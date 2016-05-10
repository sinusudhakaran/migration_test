unit RptListings;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Contains all listing type reports
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  ReportDefs,
  PrintMgrObj,
  FaxParametersObj,
  OvcDate,
  moneydef,
  Classes,
  baobj32,
  UBatchBase;

const
  NUMBER_FORMAT = '#,##0.00;(#,##0.00);-';
  BAL_FORMAT = '#,##0.00 "OD ";#,##0.00 "IF "; ';

  function  DoChartListReport(Dest : TReportDest;
                              Settings : TPrintManagerObj;
                              Scheduled : boolean;
                              FaxParams : TFaxParameters = nil;
                              RptBatch : TReportBase = nil) : boolean; overload;

  procedure DoChartListReport(Dest : TReportDest;
                              RptBatch : TReportBase = nil); overload;

  function  DoListPayeesReport(Dest : TReportDest;
                               Settings : TPrintManagerObj;
                               Scheduled : boolean;
                               FaxParams : TFaxParameters = nil;
                               RptBatch : TReportBase = nil
                               ) : boolean; overload;

  procedure DoListPayeesReport(Dest : TReportDest;
                              RptBatch : TReportBase = nil); overload;

  procedure DoListBankAccountsReport(Dest : TReportDest;
                              RptBatch : TReportBase = nil);

  procedure DoListEntriesReport(Dest : TReportDest;
                              ShowJournalOnly : boolean;
                              RptBatch : TReportBase = nil);

  procedure DoListGSTDetails(Dest : TReportDest;
                             RptBatch : TReportBase = nil);

  procedure DoListMemorisations( Dest : TReportDest;
                              RptBatch : TReportBase = nil);

  procedure DoListDivisions( Dest : TReportDest;
                              RptBatch : TReportBase = nil);

  function  DoListJobsReport(Dest : TReportDest;
                             Settings : TPrintManagerObj;
                             Scheduled : boolean;
                             FaxParams : TFaxParameters = nil;
                             RptBatch : TReportBase = nil
                             ) : boolean; overload;

  procedure DoListJobs( Dest : TReportDest;
                           RptBatch : TReportBase = nil); overload;

  procedure DoListSubGroups( Dest : TReportDest;
                              RptBatch : TReportBase = nil);

  function DoTestFax( Dest : TReportDest; Settings : TPrintManagerObj; FaxParams : TFaxParameters = nil) : boolean; overload;
  function DoTestFax( Dest : TReportDest) : boolean; overload;

  Procedure LE_EnterAccount(Sender : TObject);
  Procedure LE_ExitAccount(Sender : TObject);
  procedure LE_EnterEntry(Sender : Tobject);

  Procedure LE_EnterAccount_Pres(Sender : TObject);
  Procedure LE_ExitAccount_Pres(Sender : TObject);
  procedure LE_EnterEntry_Pres(Sender : Tobject);

  procedure LE_ExitEntry(Sender : TObject);
  procedure LE_EnterDissect(Sender : TObject);

  function LE_HasTransactions(StartDate, EndDate: Integer; BA: TBank_Account): Boolean;

//******************************************************************************
implementation

uses
   SuperfieldsUtils,
   SoftWare,
   Controls,
   TransactionUtils,
   ReportTypes,
   RptParams,
   StDateSt,
   AccountLookupFrm,
   NewReportObj,
   repcols,
   bkdefs,
   glConst,
   globals,
   ladefs,
   bkconst,
   codeDateDlg,
   GSTCalc32,
   ListEntriesAdvancedDlg,
   ListPayeeOptionsDlg,
   MemorisationsObj,
   bkhelp,
   travList,
   signUtils,
   sysutils,
   bkDateUtils,
   Admin32,
   GenUtils,
   BAUtils,
   NewReportUtils,
   InfoMoreFrm,
   BasUtils,
   mxfiles32,
   MoneyUtils, 
   CustomHeadingsListObj,
   chList32,
   ECollect,
   mxList32,
   PayeeObj,
   PrintDestDlg,
   AccountInfoObj,
   BKUtil32,
   CalculateAccountTotals,
   WarningMoreFrm,
   ChartReportDlg,
   CountryUtils,
   SystemMemorisationList,
   SYDEFS,
   ForexHelpers,
   SimpleFundX;

const
  NUMBER_FORMAT_SIGNED = '#,##0.00;-#,##0.00;-';
  PERCENT_FORMAT = '#.####;(#.####);-';
  QUANTITY_FORMAT = '###,###,###.####;(###,###,###.####);-';
  NullCode = '<NULLCODE>';

type
   //---------------------------------------------------------------------------
   TListEntriesReport = class(TBKReport)
   private
     Params : TListEntriesParam;
     CRAmountCol : TReportColumn;
     DRAmountCol : TReportColumn;
     AmountCol   : TReportColumn;
     BalanceCol  : TReportColumn;
     TaxCol      : TReportColumn;
   protected
     procedure BKPrint;  override;
     procedure PutNotes( Notes : string);
     procedure PutNarrationNotes(Job: TBKReport; Narration, Notes : string; ShowBal: Boolean; Bal: Money);
     function SplitLine(ColIdx: Integer; var TextList: TStringList) : Integer;
   end;

   //---------------------------------------------------------------------------
   TChartListReport = class(TBKReport)
   public
     ShowSubTypes : boolean;
     ShowDivisions: boolean;
     ShowBasicChart: Boolean;
     ShowInactive: boolean;
     Chart: TCustomSortChart;
   end;

   TPayeeListReport = class(TBKReport)
   private
     FParams: TListPayeesParam;
   protected
     procedure BKPrint; override;
   end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//              List Entries
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Is current bank account selected in the Advanced tab
// Returns True if selected

function LE_IsBankAccountIncluded(ReportJob: TBkReport; Mgr: TTravManagerWithNewReport): Boolean;
var
  i: Integer;
  BA: TBank_Account;
begin
   Result := False;
   for i := 0 to Pred(TListEntriesReport(ReportJob).Params.AccountList.Count) do
   begin
     BA := TListEntriesReport(ReportJob).Params.AccountList[i];
     if (BA.baFields.baBank_Account_Number = Mgr.Bank_Account.baFields.baBank_Account_Number) then
     begin
       Result := True;
       Break;
     end;
   end;
end;

// Does a bank account have transactions in the current date range
// Returns True if selected
function LE_HasTransactions(StartDate, EndDate: Integer; BA: TBank_Account): Boolean;
var
  i: Integer;
  T: pTransaction_Rec;
begin
  for i := 0 to Pred(BA.baTransaction_List.ItemCount) do
  begin
    T := BA.baTransaction_List.Transaction_At(i);
    if (T.txDate_Effective >= StartDate) and
       (T.txDate_Effective <= EndDate) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

Procedure LE_EnterAccount_Pres(Sender : TObject);
var
   Mgr : TTravManagerWithNewReport;
   Rpt : TListEntriesReport;
begin
   Mgr := TTravManagerWithNewReport(Sender);
   Rpt := TListEntriesReport( Mgr.ReportJob );
   With  Mgr, Rpt, Rpt.Params do begin

      if (not JournalOnly) and (not LE_IsBankAccountIncluded(ReportJob, Mgr)) then exit;

      if not LE_HasTransactions(Fromdate, Todate, Bank_Account) then exit;

      NumOfAccounts := NumOfAccounts+1;

      if (NumOfAccounts > 2) and ReportTypeParams.NewPageforAccounts then ReportNewPage;

      RenderTitleLine( Bank_Account.Title );
      if Bank_Account.IsAForexAccount and ( TaxCol <> NIL ) then TaxCol.FormatString := Client.FmtMoneyStr;

      if ( CRAmountCol  <> NIL ) then  CRAmountCol .FormatString := Bank_Account.FmtMoneyStr;
      if ( DRAmountCol  <> NIL ) then  DRAmountCol .FormatString := Bank_Account.FmtMoneyStr;
      if ( AmountCol    <> NIL ) then  AmountCol   .FormatString := Bank_Account.FmtMoneyStr;
      if ( BalanceCol   <> NIL ) then  BalanceCol  .FormatString := Bank_Account.FmtMoneyStr;

      if Bank_Account.baFields.baAccount_Type = btBank then
      begin
        GetBalances( Bank_Account, FromDate, Todate, OpBalAtBank, ClBalAtBank, OpBalInSystem, ClBalInSystem );

        If OpBalAtBank <> Unknown then
        Begin
           Bank_Account.baFields.baTemp_Balance := OpBalAtBank;

           case Client.clFields.clCountry of
              whNewZealand :
                 Begin
                    SkipColumn;   {trx}
                    PutString( bkDate2Str ( D1 ) );
                    PutString( 'Op Bal' );
                    PutString( '' );
                    PutString( Bank_Account.baFields.baContra_Account_Code );

                    If TwoColumn then
                    Begin
                       If OpBalAtBank >= 0 then
                       Begin
                          PutMoneyDontAdd( OpBalAtBank );
                          SkipColumn;
                       end
                       else
                       Begin
                          SkipColumn;
                          PutMoneyDontAdd( OpBalAtBank );
                       end;
                    end
                    else
                       PutMoneyDontAdd( OpBalAtBank );

                    if ShowOP then
                    begin
                      SkipColumn;   {other}
                      SkipColumn;   {part}
                    end
                    else
                      SkipColumn;   {narr}

                    if ShowBalance then
                      SkipColumn;

                    if ShowNotes then
                      SkipColumn;   {notes}

                 end;
              whAustralia, whUK :
                 Begin
                    SkipColumn; {trx}
                    PutString( bkDate2Str ( D1 ) );
                    PutString( 'Op Bal' );
                    PutString( Bank_Account.baFields.baContra_Account_Code );

                    If TwoColumn then
                    Begin
                       If OpBalAtBank >= 0 then
                       Begin
                          PutMoneyDontAdd( OpBalAtBank );
                          SkipColumn;
                       end
                       else
                       Begin
                          SkipColumn;
                          PutMoneyDontAdd( OpBalAtBank );
                       end;
                    end
                    else
                       PutMoneyDontAdd( OpBalAtBank );

                    SkipColumn; {gst}
                    SkipColumn; {narration}

                    if ShowBalance then
                      SkipColumn;

                    if ShowNotes then
                      SkipColumn;   {notes}
                 end;
           end; { Case clCountry }

           RenderDetailLine;
        end
        else
          Bank_Account.baFields.baTemp_Balance := Unknown;
      end;  //if account type is bank
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure LE_ExitAccount_Pres(Sender : TObject);
var
   Mgr : TTravManagerWithNewReport;
   Rpt : TListEntriesReport;
begin
   Mgr := TTravManagerWithNewReport(Sender);
   Rpt := TListEntriesReport( Mgr.ReportJob );
   With  Mgr, Rpt, Rpt.Params do Begin

      if (not JournalOnly) and (not LE_IsBankAccountIncluded(ReportJob, Mgr)) then exit;

      if not LE_HasTransactions(Fromdate, ToDate, Bank_Account) then exit;

      if ( CRAmountCol  <> NIL ) then  CRAmountCol .TotalFormat := Bank_Account.FmtMoneyStr;
      if ( DRAmountCol  <> NIL ) then  DRAmountCol .TotalFormat := Bank_Account.FmtMoneyStr;
      if ( AmountCol    <> NIL ) then  AmountCol   .TotalFormat := Bank_Account.FmtMoneyStr;
      if ( BalanceCol   <> NIL ) then  BalanceCol  .TotalFormat := Bank_Account.FmtMoneyStr;


      if ( CRAmountCol  <> NIL ) then  CRAmountCol .FormatString := Bank_Account.FmtMoneyStr;
      if ( DRAmountCol  <> NIL ) then  DRAmountCol .FormatString := Bank_Account.FmtMoneyStr;
      if ( AmountCol    <> NIL ) then  AmountCol   .FormatString := Bank_Account.FmtMoneyStr;
      if ( BalanceCol   <> NIL ) then  BalanceCol  .FormatString := Bank_Account.FmtMoneyStr;

      RenderDetailSubTotal('');

      if Bank_Account.baFields.baAccount_Type = btBank then begin
        If OpBalInSystem <> Unknown then
        Begin

           case Client.clFields.clCountry of
              whNewZealand :
                 Begin
                    SkipColumn;   {trx}
                    If D2 < MaxLongInt then
                       PutString( bkDate2Str ( D2 ) )
                    else
                       PutString( '' );
                    PutString( 'Cl Bal' );
                    PutString( '' );
                    PutString( Bank_Account.baFields.baContra_Account_Code );

                    If TwoColumn then
                    Begin
                       If ClBalAtBank >= 0 then
                       Begin
                          PutMoneyDontAdd( ClBalAtBank );
                          SkipColumn;
                       end
                       else
                       Begin
                          SkipColumn;
                          PutMoneyDontAdd( ClBalAtBank );
                       end;
                    end
                    else
                       PutMoneyDontAdd( ClBalAtBank );

                    SkipColumn;   {other}
                    SkipColumn;   {part}
                    if ShowBalance then
                      SkipColumn;
                    SkipColumn;   {notes}
                 end;
              whAustralia, whUK :
                 Begin
                    SkipColumn;   {trx}
                    If D2 < MaxLongInt then
                       PutString( bkDate2Str ( D2 ) )
                    else
                       PutString( '' );
                    PutString( 'Cl Bal' );
                    PutString( Bank_Account.baFields.baContra_Account_Code );

                    If TwoColumn then
                    Begin
                       If ClBalAtBank >= 0 then
                       Begin
                          PutMoneyDontAdd( ClBalAtBank );
                          SkipColumn;
                       end
                       else
                       Begin
                          SkipColumn;
                          PutMoneyDontAdd( ClBalAtBank );
                       end;
                    end
                    else
                       PutMoneyDontAdd( ClBalAtBank );

                    SkipColumn;   {gst}
                    SkipColumn;   {narr}
                    if ShowBalance then
                      SkipColumn;
                    SkipColumn;   {notes}
                 end;
           end; { Case clCountry }
           RenderDetailLine;
        end;
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure LE_EnterEntry_Pres(Sender : TObject);
var
   Mgr : TTravManagerWithNewReport;
   Bal: Money;
   ShowBal: Boolean;
   Rpt : TListEntriesReport;
