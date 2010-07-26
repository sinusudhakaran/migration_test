unit OZTypes;

// -----------------------------------------------------------------------------
interface
// -----------------------------------------------------------------------------

Const
  MaxTrx = 8000;

Type
  TOZDisk_Header_Rec  = Packed Record { 128 Bytes }
    Disk_Version      : Array[1..4] of Char;
    Disk_ID           : LongInt; { Invoice Number }
    Disk_Save_Cnt     : SmallInt;
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
    Disk_CRC          : LongInt;
    Disk_Spare        : Array[1..9] of Byte;
  end;

  POZDirectory_Rec = ^TOZDirectory_Rec;
  TOZDirectory_Rec = Packed Record { 128 bytes }
    Acc_Bank_Code     : Array[1..20] of Char;
    Acc_Name          : Array[1..40] of Char;
    Acc_File_Code     : Array[1..8] of Char;
    Acc_Spare         : Char;
    Acc_Has_Balances  : Boolean;
    Acc_TC_Code       : Array[1..10] of Char;
    Acc_NoTrx         : LongInt;
    Acc_DR_Total      : Comp;
    Acc_CR_Total      : Comp;
    Acc_New_Fee       : LongInt;
    Acc_Std_Fee       : LongInt;
    Acc_Vol_Fee       : LongInt;
    Acc_Gross         : LongInt;
    Acc_DateFirst     : LongInt;
    Acc_DateLast      : LongInt;
    Acc_eStart        : SmallInt;
    Acc_eFinish       : SmallInt;
  end;

  POZEntry_Rec = ^TOZEntry_Rec;
  TOZEntry_Rec = Packed Record { 80 Bytes }
    dDate             : LongInt; { 4 }
    dType             : Byte;
    dBankTypeCode     : Array[1..6] of Char;
    dRefce            : Array[1..12] of Char;
    dCode             : Array[1..6] of Char;
    dAmount           : LongInt; { 4 }
    dNarration        : Array[1..40] of Char;
    dSpare            : Array[1..7] of Char;
  end;

//------------------------------------------------------------------------------

Type
  TOZEntry_Sector = Packed Record
    Slot  : Array[ 1..6  ] of TOZEntry_Rec;
    Spare : Array[ 1..32 ] of Byte;
  end;

//------------------------------------------------------------------------------

Type
  PSector = ^TSector;
  TSector = Array[ 0..511 ] of Byte;

  POZDiskImage = ^TOZDiskImage;
  TOZDiskImage = Packed Record  // 1440 TSector
    RT86Directory : Array[ 0..13 ] of TSector;
    Header        : TOZDisk_Header_Rec;
    Directory     : Array[ 1..255 ] of TOZDirectory_Rec;
    SystemMsg     : Array[ 0..7 ] of TSector; // Unused
    ClientMsg     : Array[ 0..7 ] of TSector; // Unused
    Entries       : Array[ 1..1346 ] of TOZEntry_Sector;
  end;

//------------------------------------------------------------------------------

  OZDiskIDRec = Packed Record  // Written at start of Compressed Data Disk Image.  Not Compressed.
    idFileType     : String[6]; { #06 'OZLink' }
    idClientCode   : String[8];
    idClientName   : String[40];
    idDate         : Integer;
    idFileName     : String[12];
    idSequenceNo   : Byte;
    idNoInSet      : Byte;
    idLastDisk     : Boolean;
    idDiskNumber   : LongInt;
    idVersion      : String[4];
    idCRC          : Integer;
    idSpare        : Array[1..128] of Byte;
  end;

implementation

end.

