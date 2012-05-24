unit ArrayConverter;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses

  Classes,
  ProcTypes;

    { Private declarations }


procedure SetOutputFileProc (Value: OutputFile); stdcall;
procedure SetErrorProc (Value: OutputError); stdcall;
procedure ImportFile (FileName, Country, FileStream: pChar; PIN: integer) stdcall;



implementation

uses
   BaseDisk,
   XMLDoc,
   XMLIntf,
   StreamIO,
   dbObj,
   FHDefs,
   stDateSt,
   OmniXMLUtils,
   NFDiskObj,
   NZDiskObj,
   OZDiskObj,
   UKDiskObj,
   ComServ,
   cryptx,
   SysUtils;

const
  DataFile = $00000000;
  htmFile = $00000001;
  rptFile = $00000002;
  binFile = $00000003;
  ChargesFile = $00000004;

  FileCorrupt = $00000001;
  DiskInvalid = $00000002;
  PINIncorrect = $00000003;
  NoData = $00000004;


var
  OutputFileProc: OutputFile;
  ErrorProc: OutputError;

procedure SetOutputFileProc (Value: OutputFile);
begin
  OutputFileProc := Value;
end;

procedure SetErrorProc (Value: OutputError);
begin
  ErrorProc := Value;
end;


procedure DoError(Error: Integer; ErrorText: pChar);
begin
  if Assigned(ErrorProc) then
      ErrorProc(Error, ErrorText);
end;
procedure DoOutputFile(FileType: Integer; Filename: pChar; Data: PChar);
begin
   if Assigned(OutputFileProc) then
      OutputFileProc(FileType, Filename, Data);
end;


type
  TArrayConverter = class(TObject)
  private
     function GenerateKey( Name : ShortString ): LongInt;
     function DecodeText(Value: PChar): TStream;
     function EnCodetext(Value: Tstream): string;
     function ReNameFile(Filename, NewExtention: string): string;
     function FormatXMLdate(Value: Integer): string;
     procedure SetDateAttr(var OnNode: IXMLNode; Name: string; Value: Integer);
     procedure SetTextAttr(var OnNode: IXMLNode; Name, Value: string);
     function ExportDiskFile(Value: TBankLink_Disk): string;
     procedure Extract(const FileName: string; filestream: TStream);
     procedure SetIntAttr(var OnNode: IXMLNode; Name: string; Value: Integer);
     procedure SetMoneyAttr(var OnNode: IXMLNode; Name: string; Value: int64);
     procedure SetIdAttr(var OnNode: IXMLNode; Name: string; Value: int64);
     procedure SetQtyAttr(var OnNode: IXMLNode; Name: string; Value: int64);
end;


/// This is copied from EnterPINdlg, which uses Globals
/// Should realy be moved to a more conviniant location

Function TArrayConverter.GenerateKey( Name : ShortString ): LongInt;
//expects a right trimmed string
Var
   Buf : Array[0..255] of Byte;
   Sum : LongInt;
   i   : Byte;
   l   : Byte;
Begin
   Name := UpperCase(Name);
   l := Length(Name) + 1;
   FillChar( Buf, Sizeof( Buf ), 0 );
   Move( Name, Buf, l );
   Encrypt( Buf, l );
   Sum := 0;
   For i := 0 to l-1 do
      Sum := Sum + ( Buf[i] * Ord( Name[i] ) );
   GenerateKey := ( Sum mod 9999 ) + 1;
end;



function TArrayConverter.DecodeText(Value: PChar): TStream;
var
   InStream : TStringStream;
begin
   Result := TMemoryStream.Create;
   InStream := TStringStream.Create (Value);
   try
      Base64Decode(InStream, Result);
      Result.Position := 0;
   finally
      FreeandNil(Instream);
   end;
end;

function TArrayConverter.EnCodetext(Value: Tstream): string;
var
    OutStream: TStringStream;
begin
  Result := '';
  OutStream := TStringStream.Create('');
  try try
     Base64Encode(Value, OutStream);
     //Instream is now the result..
     Result := OutStream.DataString;
  except

  end;
  finally
     FreeandNil(Outstream);
  end;
end;



function TArrayConverter.ReNameFile(Filename, NewExtention: string): string;
var point: Integer;
begin
   // Moves the numer to before the extention
   Result := FileName;
   Point := Pos('.',Result);
   if Point > 0 then
      Result := format('%s_%s.%s',[ copy(Filename,1,Point-1), Copy(FileName,Point+ 1, 255),NewExtention]) ;
