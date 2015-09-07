unit OpeningBalancesDlg;
//------------------------------------------------------------------------------
{
   Title:       Opening Balances Dlg

   Description: Allows entering/editing of the opening balances for the
                current financial year.

   Author:      Matthew Hopkins  May 2002

   Remarks:     Creates an opening balance journal on the financial year start date.
                The journal MUST balance.
                All items are entered as positive numbers.

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids_ts, TSGrid, StdCtrls, ExtCtrls, clObj32, baObj32, TSMask,
  MoneyDef, bkDefs, bkXPThemes, OSFont, chList32, ActnList, Menus;

type
  TdlgOpeningBalances = class(TForm)
    pnlFooter: TPanel;
    pnlHeader: TPanel;
    lSubTitle: TLabel;
    lblFinYear: TLabel;
    Label3: TLabel;
    lblAmountRemText: TLabel;
    lblAmountRemaining: TLabel;
    tgBalances: TtsGrid;
    chkHideNonBS: TCheckBox;
    tsMaskDefs1: TtsMaskDefs;
    lblInvalidAccountsUsed: TLabel;
    PopupMenu1: TPopupMenu;
    ActionList1: TActionList;
    acForeignCurrency: TAction;
    Enterforeigncurrencybalance1: TMenuItem;
    chkHideInactive: TCheckBox;
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    ShapeBorder: TShape;
    procedure tgBalancesCellLoaded(Sender: TObject; DataCol,
      DataRow: Integer; var Value: Variant);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkHideNonBSClick(Sender: TObject);
    procedure tgBalancesEndCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure tgBalancesStartCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure tgBalancesKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tgBalancesInvalidMaskValue(Sender: TObject; DataCol,
      DataRow: Integer; var Accept: Boolean);
    procedure acForeignCurrencyExecute(Sender: TObject);
    procedure tgBalancesContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure tgBalancesPaintCell(Sender: TObject; DataCol, DataRow: Integer;
      ARect: TRect; State: TtsPaintCellState; var Cancel: Boolean);
    procedure tgBalancesMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tgBalancesEndRowEdit(Sender: TObject; DataRow: Integer;
      var Cancel: Boolean);
    procedure chkHideInactiveClick(Sender: TObject);
  private
    { Private declarations }
    ThisClient             : TClientObj;
    Journal_Account        : tBank_Account;
    FAccountList           : TCustomSortChart;
    FAsAtDate: integer;
    procedure LoadChartIntoList;
    procedure LoadOpeningBalancesIntoChart(BalDate: Integer = -1);
    procedure SaveOpeningBalancesToJournal;
    procedure SetBalancesForLinkedAccounts( SourceAccount : pAccount_Rec);
    procedure ReloadLinkedAccountBalances;
    procedure ConfigureGrid;
    procedure UpdateAmountRemaining;
    procedure SetupBalanceCell(pAccount: pAccount_Rec; DataCol, DataRow: Integer; var Value: string);
    function  GetAmountRemaining : Money;
    function EditableAccount(pAccount : pAccount_Rec): Boolean;
    function GetExchangeRate(pAccount: pAccount_Rec): Double;
    function GetForeignCurrencyAmount(pAccount: pAccount_Rec): money;
  public
    { Public declarations }
    property AsAtDate: integer read FAsAtDate;
  end;

const
  SHOW_BAL = 0;
  SHOW_BAL_AND_SAVE = 1;
  SAVE_BAL_ONLY = 2;

  procedure EditOpeningBalances(const aClient: TClientObj; SaveMode: Byte = SHOW_BAL; ForDate: Integer = -1);
  function ValidateOpeningBalances( const aClient : TClientObj; aDate: Integer): Boolean;

//******************************************************************************
implementation
uses
   bkConst,
   bkDateUtils,
   bkdsio,
   bkhelp,
   ErrorMoreFrm,
   GenUtils,
   GstCalc32,
   jnlUtils32,
   SignUtils,
   StDateSt,
   TrxList32,
   bkchio,
   CountryUtils,
   ForexHelpers,
   ExchangeRateList,
   ForeignCurrencyBalDlg,
   SuggestedMems,
   ImagesFrm;

{$R *.dfm}
const
   ColAccount     = 1;
   ColDesc        = 2;
   ColBalance     = 3;
   ColSign        = 4;
   ColReportGroup = 5;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure EditOpeningBalances(const aClient: TClientObj; SaveMode: Byte = SHOW_BAL; ForDate: Integer = -1);
//The opening balances are stored in a journal.  The values are temporarily loaded
//into the chart so that editing can be done there.
//Since the introduction of the Home page it is posible
//to look at other years.. But they can NOT be edited;

var
  mr: Integer;
begin
   with TdlgOpeningBalances.Create(Application.MainForm) do begin
      try
        FAccountList := TCustomSortChart.Create(aClient.ClientAuditMgr);
        if UseXlonSort then
          FAccountList.Sort(XlonCompare);

         ThisClient := aClient;
         Journal_Account := nil;
         //check linked accounts and set temp soh flag
         ThisClient.clChart.RefreshDependencies;

         LoadOpeningBalancesIntoChart(ForDate);

         LoadChartIntoList;

         if ForDate > 0 then begin
            FAsAtDate := ForDate;
            if ForDate <> ThisClient.clFields.clFinancial_Year_Starts then begin
               // Can ony edit the current reporting year
               tgBalances.Enabled := False;
               tgBalances.Font.Color := clGrayText;
               lSubtitle.Caption := 'The Opening Balances for your accounts as at';
            end;
         end else
            FAsAtDate := ThisClient.clFields.clFinancial_Year_Starts;

         lblFinYear.caption := StDateToDateString( 'dd nnn yyyy', FAsAtDate , true);

         ConfigureGrid;
         UpdateAmountRemaining;

         mr := mrCancel;

         if (SaveMode = SHOW_BAL)
         or (SaveMode = SHOW_BAL_AND_SAVE) then
            mr := ShowModal;

         if not tgBalances.Enabled then
            mr := mrCancel;

         if ((SaveMode = SHOW_BAL) and (mr = mrOK))
         or (SaveMode = SHOW_BAL_AND_SAVE) or (SaveMode = SAVE_BAL_ONLY) then begin
            SaveOpeningBalancesToJournal;
            RemoveJnlAccountIfEmpty(aClient, Journal_Account);
         end;


      finally
         Free;
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ValidateOpeningBalances( const aClient : TClientObj; aDate: Integer): Boolean;
var
  i: Integer;
  pAccount : pAccount_Rec;
begin
   Result := True;
   with TdlgOpeningBalances.Create(Application.MainForm) do begin
      try
         FAccountList := TCustomSortChart.Create(aClient.ClientAuditMgr);
         if UseXlonSort then
           FAccountList.Sort(XlonCompare);

         ThisClient := aClient;
         Journal_Account := nil;
         //check linked accounts and set temp soh flag
         ThisClient.clChart.RefreshDependencies;

         LoadOpeningBalancesIntoChart(aDate);

         //check for invalid account types
         with ThisClient.clChart do begin
            for i := aClient.clChart.First to ThisClient.clChart.Last do begin
               pAccount := Account_At( i);
               if ( pAccount^.chTemp_Money_Value <> 0) and
                  ( not (pAccount^.chAccount_Type in BalanceSheetReportGroupsSet + [ atOpeningStock, atClosingStock])) then
                  Result := False;
            end;
         end;

      finally
         Free;
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TdlgOpeningBalances }
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.ConfigureGrid;
begin
   tgBalances.Rows   := FAccountList.ItemCount;
