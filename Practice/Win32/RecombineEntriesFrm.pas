unit RecombineEntriesFrm;
//------------------------------------------------------------------------------
{
   Title:       Recombine Entries Selection Box

   Description:

   Remarks:     Can only recombine base entries i.e. bank or historical

   Author:      Matthew Hopkins  Feb 2001

}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ComCtrls, ExtCtrls, StdCtrls,

  bkDefs, baobj32,
  OSFont;



type
  TfrmRecombineEntries = class(TForm)
    btnCombine: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Shape1: TShape;
    lblDate: TLabel;
    lblRef: TLabel;
    lblCode: TLabel;
    lblAmount: TLabel;
    lblEntryType: TLabel;
    Label3: TLabel;
    lvEntries: TListView;
    lblWarning: TLabel;
    Panel1: TPanel;
    pnlReinstate: TPanel;
    lblReinstate: TLabel;
    InfoBmp: TImage;
    pnlNewEntry: TPanel;
    lblNewDate: TLabel;
    lblNewRef: TLabel;
    lblNewCode: TLabel;
    lblNewAmount: TLabel;
    lblNewEntryType: TLabel;
    Label9: TLabel;
    Label4: TLabel;
    WarningBmp: TImage;

    procedure lvEntriesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvEntriesDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnHelpClick(Sender: TObject);
  private
    { Private declarations }
    MatchedItemsCount : integer;
    Transaction       : pTransaction_Rec;
    fBankAccount : TBank_Account;
    procedure UpdateInfo;
  public
    { Public declarations }
  end;

  function RecombineEntry(BankAccount : TBank_Account; pT : pTransaction_Rec) : pTransaction_Rec;


//******************************************************************************
implementation

uses
  GenUtils,
  bkDateUtils,
  BKHelp,
  bkUtil32,
  BKCONST,
  BkTXIO,
  bkXPThemes,
  MoneyDef,
  WarningMoreFrm,
  LogUtil,
  ForexHelpers,
  Globals,
  AuditMgr;
{$R *.DFM}

CONST
   UnitName = 'RecombineEntriesFrm';

//------------------------------------------------------------------------------

function RecombineEntry( BankAccount : TBank_Account; pT : pTransaction_Rec) : pTransaction_Rec;
{
   Returns the resulting entry.  This may be a balancing entry, or it may be the original entry
}
var
   RecombineEntries : TfrmRecombineEntries;
   i          : integer;
   CurrTrans  : pTransaction_Rec;
   NewTrans   : pTransaction_Rec;
   NewItem    : TListItem;
   SomeExcluded : Boolean;
   CheckedCount : integer;
   CheckedTotal : Money;
   CheckedForexTotal : Money;
   sMsg, AuditIDs: string;
   AuditID: integer;
   AuditType: TAuditType;
