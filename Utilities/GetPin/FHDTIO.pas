UNIT FHdtIO;

// This code was generated automatically by running FHGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES FHDEFS, FHIOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Disk_Transaction             = 30 ;
   tkEnd_Disk_Transaction               = 31 ;

FUNCTION  IsADisk_Transaction_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Disk_Transaction_Rec ( Var O : TDisk_Transaction_Rec ; Var F : TFHIOStream );
PROCEDURE Read_Disk_Transaction_Rec ( Var O : TDisk_Transaction_Rec ; Var F : TFHIOStream );
FUNCTION  New_Disk_Transaction_Rec : pDisk_Transaction_Rec ;
PROCEDURE Free_Disk_Transaction_Rec_Dynamic_Fields ( Var O : TDisk_Transaction_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES FHExceptions;
{  -------------------------------------------------------------------  }

CONST
  SUnitName           = 'FHDTIO';
  SBoundsError        = 'FHDTIO Error: %s is out of bounds [ %d %d ], value is %d';
  SInvalidPointer     = 'FHDTIO Error: Pointer is NIL in IsADisk_Transaction_Rec';
  SInvalidType        = 'FHDTIO Error: Type is invalid in IsADisk_Transaction_Rec';
  SInvalidEOR         = 'FHDTIO Error: EOR is missing in IsADisk_Transaction_Rec';
  SUnknownToken       = 'FHDTIO Error: Unknown token %d in Read_Disk_Transaction_Rec';
  SInsufficientMemory = 'FHDTIO Error: Out of memory in New_Disk_Transaction_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
  If ( Value >= Min ) and
     ( Value <= Max ) then exit;
  Raise FHArrayBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkdtBankLink_ID                      = 32 ;
   tkdtEffective_Date                   = 33 ;
   tkdtOriginal_Date                    = 34 ;
   tkdtEntry_Type                       = 35 ;
   tkdtBank_Type_Code_OZ_Only           = 36 ;
   tkdtDefault_Code_OZ_Only             = 37 ;
   tkdtReference                        = 38 ;
   tkdtAnalysis_Code_NZ_Only            = 39 ;
   tkdtParticulars_NZ_Only              = 40 ;
   tkdtOther_Party_NZ_Only              = 41 ;
   tkdtOrig_BB                          = 42 ;
   tkdtAmount                           = 43 ;
   tkdtGST_Amount                       = 44 ;
   tkdtGST_Amount_Known                 = 45 ;
   tkdtNarration                        = 46 ;
   tkdtQuantity                         = 47 ;

{  -------------------------------------------------------------------  }

FUNCTION IsADisk_Transaction_Rec ( P : Pointer ): Boolean;

Begin
  If P=NIL then
     Raise FHNilPointerException.Create( SInvalidPointer );
  With PDisk_Transaction_Rec ( P )^ do Begin
    If dtRecord_Type <> tkBegin_Disk_Transaction then
      Raise FHCorruptMemoryException.Create( SInvalidType );
    If dtEOR <> tkEnd_Disk_Transaction then
      Raise FHCorruptMemoryException.Create( SInvalidEOR );
  end;
  Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Disk_Transaction_Rec ( Var O : TDisk_Transaction_Rec ; Var F : TFHIOStream );

Begin
   If IsADisk_Transaction_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Disk_Transaction );
      F.WriteIntegerValue( tkdtBankLink_ID , dtBankLink_ID );
      F.WriteIntegerValue( tkdtEffective_Date , dtEffective_Date );
      F.WriteIntegerValue( tkdtOriginal_Date , dtOriginal_Date );
      F.WriteByteValue( tkdtEntry_Type , dtEntry_Type );
      F.WriteShortStringValue( tkdtBank_Type_Code_OZ_Only , dtBank_Type_Code_OZ_Only );
      F.WriteShortStringValue( tkdtDefault_Code_OZ_Only , dtDefault_Code_OZ_Only );
      F.WriteShortStringValue( tkdtReference , dtReference );
      F.WriteShortStringValue( tkdtAnalysis_Code_NZ_Only , dtAnalysis_Code_NZ_Only );
      F.WriteShortStringValue( tkdtParticulars_NZ_Only , dtParticulars_NZ_Only );
      F.WriteShortStringValue( tkdtOther_Party_NZ_Only , dtOther_Party_NZ_Only );
      F.WriteShortStringValue( tkdtOrig_BB , dtOrig_BB );
      F.WriteInt64Value( tkdtAmount , dtAmount );
      F.WriteInt64Value( tkdtGST_Amount , dtGST_Amount );
      F.WriteBooleanValue( tkdtGST_Amount_Known , dtGST_Amount_Known );
      F.WriteShortStringValue( tkdtNarration , dtNarration );
      F.WriteInt64Value( tkdtQuantity , dtQuantity );
      F.WriteToken( tkEnd_Disk_Transaction );
   end;