end;

function TdlgOpeningBalances.EditableAccount(pAccount: pAccount_Rec): Boolean;
begin
  Result := ((pAccount.chAccount_Type in BalanceSheetReportGroupsSet) and (pAccount.chPosting_Allowed))
            or
            //or amount is non zero and is not opening or closing stock
            //opening closing stock accounts may be changed automatically if
            //linked to from stock on hand
            (( pAccount.chTemp_Money_Value <> 0 ) and ( not ( pAccount.chAccount_Type in [ atOpeningStock, atClosingStock])));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.LoadOpeningBalancesIntoChart(BalDate: Integer = -1);
var
   pJ : pTransaction_Rec;
   pJournal_Line : pDissection_Rec;
   pAccount      : pAccount_Rec;
   i, StartDate : integer;
begin
   if BalDate = -1 then
     StartDate := ThisClient.clFields.clFinancial_Year_Starts
   else
    StartDate := BalDate;
   //zero existing totals in chart
   with ThisClient.clChart do begin
      for i := 0 to Pred( itemCount) do begin
         Account_At(i)^.chTemp_Money_Value := 0;
         Account_At(i)^.chTemp_Opening_Balance_Currency := '';
      end;
   end;

   //find the open balance journal account
   Journal_Account := nil;
   With ThisClient.clBank_Account_List do For i := 0 to Pred( itemCount ) do
      With Bank_Account_At( i ) do
         If baFields.baAccount_Type = btOpeningBalances then {found it}
            Journal_Account := Bank_Account_At( i );

   if Assigned( Journal_Account) then begin
      pJ := jnlUtils32.GetJournalFor( Journal_Account, StartDate);
      if Assigned( pJ) then begin
         //load totals into tmp values in chart
         pJournal_Line := pJ^.txFirst_Dissection;
         while ( pJournal_Line <> nil) do begin
            pAccount := ThisClient.clChart.FindCode( pJournal_Line.dsAccount);
            if Assigned( pAccount) then begin
               if ( pAccount^.chAccount_Type in [ atOpeningStock, atClosingStock]) and
                  ( pAccount^.chTemp_Linked_To_From_SOH <> '') then
               begin
                 //the temp money values for these accounts will be set
                 //from the stock on hand figure when updating linked accounts
               end
               else begin
                 pAccount.chTemp_Money_Value := pAccount.chTemp_Money_Value + pJournal_Line.dsAmount;
                 //Get the currency
                 pAccount.chTemp_Opening_Balance_Currency := pJournal_Line.dsOpening_Balance_Currency;
                 pAccount.chTemp_Opening_Balance_Forex_Amount := pJournal_Line.dsForeign_Currency_Amount;
               end;
            end
            else
            begin
             pAccount := bkchio.New_Account_Rec;
             with pAccount^ do begin
                chAccount_Type     := BKCONST.atNone;
                chAccount_Description := 'Invalid Account';
                chAccount_Code     := pJournal_Line.dsAccount;
                chPosting_Allowed  := true;
                chTemp_Calc_Totals_Tag := 999; // to be deleted
             end;
             ThisClient.clChart.Insert(pAccount);
             pAccount.chTemp_Money_Value := pJournal_Line.dsAmount;
             pAccount.chTemp_Opening_Balance_Currency := pJournal_Line.dsOpening_Balance_Currency;
             pAccount.chTemp_Opening_Balance_Forex_Amount := pJournal_Line.dsForeign_Currency_Amount;             
            end;
            pJournal_Line := pJournal_Line.dsNext;
         end;
      end;
   end;
   //set balances for linked accounts
   ReloadLinkedAccountBalances;

   //now correct the opening balances so that normal figures appear as +ve
   with ThisClient.clChart do begin
      for i := 0 to Pred( itemCount) do begin
         pAccount := Account_At(i);

         if SignOf( pAccount.chTemp_Money_Value ) = ExpectedSign( pAccount.chAccount_Type) then
            pAccount.chTemp_Money_Value := Abs( pAccount.chTemp_Money_Value)
         else
            pAccount.chTemp_Money_Value :=  -1 * Abs( pAccount.chTemp_Money_Value);
      end;
   end;
