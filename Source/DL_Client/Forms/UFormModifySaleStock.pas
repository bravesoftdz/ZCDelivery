{*******************************************************************************
  ����: juner11212436@163.com 2018/03/28
  ����: �����޸�����
*******************************************************************************}
unit UFormModifySaleStock;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxButtonEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxDropDownEdit, cxLabel,
  dxLayoutcxEditAdapters, cxCheckBox, cxCalendar, ComCtrls, cxListView;

type
  TfFormModifySaleStock = class(TfFormNormal)
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
    EditPValue: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item13: TdxLayoutItem;
    EditLValue: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FListA: TStrings;
    FOldValue: Double;
    FOldBatchCode: string;
    FOldZhiKa: string;
    procedure InitFormData;
    //��ʼ������
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


class function TfFormModifySaleStock.CreateForm(const nPopedom: string;
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

  with TfFormModifySaleStock.Create(Application) do
  try
    Caption := '�����޸�����';

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

class function TfFormModifySaleStock.FormID: integer;
begin
  Result := cFI_FormSaleModifyStock;
end;

procedure TfFormModifySaleStock.FormCreate(Sender: TObject);
begin
  FListA    := TStringList.Create;
  AdjustCtrlData(Self);
  LoadFormConfig(Self);
  dxGroup1.AlignHorz := ahClient;
end;

procedure TfFormModifySaleStock.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);

  FListA.Free;
end;

//------------------------------------------------------------------------------
procedure TfFormModifySaleStock.InitFormData;
var nStr: string;
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
      EditTruck.Text := FieldByName('L_Truck').AsString;
      if Length(FieldByName('L_PValue').AsString) > 0 then
        EditPValue.Text := FieldByName('L_PValue').AsString
      else
        EditPValue.Text := '0';
      EditLValue.Text := FieldByName('L_Value').AsString;
      FOldValue := FieldByName('L_Value').AsFloat;
      FOldBatchCode := FieldByName('L_HYDan').AsString;
      FOldZhiKa := FieldByName('L_ZhiKa').AsString;
    end;
  end;
  if ListQuery.Items.Count>0 then
    ListQuery.ItemIndex := 0;
  BtnOK.Enabled := ListQuery.Items.Count>0;
end;

//Desc: ����
procedure TfFormModifySaleStock.BtnOKClick(Sender: TObject);
var nStr,nSQL,nStockNo: string;
    nIdx: Integer;
    nValue,nNewValue: Double;
    nNewBatchCode: string;
