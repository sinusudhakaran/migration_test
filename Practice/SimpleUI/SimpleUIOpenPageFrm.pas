unit SimpleUIOpenPageFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvGlassButton, ExtCtrls, RzPanel, OsFont, BkExGlassButton,
  menus;

type
  TfrmSimpleUIOpen = class(TForm)
    gpnlButtonHolder: TGridPanel;
    gbtnOpenLast: tbkExGlassButton;
    gbtnOpenDiff: tbkExGlassButton;
    gbtnCheckIn: tbkExGlassButton;
    pnlExtraTitleBar: TRzPanel;
    imgRight: TImage;
    imgLeft: TImage;
    gbtnRestore: tbkExGlassButton;
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure gbtnOpenLastClick(Sender: TObject);
    procedure gbtnCheckInClick(Sender: TObject);
    procedure gbtnOpenDiffClick(Sender: TObject);
    procedure CommonButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure gbtnRestoreClick(Sender: TObject);
  private
     FakeMenuITem : TMenuItem;
     procedure wmsyscommand( var msg: TWMSyscommand ); message wm_syscommand;
    { Private declarations }
  public
    { Public declarations }
  end;

  function ShowSimpleUIOpen : boolean;
  procedure CloseSimpleUIOpen( ProcessMessage: Boolean = True);


implementation
uses
   Globals, logutil, MainFrm, SUIFrameHelper, Math, bkBranding, imagesfrm;
{$R *.dfm}

const
  UnitName = 'SIMPLEUIOPEN';

var
  FormIsLoading : boolean;
  SimpleUIOpenPage: TfrmSimpleUIOpen;
  DebugMe : boolean = false;

function ShowSimpleUIOpen;
begin
  result := false;
  if Assigned(AdminSystem) then exit;  //should never happen

  if FormIsLoading then exit;

  FormIsLoading := true;
  try
  if Assigned (SimpleUIOpenPage) then begin
     // Alread open...
     if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter Re Activate');
     if (SimpleUIOpenPage.WindowState = wsMinimized) then
            ShowWindow(SimpleUIOpenPage.Handle, SW_RESTORE);

     SimpleUIOpenPage.BringToFront;
     SimpleUIOpenPage.OnActivate(nil);
  end else begin
     if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter Make New');
     Application.CreateForm(TfrmSimpleUIOpen,SimpleUIOpenPage);

     with SimpleUIOpenPage do begin
        FormStyle := fsMDIChild;
     end;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit Make New / Re Activate');
  finally
      FormIsLoading := False;
  end;
end;

procedure CloseSimpleUIOpen( ProcessMessage: Boolean = True);
begin
   if assigned (SimpleUIOpenPage) then
   begin
      SimpleUIOpenPage.Release;
      if ProcessMessage then
        Application.ProcessMessages;
   end;
end;

procedure TfrmSimpleUIOpen.gbtnCheckInClick(Sender: TObject);
begin
  frmMain.DoMainFormCommand(mf_mcCheckIn);
end;

procedure TfrmSimpleUIOpen.gbtnOpenDiffClick(Sender: TObject);
begin
  frmMain.DoMainFormCommand(mf_mcOpenFile);
end;

procedure TfrmSimpleUIOpen.gbtnOpenLastClick(Sender: TObject);
begin
  frmMain.DoMainFormCommand( mf_mcOpenFromMRU, FakeMenuItem);
end;

procedure TfrmSimpleUIOpen.gbtnRestoreClick(Sender: TObject);
begin
  frmMain.DoMainFormCommand(mf_mcOffsiteRestore);
end;

procedure TfrmSimpleUIOpen.FormActivate(Sender: TObject);
begin
  EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_MINIMIZE,
                  MF_BYCOMMAND or MFS_GRAYED );
  EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_RESTORE,
                  MF_BYCOMMAND or MFS_GRAYED );
  EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_MAXIMIZE,
                  MF_BYCOMMAND or MFS_GRAYED );


  Self.SelectFirst;
end;

procedure TfrmSimpleUIOpen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := caNone;
end;

procedure TfrmSimpleUIOpen.FormCreate(Sender: TObject);
var
  s  : string;
begin
   imgLeft.Picture := bkBranding.TopBannerImage;   
   imgRight.Transparent := True;
   imgRight.Picture := bkBranding.ClientBanner;
   pnlExtraTitleBar.Height := imgRight.Picture.Height + 5;
   SUIFrameHelper.InitButtonsOnGridPanel( gpnlButtonHolder, CommonButtonKeyUp, nil, nil,
                                          150,   //buttonsize
                                          30,    //horiz
                                          10,    //vert
                                          40,    //label height
                                          11);   //font
   //update most recent item
   if INI_MRUList[1] <> '' then
   begin
      S := INI_MRUList[1];
      S := StringReplace(S, '&', '&&', [rfReplaceAll]);
      S := StringReplace(S, #9, ' : ', [rfReplaceAll]);
      gbtnOpenLast.LabelCaption := S;
      gbtnOpenLast.LabelVisible := true;
   end
   else
      gbtnOpenLast.LabelVisible := false;

   //create a fake menu item, this is easier than changing files and mainf code
   FakeMenuItem := TMenuItem.Create( Self);
   FakeMenuITem.Caption := '1 ' + INI_MRUList[1];
end;

procedure TfrmSimpleUIOpen.FormDestroy(Sender: TObject);
begin
  SimpleUIOpenPage := nil;
  FakeMenuItem.Free;
end;

procedure TfrmSimpleUIOpen.wmsyscommand(var msg: TWMSyscommand);
//override default handling to prevent minimise and restore
begin
  if ((msg.CmdType and $FFF0) = SC_MINIMIZE) or
     ((msg.CmdType and $FFF0) = SC_RESTORE) then
    exit
  else
    inherited;
end;

procedure TfrmSimpleUIOpen.CommonButtonKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   if Key = VK_RIGHT then
   begin
     Key := 0;
     //force app to move to next items in tab order
     Self.SelectNext(TWinControl(Sender),true,true);
   end;

   if Key = VK_LEFT then
   begin
     Key := 0;
     //force app to move to next items in tab order
     Self.SelectNext(TWinControl(Sender),false,true);
   end;
end;


initialization
   DebugMe := DebugUnit(UnitName);
   FormIsLoading := false;
   SimpleUIOpenPage := nil;
end.
