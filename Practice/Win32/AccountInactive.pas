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
  procedure DisplayMemorisationPayee_AccountUsed(const aAccount: string
              ); overload;

  procedure DisplayMemorisationPayee_AccountUsed(const aAccounts: array of string
              ); overload;


implementation

uses
  SysUtils,
  Classes,
  Dialogs,
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
  i: integer;
  BankAccount: TBank_Account;
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
    if not Payee.pdFields.pdInactive then
    begin
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
  end;

  result := false;
end;

//------------------------------------------------------------------------------
procedure DisplayMemorisationPayee_AccountUsed(const aAccount: string);
var
  Accounts: array of string;
begin
  SetLength(Accounts, 1);
  Accounts[0] := aAccount;
  DisplayMemorisationPayee_AccountUsed(Accounts);
end;

procedure DisplayMemorisationPayee_AccountUsed(const aAccounts: array of string
  ); overload;
var
  MemorisationAccounts: TStringList;
  PayeeAccounts: TStringList;
  i: integer;
  sAccount: string;
  iPos: integer;
  sAccounts: string;
  sMsg: string;
  sAccountCodes: string;
begin
  try
    MemorisationAccounts := TStringList.Create;
    PayeeAccounts := TStringList.Create;

    // Split them up, and see if they need a warning message
    for i := 0 to High(aAccounts) do
    begin
      sAccount := aAccounts[i];

      if Memorisations_AccountUsed(sAccount) then
        MemorisationAccounts.Add(sAccount);

      if Payees_AccountUsed(sAccount) then
        PayeeAccounts.Add(sAccount);
    end;

    // Memorisations
    for i := 0 to MemorisationAccounts.Count-1 do
    begin
      sAccount := MemorisationAccounts[i];
      iPos := Pos(sAccount, sAccounts);
      if (iPos <> 0) then
        continue;
      if (sAccounts <> '') then
        sAccounts := sAccounts + ', ';
      sAccounts := sAccounts + sAccount;
    end;

    // Payees
    for i := 0 to PayeeAccounts.Count-1 do
    begin
      sAccount := PayeeAccounts[i];
      iPos := Pos(sAccount, sAccounts);
      if (iPos <> 0) then
        continue;
      if (sAccounts <> '') then
        sAccounts := sAccounts + ', ';
      sAccounts := sAccounts + sAccount;
    end;

    // Determine prefix
    iPos := Pos(',', sAccounts);
    if (iPos = 0) then
      sAccountCodes := 'Account Code ' + sAccounts + ' is '
    else
      sAccountCodes := 'Account Codes ' + sAccounts + ' are ';

    // Determine how to display the messages
    if (MemorisationAccounts.Count > 1) and (PayeeAccounts.Count > 1) or
       (MemorisationAccounts.Count > 1) and (PayeeAccounts.Count > 0) or
       (MemorisationAccounts.Count > 0) and (PayeeAccounts.Count > 1) then
    begin
      sMsg :=
        sAccountCodes+'currently used in memorisation(s) and payee(s).'+sLineBreak+sLineBreak+
        'You can update Memorisations from Other Functions | Memorised Entries, and Payees from Other Functions | Payees.';
    end
    else if (MemorisationAccounts.Count > 1) and (PayeeAccounts.Count = 0) then
    begin
      sMsg :=
        sAccountCodes+'currently used in memorisation(s).'+sLineBreak+sLineBreak+
        'You can update these from Other Functions | Memorised Entries.';
    end
    else if (MemorisationAccounts.Count = 0) and (PayeeAccounts.Count > 1) then
    begin
      sMsg :=
        sAccountCodes+'currently used in payee(s).'+sLineBreak+sLineBreak+
        'You can update these from Other Functions | Payees.';
    end
    else if (MemorisationAccounts.Count = 1) and (PayeeAccounts.Count = 1) then
    begin
      sMsg :=
        sAccountCodes+'currently used in memorisation(s) and payee(s).'+sLineBreak+sLineBreak+
        'You can update Memorisations from Other Functions | Memorised Entries, and Payees from Other Functions | Payees.';
    end
    else if (MemorisationAccounts.Count = 1) then
    begin
      sMsg :=
        sAccountCodes+'currently used in memorisation(s).'+sLineBreak+sLineBreak+
        'You can update these from Other Functions | Memorised Entries.';
    end
    else if (PayeeAccounts.Count = 1) then
    begin
      sMsg :=
        sAccountCodes+'currently used in payee(s).'+sLineBreak+sLineBreak+
        'You can update these from Other Functions | Payees.';
    end;

    // Display
    if (sMsg <> '') then
      HelpfulWarningMsg(sMsg, 0);

  finally
    FreeAndNil(MemorisationAccounts);
    FreeAndNil(PayeeAccounts);
  end;
end;

end.
