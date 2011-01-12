unit AccountInfoObj;
//------------------------------------------------------------------------------
{
   Title:       Account Information Object

   Description: This object provides information about a chart code.  It is
                designed to be used for financial reporting

   Author:      Matthew Hopkins

   Remarks:     All routines link back to the following base routines
                function GetRawActual()
                function GetRawBudget()
                function GetRawLastYear()

                function GetRawQuantity()
                function GetRawQuantityLastYear()

                These functions are the only ones that actually access
                the data in the chart.
}
//------------------------------------------------------------------------------
interface
uses
   Classes, bkdefs, moneydef, clObj32;

type
  TAccountInformation = class
    constructor Create( const aClient : TClientObj); virtual;
    destructor  Destroy; override;
  private
    FAccountCode     : string;
    pAcct            : pAccount_Rec;
    FClient          : TClientObj;
    FLastPeriodOfActualDataToUse: integer;
    FUseBudgetIfNoActualData: boolean;
    FUseBaseAmounts: boolean;

    procedure SetAccountCode(const Value: string); virtual;
    procedure SetClient(const Value: TClientObj);

    function GetFirstPeriod: integer;
    function GetLastPeriod: integer;
    procedure SetLastPeriodOfActualDataToUse(const Value: integer); virtual;
    procedure SetUseBudgetIfNoActualData(const Value: boolean); virtual;

    function OpeningBalanceActual( ForPeriod : integer) : Money;
    function ClosingBalanceActual( ForPeriod : integer) : Money;

    function GetRawActual( ForPeriod : integer) : Money; virtual;
    function GetRawBudget( ForPeriod : integer) : Money; virtual;
    function GetRawQuantity( ForPeriod : integer) : Money; virtual;
    function GetRawLastYear( ForPeriod : integer) : Money; virtual;
    function GetRawQuantityLastYear( ForPeriod : integer) : Money; virtual;
    function GetRawBudgetQuantity( ForPeriod: Integer): Money; virtual;
    function GetRawBudgetUnitPrice( ForPeriod: Integer): Money; virtual;

    function GetRawActualOrBudget( ForPeriod : integer) : Money; virtual;

    function Actual( ForPeriod : integer) : Money; virtual;
    function YTD_Actual( UpToPeriod : integer) : Money; virtual;
    procedure SetUseBaseAmounts(const Value: boolean);
  public
    property AccountCode    : string read FAccountCode write SetAccountCode;
    property Client         : TClientObj read FClient write SetClient;
    property LowestPeriod   : integer read GetFirstPeriod;
    property HighestPeriod  : integer read GetLastPeriod;
    property Account        : pAccount_Rec read pAcct;
    property LastPeriodOfActualDataToUse : integer read FLastPeriodOfActualDataToUse write SetLastPeriodOfActualDataToUse;
    property UseBudgetIfNoActualData : boolean read FUseBudgetIfNoActualData write SetUseBudgetIfNoActualData;

    //virutal functions this year
    function ActualOrBudget ( ForPeriod : integer) : Money; virtual;
    function Budget( ForPeriod : integer) : Money; virtual;

    function Quantity( ForPeriod : integer) : Money; virtual;
    function QuantityOrBudget( ForPeriod : integer) : Money; virtual;
    function BudgetQuantity( ForPeriod: Integer) : Money; virtual;
    function BudgetUnitPrice( ForPeriod: Integer) : Money; virtual;

    function YTD_ActualOrBudget( UpToPeriod : integer) : Money; virtual;
    function YTD_Budget( UpToPeriod : integer) : Money; virtual;
    function YTD_Quantity( UpToPeriod : integer) : Money; virtual;
    function YTD_BudgetQuantity(UpToPeriod: integer): Money; virtual;
    function AVG_BudgetUnitPrice(UpToPeriod: integer): Money; virtual;

    function OpeningBalanceActualOrBudget( ForPeriod : integer) : Money;
    function OpeningBalanceBudget(ForPeriod: integer): Money;
    function ClosingBalanceActualOrBudget( ForPeriod : integer) : Money;
    function ClosingBalanceBudget(ForPeriod: integer): Money;

    //virutal functions last year
    function LastYear( ForPeriod : integer) : Money; virtual;
    function Quantity_LastYear( ForPeriod : integer) : Money; virtual;

    function YTD_LastYear( UpToPeriod : integer) : Money; virtual;
    function YTD_Quantity_LastYear( UpToPeriod : integer) : Money; virtual;

    function OpeningBalance_LastYear( ForPeriod : integer) : Money;
    function ClosingBalance_LastYear( ForPeriod : integer) : Money;

    //calculated values
    function Variance_ActualBudget( ForPeriod : integer) : Money;
    function Variance_ActualLastYear( ForPeriod : integer) : Money;
    function Variance_QuantityLastYear( ForPeriod : integer) : Money;

    function YTD_Variance_ActualBudget( UpToPeriod : integer) : Money;
    function YTD_Variance_ActualLastYear( UpToPeriod : integer) : Money;
    function YTD_Variance_Quantity_LastYear( UpToPeriod : integer) : Money;

    function BudgetRemaining( ActualPeriod : integer; FullYearPeriod : integer) : Money;

    //opening balance budget - not currently supported
    //closing balance budget - not currently supported

    function Variance_OpeningBalance_ActualLastYear( ForPeriod : integer) : Money;
    function Variance_ClosingBalance_ActualLastYear( ForPeriod : integer) : Money;

    property UseBaseAmounts: boolean read FUseBaseAmounts write SetUseBaseAmounts;
  end;

  TSetOfByte = set of Byte;

  TProfitAndLossAccountInfo = class( TAccountInformation)
    constructor Create( const aClient : TClientObj); override;
    destructor  Destroy; override;
  private
    ReverseSign : boolean;
    LinkedAccountInfo : TProfitAndLossAccountInfo;

    function GetRawActual( ForPeriod : integer) : Money; override;
    function GetRawBudget( ForPeriod : integer) : Money; override;
    function GetRawLastYear( ForPeriod : integer) : Money; override;

    function UseLinkedAccount( var PeriodNo : integer) : boolean;
    function LinkedPeriodNo( OriginalPeriodNo : integer) : integer;

    function AccountIsInSet( ReportGroupSet : TSetOfByte) : boolean;

    function Actual( ForPeriod : integer) : Money; override;
    function YTD_Actual( UpToPeriod : integer) : Money; override;

    procedure SetAccountCode(const Value: string); override;
    procedure SetLastPeriodOfActualDataToUse(const Value: integer); override;
    procedure SetUseBudgetIfNoActualData(const Value: boolean); override;
  public
    function ActualOrBudget ( ForPeriod : integer) : Money; override;
    function Budget( ForPeriod : integer) : Money;    override;

    function YTD_ActualOrBudget( UpToPeriod : integer) : Money; override;
    function YTD_Budget( UpToPeriod : integer) : Money; override;

    function LastYear( ForPeriod : integer) : Money; override;
    function YTD_LastYear( UpToPeriod : integer) : Money; override;
  end;

