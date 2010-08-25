{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10859: ad3SpellBase.pas 
{
{   Rev 1.9    1/27/2005 2:14:20 AM  mnovak
}
{
{   Rev 1.8    20/12/2004 3:24:30 pm  Glenn
}
{
{   Rev 1.7    9/9/2004 12:02:08 AM  mnovak
{ Improvement for Smart Quotes
}
{
{   Rev 1.5    2/21/2004 11:59:50 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.4    1/15/2004 7:18:52 PM  mnovak
{ Fixed an undo problem related to Change All.
}
{
{   Rev 1.3    12/3/2003 1:03:38 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.2    11/25/2003 10:08:34 PM  mnovak
{ Add exception handler around loading of MSWord custom dictionary
}
{
{   Rev 1.1    11/25/2003 9:16:00 PM  mnovak
{ Make WordAcceptable respect Exclude words.
}
{
{   Rev 1.0    8/25/2003 1:01:48 AM  mnovak
}
{
{   Rev 1.4    12/17/2002 6:17:14 PM  mnovak
{ Switch default message Processing to HandleMessage, rather than
{ ProcessMessages.
}
{
{   Rev 1.3    12/17/2002 11:15:44 AM  mnovak
{ Correct API name to match the docs.
}
{
{   Rev 1.2    12/15/2002 8:58:36 PM  mnovak
{ Changed default for AllowedCases to be backwards compatible
}
{
{   Rev 1.1    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.0    6/23/2002 11:53:50 PM  mnovak
}
{
{   Rev 1.0    6/17/2002 1:34:20 AM  Supervisor
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

TAddictSpell3Base Component

History:
7/28/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3SpellBase;

{$I addict3.inc}

interface

uses
    windows, Forms, SysUtils, Classes, controls,
    {$IFDEF Delphi5AndAbove} contnrs, {$ENDIF}
    menus,
    ad3ParserBase,
    ad3MainDictionary,
    ad3CustomDictionary,
    ad3Ignore,
    ad3ParseEngine,
    ad3Configuration,
    ad3Suggestions,
    ad3ConfigurationDialogCtrl,
    ad3SpellLanguages,
    ad3Util,
    ad3WinAPIParser,
    ad3StringParser,
    ad3PhoneticsMap;

type

    //************************************************************
    // AddictSpell Component
    //************************************************************

    TConfigStorage          = ( csFile, csRegistry, csCallback, csNone );
    TWordCheckType          = ( wcAccepted, wcExcluded, wcCorrected, wcDenied, wcRepeated );
    TSpellUI                = ( suiDialog, suiSilent );
    TSpellDialogInitialPos  = ( ipScreenCenter, ipUnderSelection, ipAvoidControl, ipUserDefined, ipLastUserPos, ipIgnore, ipDesktopCenter );
    TSpellDialogAvoidPos    = ( saNone, saAvoid, saAvoidUpDown, saMove, saMoveUpDown );
    TSpellEndMessage        = ( emNever, emAlways, emExceptCancel, emNoDialog );
    TSpellEndPosition       = ( epHome, epOriginal, epNoModify );
    TSpellPopupOption       = ( spCancel, spDialog, spAutoCorrect, spChangeAll, spAdd, spIgnoreAll, spIgnore, spReplace );
    TSpellPopupOptions      = set of TSpellPopupOption;
    TCheckType              = ( ctSelected, ctFromCursor, ctAll, ctSmart, ctCurrent );
    TSpellAction            = ( saIgnore, saIgnoreAll, saChange, saChangeAll, saAdd, saAutoCorrect );
    TCaseModification       = ( cmNone, cmInitialCaps, cmInitialCapsOrUpcase, cmAnyCase, cmCustom );

    TReadStringEvent        = procedure( Sender:TObject; ConfigID:String; Key:String; Default:String; var Value:String ) of object;
    TWriteStringEvent       = procedure( Sender:TObject; ConfigID:String; Key:String; Value:String ) of object;
    TWordCheckEvent         = procedure( Sender:TObject; const Word:String; var CheckType:TWordCheckType; var Replacement:String ) of object;
    TCustomSpellDialogEvent = procedure( Sender:TObject; var SpellForm:TForm; Create:Boolean ) of object;
    TModalDialogEvent       = procedure( Sender:TObject; AOwner:TComponent ) of object;
    TModalDictEditEvent     = procedure( Sender:TObject; AOwner:TComponent; CustomDictionary:TCustomDictionary ) of object;
    TGetStringEvent         = procedure( Sender:TObject; LanguageString:TSpellLanguageString; var Text:String ) of object;
    TReplaceWordEvent       = procedure( Sender:TObject; Before:Boolean; Replacement:String; State:LongInt ) of object;
    TIgnoreWordEvent        = procedure( Sender:TObject; Before:Boolean; State:LongInt ) of object;
    TUndoLastEvent          = procedure( Sender:TObject; UndoState:LongInt; UndoAction:TSpellAction; UndoData:LongInt ) of object;
    TCreateCustomDictEvent  = procedure( Sender:TObject; var Dictionary:TCustomDictionary ) of object;
    TPopupDoMenuEvent       = procedure( Sender:TObject; Menu:TObject; XPos:Integer; YPos:Integer; var PopupAction:Integer; var PopupWord:String ) of object;
    TPopupAddMenuItemEvent  = procedure( Sender:TObject; Menu:TObject; SubMenu:TObject; Caption:String; Enable:Boolean; HasChildren:Boolean; Tag:Integer; var MenuItem:TObject ) of object;
    TPopupCreateMenuEvent   = procedure( Sender:TObject; Owner:TComponent; var PopupMenu:TObject ) of object;
    TPopupResultEvent       = procedure( Sender:TObject; Word:String; var ResultWord:String; var PopupResult:TSpellPopupOption ) of object;
    TCaseModificationEvent  = procedure( Sender:TObject; var Word:String ) of object;

    TParserIgnoreWordEventList = class(TEventList)
    private
        FBefore :Boolean;
        FState  :LongInt;
    public
        property Before:Boolean read FBefore write FBefore;
        property State:LongInt read FState write FState;
    end;

    TPopupResultEventList = class(TEventList)
    private
        FResult  :TSpellPopupOption;
    public
        property PopupResult:TSpellPopupOption read FResult write FResult;
    end;

    TAddictSpell3Base = class(TComponent)
    private
    protected

        // Runtime

        FParsingEngine          :TParsingEngine;
        FParser                 :TControlParser;
        FInternalCustom         :TCustomDictionary;
        FSuggestions            :TSuggestionsGenerator;
        FPhoneticsMap           :TPhoneticsMap;

        FBeforeChangeFired      :Boolean;
        FChecking               :Boolean;
        FCanceled               :Boolean;
        FWord                   :String;

        FOldOptions             :TSpellOptions;
        FPrimaryOnly            :Boolean;
        FRepeated               :Boolean;
        FDUalCaps               :Boolean;
        FLiveSpelling           :Boolean;
        FLiveCorrect            :Boolean;

        FMainDictionaries       :TObjectList;
        FCustomDictionaries     :TObjectList;
        FMSWordDictionaries     :TObjectList;
        FActiveCustom           :TCustomDictionary;
        FMappingCustom          :TCustomDictionary;
        FLearningCustom         :TCustomDictionary;

        FIgnoreEntries          :TList;
        FIgnoreEntriesPost      :TObjectList;
        FIgnoreEntriesLine      :TList;

        FAllowPossessive        :Boolean;
        FAllowSoundexFollowup   :Boolean;

        // Runtime UI

        FUILanguage             :TSpellLanguageType;

        FSpellUIType            :TSpellUI;
        FUseExclude             :Boolean;
        FUseAutoCorrectFirst    :Boolean;
        FRecheckReplaced        :Boolean;
        FDialogForm             :TForm;
        FDialogCtrl             :TConfigurationDialogCtrl;
        FDialogShown            :Boolean;
        FWordCount              :LongInt;
        FOptimizeCount          :LongInt;
        FUndoList               :TObjectList;
        FCheckingSequence       :Boolean;
        FOriginalX              :LongInt;
        FOriginalY              :LongInt;
        FDeactivated            :Boolean;
        FMergedDictionaryDir    :TStringList;

        // Help Contexts

        FHelpFile                       :String;
        FHelpCtxSpellDialog             :THelpContext;
        FHelpCtxConfigDialog            :THelpContext;
        FHelpCtxDictionariesDialog      :THelpContext;
        FHelpCtxDictionaryEditDialog    :THelpContext;

        // Configuration

        FConfiguration          :TAddictConfig;

        FConfigAvailableMain    :TStringList;
        FConfigAvailableCustom  :TStringList;
        FConfigAvailableMSWord  :TStringList;

        FConfigStorage          :TConfigStorage;
        FConfigID               :String;
        FConfigFilename         :String;
        FConfigRegistryKey      :String;
        FConfigDictionaryDir    :TStringList;
        FAvailableOptions       :TSpellOptions;
        FUserOption1            :String;
        FUserOption2            :String;
        FUserOption3            :String;
        FUserOption4            :String;
        FMSWord                 :Boolean;
        FMappingDictionary      :String;
        FMappingAutoReplace     :Boolean;

        FDefaultMSWord          :Boolean;
        FDefaultMain            :TStringList;
        FDefaultCustom          :TStringList;
        FDefaultActiveCustom    :String;
        FDefaultOptions         :TSpellOptions;

        // Event re-directs

        FOldOnShow              :TNotifyEvent;
        FOldOnActivate          :TNotifyEvent;
        FOldOnDeactivate        :TNotifyEvent;

        // Sequence Check Property Saves

        FOldCloseDialog         :Boolean;
        FOldKeepActive          :Boolean;

        // Repeated word watch

        FLastWord               :String;
        FExecutingRepeat        :Boolean;

        // Popup Menu Variables

        FPopupShowing           :Boolean;
        FPopupAction            :Integer;
        FPopupWord              :String;

        // Additional Properties

        FQuoteChars             :String;
        FInitialPos             :TSpellDialogInitialPos;
        FAvoidPos               :TSpellDialogAvoidPos;
        FImmediateDialog        :Boolean;
        FModalDialog            :Boolean;
        FCloseDialog            :Boolean;
        FFreeParser             :Boolean;
        FEndMessage             :TSpellEndMessage;
        FEndPosition            :TSpellEndPosition;
        FEndMessageWordCount    :Boolean;
        FMaxUndo                :LongInt;
        FMaxSuggestions         :LongInt;
        FKeepDictionariesActive :Boolean;
        FProcessMessages        :Boolean;
        FUseHourglass           :Boolean;
        FUsePhoneticSuggetions  :Boolean;
        FCommandsVisible        :TSpellDialogCommands;
        FCommandsEnabled        :TSpellDialogCommands;
        FLearnSuggestions       :Boolean;
        FLearnAutoCorrect       :Boolean;
        FSuggestionsDictFN      :String;
        FResumeFromLastPosition :Boolean;
        FAllowedCases           :TCaseModification;

        // Events

        FOnConfigChanged        :TNotifyEvent;
    	FOnConfigLoaded         :TNotifyEvent;
        FOnConfigSaved          :TNotifyEvent;
        FOnConfigReadString     :TReadStringEvent;
        FOnConfigWriteString    :TWriteStringEvent;
        FOnDictionariesChanged  :TNotifyEvent;
        FOnWordCheck            :TWordCheckEvent;
        FOnDialogWord           :TWordPromptEvent;
        FOnCreateSpellDialog    :TCustomSpellDialogEvent;
        FOnShowConfigDialog     :TModalDialogEvent;
        FOnShowCustomDialog     :TModalDialogEvent;
        FOnShowEditDialog       :TModalDictEditEvent;
        FOnShowAddDictionaryDir :TModalDialogEvent;
        FOnGetString            :TGetStringEvent;
        FOnAddCustomIgnore      :TNotifyEvent;
        FOnSpellDialogShow      :TNotifyEvent;
        FOnSpellDialogHide      :TNotifyEvent;
        FOnPositionDialog       :TNotifyEvent;
        FOnShowEndMessage       :TNotifyEvent;
        FOnCompleteCheck        :TNotifyEvent;
        FOnDialogDeactivate     :TNotifyEvent;
        FOnDialogActivate       :TNotifyEvent;
        FOnAdjustPhoneticsMap   :TNotifyEvent;
        FOnParserReplaceWord    :TReplaceWordEvent;
        FOnParserIgnoreWord     :TIgnoreWordEvent;
        FOnParserUndoLast       :TUndoLastEvent;
        FOnBeforeChange         :TNotifyEvent;
        FOnCreateCustomDict     :TCreateCustomDictEvent;
        FOnPopupDoMenu          :TPopupDoMenuEvent;
        FOnPopupAddMenuItem     :TPopupAddMenuItemEvent;
        FOnPopupCreateMenu      :TPopupCreateMenuEvent;
        FOnPopupResult          :TPopupResultEvent;
        FOnCaseModification     :TCaseModificationEvent;

        FOnAddCustomIgnoreList  :TEventList;
        FOnConfigChangedList    :TEventList;
        FOnParserIgnoreWordList :TParserIgnoreWordEventList;
        FOnPopupResultList      :TPopupResultEventList;

    protected

        // Property read/write functions

        procedure WriteParsingEngine( NewEngine:TParsingEngine ); virtual;
        procedure WriteSuggestions( NewSuggestions:TSuggestionsGenerator ); virtual;
        procedure WritePhoneticsMap( NewPhonetics:TPhoneticsMap ); virtual;
        procedure WriteConfigStorage( NewStorage:TConfigStorage ); virtual;
        procedure WriteConfigID( const NewID:String ); virtual;
        procedure WriteConfigFilename( const NewFilename:String ); virtual;
        procedure WriteConfigRegistryKey( const NewKey:String ); virtual;
        procedure WriteConfigDictionaryDir( NewList:TStringList ); virtual;
        procedure WriteDefaultMain( NewList:TStringList ); virtual;
        procedure WriteDefaultCustom( NewList:TStringList ); virtual;
        procedure WriteQuoteChars( NewChars:String ); virtual;
        procedure WriteKeepDictionariesActive( Active:Boolean ); virtual;
        procedure WritePhoneticMaxDistance( NewDistance:Integer ); virtual;
        procedure WritePhoneticDivisor( NewDivisor:Integer ); virtual;
        procedure WritePhoneticDepth( NewDepth:Integer ); virtual;
        procedure WriteMappingDictionary( NewMappingDict:String ); virtual;
        procedure WriteLearnSuggestions( NewValue:Boolean ); virtual;
        procedure WriteSuggestionsDictFN( NewFilename:String ); virtual;
        function ReadAvailableMain:TStringList; virtual;
        function ReadAvailableCustom:TStringList; virtual;
        function ReadAvailableMSWordCustom:TStringList; virtual;
        function ReadCanUndo:Boolean; virtual;
        function ReadPhoneticMaxDistance:Integer; virtual;
        function ReadPhoneticDivisor:Integer; virtual;
        function ReadPhoneticDepth:Integer; virtual;
        function ReadVersion:String;
        procedure WriteVersion( NewVersion:String );
        function ReadTextPrimaryLanguage:DWORD; virtual;

        // Dictionary Utility Functions

        procedure OptimizeMainDictionaryOrder; virtual;
        procedure ReloadDictionaries; virtual;
        procedure GetAvailableDictionaries( Ext:String; var DictionaryList:TStringList ); virtual;

        // Setup Utility Functions

        function SetupDialogControl( Dialog:TForm; CustomDictionary:TCustomDictionary ):TConfigurationDialogCtrl; virtual;
        procedure ResynchOptions( ForceRefresh:Boolean ); virtual;

        // Dialog Utility Funtions

        procedure Form_OnShow( Sender:TObject ); virtual;
        procedure Form_OnDeactivate( Sender:TObject ); virtual;
        procedure Form_OnActivate( Sender:TObject ); virtual;
        procedure DoWordPrompt; virtual;
        procedure AdjustDialogToSelection( AdjustLeft:Boolean; AdjustTop:Boolean ); virtual;
        procedure AdjustDialogToControl; virtual;
        procedure SetInitialPosition; virtual;
        procedure AvoidSelection; virtual;
        procedure CreateSpellDialog; virtual;
        procedure EnsureUI; virtual;
        procedure ShutdownUI; virtual;
        procedure ShowEndMessage; virtual;

        // Event Firing Utility Functions

        procedure Fire_ReplaceWord( Word:String; State:LongInt ); virtual;
        procedure Fire_IgnoreWord( State:LongInt ); virtual;
        procedure Fire_UndoLast( UndoState:LongInt; UndoAction:TSpellAction; var UndoData:LongInt ); virtual;
        procedure NotifyDictionariesPathChanged( Sender: TObject ); virtual;

        // Parsing Utility Functions

        function ValidRepeatedWord( Word:String; Parser:TControlParser ):Boolean; virtual;
        function WordIsPossessive( const Word:String ):Boolean; virtual;
        function GetCaseModification( const Word:String ):String; virtual;
        procedure GetWordCountParserInternal( Parser:TControlParser; CheckType:TCheckType;
                                                        CheckErrors:Boolean; StopOnFirstError:Boolean;
                                                        var HasErrors:Boolean;
                                                        var ErrorCount:LongInt;
                                                        var WordCount:LongInt ); virtual;

        // Undo Functionality

        procedure PerformUndo; virtual;
        procedure SetUndoAction( SpellAction:TSpellAction; Replacement:String; Automatic:Boolean ); virtual;

        // Popup Menu

        procedure PopupMenuHook( Sender:TObject ); virtual;
        function CreatePopupMenu( AOwner:TComponent ):TObject; virtual;
        function AddMenuItem( Menu:TObject; SubMenu:TObject; const Caption:String; Enable:Boolean; HasChildren:Boolean; Tag:Integer ):TObject; virtual;
        procedure DoPopup( Menu:TObject; XPos:Integer; YPos:Integer; var PopupAction:Integer; var PopupWord:String ); virtual;

        // Check Process Utility Functions

        procedure CompleteCheck; virtual;
        procedure ContinueCheck; virtual;
        procedure CheckSmart( Parser:TControlParser ); virtual;

        // Suggestions Utility Functiosn

        procedure InternalSuggest( const Word:String; MaxSuggestions:LongInt; Words:TStrings ); virtual;

    public

        // Public Check Process Utility Functions

        procedure ExistsEvent( const Word:PChar; var Exists:Boolean ); virtual;

        // Public Ignore Object Functions

        procedure RunInlineIgnore( CurrentChar:Char; Parser:TControlParser; var Ignore:Boolean ); virtual;
        procedure RunPreCheckIgnore( const Word:String; Parser:TControlParser; var Ignore:Boolean ); virtual;
        function RunPostCheckIgnore( const Word:String; Parser:TControlParser ):Boolean; virtual;
        function RunLineIgnore( const Line:String ):Boolean; virtual;
        procedure AddIgnore( IgnoreEntry:TParserIgnore ); virtual;
        procedure ClearIgnoreList; virtual;

        // Configuration object callbacks

        procedure FireConfigurationChanged( DictionaryChange:Boolean ); virtual;
        function FireReadString( const ConfigID:String; const Key:String; const Default:String ):String; virtual;
        procedure FireWriteString( const ConfigID:String; const Key:String; const Value:String ); virtual;
        procedure FireConfigLoaded; virtual;
        procedure FireConfigSaved; virtual;

        // Dialog control callbacks

        procedure InternalSetup( AOwner:TComponent ); virtual;
        procedure InternalSetupCustomDictionaries( AOwner:TComponent ); virtual;
        procedure InternalEditCustomDictionary( AOwner:TComponent; CustomDictionary:TCustomDictionary ); virtual;
        procedure InternalSetupAddDictionaryDir( AOwner:TComponent ); virtual;

        {$IFNDEF T2H}
        function ExpandAddictVars( Path:String ):String; virtual;
        {$ENDIF}

    public

        {$IFNDEF T2H}
        constructor Create( AOwner:TComponent ); override;
        destructor Destroy; override;
        {$ENDIF}

        // public properties

        property ParsingEngine:TParsingEngine read FParsingEngine write WriteParsingEngine;
        property SuggestionsGenerator:TSuggestionsGenerator read FSuggestions write WriteSuggestions;
        property PhoneticsMap:TPhoneticsMap read FPhoneticsMap write WritePhoneticsMap;
        property ControlParser:TControlParser read FParser;

        property MainDictionaries:TObjectList read FMainDictionaries;
        property CustomDictionaries:TObjectList read FCustomDictionaries;
        property MSWordCustomDictionaries:TObjectList read FMSWordDictionaries;
        property ActiveCustomDictionary:TCustomDictionary read FActiveCustom;
        property MappingCustomDictionary:TCustomDictionary read FMappingCustom;
        property LearningCustomDictionary:TCustomDictionary read FLearningCustom;

        property Configuration:TAddictConfig read FConfiguration;

        property ConfigAvailableCustom:TStringList read ReadAvailableCustom;
        property ConfigAvailableMain:TStringList read ReadAvailableMain;
        property ConfigAvailableMSWordCustom:TStringList read ReadAvailableMSWordCustom;

        property CloseDialog:Boolean read FCloseDialog write FCloseDialog;
        property FreeParser:Boolean read FFreeParser write FFreeParser;

        property InternalCustom:TCustomDictionary read FInternalCustom;
        property DialogForm:TForm read FDialogForm;
        property DialogShown:Boolean read FDialogShown;
        property DialogDeactivated:Boolean read FDeactivated;
        property Checking:Boolean read FChecking;
        property RepeatedWord:Boolean read FExecutingRepeat;
        property CheckCanceled:Boolean read FCanceled;
        property CurrentWord:String read FWord;
        property WordCount:LongInt read FWordCount;
        property CanUndo:Boolean read ReadCanUndo;
        property TextPrimaryLanguage:DWORD read ReadTextPrimaryLanguage;

        property AllowPossessiveIgnore:Boolean read FAllowPossessive write FAllowPossessive;
        property AllowSoundexFollowup:Boolean read FAllowSoundexFollowup write FAllowSoundexFollowup;

        property OnAddCustomIgnoreList:TEventList read FOnAddCustomIgnoreList;
        property OnConfigChangedList:TEventList read FOnConfigChangedList;
        property OnParserIgnoreWordList:TParserIgnoreWordEventList read FOnParserIgnoreWordList;
        property OnPopupResultList:TPopupResultEventList read FOnPopupResultList write FOnPopupResultList; 

        // public dictionary methods

        procedure EnableCustomDictionary( Filename:String; Enabled:Boolean ); virtual;
        procedure EnableWordDictionary( Filename:String; Enabled:Boolean ); virtual;
        procedure RemoveCustomDictionary( Filename:String ); virtual;
        procedure CreateNewCustomDictionary( Filename:String ); virtual;
        function RenameCustomDictionary( OldFilename:String; NewFilename:String ):Boolean; virtual;
        function GetMainDictionary( Filename:String ):TMainDictionary; virtual;
        function GetCustomDictionary( Filename:String ):TCustomDictionary; virtual;
        function GetMSWordCustomDictionary( Filename:String ):TCustomDictionary; virtual;
        function ExpandVars( Path:String ):String; virtual;

        // setup routines / UI Work

        procedure Setup; virtual;
        procedure SetupCustomDictionaries; virtual;
        procedure EditCustomDictionary( CustomDictionary:TCustomDictionary ); virtual;
        procedure SetupAddDictionaryDir; virtual;
        function GetString( LanguageString:TSpellLanguageString ):String; virtual;

        // runtime routines

        procedure ResetUndo; virtual;
        procedure UnloadDictionaries; virtual;
        procedure CloseSpellDialog; virtual;

        // control check methods

        procedure CheckString( var CheckString:String ); virtual;
        procedure CheckWinControl( Control:TWinControl; CheckType:TCheckType ); virtual;
        procedure CheckRichEdit( Control:TWinControl; CheckType:TCheckType ); virtual;
        procedure CheckWinControlHWND( ControlHWND:HWND; CheckType:TCheckType ); virtual;
        procedure CheckParser( Parser:TControlParser; CheckType:TCheckType ); virtual;
        procedure StartSequenceCheck; virtual;
        procedure StopSequenceCheck; virtual;
        procedure StopCheck( Canceled:Boolean ); virtual;

        // word count methods

        function GetWordCountString( CountString:String ):LongInt; virtual;
        function GetWordCountWinControl( Control:TWinControl; CheckType:TCheckType ):LongInt; virtual;
        function GetWordCountParser( Parser:TControlParser; CheckType:TCheckType ):LongInt; virtual;

        // non-ui error detection methods

        function GetErrorCountString( CountString:String ):LongInt;
        function GetErrorCountWinControl( Control:TWinControl; CheckType:TCheckType ):LongInt;
        function GetErrorCountParser( Parser:TControlParser; CheckType:TCheckType ):LongInt;
        function ErrorsPresentInString( CountString:String ):Boolean;
        function ErrorsPresentInWinControl( Control:TWinControl; CheckType:TCheckType ):Boolean;
        function ErrorsPresentInParser( Parser:TControlParser; CheckType:TCheckType ):Boolean;

        // spell check processing methods

        procedure Check_Ignore; virtual;
        procedure Check_IgnoreAll; virtual;
        procedure Check_Change( const Word:String ); virtual;
        procedure Check_ChangeAll( const Word:String ); virtual;
        procedure Check_Add; virtual;
        procedure Check_AutoCorrect( const Word:String ); virtual;
        procedure Check_Undo; virtual;
        procedure Check_RepeatIgnore; virtual;
        procedure Check_RepeatDelete; virtual;
        procedure Check_ControlEdited; virtual;
        procedure Check_Help; virtual;
        procedure Check_Cancel; virtual;

        // word check methods

        function WordExistsInMain( const Word:String ):Boolean; virtual;
        function WordExists( const Word:String ):Boolean; virtual;
        function WordAcceptable( const Word:String ):Boolean; virtual;
        function WordExcluded( const Word:String ):Boolean; virtual;
        function WordHasCorrection( const Word:String; var Correction:String ):Boolean; virtual;

        // suggestions methods

        procedure Suggest( const Word:String; Words:TStrings ); virtual;
        procedure LearnSuggestion( const MisspelledWord:String; const CorrectWord:String ); virtual;

        // live-spelling menu

        function ShowPopupMenu( Sender:TObject; Options:TSpellPopupOptions;
                                XPos, YPos:Integer; var Text:String ):TSpellPopupOption; virtual;

    published

        // published properties

        property ConfigStorage:TConfigStorage read FConfigStorage write WriteConfigStorage;
        property ConfigID:String read FConfigID write WriteConfigID;
        property ConfigFilename:String read FConfigFilename write WriteConfigFilename;
        property ConfigRegistryKey:String read FConfigRegistryKey write WriteConfigRegistryKey;
        property ConfigDictionaryDir:TStringList read FConfigDictionaryDir write WriteConfigDictionaryDir;
        property ConfigAvailableOptions:TSpellOptions read FAvailableOptions write FAvailableOptions;
        property ConfigUserOption1:String read FUserOption1 write FUserOption1;
        property ConfigUserOption2:String read FUserOption2 write FUserOption2;
        property ConfigUserOption3:String read FUserOption3 write FUserOption3;
        property ConfigUserOption4:String read FUserOption4 write FUserOption4;
        property ConfigUseMSWordCustom:Boolean read FMSWord write FMSWord;

        property ConfigDefaultMain:TStringList read FDefaultMain write WriteDefaultMain;
        property ConfigDefaultCustom:TStringList read FDefaultCustom write WriteDefaultCustom;
        property ConfigDefaultActiveCustom:String read FDefaultActiveCustom write FDefaultActiveCustom;
        property ConfigDefaultOptions:TSpellOptions read FDefaultOptions write FDefaultOptions;
        property ConfigDefaultUseMSWordCustom:Boolean read FDefaultMSWord write FDefaultMSWord;

        property HelpFile:String read FHelpFile write FHelpFile;
        property HelpCtxSpellDialog:THelpContext read FHelpCtxSpellDialog write FHelpCtxSpellDialog default 0;
        property HelpCtxConfigDialog:THelpContext read FHelpCtxConfigDialog write FHelpCtxConfigDialog default 0;
        property HelpCtxDictionariesDialog:THelpContext read FHelpCtxDictionariesDialog write FHelpCtxDictionariesDialog default 0;
        property HelpCtxDictionaryEditDialog:THelpContext read FHelpCtxDictionaryEditDialog write FHelpCtxDictionaryEditDialog default 0;

        property SuggestionsAutoReplace:Boolean read FLearnAutoCorrect write FLearnAutoCorrect;
        property SuggestionsLearning:Boolean read FLearnSuggestions write WriteLearnSuggestions;
        property SuggestionsLearningDict:String read FSuggestionsDictFN write WriteSuggestionsDictFN;
        property LiveSpelling:Boolean read FLiveSpelling;
        property LiveCorrect:Boolean read FLiveCorrect;
        property QuoteChars:String read FQuoteChars write WriteQuoteChars;
        property DialogInitialPos:TSpellDialogInitialPos read FInitialPos write FInitialPos;
        property DialogSelectionAvoid:TSpellDialogAvoidPos read FAvoidPos write FAvoidPos;
        property DialogShowImmediate:Boolean read FImmediateDialog write FImmediateDialog;
        property DialogShowModal:Boolean read FModalDialog write FModalDialog;
        property EndMessage:TSpellEndMessage read FEndMessage write FEndMessage;
        property EndCursorPosition:TSpellEndPosition read FEndPosition write FEndPosition;
        property EndMessageWordCount:Boolean read FEndMessageWordCount write FEndMessageWordCount;
        property MaxUndo:LongInt read FMaxUndo write FMaxUndo;
        property MaxSuggestions:LongInt read FMaxSuggestions write FMaxSuggestions;
        property KeepDictionariesActive:Boolean read FKeepDictionariesActive write WriteKeepDictionariesActive;
        property SynchronousCheck:Boolean read FProcessMessages write FProcessMessages;
        property UseHourglassCursor:Boolean read FUseHourglass write FUseHourglass;
        property CommandsVisible:TSpellDialogCommands read FCommandsVisible write FCommandsVisible;
        property CommandsEnabled:TSpellDialogCommands read FCommandsEnabled write FCommandsEnabled;
        property PhoneticSuggestions:Boolean read FUsePhoneticSuggetions write FUsePhoneticSuggetions;
        property PhoneticMaxDistance:Integer read ReadPhoneticMaxDistance write WritePhoneticMaxDistance;
        property PhoneticDivisor:Integer read ReadPhoneticDivisor write WritePhoneticDivisor;
        property PhoneticDepth:Integer read ReadPhoneticDepth write WritePhoneticDepth;
        property MappingDictionaryName:String read FMappingDictionary write WriteMappingDictionary;
        property MappingAutoReplace:Boolean read FMappingAutoReplace write FMappingAutoReplace;
        property UseExcludeWords:Boolean read FUseExclude write FUseExclude;
        property UseAutoCorrectFirst:Boolean read FUseAutoCorrectFirst write FUseAutoCorrectFirst;
        property RecheckReplacedWords:Boolean read FRecheckReplaced write FRecheckReplaced;
        property ResumeFromLastPosition:Boolean read FResumeFromLastPosition write FResumeFromLastPosition;
        property AllowedCases:TCaseModification read FAllowedCases write FAllowedCases;


        property UILanguage:TSpellLanguageType read FUILanguage write FUILanguage;
        property UIType:TSpellUI read FSpellUIType write FSpellUIType;

        property Version:String read ReadVersion write WriteVersion stored false;

        // events

        //#<Events>
        property OnConfigChanged:TNotifyEvent read FOnConfigChanged write FOnConfigChanged;
        property OnConfigLoaded:TNotifyEvent read FOnConfigLoaded write FOnConfigLoaded;
        property OnConfigSaved:TNotifyEvent read FOnConfigSaved write FOnConfigSaved;
        property OnConfigReadString:TReadStringEvent read FOnConfigReadString write FOnConfigReadString;
        property OnConfigWriteString:TWriteStringEvent read FOnConfigWriteString write FOnConfigWriteString;
        property OnDictionariesChanged:TNotifyEvent read FOnDictionariesChanged write FOnDictionariesChanged;
        property OnWordCheck:TWordCheckEvent read FOnWordCheck write FOnWordCheck;
        property OnPromptWord:TWordPromptEvent read FOnDialogWord write FOnDialogWord;
        property OnCreateSpellDialog:TCustomSpellDialogEvent read FOnCreateSpellDialog write FOnCreateSpellDialog;
        property OnShowConfigDialog:TModalDialogEvent read FOnShowConfigDialog write FOnShowConfigDialog;
        property OnShowCustomDictionariesDialog:TModalDialogEvent read FOnShowCustomDialog write FOnShowCustomDialog;
        property OnShowEditCustomDictionaryDialog:TModalDictEditEvent read FOnShowEditDialog write FOnShowEditDialog;
        property OnShowAddDictionaryDir:TModalDialogEvent read FOnShowAddDictionaryDir write FOnShowAddDictionaryDir;
        property OnGetString:TGetStringEvent read FOnGetString write FOnGetString;
        property OnAddCustomIgnore:TNotifyEvent read FOnAddCustomIgnore write FOnAddCustomIgnore;
        property OnSpellDialogShow:TNotifyEvent read FOnSpellDialogShow write FOnSpellDialogShow;
        property OnSpellDialogHide:TNotifyEvent read FOnSpellDialogHide write FOnSpellDialogHide;
        property OnPositionDialog:TNotifyEvent read FOnPositionDialog write FOnPositionDialog;
        property OnShowEndMessage:TNotifyEvent read FOnShowEndMessage write FOnShowEndMessage;
        property OnCompleteCheck:TNotifyEvent read FOnCompleteCheck write FOnCompleteCheck;
        property OnDialogDeactivate:TNotifyEvent read FOnDialogDeactivate write FOnDialogDeactivate;
        property OnDialogActivate:TNotifyEvent read FOnDialogActivate write FOnDialogActivate;
        property OnAdjustPhoneticsMap:TNotifyEvent read FOnAdjustPhoneticsMap write FOnAdjustPhoneticsMap;
        property OnParserReplaceWord:TReplaceWordEvent read FOnParserReplaceWord write FOnParserReplaceWord;
        property OnParserIgnoreWord:TIgnoreWordEvent read FOnParserIgnoreWord write FOnParserIgnoreWord;
        property OnParserUndoLast:TUndoLastEvent read FOnParserUndoLast write FOnParserUndoLast;
        property OnBeforeChange:TNotifyEvent read FOnBeforeChange write FOnBeforeChange;
        property OnCreateCustomDictionary:TCreateCustomDictEvent read FOnCreateCustomDict write FOnCreateCustomDict;
        property OnPopupDoMenu:TPopupDoMenuEvent read FOnPopupDoMenu write FOnPopupDoMenu;
        property OnPopupAddMenuItem:TPopupAddMenuItemEvent read FOnPopupAddMenuItem write FOnPopupAddMenuItem;
        property OnPopupCreateMenu:TPopupCreateMenuEvent read FOnPopupCreateMenu write FOnPopupCreateMenu;
        property OnPopupResult:TPopupResultEvent read FOnPopupResult write FOnPopupResult;
        property OnCaseModification:TCaseModificationEvent read FOnCaseModification write FOnCaseModification;

        //#</Events>
    end;

implementation

uses
    registry,
    ShlObj;

const
    KFrenchLanguage         = $000c;
    EnglishLanguage         = $0009;

type
    TAddictUndo = class(TObject)
    public
        FXPos           :LongInt;
        FYPos           :LongInt;
        FWord           :String;
        FReplacement    :String;
        FAction         :TSpellAction;
        FAutomatic      :Boolean;
        FData           :LongInt;
    end;



//************************************************************
// AddictSpell Component
//************************************************************

constructor TAddictSpell3Base.Create( AOwner:TComponent );
begin
    inherited Create(AOwner);

    FInternalCustom         := TCustomDictionary.Create;
    FSuggestions            := TSuggestionsGenerator.Create;
    FPhoneticsMap           := TPhoneticsMap.Create;

    FParsingEngine                  := TMainParsingEngine.Create;
    FParsingEngine.OnInlineIgnore   := RunInlineIgnore;
    FParsingEngine.OnPreCheckIgnore := RunPreCheckIgnore;

    FParser                 := nil;

    FBeforeChangeFired      := False;
    FChecking               := False;
    FCanceled               := False;
    FWord                   := '';

    FOldOptions             := [];
    FPrimaryOnly            := False;
    FRepeated               := True;
    FDUalCaps               := True;
    FLiveSpelling           := True;
    FLiveCorrect            := True;

    FMainDictionaries       := TObjectList.Create;
    FCustomDictionaries     := TObjectList.Create;
    FMSWordDictionaries     := TObjectList.Create;
    FActiveCustom           := nil;
    FMappingCustom          := nil;
    FLearningCustom         := nil;

    FIgnoreEntries          := TList.Create;
    FIgnoreEntriesPost      := TObjectList.Create;
    FIgnoreEntriesLine      := TList.Create;

    FAllowPossessive        := False;
    FAllowSoundexFollowup   := True;

    FUILanguage             := ltEnglish;

    FSpellUIType            := suiSilent;
    FUseExclude             := true;
    FUseAutoCorrectFirst    := false;
    FRecheckReplaced        := true;
    FDialogForm             := nil;
    FDialogCtrl             := nil;
    FDialogShown            := False;
    FWordCount              := 0;
    FOptimizeCount          := 100;
    FUndoList               := TObjectList.Create;
    FCheckingSequence       := False;
    FMergedDictionaryDir    := TStringList.Create;

    FHelpFile                       := '';
    FHelpCtxSpellDialog             := 0;
    FHelpCtxConfigDialog            := 0;
    FHelpCtxDictionariesDialog      := 0;
    FHelpCtxDictionaryEditDialog    := 0;

    FConfiguration              := TAddictConfig.Create;
    FConfiguration.AddictSpell  := Self;

    FConfigAvailableMain    := TStringList.Create;
    FConfigAvailableCustom  := TStringList.Create;
    FConfigAvailableMSWord  := TStringList.Create;

    FConfigStorage          := csRegistry;
    FConfigID               := '%UserName%';

    FConfigFilename         := '%AppDir%\Spell.cfg';
    FConfigRegistryKey      := 'Software\Addictive Software\%AppName%';
    FConfigDictionaryDir    := TStringList.Create;
    FConfigDictionaryDir.Add( '%AppDir%' );
    FConfigDictionaryDir.OnChange := NotifyDictionariesPathChanged;
    FMergedDictionaryDir.Assign( FConfigDictionaryDir );
    FAvailableOptions       := [ soUpcase, soNumbers, soPrimaryOnly, soRepeated, soDUalCaps ];
    FUserOption1            := '';
    FUserOption2            := '';
    FUserOption3            := '';
    FUserOption4            := '';
    FMSWord                 := True;
    FMappingDictionary      := '';
    FMappingAutoReplace     := True;

    FDefaultMain            := TStringList.Create;
    FDefaultMain.Add( 'American.adm' );
    FDefaultCustom          := TStringList.Create;
    FDefaultActiveCustom    := '%ConfigID%.adu';
    FDefaultOptions         := [ soAbbreviations, soRepeated, soDUalCaps, soInternet, soLiveSpelling, soLiveCorrect ];

    FOldOnShow              := nil;
    FOldOnActivate          := nil;
    FOldOnDeactivate        := nil;

    FOldCloseDialog         := False;
    FOldKeepActive          := False;

    FLastWord               := '';
    FExecutingRepeat        := False;

    FPopupShowing           := False;
    FPopupAction            := 0;
    FPopupWord              := '';

    FQuoteChars             := '>';
    FInitialPos             := ipLastUserPos;
    FAvoidPos               := saAvoid;
    FEndMessage             := emExceptCancel;
    FEndPosition            := epOriginal;
    FEndMessageWordCount    := False;
    FMaxUndo                := -1;
    FMaxSuggestions         := -1;
    FKeepDictionariesActive := False;
    FProcessMessages        := True;
    FUseHourglass           := True;
    FUsePhoneticSuggetions  := True;
    FCommandsVisible        := [ sdcIgnore, sdcIgnoreAll, sdcChange, sdcChangeAll, sdcAdd, sdcAutoCorrect,
                                sdcUndo, sdcHelp, sdcCancel, sdcOptions, sdcCustomDictionary, sdcCustomDictionaries,
                                sdcConfigOK, sdcAddedEdit, sdcAutoCorrectEdit, sdcExcludedEdit, sdcInternalEdit,
                                sdcMainDictFolderBrowse, sdcResetDefaults ];
    FCommandsEnabled        := [ sdcIgnore, sdcIgnoreAll, sdcChange, sdcChangeAll, sdcAdd, sdcAutoCorrect,
                                sdcUndo, sdcHelp, sdcCancel, sdcOptions, sdcCustomDictionary, sdcCustomDictionaries,
                                sdcConfigOK, sdcAddedEdit, sdcAutoCorrectEdit, sdcExcludedEdit, sdcInternalEdit,
                                sdcMainDictFolderBrowse, sdcResetDefaults ];
    FLearnSuggestions       := True;
    FLearnAutoCorrect       := False;
    FSuggestionsDictFN      := '%AppDir%\%UserName%_sp.adl';
    FResumeFromLastPosition := True;
    FAllowedCases           := cmInitialCapsOrUpcase;

    FImmediateDialog        := False;
    FCloseDialog            := True;
    FFreeParser             := True;

    FOnConfigChanged        := nil;
    FOnConfigLoaded         := nil;
    FOnConfigSaved          := nil;
    FOnConfigReadString     := nil;
    FOnConfigWriteString    := nil;
    FOnDictionariesChanged  := nil;
    FOnWordCheck            := nil;
    FOnDialogWord           := nil;
    FOnCreateSpellDialog    := nil;
    FOnShowConfigDialog     := nil;
    FOnShowCustomDialog     := nil;
    FOnShowEditDialog       := nil;
    FOnShowAddDictionaryDir := nil;
    FOnGetString            := nil;
    FOnAddCustomIgnore      := nil;
    FOnSpellDialogShow      := nil;
    FOnSpellDialogHide      := nil;
    FOnPositionDialog       := nil;
    FOnShowEndMessage       := nil;
    FOnCompleteCheck        := nil;
    FOnDialogDeactivate     := nil;
    FOnDialogActivate       := nil;
    FOnAdjustPhoneticsMap   := nil;
    FOnParserReplaceWord    := nil;
    FOnParserIgnoreWord     := nil;
    FOnParserUndoLast       := nil;
    FOnBeforeChange         := nil;
    FOnCreateCustomDict     := nil;
    FOnPopupDoMenu          := nil;
    FOnPopupAddMenuItem     := nil;
    FOnPopupCreateMenu      := nil;
    FOnPopupResult          := nil;
    FOnCaseModification     := nil;

    FOnAddCustomIgnoreList  := TEventList.Create;
    FOnConfigChangedList    := TEventList.Create;
    FOnParserIgnoreWordList := TParserIgnoreWordEventList.Create;
    FOnPopupResultList      := TPopupResultEventList.Create;

    CheckTrialVersion;
end;

//************************************************************

destructor TAddictSpell3Base.Destroy;
begin
    FInternalCustom.Free;
    FSuggestions.Free;
    FPhoneticsMap.Free;

    FParsingEngine.Free;

    FMainDictionaries.Free;
    FCustomDictionaries.Free;
    FMSWordDictionaries.Free;
    if (assigned(FActiveCustom)) then
    begin
        FActiveCustom.Free;
    end;
    if (assigned(FMappingCustom)) then
    begin
        FMappingCustom.Free;
    end;
    if (assigned(FLearningCustom)) then
    begin
        FLearningCustom.Free;
    end;        

    FIgnoreEntries.Free;
    FIgnoreEntriesPost.Free;
    FIgnoreEntriesLine.Free;

    FConfiguration.Free;

    FUndoList.Free;
    FMergedDictionaryDir.Free;

    FConfigAvailableMain.Free;
    FConfigAvailableCustom.Free;
    FConfigAvailableMSWord.Free;

    FConfigDictionaryDir.Free;

    FDefaultMain.Free;
    FDefaultCustom.Free;

    FOnAddCustomIgnoreList.Free;
    FOnConfigChangedList.Free;
    FOnParserIgnoreWordList.Free;
    FOnPopupResultList.Free;

    inherited Destroy;
end;




//************************************************************
// Property Read/Write functions
//************************************************************

procedure TAddictSpell3Base.WriteParsingEngine( NewEngine:TParsingEngine );
begin
    if (Assigned(NewEngine)) then
    begin
        FParsingEngine.Free;
        FParsingEngine := NewEngine;

        FParsingEngine.OnInlineIgnore   := RunInlineIgnore;
        FParsingEngine.OnPreCheckIgnore := RunPreCheckIgnore;

        ResynchOptions( True );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.WriteSuggestions( NewSuggestions:TSuggestionsGenerator );
begin
    if (Assigned( NewSuggestions )) then
    begin
        FSuggestions.Free;
        FSuggestions    := NewSuggestions;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.WritePhoneticsMap( NewPhonetics:TPhoneticsMap );
begin
    if (Assigned( NewPhonetics )) then
    begin
        FPhoneticsMap.Free;
        FPhoneticsMap   := NewPhonetics;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.WriteConfigStorage( NewStorage:TConfigStorage );
begin
    FConfigStorage := NewStorage;
    FConfiguration.ReloadConfiguration;
end;

//************************************************************

procedure TAddictSpell3Base.WriteConfigID( const NewID:String );
begin
    FConfigID := NewID;
    FConfiguration.ReloadConfiguration;
end;

//************************************************************

procedure TAddictSpell3Base.WriteConfigFilename( const NewFilename:String );
begin
    FConfigFilename := NewFilename;
    if (FConfigStorage = csFile) then
    begin
        FConfiguration.ReloadConfiguration;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.WriteConfigRegistryKey( const NewKey:String );
begin
    FConfigRegistryKey := NewKey;
    if (FConfigStorage = csRegistry) then
    begin
        FConfiguration.ReloadConfiguration;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.WriteConfigDictionaryDir( NewList:TStringList );
begin
    FConfigDictionaryDir.Assign( NewList );

    FMergedDictionaryDir.Assign( FConfigDictionaryDir );
    if (FConfiguration.Loaded) then
    begin
        FMergedDictionaryDir.AddStrings( FConfiguration.NewDictionaryPaths );
    end;

    FConfigAvailableMain.Clear;
    FConfigAvailableCustom.Clear;
    FConfigAvailableMSWord.Clear;
end;

//************************************************************

procedure TAddictSpell3Base.WriteDefaultMain( NewList:TStringList );
begin
    FDefaultMain.Assign( NewList );
end;

//************************************************************

procedure TAddictSpell3Base.WriteDefaultCustom( NewList:TStringList );
begin
    FDefaultCustom.Assign( NewList );
end;

//************************************************************

procedure TAddictSpell3Base.WriteQuoteChars( NewChars:String );
begin
    FQuoteChars := NewChars;
    ResynchOptions( True );
end;

//************************************************************

procedure TAddictSpell3Base.WriteKeepDictionariesActive( Active:Boolean );
begin
    FKeepDictionariesActive := Active;
    if (not FKeepDictionariesActive) then
    begin
        UnloadDictionaries;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.WritePhoneticMaxDistance( NewDistance:Integer );
begin
    FPhoneticsMap.DistanceMax := NewDistance;
end;

//************************************************************

procedure TAddictSpell3Base.WritePhoneticDivisor( NewDivisor:Integer );
begin
    FPhoneticsMap.DistanceDivisor := NewDivisor;
end;

//************************************************************

procedure TAddictSpell3Base.WritePhoneticDepth( NewDepth:Integer );
begin
    FPhoneticsMap.StartDepth := NewDepth;
end;

//************************************************************

procedure TAddictSpell3Base.WriteMappingDictionary( NewMappingDict:String );
begin
    if (NewMappingDict <> FMappingDictionary) then
    begin
        FMappingDictionary  := NewMappingDict;

        if (assigned( FMappingCustom )) then
        begin
            FMappingCustom.Free;
            FMappingCustom := nil;
        end;

        // If we've already got dictionaries open, then we'll
        // have to reload to get ourselves loaded... normally
        // this property is only set at design time, so this isn't
        // a big concern.

        if (FMainDictionaries.Count > 0) then
        begin
            ReloadDictionaries;
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.WriteLearnSuggestions( NewValue:Boolean );
begin
    if (FLearnSuggestions <> NewValue) then
    begin
        if (assigned(FLearningCustom)) then
        begin
            FLearningCustom.Free;
            FLearningCustom := nil;
        end;

        FLearnSuggestions := NewValue;

        if (FLearnSuggestions) and (Configuration.Loaded) then
        begin
            ReloadDictionaries;
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.WriteSuggestionsDictFN( NewFilename:String );
begin
    if (NewFilename <> FSuggestionsDictFN) then
    begin
        FSuggestionsDictFN := NewFilename;

        if assigned(FLearningCustom) and (FLearnSuggestions) then
        begin
            FLearningCustom.Free;
            FLearningCustom := nil;

            ReloadDictionaries;
        end;
    end;
end;

//************************************************************

function TAddictSpell3Base.ReadAvailableMain:TStringList;
begin
    if (FConfigAvailableMain.Count = 0) then
    begin
        GetAvailableDictionaries( 'adm', FConfigAvailableMain );
    end;
    Result := FConfigAvailableMain;
end;

//************************************************************

function TAddictSpell3Base.ReadAvailableCustom:TStringList;
begin
    if (FConfigAvailableCustom.Count = 0) then
    begin
        GetAvailableDictionaries( 'adu', FConfigAvailableCustom );

        // We also need to determine if the user's Default dictionary
        // should be added to the list...  (it may not have been written
        // yet if there isn't an entry...)

        if (FConfiguration.ActiveCustomDictionary <> '') then
        begin
            if (-1 = FConfigAvailableCustom.IndexOf( FConfiguration.ActiveCustomDictionary )) then
            begin
                FConfigAvailableCustom.Insert( 0, FConfiguration.ActiveCustomDictionary );
            end;
        end;
    end;
    Result := FConfigAvailableCustom;
end;

//************************************************************

function TAddictSpell3Base.ReadAvailableMSWordCustom:TStringList;
var
    Reg     :TRegistry;
    Index   :LongInt;
    Path    :String;
    Hive    :Integer;
begin
    if (FConfigAvailableMSWord.Count = 0) then
    begin
        Reg := TRegistry.Create;
        try
            for Hive := 1 to 2 do
            begin
                case Hive of
                1: Reg.RootKey := HKEY_CURRENT_USER;
                2: Reg.RootKey := HKEY_LOCAL_MACHINE;
                end;

                if (Reg.OpenKeyReadOnly( 'Software\Microsoft\Shared Tools\Proofing Tools\Custom Dictionaries' )) then
                begin
                    Index   := 1;
                    Path    := Reg.ReadString( IntToStr(Index) );
                    while (Path <> '') do
                    begin
                        if (pos( '\', Path ) <= 0) then
                        begin
                            Path := GetSpecialFolder( CSIDL_APPDATA ) + '\Microsoft\Proof\' + Path;
                        end;

                        if (FileExists( Path )) then
                        begin
                            FConfigAvailableMSWord.Add( Path );
                        end;

                        inc(Index);
                        Path    := Reg.ReadString( IntToStr(Index) );
                    end;
                end;
                Reg.CloseKey;
            end;
        finally
            Reg.Free;
        end;
    end;

    Result := FConfigAvailableMSWord;
end;

//************************************************************

function TAddictSpell3Base.ReadCanUndo:Boolean;
begin
    Result := (FUndoList.Count > 0);
end;

//************************************************************

function TAddictSpell3Base.ReadPhoneticMaxDistance:Integer;
begin
    Result := FPhoneticsMap.DistanceMax;
end;

//************************************************************

function TAddictSpell3Base.ReadPhoneticDivisor:Integer;
begin
    Result := FPhoneticsMap.DistanceDivisor;
end;

//************************************************************

function TAddictSpell3Base.ReadPhoneticDepth:Integer;
begin
    Result := FPhoneticsMap.StartDepth;
end;

//************************************************************

function TAddictSpell3Base.ReadVersion:String;
begin
    Result := GetAddictVersion;
end;

//************************************************************

procedure TAddictSpell3Base.WriteVersion( NewVersion:String );
begin
end;

//************************************************************

function TAddictSpell3Base.ReadTextPrimaryLanguage:DWORD;
begin
    if (FMainDictionaries.Count > 0) then
    begin
        Result := TMainDictionary(FMainDictionaries[0]).Language;
    end
    else
    begin
        Result := 0;
    end;
end;





//************************************************************
// Dictionary Utility Functions
//************************************************************

function GetFilename( Path:String; Filename:String ):String;
begin
    Result := AdExcludeTrailingBackslash( Path ) + '\' + Filename;
end;

//************************************************************

function TAddictSpell3Base.ExpandVars( Path:String ):String;
begin
    Result := ExpandBasicVars( Path );
    Result := ExpandAddictVars( Result );
end;

//************************************************************

function TAddictSpell3Base.ExpandAddictVars( Path:String ):String;
begin
    Result := Path;
    Result := ReplaceString( '%ConfigID%', ExpandBasicVars(FConfigID), Result );
end;

//************************************************************

procedure TAddictSpell3Base.OptimizeMainDictionaryOrder;
var
    Index       :LongInt;
    BestMain    :TMainDictionary;
begin
    if (FMainDictionaries.Count > 1) then
    begin
        BestMain := TMainDictionary(FMainDictionaries[0]);
        for Index := 1 to FMainDictionaries.Count - 1 do
        begin
            if (TMainDictionary(FMainDictionaries[Index]).WordsFoundCount > BestMain.WordsFoundCount) then
            begin
                BestMain := TMainDictionary(FMainDictionaries[Index]);
            end;
        end;

        if (BestMain <> TMainDictionary(FMainDictionaries[0])) then
        begin
            FMainDictionaries.Extract( BestMain );
            FMainDictionaries.Insert( 0, BestMain );
        end;
    end;
    if (FMainDictionaries.Count > 0) then
    begin
        FSuggestions.Language := TMainDictionary(FMainDictionaries[0]).Language;
        if (FParsingEngine is TMainParsingEngine) then
        begin
            (FParsingEngine as TMainParsingEngine).AllowFrenchExceptions := ((FSuggestions.Language and $00FF) = KFrenchLanguage);
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.ReloadDictionaries;
var
    Index       :LongInt;
    Main        :TMainDictionary;
    Custom      :TCustomDictionary;
begin
    FAllowPossessive    := False;
    FOptimizeCount      := 100;

    FMainDictionaries.Clear;
    for Index := 0 to FConfiguration.MainDictionaries.Count - 1 do
    begin
        Main := GetMainDictionary( FConfiguration.MainDictionaries[Index] );
        if (Assigned(Main)) then
        begin
            FMainDictionaries.Add( Main );

            if ((Main.Language and $00FF) = EnglishLanguage) then
            begin
                FAllowPossessive := True;
            end;
        end;
    end;

    FCustomDictionaries.Clear;
    for Index := 0 to FConfiguration.CustomDictionaries.Count - 1 do
    begin
        if (FConfiguration.ActiveCustomDictionary <> FConfiguration.CustomDictionaries[Index]) then
        begin
            Custom := GetCustomDictionary( FConfiguration.CustomDictionaries[Index] );
            if (Assigned(Custom)) then
            begin
                FCustomDictionaries.Add( Custom );
            end;
        end;
    end;

    FMSWordDictionaries.Clear;
    for Index := 0 to FConfiguration.MSWordCustomDictionaries.Count - 1 do
    begin
        Custom := GetMSWordCustomDictionary( FConfiguration.MSWordCustomDictionaries[Index] );
        if (Assigned(Custom)) then
        begin
            FMSWordDictionaries.Add( Custom );
        end;
    end;

    if (assigned(FActiveCustom)) then
    begin
        FActiveCustom.Free;
        FActiveCustom := nil;
    end;

    FActiveCustom := GetCustomDictionary( FConfiguration.ActiveCustomDictionary );

    if (not Assigned(FMappingCustom)) and (FMappingDictionary <> '') then
    begin
        FMappingCustom := GetCustomDictionary( FMappingDictionary );
    end;

    if (not Assigned(FLearningCustom)) and (FLearnSuggestions) then
    begin
        FLearningCustom := GetCustomDictionary( FSuggestionsDictFN );
    end;

    if (Assigned( FOnDictionariesChanged )) then
    begin
        FOnDictionariesChanged( Self );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.GetAvailableDictionaries( Ext:String; var DictionaryList:TStringList );
var
    FindResult  :Integer;
    SearchRec   :TSearchRec;
    Index       :LongInt;
    Match       :LongInt;
    FileName    :String;
begin
    FConfiguration.Loaded   := True;

    for Index := 0 to FMergedDictionaryDir.Count -1 do
    begin
        FindResult := FindFirst( ExpandVars( GetFilename( FMergedDictionaryDir[Index], '*.' + Ext ) ), faAnyFile, SearchRec );
        while (FindResult = 0) do
        begin
            DictionaryList.Add( SearchRec.Name );
            FindResult := FindNext( SearchRec );
        end;
        FindClose( SearchRec );
    end;

    // OK, if the user has somehow managed to get multiple dictionaries (of the
    // same name) into multiple directories that we look in, then we throw away
    // the duplicate filenames so as not to confuse the configuration.

    Index := 0;
    while (Index < DictionaryList.Count) do
    begin
        FileName := ExtractFilename(DictionaryList[Index]);

        Match   := Index + 1;
        while (Match < DictionaryList.Count) do
        begin
            if (FileName = ExtractFilename(DictionaryList[Match])) then
            begin
                DictionaryList.Delete( Match );
            end
            else
            begin
                INC( Match );
            end;
        end;

        INC( Index );
    end;
end;





//************************************************************
// Configuration object callbacks
//************************************************************

procedure TAddictSpell3Base.FireConfigurationChanged( DictionaryChange:Boolean );
var
    OldActiveCustom   :String;
begin
    FMergedDictionaryDir.Assign( FConfigDictionaryDir );
    FMergedDictionaryDir.AddStrings( FConfiguration.NewDictionaryPaths );

    FConfigAvailableMain.Clear;
    FConfigAvailableCustom.Clear;
    FConfigAvailableMSWord.Clear;

    if (DictionaryChange) then
    begin
        if (Assigned(FActiveCustom)) then
        begin
            OldActiveCustom   := FActiveCustom.Filename;
        end;

        ReloadDictionaries;

        // if the reload changed the active Custom dictionary, then we have to
        // dump the undo list, as undoing an 'Add' will no longer have the
        // intended effect.

        if (not Assigned(FActiveCustom)) or (FActiveCustom.Filename <> OldActiveCustom) then
        begin
            ResetUndo;
        end;
    end;

    ResynchOptions( False );

    if (Assigned( FOnConfigChanged )) then
    begin
        FOnConfigChanged( Self );
    end;
    FOnConfigChangedList.Notify( Self );
end;

//************************************************************

function TAddictSpell3Base.FireReadString( const ConfigID:String; const Key:String; const Default:String ):String;
begin
    Result := Default;
    if (Assigned( FOnConfigReadString )) then
    begin
        FOnConfigReadString( Self, ConfigID, Key, Default, Result );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.FireWriteString( const ConfigID:String; const Key:String; const Value:String );
begin
    if (Assigned( FOnConfigWriteString )) then
    begin
        FOnConfigWriteString( Self, ConfigID, Key, Value );
    end
end;

//************************************************************

procedure TAddictSpell3Base.FireConfigLoaded;
begin
    if (Assigned( FOnConfigLoaded )) then
    begin
        FOnConfigLoaded( Self );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.FireConfigSaved;
begin
    if (Assigned( FOnConfigSaved )) then
    begin
        FOnConfigSaved( Self );
    end;
end;



//************************************************************
// public dictionary methods
//************************************************************

procedure TAddictSpell3Base.EnableCustomDictionary( Filename:String; Enabled:Boolean );
var
    Index               :LongInt;
    CustomDictionary    :TCustomDictionary;
begin
    Index := FConfiguration.CustomDictionaries.IndexOf( Filename );
    if (Index >= 0) then
    begin
        // if we're trying to enable it, then there's no point... its
        // already enabled.

        if (Enabled) then
        begin
            exit;
        end;

        FConfiguration.CustomDictionaries.Delete( Index );

        // Make sure that we didn't just unload the ActiveCustomDictionary.  If
        // we did, then we'll try to auto-assume the next loaded dictionary.

        if (FConfiguration.ActiveCustomDictionary = Filename) then
        begin
            if (FConfiguration.CustomDictionaries.Count > 0) then
            begin
                FConfiguration.ActiveCustomDictionary := FConfiguration.CustomDictionaries[0];
            end
            else
            begin
                FConfiguration.ActiveCustomDictionary := '';
            end;
        end;
    end;

    if (Enabled) then
    begin
        // Verify that the dictionary is valid, and if it is then
        // go ahead and add it to the configuration list

        CustomDictionary := GetCustomDictionary( Filename );
        if (Assigned(CustomDictionary)) then
        begin
            FConfiguration.CustomDictionaries.Add( Filename );
            CustomDictionary.Free;
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.EnableWordDictionary( Filename:String; Enabled:Boolean );
var
    Index           :LongInt;
begin
    Index := FConfiguration.MSWordCustomDictionaries.IndexOf( Filename );
    if (Index >= 0) then
    begin
        // if we're trying to enable it, then there's no point... its
        // already enabled.

        if (Enabled) then
        begin
            exit;
        end;

        FConfiguration.MSWordCustomDictionaries.Delete( Index );
    end;

    if (Enabled) then
    begin
        // Verify that the dictionary is valid, and if it is then
        // go ahead and add it to the configuration list

        if (FileExists( Filename )) then
        begin
            FConfiguration.MSWordCustomDictionaries.Add( Filename );
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.RemoveCustomDictionary( Filename:String );
var
    CustomDictionary  :TCustomDictionary;
begin
    EnableCustomDictionary( Filename, False );

    FConfigAvailableCustom.Clear;

    CustomDictionary := GetCustomDictionary( Filename );
    if (Assigned(CustomDictionary)) then
    begin
        if (FileExists( CustomDictionary.Filename )) then
        begin
            DeleteFile( CustomDictionary.Filename );
        end;
        CustomDictionary.Free;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.CreateNewCustomDictionary( Filename:String );
var
    CustomDictionary  :TCustomDictionary;
begin
    Filename            := ChangeFileExt( ExtractFileName(Filename), '.adu' );
    CustomDictionary    := GetCustomDictionary( Filename );

    if (Assigned(CustomDictionary)) then
    begin
        CustomDictionary.Modified := True;
        CustomDictionary.Save;
        CustomDictionary.Free;

        if (FConfiguration.CustomDictionaries.IndexOf( Filename ) = -1) then
        begin
            FConfiguration.CustomDictionaries.Add( Filename );
        end;
        FConfigAvailableCustom.Clear;
    end;
end;

//************************************************************

function TAddictSpell3Base.RenameCustomDictionary( OldFilename:String; NewFilename:String ):Boolean;
var
    CustomList          :TStringList;
    Index               :LongInt;
    CustomDictionary    :TCustomDictionary;
    NewFullFilename     :String;
begin
    Result      := False;
    CustomList  := ConfigAvailableCustom;

    if (OldFilename = NewFilename) or (not(Assigned(CustomList))) then
    begin
        exit;
    end;

    Index := CustomList.IndexOf( OldFilename );
    if (Index >= 0) then
    begin
        CustomDictionary := GetCustomDictionary( CustomList[Index] );
        if (Assigned(CustomDictionary)) then
        begin
            if (CustomDictionary.Filename <> '') then
            begin
                NewFullFilename := ExtractFilePath(CustomDictionary.Filename) + ChangeFileExt( NewFilename, '.adu' );
                if (not(FileExists(NewFullFilename))) and (CanFileBeWritten( NewFullFilename, true )) then
                begin
                    CustomDictionary.Modified := True;
                    CustomDictionary.Save;

                    RenameFile( CustomDictionary.Filename, NewFullFilename );

                    Index := FConfiguration.CustomDictionaries.IndexOf( OldFilename );
                    if (Index >= 0) then
                    begin
                        FConfiguration.CustomDictionaries.Delete( Index );
                        FConfiguration.CustomDictionaries.Add( NewFilename );
                    end;
                    if (FConfiguration.ActiveCustomDictionary = OldFilename) then
                    begin
                        FConfiguration.ActiveCustomDictionary := NewFilename;
                    end;

                    FConfigAvailableCustom.Clear;

                    Result := True;
                end;
            end;
            CustomDictionary.Free;
        end;
    end;
end;

//************************************************************

function TAddictSpell3Base.GetMainDictionary( Filename:String ):TMainDictionary;
var
    TempFilename    :String;
    Loop            :Integer;
begin
    Result := TMainDictionary.Create;
    if (Assigned(Result)) then
    begin
        if (Pos('\',Filename) > 0) then
        begin
            Filename := ExpandVars( Filename );
            Result.Filename := Filename;
        end
        else
        begin
            for Loop := 0 to FMergedDictionaryDir.Count - 1 do
            begin
                TempFilename := ExpandVars( GetFilename( FMergedDictionaryDir[Loop], Filename ) );
                Result.Filename := TempFilename;
                if (Result.Filename = TempFilename) then
                begin
                    Filename := Result.Filename;
                    Break;
                end;
            end;
        end;

        if (Result.Filename <> Filename) then
        begin
            Result.Free;
            Result := nil;
        end;
    end;
end;

//************************************************************

function TAddictSpell3Base.GetCustomDictionary( Filename:String ):TCustomDictionary;
var
    TempFilename    :String;
    Loop            :LongInt;
    Found           :Boolean;
begin
    Result := nil;
    if (Assigned( FOnCreateCustomDict )) then
    begin
        FOnCreateCustomDict( Self, Result );
    end;
    if (not(Assigned( Result ))) then
    begin
        Result := TCustomDictionary.Create;
    end;
    if (Assigned(Result)) then
    begin
        if (Pos('\',Filename) > 0) then
        begin
            Filename := ExpandVars( Filename );
            ADForceDirectories( ExtractFilePath(Filename) );
        end
        else
        begin
            Found := False;
            for Loop := 0 to FMergedDictionaryDir.Count - 1 do
            begin
                ADForceDirectories( ExpandVars(FMergedDictionaryDir[Loop]) );
                TempFilename := ExpandVars( GetFilename( FMergedDictionaryDir[Loop], Filename ) );
                if (FileExists(TempFilename)) then
                begin
                    Filename    := TempFilename;
                    Found       := True;
                    Break;
                end;
            end;
            if (not Found) and (FMergedDictionaryDir.Count > 0) then
            begin
                Filename := ExpandVars( GetFilename( FMergedDictionaryDir[0], Filename ) );
            end;
        end;

        // A request for a Custom dictionary that we already have loaded is not
        // necessarily a good thing...  we save the current state of the
        // dictionary so that the read will take the most up-to-date info.

        for Loop := 0 to FCustomDictionaries.Count - 1 do
        begin
            if (TCustomDictionary(FCustomDictionaries[Loop]).Filename = Filename) then
            begin
                TCustomDictionary(FCustomDictionaries[Loop]).Save;
            end;
        end;
        if Assigned(FActiveCustom) and(FActiveCustom.Filename = Filename) then
        begin
            FActiveCustom.Save;
        end;

        Result.Filename := Filename;
        if (Result.Filename <> Filename) then
        begin
            Result.Free;
            Result := nil;
        end;
    end;
end;

//************************************************************

function TAddictSpell3Base.GetMSWordCustomDictionary( Filename:String ):TCustomDictionary;
var
    WordList    :TStringList;
    Index       :LongInt;
begin
    Result := nil;

    if (FileExists( Filename )) then
    begin
        WordList    := TStringList.Create;
        try
            try
                WordList.LoadFromFile( Filename );
            except
                // If we got an exception, we'll just run with the empty
                // file... rather than failing this creation.
            end;

            Result  := TCustomDictionary.Create;

            for Index := 0 to WordList.Count - 1 do
            begin
                Result.AddIgnore( WordList[Index] );
            end;

        finally
            WordList.Free;
        end;
    end;
end;



//************************************************************
// setup utility routines
//************************************************************

function TAddictSpell3Base.SetupDialogControl( Dialog:TForm; CustomDictionary:TCustomDictionary ):TConfigurationDialogCtrl;
var
    Index   :LongInt;
begin
    Result := nil;
    for Index := 0 to Dialog.ComponentCount - 1 do
    begin
        if (Dialog.Components[Index] is TConfigurationDialogCtrl) then
        begin
            TConfigurationDialogCtrl(Dialog.Components[Index]).AddictSpell      := Self;
            TConfigurationDialogCtrl(Dialog.Components[Index]).CustomDictionary := CustomDictionary;
            Result := TConfigurationDialogCtrl(Dialog.Components[Index]);
            break;
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.ResynchOptions( ForceRefresh:Boolean );
var
    QuotedIgnore    :TQuotedLineIgnore;
begin
    if  (csReading in ComponentState) or
        (csDesigning in ComponentState) then
    begin
        Exit;
    end;

    if (FOldOptions <> FConfiguration.SpellOptions) or (ForceRefresh) then
    begin
        FOldOptions := FConfiguration.SpellOptions;

        ClearIgnoreList;

        if (soInternet in FConfiguration.SpellOptions) then
        begin
            AddIgnore( TURLIgnore.Create );
        end;
        if (soUpcase in FConfiguration.SpellOptions) then
        begin
            AddIgnore( TUppercaseWordIgnore.Create );
        end;
        if (soNumbers in FConfiguration.SpellOptions) then
        begin
            AddIgnore( TNumbersIgnore.Create );
        end;
        if (soHTML in FConfiguration.SpellOptions) then
        begin
            AddIgnore( THTMLIgnore.Create );
        end;
        if (soQuoted in FConfiguration.SpellOptions) then
        begin
            QuotedIgnore := TQuotedLineIgnore.Create;
            if (Assigned(QuotedIgnore)) then
            begin
                QuotedIgnore.QuoteChars := FQuoteChars;
                AddIgnore( QuotedIgnore );
            end;
        end;
        if (soAbbreviations in FConfiguration.SpellOptions) then
        begin
            AddIgnore( TAbbreviationsIgnore.Create );
        end;

        FPrimaryOnly    := (soPrimaryOnly in FConfiguration.SpellOptions);
        FRepeated       := (soRepeated in FConfiguration.SpellOptions);
        FDUalCaps       := (soDUalCaps in FConfiguration.SpellOptions);

        FLiveSpelling   := (soLiveSpelling in FConfiguration.SpellOptions);
        FLiveCorrect    := (soLiveCorrect in FConfiguration.SpellOptions);

        if (Assigned(FOnAddCustomIgnore)) then
        begin
            FOnAddCustomIgnore( Self );
        end;
        FOnAddCustomIgnoreList.Notify( Self );
    end;
end;



//************************************************************
// setup routines
//************************************************************

procedure TAddictSpell3Base.InternalSetup( AOwner:TComponent );
begin
    if (Assigned( FOnShowConfigDialog )) then
    begin
        FOnShowConfigDialog( Self, AOwner );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.InternalSetupCustomDictionaries( AOwner:TComponent );
begin
    if (Assigned( FOnShowCustomDialog )) then
    begin
        FOnShowCustomDialog( Self, AOwner );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.InternalEditCustomDictionary( AOwner:TComponent; CustomDictionary:TCustomDictionary );
begin
    if (Assigned( FOnShowEditDialog )) then
    begin
        FOnShowEditDialog( Self, AOwner, CustomDictionary );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.InternalSetupAddDictionaryDir( AOwner:TComponent );
begin
    if (Assigned( FOnShowAddDictionaryDir )) then
    begin
        FOnShowAddDictionaryDir( Self, AOwner );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Setup;
begin
    InternalSetup( Self );
end;

//************************************************************

procedure TAddictSpell3Base.SetupCustomDictionaries;
begin
    InternalSetupCustomDictionaries( Self );
end;

//************************************************************

procedure TAddictSpell3Base.EditCustomDictionary( CustomDictionary:TCustomDictionary );
begin
    InternalEditCustomDictionary( Self, CustomDictionary );
end;

//************************************************************

procedure TAddictSpell3Base.SetupAddDictionaryDir;
begin
    InternalSetupAddDictionaryDir( Self );
end;

//************************************************************

function TAddictSpell3Base.GetString( LanguageString:TSpellLanguageString ):String;
begin
    Result := ad3SpellLanguages.GetString( LanguageString, FUILanguage );
    if (Assigned(FOnGetString)) then
    begin
        FOnGetString( Self, LanguageString, Result );
    end;
end;



//************************************************************
// runtime routines
//************************************************************

procedure TAddictSpell3Base.ResetUndo;
begin
    FUndoList.Clear;
end;

//************************************************************

procedure TAddictSpell3Base.UnloadDictionaries;
var
    Index   :LongInt;
begin
    if (not FKeepDictionariesActive) and (not FChecking) then
    begin
        // Save the configuration if it's been modified...  (we won't unload
        // it however).

        FConfiguration.SaveConfiguration;

        // Unload all of the main and Custom dictionaries we have...

        for Index := 0 to FMainDictionaries.Count - 1 do
        begin
            TMainDictionary(FMainDictionaries[Index]).Loaded := False;
        end;

        if (assigned( FActiveCustom )) then
        begin
            FActiveCustom.Loaded := False;
        end;

        for Index := 0 to FCustomDictionaries.Count - 1 do
        begin
            TCustomDictionary(FCustomDictionaries[Index]).Loaded := False;
        end;

        if (assigned( FLearningCustom )) then
        begin
            FLearningCustom.Loaded := False;
        end;

        // We can't unload the MSWordCustom files or we'll lose them.
    end;
end;

//************************************************************

procedure TAddictSpell3Base.CloseSpellDialog;
begin
    ShutdownUI;
end;



//************************************************************
// Dialog Routines
//************************************************************

procedure TAddictSpell3Base.Form_OnShow( Sender:TObject );
begin
    if (FModalDialog) then
    begin
        if (FImmediateDialog) then
        begin
            ContinueCheck;
        end
        else
        begin
            DoWordPrompt;
        end;
    end;
    if (Assigned(FOldOnShow)) then
    begin
        FOldOnShow( Sender );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Form_OnDeactivate( Sender:TObject );
begin
    if (not FDeactivated) then
    begin
        FDeactivated    := True;

        if (Assigned(FOnDialogDeactivate)) then
        begin
            FOnDialogDeactivate( Self );
        end;
    end;
    if (Assigned(FOldOnDeactivate)) then
    begin
        FOldOnDeactivate( Sender );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Form_OnActivate( Sender:TObject );
begin
    if (Assigned(FOldOnActivate)) then
    begin
        FOldOnActivate( Sender );
    end;
    if (FDeactivated) then
    begin
        FDeactivated := False;

        if (Assigned(FOnDialogActivate)) then
        begin
            FOnDialogActivate( Self );
        end;

        // OK, so now we want to try to auto-resume the spell check

        Check_ControlEdited;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.DoWordPrompt;
begin
    OptimizeMainDictionaryOrder;
    
    if (Assigned(FDialogCtrl)) and (Assigned(FDialogCtrl.OnPromptWord)) then
    begin
        FDialogCtrl.OnPromptWord( Self, FWord, FExecutingRepeat );
    end;
    if (Assigned(FOnDialogWord)) then
    begin
        FOnDialogWord( Self, FWord, FExecutingRepeat );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.AdjustDialogToSelection( AdjustLeft:Boolean; AdjustTop:Boolean );
var
    Position    :TRect;
begin
    if (Assigned(FDialogForm)) and (Assigned(FParser)) then
    begin
        Position := Rect( 0, 0, 0, 0 );

        FParser.GetSelectionScreenPosition( Position );

        AdjustDialogToRect( FDialogForm, Position, AdjustLeft, AdjustTop );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.AdjustDialogToControl;
var
    Position    :TRect;
    NewLeft    :LongInt;
    NewTop     :LongInt;
begin
    if (Assigned(FDialogForm)) and (Assigned(FParser)) then
    begin
        Position := Rect(   FDialogForm.Monitor.Left, FDialogForm.Monitor.Top,
                            FDialogForm.Monitor.Left + FDialogForm.Monitor.Width,
                            FDialogForm.Monitor.Top + FDialogForm.Monitor.Height );

        FParser.GetControlScreenPosition( Position );

        if ((Position.Bottom + FDialogForm.Height) <= (FDialogForm.Monitor.Top + FDialogForm.Monitor.Height)) then
        begin
            NewLeft := Position.Left;
            NewTop  := Position.Bottom;
        end
        else if ((Position.Right + FDialogForm.Width) <= (FDialogForm.Monitor.Left + FDialogForm.Monitor.Width)) then
        begin
            NewLeft := Position.Right;
            NewTop  := Position.Top;
        end
        else if ((Position.Top - FDialogForm.Height) >= FDialogForm.Monitor.Top) then
        begin
            NewLeft := Position.Left;
            NewTop  := Position.Top - FDialogForm.Height;
        end
        else if ((Position.Left - FDialogForm.Width) >= FDialogForm.Monitor.Left) then
        begin
            NewLeft := Position.Left - FDialogForm.Width;
            NewTop  := Position.Top;
        end
        else
        begin
            // we couldn't avoid the control... we'll put ourselves under the
            // selection if there is one, else we'll just center outselves
            // inside of the control...

            if (not(FImmediateDialog)) then
            begin
                AdjustDialogToSelection( True, True );
                NewLeft := FDialogForm.Left;
                NewTop  := FDialogForm.Top;
            end
            else
            begin
                NewLeft := Position.Left + ((Position.Right - Position.Left) div 2) - (FDialogForm.Width div 2);
                NewTop  := Position.Top + ((Position.Bottom - Position.Top) div 2) - (FDialogForm.Height div 2);
            end;
        end;

        AdjustDialogPosition( FDialogForm, NewLeft, NewTop );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.SetInitialPosition;
begin
    if (Assigned(FDialogForm)) then
    begin
        case (FInitialPos) of
        ipScreenCenter:
            FDialogForm.Position := poScreenCenter;
{$IFDEF Delphi5AndAbove}
        ipDesktopCenter:
            FDialogForm.Position := poDesktopCenter;
{$ENDIF}
        ipUnderSelection:
            begin
                if (not(FImmediateDialog)) then
                begin
                    AdjustDialogToSelection( True, True );
                end;
            end;
        ipAvoidControl:
            begin
                AdjustDialogToControl;
            end;
        ipUserDefined:
            begin
                if (Assigned( FOnPositionDialog )) then
                begin
                    FOnPositionDialog(Self);
                end;
            end;
        ipLastUserPos:
            begin
                if (Configuration.DialogX = -1) then
                begin
                    AdjustDialogToControl;
                end
                else
                begin
                    AdjustDialogPosition( FDialogForm, Configuration.DialogX, Configuration.DialogY );
                end;
            end;
        ipIgnore:
            FDialogForm.Position := poDefaultPosOnly;
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.AvoidSelection;
var
    SelPos          :TRect;
    DialogPos       :TRect;
    TempPos         :TRect;
    OverSelection   :Boolean;
begin
    if (Assigned(FDialogForm)) then
    begin
        SelPos := Rect( 0, 0, 0, 0 );
        FParser.GetSelectionScreenPosition( SelPos );

        DialogPos := Rect(  FDialogForm.Left, FDialogForm.Top,
                            FDialogForm.Left + FDialogForm.Width, FDialogForm.Top + FDialogForm.Height );

        OverSelection := IntersectRect( TempPos, SelPos, DialogPos );

        case FAvoidPos of
        saAvoid:
            begin
                if (OverSelection) then
                begin
                    AdjustDialogToSelection( True, True );
                end;
            end;
        saAvoidUpDown:
            begin
                if (OverSelection) then
                begin
                    AdjustDialogToSelection( False, True );
                end;
            end;
        saMove:
            AdjustDialogToSelection( True, True );
        saMoveUpDown:
            AdjustDialogToSelection( False, True );
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.CreateSpellDialog;
begin
    FDialogForm := nil;
end;

//************************************************************

procedure TAddictSpell3Base.EnsureUI;
var
    DoModal :Boolean;
begin
    if (FSpellUIType = suiDialog) then
    begin
        DoModal := False;

        if (not Assigned(FDialogCtrl)) then
        begin
            FDeactivated := False;

            // Create the dialog .. (user or default)

            if (not(Assigned(FDialogForm))) then
            begin
                if (Assigned( FOnCreateSpellDialog )) then
                begin
                    FOnCreateSpellDialog( Self, FDialogForm, True );
                end
                else
                begin
                    CreateSpellDialog;

                    if (Assigned( FDialogForm )) then
                    begin
                        FDialogForm.HelpFile    := FHelpFile;
                        FDialogForm.HelpContext := FHelpCtxSpellDialog;
                    end;
                end;
            end;

            // Now find the dialog control component

            if (Assigned( FDialogForm )) then
            begin
                FDialogCtrl         := SetupDialogControl( FDialogForm, nil );
            end;
        end;

        // This is the per-check initialization.  This happens, every time a
        // new spell check is started, regardless of whether or not the dialog
        // is closed between sessions.

        if (not( FDialogShown )) then
        begin
            FDialogShown := True;

            if (Assigned(FOnSpellDialogShow)) then
            begin
                FOnSpellDialogShow( Self );
            end;

            SetInitialPosition;

            if (Assigned(FDialogForm)) then
            begin
                if (not(FModalDialog)) then
                begin
                    FDialogForm.Visible := True;
                end
                else
                begin
                    DoModal             := True;
                end;

                FOldOnShow                  := FDialogForm.OnShow;
                FDialogForm.OnShow          := Form_OnShow;
                FOldOnDeactivate            := FDialogForm.OnDeactivate;
                FDialogForm.OnDeactivate    := Form_OnDeactivate;
                FOldOnActivate              := FDialogForm.OnActivate;
                FDialogForm.OnActivate      := Form_OnActivate;
            end;
        end;

        // This is a per-item initialization.  This happens whenever a word is
        // selected in the spell check dialog for some action...

        AvoidSelection;

        // Delayed modal launch
        
        if (DoModal) then
        begin
            FDialogForm.ShowModal;
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.ShutdownUI;
begin
    if (Assigned( FDialogForm )) then
    begin
        // Save the last position if we need to...

        if (FInitialPos = ipLastUserPos) then
        begin
            Configuration.DialogX   := FDialogForm.Left;
            Configuration.DialogY   := FDialogForm.Top;
        end;

        // If we're supposed to close the dialog, then continue
        // with this operation...

        if (FCloseDialog) or (FModalDialog) then
        begin
            FDialogShown        := False;

            FDialogForm.OnShow          := FOldOnShow;
            FOldOnShow                  := nil;
            FDialogForm.OnDeactivate    := FOldOnDeactivate;
            FOldOnDeactivate            := nil;
            FDialogForm.OnActivate      := FOldOnActivate;
            FOldOnActivate              := nil;

            if (FModalDialog) then
            begin
                FDialogForm.ModalResult := mrOK;
            end
            else
            begin
                FDialogForm.Visible := False;
            end;

            if (Assigned(FOnSpellDialogHide)) then
            begin
                FOnSpellDialogHide( Self );
            end;

            FDialogCtrl         := nil;

            // Free the dialog .. (user or default)

            if (Assigned( FOnCreateSpellDialog )) then
            begin
                FOnCreateSpellDialog( Self, FDialogForm, False );
            end
            else
            begin
                FDialogForm.Release;
            end;
            FDialogForm         := nil;
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.ShowEndMessage;
var
    ShowMessage :Boolean;
    MessageText :String;
begin
    if (FSpellUIType = suiDialog) then
    begin
        ShowMessage := False;

        case FEndMessage of
        emAlways:
            ShowMessage := True;
        emExceptCancel:
            begin
                if (not(FCanceled)) then
                begin
                    ShowMessage := True;
                end;
            end;
        emNoDialog:
            begin
                if (FDialogShown) then
                begin
                    ShowMessage := True;
                end;
            end;
        end;

        if ShowMessage and not(FCheckingSequence) then
        begin
            if (FCloseDialog) and (Assigned(FDialogForm)) then
            begin
                FDialogForm.Visible := False;
            end;

            if (Assigned(FOnShowEndMessage)) then
            begin
                FOnShowEndMessage( Self );
            end
            else
            begin
                MessageText := GetString(lsEndMessage);
                if (FEndMessageWordCount) then
                begin
                    MessageText := MessageText + #13#10#13#10 + GetString(lsWordsChecked) + ' ' + IntToStr(WordCount);
                end;

                Application.MessageBox( PChar(MessageText),
                                        PChar(GetString(lsSpelling)),
                                        MB_OK or MB_ICONINFORMATION );
            end;
        end;
    end;
end;


//************************************************************
// Event Firing Utility Functions
//************************************************************

procedure TAddictSpell3Base.Fire_ReplaceWord( Word:String; State:LongInt );
begin
    if (not FBeforeChangeFired) then
    begin
        FBeforeChangeFired := True;
        if (Assigned(FOnBeforeChange)) then
        begin
            FOnBeforeChange( Self );
        end;
    end;
    if (Assigned(FOnParserReplaceWord)) then
    begin
        FOnParserReplaceWord( Self, True, Word, State );
    end;
    if assigned(FParser) then
    begin
        FParser.ReplaceWord( Word, State );
    end;
    if (Assigned(FOnParserReplaceWord)) then
    begin
        FOnParserReplaceWord( Self, False, Word, State );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Fire_IgnoreWord( State:LongInt );
begin
    if (Assigned(FOnParserIgnoreWord)) then
    begin
        FOnParserIgnoreWord( Self, True, State );
    end;
    FOnParserIgnoreWordList.State  := State;
    FOnParserIgnoreWordList.Before := True;
    FOnParserIgnoreWordList.Notify( Self );
    if assigned(FParser) then
    begin
        FParser.IgnoreWord( State );
    end;
    if (Assigned(FOnParserIgnoreWord)) then
    begin
        FOnParserIgnoreWord( Self, False, State );
    end;
    FOnParserIgnoreWordList.Before := False;
    FOnParserIgnoreWordList.Notify( Self );
end;

//************************************************************

procedure TAddictSpell3Base.Fire_UndoLast( UndoState:LongInt; UndoAction:TSpellAction; var UndoData:LongInt );
begin
    if (Assigned(FOnParserUndoLast)) then
    begin
        FOnParserUndoLast( Self, UndoState, UndoAction, UndoData );
    end;
    if (assigned(FParser)) then
    begin
        FParser.UndoLast( UndoState, Integer(UndoAction), UndoData );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.NotifyDictionariesPathChanged( Sender: TObject );
begin
    if not(csReading in ComponentState) and not(csLoading in ComponentState) then
    begin
        FireConfigurationChanged( True );
    end;
end;


//************************************************************
// Parsing Utility Functions
//************************************************************

function TAddictSpell3Base.ValidRepeatedWord( Word:String; Parser:TControlParser ):Boolean;
var
    XPos, YPos  :LongInt;
    Len         :LongInt;
begin
    Result := False;
    if (Assigned(Parser)) then
    begin
        XPos := 0;
        YPos := 0;
        Parser.GetPosition( XPos, YPos );

        Len := Length(Word) + 1;
        while (Len > 0) do
        begin
            Parser.MovePrevious;
            dec(Len);
        end;

        if (Parser.GetChar = ' ') then
        begin

            Len := Length(Word);
            while (Len > 0) do
            begin
                Parser.MovePrevious;
                if (Word[Len] <> Parser.GetChar) then
                begin
                    break;
                end;
                dec(Len);
            end;

            if (Len = 0) then
            begin
                Result := True;
            end;
        end;

        Parser.SetPosition( XPos, YPos, ptCurrent );
    end;
end;

//************************************************************

function TAddictSpell3Base.WordIsPossessive( const Word:String ):Boolean;
var
    NewWord :String;
    Index   :Integer;
begin
    Result := False;
    if  (pos( '''s', Word ) = (Length(Word) - 1)) or
        (pos( '''S', Word ) = (Length(Word) - 1)) or
        (pos( #146 + 's', Word ) = (Length(Word) - 1)) or
        (pos( #146 + 'S', Word ) = (Length(Word) - 1)) then
    begin
        NewWord := copy( Word, 1, Length(Word) - 2 );
        for Index := 0 to FMainDictionaries.Count - 1 do
        begin
            if ((TMainDictionary(FMainDictionaries[Index]).Language and $00FF) = EnglishLanguage) and
                (   (TMainDictionary(FMainDictionaries[Index]).WordExists( GetCaseModification( NewWord ) )) or
                    (TMainDictionary(FMainDictionaries[Index]).WordExists( NewWord ))  ) then
            begin
                Result := True;
            end;
        end;
    end;
end;

//************************************************************

function TAddictSpell3Base.GetCaseModification( const Word:String ):String;
begin
    Result := Word;
    if (Length(Word) > 0) then
    begin
        case (FAllowedCases) of
        cmNone:
            begin
                // Source Word -- no modifications
            end;
        cmInitialCaps:
            begin
                Result[1] := AnsiLowerCase(Copy(Result,1,1))[1];
            end;
        cmInitialCapsOrUpcase:
            begin
                if (AnsiUppercase(Result) = Result) then
                begin
                    Result := AnsiLowerCase(Result);
                end
                else
                begin
                    Result[1] := AnsiLowerCase(Copy(Result,1,1))[1];
                end;
            end;
        cmAnyCase:
            begin
                Result := AnsiLowerCase(Result);
            end;
        cmCustom:
            begin
                Result := Word;
                if (Assigned(FOnCaseModification)) then
                begin
                    FOnCaseModification( Self, Result );
                end;
            end;
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.GetWordCountParserInternal( Parser:TControlParser; CheckType:TCheckType;
                                                        CheckErrors:Boolean; StopOnFirstError:Boolean;
                                                        var HasErrors:Boolean;
                                                        var ErrorCount:LongInt;
                                                        var WordCount:LongInt );
var
    StartTime   :DWORD;
    CursorShown :Boolean;
    OldCursor   :TCursor;
    Word        :String;
    LastWord    :String;
    PEngine     :TMainParsingEngine;
    OriginalX   :LongInt;
    OriginalY   :LongInt;
begin
    WordCount   := 0;
    ErrorCount  := 0;
    HasErrors   := False;

    if ((CheckType <> ctAll) and (CheckType <> ctSelected)) then
    begin
        Exit;
    end;

    FConfiguration.Loaded   := True;
    Parser.GetCursorPosition( OriginalX, OriginalY );

    PEngine                     := TMainParsingEngine.Create;
    PEngine.OnInlineIgnore      := RunInlineIgnore;
    PEngine.OnPreCheckIgnore    := RunPreCheckIgnore;
    PEngine.Initialize( Parser, LongInt(CheckType) );

    CursorShown := False;
    StartTime   := GetTickCount;
    OldCursor   := 0;

    try
        Word    := PEngine.NextWord;
        while (Word <> '') do
        begin
            inc(WordCount);

            if FUseHourglass and (not CursorShown) and ((GetTickCount - StartTime) > 1000) then
            begin
                CursorShown     := True;
                OldCursor       := Screen.Cursor;
                Screen.Cursor   := crHourglass;
            end;

            if (CheckErrors) then
            begin
                if  (WordAcceptable( Word )) then
                begin
                    if (FRepeated) then
                    begin
                        if  (LastWord = Word) and
                            (ValidRepeatedWord(Word,Parser)) then
                        begin
                            inc(ErrorCount);
                        end;
                        LastWord := Word;
                    end
                end
                else
                begin
                    inc(ErrorCount);
                end;

                if (StopOnFirstError and (ErrorCount > 0)) then
                begin
                    break;
                end;
            end;

            Word    := PEngine.NextWord;
        end;

        case FEndPosition of
        epHome:
            begin
                Parser.SetPosition( 0, 0, ptCurrent );
            end;
        epOriginal:
            begin
                Parser.SetPosition( OriginalX, OriginalY, ptCurrent );
            end;
        end;
        Parser.SelectWord( 0 );

    finally

        if (CursorShown) then
        begin
            Screen.Cursor   := OldCursor;
        end;

        PEngine.Free;

        if (FFreeParser) then
        begin
            Parser.Free;
        end;

        HasErrors := (ErrorCount > 0);
    end;
end;




//************************************************************
// Undo Functionality
//************************************************************

procedure TAddictSpell3Base.PerformUndo;
var
    Undo    :TAddictUndo;
    Auto    :Boolean;
begin
    if (FUndoList.Count > 0) and (assigned(FParser)) then
    begin
        Undo    := TAddictUndo(FUndoList[ FUndoList.Count - 1 ]);

        Fire_UndoLast( UndoState_BeforeUndo, Undo.FAction,  Undo.FData );

        Auto    := Undo.FAutomatic;

        case Undo.FAction of
        saIgnore:
            begin
                FParser.SetPosition( Undo.FXPos, Undo.FYPos, ptCurrent );
            end;
        saIgnoreAll:
            begin
                FInternalCustom.RemoveIgnore( Undo.FWord );
                FParser.SetPosition( Undo.FXPos, Undo.FYPos, ptCurrent );
            end;
        saChange:
            begin
                FParser.SetPosition( Undo.FXPos + Length(Undo.FReplacement), Undo.FYPos, ptCurrent );
                FParser.SelectWord( Length(Undo.FReplacement) );
                Fire_ReplaceWord( Undo.FWord, ReplacementState_Replace_Undo );
                FParser.SetPosition( Undo.FXPos, Undo.FYPos, ptCurrent );
            end;
        saChangeAll:
            begin
                FInternalCustom.RemoveAutoCorrect( Undo.FWord );
                FParser.SetPosition( Undo.FXPos + Length(Undo.FReplacement), Undo.FYPos, ptCurrent );
                FParser.SelectWord( Length(Undo.FReplacement) );
                Fire_ReplaceWord( Undo.FWord, ReplacementState_ReplaceAll_Undo );
                FParser.SetPosition( Undo.FXPos, Undo.FYPos, ptCurrent );
            end;
        saAdd:
            begin
                if (assigned( FActiveCustom )) then
                begin
                    FActiveCustom.RemoveIgnore( Undo.FWord );
                end;
                FParser.SetPosition( Undo.FXPos, Undo.FYPos, ptCurrent );
            end;
        saAutoCorrect:
            begin
                if (assigned( FActiveCustom )) then
                begin
                    FActiveCustom.RemoveAutoCorrect( Undo.FWord );
                end;
                FInternalCustom.RemoveAutoCorrect( Undo.FWord );
                FParser.SetPosition( Undo.FXPos + Length(Undo.FReplacement), Undo.FYPos, ptCurrent );
                FParser.SelectWord( Length(Undo.FReplacement) );
                Fire_ReplaceWord( Undo.FWord, ReplacementState_AutoCorrect_Undo );
                FParser.SetPosition( Undo.FXPos, Undo.FYPos, ptCurrent );
            end;
        end;

        FUndoList.Delete( FUndoList.Count - 1 );

        Fire_UndoLast( UndoState_AfterUndo, Undo.FAction,  Undo.FData );

        if (Auto) then
        begin
            PerformUndo;
        end
    end;
end;

//************************************************************

procedure TAddictSpell3Base.SetUndoAction( SpellAction:TSpellAction; Replacement:String; Automatic:Boolean );
var
    Undo        :TAddictUndo;
begin
    if (Assigned(FParser)) and (FMaxUndo <> 0) then
    begin
        Undo    := TAddictUndo.Create;
        if (Assigned(Undo)) then
        begin
            FUndoList.Add( Undo );

            Undo.FXPos          := 0;
            Undo.FYPos          := 0;
            FParser.GetPosition( Undo.FXPos, Undo.FYPos );
            Undo.FWord          := FWord;
            Undo.FAction        := SpellAction;
            Undo.FReplacement   := Replacement;
            Undo.FAutomatic     := Automatic;
            Undo.FData          := 0;

            Fire_UndoLast( UndoState_AddUndo, SpellAction,  Undo.FData );

            while (FMaxUndo <> -1) and (FUndoList.Count > FMaxUndo) do
            begin
                FUndoList.Delete( 0 );
            end;
        end;
    end;
end;



//************************************************************
// Public Ignore Object Functions
//************************************************************

procedure TAddictSpell3Base.RunInlineIgnore( CurrentChar:Char; Parser:TControlParser; var Ignore:Boolean );
var
    Count   :LongInt;
begin
    Ignore  := False;
    Count   := 0;
    while (Count < FIgnoreEntries.Count) do begin
        if (TParserIgnore(FIgnoreEntries[Count]).ExecuteIgnore( CurrentChar, Parser )) then
        begin
            Ignore := True;
            exit;
        end;
        INC(Count);
    end;
end;

//************************************************************

procedure TAddictSpell3Base.RunPreCheckIgnore( const Word:String; Parser:TControlParser; var Ignore:Boolean );
var
    Count   :LongInt;
begin
    Ignore  := False;
    Count   := 0;
    while (Count < FIgnoreEntries.Count) do begin
        if (TParserIgnore(FIgnoreEntries[Count]).ExecuteWordIgnorePreCheck( Word, Parser )) then
        begin
            Ignore := True;
            exit;
        end;
        INC(Count);
    end;
end;

//************************************************************

function TAddictSpell3Base.RunPostCheckIgnore( const Word:String; Parser:TControlParser ):Boolean;
var
    Count   :LongInt;
begin
    Result  := False;
    Count   := 0;
    while (Count < FIgnoreEntriesPost.Count) do
    begin
        if (TParserIgnore(FIgnoreEntriesPost[Count]).ExecuteWordIgnorePostCheck( Word, Parser )) then
        begin
            Result := True;
            exit;
        end;
        INC(Count);
    end;
end;

(*************************************************************)

function TAddictSpell3Base.RunLineIgnore( const Line:String ):Boolean;
var
    Count   :LongInt;
begin
    Result  := False;
    Count   := 0;
    while (Count < FIgnoreEntriesLine.Count) do
    begin
        if (TParserIgnore(FIgnoreEntriesLine[Count]).ExecuteLineIgnore( Line )) then
        begin
            Result := True;
            exit;
        end;
        INC(Count);
    end;
end;

(*************************************************************)

procedure TAddictSpell3Base.AddIgnore( IgnoreEntry:TParserIgnore );
begin
    if (Assigned(IgnoreEntry)) then
    begin
        if (IgnoreEntry.NeededBeforeCheck) then
        begin
            FIgnoreEntries.Add( IgnoreEntry );
        end;
        if (IgnoreEntry.LineCheckNeeded) then
        begin
            FIgnoreEntriesLine.Add( IgnoreEntry );
        end;

        FIgnoreEntriesPost.Add( IgnoreEntry );
    end;
end;

(*************************************************************)

procedure TAddictSpell3Base.ClearIgnoreList;
begin
    FIgnoreEntries.Clear;
    FIgnoreEntriesLine.Clear;
    FIgnoreEntriesPost.Clear;       // Frees ignore objects
end;





//************************************************************
// check methods
//************************************************************

procedure TAddictSpell3Base.ExistsEvent( const Word:PChar; var Exists:Boolean );
begin
    if (FPrimaryOnly) then
    begin
        Exists  := WordExistsInMain( Word ) or WordExistsInMain( GetCaseModification( Word ) );
    end
    else
    begin
        Exists  := WordExists( Word ) or WordExists( GetCaseModification( Word ) );
    end;
    if not Exists and FAllowPossessive then
    begin
        Exists := WordIsPossessive( Word );
    end;
end;

//************************************************************

procedure TAddictSpell3Base.CompleteCheck;
begin
    if (Assigned(FOnCompleteCheck)) then
    begin
        FOnCompleteCheck( Self );
    end;

    ShowEndMessage;

    if (not(FCanceled)) then
    begin
        case FEndPosition of
        epHome:
            begin
                FParser.SetPosition( 0, 0, ptCurrent );
            end;
        epOriginal:
            begin
                FParser.SetPosition( FOriginalX, FOriginalY, ptCurrent );
            end;
        end;
        FParser.SelectWord( 0 );
    end;

    if (FFreeParser) then
    begin
        FParser.Free;
    end;
    FParser := nil;

    ShutdownUI;

    FUndoList.Clear;
    FChecking := False;

    UnloadDictionaries;
end;

//************************************************************

procedure TAddictSpell3Base.ContinueCheck;
var
    Replacement :String;
    CheckType   :TWordCheckType;
    StartTime   :DWORD;
    CursorShown :Boolean;
    OldCursor   :TCursor;
begin
    CursorShown := False;
    StartTime   := GetTickCount;
    OldCursor   := 0;

    try
        repeat
            FWord   := FParsingEngine.NextWord;

            if (FWord = '') then
            begin
                CompleteCheck;
                exit;
            end;

            inc(FWordCount);

            if (FOptimizeCount > 0) then
            begin
                dec(FOptimizeCount);
                if (FOptimizeCount = 0) then
                begin
                    OptimizeMainDictionaryOrder;
                end;
            end;

            if (WordAcceptable( FWord )) then
            begin
                CheckType := wcAccepted;
                if (FUseAutoCorrectFirst) and (WordHasCorrection( FWord, Replacement )) then
                begin
                    CheckType := wcCorrected;
                end
                else if (FRepeated) then
                begin
                    if  (FLastWord = FWord) and
                        (ValidRepeatedWord(FWord,FParser)) then
                    begin
                        CheckType := wcRepeated;
                    end;
                    FLastWord := FWord;
                end
            end
            else if (WordHasCorrection( FWord, Replacement )) then
            begin
                CheckType := wcCorrected;
            end
            else if (FUseExclude) and (WordExcluded(FWord) or WordExcluded(GetCaseModification(FWord))) then
            begin
                CheckType := wcExcluded;
            end
            else
            begin
                CheckType := wcDenied;
            end;

            if (assigned( FOnWordCheck )) then
            begin
                FOnWordCheck( Self, FWord, CheckType, Replacement );
            end;

            if (CheckType = wcCorrected) then
            begin
                FParser.SelectWord( Length(FWord) );
                SetUndoAction( saChange, Replacement, True );
                Fire_ReplaceWord( Replacement, ReplacementState_AutoCorrect );
            end;

            if FUseHourglass and (not CursorShown) and ((GetTickCount - StartTime) > 1000) then
            begin
                CursorShown     := True;
                OldCursor       := Screen.Cursor;
                Screen.Cursor   := crHourglass;
            end;

        until (CheckType = wcDenied) or (CheckType = wcExcluded) or (CheckType = wcRepeated);

    finally

        if (CursorShown) then
        begin
            Screen.Cursor   := OldCursor;
        end;
    end;

    FExecutingRepeat := (CheckType = wcRepeated);
    if (FExecutingRepeat) then
    begin
        FWord := FWord + ' ' + FWord;
    end;

    FParser.SelectWord( Length(FWord) );
    FParser.CenterSelection;

    EnsureUI;

    // protect against the backdown of a modal dialog so that we don't
    // try to fire the DoWordPrompt events out after we've stopped checking

    if (FChecking) then
    begin
        DoWordPrompt;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.CheckString( var CheckString:String );
var
    Parser  :TStringParser;
begin
    Parser := TStringParser.Create;
    Parser.Initialize( @CheckString );

    CheckParser( Parser, ctAll );

    if (not FFreeParser) then
    begin
        Parser.Free;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.CheckWinControl( Control:TWinControl; CheckType:TCheckType );
var
    Parser  :TWinAPIControlParser;
begin
    Parser := TWinAPIControlParser.Create;
    Parser.Initialize( Control );

    CheckParser( Parser, CheckType );

    if (not FreeParser) then
    begin
        Parser.Free;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.CheckRichEdit( Control:TWinControl; CheckType:TCheckType );
var
    Parser  :TWinAPIControlParser;
begin
    Parser := TWinAPIControlParser.Create;
    Parser.Initialize( Control );
    Parser.ControlType := actRichEdit;

    CheckParser( Parser, CheckType );

    if (not FreeParser) then
    begin
        Parser.Free;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.CheckWinControlHWND( ControlHWND:HWND; CheckType:TCheckType );
var
    Parser  :TWinAPIControlParser;
begin
    Parser := TWinAPIControlParser.Create;
    Parser.InitializeFromHWND( ControlHWND );

    CheckParser( Parser, CheckType );

    if (not FreeParser) then
    begin
        Parser.Free;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.CheckSmart( Parser:TControlParser );
var
    FOldFreeParser              :Boolean;
    FOldSynchronousCheck        :Boolean;
    XStart, YStart, XEnd, YEnd  :LongInt;
begin
    FOldSynchronousCheck    := SynchronousCheck;
    SynchronousCheck        := True;
    FOldFreeParser          := FFreeParser;
    FreeParser              := False;

    StartSequenceCheck;

    Parser.GetSelectionPosition( XStart, YStart, XEnd, YEnd );

    if ((XStart = XEnd) and (YStart = YEnd)) then
    begin
        CheckParser( Parser, ctFromCursor );

        Parser.SetPosition( 0, 0, ptCurrent );
        Parser.SetPosition( XStart, YStart, ptEnd );

        CheckParser( Parser, ctCurrent );
    end
    else
    begin
        CheckParser( Parser, ctSelected );

        if (not FCanceled) then
        begin
            if (IDYES = Application.MessageBox( PChar(GetString(lsEndSelectionMessage)),
                                                PChar(GetString(lsSpelling)),
                                                MB_YESNO or MB_ICONINFORMATION ))   then
            begin
                Parser.SetPosition( XEnd, YEnd, ptCurrent );
                Parser.SetPosition( $7FFFFFFF, $7FFFFFFF, ptEnd );

                CheckParser( Parser, ctCurrent );

                Parser.SetPosition( 0, 0, ptCurrent );
                Parser.SetPosition( XStart, YStart, ptEnd );

                CheckParser( Parser, ctCurrent );
            end
            else
            begin
                FCanceled := True;
            end;
        end;
    end;

    StopSequenceCheck;

    FreeParser              := FOldFreeParser;
    SynchronousCheck        := FOldSynchronousCheck;

    if (FFreeParser) then
    begin
        Parser.Free;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.CheckParser( Parser:TControlParser; CheckType:TCheckType );
begin
    // We don't allow two spell checks to go on at once...
    // We also don't allow subsequent checks in a sequence when one has
    // been canceled.

    if  (FChecking) or
        (FCheckingSequence and FCanceled) then
    begin
        if (FFreeParser) then
        begin
            Parser.Free;
        end;
        Exit;
    end;

    if (CheckType = ctSmart) then
    begin
        CheckSmart( Parser );
        Exit;
    end;

    FBeforeChangeFired      := False;
    FChecking               := True;
    FCanceled               := False;
    FConfiguration.Loaded   := True;
    FParser                 := Parser;
    FOriginalX              := 0;
    FOriginalY              := 0;
    FLastWord               := '';
    FExecutingRepeat        := False;
    FParser.GetCursorPosition( FOriginalX, FOriginalY );
    ParsingEngine.Initialize( FParser, LongInt(CheckType) );
    FUndoList.Clear;

    // If we're checking a sequence, then the wordcount is unaffected.

    if (not FCheckingSequence) then
    begin
        FWordCount      := 0;
        FOptimizeCount  := 100;
    end;

    // If we're supposed to bring up the dialog immediatley, then we
    // call EnsureUI to pull it up...

    if (FImmediateDialog) then
    begin
        EnsureUI;
    end;

    // Setup some initial parameters based upon the first loaded dictionary...
    // these could adapt the the language the user is using over time as well...

    OptimizeMainDictionaryOrder;

    // The only time that we don't want to call ContinueCheck to start
    // the checking process is when we're showing the dialog immediately, and
    // the dialog is modal.  In this case, the Continue will be automatically
    // triggered by our override of the OnShow handler.

    if (not(FImmediateDialog and FModalDialog)) then
    begin
        ContinueCheck;
    end;

    while FProcessMessages and FChecking do
    begin
        {$IFNDEF ADDICTPROCESSMESSAGES}
        Application.HandleMessage;
        {$ELSE}
        Application.ProcessMessages;
        {$ENDIF}
    end;
end;

//************************************************************

procedure TAddictSpell3Base.StartSequenceCheck;
begin
    FWordCount              := 0;
    FOptimizeCount          := 100;
    FCanceled               := False;
    FCheckingSequence       := True;

    FOldCloseDialog         := FCloseDialog;
    FOldKeepActive          := FKeepDictionariesActive;

    CloseDialog             := False;
    KeepDictionariesActive  := True;
end;

//************************************************************

procedure TAddictSpell3Base.StopSequenceCheck;
begin
    if (FCheckingSequence) then
    begin
        FCheckingSequence       := False;

        CloseDialog             := True;

        ShowEndMessage;
        CloseSpellDialog;

        CloseDialog             := FOldCloseDialog;
        KeepDictionariesActive  := FOldKeepActive;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.StopCheck( Canceled:Boolean );
begin
    if (FChecking) then
    begin
        FCanceled := Canceled;
        CompleteCheck;
    end;
end;



//************************************************************
// word count methods
//************************************************************

function TAddictSpell3Base.GetWordCountString( CountString:String ):LongInt;
var
    Parser  :TStringParser;
begin
    Parser := TStringParser.Create;
    Parser.Initialize( @CountString );

    Result := GetWordCountParser( Parser, ctAll );

    if (not FFreeParser) then
    begin
        Parser.Free;
    end;
end;

//************************************************************

function TAddictSpell3Base.GetWordCountWinControl( Control:TWinControl; CheckType:TCheckType ):LongInt;
var
    Parser  :TWinAPIControlParser;
begin
    Parser := TWinAPIControlParser.Create;
    Parser.Initialize( Control );

    Result := GetWordCountParser( Parser, CheckType );

    if (not FreeParser) then
    begin
        Parser.Free;
    end;
end;

//************************************************************

function TAddictSpell3Base.GetWordCountParser( Parser:TControlParser; CheckType:TCheckType ):LongInt;
var
    HasErrors   :Boolean;
    ErrorCount  :LongInt;
    WordCount   :LongInt;
begin
    GetWordCountParserInternal( Parser, CheckType, False, False, HasErrors, ErrorCount, WordCount );
    Result := WordCount;
end;



//************************************************************
// Error count methods
//************************************************************

function TAddictSpell3Base.GetErrorCountString( CountString:String ):LongInt;
var
    Parser  :TStringParser;
begin
    Parser := TStringParser.Create;
    Parser.Initialize( @CountString );

    Result := GetErrorCountParser( Parser, ctAll );

    if (not FFreeParser) then
    begin
        Parser.Free;
    end;
end;

//************************************************************

function TAddictSpell3Base.GetErrorCountWinControl( Control:TWinControl; CheckType:TCheckType ):LongInt;
var
    Parser  :TWinAPIControlParser;
begin
    Parser := TWinAPIControlParser.Create;
    Parser.Initialize( Control );

    Result := GetErrorCountParser( Parser, CheckType );

    if (not FreeParser) then
    begin
        Parser.Free;
    end;
end;

//************************************************************

function TAddictSpell3Base.GetErrorCountParser( Parser:TControlParser; CheckType:TCheckType ):LongInt;
var
    HasErrors   :Boolean;
    ErrorCount  :LongInt;
    WordCount   :LongInt;
begin
    GetWordCountParserInternal( Parser, CheckType, True, False, HasErrors, ErrorCount, WordCount );
    Result := ErrorCount;
end;

//************************************************************

function TAddictSpell3Base.ErrorsPresentInString( CountString:String ):Boolean;
var
    Parser  :TStringParser;
begin
    Parser := TStringParser.Create;
    Parser.Initialize( @CountString );

    Result := ErrorsPresentInParser( Parser, ctAll );

    if (not FFreeParser) then
    begin
        Parser.Free;
    end;
end;

//************************************************************

function TAddictSpell3Base.ErrorsPresentInWinControl( Control:TWinControl; CheckType:TCheckType ):Boolean;
var
    Parser  :TWinAPIControlParser;
begin
    Parser := TWinAPIControlParser.Create;
    Parser.Initialize( Control );

    Result := ErrorsPresentInParser( Parser, CheckType );

    if (not FreeParser) then
    begin
        Parser.Free;
    end;
end;

//************************************************************

function TAddictSpell3Base.ErrorsPresentInParser( Parser:TControlParser; CheckType:TCheckType ):Boolean;
var
    HasErrors   :Boolean;
    ErrorCount  :LongInt;
    WordCount   :LongInt;
begin
    GetWordCountParserInternal( Parser, CheckType, True, True, HasErrors, ErrorCount, WordCount );
    Result := HasErrors;
end;




//************************************************************
// spell check processing methods
//************************************************************

procedure TAddictSpell3Base.Check_Ignore;
begin
    if (FChecking) then
    begin
        SetUndoAction( saIgnore, '', False );
        Fire_IgnoreWord( IgnoreState_Ignore );
        ContinueCheck;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Check_IgnoreAll;
begin
    if (FChecking) and (not FExecutingRepeat) then
    begin
        SetUndoAction( saIgnoreAll, '', False );
        FInternalCustom.AddIgnore( FWord );
        Fire_IgnoreWord( IgnoreState_IgnoreAll );
        ContinueCheck;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Check_Change( const Word:String );
var
    XPos    :Integer;
    YPos    :Integer;
begin
    if (FChecking) and (not FExecutingRepeat) then
    begin
        SetUndoAction( saChange, Word, False );
        Fire_ReplaceWord( Word, ReplacementState_Replace );
        if (FRecheckReplaced) then
        begin
            XPos := 0;
            YPos := 0;
            FParser.GetPosition( XPos, YPos );
            dec( XPos, Length(Word) );
            FParser.SetPosition( XPos, YPos, ptCurrent );
        end;
        LearnSuggestion( FWord, Word );
        ContinueCheck;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Check_ChangeAll( const Word:String );
begin
    if (FChecking) and (not FExecutingRepeat) then
    begin
        SetUndoAction( saChangeAll, Word, False );
        FInternalCustom.AddAutoCorrect( FWord, Word );
        Fire_ReplaceWord( Word, ReplacementState_ReplaceAll );
        LearnSuggestion( FWord, Word );
        ContinueCheck;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Check_Add;
begin
    if (FChecking) and (not FExecutingRepeat) then
    begin
        SetUndoAction( saAdd, '', False );
        if (assigned( FActiveCustom )) then
        begin
            FActiveCustom.AddIgnore( FWord );
        end;
        Fire_IgnoreWord( IgnoreState_Add );
        ContinueCheck;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Check_AutoCorrect( const Word:String );
begin
    if (FChecking) and (not FExecutingRepeat) then
    begin
        SetUndoAction( saAutoCorrect, Word, False );
        if (assigned( FActiveCustom )) then
        begin
            FActiveCustom.AddAutoCorrect( FWord, Word );
        end;
        LearnSuggestion( FWord, Word );
        Fire_ReplaceWord( Word, ReplacementState_AutoCorrect );
        ContinueCheck;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Check_Undo;
begin
    if (FChecking) then
    begin
        if (CanUndo) then
        begin
            PerformUndo;
            ContinueCheck;
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Check_RepeatIgnore;
begin
    Check_Ignore;
end;

//************************************************************

procedure TAddictSpell3Base.Check_RepeatDelete;
begin
    if (FChecking) and (FExecutingRepeat) then
    begin
        SetUndoAction( saChange, FLastWord, False );
        Fire_ReplaceWord( FLastWord, ReplacementState_Replace );
        ContinueCheck;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Check_ControlEdited;
var
    XPos        :LongInt;
    YPos        :LongInt;
    XPosCursor  :LongInt;
    YPosCursor  :LongInt;
begin
    if (FChecking) then
    begin
        FUndoList.Clear;

        // In theory, if the user hasn't moved the cursor position, then
        // we'll just back it up to before the current word we're checking...
        // Then, when we kick the check in gear, we should hit the same word
        // again.

        XPos := 0;
        YPos := 0;
        FParser.GetPosition( XPos, YPos );

        dec( XPos, Length(FWord) );
        if (XPos < 0) then
        begin
            XPos := 0;
        end;

        XPosCursor  := 0;
        YPosCursor  := 0;
        FParser.GetCursorPosition( XPosCursor, YPosCursor );

        if (FResumeFromLastPosition) then
        begin
            if (YPosCursor < YPos) then
            begin
                YPos := YPosCursor;
                XPos := XPosCursor;
            end;
            if (YPosCursor = YPos) and (XPosCursor < XPos) then
            begin
                XPos := XPosCursor;
            end;
        end
        else
        begin
            XPos    := XPosCursor;
            YPos    := YPosCursor;
        end;

        FParsingEngine.AdjustToPosition( XPos, YPos );

        ContinueCheck;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Check_Help;
begin
    if (FChecking) then
    begin
        // Currently unused... dialogs expected to implement
        // their own help.
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Check_Cancel;
begin
    if (FChecking) then
    begin
        FCanceled   := True;
        CompleteCheck;
    end;
end;



//************************************************************
// word check methods
//************************************************************

function TAddictSpell3Base.WordExistsInMain( const Word:String ):Boolean;
var
    Index   :LongInt;
begin
    FConfiguration.Loaded   := True;
    Result                  := True;

    for Index := 0 to FMainDictionaries.Count - 1 do
    begin
        if (TMainDictionary(FMainDictionaries[Index]).WordExists( Word )) then
        begin
            TMainDictionary(FMainDictionaries[Index]).WordFound;
            exit;
        end;
    end;

    Result := False;
end;

//************************************************************

function TAddictSpell3Base.WordExists( const Word:String ):Boolean;
var
    Index   :LongInt;
begin
    FConfiguration.Loaded   := True;
    Result                  := True;

    // Speed critical area.  Not deferring to similar code in
    // WordExistsInMain function

    for Index := 0 to FMainDictionaries.Count - 1 do
    begin
        if (TMainDictionary(FMainDictionaries[Index]).WordExists( Word )) then
        begin
            TMainDictionary(FMainDictionaries[Index]).WordFound;
            exit;
        end;
    end;

    if (assigned( FActiveCustom )) then
    begin
        if (FActiveCustom.IgnoreExists( Word )) then
        begin
            exit;
        end;
    end;

    for Index := 0 to FCustomDictionaries.Count - 1 do
    begin
        if (TCustomDictionary(FCustomDictionaries[Index]).IgnoreExists( Word )) then
        begin
            exit;
        end;
    end;

    for Index := 0 to FMSWordDictionaries.Count - 1 do
    begin
        if (TCustomDictionary(FMSWordDictionaries[Index]).IgnoreExists( Word )) then
        begin
            exit;
        end;
    end;

    if (FInternalCustom.IgnoreExists( Word )) then
    begin
        exit;
    end;

    Result := False;
end;

//************************************************************

function TAddictSpell3Base.WordAcceptable( const Word:String ):Boolean;
var
    Number      :Extended;
    CaseChange  :String;
begin
    Result := True;

    if (WordExists( Word )) then
    begin
        if (FUseExclude) and (WordExcluded( Word )) then
        begin
            Result := False;
        end;
        exit;
    end;

    CaseChange := GetCaseModification( Word );
    if (WordExists(CaseChange)) then
    begin
        if (FUseExclude) and (WordExcluded(CaseChange)) then
        begin
            Result := False;
        end;
        exit;
    end;

    if (FAllowPossessive) then
    begin
        if (WordIsPossessive( Word )) then
        begin
            exit;
        end;
    end;

    if (TextToFloat( PChar(Word), Number, fvExtended )) then
    begin
        exit;
    end;

    if (Length(Word) = 1) then
    begin
        exit;
    end;

    if (RunPostCheckIgnore( Word, FParser )) then
    begin
        exit;
    end;

    Result := False;
end;

//************************************************************

function TAddictSpell3Base.WordExcluded( const Word:String ):Boolean;
var
    Index       :LongInt;
    Correction  :String;
begin
    FConfiguration.Loaded   := True;
    Result                  := True;

    if (assigned( FActiveCustom )) then
    begin
        if (FActiveCustom.ExcludeExists( Word )) then
        begin
            exit;
        end;
    end;

    for Index := 0 to FCustomDictionaries.Count - 1 do
    begin
        if (TCustomDictionary(FCustomDictionaries[Index]).ExcludeExists( Word )) then
        begin
            exit;
        end;
    end;

    if (assigned( FMappingCustom )) then
    begin
        if (FMappingCustom.AutoCorrectExists( Word, Correction )) then
        begin
            exit;
        end;
    end;

    Result := False;
end;

//************************************************************

function TAddictSpell3Base.WordHasCorrection( const Word:String; var Correction:String ):Boolean;
var
    Index   :LongInt;
begin
    FConfiguration.Loaded   := True;
    Result                  := True;

    if (assigned( FActiveCustom )) then
    begin
        if (FActiveCustom.AutoCorrectExists( Word, Correction )) then
        begin
            exit;
        end;
    end;

    if (FInternalCustom.AutoCorrectExists( Word, Correction )) then
    begin
        exit;
    end;

    for Index := 0 to FCustomDictionaries.Count - 1 do
    begin
        if (TCustomDictionary(FCustomDictionaries[Index]).AutoCorrectExists( Word, Correction )) then
        begin
            exit;
        end;
    end;

    if (assigned( FMappingCustom )) and FMappingAutoReplace then
    begin
        if (FMappingCustom.AutoCorrectExists( Word, Correction )) then
        begin
            exit;
        end;
    end;

    if (assigned(FLearningCustom)) and (FLearnAutoCorrect) then
    begin
        if (FLearningCustom.AutoCorrectExists( Word, Correction )) then
        begin
            if (WordAcceptable( Correction )) then
            begin
                exit;
            end
            else
            begin
                Correction := ''
            end;
        end;
    end;

    if (FDUalCaps) then
    begin
        if  (Length(Word) > 2) and
            (Copy(Word, 3, Length(Word)-2) = AnsiLowercase(Copy(Word, 3, Length(Word)-2))) and
            (Copy(Word, 1, 2) = AnsiUppercase(Copy(Word, 1, 2))) then
        begin
            // Its a DUal caps word... now the last verification is if this word
            // is in the dictionary;

            Correction      := Word;
            Correction[2]   := AnsiLowercase(Correction[2])[1];

            if  (Word <> Correction) and
                (AnsiLowercase(Correction[1]) <> AnsiUppercase(Correction[1])) and
                (AnsiLowercase(Correction[2]) <> AnsiUppercase(Correction[2])) and
                (WordAcceptable(Correction)) then
            begin
                exit;
            end;
        end;
    end;                

    Result := False;
end;



//************************************************************
// suggestions methods
//************************************************************

procedure TAddictSpell3Base.InternalSuggest( const Word:String; MaxSuggestions:LongInt; Words:TStrings );
var
    Outer           :LongInt;
    Inner           :LongInt;
    SuggestionsList :TStringList;
    PhoneticStart   :LongInt;
    Correction      :String;
begin
    // Check to see if we have an immediate mapping conversion

    if  (assigned( FMappingCustom )) and
        FMappingCustom.AutoCorrectExists( Word, Correction ) then
    begin
        Words.Add( Correction );
        exit;
    end;

    SuggestionsList := TStringList.Create;
    try
        // First consult the suggestions generator

        FSuggestions.Suggest( Word, MaxSuggestions, SuggestionsList, ExistsEvent );

        // Next, do phonetic suggestions

        PhoneticStart := SuggestionsList.Count;

        if (FUsePhoneticSuggetions) and (FMainDictionaries.Count > 0) then
        begin
            // Setup the phonetics map for the current primary language...

            if (FPhoneticsMap.Language <> TMainDictionary(FMainDictionaries[0]).Language) then
            begin
                FPhoneticsMap.Language := TMainDictionary(FMainDictionaries[0]).Language;

                if (Assigned( FOnAdjustPhoneticsMap )) then
                begin
                    FOnAdjustPhoneticsMap( Self );
                end;
            end;

            TMainDictionary(FMainDictionaries[0]).Suggest( Word, FPhoneticsMap, SuggestionsList );

            // For English, we default the the metaphone algorithm, but we allow
            // a soundex followup if we don't have that many suggestions to
            // possibly fix up any misses that we have...

            if ((FPhoneticsMap.Language and $00FF) = EnglishLanguage) and
               (SuggestionsList.Count < 20) and
               (FAllowSoundexFollowup) then
            begin
                FPhoneticsMap.Language := 0;
                if (Assigned( FOnAdjustPhoneticsMap )) then
                begin
                    FOnAdjustPhoneticsMap( Self );
                end;

                TMainDictionary(FMainDictionaries[0]).Suggest( Word, FPhoneticsMap, SuggestionsList );
            end;
        end;

        // Now cache the EditDistance in each item's object pointer.  We do this
        // because we wish to sort on this integer and calculating it is too
        // expensive to do more than we need.

        for Outer := 0 to SuggestionsList.Count - 1 do
        begin
            SuggestionsList.Objects[Outer] := TObject( GetEditDistance( Word, SuggestionsList[Outer] ) );
        end;

        // Now, remove any suggestion whose distance is too far

        Outer := PhoneticStart;
        while (Outer < SuggestionsList.Count) do
        begin
            if (not (FPhoneticsMap.AcceptableDistance( Word, Integer(SuggestionsList.Objects[Outer]) ))) then
            begin
                SuggestionsList.Delete( Outer );
            end
            else
            begin
                inc(Outer);
            end;
        end;

        // Now adjust the list based upon learned data from the user...

        if (assigned( FLearningCustom )) then
        begin
            if (FLearningCustom.AutoCorrectExists( Word, Correction )) then
            begin
                Outer := SuggestionsList.IndexOf( Correction );
                if (Outer >= 0) and ((SuggestionsList[Outer] = Correction)) then
                begin
                    SuggestionsList.Objects[Outer] := TObject(0);
                end
                else if (WordAcceptable(Correction)) then
                begin
                    SuggestionsList.InsertObject( 0, Correction, TObject(0) );
                end;
            end;
            for Outer := 0 to SuggestionsList.Count - 1 do
            begin
                if (FLearningCustom.IgnoreExists(SuggestionsList[Outer])) then
                begin
                    SuggestionsList.Objects[Outer] := TObject( Integer(SuggestionsList.Objects[Outer]) * 2 - 1 );
                end
                else
                begin
                    SuggestionsList.Objects[Outer] := TObject( Integer(SuggestionsList.Objects[Outer]) * 2 );
                end;
            end;
        end;

        // Sort the string list based upon the edit distance.
        // We use selection sort, since it is a stable sort (doesn't move objects
        // relative to each other when equal).

        for Outer := 0 to SuggestionsList.Count - 2 do
        begin
            for Inner := Outer + 1 to SuggestionsList.Count - 1 do
            begin
                if (Integer(SuggestionsList.Objects[Outer]) > Integer(SuggestionsList.Objects[Inner])) then
                begin
                    SuggestionsList.Exchange( Inner, Outer );
                end;
            end;
        end;

        // If we've got too many suggestions, then delete down to our limit

        if (MaxSuggestions >= 0) then
        begin
            while (SuggestionsList.Count > MaxSuggestions) do
            begin
                SuggestionsList.Delete( MaxSuggestions );
            end;
        end;

    finally
        Words.Assign( SuggestionsList );
        SuggestionsList.Free;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.Suggest( const Word:String; Words:TStrings );
begin
    FConfiguration.Loaded   := True;

    InternalSuggest( Word, FMaxSuggestions, Words );
end;

//************************************************************

procedure TAddictSpell3Base.LearnSuggestion( const MisspelledWord:String; const CorrectWord:String );
begin
    if (assigned( FLearningCustom )) then
    begin
        FLearningCustom.AddAutoCorrect( MisspelledWord, CorrectWord );
        FLearningCustom.AddIgnore( CorrectWord );
    end;
end;



//************************************************************
// Right-mouse button menuing
//************************************************************

procedure TAddictSpell3Base.PopupMenuHook( Sender:TObject );
begin
    FPopupAction    := (Sender as TMenuItem).Tag;
    FPopupWord      := (Sender as TMenuItem).Caption;
end;

//************************************************************

function TAddictSpell3Base.CreatePopupMenu( AOwner:TComponent ):TObject;
begin
    Result := nil;
    if assigned(FOnPopupCreateMenu) then
    begin
        FOnPopupCreateMenu( Self, AOwner, Result );
    end
    else
    begin
        Result := TPopupMenu.Create( AOwner );
        {$IFDEF Delphi5AndAbove}
        TPopupMenu(Result).AutoHotkeys   := maManual;
        {$ENDIF}
    end;
end;

//************************************************************

function TAddictSpell3Base.AddMenuItem( Menu:TObject; SubMenu:TObject; const Caption:String; Enable:Boolean; HasChildren:Boolean; Tag:Integer ):TObject;
begin
    Result  := nil;
    if assigned(FOnPopupAddMenuItem) then
    begin
        FOnPopupAddMenuItem( Self, Menu, SubMenu, Caption, Enable, HasChildren, Tag, Result );
    end
    else if not(assigned(FOnPopupCreateMenu)) then
    begin
        Result := TMenuItem.Create( nil );
        TMenuItem(Result).Caption := Caption;
        TMenuItem(Result).Enabled := Enable;
        TMenuItem(Result).Tag     := Tag;
        if (Tag > 0) then
        begin
            TMenuItem(Result).OnClick := PopupMenuHook;
        end;
        if assigned(SubMenu) then
        begin
            TMenuItem(SubMenu).Add( TMenuItem(Result) );
        end
        else
        begin
            TPopupMenu(Menu).Items.Add( TMenuItem(Result) );
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3Base.DoPopup( Menu:TObject; XPos:Integer; YPos:Integer; var PopupAction:Integer; var PopupWord:String );
begin
    FPopupAction    := Integer(spCancel);
    FPopupWord      := '';

    if assigned(FOnPopupDoMenu) then
    begin
        FOnPopupDoMenu( Self, Menu, XPos, YPos, PopupAction, PopupWord );
    end
    else if not(assigned(FOnPopupCreateMenu)) then
    begin
        TPopupMenu(Menu).Popup( XPos, YPos );

        // We have to process messages here in order to allow for our
        // change event to be posted back to us

        Application.ProcessMessages;
    end;
end;

//************************************************************

function TAddictSpell3Base.ShowPopupMenu(   Sender:TObject;
                                            Options:TSpellPopupOptions;
                                            XPos, YPos:Integer;
                                            var Text:String ):TSpellPopupOption;
var
    PopupMenu       :TObject;
    Suggestions     :TStringList;
    Index           :LongInt;
    MenuItem        :TObject;
    OriginalWord    :String;
begin
    Result := spCancel;

    if  (Text = '') or
        FPopupShowing   then
    begin
        exit;
    end;

    OriginalWord            := Text;
    FPopupShowing           := True;
    FConfiguration.Loaded   := True;
    PopupMenu               := CreatePopupMenu( Sender as TComponent );

    Suggestions             := TStringList.Create;
    try
        if (spReplace in Options) then
        begin
            InternalSuggest( Text, 5, Suggestions );
            for Index := 0 to Suggestions.Count - 1 do
            begin
                AddMenuItem( PopupMenu, nil, Suggestions[Index], true, false, Integer(spReplace) );
            end;
            if (Suggestions.Count = 0) then
            begin
                AddMenuItem( PopupMenu, nil, GetString(lsMnNoSuggestions), false, false, 0 );
            end;
            AddMenuItem( PopupMenu, nil, '-', true, false, 0 );
        end;
        if (spIgnore in Options) then
        begin
            AddMenuItem( PopupMenu, nil, GetString(lsMnIgnore), true, false, Integer(spIgnore) );
        end;
        if (spIgnoreAll in Options) then
        begin
            AddMenuItem( PopupMenu, nil, GetString(lsMnIgnoreAll), true, false, Integer(spIgnoreAll) );
        end;
        if (spAdd in Options) then
        begin
            AddMenuItem( PopupMenu, nil, GetString(lsMnAdd), assigned(FActiveCustom), false, Integer(spAdd) );
        end;
        AddMenuItem( PopupMenu, nil, '-', true, false, 0 );
        if (spChangeAll in Options) and (Suggestions.Count > 0) then
        begin
            MenuItem    := AddMenuItem( PopupMenu, nil, GetString(lsMnChangeAll), true, true, 0 );
            for Index := 0 to Suggestions.Count - 1 do
            begin
                AddMenuItem( PopupMenu, MenuItem, Suggestions[Index], true, false, Integer(spChangeAll) );
            end;
        end;
        if (spAutoCorrect in Options) and (Suggestions.Count > 0) and (Assigned(FActiveCustom)) then
        begin
            MenuItem    := AddMenuItem( PopupMenu, nil, GetString(lsMnAutoCorrect), assigned(FActiveCustom), true, 0 );
            for Index := 0 to Suggestions.Count - 1 do
            begin
                AddMenuItem( PopupMenu, MenuItem, Suggestions[Index], assigned(FActiveCustom), false, Integer(spAutoCorrect) );
            end;
        end;
        if (spDialog in Options) then
        begin
            AddMenuItem( PopupMenu, nil, GetString(lsMnSpelling), true, false, Integer(spDialog) );
        end;

        DoPopup( PopupMenu, XPos, YPos, FPopupAction, FPopupWord );

        case (FPopupAction) of
        Integer(spDialog):
            begin
                Result  := spDialog;
            end;
        Integer(spAutoCorrect):
            begin
                if (assigned(FActiveCustom)) then
                begin
                    FActiveCustom.AddAutoCorrect( Text, FPopupWord );
                    Result  := spAutoCorrect;
                    LearnSuggestion( Text, FPopupWord );
                    Text    := FPopupWord;
                end;
            end;
        Integer(spChangeAll):
            begin
                FInternalCustom.AddAutoCorrect( Text, FPopupWord );
                Result  := spChangeAll;
                LearnSuggestion( Text, FPopupWord );
                Text    := FPopupWord;
            end;
        Integer(spAdd):
            begin
                if (assigned(FActiveCustom)) then
                begin
                    FActiveCustom.AddIgnore( Text );
                    Result  := spAdd;
                end;
            end;
        Integer(spIgnoreAll):
            begin
                FInternalCustom.AddIgnore( Text );
                Result  := spIgnoreAll;
            end;
        Integer(spIgnore):
            begin
                Result  := spIgnore;
            end;
        Integer(spReplace):
            begin
                Result  := spReplace;
                LearnSuggestion( Text, FPopupWord );
                Text    := FPopupWord;
            end;
        end;

        if (Assigned(FOnPopupResult)) then
        begin
            FOnPopupResult( Self, OriginalWord, Text, Result );
        end;
        FOnPopupResultList.PopupResult := Result;
        FOnPopupResultList.Notify( Self );

    finally
        Suggestions.Free;
        PopupMenu.Free;
        FPopupShowing := False;
    end;
end;



end.

