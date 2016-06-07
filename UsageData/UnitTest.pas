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
  StdCtrls;

type
  //----------------------------------------------------------------------------
  TTestForm = class(TForm)
    btnStop: TButton;
    btnStart: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
  private
    fUsageDataImporter : TUsageDataImporter;
  public

  end;

var
  TestForm: TTestForm;

//------------------------------------------------------------------------------
implementation

{$R *.dfm}
//------------------------------------------------------------------------------
procedure TTestForm.btnStartClick(Sender: TObject);
begin
  btnStart.Enabled := false;
  btnStop.Enabled  := true;

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
  fUsageDataImporter.Stop;
end;

//------------------------------------------------------------------------------
procedure TTestForm.FormCreate(Sender: TObject);
begin
  fUsageDataImporter := TUsageDataImporter.Create();
end;

//------------------------------------------------------------------------------
procedure TTestForm.FormDestroy(Sender: TObject);
begin
  fUsageDataImporter.Stop;
  FreeAndNil(fUsageDataImporter);
end;

end.
