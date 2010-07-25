unit CFUtils;

!! no longer used !!

{
   We need to store 11 additional headings for each account type.
   0    = Heading to use for "Unassigned" accounts [SubType = 0]
   1..9 = Heading to use for each SubType
   10   = Heading to use for the total of all the accounts for this
          type.
}

// -----------------------------------------------------------------------------
interface
// -----------------------------------------------------------------------------
{
Const
   sbMin  = 1;
   sbMax  = 10;
   SubTypes : Array[ sbMin..sbMax ] of Integer = ( 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 );

Function CFTS2Int( Const AType, ASubType : Integer ): Integer;
// Returns
//    The Heading Number for an Account Type & SubType combination.
// Remarks:
//    AType must be >= 1.
//    ASubType must be in the range 0..10.
}
// -----------------------------------------------------------------------------
implementation uses BKConst, SysUtils;
// -----------------------------------------------------------------------------

Function CFTS2Int( Const AType, ASubType : Integer ): Integer;
Const
   ProcName       = 'CFUtils.CFTS2Int';
   SATypeError    = 'Account Type %d out of range in %s';
   SASubTypeError = 'Account Subtype %d out of range in %s';
Begin
   Assert( AType    in [ atIncome..atMax ], Format( SATypeError, [ AType, ProcName ] ) );
   Assert( ASubType in [ 0 .. 10 ], Format( SASubTypeError, [ ASubType, ProcName ] ) );
   Result := 11 * ( Pred ( AType ) ) + ASubType ;
end;

Begin
   {
      The report subheadings are stored in the client record.
      clReport_Subheadings : Array[ 0..200 ] of String[ 60 ];
   }

   Assert( CFTS2Int( atIncome, 0 ) =  0 );
//   Assert( CFTS2Int( atMax, 10 ) <= 255, 'You need to increase the number of Report_Subheadings!' );
end.