end;

function TArrayConverter.FormatXMLdate(Value: Integer): string;
begin
   Result := StDateToDateString('yyyy-mm-dd', Value, True);
end;

procedure TArrayConverter.SetDateAttr(var OnNode: IXMLNode; Name: string;
  Value: Integer);
begin
   if Value > 0 then
      OnNode.Attributes [Name] := FormatXMLdate(Value);
end;


procedure TArrayConverter.SetTextAttr(var OnNode: IXMLNode; Name, Value: string);
begin
   if Value > '' then
      OnNode.Attributes [Name] := Value;
end;

procedure TArrayConverter.SetIntAttr(var OnNode: IXMLNode; Name: string; Value: Integer);
begin
   SetTextAttr(OnNode,Name,IntToStr(Value));
end;

procedure TArrayConverter.SetMoneyAttr(var OnNode: IXMLNode; Name: string; Value: int64);
begin
   if (Value <> 0)
   and (Value <> Unknown)then
      OnNode.Attributes [Name] := (Value / 100);
end;

procedure TArrayConverter.SetIDAttr(var OnNode: IXMLNode; Name: string; Value: int64);
begin
    OnNode.Attributes [Name] := Value;
end;

procedure TArrayConverter.SetQtyAttr(var OnNode: IXMLNode; Name: string;
  Value: int64);
begin
  if (Value <> 0)
  and (Value <> Unknown)then
      OnNode.Attributes [Name] := (Value / 1000);
end;

function TArrayConverter.ExportDiskFile(Value: TBankLink_Disk): string;
const
     DiskFileNameSpace = 'http://banklink.co.nz/DiskFile/schema';
     DiskFileVersion = '1.0';

