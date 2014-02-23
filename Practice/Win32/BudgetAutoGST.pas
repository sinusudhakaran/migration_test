unit BudgetAutoGST;

interface

uses
  glConst,
  bkDefs,
  MoneyDef,
  StDate,
  clObj32,
  budObj32,
  BudgetImportExport;

type
  rTGstClassMoney = record
    Amount: double;
  end;

  aTGstClassMoney = array[0..MAX_GST_CLASS] of rTGstClassMoney;

  // Note: aMonth is 1 based

  // Amount from row
  procedure CalculateGST(const aClient: TClientObj; var aBudget: TBudgetRec;
              const aMonthIndex: integer; const aDate: TStDate;
              var aGST: aTGstClassMoney); overload;

  // Amount from row, stored as a single figure
  procedure CalculateGST(const aClient: TClientObj; var aBudget: TBudgetRec;
              const aMonthIndex: integer; const aDate: TStDate;
              var GSTAmount: double); overload;

  // Amount from month
  procedure CalculateGST(const aClient: TClientObj; var aBudget: TBudgetData;
              const aMonthIndex: integer; const aDate: TStDate;
              var aGST: aTGstClassMoney); overload;

  function  IsGSTAccountCode(const aClient: TClientObj; const aAccount: string
              ): boolean;

  // Move the GST back to the rows with the same control code (gst account code)
  procedure MoveGST(const aClient: TClientObj; var aBudget: TBudgetData;
              const aMonthIndex: integer; const aGST: aTGstClassMoney);

  // Move the GST to the GSTAmount rows with the same control code (gst account code)
  procedure MoveGSTtoGstAmount(const aClient: TClientObj; var aBudget: TBudgetData;
              const aMonthIndex: integer; const aGST: aTGstClassMoney);

  // Calculate all months
  procedure CalculateGST(const aClient: TClientObj; var aBudget: TBudget;
              var aBudgetData: TBudgetData); overload;

  // Calculate all months
  procedure ClearGstAmounts(var aBudgetData : TBudgetData);

  // Calculate all months and places values in GSTAmounts var used so the amounts are not persisted
  procedure CalculateGSTtoGSTAmount(const aClient: TClientObj; var aBudget: TBudget;
              var aBudgetData: TBudgetData; aAutoCalculateGST : boolean);

  { Validate the GST Setup, e.g. every used GST class must have a valid control
    code. }
  procedure ValidateGSTSetup(const aClient: TClientObj);

  function RoundToWholeValue(UnroundedAmount: Extended): double;

  function DoRoundUp(Value: double): integer;

  function DoRoundDown(Value: double): integer;

implementation

uses
  bkConst,
  GSTCalc32,
  SignUtils,
  Dialogs,
  Math,
  WarningMoreFrm;

//------------------------------------------------------------------------------
procedure CalculateGST(const aClient: TClientObj; var aBudget: TBudgetRec;
  const aMonthIndex: integer; const aDate: TStDate;
  var aGST: aTGstClassMoney); overload;
var
  pAccount: pAccount_Rec;
  byGST_Class: byte;
  moAmount: Money;
  moGSTAmount: double;
  pnSign: TSign;
begin
  // Code doesn't exist? (valid situation)
  pAccount := aClient.clChart.FindCode(aBudget.bAccount);
  if not assigned(pAccount) then
    exit;

  // Calculate GST component
  byGST_Class := pAccount.chGST_Class;
  moAmount := aBudget.bAmounts[aMonthIndex];
  moGSTAmount := CalculateGSTFromNett(aClient, aDate, moAmount, byGST_Class);
  if not IsGSTAccountCode(aClient, aBudget.bAccount) then
    aBudget.bGstAmounts[aMonthIndex] := DoRoundUp(moGSTAmount + moAmount);

  // Ensure GST amount sign is correct
  pnSign := ExpectedSign(pAccount.chAccount_Type);
  case pnSign of
    Debit:
      moGSTAmount := Abs(moGSTAmount);

    Credit:
      moGSTAmount := -moGSTAmount;

    NNone:
      // Do nothing
  end;

  // Add to total (positive or negative)
  aGST[byGST_Class].Amount := aGST[byGST_Class].Amount + moGSTAmount;
end;

//------------------------------------------------------------------------------
procedure CalculateGST(const aClient: TClientObj; var aBudget: TBudgetRec;
  const aMonthIndex: integer; const aDate: TStDate;
  var GSTAmount: double); overload;
var
  pAccount: pAccount_Rec;
  byGST_Class: byte;
  moAmount: Money;
  moGSTAmount: double;
  pnSign: TSign;
begin
  // Code doesn't exist? (valid situation)
  pAccount := aClient.clChart.FindCode(aBudget.bAccount);
  if not assigned(pAccount) then
    exit;

  // Calculate GST component
  byGST_Class := pAccount.chGST_Class;
  moAmount := aBudget.bAmounts[aMonthIndex];
  moGSTAmount := CalculateGSTFromNett(aClient, aDate, moAmount, byGST_Class);
  if not IsGSTAccountCode(aClient, aBudget.bAccount) then
    aBudget.bGstAmounts[aMonthIndex] := DoRoundUp(moGSTAmount + moAmount);

  // Add to total (positive or negative)
  GSTAmount := GSTAmount + moGSTAmount;
