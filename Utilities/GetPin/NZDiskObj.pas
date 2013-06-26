unit NZDiskObj;

// ----------------------------------------------------------------------------
interface uses NFDiskObj,
  dbObj,
  BaseDisk,
  Classes;
// ----------------------------------------------------------------------------

type
  TNZDisk = class(TNewFormatDisk)
  protected
    function SaveToRT86Stream: TMemoryStream;
    function SaveSuperDirectoryStream: TMemoryStream;
    procedure LoadFromRT86Stream(const RT86Stream: TMemoryStream);
    function GetZipStream(const FileName: string): TMemoryStream;
  private
  public
    procedure Validate; override;
    function CanAddAccount: Boolean; override;
    function CanAddTransaction: Boolean; override;
    procedure SaveToFileOF(const FileName: string; const Attachments: TStringList); override;
    function LoadFromFileOF(const FileName: string;
      const AttachmentDir: string;
      const GetAttachments: Boolean): TStringList; override;
    { ------------------------------------------------------------------------ }
    procedure NewDisk(ClientCode, ClientName: string; CreatDate: integer;
      FileName, FloppyDesc, TrueFileName: string; DiskNo, SeqNo: integer);
    procedure AddAccount(Number, OriginalNumber, Name, FileCode, CostCode, BankCode,
      BankName, Currency: string;
      OpBalance: Int64; IsNew: Boolean;
      accLRN,instID: integer;
      FrequencyID: integer;
      InternalAccNumber: string='');
    procedure AddTransaction(var DBA: TDisk_Bank_Account;
      TransID: Integer; TransType: Byte;
      Amount, GSTAmount, Quantity: Int64; EffDate, OrigDate: Integer;
      Reference, Analysis, Particulars, OtherParty,
      OrigBB, Narration: string);
  end;

  // ----------------------------------------------------------------------------
implementation uses SysUtils,
  NZTypes,
  DiskUtils,
  VCLZip,
  FHDefs,
  dtList,
  CRC32,
  CRCFileUtils,
  CryptX,
  StStrS,
  StDate,
  StDateSt, (* ProcUtils, *)
  FHDTIO,
  StreamIO,
  FHExceptions,
  dbList,
  NFUtils,
  FileExtensionUtils;
// ----------------------------------------------------------------------------

const
  DefEpoch = 1970;
  MaxAccounts = 255;
  MaxTransactions = 7200;

  { TNZDisk }

function TNZDisk.CanAddAccount: Boolean;
// Rules deciding whether there's enough room for account or transaction on NZ disk are
// too complicated to implement them here - must stay in NZMake.
// (Passing of callback routines to this object would be required)
begin
  raise Exception.Create('TNZDisk.CanAddAccount should never be called');
  (*
    If dhFields.dhCountry_Code <> whNewZealand then Raise FHDataValidationException.CreateFmt( 'TNZDisk.CanAddAccount: Invalid country code %d', [ dhFields.dhCountry_Code ] );
    Result := ( dhAccount_List.ItemCount < MaxAccounts ) and ( dhFields.dhNo_of_Transactions < MaxTransactions );
  *)
end;
// ----------------------------------------------------------------------------

function TNZDisk.CanAddTransaction: Boolean;
// Rules deciding whether there's enough room for account or transaction on NZ disk are
// too complicated to implement them here - must stay in NZMake.
// (Passing of callback routines to this object would be required)
begin
  raise Exception.Create('TNZDisk.CanAddTransaction should never be called');
  (*
    If dhFields.dhCountry_Code <> whNewZealand then Raise FHDataValidationException.CreateFmt( 'TNZDisk.CanAddTransaction: Invalid country code %d', [ dhFields.dhCountry_Code ] );
    Result := ( dhAccount_List.ItemCount <= MaxAccounts ) and ( dhFields.dhNo_of_Transactions < MaxTransactions );
  *)
end;
//------------------------------------------------------------------------------

function TNZDisk.GetZipStream(const FileName: string): TMemoryStream;
const
  ChunkSize = 8192;
  ProcName = 'TNZDisk.GetZipStream';
var
  ID: NZDiskIDRec;
  Buffer: Pointer;
  CRC: LongInt;
  SaveCRC: LongInt;
  ZipStream: TMemoryStream;
  FileStream: TMemoryStream;
  NumRead: Integer;
  NumWritten: Integer;
begin
  (* Profile( 'TNZDisk.GetZipStream' ); *)
  Result := nil;
  if not FileExists(FileName) then
    raise FHException.CreateFmt('%s ERROR: the file %s does not exist', [ProcName, FileName]);
  { Generate the File Header Record }
  FileStream := TMemoryStream.Create;
  try
    FileStream.LoadFromFile(FileName);
    FileStream.Position := 0;
    FileStream.Read(ID, Sizeof(ID));

    if ID.idFileType <> 'BankLink' then
      raise FHException.CreateFmt('%s ERROR: the file %s is not a NZ BankLink DOS disk file',
        [ProcName, FileName]);
    if ID.idVersion <> 2 then
      raise FHException.CreateFmt('%s ERROR: the file %s is for version %d (2 expected)',
        [ProcName, FileName, ID.idVersion]);

    SaveCRC := ID.idCRC;
    CRC := 0;
    ID.idCRC := 0;

    UpdateCRC(CRC, ID, Sizeof(ID));

    ZipStream := TMemoryStream.Create;

    GetMem(Buffer, ChunkSize);
    try
      repeat
        NumRead := FileStream.Read(Buffer^, ChunkSize);
        if NumRead > 0 then
          begin
            UpdateCRC(CRC, Buffer^, NumRead);
            Decrypt(Buffer^, NumRead);
            NumWritten := ZipStream.Write(Buffer^, NumRead);
            if not (NumWritten = NumRead) then
              raise FHException.CreateFmt('%s ERROR: ZipStream write failed', [ProcName]);
          end;
      until NumRead < ChunkSize;
    finally
      FreeMem(Buffer, ChunkSize);
    end;
    if CRC <> SaveCRC then
      raise FHException.CreateFmt('%s ERROR: the file %s is corrupt - invalid CRC', [ProcName,
        FileName]);
    ZipStream.Position := 0;
    Result := ZipStream;
  finally
    FileStream.Free;
  end;
