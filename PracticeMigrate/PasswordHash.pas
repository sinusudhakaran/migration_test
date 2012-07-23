unit PasswordHash;

interface

function  ComputePWHash(plainText: string;
                      saltbytes: tguid): string;

//function Encrypt(value: string): string;

implementation

uses
 uTPLb_StreamCipher,
 classes, OmniXMLUtils,
 sysutils, Cryptcon,md5Unit;


function ReText(Input: Pchar; Size: integer): string;
var InStream: TMemoryStream;
    OutStream: TStringStream;

begin
  Result := '';
  Instream := TMemoryStream.Create;
  OutStream := TStringStream.Create('');
  try
     instream.WriteBuffer(Input^,Size);
     instream.Position := 0;
     Outstream.Position := 0;
     Base64Encode(Instream, Outstream);
     Result := outstream.DataString;
  finally
     FreeandNil(Instream);
     FreeandNil(Outstream);
  end;
end;

(*
function Encrypt(value: string): string;
var Cipher: IStreamCipherEx2;
begin

 Cipher:= IStreamCipherEx2;
      Cipher.InitStr(KeyStr,TDCP_sha1);         // initialize the cipher with a hash of the passphrase
      for i:= 0 to Memo1.Lines.Count-1 do       // encrypt the contents of the memo
        Memo1.Lines[i]:= Cipher.EncryptString(Memo1.Lines[i]);
      Cipher.Burn;
      Cipher.Free
end;
 *)

function  ComputePWHash(plainText: string;
                      saltbytes: tguid): string;
var
   md5hash  : TMD5;
   Inarray   : array[0..255] of byte;
   outarray  : array[0..32] of byte;
begin
   Result := '';
   if plainText = '' then
      Exit; // No PW set...       
   // Add The Text to in iput array
   StrCopy(PChar(@Inarray),Pchar(Plaintext));
   //Appent the Guid as Salt
   move(saltbytes,Inarray[Length(Plaintext)],Sizeof(tGuid));

   //apply md5 algorithm to in array
   md5hash := TMD5.Create(nil);
   try
       md5hash.InputType    := SourceByteArray;
       md5hash.pInputArray  := @Inarray;
       md5hash.InputLength  := Length(Plaintext) + Sizeof(tGuid);
       md5hash.pOutputArray := @outarray;

       // Make the Hash
       md5hash.MD5_Hash;

       // Add the Guid
       move(saltbytes,OutArray[16],Sizeof(tGuid));

       // Convert to Text
       Result := ReText(PChar(@outArray),16 + Sizeof(tguid));
   finally
       md5hash.Free;
   end;
end;


end.
