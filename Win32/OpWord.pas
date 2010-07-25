(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is TurboPower OfficePartner
 *
 * The Initial Developer of the Original Code is
 * TurboPower Software
 *
 * Portions created by the Initial Developer are Copyright (C) 2000-2002
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)
{$I OPDEFINE.INC}

{$IFDEF DCC6ORLATER}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN SYMBOL_DEPRECATED OFF}
{$ENDIF}

unit OpWord;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpWrdXP, OpOfcXP,                                                  {!!.62}
  OpMSO, OpShared, ActiveX, OpModels, OpOutlk, OpDbOfc
  {$IFDEF DCC6ORLATER}, Variants {$ENDIF} ;

type
 //: Name conflict with Excel Window
 WordWindow = type OpWrdXP.Window_;                                  {!!.62}

 //: set of view option on the TOpWordDocument.ViewType property
 TOpWdViewType = (wdvtNormalView,      // $00000001;
                  wdvtOutlineView,     // $00000002;
                  wdvtPrintView,       // $00000003;
                  wdvtPrintPreview,    // $00000004;
                  wdvtMasterView,      // $00000005;
                  wdvtWebView);        // $00000006;

  {: set of options on how to deal with the Ranges in Word
     Each option causes the Insert and InsertStrings procedure to be manipulated
     according to the TOpwdRangeLimit.
  }
  TOpWdRangeLimit = (wdrlParagraphs,
                     wdrlSentences,
                     wdrlWords,
                     wdrlCharacters);

  //: set of options on the TOpWordDocument.SummaryViewMode property.
  TOpWdSummaryMode = (wdsmHighlight,
                      wdsmHideAllButSummary,
                      wdsmInsert,
                      wdsmCreateNew);

  //: set of options on the Component's WindowState property.
  TOpWdWindowState = (wdwsNormal,
                      wdwsMaximized,
                      wdwsMinimized);

  //: set of options on the Component's AlertLevel property.
  TOpWdAlertLevel = (wdalNone,      // $00000000;
                     wdalMessageBox,// $FFFFFFFE;
                     wdalAll);      // $FFFFFFFF;

  //: set of options on the Component's EnableCancelKey property.
  TOpWdEnableCancelKey = (wdeckDisabled,   // $00000000;
                          wdeckInterrupt); // $00000001;

  //: set of options on the TOpDocumentRange.FontAnimation property.
  TOpWdFontAnimation = (wdfaNone,               // $00000000;
                        wdfaLasVegasLights,     // $00000001;
                        wdfaBlinkingBackground, // $00000002;
                        wdfaSparkleText,        // $00000003;
                        wdfaMarchingBlackAnts,  // $00000004;
                        wdfaMarchingRedAnts,    // $00000005;
                        wdfaShimmer);           // $00000006;

  //: set of options on the TOpWordDocument.Kind property.
  TOpWdDocumentKind = (wddkNotSpecified,
                       wddkLetter,
                       wddkEmail);

  TOpWdReplaceOption = (wdroReplaceNone,
                        wdroReplaceOne,
                        wdroReplaceAll);


type
{ Forwards }
  TOpWord = class;
  TOpWordDocument = class;


{ TOpMailMerge }
  TOpMailMerge = class(TPersistent)
  private
    FIntf : MailMerge;
    FModel : TOpUnknownComponent;
    procedure SetModel(const Value: TOpUnknownComponent);
  public
    procedure SetDoc(Doc: _Document);
    property AsMailMerge : MailMerge
      read FIntf;
  published
   property OfficeModel: TOpUnknownComponent
     read FModel write SetModel;
  end;


{ TOpDocumentShape }
  TOpDocumentShape = class(TOpNestedCollectionItem)
  private
    FLeft: Single;
    FTop: Single;
    FWidth: Single;
    FHeight: Single;
    FShapeName: WideString;
    procedure SetHeight(const Value: Single);
    procedure SetLeft(const Value: Single);
    procedure SetTop(const Value: Single);
    procedure SetWidth(const Value: Single);
    procedure SetShapeName(const Value: WideString);
  protected
    function GetSubCollection(index : integer) : TCollection; override;
    function GetSubCollectionCount : integer; override;
    function GetVerbCount: Integer; override;
    function GetVerb(index: integer): string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Activate; override;
    procedure AddTextBox;
    procedure Connect; override;
    procedure ExecuteVerb(index: Integer); override;
  published
    property Left: Single
      read FLeft write SetLeft;
    property Top: Single
      read FTop write SetTop;
    property Width: Single
      read FWidth write SetWidth;
    property Height: Single
      read FHeight write SetHeight;
    property ShapeName: WideString
      read FShapeName write SetShapeName;
  end;


{ The TOpDocumentShapes }
  TOpDocumentShapes = class(TOpNestedCollection)
  private
    function GetItem(Index: Integer): TOpDocumentShape;
    procedure SetItem(Index: Integer; Value: TOpDocumentShape);
  protected
    function GetItemName : string; override;
  public
    function Add: TOpDocumentShape;
    property Items[Index: Integer]: TOpDocumentShape
      read GetItem write SetItem; default;
  end;


{ TOpDocumentHyperLink }
  TOpDocumentHyperLink = class(TOpNestedCollectionItem)
  private
    FAddress: WideString;
    FNewWindow: Boolean;
    function GetAddress: WideString;
    procedure SetAddress(const Value: WideString);
    procedure SetNewWindow(const Value: Boolean);
  protected
    function GetSubCollection(index: integer): TCollection; override;
    function GetSubCollectionCount: integer; override;
    function GetVerbCount: Integer; override;
    function GetVerb(index: integer): string; override;
  public
    procedure Activate; override;
    procedure ExecuteVerb(index: Integer); override;
    procedure FollowHyperLink;
  published
    property Address: WideString
      read GetAddress write SetAddress;
    property NewWindow: Boolean
      read FNewWindow write SetNewWindow;
  end;


{ TOpDocumentHyperLinks }
  TOpDocumentHyperLinks = class(TOpNestedCollection)
  private
    function GetItem(Index: Integer): TOpDocumentHyperLink;
    procedure SetItem(Index: Integer; Value: TOpDocumentHyperLink);
  protected
    function GetItemName: string; override;
  public
    function Add: TOpDocumentHyperLink;
    property Items[Index: Integer]: TOpDocumentHyperLink
      read GetItem write SetItem; default;
  end;


{ TOpDocumentBookmark }
  TOpDocumentBookmark = class(TOpNestedCollectionItem)
  private
    FBookmarkName: WideString;
    function GetBookMarkName: WideString;
    procedure SetBookmarkName(const Value: WideString);
  protected
    function GetSubCollection(index: integer): TCollection; override;
    function GetSubCollectionCount: integer; override;
  public
    procedure Activate; override;
  published
    property BookmarkName: WideString
      read GetBookMarkName write SetBookmarkName;
  end;


{ TOpDocumentBookmarks }
  TOpDocumentBookmarks = class(TOpNestedCollection)
  private
    function GetItem(Index: Integer): TOpDocumentBookmark;
    procedure SetItem(Index: Integer; Value: TOpDocumentBookmark);
  protected
    function GetItemName: string; override;
  public
    function Add: TOpDocumentBookmark;
    property Items[Index: Integer]: TOpDocumentBookmark
      read GetItem write SetItem; default;
  end;


{ TOpDocumentTable }
  TOpDocumentTable = class(TOpNestedCollectionItem)
  private
    FModel: TOpUnknownComponent;
    procedure SetModel(Value: TOpUnknownComponent);
  protected
    function GetSubCollection(index: integer): TCollection; override;
    function GetSubCollectionCount: integer; override;
    function GetVerbCount: Integer; override;
    function GetVerb(index: integer): string; override;
  public
    procedure Activate; override;
    procedure ExecuteVerb(index: Integer); override;
    procedure PopulateDocTable;
    procedure RePopulateDocTable;
  published
    property OfficeModel: TOpUnknownComponent
    read FModel write SetModel;
  end;


{ TOpDocumentTables }
  TOpDocumentTables = class(TOpNestedCollection)
  private
    function GetItem(Index: Integer): TOpDocumentTable;
    procedure SetItem(Index: Integer; Value: TOpDocumentTable);
  protected
    function GetItemName: string; override;
  public
    function Add: TOpDocumentTable;
    property Items[Index: Integer]: TOpDocumentTable
      read GetItem write SetItem; default;
  end;


