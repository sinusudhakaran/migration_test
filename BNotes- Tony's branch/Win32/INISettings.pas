unit INISettings;
//------------------------------------------------------------------------------
{
   Title:       INI Settings

   Description: Hold variables for the INI settings and handles read/write

   Remarks:

   Author:      Matthew Hopkins Jul 2001

}
//------------------------------------------------------------------------------

interface

const
   INIFileName = 'BNOTES.INI';
   MAX_MRU     = 9;
   mtMAPI      = 0;
   mtSMTP      = 1;

var
   INI_mfStatus      : integer;
   INI_mfTop         : integer;
   INI_mfLeft        : integer;
   INI_mfWidth       : integer;
   INI_mfHeight      : integer;
   INI_mfShowPanel   : Boolean;

   INI_DefaultFileLocation : string;
   INI_LastFileOpened      : string;
   INI_Theme               : string;

   INI_MRUList             : Array [1..MAX_MRU] of String;

   INI_MAIL_TYPE           : integer;

   INI_SMTP_FROMADDR       : string;
   INI_SMTP_FROMNAME       : string;
   INI_SMTP_USERID         : string;
   INI_SMTP_PWD            : string;
   INI_SMTP_HOST           : string;
   INI_SMTP_PWDReqd        : boolean;
   INI_SMTP_PORT           : integer;
   INI_SMTP_TIMEOUT        : integer;

procedure ReadLocalINI;
procedure WriteLocalINI;

//******************************************************************************
implementation
uses
   iniFiles,
   stStrL,
   sysUtils,
   Cryptcon,
   Blowunit,
   Forms, Windows, WinUtils, SysLog, ecGlobalConst, SHFolder;

const
   GrpMainForm       = 'MainForm';
   GrpUserSettings   = 'Enviroment';
   GrpMRUList        = 'MRUList';
   GrpMail           = 'Mail';

type
   TCryptoArray = array [0..127] Of Char;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function PassKey : string;
const
   KeyPart1          = 'z3f8b37c';
   KeyPart2          = 'vk9!SFG%';
var
   i : integer;
begin
   for i := 1 to 8 do
      result := result + KeyPart1[i] + KeyPart2[ i];
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DecryptPass(BFKey: string; Encrypted: string) : string;
var
   InArray   : TCryptoArray;
   OutArray  : TCryptoArray;
   BlowFish2 : TBlowFish;
