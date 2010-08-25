unit NZTypes;

// ----------------------------------------------------------------------------
interface
// ----------------------------------------------------------------------------

Type
  c6  = Array[1..6]  of Char;
  c11 = Array[1..11] of Char;
  c12 = Array[1..12] of Char;
  c13 = Array[1..13] of Char;
  c20 = Array[1..20] of Char;
  c30 = Array[1..30] of Char;

Procedure Int64ToC13( CONST A : Int64; Var PA : c13 );
Function  C13ToInt64( PA : c13 ): Int64;

Type
  PSector     = ^TSector;
  TSector     = Array[0..511] of Byte;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  PaxusDataRecTypePtr = ^PaxusDataRecType;

  PaxusDataRecType = Packed Record
    Case Char OF
       ' ' : (
          Outline : Packed Record
             RecType : Char;
             Spare   : Array[1..83] of Char;
          end; );

       'A' : (
          Header  : Packed Record
             RecType        : Char;            {A}
             ClientAcct     : c13;
             ClientName     : c20;
             CreateDate     : c6;
             CostCode       : Array[ 1..8] Of Char;
             Spare          : Array[1..36] of Char;
             {
             Spare          : Array[1..44] of Char;
             }
          end; );

       'B' : (
          Tran : Packed Record
             RecType        : Char;            {B}
             TranCode       : Byte; { û }
             Amount         : c13;  { û }
             Reference      : c12;  { û }
             Particulars    : c12;  { û }
             Analysis       : c12;  { û }
             PostDate       : c6; { û }
             OrigBB         : c6; { û }
             InputSource    : Byte; { û }
             OtherParty     : c20;  { û }
          end; );
       'C' : (
          Tail : Packed Record
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

  POldAccountHeader = ^OldAccountHeader;
  OldAccountHeader = Packed Record
    Cust_Code      : c13;
    Cust_Name      : c20;
    Cust_FullCode  : c20;
    Spare_2        : Array[1..6] of Char;
    Start_Block    : Word;
    No_of_Blocks   : Word;
    Continued      : Byte;
  end;

  NewAccountHeader = Packed Record
    Old               : OldAccountHeader;
    Acc_Bank          : Byte       ;
    Acc_Branch        : Word       ;
    Acc_Account       : LongInt    ;
    Acc_Suffix        : Word       ;
    Acc_Name          : String[40];
    Acc_File_Code     : String[8];
    Acc_TC_Code       : String[8];
    Acc_Is_New        : Boolean;
    Acc_NoTrx         : LongInt;
    Acc_DR_Total      : Comp;
    Acc_CR_Total      : Comp;
    Acc_New_Fee       : Comp;
    Acc_Std_Fee       : Comp;
    Acc_Vol_Fee       : Comp;
    Acc_Gross         : Comp;
    Acc_DateFirst     : LongInt;
    Acc_DateLast      : LongInt;
  end;

  OldDiskHeader = Packed Record
    Disk_Code         : c13;
    Disk_Name         : c20;
    Creation_Date     : c6;
    Floppy_Desc       : c11;
    Floppy_Version    : Byte;
    Last_Disk_In_Set  : Char;
    Sequence_No       : Byte;
    Number_In_Set     : Byte;
    Disk_Number       : Integer;
    Disk_CRC          : Integer;
    Spare_1           : Array[1..2] of Byte;
  end;

  NewDiskHeader = Packed Record
     Old            : OldDiskHeader;
     Invoice_No     : LongInt; { Invoice Number }
     Cust_Code      : String[8];
     Cust_Name      : String[40];
     Disk_Created   : LongInt;
     Disk_NoAccs    : LongInt;
     Disk_NoTrx     : LongInt;
     Disk_Transfer  : Comp;
     Disk_Rental    : Comp;
     Disk_Account   : Comp;
     Disk_Volume    : Comp;
     Disk_Loads     : Comp;
     Disk_Delivery  : Comp;
     Disk_Charge    : Comp;
     Disk_Gross     : Comp;
     Disk_Tax       : Comp;
     Disk_Total     : Comp;
     Disk_FileName  : String[12];
  end;

  PNZSuperDirectory = ^TNZSuperDirectory;
  TNZSuperDirectory = Packed Record
     Header   : NewDiskHeader;
     Accounts : Array[1..255] of NewAccountHeader;
  end;

  PNZDiskImage = ^TNZDiskImage;
  TNZDiskImage = Packed Record
    RT86Directory : Array[ 0..13 ] of TSector;
    Header        : OldDiskHeader;
    Directory     : Array[ 1..255  ] of OldAccountHeader;
    EntryBlocks   : Array[ 0..1393 ] of E_Sector_Rec;
  end;

  NZDiskIDRec = Packed Record
    idFileType     : String[8]; { #08 'BankLink' }
    idClientCode   : String[8];
    idClientName   : String[20];
    idDate         : Integer;
    idSerialNo     : String[11];
    idVersion      : Byte;
    idSequenceNo   : Byte;
    idNoInSet      : Byte;
    idLastDisk     : Boolean;
    idDiskNumber   : LongInt;
    idCRC          : integer;
    idSpare        : Array[1..120] of Byte;
  end;

// ----------------------------------------------------------------------------
implementation uses DiskUtils;
// ----------------------------------------------------------------------------

Procedure Int64ToC13( CONST A : Int64; Var PA : c13 );

Var
   S  : String[13];
   i  : Integer;
Begin
   Str( abs( A ):12, S );
   If A<0 then S[1]:='-';
   For i := 2 TO Length( S ) do If S[i]=' ' then S[i]:='0';
   S := Copy( S, 1, 10 ) + '.' + Copy( S, 11, 2 );
   Move( S[1], PA[1], SizeOf( PA ) );
End;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function C13ToInt64( PA : c13 ): Int64;
var
  Is_Negative : Boolean;
  S           : String[13];
  p           : Byte;
  c           : Int64;
  Error       : Integer;
begin
   S:=A2S( PA, 13 );
   Is_Negative:=( S[1]='-' ); If Is_Negative then S[1]:=' ';
   p:=pos( '.',S );
   While p>0 do
   begin
     Delete( S,p,1 );
     p:=pos( '.',S );
   end;
   Val( S,c,Error );
   If Is_Negative then c:=-c;
   Result := c;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