{ TOpWordDocument }
  TOpWordDocument = class(TOpNestedCollectionItem)
  private
    FName: string;
    FDocumentBookmarks: TOpDocumentBookmarks;
    FDocumentTables: TOpDocumentTables;
    FDocumentHyperLinks: TOpDocumentHyperLinks;
    FDocumentShapes: TOpDocumentShapes;
    FDocFile: TFileName;
    FDocumentKind: TOpWdDocumentKind;
    FShowSummary: WordBool;
    FMailMerge: TOpMailMerge;
    FSummaryLength: Integer;
    FHyphenationZone: Integer;
    FConsecutiveHyphensLimit: Integer;
    FDefaultTabStop: Single;
    FSummaryViewMode: TOpWdSummaryMode;
    FCodeName: WideString;
    FPrintRevisions: WordBool;
    FHyphenateCaps: WordBool;
    FPrintPostScriptOverText: WordBool;
    FSpellingChecked: WordBool;
    FShowRevisions: WordBool;
    FSaveFormsData: WordBool;
    FPrintFormsData: WordBool;
    FGrammarChecked: WordBool;
    FUserControl: WordBool;
    FShowGrammaticalErrors: WordBool;
    FReadOnlyRecommended: WordBool;
    FSaveSubsetFonts: WordBool;
    FTrackRevisions: WordBool;
    FUpdateStylesOnOpen: WordBool;
    FEmbedTrueTypeFonts: WordBool;
    FHasRoutingSlip: WordBool;
    FSaved: WordBool;
    FAutoHyphenation: WordBool;
    FShowSpellingErrors: WordBool;
    FdocRangeLimit: TOpWdRangeLimit;
    FRangeStart: integer;
    FRangeEnd: integer;
    FViewType: TOpWdViewType;
    FFindRange : OpWrdXP.Range;                                      {!!.62}
    FFindText : string;

    procedure SetSummary(const Value: WordBool);
    function GetDocumentKind: TOpWdDocumentKind;
    procedure SetDocumentKind(const Value: TOpWdDocumentKind);
    procedure SetMailMerge(const Value: TOpMailMerge);
    procedure SetAutoHyphenation(const Value: WordBool);
    procedure SetConsecutiveHyphensLimit(const Value: Integer);
    procedure SetDefaultTabStop(const Value: Single);
    procedure SetEmbedTrueTypeFonts(const Value: WordBool);
    procedure SetGrammarChecked(const Value: WordBool);
    procedure SetHasRoutingSlip(const Value: WordBool);
    procedure SetHyphenateCaps(const Value: WordBool);
    procedure SetHyphenationZone(const Value: Integer);
    procedure SetPrintFormsData(const Value: WordBool);
    procedure SetPrintPostScriptOverText(const Value: WordBool);
    procedure SetPrintRevisions(const Value: WordBool);
    procedure SetReadOnlyRecommended(const Value: WordBool);
    procedure SetSaved(const Value: WordBool);
    procedure SetSaveFormsData(const Value: WordBool);
    procedure SetSaveSubsetFonts(const Value: WordBool);
    procedure SetShowGrammaticalErrors(const Value: WordBool);
    procedure SetShowRevisions(const Value: WordBool);
    procedure SetShowSpellingErrors(const Value: WordBool);
    procedure SetSpellingChecked(const Value: WordBool);
    procedure SetSummaryLength(const Value: Integer);
    procedure SetSummaryViewMode(const Value: TOpWdSummaryMode);
    procedure SetTrackRevisions(const Value: WordBool);
    procedure SetUpdateStylesOnOpen(const Value: WordBool);
    procedure SetUserControl(const Value: WordBool);
    function GetAutoHyphenation: WordBool;
    function GetCodeName: WideString;
    function GetConsecutiveHyphensLimit: Integer;
    function GetDefaultTabStop: Single;
    function GetEmbedTrueTypeFonts: WordBool;
    function GetGrammarChecked: WordBool;
    function GetHasRoutingSlip: WordBool;
    function GetHyphenateCaps: WordBool;
    function GetHyphenationZone: Integer;
    function GetName: string;
    function GetPrintFormsData: WordBool;
    function GetPrintPostScriptOverText: WordBool;
    function GetPrintRevisions: WordBool;
    function GetReadOnlyRecommended: WordBool;
    function GetSaved: WordBool;
    function GetSaveFormsData: WordBool;
    function GetSaveSubsetFonts: WordBool;
    function GetShowGrammaticalErrors: WordBool;
    function GetShowRevisions: WordBool;
    function GetShowSpellingErrors: WordBool;
    function GetShowSummary: WordBool;
    function GetSpellingChecked: WordBool;
    function GetSummaryLength: Integer;
    function GetSummaryViewMode: TOpWdSummaryMode;
    function GetTrackRevisions: WordBool;
    function GetUpdateStylesOnOpen: WordBool;
    function GetUserControl: WordBool;
    procedure SetRangeLimit(const Value: TOpWdRangeLimit);
    procedure SetCodeName(const Value: WideString);
    function GetViewType: TOpWdViewType;
    procedure SetViewType(const Value: TOpWdViewType);
    function GetPropDirection: TOpPropDirection;
    function SaveCollection: Boolean;
    function GetAsDocument: _Document;
  protected
    function GetSubCollection(index: integer): TCollection; override;
    function GetSubCollectionCount: integer; override;
    procedure CreateSubCollections; override;
    function GetVerbCount: Integer; override;
    function GetVerb(index: integer): string; override;
    procedure SetDocFile(const Value: TFileName);

  public {methods}
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure Activate; override;
    procedure AnimateSelection(Value: TOpWdFontAnimation);
    procedure Connect; override;
    procedure ExecuteVerb(index: Integer); override;
    procedure ExecuteMailMerge;
    function  Find(const FindText: string; Forward: Boolean): Boolean;
    function  FindNext: Boolean;                                       {!!.61}
    procedure Insert(const Text: WideString; AtEnd: Boolean);
    procedure InsertStrings(Lines: TStrings; AtEnd: Boolean);
    procedure PopulateMailMerge;
    procedure Print;
    function  Replace(const FindText, ReplaceText: string; Forward: Boolean;
                ReplaceOption: TOpWdReplaceOption): Boolean;
    procedure Save;
    Procedure SaveAs(const FileName: string);
    procedure SendMailWithOutLook(const WordSubject, SendTo, SendCC, SendBC: string;
                OutlookComp: TOpOutlook; AsAttachment: Boolean);

  public {properties}
    property AsDocument: _Document
      read GetAsDocument;
    property PropDirection: TOpPropDirection
      read GetPropDirection;

  published {properties}
    property Name: string
      read GetName stored SaveCollection;
    property ShowSummary: WordBool
      read GetShowSummary write SetSummary stored SaveCollection;
    property DocumentKind: TOpWdDocumentKind
      read GetDocumentKind write SetDocumentKind stored SaveCollection;
    property Bookmarks: TOpDocumentBookmarks
      read FDocumentBookmarks write FDocumentBookmarks stored SaveCollection;
    property Tables: TOpDocumentTables
      read FDocumentTables write FDocumentTables stored SaveCollection;
    property HyperLinks: TOpDocumentHyperLinks
      read FDocumentHyperLinks write FDocumentHyperlinks stored SaveCollection;
    property Shapes: TOpDocumentShapes
      read FDocumentShapes write FDocumentShapes stored SaveCollection;
    property MailMerge: TOpMailMerge
      read FMailMerge write SetMailMerge;
    property DocFile: TFileName
      read FDocFile write SetDocFile;
    property AutoHyphenation: WordBool
      read GetAutoHyphenation write SetAutoHyphenation stored SaveCollection;
    property HyphenateCaps: WordBool
      read GetHyphenateCaps write SetHyphenateCaps stored SaveCollection;
    property HyphenationZone: Integer
      read GetHyphenationZone write SetHyphenationZone stored SaveCollection;
    property ConsecutiveHyphensLimit: Integer
      read GetConsecutiveHyphensLimit write SetConsecutiveHyphensLimit stored SaveCollection;
    property HasRoutingSlip: WordBool
      read GetHasRoutingSlip write SetHasRoutingSlip stored SaveCollection;
    property Saved: WordBool
      read GetSaved write SetSaved stored SaveCollection;
    property DefaultTabStop: Single
      read GetDefaultTabStop write SetDefaultTabStop stored SaveCollection;
    property EmbedTrueTypeFonts: WordBool
      read GetEmbedTrueTypeFonts write SetEmbedTrueTypeFonts stored SaveCollection;
    property SaveFormsData: WordBool
      read GetSaveFormsData write SetSaveFormsData stored SaveCollection;
    property ReadOnlyRecommended: WordBool
      read GetReadOnlyRecommended write SetReadOnlyRecommended stored SaveCollection;
    property SaveSubsetFonts: WordBool
      read GetSaveSubsetFonts write SetSaveSubsetFonts stored SaveCollection;
    property UpdateStylesOnOpen: WordBool
      read GetUpdateStylesOnOpen write SetUpdateStylesOnOpen stored SaveCollection;
    property GrammarChecked: WordBool
      read GetGrammarChecked write SetGrammarChecked stored SaveCollection;
    property SpellingChecked: WordBool
      read GetSpellingChecked write SetSpellingChecked stored SaveCollection;
    property ShowGrammaticalErrors: WordBool
      read GetShowGrammaticalErrors write SetShowGrammaticalErrors stored SaveCollection;
    property ShowSpellingErrors: WordBool
      read GetShowSpellingErrors write SetShowSpellingErrors stored SaveCollection;
    property SummaryViewMode: TOpWdSummaryMode
      read GetSummaryViewMode write SetSummaryViewMode stored SaveCollection;
    property SummaryLength: Integer
      read GetSummaryLength write SetSummaryLength stored SaveCollection;
    property PrintPostScriptOverText: WordBool
      read GetPrintPostScriptOverText write SetPrintPostScriptOverText stored SaveCollection;
    property PrintFormsData: WordBool
      read GetPrintFormsData write SetPrintFormsData stored SaveCollection;
    property UserControl: WordBool
      read GetUserControl write SetUserControl stored SaveCollection;
    property CodeName: WideString
      read GetCodeName write SetCodeName stored SaveCollection;
    property TrackRevisions: WordBool
      read GetTrackRevisions write SetTrackRevisions stored SaveCollection;
    property PrintRevisions: WordBool
      read GetPrintRevisions write SetPrintRevisions stored SaveCollection;
    property ShowRevisions: WordBool
      read GetShowRevisions write SetShowRevisions stored SaveCollection;
    property RangeLimit: TOpWdRangeLimit
      read FDocRangeLimit write SetRangeLimit stored SaveCollection;
    property RangeStart: integer
      read FRangeStart write FRangeStart stored SaveCollection;
    property RangeEnd: integer
      read FRangeEnd write FRangeEnd stored SaveCollection;
    property ViewType: TOpWdViewType
    read GetViewType write SetViewType stored SaveCollection;
  end;


{ TOpWordDocuments }
  TOpWordDocuments = class(TOpNestedCollection)
  protected
    function GetItem(Index: Integer): TOpWordDocument;
    procedure SetItem(Index: Integer; const Value: TOpWordDocument);
    function GetItemName: string; override;
  public
    function Add: TOpWordDocument;
    property Items[index: integer]: TOpWordDocument
      read GetItem write SetItem ; default;
  end;


{ TOpWord events }
  TOnDocumentOpen            = procedure(Sender: TObject; Doc: Document) of object;
  TOnDocumentBeforeClose     = procedure(Sender: TObject; Doc: Document;
                                 var Cancel: WordBool) of object;
  TOnDocumentBeforePrint     = procedure(Sender: TObject; Doc: Document;
                                 var Cancel: WordBool) of object;
  TOnDocumentBeforeSave      = procedure(Sender: TObject; Doc: Document;
                                 var SaveAsUI: WordBool; var Cancel: WordBool) of object;
  TOnNewDocument             = procedure(Sender: TObject; Doc: Document) of object;
  TOnWindowActivate          = procedure(Sender: TObject; Doc: Document;
                                 const Wn: WordWindow) of object;
  TOnWindowDeactivate        = procedure(Sender: TObject; Doc: Document;
                                 const Wn: WordWindow) of object;
  TOnWindowSelectionChange   = procedure(Sender: TObject; Sel: Selection) of object;
  TOnWindowBeforeRightClick  = procedure(Sender: TObject; Sel: Selection;
                                 var Cancel: WordBool) of object;
  TOnWindowBeforeDoubleClick = procedure(Sender: TObject; Sel: Selection;
                                 var Cancel: WordBool) of object;


