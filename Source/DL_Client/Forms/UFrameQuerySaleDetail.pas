{*******************************************************************************
  ����: dmzn@163.com 2012-03-26
  ����: ������ϸ
*******************************************************************************}
unit UFrameQuerySaleDetail;

{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, IniFiles, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxMaskEdit, cxButtonEdit, cxTextEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxCheckBox;

type
  TfFrameSaleDetailQuery = class(TfFrameNormal)
    cxtxtdt1: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditCustomer: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    cxtxtdt2: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    pmPMenu1: TPopupMenu;
    mniN1: TMenuItem;
    cxtxtdt3: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxtxtdt4: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditBill: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    N1: TMenuItem;
    chkAll: TcxCheckBox;
    dxLayout1Item9: TdxLayoutItem;
    N2: TMenuItem;
    N3: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure mniN1Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //ʱ������
    FJBWhere: string;
    //��������
    FValue,FMoney: Double;
    //���۲���
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnLoadGridConfig(const nIni: TIniFile); override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //��ѯSQL
    procedure SummaryItemsGetText(Sender: TcxDataSummaryItem;
      const AValue: Variant; AIsFooter: Boolean; var AText: String);
    //����ժҪ
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UFormDateFilter, USysPopedom, USysBusiness,
  UBusinessConst, USysConst, USysDB, UDataModule, UBusinessPacker;

class function TfFrameSaleDetailQuery.FrameID: integer;
begin
  Result := cFI_FrameSaleDetailQuery;
end;

procedure TfFrameSaleDetailQuery.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  FJBWhere := '';
  InitDateRange(Name, FStart, FEnd);

  {$IFDEF SyncDataByWSDL}
  N1.Visible := False;
  N2.Visible := True;
  N3.Visible := True;
  {$ELSE}
  N1.Visible := True;
  N2.Visible := False;
  N3.Visible := False;
  {$ENDIF}

  {$IFDEF UseFliterRefresh}
  //ɸѡ���ݼ��Զ�ˢ��
  cxView1.DataController.Filter.AutoDataSetFilter := True;
  {$ENDIF}
end;

procedure TfFrameSaleDetailQuery.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfFrameSaleDetailQuery.OnLoadGridConfig(const nIni: TIniFile);
var i,nCount: Integer;
begin
  with cxView1.DataController.Summary do
  begin
    nCount := FooterSummaryItems.Count - 1;
    for i:=0 to nCount do
      FooterSummaryItems[i].OnGetText := SummaryItemsGetText;
    //���¼�

    nCount := DefaultGroupSummaryItems.Count - 1;
    for i:=0 to nCount do
      DefaultGroupSummaryItems[i].OnGetText := SummaryItemsGetText;
    //���¼�
  end;

  inherited;
end;

function TfFrameSaleDetailQuery.InitFormDataSQL(const nWhere: string): string;
begin
  FEnableBackDB := True;
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select *, CAST((L_Value * L_Price) as decimal(38, 2)) as L_Money From $Bill b ' +
            ' Left Join $ZK on O_Order=L_ZhiKa ' +
            ' Left Join $C on C_ID=L_CusID ' +
            ' Left Join $Truck on T_Truck=L_Truck ';
  //�����

  if FJBWhere = '' then
  begin
    Result := Result + 'Where (L_OutFact>=''$S'' and L_OutFact <''$End'')';

    if nWhere <> '' then
      Result := Result + ' And (' + nWhere + ')';
    //xxxxx
  end else
  begin
    Result := Result + ' Where (' + FJBWhere + ')';
  end;

  if not chkAll.Checked then
    Result := Result + ' And (L_TruckEmpty <>''Y'' or L_TruckEmpty is null)';

  Result := MacroValue(Result, [MI('$Bill', sTable_Bill),
            MI('$ZK', sTable_SalesOrder),
            MI('$Truck', sTable_Truck),
            MI('$C', sTable_Customer),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;

//Desc: �����ֶ�
function TfFrameSaleDetailQuery.FilterColumnField: string;
begin
  if gPopedomManager.HasPopedom(PopedomItem, sPopedom_ViewPrice) then
       Result := ''
  else Result := 'L_Price;L_Money';
end;

//Desc: ����ɸѡ
procedure TfFrameSaleDetailQuery.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: ִ�в�ѯ
procedure TfFrameSaleDetailQuery.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'L_CusPY like ''%%%s%%'' Or L_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text,EditBill.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'b.L_Truck like ''%%%s%%''';
    FWhere := Format(FWhere, [EditTruck.Text]);
    InitFormData(FWhere);
  end;

  if Sender = EditBill then
  begin
    EditBill.Text := Trim(EditBill.Text);
    if EditBill.Text = '' then Exit;

    FWhere := 'b.L_ID like ''%%%s%%''';
    FWhere := Format(FWhere, [EditBill.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: ���Ӱ��ѯ
procedure TfFrameSaleDetailQuery.mniN1Click(Sender: TObject);
begin
  if ShowDateFilterForm(FTimeS, FTimeE, True) then
  try
    FJBWhere := '(L_OutFact>=''%s'' and L_OutFact <''%s'')';
    FJBWhere := Format(FJBWhere, [DateTime2Str(FTimeS), DateTime2Str(FTimeE),
                sFlag_BillPick, sFlag_BillPost]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

//Desc: �������
procedure TfFrameSaleDetailQuery.SummaryItemsGetText(
  Sender: TcxDataSummaryItem; const AValue: Variant; AIsFooter: Boolean;
  var AText: String);
var nStr: string;
begin
  nStr := TcxGridDBColumn(TcxGridTableSummaryItem(Sender).Column).DataBinding.FieldName;
  try
    if CompareText(nStr, 'L_Value') = 0 then FValue := SplitFloatValue(AText);
    if CompareText(nStr, 'L_Money') = 0 then FMoney := SplitFloatValue(AText);

    if CompareText(nStr, 'L_Price') = 0 then
    begin
      if FValue = 0 then
           AText := '����: 0.00Ԫ'
      else AText := Format('����: %.2fԪ', [Round(FMoney / FValue * cPrecision) / cPrecision]);
    end;
  except
    //ignor any error
  end;
end;

procedure TfFrameSaleDetailQuery.N1Click(Sender: TObject);
var nPID, nStr,nPreFix: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nPID := SQLQuery.FieldByName('L_ID').AsString;

    nPreFix := 'WY';
    nStr := 'Select B_Prefix From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      nPreFix := Fields[0].AsString;
    end;

    if Pos(nPreFix,SQLQuery.FieldByName('L_ZhiKa').AsString) > 0 then
    begin
      nStr := Format('�����[ %s ]��ERP����,�޷��ϴ�', [nPID]);
      ShowMsg(nStr, sHint);
      Exit;
    end;

    if SQLQuery.FieldByName('L_TruckEmpty').AsString = sFlag_Yes then
    begin
      nStr := Format('�����[ %s ]�Ѿ�����ճ�����,��ֹ�ϴ�', [nPID]);
      ShowMsg(nStr, sHint);
      Exit;
    end;

    nStr := Format('ȷ���ϴ������[ %s ]��?', [nPID]);
    if not QueryDlg(nStr, sHint) then Exit;

    if SQLQuery.FieldByName('L_BDAX').AsString = '1' then
    begin
      nStr := Format('�����[ %s ]�Ѿ��ϴ��ɹ�,��ֹ�ٴ��ϴ�', [nPID]);
      ShowMsg(nStr, sHint);
      Exit;
    end;

    if SQLQuery.FieldByName('L_OutFact').AsString = '' then
    begin
      nStr := Format('�����[ %s ]δ����,�޷��ϴ�', [nPID]);
      ShowMsg(nStr, sHint);
      Exit;
    end;

    if not SyncHhSaleDetail(nPID) then
    begin
      ShowMsg('�ϴ�ʧ��',sHint);
      Exit;
    end;

    ShowMsg('�ϴ��ɹ�',sHint);
    InitFormData('');
  end;
end;

procedure TfFrameSaleDetailQuery.N2Click(Sender: TObject);
var nPID, nStr,nPreFix: string;
    nList: TStrings;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nPID := SQLQuery.FieldByName('L_ID').AsString;

    nPreFix := 'WY';
    nStr := 'Select B_Prefix From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      nPreFix := Fields[0].AsString;
    end;

    if Pos(nPreFix,SQLQuery.FieldByName('L_ZhiKa').AsString) > 0 then
    begin
      nStr := Format('�����[ %s ]��ERP����,�޷��ϴ�', [nPID]);
      ShowMsg(nStr, sHint);
      Exit;
    end;

    nStr := Format('ȷ���ϴ������[ %s ]��?', [nPID]);
    if not QueryDlg(nStr, sHint) then Exit;

    if SQLQuery.FieldByName('L_OutFact').AsString = '' then
    begin
      nStr := Format('�����[ %s ]δ����,�޷��ϴ�', [nPID]);
      ShowMsg(nStr, sHint);
      Exit;
    end;

    nList := TStringList.Create;
    nList.Values['ID'] := SQLQuery.FieldByName('L_ID').AsString;
    nList.Values['Status'] := '1';

    nStr := PackerEncodeStr(nList.Text);
    try
      if not SyncHhSaleDetailWSDL(nStr) then
      begin
        ShowMsg('������ϴ�ʧ��',sHint);
        Exit;
      end;
    finally
      nList.Free;
    end;

    ShowMsg('�ϴ��ɹ�',sHint);
    InitFormData('');
  end;
end;

procedure TfFrameSaleDetailQuery.N3Click(Sender: TObject);
var nLID, nStr,nPreFix,nHint: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nLID := SQLQuery.FieldByName('L_ID').AsString;

    nPreFix := 'WY';
    nStr := 'Select B_Prefix From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      nPreFix := Fields[0].AsString;
    end;

    if Pos(nPreFix,SQLQuery.FieldByName('L_ZhiKa').AsString) > 0 then
    begin
      nStr := Format('�����[ %s ]��ERP����,�޷�����', [nLID]);
      ShowMsg(nStr, sHint);
      Exit;
    end;

    if not PoundVerifyHhSalePlanWSDL(nLID,
           SQLQuery.FieldByName('L_Value').AsFloat,
           SQLQuery.FieldByName('L_OutFact').AsString, nHint) then
    begin
      ShowMsg('����ʧ��',sHint);
    end;
    InitFormData('');
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameSaleDetailQuery, TfFrameSaleDetailQuery.FrameID);
end.

