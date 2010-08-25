unit ConceptCashManager2000;
//------------------------------------------------------------------------------
{
   Title:       Import routines for concept cash manager 2000

   Description:

   Author:      Matthew Hopkins Aug 2002

   Remarks:     Concept Cash Manager 2000 is written by

                  Computer Concepts & Systems Ltd
                  PO Box 692
                  Masterton

                  Phone 06-370-0280
                  Fax 06-370-0285

               The software uses the standard BK5 CSV interface document
               as as Aug 2002.

   Contact:    Paul Younger [mailto:Paul@computerconcepts.co.nz]
}
//------------------------------------------------------------------------------

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;

//******************************************************************************
implementation
uses
  CSVChart;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure RefreshChart;
begin
   CSVChart.RefreshChart( '*.CSV', '', iText );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
