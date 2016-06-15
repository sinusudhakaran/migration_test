unit UnitTest;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  UsageDataImporter,
  Dialogs,
  UsageDataReporting,
  StdCtrls;

type
  //----------------------------------------------------------------------------
  TTestForm = class(TForm)
    btnStop: TButton;
    btnStart: TButton;
    btnRunUsageReports: TButton;
    lblReportProgress: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnRunUsageReportsClick(Sender: TObject);
  private
    fUsageDataImporter : TUsageDataImporter;
    fUsageDataReporting : TUsageDataReporting;
  protected
    procedure DoProgressOnReport(aUsageGroup : integer;
                                 aUsageCount : integer);
  public

  end;

var
  TestForm: TTestForm;

//------------------------------------------------------------------------------
implementation

{$R *.dfm}
//------------------------------------------------------------------------------
procedure TTestForm.btnRunUsageReportsClick(Sender: TObject);
begin
  lblReportProgress.Visible := true;
  btnStart.Enabled := false;
  btnRunUsageReports.Enabled := false;

  fUsageDataReporting.HostName := '10.72.30.156';
  fUsageDataReporting.Database := 'P5UsageStats';
  fUsageDataReporting.UserName := 'sa';
  fUsageDataReporting.Password := '1qaz!QAZ';

  fUsageDataReporting.Connect;

  try
    fUsageDataReporting.RunFeatureUsageReport('C:\My Documents\Usage Stats\UsageReport.xlsx')
  finally
    fUsageDataReporting.Disconnect;

    btnStart.Enabled := true;
    btnRunUsageReports.Enabled := true;
    lblReportProgress.Visible := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TTestForm.btnStartClick(Sender: TObject);
begin
  btnStart.Enabled := false;
  btnStop.Enabled  := true;
  btnRunUsageReports.Enabled := false;

  fUsageDataImporter.HostName := '10.72.30.156';
  fUsageDataImporter.Database := 'P5UsageStats';
  fUsageDataImporter.UserName := 'sa';
  fUsageDataImporter.Password := '1qaz!QAZ';

  fUsageDataImporter.Start;
end;

//------------------------------------------------------------------------------
procedure TTestForm.btnStopClick(Sender: TObject);
begin
  btnStart.Enabled := true;
  btnStop.Enabled  := false;
  btnRunUsageReports.Enabled := true;

  fUsageDataImporter.Stop;
end;

//------------------------------------------------------------------------------
procedure TTestForm.FormCreate(Sender: TObject);
begin
  fUsageDataImporter := TUsageDataImporter.Create();
  fUsageDataReporting := TUsageDataReporting.Create();
  fUsageDataReporting.ProgressEvent := DoProgressOnReport;
end;

//------------------------------------------------------------------------------
procedure TTestForm.FormDestroy(Sender: TObject);
begin
  fUsageDataReporting.Disconnect;
  FreeAndNil(fUsageDataReporting);

  fUsageDataImporter.Stop;
  FreeAndNil(fUsageDataImporter);
end;

//------------------------------------------------------------------------------
procedure TTestForm.DoProgressOnReport(aUsageGroup, aUsageCount: integer);
begin
  lblReportProgress.Caption := 'Usage Group - ' + inttostr(aUsageGroup) + ', Usage Count - ' + inttostr(aUsageCount);
  Forms.Application.ProcessMessages;
end;

end.