end;
procedure TdlgOpeningBalances.PopupMenu1Popup(Sender: TObject);
begin

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.SaveOpeningBalancesToJournal;
//write an opening balances journal
var
   {NeedJournal           : boolean;}
   pJ                    : pTransaction_Rec;
   pJournalLine          : pDissection_Rec;
   pAccount              : pAccount_Rec;
   i                     : integer;
   AuditIDList: TList;   
begin
   {//test to see if a journal entry needs to be written
   NeedJournal := false;
   with ThisClient.clChart do begin
      for i := 0 to Pred( itemCount) do
         if Account_At(i)^.chTemp_Money_Value <> 0 then begin
            NeedJournal := true;
            Break;
         end;
   end;}

   //find the open balance journal account
   Journal_Account := nil;
   With ThisClient.clBank_Account_List do For i := 0 to Pred( itemCount ) do
      With Bank_Account_At( i ) do
         If baFields.baAccount_Type = btOpeningBalances then {found it}
            Journal_Account := Bank_Account_At( i );

   if Journal_Account = nil then begin
      //there is no journal account currently, so create one
      Journal_Account := TBank_Account.Create(ThisClient);
      With Journal_Account.baFields do Begin
         baBank_Account_Number   := btNames[ btOpeningBalances ];
         baBank_Account_Name     := btNames[ btOpeningBalances ];
         baCurrent_Balance       := 0;
         baAccount_Type          := btOpeningBalances;
         baDesktop_Super_Ledger_ID := -1;
         baCurrency_Code         := ThisClient.clExtra.ceLocal_Currency_Code;         
      end;
      ThisClient.clBank_Account_List.Insert(Journal_Account);
   end;

   //find the opening balance journal for this date
   pJ := jnlUtils32.GetJournalFor( Journal_Account, ThisClient.clFields.clFinancial_Year_Starts);
   //If no transaction exists on this date the create a new one to be dissected
   If pJ = nil then
     pJ := NewJournalFor( ThisClient, Journal_Account, ThisClient.clFields.clFinancial_Year_Starts);

   AuditIDList := TList.Create;
   try
     //Clear current dissection lines - but save audit ID's
     TrxList32.Dump_Dissections( pJ, AuditIDList );

     //change temp amounts so that the sign is correct
     //+ve amounts should take the expected sign, -ve amounts take reversed sign
     for i := 0 to Pred( ThisClient.clChart.ItemCount ) do begin
        pAccount := ThisClient.clChart.Account_At( i);

        if pAccount.chTemp_Money_Value < 0 then begin
           pAccount.chTemp_Money_Value := SetSign( pAccount.chTemp_Money_Value, ReverseSign( ExpectedSign( pAccount.chAccount_Type)));
        end
        else if pAccount.chTemp_Money_Value > 0 then begin
           pAccount.chTemp_Money_Value := SetSign( pAccount.chTemp_Money_Value, ExpectedSign( pAccount.chAccount_Type));
        end;
     end;
     //Reload values for linked accounts
     ReloadLinkedAccountBalances;

     // Store dissection lines
     for i := 0 to Pred( ThisClient.clChart.ItemCount ) do begin
        pAccount := ThisClient.clChart.Account_At( i);
        if pAccount.chTemp_Money_Value <> 0 then begin
           //need to write a dissection line for this account
           pJournalLine        :=  New_Dissection_Rec;
           with pJournalLine^ do begin
             dsTransaction         := pJ;
             dsAccount             := pAccount.chAccount_Code;
             dsAmount              := pAccount.chTemp_Money_Value;
             dsOpening_Balance_Currency := pAccount.chTemp_Opening_Balance_Currency;
             dsForeign_Currency_Amount  := pAccount.chTemp_Opening_Balance_Forex_Amount;
             dsPayee_Number        := 0;
             dsGST_Class           := pAccount.chGST_Class;
             //The GST for opening balance journals MUST be zero, set this and
             //set edit flag if not already zero
             dsGST_Amount          := GSTCalc32.CalculateGSTForClass( ThisClient, pJ.txDate_Effective, Local_Amount, pAccount.chGST_Class);
             if ( dsGST_Amount <> 0) then begin
               dsGST_Amount := 0;
               dsGST_Has_Been_Edited := True;
             end;
             dsQuantity            := 0;
             dsGL_Narration        := '';
             dsHas_Been_Edited     := True;
             dsJournal_Type        := jtNormal;
             dsSF_Member_Account_ID:= -1;
             dsSF_Fund_ID          := -1;
             if AuditIDList.Count > 0 then begin
               pJournalLine.dsAudit_Record_ID := integer(AuditIDList.Items[0]);
               TrxList32.AppendDissection( pJ, pJournalLine, nil );
               AuditIDList.Delete(0);
             end else
               TrxList32.AppendDissection( pJ, pJournalLine, ThisClient.ClientAuditMgr);
           end;
        end;
     end;
   finally
     AuditIDList.Free;
   end;

   if pJ^.txFirst_Dissection <> nil then begin
     pJ^.txCoded_By := cbManual;
     pJ^.txAccount  := 'DISSECT';
     pJ^.txAmount   := 0;
   end
   else begin
     //there are no lines in the journal so delete it
     Journal_Account.baTransaction_List.DelFreeItem( pJ);
     pJ := nil;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.tgBalancesCellLoaded(Sender: TObject;
  DataCol, DataRow: Integer; var Value: Variant);
