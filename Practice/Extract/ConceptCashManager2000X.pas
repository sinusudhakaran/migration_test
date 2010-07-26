unit ConceptCashManager2000X;
//------------------------------------------------------------------------------
{
   Title:        Concept Cash Manager 2000 Export Routines

   Description:

   Author:       Matthew Hopkins Aug 2002

   Remarks:      See contact notes in ConceptCashManager2000.pas

                 Uses the standard BankLink CSV interface

                 Default file name format is  ..\<Client Code>.CSV
}
//------------------------------------------------------------------------------

interface

procedure ExtractData( const FromDate, ToDate : integer; const SaveTo : string );

//******************************************************************************
implementation
uses
  CSVX;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ExtractData( const FromDate, ToDate : integer; const SaveTo : string );
Begin
   CSVX.ExtractData( FromDate, ToDate, SaveTo );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