//******************************************************************************
implementation

uses
  chList32,
  math,
  sysUtils,
  bkConst,
  GenUtils;

{ TAccountInformation }

function TAccountInformation.Actual(ForPeriod: integer): Money;
begin
  result := GetRawActual( ForPeriod);
end;

function TAccountInformation.ActualOrBudget(ForPeriod: integer): Money;
begin
  result := GetRawActualOrBudget( ForPeriod);
end;

function TAccountInformation.Budget(ForPeriod: integer): Money;
begin
  result := GetRawBudget( ForPeriod);
end;

function TAccountInformation.BudgetQuantity(ForPeriod: Integer): Money;
begin
  Result := GetRawBudgetQuantity(ForPeriod);
end;

function TAccountInformation.BudgetRemaining(ActualPeriod, FullYearPeriod : integer): Money;
begin
  result := YTD_Budget( FullYearPeriod) - YTD_Actual( ActualPeriod);
end;

function TAccountInformation.BudgetUnitPrice(ForPeriod: Integer): Money;
begin
  Result := GetRawBudgetUnitPrice( ForPeriod);
end;

function TAccountInformation.ClosingBalanceActual(
  ForPeriod: integer): Money;
begin
  result := OpeningBalanceActual( ForPeriod) + GetRawActual( ForPeriod);
