unit WPLngCtr;
{ -----------------------------------------------------------------------------
  WPLngCtr             -                     Copyright (C) 2002 by wpcubed GmbH
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  You may use this unit if you are a registered user of WPTools 4 or WPForm 2
  to add localization to your projects.
  -----------------------------------------------------------------------------
  Distribution of the "IWPLocalizationInterface" interface is allowed
  Distribution of the unit "WPLngCtr" unit is *not* allowed.
  -----------------------------------------------------------------------------
  TWPLanguageControl - Component - implements IWPLocalizationInterface
  -----------------------------------------------------------------------------
  Modified to be compatible to WPTools 5 - 26.10.2004 by Julian Ziersch
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

interface

{$IFDEF	VER140}
{$DEFINE DELPHI6ANDUP}
{$ENDIF}
{$IFDEF	VER150}
{$DEFINE DELPHI6ANDUP}
{$ENDIF}
{$IFDEF	VER170}
{$DEFINE DELPHI6ANDUP}
{$ENDIF}
{$IFDEF	VER180}
{$DEFINE DELPHI6ANDUP}
{$ENDIF}

{--$DEFINE USE_LOCALIZE_U}{ off for WPTools 5}

uses Windows, Classes, TypInfo, Sysutils, Controls, Forms, Menus, WPXMLInt,
{$IFDEF USE_LOCALIZE_U}WPLocalize, {$ENDIF}extctrls{$IFDEF DELPHI6ANDUP}, Variants{$ENDIF};

type
  TWPLanguageControl = class;

  IWPLocalizationInterface = interface
    ['{A12EF1F7-E592-4483-855F-67E28332AFC5}']
{:: This method can be used to save the menu items and captions
   on a certain form. If you use the TWPLocalizeForm class you don't need
   to care about that. }
    procedure SaveForm(
      const Name: string;
      Form: TWinControl;
      Menus, Captions, Hints: Boolean);

{:: Load all Components on a certain TForm. }
    procedure LoadForm(
      const Name: string;
      Form: TWinControl;
      Menus, Captions, Hints: Boolean);

{:: This method saves a string list under a certain name. The string list has to use
   the syntax NAME=xxx\n }
    procedure SaveStrings(
      const Name: string;
      Entries: TStrings;
      Charset: Integer);

{:: Loads back the string(s) saved with  WPLangSaveStrings }
    function LoadStrings(
      const Name: string;
      Entries: TStrings;
      var Charset: Integer): Boolean;

{:: Method to save a certain string. To save multiple strings use  WPLangSaveStrings }
    procedure SaveString(
      const Name, Text: string;
      Charset: Integer);

{:: Loads back a string saved with WPLangSaveString }
    function LoadString(
      const Name: string;
      var Text: string;
      var Charset: Integer): Boolean;
  end;

  TWPLanguageControlAfterEvent =
    procedure(Sender: TWPLanguageControl;
    Form: TWinControl;
    XMLEntry: TWPXMLOneLevel) of object;
  TWPLanguageControlBeforeEvent =
    procedure(Sender: TWPLanguageControl;
    Form: TWinControl;
    XMLEntry: TWPXMLOneLevel;
    var Ignore: Boolean) of object;

{: This procedure will save as many properties of
   a certain Control. The stringlist can contain
   Items such as H=.. and C=... }
  TWPLocalSaveObjectStrings = procedure(
    const Control: TObject;
    const Entries: TStringList;
    var Done, NoDefault: Boolean) of object;

{: This procedure is executed when a certain object has to be initialized.
   It can be used to add localisation support for objects which use other
   properties than Caption and Hint. }

  TWPLocalLoadObjectStrings = procedure(
    const Control: TObject;
    const Entries: TStringList;
    var Done, NoDefault: Boolean) of object;

  TWPLanguageControl = class(TWPCustomXMLTree, IWPLocalizationInterface, IUnknown)
  private
    FEntry: string;
    WPLocalizeLanguage: string;
    FFileName: string;
    FAfterSave: TWPLanguageControlAfterEvent;
    FAfterLoad: TWPLanguageControlAfterEvent;
    FBeforeSave: TWPLanguageControlBeforeEvent;
    FBeforeLoad: TWPLanguageControlBeforeEvent;

    FWPLocalSaveObjectStrings: TWPLocalSaveObjectStrings;
    FWPLocalLOadObjectStrings: TWPLocalLoadObjectStrings;

    function GetActive: Boolean;
    procedure SetActive(x: Boolean);
    function GetAutoLoadStrings: Boolean;
    procedure SetAutoLoadStrings(x: Boolean);
    function GetAutoSaveStrings: Boolean;
    procedure SetAutoSaveStrings(x: Boolean);
    function GetGlobalLanguage: string;
    procedure SetGlobalLanguage(x: string);
  protected
    FRefCount: Integer;
    // Ignore Compiler warning!
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    class function NewInstance: TObject; override;
    property RefCount: Integer read FRefCount;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure SaveVCLStrings;
    procedure LoadVCLStrings;
    procedure WPAutoLocalize;
    function SaveFormEx(const Name: string; Form: TWinControl; Menus, Captions, Hints: Boolean): TWPXMLOneLevel; virtual;
    procedure SaveForm(const Name: string; Form: TWinControl; Menus, Captions, Hints: Boolean); virtual;
    procedure LoadForm(const Name: string; Form: TWinControl; Menus, Captions, Hints: Boolean); virtual;
    procedure SaveStrings(const Name: string;
      Entries: TStrings; Charset: Integer);
    function LoadStrings(const Name: string;
      Entries: TStrings; var Charset: Integer): Boolean;
    procedure SaveString(const Name, Text: string; Charset: Integer);
    {Loads back a string saved with WPLangSaveString. Since WPTools V5.18.1 the string
     "WPLocalizeLanguage" can be passed as name. Than the ID (such as DE, IT etc) of
     the selected language will be assigned to variable Text.}
    function LoadString(const Name: string;
      var Text: string; var Charset: Integer): Boolean;
  published
    property XMLParent: string read FEntry write FEntry;
    property Active: Boolean read GetActive write SetActive;
    property AutoLoadStrings: Boolean read GetAutoLoadStrings write SetAutoLoadStrings;
    property AutoSaveStrings: Boolean read GetAutoSaveStrings write SetAutoSaveStrings;
    property FileName: string read FFileName write FFileName;
    // property Compressed;
    // property Password;
    property AfterSaveForm: TWPLanguageControlAfterEvent read FAfterSave write FAfterSave;
    property AfterLoadForm: TWPLanguageControlAfterEvent read FAfterLoad write FAfterLoad;
    property BeforeSaveForm: TWPLanguageControlBeforeEvent read FBeforeSave write FBeforeSave;
    property BeforeLoadForm: TWPLanguageControlBeforeEvent read FBeforeLoad write FBeforeLoad;

    property WPLocalSaveObjectStrings: TWPLocalSaveObjectStrings read FWPLocalSaveObjectStrings write FWPLocalSaveObjectStrings;
    property WPLocalLOadObjectStrings: TWPLocalLoadObjectStrings read FWPLocalLOadObjectStrings write FWPLocalLOadObjectStrings;

    // After loading or changing the data
    property OnLoaded;
    // XML Data
    property XMLData;
    // AT LAST!
    property GlobalLanguage: string read GetGlobalLanguage write SetGlobalLanguage;
  end;

implementation

var
  WPLanguageControl: TWPLanguageControl; // Only one is allowed !

const
  CAPTION_PARAM = 'C';
  HINT_PARAM = 'H';
  CHARSET_PARAM = 'CS';


  { -----------------------------------------------------------------------------
    TWPLanguageControl
    ----------------------------------------------------------------------------- }

procedure TWPLanguageControl.AfterConstruction;
begin
// Release the constructor's implicit refcount
  InterlockedDecrement(FRefCount);
end;

procedure TWPLanguageControl.BeforeDestruction;
begin
  if RefCount <> 0 then raise Exception.Create('Cannot destroy');
end;

// Set an implicit refcount so that refcounting
// during construction won't destroy the object.

class function TWPLanguageControl.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TWPLanguageControl(Result).FRefCount := 1;
end;

function TWPLanguageControl.QueryInterface(const IID: TGUID; out Obj): HResult;
const
  E_NOINTERFACE = HResult($80004002);
begin
  if GetInterface(IID, Obj) then Result := 0 else Result := E_NOINTERFACE;
end;

function TWPLanguageControl._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TWPLanguageControl._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;


procedure TWPLanguageControl.WPAutoLocalize;
var
  pTemp: array[0..MAX_PATH] of char;
  sTemp, aGlobalLanguage: string;
  function GETUILANGUAGE: string;
    {adapted from Erik Lindberg at Mutilizer, QBS TechTip}
  type
    TBuf = array[1..4] of SmallInt;
    PBuf = ^TBuf;
  var
    FName: TFilename;
    LangIntName: string;
    BSize, DummySize: DWORD;
    Handle: DWORD;
    Buffer: PBuf;
    InfoBuffer: Pointer;
    dwI: Longint;
  {$IFDEF DELPHI5ANDUP}
    iLanguage: Longint;
  {$ENDIF}
  begin
    SetLength(FName, MAX_PATH + 1);
    dwI := GetSystemDirectory(PChar(FName), MAX_PATH);
    SetLength(FName, dwI);
    FName := FName + '\USER.EXE';
    BSize := GetFileVersionInfoSize(PChar(FName), Handle);
    if BSize = 0 then
      Result := 'Unknown'
    else
    begin
      GetMem(InfoBuffer, BSize);
      try
        if GetFileVersionInfo(PChar(FName), Handle, BSize, InfoBuffer) then
        begin
          VerQueryValue(InfoBuffer, PChar('\VarFileInfo\Translation'),
            Pointer(Buffer), DummySize);

          if LoWord(Buffer^[1]) = $0000 then
          begin
            Result := 'Language Neutral';
          end
          else
{$IFDEF DELPHI5ANDUP}
          begin
            for iLanguage := 0 to Languages.Count - 1 do // Iterate
            begin
              if LoWord(Buffer^[1]) = Languages.LocaleID[iLanguage] then
                Result := Languages.Name[iLanguage];
            end; // for
          end;
        end;
{$ELSE}
          {Int to ..SENGLANGUAGE}
            case LoWord(Buffer^[1]) of //
              $0000: LangIntName := 'Language Neutral';
              $0400: LangIntName := 'Process Default Language';
              $0401: LangIntName := 'Arabic (Saudi Arabia)';
              $0801: LangIntName := 'Arabic (Iraq)';
              $0C01: LangIntName := 'Arabic (Egypt)';
              $1001: LangIntName := 'Arabic (Libya)';
              $1401: LangIntName := 'Arabic (Algeria)';
              $1801: LangIntName := 'Arabic (Morocco)';
              $1C01: LangIntName := 'Arabic (Tunisia)';
              $2001: LangIntName := 'Arabic (Oman)';
              $2401: LangIntName := 'Arabic (Yemen)';
              $2801: LangIntName := 'Arabic (Syria)';
              $2C01: LangIntName := 'Arabic (Jordan)';
              $3001: LangIntName := 'Arabic (Lebanon)';
              $3401: LangIntName := 'Arabic (Kuwait)';
              $3801: LangIntName := 'Arabic (U.A.E.)';
              $3C01: LangIntName := 'Arabic (Bahrain)';
              $4001: LangIntName := 'Arabic (Qatar)';
              $0402: LangIntName := 'Bulgarian';
              $0403: LangIntName := 'Catalan';
              $0404: LangIntName := 'Chinese (Taiwan)';
              $0804: LangIntName := 'Chinese (PRC)';
              $0C04: LangIntName := 'Chinese (Hong Kong)';
              $1004: LangIntName := 'Chinese (Singapore)';
              $0405: LangIntName := 'Czech';
              $0406: LangIntName := 'Danish';
              $0407: LangIntName := 'German (Standard)';
              $0807: LangIntName := 'German (Swiss)';
              $0C07: LangIntName := 'German (Austrian)';
              $1007: LangIntName := 'German (Luxembourg)';
              $1407: LangIntName := 'German (Liechtenstein)';
              $0408: LangIntName := 'Greek';
              $0409: LangIntName := 'English (United States)';
              $0809: LangIntName := 'English (United Kingdom)';
              $0C09: LangIntName := 'English (Australian)';
              $1009: LangIntName := 'English (Canadian)';
              $1409: LangIntName := 'English (New Zealand)';
              $1809: LangIntName := 'English (Ireland)';
              $1C09: LangIntName := 'English (South Africa)';
              $2009: LangIntName := 'English (Jamaica)';
              $2409: LangIntName := 'English (Caribbean)';
              $2809: LangIntName := 'English (Belize)';
              $2C09: LangIntName := 'English (Trinidad)';
              $040A: LangIntName := 'Spanish (Traditional Sort)';
              $080A: LangIntName := 'Spanish (Mexican)';
              $0C0A: LangIntName := 'Spanish (Modern Sort)';
              $100A: LangIntName := 'Spanish (Guatemala)';
              $140A: LangIntName := 'Spanish (Costa Rica)';
              $180A: LangIntName := 'Spanish (Panama)';
              $1C0A: LangIntName := 'Spanish (Dominican Republic)';
              $200A: LangIntName := 'Spanish (Venezuela)';
              $240A: LangIntName := 'Spanish (Colombia)';
              $280A: LangIntName := 'Spanish (Peru)';
              $2C0A: LangIntName := 'Spanish (Argentina)';
              $300A: LangIntName := 'Spanish (Ecuador)';
              $340A: LangIntName := 'Spanish (Chile)';
              $380A: LangIntName := 'Spanish (Uruguay)';
              $3C0A: LangIntName := 'Spanish (Paraguay)';
              $400A: LangIntName := 'Spanish (Bolivia)';
              $440A: LangIntName := 'Spanish (El Salvador)';
              $480A: LangIntName := 'Spanish (Honduras)';
              $4C0A: LangIntName := 'Spanish (Nicaragua)';
              $500A: LangIntName := 'Spanish (Puerto Rico)';
              $040B: LangIntName := 'Finnish';
              $040C: LangIntName := 'French (Standard)';
              $080C: LangIntName := 'French (Belgian)';
              $0C0C: LangIntName := 'French (Canadian)';
              $100C: LangIntName := 'French (Swiss)';
              $140C: LangIntName := 'French (Luxembourg)';
              $040D: LangIntName := 'Hebrew';
              $040E: LangIntName := 'Hungarian';
              $040F: LangIntName := 'Icelandic';
              $0410: LangIntName := 'Italian (Standard)';
              $0810: LangIntName := 'Italian (Swiss)';
              $0411: LangIntName := 'Japanese';
              $0412: LangIntName := 'Korean';
              $0812: LangIntName := 'Korean (JoHab)';
              $0413: LangIntName := 'Dutch (Standard)';
              $0813: LangIntName := 'Dutch (Belgian)';
              $0414: LangIntName := 'Norwegian (Bokmal)';
              $0814: LangIntName := 'Norwegian (Nynorsk)';
              $0415: LangIntName := 'Polish';
              $0416: LangIntName := 'Portuguese (Brazilian)';
              $0816: LangIntName := 'Portuguese (Standard)';
              $0418: LangIntName := 'Romanian';
              $0419: LangIntName := 'Russian';
              $041A: LangIntName := 'Croatian';
              $0C1A: LangIntName := 'Serbian';
              $041B: LangIntName := 'Slovak';
              $041C: LangIntName := 'Albanian';
              $041D: LangIntName := 'Swedish';
              $081D: LangIntName := 'Swedish (Finland)';
              $041E: LangIntName := 'Thai';
              $041F: LangIntName := 'Turkish';
              $0421: LangIntName := 'Indonesian';
              $0422: LangIntName := 'Ukrainian';
              $0423: LangIntName := 'Belarusian';
              $0424: LangIntName := 'Slovenian';
              $0425: LangIntName := 'Estonian';
              $0426: LangIntName := 'Latvian';
              $0427: LangIntName := 'Lithuanian';
              $081A: LangIntName := 'Serbian';
              $0429: LangIntName := 'Farsi';
              $042D: LangIntName := 'Basque';
              $0436: LangIntName := 'Afrikaans';
              $0438: LangIntName := 'Faeroese';
            end; // case
{$ENDIF}
          Result := LangIntName;
        end;
      finally // wrap up
        System.FreeMem(InfoBuffer);
      end; // try/finally
    end;
  end;
begin
  sTemp := GetUILanguage;
  aGlobalLanguage := GlobalLanguage;
  if Pos('German', sTemp) > 0 then
    aGlobalLanguage := 'DE'
  else if Pos('French', sTemp) > 0 then
    aGlobalLanguage := 'FR'
  else if Pos('Spanish', sTemp) > 0 then
    aGlobalLanguage := 'ES'
  else if Pos('Dutch', sTemp) > 0 then
    aGlobalLanguage := 'NL'
  else if Pos('Italian', sTemp) > 0 then
    aGlobalLanguage := 'IT'
  else if Pos('Portuguese', sTemp) > 0 then
    aGlobalLanguage := 'PO'
  else if Pos('Danish', sTemp) > 0 then
    aGlobalLanguage := 'DA'
  else if Pos('Czech', sTemp) > 0 then
    aGlobalLanguage := 'CZ'
  else
    aGlobalLanguage := 'EN';

  if Find('/' + XMLParent + '/' + aGlobalLanguage) = nil then
    aGlobalLanguage := GlobalLanguage;

  GlobalLanguage := aGlobalLanguage;

  GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_IMEASURE, pTemp, SizeOf(pTemp));
  {  if StrToInt(pTemp) = 0 then
      GlobalValueUnit := euCM
    else
      GlobalValueUnit := euInch;  }
