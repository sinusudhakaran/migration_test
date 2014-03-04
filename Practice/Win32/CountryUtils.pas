unit CountryUtils;

//
//  Write all the captions and strings in NZ standard form and replace them as required
//  for other countries.
//

// ---------------------------------------------------------------------------
interface
// ---------------------------------------------------------------------------

const
  MIN_STATE = 0;
  MAX_STATE = 8;

Function Localise( Country : Byte; S : String ): String;
Procedure GetAustraliaStateFromIndex(aIndex : integer; var aCode, aDescription : string);

// ---------------------------------------------------------------------------
implementation

uses
  BKCONST,
  StrUtils;

// -----------------------------------------------------------------------------
Function Localise( Country : Byte; S : String ): String;

Var
  S1, S2 : String;
Begin
  if ( Country = whNewZealand ) then
  Begin
    Result := S;
    exit;
  End;

  S1 := whTaxSystemNames[ whNewZealand ];  S2 := whTaxSystemNames[ Country ];
  if ( S1 <> S2 ) then S := ReplaceStr( S, S1, S2 );

  S1 := whTaxSystemNamesUC[ whNewZealand ];  S2 := whTaxSystemNamesUC[ Country ];
  if ( S1 <> S2 ) then S := ReplaceStr( S, S1, S2 );

  S1 := whCurrencySymbols[ whNewZealand ];  S2 := whCurrencySymbols[ Country ];
  if ( S1 <> S2 ) then S := ReplaceStr( S, S1, S2 );

  S1 := whCurrencyNames[ whNewZealand ];  S2 := whCurrencyNames[ Country ];
  if ( S1 <> S2 ) then S := ReplaceStr( S, S1, S2 );

  Result := S;
End;

// -----------------------------------------------------------------------------
Procedure GetAustraliaStateFromIndex(aIndex : integer; var aCode, aDescription : string);
begin
  case aIndex of
    0 : begin aCode := 'ACT'; aDescription :=	'Australian Capital Territory'; end;
    1 : begin aCode := 'NSW'; aDescription :=	'New South Wales'; end;
    2 : begin aCode := 'NT'; aDescription :=	'Northern Territory'; end;
    3 : begin aCode := 'QLD'; aDescription :=	'Queensland'; end;
    4 : begin aCode := 'SA'; aDescription :=	'South Australia'; end;
    5 : begin aCode := 'TAS'; aDescription :=	'Tasmania'; end;
    6 : begin aCode := 'VIC'; aDescription :=	'Victoria'; end;
    7 : begin aCode := 'WA'; aDescription :=	'Western Australia'; end;
    8 : begin aCode := 'OTH'; aDescription :=	'Overseas addresses'; end;
  else
    begin aCode := ''; aDescription :=	''; end;
  end;
end;

end.