var
   pAccount : pAccount_Rec;
   BalanceAmtStr: string;
begin
   pAccount := FAccountList.Items[ DataRow - 1];

   case DataCol of
      ColAccount      : Value := pAccount.chAccount_Code;
      ColDesc         : Value := pAccount.chAccount_Description;
      ColBalance      : begin
                          SetupBalanceCell(pAccount, DataCol, DataRow, BalanceAmtStr);
                          Value := BalanceAmtStr;
                        end;
      ColSign         : case ExpectedSign( pAccount.chAccount_Type) of
                           Debit : Value := 'Dr';
                           Credit : Value  := 'Cr';
                        else
                           Value := '';
                        end;
      ColReportGroup  : Value := Localise(ThisClient.clFields.clCountry, bkconst.atNames[ pAccount.chAccount_Type]);
   end;
end;

procedure TdlgOpeningBalances.tgBalancesContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  i: integer;
  Grid: TTsGrid;
  Rect: TRect;
  pAccount : pAccount_Rec;
  ExchangeRec: TExchangeRecord;
  HasExchangeRate: Boolean;
  BaseCurrencyIdx: integer;
begin
  Handled := True;

  if not ThisClient.HasForeignCurrencyAccounts then Exit;

  HasExchangeRate := False;
  ExchangeRec := ThisClient.ExchangeSource.GetDateRates(AsAtDate);
  BaseCurrencyIdx := ThisClient.ExchangeSource.GetISOIndex(ThisClient.clExtra.ceLocal_Currency_Code,
                                                           ThisClient.ExchangeSource.Header);

  if not Assigned(ExchangeRec) then Exit;

  for i := 0 to ExchangeRec.Width do begin
    if (ExchangeRec.Rates[i] <> 0) and (i <> BaseCurrencyIdx)then begin
      HasExchangeRate := True;
      Break;
    end;
  end;
  if not HasExchangeRate then Exit;

  Grid := TTsGrid(Sender);
  pAccount := FAccountList.Items[Grid.CurrentDataRow - 1];
  if Assigned(pAccount) then begin
    if EditableAccount(pAccount) and (pAccount.chAccount_Type = atBankAccount)
       and (Grid.CurrentDataCol = ColBalance) then begin
      Rect := Grid.CellRect(Grid.CurrentDataCol, Grid.CurrentDataRow);
      //Can't workout how to get the bottom position of the cell???
      PopupMenu1.Popup(Self.Left + Grid.Left + Rect.Left,
                       Self.Top + Grid.Top + Rect.Bottom +
                       Grid.HeadingHeight + 10);
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);
   tgBalances.HeadingFont := Font;
   Journal_Account := nil;
   lblFinYear.Font.Style := [fsBold];
   lblInvalidAccountsUsed.Font.Name := Font.Name;
   tgBalances.HeadingFont.Style := [fsBold];

   if Screen.WorkAreaHeight > 480 then
      Self.Height := Round( Screen.WorkAreaHeight * 0.8);
   Self.Top := ( Screen.WorkAreaHeight - Self.Height) div 2;

   BKHelpSetUp( Self, BKH_Opening_balances);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.FormDestroy(Sender: TObject);
