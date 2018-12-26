{*******************************************************************************
  ����: fendou116688@163.com 2015/9/19
  ����: ѡ��ɹ����뵥
*******************************************************************************}
unit UFormGetPOrderBase;

{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, dxLayoutControl, StdCtrls, cxControls,
  ComCtrls, cxListView, cxButtonEdit, cxLabel, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutcxEditAdapters;

type
  TOrderBaseParam = record
    FID :string;

    FProvID: string;
    FProvName: string;

    FSaleID: string;
    FSaleName: string;

    FArea: string;
    FProject: string;

    FStockNO: string;
    FStockName: string;
    FStockModel: string;
    FRestValue: string;
    FRecID: string;
    FMemo:string;
    FKD:string;
    FYear:string;
    FPurchType: string;
  end;
  TOrderBaseParams = array of TOrderBaseParam;

  TfFormGetPOrderBase = class(TfFormNormal)
    EditProvider: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    ListQuery: TcxListView;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    EditMate: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditYear: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditOrderType: TcxComboBox;
    dxLayout1Item8: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure ListQueryKeyPress(Sender: TObject; var Key: Char);
    procedure EditCIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ListQueryDblClick(Sender: TObject);
    procedure orderange(Sender: TObject);
  private
    { Private declarations }
    FResults: TStrings;
    //��ѯ����
    FOrderData: string;
    //���뵥��Ϣ
    FOrderItems: TOrderBaseParams;
    function QueryData(const nQueryType: string=''): Boolean;
    //��ѯ����
    function QueryDataWSDL(const nQueryType: string=''): Boolean;
    //��ѯ����
    procedure GetResult;
    //��ȡ���
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UFormCtrl, UFormBase, USysGrid, USysDB,
  USysConst, UDataModule, UBusinessPacker, DateUtils, USysBusiness;

class function TfFormGetPOrderBase.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormGetPOrderBase.Create(Application) do
  begin
    Caption := 'ѡ�����뵥';
    FResults.Clear;
    SetLength(FOrderItems, 0);

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;

    if nP.FParamA = mrOK then
    begin
      nP.FParamB := PackerEncodeStr(FOrderData);
    end;
    Free;
  end;
end;

class function TfFormGetPOrderBase.FormID: integer;
begin
  Result := cFI_FormGetPOrderBase;
end;

procedure TfFormGetPOrderBase.FormCreate(Sender: TObject);
var nIni: TIniFile;
    nIdx, nInt: Integer;
    nStr: string;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListQuery, nIni);
  finally
    nIni.Free;
  end;
  EditYear.Properties.Items.Clear;
  for nIdx := 0 to 119 do
  begin
    nInt := 1 - nIdx;
    EditYear.Properties.Items.Add(FormatDateTime('YYYY-MM',IncMonth(Now,nInt)));
  end;
  nStr := FormatDateTime('DD',Now);
  try
    if StrToInt(nStr) > 25 then//26�Ÿ��¼�������
      nInt := 0
    else
      nInt := 1;
  except
    nInt := 1;
  end;
  EditYear.ItemIndex := nInt;
  FResults := TStringList.Create;
end;

procedure TfFormGetPOrderBase.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListQuery, nIni);
  finally
    nIni.Free;
  end;

  FResults.Free;
end;

//------------------------------------------------------------------------------
//Date: 2015-01-22
//Desc: ��ָ�����Ͳ�ѯ
function TfFormGetPOrderBase.QueryData(const nQueryType: string=''): Boolean;
var nStr, nQuery, nData: string;
    nIdx, nOrderCount: Integer;
    nListA, nListB: TStrings;
