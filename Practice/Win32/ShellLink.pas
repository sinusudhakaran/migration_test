unit ShellLink;
// Component to create/modify Desktop Shortcuts
// Refer to Delphi Magazine Issue 19 
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TShellLink = class(TComponent)
  private
    { Private declarations }
    fTargetPath: String;
    fLinkPath: String;
    fDescription: String;
    fArguments: String;
    fWorkingDirectory: String;
    fWindowState: TWindowState;
    procedure SetLinkPath (const Val: String);
    procedure Resolve (const FullLinkPath: String);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    function Save: Boolean;
   published
    { Published declarations }
    property WindowState: TWindowState read fWindowState write fWindowState default wsNormal;
    property TargetPath: String read fTargetPath write fTargetPath;
    property LinkPath: String read fLinkPath write SetLinkPath;
    property Description: String read fDescription write fDescription;
    property Arguments: String read fArguments write fArguments;
    property WorkingDirectory: String read fWorkingDirectory write fWorkingDirectory;
  end;

procedure Register;

implementation

uses
   Ole2,  //
   ShellObj,
   ShellAPI,
   WinUtils;

//----------------------------------------------------------------------
//  Name:    GetIShellLink
//  Purpose: Create an instance of the IShellLink interface
//----------------------------------------------------------------------

function GetIShellLink: IShellLink;
begin
    if CoCreateInstance (CLSID_ShellLink, Nil, 1, IID_IShellLink, Result) <> S_OK then
        Exception.Create ('Can''t get a shell link');
end;

//----------------------------------------------------------------------
//  Name:    GetIPersistFile
//  Purpose: Given an IShellLink, get the IPersistFile interface.
//----------------------------------------------------------------------

function GetIPersistFile (link: IShellLink): IPersistFile;
begin
    if link.QueryInterface (IID_IPersistFile, Result) <> S_OK then
        Exception.Create ('Can''t get a persistent file');
end;

//----------------------------------------------------------------------
//  Name:    GetDeskTopFolder
//  Purpose: Return location of Explorer's "live" desktop data
//  Notes:   Yes, we could use SHGetDesktopFolder, but this is simpler.
//----------------------------------------------------------------------

function GetDeskTopFolder: String;
const
    ShellFolders = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders';
var
    Key: hKey;
    bytes: DWord;
    szDest: array [0..Max_Path - 1] of Char;
begin
    Result := '';
    if RegOpenKeyEx (HKey_Current_User, ShellFolders, 0, Key_Read, Key) = 0 then
    try
        bytes := sizeof (szDest);
        if RegQueryValueEx (Key, 'Desktop', Nil, Nil, @szDest, @bytes) = 0 then
        begin
            Result := szDest;
            Result := Result + '\';
        end;
    finally
        RegCloseKey (Key);
    end;
end;

//----------------------------------------------------------------------
//  Name:    FixUpLinkPath
//  Purpose: Convert user-supplied link path into a fully qualified path.
//----------------------------------------------------------------------

function FixUpLinkPath (const LinkPath: String): String;
begin
    Result := LinkPath;
    if Pos ('.lnk', LowerCase (Result)) = 0 then Result := Result + '.lnk';
    { Is this a fully-qualified pathname ? }
    if ExtractFileDrive (Result) = '' then
    begin
        if Result[1] = '\' then Result := Copy (Result, 2, 255);
        Result := GetDeskTopFolder + Result;
    end;
end;

{ TShellLink }

constructor TShellLink.Create (AOwner: TComponent);
begin
    Inherited Create (AOwner);
    CoInitialize (Nil);
    WindowState := wsNormal;
end;

destructor TShellLink.Destroy;
begin
    CoUninitialize;
    Inherited Destroy;
end;

procedure TShellLink.SetLinkPath (const Val: String);
begin
    if fLinkPath <> Val then
    begin
        fLinkPath := Val;
        Resolve (FixUpLinkPath (fLinkPath));
    end;
end;

procedure TShellLink.Resolve (const FullLinkPath: String);
var
    swCmd: Integer;
    link: IShellLink;
    persist: IPersistFile;
    FindData: TWin32FindData;
    buff: array [0..511] of Char;
    wLinkPath: array [0..Max_Path-1] of WideChar;
begin
    { Make sure the link file exists }
    if BKFileExists (FullLinkPath) then
    begin
        { Pathname must be in WideChar format }
        MultiByteToWideChar (cp_ACP, 0, PChar (FullLinkPath), -1, wLinkPath, Max_Path);
        { Get a pointer to the wanted interface }
        link := GetIShellLink;
        try
            // First, make sure we can get IPersistentFile
            persist := GetIPersistFile (link);
            try
                // Load the persistent object
                if persist.Load (wLinkPath, stgm_Read) = S_OK then
                begin
                    link.GetPath (buff, sizeof (buff), FindData, slgp_ShortPath);
                    TargetPath := buff;
                    link.GetDescription (buff, sizeof (buff));
                    Description := buff;
                    link.GetArguments (buff, sizeof (buff));
                    Arguments := buff;
                    link.GetWorkingDirectory (buff, sizeof (buff));
                    WorkingDirectory := buff;
                    link.GetShowCmd (swCmd);
                    case swCmd of
                        sw_Minimize, sw_ShowMinimized:
                            fWindowState := wsMinimized;
                        sw_ShowMaximized:
                            fWindowState := wsMaximized;
                        else
                            fWindowState := wsNormal;
                    end;
                end;
            finally
                persist.Release;
            end;
        finally
            link.Release;
        end;
    end;
end;

function TShellLink.Save: Boolean;
var
    link: IShellLink;
    persist: IPersistFile;
    wLinkPath: array [0..Max_Path-1] of WideChar;
begin
    //result := false;
    { LinkPath must be in WideChar format }
    MultiByteToWideChar (cp_ACP, 0, PChar (FixupLinkPath (LinkPath)), -1, wLinkPath, Max_Path);
    { Get a pointer to the wanted interface }
    link := GetIShellLink;
    try
        // First, make sure we can get IPersistentFile
        persist := GetIPersistFile (link);
        try
            // Set target and description strings
            link.SetPath (PChar (UpperCase (TargetPath)));
            link.SetDescription (PChar (Description));
            link.SetArguments (PChar (Arguments));
            link.SetWorkingDirectory (PChar (WorkingDirectory));
            case WindowState of
                wsMinimized:  link.SetShowCmd (sw_ShowMinimized);
                wsMaximized:  link.SetShowCmd (sw_ShowMaximized);
                wsNormal:     link.SetShowCmd (sw_ShowNormal);
            end;
            persist.Save (wLinkPath, True);
            Result := True;
        finally
            persist.Release;
        end;
    finally
        link.Release;
    end;
end;

procedure Register;
begin
  RegisterComponents ('Shell Tools', [TShellLink]);
end;

end.