{ TOpWord }
  TOpWord = class(TOpWordBase)
  protected {property variables}
    FServer: _Application;
    FVisible: Boolean;
    FCaption: string;
    FDocuments: TOpWordDocuments;
    FOnStartup: TNotifyEvent;
    FOnQuit: TNotifyEvent;
    FOnDocumentChange: TNotifyEvent;
    FOnDocumentOpen: TOnDocumentOpen;
    FOnDocumentBeforeClose: TOnDocumentBeforeClose;
    FOnDocumentBeforePrint: TOnDocumentBeforePrint;
    FOnDocumentBeforeSave: TOnDocumentBeforeSave;
    FOnNewDocument: TOnNewDocument;
    FOnWindowActivate: TOnWindowActivate;
    FOnWindowDeactivate: TOnWindowDeactivate;
    FOnWindowSelectionChange: TOnWindowSelectionChange;
    FOnWindowBeforeRightClick: TOnWindowBeforeRightClick;
    FOnWindowBeforeDoubleClick: TOnWindowBeforeDoubleClick;
    FDisplayAlerts: TOpWdAlertLevel;
    FEnableCancelKey: TOpWdEnableCancelKey;
    FWindowState: TOpWdWindowState;
    FStartupPath: WideString;
    FUserInitials: WideString;
    FUserAddress: WideString;
    FDefaultSaveFormat: WideString;
    FBrowseExtraFileTypes: WideString;
    FDefaultTableSeparator: WideString;
    FUserName: WideString;
    FDisplayRecentFiles: WordBool;
    FScreenUpdating: WordBool;
    FPrintPreview: WordBool;
    FDisplayScrollBars: WordBool;
    FDisplayScreenTips: WordBool;
    FHeight: integer;
    FTop: integer;
    FLeft: integer;
    FWidth: integer;

  protected {methods}
    procedure Setcaption(const Value: string);
    function  CollectionNotify(var Key; Item: TOpNestedCollectionItem): Boolean;
    procedure FixupCollection(Item: TOpNestedCollectionItem);
    procedure ReleaseCollectionInterface(Item: TOpNestedCollectionItem);
    procedure SetBrowseExtraFileTypes(const Value: WideString);
    procedure SetDefaultSaveFormat(const Value: WideString);
    procedure SetDefaultTableSeparator(const Value: WideString);
    procedure SetDisplayAlerts(const Value: TOpWdAlertLevel);
    procedure SetDisplayRecentFiles(const Value: WordBool);
    procedure SetDisplayScreenTips(const Value: WordBool);
    procedure SetDisplayScrollBars(const Value: WordBool);
    procedure SetEnableCancelKey(const Value: TOpWdEnableCancelKey);
    procedure SetPrintPreview(const Value: WordBool);
    procedure SetScreenUpdating(const Value: WordBool);
    procedure SetStartupPath(const Value: WideString);
    procedure SetUserAddress(const Value: WideString);
    procedure SetUserInitials(const Value: WideString);
    procedure SetUserName(const Value: WideString);
    procedure SetWindowState(const Value: TOpWdWindowState);
    function GetBrowseExtraFileTypes: WideString;
    function GetDefaultSaveFormat: WideString;
    function GetDefaultTableSeparator: WideString;
    function GetDisplayAlerts: TOpWdAlertLevel;
    function GetDisplayRecentFiles: WordBool;
    function GetDisplayScreenTips: WordBool;
    function GetDisplayScrollBars: WordBool;
    function GetEnableCancelKey: TOpWdEnableCancelKey;
    function GetPrintPreview: WordBool;
    function GetScreenUpdating: WordBool;
    function GetStartupPath: WideString;
    function GetUserAddress: WideString;
    function GetUserInitials: WideString;
    function GetUserName: WideString;
    function GetWindowState: TOpWdWindowState;
    function GetCaption: string;
    function GetHeight: Integer;
    function GetLeft: Integer;
    function GetTop: Integer;
    function GetWidth: Integer;
    procedure SetHeight(const Value: Integer);
    procedure SetLeft(const Value: Integer);
    procedure SetTop(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    function GetVisible: Boolean;
    procedure DoConnect; override;
    procedure DoDisconnect; override;
    procedure FixupProps; override;
    function GetWordInstance: _Application;
    procedure SetVisible(const Value: Boolean);
    function GetConnected: Boolean; override;
    function GetOfficeVersionStr: string; override;
    procedure DoApplicationStartUp;
    procedure DoApplicationQuit;
    procedure DoDocumentChange;
    procedure DoDocumentOpen(const Doc: Document);
    procedure DoDocumentBeforeClose(const Doc: Document; var Cancel: WordBool);
    procedure DoDocumentBeforePrint(const Doc: Document; var Cancel: WordBool);
    procedure DoDocumentBeforeSave(const Doc: Document; var SaveAsUI: WordBool; var Cancel: WordBool);
    procedure DoNewDocument(const Doc: Document);
    procedure DoWindowActivate(const Doc: Document; const Wn: WordWindow);
    procedure DoWindowDeactivate(const Doc: Document; const Wn: WordWindow);
    procedure DoWindowSelectionChange(const Sel: Selection);
    procedure DoWindowBeforeRightClick(const Sel: Selection; var Cancel: WordBool);
    procedure DoWindowBeforeDoubleClick(const Sel: Selection; var Cancel: WordBool);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function PointsToPixels(Points: Integer): Integer;
    function PixelsToPoints(Pixels: Integer): Integer;
    function PixelsPerInch: Integer;
    function GetActiveDocument : TOpWordDocument;                      {!!.61}

  public {methods}
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CreateItem(Item: TOpNestedCollectionItem): IDispatch; override;
    procedure GetAppInfo(Info: TStrings); override;
    procedure HandleEvent(const IID: TIID; DispId: Integer; const Params: TVariantArgList); override;
    procedure GetFileInfo(var Filter, DefExt: string); override;
    function OpenDocument(const FileName : TFileName) : TOpWordDocument; {!!.61}
    function NewDocument : TOpWordDocument;                              {!!.61}

  public {properties}
    property ActiveDocument : TOpWordDocument
      read GetActiveDocument;
    property Server: _Application
      read GetWordInstance;

  published {properties}
    property Caption: string
      read GetCaption write Setcaption;
    property Connected;
    property Documents: TOpWordDocuments
      read FDocuments write FDocuments;
    property PropDirection;
    property MachineName;
    property Visible: Boolean
      read GetVisible write SetVisible;
    property ScreenUpdating: WordBool
      read GetScreenUpdating write SetScreenUpdating;
    property PrintPreview: WordBool
      read GetPrintPreview write SetPrintPreview;
    property UserName: WideString
      read GetUserName write SetUserName;
    property UserInitials: WideString
      read GetUserInitials write SetUserInitials;
    property UserAddress: WideString
      read GetUserAddress write SetUserAddress;
    property DisplayRecentFiles: WordBool
      read GetDisplayRecentFiles write SetDisplayRecentFiles;
    property DefaultSaveFormat: WideString
      read GetDefaultSaveFormat write SetDefaultSaveFormat;
    property DisplayScrollBars: WordBool
      read GetDisplayScrollBars write SetDisplayScrollBars;
    property StartupPath: WideString
      read GetStartupPath write SetStartupPath stored False;
    property ServerLeft: Integer
      read GetLeft write SetLeft;
    property ServerTop: Integer
      read GetTop write SetTop;
    property ServerWidth: Integer
      read GetWidth write SetWidth;
    property ServerHeight: Integer
      read GetHeight write SetHeight;
    property WindowState: TOpWdWindowState
      read GetWindowState write SetWindowState;
    property DisplayAlerts: TOpWdAlertLevel
      read GetDisplayAlerts write SetDisplayAlerts;
    property DisplayScreenTips: WordBool
      read GetDisplayScreenTips write SetDisplayScreenTips;
    property EnableCancelKey: TOpWdEnableCancelKey
      read GetEnableCancelKey write SetEnableCancelKey;
    property DefaultTableSeparator: WideString
      read GetDefaultTableSeparator write SetDefaultTableSeparator;
    property BrowseExtraFileTypes: WideString
      read GetBrowseExtraFileTypes write SetBrowseExtraFileTypes;

    property OnOpConnect;
    property OnOpDisconnect;
    property OnGetInstance;
    property OnStartup: TNotifyEvent
      read FOnStartup write FOnStartup;
    property OnQuit: TNotifyEvent
      read FOnQuit write FOnQuit;
    property OnDocumentChange: TNotifyEvent
      read FOnDocumentChange write FOnDocumentChange;
    property OnDocumentOpen: TOnDocumentOpen
      read FOnDocumentOpen write FOnDocumentOpen;
    property BeforeDocumentClose: TOnDocumentBeforeClose
      read FOnDocumentBeforeClose write FOnDocumentBeforeClose;
    property BeforeDocumentPrint: TOnDocumentBeforePrint
      read FOnDocumentBeforePrint write FOnDocumentBeforePrint;
    property BeforeDocumentSave: TOnDocumentBeforeSave
      read FOnDocumentBeforeSave write FOnDocumentBeforeSave;
    property OnNewDocument: TOnNewDocument
      read FOnNewDocument write FOnNewDocument;
    property OnWindowActivate: TOnWindowActivate
      read FOnWindowActivate write FOnWindowActivate;
    property OnWindowDeactivate: TOnWindowDeactivate
      read FOnWindowDeactivate write FOnWindowDeactivate;
    property OnWindowSelectionChange: TOnWindowSelectionChange
      read FOnWindowSelectionChange write FOnWindowSelectionChange;
    property BeforeWindowRightClick: TOnWindowBeforeRightClick
      read FOnWindowBeforeRightClick write FOnWindowBeforeRightClick;
    property BeforeWindowDoubleClick: TOnWindowBeforeDoubleClick
      read FOnWindowBeforeDoubleClick write FOnWindowBeforeDoubleClick;
  end;

var
  SQLConfigDataSource: function (hwndParent: HWnd; fRequest: integer; lpszDriver: pchar; lpszAttributes: pchar): integer; stdcall;

implementation

uses
  {$IFDEF TRIALRUN} OpTrial, {$ENDIF}
   ComObj, OpConst;


{ TOpWord }
constructor TOpWord.Create(AOwner: TComponent);
begin
{$IFDEF TRIALRUN}
  _CC_;
  _VC_;
{$ENDIF}
  inherited Create(AOwner);


  FLeft := 0;
  FTop := 0;
  FWidth := 640;
  FHeight := 480;
  FDocuments:= TOpWordDocuments.Create(self, self, TOpWordDocument);
end;

destructor TOpWord.Destroy;
begin
  Connected := False;
  FDocuments.Free;
  inherited Destroy;
end;

{: GetWordInstance returns a _Application instance where you can get to any method
or property in the Word Type Library in case it was not wrapped in the TOpWord component.}
function TOpWord.GetWordInstance: _Application;
begin
  if FServer <> nil then
    result:= FServer
  else
    result:= nil;
end;

procedure TOpWord.HandleEvent(const IID: TIID; DispId: Integer; const Params: TVariantArgList);
begin
   if IsEqualGuid(IID,ApplicationEvents2) then
   begin
    ClientState := ClientState + [csInEvent];
    try
      case DispId of
        1:  DoApplicationStartUp;
        2:  DoApplicationQuit;
        3:  DoDocumentChange;
        4:  DoDocumentOpen(IDispatch(Params[0].dispVal) as Document);
        5:  ;// Not available in the Type Library !!!
        6:  DoDocumentBeforeClose(IDispatch(Params[0].dispVal) as Document, Params[1].pBool^);
        7:  DoDocumentBeforePrint(IDispatch(Params[0].dispVal) as Document, Params[1].pBool^);
        8:  DoDocumentBeforeSave(IDispatch(Params[0].dispVal) as Document, Params[1].pBool^, Params[2].pBool^);
        9:  DoNewDocument(IDispatch(Params[0].dispVal) as Document);
        10: DoWindowActivate(IDispatch(Params[0].dispVal) as Document, WordWindow(Params[1].dispVal));
        11: DoWindowDeactivate(IDispatch(Params[0].dispVal) as Document, WordWindow(Params[1].dispVal));
        12: DoWindowSelectionChange(IDispatch(Params[0].dispVal) as Selection);
        13: DoWindowBeforeRightClick(IDispatch(Params[0].dispVal) as Selection, Params[1].pBool^);
        14: DoWindowBeforeDoubleClick(IDispatch(Params[0].dispVal) as Selection, Params[1].pBool^);
      end;
    finally
      ClientState := ClientState - [csInEvent];
    end;
   end;
   if IsEqualGuid(IID,ApplicationEvents) then
   begin
     ClientState := ClientState + [csInEvent];
     try
       case DispId of
         1:  DoApplicationStartUp;
         2:  DoApplicationQuit;
         3:  DoDocumentChange;
       end;
     finally
       ClientState := ClientState - [csInEvent];
     end;
   end;

end;

procedure TOpWord.SetCaption(const Value: string);
begin
  FCaption := Value;
  if (Connected) then
    FServer.Caption := Value;
end;

procedure TOpWord.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
  if Connected then
  begin
    FServer.Visible:= Value;
    FServer.ScreenUpdating:= True;
  end;
end;

{: This event will never fire, known problem for Word 97 and 2000 and reported on the MSDN}
procedure TOpWord.DoApplicationStartUp;
begin
  if Assigned(FOnStartUp) then FOnStartUp(Self);
end;

procedure TOpWord.DoApplicationQuit;
begin
  if Assigned(FOnQuit) then FOnQuit(Self);
  Connected:= False;
end;

procedure TOpWord.DoDocumentChange;
begin
  if Assigned(FOnDocumentChange) then FOnDocumentChange(Self);
end;

procedure TOpWord.DoDocumentBeforeClose(const Doc: Document; var Cancel: WordBool);
begin
  if assigned(FOnDocumentBeforeClose) then FOnDocumentBeforeClose(self, Doc, Cancel);
end;

procedure TOpWord.DoDocumentBeforePrint(const Doc: Document; var Cancel: WordBool);
begin
  if assigned(FOnDocumentBeforePrint) then FOnDocumentBeforePrint(self, Doc, Cancel);
end;

procedure TOpWord.DoDocumentBeforeSave(const Doc: Document; var SaveAsUI, Cancel: WordBool);
begin
  if assigned(FOnDocumentBeforeSave) then FOnDocumentBeforeSave(self, Doc, SaveAsUI, Cancel);
end;

procedure TOpWord.DoDocumentOpen(const Doc: Document);
begin
  if assigned(FOnDocumentOpen) then FOnDocumentOpen(self, Doc);
end;

procedure TOpWord.DoNewDocument(const Doc: Document);
begin
  if assigned(FOnNewDocument) then FOnNewDocument(self, Doc);
end;

procedure TOpWord.DoWindowActivate(const Doc: Document; const Wn: WordWindow);
begin
  if assigned(FOnWindowActivate) then FOnWindowActivate(self, Doc, Wn);
end;

procedure TOpWord.DoWindowBeforeDoubleClick(const Sel: Selection; var Cancel: WordBool);
begin
  if assigned(FOnWindowBeforeDoubleClick) then FOnWindowBeforeDoubleClick(self, Sel, Cancel);
end;

procedure TOpWord.DoWindowBeforeRightClick(const Sel: Selection; var Cancel: WordBool);
begin
 if assigned(FOnWindowBeforeRightClick) then FOnWindowBeforeRightClick(self, Sel, Cancel);
end;

procedure TOpWord.DoWindowDeactivate(const Doc: Document; const Wn: WordWindow);
begin
  if assigned(FOnWindowDeactivate) then FOnWindowDeactivate(self, Doc, Wn);
end;

procedure TOpWord.DoWindowSelectionChange(const Sel: Selection);
begin
  if assigned(FOnWindowSelectionChange) then FOnWindowSelectionChange(self, Sel);
end;

{: FixupProps allows for changes to the Word properties while the server is not connected.}
procedure TOpWord.FixupProps;
begin
  Visible := FVisible;
  case PropDirection of
    pdToServer:  Begin
                  WindowState:= FWindowState;
                  Visible:= FVisible;
                  Caption:= FCaption;
                  ScreenUpdating:= FScreenUpdating;
                  PrintPreview:= FPrintPreview;
                  UserName:= FUserName;
                  UserInitials:= FUserInitials;
                  UserAddress:= FUserAddress;
                  DisplayRecentFiles:= FDisplayRecentFiles;
                  DefaultSaveFormat:= FDefaultSaveFormat;
                  DisplayScrollBars:= FDisplayScrollBars;
                  StartupPath:= FStartupPath;
                  ServerLeft:= FLeft;
                  ServerTop:= FTop;
                  ServerWidth:= FWidth;
                  ServerHeight:= FHeight;
                  DisplayAlerts:= FDisplayAlerts;
                  DisplayScreenTips:= FDisplayScreenTips;
                  EnableCancelKey:= FEnableCancelKey;
                  DefaultTableSeparator:= FDefaultTableSeparator;
                  BrowseExtraFileTypes:= FBrowseExtraFileTypes;
                 end;
    pdFromServer: begin
                    FWindowState:= WindowState;
                    FVisible:= Visible;
                    FCaption:= Caption;
                    FScreenUpdating:= ScreenUpdating;
                    FPrintPreview:= PrintPreview;
                    FUserName:= UserName;
                    FUserInitials:= UserInitials;
                    FUserAddress:= UserAddress;
                    FDisplayRecentFiles:= DisplayRecentFiles;
                    FDefaultSaveFormat:= DefaultSaveFormat;
                    FDisplayScrollBars:= DisplayScrollBars;
                    FStartupPath:= StartupPath;
                    FLeft:= ServerLeft;
                    FTop:= ServerTop;
                    FWidth:= ServerWidth;
                    FHeight:= ServerHeight;
                    FDisplayAlerts:= DisplayAlerts;
                    FDisplayScreenTips:= DisplayScreenTips;
                    FEnableCancelKey:= EnableCancelKey;
                    FDefaultTableSeparator:= DefaultTableSeparator;
                    FBrowseExtraFileTypes:= BrowseExtraFileTypes;
                  end;
  end;
  FDocuments.ForEachItem(FixupCollection);
end;

{: CreateItem is the function responsible of creating all common Word Objects
whether the PropDirection is pdFromServer or pdToServer.}
function TOpWord.CreateItem(Item: TOpNestedCollectionItem): IDispatch;
var
  OleBookRange, OleHyperRange, OleSubAddress, OleIndex: OleVariant;
begin
  Result := nil;
  if Connected then begin

    if (Item is TOpWordDocument) then begin
      if TOpWordDocument(Item).PropDirection = pdFromServer then
        Result:= nil
      else
        Result := Server.Documents.AddOld(EmptyParam, EmptyParam);
    end;

    if (Item is TOpDocumentBookmark) then begin
      OleIndex := Item.Index + 1;
      if Item.Index < (Item.ParentItem.Intf as _Document).Bookmarks.Count then begin
        Result := (Item.ParentItem.Intf as _Document).Bookmarks.Item(OleIndex);
        TOpDocumentBookmark(Item).FBookmarkName :=
          (Item.ParentItem.Intf as _Document).Bookmarks.Item(OleIndex).Name;
      end else begin
        if (Item.ParentItem.Intf as _Document).Application_.Selection.Range.Text <> '' then begin
          OleBookRange:= (Item.ParentItem.Intf as _Document).Application_.Selection.Range;
          Result := (Item.ParentItem.Intf as _Document).Bookmarks.Add('Bookmark' +
            IntToStr((Item.ParentItem.Intf as _Document).Bookmarks.count + 1), OleBookRange);
          TOpDocumentBookmark(Item).FBookmarkName:= (Result as Bookmark).Name;
        end else
          raise Exception.Create(STextMustBeSelected);
      end;
    end;

    if (Item is TOpDocumentHyperLink) then begin
      OleIndex := Item.Index + 1;
      if Item.Index < (Item.ParentItem.Intf as _Document).Hyperlinks.Count then begin
        Result := (Item.ParentItem.Intf as _Document).Hyperlinks.Item(OleIndex);
        TOpDocumentHyperLink(Item).FAddress:=
          (Item.ParentItem.Intf as _Document).Hyperlinks.Item(OleIndex).AddressOld;
      end else begin
        if (Item.ParentItem.Intf as _Document).Application_.Selection.Range.Text <> '' then begin
          OleSubAddress:= '';
          OleHyperRange:= (Item.ParentItem.Intf as _Document).Application_.Selection.Range.Text;
          Result := (Item.ParentItem.Intf as _Document).HyperLinks._Add(
            (Item.ParentItem.Intf as _Document).Application_.Selection.Range,
            OleHyperRange, OleSubAddress);
        end else
          raise Exception.Create(STextMustBeSelected);
      end;
    end;

    if (Item is TOpDocumentTable) then begin
      OleIndex := Item.Index + 1;                                    {!!.62}
      if Item.Index < (Item.ParentItem.Intf as _Document).Tables.Count then
        Result := (Item.ParentItem.Intf as _Document).Tables.Item(OleIndex);
    end;

    if (Item is TOpDocumentShape) then begin
      OleIndex := Item.Index + 1;                                    {!!.61}
      if Item.Index < (Item.ParentItem.Intf as _Document).Shapes.Count then begin
        Result := ((Item.ParentItem.Intf as _Document).Shapes.Item(OleIndex) as OpWrdXP.Shape);  {!!.62}
        TOpDocumentShape(Item).FLeft :=
          ((Item.ParentItem.Intf as _Document).Shapes.Item(OleIndex) as OpWrdXP.Shape).Left;  {!!.62}
        TOpDocumentShape(Item).FTop :=
          ((Item.ParentItem.Intf as _Document).Shapes.Item(OleIndex) as OpWrdXP.Shape).Top;
        TOpDocumentShape(Item).FWidth :=
          ((Item.ParentItem.Intf as _Document).Shapes.Item(OleIndex) as OpWrdXP.Shape).Width; {!!.62}
        TOpDocumentShape(Item).FHeight :=
          ((Item.ParentItem.Intf as _Document).Shapes.Item(OleIndex) as OpWrdXP.Shape).Height; {!!.62}
        TOpDocumentShape(Item).FShapeName :=
          ((Item.ParentItem.Intf as _Document).Shapes.Item(OleIndex) as OpWrdXP.Shape).Name;  {!!.62}
      end
    end;
  end;
end;

function TOpWord.GetConnected: Boolean;
begin
  Result := Assigned(FServer);
end;

{: GetFileInfo defines the Filter and the Default Extension for the Open Dialog of Word Files.}
procedure TOpWord.GetFileInfo(var Filter, DefExt: string);
begin
  Filter := SWordFilter;
  DefExt := SWordDef;
end;

procedure TOpWord.FixupCollection(Item: TOpNestedCollectionItem);
begin
  Item.Connect;
end;

procedure TOpWord.ReleaseCollectionInterface(Item: TOpNestedCollectionItem);
begin
  Item.Intf := nil;
end;

procedure TOpWord.SetBrowseExtraFileTypes(const Value: WideString);
begin
  if (Connected) then
    FServer.BrowseExtraFileTypes := Value;
  FBrowseExtraFileTypes := Value;
end;

procedure TOpWord.SetDefaultSaveFormat(const Value: WideString);
begin
  if (Connected) then
    FServer.DefaultSaveFormat := Value;
  FDefaultSaveFormat := Value;
end;
//: Note: Separator can not be empty
procedure TOpWord.SetDefaultTableSeparator(const Value: WideString);
begin
  if (Connected) and (Value <> '') then
    FServer.DefaultTableSeparator := Value;
  FDefaultTableSeparator := Value;
end;

procedure TOpWord.SetDisplayAlerts(const Value: TOpWdAlertLevel);
begin
  if (Connected) then
  begin
    case Value of
    {$IFDEF DCC6ORLATER}
      wdalNone: FServer.DisplayAlerts := Int64($00000000);
      wdalMessageBox: FServer.DisplayAlerts:= Int64($FFFFFFFE);
      wdalAll: FServer.DisplayAlerts:= Int64($FFFFFFFF);
    {$ELSE}
      wdalNone: FServer.DisplayAlerts := Integer($00000000);
      wdalMessageBox: FServer.DisplayAlerts:= Integer($FFFFFFFE);
      wdalAll: FServer.DisplayAlerts:= Integer($FFFFFFFF);
    {$ENDIF}
    end;
  end;
  FDisplayAlerts := Value;
end;

procedure TOpWord.SetDisplayRecentFiles(const Value: WordBool);
begin
  if (Connected) then
    FServer.DisplayRecentFiles := Value;
  FDisplayRecentFiles := Value;
end;

procedure TOpWord.SetDisplayScreenTips(const Value: WordBool);
begin
  if (Connected) and (FDisplayScreenTips <> Value) then
    FServer.DisplayScreenTips := Value;
  FDisplayScreenTips := Value;
end;

procedure TOpWord.SetDisplayScrollBars(const Value: WordBool);
begin
  if (Connected) then
    FServer.DisplayScrollBars := Value;
  FDisplayScrollBars := Value;
end;

procedure TOpWord.SetEnableCancelKey(const Value: TOpWdEnableCancelKey);
begin
  if (Connected) then
  begin
    case Value of
      wdeckDisabled:  FServer.EnableCancelKey := Integer($00000000);
      wdeckInterrupt: FServer.EnableCancelKey := Integer($00000001);
    end;
  end;
  FEnableCancelKey := Value;
end;

procedure TOpWord.SetPrintPreview(const Value: WordBool);
begin
  if (Connected) then
    FServer.PrintPreview := Value;
  FPrintPreview := Value;
end;

procedure TOpWord.SetScreenUpdating(const Value: WordBool);
begin
  if (Connected) then
    FServer.ScreenUpdating := Value;
  FScreenUpdating := Value;
end;

procedure TOpWord.SetStartupPath(const Value: WideString);
begin
  if (Connected) then
    FServer.StartupPath := Value;
  FStartupPath := Value;
end;

procedure TOpWord.SetUserAddress(const Value: WideString);
begin
  if (Connected) then
    FServer.UserAddress := Value;
  FUserAddress := Value;
end;

procedure TOpWord.SetUserInitials(const Value: WideString);
begin
  if (Connected) then
    FServer.UserInitials := Value;
  FUserInitials := Value;
end;

procedure TOpWord.SetUserName(const Value: WideString);
begin
try
  if (Connected) then
    FServer.UserName := Value;
except
end;
  FUserName := Value;
end;

procedure TOpWord.SetWindowState(const Value: TOpWdWindowState);
begin
  if (Connected) then
  begin
    case Value of
      wdwsNormal: FServer.WindowState := Integer(wdwsNormal);
      wdwsMinimized: FServer.WindowState:= Integer(wdwsMinimized);
      wdwsMaximized: FServer.WindowState:= Integer(wdwsMaximized);
    end;
  end;
  FWindowState := Value;
end;

function TOpWord.GetActiveDocument : TOpWordDocument;                  {!!.61}
var
  Doc : _Document;
  i : Integer;
begin
  Result := nil;
  Doc := Server.ActiveDocument;
  if (Documents.Count > 0) then
    for i := 0 to Pred(Documents.Count) do
      if (Doc = Documents[i].AsDocument) then
        begin
          Result := Documents[i];
          Break;
        end;
end;


{: GetAppInfo gathers information from the server}
procedure TOpWord.GetAppInfo(Info: TStrings);
var
  App: _Application;
  Mcp: string;
  b: OleVariant;
  Created : boolean;
begin
  if not Connected then
  begin
    Created := True;
    OleCheck(CoCreate(CLASS_Application_, _Application, App))
  end
  else
  begin
    Created := False;
    App := FServer;
  end;
  if assigned(Info) then
  begin
    with Info do
    begin
      Clear;
      Add('User Name=' + App.UserName);
      Add('Version=' + App.Version);
      Add('Build=' + App.Build);
      Add('Active Printer=' + App.ActivePrinter);
      if App.MathCoProcessorAvailable then Mcp := 'Yes'
      else Mcp := 'No';
      Add('Math CoProcessorAvailable=' + Mcp);
    end;
  end;
  if Created then
  begin
    b := False;
    App.Quit(b, emptyParam, emptyParam);
  end;
end;

function TOpWord.GetBrowseExtraFileTypes: WideString;
begin
  if Connected then
  begin
    Result := FServer.BrowseExtraFileTypes;
    FBrowseExtraFileTypes:= Result;
  end
  else
    Result := FBrowseExtraFileTypes;
end;

function TOpWord.GetDefaultSaveFormat: WideString;
begin
  if Connected then
  begin
    Result := FServer.DefaultSaveFormat;
    FDefaultSaveFormat:= Result;
  end
  else
    Result := FDefaultSaveFormat;
end;

function TOpWord.GetDefaultTableSeparator: WideString;
begin
  if Connected then
  begin
    Result := FServer.DefaultTableSeparator;
    FDefaultTableSeparator:= Result;
  end
  else
    Result := FDefaultTableSeparator;
end;

function TOpWord.GetDisplayAlerts: TOpWdAlertLevel;
begin
  if Connected then
  begin
    Result := TOpWdAlertLevel(FServer.DisplayAlerts);
    FDisplayAlerts:= Result;
  end
  else
    Result := FDisplayAlerts;
end;

function TOpWord.GetDisplayRecentFiles: WordBool;
begin
  if Connected then
  begin
    Result := FServer.DisplayRecentFiles;
    FDisplayRecentFiles:= Result;
  end
  else
    Result := FDisplayRecentFiles;
end;

function TOpWord.GetDisplayScreenTips: WordBool;
begin
  if Connected then
  begin
    Result := FServer.DisplayScreenTips;
    FDisplayScreenTips:= Result;
  end
  else
    Result := FDisplayScreenTips;
end;

function TOpWord.GetDisplayScrollBars: WordBool;
begin
  if Connected then
  begin
   Result := FServer.DisplayScrollBars;
    FDisplayScrollBars:= Result;
  end
  else
    Result := FDisplayScrollBars;
end;

function TOpWord.GetEnableCancelKey: TOpWdEnableCancelKey;
begin
  if Connected then
  begin
    Result := TOpWdEnableCancelKey(FServer.EnableCancelKey);
    FEnableCancelKey:= Result;
  end
  else
    Result := FEnableCancelKey;
end;

function TOpWord.GetPrintPreview: WordBool;
begin
  if Connected then
  begin
    Result := FServer.PrintPreview;
    FPrintPreview:= Result;
  end
  else
    Result := FPrintPreview;
end;

function TOpWord.GetScreenUpdating: WordBool;
begin
  if Connected then
  begin
    Result := FServer.ScreenUpdating;
    FScreenUpdating:= Result;
  end
  else
    Result := FScreenUpdating;
end;

function TOpWord.GetStartupPath: WideString;
begin
  if Connected then
  begin
    Result := FServer.StartupPath;
    FStartupPath:= Result;
  end
  else
    Result := FStartupPath;
end;

function TOpWord.GetUserAddress: WideString;
begin
  if Connected then
  begin
    Result := FServer.UserAddress;
    FUserAddress:= Result;
  end
  else
    Result := FUserAddress;
end;

function TOpWord.GetUserInitials: WideString;
begin
  if Connected then
  begin
    Result := FServer.UserInitials;
    FUserInitials:= Result;
  end
  else
    Result := FUserInitials;
end;

function TOpWord.GetUserName: WideString;
begin
  if Connected then
  begin
    Result := FServer.UserName;
    FUserName:= Result;
  end
  else
    Result := FUserName;
end;

function TOpWord.GetWindowState: TOpWdWindowState;
begin
  if Connected then
  begin
    Result := TOpWdWindowState(FServer.WindowState);
    FWindowState:= Result;
  end
  else
    Result := FWindowState;
end;

function TOpWord.GetCaption: string;
begin
  if Connected then
  begin
    Result := FServer.Caption;
    FCaption:= Result;
  end
  else
    Result := FCaption;
end;

function TOpWord.GetHeight: Integer;
begin
  if Connected then
  begin
    Result := PointsToPixels(FServer.Height);
    FHeight:= Result;
  end
  else
    Result := FHeight;
end;

function TOpWord.GetLeft: Integer;
begin
  if Connected then
  begin
    Result := PointsToPixels(Fserver.Left);
    FLeft:= Result;
  end
  else
    Result := FLeft;
end;

function TOpWord.GetTop: Integer;
begin
  if Connected then
  begin
    Result := PointsToPixels(FServer.Top);
    FTop:= Result;
  end
  else
   Result := FTop;
end;

function TOpWord.GetWidth: Integer;
begin
  if Connected then
  begin
   Result := PointsToPixels(FServer.Width);
    FWidth:= Result;
  end
  else
    Result := FWidth;
end;

procedure TOpWord.SetHeight(const Value: Integer);
begin
  FHeight:= Value;
  if (Connected) and (FWindowState = wdwsNormal) then
    FServer.Height := PixelsToPoints(FHeight);
end;

procedure TOpWord.SetLeft(const Value: Integer);
begin
  FLeft:= Value;
  if (Connected) and (FWindowState = wdwsNormal) then
    FServer.Left := PixelsToPoints(FLeft);
end;

procedure TOpWord.SetTop(const Value: Integer);
begin
  FTop:= Value;
  if (Connected) and (FWindowState = wdwsNormal) then
    FServer.Top := PixelsToPoints(FTop);
end;

procedure TOpWord.SetWidth(const Value: Integer);
begin
  FWidth:= Value;
  if (Connected) and (FWindowState = wdwsNormal) then
    FServer.Width := PixelsToPoints(FWidth);
end;

function TOpWord.CollectionNotify(var Key; Item: TOpNestedCollectionItem): Boolean;
begin
  if (Item is TOpDocumentTable) and (TComponent(Key) = (Item as TOpDocumentTable).OfficeModel) then
  begin
    (Item as TOpDocumentTable).OfficeModel := nil;
    Result := true;
  end
  else
    Result := false;
end;

procedure TOpWord.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent,Operation);
  if (Operation = opRemove) and (AComponent is TOpUnknownComponent) then
  begin
    Documents.FindItem(AComponent,CollectionNotify,nil)
  end;
