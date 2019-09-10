{*******************************************************************************
  ����: dmzn@163.com 2012-03-26
  ����: ������ϸ
*******************************************************************************}
unit UFrameQueryWXSynInfo;

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
  TfFrameQueryWXSynInfo = class(TfFrameNormal)
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
    chkAll: TcxCheckBox;
    dxLayout1Item9: TdxLayoutItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure mniN1Click(Sender: TObject);
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
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UFormDateFilter, USysPopedom, USysBusiness,
  UBusinessConst, USysConst, USysDB, UDataModule, UBusinessPacker;

class function TfFrameQueryWXSynInfo.FrameID: integer;
begin
  Result := cFI_FrameQueryWXSynInfo;
end;

procedure TfFrameQueryWXSynInfo.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  FJBWhere := '';
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameQueryWXSynInfo.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfFrameQueryWXSynInfo.OnLoadGridConfig(const nIni: TIniFile);
begin

  inherited;
end;

function TfFrameQueryWXSynInfo.InitFormDataSQL(const nWhere: string): string;
begin
  FEnableBackDB := True;
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := ' Select * From $Sync b ';
  //ͬ����¼
  Result := MacroValue(Result, [MI('$Sync', sTable_HHJYSync)]);
end;

//Desc: �����ֶ�
function TfFrameQueryWXSynInfo.FilterColumnField: string;
begin
  if gPopedomManager.HasPopedom(PopedomItem, sPopedom_ViewPrice) then
       Result := ''
  else Result := 'L_Price;L_Money';
end;

//Desc: ����ɸѡ
procedure TfFrameQueryWXSynInfo.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: ִ�в�ѯ
procedure TfFrameQueryWXSynInfo.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  //
end;

//Desc: ERPͬ���ϴ�
procedure TfFrameQueryWXSynInfo.mniN1Click(Sender: TObject);
var nStr: string;
begin
  inherited;

  nStr := 'ȷ��ERP�ϴ�ʧ�ܼ�¼�����ϴ���?';
  if not QueryDlg(nStr, sHint) then Exit;

  nStr := ' Update %s Set H_SyncNum = 0 ' +
          ' Where H_Deleted = ''%s'' ';
  nStr := Format(nStr, [sTable_HHJYSync, sFlag_No]);
  FDM.ExecuteSQL(nStr);
  ShowMsg('ERP�ϴ�ʧ�ܼ�¼�����ϴ����', sHint);
end;

procedure TfFrameQueryWXSynInfo.N2Click(Sender: TObject);
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

procedure TfFrameQueryWXSynInfo.N3Click(Sender: TObject);
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
  gControlManager.RegCtrl(TfFrameQueryWXSynInfo, TfFrameQueryWXSynInfo.FrameID);
end.