var
  pA : pAccount_Rec;
  i: Integer;
begin
   FAccountList.DeleteAll;
   FAccountList.Free;

   i := 0;
   while i < ThisClient.clChart.ItemCount do
   begin
      pA  := ThisClient.clChart.Account_At( i);
      if pA.chTemp_Calc_Totals_Tag = 999 then
        ThisClient.clChart.Delete(pA)
      else
        Inc(i);
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.LoadChartIntoList;
var
   pA : pAccount_Rec;
   i  : integer;
begin
   FAccountList.DeleteAll;
   for i := 0 to Pred( ThisClient.clChart.ItemCount) do begin
      pA  := ThisClient.clChart.Account_At( i);
      if pA.chInactive and chkHideInactive.Checked and (pA.chTemp_Money_Value = 0) then
        continue;
      if ( not chkHideNonBS.checked)
         or ( pA.chAccount_Type in BalanceSheetReportGroupsSet)
         or ( pA^.chTemp_Money_Value <> 0 ) then
      begin
        FAccountList.Insert( pA);
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.acForeignCurrencyExecute(Sender: TObject);
var
  pAccount : pAccount_Rec;
begin
  pAccount := FAccountList.Items[tgBalances.CurrentDataRow - 1];
  if Assigned(pAccount) then begin
    EnterForeignCurrencyBalance(pAccount, AsAtDate);
    tgBalances.Refresh;
    UpdateAmountRemaining;
  end;
end;

procedure TdlgOpeningBalances.chkHideInactiveClick(Sender: TObject);
begin
   tgBalances.Rows := 0;
   LoadChartIntoList;
   ConfigureGrid;
   tgBalances.Refresh;
end;

procedure TdlgOpeningBalances.chkHideNonBSClick(Sender: TObject);
begin
   tgBalances.Rows := 0;
   LoadChartIntoList;
   ConfigureGrid;
   tgBalances.Refresh;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.tgBalancesEndCellEdit(Sender: TObject;
  DataCol, DataRow: Integer; var Cancel: Boolean);
var
   sValue : string;
   dValue : Double;
   pAccount : pAccount_Rec;
   pOS_Acct,
   pCS_Acct : pAccount_Rec;

   HasLinkedAccounts : boolean;
