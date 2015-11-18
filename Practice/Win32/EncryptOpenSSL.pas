unit EncryptOpenSSL;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Classes,
  libeay32,
  XMLintf,
  XMLDoc;

const
  AES_VECTOR  = '687H5H2371F5g7Y8';

Type
  TArrByte = Array of Byte;

  //----------------------------------------------------------------------------
  TRSAKey = class
  private
    FKeyFile: String;
    FKey: pRSA;

    function GetKey: pRSA;
    function GetSize: Integer;
  protected
    function InitializeKey(const KeyFile: String): pRSA; virtual; abstract;
  public
    constructor Create(const KeyFile: String);
    destructor Destroy; override;

    property Key: pRSA read GetKey;
    property KeyFile: String read FKeyFile;
    property Size: Integer read GetSize;
  end;

  //----------------------------------------------------------------------------
  TXMLKey = class(TRSAKey)
  private
    procedure DecodeStringToStream(const Input: String; Output: TStream);
    procedure DecodeStringToBN(const Input: String; Output: pBIGNUM);
    procedure StreamToBN(Input: TStream; Output: pBIGNUM);
    procedure LoadXmlRSAPublicKey(KeyFile: String; Document: IXMLDocument);
    function GetRSAKeyFromXML(KeyFile : string) : pRSA;
  protected
    function InitializeKey(const KeyFile: String): pRSA; override;
  end;

  //----------------------------------------------------------------------------
  TPEMKey = class(TRSAKey)
    function InitializeKey(const KeyFile: String): pRSA; override;
  end;

  //----------------------------------------------------------------------------
  TEncryptOpenSSL = class
  private
    fKeyLength: word;
    fPassword: string;
    fPrivateKeyFilename : string;
    fPublicKeyFileName  : string;
    fSeedFile : string;

    function StringToArrByte(inString : String) : TArrByte;
    function ArrByteToString(arrByte : TArrByte) : String;

    function GetAESPaddedStr(inString : String) : string;
    function RemoveAESPadding(InString: String): String;

    function ReadRSAPrivateKey(AFileName: string): pRSA;
    function ReadRSAPublicKey(AFileName: string): pRSA;

    function ReverseString(const Source: AnsiString): AnsiString;
    procedure ReverseBytes(Source, Dest: Pointer; Size: Integer);

    procedure Base64EncodeBytes(Source: Pointer; out Dest: Pointer; var Size: Integer);
    function Base64EncodeString(Source: String): String;
    function Base64DecodeString(Source: String): String;
  public
    constructor Create;
    destructor Destroy; override;

    function GetRandomKey : string;
    function RijndaelEncrypt(aInString: string; aKeyString : string): string;

    procedure AnsiStringToUTF32(const Source: AnsiString; Dest: Pointer; Size: Integer);

    function StringtoHex(Data: string): string;

    function GenerateRSAKeys( aPrivateKeyFilename, aPublicKeyFileName : String) : Boolean;

    function SimpleRSAEncrypt(aInString : string; aKeyFile : string): string;

    function RSAEncrypt(PublicKey: TRSAKey; Cleartext : AnsiString; var Encryptedtext: AnsiString; padding: integer) : integer; overload;
    function RSAEncrypt(PublicKey: TRSAKey; ClearData, EncryptedData: TStream; padding: Integer) : integer; overload;

    function RSADecrypt(KeyFile, Encryptedtext : string; var Cleartext: string; padding: integer) : integer;

    function AESEncrypt(KeyText : string;
                        InText : string;
                        var OutText: string;
                        Vector : string) : boolean; overload;

    function AESEncrypt(PasswordBytes : PAnsiChar;
                        InText : string;
                        var OutText: string;
                        Vector : string) : boolean; overload;

    function AESDecrypt(KeyText : string;
                        InText : string;
                        var OutText: string;
                        Vector : string) : Boolean;

    function EncodeSHA256(InString: AnsiString; SaltText : AnsiString) : AnsiString; overload;
    function EncodeSHA256(InBuffer: Pointer; BufferSize: Integer; OutBuffer: PAnsiChar) : Integer; overload;
    function EncodeSHA256(InBuffer, Salt: Pointer; InBufferSize, SaltSize: Integer; OutBuffer: PAnsiChar) : Integer; overload;

    procedure ReEncodeSHA256(aEncodedBuffer: PAnsiChar);

    function SHA256DerivePassword(InString: string; SaltText : String; Iterations : integer): AnsiString;

    function GetError : String;
  end;

