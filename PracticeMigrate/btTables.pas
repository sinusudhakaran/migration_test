unit btTables;

interface
uses
  DB,
  ADODB,
  ArchUtil32,
  MigrateTable;

type

  TbtTable = class (TMigrateTable)
  protected
     procedure SetupTable; override;
  public
     function Insert (MyId: TGuid;
              AccountID: TGuid;
              Value: tArchived_Transaction
              ): Boolean;

  end;

implementation



{ btTable }

procedure TbtTable.SetupTable;
begin
   TableName := 'BankTransactions';
   SetFields(['Id','SequenceNo','txnType','Source','DatePresented','DateTransferred','Amount','Quantity',
         'ChequeNumber','Reference','Particulars','Analysis','OrigBB','Narration',
         'StatementDetails','BankLinkID','OtherParty','SystemBankAccountId'],[]);


end;

function TbtTable.Insert(MyId, AccountID: TGuid;
  Value: tArchived_Transaction): Boolean;
begin
   with Value do
   Result := RunValues([ToSQL(MyId) , ToSQL(aLRN) , ToSQL(aType) , TOSQL(aSource) , DateTOSQL(aDate_Presented)
               , DateToSQL(aDate_Transferred) , TOSQL(aAmount), QtyToSQL(aQuantity)
           , TOSQL(aCheque_Number) , TOSQL(aReference) , TOSQL(aParticulars) , TOSQL(aAnalysis)
               , TOSQL(aOrigBB) , TOSQL(aNarration) , TOSQL(aStatement_Details)
           , ToSQL(aUnique_ID) , ToSQL(aOther_Party) , ToSQL(AccountID )],[]);
end;


end.
