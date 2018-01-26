{*******************************************************************************
  ����: dmzn@163.com 2017-09-26
  ����: �������
*******************************************************************************}
unit UFormBill;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, ComCtrls, cxContainer, cxEdit, cxCheckBox,
  cxMaskEdit, cxDropDownEdit, cxTextEdit, cxListView, cxMCListBox,
  dxLayoutControl, StdCtrls, cxMemo, cxLabel, cxCalendar;

type
  TfFormBill = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    dxLayout1Item3: TdxLayoutItem;
    ListInfo: TcxMCListBox;
    EditValue: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditStock: TcxComboBox;
    dxLayout1Item7: TdxLayoutItem;
    EditLading: TcxComboBox;
    dxLayout1Item12: TdxLayoutItem;
    EditFQ: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    dxLayout1Item6: TdxLayoutItem;
    EditType: TcxComboBox;
    PrintGLF: TcxCheckBox;
    dxLayout1Item13: TdxLayoutItem;
    dxLayout1Item14: TdxLayoutItem;
    PrintHY: TcxCheckBox;
    dxLayout1Group4: TdxLayoutGroup;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Group6: TdxLayoutGroup;
    dxLayout1Group2: TdxLayoutGroup;
    cxLabel1: TcxLabel;
    dxLayout1Item4: TdxLayoutItem;
    EditPhone: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    EditUnloading: TcxMemo;
    dxLayout1Item11: TdxLayoutItem;
    EditDate: TcxDateEdit;
    dxLayout1Item15: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
    procedure EditFQPropertiesEditValueChanged(Sender: TObject);
  protected
    { Protected declarations }
    FMsgNo: Cardinal;
    FBuDanFlag: string;
    //�������
    procedure LoadFormData;
    //��������
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

implementation

{$R *.dfm}

uses
  ULibFun, DB, IniFiles, UMgrControl, UFormBase, UDataModule, UAdjustForm,
  UBusinessConst, USysPopedom, USysBusiness, USysDB, USysGrid, USysConst,
  UBusinessPacker, UFormWait;

var
  gBillItem: TLadingBillItem;
  //�ᵥ����

class function TfFormBill.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nBool,nBuDan: Boolean;
    nDef: TLadingBillItem;
    nP: PFormCommandParam;
