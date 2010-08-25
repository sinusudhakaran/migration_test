{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10823: ad3ConfigurationDialogCtrl.pas 
{
{   Rev 1.4    1/27/2005 2:14:16 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:06 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:36 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:24 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:36 AM  mnovak
}
{
{   Rev 1.1    7/30/2002 12:07:10 AM  mnovak
{ Prep for v3.3 release
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

AddictSpell Config Dialog Control Component

History:
8/13/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3ConfigurationDialogCtrl;

{$I addict3.inc}

interface

uses
    Windows, Messages, SysUtils, Classes, Graphics,
    Controls, Forms, Dialogs, StdCtrls,
    ad3Util,
    ad3Configuration,
    ad3MainDictionary,
    ad3CustomDictionary,
    ad3SpellLanguages;

type

    TSpellDialogCommand     = ( sdcIgnore, sdcIgnoreAll, sdcChange, sdcChangeAll, sdcAdd, sdcAutoCorrect,
                                sdcUndo, sdcHelp, sdcCancel, sdcOptions, sdcCustomDictionary, sdcCustomDictionaries,
                                sdcConfigOK, sdcAddedEdit, sdcAutoCorrectEdit, sdcExcludedEdit, sdcInternalEdit,
                                sdcMainDictFolderBrowse, sdcResetDefaults );
    TSpellDialogCommands    = set of TSpellDialogCommand;

    TWordPromptEvent        = procedure( Sender:TObject; const Word:String; Repeated:Boolean ) of object;

    TConfigurationDialogCtrl = class(TComponent)
    protected
        FAddictSpell                :Pointer;
        FCustomDictionary           :TCustomDictionary;

        FConfiguration              :TAddictConfig;
        FAvailableOptions           :TSpellOptions;

        FConfigurationAvailable     :TNotifyEvent;
        FCustomDictionaryAvailable  :TNotifyEvent;
        FOnDialogWord               :TWordPromptEvent;

    protected

        // Property read/write functions

        procedure WriteAddictSpell( NewAddict:Pointer );
        procedure WriteCustomDictionary( Dictionary:TCustomDictionary );
        function ReadAvailableMSWordCustom:TStringList;
        function ReadAvailableCustom:TStringList;
        function ReadAvailableMain:TStringList;
        function ReadUseExcludeWords:Boolean;
        function ReadCanUndo:Boolean;
        function ReadInternalCustom:TCustomDictionary;
        function ReadActiveCustom:TCustomDictionary;
        function ReadCommandsVisible:TSpellDialogCommands;
        function ReadCommandsEnabled:TSpellDialogCommands;
        function ReadHelpCtxSpellDialog:THelpContext;
        function ReadHelpCtxConfigDialog:THelpContext;
        function ReadHelpCtxDictionariesDialog:THelpContext;
        function ReadHelpCtxDictionaryEditDialog:THelpContext;
        function ReadVersion:String;
        procedure WriteVersion( NewVersion:String );

    public
        {$IFNDEF T2H}
        constructor Create( aowner:TComponent ); override;
        {$ENDIF}

        property AddictSpell:Pointer read FAddictSpell write WriteAddictSpell;
        property CustomDictionary:TCustomDictionary read FCustomDictionary write WriteCustomDictionary;

        property Configuration:TAddictConfig read FConfiguration;
        property AvailableOptions:TSpellOptions read FAvailableOptions;
        property AvailableMSWordCustom:TStringList read ReadAvailableMSWordCustom;
        property AvailableCustom:TStringList read ReadAvailableCustom;
        property AvailableMain:TStringList read ReadAvailableMain;
        property UseExcludeWords:Boolean read ReadUseExcludeWords;
        property CanUndo:Boolean read ReadCanUndo;
        property InternalCustom:TCustomDictionary read ReadInternalCustom;
        property ActiveCustomDictionary:TCustomDictionary read ReadActiveCustom;
        property CommandsVisible:TSpellDialogCommands read ReadCommandsVisible;
        property CommandsEnabled:TSpellDialogCommands read ReadCommandsEnabled;

        property HelpCtxSpellDialog:THelpContext read ReadHelpCtxSpellDialog;
        property HelpCtxConfigDialog:THelpContext read ReadHelpCtxConfigDialog;
        property HelpCtxDictionariesDialog:THelpContext read ReadHelpCtxDictionariesDialog;
        property HelpCtxDictionaryEditDialog:THelpContext read ReadHelpCtxDictionaryEditDialog;

        function GetMainDictionary( Filename:String ):TMainDictionary;
        function GetCustomDictionary( Filename:String ):TCustomDictionary;

        function GetOptionString( Option:TSpellOption ):String;
        function GetString( LangString:TSpellLanguageString ):String;

        procedure Setup;
        procedure SetupCustomDictionaries;
        procedure EditCustomDictionary( CustomDictionary:TCustomDictionary );
        procedure SetupAddDictionaryDir;

        procedure EnableCustomDictionary( Filename:String; Enabled:Boolean );
        procedure EnableWordDictionary( Filename:String; Enabled:Boolean );
        procedure RemoveCustomDictionary( Filename:String );
        procedure CreateNewCustomDictionary( Filename:String );
        function RenameCustomDictionary( OldFilename:String; NewFilename:String ):Boolean;

        procedure Ignore;
        procedure IgnoreAll;
        procedure Change( const Word:String );
        procedure ChangeAll( const Word:String );
        procedure Add;
        procedure AutoCorrect( const Word:String );
        procedure Undo;
        procedure RepeatIgnore;
        procedure RepeatDelete;
        procedure ControlEdited;
        procedure Cancel;

        procedure Suggest( const Word:String; Words:TStrings );

        procedure HelpSpellDialog;
        procedure HelpConfigDialog;
        procedure HelpDictionariesDialog;
        procedure HelpDictionaryEditDialog;

    published

        property Version:String read ReadVersion write WriteVersion stored false;

        //#<Events>
        property OnConfigurationAvailable:TNotifyEvent read FConfigurationAvailable write FConfigurationAvailable;
        property OnCustomDictionaryAvailable:TNotifyEvent read FCustomDictionaryAvailable write FCustomDictionaryAvailable;
        property OnPromptWord:TWordPromptEvent read FOnDialogWord write FOnDialogWord;
        //#</Events>
    end;

implementation

uses
    ad3SpellBase;


//************************************************************
// Spell Check Dialog Control
//************************************************************

constructor TConfigurationDialogCtrl.Create( aowner:TComponent );
begin
    inherited Create(aowner);

    FAddictSpell        := nil;

    FConfigurationAvailable     := nil;
    FCustomDictionaryAvailable  := nil;
    FOnDialogWord               := nil;

    FConfiguration      := nil;
    FAvailableOptions   := [];
end;


//************************************************************
// Property read/write functions
//************************************************************

procedure TConfigurationDialogCtrl.WriteAddictSpell( NewAddict:Pointer );
begin
    if (not(Assigned(FAddictSpell))) then
    begin
        FAddictSpell    := NewAddict;
        if (Assigned(FAddictSpell)) then
        begin
            FConfiguration      := TAddictSpell3Base(FAddictSpell).Configuration;
            FAvailableOptions   := TAddictSpell3Base(FAddictSpell).ConfigAvailableOptions;

            if (Assigned( FConfigurationAvailable )) then
            begin
                FConfigurationAvailable( Self );
            end;
        end;
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.WriteCustomDictionary( Dictionary:TCustomDictionary );
begin
    FCustomDictionary     := Dictionary;
    if (Assigned(FCustomDictionary)) and (Assigned(FCustomDictionaryAvailable)) then
    begin
        FCustomDictionaryAvailable( Self );
    end;
end;

//************************************************************

function TConfigurationDialogCtrl.ReadAvailableMSWordCustom:TStringList;
begin
    Result := nil;
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).ConfigAvailableMSWordCustom;
    end;
end;

//************************************************************

function TConfigurationDialogCtrl.ReadAvailableCustom:TStringList;
begin
    Result := nil;
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).ConfigAvailableCustom;
    end;
end;

//************************************************************

function TConfigurationDialogCtrl.ReadAvailableMain:TStringList;
begin
    Result := nil;
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).ConfigAvailableMain;
    end;
end;

//************************************************************

function TConfigurationDialogCtrl.ReadUseExcludeWords:Boolean;
begin
    Result := True;
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).UseExcludeWords;
    end;
end;

//************************************************************

function TConfigurationDialogCtrl.ReadCanUndo:Boolean;
begin
    Result := False;
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).CanUndo;
    end;
