Unit GenUtils;
//------------------------------------------------------------------------------
{
   Title:       General Utilities

   Description:

   Remarks:    This unit contains all the general utility functions from D3Utils.

   Author:

}
//------------------------------------------------------------------------------
Interface

Uses
  Classes,
  StdCtrls,
  Controls,
  bkDefs,
  MoneyDef,
  Graphics,
  Math;

type
  String1 = String[1];
  String2 = String[2];
  String4 = String[4];
  String10 = String[10];

Function StrToIntSafe(S: string) : Integer;

Function StrCompare(s1, s2: ShortString) : Integer;

Function TrimSpacesAndQuotes(S: ShortString) : ShortString;

Function Money2Double(L: money) : double;
Function GSTRate2Double(L: money) : double;
Function Percent2Double(L: money) : double;
Function CreditRate2Double(L: money) : double;

Function Double2Money(D: double) : money;
Function Double2GSTRate(D: double) : money;
Function Double2Percent(D: double) : money;
Function Double2CreditRate(D: double) : money;

Function Money2Str(f: money) : string; overload;
Function Money2Str(f: money; Format : string) : string; overload;
const MoneyMask = '#,###,###,###.##';

Function Quantity2Str( q : money) : string; overload;
Function Quantity2Str( q : money; Format : string) : string; overload;

Function Percent2Str( q : money) : string; overload;
Function Percent2Str( q : money; Format : string) : string; overload;
const PercentMask = '###.####';

Function Money2Int( m : Money ) : integer;

Function Money2IntTrunc( m : Money ) : integer;

Function Int2Money( I : Integer) : Money;

Function Str2Long(S: string) : Integer;

Function Str2Word(S: string) : Word;

Function Str2Byte(S: string) : byte;

Function AddSlash(DirPath: string) : string;

Function RemoveSlash(const DirPath: string) : string;

Function FillRefce(m: string) : ShortString;

Function ReverseFields( Bank_Account_Number: ShortString ) : boolean;

function LongtoKey(L : Int64) : string4; overload;
function LongToKey(L : Integer) : string4; overload;

function ByteToKey(B : Byte) : String1;
function DoubleToKey(E : Extended) : String10;

function IsNumeric( const S : ShortString ): Boolean;

function ConstStr( Ch : char; N : integer) : ShortString;

function BooleanToYesNo( const B : Boolean ) : String;

Procedure ZTrim( VAR S : ShortString );

function MakeAmount(f: Comp):string;

function MakeAmountNoComma( f : Comp) : string;

function MakeCodingRef( S : String ): String;

function GetFormattedReference(Const T : pTransaction_Rec; Account_Type: Byte = 0): ShortString;

function SetFocusSafe( Control : TWinControl) : boolean;

function WrapTextIntoStringList(AOriginalText: string;  ALineLength: integer): TStringList;
function WrapText(AOriginalText: string;  ALineLength: integer): string;

function MakeCountryPrefix( whNo : byte) : String2;

function UseXlonSort : boolean;

function XlonCompare( Item1, Item2: Pointer): Integer;

function XlonSort( BkCode1, BkCode2 : ShortString) : integer;

function FormatCodeForXlonSort( Code : ShortString) : string;

function MakeStatementDetails( AccountNo, OtherParty, Particulars : string) : string;

function StripReturnCharsFromString( const Source : string; ReplaceWith : string) : string;

function PadStr( ExistingStr : string; Len : byte; PadChar : Char) : String;

function ForceSignToMatchAmount( aQuantity, aAmount : Money) : Money;

// #1701 - standardise handling of commas and put the ReplaceQuotes function in one place
function ReplaceCommas(s: string): string;

function ReplaceCommasAndQuotes(s: string): string;

function GetMaxNarrationLength: Integer;

function IsPrintableCharacters(s: string): Boolean;

function PadLeft(const s : string; const iWidth : integer; const c : char) : string;

function GetQuantityStringForExtract(q: Money; MaxExtract: Integer = 4): string;

function MyRoundTo(const AValue: Double; const ADigit: Integer): string;
function MyRoundDouble(const AValue: Double; const ADigit: Integer): Double;

function FontToStr(Font: TFont): string;

procedure StrToFont(Value: string; Font: TFont);

function FontStyleToStr(Value: TFontStyles): string;

function StrToFontStyle(FontStyle : String) : TFontStyles;

procedure PopUpCalendar(Owner:TEdit; var aDate : integer);

function GetCommaSepStrFromList(const Items : TStringList) : string; overload;
function GetCommaSepStrFromList(const Items : array of string) : string; overload;

function GetNumOfSubstringInString(Needle, Haystack: string) : integer; // Returns the number of occurrences of a substring (needle) in a string (haystack)
function GetMonthName(aMonth : integer) : string;

function FindFilesLike(aFilePath : string; aFileSearch : string) : Boolean;

function ReplaceIllegalFileChars(aInstr : string; aReplaceChar : char) : string;

function TrimedGuid(AGuid: TGuid): String;

function RemoveInvalidCharacters(aInString : string) : string;
function TrimNonCharValues(aInString : string) : string;

function RoundNumberExt(number, base: extended): extended;

