unit MatchedItemsList;
//------------------------------------------------------------------------------
{
   Title:       Matched Items List Object

   Description:

   Remarks:     Descends from TTransaction_List because the SaveToFile must be
                overriden so that the correct token is written.

   Author:      Matthew Hopkins Jan 2001


   //as of version 60.5 this list is no longer used.  It should be removed
   //in future version.  It has only been left in to aid in upgrading from version
   //from 59 - 60.4 which were only released internally

}
//------------------------------------------------------------------------------
interface
uses
   classes, bkdefs, iostream, trxList32;

type
   TMatched_Items_List = class( TTransaction_List)
   public
      procedure SaveToFile(var S: TIOStream);
   end;

//******************************************************************************
implementation
uses
   Tokens,
   bkTXIO,
   bkDSIO;      

{ TMatched_Items_List }

//------------------------------------------------------------------------------

procedure TMatched_Items_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TMatched_Items_List.SaveToFile';
Var
   i   : LongInt;
   pTX : pTransaction_Rec;
   pDS : pDissection_Rec;
Begin
   S.WriteToken( tkBeginMatchedItems );  //MUST WRITE CORRECT TOKEN!!!

   for i := 0 to Pred( ItemCount ) do begin
      pTX := Transaction_At( i );
      pTx^.txLRN_NOW_UNUSED := 0;   //clear any obsolete data

      BKTXIO.Write_Transaction_Rec ( pTX^, S );

      pDS := pTX^.txFirst_Dissection;
      while pDS<>NIL do begin
         BKDSIO.Write_Dissection_Rec ( pDS^, S );
         pDS := pDS^.dsNext;
      end;
   end;
   S.WriteToken( tkEndSection );
end;

//------------------------------------------------------------------------------
end.