begin
   Mgr := TTravManagerWithNewReport(Sender);
   Rpt := TListEntriesReport( Mgr.ReportJob );
   With  Mgr, Rpt, Rpt.Params, Bank_Account, Transaction^ do
   Begin
      if (not JournalOnly) and (not LE_IsBankAccountIncluded(ReportJob, Mgr)) then exit;

      case Client.clFields.clCountry of
         whNewZealand :
            Begin
               If txDate_Transferred <> 0 then
                  PutString( 'Yes' )
               else
                  SkipColumn;

               PutString( bkDate2Str ( txDate_Presented ) );
               PutString( GetFormattedReference( Mgr.Transaction));
               PutString(Trim(txAnalysis));
               PutString( txAccount );
               If TwoColumn then
               Begin
                  If txAmount >= 0 then
                  Begin
                     PutMoney( Trunc( txAmount ) );
                     SkipColumn;
                  end
                  else
                  Begin
                     SkipColumn;
                     PutMoney( Trunc( txAmount ) );
                  end;
               end
               else
                  PutMoney( Trunc( txAmount ) );

               if JournalOnly then
                 PutMoney ( Trunc( txGST_Amount));

               ShowBal := False;
               Bal := 0;
               if ShowBalance then
               begin
                 if Bank_Account.baFields.baTemp_Balance <> unknown then
                 begin
                   Bank_Account.baFields.baTemp_Balance := Bank_Account.baFields.baTemp_Balance + txAmount;
                   Bal := Bank_Account.baFields.baTemp_Balance;
                   ShowBal := True;
                 end
                 else
                   ShowBal := False;
               end;

               if ShowOP then begin
                  PutString( txOther_Party );
                  Rpt.PutNarrationNotes( ReportJob, txParticulars, GetFullNotes( Transaction), ShowBal, Bal);
                  if ShowNotes then
                     Rpt.PutNotes( GetFullNotes( Transaction ) );
               end else
                  Rpt.PutNarrationNotes( ReportJob, txGL_Narration, GetFullNotes( Transaction ), ShowBal, Bal);
            end;

         whAustralia, whUK :
            Begin
               If txDate_Transferred <> 0 then
                  PutString( 'Yes' )
               else
                  SkipColumn;

               PutString( bkDate2Str ( txDate_Presented ) );
               PutString( GetFormattedReference( Mgr.Transaction));
               PutString( txAccount );
               If TwoColumn then
               Begin
                  If txAmount >= 0 then
                  Begin
                     PutMoney( Trunc( txAmount ) );
                     SkipColumn;
                  end
                  else
                  Begin
                     SkipColumn;
                     PutMoney( Trunc( txAmount ) );
                  end;
               end
               else
                  PutMoney( Trunc( txAmount ) );

               PutMoney ( Trunc( txGST_Amount));

               ShowBal := False;
               Bal := 0;
               if ShowBalance then
               begin
                 if Bank_Account.baFields.baTemp_Balance <> unknown then
                 begin
                   Bank_Account.baFields.baTemp_Balance := Bank_Account.baFields.baTemp_Balance + txAmount;
                   Bal := Bank_Account.baFields.baTemp_Balance;
                   ShowBal := True;
                 end
                 else
                   ShowBal := False;
               end;

               Rpt.PutNarrationNotes( ReportJob, txGL_Narration, GetFullNotes(Transaction), ShowBal, Bal);
            end;
      end; { Case clCountry }
      RenderDetailLine;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure LE_EnterAccount(Sender : TObject);
var
   Mgr : TTravManagerWithNewReport;
   Rpt : TListEntriesReport;
begin
   Mgr := TTravManagerWithNewReport(Sender);
   Rpt := TListEntriesReport( Mgr.ReportJob );
   With  Mgr, Rpt, Rpt.Params do
   Begin
      if (not JournalOnly)
      and (not LE_IsBankAccountIncluded(ReportJob, Mgr)) then
           exit;

      if not LE_HasTransactions(Fromdate, Todate, Bank_Account) then exit;

      NumOfAccounts := NumOfAccounts+1;

      if (NumOfAccounts > 2) and ReportTypeParams.NewPageforAccounts then ReportNewPage;

      RenderTitleLine( Bank_Account.Title );

      if Bank_Account.IsAForexAccount and ( TaxCol <> NIL ) then  TaxCol.FormatString := Client.FmtMoneyStr;

      if ( CRAmountCol  <> NIL ) then  CRAmountCol .FormatString := Bank_Account.FmtMoneyStr;
      if ( DRAmountCol  <> NIL ) then  DRAmountCol .FormatString := Bank_Account.FmtMoneyStr;
      if ( AmountCol    <> NIL ) then  AmountCol   .FormatString := Bank_Account.FmtMoneyStr;
      if ( BalanceCol   <> NIL ) then  BalanceCol  .FormatString := Bank_Account.FmtMoneyStr;
//      if ( CRAmountCol  <> NIL ) then  CRAmountCol .FormatString := Bank_Account.FmtMoneyStrBrackets;
//      if ( DRAmountCol  <> NIL ) then  DRAmountCol .FormatString := Bank_Account.FmtMoneyStrBrackets;
//      if ( AmountCol    <> NIL ) then  AmountCol   .FormatString := Bank_Account.FmtMoneyStrBrackets;
//      if ( BalanceCol   <> NIL ) then  BalanceCol  .FormatString := Bank_Account.FmtMoneyStrBrackets;

      if ( Bank_Account.baFields.baAccount_Type = btBank) {and
         ( Mgr.SelectionCriteria = twAllEntries)} then
      begin
        GetBalances( Bank_Account, FromDate, Todate, OpBalAtBank, ClBalAtBank, OpBalInSystem, ClBalInSystem );

        If OpBalInSystem <> Unknown then
        Begin
           Bank_Account.baFields.baTemp_Balance := OpBalInSystem;

           case Client.clFields.clCountry of
              whNewZealand :
                 Begin
                    SkipColumn;   {trx}
                    PutString( bkDate2Str (D1) );
                    PutString( 'Op Bal' );
                    SkipColumn;
                    PutString( Bank_Account.baFields.baContra_Account_Code );

                    If TwoColumn then
                    Begin
                       If OpBalInSystem >= 0 then
                       Begin
                          PutMoneyDontAdd( OpBalInSystem );
                          SkipColumn;
                       end
                       else
                       Begin
                          SkipColumn;
                          PutMoneyDontAdd( OpBalInSystem );
                       end;
                    end
                    else
                       PutMoneyDontAdd( OpBalInSystem );

                    if ShowOP then
                    begin
                      SkipColumn;   {other}
                      SkipColumn;   {part}
                    end
                    else
                      SkipColumn;   {narr}

                    if ShowBalance then
                      SkipColumn;

                    if ShowNotes then
                      SkipColumn;   {notes}

                 end;
              whAustralia, whUK :
                 Begin
                    SkipColumn; {trx}
                    PutString( bkDate2Str ( D1 ) );
                    PutString( 'Op Bal' );
                    PutString( Bank_Account.baFields.baContra_Account_Code );

                    If TwoColumn then
                    Begin
                       If OpBalInSystem >= 0 then
                       Begin
                          PutMoneyDontAdd( OpBalInSystem );
                          SkipColumn;
                       end
                       else
                       Begin
                          SkipColumn;
                          PutMoneyDontAdd( OpBalInSystem );
                       end;
                    end
                    else
                       PutMoneyDontAdd( OpBalInSystem );

                    SkipColumn; {gst}
                    SkipColumn; {narration}

                    if ShowBalance then
                      SkipColumn;

                    if ShowNotes then
                      SkipColumn;   {notes}
                 end;
           end; { Case clCountry }
           RenderDetailLine;
        end
        else
          Bank_Account.baFields.baTemp_Balance := Unknown;
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure LE_ExitAccount(Sender : TObject);
var
   Rpt : TListEntriesReport;
   Mgr : TTravManagerWithNewReport;
begin
   Mgr := TTravManagerWithNewReport(Sender);
   Rpt := TListEntriesReport( Mgr.ReportJob );
   With  Mgr, Rpt, Rpt.Params do
   Begin
      if (not JournalOnly) and (not LE_IsBankAccountIncluded(ReportJob, Mgr)) then exit;

      if not LE_HasTransactions(Fromdate, ToDate, Bank_Account) then exit;

      if ( CRAmountCol  <> NIL ) then  CRAmountCol .FormatString := Bank_Account.FmtMoneyStr;
      if ( DRAmountCol  <> NIL ) then  DRAmountCol .FormatString := Bank_Account.FmtMoneyStr;
      if ( AmountCol    <> NIL ) then  AmountCol   .FormatString := Bank_Account.FmtMoneyStr;
      if ( BalanceCol   <> NIL ) then  BalanceCol  .FormatString := Bank_Account.FmtMoneyStr;

      if ( CRAmountCol  <> NIL ) then  CRAmountCol .TotalFormat := Bank_Account.FmtMoneyStr;
      if ( DRAmountCol  <> NIL ) then  DRAmountCol .TotalFormat := Bank_Account.FmtMoneyStr;
      if ( AmountCol    <> NIL ) then  AmountCol   .TotalFormat := Bank_Account.FmtMoneyStr;
      if ( BalanceCol   <> NIL ) then  BalanceCol  .TotalFormat := Bank_Account.FmtMoneyStr;
//      if ( CRAmountCol  <> NIL ) then  CRAmountCol .TotalFormat := Bank_Account.FmtMoneyStrBrackets;
//      if ( DRAmountCol  <> NIL ) then  DRAmountCol .TotalFormat := Bank_Account.FmtMoneyStrBrackets;
//      if ( AmountCol    <> NIL ) then  AmountCol   .TotalFormat := Bank_Account.FmtMoneyStrBrackets;
//      if ( BalanceCol   <> NIL ) then  BalanceCol  .TotalFormat := Bank_Account.FmtMoneyStrBrackets;

      RenderDetailSubTotal('');

      if ( Bank_Account.baFields.baAccount_Type = btBank) {and
         ( Mgr.SelectionCriteria = twAllEntries)} then
      begin
        If OpBalInSystem <> Unknown then
        Begin
           case Client.clFields.clCountry of
              whNewZealand :
                 Begin
                    SkipColumn;   {trx}
                    If D2 < MaxLongInt then
                       PutString( bkDate2Str ( D2 ) )
                    else
                       PutString( '' );
                    PutString( 'Cl Bal' );
                    PutString( '' );

                    PutString( Bank_Account.baFields.baContra_Account_Code);

                    If TwoColumn then
                    Begin
                       If ClBalInSystem >= 0 then
                       Begin
                          PutMoneyDontAdd( ClBalInSystem );
                          SkipColumn;
                       end
                       else
                       Begin
                          SkipColumn;
                          PutMoneyDontAdd( ClBalInSystem );
                       end;
                    end
                    else
                       PutMoneyDontAdd( ClBalInSystem );

                    if ShowOP then
                    begin
                      SkipColumn;   {other}
                      SkipColumn;   {part}
                    end
                    else
                      SkipColumn;   {narr}

                    if ShowBalance then
                      SkipColumn;

                    if ShowNotes then
                      SkipColumn;   {notes}
                 end;
              whAustralia, whUK :
                 Begin
                    SkipColumn;   {trx}
                    If D2 < MaxLongInt then
                       PutString( bkDate2Str ( D2 ) )
                    else
                       PutString( '' );
                    PutString( 'Cl Bal' );
                    PutString( Bank_Account.baFields.baContra_Account_Code);

                    If TwoColumn then
                    Begin
                       If ClBalInSystem >= 0 then
                       Begin
                          PutMoneyDontAdd( ClBalInSystem );
                          SkipColumn;
                       end
                       else
                       Begin
                          SkipColumn;
                          PutMoneyDontAdd( ClBalInSystem );
                       end;
                    end
                    else
                       PutMoneyDontAdd( ClBalInSystem );

                    SkipColumn;   {gst}
                    SkipColumn;   {narr}

                    if ShowBalance then
                      SkipColumn;

                    if ShowNotes then
                      SkipColumn;   {notes}
                 end;
           end; { Case clCountry }

           RenderDetailLine;
           case Client.clFields.clCountry of
              whNewZealand :
                 Begin
                    SkipColumn;   {trx}
                    If D2 < MaxLongInt then
                       PutString( bkDate2Str ( D2 ) )
                    else
                       PutString( '' );
                    PutString( 'Cl Bal At Bank' );
                    PutString( '' );
                    PutString( Bank_Account.baFields.baContra_Account_Code );

                    If TwoColumn then
                    Begin
                       If ClBalAtBank >= 0 then
                       Begin
                          PutMoneyDontAdd( ClBalAtBank );
                          SkipColumn;
                       end
                       else
                       Begin
                          SkipColumn;
                          PutMoneyDontAdd( ClBalAtBank );
                       end;
                    end
                    else
                       PutMoneyDontAdd( ClBalAtBank );

                    if ShowOP then
                    begin
                      SkipColumn;   {other}
                      SkipColumn;   {part}
                    end
                    else
                      SkipColumn;   {narr}

                    if ShowBalance then
                      SkipColumn;

                    if ShowNotes then
                      SkipColumn;   {notes}

                 end;

              whAustralia, whUK :
                 Begin
                    SkipColumn;   {trx}
                    If D2 < MaxLongInt then
                       PutString( bkDate2Str ( D2 ) )
                    else
                       PutString( '' );
                    PutString( 'Cl Bal At Bank' );
                    PutString( Bank_Account.baFields.baContra_Account_Code );

                    If TwoColumn then
                    Begin
                       If ClBalAtBank >= 0 then
                       Begin
                          PutMoneyDontAdd( ClBalAtBank );
                          SkipColumn;
                       end
                       else
                       Begin
                          SkipColumn;
                          PutMoneyDontAdd( ClBalAtBank );
                       end;
                    end
                    else
                       PutMoneyDontAdd( ClBalAtBank );

                    SkipColumn;   {gst}
                    SkipColumn;   {narr}

                    if ShowBalance then
                      SkipColumn;

                    if ShowNotes then
                      SkipColumn;   {notes}
                 end;
           end; { Case clCountry }
           RenderDetailLine;
        end;
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure LE_EnterEntry(Sender : Tobject);
var
   Mgr : TTravManagerWithNewReport;
   Bal: Money;
   ShowBal: Boolean;
   Rpt : TListEntriesReport;
begin
   Mgr := TTravManagerWithNewReport(Sender);
   Rpt := TListEntriesReport( Mgr.ReportJob );
   With Mgr, Rpt, Rpt.Params, Transaction^, Bank_Account do
   Begin
      if (not JournalOnly) and (not LE_IsBankAccountIncluded(ReportJob, Mgr)) then exit;

      case Client.clFields.clCountry of
         whNewZealand :
            Begin
               If txDate_Transferred <> 0 then
                  PutString( 'Yes' )
               else
                  SkipColumn;
               PutString( bkDate2Str ( txDate_Effective ) );
               PutString( GetFormattedReference( Mgr.Transaction));
               PutString(Trim(txAnalysis));
               // add a space - its truncating the 'D'
               if txAccount = DISSECT_DESC then
                 PutString(txAccount + ' ')
               else
                 PutString( txAccount );

               If TwoColumn then
               Begin
                  If txAmount >= 0 then
                  Begin
                     PutMoney( Trunc( txAmount ) );
                     SkipColumn;
                  end
                  else
                  Begin
                     SkipColumn;
                     PutMoney( Trunc( txAmount ) );
                  end;
               end
               else
                  PutMoney( Trunc( txAmount ) );

               if JournalOnly then
                 PutMoney ( Trunc( txGST_Amount));

               ShowBal := False;
               Bal := 0;
               if ShowBalance then
               begin
                 if Bank_Account.baFields.baTemp_Balance <> unknown then
                 begin
                   Bank_Account.baFields.baTemp_Balance := Bank_Account.baFields.baTemp_Balance + txAmount;
                   Bal := Bank_Account.baFields.baTemp_Balance;
                   ShowBal := True;
                 end
                 else
                   ShowBal := False;
               end;

               if ShowOP then begin
                  PutString( txOther_Party );
                  Rpt.PutNarrationNotes( ReportJob, txParticulars, GetFullNotes( Transaction), ShowBal, Bal);
                  PutString( txParticulars );
               end
               else
                 Rpt.PutNarrationNotes( ReportJob, txGL_Narration, GetFullNotes( Transaction), ShowBal, Bal);
            end;
         whAustralia, whUK :
            Begin
               If txDate_Transferred <> 0 then
                  PutString( 'Yes' )
               else
                  SkipColumn;

               PutString( bkDate2Str ( txDate_Effective ) );
               PutString( GetFormattedReference( Mgr.Transaction));
               // add a space - its truncating the 'D'
               if txAccount = DISSECT_DESC then
                 PutString(txAccount + ' ')
               else
                 PutString( txAccount );

               If TwoColumn then
               Begin
                  If txAmount >= 0 then
                  Begin
                     PutMoney( Trunc( txAmount ) );
                     SkipColumn;
                  end
                  else
                  Begin
                     SkipColumn;
                     PutMoney( Trunc( txAmount ) );
                  end;
               end
               else
                  PutMoney( Trunc( txAmount ) );
               PutMoney ( Trunc( txGST_Amount));

               ShowBal := False;
               Bal := 0;
               if ShowBalance then
               begin
                 if Bank_Account.baFields.baTemp_Balance <> unknown then
                 begin
                   Bank_Account.baFields.baTemp_Balance := Bank_Account.baFields.baTemp_Balance + txAmount;
                   Bal := Bank_Account.baFields.baTemp_Balance;
                   ShowBal := True;
                 end
                 else
                   ShowBal := False;
               end;
               Rpt.PutNarrationNotes( ReportJob, txGL_Narration,GetFullNotes(Transaction), ShowBal, Bal);
            end;
      end; { Case clCountry }
      RenderDetailLine;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure LE_EnterDissect(Sender : TObject);
