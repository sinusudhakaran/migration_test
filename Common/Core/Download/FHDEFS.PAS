Unit FHDEFS;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
Interface
{  -------------------------------------------------------------------  }

Const
   FH_IOLIB_Version : Integer = 110;
   FH_IOLIB_Date    = '21/01/11';
   DISK_FILE_VERSION  = 01;

{  -------------------------------------------------------------------  }

Type
   pDisk_Header_Rec                      = ^tDisk_Header_Rec ;
   pDisk_Bank_Account_Rec                = ^tDisk_Bank_Account_Rec ;
   pDisk_Transaction_Rec                 = ^tDisk_Transaction_Rec ;

{  -------------------------------------------------------------------  }

   tDisk_Header_Rec = Packed Record
      dhRecord_Type                      : Byte;
      dhCountry_Code                     : Byte;       { Stored }
      dhVersion                          : String[ 10 ];       { Stored }
      dhFile_SubType                     : String[ 8 ];       { Stored }
      dhClient_Code                      : String[ 8 ];       { Stored }
      dhClient_Name                      : String[ 60 ];       { Stored }
      dhDisk_Number                      : Integer;       { Stored }
      dhNo_Of_Disks_in_Set               : Integer;       { Stored }
      dhSequence_In_Set                  : Integer;       { Stored }
      dhCreation_Date                    : Integer;       { Stored }
      dhFile_Name                        : String[ 12 ];       { Stored }
      dhFloppy_Desc_NZ_Only              : String[ 11 ];       { Stored }
      dhTrue_File_Name                   : String[ 30 ];       { Stored }
      dhNo_Of_Accounts                   : Integer;       { Stored }
      dhNo_Of_Transactions               : Integer;       { Stored }
      dhFirst_Transaction_Date           : Integer;       { Stored }
      dhLast_Transaction_Date            : Integer;       { Stored }
      dhEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tDisk_Bank_Account_Rec = Packed Record
      dbRecord_Type                      : Byte;
      dbAccount_Number                   : String[ 20 ];       { Stored }
      dbOriginal_Account_Number          : String[ 30 ];       { Stored }
      dbAccount_Name                     : String[ 40 ];       { Stored }
      dbFile_Code                        : String[ 8 ];       { Stored }
      dbCost_Code                        : String[ 10 ];       { Stored }
      dbBank_Prefix                      : String[ 4 ];       { Stored }
      dbBank_Name                        : String[ 40 ];       { Stored }
      dbCan_Redate_Transactions          : Boolean;       { Stored }
      dbContinued_On_Next_Disk           : Boolean;       { Stored }
      dbOpening_Balance                  : Int64;       { Stored }
      dbClosing_Balance                  : Int64;       { Stored }
      dbDebit_Total                      : Int64;       { Stored }
      dbCredit_Total                     : Int64;       { Stored }
      dbFirst_Transaction_Date           : Integer;       { Stored }
      dbLast_Transaction_Date            : Integer;       { Stored }
      dbNo_Of_Transactions               : Integer;       { Stored }
      dbIs_New_Account                   : Boolean;       { Stored }
      dbInternal_Account_Number          : String[ 20 ];       { Stored }
      dbAccount_LRN                      : Integer;       { Stored }
      dbCurrency                         : String[ 3 ];       { Stored }
      dbInstitution_ID                   : Integer;       { Stored }
      dbFrequency_ID                     : Integer;       { Stored }
      dbIs_Provisional                   : Boolean;       { Stored }
      dbEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tDisk_Transaction_Rec = Packed Record
      dtRecord_Type                      : Byte;
      dtBankLink_ID                      : Integer;       { Stored }
      dtEffective_Date                   : Integer;       { Stored }
      dtOriginal_Date                    : Integer;       { Stored }
      dtEntry_Type                       : Byte;       { Stored }
      dtBank_Type_Code_OZ_Only           : String[ 6 ];       { Stored }
      dtDefault_Code_OZ_Only             : String[ 6 ];       { Stored }
      dtReference                        : String[ 12 ];       { Stored }
      dtAnalysis_Code_NZ_Only            : String[ 12 ];       { Stored }
      dtParticulars_NZ_Only              : String[ 12 ];       { Stored }
      dtOther_Party_NZ_Only              : String[ 20 ];       { Stored }
      dtOrig_BB                          : String[ 6 ];       { Stored }
      dtAmount                           : Int64;       { Stored }
      dtGST_Amount                       : Int64;       { Stored }
      dtGST_Amount_Known                 : Boolean;       { Stored }
      dtNarration                        : String[ 200 ];       { Stored }
      dtQuantity                         : Int64;       { Stored }
      dtBankLink_ID_H                    : Integer;       { Stored }
      dtEOR                              : Byte;
   end;

Const
   Disk_Header_Rec_Size                      = Sizeof( TDisk_Header_Rec ); 
   Disk_Bank_Account_Rec_Size                = Sizeof( TDisk_Bank_Account_Rec ); 
   Disk_Transaction_Rec_Size                 = Sizeof( TDisk_Transaction_Rec ); 

function CorrectFileName(aName: string): string;

{  -------------------------------------------------------------------  }
Implementation
{  -------------------------------------------------------------------  }

function CorrectFileName(aName: string): string;
begin
  if pos('.',aName)>0 then
    result:=aName
  else
    result:=Copy(aName,1,length(aName)-4)+'.'+Copy(aName,length(aName)-3,4);
end;

end.
