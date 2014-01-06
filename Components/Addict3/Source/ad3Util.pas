{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10881: ad3Util.pas 
{
{   Rev 1.9    28/07/2005 2:27:54 pm  Glenn
{ Updated version to 3.4.4
}
{
{   Rev 1.8    1/27/2005 2:14:24 AM  mnovak
}
{
{   Rev 1.7    9/14/2004 10:04:00 PM  mnovak
{ Elminate RichEdit Dependency
}
{
{   Rev 1.7    9/14/2004 8:46:52 PM  mnovak
{ Remove RichEdit Dependencies
}
{
{   Rev 1.6    9/11/2004 8:39:22 PM  mnovak
}
{
{   Rev 1.5    8/31/2004 2:43:20 AM  mnovak
{ Improve Control Auto-Detect and Child Window handling for DevExpress support
}
{
{   Rev 1.4    22/02/2004 9:58:46 pm  Glenn
{ Updated version numbers to 3.4.1
}
{
{   Rev 1.3    2/22/2004 12:00:02 AM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.2    12/3/2003 1:03:50 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.1    12/3/2003 12:26:44 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:58 AM  mnovak
}
{
{   Rev 1.3    12/17/2002 9:40:16 AM  mnovak
{ Prep for v 3.3.1 release
}
{
{   Rev 1.2    9/14/2002 6:23:30 PM  mnovak
{ Fixed path expansion problem.
}
{
{   Rev 1.1    7/30/2002 12:07:14 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.0    6/23/2002 11:55:28 PM  mnovak
}
{
{   Rev 1.0    6/17/2002 1:34:20 AM  Supervisor
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

Main dictionary class for reading AddictX dictionaries

History:
7/30/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3Util;

{$I addict3.inc}

interface

uses
    forms,
    sysutils,
    windows,
    classes;

const
    CurrentVersion = '3.4.4';

type
    TEventList = class(TObject)
    protected
        FListeners  :TList;
        FEvents     :TList;
    protected
        function ReadCount:Integer;
        function ReadItems( Index:Integer ):Pointer;
    public
        constructor Create; virtual;
        destructor Destroy; override;

        procedure Add( Sender:TObject; EventHandler:TNotifyEvent );
        procedure Remove( Sender:TObject );
        procedure Notify( Sender:TObject );

        property Count:Integer read ReadCount;
        property Items[ Index:Integer ]:Pointer read ReadItems; default;
    end;

{$IFNDEF Delphi5AndAbove}
    TObjectList = class(TObject)
    protected
        FCount  :Integer;
        FList   :TList;
    protected
        function ReadCount:Integer;
        procedure WriteCount( NewCount:Integer );
        function ReadItems( Index:Integer ):TObject;
        procedure WriteItems( Index:Integer; Item:TObject );
    public
        constructor Create; virtual;
        destructor Destroy; override;

        function Extract( Item:TObject ):TObject;
        procedure Insert( Index:Integer; Item:TObject );
        procedure Clear;
        procedure Add( Item:TObject );
        procedure Delete( Index:Integer );
        procedure Sort( Compare:TListSortCompare );

        property Count:Integer read ReadCount write WriteCount;
        property Items[ Index:Integer ]:TObject read ReadItems write WriteItems; default;
    end;

    TWMContextMenu = packed record
        Msg     :Cardinal;
        hWnd    :HWND;
        Pos     :TSmallPoint;
        Result  :Longint;
    end;
{$ENDIF}

function GetAddictVersion:String;
procedure CheckStandardVersion;
procedure CheckTrialVersion;

procedure AdjustDialogPosition( Dialog:TForm; NewLeft:LongInt; NewTop:LongInt );
procedure AdjustDialogToRect( Dialog:TForm; Position:TRect; AdjustLeft:Boolean; AdjustTop:Boolean );
function IsRichEdit( Window:HWND ):Boolean;

function ReplaceString( Search:String; Replace:String; Original:String ):String;
function ExpandBasicVars( Path:String ):String;
function ExpandChangingVars( Path:String ):String;
function ExpandFixedVars( Path:String ):String;
function GetSpecialFolder( Folder:Integer ):String;

function DWORDAdd( StartAddr:LPDWORD; Increment:DWORD ):LPDWORD;
function BYTEAdd( StartAddr:PByte; Increment:DWORD ):PByte;

function CanFileBeWritten( Filename:String; DeleteOnClose:Boolean ):Boolean;
procedure ADForceDirectories( Dir:String );

function GetNextPrime( Current:DWORD ):DWORD;
function HashString( Word:PChar; TableSize:LongInt ):LongInt;
function SecondaryHash( PrevHash:LongInt ):LongInt;

function GetEditDistance( String1:String; String2:String ):Integer;

function AdExcludeTrailingBackslash( const Path:string ):string;

function GetFileVersion( const Filename:String; var VersionMS:DWORD; var VersionLS:DWORD ):Boolean;

function ADMin( L1:LongInt; L2:LongInt ):LongInt;
function ADMax( L1:LongInt; L2:LongInt ):LongInt;

implementation

uses
    ShlObj,
    Dialogs;

type
  RichEditCHARRANGE = record
    cpMin: Longint;
    cpMax: LongInt;
  end;

var
    FStdMessage     :Boolean;
    FTrialMessage   :Boolean;

//************************************************************

function GetAddictVersion:String;
begin
    Result := CurrentVersion;
    {$IFDEF A3STD}
    Result := Result + ' Std';
    {$ELSE}
    {$IFDEF A3TRIAL}
    Result := Result + ' Trial';
    {$ELSE}
    Result := Result + ' Pro';
    {$ENDIF}
    {$ENDIF}
end;

//************************************************************

procedure CheckStandardVersion;
begin
{$IFDEF A3STD}
    if not(FStdMessage) then
    begin
        FStdMessage := True;

        MessageDlg(     'The Addict RichEdit components are only available in' +#13+#10+
                        'the Professional version of the Addict suite.  See' +#13+#10+
                        'http://www.addictive-software.com for information on' +#13+#10+
                        'upgrading.' +#13+#10+  #13+#10+
                        'The components will work for demonstration purposes' +#13+#10+
                        'but this message will be displayed once per-process.',
                        mtInformation, [mbOK], -1 );
    end;
{$ENDIF}
end;

//************************************************************

procedure CheckTrialVersion;
begin
{$IFDEF A3TRIAL}
    if not(FTrialMessage) then
    begin
        FTrialMessage := True;
        if (FindWindow( 'TAppBuilder', nil ) = 0) then
        begin
            MessageDlg(     'This application was built with a trial-run version of' +#13+#10+
                            'the Addict SpellChecking and Thesaurus components.' +#13+#10+ #13+#10+
                            'Destributing an application based upon this version' +#13+#10+
                            'of Addict is against the licensing agreement.'  +#13+#10 +#13+#10+
                            'Please see http://www.addictive-software.com for more'  +#13+#10+
                            'information on purchasing.',
                            mtInformation, [mbOK], -1 );
        end;
    end;
{$ENDIF}
end;


//************************************************************
// TEventList
//************************************************************

constructor TEventList.Create;
begin
    FListeners  := TList.Create;
    FEvents     := TList.Create;
end;

//************************************************************

destructor TEventList.Destroy;
begin
    while (FListeners.Count > 0) do
    begin
        Remove( FListeners[0] );
    end;
    FListeners.Free;
    FEvents.Free;
    inherited Destroy;
end;

//************************************************************

function TEventList.ReadCount:Integer;
begin
    Result := FListeners.Count;
end;

//************************************************************

function TEventList.ReadItems( Index:Integer ):Pointer;
begin
    Result := FEvents[Index];
end;

//************************************************************

procedure TEventList.Add( Sender:TObject; EventHandler:TNotifyEvent );
var
    pEvent  :Pointer;
begin
    if (FListeners.IndexOf(Sender) = -1) then
    begin
        FListeners.Add( Sender );
        GetMem( pEvent, sizeof(TNotifyEvent) );
        Move( PChar(longint(@@EventHandler))[0], PChar(longint(pEvent))[0], sizeof(TNotifyEvent) );
        FEvents.Add( pEvent );
    end;
end;

//************************************************************

procedure TEventList.Remove( Sender:TObject );
var
    Index   :Integer;
begin
    Index := FListeners.IndexOf(Sender);
    if (Index >= 0) then
    begin
        FListeners.Delete( Index );
        FreeMem(FEvents[Index]);
        FEvents.Delete( Index );
    end;
end;

//************************************************************

procedure TEventList.Notify( Sender:TObject );
var
    Index: Integer;
begin
    for Index := 0 to FEvents.Count - 1 do
    begin
        TNotifyEvent(Pointer(FEvents[Index])^)( Sender );
    end;
end;



{$IFNDEF Delphi5AndAbove}

//************************************************************
// TObjectList
//************************************************************

constructor TObjectList.Create;
begin
    inherited;

    FCount  := 0;
    FList   := TList.Create;
end;

destructor TObjectList.Destroy;
begin
    Clear;

    FList.Free;
    inherited;
end;

function TObjectList.ReadCount:Integer;
begin
    Result := FList.Count;
end;

procedure TObjectList.WriteCount( NewCount:Integer );
begin
    FList.Count := NewCount;
end;

function TObjectList.ReadItems( Index:Integer ):TObject;
begin
    Result := TObject( FList[Index] );
end;

procedure TObjectList.WriteItems( Index:Integer; Item:TObject );
begin
    FList[Index] := Item;
end;

function TObjectList.Extract( Item:TObject ):TObject;
var
    Index   :Integer;
begin
    Result  := nil;
    Index   := FList.IndexOf( Item );
    if (Index >= 0) then
    begin
        Result := TObject(FList[Index]);
        FList.Delete( Index );
    end;
end;

procedure TObjectList.Insert( Index:Integer; Item:TObject );
begin
    FList.Insert( Index, Item );
end;

procedure TObjectList.Clear;
var
    Index   :Integer;
begin
    for Index := 0 to FList.Count - 1 do
    begin
        if (Assigned( FList[Index] )) then
        begin
            TObject(FList[Index]).Free;
        end;
    end;
    FList.Clear;
end;

procedure TObjectList.Add( Item:TObject );
begin
    FList.Add( Item );
end;

procedure TObjectList.Delete( Index:Integer );
begin
    if (Assigned( FList[Index] )) then
    begin
        TObject(FList[Index]).Free;
    end;
    FList.Delete( Index );
end;

procedure TObjectList.Sort( Compare:TListSortCompare );
begin
    FList.Sort( Compare );
end;                      

{$ENDIF}

//************************************************************

procedure AdjustDialogPosition( Dialog:TForm; NewLeft:LongInt; NewTop:LongInt );
begin
    if (Assigned(Dialog)) then
    begin
        if (NewLeft < Dialog.Monitor.Left) then
        begin
            NewLeft := Dialog.Monitor.Left;
        end;
        if (NewTop < Dialog.Monitor.Top) then
        begin
            NewTop := Dialog.Monitor.Top;
        end;
        if ((NewLeft + Dialog.Width) > (Dialog.Monitor.Left + Dialog.Monitor.Width)) then
        begin
            NewLeft := Dialog.Monitor.Left + Dialog.Monitor.Width - Dialog.Width;
        end;
        if ((NewTop + Dialog.Height) > (Dialog.Monitor.Top + Dialog.Monitor.Height)) then
        begin
            NewLeft := Dialog.Monitor.Top + Dialog.Monitor.Height - Dialog.Height;
        end;

        Dialog.SetBounds( NewLeft, NewTop, Dialog.Width, Dialog.Height );
    end;
end;

//************************************************************

procedure AdjustDialogToRect( Dialog:TForm; Position:TRect; AdjustLeft:Boolean; AdjustTop:Boolean );
var
    NewLeft     :LongInt;
    NewTop      :LongInt;
begin
    if (Assigned(Dialog)) then
    begin
        NewLeft := Dialog.Left;
        NewTop  := Dialog.Top;

        if (AdjustLeft) then
        begin
            if ((Position.Left + Dialog.Width) <= (Dialog.Monitor.Left + Dialog.Monitor.Width)) then
            begin
                NewLeft := Position.Left;
            end
            else
            begin
                NewLeft := Dialog.Monitor.Left + Dialog.Monitor.Width - Dialog.Width;
            end;
        end;

        if (AdjustTop) then
        begin
            if ((Position.Bottom + Dialog.Height) <= (Dialog.Monitor.Top + Dialog.Monitor.Height)) then
            begin
                NewTop := Position.Bottom;
            end
            else
            begin
                NewTop := Position.Top - Dialog.Height;
            end;
        end;

        AdjustDialogPosition( Dialog, NewLeft, NewTop );
    end;
end;

//************************************************************

function IsRichEdit( Window:HWND ):Boolean;
var
    Range       :RichEditCHARRANGE;
const
    Windows_WM_USER      = $0400;
    RichEdit_EM_EXGETSEL = Windows_WM_USER + 52;
begin
    // We send a EM_EXGETSEL message to the control to see if it fills out the
    // structure.  We do this as only the RichEdit control supports this
    // message, so it should allow us to differentiate between and edit and
    // a RichEdit control.

    Range.cpMin := -2;
    Range.cpMax := -2;

    SendMessage( Window, RichEdit_EM_EXGETSEL, 0, LPARAM(@Range) );

    Result := ((Range.cpMin <> -2) or (Range.cpMax <> -2));
end;

//************************************************************

function ReplaceString( Search:String; Replace:String; Original:String ):String;
var
    Index   :LongInt;
begin
    Result  := Original;
    Index   := Pos( Search, Result );
    if (Index > 0) then
    begin
        delete( Result, Index, Length(Search) );
        insert( Replace, Result, Index );
    end;
end;

//************************************************************

function ExpandBasicVars( Path:String ):String;
begin
    Result := ExpandFixedVars( Path );
    Result := ExpandChangingVars( Result );
end;

//***************************************************************************

function ExpandChangingVars( Path:String ):String;
var
    ExpandedString  :Array[0..4095] of char;
    AppDir          :String;
begin
    Result := Path;
    Result := ReplaceString( '%AppDir%', AdExcludeTrailingBackslash( ExtractFilePath(Application.ExeName) ), Result );
    if (Pos( '%AppData%', Path ) > 0) then
    begin
        AppDir := AdExcludeTrailingBackslash( GetSpecialFolder( CSIDL_APPDATA ) );
        if (AppDir = '') then
        begin
            AdExcludeTrailingBackslash( ExtractFilePath(Application.ExeName) )
        end;
        Result := ReplaceString( '%AppData%', AppDir, Result );
    end;
    if (Pos( '%MyDocuments%', Path ) > 0) then
    begin
        Result := ReplaceString( '%MyDocuments%', GetSpecialFolder( CSIDL_PERSONAL ), Result );
    end;

    // ExpandEnvironmentStrings gets us:
    //  %SystemRoot%
    //  %WinDir%
    //  %ProgramFiles%
    //  %Temp%
    //  %UserProfile%

    if (ExpandEnvironmentStrings( PChar(Result), ExpandedString, sizeof(ExpandedString) ) > 0) then
    begin
        Result := ExpandedString;
    end;
end;

//***************************************************************************

function ExpandFixedVars( Path:String ):String;
var
    UserName        :Array[0..255] of char;
    Size            :Cardinal;
begin
    Result := Path;
    Result := ReplaceString( '%AppName%', ChangeFileExt( ExtractFileName(Application.ExeName), '' ), Result );
    if (Pos( '%UserName%', Path ) > 0) then
    begin
        UserName[0] := #0;
        Size        := sizeof(UserName);
        if (GetUserName( UserName, size )) and (UserName[0] <> #0) then
        begin
            Result := ReplaceString( '%UserName%', UserName, Result );
        end
        else
        begin
            Result := ReplaceString( '%UserName%', 'default', Result );
        end;
    end;
end;

//***************************************************************************

function GetSpecialFolder( Folder:Integer ):String;
var
    Path                    :Array[0..MAX_PATH] of Char;
    _SHGetSpecialFolderPath :procedure( hwndOwner:HWND; lpszPath:PChar; nFolder:Integer; fCreate:BOOL ); stdcall;
    HShell32                :HMODULE;
begin
    Result  := '';
    Path[0] := #0;

    {$IFDEF Delphi5AndAbove}
    HShell32 := SafeLoadLibrary( 'shell32.dll' );
    {$ELSE}
    HShell32 := LoadLibrary( 'shell32.dll' );
    {$ENDIF}
    if (HShell32 <> 0) then
    begin
        @_SHGetSpecialFolderPath := GetProcAddress( HShell32, 'SHGetSpecialFolderPathA' );
        if (@_SHGetSpecialFolderPath = nil) then
        begin
            @_SHGetSpecialFolderPath := GetProcAddress( HShell32, 'SHGetSpecialFolderPath' );
        end;

        if (Assigned(_SHGetSpecialFolderPath)) then
        begin
            _SHGetSpecialFolderPath( 0, Path, Folder, False );
        end;

        FreeLibrary( HShell32 );
    end;

    if (Path[0] <> #0) then
    begin
        Result := AdExcludeTrailingBackslash( Path );
    end;
end;

//***************************************************************************

function DWORDAdd( StartAddr:LPDWORD; Increment:DWORD ):LPDWORD;
begin
    Result := LPDWORD(Ptr( DWORD(StartAddr) + (Increment * 4) ));
end;

//***************************************************************************

function BYTEAdd( StartAddr:PByte; Increment:DWORD ):PByte;
begin
    Result := PByte(Ptr( DWORD(StartAddr) + Increment ));
end;

//***************************************************************************

function CanFileBeWritten( Filename:String; DeleteOnClose:Boolean ):Boolean;
var
    FileHandle      :THandle;
    Flags           :DWORD;
begin
    Flags := FILE_ATTRIBUTE_NORMAL;
    if (DeleteOnClose) then
    begin
        Flags := Flags or FILE_FLAG_DELETE_ON_CLOSE;
    end;
    FileHandle  := CreateFile( PChar(Filename), GENERIC_WRITE, 0, nil, OPEN_ALWAYS, Flags, 0 );
    if (INVALID_HANDLE_VALUE = FileHandle) then
    begin
        Result := False;
        exit;
    end;
    CloseHandle( FileHandle );
    Result := True;
end;

//***************************************************************************

procedure ADForceDirectories( Dir:String );
var
    Attrib  :DWORD;
    Exists  :Boolean;
begin
    Attrib  := GetFileAttributes( PChar(Dir) );
    Exists  := ($FFFFFFFF <> Attrib) and ((Attrib and FILE_ATTRIBUTE_DIRECTORY) <> 0);

    if (not Exists) then
    begin
        Dir := AdExcludeTrailingBackslash(Dir);
        if  (Length(Dir) > 2) and                   // room for drive letter
            (pos('\', Dir) <> 0) and                // has a slash
            not(ExtractFilePath(Dir) = Dir) then    // has another dir
        begin
            ADForceDirectories( ExtractFilePath(Dir) );
        end;
        CreateDir( Dir );
    end;
end;

//***************************************************************************

function GetNextPrime( Current:DWORD ):DWORD;
var
    Primes  :Array[0..23] of DWORD;
    Index   :Integer;
begin
    Primes[0]   := 251;
    Primes[1]   := 509;
    Primes[2]   := 1021;
    Primes[3]   := 2039;
    Primes[4]   := 4093;
    Primes[5]   := 8191;
    Primes[6]   := 16381;
    Primes[7]   := 32749;
    Primes[8]   := 65521;
    Primes[9]   := 131071;
    Primes[10]  := 262139;
    Primes[11]  := 524287;
    Primes[12]  := 1048573;
    Primes[13]  := 2097143;
    Primes[14]  := 4194301;
    Primes[15]  := 8388593;
    Primes[16]  := 16777213;
    Primes[17]  := 33554393;
    Primes[18]  := 67108859;
    Primes[19]  := 134217689;
    Primes[20]  := 268435399;
    Primes[21]  := 536870909;
    Primes[22]  := 1073741789;
    Primes[23]  := 2147483647;

    Result  := Primes[0];
    Index   := 0;
    while (Current >= Primes[Index]) do
    begin
        inc(Index);
        Result := Primes[Index];
    end;
end;

//***************************************************************************
// This hash function is written from the example given in Robert Sedgewick's
// "Algorithms in C - third edition".  Page 579, Porgram 14.2.

function HashString( Word:PChar; TableSize:LongInt ):LongInt;
var
    A   :LongInt;
    B   :LongInt;
begin
    A       := 31415;
    B       := 27183;
    Result  := 0;

    while (Word[0] <> #0) do
    begin
        Result  := (A * Result + Ord(Word[0])) mod TableSize;
        if (Result < 0) then
        begin
            Result := (-Result) mod TableSize;
        end;
        Word    := PChar(BYTEAdd(PByte(Word), 1));
        A       := A * B mod (TableSize - 1);
    end;
end;

//***************************************************************************
// Also from Sedgewick - page 595.
// This fucntion is for a secondary hash for the double hashing approach.
// IMPORTANT:  Your table must be allocated above 98 entries or this will not
//             work!!!!!!

function SecondaryHash( PrevHash:LongInt ):LongInt;
begin
    Result := (PrevHash mod 97) + 1;
end;



//************************************************************
// Basic Levenshtein "edit distance" algorithm
//************************************************************

function GetEditDistance( String1:String; String2:String ):Integer;
const
    MaxWordLen  = 255;
var
    Matrix  :Array[0..MaxWordLen, 0..MaxWordLen] of BYTE;
    I       :Integer;
    J       :Integer;
    Temp    :Integer;
begin
    if ((Length(String1) >= MaxWordLen) or (Length(String2) >= MaxWordLen)) then
    begin
        Result := ADMax( Length(String1), Length(String2) );
    end
    else
    begin
        for I := 0 to Length(String1) do
        begin
            Matrix[I][0] := I;
        end;
        for J := 0 to Length(String2) do
        begin
            Matrix[0][J] := J;
        end;

        for I := 1 to Length(String1) do
        begin
            for J := 1 to Length(String2) do
            begin
                if (String1[I] = String2[J]) then
                begin
                    Matrix[I][J] := Matrix[I - 1][J - 1];
                end
                else
                begin
                    Temp            := ADMin( Matrix[I-1][J] + 1, Matrix[I][J-1] + 1 );
                    Matrix[I][J]    := ADMin( Temp, Matrix[I-1][J-1] + 1 );
                end;
            end;
        end;

        Result := Matrix[ Length(String1) ][ Length(String2) ];

        // We want to lower the cost of a simple transposition to 1,
        // instead of 2 as the algorithm does... so:

        I := 2;
        J := ADMin( Length(String1), Length(String2) );

        while (I <= J) do
        begin
            if  (String1[I] = String2[I-1]) and
                (String1[I-1] = String2[I]) and
                (String1[I] <> String1[I-1]) and
                (Result > 0) then
            begin
                DEC( Result );
                INC( I );
            end;
            INC( I );
        end;
    end;
end;

//************************************************************

function AdExcludeTrailingBackslash( const Path:string ):string;
begin
{$IFNDEF Delphi5AndAbove}
    Result := Path;
    if (IsPathDelimiter( Path, Length(Path) )) then
    begin
        Result := copy( Path, 1, Length(Path) - 1 );
    end
    else
    begin
        Result := Path;
    end;
{$ENDIF}
{$IFDEF UsingDelphi5}
    Result := ExcludeTrailingBackslash( Path );
{$ENDIF}
{$IFDEF Delphi6AndAbove}
    Result := ExcludeTrailingPathDelimiter( Path );
{$ENDIF}
end;

//************************************************************

function GetFileVersion( const Filename:String; var VersionMS:DWORD; var VersionLS:DWORD ):Boolean;
var
    UselessArg  :DWORD;
    VersionSize :DWORD;
    VerPtr      :Pointer;
    TempPtr     :Pointer;
    InfoPtr     :^VS_FIXEDFILEINFO;
    InfoSize    :Cardinal;
begin
    Result      := False;

    VersionSize := GetFileVersionInfoSize( PChar(Filename), UselessArg );

    if (VersionSize = 0) then
    begin
        Exit;
    end;

    VerPtr := nil;
    ReallocMem( VerPtr, VersionSize );
    try
        if (not GetFileVersionInfo( PChar(Filename), 0, VersionSize, VerPtr )) then
        begin
            Exit;
        end;

        TempPtr     := nil;
        InfoSize    := 0;

        if (not VerQueryValue( VerPtr, '\', TempPtr, InfoSize )) then
        begin
            Exit;
        end;

        InfoPtr := TempPtr;

        if (0 = InfoSize) then
        begin
            Exit;
        end;

        VersionMS   := InfoPtr.dwFileVersionMS;
        VersionLS   := InfoPtr.dwFileVersionLS;

        Result      := True;

    finally
        FreeMem( VerPtr );
    end;
end;

function ADMin( L1:LongInt; L2:LongInt ):LongInt;
begin
    if (L1 < L2) then
    begin
        Result := L1;
    end
    else
    begin
        Result := L2;
    end;
end;

function ADMax( L1:LongInt; L2:LongInt ):LongInt;
begin
    if (L1 > L2) then
    begin
        Result := L1;
    end
    else
    begin
        Result := L2;
    end;
end;


{$HINTS OFF}
initialization
    FStdMessage     := False;
    FTrialMessage   := False;
{$HINTS ON}
end.