var
   Mgr : TTravManagerWithNewReport;
   Rpt : TListEntriesReport;
begin
   Mgr := TTravManagerWithNewReport(Sender);
   Rpt := TListEntriesReport( Mgr.ReportJob );
   With Mgr, Rpt, Rpt.Params, Bank_Account, Transaction^, Dissection^ do
   Begin
      if (not JournalOnly) and (not LE_IsBankAccountIncluded(ReportJob, Mgr)) then exit;

      PutString( '' ); { Date }
      case Client.clFields.clCountry of
         whNewZealand :
            Begin
               If txDate_Transferred <> 0 then
                  PutString( 'Yes' )
               else
                  SkipColumn;

               PutString(dsReference);

               PutString( ' /'+IntToStr( dsSequence_No ) ); { Reference }
               PutString( dsAccount );

               If TwoColumn then
               Begin
                  If dsAmount >= 0 then
                  Begin
                     PutMoneyDontAdd( Trunc( dsAmount ) );
                     SkipColumn;
                  end
                  else
                  Begin
                     SkipColumn;
                     PutMoneyDontAdd( Trunc( dsAmount ) );
                  end;
               end
               else
                  PutMoneyDontAdd( Trunc( dsAmount ) );

               if JournalOnly then
                 PutMoney( Trunc( dsGST_Amount));

               if ShowOP then begin
                  PutString( '' );
                  Rpt.PutNarrationNotes( ReportJob, dsGL_Narration,GetFullNotes(Dissection), False, 0);
               end
               else
                  Rpt.PutNarrationNotes( ReportJob, dsGL_Narration,GetFullNotes(Dissection), False, 0);
            end;

         whAustralia, whUK :
            Begin
               If txDate_Transferred <> 0 then
                  PutString( 'Yes' )
               else
                  SkipColumn;

               if dsReference <> '' then
                 PutString(dsReference)
               else
                 PutString( ' /'+IntToStr( dsSequence_No ) ); { Reference }

               PutString( dsAccount );

               If TwoColumn then
               Begin
                  If dsAmount >= 0 then
                  Begin
                     PutMoneyDontAdd( Trunc( dsAmount ) );
                     SkipColumn;
                  end
                  else
                  Begin
                     SkipColumn;
                     PutMoneyDontAdd( Trunc( dsAmount ) );
                  end;
               end
               else
                  PutMoneyDontAdd( Trunc( dsAmount ) );

               PutMoney( Trunc( dsGST_Amount));

               Rpt.PutNarrationNotes( ReportJob, dsGL_Narration,GetFullNotes( Dissection), False, 0);
             end;
      end; { Case clCountry }
      RenderDetailLine;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure LE_ExitEntry(Sender : TObject);
var
 Mgr : TTravManagerWithNewReport;
begin
 Mgr := TTravManagerWithNewReport(Sender);
 With Mgr.ReportJob, Mgr.Transaction^, TListEntriesReport(Mgr.ReportJob).params do begin

   if (not JournalOnly) and (not LE_IsBankAccountIncluded(Mgr.ReportJob, Mgr)) then exit;

   if txFirst_Dissection <> nil then
     RenderTextLine('');
 end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TListEntriesReport.PutNotes(Notes: string);
var
  j, ColWidth, OldWidth, MaxNotesLines : Integer;
  ColsToSkip : integer;
  NotesList  : TStringList;
begin
  if params.WrapNarration then
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
        if ( j < notesList.Count) and ( j < MaxNotesLines) then
        begin
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
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// PutNarrationNotes
//
// Outputs Narration and Notes columns but wraps text onto multiple lines
// if need be.
//
procedure TListEntriesReport.PutNarrationNotes(Job: TBKReport; Narration, Notes : string; ShowBal: Boolean; Bal: Money);
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
    NarrLines := SplitLine(CurrDetail.Count, NarrList);
    NoteLines := SplitLine(Pred(Columns.ItemCount), NotesList);//notes is always the last column
    if (NarrLines > 1) and (not params.WrapNarration) then
      NarrLines := 1;
    if (NoteLines > 1) and (not params.WrapNarration) then
      NoteLines := 1;

    if not params.ShowNotes then
      NoteLines := 0;

    MaxLines := NarrLines;
    if (NoteLines > NarrLines) then
      MaxLines := NoteLines;
    if (MaxLines > MaxLinesAllowed) then
      MaxLines := MaxLinesAllowed;

    if (MaxLines = 0) then
    begin
      SkipColumn;
      if params.ShowBalance then
      begin
        if ShowBal then
          PutMoney(Bal)
        else
          SkipColumn;
      end;
      SkipColumn;
    end else
    begin
      for i := 0 to MaxLines-1 do
      begin
        if (i < NarrLines) then
          PutString(NarrList[i])
        else
          SkipColumn;
        if params.ShowBalance then
        begin
          if ShowBal and (i = 0) then
            PutMoney(Bal)
          else
            SkipColumn;
        end;
        if (i < NoteLines) then
          PutString(NotesList[i])
        else
          SkipColumn;
        if (i < MaxLines-1) then
        begin
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
function TListEntriesReport.SplitLine(ColIdx: Integer; var TextList: TStringList) : Integer;
const
  MaxLines = 10;
var
  j, ColWidth, OldWidth : Integer;
begin
  j := 0;
  while j < TextList.Count do
  begin
    if TextList[j] = '' then
      TextList.Delete(j)
    else
      Inc(j);
  end;
  if (TextList.Count = 0) then
    Result := 0
  else
  begin
      j := 0;
      repeat
        ColWidth := RenderEngine.RenderColumnWidth(ColIdx, TextList[ j]);
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
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TListEntriesReport.BKPrint;
var
   TravMgr : TTravManagerWithNewReport;
   i       : integer;
begin
  TravMgr := TTravManagerWithNewReport.Create;
  try
     TravMgr.Clear;
     TravMgr.SortType := params.SortBy;
     case params.Include of
       esUncodedOnly : TravMgr.SelectionCriteria := TravList.twAllUncoded;
     else
       TravMgr.SelectionCriteria := TravList.twAllEntries;
     end;
     TravMgr.ReportJob := Self;

     if params.SortBy = csDateEffective then
     begin
       //csDateEffective;
       TravMgr.OnEnterAccount := LE_EnterAccount;
       TravMgr.OnExitAccount  := LE_ExitAccount;
       TravMgr.OnEnterEntry   := LE_EnterEntry;
     end
     else
     begin
       //csDatePresented
       TravMgr.OnEnterAccount := LE_EnterAccount_Pres;
       TravMgr.OnExitAccount  := LE_ExitAccount_Pres;
       TravMgr.OnEnterEntry   := LE_EnterEntry_Pres;
     end;

     TravMgr.OnExitEntry       := LE_ExitEntry;
     TravMgr.OnEnterDissection := LE_EnterDissect;

     if params.JournalOnly then begin
         for I := 0 to params.AccountList.Count - 1 do
            With TBank_Account( params.AccountList[i] ), baFields do
               if IsaJournalAccount
               {and (baAccount_Type <> btStockBalances)} then
                   TravMgr.TraverseAccount(TBank_Account( params.AccountList[i] ),params.Fromdate,params.ToDate);
     end else begin
        TravMgr.TraverseAllAccounts(params.Fromdate,params.Todate);
     end;
  finally
    TravMgr.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoListEntriesReport(Dest : TReportDest;
                              ShowJournalOnly : boolean ;
                              RptBatch : TReportBase = nil);
//uses two column layout if set for coding report
var
   Job        : TListEntriesReport;
   S          : string;
   cleft: Double;
   LParams: TListEntriesParam;

   ExtraWidth : double;  //available if coding style is single col
   HasSomeEntries: Boolean;
   BA: TBank_Account;
   i, Button: Integer;
   MONEY_FORMAT : String;
   ISOCodes: string;
   NonBaseCurrency: Boolean;