end;


function TWPLanguageControl.GetActive: Boolean;
begin
  Result := WPLanguageControl = Self;
end;

procedure TWPLanguageControl.SetActive(x: Boolean);
begin
  if WPLanguageControl = self then
  begin
    if not x then WPLanguageControl := nil;
  end
  else if x then
    WPLanguageControl := Self;
end;

function TWPLanguageControl.GetAutoLoadStrings: Boolean;
begin
{$IFDEF USE_LOCALIZE_U}
  Result := (WPLanguageControl = Self) and WPLocalizeLoadForms;
{$ELSE}
  Result := FALSE;
{$ENDIF}
end;

procedure TWPLanguageControl.SetAutoLoadStrings(x: Boolean);
begin
{$IFDEF USE_LOCALIZE_U}
  if x then SetActive(true);
  WPLocalizeLoadForms := x;
{$ENDIF}
end;

function TWPLanguageControl.GetAutoSaveStrings: Boolean;
begin
{$IFDEF USE_LOCALIZE_U}
  (WPLanguageControl = Self) and WPLocalizeSaveForms;
{$ELSE}
  Result := FALSE;
{$ENDIF}
end;

procedure TWPLanguageControl.SetAutoSaveStrings(x: Boolean);
begin
{$IFDEF USE_LOCALIZE_U}
  if x then SetActive(true);
  WPLocalizeSaveForms := x;
{$ENDIF}
end;

