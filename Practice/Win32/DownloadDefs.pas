unit DownloadDefs;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//contains the type declarations and const values for the download routines
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

!! No longer Used !!

interface
uses
   MoneyDef;

type
   NZDiskIDRec = Packed Record
      idFileType     : String[8]; { #08 'BankLink' }
      idClientCode   : String[8];
      idClientName   : String[20];
      idDate         : LongInt;
      idSerialNo     : String[11];
      idVersion      : Byte;
      idSequenceNo   : Byte;
      idNoInSet      : Byte;
      idLastDisk     : Boolean;
      idDiskNumber   : LongInt;
      idCRC          : LongWord;
      idSpare        : Array[1..120] of Byte;
   end;

TYPE
   PaxusDateRec = Array[1..6] of Char;

   c20 = Array[1..20] of Char;
   c13 = Array[1..13] of Char;
   c12 = Array[1..12] of Char;
   c11 = Array[1..11] of Char;

   DirectorySlot = Packed Record Case Boolean of
      FALSE : ( DiskHeader :  Packed Record
                                 Disk_Code         : c13;
                                 Disk_Name         : c20;
                                 Creation_Date     : PaxusDateRec;
                                 Floppy_Desc       : c11;
                                 Floppy_Version    : Byte;
                                 Last_Disk_In_Set  : Char;
                                 Sequence_No       : Byte;
                                 Number_In_Set     : Byte;
                                 Disk_Number       : LongInt;
                                 Spare_1           : Array[1..6] of Byte;
                              end; );
      TRUE  : ( AcctHeader :  Packed Record
                                 Cust_Code      : c13;
                                 Cust_Name      : c20;
                                 Cust_FullCode  : c20;
                                 Spare_2        : Array[1..6] of Char;
                                 Start_Block    : SmallInt;
                                 No_of_Blocks   : SmallInt;
                                 Continued      : Byte;
                              end; );
   end;

   pDirectory = ^tDirectory;
   tDirectory = Packed Array[0..255] of DirectorySlot;

   PaxusDataRecType = Packed Record
     Case Char OF
        ' ' : ( Outline : Packed Record
                             RecType : Char;
                             Spare   : Array[1..83] of Char;
                          end; );
        'A' : ( Header  : Packed Record
                             RecType        : Char;            {A}
                             ClientAcct     : c13;
                             ClientName     : c20;
                             CreateDate     : PaxusDateRec;
                             CostCode       : Array[ 1..8] Of Char;
                             Spare          : Array[1..36] of Char;
                             {
                             Spare          : Array[1..44] of Char;
                             }
                          end; );
        'B' : ( Tran    : Packed Record
                             RecType        : Char;            {B}
                             TranCode       : Byte; { û }
                             Amount         : c13;  { û }
                             Reference      : c12;  { û }
                             Particulars    : c12;  { û }
                             Analysis       : c12;  { û }
                             PostDate       : PaxusDateRec; { û }
                             OrigBB         : Array[1..6]  of Char; { û }
                             InputSource    : Byte; { û }
                             OtherParty     : c20;  { û }
                          end; );
        'C' : ( Tail    : Packed Record
                             RecType        : Char;            {C}
                             Debit          : c13;
                             Credit         : c13;
                             Nett           : c13;
                             Grand          : c13;
                             Number         : c13;
                             Charges        : c13;
                             Spare          : Array[1..5] of Char;
                             { Changed 17-08-98
                             Spare          : Array[1..18] of Char;
                             }
                          end; );
     end;

   E_Sector_Rec = Packed Record
      Slot     : Array[1..6] of PaxusDataRecType;
      Unused   : Array[1..8] of Byte;
   end;

   tSector = Array[ 1..512 ] of Byte;

TYPE
   OZDiskIDRec =  Packed  Record
      idFileType     : String[6]; { #06 'OZLink' }
      idClientCode   : String[8];
      idClientName   : String[40];
      idDate         : Longint;
      idFileName     : String[12];
      idSequenceNo   : Byte;
      idNoInSet      : Byte;
      idLastDisk     : Boolean;
      idDiskNumber   : LongInt;
      idVersion      : String[4];
      idCRC          : LongWord;
      idSpare        : Array[1..128] of Byte;
   end;

CONST
    MaxTrx = 8000;

TYPE
   Disk_Hdr_Rec  =  Packed  Record { 128 Bytes }
      Disk_Version      : Array[1..4] of Char;
      Disk_ID           : LongInt; { Invoice Number }
      Disk_Save_Cnt     : Smallint; { 2 byte integer}
      Cust_Code         : Array[1..10] of Char;
      Cust_Name         : Array[1..40] of Char;
      Disk_Created      : LongInt;
      Disk_NoAccs       : LongInt;
      Disk_NoTrx        : LongInt;
      Disk_AccCharges   : LongInt;
      Disk_Charge       : LongInt;
      Disk_Gross        : LongInt;
      Disk_Tax          : LongInt;
      Disk_Net          : LongInt;
      Disk_MonthNo      : SmallInt;
      Disk_YearNo       : SmallInt;
      Disk_Name         : Array[1..12] of Char; { Filename }
      Last_Disk_In_Set  : Char; { 'N' or 'Y' }
      Sequence_No       : Byte;
      Number_In_Set     : Byte;
      Disk_Number       : LongInt;
      Disk_CRC          : LongWord;
      Disk_Spare        : Array[1..9] of Byte;
   end;

   Acc_Dir_Rec  =  Packed  Record { 128 bytes }
      Acc_Bank_Code     : Array[1..20] of Char;
      Acc_Name          : Array[1..40] of Char;
      Acc_File_Code     : Array[1..10] of Char;
      Acc_TC_Code       : Array[1..10] of Char;
      Acc_NoTrx         : LongInt;
      Acc_DR_Total      : Money;
      Acc_CR_Total      : Money;
      Acc_New_Fee       : LongInt;
      Acc_Std_Fee       : LongInt;
      Acc_Vol_Fee       : LongInt;
      Acc_Gross         : LongInt;
      Acc_DateFirst     : Longint;
      Acc_DateLast      : Longint;
      Acc_eStart        : SmallInt;
      Acc_eFinish       : SmallInt;
   end;

   Dsk_Entry_Rec =  Packed Record { 80 Bytes }
      dDate             : LongInt; { 4 }
      dType             : Byte;
      dBankTypeCode     : Array[1..6] of Char;
      dRefce            : Array[1..12] of Char;
      dCode             : Array[1..6] of Char;
      dAmount           : LongInt; { 4 }
      dNarration        : Array[1..40] of Char;
      dSpare            : Array[1..7] of Char;
   end;

CONST
   Entries_Per_Sector = 6;

TYPE
   OZ_E_Sector_Rec  =  Packed Record
      Slot  : Array[1..Entries_Per_Sector] of Dsk_Entry_Rec;
      Spare : Array[1..32] of Byte;
   end;

TYPE
   POZDirectory = ^TOZDirectory;
   TOZDirectory = Packed Record
   Case Boolean of
      True  : ( AccInfo  : Array[1..256] of Acc_Dir_Rec );
      False : ( DiskHdr  : Disk_Hdr_Rec                 );
   end;



//******************************************************************************
implementation

const
   UnitName = 'DOWNLOADDEFS';
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
