unit SimpleEOYForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OsFont;

type
  TfrmSimpleEOY = class(TForm)
    lblHeaderText: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblCodedYesNo: TLabel;
    lblAllCodedWarning: TLabel;
    btnCancel: TButton;
    btnProceed: TButton;
    Label7: TLabel;
    lblCurrentPeriod: TLabel;
    lblFullYearWarning: TLabel;
    lblFinYearStart: TLabel;
    Label1: TLabel;
    lblLastPeriodDownloaded: TLabel;
    procedure btnProceedClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function DoSimpleEOY : boolean;

implementation
uses
   globals,
   bkConst,
   bkDateUtils,
   clDateUtils,
   InfoMoreFrm,
   PeriodUtils,
   balancesForward,
   clObj32,
   StDate,
   StDateSt;

{$R *.dfm}

function DoSimpleEOY : boolean;
var
   f : TfrmSimpleEOY;
   EntriesThisYear : boolean;
   EntriesInLastPeriod : boolean;
   EntriesAfterThisYear : boolean;
   AllCoded : boolean;
   i : integer;
   MonthEnd, YearEnd, Day, Month, Year : integer;
begin
   result := false;

   if not Assigned( MyClient) then Exit;

   MonthEnd := GetLastDayOfMonth(MyClient.clFields.clTemp_FRS_To_Date);
   YearEnd := GetYearEndDate(MyClient.clFields.clFinancial_Year_Starts);
   StDatetoDMY( YearEnd, Day, Month, Year ) ;
   if (YearEnd <> MonthEnd) then
   begin
     ShowMessage('Cannot complete end of year, as the last month of the financial year (' +
                 MonthToString(Month) + ' ' + IntToStr(Year) + ') has not been coded.');
     Exit;
   end;

   f := TfrmSimpleEOY.Create(Application.MainForm);
   try
     //init fields
     f.lblHeaderText.caption := 'Completing the Year End Process will update your Financial Year Start Date to ' +
                                bkDate2Str(GetYearEndDate( MyClient.clFields.clFinancial_Year_Starts)+1);

     if MyClient.clFields.clLast_Financial_Year_Start = 0 then
       MyClient.clFields.clLast_Financial_Year_Start := GetPrevYearStartDate( MyClient.clFields.clFinancial_Year_Starts);

     f.lblFinYearStart.Caption :=  bkDate2Str( MyClient.clFields.clFinancial_Year_Starts) + ' - ' +
          bkDate2Str(GetYearEndDate( MyClient.clFields.clFinancial_Year_Starts));

     f.lblCurrentPeriod.Caption := bkDate2Str( MyClient.clExtra.ceSUI_Period_Start) + ' - ' +
                                   bkDate2Str( MyClient.clExtra.ceSUI_Period_End);

     balancesForward.SetupParameters( MyClient);

     //check there are no uncoded or invalidly coded entries
     PeriodUtils.LoadPeriodDetailsIntoArray( MyClient, MyClient.clFields.clTemp_FRS_From_Date,
                                          MyClient.clFields.clTemp_FRS_To_Date,
                                          false,
                                          frpMonthly,
                                          MyClient.clFields.clTemp_Period_Details_This_Year);

     AllCoded := true;
     EntriesThisYear := false;
     for i := 1 to 12 do
     begin
        if MyClient.clFields.clTemp_Period_Details_This_Year[ i].HasUncodedEntries then
           AllCoded := false;
        if MyClient.clFields.clTemp_Period_Details_This_Year[ i].HasData then
           EntriesThisYear := true;
      end;

     //check to see if have transaction in the last period
     EntriesInLastPeriod := MyClient.clFields.clTemp_Period_Details_This_Year[ 12].HasData;
     EntriesAfterThisYear :=  EBankData(MyClient) > MyClient.clFields.clTemp_Period_Details_This_Year[ 12].Period_End_Date;

     //show warnings
     f.lblFullYearWarning.Visible := not (EntriesThisYear and ( EntriesInLastPeriod or EntriesAfterThisYear));
     if EntriesInLastPeriod then
       f.lblLastPeriodDownloaded.caption := 'Yes'
     else
       f.lblLastPeriodDownloaded.caption := 'No';

     f.lblAllCodedWarning.Visible := not AllCoded;
     if AllCoded then
       f.lblCodedYesNo.caption := 'Yes'
     else
       f.lblCodedYesNo.caption := 'No';


     f.btnProceed.enabled := (EntriesInLastPeriod and AllCoded);

     result := f.showModal = mrOK;
   finally
     f.Free;
   end;
end;

procedure TfrmSimpleEOY.btnProceedClick(Sender: TObject);
//move fin year start and reporting year start forward
begin
  //do eoy
  with MyClient.clFields do
  begin
     clLast_Financial_Year_Start := clFinancial_Year_Starts;
    //move fin year forward
    clFinancial_Year_Starts := GetYearEndDate( clFinancial_Year_Starts) + 1;
    clReporting_Year_Starts := clFinancial_Year_Starts;

    HelpfulInfoMsg( 'Your financial year is now ' +
        bkDate2Str( MyClient.clFields.clFinancial_Year_Starts) + ' - ' +
        bkDate2Str(GetYearEndDate( MyClient.clFields.clFinancial_Year_Starts)),0);
  end;
end;

end.
