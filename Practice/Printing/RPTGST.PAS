unit RptGST;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//GST reports, except for 101 report
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
   UBatchBase, ReportDefs;

procedure DoGSTAudit(Dest: TReportDest;RptBatch: TReportBase = nil;
         DFrom : Integer = 0; DTo : Integer = 0);

procedure DoGSTSummary(Dest: TReportDest;RptBatch: TReportBase = nil;
         DFrom : Integer = 0; DTo : Integer = 0);

procedure DoGSTAllocationSummary(Dest : TReportDest;RptBatch : TReportBase = nil;
         DFrom : Integer = 0; DTo : Integer = 0);

procedure DoGSTReconciliation(Dest: TReportDest;RptBatch: TReportBase = nil;
         DFrom : Integer = 0; DTo : Integer = 0 );

procedure DoGSTOverrides(Dest: TReportDest;RptBatch: TReportBase = nil;
         DFrom : Integer = 0; DTo : Integer = 0);

procedure DoBusinessNorms(Dest: TReportDest;RptBatch : TReportBase = nil);

//******************************************************************************
implementation

uses
  ReportToCanvas,
  ReportTypes,
  Transactionutils,
  Classes, SysUtils,
  NewReportObj,
  RepCols,
  AccountInfoObj,
  //baObj32,
  CashflowRepDlg,
  CalculateAccountTotals,
  Globals,
  glConst,
  bkDefs,
  GSTUtil32,
  CodeDateDlg,
  YesNoDlg,
  NewReportUtils,
  stDatest,
  MoneyDef,
  bkConst,
  GenUtils,
  bkDateUtils,
  bkhelp,
  GSTCalc32,
  SignUtils,
  stDate,
  chList32, travList, clObj32, ECollect, baObj32,
  Math,
  Rptparams,
  UserReportSettings,
  InfoMoreFrm;


const
  FORMAT_AMOUNT = '#,##0.00;(#,##0.00);-';

type
  ATTypeSet = Set of Byte;
  TValuesArray = Array of Money; //dynamic array

type
  //report type is used by both the GST Audit Report and the GST Reconciliation report
  TGSTReport = class(TBKReport)
  protected
    D1,D2     : integer;
    SortOrder : Integer;
    GSTInfo   : TGSTInfo;
    GSTClass  : Integer;
    SomeEdits : boolean;
    Period    : Integer;
    RptParameters : TRptParameters;
  end;

  TGSTNonBaseCurrencyReport = class( TGSTReport)
  private
    NonBaseCurrency: Boolean;
  end;

  TGSTAuditReport = class( TGSTNonBaseCurrencyReport)
  private
    DoneHeader : boolean;
    AccountsPrinted : integer;
    PrintTitle : Boolean; //print the GST title?
    WrapNarration: Boolean;
    function GetGSTTitleLine(ClassNo, D1, D2: integer): string;
    procedure DoGAHeader(Sender : TObject);
  end;

  TGSTReconReport = class(TGSTReport)
  protected
    procedure GetValuesForPeriod(const pAcct: pAccount_Rec; const ForPeriod: integer; var Values: TValuesArray);
  end;


//------------------------------------------------------------------------------
procedure GstAllocationSummaryDetail(Sender : Tobject);

var
   I: Integer;
   lTotals: array [gtMin..gtMax] of Money;
   T, B: LongInt;
   Dissection: pDissection_Rec;
   FirstOne: Boolean;
   S,R: string;

   procedure DoHeader (  baFields : tBank_Account_Rec);
   begin
      FirstOne := false;
   end;

   const BoxLine = '...................';

begin
   with TGstReport(Sender),MyClient, MyClient.clFields, GSTInfo  do begin
      // Collect the totals...
      FillChar(ltotals,Sizeof(LTotals),0);
      for i := 1 to MAX_GST_CLASS do
         if guHasActivity[I]
         and (clGST_Class_Types[I] in [gtMin..gtMax]) then begin
            ltotals[clGST_Class_Types[I]] :=
              ltotals[clGST_Class_Types[I]] + guGross_Totals[I];

         end;
      // Print the top totals...
      RenderTitleLine('GST allocated entries');
      PutString( 'Total');
      PutMoney(lTotals[gtIncomeGST] + lTotals[gtExpenditureGST]
             + lTotals[gtZeroRated] + lTotals[gtExempt]);

      PutMoney(lTotals[gtIncomeGST]);
      PutMoney(lTotals[gtExpenditureGST]);
      PutMoney(lTotals[gtExempt]);
      PutMoney(lTotals[gtZeroRated]);
      RenderDetailLine;

      if guHasActivity[0]then begin
      /// Add the transactions...
      //LtoTals[0] := lTotals[1] + lTotals[2] + lTotals[3]+ lTotals[4];
      lTotals[gtUndefined] := 0;
      RenderTitleLine('Uncoded or GST unallocated entries');

      With clBank_Account_List do for B := 0 to Pred( ItemCount ) do
        With Bank_Account_At(B), baFields do
        begin
           //check correct journal accounts are being used, exclude stock and opening journals
           if (baFields.baAccount_Type in [btBank,btCashJournals,btGSTJournals]) or
                           ((baFields.baAccount_Type = btAccrualJournals) and (not clGST_Excludes_Accruals)) then

           begin
              FirstOne := true;
              With baTransaction_List do
                 For T := 0 to Pred( ItemCount ) do
                    With Transaction_At( T )^ do
                       if ( ( clGST_on_Presentation_Date ) and ( txDate_Presented >=D1 ) and ( txDate_Presented <=D2 ) )
                       OR ( ( not clGST_on_Presentation_Date ) and ( txDate_Effective >=D1 ) and ( txDate_Effective <=D2 ) ) then
                      begin
                         if IsAJournalAccount then guHasJournals := TRUE;
                            guWhichJournals[ baAccount_Type ] := TRUE;

                         if ( txFirst_Dissection = nil ) then
                         begin
                            if RptParameters.Chart.FindCode( txAccount ) = nil then begin

                            end;
                             RenderTextLine('');
                            if ( txGST_Class = 0) then begin
                               if FirstOne then DoHeader(baFields);

                               S := stDatetoDateString('dd/mm/yy', txDate_Effective,true);
                               {
                               if MyClient.clFields.clShort_Name[txType] > '' then
                                 S := S + ' ' + MyClient.clFields.clShort_Name[txType];
                               }
                               R := GetFormattedReference( Transaction_At( T ));
                               if R > '' then
                                  S := S + ' - ' + R;

                               if txGL_Narration > '' then
                                  S := S + ' - ' +txGL_Narration;

                               LtoTals[gtUndefined] := lTotals[gtUndefined] + txTemp_Base_Amount;

                               PutString(S);
                               PutMoney(txTemp_Base_Amount);

                               for I := 0 to 3 do PutString(BoxLine);

                               RenderDetailLine;
                            end;
                         end
                         else
                         begin
                            Dissection := txFirst_Dissection;
                            While ( Dissection<>nil ) do With Dissection^ do
                            begin
                               RenderTextLine('');
                               if RptParameters.Chart.FindCode( dsAccount )=nil then begin

                               end;

                               if ( dsGST_Class = 0) then
                               begin
                                 if FirstOne then DoHeader(baFields);
                                 S := stDatetoDateString('dd/mm/yy', txDate_Effective,true);
                                 if dsReference > '' then
                                    S := S + ' - ' + dsReference;
                                 if dsGL_Narration > '' then
                                    S := S + ' - ' + dsGL_Narration;
                                 PutString(s);
                                 LtoTals[gtUndefined] := lTotals[gtUndefined] + dsAmount;

                                 PutMoney(dsAmount);
                                 for I := 0 to 3 do PutString(BoxLine);

                                 RenderDetailLine;
                               end;
                               Dissection := dsNext;
                            end; { of While }
                         end;
                      end; //with
           end; //if account type ok
        end; //with

        RequireLines(6);

        SingleUnderLine;

        PutString('Unallocated Total');
        PutMoney(lTotals[gtUndefined]);
        for I := 0 to 3 do PutString(BoxLine);
        RenderDetailLine;

        RenderTitleLine('Check Total');
        DoubleUnderLine;

        PutString('Total');
        PutMoney(lTotals[gtUndefined] + lTotals[gtIncomeGST] + lTotals[gtExpenditureGST]
               + lTotals[gtZeroRated] + lTotals[gtExempt]);

        for I := 0 to 3 do PutString(BoxLine);
        RenderDetailLine;


      ////
      end else
         // No Uncoded, should just add...
         //RenderDetailGrandTotal('');
   end;
end;


//------------------------------------------------------------------------------
procedure GstSummaryDetail(Sender : Tobject);
var
   R1, R2   : Byte;
   i        : Integer;
   PC       : String[10];
begin
   with TGstReport(Sender),MyClient, MyClient.clFields, GSTInfo  do
   begin
     For i := 0 to MAX_GST_CLASS do If guHasActivity[ i ] then
     Begin
        If i > 0 then
        Begin
           PutString( clGST_Class_Codes[ i ]);

           R1 := WhichGSTRateApplies( MyClient, D1 );
           R2 := WhichGSTRateApplies( MyClient, D2 );

           If ( R1=R2 ) then
           Begin
              If R1=0 then
              Begin
                 PutString( clGST_Class_Names[i] + ' (0%)' );
              end
              else
              Begin
                 Str( clGST_Rates[i, R1]/10000.0:5:4, PC );
                 PutString( clGST_Class_Names[i] + ' ('+PC + '%)' );
              end
           end
           else
              PutString( clGST_Class_Names[i] );
        end
        else
        begin
           PutString('0');
           PutString('Unallocated' );
        end;

        PutMoney( guGross_Totals[i] );
        PutMoney( guGST_Totals[i] );
        PutMoney( guNet_Totals[i] );
        RenderDetailLine;
     end;
     RenderDetailGrandTotal('');
   end;