function TWPLanguageControl.GetGlobalLanguage: string;
begin
  Result := WPLocalizeLanguage;
end;

procedure TWPLanguageControl.SetGlobalLanguage(x: string);
var i: Integer;
begin
  i := pos('&', x);
  if i > 0 then System.Delete(x, i, 1);

  if x <> WPLocalizeLanguage then
  begin
    WPLocalizeLanguage := x;
    if AutoLoadStrings and not (csLoading in ComponentState) and
      (Find('/' + XMLParent + '/' + WPLocalizeLanguage) <> nil) then
      LoadVCLStrings;
  end;
end;

constructor TWPLanguageControl.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  AutoCreateClosedTags := TRUE;
  HTMLMode := FALSE;
  DontSaveEmptyTags := TRUE;
  FEntry := 'loc';
end;

destructor TWPLanguageControl.Destroy;
var
  p: string;
begin
  if (FFilename <> '') and AutoSaveStrings then
  try
    p := ExtractFilePath(Application.EXEName);
    if FileExists(p + FFilename) then
      SaveToFile(p + FFilename)
    else if FileExists(FFilename) then
      SaveToFile(FFilename);
  except
  end;
  if WPLanguageControl = Self then WPLanguageControl := nil;
  inherited Destroy;
end;

procedure TWPLanguageControl.Loaded;
var
  p: string;
