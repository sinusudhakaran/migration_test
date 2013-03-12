unit RptCoding;
//------------------------------------------------------------------------------
{
   Title:       Coding Report

   Description: Coding Report

   Remarks:     Nov 00 - This report is no longer used during Scheduled Reports

   Author:

}
//------------------------------------------------------------------------------
interface

uses
   Classes, ReportDefs, PrintMgrObj, OmniXML, baobj32, UBatchBase,
   NewReportObj, RepCols, CodingRepDlg;

type
   TCodingReport = class(TBKReport)
   private
     ColAmt, Col1, Col2 : TReportColumn;
     Settings: TCodingReportSettings;
     PrintingEntry : Boolean;
     CurrentBankAccount : TBank_Account;
     AccountTitle : Boolean;
     NarrationColIdx, NotesColIdx: Integer;
     IsForex : Boolean;
   protected
     procedure PutNarrationNotes(Narration, Notes : string);
     function SplitLine(ColIdx: Integer; var TextList: TStringList) : Integer;
   public
     procedure BKPrint;  override;
     procedure AfterNewPage(DetailPending : Boolean);  override;
     procedure PutNotes( Notes : string);
     property ReportSettings: TCodingReportSettings read Settings;
   end;

procedure DoCodingReport(Destination : TReportDest;
                    RptBatch : TReportBase = nil;
                    SetupOnly : Boolean = false );

//******************************************************************************
implementation

uses
  BKReportColumnManager,
  TransactionUtils,
  Graphics,
  sysutils,
  Types,
  reportTypes,
  bkdefs,
  globals,
  bkconst,
  ovcDate,
  stDateSt,
  travList,
  moneydef,
  bkDateUtils,
  ToDoHandler,
  GenUtils,
  infoMoreFrm,
  AutoCode32,
  rptParams,
  NewReportUtils,
  SYDEFS,
  Admin32,
  ClientHomePagefrm;

const
  TaxInvBoxEmpty = '[  ]';
  TaxInvBoxTicked = '[x]';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoCodingReport(Destination : TReportDest;
                    RptBatch : TReportBase = nil;
                    SetupOnly : Boolean = false );
const
  ThisMethodName = 'DoCodingReport';

var
  Job                : TCodingReport;
  s                  : string;
  cLeft, cGap        : double;
  ClientHasEntries   : boolean;
  i                  : integer;
  CRSettings         : TCodingReportSettings;
  FORMAT_AMOUNT      : String;
  FORMAT_AMOUNT2     : String;
  ShowVatFootnote    : boolean;

  function HasNewEntriesToPrint( B : TBank_Account ) : Boolean;
   var
      T : LongInt;
      NewEntries : Boolean;
   begin
      NewEntries := FALSE;
      With B.baTransaction_List do For T := 0 to Pred( itemCount ) do
         With Transaction_At( T )^ do
            If ( txDate_Effective >= CRSettings.FromDate ) and
               ( txDate_Effective <= CRSettings.ToDate ) and
               ( txDate_Transferred = 0 ) then
            Begin
               NewEntries := TRUE;
               Break;
            end;
      HasNewEntriesToPrint := NewEntries;
   end;

   Function HasEntries( B : TBank_Account ) : Boolean;
   Var
      T : LongInt;
      Entries : Boolean;
   Begin
      Entries := FALSE;
      With B.baTransaction_List do For T := 0 to Pred( itemCount ) do
         With Transaction_At( T )^ do
            If ( txDate_Effective >= CRSettings.FromDate ) and
               ( txDate_Effective <= CRSettings.ToDate ) then
            Begin
               Entries := TRUE;
               Break;
            end;
      HasEntries := Entries;
   end;


