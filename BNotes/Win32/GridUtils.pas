unit GridUtils;

interface uses TsGrid, Graphics;

Function GetRowColor( Const AGrid : TtsGrid; Const Row : Integer; Const Is256Colors : Boolean ): TColor;

implementation

Function GetRowColor( Const AGrid : TtsGrid; Const Row : Integer; Const Is256Colors : Boolean ): TColor;
Begin
  If Row = AGrid.CurrentDataRow then
  Begin
    Case Is256Colors of
      True  : Result := $00F0D0A0;
      False : Result := clSkyBlue;
    end;
  end
  else
  If Odd( Row ) then
  Begin
    Case Is256Colors of
      True  : Result := $00E0FFFF;
      False : Result := $00E1FFFF;
    end;
  end
  else
  Begin
    Case Is256Colors of
      True  : Result := clWhite;
      False : Result := clWhite;
    end;
  end;
end;

end.
