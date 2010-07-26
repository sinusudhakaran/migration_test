{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10819: ad3Configuration.pas 
{
{   Rev 1.4    1/27/2005 2:14:16 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:02 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:34 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:22 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:34 AM  mnovak
}
{
{   Rev 1.2    7/30/2002 12:07:10 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.1    7/29/2002 11:24:48 PM  mnovak
{ Fixed exception handling for read-only INI files.
}
{
{   Rev 1.0    6/23/2002 11:55:26 PM  mnovak
}
{
{   Rev 1.0    6/17/2002 1:34:18 AM  Supervisor
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

AddictSpell3 Configuration Object

History:
7/28/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release
3/11/01     - Michael Novak     - Fix 'locate' bug missing dict update

**************************************************************)

unit ad3Configuration;

{$I addict3.inc}

interface

uses
    classes,
    inifiles,
    registry,
    sysutils;

type

    TSpellOption = (
                        soLiveSpelling,                         // live spelling on
                        soLiveCorrect,                          // live correct on
                        soUpcase,                               // ignore uppercase
                        soNumbers,                              // ignore numbers
                        soHTML,                                 // ignore HTML
                        soInternet,                             // ignore internet addresses
                        soQuoted,                               // ignore quoted lines
                        soAbbreviations,                        // ignore abbreviations
                        soPrimaryOnly,                          // only suggest from the main dictionaries
                        soRepeated,                             // check for repeated words
                        soDUalCaps,                             // auto-correct DUal caps?
                        soUser1, soUser2, soUser3, soUser4 );   // user options
    TSpellOptions = set of TSpellOption;


    //************************************************************
    // Addict Configuration Class
    //************************************************************

    TAddictConfig = class(TObject)
    protected
        FModified                   :Boolean;
        FMainDictionaries           :TStringList;
        FCustomDictionaries         :TStringList;
        FMSWordCustomDictionaries   :TStringList;
        FActiveCustom               :String;
        FUserNames                  :TStringList;
        FUserValues                 :TStringList;
        FSpellOptions               :TSpellOptions;
        FDialogX                    :Integer;
        FDialogY                    :Integer;
        FNewDictionaryPaths         :TStringList;

        FIniFile                    :TIniFile;
        FRegIniFile                 :TRegIniFile;
        FConfigStorage              :LongInt;
        FConfigFilename             :String;
        FConfigRegistryKey          :String;
        FConfigID                   :String;

        FConfigLoaded               :Boolean;
        FAddictSpell                :Pointer;
        FResetNextLoad              :Boolean;

    protected
        procedure WriteActiveCustom( ActiveCustom:String ); virtual;
        procedure WriteLoaded( NewLoaded:Boolean ); virtual;
        procedure WriteSpellOptions( NewOptions:TSpellOptions ); virtual;
        procedure WriteDialogX( XPos:Integer ); virtual;
        procedure WriteDialogY( YPos:Integer ); virtual;
        function ReadMainDictionaries:TStringList; virtual;
        function ReadCustomDictionaries:TStringList; virtual;
        function ReadMSWordCustomDictionaries:TStringList; virtual;
        function ReadActiveCustom:String; virtual;
        function ReadSpellOptions:TSpellOptions; virtual;
        function ReadDialogX:Integer; virtual;
        function ReadDialogY:Integer; virtual;
        function ReadNewDictionaryPaths:TStringList; virtual;

        procedure NotifyDictionariesChanged(Sender: TObject); virtual;
        
        procedure FireOnConfigChanged( DictionaryChange:Boolean ); virtual;
        procedure ReadWriteStringList( Key:String; var SL:TStringList; Read:Boolean ); virtual;
        function ReadString( Key:String; Default:String ):String; virtual;
        procedure WriteString( Key:String; Value:String ); virtual;
        procedure LoadConfiguration; virtual;
        procedure EnsureLoaded; virtual;

    public
        {$IFNDEF T2H}
        constructor Create; virtual;
        destructor Destroy; override;
        {$ENDIF}

        function GetConfigurationData( Name:String ):String; virtual;
        procedure SetConfigurationData( Name:String; Value:String ); virtual;

        procedure ResetConfigurationDefaults; virtual;
        procedure ReloadConfiguration; virtual;
        procedure SaveConfiguration; virtual;

        property Modified:Boolean read FModified write FModified;
        property Loaded:Boolean read FConfigLoaded write WriteLoaded;
        property MainDictionaries:TStringList read ReadMainDictionaries;
        property CustomDictionaries:TStringList read ReadCustomDictionaries;
        property MSWordCustomDictionaries:TStringList read ReadMSWordCustomDictionaries;
        property ActiveCustomDictionary:String read ReadActiveCustom write WriteActiveCustom;
        property SpellOptions:TSpellOptions read ReadSpellOptions write WriteSpellOptions;
        property DialogX:Integer read ReadDialogX write WriteDialogX;
        property DialogY:Integer read ReadDialogY write WriteDialogY;
        property NewDictionaryPaths:TStringList read ReadNewDictionaryPaths;

        {$IFNDEF T2H}
        property AddictSpell:Pointer read FAddictSpell write FAddictSpell;
        {$ENDIF}
    end;

implementation

uses
    ad3Util,
    ad3SpellBase;


//************************************************************
// Addict Configuration Class
//************************************************************

constructor TAddictConfig.Create;
begin
    inherited Create;

    FModified                   := False;
    FMainDictionaries           := TStringList.Create;
    FCustomDictionaries         := TStringList.Create;
    FMSWordCustomDictionaries   := TStringList.Create;
    FActiveCustom               := '';
    FUserNames                  := TStringList.Create;
    FUserValues                 := TStringList.Create;
    FSpellOptions               := [];
    FDialogX                    := -1;
    FDialogY                    := -1;

    FNewDictionaryPaths             := TStringList.Create;
    FNewDictionaryPaths.Sorted      := True;
    FNewDictionaryPaths.Duplicates  := dupIgnore;

    FConfigLoaded               := False;
    FAddictSpell                := nil;
    FResetNextLoad              := False;

    FMainDictionaries.OnChange          := NotifyDictionariesChanged;
    FCustomDictionaries.OnChange        := NotifyDictionariesChanged;
    FMSWordCustomDictionaries.OnChange  := NotifyDictionariesChanged;
    FNewDictionaryPaths.OnChange        := NotifyDictionariesChanged;
end;

//************************************************************

destructor TAddictConfig.Destroy;
begin
    SaveConfiguration;

    FMainDictionaries.Free;
    FCustomDictionaries.Free;
    FMSWordCustomDictionaries.Free;
    FUserNames.Free;
    FUserValues.Free;
    FNewDictionaryPaths.Free;

    inherited Destroy;
end;



//************************************************************
// Property Read/Write References
//************************************************************

procedure TAddictConfig.WriteActiveCustom( ActiveCustom:String );
begin
    if (FActiveCustom <> ActiveCustom) then
    begin
        FActiveCustom := ActiveCustom;
        if (FCustomDictionaries.IndexOf( FActiveCustom ) = -1) then
        begin
            FCustomDictionaries.Add( FActiveCustom );
        end;
        FireOnConfigChanged( True );
    end;
end;

//************************************************************

procedure TAddictConfig.WriteLoaded( NewLoaded:Boolean );
begin
    if (FConfigLoaded <> NewLoaded) then
    begin
        if (NewLoaded) then
        begin
            LoadConfiguration;
        end
        else
        begin
            SaveConfiguration;
            FConfigLoaded := False;
        end;
    end;
end;

//************************************************************

procedure TAddictConfig.WriteSpellOptions( NewOptions:TSpellOptions );
begin
    if (NewOptions <> FSpellOptions) then
    begin
        FSpellOptions := NewOptions;
        FireOnConfigChanged( False );
    end;
end;

//************************************************************

procedure TAddictConfig.WriteDialogX( XPos:Integer );
begin
    if (FDialogX <> XPos) then
    begin
        FDialogX    := XPos;
        FireOnConfigChanged( False );
    end;
end;

//************************************************************

procedure TAddictConfig.WriteDialogY( YPos:Integer );
begin
    if (FDialogY <> YPos) then
    begin
        FDialogY    := YPos;
        FireOnConfigChanged( False );
    end;
end;

//************************************************************

function TAddictConfig.ReadMainDictionaries:TStringList;
begin
    EnsureLoaded;
    Result := FMainDictionaries;
end;

//************************************************************

function TAddictConfig.ReadCustomDictionaries:TStringList;
begin
    EnsureLoaded;
    Result := FCustomDictionaries;
end;

//************************************************************

function TAddictConfig.ReadMSWordCustomDictionaries:TStringList;
begin
    EnsureLoaded;
    Result := FMSWordCustomDictionaries;
end;

//************************************************************

function TAddictConfig.ReadActiveCustom:String;
begin
    EnsureLoaded;
    Result := TAddictSpell3Base(FAddictSpell).ExpandVars( FActiveCustom );
end;

//************************************************************

function TAddictConfig.ReadSpellOptions:TSpellOptions;
begin
    EnsureLoaded;
    Result := FSpellOptions;
end;

//************************************************************

function TAddictConfig.ReadDialogX:Integer;
begin
    EnsureLoaded;
    Result := FDialogX;
end;

//************************************************************

function TAddictConfig.ReadDialogY:Integer;
begin
    EnsureLoaded;
    Result := FDialogY;
end;

//************************************************************

function TAddictConfig.ReadNewDictionaryPaths:TStringList;
begin
    EnsureLoaded;
    Result := FNewDictionaryPaths;
end;



//************************************************************
// Event Callbacks
//************************************************************

procedure TAddictConfig.NotifyDictionariesChanged(Sender: TObject);
begin
    FireOnConfigChanged( True );
end;




//************************************************************
// Utility Functions
//************************************************************

procedure TAddictConfig.FireOnConfigChanged( DictionaryChange:Boolean );
begin
    if (Assigned(FAddictSpell)) and FConfigLoaded then
    begin
        FModified := True;
        TAddictSpell3Base(FAddictSpell).FireConfigurationChanged( DictionaryChange );
    end;
end;

//************************************************************

procedure TAddictConfig.ReadWriteStringList( Key:String; var SL:TStringList; Read:Boolean );
var
    KeyName     :String;
    Value       :String;
    Count       :LongInt;
    Index       :LongInt;
begin
    KeyName := Key + '_count';
    Count   := 0;

    if (Read) then
    begin
        Value := ReadString( KeyName, '-' );
        if (Value <> '-') then
        begin
            try
                Count := StrToInt( Value );
            except
            end;
        end;
    end
    else
    begin
        Count := SL.Count;
        WriteString( KeyName, IntToStr( Count ) );
    end;

    for Index := 0 to Count - 1 do
    begin
        KeyName := Key + '_' + IntToStr(Index);
        if (Read) then
        begin
            Value := ReadString( KeyName, '' );
            if (Value <> '') then
            begin
                SL.Add( Value );
            end;
        end
        else
        begin
            WriteString( KeyName, SL[Index] );
        end;
    end;
end;

//************************************************************

function TAddictConfig.ReadString( Key:String; Default:String ):String;
begin
    Result := Default;

    case (TAddictSpell3Base(FAddictSpell).ConfigStorage) of
    csFile:
        if (Assigned( FIniFile )) then
        begin
            Result := FIniFile.ReadString( FConfigID, Key, Default );
        end;
    csRegistry:
        if (Assigned( FRegIniFile )) then
        begin
            Result := FRegIniFile.ReadString( FConfigID, Key, Default );
        end;
    csCallback:
        Result := TAddictSpell3Base(FAddictSpell).FireReadString( FConfigID, Key, Default );
    csNone:
        // pulls the default value from above
    end;
end;

//************************************************************

procedure TAddictConfig.WriteString( Key:String; Value:String );
begin
    case (TAddictSpell3Base(FAddictSpell).ConfigStorage) of
    csFile:
        if (Assigned( FIniFile )) then
        begin
            try
                FIniFile.WriteString( FConfigID, Key, Value );
            except
                FIniFile.Free;
                FIniFile := nil;
            end;
        end;
    csRegistry:
        if (Assigned( FRegIniFile )) then
        begin
            FRegIniFile.WriteString( FConfigID, Key, Value );
        end;
    csCallback:
        TAddictSpell3Base(FAddictSpell).FireWriteString( FConfigID, Key, Value );
    csNone:
        // No write done
    end;
end;

//************************************************************

procedure TAddictConfig.LoadConfiguration;
var
    FirstRun    :Boolean;
    Index       :LongInt;
    Addict      :TAddictSpell3Base;
    BoolVal     :Boolean;
    Error       :Integer;
begin
    Addict          := TAddictSpell3Base(FAddictSpell);
    FConfigLoaded   := False;

    if (not Assigned(FAddictSpell)) then
    begin
        exit;
    end;

    // Perform any initialization that is necessary based upon our current
    // storage type

    FConfigStorage  := LongInt( Addict.ConfigStorage );
    FConfigID       := Addict.ExpandVars( Addict.ConfigID );
    case (Addict.ConfigStorage) of
    csFile:
        begin
            FConfigFilename     := Addict.ExpandVars( Addict.ConfigFilename );
            ADForceDirectories( ExtractFilePath( FConfigFilename ) );
            FIniFile            := TIniFile.Create( FConfigFilename );
        end;
    csRegistry:
        begin
            FConfigRegistryKey  := Addict.ExpandVars( Addict.ConfigRegistryKey );
            FRegIniFile         := TRegIniFile.Create( FConfigRegistryKey );
        end;
    end;

    // First we see if this is our first run (or every run on the no config-file
    // case)... we then pick up the defaults from Addict, or read them from
    // the configuration

    FirstRun        := (ReadString( '_FirstRun', '-' ) = '-') or FResetNextLoad;
    FResetNextLoad  := False;

    if (FirstRun) then
    begin
        FMainDictionaries.Clear;
        FMainDictionaries.Assign( Addict.ConfigDefaultMain );
        FCustomDictionaries.Clear;
        FCustomDictionaries.Assign( Addict.ConfigDefaultCustom );
        FMSWordCustomDictionaries.Clear;
        if (Addict.ConfigUseMSWordCustom) and (Addict.ConfigDefaultUseMSWordCustom) then
        begin
            FMSWordCustomDictionaries.Assign( Addict.ConfigAvailableMSWordCustom );
        end;
        FSpellOptions           := Addict.ConfigDefaultOptions;
        FDialogX                := -1;
        FDialogY                := -1;
        FNewDictionaryPaths.Clear;

        ActiveCustomDictionary  := ExpandFixedVars( Addict.ExpandAddictVars( Addict.ConfigDefaultActiveCustom ) );
    end
    else
    begin
        FMainDictionaries.Clear;
        ReadWriteStringList( '_Main', FMainDictionaries, True );
        FCustomDictionaries.Clear;
        ReadWriteStringList( '_Custom', FCustomDictionaries, True );
        FMSWordCustomDictionaries.Clear;
        ReadWriteStringList( '_MSWordCustom', FMSWordCustomDictionaries, True );

        ActiveCustomDictionary  := ReadString( '_ActiveCustom', '');

        FSpellOptions           := [];
        BoolVal := (ReadString( '_soUpcase', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soUpcase];
        BoolVal := (ReadString( '_soNumbers', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soNumbers];
        BoolVal := (ReadString( '_soHTML', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soHTML];
        BoolVal := (ReadString( '_soInternet', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soInternet];
        BoolVal := (ReadString( '_soQuoted', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soQuoted];
        BoolVal := (ReadString( '_soAbbreviations', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soAbbreviations];
        BoolVal := (ReadString( '_soPrimaryOnly', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soPrimaryOnly];
        BoolVal := (ReadString( '_soRepeated', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soRepeated];
        BoolVal := (ReadString( '_soDUalCaps', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soDUalCaps];
        BoolVal := (ReadString( '_soLiveSpelling', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soLiveSpelling];
        BoolVal := (ReadString( '_soLiveCorrect', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soLiveCorrect];
        BoolVal := (ReadString( '_soUser1', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soUser1];
        BoolVal := (ReadString( '_soUser2', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soUser2];
        BoolVal := (ReadString( '_soUser3', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soUser3];
        BoolVal := (ReadString( '_soUser4', '-' ) = '+');
        if (BoolVal) then FSpellOptions := FSpellOptions + [soUser4];

        Val( ReadString( '_DialogX', '-1' ), FDialogX, Error );
        Val( ReadString( '_DialogY', '-1' ), FDialogY, Error );

        ReadWriteStringList( '_NewPaths', FNewDictionaryPaths, True );

        // Read the user-data (name-value paris given programatically).

        FUserNames.Clear;
        FUserValues.Clear;
        ReadWriteStringList( '_UserData', FUserNames, True );
        for Index := 0 to FUserNames.Count - 1 do
        begin
            FUserValues.Add( ReadString( 'User_' + FUserNames[Index], '' ) );
        end;
    end;

    FConfigLoaded   := True;
    FModified       := False;

    // Fire the configuration loaded and configuration changed events out

    Addict.FireConfigLoaded;
    FireOnConfigChanged( True );

    if (Assigned(FIniFile)) then
    begin
        FIniFile.Free;
        FIniFile := nil;
    end;
    if (Assigned(FRegIniFile)) then
    begin
        FRegIniFile.Free;
        FRegIniFile := nil;
    end;
end;

//************************************************************

function GetBoolChar( Value:Boolean ):String;
begin
    if (Value) then
    begin
        Result := '+';
    end
    else
    begin
        Result := '-';
    end;
end;

procedure TAddictConfig.SaveConfiguration;
var
    Index   :LongInt;
    Addict  :TAddictSpell3Base;
begin
    if (not FModified) or (not FConfigLoaded) then
    begin
        Exit;
    end;

    Addict  := TAddictSpell3Base(FAddictSpell);

    if (csDesigning in Addict.ComponentState) then
    begin
        Exit;
    end;        

    // Perform any initialization that is necessary based upon our current
    // storage type

    case (TConfigStorage(FConfigStorage)) of
    csFile:
        FIniFile    := TIniFile.Create( FConfigFilename );
    csRegistry:
        FRegIniFile := TRegIniFile.Create( FConfigRegistryKey );
    end;

    if (TConfigStorage(FConfigStorage) <> csNone) then
    begin
        WriteString( '_FirstRun', '+' );

        ReadWriteStringList( '_Main', FMainDictionaries, False );
        ReadWriteStringList( '_Custom', FCustomDictionaries, False );
        ReadWriteStringList( '_MSWordCustom', FMSWordCustomDictionaries, False );
        WriteString( '_ActiveCustom', FActiveCustom );

        WriteString( '_soUpcase', GetBoolChar(soUpcase in FSpellOptions) );
        WriteString( '_soNumbers', GetBoolChar(soNumbers in FSpellOptions) );
        WriteString( '_soHTML', GetBoolChar(soHTML in FSpellOptions) );
        WriteString( '_soInternet', GetBoolChar(soInternet in FSpellOptions) );
        WriteString( '_soQuoted', GetBoolChar(soQuoted in FSpellOptions) );
        WriteString( '_soAbbreviations', GetBoolChar(soAbbreviations in FSpellOptions) );
        WriteString( '_soPrimaryOnly', GetBoolChar(soPrimaryOnly in FSpellOptions) );
        WriteString( '_soRepeated', GetBoolChar(soRepeated in FSpellOptions) );
        WriteString( '_soDUalCaps', GetBoolChar(soDUalCaps in FSpellOptions) );
        WriteString( '_soLiveSpelling', GetBoolChar(soLiveSpelling in FSpellOptions) );
        WriteString( '_soLiveCorrect', GetBoolChar(soLiveCorrect in FSpellOptions) );
        WriteString( '_soUser1', GetBoolChar(soUser1 in FSpellOptions) );
        WriteString( '_soUser2', GetBoolChar(soUser2 in FSpellOptions) );
        WriteString( '_soUser3', GetBoolChar(soUser3 in FSpellOptions) );
        WriteString( '_soUser4', GetBoolChar(soUser4 in FSpellOptions) );

        WriteString( '_DialogX', IntToStr(FDialogX) );
        WriteString( '_DialogY', IntToStr(FDialogY) );

        ReadWriteStringList( '_NewPaths', FNewDictionaryPaths, False );        

        ReadWriteStringList( '_UserData', FUserNames, False );
        for Index := 0 to FUserValues.Count - 1 do
        begin
            if (Index < FUserNames.Count) then
            begin
                WriteString( 'User_' + FUserNames[Index], FUserValues[Index] );
            end;
        end;
    end;

    FModified := False;

    if (Assigned(FIniFile)) then
    begin
        FIniFile.Free;
        FIniFile := nil;
    end;
    if (Assigned(FRegIniFile)) then
    begin
        FRegIniFile.Free;
        FRegIniFile := nil;
    end;

    // Fire the configuration saved event out.

    Addict.FireConfigSaved;
end;

//************************************************************

procedure TAddictConfig.EnsureLoaded;
begin
    if (not FConfigLoaded) then
    begin
        LoadConfiguration;
    end;
end;




//************************************************************
// Public Methods
//************************************************************

function TAddictConfig.GetConfigurationData( Name:String ):String;
var
    Position    :LongInt;
begin
    EnsureLoaded;
    Result := '';
    if (FConfigLoaded) then
    begin
        Position := FUserNames.IndexOf( Name );
        if (Position >= 0) and (Position < FUserValues.Count) then
        begin
            Result := FUserValues[Position];
        end;
    end;
end;

//************************************************************

procedure TAddictConfig.SetConfigurationData( Name:String; Value:String );
var
    Position    :LongInt;
begin
    EnsureLoaded;
    if (FConfigLoaded) then
    begin
        FModified   := True;
        Position    := FUserNames.IndexOf( Name );
        if (Position >= 0) and (Position < FUserValues.Count) then
        begin
            FUserValues[Position] := Value;
        end
        else
        begin
            FUserNames.Add( Name );
            FUserValues.Add( Value );
        end;
        FireOnConfigChanged( False );
    end;
end;

//************************************************************

procedure TAddictConfig.ResetConfigurationDefaults;
begin
    FResetNextLoad := True;            
    ReloadConfiguration;
end;

//************************************************************

procedure TAddictConfig.ReloadConfiguration;
begin
    if (FConfigLoaded) then
    begin
        SaveConfiguration;
        LoadConfiguration;
    end;
end;



end.