begin
  ClientHasEntries := FALSE;
  CRSettings := TCodingReportSettings.Create(ord(Report_Coding),MyClient,RptBatch,dPeriod);
  CRSettings.AccountFilter := TransferringJournalsSet;
  CRSettings.GetBatchAccounts;
  try
  with CRSettings do repeat

    if not GetCRParameters(CRSettings) then
       Exit; // Does the save...

    case CRSettings.RunBtn of
       BTN_PRINT   : Destination := rdPrinter;
       BTN_PREVIEW : Destination := rdScreen;
       BTN_FILE    : Destination := rdFile;
    else
       Destination := rdAsk;
    end;

    for i := 0 to Pred(CRSettings.AccountList.Count) do begin
      if HasEntries( TBank_account(CRSettings.AccountList[i])) then begin
          ClientHasEntries := true;
          Break;
      end;
    end;

    if ( not ClientHasEntries ) then begin
       HelpfulInfoMsg( 'There are no entries within this date range', 0 );
       exit;
    end;


    //Auto Code Entries
    for i := 0 to Pred(AccountList.Count) do begin
       AutoCodeEntries(Client, TBank_account(AccountList[i]),AllEntries,Fromdate,ToDate);
       //Store exchange rates for custom coding report - doesn't matter if there
       //are missing rates
       TBank_account(CRSettings.AccountList[i]).HasExchangeRates(Fromdate, ToDate, True);
    end;


    //create report
    Job := TCodingReport.Create(ReportTypes.rptCoding);
    try
       Job.Settings := CRSettings;
       Job.ReportType := ReportTypes.rptCoding;
       with job.Settings do
       begin
         case Style of
            rsStandard   : Job.LoadReportSettings(UserPrintSettings,MakeRptName(Report_List_Names[REPORT_CODING_STANDARD]));
            rsTwoColumn  : Job.LoadReportSettings(UserPrintSettings,MakeRptName(Report_List_Names[REPORT_CODING_TWOCOL]));
            rsStandardWithNotes  : Job.LoadReportSettings(UserPrintSettings,MakeRptName(Report_List_Names[Report_Coding_Standard_With_Notes]));
            rsTwoColumnWithNotes : Job.LoadReportSettings(UserPrintSettings,MakeRptName(Report_List_Names[REPORT_CODING_TWOCOL_WITH_NOTES]));
            rsCustom: Job.LoadReportSettings(UserPrintSettings,MakeRptName(Report_List_Names[REPORT_CODING]));
         end;

         //AddCodingHeader(Job);

         //Add Headers
         AddCommonHeader(Job);

         S := 'FROM ';
         If Fromdate=0 then
            S := S + 'FIRST'
         else
            S := S + bkDate2Str( Fromdate );
         S := S + ' TO ';
         If Todate = MaxLongInt then
            S := S + 'LAST'
         else
            S := S + bkDate2Str( ToDate );
         AddJobHeader(Job,siTitle,'CODING REPORT '+S, true );
         //AddJobHeader(Job,jtCenter,1.6,'CODING REPORT '+S, true);

         S := 'BY '+UpperCase(csNames[Sort]);

         Case include of
            esAllEntries   : S := S + ', ALL ENTRIES';
            esUncodedOnly  : S := S + ', UNCODED/INVALIDLY CODED ENTRIES';
         end;
         //AddJobHeader(Job,jtCenter,1.2,S, true);
         AddJobHeader(Job,siSubTitle,S, true);

         FORMAT_AMOUNT  := Client.FmtMoneyStrBracketsNoSymbol;
         FORMAT_AMOUNT2 := Client.FmtMoneyStrBrackets;

         {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
         CLeft    := GcLeft;
         CGap     := GcGap;
         Job.Col1 := nil;
         Job.Col2 := nil;
         Job.ColAmt  := nil;
         Case Style of
            rsStandard :
               Case Client.ClFields.clCountry of
                  whNewZealand :
                     Begin
                        AddColAuto(Job,cleft,7.0  ,cGap,'Date', jtLeft);
                        AddColAuto(Job,cLeft,2.5  ,cGap,'No',jtRight);
                        AddColAuto(Job,cleft,13.0 ,cGap,'Reference',jtLeft);
                        AddColAuto(Job,cleft,12.0 ,cGap,'Analysis',jtLeft);
                        AddColAuto(Job,cleft,9.0  ,cGap,'Code To',jtLeft);
                        Job.ColAmt := AddFormatColAuto(Job,cleft,12,cGap,'Amount',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        if TaxInvoice then
                          AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                        if ShowOtherParty then
                        begin
                          AddColAuto(Job,cleft,18.0 ,cGap,'Other Party',jtLeft);
                          AddColAuto(Job,cleft,13.0 ,cGap,'Particulars',jtLeft);
                        end else
                          AddColAuto( Job,cLeft, 31.0, cGap, 'Transaction Details', jtLeft);
                     end;
                  whAustralia :
                     Begin
                        AddColAuto(Job,cleft,7.0 ,cGap,'Date', jtLeft);
                        //AddColAuto(Job,cLeft,2.5  ,cGap,' ',jtRight);
                        AddColAuto(Job,cleft,13.0 ,cGap,'Reference',jtLeft);
                        AddColAuto(Job,cleft,9.0,cGap,'Code To',jtLeft);
                        Job.ColAmt := AddFormatColAuto(Job,cleft,12,cGap,'Amount',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        if TaxInvoice then
                        begin
                          AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                          AddFormatColAuto( Job, cLeft, 9, cGap, 'GST Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                        end;
                        AddColAuto(Job,cLeft,36,cGap, 'Transaction Details',jtLeft);
                     end;
                  whUK :
                     Begin
                        AddColAuto(Job,cleft,7.0 ,cGap,'Date', jtLeft);
                        //AddColAuto(Job,cLeft,2.5  ,cGap,' ',jtRight);
                        AddColAuto(Job,cleft,13.0 ,cGap,'Reference',jtLeft);
                        AddColAuto(Job,cleft,9.0,cGap,'Code To',jtLeft);
                        Job.ColAmt := AddFormatColAuto(Job,cleft,12,cGap,'Amount',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        if TaxInvoice then
                        begin
                          AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                          if (Client.HasForeignCurrencyAccounts) then
                            AddFormatColAuto( Job, cLeft, 9, cGap, 'VAT (GBP)*', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false)
                          else
                            AddFormatColAuto( Job, cLeft, 9, cGap, 'VAT Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                        end;
                        AddColAuto(Job,cLeft,36,cGap, 'Transaction Details',jtLeft);
                     end;

               end; { of Case clCountry }
            rsStandardWithNotes : begin
               CGap     := 0.8;
               Case Client.ClFields.clCountry of
                  whNewZealand :
                     Begin
                        AddColAuto(Job,cleft,6.0  ,cGap,'Date', jtLeft);
                        AddColAuto(Job,cLeft,1.8  ,cGap,'No',jtRight);
                        AddColAuto(Job,cleft,9.75 ,cGap,'Reference',jtLeft);
                        AddColAuto(Job,cleft,9.0 ,cGap,'Analysis',jtLeft);
                        AddColAuto(Job,cleft,6.0  ,cGap,'Code To',jtLeft);
                        Job.ColAmt := AddFormatColAuto(Job,cleft,9,cGap,'Amount',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        if TaxInvoice then
                          AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                        if ShowOtherParty then
                        begin
                          AddColAuto(Job,cleft,13.0 ,cGap,'Other Party',jtLeft);
                          AddColAuto(Job,cleft,10.0 ,cGap,'Particulars',jtLeft);
                        end else
                          AddColAuto( Job,cLeft, 24.0, cGap, 'Transaction Details', jtLeft);
                        AddColAuto( Job, cLeft, 28.0, cGap, 'Notes', jtLeft);
                     end;
                  whAustralia :
                     Begin
                        AddColAuto(Job,cleft,6.0 ,cGap,'Date', jtLeft);
                        //AddColAuto(Job,cLeft,2.5  ,cGap,'',jtRight);  Case 4443
                        AddColAuto(Job,cleft,9.75 ,cGap,'Reference',jtLeft);
                        AddColAuto(Job,cleft,6.0,cGap,'Code To',jtLeft);
                         Job.ColAmt := AddFormatColAuto(Job,cleft,9,cGap,'Amount',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        if TaxInvoice then
                        begin
                           AddColAuto(Job, cLeft, 4.5, cGap, 'Tax Inv', jtCenter);
                           AddFormatColAuto( Job, cLeft, 6.75, cGap, 'GST Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                        end;
                        AddColAuto(Job,cLeft,23,cGap, 'Transaction Details',jtLeft);
                        AddColAuto( Job, cLeft, 29.0, cGap, 'Notes', jtLeft);
                     end;
                  whUK :
                     Begin
                        AddColAuto(Job,cleft,6.0 ,cGap,'Date', jtLeft);
                        //AddColAuto(Job,cLeft,2.5  ,cGap,'',jtRight);  Case 4443
                        AddColAuto(Job,cleft,9.75 ,cGap,'Reference',jtLeft);
                        AddColAuto(Job,cleft,6.0,cGap,'Code To',jtLeft);
                        Job.ColAmt := AddFormatColAuto(Job,cleft,9,cGap,'Amount',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        if TaxInvoice then
                        begin
                          AddColAuto(Job, cLeft, 4.5, cGap, 'Tax Inv', jtCenter);
                          if (Client.HasForeignCurrencyAccounts) then
                            AddFormatColAuto( Job, cLeft, 9, cGap, 'VAT (GBP)*', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false)
                          else
                            AddFormatColAuto( Job, cLeft, 6.75, cGap, 'VAT Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                        end;
                        AddColAuto(Job,cLeft,23,cGap, 'Transaction Details',jtLeft);
                        AddColAuto( Job, cLeft, 29.0, cGap, 'Notes', jtLeft);
                     end;
               end; { of Case clCountry }
            end;
            rsTwoColumn :
               Case Client.ClFields.clCountry of
                  whNewZealand :
                     Begin
                        AddColAuto(Job,cleft,6.0 ,cGap,'Date', jtLeft);
                        AddColAuto(Job,cLeft,2.5, cGap,'No',jtRight);
                        AddColAuto(Job,cleft,9.6 ,cGap,'Reference',jtLeft);
                        AddColAuto(Job,cleft,9.6 ,cGap,'Analysis',jtLeft);
                        AddColAuto(Job,cleft,9,   cGap,'Code To',jtLeft);
                        Job.Col1 := AddFormatColAuto(Job,cLeft,11.5,cGap,'Withdrawals',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        Job.Col2 := AddFormatColAuto(Job,cLeft,11.5,cGap,'Deposits',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        if TaxInvoice then
                          AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                        if ShowOtherParty then
                        begin
                          AddColAuto(Job,cleft,16.4,cGap,'Other Party',jtLeft);
                          AddColAuto(Job,cleft,9.6 ,cGap,'Particulars',jtLeft);
                        end else
                          AddColAuto( Job,cLeft, 26.0, cGap, 'Transaction Details', jtLeft);
                     end;
                  whAustralia :
                     begin
                        AddColAuto(Job,cleft,8.0 ,cGap,'Date', jtLeft);
                        //AddColAuto(Job,cLeft,2.5  ,cGap,'',jtRight);
                        AddColAuto(Job,cleft,14.0 ,cGap,'Reference',jtLeft);
                        AddColAuto(Job,cleft,9,cGap,'Code To',jtLeft);
                        Job.Col1 := AddFormatColAuto(Job,cLeft,11,cGap,'Withdrawals',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        Job.Col2 := AddFormatColAuto(Job,cLeft,11,cGap,'Deposits',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        if TaxInvoice then
                        begin
                          AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                          AddFormatColAuto( Job, cLeft, 9, cGap, 'GST Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                        end;
                        AddColAuto(Job,cLeft,26 ,cGap, 'Transaction Details',jtLeft);
                     end;
                  whUK :
                     begin
                        AddColAuto(Job,cleft,8.0 ,cGap,'Date', jtLeft);
                        //AddColAuto(Job,cLeft,2.5  ,cGap,'',jtRight);
                        AddColAuto(Job,cleft,14.0 ,cGap,'Reference',jtLeft);
                        AddColAuto(Job,cleft,9,cGap,'Code To',jtLeft);
                        Job.Col1 := AddFormatColAuto(Job,cLeft,11,cGap,'Withdrawals',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        Job.Col2 := AddFormatColAuto(Job,cLeft,11,cGap,'Deposits',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        if TaxInvoice then
                        begin
                          AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                          if (Client.HasForeignCurrencyAccounts) then
                            AddFormatColAuto( Job, cLeft, 9, cGap, 'VAT (GBP)*', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false)
                          else
                            AddFormatColAuto( Job, cLeft, 9, cGap, 'VAT Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                        end;
                        AddColAuto(Job,cLeft,26 ,cGap, 'Transaction Details',jtLeft);
                     end;

               end;
            rsTwoColumnWithNotes    : begin
               CGap     := 0.8;
               Case Client.ClFields.clCountry of
                  whNewZealand :
                     Begin
                        AddColAuto(Job,cleft,6.0, cGap,'Date', jtLeft);
                        AddColAuto(Job,cLeft,1.8, cGap,'No',jtRight);
                        AddColAuto(Job,cleft,7.2, cGap,'Reference',jtLeft);
                        AddColAuto(Job,cleft,7.2, cGap,'Analysis',jtLeft);
                        AddColAuto(Job,cleft,6,   cGap,'Code To',jtLeft);
                        Job.Col1 := AddFormatColAuto(Job,cLeft,8.5,cGap,'Withdrawals',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        Job.Col2 := AddFormatColAuto(Job,cLeft,8.5,cGap,'Deposits',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        if TaxInvoice then
                          AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                        if ShowOtherParty then begin
                          AddColAuto(Job,cleft,12.5,cGap,'Other Party',jtLeft);
                          AddColAuto(Job,cleft,7.0 ,cGap,'Particulars',jtLeft);
                        end else
                          AddColAuto( Job,cLeft, 19.5, cGap, 'Transaction Details', jtLeft);
                        AddColAuto( Job, cLeft, 28.5, cGap, 'Notes', jtLeft);
                     end;
                  whAustralia :
                     Begin
                        AddColAuto(Job,cleft,6.0 ,cGap,'Date', jtLeft);
                        //AddColAuto(Job,cLeft,2.5  ,cGap,'',jtRight);
                        AddColAuto(Job,cleft,11.0 ,cGap,'Reference',jtLeft);
                        AddColAuto(Job,cleft,6,cGap,'Code To',jtLeft);
                        Job.Col1 := AddFormatColAuto(Job,cLeft,8.25,cGap,'Withdrawals',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        Job.Col2 := AddFormatColAuto(Job,cLeft,8.25,cGap,'Deposits',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        if TaxInvoice then
                        begin
                          AddColAuto(Job, cLeft, 5.5, cGap, 'Tax Inv', jtCenter);
                          AddFormatColAuto( Job, cLeft, 6.7, cGap, 'GST Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                        end;
                        AddColAuto(Job,cLeft,19.5 ,cGap, 'Transaction Details',jtLeft);
                        AddColAuto( Job, cLeft, 23.0, cGap, 'Notes', jtLeft);
                     end;
                  whUK :
                     begin
                        AddColAuto(Job,cleft,6.0 ,cGap,'Date', jtLeft);
                        //AddColAuto(Job,cLeft,2.5  ,cGap,'',jtRight);
                        AddColAuto(Job,cleft,11.0 ,cGap,'Reference',jtLeft);
                        AddColAuto(Job,cleft,6,cGap,'Code To',jtLeft);
                        Job.Col1 := AddFormatColAuto(Job,cLeft,8.25,cGap,'Withdrawals',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        Job.Col2 := AddFormatColAuto(Job,cLeft,8.25,cGap,'Deposits',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                        if TaxInvoice then
                        begin
                          AddColAuto(Job, cLeft, 5.5, cGap, 'Tax Inv', jtCenter);
                          if (Client.HasForeignCurrencyAccounts) then
                            AddFormatColAuto( Job, cLeft, 9, cGap, 'VAT (GBP)*', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false)
                          else
                            AddFormatColAuto( Job, cLeft, 6.7, cGap, 'VAT Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                        end;
                        AddColAuto(Job,cLeft,19.5 ,cGap, 'Transaction Details',jtLeft);
                        AddColAuto( Job, cLeft, 23.0, cGap, 'Notes', jtLeft);
                     end;
               end; { of Case clCountry }
            end;
            rsCustom:
              begin
                //Portrait or landscape
                job.UserReportSettings.s7Orientation := job.Settings.ColManager.Orientation;
                //Add report columns
                job.Settings.ColManager.AddReportColumns(Job);
              end;
         end; { of Case Style }

         // See which column contains notes and narrations
         Job.NarrationColIdx := -1;
         Job.NotesColIdx := -1;
         ShowVatFootnote := false;
         for i := 0 to Pred(Job.Columns.ItemCount) do
         begin
          if TReportColumn(Job.Columns.Report_Column_At(i)).Caption = 'Notes' then
            Job.NotesColIdx := i
          else if TReportColumn(Job.Columns.Report_Column_At(i)).Caption = 'Transaction Details' then
            Job.NarrationColIdx := i
          else if TReportColumn(Job.Columns.Report_Column_At(i)).Caption = 'VAT (GBP)*' then
            ShowVatFootnote := true;
         end;

         if TaxInvoice then
           AddJobFooter( Job, siFootNote, '( Tax Inv = Tax Invoice  [x] = Available )', true);
         if ShowVatFootnote then
           AddJobFooter( Job, siFootNote, '* Please ensure that you indicate a currency for any VAT amounts recorded for this account.', true);

         //AddCodingFooter(Job);

         //if (Destination <> rdFile) then
           //Add Footers
         AddCommonFooter(Job);

         Job.Generate(Destination, CRSettings);

         //will cause reload of admin system
         if (Destination in [ rdPrinter, rdFile, rdFax])
         and AdminExists then begin

            if LoadAdminSystem(true, ThisMethodName ) then
            try

                AddAutomaticToDoItem( Client.clFields.clCode,
                                    ttyCodingReport,
                                    Format( ToDoMsg_ManualCodingReport,
                                           [ bkDate2Str( Fromdate), bkDate2Str( ToDate),
                                           bkDate2Str(CurrentDate)]
                                          )
                                    );
            finally
                SaveAdminSystem;
            end;
            RefreshHomepage;
         end;
      end; {Job.settings}
    finally
      Job.Free;
    end;

  until RunExit(Destination);

  finally
    CRSettings.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CR_EnterAccount(Sender : TObject);
//on enter bank account
var
   Mgr : TTravManagerWithNewReport;
   s :string;
   Rpt : TCodingReport;
   I,J: Integer;
begin
   Mgr := TTravManagerWithNewReport(Sender);
   Rpt := TCodingReport( Mgr.ReportJob );

   With  Mgr, Rpt, Mgr.Bank_Account do
   Begin
      If NumOfAccounts > 0 then
      Begin
        If (ReportTypeParams.NewPageforAccounts) then
          ReportNewPage
        else
        begin
          RenderTextLine('');
          RenderTextLine('');
        end;
      end;

      Rpt.IsForex := IsAForexAccount;

      if ( not Rpt.AccountTitle ) then
      begin
        S := Bank_Account.Title;
        RenderTitleLine(S);
        Rpt.AccountTitle := True;
      end;

      if settings.Style = rsCustom then begin
         J := -1;
         for I := 0 to pred(Settings.ColManager.Count) do begin
            if Settings.ColManager.Columns[i].OutputCol then begin
               Inc(J); // is in the report..
               case Settings.ColManager.Columns[i].DataToken of
               tktxAmount:
                  Rpt.Columns.Report_Column_At(J).TotalFormat := Mgr.Bank_Account.FmtMoneyStrBrackets;
                  
               end;
            end;
         end;
      end else begin
         if Assigned(Col1) then
            Col1.TotalFormat := Mgr.Bank_Account.FmtMoneyStrBrackets;
         if Assigned(Col2) then
            Col2.TotalFormat := Mgr.Bank_Account.FmtMoneyStrBrackets;
         if Assigned(ColAmt) then
            ColAmt.TotalFormat := Mgr.Bank_Account.FmtMoneyStrBrackets;
      end;

      CRTotal := 0;
      DRTotal := 0;
   end;
   TCodingReport(Mgr.ReportJob).CurrentBankAccount := Mgr.Bank_Account;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CR_ExitAccount(Sender : TObject);
//on exit bank account
var
   Mgr : TTravManagerWithNewReport;
   NettTotal : Currency;
   Job :  TCodingReport;
begin
   Mgr := TTravManagerWithNewReport(Sender);
   Job := TCodingReport (Mgr.ReportJob);
   With  Mgr, Job, Mgr.Bank_Account, Mgr.Transaction^, Mgr.Dissection^ do
   Begin
      if Settings.Rule then

      //Only draw the lines if we have actually traversed some transactions
      if Mgr.TransactionsTraversed then
      begin
        if (Settings.RuleLineBetweenColumns) then
          RenderRuledLineWithColLines(0, psSolid, vcTopHalf) //Ruled line after last detail line for account
        else
          RenderRuledLine;
      end;

      if Assigned(Col1) then
        Col1.TotalFormat := Mgr.Bank_Account.FmtMoneyStrBrackets;
      if Assigned(Col2) then
        Col2.TotalFormat := Mgr.Bank_Account.FmtMoneyStrBrackets;
      if Assigned(ColAmt) then
        ColAmt.TotalFormat := Mgr.Bank_Account.FmtMoneyStrBrackets;

      RenderDetailSubTotal('');
      If Settings.Style in [ rsTwoColumn, rsTwoColumnWithNotes] then
      Begin
         NettTotal := DRTotal + CRTotal;
         If NettTotal > 0 then
            C1.SubTotal := NettTotal/100
         else
            C2.SubTotal := NettTotal/100;
         RenderDetailSubTotal('');
      end;
      TCodingReport(Mgr.ReportJob).CurrentBankAccount := nil;
      TCodingReport(Mgr.ReportJob).AccountTitle := False;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure CR_EnterDissect(Sender : Tobject);
var
  Mgr : TTravManagerWithNewReport;
  i, NotesLines, NarrationLines, SpaceForRuledLines : integer;
  entry: TStringList;
  NotesCol, NarrationCol: Integer;
  lNotes: string;
  Job :  TCodingReport;
  Amt : Money;
begin
   Mgr := TTravManagerWithNewReport(Sender);
   Job := TCodingReport (Mgr.ReportJob);

   if (Job.Settings.Include = esUncodedOnly) and (Mgr.Dissection^.dsAccount <> '') and
      (Mgr.Bank_Account.IsAJournalAccount) then
     Exit;

   With  Mgr, Job, Settings, Mgr.Bank_Account, Mgr.Transaction^, Mgr.Dissection^ do
   Begin
     PrintingEntry := False;
//     RequireLines(Leave+1);
     If Rule then
     begin
       if (Sort = csAccountCode) or
          (IsAJournalAccount) then begin
         if RuleLineBetweenColumns then
           RenderRuledLineWithColLines(Leave)  //Ruled line before each detail line
         else
           RenderRuledLine
       end else begin
         if RuleLineBetweenColumns then
           RenderRuledLineWithColLines(Leave, psDot, vcFull) //Ruled line before each detail line
         else
           RenderRuledLine(psDot);
       end;
     end;

     if Rule then
        RequireLines(Leave+2)
     else
        RequireLines(Leave+1);

     // Do not allow spanning pages in dissections - if not enough room then start new page (#1733)

     entry := TStringList.Create;
     NotesCol := TCodingReport(Mgr.ReportJob).NotesColIdx;
     NarrationCol := TCodingReport(Mgr.ReportJob).NarrationColIdx;
     try
       lNotes := GetFullNotes(Mgr.Dissection);
       if (lNotes <> '')
       and (NotesCol > -1)
       and ((Style = rsTwoColumnWithNotes)
            or (Style = rsStandardWithNotes)) then begin
          entry.Text := LNotes;
          NotesLines := TCodingReport(Mgr.ReportJob).SplitLine(NotesCol, entry);
       end else
         NotesLines := 0;

       if (dsGL_Narration <> '')
       and (NarrationCol > -1)
       and (WrapNarration) then
       begin
         entry.Text := dsGL_Narration;
         NarrationLines := TCodingReport(Mgr.ReportJob).SplitLine(NarrationCol, entry);
       end
       else
         NarrationLines := 0;
       if (NarrationLines > 0) or (NotesLines > 0) then
       begin
         if Rule then
           SpaceForRuledLines := Leave + 1
         else
           SpaceForRuledLines := Leave;
         if NotesLines > NarrationLines then
           RequireLines(NotesLines + SpaceForRuledLines)
         else
           RequireLines(NarrationLines + SpaceForRuledLines);
       end;
     finally
       entry.Free;
     end;

     // Always use the actual amount, not the base amount
     Amt := dsAmount;

     Case Style of
        rsStandard, rsStandardWithNotes :
           Case Client.clFields.clCountry of
              whNewZealand :
                 Begin
                    PutString(bkDate2Str( txDate_Effective ) );
                    SkipColumn; //no
                    if dsReference <> '' then
                       PutString(dsReference)
                    else
                       PutString(' /'+inttostr(dsSequence_No));

                    SkipColumn;
                    PutString( dsAccount );
                    //need to add the amount if the sort order is by account
                    //because the enter entry routine is not called for
                    //dissection entries if the sort order is csAccountCode

                    if SortType = csAccountCode then
                      PutMoney( Amt )
                    else
                      PutMoneyDontAdd( Amt );

                    if TaxInvoice then
                    begin
                      if dsTax_Invoice then
                        PutString( TaxInvBoxTicked)
                      else
                        PutString( TaxInvBoxEmpty);
                    end;

                    if ShowOtherParty then
                       SkipColumn;

                    if Style = rsStandardWithNotes then
                      TCodingReport( Mgr.ReportJob).PutNarrationNotes(dsGL_Narration,GetFullNotes(Mgr.Dissection))
                    else
                      TCodingReport( Mgr.ReportJob).PutNotes( dsGL_Narration);
                 end;
              whAustralia, whUK :
                 Begin
                    PutString( bkDate2Str( txDate_Effective ) );
                    if dsReference <> '' then
                       PutString(dsReference) // must be Journal
                    else PutString(' /'+inttostr(dsSequence_No));


                    PutString( dsAccount );

                    if SortType = csAccountCode then
                      PutMoney( Amt)
                    else
                      PutMoneyDontAdd( Amt );

                    if TaxInvoice then begin
                      if dsTax_Invoice then
                        PutString( TaxInvBoxTicked)
                      else
                        PutString( TaxInvBoxEmpty);

                      if dsGST_Amount <> 0 then
                        PutMoney( dsGST_Amount)
                      else
                        SkipColumn;
                    end;

                    if Style = rsStandardWithNotes then
                      TCodingReport( Mgr.ReportJob).PutNarrationNotes(dsGL_Narration, GetFullNotes(Mgr.Dissection))
                    else
                      TCodingReport( Mgr.ReportJob).PutNotes( dsGL_Narration);
                 end;
           end; { of Case clCountry }
        rsTwoColumn, rsTwoColumnWithNotes :
           Case Client.clFields.clCountry of
              whNewZealand :
                 Begin
                    PutString(bkDate2Str(txDate_Effective));
                    SkipColumn;
                    if dsReference <> '' then
                       PutString(dsReference)
                    else
                       PutString(' /'+inttostr(dsSequence_No));
                    SkipColumn;
                    PutString( dsAccount );
                    If Amt >= 0 then
                    Begin
                      if SortType = csAccountCode then
                        PutMoney( Amt)
                      else
                        PutMoneyDontAdd( Amt );
                      SkipColumn;
                    end
                    else
                    Begin
                       SkipColumn;
                       if SortType = csAccountCode then
                         PutMoney( Amt)
                       else
                         PutMoneyDontAdd( Amt );
                    end;
                    if TaxInvoice then
                    begin
                      if dsTax_Invoice then
                        PutString( TaxInvBoxTicked)
                      else
                        PutString( TaxInvBoxEmpty);
                    end;

                    if ShowOtherParty then
                       SkipColumn;

                    if Style = rsTwoColumnWithNotes then
                      TCodingReport( Mgr.ReportJob).PutNarrationNotes(dsGL_Narration, GetFullNotes(Mgr.Dissection))
                    else
                      TCodingReport( Mgr.ReportJob).PutNotes( dsGL_Narration);
                 end;
              whAustralia, whUK :
                 Begin
                    PutString(bkDate2Str(txDate_Effective));
                    if dsReference <> '' then
                       PutString(dsReference) // must be Journal
                    else PutString(' /'+inttostr(dsSequence_No));

                    PutString( dsAccount );
                    If Amt >= 0 then
                    Begin
                      if SortType = csAccountCode then
                        PutMoney( Amt)
                      else
                        PutMoneyDontAdd( Amt );
                      SkipColumn;
                    end
                    else
                    Begin
                       SkipColumn;
                       if SortType = csAccountCode then
                         PutMoney( Amt)
                       else
                         PutMoneyDontAdd( Amt );
                    end;

                    if TaxInvoice then begin
                      if dsTax_Invoice then
                        PutString( TaxInvBoxTicked)
                      else
                        PutString( TaxInvBoxEmpty);

                      if dsGST_Amount <> 0 then
                        PutMoney( dsGST_Amount)
                      else
                        SkipColumn;
                    end;

                    if Style = rsTwoColumnWithNotes then
                      TCodingReport( Mgr.ReportJob).PutNarrationNotes(dsGL_Narration, GetFullNotes(Mgr.Dissection))
                    else
                      TCodingReport( Mgr.ReportJob).PutNotes( dsGL_Narration);
                 end;
           end; { of Case clCountry }
        rsCustom:
           begin
             TCodingReport(Mgr.ReportJob).Settings.ColManager.OutputColumns(Mgr.ReportJob, Mgr);
           end;
     end; { of Case Style }

     if RuleLineBetweenColumns then
       RenderAllVerticalColumnLines; //Detail line
     RenderDetailLine;

     for i := 1 to Leave do begin
        if RuleLineBetweenColumns then
          RenderAllVerticalColumnLines;
        RenderTextLine( '');
     end;

     //need to add the amounts here if sort order is by account because
     //enter entry routine not called for dissection entries if sort order
     //is csAccountCode
     if SortType = csAccountCode then begin
       if Amt >=0 then
          DRTotal := DRTotal + Amt
       else
          CRTotal := CRTotal + Amt;
     end;
   end; {with}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CR_EnterEntry(Sender: TObject);
//note: this routine is not called for dissected entries if the sort order
//      is by account
var
  Mgr : TTravManagerWithNewReport;
  i, NotesLines, NarrationLines, SpaceForRuledLines : integer;
  entry: TStringList;
  NotesCol, NarrationCol: Integer;
  lNotes: string;
  Job :  TCodingReport;
  Amt : Money;
Begin
   Mgr := TTravManagerWithNewReport(Sender);
   Job := TCodingReport (Mgr.ReportJob);
   With  Mgr, Job, Settings, Mgr.Bank_Account, Mgr.Transaction^ do
   Begin
     TCodingReport(Mgr.ReportJob).PrintingEntry := True;
     If Rule then begin
       if RuleLineBetweenColumns then
         RenderRuledLineWithColLines(Leave) //Ruled line before each detail line
       else
         RenderRuledLine;
     end;

     if Rule then
        RequireLines(Leave+2)
     else
        RequireLines(Leave+1);

     // Do not allow spanning pages - if not enough room then start new page (#1733)
     entry := TStringList.Create;
     NotesCol := TCodingReport(Mgr.ReportJob).NotesColIdx;
     NarrationCol := TCodingReport(Mgr.ReportJob).NarrationColIdx;
     try
       lNotes := GetFullNotes(Mgr.Transaction);
       if (lNotes <> '')
       and (NotesCol > -1)
       and((Style = rsTwoColumnWithNotes)
           or (Style = rsStandardWithNotes)) then begin
          entry.Text := lNotes;
          NotesLines := TCodingReport(Mgr.ReportJob).SplitLine(NotesCol, entry);
       end else
         NotesLines := 0;
       if (txGL_Narration <> '') and (NarrationCol > -1) and (WrapNarration) then
       begin
         entry.Text := txGL_Narration;
         NarrationLines := TCodingReport(Mgr.ReportJob).SplitLine(NarrationCol, entry);
       end
       else
         NarrationLines := 0;
       if (NarrationLines > 0) or (NotesLines > 0) then
       begin
         if Rule then
           SpaceForRuledLines := Leave + 1
         else
           SpaceForRuledLines := Leave;
         if NotesLines > NarrationLines then
           RequireLines(NotesLines + SpaceForRuledLines)
         else
           RequireLines(NarrationLines + SpaceForRuledLines);
       end;
     finally
       entry.Free;
     end;

      // Always use the actual amount, not the base amount
      Amt := txAmount;

      Case Style of
         rsStandard, rsStandardWithNotes :
            Case Client.clFields.clCountry of
               whNewZealand :
                  Begin
                     PutString(bkDate2Str(txDate_Effective));
                     PutString(IntToStr(txType) );
                     PutString( GetFormattedReference( Mgr.Transaction));
                     PutString( Trim(txAnalysis) );
                     PutString( txAccount );
                     PutMoney( Amt );
                     if TaxInvoice then
                     begin
                       if txTax_Invoice_Available then
                         PutString( TaxInvBoxTicked)
                       else
                         PutString( TaxInvBoxEmpty);
                     end;
                     if ShowOtherParty then begin
                        if ReverseFieldOrder then
                        begin
                           PutString(txParticulars);
                           PutString(txOther_Party);
                        end
                        else
                        begin
                           PutString(txOther_Party);
                           PutString(txParticulars);
                        end;
                        if Style = rsStandardWithNotes then
                          TCodingReport( Mgr.ReportJob).PutNotes(GetFullNotes(Mgr.Transaction) );
                     end else
                     begin
                        if Style = rsStandardWithNotes then
                          TCodingReport(Mgr.ReportJob).PutNarrationNotes(txGL_Narration, GetFullNotes(Mgr.Transaction))
                        else
                          TCodingReport(Mgr.ReportJob).PutNotes( txGL_Narration);
                     end;
                  end;
               whAustralia, whUK :
                  Begin
                     PutString(bkDate2Str(txDate_Effective));

                     PutString( GetFormattedReference( Mgr.Transaction));
                     PutString( txAccount );
                     PutMoney( Amt );

                     if TaxInvoice then begin
                        if txTax_Invoice_Available then
                          PutString( TaxInvBoxTicked)
                        else
                          PutString( TaxInvBoxEmpty);

                        if txGST_Amount <> 0 then
                           PutMoney( txGST_Amount)
                        else
                           SkipColumn;
                     end;

                    if Style = rsStandardWithNotes then
                      TCodingReport( Mgr.ReportJob).PutNarrationNotes(txGL_Narration, GetFullNotes(Mgr.Transaction))
                    else
                      TCodingReport( Mgr.ReportJob).PutNotes( txGL_Narration);
                  end;
            end; { of Case fdCountry }
         rsTwoColumn, rsTwoColumnWithNotes :
            Case Client.clFields.clCountry of
               whNewZealand :
                  Begin
                     PutString(bkDate2Str(txDate_Effective));
                     PutString(IntToStr(txType) );
                     PutString( GetFormattedReference( Mgr.Transaction));
                     PutString( Trim(txAnalysis) );
                     PutString( txAccount );
                     If Amt >= 0 then
                     Begin
                       PutMoney( Amt );
                       SkipColumn;
                     end
                     else
                     Begin
                       SkipColumn;
                       PutMoney( Amt );
                     end;

                     if TaxInvoice then
                     begin
                       if txTax_Invoice_Available then
                         PutString( TaxInvBoxTicked)
                       else
                         PutString( TaxInvBoxEmpty);
                     end;
                     if ShowOtherParty then
                     begin
                        if ReverseFieldOrder then
                        begin
                          PutString(txParticulars);
                          PutString(txOther_Party);
                        end
                        else
                        begin
                          PutString(txOther_Party);
                          PutString(txParticulars);
                        end;
                       if Style = rsTwoColumnWithNotes then
                         TCodingReport( Mgr.ReportJob).PutNotes( GetFullNotes(Mgr.Transaction));
                     end else
                     begin
                       if Style = rsTwoColumnWithNotes then
                         TCodingReport( Mgr.ReportJob).PutNarrationNotes(txGL_Narration,GetFullNotes(Mgr.Transaction))
                       else
                         TCodingReport( Mgr.ReportJob).PutNotes( txGL_Narration);
                     end;
                  end;
               whAustralia, whUK :
                  Begin
                     PutString(bkDate2Str(txDate_Effective));

                     PutString( GetFormattedReference( Mgr.Transaction));
                     PutString( txAccount );
                     If Amt >= 0 then
                     Begin
                        PutMoney( Amt );
                        SkipColumn;
                     end
                     else
                     Begin
                        SkipColumn;
                        PutMoney( Amt );
                     end;

                     if TaxInvoice then begin
                        if txTax_Invoice_Available then
                          PutString( TaxInvBoxTicked)
                        else
                          PutString( TaxInvBoxEmpty);

                        if txGST_Amount <> 0 then
                           PutMoney( txGST_Amount)
                        else
                           SkipColumn;
                     end;

                     if Style = rsTwoColumnWithNotes then
                       TCodingReport( Mgr.ReportJob).PutNarrationNotes(txGL_Narration, GetFullNotes(Mgr.Transaction))
                     else
                       TCodingReport( Mgr.ReportJob).PutNotes( txGL_Narration);
                  end; { of Case fdCountry }
            end;
            rsCustom:
            begin
              TCodingReport(Mgr.ReportJob).Settings.ColManager.OutputColumns(Mgr.ReportJob, Mgr);
            end;
      end; { of Case Style }

      If Amt >=0 then
         DRTotal := DRTotal + Amt
      else
         CRTotal := CRTotal + Amt;

      if RuleLineBetweenColumns then
        RenderAllVerticalColumnLines; //detail line
      RenderDetailLine;
      For i := 1 to Leave do begin
         if RuleLineBetweenColumns then
            RenderAllVerticalColumnLines;
         RenderTextLine( '');
      end;
   end; {with}

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CR_ExitEntry(Sender :TObject);
begin
  //
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// PutNotes
//
// Outputs Notes column but wraps text onto multiple lines if need be.
//
procedure TCodingReport.PutNotes(Notes: string);
var
  j, ColWidth, OldWidth, MaxNotesLines : Integer;
  ColsToSkip : integer;
  NotesList  : TStringList;
begin
  if Settings.WrapNarration then
    MaxNotesLines := 10
  else
    MaxNotesLines := 1;
  if (Notes = '') then
    SkipColumn
  else
  begin
    NotesList  := TStringList.Create;
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
        if ( j < notesList.Count)
        and ( j < MaxNotesLines) then begin
           if Settings.RuleLineBetweenColumns then
             RenderAllVerticalColumnLines; //Detail line
           RenderDetailLine(False);
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
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// PutNarrationNotes
//
// Outputs Narration and Notes columns but wraps text onto multiple lines
// if need be.
//
procedure TCodingReport.PutNarrationNotes(Narration, Notes : string);
const
  MaxLinesAllowed = 10;
var
  NotesList : TStringList;
  NarrList : TStringList;
  NoteLines, NarrLines : Integer;
  MaxLines : Integer;
  ColsToSkip, i, j : Integer;
begin
  NarrList := TStringList.Create;
  NotesList := TStringList.Create;
  try
    ColsToSkip := CurrDetail.Count;
    NarrList.Text := Narration;
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
    NarrLines := SplitLine(CurrDetail.Count, NarrList);
    NoteLines := SplitLine(CurrDetail.Count, NotesList);

    if (NarrLines > 1) and (not Settings.WrapNarration) then
      NarrLines := 1;
    if (NoteLines > 1) and (not Settings.WrapNarration) then
      NoteLines := 1;

    MaxLines := NarrLines;
    if (NoteLines > NarrLines) then
      MaxLines := NoteLines;
    if (MaxLines > MaxLinesAllowed) then
      MaxLines := MaxLinesAllowed;

    if (MaxLines = 0) then
    begin
      SkipColumn;
      SkipColumn;
    end else
    begin
      for i := 0 to MaxLines-1 do
      begin
        if (i < NarrLines) then
          PutString(NarrList[i])
        else
          SkipColumn;
        if (i < NoteLines) then
          PutString(NotesList[i])
        else
          SkipColumn;
        if (i < MaxLines-1) then
        begin
          if Settings.RuleLineBetweenColumns then
            RenderAllVerticalColumnLines; //Detail line
          RenderDetailLine(False);
          j := ColsToSkip;
          while (j > 0) do
          begin
            SkipColumn;
            Dec(j);
          end;
        end;
      end;
    end;
  finally
    NotesList.Free;
    NarrList.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TCodingReport.SplitLine(ColIdx: Integer; var TextList: TStringList) : Integer;
const
  MaxLines = 10;
var
  j, ColWidth, OldWidth : Integer;
begin
  j := 0;
  while j < TextList.Count do begin
     // Remove any Blank lines..
     if TextList[j] = '' then
        TextList.Delete(j)
     else
        Inc(j);
  end;
  if (TextList.Count = 0) then
     Result := 0 // nothing to do...
  else begin
     j := 0;
     repeat
        ColWidth := RenderEngine.RenderColumnWidth(ColIdx, TextList[j]);
        if (ColWidth < Length(TextList[j])) then
        begin
          //line needs to be split
          OldWidth := ColWidth; //store
          while (ColWidth > 0) and (TextList[j][ColWidth] <> ' ') do
            Dec(ColWidth);
          if (ColWidth = 0) then
            ColWidth := OldWidth; //unexpected!
          TextList.Insert(j + 1, Copy(TextList[j], ColWidth + 1, Length(TextList[j]) - ColWidth + 1));
          TextList[j] := Copy(TextList[j], 1, ColWidth);
        end;
        Inc( j);
      until ( j >= TextList.Count) or ( j >= MaxLines);
      Result := TextList.Count;
      if Result > MaxLines then
        Result := MaxLines;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TCodingReport.BKPrint;
var
  i, j : Integer;
  TravMgr : TTravManagerWithNewReport;
  NettTotal : currency;
  Empty : Boolean;
  BA : TBank_Account;
  TR : pTransaction_Rec;
begin
  TravMgr := TTravManagerWithNewReport.Create;
  try
     TravMgr.Clear;
     TravMgr.SortType := Settings.Sort; //csDateEffective;
     TravMgr.ReportJob := Self;

     Case Settings.Include of
        esAllEntries   : TravMgr.SelectionCriteria := TravList.twAllEntries;        //twAllNewEntries;
        esUncodedOnly  : TravMgr.SelectionCriteria := TravList.twAllUncoded;        //twAllNewUncodedEntries;
     end;

     PrintingEntry := True;

     TravMgr.OnEnterAccount    := CR_EnterAccount;
     TravMgr.OnExitAccount     := CR_ExitAccount;
     TravMgr.OnEnterEntry      := CR_EnterEntry;
     TravMgr.OnExitEntry       := CR_ExitEntry;
     TravMgr.OnEnterDissection := CR_EnterDissect;
     TravMgr.C1                := Col1;
     TravMgr.C2                := Col2;

     //traverse thru each account
     for i := 0 to Settings.AccountList.Count-1 do
     begin
       BA := Settings.AccountList[i];

       if (BA.IsAJournalAccount)
       and (BA.baTransaction_List.ItemCount > 0) then
       begin
         //is a journal so check to see if it's empty
         Empty := True;
         j := 0;
         repeat
           TR := BA.baTransaction_List.Transaction_At(j);
             if (TR^.txDate_Effective >= Settings.FromDate) and (TR^.txDate_Effective <= Settings.ToDate) then
               Empty := False;
           Inc(j);
         until (j >= BA.baTransaction_List.ItemCount) or (not Empty);
         if (not Empty) then
           TravMgr.TraverseAccount(BA, Settings.FromDate, Settings.ToDate);
       end else
         TravMgr.TraverseAccount(BA, Settings.FromDate, Settings.ToDate);
     end;

     with TravMgr do
     begin
       If settings.Style in [ rsTwoColumn, rsTwoColumnWithNotes] then
       Begin
          DRTotal := C1.GrandTotal; C1.GrandTotal := 0;
          CRTotal := C2.GrandTotal; C2.GrandTotal := 0;
          NettTotal := DRTotal + CRTotal;
          If NettTotal > 0 then
             C1.GrandTotal := NettTotal/100
          else
             C2.GrandTotal := NettTotal/100;
       end;
     end;

     If ( TravMgr.NumOfAccounts > 1 ) and PRACINI_Reports_GrandTotal and ( not Settings.Client.HasForeignCurrencyAccounts ) then
       RenderDetailGrandTotal('');
  finally
    TravMgr.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// AfterNewPage
//
// Parameters :
// DetailPending : Indicates that there is a detail line to be rendered
//                 immediately after the page header.
//
procedure TCodingReport.AfterNewPage(DetailPending : Boolean);
var
  s : String;
begin
  AccountTitle := False;
  if (Assigned(CurrentBankAccount)) then
  begin
    //render the acccount details at the top of each page
    s := CurrentBankAccount.baFields.baBank_Account_Number + ' : '+CurrentBankAccount.AccountName;
    RenderTitleLine(s);
    AccountTitle := True;
  end;
  if (DetailPending) and (Settings.Rule) then
  begin
    //render a ruled line before the pending detail is rendered
    if (PrintingEntry) then begin
      if Settings.RuleLineBetweenColumns then
        RenderRuledLineWithColLines(0, psSolid, vcBottomHalf) //First ruled line on new page
      else
        RenderRuledLine;
    end else
    begin
      if (Settings.Sort = csAccountCode) or
         (Assigned(CurrentBankAccount) and (CurrentBankAccount.IsAJournalAccount)) then begin
        if Settings.RuleLineBetweenColumns then
          RenderRuledLineWithColLines(0, psSolid, vcBottomHalf) //First ruled line on new page
        else
          RenderRuledLine;
      end else begin
        if Settings.RuleLineBetweenColumns then
          RenderRuledLineWithColLines(0, psDot, vcBottomHalf) //First ruled line on new page
        else
          RenderRuledLine(psDot);
      end;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.

