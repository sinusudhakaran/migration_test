UNIT BKpyIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Payee                        = 100 ;
   tkEnd_Payee                          = 101 ;

FUNCTION  IsAPayee_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Payee_Rec ( Var O : TPayee_Rec ; Var F : TIOStream );
PROCEDURE Read_Payee_Rec ( Var O : TPayee_Rec ; Var F : TIOStream );
FUNCTION  New_Payee_Rec : pPayee_Rec ;
PROCEDURE Free_Payee_Rec_Dynamic_Fields ( Var O : TPayee_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKPYIO';
   SBoundsError        = 'BKPYIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKPYIO Error: Pointer is NIL in IsAPayee_Rec';
   SInvalidType        = 'BKPYIO Error: Type is invalid in IsAPayee_Rec';
   SInvalidEOR         = 'BKPYIO Error: EOR is missing in IsAPayee_Rec';
   SUnknownToken       = 'BKPYIO Error: Unknown token %d in Read_Payee_Rec';
   SInsufficientMemory = 'BKPYIO Error: Out of memory in New_Payee_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkpyNumber                           = 102 ;
   tkpyName                             = 103 ;
   tkpyAccount                          = 104 ;
   tkpyPercentage                       = 105 ;
   tkpyGST_Class                        = 106 ;
   tkpyGST_Has_Been_Edited              = 107 ;
   tkpyGL_Narration                     = 108 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAPayee_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PPayee_Rec ( P )^ do Begin
      If pyRecord_Type <> tkBegin_Payee then
         Raise ECorruptData.Create( SInvalidType );
      If pyEOR <> tkEnd_Payee then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Payee_Rec ( Var O : TPayee_Rec ; Var F : TIOStream );

Var
   I     : Byte;

Begin
   If IsAPayee_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Payee );
      F.WriteIntegerValue( tkpyNumber , pyNumber );
      F.WriteStringValue( tkpyName , pyName );
      For i := 1 to 50 do F.WriteBStringValue( tkpyAccount , i, pyAccount[ i ] );
      For i := 1 to 50 do F.WriteBMoneyValue( tkpyPercentage , i, pyPercentage[ i ] );
      For i := 1 to 50 do F.WriteBByteValue( tkpyGST_Class , i, pyGST_Class[ i ] );
      For i := 1 to 50 do F.WriteBBooleanValue( tkpyGST_Has_Been_Edited , i, pyGST_Has_Been_Edited[ i ] );
      For i := 1 to 50 do F.WriteBStringValue( tkpyGL_Narration , i, pyGL_Narration[ i ] );
      F.WriteToken( tkEnd_Payee );
   end;
end; { of Write_Payee_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Payee_Rec ( Var O : TPayee_Rec; Var F : TIOStream );

Var
   Token : Byte;
   I     : Byte;
   M     : Money;
   B     : Byte;   
   Y     : Boolean;
   S     : ShortString;

Begin
   FillChar( O, Payee_Rec_Size, 0 );
   O.pyRecord_Type := tkBegin_Payee;
   O.pyEOR := tkEnd_Payee;
   Token := tkBegin_Payee;

   While Token <> tkEnd_Payee do With O do
   Begin
      Case Token of
         tkBegin_Payee :; { Do Nothing }
         tkEnd_Payee :; { Do Nothing }
         tkpyNumber                           : pyNumber := F.ReadIntegerValue;
         tkpyName                             : pyName := F.ReadStringValue;
         tkpyAccount                          : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 50, 'pyAccount' );
               pyAccount[ I ] := S;
            end;
         tkpyPercentage                       : 
            Begin
               M := F.ReadBMoneyValue( I );
               CheckBounds( I, 1, 50, 'pyPercentage' );
               pyPercentage[ I ] := M;
            end;
         tkpyGST_Class                        : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 50, 'pyGST_Class' );
               pyGST_Class[ I ] := B;
            end;
         tkpyGST_Has_Been_Edited              : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 1, 50, 'pyGST_Has_Been_Edited' );
               pyGST_Has_Been_Edited[ I ] := Y;
            end;
         tkpyGL_Narration                     : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 50, 'pyGL_Narration' );
               pyGL_Narration[ I ] := S;
            end;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Payee_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Payee_Rec : pPayee_Rec ;

Var
   P : pPayee_Rec;
Begin
   SafeGetMem( P, Payee_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Payee_Rec_Size, 0 );
      pyRecord_Type := tkBegin_Payee;
      pyEOR         := tkEnd_Payee;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Payee_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Payee_Rec_Dynamic_Fields ( Var O : TPayee_Rec );

Begin
   If IsAPayee_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
