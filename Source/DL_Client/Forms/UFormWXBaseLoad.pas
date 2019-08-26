unit UFormWXBaseLoad;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, cxCheckBox;

type
  TfFormWXBaseLoad = class(TfFormNormal)
    chkdept: TcxCheckBox;
    dxLayout1Item3: TdxLayoutItem;
    chkCusPro: TcxCheckBox;
    chkStockType: TcxCheckBox;
    chkUser: TcxCheckBox;
    chkStockInfo: TcxCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormWXBaseLoad: TfFormWXBaseLoad;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UMgrControl, UFormBase, USysConst, USysGrid, USysDB,
  USysBusiness, UDataModule, USysPopedom, UBusinessPacker, UAdjustForm, UFormWait;

class function TfFormWXBaseLoad.FormID: integer;
begin
  Result := cFI_FormWXBaseLoad;
end;

class function TfFormWXBaseLoad.CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl;
var
  nP: PFormCommandParam;
begin
  Result:=nil;
  with TfFormWXBaseLoad.Create(Application) do
  begin
    Caption := '��������������';
    ShowModal;
    Free;
  end;
end;

procedure TfFormWXBaseLoad.FormCreate(Sender: TObject);
var nIni:TIniFile;
begin
  inherited;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormWXBaseLoad.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni:TIniFile;
begin
  inherited;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormWXBaseLoad.BtnOKClick(Sender: TObject);
var
  nMsg:string;
begin
  ShowWaitForm(Self, '��������...', True);
  try
    GetLoginToken(gSysParam.FWXZhangHu,gSysParam.FWXMiMa);
    if chkdept.Checked then
    begin
      if SyncWXDept then
        nMsg:='������Ϣͬ���ɹ�'
      else
        nMsg:='������Ϣͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkUser.Checked then
    begin
      if SyncWXPersonal then
        nMsg:='��Ա��Ϣͬ���ɹ�'
      else
        nMsg:='��Ա��Ϣͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkCusPro.Checked then
    begin
      if SyncWXCusPro then
        nMsg:='������Ϣͬ���ɹ�'
      else
        nMsg:='������Ϣͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkStockType.Checked then
    begin
      if SyncWXStockType then
        nMsg:='�������ͬ���ɹ�'
      else
        nMsg:='�������ͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
    if chkStockInfo.Checked then
    begin
      if SyncWXStockInfo then
        nMsg:='�����Ϣͬ���ɹ�'
      else
        nMsg:='�����Ϣͬ��ʧ��';
      ShowMsg(nMsg,sHint);
    end;
  finally
    CloseWaitForm;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormWXBaseLoad,TfFormWXBaseLoad.FormID);

end.
