unit ecBankAccountObj;
//------------------------------------------------------------------------------
{
   Title:       EcBankAccount

   Description: ECoding Bank Account Object

   Remarks:     Holds details and transaction list for bank account

   Author:      Matthew Hopkins Jul 2001

}
//------------------------------------------------------------------------------

interface
uses
   ecDefs, ioStream, ecTransactionListObj;

type
   TEcBank_Account = class
      baFields                 : tBank_Account_Details_Rec;
      baTransaction_List       : TECTransaction_List;

      constructor  Create; virtual;
      destructor   Destroy; override;
   private

   public
      procedure    SaveToFile(var s: TIOStream);
      procedure    LoadFromFile(var s: TIOStream);
      procedure    UpdateSequenceNumbers;

      procedure    UpdateCRC( var CRC : LongWord);
   end;

//******************************************************************************
implementation
uses
   ecbaio,
   ecTokens,
   bkDBExcept,
   ecCRC;

{ TEcBankAccount }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TEcBank_Account.Create;
begin
   inherited Create;

   FillChar( baFields, SizeOf( baFields), 0);
   baFields.baRecord_Type := ecbaio.tkBegin_Bank_Account_Details;
   baFields.baEOR         := ecbaio.tkEnd_Bank_Account_Details;
   baTransaction_List     := TEcTransaction_List.Create;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TEcBank_Account.Destroy;
begin
   baTransaction_List.Free;
   ecbaio.Free_Bank_Account_Details_Rec_Dynamic_Fields( baFields);
   inherited;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TEcBank_Account.LoadFromFile(var s: TIOStream);
var
   Token: Byte;
begin
   Token := tkBegin_Bank_Account_Details;
   While ( Token <> tkEndSection ) do Begin
      Case Token of
         tkBegin_Bank_Account_Details : Read_Bank_Account_Details_Rec ( baFields, S );
         tkBeginEntries               : baTransaction_List.LoadFromFile( S );
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := S.ReadToken;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TEcBank_Account.SaveToFile(var s: TIOStream);
begin
   ECBAIO.Write_Bank_Account_Details_Rec ( baFields, S );
   baTransaction_List.SaveToFile( S );
   S.WriteToken( tkEndSection );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TEcBank_Account.UpdateCRC(var CRC: LongWord);
begin
   ecCRC.UpdateCRC( baFields, CRC);
   baTransaction_List.UpdateCRC( CRC);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TEcBank_Account.UpdateSequenceNumbers;
var
  t : integer;
begin
   with baTransaction_List do begin
      for T := 0 to Pred( ItemCount ) do begin
         with Transaction_At( T )^ do begin
            txBank_Seq := baFields.baNumber;
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
