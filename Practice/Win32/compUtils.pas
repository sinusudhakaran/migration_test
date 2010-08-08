unit compUtils;
//------------------------------------------------------------------------------
{
   Title:       Comparison utilities.

   Description: Functions to compare numbers and strings. Used to sort list
                elements. Compare parameters P1 and P2 and always return:
                 1   if P1>P2
                 -1  if P1<P2
                 0   if P1=P2

   Author:     Peter 05/2000
}
//------------------------------------------------------------------------------
interface
{ -------------------------------------------------------------------------- }

function Compare( const I1, I2: Integer ): Integer; Overload;
function Compare( const I1, I2: Byte ): Integer; Overload;
function Compare( const S1, S2: single ): Integer; Overload;
function Compare( const D1, D2: double ): Integer; Overload;
function Compare( const S1, S2: string ): Integer; Overload;
function Compare( const S1, S2: ShortString ): Integer; Overload;
function Compare( const B1, B2: Boolean ): Integer; Overload;

{ -------------------------------------------------------------------------- }
implementation uses SysUtils;
{ -------------------------------------------------------------------------- }

function Compare( const I1, I2: Integer ): Integer;
begin
  if ( I1 > I2 ) then
    Result := 1
  else if ( I1 < I2 ) then
    Result := -1
  else
    Result := 0;
end;
//------------------------------------------------------------------------------

function Compare( const I1, I2: Byte ): Integer;
begin
  if ( I1 > I2 ) then
    Result := 1
  else if ( I1 < I2 ) then
    Result := -1
  else
    Result := 0;
end;

function Compare( const D1, D2: double ): Integer;
begin
  if ( D1 > D2 ) then
    Result := 1
  else if ( D1 < D2 ) then
    Result := -1
  else
    Result := 0;
end;

//------------------------------------------------------------------------------

function Compare( const S1, S2: single ): Integer;
begin
  if ( S1 > S2 ) then
    Result := 1
  else if ( S1 < S2 ) then
    Result := -1
  else
    Result := 0;
end;

//------------------------------------------------------------------------------

function Compare( const S1, S2: string ): Integer;
begin { Start at pos 1, case sensitive, full string compare }
  Result := CompareStr( S1, S2 );
end;

//------------------------------------------------------------------------------

function Compare( const S1, S2: ShortString ): Integer;
begin
  Result := CompareStr( S1, S2 );
end;

//------------------------------------------------------------------------------

function Compare( const B1, B2: Boolean ): Integer; Overload;
Begin
  If B1 and not B2 then
    Result := 1
  else
  If B2 and not B1 then
    Result := -1
  else
    Result := 0;
end;

end.