begin
  Result := nil;

  RecombineEntries := TfrmRecombineEntries.Create(Application.MainForm);
  with RecombineEntries do
  begin
    try
      BKHelpSetUp(RecombineEntries, BKH_Un_matching_unpresented_cheques);
      //store pointer to transaction for later use
      Transaction := pT;
      fBankAccount := BankAccount;
      //load details of original transaction
      lblDate.caption      := bkDate2Str( pT^.txDate_Presented);
      lblRef.Caption       := MakeCodingRef( pT^.txOriginal_Reference);
      lblCode.caption      := '';
      lblAmount.caption    := BankAccount.MoneyStr( pT^.txOriginal_Amount );

      lblEntryType.caption := IntToStr( pT^.txOriginal_Type)+ ':' + MyClient.clFields.clShort_Name[ pT^.txOriginal_Type];

      //load entries which can be combined
      SomeExcluded := false;
      MatchedItemsCount := 0;

      for i := 0 to Pred( BankAccount.baTransaction_List.ItemCount) do begin
         CurrTrans := BankAccount.baTransaction_List.Transaction_At( i);
         //find entries which are matched against same original transaction
         if ( CurrTrans^.txMatched_Item_ID = pT^.txMatched_Item_ID) then begin
            Inc( MatchedItemsCount);
            //now check that entry can be recombined
            if ( CurrTrans^.txUPI_State in [ upBalanceOfUPC, upBalanceOfUPD, upBalanceOfUPW]) and
               ( CurrTrans^.txDate_Transferred = 0) and
               ( not CurrTrans^.txLocked) then begin

               NewItem := lvEntries.Items.Add;
               NewItem.Caption := bkDate2Str( CurrTrans^.txDate_Effective);
               NewItem.SubItems.AddObject( GetFormattedReference( CurrTrans), TObject( CurrTrans));
               NewItem.SubItems.Add( CurrTrans^.txAccount);
               NewItem.SubItems.Add( MakeAmount( CurrTrans^.Statement_Amount));
               NewItem.SubItems.Add( IntToStr( CurrTrans^.txType)+ ':' + MyClient.clFields.clShort_Name[ CurrTrans^.txType]);
               //select all items by default
               NewItem.Checked := true;
            end
            else begin
               //matching transaction found, but cannot be recombined.
               //maybe locked or matched against UPI
               SomeExcluded := true;
            end;
         end;
      end;
      if SomeExcluded then
         lblWarning.Visible := true;
      UpdateInfo;
      //------------------
      ShowModal;
      //------------------
      if ( ModalResult = mrOK) then begin
         //stop window updates because deleting transaction
         LockWindowUpdate( Application.MainForm.Handle);
         CheckedCount := 0;
         CheckedTotal := 0;
         CheckedForexTotal := 0;
         AuditIDs := '';
         //get total of all checked transactions
         for i := 0 to Pred( lvEntries.Items.Count) do begin
            if lvEntries.Items[ i].Checked then begin
               Inc( CheckedCount);
               CurrTrans    := pTransaction_Rec( lvEntries.Items[ i].SubItems.Objects[0]);
               //log event
               sMsg := 'Recombine entry ' +
                       BkDate2Str( CurrTrans^.txDate_Effective) + ' ' +
                       GetFormattedReference( CurrTrans ) + ' ' +
                       BankAccount.MoneyStr( Currtrans^.Statement_Amount );
               LogUtil.LogMsg(lmInfo,UnitName, sMsg );

               //*** Flag Audit ***
               MyClient.ClientAuditMgr.FlagAudit(MyClient.ClientAuditMgr.GetTransactionAuditType(CurrTrans^.txSource,
                                                                                                 BankAccount.baFields.baAccount_Type),
                                                 Currtrans^.txAudit_Record_ID,
                                                 aaNone,
                                                 sMsg);

               CheckedTotal := CheckedTotal + CurrTrans^.Local_Amount;
               CheckedForexTotal := CheckedForexTotal + CurrTrans^.txAmount;
               if AuditIDs = '' then
                 AuditIDs := intToStr(CurrTrans^.txAudit_Record_ID)
               else
                 AuditIDs := AuditIDs + ',' + intToStr(CurrTrans^.txAudit_Record_ID);
            end;
         end;

         //add balancing entry, or reinstate original entry

         if ( CheckedCount = MatchedItemsCount) and
            ( CheckedTotal = pT^.Local_Amount) and
            ( CheckedForexTotal = pT^.txOriginal_Amount ) then
         begin
            NewTrans := BankAccount.baTransaction_List.New_Transaction;
            with NewTrans^ do begin
               txDate_Presented        := pT^.txDate_Presented;
               txDate_Effective        := pT^.txDate_Presented;
               txType                  := pT^.txOriginal_Type;
               txSource                := pT^.txOriginal_Source;
               txReference             := pT^.txOriginal_Reference;
               txCheque_Number         := pT^.txOriginal_Cheque_Number;
               txAmount                := pT^.txOriginal_Amount;
               txForex_Conversion_Rate   := pT^.txOriginal_Forex_Conversion_Rate       ;
               txBank_Seq              := pT^.txBank_Seq;
               txUPI_State             := upNone;

            end;
            BankAccount.baTransaction_List.Insert_Transaction_Rec( NewTrans);
            //log event
            sMsg := 'Original entry recreated ' +
                    bkDate2Str( NewTrans^.txDate_Effective) + ' ' +
                    GetFormattedReference( NewTrans) + ' ' +
                    MyClient.MoneyStr( NewTrans^.txAmount );
            LogUtil.LogMsg( lmInfo, UnitName, sMsg );

            //*** Flag Audit ***
            sMsg := Format('%s (AuditIDs=%s)', [sMsg, AuditIDs]);
            MyClient.ClientAuditMgr.FlagAudit(arUnpresentedItems,
                                              NewTrans^.txAudit_Record_ID,
                                              aaNone,
                                              sMsg);

            result := NewTrans;
         end
         else begin
            //original entry still needed, recreate balancing transaction.
            NewTrans := BankAccount.baTransaction_List.New_Transaction;
            with NewTrans^ do begin
               txDate_Effective  := pT^.txDate_Presented;
               txDate_Presented  := pT^.txDate_Presented;
               txType            := pT^.txOriginal_Type;
               txSource          := pT^.txOriginal_Source;
               txReference       := pT^.txOriginal_Reference;
               txCheque_Number   := pT^.txOriginal_Cheque_Number;
               txAmount          := CheckedForexTotal;
               txSequence_No     := pT^.txSequence_No;
               txUPI_State       := pT^.txUPI_State;
               txMatched_Item_ID := pT^.txMatched_Item_ID;
               txBank_Seq        := pT^.txBank_Seq;
               txForex_Conversion_Rate   := pT^.txOriginal_Forex_Conversion_Rate       ;


               //store details of original transaction
               txOriginal_Type   := pT^.txOriginal_Type;
               txOriginal_Reference := pT^.txOriginal_Reference;
               txOriginal_Source    := pT^.txOriginal_Source;
               txOriginal_Cheque_Number := pT^.txOriginal_Cheque_Number;
               txOriginal_Amount        := pT^.txOriginal_Amount;
               txOriginal_Forex_Conversion_Rate    := pT^.txOriginal_Forex_Conversion_Rate    ;

               txSF_Member_Account_ID:= -1;
               txSF_Fund_ID          := -1;
            end;
            BankAccount.baTransaction_List.Insert_Transaction_Rec( NewTrans);
            //log event
            sMsg := 'New balancing entry ' +
                    BkDate2Str( NewTrans^.txDate_Effective) + ' ' +
                    GetFormattedReference( NewTrans) + ' ' +
                    MakeAmount( NewTrans^.txAmount);
            LogUtil.LogMsg(lmInfo,UnitName, sMsg);

            //*** Flag Audit ***
            sMsg := Format('%s (AuditIDs=%s)', [sMsg, AuditIDs]);
            MyClient.ClientAuditMgr.FlagAudit(MyClient.ClientAuditMgr.GetTransactionAuditType(NewTrans^.txSource,
                                                                                              BankAccount.baFields.baAccount_Type),
                                              NewTrans^.txAudit_Record_ID,
                                              aaNone,
                                              sMsg);
            result := NewTrans;
         end;
         //remove entries that are checked from the bank account
         for i := 0 to Pred( lvEntries.Items.Count) do begin
            if lvEntries.Items[ i].Checked then begin
               CurrTrans    := pTransaction_Rec( lvEntries.Items[ i].SubItems.Objects[0]);
               AuditID := CurrTrans^.txAudit_Record_ID;
               AuditType := MyClient.ClientAuditMgr.GetTransactionAuditType(CurrTrans^.txSource,
                                                                            BankAccount.baFields.baAccount_Type);
               BankAccount.baTransaction_List.DelFreeItem( CurrTrans);
               lvEntries.Items[ i].SubItems.Objects[0] := nil;

               //*** Flag Audit ***
               MyClient.ClientAuditMgr.FlagAudit(AuditType,
                                                 AuditID,
                                                 aaNone,
                                                 'Recombined Transaction Deleted');
            end;
         end;
      end;
    finally
      Free;
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure TfrmRecombineEntries.UpdateInfo;
//update screen so that new entry panel or orig entry panel is shown
var
   CheckedCount : integer;
   i            : integer;
   CheckedTotal : Money;
   CheckedForexTotal : Money;