begin
   pAccount := FAccountList.Items[ DataRow - 1];
   HasLinkedAccounts := false;

   case DataCol of
      ColBalance : begin
         sValue := tgBalances.CurrentCell.Value;
         if sValue = '' then
            sValue := '0.00';
         dValue := StrToFloatDef( sValue , 0.0);
         pAccount.chTemp_Money_Value := Double2Money( dValue);
         pAccount.chTemp_Opening_Balance_Currency := '';

         if pAccount.chAccount_Type = atStockOnHand then begin
           pOS_Acct := ThisClient.clChart.FindCode( pAccount.chLinked_Account_OS);
           pCS_Acct := ThisClient.clChart.FindCode( pAccount.chLinked_Account_CS);

           if Assigned( pOS_Acct)
             and Assigned( pCS_Acct)
             and ( pOS_Acct.chAccount_Type = atOpeningStock)
             and ( pCS_Acct.chAccount_Type = atClosingStock) then
           begin
             pOS_Acct.chTemp_Money_Value := pAccount.chTemp_Money_Value;
             pCS_Acct.chTemp_Money_Value := pAccount.chTemp_Money_Value;
             HasLinkedAccounts := true;
           end;
         end;
      end;
   else
      Cancel := true;
   end;

   UpdateAmountRemaining;

   if HasLinkedAccounts then
   begin
     //refresh the table so that opening/closing stock amounts are refreshed
     tgBalances.Refresh;
   end;
end;
procedure TdlgOpeningBalances.tgBalancesEndRowEdit(Sender: TObject;
  DataRow: Integer; var Cancel: Boolean);
begin

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.tgBalancesStartCellEdit(Sender: TObject;
  DataCol, DataRow: Integer; var Cancel: Boolean);
var
   pAccount : pAccount_Rec;
   CanEdit  : boolean;
begin
   pAccount := FAccountList.Items[ DataRow - 1];

              //can edit if is a balance sheet item
   CanEdit := EditableAccount(pAccount);

   Cancel := not CanEdit;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgOpeningBalances.GetAmountRemaining: Money;
var
   pAccount : pAccount_Rec;
   Total    : Money;
   Dr_Total : Money;
   Cr_Total : Money;
   Value    : Money;
   i        : integer;
begin
   //Add up the totals to see how much is remaining
   //Need to change to sign of the amount depending of whether or not the
   //report group is a dr or cr account
   Total    := 0;
   Dr_Total := 0;
   Cr_Total := 0;

   with ThisClient.clChart do begin
      for i := 0 to Pred( itemCount) do begin
         pAccount := Account_At( i);

         Value := pAccount^.chTemp_Money_Value;

         if ExpectedSign( pAccount.chAccount_Type) = Debit then
            Dr_Total := Dr_Total + Value
         else
            Cr_Total := Cr_Total + Value;

         if ExpectedSign( pAccount.chAccount_Type) = Credit then
            Value := - Value;

         Total := Total + Value;
      end;
   end;

   result := Total;
end;

function TdlgOpeningBalances.GetExchangeRate(pAccount: pAccount_Rec): Double;
var
  ExchangeRecord: TExchangeRecord;
  RateIdx: integer;
begin
  Result := 0;
  ExchangeRecord := ThisClient.ExchangeSource.GetDateRates(AsAtDate);
  if Assigned(ExchangeRecord) then begin
    RateIdx := ThisClient.ExchangeSource.GetISOIndex(pAccount.chTemp_Opening_Balance_Currency,
                                                     ThisClient.ExchangeSource.Header);
    if (ExchangeRecord.Rates[RateIdx] > 0) then
      Result := ExchangeRecord.Rates[RateIdx];
  end;
end;

function TdlgOpeningBalances.GetForeignCurrencyAmount(
  pAccount: pAccount_Rec): money;
var
  ExchangeRate: double;
begin
  Result := 0;
  if (pAccount.chTemp_Opening_Balance_Currency <> ThisClient.clExtra.ceLocal_Currency_Code) and
     (pAccount.chTemp_Opening_Balance_Currency <> '')  then begin
    ExchangeRate := GetExchangeRate(pAccount);
    Result := Double2Money((pAccount.chTemp_Money_Value/100) * ExchangeRate);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.UpdateAmountRemaining;
var
   Rem : Money;
   i   : integer;
   pAccount : pAccount_Rec;
   Found    : boolean;