end;

function TOpWord.NewDocument : TOpWordDocument;                        {!!.61}
begin
  if not Connected then
    Connected := True;
  Result := Documents.Add;
end;

function TOpWord.OpenDocument(const FileName : TFileName) :            {!!.61}  
                              TOpWordDocument;
begin
  if not Connected then
    Connected := True;
  Result := Documents.Add;
  Result.DocFile := FileName;
end;

function TOpWord.PixelsPerInch: Integer;
var
  DC: HDC;
begin
  DC := GetDC(0);
  try
    Result := GetDeviceCaps(DC,LOGPIXELSY);
  finally
    ReleaseDC(0,DC);
  end;
end;

function TOpWord.PixelsToPoints(Pixels: Integer): Integer;
begin
  Result := Trunc((Pixels / PixelsPerInch) * 72);
end;

function TOpWord.PointsToPixels(Points: Integer): Integer;
begin
   Result := Trunc((Points / 72) * PixelsPerInch);
end;


function TOpWord.GetVisible: Boolean;
begin
  if (Connected) then
  begin
    Result := FServer.Visible;
    FVisible := Result;
  end
  else
    Result := FVisible;
end;

procedure TOpWord.DoConnect;
begin
  OleCheck(CoCreate(CLASS_Application_, _Application, FServer));
  if (OfficeVersion = ov2000) or (OfficeVersion = ovXP) then         {!!.63}
    CreateEvents(FServer, DIID_ApplicationEvents2);
  if OfficeVersion = ov97 then
    CreateEvents(FServer, DIID_ApplicationEvents);