//------------------------------------------------------------------------------
function OpenSSLEncription : TEncryptOpenSSL;

//------------------------------------------------------------------------------
implementation

uses
  SysUtils,
  StrUtils,
  EncdDecd,
  IdCoder,
  IdCoderMIME,
  IdGlobal;

Const
  AES_KEY_BIT_SIZE = 256;

var
  fEncryptOpenSSL : TEncryptOpenSSL;

//------------------------------------------------------------------------------
function OpenSSLEncription : TEncryptOpenSSL;
begin
  if not assigned(fEncryptOpenSSL) then
    fEncryptOpenSSL := TEncryptOpenSSL.Create;

  Result := fEncryptOpenSSL;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.StringtoHex(Data: string): string;
var
  DataIndex : Integer;
begin
  Result := '';
  for DataIndex := 1 to Length(Data) do
  begin
    Result := Result + IntToHex(Ord(Data[DataIndex]), 2);
    if DataIndex < Length(Data) then
      Result := Result + ' ';
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.StringToArrByte(inString: String): TArrByte;
var
  Index : integer;
begin
  SetLength(Result, Length(inString));

  for Index := 0 to Length(inString) - 1 do
  begin
    Result[Index] := ord(inString[Index + 1]);
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.ArrByteToString(arrByte : TArrByte) : String;
var
  Index : integer;
begin
  Result := '';
  for Index := 0 to High(arrByte) do
  begin
    Result := Result + chr(arrByte[Index]);
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.Base64DecodeString(Source: String): String;
begin
  Result := IdCoder.DecodeString(TIdDecoderMIME, Source);
end;

//------------------------------------------------------------------------------
procedure TEncryptOpenSSL.Base64EncodeBytes(Source: Pointer; out Dest: Pointer; var Size: Integer);
var
  Stream: TStream;
  Encoder: TIdEncoderMIME;
  EncodedData: String;
  EncodedDataSize: Integer;
begin
  Stream := TMemoryStream.Create;

  try
    Stream.WriteBuffer(Source^, Size);

    Stream.Position := 0;

    Encoder := TIdEncoderMIME.Create;

    try
      EncodedData := Encoder.Encode(Stream);

      EncodedDataSize := Length(EncodedData) * SizeOf(AnsiChar);

      GetMem(Dest, EncodedDataSize);

      Move(EncodedData[1], Dest^, EncodedDataSize);

      Size := EncodedDataSize;
    finally
      Encoder.Free;
    end;
  finally
    Stream.Free;
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.Base64EncodeString(Source: String): String;
begin
  Result := IdCoder.EncodeString(TIdEncoderMIME, Source);
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.ReadRSAPrivateKey(AFileName: string): pRSA;
var
  Keyfile: pBIO;

  // Callback for encrypted private key
  function Passwordcallback(buffer  : PCharacter;
                            blength : integer;
                            verify  : integer;
                            data    : pointer): integer; cdecl;
  var
    Password : string;
  begin
    Password := '1qaz!QAZ';

    StrPCopy(buffer, Password);
    result := Length(Password);
  end;

begin
  Result  := RSA_new;
  keyfile := BIO_new(BIO_s_file());
  BIO_read_filename(keyfile, PChar(AFilename));
  result  := PEM_read_bio_RSAPrivateKey(keyfile, Result, @Passwordcallback, self);
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.ReadRSAPublicKey(AFileName: string): pRSA;
var
  Keyfile: pBIO;

  // Callback for encrypted private key
  function Passwordcallback(buffer  : PCharacter;
                            blength : integer;
                            verify  : integer;
                            data    : pointer): integer; cdecl;
  var
    Password : string;
  begin
    Password := '1qaz!QAZ';

    StrPCopy(buffer, Password);
    result := Length(Password);
  end;

