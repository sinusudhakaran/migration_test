unit BaseDisk;

{  -------------------------------------------------------------------  }
interface uses fhdefs, Classes, FHIOStream, dblist, SysUtils, NFUtils;
{  -------------------------------------------------------------------  }

Const
  whNewZealand = 0;
  whAustralia  = 1;
  whUnitedKingdom = 2;

  whCountryCodes : array [ whNewZealand..whUnitedKingdom ] of string[2] = (NFCountryNZ,NFCountryAU,NFCountryUK);

  Unknown : Int64 = $7FFFFFFFFFFFFFFF;

type
  TBankLink_Disk = class ( TObject )
    dhFields       : tDisk_Header_Rec;
    dhAccount_List : tDisk_Bank_Account_List;
    constructor Create;
    destructor Destroy; override;
  private
    procedure LoadFromStream( var s : TFHIOStream );
    procedure SaveToStream( var s : TFHIOStream );
    { ------------------------- }
  public
    procedure LoadFromProductionFile( Const FileName : String );  { Native Data Format for PRODUCTION only }
    procedure SaveToProductionFile( Const FileName : String );    { Native Data Format for PRODUCTION only }
    procedure EmptyDisk;

    { ------------------------- }
    { Virtual Methods           }
    { ------------------------- }

    (* Check that the data in memory is OK to save *)
    procedure Validate; Virtual;
    (* We need a human readable version of the data to help diagnose problems *)
    procedure SaveAsText( Const FileName : String ); Virtual; Abstract;
  end;

Type
  TDiskError = Class( Exception );

{  -------------------------------------------------------------------  }
implementation uses FHTokens, fhdhio, dbObj, StStrS, CRCFileUtils, FHDTIO,
  StDate, StDateSt, CRC32, (* ProcUtils,*) StreamIO, VCLZip, CryptX, FHExceptions;
{  -------------------------------------------------------------------  }

resourcestring
  SUnknownToken = 'BaseDisk Error: Unknown token %d';

// -----------------------------------------------------------------------------

constructor TBankLink_Disk.Create;
begin
  inherited Create;
  FillChar( dhFields, Sizeof( dhFields ), 0 );
  with dhFields do
  begin
    dhRecord_Type := tkBegin_Disk_Header;
    dhEOR := tkEnd_Disk_Header;
  end;
  dhAccount_List := TDisk_Bank_Account_List.Create;
  if not Assigned( dhAccount_List ) then Raise FHInsufficientMemoryException.Create( 'TBankLink_Disk.Create: Unable to create dhAccount_List ');
end;

// -----------------------------------------------------------------------------

destructor TBankLink_Disk.Destroy;
begin
  dhAccount_List.Free;
  inherited Destroy;
end;

// -----------------------------------------------------------------------------

procedure TBankLink_Disk.LoadFromStream(var s : TFHIOStream);
var
  CRC: LongInt;
  Token: Byte;
begin
  CRCFileUtils.CheckEmbeddedCRC( S );

  S.Position := 0;
  S.Read( CRC, Sizeof( LongInt ) );

  EmptyDisk;

  Token := tkBegin_Disk_Header;
  while ( Token <> tkEndSection ) do
  begin
    case Token of
      tkBegin_Disk_Header    : Read_Disk_Header_Rec( dhFields, S );
      tkBeginDiskAccountList : dhAccount_List.LoadFromFile( S );
      else
        Raise FHUnknownTokenException.CreateFmt( SUnknownToken, [ Token ] );
    end; { of Case }
    Token := S.ReadToken;
  end;
end;

// -----------------------------------------------------------------------------

procedure TBankLink_Disk.LoadFromProductionFile( Const FileName : String );
Var
  S : TFHIOStream;
Begin
  (* Profile( 'TBankLink_Disk.LoadFromProductionFile' ); *)
  S := TFHIOStream.Create;
  Try
    S.LoadFromFile( FileName );
    LoadFromStream( S );
  Finally
    S.Free;
  end;
