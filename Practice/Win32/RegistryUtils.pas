unit RegistryUtils;

interface

uses
  Classes;

procedure StoreCurrentExePath( path : string);
function GetExePaths( Paths : TStringList) : boolean;
function UpdateExePaths( Paths : TStringList) : boolean;
function GetCurrentExePath : string;
function BKHandlerInstalled : boolean;
function TRFHandlerInstalled : boolean;
function BNotesInstalled : boolean;
function GetPrivateProfileText(aIniFile, aApp, aKey: string; aDefault: string = ''): string;
procedure WritePrivateProfileText(aIniFile, aApp, aKey, aValue: string);
function PrivateProfileTextToBoolean(aValue : string) : boolean;

Type
  Tassociation = (AS_None, AS_BKHandler, AS_BNotes, AS_TRFHandler);

Function GetBK5Association : Tassociation;
Function GetTRFAssociation : Tassociation;

function SetTRFAssociation (value : Tassociation) : Boolean;
function CanOpenEditClassesKey( keyname : string) : boolean;

Const
  regStr_trfFile  = '.trf';
  regStr_BK5File  = '.bk5';

implementation

uses
  SysUtils,
  Registry,
  Windows,
  WinUtils;

const
  regKey_BK5Software = '\Software\Banklink';
  regKey_TRFVista = '\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.trf\UserChoice';
  regStr_PathPrefix  = 'path';
  regStr_CurrentPath = 'currentpath';

  regstr_BK5File_Handler = 'BankLink.bkHandlr';
  regstr_BNNotes_Handler = 'BankLinkBNotesfile';
  regstr_TrfFile_Handler = 'BankLink.trfFile';

  regStr_VistaBNotes = 'Applications\BNOTES.EXE';
  regStr_VistaHandlr = 'Applications\BKHandlr.EXE';
  

function GetAssociation ( FileExtn : string) : string;
//checks to see what the default association is for the specified file extn
var
  RegObj : TRegistry;
begin
  result := '';
  if FileExtn = '' then
    exit;

  RegObj := TRegistry.Create;
  try
     if (Pos('Vista', WinUtils.GetWinVer) > 0) then
     begin
       RegObj.RootKey := HKEY_CURRENT_USER;
       RegObj.OpenKeyReadOnly(regKey_TRFVista);
       if RegObj.ValueExists('Progid') then
       begin
         if RegObj.ReadString('Progid') = regStr_VistaBNotes then
           Result := regstr_BNNotes_Handler
         else
           Result := regstr_TrfFile_Handler;
       end
       else
         Result := regstr_TrfFile_Handler;
     end
     else
     begin
       Regobj.RootKey := HKEY_CLASSES_ROOT;
       RegObj.OpenKeyReadOnly( FileExtn);
       //read default value
       Result := RegObj.ReadString('');
     end;
  finally
    RegObj.Free;
  end;
end;

//Local
function TestAssociation (const value: string): Tassociation;
begin
   result := AS_None;
   if value <> '' then
   begin
     if sametext(value, regstr_BK5File_Handler) then
        result := AS_BKHandler
     else if Sametext(Value,regstr_BNNotes_Handler) then
        result := AS_BNotes
     else if Sametext(Value,regstr_TrfFile_Handler) then
        result := AS_TRFHandler;
   end;
end;

function CanOpenEditClassesKey( keyname : string) : boolean;
//returns true if we can open the key in read write mode
var
  RegObj : TRegistry;
begin
  result := false;
  if keyname <> '' then
  begin
    RegObj := TRegistry.Create;
    try
      RegObj.RootKey := HKEY_CLASSES_ROOT;
      RegObj.Access  := KEY_WRITE;
      result := RegObj.OpenKey( keyname, false);
    finally
      RegObj.Free;
    end;
  end;
end;


function GetBK5Association : Tassociation;
begin
   result := TestAssociation(GetAssociation(regStr_bk5File));
end;

function GetTRFAssociation : Tassociation;
begin
   result := TestAssociation(GetAssociation(regStr_TRFFile));
end;

function SetTRFAssociation (value : Tassociation) : Boolean;
   procedure setTo (Value : string);
   var RegObj : TRegistry;
   begin
      RegObj := TRegistry.Create;
      try try
         if (Pos('Vista', WinUtils.GetWinVer) > 0) then
         begin
           RegObj.RootKey := HKEY_CURRENT_USER;
           RegObj.OpenKey(regKey_TRFVista, True);
           if value = regstr_BNNotes_Handler then
             RegObj.WriteString('Progid' ,regStr_VistaBNotes)
           else
             RegObj.WriteString('Progid' ,regStr_VistaHandlr)
         end
         else
         begin
           RegObj.RootKey := HKEY_CLASSES_ROOT;
           RegObj.Openkey(regStr_trfFile,true);
           RegObj.WriteString('',Value);
         end;
         result := true;
      except
      end
      finally
         RegObj.Free;
      end;
   end;

begin
   Result := False;
   case Value of
   AS_None :SetTo(''); //Do we realy want to turn off..
   AS_BKHandler  : if BKHandlerInstalled then
                     SetTo(regstr_TRFFile_Handler)
                  else
                     Result := true;

   AS_TRFHandler : if BKHandlerInstalled then
                     SetTo(regstr_TRFFile_Handler)
                  else
                     Result := true;

   AS_BNotes : if BNotesInstalled then
                   SetTo(regstr_BNNotes_Handler);
               else
                   Result := true;
   end;
