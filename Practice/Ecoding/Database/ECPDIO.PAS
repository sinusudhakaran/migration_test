UNIT ECpdIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES ECDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Payee_Detail                 = 90 ;
   tkEnd_Payee_Detail                   = 91 ;

FUNCTION  IsAPayee_Detail_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Payee_Detail_Rec ( Var O : TPayee_Detail_Rec ; Var F : TIOStream );
PROCEDURE Read_Payee_Detail_Rec ( Var O : TPayee_Detail_Rec ; Var F : TIOStream );
FUNCTION  New_Payee_Detail_Rec : pPayee_Detail_Rec ;
PROCEDURE Free_Payee_Detail_Rec_Dynamic_Fields ( Var O : TPayee_Detail_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'ECPDIO';
   SBoundsError        = 'ECPDIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'ECPDIO Error: Pointer is NIL in IsAPayee_Detail_Rec';
   SInvalidType        = 'ECPDIO Error: Type is invalid in IsAPayee_Detail_Rec';
   SInvalidEOR         = 'ECPDIO Error: EOR is missing in IsAPayee_Detail_Rec';
   SUnknownToken       = 'ECPDIO Error: Unknown token %d in Read_Payee_Detail_Rec';
   SInsufficientMemory = 'ECPDIO Error: Out of memory in New_Payee_Detail_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkpdNumber                           = 92 ;
   tkpdName                             = 93 ;
   tkpdAdded_By_ECoding                 = 94 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAPayee_Detail_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PPayee_Detail_Rec ( P )^ do Begin
      If pdRecord_Type <> tkBegin_Payee_Detail then
         Raise ECorruptData.Create( SInvalidType );
      If pdEOR <> tkEnd_Payee_Detail then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Payee_Detail_Rec ( Var O : TPayee_Detail_Rec ; Var F : TIOStream );

Begin
   If IsAPayee_Detail_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Payee_Detail );
      F.WriteIntegerValue( tkpdNumber , pdNumber );
      F.WriteStringValue( tkpdName , pdName );
      F.WriteBooleanValue( tkpdAdded_By_ECoding , pdAdded_By_ECoding );
      F.WriteToken( tkEnd_Payee_Detail );
   end;
end; { of Write_Payee_Detail_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Payee_Detail_Rec ( Var O : TPayee_Detail_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Payee_Detail_Rec_Size, 0 );
   O.pdRecord_Type := tkBegin_Payee_Detail;
   O.pdEOR := tkEnd_Payee_Detail;
   Token := tkBegin_Payee_Detail;

   While Token <> tkEnd_Payee_Detail do With O do
   Begin
      Case Token of
         tkBegin_Payee_Detail :; { Do Nothing }
         tkEnd_Payee_Detail :; { Do Nothing }
         tkpdNumber                           : pdNumber := F.ReadIntegerValue;
         tkpdName                             : pdName := F.ReadStringValue;
         tkpdAdded_By_ECoding                 : pdAdded_By_ECoding := F.ReadBooleanValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Payee_Detail_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Payee_Detail_Rec : pPayee_Detail_Rec ;

Var
   P : pPayee_Detail_Rec;
Begin
   SafeGetMem( P, Payee_Detail_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Payee_Detail_Rec_Size, 0 );
      pdRecord_Type := tkBegin_Payee_Detail;
      pdEOR         := tkEnd_Payee_Detail;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Payee_Detail_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Payee_Detail_Rec_Dynamic_Fields ( Var O : TPayee_Detail_Rec );

Begin
   If IsAPayee_Detail_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