end;

//------------------------------------------------------------------------------
procedure CalculateGST(const aClient: TClientObj; var aBudget: TBudgetData;
  const aMonthIndex: integer; const aDate: TStDate;
  var aGST: aTGstClassMoney); overload;
var
  i: integer;
  iRow: integer;
begin
  ASSERT((1 <= aMonthIndex) and (aMonthIndex <= 12));

  // Reset
  for i := 0 to High(aGST) do
  begin
    aGST[i].Amount := 0;
  end;

  // Look at all rows (including the controlling codes)
  for iRow := 0 to High(aBudget) do
  begin
    CalculateGST(aClient, aBudget[iRow], aMonthIndex, aDate, aGST);
  end;
end;

//------------------------------------------------------------------------------
function IsGSTAccountCode(const aClient: TClientObj; const aAccount: string
  ): boolean;
var
  i: integer;
  sCode: string;
begin
  // Empty GST account code?
  if (aAccount = '') then
  begin
    result := false;
    exit;
  end;

  for i := 0 to High(aClient.clFields.clGST_Account_Codes) do
  begin
    // GST account code?
    sCode := aClient.clFields.clGST_Account_Codes[i];
    if (sCode = aAccount) then
    begin
      result := true;
      exit;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
procedure MoveGST(const aClient: TClientObj; var aBudget: TBudgetData;
  const aMonthIndex: integer; const aGST: aTGstClassMoney);
var
  iRow: integer;
  iClass: integer;
  sAccount: string;
begin
  { Note: multiple GST codes, can still post to one (!) account code, so we
    must clear first, and then add later on }
  for iRow := 0 to High(aBudget) do
  begin
    with aBudget[iRow] do
    begin
      if not IsGSTAccountCode(aClient, bAccount) then
        continue;

      // Reset to zero
      bAmounts[aMonthIndex] := 0;
    end;
  end;

  for iClass := 0 to MAX_GST_CLASS do
  begin
    // Not a valid code?
    sAccount := aClient.clFields.clGST_Account_Codes[iClass];
    if (sAccount = '') then
      continue;

    for iRow := 0 to High(aBudget) do
    begin
      with aBudget[iRow] do
      begin
        if (bAccount <> sAccount) then
          continue;

        // Note: this must be added (see note above)
        bAmounts[aMonthIndex] := bAmounts[aMonthIndex] +
          Round(aGST[iClass].Amount);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure MoveGSTtoGstAmount(const aClient: TClientObj; var aBudget: TBudgetData;
  const aMonthIndex: integer; const aGST: aTGstClassMoney);
var
  iRow: integer;
  iClass: integer;
  sAccount: string;
begin
  for iClass := 0 to MAX_GST_CLASS do
  begin
    sAccount := aClient.clFields.clGST_Account_Codes[iClass];
    if (sAccount = '') then
      continue;

    for iRow := 0 to High(aBudget) do
    begin
      if (aBudget[iRow].bAccount <> sAccount) then
        continue;

      // Note: this must be added
      aBudget[iRow].ShowGstAmounts := true;
      aBudget[iRow].bGstAmounts[aMonthIndex] := aBudget[iRow].bGstAmounts[aMonthIndex] +
        Round(aGST[iClass].Amount);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure CalculateGST(const aClient: TClientObj; var aBudget: TBudget;
  var aBudgetData: TBudgetData);
var
  dtMonth: TStDate;
  iMonth: integer;
  arrGST: aTGstClassMoney;
begin
  dtMonth := aBudget.buFields.buStart_Date;

  for iMonth := 1 to 12 do
  begin
    // Calculate the GST amounts for all rows, and add them to GST total table
    CalculateGST(aClient, aBudgetData, iMonth, dtMonth, arrGST);

    // Move all GST amounts to the budget GSTAmount
    MoveGST(aClient, aBudgetData, iMonth, arrGST);

    // Next month
    dtMonth := IncDate(dtMonth, 0, 1, 0);
  end;
end;

//------------------------------------------------------------------------------
procedure ClearGstAmounts(var aBudgetData : TBudgetData);
var
  iMonth : integer;
  iRow : integer;
begin
  for iRow := 0 to High(aBudgetData) do
  begin
    if aBudgetData[iRow].bIsGSTAccountCode then
    begin
      aBudgetData[iRow].ShowGstAmounts := false;
      for iMonth := 1 to 12 do
      begin
        aBudgetData[iRow].bGstAmounts[iMonth] := 0;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure CalculateGSTtoGSTAmount(const aClient: TClientObj; var aBudget: TBudget;
  var aBudgetData: TBudgetData; aAutoCalculateGST : boolean);
var
  dtMonth: TStDate;
  iMonth: integer;
  arrGST: aTGstClassMoney;