begin
  inherited Loaded;
  if (FFilename <> '') and AutoLoadStrings then
  try
    p := ExtractFilePath(Application.EXEName);
    if FileExists(p + FFilename) then
      LoadFromFile(p + FFilename)
    else if FileExists(FFilename) then
      LoadFromFile(FFilename);
  except
  end;
  if AutoLoadStrings and
    (Find('/' + XMLParent + '/' + WPLocalizeLanguage) <> nil) then
    LoadVCLStrings;
end;

// --------------------------------------------------------------------------

procedure TWPLanguageControl.SaveVCLStrings;
begin
  // if Assigned(WPLocalSaveVCLStrings) then WPLocalSaveVCLStrings;
end;

procedure TWPLanguageControl.LoadVCLStrings;
begin
  // if Assigned(WPLocalLoadVCLStrings) then WPLocalLoadVCLStrings;
end;

// --------------------------------------------------------------------------
//{$IFDEF VER100}{$DEFINE NODELPHI5}{$ENDIF}
//{$IFDEF VER120}{$DEFINE NODELPHI5}{$ENDIF}

{$DEFINE NODELPHI5} // DELPHI 6 raises an exception when trying to read a property which does
// not exist. Although this exception could be trapped this is not desirable since the
// exception is visible when starting the application in the IDE and also
// will be triggered frequently. so we decided to assume the GetPropValue function does not exist.

