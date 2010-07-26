unit dlgSelectPeriod;

interface

uses
  bkdateutils,
  clObj32,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DateSelectorFme, StdCtrls, ExtCtrls,
  OsFont;

type
  TfrmSelectPeriod = class(TForm)
    pButton: TPanel;
    btnCancel: TButton;
    fmeDateSelector1: TfmeDateSelector;
    BtnOK: TButton;
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FClient: TClientObj;
    procedure SetPeriod(const Value: TDateRange);
    function GetPeriod: TDateRange;
    procedure SetClient(const Value: TClientObj);
  public
    property Period: TDateRange read GetPeriod write SetPeriod;
    property Client: TClientObj read FClient write SetClient;
  end;


function SelectAPeriod(Title: string; var DateRange: TDateRange): Boolean;

implementation

{$R *.dfm}
uses
   bkXPThemes,
   ErrorMoreFrm,
   stDate,
   Globals,
   ClDateUtils;

function SelectAPeriod(Title: string; var DateRange: TDateRange): Boolean;
var MyDlg: TfrmSelectPeriod;
begin
   MyDlg := TfrmSelectPeriod.Create(nil);
   try
      Mydlg.Client := MyClient;
      MyDlg.Period := DateRange;
      Mydlg.Caption := Title;
      if MyDlg.ShowModal = mrok then begin
         DateRange := MyDlg.Period;
         Result := true;
      end else
         Result := False;

   finally
      MyDlg.Free;
   end;
end;


{ TfrmSelectPeriod }

procedure TfrmSelectPeriod.BtnOKClick(Sender: TObject);
var ld: TStDate;
    D,M,Y: Integer;
begin
   // Validate ???
   ld := fmeDateSelector1.eDateFrom.AsStDate;

   stDateToDMY(ld, D, M, Y );
   if D <> 1 then begin
      HelpfulErrorMsg('Please enter a valid month start date.',0);
      fmeDateSelector1.eDateFrom.SetFocus;
      Exit;
   end;

   ld := fmeDateSelector1.eDateTo.AsStDate;
   stDateToDMY(ld, D, M, Y );
   if D <> DaysInMonth(M,Y,BKDATEEPOCH) then begin
      HelpfulErrorMsg('Please enter a valid month end date.',0);
      fmeDateSelector1.eDateTo.SetFocus;
      Exit;
   end;

   if fmeDateSelector1.eDateFrom.AsStDate >= fmeDateSelector1.eDateTo.AsStDate then begin
      HelpfulErrorMsg('Please enter a to-date, later than the from-date',0);
      fmeDateSelector1.eDateTo.SetFocus;
      Exit;
   end;

   ModalResult := mrOK;
end;

procedure TfrmSelectPeriod.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm(Self);
end;

procedure TfrmSelectPeriod.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   case Key of
   VK_Escape : begin
         Key := 0;
         ModalResult := mrCancel;
      end;
   end;
end;

function TfrmSelectPeriod.GetPeriod: TDateRange;
begin
   Result.FromDate := fmeDateSelector1.eDateFrom.AsStDate;
   Result.ToDate   := fmeDateSelector1.eDateTo.AsStDate;
end;

procedure TfrmSelectPeriod.SetClient(const Value: TClientObj);
begin
  FClient := Value;
  if assigned(FClient) then begin
     fmeDateSelector1.ClientObj := FClient;
     fmeDateSelector1.InitDateSelect( ClDateUtils.BAllData(FClient),
                                      ClDateUtils.EAllData(FClient),
                                      fmeDateSelector1.eDateFrom
                                     );
  end;
end;

procedure TfrmSelectPeriod.SetPeriod(const Value: TDateRange);
begin
   fmeDateSelector1.eDateFrom.AsStDate := BKNull2St(Value.FromDate);
   fmeDateSelector1.eDateTo.AsStDate   := BKNull2St(Value.ToDate);
end;

end.
