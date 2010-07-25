unit TransUtils;
//------------------------------------------------------------------------------
{
   Title:       Transaction Utilities

   Description: routines which operate on the transaction object

   Remarks:

   Author:      Matthew Hopkins Jan 2001

}
//------------------------------------------------------------------------------
interface
uses
   bkDefs;

   !!!! NOT USED !!!!!

//   procedure CopyTransaction( Source : pTransaction_Rec; Dest : pTransaction_Rec);

//******************************************************************************
implementation

procedure CopyTransaction( Source : pTransaction_Rec; Dest : pTransaction_Rec);
begin
   Move( Source^, Dest^, SizeOf( TTransaction_Rec));
end;

//------------------------------------------------------------------------------
end.