begin
   Result := '';
   if Encrypted = '' then exit;

   FillChar(InArray, Sizeof(InArray), #0);
   FillChar(OutArray, Sizeof(OutArray), #0);
   StrpCopy(InArray, Encrypted);
   BlowFish2 := TBlowFish.Create(Nil);
   try
      with BlowFish2 do begin
         CipherMode    := ECBMode;
         Key           := BFKey;
         InputType     := SourceByteArray;
         InputLength   := Length(Encrypted);
         pInputArray   := @InArray;
         pOutputArray  := @OutArray;
         DecipherData(false);
      end;
      Result := OutArray;
   finally
      BlowFish2.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EncryptPass(BFKey: string; PlainText: string) : string;
var
   InArray   : TCryptoArray;
   OutArray  : TCryptoArray;
   BlowFish2 : TBlowFish;
begin
   Result := '';
   if PlainText = '' then exit;

   FillChar(InArray, Sizeof(InArray), #0);
   FillChar(OutArray, Sizeof(OutArray), #0);
   StrpCopy(InArray, PlainText);
   BlowFish2 := TBlowFish.Create(Nil);
   try
      with BlowFish2 do begin
         CipherMode    := ECBMode;
         Key           := BFKey;
         InputType     := SourceByteArray;
         InputLength   := Length(PlainText);
         pInputArray   := @InArray;
         pOutputArray  := @OutArray;
         EncipherData(false);
         Result := OutArray;
      end;
   finally
      BlowFish2.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ReadLocalINI;
var
   IniFile : TIniFile;
   TempMRU : Array [1..MAX_MRU] of String;
   i,j     : integer;
   S       : string;
   TempPwd : string;
   CommondocFolder, DocFolder, DocFile, OldFolder, OldFile: string;
begin
   CommonDocFolder := ShellGetFolderPath(CSIDL_APPDATA);
   DocFolder := IncludeTrailingPathDelimiter(CommonDocFolder + 'BankLink\' + ecGlobalConst.APP_NAME);
   DocFile := DocFolder + INIFILENAME;
   OldFolder := ExtractFilePath(Application.ExeName);
   OldFile := OldFolder + INIFILENAME;
   if BKFileExists(OldFile) and (not BKFileExists(DocFile)) then // move it to common folder
   begin
     if not DirectoryExists(DocFolder) then
       ForceDirectories(DocFolder);
     Windows.CopyFile(PChar(OldFile),PChar(DocFile), True);
     DeleteFile(PChar(OldFile));
     ApplicationLog.LogError('Moved INI from ' + OldFile + ' to ' + DocFile);
   end;
   IniFile := TIniFile.Create(DocFile);
   try
      //read form settings from INI
      INI_mfStatus := IniFile.ReadInteger( GrpMainForm, 'Status', 3);
      //default of -1 indicates value not present
      INI_mfTop    := IniFile.ReadInteger( GrpMainForm, 'Top',    -1);
      INI_mfLeft   := IniFile.ReadInteger( GrpMainForm, 'Left',   -1);
      INI_mfWidth  := IniFile.ReadInteger( GrpMainForm, 'Width',  -1);
      INI_mfHeight := IniFile.ReadInteger( GrpMainForm, 'Height', -1);
      INI_mfShowPanel := IniFile.ReadBool( GrpMainForm, 'ShowPanel', True);

      INI_DefaultFileLocation := IniFile.ReadString( GrpUserSettings, 'FileLocation', '');
      INI_LastFileOpened      := IniFile.ReadString( GrpUserSettings, 'LastFile','');
      INI_Theme               := IniFile.ReadString( GrpUserSettings, 'Theme','Default');

      //read MRU List
      for i := 1 to MAX_MRU do begin
        S := IniFile.ReadString(GrpMRUList,'Client'+inttostr(i),'');
        TempMRU[i] := SubStituteL( S, '~', #9 );
        INI_MRUList[i] := ''; //Clear INI List
      end;
      //shuffle valid lines to top
      j := 0;
      for i := 1 to MAX_MRU do
        if TempMRU[i] <> '' then
        begin
           Inc(j);
           INI_MRUList[j] := TempMRU[i];
        end;

      //read mail settings
      INI_MAIL_TYPE := IniFile.ReadInteger( GrpMail, 'MailType', mtMAPI);

      INI_SMTP_FROMADDR   := IniFile.ReadString( GrpMail, 'smtpfromaddr', '');
      INI_SMTP_FROMNAME   := IniFile.ReadString( GrpMail, 'smtpfromname', '');
      INI_SMTP_USERID     := IniFile.ReadString( GrpMail, 'smtpuser',     '');
      INI_SMTP_HOST       := IniFile.ReadString( GrpMail, 'smtpserver',   '');
      INI_SMTP_PWDReqd    := IniFile.ReadBool(   GrpMail, 'smtppwdreqd',  false);
      TempPWD             := IniFile.ReadString( GrpMail, 'smtppassword', '');
      INI_SMTP_PWD        := DecryptPass( PassKey, TempPwd);
      INI_SMTP_PORT       := IniFile.ReadInteger( GrpMail, 'smtpPort', 25);
      INI_SMTP_TIMEOUT    := IniFile.ReadInteger( GrpMail, 'smtpConnectTimeout', 60);
   finally
      IniFile.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure WriteLocalINI;
var
   IniFile : TIniFile;
   i       : integer;
   S       : string;
   TempPwd : string;
   DocFolder: string;
begin
   DocFolder := ShellGetFolderPath(CSIDL_APPDATA) + 'BankLink\' + ecGlobalConst.APP_NAME + '\';
   if not DirectoryExists(DocFolder) then
     ForceDirectories(DocFolder);
   IniFile := TIniFile.Create(DocFolder + INIFILENAME);
   try
     //Save Main Form Window Status
     IniFile.WriteInteger( GrpMainForm, 'Status', INI_mfStatus);
     //save position and size only if the state is normal}
     IniFile.WriteInteger( GrpMainForm, 'Top',    INI_mfTop);
     IniFile.WriteInteger( GrpMainForm, 'Left',   INI_mfLeft);
     IniFile.WriteInteger( GrpMainForm, 'Width',  INI_mfWidth);
     IniFile.WriteInteger( GrpMainForm, 'Height', INI_mfHeight);
     IniFile.WriteBool( GrpMainForm, 'ShowPanel', INI_mfShowPanel);

     IniFile.WriteString( GrpUserSettings, 'FileLocation', INI_DefaultFileLocation);
     IniFile.WriteString( GrpUserSettings, 'LastFile', INI_LastFileOpened);
     IniFile.WriteString( GrpUserSettings, 'Theme', INI_Theme);

     {write MRU List}
     for i := 1 to MAX_MRU do begin
       S := SubStituteL( INI_MRUList[i], #9, '~' );
       IniFile.WriteString(GrpMRUList,'Client'+inttostr(i), S );
     end;

     //save mail settings
     IniFile.WriteInteger( GrpMail, 'MailType', INI_MAIL_TYPE);

     IniFile.WriteString( GrpMail, 'smtpfromaddr', INI_SMTP_FROMADDR);
     IniFile.WriteString( GrpMail, 'smtpfromname', INI_SMTP_FROMNAME);
     IniFile.WriteString( GrpMail, 'smtpuser',     INI_SMTP_USERID);
     IniFile.WriteString( GrpMail, 'smtpserver',   INI_SMTP_HOST);
     IniFile.WriteBool(   GrpMail, 'smtppwdreqd',  INI_SMTP_PWDReqd);
     TempPwd := EncryptPass( PassKey, INI_SMTP_PWD);
     IniFile.WriteString( GrpMail, 'smtppassword', TempPwd);
     IniFile.WriteInteger(GrpMail, 'smtpPort', INI_SMTP_PORT);
     IniFile.WriteInteger(GrpMail, 'smtpConnectTimeout', INI_SMTP_TIMEOUT);
   finally
      IniFile.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