var lNode,
    LAccounts: IXMLNode;
    lXMLDoc: IXMLDocument;
    a: Integer;
    lLong: int64;

    procedure AddTransaction(ToNode:IXMLNode; Trans: pDisk_Transaction_Rec);
    var lNode: IXMLNode;
    begin
       LNode := ToNode.AddChild('Transaction');
       if (Trans.dtBankLink_ID <> 0)
       or (Trans.dtBankLink_ID_H <> 0) then begin
          lLong := Trans.dtBankLink_ID_H;
          lLong := (LLong shr 32) + Trans.dtBankLink_ID;
          SetIDAttr(LNode,'BankLinkID',llong);
       end;
       SetDateAttr(LNode,'EffectiveDate',Trans.dtEffective_Date);
       SetDateAttr(LNode,'OriginalDate',Trans.dtOriginal_Date);
       SetIntAttr(LNode,'EntryType',Trans.dtEntry_Type);
       case Value.dhFields.dhCountry_Code of
        whNewZealand : begin
           SetTextAttr(LNode,'AnalysisCode',Trans.dtAnalysis_Code_NZ_Only);
           SetTextAttr(LNode,'Particulars',Trans.dtParticulars_NZ_Only);
           SetTextAttr(LNode,'OtherParty',Trans.dtOther_Party_NZ_Only);
        end;
        whAustralia, whUnitedKingdom : begin
           SetTextAttr(LNode,'BankTypeCode',Trans.dtBank_Type_Code_OZ_Only);
           SetTextAttr(LNode,'DefaultCode',Trans.dtDefault_Code_OZ_Only);
        end;

       end;

       SetTextAttr(LNode,'Reference',Trans.dtReference);

       SetTextAttr(LNode,'OrigBB',Trans.dtOrig_BB);
       SetMoneyAttr(LNode,'Amount',Trans.dtAmount);
       if Trans.dtGST_Amount_Known then
          SetMoneyAttr(LNode,'GSTAmount',Trans.dtGST_Amount);
       SetTextAttr(LNode,'Narration',Trans.dtNarration);
       SetQtyAttr(LNode,'Quantity',Trans.dtQuantity);
    end;

    procedure AddAccount(ToNode:IXMLNode; Account: TDisk_Bank_Account);
    var lNode: IXMLNode;
        T: Integer;
    begin
       LNode := ToNode.AddChild('Account');
       SetTextAttr(LNode,'AccountNumber',Account.dbFields.dbAccount_Number);
       SetTextAttr(LNode,'AccountName',Account.dbFields.dbAccount_Name);
       SetTextAttr(LNode,'OriginalAccountNumber',Account.dbFields.dbOriginal_Account_Number);
       SetTextAttr(LNode,'InternalAccountNumber',Account.dbFields.dbInternal_Account_Number);


       SetTextAttr(LNode,'FileCode',Account.dbFields.dbFile_Code);
       SetTextAttr(LNode,'CostCode',Account.dbFields.dbCost_Code);
       SetTextAttr(LNode,'BankPrefix',Account.dbFields.dbBank_Prefix);
       SetTextAttr(LNode,'BankName',Account.dbFields.dbBank_Name);
       SetTextAttr(LNode,'CanRedateTransactions',BoolToStr(Account.dbFields.dbCan_Redate_Transactions, true));
       SetTextAttr(LNode,'ContinuedOnNextDisk',BoolToStr(Account.dbFields.dbContinued_On_Next_Disk, true));
       SetMoneyAttr(LNode,'OpeningBalance',Account.dbFields.dbOpening_Balance);
       SetMoneyAttr(LNode,'ClosingBalance',Account.dbFields.dbClosing_Balance);
       SetMoneyAttr(LNode,'DebitTotal',Account.dbFields.dbDebit_Total);
       SetMoneyAttr(LNode,'CreditTotal',Account.dbFields.dbCredit_Total);
       SetDateAttr(LNode,'FirstTransactionDate',Account.dbFields.dbFirst_Transaction_Date);
       SetDateAttr(LNode,'LastTransactionDate',Account.dbFields.dbLast_Transaction_Date);
       SetIntAttr(LNode,'NoOfTransactions',Account.dbFields.dbNo_Of_Transactions);
       SetTextAttr(LNode,'IsNew',BoolToStr(Account.dbFields.dbIs_New_Account, true));
       SetIntAttr(LNode,'AccountLRN',Account.dbFields.dbAccount_LRN);
       SetTextAttr(LNode,'Currency',Account.dbFields.dbCurrency);
       SetIntAttr(LNode,'InstitutionID',Account.dbFields.dbInstitution_ID);
       SetIntAttr(LNode,'FrequencyID',Account.dbFields.dbFrequency_ID);
       SetTextAttr(LNode,'IsProvisional',BoolToStr(Account.dbFields.dbIs_Provisional, true));
       LNode := ToNode.AddChild('Transactions');
       for T := 0 to Account.dbTransaction_List.ItemCount - 1 do
           AddTransaction(lNode, Account.dbTransaction_List.Disk_Transaction_At(T));
         
    end;
