unit GainLossfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RzButton, Grids_ts, TSGrid, DateUtils;

type
  TfrmGainLoss = class(TForm)
    tgGainLoss: TtsGrid;
    Label1: TLabel;
    lblMonthEndDate: TLabel;
    tbPrevious: TRzToolButton;
    tbNext: TRzToolButton;
    Label2: TLabel;
    lblEntriesCreatedDate: TLabel;
    btnClose: TButton;
    procedure FormShow(Sender: TObject);
    procedure tbPreviousClick(Sender: TObject);
    procedure tbNextClick(Sender: TObject);
  private
    { private declarations }
  public
    procedure FormCreate(Sender: TObject);
    procedure SetPeriodEndDate(Value: TDateTime);
  protected
    FPeriodEndDate: TDateTime;
    property PeriodEndDate: TDateTime read FPeriodEndDate write SetPeriodEndDate;
    procedure UpdatePeriodEndDate;
  end;

var
  frmGainLoss: TfrmGainLoss;

implementation

{$R *.dfm}

{ TfrmGainLoss }

procedure TfrmGainLoss.FormCreate(Sender: TObject);
begin
end;

procedure TfrmGainLoss.UpdatePeriodEndDate;
begin
  lblMonthEndDate.Caption := DateToStr(PeriodEndDate);
end;

procedure TfrmGainLoss.FormShow(Sender: TObject);
begin
  UpdatePeriodEndDate;
end;

procedure TfrmGainLoss.SetPeriodEndDate(Value: TDateTime);
begin
  FPeriodEndDate := Value;
end;

procedure TfrmGainLoss.tbPreviousClick(Sender: TObject);
begin
  // Simply decreasing the month by one wouldn't work, because months have varying lengths eg. 28 Feb -> 28 Jan
  FPeriodEndDate := IncDay(FPeriodEndDate, 1);
  FPeriodEndDate := IncMonth(FPeriodEndDate, -1);
  FPeriodEndDate := IncDay(FPeriodEndDate, -1);
  UpdatePeriodEndDate;
end;

procedure TfrmGainLoss.tbNextClick(Sender: TObject);
begin
  // Simply increasing the month by one wouldn't work, because months have varying lengths eg. 28 Feb -> 28 Mar
  FPeriodEndDate := IncDay(FPeriodEndDate, 1);
  FPeriodEndDate := IncMonth(FPeriodEndDate, 1);
  FPeriodEndDate := IncDay(FPeriodEndDate, -1);
  UpdatePeriodEndDate;
end;

end.