begin
  Result  := RSA_new;
  keyfile := BIO_new(BIO_s_file());
  BIO_read_filename(keyfile, PChar(AFilename));
  Result  := PEM_read_bio_RSAPublicKey(keyfile, Result, @Passwordcallback, self);
end;

//------------------------------------------------------------------------------
procedure TEncryptOpenSSL.ReEncodeSHA256(aEncodedBuffer: PAnsiChar);
var
  OutBuffer: Pointer;
begin
  GetMem(OutBuffer, SHA256_DIGEST_LENGTH);

  try
    ZeroMemory(OutBuffer, SHA256_DIGEST_LENGTH);

    EncodeSHA256(aEncodedBuffer, SHA256_DIGEST_LENGTH, OutBuffer);

    ZeroMemory(aEncodedBuffer, SHA256_DIGEST_LENGTH);

    Move(OutBuffer^, aEncodedBuffer^, SHA256_DIGEST_LENGTH);
  finally
    FreeMem(OutBuffer);
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.RemoveAESPadding(InString: String): String;
var
  Padding: Integer;
begin
  {The last char is always the length of the padding}
  Padding := Ord(InString[Length(InString)]);

  Result := MidStr(InString, 1,Length(InString) - Padding);
end;

//------------------------------------------------------------------------------
procedure TEncryptOpenSSL.ReverseBytes(Source, Dest: Pointer; Size: Integer);
var
  Index: Integer;
begin
  for Index := 0 to Size - 1 do
  begin
    Move(Pointer(LongInt(Source) + Index)^, Pointer(LongInt(Dest) + (Size - Index - 1))^ , 1);
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.ReverseString(const Source: AnsiString): AnsiString;
var
  Index: Integer;