begin
    lXMLDoc := XMLDoc.NewXMLDocument;
    lXMLDoc.Active := true;
    lXMLDoc.Options := [doNodeAutoIndent];
    lXMLDoc.version:= DiskFileVersion;
    lXMLDoc.encoding:= 'UTF-8'; // Have no choice for now, its not a WideString
     // Build the notes
    lNode := lXMLDoc.CreateNode('DiskImage');

    SetTextAttr(LNode,'Version',DiskFileVersion);
    LNode.DeclareNamespace('',DiskFileNameSpace);
    lXMLDoc.DocumentElement := lNode;

    lNode := lNode.AddChild('Details',DiskFileNameSpace);


    SetTextAttr(LNode,'ClientCode',Value.dhFields.dhClient_Code);
    SetTextAttr(LNode,'ClientName',Value.dhFields.dhClient_Name);
    SetTextAttr(LNode,'InternalFileName',Value.dhFields.dhTrue_File_Name);
    SetIntAttr(LNode,'DiskNumber',Value.dhFields.dhDisk_Number);
    SetIntAttr(LNode,'DisksInSet',Value.dhFields.dhNo_Of_Disks_in_Set);
    SetIntAttr(LNode,'SequenceInSet',Value.dhFields.dhSequence_In_Set);
    SetDateAttr(LNode,'CreationDate',Value.dhFields.dhCreation_Date);

    //  dhFile_Name                        : String[ 12 ];       { Stored }
    //  dhFloppy_Desc_NZ_Only              : String[ 11 ];       { Stored }
    //  dhTrue_File_Name                   : String[ 30 ];       { Stored }
    SetIntAttr(LNode,'NoOfAccounts',Value.dhFields.dhNo_Of_Accounts);
    SetIntAttr(LNode,'NoOfTranactions',Value.dhFields.dhNo_Of_Transactions);
    SetDateAttr(LNode,'FirstTransactionDate',Value.dhFields.dhFirst_Transaction_Date);
    SetDateAttr(LNode,'LastTransactionDate',Value.dhFields.dhLast_Transaction_Date);

    LAccounts := LNode.AddChild('Accounts');
    for A := 0 to Value.dhAccount_List.ItemCount - 1 do
      AddAccount(LAccounts, Value.dhAccount_List.Disk_Bank_Account_At(A));
      

    Result := lXMLDoc.XML.Text;
    { Debug Only
    lXMLDoc.SaveToFile('c:\bk5\send.xml');
    {}
    lXMLDoc := nil;
end;


procedure TArrayConverter.Extract(const FileName: string; filestream: TStream);

   function StreamToString: string;
   var Stream: TStringStream;
   begin
      Stream := TStringStream.Create('');
      try
         Stream.CopyFrom(FileStream,0);
         Result := Stream.DataString;
      finally
         Stream.Free;
      end;
   end;

begin
   // Check the filename..

   if Pos('DISK_INF', FileName) > 0 then
      Exit; // Don't need it

   if (pos('.htm', lowerCase(Filename)) > 0) then begin
      DoOutputFile(htmFile,pChar(Filename), PChar(StreamToString));
      Exit;
   end;

   if (pos('report', LowerCase(Filename)) = 1) then begin
      DoOutputFile(rptFile,pChar(ReNameFile(Filename,'rpt')), PChar(StreamToString));
      Exit;
   end;

   if (pos('.csv', LowerCase(Filename)) > 0) then begin
      DoOutputFile(ChargesFile,pChar(Filename), PChar(StreamToString));
      Exit;
   end;

   // Still here...
   DoOutputFile(binFile,pChar(Filename), PChar(EnCodetext(FileStream)));
end;



procedure ImportFile(FileName, Country, FileStream: pChar; PIN: integer);
var DiskImage: TNewFormatDisk;
    Converter: TArrayConverter;
    Stream: TStream;
    FilePIN: Integer;
begin
    if (FileStream = nil)
    or (FileStream^ = #0) then begin
       DoError(NoData, 'No Data');
       Exit;
    end;

   Stream := nil;
   Converter := TArrayConverter.Create;
   try
      Stream := Converter.DecodeText(FileStream);

      if strIcomp(Country, 'NZ') = 0 then
         DiskImage := TNZDisk.Create
      else if (strIcomp(Country, 'AU') = 0) // Just in case...
           or (strIcomp(Country, 'OZ') = 0) then
              DiskImage := TOZDisk.Create
      else if SameText(Country, 'UK') then
         DiskImage := TUKDisk.Create
      else begin
         DiskImage := nil;
         DoError(0, 'Wrong Country');
      end;

      try
         if Pos('BK_',Filename) = 1 then
            DiskImage.ExtractFromStream(FileName,Stream,Converter.Extract)
         else
            DiskImage.ExtractFromStreamOF(FileName,Stream,Converter.Extract);
      except
         on E : Exception do begin
            DoError(FileCorrupt, PChar(E.Message));
            Exit;
         end;
      end;

       // Validate the Disk..
      try
         DiskImage.Validate;
      except
         on E : Exception do begin
            DoError(DiskInvalid, pchar(E.Message));
            Exit;
         end;
      end;

       // Check the PIN
      if DiskImage.dhFields.dhCountry_Code = whNewZealand then
         FilePIN := Converter.GenerateKey(TrimRight(Copy(DiskImage.dhFields.dhClient_Name, 1, 20)))
      else
         FilePIN := Converter.GenerateKey(TrimRight(Copy(DiskImage.dhFields.dhClient_Name, 1, 40)));

      if FilePin <> PIN then begin
         DoError(PINIncorrect, 'PIN Incorrect' );
         Exit;
      end;

      // Now do the disk Image;
      DoOutputFile(DataFile,PChar(Converter.ReNameFile(FileName,'XML')),pchar(Converter.ExportDiskFile(DiskImage)));

   finally
      FreeAndNil(DiskImage);
      FreeAndNil(Stream);
      Converter.Free;
   end;
end;



initialization
   OutputFileProc := nil;
   ErrorProc :=  nil;
end.