begin
  // Clears All Gst Amounts
  ClearGstAmounts(aBudgetData);

  dtMonth := aBudget.buFields.buStart_Date;

  for iMonth := 1 to 12 do
  begin
    // Calculate the GST amounts for all rows, and add them to GST total table
    CalculateGST(aClient, aBudgetData, iMonth, dtMonth, arrGST);

    if aAutoCalculateGST then
      // Move all GST amounts to the budget GSTAmount
      MoveGSTtoGstAmount(aClient, aBudgetData, iMonth, arrGST);

    // Next month
    dtMonth := IncDate(dtMonth, 0, 1, 0);
  end;
end;

//------------------------------------------------------------------------------
procedure ValidateGSTSetup(const aClient: TClientObj);
var
  i: integer;
  sCode: string;
  pAccount: pAccount_Rec;
  NoControlAccountIDs: string;
  IncorrectGroupIDs: string;
  WarningMsg: string;
  ExtraHeight: integer;
begin
  for i := 0 to MAX_GST_CLASS do
  begin
    sCode := aClient.clFields.clGST_Account_Codes[i];
    if (sCode = '') and (aClient.clFields.clGST_Class_Names[i] = '') then
      continue;

    pAccount := aClient.clChart.FindCode(sCode);
    if assigned(pAccount) then
    begin
      // Check the control account has the correct group (GST Payable, or GST receivable)
      if not (pAccount.chAccount_Type in [atGSTPayable, atGSTReceivable]) then
      begin
        if (IncorrectGroupIDs <> '') then
          IncorrectGroupIDs := IncorrectGroupIDs + ', ';

        IncorrectGroupIDs := IncorrectGroupIDs + aClient.clFields.clGST_Class_Codes[i];
      end;
    end
    else
    begin
      // GST ID does not have a control account
      if (NoControlAccountIDs <> '') then
        NoControlAccountIDs := NoControlAccountIDs + ', ';

      NoControlAccountIDs := NoControlAccountIDs + aClient.clFields.clGST_Class_Codes[i];
    end;
  end;

  if (NoControlAccountIDs = '') and (IncorrectGroupIDs = '') then
    exit;

  WarningMsg := '';
  if (NoControlAccountIDs <> '') then
    WarningMsg := WarningMsg +
                  'The Control Accounts for the following GST IDs are missing:' + sLineBreak +
                  sLineBreak +
                  NoControlAccountIDs + sLineBreak +
                  sLineBreak+
                  'You can configure these via Other Functions | GST Set Up.';

  if (NoControlAccountIDs <> '') and (IncorrectGroupIDs <> '') then
  begin
    WarningMsg := WarningMsg +
                  sLineBreak +
                  sLineBreak +
                  '------------------------------------------------------------------------------' +
                  sLineBreak;
    ExtraHeight := 20;
  end else
    ExtraHeight := -20;

  if (IncorrectGroupIDs <> '') then
    WarningMsg := WarningMsg +
                  'The Control Accounts for the following GST IDs have invalid groups:' + sLineBreak +
                  sLineBreak +
                  IncorrectGroupIDs + sLineBreak +
                  sLineBreak+
                  'The group for these accounts should be set to either GST Payable ' + sLineBreak +
                  'or GST Receivable.';

  HelpfulWarningMsg(WarningMsg, 0, '&OK', 500, ExtraHeight);
end;

function RoundToWholeValue(UnroundedAmount: Extended): double;
var
  OldRoundMode : TFPURoundingMode;
  Remainder    : Extended;
  RoundUpHalves: boolean;
begin
  Remainder := UnroundedAmount - Trunc(UnroundedAmount);
  RoundUpHalves := abs(Remainder - 0.5) < 0.0000001;
  OldRoundMode := GetRoundMode; // would put this in the if statement below but then I get a compiler warning
  if RoundUpHalves then
    SetRoundMode(rmUp);
  Result := Round( UnroundedAmount );
  if RoundUpHalves then
    SetRoundMode(OldRoundMode);
end;

function DoRoundUp(Value: double): integer;
var
  RoundUpHalves: boolean;
  Remainder: extended;
  OldRoundMode: TFPURoundingMode;
begin
  Remainder := Value - Trunc(Value);
  RoundUpHalves := abs(Remainder - 0.5) < 0.0000001;
  OldRoundMode := GetRoundMode; // would put this in the if statement below but then I get a compiler warning
  if RoundUpHalves then
    SetRoundMode(rmUp);
  Result := Round(Value);
  if RoundUpHalves then
    SetRoundMode(OldRoundMode);
end;

function DoRoundDown(Value: double): integer;
var
  RoundDownHalves: boolean;
  Remainder: extended;
  OldRoundMode: TFPURoundingMode;
begin
  Remainder := Value - Trunc(Value);
  RoundDownHalves := abs(Remainder - 0.5) < 0.0000001;
  OldRoundMode := GetRoundMode; // would put this in the if statement below but then I get a compiler warning
  if RoundDownHalves then
    SetRoundMode(rmDown);
  Result := Round(Value);
  if RoundDownHalves then
    SetRoundMode(OldRoundMode);
end;

end.
