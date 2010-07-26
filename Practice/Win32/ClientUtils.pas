// Client utilities module

unit ClientUtils;

interface

uses Classes, bkdefs;

procedure AddNewProspectRec(const ClientCode, ClientName, Address1,
  Address2, Address3, Phone, Fax, Mobile, Sal, Email, ContactName: string;
  const User: Integer);
procedure UpdateClientRecord(const ClientCode, ClientName, Address1,
  Address2, Address3, Phone, Fax, Mobile, Sal, Email, ContactName: string;
  const UserID: Integer);
function GenerateProspectCode(const Code, ClientName, CurrentCode: string): string;
function IsABadCode( S : String ): Boolean;
function IsCodeValid(Code: string; var Errors: string; CurrentCode: string): Boolean;
function CheckCodeExists(Code: string; Silent: Boolean = False): Boolean;
function GetLastPrintedDate(Code: string; BLRN: Integer): Integer;
procedure SetLastPrintedDate(Code: string; BLRN: Integer);
procedure SetTempPrintedDate(Code: string; BLRN, TempDate: Integer);
function CountEntriesToPurge(TestDate: Integer; TrnsfOnly: boolean; const BankAccountList: TStringList): integer;
function CountUPIs(TestDate: Integer; TrnsfOnly: boolean; const BankAccountList: TStringList): integer;
function OkToPurgeTransaction( pT : pTransaction_Rec; TestDate : integer; PurgeTrnsfOnly : boolean) : boolean;
function OkToPurgeUPI(pT: pTransaction_Rec; TestDate: integer): boolean;
procedure PurgeEntriesFromMyClient(const PurgeDate: integer;
                                   const DelTransferredOnly: boolean;
                                   var TotalDeleted, TotalUnpresented: integer;
                                   const BankAccountList: TStringList);

const
  UnitName = 'ClientUtils';

implementation

uses SysUtils, ClientDetailCacheObj, Globals, SyDefs, SycfIO, BkConst, Admin32,
  ErrorMoreFrm, LogUtil, trxList32, bkdateutils, stdate, baObj32,clObj32, Files;

