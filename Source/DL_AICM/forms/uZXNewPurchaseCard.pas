{*******************************************************************************
  ����: juner11212436@163.com 2017-12-28
  ����: �����쿨����--������
*******************************************************************************}
unit uZXNewPurchaseCard;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, Menus, StdCtrls, cxButtons, cxGroupBox,
  cxRadioGroup, cxTextEdit, cxCheckBox, ExtCtrls, dxLayoutcxEditAdapters,
  dxLayoutControl, cxDropDownEdit, cxMaskEdit, cxButtonEdit,
  USysConst, cxListBox, ComCtrls,Contnrs,UFormCtrl;

type
  TfFormNewPurchaseCard = class(TForm)
    editWebOrderNo: TcxTextEdit;
    labelIdCard: TcxLabel;
    btnQuery: TcxButton;
    PanelTop: TPanel;
    PanelBody: TPanel;
    dxLayout1: TdxLayoutControl;
    BtnOK: TButton;
    BtnExit: TButton;
    EditValue: TcxTextEdit;
    EditProv: TcxTextEdit;
    EditID: TcxTextEdit;
    EditProduct: TcxTextEdit;
    EditTruck: TcxButtonEdit;
    dxLayoutGroup1: TdxLayoutGroup;
    dxGroup1: TdxLayoutGroup;
    dxGroupLayout1Group2: TdxLayoutGroup;
    dxLayout1Item5: TdxLayoutItem;
    dxLayout1Item9: TdxLayoutItem;
    dxlytmLayout1Item3: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    dxlytmLayout1Item12: TdxLayoutItem;
    dxLayout1Item8: TdxLayoutItem;
    dxLayoutGroup3: TdxLayoutGroup;
    dxLayoutItem1: TdxLayoutItem;
    dxLayout1Item2: TdxLayoutItem;
    pnlMiddle: TPanel;
    cxLabel1: TcxLabel;
    lvOrders: TListView;
    Label1: TLabel;
    btnClear: TcxButton;
    TimerAutoClose: TTimer;
    EditYear: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditModel: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Group1: TdxLayoutGroup;
    EditKD: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Item6: TdxLayoutItem;
    chkIfPrint: TcxCheckBox;
    procedure BtnExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnClearClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TimerAutoCloseTimer(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure editWebOrderNoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FAutoClose:Integer; //�����Զ��رյ���ʱ�����ӣ�
    FWebOrderIndex:Integer; //�̳Ƕ�������
    FWebOrderItems:array of stMallPurchaseItem; //�̳Ƕ�������
    FMaxQuantity:Double; //��ͬʣ����
    Fbegin:TDateTime;
    FProID: string;
    procedure InitListView;
    procedure SetControlsReadOnly;
    procedure Writelog(nMsg:string);
    function DownloadOrder(const nCard:string):Boolean;
    procedure AddListViewItem(var nWebOrderItem:stMallPurchaseItem);
    procedure LoadSingleOrder;
    function IsRepeatCard(const nWebOrderItem:string):Boolean;
    function CheckOrderValidate(var nWebOrderItem:stMallPurchaseItem):Boolean;
    function SaveBillProxy:Boolean;
    function SaveWebOrderMatch(const nBillID,nWebOrderID,nBillType:string):Boolean;
    function VerifyCtrl(Sender: TObject; var nHint: string): Boolean;
  public
    { Public declarations }
    procedure SetControlsClear;
  end;

var
  fFormNewPurchaseCard: TfFormNewPurchaseCard;

implementation
uses
  ULibFun,UBusinessPacker,USysLoger,UBusinessConst,UFormMain,USysBusiness,USysDB,
  UAdjustForm,UFormBase,UDataReport,UDataModule,NativeXml,UMgrTTCEDispenser,UFormWait,
  DateUtils;
{$R *.dfm}

{ TfFormNewPurchaseCard }

procedure TfFormNewPurchaseCard.SetControlsClear;
var
  i:Integer;
  nComp:TComponent;
begin
  editWebOrderNo.Clear;
  for i := 0 to dxLayout1.ComponentCount-1 do
  begin
    nComp := dxLayout1.Components[i];
    if nComp is TcxTextEdit then
    begin
      TcxTextEdit(nComp).Clear;
    end;
  end;
end;

procedure TfFormNewPurchaseCard.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormNewPurchaseCard.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action:=  caFree;
  fFormNewPurchaseCard := nil;
end;

procedure TfFormNewPurchaseCard.btnClearClick(Sender: TObject);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  editWebOrderNo.Clear;
  ActiveControl := editWebOrderNo;
end;

procedure TfFormNewPurchaseCard.FormShow(Sender: TObject);
begin
  SetControlsReadOnly;
  btnOK.Enabled := False;
  EditTruck.Properties.Buttons[0].Visible := False;

  FAutoClose := gSysParam.FAutoClose_Mintue;
  TimerAutoClose.Interval := 60*1000;
  TimerAutoClose.Enabled := True;
end;

procedure TfFormNewPurchaseCard.TimerAutoCloseTimer(Sender: TObject);
begin
  if FAutoClose=0 then
  begin
    TimerAutoClose.Enabled := False;
    Close;
  end;
  Dec(FAutoClose);
end;

procedure TfFormNewPurchaseCard.btnQueryClick(Sender: TObject);
var
  nCardNo,nStr:string;
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  btnQuery.Enabled := False;
  try
    nCardNo := Trim(editWebOrderNo.Text);
    if nCardNo='' then
    begin
      nStr := '���������ɨ�������';
      ShowMsg(nStr,sHint);
      Writelog(nStr);
      Exit;
    end;
    lvOrders.Items.Clear;
    if not DownloadOrder(nCardNo) then Exit;
    btnOK.Enabled := True;
  finally
    btnQuery.Enabled := True;
  end;
end;

procedure TfFormNewPurchaseCard.BtnOKClick(Sender: TObject);
begin
  BtnOK.Enabled := False;
  try
    if not SaveBillProxy then
    begin
      BtnOK.Enabled := True;
      Exit;
    end;
    Close;
  except
  end;
end;

procedure TfFormNewPurchaseCard.InitListView;
var
  col:TListColumn;
begin
  lvOrders.ViewStyle := vsReport;
  col := lvOrders.Columns.Add;
  col.Caption := '�̳ǻ������';
  col.Width := 270;

  col := lvOrders.Columns.Add;
  col.Caption := '��ͬ���';
  col.Width := 150;

  col := lvOrders.Columns.Add;
  col.Caption := '��������';
  col.Width := 200;

  col := lvOrders.Columns.Add;
  col.Caption := '��������';
  col.Width := 200;

  col := lvOrders.Columns.Add;
  col.Caption := '�������';
  col.Width := 150;
end;

procedure TfFormNewPurchaseCard.SetControlsReadOnly;
var
  i:Integer;
  nComp:TComponent;
begin
  for i := 0 to dxLayout1.ComponentCount-1 do
  begin
    nComp := dxLayout1.Components[i];
    if nComp is TcxTextEdit then
    begin
      TcxTextEdit(nComp).Properties.ReadOnly := True;
    end;
  end;
end;

procedure TfFormNewPurchaseCard.FormCreate(Sender: TObject);
begin
  if not Assigned(FDR) then
  begin
    FDR := TFDR.Create(Application);
  end;
  editWebOrderNo.Properties.MaxLength := gSysParam.FWebOrderLength;
  InitListView;
  gSysParam.FUserID := 'AICM';
end;

procedure TfFormNewPurchaseCard.Writelog(nMsg: string);
var
  nStr:string;
begin
  nStr := 'weborder[%s]contractcode[%s]provname[%s]productname[%s]:';
  nStr := Format(nStr,[editWebOrderNo.Text,EditID.Text,EditProv.Text,EditProduct.Text]);
  gSysLoger.AddLog(nStr+nMsg);
end;

function TfFormNewPurchaseCard.DownloadOrder(const nCard: string): Boolean;
var
  nXmlStr,nData:string;
  nListA,nListB:TStringList;
  i:Integer;
  nWebOrderCount:Integer;
begin
  Result := False;
  FWebOrderIndex := 0;
  nXmlStr := PackerEncodeStr(nCard);

  FBegin := now;
  nData := get_shopPurchaseByno(nXmlStr);
  if nData='' then
  begin
    ShowMsg('δ��ѯ�������̳ǻ�����ϸ��Ϣ������������Ƿ���ȷ',sHint);
    Writelog('δ��ѯ�������̳ǻ�����ϸ��Ϣ������������Ƿ���ȷ');
    Exit;
  end;

  Writelog('TfFormNewPurchaseCard.DownloadOrder(nCard='''+nCard+''') ��ѯ�̳Ƕ���-��ʱ��'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
  //�������Ƕ�����Ϣ
  Writelog('get_shopPurchaseByno res:'+nData);
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Text := nData;

    nWebOrderCount := nListA.Count;
    SetLength(FWebOrderItems,nWebOrderCount);
    for i := 0 to nWebOrderCount-1 do
    begin
      nListB.Text := PackerDecodeStr(nListA.Strings[i]);
      FWebOrderItems[i].FOrder_id := nListB.Values['ordernumber'];
      FWebOrderItems[i].Fpurchasecontract_no := nListB.Values['fac_order_no'];
      FWebOrderItems[i].FgoodsID := nListB.Values['goodsID'];
      FWebOrderItems[i].FGoodsname := nListB.Values['goodsname'];
      FWebOrderItems[i].FData := nListB.Values['data'];
      FWebOrderItems[i].Ftracknumber := nListB.Values['tracknumber'];
      AddListViewItem(FWebOrderItems[i]);
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;
  LoadSingleOrder;
end;

procedure TfFormNewPurchaseCard.AddListViewItem(
  var nWebOrderItem: stMallPurchaseItem);
var
  nListItem:TListItem;
begin
  nListItem := lvOrders.Items.Add;
  nlistitem.Caption := nWebOrderItem.FOrder_id;

  nlistitem.SubItems.Add(nWebOrderItem.Fpurchasecontract_no);
  nlistitem.SubItems.Add(nWebOrderItem.FGoodsname);
  nlistitem.SubItems.Add(nWebOrderItem.Ftracknumber);
  nlistitem.SubItems.Add(nWebOrderItem.FData);
end;

procedure TfFormNewPurchaseCard.LoadSingleOrder;
var
  nOrderItem:stMallPurchaseItem;
  nRepeat:Boolean;
  nWebOrderID,nModel,nYear,nKD,nProName,nStockName:string;
  nMsg:string;
begin
  nOrderItem := FWebOrderItems[FWebOrderIndex];
  nWebOrderID := nOrderItem.FOrder_id;
  FBegin := now;
  nRepeat := IsRepeatCard(nWebOrderID);

  if nRepeat then
  begin
    nMsg := '�˻����ѳɹ��쿨�������ظ�����';
    ShowMsg(nMsg,sHint);
    Writelog(nMsg);
    Exit;
  end;

  //��������Ϣ
  //������Ϣ
  EditID.Text := nOrderItem.Fpurchasecontract_no;
  EditProv.Text := nOrderItem.FProvName;
  EditProduct.Text := nOrderItem.FGoodsname;
  //������Ϣ
  EditTruck.Text := nOrderItem.Ftracknumber;
  EditValue.Text := nOrderItem.FData;

  FWebOrderItems[FWebOrderIndex] := nOrderItem;
  if not GetOrderOtherInfo(EditID.Text,nModel,nYear,nKD,FProID,nProName,nStockName) then
  begin
    ShowMsg('��ѯ����������Ϣʧ��',sHint);
    nRepeat := True;
  end;

  if nYear = '' then
  begin
    ShowMsg('��ѯ����������Ϣʧ��',sHint);
    nRepeat := True;
  end;

  if nStockName <> '' then
  begin
    EditProduct.Text := nStockName;
  end;

  EditModel.Text := nModel;
  EditYear.Text  := nYear;
  EditKD.Text    := nKD;
  EditProv.Text  := nProName;

  BtnOK.Enabled := not nRepeat;
end;

function TfFormNewPurchaseCard.IsRepeatCard(
  const nWebOrderItem: string): Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := 'select * from %s where WOM_WebOrderID=''%s'' ';
  nStr := Format(nStr,[sTable_WebOrderMatch,nWebOrderItem]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      Result := True;
    end;
  end;
end;

function TfFormNewPurchaseCard.CheckOrderValidate(var nWebOrderItem: stMallPurchaseItem): Boolean;
var
  nStr:string;
  nwebOrderValue:Double;
  nMsg:string;
begin
  Result := False;

  //��ѯ�ɹ����뵥
  nStr := 'select b_proid as provider_code,b_proname as provider_name,b_stockno as con_materiel_Code,b_restvalue as con_remain_quantity from %s where b_id=''%s''';
  nStr := Format(nStr,[sTable_OrderBase,nWebOrderItem.Fpurchasecontract_no]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount<=0 then
    begin
      nMsg := '�ɹ���ͬ��������ɹ���ͬ�ѱ�ɾ��[%s]��';
      nMsg := Format(nMsg,[nWebOrderItem.Fpurchasecontract_no]);
      ShowMsg(nMsg,sError);
      Writelog(nMsg);
      Exit;
    end;

    nWebOrderItem.FProvID := FieldByName('provider_code').AsString;
    nWebOrderItem.FProvName := FieldByName('provider_name').AsString;

    if nWebOrderItem.FGoodsID<>FieldByName('con_materiel_Code').AsString then
    begin
      nMsg := '�̳ǻ�����ԭ����[%s]����';
      nMsg := Format(nMsg,[nWebOrderItem.FGoodsname]);
      ShowMsg(nMsg,sError);
      Writelog(nMsg);
      Exit;
    end;

    nwebOrderValue := StrToFloatDef(nWebOrderItem.FData,0);
    FMaxQuantity := FieldByName('con_remain_quantity').AsFloat;

  //    if (nwebOrderValue<=0.00001) then
  //    begin
  //      nMsg := '���������������ʽ����';
  //      ShowMsg(nMsg,sError);
  //      Writelog(nMsg);
  //      Exit;
  //    end;

    if nwebOrderValue-FMaxQuantity>0.00001 then
    begin
      nMsg := '�̳ǻ���������������������������Ϊ[%f]��';
      nMsg := Format(nMsg,[FMaxQuantity]);
      ShowMsg(nMsg,sError);
      Writelog(nMsg);
      Exit;
    end;
  end;
  Result := True;
end;

function TfFormNewPurchaseCard.SaveBillProxy: Boolean;
var
  nHint, nMsg, nDate, nData, nYear:string;
  nWebOrderID:string;
  nList: TStrings;
  nOrderItem:stMallPurchaseItem;
  nOrder:string;
  nCard:string;
  nidx:Integer;
  i:Integer;
  nRet:Boolean;
  nDateNow: TDateTime;
begin
  Result := False;
  nOrderItem := FWebOrderItems[FWebOrderIndex];
  nWebOrderID := nOrderItem.FOrder_id;

  if EditID.Text='' then
  begin
    ShowMsg('δ��ѯ���ϻ���',sHint);
    Writelog('δ��ѯ���ϻ���');
    Exit;
  end;

  if Trim(EditYear.Text)='' then
  begin
    ShowMsg('�����쳣,���뵥�����ѹ���',sHint);
    Writelog('�����쳣,���뵥�����ѹ���');
    Exit;
  end
  else
  begin
    nYear := Trim(EditYear.Text);
    try
      nDateNow := FDM.ServerNow;
      nDate := FormatDateTime('YYYY-MM-',nDateNow) + '26';
      if nDateNow > StrToDate(nDate) then
       nDate := FormatDateTime('YYYY-MM',IncMonth(nDateNow))
      else
       nDate := FormatDateTime('YYYY-MM',nDateNow);
    except
       nDate := FormatDateTime('YYYY-MM',nDateNow);
    end;

    nData := '��ǰ��������[ %s ]�ɹ�����[ %s ]�����ƻ�����[ %s ]';
    nData := Format(nData,[nDate, EditID.Text, nYear]);
    WriteLog(nData);
    
    if nYear <> nDate then
    begin
      nData := '��ǰ��������[ %s ]��ɹ�����[ %s ]�����ƻ�����[ %s ]��һ��,�ɹ�����������ʧЧ';
      nData := Format(nData,[nDate, EditID.Text, nYear]);
      Writelog(nData);
      ShowMsg(nData, sHint);
      Exit;
    end;
  end;

  if not VerifyCtrl(EditTruck,nHint) then
  begin
    ShowMsg(nHint,sHint);
    Writelog(nHint);
    Exit;
  end;

  if not VerifyCtrl(EditValue,nHint) then
  begin
    ShowMsg(nHint,sHint);
    Writelog(nHint);
    Exit;
  end;

  if IFHasOrder(EditTruck.Text, nHint) then
  begin
    ShowMsg('��������δ��ɵĲɹ���[' + nHint + '],�޷�����,����ϵ����Ա',sHint);
    Exit;
  end;

  nCard := '';

  for nIdx:=0 to 3 do
  begin
    nCard := gDispenserManager.GetCardNo(gSysParam.FTTCEK720ID, nHint, False);
    if nCard <> '' then
      Break;
    Sleep(500);
  end;
  //�������ζ���,�ɹ����˳���

  if nCard = '' then
  begin
    nMsg := '�����쳣,��鿴�Ƿ��п�.';
    ShowMsg(nMsg, sWarn);
    Exit;
  end;

  WriteLog('��ȡ����Ƭ: ' + nCard);
  //������Ƭ
  if not IsCardValid(nCard) then
  begin
    gDispenserManager.RecoveryCard(gSysParam.FTTCEK720ID, nHint);
    nMsg := '����' + nCard + '�Ƿ�,������,���Ժ�����ȡ��';
    WriteLog(nMsg);
    ShowMsg(nMsg, sWarn);
    Exit;
  end;

  {$IFDEF OrderControl}
  if IsPurOrderHasControl(FProID, nOrderItem.FGoodsID) then
  begin
    nMsg := '��Ӧ��' + EditProv.Text + '����' + Trim(EditProduct.Text)
            + '������ȡ��, ����ϵ����Ա';
    ShowMsg(nMsg, sWarn);
    Exit;
  end;
  {$ENDIF}

  nList := TStringList.Create;
  try
    nList.Values['SQID'] := EditID.Text;
    nList.Values['Area'] := '';
    nList.Values['Truck'] := Trim(EditTruck.Text);
    nList.Values['Project'] := EditID.Text;
    nList.Values['CardType'] := 'L';

    nList.Values['ProviderID'] := FProID;
    nList.Values['ProviderName'] := EditProv.Text;
    nList.Values['StockNO'] := nOrderItem.FGoodsID;
    nList.Values['StockName'] := Trim(EditProduct.Text);
    nList.Values['Value'] := EditValue.Text;
    nList.Values['Model'] := EditModel.Text;
    nList.Values['KD'] := EditKD.Text;
    nList.Values['Year'] := EditYear.Text;
    nList.Values['NeiDao'] := sFlag_No;
    nList.Values['OppositeValue'] := '0.00';
    nList.Values['expiretime'] := '0';
    if chkIfPrint.Checked then
      nList.Values['PrintBD'] := sFlag_Yes
    else
      nList.Values['PrintBD'] := sFlag_No;
    nList.Values['WebOrderID'] := nWebOrderID;

    FBegin := Now;
    nOrder := SaveOrder(PackerEncodeStr(nList.Text));
    if nOrder='' then
    begin
      nHint := '����ɹ���ʧ��';
      ShowMsg(nHint,sError);
      Writelog(nHint);
      Exit;
    end;

    nRet := SaveOrderCard(nOrder, nCard);

    writelog('TfFormNewPurchaseCard.SaveBillProxy ����ɹ���-��ʱ��'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');

    FBegin := Now;
    SaveWebOrderMatch(nOrder,nWebOrderID,sFlag_Provide);
    writelog('TfFormNewPurchaseCard.SaveBillProxy �����̳Ƕ�����-��ʱ��'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
  finally
    nList.Free;
  end;

  if not nRet then
  begin
    nMsg := '����ſ�ʧ��,������.';
    ShowMsg(nMsg, sHint);
    Exit;
  end;

  nRet := gDispenserManager.SendCardOut(gSysParam.FTTCEK720ID, nHint);
  //����

  if nRet then
  begin
    nMsg := '�ɹ���[ %s ]�����ɹ�,����[ %s ],���պ����Ŀ�Ƭ';
    nMsg := Format(nMsg, [nOrder, nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end
  else begin
    gDispenserManager.RecoveryCard(gSysParam.FTTCEK720ID, nHint);

    nMsg := '����[ %s ]��������ʧ��,�뵽��Ʊ�������¹���.';
    nMsg := Format(nMsg, [nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end;
  Result := True;
end;

function TfFormNewPurchaseCard.SaveWebOrderMatch(const nBillID,
  nWebOrderID,nBillType: string): Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := MakeSQLByStr([
  SF('WOM_WebOrderID'   , nWebOrderID),
  SF('WOM_LID'          , nBillID),
  SF('WOM_StatusType'   , c_WeChatStatusCreateCard),
  SF('WOM_MsgType'      , cSendWeChatMsgType_AddBill),
  SF('WOM_BillType'     , nBillType),
  SF('WOM_deleted'     , sFlag_No)
  ], sTable_WebOrderMatch, '', True);
  fdm.ADOConn.BeginTrans;
  try
    fdm.ExecuteSQL(nStr);
    fdm.ADOConn.CommitTrans;
    Result := True;
  except
    fdm.ADOConn.RollbackTrans;
  end;
end;

function TfFormNewPurchaseCard.VerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
var nVal: Double;
  nStr:string;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    if not Result then
    begin
      nHint := '���ƺų���Ӧ����2λ';
      Writelog(nHint);
      Exit;
    end;
  end;

  if Sender = EditValue then
  begin
//    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    Result := IsNumber(EditValue.Text, True);
    if not Result then
    begin
      nHint := '����д��Ч�İ�����';
      Writelog(nHint);
      Exit;
    end;
  end;
end;

procedure TfFormNewPurchaseCard.editWebOrderNoKeyPress(Sender: TObject;
  var Key: Char);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  if Key=Char(vk_return) then
  begin
    key := #0;
    btnQuery.Click;
  end;
end;

end.