end;

function TAccountInformation.ClosingBalanceActualOrBudget(
  ForPeriod: integer): Money;
begin
  result := OpeningBalanceActualOrBudget( ForPeriod) + GetRawActualOrBudget( ForPeriod);
end;

function TAccountInformation.ClosingBalanceBudget(ForPeriod: integer): Money;
begin
  result := OpeningBalanceBudget(ForPeriod) + GetRawBudget(ForPeriod);
end;

function TAccountInformation.ClosingBalance_LastYear(
  ForPeriod: integer): Money;
begin
  result := OpeningBalance_LastYear( ForPeriod) + GetRawLastYear( ForPeriod);
end;

constructor TAccountInformation.Create(const aClient: TClientObj);
begin
   inherited Create;
   FClient := aClient;
end;

destructor TAccountInformation.Destroy;
begin
  FClient := nil;
  pAcct   := nil;
  inherited;
end;

function TAccountInformation.GetFirstPeriod: integer;
begin
  result := -1;
  if not Assigned( pAcct) then exit;

  if UseBaseAmounts then
    result := Low( pAcct^.chTemp_Base_Amount.This_Year)
  else
    result := Low( pAcct^.chTemp_Amount.This_Year);
end;

function TAccountInformation.GetLastPeriod: integer;
//this year and last year may have different periods depending on the number of
//weeks in each year.  Provide the highest value.
begin
  result := -1;
  if not Assigned( pAcct) then exit;

  if UseBaseAmounts then
    result := Max( High( pAcct^.chTemp_Base_Amount.This_Year), High( pAcct^.chTemp_Base_Amount.Last_Year))
  else
    result := Max( High( pAcct^.chTemp_Amount.This_Year), High( pAcct^.chTemp_Amount.Last_Year));
end;

function TAccountInformation.GetRawActual(ForPeriod: integer): Money;
//Base routine.  The routine accesses the figures in the chart
begin
  result := 0;
  if not Assigned( pAcct) then exit;
  if ForPeriod > FLastPeriodOfActualDataToUse then exit;

  Assert( ForPeriod <= HighestPeriod, 'ForPeriod (' + inttostr( ForPeriod) + ') > HighestPeriod (' + inttostr( HighestPeriod) + ')');

  if UseBaseAmounts then begin
    if ForPeriod <= High( pAcct^.chTemp_Base_Amount.This_Year) then
      result := pAcct^.chTemp_Base_Amount.This_Year[ ForPeriod];
  end else begin
    if ForPeriod <= High( pAcct^.chTemp_Amount.This_Year) then
      result := pAcct^.chTemp_Amount.This_Year[ ForPeriod];
  end;
end;

function TAccountInformation.GetRawActualOrBudget(
  ForPeriod: integer): Money;
begin
  if ( ForPeriod > FLastPeriodOfActualDataToUse) and FUseBudgetIfNoActualData then
    result := GetRawBudget( ForPeriod)
  else
    result := GetRawActual( ForPeriod);
end;

