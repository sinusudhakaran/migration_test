UNIT ECplIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES ECDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Payee_Line                   = 95 ;
   tkEnd_Payee_Line                     = 96 ;

FUNCTION  IsAPayee_Line_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Payee_Line_Rec ( Var O : TPayee_Line_Rec ; Var F : TIOStream );
PROCEDURE Read_Payee_Line_Rec ( Var O : TPayee_Line_Rec ; Var F : TIOStream );
FUNCTION  New_Payee_Line_Rec : pPayee_Line_Rec ;
PROCEDURE Free_Payee_Line_Rec_Dynamic_Fields ( Var O : TPayee_Line_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'ECPLIO';
   SBoundsError        = 'ECPLIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'ECPLIO Error: Pointer is NIL in IsAPayee_Line_Rec';
   SInvalidType        = 'ECPLIO Error: Type is invalid in IsAPayee_Line_Rec';
   SInvalidEOR         = 'ECPLIO Error: EOR is missing in IsAPayee_Line_Rec';
   SUnknownToken       = 'ECPLIO Error: Unknown token %d in Read_Payee_Line_Rec';
   SInsufficientMemory = 'ECPLIO Error: Out of memory in New_Payee_Line_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkplAccount                          = 97 ;
   tkplPercentage                       = 98 ;
   tkplGST_Class                        = 99 ;
   tkplGST_Has_Been_Edited              = 100 ;
   tkplLine_Type                        = 101 ;
   tkplGL_Narration                     = 102 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAPayee_Line_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PPayee_Line_Rec ( P )^ do Begin
      If plRecord_Type <> tkBegin_Payee_Line then
         Raise ECorruptData.Create( SInvalidType );
      If plEOR <> tkEnd_Payee_Line then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Payee_Line_Rec ( Var O : TPayee_Line_Rec ; Var F : TIOStream );

Begin
   If IsAPayee_Line_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Payee_Line );
      F.WriteStringValue( tkplAccount , plAccount );
      F.WriteMoneyValue( tkplPercentage , plPercentage );
      F.WriteByteValue( tkplGST_Class , plGST_Class );
      F.WriteBooleanValue( tkplGST_Has_Been_Edited , plGST_Has_Been_Edited );
      F.WriteByteValue( tkplLine_Type , plLine_Type );
      F.WriteAnsiStringValue( tkplGL_Narration , plGL_Narration );
      F.WriteToken( tkEnd_Payee_Line );
   end;
end; { of Write_Payee_Line_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Payee_Line_Rec ( Var O : TPayee_Line_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Payee_Line_Rec_Size, 0 );
   O.plRecord_Type := tkBegin_Payee_Line;
   O.plEOR := tkEnd_Payee_Line;
   Token := tkBegin_Payee_Line;

   While Token <> tkEnd_Payee_Line do With O do
   Begin
      Case Token of
         tkBegin_Payee_Line :; { Do Nothing }
         tkEnd_Payee_Line :; { Do Nothing }
         tkplAccount                          : plAccount := F.ReadStringValue;
         tkplPercentage                       : plPercentage := F.ReadMoneyValue;
         tkplGST_Class                        : plGST_Class := F.ReadByteValue;
         tkplGST_Has_Been_Edited              : plGST_Has_Been_Edited := F.ReadBooleanValue;
         tkplLine_Type                        : plLine_Type := F.ReadByteValue;
         tkplGL_Narration                     : plGL_Narration := F.ReadAnsiStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Payee_Line_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Payee_Line_Rec : pPayee_Line_Rec ;

Var
   P : pPayee_Line_Rec;
Begin
   SafeGetMem( P, Payee_Line_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Payee_Line_Rec_Size, 0 );
      plRecord_Type := tkBegin_Payee_Line;
      plEOR         := tkEnd_Payee_Line;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Payee_Line_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Payee_Line_Rec_Dynamic_Fields ( Var O : TPayee_Line_Rec );

Begin
   If IsAPayee_Line_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      plGL_Narration := '' ;
   end;
end;

{  -------------------------------------------------------------------  }

END.