{$IFDEF NODELPHI5}

function GetPropValue(Instance: TPersistent; const PropName: string; dummy: Boolean): string;
var
  PropInfo: PPropInfo;
  // TypeData: PTypeData;
begin
  Result := '';
  // get the prop info
  PropInfo := GetPropInfo(Instance.ClassInfo, PropName);
  if PropInfo <> nil then
  begin
    // TypeData := GetTypeData(PropInfo^.PropType^);
    // We only support strings since this is a tranlation tool !
    if PropInfo^.PropType^^.Kind in [tkString, tkLString, tkWString]
      then Result := GetStrProp(
{$IFDEF VER100}Instance.ClassInfo
{$ELSE}{$IFDEF VER120}Instance.ClassInfo
{$ELSE}Instance{$ENDIF}{$ENDIF}, PropInfo);
  end;
end;

procedure SetPropValue(Instance: TPersistent; const PropName: string; const Value: string);
var
  PropInfo: PPropInfo;
  // TypeData: PTypeData;
begin
  // get the prop info
  PropInfo := GetPropInfo(Instance.ClassInfo, PropName);
  if PropInfo <> nil then
  begin
    // TypeData := GetTypeData(PropInfo^.PropType^);
    // We only support strings since this is a tranlation tool !
    if PropInfo.PropType^^.Kind in [tkString, tkLString, tkWString] then
      SetStrProp(Instance, PropInfo, Value);
  end;
end;
{$ENDIF}

procedure TWPLanguageControl.SaveForm(
  const Name: string; // Main TREE
  Form: TWinControl;
  Menus, Captions, Hints: Boolean);
