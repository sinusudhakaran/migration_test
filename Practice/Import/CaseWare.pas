unit CaseWare;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation uses CSVChart;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;

Begin
   CSVChart.RefreshChart( '*.TXT', 'CASEWARE.TPM', iText );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.