// Check to see if a given client code is valid
function IsABadCode( S : String ): Boolean;
Begin
   S := UpperCase( S );
   result := ( S='CON' ) or ( S='AUX' ) or ( S='COM1' ) or ( S='COM2' ) or
             ( S='PRN' ) or ( S='LPT1' ) or ( S='LPT2' ) or ( S='LPT3' ) or ( S='NUL' ) or
             ( pos( '.', S )>0 ) or
             ( pos( ':', S )>0 ) or
             ( pos( '\', S )>0 ) or
             ( pos( '/', S )>0 ) or
             ( pos( '*', S )>0 ) or
             ( pos( '"', S )>0 ) or
             ( pos( '<', S )>0 ) or
             ( pos( '>', S )>0 ) or
             ( pos( '|', S )>0 ) or
             ( pos( '~', S )>0 ) or
             ( pos( '?', S )>0 );
end;

// Validate a given client code and return errors
function IsCodeValid(Code: string; var Errors: string; CurrentCode: string): Boolean;
var
  cfRec : pClient_File_Rec;
begin
  Result := True;
  Errors := '';
  if Assigned(Adminsystem) then
    cfRec := AdminSystem.fdSystem_Client_File_List.FindCode(Code)
  else
    cfRec := nil;
  if Code = '' then
  begin
    Errors := 'Code must not be blank.';
    Result := False;
  end
  else if IsABadCode(Code) then
  begin
     Errors := 'The code contains invalid characters or is a reserved word.';
     Result := False;
  end
  else if (Code <> CurrentCode) and (cfRec <> nil) then
  begin
    if cfRec.cfClient_Type = ctProspect then
      Errors := 'A Prospect with this code already exists.'
    else
      Errors := 'A Client with this code alredy exists.';
    Result := False;
  end
  else if Length(Code) > 8 then
  begin
    Errors := 'The code must not be longer than 8 characters';
    Result := False;
  end;
end;

// Generate a new code for a prospective client based on the client name
// (We always must have a client code because BK indexes and searches using client code)
function GenerateProspectCode(const Code, ClientName, CurrentCode: string): string;
var
  i: Integer;
  NewCode, NewName: string;
begin
  NewCode := Trim(Code);
  if NewCode = '' then
  begin
    // Remove any invalid characters to reduce the chance of generating a bad code!
    NewName := UpperCase(ClientName);
    i := 1;
    while i < Length(NewName) do
    begin
      if (NewName[i] = ' ') or (NewName[i] = '.') or
         (NewName[i] = ':') or (NewName[i] = '\') or
         (NewName[i] = '/') or (NewName[i] = '~') or
         (NewName[i] = '*') or (NewName[i] = '"') or
         (NewName[i] = '<') or (NewName[i] = '>') or
         (NewName[i] = '?') then
        Delete(NewName, i, 1)
      else
        Inc(i);
    end;
    // If its now empty use a default
    if NewName = '' then
      Result := 'BK'
    else
      Result := Copy(NewName, 1, 8);
    i := 1;
    while (Result <> CurrentCode) and (AdminSystem.fdSystem_Client_File_List.FindCode(Result) <> nil) do
    begin
      Result := Copy(NewName, 1, 8 - Length(IntToStr(i))) + IntToStr(i);
      Inc(i);
    end;
  end
  else
    Result := Code;
  // Now make sure we never generate a bad code
  i := 1;
  while ((Result <> CurrentCode) and (AdminSystem.fdSystem_Client_File_List.FindCode(Result) <> nil)) or
        (IsABadCode(Result)) do
  begin
    Result := 'BK' + IntToStr(i);
    Inc(i);
  end;
  Result := Result;
end;

//Update an existing Client Record in the Admin System (Used when importing Clients)
procedure UpdateClientRecord(const ClientCode, ClientName, Address1,
  Address2, Address3, Phone, Fax, Mobile, Sal, Email, ContactName: string;
  const UserID: Integer);
const ThisMethodName = 'UpdateClientRecord';
var
  cfrec: pClient_File_Rec;
  Client: TClientObj;
begin
  RefreshAdmin;
  OpenAClient(ClientCode, Client, True);
  cfrec := AdminSystem.fdSystem_Client_File_List.FindCode(ClientCode);
  if Assigned(Client) then
  begin
    Client.clFields.clStaff_Member_LRN := UserID;
    Client.clFields.clAddress_L1 := Copy(Address1, 1, 60);
    Client.clFields.clName := Copy(ClientName, 1, 60);
    Client.clFields.clAddress_L2 := Copy(Address2, 1, 60);
    Client.clFields.clAddress_L3 := Copy(Address3, 1, 60);
    Client.clFields.clContact_Name := Copy(ContactName, 1, 60);
    Client.clFields.clPhone_No := Copy(Phone, 1, 60);
    Client.clFields.clMobile_No := Copy(Mobile, 1, 60);
    Client.clFields.clSalutation := Copy(Sal, 1, 10);
    Client.clFields.clFax_No := Copy(Fax, 1, 60);
    Client.clFields.clClient_Email_Address := Copy(Email, 1,40);
    Client.clFields.clContact_Details_Edit_Date := StDate.CurrentDate;
    Client.clFields.clContact_Details_Edit_Time := StDate.CurrentTime;
    CloseAClient(Client);
  end
  else
  begin
    ClientDetailsCache.Clear;
    ClientDetailsCache.Load(cfrec.cfLRN);

    ClientDetailsCache.Name := Copy(ClientName, 1, 60);
    ClientDetailsCache.Address_L1 := Copy(Address1, 1, 60);
    ClientDetailsCache.Address_L2 := Copy(Address2, 1, 60);
    ClientDetailsCache.Address_L3 := Copy(Address3, 1, 60);
    ClientDetailsCache.Contact_Name := Copy(ContactName, 1, 60);
    ClientDetailsCache.Phone_No := Copy(Phone, 1, 60);
    ClientDetailsCache.Mobile_No := Copy(Mobile, 1, 60);
    ClientDetailsCache.Salutation := Copy(Sal, 1, 10);
    ClientDetailsCache.Fax_No := Copy(Fax, 1, 60);
    ClientDetailsCache.Email_Address := Copy(Email, 1,40);

    ClientDetailsCache.Save(cfrec.cfLRN);
  end;

  if LoadAdminSystem(True, ThisMethodName) then
  begin
    cfrec := AdminSystem.fdSystem_Client_File_List.FindCode(ClientCode);
    cfrec^.cfUser_Responsible := UserID;
    cfrec^.cfFile_Name := ClientDetailsCache.Name;
    cfrec^.cfContact_Details_Edit_Date := StDate.CurrentDate;
    cfrec^.cfContact_Details_Edit_Time := StDate.CurrentTime;
    SaveAdminSystem;
  end
  else
    HelpfulErrorMsg('Unable to update Client at this time.  Admin system unavailable.',0);

  //RefreshLookup( ClientCode);
end;


// Insert a new prospective client record into the admin system
procedure AddNewProspectRec(const ClientCode, ClientName, Address1,
  Address2, Address3, Phone, Fax, Mobile, Sal, Email, ContactName: string;
  const User: Integer);
const
  ThisMethodName = 'AddNewProspectRec';
var
  cfrec: pClient_File_Rec;
begin
  if LoadAdminSystem(True, ThisMethodName) then
  begin
    cfrec := New_Client_File_Rec;
    cfrec^.cfFile_Code := ClientCode;
    cfrec^.cfClient_Type := ctProspect;
    cfrec^.cfUser_Responsible := User;
    Inc(AdminSystem.fdFields.fdClient_File_LRN_Counter);
    cfrec^.cfLRN := AdminSystem.fdFields.fdClient_File_LRN_Counter ;
    AdminSystem.fdSystem_Client_File_List.Insert(cfrec);
    with ClientDetailsCache do
    begin
      // auto-truncate to max lengths
      Code := Copy(ClientCode, 1, 8);
      Name := Copy(ClientName, 1, 60);
      Address_L1 := Copy(Address1, 1, 60);
      Address_L2 := Copy(Address2, 1, 60);
      Address_L3 := Copy(Address3, 1, 60);
      Contact_Name := Copy(ContactName, 1, 60);
      Phone_No := Copy(Phone, 1, 60);
      Mobile_No := Copy(Mobile, 1, 60);
      Salutation := Copy(Sal, 1, 10);
      Fax_No := Copy(Fax, 1, 60);
      Email_Address := Copy(Email, 1,40);
      Save(cfrec^.cfLRN);
    end;
    cfrec^.cfFile_Name := ClientDetailsCache.Name;
    SaveAdminSystem;
  end
  else
     HelpfulErrorMsg('Unable to add Prospect at this time.  Admin system unavailable.',0);
end;

function CheckCodeExists(Code: string; Silent: Boolean = False): Boolean;
const
  ThisMethodName = 'CheckCodeExists';
var
  Msg: string;
begin
  Result := True;
  RefreshAdmin;
  if (AdminSystem.fdSystem_Client_File_List.FindCode(Code) = nil) then
  begin
    Msg := Format('Code "%s" could not be found in the Admin System.', [Code]);
    if not Silent then
      HelpfulErrorMsg(Msg, 0);
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
    Result := False;
  end;
end;

// Given a client code and bank account number, find the last Sched Rep printed date in the client-account map
function GetLastPrintedDate(Code: string; BLRN: Integer): Integer;
var
  pM: pClient_Account_Map_Rec;
  pF: pClient_File_Rec;
begin
  Result := 0;
  pF := AdminSystem.fdSystem_Client_File_List.FindCode(Code);
  if Assigned(pF) then
  begin
    pM := AdminSystem.fdSystem_Client_Account_Map.FindLRN(BLRN, pF.cfLRN);
    if Assigned(pM) then
      Result := pM.amLast_Date_Printed;
  end;
end;

procedure SetLastPrintedDate(Code: string; BLRN: Integer);
var
  pM: pClient_Account_Map_Rec;
  pF: pClient_File_Rec;
begin
  pF := AdminSystem.fdSystem_Client_File_List.FindCode(Code);
  if Assigned(pF) then
  begin
    pM := AdminSystem.fdSystem_Client_Account_Map.FindLRN(BLRN, pF.cfLRN);
    if Assigned(pM) and (pM.amTemp_Last_Date_Printed <> 0) and (pM.amTemp_Last_Date_Printed > pM.amLast_Date_Printed) then
    begin
      pM.amLast_Date_Printed := pM.amTemp_Last_Date_Printed;
      pM.amTemp_Last_Date_Printed := 0;
    end;
  end;
end;

procedure SetTempPrintedDate(Code: string; BLRN, TempDate: Integer);
var
  pM: pClient_Account_Map_Rec;
  pF: pClient_File_Rec;
begin
  pF := AdminSystem.fdSystem_Client_File_List.FindCode(Code);
  if Assigned(pF) then
  begin
    pM := AdminSystem.fdSystem_Client_Account_Map.FindLRN(BLRN, pF.cfLRN);
    if Assigned(pM) and (TempDate > pM.amLast_Date_Printed) then
      pM.amTemp_Last_Date_Printed := TempDate;
  end;
end;

function OkToPurgeUPI( pT : pTransaction_Rec; TestDate : integer) : boolean;
var
  IsUPC, IsUPD, IsUPW: boolean;
begin
  //Note: The following matches the selection criteria for UPI's in the
  //Bank Rec Report (except for UPC's with amount = 0). These items should
  //not be purged because they may alter the report totals.

  //Unpresented cheques that shouldn't be pruged
  IsUPC := (pT^.txUPI_State in [upUPC, upMatchedUPC, upBalanceOfUPC,
                                upReversedUPC, upReversalOfUPC]) and
           (pT^.txDate_Effective < TestDate) and
           ((pT^.txDate_Presented = 0) or
            (pT^.txDate_Presented >= TestDate));
  //Unpresented deposits that shouldn't be pruged
  IsUPD := (pT^.txUPI_State in [upUPD, upMatchedUPD, upBalanceOfUPD,
                                upReversedUPD,upReversalOfUPD]) and
           (pT^.txDate_Effective < TestDate) and
           ((pT^.txDate_Presented = 0) or
            (pT^.txDate_Presented >= TestDate));
  //Unpresented withdraws that shouldn't be pruged
  IsUPW := (pT^.txUPI_State in [upUPW, upMatchedUPW, upBalanceOfUPW,
                                upReversedUPW, upReversalOfUPW]) and
           (pT^.txDate_Effective < TestDate) and
           ((pT^.txDate_Presented = 0) or
            (pT^.txDate_Presented >= TestDate));

  Result := not (IsUPC or IsUPD or IsUPW);
end;

function CountEntriesToPurge( TestDate : tStDate; TrnsfOnly : boolean; const BankAccountList: TStringList) : integer;
Var
   Count  : integer;
   p      : pTransaction_Rec;
   i,j    : Integer;
begin
   Count := 0;
   with myClient.clBank_Account_List do for i := 0 to Pred(ItemCount) do
      with Bank_Account_At(i), baTransaction_List do
      begin
         if (BankAccountList = nil) or
            (BankAccountList.IndexOf(baFields.baBank_Account_Number) > -1) then
         begin
           for j := 0 to Pred(baTransaction_List.ItemCount) do begin
            p := Transaction_At(j);
            if OkToPurgeTransaction(p, TestDate, TrnsfOnly) then
               Inc(Count)
            else
               //See if effective date is greater than test date. If so there
               //will be no more entries as entries are sorted in eff date order
               if p^.txDate_Effective >= TestDate then
                  Break;

               ;//Break;  //leave transaction loop
            end;
         end ;
      end;
   Result := Count;
End;

function CountUPIs(TestDate: Integer; TrnsfOnly: boolean; const
  BankAccountList: TStringList): integer;
var
  p: pTransaction_Rec;
  i,j: Integer;
  ClientBankAccount: TBank_Account;
  BankAccountNo: string;
begin
  Result := 0;
  for i := 0 to Pred(myClient.clBank_Account_List.ItemCount) do begin
    ClientBankAccount := myClient.clBank_Account_List.Bank_Account_At(i);
    BankAccountNo := ClientBankAccount.baFields.baBank_Account_Number;
    if (BankAccountList = nil) or
       (BankAccountList.IndexOf(BankAccountNo) > -1) then begin
      for j := 0 to Pred(ClientBankAccount.baTransaction_List.ItemCount) do begin
        p := ClientBankAccount.baTransaction_List.Transaction_At(j);
        if p^.txDate_Effective >= TestDate then
          Break;
        if not OkToPurgeUPI(p, testDate) then
          Inc(Result);
      end;
    end;
  end;
end;

function OkToPurgeTransaction( pT : pTransaction_Rec; TestDate : integer; PurgeTrnsfOnly : boolean) : boolean;
begin
  Result := (pT^.txDate_Effective < TestDate) and
            ((not PurgeTrnsfOnly) or
             (PurgeTrnsfOnly and (pT^.txDate_Transferred <> 0)));
  Result := Result and (OkToPurgeUPI(pT, TestDate));
end;

procedure PurgeEntriesFromMyClient(const PurgeDate: integer;
  const DelTransferredOnly: boolean; var TotalDeleted,
  TotalUnpresented: integer; const BankAccountList: TStringList);
var
   i                  : integer;
   b                  : integer;
   BankAccount        : TBank_Account;
   NewTransactionList : TTransaction_List;
   pT                 : pTransaction_Rec;
   NoDeleted          : integer;
   sMsg               : string;
begin
  TotalDeleted := 0;
  //Get the total for unpresented items that will not be purged
  TotalUnpresented := CountUPIs(PurgeDate, DelTransferredOnly, BankAccountList);
  //cycle thru each bank account (including journals)
  with MyClient do
  begin
    for b := 0 to Pred( clBank_Account_List.ItemCount) do
    Begin
      BankAccount := clBank_Account_List.Bank_Account_At( b );
      with BankAccount do
      begin
        //Create a new transaction list
        if (BankAccountList = nil) or
           (BankAccountList.IndexOf(baFields.baBank_Account_Number) > -1) then
        begin
          NewTransactionList := TTransaction_List.Create( MyClient, BankAccount );
          NoDeleted := 0;
              //look thru each transaction
          for i := 0 to Pred( baTransaction_List.ItemCount) do
          begin
            pT := baTransaction_List.Transaction_At(i);
            //delete transaction and set the pointer to nil if before purge date
            //also check to see if has been transfered
            if OkToPurgeTransaction( pT, PurgeDate, DelTransferredOnly) then begin
               Dispose_Transaction_Rec( pT );
               pT := nil;
               Inc( NoDeleted );
               Inc( TotalDeleted );
            end
            else
            begin
              //transaction should be kept so add to New Transaction List
              NewTransactionList.Insert_Transaction_Rec( pT );
            end;
          end;
          //Check to see if anything changed
          if NoDeleted > 0 then
          begin
            //clear the existing trans list and point to the new list
            baTransaction_List.DeleteAll;
            baTransaction_List.Free;
            baTransaction_List := NewTransactionList;
            sMsg := '%d Entries with a presentation date prior to %s were purged from account %s';
            LogUtil.LogMsg(lmInfo, UnitName, Format( sMsg,
                                                     [ NoDeleted,
                                                       BkDate2Str( PurgeDate),
                                                       baFields.baBank_Account_Number]));
          end
          else
          begin
            //Nothing deleted so don't need to use new list, empty pointers and free
            NewTransactionList.DeleteAll;
            NewTransactionList.Free;
          end;
        end; // if
      end; //with BankAccount
    end; /// b
  end; //with myClient
end;

end.
