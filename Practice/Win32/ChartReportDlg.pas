unit ChartReportDlg;

interface

uses
  RptParams,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons,
  OsFont;

type
  TDlgChartReport = class(TForm)
    Label1: TLabel;
    btnPreview: TButton;
    btnFile: TButton;
    btnPrint: TButton;
    btnCancel: TButton;
    rbFull: TRadioButton;
    rbBasic: TRadioButton;
    BtnSave: TBitBtn;
    btnEmail: TButton;
    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
  private
    { Private declarations }
    FPressed: integer;
    FRptParams: TRPTParameters;
    procedure SetUpHelp(Value: Integer);
    procedure SetPressed(const Value: integer);
    procedure SetRptParams(const Value: TRPTParameters);
  public
    { Public declarations }
    property Pressed: integer read FPressed write SetPressed;
    property RptParams: TRPTParameters read FRptParams write SetRptParams;
  end;

  function GetChartReportOptions( var Basic: Boolean;
                                  Params: TRPTParameters;
                                  HelpCtx: integer = 0): boolean;

var
  DlgChartReport: TDlgChartReport;

implementation

uses
  bkXPThemes,
  bkHelp,
  UBatchBase,
  ImagesFrm,
  dlgAddFavourite,
  Globals,
  StdHints;

{$R *.dfm}

procedure TDlgChartReport.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := Value;
   //Components
   btnPreview.Hint  := STDHINTS.PreviewHint;
   btnPrint.Hint    := STDHINTS.PrintHint;
end;

procedure TDlgChartReport.SetPressed(const Value: integer);
begin
   FPressed := Value;
end;

procedure TDlgChartReport.SetRptParams(const Value: TRPTParameters);
begin
  FRptParams := Value;
  if assigned(FRptParams) then begin
     FRptParams.SetDlgButtons(BtnPreview,BtnFile,BtnEmail,BtnSave,BtnPrint);
     if Assigned(FRptParams.RptBatch) then //Assumes is set only once
        Caption := Caption + ' [' + FRptParams.RptBatch.Name + ']';
  end else
     BtnSave.Hide;
end;

procedure TDlgChartReport.btnPreviewClick(Sender: TObject);
begin
   Pressed := BTN_PREVIEW;
   Close;
end;

procedure TDlgChartReport.btnEmailClick(Sender: TObject);
begin
   Pressed := BTN_EMAIL;
   Close;
end;

procedure TDlgChartReport.btnFileClick(Sender: TObject);
begin
   Pressed := BTN_FILE;
   Close;
end;

procedure TDlgChartReport.btnPrintClick(Sender: TObject);
begin
   Pressed := BTN_PRINT;
   Close;
end;

procedure TDlgChartReport.BtnSaveClick(Sender: TObject);
begin
   if not FRptParams.CheckForBatch(Self.Caption, Self.Caption) then
      Exit;


   Pressed := BTN_SAVE;
   Close;
end;

procedure TDlgChartReport.btnCancelClick(Sender: TObject);
begin
   Pressed := BTN_NONE;
   Close;
end;

procedure TDlgChartReport.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm(Self);
   //favorite reports functionality is disabled in simpleUI
   if Active_UI_Style = UIS_Simple then
      btnSave.Hide;
end;

function GetChartReportOptions(var Basic: Boolean;
                                  Params: TRPTParameters;
                                  HelpCtx: integer = 0): boolean;
begin
  Params.RunBtn := BTN_NONE;
  with TdlgChartReport.Create(Application.MainForm) do begin
    try
       SetUpHelp(HelpCtx);
       rbBasic.Checked := Basic;
       RptParams := Params;

       //*************
       ShowModal;
       //*************

       Basic := rbBasic.Checked;
       Result := Params.DlgResult(Pressed);

    finally
       Free;
    end;
  end;
end;

end.