function AddFillerData(aInString: string; aFiller: char; aLength : integer; aLeftSide : boolean): string;
function AddFillerSpaces(aInString: string; aLength : integer): string;
function InsFillerZeros(aInString: string; aLength : integer): string;
function RemoveNonNumericData(aInString : string; KeepSpaces: boolean = true) : string;
function FixJsonString(inString : string) : string;
function TrimLeadZ( const S : ShortString ) : ShortString;

function CombineInt32ToInt64( aHigh, aLow : integer ) : Int64;

function IsStringNumberInIntegerRange(aLow, aHigh : integer; InStr :string ) : boolean;


//******************************************************************************
Implementation

Uses
  SysUtils,
  ststrs,
  StDate,
  StrUtils,
  DirUtils,
  bkConst,
  RzPanel,
  Windows,
  RzPopups,
  bk5except,
  Globals,
  DecimalRounding_JH1,
  CountryUtils;

Const
  NUMERIC_PAD_CHAR = '0';
  FILLER_CHAR = ' ';

//------------------------------------------------------------------------------
function TrimedGuid(AGuid: TGuid): String;
begin
  // Trims the { and } off the ends of the Guid to pass to the server
  Result := midstr(GuidToString(AGuid),2,length(GuidToString(AGuid))-2);
end;

//------------------------------------------------------------------------------
Function StrToIntSafe(S: string) : Integer;
Begin { StrToIntSafe }
   Result := StrToIntDef(S, 0);
End; { StrToIntSafe }

//------------------------------------------------------------------------------
Function StrCompare(s1, s2: ShortString) : Integer;
{allows strcompare of delphi short strings only}
Begin { StrCompare }
   Result := ststrs.CompStrings(s1, s2);
