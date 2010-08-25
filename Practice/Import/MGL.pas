unit MGL;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation uses CSVChart;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;

Begin
   CSVChart.RefreshChart( '*.BLC', 'MGL.TPM', iNumeric );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.

