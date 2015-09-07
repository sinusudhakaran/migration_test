unit DownloadReportOptionsDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  OSFont;

const
  optNothing           = 0;
  optAllAccounts       = 1;
  optActive            = 2;
  optInactive          = 4;
  optNew               = 8;
  optNotReceived       = 16;
  optUnallocated       = 32;

type
  TdlgDownloadReportOptions = class(TForm)
    Label2: TLabel;
    chkHideDeleted: TCheckBox;
    Panel1: TPanel;
    chkActive: TCheckBox;
    chkInactive: TCheckBox;
    chkNew: TCheckBox;
    chkMissing: TCheckBox;
    chkNotAllocated: TCheckBox;
    btnAll: TButton;
    btnClear: TButton;
    chkAll: TCheckBox;
    Panel2: TPanel;
    btnPreview: TButton;
    btnFile: TButton;
    btnCancel: TButton;
    btnPrint: TButton;
    ShapeBorder: TShape;
    ShapeBottom: TShape;
    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnAllClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    btn : integer;

    procedure LoadOptions;
    procedure SaveOptions;

    procedure SetAll( Checked : boolean);
  public
    { Public declarations }
    function Execute : boolean;
  end;

function UpdateDownloadReportOptions( const DialogTitle : string;
                                      var BtnPressed : integer) : boolean;

//******************************************************************************
implementation

{$R *.DFM}

uses
  bkXPThemes, Globals, SYDEFS, WarningMoreFrm, bkhelp;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TdlgDownloadReportOptions }
function TdlgDownloadReportOptions.Execute: boolean;
begin
   Self.ShowModal;
   result := btn in [ BTN_PRINT, BTN_PREVIEW, BTN_FILE];
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDownloadReportOptions.btnPreviewClick(Sender: TObject);
begin
   Btn := BTN_PREVIEW;
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDownloadReportOptions.btnFileClick(Sender: TObject);
begin
   Btn := BTN_FILE;
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDownloadReportOptions.btnPrintClick(Sender: TObject);
begin
   Btn := BTN_PRINT;
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDownloadReportOptions.btnCancelClick(Sender: TObject);
begin
   Btn := BTN_NONE;
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function UpdateDownloadReportOptions( const DialogTitle : string;
                                      var BtnPressed : integer) : boolean;
begin
   BtnPressed := btn_none;
   with TdlgDownloadReportOptions.Create(Application.MainForm) do begin
      try
         Caption := DialogTitle;

         LoadOptions;
         result := Execute;
         SaveOptions;

         if result then begin
            btnPressed := btn;
         end;
      finally
         Free;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDownloadReportOptions.LoadOptions;
var
  Opt : integer;
begin
  //assumes that an admin system exists, otherwise would not have reached here
  Opt := AdminSystem.fdFields.fdDownload_Report_Options;

  chkAll.Checked         := (Opt and optAllAccounts = optAllAccounts) or ( Opt = 0);
  chkActive.Checked      := (Opt and optActive = optActive) or ( Opt = 0);
  chkInactive.Checked    := (Opt and optInactive = optInactive) or ( Opt = 0);
  chkNew.Checked         := (Opt and optNew = optNew) or ( Opt = 0);
  chkMissing.Checked     := (Opt and optNotReceived = optNotReceived) or ( Opt = 0);
  chkNotAllocated.Checked:= (Opt and optUnallocated = optUnallocated) or ( Opt = 0);

  chkHideDeleted.Checked   := AdminSystem.fdFields.fdDownload_Report_Hide_Deleted;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDownloadReportOptions.SaveOptions;
var
  Opt : integer;
begin
  Opt := 0;

  if chkAll.Checked  then         Opt := Opt or optAllAccounts;
  if chkActive.Checked then       Opt := Opt or optActive;
  if chkInactive.Checked  then    Opt := Opt or optInactive;
  if chkNew.Checked  then         Opt := Opt or optNew;
  if chkMissing.Checked  then     Opt := Opt or optNotReceived;
  if chkNotAllocated.Checked then Opt := Opt or optUnallocated;

  AdminSystem.fdFields.fdDownload_Report_Options      := Opt;
  AdminSystem.fdFields.fdDownload_Report_Hide_Deleted := chkHideDeleted.Checked;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDownloadReportOptions.btnAllClick(Sender: TObject);
begin
  SetAll( True);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDownloadReportOptions.btnClearClick(Sender: TObject);
begin
  SetAll( False);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDownloadReportOptions.SetAll( Checked : boolean);
begin
  chkAll.Checked         := Checked;
  chkActive.Checked      := Checked;
  chkInactive.Checked    := Checked;
  chkNew.Checked         := Checked;
  chkMissing.Checked     := Checked;
  chkNotAllocated.Checked:= Checked;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDownloadReportOptions.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  SomethingSelected : boolean;
begin
  if (Btn <> Btn_None) then begin
    //make sure something is selected
    SomethingSelected := chkAll.Checked or
                         chkActive.Checked or
                         chkInactive.Checked or
                         chkNew.Checked or
                         chkMissing.Checked or
                         chkNotAllocated.Checked;

    if not SomethingSelected then begin
      HelpfulWarningMsg( 'You have not selected any detail to appear on this report.  '+
                         'Please select something to display.', 0);
      CanClose := false;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDownloadReportOptions.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  bkHelp.BKHelpSetUp( Self, BKH_Running_the_Download_Report);
end;

end.
