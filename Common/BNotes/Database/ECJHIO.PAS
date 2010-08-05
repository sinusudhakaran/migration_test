UNIT ECjhIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES ECDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Job_Heading                  = 210 ;
   tkEnd_Job_Heading                    = 211 ;

FUNCTION  IsAJob_Heading_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Job_Heading_Rec ( Var O : TJob_Heading_Rec ; Var F : TIOStream );
PROCEDURE Read_Job_Heading_Rec ( Var O : TJob_Heading_Rec ; Var F : TIOStream );
FUNCTION  New_Job_Heading_Rec : pJob_Heading_Rec ;
PROCEDURE Free_Job_Heading_Rec_Dynamic_Fields ( Var O : TJob_Heading_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'ECJHIO';
   SBoundsError        = 'ECJHIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'ECJHIO Error: Pointer is NIL in IsAJob_Heading_Rec';
   SInvalidType        = 'ECJHIO Error: Type is invalid in IsAJob_Heading_Rec';
   SInvalidEOR         = 'ECJHIO Error: EOR is missing in IsAJob_Heading_Rec';
   SUnknownToken       = 'ECJHIO Error: Unknown token %d in Read_Job_Heading_Rec';
   SInsufficientMemory = 'ECJHIO Error: Out of memory in New_Job_Heading_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkjhHeading                          = 212 ;
   tkjhLRN                              = 213 ;
   tkjhCode                             = 214 ;
   tkjhIsCompleted                      = 215 ;
   tkjhAdded_By_ECoding                 = 216 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAJob_Heading_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PJob_Heading_Rec ( P )^ do Begin
      If jhRecord_Type <> tkBegin_Job_Heading then
         Raise ECorruptData.Create( SInvalidType );
      If jhEOR <> tkEnd_Job_Heading then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Job_Heading_Rec ( Var O : TJob_Heading_Rec ; Var F : TIOStream );

Begin
   If IsAJob_Heading_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Job_Heading );
      F.WriteStringValue( tkjhHeading , jhHeading );
      F.WriteIntegerValue( tkjhLRN , jhLRN );
      F.WriteStringValue( tkjhCode , jhCode );
      F.WriteBooleanValue( tkjhIsCompleted , jhIsCompleted );
      F.WriteBooleanValue( tkjhAdded_By_ECoding , jhAdded_By_ECoding );
      F.WriteToken( tkEnd_Job_Heading );
   end;
end; { of Write_Job_Heading_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Job_Heading_Rec ( Var O : TJob_Heading_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Job_Heading_Rec_Size, 0 );
   O.jhRecord_Type := tkBegin_Job_Heading;
   O.jhEOR := tkEnd_Job_Heading;
   Token := tkBegin_Job_Heading;

   While Token <> tkEnd_Job_Heading do With O do
   Begin
      Case Token of
         tkBegin_Job_Heading :; { Do Nothing }
         tkEnd_Job_Heading :; { Do Nothing }
         tkjhHeading                          : jhHeading := F.ReadStringValue;
         tkjhLRN                              : jhLRN := F.ReadIntegerValue;
         tkjhCode                             : jhCode := F.ReadStringValue;
         tkjhIsCompleted                      : jhIsCompleted := F.ReadBooleanValue;
         tkjhAdded_By_ECoding                 : jhAdded_By_ECoding := F.ReadBooleanValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Job_Heading_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Job_Heading_Rec : pJob_Heading_Rec ;

Var
   P : pJob_Heading_Rec;
Begin
   SafeGetMem( P, Job_Heading_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Job_Heading_Rec_Size, 0 );
      jhRecord_Type := tkBegin_Job_Heading;
      jhEOR         := tkEnd_Job_Heading;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Job_Heading_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Job_Heading_Rec_Dynamic_Fields ( Var O : TJob_Heading_Rec );

Begin
   If IsAJob_Heading_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