begin
  SaveFormEx(Name, Form, Menus, Captions, Hints);
end;

function TWPLanguageControl.SaveFormEx(
  const Name: string; // Main TREE
  Form: TWinControl;
  Menus, Captions, Hints: Boolean): TWPXMLOneLevel;
var
  Entry: TWPXMLOneLevel; i: Integer; Ignore: Boolean;
  // ------------------------------------------------------------------------
  procedure WriteObj(XMLEntry: TWPXMLOneLevel; obj: TPersistent);
  var
    oName, oCaption, oHint: string;
    Done, NoDefault: Boolean;
    i: Integer;
    function ReadProp(const aName: string): string;
    var
      aValue, aStringVar: Variant;
    begin
      aValue := GetPropValue(obj, aName, True);
      if aValue <> Null then
      begin
        Varcast(aStringVar, aValue, varString);
        Result := aStringVar;
      end
      else
        Result := '';
    end;
    procedure SaveMenuItems(Menu: TMenuItem);
    var
      mEntry: TWPXMLOneLevel;
    begin
      mEntry := XMLEntry.AddTagValue(Menu.Name, '');
      mEntry.ParamValue[CAPTION_PARAM] := Menu.Caption;
      mEntry.ParamValue[HINT_PARAM] := Menu.Hint;
       { for m := 0 to Menu.Count - 1 do
          SaveMenuItems(Menu.Items[m]); }
    end;
  begin
    if (XMLEntry <> nil) and (Menus or not (obj is TMenuItem)) then
    begin
      oName := ReadProp('Name');
      if oName <> '' then
      begin
        XMLEntry := XMLEntry.AddTagValue(oName, '');
        if XMLEntry <> nil then
        begin
          // First try to create the params using our linked procedures
          Done := FALSE;
          NoDefault := FALSE;
          if assigned(WPLocalSaveObjectStrings) then
            WPLocalSaveObjectStrings(obj, XMLEntry.Params, Done, NoDefault);
          // Now, if we may, save using our default code ...
          if not NoDefault then
          begin
            if obj is TMenu then // TMainMenu, TPopupMenu
            begin
              if Menus then
                for i := 0 to TMenu(obj).Items.Count - 1 do
                  SaveMenuItems(TMenu(obj).Items[i]);
            end
            else
              if not (obj is TMenuItem) then // V4.08b - 'TMenuItem' - we saved these above already
              begin
                oCaption := ReadProp('Caption');
                oHint := ReadProp('Hint');
                if Captions and (oCaption <> '') then XMLEntry.ParamValue[CAPTION_PARAM] := oCaption;
                if Hints and (oHint <> '') then XMLEntry.ParamValue[HINT_PARAM] := oHint;
              // Handle some special Properties ....
                if obj is TRadioGroup then
                begin
                  for i := 0 to TRadioGroup(obj).Items.Count - 1 do
                    XMLEntry.ParamValue['I' + IntToStr(i)] := TRadioGroup(obj).Items[i];
                end;

              end;
          end;
          // Only cosmetic - create a line break after this tag
          XMLEntry.WriteLineBreak := TRUE;
        end;
      end;
    end;
  end;
  // ------------------------------------------------------------------------
begin
  Result := nil;
    // |-Entry/LANG/NAME/...
  Entry := Tree.AddTagValue(
    WPXMLPathDelimiter + XMLParent +
    WPXMLPathDelimiter + WPLocalizeLanguage +
    WPXMLPathDelimiter + Name, '');
  Ignore := FALSE;
  if assigned(FBeforeSave) then
    FBeforeSave(Self, Form, Entry, Ignore);
  if not Ignore and (Form is TForm) then
  begin
    Entry.ParamValue[CAPTION_PARAM] := TForm(Form).Caption;
    Entry.ParamValue[HINT_PARAM] := TForm(Form).Hint;
    Entry.ParamValue[CHARSET_PARAM] := IntToStr(TForm(Form).Font.Charset);
    for i := 0 to TForm(Form).ComponentCount - 1 do
      WriteObj(Entry, TForm(Form).Components[i]);
    if assigned(FAfterSave) then
      FAfterSave(Self, Form, Entry);
    Result := Entry;
  end;
end;

procedure TWPLanguageControl.LoadForm(
  const Name: string; // Main TREE
  Form: TWinControl;
  Menus, Captions, Hints: Boolean);
var
  Entry, Entry2: TWPXMLOneLevel;
  i, j: Integer;
  comp: TComponent;
  Done, NoDefault, Ignore: Boolean;
  s, cs: string;
