unit ClientWrapper;

interface

const
   BANKLINK_SIGNATURE = $BABE;
   SBOOKS_SIGNATURE   = $B00B;

type
   BATypeSet = set of Byte;

   pClientWrapper = ^TClientWrapper;
   TClientWrapper = packed record
      wCRC              : LongWord;
      wSignature        : LongInt;
      wCountry          : Byte;
      wCode             : string[8];
      wName             : string[60];
      wOldPassword      : string[8];
      wVersion          : LongInt;
      wSave_Count       : LongInt;
      wDate_Stored      : LongInt;
      wTime_Stored      : LongInt;
      wReport_Start_Date: LongInt;
      wReporting_Period : LongInt;
      wMagic_Number     : LongInt;
      wVersion_Reqd_Str : string[10];
      wRead_Only        : Boolean;
      wUpdateServer     : String[60];    //dont use this! it will cause 5.12 to fail upgrading
      wPwdHash          : String[32];
      wSpare            : Array[ 1..18] of Byte;
   end;

procedure GetClientWrapper(FileName: string; var W: TClientWrapper; AllowReadOnly: Boolean);

function IntegrityCheckClientWrapper(Wrapper: TClientWrapper): Boolean;
{$IFDEF ParserDLL}
{$ELSE}
function CreatePasswordHash(Password: string): string;
function HasPassword(Wrapper: TClientWrapper): boolean;
{$ENDIF}

implementation

uses
{$IFDEF ParserDll}
   // The Parser DLL just need to read the Wrapper or maybe the client fields
   // All the rest is not needed,
   // and is removed to keep the Dll file size under control
{$ELSE}
  LogUtil,
  GenUtils,
  Cryptcon,
  BankLinkConnect,
{$ENDIF}
  SysUtils,
  bk5Except,
  cryptx;

const
   UnitName = 'CLOBJ32'; // That's where the code came from
   PasswordSalt = 'AD:JL$*D'; //Salt used to prevent reversing of MD5 Hash into usable password.

{$IFDEF ParserDll}
{$ELSE}
  var
    DebugMe: Boolean = false;
{$ENDIF}

procedure GetClientWrapper(FileName: string; var W: TClientWrapper; AllowReadOnly: Boolean);
const
   ThisMethodName = 'GetWrapper';
Var
   F       : File;
   aMsg    : String;
   WasMode : Byte;
Begin
{$IFDEF ParserDll}
   // Don't want Logging
{$ELSE}
   if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Begins');
{$ENDIF}
   try
      FillChar(W, Sizeof(W), 0);
      WasMode := System.FileMode;
      try
         AssignFile(F, FileName);
         if AllowReadOnly then
            System.FileMode := 0;  //open mode = read only
         Reset(F, 1);
         try
            //read wrapper, raise i/o error if not enough bytes read
            BlockRead(F, W, Sizeof(W)); //, NumRead );

            if (W.wVersion > 122)
            and (W.wVersion < 130) then
               // Had to be turned off See case 1743
               cryptx.Decrypt(W.wOldPassword, sizeof(W.wOldPassword));
            if w.wVersion < 140 then
                W.wPwdHash := ''; // Was other stuff
         finally
            CloseFile(f);
         end;
      finally
         System.FileMode := WasMode;
      end;
   except
      on e : EInOutError do begin
         //default message
         aMsg := Format( 'Invalid Wrapper Read for %s [%s]',[ FileName, E.Message]);
{$IFDEF ParserDll}
{$ELSE}
         LogUtil.LogMsg( lmError, UnitName, aMsg);
 {$ENDIF}
         raise EFileWrapper.CreateFmt('%s - %s',[ UnitName, aMsg]);
      end;
   end;
{$IFDEF ParserDll}
{$ELSE}
   if DebugMe then
      LogUtil.LogMsg( lmDebug, UnitName, ThisMethodName+' Ends');
{$ENDIF}
end;

function IntegrityCheckClientWrapper(Wrapper: TClientWrapper): Boolean;
begin
  Result := (Wrapper.wCode <> '')
        and (Wrapper.wName <> '')
        and (Wrapper.wSignature = BankLink_Signature)
{$IFDEF ParserDll}
      ; // Don't link in GenUtils, and we don' care
{$ELSE}
        and IsPrintableCharacters(Wrapper.wCode)
        and IsPrintableCharacters(Wrapper.wName)
        and IsPrintableCharacters(Wrapper.wOldPassword)
       ;
 {$ENDIF}

end;

{$IFDEF ParserDLL}
{$ELSE}
{function HashString(InputString: string): hashDigest;
var
  md5Hash: TMD5;
  output : hashDigest;
begin
  output.A := 0;
  output.B := 0;
  output.C := 0;
  output.D := 0;
  if InputString = '' then
    Result := output
  else
  begin
    md5Hash := TMD5.Create(nil);
    try
      md5Hash.InputType := SourceString;
      md5Hash.InputString := InputString;
      md5Hash.pOutputArray := @output;
      md5Hash.MD5_Hash;
      Result := output;
    finally
      md5Hash.Free;
    end;
  end;
end;}

function CreatePasswordHash(Password: string): string;
begin
  if Password = '' then
    Result := ''
  else
    Result := EncryptPassword(Password + PasswordSalt, false);
end;

function HasPassword(Wrapper: TClientWrapper): boolean;
begin
  Result := (Wrapper.wOldPassword <> '') or (Wrapper.wPwdHash <> '');
end;

{$ENDIF}


initialization
{$IFDEF ParserDll}
{$ELSE}
   DebugMe := DebugUnit(UnitName);
{$ENDIF}
end.
