unit CountryUtils;

//
//  Write all the captions and strings in NZ standard form and replace them as required
//  for other countries.
//

// ---------------------------------------------------------------------------
interface
// ---------------------------------------------------------------------------

Function Localise( Country : Byte; S : String ): String;

// ---------------------------------------------------------------------------
implementation uses BKCONST, StrUtils;
// ---------------------------------------------------------------------------

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

end.
