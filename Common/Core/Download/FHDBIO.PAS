UNIT FHdbIO;

// This code was generated automatically by running FHGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES FHDEFS, FHIOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Disk_Bank_Account            = 20 ;
   tkEnd_Disk_Bank_Account              = 21 ;

FUNCTION  IsADisk_Bank_Account_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Disk_Bank_Account_Rec ( Var O : TDisk_Bank_Account_Rec ; Var F : TFHIOStream );
PROCEDURE Read_Disk_Bank_Account_Rec ( Var O : TDisk_Bank_Account_Rec ; Var F : TFHIOStream );
FUNCTION  New_Disk_Bank_Account_Rec : pDisk_Bank_Account_Rec ;
PROCEDURE Free_Disk_Bank_Account_Rec_Dynamic_Fields ( Var O : TDisk_Bank_Account_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES FHExceptions;
{  -------------------------------------------------------------------  }

CONST
  SUnitName           = 'FHDBIO';
  SBoundsError        = 'FHDBIO Error: %s is out of bounds [ %d %d ], value is %d';
  SInvalidPointer     = 'FHDBIO Error: Pointer is NIL in IsADisk_Bank_Account_Rec';
  SInvalidType        = 'FHDBIO Error: Type is invalid in IsADisk_Bank_Account_Rec';
  SInvalidEOR         = 'FHDBIO Error: EOR is missing in IsADisk_Bank_Account_Rec';
  SUnknownToken       = 'FHDBIO Error: Unknown token %d in Read_Disk_Bank_Account_Rec';
  SInsufficientMemory = 'FHDBIO Error: Out of memory in New_Disk_Bank_Account_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
  If ( Value >= Min ) and
     ( Value <= Max ) then exit;
  Raise FHArrayBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkdbAccount_Number                   = 22 ;
   tkdbOriginal_Account_Number          = 23 ;
   tkdbAccount_Name                     = 24 ;
   tkdbFile_Code                        = 25 ;
   tkdbCost_Code                        = 26 ;
   tkdbBank_Prefix                      = 27 ;
   tkdbBank_Name                        = 28 ;
   tkdbCan_Redate_Transactions          = 29 ;
   tkdbContinued_On_Next_Disk           = 30 ;
   tkdbOpening_Balance                  = 31 ;
   tkdbClosing_Balance                  = 32 ;
   tkdbDebit_Total                      = 33 ;
   tkdbCredit_Total                     = 34 ;
   tkdbFirst_Transaction_Date           = 35 ;
   tkdbLast_Transaction_Date            = 36 ;
   tkdbNo_Of_Transactions               = 37 ;
   tkdbIs_New_Account                   = 38 ;
   tkdbInternal_Account_Number          = 39 ;
   tkdbAccount_LRN                      = 40 ;
   tkdbCurrency                         = 41 ;
   tkdbInstitution_ID                   = 42 ;
   tkdbFrequency_ID                     = 43 ;
   tkdbIs_Provisional                   = 44 ;

{  -------------------------------------------------------------------  }

FUNCTION IsADisk_Bank_Account_Rec ( P : Pointer ): Boolean;

Begin
  If P=NIL then
     Raise FHNilPointerException.Create( SInvalidPointer );
  With PDisk_Bank_Account_Rec ( P )^ do Begin
    If dbRecord_Type <> tkBegin_Disk_Bank_Account then
      Raise FHCorruptMemoryException.Create( SInvalidType );
    If dbEOR <> tkEnd_Disk_Bank_Account then
      Raise FHCorruptMemoryException.Create( SInvalidEOR );
  end;
  Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Disk_Bank_Account_Rec ( Var O : TDisk_Bank_Account_Rec ; Var F : TFHIOStream );

Begin
   If IsADisk_Bank_Account_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Disk_Bank_Account );
      F.WriteShortStringValue( tkdbAccount_Number , dbAccount_Number );
      F.WriteShortStringValue( tkdbOriginal_Account_Number , dbOriginal_Account_Number );
      F.WriteShortStringValue( tkdbAccount_Name , dbAccount_Name );
      F.WriteShortStringValue( tkdbFile_Code , dbFile_Code );
      F.WriteShortStringValue( tkdbCost_Code , dbCost_Code );
      F.WriteShortStringValue( tkdbBank_Prefix , dbBank_Prefix );
      F.WriteShortStringValue( tkdbBank_Name , dbBank_Name );
      F.WriteBooleanValue( tkdbCan_Redate_Transactions , dbCan_Redate_Transactions );
      F.WriteBooleanValue( tkdbContinued_On_Next_Disk , dbContinued_On_Next_Disk );
      F.WriteInt64Value( tkdbOpening_Balance , dbOpening_Balance );
      F.WriteInt64Value( tkdbClosing_Balance , dbClosing_Balance );
      F.WriteInt64Value( tkdbDebit_Total , dbDebit_Total );
      F.WriteInt64Value( tkdbCredit_Total , dbCredit_Total );
      F.WriteIntegerValue( tkdbFirst_Transaction_Date , dbFirst_Transaction_Date );
      F.WriteIntegerValue( tkdbLast_Transaction_Date , dbLast_Transaction_Date );
      F.WriteIntegerValue( tkdbNo_Of_Transactions , dbNo_Of_Transactions );
      F.WriteBooleanValue( tkdbIs_New_Account , dbIs_New_Account );
      F.WriteShortStringValue( tkdbInternal_Account_Number , dbInternal_Account_Number );
      F.WriteIntegerValue( tkdbAccount_LRN , dbAccount_LRN );
      F.WriteShortStringValue( tkdbCurrency , dbCurrency );
      F.WriteIntegerValue( tkdbInstitution_ID , dbInstitution_ID );
      F.WriteIntegerValue( tkdbFrequency_ID , dbFrequency_ID );
      F.WriteBooleanValue( tkdbIs_Provisional , dbIs_Provisional );
      F.WriteToken( tkEnd_Disk_Bank_Account );
   end;
