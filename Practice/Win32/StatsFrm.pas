unit StatsFrm;
//------------------------------------------------------------------------------
{
   Title:       Statistic Form

   Description:

   Author:

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls,
  bkXPThemes,
  OSFont;

type
  TfrmStatistics = class(TForm)
    pnlFooter: TPanel;
    btnClose: TButton;
    PageControl1: TPageControl;
    tbsRaw: TTabSheet;
    memFile: TMemo;
    tbsCalculated: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    lblLogins: TLabel;
    lblReliability: TLabel;
    Label3: TLabel;
    lblStartDate: TLabel;
    Label4: TLabel;
    lblLockErrors: TLabel;
    Label5: TLabel;
    lblUnhandled: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure ShowStatistics;

//******************************************************************************
implementation
uses
  ErrorLog;

{$R *.dfm}

procedure ShowStatistics;
var
  ReliabilityPerc : double;
  Logins, Logouts : integer;
  LockErrors      : integer;
  UnhandledErrorCount : integer;
  StatisticsData  : TStringList;
begin
  with TfrmStatistics.Create( Application.MainForm) do
  begin
    try
      StatisticsData := TStringList.Create;
      try
        StatisticsData.Text := ERRORLOG.SysLog.GetStatistics;
        //subtract current session login
        Logins := StrToIntDef( StatisticsData.Values['Logins'], 0) - 1;
        Logouts := StrToIntDef( StatisticsData.Values['Logouts'], 0);
        LockErrors := StrToIntDef( StatisticsData.Values['LockErrors'], 0);
        UnhandledErrorCount := StrToIntDef( StatisticsData.Values['UnHandledErrors'], 0);

        if Logins <> 0 then
          ReliabilityPerc := Logouts/Logins * 100
        else
          ReliabilityPerc := 100.0;

        lblLogins.Caption := IntToStr( Logins);
        lblReliability.Caption := Format( '%4.2f %', [ReliabilityPerc]);
        lblStartDate.Caption := StatisticsData.Values['Created'];
        lblLockErrors.Caption := IntToStr( LockErrors);
        lblUnHandled.Caption  := IntToStr( UnhandledErrorCount);

        memFile.Text := StatisticsData.Text;

        ShowModal;
      finally
        StatisticsData.Free;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TfrmStatistics.FormCreate(Sender: TObject);
begin
    bkXPThemes.ThemeForm( Self);
end;

end.
