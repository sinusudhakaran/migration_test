UNIT BKmaIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Macro                        = 240 ;
   tkEnd_Macro                          = 241 ;

FUNCTION  IsAMacro_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Macro_Rec ( Var O : TMacro_Rec ; Var F : TIOStream );
PROCEDURE Read_Macro_Rec ( Var O : TMacro_Rec ; Var F : TIOStream );
FUNCTION  New_Macro_Rec : pMacro_Rec ;
PROCEDURE Free_Macro_Rec_Dynamic_Fields ( Var O : TMacro_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKMAIO';
   SBoundsError        = 'BKMAIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKMAIO Error: Pointer is NIL in IsAMacro_Rec';
   SInvalidType        = 'BKMAIO Error: Type is invalid in IsAMacro_Rec';
   SInvalidEOR         = 'BKMAIO Error: EOR is missing in IsAMacro_Rec';
   SUnknownToken       = 'BKMAIO Error: Unknown token %d in Read_Macro_Rec';
   SInsufficientMemory = 'BKMAIO Error: Out of memory in New_Macro_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkmaCode                             = 242 ;
   tkmaDescription                      = 243 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAMacro_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PMacro_Rec ( P )^ do Begin
      If maRecord_Type <> tkBegin_Macro then
         Raise ECorruptData.Create( SInvalidType );
      If maEOR <> tkEnd_Macro then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Macro_Rec ( Var O : TMacro_Rec ; Var F : TIOStream );

Begin
   If IsAMacro_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Macro );
      F.WriteStringValue( tkmaCode , maCode );
      F.WriteStringValue( tkmaDescription , maDescription );
      F.WriteToken( tkEnd_Macro );
   end;
end; { of Write_Macro_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Macro_Rec ( Var O : TMacro_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Macro_Rec_Size, 0 );
   O.maRecord_Type := tkBegin_Macro;
   O.maEOR := tkEnd_Macro;
   Token := tkBegin_Macro;

   While Token <> tkEnd_Macro do With O do
   Begin
      Case Token of
         tkBegin_Macro :; { Do Nothing }
         tkEnd_Macro :; { Do Nothing }
         tkmaCode                             : maCode := F.ReadStringValue;
         tkmaDescription                      : maDescription := F.ReadStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Macro_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Macro_Rec : pMacro_Rec ;

Var
   P : pMacro_Rec;
Begin
   SafeGetMem( P, Macro_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Macro_Rec_Size, 0 );
      maRecord_Type := tkBegin_Macro;
      maEOR         := tkEnd_Macro;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Macro_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Macro_Rec_Dynamic_Fields ( Var O : TMacro_Rec );

Begin
   If IsAMacro_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
