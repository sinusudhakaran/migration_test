unit ModalProcessorDlg;
//------------------------------------------------------------------------------
{
   Title:       Modal Processor Form

   Description: The form provides a means to call routines that use
                Application process messages

   Author:      Matthew Hopkins Oct 2002

   Remarks:     The form operates as if it were a modal form, all other forms
                in the application are disabled for the duration of the command
                that the form must process.

                Routines that are called from the main form must use this
                unit if they call application process messages
}
//------------------------------------------------------------------------------

interface

uses
  Classes, Controls, Forms, ActnList,
  StdCtrls, ExtCtrls, ReportDefs,
  OSFont;

type
  TModalProcessorCommand = ( mpcDoDownloadFromBConnect,
                             mpcDoDownloadFromFloppy,
                             mpcDoPrintScheduledReports,
                             mpcDoOffsiteDownload,
                             mpcDoReport,
                             mpcDoAdminReport,
                             mpcNone);

type
  TdlgModalProcessor = class(TForm)
    lblDescription: TLabel;
    Shape1: TShape;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    Activated        : boolean;
    FHelpID          : integer;
    procedure ProcessCommand(Command: TModalProcessorCommand);
    procedure ProcessReport(ReportType : Report_List_Type; Destination : TReportDest);
  public
    { Public declarations }
    CommandToProcess : TModalProcessorCommand;
    ReportToProcess : Report_List_Type;
    ReportDestination : TReportDest;
  end;

  procedure DoModalCommand( Command : TModalProcessorCommand);
  procedure DoModalReport(ReportType : Report_List_Type; Destination : TReportDest; HelpCtx : integer = 0);

implementation

uses
  ClientHomepagefrm,
  AutoSaveUtils,
  ApplicationUtils,
  SysUtils,
  DownloadEx,
  OffsiteDownload,
  Scheduled,
  Progress,
  Reports;

{$R *.dfm}

{ TdlgModalProcessor }

procedure TdlgModalProcessor.ProcessCommand(
  Command: TModalProcessorCommand);
begin
  Case Command of
    mpcDoDownloadFromBConnect  : DownloadEx.DownloadDiskImages( DownloadEx.dsBConnect);
    mpcDoDownloadFromFloppy    : DownloadEx.DownloadDiskImages( DownloadEx.dsFloppy);
    mpcDoPrintScheduledReports : Scheduled.PrintScheduledReports;
    mpcDoOffsiteDownload       : OffsiteDownload.DoOffsiteDownloadEx;
  end;
  if Command in [mpcDoDownloadFromBConnect,
                 mpcDoDownloadFromFloppy,
                 mpcDoOffsiteDownload] then
      RefreshHomepage([HPR_Client, HPR_Files]);
end;

procedure DoModalCommand( Command : TModalProcessorCommand);
begin
  Progress.CalledFromModalProcessor := true;
  AutoSaveUtils.DisableAutoSave;
  try
    with TdlgModalProcessor.Create( nil) do //Application.MainForm) do
    begin
      try
        //turn off all current windows of main form
        DisableMainForm;
        try
          CommandToProcess := Command;
          Show;
        finally
          //turn forms back on
          EnableMainForm;
        end;
      finally
        Free;
      end;
    end;
  finally
    Progress.CalledFromModalProcessor := false;
    EnableAutoSave;
  end;
end;

procedure TdlgModalProcessor.ProcessReport(ReportType : Report_List_Type; Destination : TReportDest);
begin
  case CommandToProcess of
    mpcDoReport : DoReport(ReportType, Destination, FHelpID);
    mpcDoAdminReport : DoAdminReport( ReportType, Destination, FHelpID);
  end;
end;

procedure DoModalReport(ReportType : Report_List_Type; Destination : TReportDest; HelpCtx : integer = 0);
begin
  Progress.CalledFromModalProcessor := true;
  AutoSaveUtils.DisableAutoSave;
  try
    with TdlgModalProcessor.Create(nil) do //Application.MainForm) do
    begin
      try
        //turn off all current windows of main form
        DisableMainForm;
        try
          if ReportType in [ REPORT_DOWNLOAD, REPORT_WHATSDUE,
                             REPORT_ADMIN_ACCOUNTS, REPORT_ADMIN_INACTIVE_ACCOUNTS,
                             REPORT_PROV_ACCOUNTS,
                             REPORT_CLIENTS_BY_STAFF, REPORT_CLIENT_REPORT_OPT,
                             REPORT_DOWNLOAD_LOG, REPORT_CLIENT_STATUS,
                             REPORT_FILE_ACCESS_CONTROL, REPORT_SUMMARY_DOWNLOAD,
                             List_Groups,List_Client_Types, REPORT_CODING_OPTIMISATION,
                             Report_System_Audit, Report_Client_Audit] then
            CommandToProcess := mpcDoAdminReport
          else
            CommandToProcess := mpcDoReport;

          //store parameters
          ReportToProcess   := ReportType;
          ReportDestination := Destination;
          FHelpID           := HelpCtx;

          Show;
        finally
          //turn forms back on
          EnableMainForm;
        end;
      finally
        Free;
      end;
    end;
  finally
    Progress.CalledFromModalProcessor := false;
    EnableAutoSave;
  end;
end;

procedure TdlgModalProcessor.FormCreate(Sender: TObject);
begin
  Activated := false;
  CommandToProcess := mpcNone;
  FHelpID := 0;
end;

procedure TdlgModalProcessor.FormShow(Sender: TObject);
begin
   self.Update;
   lblDescription.Update;
end;

procedure TdlgModalProcessor.FormActivate(Sender: TObject);
begin
  if not Activated then
  begin
    Activated := true;
    case CommandToProcess of
      mpcDoReport, mpcDoAdminReport : ProcessReport( ReportToProcess, ReportDestination);
    else
      ProcessCommand( Self.CommandToProcess);
    end;
  end;
end;

end.

