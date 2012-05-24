unit FileConverter;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
XMLDoc,
   XMLIntf,
  ComObj, ActiveX, AxCtrls, Classes, DownloadConverter_TLB, StdVcl, BaseDisk;

type
  TFileConverter = class(TAutoObject, IConnectionPointContainer, IFileConverter)
  private
    { Private declarations }
    FConnectionPoints: TConnectionPoints;
    FConnectionPoint: TConnectionPoint;
    FEvents: IFileConverterEvents;
    { note: FEvents maintains a *single* event sink. For access to more
      than one event sink, use FConnectionPoint.SinkList, and iterate
      through the list of sinks. }
    procedure Extract(const FileName: string; filestream: TStream);

    // Binary File handeling
    function DecodeText(Value: string): TStream;
    function EnCodetext(Value: Tstream): string;

    // Move the numbers From the extention into the filename and add new extention
    function ReNameFile(Filename, NewExtention: string): string;

    // Some XML Handeling helpers
    function FormatXMLdate(Value: Integer): string;
    procedure SetDateAttr(var OnNode: IXMLNode; Name: string; Value: Integer);
    procedure SetTextAttr(var OnNode: IXMLNode; Name, Value: string);
    procedure SetIntAttr(var OnNode: IXMLNode; Name: string; Value: Integer);
    procedure SetMoneyAttr(var OnNode: IXMLNode; Name: string; Value: int64);
    procedure SetQtyAttr(var OnNode: IXMLNode; Name: string; Value: int64);

    // Make The actual XML
    function ExportDiskFile(Value: TBankLink_Disk): string;
  public
    procedure Initialize; override;
  protected

    procedure ImportFile(const FileName, Country, FileStream: WideString;
      PIN: Integer); safecall;

    property ConnectionPoints: TConnectionPoints read FConnectionPoints
      implements IConnectionPointContainer;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
     { Protected declarations }
  end;

implementation

uses
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


/// This is copied from EnterPINdlg, which uses Globals
/// Should realy be moved to a more conviniant location

Function GenerateKey( Name : ShortString ): LongInt;
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



function TFileConverter.DecodeText(Value: string): TStream;
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

function TFileConverter.EnCodetext(Value: Tstream): string;
var
    OutStream : TStringStream;
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

procedure TFileConverter.EventSinkChanged(const EventSink: IUnknown);
begin // Generated Code
  FEvents := EventSink as IFileConverterEvents;
end;

procedure TFileConverter.Initialize;
begin  // Generated Code
  inherited Initialize;
  FConnectionPoints := TConnectionPoints.Create(Self);
  if AutoFactory.EventTypeInfo <> nil then
    FConnectionPoint := FConnectionPoints.CreateConnectionPoint(
      AutoFactory.EventIID, ckSingle, EventConnect)
  else FConnectionPoint := nil;
end;


function TFileConverter.ReNameFile(Filename, NewExtention: string): string;
var point: Integer;
begin
   // Moves the numer to before the extention
   Result := FileName;
   Point := Pos('.',Result);
   if Point > 0 then
      Result := format('%s_%s.%s',[ copy(Filename,1,Point-1), Copy(FileName,Point+ 1, 255),NewExtention]) ;
end;

procedure TFileConverter.SetDateAttr(var OnNode: IXMLNode; Name: string;
  Value: Integer);
begin
   if Value > 0 then
      OnNode.Attributes [Name] := FormatXMLdate(Value);
end;

procedure TFileConverter.SetIntAttr(var OnNode: IXMLNode; Name: string; Value: Integer);
begin
   SetTextAttr(OnNode,Name,IntToStr(Value));
end;

procedure TFileConverter.SetMoneyAttr(var OnNode: IXMLNode; Name: string;
  Value: int64);
begin
 if (Value <> 0)
 and (Value <> Unknown)then
      OnNode.Attributes [Name] := (Value / 100);
end;

procedure TFileConverter.SetQtyAttr(var OnNode: IXMLNode; Name: string;
  Value: int64);
begin
if (Value <> 0)
 and (Value <> Unknown)then
      OnNode.Attributes [Name] := (Value / 1000);
end;

procedure TFileConverter.SetTextAttr(var OnNode: IXMLNode; Name, Value: string);
begin
   if Value > '' then
      OnNode.Attributes [Name] := Value;
end;

function TFileConverter.ExportDiskFile(Value: TBankLink_Disk): string;
const
     DiskFileNameSpace = 'http://banklink.co.nz/DiskFile/schema';
     DiskFileVersion = '1.0';