begin
  Result := False;
  ListQuery.Items.Clear;

  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Values['YearPeriod'] := EditYear.Text;

    if nQueryType = '1' then //��Ӧ��
    begin
      nListA.Values['Provider'] := Trim(EditProvider.Text);
    end
    else if nQueryType = '2' then //ԭ����
    begin
      nListA.Values['Materiel'] := Trim(EditMate.Text);
    end;

    nStr := PackerEncodeStr(nListA.Text);

    case EditOrderType.ItemIndex of
      0:
        nData := GetHhOrderPlan(nStr);
      1:
        nData := GetHhNeiDaoOrderPlan(nStr);
    end;

    if nData = '' then
    begin
      ShowMsg('δ��ѯ�������Ϣ',sHint);
      Exit;
    end;

    nListA.Text := PackerDecodeStr(nData);
    nOrderCount := nListA.Count;
    SetLength(FOrderItems,nOrderCount);
    for nIdx := 0 to nOrderCount-1 do
    with FOrderItems[nIdx] do
    begin
      nListB.Text := PackerDecodeStr(nListA.Strings[nIdx]);
      FID       := nListB.Values['Order'];
      FProvID   := nListB.Values['ProID'];
      FProvName := nListB.Values['ProName'];
      FSaleID   := '';
      FSaleName := '';
      FStockNO  := nListB.Values['StockNo'];
      FStockName:= nListB.Values['StockName'];
      FStockModel:= nListB.Values['Model'];
      FKD       := nListB.Values['KD'];
      FArea     := '';
      FProject  := '';
      FRecID    := nListB.Values['Order'];
      FPurchType:= EditOrderType.Text;
      FMemo     := '';
      FRestValue := nListB.Values['Value'];
      FYear     := EditYear.Text;

      with ListQuery.Items.Add do
      begin
        Caption := FID;
        SubItems.Add(FStockName);
        SubItems.Add(FStockModel);
        SubItems.Add(FProvName);
        SubItems.Add(FKD);
        SubItems.Add(FRestValue);
        SubItems.Add(FMemo);
        SubItems.Add(FRecID);
        ImageIndex := cItemIconIndex;
      end;
    end;
    if ListQuery.Items.Count>0 then
      ListQuery.ItemIndex := 0;
    Result := True;
  finally
    nListA.Free;
    nListB.Free;
  end;
end;

//Date: 2015-01-22
//Desc: ��ָ�����Ͳ�ѯ
function TfFormGetPOrderBase.QueryDataWSDL(const nQueryType: string=''): Boolean;
var nStr, nQuery, nData: string;
    nIdx, nOrderCount: Integer;
    nListA, nListB: TStrings;
begin
  Result := False;
  ListQuery.Items.Clear;

  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nStr := 'FYearPeriod = ''%s'' and FStatus = ''254'' and FCancelStatus = ''0'' ';
    nStr := Format(nStr, [EditYear.Text]);

    if nQueryType = '1' then //��Ӧ��
    begin
      if Trim(EditProvider.Text) <> '' then
      begin
        nStr := nStr + 'and FMaterialProviderName like ''%%%s%%'' ';
        nStr := Format(nStr, [Trim(EditProvider.Text)]);
      end;
    end
    else if nQueryType = '2' then //ԭ����
    begin
      if Trim(EditMate.Text) <> '' then
      begin
        nStr := nStr + 'and FMaterielName like ''%%%s%%'' ';
        nStr := Format(nStr, [Trim(EditMate.Text)]);
      end;
    end;

    nStr := PackerEncodeStr(nStr);

    case EditOrderType.ItemIndex of
      0:
        nData := GetHhOrderPlanWSDL(nStr);
      1:
        nData := GetHhNeiDaoOrderPlanWSDL(nStr);
    end;

    if nData = '' then
    begin
      ShowMsg('δ��ѯ�������Ϣ',sHint);
      Exit;
    end;

    nListA.Text := PackerDecodeStr(nData);
    nOrderCount := nListA.Count;
    SetLength(FOrderItems,nOrderCount);
    for nIdx := 0 to nOrderCount-1 do
    with FOrderItems[nIdx] do
    begin
      nListB.Text := PackerDecodeStr(nListA.Strings[nIdx]);
      FID       := nListB.Values['Order'];
      FProvID   := nListB.Values['ProID'];
      FProvName := nListB.Values['ProName'];
      FSaleID   := '';
      FSaleName := '';
      FStockNO  := nListB.Values['StockNo'];
      FStockName:= nListB.Values['StockName'];
      FStockModel:= nListB.Values['Model'];
      FKD       := nListB.Values['KD'];
      FArea     := '';
      FProject  := '';
      FRecID    := nListB.Values['Order'];
      FPurchType:= EditOrderType.Text;
      FMemo     := '';
      FRestValue := nListB.Values['Value'];
      FYear     := EditYear.Text;

      with ListQuery.Items.Add do
      begin
        Caption := FID;
        SubItems.Add(FStockName);
        SubItems.Add(FStockModel);
        SubItems.Add(FProvName);
        SubItems.Add(FKD);
        SubItems.Add(FRestValue);
        SubItems.Add(FMemo);
        SubItems.Add(FRecID);
        ImageIndex := cItemIconIndex;
      end;
    end;
    if ListQuery.Items.Count>0 then
      ListQuery.ItemIndex := 0;
    Result := True;
  finally
    nListA.Free;
    nListB.Free;
  end;
