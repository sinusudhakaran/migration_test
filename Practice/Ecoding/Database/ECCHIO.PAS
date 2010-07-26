UNIT ECchIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES ECDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Account                      = 80 ;
   tkEnd_Account                        = 81 ;

FUNCTION  IsAAccount_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Account_Rec ( Var O : TAccount_Rec ; Var F : TIOStream );
PROCEDURE Read_Account_Rec ( Var O : TAccount_Rec ; Var F : TIOStream );
FUNCTION  New_Account_Rec : pAccount_Rec ;
PROCEDURE Free_Account_Rec_Dynamic_Fields ( Var O : TAccount_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'ECCHIO';
   SBoundsError        = 'ECCHIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'ECCHIO Error: Pointer is NIL in IsAAccount_Rec';
   SInvalidType        = 'ECCHIO Error: Type is invalid in IsAAccount_Rec';
   SInvalidEOR         = 'ECCHIO Error: EOR is missing in IsAAccount_Rec';
   SUnknownToken       = 'ECCHIO Error: Unknown token %d in Read_Account_Rec';
   SInsufficientMemory = 'ECCHIO Error: Out of memory in New_Account_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkchAccount_Code                     = 82 ;
   tkchAccount_Description              = 83 ;
   tkchGST_Class                        = 84 ;
   tkchPosting_Allowed                  = 85 ;
   tkchHide_In_Basic_Chart              = 86 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAAccount_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PAccount_Rec ( P )^ do Begin
      If chRecord_Type <> tkBegin_Account then
         Raise ECorruptData.Create( SInvalidType );
      If chEOR <> tkEnd_Account then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Account_Rec ( Var O : TAccount_Rec ; Var F : TIOStream );

Begin
   If IsAAccount_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Account );
      F.WriteStringValue( tkchAccount_Code , chAccount_Code );
      F.WriteStringValue( tkchAccount_Description , chAccount_Description );
      F.WriteByteValue( tkchGST_Class , chGST_Class );
      F.WriteBooleanValue( tkchPosting_Allowed , chPosting_Allowed );
      F.WriteBooleanValue( tkchHide_In_Basic_Chart , chHide_In_Basic_Chart );
      F.WriteToken( tkEnd_Account );
   end;
end; { of Write_Account_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Account_Rec ( Var O : TAccount_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Account_Rec_Size, 0 );
   O.chRecord_Type := tkBegin_Account;
   O.chEOR := tkEnd_Account;
   Token := tkBegin_Account;

   While Token <> tkEnd_Account do With O do
   Begin
      Case Token of
         tkBegin_Account :; { Do Nothing }
         tkEnd_Account :; { Do Nothing }
         tkchAccount_Code                     : chAccount_Code := F.ReadStringValue;
         tkchAccount_Description              : chAccount_Description := F.ReadStringValue;
         tkchGST_Class                        : chGST_Class := F.ReadByteValue;
         tkchPosting_Allowed                  : chPosting_Allowed := F.ReadBooleanValue;
         tkchHide_In_Basic_Chart              : chHide_In_Basic_Chart := F.ReadBooleanValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Account_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Account_Rec : pAccount_Rec ;

Var
   P : pAccount_Rec;
Begin
   SafeGetMem( P, Account_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Account_Rec_Size, 0 );
      chRecord_Type := tkBegin_Account;
      chEOR         := tkEnd_Account;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Account_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Account_Rec_Dynamic_Fields ( Var O : TAccount_Rec );

Begin
   If IsAAccount_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