end;

// ----------------------------------------------------------------------------

function TNZDisk.LoadFromFileOF(const FileName, AttachmentDir: string;
  const GetAttachments: Boolean): TStringList;

const
  ProcName = 'TNZDisk.LoadFromFileOF';

var
  Files: TStringList;
  ZipStream: TMemoryStream;
  UnZipper: TVclZip;
  DataStream: TMemoryStream;
  FileStream: TMemoryStream;
  i: Integer;
  AttachmentName: string;
  Index: Integer;
begin
  (* Profile( ProcName ); *)
  Result := nil;
  ZipStream := nil;
  try
    ZipStream := GetZipStream(FileName);

    UnZipper := TVCLZip.Create(nil);
    Files := TStringList.Create;
    try
      UnZipper.ArchiveStream := ZipStream;
      UnZipper.ReadZip;

      for i := 0 to Pred(UnZipper.Count) do
        Files.Add(UnZipper.Filename[i]);
      Index := Files.IndexOf(ExtractFileName(FileName));
      if Index >= 0 then
        begin
          DataStream := TMemoryStream.Create;
          try
            UnZipper.UnZipToStream(DataStream, UnZipper.FullName[Index]);
            DataStream.Position := 0;
            Self.LoadFromRT86Stream(DataStream);
          finally
            DataStream.Free;
          end;
        end
      else
        raise FHException.CreateFmt('%s Error: Couldn''t find any data in the file %s', [ProcName,
          FileName]);

      if GetAttachments then
        begin
          Result := TStringList.Create;
          for i := 0 to Pred(UnZipper.Count) do
            begin
              if UnZipper.FileName[i] <> ExtractFileName(FileName) then
                begin { it's an attachment file }
                  FileStream := TMemoryStream.Create;
                  try
                    UnZipper.UnZipToStream(FileStream, UnZipper.FullName[i]);
                    FileStream.Position := 0;
                    AttachmentName := AttachmentDir + UnZipper.FileName[i];
                    FileStream.SaveToFile(AttachmentName);
                    Result.Add(AttachmentName);
                  finally
                    FileStream.Free;
                  end;
                end;
            end;
        end;
      UnZipper.ArchiveStream := nil;
    finally
      UnZipper.Free;
      Files.Free;
    end;
  finally
    ZipStream.Free;
  end;
end;

// ----------------------------------------------------------------------------

function TNZDisk.SaveToRT86Stream: TMemoryStream;

const
  F1: array[1..20] of Byte = ($FF, $11, $1C, $24, $21, $34, $21, $22, $21, $2E, $2B, $0E, $24, $29,
    $32, $21, $0E, $31, $20, $00);
  F2: array[1..20] of Byte = ($FF, $12, $1C, $24, $21, $34, $21, $22, $21, $2E, $2B, $0E, $24, $21,
    $34, $21, $2E, $32, $72, $05);

  ProcName = 'TNZDisk.SaveToRT86Stream';
var
  NZDiskImage: PNZDiskImage;
  eSecNo: Integer;
  eSlotNo: Integer;
  AcctNo: Integer;

  procedure NextSlot;
  begin
    if (eSlotNo = 6) then
      begin
        Inc(eSecNo);
        Assert((eSecNo >= 0) and (eSecNo <= 1393));
        FillChar(NZDiskImage.EntryBlocks[eSecNo], 512, #$20);
        eSlotNo := 0;
      end;
    Inc(eSlotNo);
  end;

  function CurrentSlot: PaxusDataRecTypePtr;
  begin
    Assert((eSecNo >= 0) and (eSecNo <= 1393));
    Assert(eSlotNo in [1..6]);
    Result := @NZDiskImage.EntryBlocks[eSecNo].Slot[eSlotNo];
  end;

  function CurrentDir: POldAccountHeader;
  begin
    Assert(AcctNo in [1..255]);
    Result := @NZDiskImage.Directory[AcctNo];
  end;

var
  Sector: TSector;
  i, t: Integer;
  DBA: TDisk_Bank_Account;
  P: PDisk_Transaction_Rec;

  AccountTotals:
  record
    Debit: Int64;
    Credit: Int64;
    Nett: Int64;
    Grand: Int64;
    Number: Int64;
  end;

  FileLen: Integer;

begin
  (* Profile( 'TNZDisk.SaveToRT86Stream' ); *)

  Validate;
  Assert(dhFields.dhCountry_Code = whNewZealand);
  Result := nil;
  GetMem(NZDiskImage, Sizeof(TNZDiskImage));
  try
    if not Assigned(NZDiskImage) then
      raise FHException.CreateFmt('%s Error: Unable to Create NZDiskImage', [ProcName]);
    FillChar(NZDiskImage^, Sizeof(TNZDiskImage), 0);

    { Fill the RT86Directory Structure }

    for i := 0 to 13 do
      begin
        FillChar(Sector, Sizeof(Sector), 0);
        Sector[0] := 255;
        case i of
          0:
            begin
              Sector[0] := $A0;
              Sector[1] := $05;
              Sector[2] := $0D;
              Sector[183] := $FF;
            end;
          1: Move(F1, Sector, Sizeof(F1));
          3: Move(F2, Sector, Sizeof(F2));
        end;
        Move(Sector, NZDiskImage.RT86Directory[i], 512);
      end;

    { Fill the NZDiskImage.Header Structure }

    S2A(dhFields.dhClient_Code, NZDiskImage.Header.Disk_Code, 13);
    S2A(dhFields.dhClient_Name, NZDiskImage.Header.Disk_Name, 20);
    S2A(StDateToDateString('ddmmyy', dhFields.dhCreation_Date, False),
      NZDiskImage.Header.Creation_Date, 6);
    S2A(dhFields.dhFloppy_Desc_NZ_Only, NZDiskImage.Header.Floppy_Desc, 11);

    NZDiskImage.Header.Disk_Number := dhFields.dhDisk_Number;
    NZDiskImage.Header.Floppy_Version := 02;
    NZDiskImage.Header.Sequence_No := dhFields.dhSequence_In_Set;
    NZDiskImage.Header.Number_In_Set := dhFields.dhNo_Of_Disks_in_Set;

    if dhFields.dhSequence_In_Set = dhFields.dhNo_Of_Disks_in_Set then
      NZDiskImage.Header.Last_Disk_In_Set := 'Y'
    else
      NZDiskImage.Header.Last_Disk_In_Set := 'N';

    eSecNo := -1;
    eSlotNo := -1;
    AcctNo := 0;

    for i := dhAccount_List.First to dhAccount_List.Last do
      begin
        DBA := dhAccount_List.Disk_Bank_Account_At(i);

        { Write the Header Record - Always start in a new Sector }

        Inc(eSecNo);
        eSlotNo := 1;
        FillChar(CurrentSlot.Header, Sizeof(PaxusDataRecType), #0);
        CurrentSlot.Header.RecType := 'A';
        S2A(DBA.dbFields.dbAccount_Number, CurrentSlot.Header.ClientAcct, 13);
        S2A(DBA.dbFields.dbAccount_Name, CurrentSlot.Header.ClientName, 20);
        S2A(StDateToDateString('ddmmyy', dhFields.dhCreation_Date, False),
          CurrentSlot.Header.CreateDate, 6);
        S2A(DBA.dbFields.dbCost_Code, CurrentSlot.Header.CostCode, 8);

        { Write the Directory Record }

        Inc(AcctNo);
        S2A(DBA.dbFields.dbAccount_Number, CurrentDir.Cust_Code, 13);
        S2A(DBA.dbFields.dbAccount_Name, CurrentDir.Cust_Name, 20);
        S2A(DBA.dbFields.dbAccount_Number, CurrentDir.Cust_FullCode, 20);
        CurrentDir.Start_Block := eSecNo;
        if DBA.dbFields.dbContinued_On_Next_Disk then
          CurrentDir.Continued := 1
        else
          CurrentDir.Continued := 0;

        { Write the Transactions }

        FillChar(AccountTotals, Sizeof(AccountTotals), 0);

        for t := DBA.dbTransaction_List.First to DBA.dbTransaction_List.Last do
          begin
            NextSlot;
            P := DBA.dbTransaction_List.Disk_Transaction_At(t);
            with CurrentSlot.Tran do
              begin
                RecType := 'B';
                TranCode := P.dtEntry_Type;
                Int64ToC13(P.dtAmount, Amount);
                S2A(P.dtAnalysis_Code_NZ_Only, Analysis, 12);
                S2A(P.dtReference, Reference, 12);
                S2A(P.dtParticulars_NZ_Only, Particulars, 12);
                S2A(StDateToDateString('ddmmyy', P.dtEffective_Date, False), PostDate, 6);
                S2A(P.dtOrig_BB, OrigBB, 6);
                InputSource := 0;
                S2A(P.dtOther_Party_NZ_Only, OtherParty, 20);
              end;
            with AccountTotals do
              begin
                Inc(Number);
                if (P.dtAmount < 0) then
                  Credit := Credit - P.dtAmount
                else
                  Debit := Debit + P.dtAmount;
              end;
          end; { of dbTransaction_List }

        { Write the Trailer }

        with AccountTotals do
          begin
            Nett := Debit - Credit;
            Grand := Debit + Credit;
          end;

        NextSlot;
        with CurrentSlot.Tail do
          begin
            RecType := 'C';
            Int64ToC13(AccountTotals.Debit, Debit);
            Int64ToC13(AccountTotals.Credit, Credit);
            Int64ToC13(AccountTotals.Nett, Nett);
            Int64ToC13(AccountTotals.Grand, Grand);
            Int64ToC13(AccountTotals.Number * 100, Number);
            Int64ToC13(0, Charges);
          end;
        { Update the Account Header }
        CurrentDir.No_of_Blocks := 1 + (eSecNo - CurrentDir.Start_Block);
        CurrentDir.Start_Block := Swap(CurrentDir.Start_Block);
        CurrentDir.No_of_Blocks := Swap(CurrentDir.No_of_Blocks);
      end; { of dhAccount_List }

    Result := TMemoryStream.Create;

    FileLen := Sizeof(NZDiskImage.RT86Directory) +
      Sizeof(NZDiskImage.Header) +
      Sizeof(NZDiskImage.Directory) +
      ((eSecNo + 1) * Sizeof(E_Sector_Rec));

    Result.Write(NZDiskImage^, FileLen);
    Result.Position := 0;
  finally
    FreeMem(NZDiskImage);
  end;
end;
//----------------------------------------------------------------------------

function TNZDisk.SaveSuperDirectoryStream: TMemoryStream;
const
  ProcName = 'TNZDisk.SaveSuperDirectoryStream';
var
  SuperDirectory: PNZSuperDirectory;
  eSecNo: Integer;
  eSlotNo: Integer;

  procedure NextSlot;
  begin // Simulate only
    if (eSlotNo = 6) then
      begin
        Inc(eSecNo);
        Assert((eSecNo >= 0) and (eSecNo <= 1393));
        eSlotNo := 0;
      end;
    Inc(eSlotNo);
  end;

var
  i, t: integer;
  DBA: TDisk_Bank_Account;
  FileLen: Integer;
begin
  (* Profile( 'TNZDisk.SaveSuperDirectoryStream' ); *)
  Validate;
  Assert(dhFields.dhCountry_Code = whNewZealand);
  Result := nil;
  GetMem(SuperDirectory, Sizeof(TNZSuperDirectory));
  try
    if not Assigned(SuperDirectory) then
      raise FHException.CreateFmt('%s Error: Unable to Create SuperDirectory', [ProcName]);
    FillChar(SuperDirectory^, Sizeof(TNZSuperDirectory), 0);

    S2A(dhFields.dhClient_Code, SuperDirectory.Header.Old.Disk_Code, 13); // Repeat old header
    S2A(dhFields.dhClient_Name, SuperDirectory.Header.Old.Disk_Name, 20);
    S2A(StDateToDateString('ddmmyy', dhFields.dhCreation_Date, False),
      SuperDirectory.Header.Old.Creation_Date, 6);
    S2A(dhFields.dhFloppy_Desc_NZ_Only, SuperDirectory.Header.Old.Floppy_Desc, 11);
    SuperDirectory.Header.Old.Disk_Number := dhFields.dhDisk_Number;
    SuperDirectory.Header.Old.Floppy_Version := 02;
    SuperDirectory.Header.Old.Sequence_No := dhFields.dhSequence_In_Set;
    SuperDirectory.Header.Old.Number_In_Set := dhFields.dhNo_Of_Disks_in_Set;
    if dhFields.dhSequence_In_Set = dhFields.dhNo_Of_Disks_in_Set then
      SuperDirectory.Header.Old.Last_Disk_In_Set := 'Y'
    else
      SuperDirectory.Header.Old.Last_Disk_In_Set := 'N';
    // Fill extended SuperDirectory header
    SuperDirectory.Header.Invoice_No := 0; // Never used
    SuperDirectory.Header.Cust_Code := dhFields.dhClient_Code;
    SuperDirectory.Header.Cust_Name := dhFields.dhClient_Name;
    SuperDirectory.Header.Disk_Created := dhFields.dhCreation_Date;
    SuperDirectory.Header.Disk_NoAccs := dhFields.dhNo_Of_Accounts;
    SuperDirectory.Header.Disk_NoTrx := dhFields.dhNo_Of_Transactions;
    SuperDirectory.Header.Disk_Transfer := 0; // Never used
    SuperDirectory.Header.Disk_Rental := 0; // Never used
    SuperDirectory.Header.Disk_Account := 0; // Never used
    SuperDirectory.Header.Disk_Volume := 0; // Never used
    SuperDirectory.Header.Disk_Loads := 0; // Never used
    SuperDirectory.Header.Disk_Delivery := 0; // Never used
    SuperDirectory.Header.Disk_Charge := 0; // Never used
    SuperDirectory.Header.Disk_Gross := 0; // Never used
    SuperDirectory.Header.Disk_Tax := 0; // Never used
    SuperDirectory.Header.Disk_Total := 0; // Never used
    SuperDirectory.Header.Disk_FileName := dhFields.dhFile_Name; // File name with dot

    eSecNo := -1;
    eSlotNo := -1;
    for i := dhAccount_List.First + 1 to dhAccount_List.Last + 1 do
      begin
        DBA := dhAccount_List.Disk_Bank_Account_At(i - 1);
        Inc(eSecNo);
        eSlotNo := 1;
        // Try to repeat old account header. Is this enough information? (Data location info was skipped)
        S2A(DBA.dbFields.dbAccount_Number, SuperDirectory.Accounts[i].Old.Cust_Code, 13);
        S2A(DBA.dbFields.dbAccount_Name, SuperDirectory.Accounts[i].Old.Cust_Name, 20);
        S2A(DBA.dbFields.dbAccount_Number, SuperDirectory.Accounts[i].Old.Cust_FullCode, 20);
        SuperDirectory.Accounts[i].Old.Start_Block := eSecNo;
        if DBA.dbFields.dbContinued_On_Next_Disk then
          SuperDirectory.Accounts[i].Old.Continued := 1
        else
          SuperDirectory.Accounts[i].Old.Continued := 0;

        for t := DBA.dbTransaction_List.First to DBA.dbTransaction_List.Last + 1 do
          // Simulate writing of transactions
          NextSlot;

        { Update old Account Header }
        SuperDirectory.Accounts[i].Old.No_of_Blocks := 1 + (eSecNo -
          SuperDirectory.Accounts[i].Old.Start_Block);
        SuperDirectory.Accounts[i].Old.Start_Block :=
          Swap(SuperDirectory.Accounts[i].Old.Start_Block);
        SuperDirectory.Accounts[i].Old.No_of_Blocks :=
          Swap(SuperDirectory.Accounts[i].Old.No_of_Blocks);

        // Fill extended account header
        SuperDirectory.Accounts[i].Acc_Bank := 0; // Now Unused
        SuperDirectory.Accounts[i].Acc_Branch := 0; // Now Unused
        SuperDirectory.Accounts[i].Acc_Account := 0; // Now Unused
        SuperDirectory.Accounts[i].Acc_Suffix := 0; // Now Unused
        SuperDirectory.Accounts[i].Acc_Name := DBA.dbFields.dbAccount_Name;
        SuperDirectory.Accounts[i].Acc_File_Code := DBA.dbFields.dbFile_Code;
        SuperDirectory.Accounts[i].Acc_TC_Code := DBA.dbFields.dbCost_Code;
        SuperDirectory.Accounts[i].Acc_NoTrx := DBA.dbFields.dbNo_Of_Transactions;
        SuperDirectory.Accounts[i].Acc_DR_Total := DBA.dbFields.dbDebit_Total;
        SuperDirectory.Accounts[i].Acc_CR_Total := -DBA.dbFields.dbCredit_Total;
        SuperDirectory.Accounts[i].Acc_New_Fee := 0; // Now Unused
        SuperDirectory.Accounts[i].Acc_Std_Fee := 0; // Now Unused
        SuperDirectory.Accounts[i].Acc_Vol_Fee := 0; // Now Unused
        SuperDirectory.Accounts[i].Acc_Gross := 0; // Now Unused
        SuperDirectory.Accounts[i].Acc_DateFirst := DBA.dbFields.dbFirst_Transaction_Date;
        SuperDirectory.Accounts[i].Acc_DateLast := DBA.dbFields.dbLast_Transaction_Date;
        SuperDirectory.Accounts[i].Acc_Is_New := DBA.dbFields.dbIs_New_Account;
      end;

    Result := TMemoryStream.Create;

    FileLen := Sizeof(SuperDirectory.Header) + (SuperDirectory.Header.Disk_NoAccs *
      Sizeof(NewAccountHeader));

    Result.Write(SuperDirectory^, FileLen);
    Result.Position := 0;
  finally
    FreeMem(SuperDirectory);
  end;
end;
//------------------------------------------------------------------------------

procedure TNZDisk.SaveToFileOF(const FileName: string; const Attachments: TStringList);
//save file in old format ( RT86)
const
  ChunkSize = 8192;

var
  i: Integer;
  ID: NZDiskIDRec;
  Buffer: Pointer;
  CRC: LongInt;
  MemoryStream: TMemoryStream;
  ZipStream: TMemoryStream;
  FileStream: TMemoryStream;
  NumRead: Integer;
  NumWritten: Integer;
  Zipper: TVclZip;
begin
  (* Profile( 'TNZDisk.SaveToFile' ); *)
  Validate;
  { Generate the File Header Record }
  FillChar(ID, Sizeof(ID), 0);
  with ID do
    begin
      idFileType := 'BankLink';
      idClientCode := TrimS(dhFields.dhClient_Code);
      idClientName := TrimTrailS(Copy(dhFields.dhClient_Name, 1, 20));
      idDate := dhFields.dhCreation_Date;
      idSerialNo := TrimS(dhFields.dhFloppy_Desc_NZ_Only); { 'XXXXXXXnnn' }
      idVersion := 02;
      idSequenceNo := dhFields.dhSequence_In_Set;
      idNoInSet := dhFields.dhNo_Of_Disks_in_Set;
      idLastDisk := (dhFields.dhSequence_In_Set = dhFields.dhNo_Of_Disks_in_Set);
      idDiskNumber := dhFields.dhDisk_Number;
    end;

  ZipStream := TMemoryStream.Create;
  try
    ZipStream.Clear;
    ZipStream.Position := 0;

    Zipper := TVclZip.Create(nil);
    try
      Zipper.StorePaths := False;
      Zipper.ArchiveStream := ZipStream;

      { We're going to save the data in each format }

      MemoryStream := SaveToRT86Stream;
      try
        Zipper.ZipFromStream(MemoryStream, ExtractFileName(FileName)); { The data in RT86 format }
      finally
        MemoryStream.Free;
      end;

      MemoryStream := SaveSuperDirectoryStream;
      try
        Zipper.ZipFromStream(MemoryStream, 'DISK_INF' + ExtractFileExt(FileName));
          // Super directory for current data
      finally
        MemoryStream.Free;
      end;

      if Assigned(Attachments) then
        begin
          for i := 0 to Pred(Attachments.Count) do
            begin
              FileStream := TMemoryStream.Create;
              try
                FileStream.LoadFromFile(Attachments[i]);
                FileStream.Position := 0;
                Zipper.ZipFromStream(FileStream, ExtractFileName(Attachments[i]))
              finally
                FileStream.Free;
              end;
            end;
        end;
      ZipStream := TMemoryStream(Zipper.ArchiveStream);
      Zipper.ArchiveStream := nil;
    finally
      Zipper.Free;
    end;

    { The Zip data is now sitting in the ZipStream TMemoryStream
      We need to read this and encrypt it }

    FileStream := TMemoryStream.Create;

    try
      FileStream.Clear;
      FileStream.Position := 0;

      CRC := 0;
      UpdateCRC(CRC, ID, Sizeof(ID));
      FileStream.Write(ID, Sizeof(ID));

      GetMem(Buffer, ChunkSize);
      try
        ZipStream.Position := 0;
        repeat
          NumRead := ZipStream.Read(Buffer^, ChunkSize);
          if NumRead > 0 then
            begin
              Encrypt(Buffer^, NumRead);
              UpdateCRC(CRC, Buffer^, NumRead);
              NumWritten := FileStream.Write(Buffer^, NumRead);
              if not (NumWritten = NumRead) then
                raise FHException.Create('Error writing to FileStream Memory Stream');
            end;
        until NumRead < ChunkSize;
      finally
        FreeMem(Buffer, ChunkSize);
      end;

      FileStream.Position := 0;
      ID.idCRC := CRC;
      FileStream.Write(ID, Sizeof(ID));
      FileStream.Position := 0;
      FileStream.SaveToFile(FileName);
    finally
      FileStream.Free;
    end;
  finally
    ZipStream.Free;
  end;
end;

{  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -    }

procedure TNZDisk.LoadFromRT86Stream(const RT86Stream: TMemoryStream);

var
  NZDiskImage: PNZDiskImage;
  eSecNo: Integer;
  eSlotNo: Integer;
  AcctNo: Integer;

  function CurrentSlot: PaxusDataRecTypePtr;
  begin
    Assert((eSecNo >= 0) and (eSecNo <= 1393));
    Assert(eSlotNo in [1..6]);
    Result := @NZDiskImage.EntryBlocks[eSecNo].Slot[eSlotNo];
  end;

  function CurrentDir: POldAccountHeader;
  begin
    Assert(AcctNo in [1..255]);
    Result := @NZDiskImage.Directory[AcctNo];
  end;

var
  DBA: TDisk_Bank_Account;
  P: PDisk_Transaction_Rec;
  Slot1, Slot2: Integer;
  desc: string;
begin
  (* Profile( 'TNZDisk.LoadFromRT86Stream' ); *)
  Assert(dhAccount_List.ItemCount = 0);
  Assert(Assigned(RT86Stream));
  Assert(Rt86Stream.Size > 0);

  GetMem(NZDiskImage, Sizeof(TNZDiskImage));
  try
    FillChar(NZDiskImage^, Sizeof(TNZDiskImage), 0);
    RT86Stream.Position := 0;
    RT86Stream.Read(NZDiskImage^, RT86Stream.Size);

    EmptyDisk;

    dhFields.dhVersion := 'RT86 - ' + IntToStr(NZDiskImage.Header.Floppy_Version);
    dhFields.dhFile_SubType := NFDataStr;
    dhFields.dhCountry_Code := whNewZealand;
    dhFields.dhClient_Code := A2S(NZDiskImage.Header.Disk_Code, 13);
    dhFields.dhClient_Name := A2S(NZDiskImage.Header.Disk_Name, 20);
    dhFields.dhCreation_Date := DateStringToSTDate('ddmmyy', NZDiskImage.Header.Creation_Date,
      DefEpoch);
    desc := A2S(NZDiskImage.Header.Floppy_Desc, 11);
    dhFields.dhFloppy_Desc_NZ_Only := desc;
    if NZDiskImage.Header.Disk_Number<3600 then
    begin
      dhFields.dhFile_Name := Copy(desc, 1, length(desc) - 3) + '.' + Copy(desc, length(desc) - 2, 3);   // Insert dot into file name
      dhFields.dhTrue_File_Name := dhFields.dhFile_Name;
    end
    else
    begin
      dhFields.dhFile_Name := dhFields.dhClient_Code + MakeSuffix(NZDiskImage.Header.Disk_Number);
      dhFields.dhTrue_File_Name := CorrectFileName(dhFields.dhFile_Name);
    end;

    dhFields.dhDisk_Number := NZDiskImage.Header.Disk_Number;
    dhFields.dhSequence_In_Set := NZDiskImage.Header.Sequence_No;
    dhFields.dhNo_Of_Disks_in_Set := NZDiskImage.Header.Number_In_Set;

    for AcctNo := 1 to 255 do
      begin
        if Swap(CurrentDir.No_of_Blocks) > 0 then
          begin
            DBA := TDisk_Bank_Account.Create;
            DBA.dbFields.dbAccount_Name := A2S(CurrentDir.Cust_Name, 20);
            DBA.dbFields.dbAccount_Number := A2S(CurrentDir.Cust_FullCode, 20);
            DBA.dbFields.dbContinued_On_Next_Disk := (CurrentDir.Continued = 1);
            DBA.dbFields.dbOpening_Balance := Unknown;
            DBA.dbFields.dbClosing_Balance := Unknown;
            DBA.dbFields.dbDebit_Total := 0;
            DBA.dbFields.dbCredit_Total := 0;

            dhAccount_List.Insert(DBA);
            Inc(dhFields.dhNo_Of_Accounts);

            Slot1 := Swap(CurrentDir.Start_Block);
            Slot2 := Slot1 + Swap(CurrentDir.No_of_Blocks) - 1;

            eSecNo := Slot1;
            eSlotNo := 1;

            { In theory, we should always be on the Header Slot for this Account. I've found a
              few old NZ disks (CHES.009, GOLDFOX.007, HANNAHP.011 FIDDFAL.011)
              where this isn't true for one account only where Slot1 = Slot2 = 1200, which
              I guess must have been caused by a bug in the NZ production system at that time.

            If CurrentSlot.Header.RecType <> 'A' then
              CodeSite.SendFmtMsg( '[No Header Rec] File %s Account %d %s entries from %d to %d',
                [ dhFields.dhFloppy_Desc_NZ_Only, AcctNo, DBA.dbFields.dbAccount_Name, Slot1, Slot2 ] );

            }

            for eSecNo := Slot1 to Slot2 do
              begin
                for eSlotNo := 1 to 6 do
                  begin
                    case CurrentSlot.Outline.RecType of
                      'A': { Header } DBA.dbFields.dbCost_Code := A2S(CurrentSlot.Header.CostCode,
                        8);
                      'B': with CurrentSlot.Tran do
                          begin { Transaction }
                            P := FHDTIO.New_Disk_Transaction_Rec;
                            P.dtEntry_Type := TranCode;
                            P.dtAmount := C13ToInt64(Amount);
                            P.dtAnalysis_Code_NZ_Only := A2S(Analysis, 12);
                            P.dtReference := A2S(Reference, 12);
                            P.dtParticulars_NZ_Only := A2S(Particulars, 12);
                            P.dtEffective_Date := DateStringToStDate('ddmmyy', PostDate, DefEpoch);
                            P.dtOrig_BB := A2S(OrigBB, 6);
                            P.dtOther_Party_NZ_Only := A2S(OtherParty, 20);
                            P.dtGST_Amount := Unknown;
                            P.dtQuantity := Unknown;

                            if P.dtAmount < 0 then
                              DBA.dbFields.dbCredit_Total := DBA.dbFields.dbCredit_Total -
                                P.dtAmount
                            else
                              DBA.dbFields.dbDebit_Total := DBA.dbFields.dbDebit_Total +
                                P.dtAmount;

                            if (DBA.dbFields.dbFirst_Transaction_Date = 0) or
                              (DBA.dbFields.dbFirst_Transaction_Date > P.dtEffective_Date) then
                              DBA.dbFields.dbFirst_Transaction_Date := P.dtEffective_Date;
                            if DBA.dbFields.dbLast_Transaction_Date < P.dtEffective_Date then
                              DBA.dbFields.dbLast_Transaction_Date := P.dtEffective_Date;
                            if (dhFields.dhFirst_Transaction_Date = 0) or
                              (dhFields.dhFirst_Transaction_Date > P.dtEffective_Date) then
                              dhFields.dhFirst_Transaction_Date := P.dtEffective_Date;
                            if dhFields.dhLast_Transaction_Date < P.dtEffective_Date then
                              dhFields.dhLast_Transaction_Date := P.dtEffective_Date;

                            DBA.dbTransaction_List.Insert(P);
                            Inc(DBA.dbFields.dbNo_Of_Transactions);
                            Inc(dhFields.dhNo_Of_Transactions);
                          end;
                      'C': { Trailer };
                    end; { of Case }
                  end; { eSlotNo }
              end; { eSecNo }
          end;
      end;

  finally
    FreeMem(NZDiskImage);
  end;
end;

// ----------------------------------------------------------------------------

procedure TNZDisk.Validate;
begin
  inherited;
  if dhFields.dhCountry_Code <> whNewZealand then
    raise FHDataValidationException.Create('TNZDisk.Validate Error: Wrong country code');
  if dhFields.dhDisk_Number = 0 then
    raise
      FHDataValidationException.Create('TNZDisk.Validate Error: dhDisk_Number is a required field [NZ]');
  if dhFields.dhNo_Of_Disks_in_Set = 0 then
    raise
      FHDataValidationException.Create('TNZDisk.Validate Error: dhNo_of_Disks_In_Set is a required field [NZ]');
  if dhFields.dhSequence_In_Set = 0 then
    raise
      FHDataValidationException.Create('TNZDisk.Validate Error: dhSequence_In_Set is a required field [NZ]');
  if dhFields.dhFloppy_Desc_NZ_Only = '' then
    raise
      FHDataValidationException.Create('TNZDisk.Validate Error: dhFloppy_Desc_NZ_Only is a required field [NZ]');
end;
//------------------------------------------------------------------------------

procedure TNZDisk.NewDisk(ClientCode, ClientName: string; CreatDate: integer;
  FileName, FloppyDesc, TrueFileName: string; DiskNo, SeqNo: integer);
// New, empty disk
begin
  EmptyDisk; // Cleanup previous disk image

  dhFields.dhCountry_Code := whNewZealand; // New header data
  dhFields.dhClient_Code := ClientCode;
  dhFields.dhClient_Name := ClientName;
  dhFields.dhCreation_Date := CreatDate;

  if DiskNo<3600 then
    dhFields.dhFile_Name := FileName
  else
    dhFields.dhFile_Name := StringReplace(FileName,'.','',[rfReplaceAll]);      // remove dot in 4-character extensions

  dhFields.dhFloppy_Desc_NZ_Only := FloppyDesc;
  dhFields.dhTrue_File_Name := TrueFileName;
  dhFields.dhDisk_Number := DiskNo;
  dhFields.dhSequence_In_Set := SeqNo;
  dhFields.dhNo_Of_Disks_in_Set := 0; // Not known yet, to be updated later
  dhFields.dhNo_Of_Accounts := 0; // Disk is empty
  dhFields.dhNo_Of_Transactions := 0; // Disk is empty
  dhFields.dhFirst_Transaction_Date := 0; // Disk is empty
  dhFields.dhLast_Transaction_Date := 0; // Disk is empty
  dhFields.dhVersion := NFVersion;
end;
//------------------------------------------------------------------------------

procedure TNZDisk.AddAccount(Number, OriginalNumber, Name, FileCode, CostCode, BankCode,
  BankName, Currency: string;
  OpBalance: Int64; IsNew: Boolean;
  accLRN,instID: integer;
  FrequencyID: integer;
  InternalAccNumber: string);
// Add new account to current disk.
var
  DBA: TDisk_Bank_Account;
begin
  (*
  if not CanAddAccount then
    raise FHException.Create( 'No room for new account. Disk is full.' );
  *)

  DBA := TDisk_Bank_Account.Create;
  DBA.dbFields.dbAccount_Number := Number;
  DBA.dbFields.dbOriginal_Account_Number := OriginalNumber;
  DBA.dbFields.dbAccount_Name := Name;
  DBA.dbFields.dbContinued_On_Next_Disk := False; // Don't know yet
  DBA.dbFields.dbFile_Code := FileCode;
  DBA.dbFields.dbCost_Code := CostCode;
  DBA.dbFields.dbBank_Prefix := BankCode;
  DBA.dbFields.dbBank_Name := BankName;
  DBA.dbFields.dbCan_Redate_Transactions := False; // Currently always False
  DBA.dbFields.dbOpening_Balance := OpBalance;
  DBA.dbFields.dbClosing_Balance := Unknown; // Calculated when transactions are added
  DBA.dbFields.dbDebit_Total := 0; // No transactions yet
  DBA.dbFields.dbCredit_Total := 0; // No transactions yet
  DBA.dbFields.dbFirst_Transaction_Date := 0; // No transactions yet
  DBA.dbFields.dbLast_Transaction_Date := 0; // No transactions yet
  DBA.dbFields.dbNo_Of_Transactions := 0; // No transactions yet
  DBA.dbFields.dbIs_New_Account := IsNew;
  DBA.dbFields.dbInternal_Account_Number := InternalAccNumber;
  DBA.dbFields.dbAccount_LRN := accLRN;
  DBA.dbFields.dbInstitution_ID := instID;
  DBA.dbFields.dbCurrency := Currency;
  DBA.dbFields.dbFrequency_ID := FrequencyID;

  dhAccount_List.Insert(DBA);
  Inc(dhFields.dhNo_Of_Accounts);
end;
//------------------------------------------------------------------------------

procedure TNZDisk.AddTransaction(var DBA: TDisk_Bank_Account;
  TransID: Integer; TransType: Byte;
  Amount, GSTAmount, Quantity: Int64; EffDate, OrigDate: Integer;
  Reference, Analysis, Particulars, OtherParty,
  OrigBB, Narration: string);
// Add transaction to specified account.
var
  P: PDisk_Transaction_Rec;
begin
  (*
  if not CanAddTransaction then
    raise FHException.Create( 'No room for new transaction. Disk is full.' );
  *)

  P := FHDTIO.New_Disk_Transaction_Rec;
  P.dtBankLink_ID := TransID;
  P.dtEntry_Type := TransType;
  P.dtAmount := Amount;
  P.dtGST_Amount := GSTAmount;
  P.dtGST_Amount_Known := GSTAmount <> Unknown;
  P.dtEffective_Date := EffDate;
  P.dtOriginal_Date := OrigDate;
  P.dtReference := Reference;
  P.dtAnalysis_Code_NZ_Only := Analysis;
  P.dtParticulars_NZ_Only := Particulars;
  P.dtOther_Party_NZ_Only := OtherParty;
  P.dtOrig_BB := OrigBB;
  P.dtNarration := Narration;
  P.dtQuantity := Quantity;
  P.dtBank_Type_Code_OZ_Only := ''; // Not used in NZ
  P.dtDefault_Code_OZ_Only := ''; // Not used in NZ

  DBA.dbTransaction_List.Insert(P);

  Inc(DBA.dbFields.dbNo_Of_Transactions); // Update account and disk totals
  Inc(dhFields.dhNo_Of_Transactions);
  if (dhFields.dhFirst_Transaction_Date = 0) or (dhFields.dhFirst_Transaction_Date > EffDate) then
    dhFields.dhFirst_Transaction_Date := EffDate;
  if (dhFields.dhLast_Transaction_Date < EffDate) then
    dhFields.dhLast_Transaction_Date := EffDate;
  if (DBA.dbFields.dbFirst_Transaction_Date = 0) or (DBA.dbFields.dbFirst_Transaction_Date >
    EffDate) then
    DBA.dbFields.dbFirst_Transaction_Date := EffDate;
  if (DBA.dbFields.dbLast_Transaction_Date < EffDate) then
    DBA.dbFields.dbLast_Transaction_Date := EffDate;

  if Amount < 0 then
    DBA.dbFields.dbCredit_Total := DBA.dbFields.dbCredit_Total - Amount
  else
    DBA.dbFields.dbDebit_Total := DBA.dbFields.dbDebit_Total + Amount;
  if DBA.dbFields.dbOpening_Balance <> Unknown then
    DBA.dbFields.dbClosing_Balance := DBA.dbFields.dbOpening_Balance + DBA.dbFields.dbCredit_Total
      - DBA.dbFields.dbDebit_Total;
end;
//------------------------------------------------------------------------------

end.