begin
   //count how many items checked
   CheckedCount := 0;
   CheckedTotal := 0;
   CheckedForexTotal := 0;
   for i := 0 to Pred( lvEntries.Items.Count) do begin
      if lvEntries.Items[ i].Checked then begin
         Inc( CheckedCount);
         CheckedTotal := CheckedTotal + pTransaction_Rec( lvEntries.Items[ i].SubItems.Objects[0])^.Local_Amount;
         CheckedForexTotal := CheckedForexTotal + pTransaction_Rec( lvEntries.Items[ i].SubItems.Objects[0])^.txAmount;
      end;
   end;

   //must selected at least 2 entries
   if CheckedCount < 2 then
   begin
      label4.visible := true;
      WarningBmp.Visible := true;
      pnlNewEntry.visible  := false;
      pnlReinstate.Visible := false;
      exit;
   end
   else
   begin
      label4.visible := false;
      WarningBmp.Visible := false;
      pnlNewEntry.visible  := false;
      pnlReinstate.Visible := false;
   end;

   //decide whether to show new entry or tell original will be reinstated
   if ( MatchedItemsCount = CheckedCount) and
      ( CheckedTotal = Transaction^.Local_Amount ) and
      ( CheckedForexTotal = Transaction^.txOriginal_Amount ) then
      pnlReinstate.Visible := true
   else
   begin
      //show details of new transaction
      lblNewDate.caption      := bkDate2Str( Transaction^.txDate_Presented);
      lblNewRef.Caption       := upNames[ Transaction^.txUPI_State] + MakeCodingRef( Transaction^.txOriginal_Reference);
      lblNewCode.caption      := '';
      if fBankAccount.IsAForexAccount then
        lblNewAmount.caption    := fBankAccount.MoneyStr( CheckedForexTotal )
      else
        lblNewAmount.caption    := fBankAccount.MoneyStr( CheckedTotal );
      lblNewEntryType.caption := IntToStr( Transaction^.txOriginal_Type)+ ':' + MyClient.clFields.clShort_Name[ Transaction^.txOriginal_Type];
      pnlNewEntry.visible  := true;
   end;
