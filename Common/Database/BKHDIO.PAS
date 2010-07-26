UNIT BKhdIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Custom_Heading               = 230 ;
   tkEnd_Custom_Heading                 = 231 ;

FUNCTION  IsACustom_Heading_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Custom_Heading_Rec ( Var O : TCustom_Heading_Rec ; Var F : TIOStream );
PROCEDURE Read_Custom_Heading_Rec ( Var O : TCustom_Heading_Rec ; Var F : TIOStream );
FUNCTION  New_Custom_Heading_Rec : pCustom_Heading_Rec ;
PROCEDURE Free_Custom_Heading_Rec_Dynamic_Fields ( Var O : TCustom_Heading_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKHDIO';
   SBoundsError        = 'BKHDIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKHDIO Error: Pointer is NIL in IsACustom_Heading_Rec';
   SInvalidType        = 'BKHDIO Error: Type is invalid in IsACustom_Heading_Rec';
   SInvalidEOR         = 'BKHDIO Error: EOR is missing in IsACustom_Heading_Rec';
   SUnknownToken       = 'BKHDIO Error: Unknown token %d in Read_Custom_Heading_Rec';
   SInsufficientMemory = 'BKHDIO Error: Out of memory in New_Custom_Heading_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkhdHeading_Type                     = 232 ;
   tkhdHeading                          = 233 ;
   tkhdMajor_ID                         = 234 ;
   tkhdMinor_ID                         = 235 ;

{  -------------------------------------------------------------------  }

FUNCTION IsACustom_Heading_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PCustom_Heading_Rec ( P )^ do Begin
      If hdRecord_Type <> tkBegin_Custom_Heading then
         Raise ECorruptData.Create( SInvalidType );
      If hdEOR <> tkEnd_Custom_Heading then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Custom_Heading_Rec ( Var O : TCustom_Heading_Rec ; Var F : TIOStream );

Begin
   If IsACustom_Heading_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Custom_Heading );
      F.WriteByteValue( tkhdHeading_Type , hdHeading_Type );
      F.WriteStringValue( tkhdHeading , hdHeading );
      F.WriteIntegerValue( tkhdMajor_ID , hdMajor_ID );
      F.WriteIntegerValue( tkhdMinor_ID , hdMinor_ID );
      F.WriteToken( tkEnd_Custom_Heading );
   end;
end; { of Write_Custom_Heading_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Custom_Heading_Rec ( Var O : TCustom_Heading_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Custom_Heading_Rec_Size, 0 );
   O.hdRecord_Type := tkBegin_Custom_Heading;
   O.hdEOR := tkEnd_Custom_Heading;
   Token := tkBegin_Custom_Heading;

   While Token <> tkEnd_Custom_Heading do With O do
   Begin
      Case Token of
         tkBegin_Custom_Heading :; { Do Nothing }
         tkEnd_Custom_Heading :; { Do Nothing }
         tkhdHeading_Type                     : hdHeading_Type := F.ReadByteValue;
         tkhdHeading                          : hdHeading := F.ReadStringValue;
         tkhdMajor_ID                         : hdMajor_ID := F.ReadIntegerValue;
         tkhdMinor_ID                         : hdMinor_ID := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Custom_Heading_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Custom_Heading_Rec : pCustom_Heading_Rec ;

Var
   P : pCustom_Heading_Rec;
Begin
   SafeGetMem( P, Custom_Heading_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Custom_Heading_Rec_Size, 0 );
      hdRecord_Type := tkBegin_Custom_Heading;
      hdEOR         := tkEnd_Custom_Heading;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Custom_Heading_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Custom_Heading_Rec_Dynamic_Fields ( Var O : TCustom_Heading_Rec );

Begin
   If IsACustom_Heading_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