begin
  Result := nil;
  if GetSysValidDate < 1 then Exit;

  nP := nil;
  try
    if not Assigned(nParam) then
    begin
      New(nP);
      FillChar(nP^, SizeOf(TFormCommandParam), #0);
    end else nP := nParam;

    nBuDan := nPopedom = 'MAIN_D04';
    FillChar(nDef, SizeOf(nDef), #0);
    nP.FParamE := @nDef;

    CreateBaseFormItem(cFI_FormGetZhika, nPopedom, nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    gBillItem := nDef;
  finally
    if not Assigned(nParam) then Dispose(nP);
  end;

  with TfFormBill.Create(Application) do
  try
    Caption := '�������';
    FMsgNo := GetTickCount;

    if nBuDan then //����
         FBuDanFlag := sFlag_Yes
    else FBuDanFlag := sFlag_No;

    nBool := not gPopedomManager.HasPopedom(nPopedom, sPopedom_Edit);
    EditLading.Properties.ReadOnly := nBool;
    LoadFormData;

    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;

      if FParamA = mrOK then
           FParamB := gBillItem.FID
      else FParamB := '';
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBill.FormID: integer;
begin
  Result := cFI_FormBill;
end;

procedure TfFormBill.FormCreate(Sender: TObject);
var nStr: string;
    nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nStr := nIni.ReadString(Name, 'FQLabel', '');
    if nStr <> '' then
      dxLayout1Item5.Caption := nStr;
    //xxxxx

    PrintHY.Checked := nIni.ReadBool(Name, 'PrintHY', False);
    //�泵����
    LoadMCListBoxConfig(Name, ListInfo, nIni);
  finally
    nIni.Free;
  end;

  {$IFDEF PrintGLF}
  dxLayout1Item13.Visible := True;
  {$ELSE}
  dxLayout1Item13.Visible := False;
  PrintGLF.Checked := False;
  {$ENDIF}

  {$IFDEF PrintHYEach}
  dxLayout1Item14.Visible := True;
  {$ELSE}
  dxLayout1Item14.Visible := False;
  PrintHY.Checked := False;
  {$ENDIF}

  AdjustCtrlData(Self);
end;

procedure TfFormBill.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nIni.WriteBool(Name, 'PrintHY', PrintHY.Checked);
    SaveMCListBoxConfig(Name, ListInfo, nIni);
  finally
    nIni.Free;
  end;

  ReleaseCtrlData(Self);
end;

//Desc: �س���
procedure TfFormBill.EditLadingKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    if Sender = EditTruck then ActiveControl := EditValue else
    if Sender = EditPhone then ActiveControl := EditUnloading else
    if Sender = EditUnloading then ActiveControl := BtnOK else
    //xxxxx
    
    if Sender = EditValue then
         ActiveControl := BtnOK
    else Perform(WM_NEXTDLGCTL, 0, 0);
  end;

  if (Sender = EditTruck) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
    begin
      EditTruck.Text := nP.FParamB;
      EditPhone.Text := nP.FParamD;
    end;
    EditTruck.SelectAll;
  end;

  if (Sender = EditUnloading) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditUnloading.Text;
    CreateBaseFormItem(cFI_FormGetUnloading, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
      EditUnloading.Text := nP.FParamB;
    EditUnloading.SelectAll;
  end;
end;

//------------------------------------------------------------------------------
//Desc: �����������
procedure TfFormBill.LoadFormData;
var nStr: string;
begin
  dxGroup1.AlignVert := avClient;
  dxGroup2.AlignVert := avBottom;

  EditDate.Date := Now();
  dxLayout1Item15.Visible := FBuDanFlag = sFlag_Yes;

  ActiveControl := EditTruck;
  EditStock.ItemIndex := 1; //ˮ��

  with gBillItem,ListInfo do
  begin
    Clear;
    Items.Add(Format('�������:%s %s', [Delimiter, FZhiKa]));
    Items.Add(Format('��������:%s %s', [Delimiter, FStatus]));
    Items.Add(Format('��������:%s %s', [Delimiter, FNextStatus]));

    Items.Add(Format('%s ', [Delimiter]));
    Items.Add(Format('�ͻ����:%s %s', [Delimiter, FCusID]));
    Items.Add(Format('�ͻ�����:%s %s', [Delimiter, FCusName]));

    Items.Add(Format('%s ', [Delimiter]));
    Items.Add(Format('���ϱ��:%s %s', [Delimiter, FStockNo]));
    Items.Add(Format('��������:%s %s', [Delimiter, FStockName]));

    if FType = sFlag_Dai then nStr := '��װ' else nStr := 'ɢװ';
    Items.Add(Format('��������:%s %s', [Delimiter, nStr]));
    Items.Add(Format('Ԥ�ƿ���:%s %.2f��', [Delimiter, FValue]));
  end;
end;

//Desc: �����ǩ��
procedure TfFormBill.EditFQPropertiesEditValueChanged(Sender: TObject);
var nIni: TIniFile;
begin
  inherited;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nIni.WriteString('EditFQ', GetCtrlData(EditStock), EditFQ.Text);
  finally
    nIni.Free;
  end;
end;

function TfFormBill.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '���ƺų���Ӧ����2λ';
  end else

  if Sender = EditLading then
  begin
    Result := EditLading.ItemIndex > -1;
    nHint := '��ѡ�������ʽ';
  end else

  if Sender = EditStock then
  begin
    Result := EditStock.ItemIndex > -1;
    nHint := '��ѡ����ص�';
  end else

  if Sender = EditFQ then
  begin
    EditFQ.Text := Trim(EditFQ.Text);
    Result := (Length(EditFQ.Text) > 0) or (not VerifyFQSumValue);
    nHint := '������Ų���Ϊ��';
  end else

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    nHint := '����д��Ч�İ�����';
    if not Result then Exit;
  end;
end;

//Desc: ����
procedure TfFormBill.BtnOKClick(Sender: TObject);
var nPrint: Boolean;
    nList,nStocks: TStrings;
begin
  nStocks := TStringList.Create;
  nList := TStringList.Create;
  try
    nList.Clear;
    nPrint := False;
    LoadSysDictItem(sFlag_PrintBill, nStocks);
    //���ӡƷ��

    with nList do
    begin
      if PrintGLF.Checked  then
           Values['PrintGLF'] := sFlag_Yes
      else Values['PrintGLF'] := sFlag_No;

      if PrintHY.Checked  then
           Values['PrintHY'] := sFlag_Yes
      else Values['PrintHY'] := sFlag_No;

      if (not nPrint) and (FBuDanFlag <> sFlag_Yes) then
        nPrint := nStocks.IndexOf(gBillItem.FStockNo) >= 0;
      //xxxxx

      Values['ZhiKa']        := gBillItem.FZhiKa;
      Values['Truck']        := EditTruck.Text;
      Values['Value']        := EditValue.Text;

      Values['Area']         := GetCtrlData(EditStock);
      Values['Lading']       := GetCtrlData(EditLading);
      Values['IsVIP']        := GetCtrlData(EditType);

      Values['Value']        := EditValue.Text;
      Values['Seal']         := EditFQ.Text;
      Values['BuDan']        := FBuDanFlag;
      Values['BuDanDate']    := Date2Str(EditDate.Date);

      Values['Phone']        := Trim(EditPhone.Text);
      Values['Unloading']    := Trim(EditUnloading.Text);
      Values['MsgNo']        := IntToStr(FMsgNo);
    end;

    ShowWaitForm(Self, '���ڱ�������', True);
    try
      gBillItem.FID := SaveBill(PackerEncodeStr(nList.Text));
      //call mit bus
    finally
      CloseWaitForm;
    end;

    if gBillItem.FID = '' then Exit;
    //save failed
  finally
    nList.Free;
    nStocks.Free;
  end;

  if FBuDanFlag <> sFlag_Yes then
    SetBillCard(gBillItem.FID, EditTruck.Text, True);
  //����ſ�

  if nPrint then
    PrintBillReport(gBillItem.FID, True);
  //print report
  
  ModalResult := mrOk;
  ShowMsg('���������ɹ�', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormBill, TfFormBill.FormID);
end.