begin
   NonBaseCurrency := False;
   LParams    := TListEntriesParam.Create(ord(Report_Last),MyClient, RptBatch,dPeriod );
   try
      LParams.GetBatchAccounts;
      repeat

      HasSomeEntries := False;

      while not HasSomeEntries do begin
         if lparams.BatchRun then begin
            // All done...
         end else begin
            // Get the Details..

            if ShowJournalOnly then begin
               Lparams.ReportType := ord(REPORT_LIST_JOURNALS);

               // If Batchless.. this is more or less meaningless
               if not EnterPrintDateRangeOptions('List Journals','Enter the starting and finishing date for the journals you want to list.',
                                    LParams.FromDate, LParams.ToDate, BKH_List_journals, true,
                                    [], Button, LParams, LParams.WrapNarration, NonBaseCurrency, True, False,[btCashJournals..btStockBalances]) then exit;
               // Is a bid odd..
               LParams.TwoColumn := (LParams.Client.clFields.clCoding_Report_Style = rsTwoColumn);
               LParams.SortBy := csDateEffective; // Just to be sure...
               Lparams.Include :=  esAllEntries;
               LParams.ShowNotes := False;
               LParams.ShowBalance := False;

               i := 0;
               while i < LParams.AccountList.Count do
               begin
                 ba := LParams.AccountList[i];
                 if  BA.baFields.baAccount_Type = btStockBalances then
                   LParams.AccountList.Delete(i)
                 else
                  Inc(i);
               end;
            end else begin
               Lparams.ReportType := ord(REPORT_LIST_ENTRIES);
               if not EnterLEPrintDateRange( 'List Entries','Enter the starting and finishing date for the entries you want to list.',
                                              LParams.FromDate,
                                              LParams.ToDate,
                                              BKH_List_entries,
                                              true,
                                              LParams) then
                   exit;
            end;
         end;

         if LParams.RunBtn = BTN_SAVE then begin
            if ShowJournalOnly then
               // Fine..
            else begin
               // Check the actual report type
               if LParams.ShowNotes then
                  LParams.RptBatch.Title := Report_List_Names[Report_List_Entries_With_Notes]
               else
                  LParams.RptBatch.Title := Report_List_Names[REPORT_LIST_ENTRIES];
            end;
            lParams.SaveNodeSettings;
            Exit;
         end else if (LParams.BatchRunMode = R_Normal) then
           LParams.SaveClientSettings;

         case LParams.RunBtn of
            BTN_PRINT   : Dest := rdPrinter;
            BTN_PREVIEW : Dest := rdScreen;
            BTN_FILE    : Dest := rdFile;
            BTN_SAVE    : Dest := rdNone;
            BTN_EMAIL   : Dest := rdEmail;
            else          Exit;
         end;

         MONEY_FORMAT := MyClient.FmtMoneyStr;

         //check for entries
         HasSomeEntries := False;
         if ShowJournalOnly then begin
            for i := 0 to Pred(LParams.AccountList.Count) do begin
               ba := LParams.AccountList[i];
               if  BA.IsAJournalAccount
               and LE_HasTransactions(LParams.FromDate,LParams.Todate , BA) then begin
                 HasSomeEntries := True;
                 Break;
               end;
            end;
         end else begin
            for i := 0 to Pred(LParams.AccountList.Count) do begin
               ba := LParams.AccountList[i];
               if LE_HasTransactions(LParams.FromDate, LParams.Todate,ba ) then begin
                  HasSomeEntries := True;
                  Break;
               end;
            end;
         end;



         if not HasSomeEntries then
            if LParams.BatchRun then begin
               RptBatch.RunResult := 'No Entries in date range , '
                              +bkDate2Str(LParams.FromDate)+' to '+bkDate2Str(LParams.Todate)+'.';


               Exit;
               // Was meant to run direct... Just Exit
            end else
             HelpfulWarningMsg('There are no Entries for this client in the date range , '
                              +bkDate2Str(LParams.FromDate)+' to '+bkDate2Str(LParams.Todate)+'.',0);
     end; //While HasSomeEntries


     if Dest = rdNone then
       Continue;

     //Flag bank accounts included in the report
     for i := 0 to Pred(MyClient.clBank_Account_List.ItemCount) do
       MyClient.clBank_Account_List.Bank_Account_At(i).baFields.baTemp_Include_In_Report := False;
     for i := 0 to Pred(LParams.AccountList.Count) do
       TBank_Account(LParams.AccountList[i]).baFields.baTemp_Include_In_Report := True;
     //Check exchange rates
     if not MyClient.HasExchangeRates(ISOCodes, LParams.FromDate, LParams.ToDate, True, False) then begin
       HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' + ISOCodes + '.',0);
       Continue;
     end;

     Job := TListEntriesReport.Create(ReportTypes.rptListings);
     job.Params := LParams;
     try
       if not ShowJournalOnly then
       begin
         if not job.Params.ShowNotes then
         begin
            Job.LoadReportSettings(UserPrintSettings,
              Job.Params.MakeRptName(Report_List_Names[REPORT_LIST_ENTRIES]));
            job.Params.JournalOnly := false;
         end
         else
         begin
            Job.LoadReportSettings(UserPrintSettings,
               Job.Params.MakeRptName(Report_List_Names[Report_List_Entries_With_Notes]));
            Job.Params.JournalOnly := false;
         end;
       end
       else
       begin
            Job.LoadReportSettings(UserPrintSettings,
               Job.Params.MakeRptName(Report_List_Names[REPORT_LIST_JOURNALS]));
            Job.Params.JournalOnly := true;

       end;

       //Add Headers
       AddCommonHeader(Job);

       S := 'FROM ';
       If Job.Params.FromDate =0 then
          S := S + 'FIRST'
       else
          S := S + bkDate2Str( Job.Params.FromDate );
       S := S + ' TO ';
       If Job.Params.ToDate=MaxLongInt then
          S := S + 'LAST'
       else
          S := S + bkDate2Str( Job.Params.ToDate );

       if (not ShowJournalOnly) then
       begin
         if not Job.Params.ShowNotes then
           AddJobHeader(Job,siTitle,'LIST ENTRIES '+S, true)
         else
           AddJobHeader(Job,siTitle,'LIST ENTRIES (incl Notes) '+S, true);

           if (Job.Params.SortBy <> csDateEffective) then
             S := 'BY DATE PRESENTED'
           else
             S := 'BY DATE EFFECTIVE';

           if (Job.Params.Include = esAllEntries) then
             S := S + ', ALL ENTRIES'
           else
             S := S + ', UNCODED/INVALIDLY CODED ENTRIES';

          AddJobHeader(Job,siSubtitle,S,true);
       end
       else
           AddJobHeader(Job,siTitle,'LIST JOURNALS '+S, true);

       AddJobHeader(Job,siSubTitle,'',true);
       //Build the columns
       with Job.Params, Client.clFields do
       begin
         if not Job.Params.ShowNotes then
         begin
           {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
           CLeft := Gcleft;

           //extra 10% if available if not showing two columns
           ExtraWidth := 0.0;

           case clCountry of
              whNewZealand :
                 Begin
                    if not ShowBalance then
                      ExtraWidth := ExtraWidth + 3.0;
                    if not TwoColumn then
                      ExtraWidth := ExtraWidth + 3.0;

                    AddColAuto(Job,cleft,2.7 ,Gcgap,'Tfr',jtLeft);
                    AddColAuto(Job,cleft,6.3 ,Gcgap, 'Date'     , jtLeft);
                    AddColAuto(Job,cleft,10 + ExtraWidth ,Gcgap, 'Reference', jtLeft);
                    AddColAuto(Job,cleft,9.0 + ExtraWidth ,Gcgap, 'Analysis' , jtLeft);
                    AddColAuto(Job,cleft,8.0 ,Gcgap, 'Account'  , jtLeft);

                    if TwoColumn then  {these should be totalled on}
                    begin
                      Job.CRAmountCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Withdrawals',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
                      Job.DRAmountCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Deposits',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
                    end
                    else
                      Job.AmountCol := AddFormatColAuto(Job,cleft,11.0 + Gcgap,Gcgap,'Amount',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);

                    if ShowJournalOnly then // Show GST for journals as per OZ
                      Job.TaxCol := AddFormatColAuto( Job, cLeft, 8, Gcgap, 'GST', jtRight,MONEY_FORMAT,MONEY_FORMAT, true);
//                      Job.TaxCol := AddFormatColAuto( Job, cLeft, 8, Gcgap, 'GST', jtRight,NUMBER_FORMAT_SIGNED,NUMBER_FORMAT_SIGNED, true);

                    if ShowOp then
                    begin
                       AddColAuto(Job,cleft,14.0 + ExtraWidth ,Gcgap,'Other Party',jtLeft);
                       AddColAuto(Job,cleft,9.0 + ExtraWidth,Gcgap,'Particulars',jtLeft);
                    end
                    else
                       AddColAuto(Job,cleft,23 + ( 2 * ExtraWidth),Gcgap,'Narration',jtLeft);

                    if ShowBalance then
                      Job.BalanceCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Balance',jtRight,BAL_FORMAT,BAL_FORMAT,false);
                 end;
              whAustralia, whUK :
                 Begin
                    if not ShowBalance then
                      ExtraWidth := ExtraWidth + 4.0;
                    if not TwoColumn then
                      ExtraWidth := ExtraWidth + 4.0;

                    AddColAuto(Job,cleft,2.7 ,Gcgap,'Tfr',jtLeft);
                    AddColAuto(Job,cleft,6.3 ,Gcgap,'Date', jtLeft);
                    AddColAuto(Job,cleft,10 + ExtraWidth ,Gcgap,'Reference',jtLeft);
                    AddColAuto(Job,cleft,8.0,Gcgap,'Account',jtLeft);

                    if TwoColumn then  {these should be totalled on}
                    begin
                      Job.CRAmountCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Withdrawals',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
                      Job.DRAmountCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Deposits',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
                    end
                    else
                      Job.AmountCol := AddFormatColAuto(Job,cleft,11.0,Gcgap,'Amount',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);

                    Job.TaxCol := AddFormatColAuto( Job, cLeft, 8, Gcgap, Localise( clCountry, 'GST') , jtRight,MONEY_FORMAT,MONEY_FORMAT, true);
                    AddColAuto(Job,cLeft, 23.8 + ( 2 * ExtraWidth ),Gcgap, 'Narration',jtLeft);

                    if ShowBalance then
                      Job.BalanceCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Balance',jtRight,BAL_FORMAT,BAL_FORMAT,false);
                 end;
           end; { Case clCountry }
         end
         else
         begin
           //do list entries report with notes, this report is landscape by default
           {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
           CLeft := GcLeft;
           ExtraWidth := 0.0;

           case clCountry of
              whNewZealand :
                 Begin
                    if not ShowBalance then
                      ExtraWidth := ExtraWidth + 8.6/5;
                    if not TwoColumn then
                      ExtraWidth := ExtraWidth + 8.6/5;

                    AddColAuto(Job,cleft,2.0 ,GcGap,'Tfr',jtLeft);
                    AddColAuto(Job,cleft,4.5 ,GcGap, 'Date'     , jtLeft);
                    AddColAuto(Job,cleft,8.0 + ExtraWidth ,GcGap, 'Reference', jtLeft);
                    AddColAuto(Job,cleft,7.0 + ExtraWidth ,GcGap, 'Analysis' , jtLeft);
                    AddColAuto(Job,cleft,7.0 ,Gcgap, 'Account'  , jtLeft);

                    if TwoColumn then  {these should be totalled on}
                    begin
                      Job.CRAmountCol := AddFormatColAuto(Job,cLeft,8.0,Gcgap,'Withdrawals',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
                      Job.DRAmountCol := AddFormatColAuto(Job,cLeft,8.0,Gcgap,'Deposits',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
                    end
                    else
                      Job.AmountCol := AddFormatColAuto(Job,cleft,8.0,Gcgap,'Amount',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);

                    if ShowOp then begin
                       AddColAuto(Job,cleft,10.0 + ExtraWidth,Gcgap,'Other Party',jtLeft);
                       AddColAuto(Job,cleft,8.0 + ExtraWidth,Gcgap,'Particulars',jtLeft);
                    end
                    else
                       AddColAuto(Job,cleft,18 + ( 2 * ExtraWidth),Gcgap,'Narration',jtLeft);

                    if ShowBalance then
                      Job.BalanceCol := AddFormatColAuto(Job,cLeft,8.0,Gcgap,'Balance',jtRight,BAL_FORMAT,BAL_FORMAT,false);

                    AddColAuto(Job,cLeft, 25 + ExtraWidth, Gcgap, 'Notes', jtLeft);
                 end;
              whAustralia, whUK :
                 Begin
                    if not ShowBalance then
                      ExtraWidth := ExtraWidth + 3.0;
                    if not TwoColumn then
                      ExtraWidth := ExtraWidth + 3.0;

                    AddColAuto(Job,cleft,2.0 ,Gcgap,'Tfr',jtLeft);
                    AddColAuto(Job,cleft,4.5 ,Gcgap,'Date', jtLeft);
                    AddColAuto(Job,cleft,8.0 + ExtraWidth ,Gcgap,'Reference',jtLeft);
                    AddColAuto(Job,cleft,6.2,Gcgap,'Account',jtLeft);

                    if TwoColumn then  {these should be totalled on}
                    begin
                      Job.CRAmountCol := AddFormatColAuto(Job,cLeft,8.0,Gcgap,'Withdrawals',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
                      Job.DRAmountCol := AddFormatColAuto(Job,cLeft,8.0,Gcgap,'Deposits',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
                    end
                    else
                      Job.AmountCol := AddFormatColAuto(Job,cleft,8.0,Gcgap,'Amount',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);

                    Job.TaxCol := AddFormatColAuto( Job, cLeft, 7, Gcgap, Localise( clCountry, 'GST' ), jtRight,MONEY_FORMAT,MONEY_FORMAT, true);
                    AddColAuto(Job,cLeft, 19 + ( 2 * ExtraWidth ),Gcgap, 'Narration',jtLeft);

                    if ShowBalance then
                      Job.BalanceCol := AddFormatColAuto(Job,cLeft,9.0 ,Gcgap,'Balance',jtRight,BAL_FORMAT,BAL_FORMAT,false);

                    AddColAuto(Job,cLeft, 23 ,Gcgap ,'Notes', jtLeft);
                 end;
           end; { Case clCountry }
         end;
       end;

       //Add Footers
       AddCommonFooter(Job);

       Job.Generate(Dest, Lparams);

       if LParams.BatchRun then
           RptBatch.RunResult := 'Ok';
     finally
      Job.Free;
     end;

   until LParams.RunExit(dest);
   finally
    lParams.Free;
   end;
end;

{----------------------------------------------------}
{               List Chart of Accounts               }
{----------------------------------------------------}

procedure ListChartDetail(Sender : TObject);
var
   i,j     : integer;
   S       : string;
begin
   with TChartListReport(Sender) do
   begin
    {render detail}
    With TChartListReport(Sender).Chart, MyClient.clFields do
      For I := 0 to Pred( ItemCount ) do With Account_At( I )^ do
      Begin
         if ShowBasicChart and chHide_In_Basic_Chart then
           Continue;

         if not ShowInactive and chInactive then
           continue;

         PutString( chAccount_Code );
         PutString( chAccount_Description );

         if HasAlternativeChartCode(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used) then
            PutString( chAlternative_Code );
            
         //account type
         if chAccount_Type in [atMin..atMax] then
            PutString( Localise(clCountry, atNames[ chAccount_Type ] ));

         if ShowSubTypes then begin
            //account syb type
            if ( chSubType in [ 1..Max_SubGroups ] ) then
            Begin
               S := Trim( MyClient.clCustom_Headings_List.Get_SubGroup_Heading( chSubType));
               if s = '' then
                 s := Inttostr( chSubType);
            end
            else
              S := '';
            PutString( S);
         end;

         if ShowDivisions then begin
            //divisions list
            S := '';
            for j := 1 to Max_Divisions do begin
               if chPrint_in_Division[j] then begin
                  S := S + inttostr(j) + ', ';
               end;
            end;
            PutString( S);
         end;

         //GST class
         If ( chGST_Class in GST_CLASS_RANGE ) then
            PutString( clGST_Class_Codes[ chGST_Class ] + ' ' +  clGST_Class_Names[ chGST_Class ] )
         else
            PutString( '' );

         if not ShowBasicChart then
         begin
          if chHide_In_Basic_Chart then
            PutString( '' )
          else
            PutString( 'Y' );
         end;

          //Posting
         if chPosting_Allowed then
            PutString( 'Y' )
         else
            PutString( '' );

         // Inactive
         if ShowInactive then
         begin
           if chInactive then
             PutString('Y')
           else
             PutString('');
         end;

         RenderDetailLine;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoChartListReport(Dest : TReportDest;
                           Settings : TPrintManagerObj;
                           Scheduled : boolean;
                           FaxParams : TFaxParameters = nil;
                           RptBatch : TReportBase = nil) : boolean; overload;
const
  COL_CODE_WIDTH : extended = 10.0;
  COL_DESCRIPTION_WIDTH : extended = 19.0;
  COL_ALT_CHART_CODE_WIDTH : extended = 10.0;
  COL_ACC_GROUP_WIDTH : extended = 11.0;
  COL_SUB_GROUP_WIDTH : extended = 11.0;
  COL_DIVISION_WIDTH : extended = 8.0;
  COL_CLASS_WIDTH : extended = 12.0;
  COL_BASIC_WIDTH : extended = 6.0;
  COL_POSTING_WIDTH : extended = 6.0;
  COL_INACTIVE_WIDTH : extended = 6.0;
var
  Job : TChartListReport;
  AdditionalSpace : extended;
  MissingColumns  : integer;
  i,j : integer;
  SubTypesFound : boolean;
  DivisionFound : boolean;
  cLeft         : double;
  ShowBasic     : Boolean;
  ShowAltChartCode : boolean;
  AltChartCodeName : string;
  JobParam : TRPTParameters;
begin
  result := false;  //result only used by faxing

  JobParam := TRPTParameters.Create(ord(Report_List_Chart),MyClient,Rptbatch);
  JobParam.Scheduled := Scheduled;
  try

    ShowBasic := JobParam.GetBatchBool('Show_Basic', True);
    repeat
      //if (Dest = rdNone) then
      //or JobParam.BatchSetup then
      if not Scheduled then
      begin
        if GetChartReportOptions(ShowBasic, JobParam) then
        case JobParam.RunBtn of
          BTN_PRINT   : Dest := rdPrinter;
          BTN_PREVIEW : Dest := rdScreen;
          BTN_FILE    : Dest := rdFile;
          BTN_EMAIL   : Dest := rdEmail;
          BTN_SAVE  : begin
               JobParam.SaveNodeSettings;
               JobParam.SetBatchBool('Show_Basic', ShowBasic);
               Exit;
          end;
        end
        else
          exit;
      end;


      //see if client has divisions or sub types setup, if none found then
      //dont show on report, if this is the case then we can expand the other columns
      SubTypesFound := false;
      DivisionFound := false;

      with JobParam.Chart do
      begin
        for i := 0 to Pred( ItemCount) do
        begin
          if Account_At( i)^.chSubtype <> 0 then
            SubTypesFound := true;

          for j := 1 to Max_Divisions do
          begin
            if Account_At( i)^.chPrint_in_Division[ j] then
              DivisionFound := true;
          end;
        end;
      end;


      Job := TChartListReport.Create(ReportTypes.rptListings);
      try
        Job.Chart := JobParam.Chart;
        Job.LoadReportSettings(Settings,
           JobParam.MakeRptName( Report_List_Names[REPORT_LIST_CHART]));
        Job.ShowSubTypes   := SubTypesFound;
        Job.ShowDivisions  := DivisionFound;
        Job.ShowBasicChart := ShowBasic;
        Job.ShowInactive   := not Scheduled;
        ShowAltChartCode := HasAlternativeChartCode(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used);
        AltChartCodeName := '';
        AdditionalSpace := 0;
        MissingColumns  := 0;

        // Calculate Additional Space and how many columns are affected
        if not ShowAltChartCode then
          AdditionalSpace := AdditionalSpace + COL_ALT_CHART_CODE_WIDTH
        else
          AltChartCodeName := AlternativeChartCodeName(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used);

        if not SubTypesFound then
        begin
          AdditionalSpace := AdditionalSpace + COL_SUB_GROUP_WIDTH;
          Inc( MissingColumns);
        end;

        if not DivisionFound then
        begin
          AdditionalSpace := AdditionalSpace + COL_DIVISION_WIDTH;
          Inc( MissingColumns);
        end;

        if ShowBasic then
        begin
          AdditionalSpace := AdditionalSpace + COL_BASIC_WIDTH;
        end;

        if not Job.ShowInactive then
        begin
          AdditionalSpace := AdditionalSpace + COL_INACTIVE_WIDTH;
        end;

        //additional space is spread across account group, sub group, division and gst cols
        if AdditionalSpace <> 0 then
          AdditionalSpace := AdditionalSpace / ( 5 - MissingColumns);

        //Add Headers
        AddCommonHeader(Job);
        AddJobHeader(Job,siTitle,'CHART OF ACCOUNTS',true);
        AddJobHeader(Job,siSubTitle,'',true);

        //Build the columns
        cLeft := GcLeft;

        // Setup Columns
        AddColAuto(Job, cLeft, COL_CODE_WIDTH, Gcgap, 'Code', jtLeft);

        AddColAuto(Job, cLeft, COL_DESCRIPTION_WIDTH + AdditionalSpace, Gcgap, 'Description', jtLeft);

        if ShowAltChartCode then
          AddColAuto(Job, cLeft, COL_ALT_CHART_CODE_WIDTH, Gcgap, AltChartCodeName, jtLeft);

        AddColAuto(Job, cLeft, COL_ACC_GROUP_WIDTH + AdditionalSpace, Gcgap, 'Account Group', jtLeft);

        if SubTypesFound then
          AddColAuto(Job, cLeft, COL_SUB_GROUP_WIDTH + AdditionalSpace, Gcgap, 'Sub-group', jtLeft);

        if DivisionFound then
          AddColAuto(Job, cLeft, COL_DIVISION_WIDTH + AdditionalSpace, Gcgap, 'Divisions', jtLeft);

        AddColAuto(Job, cLeft, COL_CLASS_WIDTH + AdditionalSpace, Gcgap, MyClient.TaxSystemNameUC + ' Class', jtLeft);

        if not ShowBasic then
          AddColAuto(Job, cLeft, COL_BASIC_WIDTH, Gcgap, 'Basic', jtLeft);

        AddColAuto(Job, cLeft, COL_POSTING_WIDTH, Gcgap, 'Posting', jtLeft);

        if Job.ShowInactive then
          AddColAuto(Job,cLeft, COL_INACTIVE_WIDTH, Gcgap, 'Inactive', jtLeft);

        //Add Footers
        AddCommonFooter(Job);

        Job.OnBKPrint := ListChartDetail;
        if Scheduled and ( Dest = rdEmail ) then
        begin
          //special case for scheduled reports.  Don't want the user to be asked
          //what file name to use
          case MyClient.clFields.clEmail_Report_Format of
            rfCSV :
              Job.GenerateToFile( EmailOutboxDir + MyClient.clFields.clCode + '.CHC', rfCSV, JobParam);
            rfFixedWidth :
              Job.GenerateToFile( EmailOutboxDir + MyClient.clFields.clCode + '.CHT', rfFixedWidth, JobParam);
            rfPDF :
              Job.GenerateToFile( EmailOutboxDir + MyClient.clFields.clCode + '.CHP', rfPDF, JobParam);
            rfExcel :
              Job.GenerateToFile( EmailOutboxDir + MyClient.clFields.clCode + '.CHX', rfExcel, JobParam);
          end;
        end
        else if ( Dest = rdFax) then
        begin
          result := Job.GenerateToFax(FaxParams, AdminSystem.fdFields.fdSched_Rep_Fax_Transport, JobParam)
        end
        else
          Job.Generate(Dest, Jobparam);

      finally
        Job.Free;
      end;

    until Jobparam.RunExit(Dest);
  finally
    JobParam.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoChartListReport(Dest : TReportDest;
                            RptBatch : TReportBase = nil); overload;
begin
  //standard report call
  DoChartListReport( Dest, UserPrintSettings, false,Nil, RptBatch);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


procedure ListFCBankDetail(Sender:TObject);
var
   i       : integer;
   Bank_Account : TBank_Account;
begin
   with TBKReport(Sender) do
   begin
    {render detail}
    for i := 0 to Pred(MyClient.clBank_Account_List.ItemCount) do
    begin
       Bank_Account := MyClient.clBank_Account_List.Bank_Account_At(i);
       if Bank_Account.baFields.baAccount_Type = btStockBalances then Continue;
       With Bank_Account, baFields do
       Begin
          PutString( baBank_Account_Number );
          PutString( baBank_Account_Name );
          PutString( bkDate2Str( baTransaction_List.FirstPresDate));
          PutString( bkDate2Str( baTransaction_List.LastPresDate ));
          PutCurrency( baTransaction_List.ItemCount );
          PutString( baCurrency_Code );
          if baCurrent_Balance <> Unknown then
             PutMoney   ( baCurrent_Balance )
          else
             PutMoney(0);
          RenderDetailLine;
       end;
    end;
  RenderDetailGrandTotal('');
  end;
end;

procedure DoListFCBankAccountsReport(Dest : TReportDest;
                              RptBatch : TReportBase = nil);
var
   Job: TBKReport;
   Param: TRPTParameters;
   cleft: Double;
begin
   Param := TRPTParameters.Create(ord(REPORT_LIST_BANKACCTS), MyClient,RptBatch);
   Job := TBKReport.Create(ReportTypes.rptListings);
   try

     Job.LoadReportSettings(UserPrintSettings,
        param.MakeRptName(  Report_List_Names[REPORT_LIST_BANKACCTS]));

     //Add Headers
     AddCommonHeader(Job);
     AddJobHeader(Job,siTitle,'LIST CLIENT BANK ACCOUNTS',true);
     AddJobHeader(Job,siSubTitle,'',true);

     //Build the columns
     cLeft := gcLeft;
     AddColAuto(Job,cLeft,      17,gcgap,'Number', jtLeft);
     AddColAuto(Job,cLeft,      20,gcgap,'Name',jtLeft);
     AddColAuto(Job,cLeft,      10,gcgap,'Entries From',jtLeft);
     AddColAuto(Job,cLeft,      10,gcgap,'Entries To', jtLeft);
     AddFormatColAuto(Job,cleft,10,gcgap,'No. Entries',jtRight,'#,##','#,##',true);
     AddColAuto(Job,cLeft,      10,gcgap,'Currency',jtLeft);

     AddFormatColAuto(Job,cleft,17,gcgap,'Current Balance',jtRight,
        MyClient.FmtBalanceStrNoSymbol, MyClient.FmtBalanceStrNoSymbol, False );

     //Add Footers
     AddCommonFooter(Job);

     Job.OnBKPrint := ListFCBankDetail;
     Job.Generate(Dest, Param);
   finally
    Job.Free;
    Param.Free;
   end;
end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ListBankDetail(Sender:TObject);
var
   i       : integer;
   Bank_Account : TBank_Account;
begin
   with TBKReport(Sender) do
   begin
    {render detail}
    for i := 0 to Pred(MyClient.clBank_Account_List.ItemCount) do
    begin
       Bank_Account := MyClient.clBank_Account_List.Bank_Account_At(i);
       if Bank_Account.baFields.baAccount_Type = btStockBalances then Continue;
       With Bank_Account, baFields do
       Begin
          PutString( baBank_Account_Number );
          PutString( baBank_Account_Name );
          PutString( bkDate2Str( baTransaction_List.FirstPresDate));
          PutString( bkDate2Str( baTransaction_List.LastPresDate ));
          PutCurrency( baTransaction_List.ItemCount );
          if baCurrent_Balance <> Unknown then
             PutMoney   ( baCurrent_Balance )
          else
             PutMoney(0);

          RenderDetailLine;
       end;
    end;
  RenderDetailGrandTotal('');
  end;
end;       

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoListBankAccountsReport(Dest : TReportDest;
                              RptBatch : TReportBase = nil);
var
   Job: TBKReport;
   Param: TRPTParameters;
   cleft: Double;
begin
  if MyClient.HasForeignCurrencyAccounts then
  Begin
    DoListFCBankAccountsReport( Dest, RptBatch );
    exit;
  End;

   Param := TRPTParameters.Create(ord(REPORT_LIST_BANKACCTS), MyClient,RptBatch);
   Job := TBKReport.Create(ReportTypes.rptListings);
   try

     Job.LoadReportSettings(UserPrintSettings,
        param.MakeRptName(  Report_List_Names[REPORT_LIST_BANKACCTS]));

     //Add Headers
     AddCommonHeader(Job);
     AddJobHeader(Job,siTitle,'LIST CLIENT BANK ACCOUNTS',true);
     AddJobHeader(Job,siSubTitle,'',true);

     //Build the columns
     cLeft := gcLeft;
     AddColAuto(Job,cLeft,      17,gcgap,'Number', jtLeft);
     AddColAuto(Job,cLeft,      30,gcgap,'Name',jtLeft);
     AddColAuto(Job,cLeft,      10,gcgap,'Entries From',jtLeft);
     AddColAuto(Job,cLeft,      10,gcgap,'Entries To', jtLeft);
     AddFormatColAuto(Job,cleft,10,gcgap,'No. Entries',jtRight,'#,##','#,##',true);
     AddFormatColAuto(Job,cleft,17,gcgap,'Current Balance',jtRight,
        MyClient.FmtBalanceStrNoSymbol, MyClient.FmtBalanceStr, True );

     //Add Footers
     AddCommonFooter(Job);

     Job.OnBKPrint := ListBankDetail;
     Job.Generate(Dest, Param);
   finally
    Job.Free;
    Param.Free;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoListPayeesReport(Dest : TReportDest;
                            Settings : TPrintManagerObj;
                            Scheduled : boolean;
                            FaxParams : TFaxParameters = nil;
                            RptBatch : TReportBase = nil) : boolean; overload;
var
  Job : TPayeeListReport;
  lParams : TListPayeesParam;
  cLeft: Double;
begin
  Result := false;
  lParams := TListPayeesParam.Create(ord(REPORT_LIST_PAYEE), MyClient, RptBatch);
  try
    lParams.Scheduled := Scheduled;
    repeat
      if Scheduled then
        lParams.Detailed := false
      else begin
        // May need To ask..

        if Lparams.BatchRun then
          // Just run..
        else begin
          Dest := rdScreen;

          //Get payee list options
          if GetPayeeReportOptions(Dest, LParams) then begin
            if LParams.BatchSave then begin
              lparams.SaveNodesettings;
              Exit;
            end else if (LParams.BatchRunMode = R_Normal) then
              LParams.SaveClientSettings;

          end else
            Exit;
        end;
      end;

      if lParams.Detailed then
      begin
        Job := TPayeeListReport.Create(ReportTypes.rptListings);
        try
          Job.FParams := LParams;
          Job.LoadReportSettings(Settings,
            LParams.MakeRptName ( Report_List_Names[REPORT_LIST_PAYEE]));

          if PRACINI_RestrictFileFormats then
            Job.FileFormats := [ ffPDF, ffAcclipse];

          //Add Headers
          AddCommonHeader(Job);
          AddJobHeader(Job,siTitle,'LIST PAYEES (DETAILED)',true);
          AddJobHeader(Job,siSubTitle,'',true);

          //Build the columns
          cLeft := GCLeft;
          if Scheduled then
          begin
            // Normal settings
            AddColAuto(Job,cLeft,30,GcGap,'Account', jtLeft);
            AddColAuto(Job,cLeft,40,GcGap,'Narration',jtLeft);
            AddColAuto(Job,cLeft,15,GcGap, MyClient.TaxSystemNameUC + ' Class', jtLeft );
            AddColAuto(Job,cLeft,15,GcGap,'Amount/Percent',jtRight);
          end
          else
          begin
            // Extra column
            AddColAuto(Job,cLeft,25,GcGap,'Account', jtLeft);
            AddColAuto(Job,cLeft,35,GcGap,'Narration',jtLeft);
            AddColAuto(Job,cLeft,15,GcGap, MyClient.TaxSystemNameUC + ' Class', jtLeft );
            AddColAuto(Job,cLeft,15,GcGap,'Amount/Percent',jtRight);
            AddColAuto(Job,cLeft,10,GcGap,'Inactive', jtCenter);
          end;

          //Add Footers
          AddCommonFooter(Job);

          Job.Generate(Dest, Lparams);
        finally
          Job.Free;
        end;
      end else begin
        Job := TPayeeListReport.Create(ReportTypes.rptListings);
        try
          Job.FParams := LParams;
          Job.LoadReportSettings(Settings,
                                 LParams.MakeRptName (Report_List_Names[REPORT_LIST_PAYEE]));

          //Add Headers
          AddCommonHeader(Job);
          AddJobHeader(Job,siTitle,'LIST PAYEES',true);
          AddJobHeader(Job,siSubTitle,'',true);

          //Build the columns
          cLeft := GCLeft;
          case LParams.SortBy of
            0: begin
                 AddColAuto(Job,cLeft,55,GcGap,'Payee Name', jtLeft);
                 AddColAuto(Job,cLeft,15,GcGap,'Payee Number',jtLeft);
               end;
            1: begin
                 AddColAuto(Job,cLeft,15,GcGap,'Payee Number',jtLeft);
                 AddColAuto(Job,cLeft,55,GcGap,'Payee Name', jtLeft);
               end;
          end;
          if not Scheduled then
            AddColAuto(Job,cLeft,15,GcGap,'Inactive', jtCenter);

          //Add Footers
          AddCommonFooter(Job);

          if Scheduled and (Dest = rdEmail) then
          begin
            //special case for scheduled reports.  Don't want the user to be asked
            //what file name to use
            case MyClient.clFields.clEmail_Report_Format of
              rfCSV :
                Job.GenerateToFile( EmailOutboxDir + MyClient.clFields.clCode + '.PYC', rfCSV, LParams);
              rfFixedWidth :
                Job.GenerateToFile( EmailOutboxDir + MyClient.clFields.clCode + '.PAY', rfFixedWidth, LParams);
              rfPDF :
                Job.GenerateToFile( EmailOutboxDir + MyClient.clFields.clCode + '.PYP', rfPDF, LParams);
              rfExcel :
                Job.GenerateToFile( EmailOutboxDir + MyClient.clFields.clCode + '.PYX', rfExcel, LParams);
            end
          end else
            if ( Dest = rdFax) then
            begin
              result := Job.GenerateToFax( FaxParams, AdminSystem.fdFields.fdSched_Rep_Fax_Transport, LParams)
            end else
              Job.Generate(Dest, Lparams);
        finally
          Job.Free;
        end;
      end;
    until lparams.RunExit(Dest);
  finally
    lParams.Free;
  end;
end;

procedure DoListPayeesReport(Dest : TReportDest;
                             RptBatch : TReportBase = nil);
begin
  //standard report call
  DoListPayeesReport( Dest, UserPrintSettings, false,Nil,RptBatch);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//function DoCodeOpeningBalance(const Code : string; const D1 : TStDate; var aOpGST, aOpNet : Money ) : money;
////Accumulate the OpenBal prior to the specified Start Date
//var
//   i, j         : integer;
//   OpenBal      : Money;
//   Curr_Dissect : pDissection_Rec;
//
//begin
//   with MyClient.clChart.FindCode(Code)^ do
//      OpenBal := chOpening_Balance_SB_Only;
//
//   with MyClient.clBank_Account_List do begin
//      for i := 0 to Pred(ItemCount) do begin
//         with Bank_Account_At(i).baTransaction_List do begin
//            for j := 0 to Pred(ItemCount) do begin
//               with Transaction_At(j)^ do begin
//                  if (txDate_Effective < D1) then begin
//                     if (txAccount = Code) then begin
//                        OpenBal := OpenBal + txAmount;
//                        aOpGst  := aOpGST + txGST_Amount;
//                        aOpNet  := aOpNet + ( txAmount - txGST_Amount );
//                     end
//                     else if (txFirst_Dissection <> nil) then begin
//                        Curr_Dissect := txFirst_Dissection;
//                        while Curr_Dissect <> nil do begin
//                           with Curr_Dissect^ do begin
//                              if dsAccount = Code then begin
//                                 OpenBal := OpenBal + dsAmount;
//                                 aOpGst  := aOpGST + dsGST_Amount;
//                                 aOpNet  := aOpNet + ( dsAmount - dsGST_Amount );
//                              end;
//
//                              Curr_Dissect := dsNext;
//                           end;
//                        end;
//                     end;
//                  end;
//               end;
//            end;
//         end;
//      end;
//   end;
//   Result := OpenBal;
//end;
//------------------------------------------------------------------------------

procedure ListGSTDetail(Sender : TObject);
const
   LevelOneIndent = '               ';
   LevelTwoIndent = '                                   ';

  Procedure AddNodesForBASField( BASFieldNo : Integer );
  //add nodes to level 2
  Var
     i          : Integer;
     HeaderDone : boolean;
     Account   : pAccount_Rec;
     sPerc      : string;
     Desc       : string;
  begin
     HeaderDone := false;
     With TBKReport(Sender), MyClient.clFields, MyClient.clChart do begin
        For i := BASUtils.MIN_SLOT to BASUtils.MAX_SLOT do begin
           if clBAS_Field_Number[ i ] = BASFieldNo then begin
              //see if header has been rendered
              if not HeaderDone then begin
                 RenderTextLine( LevelOneIndent + bfFieldIDs[ BASFieldNo ] + ': ' + bfNames[ BASFieldNo ]);
                 HeaderDone := true;
              end;
              //now build the description line for the rule
              if clBAS_Field_Source[ i] = BasUtils.bsFrom_Chart then begin
                 sPerc := Percent2Str( clBAS_Field_Percent[ i]) + '% of ';
                 Account := MyClient.clChart.FindCode( clBAS_Field_Account_Code[ i] );
                 if Assigned( Account ) then With Account^ do
                    Desc := '<'+ clBAS_Field_Account_Code[ i] + '> ' + chAccount_Description
                 else
                    Desc := clBAS_Field_Account_Code[ i] + ' < INVALID CODE >';
                 Case  clBAS_Field_Balance_Type[ i] of
                    blGross : Desc := 'Gross Total of Account ' + Desc;
                    blNet   : Desc := 'Net Total of Account '   + Desc;
                    blTax   : Desc := 'Tax Total of Account '   + Desc;
                 end;
                 Desc := sPerc + Desc;
              end
              else begin
                 //if a gst class so need to use the CURRENT description from the grid
                 if clBAS_Field_Source[ i] in [ 0..MAX_GST_CLASS ] then
                 begin
                    sPerc := Percent2Str( clBAS_Field_Percent[ i] ) + ' % of ';
                    if clBAS_Field_Source[ i] = 0 then
                       Desc := '[Unallocated]'
                    else
                       Desc := clGST_Class_Codes[ clBAS_Field_Source[ i]] + ' : ' + clGST_Class_Names[ clBAS_Field_Source[ i]];
                    Case clBAS_Field_Balance_Type[ i] of
                       blGross : Desc := 'Gross Total of GST Class ' + Desc;
                       blNet   : Desc := 'Net Total of GST Class '   + Desc;
                       blTax   : Desc := 'Tax Total of GST Class '   + Desc;
                    end;
                    Desc := sPerc + Desc;
                 end;
              end;
              RenderTextLine( LevelTwoIndent + Desc);
           end;
        end;
        if HeaderDone then
           RenderTextLine('');
     end;
  end;

var
   i : integer;
begin
   with TBKReport(Sender) ,MyClient, MyClient.clFields do begin
      RenderTitleLine( TaxSystemNameUC + ' Rates');
      //list gst rates
      for i := 1 to MAX_GST_CLASS do begin
         if clGST_Class_Codes[ i] <> '' then begin
            PutString( clGST_Class_Codes[ i]);
            PutString( clGST_Class_Names[ i]);

            //show first 3 rates
            if clGST_Rates[ i, 1] <> 0 then
               PutString( FormatFloat( '#.####', clGST_Rates[i , 1] / 10000) + '%')
            else
               SkipColumn;

            if clGST_Rates[ i, 2] <> 0 then
               PutString( FormatFloat( '#.####', clGST_Rates[i , 2] / 10000) + '%')
            else
               SkipColumn;

            if clGST_Rates[ i, 3] <> 0 then
               PutString( FormatFloat( '#.####', clGST_Rates[i , 3] / 10000) + '%')
            else
               SkipColumn;

            PutString( clGST_Account_Codes[ i]);

            if clCountry = whAustralia then begin
               if clGST_Business_Percent[ i] <> 0 then
                  PutString (FormatFloat( '#.##', clGST_Business_Percent[ i] / 100) + '%')
               else
                  SkipColumn;
            end;
            RenderDetailLine;
         end;
      end;
      RenderTextLine('');
      //list when rate apply
      for i := 1 to 3 do begin
         if clGST_Applies_From[i] > 0 then
            RenderTextLine( 'Rate ' + inttostr(i) + ' applies from ' + bkDate2Str( clGST_Applies_From[i]));
      end;
      RenderTextLine('');

      //render BAS Setup if Australian
      if clCountry = whAustralia then begin
         RenderTextLine('');
         RenderTitleLine('BAS Fields');
         RenderTextLine('');
         RenderTextLine('GST Calculation Sheet');
         for i := bfG1 to bfG18 do begin
            AddNodesForBASField( i);
         end;
         RenderTextLine('');
         RenderTextLine('PAYG Withholding');
         for i := bfW1 to bfW4 do begin
            AddNodesForBASField( i);
         end;
         RenderTextLine('');
         RenderTextLine('Totals');
         for i := bf1C to bf7 do begin
            AddNodesForBASField( i);
         end;
         if clBAS_Include_Fuel then
           AddNodesForBASField( bf7d);
         RenderTextLine('');
      end;
   end;
end;
//------------------------------------------------------------------------------


procedure DoListGSTDetails(Dest : TReportDest;
                           RptBatch : TReportBase = nil);
var
   Job: TBKReport;
   Param: TRPTParameters;
   cleft: Double;
begin

   if Dest = rdNone then Dest := rdScreen;
   Param := TRPTParameters.Create(ord(Report_List_GST_Details),MyClient,RptBatch);
   Job := TBKReport.Create(ReportTypes.rptlistings); //?? or listings
   try

     Job.LoadReportSettings(UserPrintSettings,
        param.MakeRptName(Report_List_Names[Report_List_GST_Details]));

       if PRACINI_RestrictFileFormats then
         Job.FileFormats := [ ffPDF, ffAcclipse];

       //Add Headers
       AddCommonHeader(Job);
       AddJobHeader(Job,siTitle,'LIST '+Param.Client.TaxSystemNameUC + ' DETAILS',true);
       AddJobHeader(Job,siSubTitle,'',true);
       if Param.Client.clFields.clGST_Number > '' then begin
          case Param.Client.clFields.clCountry of
             whNewZealand : AddJobHeader(Job, siSubTitle, 'GST No: '+ Param.Client.clFields.clGST_Number,true);
             whAustralia  : AddJobHeader(Job, siSubtitle, 'ABN : '+ Param.Client.clFields.clGST_Number, true);
             whUK : AddJobHeader(Job, siSubTitle, 'VAT No: '+ Param.Client.clFields.clGST_Number,true);
          end;
          AddJobHeader(Job,siSubTitle,'',true);
       end;

       //Build Columns
       cLeft := gCLeft;
       AddColAuto  (Job,cLeft,    7.0,Gcgap,'Class ID',jtLeft);
       if Param.Client.clFields.clCountry  = whAustralia then
          AddColAuto(Job,cLeft,  37.0,Gcgap,'Description', jtLeft)
       else
          AddColAuto(Job,cLeft,  46.5,Gcgap,'Description', jtLeft);

       AddColAuto(Job,cLeft,      9.5,Gcgap,'Rate 1', jtRight);
       AddColAuto(Job,cLeft,      9.5,Gcgap,'Rate 2', jtRight);
       AddColAuto(Job,cLeft,      9.5,Gcgap,'Rate 3', jtRight);
       AddColAuto(Job,cLeft,     12.0,Gcgap,'Control Acc', jtLeft);
       if Param.Client.clFields.clCountry = whAustralia then
          AddColAuto(Job,cLeft,  9.5,Gcgap,'Norm %', jtRight);

       //Add Footers
       AddCommonFooter(Job);

       Job.OnBKPrint := ListGSTDetail;
       Job.Generate(Dest, Param);
     finally
      Job.Free;
      Param.Free;
     end;
end;
//------------------------------------------------------------------------------
function EntryTypeSort(Item1, Item2: Pointer): Integer;
begin
  if (Integer(Item1) < Integer(Item2)) then
    Result := -1
  else if (Integer(Item1) > Integer(Item2)) then
    Result := 1
  else
    Result := 0;
end;
//------------------------------------------------------------------------------
procedure ListMemDetail(Sender : TObject);
var
  lsEntryType : string;

  function GetTransactionTypeString( aValue : string ) : string;
  var
    liControlCode : integer;
  begin
    if trim( aValue ) <> '' then
      liControlCode := StripBGL360ControlAccountCode( aValue )
    else
      liControlCode := -1;
    case liControlCode of
      cttanDistribution      : result := 'Distribution';
      cttanDividend          : result := 'Dividend';
      cttanInterest          : result := 'Interest';
      cttanShareTradeRangeStart..cttanShareTradeRangeEnd : result := 'Share Trade';
      else
        result := 'Other';
    end;
  end;

  procedure RenderMemorisation( BA : TBank_Account; Mem : TMemorisation);
  var
    APayee  : TPayee;
    line    : integer;
    S       : string;
    MemLine : pMemorisation_Line_Rec;
    pAcct   : pAccount_Rec;
    AmountMatchType : byte;

    const Indent = '      ';

    procedure AddValueLine(Name: string; value: Money; Percent: Boolean);
    begin
       if Value = 0 then
          Exit;
       with TBKReport(Sender) do begin
          Putstring(Indent + Name);
          if Percent then
             putstring(FormatFloat(PERCENT_FORMAT, Percent2Double(Value)) + ' %' )
          else
             putstring(BA.CurrencySymbol + ' ' +FormatFloat(NUMBER_FORMAT, Money2Double(Value)));
          PutString('');
          PutString('');
          PutString('');
          PutString('');
          RenderDetailLine;
       end;
    end;

    procedure AddAlignedTextLine(Name: string; value: double);
    begin
      if Value = 0 then
        Exit;
      with TBKReport(Sender) do
      begin
        PutString(Indent + Name);
        PutString(FormatFloat(QUANTITY_FORMAT, Value));
        PutString('');
        PutString('');
        PutString('');
        PutString('');
        RenderDetailLine;
      end;
    end;

    procedure AddTextLine(Name, Value: string; indented: Boolean = false);
    var S: string;
    begin
       if Value = '' then
          Exit;
       S := format('%s : %s',[Name,Value]);
       if indented then
          S := Indent + S;
       TBKReport(Sender).RenderTextLine(S);
    end;

  begin
    with TBKReport(Sender) {,MyClient, MyClient.clFields} do begin

      AddTextLine('Entry Type', format('%u:%s',[mem.mdFields.mdType, MyClient.clFields.clshort_Name[ mem.mdFields.mdType]]));

      AddTextLine('Applies', mem.DateText);

      if mem.mdFields.mdMatch_on_Refce then
        AddTextLine('Reference',mem.mdFields.mdReference);

      if mem.mdFields.mdMatch_on_Particulars then begin
         if ( MyClient.clFields.clCountry in [ whAustralia, whUK ] ) then
            AddTextLine('Bank Type', mem.mdFields.mdParticulars)
         else
            AddTextLine('Particulars',mem.mdFields.mdParticulars);
      end;
      if mem.mdFields.mdMatch_on_Analysis then
         AddTextLine('Analysis' , mem.mdFields.mdAnalysis);
      if mem.mdFields.mdMatch_on_Other_Party then
         AddTextLine('Other Party' , mem.mdFields.mdOther_Party);
      if mem.mdFields.mdMatch_On_Statement_Details then
         AddTextLine('Statement Details' , mem.mdFields.mdStatement_Details);
      if mem.mdFields.mdMatch_on_Notes then
         AddTextLine('Notes' , mem.mdFields.mdNotes);

      //we need to reverse the match on amount type for -ve entries because
      //we display all values as positive amounts
      AmountMatchType := mem.mdFields.mdMatch_on_Amount;
      if mem.mdFields.mdAmount < 0 then
      begin
        case AmountMatchType of
          mxAmtGreaterThan    : AmountMatchType := mxAmtLessThan;
          mxAmtGreaterOrEqual : AmountMatchType := mxAmtLessOrEqual;
          mxAmtLessThan       : AmountMatchType := mxAmtGreaterThan;
          mxAmtLessOrEqual    : AmountMatchType := mxAmtGreaterOrEqual;
        end;
      end;

      if mem.mdFields.mdMatch_on_Amount <> mxNo then
         AddTextLine( 'Amount ' + mxNames[ AmountMatchType], BA.DrCrStr( mem.mdFields.mdAmount ) );

      if mem.mdFields.mdDate_Last_Applied <> 0 then
         AddTextLine( 'Last applied', bkDate2Str( mem.mdFields.mdDate_Last_Applied));

      RenderTextLine('');

      for line := mem.mdLines.First to mem.mdLines.Last do
      begin
        MemLine := mem.mdLines.MemorisationLine_At(line);
         if MemLine^.mlAccount <> '' then begin
           pAcct := MyClient.clChart.FindCode( MemLine^.mlAccount);
           if Assigned( pAcct) then
             s := MemLine^.mlAccount + ' ' + pAcct^.chAccount_Description
           else
             s := MemLine^.mlAccount + ' ** INVALID CODE';
           PutString( S);
           if MemLine^.mlLine_Type = mltPercentage then
             s := FormatFloat ( PERCENT_FORMAT, Percent2Double( MemLine^.mlPercentage))
           else
             s := FormatFloat ( NUMBER_FORMAT, Money2Double( MemLine^.mlPercentage));

           case MemLine^.mlLine_Type of
             mltDollarAmt  : S := BA.CurrencySymbol + ' ' + S;
             mltPercentage : S := S + ' ' + mltNames[mltPercentage];
           end;
           PutString( s);

           if MemLine^.mlPayee <> 0 then
             APayee := MyClient.clPayee_List.Find_Payee_Number(MemLine^.mlPayee)
           else
             APayee := nil;
           if Assigned(APayee) then
             PutString(inttostr(APayee.pdNumber) + ' ' + APayee.pdName)
           else
             PutString('');

           PutString(MemLine^.mlJob_Code);

           if ( MemLine^.mlGST_Class in [ 1..MAX_GST_CLASS]) then begin
              PutString( MyClient.clFields.clGST_Class_Codes[ MemLine^.mlGST_Class] + ' ' +
                         MyClient.clFields.clGST_Class_Names[ MemLine^.mlGST_Class]);
           end
           else
              PutString('-');

           // #1732 - add narration to report, use statement details if no narration
           if MemLine^.mlGL_Narration = '' then
             PutString('-')
           else
             PutString(MemLine^.mlGL_Narration);

           RenderDetailLine;

           if (memLine.mlSF_Edited)
           and CanUseSuperFundFields(MyClient.clFields.clCountry,  MyClient.clFields.clAccounting_System_Used) then begin
               AddValueLine('Franked',MemLine^.mlSF_PCFranked, true);
               AddValueLine('Unfranked',MemLine^.mlSF_PCUnFranked, true);

               case MyClient.clFields.clAccounting_System_Used of
               saBGLSimpleFund, saBGLSimpleLedger : begin

                     AddValueLine('Tax Free Dist', MemLine.mlSF_Tax_Free_Dist, MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Tax Exempt Dist', MemLine.mlSF_Tax_Exempt_Dist, MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Tax Deferred Dist', MemLine.mlSF_Tax_Deferred_Dist, MemLine.mlLine_Type = mltPercentage);

                     AddValueLine('Foreign Income', MemLine.mlSF_Foreign_Income, MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Other Expenses', MemLine.mlSF_Other_Expenses , MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Capital Gains indexed', MemLine.mlSF_Capital_Gains_Indexed , MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Capital Gains discounted', MemLine.mlSF_Capital_Gains_Disc, MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Capital Gains other', MemLine.mlSF_Capital_Gains_Other, MemLine.mlLine_Type = mltPercentage);


                     if (MemLine^.mlSF_Member_Component <> mcNewNA) then
                        AddTextLine('Member Component' , GetSFMemberText(0,MemLine^.mlSF_Member_Component, False), true);

                     AddAlignedTextLine('Quantity', MemLine.mlQuantity / 10000);

                  end;
               saBGL360 : begin
                 lsEntryType := GetTransactionTypeString( MemLine.mlAccount );
                 if lsEntryType <> 'Other' then
                   AddTextLine('Entry Type', lsEntryType, MemLine.mlLine_Type = mltPercentage);

                 AddValueLine('Franking CR', MemLine.mlSF_Imputed_Credit, MemLine.mlLine_Type = mltPercentage);
                 AddValueLine('Gross Interest', MemLine.mlSF_Interest, MemLine.mlLine_Type = mltPercentage);
                 AddValueLine('Tax Paid CR Before Disc', MemLine.mlSF_Capital_Gains_Foreign_Disc, MemLine.mlLine_Type = mltPercentage);
                 AddValueLine('TFN Withheld', MemLine.mlSF_TFN_Credits, MemLine.mlLine_Type = mltPercentage);
                 AddValueLine('Foreign Tax CR', MemLine.mlSF_Foreign_Tax_Credits, MemLine.mlLine_Type = mltPercentage);
                 AddValueLine('Tax Free', MemLine.mlSF_Tax_Free_Dist, MemLine.mlLine_Type = mltPercentage);
                 AddValueLine('Tax Exempt', MemLine.mlSF_Tax_Exempt_Dist, MemLine.mlLine_Type = mltPercentage);
                 AddValueLine('Tax Deferred', MemLine.mlSF_Tax_Deferred_Dist, MemLine.mlLine_Type = mltPercentage);

                 AddValueLine('Foreign Income', MemLine.mlSF_Foreign_Income, MemLine.mlLine_Type = mltPercentage);
                 AddValueLine('Other Expenses', MemLine.mlSF_Other_Expenses , MemLine.mlLine_Type = mltPercentage);
                 AddValueLine('CG Indexed', MemLine.mlSF_Capital_Gains_Indexed , MemLine.mlLine_Type = mltPercentage);
                 AddValueLine('CG Discounted', MemLine.mlSF_Capital_Gains_Disc, MemLine.mlLine_Type = mltPercentage);
                 AddValueLine('CG Other', MemLine.mlSF_Capital_Gains_Other, MemLine.mlLine_Type = mltPercentage);

                 AddAlignedTextLine('Quantity', MemLine.mlQuantity / 10000);

                 AddValueLine( 'Other Income', MemLine.mlSF_Other_Income, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Trust Deductions', MemLine.mlSF_Other_Trust_Deductions, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'CGT Concession', MemLine.mlSF_CGT_Concession_Amount, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Foreign CG Before Disc', MemLine.mlSF_CGT_ForeignCGT_Before_Disc, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Foreign CG Indexed', MemLine.mlSF_CGT_ForeignCGT_Indexation, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Foreign CG Other', MemLine.mlSF_CGT_ForeignCGT_Other_Method, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Tax Paid CR Indexed', MemLine.mlSF_CGT_TaxPaid_Indexation, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Tax Paid CR Other', MemLine.mlSF_CGT_TaxPaid_Other_Method, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Other Net Foreign Income', MemLine.mlSF_Other_Net_Foreign_Income, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Cash Distribution', MemLine.mlSF_Cash_Distribution, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'AU Franking CR from NZ Co.', MemLine.mlSF_AU_Franking_Credits_NZ_Co, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Non-Resident Tax', MemLine.mlSF_Non_Res_Witholding_Tax, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'LIC Deduction', MemLine.mlSF_LIC_Deductions, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Non-Cash CG Before Disc', MemLine.mlSF_Non_Cash_CGT_Discounted_Before_Discount, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Non-Cash CG Indexed', MemLine.mlSF_Non_Cash_CGT_Indexation, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Non-Cash CG Other', MemLine.mlSF_Non_Cash_CGT_Other_Method, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Non-Cash Capital Losses', MemLine.mlSF_Non_Cash_CGT_Capital_Losses, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Brokerage', MemLine.mlSF_Share_Brokerage, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'Consideration', MemLine.mlSF_Share_Consideration, MemLine.mlLine_Type = mltPercentage );
                 AddValueLine( 'GST Amount', MemLine.mlSF_Share_GST_Amount, MemLine.mlLine_Type = mltPercentage );
                 AddTextLine( 'GST Rate', MemLine.mlSF_Share_GST_Rate );
                 AddTextLine( 'Cash Date', bkDate2Str( MemLine.mlSF_Cash_Date ) );
                 AddTextLine( 'Accrual Date', bkDate2Str( MemLine.mlSF_Accrual_Date ) );
                 AddTextLine( 'Record Date', bkDate2Str( MemLine.mlSF_Record_Date ) );
                 AddTextLine( 'Contract Date', bkDate2Str( MemLine.mlSF_Contract_Date ) );
                 AddTextLine( 'Settlement Date', bkDate2Str( MemLine.mlSF_Settlement_Date ) );
               end;
               saSupervisor, saSolution6SuperFund, saSuperMate: begin
                     AddValueLine('Interest', MemLine.mlSF_Interest , MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Foreign', MemLine.mlSF_Foreign_Income, MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Foreign CG', MemLine.mlSF_Capital_Gains_Other, MemLine.mlLine_Type = mltPercentage);

                     AddValueLine('Foreign Discount CG', MemLine.mlSF_Foreign_Capital_Gains_Credit , MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Rent', MemLine.mlSF_Rent , MemLine.mlLine_Type = mltPercentage);

                     AddValueLine('Capital Gain', MemLine.mlSF_Capital_Gains_Indexed , MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Discount CG', MemLine.mlSF_Capital_Gains_Disc, MemLine.mlLine_Type = mltPercentage);

                     AddValueLine('Other Taxable', MemLine.mlSF_Other_Expenses , MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Tax Deferred', MemLine.mlSF_Tax_Deferred_Dist, MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Tax Free Trust', MemLine.mlSF_Tax_Free_Dist, MemLine.mlLine_Type = mltPercentage);

                     AddValueLine('Special Income', MemLine.mlSF_Special_Income, MemLine.mlLine_Type = mltPercentage);



                     AddTextLine('Member ID', MemLine.mlSF_Member_ID, true);
                     AddAlignedTextLine('Quantity', MemLine.mlQuantity / 10000);

                  end;
               saDesktopSuper, saClassSuperIP: begin
                     AddValueLine('Foreign Income', MemLine.mlSF_Foreign_Income, MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Other Taxable', MemLine.mlSF_Other_Expenses , MemLine.mlLine_Type = mltPercentage);

                     AddValueLine('Capital Gain Other', MemLine.mlSF_Capital_Gains_Other, MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Capital Gain Discount', MemLine.mlSF_Capital_Gains_Disc, MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Capital Gain Conc', MemLine.mlSF_Capital_Gains_Indexed , MemLine.mlLine_Type = mltPercentage);

                     AddValueLine('Tax Deferred', MemLine.mlSF_Tax_Deferred_Dist, MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Tax Free Trust', MemLine.mlSF_Tax_Free_Dist, MemLine.mlLine_Type = mltPercentage);
                     AddValueLine('Non Taxable', MemLine.mlSF_Tax_Exempt_Dist , MemLine.mlLine_Type = mltPercentage);



                     AddTextLine('Transaction Type', MemLine.mlSF_Trans_Code, true);

                     AddTextLine('Investment Code', MemLine.mlSF_Fund_Code, True);

                     AddTextLine('Member Account', MemLine.mlSF_Member_Account_Code, True);
                     AddAlignedTextLine('Units', MemLine.mlQuantity / 10000);
                   end;

               end;
               
               RenderTextLine('');
           end;


         end;
      end;
      RenderRuledLine;
    end;
  end;

var
   EntryTypeList     : Tlist;
   i, j, k           : integer;
   EntryNo           : Integer;
   ba                : TBank_Account;
   mem               : TMemorisation;
   AccountHeaderDone : boolean;
   MasterHeaderDone  : boolean;
   Sequence_Last     : Integer;
   Sequence_Next     : Integer;
   Sequence_No       : Integer;
   BankPrefix        : string;
   SystemMemorisation: pSystem_Memorisation_List_Rec;
   MasterMemList     : TMemorisations_List;
begin
  EntryTypeList := Tlist.Create;
  try
   with TBKReport(Sender) ,MyClient, MyClient.clFields do begin
      with MyClient.clBank_Account_List do
      begin
         for i := 0 to Pred( ItemCount) do
         begin
           //account loop
           ba := Bank_Account_At( i);
           if not ba.baFields.baTemp_Include_In_Report then
              continue;
           //place unique entry types into a list
           EntryTypeList.Clear;
           for j := ba.baMemorisations_List.First to ba.baMemorisations_List.Last do
           begin
             mem := ba.baMemorisations_List.Memorisation_At(j);
             if (EntryTypeList.IndexOf(Pointer(mem.mdFields.mdType)) = -1) then
               EntryTypeList.Add(Pointer(mem.mdFields.mdType));
           end;
           //sort the list
           EntryTypeList.Sort(EntryTypeSort);

           AccountHeaderDone := false;
           for EntryNo := 0 to EntryTypeList.Count-1 do
           begin
             //render client memorisations by entry type
             Sequence_Last := -1;
             for j := ba.baMemorisations_List.First to ba.baMemorisations_List.Last do
             begin
               //memorisation loop for a single entry type
               Sequence_Next := -1;
               Sequence_No   := -1;
               //find the next memorisation in the sequence
               for k := ba.baMemorisations_List.First to ba.baMemorisations_List.Last do
               begin
                 mem := ba.baMemorisations_List.Memorisation_At( k);
                 if (mem.mdFields.mdType = Integer(EntryTypeList[EntryNo])) then
                 begin
                   if (Sequence_Last = -1) or (mem.mdFields.mdSequence_No < Sequence_Last) then
                   begin
                     if (Sequence_Next = -1) or (mem.mdFields.mdSequence_No > Sequence_Next) then
                     begin
                       Sequence_Next := mem.mdFields.mdSequence_No;
                       Sequence_No := k;
                     end;
                   end;
                 end;
               end;
               if (Sequence_No >= 0) then
               begin
                 //list memorisation for this bank account
                 mem := ba.baMemorisations_List.Memorisation_At(Sequence_No);
                 if not AccountHeaderDone then
                 begin
                   RenderTitleLine( ba.baFields.baBank_Account_Number + ' ' +
                                    ba.AccountName + ' ');
                   RenderTitleLine('Memorisations');
                   AccountHeaderDone := true;
                 end;
                 RenderMemorisation( ba, mem);
                 Sequence_Last := Sequence_Next;
               end;
             end;
           end;

           //render master memorisations
           if Admin32.RefreshAdmin then
           begin
             MasterHeaderDone  := false;
             BankPrefix := mxFiles32.GetBankPrefix( ba.baFields.baBank_Account_Number);
             if (ba.baFields.baApply_Master_Memorised_Entries) and Assigned(AdminSystem) and
                (MyClient.clFields.clMagic_Number = AdminSystem.fdFields.fdMagic_Number) and
                (MyClient.clFields.clDownload_From = dlAdminSystem) then
             begin
                SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(BankPrefix);
                if Assigned(SystemMemorisation) then begin
                  MasterMemList :=  TMemorisations_List(SystemMemorisation.smMemorisations);
                  if Assigned( MasterMemList) then
                  begin
                    //place unique entry types into a list
                    EntryTypeList.Clear;
                    for j := MasterMemList.First to MasterMemList.Last do
                    begin
                      mem := MasterMemList.Memorisation_At(j);
                      if (EntryTypeList.IndexOf(Pointer(mem.mdFields.mdType)) = -1) then
                        EntryTypeList.Add(Pointer(mem.mdFields.mdType));
                    end;
                    //sort the list
                    EntryTypeList.Sort(EntryTypeSort);

                    for EntryNo := 0 to EntryTypeList.Count-1 do
                    begin
                      //render client memorisations by entry type
                      Sequence_Last := -1;
                      for j := MasterMemList.First to MasterMemList.Last do
                      begin
                        //memorisation loop for a single entry type
                        Sequence_Next := -1;
                        Sequence_No   := -1;
                        //find the next memorisation in the sequence
                        for k := MasterMemList.First to MasterMemList.Last do
                        begin
                          mem := MasterMemList.Memorisation_At( k);
                          if (mem.mdFields.mdType = Integer(EntryTypeList[EntryNo])) then
                          begin
                            if (Sequence_Last = -1) or (mem.mdFields.mdSequence_No < Sequence_Last) then
                            begin
                              if (Sequence_Next = -1) or (mem.mdFields.mdSequence_No > Sequence_Next) then
                              begin
                                Sequence_Next := mem.mdFields.mdSequence_No;
                                Sequence_No := k;
                              end;
                            end;
                          end;
                        end;
                        if (Sequence_No >= 0) then
                        begin
                          //list memorisation for this bank account
                          mem := MasterMemList.Memorisation_At(Sequence_No);
                          //make sure that a header has been written for this account
                          if not AccountHeaderDone then
                          begin
                            RenderTitleLine( ba.baFields.baBank_Account_Number + ' ' +
                                             ba.AccountName + ' ');
                            AccountHeaderDone := true;
                          end;
                          //make sure that we have written a header for master mems
                          if not MasterHeaderDone then
                          begin
                            RenderTitleLine('Master Memorisations');
                            MasterHeaderDone := true;
                          end;
                          RenderMemorisation( ba, mem);
                          Sequence_Last := Sequence_Next;
                        end;
                      end;
                    end;
                  end;
                end;
             end;
             //done
           end;   
         end;
      end;
   end;
  finally
    EntryTypeList.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure DoListMemorisations( Dest : TReportDest;
                               RptBatch : TReportBase = nil);
var
   Job: TBKReport;
   Param: TRPTParameters;
   cLeft: Double;
Begin
   if Dest = rdNone then
      Dest := rdScreen;
   Param := TRPTParameters.Create(ord( Report_List_Memorisations),MyClient,RptBatch);
   try
      Param.GetBatchAccounts;
      repeat
         if SelectReportDest(Report_List_Names[Report_List_Memorisations], Param,0, [btBank]) then begin

            case Param.RunBtn of
               BTN_PRINT    : Dest := rdPrinter;
               BTN_PREVIEW  : Dest := rdScreen;
               BTN_FILE     : Dest := rdFile;
               BTN_EMAIL    : Dest := rdEmail;
               BTN_SAVE     : case Param.BatchRunMode of
                                 R_Setup,R_Batch,R_BatchAdd : exit;
                              end;
               else Dest := rdScreen;
            end;
         end else
            Exit;

         Job := TBKReport.Create(ReportTypes.rptListings);
         try

            Job.LoadReportSettings(UserPrintSettings,
               Param.MakeRptName ( Report_List_Names[ Report_List_Memorisations]));

            if PRACINI_RestrictFileFormats then
               Job.FileFormats := [ ffPDF, ffAcclipse];

            //Add Headers
            AddCommonHeader(Job);
            AddJobHeader(Job,siTitle,'LIST CLIENT MEMORISATIONS',true);
            AddJobHeader(Job,siSubTitle,'',true);

            //Build The columns
            cLeft := gCLeft;
            AddColAuto( Job,cleft, 22,gcgap,'', jtLeft); //'Account' removed for clarity
            AddColAuto( Job,cleft, 9,gcgap,'$/%', jtRight);
            AddColAuto( Job,cleft, 13,gcgap,'Payee', jtLeft);
            AddColAuto( Job,cleft, 10,gcgap,'Job', jtLeft);
            AddColAuto( Job,cleft, 18,gcgap, MyClient.TaxSystemNameUC + ' Class', jtLeft);
            AddColAuto( Job,cleft, 28,gcgap,'Narration', jtLeft);

            //Add Footers
            AddCommonFooter(Job);

            Job.OnBKPrint := ListMemDetail;
            Job.Generate(Dest, Param);

         finally
            Job.Free;
         end;
      until Param.RunExit(dest);;
   finally
      Param.Free;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ListDivDetail(Sender : TObject);
var
   s                 : string;
   i                 : integer;
begin
   with TBKReport(Sender) ,MyClient, MyClient.clFields do
   begin
     for i := 1 to glConst.Max_Divisions do
     begin
       S := clCustom_Headings_List.Get_Division_Heading( i);
       if S <> '' then
       begin
         PutString( IntToStr( i));
         PutString( S);
         RenderDetailLine;
       end;
     end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoListDivisions( Dest : TReportDest;
                           RptBatch : TReportBase = nil);
var
   Job : TBKReport;
   Param : TRPTParameters;
   cLeft: Double;
Begin
   With MyClient, clFields do
   Begin
     if Dest = rdNone then Dest := rdScreen;

     Param := TRPTParameters.Create(ord(Report_List_Divisions),MyClient,RptBatch);
     Job := TBKReport.Create(ReportTypes.rptListings);
     try
       Job.LoadReportSettings(UserPrintSettings,
           Param.MakeRptName ( Report_List_Names[ Report_List_Divisions]));

       //Add Headers
       AddCommonHeader(Job);
       AddJobHeader(Job,siTitle,'LIST DIVISIONS',true);
       AddJobHeader(Job,siSubTitle,'',true);

       //Build columns
       cLeft := GcLeft;
       AddColAuto(Job, cLeft, 15,Gcgap, 'Number', jtLeft);
       AddColAuto(Job, cLeft, 60,GcGap, 'Name', jtLeft);

       //Add Footers
       AddCommonFooter(Job);

       Job.OnBKPrint := ListDivDetail;
       Job.Generate(Dest, Param);
     finally
      Job.Free;
      Param.Free;
     end;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ListJobDetail(Sender : TObject);
var i: integer;
    ll: TStringList;
begin
   with TBKReport(Sender) do begin
      ll := TStringList.Create;
      try
         for i := MyClient.clJobs.First to MyClient.clJobs.Last do
           with MyClient.clJobs.Job_At(I)^ do
             ll.AddObject(uppercase(jhHeading),TObject(MyClient.clJobs.Job_At(I)));
         ll.Sort;
         for I := 0 to ll.Count - 1 do
            with pJob_Heading_Rec(ll.Objects[I])^ do begin
               PutString(jhCode);
               PutString(jhHeading);
               if jhDate_Completed <> 0 then
                  PutString('Yes')
               else
                  PutString('');
            RenderDetailLine;
         end;
      finally
         LL.Free;
      end;
   end;
end;

procedure DoListJobs(Dest: TReportDest; RptBatch: TReportBase = nil);
begin
  //Standard report call
  DoListJobsReport( Dest, UserPrintSettings, False, nil, RptBatch);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ListSubGroupDetail(Sender : TObject);
var
   s                 : string;
   i                 : integer;
begin
   with TBKReport(Sender) ,MyClient, MyClient.clFields do
   begin
     for i := 1 to glConst.Max_SubGroups do
     begin
       S := clCustom_Headings_List.Get_SubGroup_Heading( i);
       if S <> '' then
       begin
         PutString( IntToStr( i));
         PutString( S);
         RenderDetailLine;
       end;
     end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoListSubGroups( Dest : TReportDest;
                           RptBatch : TReportBase = nil);
var
   Job: TBKReport;
   Params: TRptParameters;
   cLeft: Double;
Begin
   Begin
     if Dest = rdNone then Dest := rdScreen;
     Params := TRptParameters.Create(ord(Report_List_SubGroups),MyClient,RptBatch);
     Job := TBKReport.Create(ReportTypes.rptListings);
     try

       Job.LoadReportSettings(UserPrintSettings,
           Params.MakeRptName( Report_List_Names[ Report_List_SubGroups]));

       //Add Headers
       AddCommonHeader(Job);
       AddJobHeader(Job,siTitle,'LIST SUB-GROUPS',true);
       AddJobHeader(Job,siSubTitle,'',true);

       //Build columns 
       cLeft := GcLeft;
       AddColAuto(Job, cLeft, 15,Gcgap, 'Number', jtLeft);
       AddColAuto(Job, cLeft, 60,Gcgap, 'Name', jtLeft);

       //Add Footers
       AddCommonFooter(Job);

       Job.OnBKPrint := ListSubGroupDetail;
       Job.Generate(Dest, Params);
     finally
      Job.Free;
      Params.Free;
     end;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TestFaxDetail(Sender : TObject);
begin
   with TBKReport(Sender) do
   begin
     RenderTextLine( 'This is a test fax!');
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoTestFax( Dest : TReportDest; Settings : TPrintManagerObj; FaxParams : TFaxParameters = nil) : boolean;
var
  Job : TBKReport;
  cLeft: Double;
begin
  result := false;
  Job := TBKReport.Create(ReportTypes.rptListings);
  try
    Job.LoadReportSettings(Settings,Report_List_Names[ REPORT_TEST_FAX]);

    //Add Headers
    AddCommonHeader( Job);
    AddJobHeader(Job,siTitle,'TEST FAX',true);
    AddJobHeader(Job,siSubTitle,'',true);

    //Build Columns
    cLeft := GcLeft;
    AddColAuto(Job, cLeft, 15,Gcgap, 'Number', jtLeft);
    AddColAuto(Job, cLeft, 60,Gcgap, 'Name', jtLeft);

    //Add Footers
    AddCommonFooter(Job);

    Job.OnBKPrint := TestFaxDetail;
    if ( Dest = rdFax) then
    begin
      result := Job.GenerateToFax( FaxParams, AdminSystem.fdFields.fdSched_Rep_Fax_Transport)
    end;
  finally
    Job.Free;
  end;

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoTestFax( Dest : TReportDest) : boolean; overload;
begin
  result := DoTestFax( Dest, UserPrintSettings);
end;


{ TPayeeListReport }

function PayeeSortByName(Item1, Item2: Pointer): Integer;
var
  Payee1, Payee2: TPayee;
begin
  Payee1 := TPayee(Item1);
  Payee2 := TPayee(Item2);
  Result := CompareStr(Payee1.pdName, Payee2.pdName);
end;

function PayeeSortByNumber(Item1, Item2: Pointer): Integer;
var
  Payee1, Payee2: TPayee;
begin
  Payee1 := TPayee(Item1);
  Payee2 := TPayee(Item2);
  Result := (Payee1.pdNumber - Payee2.pdNumber);
end;

procedure TPayeeListReport.BKPrint;
var
  i, j: integer;
  PayeeList: TList;
  Payee: TPayee;
  PayeeLine: pPayee_Line_Rec;
  S: string;
  pAcct: pAccount_Rec;
begin
  PayeeList := TList.Create;
  try
    //Add to list
    for i := MyClient.clPayee_List.First to MyClient.clPayee_List.Last do
    begin
      Payee := MyClient.clPayee_List.Payee_At(i);

      if fParams.Scheduled and Payee.pdFields.pdInactive then
        continue;

      PayeeList.Add(Payee);
    end;

    //Sort
    case FParams.SortBy of
      0: PayeeList.Sort(PayeeSortByName);
      1: PayeeList.Sort(PayeeSortByNumber);
    end;

    if FParams.Detailed then begin
      //Detailed
      for i := 0 to PayeeList.Count - 1 do begin
        Payee := TPayee(PayeeList.Items[i]);
        case FParams.SortBy of
          0: S := Format('%s (%d)', [Payee.pdName, Payee.pdNumber]);
          1: S := Format('%d - %s', [Payee.pdNumber, Payee.pdName]);
        else
          S := Format('%s (%d)', [Payee.pdName, Payee.pdNumber]);
        end;
        RenderTitleLine(S);
        //Print out lines
        for j := Payee.pdLines.First to Payee.pdLines.Last do begin
          PayeeLine := Payee.pdLines.PayeeLine_At(j);
          pAcct := MyClient.clChart.FindCode( PayeeLine.plAccount);
          if Assigned( pAcct) then
            s := pAcct^.chAccount_Code + ' ' + pAcct^.chAccount_Description
          else if ( PayeeLine.plAccount = '') and ( j = 0) then
            s := '(none)'
          else
            s := PayeeLine.plAccount + ' ** INVALID CODE';

          PutString( S);
          PutString( PayeeLine.plGL_Narration);

          if ( PayeeLine.plGST_Class in [ 1.. Max_Gst_Class]) then begin
            S := MyClient.clFields.clGST_Class_Codes[ PayeeLine.plGST_Class] + ' ' +
                 MyClient.clFields.clGST_Class_Names[ PayeeLine.plGST_Class];
            PutString( S);
          end else
            SkipColumn;

          case PayeeLine.plLine_Type of
            pltPercentage :
            begin
              PutString( FormatFloat( PERCENT_FORMAT, PayeeLine.plPercentage / 10000) + pltNames[PayeeLine.plLine_Type]);
            end;

            pltDollarAmt :
            begin
              if IsForeignCurrencyClient then
              begin
                PutString( FormatFloat( '#.##', PayeeLine.plPercentage / 100));
              end
              else
              begin
                PutString( pltNames[PayeeLine.plLine_Type] + FormatFloat( '#.##', PayeeLine.plPercentage / 100));
              end;
            end
          else
            SkipColumn;
          end;

          // Inactive column
          if not fParams.Scheduled then
          begin
            if Payee.pdFields.pdInactive then
              PutString('Yes')
            else
              SkipColumn;
          end;

          RenderDetailLine;

        end;
        if FParams.RuleLine then
            RenderRuledLine;
      end;
    end else begin
      //Summarised
      for i := 0 to PayeeList.Count - 1 do begin
        Payee := TPayee(PayeeList.Items[i]);
        case FParams.SortBy of
          0: begin
               PutString(Payee.pdName);
               PutInteger(Payee.pdNumber);
             end;
          1: begin
               PutInteger(Payee.pdNumber);
               PutString(Payee.pdName);
             end;
        end;
        if not fParams.Scheduled then
        begin
          if Payee.pdFields.pdInactive then
            PutString('Yes')
          else
            SkipColumn;
        end;
        RenderDetailLine;
        if FParams.RuleLine then
          RenderRuledLine;
      end;
    end;
  finally
    PayeeList.Free;
  end;
end;

function DoListJobsReport(Dest : TReportDest;
                          Settings : TPrintManagerObj;
                          Scheduled : boolean;
                          FaxParams : TFaxParameters = nil;
                          RptBatch : TReportBase = nil) : boolean; overload;
var
  Job : TBKReport;
  Param : TRPTParameters;
  cLeft: Double;
begin
  Result := false;
  with MyClient, clFields do begin
    if Dest = rdNone then
      Dest := rdScreen;

    Param := TRPTParameters.Create(ord(Report_List_jobs),MyClient,RptBatch);
    try
      Param.Scheduled := Scheduled;
      Job := TBKReport.Create(ReportTypes.rptListings);
      try
        Job.LoadReportSettings(Settings, Param.MakeRptName(Report_List_Names[Report_List_Jobs]));

        //Add Headers
        AddCommonHeader(Job);
        AddJobHeader(Job,siTitle,'LIST JOBS',true);
        AddJobHeader(Job,siSubTitle,'',true);

        //Build columns
        cLeft := GcLeft;
        AddColAuto(Job, cLeft, 12,Gcgap, 'Code', jtLeft);
        AddColAuto(Job, cLeft, 65,GcGap, 'Name', jtLeft);
        AddColAuto(Job, cLeft, 10,Gcgap, 'Completed', jtLeft);

        //Add Footers
        AddCommonFooter(Job);

        Job.OnBKPrint := ListJobDetail;
        if Scheduled and (Dest = rdEmail) then begin
          //special case for scheduled reports.  Don't want the user to be asked
          //what file name to use
          case MyClient.clFields.clEmail_Report_Format of
            rfCSV :
              Job.GenerateToFile( EmailOutboxDir + MyClient.clFields.clCode + '.JBC', rfCSV, Param);
            rfFixedWidth :
              Job.GenerateToFile( EmailOutboxDir + MyClient.clFields.clCode + '.JBY', rfFixedWidth, Param);
            rfPDF :
              Job.GenerateToFile( EmailOutboxDir + MyClient.clFields.clCode + '.JBP', rfPDF, Param);
            rfExcel :
              Job.GenerateToFile( EmailOutboxDir + MyClient.clFields.clCode + '.JBX', rfExcel, Param);
          end
        end else if (Dest = rdFax) then begin
          Result := Job.GenerateToFax( FaxParams, AdminSystem.fdFields.fdSched_Rep_Fax_Transport, Param)
        end else begin
          Job.Generate(Dest, Param);
        end;
      finally
        Job.Free;
      end;
    finally
      Param.Free;
    end;
  end;
end;


end.
