unit DateSelectorFme;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:        Date Selection Frame

   Description:  Allows dates to be selected for client.  Can move back or forward
                 a period at a time or can select dates from the client file transaction
                 ranges.

   Remarks:      OnDateChange event is added because changing the text within the
                 date boxes (ie with btnPrev) does not fire a change event for the
                 date box.

   Author:       Matthew   Aug 2000

}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OvcBase, Menus, Buttons, ovcDate,OvcEF, OvcPB, OvcPF, clObj32;


type
  TfmeDateSelector = class(TFrame)
    Label2: TLabel;
    eDateFrom: TOvcPictureField;
    btnPrev: TSpeedButton;
    btnNext: TSpeedButton;
    btnQuik: TSpeedButton;
    eDateTo: TOvcPictureField;
    Label3: TLabel;
    pmDates: TPopupMenu;
    LastMonth1: TMenuItem;
    ThisYear1: TMenuItem;
    LastYear1: TMenuItem;
    AllData1: TMenuItem;
    OvcController1: TOvcController;
    LastQuarter1: TMenuItem;
    Last2Months1: TMenuItem;
    Last6months1: TMenuItem;

    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnQuikClick(Sender: TObject);
    procedure LastMonth1Click(Sender: TObject);
    procedure ThisYear1Click(Sender: TObject);
    procedure LastYear1Click(Sender: TObject);
    procedure AllData1Click(Sender: TObject);
    procedure eDateFromChange(Sender: TObject);
    procedure eDateFromError(Sender: TObject; ErrorCode: Word;
      ErrorMsg: String);
    procedure eDateFromKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LastQuarter1Click(Sender: TObject);
    procedure Last2Months1Click(Sender: TObject);
    procedure Last6months1Click(Sender: TObject);
  private
    { Private declarations }

    SmartOn      : Boolean;
    FOnDateChange: TNotifyEvent;
    FClientObj   : TClientObj;
    FNextControl: TWinControl;

    procedure SetUpHelp;
    procedure MoveFocus(Sender: TObject);
    procedure SetOnDateChange(const Value: TNotifyEvent);
    procedure SetClientObj(const Value: TClientObj);
    procedure SetNextControl(const Value: TWinControl);
    procedure CMShowingChanged(var M: TMessage); message CM_SHOWINGCHANGED;
    function YearStart:Integer;
    function PeriodStart (value : Integer):Integer;
  public
    { Public declarations }
    MaxDate,
    MinDate      : Integer;
    procedure InitDateSelect( dFrom : integer; dTo : integer; ControlToFocus : TWinControl);
    function  ValidateDates(Prompt: Boolean = true) : Boolean;

    property  ClientObj : TClientObj read FClientObj write SetClientObj;
    property  NextControl : TWinControl read FNextControl write SetNextControl;

    class function GetCurrentFinancialYear(Client: TClientObj): Integer;
  published
    property  OnDateChange : TNotifyEvent read FOnDateChange write SetOnDateChange;  
  end;


//******************************************************************************
implementation
{$R *.DFM}
uses
  bkConst,
  bkDateUtils,
  ClDateUtils,
  Globals,
  ImagesFrm,
  WarningMoreFrm,
  stdaTest,
  selectDate,
  StdHints;

//------------------------------------------------------------------------------

procedure TfmeDateSelector.InitDateSelect( dFrom : integer; dTo : integer; ControlToFocus : TWinControl);
begin
   eDateFrom.Epoch       := BKDATEEPOCH;
   eDateFrom.PictureMask := BKDATEFORMAT;
   eDateTo.Epoch         := BKDATEEPOCH;
   eDateTo.PictureMask   := BKDATEFORMAT;

   with ImagesFrm.AppImages.Misc do begin
      GetBitmap(MISC_ARROWLEFT_BMP,btnPrev.Glyph);
      GetBitmap(MISC_ARROWRIGHT_BMP,btnNext.Glyph);
      GetBitmap(MISC_CALENDAR_BMP,btnQuik.Glyph);
   end;

   MinDate := dFrom;
   MaxDate := dTo;
   FNextControl := ControlToFocus;

   SetupHelp;

   //disable popup if FClientObj not assigned.
   if not Assigned( FClientObj) then btnQuik.Visible := false;
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.SetUpHelp;
begin
   Self.ShowHint     := INI_ShowFormHints;
   Self.HelpContext  := 0;
   //Components
   eDateFrom.Hint    :=
                     STDHINTS.DateFromHint;
   eDateTo.Hint      :=
                     STDHINTS.DateToHint;
   btnPrev.Hint      :=
                     STDHINTS.PrevDateHint;
   btnNext.Hint      :=
                     STDHINTS.NextDateHint;
   btnQuik.Hint      :=
                     STDHINTS.QuickDateHint;
