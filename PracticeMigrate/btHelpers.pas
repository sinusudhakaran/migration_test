unit btHelpers;

interface
uses ArchUtil32;

type
 pArchived_Transaction = ^tArchived_Transaction;
function GetBankTransactionFields: string;
function GetBanktransactionValues
             (MyId: TGuid;
              AccountID: TGuid;
              Value: tArchived_Transaction
              ):string;



implementation

uses SQLHelpers;


function GetBankTransactionFields: string;
begin
  result := '[Id],[SequenceNo],[txnType],[Source],[DatePresented],[DateTransferred],[Amount]' +
         ',[ChequeNumber],[Reference],[Particulars],[Analysis],[OrigBB],[Narration]' +
         ',[StatementDetails],[BankLinkID],[OtherParty],[SystemBankAccountId]';
end;

function GetBanktransactionValues
             (MyId: TGuid;
              AccountID: TGuid;
              Value: tArchived_Transaction
              ):string;
begin with value do
   Result := ToSQL(MyId) + ToSQL(aLRN) + ToSQL(aType) + TOSQL(aSource) + DateTOSQL(aDate_Presented)
               + DateToSQL(aDate_Transferred) + TOSQL(aAmount)
           + TOSQL(aCheque_Number) + TOSQL(aReference) + TOSQL(aParticulars) + TOSQL(aAnalysis)
               + TOSQL(aOrigBB) + TOSQL(aNarration) + TOSQL(aStatement_Details)
           + ToSQL(aUnique_ID) + ToSQL(aOther_Party) + ToSQL(AccountID,False);
end;



end.