end;

procedure TOpWord.DoDisconnect;
var
  NoSave: OleVariant;
begin
  Events.Free;
  FDocuments.ForEachItem(ReleaseCollectionInterface);
  FServer.Quit(NoSave, emptyParam, emptyParam);
  FServer:= nil;
end;

function TOpWord.GetOfficeVersionStr: string;
begin
  Result := FServer.Version;
end;

{ TOpWordDocument }

constructor TOpWordDocument.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FMailMerge:= TOpMailMerge.Create;
  RangeLimit:= wdrlCharacters;
end;

procedure TOpWordDocument.Activate;
begin
  if assigned(Intf) then AsDocument.Activate;
end;

procedure TOpWordDocument.AnimateSelection(Value: TOpWdFontAnimation);
begin
  if CheckActive(True, ctMethod) then
  begin
    with (RootComponent as TOpWord).Server.Selection.Range.Font do
    case Value of
      wdfaNone: Animation:= wdAnimationNone;
      wdfaLasVegasLights: Animation:= wdAnimationLasVegasLights;
      wdfaBlinkingBackground: Animation:= wdAnimationBlinkingBackground;
      wdfaSparkleText: Animation:= wdAnimationSparkleText;
      wdfaMarchingBlackAnts: Animation:= wdAnimationMarchingBlackAnts;
      wdfaMarchingRedAnts: Animation:= wdAnimationMarchingRedAnts;
      wdfaShimmer: Animation := wdAnimationShimmer;
    end;
  end;
end;


function TOpWordDocument.SaveCollection: Boolean;
begin
  Result := PropDirection = pdToServer;
end;


procedure TOpWordDocument.Connect;
begin
  inherited Connect;
  if (PropDirection = pdFromServer) then
    DocFile:= FDocFile;
  ShowSummary:= FShowSummary;
  DocumentKind:= FDocumentKind;
  MailMerge:= FMailMerge;
  AutoHyphenation:= FAutoHyphenation;
  HyphenateCaps:= FHyphenateCaps;
  HyphenationZone:= 1;  //FHyphenationZone;
  ConsecutiveHyphensLimit:= FConsecutiveHyphensLimit;
  HasRoutingSlip:= FHasRoutingSlip;
  Saved:= FSaved;
  DefaultTabStop:= FDefaultTabStop;
  EmbedTrueTypeFonts:= FEmbedTrueTypeFonts;
  SaveFormsData:= FSaveFormsData;
  ReadOnlyRecommended:= FReadOnlyRecommended;
  SaveSubsetFonts:= FSaveSubsetFonts;
  UpdateStylesOnOpen:=FUpdateStylesOnOpen;
  GrammarChecked:= FGrammarChecked;
  SpellingChecked:= FSpellingChecked;
  ShowGrammaticalErrors:= FShowGrammaticalErrors;
  ShowSpellingErrors:= FShowSpellingErrors;
  SummaryViewMode:= FSummaryViewMode;
  SummaryLength:= FSummaryLength;
  PrintPostScriptOverText:= FPrintPostScriptOverText;
  PrintFormsData:= FPrintFormsData;
  UserControl:= FUserControl;
  TrackRevisions:= FTrackRevisions;
  PrintRevisions:= FPrintRevisions;
  ShowRevisions:= FShowRevisions;
end;

procedure TOpWordDocument.CreateSubCollections;
begin
  FDocumentHyperLinks := TOpDocumentHyperLinks.Create(RootComponent,self,TOpDocumentHyperLink);
  FDocumentShapes := TOpDocumentShapes.Create(RootComponent,self,TOpDocumentShape);
  FDocumentBookmarks := TOpDocumentBookmarks.Create(RootComponent,self,TOpDocumentBookmark);
  FDocumentTables := TOpDocumentTables.Create(RootComponent,self,TOpDocumentTable);
end;

destructor TOpWordDocument.Destroy;
var
  NoSave: OleVariant;
begin
  if TOpWord(RootComponent).Connected then
  begin
    NoSave:= wdDoNotSaveChanges;
    AsDocument.Close(NoSave, emptyParam, emptyParam);
  end;
  FMailMerge.Free;
  FDocumentHyperLinks.Free;
  FDocumentShapes.Free;
  FDocumentBookmarks.Free;
  FDocumentTables.Free;
  inherited destroy;
end;
{: ExecuteMailMerge generates a new Document with all the runtime database fields populated on the main document.}
procedure TOpWordDocument.ExecuteMailMerge;
begin
  if (CheckActive(True,ctMethod)) then
    if FMailMerge.AsMailMerge <> nil then
      FMailMerge.AsMailMerge.Execute(emptyParam)
    else
      ShowMessage('The Document needs to be populated before it can be Executed');
end;

procedure TOpWordDocument.ExecuteVerb(index: Integer);
begin
  case index of
    0: PopulateMailMerge;
    1: ExecuteMailMerge;
    2: Save;
  end;
end;

function TOpWordDocument.GetAutoHyphenation: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.AutoHyphenation;
    FAutoHyphenation:= Result;
  end
  else
    Result := FAutoHyphenation;
end;

function TOpWordDocument.GetCodeName: WideString;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument._CodeName;
    FCodeName:= Result;
  end
  else
    Result := FCodeName;
end;

function TOpWordDocument.GetConsecutiveHyphensLimit: Integer;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.ConsecutiveHyphensLimit;
    FConsecutiveHyphensLimit:= Result;
  end
  else
    Result := FConsecutiveHyphensLimit;
end;

function TOpWordDocument.GetDefaultTabStop: Single;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.DefaultTabStop;
    FDefaultTabStop:= Result;
  end
  else
    Result := FDefaultTabStop;
end;

function TOpWordDocument.GetDocumentKind: TOpWdDocumentKind;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := TOpWdDocumentKind(AsDocument.Kind);
    FDocumentKind:= Result;
  end
  else
    Result := FDocumentKind;
end;

function TOpWordDocument.GetEmbedTrueTypeFonts: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.EmbedTrueTypeFonts;
    FEmbedTrueTypeFonts:= Result;
  end
  else
    Result := FEmbedTrueTypeFonts;
end;

function TOpWordDocument.GetGrammarChecked: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.GrammarChecked;
    FGrammarChecked:= Result;
  end
  else
    Result := FGrammarChecked;
end;

function TOpWordDocument.GetHasRoutingSlip: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.HasRoutingSlip;
    FHasRoutingSlip:= Result;
  end
  else
    Result := FHasRoutingSlip;
end;

function TOpWordDocument.GetHyphenateCaps: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.HyphenateCaps;
    FHyphenateCaps:= Result;
  end
  else
    Result := FHyphenateCaps;
end;

function TOpWordDocument.GetHyphenationZone: Integer;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.HyphenationZone;
    FHyphenationZone:= Result;
  end
  else
    Result := FHyphenationZone;
end;

function TOpWordDocument.GetName: string;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.Name;
    FName:= Result;
  end
  else
    Result := FName;
end;

function TOpWordDocument.GetPrintFormsData: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.PrintFormsData;
    FPrintFormsData:= Result;
  end
  else
    Result := FPrintFormsData;
end;

function TOpWordDocument.GetPrintPostScriptOverText: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.PrintPostScriptOverText;
    FPrintPostScriptOverText:= Result;
  end
  else
    Result := FPrintPostScriptOverText;
end;

function TOpWordDocument.GetPrintRevisions: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.PrintRevisions;
    FPrintRevisions:= Result;
  end
  else
    Result := FPrintRevisions;
end;

function TOpWordDocument.GetPropDirection: TOpPropDirection;
begin
  if FDocFile = '' then
    Result := pdToServer
  else
    Result := pdFromServer;
