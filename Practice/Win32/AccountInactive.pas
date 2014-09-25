unit AccountInactive;

interface

uses
  BKDEFS,
  SYDEFS,
  MemorisationsObj,
  PayeeObj,
  baObj32,
  Globals;

  // Helpers
  function  Memorisations_AccountUsed(const aList: TMemorisations_List;
              const aAccount: string): boolean; overload;

  function  ClientMemorisations_AccountUsed(const aAccount: string): boolean;

  function  SystemMemorisations_AccountUsed(const aAccount: string): boolean;

  function  Memorisations_AccountUsed(const aAccount: string): boolean; overload;

  function  Payees_AccountUsed(const aAccount: string): boolean;

  // GUI helpers
  procedure DisplayMemorisationPayee_AccountUsed(const aAccount: string);


implementation

uses
  WarningMoreFrm;

//------------------------------------------------------------------------------
function Memorisations_AccountUsed(const aList: TMemorisations_List;
  const aAccount: string): boolean;
var
  iMem: integer;
  Memorisation: TMemorisation;
  iLine: integer;
  MemorisationLine: pMemorisation_Line_Rec;
begin
  for iMem := 0 to aList.Last do
  begin
    Memorisation := aList.Memorisation_At(iMem);
    for iLine := 0 to Memorisation.mdLines.Last do
    begin
      MemorisationLine := Memorisation.mdLines.MemorisationLine_At(iLine);
      if (MemorisationLine.mlAccount = aAccount) then
      begin
        result := true;
        exit;
      end;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
function ClientMemorisations_AccountUsed(const aAccount: string): boolean;
var
  bInMem: boolean;
  i: integer;
  BankAccount: TBank_Account;
  bInPayee: boolean;
begin
  for i := 0 to MyClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := MyClient.clBank_Account_List.Bank_Account_At(i);
    if Memorisations_AccountUsed(BankAccount.baMemorisations_List, aAccount) then
    begin
      result := true;
      exit;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
function SystemMemorisations_AccountUsed(const aAccount: string): boolean;
var
  i: integer;
  Memorisation: pSystem_Memorisation_List_Rec;
  Memorisations: TMemorisations_List;
begin
  if not assigned(AdminSystem) then
  begin
    result := false;
    exit;
  end;

  for i := 0 to AdminSystem.fSystem_Memorisation_List.ItemCount-1 do
  begin
    Memorisation := AdminSystem.fSystem_Memorisation_List.System_Memorisation_At(i);
    Memorisations := TMemorisations_List(Memorisation.smMemorisations);
    if not assigned(Memorisations) then
      continue;
    if Memorisations_AccountUsed(Memorisations, aAccount) then
    begin
      result := true;
      exit;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
function Memorisations_AccountUsed(const aAccount: string): boolean;
begin
  result :=
    ClientMemorisations_AccountUsed(aAccount) or
    SystemMemorisations_AccountUsed(aAccount);
end;

//------------------------------------------------------------------------------
function Payees_AccountUsed(const aAccount: string): boolean;
var
  iPayee: integer;
  Payee: TPayee;
  iLine: integer;
  Line: pPayee_Line_Rec;
begin
  for iPayee := 0 to MyClient.clPayee_List.Last do
  begin
    Payee := MyClient.clPayee_List.Payee_At(iPayee);
    for iLine := 0 to Payee.pdLines.Last do
    begin
      Line := Payee.pdLines.PayeeLine_At(iLine);
      if (Line.plAccount = aAccount) then
      begin
        result := true;
        exit;
      end;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
procedure DisplayMemorisationPayee_AccountUsed(const aAccount: string);
var
  bInMemorisations: boolean;
  bInPayees: boolean;
  sMsg: string;
begin
  bInMemorisations := Memorisations_AccountUsed(aAccount);
  bInPayees := Payees_AccountUsed(aAccount);

  if (bInMemorisations and bInPayees) then
  begin
    sMsg :=
      'Account Code '+aAccount+' is currently used in memorisation(s) and payee(s).'+sLineBreak+
      'You can update Memorisations from Other Functions | Memorised Entries, and Payees from Other Functions | Payees.';
    HelpfulWarningMsg(sMsg, 0);
  end
  else if bInMemorisations then
  begin
    sMsg :=
      'Account Code '+aAccount+' is currently used in memorisation(s).'+sLineBreak+
      'You can update these from Other Functions | Memorised Entries.';
    HelpfulWarningMsg(sMsg, 0);
  end
  else if bInPayees then
  begin
    sMsg :=
    'Account Code '+aAccount+' is currently used in payee(s).'+sLineBreak+
    'You can update these from Other Functions | Payees.';
    HelpfulWarningMsg(sMsg, 0);
  end;
end;

end.
