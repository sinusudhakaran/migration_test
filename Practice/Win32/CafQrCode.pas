unit CafQrCode;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Classes,
  EncryptOpenSSL,
  ExtCtrls,
  Sysutils,
  bkdateutils,
  Libeay32;

const
  PUBLIC_KEY_FILE_CAF_QRCODE = 'PublicKeyCafQrCode.pke';
  QR_CODE_VERSION = '1';
  //QR_CODE_PASSPHRASE = '722A4B3BC7214C66BF68';
  QR_CODE_PASSPHRASE = '687H5H2371F5g7Y8';
  QR_CODE_DELIMITER = '|';
  QR_CODE_VENDOR_ID = 'BANKLINK';

type
  TCAFQRDataAccount = class(TCollectionItem)
  private
    fAccountName : string;
    fAccountNumber : string;
    fClientCode : string;
    fCostCode : String;
    fSMSF : string;
  public
    property AccountName : string read fAccountName write fAccountName;
    property AccountNumber : string read fAccountNumber write fAccountNumber;
    property ClientCode : string read fClientCode write fClientCode;
    property CostCode : String read fCostCode write fCostCode;
    property SMSF : string read fSMSF write fSMSF;
  end;

  TCAFQRData = class(TCollection)
  private
    fStartDate : TDateTime;
    fPracticeCode : string;
    fPracticeCountryCode : String;
    fProvisional : string;
    fFrequency : string;
    fTimeStamp : TDateTime;
    fInstitutionCode : String;
    fInstitutionCountry : String;
  public
    procedure SetProvisional(aChecked : Boolean);
    procedure SetFrequency(aMonthly, aWeekly, aDaily : Boolean; aDefaultIndex : integer);
    procedure SetStartDate(DayIndex, MonthIndex : integer; YearStr : string);
    function Validate(var aError : string): boolean;
    function BuildDataPacket(const Delimiter: String) : String;

    property StartDate : TDateTime read fStartDate write fStartDate;
    property PracticeCode : string read fPracticeCode write fPracticeCode;
    property PracticeCountryCode : String read fPracticeCountryCode write fPracticeCountryCode;
    property Provisional : string read fProvisional write fProvisional;
    property Frequency : string read fFrequency write fFrequency;
    property TimeStamp : TDateTime read fTimeStamp write fTimeStamp;
    property InstitutionCode : String read fInstitutionCode write fInstitutionCode;
    property InstitutionCountry : String read fInstitutionCountry write fInstitutionCountry;
  end;

  TCafQrCode = class
  private
    FDelimiter: string;
    FPassPhrase: String;
    FVendorID: String;
    FVersion: String;

    procedure SetPassPhrase(const Value: String);
    procedure SetVendorID(const Value: String);
    procedure SetDelimiter(aValue : string);
    procedure SetVersion(const Value: String);
  public
    constructor Create;
    procedure BuildQRCode(aCafQRData : TCAFQRData; KeyFile : string; QRCodeImage: TImage);

    property Version: String read FVersion write SetVersion;
    property VendorID: String read FVendorID write SetVendorID;
    property PassPhrase : String read FPassPhrase write SetPassPhrase;

    property Delimiter : string read FDelimiter write SetDelimiter;
  end;

//------------------------------------------------------------------------------
implementation

uses
  uZintBarcode;

{ TCAFQRData }
//------------------------------------------------------------------------------
procedure TCAFQRData.SetProvisional(aChecked : Boolean);
begin
  if aChecked then
    fProvisional := 'Y'
  else
    fProvisional := 'N';
end;

//------------------------------------------------------------------------------
procedure TCAFQRData.SetFrequency(aMonthly, aWeekly, aDaily : Boolean; aDefaultIndex : integer);
begin
  if aMonthly then
    fFrequency := 'M'
  else if aWeekly then
    fFrequency := 'W'
  else if aDaily then
    fFrequency := 'D'
  else
  begin
    case aDefaultIndex of
      0 : fFrequency := 'M';
      1 : fFrequency := 'W';
      2 : fFrequency := 'D';
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TCAFQRData.SetStartDate(DayIndex, MonthIndex : integer; YearStr : string);
var
  YearIndex : integer;