end;

function TOpWordDocument.GetReadOnlyRecommended: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.ReadOnlyRecommended;
    FReadOnlyRecommended:= Result;
  end
  else
    Result := FReadOnlyRecommended;
end;

function TOpWordDocument.GetSaved: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.Saved;
    FSaved:= Result;
  end
  else
    Result := FSaved;
end;

function TOpWordDocument.GetSaveFormsData: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.SaveFormsData;
    FSaveFormsData:= Result;
  end
  else
    Result := FSaveFormsData;
end;

function TOpWordDocument.GetSaveSubsetFonts: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.SaveSubsetFonts;
    FSaveSubsetFonts:= Result;
  end
  else
    Result := FSaveSubsetFonts;
end;

function TOpWordDocument.GetShowGrammaticalErrors: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.ShowGrammaticalErrors;
    FShowGrammaticalErrors:= Result;
  end
  else
    Result := FShowGrammaticalErrors;
end;

function TOpWordDocument.GetShowRevisions: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.ShowRevisions;
    FShowRevisions:= Result;
  end
  else
    Result := FShowRevisions;
end;

function TOpWordDocument.GetShowSpellingErrors: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.ShowSpellingErrors;
    FShowSpellingErrors:= Result;
  end
  else
    Result := FShowSpellingErrors;
end;

function TOpWordDocument.GetShowSummary: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.ShowSummary;
    FShowSummary:= Result;
  end
  else
    Result := FShowSummary;
end;

function TOpWordDocument.GetSpellingChecked: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.SpellingChecked;
    FSpellingChecked:= Result;
  end
  else
    Result := FSpellingChecked;
end;

function TOpWordDocument.GetSubCollection(index: integer): TCollection;
begin
  result := nil;
  case index of
    0: Result := FDocumentBookmarks;
    1: Result := FDocumentTables;
    2: Result := FDocumentHyperLinks;
    3: Result := FDocumentShapes;
  end;
end;

function TOpWordDocument.GetSubCollectionCount: integer;
begin
  result:= 4;     {bookmarks, tables, hyperlinks, shapes}
end;

function TOpWordDocument.GetSummaryLength: Integer;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.SummaryLength;
    FSummaryLength:= Result;
  end
  else
    Result := FSummaryLength;
end;

function TOpWordDocument.GetSummaryViewMode: TOpWdSummaryMode;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := TOpWdSummaryMode(AsDocument.SummaryViewMode);
    FSummaryViewMode:= Result;
  end
  else
    Result := FSummaryViewMode;
end;

function TOpWordDocument.GetTrackRevisions: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.TrackRevisions;
    FTrackRevisions:= Result;
  end
  else
    Result := FTrackRevisions;
end;

function TOpWordDocument.GetUpdateStylesOnOpen: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.UpdateStylesOnOpen;
    FUpdateStylesOnOpen:= Result;
  end
  else
    Result := FUpdateStylesOnOpen;
end;

function TOpWordDocument.GetUserControl: WordBool;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsDocument.UserControl;
    FUserControl:= Result;
  end
  else
    Result := FUserControl;
end;

{: GetVerb places 2 MenuItems on the Collection Editor under TOpWordDocument}
function TOpWordDocument.GetVerb(index: integer): string;
begin
  case index of
    0: Result := 'Populate Mail Merge';
    1: Result := 'Execute Mail Merge';
    2: Result := 'Save';
  end;
end;

function TOpWordDocument.GetVerbCount: Integer;
begin
  if TOpWord(RootComponent).Connected then
    Result:= 3
  else
    Result:= 0;
end;


function TOpWordDocument.GetViewType: TOpWdViewType;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := TOpWdViewType(AsDocument.ActiveWindow.View.Type_);
    FViewType:= Result;
  end
  else
    Result := FViewType;
end;

procedure TOpWordDocument.insert(const Text: WideString; AtEnd: Boolean);
var
  OleStartRange, OleEndRange: OleVariant;
begin
  if (CheckActive(True,ctMethod)) then
  begin
    if AtEnd then
      AsDocument.Content.InsertAfter(Text)
    else
    case RangeLimit of
      wdrlParagraphs:
        begin
          OleStartRange:= AsDocument.Paragraphs.Item(RangeStart);
          OleEndRange:= AsDocument.Paragraphs.Item(RangeEnd);
          AsDocument.Range(OleStartRange, OleEndRange).InsertAfter(Text);
        end;
      wdrlSentences:
        begin
          OleStartRange:= AsDocument.Sentences.Item(RangeStart);
          OleEndRange:= AsDocument.Sentences.Item(RangeEnd);
          AsDocument.Range(OleStartRange, OleEndRange).InsertAfter(Text);
        end;
      wdrlWords:
        begin
          OleStartRange:= AsDocument.Words.Item(RangeStart);
          OleEndRange:= AsDocument.Words.Item(RangeEnd);
          AsDocument.Range(OleStartRange, OleEndRange).InsertAfter(Text);
        end;
      wdrlCharacters:
        begin
          OleStartRange:= RangeStart;
          OleEndRange:= RangeEnd;
          AsDocument.Range(OleStartRange, OleEndRange).InsertAfter(Text);
        end;
    end;
  end;
end;

procedure TOpWordDocument.InsertStrings(Lines: TStrings; AtEnd: Boolean);
var
  OleStartRange, OleEndRange: OleVariant;
begin
  if (CheckActive(True,ctMethod)) then
  begin
    if AtEnd then
      AsDocument.Content.InsertAfter(Lines.Text)
    else
    case RangeLimit of
      wdrlParagraphs:
        begin
          OleStartRange:= AsDocument.Paragraphs.Item(RangeStart);
          OleEndRange:= AsDocument.Paragraphs.Item(RangeEnd);
          AsDocument.Range(OleStartRange, OleEndRange).InsertAfter(Lines.Text);
        end;
      wdrlSentences:
        begin
          OleStartRange:= AsDocument.Sentences.Item(RangeStart);
          OleEndRange:= AsDocument.Sentences.Item(RangeEnd);
          AsDocument.Range(OleStartRange, OleEndRange).InsertAfter(Lines.Text);
        end;
      wdrlWords:
        begin
          OleStartRange:= AsDocument.Words.Item(RangeStart);
          OleEndRange:= AsDocument.Words.Item(RangeEnd);
          AsDocument.Range(OleStartRange, OleEndRange).InsertAfter(Lines.Text);
        end;
      wdrlCharacters:
        begin
          OleStartRange:= RangeStart;
          OleEndRange:= RangeEnd;
          AsDocument.Range(OleStartRange, OleEndRange).InsertAfter(Lines.Text);
        end;
    end;
  end;
end;

{: PopulateMailMerge opens the DataSource on the selected Word Document.
by retreiving the DataSource and SQL properties of the MailMerge instance of the document.}
procedure TOpWordDocument.PopulateMailMerge;
const
  ODBCDLL = '\ODBCCP32.DLL';
  ODBC_ADD_DSN = 1;
var
  Model: IOpModel;
  ConnectionStr, SQLText, VarT, VarF: OleVariant;
  TempFile: TextFile;
  i, Size: integer;
  SysDir, TempDir, TempFilePath: array[0..MAX_PATH] of char;
  LibHandle: THandle;
  Attrib, TempFileName: string;
  CurCur: TCursor;
  DocumentOwner : TOpWordDocuments;                                    {!!.64}
  BaseComponent : TOpWord;                                             {!!.64}
  OleSubType: OleVariant;                                              {!!.64}
  Separator : Char;                                                    {!!.64}
  Buffer: array[0..1] of Char;                                         {!!.64}