function TAccountInformation.GetRawBudget(ForPeriod: integer): Money;
//Base routine.  The routine accesses the figures in the chart
begin
  result := 0;
  if not Assigned( pAcct) then exit;

  Assert( ForPeriod <= HighestPeriod, 'ForPeriod (' + inttostr( ForPeriod) + ') > HighestPeriod (' + inttostr( HighestPeriod) + ')');

  if UseBaseAmounts then begin
    if ForPeriod <= High( pAcct^.chTemp_Base_Amount.Budget) then
      result := pAcct^.chTemp_Base_Amount.Budget[ ForPeriod];
  end else begin
    if ForPeriod <= High( pAcct^.chTemp_Amount.Budget) then
      result := pAcct^.chTemp_Amount.Budget[ ForPeriod];
  end;
end;

function TAccountInformation.GetRawBudgetQuantity(ForPeriod: Integer): Money;
//Base routine.  The routine accesses the figures in the chart
begin
  result := 0;
  if not Assigned(pAcct) then
    Exit;

  Assert( ForPeriod <= HighestPeriod, 'ForPeriod (' + inttostr( ForPeriod) + ') > HighestPeriod (' + inttostr( HighestPeriod) + ')');

  if ForPeriod > High(pAcct^.chTemp_Quantity.Budget) then
    result := 0
  else
    result := pAcct^.chTemp_Quantity.Budget[ForPeriod];
end;

function TAccountInformation.GetRawBudgetUnitPrice(ForPeriod: Integer): Money;
//Base routine.  The routine accesses the figures in the chart
begin
  result := 0;
  if not Assigned(pAcct) then
    Exit;

  Assert( ForPeriod <= HighestPeriod, 'ForPeriod (' + inttostr( ForPeriod) + ') > HighestPeriod (' + inttostr( HighestPeriod) + ')');

  if ForPeriod > High(pAcct^.chTemp_Quantity.Budget) then
    result := 0
  else
    result := pAcct^.chTemp_Amount.Budget_Unit_Price[ForPeriod];
end;

function TAccountInformation.GetRawLastYear(ForPeriod: integer): Money;
//Base routine.  The routine accesses the figures in the chart
begin
  result := 0;
  if not Assigned( pAcct) then exit;
  Assert( ForPeriod <= HighestPeriod, 'ForPeriod (' + inttostr( ForPeriod) + ') > HighestPeriod (' + inttostr( HighestPeriod) + ')');

  if UseBaseAmounts then begin
    if ForPeriod <= High( pAcct^.chTemp_Base_Amount.Last_Year) then
      result := pAcct^.chTemp_Base_Amount.Last_Year[ ForPeriod];
  end else begin
    if ForPeriod <= High( pAcct^.chTemp_Amount.Last_Year) then
      result := pAcct^.chTemp_Amount.Last_Year[ ForPeriod];
  end;
end;

function TAccountInformation.GetRawQuantity(ForPeriod: integer): Money;
//Base routine.  The routine accesses the figures in the chart
begin
  result := 0;
  if not Assigned( pAcct) then exit;
  Assert( ForPeriod <= HighestPeriod, 'ForPeriod (' + inttostr( ForPeriod) + ') > HighestPeriod (' + inttostr( HighestPeriod) + ')');

  if ForPeriod > High( pAcct^.chTemp_Quantity.This_Year) then
    result := 0
  else
    result := pAcct^.chTemp_Quantity.This_Year[ ForPeriod];
end;


function TAccountInformation.GetRawQuantityLastYear(
  ForPeriod: integer): Money;
//Base routine.  The routine accesses the figures in the chart
begin
  result := 0;
  if not Assigned( pAcct) then exit;
  Assert( ForPeriod <= HighestPeriod, 'ForPeriod (' + inttostr( ForPeriod) + ') > HighestPeriod (' + inttostr( HighestPeriod) + ')');

  if ForPeriod > High( pAcct^.chTemp_Quantity.Last_Year) then
    result := 0
  else
    result := pAcct^.chTemp_Quantity.Last_Year[ ForPeriod];
end;

function TAccountInformation.LastYear(ForPeriod: integer): Money;
begin
  result := GetRawLastYear( ForPeriod);