end; { of Write_Disk_Transaction_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Disk_Transaction_Rec ( Var O : TDisk_Transaction_Rec; Var F : TFHIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Disk_Transaction_Rec_Size, 0 );
   O.dtRecord_Type := tkBegin_Disk_Transaction;
   O.dtEOR := tkEnd_Disk_Transaction;
   Token := tkBegin_Disk_Transaction;

   While Token <> tkEnd_Disk_Transaction do With O do
   Begin
      Case Token of
         tkBegin_Disk_Transaction :; { Do Nothing }
         tkEnd_Disk_Transaction :; { Do Nothing }
         tkdtBankLink_ID                      : dtBankLink_ID := F.ReadIntegerValue;
         tkdtEffective_Date                   : dtEffective_Date := F.ReadIntegerValue;
         tkdtOriginal_Date                    : dtOriginal_Date := F.ReadIntegerValue;
         tkdtEntry_Type                       : dtEntry_Type := F.ReadByteValue;
         tkdtBank_Type_Code_OZ_Only           : dtBank_Type_Code_OZ_Only := F.ReadShortStringValue;
         tkdtDefault_Code_OZ_Only             : dtDefault_Code_OZ_Only := F.ReadShortStringValue;
         tkdtReference                        : dtReference := F.ReadShortStringValue;
         tkdtAnalysis_Code_NZ_Only            : dtAnalysis_Code_NZ_Only := F.ReadShortStringValue;
         tkdtParticulars_NZ_Only              : dtParticulars_NZ_Only := F.ReadShortStringValue;
         tkdtOther_Party_NZ_Only              : dtOther_Party_NZ_Only := F.ReadShortStringValue;
         tkdtOrig_BB                          : dtOrig_BB := F.ReadShortStringValue;
         tkdtAmount                           : dtAmount := F.ReadInt64Value;
         tkdtGST_Amount                       : dtGST_Amount := F.ReadInt64Value;
         tkdtGST_Amount_Known                 : dtGST_Amount_Known := F.ReadBooleanValue;
         tkdtNarration                        : dtNarration := F.ReadShortStringValue;
         tkdtQuantity                         : dtQuantity := F.ReadInt64Value;
         else
            Raise FHUnknownTokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Disk_Transaction_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Disk_Transaction_Rec : pDisk_Transaction_Rec ;

Var
   P : pDisk_Transaction_Rec;
Begin
   New( P );
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Disk_Transaction_Rec_Size, 0 );
      dtRecord_Type := tkBegin_Disk_Transaction;
      dtEOR         := tkEnd_Disk_Transaction;
   end
   else
      Raise FHInsufficientMemoryException.Create( SInsufficientMemory );
   New_Disk_Transaction_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Disk_Transaction_Rec_Dynamic_Fields ( Var O : TDisk_Transaction_Rec );

Begin
   If IsADisk_Transaction_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