begin
  if Form is TForm then
  begin
    Entry := Tree.FindPath(
      WPXMLPathDelimiter + XMLParent +
      WPXMLPathDelimiter + WPLocalizeLanguage +
      WPXMLPathDelimiter + Name);
    Ignore := FALSE;
    if assigned(FBeforeLoad) then
      FBeforeLoad(Self, Form, Entry, Ignore);

    if not Ignore and (Entry <> nil) then
    begin
      if Entry.ParamValue[CAPTION_PARAM] <> '' then
        TForm(Form).Caption := Entry.ParamValue[CAPTION_PARAM];
      if Entry.ParamValue[HINT_PARAM] <> '' then
        TForm(Form).Hint := Entry.ParamValue[HINT_PARAM];
      cs := Entry.ParamValue[CHARSET_PARAM];
      if cs <> '' then TForm(Form).Font.Charset := StrToIntDef(cs, TForm(Form).Font.Charset);
      for i := 0 to Entry.Count - 1 do
      begin
        comp := TForm(Form).FindComponent(Entry[i].Name);
        if Menus and (comp is TMenu) then //V4.08b
        begin
          for j := 0 to TMenu(comp).Items.Count - 1 do
          begin
            Entry2 := Entry[i].Find(TMenu(comp).Items[j].Name);
            if Entry2 <> nil then
            begin
              SetPropValue(TMenu(comp).Items[j], 'Caption', Entry2.ParamValue[CAPTION_PARAM]);
              SetPropValue(TMenu(comp).Items[j], 'Hint', Entry2.ParamValue[HINT_PARAM]);
            end;
          end;
        end else
          if (comp <> nil) and (Menus or not (comp is TMenuItem)) then
          begin
          // First use the linked procedures
            Done := FALSE;
            NoDefault := FALSE;
            if assigned(WPLocalLoadObjectStrings) then
              WPLocalLoadObjectStrings(comp, Entry.Params, Done, NoDefault);
          // Now, if we may, load using our default procedure ....
            if not NoDefault then
            begin
              SetPropValue(comp, 'Caption', Entry[i].ParamValue[CAPTION_PARAM]);
              SetPropValue(comp, 'Hint', Entry[i].ParamValue[HINT_PARAM]);

            // Handle some special Properties ....
              if comp is TRadioGroup then
              begin
                for j := 0 to TRadioGroup(comp).Items.Count - 1 do
                begin
                  s := Entry[i].ParamValue['I' + IntToStr(j)];
                  if s <> '' then TRadioGroup(comp).Items[j] := s;
                end;
              end;
            end;
          end;
      end;
    end;
    if assigned(FAfterLoad) then
      FAfterLoad(Self, Form, Entry);
  end;
end;

procedure TWPLanguageControl.SaveStrings(const Name: string;
  Entries: TStrings; Charset: Integer);
var
  Entry: TWPXMLOneLevel;
begin
  Entry := Tree.AddTagValue(
    WPXMLPathDelimiter + XMLParent +
    WPXMLPathDelimiter + WPLocalizeLanguage +
    WPXMLPathDelimiter + Name, '');
  Entry.MergeParams(Entries);
  if Charset > 1 then Entry.ParamValue[CHARSET_PARAM] := IntToStr(Charset);
end;

function TWPLanguageControl.LoadStrings(const Name: string;
  Entries: TStrings; var Charset: Integer): Boolean;
var
  Entry: TWPXMLOneLevel;
  i, cs: Integer;
begin
  Entry := Tree.FindPath(
    WPXMLPathDelimiter + XMLParent +
    WPXMLPathDelimiter + WPLocalizeLanguage +
    WPXMLPathDelimiter + Name);
  if Entry <> nil then
  try
    Entries.BeginUpdate;
    Entries.Clear;
    cs := Entry.Params.IndexOfName(CHARSET_PARAM);
    for i := 0 to Entry.Params.Count - 1 do
      if i <> cs then Entries.Add(Entry.Params[i]);
    if cs >= 0 then
      Charset := StrToIntDef(Entry.ParamValue[CHARSET_PARAM], 0);
    Result := TRUE;
  finally
    Entries.EndUpdate;
  end
  else
    Result := FALSE;
end;

procedure TWPLanguageControl.SaveString(const Name, Text: string; Charset: Integer);
var
  Entry: TWPXMLOneLevel;
begin
  Entry := Tree.AddTagValue(
    WPXMLPathDelimiter + XMLParent +
    WPXMLPathDelimiter + WPLocalizeLanguage +
    WPXMLPathDelimiter + Name, Text);
  if Charset > 1 then Entry.ParamValue[CHARSET_PARAM] := IntToStr(Charset);
end;

function TWPLanguageControl.LoadString(const Name: string;
  var Text: string; var Charset: Integer): Boolean;
var
  Entry: TWPXMLOneLevel;
  cs: string;