begin
  if (CheckActive(True,ctMethod)) then
  begin
    FMailMerge.SetDoc(AsDocument);
    CurCur := Screen.Cursor;
    Screen.Cursor := crHourglass;
    try
      Model := FMailMerge.FModel as IOpModel;
      if assigned(Model) then
      begin
        if GetTempPath(Sizeof(TempDir), TempDir) = 0 then
          RaiseLastWin32Error;
        if GetTempFileName(TempDir, 'Opw', 0, TempFilePath) = 0 then
          RaiseLastWin32Error;
        TempFileName := ChangeFileExt(TempFilePath, '.txt'); // ODBC is picky
        AssignFile(TempFile, TempFileName);
        Rewrite(TempFile);
        try
          try
            Model.BeginRead;
            try
              if GetLocaleInfo(GetThreadLocale, LOCALE_SLIST, Buffer, 2) > 0 then {!!.64}
                Separator := Buffer[0] else                            {!!.64}
              Separator := ',';                                        {!!.64}
              for i:= 0 to Model.ColCount - 1 do
              begin
                Write(TempFile, '"' + Model.ColHeaders[i] + '"');
                if i <> Model.ColCount - 1 then
                   Write(TempFile, Separator)                          {!!.64}
                else
                  Write(TempFile, #10);
              end;
              Model.First;
              while not Model.Eof do
              begin
                for i:= 0 to Model.ColCount - 1 do
                begin
                  Write(TempFile, Model.GetData(i, rmCell, Size));
                  if i <> Model.ColCount - 1 then
                    Write(TempFile, Separator)                         {!!.64}
                  else
                    Write(TempFile, #10);
                end;
                Model.Next;
              end;
            finally
              Model.EndRead;
            end;
          finally
            CloseFile(TempFile);
          end;
          VarT:= True;
          VarF:= False;
          GetSystemDirectory(SysDir, SizeOf(SysDir));
          StrLCat(SysDir, ODBCDLL, SizeOf(SysDir));
          LibHandle:= LoadLibrary(SysDir);
          if LIBHandle <> 0 then
          begin
            try
              Attrib:= SDSNOP + #0 + SDescODBC + #0 + SDefODBCDir + TempDir + #0 +
                 SODBCFileType + #0 + SMaxODBCRows + #0;
              @SQLConfigDataSource:= GetProcAddress(LibHandle, 'SQLConfigDataSource');
              if (@SQLConfigDataSource <> nil) then
                if SQLConfigDataSource(0, ODBC_ADD_DSN, PChar(SMSODBCTextDrv), PChar(Attrib)) <> 1 then
                  raise Exception.Create('SQLConfigDataSource failed');
            finally
              FreeLibrary(LibHandle);
            end;
          end;
          ConnectionStr:= SDSNOP;
          SQLText:= 'Select * from ' + ExtractFileName(TempFileName);
          FMailMerge.AsMailMerge.MainDocumentType:= wdFormLetters;
          (*The TOpWordDocument is owned by TOpWordDocuments which in turn
            is owned by The TOpWord Component. From the TOpWord component
            we can easily obtain the version of Office we are currently
            working with*)
          DocumentOwner := TOpWordDocuments(self.GetOwner);            {!!.64}
          BaseComponent := TOpWord(DocumentOwner.GetOwner);            {!!.64}
          OleSubType := wdMergeSubTypeWord2000;                        {!!.64}          
          if BaseComponent.FOfficeVersion = ovXP then                  {!!.64}
          begin                                                        {!!.64}
            (*this procedure is used only in XP*)
            FMailMerge.AsMailMerge.OpenDataSource('', emptyParam,emptyParam,  {!!.64}
            emptyParam, VarT, VarF, emptyParam, emptyParam, emptyParam,       {!!.64}
            emptyParam, emptyParam, ConnectionStr, SQLText, emptyParam,       {!!.64}
            emptyParam, OleSubType); //this last param makes difference       {!!.64}
          end                                                                 {!!.64}
          else                                                                {!!.64}
          begin                                                               {!!.64}
            (*this is the old procedure that was used by all versions of word
              up until the discovery that it did not work with XP*)
            FMailMerge.AsMailMerge.OpenDataSource2000('', emptyParam, {!!.62}
            emptyparam, emptyparam, VarT, VarF, emptyParam, emptyParam,
            emptyParam, emptyParam, emptyParam, ConnectionStr,
            SQLText, emptyParam);
          end;                                                                {!!.64}
        finally
          DeleteFile(TempFileName);
        end;
      end;
    finally
      Screen.Cursor := CurCur;
    end;
  end;
end;

procedure TOpWordDocument.Save;
begin
  if (CheckActive(True,ctMethod)) then
    AsDocument.Save;
end;

procedure TOpWordDocument.SaveAs(const FileName: string);
var
  OleFileFormat: OleVariant;
  OleFileName: OleVariant;
begin
  if (CheckActive(True,ctMethod)) then
  begin
    OleFileFormat:= integer(wdFormatDocument);
    OleFileName:= FileName;
    AsDocument.SaveAs2000(OleFileName, OleFileFormat, emptyParam,    {!!.62}
                      emptyParam, emptyParam, emptyParam, emptyParam,
                      emptyParam, emptyParam, emptyParam, emptyParam);
  end;
end;

procedure TOpWordDocument.SendMailWithOutLook(const WordSubject, SendTo,
   SendCC, SendBC: string; OutLookComp: TOpOutlook; AsAttachment: Boolean);
var
  MsgText, Attachments: TStringList;
begin
  if not (CheckActive(True,ctMethod)) then exit;
  if not (OutLookComp.Connected) then
   OutLookComp.Connected:= True;
  if AsAttachment then
  begin
    Attachments:= TStringList.Create;
    try
      Attachments.Add(DocFile);
      OutLookComp.SendMailMessage(SendTo, SendCC, SendBC, WordSubject, nil, Attachments);
    finally
      Attachments.Free;
    end;
  end
  else
    begin
      MsgText:= TStringList.Create;
      try
        MsgText.Add(AsDocument.Content.Text);
        OutLookComp.SendMailMessage(SendTo, SendCC, SendBC, WordSubject, MsgText, nil);
      finally
        MsgText.Free;
      end;
  end;
end;

procedure TOpWordDocument.SetAutoHyphenation(const Value: WordBool);
begin
  FAutoHyphenation := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.AutoHyphenation:= Value;
end;

procedure TOpWordDocument.SetCodeName(const Value: WideString);
begin
  FCodeName:= Value;
  if CheckActive(False,ctProperty) then
    AsDocument._CodeName:= Value;
end;

procedure TOpWordDocument.SetConsecutiveHyphensLimit(const Value: Integer);
begin
  FConsecutiveHyphensLimit := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.ConsecutiveHyphensLimit:= Value;
end;

procedure TOpWordDocument.SetDefaultTabStop(const Value: Single);
begin
  FDefaultTabStop := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.DefaultTabStop:= Value;
end;

procedure TOpWordDocument.SetDocFile(const Value: TFileName);
var
  DocFileVariant: OleVariant;
  DoNotSaveChanges: OleVariant;
  Count: Integer;
begin
  FDocFile := Value;
  if (CheckActive(False,ctProperty)) and (PropDirection = pdFromServer) and (Value <> '') then
  begin
    DocFileVariant:= Value;
    DoNotSaveChanges:= 0;
    Tables.Clear;
    HyperLinks.Clear;
    Bookmarks.Clear;
    Shapes.Clear;
    if assigned(Intf) then
    begin
      AsDocument.Close(DoNotSaveChanges, emptyParam, emptyParam);
    end;
    Intf:= TOpWord(RootComponent).FServer.Documents.OpenOld(DocFileVariant,
      emptyParam, emptyParam, emptyParam, emptyParam, emptyParam,
      emptyParam, emptyParam, emptyParam, emptyParam);
    {$IFDEF DCC6ORLATER}
    if (AsDocument.MailMerge.MainDocumentType) <>
      Int64(OpWrdXP.wdNotAMergeDocument) then                        {!!.62}
    {$ELSE}
    if (AsDocument.MailMerge.MainDocumentType) <>
      Integer(OpWrdXP.wdNotAMergeDocument) then                      {!!.62}
    {$ENDIF}
      FMailMerge.SetDoc(AsDocument);
    if AsDocument.Bookmarks.Count > 0 then
    begin
      for Count:= 0 to AsDocument.Bookmarks.Count - 1 do
      begin
        Bookmarks.Add;
      end;
    end;
    if AsDocument.Hyperlinks.Count > 0 then
    begin
      for count:= 0 to AsDocument.Hyperlinks.Count - 1 do
      begin
        HyperLinks.Add;
      end;
    end;
    if AsDocument.Tables.Count > 0 then
    begin
      for count:= 0 to AsDocument.Tables.Count - 1 do
      begin
        Tables.Add;
      end;
    end;
    if AsDocument.Shapes.Count > 0 then
    begin
      for count:= 0 to AsDocument.Shapes.Count - 1 do
      begin
        Shapes.Add;
      end;
    end;
  end;
end;

procedure TOpWordDocument.SetRangeLimit(const Value: TOpWdRangeLimit);
begin
  FDocRangeLimit := Value;
end;

procedure TOpWordDocument.SetDocumentKind(const Value: TOpWdDocumentKind);
begin
  FDocumentKind:= Value;
  if CheckActive(False,ctProperty) then
  begin
    case Value of
      wddkNotSpecified: AsDocument.Kind:= Integer(wddkNotSpecified);
      wddkLetter: AsDocument.Kind:= Integer(wddkLetter);
      wddkEmail: AsDocument.Kind:= Integer(wddkEmail);
    end;
  end;
end;

procedure TOpWordDocument.SetEmbedTrueTypeFonts(const Value: WordBool);
begin
  FEmbedTrueTypeFonts := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.EmbedTrueTypeFonts:= Value;
end;

procedure TOpWordDocument.SetGrammarChecked(const Value: WordBool);
begin
  FGrammarChecked := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.GrammarChecked:= Value;
end;

procedure TOpWordDocument.SetHasRoutingSlip(const Value: WordBool);
begin
  FHasRoutingSlip := Value;
  try
  if CheckActive(False,ctProperty) then
    AsDocument.HasRoutingSlip:= Value;
  except
  end;
end;

procedure TOpWordDocument.SetHyphenateCaps(const Value: WordBool);
begin
  FHyphenateCaps := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.HyphenateCaps:= Value;
end;

procedure TOpWordDocument.SetHyphenationZone(const Value: Integer);
begin
  FHyphenationZone := Value;
  if CheckActive(False,ctProperty) then
    (Intf as _Document).HyphenationZone:= Value;
end;

procedure TOpWordDocument.SetMailMerge(const Value: TOpMailMerge);
begin
  FMailMerge := Value;
end;

procedure TOpWordDocument.SetPrintFormsData(const Value: WordBool);
begin
  FPrintFormsData := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.PrintFormsData:= Value;
end;

procedure TOpWordDocument.SetPrintPostScriptOverText(const Value: WordBool);
begin
  FPrintPostScriptOverText := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.PrintPostScriptOverText:= Value;
end;

procedure TOpWordDocument.SetPrintRevisions(const Value: WordBool);
begin
  FPrintRevisions := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.PrintRevisions:= Value;
end;

procedure TOpWordDocument.SetReadOnlyRecommended(const Value: WordBool);
begin
  FReadOnlyRecommended := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.ReadOnlyRecommended:= Value;
end;

procedure TOpWordDocument.SetSaved(const Value: WordBool);
begin
  FSaved := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.Saved:= Value;
end;

procedure TOpWordDocument.SetSaveFormsData(const Value: WordBool);
begin
  FSaveFormsData := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.SaveFormsData:= Value;
end;

procedure TOpWordDocument.SetSaveSubsetFonts(const Value: WordBool);
begin
  FSaveSubsetFonts := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.SaveSubsetFonts:= Value;
end;

procedure TOpWordDocument.SetShowGrammaticalErrors(const Value: WordBool);
begin
  FShowGrammaticalErrors := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.ShowGrammaticalErrors:= Value;
end;

procedure TOpWordDocument.SetShowRevisions(const Value: WordBool);
begin
  FShowRevisions := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.ShowRevisions:= Value;
end;

procedure TOpWordDocument.SetShowSpellingErrors(const Value: WordBool);
begin
  FShowSpellingErrors := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.ShowSpellingErrors:= Value;
end;

procedure TOpWordDocument.SetSpellingChecked(const Value: WordBool);
begin
  FSpellingChecked := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.SpellingChecked:= Value;
end;


procedure TOpWordDocument.SetSummary(const Value: WordBool);
begin
  FShowSummary := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.ShowSummary:= Value;
end;

procedure TOpWordDocument.SetSummaryLength(const Value: Integer);
begin
  FSummaryLength := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.SummaryLength:= Value;
end;

procedure TOpWordDocument.SetSummaryViewMode(const Value: TOpWdSummaryMode);
begin
  FSummaryViewMode := Value;
  if CheckActive(False,ctProperty) then
  begin
    case Value of
      wdsmHighlight: AsDocument.SummaryViewMode:= integer(wdSummaryModeHighlight);
      wdsmHideAllButSummary: AsDocument.SummaryViewMode:= integer(wdSummaryModeHideAllButSummary);
      wdsmInsert: AsDocument.SummaryViewMode:= integer(wdSummaryModeInsert);
      wdsmCreateNew: AsDocument.SummaryViewMode:= integer(wdSummaryModeCreateNew);
    end;
  end;
end;

procedure TOpWordDocument.SetTrackRevisions(const Value: WordBool);
begin
  FTrackRevisions := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.TrackRevisions:= Value;
end;

procedure TOpWordDocument.SetUpdateStylesOnOpen(const Value: WordBool);
begin
  FUpdateStylesOnOpen := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.UpdateStylesOnOpen:= Value;
end;

procedure TOpWordDocument.SetUserControl(const Value: WordBool);
begin
  FUserControl := Value;
  if CheckActive(False,ctProperty) then
    AsDocument.UserControl:= Value;
end;

procedure TOpWordDocument.SetViewType(const Value: TOpWdViewType);
begin
  FViewType:= Value;
  if CheckActive(False,ctProperty) then
  begin
    case Value of
      wdvtNormalView: AsDocument.ActiveWindow.View.Type_:= integer(wdNormalView);
      wdvtOutlineView: AsDocument.ActiveWindow.View.Type_:= integer(wdOutlineView);
      wdvtPrintView: AsDocument.ActiveWindow.View.Type_:= integer(wdPrintView);
      wdvtPrintPreview: AsDocument.ActiveWindow.View.Type_:= integer(wdPrintPreview);
      wdvtMasterView: AsDocument.ActiveWindow.View.Type_:= integer(wdMasterView);
      wdvtWebView: AsDocument.ActiveWindow.View.Type_:= integer(wdWebView);
    end;
  end;
end;

procedure TOpWordDocument.Print;
begin
  if (CheckActive(True,ctMethod)) then
  begin
    AsDocument.PrintOutOld(emptyParam, emptyParam, emptyParam, emptyParam, emptyParam,
       emptyParam, emptyParam, emptyParam, emptyParam, emptyParam, emptyParam, emptyParam, emptyParam, emptyParam);
  end;
end;

function TOpWordDocument.GetAsDocument: _Document;
begin
  CheckActive(True,ctProperty);
  Result := (Intf as _Document);
end;

function TOpWordDocument.Find(const FindText: string; Forward: Boolean): Boolean;
var
  OleFindText, OleForward: OleVariant;
begin
  if (CheckActive(True,ctMethod)) then
  begin
    FFindText := FindText;
    OleFindText := FFindText;
    OleForward := Forward;
    FFindRange := AsDocument.Content;
    result := FFindRange.Find.ExecuteOld(OleFindText, emptyParam, emptyParam, emptyParam, emptyParam,
      emptyParam, OleForward, emptyParam, emptyParam, emptyParam, emptyParam);
    if FFindRange.Find.Found then
    begin
      (RootComponent as TOpWord).Server.Activate;
      FFindRange.Select;
    end;
  end
  else
    result:= False;
end;

function TOpWordDocument.FindNext: Boolean;                            {!!.61}
var
//  FindRange: OpWrd2K.Range;                                          {!!.61}
  OleFindText: OleVariant;
begin
  if (CheckActive(True,ctMethod)) then
  begin
    OleFindText := FFindText;
//    FFindRange := AsDocument.Content;                                {!!.61}
    result := FFindRange.Find.ExecuteOld(OleFindText, emptyParam, emptyParam, emptyParam, emptyParam,
      emptyParam, emptyParam, emptyParam, emptyParam, emptyParam, emptyParam);
    if FFindRange.Find.Found then
    begin
      (RootComponent as TOpWord).Server.Activate;
      FFindRange.Select;
    end;
  end
  else
    Result:= False;
end;

function TOpWordDocument.Replace(const FindText, ReplaceText: string;
  Forward: Boolean; ReplaceOption: TOpWdReplaceOption): Boolean;
var
  OleFindText, OleForward, OleReplaceText, OleReplaceOption: OleVariant;
begin
  if (CheckActive(True,ctMethod)) then
  begin
    OleFindText:= FindText;
    OleForward:= Forward;
    OleReplaceText:= ReplaceText;
    OleReplaceOption:= ReplaceOption;
    Result:= AsDocument.Content.Find.ExecuteOld(OleFindText, emptyParam,
      emptyParam, emptyParam, emptyParam, emptyParam, OleForward,
      emptyParam, emptyParam, OleReplaceText, OleReplaceOption);
  end
  else
    result:= False;
end;

{ TOpWordDocuments }

function TOpWordDocuments.Add: TOpWordDocument;
begin
  Result := TOpWordDocument(inherited Add);
end;

function TOpWordDocuments.GetItem(Index: Integer): TOpWordDocument;
begin
  Result := TOpWordDocument(inherited GetItem(Index));
end;

function TOpWordDocuments.GetItemName: string;
begin
  result:= 'Document';
end;

procedure TOpWordDocuments.SetItem(Index: Integer; const Value: TOpWordDocument);
begin
  inherited SetItem(Index, Value);
end;

{ TOpDocumentBookmark }

procedure TOpDocumentBookmark.Activate;
begin
  if assigned(Intf) then (Intf as Bookmark).Select;
end;

function TOpDocumentBookmark.GetBookMarkName: WideString;
begin
  result:= FBookMarkName;
end;

function TOpDocumentBookmark.GetSubCollection(index: integer): TCollection;
begin
  result:= nil;
end;

function TOpDocumentBookmark.GetSubCollectionCount: integer;
begin
  result:= 0;
end;

function TOpDocumentBookmarks.Add: TOpDocumentBookmark;
begin
  Result := TOpDocumentBookmark(inherited Add);
end;

function TOpDocumentBookmarks.GetItem(Index: Integer): TOpDocumentBookmark;
begin
  Result := TOpDocumentBookmark(inherited GetItem(Index));
end;

function TOpDocumentBookmarks.GetItemName: string;
begin
  result:= 'Bookmark';
end;

procedure TOpDocumentBookmarks.SetItem(Index: Integer; Value: TOpDocumentBookmark);
begin
   inherited SetItem(Index, Value);
end;

procedure TOpDocumentBookmark.SetBookmarkName(const Value: WideString);
begin
  FBookmarkName:= Value;
end;

{ TOpDocumentTable }

procedure TOpDocumentTable.Activate;
begin
  if assigned(Intf) then (Intf as Table).Select;
end;

function TOpDocumentTable.GetSubCollection(index: integer): TCollection;
begin
  result := nil;
end;

function TOpDocumentTable.GetSubCollectionCount: integer;
begin
  result:= 0;
end;

{: PopulateDocTable allows for the creation of a Word Table manipulated by a TOpOfficeModel}
procedure TOpDocumentTable.PopulateDocTable;
var
  Model: IOpModel;
  tbl: Table;
  i, col: integer;
  TableCell: Cell;
  Size: integer;
begin
    if not((RootComponent as TOpOfficeComponent).Connected) then exit;
    Screen.Cursor := crHourglass;
    try
      Model := FModel as IOpModel;
      if assigned(Model) then
      begin
        Model.BeginRead;
        (RootComponent as TOpWord).Server.ScreenUpdating := false;
        tbl:= (ParentItem.Intf as _Document).Tables.AddOld((ParentItem.Intf as _Document).Characters.Last,
         1, Model.ColCount);
        Self.Intf := tbl;                                              {!!.61}
        for i:= 0 to Model.ColCount - 1 do
        begin
          TableCell:= tbl.Cell(1,i + 1);
          TableCell.Range.Text:= Model.ColHeaders[i];
          TableCell.Range.Bold:= 1;
        end;
        Model.First;
        while not Model.Eof do
        begin
          tbl.Rows.Add(emptyParam);
          for Col := 0 to Model.ColCount - 1 do
          begin
            TableCell:= tbl.Cell(tbl.Rows.Count, col + 1);
            TableCell.Range.Text:= Model.GetData(col, rmCell, Size);
            TableCell.Range.Bold:= 0;
          end;
          Model.Next;
        end;
        tbl.Columns.AutoFit;
        Model.EndRead;
      end;
    finally
      (RootComponent as TOpWord).Server.ScreenUpdating:= true;
      Screen.Cursor := crDefault;
    end;
end;

{: RePopulateDocTable updates an existing Word Table manipulated by a TOpOfficeModel}
procedure TOpDocumentTable.RePopulateDocTable;
var
  Model: IOpModel;
  tbl: Table;
  i, col: integer;
  TableCell: Cell;
  Size: integer;
begin
    if not((RootComponent as TOpOfficeComponent).Connected) then exit;
    Screen.Cursor := crHourglass;
    try
      Model := FModel as IOpModel;
      if assigned(Model) then
      begin
        Model.BeginRead;
        (RootComponent as TOpWord).Server.ScreenUpdating := false;
        tbl:= Self.Intf as Table;
        for i:= 0 to Model.ColCount - 1 do
        begin
          TableCell:= tbl.Cell(1,i + 1);
          TableCell.Range.Text:= Model.ColHeaders[i];
          TableCell.Range.Bold:= 1;
        end;
        Model.First;
        while not Model.Eof do
        begin
          for Col := 0 to Model.ColCount - 1 do
            begin
              TableCell := tbl.Cell(Model.CurrentRow + 2, col + 1);
              TableCell.Range.Text:= Model.GetData(col, rmCell, Size);
              TableCell.Range.Bold:= 0;
            end;
          Model.Next;
        end;
        tbl.Columns.AutoFit;
        Model.EndRead;
      end;
    finally
      (RootComponent as TOpWord).Server.ScreenUpdating:= true;
      Screen.Cursor := crDefault;
    end;
end;

procedure TOpDocumentTable.ExecuteVerb(index: Integer);
begin
  if index = 0 then
    PopulateDocTable;
end;

function TOpDocumentTable.GetVerb(index: integer): string;
begin
  if index = 0 then
    Result:= 'PopulateTableModel';
end;

function TOpDocumentTable.GetVerbCount: Integer;
begin
  if TOpWord(RootComponent).Connected then
    Result:= 1
  else
    Result:= 0;
end;

procedure TOpDocumentTable.SetModel(Value: TOpUnknownComponent);
begin
  if Value <> nil then Value.FreeNotification(self.RootComponent);
  FModel := Value;
end;

{ TOpDocumentTables }

function TOpDocumentTables.Add: TOpDocumentTable;
begin
  Result := TOpDocumentTable(inherited Add);
end;


function TOpDocumentTables.GetItem(Index: Integer): TOpDocumentTable;
begin
  Result := TOpDocumentTable(inherited GetItem(Index));
end;


function TOpDocumentTables.GetItemName: string;
begin
  result:= 'Table';
end;

procedure TOpDocumentTables.SetItem(Index: Integer; Value: TOpDocumentTable);
begin
  inherited SetItem(Index, Value);
end;

{ TOpDocumentHyperLink }

procedure TOpDocumentHyperLink.Activate;
begin
  if assigned(Intf) then
  begin
    (ParentItem.Intf as _Document).Activate;
    (Intf as Hyperlink).Range.Select;
  end;
end;

procedure TOpDocumentHyperLink.ExecuteVerb(index: Integer);
begin
  if index = 0 then
    FollowHyperlink;
end;

procedure TOpDocumentHyperLink.FollowHyperLink;
var
  OleNewWindow: OleVariant;
begin
  if CheckActive(True,ctMethod) then
  begin
    OleNewWindow:= FNewWindow;
    (Intf as HyperLink).Follow(OleNewWindow, emptyParam, emptyParam, emptyParam, emptyParam);
  end;
end;

function TOpDocumentHyperLink.GetAddress: WideString;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := (Intf as HyperLink).AddressOld;
    FAddress:= Result;
  end
  else
    Result := FAddress;
end;


function TOpDocumentHyperLink.GetSubCollection(index: integer): TCollection;
begin
 result:= nil;
end;

function TOpDocumentHyperLink.GetSubCollectionCount: integer;
begin
  result:= 0;
end;

function TOpDocumentHyperLink.GetVerb(index: integer): string;
begin
 if index = 0 then
   Result:= 'Follow';
end;

function TOpDocumentHyperLink.GetVerbCount: Integer;
begin
  if TOpWord(RootComponent).Connected then
    Result:= 1
  else
    Result:= 0;
end;

procedure TOpDocumentHyperLink.SetAddress(const Value: WideString);
begin
  FAddress:= Value;
  if CheckActive(False,ctProperty) then
    if (TOpWord(RootComponent).OfficeVersion = ov2000) or
       (TOpWord(RootComponent).OfficeVersion = ovXP) then            {!!.63}
      (Intf as HyperLink).Address:= Value
    else
      ShowMessage(SHyperlinkLinkAddress);
end;

procedure TOpDocumentHyperLink.SetNewWindow(const Value: Boolean);
begin
  FNewWindow:= Value;
end;

{ TOpDocumentHyperLinks }

function TOpDocumentHyperLinks.Add: TOpDocumentHyperLink;
begin
  Result := TOpDocumentHyperLink(inherited Add);
end;

function TOpDocumentHyperLinks.GetItem(Index: Integer): TOpDocumentHyperLink;
begin
  Result := TOpDocumentHyperLink(inherited GetItem(Index));
end;

function TOpDocumentHyperLinks.GetItemName: string;
begin
  result:= 'HyperLink';
end;

procedure TOpDocumentHyperLinks.SetItem(Index: Integer; Value: TOpDocumentHyperLink);
begin
  inherited SetItem(Index, Value);
end;

{ TOpDocumentShapes }

function TOpDocumentShapes.Add: TOpDocumentShape;
begin
  Result := TOpDocumentShape(inherited Add);
end;

function TOpDocumentShapes.GetItem(Index: Integer): TOpDocumentShape;
begin
  Result := TOpDocumentShape(inherited GetItem(Index));
end;

function TOpDocumentShapes.GetItemName: string;
begin
  result:= 'Shape';
end;

procedure TOpDocumentShapes.SetItem(Index: Integer; Value: TOpDocumentShape);
begin
  inherited SetItem(Index, Value);
end;

{ TOpDocumentShape }

procedure TOpDocumentShape.Activate;
begin
  if assigned(Intf) then (Intf as OpWrdXP.Shape).Select(emptyParam);
end;

procedure TOpDocumentShape.AddTextBox;
begin
  if CheckActive(True,ctMethod) then
  begin
    intf:= (ParentItem.Intf as _Document).Shapes.AddShape(Integer(OpOfcXP.msoTextBox),  {!!.62}
      FLeft, FTop, FWidth, FHeight, emptyParam);
  end;
end;

procedure TOpDocumentShape.Connect;
begin
  inherited Connect;
  case (ParentItem as TOpWordDocument).PropDirection of
    pdToServer:   begin
                    ShapeName:= FShapeName;
                    Top := FTop;
                    Left := FLeft;
                    Width := FWidth;
                    Height := FHeight;
                  end;
    pdFromServer: begin
                    FShapeName:= ShapeName;
                    FTop := Top;
                    FLeft := Left;
                    FWidth := Width;
                    FHeight := Height;
                  end;
  end;
end;

constructor TOpDocumentShape.create(Collection: TCollection) ;
begin
  inherited create(Collection);
  if (TOpWordDocument(ParentItem).PropDirection = pdToServer) then
  begin
    FLeft:= 100;
    FTop:= 50;
    FWidth:= 100;
    FHeight:= 50;
  end;
end;

procedure TOpDocumentShape.ExecuteVerb(index: Integer);
begin
  if index = 0 then
    AddTextBox;
end;

function TOpDocumentShape.GetSubCollection(index: integer): TCollection;
begin
   result:= nil;
end;

function TOpDocumentShape.GetSubCollectionCount: integer;
begin
  result:= 0;
end;

function TOpDocumentShape.GetVerb(index: integer): string;
begin
  if index = 0 then
    result:= 'AddShape';
end;

function TOpDocumentShape.GetVerbCount: Integer;
begin
  if TOpWord(RootComponent).Connected then
    Result:= 1
  else
    Result:= 0;
end;


procedure TOpDocumentShape.SetHeight(const Value: Single);
begin
  if FHeight <> Value then
  begin
    FHeight := Value;
    if Assigned(intf) then
    begin
      (Intf as OpWrdXP.Shape).Height:= FHeight;                      {!!.62}
    end;
  end;
end;

procedure TOpDocumentShape.SetLeft(const Value: Single);
begin
  if FLeft <> Value then
  begin
    FLeft := Value;
    if Assigned(intf) then
    begin
      (Intf as OpWrdXP.Shape).Left:= FLeft;                          {!!.62}
    end;
  end;
end;

procedure TOpDocumentShape.SetShapeName(const Value: WideString);
begin
  if FShapeName <> Value then
  begin
    FShapeName := Value;
    if Assigned(intf) then
    begin
      (Intf as OpWrdXP.Shape).Name:= FShapeName;                     {!!.62}
    end;
  end;
end;

procedure TOpDocumentShape.SetTop(const Value: Single);
begin
  if FTop <> Value then
  begin
    FTop := Value;
    if Assigned(intf) then
    begin
      (Intf as OpWrdXP.Shape).Top:= FTop;                            {!!.62}
    end;
  end;
end;

procedure TOpDocumentShape.SetWidth(const Value: Single);
begin
  if FWidth <> Value then
  begin
    FWidth := Value;
    if Assigned(intf) then
    begin
      (Intf as OpWrdXP.Shape).Width:= FWidth;                        {!!.62}
    end;
  end;
end;


{ TOpMailMerge }
procedure TOpMailMerge.SetDoc(Doc: _Document);
begin
  FIntf := Doc.MailMerge;
end;

procedure TOpMailMerge.SetModel(const Value: TOpUnknownComponent);
begin
  FModel := Value;
end;

end.