end;
// ----------------------------------------------------------------------------
procedure DoGSTSummary(Dest : TReportDest;RptBatch : TReportBase = nil;
         DFrom : Integer = 0; DTo : Integer = 0);
var
   GSTInfo  : TGSTinfo;
   Job : TGSTReport;
   Params : TRptParameters;
   Cleft: Double;
   TaxName : String;
   ISOCodes: string;
   NonBaseCurrency: Boolean;
Begin
   TaxName := MyClient.TaxSystemNameUC;
   NonBaseCurrency := False;
   Params := TRptParameters.Create(ord(Report_GST_Summary),MyClient,RptBatch,DPeriod);

   with Params do try
     if DFrom <> 0 then begin
         Fromdate := DFrom;
         Todate := DTo;
      end;
    repeat
      if batchRun
      or (DFrom <> 0) then
      else begin

         if not EnterPrintDateRange('Print ' + TaxName + ' Summary','Enter the starting and finishing dates for the period you want to print',
                                 Fromdate,Todate,
                                 BKH_GST_summary_report, true,Params, NonBaseCurrency) then exit;

         if (Params.RunBtn = BTN_SAVE) then begin
            SaveNodesettings;
            Exit;

         end;

         case Params.RunBtn of
           BTN_PRINT   : Dest := rdPrinter;
           BTN_PREVIEW : Dest := rdScreen;
           BTN_FILE    : Dest := rdFile;
           else Dest := rdAsk;
         end;
      end;

      // Still here... Run the report..

      //Check Forex - this will stop the report running if there are missing exchange rates
      if not MyClient.HasExchangeRates(ISOCodes, FromDate, ToDate, True, True) then begin
        HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' + ISOCodes + '.',0);
        Exit;
      end;

      GSTUTIL32.CalculateGSTTotalsForPeriod( Fromdate, Todate, GSTInfo, -1 );

      If (GSTInfo.guHasUncodes) and
         ( AskYesNo('Warning - Uncoded Entries', 'There are ' + inttostr(GSTInfo.guNumberUncoded) + ' UNCODED entries '+
                      'from ' + bkDate2Str( Fromdate )+' to ' + bkDate2Str( Todate ) +' which will '+
                      'affect the ' + TaxName + ' Summary Report.  Use F8 in the Code Entries Window to '+
                      'locate and code the UNCODED entries.'+#13#13+
                      'Do you want to print this Report with UNCODED entries?',
                      DLG_NO,0) <> DLG_YES )
                        then begin
                           Params.RunBtn := BTN_NONE;
                           exit;
                        end;

     Job := TGSTReport.Create(ReportTypes.RptGST);
     try
       Job.RptParameters := Params;
       Job.LoadReportSettings(UserPrintSettings,MakeRptName(Report_List_Names[REPORT_GST_SUMMARY]));

       //Add Headers
       AddCommonHeader(Job);

       AddJobHeader(Job,siTitle,TaxName + ' SUMMARY FROM '+ stDatetoDateString('dd nnn yy',Fromdate,true) + ' TO '+
                                                          stDatetoDateString('dd nnn yy',Todate,true),true);
       (*
       AddJobHeader(Job,siSubTitle,'',true);
       AddJobHeader(Job,siSubTitle,Client.clFields.clName,true);
       if Client.clFields.clAddress_L1 > '' then
          AddJobHeader(Job,siSubTitle,Client.clFields.clAddress_L1,true);
       if Client.clFields.clAddress_L2 > '' then
          AddJobHeader(Job,siSubTitle,Client.clFields.clAddress_L2,true);
       if Client.clFields.clAddress_L3 > '' then
          AddJobHeader(Job,siSubTitle,Client.clFields.clAddress_L3,true);
       *)
       AddJobHeader(Job,siSubTitle,'',true);

       cLeft := Gcleft;
       AddColAuto(Job,cLeft,       7,Gcgap,'Rate ID', jtLeft);
       AddColAuto(Job,cLeft,      30,Gcgap,'Description',jtLeft);
       AddFormatColAuto(Job,cLeft,18,Gcgap,'Gross Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
       AddFormatColAuto(Job,cLeft,18,Gcgap, TaxName + ' Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
       AddFormatColAuto(Job,cLeft,18,Gcgap,'Net Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);

       //Add Footers
       AddCommonFooter(Job);

       Job.GSTInfo := GSTInfo;
       Job.d1      := Fromdate;
       Job.d2      := Todate;
       Job.OnBKPrint := GSTSummaryDetail;
       Job.Generate(Dest,params);
     finally
      Job.Free;
     end;

   until RunExit(Dest)
   or (DFrom <>0);
   finally
      Params.Free;
   end;

end;


procedure DoGSTAllocationSummary(Dest : TReportDest;RptBatch : TReportBase = nil;
         DFrom : Integer = 0; DTo : Integer = 0);
var
   GSTInfo  : TGSTinfo;
   Job : TGSTReport;
   Params : TRptParameters;
   cLeft: Double;
   ISOCodes: string;
   NonBaseCurrency: Boolean;
const
  FORMAT_AMOUNT = '#,##0.00 DR;#,##0.00 CR';
Begin
   Params := TRptParameters.Create(ord(Report_GST_allocationSummary), MyClient,RptBatch,DPeriod);
   NonBaseCurrency := False;

   with Params do try
     if DFrom <> 0 then begin
         Fromdate := DFrom;
         Todate := DTo;
      end;
    repeat
      if batchRun
      or (DFrom <> 0) then
      else begin

         if not EnterPrintDateRange('Print GST Allocation Summary','Enter the starting and finishing dates for the period you want to print',
                                 Fromdate,Todate,
                                 BKH_GST_summary_report, true,Params, NonBaseCurrency) then exit;

          if (Params.RunBtn = BTN_SAVE) then begin
            SaveNodesettings;
            Exit
         end;
         {if (Dest = rdNone)
         or Batchsetup then}
         case Params.RunBtn of
           BTN_PRINT   : Dest := rdPrinter;
           BTN_PREVIEW : Dest := rdScreen;
           BTN_FILE    : Dest := rdFile;
           else Dest := rdAsk;
         end;
      end;

      // Still here... Run the report..

     //Check Forex - this will stop the report running if there are missing exchange rates
     if not MyClient.HasExchangeRates(ISOCodes, FromDate, ToDate, True, True) then begin
       HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' + ISOCodes + '.',0);
       Exit;
     end;

     GSTUTIL32.CalculateGSTTotalsForPeriod( Fromdate, Todate, GSTInfo, -1 );
           { //Expect uncoded..
      If (GSTInfo.guHasUncodes) and
         ( AskYesNo('Warning - Uncoded Entries', 'There are ' + inttostr(GSTInfo.guNumberUncoded) + ' UNCODED entries '+
                      'from ' + bkDate2Str( Fromdate )+' to ' + bkDate2Str( Todate ) +' which will '+
                      'affect the GST Summary Report.  Use F8 in the Code Entries Window to '+
                      'locate and code the UNCODED entries.'+#13#13+
                      'Do you want to print this Report with UNCODED entries?',
                      DLG_NO,0) <> DLG_YES )
                        then exit;
            }

     Job := TGSTReport.Create(ReportTypes.rptGst);
     try
       Job.RptParameters := Params;
       Job.LoadReportSettings(UserPrintSettings,MakeRptName(Report_List_Names[REPORT_GST_ALLOCATIONSUMMARY]));

       //Add Headers
       AddCommonHeader(Job);

       AddJobHeader(Job,siTitle,'GST ALLOCATION SUMMARY FROM '+ stDatetoDateString('dd nnn yy',Fromdate,true) + ' TO '+
                                                          stDatetoDateString('dd nnn yy',Todate,true),true);
       (*
       AddJobHeader(Job,siSubTitle,'',true);
       AddJobHeader(Job,siSubTitle,Client.clFields.clName,true);
       if Client.clFields.clAddress_L1 > '' then
          AddJobHeader(Job,siSubTitle,Client.clFields.clAddress_L1,true);
       if Client.clFields.clAddress_L2 > '' then
          AddJobHeader(Job,siSubTitle,Client.clFields.clAddress_L2,true);
       if Client.clFields.clAddress_L3 > '' then
          AddJobHeader(Job,siSubTitle,Client.clFields.clAddress_L3,true);
       *)
       AddJobHeader(Job,siSubTitle,'',true);

       cLeft := GCleft;
       AddColAuto(Job,cLeft,      34,Gcgap,' ',jtLeft).CaptionLine2 := 'Description';
       AddFormatColAuto(Job,cLeft,12,Gcgap,'Total',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true).CaptionLine2 := 'or Entry';;
       AddFormatColAuto(Job,cLeft,12,Gcgap,' ',jtRight,FORMAT_AMOUNT, MyClient.FmtDrCrStr, true).CaptionLine2 := 'Income';
       AddFormatColAuto(Job,cLeft,12,Gcgap,' ',jtRight,FORMAT_AMOUNT, MyClient.FmtDrCrStr, true).CaptionLine2 := 'Expenditure';
       AddFormatColAuto(Job,cLeft,12,Gcgap,' ',jtRight,FORMAT_AMOUNT, MyClient.FmtDrCrStr, true).CaptionLine2 := 'Exempt';
       AddFormatColAuto(Job,cLeft,12,Gcgap,' ',jtRight,FORMAT_AMOUNT, MyClient.FmtDrCrStr, true).CaptionLine2 := 'Zero Rated';
       //Add Footers
       AddCommonFooter(Job);

       Job.GSTInfo := GSTInfo;
       Job.d1      := Fromdate;
       Job.d2      := Todate;
       Job.OnBKPrint := GSTAllocationSummaryDetail;
       Job.Generate(Dest,params);
     finally
      Job.Free;
     end;

   until RunExit(Dest)
   or (DFrom <>0);
   finally
      Params.Free;
   end;

end;
// ----------------------------------------------------------------------------
procedure GstReconciliationDetail(Sender : Tobject);
const
  PERIOD_MAX = 12;
var
  i, PeriodNo : Integer;
  R1, R2 : Byte;
  PC : String[10];
  pAcct : pAccount_Rec;
  PeriodStartDate, PeriodEndDate : array[1..12] of LongInt;
  ValuesArray  : TValuesArray;
  Values, Total : array[1..PERIOD_MAX+1] of Money;
  YTDValue : Money;
  PrintMe : boolean;
  MaxPeriods: Integer;
begin
  with TGSTReconReport(Sender) do
  begin
    SetLength(ValuesArray, 1);  //no need to nil this afterward
                                 //delphi will handle it through
                                 //reference counting

    MaxPeriods := Max(MyClient.clFields.clTemp_Periods_This_Year, MyClient.clFields.clTemp_Periods_Last_Year);
    MaxPeriods := Ceil(MyClient.clFields.clTemp_FRS_Last_Period_To_Show/Floor(12/MaxPeriods));
    for i := 1 to MaxPeriods+1 do
    begin
      Total[i] := 0.00;
    end;

    RenderTitleLine('GST Payable/(Receivable)');

    For i := 1 to MAX_GST_CLASS do
    begin
      if (MyClient.clFields.clGST_Class_Codes[ i ] <> '') then
      begin
        for PeriodNo := 1 to MaxPeriods do
        begin
          if PeriodNo <= MyClient.clFields.clTemp_Periods_This_Year then begin
            PeriodStartDate[PeriodNo] := MyClient.clFields.clTemp_Period_Details_This_Year[PeriodNo].Period_Start_Date;
            PeriodEndDate[PeriodNo]   := Min(MyClient.clFields.clTemp_Period_Details_This_Year[PeriodNo].Period_End_Date, D2);
          end
          else begin
            PeriodStartDate[PeriodNo] := MyClient.clFields.clTemp_Period_Details_Last_Year[PeriodNo].Period_Start_Date;
            PeriodEndDate[PeriodNo]   := Min(MyClient.clFields.clTemp_Period_Details_Last_Year[PeriodNo].Period_End_Date, D2);
          end;
          Values[PeriodNo] := 0;
        end;
        Values[MaxPeriods+1] := 0;

        Calculate12MthGSTTotals(PeriodStartDate, PeriodEndDate, Values, i, MyClient.clFields.clTemp_FRS_Division_To_Use);

        YTDValue := 0.00;
        for PeriodNo := 1 to MaxPeriods do
          if (PeriodNo <= Period) then
            YTDValue := YTDValue + Values[PeriodNo];

        if (YTDValue <> 0.00) then
        begin
          PutString( MyClient.clFields.clGST_Class_Codes[ i ]);

          R1 := WhichGSTRateApplies( MyClient, D1 );
          R2 := WhichGSTRateApplies( MyClient, D2 );

          If ( R1=R2 ) then
          Begin
            If R1=0 then
            Begin
              PutString( MyClient.clFields.clGST_Class_Names[i] + ' (0%)' );
            end
            else
            Begin
              Str( MyClient.clFields.clGST_Rates[i, R1]/10000.0:5:4, PC );
              PutString( MyClient.clFields.clGST_Class_Names[i] + ' ('+PC + '%)' );
            end
          end
          else
            PutString( MyClient.clFields.clGST_Class_Names[i] );

          for PeriodNo := 1 to MaxPeriods do
          begin
            if (PeriodNo <= Period) then
            begin
              PutMoney( Values[PeriodNo], Credit );
              Total[PeriodNo] := Total[PeriodNo] + Values[PeriodNo];
            end else
              PutMoney( 0.00, Credit );
          end;
          PutMoney( YTDValue, Credit );
          Total[MaxPeriods+1] := Total[MaxPeriods+1] + YTDValue;

          RenderDetailLine;
        end;
      end;
    end;


    SingleUnderLine;
    PutString('');
    PutString('Total');
    for PeriodNo := 1 to MaxPeriods+1 do
    begin
      PutMoney(Total[PeriodNo], Credit)
    end;
    RenderDetailLine(True,siSectiontotal);;
    DoubleUnderLine;


    for i := 1 to MaxPeriods+1 do
    begin
      Total[i] := 0.00;
    end;

    RenderTitleLine('GST Payment/(Refund)');

    for i := 0 to Pred( RptParameters.Chart.ItemCount) do begin
      pAcct := RptParameters.Chart.Account_At(i);

      if ( pAcct^.chAccount_Type in [ atGSTPayable, atGSTReceivable]) then //and ( pAcct^.chTemp_Include_In_Report) then
      begin
        //decide if we need to show this account
        PrintMe := false;
        for PeriodNo := 1 to MaxPeriods do
        begin
          if (PeriodNo <= Period) then
          begin
            GetValuesForPeriod( pAcct, PeriodNo, ValuesArray);
            if ValuesArray[0] <> 0 then
              PrintMe := true;
          end;
        end;

        if PrintMe then
        begin
          PutString(pAcct^.chAccount_Code);
          PutString(pAcct^.chAccount_Description);
          YTDValue := 0.00;
          for PeriodNo := 1 to MaxPeriods do
          begin
            if (PeriodNo <= Period) then
            begin
              GetValuesForPeriod( pAcct, PeriodNo, ValuesArray);
              PutMoney( ValuesArray[0], Debit);
              YTDValue := YTDValue + ValuesArray[0];
              Total[PeriodNo] := Total[PeriodNo] + ValuesArray[0];
            end else
              PutMoney( 0.00, Debit);
          end;
          PutMoney( YTDValue, Debit );
          Total[MaxPeriods+1] := Total[MaxPeriods+1] + YTDValue;
          RenderDetailLine;
        end;
      end;
    end;


    SingleUnderLine;
    PutString('');
    PutString('Total');
    for PeriodNo := 1 to MaxPeriods+1 do
    begin
      PutMoney(Total[PeriodNo], Debit)
    end;
    RenderDetailLine(True,siSectiontotal);;
    DoubleUnderLine;
  end;
end;
// ----------------------------------------------------------------------------
procedure DoGSTReconciliation(Dest : TReportDest;RptBatch : TReportBase = nil;
         DFrom : Integer = 0; DTo : Integer = 0);
var
   Title  : String;
   i : integer;
   //D1, D2   : LongInt;
   GSTInfo  : TGSTinfo;
   Job : TGSTReconReport;
   PeriodEndDate   : integer;
   PeriodStartDate : integer;
   cWidth : double;
   cLeft : double;
   S : string;
   D, M, Y: Integer;
   Params : TProfitRptParameters;
   MaxPeriods: Integer;
   aColumn : TReportColumn;
   ISOCodes: string;
begin
   Params := TProfitRptParameters.Create(ord(Report_GST_Summary_12),MyClient,RptBatch,DYear);
   with Params do try
      if DFrom <> 0 then begin
         Fromdate := DFrom;
         Todate := DTo;
      end;
      repeat

      if batchRun
      or (DFrom <> 0) then
      else begin

         Title := 'GST Reconciliation';
         if not GetFYearParameters(Title,
             params, BKH_GST_reconciliation_report, False, False, False, True) then exit;

         case Runbtn of
         BTN_PRINT : Dest := rdPrinter;
         BTN_PREVIEW : Dest := rdScreen;
         BTN_FILE : Dest := rdFile;
         BTN_SAVE : Continue;
         else Dest := rdAsk;
         end;
     end;
     // Run the report..
     with Client, clFields do begin
        //clReporting_Year_Starts set by GetFYearParameters
     clFRS_Reporting_Period_Type               := Params.PeriodType; //frpMonthly;
     clGST_Inclusive_Cashflow                  := ShowGST;

     //now set temporary client variables
     clTemp_FRS_Account_Totals_Cash_Only       := true;
     clTemp_FRS_Last_Period_To_Show            := Period;
     clTemp_FRS_Last_Actual_Period_To_Use      := clTemp_FRS_Last_Period_To_Show;
     clTemp_FRS_From_Date                      := 0;
     clTemp_FRS_To_Date                        := 0;
     clTemp_FRS_Job_To_Use                     := '';
     clTemp_FRS_Division_To_Use                := Division;
     clTemp_FRS_Budget_To_Use                  := '';
     clTemp_FRS_Budget_To_Use_Date             := -1;
     clTemp_FRS_Use_Budgeted_Data_If_No_Actual := False;

     //verify parameters
     Assert( clReporting_Year_Starts > 0,
             'clReporting_Year_Starts > 0');
     //Non-persistant fields
//     Assert( clTemp_FRS_Last_Period_To_Show in [0..pdMaximumNoOfPeriods[ clFRS_Reporting_Period_Type]],
//             'clTemp_FRS_Last_Period_To_Show in [0..pdMaximumNoOfPeriods[ clFRS_Reporting_Period_Type]]');
     Assert( clTemp_FRS_Division_To_Use in [ 0..Max_Divisions],
             'clTemp_FRS_Division_To_Use in [ 0..Max_Divisions]');

     FlagAllAccountsForUse( MyClient);

     //Check Forex - this will stop the report running if there are missing exchange rates
     if not MyClient.HasExchangeRates(ISOCodes, FromDate, ToDate, True, False) then begin
       HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' + ISOCodes + '.',0);
       Continue;
     end;

     CalculateAccountTotals.CalculateAccountTotalsForClient( MyClient, False, nil, ToDate);

     //D1 := FromDate;
     //D2 := IncDate(Fromdate, 0, Period, 0);

     Job := TGSTReconReport.Create(ReportTypes.rptGst);
     try
       Job.RptParameters := Params;
       Job.LoadReportSettings(UserPrintSettings,MakeRptName(Report_List_Names[REPORT_GST_SUMMARY_12]));
       if clFRS_Reporting_Period_Type in [frpMonthly, frp2Monthly] then
         Job.UserReportSettings.s7Orientation := BK_LANDSCAPE
       else
         Job.UserReportSettings.s7Orientation := BK_PORTRAIT;
       //Add Headers
       AddCommonHeader(Job);
       StDateToDMY(Todate, D, M, Y);
       D := DaysInMonth(M, Y, BKDATEEPOCH);
       AddJobHeader(Job,siTitle,'GST RECONCILIATION from ' +
         bkDateUtils.GetDateRangeS(FromDate,Todate),True);


       if ( clTemp_FRS_Division_To_Use in [1..glConst.Max_Divisions]) then begin
         s := 'For Division: ' + clCustom_Headings_List.Get_Division_Heading( clTemp_FRS_Division_To_Use);
         AddJobHeader(Job,jtCenter,1.1,S,true);
       end;

       AddJobHeader(Job,siSubTitle,'',true);
       AddJobHeader(Job,siSubTitle,'',true);

        //Find number of periods
       MaxPeriods := Max(clTemp_Periods_This_Year, clTemp_Periods_Last_Year);
       MaxPeriods := Ceil(clTemp_FRS_Last_Period_To_Show/Floor(12/MaxPeriods));
       case MaxPeriods of
       1..2 : cWidth := 50;
       3..4 : cWidth := 40;
       5..6 : cWidth := 30;
       else  cWidth := 14;
       end;

       cLeft := GcLeft;
       if clFRS_Reporting_Period_Type = frpMonthly then
       begin
        AddColAuto(Job,cLeft,4,Gcgap,'Code', jtLeft);
        AddColAuto(Job,cLeft,cWidth,Gcgap,'Description',jtLeft);
       end
       else
       begin
         //if we're not doing monthly periods then there will be two lines for the headings
         //so the heading caption should be on the 2nd line so that it's underlined (Case 10951)
         aColumn := AddColAuto(Job,cLeft,4,Gcgap,'', jtLeft);
         aColumn.CaptionLine2 := 'Code';
         aColumn := AddColAuto(Job,cLeft,cWidth,Gcgap,'',jtLeft);
         aColumn.CaptionLine2 := 'Description';
       end;


       //Work out width of columns (max width 20)
       cWidth := ( (99.5 - cLeft) / (MaxPeriods + 1)) - GcGap;
       if (cWidth > 25) then
         cWidth := 25;

       //Add period columns
       for i := 1 to MaxPeriods{( Job.iVisiblePeriods)} do begin

         //get period dates, there is a chance that the no of periods in each
         //year may be different, so need to make sure we are getting dates
         //for the correct period
         if i <= clTemp_Periods_This_Year then
         begin
            PeriodStartDate := clTemp_Period_Details_This_Year[i].Period_Start_Date;
            PeriodEndDate   := Min(clTemp_Period_Details_This_Year[i].Period_End_Date, Todate);
         end
         else
         begin
            PeriodStartDate := clTemp_Period_Details_Last_Year[i].Period_Start_Date;
            PeriodEndDate   := Min(clTemp_Period_Details_Last_Year[i].Period_End_Date, Todate);
         end;

         aColumn := AddFormatColAuto(Job,cLeft,cWidth,GcGap,'Date',jtRight,'#,##0;(#,##0);-','#,##0;(#,##0);-',true);
         if clFRS_Reporting_Period_Type = frpMonthly then
             aColumn.Caption      := StDatetoDateString('nnn yyyy', PeriodEndDate,true)
         else
         begin
            //if we're not doing monthly periods then there will be two lines for the headings
            //so the heading caption should be on the 2nd line so that it's underlined (Case 10951)
             aColumn.Caption      := StDatetoDateString('nnn yyyy', PeriodStartDate,true) + '-';
             aColumn.CaptionLine2 := StDatetoDateString('nnn yyyy', PeriodEndDate,true);
         end;
       end;
       if clFRS_Reporting_Period_Type = frpMonthly then
       begin
        AddFormatColAuto(Job,cLeft,cWidth,GcGap,'YTD',jtRight,'#,##0;(#,##0);-','#,##0;(#,##0);-',true);
       end
       else
       begin
        aColumn := AddFormatColAuto(Job,cLeft,cWidth,GcGap,'',jtRight,'#,##0;(#,##0);-','#,##0;(#,##0);-',true);
        aColumn.CaptionLine2 := 'YTD';
       end;

       //Add Footers
       AddCommonFooter(Job);

       Job.GSTInfo := GSTInfo;
       Job.d1      := Fromdate;
       Job.d2      := Todate;
       Job.Period  := Period;
       Job.OnBKPrint := GstReconciliationDetail;
       Job.Generate(Dest,params);
     finally
      Job.Free;
     end;
   end;
   until RunExit(Dest)
   or (DFrom <> 0);
   finally
     Params.Free;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
function TGSTAuditReport.GetGSTTitleLine( ClassNo : integer;
                          D1 : integer;
                          D2 : integer)  : string;
var
   R1, R2   : Byte;
   TempS    : string;
   PC       : String[10];
begin
  with MyClient, MyClient.clFields do begin
     If ClassNo > 0 then
     Begin
        TempS := clGST_Class_Codes[ ClassNo ] +' ';
        R1 := WhichGSTRateApplies( MyClient, D1 );
        R2 := WhichGSTRateApplies( MyClient, D2 );
        If ( R1=R2 ) then
        Begin
           If R1=0 then
           Begin
              TempS := TempS + ' ' + clGST_Class_Names[ClassNo] + ' (0%)';
           end
           else
           Begin
              Str( clGST_Rates[ClassNo, R1]/10000.0:5:4, PC );
              TempS := TempS + ' ' + clGST_Class_Names[ClassNo] + ' ('+PC + '%)';
           end;
        end
        else
           TempS := TempS + ' ' + clGST_Class_Names[ClassNo];
     end
     else
        TempS := TaxSystemNameUC + ' Class 0 : Unallocated';
  end;
  result := TempS;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// print the account heading for the current account,
// do a page break if specified in ini
//
procedure TGSTAuditReport.DoGAHeader(Sender : TObject);
var
  Mgr : TTravManagerWithNewReport;
  ShowTitle : Boolean;
  S : string;
begin
  Mgr := TTravManagerWithNewReport(Sender);

  if (ReportTypeParams.NewPageforAccounts) then
  begin
    if (TGSTAuditReport( Mgr.ReportJob).AccountsPrinted > 0) then
      ReportNewPage;
    //print the GST title once on each page
    ShowTitle := True;
  end else
  begin
    //only print the GST title once for each class
    ShowTitle := PrintTitle;
  end;

  if (ShowTitle) then
  begin
    with TGSTAuditReport( Mgr.ReportJob) do
      RenderTitleLine( GetGSTTitleLine( GSTClass, D1, D2));
  end;

  S := 'Account ' + Mgr.Bank_Account.baFields.baBank_Account_Number +
       ': ' + Mgr.Bank_Account.AccountName;

  Mgr.ReportJob.RenderTitleLine( S);
  PrintTitle := False;
  DoneHeader := True;
end;
// ----------------------------------------------------------------------------
//
//on enter bank account
//
procedure GA_EnterAccount(Sender : TObject);
var
  Mgr : TTravManagerWithNewReport;
begin
  Mgr := TTravManagerWithNewReport(Sender);
  TGSTAuditReport(Mgr.ReportJob).DoneHeader := False;
end;
// ----------------------------------------------------------------------------
//
//on exit bank account
//
procedure GA_ExitAccount(Sender : TObject);
var
  Mgr : TTravManagerWithNewReport;
begin
  Mgr := TTravManagerWithNewReport(Sender);

  with TGSTAuditReport(Mgr.ReportJob) do
  begin
    if DoneHeader then
    begin
      RenderTextLine('');
      RenderDetailSectionTotal('');
      Inc(AccountsPrinted);
    end;
  end;
end;
// ----------------------------------------------------------------------------
procedure PutNarration(ReportJob: TBKReport; Notes: string);
var
  j, ColWidth, OldWidth : Integer;
  ColsToSkip : integer;
  NotesList  : TStringList;
  MaxNotesLines: Integer;
begin
  with TGSTAuditReport(ReportJob) do
  begin
   if WrapNarration then
     MaxNotesLines := 10
   else
     MaxNotesLines := 1;
   if (Notes = '') then
     SkipColumn
   else
   begin
     NotesList := TStringList.Create;
     try
       NotesList.Text := Notes;
       // Remove blank lines
       j := 0;
       while j < NotesList.Count do
       begin
         if NotesList[j] = '' then
           NoteSList.Delete(j)
         else
           Inc(j);
       end;
       if NotesList.Count = 0 then
       begin
         SkipColumn;
         Exit;
       end;
       ColsToSkip := CurrDetail.Count;
       j := 0;
       repeat
         ColWidth := RenderEngine.RenderColumnWidth(CurrDetail.Count, NotesList[ j]);
         if (ColWidth < Length(NotesList[j])) then
         begin
           //line needs to be split
           OldWidth := ColWidth; //store
           while (ColWidth > 0) and (NotesList[j][ColWidth] <> ' ') do
             Dec(ColWidth);
           if (ColWidth = 0) then
             ColWidth := OldWidth; //unexpected!
           NotesList.Insert(j + 1, Copy(NotesList[j], ColWidth + 1, Length(NotesList[j]) - ColWidth + 1));
           NotesList[j] := Copy(NotesList[j], 1, ColWidth);
         end;
         PutString( NotesList[ j]);
         Inc( j);
         //decide if need to call renderDetailLine
         if ( j < notesList.Count) and ( j < MaxNotesLines) then
         begin
           RenderDetailLine;
           //skip all other fields (reuse ColWidth)
           for ColWidth := 1 to ColsToSkip do
             SkipColumn;
         end;
       until ( j >= NotesList.Count) or ( j >= MaxNotesLines);
     finally
        NotesList.Free;
     end;
   end;
  end;
end;
// ----------------------------------------------------------------------------
//
//note: this routine is not called for dissected entries if the sort order
//      is by account
//
procedure GA_EnterEntry(Sender: TObject);
var
  Mgr : TTravManagerWithNewReport;
  Edited : Boolean;
  GST : Money;
  S : String;
  pAcct : pAccount_Rec;
  GST_Class: Byte;
  Chart: TCustomSortChart;
begin
  Mgr := TTravManagerWithNewReport(Sender);
  Chart := TGSTAuditReport(Mgr.ReportJob).RptParameters.Chart;

  with Mgr.Transaction^ do
  begin
    if ( txFirst_Dissection = nil) then
    begin
      if ( txGST_Class = TGSTAuditReport(Mgr.ReportJob).GSTClass ) then
      begin { It's what we want }
        if not TGSTAuditReport(Mgr.ReportJob).DoneHeader then
          TGSTAuditReport(Mgr.ReportJob).DoGAHeader( Sender);

        { Print the Entry }
        If MyClient.clFields.clGST_on_Presentation_Date then
           GST := CalculateGSTForClass( MyClient, txDate_Presented, txTemp_Base_Amount, txGST_Class )
        else
           GST := CalculateGSTForClass( MyClient, txDate_Effective, txTemp_Base_Amount, txGST_Class );
        Edited := ( GST <> txGST_Amount );

        if not Edited then // Also check to see if class has been edited
        begin
          GST_Class :=  Chart.GSTClass(txAccount);
          Edited := (GST_Class > 0) and (txGST_Class <> GST_Class);
        end;

        If MyClient.clFields.clGST_on_Presentation_Date then
           S := bkDate2Str ( txDate_Presented )
        else
           S := bkDate2Str ( txDate_Effective ) ;

        If Edited then
        Begin
           S := S + '*';
           TGSTAuditReport(Mgr.ReportJob).SomeEdits := TRUE;
        end;

        with Mgr.ReportJob do
        begin
          PutString( S );
          PutString( GetFormattedReference( Mgr.Transaction));

          pAcct := Chart.FindCode( txAccount);
          if Assigned( pAcct) then begin
            S := Trim( pAcct^.chAccount_Code) + '  ' + Trim( pAcct^.chAccount_Description);
          end
          else
            S := txAccount;
          PutString( S );

          if TGSTAuditReport(Mgr.ReportJob).NonBaseCurrency then
            if (txGST_Amount <> 0) and (Mgr.Bank_Account.IsAForexAccount) then
              PutMoney( txAmount )
            else
              PutString( '-' );

          PutMoney( txTemp_Base_Amount );
          PutMoney( txGST_Amount );
          PutMoney( txTemp_Base_Amount - txGST_Amount );
          PutNarration(Mgr.ReportJob, txGL_Narration);

          RenderDetailLine;
        end;
      end;
    end;
  end;
end;
// ----------------------------------------------------------------------------
procedure GA_ExitEntry(Sender :TObject);
//var
//  Mgr : TTravManagerWithNewReport;
begin
//  Mgr := TTravManagerWithNewReport(Sender);
end;
// ----------------------------------------------------------------------------
//
//on enter dissection
//
procedure GA_EnterDissect(Sender : Tobject);
var
  Mgr : TTravManagerWithNewReport;
  Edited : Boolean;
  GST : Money;
  S : String;
  pAcct : pAccount_Rec;
  GST_Class: Byte;
  Chart: TCustomSortChart;
begin
  Mgr := TTravManagerWithNewReport(Sender);
  Chart := TGSTAuditReport(Mgr.ReportJob).RptParameters.Chart;

  with Mgr.Transaction^, Mgr.Dissection^ do
  begin
    If ( dsGST_Class = TGSTAuditReport(Mgr.ReportJob).GSTClass ) then
    begin
      if not TGSTAuditReport(Mgr.ReportJob).DoneHeader then
        TGSTAuditReport(Mgr.ReportJob).DoGAHeader( Sender);

      { Print the Entry }

      If MyClient.clFields.clGST_on_Presentation_Date then
         GST := CalculateGSTForClass( MyClient, txDate_Presented, dsTemp_Base_Amount, dsGST_Class )
      else
         GST := CalculateGSTForClass( MyClient, txDate_Effective, dsTemp_Base_Amount, dsGST_Class );
      Edited := ( GST <> dsGST_Amount );

      if not Edited then // Also check to see if class has been edited
      begin
        GST_Class := Chart.GSTClass(dsAccount);
        Edited := (GST_Class > 0) and (dsGST_Class <> GST_Class);
      end;

      if MyClient.clFields.clGST_on_Presentation_Date then
        S := bkDate2Str ( txDate_Presented )
      else
        S := bkDate2Str ( txDate_Effective ) ;

      if Edited then
      Begin
        S := S + '*';
        TGSTAuditReport(Mgr.ReportJob).SomeEdits := TRUE;
      end;

      // mark dissection
      if not Mgr.Bank_Account.IsAJournalAccount then
        S := S + ' [D]';

      with Mgr.ReportJob do
      begin
        PutString( S );
        PutString(getDsctReference (Mgr.Dissection, Mgr.Transaction, 0));

        pAcct := Chart.FindCode( dsAccount);
        if Assigned( pAcct) then begin
          S := Trim( pAcct^.chAccount_Code) + '  ' + Trim( pAcct^.chAccount_Description);
        end
        else
          S := dsAccount;
        PutString( S);

        if TGSTAuditReport(Mgr.ReportJob).NonBaseCurrency then
          if (dsGST_Amount <> 0) and (Mgr.Bank_Account.IsAForexAccount) then
            PutMoney( dsAmount )
          else
            PutString( '-' );

        PutMoney( dsTemp_Base_Amount );
        PutMoney( dsGST_Amount );
        PutMoney( dsTemp_Base_Amount - dsGST_Amount );
        PutNarration(Mgr.ReportJob, dsGL_Narration );
        RenderDetailLine;
      end;
    end;
  end;
end;
// ----------------------------------------------------------------------------
procedure GSTAuditDetail(Sender : TObject);
var
  TravMgr : TTravManagerWithNewReport;
  AccountSet : TAccountTypeSet;
  i : Integer;
  TaxName : String;
begin
  TaxName := MyClient.TaxSystemNameUC;
  TravMgr := TTravManagerWithNewReport.Create;
  try
    TravMgr.Clear;
    TravMgr.ReportJob := TGSTAuditReport(Sender);
    TravMgr.SelectionCriteria := TravList.twAllEntries;

    TravMgr.OnEnterAccount    := GA_EnterAccount;
    TravMgr.OnExitAccount     := GA_ExitAccount;
    TravMgr.OnEnterEntry      := GA_EnterEntry;
    TravMgr.OnExitEntry       := GA_ExitEntry;
    TravMgr.OnEnterDissection := GA_EnterDissect;

    TGSTAuditReport(Sender).AccountsPrinted := 0;
    TGSTAuditReport(Sender).DoneHeader      := False;

    if (TGSTAuditReport(Sender).SortOrder = 0) then
    begin
       //date order
       if (MyClient.clFields.clGST_on_Presentation_Date) then
          TravMgr.SortType := csDatePresented
       else
          TravMgr.SortType := csDateEffective;
    end else begin
       TravMgr.SortType := csAccountCode;
       if (MyClient.clFields.clGST_on_Presentation_Date) then
          TravMgr.UseDatePresented := True;
    end;
    with TGSTAuditReport(Sender),MyClient, MyClient.clFields, GSTInfo  do
    begin
      SomeEdits := FALSE;

      if clGST_Excludes_Accruals then
        AccountSet := [ btBank, btCashJournals, btGSTJournals]
      else
        AccountSet := [ btBank, btCashJournals, btGSTJournals, btAccrualJournals];

      for i := 0 to MAX_GST_CLASS do
        //loop over gst classes
        if guHasActivity[ i ] then
        begin
          TGSTAuditReport(TravMgr.ReportJob).GSTClass := i;
          PrintTitle := True; //print the GST title for this class
          TravMgr.TraverseAllAccounts(D1, D2, AccountSet);
          RenderTextLine('');
          RenderDetailSubTotal('');
        end;
        RenderDetailGrandTotal('');

        if SomeEdits then
           RenderTextLine('Note: An asterisk "*" next to the date indicates that either the ' + TaxName + ' class or the ' + TaxName + ' amount has been edited' );
    end;
  finally
    TravMgr.Free;
  end;
end;
// ----------------------------------------------------------------------------
procedure DoGSTAudit(Dest : TReportDEst;RptBatch : TReportBase = nil;
         DFrom : Integer = 0; DTo : Integer = 0);
var
   SortOrder : Integer;
   GSTInfo  : TGSTinfo;
   Job : TGSTAuditReport;
   WrapNarration: Boolean;
   NonBaseCurrency: Boolean;
   Params : TRptParameters;
   s : string;
   cLeft: Double;
   TaxName, ISOCodes : String;
Begin
   TaxName := MyClient.TaxSystemNameUC;

   Params := TRptParameters.Create(ord(Report_GST_Audit),MyClient,RptBatch,DPeriod);

   with params do try
      if DFrom <> 0 then begin
         Fromdate := DFrom;
         Todate := DTo;
      end;
      WrapNarration := GetBatchBool('Wrap_Narration',false);
      NonBaseCurrency := GetBatchBool('Non_Base_Currency',false);
      s := GetBatchText('Sort','Date');
      if Sametext(S,'Account') then SortOrder := 1
      else SortOrder := 0;

      repeat
         if batchRun
         or (DFrom <> 0) then begin
         end else begin


            if not EnterPrintDateRangeOptions('Print '+TaxName+' Audit Trail',
              'Enter the starting and finishing dates for the period you want to print',
              FromDate,Todate,BKH_GST_audit_trail_report, true,
              ['&Date order', '&Account code order'], SortOrder, Params,
              WrapNarration, NonBaseCurrency, True, MyClient.HasForeignCurrencyAccounts) then exit;

            if Params.BatchSave then begin
                SaveNodeSettings;
                if SortOrder  = 0 then SetBatchText('Sort','Date')
                else SetBatchText('Sort','Account');
                SetBatchBool('Wrap_Narration',WrapNarration);
                SetBatchBool('Non_Base_Currency',NonBaseCurrency);
                Exit;
            end;

            {if (Dest = rdNone)
            or Batchsetup then}
            case Params.RunBtn of
            BTN_PRINT : Dest := rdPrinter;
            BTN_PREVIEW : Dest := rdScreen;
            BTN_FILE    : Dest := rdFile;
            else Dest := rdAsk;
            end;
         end;

         //Check Forex - this will stop the report running if there are missing exchange rates
         if not MyClient.HasExchangeRates(ISOCodes, FromDate, ToDate, True, True) then begin
           HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' + ISOCodes + '.',0);
           Exit;
         end;

         // Run The Report
         GSTUTIL32.CalculateGSTTotalsForPeriod(Fromdate, ToDate, GSTInfo, -1 );

         if (GSTInfo.guHasUncodes) then
           if BatchRun then
              RptBatch.RunResult := inttostr(GSTInfo.guNumberUncoded) + ' UNCODED entries'
           else if
         ( AskYesNo('Warning - Uncoded Entries', 'There are ' + inttostr(GSTInfo.guNumberUncoded) + ' UNCODED entries '+
                      'from ' + bkDate2Str( Fromdate )+' to ' + bkDate2Str( Todate ) +' which will '+
                      'affect the '+TaxName+' Audit Trail Report.  Use F8 in the Code Entries Window to '+
                      'locate and code the UNCODED entries.'+#13#13+
                      'Do you want to print this Report with UNCODED entries?',
                      DLG_NO,0) <> DLG_YES )then begin
                           Params.RunBtn := BTN_NONE;
                           exit;
                        end;


         with Client, clFields do Begin
         Job := TGSTAuditReport.Create(ReportTypes.rptGst);
         try
         Job.RptParameters := Params;
         Job.LoadReportSettings(UserPrintSettings,MakeRptName(Report_List_Names[Report_GST_Audit]));

         //Add Headers
         AddCommonHeader(Job);

         AddJobHeader(Job,siTitle,TaxName+' AUDIT TRAIL',true);
         AddJobHeader(Job,siSubTitle,'For the Period from '+ stDatetoDateString('dd nnn yy',FromDate,true) + ' TO '+
                                                          stDatetoDateString('dd nnn yy',Todate,true),true);
         AddJobHeader(Job,siSubTitle,'',true);
         (*
         AddJobHeader(Job,siSubTitle,clName,true);
         if clGST_Number > '' then
         case clFields.clCountry of
           whNewZealand : AddJobHeader(Job, siSubTitle, 'GST No: '+ clGST_Number,true);
           whAustralia  : AddJobHeader(Job, siSubTitle, 'ABN : '+ clGST_Number, true);
         end;
         if clAddress_L1 > '' then
            AddJobHeader(Job,siSubTitle,clAddress_L1,true);
         if clAddress_L2 > '' then
            AddJobHeader(Job,siSubTitle,clAddress_L2,true);
         if clAddress_L3 > '' then
            AddJobHeader(Job,siSubTitle,clAddress_L3,true);
         AddJobHeader(Job,siSubTitle,'',true);
         *)
         cLeft := GCLeft;
         AddColAuto(Job,cLeft,        9.0,GcGap, 'Date',jtLeft);
         AddColAuto(Job,cLeft,       10.4,GcGap,'Reference', jtLeft);
         AddColAuto(Job,cLeft,       20.0,GcGap,'Account',jtLeft);
         //Default to landscape when non-base currencies displayed
         if MyClient.HasForeignCurrencyAccounts and NonBaseCurrency then begin
           Job.UserReportSettings.s7Orientation := BK_LANDSCAPE;
           AddFormatColAuto(Job,cLeft, 9.5,GcGap,'Gross Non-base',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, false);
           AddFormatColAuto(Job,cLeft, 9.5,GcGap,'Gross Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
           AddFormatColAuto(Job,cLeft,  8.0,GcGap,TaxName+' Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
           AddFormatColAuto(Job,cLeft, 9.5,GcGap,'Net Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
           AddColAuto(Job,cLeft,       23.0,GcGap,'Narration',jtLeft);
         end else begin
           AddFormatColAuto(Job,cLeft, 10.5,GcGap,'Gross Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
           AddFormatColAuto(Job,cLeft,  9.0,GcGap,TaxName+' Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
           AddFormatColAuto(Job,cLeft, 10.5,GcGap,'Net Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
           AddColAuto(Job,cLeft,       25.0,GcGap,'Narration',jtLeft);
         end;

       //Add Footers
         AddJobFooter(Job,siFootNote, '[D] = Part of Dissected Entry', true);
         AddCommonFooter(Job);

         Job.GSTInfo := GSTInfo;
         Job.d1      := Params.FromDate;
         Job.d2      := Params.ToDate;
         Job.SortOrder := SortOrder;
         Job.WrapNarration := WrapNarration;
         Job.NonBaseCurrency := NonBaseCurrency;

         Job.OnBKPrint := GSTAuditDetail;
         Job.Generate(Dest, params);
         finally
           Job.Free;
         end;
       end;
   until RunExit(Dest)
   or (DFrom <> 0);

   finally
      Params.Free;
   end;
end;
//------------------------------------------------------------------------------
procedure GSTBusinessNormsDetail(Sender : TObject);
var
   FirstClass : boolean;

   //-------------------------------------------------------------------
   function GetGSTTitleLine( ClassNo : integer)  : string;
   begin
      with MyClient, MyClient.clFields do begin
         If ClassNo > 0 then begin
            result := 'GST Class '+ clGST_Class_Codes[ ClassNo ] + ' : ' + clGST_Class_Names[ClassNo];
         end
         else
            result := 'GST Class 0 : Unallocated';
      end;
   end;

   //-----------------------------------------------------------------
   procedure ShowCalculationFor( GST_Class : Byte );
   var
      c          : integer;
      s          : string;
      BNAmt      : money;
      pA         : pAccount_Rec;
      DoneHeader : Boolean;
   begin
      //look thru chart for chart codes with specified gst class
      with MyClient, clFields, TGSTReport( Sender) do begin
         DoneHeader := false;
         for c := 0 to Pred( RptParameters.Chart.ItemCount) do begin
            pA := RptParameters.Chart.Account_At( c);
            with pA^ do begin
               //no need to check if class matches because gst totals for the specified class only
               //also need to check that chart is a sales or purchases account
               if ( chGross <> 0) and ( chAccount_Type in [ atIncome, atPurchases])  then begin
                  if not DoneHeader then begin
                     if ( not FirstClass) and ( ReportTypeParams.NewPageforAccounts) then
                        ReportNewPage
                     else
                        FirstClass := false;

                     RenderTitleLine(GetGSTTitleLine( GST_Class));
                     DoneHeader := true;
                  end;
                  PutString( chAccount_Code);
                  PutString( chAccount_Description);
                  PutMoney( chGross);
                  PutMoney( chTax);
                  if GST_Class = 0 then begin
                        s     := '0';
                        BNAmt := 0;
                  end
                  else begin
                     if clGST_Business_Percent[ GST_Class] = 0 then begin
                        s     := '0';
                        BNAmt := 0;
                     end
                     else begin
                        s := FormatFloat( '#.##', clGST_Business_Percent[ GST_Class] / 100);
                        BNAmt := chGross * ( clGST_Business_Percent[ GST_Class]/100.0) / 100;
                     end;
                  end;
                  PutString( s + '%');
                  PutMoney( BNAmt);
                  RenderDetailLine;
               end;
            end;
         end;

         if DoneHeader then begin
            RenderTextLine('');
            RenderDetailSubTotal('');
         end;
      end;
   end;

var
   i        : Integer;
begin
   with TGstReport(Sender),MyClient, MyClient.clFields, GSTInfo  do begin
      FirstClass := true;
      for i := 0 to MAX_GST_CLASS do begin
         GSTUTIL32.CalculateGSTTotalsForPeriod(  D1, D2, GSTInfo, i );
         ShowCalculationFor( i );
      end;
//      RenderDetailGrandTotal('');
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoBusinessNorms(Dest : TReportDest;RptBatch : TReportBase = nil);
var
   GSTInfo: TGSTinfo;
   Job: TGSTReport;
   Params: TGenRptParameters;
   cLeft: Double;
   NonBaseCurrency: Boolean;
begin
   Params := TGenRptParameters.Create(ord(Report_GST_BusinessNorms), MyClient,RptBatch);
   NonBaseCurrency := False;
   try
   with Params do repeat
      if Batchrun then
      else begin
        if Batchless then begin
           FromDate := Client.clFields.clPeriod_Start_Date;
           ToDate   := Client.clFields.clPeriod_End_Date;
        end;

        if not EnterPrintDateRange('Print Business Norm Percentages Report','Enter the starting and finishing dates for the period you want to print',
                                 Fromdate,ToDate,BKH_Business_norms_percentages_report, true,Params, NonBaseCurrency) then exit;



        if (Params.RunBtn = BTN_SAVE) then begin
            SaveNodesettings;
            Exit
        end;

        case Params.RunBtn of

          BTN_PRINT : Dest := rdPrinter;
          BTN_PREVIEW : Dest := rdScreen;
          BTN_FILE    : Dest := rdFile;
          else Dest := rdAsk;
        end;
      end;

      //Calculate Totals.  In this case we will be using the gross amounts from the chart codes
      GSTUTIL32.CalculateGSTTotalsForPeriod( Fromdate,ToDate, GSTInfo, -1 );

      If (GSTInfo.guHasUncodes) and
         ( AskYesNo('Warning - Uncoded Entries', 'There are ' + inttostr(GSTInfo.guNumberUncoded) + ' UNCODED entries '+
                      'from ' + bkDate2Str( Fromdate )+' to ' + bkDate2Str( Todate ) +' which will '+
                      'affect Report.  Use F8 in the Code Entries Window to '+
                      'locate and code the UNCODED entries.'+#13#13+
                      'Do you want to print this Report with UNCODED entries?',
                      DLG_NO,0) <> DLG_YES )
                        then begin
                           Params.RunBtn := BTN_NONE;
                           exit;
                        end;

     Job := TGSTReport.Create(ReportTypes.rptGst);
     try
       Job.RptParameters := Params;     
       Job.LoadReportSettings(UserPrintSettings,MakeRptName(Report_List_Names[Report_GST_BusinessNorms]));

       //Add Headers
       AddCommonHeader(Job);

       AddJobHeader(Job,siTitle,'GST Business Norm Percentages Report',true);
       AddJobHeader(Job,siSubTitle,'For the Period from '+ stDatetoDateString('dd nnn yy',Fromdate,true) + ' TO '+
                                                          stDatetoDateString('dd nnn yy',ToDate,true),true);
       AddJobHeader(Job,siSubTitle,'',true);
       (*
       AddJobHeader(Job,siSubTitle,Client.clFields.clName,true);
       if Client.clFields.clGST_Number > '' then
       case Client.clFields.clCountry of
          whNewZealand : AddJobHeader(Job, siSubTitle, 'GST No: '+ Client.clFields.clGST_Number,true);
          whAustralia  : AddJobHeader(Job, siSubTitle, 'ABN : '+ Client.clFields.clGST_Number, true);
       end;
       AddJobHeader(Job,siSubTitle,Client.clFields.clAddress_L1,true);
       AddJobHeader(Job,siSubTitle,Client.clFields.clAddress_L2,true);
       AddJobHeader(Job,siSubTitle,Client.clFields.clAddress_L3,true);
       *)
       AddJobHeader(Job,siSubTitle,'',true);

       cLeft := GCLeft;
       AddColAuto(Job,cLeft,        7.0,Gcgap,'Account',jtLeft);
       AddColAuto(Job,cLeft,       35.0,Gcgap,'Description', jtLeft);
       AddFormatColAuto(Job,cLeft, 10.5,Gcgap,'Gross Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
       AddFormatColAuto(Job,cLeft, 10.5,Gcgap,'GST Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
       AddColAuto(Job,cLeft,       10.5,Gcgap,'GST Free %',jtRight);
       AddFormatColAuto(Job,cLeft, 10.5,Gcgap,'GST Free Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);

       //Add Footers
       AddCommonFooter(Job);

       Job.GSTInfo := GSTInfo;
       Job.d1      := FromDate;
       Job.d2      := Todate;
       Job.OnBKPrint := GSTBusinessNormsDetail;
       Job.Generate( Dest,params);
     finally
      Job.Free;
     end;
   until RunExit(Dest);
   finally
      Params.Free;
   end;
end;
//------------------------------------------------------------------------------

// ----------------------------------------------------------------------------
procedure GSTOverridesDetail(Sender : TObject);
var
   PC       : String[10];
   FirstClass : boolean;

   //-------------------------------------------------------------------
   function GetGSTTitleLine( ClassNo : integer;
                             D1 : integer;
                             D2 : integer)  : string;
   var
      R1, R2   : Byte;
      TempS    : string;
   begin
     with MyClient, MyClient.clFields do begin
        If ClassNo > 0 then
        Begin
           TempS := clGST_Class_Codes[ ClassNo ] +' ';
           R1 := WhichGSTRateApplies( MyClient, D1 );
           R2 := WhichGSTRateApplies( MyClient, D2 );
           If ( R1=R2 ) then
           Begin
              If R1=0 then
              Begin
                 TempS := TempS + ' ' + clGST_Class_Names[ClassNo] + ' (0%)';
              end
              else
              Begin
                 Str( clGST_Rates[ClassNo, R1]/10000.0:5:4, PC );
                 TempS := TempS + ' ' + clGST_Class_Names[ClassNo] + ' ('+PC + '%)';
              end;
           end
           else
              TempS := TempS + ' ' + clGST_Class_Names[ClassNo];
        end
        else
           TempS := MyClient.TaxSystemNameUC + ' Class 0 : Unallocated';
     end;
     result := TempS;
   end;

   //-----------------------------------------------------------------
   Procedure ShowCalculationFor( D1, D2 : LongInt; GST_Class : Byte );
   Var
      DoneHeader : Boolean;
      ClassHeaderDone : boolean;
      T, B  : LongInt;
      S : String;
      Dissection : pDissection_Rec;
//      AccountTypeOK : boolean;

      DefaultGSTClass   : byte;
      DefaultGSTAmount  : Money;
      GSTDate           : integer;
      pT                : pTransaction_Rec;

      //------------------------------------
      procedure DoHeader( AccountHeaderLine : string);
      begin
         with TGstReport(Sender) do begin
            if ( ReportTypeParams.NewPageforAccounts ) then begin
               //dont do new page if this is the first page
               if not FirstClass then
                  ReportNewPage
               else
                  FirstClass := false;
               RenderTitleLine(GetGSTTitleLine( GST_Class, D1, D2 ));
            end
            else begin
               if not ClassHeaderDone then begin
                  RenderTitleLine(GetGSTTitleLine( GST_Class, D1, D2 ));
                  ClassHeaderDone := true;
               end;
            end;
            RenderTitleLine( AccountHeaderLine);
            DoneHeader := TRUE;
         end;
      end;

   Begin
     DoneHeader := false;
     ClassHeaderDone := false;

      With MyClient, clFields, clBank_Account_List, TGstNonBaseCurrencyReport(Sender) do
      Begin
         For B := 0 to Pred( ItemCount ) do With Bank_Account_At( B ), baFields do
         begin
           //check correct journal accounts are being used, exclude stock and opening journals
           //AccountTypeOK := (baFields.baAccount_Type in [btBank,btCashJournals,btGSTJournals]) or
           //                ((baFields.baAccount_Type = btAccrualJournals) and (not clGST_Excludes_Accruals));
           //
           //If AccountTypeOK then
           Begin
             DoneHeader := FALSE;
             With baTransaction_List do For T := 0 to Pred( ItemCount ) do begin
                pT := Transaction_At( T );
                With pT^ do
                  If ( ( clGST_on_Presentation_Date ) and
                        ( txDate_Presented >=D1 ) and ( txDate_Presented <=D2 ) )
                     OR
                        ( ( not clGST_on_Presentation_Date ) and
                        ( txDate_Effective >=D1 ) and ( txDate_Effective <=D2 ) )
                  then begin
                     If ( txFirst_Dissection = NIL ) then Begin
                        If ( txGST_Class = GST_Class ) and ( txGST_Has_Been_Edited) then
                        Begin { It's what we want }
                           If not DoneHeader then Begin  //has a header been shown for this account
                              S := 'Account '+ baBank_Account_Number + ': '+AccountName;
                              DoHeader( S);
                           end;

                           { Print the Entry }
                           If clGST_on_Presentation_Date then begin
                              S := bkDate2Str ( txDate_Presented );
                              GSTDate := txDate_Presented;
                           end
                           else begin
                              S := bkDate2Str ( txDate_Effective ) ;
                              GSTDate := txDate_Effective;
                           end;

                           PutString( S );

                           PutString( GetFormattedReference( pT));
                           PutString( txAccount + ' ' + RptParameters.Chart.FindDesc( txAccount ) );

                           if NonBaseCurrency then
                             if (txGST_Amount <> 0) and IsAForexAccount then
                               PutMoney( txAmount )
                             else
                               PutString( '-' );

                           PutMoney( txTemp_Base_Amount );
                           PutMoney( txGST_Amount );
                           PutString( txGL_Narration);

                           //get defaults for this accounts
                           CalculateGST( MyClient, GSTDate, txAccount, txTemp_Base_Amount, DefaultGSTClass, DefaultGSTAmount);
                           PutString( GetGSTClassCode( MyClient, DefaultGSTClass));
                           PutMoney( DefaultGSTAmount);

                           RenderDetailLine;
                        end;
                     end
                     else
                     Begin
                        Dissection := txFirst_Dissection;
                        While ( Dissection<>NIL ) do With Dissection^ do
                        Begin
                           If ( dsGST_Class = GST_Class ) and ( dsGST_Has_Been_Edited) then
                           Begin
                              If not DoneHeader then Begin //has a header been shown for this account
                                 S := 'Account '+ baBank_Account_Number + ': '+ AccountName;
                                 DoHeader( S);
                              end;
                              { Print the Entry }

                              If clGST_on_Presentation_Date then begin
                                 S := bkDate2Str ( txDate_Presented );
                                 GSTDate := txDate_Presented;
                              end
                              else begin
                                 S := bkDate2Str ( txDate_Effective ) ;
                                 GSTDate := txDate_Effective;
                              end;

                              // mark dissection
                              if baFields.baAccount_Type = btBank then
                                S := S + ' [D]';

                              PutString( S );

                              PutString( getDsctReference (Dissection, pT,0 ) );
                              PutString( dsAccount + ' ' + RptParameters.Chart.FindDesc( dsAccount ) );

                              if NonBaseCurrency then
                                if (dsGST_Amount <> 0) and IsAForexAccount then
                                  PutMoney( dsAmount )
                                else
                                  PutString( '-' );

                              PutMoney( dsTemp_Base_Amount );
                              PutMoney( dsGST_Amount );
                              PutString( dsGL_Narration );
                              //get defaults for this accounts
                              CalculateGST( MyClient, GSTDate, dsAccount, txTemp_Base_Amount, DefaultGSTClass, DefaultGSTAmount);
                              PutString( GetGSTClassCode( MyClient, DefaultGSTClass));
                              PutMoney( DefaultGSTAmount);
                              RenderDetailLine;
                           end;
                           Dissection := dsNext;
                        end; // Scope of Dissection^ }
                     end; // of a Dissected Entry }
                  end; // Scope of Transaction^ }
             end;

             //do a section total for this bank account
             if DoneHeader then begin
                RenderTextLine('');
                RenderDetailSectionTotal('');
             end;

           end; //if accounttypeOK
         end; //with BankAccount;

         If DoneHeader then RenderTextLine('');
         if ClassHeaderDone then RenderDetailSubTotal('');
      end; //with MyClient...
   end; { of ShowCalculationFor }

//GSTAuditOverrides main
var
   i        : Integer;
begin
   FirstClass := true;

   with TGstReport(Sender),MyClient, MyClient.clFields, GSTInfo  do begin
      For i := 0 to MAX_GST_CLASS do {If guGross_Totals[ i ]<>0 then} begin
         ShowCalculationFor( D1, D2, i );
      end;
      RenderDetailGrandTotal('');
   end;
end;

//------------------------------------------------------------------------------

procedure DoGSTOverrides(Dest : TReportDest;RptBatch : TReportBase = nil;
         DFrom : Integer = 0; DTo : Integer = 0);
var
   GSTInfo  : TGSTinfo;
   Job : TGSTNonBaseCurrencyReport;
   params : TRptParameters;
   cLeft: Double;
   TaxName : String;
   ISOCodes: string;
   NonBaseCurrency: Boolean;
begin
  TaxName := MyClient.TaxSystemNameUC;

   Params := TRptParameters.Create(ord(Report_GST_Overrides),MyClient,RptBatch,DPeriod);
   with Params do try
      if DFrom <> 0 then begin
         Fromdate := DFrom;
         Todate := DTo;
      end;
      NonBaseCurrency := GetBatchBool('Non_Base_Currency',false);

      repeat

      if batchRun
      or (DFrom <> 0) then
      else begin
         if not EnterPrintDateRange('Print '+TaxName+' Overrides','Enter the starting and finishing dates for the period you want to print',
                                 Fromdate,ToDate,BKH_GST_overrides_report,
                                 True,Params, NonBaseCurrency, MyClient.HasForeignCurrencyAccounts) then exit;

         if Params.BatchSave then begin
            SaveNodesettings;
            SetBatchBool('Non_Base_Currency', NonBaseCurrency);
            Exit;
         end;

         case Params.RunBtn of
            BTN_PRINT   : Dest := rdPrinter;
            BTN_PREVIEW : Dest := rdScreen;
            BTN_FILE    : Dest := rdFile;
         else
            Dest := rdAsk;
         end;
      end;

      //Check Forex - this will stop the report running if there are missing exchange rates
      if not MyClient.HasExchangeRates(ISOCodes, FromDate, ToDate, True, True) then begin
        HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' + ISOCodes + '.',0);
        Exit;
      end;

      GSTUTIL32.CalculateGSTTotalsForPeriod(  Fromdate,ToDate, GSTInfo, -1 );

      If (GSTInfo.guHasUncodes) and
         ( AskYesNo('Warning - Uncoded Entries', 'There are ' + inttostr(GSTInfo.guNumberUncoded) + ' UNCODED entries '+
                      'from ' + bkDate2Str( FromDate )+' to ' + bkDate2Str( ToDate ) +' which will '+
                      'affect the '+TaxName+' Overrides Report.  Use F8 in the Code Entries Window to '+
                      'locate and code the UNCODED entries.'+#13#13+
                      'Do you want to print this Report with UNCODED entries?',
                      DLG_NO,0) <> DLG_YES )
                        then begin
                           Params.RunBtn := BTN_NONE;
                           Exit;
                        end;

     Job := TGSTNonBaseCurrencyReport.Create(ReportTypes.rptGst);
     try
       Job.RptParameters := Params;
       Job.LoadReportSettings(UserPrintSettings,MakeRptName(Report_List_Names[Report_GST_Overrides]));

       //Add Headers
       AddCommonHeader(Job);

       AddJobHeader(Job,siTitle,TaxName+' OVERRIDES',true);
       AddJobHeader(Job,siSubTitle,'For the Period from '+ stDatetoDateString('dd nnn yy',Fromdate,true) + ' TO '+
                                                          stDatetoDateString('dd nnn yy',ToDate,true),true);
       AddJobHeader(Job,siSubtitle,'',true);

       cLeft := GCLeft;
       AddColAuto(Job,cLeft,8.0,Gcgap,'Date',jtLeft);
       AddColAuto(Job,cLeft,10.4,Gcgap,'Reference', jtLeft);
       AddColAuto(Job,cLeft,16.0,Gcgap,'Account',jtLeft);
       if MyClient.HasForeignCurrencyAccounts and NonBaseCurrency then begin
         Job.UserReportSettings.s7Orientation := BK_LANDSCAPE;
         AddFormatColAuto(Job,cLeft,9.5,Gcgap,'Gross Non-base',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, false);
         AddFormatColAuto(Job,cLeft,9.5,Gcgap,'Gross Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
         AddFormatColAuto(Job,cLeft,8.0,Gcgap, TaxName+' Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
         AddColAuto(Job,cLeft,19.4,Gcgap,'Narration',jtLeft);
         AddColAuto(Job,cLeft,7.5,Gcgap,'Def Class', jtRight);
         AddFormatColAuto(Job,cLeft,  9.5,Gcgap,'Default Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
       end else begin
         AddFormatColAuto(Job,cLeft,10.5,Gcgap,'Gross Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
         AddFormatColAuto(Job,cLeft,9.0,Gcgap, TaxName+' Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
         AddColAuto(Job,cLeft,19.4,Gcgap,'Narration',jtLeft);
         AddColAuto(Job,cLeft,7.5,Gcgap,'Def Class', jtRight);
         AddFormatColAuto(Job,cLeft,  10.5,Gcgap,'Default Amt',jtRight,FORMAT_AMOUNT, MyClient.FmtMoneyStrBrackets, true);
       end;

       //Add Footers
       AddJobFooter( Job,siFootNote, '[D] = Part of Dissected Entry', true);
       AddCommonFooter(Job);

       Job.GSTInfo := GSTInfo;
       Job.d1      := FromDate;
       Job.d2      := ToDate;
       Job.NonBaseCurrency := NonBaseCurrency;
              
       Job.OnBKPrint := GSTOverridesDetail;
       Job.Generate( Dest,params);
     finally
      Job.Free;
     end;

   until RunExit(Dest)
   or (DFrom <> 0);

   finally
     Params.Free;
   end;
end;

//------------------------------------------------------------------------------
procedure TGSTReconReport.GetValuesForPeriod(const pAcct: pAccount_Rec;
  const ForPeriod: integer; var Values: TValuesArray);
var
  AccountInfo  : TAccountInformation;
  i            : integer;
begin
  //values for cash flow reports will be in the following order
  // Actual   Comparitive (Budget or Last Year)   Variance    Quantity
  for i := Low( Values) to High( Values) do
     Values[i] := 0;

  AccountInfo := TAccountInformation.Create( MyClient);
  try
    AccountInfo.UseBudgetIfNoActualData     := MyClient.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual;
    AccountInfo.LastPeriodOfActualDataToUse := MyClient.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
    AccountInfo.AccountCode                 := pAcct.chAccount_Code;

    for i := Low( Values) to High( Values) do begin
      Values[ i] := AccountInfo.ActualOrBudget( ForPeriod);
    end;
  finally
   AccountInfo.Free;
  end;
end;

//------------------------------------------------------------------------------


end.
