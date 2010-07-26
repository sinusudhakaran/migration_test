UNIT SYctIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Client_Type                  = 120 ;
   tkEnd_Client_Type                    = 121 ;

FUNCTION  IsAClient_Type_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Client_Type_Rec ( Var O : TClient_Type_Rec ; Var F : TIOStream );
PROCEDURE Read_Client_Type_Rec ( Var O : TClient_Type_Rec ; Var F : TIOStream );
FUNCTION  New_Client_Type_Rec : pClient_Type_Rec ;
PROCEDURE Free_Client_Type_Rec_Dynamic_Fields ( Var O : TClient_Type_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'SYCTIO';
   SBoundsError        = 'SYCTIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'SYCTIO Error: Pointer is NIL in IsAClient_Type_Rec';
   SInvalidType        = 'SYCTIO Error: Type is invalid in IsAClient_Type_Rec';
   SInvalidEOR         = 'SYCTIO Error: EOR is missing in IsAClient_Type_Rec';
   SUnknownToken       = 'SYCTIO Error: Unknown token %d in Read_Client_Type_Rec';
   SInsufficientMemory = 'SYCTIO Error: Out of memory in New_Client_Type_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkctLRN                              = 122 ;
   tkctName                             = 123 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAClient_Type_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PClient_Type_Rec ( P )^ do Begin
      If ctRecord_Type <> tkBegin_Client_Type then
         Raise ECorruptData.Create( SInvalidType );
      If ctEOR <> tkEnd_Client_Type then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Client_Type_Rec ( Var O : TClient_Type_Rec ; Var F : TIOStream );

Begin
   If IsAClient_Type_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Client_Type );
      F.WriteIntegerValue( tkctLRN , ctLRN );
      F.WriteStringValue( tkctName , ctName );
      F.WriteToken( tkEnd_Client_Type );
   end;
end; { of Write_Client_Type_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Client_Type_Rec ( Var O : TClient_Type_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Client_Type_Rec_Size, 0 );
   O.ctRecord_Type := tkBegin_Client_Type;
   O.ctEOR := tkEnd_Client_Type;
   Token := tkBegin_Client_Type;

   While Token <> tkEnd_Client_Type do With O do
   Begin
      Case Token of
         tkBegin_Client_Type :; { Do Nothing }
         tkEnd_Client_Type :; { Do Nothing }
         tkctLRN                              : ctLRN := F.ReadIntegerValue;
         tkctName                             : ctName := F.ReadStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Client_Type_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Client_Type_Rec : pClient_Type_Rec ;

Var
   P : pClient_Type_Rec;
Begin
   SafeGetMem( P, Client_Type_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Client_Type_Rec_Size, 0 );
      ctRecord_Type := tkBegin_Client_Type;
      ctEOR         := tkEnd_Client_Type;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Client_Type_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Client_Type_Rec_Dynamic_Fields ( Var O : TClient_Type_Rec );

Begin
   If IsAClient_Type_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