end;



function TRFHandlerInstalled : boolean;
//look for the file associations for bk5
var
  RegObj : TRegistry;
begin
  RegObj := TRegistry.Create;
  try
    RegObj.RootKey := HKEY_CLASSES_ROOT;
    result := RegObj.KeyExists(regstr_TrfFile_Handler);
  finally
    RegObj.Free;
  end;
end;

function BKHandlerInstalled : boolean;
//look for the file associations for bk5
var
  RegObj : TRegistry;
begin
  RegObj := TRegistry.Create;
  try
    RegObj.RootKey := HKEY_CLASSES_ROOT;
    result := RegObj.KeyExists(regstr_BK5File_Handler);
  finally
    RegObj.Free;
  end;
end;


function BNotesInstalled : boolean;
//look for the file associations for BNotes
var
  RegObj : TRegistry;
begin
  RegObj := TRegistry.Create;
  try
    RegObj.RootKey := HKEY_CLASSES_ROOT;
    result := RegObj.KeyExists(regstr_BNNotes_Handler);
  finally
    RegObj.Free;
  end;
end;



procedure StoreCurrentExePath( path : string);
//stores the current path in the registry, check first to see if it is already
//there
//
//parameters:
//            path : path of bk5win.exe file and data
var
  ExistingPaths : TStringList;
  RegObj : TRegistry;
begin
  //get list of paths
  ExistingPaths := TStringList.Create;
  try
    GetExePaths( ExistingPaths);

    if ExistingPaths.IndexOf( Path) = -1 then
    begin
      //path does not appear in list so add it
      RegObj := TRegistry.Create;
      try
        RegObj.RootKey := HKEY_CURRENT_USER;
        if RegObj.OpenKey( regKey_BK5Software, True) then
        begin
          RegObj.WriteString( regStr_PathPrefix + IntToStr( ExistingPaths.Count + 1), Path);
          RegObj.CloseKey;
        end
      finally
        RegObj.Free;
      end;
    end;

    //now write in current dir
    RegObj := TRegistry.Create;
    try
      RegObj.RootKey := HKEY_CURRENT_USER;
      if RegObj.OpenKey( regKey_BK5Software, True) then
      begin
        RegObj.WriteString( regStr_CurrentPath, Path);
        RegObj.CloseKey;
      end
    finally
      RegObj.Free;
    end;
  finally
    ExistingPaths.Free;
  end;
end;

function GetCurrentExePath : string;
var
  RegObj : TRegistry;
begin
  //now write in current dir
  RegObj := TRegistry.Create;
  try
    RegObj.RootKey := HKEY_CURRENT_USER;
    if RegObj.OpenKeyReadOnly( regKey_BK5Software) then
    begin
      result := RegObj.ReadString( regStr_CurrentPath);
      RegObj.CloseKey;
    end
  finally
    RegObj.Free;
  end;
end;

function GetExePaths( Paths : TStringList) : boolean;
//load a list of paths that describe where bk5 is installed
//parameters:
//           paths: A valid TStringList structure, will be filled by function
//           result : true if a structure was loaded.
var
  RegObj : TRegistry;
  PathValue : string;
  i : integer;
begin
  Assert( Assigned( Paths));
  //open reg key
  //look for list of keys  path_1 .. path_n
  RegObj := TRegistry.Create;
  try
     RegObj.RootKey := HKEY_CURRENT_USER;
     if RegObj.OpenKeyReadOnly( regKey_BK5Software) then
     begin
       //read current list, see if current path is there
       //load all path1..pathn keys
       i := 1;
       repeat
         PathValue := RegObj.ReadString( regStr_PathPrefix + IntToStr( i));
         if PathValue <> '' then
         begin
           Paths.Add( PathValue);
           i := i + 1;
         end;
       until PathValue = '';
       RegObj.CloseKey;
     end;
     result := Paths.Text <> '';
  finally
    RegObj.Free;
  end;
end;

function UpdateExePaths( Paths : TStringList) : boolean;
//provides the ability to update the list of exe paths, allowing the existing
//list to be completely rewritten
begin
  result := false;
end;

function GetPrivateProfileText(aIniFile, aApp, aKey: string; aDefault: string = ''): string;
var
  Lbuf: array[0..200] of char;
begin
  GetPrivateProfilestring(pchar(aApp), Pchar(aKey), PChar(aDefault), lbuf, sizeof(lbuf), PChar(aIniFile));
  Result := string(lbuf);
end;

procedure WritePrivateProfileText(aIniFile, aApp, aKey, aValue: string);
begin
  if aValue = '' then
    WritePrivateProfileString(PChar(aApp), PChar(aKey), nil, PChar(aIniFile))
  else
    WritePrivateProfileString(PChar(aApp), PChar(aKey), pChar(aValue), PChar(aIniFile));
end;

function PrivateProfileTextToBoolean(aValue : string) : boolean;
begin
  if Sametext(aValue, '1') or Sametext(aValue, 'true') then
    Result := true
  else
    Result := false;
end;

end.