end;

procedure TfFormGetPOrderBase.EditCIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nQueryType: string;
begin
  if Sender = EditProvider then
       nQueryType := '1'
  else nQueryType := '2';

  {$IFDEF SyncDataByWSDL}
  if QueryDataWSDL(nQueryType) then ListQuery.SetFocus;
  {$ELSE}
  if QueryData(nQueryType) then ListQuery.SetFocus;
  {$ENDIF}
end;

//Desc: ��ȡ���
procedure TfFormGetPOrderBase.GetResult;
var nIdx: Integer;
begin
  with ListQuery.Selected do
  begin
    for nIdx:=Low(FOrderItems) to High(FOrderItems) do
    with FOrderItems[nIdx], FResults do
    begin
      //if CompareText(FID, Caption)=0 then
      if CompareText(FRecID, SubItems[6])=0 then
      begin
        Values['SQ_ID']       := FID;
        Values['SQ_ProID']    := FProvID;
        Values['SQ_ProName']  := FProvName;
        Values['SQ_SaleID']   := FSaleID;
        Values['SQ_SaleName'] := FSaleName;
        Values['SQ_StockNO']  := FStockNO;
        Values['SQ_StockName']:= FStockName;
        Values['SQ_Area']     := FArea;
        Values['SQ_Project']  := FProject;
        Values['SQ_RestValue']:= FRestValue;
        Values['SQ_RecID']    := FRecID;
        Values['SQ_PurchType']:= FPurchType;
        Values['SQ_Memo']     := FMemo;
        Values['SQ_Model']    := FStockModel;
        Values['SQ_KD']       := FKD;
        Values['SQ_Year']     := FYear;
        Break;
      end;
    end;
  end;

  FOrderData := FResults.Text;
end;

procedure TfFormGetPOrderBase.ListQueryKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if ListQuery.ItemIndex > -1 then
    begin
      GetResult;
      if (StrToFloat(FResults.Values['SQ_RestValue'])<=0) and (FResults.Values['SQ_PurchType']<>'0')  then
      begin
        if not QueryDlg('����ʣ��������,�Ƿ��������?', sHint) then Exit;
      end;
      ModalResult := mrOk;
    end;
  end;
end;

procedure TfFormGetPOrderBase.ListQueryDblClick(Sender: TObject);
begin
  if ListQuery.ItemIndex > -1 then
  begin
    GetResult;
    if (StrToFloat(FResults.Values['SQ_RestValue'])<=0) and (FResults.Values['SQ_PurchType']<>'0')  then
    begin
      if not QueryDlg('����ʣ��������,�Ƿ��������?', sHint) then Exit;
    end;
    ModalResult := mrOk;
  end;
end;

procedure TfFormGetPOrderBase.BtnOKClick(Sender: TObject);
begin
  if ListQuery.ItemIndex > -1 then
  begin
    GetResult;
    if (StrToFloat(FResults.Values['SQ_RestValue'])<=0) and (FResults.Values['SQ_PurchType']<>'0')  then
    begin
      if not QueryDlg('����ʣ��������,�Ƿ��������?', sHint) then Exit;
    end;
    ModalResult := mrOk;
  end else ShowMsg('���ڲ�ѯ�����ѡ��', sHint);
end;

procedure TfFormGetPOrderBase.orderange(
  Sender: TObject);
begin
  if EditOrderType.ItemIndex = 1 then
    dxLayout1Item5.Visible := False
  else
    dxLayout1Item5.Visible := True;
  ListQuery.Items.Clear;
end;

initialization
  gControlManager.RegCtrl(TfFormGetPOrderBase, TfFormGetPOrderBase.FormID);
end.