begin
  if not QueryDlg('ȷ��Ҫ�޸����������������?', sHint) then Exit;

  if not IsNumber(EditPValue.Text,True) then
  begin
    EditPValue.SetFocus;
    nStr := '��������ЧƤ��';
    ShowMsg(nStr,sHint);
    Exit;
  end;

  if not IsNumber(EditLValue.Text,True) then
  begin
    EditLValue.SetFocus;
    nStr := '��������Ч�����';
    ShowMsg(nStr,sHint);
    Exit;
  end;

  nNewValue := StrToFloat(EditLValue.Text);
  if nNewValue > gBillItem.FValue then
  begin
    EditLValue.SetFocus;
    nStr := '������������,�޷��޸�';
    ShowMsg(nStr,sHint);
    Exit;
  end;

  nValue := nNewValue - FOldValue;

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

      nNewBatchCode := GetBatchCode(gBillItem.FStockNo,
                                    gBillItem.FCusName,
                                    nNewValue);

      if nNewBatchCode = '' then
      begin
        ShowMsg('��ȡ���κ�ʧ��',sHint);
        Exit;
      end;

      nSQL := 'Update %s Set L_StockNo=''%s'',L_StockName=''%s'',L_ZhiKa=''%s'','+
              ' L_Truck=''%s'',L_PValue=''%s'',L_Value=''%s'','+
              ' L_CusName=''%s'',L_CusPY=''%s'',L_Type=''%s'',L_HYDan=''%s'','+
              ' L_Order=''%s'' Where L_ID=''%s''';
      nSQL := Format(nSQL, [sTable_Bill, gBillItem.FStockNo,
                                          gBillItem.FStockName,
                                          gBillItem.FZhiKa,
                                          Trim(EditTruck.Text),
                                          Trim(EditPValue.Text),
                                          FloatToStr(nNewValue),
                                          gBillItem.FCusName,
                                          GetPinYinOfStr(gBillItem.FCusName,),
                                          gBillItem.FType,
                                          nNewBatchCode,
                                          gBillItem.FZhiKa,
                                          FListA.Strings[nIdx]]);
      FDM.ExecuteSQL(nSQL);


      nSQL := 'Update %s Set P_MID=''%s'', P_MName=''%s'', P_MType=''%s'','+
              ' P_CusName=''%s'',P_PValue=''%s'','+
              ' P_KwMan=''%s'',P_KwDate=%s,P_Truck=''%s'' Where P_Bill=''%s''';
      nSQL := Format(nSQL, [sTable_PoundLog, gBillItem.FStockNo,
                                          gBillItem.FStockName,
                                          gBillItem.FType,
                                          gBillItem.FCusName,
                                          EditPValue.Text,
                                          gSysParam.FUserID,
                                          sField_SQLServer_Now,
                                          Trim(EditTruck.Text),
                                          FListA.Strings[nIdx]]);
      FDM.ExecuteSQL(nSQL);

      nStr := 'Update %s Set O_Freeze=O_Freeze-(%.2f) Where O_Order=''%s''';
      nStr := Format(nStr, [sTable_SalesOrder, FOldValue, FOldZhiKa]);
      FDM.ExecuteSQL(nStr); //����

      nStr := 'Update %s Set B_HasUse=B_HasUse-(%.2f) Where B_Batcode=''%s''';
      nStr := Format(nStr, [sTable_StockBatcode, FOldValue, FOldBatchCode]);
      FDM.ExecuteSQL(nStr);
      //�ͷ�ʹ�õ����κ�

      nStr := 'Update %s Set R_Used=R_Used-(%.2f) Where R_Batcode=''%s''';
      nStr := Format(nStr, [sTable_BatRecord, FOldValue, FOldBatchCode]);
      FDM.ExecuteSQL(nStr);
      //�ͷ����μ�¼ʹ����


      nStr := 'Update %s Set O_Freeze=O_Freeze+(%.2f) Where O_Order=''%s''';
      nStr := Format(nStr, [sTable_SalesOrder, nNewValue, gBillItem.FZhiKa]);
      FDM.ExecuteSQL(nStr); //����

      nStr := 'Update %s Set B_HasUse=B_HasUse+(%.2f) Where B_Batcode=''%s''';
      nStr := Format(nStr, [sTable_StockBatcode, nNewValue, nNewBatchCode]);
      FDM.ExecuteSQL(nStr);
      //����ʹ�õ����κ�

      nStr := 'Update %s Set R_Used=R_Used+(%.2f) Where R_Batcode=''%s''';
      nStr := Format(nStr, [sTable_BatRecord, nNewValue, nNewBatchCode]);
      FDM.ExecuteSQL(nStr);
      //�������μ�¼ʹ����

    end
    else
    begin
      nSQL := 'Update %s Set L_Truck=''%s'',L_PValue=''%s'','+
              ' L_Value=''%s'' Where L_ID=''%s''';
      nSQL := Format(nSQL, [sTable_Bill, Trim(EditTruck.Text),
                                          Trim(EditPValue.Text),
                                          FloatToStr(nNewValue),
                                          FListA.Strings[nIdx]]);
      FDM.ExecuteSQL(nSQL);

      nSQL := 'Update %s Set P_PValue=''%s'','+
              ' P_KwMan=''%s'',P_KwDate=%s,P_Truck=''%s'' Where P_Bill=''%s''';
      nSQL := Format(nSQL, [sTable_PoundLog,EditPValue.Text,
                                            gSysParam.FUserID,
                                            sField_SQLServer_Now,
                                            Trim(EditTruck.Text),
                                            FListA.Strings[nIdx]]);
      FDM.ExecuteSQL(nSQL);

      if nValue <> 0 then//���ط����仯
      begin
        nStr := 'Update %s Set O_Freeze=O_Freeze+(%.2f) Where O_Order=''%s''';
        nStr := Format(nStr, [sTable_SalesOrder, nValue, FOldZhiKa]);
        FDM.ExecuteSQL(nStr); //����

        nStr := 'Update %s Set B_HasUse=B_HasUse+(%.2f) Where B_Batcode=''%s''';
        nStr := Format(nStr, [sTable_StockBatcode, nValue, FOldBatchCode]);
        FDM.ExecuteSQL(nStr);
        //����ʹ�õ����κ�

        nStr := 'Update %s Set R_Used=R_Used+(%.2f) Where R_Batcode=''%s''';
        nStr := Format(nStr, [sTable_BatRecord, nValue, FOldBatchCode]);
        FDM.ExecuteSQL(nStr);
        //�������μ�¼ʹ����
      end;
    end;
  end;

  ModalResult := mrOK;
  nStr := '�޸����';
  ShowMsg(nStr, sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormModifySaleStock, TfFormModifySaleStock.FormID);
end.