End; { StrCompare }
//------------------------------------------------------------------------------
Function TrimSpacesAndQuotes(S: ShortString) : ShortString;
Begin { TrimSpacesAndQuotes }
   While (S[0] > #0) and (S[1] in [' ', '"']) Do
   Begin
      Delete(S, 1, 1)
   End { (S[0] > #0) and (S[1] in [' ', '"']) };
   While (S[0] > #0) and (S[Length(S)] in [' ', '"']) Do
   Begin
      S[0] := Pred(S[0])
   End { (S[0] > #0) and (S[Length(S)] in [' ', '"']) };
   Result := S;
End; { TrimSpacesAndQuotes }



//------------------------------------------------------------------------------
Function Money2Double(L: money) : double;
Begin { Money2Double }
   Result := L / 100;
End; { Money2Double }

Function GSTRate2Double(L: money) : double;
Begin { GSTRate2Double }
   Result := L / 10000;
End; { GSTRate2Double }

Function Percent2Double(L: money) : double;
Begin { Percent2Double }
   Result := L / 10000;
End; { Percent2Double }

Function CreditRate2Double(L: money) : double;
Begin { CreditRate2Double }
   Result := L / 10000;
End; { CreditRate2Double }

//------------------------------------------------------------------------------
Function Double2Money(D: double) : money;
Begin { Double2Money }
   Result := round(D * 100);
End; { Double2Money }

Function Double2GSTRate(D: double) : money;
Begin { Double2GSTRate }
   Result := round(D * 10000);
End; { Double2GSTRate }

Function Double2Percent(D: double) : money;
Begin { Double2Percent }
   Result := round(D * 10000);
End; { Double2Percent }

Function Double2CreditRate(D: double) : money;
Begin { Double2CreditRate }
   Result := round(D * 10000);
End; { Double2CreditRate }

//------------------------------------------------------------------------------
Function Money2Str(f: money) : string; overload;
Begin
   Result := SysUtils.FormatFloat('#,##0.00', f / 100);
End;

Function Money2Str(f: money; Format : string) : string; overload;
Begin
   Result := SysUtils.FormatFloat(Format, f / 100);
End;

Function Quantity2Str( q : money) : string; overload;
Begin
   Result := SysUtils.FormatFloat('#,##0.0000', q / 10000);
End;

Function Quantity2Str( q : money; format : string) : string; overload;
Begin
   Result := SysUtils.FormatFloat(Format, q / 10000);
End;

Function Percent2Str( q : money) : string; overload;
Begin
   Result := SysUtils.FormatFloat('#,##0.0000', q / 10000);
End;

Function Percent2Str( q : money; format : string) : string; overload;
Begin
   Result := SysUtils.FormatFloat(Format, q / 10000);
End;

function PadLeft(const s : string; const iWidth : integer; const c : char) : string;
begin
  Result := s;
  while Length(Result) < iWidth do
    Result := c + Result;
end;

function GetQuantityStringForExtract(q: Money; MaxExtract: Integer = 4): string;
var
  i: Integer;
  f: string;
begin
  f := '0';
  if (Globals.PRACINI_ExtractDecimalPlaces > 0) and (MaxExtract > 0) then
  begin
    f := f + '.';
    for i := 1 to Globals.PRACINI_ExtractDecimalPlaces do
    begin
      f := f + '0';
      if i >= MaxExtract then
        Break;
    end;
  end;
  Result := SysUtils.FormatFloat('#' + f, q / 10000);
end;

//------------------------------------------------------------------------------
Function Str2Long(S: string) : Integer;
Var
   err,
   v   : Integer;
Begin { Str2Long }
   Result := 0;
   Try
      val(S, v, err);
      If err = 0 Then
      Begin
         Result := v
      End { err = 0 };
   Except
;
   End { try };
End; { Str2Long }



//------------------------------------------------------------------------------
Function Str2Word(S: string) : Word;
Var
   i : Integer;
Begin { Str2Word }
   Result := 0;

   i := Str2Long(S);
   If (i >= 0) and (i <= 65535) Then
   Begin
      Result := i
   End { (i >= 0) and (i <= 65535) };
End; { Str2Word }



//------------------------------------------------------------------------------
Function Str2Byte(S: string) : byte;
Var
   i : Integer;
Begin { Str2Byte }
   Result := 0;

   i := Str2Long(S);
   If (i >= 0) and (i <= 255) Then
   Begin
      Result := i
   End { (i >= 0) and (i <= 255) };
End; { Str2Byte }

//------------------------------------------------------------------------------
Function AddSlash(DirPath: string) : string;
Begin { AddSlash }
   Result := DirPath;
   If (DirPath <> '') and (Copy(DirPath, Length(DirPath), 1) <> '\') Then
   Begin
      Result := DirPath + '\'
   End { (DirPath <> '') and (Copy(DirPath, Length(DirPath), 1) <> '\') }
End; { AddSlash }

//------------------------------------------------------------------------------
Function RemoveSlash(const DirPath: string) : string;
Begin
   Result := DirPath;
   If (DirPath <> '') and (Copy(DirPath, Length(DirPath), 1) = '\') Then
      Result := Copy(DirPath, 1, Length(DirPath) - 1);
End;


//------------------------------------------------------------------------------
Function FillRefce(m: string) : ShortString;
Const
   Blank = '            ';
   zero = '000000000000';
{123456789012}
Var
   S         : ShortString;
Begin { FillRefce }
   S := m;
   While (S[0] > #0) and (S[1] = ' ') Do
   Begin
      Delete(S, 1, 1)
   End { (S[0] > #0) and (S[1] = ' ') };
   While (S[0] > #0) and (S[Length(S)] = ' ') Do
   Begin
      S[0] := Pred(S[0])
   End { (S[0] > #0) and (S[Length(S)] = ' ') };

   If IsNumeric( S ) Then
   Begin
      While Length(S) < 12 Do
      Begin
         S := '0' + S
      End { Length(S) < 12 }; (* Right Justify *)
      If S = zero Then
      Begin
         FillRefce := Blank
      End { S = zero }
      Else
      Begin
         FillRefce := S
      End { not (S = zero) };
   End { IsNumeric }
   Else
   Begin (* Leave as is *)
      FillChar(S, Sizeof(S), #$20);
      If Length(m) > 0 Then
      Begin
         Move(m[1], S[1], Length(m))
      End { Length(m) > 0 };
      S[0] := Chr(12);
      If S = zero Then
      Begin
         FillRefce := Blank
      End { S = zero }
      Else
      Begin
         FillRefce := S
      End { not (S = zero) };
   End { not (IsNumeric) };
End; { FillRefce }
//------------------------------------------------------------------------------

Function ReverseFields( Bank_Account_Number: ShortString ) : boolean;
{ Only call this for a NZ Account }
begin
   Result := Copy(Bank_Account_Number, 1, 6) = '700001';
end;

//------------------------------------------------------------------------------

Function MakeComment(reverse: boolean; OtherParty, Particulars: string) : string;
Var
   US1,
   US2 : String[20];
Begin { MakeComment }
   Particulars := Trim(Particulars);
   US1 := Uppercase(Particulars);
   OtherParty := Trim(OtherParty);
   US2 := Uppercase(OtherParty);

   If reverse Then
   Begin
      Result := Particulars;
      If (OtherParty <> '') and (Pos(US1, US2) = 0) Then
      Begin
         If Particulars <> '' Then
         Begin
            Result := Result + ' ' + OtherParty
         End
         Else
         Begin
            Result := OtherParty
         End
      End;
   End { reverse }
   Else
   Begin
      Result := OtherParty;
      If (Particulars <> '') and (Pos(US1, US2) = 0) Then
      Begin 
         If OtherParty <> '' Then 
         Begin 
            Result := Result + ' ' + Particulars 
         End
         Else 
         Begin
            Result := Particulars
         End
      End;
   End { not (reverse) };
   MakeComment := Result;
End; { MakeComment }

{-----------------------------------------------------------------}

function LongtoKey( L : Int64 ) : string4; overload;
//convert a 64bit integer into a 4 char string, only the low 32bits are used
//if int64 not used then money values over 21,474,436,48 can't be sorted
//In D5 Trunc() returns an int64 so truncations a money amount may cause an error
//Overload is being used so compiler doesnt need to convert types in most cases.
var
   W : LongWord Absolute L;
   B : Array[0..3] of char Absolute L;
begin
   W := W xor $80000000;
   result[0] := #4;
   result[1] := B[3];
   result[2] := B[2];
   result[3] := B[1];
   result[4] := B[0];
end;
//------------------------------------------------------------------------------

function LongToKey(L : Integer) : string4; overload;
{convert a longint to a short string}
var
   W : LongWord Absolute L;
   B : Array[0..3] of char Absolute L;
begin
   W := W xor $80000000;
   result[0] := #4;
   result[1] := B[3];
   result[2] := B[2];
   result[3] := B[1];
   result[4] := B[0];
end;

//------------------------------------------------------------------------------

function ByteToKey(B : Byte) : String1;
{-Convert a byte to a string}
  begin
    ByteToKey[0] := #1;
    ByteToKey[1] := Char(B);
  end;
//------------------------------------------------------------------------------

procedure ReverseBytes(var V; Size : Word); assembler;
  {-Reverse the ordering of bytes from V[1] to V[Size]. Size must be >= 2.}
  asm
    push ebx
    movzx edx, dx
    mov ecx, eax
    add ecx, edx
    dec ecx
    shr edx, 1
  @@Again:
    mov bl, [eax]
    xchg bl, [ecx]
    mov [eax], bl
    inc eax
    dec ecx
    dec edx
    jnz @@Again
    pop ebx
  end;

  {--------}

procedure ToggleBits(var V; Size : Word); assembler;
  {-Toggle the bits from V[1] to V[Size]}
  asm
    movzx edx, dx
  @@Again:
    not byte ptr [eax]
    inc eax
    dec edx
    jnz @@Again
  end;


function DoubleToKey(E : Extended) : String10;
    {-Convert an extended to a string}
  const
    Temp :
      record case Byte of
        0 : (Len : Byte; EE : Extended);
        1 : (XXX, Exp : Byte);
        2 : (Str : String10);
      end = (Str : '          ');
  begin
    Temp.EE := E;

    {move the exponent to the front and put mantissa in MSB->LSB order}
    ReverseBytes(Temp.EE, 10);

    {flip the sign bit}
    Temp.Exp := Temp.Exp xor $80;

    if Temp.Exp and $80 = 0 then begin  {!!.04}
      ToggleBits(Temp.EE, 10);          {!!.04}
      Temp.Exp := Temp.Exp and $7F;     {!!.04}
    end;                                {!!.04}

    DoubleToKey := Temp.Str;
  end;

function IsNumeric( const S : ShortString ): Boolean;
var
   i : Byte;
begin
   if Length( S ) = 0 then
   Begin
      Result := False;
      Exit;
   end;

   Result := True;
   For i := 1 to Length( S ) Do
   Begin
      If not ( S[ i ] in ['0'..'9']) then
      begin
         Result := False;
         Exit;
      end;
   end;
end;
//------------------------------------------------------------------------------

function ConstStr( Ch : char; N : integer) : ShortString;
begin
   FillChar( Result, SizeOf( Result ), Ch );
   Result[0] := chr( N );
end;
//------------------------------------------------------------------------------

function BooleanToYesNo( const B : Boolean ) : String;
begin
   Result := 'No';
   If B then
      Result := 'Yes';
end;
//------------------------------------------------------------------------------

Procedure ZTrim( VAR S : ShortString );
  { Remove leading and trailing spaces and any leading zeros.}
var
  I    : Word;
begin
  If S[0]=#0 then exit;
  while (Length(S) > 0) and (S[Length(S)] = ' ') do
    Dec(S[0]);
  I := 1;
  while (I <= Length(S)) and (( S[I] = ' ') or ( S[I]='0')) do
    Inc(I);
  Dec(I);
  if I > 0 then
    Delete(S, 1, I);
end;
//------------------------------------------------------------------------------
function Money2Int( m : Money ) : integer;
//takes a money value and return a dollar portion
//div money by 100 then round
begin
   result := Round( M / 100);
end;
//------------------------------------------------------------------------------

function Money2IntTrunc( m : Money ) : integer;
//takes a money value and return a dollar portion
//div money by 100 then truncate
begin
   result := Trunc( M / 100);
end;
//------------------------------------------------------------------------------

function Int2Money( I : Integer) : Money;
//takes a money value and return a dollar portion
//div money by 100 then round
begin
  //this assign is needed so that the Integer is cast as a Money type before
  //the multiplication takes place.
  Result := I;
  Result := (Result * 100)
end;
//------------------------------------------------------------------------------

function MakeAmount(f: Comp):string;
begin
   result := FormatFloat('#,##0.00;(#,##0.00)',f/100);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MakeAmountNoComma( f : Comp) : string;
begin
   result := FormatFloat('0.00;(0.00)',f/100);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MakeCodingRef( S : String ): String;
//if this is a number then remove leading zeros, for use in coding screen
begin
   result := S;
   if IsNumeric( S ) then begin
      {remove leading zeros}
      while ( Length( S )>0 ) and ( S[1]='0' ) do System.Delete(S,1,1);
      result:=S ;
   end;
end;
//------------------------------------------------------------------------------

function TrimLeadZ( const S : ShortString ) : ShortString;
{  Summary: Return a string with leading zeros removed
}
var
  I : Cardinal;
begin
  if S='' then
  begin
    result:='';
    exit;
  end;
  I := 1;
  while (I < Length(S)) and (S[I]='0' ) do
    Inc(I);
  Move( S[I], Result[1], Length( S ) - I + 1 );
  Result[0] := Char(Length(S)-I+1);
end;

//------------------------------------------------------------------------------
function CopyRightAbsS(const S : ShortString; NumChars : Cardinal) : ShortString;
  {-Return NumChar characters starting from end}
begin
  if (Length(S) > NumChars) then
    Result := Copy(S, (Length(S) - NumChars)+1, NumChars)
  else
    Result := S;
end;

//------------------------------------------------------------------------------

function GetFormattedReference(Const T : pTransaction_Rec; Account_Type: Byte = 0): ShortString;

Var
  Refce: String[12];

Const
  MaxChqNo = 100000000; { Eight Digits }

    // -------------------------------------------------------------------------
    {
    Function Str12( I : Integer ): ShortString;
    Begin
       Str( ( I mod MaxChqNo ):12, Result );
    end;
    }
    // -------------------------------------------------------------------------

    Function Str8( I : Integer ): ShortString;
    Begin
       Str( ( I mod MaxChqNo ):8, Result );
    end;

    // -------------------------------------------------------------------------

begin
  { We are filling a 12 character field }

  With T^ do
  Begin
     Refce := TrimLeadZ( TrimS( txReference ) );

     Case txUPI_State of
        upNone         :
           Begin
              If txCheque_Number > 0 then
                 Result := IntToStr( txCheque_Number)
              else
                 Result := Refce;
           end;

        upUPC,
        upMatchedUPC,
        upReversedUPC,
        upReversalOfUPC : Result := upNames[ txUPI_State ] + Str8( txCheque_Number );

        //may not have a cheque number because may not be cheque type
        upBalanceOfUPC : begin
           if txCheque_Number > 0 then
              Result := upNames[ txUPI_State ] + Str8( txCheque_Number )
           else begin
              Refce    := CopyRightAbsS( Refce, 8 );
              Result   := upNames[ txUPI_State ] + LeftPadChS( Refce, ' ', 8 );
           end;
        end;

        upUPD,
        upMatchedUPD,
        upBalanceOfUPD,
        upReversedUPD,
        upReversalOfUPD :
           Begin
              Refce    := CopyRightAbsS( Refce, 8 );
              Result   := upNames[ txUPI_State ] + LeftPadChS( Refce, ' ', 8 );
           end;

        upUPW,
        upMatchedUPW,
        upBalanceOfUPW,
        upReversedUPW,
        upReversalOfUPW :
           Begin
              Refce    := CopyRightAbsS( Refce, 8 );
              Result   := upNames[ txUPI_State ] + LeftPadChS( Refce, ' ', 8 );
           end;

        else
           Raise EDataIntegrity.CreateFmt( 'Unknown txUPI_State %d in GetFormatted Reference', [ txUPI_State ] );
     end;
  end;
  if Result = '' then
    if Account_Type in [btCashJournals..btStockBalances] then
{$IFNDEF LOOKUPDLL}
      if Assigned(MyClient) then
        Result := Localise(MyClient.clFields.clCountry, btReferences[Account_Type])
      else
{$ENDIF}
        Result := btReferences[Account_Type];

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SetFocusSafe( Control : TWinControl) : boolean;
begin
   result := false;
   try
      Control.SetFocus;
      result := true;
   except
      On E : EInvalidOperation do ;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function WrapTextIntoStringList(AOriginalText: string;  ALineLength: integer): TStringList;
var
  i, j : integer;
  s1, s2 : String;
begin
  Result := TStringList.Create;
  Result.Text := AOriginalText;

  i := 0;
  while i < Result.Count do
  begin
    if Length (Trim (Result[i])) > ALineLength then
    begin
      s1 := Trim (Result[i]);
      s2 := '';
      j := ALineLength;
      while j > 0 do
      begin
        if s1[j] = ' ' then
          break;
        Dec (j);
      end;

      //There were no spaces
      if j <= 0 then
      begin
        s2 := Copy (s1, ALineLength + 1, Length (s1));
        s1 := Copy (s1, 1, ALineLength);
      end
      else
      begin
        s2 := Copy (s1, j + 1, Length (s1));
        s1 := Copy (s1, 1, j);
      end;

      Result[i] := s1;
      Result.Insert (i + 1, s2);
    end;

    Inc (i);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function WrapText(AOriginalText: string;  ALineLength: integer): string;
var
  strList : TStringList;
begin
  Result := '';
  strList := WrapTextIntoStringList(AOriginalText, ALineLength);
  try
    Result := strList.text;
  finally
    FreeAndNil(strList);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MakeCountryPrefix( whNo : byte) : String2;
begin
   case whNo of
      whNewZealand : result := 'NZ';
      whAustralia  : result := 'AU';
      whUK         : result := 'UK';
   else
      raise EInvalidCall.Create( 'Unknown country passed to MakeCountryPrefix');
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function UseXlonSort : boolean;
begin
{$IFNDEF LOOKUPDLL}
  if not Assigned(MyClient) then
    Result := False
  else
    //see if xlon sort needed
    Result := ( MyClient.clFields.clCountry = whAustralia) and
              ( MyClient.clFields.clAccounting_System_Used = saXlon) and
              ( Globals.PRACINI_UseXLonChartOrder);
{$ENDIF}              
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function FormatCodeForXlonSort( Code : ShortString) : string;
// xlon chart codes are imported into banklink in the following format
//
//          b/dd.ccc-ss       b    = branch no
//                            dd   = division no
//                            ccc  = chart code
//                            ss   = sub code
//
// chart codes are normally sorted alphabetically in banklink however this
// makes it very difficult for an xlon user to setup reporting.  If the user
// selects xlon sorting then the chart is sorted by:
//        chart code
//        branch
//        division
//        sub code
const
  PAD_LENGTH = 5;
var
  sBranch, sDivision: ShortString;
  sCode: ShortString;
  sSubCode: ShortString;
  iCode: Integer;
  p: integer;
  PadChar: Char;
begin
  //Formats the account code so that it can be sorted
  Result    := '';
  sBranch   := '';
  sDivision := '';
  sCode     := '';
  sSubCode  := '';

  sCode := Code;
  //Branch
  p := Pos('/', sCode);
  if p > 0 then begin
    sBranch := Copy(sCode, 1, (p - 1));
    sCode := Copy(sCode, (p + 1), Length(sCode));
  end;
  //Division
  p := Pos('.', sCode);
  if p > 0 then begin
    sDivision := Copy(sCode, 1, (p - 1));
    sCode := Copy(sCode, (p + 1), Length(sCode));
  end;
  //Code / Sub Code
  p := Pos('-', sCode);
  if p > 0 then begin
    sSubCode := Copy(sCode, (p + 1), Length(sCode));
    sCode := Copy(sCode, 1, (p - 1));
  end else
    sSubCode := '';

  PadChar   := '0';
  if not TryStrToInt(sCode, iCode) then
    PadChar := 'A'; // So alpha codes come after numeric

  Result := LeftPadChS(sCode,     PadChar, PAD_LENGTH) +
            LeftPadChS(sBranch,   PadChar, PAD_LENGTH) +
            LeftPadChS(sDivision, PadChar, PAD_LENGTH) +
            LeftPadChS(sSubCode,  PadChar, PAD_LENGTH); 
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function XlonCompare( Item1, Item2: Pointer): Integer;
begin
  Result := XlonSort(pAccount_Rec(Item1)^.chAccount_Code,
                     pAccount_Rec(Item2)^.chAccount_Code);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function XlonSort( BkCode1, BkCode2 : ShortString) : integer;
var
  S1 : ShortString;
  S2 : ShortString;
begin
  //Replaces Xlon sort below
  S1 := FormatCodeForXlonSort(BkCode1);
  S2 := FormatCodeForXlonSort(BkCode2);
  Result := StStrS.CompStringS( S1, S2 );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MakeStatementDetails( AccountNo, OtherParty, Particulars : string) : string;
//this function is used to create a statement details field for transactions
//in which were downloaded prior to the addition of a statement details field
//in the production disk image
begin
  result := MakeComment( ReverseFields( AccountNo), OtherParty, Particulars);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function StripReturnCharsFromString( const Source : string; ReplaceWith : string) : string;
//remove #13 and #10 chars from source string, replace with|
var
   p : integer;
   WorkingText : string;
begin
   WorkingText := Source;

   if ReplaceWith = '' then
     ReplaceWith := ' ';

   //remove #13#10 first
   p := Pos( #13 + #10, WorkingText);
   while ( p > 0) do begin
      WorkingText := Copy( WorkingText, 1, p - 1) + ReplaceWith +
                     Copy( WorkingText, p + 2, length( WorkingText));
      p := Pos( #13 + #10, WorkingText);
   end;
   //remove #13's
   p := Pos( #13, WorkingText);
   while ( p > 0) do begin
      WorkingText := Copy( WorkingText, 1, p - 1) + ReplaceWith +
                     Copy( WorkingText, p + 1 , length( WorkingText));
      p := Pos( #13, WorkingText);
   end;
   //now remove #10
   p := Pos( #10, WorkingText);
   while ( p > 0) do begin
      WorkingText := Copy( WorkingText, 1, p - 1) +
                     Copy( WorkingText, p + 1, length( WorkingText));
      p := Pos( #10, WorkingText);
   end;
   result := WorkingText;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function PadStr( ExistingStr : string; Len : byte; PadChar : Char) : String;
var
  S : ShortString;
begin
  S := StringOfChar( PadChar, Len);
  if Length( ExistingStr) < Len then
    Result := StuffString( S, 1, Length( ExistingStr), ExistingStr)
  else
    Result := ExistingStr;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ForceSignToMatchAmount( aQuantity, aAmount : Money) : Money;
//the sign of the quantity amount must be changed to match the sign of the amt
begin
  if ( aAmount >= 0) then
    //amount is positive
    result := Abs( aQuantity)
  else
    //amount is negative
    result := Abs( aQuantity) * -1;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function ReplaceCommas(s: string): string;
begin
  Result := StringReplace(s, ',', ' ', [rfReplaceAll]);
end;

function ReplaceCommasAndQuotes(s: string): string;
begin
  Result := StringReplace(s, '"', '', [rfReplaceAll]);
  Result := ReplaceCommas(Result);
end;

function GetMaxNarrationLength: Integer;
begin
  if Assigned(AdminSystem) then
  begin
    if AdminSystem.fdFields.fdMaximum_Narration_Extract = 0 then
      Result := 200
    else
      Result := AdminSystem.fdFields.fdMaximum_Narration_Extract;
  end
  else
    Result := INI_MAX_EXTRACT_NARRATION_LENGTH;
end;

// Make sure a string contains only printable ASCII characters
function IsPrintableCharacters(s: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := 1 to Length(s) do
    // Allow French characters
    if (Ord(s[i]) < 32) or (Ord(s[i]) > 175) then
    begin
      Result := False;
      Break;
    end;
end;

function MyRoundTo(const AValue: Double; const ADigit: Integer): string;
var
  X: Integer;
begin
  Result := FloatToStr(DecimalRoundDbl(AValue, ADigit, drHalfPos));
  // Add a zero on the end if required. e.g. 19.8 -> 19.80
  X := Pos('.', Result);
  if (X > 0) and (Length(Copy(Result, X, 3)) = 2) then
    Result := Result + '0';
end;

function MyRoundDouble(const AValue: Double; const ADigit: Integer): Double; overload;
begin
  result := DecimalRoundDbl(AValue, ADigit, drHalfPos);
end;
//
// Converts a fonts attributes into string representation.
//
function StrToFontStyle(FontStyle : String) : TFontStyles;
begin
  Result := [];
  if (Pos('B',FontStyle) > 0) then
    Result := Result + [fsBold];
  if (Pos('I',FontStyle) > 0) then
    Result := Result + [fsItalic];
  if (Pos('U',FontStyle) > 0) then
    Result := Result + [fsUnderline];
  if (Pos('S',FontStyle) > 0) then
    Result := Result + [fsStrikeOut];
end;

function FontStyleToStr(Value: TFontStyles): string;
begin
   Result := '';
   if (fsBold in Value) then
      Result := Result + 'B';
   if (fsItalic in Value) then
      Result := Result + 'I';
   if (fsUnderline in Value) then
      Result := Result + 'U';
   if (fsStrikeOut in Value) then
      Result := Result + 'S';
end;


function FontToStr(Font : TFont) : String;

begin
  if (Assigned(Font)) then begin
     //name, style, size, Colour
    Result :=
      '"' + Font.Name + '","' + FontStyleToStr(Font.Style) +
      '",' + IntToStr(Font.Size);
    if not ((Font.Color = clBlack) or (Font.Color = clWindowText)) then
       Result := result + ',' + IntToStr(Font.Color);
  end else
    Result := '';
end;

procedure StrToFont(Value: string; Font: TFont);
var TextLines: TStringList;
    C: integer;
begin
   TextLines := TStringList.Create;
   try
      TextLines.CommaText := Value;
      c := Textlines.Count;
      if c = 0 then exit;
      Font.Name := TextLines[0];
      if c = 1 then exit;
      Font.Style := StrToFontStyle(TextLines[1]);
      if c = 2 then exit;
      Font.Size := StrToInt(TextLines[2]);
      if c = 3 then exit;
      Font.Color := StrToInt(TextLines[3]);
   finally
      TextLines.Free;
   end;
end;


procedure PopUpCalendar(Owner:Tedit; var aDate : integer);
var
  PopupPanel: TRzPopupPanel;
  Calendar: TRzCalendar;
begin
  PopupPanel := TRzPopupPanel.Create(Owner);
  try

    Calendar := TRzCalendar.Create(PopupPanel);
    Calendar.Font := Owner.Font;
    Calendar.Parent := PopupPanel;
    PopupPanel.Parent := Owner;

    Calendar.IsPopup := True;
    Calendar.Color := Owner.Color;
    Calendar.Elements := [ceYear,ceMonth,ceArrows,ceDaysOfWeek,ceFillDays,ceTodayButton,ceClearButton];
    Calendar.FirstDayOfWeek := fdowLocale;
    Calendar.Handle; // Creates the handle

    if aDate <> 0 then
      Calendar.Date := StDate.StDateToDateTime( aDate);

    //Calendar.BorderOuter := fsFlat;
    Calendar.Visible := True;
    Calendar.OnClick := PopupPanel.Close;

    if PopupPanel.Popup(Owner) then
       if ( Calendar.Date <> 0 ) then
          aDate := StDate.DateTimeToStDate(Calendar.Date)
       else
         aDate := 0;
  finally
    PopupPanel.Free;
  end;
end;

// Returns a string containing the elements of a TStringList like so:
// [a] becomes 'a'
// [a,b] becomes 'a and b'
// [a,b,c] becomes 'a, b, and c'
function GetCommaSepStrFromList(const Items : TStringList) : string;
var
  ItemArr   : array of string;
  ItemIndex : integer;
begin
  Setlength(ItemArr, Items.Count);

  for ItemIndex := 0 to Items.Count - 1 do
    ItemArr[ItemIndex] := Items.Strings[ItemIndex];

  Result := GetCommaSepStrFromList(ItemArr);

  Setlength(ItemArr, 0);
end;

function GetCommaSepStrFromList(const Items : array of string) : string;
var
  ItemCount : integer;
  ItemIndex : integer;
begin
  Result := '';
  ItemCount := Length(Items);

  case ItemCount of
    0 : Exit;
    1 : Result := Items[0];
    2 : Result := Items[0] + ' and ' + Items[1];
    else
    begin
      for ItemIndex := 0 to ItemCount - 2 do
        Result := Result + Items[ItemIndex] + ', ';

      Result := Result + 'and ' + Items[ItemCount - 1];
    end;
  end;
end;

// Returns the number of occurrences of a substring (needle) in a string (haystack)
function GetNumOfSubstringInString(Needle, Haystack: string) : integer;
var
  sTmp: String;
begin
  sTmp := StringReplace(Haystack, Needle, '', [rfReplaceAll]);
  Result := Floor((Length(Haystack) - Length(sTmp))/Length(Needle));
end;

function GetMonthName(aMonth : integer) : string;
begin
  Result := FormatDateTime('mmmm', EncodeDate(2000,aMonth,1));
end;

function FindFilesLike(aFilePath : string; aFileSearch : string) : Boolean;
var
  SearchRec : TSearchRec;
  FileAttrs: Integer;
  FullSearch : string;
begin
  Result := False;
  FileAttrs := faAnyFile;
  FullSearch := AppendFileNameToPath(aFilePath, aFileSearch);
  try
    if SysUtils.FindFirst(FullSearch, FileAttrs, SearchRec) = 0 then
      Result := True;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

function ReplaceIllegalFileChars(aInstr : string; aReplaceChar : char) : string;
const
  ILLEGAL_CHARS = '<>:"/\|?*';
var
  CharIndex, StrIndex : integer;
  Found : boolean;
begin
  Result := '';
  for StrIndex := 1 to length(aInstr) do
  begin
    Found := false;
    for CharIndex := 1 to length(ILLEGAL_CHARS) do
    begin
      if aInstr[StrIndex] = ILLEGAL_CHARS[CharIndex] then
      begin
        Found := true;
        break;
      end;
    end;

    if Found then
      Result := Result + aReplaceChar
    else
      Result := Result + aInstr[StrIndex];
  end;
end;

//-----------------------------------------------------------------
function RemoveInvalidCharacters(aInString : string) : string;
var
  Index : integer;
begin
  Result := '';
  for Index := 1 to length(aInString) do
    if not (aInString[Index] in ['/',':','\','/','*','"','<','>','|','~','?',',']) then
      Result := Result + aInString[Index];
end;

//-----------------------------------------------------------------
function TrimNonCharValues(aInString : string) : string;
var
  Index : integer;
  Start : boolean;
  TempStr : string;
begin
  Start := false;
  TempStr := '';
  for Index := 1 to length(aInString) do
  begin
    if (not start) and
       (aInString[Index] in ['A'..'Z','a'..'z','0'..'9']) then
      Start := true;

    if Start then
      TempStr := TempStr + aInString[Index];
  end;

  Start := false;
  Result := '';
  for Index := length(TempStr) downto 1 do
  begin
    if (not start) and
       (TempStr[Index] in ['A'..'Z','a'..'z','0'..'9']) then
      Start := true;

    if Start then
      Result := TempStr[Index] + Result;
  end;
end;

// Thanks to Piotr for this one
function RoundNumberExt(number, base: extended): extended;
{Rounds number to the given base}
const
  half: extended = 0.49999999; // There are rounding errors in the fp calculator...
var
  quot: extended;
begin
  if base > 0 then
    begin
      if number < 0 then // Handle negative numbers
        base := -base;
      quot := number / base;
      if Frac(quot) < half then
        result := Int(quot) * base
      else
        result := (Int(quot) + 1) * base;
    end
  else
    result := number;
end;

//------------------------------------------------------------------------------
function AddFillerData(aInString: string; aFiller: char; aLength : integer; aLeftSide : boolean): string;
var
  FillerIndex : integer;
  FillerString : string;
  InStrLength : integer;
begin
  InStrLength := length(aInString);
  Result := aInString;

  if InStrLength >= aLength then
    Exit;

  FillerString := '';
  for FillerIndex := (InStrLength + 1) to aLength do
    FillerString := FillerString + aFiller;

  if aLeftSide then
    Result := FillerString + Result
  else
    Result := Result + FillerString;
end;

//------------------------------------------------------------------------------
function AddFillerSpaces(aInString: string; aLength: integer): string;
begin
  Result := AddFillerData(aInString, FILLER_CHAR, aLength, false);
end;

//------------------------------------------------------------------------------
function InsFillerZeros(aInString: string; aLength: integer): string;
begin
  Result := AddFillerData(aInString, NUMERIC_PAD_CHAR, aLength, true);
end;

//------------------------------------------------------------------------------
function RemoveNonNumericData(aInString: string; KeepSpaces: boolean = true): string;
var
  Index : integer;
begin
  Result := '';
  for Index := 1 to Length(aInString) do
  begin
    if ((aInString[Index] >= '0') and (aInString[Index] <= '9')) or
       ((aInString[Index] = ' ') and KeepSpaces) then
    begin
      Result := Result + aInString[Index];
    end;
  end;
end;

//----------------------------------------------------------------------------
function FixJsonString(inString : string) : string;
var
  Index : integer;
  LenStr : integer;
begin
  LenStr := Length(inString);
  Result := '';
  for Index := 1 to LenStr do
  begin
    if (Index < LenStr) and
       (inString[Index] = '\') and
       (inString[Index+1] = '/') then
      Continue;

    Result := Result + inString[Index];
  end;
end;

{  -----------------------------------------------------------------------  }
function CombineInt32ToInt64( aHigh, aLow : integer ) : Int64;
var
  High : int64;
  Low  : int64;
begin
  Low  := aLow;
  High := aHigh;

//The CORE dump uses a 62bit Integer (2 most significant bits are lost) split
//into two 31bit integers
  result := (High shl 31 ) or Low;
end;

function IsStringNumberInIntegerRange(aLow, aHigh : integer; InStr :string ) : boolean;
var
  li : integer;
begin
  result := false;
  for li := aLow to aHigh do begin
    result := pos( intToStr( li ), InStr ) <> 0;
    if result then
      exit;
  end;
end;

End.