end;

// -----------------------------------------------------------------------------

procedure TBankLink_Disk.SaveToProductionFile( Const FileName : String );

Var
  S : TFHIOStream;
Begin
  (* Profile( 'TBankLink_Disk.SaveToProductionFile' ); *)
  S := TFHIOStream.Create;
  Try
    SaveToStream( S );
    S.Position := 0;
    S.SaveToFile( FileName );
  Finally
    S.Free;
  end;
end;

// -----------------------------------------------------------------------------

procedure TBankLink_Disk.SaveToStream(var s : TFHIOStream);
var
  CRC: LongInt;
begin
  Assert( S.Position = 0 );
  Assert( S.Size = 0 );
  CRC := 0;
  S.Write( CRC, Sizeof( LongInt ) ); { Leave room for the CRC }
  FHDHIO.Write_Disk_Header_Rec( dhFields, S );
  dhAccount_List.SaveToFile( S );
  S.WriteToken( tkEndSection );
  CRCFileUtils.EmbedCRC( S );
end;

// -----------------------------------------------------------------------------

procedure TBankLink_Disk.Validate;
Var
  HeaderInf : Integer;
  ActualInf : Integer;
  I : Integer;
  DB : TDisk_Bank_Account;
begin
  HeaderInf := dhFields.dhNo_of_Accounts;
  ActualInf := dhAccount_List.ItemCount;

  If ( HeaderInf <> ActualInf ) then
    Raise FHDataValidationException.CreateFmt( 'TBankLink_Disk.Validate Error: dhNo_Of_Accounts = %d but dhAccount_List.Count = %d', [ HeaderInf, ActualInf ] );

  HeaderInf := dhFields.dhNo_of_Transactions;
  ActualInf := 0;

  For I := dhAccount_List.First to dhAccount_List.Last do
  Begin
    DB := dhAccount_List.Disk_Bank_Account_At( I );
    ActualInf := ActualInf + DB.dbTransaction_List.ItemCount;
  end;
  If ( HeaderInf <> ActualInf ) then
    Raise FHDataValidationException.CreateFmt( 'TBankLink_Disk.Validate Error: dhNo_of_Transactions = %d but sum of dbTransaction_List.Count = %d', [ HeaderInf, ActualInf ] );

  For I := dhAccount_List.First to dhAccount_List.Last do
  Begin
    DB := dhAccount_List.Disk_Bank_Account_At( I );
    HeaderInf := DB.dbFields.dbNo_of_Transactions;
    ActualInf := DB.dbTransaction_List.ItemCount;
    If ( HeaderInf <> ActualInf ) then
      Raise FHDataValidationException.CreateFmt( 'TBankLink_Disk.Validate Error: dbFields.dbNo_of_Transactions = %d but sum of dbTransaction_List.Count = %d', [ HeaderInf, ActualInf ] );
  end;

  If dhFields.dhClient_Code   = '' then Raise FHDataValidationException.Create( 'TBankLink_Disk.Validate Error: dhClient_Code is a required field' );
  If dhFields.dhCreation_Date = 0  then Raise FHDataValidationException.Create( 'TBankLink_Disk.Validate Error: dhCreation_Date is a required field' );
end;
//------------------------------------------------------------------------------

procedure TBankLink_Disk.EmptyDisk;
begin
  if dhAccount_List<>nil then                   // Free any previous accounts and transactions
  begin
    dhAccount_List.Free;
    dhAccount_List := TDisk_Bank_Account_List.Create;
    if not Assigned( dhAccount_List ) then
      Raise FHInsufficientMemoryException.Create( 'TBankLink_Disk.EmptyDisk: Unable to create dhAccount_List ');
  end;
  FillChar( dhFields, Sizeof( dhFields ), 0 );  // Clean-up header
  with dhFields do
  begin
    dhRecord_Type := tkBegin_Disk_Header;
    dhEOR := tkEnd_Disk_Header;
  end;
end;

end.
