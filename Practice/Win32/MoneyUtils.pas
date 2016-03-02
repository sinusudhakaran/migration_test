unit MoneyUtils;

{ We can't use %0.2m to return formatted strings because it is hard to test }

// ----------------------------------------------------------------------------
interface

uses
  MoneyDef,
  ISO_4217;
// ----------------------------------------------------------------------------

const
  MONEY_FORMAT      = '#,##0.00;#,##0.00';
  MONEY_FORMAT_SIGN = '#,##0.00;-#,##0.00';
  QUANTITY_FORMAT   = '#,##0.000;#,##0.000';

  Function MoneyStrNoSymbol( Const Amount : Money ): String;
  Function BalanceStrNoSymbol( Const Amount : Money ): String;
  Function MoneyStr( Const Amount : Money; Const aCurrencyCode : String ): String;
  Function MoneyStrBrackets( Const Amount : Money; Const aCurrencyCode : String ): String;
  Function BalanceStr( Const Amount : Money; Const aCurrencyCode : String ): String;
  Function FmtBalanceStrNoSymbol: String;
  Function DrCrStr( Const Amount : Money; Const aCurrencyCode : String ): String;
  Function DrCrStrNoSymbol( Const Amount : Money ): String;

  // ----------------------------------------------------------------------------

  Function FmtMoneyStr( Const aCurrencyCode : String ): String;
  Function FmtMoneyStrBrackets( Const aCurrencyCode : String ): String;
  Function FmtBalanceStr( Const aCurrencyCode : String ): String;
  Function FmtMoneyStrBracketsNoSymbol: String;
  Function FmtDrCrStr( Const aCurrencyCode : String ): String;
  Function FmtDrCrStrNoSymbol: String;

  Function CurrencySymbol( Const aCurrencyCode : String ): String;

  Function ForexRate2Str( R : Double ): String;
  Function ForexPictureMask : String;

// ----------------------------------------------------------------------------
implementation

uses
  BkConst,
  SysUtils;
// ----------------------------------------------------------------------------

{These constants have been replace by those in ISO_4217
Const
  msNZD = 0; msMin = msNZD;
  msAUD = 1;
  msUKP = 2;
  msEUR = 3;
  msUSD = 4; msMax = msUSD;

  msSymbols : Array[ msNZD..msUSD ] of String[1] = ( '$', '$', '£', '€', '$' );
  msCodes   : Array[ msNZD..msUSD ] of String[3] = ( 'NZD', 'AUD', 'GBP', 'EUR', 'USD' );
}
// ----------------------------------------------------------------------------


Function MoneyStrNoSymbol( Const Amount : Money ): String;
Begin
  if Amount = Unknown then
    Result := 'Unknown'
  else
    Result := FormatFloat( '#,##0.00;-#,##0.00', Amount/100.0 );
End;

// ----------------------------------------------------------------------------

Function FmtBalanceStrNoSymbol: String;
Begin
  Result := '#,##0.00 OD;#,##0.00 IF;0.00';
end;

Function BalanceStrNoSymbol( Const Amount : Money ): String;
Begin
  if Amount = Unknown then
    Result := 'Unknown'
  else
    Result := FormatFloat( FmtBalanceStrNoSymbol, Amount/100.0 );
End;

// ----------------------------------------------------------------------------

Function FmtDrCrStrNoSymbol: String;
Begin
  Result := '#,##0.00 DR;#,##0.00 CR;0.00';
end;

// ----------------------------------------------------------------------------

Function DrCrStrNoSymbol( Const Amount : Money ): String;
Begin
  if Amount = Unknown then
    Result := 'Unknown'
  else
    Result := FormatFloat( FmtDrCRStrNoSymbol, Amount/100.0 );
End;

// ----------------------------------------------------------------------------

Function FmtDrCrStr( Const aCurrencyCode : String ): String;
Var
  Symbol: string;
Begin
  Symbol := Get_ISO_4217_Symbol(aCurrencyCode);
  Result := Symbol + '#,##0.00 DR;' + Symbol + '#,##0.00 CR;' + Symbol + '0.00';
End;

// ----------------------------------------------------------------------------

Function DrCrStr( Const Amount : Money; Const aCurrencyCode : String ): String;
Begin
  if Amount = Unknown then
    Result := 'Unknown'
  else
    Result := FormatFloat( FmtDrCrStr( aCurrencyCode ), Amount/100.0 );
End;

// ----------------------------------------------------------------------------

Function FmtMoneyStr( Const aCurrencyCode : String ): String;
Var
  Symbol: string;
Begin
  Symbol := Get_ISO_4217_Symbol(aCurrencyCode);
  Result := Symbol + '#,##0.00;' + '-' + Symbol + '#,##0.00';
End;

// ----------------------------------------------------------------------------

Function FmtMoneyStrBracketsNoSymbol: String;
Begin
  Result := '#,##0.00;(#,##0.00);0.00';
end;

// ----------------------------------------------------------------------------

Function MoneyStr( Const Amount : Money; Const aCurrencyCode : String ): String;
Begin
  if Amount = Unknown then
    Result := 'Unknown'
  else
    Result := FormatFloat( FmtMoneyStr( aCurrencyCode ), Amount/100.0 );
End;

// ----------------------------------------------------------------------------

Function FmtMoneyStrBrackets( Const aCurrencyCode : String ): String;
Var
  Symbol: string;
Begin
  Symbol := Get_ISO_4217_Symbol(aCurrencyCode);
  Result := Symbol + '#,##0.00;' + Symbol + '(#,##0.00);' + Symbol + '0.00';
End;

// ----------------------------------------------------------------------------

Function MoneyStrBrackets( Const Amount : Money; Const aCurrencyCode : String ): String;
Begin
  if Amount = Unknown then
    Result := 'Unknown'
  else
    Result := FormatFloat( FmtMoneyStrBrackets( aCurrencyCode ), Amount/100.0 );
End;

// ----------------------------------------------------------------------------

Function FmtBalanceStr( Const aCurrencyCode : String ): String;
Var
  Symbol: string;
Begin
  Symbol := Get_ISO_4217_Symbol(aCurrencyCode);
  Result := Symbol + '#,##0.00 OD;' + Symbol + '#,##0.00 IF;' + Symbol + '0.00';
End;

// ----------------------------------------------------------------------------

Function BalanceStr( Const Amount : Money; Const aCurrencyCode : String ): String;
Begin
  if Amount = Unknown then
    Result := 'Unknown'
  else
    Result := FormatFloat( FmtBalanceStr( aCurrencyCode ), Amount/100.0 );
End;

// ----------------------------------------------------------------------------

Function CurrencySymbol( Const aCurrencyCode : String ): String;
Begin
  Result := Get_ISO_4217_Symbol(aCurrencyCode);
End;

// ----------------------------------------------------------------------------

Function ForexRate2Str( R : Double ): String;
Begin
  Result := '';
  Case BKConst.ForexDP of
    2 : Result := Format( '%0.2f', [ R ] );
    3 : Result := Format( '%0.3f', [ R ] );
    4 : Result := Format( '%0.4f', [ R ] );
    5 : Result := Format( '%0.5f', [ R ] );
    6 : Result := Format( '%0.6f', [ R ] );
  End;
End;

// ----------------------------------------------------------------------------

Function ForexPictureMask : String;
Begin
  Case BKConst.ForexDP of
    2 : Result := '####.##';
    3 : Result := '####.###';
    4 : Result := '####.####';
    5 : Result := '####.#####';
    6 : Result := '####.######';
  End;
End;

Procedure RunTests;
Begin
  Assert( MoneyStr( 100, 'NZD' ) = '$1.00' );
  Assert( MoneyStr( 100000, 'NZD' ) = '$1,000.00' );
  Assert( MoneyStr( 0, 'NZD' ) = '$0.00' );
  Assert( MoneyStr( -1, 'NZD' ) = '-$0.01' );
  Assert( MoneyStr( -100, 'NZD' ) = '-$1.00' );
  Assert( MoneyStr( Unknown, 'NZD' ) = 'Unknown' );

  Assert( MoneyStr( 100, 'AUD' ) = '$1.00' );
  Assert( MoneyStr( 100000, 'AUD' ) = '$1,000.00' );
  Assert( MoneyStr( 0, 'AUD' ) = '$0.00' );
  Assert( MoneyStr( -1, 'AUD' ) = '-$0.01' );
  Assert( MoneyStr( -100, 'AUD' ) = '-$1.00' );
  Assert( MoneyStr( Unknown, 'AUD' ) = 'Unknown' );

  Assert( MoneyStr( 100, 'GBP' ) = '£1.00' );
  Assert( MoneyStr( 100000, 'GBP' ) = '£1,000.00' );
  Assert( MoneyStr( 0, 'GBP' ) = '£0.00' );
  Assert( MoneyStr( -1, 'GBP' ) = '-£0.01' );
  Assert( MoneyStr( -100, 'GBP' ) = '-£1.00' );
  Assert( MoneyStr( Unknown, 'GBP' ) = 'Unknown' );

  Assert( MoneyStr( 100, 'USD' ) = '$1.00' );
  Assert( MoneyStr( 100000, 'USD' ) = '$1,000.00' );
  Assert( MoneyStr( 0, 'USD' ) = '$0.00' );
  Assert( MoneyStr( -1, 'USD' ) = '-$0.01' );
  Assert( MoneyStr( -100, 'USD' ) = '-$1.00' );
  Assert( MoneyStr( Unknown, 'USD' ) = 'Unknown' );


  Assert( MoneyStr( 100, 'EUR' ) = '€1.00' );
  Assert( MoneyStr( 100000, 'EUR' ) = '€1,000.00' );
  Assert( MoneyStr( 0, 'EUR' ) = '€0.00' );
  Assert( MoneyStr( -1, 'EUR' ) = '-€0.01' );
  Assert( MoneyStr( -100, 'EUR' ) = '-€1.00' );
  Assert( MoneyStr( Unknown, 'EUR' ) = 'Unknown' );

  // --------------------------------------------------------------------------

  Assert( MoneyStrNoSymbol( 100 ) = '1.00' );
  Assert( MoneyStrNoSymbol( 100000 ) = '1,000.00' );
  Assert( MoneyStrNoSymbol( 0 ) = '0.00' );
  Assert( MoneyStrNoSymbol( -1 ) = '-0.01' );
  Assert( MoneyStrNoSymbol( -100 ) = '-1.00' );
  Assert( MoneyStrNoSymbol( Unknown ) = 'Unknown' );

  // --------------------------------------------------------------------------

  Assert( MoneyStrBrackets( 100, 'NZD' ) = '$1.00' );
  Assert( MoneyStrBrackets( 100000, 'NZD' ) = '$1,000.00' );
  Assert( MoneyStrBrackets( 0, 'NZD' ) = '$0.00' );
  Assert( MoneyStrBrackets( -1, 'NZD' ) = '$(0.01)' );
  Assert( MoneyStrBrackets( -100, 'NZD' ) = '$(1.00)' );
  Assert( MoneyStrBrackets( Unknown, 'NZD' ) = 'Unknown' );

  Assert( MoneyStrBrackets( 100, 'AUD' ) = '$1.00' );
  Assert( MoneyStrBrackets( 100000, 'AUD' ) = '$1,000.00' );
  Assert( MoneyStrBrackets( 0, 'AUD' ) = '$0.00' );
  Assert( MoneyStrBrackets( -1, 'AUD' ) = '$(0.01)' );
  Assert( MoneyStrBrackets( -100, 'AUD' ) = '$(1.00)' );
  Assert( MoneyStrBrackets( Unknown, 'AUD' ) = 'Unknown' );

  Assert( MoneyStrBrackets( 100, 'GBP' ) = '£1.00' );
  Assert( MoneyStrBrackets( 100000, 'GBP' ) = '£1,000.00' );
  Assert( MoneyStrBrackets( 0, 'GBP' ) = '£0.00' );
  Assert( MoneyStrBrackets( -1, 'GBP' ) = '£(0.01)' );
  Assert( MoneyStrBrackets( -100, 'GBP' ) = '£(1.00)' );
  Assert( MoneyStrBrackets( Unknown, 'GBP' ) = 'Unknown' );

  Assert( MoneyStrBrackets( 100, 'EUR' ) = '€1.00' );
  Assert( MoneyStrBrackets( 100000, 'EUR' ) = '€1,000.00' );
  Assert( MoneyStrBrackets( 0, 'EUR' ) = '€0.00' );
  Assert( MoneyStrBrackets( -1, 'EUR' ) = '€(0.01)' );
  Assert( MoneyStrBrackets( -100, 'EUR' ) = '€(1.00)' );
  Assert( MoneyStrBrackets( Unknown, 'EUR' ) = 'Unknown' );

  // --------------------------------------------------------------------------

  Assert( BalanceStr( 100, 'NZD' ) = '$1.00 OD' );
  Assert( BalanceStr( 100000, 'NZD' ) = '$1,000.00 OD' );
  Assert( BalanceStr( 0, 'NZD' ) = '$0.00' );
  Assert( BalanceStr( -1, 'NZD' ) = '$0.01 IF' );
  Assert( BalanceStr( -100, 'NZD' ) = '$1.00 IF' );
  Assert( BalanceStr( Unknown, 'NZD' ) = 'Unknown' );

  Assert( BalanceStr( 100, 'AUD' ) = '$1.00 OD' );
  Assert( BalanceStr( 100000, 'AUD' ) = '$1,000.00 OD' );
  Assert( BalanceStr( 0, 'AUD' ) = '$0.00' );
  Assert( BalanceStr( -1, 'AUD' ) = '$0.01 IF' );
  Assert( BalanceStr( -100, 'AUD' ) = '$1.00 IF' );
  Assert( BalanceStr( Unknown, 'AUD' ) = 'Unknown' );

  Assert( BalanceStr( 100, 'GBP' ) = '£1.00 OD' );
  Assert( BalanceStr( 100000, 'GBP' ) = '£1,000.00 OD' );
  Assert( BalanceStr( 0, 'GBP' ) = '£0.00' );
  Assert( BalanceStr( -1, 'GBP' ) = '£0.01 IF' );
  Assert( BalanceStr( -100, 'GBP' ) = '£1.00 IF' );
  Assert( BalanceStr( Unknown, 'GBP' ) = 'Unknown' );

  Assert( BalanceStr( 100, 'EUR' ) = '€1.00 OD' );
  Assert( BalanceStr( 100000, 'EUR' ) = '€1,000.00 OD' );
  Assert( BalanceStr( 0, 'EUR' ) = '€0.00' );
  Assert( BalanceStr( -1, 'EUR' ) = '€0.01 IF' );
  Assert( BalanceStr( -100, 'EUR' ) = '€1.00 IF' );
  Assert( BalanceStr( Unknown, 'EUR' ) = 'Unknown' );

  // --------------------------------------------------------------------------

  Assert( BalanceStrNoSymbol( 100 )       = '1.00 OD' );
  Assert( BalanceStrNoSymbol( 100000 )    = '1,000.00 OD' );
  Assert( BalanceStrNoSymbol( 0 )         = '0.00' );
  Assert( BalanceStrNoSymbol( -1 )        = '0.01 IF' );
  Assert( BalanceStrNoSymbol( -100 )      = '1.00 IF' );
  Assert( BalanceStrNoSymbol( Unknown )   = 'Unknown' );

  // --------------------------------------------------------------------------

  Assert( DrCrStr( 100, 'NZD' ) = '$1.00 DR' );
  Assert( DrCrStr( 100000, 'NZD' ) = '$1,000.00 DR' );
  Assert( DrCrStr( 0, 'NZD' ) = '$0.00' );
  Assert( DrCrStr( -1, 'NZD' ) = '$0.01 CR' );
  Assert( DrCrStr( -100, 'NZD' ) = '$1.00 CR' );
  Assert( DrCrStr( Unknown, 'NZD' ) = 'Unknown' );

  Assert( DrCrStr( 100, 'AUD' ) = '$1.00 DR' );
  Assert( DrCrStr( 100000, 'AUD' ) = '$1,000.00 DR' );
  Assert( DrCrStr( 0, 'AUD' ) = '$0.00' );
  Assert( DrCrStr( -1, 'AUD' ) = '$0.01 CR' );
  Assert( DrCrStr( -100, 'AUD' ) = '$1.00 CR' );
  Assert( DrCrStr( Unknown, 'AUD' ) = 'Unknown' );

  Assert( DrCrStr( 100, 'GBP' ) = '£1.00 DR' );
  Assert( DrCrStr( 100000, 'GBP' ) = '£1,000.00 DR' );
  Assert( DrCrStr( 0, 'GBP' ) = '£0.00' );
  Assert( DrCrStr( -1, 'GBP' ) = '£0.01 CR' );
  Assert( DrCrStr( -100, 'GBP' ) = '£1.00 CR' );
  Assert( DrCrStr( Unknown, 'GBP' ) = 'Unknown' );

  Assert( DrCrStr( 100, 'EUR' ) = '€1.00 DR' );
  Assert( DrCrStr( 100000, 'EUR' ) = '€1,000.00 DR' );
  Assert( DrCrStr( 0, 'EUR' ) = '€0.00' );
  Assert( DrCrStr( -1, 'EUR' ) = '€0.01 CR' );
  Assert( DrCrStr( -100, 'EUR' ) = '€1.00 CR' );
  Assert( DrCrStr( Unknown, 'EUR' ) = 'Unknown' );

  // --------------------------------------------------------------------------

  Assert( DrCrStrNoSymbol( 100 ) = '1.00 DR' );
  Assert( DrCrStrNoSymbol( 100000 ) = '1,000.00 DR' );
  Assert( DrCrStrNoSymbol( 0 ) = '0.00' );
  Assert( DrCrStrNoSymbol( -1 ) = '0.01 CR' );
  Assert( DrCrStrNoSymbol( -100 ) = '1.00 CR' );
  Assert( DrCrStrNoSymbol( Unknown ) = 'Unknown' );

End;

// ----------------------------------------------------------------------------

Initialization
  {$IFOPT D+} RunTests; {$ENDIF}
end.
