{*******************************************************************************
  ����: juner11212436@163.com 2018/03/15
  ����: ��������(��ʱ����)
*******************************************************************************}
unit UFormPoundKwOther;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxButtonEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxDropDownEdit, cxLabel,
  dxLayoutcxEditAdapters, cxCheckBox, cxCalendar, ComCtrls, cxListView;

type
  TfFormPoundKwOther = class(TfFormNormal)
    EditMate: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditProvider: TcxTextEdit;
    dxlytmLayout1Item3: TdxLayoutItem;
    editMemo: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    dxLayout1Item3: TdxLayoutItem;
    ListQuery: TcxListView;
    EditPValue: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditMValue: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    chkReSync: TcxCheckBox;
    dxLayout1Item8: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item11: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditRec: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FCardData, FListA: TStrings;

    procedure InitFormData;
    //��ʼ������
    procedure WriteOptionLog(const LID: string; nIdx: Integer);
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
  UDataModule, USysBusiness, USysDB, USysGrid, USysConst,DateUtils;


class function TfFormPoundKwOther.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nStr, nModifyStr: string;
    nP: PFormCommandParam;
    nList: TStrings;
begin
  Result := nil;
  if GetSysValidDate < 1 then Exit;

  if Assigned(nParam) then
       nP := nParam
  else Exit;

  nModifyStr := nP.FParamA;

  with TfFormPoundKwOther.Create(Application) do
  try
    Caption := '��������(��ʱ����)';

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

class function TfFormPoundKwOther.FormID: integer;
begin
  Result := cFI_FormPoundKwOther;
end;

procedure TfFormPoundKwOther.FormCreate(Sender: TObject);
begin
  FListA    := TStringList.Create;
  FCardData := TStringList.Create;
  AdjustCtrlData(Self);
  LoadFormConfig(Self);
  dxGroup1.AlignHorz := ahClient;
end;

procedure TfFormPoundKwOther.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);

  FListA.Free;
  FCardData.Free;
end;

//------------------------------------------------------------------------------
procedure TfFormPoundKwOther.InitFormData;
var nStr: string;
    nIdx: Integer;