end;

function TAccountInformation.OpeningBalanceActual(ForPeriod: integer): Money;
//equals the opening balance + all movements
var
  i : integer;
begin
  result := 0;
  for i := 0 to ( ForPeriod - 1) do
     result := result + GetRawActual( i);
end;

function TAccountInformation.OpeningBalanceActualOrBudget(
  ForPeriod: integer): Money;
var
  i : integer;
begin
  result := 0;
  for i := 0 to ( ForPeriod - 1) do
     result := result + GetRawActualOrBudget( i);
end;

function TAccountInformation.OpeningBalanceBudget(ForPeriod: integer): Money;
var
  i: Integer;
begin
  result := 0;
  for i := 0 to (ForPeriod - 1) do
    result := result + GetRawBudget(i);
end;

function TAccountInformation.OpeningBalance_LastYear(
  ForPeriod: integer): Money;
var
  i : integer;
begin
  result := 0;
  for i := 0 to ( ForPeriod - 1) do
     result := result + GetRawLastYear( i);
end;

function TAccountInformation.Quantity(ForPeriod: integer): Money;
begin
  result := GetRawQuantity( ForPeriod);
end;

function TAccountInformation.QuantityOrBudget(ForPeriod: integer): Money;
begin
   if ( ForPeriod > FLastPeriodOfActualDataToUse) and FUseBudgetIfNoActualData then
    result := GetRawBudgetQuantity( ForPeriod)
  else
    result := GetRawQuantity( ForPeriod);
end;

function TAccountInformation.Quantity_LastYear(ForPeriod: integer): Money;
begin
  result := GetRawQuantityLastYear( ForPeriod);
end;

procedure TAccountInformation.SetAccountCode(const Value: string);
begin
  if Value <> FAccountCode then
  begin
    if Assigned( FClient) then begin
      pAcct := FClient.clChart.FindCode( Value);
    end
    else
      pAcct := nil;
  end;
  FAccountCode := Value;
end;

procedure TAccountInformation.SetClient(const Value: TClientObj);
begin
  FClient := Value;
end;

procedure TAccountInformation.SetLastPeriodOfActualDataToUse(
  const Value: integer);
begin
  FLastPeriodOfActualDataToUse := Value;
end;

procedure TAccountInformation.SetUseBaseAmounts(const Value: boolean);
begin
  FUseBaseAmounts := Value;
end;

procedure TAccountInformation.SetUseBudgetIfNoActualData(
  const Value: boolean);
begin
  FUseBudgetIfNoActualData := Value;
end;

function TAccountInformation.Variance_ActualBudget(
  ForPeriod: integer): Money;
var
  Act : Money;
begin
  if FUseBudgetIfNoActualData then
     Act := ActualOrBudget( ForPeriod)
  else
     Act := Actual( ForPeriod);

  result := Act - Budget( ForPeriod);
end;

function TAccountInformation.Variance_ActualLastYear(
  ForPeriod: integer): Money;
var
  Act : Money;
begin
  if FUseBudgetIfNoActualData then
     Act := ActualOrBudget( ForPeriod)
  else
     Act := Actual( ForPeriod);

  result := Act - LastYear( ForPeriod);
end;

function TAccountInformation.Variance_ClosingBalance_ActualLastYear(
  ForPeriod : integer): Money;
var
  ClosingThisYear : Money;
begin
  if FUseBudgetIfNoActualData then
     ClosingThisYear := ClosingBalanceActualOrBudget( ForPeriod)
  else
     ClosingThisYear := ClosingBalanceActual( ForPeriod);

  result := ClosingThisYear - ClosingBalance_LastYear( ForPeriod);
end;

function TAccountInformation.Variance_OpeningBalance_ActualLastYear(
  ForPeriod : integer): Money;
var
  OpeningThisYear : Money;
