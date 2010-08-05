unit GenUtils;

interface

uses
   stDate, moneydef, ecdefs;

const
   Epoch = 1970;

type
  TCharSet = set of Char;
  
function bkStr2Date( DateStr: string ) : tStDate;
function bkDate2Str( ADate: tStDate) : string;
function MakeAmountStr( f: Comp):string;
function MakeQuantityStr( f: Comp):string;

Function Money2Double(L: money) : double;
Function Double2Money(D: double) : money;
Function Money2Str(f: money) : string;
Function Money2Int( m : Money ) : integer;
Function Money2IntTrunc( m : Money ) : integer;
Function Int2Money( I : Integer) : Money;
function Double2percent(Value: Double): Money;
function Percent2Double(Value: Money): Double;

function IsNumeric( const S : ShortString ): Boolean;
function StrToFloatDef( s : string; def : double) : double;
function RemoveCharsFromString( S : String; Chars : TCharSet): String;

function GetFormattedReference(Const T : pTransaction_Rec): ShortString;


implementation

uses
   stDateSt,
   stStrs,
   SysUtils,
   bkConst;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function bkStr2Date( DateStr: string ) : tStDate;
{ Returns 0 for a null date, -1 for an invalid date }
Begin
   if DateStr = '' then
      Result := 0
   else
      Result := StDateSt.DateStringToStDate( 'dd/mm/yy', DateStr, Epoch );
End;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function Date2Str( ADate: tStDate; APicture : ShortString ) : ShortString;
Begin
   If ADate <= 0 then
      Result := '' { Bad date or null date }
   Else
      Result := StDateSt.StDateToDateString( APicture, ADate, False );
End;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function bkDate2Str(ADate: tStDate) : string;
begin
   bkDate2Str := Date2Str( ADate, 'dd/mm/yy' );
End;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MakeAmountStr( f: Comp):string;
begin
   result := FormatFloat('#,##0.00;(#,##0.00)',f/100);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MakeQuantityStr( f: Comp):string;
begin
   result := FormatFloat('#,##0.####',f/10000);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function Money2Double(L: money) : double;
Begin
   Result := L / 100;
End;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function Double2Money(D: double) : money;
Begin
   Result := round(D * 100);
End;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
const PercentScale = 10000.0;

function Double2percent(Value: Double): Money;
begin
   Result := round(Value * PercentScale);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function Percent2Double(Value: Money): Double;
begin
   Result := Value;
   Result := Result / PercentScale;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function Money2Str(f: money) : string;
Begin
   Result := SysUtils.FormatFloat('#,##0.00', f / 100);
End;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function Money2Int( m : Money ) : integer;
//takes a money value and return a dollar portion
//div money by 100 then round
begin
   result := Round( M / 100);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function Money2IntTrunc( m : Money ) : integer;
//takes a money value and return a dollar portion
//div money by 100 then truncate
begin
   result := Trunc( M / 100);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function Int2Money( I : Integer) : Money;
//takes a money value and return a dollar portion
//div money by 100 then round
begin
   result := I * 100;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetFormattedReference(Const T : pTransaction_Rec): ShortString;

Var
  Refce: String[12];

Const
  MaxChqNo = 100000000; { Eight Digits }

    // -------------------------------------------------------------------------

    Function Str12( I : Integer ): ShortString;
    Begin
       Str( ( I mod MaxChqNo ):12, Result );
    end;

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
                 Result := Str12( txCheque_Number )
              else
                 Result := LeftPadChS( Refce, ' ', 12 );
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
           Raise Exception.CreateFmt( 'Unknown txUPI_State %d in GetFormatted Reference', [ txUPI_State ] );
     end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function IsNumeric( const S : ShortString ): Boolean;
var
  Value : Double;
  Code : Integer;
begin
  Val(S, Value, Code);
  Result := ((Code = 0) and (Value <> 0));
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function StrToFloatDef( s : string; def : double) : double;
var
   s1     : string;
   p      : integer;
begin
   result := def;
   s1     := s;
   try
      //strip ( and )
      if (Pos( '(', s)) > 0 then begin
         p := Pos( '(',s);
         s1 := Copy( s, p + 1, length( s));
         p := Pos( ')', s1);
         s1 := Copy( s1, 1, p - 1);
         S1 := '-' + s1;
      end;
      //strip comma
      p := pos(',', s1);
      while ( p > 0) do begin
         s1 := Copy( s1, 0, p - 1) + Copy( s1, p + 1, length( s1));
         p := pos(',', s1);
      end;
      result := StrToFloat( s1);
   except
      on E : EConvertError do begin
         exit;
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function RemoveCharsFromString( S : String; Chars : TCharSet): String;
var
  i : Integer;
begin
  Result := '';
  for i := 1 to length(S) do
    if not (S[i] in Chars) then
      Result := Result + S[i];
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