var lNode,
    LAccounts: IXMLNode;
    lXMLDoc: IXMLDocument;
    a: Integer;

    procedure AddTransaction(ToNode:IXMLNode; Trans: pDisk_Transaction_Rec);
    var lNode: IXMLNode;
    begin
       LNode := ToNode.AddChild('Transaction');
       if Trans.dtBankLink_ID <> 0 then
          SetIntAttr(LNode,'BankLinkID',Trans.dtBankLink_ID);
       SetDateAttr(LNode,'EffectiveDate',Trans.dtEffective_Date);
       SetDateAttr(LNode,'OriginalDate',Trans.dtOriginal_Date);
       SetIntAttr(LNode,'EntryType',Trans.dtEntry_Type);
       case Value.dhFields.dhCountry_Code of
        whNewZealand : begin
           SetTextAttr(LNode,'AnalysisCode',Trans.dtAnalysis_Code_NZ_Only);
           SetTextAttr(LNode,'Particulars',Trans.dtParticulars_NZ_Only);
           SetTextAttr(LNode,'OtherParty',Trans.dtOther_Party_NZ_Only);
        end;
        whAustralia : begin
           SetTextAttr(LNode,'BankTypeCode',Trans.dtBank_Type_Code_OZ_Only);
           SetTextAttr(LNode,'DefaultCode',Trans.dtDefault_Code_OZ_Only);
        end;
        //whUnitedKingdom :;
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
    SetIntAttr(LNode,'DisksInSet',Value.dhFields.dhNo_Of_Disks_in_Set);
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

procedure TFileConverter.Extract(const FileName: string; filestream: TStream);

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
      FEvents.OnNewFile(Filename,htmFile,StreamToString);
      Exit;
   end;

   if (pos('report', LowerCase(Filename)) = 1) then begin
      FEvents.OnNewFile(ReNameFile(Filename,'rpt'),rptFile,StreamToString);
      Exit;
   end;

   if (pos('.csv', LowerCase(Filename)) > 0) then begin
      FEvents.OnNewFile(Filename,ChargesFile,StreamToString);
      Exit;
   end;

   // Still here...
   FEvents.OnNewFile(Filename,BinFile,EnCodetext(FileStream));
end;

function TFileConverter.FormatXMLdate(Value: Integer): string;
begin
   Result := StDateToDateString('yyyy-mm-dd', Value, True);
end;

procedure TFileConverter.ImportFile(const FileName, Country,
  FileStream: WideString; PIN: Integer);
var
    Stream: TStream;
    FilePIN: Integer;
    DiskImage: TNewFormatDisk;
    {}
    fStream: TMemoryStream;
    {}

begin
   if FileStream = '' then begin
      FEvents.OnError(NoData, 'No Data' );
      Exit;
   end;

   Stream := DecodeText(FileStream);
   try
      // Pick the correct Country Image
      if SameText(Country, 'NZ') then
         DiskImage := TNZDisk.Create
      else if SameText(Country, 'AU') // Just in case...
           or SameText(Country, 'OZ') then
         DiskImage := TOZDisk.Create
      else if SameText(Country, 'UK') then
         DiskImage := TUKDisk.Create
      else
         DiskImage := nil;
       {}
      fStream := TMemoryStream.Create;
      Stream.Position := 0;
      fStream.CopyFrom(Stream,0);
      FStream.SaveToFile('c:\save\out.file');
      FStream.Free;
       {}

      try
         if Pos('BK_',Filename) = 1 then
            DiskImage.ExtractFromStream(FileName,Stream,Extract)
         else
            DiskImage.ExtractFromStreamOF(FileName,Stream,Extract);
      except
         on E : Exception do begin
            FEvents.OnError(FileCorrupt, E.Message );
            Exit;
         end;
      end;

      // Validate the Disk..
      try
         DiskImage.Validate;
      except
         on E : Exception do begin
            FEvents.OnError(DiskInvalid, E.Message );
            Exit;
         end;
      end;

      // Check the PIN
      if DiskImage.dhFields.dhCountry_Code = whNewZealand then
         FilePIN := GenerateKey(TrimRight(Copy(DiskImage.dhFields.dhClient_Name, 1, 20)))
      else
         FilePIN := GenerateKey(TrimRight(Copy(DiskImage.dhFields.dhClient_Name, 1, 40)));

      if FilePin <> PIN then begin
         FEvents.OnError(PINIncorrect, 'PIN Incorrect' );
         Exit;
      end;


      // Now do the disk Image;
      FEvents.OnNewFile(ReNameFile(FileName,'XML'),dataFile,ExportDiskFile(DiskImage));
   finally
      Stream.Free;
      FreeAndNil(DiskImage);
   end;
end;

initialization
   TAutoObjectFactory.Create(ComServer, TFileConverter, CLASS_FileConverter,
    ciMultiInstance, tmApartment);
end.