begin
  if FUseBudgetIfNoActualData then
     OpeningThisYear := OpeningBalanceActualOrBudget( ForPeriod)
  else
     OpeningThisYear := OpeningBalanceActual( ForPeriod);

  result := OpeningThisYear - OpeningBalance_LastYear( ForPeriod);
end;

function TAccountInformation.Variance_QuantityLastYear(
  ForPeriod: integer): Money;
begin
  result := Quantity( ForPeriod) - Quantity_LastYear( ForPeriod);
end;

function TAccountInformation.YTD_Actual(UpToPeriod: integer): Money;
var
   i : integer;
begin
  result := 0;
  for i := 1 to UpToPeriod do
    result := result + GetRawActual( i);
end;

function TAccountInformation.YTD_ActualOrBudget(
  UpToPeriod: integer): Money;
var
  i : integer;
begin
  result := 0;
  for i := 1 to UpToPeriod do
    result := result + GetRawActualOrBudget( i);
end;

function TAccountInformation.YTD_Budget(UpToPeriod: integer): Money;
var
  i : integer;
begin
  result := 0;
  for i := 1 to UpToPeriod do
    result := result + GetRawBudget( i);
end;

function TAccountInformation.YTD_BudgetQuantity(UpToPeriod: integer): Money;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to UpToPeriod do
    Result := Result + GetRawBudgetQuantity(i);
end;


function TAccountInformation.AVG_BudgetUnitPrice(UpToPeriod: integer): Money;
var
  I: Integer;
  Total: Money;
  Count: Money;
  PeriodCount: Money;
begin
  //Gets the average unit price
  Total := 0;
  Count := 0;
  for I := 1 to UpToPeriod do
  begin
    PeriodCount := GetRawBudgetQuantity(I);
    Total := Total + (GetRawBudgetUnitPrice(I) * PeriodCount);
    Count := Count + PeriodCount;
  end;

  if Count = 0 then
    Result := 0
  else
    Result := Total / Count;
end;

function TAccountInformation.YTD_LastYear(UpToPeriod: integer): Money;
var
  i : integer;
begin
  result := 0;
  for i := 1 to UpToPeriod do
    result := result + GetRawLastYear( i);
end;

function TAccountInformation.YTD_Quantity(UpToPeriod: integer): Money;
var
  i : integer;
begin
  result := 0;
  for i := 1 to UpToPeriod do
    result := result + QuantityOrBudget( i);
end;

function TAccountInformation.YTD_Quantity_LastYear(
  UpToPeriod: integer): Money;
var
  i : integer;
begin
  result := 0;
  for i := 1 to UpToPeriod do
    result := result + GetRawQuantityLastYear( i);
end;

function TAccountInformation.YTD_Variance_ActualBudget(
  UpToPeriod: integer): Money;
var
  Act : Money;
begin
  if FUseBudgetIfNoActualData then
     Act := YTD_ActualOrBudget( UpToPeriod)
  else
     Act := YTD_Actual( UpToPeriod);

   result := Act - YTD_Budget( UpToPeriod);
end;

function TAccountInformation.YTD_Variance_ActualLastYear(
  UpToPeriod: integer): Money;
var
  Act : Money;
begin
  if FUseBudgetIfNoActualData then
     Act := YTD_ActualOrBudget( UpToPeriod)
  else
     Act := YTD_Actual( UpToPeriod);

  result := Act - YTD_LastYear( UpToPeriod);
end;

function TAccountInformation.YTD_Variance_Quantity_LastYear(
  UpToPeriod: integer): Money;
begin
  result := YTD_Quantity( UpToPeriod) - YTD_Quantity_LastYear( UpToPeriod);
end;

{ TProfitAndLossAccountInfo }

function TProfitAndLossAccountInfo.AccountIsInSet(
  ReportGroupSet: TSetOfByte): boolean;
begin
  result := false;
  if not Assigned( pAcct) then exit;

  result := pAcct^.chAccount_Type in ReportGroupSet;
end;