begin
  if Name='WPLocalizeLanguage' then  //V5.18.1
  begin
    Text := WPLocalizeLanguage;
    Charset := DEFAULT_CHARSET;
    Result := TRUE;
  end else
  begin
  Entry := Tree.FindPath(
    WPXMLPathDelimiter + XMLParent +
    WPXMLPathDelimiter + WPLocalizeLanguage +
    WPXMLPathDelimiter + Name);
  if Entry <> nil then
  begin
    cs := Entry.ParamValue[CHARSET_PARAM];
    if cs <> '' then
      Charset := StrToIntDef(Entry.ParamValue[CHARSET_PARAM], 0);
    Text := Entry.Content;
    Result := TRUE;
  end
  else
    Result := FALSE;
  end;
end;


// *****************************************************************************
// *****************************************************************************
// *****************************************************************************
// *****************************************************************************

// This 6 procedures are accessible globally through the events in unit WPLocalize
// They can be executed for a form to save all the properties to XML format
// and they can be used to load the information agaian.

procedure doWPLangSaveForm(
  const Name: string;
  Form: TWinControl;
  Menus, Captions, Hints: Boolean);
begin
  if WPLanguageControl <> nil then
    WPLanguageControl.SaveForm(Name, Form, Menus, Captions, Hints);
end;

procedure doWPLangLoadForm(
  const Name: string; // Main TREE
  Form: TWinControl;
  Menus, Captions, Hints: Boolean);
begin
  if WPLanguageControl <> nil then
    WPLanguageControl.LoadForm(Name, Form, Menus, Captions, Hints);
end;


//: Saves certain strings

procedure doWPLangSaveStrings(
  const Name: string;
  Entries: TStrings;
  Charset: Integer);
begin
  if WPLanguageControl <> nil then
    WPLanguageControl.SaveStrings(Name, Entries, Charset);
end;

//: Loads back this string(s)

function doWPLangLoadStrings(
  const Name: string;
  Entries: TStrings;
  var Charset: Integer): Boolean;
begin
  if WPLanguageControl <> nil then
    Result := WPLanguageControl.LoadStrings(Name, Entries, Charset)
  else
    Result := FALSE;
end;

//: Saves a certain strings

procedure doWPLangSaveString(
  const Name, Text: string;
  Charset: Integer);
begin
  if WPLanguageControl <> nil then
    WPLanguageControl.SaveString(Name, Text, Charset);
end;

//: Loads back this string

function doWPLangLoadString(
  const Name: string;
  var Text: string;
  var Charset: Integer): Boolean;
begin
  if WPLanguageControl <> nil then
    Result := WPLanguageControl.LoadString(Name, Text, Charset)
  else
    Result := FALSE;
end;

// Encryption, based on Function RC4EncodeString(Var Source,key:String):String;
// found on http://www.delphidev.com/issue1/rc4.html.

function doWPEncryptData(
  Data: PChar;
  DataLen: Integer;
  const Key: string): Boolean;
var
  S: array[0..255] of Byte;
  K: array[0..255] of byte;
  Temp, y: Byte;
  I, J, T, X: Integer;
begin
  if DataLen = 0 then
    Result := FALSE
  else
  begin
    // Prepare the keys
    for i := 0 to 255 do
      s[i] := i;

    J := 1;
    for I := 0 to 255 do
    begin
      if j > length(key) then j := 1;
      k[i] := byte(key[j]);
      inc(j);
    end;

    J := 0;
    for i := 0 to 255 do
    begin
      j := (j + s[i] + k[i]) mod 256;
      temp := s[i];
      s[i] := s[j];
      s[j] := Temp;
    end;
    // Do the encryption - inplace
    i := 0;
    j := 0;
    for x := 0 to DataLen - 1 do
    begin
      i := (i + 1) mod 256;
      j := (j + s[i]) mod 256;
      temp := s[i];
      s[i] := s[j];
      s[j] := temp;
      t := (s[i] + (s[j] mod 256)) mod 256;
      y := s[t];
      (Data + x)^ := char(byte((Data + x)^) xor y);
    end;
    result := TRUE;
  end;
end;


{$IFDEF USE_LOCALIZE_U}
initialization

  WPLangSaveForm := Addr(doWPLangSaveForm);
  WPLangLoadForm := Addr(doWPLangLoadForm);
  WPLangSaveString := Addr(doWPLangSaveString);
  WPLangLoadString := Addr(doWPLangLoadString);
  WPLangSaveStrings := Addr(doWPLangSaveStrings);
  WPLangLoadStrings := Addr(doWPLangLoadStrings);
  WPEncryptData := doWPEncryptData; 

finalization

  WPLangSaveForm := nil;
  WPLangLoadForm := nil;
  WPLangSaveString := nil;
  WPLangLoadString := nil;
  WPLangSaveStrings := nil;
  WPLangLoadStrings := nil;
  WPEncryptData := nil;
{$ENDIF}

end.

