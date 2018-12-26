{*******************************************************************************
  ����: juner11212436@163.com 2018-04-24
  ����: ������ʱʱ������
*******************************************************************************}
unit UFormTruckOutOverTime;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, StdCtrls, ExtCtrls, dxLayoutControl, cxControls,
  cxContainer, cxEdit, cxTextEdit, UFormBase, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters, cxMaskEdit,
  cxDropDownEdit, cxLabel;

type
  TfFormTruckOutOverTime = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    BtnOK: TButton;
    dxLayoutControl1Item4: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item5: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayoutControl1Item2: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, USysPopedom;

//------------------------------------------------------------------------------
class function TfFormTruckOutOverTime.CreateForm;
var nStr: string;
begin
  Result := nil;

  with TfFormTruckOutOverTime.Create(Application) do
  begin
    nStr := 'select D_Value from %s where D_Memo=''%s'' ';
    nStr := Format(nStr, [sTable_SysDict, sFlag_TimeOutValue]);

    with FDM.QuerySQL(nStr) do
    if RecordCount > 0 then
    begin
      EditValue.Text :=Fields[0].AsString;
    end;
    BtnOK.Enabled := gPopedomManager.HasPopedom(nPopedom, sPopedom_Edit);
    ShowModal;
    Free;
  end;
end;

class function TfFormTruckOutOverTime.FormID: integer;
begin
  Result := cFI_FormOutOverTime;
end;

//------------------------------------------------------------------------------
//Desc: ����
procedure TfFormTruckOutOverTime.BtnOKClick(Sender: TObject);
var nStr: string;
begin
  if not IsNumber(EditValue.Text,True) then
  begin
    EditValue.SetFocus;
    nStr := '��������Ч��ֵ';
    ShowMsg(nStr,sHint);
    Exit;
  end
  else
  begin
    if StrToFloat(EditValue.Text) <= 0 then
    begin
      EditValue.SetFocus;
      nStr := '��ʱʱ�䲻��С�ڻ����0';
      ShowMsg(nStr,sHint);
      Exit;
    end;
  end;

  nStr:='Update Sys_Dict set D_Value=''%s'' where D_Memo=''%s'' ';
  nStr := Format(nStr, [EditValue.Text, sFlag_TimeOutValue]);

  if FDM.ExecuteSQL(nStr, False) > 0 then
  begin
    ModalResult := mrOK;
    ShowMsg('���óɹ�', sHint);
  end else ShowMsg('����δ֪����', '����ʧ��');
end;

initialization
  gControlManager.RegCtrl(TfFormTruckOutOverTime, TfFormTruckOutOverTime.FormID);
end.