function TProfitAndLossAccountInfo.Actual(ForPeriod: integer): Money;
begin
  if UseLinkedAccount(ForPeriod) then
    result := LinkedAccountInfo.Actual( LinkedPeriodNo( ForPeriod))
  else begin
    if AccountIsInSet( [ atOpeningStock, atClosingStock]) then begin
      result := inherited ClosingBalanceActual( ForPeriod);
    end
    else
      result := inherited Actual( ForPeriod);
  end;
end;

function TProfitAndLossAccountInfo.ActualOrBudget(
  ForPeriod: integer): Money;
begin
  if UseLinkedAccount(ForPeriod) then
  begin
    result := LinkedAccountInfo.ActualOrBudget( LinkedPeriodNo( ForPeriod));
  end
  else begin
    if AccountIsInSet( [ atOpeningStock, atClosingStock]) then
    begin
      result := inherited ClosingBalanceActualOrBudget( ForPeriod);
    end
    else
    begin
      result := inherited ActualOrBudget( ForPeriod);
    end;
  end;
end;

function TProfitAndLossAccountInfo.Budget(ForPeriod: integer): Money;
//the budget figures are treated as period to date figures for stock accounts
//so there is no difference to normal
begin
  if UseLinkedAccount(ForPeriod) then
    result := LinkedAccountInfo.Budget( LinkedPeriodNo(ForPeriod))
  else
    result := inherited Budget( ForPeriod);
end;

constructor TProfitAndLossAccountInfo.Create(const aClient: TClientObj);
begin
  inherited Create( aClient);
  LinkedAccountInfo := nil;
end;

destructor TProfitAndLossAccountInfo.Destroy;
begin
  LinkedAccountInfo.Free;
  inherited;
end;

function TProfitAndLossAccountInfo.GetRawActual(ForPeriod: integer): Money;
//if the closing stock account is being used instead opening stock we
//need to reversing the sign, this is because opening stock is a debit account
//and closing stock is a credit account.
begin
  result := inherited GetRawActual( ForPeriod);

  if ReverseSign then
    result := - result;
end;

function TProfitAndLossAccountInfo.GetRawBudget(ForPeriod: integer): Money;
//see note on GetRawActual
begin
  result := inherited GetRawBudget( ForPeriod);

  if ReverseSign then
    result := - result;
end;

function TProfitAndLossAccountInfo.GetRawLastYear(
  ForPeriod: integer): Money;
//see note on GetRawActual
begin
  result := inherited GetRawLastYear( ForPeriod);

  if ReverseSign then
    result := - result;
end;

function TProfitAndLossAccountInfo.LastYear(ForPeriod: integer): Money;
begin
  if UseLinkedAccount( ForPeriod) then
    result := LinkedAccountInfo.LastYear( LinkedPeriodNo( ForPeriod))
  else begin
    if AccountIsInSet( [ atOpeningStock, atClosingStock]) then begin
      result := inherited ClosingBalance_LastYear( ForPeriod);
    end
    else
      result := inherited LastYear( ForPeriod);
  end;
end;

function TProfitAndLossAccountInfo.LinkedPeriodNo(
  OriginalPeriodNo: integer): integer;
begin
  result := OriginalPeriodNo;

  if pAcct^.chAccount_Type = atOpeningStock then begin
    //this will link to a closing stock account, the opening stock of this
    //period will be the closing stock of the previous period, so decrement the
    //original period by one
    result := OriginalPeriodNo - 1;
  end;
end;

procedure TProfitAndLossAccountInfo.SetAccountCode(const Value: string);
var
  LinkedAcct : pAccount_Rec;
