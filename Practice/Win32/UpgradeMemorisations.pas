unit UpgradeMemorisations;

interface

uses
  clObj32,
  SysObj32;

procedure UpgradeClient_Memorisation_EntryType(const aClient: TClientObj);

procedure UpgradeAdmin_Memorisation_EntryType(const aAdmin: TSystemObj);


implementation

uses
  SysUtils,
  StrUtils,
  bkConst,
  bkDefs,
  BKMLIO,
  baObj32,
  baList32,
  MemorisationsObj,
  MemUtils,
  baUtils,
  Globals,
  SystemMemorisationList,
  syDefs,
  ECollect;

const
  NATIONAL_06 = '06';

{------------------------------------------------------------------------------}
procedure CopyMemorisations(const aMems: TMemorisations_List);
const
  ENTRY_TYPE_0 = 0;
  ENTRY_TYPE_49 = 49;
var
  Existing49s: TExtdCollection;
  New49s: TExtdCollection;
  iMem: integer;
  Mem: TMemorisation;
  MemCopy: TMemorisation;
begin
  { Note: The higher the sequence, the higher the priority (done first).
    Normally when a new memorisation is added it will get a higher priority. It
    can then be changed during the MaintainMemFrm (up and down within an entry
    type). Since the existing 49s should have a higher priority, we have to
    delete them first, and then move them in last again.
  }

  Existing49s := TExtdCollection.Create;
  New49s := TExtdCollection.Create;
  try
    // Find 0:cheque, and create 49:withdrawal copies
    for iMem := 0 to aMems.ItemCount-1 do
    begin
      Mem := aMems.Memorisation_At(iMem);

      // Collect entry type 49:withdrawal for later
      if (Mem.mdFields.mdType = ENTRY_TYPE_49) then
        Existing49s.Insert(Mem);

      // Entry type must be 0:cheque before we can copy it
      if (Mem.mdFields.mdType <> ENTRY_TYPE_0) then
        continue;

      // Must have "match on" criteria
      if not HasMatchOnCriteria(Mem) then
        continue;

      // Create new memorisation, and copy contents
      MemCopy := TMemorisation.Create(Mem.AuditMgr);
      CopyMemorisation(Mem, MemCopy);

      // Change over the entry type
      MemCopy.mdFields.mdType := ENTRY_TYPE_49;

      // Copy should have no duplicate
      if HasDuplicateMem(MemCopy, aMems) then
      begin
        FreeAndNil(MemCopy);
        continue;
      end;

      // Store for proper insertion later
      New49s.Insert(MemCopy);
    end;

    // Nothing to do?
    if (New49s.ItemCount = 0) then
      exit;

    // Delete existing 49:withdrawal from list
    for iMem := aMems.Last downto 0 do
    begin
      Mem := aMems.Memorisation_At(iMem);

      // Must be 49:withdrawal
      if (Mem.mdFields.mdType <> ENTRY_TYPE_49) then
        continue;

      aMems.AtDelete(iMem);
    end;

    // Insert new 49:withdrawal (copies of 0:cheque) into the list
    for iMem := 0 to New49s.Last do
    begin
      Mem := TMemorisation(New49s[iMem]);

      aMems.Insert_Memorisation(Mem);
    end;

    { Insert existing 49:withdrawal back into the list.
      Note: They should now have the highest sequence number (= highest
      priority). }
    for iMem := 0 to Existing49s.Last do
    begin
      Mem := TMemorisation(Existing49s[iMem]);

      aMems.Insert_Memorisation(Mem);
    end;
  finally
    Existing49s.DeleteAll;
    FreeAndNil(Existing49s);
    New49s.DeleteAll;
    FreeAndNil(New49s);
  end;
end;

{------------------------------------------------------------------------------}
procedure UpgradeClient_Memorisation_EntryType(const aClient: TClientObj);
var
  BankAccounts: TBank_Account_List;
  iBank: integer;
  BankAccount: TBank_Account;
  Mems: TMemorisations_List;
begin
  // New Zealand only
  if (aClient.clFields.clCountry <> whNewZealand) then
    exit;

  BankAccounts := aClient.clBank_Account_List;

  for iBank := 0 to BankAccounts.ItemCount-1 do
  begin
    BankAccount := BankAccounts.Bank_Account_At(iBank);

    // National (06) only
    if not IsSameInstitution(BankAccount, NATIONAL_06) then
      continue;

    Mems := BankAccount.baMemorisations_List;

    CopyMemorisations(Mems);
  end;
end;


{------------------------------------------------------------------------------}
procedure UpgradeAdmin_Memorisation_EntryType(const aAdmin: TSystemObj);
var
  SysMems: TSystem_Memorisation_List;
  iBank: integer;
  SysMem: pSystem_Memorisation_List_Rec;
  Mems: TMemorisations_List;
begin
  // New Zealand only
  if (aAdmin.fdFields.fdCountry <> whNewZealand) then
    exit;

  SysMems := aAdmin.fSystem_Memorisation_List;

  for iBank := SysMems.First to SysMems.Last do
  begin
    SysMem := SysMems.System_Memorisation_At(iBank);

    // National (06) only
    if not IsSameInstitution(SysMem.smBank_Prefix, NATIONAL_06) then
      continue;

    Mems := TMemorisations_List(SysMem.smMemorisations);

    CopyMemorisations(Mems);  
  end;
end;


end.