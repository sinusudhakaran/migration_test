unit WPSpell_Controller;
// ---------------------------------------------------------------
// WPSpell by WPCubed GmbH
// engine for dictionary and options
// ---------------------------------------------------------------
// completely modernized and extended code
// based on dictionary technology by
// Eminent Domain Software - used under OEM license.
// ---------------------------------------------------------------
// Copyright (C) 2005 by WPCubed GmbH - Munich
// Version 1.0 - 16.2.2005
// Last Modification: 27.9.2005
// ---------------------------------------------------------------

interface

{$R WPSpell_Controller.res} // Component ICON

uses SysUtils, Classes, Windows, Controls, Registry,
  Forms, IniFiles, WPSpell_Language, Menus;

{$I WPLanguages.INC}
{$I WPSpell_INC.INC}

{$R-}

{--$DEFINE ALLFRENCH} //MC Fix

// If this flag is defined user dictionaries are update the same time a word
// is added. On the other hand the dictionary is not saved at the end
{$DEFINE USERDIC_INSTANTUPDATE}

// Is this is set the DCT files will be completely loaded
// Not that the memory consuption of a dictionary is relatively small -
// exactly the size of the dictionary
{--$DEFINE DEFAULT_INMEM}

const
  WPSpellBufferMinSize = 32000; // Dicts smaller than this are always loaded completely
  DEFAULT_USERDIC_NAME = 'USERDICT.DIC';

// Spellcheck Options
  WPSPELLOPT_IGNORECOMPOUND = 1; // no compound word checking
  WPSPELLOPT_IGNORECASE = 2; // Ignore the case
  WPSPELLOPT_IGNORENUMS = 4; // Ignore words with numbers
  WPSPELLOPT_IGNOREALLCAPS = 8; // Ignore all caps words

  WPSPELLOPT_AUTOCORRECT_CAPS = 16;
  WPSPELLOPT_AUTOCORRECT_LIST = 32;
  WPSPELLOPT_SPELLASYOUGO = 64;


