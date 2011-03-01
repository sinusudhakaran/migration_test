UNIT BKmcIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_MoreClient                   = 251 ;
   tkEnd_MoreClient                     = 252 ;

FUNCTION  IsAMoreClient_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_MoreClient_Rec ( Var O : TMoreClient_Rec ; Var F : TIOStream );
PROCEDURE Read_MoreClient_Rec ( Var O : TMoreClient_Rec ; Var F : TIOStream );
FUNCTION  New_MoreClient_Rec : pMoreClient_Rec ;
PROCEDURE Free_MoreClient_Rec_Dynamic_Fields ( Var O : TMoreClient_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKMCIO';
   SBoundsError        = 'BKMCIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKMCIO Error: Pointer is NIL in IsAMoreClient_Rec';
   SInvalidType        = 'BKMCIO Error: Type is invalid in IsAMoreClient_Rec';
   SInvalidEOR         = 'BKMCIO Error: EOR is missing in IsAMoreClient_Rec';
   SUnknownToken       = 'BKMCIO Error: Unknown token %d in Read_MoreClient_Rec';
   SInsufficientMemory = 'BKMCIO Error: Out of memory in New_MoreClient_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkmcBAS_Dont_Print_Fuel_Sheet        = 253 ;
   tkmcArchived                         = 254 ;
   tkmcJournal_Processing_Duration      = 255 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAMoreClient_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PMoreClient_Rec ( P )^ do Begin
      If mcRecord_Type <> tkBegin_MoreClient then
         Raise ECorruptData.Create( SInvalidType );
      If mcEOR <> tkEnd_MoreClient then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_MoreClient_Rec ( Var O : TMoreClient_Rec ; Var F : TIOStream );

Begin
   If IsAMoreClient_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_MoreClient );
      F.WriteBooleanValue( tkmcBAS_Dont_Print_Fuel_Sheet , mcBAS_Dont_Print_Fuel_Sheet );
      F.WriteBooleanValue( tkmcArchived , mcArchived );
      F.WriteByteValue( tkmcJournal_Processing_Duration , mcJournal_Processing_Duration );
      F.WriteToken( tkEnd_MoreClient );
   end;
end; { of Write_MoreClient_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_MoreClient_Rec ( Var O : TMoreClient_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, MoreClient_Rec_Size, 0 );
   O.mcRecord_Type := tkBegin_MoreClient;
   O.mcEOR := tkEnd_MoreClient;
   Token := tkBegin_MoreClient;

   While Token <> tkEnd_MoreClient do With O do
   Begin
      Case Token of
         tkBegin_MoreClient :; { Do Nothing }
         tkEnd_MoreClient :; { Do Nothing }
         tkmcBAS_Dont_Print_Fuel_Sheet        : mcBAS_Dont_Print_Fuel_Sheet := F.ReadBooleanValue;
         tkmcArchived                         : mcArchived := F.ReadBooleanValue;
         tkmcJournal_Processing_Duration      : mcJournal_Processing_Duration := F.ReadByteValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_MoreClient_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_MoreClient_Rec : pMoreClient_Rec ;

Var
   P : pMoreClient_Rec;
Begin
   SafeGetMem( P, MoreClient_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, MoreClient_Rec_Size, 0 );
      mcRecord_Type := tkBegin_MoreClient;
      mcEOR         := tkEnd_MoreClient;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_MoreClient_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_MoreClient_Rec_Dynamic_Fields ( Var O : TMoreClient_Rec );

Begin
   If IsAMoreClient_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
