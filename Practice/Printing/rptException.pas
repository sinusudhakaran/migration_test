unit RptException;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Exception Report
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   ReportDefs,
   UbatchBase;

procedure DoExceptionReportEx( Destination: TReportDest;RptBatch : TReportBase = nil);

//******************************************************************************
implementation

uses
   ReportTypes,
   AccountInfoObj,
   baobj32,
   bkconst,
   bkDateUtils,
   bkdefs,
   bkutil32,
   BudgetLookup,
   budobj32,
   CalculateAccountTotals,
   clObj32,
   ExceptRepDlg,
   GenUtils,
   glConst,
   globals,
   infoMoreFrm,
   moneydef,
   NewReportObj,
   NewReportUtils,
   repcols,
   stDate,
   SetCriteriaDlg,
   SignUtils,
   stDateSt,
   RptParams,
   sysutils,
   ForexHelpers,
   ExchangeGainLossReport;

type
   TExceptionsReportEx = class(TBKReport)
     constructor Create( const ForClient : TClientObj); reintroduce; virtual;
     destructor  Destroy; override;
   private
     ClientForReport : TClientOBj;
     ExceptOptions : TExceptParam;
     AccountInfo : TAccountInformation;
   protected
     procedure BKPrint; override;
   end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure FlagAllAccountsForPrinting( aClient : TClientObj);
//will be called by old dialog routines so that all accounts are selected
var
  i : integer;
  ba : TBank_Account;
begin
  with aClient do begin
     //now set temporary flag into bank accounts;
     for i := 0 to Pred( clBank_Account_List.ItemCount) do begin
       ba := clBank_Account_List.Bank_Account_At(i);
       ba.baFields.baTemp_Include_In_Report := true;
     end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetGSTString(aClient : TClientObj) : string;
//returns a string as to whether the report is gst inclusive or exclusive,
//depends on if the client uses GST
Var
  TaxName : String;
begin
  TaxName := aClient.TaxSystemNameUC;
  if aClient.clFields.clGST_Inclusive_Cashflow then
    result := ' (Incl ' + TaxName + ') '
  else
    result := ' (Excl ' + TaxName + ') ';
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoExceptionReportEx(Destination: TReportDest;RptBatch : TReportBase = nil);
var
   Job : TExceptionsReportEx;
   Opt : TExceptParam;
   s1, s2 : string;
   cLeft: Double;
   FORMAT_AMOUNT : String;
   FORMAT_AMOUNT2: String;