end;

//------------------------------------------------------------------------------

procedure TfmeDateSelector.MoveFocus(Sender : TObject);
begin
  if TOvcPictureField(Sender).Name = 'eDateFrom' then
    eDateTo.SetFocus
  else begin
    if Assigned( FNextControl) then
    begin
      //try except will catch errors assigning to invisible control
      try
        FNextControl.SetFocus;
      except
        On E : EInvalidOperation do ;
      end;
    end;
  end;
end;


function TfmeDateSelector.PeriodStart(value: Integer): Integer;
var
  CurrentDay, CurrentMonth, CurrentYear : Word;
  StartDay, StartMonth, StartYear : Integer;
  MonthDiv : Integer;
  lYearStart : Integer;
begin
    // break up the current date
    DecodeDate(Date, CurrentYear, CurrentMonth, CurrentDay);
    // break up the year start date
    lYearStart := YearStart;
    StDatetoDMY( lYearStart, StartDay, StartMonth, StartYear);



    if (CurrentYear > StartYear) then
      // year wrap around
      CurrentMonth := CurrentMonth + 12 * (CurrentYear -StartYear);

    // find the number of whole (Value) month periods
    MonthDiv := ((CurrentMonth - StartMonth) div value);
    // calculate the new date
    Result := IncDate(lYearStart, 0, (MonthDiv * value), 0);
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.btnPrevClick(Sender: TObject);
begin
   SELECTDATE.MovePeriod(false, eDatefrom, eDateTo, MinDate, MaxDate);
   if Assigned( FOnDateChange) then FOnDateChange( Sender);
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.btnNextClick(Sender: TObject);
begin
   SELECTDATE.MovePeriod(true, eDateFrom, eDateTo, MinDate, MaxDate);
   if Assigned( FOnDateChange) then FOnDateChange( Sender);
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.btnQuikClick(Sender: TObject);
//drop down menu
var
   ClientP, ScreenP : TPoint;
begin
   ClientP.x := btnQuik.left + btnQuik.width; ClientP.y := btnQuik.top;
   ScreenP   := Self.ClientToScreen(clientP);
   pmDates.Popup(Screenp.x,ScreenP.y);
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.CMShowingChanged(var M: TMessage);
begin
  inherited;
  Tabstop := False;
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.Last2Months1Click(Sender: TObject);
begin
  eDateTo.AsStDate   := BkNull2St(PeriodStart(2)-1);
  eDateFrom.AsStDate := BkNull2St(incDate(eDateTo.AsStDate+1,0,-2,0));
  if Assigned(FOnDateChange) then FOnDateChange(Sender);
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.Last6months1Click(Sender: TObject);
begin
  eDateTo.AsStDate   := BkNull2St(PeriodStart(6)-1);
  eDateFrom.AsStDate := BkNull2St(incDate(eDateTo.AsStDate+1,0,-6,0));
  if Assigned( FOnDateChange) then FOnDateChange( Sender);
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.LastMonth1Click(Sender: TObject);
//calendar dates for last month, relative to today
begin
  eDateFrom.AsStDate := BkNull2St(BLastMth);
  eDateTo.AsStDate   := BkNull2St(ELastMth);
  if Assigned( FOnDateChange) then FOnDateChange( Sender);
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.LastQuarter1Click(Sender: TObject);
begin
  eDateTo.AsStDate   := BkNull2St(PeriodStart(3)-1);
  eDateFrom.AsStDate := BkNull2St(incDate(eDateTo.AsStDate+1,0,-3,0));
  if Assigned( FOnDateChange) then FOnDateChange( Sender);
  if Assigned( FOnDateChange) then FOnDateChange( Sender);
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.ThisYear1Click(Sender: TObject);
begin
   eDateFrom.asStDate := BkNull2St(YearStart);
   eDateTo.asStDate   := BkNull2St(incDate( eDateFrom.asStDate,0,0,1)-1);
   if Assigned( FOnDateChange) then FOnDateChange( Sender);
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.LastYear1Click(Sender: TObject);
begin
   eDateTo.asStDate   := BkNull2St(BkNull2St(YearStart)-1);
   eDateFrom.asStDate := BkNull2St(incDate( eDateTo.asStDate,0,0,-1)+1);
   if Assigned( FOnDateChange) then FOnDateChange( Sender);
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.AllData1Click(Sender: TObject);
//return min, max dates
begin
   eDateFrom.asStDate := BkNull2St( MinDate);
   eDateTo.asStDate   := BkNull2St( MaxDate);
   if Assigned( FOnDateChange) then FOnDateChange( Sender);
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.eDateFromKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
//disable to automatic focus move if the next key is escape #8 or backspace #46
begin
  SmartOn := not((key = 8) or (key=46));
