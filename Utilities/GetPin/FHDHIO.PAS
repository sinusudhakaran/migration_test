UNIT FHdhIO;

// This code was generated automatically by running FHGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES FHDEFS, FHIOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Disk_Header                  = 10 ;
   tkEnd_Disk_Header                    = 11 ;

FUNCTION  IsADisk_Header_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Disk_Header_Rec ( Var O : TDisk_Header_Rec ; Var F : TFHIOStream );
PROCEDURE Read_Disk_Header_Rec ( Var O : TDisk_Header_Rec ; Var F : TFHIOStream );
FUNCTION  New_Disk_Header_Rec : pDisk_Header_Rec ;
PROCEDURE Free_Disk_Header_Rec_Dynamic_Fields ( Var O : TDisk_Header_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES FHExceptions;
{  -------------------------------------------------------------------  }

CONST
  SUnitName           = 'FHDHIO';
  SBoundsError        = 'FHDHIO Error: %s is out of bounds [ %d %d ], value is %d';
  SInvalidPointer     = 'FHDHIO Error: Pointer is NIL in IsADisk_Header_Rec';
  SInvalidType        = 'FHDHIO Error: Type is invalid in IsADisk_Header_Rec';
  SInvalidEOR         = 'FHDHIO Error: EOR is missing in IsADisk_Header_Rec';
  SUnknownToken       = 'FHDHIO Error: Unknown token %d in Read_Disk_Header_Rec';
  SInsufficientMemory = 'FHDHIO Error: Out of memory in New_Disk_Header_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
  If ( Value >= Min ) and
     ( Value <= Max ) then exit;
  Raise FHArrayBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkdhCountry_Code                     = 12 ;
   tkdhVersion                          = 13 ;
   tkdhFile_SubType                     = 14 ;
   tkdhClient_Code                      = 15 ;
   tkdhClient_Name                      = 16 ;
   tkdhDisk_Number                      = 17 ;
   tkdhNo_Of_Disks_in_Set               = 18 ;
   tkdhSequence_In_Set                  = 19 ;
   tkdhCreation_Date                    = 20 ;
   tkdhFile_Name                        = 21 ;
   tkdhFloppy_Desc_NZ_Only              = 22 ;
   tkdhTrue_File_Name                   = 23 ;
   tkdhNo_Of_Accounts                   = 24 ;
   tkdhNo_Of_Transactions               = 25 ;
   tkdhFirst_Transaction_Date           = 26 ;
   tkdhLast_Transaction_Date            = 27 ;

{  -------------------------------------------------------------------  }

FUNCTION IsADisk_Header_Rec ( P : Pointer ): Boolean;

Begin
  If P=NIL then
     Raise FHNilPointerException.Create( SInvalidPointer );
  With PDisk_Header_Rec ( P )^ do Begin
    If dhRecord_Type <> tkBegin_Disk_Header then
      Raise FHCorruptMemoryException.Create( SInvalidType );
    If dhEOR <> tkEnd_Disk_Header then
      Raise FHCorruptMemoryException.Create( SInvalidEOR );
  end;
  Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Disk_Header_Rec ( Var O : TDisk_Header_Rec ; Var F : TFHIOStream );

Begin
   If IsADisk_Header_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Disk_Header );
      F.WriteByteValue( tkdhCountry_Code , dhCountry_Code );
      F.WriteShortStringValue( tkdhVersion , dhVersion );
      F.WriteShortStringValue( tkdhFile_SubType , dhFile_SubType );
      F.WriteShortStringValue( tkdhClient_Code , dhClient_Code );
      F.WriteShortStringValue( tkdhClient_Name , dhClient_Name );
      F.WriteIntegerValue( tkdhDisk_Number , dhDisk_Number );
      F.WriteIntegerValue( tkdhNo_Of_Disks_in_Set , dhNo_Of_Disks_in_Set );
      F.WriteIntegerValue( tkdhSequence_In_Set , dhSequence_In_Set );
      F.WriteIntegerValue( tkdhCreation_Date , dhCreation_Date );
      F.WriteShortStringValue( tkdhFile_Name , dhFile_Name );
      F.WriteShortStringValue( tkdhFloppy_Desc_NZ_Only , dhFloppy_Desc_NZ_Only );
      F.WriteShortStringValue( tkdhTrue_File_Name , dhTrue_File_Name );
      F.WriteIntegerValue( tkdhNo_Of_Accounts , dhNo_Of_Accounts );
      F.WriteIntegerValue( tkdhNo_Of_Transactions , dhNo_Of_Transactions );
      F.WriteIntegerValue( tkdhFirst_Transaction_Date , dhFirst_Transaction_Date );
      F.WriteIntegerValue( tkdhLast_Transaction_Date , dhLast_Transaction_Date );
      F.WriteToken( tkEnd_Disk_Header );
   end;
end; { of Write_Disk_Header_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Disk_Header_Rec ( Var O : TDisk_Header_Rec; Var F : TFHIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Disk_Header_Rec_Size, 0 );
   O.dhRecord_Type := tkBegin_Disk_Header;
   O.dhEOR := tkEnd_Disk_Header;
   Token := tkBegin_Disk_Header;

   While Token <> tkEnd_Disk_Header do With O do
   Begin
      Case Token of
         tkBegin_Disk_Header :; { Do Nothing }
         tkEnd_Disk_Header :; { Do Nothing }
         tkdhCountry_Code                     : dhCountry_Code := F.ReadByteValue;
         tkdhVersion                          : dhVersion := F.ReadShortStringValue;
         tkdhFile_SubType                     : dhFile_SubType := F.ReadShortStringValue;
         tkdhClient_Code                      : dhClient_Code := F.ReadShortStringValue;
         tkdhClient_Name                      : dhClient_Name := F.ReadShortStringValue;
         tkdhDisk_Number                      : dhDisk_Number := F.ReadIntegerValue;
         tkdhNo_Of_Disks_in_Set               : dhNo_Of_Disks_in_Set := F.ReadIntegerValue;
         tkdhSequence_In_Set                  : dhSequence_In_Set := F.ReadIntegerValue;
         tkdhCreation_Date                    : dhCreation_Date := F.ReadIntegerValue;
         tkdhFile_Name                        : dhFile_Name := F.ReadShortStringValue;
         tkdhFloppy_Desc_NZ_Only              : dhFloppy_Desc_NZ_Only := F.ReadShortStringValue;
         tkdhTrue_File_Name                   : dhTrue_File_Name := F.ReadShortStringValue;
         tkdhNo_Of_Accounts                   : dhNo_Of_Accounts := F.ReadIntegerValue;
         tkdhNo_Of_Transactions               : dhNo_Of_Transactions := F.ReadIntegerValue;
         tkdhFirst_Transaction_Date           : dhFirst_Transaction_Date := F.ReadIntegerValue;
         tkdhLast_Transaction_Date            : dhLast_Transaction_Date := F.ReadIntegerValue;
         else
            Raise FHUnknownTokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Disk_Header_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Disk_Header_Rec : pDisk_Header_Rec ;

Var
   P : pDisk_Header_Rec;
Begin
   New( P );
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Disk_Header_Rec_Size, 0 );
      dhRecord_Type := tkBegin_Disk_Header;
      dhEOR         := tkEnd_Disk_Header;
   end
   else
      Raise FHInsufficientMemoryException.Create( SInsufficientMemory );
   New_Disk_Header_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Disk_Header_Rec_Dynamic_Fields ( Var O : TDisk_Header_Rec );

Begin
   If IsADisk_Header_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