end;

//************************************************************

function TConfigurationDialogCtrl.ReadInternalCustom:TCustomDictionary;
begin
    Result := nil;
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).InternalCustom;
    end;
end;

//************************************************************

function TConfigurationDialogCtrl.ReadActiveCustom:TCustomDictionary;
begin
    Result := nil;
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).ActiveCustomDictionary;
    end;
end;

//************************************************************

function TConfigurationDialogCtrl.ReadCommandsVisible:TSpellDialogCommands;
begin
    Result := [];
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).CommandsVisible;
        if (sdcHelp in Result) then
        begin

        end;
    end;
end;

//************************************************************

function TConfigurationDialogCtrl.ReadCommandsEnabled:TSpellDialogCommands;
begin
    Result := [];
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).CommandsEnabled;
    end;
end;

//************************************************************

function TConfigurationDialogCtrl.ReadHelpCtxSpellDialog:THelpContext;
begin
    Result := 0;
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).HelpCtxSpellDialog;
    end;        
end;

//************************************************************

function TConfigurationDialogCtrl.ReadHelpCtxConfigDialog:THelpContext;
begin
    Result := 0;
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).HelpCtxConfigDialog;
    end;        
end;

//************************************************************

function TConfigurationDialogCtrl.ReadHelpCtxDictionariesDialog:THelpContext;
begin
    Result := 0;
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).HelpCtxDictionariesDialog;
    end;        