end;

//------------------------------------------------------------------------------

procedure TfmeDateSelector.eDateFromChange(Sender: TObject);
//move on to next control if entered a complete date
begin
  if smartOn then
     if TOvcPictureField(Sender).CurrentPos = length(BKDATEFORMAT) then MoveFocus(Sender);

  if Assigned( FOnDateChange) then FOnDateChange( Sender);
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.eDateFromError(Sender: TObject; ErrorCode: Word;
  ErrorMsg: String);
begin
  SELECTDATE.ShowDateError(Sender);
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.SetOnDateChange(const Value: TNotifyEvent);
begin
  FOnDateChange := Value;
end;
//------------------------------------------------------------------------------

procedure TfmeDateSelector.SetClientObj(const Value: TClientObj);
begin
  FClientObj := Value;
  if assigned(FClientObj) then begin
     if FClientObj.clFields.clCountry = whAustralia then begin
        Last2Months1.Visible := False;
        Last6months1.Visible := False;
     end;
  end else begin

  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeDateSelector.SetNextControl(const Value: TWinControl);
begin
  FNextControl := Value;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfmeDateSelector.ValidateDates(Prompt: Boolean = true): Boolean;
var
  D1, D2 : integer;
begin
  D1 := stNull2Bk(eDateFrom.AsStDate);
  D2 := stNull2Bk(eDateTo.AsStDate);
  Result := False;
  if (D1 < MinValidDate) or (D1 > MaxValidDate) then begin
     if Prompt then begin
        HelpfulWarningMsg( 'Please enter a valid From date.', 0);
        if eDateFrom.CanFocus then
           eDateFrom.SetFocus;
     end;
     Exit;
  end;

  if (D2 < MinValidDate) or (D2 > MaxValidDate) then begin
     if Prompt then begin
        HelpfulWarningMsg( 'Please enter a valid To date.', 0);
        if eDateFrom.CanFocus then
           eDateFrom.SetFocus;
     end;
     Exit;
  end;

  if (D1 > D2) then begin
     if Prompt then begin
        HelpfulWarningMsg( 'The From date must be before the To date', 0);
        if eDateFrom.CanFocus then
           eDateFrom.SetFocus;
     end;
     Exit;
  end;

  Result := True;
end;

//------------------------------------------------------------------------------
function TfmeDateSelector.YearStart: Integer;
begin
  Result := GetCurrentFinancialYear(FClientObj);
end;

//------------------------------------------------------------------------------
class function TfmeDateSelector.GetCurrentFinancialYear(
  Client: TClientObj): Integer;
var
  Day: Integer;
  Month, CMonth: Integer;
  Year, CYear: Integer;
begin
  StDatetoDMY(CurrentDate, Day, CMonth, CYear);
  if assigned(Client)
    and (Client.clFields.clFinancial_Year_Starts <> 0) then
  begin
     // Only interested in DD MM
     StDatetoDMY(Client.clFields.clFinancial_Year_Starts, Day, Month, Year);
     if CMonth < Month then
       Dec(CYear);
  end
  else
  begin
     Day := 1;  // assume 1st of Jan
     Month := 1;
  end;
  Result := DMYtoStDate(Day, Month, CYear, Epoch);
end;

end.