begin
  inherited;
  ReverseSign := false;

  //opening stock accounts may link to a closing stock account for there values
  //clear any existing links
  FreeAndNil( LinkedAccountInfo);

  if pAcct^.chAccount_Type = atOpeningStock then begin
    LinkedAcct := FClient.clChart.FindCode( pAcct^.chLinked_Account_CS);
    if Assigned( LinkedAcct) and ( LinkedAcct.chAccount_Type = atClosingStock) then begin
      LinkedAccountInfo := TProfitAndLossAccountInfo.Create( FClient);
      LinkedAccountInfo.AccountCode                 := LinkedAcct^.chAccount_Code;
      LinkedAccountInfo.ReverseSign                 := True;
      LinkedAccountInfo.LastPeriodOfActualDataToUse := Self.LastPeriodOfActualDataToUse;
      LinkedAccountInfo.UseBudgetIfNoActualData     := Self.UseBudgetIfNoActualData;
    end;
  end;
end;

procedure TProfitAndLossAccountInfo.SetLastPeriodOfActualDataToUse(
  const Value: integer);
begin
  inherited;
  //now update setting in the linked account so that same options are used
  if Assigned( LinkedAccountInfo) and Assigned( Self.Account) and ( Self.Account.chAccount_Type = atOpeningStock) then
    LinkedAccountInfo.LastPeriodOfActualDataToUse := value;
end;

procedure TProfitAndLossAccountInfo.SetUseBudgetIfNoActualData(
  const Value: boolean);
begin
  inherited;
  //now update setting in the linked account so that same options are used
  if Assigned( LinkedAccountInfo) and Assigned( Self.Account) and ( Self.Account.chAccount_Type = atOpeningStock) then
    LinkedAccountInfo.UseBudgetIfNoActualData := value;
end;

function TProfitAndLossAccountInfo.UseLinkedAccount( var PeriodNo : integer) : boolean;
//the opening stock figure can be taken from the closing stock figure of the
//previous period if a linked account has been specified.  If this is the case
//then the sign of the account must be reversed
//the linked account will be "linked" when the account code is set
begin
  result := false;
  if Assigned( LinkedAccountInfo) then begin
    if (pAcct.chAccount_Type = atOpeningStock) then begin
      //use the closing stock account for periods greater than 1
      result := PeriodNo > 1;
    end;
  end;
end;

function TProfitAndLossAccountInfo.YTD_Actual(UpToPeriod: integer): Money;
begin
  if (pAcct.chAccount_Type = atOpeningStock) then begin
    result := inherited ClosingBalanceActual( 1);
  end
  else if (pAcct.chAccount_Type = atClosingStock) then
    result := inherited ClosingBalanceActual( UpToPeriod)
  else
    result := inherited YTD_Actual( UpToPeriod);
end;

function TProfitAndLossAccountInfo.YTD_ActualOrBudget(
  UpToPeriod: integer): Money;
begin
  if (pAcct.chAccount_Type = atOpeningStock) then begin
    result := inherited ClosingBalanceActualOrBudget(1);
  end
  else if (pAcct.chAccount_Type = atClosingStock) then
    result := inherited ClosingBalanceActualOrBudget( UpToPeriod)
  else
    result := inherited YTD_ActualOrBudget( UpToPeriod);
end;

function TProfitAndLossAccountInfo.YTD_Budget(UpToPeriod: integer): Money;
//for stock accounts it is assumed that the ammounts in the budget are end of
//period amounts
begin
  if (pAcct.chAccount_Type = atOpeningStock) then
    result := inherited Budget(1)
  else if (pAcct.chAccount_Type = atClosingStock) then
    result := inherited Budget( UpToPeriod)
  else
    result := inherited YTD_Budget( UpToPeriod);
end;

function TProfitAndLossAccountInfo.YTD_LastYear(
  UpToPeriod: integer): Money;
begin
  if (pAcct.chAccount_Type = atOpeningStock) then
    result := inherited ClosingBalance_LastYear(1)
  else if (pAcct.chAccount_Type = atClosingStock) then
    result := inherited ClosingBalance_LastYear( UpToPeriod)
  else
    result := inherited YTD_LastYear( UpToPeriod);
end;

end.
