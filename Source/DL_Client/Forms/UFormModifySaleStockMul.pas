{*******************************************************************************
  ����: juner11212436@163.com 2019/03/30
  ����: ��ɽ�����޸�����
*******************************************************************************}
unit UFormModifySaleStockMul;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxButtonEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxDropDownEdit, cxLabel,
  dxLayoutcxEditAdapters, cxCheckBox, cxCalendar, ComCtrls, cxListView;

type
  TfFormModifySaleStockMul = class(TfFormNormal)
    EditMate: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditID: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditCName: TcxTextEdit;
    dxlytmLayout1Item3: TdxLayoutItem;
    editMemo: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    dxLayout1Item3: TdxLayoutItem;
    ListQuery: TcxListView;
    EditType: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FListA: TStrings;
    FOldValue, FOldPValue, FTotalValue: Double;
    FOldBatchCode: string;
    FOldZhiKa, FOldTruck, FOldMValueMax: string;
    procedure InitFormData;
    //��ʼ������
    procedure WriteOptionLog(const LID: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, DB, IniFiles, UMgrControl, UAdjustForm, UFormBase, UBusinessPacker,
  UDataModule, USysBusiness, USysDB, USysGrid, USysConst,DateUtils,
  UBusinessConst;

var
  gBillItem: TLadingBillItem;
  //�ᵥ����


class function TfFormModifySaleStockMul.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nStr, nModifyStr: string;
    nP: PFormCommandParam;
    nList: TStrings;
    nDef: TLadingBillItem;
begin
  Result := nil;
  if GetSysValidDate < 1 then Exit;

  if Assigned(nParam) then
       nP := nParam
  else Exit;

  nModifyStr := nP.FParamA;

  try
    FillChar(nDef, SizeOf(nDef), #0);
    nP.FParamE := @nDef;

    CreateBaseFormItem(cFI_FormGetZhika, nPopedom, nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
      gBillItem := nDef;
  finally
    if not Assigned(nParam) then Dispose(nP);
  end;

  with TfFormModifySaleStockMul.Create(Application) do
  try
    Caption := '��ɽ���������޸�����';

    FListA.Text := nModifyStr;
    InitFormData;

    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;

      if FParamA = mrOK then
           FParamB := ''
      else FParamB := '';
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormModifySaleStockMul.FormID: integer;
begin
  Result := cFI_FormSaleModifyStockMul;
end;

procedure TfFormModifySaleStockMul.FormCreate(Sender: TObject);
begin
  FListA    := TStringList.Create;
  AdjustCtrlData(Self);
  LoadFormConfig(Self);
  dxGroup1.AlignHorz := ahClient;
end;

procedure TfFormModifySaleStockMul.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);

  FListA.Free;
end;

//------------------------------------------------------------------------------
procedure TfFormModifySaleStockMul.InitFormData;
var nStr, nPreFix: string;
    nIdx: Integer;
begin
  with gBillItem do
  begin
    if gBillItem.FZhiKa <> '' then
    begin
      EditID.Text       := FZhiKa;
      EditCName.Text    := FCusName;
      EditMate.Text     := FStockName;
      if FType = sFlag_Dai then nStr := '��װ' else nStr := 'ɢװ';
      EditType.Text     := nStr;
      EditValue.Text     := FloatToStr(FValue);
    end;
  end;
  nPreFix := 'WY';
  nStr := 'Select B_Prefix From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nPreFix := Fields[0].AsString;
  end;

  if Pos(nPreFix,gBillItem.FZhiKa) <= 0 then
  begin
    ShowMsg('�ǿ�ɽ���˶���,���ܽ����޸�', sHint);
    Exit;
  end;

  FTotalValue := 0;
  for nIdx := 0 to FListA.Count - 1 do
  begin
    nStr := 'select * From %s where L_ID = ''%s'' ';

    nStr := Format(nStr,[sTable_Bill,FListA.Strings[nIdx]]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
        Continue;

      with ListQuery.Items.Add do
      begin
        Caption := FieldByName('L_ID').AsString;
        SubItems.Add(FieldByName('L_Truck').AsString);
        SubItems.Add(FieldByName('L_StockName').AsString);
        if FieldByName('L_Type').AsString = sFlag_Dai then
          nStr := '��װ'
        else
          nStr := 'ɢװ';
        SubItems.Add(nStr);
        SubItems.Add(FieldByName('L_ZhiKa').AsString);
        SubItems.Add(FieldByName('L_CusName').AsString);
        SubItems.Add(FieldByName('L_PValue').AsString);
        SubItems.Add(FieldByName('L_Value').AsString);
        ImageIndex := cItemIconIndex;
      end;
      FTotalValue := FTotalValue + FieldByName('L_Value').AsFloat;
      FOldValue := FieldByName('L_Value').AsFloat;
      FOldBatchCode := FieldByName('L_HYDan').AsString;
      if FOldZhiKa <> '' then
      begin
        if FOldZhiKa <> FieldByName('L_ZhiKa').AsString then
        begin
          ShowMsg('��ѡ��¼�Ķ����Ų�һ��,�޷������޸�', sHint);
          Exit;
        end;
      end;
      FOldZhiKa := FieldByName('L_ZhiKa').AsString;
    end;
  end;
  if ListQuery.Items.Count>0 then
    ListQuery.ItemIndex := 0;
  BtnOK.Enabled := ListQuery.Items.Count>0;
end;

//Desc: ����
procedure TfFormModifySaleStockMul.BtnOKClick(Sender: TObject);
var nStr,nSQL,nStockNo,nStockName,nHint: string;
    nIdx: Integer;
    nNewBatchCode: string;
begin
  if not QueryDlg('ȷ��Ҫ�޸����������������?', sHint) then Exit;

  if FTotalValue > gBillItem.FValue then
  begin
    nStr := '������������,�޷��޸�';
    ShowMsg(nStr,sHint);
    Exit;
  end;

  for nIdx := 0 to FListA.Count - 1 do
  begin
    if Length(EditID.Text) > 0 then//��������
    begin
      nStr := 'Select D_ParamB From %s Where D_Name = ''%s'' ' +
              'And D_Memo=''%s'' and D_Value like ''%%%s%%''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem,
                            gBillItem.FType,
                            Trim(gBillItem.FStockName)]);

      with FDM.QueryTemp(nStr) do
      begin
        if RecordCount < 1 then
        begin
          ShowMsg('δ��ѯ�����ϱ��',sHint);
          Exit;
        end;
        gBillItem.FStockNo := Fields[0].AsString;
      end;

      nSQL := 'Update %s Set L_StockNo=''%s'',L_StockName=''%s'',L_ZhiKa=''%s'','+
              ' L_CusName=''%s'',L_CusPY=''%s'',L_Type=''%s'',L_HYDan=''%s'','+
              ' L_Status=''%s'',L_NextStatus=Null,'+
              ' L_Order=''%s'' Where L_ID=''%s''';
      nSQL := Format(nSQL, [sTable_Bill, gBillItem.FStockNo,
                                          gBillItem.FStockName,
                                          gBillItem.FZhiKa,
                                          gBillItem.FCusName,
                                          GetPinYinOfStr(gBillItem.FCusName,),
                                          gBillItem.FType,
                                          nNewBatchCode,
                                          sFlag_TruckNone,
                                          gBillItem.FZhiKa,
                                          FListA.Strings[nIdx]]);
      FDM.ExecuteSQL(nSQL);

    end
    else
    begin
      ShowMsg('δѡ���¶���,�޷��޸�', sHint);
      Exit;
    end;
    WriteOptionLog(FListA.Strings[nIdx]);
  end;

  nStr := 'Update %s Set O_Freeze=O_Freeze-(%.2f) Where O_Order=''%s''';
  nStr := Format(nStr, [sTable_SalesOrder, FTotalValue, FOldZhiKa]);
  FDM.ExecuteSQL(nStr); //����

  nStr := 'Update %s Set B_HasUse=B_HasUse-(%.2f) Where B_Batcode=''%s''';
  nStr := Format(nStr, [sTable_StockBatcode, FTotalValue, FOldBatchCode]);
  FDM.ExecuteSQL(nStr);
  //�ͷ�ʹ�õ����κ�

  nStr := 'Update %s Set R_Used=R_Used-(%.2f) Where R_Batcode=''%s''';
  nStr := Format(nStr, [sTable_BatRecord, FTotalValue, FOldBatchCode]);
  FDM.ExecuteSQL(nStr);
  //�ͷ����μ�¼ʹ����


  nStr := 'Update %s Set O_Freeze=O_Freeze+(%.2f) Where O_Order=''%s''';
  nStr := Format(nStr, [sTable_SalesOrder, FTotalValue, gBillItem.FZhiKa]);
  FDM.ExecuteSQL(nStr); //����

  nStr := 'Update %s Set B_HasUse=B_HasUse+(%.2f) Where B_Batcode=''%s''';
  nStr := Format(nStr, [sTable_StockBatcode, FTotalValue, nNewBatchCode]);
  FDM.ExecuteSQL(nStr);
  //����ʹ�õ����κ�

  nStr := 'Update %s Set R_Used=R_Used+(%.2f) Where R_Batcode=''%s''';
  nStr := Format(nStr, [sTable_BatRecord, FTotalValue, nNewBatchCode]);
  FDM.ExecuteSQL(nStr);
  //�������μ�¼ʹ����

  ModalResult := mrOK;
  nStr := '�޸����';
  ShowMsg(nStr, sHint);
end;

procedure TfFormModifySaleStockMul.WriteOptionLog(const LID: string);
var nEvent: string;
begin
  nEvent := '';

  begin
    if EditID.Text <> '' then
    begin
      nEvent := nEvent + '�������� [ %s ] --> [ %s ];';
      nEvent := Format(nEvent, [FOldZhiKa, EditID.Text]);
    end;

    if nEvent <> '' then
    begin
      nEvent := '����� [ %s ] �����ѱ��޸�:' + nEvent;
      nEvent := Format(nEvent, [LID]);
    end;
  end;

  if nEvent <> '' then
  begin
    FDM.WriteSysLog(sFlag_BillItem, LID, nEvent);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormModifySaleStockMul, TfFormModifySaleStockMul.FormID);
end.