end;
//------------------------------------------------------------------------------

procedure TfrmRecombineEntries.lvEntriesClick(Sender: TObject);
begin
   UpdateInfo;
end;
//------------------------------------------------------------------------------

procedure TfrmRecombineEntries.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  pnlReinstate.Top    := pnlNewEntry.Top;
  pnlReinstate.Left   := pnlNewEntry.Left;

  //clear status panel
  label4.visible := true;
  WarningBmp.Visible := true;
  pnlNewEntry.visible  := false;
  pnlReinstate.Visible := false;
end;
//------------------------------------------------------------------------------

procedure TfrmRecombineEntries.lvEntriesDblClick(Sender: TObject);
begin
   UpdateInfo;
end;
//------------------------------------------------------------------------------

procedure TfrmRecombineEntries.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
   CheckedCount : integer;
   i            : integer;
begin
   if ModalResult = mrOK then begin
      //count how many items checked
      CheckedCount := 0;
      for i := 0 to Pred( lvEntries.Items.Count) do begin
         if lvEntries.Items[ i].Checked then begin
            Inc( CheckedCount);
         end;
      end;

      if CheckedCount < 2 then begin
         HelpfulWarningMsg( 'You must select a least two entries to recombine!',0);
         CanClose := false;
         exit;
      end;
   end;
end;
//------------------------------------------------------------------------------

procedure TfrmRecombineEntries.btnHelpClick(Sender: TObject);
begin
  BKHelpShowContext( BKH_Un_matching_unpresented_cheques);
end;

end.
