{*******************************************************************************
  ����: juner11212436@163.com 2018-03-18
  ����: ��ʱ���۶���
*******************************************************************************}
unit UFrameSaleOrderOther;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UDataModule, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, ADODB, cxContainer, cxLabel,
  dxLayoutControl, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxTextEdit, cxMaskEdit, cxButtonEdit, UFrameNormal,
  Menus, UBitmapPanel, cxSplitter, cxLookAndFeels, cxLookAndFeelPainters;

type
  TfFrameSaleOrderOther = class(TfFrameNormal)
    EditCusName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditID: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  protected
    FStart,FEnd: TDate;
    //ʱ������
    FPreFix: string;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //��ʼ������
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, USysFun, USysConst, USysGrid, USysDB, UMgrControl,
  UFormDateFilter, UFormBase;

class function TfFrameSaleOrderOther.FrameID: integer;
begin
  Result := cFI_FrameSaleOrderOther;
end;

procedure TfFrameSaleOrderOther.OnCreateFrame;
var nStr: string;
begin
  inherited;
  FPreFix := 'WY';
  nStr := 'Select B_Prefix From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_SaleOrderOther]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    FPreFix := Fields[0].AsString;
  end;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameSaleOrderOther.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameSaleOrderOther.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select * From $SO ';

  if nWhere = '' then
       Result := Result + 'Where (O_Create>=''$Start'' and O_Create<''$End'')'
  else Result := Result + 'Where (' + nWhere + ')';

  Result := Result + ' And O_Order like ''%%' + FPreFix + '%%''' ;

  Result := MacroValue(Result, [MI('$SO', sTable_SalesOrder),
            MI('$Start', DateTime2Str(FStart)),
            MI('$End', DateTime2Str(FEnd + 1))]);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: ���
procedure TfFrameSaleOrderOther.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormSaleOrderOther, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: �༭
procedure TfFrameSaleOrderOther.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('R_ID').AsString;
  CreateBaseFormItem(cFI_FormSaleOrderOther, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: ɾ��
procedure TfFrameSaleOrderOther.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  if SQLQuery.FieldByName('O_Freeze').AsFloat > 0 then
  begin
    ShowMsg('�ö�������δ���������,�޷�ɾ��', '�ѿ���'); Exit;
  end;

  nStr := SQLQuery.FieldByName('O_Order').AsString;
  if not QueryDlg('ȷ��Ҫɾ������[ ' + nStr + ' ]��', sAsk) then Exit;

  nStr := SQLQuery.FieldByName('R_ID').AsString;
  nSQL := 'Delete From %s Where R_ID=%s';
  nSQL := Format(nSQL, [sTable_SalesOrder, nStr]);

  FDM.ExecuteSQL(nSQL);
  InitFormData(FWhere);
  ShowMsg('�����ѳɹ�ɾ��', sHint);
end;

//Desc: ����ɸѡ
procedure TfFrameSaleOrderOther.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

//Desc: ��ѯ
procedure TfFrameSaleOrderOther.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'O_Order like ''%%' + EditID.Text + '%%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCusName then
  begin
    EditCusName.Text := Trim(EditCusName.Text);
    if EditCusName.Text = '' then Exit;

    FWhere := 'O_CusName like ''%%' + EditCusName.Text + '%%''';
    InitFormData(FWhere);
  end else
end;

initialization
  gControlManager.RegCtrl(TfFrameSaleOrderOther, TfFrameSaleOrderOther.FrameID);
end.
