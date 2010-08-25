unit BCSAccounting;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation uses CSVChart;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;

Begin
   CSVChart.RefreshChart( '*.COA', 'BCS.TPM', iText );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.