end; { of Write_Disk_Bank_Account_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Disk_Bank_Account_Rec ( Var O : TDisk_Bank_Account_Rec; Var F : TFHIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Disk_Bank_Account_Rec_Size, 0 );
   O.dbRecord_Type := tkBegin_Disk_Bank_Account;
   O.dbEOR := tkEnd_Disk_Bank_Account;
   Token := tkBegin_Disk_Bank_Account;

   While Token <> tkEnd_Disk_Bank_Account do With O do
   Begin
      Case Token of
         tkBegin_Disk_Bank_Account :; { Do Nothing }
         tkEnd_Disk_Bank_Account :; { Do Nothing }
         tkdbAccount_Number                   : dbAccount_Number := F.ReadShortStringValue;
         tkdbOriginal_Account_Number          : dbOriginal_Account_Number := F.ReadShortStringValue;
         tkdbAccount_Name                     : dbAccount_Name := F.ReadShortStringValue;
         tkdbFile_Code                        : dbFile_Code := F.ReadShortStringValue;
         tkdbCost_Code                        : dbCost_Code := F.ReadShortStringValue;
         tkdbBank_Prefix                      : dbBank_Prefix := F.ReadShortStringValue;
         tkdbBank_Name                        : dbBank_Name := F.ReadShortStringValue;
         tkdbCan_Redate_Transactions          : dbCan_Redate_Transactions := F.ReadBooleanValue;
         tkdbContinued_On_Next_Disk           : dbContinued_On_Next_Disk := F.ReadBooleanValue;
         tkdbOpening_Balance                  : dbOpening_Balance := F.ReadInt64Value;
         tkdbClosing_Balance                  : dbClosing_Balance := F.ReadInt64Value;
         tkdbDebit_Total                      : dbDebit_Total := F.ReadInt64Value;
         tkdbCredit_Total                     : dbCredit_Total := F.ReadInt64Value;
         tkdbFirst_Transaction_Date           : dbFirst_Transaction_Date := F.ReadIntegerValue;
         tkdbLast_Transaction_Date            : dbLast_Transaction_Date := F.ReadIntegerValue;
         tkdbNo_Of_Transactions               : dbNo_Of_Transactions := F.ReadIntegerValue;
         tkdbIs_New_Account                   : dbIs_New_Account := F.ReadBooleanValue;
         tkdbInternal_Account_Number          : dbInternal_Account_Number := F.ReadShortStringValue;
         tkdbAccount_LRN                      : dbAccount_LRN := F.ReadIntegerValue;
         tkdbCurrency                         : dbCurrency := F.ReadShortStringValue;
         tkdbInstitution_ID                   : dbInstitution_ID := F.ReadIntegerValue;
         tkdbFrequency_ID                     : dbFrequency_ID := F.ReadIntegerValue;
         tkdbIs_Provisional                   : dbIs_Provisional := F.ReadBooleanValue;
         else
            Raise FHUnknownTokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Disk_Bank_Account_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Disk_Bank_Account_Rec : pDisk_Bank_Account_Rec ;

Var
   P : pDisk_Bank_Account_Rec;
Begin
   New( P );
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Disk_Bank_Account_Rec_Size, 0 );
      dbRecord_Type := tkBegin_Disk_Bank_Account;
      dbEOR         := tkEnd_Disk_Bank_Account;
   end
   else
      Raise FHInsufficientMemoryException.Create( SInsufficientMemory );
   New_Disk_Bank_Account_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Disk_Bank_Account_Rec_Dynamic_Fields ( Var O : TDisk_Bank_Account_Rec );

Begin
   If IsADisk_Bank_Account_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