begin
   if not HasAChart then exit;

   if not HasExceptions then
   begin
     SetExceptionCriteria;
     if not HasExceptionsSilent then exit;
   end;

   Opt := TExceptParam.Create(ord(Report_Exception), MyClient,RptBatch,DYear,True);

   with Opt do try repeat

      if not GetExceptOpt(Opt) then exit;


      if RunBtn = BTN_SAVE then begin
         SaveNodeSettings;
         Exit;
      end;

      {f (Destination = rdNone)
      or Batchsetup then}
      case RunBtn of
         BTN_PREVIEW : Destination := rdScreen;
         BTN_PRINT   : Destination := rdPrinter;
         BTN_FILE    : Destination := rdFile;
      else
         Destination := rdScreen;
      end;

      FORMAT_AMOUNT := '#,##0.00;(#,##0.00)';
      FORMAT_AMOUNT2 := Client.FmtMoneyStrBrackets;

      CalculateAccountTotals.AddAutoContraCodes( Client);
      try
        with Client, clFields do begin
           //set fields required by calculation routine
           //clGST_Inclusive_Cashflow - Set by dialog
           clFRS_Reporting_Period_Type               := frpMonthly;
           clTemp_FRS_Account_Totals_Cash_Only       := false;
           clTemp_FRS_Division_To_Use                := 0;
           clTemp_FRS_Job_To_Use                     := '';
           if Assigned( Budget) then begin
              clTemp_FRS_Budget_To_Use               := Budget.buFields.buName;
              clTemp_FRS_Budget_To_Use_Date          := Budget.buFields.buStart_Date;
           end else begin
              clTemp_FRS_Budget_To_Use               := '';
              clTemp_FRS_Budget_To_Use_Date          := -1;
           end;

           //set periods required by report
           clTemp_FRS_Last_Period_To_Show            := Period;
           clTemp_FRS_Last_Actual_Period_To_Use      := clTemp_FRS_Last_Period_To_Show;

           //now set temporary flag into bank accounts;
           FlagAllAccountsForPrinting( Client);

           //check relevant pre conditions
           //Persistant Fields
           //clGST_Inclusive_Cashflow
           //clFRS_Print_Chart_Codes
           //clFRS_Show_YTD
           //clFRS_Show_Variance
           //clFRS_Prompt_User_to_use_Budgeted_figures

           Assert( clFRS_Compare_Type in [cflCompare_None, cflCompare_To_Budget, cflCompare_To_Last_Year]);
           Assert( clReporting_Year_Starts > 0);

           //Non-persistant fields
           Assert( clTemp_FRS_Last_Period_To_Show in [0..pdMaximumNoOfPeriods[ clFRS_Reporting_Period_Type]]);
           Assert( clTemp_FRS_Division_To_Use in [ 0..Max_Divisions]);
           Assert( clTemp_FRS_Last_Actual_Period_To_Use <= clTemp_FRS_Last_Period_To_Show);

           //clTemp_FRS_Budget_To_Use
           //clTemp_FRS_Account_Totals_Cash_Only
           //clTemp_FRS_Use_Budgeted_Data_If_No_Actual_Data

           //The following fields are filled automatically by the CalculateAccountTotals routine
           //clTemp_Period_Details_This_Year
           //clTemp_Period_Details_Last_Year
           //clTemp_Periods_This_Year
           //clTemp_Periods_Last_Year
           //clTemp_Last_Period_Of_Actual_Data

           clTemp_FRS_Account_Totals_Cash_Only := false;

           CalculateAccountTotals.CalculateAccountTotalsForClient( Client, True, nil, -1, False, False, True);

           //check fields that are filled automatically
           Assert( clFRS_Reporting_Period_Type <= MyClient.clFields.clTemp_Periods_This_Year);
           Assert( clTemp_Last_Period_Of_Actual_Data <= MyClient.clFields.clTemp_Periods_This_Year);
        end;
        Job := TExceptionsReportEx.Create( Client);
        try
           Job.LoadReportSettings(UserPrintSettings,MakeRptName(Report_List_Names[REPORT_EXCEPTION]));

           {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
           with Client.clFields do begin
             s1 := bkdate2Str( clTemp_Period_Details_This_Year[clTemp_FRS_Last_Period_To_Show].Period_Start_Date);
             s2 := bkdate2Str( clTemp_Period_Details_This_Year[clTemp_FRS_Last_Period_To_Show].Period_End_Date);
           end;

           //Add Headers
           AddCommonHeader(Job);

           AddJobHeader(Job,siTitle,'EXCEPTION REPORT ' + GetGSTString( MyClient) + ' (' + S1 + ' - ' + S2 + ')',true);

           if Assigned(Budget) then begin
              AddJobHeader( Job,siSubTitle, 'Using Budget: ' + Budget.buFields.buName, true);
           end;
           AddJobHeader(Job,siSubTitle, '', true);

           cLeft := GcLeft;
           AddColAuto(Job,cLeft,      23.0,Gcgap,'Actual Figure', jtLeft);
           AddColAuto(Job,cLeft,      23.0,Gcgap,'Compared With', jtLeft);
           AddFormatColAuto(Job,cLeft,12.5,Gcgap,'Actual',jtRight,FORMAT_AMOUNT2,FORMAT_AMOUNT2,false);
           AddFormatColAuto(Job,cLeft,12.5,Gcgap,'Expected',jtRight,FORMAT_AMOUNT2,FORMAT_AMOUNT2,false);

           s1 := Client.CurrencySymbol + ' Variance';

           AddFormatColAuto(Job,cLeft,12.5,Gcgap, s1, jtRight,FORMAT_AMOUNT2,FORMAT_AMOUNT,false);

           AddFormatColAuto(Job,cLeft, 9.0,Gcgap,'% Variance',jtRight,'#,##0.00;-#,##0.00','#,##0.00;-#,##0.00',false);
           AddColAuto(Job,cLeft,       7.0,Gcgap,'Outcome', jtRight);

           //Add Footers
           AddCommonFooter(Job);

           Job.ExceptOptions := Opt;
           Job.Generate(Destination, Opt);
        finally
           Job.Free;
        end;
      finally
        CalculateAccountTotals.RemoveAutoContraCodes(client);
      end;
   until RunExit(Destination);
   finally
     Opt.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{ TExceptionsReportEx }

procedure TExceptionsReportEx.BKPrint;

    Function ExceedsBounds( P : pAccount_Rec; Actual, Expected : Money ): Boolean;
    //checks whether the amounts differ beyond the specified variance is
    //this is used to determine if the account should be printed
    Var
       MV    : Money;
       PV    : Money;
       AMV   : Money;
       APV   : Money;
    Begin
       ExceedsBounds := FALSE;
       If Expected = 0 then Exit;

       MV    := Actual - Expected;
       PV    := Round( 10000.0 * MV / Expected );
       AMV   := Abs( MV );
       APV   := Abs( PV );

       With P^ do
       Begin
          Case ExpectedSign( chAccount_Type ) of
             Credit :
                Begin
                   Case SignOf( MV ) of
                      Credit : If ( ( chMoney_Variance_Up <> 0 ) AND ( AMV > chMoney_Variance_Up ) ) OR
                                  ( ( chPercent_Variance_Up <>0 ) AND ( APV > chPercent_Variance_Up ) ) then
                                  ExceedsBounds := TRUE;

                      Debit  : If ( ( chMoney_Variance_Down <> 0 ) AND ( AMV > chMoney_Variance_Down ) ) OR
                                  ( ( chPercent_Variance_Down <>0 ) AND ( APV > chPercent_Variance_Down ) ) then
                                  ExceedsBounds := TRUE;
                   end;
                end;

             Debit :
                Begin
                   Case SignOf( MV ) of
                      Debit  : If ( ( chMoney_Variance_Up <> 0 ) AND ( AMV > chMoney_Variance_Up ) ) OR
                                  ( ( chPercent_Variance_Up <>0 ) AND ( APV > chPercent_Variance_Up ) ) then
                                  ExceedsBounds := TRUE;

                      Credit : If ( ( chMoney_Variance_Down <> 0 ) AND ( AMV > chMoney_Variance_Down ) ) OR
                                  ( ( chPercent_Variance_Down <>0 ) AND ( APV > chPercent_Variance_Down ) ) then
                                  ExceedsBounds := TRUE;
                   end;
                end;
          end; { of Case }
       end;
    end;

    {  ----------------------------------------------------------------------  }

    Function Money_Variance( P : pAccount_Rec; Actual, Expected : Money ): Money;

    Var
       MV    : Money;
       AMV   : Money;
       //PV    : Money;
       //APV   : Money;
    Begin
       Money_Variance := 0;
       If Expected = 0 then Exit;

       MV    := Actual - Expected;
       AMV   := Abs( MV );
       //PV    := Round( 10000.0 * MV / Expected );
       //APV   := Abs( PV );

       With P^ do
       Begin
          Case ExpectedSign( chAccount_Type ) of
             Credit :
                Begin
                   Case SignOf( MV ) of
                      Credit : Money_Variance := AMV;
                      Debit  : Money_Variance := -AMV;
                   end;
                end;

             Debit :
                Begin
                   Case SignOf( MV ) of
                      Debit  : Money_Variance := AMV;
                      Credit : Money_Variance := -AMV;
                   end;
                end;
          end; { of Case }
       end;
    end;

    {  ----------------------------------------------------------------------  }

    Function Percent_Variance( P : pAccount_Rec; Actual, Expected : Money ): Money;

    Var
       MV    : Money;
       PV    : Money;
       //AMV   : Money;
       APV   : Money;
    Begin
       Percent_Variance := 0;
       If Expected = 0 then Exit;

       MV    := Actual - Expected;
       PV    := Round( 10000.0 * MV / Expected );
       //AMV   := Abs( MV );
       APV   := Abs( PV );

       With P^ do
       Begin
          Case ExpectedSign( chAccount_Type ) of
             Credit :
                Begin
                   Case SignOf( MV ) of
                      Credit : Percent_Variance := APV;   { Up }
                      Debit  : Percent_Variance := -APV;    { Down }
                   end;
                end;

             Debit :
                Begin
                   Case SignOf( MV ) of
                      Debit  : Percent_Variance := APV; { Up }
                      Credit : Percent_Variance := -APV; { Down }
                   end;
                end;
          end; { of Case }
       end;
    end;

    procedure PrintVariance( pAcct : pAccount_Rec; sActualTitle, sComparitiveTitle : String; ActualValue : money; Comparitive : money; DefaultSign : TSign);
    var
      MoneyVariance        : Money;
      PercentageVariance   : Money;
    begin
      MoneyVariance      := Money_Variance( pAcct, ActualValue, Comparitive );
      PercentageVariance := Percent_Variance( pAcct, ActualValue, Comparitive);

      PutString( sActualTitle );
      PutString( sComparitiveTitle );
      PutMoney( ActualValue, DefaultSign);
      PutMoney( Comparitive, DefaultSign);
      PutMoney( MoneyVariance );
      PutMoney( PercentageVariance );

      if MoneyVariance >= 0 then
        PutString( 'More' )
      else
        PutString( 'Less' );

      RenderDetailLine;
    end;

var
   I                   : LongInt;
   PrintMe             : Boolean;
   S                   : String;
   VM, VP              : String[40];
   ECount              : LongInt;
   Month               : String[6];
   Account             : pAccount_Rec;
   AcctSign            : TSign;
   p                   : integer;
   mActualOrBudget     : Money;
   mLastYear           : Money;
   mBudget             : Money;
   mYTD_ActualOrBudget : Money;
   mYTD_LastYear       : Money;
   mYTD_Budget         : Money;
   Actual              : Money;
   Comparitive         : Money;
begin
   with ClientForReport, ClientForReport.clFields, ExceptOptions do
   begin
      Month := stDateToDateString( 'nnn-YY', clTemp_Period_Details_This_Year[clTemp_FRS_Last_Period_To_Show].Period_End_Date,true);

      ECount := 0;

      With clChart do For I := 0 to Pred( itemCount ) do
      Begin
         Account := Account_At( I );
         //set up the account info object
         AccountInfo.UseBudgetIfNoActualData     := False;
         AccountInfo.LastPeriodOfActualDataToUse := ClientForReport.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
         AccountInfo.AccountCode                 := Account.chAccount_Code;
         //refer to these temp variable from now on to make code more readable
         AcctSign  := ExpectedSign( Account^.chAccount_Type);
         p         := clTemp_FRS_Last_Period_To_Show;

         With Account^ do
         Begin
            PrintMe := FALSE;
            If ( chMoney_Variance_Up     <> 0 )  OR     //these are criteria set in the SetCriteriaDlg
               ( chMoney_Variance_Down   <> 0 )  OR
               ( chPercent_Variance_Up   <> 0 )  OR
               ( chPercent_Variance_Down <> 0 )  Then
            Begin
               //  This Period
               mActualOrBudget := AccountInfo.ActualOrBudget(p);
               // This Period Last Year
               mLastYear := AccountInfo.LastYear(p);
               // This Period Budgeted
               mBudget := AccountInfo.Budget(p);

               // Year to Date
               mYTD_ActualOrBudget := AccountInfo.YTD_ActualOrBudget(p);
               // Year to Date Last Year
               mYTD_LastYear := AccountInfo.YTD_LastYear(p);
               // Year to Date Budgeted
               mYTD_Budget := AccountInfo.YTD_Budget(p);

               // Add exchange gain/loss
               if IsForeignCurrencyClient(ClientForReport) then
               begin
                  { Note:
                    * ActualOrBudget is always Actual, never Budget
                     (See AccountInfo flags)

                    * Budget can remain as it is because it's retrieved
                      differently from transactions
                  }

                  // This Period
                  AddExchangeGainLossTo(ClientForReport, chAccount_Code,
                    glpThisPeriod, mActualOrBudget);

                  // This Period Last Year
                  AddExchangeGainLossTo(ClientForReport, chAccount_Code,
                    glpThisPeriodLastYear, mLastYear);

                  // Year to Date
                  AddExchangeGainLossTo(ClientForReport, chAccount_Code,
                    glpYearToDate, mYTD_ActualOrBudget);

                  // Year to Date Last Year
                  AddExchangeGainLossTo(ClientForReport, chAccount_Code,
                    glpYearToDateLastYear, mYTD_LastYear);
               end;

               If ( ( Options and exYTD_vs_BudgetYTD  ) = exYTD_vs_BudgetYTD  ) then
                  PrintMe := PrintMe OR
                  ( ExceedsBounds( Account, mYTD_ActualOrBudget, mYTD_Budget));

               If ( ( Options and exYTD_vs_LastYrYTD  ) = exYTD_vs_LastYrYTD  ) then
                  PrintMe := PrintMe OR
                  ( ExceedsBounds( Account, mYTD_ActualOrBudget, mYTD_LastYear));

               If ( ( Options and exThisPd_vs_Budget ) = exThisPd_vs_Budget ) then
                  PrintMe := PrintMe OR
                  ( ExceedsBounds( Account, mActualOrBudget, mBudget));

               If ( ( Options and exThisPd_vs_LastYr ) = exThisPd_vs_LastYr ) then
                  PrintMe := PrintMe OR
                  ( ExceedsBounds( Account, mActualOrBudget, mLastYear));

               If PrintMe then
               Begin
                  Inc( ECount );

                  VM := UDMoney( chMoney_Variance_Up, chMoney_Variance_Down );
                  VP := UDPercent( chPercent_Variance_Up, chPercent_Variance_Down );
                  S  := chAccount_Code + ' ' + chAccount_Description + ' ['+ VM + ' ' +VP+ ']';
                  RenderTitleLine(S);

                  {  ------------------------------------------------------  }
                  {  This Period vs This Period Last Year                    }
                  Actual      := mActualOrBudget;
                  Comparitive := mLastYear;

                  If ( ( Options and exThisPd_vs_LastYr ) = exThisPd_vs_LastYr ) and
                    ( ExceedsBounds( Account, Actual, Comparitive)) then
                  Begin
                     PrintVariance( Account, 'This Period', 'This Period Last Year', Actual, Comparitive, AcctSign);
                  end;

                  {  ----------------------------------------------------------  }
                  { This Period vs Budgeted this Period                      }
                  Actual      := mActualOrBudget;
                  Comparitive := mBudget;

                  If ( ( Options and exThisPd_vs_Budget ) = exThisPd_vs_Budget ) and
                    ( ExceedsBounds( Account, Actual, Comparitive )) then
                  Begin
                     PrintVariance( Account, 'This Period', 'This Period Budget', Actual, Comparitive, AcctSign);
                  end;

                  {  ----------------------------------------------------------  }
                  { Year to Date vs Last Year                                }
                  Actual      := mYTD_ActualOrBudget;
                  Comparitive := mYTD_LastYear;

                  If ( ( Options and exYTD_vs_LastYrYTD ) = exYTD_vs_LastYrYTD ) and
                     ( ExceedsBounds( Account, Actual, Comparitive)) then
                  Begin
                     PrintVariance( Account, 'YTD Actual', 'YTD Last Year', Actual, Comparitive, AcctSign);
                  end;

                  {  ----------------------------------------------------------  }
                  {  Year to Date vs Budgeted Year to Date                   }
                  Actual      := mYTD_ActualOrBudget;
                  Comparitive := mYTD_Budget;

                  If ( ( Options and exYTD_vs_BudgetYTD  ) = exYTD_vs_BudgetYTD  ) and
                     ( ExceedsBounds( Account, Actual, Comparitive ) ) then
                  Begin
                     PrintVariance( Account, 'YTD Actual', 'YTD Budget', Actual, Comparitive, AcctSign);
                  end;

                  {  ----------------------------------------------------------  }
                  RenderTextLine('');
               end;
            end;
         end;
      end;
      If ECount = 0 then RenderTitleLine( 'There were no exceptions to print');
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TExceptionsReportEx.Create(const ForClient: TClientObj);
begin
  inherited Create(RptOther);
  ClientForReport := ForClient;

  AccountInfo := TAccountInformation.Create( ForClient);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TExceptionsReportEx.Destroy;
begin
  AccountInfo.Free;
  inherited;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