begin
  if TryStrtoInt(YearStr, YearIndex) then
  begin
    MonthIndex := MonthIndex - 1;
    if TryEncodeDate(YearIndex, MonthIndex, DayIndex, fStartDate) then
      Exit;
  end;

  fStartDate := Date;
end;

//------------------------------------------------------------------------------
function TCAFQRData.Validate(var aError : string): boolean;
var
  AccIndex : integer;
begin
  Result := false;

  if length(PracticeCode) > 8 then
  begin
    aError := 'Practice Code exceeds max Length of 8 characters.';
    Exit;
  end;

  if length(PracticeCountryCode) > 10 then
  begin
    aError := 'Practice Country Code exceeds max Length of 10 characters.';
    Exit;
  end;

  if length(Provisional) > 1 then
  begin
    aError := 'Provisional exceeds max Length of 1 character.';
    Exit;
  end;

  if not ((uppercase(Provisional) = 'Y') or (uppercase(Provisional) = 'N')) then
  begin
    aError := 'Invalid character, provisional needs to be either Y or N.';
    Exit;
  end;

  if length(Frequency) > 1 then
  begin
    aError := 'Frequency exceeds max Length of 1 character.';
    Exit;
  end;

  if not ((uppercase(Frequency) = 'D') or
          (uppercase(Frequency) = 'W') or
          (uppercase(Frequency) = 'M')) then
  begin
    aError := 'Invalid character, provisional needs to be either D, W or M.';
    Exit;
  end;

  if length(InstitutionCode) > 10 then
  begin
    aError := 'Institution Code exceeds max Length of 10 characters.';
    Exit;
  end;

  if length(InstitutionCountry) > 10 then
  begin
    aError := 'Institution Country exceeds max Length of 10 characters.';
    Exit;
  end;

  for AccIndex := 0 to Count - 1 do
  begin
    if length(TCAFQRDataAccount(Items[AccIndex]).AccountName) > 100 then
    begin
      aError := 'Account Line - ' + inttostr(AccIndex) + ', ' +
                'Account Name exceeds max Length of 100 characters.';
      Exit;
    end;

    if length(TCAFQRDataAccount(Items[AccIndex]).AccountNumber) > 20 then
    begin
      aError := 'Account Line - ' + inttostr(AccIndex) + ', ' +
                'Account Number exceeds max Length of 20 characters.';
      Exit;
    end;

    if length(TCAFQRDataAccount(Items[AccIndex]).ClientCode) > 10 then
    begin
      aError := 'Account Line - ' + inttostr(AccIndex) + ', ' +
                'Client Code exceeds max Length of 10 characters.';
      Exit;
    end;

    if length(TCAFQRDataAccount(Items[AccIndex]).CostCode) > 10 then
    begin
      aError := 'Account Line - ' + inttostr(AccIndex) + ', ' +
                'Cost Code exceeds max Length of 10 characters.';
      Exit;
    end;

    if length(TCAFQRDataAccount(Items[AccIndex]).SMSF) > 1 then
    begin
      aError := 'Account Line - ' + inttostr(AccIndex) + ', ' +
                'SMSF exceeds max Length of 1 character.';
      Exit;
    end;

    if not ((uppercase(TCAFQRDataAccount(Items[AccIndex]).SMSF) = 'Y') or
            (uppercase(TCAFQRDataAccount(Items[AccIndex]).SMSF) = 'N')) then
    begin
      aError := 'Invalid character, SMSF needs to be either Y or N.';
      Exit;
    end;
  end;

  Result := true;
end;

//------------------------------------------------------------------------------
function TCAFQRData.BuildDataPacket(const Delimiter: String): String;
var
  AccIndex : integer;