type
  TWPSpellController = class;
  TWPSpellInterface = class;

  TWPCreateSpellPopupEvent = procedure(Sender: TWPSpellInterface;
    PopupMenu: TPopupMenu) of object;

  TWPSpellCheckStartMode = (wpCheckFromCursor, wpCheckFromStart);

  {:: This is the abstract interface to the editor which is
      currently spellchecked. It is used by the <see class="TWPSpellForm">. }
  TWPSpellInterface = class(TComponent)
  private
    FControl: TControl;
    function GetSpellController: TWPSpellController;
  protected
    _SupportAutoCorrect: Boolean;
    FAfterCreatePopup, FBeforeCreatePopup: TWPCreateSpellPopupEvent;
    procedure SetSpellAsYouGoIsActive(x: Boolean); virtual;
    function GetSpellAsYouGoIsActive: Boolean; virtual;
  public
    constructor Create(aOwner: TComponent); override;
    //:: Show the spllcheckr configuartion dialog
    procedure Configure;
    //:: Editor must be switched to edit mode. If not possible FALSE is returned
    function Changing: Boolean; virtual;
    //:: Text in editor was changed
    procedure Changed; virtual;
    //:: Skip word
    procedure Ignore(const aWord: string); virtual;
    //:: Add this word to the temporary ignore list
    procedure IgnoreAll(const aWord: string); virtual;
    //:: Learn this word
    procedure AddToUserDic(const aWord: string); virtual;
    //:: Replace this time
    procedure Replace(const aWord, ReplaceWord: string); virtual;
    //:: Replace all occurances of this word
    procedure ReplaceAll(const aWord, ReplaceWord: string); virtual;
    //:: Start at cursor position
    procedure StartNextWord; virtual;
    //:: Get next word to be checked
    function GetNextWord(var languageid: Integer): string; virtual;
    //:: Show the current cursor position and selection
    procedure MoveCursor; virtual;
    //:: lock the current selection
    procedure SaveState; virtual;
    //:: goto saved selection
    function RestoreState: Boolean; virtual;
    //:: Used to move the dialog if required
    function GetScreenXYWH(var X, Y, W, H: Integer): Boolean; virtual;
    //:: Go to the beginning of the document
    procedure ToStart; virtual;
    //:: Save  marker at current possition to select language
    procedure SelectLanguageFromHere(LanguageID: Integer); virtual;
    //:: Get the default language id for this text
    function GetDefaultLanguageID: Integer; virtual;
    //:: Update spellasyougo - for example if thge language changes
    procedure UpdateSpellAsYouGo(laststate: Boolean = FALSE); virtual;
    {:: Always applies the spell as you go markers. This can only work if 'Control' has
        been set properly }
    procedure DoSpellAsYouGo; virtual;
    {:: Starts the spellcheck of the given control. Also assigns the give control to
      the property 'Control' }
    procedure SpellCheck(ThisControl: TControl; mode: TWPSpellCheckStartMode); virtual;
    //:: Active Spellcontroller
    property SpellController: TWPSpellController read GetSpellController;
    //:: The current control which is checked
    property Control: TControl read FControl write FControl;
    //:: Do we use spellasyou go=
    property SpellAsYouGoIsActive: Boolean read GetSpellAsYouGoIsActive write SetSpellAsYouGoIsActive;
    //:: This event is triggered before the spellcheck popup menu is filled
    property AfterCreatePopup: TWPCreateSpellPopupEvent read FAfterCreatePopup write FAfterCreatePopup;
    //:: This event is triggered after the spellcheck popup menu has been filled
    property BeforeCreatePopup: TWPCreateSpellPopupEvent read FBeforeCreatePopup write FBeforeCreatePopup;
  end;


  {:: This is the header of a WPSpell Dictionary }
  TWPDctHeader = packed record
    Version: Byte; // 1=EDS style
    copyright: array[0..37] of Char; // WPCubed Text
    dummy: Byte; // for alignment
    magic: Cardinal; // = 2127301129
    Size: Word; // Length of this record
    codepage: Word; // Standard = 60000 for OEM
    languageid: Word; // \lang value
    userid: Word; // User Language ID (Diszipline!)
    options: Integer; // check compound, capital ...
    offnext: Integer; // Offset to next TWPDctHeader
    offmap: Integer; // Offset to character map (256 entries)
    offhyphrules: Integer; // Offset to hyphenation rules
    lenhyphrules: Integer; // Length of hyphenation rules
    offcapital: Integer; // Stringlist with all capitals GmBH ...
    lencapital: Integer; // Length of Stringlist with all capitals
    dictname: array[0..47] of Char; // Name of this dictionary (0 limited!)
    compiledate: TDateTime; // Set by Compiler
    updatedate: TDateTime; // Set by Update App
    reserved: Integer;
    reservedA: Integer;
    reservedB: Integer;
    reservedC: Integer;
    // ToUni  : array[0..255] of Word; macht das sinn ?
    // ToAnsi : array[0..255] of Byte;
  end;

  TWPInDictionaryMode = set of (
    wpInSuggestMode,
    wpInCheckSpellAsYouGo,
    wpAutoOpenDictionaries,
    wpDontCheckCapital,
    wpDontSearchCompound);

  TWPInDictionarySuggest = set of (
    wpSuggestAutoOpenDictionaries,
    wpSuggestFrequentMistakes,
    wpSuggestAccents,
    wpSuggestTwoWords,
    wpSuggestFirstVariation,
    wpSuggestRotatedChar,
    wpSuggestQWERTY,
    wpSuggestStartChar,
    wpSuggestSoundex
    );

  TWPInDictionaryResult = set of (
    wpNeedCapital,
    wpNeedAutoReplace);

  TWPDCTMemoryMode = (wpspellUseFile, wpspellUseMemory);


  TDiskEdge = Cardinal;

  EWPSpellDictFormatError = class(Exception);

  {:: This class manages one DCT file on the disc }
  TWPDCT = class(TObject)
  private
    FOverriddenID: Integer;
    _FoundSpecial: Integer;
    FParent: TWPSpellController;
    FDisabled: Boolean;
    FStream: TFileStream;
    FHeader: TWPDctHeader;
    FAbbreviation: TStringList;
    FJumpList: array of TDiskEdge;
    FLanguageIDGroup: Integer;
    FBuffer: array of Cardinal;
    FBufferPos: Integer;
    FBufferMax: Integer;
    FBufferSize: Integer;
    FFileName: string;
    FMemoryMode: TWPDCTMemoryMode;
    function GetDisabled: Boolean;
    procedure SetDisabled(x: Boolean);
    function GetOpen: Boolean;
    procedure SetOpen(x: Boolean);
    function GetName: string;
    function GetCodePage: Integer;
    function GetLanguageID: Integer;
    procedure SetLanguageID(x: Integer);
    function GetOptions: Integer;
    procedure SetFileName(x: string);
    procedure SetMemoryMode(x: TWPDCTMemoryMode);
    function Buffer(id: Integer): TDiskEdge;
    function MakeSoundEx(AWord: string; Pad: Boolean): string;
    function MatchSoundex(FSndx, WithWord: string): Boolean;
    function FirstChildID(ForChar: Char): Integer;
    function AdjustForDCT_in(aword: string): string;
    function AdjustForDCT_out(aword: string): string;
  public
    constructor Create;
    destructor Destroy; override;
    {:: Move up in the parent controller. Returns TRUE if this was possible. }
    function MoveUp: Boolean;
    {:: Move down in the parent controler. Returns TRUE if this was possible. }
    function MoveDown: Boolean;
    {:: If not open this function makes sure the header is loaded.
        If the result value is FALSE the header could not be loaded. }
    function Test: Boolean;
    {:: Looks up a word in the dictionary. The word must be passed in ANSI
      format matching the language ID of the dictionary. It should be also
      converted to lowercase }
    function InDictionary(AWord: string;
      Mode: TWPInDictionaryMode; var Res: TWPInDictionaryResult): Boolean;
    {:: Adds suggestions to the list }
    procedure Suggest(AWord: string; List: TStrings;
      MaxCount: Integer;
      SuggestMode: TWPInDictionarySuggest =
      [wpSuggestFrequentMistakes,
      wpSuggestAccents,
        wpSuggestTwoWords,
        wpSuggestFirstVariation,
        wpSuggestRotatedChar,
        wpSuggestQWERTY]);
    {:: Retrieves all word or a certain number from the dictionary. }
    procedure GetWordList(list: TStrings; maxcount: Integer = MaxInt);

    property Filename: string read FFileName write SetFileName;
    property Open: Boolean read GetOpen write SetOpen;
    property Disabled: Boolean read GetDisabled write SetDisabled;
    property Name: string read GetName;
    property CodePage: Integer read GetCodePage;
    property LanguageID: Integer read GetLanguageID write SetLanguageID;
    property LanguageIDGroup: Integer read FLanguageIDGroup;
    property Options: Integer read GetOptions;
    property MemoryMode: TWPDCTMemoryMode read FMemoryMode write SetMemoryMode;
  end;

  TWPUserDicMode = (wpUserAdded, wpUserExcluded, wpUserReplace, wpUserDeleted);

  {:: This is a word is the user dictionary }
  TWPUserDicEntry = class(TObject)
  private
    FReplace: string;
    FMode: TWPUserDicMode;
  public
    property ReplaceText: string read FReplace;
    property Mode: TWPUserDicMode read FMode;
  end;

  {:: This class manages one user dictionary. User dictionaries are
     saved as standard text files (similar to Word) but can also contain
     2 special entries which are marked with = and # as first characters <br>
     Example:<br>
     Delphi           - simple entry<br>
     =Delhpi=Delphi   - auto correction entry (note the 2 = signs)<br>
     #Delhpi          - This word is always wrong = removed from main dictionary<br>
  }
  TWPUserDic = class(TObject)
  private
    Parent: TWPSpellController;
    FFileName: string;
    FWords: TStringList; // Object=nil or  TWPUserDicEntry
    FLoaded: Boolean;
    FUpdateCount: Integer;
    FModified: Boolean;
    function GetStandard: Boolean;
    function GetWords: TStrings;
    procedure SetStandard(x: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Load;
    procedure Save;
    procedure Remove;
    procedure ListWords(list: TStrings);
    function Suggest(aWord: string; list: TStrings): Boolean;
    property Words: TStrings read GetWords;
    property Standard: Boolean read GetStandard write SetStandard;
    procedure Add(const aWord, aReplace: string; Mode: TWPUserDicMode);
    function Find(const aWord: string; var entry: TWPUserDicEntry): Boolean;
    property FileName: string read FFileName write FFileName;
    property UpdateCount: Integer read FUpdateCount;
  end;

  TWPSpellControllerPersistencyMode = (wpUseRegistry, wpUseINIFile, wpNoPersistency);

  {:: One of this class must always be created
   in the application to make spellcheck available.
   It is only possible to have one active
   instance at a time }
  TWPSpellController = class(TComponent)
  private
    FRegistryPath: string;
    FINIfilePath: string;
    FWasLoaded: Boolean;
    FAutoReplacedWord: string;
    FInitialDirectory: string;
    FOptionalParams: string;
    FOptionFlags: Integer;
    FSupportAutoCorrect: Boolean;
    FPersistencyMode: TWPSpellControllerPersistencyMode;
    FAllDCTs: TList;
    FLanguageHasChanged: Boolean;
    FAllLanguages: TStringList;
    FIgnoreList: TStringList;
    FCurrentLanguage, FCurrentLanguageGroup: Integer;
    FCurrentLanguageName: string;
    FSoundexScanTable: TStringList;
    FSuggestMode: TWPInDictionarySuggest;
    FDisabledFiles: TStringList;
    FUserDicts: TList; // [TWPUserDic]
    FDlgLeft, FDlgTop: Integer;
    FMemoryMode: TWPDCTMemoryMode;
    FAfterCreatePopup, FBeforeCreatePopup: TWPCreateSpellPopupEvent;
    function GetUserDictCount: Integer;
    function GetUserDict(index: Integer): TWPUserDic;
    function GetActive: Boolean;
    procedure SetActive(x: Boolean);
    function GetDCT(index: Integer): TWPDCT;
    function GetDCTCount: Integer;
    function GetLanguageID(index: Integer): Integer;
    function GetLanguageName(index: Integer): string;
    function GetLanguageIDCount: Integer;
    function GetSoundexScanTable: TStrings;
    procedure SetSoundexScanTable(x: TStrings);
    function GetDisabledFiles: TStrings;
    procedure SetDisabledFiles(x: TStrings);
    procedure SetCurrentLanguage(x: Integer);
    procedure SetOptionFlags(x: Integer);
    procedure SetMemoryMode(x: TWPDCTMemoryMode);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure AutoSaveSetup; virtual;
    procedure Loaded; override;
    {:: Show the configuration dialog. }
    function Configure: Boolean;

    procedure SaveSetup(AsINI: Boolean);
    procedure LoadSetup(AsINI: Boolean);
    {:: Removes all dictionaries }
    procedure ClearAll;
    {:: Adds all valid dictionaries in a certain path. Expects
      dictionaries to have *.DCT extension.  }
    procedure AddFromPath(path: string);
    {:: Adds one DCT file. Retuns nil if not found. }
    function AddFromFile(s: string): TWPDCT;
    {:: Adds/Find User dictionary }
    function UserDictAdd(path: string): TWPUserDic;
    {:: Removes User Dictionary }
    procedure UserDictRemove(path: string);
    {:: called from the interface TWPToolsSpellInterface only to trigger
       the AfterCreatePopup event. }
    procedure DoAfterCreatePopup(Sender: TWPSpellInterface; PopupMenu: TPopupMenu); virtual;
    {:: called from the interface TWPToolsSpellInterface only to trigger
       the BeforeCreatePopup event. }
    procedure DoBeforeCreatePopup(Sender: TWPSpellInterface; PopupMenu: TPopupMenu); virtual;


    procedure Suggest(AWord: string; List: TStrings;
      MaxCount: Integer;
      SuggestMode: TWPInDictionarySuggest =
      [wpSuggestFrequentMistakes,
      wpSuggestAccents,
        wpSuggestTwoWords,
        wpSuggestFirstVariation,
        wpSuggestRotatedChar,
        wpSuggestQWERTY]);

    {:: This method adds a word to the first user dictionary. If no user dictionary
     has been defined it will be created in the application path using the
     name DEFAULT_USERDIC_NAME 'USERDICT.DIC'.<br>
     If the compiler symbol USERDIC_INSTANTUPDATE is defined the user
     dictionaries are updated at once. This makes sure the words are not lost
     even if different applications use the same dictionary - although the
     changes are not automatically available to the other dictionary since the
     updates are always appended to the dictionary file. }
    procedure AddWord(const aWord, aReplace: string; Mode: TWPUserDicMode);

    {:: This procedure adds a word to the ignore list. This is list
        is not saved }
    procedure IgnoreWord(aWord: string);
    {:: This function searches through the dictionaries which are
        currently selected by the <see property="CurrentLanguage"> property.
        If the word was not found or is known to be incorrect
        FALSE is returned. In this case the flags in parameter res can be used
        to check if the word is wrong because it is lowercase or
        if the property <see property="AutoReplacedWord"> has been already set
        to a replacement for this word. }
    function InDictionary(AWord: string;
      Mode: TWPInDictionaryMode;
      var Res: TWPInDictionaryResult): Boolean;

    {:: Adds a certain dictionary. The result value is nil if the
      dictionary cannot be loaded. }
    function FindDCT(s: string): TWPDCT;
    procedure RemoveDCT(dct: TWPDCT);

    property DCTCount: Integer read GetDCTCount;
    property DCT[index: Integer]: TWPDCT read GetDCT;
    //:: This property counts how many different language groups are available
    property LanguageIDCount: Integer read GetLanguageIDCount;
    //:: This property gives access to this language group
    property LanguageID[index: Integer]: Integer read GetLanguageID;
    property LanguageName[index: Integer]: string read GetLanguageName;
    property UserDictCount: Integer read GetUserDictCount;
    property UserDict[index: Integer]: TWPUserDic read GetUserDict;
    property DlgLeft: Integer read FDlgLeft write FDlgLeft;
    property DlgTop: Integer read FDlgTop write FDlgTop;
    {:: This property is set by the method <see method="InDictionary"> }
    property AutoReplacedWord: string read FAutoReplacedWord;
    {:: This property is set to false by the SpellcheckInterface if it does not
      support auto correction }
    property SupportAutoCorrect: Boolean read FSupportAutoCorrect write FSupportAutoCorrect;
    {:: This property is set to TRUE by the Configure dialog if the
    language or dictionary was checked. This is useful to reapply the spellasyougo process. }
    property LanguageHasChanged: Boolean read FLanguageHasChanged;
  published
    property Active: Boolean read GetActive write SetActive;
    property SoundexScanTable: TStrings read GetSoundexScanTable write SetSoundexScanTable;
    {:: Usually all DCT files which are loaded are enabled if the
      selected language code is either neutral or the
      same as the language code for the text we are checking.
      This list can be used to disable files, they will be
      loaded but marked as deactivated}
    property DisabledFiles: TStrings read GetDisabledFiles write SetDisabledFiles;
    property SuggestMode: TWPInDictionarySuggest read FSuggestMode write FSuggestMode;
    property InitialDirectory: string read FInitialDirectory write FInitialDirectory;
    property OptionalParams: string read FOptionalParams write FOptionalParams;
    property RegistryPath: string read FRegistryPath write FRegistryPath;
    property INIFilePath: string read FINIfilePath write FINIfilePath;
    {:: So, if PersistencyMode  is set to wpNoPersistency nothing will be saved
     automatically, you can use SaveSetup/LoadSetup. Of course note the
     properties RegistryPath and INIfilePath! In case they have not been modified
     an automatic value will be used. '[app]wpspell.ini' and 'Software\WPCubed\WPSpell'.
     <br>
While the location of the dictionaries is saved for all instances of WPSpell -
the CurrentLanguage is saved in a key which is buiult using the application names.
So different applications can share the dictionaries but do not share the user setting.
}
    property PersistencyMode: TWPSpellControllerPersistencyMode
      read FPersistencyMode write FPersistencyMode;
    property OptionFlags: Integer read FOptionFlags write SetOptionFlags;
    {:: This property selects the current language group. The dictionary
        search and suggest methods will selects the dictionaries if they are
        active and member of the same group as CurrentLanguage is!
        <br>
        The property <b>CurrentLanguage</b> controls which lanuage is
        currently checked. All dictionaries which use the language ID will be
        selected. LanguageIDs are defined in the file WPLanguages.INC.
        CurrentLanguage can either use the id or the group id. Usually
        the group ids are more effective: English=9, Frensh=1036, German=1031, Spanish=1034

        }
    property CurrentLanguage: Integer read FCurrentLanguage write SetCurrentLanguage;
    property CurrentLanguageName: string read FCurrentLanguageName;
    property MemoryMode: TWPDCTMemoryMode read FMemoryMode write SetMemoryMode;
    //:: This event is triggered before the spellcheck popup menu is filled
    property AfterCreatePopup: TWPCreateSpellPopupEvent read FAfterCreatePopup write FAfterCreatePopup;
    {:: This event is triggered after the spellcheck popup menu has been filled. Similar to
       <see event="AfterCreatePopup"> it can be used to add items to the spell-as-you-go
       popup menu:
       <code>
procedure TWPToolsSpellDemoEditor.ClickBold(Sender : TObject);
begin
   WPRichText1.TextCursor.CurrAttribute.IncludeStyle(afsBold);
end;

procedure TWPToolsSpellDemoEditor.DoBeforeCreatePopup(Sender : TWPSpellInterface; PopupMenu : TPopupMenu);
var men : TMenuItem;
begin
   men := TMenuItem.Create(PopupMenu);
   men.OnClick := ClickBold;
   men.Caption := 'Bold';
   PopupMenu.Items.Add(men);
end;
       </code> }
    property BeforeCreatePopup: TWPCreateSpellPopupEvent read FBeforeCreatePopup write FBeforeCreatePopup;
  end;

  TWPCustomSpellOptionForm = class(TForm)
  public
    SpellControler: TWPSpellController;
  end;
  TWPCustomSpellOptionFormClass = class of TWPCustomSpellOptionForm;

  TWPGetSLanguages = function: TWPSLanguages;

procedure Register;

var glWPSpellController: TWPSpellController;
  glWPSpellOptionForm: TWPCustomSpellOptionFormClass;
  WPSpellCurrentLabelLanguage: TWPSLanguages;
  WPGetSpellCurrentLabelLanguage: TWPGetSLanguages;

implementation

uses Math;

const
  flNodeEnd: Cardinal = $00800000; // 0000 0000 1000 0000
  flWordEnd: Cardinal = $00400000; // 0000 0000 0100 0000
  flCapital: Cardinal = $00200000; // 0000 0000 0010 0000
  fsSpecialChar: Cardinal = $00100000; // 0000 0000 0001 0000

  OPTION_HANDLECAPITAL = 1; // if first char is capital then it is saved
  // lowercase with a certain flag at the end
  OPTION_HANDLECOMPOUND = 2; //RESERVED: SpecialChars are compound
  OPTION_HANDLEALLCOMPOUND = 4; //Build all kind of compound words
  // Res 8:

  OPTION_FRENCH_L = 32; // french L' rule
  OPTION_EXPECT_COMP = 64; // expect compounds built with -

  OPTION_STRIP_AP_S = 512; // Strip 's  (only Write)
  OPTION_STRIP_ANY_AP = 1024; // Strip any char apostrophe l'  (only Write)
  OPTION_SPLIT_AT_MINUS = 2048; // Split at minus                (only Write)
  OPTION_REMOVELAST_S = 4096; // old style (only READ!)
  OPTION_LOWERCASESTR = 8192; // old style
  OPTION_OEMCONVERTRSTR = 16384; // old style (only READ!)

  // This word has a special meaning. It is not found on its own!
  WPSpellSpecialChar = ['+', '&', '$', '§', '#'];

procedure Register;
begin
  RegisterComponents('WPTools', [TWPSpellController]);
end;

// ----------------------------------------
// ----------- utility --------------------
// ----------------------------------------


function VerifyHeader(var FHeader: TWPDctHeader; FFileName: string): Boolean;
var
  i, l: Integer;
begin
  l := 0;
  for i := 0 to 37 do
  begin
    l := l + Integer(FHeader.copyright[i]) * i;
    if (i and 1) = 1 then l := l + Integer(FHeader.copyright[i]) div 3;
  end;

  if (FHeader.copyright[37] = 'f') and (l = 59655) then
  begin
    fillchar(FHeader, SizeOf(FHeader), 0);
    FHeader.codepage := 60000;
    FHeader.version := 1;
    FHeader.Size := 83; // This is an old style header
    FHeader.options := OPTION_REMOVELAST_S +
      OPTION_LOWERCASESTR + OPTION_OEMCONVERTRSTR;
    StrPLCopy(@FHeader.dictname[0],
      ExtractFileName(FFileName), 46);
    Result := TRUE;
  end
  else if (l = 60487) and (FHeader.magic = 2127301129) then
  begin
    Result := TRUE;
    if FHeader.dictname[0] = #0 then
      StrPLCopy(@FHeader.dictname[0],
        ExtractFileName(FFileName), 46);
  end
  else Result := FALSE;
end;

function WPSpellLowercase(s: string; CodePage: Integer): string;
begin
  if CodePage <> 60000 then
    Result := AnsiLowerCase(s)
  else Result := LowerCase(s); // Use the simple form for OEM
end;

function WPSpellCapitalize(s: string; CodePage: Integer): string;
begin
  Result := s;
  AnsiUpperBuff(PChar(Result), 1);
end;

{ LowCaseChars : string =
          ('üéâäàåçêëèïîìæôöòûìÿáíóúñ');
        UpCaseChars : string =
          ('ÜÉAÄAÅÇEEEIIIÆOÖOUIYAIOUÑ');  }

function WPSpellIsUppercase(s: string; CodePage: Integer): Boolean;
begin
  Result := (s <> '') and (AnsiLowerCase(s[1]) <> s[1]);
end;


{$IFDEF OLDDELPHI} // not defined in Delphi 4

procedure FreeAndNil(var Obj);
var
  P: TObject;
begin
  P := TObject(Obj);
  TObject(Obj) := nil;
  P.Free;
end;
{$ENDIF}


// ----------------------------------------
// ----------- one dictionary -------------
// ----------------------------------------

constructor TWPDCT.Create;
begin
  inherited Create;
  FFileName := '';
  FBuffer := nil;
  FJumpList := nil;
  FAbbreviation := TStringList.Create;
  FAbbreviation.Sorted := TRUE;
{$IFNDEF OLDDELPHI}
  FAbbreviation.CaseSensitive := FALSE;
{$ENDIF}
  FillChar(FHeader, SizeOf(FHeader), 0);
  FStream := nil;
end;

destructor TWPDCT.Destroy;
begin
  FreeAndNil(FStream);
  FFileName := '';
  FAbbreviation.Free;
  FBuffer := nil;
  FJumpList := nil;
  inherited Destroy;
end;

function TWPDCT.GetOpen: Boolean;
begin
  if FMemoryMode = wpspellUseMemory then
    Result := FBuffer <> nil
  else Result := FStream <> nil;
end;

function TWPDCT.GetDisabled: Boolean;
begin
  if FParent = nil then
    Result := FDisabled
  else
  begin
    Result := (FParent.FDisabledFiles.IndexOf(FFileName) >= 0);
    FDisabled := Result;
  end;
end;

procedure TWPDCT.SetDisabled(x: Boolean);
var i: Integer;
begin
  FDisabled := x;
  if FParent <> nil then
  begin
    i := FParent.FDisabledFiles.IndexOf(FFileName);
    if x and (i < 0) then FParent.FDisabledFiles.Add(FFileName)
    else if not x and (i >= 0) then FParent.FDisabledFiles.Delete(i);
  end;
end;

function TWPDCT.GetName: string;
begin
  Result := StrPas(FHeader.dictname);
end;

function TWPDCT.GetCodePage: Integer;
begin
  Result := FHeader.codepage;
end;

procedure TWPDCT.SetLanguageID(x: Integer);
var j: Integer;
begin
  if FHeader.languageid = x then
    FOverriddenID := 0
  else FOverriddenID := x;
  FLanguageIDGroup := GetLanguageID;
  if FLanguageIDGroup <> 0 then
    for j := 0 to Length(wplanguages) - 1 do
      if wplanguages[j].id = FLanguageIDGroup then
      begin
        FLanguageIDGroup := wplanguages[j].groupid;
        break;
      end;
end;

function TWPDCT.GetLanguageID: Integer;
begin
  if FOverriddenID <> 0 then
    Result := FOverriddenID
  else Result := FHeader.languageid;
end;

function TWPDCT.GetOptions: Integer;
begin
  Result := FHeader.options;
end;

procedure TWPDCT.SetFileName(x: string);
var o: Boolean;
begin
  if CompareText(FFileName, x) <> 0 then
  begin
    o := Open;
    Open := FALSE;
    FFileName := x;
    Open := o;
  end;
end;

function TWPDCT.Buffer(id: Integer): TDiskEdge;
begin
  if (id >= FBufferPos) and (id < FBufferPos + FBufferSize) then
    Result := FBuffer[id - FBufferPos]
  else
    if (id >= FBufferMax) or
      (FStream = nil) or
      (MemoryMode = wpspellUseMemory) then Result := flNodeEnd
    else
    begin
      FBufferPos := id - 1000;
      if FBufferPos < 0 then FBufferPos := 0;
      FStream.Position := FHeader.Size + FBufferPos * SizeOf(TDiskEdge);
      FStream.Read(FBuffer[1], FBufferSize * SizeOf(TDiskEdge));
      Result := FBuffer[id - FBufferPos];
    end;
end;

function TWPDCT.AdjustForDCT_in(aword: string): string;
begin
  if FHeader.codepage = 60000 then
  begin
    SetLength(Result, Length(aword));
    AnsiToOem(PChar(aword), PChar(Result));
  end
  else Result := aword;
end;

function TWPDCT.AdjustForDCT_out(aword: string): string;
begin
  if FHeader.codepage = 60000 then
  begin
    OemToAnsi(PChar(aword), PChar(aword));
  end;
  Result := aword;
end;

procedure TWPDCT.SetMemoryMode(x: TWPDCTMemoryMode);
var o: Boolean;
begin
  if x <> FMemoryMode then
  begin
    o := Open;
    Open := FALSE;
    FMemoryMode := x;
    Open := o;
  end;
end;

function TWPDCT.MoveUp: Boolean;
var i: Integer;
begin
  Result := FALSE;
  if FParent <> nil then
  begin
    i := FParent.FAllDCTs.IndexOf(Self);
    if i > 0 then
    begin
      FParent.FAllDCTs.Exchange(i, i - 1);
      Result := TRUE;
    end;
  end;
end;


function TWPDCT.MoveDown: Boolean;
var i: Integer;
begin
  Result := FALSE;
  if FParent <> nil then
  begin
    i := FParent.FAllDCTs.IndexOf(Self);
    if (i >= 0) and (i < FParent.FAllDCTs.Count - 1) then
    begin
      FParent.FAllDCTs.Exchange(i, i + 1);
      Result := TRUE;
    end;
  end;
end;

function TWPDCT.InDictionary(AWord: string; Mode: TWPInDictionaryMode;
  var Res: TWPInDictionaryResult): Boolean;
  function Buffer(id: Integer): TDiskEdge;
  begin
    if (id >= FBufferPos) and (id < FBufferPos + FBufferSize) then
      Result := FBuffer[id - FBufferPos]
    else
      if (id >= FBufferMax) or
        (FStream = nil) or
        (MemoryMode = wpspellUseMemory) then Result := flNodeEnd
      else
      begin
        FBufferPos := id - 1000;
        if FBufferPos < 0 then FBufferPos := 0;
        FStream.Position := FHeader.Size + FBufferPos * SizeOf(TDiskEdge);
        FStream.Read(FBuffer[1], FBufferSize * SizeOf(TDiskEdge));
        Result := FBuffer[id - FBufferPos];
      end;
  end;
  // ---------------------------------------------------------------------------
  function ScanNode(StartEdge: Longint; ForLetter: Cardinal): TDiskEdge;
  begin
    Result := Buffer(StartEdge);
    while (((Result and $FF000000)) <> ForLetter) and
      (Result and flNodeEnd = 0) do
    begin
      Inc(StartEdge);
      Result := Buffer(StartEdge);
    end;
  end;
  // Initialize the first ID array ---------------------------------------------
  procedure InitJumpList;
  var
    CurEdge: TDiskEdge;
    StartEdge: Integer;
  begin
    FJumpList := nil;
    SetLength(FJumpList, 256);
    StartEdge := 1; // the first!
    CurEdge := Buffer(StartEdge);
    while (CurEdge and flNodeEnd) = 0 do
    begin
      FJumpList[(CurEdge and $FF000000) shr 24] := CurEdge;
      Inc(StartEdge);
      CurEdge := Buffer(StartEdge);
    end;
  end;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var
  CurEdge: TDiskEdge;
  EdgeID: Longint;
  i, l: Integer;
  is_capital, capital, SearchCompound: Boolean;
  OrgWord: string;
label FoundEdge;
begin
  Result := FALSE;
  l := Length(AWord);
  if l = 0 then exit;
  _FoundSpecial := -1;
  OrgWord := AWord;

  // This language supports compound ----------------------------
  // also see OPTION_HANDLECAPITAL
  SearchCompound :=
    ((FHeader.options and OPTION_HANDLEALLCOMPOUND) <> 0) and
    ((Mode * [wpDontSearchCompound, wpInSuggestMode]) = []);

  // -------------- First check abbreviation list ---------------
  if not (wpInSuggestMode in Mode) then
  begin
{$IFDEF OLDDELPHI}
    i := FAbbreviation.Count - 1;
    while i >= 0 do //was: while i > 0 do
    begin
      if CompareText(FAbbreviation[i], OrgWord) = 0 then break;
      dec(i);
    end;
{$ELSE}
    i := FAbbreviation.IndexOf(OrgWord);
{$ENDIF}
    if (i >= 0) and (FAbbreviation[i] <> OrgWord) then
    begin
      Result := FALSE;
      exit;
    end;
  end;

  is_capital := WPSpellIsUppercase(AWord[1], FHeader.codepage);
  if (FHeader.options and OPTION_HANDLECAPITAL) <> 0 then
  begin
    capital := is_capital;
    AWord := WPSpellLowercase(AWord, FHeader.codepage);
    // Only captital words can be Compound
    if not capital then
      SearchCompound := FALSE;
  end else capital := FALSE;

  {$IFNDEF ALLFRENCH}
  if ((FHeader.options and OPTION_LOWERCASESTR)<>0)or(FHeader.codepage=60000) then
  {$ENDIF}
   AWord := WPSpellLowercase(AWord, FHeader.codepage);


  // French l' rule checking  (word is already lowercase)
  if (FHeader.options and OPTION_FRENCH_L) <> 0 then
  begin
    if (l > 2) and (AWord[2] = #39) then
    begin
      if AWord[3] = 'h' then i := 4 else i := 3;
      if (l > 2) and (AWord[2] = #39) and
        (AWord[1] in ['l', 'd', 's', 'j', 'n', 'm', 't']) and
        (AWord[i] in ['a', 'e', 'i', 'o', 'u', 'y',
                      'é',
                      'ä', 'ï', 'ö', 'ü', 'ë',
                      'à', 'è', 'ù',
                      'â', 'ê', 'î', 'ô', 'û'])
                       and ((l < i + 2) or (AWord[i + 2] <> #39)) // skip L' words in DCT
      then
      begin
        dec(l, 2);
        AWord := Copy(AWord, 3, l);
      end;
    end;
  end;

  // if the end of the word has an 's remove it and check
 { if (FHeader.options and OPTION_REMOVELAST_S)<>0 then
  begin
    if AWord[l]='s' then dec(l);
  end; }

  // Optimation - use JUMPARRAY for first character ----------------------------
  if FJumpList = nil then InitJumpList;
  CurEdge := FJumpList[Byte(AWord[1])];
  if (CurEdge = 0) or (l < 2) then exit
  else
  begin
    i := 1;
    goto FoundEdge; //  We jump right in ...
  end;
  // i:=1; EdgeID := 1; // non optimized!
  // ---------------------------------------------------------------------------

  while (EdgeID <> 0) and (i <= l) do
  begin
    CurEdge := ScanNode(EdgeID, Byte(AWord[i]) shl 24);
    if Char((CurEdge and $FF000000) shr 24) = AWord[i] then
    begin
      FoundEdge: // we come from FJumpList!
      if (CurEdge and fsSpecialChar <> 0) then
        _FoundSpecial := i;
      inc(i);
      if (CurEdge and flWordEnd <> 0) then
      begin
        if (i > l) then
        begin
          if ((FHeader.options and OPTION_HANDLECAPITAL) <> 0) and
            (CurEdge and flCapital <> 0) then
            include(Res, wpNeedCapital);

          if not (wpDontCheckCapital in Mode) and
            not capital and
            ((FHeader.options and OPTION_HANDLECAPITAL) <> 0) and
            (CurEdge and flCapital <> 0) then
            Result := FALSE // MUST BE CAPITAL!!
          else Result := TRUE;
          Break;
        end else
          if SearchCompound then
          begin
            if InDictionary(Copy(AWord, i, Length(AWord)),
              [wpInSuggestMode, wpDontCheckCapital, wpDontSearchCompound],
              Res) then
            begin
              Result := TRUE;
              break;
            end;
          end;
      end;
      EdgeID := CurEdge and $0007FFFF;
      if EdgeID = 0 then
      begin
        Result := FALSE;
        // no more children to scan (word not found)
        Break;
      end; {  if...}
    end
    else
    begin
      Result := FALSE;
      // not found :-(
      Break;
    end; {  if...}
  end; {  while }
end;

// -----------------------------------------------------------------------------

function TWPDCT.MakeSoundEx(AWord: string; Pad: Boolean): string;
const
  SoundexSize = 4;
var
  i: Integer;
  SXChar: char;
begin
  //  AWord := UpperCase (UnInternationalize (AWord));
  // AWord := UpperCase(Internationalize(AWord));  <----------JZ
  // translate according to SXTable
  AWord := ANSIUpperCase(AWord);
  i := 2; {keep first letter}
  while i <= Length(AWord) do
  begin
     { case AWord[i] of
             'Ä', 'Á', 'À', 'Ö','Ü','ä','ö','ü',
             'A','E', 'É', 'È', 'H','I','O','U','W','Y' : SXChar := '0';
             'B','F','P','V'                 : SXChar := '1';
             'C','G','J','K','Q','S','X','Z' : SXChar := '2';
             'D','T'                         : SXChar := '3';
             'L'                             : SXChar := '4';
             'M','N'                         : SXChar := '5';
             'R'                             : SXChar := '6';
             else SXChar := #0;
      end; }

    case AWord[i] of
      'E', 'É', 'È': SXChar := '1';
      'Ä', 'ä', 'A', 'I', 'Y': SXChar := '2';
      'O', 'U', 'Ö', 'ö', 'Ü', 'ü': SXChar := '3';
      'B', 'F', 'P', 'V': SXChar := '4';
      'C', 'G', 'J', 'K', 'Q': SXChar := '5';
      'S', 'ß', 'X', 'Z': SXChar := '6';
      'D', 'T': SXChar := '7';
      'L': SXChar := '8';
      'M', 'N': SXChar := '9';
      'R': SXChar := '*';
    else SXChar := #0;
    end;


    if SXChar = #0 then Inc(i)
    else if SXChar <> '0' then
    begin
      if (i > 2) and (SXChar = AWord[i - 1]) then
      begin
          // remove duplicates
        System.Delete(AWord, i, 1);
      end {:}
      else
      begin
        AWord[i] := SXChar;
        Inc(i);
      end; { else }
    end
    else
        // remove vowels
      System.Delete(AWord, i, 1);

  end; { while }

  (*
  // remove duplicates
  i := 2;  // don't do first letter (used for Soundex: A123)
  while i < Length (AWord) do
  begin
    if AWord[i] = AWord[i+1] then
      System.Delete (AWord, i, 1)
    else
      Inc(i);
  end;  { while }
  *)
  if Length(AWord) < SoundexSize then
  begin
    // if less than SoundexSize add zeros to end
    if Pad then
      while Length(AWord) < SoundexSize do
        AWord := AWord + '0';
  end
  else
    // truncate to SoundexSize
    AWord := Copy(AWord, 1, SoundexSize);

  Result := lowercase(AWord);
end;

function TWPDCT.MatchSoundex(FSndx, WithWord: string): Boolean;
var
  WithSndX: string;
  WithLen: Integer;
begin
  WithSndx := MakeSoundEx(WithWord, FALSE);
  WithLen := Length(WithSndX);
  Result := Copy(FSndx, 1, WithLen) = WithSndX;
end;

// -----------------------------------------------------------------------------

function TWPDCT.FirstChildID(ForChar: Char): Integer;
var
  CurEdge: TDiskEdge;
  CurNum: byte;
  ForLetter: Cardinal;
begin
  CurNum := 1;
  CurEdge := Buffer(CurNum);
  ForLetter := Cardinal(ForChar) shl 24;

  while (CurEdge and $FF000000 <> ForLetter) and
    (CurEdge and flNodeEnd = 0) do
  begin
    Inc(CurNum);
    CurEdge := Buffer(CurNum);
  end; { while }
  if CurEdge and $FF000000 = ForLetter then
    Result := CurEdge and $0007FFFF
  else
    Result := 0;
end;

// -----------------------------------------------------------------------------

procedure TWPDCT.Suggest(AWord: string; List: TStrings;
  MaxCount: Integer;
  SuggestMode: TWPInDictionarySuggest =
  [wpSuggestFrequentMistakes,
  wpSuggestAccents,
    wpSuggestTwoWords,
    wpSuggestFirstVariation,
    wpSuggestRotatedChar,
    wpSuggestQWERTY]);
var
  Mode: TWPInDictionaryMode;
  Res, Res2: TWPInDictionaryResult;
  is_capital: Boolean;
  // Add one word - break if full ---------------------------------
  function AddWord(ThisWord: string): Boolean;
  begin
    if List.Count > MaxCount then Result := FALSE
    else
    begin
      ThisWord := AdjustForDCT_out(ThisWord);
      if is_capital or (wpNeedCapital in Res) then
        ThisWord := WPSpellCapitalize(ThisWord, FHeader.codepage);
      if wpNeedCapital in Res then
        ThisWord[1] := UpCase(ThisWord[1]);
      if List.IndexOf(ThisWord) < 0 then
        List.Add(ThisWord);
      Result := TRUE;
    end;
    Res := [];
  end;
  // Try to split up this word ------------------------------------
  procedure SuggestTwoWords(SuggestNum: Integer);
  var
    i: byte;
    Hits: byte;
    FirstWord: string;
    LastWord: string;
  begin
    Hits := 0;
    // Min 3 char length !
    for i := 3 to Length(AWord) - 3 do
    begin
      FirstWord := Copy(AWord, 1, i);
      LastWord := Copy(AWord, i + 1, 255);
      Mode := [wpDontCheckCapital];
      Res := [];
      Res2 := [];
      if InDictionary(FirstWord, Mode, Res) and
        InDictionary(LastWord, Mode, Res2) then
      begin
        if List.Count > MaxCount then break;
        Inc(Hits);
        if wpNeedCapital in Res then
          FirstWord[1] := UpCase(FirstWord[1]);
        if wpNeedCapital in Res2 then
          LastWord[1] := UpCase(LastWord[1]);
        AddWord(FirstWord + ' ' + LastWord);

      end; {  if...}
      if Hits = SuggestNum then
        Break;
    end;
  end;
  // -------- Try variations of this word using a table . max one!
  procedure SuggestQWERTY;
  var s: string;
  const qwertyH: string = 'qwertyuiopasdfghjklzxcvbnm';
    qwertyV: string = 'yaqxswcdevfrbgtnhzmjukilop';
    procedure DoIt(const qwerty: string);
    var i, j: Integer;
    begin
      for i := 1 to Length(AWord) do
      begin
        j := Pos(AWord[i], qwerty);
        if j > 1 then
        begin
          s[i] := qwerty[j - 1];
          if InDictionary(s, Mode, Res) then
          begin
            AddWord(s);
            break;
          end;
        end;
        if (j > 0) and (j < Length(qwerty)) then
        begin
          s[i] := qwerty[j + 1];
          if InDictionary(s, Mode, Res) then
          begin
            AddWord(s);
            break;
          end;
        end;
        s[i] := AWord[i];
      end;
    end;
  begin
    s := AWord;
    DoIt(qwertyH);
    DoIt(qwertyV);
  end;
  // -------- Try variations of first char ---------------------------
  procedure SuggestFirst;
  var s: string;
    i: Integer;
  const chars: string = 'abcdefghijklmnopqrtstuvwxyzäöüéèáàúù';
  begin
    s := AWord;
    for i := 1 to Length(chars) do
    begin
      s[1] := chars[i];
      if InDictionary(s, Mode, Res) then
      begin
        if List.Count > MaxCount then break;
        AddWord(s);
        break;
      end;
    end;
  end;
  // -------- Insert missing chars -----------------------------
  procedure SuggestMissingChars;
  var s: string;
    i: Integer;
    a: Char;
  begin
    for i := 1 to Length(AWord) do
      for a := 'a' to 'z' do
      begin
        s := Copy(AWord, 1, i) + a +
          Copy(AWord, i + 1, Length(AWord));
        if InDictionary(s, Mode, Res) then
        begin
          if List.Count > MaxCount then break;
          AddWord(s);
        end;
      end;
  end;
  // -------- Delete chars in middle -----------------------------
  procedure SuggestWithoutChars;
  var s: string;
    i: Integer;
  begin
    if Length(AWord) >= 3 then // remove last char
    begin
      s := Copy(AWord, 1, Length(AWord) - 1);
      if InDictionary(s, Mode, Res) then
        AddWord(s);
    end;

    if Length(AWord) > 3 then
      for i := 2 to Length(AWord) - 1 do
      begin
        s := Copy(AWord, 1, i - 1) +
          Copy(AWord, i + 1, Length(AWord));
        if InDictionary(s, Mode, Res) then
        begin
          if List.Count > MaxCount then break;
          AddWord(s);
        end;
      end;
  end;
  // -------- Try orders of chars -----------------------------
  procedure SuggestRotatedChar;
  var s: string;
    i: Integer;
  begin
    for i := 2 to Length(AWord) do
    begin
      s := AWord;
      s[i - 1] := AWord[i];
      s[i] := AWord[i - 1];
      if InDictionary(s, Mode, Res) then
      begin
        if List.Count > MaxCount then break;
        AddWord(s);
        // break;
      end;
    end;
  end;
  // -------- Try typical writing mstakes --------------------------
  procedure SuggestFrequentMistakes;
  var s: string;
    i, j: Integer;
    c: Char;
  begin
    c := #0;
    // Istead of "summer" we wrote "summerr"
    if Length(AWord) > 8 then j := 4 else j := 2;
    if Length(AWord) > 5 then
      for i := Length(AWord) - j to Length(AWord) - 1 do
      begin
        s := Copy(Aword, 1, i);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
    // Istead of "summer" we wrote "sumeer"
    for i := 2 to Length(AWord) do
    begin
      if AWord[i] = c then
      begin
        s := AWord;
        s[i - 1] := s[i - 2];
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
      c := AWord[i];
    end;
    // Istead of "summer" we wrote "sumer"
    for i := 1 to Length(AWord) do
    begin
      s := Copy(AWord, 1, i) + AWord[i] +
        Copy(AWord, i + 1, 50);
      if InDictionary(s, Mode, Res) then
        AddWord(s);
    end;
    // Istead of "query" we wrote "qery" etc
    for i := 1 to Length(AWord) do
    begin
      if AWord[i] = 'q' then // q ->qu
      begin
        s := Copy(AWord, 1, i) + 'u' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
      if AWord[i] = 'f' then // f ->ph
      begin
        s := Copy(AWord, 1, i - 1) + 'ph' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
      if AWord[i] = 'ß' then // ß ->ss
      begin
        s := Copy(AWord, 1, i - 1) + 'ss' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
      if AWord[i] = 'o' then // o ->ou
      begin
        s := Copy(AWord, 1, i - 1) + 'ou' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
      if AWord[i] = 'u' then // u ->oo
      begin
        s := Copy(AWord, 1, i - 1) + 'ou' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
      if AWord[i] = 'k' then // k ->ch , ck
      begin
        s := Copy(AWord, 1, i - 1) + 'ch' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
        s := Copy(AWord, 1, i - 1) + 'ck' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
      if AWord[i] = 'o' then // o ->u
      begin
        s := Copy(AWord, 1, i - 1) + 'u' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
      if AWord[i] = 'u' then // u ->o
      begin
        s := Copy(AWord, 1, i - 1) + 'o' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
    end;
    if FLanguageIDGroup = 1036 then // french
    begin
      if (AWord[1] = 'h') or (AWord[1] = 'H') then // remove h
      begin
        s := Copy(AWord, 2, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end else // add 'h'
      begin
        s := 'h' + AWord;
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
    end;

    if (Length(AWord) > 2) and (AWord[2] <> #39) then
    begin
      s := AWord[1] + #32 + Copy(AWord, 2, 50);
      if InDictionary(s, Mode, Res) then
        AddWord(s);
    end;

    // Istead of "straße" we wrote "strasse" etc
    c := #0;
    for i := 1 to Length(AWord) do
    begin
      if (c = 's') and (AWord[i] = 's') then // ss ->ß
      begin
        s := Copy(AWord, 1, i - 1) + 'ß' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
      if (c = 's') and (AWord[i] = 's') then // ss ->s
      begin
        s := Copy(AWord, 1, i - 1) + 's' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
      if (c = 'p') and (AWord[i] = 'h') then // ph ->f
      begin
        s := Copy(AWord, 1, i - 1) + 'f' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
      if (c = 'q') and (AWord[i] = 'u') then // qu ->q
      begin
        s := Copy(AWord, 1, i - 1) + 'q' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
      if (c = 'o') and (AWord[i] = 'u') then // ou ->o
      begin
        s := Copy(AWord, 1, i - 1) + 'o' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
      if (c = 'o') and (AWord[i] = 'o') then // oo ->u
      begin
        s := Copy(AWord, 1, i - 1) + 'u' +
          Copy(AWord, i + 1, 50);
        if InDictionary(s, Mode, Res) then
          AddWord(s);
      end;
      c := AWord[i];
    end;
  end;
  // --------------------------------------------------------------
  procedure SuggestAccents;
  var i: Integer;
    s: string;
  begin

    for i := 1 to Length(AWord) do
    begin
      s := AWord;
      case AWord[i] of
        'a', 'ä', 'á', 'â', 'å': begin
            s[i] := 'ä'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'á'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'à'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'â'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'å'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'a'; if InDictionary(s, Mode, Res) then AddWord(s);
          end;
        'o', 'ö', 'ô', 'ó', 'ò': begin
            s[i] := 'ö'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'ô'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'ó'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'ò'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'o'; if InDictionary(s, Mode, Res) then AddWord(s);
          end;
        'u', 'ü', 'û', 'ú', 'ù': begin
            s[i] := 'ü'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'û'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'ú'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'ù'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'u'; if InDictionary(s, Mode, Res) then AddWord(s);
          end;
        'e', 'é', 'è', 'ê', 'ë': begin
            s[i] := 'é'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'è'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'ê'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'ë'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'e'; if InDictionary(s, Mode, Res) then AddWord(s);
          end;
        'i', 'í', 'ì', 'î', 'ï': begin
            s[i] := 'í'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'ì'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'î'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'ï'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'i'; if InDictionary(s, Mode, Res) then AddWord(s);
          end;
        'y', 'ý': begin
            s[i] := 'ý'; if InDictionary(s, Mode, Res) then AddWord(s);
            s[i] := 'y'; if InDictionary(s, Mode, Res) then AddWord(s);
          end;
      end;
    end;
  end;

  // --------------------------------------------------------------
  procedure SuggestSoundex;
  const MaxWordLength = 50; MaxSoundex = 4;
  var startstr, s: string;
    i, NewLength, NextID: Integer;
    FSndX, NewWord: string;
    MinHitLen, MaxHitLen: Integer;
    EdgeArray: array[2..MaxWordLength] of TDiskEdge;
    EdgeID: array[0..MaxWordLength] of Longint;
  begin
    startstr := Aword[1];
    if FParent <> nil then
    begin
      for i := 0 to FParent.SoundexScanTable.Count - 1 do
      begin
        s := FParent.SoundexScanTable[i];
        if s[1] = Aword[1] then
        begin
          Delete(s, Pos(':', s), 1);
          startstr := s;
          break;
        end;
      end;
    end;
    FSndX := MakeSoundEx(AWord, TRUE);
    MinHitLen := Length(AWord) - 2;
    MaxHitLen := Length(AWord) + 2;
    SetLength(FSndX, MaxSoundex);
    SetLength(NewWord, 0);
    for i := 1 to Length(startstr) do
    begin
      FSndX[1] := startstr[i];
      NewWord := FSndX[1];
      EdgeID[1] := FirstChildID(FSndX[1]);
      if (EdgeID[1] <> 0) then
        while Length(NewWord) > 0 do
        begin
          NewLength := Length(NewWord);
          EdgeArray[NewLength + 1] := Buffer(EdgeID[NewLength]);
          NewWord := NewWord +
            Char((EdgeArray[NewLength + 1] and $FF000000) shr 24);
          NewLength := Length(NewWord);
          if MatchSoundex(FSndX, NewWord) and
            (NewLength <= MaxHitLen) then
          begin
            if (EdgeArray[NewLength] and flWordEnd <> 0) and
              (NewLength >= MinHitLen) then
              if not AddWord(NewWord) then exit;
            NextID := EdgeArray[NewLength] and $0007FFFF;
            if NextID <> 0 then
            begin
              EdgeID[NewLength] := NextID;
              Continue;
            end;
          end;
          if (EdgeArray[NewLength] and flNodeEnd) <> 0 then
          begin
            repeat
              NewWord := Copy(NewWord, 1, NewLength - 1);
              NewLength := Length(NewWord);
            until (NewLength = 1) or (EdgeArray[NewLength] and flNodeEnd = 0);
          end; { if... }
          NewWord := Copy(NewWord, 1, NewLength - 1);
          NewLength := Length(NewWord);
          Inc(EdgeID[NewLength]);
        end;
    end;
  end;
  // -------------------------------------------------------------------------
  function ScanNode(StartEdge: Longint; ForLetter: Cardinal): TDiskEdge;
  begin
    Result := Buffer(StartEdge);
    while (((Result and $FF000000)) <> ForLetter) and
      (Result and flNodeEnd = 0) do
    begin
      Inc(StartEdge);
      Result := Buffer(StartEdge);
    end;
  end;
  function AddNode(StartText: string; StartEdge: Longint): Boolean;
  var e: Longint; c: Char; NewWord: string;
  begin
    e := Buffer(StartEdge);
    Result := TRUE;
    while Result and (e <> 0) do
    begin
      c := Char((e and $FF000000) shr 24);
      if ((e and flWordEnd) <> 0) then
      begin
        NewWord := StartText + c;
        if is_capital or (((FHeader.options and OPTION_HANDLECAPITAL) <> 0) and
          (e and flCapital <> 0)) then AnsiUpperBuff(@NewWord[1], 1);
        Result := AddWord(NewWord);
      end
      else Result := AddNode(StartText + c, e and $0007FFFF);
      if ((e and flNodeEnd) <> 0) then break;
      Inc(StartEdge);
      e := Buffer(StartEdge);
    end;
  end;
  // -------------------------------------------------------------------------
  procedure SuggestStartChar;
  var EdgeID: Longint;
    i, l: Integer;
  begin
    i := 2;
    l := Length(AWord);
    EdgeID := FirstChildID(Aword[1]);
    while (EdgeID <> 0) and (i <= l) do
    begin
      if i < l then EdgeID := ScanNode(EdgeID, Byte(AWord[i]) shl 24) and $0007FFFF
      else EdgeID := ScanNode(EdgeID, Byte(AWord[i]) shl 24);
      inc(i);
    end;
    AddNode(AWord, EdgeID and $0007FFFF);
  end;
  // ~~~~~~~~~~~~~~~~~~~~~~~ procedure TWPDCT.Suggest( ~~~~~~~~~~~~~~~~~~~~~~~~~
var i: Integer;
begin
  if AWord = '' then exit;
  Mode := [wpInSuggestMode, wpDontCheckCapital];
  Res := [];
  Res2 := [];
  is_capital := WPSpellIsUppercase(AWord[1], FHeader.codepage);
  AWord := WPSpellLowercase(AWord, CodePage);

  // Always check the abbreviations first and if found

{$IFDEF OLDDELPHI}
  i := FAbbreviation.Count - 1;
  while i >= 0 do
  begin
    if CompareText(FAbbreviation[i], AWord) = 0 then break;
    dec(i);
  end;
{$ELSE}
  i := FAbbreviation.IndexOf(AWord);
{$ENDIF}

  if i >= 0 then
  begin
    AddWord(FAbbreviation[i]);
          // exit;
  end;
  // Check for other suggestions

  if wpSuggestStartChar in SuggestMode then
  begin
    SuggestStartChar;
  end;

  if wpSuggestFrequentMistakes in SuggestMode then
  begin
    SuggestFrequentMistakes;
    SuggestMissingChars;
    SuggestWithoutChars;
  end;
  if wpSuggestAccents in SuggestMode then
    SuggestAccents;
  if wpSuggestTwoWords in SuggestMode then
    SuggestTwoWords(3);
  if wpSuggestRotatedChar in SuggestMode then
    SuggestRotatedChar;
  if wpSuggestQWERTY in SuggestMode then
    SuggestQWERTY;
  if wpSuggestFirstVariation in SuggestMode then
    SuggestFirst;
  if wpSuggestSoundex in SuggestMode then
    SuggestSoundex;
end;


procedure TWPDCT.GetWordList(list: TStrings; maxcount: Integer = MaxInt);
var
  o: Boolean;
  EdgeID: Longint;
  SaveWord: string;
  AWord: string;
  procedure BuildList(StartEdge: Longint);
  var
    ChildEdge: Longint;
    ChkEdge: TDiskEdge;
  begin
    while StartEdge <> 0 do
    begin
      ChkEdge := Buffer(StartEdge);
      if ChkEdge and flWordEnd <> 0 then
      begin
        AWord := AWord + Char((ChkEdge and $FF000000) shr 24);
        list.Add(SaveWord + AWord);
        dec(maxcount);
        if maxcount < 0 then break;
        Delete(AWord, Length(AWord), 1);
      end;
      ChildEdge := ChkEdge and $0007FFFF;
      if ChildEdge <> 0 then
      begin
        AWord := AWord + Char((ChkEdge and $FF000000) shr 24);
        // keep going
        BuildList(ChildEdge);
        if maxcount < 0 then break;
        Delete(AWord, Length(AWord), 1);
      end;
      if ChkEdge and flNodeEnd <> 0 then
        Break
      else
        Inc(StartEdge);
    end;
  end;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
begin
  List.BeginUpdate;
  o := Open;
  Open := TRUE;
  SaveWord := '';
  AWord := '';
  EdgeID := 1;
  try
    BuildList(EdgeID);
  finally
    List.EndUpdate;
    Open := o;
  end;
end;

function TWPDCT.Test: Boolean;
var f: TFileStream; j: Integer;
begin
  Result := TRUE;
  if not Open then
  begin
    f := TFileStream.Create(FFileName, fmOpenRead + fmShareDenyWrite);
    try
      f.Read(FHeader, SizeOf(FHeader));
      Result := VerifyHeader(FHeader, FFileName);
      if Result and (FHeader.languageid <> 0) then
      begin
        FOverriddenID := 0;
        FLanguageIDGroup := FHeader.languageid;
        if FLanguageIDGroup <> 0 then
          for j := 0 to Length(wplanguages) - 1 do
            if wplanguages[j].id = FLanguageIDGroup then
            begin
              FLanguageIDGroup := wplanguages[j].groupid;
              break;
            end;
      end;
    finally
      f.Free;
    end;
  end;
end;

procedure TWPDCT.SetOpen(x: Boolean);
var j: Integer;
  s: string;
begin
  if x <> GetOpen then
  begin
    FreeAndNil(FStream);
    FBuffer := nil;
    FJumpList := nil;
    FBufferSize := 0;
    FBufferPos := 0;
    FBufferMax := 0;
    FAbbreviation.Clear;
    if x then // Open file
    try
      FStream := TFileStream.Create(FFileName, fmOpenRead + fmShareDenyWrite);
      FStream.Read(FHeader, SizeOf(FHeader));
      if not VerifyHeader(FHeader, FFileName) then
        raise EWPSpellDictFormatError.Create('Cannot load this doctionary :' + FFileName);
      if FHeader.offcapital <> 0 then
      begin
        FBufferMax := FHeader.offcapital div 4 + 1; // +1 since we start with 1 !
        SetLength(s, FHeader.lencapital);
        FStream.Position := FHeader.Size + FHeader.offcapital;
        FStream.Read(s[1], Length(s));
        FAbbreviation.Text := s;
      end
      else FBufferMax := (FStream.Size - FHeader.Size) div 4 + 1;
      FStream.Position := FHeader.Size;

      // Which language group are we in ?
      FLanguageIDGroup := FHeader.languageid;
      if FLanguageIDGroup <> 0 then
        for j := 0 to Length(wplanguages) - 1 do
          if wplanguages[j].id = FLanguageIDGroup then
          begin
            FLanguageIDGroup := wplanguages[j].groupid;
            break;
          end;

      if FMemoryMode = wpspellUseMemory then // Load to memory ...
      begin
        FBufferSize := FBufferMax;
        SetLength(FBuffer, FBufferSize + 4);
        FStream.Read(FBuffer[1], FBufferSize * SizeOf(TDiskEdge));
      end else // Load file
      begin
        if FBufferMax < WPSpellBufferMinSize then
          FBufferSize := FBufferMax // Load completely
        else FBufferSize := 7925; // Load about 32K at a time ...
        SetLength(FBuffer, FBufferSize + 4);
        FStream.Read(FBuffer[1], FBufferSize * SizeOf(TDiskEdge));
      end;
    except
      FreeAndNil(FStream);
      FBuffer := nil;
    end;
  end;
end;


// ----------------------------------------
// ----------- all dictionaries -----------
// ----------------------------------------

constructor TWPSpellController.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
{$IFDEF DEFAULT_INMEM}
  FMemoryMode := wpspellUseMemory;
{$ENDIF}
  INIfilePath := '{app}wpspell.ini';
  RegistryPath := 'Software\WPCubed\WPSpell';
  FAllDCTs := TList.Create;
  FDisabledFiles := TStringList.Create;
  FUserDicts := TList.Create;
  FSupportAutoCorrect := TRUE;
  FAllLanguages := TStringList.Create;
  FIgnoreList := TStringList.Create;
  FIgnoreList.Sorted := TRUE;
  FIgnoreList.Duplicates := dupIgnore;
  FCurrentLanguageName := wplanguages[0].Name;
  FSoundexScanTable := TStringList.Create;
  // Fill SoundexTable with values
  FSoundexScanTable.Text :=
    'a:edä' + #13 + #10 +
    'b:pvn' + #13 + #10 +
    'c:sxv' + #13 + #10 +
    'd:sf' + #13 + #10 +
    'e:aiä' + #13 + #10 +
    'f:dg' + #13 + #10 +
    'g:jfh' + #13 + #10 +
    'h:gj' + #13 + #10 +
    'i:euo' + #13 + #10 +
    'j:hk' + #13 + #10 +
    'k:cjl' + #13 + #10 +
    'l:mn' + #13 + #10 +
    'm:n' + #13 + #10 +
    'n:mb' + #13 + #10 +
    'o:ipö' + #13 + #10 +
    'p:bo' + #13 + #10 +
    'q:ckw' + #13 + #10 +
    'r:et' + #13 + #10 +
    's:cadß' + #13 + #10 +
    't:rpy' + #13 + #10 +
    'u:yiü' + #13 + #10 +
    'v:bc' + #13 + #10 +
    'w:uqe' + #13 + #10 +
    'x:kz' + #13 + #10 +
    'y:tu' + #13 + #10 +
    'z:xs';
end;

procedure TWPSpellController.AutoSaveSetup;
begin
  if (FPersistencyMode in [wpUseRegistry, wpUseINIFile]) then
    SaveSetup(FPersistencyMode = wpUseINIFile);
end;

destructor TWPSpellController.Destroy;
var i: Integer;
begin
  if FWasLoaded then AutoSaveSetup;

  for i := 0 to FAllDCTs.Count - 1 do
    TWPDCT(FAllDCTs[i]).Free;
  for i := 0 to FUserDicts.Count - 1 do
    TWPUserDic(FUserDicts[i]).Free;
  FAllDCTs.Free;
  FAllLanguages.Free;
  FIgnoreList.Free;
  FDisabledFiles.Free;
  FUserDicts.Free;
  FSoundexScanTable.Free;
  inherited Destroy;
end;

procedure TWPSpellController.Loaded;
begin
  inherited Loaded;
  if (FPersistencyMode in [wpUseRegistry, wpUseINIFile]) then
  begin
    LoadSetup(FPersistencyMode = wpUseINIFile);
    FWasLoaded := TRUE;
  end;
end;

procedure TWPSpellController.ClearAll;
var i: Integer;
begin
  for i := 0 to FAllDCTs.Count - 1 do
    TWPDCT(FAllDCTs[i]).Free;
  for i := 0 to FUserDicts.Count - 1 do
    TWPUserDic(FUserDicts[i]).Free;
  FAllLanguages.Clear;
  FIgnoreList.Clear;
  FUserDicts.Clear;
  FAllDCTs.Clear;
end;

function TWPSpellController.GetDCTCount: Integer;
begin
  Result := FAllDCTs.Count;
end;

function TWPSpellController.GetDCT(index: Integer): TWPDCT;
begin
  Result := TWPDCT(FAllDCTs[index]);
end;

function TWPSpellController.GetLanguageIDCount: Integer;
var i, j, id: Integer; s: string;
begin
  FAllLanguages.Clear;
  for i := 0 to FAllDCTs.Count - 1 do
  begin
    id := TWPDCT(FAllDCTs[i]).LanguageIDGroup;
    if FAllLanguages.IndexOfObject(Pointer(id)) < 0 then
    begin
      s := wplanguages[0].Name;
      for j := 0 to Length(wplanguages) - 1 do
        if wplanguages[j].id = id then
        begin
          s := wplanguages[j].name;
          break;
        end;
      FAllLanguages.AddObject(s, Pointer(id));
    end;
  end;
  Result := FAllLanguages.Count;
end;

function TWPSpellController.GetSoundexScanTable: TStrings;
begin
  Result := TStrings(FSoundexScanTable);
end;

procedure TWPSpellController.SetSoundexScanTable(x: TStrings);
begin
  FSoundexScanTable.Assign(x);
end;

function TWPSpellController.GetDisabledFiles: TStrings;
begin
  Result := TStrings(FDisabledFiles);
end;

procedure TWPSpellController.SetDisabledFiles(x: TStrings);
begin
  FDisabledFiles.Assign(x);
end;

procedure TWPSpellController.SetOptionFlags(x: Integer);
begin
  FOptionFlags := x;
end;

procedure TWPSpellController.SetCurrentLanguage(x: Integer);
var i: Integer;
begin
  if FCurrentLanguage <> x then
  begin
    FLanguageHasChanged := TRUE;
    FCurrentLanguage := x;
    FCurrentLanguageGroup := x;
    FCurrentLanguageName := wplanguages[0].Name;
    for i := 0 to Length(wplanguages) - 1 do
    begin
      if wplanguages[i].id = x then
      begin
        FCurrentLanguageGroup := wplanguages[i].groupid;
        FCurrentLanguageName := wplanguages[i].Name;
        break;
      end;
    end;
  end;
end;

procedure TWPSpellController.SetMemoryMode(x: TWPDCTMemoryMode);
var i: Integer;
begin
  if x <> FMemoryMode then
  begin
    FMemoryMode := x;
    for i := 0 to DCTCount - 1 do
      DCT[i].MemoryMode := x;
  end;
end;

function TWPSpellController.GetLanguageID(index: Integer): Integer;
begin
  Result := Integer(FAllLanguages.Objects[index]);
end;

function TWPSpellController.GetLanguageName(index: Integer): string;
begin
  Result := FAllLanguages[index];
end;


function TWPSpellController.GetActive: Boolean;
begin
  Result := glWPSpellController = Self;
end;

procedure TWPSpellController.SetActive(x: Boolean);
begin
  if x then glWPSpellController := Self
  else
    if (glWPSpellController = Self) then
      glWPSpellController := nil;
end;

function TWPSpellController.Configure: Boolean;
var dia: TWPCustomSpellOptionForm;
begin
  FLanguageHasChanged := FALSE;
  if glWPSpellOptionForm <> nil then
  begin
    dia := glWPSpellOptionForm.Create(nil);
    dia.SpellControler := Self;
    if (FDlgLeft <= 0) or (FDlgTop <= 0) or
      (FDlgLeft > Screen.Width - 50) or (FDlgTop > Screen.Height - 50) then
    begin
      FDlgLeft := (Screen.Width - dia.Width) div 2;
      FDlgTop := (Screen.Height - dia.Height) div 2;
    end;
    dia.Left := FDlgLeft;
    dia.Top := FDlgTop;
    try
      Result := dia.ShowModal = IDOK;
      FDlgLeft := dia.Left;
      FDlgTop := dia.Top;
    finally
      dia.Free;
    end;
  end else Result := FALSE;
end;


// We use this code to save options which should only
// work for this application

function GetAppCode: string;
var i, j: Integer;
  s: string;
begin
  s := ParamStr(0);
  try
    j := 0;
    for i := 1 to Length(s) do
    begin
      j := j + (Integer(s[i]) + 128) * i;
      j := j xor (j shl 1);
    end;
    Result := IntToHex(j, 8);
  except
    Result := ExtractFileName(s);
  end;
end;

procedure TWPSpellController.SaveSetup(AsINI: Boolean);
var reg: TCustomIniFile;
  s, appath, appcode: string;
  i: Integer;
const section: string = 'SpellCheck';
  sectionfiles: string = 'SpellCheck-Files';
begin
  s := ParamStr(0);
  appcode := GetAppCode;
  appath := ExtractFilePath(s);

  if AsINI and (INIfilePath <> '') then
  begin
    s := INIfilePath;
    s := StringReplace(s, '{app}', appath, [rfIgnoreCase]);
    reg := TIniFile.Create(s);
  end else
    if not AsINI and (RegistryPath <> '') then
    begin
      s := RegistryPath;
      s := StringReplace(s, '{app}', ExtractFileName(ParamStr(0)), [rfIgnoreCase]);
      reg := TRegistryIniFile.Create(s);
    end
    else exit;
  try
    reg.WriteString(section, 'InitialDir', InitialDirectory);
    reg.WriteString(section, 'StrOption', OptionalParams);
    reg.WriteInteger(section, 'Option', FOptionFlags);

    reg.WriteInteger(section, 'X', FDlgLeft);
    reg.WriteInteger(section, 'Y', FDlgTop);

     // Save the current language and using 2 keys!
    reg.WriteInteger(section, 'Language', CurrentLanguage);
    reg.WriteInteger(section, 'Language_' + appcode, CurrentLanguage);

     // Erase the whole files section
    reg.EraseSection(sectionfiles);

     // Save Disabled first
    for i := FDisabledFiles.Count - 1 downto 0 do
      if FindDCT(FDisabledFiles[i]) = nil then
        FDisabledFiles.Delete(i);

    reg.WriteInteger(sectionfiles, 'DCTs.Disabled', FDisabledFiles.Count);
    for i := 0 to FDisabledFiles.Count - 1 do
    begin
      s := FDisabledFiles[i];
      reg.WriteString(sectionfiles, 'DCTdis' + IntToStr(i), s);
    end;

    reg.WriteInteger(sectionfiles, 'DCTs', DCTCount);
    for i := 0 to DCTCount - 1 do
    begin
      s := DCT[i].Filename;
      reg.WriteString(sectionfiles, 'DCT' + IntToStr(i), s);
    end;

    reg.WriteInteger(sectionfiles, 'User', FUserDicts.Count);
    for i := 0 to FUserDicts.Count - 1 do
    begin
      s := UserDict[i].FileName;
      reg.WriteString(sectionfiles, 'DIC' + IntToStr(i), s);
    end;
  finally
    reg.Free;
  end;
end;

// if we are loading INI file we allow {app} in the INI entries
// This makes it easy to set up an INI file for the first startup
// of the application

procedure TWPSpellController.LoadSetup(AsINI: Boolean);
var reg: TCustomIniFile;
  s, appath, appcode: string;
  i, c: Integer;
const section: string = 'SpellCheck';
  sectionfiles: string = 'SpellCheck-Files';
begin
  s := ParamStr(0);
  appcode := GetAppCode;
  appath := ExtractFilePath(s);

  if AsINI and (INIfilePath <> '') then
  begin
    s := INIfilePath;
    s := StringReplace(s, '{app}', appath, [rfIgnoreCase]);
    reg := TIniFile.Create(s);
  end else
    if not AsINI and (RegistryPath <> '') then
    begin
      s := RegistryPath;
      s := StringReplace(s, '{app}', ExtractFileName(ParamStr(0)), [rfIgnoreCase]);
      reg := TRegistryIniFile.Create(s);
    end
    else exit;
  if not reg.SectionExists(section) then reg.Free else
  try
    ClearAll;
    FDisabledFiles.Clear;
    FInitialDirectory := reg.ReadString(section, 'InitialDir', InitialDirectory);
    if AsINI then
      FInitialDirectory := StringReplace(FInitialDirectory, '{app}', appath, [rfIgnoreCase]);
    FOptionalParams := reg.ReadString(section, 'StrOption', OptionalParams);
    FOptionFlags := reg.ReadInteger(section, 'Option', OptionFlags);

    FDlgLeft := reg.ReadInteger(section, 'X', FDlgLeft);
    FDlgTop := reg.ReadInteger(section, 'Y', FDlgTop);

    c := reg.ReadInteger(section, 'Language', CurrentLanguage);
    CurrentLanguage := reg.ReadInteger(section, 'Language_' + appcode, c);

    // we check first if the dictionaries exist and remove the links othewise completels

     // Read disabled first!
    c := reg.ReadInteger(sectionfiles, 'DCTs.Disabled', 0);
    for i := 0 to c - 1 do
    begin
      s := reg.ReadString(sectionfiles, 'DCTdis' + IntToStr(i), '');
      if AsINI then s := StringReplace(s, '{app}', appath, [rfIgnoreCase]);
      if (s <> '') and FileExists(s) then FDisabledFiles.Add(s);
    end;

    c := reg.ReadInteger(sectionfiles, 'DCTs', 0);
    for i := 0 to c - 1 do
    begin
      s := reg.ReadString(sectionfiles, 'DCT' + IntToStr(i), '');
      if AsINI then s := StringReplace(s, '{app}', appath, [rfIgnoreCase]);
      if (s <> '') and FileExists(s) then AddFromFile(s);
    end;

    c := reg.ReadInteger(sectionfiles, 'User', 0);
    for i := 0 to c - 1 do
    begin
      s := reg.ReadString(sectionfiles, 'DIC' + IntToStr(i), '');
      if AsINI then s := StringReplace(s, '{app}', appath, [rfIgnoreCase]);
      if (s <> '') and FileExists(s) then UserDictAdd(s);
    end;
  finally
    reg.Free;
  end;
end;

function TWPSpellController.UserDictAdd(path: string): TWPUserDic;
var i: Integer;
begin
  for i := 0 to FUserDicts.Count - 1 do
  begin
    Result := TWPUserDic(FUserDicts[i]);
    if CompareText(Result.FFileName, path) = 0 then
      exit;
  end;
  Result := TWPUserDic.Create;
  Result.FFileName := path;
  Result.Parent := Self;
  FUserDicts.Add(Result);
end;


procedure TWPSpellController.DoAfterCreatePopup(Sender: TWPSpellInterface; PopupMenu: TPopupMenu);
begin
  if Assigned(FAfterCreatePopup) then
    FAfterCreatePopup(Sender, PopupMenu);
end;

procedure TWPSpellController.DoBeforeCreatePopup(Sender: TWPSpellInterface; PopupMenu: TPopupMenu);
begin
  if Assigned(FBeforeCreatePopup) then
    FBeforeCreatePopup(Sender, PopupMenu);
end;

procedure TWPSpellController.UserDictRemove(path: string);
var i: Integer;
begin
  for i := FUserDicts.Count - 1 downto 0 do
    if CompareText(TWPUserDic(FUserDicts[i]).FFileName, path) = 0 then
      FUserDicts.Delete(i);
end;

function TWPSpellController.GetUserDictCount: Integer;
begin
  Result := FUserDicts.Count;
end;

function TWPSpellController.GetUserDict(index: Integer): TWPUserDic;
begin
  Result := TWPUserDic(FUserDicts[index]);
end;

procedure TWPSpellController.AddFromPath(path: string);
var
  sr: TSearchRec;
  FileAttrs: Integer;
  s: string;
begin
  FileAttrs := faAnyFile;
  s := path + '\*.DCT';
  if FindFirst(s, FileAttrs, sr) = 0 then
  begin
    repeat
      if (sr.Attr and FileAttrs) = sr.Attr then
        AddFromFile(path + '\' + sr.Name);
    until FindNext(sr) <> 0;
    SysUtils.FindClose(sr);
  end;
end;

function TWPSpellController.FindDCT(s: string): TWPDCT;
var i: Integer;
begin
  Result := nil;
  for i := 0 to FAllDCTs.Count - 1 do
    if CompareText(TWPDCT(FAllDCTs[i]).FFileName, s) = 0 then
    begin
      Result := TWPDCT(FAllDCTs[i]);
      break;
    end;
end;

procedure TWPSpellController.RemoveDCT(dct: TWPDCT);
var i: Integer;
begin
  i := FAllDCTs.IndexOf(dct);
  if i >= 0 then
  begin
    FAllDCTs.Delete(i);
    dct.Free;
  end;
end;


function TWPSpellController.AddFromFile(s: string): TWPDCT;
var i: Integer;
begin
  for i := 0 to FAllDCTs.Count - 1 do
    if CompareText(TWPDCT(FAllDCTs[i]).FFileName, s) = 0 then
    begin
      Result := TWPDCT(FAllDCTs[i]);
      exit;
    end;
  Result := TWPDCT.Create;
  Result.MemoryMode := FMemoryMode;
  try
    Result.Filename := s;
    if not Result.Test then
    begin
      Result.Free;
      Result := nil;
    end;
    FAllDCTs.Add(Result);
    Result.FParent := Self;
    // We synchronize with our DisabledFiles list
    Result.FDisabled := Result.Disabled;
    FLanguageHasChanged := TRUE;
  except
    Result.Free;
    raise;
  end;
end;

procedure TWPSpellController.Suggest(AWord: string; List: TStrings;
  MaxCount: Integer;
  SuggestMode: TWPInDictionarySuggest =
  [wpSuggestFrequentMistakes,
  wpSuggestAccents,
    wpSuggestTwoWords,
    wpSuggestFirstVariation,
    wpSuggestRotatedChar,
    wpSuggestQWERTY]);
var i: Integer; adct: TWPDCT; dict: TWPUserDic;
begin
  for i := 0 to FUserDicts.Count - 1 do
  begin
    dict := TWPUserDic(FUserDicts[i]);
    if dict.Suggest(AWord, List) then break;
  end;
  for i := 0 to DCTCount - 1 do
  begin
    adct := DCT[i];
    if not (adct.FDisabled) and // Use private variable
      ((DCTCount = 1) or (
      (adct.LanguageID = FCurrentLanguage) or
      (adct.LanguageIDGroup = FCurrentLanguageGroup))) then
    begin
      if DCTCount = 1 then
      begin
        FCurrentLanguage := adct.LanguageID;
        FCurrentLanguageGroup := adct.LanguageIDGroup;
      end;

      if not adct.Open then
      begin
        if (wpSuggestAutoOpenDictionaries in SuggestMode) then
        begin
          adct.Open := TRUE;
          adct.Suggest(adct.AdjustForDCT_in(AWord), List, MaxCount, SuggestMode);
        end;
      end
      else adct.Suggest(adct.AdjustForDCT_in(AWord), List, MaxCount, SuggestMode);
    end;
  end;
end;

procedure TWPSpellController.AddWord(const aWord, aReplace: string; Mode: TWPUserDicMode);
var dict: TWPUserDic;
begin
  // Add/open a default dictionary
  if FUserDicts.Count = 0 then
    UserDictAdd(ExtractFilePath(ParamStr(0)) + DEFAULT_USERDIC_NAME);
  // No add the file
  if FUserDicts.Count > 0 then
  begin
    dict := TWPUserDic(FUserDicts[0]);
    if not dict.FLoaded then dict.Load;
    dict.Add(aWord, aReplace, Mode);
  end;
end;

procedure TWPSpellController.IgnoreWord(aWord: string);
begin
  FIgnoreList.Add(aWord);
end;

function TWPSpellController.InDictionary(
  AWord: string;
  Mode: TWPInDictionaryMode;
  var Res: TWPInDictionaryResult): Boolean;
var i: Integer;
  adct: TWPDCT;
  adic: TWPUserDic;
  entry: TWPUserDicEntry;
begin
  // Result := FALSE;
  Res := [];

  // In SpellAsYouGo check we ca test a bit different --------------------------
  // if wpInCheckSpellAsYouGo in Mode then

  Result := TRUE;
  for i := 1 to Length(AWord) do
    if (AWord[i] > #32) and not ((AWord[i] in ['0'..'9']) or
      (AWord[i] in ['('..'/']) or (AWord[i] in ['_', #150, '-'])) then
    begin
      Result := FALSE;
      break;
    end;

  if Result then exit;

  Result := FALSE;
  // Ignore word with Numbers --------------------------------------------------
  if (FOptionFlags and WPSPELLOPT_IGNORENUMS) <> 0 then
    for i := 1 to Length(AWord) do
      if AWord[i] in ['0'..'9'] then
      begin
        Result := TRUE;
        exit;
      end;

  // Ignore all caps -----------------------------------------------------------
  if (FOptionFlags and WPSPELLOPT_IGNOREALLCAPS <> 0) and (AWord = AnsiUpperCase(AWord)) then
  begin
    Result := TRUE;
    exit;
  end;

  // Modes ...
  if (FOptionFlags and WPSPELLOPT_IGNORECOMPOUND <> 0) then
    include(Mode, wpDontSearchCompound);

  if (FOptionFlags and WPSPELLOPT_IGNORECASE <> 0) then
    include(Mode, wpDontCheckCapital);

  // Check our Ignorelist ------------------------------------------------------
  if FIgnoreList.IndexOf(AWord) >= 0 then
  begin
    Result := TRUE;
    exit;
  end;

  // Search in the User Dictionaries -------------------------------------------
  for i := 0 to FUserDicts.Count - 1 do
  begin
    adic := TWPUserDic(FUserDicts[i]);
    if not adic.FLoaded then
    begin
      if wpAutoOpenDictionaries in Mode then
        adic.Load
      else continue;
    end;
    if adic.Find(AWord, entry) then
    begin
      if entry = nil then
      begin
        Result := TRUE;
        exit;
      end else
        case entry.Mode of
          wpUserAdded: // Found it -> OK
            begin
              Result := TRUE;
              exit;
            end;
          wpUserExcluded: // Found it -> WRONG
            begin
              Result := FALSE;
              exit;
            end;
          wpUserReplace: // Found it -> WRONG but have replacement
            begin
              FAutoReplacedWord := entry.FReplace;
              include(res, wpNeedAutoReplace);
              Result := FALSE;
              exit;
            end;
          wpUserDeleted:
            begin
             // Do nothing
            end;
        end;
    end;
  end;

  // Search through the DCTs ---------------------------------------------------
  if not Result then
    for i := 0 to DCTCount - 1 do
    begin
      adct := DCT[i];
      if not (adct.FDisabled) and // Use private variable
        ((DCTCount = 1) or (
        (adct.LanguageID = FCurrentLanguage) or
        (adct.LanguageIDGroup = FCurrentLanguageGroup))) then
      begin
        if DCTCount = 1 then
        begin
          FCurrentLanguage := adct.LanguageID;
          FCurrentLanguageGroup := adct.LanguageIDGroup;
        end;
        if not adct.Open then
        begin
          if (wpAutoOpenDictionaries in Mode) then
          begin
            adct.Open := TRUE;
            Result := adct.InDictionary(adct.AdjustForDCT_in(AWord), Mode, Res);
          end;
        end
        else Result := adct.InDictionary(adct.AdjustForDCT_in(AWord), Mode, Res);
        if Result then exit;
      end;
    end;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

constructor TWPUserDic.Create;
begin
  FWords := TStringList.Create;
end;

destructor TWPUserDic.Destroy;
begin
  Clear;
  FWords.Free;
  inherited Destroy;
end;

procedure TWPUserDic.Clear;
var i: Integer;
  aword: TWPUserDicEntry;
begin
  for i := 0 to FWords.Count - 1 do
  begin
    aword := TWPUserDicEntry(FWords.Objects[i]);
    if aword <> nil then aword.Free;
  end;
  FWords.Clear;
end;

function TWPUserDic.GetStandard: Boolean;
var i: Integer;
begin
  Result := FALSE;
  if Parent <> nil then
  begin
    i := Parent.FUserDicts.IndexOf(self);
    if i = 0 then Result := TRUE;
  end;
end;

function TWPUserDic.GetWords: TStrings;
begin
  Result := FWords;
end;

procedure TWPUserDic.Remove;
var i: Integer;
begin
  if Parent <> nil then
  begin
    i := Parent.FUserDicts.IndexOf(self);
    if i >= 0 then Parent.FUserDicts.Delete(i);
  end;
  Free;
end;

procedure TWPUserDic.SetStandard(x: Boolean);
var i: Integer;
begin
  if Parent <> nil then
  begin
    i := Parent.FUserDicts.IndexOf(self);
    if x and (i > 0) then
    begin
      Parent.FUserDicts.Delete(i);
      Parent.FUserDicts.Insert(0, Self);
       // this code is not correct: Parent.FUserDicts.Exchange(0,i);
    end else
      if not x and (i = 0) then
      begin
        Parent.FUserDicts.Exchange(0, Parent.FUserDicts.Count - 1); // Exchange with last
      end;
  end;
end;

procedure TWPUserDic.Load;
var all: TStringList;
  i, j: Integer;
  s: string;
  aword: TWPUserDicEntry;
begin
  FModified := FALSE;
  Clear;
  FUpdateCount := 0;
  if FileExists(FFileName) then
  begin
    all := TStringList.Create;
    try
      try
        all.LoadFromFile(FFileName);
      except
         // Somebody is locking this file ....
        raise;
      end;
      FWords.Sorted := FALSE;
      for i := 0 to all.count - 1 do
      begin
        s := all[i];
        if Length(s) > 1 then
        begin
          // This is a last minute update - delete prevous entry
          if s[1] = '@' then
          begin
            j := FWords.IndexOf(s);
            if j > 0 then
            begin
              FWords.Objects[j].Free;
              FWords.Delete(j);
              inc(FUpdateCount);
            end;
            Delete(s, 1, 1);
          end;
          // Now add it
          if s[1] = '=' then // AUTO Replace -------------------------------
          begin
            j := Length(s) - 1;
            while j > 1 do
            begin
              if s[j] = '=' then break;
              dec(j);
            end;
            if j > 1 then
            begin
              aword := TWPUserDicEntry.Create;
              aword.FReplace := Copy(s, j + 1, Length(s));
              aword.FMode := wpUserReplace;
              FWords.AddObject(Copy(s, 2, j - 2), aword);
            end;
          end else if s[1] = '#' then // EXCLUDED ---------------------------
          begin
            aword := TWPUserDicEntry.Create;
            aword.FReplace := '';
            aword.FMode := wpUserExcluded;
            FWords.AddObject(Copy(s, 2, Length(s) - 1), aword);
          end else
            if s[1] <> '~' then
              FWords.AddObject(s, nil); // Included, Standard ------------------
        end;
      end;
      FWords.Sorted := TRUE;
    finally
      all.Free;
    end;
  end;
  FLoaded := TRUE; // even if new
end;

function TWPUserDic.Suggest(aWord: string; list: TStrings): Boolean;
  function Normalize(s: string): string;
  var j, m: Integer; c: Char;
  begin
    s := ANSILowercase(s);
    for j := 1 to Length(s) do
      case s[j] of
        'ä', 'á', 'â', 'å': s[j] := 'a';
        'ö', 'ô', 'ó', 'ò': s[j] := 'o';
        'ü', 'û', 'ú', 'ù': s[j] := 'u';
        'é', 'è', 'ê', 'ë': s[j] := 'e';
        'i', 'í', 'ì', 'î', 'ï': s[j] := 'i';
        'ý': s[j] := 'y';
        'ß': s[j] := 's';
      end;
    c := #0;
    m := 0;
    SetLength(Result, Length(s));
    for j := 1 to Length(s) do
    begin
      if (c <> s[j]) and (s[j] <> #39) and (s[j] <> '-') and
        ((j > 1) or (s[j] <> 'h')) //first 'h'
        then begin inc(m); Result[m] := s[j]; c := s[j]; end;

    end;
    SetLength(Result, m);
  end;
var
  i: Integer;
  cs: string;
begin
  aWord := Normalize(aWord);
  Result := FALSE;
  for i := 0 to FWords.Count - 1 do
  begin
    cs := Normalize(FWords[i]);
    if Length(AWord) < 4 then
    begin
      if aWord = cs then
      begin
        Result := TRUE;
        list.Add(FWords[i]);
        break;
      end;
    end else
      if (aWord = Copy(cs, 1, Length(aWord))) or
        ((Length(aWord) > 1) and (Copy(aWord, 1, Length(aWord) - 1) = cs)) then
      begin
        Result := TRUE;
        list.Add(FWords[i]);
        break;
      end;
  end;
end;

procedure TWPUserDic.ListWords(list: TStrings);
var
  i: Integer;
  aword: TWPUserDicEntry;
  s, s2: string;
begin
  list.BeginUpdate;
  try
    for i := 0 to FWords.Count - 1 do
    begin
      s := FWords[i];
      if s <> '' then
      begin
        aword := TWPUserDicEntry(FWords.Objects[i]);
        if aword <> nil then
        begin
          case aword.FMode of
            wpUserAdded: s2 := s;
            wpUserExcluded: s2 := '#' + s;
            wpUserReplace: s2 := '=' + s + '=' + aword.FReplace;
            wpUserDeleted: continue; // Do NOT WRITE!
          end;
        end else s2 := s;
        list.AddObject(s2, aword);
      end;
    end;
  finally
    list.EndUpdate;
  end;
end;

procedure TWPUserDic.Save;
var f: TFileStream;
  i: Integer;
  aword: TWPUserDicEntry;
  s, s2: string;
begin
  if FModified then
  begin
    f := TFileStream.Create(FileName, fmCreate);
    try
      for i := 0 to FWords.Count - 1 do
      begin
        s := FWords[i];
        if s <> '' then
        begin
          aword := TWPUserDicEntry(FWords.Objects[i]);
          if aword <> nil then
          begin
            case aword.FMode of
              wpUserAdded: s2 := s + #13#10;
              wpUserExcluded: s2 := '#' + s + #13#10;
              wpUserReplace: s2 := '=' + s + '=' + aword.FReplace + #13#10;
              wpUserDeleted: continue; // Do NOT WRITE!
            end;
          end else s2 := s + #13#10;
{$IFDEF CLR}
          todo
{$ELSE}
          f.Write(s2[1], Length(s2));
{$ENDIF}
        end;
      end;
      FUpdateCount := 0;
    finally
      f.Free;
    end;
    FModified := FALSE;
  end;
end;

procedure TWPUserDic.Add(const aWord, aReplace: string; Mode: TWPUserDicMode);
var entry: TWPUserDicEntry;
  i: Integer;
  NeedModify: Boolean;
{$IFDEF USERDIC_INSTANTUPDATE}
  f: TFileStream;
  s: string;
{$ENDIF}
begin
  entry := nil;
  i := FWords.IndexOf(aWord);
  NeedModify := FALSE;
  if i >= 0 then // We found it, now modify it -------------------------------
  begin
    if Mode = wpUserAdded then
    begin
      if entry <> nil then
      begin
        FreeAndNil(entry);
        FWords.Objects[i] := nil;
        NeedModify := TRUE;
      end;
    end else
    begin
      if (entry.FReplace <> aReplace) or (entry.FMode <> Mode) then
      begin
        entry.FReplace := aReplace;
        entry.FMode := Mode;
        NeedModify := TRUE;
      end;
    end;
  end else
    if Mode <> wpUserDeleted then // We have to add it -------------------------
    begin
      if Mode <> wpUserAdded then
      begin
        entry := TWPUserDicEntry.Create;
        entry.FReplace := aReplace;
        entry.FMode := Mode;
      end else entry := nil;
      FWords.AddObject(aWord, entry);
      NeedModify := TRUE;
    end;

{$IFDEF USERDIC_INSTANTUPDATE}
  if NeedModify then
  try
    if not FileExists(FileName) then
      f := TFileStream.Create(FileName, fmCreate)
    else f := TFileStream.Create(FileName, fmOpenReadWrite + fmShareDenyNone);
    try
      f.Position := f.Size;
          // This
      if i >= 0 then
      begin
        s := '@'; // This is a modification!
        inc(FUpdateCount); // This is not intirely correct since another
               // application can have added the same word already!
      end
      else s := '';
      case mode of
        wpUserAdded: s := s + aWord + #13 + #10;
        wpUserExcluded: s := s + '#' + aWord + #13 + #10;
        wpUserReplace: s := s + '=' + aWord + '=' + aReplace + #13 + #10;
        wpUserDeleted: s := s + '~' + aWord + #13 + #10;
      else s := '';
      end;
      f.Write(s[1], Length(s));
    finally
      f.Free;
    end;
  except
    FModified := TRUE; // probably a file locking error
  end;
{$ELSE}
  if NeedModify then FModified := TRUE;
{$ENDIF}

end;

function TWPUserDic.Find(const aWord: string; var entry: TWPUserDicEntry): Boolean;
var i: Integer;
begin
  i := FWords.IndexOf(aWord);
  if i < 0 then
  begin
    Result := FALSE;
    entry := nil;
  end else
  begin
    Result := TRUE;
    entry := TWPUserDicEntry(FWords.Objects[i]);
  end;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

constructor TWPSpellInterface.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
end;

function TWPSpellInterface.GetSpellController: TWPSpellController;
begin
  if not Assigned(glWPSpellController) then
    raise Exception.Create('TWPSpellController not created or active!')
  else
  begin
    Result := glWPSpellController;
    Result.SupportAutoCorrect := _SupportAutoCorrect;
  end;
end;

procedure TWPSpellInterface.SetSpellAsYouGoIsActive(x: Boolean);
begin
  if x <> ((SpellController.OptionFlags and WPSPELLOPT_SPELLASYOUGO) <> 0) then
  begin
    if x then
      SpellController.OptionFlags := SpellController.OptionFlags + WPSPELLOPT_SPELLASYOUGO
    else SpellController.OptionFlags := SpellController.OptionFlags - WPSPELLOPT_SPELLASYOUGO;
  end;
end;

function TWPSpellInterface.GetSpellAsYouGoIsActive: Boolean;
begin
  if not Assigned(glWPSpellController) then Result := FALSE
  else Result := ((SpellController.OptionFlags and WPSPELLOPT_SPELLASYOUGO) <> 0);
end;

procedure TWPSpellInterface.UpdateSpellAsYouGo(laststate: Boolean = FALSE);
begin
  if not SpellAsYouGoIsActive or (laststate <> SpellAsYouGoIsActive) then DoSpellAsYouGo;
end;

procedure TWPSpellInterface.SpellCheck(ThisControl: TControl; mode: TWPSpellCheckStartMode);
begin
  // Must be overridden
end;

procedure TWPSpellInterface.DoSpellAsYouGo;
begin
  // Must be overridden
end;

function TWPSpellInterface.Changing: Boolean;
begin
  Result := TRUE;
end;

procedure TWPSpellInterface.Configure;
var spell: Boolean;
begin
  spell := SpellAsYouGoIsActive;
  if SpellController.Configure and
    ((SpellAsYouGoIsActive <> spell) or
    (spell and SpellController.LanguageHasChanged)) then
    DoSpellAsYouGo;
end;

procedure TWPSpellInterface.Changed;
begin
end;

procedure TWPSpellInterface.Ignore(const aWord: string);
begin
end;

procedure TWPSpellInterface.IgnoreAll(const aWord: string);
begin
end;

procedure TWPSpellInterface.AddToUserDic(const aWord: string);
begin
     // FSpellController.
end;

procedure TWPSpellInterface.Replace(const aWord, ReplaceWord: string);
begin
end;

procedure TWPSpellInterface.ReplaceAll(const aWord, ReplaceWord: string);
begin
end;

function TWPSpellInterface.GetNextWord(var languageid: Integer): string;
begin
  languageid := 0;
  Result := '';
end;

procedure TWPSpellInterface.StartNextWord;
begin
end;

procedure TWPSpellInterface.MoveCursor;
begin
end;

procedure TWPSpellInterface.SaveState;
begin
end;

function TWPSpellInterface.RestoreState: Boolean;
begin
  Result := TRUE;
end;

function TWPSpellInterface.GetScreenXYWH(var X, Y, W, H: Integer): Boolean;
var p: TPoint;
begin
  if FControl <> nil then
  begin
    p := FControl.ClientToScreen(Point(0, 0));
    X := p.x;
    Y := p.y;
    w := 0;
    h := 0;
  end else
  begin
    x := 0;
    y := 0;
    w := 16;
    h := 16;
  end;
  Result := FALSE;
end;

procedure TWPSpellInterface.ToStart;
begin
end;

procedure TWPSpellInterface.SelectLanguageFromHere(LanguageID: Integer);
begin
end;

function TWPSpellInterface.GetDefaultLanguageID: Integer;
begin
  Result := 0;
end;

end.