begin
  Result := '';

  for Index := Length(Source) downto 1 do
  begin
    Result := Result + Source[Index];
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.RijndaelEncrypt(aInString: string; aKeyString : string): string;
const
  INIT_VECTOR = '@AT^NK(@YUVK)$#Y';
{          // Constants used in our AES256 (Rijndael) Encryption / Decryption
        const string initVector = "@1B2c3D4e5F6g7H8";     // Must be 16 bytes
        const string passPhrase = "Pas5pr@se";            // Any string
        const string saltValue = "s@1tValue";             // Any string
        const string hashAlgorithm = "SHA1";              // Can also be "MD5", "SHA1" is stronger
        const int passwordIterations = 2;                 // Can be any number, usually 1 or 2
        const int keySize = 256;                          // Allowed values: 192, 128 or 256}
var
  OutString : string;
begin
  Result := '';
  if AESEncrypt(aKeyString, aInString, OutString, INIT_VECTOR) then
  begin
    Result := OutString;
  end;
end;

//------------------------------------------------------------------------------
constructor TEncryptOpenSSL.Create;
begin
  fKeyLength := 1024;
  fPassword := '1qaz!QAZ';
  fSeedFile := 'c:\temp\seed.sed';

  OpenSSL_add_all_algorithms();
  OpenSSL_add_all_ciphers();
  OpenSSL_add_all_digests();

  ERR_load_crypto_strings;
end;

//------------------------------------------------------------------------------
destructor TEncryptOpenSSL.Destroy;
begin
  ERR_free_strings;
  EVP_cleanup;
  inherited;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.EncodeSHA256(InBuffer, Salt: Pointer; InBufferSize, SaltSize: Integer; OutBuffer: PAnsiChar): Integer;
var
  psha256Rec : pSHA256_CTX;
begin
  Result := 0;

  New(psha256Rec);
  try
    SHA256_Init(psha256Rec);
    
    SHA256_Update(psha256Rec, InBuffer, InBufferSize);

    if SaltSize > 0 then
    begin
      SHA256_Update(psha256Rec, Salt, SaltSize);
    end;

    ZeroMemory(OutBuffer, SHA256_DIGEST_LENGTH);

    Result := SHA256_Final(OutBuffer, psha256Rec);
  finally
    Dispose(psha256Rec);
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.GenerateRSAKeys( aPrivateKeyFilename, aPublicKeyFileName : String) : Boolean;
var
  rsa: pRSA;
  PrivateKeyOut, PublicKeyOut, ErrMsg: pBIO;
  buff: array [0..1023] of char;
  enc: pEVP_CIPHER;
begin
  Result := False;

  fPrivateKeyFilename := aPrivateKeyFilename;
  fPublicKeyFileName := aPublicKeyFileName;

  // Three key triple DES in CBC
  enc := EVP_des_ede3_cbc;

  // Load a pseudo random file
  RAND_load_file(PChar(fSeedFile), -1);

  ErrMsg := nil;
  rsa := RSA_generate_key(fKeyLength, RSA_F4, nil, ErrMsg);
  if rsa=nil then
  begin
    BIO_reset(ErrMsg);
    BIO_read(ErrMsg, @buff, 1024);
    Exit;
  end;

  PrivateKeyOut := BIO_new(BIO_s_file());
  BIO_write_filename(PrivateKeyOut, PChar(fPrivateKeyFilename));
  PublicKeyOut := BIO_new(BIO_s_file());
  BIO_write_filename(PublicKeyOut, PChar(fPublicKeyFileName));

  PEM_write_bio_RSAPrivateKey(PrivateKeyOut, rsa, enc, nil, 0, nil, PChar(fPassword));
  PEM_write_bio_RSAPublicKey(PublicKeyOut, rsa);

  if rsa <> nil then
    RSA_free(rsa);
  if PrivateKeyOut <> nil then
    BIO_free_all(PrivateKeyOut);
  if PublicKeyOut <> nil then
    BIO_free_all(PublicKeyOut);
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.RSAEncrypt(PublicKey: TRSAKey; Cleartext : AnsiString; var Encryptedtext: AnsiString; padding: integer) : integer;
var
  ClearData : Pointer;
  ClearDataSize : integer;
  UnencryptedData: TStream;
  EncryptedData : TStringStream;
begin
  ClearDataSize := length(ClearText) * 4;

  GetMem(ClearData, ClearDataSize);

  try
    //The .Net decrypter expects that the encrypted text is UTF32.
    AnsiStringToUTF32(ClearText, ClearData, ClearDataSize);

    UnencryptedData := TStringStream.Create('');

    try
      UnencryptedData.WriteBuffer(ClearData^, ClearDataSize);

      UnencryptedData.Position := 0;

      EncryptedData := TStringStream.Create('');

      try
        Result := RSAEncrypt(PublicKey, UnencryptedData, EncryptedData, padding);

        EncryptedText := EncryptedData.DataString;
      finally
        EncryptedData.Free;
      end;
    finally
      UnencryptedData.Free;
    end;
  finally
    FreeMem(ClearData);
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.RSADecrypt(KeyFile, Encryptedtext : string; var Cleartext: string; padding: integer) : integer;
var
  PrivateKey : pRSA;
  PrivateKeySize : integer;

  ClearData : PChar;

  EncryptedData : pChar;
  EncryptedDataSize : integer;
begin
  PrivateKey := ReadRSAPrivateKey(KeyFile);
  try
    PrivateKeySize := RSA_size(PrivateKey);

    EncryptedDataSize := length(Encryptedtext);
    EncryptedData     := Addr(Encryptedtext[1]);

    Setlength(Cleartext, PrivateKeySize - 11);
    ClearData := Addr(Cleartext[1]);

    Result := RSA_private_decrypt(EncryptedDataSize, EncryptedData, ClearData, PrivateKey, padding);
  Finally
    RSA_free(PrivateKey);
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.RSAEncrypt(PublicKey: TRSAKey; ClearData, EncryptedData: TStream; padding: Integer): Integer;
var
  MaxBlockSize: Integer;
  Iterations: Integer;
  Iteration: Integer;
  ClearDataBlock: Pointer;
  DataBlockSize: Integer;
  ReversedData: Pointer;
  EncryptedDataBlock: Pointer;
  EncryptedBlockSize: Integer;
  EncodedData: Pointer;
begin
  Result := 0;

  EncodedData := nil;
  ReversedData := nil;
  EncryptedDataBlock := nil;

  MaxBlockSize := PublicKey.Size - 42;

  Iterations := ClearData.Size div MaxBlockSize;

  for Iteration := 0 to Iterations do
  begin
    if ClearData.Size - MaxBlockSize * Iteration > MaxBlockSize then
    begin
      DataBlockSize := MaxBlockSize;
    end
    else
    begin
      DataBlockSize := ClearData.Size - MaxBlockSize * Iteration;
    end;

    GetMem(ClearDataBlock, DataBlockSize);

    try
      ClearData.ReadBuffer(ClearDataBlock^, DataBlockSize);

      GetMem(EncryptedDataBlock, PublicKey.Size);

      try
        EncryptedBlockSize := RSA_public_encrypt(DataBlockSize, ClearDataBlock, EncryptedDataBlock, PublicKey.Key, padding);

        if EncryptedBlockSize > -1 then
        begin
          GetMem(ReversedData, EncryptedBlockSize);

          try
            ReverseBytes(EncryptedDataBlock, ReversedData, EncryptedBlockSize);

            Base64EncodeBytes(ReversedData, EncodedData, EncryptedBlockSize);

            try
              EncryptedData.WriteBuffer(EncodedData^, EncryptedBlockSize);
            finally
              FreeMem(EncodedData);
            end;
          finally
            FreeMem(ReversedData);
          end;
        end
        else
        begin
          Result := -1;
        end;
      finally
        FreeMem(EncryptedDataBlock);
      end;
    finally
      FreeMem(ClearDataBlock);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.AESEncrypt(KeyText : string;
                                    InText : string;
                                    var OutText: string;
                                    Vector : string) : boolean;
var
  AESkey     : AES_KEY;
  pAESkey    : pAES_KEY;
  KeyData    : pChar;
  InData     : PChar;
  InDataSize : integer;
  OutData    : PChar;
  VectorData : PChar;
  KeyRes     : integer;
begin
  pAESkey := Addr(AESkey);
  KeyData := Addr(KeyText[1]);

  InText     := GetAESPaddedStr(InText);
  InDataSize := length(InText);
  InData     := Addr(InText[1]);

  Setlength(OutText, InDataSize);
  OutData := Addr(OutText[1]);
  VectorData := Addr(Vector[1]);

  KeyRes := AES_set_encrypt_key(KeyData, AES_KEY_BIT_SIZE, pAESkey);

  AES_cbc_encrypt(InData, OutData, InDataSize, pAESkey, VectorData, AES_ENCRYPT_OPT);

  OutText := Base64EncodeString(OutText);

  Result := True;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.AESEncrypt(PasswordBytes: PAnsiChar; InText: string; var OutText: string; Vector: string): boolean;
var
  AESkey     : AES_KEY;
  pAESkey    : pAES_KEY;
  InData     : PChar;
  InDataSize : integer;
  OutData    : PChar;
  VectorData : PChar;
  KeyRes     : integer;
begin
  pAESkey := Addr(AESkey);

  InText     := GetAESPaddedStr(InText);
  InDataSize := length(InText);
  InData     := Addr(InText[1]);

  Setlength(OutText, InDataSize);
  OutData := Addr(OutText[1]);
  VectorData := Addr(Vector[1]);

  KeyRes := AES_set_encrypt_key(PasswordBytes, AES_KEY_BIT_SIZE, pAESkey);

  AES_cbc_encrypt(InData, OutData, InDataSize, pAESkey, VectorData, AES_ENCRYPT_OPT);

  OutText := Base64EncodeString(OutText);

  Result := True;
end;

//------------------------------------------------------------------------------
procedure TEncryptOpenSSL.AnsiStringToUTF32(const Source: AnsiString; Dest: Pointer; Size: Integer);
//This function basically works by placing a single byte character at every 4th byte so that there are three zeros in between

var
  Offset: Integer;
  SourceChar: AnsiChar;
begin
  ZeroMemory(Dest, Size);

  Offset := 0;

  for SourceChar in Source do
  begin
    Move(SourceChar, Pointer(LongInt(Dest) + Offset)^, SizeOf(AnsiChar));

    //Write a single byte character at every four bytes
    Inc(Offset, 4);
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.AESDecrypt(KeyText : string;
                                    InText : string;
                                    var OutText: string;
                                    Vector : string) : boolean;
var
  AESkey     : AES_KEY;
  pAESkey    : pAES_KEY;
  KeyData    : pChar;
  InData     : PChar;
  InDataSize : integer;
  OutData    : PChar;
  VectorData : PChar;
  KeyRes     : integer;
begin
  pAESkey := Addr(AESkey);
  KeyData := Addr(KeyText[1]);

  InText := Base64DecodeString(InText);
  
  InDataSize := length(InText);
  InData     := Addr(InText[1]);

  Setlength(OutText, InDataSize);
  OutData := Addr(OutText[1]);
  VectorData := Addr(Vector[1]);

  KeyRes := AES_set_decrypt_key(KeyData, AES_KEY_BIT_SIZE, pAESkey);

  AES_cbc_encrypt(InData, OutData, InDataSize, pAESkey, VectorData, AES_DECRYPT_OPT);

  OutText := RemoveAESPadding(OutText);

  Result := true;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.EncodeSHA256(InString: AnsiString; SaltText : AnsiString): AnsiString;
var
  psha256Rec : pSHA256_CTX;
  InDataSize : integer;
  OutData : Pointer;
  SaltDataSize : integer;
begin
  Result := '';

  New(psha256Rec);

  try
    InDataSize := Length(InString);

    SaltDataSize := Length(SaltText);

    SHA256_Init(psha256Rec);
    SHA256_Update(psha256Rec, PAnsiChar(InString), InDataSize);

    if SaltDataSize > 0 then
    begin
      SHA256_Update(psha256Rec, PAnsiChar(SaltText), SaltDataSize);
    end;

    GetMem(OutData, SHA256_DIGEST_LENGTH * SizeOf(Char));

    try
      ZeroMemory(OutData, SHA256_DIGEST_LENGTH);

      if SHA256_Final(OutData, psha256Rec) = 1 then
      begin
        SetLength(Result, SHA256_DIGEST_LENGTH * 2);

        BinToHex(OutData, @Result[1], SHA256_DIGEST_LENGTH);
      end;
    finally
      FreeMem(OutData);
    end;
  finally
    Dispose(psha256Rec);
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.EncodeSHA256(InBuffer: Pointer; BufferSize: Integer; OutBuffer: PAnsiChar): Integer;
var
  psha256Rec : pSHA256_CTX;
begin
  Result := 0;
  
  New(psha256Rec);

  try
    SHA256_Init(psha256Rec);
    SHA256_Update(psha256Rec, InBuffer, BufferSize);

    ZeroMemory(OutBuffer, SHA256_DIGEST_LENGTH);

    Result := SHA256_Final(OutBuffer, psha256Rec);
  finally
    Dispose(psha256Rec);
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.SHA256DerivePassword(InString: string; SaltText : String; Iterations : integer): AnsiString;
var
  IterationNumber : integer;
  OutBuffer: PAnsiChar;
  Temp: String;
begin
  Result := Instring;

  GetMem(OutBuffer, SHA256_DIGEST_LENGTH);

  try
    EncodeSHA256(PAnsiChar(InString), PAnsiChar(SaltText), Length(InString), Length(SaltText), OutBuffer);

    for IterationNumber := 1 to Iterations do
    begin
      ReEncodeSHA256(OutBuffer);
    end;

    ReEncodeSHA256(OutBuffer);

    SetLength(Temp, SHA256_DIGEST_LENGTH * 2);

    BinToHex(OutBuffer, @Temp[1], SHA256_DIGEST_LENGTH);

    Result := OutBuffer;  
  finally
    FreeMem(OutBuffer);
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.SimpleRSAEncrypt(aInString : string; aKeyFile : string): string;
var
  RSAKey : TRSAKey;
  OutString : string;

    //----------------------------------------------------------------------------
  function EncryptStreamUsingKey(PublicKey: TRSAKey; ClearData, EncryptedData: TStream; padding: Integer): Integer;
  var
    ClearDataBlock: Pointer;
    DataBlockSize: Integer;
    EncryptedDataBlock: Pointer;
    EncryptedBlockSize: Integer;
    EncodedData: Pointer;
  begin
    Result := 0;

    DataBlockSize := ClearData.Size;
    GetMem(ClearDataBlock, DataBlockSize);

    try
      ClearData.ReadBuffer(ClearDataBlock^, DataBlockSize);
      GetMem(EncryptedDataBlock, PublicKey.Size);

      try
        EncryptedBlockSize := RSA_public_encrypt(DataBlockSize, ClearDataBlock, EncryptedDataBlock, PublicKey.Key, padding);

        if EncryptedBlockSize > -1 then
        begin
          Base64EncodeBytes(EncryptedDataBlock, EncodedData, EncryptedBlockSize);

          try
            EncryptedData.WriteBuffer(EncodedData^, EncryptedBlockSize);
          finally
            FreeMem(EncodedData);
          end;
        end;

      finally
        FreeMem(EncryptedDataBlock);
      end;

    finally
      FreeMem(ClearDataBlock);
    end;
  end;

  //----------------------------------------------------------------------------
  function EncryptUsingKey(PublicKey: TRSAKey; Cleartext : AnsiString; var Encryptedtext: AnsiString; padding: integer) : integer;
  var
    UnencryptedData: TStream;
    EncryptedData : TStringStream;
  begin
    UnencryptedData := TStringStream.Create(Cleartext);
    try
      EncryptedData := TStringStream.Create('');
      try
        Result := EncryptStreamUsingKey(PublicKey, UnencryptedData, EncryptedData, padding);

        EncryptedText := EncryptedData.DataString;
      finally
        EncryptedData.Free;
      end;
    finally
      UnencryptedData.free;
    end;
  end;

begin
  RSAKey := TXMLKey.Create(aKeyFile);
  try
    // old padding is RSA_PKCS1_PADDING
    if EncryptUsingKey(RSAKey, aInString, OutString, RSA_PKCS1_OAEP_PADDING) > -1 then
    begin
      Result := OutString;
    end;
  finally
    RSAKey.Free;
  end;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.GetAESPaddedStr(inString: String): string;
var
  InStrLen : integer;
  PaddingAmount : integer;
  PadIndex : integer;
begin
  Result := inString;

  InStrLen := Length(inString);

  PaddingAmount := AES_BLOCK_SIZE - (InStrLen - (trunc(InStrLen / AES_BLOCK_SIZE) * AES_BLOCK_SIZE));

  {PKCS7 pads to the number of bytes using the number of bytes as the padding character.}
  for PadIndex := 1 to PaddingAmount do
    Result := Result + Chr(PaddingAmount);
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.GetError: String;
var
  ErrorId : integer;
  Error : PAnsiChar;
begin
  Error := '';
  ErrorId := ERR_get_error;
  Error := ERR_error_string(ErrorId, Error);
  Result := Error;
end;

//------------------------------------------------------------------------------
function TEncryptOpenSSL.GetRandomKey: string;
var
  KeyIndex : integer;
  TableSize : integer;
  hours, mins, secs, milliSecs : Word;
begin
  Result := '';

  DecodeTime(now, hours, mins, secs, milliSecs);
  RandSeed := (milliSecs * secs * (mins * 60));

  TableSize := Length(GBase64CodeTable);

  for KeyIndex := 0 to 31 do
    Result := Result + GBase64CodeTable[random(TableSize-1)+1];
end;

//------------------------------------------------------------------------------
{ TRSAKey }
constructor TRSAKey.Create(const KeyFile: String);
begin
  FKeyFile := KeyFile;
  FKey := nil;
end;

//------------------------------------------------------------------------------
destructor TRSAKey.Destroy;
begin
  if FKey <> nil then
  begin
    RSA_free(FKey);
  end;

  inherited;
end;

//------------------------------------------------------------------------------
function TRSAKey.GetKey: pRSA;
begin
  if FKey = nil then
  begin
    FKey := InitializeKey(KeyFile);
  end;

  Result := FKey;
end;

//------------------------------------------------------------------------------
function TRSAKey.GetSize: Integer;
begin
  Result := RSA_size(GetKey);
end;

{ TXMLKey }
//------------------------------------------------------------------------------
procedure TXMLKey.DecodeStringToBN(const Input: String; Output: pBIGNUM);
var
  Data: TStream;
begin
  Data := TMemoryStream.Create;

  try
    DecodeStringToStream(Input, Data);
    Data.Position := 0;

    StreamToBN(Data, Output);
  finally
    Data.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TXMLKey.DecodeStringToStream(const Input: String; Output: TStream);
var
  InStr: TStringStream;
begin
  InStr := TStringStream.Create(Input);
  try
    DecodeStream(InStr, Output);
  finally
    InStr.Free;
  end;
end;

//------------------------------------------------------------------------------
function TXMLKey.GetRSAKeyFromXML(KeyFile: string): pRSA;
var
  KeyDocument: IXMLDocument;
  RSANode: IXMLNode;
  ModulusNode: IXMLNode;
  ExponentNode: IXMLNode;
  Modulus, Exponent : pBIGNUM;
  EVPKey : pEVP_PKEY;
begin
  Result := nil;
  Modulus := nil;
  Exponent := nil;

  KeyDocument := NewXMLDocument;

  LoadXmlRSAPublicKey(KeyFile, KeyDocument);

  RSANode := KeyDocument.ChildNodes.FindNode('RSAKeyValue');

  if Assigned(RSANode) then
  begin
    ModulusNode := RSANode.ChildNodes.FindNode('Modulus');

    if Assigned(ModulusNode) then
    begin
      Modulus := BN_New;

      DecodeStringToBN(ModulusNode.NodeValue, Modulus);
    end;

    ExponentNode := RSANode.ChildNodes.FindNode('Exponent');

    if Assigned(ExponentNode) then
    begin
      Exponent := BN_New;

      DecodeStringToBN(ExponentNode.NodeValue, Exponent);
    end;

    if Assigned(ModulusNode) and Assigned(ExponentNode) then
    begin
      EVPKey := EVP_PKEY_new;

      Result := RSA_new;
      Result^.n := Modulus;
      Result^.e := Exponent;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TXMLKey.InitializeKey(const KeyFile: String): pRSA;
begin
  Result := GetRSAKeyFromXML(KeyFile);
end;

//------------------------------------------------------------------------------
procedure TXMLKey.LoadXmlRSAPublicKey(KeyFile: String; Document: IXMLDocument);
const
  FIRST_NODE = '<RSAKeyValue>';

var
  KeyTextFile : TextFile;
  InString : String;
  RSAPos : integer;
begin
  Assignfile(KeyTextFile, KeyFile);

  Reset(KeyTextFile);

  try
    Readln(KeyTextFile, InString);
  finally
    CloseFile(KeyTextFile);
  end;

  RSAPos := Pos(FIRST_NODE, InString);

  if RSAPos > 0 then
  begin
    InString := RightStr(InString, Length(InString) - (RSAPos-1));

    Document.Active := false;
    Document.XML.Add(Instring);
    Document.Active := true;
  end;
end;

//------------------------------------------------------------------------------
procedure TXMLKey.StreamToBN(Input: TStream; Output: pBIGNUM);
var
  Buffer: Pointer;
begin
  GetMem(Buffer, Input.Size);

  try
    Input.ReadBuffer(Buffer^, Input.Size);

    Output := BN_bin2bn(Buffer, Input.Size, Output);
  finally
    FreeMem(Buffer);
  end;
end;

{ TPEMKey }
//------------------------------------------------------------------------------
function TPEMKey.InitializeKey(const KeyFile: String): pRSA;
var
  KeyData: pBIO;

  // Callback for encrypted private key
  function Passwordcallback(buffer  : PCharacter;
                            blength : integer;
                            verify  : integer;
                            data    : pointer): integer; cdecl;
  var
    Password : string;
  begin
    Password := '1qaz!QAZ';

    StrPCopy(buffer, Password);
    result := Length(Password);
  end;

begin
  Result  := RSA_new;

  KeyData := BIO_new(BIO_s_file());

  BIO_read_filename(KeyData, PChar(KeyFile));

  Result  := PEM_read_bio_RSAPublicKey(KeyData, Result, @Passwordcallback, self);
end;

initialization

//------------------------------------------------------------------------------
finalization
begin
  if assigned(fEncryptOpenSSL) then
    FreeAndNil(fEncryptOpenSSL);
end;

end.
