unit TransferEntriesDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:        Transfer Entries Dialog

   Description:

   Remarks:      This dialog allows the user to select a bank account to transfer
                 entries from the Temp bank account into.  Any existing entries in
                 the system bank account which are in the selected date range will
                 be deleted before the Temp bank account entries are transfered.

                 If no entries are left in the temp bank account the user will be
                 prompted to delete the bank account.

                 All coding windows MUST be closed before calling this routine

   Author:       Matthew Aug 2000

}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  bkOKCancelDlg, ExtCtrls, StdCtrls, Menus, DateSelectorFme;

type
  TdlgTransferEntries = class(TbkOKCancelDlgForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    cmbTempAccount: TComboBox;
    cmbBankAccount: TComboBox;
    Panel1: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    lblTempAccount: TLabel;
    lblBankAccount: TLabel;
    lblTempEntries: TLabel;
    lblBankEntries: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    lblTempFrom: TLabel;
    lblBankFrom: TLabel;
    lblTempTo: TLabel;
    lblBankTo: TLabel;
    lblWarning: TLabel;
    Label4: TLabel;
    lblDupDesc: TLabel;
    lblDupFrom: TLabel;
    lblDupTo: TLabel;
    lblDupEntries: TLabel;
    DateSelector: TfmeDateSelector;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FieldChanged( Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
    procedure cmbTempAccountSelect(Sender: TObject);
    procedure cmbBankAccountSelect(Sender: TObject);
  private
    { Private declarations }
    procedure SetUpHelp;
    procedure UpdateStatistics;
  public
    { Public declarations }
  end;

  procedure TransferEntries;

//******************************************************************************
implementation

{$R *.DFM}

uses
  globals,
  baObj32,
  bkDefs,
  bkDateUtils,
  bkXPThemes,
  ClDateUtils,
  bkConst,
  WarningMoreFrm,
  InfoMoreFrm,
  YesNoDlg,
  LogUtil,
  Progress,
  baUtils,
  bkHelp,
  ECodingUtils,
  AuditMgr;

Const
   UnitName = 'TransferEntriesDlg';
//------------------------------------------------------------------------------

procedure TdlgTransferEntries.FormCreate(Sender: TObject);
begin

  with DateSelector do begin
    //set client
    ClientObj := MyClient;
    //set date bounds to first and last trx date
    InitDateSelect( BAllData( MyClient ), EAllData( MyClient ), btnOK);
    eDateFrom.asStDate := -1;
    eDateTo.asStDate   := -1;
  end;
  SetupHelp;

  lblWarning.caption := Format( lblWarning.caption, [ SHORTAPPNAME]);
end;
//------------------------------------------------------------------------------

procedure TdlgTransferEntries.SetUpHelp;
begin
   Self.ShowHint     := INI_ShowFormHints;
   Self.HelpContext  := 0;
   //Components
   cmbTempAccount.Hint := 'Choose a ' + UserDefinedBankAccountDesc + '|'+
                          'Choose a ' + UserDefinedBankAccountDesc + ' to transfer entries from';
   cmbBankAccount.Hint := 'Choose a system bank account|'+
                          'Choose a system bank account to transfer entries to';
end;
//------------------------------------------------------------------------------

function EntryWord( n : integer) : string;
begin
  if n = 1 then
     result := 'entry'
  else
     result := 'entries';
end;
//------------------------------------------------------------------------------

procedure TdlgTransferEntries.UpdateStatistics;
//update all the information fields where we have enough information
var
   iEntries : integer;
   dFrom    : integer;
   dTo      : integer;

   TempFrom : integer;
   TempTo   : integer;

   BankAccount : TBank_Account;
   TempAccount : TBank_Account;
begin
   BankAccount := nil;
   TempAccount := nil;

   lblTempAccount.caption  := '-';
   lblTempEntries.caption  := '0';
   lblTempFrom.caption     := '-';
   lblTempTo.caption       := '-';

   lblBankAccount.caption  := '-';
   lblBankEntries.caption  := '0';
   lblBankFrom.caption     := '-';
   lblBankTo.caption       := '-';

   lblDupDesc.visible      := false;
   lblDupEntries.caption   := '';
   lblDupFrom.caption      := '';
   lblDupTo.caption        := '';

   //combo boxes have valid selections
   if ( cmbTempAccount.ItemIndex <> -1) then begin
      TempAccount := TBank_Account( cmbTempAccount.Items.Objects[ cmbTempAccount.ItemIndex]);
   end;
   if ( cmbBankAccount.ItemIndex <> -1) then begin
      BankAccount := TBank_Account( cmbBankAccount.Items.Objects[ cmbBankAccount.ItemIndex]);
   end;

   if Assigned( TempAccount) then begin
      lblTempAccount.caption  := StringReplace(cmbTempAccount.Items[ cmbTempAccount.ItemIndex], '&', '&&', [rfReplaceAll]);
      //count entries
      GetStatsForAccount( TempAccount, 0, MaxInt , iEntries, TempFrom, TempTo);
      lblTempEntries.caption  := IntToStr( iEntries);
      if iEntries > 0 then begin
         lblTempFrom.caption     := BKDate2Str( TempFrom);
         lblTempTo.caption       := BKDate2Str( TempTo);
      end;
   end;

   if Assigned( BankAccount) then begin
      lblBankAccount.caption  := StringReplace(cmbBankAccount.Items[ cmbBankAccount.ItemIndex], '&', '&&', [rfReplaceAll]);;

      GetStatsForAccount( BankAccount, 0, MaxInt, iEntries, dFrom, dTo);
      lblBankEntries.caption  := IntToStr( iEntries);
      if iEntries > 0 then begin
         lblBankFrom.caption     := BKDate2Str( dFrom);
         lblBankTo.caption       := BKDate2Str( dTo);
      end;
   end;

   //now look for possible duplicates.  ie bank account trx which are within the date range of
   //the temp account
   if Assigned( TempAccount) and Assigned( BankAccount) then begin
      GetStatsForAccount( BankAccount, TempFrom, TempTo , iEntries, dFrom, dTo);
      if iEntries > 0 then begin
         lblDupDesc.visible      := true;
         lblDupEntries.caption  := IntToStr( iEntries);
         lblDupFrom.caption     := BKDate2Str( dFrom);
         lblDupTo.caption       := BKDate2Str( dTo);
      end;
   end;
end;
//------------------------------------------------------------------------------

procedure TdlgTransferEntries.cmbBankAccountSelect(Sender: TObject);
begin
  UpdateStatistics;
end;

procedure TdlgTransferEntries.cmbTempAccountSelect(Sender: TObject);
var
  baFrom, baTo: TBank_Account;
  i, FromEntries, ToEntries, D1, D2, D3, D4: Integer;
begin
  if cmbTempAccount.ItemIndex = -1 then
  begin
    cmbBankAccount.Clear;
    exit;
  end;
  baFrom := TBank_Account(cmbTempAccount.Items.Objects[cmbTempAccount.ItemIndex]);
  cmbBankAccount.Clear;
  if Assigned(baFrom) then
  begin
    // List all accounts with first entry date after or equal last entry date of selected account
    with MyClient.clBank_Account_List do
      for i := 0 to Pred( ItemCount) do
      begin
        baTo := Bank_Account_At( i);
        if (baTo.baFields.baAccount_Type <> btBank)
        or (baTo.IsManual)
        or (baFrom.baFields.baCurrency_Code <> baTo.baFields.baCurrency_Code)
        or (baFrom = baTo) then
           Continue;
        cmbBankAccount.Items.AddObject( baTo.Title, baTo);
      end;
    if cmbBankAccount.Items.Count = 1 then // if only one then select it
      cmbBankAccount.ItemIndex := 0;
  end;
  if cmbBankAccount.Items.Count = 0 then
    HelpfulInfoMsg('There are no system bank accounts that can be merged with the selected account.', 0);
  UpdateStatistics;
end;

procedure TdlgTransferEntries.FieldChanged(Sender: TObject);
//triggered by cmb changes
begin
   UpdateStatistics;
end;
//------------------------------------------------------------------------------

procedure TdlgTransferEntries.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
   TempBA : TBank_Account;
   BankBA : TBank_Account;
   FromDate,
   ToDate   : integer;
   TempFromDate,
   TempToDate : integer;
   d1,d2    : integer;
   TempEntries : integer;
   BankEntries : integer;
   aMsg         : string;
begin
  if ModalResult = mrOK then begin
     //check accounts
     if ( cmbBankAccount.ItemIndex = -1) or ( cmbTempAccount.ItemIndex = -1) then begin
        HelpfulWarningMsg( 'You must select both a ' + UserDefinedBankAccountDesc + ' AND a System Bank Account.',0);
        CanClose := false;
        exit;
     end;

     if (not DateSelector.ValidateDates) then
     begin
       CanClose := False;
       DateSelector.eDateFrom.SetFocus;
       Exit;
     end;

     FromDate := DateSelector.eDateFrom.AsStDate;
     ToDate   := DateSelector.eDateTo.AsStDate;

     TempBa   := TBank_Account( cmbTempAccount.Items.Objects[ cmbTempAccount.ItemIndex]);
     BankBa   := TBank_Account( cmbBankAccount.Items.Objects[ cmbBankAccount.ItemIndex]);

     //check dates valid
     if ( FromDate <= 0) or ( ToDate <=0) or ( FromDate > ToDate) then begin
        HelpfulWarningMsg( 'Please select valid dates.',0);
        CanClose := false;
        DateSelector.eDateFrom.SetFocus;
        exit;
     end;

     //check that there are entries to transfer
     GetStatsForAccount( TempBa, FromDate, ToDate, TempEntries, TempFromDate, TempToDate);
     //now find how many bank entries in that range
     GetStatsForAccount( BankBa, TempFromDate, TempToDate, BankEntries, d1,d2);

     if ( TempEntries = 0) then begin
        HelpfulWarningMsg( 'There are no entries in the manual account to transfer.',0);
        CanClose := false;
        exit;
     end;

     //warning user about what they are going to do
     aMsg := 'You are about to transfer %d %s dated %s to %s'#13#13'from Manual Account'#13'"%s"'#13#13'to Bank Account'#13'"%s".';

     aMsg := Format( aMsg, [ TempEntries,
                             EntryWord( TempEntries),
                             BkDate2Str( TempFromDate),
                             BkDate2Str( TempToDate),
                             TempBa.bafields.baBank_Account_Number + ' ' + TempBa.AccountName,
                             BankBa.baFields.baBank_Account_Number + ' ' + BankBa.AccountName]);

     if BankEntries > 0 then begin
        aMsg := aMsg + #13#13'%d existing %s will be deleted from Bank Account "%s".';
        aMsg := Format( aMsg, [ BankEntries,
                              EntryWord( BankEntries),
                              BankBa.baFields.baBank_Account_Number]);
     end;

     if AskYesNo( 'Transfer Entries',
                  aMsg + #13#13+
                  'Do you wish to continue?', DLG_NO, 0) <> DLG_YES then begin
        CanClose := false;
        exit;
     end;
  end;
end;
//------------------------------------------------------------------------------

procedure TransferEntries;
//note:
//   dates are effective dates
var
   i, j        : integer;
   ba, ba2     : TBank_Account;
   TempBa,
   BankBa   : TBank_Account;
   FromDate : integer;
   ToDate   : integer;

   TempFromDate,
   TempToDate  : integer;
   TempEntries : integer;

   pT       : pTransaction_Rec;
   DeleteCount : integer;
   TransferCount : integer;
   aMsg          : String;

   TrxIndex     : integer;
   Dissection: pDissection_Rec;
   AccList : TStringList;
begin
   if not Assigned( MyClient) then exit;

   with TDlgTransferEntries.Create(Application.MainForm) do begin
      try
         //load bank account combo boxes
         cmbTempAccount.Clear;
         cmbBankAccount.Clear;
         with MyClient.clBank_Account_List do begin
            //Add system bank accounts
            for i := 0 to Pred( ItemCount) do begin
               ba := Bank_Account_At( i);
               if ba.baFields.baAccount_Type = btBank then begin
                  if (not ba.IsManual) then
                  //add to system accounts list
                  cmbBankAccount.Items.AddObject( ba.Title, ba);
               end;
            end;
            //Add manual bank accounts
            for i := 0 to Pred( ItemCount) do begin
               ba := Bank_Account_At( i);
               if (ba.baFields.baAccount_Type = btBank) and (ba.IsManual) then begin
                  //Only add if system account exists with same currency
                  for j := 0 to Pred(cmbBankAccount.Items.Count) do begin
                    ba2 := TBank_Account(cmbBankAccount.Items.Objects[j]);
                    if Assigned(ba2) then begin
                      if (ba.baFields.baCurrency_Code = ba2.baFields.baCurrency_Code) then begin
                        //add to manual accounts list
                        cmbTempAccount.Items.AddObject( ba.Title, ba);
                        Break;
                      end;
                    end;
                  end;
               end;
            end;
         end;   

         //if no bank or temp accounts exist then exit;
         if cmbTempAccount.Items.Count = 0 then begin
            HelpfulWarningMsg('This Client File does not contain any ' + UserDefinedBankAccountDesc + 's.',0);
            exit;
         end;

         if cmbBankAccount.Items.Count = 0 then begin
            HelpfulWarningMsg('This Client File does not contain any System Bank Accounts to transfer entries to.',0);
            exit;
         end;

          //Check if they have outstanding BNotes or Acclipse files, and warn them against continuing. Case 8625
         if not CheckOutstandingEcodingFiles(MyClient) then Exit;


         //if only one item in box then auto select
         if cmbTempAccount.Items.Count = 1 then
            cmbTempAccount.ItemIndex := 0;

         cmbTempAccountSelect(nil);

         //update stats
         FieldChanged( nil);

         ShowModal;

         //user selected ok and inputs verified
         if ModalResult = mrOK then begin

            //show progress
            UpdateAppStatus('Transfering entries','',30);
            try
               FromDate := DateSelector.eDateFrom.AsStDate;
               ToDate   := DateSelector.eDateTo.AsStDate;
               TempBa   := TBank_Account( cmbTempAccount.Items.Objects[ cmbTempAccount.ItemIndex]);
               BankBa   := TBank_Account( cmbBankAccount.Items.Objects[ cmbBankAccount.ItemIndex]);

               AccList := TStringList.Create;
               try
                 AccList.Add(TempBa.baFields.baBank_Account_Number);
                 AccList.Add(BankBa.baFields.baBank_Account_Number);
                 MyClient.clRecommended_Mems.RemoveAccountsFromMems(AccList, False);
               finally
                 FreeAndNil(AccList);
               end;

               //get date range for temp account transactions - no need to delete any more transactions
               //than necessary
               GetStatsForAccount( TempBa, FromDate, ToDate, TempEntries, TempFromDate, TempToDate);

               DeleteCount := 0;
               TransferCount := 0;

               LogUtil.LogMsg( lmInfo, UnitName, 'Transfering entries from ' + TempBa.baFields.baBank_Account_Number + ' to ' + BankBa.BaFields.baBank_Account_Number);
               LogUtil.LogMsg( lmInfo, UnitName, 'Transfering entries dated ' + BkDate2Str( TempFromDate) + ' to '+ BkDate2Str( TempToDate));

               //delete any entries in the system bank account
               with BankBa.baTransaction_List do begin
                  TrxIndex := -1;
                  i        := 0;
                  //find first entry within date range
                  While ( i < ItemCount) and ( TrxIndex < 0) do begin
                     pT := Transaction_At( i);
                     if (( pT^.txDate_Effective >= TempFromDate) and ( pT^.txDate_Effective <= TempToDate)) then
                        TrxIndex := i;
                     //move to next index in list
                     Inc( i);
                  end;
                  if ( TrxIndex >= 0 ) then begin
                     //transaction found so delete at this index until outside date range
                     repeat
                        pT := Transaction_At( TrxIndex);
                        if (( pT^.txDate_Effective >= TempFromDate) and ( pT^.txDate_Effective <= TempToDate)) then begin
                           //delete from temp account
                           Delete( pT);
                           Inc( DeleteCount);
                        end;
                     until ( TrxIndex >= ItemCount) or ( pT^.txDate_Effective > TempToDate);
                  end;
               end;
               if DeleteCount > 0 then
                  LogUtil.LogMsg( lmInfo, UnitName, 'Deleted ' + inttostr( DeleteCount) + ' ' +
                                                    EntryWord( DeleteCount) +' from ' +
                                                    BankBa.BaFields.baBank_Account_Number);

               //insert entries from the Temp account into system account
               //find index for first transaction
               //no need to test if transaction found because already know that entries exist in the date range
               TrxIndex := -1;
               with TempBa.baTransaction_List do begin
                  for i := 0 to Pred( ItemCount) do begin
                     pT := Transaction_At( i);
                     if ( pT^.txDate_Effective >= TempFromDate) and ( pT^.txDate_Effective <= TempToDate) then begin
                        TrxIndex := i;
                        Break;
                     end;
                  end;
                  //loop around transfering the trx and then deleting trx until outside date range or end of list
                  repeat
                     pT := Transaction_At( TrxIndex);
                     if (( pT^.txDate_Effective >= TempFromDate) and ( pT^.txDate_Effective <= TempToDate)) then begin
                        //delete from temp account
                        TempBa.baTransaction_List.Delete( pT);
                        //change sequence no to match new bank account - important for sorting!
                        pT^.txBank_Seq := BankBa.baFields.baNumber;
                        //delete the ecoding id as this is related to a bank account not to a transaction
                        pT^.txECoding_Transaction_UID := 0;
                        //insert into bank account
                        BankBa.baTransaction_List.Insert_Transaction_Rec( pT);

                        Dissection := pT^.txFirst_Dissection;

                        while Dissection <> nil do
                        begin
                          Dissection.dsBank_Account := pT^.txBank_Account;
                          Dissection.dsClient := pT^.txClient;
                          Dissection := Dissection.dsNext;
                        end;
                
                        Inc( TransferCount);
                     end;
                  until ( TrxIndex >= ItemCount) or ( pT^.txDate_Effective > TempToDate);
               end;
               MyClient.clRecommended_Mems.PopulateUnscannedListOneAccount(BankBa);
            finally
               //clear progress
               ClearStatus;
            end;

            //transfer complete
            aMsg := 'Transfered ' + inttostr( TransferCount) +
                    ' ' + EntryWord( TransferCount) +' from ' + TempBa.baFields.baBank_Account_Number +
                    ' to ' + BankBa.baFields.baBank_Account_Number;

            LogUtil.LogMsg( lmInfo, UnitName, aMsg);
            HelpfulInfoMsg( aMsg, 0);

            //*** Flag Audit ***
            //Set audit info here so no system client file record
            //needs to be saved to the audit table.
            aMsg := Format('Transfered manual bank account %s%sFrom %s%sTo %s%sTransactions Added=%d',
                           [EntryWord(TransferCount), VALUES_DELIMITER,
                            TempBa.Title, VALUES_DELIMITER,
                            BankBa.Title, VALUES_DELIMITER,
                            TransferCount]);
            MyClient.ClientAuditMgr.FlagAudit(arClientBankAccounts,
                                              BankBa.baFields.baAudit_Record_ID,
                                              aaNone,
                                              aMsg);

            //if there are no entries left in the Temp account then prompt user
            //to delete the account.
            if ( TempBa.baTransaction_List.ItemCount = 0) then begin
               if AskYesNo( 'Delete ' + UserDefinedBankAccountDesc,
                            'There are no longer any entries in the ' + UserDefinedBankAccountDesc + ' '+
                            '"'+ TempBa.baFields.baBank_Account_Number+'".'#13#13+

                            'Do you wish to delete this account?', DLG_YES, 0) = DLG_YES then begin
                  //delete the empty account from the client file
                  MyClient.clBank_Account_List.DelFreeItem( TempBa);
                  LogUtil.LogMsg( lmInfo, UnitName, 'Deleted ' + UserDefinedBankAccountDesc);
               end;
            end;
         end;
      finally
         Free;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgTransferEntries.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  inherited;
  case Msg.CharCode of
    109: begin
           DateSelector.btnPrev.Click;
           Handled := true;
         end;
    107: begin
           DateSelector.btnNext.click;
           Handled := true;
         end;
    VK_MULTIPLY : begin
           DateSelector.btnQuik.click;
           handled := true;
         end;
  end;
end;

procedure TdlgTransferEntries.FormShow(Sender: TObject);
begin
  BKHelpSetup(Self, BKH_Combining_manual_and_system_bank_accounts);
end;

end.