begin
   Rem := -GetAmountRemaining;
   if Rem <> 0 then begin
      lblAmountRemText.Font.Color := clRed;
      lblAmountRemText.Caption    := 'Amount remaining to be assigned: ';
      lblAmountRemaining.caption  := ThisClient.DrCrStr( Rem );
   end
   else begin
      lblAmountRemText.Font.Color := clGreen;
      lblAmountRemText.Caption    := 'The account totals are balanced.';
      lblAmountRemaining.caption  := '';
   end;

   //check for invalid account types
   Found := False;
   with ThisClient.clChart do begin
      for i := ThisClient.clChart.First to ThisClient.clChart.Last do begin
         pAccount := Account_At( i);
         if ( pAccount^.chTemp_Money_Value <> 0) and
            ( not (pAccount^.chAccount_Type in BalanceSheetReportGroupsSet + [ atOpeningStock, atClosingStock])) then
            Found := True;
      end;
   end;
   lblInvalidAccountsUsed.Visible := Found;
end;

procedure TdlgOpeningBalances.tgBalancesKeyPress(Sender: TObject; var Key: Char);
var
   DataCol     : integer;
   DataRow     : integer;
   Rem         : money;
   pAccount    : pAccount_Rec;
   Value       : money;
   sValue      : string;
   dValue      : double;
begin
   DataCol := tgBalances.CurrentDataCol;

   if DataCol = colBalance then
   begin
     DataRow := tgBalances.CurrentDataRow;
     //complete the amount
     if Key = '=' then
     begin
       Key := #0;
       //get pointer to current account
       pAccount := FAccountList.Items[ DataRow - 1];

       //calculate amount remaining, need to remove current item
       Rem := -1 * GetAmountRemaining;
       Value := pAccount^.chTemp_Money_Value;
       if ExpectedSign( pAccount.chAccount_Type) = Credit then
          Value := - Value;
       Rem := Rem + Value;

       //now calculate sign needed
       if SignOf( Rem) = ExpectedSign( pAccount^.chAccount_Type) then
          Rem := Abs(Rem)
       else
          Rem := -1 * Abs(Rem);

       //apply
       tgBalances.CurrentCell.Value := FormatFloat( '0.00', Money2Double( Rem));
       tgBalances.EndEdit( false);
       tgBalances.CurrentDataRow := tgBalances.CurrentDataRow + 1;
     end;

     if Key = '-' then
     begin
       sValue := tgBalances.CurrentCell.Value;

       //process the user pressing '-' key
       //if whole cell is selcted then clear and allow minus
       if tgBalances.CurrentCell.SelLength = Length( sValue) then
         tgBalances.CurrentCell.Value := ''
       else
       begin
         if (sValue = '') then
           dValue := 0.00
         else
         begin
           if (sValue[1] = '(') and (sValue[length(sValue)] = ')') then
             //negative value
             sValue :='-' + Copy(sValue,2,Length(sValue)-2);
           dValue := StrToFloatDef(sValue ,0.0);
         end;

         if (dValue <> 0.00) then
         begin
           dValue := -1 * dValue;
           tgBalances.CurrentCell.Value := FormatFloat( '0.00', dValue);
         end;
       end;
     end;
   end;
end;

procedure TdlgOpeningBalances.tgBalancesMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  S: string;
  DCol, DRow: integer;
  DataCol, DataRow: integer;
  pAccount : pAccount_Rec;
begin
  tgBalances.ShowHint := False;
  tgBalances.Hint := '';
  //Get col and row
  tgBalances.CellFromXY(X, Y, DCol, DRow);

  if (DCol < 0) or (DRow < 0) then Exit;

  DataCol := tgBalances.DataColnr[DCol];
  DataRow := tgBalances.DataRownr[DRow];

  if (DataRow <= 0) then Exit;

  //If balance col
  if (DataCol = ColBalance) then begin
    //Get Account
    pAccount := FAccountList.Items[DataRow - 1];
    //If forex amt then show hint
    if (pAccount.chTemp_Opening_Balance_Currency <> ThisClient.clExtra.ceLocal_Currency_Code) and
       (pAccount.chTemp_Opening_Balance_Currency <> '')  then begin
      //Get foreign currency balance
      S := MakeAmountNoComma(GetForeignCurrencyAmount(pAccount));
      tgBalances.Hint := Format('Foreign currency opening balance: %s %s',
                                [S, pAccount.chTemp_Opening_Balance_Currency]);
      tgBalances.ShowHint := True;
    end;
  end;
end;

procedure TdlgOpeningBalances.tgBalancesPaintCell(Sender: TObject; DataCol,
  DataRow: Integer; ARect: TRect; State: TtsPaintCellState;
  var Cancel: Boolean);
var
  pAccount: pAccount_Rec;
  R: TRect;
  Value: String;
  TextWidth: integer;