end;

//************************************************************

function TConfigurationDialogCtrl.ReadHelpCtxDictionaryEditDialog:THelpContext;
begin
    Result := 0;
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).HelpCtxDictionaryEditDialog;
    end;        
end;

//************************************************************

function TConfigurationDialogCtrl.ReadVersion:String;
begin
    Result := GetAddictVersion;
end;

//************************************************************

procedure TConfigurationDialogCtrl.WriteVersion( NewVersion:String );
begin
end;




//************************************************************
// Public Methods
//************************************************************

function TConfigurationDialogCtrl.GetMainDictionary( Filename:String ):TMainDictionary;
begin
    Result := nil;
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).GetMainDictionary( Filename );
    end;
end;

//************************************************************

function TConfigurationDialogCtrl.GetCustomDictionary( Filename:String ):TCustomDictionary;
begin
    Result := nil;
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).GetCustomDictionary( Filename );
    end;
end;

//************************************************************

function TConfigurationDialogCtrl.GetOptionString( Option:TSpellOption ):String;
begin
    Result := '';
    if (Assigned(FAddictSpell)) then
    begin
        case (Option) of
        soUser1:
            Result := TAddictSpell3Base(FAddictSpell).ConfigUserOption1;
        soUser2:
            Result := TAddictSpell3Base(FAddictSpell).ConfigUserOption2;
        soUser3:
            Result := TAddictSpell3Base(FAddictSpell).ConfigUserOption3;
        soUser4:
            Result := TAddictSpell3Base(FAddictSpell).ConfigUserOption4;
        else
            Result := TAddictSpell3Base(FAddictSpell).GetString( TSpellLanguageString( Integer(lsLiveSpelling) + Integer(Option) ) );
        end;
    end;
end;

//************************************************************

function TConfigurationDialogCtrl.GetString( LangString:TSpellLanguageString ):String;
begin
    Result := '';
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).GetString( LangString );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.Setup;
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).InternalSetup( Self );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.SetupCustomDictionaries;
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).InternalSetupCustomDictionaries( Self );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.EditCustomDictionary( CustomDictionary:TCustomDictionary );
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).InternalEditCustomDictionary( Self, CustomDictionary );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.SetupAddDictionaryDir;
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).InternalSetupAddDictionaryDir( Self );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.EnableCustomDictionary( Filename:String; Enabled:Boolean );
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).EnableCustomDictionary( Filename, Enabled );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.EnableWordDictionary( Filename:String; Enabled:Boolean );
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).EnableWordDictionary( Filename, Enabled );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.RemoveCustomDictionary( Filename:String );
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).RemoveCustomDictionary( Filename );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.CreateNewCustomDictionary( Filename:String );
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).CreateNewCustomDictionary( Filename );
    end;
end;

//************************************************************

function TConfigurationDialogCtrl.RenameCustomDictionary( OldFilename:String; NewFilename:String ):Boolean;
begin
    Result := False;
    if (Assigned(FAddictSpell)) then
    begin
        Result := TAddictSpell3Base(FAddictSpell).RenameCustomDictionary( OldFilename, NewFilename );
    end;
end;


//************************************************************
// Public Response Methods
//************************************************************

procedure TConfigurationDialogCtrl.Ignore;
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).Check_Ignore;
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.IgnoreAll;
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).Check_IgnoreAll;
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.Change( const Word:String );
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).Check_Change( Word );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.ChangeAll( const Word:String );
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).Check_ChangeAll( Word );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.Add;
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).Check_Add;
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.AutoCorrect( const Word:String );
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).Check_AutoCorrect( Word );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.ControlEdited;
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).Check_ControlEdited;
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.Cancel;
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).Check_Cancel;
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.Undo;
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).Check_Undo;
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.RepeatIgnore;
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).Check_RepeatIgnore;
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.RepeatDelete;
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).Check_RepeatDelete;
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.Suggest( const Word:String; Words:TStrings );
begin
    if (Assigned(FAddictSpell)) then
    begin
        TAddictSpell3Base(FAddictSpell).Suggest( Word, Words );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.HelpSpellDialog;
begin
    if (Assigned(FAddictSpell)) then
    begin
        Application.HelpContext( TAddictSpell3Base(FAddictSpell).HelpCtxSpellDialog );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.HelpConfigDialog;
begin
    if (Assigned(FAddictSpell)) then
    begin
        Application.HelpContext( TAddictSpell3Base(FAddictSpell).HelpCtxConfigDialog );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.HelpDictionariesDialog;
begin
    if (Assigned(FAddictSpell)) then
    begin
        Application.HelpContext( TAddictSpell3Base(FAddictSpell).HelpCtxDictionariesDialog );
    end;
end;

//************************************************************

procedure TConfigurationDialogCtrl.HelpDictionaryEditDialog;
begin
    if (Assigned(FAddictSpell)) then
    begin
        Application.HelpContext( TAddictSpell3Base(FAddictSpell).HelpCtxDictionaryEditDialog );
    end;
end;


end.