begin
  Result := FormatDateTime('DDMMYYYY', fStartDate) + Delimiter +
            fPracticeCode + Delimiter +
            fPracticeCountryCode + Delimiter +
            fProvisional + Delimiter +
            fFrequency + Delimiter +
            FormatDateTime('DDMMYYYYHHMMSS', TimeStamp) + Delimiter +
            InstitutionCode + Delimiter +
            InstitutionCountry + Delimiter;

  for AccIndex := 0 to Count - 1 do
  begin
    Result := Result + TCAFQRDataAccount(Items[AccIndex]).AccountName + Delimiter +
                       TCAFQRDataAccount(Items[AccIndex]).AccountNumber + Delimiter +
                       TCAFQRDataAccount(Items[AccIndex]).ClientCode + Delimiter +
                       TCAFQRDataAccount(Items[AccIndex]).CostCode + Delimiter +
                       TCAFQRDataAccount(Items[AccIndex]).SMSF + Delimiter;
  end;
end;

{ TCafQrCode }
//------------------------------------------------------------------------------
constructor TCafQrCode.Create;
begin
  fVersion    := QR_CODE_VERSION;
  fVendorID   := QR_CODE_VENDOR_ID;
  fPassPhrase := QR_CODE_PASSPHRASE;
  fDelimiter  := QR_CODE_DELIMITER;
end;

//------------------------------------------------------------------------------
procedure TCafQrCode.SetDelimiter(aValue: string);
begin
  FDelimiter := aValue;
end;

//------------------------------------------------------------------------------
procedure TCafQrCode.SetPassPhrase(const Value: String);
begin
  FPassPhrase := Value;
end;

//------------------------------------------------------------------------------
procedure TCafQrCode.SetVendorID(const Value: String);
begin
  FVendorID := Value;
end;

//------------------------------------------------------------------------------
procedure TCafQrCode.SetVersion(const Value: String);
begin
  FVersion := Value;
end;

//------------------------------------------------------------------------------
procedure TCafQrCode.BuildQRCode(aCafQRData : TCAFQRData; KeyFile : string; QRCodeImage: TImage);
const
  SALT_FRONT = 'BL_';
  END_OF_PACKET = 'End';
var
  PacketData : String;
  KeyText : String;
  AESPacket : String;
  Salt : string;
  NumOfInterations : integer;
  SHA256Pass : string;
  RSAKey : TRSAKey;
  EncryptedPass: String;
  QRCode: TZintBarcode;
  BarCodeWidth, BarCodeHeight : integer;
begin
  if Assigned(aCafQRData) then
  begin
    KeyText := '';
    Salt := SALT_FRONT + VendorID;
    NumOfInterations := 26; //.Net uses 28 iterations but is always 2 iterations behind so for compatibility we use 26 iterations.

    PacketData := aCafQRData.BuildDataPacket(FDelimiter);

    SHA256Pass := OpenSSLEncription.SHA256DerivePassword(PassPhrase, Salt, NumOfInterations);

    if OpenSSLEncription.AESEncrypt(SHA256Pass, PacketData, AESPacket, AES_VECTOR) then
    begin
      RSAKey := TXMLKey.Create(KeyFile);

      try
        if OpenSSLEncription.RSAEncrypt(RSAKey, PassPhrase, EncryptedPass, RSA_PKCS1_OAEP_PADDING) > -1 then
        begin
          QRCode := TZintBarcode.Create;

          try
            QRCode.BarcodeType := tBARCODE_QRCODE;
            QRCode.Data := Version       + FDelimiter +
                           VendorID      + FDelimiter +
                           EncryptedPass + FDelimiter +
                           AESPacket     + FDelimiter +
                           END_OF_PACKET;
            QRCodeImage.Width  := QRCode.BarcodeSize.X;
            QRCodeImage.Height := QRCode.BarcodeSize.Y;
            QRCode.GetBarcode(QRCodeImage.Picture.Bitmap);
          finally
            FreeAndNil(QRCode);
          end;
        end;
      finally
        RSAKey.Free;
      end;
    end;
  end;
end;

end.