begin
  for nIdx := 0 to FListA.Count - 1 do
  begin
    nStr := 'select * From %s a, %s b'+
    ' where a.R_ID=b.P_OrderBak and b.P_ID = ''%s'' ';

    nStr := Format(nStr,[sTable_CardOther,sTable_PoundLog,FListA.Strings[nIdx]]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
        Continue;

      with ListQuery.Items.Add do
      begin
        Caption := FieldByName('P_ID').AsString;
        SubItems.Add(FieldByName('P_Truck').AsString);
        SubItems.Add(FieldByName('P_MName').AsString);
        SubItems.Add(FieldByName('P_CusName').AsString);
        SubItems.Add(FieldByName('P_PValue').AsString);
        SubItems.Add(FieldByName('P_MValue').AsString);
        ImageIndex := cItemIconIndex;
      end;
      EditProvider.Text := FieldByName('P_CusName').AsString;
      EditMate.Text := FieldByName('P_MName').AsString;
      EditPValue.Text := FieldByName('P_PValue').AsString;
      EditMValue.Text := FieldByName('P_MValue').AsString;
      EditTruck.Text := FieldByName('P_Truck').AsString;
      EditRec.Text := FieldByName('O_RevName').AsString;
    end;
  end;
  if ListQuery.Items.Count>0 then
    ListQuery.ItemIndex := 0;
  BtnOK.Enabled := ListQuery.Items.Count>0;
end;

//Desc: ����
procedure TfFormPoundKwOther.BtnOKClick(Sender: TObject);
var nStr,nSQL,nID: string;
    nIdx: Integer;
begin
  if not QueryDlg('ȷ��Ҫ�޸���������������?', sHint) then Exit;

  if not IsNumber(EditPValue.Text,True) then
  begin
    EditPValue.SetFocus;
    nStr := '��������ЧƤ��';
    ShowMsg(nStr,sHint);
    Exit;
  end;

  if not IsNumber(EditMValue.Text,True) then
  begin
    EditMValue.SetFocus;
    nStr := '��������Чë��';
    ShowMsg(nStr,sHint);
    Exit;
  end;

  if StrToFloat(EditMValue.Text) <= StrToFloat(EditPValue.Text) then
  begin
    EditMValue.SetFocus;
    nStr := 'ë�ز���С��Ƥ��';
    ShowMsg(nStr,sHint);
    Exit;
  end;

  for nIdx := 0 to FListA.Count - 1 do
  begin
    nStr := 'select * From %s a, %s b'+
    ' where a.R_ID=b.P_OrderBak and b.P_ID = ''%s'' ';

    nStr := Format(nStr,[sTable_CardOther,sTable_PoundLog,FListA.Strings[nIdx]]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        ShowMsg('δ��ѯ���������',sHint);
        Exit;
      end;;

      nID := FieldByName('P_OrderBak').AsString;
    end;

    nSQL := 'Update %s Set O_Truck=''%s'',O_RevName=''%s'' Where R_ID=''%s''';
    nSQL := Format(nSQL, [sTable_CardOther, Trim(EditTruck.Text),
                                            Trim(EditRec.Text),
                                        nID]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Update %s Set P_PValue=''%s'',P_MValue=''%s'',P_CusName=''%s'',P_MName=''%s'','+
            ' P_KwMan=''%s'',P_KwDate=%s,P_Truck=''%s'' Where P_ID=''%s''';
    nSQL := Format(nSQL, [sTable_PoundLog,EditPValue.Text,
                                          EditMValue.Text,
                                          EditProvider.Text,
                                          EditMate.Text,
                                          gSysParam.FUserID,
                                          sField_SQLServer_Now,
                                          Trim(EditTruck.Text),
                                          FListA.Strings[nIdx]]);
    FDM.ExecuteSQL(nSQL);

    if chkReSync.Checked then
    begin
      nSQL := 'Update %s Set P_BDAX = 0 Where P_ID=''%s''';
      nSQL := Format(nSQL, [sTable_PoundLog,FListA.Strings[nIdx]]);
      FDM.ExecuteSQL(nSQL);
    end;
    WriteOptionLog(FListA.Strings[nIdx], nIdx);
  end;

  ModalResult := mrOK;
  if chkReSync.Checked then
    nStr := '�������,�������ϴ�'
  else
    nStr := '�������';
  ShowMsg(nStr, sHint);
end;

procedure TfFormPoundKwOther.WriteOptionLog(const LID: string;nIdx: Integer);
var nEvent: string;
begin
  nEvent := '';

  try
    with ListQuery.Items[nIdx] do
    begin
      if EditProvider.Text <> SubItems[2] then
      begin
        nEvent := nEvent + '������λ�� [ %s ] --> [ %s ];';
        nEvent := Format(nEvent, [SubItems[2], EditProvider.Text]);
      end;
      if SubItems[1] <> EditMate.Text then
      begin
        nEvent := nEvent + '������ [ %s ] --> [ %s ];';
        nEvent := Format(nEvent, [SubItems[1], EditMate.Text]);
      end;
      if SubItems[0] <> EditTruck.Text then
      begin
        nEvent := nEvent + '���ƺ��� [ %s ] --> [ %s ];';
        nEvent := Format(nEvent, [SubItems[0], EditTruck.Text]);
      end;
      if SubItems[3] <> EditPValue.Text then
      begin
        nEvent := nEvent + 'Ƥ���� [ %s ] --> [ %s ];';
        nEvent := Format(nEvent, [SubItems[3], EditPValue.Text]);
      end;
      if SubItems[4] <> EditMValue.Text then
      begin
        nEvent := nEvent + 'ë���� [ %s ] --> [ %s ];';
        nEvent := Format(nEvent, [SubItems[4], EditMValue.Text]);
      end;

      if nEvent <> '' then
      begin
        nEvent := '���� [ %s ] �����ѱ��޸�:' + nEvent;
        nEvent := Format(nEvent, [LID]);
      end;
    end;

    if nEvent <> '' then
    begin
      FDM.WriteSysLog(sFlag_BillItem, LID, nEvent);
    end;
  except
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormPoundKwOther, TfFormPoundKwOther.FormID);
end.
