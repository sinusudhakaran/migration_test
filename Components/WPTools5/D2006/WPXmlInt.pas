unit WPXMLint;
{ -----------------------------------------------------------------------------
  WPXMLInterface - Copyright (C) 2002 by wpcubed GmbH -  all rigths reserved!
  Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  You may use this unit if you are a registered user of WPTools 4 or WPForm 2
  Both products use this uint for loading/saving XML data and for localization
  -----------------------------------------------------------------------------
  Distribution of the "WPXMLint" unit in object and source form is not allowed
  -----------------------------------------------------------------------------
  Summary:
  TWPXMLInterface - Component to load and save an XML file. While loading
  and saving the tags, parameters and texts are created/provided by/to events.
  TWPCustomXMLTree - Component (based on TWPCustomXMLInterface) to load and
  save XML files to a tree representation stored in memory.
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

// Version 1.0   -  release 21.2.2002 - Julian Ziersch
// Version 1.01  -  improvements to XMLWriter to created indented Layout
// Version 1.02  -  fixed problem with CR after tag
// version 2.00  -  Revised to eliminate Pointers

{$DEFINE WPDEBUG}
{$DEFINE EMPTY_IN_APPEND} // AppendFromFile clears strings of all tags on the way
{.$DEFINE WPDEMO}
{.$DEFINE AFLAG}

{$IFNDEF WPDEBUG}{$D-}{$Y-}{$Q-}{$R-}{$L-}{$ENDIF}
{$B-}
{$IFDEF VER100}{$DEFINE NODELPHI5}{$ENDIF}
{$IFDEF VER110}{$DEFINE NODELPHI5}{$ENDIF}
{$IFDEF VER120}{$DEFINE NODELPHI5}{$ENDIF}
{$IFDEF VER140}{$DEFINE DELPHI6ANDUP}{$ENDIF}
{$IFDEF VER150}{$DEFINE DELPHI6ANDUP}
{$WARNINGS ON}{$ENDIF}
{$R+}

{ --------------------------------------------------------------------
  *** TWPCustomXMLInterface ***
  This  is  a  basic  XML  Interface  class.  It was not created as an
  utility  for  a simple interface to XML for property definitions and
  to load and save XML/CSS format.

  It provides the following intelligence:
  * reading *
    -  if  a not matching end-tag is found it looks in the stack if it
    finds  a  previous  start  tag  of this kind and if it does not it
    ignores  the  tag but reports and error Otherwise it automatically
    closes the not closed tags up to this position
    -  if  a  comment  is  found it automatically removes the <!-- and
    spaces at the beginning and at the end.
    - In HTMLmode a few tags are detected to be closed, this are META,
    BR, HR and BASEFONT.
    -  for each opened stack a new record is saved (DataSize). You can
    use  this  record to store data. When you get the close data event
    automatically  the  previous data record is available! You can use
    the Data in the OnReadText.
  * writing *
    - Encoding is written
    - The comma separated list of CSS references is automatically
      written as xml-stylesheets
    - OpenTag  automatically  creates a empty record on the Stack The
    record  must  not contain any strings (shortstrings are ok). It is
    accessible using the function Data
    -  CloseTag is able to automatically close several open tags until
    the  tag  which  has the same name is found. This produces only an
    error if such a tag does not exist on the stack.

 *** TWPCustomXMLTree ***
 This  class  is based on TWPCustomXMLInterface. I allocates an intern
 tree  to  hold  all the data of the XML file. It was designed to hold
 also  XML  alike  code  such as HTML. It supports methods to find and
 replaces  XML  nodes,  to  save  a  node and to delete nodes. It even
 supports  search  in  the  text  and xml params. The unit WPXmlEditor
 contains  a  valuable editor which manipulates the data stored in the
 XML tree.
 --------------------------------------------------------------------- }


interface

uses Classes, SysUtils, Graphics
{$IFDEF WPDEMO}, Dialogs, Forms, Stdctrls{$ENDIF};

type
  {: This errors can happen at read time. We try to fix the problem by ignoring close tags }
  TWPXMLError = (wpxmlErrMissingCloseTags, wpxmlErrCloseTagIgnored,
    wpxmlUnexpectedEndOfFile, wpxmlStyleSheetHasNoURL);

  {: XML error. Created only if DontAllowMultTagsOnFirstLevel = TRUE !  }
  EWPXMLMultipleEntriesOnFirstLevelError = class(Exception);

  TWPCustomXMLInterface = class;
  TWPXMLInterfaceReadTagStart =
    procedure(Sender: TWPCustomXMLInterface; // Read <p ...>   and <p ...\>
    const TagName: string;
    var Params: TStringList;
    IsClosed: Boolean) of object;
  TWPXMLInterfaceReadTagEnd = // read <\p>
    procedure(Sender: TWPCustomXMLInterface;
    const TagName: string) of object;
  TWPXMLInterfaceReadComment = // read <!--  --> - the comment char are skipped !
    procedure(Sender: TWPCustomXMLInterface;
    const CommentText: string) of object;
  TWPXMLInterfaceReadText = // read text (inbetween 2 tags!)
    procedure(Sender: TWPCustomXMLInterface;
    const Text: string) of object;

  TWPXMLInterfaceReadError = // read text (inbetween 2 tags!)
    procedure(Sender: TWPCustomXMLInterface;
    Error: TWPXMLError;
    Position: Integer) of object;

  TWPXMLStyleSheetMode = (wpcssSaveAsLink, wpcssEmbedInHTML, wpcssIgnore);

  TWPXMLStyleSheet = class(TCollectionItem)
{$IFNDEF T2H}
  private
    FURL: string;
    FSheet: string;
    FMode: TWPXMLStyleSheetMode;
    FMedia: string; // screen, print, all ...
  protected
    function GetDisplayName: string; override;
  public
    procedure Assign(Source: TPersistent); override;
    procedure SaveToFile(const CSSFileName: string);
{$ENDIF}
  published
    property URL: string read FURL write FURL;
    property Sheet: string read FSheet write FSheet;
    property Mode: TWPXMLStyleSheetMode read FMode write FMode;
    property Media: string read FMedia write FMedia;
  end;

  TWPXMLStyleSheetCollection = class(TCollection)
{$IFNDEF T2H}
  private
    FOwner: TPersistent;
    function GetItem(index: Integer): TWPXMLStyleSheet;
    procedure SetItem(index: Integer; x: TWPXMLStyleSheet);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create;
{$ENDIF}
    procedure AppendFromFile(const CSSFileName: string);
    property Items[index: Integer]: TWPXMLStyleSheet read GetItem write SetItem; default;
  end;


  TWPXMLInterfaceWriteText = // Write Event
    procedure(Sender: TWPCustomXMLInterface) of object;

{$IFNDEF T2H}
  TWPXMLInterfaceStack = class
    Tag: string;
    Next: TWPXMLInterfaceStack;
    Data: array of Byte;
    ID: Integer;
    Obj: TObject; // any use
  end;

  TWPXMLInterfaceData = class(TPersistent)
  private
    Owner: TWPCustomXMLInterface;
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure ReadData(Stream: TStream); virtual;
    procedure WriteData(Stream: TStream); virtual;
  public
    procedure Assign(Source: TPersistent); override;
  end;
{$ENDIF}

  TWPCustomXMLInterface = class(TComponent)
{$IFNDEF T2H}
  private
    FData: TMemoryStream;
    FWriteIndentedLayout: Boolean;
    FXMLInterfaceData: TWPXMLInterfaceData;
    FPassword: string;
    FCompress: Boolean;
    FDataSize: Integer;
    FWorkList: TStringList;
    FHTMLMode: Boolean;
    FNoXMLHeader: Boolean;
    FEncoding: string;
    FUseOnlyXMLEntities: Boolean;
    FXMLStyleSheet: TWPXMLStyleSheetCollection;
    // The Load Events
    FOnStartTag: TWPXMLInterfaceReadTagStart;
    FOnEndTag: TWPXMLInterfaceReadTagEnd;
    FOnComment: TWPXMLInterfaceReadComment;
    FOnText: TWPXMLInterfaceReadText;
    FOnLoaded: TNotifyEvent;
    // The write Events
    FOnWriteTextStart: TWPXMLInterfaceWriteText;
    FOnWriteTextEnd: TWPXMLInterfaceWriteText;
    // Error Event
    FOnError: TWPXMLInterfaceReadError;
{$IFDEF DELPHI6ANDUP}
    FUTF8, FHasUTF8: Boolean;
{$ENDIF}
    procedure SetDataSize(x: Integer);
    procedure Push(const Tag: string);
    function GetDepth: Integer;
    function TestStack(const Tag: string): Boolean;
    procedure Pop(const Tag: string);
    function GetObjectStack: TObject;
    procedure SetObjectStack(x: TObject);
    function GetStack: Pointer;
    function GetXMLData: TWPXMLInterfaceData;
    procedure SetXMLData(x: TWPXMLInterfaceData);
    function GetAsString: string;
    procedure SetAsString(const x: string);
    function GetStyleSheets: TWPXMLStyleSheetCollection;
    procedure SetStyleSheets(x: TWPXMLStyleSheetCollection);
  protected
    FStack: TWPXMLInterfaceStack;
    FPosInData: Integer;
    function ParamsToStr(const params: TStringList): string; // Useful function
    function StrToParams(const Input: string): TStringList;
    procedure ReplaceEntities(var s: string; OnlyXML: Boolean);
    procedure ReadLoop; virtual;
    procedure InternReadTag(s: string);
    procedure DoReadTag(const TagName: string; var Params: TStringList; IsClosed: Boolean); virtual;
    procedure DoReadTagEnd(const TagName: string); virtual;
    procedure DoReadComment(const s: string); virtual;
    procedure DoReadText(const s: string); virtual;
    procedure DoError(Error: TWPXMLError); virtual;
    procedure DoLoaded; virtual;
    procedure DestroyData(data: TWPXMLInterfaceStack); virtual;
  public
    procedure DoWriteStart; virtual;
    procedure DoWriteEnd; virtual;
{$ENDIF}
  public
{$IFNDEF T2H}
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
{$ENDIF}
    property Depth: Integer read GetDepth;
    property WriteIndented: Boolean read FWriteIndentedLayout write FWriteIndentedLayout;
    procedure Clear; virtual;
    // Loading is done through 4 events
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromFile(const Filename: string);
    procedure SaveToFile(const Filename: string);
    procedure SaveToStream(Stream: TStream);
    procedure WriteStylesheets;
    // Saving is done by  this procedure in the WriteStart or WriteEnd event
    procedure WriteNative(const s: string);
    procedure Write(const s: string);
    procedure Writeln(const s: string);
    procedure WriteTag(const Tag: string; const params: TStringList); // Writes a closed tag
    function MakeStyleParam(s: string): TStringList;
    function OpenTag(const Tag: string; const params: TStringList): Integer; // Starts a tag
    function CurrentTag: string;
    procedure CloseTagID(ID: Integer);
    procedure CloseTag(const Tag: string); // Closes all tags until it finds the named tag, '' closes the last tag
    procedure CloseAllTags;
    // Read the current data
  public
{$IFDEF DELPHI6ANDUP}
    property UTF8: Boolean read FUTF8 write FUTF8 default FALSE;
{$ENDIF}
{$IFNDEF T2H}
    property Password: string read FPassword write FPassword;
    property Compress: Boolean read FCompress write FCompress;
{$ENDIF}
    property Stack: Pointer read GetStack;
    property WorkStringList: TStringList read FWorkList;
    property ObjectStack: TObject read GetObjectStack write SetObjectStack;
    property DataSize: Integer read FDataSize write SetDataSize;
    property HTMLMode: Boolean read FHTMLMode write FHTMLMode;
    property UseOnlyXMLEntities: Boolean read FUseOnlyXMLEntities write FUseOnlyXMLEntities;
    property Encoding: string read FEncoding write FEncoding;
    property StyleSheets: TWPXMLStyleSheetCollection read GetStyleSheets write SetStyleSheets;
    property OnStartTag: TWPXMLInterfaceReadTagStart read FOnStartTag write FOnStartTag;
    property OnEndTag: TWPXMLInterfaceReadTagEnd read FOnEndTag write FOnEndTag;
    property OnComment: TWPXMLInterfaceReadComment read FOnComment write FOnComment;
    property OnText: TWPXMLInterfaceReadText read FOnText write FOnText;
    property OnError: TWPXMLInterfaceReadError read FOnError write FOnError;
    property OnWriteTextStart: TWPXMLInterfaceWriteText read FOnWriteTextStart write FOnWriteTextStart;
    property OnWriteTextEnd: TWPXMLInterfaceWriteText read FOnWriteTextEnd write FOnWriteTextEnd;
    property OnLoaded: TNotifyEvent read FOnLoaded write FOnLoaded;
    property XMLData: TWPXMLInterfaceData read GetXMLData write SetXMLData;
    property AsString: string read GetAsString write SetAsString;
    property MemoryStream: TMemoryStream read FData;
  end;

  TWPXMLInterface = class(TWPCustomXMLInterface)
{$IFNDEF T2H}
  public
    property Stack;
    property ObjectStack;
  published
    property DataSize default 0;
    property HTMLMode default FALSE;
    property StyleSheets;
    property UseOnlyXMLEntities default TRUE;
    property Encoding;
    // property Compressed;
    // property Password;
    property OnStartTag;
    property OnEndTag;
    property OnComment;
    property OnText;
    property OnError;
    property OnWriteTextStart;
    property OnWriteTextEnd;
{$ENDIF}
  end;

  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  TWPCustomXMLTree = class;

  TWPXMLOneLevel = class(TList)
{$IFNDEF T2H}
  protected
    FParent: TWPCustomXMLTree;
    FOwner: TWPXMLOneLevel;
    // We save this as a TWPXMLOneLevel to avoid slow 'is' statements
    FIsText: Boolean; // This is not a tag, just some text
    FIsClosed: Boolean;
    FIsNew: Boolean; // Used while appending data
    FName: string;
    FContent: string;
{$IFDEF DELPHI6ANDUP}
    FContentIsUTF8: Boolean;
{$ENDIF}
    FComment: string;
    FLowercaseName: string; // faster compare !
    FIsCDDATA: Boolean;
    FNameLen: Integer;
    FParams: TStringList;
    FWriteLineBreak: Boolean;
    FSelected: Boolean;
    FObject: TObject;
    FAnyData: TObject; // assign data which is automatically freed on 'Destroy'
    procedure SetName(const x: string);
    procedure SetPath(const x: string);
    function GetAnyData: TObject;
    procedure SetAnyData(x: TObject);
    procedure SetParent(x: TWPXMLOneLevel);
    function GetPath: string;
    function GetSubElement(index: Integer): TWPXMLOneLevel;
    function GetParams: TStringList;
    procedure SetParams(x: TStringList);
    function GetParamCount: Integer;
    procedure SetParamValue(index: string; const Value: string);
    function GetParamValue(index: string): string;
{$IFDEF AFLAG}
    function GetInheritedParamValue(index: string): string;
    function GetSelectedInheritedParamValue(index: string; possibletags: array of string): string;
{$ENDIF}
    function GetColonText: string;
    function GetCommaText: string;
    function GetAsString: string;
    procedure SetSelected(x: Boolean);
    function FastFind(const TagName: string): TWPXMLOneLevel;
    function InternAddTagValue(const TagPathName: string; const Value: string; SetValue: Boolean): TWPXMLOneLevel;
  protected
{$IFNDEF NODELPHI5} // No Delphi 3
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
{$ENDIF}
{$ENDIF}
  public
{$IFDEF NODELPHI5} // Only Delphi 3
    function Add(Item: Pointer): Integer;
{$ENDIF}
    constructor Create(aOwner: TWPCustomXMLTree);
    destructor Destroy; override;
    procedure Clear; {$IFNDEF VER100} override; {$ENDIF}
    function Find(const TagName: string): TWPXMLOneLevel;
    {:: Value of an element of this tag }
    function GetEValue(const TagName: string; DefValue: Integer): Integer;
    function GetSValue(const TagName: string): String;
    function HasElement(const TagName: string): Boolean;
    function Depth: Integer;
    function FindRecursive(const TagName: string): TWPXMLOneLevel;
    function NameEqual(const LowerCaseName: string): Boolean;
    function InsideName(const LowerCaseName: string): Boolean;
    function FindPath(const TagPathName: string): TWPXMLOneLevel;
    function FindText(Text: string; CaseSensitive, Recursive: Boolean; List: TList): TWPXMLOneLevel;
    function AddTagValue(const TagPathName: string; const Value: string): TWPXMLOneLevel; overload;
    function AddTagValue(const TagPathName: string; const Value: Integer): TWPXMLOneLevel; overload;
    function AddTag(const TagPathName: string): TWPXMLOneLevel;
    function AppendTag(const Name: string): TWPXMLOneLevel;
    procedure MergeParams(Source: TStrings);
    function HasParam(index: string): Boolean;
    procedure SaveToFile(const FileName: string; WithPath: Boolean);
    procedure SaveToStream(Stream: TStream; WithPath: Boolean);
    function ParamValueDef(const ParamName: string; DefValue: Integer = 0): Integer;
    property AnyData: TObject read GetAnyData write SetAnyData;
    property Elements[index: Integer]: TWPXMLOneLevel read GetSubElement; default;
    property Name: string read FName write SetName;
    property Path: string read GetPath write SetPath;
    property Parent: TWPXMLOneLevel read FOwner write SetParent;
    property ParamCount: integer read GetParamCount;
    property Params: TStringList read GetParams write SetParams;
    property ParamValue[index: string]: string read GetParamValue write SetParamValue;
{$IFDEF AFLAG}
    property ParamInheritedValue[index: string]: string read GetInheritedParamValue;
{$ENDIF}
{$IFDEF DELPHI6ANDUP}
    property ContentIsUTF8: Boolean read FContentIsUTF8 write FContentIsUTF8;
{$ENDIF}
    property Content: string read FContent write FContent; // The free text
    property Comment: string read FComment write FComment; // <!-- Comment
    property IsClosed: Boolean read FIsClosed write FIsClosed;
    property IsText: Boolean read FIsText; // set Name = '' to make it a "text"
    property IsCDDATA: Boolean read FIsCDDATA write FIsCDDATA; // TODO
    property WriteLineBreak: Boolean read FWriteLineBreak write FWriteLineBreak;
    property Selected: Boolean read FSelected write SetSelected;
    property Obj: TObject read FObject write FObject; // any use
    property ColonText: string read GetColonText;
    property CommaText: string read GetCommaText;
    property AsString: string read GetAsString;
  end;
  TWPXMLLevelClass = class of TWPXMLOneLevel;

  TWPCustomXMLTree = class(TWPCustomXMLInterface)
{$IFNDEF T2H}
  private
    FFirst: TWPXMLOneLevel;
    FModified: Boolean;
    FItemClass: TWPXMLLevelClass;
    FCurrentItem: TWPXMLOneLevel; // While reading !
    FAllowTextOutsideOfTags: Boolean;
    FAutoCreateClosedTags: Boolean;
    FDontSaveEmptyTags: Boolean;
    FSaveItem: TWPXMLOneLevel;
    FSaveItemParents, FSaveSelected: Boolean;
    FDontAllowMultTagsOnFirstLevel: Boolean;
    FReadingStyle: Boolean;
    FLastComment: string;
    function GetFirst: TWPXMLOneLevel;
  protected
    FAppendMode: Boolean;
    procedure ReadLoop; override;
    procedure DoReadTag(const TagName: string; var Params: TStringList; IsClosed: Boolean); override;
    procedure DoReadTagEnd(const TagName: string); override;
    procedure DoReadComment(const s: string); override;
    procedure DoReadText(const s: string); override;
{$IFDEF AFLAG}
    constructor CreateEx(aOwner: TComponent; aItemClass: TWPXMLLevelClass); virtual;
{$ENDIF}
{$ENDIF}
  public
{$IFNDEF T2H}
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
{$ENDIF}
    procedure Clear; override;
    procedure Assign(Source: TPersistent); override;
    procedure DoWriteStart; override;
    procedure AppendFromFile(const Filename: string);
    procedure AppendFromStream(Stream: TStream);
    procedure AppendFromString(s: string);
    procedure LoadFromString(s: string);
    function AsANSIString: string;
    procedure GetList(List: TStrings);
    function ValueOf(const TagName, ParamName: string): string;
    function Find(const TagPathName: string): TWPXMLOneLevel;
    function FindParName(const TagPathName: string;
      ParamName: string): TWPXMLOneLevel;
    function TagByName(const TagPathName: string): TWPXMLOneLevel;
    property Tree: TWPXMLOneLevel read GetFirst;
    property Modified: Boolean read FModified write FModified;
    property AutoCreateClosedTags: Boolean read FAutoCreateClosedTags write FAutoCreateClosedTags;
    property AllowTextOutsideOfTags: Boolean read FAllowTextOutsideOfTags write FAllowTextOutsideOfTags;
    property DontSaveEmptyTags: Boolean read FDontSaveEmptyTags write FDontSaveEmptyTags;
    property DontAllowMultTagsOnFirstLevel: Boolean read FDontAllowMultTagsOnFirstLevel write FDontAllowMultTagsOnFirstLevel;
  end;

  TWPXMLTree = class(TWPCustomXMLTree)
{$IFNDEF T2H}
  public
    property Tree;
  published
    property HTMLMode default FALSE;
    property UseOnlyXMLEntities default TRUE;
    property AllowTextOutsideOfTags default FALSE;
    property AutoCreateClosedTags default FALSE;
    property DontSaveEmptyTags default FALSE;
    property DontAllowMultTagsOnFirstLevel default FALSE;
    property Encoding;
    property StyleSheets;
    // property Compressed;
    // property Password;
    property OnError;
    property OnWriteTextStart;
    property OnWriteTextEnd;
    property OnLoaded;
    property XMLData;
{$ENDIF}
  end;

{$IFNDEF T2H}
const
  WPXMLPathDelimiter = '/';
  WPXMLVersion = 100; // V1.00
{$ENDIF}

implementation

uses Math;

type
  TWPSpecialChar = record c: Char; p: PChar
  end;
const
  CLOSE_ALLTAGS = '$ALL$';
  HTML_CLOSETAGS_COUNT = 7;
  HTML_CLOSETAGS: array[1..HTML_CLOSETAGS_COUNT] of string =
  ('HR', 'BR', 'META', 'BASEFONT', 'IMG', 'INPUT', '!DOCTYPE');
  maxwpspch = 105;

  wpspch: array[1..maxwpspch] of TWPSpecialChar =
  (
    (c: #34; p: 'quot'),
    (c: #38; p: 'amp'),
    (c: '<'; p: 'lt'),
    (c: '>'; p: 'gt'),
    //  (c: ''''; p: 'apos'),
    (c: #128; p: '#8364'), // EURO
    (c: #47; p: '#8260'), // frasl
    (c: #47; p: 'frasl'),
    (c: #150; p: 'ndash'),
    (c: #151; p: 'mdash'),
    (c: #160; p: 'nbsp'),
    (c: #161; p: 'iexcl'),
    (c: #162; p: 'cent'),
    (c: #163; p: 'pound'),
    (c: #164; p: 'curren'),
    (c: #165; p: 'yen'),
    (c: #166; p: 'brvbar'),
    (c: #167; p: 'sect'),
    (c: #168; p: 'uml'),
    (c: #169; p: 'copy'),
    (c: #170; p: 'ordf'),
    (c: #171; p: 'laquo'),
    (c: #172; p: 'not'),
    (c: #173; p: 'shy'),
    (c: #174; p: 'reg'),
    (c: #175; p: 'macr'),
    (c: #176; p: 'deg'),
    (c: #177; p: 'plusmn'),
    (c: #178; p: 'sup2'),
    (c: #179; p: 'sup3'),
    (c: #180; p: 'acute'),
    (c: #181; p: 'micro'),
    (c: #182; p: 'para'),
    (c: #183; p: 'middot'),
    (c: #184; p: 'cedil'),
    (c: #185; p: 'sup1'),
    (c: #186; p: 'ordm'),
    (c: #187; p: 'raquo'),
    (c: #188; p: 'frac14'),
    (c: #189; p: 'frac12'),
    (c: #190; p: 'frac34'),
    (c: #191; p: 'iquest'),
    (c: #192; p: 'Agrave'),
    (c: #193; p: 'Aacute'),
    (c: #194; p: 'Acirc'),
    (c: #195; p: 'Atilde'),
    (c: #196; p: 'Auml'),
    (c: #197; p: 'Aring'),
    (c: #198; p: 'AElig'),
    (c: #199; p: 'Ccedil'),
    (c: #200; p: 'Egrave'),
    (c: #201; p: 'Eacute'),
    (c: #202; p: 'Ecirc'),
    (c: #203; p: 'Euml'),
    (c: #204; p: 'Igrave'),
    (c: #205; p: 'Iacute'),
    (c: #206; p: 'Icirc'),
    (c: #207; p: 'Iuml'),
    (c: #208; p: 'ETH'),
    (c: #209; p: 'Ntilde'),
    (c: #210; p: 'Ograve'),
    (c: #211; p: 'Oacute'),
    (c: #212; p: 'Ocirc'),
    (c: #213; p: 'Otilde'),
    (c: #214; p: 'Ouml'),
    (c: #215; p: 'times'),
    (c: #216; p: 'Oslash'),
    (c: #217; p: 'Ugrave'),
    (c: #218; p: 'Uacute'),
    (c: #219; p: 'Ucirc'),
    (c: #220; p: 'Uuml'),
    (c: #221; p: 'Yacute'),
    (c: #222; p: 'THORN'),
    (c: #223; p: 'szlig'),
    (c: #224; p: 'agrave'),
    (c: #225; p: 'aacute'),
    (c: #226; p: 'acirc'),
    (c: #227; p: 'atilde'),
    (c: #228; p: 'auml'),
    (c: #229; p: 'aring'),
    (c: #230; p: 'aelig'),
    (c: #231; p: 'ccedil'),
    (c: #232; p: 'egrave'),
    (c: #233; p: 'eacute'),
    (c: #234; p: 'ecirc'),
    (c: #235; p: 'euml'),
    (c: #236; p: 'igrave'),
    (c: #237; p: 'iacute'),
    (c: #238; p: 'icirc'),
    (c: #239; p: 'iuml'),
    (c: #240; p: 'eth'),
    (c: #241; p: 'ntilde'),
    (c: #242; p: 'ograve'),
    (c: #243; p: 'oacute'),
    (c: #244; p: 'ocirc'),
    (c: #245; p: 'otilde'),
    (c: #246; p: 'ouml'),
    (c: #247; p: 'divide'),
    (c: #248; p: 'oslash'),
    (c: #249; p: 'ugrave'),
    (c: #250; p: 'uacute'),
    (c: #251; p: 'ucirc'),
    (c: #252; p: 'uuml'),
    (c: #253; p: 'yacute'),
    (c: #254; p: 'thorn'),
    (c: #255; p: 'yuml'));

var
  inwpspch: array[Char] of PChar;

// *****************************************************************************

procedure TWPXMLInterfaceData.DefineProperties(Filer: TFiler);
begin
  Filer.DefineBinaryProperty('Data', ReadData, WriteData, true);
end;

procedure TWPXMLInterfaceData.ReadData(Stream: TStream);
begin
  Owner.LoadFromStream(Stream);
end;

procedure TWPXMLInterfaceData.WriteData(Stream: TStream);
begin
  Owner.SaveToStream(Stream);
end;

procedure TWPXMLInterfaceData.Assign(Source: TPersistent);
var
  temp: TMemoryStream;
begin
  if Source is TWPXMLInterfaceData then
  begin
    temp := TMemoryStream.Create;
    try
      TWPXMLInterfaceData(Source).Owner.SaveToStream(temp);
      temp.Position := 0;
      Owner.LoadFromStream(temp);
    finally
      temp.Free;
    end;
  end else inherited Assign(Source);
end;

// *****************************************************************************
// *****************************************************************************
// *****************************************************************************

function TWPXMLStyleSheet.GetDisplayName: string;
begin
  Result := 'xml-stylesheet type="text/css" href="' + FURL + '"';
end;

procedure TWPXMLStyleSheet.Assign(Source: TPersistent);
begin
  if Source is TWPXMLStyleSheet then
  begin
    FURL := TWPXMLStyleSheet(Source).FURL;
    FSheet := TWPXMLStyleSheet(Source).FSheet;
    FMode := TWPXMLStyleSheet(Source).FMode;
    FMedia := TWPXMLStyleSheet(Source).FMedia;
  end
  else
    inherited Assign(Source);
end;

procedure TWPXMLStyleSheet.SaveToFile(const CSSFileName: string);
begin
  with TFileStream.Create(CSSFileName, fmCreate) do
  try
    if FSheet <> '' then
      Write(FSheet[1], Length(FSheet));
    FURL := CSSFileName;
  finally
    Free;
  end;
end;

function TWPXMLStyleSheetCollection.GetItem(index: Integer): TWPXMLStyleSheet;
begin
  Result := TWPXMLStyleSheet(inherited items[index]);
end;

procedure TWPXMLStyleSheetCollection.SetItem(index: Integer; x: TWPXMLStyleSheet);
begin
  TWPXMLStyleSheet(inherited items[index]).Assign(x);
end;

function TWPXMLStyleSheetCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

constructor TWPXMLStyleSheetCollection.Create;
begin
  inherited Create(TWPXMLStyleSheet);
end;

procedure TWPXMLStyleSheetCollection.AppendFromFile(const CSSFileName: string);
var
  aItem: TWPXMLStyleSheet;
begin
  with TFileStream.Create(CSSFileName, fmOpenRead + fmShareDenyNone) do
  begin
    aItem := TWPXMLStyleSheet(Add);
    aItem.FURL := CSSFileName;
    SetLength(aItem.FSheet, Size);
    if Size > 0 then Read(aItem.FSheet[1], Size);
  end;
end;

// *****************************************************************************
// *****************************************************************************
// *****************************************************************************

constructor TWPCustomXMLInterface.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FWorkList := TStringList.Create;
  FXMLStyleSheet := TWPXMLStyleSheetCollection.Create;
  FXMLStyleSheet.FOwner := Self;
  FData := TMemoryStream.Create;
  FDataSize := 0;
  FStack := nil;
  FUseOnlyXMLEntities := TRUE;
  FEncoding := 'windows-1250';
  FXMLInterfaceData := TWPXMLInterfaceData.Create;
  FXMLInterfaceData.Owner := Self;
end;

destructor TWPCustomXMLInterface.Destroy;
begin
  if FStack <> nil then Pop(CLOSE_ALLTAGS);
  FData.Free;
  FWorkList.Free;
  FXMLInterfaceData.Free;
  FXMLStyleSheet.Free;
  inherited Destroy;
end;

function TWPCustomXMLInterface.GetStyleSheets: TWPXMLStyleSheetCollection;
begin
  Result := FXMLStyleSheet;
end;

procedure TWPCustomXMLInterface.SetStyleSheets(x: TWPXMLStyleSheetCollection);
begin
  FXMLStyleSheet.Assign(x);
end;

procedure TWPCustomXMLInterface.Clear;
begin
  FXMLStyleSheet.Clear;
  FEncoding := 'windows-1250';
end;

procedure TWPCustomXMLInterface.SetDataSize(x: Integer);
begin
  if FStack <> nil then
    raise Exception.Create('Stack currently in use!')
  else if x >= 0 then
    FDataSize := x;
end;

procedure TWPCustomXMLInterface.DoReadTag(const TagName: string; var Params: TStringList; IsClosed: Boolean);
begin
  if assigned(FOnStartTag) then
    FOnStartTag(Self, TagName, Params, IsClosed);
end;

procedure TWPCustomXMLInterface.DoReadTagEnd(const TagName: string);
begin
  if assigned(FOnEndTag) then
    FOnEndTag(Self, TagName);
end;

procedure TWPCustomXMLInterface.InternReadTag(s: string);
var
  IsClosed, ok: Boolean;
  t: string;
  j: Integer;
  params: TStringList;
begin
  IsClosed := FALSE;
  params := nil;
  if s <> '' then
  try
    if s[1] = WPXMLPathDelimiter then
    begin
      Delete(s, 1, 1);
      if not TestStack(s) then
        DoError(wpxmlErrCloseTagIgnored)
      else
      begin
        ok := FALSE;
        while not ok and (FStack <> nil) do
        begin
          t := FStack.Tag;
          ok := CompareText(FStack.Tag, s) = 0;
          if not ok then DoError(wpxmlErrMissingCloseTags);
          Pop('');
          DoReadTagEnd(t);
        end;
      end;
    end
    else
    begin
      if s[Length(s)] = WPXMLPathDelimiter then
      begin
        IsClosed := TRUE;
        Delete(s, Length(s), 1);
      end;
      // Which is the 'tag'
      j := 1;
      while j <= Length(s) do
      begin
        if s[j] <= #32 then break; //V4.11f
        inc(j);
      end;
      //WAS: j := Pos(#32, s);
      if (j > 0) and (j <= Length(s)) then
      begin
        t := Trim(Copy(s, 1, j - 1));
        // Read the parameters from the params list
        params := StrToParams(Copy(s, j + 1, Length(s)));
      end
      else
        t := s;
      // in HTML mode some tags are accepted to be 'closed'
      if not IsClosed and FHTMLMode then
        for j := 1 to HTML_CLOSETAGS_COUNT do
          if CompareText(t, HTML_CLOSETAGS[j]) = 0 then
          begin
            IsClosed := TRUE;
            break;
          end;
      if (CompareText(t, '?xml') = 0) then
      begin
        if params.Values['encoding'] <> '' then
          FEncoding := params.Values['encoding'];
        exit;
      end
      else if (CompareText(t, '?xml-stylesheet') = 0) then
      begin
        if params.Values['href'] <> '' then
        begin
          with TWPXMLStyleSheet(FXMLStyleSheet.Add) do
          begin
            FURL := params.Values['href'];
            FMode := wpcssSaveAsLink;
          end;
        end;
        exit;
      end;
      // to exectute the event
      if not IsClosed then Push(t);
      DoReadTag(t, params, IsClosed);
    end;
  finally
    if params <> nil then params.Free;
  end;
end;

procedure TWPCustomXMLInterface.DoReadComment(const s: string);
begin
  if assigned(FOnComment) then
    FOnComment(Self, s);
end;

procedure TWPCustomXMLInterface.DoReadText(const s: string);
begin
  if assigned(FOnText) then
    FOnText(Self, s);
end;

procedure TWPCustomXMLInterface.DoError(Error: TWPXMLError);
begin
  if assigned(FOnError) then
    FOnError(Self, Error, FPosInData);
end;

procedure TWPCustomXMLInterface.DoLoaded;
begin
  if assigned(FOnLoaded) then
    FOnLoaded(Self);
end;

// Creates a new copy on the stack
var
  UniqueID: Integer;

procedure TWPCustomXMLInterface.Push(const Tag: string);
var
  p: TWPXMLInterfaceStack;
  i: Integer;
begin
  p := TWPXMLInterfaceStack.Create;
  inc(UniqueID);
  p.ID := UniqueID;
  if FDataSize > 0 then
  begin
    SetLength(p.Data, FDataSize);
    if FStack <> nil then
      for i := 0 to FDataSize - 1 do
        p.Data[i] := FStack.Data[i];
  end;
  p.Next := FStack;
  p.Tag := Tag;
  if FStack <> nil then p.obj := FStack.obj;
  FStack := p;
end;

function TWPCustomXMLInterface.GetDepth: Integer;
var
  p: TWPXMLInterfaceStack;
begin
  Result := 0;
  p := FStack;
  while p <> nil do
  begin
    p := p.next;
    inc(Result);
  end;
end;

// Deletes the complete stack with CLOSE_ALLTAGS = '$ALL$'

function TWPCustomXMLInterface.TestStack(const Tag: string): Boolean;
var
  p: TWPXMLInterfaceStack;
begin
  if (Tag <> '') and (Tag <> CLOSE_ALLTAGS) then
  begin
    p := FStack;
    Result := FALSE;
    while (p <> nil) and (CompareText(P.Tag, Tag) <> 0) do
      p := p.Next;
    if p = nil then // This tag does not exist on the stack
      exit;
  end;
  Result := TRUE;
end;


procedure TWPCustomXMLInterface.Pop(const Tag: string);
var
  p: TWPXMLInterfaceStack;
  ok: Boolean;
begin
  ok := FALSE;
  if not TestStack(Tag) then exit;
  while not ok and (FStack <> nil) do
  begin
    ok := (Tag = '') or (CompareText(FStack.Tag, Tag) = 0);
    p := FStack.Next;
    if FStack.Data <> nil then
    begin
      DestroyData(FStack);
      FStack.Data := nil;
    end;
    FStack.Tag := '';
    FStack.Free;
    FStack := p;
  end;
end;

procedure TWPCustomXMLInterface.DestroyData(data: TWPXMLInterfaceStack);
begin
end;

procedure TWPCustomXMLInterface.DoWriteStart;
var
  i: Integer;
begin
  if not FNoXMLHeader then
  begin
    if not FHTMLMode then
    begin
      if FEncoding = '' then
        WriteNative('<?xml version="1.0"?>' + #13 + #10)
      else
        WriteNative('<?xml version="1.0" encoding="' + FEncoding + '"?>' + #13 + #10);
      // Save XML Stylesheets
      for i := 0 to FXMLStyleSheet.Count - 1 do
        if FXMLStyleSheet.Items[i].Mode <> wpcssIgnore then
        begin
          if FXMLStyleSheet.Items[i].URL <> '' then
            WriteNative('<?xml-stylesheet type="text/css" href="' + FXMLStyleSheet.Items[i].URL + '"?>' + #13 + #10)
          else
            DoError(wpxmlStyleSheetHasNoURL);
        end;
    end
    else
    begin
      // Save HTML Stylesheets
      // WriteStylesheets;
    end;
  end;
  if assigned(FOnWriteTextStart) then FOnWriteTextStart(Self);
end;

procedure TWPCustomXMLInterface.WriteStylesheets;
var
  i: Integer; media: string;
begin
  for i := 0 to FXMLStyleSheet.Count - 1 do
  begin
    if FXMLStyleSheet.Items[i].Media <> '' then
      media := ' media="' + FXMLStyleSheet.Items[i].Media + '"'
    else
      media := '';
    if FXMLStyleSheet.Items[i].Mode = wpcssSaveAsLink then
    begin
      if FXMLStyleSheet.Items[i].URL <> '' then
        WriteNative('<link rel="stylesheet" type="text/css" ' + media + ' href="' + FXMLStyleSheet.Items[i].URL + '">' + #13 + #10)
      else
        DoError(wpxmlStyleSheetHasNoURL);
    end
    else if (FXMLStyleSheet.Items[i].Mode = wpcssEmbedInHTML) and
      (FXMLStyleSheet.Items[i].Sheet <> '') then
    begin
      WriteNative('<style type="text/css"' + media + '><!--' + #13 + #10);
      WriteNative(FXMLStyleSheet.Items[i].Sheet);
      WriteNative('--></style>' + #13 + #10);
    end;
  end;
end;


procedure TWPCustomXMLInterface.DoWriteEnd;
begin
  if assigned(FOnWriteTextEnd) then FOnWriteTextEnd(Self);
end;

(* was:
function TWPCustomXMLInterface.GetStack: Pointer;
begin
  if FStack <> nil then
    Result := FStack^.Data
  else
    Result := nil;
end;
*)

function TWPCustomXMLInterface.GetStack: Pointer;
begin
  if (FStack <> nil) and (FStack.Data <> nil) then
    Result := @(FStack.Data[0])
  else
    Result := nil;
end;

function TWPCustomXMLInterface.GetObjectStack: TObject;
begin
  if FStack <> nil then
    Result := FStack.Obj
  else
    Result := nil;
end;


procedure TWPCustomXMLInterface.SetObjectStack(x: TObject);
begin
  if FStack <> nil then FStack.Obj := x;
end;


function TWPCustomXMLInterface.GetXMLData: TWPXMLInterfaceData;
begin
  Result := FXMLInterfaceData;
end;

procedure TWPCustomXMLInterface.SetXMLData(x: TWPXMLInterfaceData);
begin
  FXMLInterfaceData.Assign(x);
end;

function TWPCustomXMLInterface.GetAsString: string;
begin
  SaveToStream(nil);
  SetString(Result, PChar(FData.Memory), FData.Size);
  FData.Clear;
end;

procedure TWPCustomXMLInterface.SetAsString(const x: string);
begin
  FData.Clear;
  if x <> '' then
    FData.Write(x[1], Length(x));
  LoadFromStream(nil);
end;

// Loading is done through 4 events
{$IFDEF WPDEMO}
var
  DemoCount: Integer;
{$ENDIF}

procedure TWPCustomXMLInterface.LoadFromStream(Stream: TStream);
var
  l: Integer;
begin
  if FStack <> nil then Pop(CLOSE_ALLTAGS);
  if Stream <> nil then
  begin
    FData.Clear;
    l := Stream.Size - Stream.Position;
    if l > 0 then
    begin
      FData.SetSize(l);
      Stream.Read(PChar(FData.Memory)^, l);
      // FData.CopyFrom(Stream, Stream.Size);  //StreamRead error ?
    end;
  end;

{$IFDEF WPDEMO}
  inc(DemoCount);
  if (DemoCount < 0) or (DemoCount = 10) or (DemoCount > 50) then
  begin
    DemoCount := 10;
    ShowMessage('This is the demo of TWPCustomXMLInterface' + #13
      + 'You can order the full version at www.wptools.de');
  end;
{$ENDIF}

  // First decrypt
{$IFDEF USELANINTERFACE}
  if (FPassword <> '') and assigned(WPEncryptData) then
    WPEncryptData(PChar(FData.Memory), FData.Size, FPassword);


  // then decompress
  if FCompress and assigned(WPCompressData) then
  begin
    temp := nil;
    if WPCompressData(PChar(FData.Memory), FData.Size, nil, l, true) then
    try
      temp := TMemoryStream.Create;
      temp.SetSize(l);
      WPCompressData(PChar(FData.Memory), FData.Size, PChar(temp.Memory), l, true);
      FData := temp;
    except
      temp.Free;
    end;
  end;
{$ENDIF}
  // then translate
  try
    ReadLoop;
  finally
    DoLoaded;
  end;
end;

procedure TWPCustomXMLInterface.LoadFromFile(const Filename: string);
var
  FFile: TFileStream;
begin
  FFile := TFileStream.Create(Filename, fmOpenRead + fmShareDenyNone);
  try
    LoadFromStream(FFile);
  finally
    FFile.Free;
  end;
end;

// Also replaces controll codes
// if property UTF8 = true the resulting string can be UTF8

procedure TWPCustomXMLInterface.ReplaceEntities(var s: string; OnlyXML: Boolean);
var
  pp1, pp2, oldpp1: Integer;
  l2, l, ii, ch: Integer;
  cc: Char;
  ss1: string;
{$IFDEF DELPHI6ANDUP}
  mlen, pss1: Integer;
{$ENDIF}
begin
  ss1 := '';
{$IFDEF DELPHI6ANDUP}
  FHasUTF8 := FALSE;
{$ENDIF}
  if (s <> '') then
  begin
    l := Length(s);
    pp1 := 1;
    pp2 := pp1;
    l2 := 0;
    repeat
      cc := s[pp1];
      inc(pp1);
{$IFDEF DELPHI6ANDUP}
      ch := 0;
      mlen := 1;
{$ENDIF}
      if cc = #0 then break
      else if cc < #32 then continue
      else if cc = '&' then
      begin
        ss1 := '';
        oldpp1 := pp1;
        while (pp1 <= l) and (s[pp1] > #32) and (s[pp1] <> ';') do
        begin
          ss1 := ss1 + s[pp1];
{$IFDEF DELPHI6ANDUP}
          inc(mlen); // only used for UTF8 support!
{$ENDIF}
          inc(pp1);
        end;
        if (pp1 <= l) and (s[pp1] <> ';') then
        begin
          cc := '&'; //V4.20a'
          pp1 := oldpp1;
        end
        else
        begin
          inc(pp1);
          cc := '?';

          if (ss1 <> '') and (ss1[1] = '#') then
          begin
            ch := StrToIntDef(Copy(ss1, 2, 10), Integer('?'));
            cc := Char(ch and 255);
          end
          else
            for ii := 1 to maxwpspch do
              if StrComp(wpspch[ii].p, PChar(ss1)) = 0 then
              begin
                cc := wpspch[ii].c;
                break;
              end;
          if (pp1 <= l) and (s[pp1] = ';') then inc(pp1);
        end; //V4.20a
      end;

{$IFDEF DELPHI6ANDUP}
      if ch > 255 then // UNICODE!!!!  - NEED UTF8
      begin
        if not FUTF8 then
        begin
          s[pp2] := '?';
          inc(pp2);
          inc(l2);
        end else
        begin
           // Asumption: The UTF char sequence is always smaller than the entity 'mlen'
          ss1 := UTF8Encode(WideChar(ch));
          if Length(ss1) < mlen then
          begin
            mlen := Length(ss1);
            pss1 := 1;
            while mlen > 0 do
            begin
              s[pp2] := ss1[pss1];
              inc(pp2);
              inc(pss1);
              dec(mlen);
              inc(l2);
            end;
            FHasUTF8 := TRUE;
          end else
          begin
            s[pp2] := '?';
            inc(pp2);
            inc(l2);
          end;
        end;
      end else
{$ENDIF}
      begin
        s[pp2] := cc;
        inc(pp2);
        inc(l2);
      end;
    until (pp1 > l) or (s[pp1] = #0);
    if l2 <> l then
      SetLength(s, l2);
  end;
end;

procedure TWPCustomXMLInterface.ReadLoop;
var
  i, m, l: Integer;
  start, p, p2: Integer;
  c: Char;
  buffer: array of AnsiChar;
  function SetString(aPos, aLen: Integer): string;
  var ii: Integer;
  begin
    SetLength(Result, aLen);
    for ii := 0 to aLen - 1 do
      Result[ii + 1] := buffer[aPos + ii];
  end;
  procedure Finish;
  var
    s: string;
  begin
    if l > 0 then
    begin
      FPosInData := Start;
      case m of
        0: // Standard Text
          if l > 0 then
          begin
            s := SetString(start, l);
            ReplaceEntities(s, false);
            DoReadText(s);
            // ShowMessage('"'+s+'"');
          end;
        1: // Tag
          begin
            s := SetString(start, l);
            InternReadTag(s);
            // ShowMessage('TAG:"' +s + '"');
          end;
        2: // Comment
          begin
            s := SetString(start, l);
            DoReadComment(s);
            // ShowMessage('COMMENT:' +s);
          end;
      end;
    end;
    l := 0;
    start := p;
    m := 0;
  end;
begin
  // Make sure the buffer ends with #0
  FData.Position := FData.Size;
  i := 0;
  FData.Write(i, SizeOf(i));
  // Now start ...
  SetLength(buffer, FData.Size);
  FData.Position := 0;
  FData.Read(buffer[0], FData.Size);
  try
    p := 0;
    start := p;
    l := 0;
    c := #0;
    m := 0; // 0=text, 1=tag 2=comment

    while buffer[p] <> #0 do
    begin
      if (buffer[p] = '<') and (m = 0) then // expect '<' only in regular text, not comments or tags!
      begin
        Finish;
        inc(p);
        if buffer[p] = '!' then // Skip the start of the comment
        begin
          m := 2;
          inc(p);
          if ((buffer[p] = 'd') or (buffer[p] = 'D')) and
            (StrLIComp(@buffer[p], 'DOCTYPE', 7) = 0) then
          begin
           // read this tag
            dec(p);
            m := 1;
            start := p;
            c := #0;
          end else
          begin
            while buffer[p] = '-' do
              inc(p);
            c := '-';
            start := p;
          end;
        end
        else // tag
        begin
          m := 1;
          start := p;
          c := #0;
        end;
        continue;
      end
      else if buffer[p] = '>' then
      begin
        if (m = 2) and (c = '-') then // '->' in comment
        begin
          p2 := p - 1;
          while (l > 0) and ((buffer[p2] = '-') or (buffer[p2] <= #32)) do // remove '-' and spc at the end!
          begin
            dec(p2); dec(l);
          end; // Note: we must hit a '!' sometimes !
          while (buffer[start] <= #32) and (buffer[start] <> #0) do // Skip Whitespace at the start !
          begin
            dec(l); inc(start);
          end;
          Finish;
          inc(p);
          start := p;
        end
        else if m = 1 then // > in tag
        begin
          Finish;
          inc(p);
          start := p;
        end
        else // > in text. Use as '>'
        begin
          c := buffer[p];
          inc(p);
          inc(l);
        end;
      end
      else
      begin
        c := buffer[p];
        inc(p); // Regular Text
        inc(l);
      end;
    end;
    Finish;
  // We need to close all open tags
    if FStack <> nil then
    begin
      FPosInData := FData.Size;
      DoError(wpxmlUnexpectedEndOfFile);
      while FStack <> nil do
        InternReadTag(WPXMLPathDelimiter + FStack.Tag);
    end;

  finally
    buffer := nil;
  end;
end;

// Saving is done by

procedure TWPCustomXMLInterface.SaveToFile(const Filename: string);
var
  FOutStream: TFileStream;
begin
  FOutStream := nil;
  try
    SaveToStream(nil);
    // We don't create a new file unless we have sucessfully created new data !
    FOutStream := TFileStream.Create(Filename, fmCreate);
    FData.SaveToStream(FOutStream);
  finally
    FOutStream.Free;
    FData.Clear;
  end;
end;

procedure TWPCustomXMLInterface.SaveToStream(Stream: TStream);
{$IFDEF USELANINTERFACE}
var
  l: Integer;
  temp: TMemoryStream;
{$ENDIF}
begin
  FData.Clear;
  try
    DoWriteStart;
    CloseTag(CLOSE_ALLTAGS);
    DoWriteEnd;
{$IFDEF USELANINTERFACE}
    // First Compress
    if FCompress and assigned(WPCompressData) then
    begin
      temp := TMemoryStream.Create;
      l := Round((FData.Size + 2) * 1.2);
      if WPCompressData(PChar(FData.Memory), FData.Size, PChar(FData.Memory), l, false) then
      try
        temp.SetSize(l);
        FData := temp;
      except
        temp.Free;
      end;
    end;
    // Then Encrypt
    if (FPassword <> '') and assigned(WPEncryptData) then
      WPEncryptData(PChar(FData.Memory), FData.Size, FPassword);
{$ENDIF}
    // Now save to stream or later to file
    if Stream <> nil then
      FData.SaveToStream(Stream);
  finally
    if Stream <> nil then FData.Clear;
  end;
end;

procedure TWPCustomXMLInterface.WriteNative(const s: string);
begin
  if s <> '' then FData.Write(s[1], Length(s));
end;

procedure TWPCustomXMLInterface.Write(const s: string);
var
  start, p, len: Integer;
  l: Integer;
  t: string;
  c: Char;
begin
  t := '';
  if s <> '' then
  begin
    len := Length(s);
    start := 1;
    p := Start;
    l := 0;
    if FUseOnlyXMLEntities then
      while (p <= len) and (s[p] <> #0) do
      begin
        c := s[p];
        // the 5 predefined XML entities
        if (c = '<') or (c = '>') or
          (c = '&') or (not HTMLMode and ({(c = #39) or}(c = '"'))) then
        begin
          if l > 0 then FData.Write(s[start], l);
          t := '&' + StrPas(inwpspch[c]) + ';';
          FData.Write(t[1], Length(t));
          inc(p);
          start := p;
          l := 0;
        end
        else
        begin
          inc(p);
          inc(l);
        end;
      end
    else
      while (p <= len) and (s[p] <> #0) do
      begin
        c := s[p];
        if inwpspch[c] <> nil then
        begin
          if l > 0 then FData.Write(s[start], l);
          t := '&' + StrPas(inwpspch[c]) + ';';
          FData.Write(t[1], Length(t));
          inc(p);
          start := p;
          l := 0;
        end
        else
        begin
          inc(p);
          inc(l);
        end;
      end;
    if l > 0 then FData.Write(s[start], l);
  end;
end;

procedure TWPCustomXMLInterface.Writeln(const s: string);
const
  nl: string = #13 + #10;
begin
  if s <> '' then Write(S);
  FData.Write(nl[1], 2);
end;

function TWPCustomXMLInterface.ParamsToStr(const params: TStringList): string;
var
  p, s: string; i, j: Integer;
  p1, len: Integer;
  c: Char;
begin
  Result := '';
  if params <> nil then
    for i := 0 to params.Count - 1 do
    begin
      p := params[i];
      if (p <> '') then
      begin
        j := Pos('=', p);
        if j > 0 then
        begin
          s := Copy(p, j + 1, Length(p));
          p := Copy(p, 1, j) + '"';
          // Encoding - not necessary the fastest implementation but handles entities and "
          if s <> '' then
          begin
            if s[1] = '"' then Delete(s, 1, 1);
            if s[Length(s)] = '"' then Delete(s, Length(s), 1);
            len := Length(s);
            p1 := 1;
            while (p1 <= len) and (s[p1] <> #0) do
            begin
              c := s[p1];
              if (c = '<') or (c = '>') or
                (c = '&') or {(c = #39) or}(c = '"') then
                p := p + '&' + StrPas(inwpspch[c]) + ';'
              else
                p := p + c;
              inc(p1);
            end;
          end;
          p := p + '"';
        end;
        Result := Result + #32 + p;
      end;
    end;
end;

function TWPCustomXMLInterface.StrToParams(const Input: string): TStringList;
var
  start, p, len: Integer;
  l: Integer;
  hk_char: Char; hk: Boolean;
  function SetString(aPos, aLen: Integer): string;
  var ii: Integer;
  begin
    SetLength(Result, aLen);
    for ii := 0 to aLen - 1 do
      Result[ii + 1] := Input[aPos + ii];
  end;
  procedure AddIt;
  var
    n, par: string;
  begin
    par := '';
    n := '';
    if l > 0 then
    begin
      while (start <= len) and (Input[start] <> #0) and (Input[start] <= #32) do
      begin
        inc(start);
        dec(l);
      end;
      if l > 0 then
      begin
        par := SetString(start, l);
        l := Pos('=', par);
        if l > 0 then
        begin
          n := Copy(par, 1, l - 1);
          par := Copy(par, l + 1, Length(par));
          if (par = '""') or (par = #39 + #39) then
            par := ''
          else if (par <> '') and (par <> '''''') then
          begin
            if par[1] = '"' then Delete(par, 1, 1);
            if (par <> '') and (par[Length(par)] = '"') then Delete(par, Length(par), 1);
            if pos('&', par) > 0 then ReplaceEntities(par, true);
          end;
          if par <> '' then Result.Add(n + '=' + par);
        end;
      end;
    end;
    l := 0;
  end;
begin
  if Input = '' then
    Result := nil
  else
  begin
    Result := TStringList.Create;
    start := 1;
    len := Length(Input);

    // Find first " or ' char and set hk_char accordingly
    hk_char := '"';
    p := start;
    while (p <= len) and (Input[p] <> #0) do
    begin
      if Input[p] = '"' then break
      else if Input[p] = #39 then
      begin
        hk_char := #39;
        break;
      end;
      inc(p);
    end;

    // Read the üarams
    p := start;
    l := 0;
    hk := FALSE;

    while (p <= len) and (Input[p] <> #0) do
    begin
      if Input[p] = hk_char then
      begin
        hk := not hk;
        // After a " a space is not required
        if not hk then
        begin
          inc(p);
          inc(l);
          AddIt;
          continue;
        end;
      end
      else if not hk and (Input[p] = #32) then
      begin
        AddIt;
        start := p;
      end;
      inc(p);
      inc(l);
    end;
    AddIt;
  end;
end;

// Writes a tag with a list of params. Expects the syntax name=value for the params. Adds " to the parameter

procedure TWPCustomXMLInterface.WriteTag(const Tag: string; const params: TStringList); // Writes a closed tag
var
  s: string;
  p: TWPXMLInterfaceStack;
begin
  s := '<' + Tag + ParamsToStr(params) + '/>';
  FData.Write(s[1], Length(s));
  if FWriteIndentedLayout then
  begin
    WriteNative(#13#10);
    p := FStack;
    while p <> nil do
    begin
      WriteNative(#32);
      p := p.Next;
    end;
  end;
end;

// Writes a tag ands an entry to the stack

function TWPCustomXMLInterface.OpenTag(const Tag: string; const params: TStringList): Integer; // Starts a tag
var
  s: string;
begin
  Push(Tag);
  Result := FStack.ID;
  s := '<' + Tag + ParamsToStr(params) + '>';
  FData.Write(s[1], Length(s));
end;

function TWPCustomXMLInterface.MakeStyleParam(s: string): TStringList;
var
  p, len: Integer;
begin
  FWorkList.Clear;
  if s <> '' then
  begin
    len := Length(s);
    p := 1;
    while (p <= len) and (s[p] <> #0) do
    begin
      if s[p] = '"' then s[p] := '''';
      inc(p);
    end;
    FWorkList.Add('style="' + s + '"');
  end;
  Result := FWorkList;
end;

// Writes the tags and also gets the tags from the stack

procedure TWPCustomXMLInterface.CloseTag(const Tag: string); // Closes all tags until it finds the named tag, '' closes the last tag
var
  pp, p: TWPXMLInterfaceStack;
  ok: Boolean;
  s: string;
begin
  ok := FALSE;
  if not TestStack(Tag) then
    raise Exception.Create('Tag "' + Tag + '" has not be written!');
  while not ok and (FStack <> nil) do
  begin
    ok := (Tag = '') or (CompareText(FStack.Tag, Tag) = 0);
    p := FStack.Next;
    FStack.Next := nil; // Makes it easier to find illegal access to this memory
    if FStack.Data <> nil then
    begin
      if FStack.Data <> nil then DestroyData(FStack);
      FStack.Data := nil;
    end;
    s := '</' + FStack.Tag + '>';
    FStack.Tag := '';
    FStack.Free;
    FStack := p;
    FData.Write(s[1], Length(s));

    if FWriteIndentedLayout then
    begin
      WriteNative(#13#10);
      pp := FStack;
      while (pp <> nil) and (pp.Next <> nil) do // Closing, one #32 less
      begin
        WriteNative(#32);
        pp := pp.Next;
      end;
    end;
  end;
end;

function TWPCustomXMLInterface.CurrentTag: string;
begin
  if FStack = nil then
    Result := ''
  else
    Result := FStack.Tag;
end;

procedure TWPCustomXMLInterface.CloseTagID(ID: Integer);
var
  p: TWPXMLInterfaceStack;
  ok: Boolean;
  s: string;
begin
  p := FStack;
  while (p <> nil) and (P.ID <> ID) do
    p := p.Next;
  if p = nil then exit;
  ok := FALSE;
  while not ok and (FStack <> nil) do
  begin
    ok := FStack.ID = ID;
    p := FStack.Next;
    FStack.Next := nil; // Makes it easier to find illegal access to this memory
    if FStack.Data <> nil then
    begin
      DestroyData(FStack);
      FStack.Data := nil;
    end;
    s := '</' + FStack.Tag + '>';
    FStack.Tag := '';
    FStack.Free;
    FStack := p;
    FData.Write(s[1], Length(s));
  end;
end;

procedure TWPCustomXMLInterface.CloseAllTags;
begin
  CloseTag(CLOSE_ALLTAGS);
end;

// -----------------------------------------------------------------------------
// An universal class to read and manage XML elements
// -----------------------------------------------------------------------------

procedure TWPXMLOneLevel.SetName(const x: string);
begin
  FName := x;
  FLowercaseName := lowercase(x);
  FNameLen := Length(x);
  FIsText := (FNameLen = 0);
end;

procedure TWPXMLOneLevel.SetPath(const x: string);
var
  new: TWPXMLOneLevel;
begin
  new := FParent.Find(x);
  if new = nil then
    new := FParent.Tree.AddTagValue(x, '');
  SetParent(new);
end;

function TWPXMLOneLevel.GetAnyData: TObject;
begin
  Result := FAnyData;
end;

procedure TWPXMLOneLevel.SetAnyData(x: TObject);
begin
  if FAnyData <> x then
  begin
    if FAnyData <> nil then FAnyData.Free;
    FAnyData := x;
  end;
end;

procedure TWPXMLOneLevel.SetParent(x: TWPXMLOneLevel);
var
  i: Integer;
  FOldOwner: TWPXMLOneLevel;
begin
  if x <> nil then
  begin
    FOldOwner := FOwner;
    i := FOwner.IndexOf(Self);
    if i >= 0 then FOwner.Delete(i);
    FOwner := nil;
    try
      x.Add(Self);
      FOwner := x;
    except // not allowed ?
      FOldOwner.Add(Self);
      FOwner := FOldOwner;
      raise;
    end;
  end;
end;

function TWPXMLOneLevel.GetPath: string;
var
  p: TWPXMLOneLevel;
begin
  Result := '';
  p := FOwner;
  while p <> nil do
  begin
    Result := p.Name + '/' + Result;
    p := p.FOwner;
  end;
end;

function TWPXMLOneLevel.GetSubElement(index: Integer): TWPXMLOneLevel;
begin
  assert(index < Count, 'index in TWPXMLOneLevel');
  Result := TWPXMLOneLevel(Items[index]);
end;

function TWPXMLOneLevel.GetParams: TStringList;
begin
  if FParams = nil then FParams := TStringList.Create;
  Result := FParams;
end;

function TWPXMLOneLevel.GetParamCount: Integer;
begin
  if FParams = nil then
    Result := 0
  else
    Result := FParams.Count;
end;

procedure TWPXMLOneLevel.SetParams(x: TStringList);
begin
  if FParams = nil then FParams := TStringList.Create;
  FParams.Assign(x);
end;

{$IFNDEF NODELPHI5} // No Delphi 3

procedure TWPXMLOneLevel.Notify(Ptr: Pointer; Action: TListNotification);
var
  i: Integer;
begin
  if PTR <> nil then
  begin
    if Action = lnDeleted then
    begin
      // NO!!!! TWPXMLOneLevel(PTR).Free;
    end
    else if Action = lnAdded then
    begin
      TWPXMLOneLevel(PTR).FOwner := Self;
      TWPXMLOneLevel(PTR).FParent := FParent;
      if (FParent <> nil) and (FOwner = nil) and FParent.FDontAllowMultTagsOnFirstLevel
        and (Count > 1) then
      begin
        i := IndexOf(Ptr);
        Delete(i);
        raise EWPXMLMultipleEntriesOnFirstLevelError.Create('On first XML level only one element is allowed!');
      end;
    end;
  end;
end;

{$ELSE} // Only Delphi 3

function TWPXMLOneLevel.Add(Item: Pointer): Integer;
var
  i: Integer;
begin
  Result := inherited Add(Item);
  TWPXMLOneLevel(Item).FOwner := Self;
  TWPXMLOneLevel(Item).FParent := FParent;
  if (FParent <> nil) and (FOwner = nil) and FParent.FDontAllowMultTagsOnFirstLevel
    and (Count > 1) then
  begin
    i := IndexOf(Item);
    Delete(i);
    raise EWPXMLMultipleEntriesOnFirstLevelError.Create('On first XML level only one element is allowed!');
  end;
end;
{$ENDIF}

constructor TWPXMLOneLevel.Create(aOwner: TWPCustomXMLTree);
begin
  inherited Create;
  FParent := aOwner;
  AnyData := nil;
end;

destructor TWPXMLOneLevel.Destroy;
var
  i: Integer;
begin
  // Free any attached data
  AnyData := nil;
  //NO - inherited does this Clear;
  if FOwner <> nil then
  begin
    i := FOwner.IndexOf(Self);
    if i >= 0 then FOwner.Delete(i);
    FOwner := nil;
  end;
  if FParent.FFirst = Self then
    FParent.FFirst := nil;
  inherited Destroy;
end;

procedure TWPXMLOneLevel.Clear;
var
  i: Integer;
begin
  FParent.FModified := TRUE;
  for i := 0 to Count - 1 do
  begin
    TWPXMLOneLevel(Items[i]).FOwner := nil;
    TWPXMLOneLevel(Items[i]).Free;
    Items[i] := nil;
  end;
  FName := '';
  FContent := '';
  FLowercaseName := '';
  FName := '';
  FIsClosed := FALSE;
  FIsText := FALSE;
  if FParams <> nil then
  begin
    FParams.Free;
    FParams := nil;
  end;
  inherited Clear;
end;

function TWPXMLOneLevel.Depth: Integer;
var
  p: TWPXMLOneLevel;
begin
  Result := 0;
  p := Parent;
  while p <> nil do
  begin
    inc(Result);
    p := p.Parent;
  end;
end;

function TWPXMLOneLevel.GetEValue(const TagName: string; DefValue: Integer): Integer;
var p: TWPXMLOneLevel;
begin
  if TagName='' then p := Self else p := Find(TagName);
  if p = nil then Result := DefValue else
  begin
    if p.HasParam('value') then Result := p.ParamValueDef('value',DefValue)
    else Result := StrToIntDef(p.Content, DefValue);
  end;
end;

function TWPXMLOneLevel.GetSValue(const TagName: string): String;
var p: TWPXMLOneLevel;
begin
  if TagName='' then p := Self else p := Find(TagName);
  if p = nil then Result := '' else
  begin
    if p.HasParam('value') then Result := p.ParamValue['value']
    else Result := p.Content;
  end;
end;

function TWPXMLOneLevel.HasElement(const TagName: string): Boolean;
var p: TWPXMLOneLevel;
begin
  p := Find(TagName);
  Result := p <> nil;
end;

// Find name in this level

function TWPXMLOneLevel.Find(const TagName: string): TWPXMLOneLevel;
var
  s: string; i, l: Integer;
begin
  s := Lowercase(TagName);
  l := Length(s);
  for i := 0 to Count - 1 do
  begin
    Result := TWPXMLOneLevel(Items[i]);
    // Fast compare, first check length then check the string
    if not (Result.FIsText) and (Result.FNameLen = l) and (Result.FLowercaseName = s) then exit;
  end;
  Result := nil;
end;

// Find any tag in this tag (but not itself!)

function TWPXMLOneLevel.FindRecursive(const TagName: string): TWPXMLOneLevel;
var
  s: string;
  l: Integer;
  function FindHere(level: TWPXMLOneLevel): TWPXMLOneLevel;
  var
    i: Integer; runlevel: TWPXMLOneLevel;
  begin
    Result := nil;
    for i := 0 to level.Count - 1 do
    begin
      runlevel := TWPXMLOneLevel(level.Items[i]);
      if not runlevel.FIsText then
      begin
        if (runlevel.FNameLen = l) and (runlevel.FLowercaseName = s) then
        begin
          Result := runlevel;
          exit;
        end;
        Result := FindHere(runlevel);
        if Result <> nil then exit;
      end;
    end;
  end;
begin
  s := Lowercase(TagName);
  l := Length(s);
  Result := FindHere(Self);
end;

// Fast compare function

function TWPXMLOneLevel.NameEqual(const LowerCaseName: string): Boolean;
begin
  Result := (FNameLen = Length(LowerCaseName)) and
    (LowerCaseName = FLowercaseName);
end;

function TWPXMLOneLevel.InsideName(const LowerCaseName: string): Boolean;
var par: TWPXMLOneLevel;
begin
  Result := NameEqual(LowerCaseName);
  par := FOwner;
  while not Result and (par <> nil) do
  begin
    Result := par.NameEqual(LowerCaseName);
    par := par.FOwner;
  end;
end;

// Just as 'Find' but expects TagName to be lowercase already

function TWPXMLOneLevel.FastFind(const TagName: string): TWPXMLOneLevel;
var
  i, l: Integer;
begin
  l := Length(TagName);
  for i := 0 to Count - 1 do
  begin
    Result := TWPXMLOneLevel(Items[i]);
    if not (Result.FIsText) and (Result.FNameLen = l) and (Result.FLowercaseName = TagName) then exit;
  end;
  Result := nil;
end;

// Find a name which can contain a path. The first element until the WPXMLPathDelimiter must always match

function TWPXMLOneLevel.FindPath(const TagPathName: string): TWPXMLOneLevel;
var
  l: Integer;
  s, p: string;
  current: TWPXMLOneLevel;
begin
  current := Self;
  p := Lowercase(TagPathName);
  repeat
    l := Pos(WPXMLPathDelimiter, p);
    if l = 0 then
    begin
      s := p;
      p := '';
    end
    else
    begin
      s := Copy(p, 1, l - 1);
      p := Copy(p, l + 1, Length(p));
    end;
    if s = '' then
      Result := Current
    else
      Result := current.FastFind(s);
    if Result = nil then exit;
    current := Result;
    if (Result <> nil) and (p = '') then exit;
  until (p = '') or (current = nil);
  Result := nil;
end;

function TWPXMLOneLevel.FindText(Text: string; CaseSensitive, Recursive: Boolean; List: TList): TWPXMLOneLevel;
  function InternFind(level: TWPXMLOneLevel): TWPXMLOneLevel;
  var
    i: Integer;
  begin
    Result := nil;
    if (CaseSensitive and (Pos(Text, level.Content) > 0)) or
      (not CaseSensitive and (Pos(Text, lowercase(level.Content)) > 0)) then
      Result := level;

    if (Result = nil) and (level.FParams <> nil) and
      ((CaseSensitive and (Pos(Text, level.FParams.CommaText) > 0)) or
      (not CaseSensitive and (Pos(Text, lowercase(level.FParams.CommaText)) > 0))) then
      Result := level;

    if (Result <> nil) and (List <> nil) then
      List.Add(Result);

    if Recursive and ((Result = nil) or (List <> nil)) then
      for i := 0 to level.Count - 1 do
      begin
        Result := InternFind(level.Items[i]);
        if (Result <> nil) and (List = nil) then break;
      end;
  end;
begin
  if not CaseSensitive then Text := lowercase(Text);
  Result := InternFind(Self);
  if (List <> nil) and (List.Count > 0) then
    Result := TWPXMLOneLevel(List[0]);
end;

function TWPXMLOneLevel.AddTagValue(const TagPathName: string; const Value: string): TWPXMLOneLevel;
begin
  Result := InternAddTagValue(TagPathName, Value, TRUE);
end;

function TWPXMLOneLevel.AddTagValue(const TagPathName: string; const Value: Integer): TWPXMLOneLevel;
begin
  Result := InternAddTagValue(TagPathName, IntToStr(Value), TRUE);
end;

function TWPXMLOneLevel.AddTag(const TagPathName: string): TWPXMLOneLevel;
begin
  Result := InternAddTagValue(TagPathName, '', TRUE);
end;

function TWPXMLOneLevel.InternAddTagValue(const TagPathName: string; const Value: string; SetValue: Boolean): TWPXMLOneLevel;
var
  l: Integer;
  s, p: string;
  current: TWPXMLOneLevel;
begin
  FParent.FModified := TRUE;
  current := Self;
  p := TagPathName;
  s := '';
  repeat
    l := Pos(WPXMLPathDelimiter, p);
    if l = 0 then
    begin
      s := p;
      p := '';
    end
    else
    begin
      s := Copy(p, 1, l - 1);
      p := Copy(p, l + 1, Length(p));
    end;
    if s = '' then
      Result := Current
    else
      Result := current.Find(s);
    if Result = nil then
    begin
      // Result := TWPXMLOneLevel.Create(FParent);
      Result := FParent.FItemClass.Create(FParent);
      Result.Name := s;
      current.Add(Result);
    end;
    current := Result;
    if (Result <> nil) and (p = '') then
    begin
       Result.Content := Value;
    end;
  until (p = '') or (current = nil);
end;


function TWPXMLOneLevel.AppendTag(const Name: string): TWPXMLOneLevel;
begin
  // Result := TWPXMLOneLevel.Create(FParent);
  Result := FParent.FItemClass.Create(FParent);
  Result.Name := Name;
  Self.Add(Result);
end;

procedure TWPXMLOneLevel.SetParamValue(index: string; const Value: string);
var
  i: Integer;
begin
  FParent.FModified := TRUE;
  if FParams = nil then
  begin
    FParams := TStringList.Create;
    FParams.Add(index + '=' + Value);
  end
  else
  begin
    i := FParams.IndexOfName(index);
    if i < 0 then
      FParams.Add(index + '=' + Value)
    else
      FParams[i] := index + '=' + Value;
  end;
end;

function TWPXMLOneLevel.GetParamValue(index: string): string;
begin
  if FParams = nil then
    Result := ''
  else
    Result := FParams.Values[index];
end;

function TWPXMLOneLevel.HasParam(index: string): Boolean;
begin
  Result := (FParams <> nil) and (FParams.IndexOfName(index) >= 0);
end;

function TWPXMLOneLevel.ParamValueDef(const ParamName: string; DefValue: Integer = 0): Integer;
begin
  Result := StrToIntDef(GetParamValue(ParamName), DefValue);
end;

{$IFDEF AFLAG}

function TWPXMLOneLevel.GetInheritedParamValue(index: string): string;
var par: TWPXMLOneLevel;
begin
  Result := GetParamValue(index);
  par := FOwner;
  while (Result = '') and (par <> nil) do
  begin
    Result := par.GetParamValue(index);
    par := par.FOwner;
  end;
end;

function TWPXMLOneLevel.GetSelectedInheritedParamValue(index: string; possibletags: array of string): string;
var par: TWPXMLOneLevel;
  i: Integer;
begin
  Result := GetParamValue(index);
  par := FOwner;
  while (Result = '') and (par <> nil) do
  begin
    for i := 0 to Length(possibletags) - 1 do
      if par.NameEqual(possibletags[i]) then
      begin
        Result := par.GetParamValue(index);
        possibletags[i] := '';
      end;
    par := par.FOwner;
  end;
end;
{$ENDIF}

function TWPXMLOneLevel.GetColonText: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    if not TWPXMLOneLevel(Items[i]).IsText then
    begin
      if Result <> '' then Result := Result + ';';
      Result := Result + '"' + TWPXMLOneLevel(Items[i]).Name + '"';
    end;
  end;
end;

function TWPXMLOneLevel.GetCommaText: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    if not TWPXMLOneLevel(Items[i]).IsText then
    begin
      if Result <> '' then Result := Result + ', ';
      Result := Result + TWPXMLOneLevel(Items[i]).Name;
    end;
  end;
end;

function TWPXMLOneLevel.GetAsString: string;
var
  mem: TMemoryStream;
begin
  mem := TMemoryStream.Create;
  Result := '';
  try
    SaveToStream(mem, false);
    SetString(Result, PChar(mem.Memory), mem.Size);
  finally
    mem.Free;
  end;
end;

procedure TWPXMLOneLevel.SetSelected(x: Boolean);
var
  i: Integer;
begin
  FSelected := x;
  for i := 0 to Count - 1 do
    TWPXMLOneLevel(Items[i]).Selected := x;
end;

procedure TWPXMLOneLevel.MergeParams(Source: TStrings);
var
  i, l: Integer; s: string;
begin
  if Source <> nil then
    for i := 0 to Source.Count - 1 do
    begin
      s := Source[i];
      l := Pos('=', s);
      if l > 0 then SetParamValue(Copy(s, 1, l - 1), Copy(s, l + 1, Length(s)));
    end;
end;

procedure TWPXMLOneLevel.SaveToFile(const FileName: string; WithPath: Boolean);
begin
  try
    FParent.FSaveItem := Self;
    FParent.FSaveItemParents := WithPath;
    FParent.SaveToFile(FileName);
  finally
    FParent.FSaveItem := nil;
  end;
end;

procedure TWPXMLOneLevel.SaveToStream(Stream: TStream; WithPath: Boolean);
begin
  try
    FParent.FSaveItem := Self;
    FParent.FSaveItemParents := WithPath;
    FParent.SaveToStream(Stream);
  finally
    FParent.FSaveItem := nil;
  end;
end;

// *****************************************************************************

constructor TWPCustomXMLTree.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FItemClass := TWPXMLOneLevel;
  FFirst := TWPXMLOneLevel.Create(Self);
end;

{$IFDEF AFLAG}

constructor TWPCustomXMLTree.CreateEx(aOwner: TComponent; aItemClass: TWPXMLLevelClass);
begin
  inherited Create(aOwner);
  if aItemClass = nil then
    FItemClass := TWPXMLOneLevel
  else
    FItemClass := aItemClass;
  FFirst := FItemClass.Create(Self);
end;
{$ENDIF}

function TWPCustomXMLTree.GetFirst: TWPXMLOneLevel;
begin
  if FFirst = nil then
    FFirst := FItemClass.Create(Self);
  Result := FFirst;
end;

procedure TWPCustomXMLTree.Clear;
begin
  inherited Clear;
  if FFirst <> nil then FFirst.Clear;
  FModified := FALSE;
end;

procedure TWPCustomXMLTree.Assign(Source: TPersistent);
begin
  if Source = nil then clear else
    if Source is TWPCustomXMLTree then
    begin
      AsString := TWPCustomXMLTree(Source).AsString;
      FModified := FALSE;
    end
    else inherited Assign(Source);
end;

destructor TWPCustomXMLTree.Destroy;
begin
  if FFirst <> nil then FFirst.Free;
  inherited Destroy;
end;

procedure TWPCustomXMLTree.AppendFromFile(const Filename: string);
begin
  FAppendMode := TRUE;
  try
    LoadFromFile(Filename);
  finally
    FAppendMode := FALSE;
  end;
end;

procedure TWPCustomXMLTree.AppendFromStream(Stream: TStream);
begin
  FAppendMode := TRUE;
  try
    LoadFromStream(Stream);
  finally
    FAppendMode := FALSE;
  end;
end;

procedure TWPCustomXMLTree.AppendFromString(s: string);
var str: TStringStream;
begin
  str := TStringStream.Create(s);
  FAppendMode := TRUE;
  try
    LoadFromStream(str);
  finally
    FAppendMode := FALSE;
    str.Free;
  end;
end;

procedure TWPCustomXMLTree.LoadFromString(s: string);
var str: TStringStream;
begin
  str := TStringStream.Create(s);
  try
    LoadFromStream(str);
  finally
    str.Free;
  end;
end;

function TWPCustomXMLTree.AsANSIString: string;
var str: TStringStream;
begin
  str := TStringStream.Create('');
  try
    SaveToStream(str);
    Result := str.DataString;
  finally
    str.Free;
  end;
end;

procedure TWPCustomXMLTree.ReadLoop;
begin
  FLastComment := '';
  if not FAppendMode then Clear;
  inherited ReadLoop;
end;

procedure TWPCustomXMLTree.DoReadTag(
  const TagName: string;
  var Params: TStringList;
  IsClosed: Boolean);
var
  NewItem: TWPXMLOneLevel;
begin
  if FHTMLmode and not IsClosed and (CompareText(TagName, 'STYLE') = 0) then
    FReadingStyle := TRUE;
  if FFirst = nil then
    FFirst := FItemClass.Create(Self);
  if ObjectStack = nil then
    ObjectStack := FFirst;
  if FAppendMode and not TWPXMLOneLevel(ObjectStack).FIsNew then
  begin
    NewItem := TWPXMLOneLevel(ObjectStack).Find(TagName);
{$IFDEF EMPTY_IN_APPEND}
    if NewItem <> nil then
      NewItem.FContent := '';
{$ENDIF}
  end
  else
    NewItem := nil;
  if NewItem = nil then
  begin
    NewItem := FItemClass.Create(Self);
    NewItem.Name := TagName;
    NewItem.IsClosed := IsClosed;
    NewItem.FParams := Params;
    Params := nil;
    NewItem.FIsNew := TRUE;
  end
  else
  begin
    TWPXMLOneLevel(ObjectStack).FIsNew := FALSE;
    NewItem.MergeParams(Params);
    NewItem.FIsNew := FALSE;
  end;

  if FLastComment <> '' then // COMMENT BEFORE THE ITEM !
  begin
    NewItem.FComment := NewItem.FComment + FLastComment;
    FLastComment := '';
  end;

  if NewItem.FIsNew then
  begin
    if ObjectStack = nil then
      FFirst.Add(NewItem)
    else
      TWPXMLOneLevel(ObjectStack).Add(NewItem);
  end;
  if not IsClosed then
  begin
    FCurrentItem := NewItem;
    ObjectStack := NewItem;
  end;
  inherited DoReadTag(TagName, Params, IsClosed);
end;

procedure TWPCustomXMLTree.DoReadTagEnd(const TagName: string);
begin
  if FHTMLmode and (CompareText(TagName, 'STYLE') = 0) then
    FReadingStyle := FALSE;
  FCurrentItem := TWPXMLOneLevel(ObjectStack);
  inherited DoReadTagEnd(TagName);
end;

procedure TWPCustomXMLTree.DoReadComment(const s: string);
begin
  if FReadingStyle then
    with TWPXMLStyleSheet(FXMLStyleSheet.Add) do
    begin
      FURL := '';
      FMode := wpcssEmbedInHTML;
      FSheet := s;
    end
  else // We save the comment with the next item !
  begin
    if FLastComment <> '' then
      FLastComment := FLastComment + ' -->' + #13 + #10 + ' <!-- ' + Trim(s)
    else
      FLastComment := Trim(s);
  end;
end;

procedure TWPCustomXMLTree.DoReadText(const s: string);
var
  NewItem: TWPXMLOneLevel;
begin
  // Do we accept text for this tag ?
  if FCurrentItem <> nil then
  begin
    if FCurrentItem.Count = 0 then
    begin
      FCurrentItem.FContent := FCurrentItem.FContent + s; // Comment inbetween !
{$IFDEF DELPHI6ANDUP}
      if FHasUTF8 then
        FCurrentItem.FContentIsUTF8 := TRUE;
{$ENDIF}
    end
    else if FAllowTextOutsideOfTags then // V4.23a:  and (Trim(s) <> '') then
    begin
      NewItem := FItemClass.Create(Self);
      NewItem.Name := '';
      NewItem.FIsText := TRUE;
      NewItem.FContent := s;
{$IFDEF DELPHI6ANDUP}
      if FHasUTF8 then
        NewItem.FContentIsUTF8 := TRUE;
{$ENDIF}
      FCurrentItem.Add(NewItem)
    end;
  end;
end;

procedure TWPCustomXMLTree.DoWriteStart;
  procedure WriteIt(Item: TWPXMLOneLevel);
  var
    Ignore: Boolean;
    procedure WriteContents;
    var
      j: Integer;
    begin
      if (not FWriteIndentedLayout or (Trim(Item.FContent) <> '')) and
        (Item.FContent <> '') then
      begin
        if Item.FIsCDDATA then
        begin
          WriteNative('<!CDDATA[');
          WriteNative(Item.FContent);
          WriteNative(']]>');
        end
        else
          Write(Item.FContent);
      end;
      for j := 0 to Item.Count - 1 do
        if not FSaveSelected or TWPXMLOneLevel(Item.Items[j]).FSelected then
          WriteIt(TWPXMLOneLevel(Item.Items[j]));
    end;
  var
    pp: TWPXMLInterfaceStack;
  begin
    if not FSaveSelected or Item.FSelected then
    begin
      Ignore := FALSE;
      if Item.FComment <> '' then
      begin
        WriteNative('<!-- ' + Item.FComment + '-->');
        if WriteIndented then
        begin
          WriteNative(#13#10);
          pp := FStack;
          while (pp <> nil) do
          begin
            WriteNative(#32);
            pp := pp.Next;
          end;
        end;
      end;
      if Item.FIsText then
        WriteContents
      else if FDontSaveEmptyTags and
        (Item.Count = 0) and
        (Item.Content = '') and
        ((Item.FParams = nil) or (Item.FParams.Count = 0))
        then
      begin
        Ignore := TRUE;
      end
      else if (Item.FIsClosed or FAutoCreateClosedTags) and
        (Item.Count = 0) and (Item.Content = '') then
        WriteTag(Item.Fname, Item.FParams)
      else
      try
        if Item.Fname <> '' then
        begin
          OpenTag(Item.Fname, Item.FParams);
          if FWriteIndentedLayout and (Item.Count > 0) then
          begin
            WriteNative(#13#10);
            pp := FStack;
            if (Trim(Item.Content) = '') then
            begin
              while (pp <> nil) do
              begin
                WriteNative(#32);
                pp := pp.Next;
              end;
            end;
          end;
        end;
        WriteContents;
      finally
        if Item.Fname <> '' then
        begin
          CloseTag(Item.Fname);
          if not Item.FWriteLineBreak and not WriteIndented then Writeln('');
        end;
      end;
      if Item.FWriteLineBreak and not Ignore and not WriteIndented then
      begin
        Writeln('');
      end;
    end;
  end;
  // ---------------------------------------------------------------------------
var
  lst: TList;
  p: TWPXMLOneLevel;
  i: Integer;
begin
  if FSaveItem <> nil then
    FNoXMLHeader := not FSaveItemParents
  else
    FNoXMLHeader := FALSE;
  inherited DoWriteStart;
  if FSaveItem <> nil then
  begin
    // Save the XML data starting with this Itme
    if not FSaveItemParents then
      WriteIt(FSaveItem)
    else
    begin
      // Save the tags before the selected item, then the item and then the closing tags
      lst := TList.Create;
      try
        p := FSaveItem.FOwner;
        while p <> nil do
        begin
          if p.FName <> '' then lst.Add(p);
          p := p.FOwner;
        end;
        for i := lst.Count - 1 downto 0 do
          WriteNative('<' + TWPXMLOneLevel(lst[i]).FName + '>');
        WriteIt(FSaveItem);
        for i := 0 to lst.Count - 1 do
          WriteNative('</' + TWPXMLOneLevel(lst[i]).FName + '>');
      finally
        lst.Free;
      end;
    end;
  end // else FSaveItem <> nil then
  else {// Standard save routine} if FFirst <> nil then
    WriteIt(FFirst);
end;

procedure TWPCustomXMLTree.GetList(List: TStrings);
  procedure WriteIt(const path: string; Item: TWPXMLOneLevel);
  var
    i: Integer;
  begin
    if Item.FIsText then
    begin
    end
    else
    begin
      if Item.Name <> '' then
        List.Add(path + Item.Name);
      for i := 0 to Item.Count - 1 do
        WriteIt('*' + path + Item.Name + WPXMLPathDelimiter, TWPXMLOneLevel(Item.Items[i]));
    end;
  end;
begin
  try
    List.BeginUpdate;
    if FFirst <> nil then WriteIt('', FFirst);
  finally
    List.EndUpdate;
  end;
end;

function TWPCustomXMLTree.Find(const TagPathName: string): TWPXMLOneLevel;
begin
  Result := Tree.FindPath(TagPathName);
end;

function TWPCustomXMLTree.FindParName(const TagPathName: string;
  ParamName: string): TWPXMLOneLevel;
var i: Integer;
begin
  Result := Tree.FindPath(TagPathName);
  if Result <> nil then
  begin
    for i := 0 to Result.Count - 1 do
      if CompareText(Result.Elements[i].ParamValue['Name'], ParamName) = 0 then
      begin
        Result := Result.Elements[i];
        exit;
      end;
    Result := nil;
  end;
end;

// Simplified function to retrieve a value

function TWPCustomXMLTree.ValueOf(const TagName, ParamName: string): string;
var item: TWPXMLOneLevel;
begin
  item := Tree.FindRecursive(TagName);
  if item = nil then Result := '' else
    if ParamName <> '' then
      Result := item.ParamValue[ParamName]
    else Result := item.Content;
end;

function TWPCustomXMLTree.TagByName(const TagPathName: string): TWPXMLOneLevel;
begin
  Result := Tree.FindPath(TagPathName);
  if Result = nil then
    raise
      Exception.Create('Cannot locate tag "' + TagPathName + '" in XML tree!');
end;


var
  ig: Char;
  jg: Integer;
{$IFDEF WPDEMO}
  df: TForm;
  dfl: TLabel;
{$ENDIF}

initialization
  for ig := #1 to #255 do
  begin
    for jg := 1 to maxwpspch do
      if wpspch[jg].c = ig then
        inwpspch[ig] := wpspch[jg].p;
  end;

{$IFDEF WPDEMO}
  df := TForm.Create(nil);
  df.Borderstyle := bsNone;
  dfl := TLabel.Create(df);
  dfl.Parent := df;
  df.Color := clGray;
  dfl.Caption := ' WPTools-DEMO ';
  dfl.Hint := 'Compiled with the WPTools shared components DEMO';
  dfl.ShowHint := TRUE;
  dfl.Font.Name := 'Arial';
  dfl.Font.Size := 10;
  dfl.Font.Color := clBlack;
  dfl.Left := 2;
  dfl.Color := clWhite;
  dfl.Top := 2;
  df.SetBounds(2, 2, dfl.Width + 4, dfl.Height + 4);
  df.Show;
{$ENDIF}
finalization

{$IFDEF WPDEMO}
  df.Close;
  df.Free;
{$ENDIF}

{$WARNINGS ON}
end.