begin
  if DataRow = 0 then Exit; //Header?

  if (DataCol = ColBalance) then begin
    //Draw notes icon
    pAccount := FAccountList.Items[DataRow - 1];
    if (pAccount.chTemp_Opening_Balance_Currency <> ThisClient.clExtra.ceLocal_Currency_Code) and
       (pAccount.chTemp_Opening_Balance_Currency <> '')  then begin
      R := ARect;

      R.Right := R.Left + ( R.Bottom - R.Top ); { Square at LH End }
      OffsetRect( R, -2, 0 ); { Move it Left a bit }

      tgBalances.Canvas.FillRect(ARect);
      tgBalances.Canvas.StretchDraw(R, ImagesFrm.AppImages.imgNotes.Picture.Bitmap);

      SetupBalanceCell(pAccount, DataCol, DataRow, Value);

      TextWidth := tgBalances.Canvas.TextWidth(Value);
      R := ARect;
      R.Left := R.Left + ( R.Bottom - R.Top );
      tgBalances.Canvas.TextRect(R, R.Right - TextWidth, R.Top, Value);

      Cancel := True;
      if ( DataCol = tgBalances.CurrentDataCol) and ( DataRow = tgBalances.CurrentDataRow) then
        Cancel := False;
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   if ModalResult = mrOK then begin
      if tgBalances.Enabled then begin
         CanClose := false;

         if not tgBalances.EndEdit( false) then exit;

         if GetAmountRemaining <> 0 then begin
            HelpfulErrorMsg( 'The amount remaining to be assigned is not zero.  All amounts must be allocated.', 0 );
            tgBalances.SetFocus;
            Exit;
         end;
      end;

   end;
   CanClose := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.tgBalancesInvalidMaskValue(Sender: TObject;
  DataCol, DataRow: Integer; var Accept: Boolean);
begin
   if DataCol = colBalance then begin
      //need to allow the user to exit the cell when value is blank
      if tgBalances.CurrentCell.Value = '' then begin
         tgBalances.CurrentCell.Value := '0.00';
         Accept := true;
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.SetBalancesForLinkedAccounts( SourceAccount: pAccount_Rec);
//assumes that the current balance for the source account is correct
var
  pOS_Acct,
  pCS_Acct  : pAccount_Rec;
begin
  if SourceAccount.chAccount_Type = atStockOnHand then
  begin
    pOS_Acct := ThisClient.clChart.FindCode( SourceAccount.chLinked_Account_OS);
    pCS_Acct := ThisClient.clChart.FindCode( SourceAccount.chLinked_Account_CS);

    if Assigned( pOS_Acct)
      and Assigned( pCS_Acct)
      and ( pOS_Acct.chAccount_Type = atOpeningStock)
      and ( pCS_Acct.chAccount_Type = atClosingStock) then
    begin
      pOS_Acct.chTemp_Money_Value := SourceAccount.chTemp_Money_Value;
      pCS_Acct.chTemp_Money_Value := -SourceAccount.chTemp_Money_Value;
    end;
  end;
end;

procedure TdlgOpeningBalances.SetupBalanceCell(pAccount: pAccount_Rec; DataCol,
  DataRow: Integer; var Value: string);
var
  GrayOut: boolean;
begin
  //if this is the currently edited cell then display without brackets
  if ( DataCol = tgBalances.CurrentDataCol) and ( DataRow = tgBalances.CurrentDataRow) then
    Value := FormatFloat( '0.00', pAccount.chTemp_Money_Value/100)
  else
    Value := MakeAmountNoComma( pAccount.chTemp_Money_Value);

  if pAccount.chAccount_Type in BalanceSheetReportGroupsSet then begin
    tgBalances.CellParentFont[ DataCol, DataRow] := true;
    tgBalances.CellColor[ DataCol, DataRow]      := clNone;
  end else begin
    GrayOut := ( pAccount.chAccount_Type in [ atOpeningStock, atClosingStock]) or (pAccount.chTemp_Money_Value = 0);
    tgBalances.CellParentFont[ DataCol, DataRow] := false;

    if GrayOut then
      tgBalances.CellFont[ DataCol, DataRow].color := clGrayText
    else
      tgBalances.CellFont[ DataCol, DataRow].color := clRed;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgOpeningBalances.ReloadLinkedAccountBalances;
var
  i : integer;
begin
  for i := ThisClient.clChart.First to ThisClient.clChart.Last do
  begin
    SetBalancesForLinkedAccounts( ThisClient.clChart.Account_At( i));
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
