library ParseBNotes;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

{$DEFINE ParserDll}
{$R *.res}
uses
  SysUtils,
  Windows,
  Classes,
  FileWrapper,
  upgConstants,
  SHFolder,
  ecobj;

/// Copied from WinUtils
function GetWinDir: String;
begin
  SetLength(Result, MAX_PATH);
  GetWindowsDirectory(PChar(Result), MAX_PATH);
  SetLength(Result, StrLen(PChar(Result)));
  Result := IncludeTrailingPathDelimiter(Result);
end;

function ShellGetFolderPath(CSIDL: Integer): string;
var
  Buffer: array[0..MAX_PATH] of Char;
begin
  FillChar(Buffer, MAX_PATH, 0);
  if SHGetFolderPath(0, CSIDL, 0, 0, Buffer) = S_OK then // pre-win2k
    Result := IncludeTrailingPathDelimiter(Buffer)
  else
    Result := GetWinDir;
end;
/////

const
   GrpUserSettings   = 'Enviroment';
   GrpMRUList        = 'MRUList';


function ParserApp
             (CallingApp: PChar;
              aHandle: THandle;
              ApplicationID: longInt;
              ReplyBuffer: PChar;
              ReplyBufferSize: longInt;
              out ReplySize: LongInt) : LongInt; stdcall;

var
   ClientCode,
   PracticeCode,
   PracticeName,
   ReplyString : string;

   procedure BuildReply;
   var P: Integer;
   begin
      ReplyString := '';
      Result := 0;
      if PracticeCode > '' then begin
         Result := Result + Pa_PracticeCode;
         ReplyString := eiPracticeCode + '=' + PracticeCode;
      end;
      if PracticeName > '' then begin
         Result := Result + Pa_PracticeName;
         repeat
            P := Pos(',',PracticeName);
            if P > 0 then
               PracticeName[P] := '_';
         until P = 0;
         if ReplyString > '' then
            ReplyString := ReplyString + ',';
         ReplyString := ReplyString + eiPracticeName + '=' + PracticeName;
      end;
      if ClientCode > '' then begin
         Result := Result + Pa_ClientCode;
         if ReplyString > '' then
            ReplyString := ReplyString + ',';
         ReplyString := ReplyString + eiClientCode + '=' + ClientCode;
      end;
   end;


   function CheckFile(AFileName: string): boolean;
   var Ec: TEcClient;
       aWrapper : TWrapper;
   begin
      Result := False;
      if AFilename = '' then
         Exit;
      if fileExists(AFilename) then try

         Ec:= TEcClient.Create;
         try
            Ec.LoadFromFile(AFilename,0);
            ClientCode := EC.ecFields.ecCode;
            PracticeName := ec.ecFields.ecPractice_Name;
            if ec.ecFields.ecFile_Version >= 7 then 
               PracticeCode := ec.ecFields.ecPractice_Code;
            BuildReply;
            Result := True;
         finally
            ec.Free;
         end;
      except
         on E: Exception do
            ReplyString := E.Message;
      end;
   end;

   procedure GetClientDetails;
   var lt,bp: PChar;
       FileName: string;
       IniFile: string;
       I: Integer;
   const ls = 350;  // We should have atleast the code...
   begin

      //WritePrivateProfileString('BNotes','Check','Param','debug.ini');
      if ParamCount >= 1 then
         if CheckFile(ParamStr(1)) then
            Exit; // Parameter OK..
      FileName := '';
      if AHandle <> 0 then begin
         GetMem(lt,ls);
         try
         try
            GetWindowText(aHandle,lt,pred(ls));
            strLower(lt);
            bp := strPos(lt,'.trf'); // The separator beteen Code and Name
            if bp <> nil then begin
               (bp + 4)^ := #0;
               Filename := string(lt);
               // Have a file name, but where is the file..

               if CheckFile(ExtractFilePath(ParamStr(0)) + FileName) then
                  Exit; // Found File In EXE dir

               GetDir (0,IniFile);
               if CheckFile(IncludeTrailingBackslash(IniFile)+ FileName) then
                  Exit;// Found File in Current Dir
            end else
               ReplyString := 'No Client file open';
         except
            on E: Exception do
               ReplyString := E.Message;
         end;
         finally
            FreeMem(lt,ls);
         end;
      end;
      // Try the ini file
      IniFile := ShellGetFolderPath(CSIDL_APPDATA) + 'BankLink\Banklink Notes\BNotes.Ini';

      //WritePrivateProfileString('BNotes','IniFile',PChar(IniFile),'debug.ini');

      if not FileExists(IniFile) then
         IniFile := ExtractFilePath(ParamStr(0)) + 'BNotes.ini';

      //WritePrivateProfileString('BNotes','IniFile2',PChar(IniFile),'debug.ini');   
      if not FileExists(IniFile) then begin
         ReplyString := 'No Ini file found';
         Exit;
      end;
      GetMem(lt,ls);
      try try
         //WritePrivateProfileString('BNotes','Check','LastFile','debug.ini');
         if FileName > '' then begin
            GetPrivateProfileString(GrpUserSettings,'FileLocation','',lt,ls,PChar(IniFile));
            if CheckFile(string(lt)+ Filename) then
               Exit; // Last Location OK..
         end;

         GetPrivateProfileString(GrpUserSettings,'LastFile','',lt,ls,PChar(IniFile));
         if CheckFile(string(lt)) then
             Exit; // Last File OK..

         //WritePrivateProfileString('BNotes','Check','LastList','debug.ini');
         for I := 1 to 9 do begin
            GetPrivateProfileString(GrpMRUList,PChar('Client'+inttostr(i)) ,'',lt,ls,PChar(IniFile));
            Bp := StrPos(lt,'~');
            if BP <> nil then
               BP^ := #0;
            if CheckFile(string(lt)) then
                Exit; // MRU File OK..
         end;

         ReplyString := 'No Client files found';

      except
         on E: Exception do
               ReplyString := E.Message;
      end;
      finally
         FreeMem(lt,ls);
      end;
   end;



begin
   Result := Pa_DllFailed;
   ReplySize := 0;
   ClientCode := '';
   PracticeCode := '';
   PracticeName := '';
   ReplyString := '';
   case ApplicationID of
     aidBNotes : GetClientDetails;

     else ReplyString := 'Wrong Appicaltion ID';
   end;

   // Return the Reply
   ReplySize := Length(ReplyString);
   StrCopy(ReplyBuffer,pchar(ReplyString));
end;

exports
   ParserApp;

begin
end.
