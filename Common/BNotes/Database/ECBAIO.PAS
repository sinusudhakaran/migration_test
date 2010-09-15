UNIT ECbaIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES ECDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Bank_Account_Details         = 150 ;
   tkEnd_Bank_Account_Details           = 151 ;

FUNCTION  IsABank_Account_Details_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Bank_Account_Details_Rec ( Var O : TBank_Account_Details_Rec ; Var F : TIOStream );
PROCEDURE Read_Bank_Account_Details_Rec ( Var O : TBank_Account_Details_Rec ; Var F : TIOStream );
FUNCTION  New_Bank_Account_Details_Rec : pBank_Account_Details_Rec ;
PROCEDURE Free_Bank_Account_Details_Rec_Dynamic_Fields ( Var O : TBank_Account_Details_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'ECBAIO';
   SBoundsError        = 'ECBAIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'ECBAIO Error: Pointer is NIL in IsABank_Account_Details_Rec';
   SInvalidType        = 'ECBAIO Error: Type is invalid in IsABank_Account_Details_Rec';
   SInvalidEOR         = 'ECBAIO Error: EOR is missing in IsABank_Account_Details_Rec';
   SUnknownToken       = 'ECBAIO Error: Unknown token %d in Read_Bank_Account_Details_Rec';
   SInsufficientMemory = 'ECBAIO Error: Out of memory in New_Bank_Account_Details_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkbaBank_Account_Number              = 152 ;
   tkbaBank_Account_Name                = 153 ;
   tkbaBank_Account_Password            = 154 ;
   tkbaCurrent_Balance                  = 155 ;
   tkbaAccount_Type                     = 156 ;
   tkbaCurrency_Code                    = 157 ;
   tkbaCurrency_Symbol                  = 158 ;

{  -------------------------------------------------------------------  }

FUNCTION IsABank_Account_Details_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PBank_Account_Details_Rec ( P )^ do Begin
      If baRecord_Type <> tkBegin_Bank_Account_Details then
         Raise ECorruptData.Create( SInvalidType );
      If baEOR <> tkEnd_Bank_Account_Details then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Bank_Account_Details_Rec ( Var O : TBank_Account_Details_Rec ; Var F : TIOStream );

Begin
   If IsABank_Account_Details_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Bank_Account_Details );
      F.WriteStringValue( tkbaBank_Account_Number , baBank_Account_Number );
      F.WriteStringValue( tkbaBank_Account_Name , baBank_Account_Name );
      F.WriteStringValue( tkbaBank_Account_Password , baBank_Account_Password );
      F.WriteMoneyValue( tkbaCurrent_Balance , baCurrent_Balance );
      F.WriteByteValue( tkbaAccount_Type , baAccount_Type );
      F.WriteStringValue( tkbaCurrency_Code , baCurrency_Code );
      F.WriteStringValue( tkbaCurrency_Symbol , baCurrency_Symbol );
      F.WriteToken( tkEnd_Bank_Account_Details );
   end;
end; { of Write_Bank_Account_Details_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Bank_Account_Details_Rec ( Var O : TBank_Account_Details_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Bank_Account_Details_Rec_Size, 0 );
   O.baRecord_Type := tkBegin_Bank_Account_Details;
   O.baEOR := tkEnd_Bank_Account_Details;
   Token := tkBegin_Bank_Account_Details;

   While Token <> tkEnd_Bank_Account_Details do With O do
   Begin
      Case Token of
         tkBegin_Bank_Account_Details :; { Do Nothing }
         tkEnd_Bank_Account_Details :; { Do Nothing }
         tkbaBank_Account_Number              : baBank_Account_Number := F.ReadStringValue;
         tkbaBank_Account_Name                : baBank_Account_Name := F.ReadStringValue;
         tkbaBank_Account_Password            : baBank_Account_Password := F.ReadStringValue;
         tkbaCurrent_Balance                  : baCurrent_Balance := F.ReadMoneyValue;
         tkbaAccount_Type                     : baAccount_Type := F.ReadByteValue;
         tkbaCurrency_Code                    : baCurrency_Code := F.ReadStringValue;
         tkbaCurrency_Symbol                  : baCurrency_Symbol := F.ReadStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Bank_Account_Details_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Bank_Account_Details_Rec : pBank_Account_Details_Rec ;

Var
   P : pBank_Account_Details_Rec;
Begin
   SafeGetMem( P, Bank_Account_Details_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Bank_Account_Details_Rec_Size, 0 );
      baRecord_Type := tkBegin_Bank_Account_Details;
      baEOR         := tkEnd_Bank_Account_Details;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Bank_Account_Details_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Bank_Account_Details_Rec_Dynamic_Fields ( Var O : TBank_Account_Details_Rec );

Begin
   If IsABank_Account_Details_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
