unit ClientLookupFme;
//------------------------------------------------------------------------------
{
   Title:       Client File Lookup Frame

   Description: Frame is designed to be used by any dialog that requires the
                selection of clients

   Author:      Matthew Hopkins Mar 2003

   Remarks:     Uses a intermediate list to hold each line of the grid
                This allows us to read the file list for offsite clients
                and for admin system clients
}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, VirtualTrees, cfList32, eCollect, syDefs, sysObj32, bkconst,
  StDate,
  ClientCodingStatistics, BankLinkOnlineServices,
  Menus, ExtCtrls, WebCiCoClient;

type
//  TBankLinkOnlineMode = (bomNone, bomGetFile, bomSendFile);
  TFrameUseMode    = (fumNone, fumOpenFile, fumGetFile, fumSendFile, fumGetOnline, fumSendOnline);
  TSelectedMode    = ( smSingle, smMultiple);
  TFilterMode      = ( fmNoFilter, fmFilesForCheckIn, fmFilesForCheckOut, fmAvailableFiles,
                       fmUpdateableFiles);
  TLookupOption    = ( loShowNotesImage);
  TLookupOptions   = set of TLookupOption;

  //simple implemenation of a column object
  TClientLookupCol = ( cluCode,
                       cluName,
                       cluAction,
                       cluReminderDate,
                       cluStatus,
                       cluUser,
                       cluReportingPeriod,
                       cluSendBy,
                       cluLastAccessed,
                       cluFinYearStarts,
                       cluContactType,
                       cluUnknown,
                       cluType,
                       cluProcessing,
                       cluStarts,
                       cluGroup,
                       cluClientType,
                       cluNextGSTDue,
                       cluBankLinkOnline,
                       cluModifiedDate,
                       cluBOProduct,
                       cluBOBillingFrequency,
                       cluBOUserAdmin,
                       cluBOAccess
                       );

  TCluColumnDefn = class
  public
    Caption       : string;
    DefaultWidth  : integer;
    DefaultPos    : integer;
    FieldID       : TClientLookupCol;
    DisplayPos    : integer;
    DisplayWidth  : integer;
    Visible       : Boolean;
    Color         : TColor;
    ProdIndex     : Integer;
    ProdGuid      : TBloGuid;
  end;

  TCluColumnList = class( TList)
  public
    function ColumnDefn_At( i : integer) : TCluColumnDefn;

    function GetColumnFieldID( aColumnNo : integer) : TClientLookupCol;
    function FindColumnIndex( aLookupCol : TClientLookupCol) : integer;
  end;

  //implemented the intermediateData list as a list of records rather than
  //objects so that access is faster
  pIntermediateDataRec = ^TIntermediateDataRec;
  TIntermediateDataRec = record
    imCode    : string[20];
    imName    : string[60];
    imGroupID : integer;
    imSortKey : string[10];
    imData    : pointer;
    imTag     : integer;
    imType    : Byte;
    imSendMethod      : Byte;
    imOnlineStatus    : TClientFileStatus;
    imOnlineStatusDesc: string[60];
    imModifiedDate    : TDateTime;
  end;

  TIntermediateDataList = class(TExtdCollection) //not sorted
  protected
    procedure FreeItem     (Item : Pointer); override;
  public
    function  IntermediateData_At(Index : integer) : pIntermediateDataRec;
    function  Add : pIntermediateDataRec;
  end;

type
  pTreeData = ^tTreeData;
  tTreeData  = record
    tdNodeType  : integer;
    tdFolderID  : integer;
    tdData      : pointer;
  end;

  type
  ClientStat = record
     Transferred : array [1..12] of TResultType;
     Finalized : array [1..12] of TResultType;
     Coded : array [1..12] of TResultType;
     Downloaded : array [1..12] of TResultType;
  end;

type
  TfmeClientLookup = class(TFrame)
    vtClients: TVirtualStringTree;
    popDelete: TPopupMenu;
    mniDelete: TMenuItem;
    BtnLeft: TButton;
    BtnRight: TButton;
    procedure vtClientsGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure vtClientsPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure vtClientsCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure vtClientsHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure vtClientsChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vtClientsIncrementalSearch(Sender: TBaseVirtualTree;
      Node: PVirtualNode; const SearchText: WideString;
      var Result: Integer);
    procedure vtClientsBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect);
    procedure vtClientsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure vtClientsKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure vtClientsShortenString(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      const S: WideString; TextSpace: Integer; RightToLeft: Boolean;
      var Result: WideString; var Done: Boolean);
    procedure vtClientsBeforeItemPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
      var CustomDraw: Boolean);
    procedure vtClientsCollapsing(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var Allowed: Boolean);
    procedure vtClientsAfterCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect);
    procedure vtClientsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure vtClientsKeyPress(Sender: TObject; var Key: Char);
    procedure mniDeleteClick(Sender: TObject);
    procedure popDeletePopup(Sender: TObject);
    procedure vtClientsGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure vtClientsHeaderDraw(Sender: TVTHeader; HeaderCanvas: TCanvas;
      Column: TVirtualTreeColumn; R: TRect; Hover, Pressed: Boolean;
      DropMark: TVTDropMarkMode);
    procedure vtClientsScroll(Sender: TBaseVirtualTree; DeltaX,
      DeltaY: Integer);
    procedure BtnRightClick(Sender: TObject);
    procedure BtnLeftClick(Sender: TObject);
    function IncludeClientInList(ASendMethod: Byte): Boolean;
  private
    { Private declarations }
    FUsingAdminSystem : boolean;
    FSelectedColumn   : TClientLookupCol;
    FIntermediateDataList : TIntermediateDataList;
    FViewMode: TViewMode;
    FSelectMode: TSelectedMode;
    FOnSelectionChanged: TNotifyEvent;
    FColumns : TCluColumnList;
    FFilterMode: TFilterMode;
    FSubFilter: UInt64;
    FUserFilter: TStringList;
    FGroupFilter: TStringList;
    FClientTypeFilter: TStringList;
    FClientFilter: Byte;
    FFilesDirectory: string;
    FArrowKeyDown : boolean;
    FOptions: TLookupOptions;
    FOnNotesClick: TNotifyEvent;
    FOnSortChanged: TNotifyEvent;
    FSortType: Byte;

    FClientCodesList : TStringList;
    FClientNamesList : TStringList;
    FOnKeyPress: TKeyPressEvent;

    FShowPopMenu: Boolean;

    CurrentSearchKey : ShortString;
    LastSearchTime: TdateTime;
    FProcessStatusUpdateNeeded: Boolean;
    FLastScrollPosition: Integer;
    FSearchText: String;
    FProcStatOffset: Integer;
    FProcStatDate: Integer;
    FOnUpdateCount: TNotifyEvent;
    FSeverResponce : TServerResponse;
    FNoOnlineConnection: boolean;
//    FClient: Client;
    FFrameUseMode: TFrameUseMode;
    FServerResponse: TServerResponse;
    FClientStatusList: TClientStatusList;
    procedure LoadNodes( ReloadData : boolean);
    procedure LoadColumns;
    procedure RefreshData;
    procedure SetGroupIDs;
    procedure SetViewMode(const Value: TViewMode);

    function GetIntermediateDataFromNode( aNode : pVirtualNode) : pIntermediateDataRec;
    function GetSysClientDataFromNode( aNode : pVirtualNode) : syDefs.pClient_File_Rec;
    function GetSelectedCodes: string;
    procedure SetSelectMode(const Value: TSelectedMode);
    procedure SetOnSelectionChanged(const Value: TNotifyEvent);
    function GetSelectionCount: integer;
    function GetClientCount: integer;
    procedure SetOnGridDblClick(const Value: TNotifyEvent);
    function GetOnGridDblClick: TNotifyEvent;
    procedure SetOnGridColumnMoved(const Value: TVTHeaderDraggedEvent);
    function GetOnGridColumnMoved: TVTHeaderDraggedEvent;
    procedure SetFilterMode(const Value: TFilterMode);
    procedure SetSubFilter(const Value: UInt64);
    procedure SetUserFilter(const Value: TStringList);
    procedure SetGroupFilter(const Value: TStringList);
    procedure SetClientTypeFilter(const Value: TStringList);
    procedure SetClientFilter(const Value: Byte);
    procedure SetFilesDirectory(const Value: string);
    procedure SetOptions(const Value: TLookupOptions);
    procedure SetOnNotesClick(const Value: TNotifyEvent);
    function GetSysClientRec(Sender: TBaseVirtualTree; Node: PVirtualNode): pClient_File_Rec;
    procedure SetSelectedCodes(const Value: string);
    function GetFirstSelectedCode: string;
    function GetFirstSelectedName: string;
    procedure SetOnSortChanged(const Value: TNotifyEvent);
    function GetColumnCount: integer;
    procedure SetOnKeyPress(const Value: TKeyPressEvent);
    procedure DoNewSearch;
    function ClosestMatch(SearchList: TStringList;
      aKey: ShortString): string;
    function HasMatch(SearchList: TStringList; aKey: ShortString): boolean;
    function GetSortDirection: TSortDirection;
    procedure SetShowPopMenu(Value: Boolean);
//    function GetProcessingHint(Offset: TPoint; Node: PVirtualNode): string;
    procedure CMShowingChanged(var M: TMessage); message CM_SHOWINGCHANGED;
    function GetClientStat(sysClientRec: pClient_File_Rec; ForDate: TSTDate):ClientStat;
    procedure SetProcessStatusUpdateNeeded(const Value: Boolean);
    procedure SetSearchText(const Value: String);
    function GetProcStatDate: Integer;
    procedure SetProcStatOffset(const Value: Integer);
    procedure SetHeaderHeight(Processing: Boolean);
    procedure SetOnUpdateCount(const Value: TNotifyEvent);
    procedure UpdateCount;
    procedure UpdateOnlineStatus;
    procedure SetNoOnlineConnection(const Value: boolean);
    procedure DoStatusProgress(APercentComplete : integer;
                               AMessage         : string);
    procedure InvalidPasswordDlg(AttemptCount: integer);
//    procedure SetOnlineMode(const Value: TBankLinkOnlineMode);
    procedure SetFrameUseMode(const Value: TFrameUseMode);
    procedure SetServiceResponse(const Value: TServerResponse);
    procedure SetClientStatusList(const Value: TClientStatusList);
  public
    { Public declarations }
    AdminSnapshot : TSystemObj;
    procedure DoCreate;
    destructor  Destroy; override;

    procedure ClearColumns;
    function AddColumn( aCaption : string; aDefaultWidth : integer; aFieldID : TClientLookupCol) : TCluColumnDefn;
    function AddColumnEx( aFieldID : TClientLookupCol; aCaption : string;
                          aDefaultWidth : integer; aDefaultPos : integer;
                          aUserWidth : integer; aUserPos : integer; visible: Boolean;
                          aProdIndex : Integer = -1;
                          aProdGuid : TBloGuid = ''): TCluColumnDefn;
    procedure BuildGrid( const SelectColumn : TClientLookupCol; const SortDirection: TSortDirection = sdAscending);
    procedure LocateCode( aCode : string);
    procedure SetFocusToGrid;
    procedure Reload;
    procedure ResetColumns;
    procedure ClearSelection;

    procedure vtClientsGetTextEx(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; cID: TClientLookupCol; ProcAsText: Boolean;
      var CellText: WideString);

    property ViewMode : TViewMode read FViewMode write SetViewMode;
    property SelectMode : TSelectedMode read FSelectMode write SetSelectMode;
    property FilterMode : TFilterMode read FFilterMode write SetFilterMode;
    property SubFilter : UInt64 read FSubFilter write SetSubFilter;
    property UserFilter : TStringList read FUserFilter write SetUserFilter;
    property GroupFilter : TStringList read FGroupFilter write SetGroupFilter;
    property ClientTypeFilter : TStringList read FClientTypeFilter write SetClientTypeFilter;
    property ClientFilter : Byte read FClientFilter write SetClientFilter;
    property FilesDirectory : string read FFilesDirectory write SetFilesDirectory;
    property Options : TLookupOptions read FOptions write SetOptions;

    function FindColumnIndex( aFieldID : TClientLookupCol) : integer;
    function GetColumnPosition( aColIndex : integer) : integer; overload;
    function GetColumnPosition( aFieldID : TClientLookupCol) : integer; overload;
    function GetColumnWidth( aColIndex : integer) : integer; overload;
    function GetColumnWidth( aFieldID : TClientLookupCol) : integer; overload;
    function GetColumnVisibility( aColIndex : integer) : boolean; overload;
    function GetColumnVisibility( aFieldID : TClientLookupCol) : boolean; overload;
    function GetColumnCaption( aColIndex : integer) : string; overload;
    function GetColumnCaption( aFieldID : TClientLookupCol) : string; overload;
    function GetColumnID( ColumnNo : integer) : TClientLookupCol;
    function GetColumnIDByPosition(ColumnNo: integer): TClientLookupCol;
    function GetSortedByText : string;
    function GetCodeBelowSelection: string;
    function IsUnCoded(SysClientRec: pClient_File_Rec; Ondate: Integer): boolean;
    procedure SetColumnVisiblity(aFieldID: TClientLookupCol; Status: Boolean);

    procedure GetSelectionTypes(var Prospect, Active, Unsync: Boolean);
    procedure GetArchiveStates(var Unarchived, Archived: Boolean);
    procedure FilterBySearchKeys(Value: String);

    property SelectedCodes : string read GetSelectedCodes write SetSelectedCodes;
    property FirstSelectedCode : string read GetFirstSelectedCode;
    property FirstSelectedName : string read GetFirstSelectedName;
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write SetOnSelectionChanged;
    property OnGridDblClick : TNotifyEvent read GetOnGridDblClick write SetOnGridDblClick;
    property OnGridColumnMoved : TVTHeaderDraggedEvent read GetOnGridColumnMoved write SetOnGridColumnMoved;
    property OnNotesClick : TNotifyEvent read FOnNotesClick write SetOnNotesClick;
    property OnSortChanged : TNotifyEvent read FOnSortChanged write SetOnSortChanged;
    property OnKeyPress : TKeyPressEvent read FOnKeyPress write SetOnKeyPress;

    property SelectionCount: integer read GetSelectionCount;
    property ColumnCount : integer read GetColumnCount;
    property ClientCount : integer read GetClientCount;

    property SortColumn: TClientLookupCol read FSelectedColumn;
    property SortDirection: TSortDirection read GetSortDirection;
    property SearchText: String read FSearchText write SetSearchText;
    property ShowPopMenu: Boolean read FShowPopMenu write SetShowPopMenu;
    property ProcessStatusUpdateNeeded: Boolean read FProcessStatusUpdateNeeded write SetProcessStatusUpdateNeeded;
    property LastScrollPosition: Integer read FLastScrollPosition;
    property Columns : TCluColumnList read FColumns;
    property ProcStatDate: Integer read GetProcStatDate;
    property ProcStatOffset: Integer read FProcStatOffset write SetProcStatOffset;
    procedure UpdateActions;
    property OnUpdateCount: TNotifyEvent read FOnUpdateCount write SetOnUpdateCount;
    procedure RefeshBankLinkOnlineStatus;
    function FirstUpload: Boolean;
    property NoOnlineConnection: boolean read FNoOnlineConnection write SetNoOnlineConnection;
    property FrameUseMode: TFrameUseMode read FFrameUseMode write SetFrameUseMode;
    property ServerResponse: TServerResponse read FServerResponse write SetServiceResponse;
    property ClientStatusList: TClientStatusList read FClientStatusList write SetClientStatusList;

    function EditBooksBankLinkOnlineLogin: Boolean;
    function CheckBooksLogin: Boolean;
    function ChangeBooksPassword: Boolean;
  end;

  const
    MinProcOffset = 0;
    MaxProcOffset = 24;


implementation
uses
  bkDateUtils,
  GenUtils,
  ClientWrapper,
  imagesfrm,
  Imglist,
  infoMoreFrm,
  Globals,
  StStrs,
  syCFIO,
  Themes,
  rzGrafx, rzCommon,
  Math, Types,
  WinUtils, YesNoDlg, ErrorMoreFrm,  ClientDetailCacheObj,
  stDateSt, bkBranding, PDDATES32,
  progress, formPassword, BankLinkConnect, Admin32,
  ChangePasswordFrm, INISettings, TypInfo;

{$R *.dfm}

const
  //Group ID's
  gidNone                 = 0;   gidMin  = 0;
  gidStatus_Closed        = 1;
  gidStatus_Open          = 2;
  gidStatus_CheckedOut    = 3;
  gidStatus_Offsite       = 4;
  gidStatus_NewFile       = 31;   //new file to update
  gidStatus_CheckInConflict = 33; //file is not read-only out or offsite
  gidStatus_InvalidFile   = 34;   //error reading wrapper, crc, not banklink
  gidStatus_ReadOnly      = 35;
  gidArchived             = 36;
  gidBankLink_Online      = 37;
  gidNon_BankLink_Online  = 38;

  gidAction_Now           = 5;
  gidAction_Later         = 6;
  gidAction_None          = 7;

  gidAssignedTo_Assigned  = 8;
  gidAssignedTo_Not       = 9;

  gidReportPeriod_Schd    = 10;
  gidReportPeriod_NotSchd = 11;

  gidDates_Never            = 12;
  gidDates_Today            = 13;
  gidDates_Yesterday        = 14;
  gidDates_EarlierThisMonth = 15;
  gidDates_LastMonth        = 16;
  gidDates_LongTime         = 17;

  gidFutDates_ThisMonth        = 18;
  gidFutDates_NextMonth        = 19;
  gidFutDates_TwoMonthsOrMore  = 20;
  gidFutDates_NA               = 21;


  gidFinYear_ThisYear     = 22;
  gidFinYear_LastYear     = 23;
  gidFinYear_Older        = 24;
  gidFinYear_NotSet       = 25;

  gidRemDate_Now          = 26;
  gidRemDate_Later        = 27;
  gidRemDate_NoDate       = 28;

  gidActive               = 29;
  gidProspect             = 30;

  gidForeignFile          = 32;  //This should always be the last group!!


  gidMax  = 38;

  gidNames : Array[ gidMin..gidMax] of string[30] =
    (
      'Files',

      'Available',
      'Open',
      BKBOOKSNAME,
      BKBOOKSNAME + ' (Secure)',

      'Action Required Now',
      'Action Required Later',
      'No Action Required',

      'Assigned',
      'Not Assigned',

      'Scheduled',
      'Not Scheduled',

      'Never',
      'Today',
      'Yesterday',
      'Earlier this month',
      'Last month',
      'A long time ago',
      'This Month',
      'Next Month',
      'Two Months or More',
      'Not Applicable',

      'This Year',
      'Last Year',
      'Prior to last year',
      'Unknown',

      'Due Now',
      'Due Later',
      'No Date',

      'Active Clients',
      'Prospective Clients',

      'New',

      'Unsynchronised Files',
      'Conflict',
      'Invalid Files',
      'Read-Only',
      'Archived',
      'Files via BankLink Online',
      'Non-BankLink Online Files'
     );

const
  Tag_CheckInConflict = 1;
  Tag_InvalidFile = 2;
  Tag_ReadOnlyFile = 3;

const LEDOffset = 6;
      LEDWidth = 8;
      LEDSpacing = 3;

      // sort types for sched rep column
      stMonth = 1;
      stSchedule = 2;

const
   TypeAheadTimeout = 1.0 / SecsPerDay; // 1 sec


const
   ProcStatBtnW = 20;
   ProcStatBtnH = 20;

var
   cmfDateBits : UInt64;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//column order sort
function SortByDisplayPos( Item1, Item2: TCluColumnDefn): Integer;
begin
  if Item1.DisplayPos < Item2.DisplayPos then
    result := -1
  else
  if Item1.DisplayPos > Item2.DisplayPos then
    result := 1
  else
    result := 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TCluColumnList }
function TfmeClientLookup.AddColumn(aCaption: string; aDefaultWidth: integer;
  aFieldID: TClientLookupCol): TCluColumnDefn;
//passing -1 as the default width will set that column to be auto-sizing
var
  NewColumn : TCluColumnDefn;
begin
  //create new column
  NewColumn := TCluColumnDefn.Create;
  NewColumn.FieldID         := aFieldID;
  NewColumn.Caption         := aCaption;
  NewColumn.DefaultWidth    := aDefaultWidth;
  NewColumn.DefaultPos      := FColumns.Count;
  NewColumn.DisplayPos      := NewColumn.DefaultPos;
  NewColumn.DisplayWidth    := NewColumn.DefaultWidth;
  NewColumn.Visible         := True;
  NewColumn.ProdIndex       := -1;
  NewColumn.ProdGuid        := '';
  //add columns
  FColumns.Add( NewColumn);
  result := NewColumn;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfmeClientLookup.AddColumnEx( aFieldID: TClientLookupCol;
                                       aCaption: string;
                                       aDefaultWidth, aDefaultPos, aUserWidth,
                                       aUserPos: integer;
                                       visible: Boolean;
                                       aProdIndex : Integer;
                                       aProdGuid : TBloGuid): TCluColumnDefn;
//extended version of AddColumn that allows customizable column position and
//width
//passing -1 as the default width will set that column to be auto-sizing
var
  NewColumn : TCluColumnDefn;
begin
  //create new column
  NewColumn := TCluColumnDefn.Create;
  NewColumn.Caption         := aCaption;
  NewColumn.FieldID         := aFieldID;
  NewColumn.DefaultWidth    := aDefaultWidth;
  NewColumn.DefaultPos      := aDefaultPos;
  NewColumn.Visible         := visible;
  NewColumn.ProdIndex       := aProdIndex;
  NewColumn.ProdGuid        := aProdGuid;
  //set custom settings if specified
  if aUserPos = -1 then
  begin
    NewColumn.DisplayPos      := NewColumn.DefaultPos;
    NewColumn.DisplayWidth    := NewColumn.DefaultWidth;
  end
  else
  begin
    NewColumn.DisplayPos      := aUserPos;
    NewColumn.DisplayWidth    := aUserWidth;
  end;
  //add columns
  FColumns.Add( NewColumn);
  result := NewColumn;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TCluColumnList.ColumnDefn_At(i: integer): TCluColumnDefn;
begin
  result := TCluColumnDefn( Self.Get(i));
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TCluColumnList.FindColumnIndex( aLookupCol: TClientLookupCol): integer;
//returns the column index for a particular column type
var
  i : integer;
begin
  result := -1;
  for i := 0 to ( Self.Count -1) do
    if Self.ColumnDefn_At(i).FieldID = aLookupCol then
    begin
      result := i;
      exit;
    end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TCluColumnList.GetColumnFieldID( aColumnNo: integer): TClientLookupCol;
begin
  if ( aColumnNo >= 0) and ( aColumnNo < Self.Count) then
    result := Self.ColumnDefn_At( aColumnNo).FieldID
  else
    result := cluUnknown;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TIntermediateDataList }
function TIntermediateDataList.Add: pIntermediateDataRec;
//create a new item, add it to the list and return the pointer
var
  NewItem : pIntermediateDataRec;
begin
  GetMem( NewItem, SizeOf( TIntermediateDataRec));
  Self.Insert( NewItem);

  result := NewItem;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TIntermediateDataList.FreeItem(Item: Pointer);
begin
  FreeMem( Item, SizeOf( TIntermediateDataRec));
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TIntermediateDataList.IntermediateData_At(
  Index: integer): pIntermediateDataRec;
begin
  result := At( Index);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function  TfmeClientLookup.GetClientStat(sysClientRec: pClient_File_Rec; ForDate: TSTDate):ClientStat;
var Offset, P: Integer;

function GetMonthsBetween(Date1, Date2: Integer): Integer;
var
  D1, D2, M1, M2, Y1, Y2: Integer;
begin
   StDatetoDMY(Date1, D1, M1, Y1);
   StDatetoDMY(Date2, D2, M2, Y2);
   Result := M2 - M1 + ((Y2 - Y1) * 12);
end;

begin
   FillChar(Result,Sizeof(Result),rtNoData);
   if not Assigned(sysClientRec) then
      Exit;
   // how many months is the Client Rec out of step with the ForDate date...
   Offset := GetMonthsBetween(sysClientRec.cfLast_Processing_Status_Date, ForDate);
   //So Offset represents the offset between the ClientRec period 36 and Output period 12;
   if Offset <> 0 then
      if ProcStatOffset = 0 then
         ProcessStatusUpdateNeeded := True;

   Offset := Offset + 24;
   for P := 1 to 12 do
      if (P + Offset) in [1..36] then begin
         Result.Transferred[P] := TResultType(sysClientRec.cfTransferred[P + Offset]);
         Result.Finalized[P]   := TResultType(sysClientRec.cfFinalized [P + Offset]);
         Result.Coded[P]       := TResultType(sysClientRec.cfCoded [P + Offset]);
         Result.Downloaded[P]  := TResultType(sysClientRec.cfDownloaded [P + Offset]);
      end else if (P + Offset) < 1 then begin
         // May look better than NoData..
         Result.Transferred[P] := TResultType(sysClientRec.cfTransferred[1]);
         Result.Finalized[P]   := TResultType(sysClientRec.cfFinalized [1]);
         Result.Coded[P]       := TResultType(sysClientRec.cfCoded [1]);
         Result.Downloaded[P]  := TResultType(sysClientRec.cfDownloaded [1]);
      end;

end;

procedure TfmeClientLookup.DoCreate;
begin
  vtClients.Clear;
  vtClients.Header.Columns.Clear;
  vtClients.NodeDataSize := SizeOf( TTreeData);

  FColumns := TCluColumnList.Create;
  FSelectedColumn        := cluCode;
  FIntermediateDataList  := TIntermediateDataList.create;
  FViewMode              := vmAllFiles;
  FFilterMode            := fmNoFilter;
  FSubFilter             := 0;
  FUserFilter            := TStringList.Create;
  FGroupFilter           := TStringList.Create;
  FClientTypeFilter      := TStringList.Create;
  FClientFilter          := filterAllClients;
  FFilesDirectory        := Globals.DATADIR;
  FArrowKeyDown          := False;
  FOptions               := [];
  FOnNotesClick          := nil;
  FSortType              := stMonth;

  AdminSnapshot         := nil;

  FClientCodesList := TStringList.Create;
  FClientNamesList := TStringList.Create;

  VTClients.Font := appimages.Font;
  VTClients.Header.Font := appimages.Font;
  CurrentSearchKey := '';
  LastSearchTime := 0;

  FClientStatusList := TClientStatusList.Create;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


destructor TfmeClientLookup.Destroy;
var
  i : integer;
begin
  FClientStatusList.Free;
  //empty columns object

  for i := 0 to Pred( FColumns.Count) do
    FColumns.ColumnDefn_At(i).Free;
  //free object
  FColumns.Free;
  //clear intermediate data
  FIntermediateDataList.Free;
  //free snapshot
  FreeAndNil( AdminSnapshot);
  //free sort lists
  FClientCodesList.Free;
  FClientNamesList.Free;
  FUserFilter.Free;
  FGroupFilter.Free;
  FClientTypeFilter.Free;
  //do standard frame stuff
  inherited;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.LoadColumns;
//take the frames internal column list and build the columns in the virtual tree
var
  i : integer;
  UserColumn : TCluColumnDefn;
  TreeColumn : TVirtualTreeColumn;
begin
  //take column object and set up columns in grid
  vtClients.Header.Columns.Clear;
  btnLeft.Visible := False;
  btnRight.Visible := False;
  SetHeaderHeight(False);
  //sort columns into display order
  FColumns.Sort( @SortByDisplayPos);

  for i := 0 to (FColumns.Count -1) do
  begin
    UserColumn := FColumns.ColumnDefn_At(i);

    TreeColumn := vtClients.Header.Columns.Add;
    TreeColumn.Text        := UserColumn.Caption;
    TreeColumn.Tag         := Ord(UserColumn.FieldID);

    if UserColumn.FieldID = cluProcessing then begin
       TreeColumn.Style  := vsOwnerDraw;
       TreeColumn.Width :=  ProcStatBtnW * 2 + 12 * 11 + 4;
       TreeColumn.Options :=  TreeColumn.Options - [coResizable]
    end;

    if UserColumn.Visible then begin
       if UserColumn.FieldID = cluProcessing then begin
          TreeColumn.Style  := vsOwnerDraw;
          SetHeaderHeight(True);
          TreeColumn.Width :=  ProcStatBtnW * 2 + 12 * 11 + 4;
          TreeColumn.Options :=  TreeColumn.Options - [coResizable]
       end;
    end else
      TreeColumn.Options := TreeColumn.Options - [coVisible];

    if UserColumn.DefaultWidth = -1 then
    begin
      vtClients.Header.AutoSizeIndex := TreeColumn.Index;
      vtClients.Header.Options := vtClients.Header.Options + [ hoAutoResize];
    end
    else
     if UserColumn.FieldID <> cluProcessing then
      TreeColumn.Width  := UserColumn.DisplayWidth;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.LoadNodes( ReloadData : boolean);
//only use grouping if column needs it
var
  NodeData : pTreeData;
  ChildNodesCount : Array[ gidMin..gidMax] of integer;
  ChildNode       : pVirtualNode;
  RootNodesCache  : Array[ gidMin..gidMax] of pVirtualNode;

  i               : integer;
  pIDRec          : pIntermediateDataRec;

  LastCodeSelected: string;
begin
  vtClients.BeginUpdate;
  try
    //store the current position
    pIDRec := GetIntermediateDataFromNode( vtClients.GetFirstSelected);
    if Assigned( pIDRec) then
      LastCodeSelected := pIDRec^.imCode
    else
      LastCodeSelected := '';

    //empty current nodes
    vtClients.Clear;
    vtClients.RootNodeCount := 0;
    vtClients.Indent := 0;
    //clear the array the counts the number of nodes required for each group
    //this is used to determine if a root node should be added
    FillChar( ChildNodesCount, SizeOf( ChildNodesCount), 0);
    for i := gidMin to gidMax do
      RootNodesCache[ i] := nil;

    //clear search lists
    FClientCodesList.Clear;
    FClientNamesList.Clear;
    FClientCodesList.Sorted := true;
    FClientNamesList.Sorted := true;

    CurrentSearchKey := '';
    LastSearchTime := 0;

    //load intermediate array and set grouping id for each child node
    if ReloadData then
      RefreshData;

    SetGroupIDs;

    //reload the grid
    for i := FIntermediateDataList.First to FIntermediateDataList.Last do
    begin
      pIDRec := FIntermediateDataList.IntermediateData_At(i);
      ChildNodesCount[ pIDRec.imGroupID] := ChildNodesCount[ pIDRec.imGroupID] + 1;
    end;

    //load root nodes, load into a cache so that we can reference by group id
    for i := gidMin to gidMax do
    begin
      if ChildNodesCount[ i] > 0 then
      begin
        RootNodesCache[ i] := vtClients.AddChild( nil);

        NodeData := vtClients.GetNodeData( RootNodesCache[ i]);
        NodeData.tdNodeType  := ntGroup;
        NodeData.tdFolderID  := i;
      end;
    end;

    //add the child notes for each root node
    for i := FIntermediateDataList.First to FIntermediateDataList.Last do
    begin
      pIDRec := FIntermediateDataList.IntermediateData_At(i);
      ChildNode := vtClients.AddChild( RootNodesCache[ pIDREc.imGroupID], nil);

      NodeData  := vtClients.GetNodeData( ChildNode);
      NodeData.tdNodeType := ntClient;
      NodeData.tdData     := pIDRec;

      //add to sort lists
      FClientCodesList.AddObject( Uppercase( pIDRec.imCode), TObject( ChildNode));
      FClientNamesList.AddObject( Uppercase( pIDRec.imName), TObject( ChildNode));
    end;

    //set the indentation between levels, set to zero if only 1 root node and
    //is the default node
    if ( vtClients.RootNodeCount = 1) and (ChildNodesCount[ gidNone] > 0) then
    begin
      vtClients.NodeHeight[ RootNodesCache[ 0]] := 0;
    end;

    //expand all nodes by default
    for i := gidMin to gidMax do
    begin
      if ChildNodesCount[ i] > 0 then
      begin
        vtClients.Expanded[ RootNodesCache[ i]]   := True;
        vtClients.NodeHeight[ RootNodesCache[ i]] := 35;
      end;
    end;

    //sort
    with vtClients.Header do
      vtClients.SortTree( SortColumn, SortDirection);

    //reposition on last selected code
    if LastCodeSelected <> '' then
      LocateCode( LastCodeSelected);

    //sort search lists
    FClientCodesList.Sorted := true;
    FClientNamesList.Sorted := true;

    FClientCodesList.Sort;
    FClientNamesList.Sort;
    UpdateCount;
  finally
    vtClients.EndUpdate;
  end;
end;

procedure TfmeClientLookup.BtnLeftClick(Sender: TObject);
begin
   if ProcStatOffset < MaxProcOffset then
      ProcStatOffset := ProcStatOffset + 1;
end;

procedure TfmeClientLookup.BtnRightClick(Sender: TObject);
begin
   if ProcStatOffset > MinProcOffset then
      ProcStatOffset := ProcStatOffset - 1;
end;

procedure TfmeClientLookup.BuildGrid( const SelectColumn : TClientLookupCol; const SortDirection: TSortDirection = sdAscending);
begin
  //build columns from internal list
  LoadColumns;

  //set up sorting defaults
  FSelectedColumn := SelectColumn;  //determine which column is selected
                                    //this affects sorting and grouping

  vtClients.Header.SortColumn    := FColumns.FindColumnIndex( SelectColumn);
  vtClients.Header.SortDirection := SortDirection;
  vtClients.Header.Background    := clBtnFace;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetFutureDateGroupID( aStDate: Integer): byte;
var
  TodaysDate: Integer;
  TodaysDay, TodaysMonth, TodaysYear: Integer;
  Day, Month, Year : Integer;

begin
  if aStDate <= 0 then
    result := gidFutDates_NA
  else
  begin
    TodaysDate := StDate.CurrentDate;
    StDateToDMY(TodaysDate, TodaysDay, TodaysMonth, TodaysYear);
    StDateToDMY(aSTDate, Day, Month, Year);
    //if before this month, then never
    if (Year < TodaysYear) or ((Year = TodaysYear) and (Month < TodaysMonth)) then
      Result := gidFutDates_NA
    else if (Year = TodaysYear) and (Month = TodaysMonth) then //current month
      result := gidFutDates_ThisMonth
    else if ((Year = TodaysYear) and (Month = TodaysMonth + 1)) or
      ((Year = TodaysYear + 1) and (Month = 1) and (TodaysMonth = 12))  then
      result := gidFutDates_NextMonth
    else
      result := gidFutDates_TwoMonthsOrMore;
  end;
end;

function GetDateGroupID( aStDate : integer) : byte;
var
  TodaysDate : integer;
  TodaysMonth : integer;
  TodaysYear  : integer;
  d,m,y       : integer;
begin
  if aStDate <= 0 then
    result := gidDates_Never
  else begin
    TodaysDate := StDate.CurrentDate;
    StDateToDMY( TodaysDate, d, TodaysMonth, TodaysYear);
    StDateToDMY( aStDate, d, m, y);
                                              
    if aStDate = TodaysDate then
    begin
      result := gidDates_Today;
      exit;
    end;

    if aStDate = ( TodaysDate - 1) then
    begin
      result := gidDates_Yesterday;
      exit;
    end;

    if ( m = TodaysMonth) then
    begin
      result := gidDates_EarlierThisMonth;
      exit;
    end;

    if ( TodaysYear = y) and ( m = ( TodaysMonth - 1)) or
       (( y = TodaysYear -1) and ( m = 12) and ( TodaysMonth = 1)) then
    begin
      result := gidDates_LastMonth;
      exit;
    end;

    result := gidDates_LongTime;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.SetGroupIDs;
//reset the group ids based on the current sort col
var
  i : integer;
  pIDRec : pIntermediateDataRec;
  sysClientRec   : pClient_File_Rec;
  d,m,y,TodaysYear : integer;
begin
  for i := FIntermediateDataList.First to FIntermediateDataList.Last do
  begin
    pIDRec := FIntermediateDataList.IntermediateData_At(i);

    if PIDRec^.imData = nil then
    begin
      //additional client info is not available so can't set group
      //this will happen if list is loaded from files on disk
      pIDRec^.imGroupID := 0;

      case pIDRec^.imTag of
        Tag_InvalidFile :
           pIDRec^.imGroupID := gidStatus_InvalidFile;
        Tag_ReadOnlyFile :
           pIDRec^.imGroupID := gidStatus_ReadOnly;
      else
        begin
          //it will also happen when a file is being updated for the first time
          if ( FFilterMode = fmFilesForCheckIn) and ( FSelectedColumn = cluStatus) then
          begin
            if FUsingAdminSystem then
              pIDRec^.imGroupID := gidStatus_NewFile
            else
            begin
              //Update from an offsite, see if the
              if pIDRec^.imTag = Tag_CheckInConflict then
                pIDRec^.imGroupID := gidStatus_CheckInConflict
              else
                pIDRec^.imGroupID := gidStatus_NewFile;
            end;
          end;
        end;                                     
      end; //case

    end
    else begin
      sysClientRec := pIDRec^.imData;

      if (sysClientRec^.cfArchived) then
        pIDRec^.imGroupID := gidArchived
      else if ( sysClientRec^.cfForeign_File) then
        pIDRec^.imGroupID := gidForeignFile
      else
      begin
        case FSelectedColumn of
          cluStatus :
          begin
            if ( FFilterMode = fmFilesForCheckIn) then
            begin
              //make sure the files are read-only, otherwise there is a
              //conflict
              case sysClientRec^.cfFile_Status of
                bkconst.fsCheckedOut : pIDRec^.imGroupID := gidStatus_CheckedOut;
                bkconst.fsOffsite    : pIDRec^.imGroupID := gidStatus_Offsite;
              else
                pIDRec^.imGroupID := gidStatus_CheckInConflict;
              end;
            end else begin
              case sysClientRec^.cfFile_Status of
                bkconst.fsNormal     : pIDRec^.imGroupID := gidStatus_Closed;
                bkconst.fsOpen       : pIDRec^.imGroupID := gidStatus_Open;
                bkconst.fsCheckedOut : pIDRec^.imGroupID := gidStatus_CheckedOut;
                bkconst.fsOffsite    : pIDRec^.imGroupID := gidStatus_Offsite;
              end;
            end;
          end;

          cluNextGSTDue :
          begin
            pIDRec^.imGroupID := GetFutureDateGroupID(GetNextGSTDueDate(STDate.CurrentDate, sysClientRec^.cfGST_Start_Month,
              sysClientRec^.cfGST_Period, AdminSystem.fdFields.fdCountry));
          end;

          cluUser :
          begin
            if sysClientRec^.cfUser_Responsible > 0 then
              pIDRec^.imGroupID := gidAssignedTo_Assigned
            else
              pIDRec^.imGroupID := gidAssignedTo_Not;
          end;

          cluGroup :
          begin
            if sysClientRec^.cfGroup_LRN > 0 then
              pIDRec^.imGroupID := gidAssignedTo_Assigned
            else
              pIDRec^.imGroupID := gidAssignedTo_Not;
          end;

          cluClientType :
          begin
            if sysClientRec^.cfClient_Type_LRN  > 0 then
              pIDRec^.imGroupID := gidAssignedTo_Assigned
            else
              pIDRec^.imGroupID := gidAssignedTo_Not;
          end;

          cluReportingPeriod, cluSendBy :
          begin
            if sysClientRec^.cfReporting_Period = roDontSendReports then
              pIDRec^.imGroupID := gidReportPeriod_NotSchd
            else
              pIDRec^.imGroupID := gidReportPeriod_Schd;
          end;

          cluLastAccessed :
          begin
            //date groups
            pIDRec^.imGroupID := GetDateGroupID( sysClientRec^.cfDate_Last_Accessed);
          end;

          cluType :
          begin
            if sysClientRec^.cfClient_Type = ctProspect then
              pIDRec^.imGroupID := gidProspect
            else
              pIDRec^.imGroupID := gidActive;
          end;

          cluAction, cluReminderDate :
          begin
            if sysClientRec^.cfPending_ToDo_Count = 0 then
              pIDRec^.imGroupID := gidAction_None
            else
            begin
              if ( sysClientRec^.cfNext_ToDo_Rem_Date = 0) or
                 ( sysClientRec^.cfNext_ToDo_Rem_Date <= StDate.CurrentDate) then
                pIDRec^.imGroupID := gidAction_Now
              else
                pIDRec^.imGroupID := gidAction_Later;
            end;
          end;

          cluFinYearStarts :
          begin
            //group into this year, last year, older
            if sysClientRec^.cfFinancial_Year_Starts <= 0 then
              pIDRec^.imGroupID := gidFinYear_NotSet
            else
            begin
              StDateToDMY( CurrentDate, d,m, TodaysYear);
              StDateToDMY( sysClientRec^.cfFinancial_Year_Starts, d,m,y);
              if ( y = TodaysYear) then
                pIDRec^.imGroupID := gidFinYear_ThisYear
              else
              if ( y = ( TodaysYear - 1)) then
                pIDRec^.imGroupID := gidFinYear_LastYear
              else
                pIDRec^.imGroupID := gidFinYear_Older;
            end;
          end;
        else
          pIDRec^.imGroupID := 0;
        end;
      end;
    end;

    //Add extra grouping for BankLink Online for Books Send
    if not Assigned(AdminSystem) then begin
      case FFrameUseMode of
        fumSendFile  : if (pIDRec^.imSendMethod = ftmOnline) then
                         pIDRec^.imGroupID := gidBankLink_Online;
        fumSendOnline: if (pIDRec^.imSendMethod <> ftmOnline) then
                         pIDRec^.imGroupID := gidNon_BankLink_Online;
      end;
    end;
  end;
end;

procedure TfmeClientLookup.SetHeaderHeight(Processing: Boolean);
begin
   if Processing then
      vtClients.Header.Height := ProcStatBtnH * 2 + 2
   else
      vtClients.Header.Height := Abs(VTClients.Header.Font.Height) * 10 DIV 6;
end;

procedure TfmeClientLookup.SetNoOnlineConnection(const Value: boolean);
begin
  FNoOnlineConnection := Value;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.RefeshBankLinkOnlineStatus;
var
  i: integer;
  pIDRec: pIntermediateDataRec;
  Attempt: integer;
  ErrMsg : string;
begin
  //Get status of Banklink Online client files
  Screen.Cursor := crHourGlass;
  StatusSilent := False;
  CiCoClient.OnProgressEvent := DoStatusProgress;
  try
    try
      UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 0);
      Attempt := -1;
      while (Attempt < 3) do begin
        Inc(Attempt);
        FClientStatusList.Clear;

        if (FSeverResponce.Status = '') then
          if Assigned(AdminSystem) then
            CiCoClient.GetClientFileStatus(FSeverResponce, FClientStatusList, '')
          else begin
            //Don't show the password form if the CheckInOut form is already displayed
            ChangePasswordFrm.LoginToBankLinkOnline(FSeverResponce, FClientStatusList);
          end;

        if (FSeverResponce.Status = '200') then begin
          FNoOnlineConnection := False;  //Connection ok
          UpdateOnlineStatus;
          Attempt := 3;  //Password ok
        end else if not Assigned(AdminSystem) then begin
          FNoOnlineConnection := True;  //not logged on from books
          Attempt := 3;
        end else if (FSeverResponce.Status = '101') or         //No Practice Password
                    (FSeverResponce.Status = '102') or         //invalid Country, Practice or password
                    (FSeverResponce.Status = '103') then begin //invalid Country or Practice
          if Attempt > 2 then
            raise Exception.Create('Password failed on third attempt');
          InvalidPasswordDlg(Attempt);
        end else
          raise Exception.Create(format('%s : %s : %s',[FSeverResponce.Status,
                                                        FSeverResponce.Description,
                                                        FSeverResponce.DetailedDesc]));
      end;
    except
      on E: Exception do begin
        for i := FIntermediateDataList.First to FIntermediateDataList.Last do begin
          pIDRec := FIntermediateDataList.IntermediateData_At(i);
          pIDRec^.imOnlineStatusDesc := '';
          pIDRec^.imModifiedDate   := 0;
          pIDRec^.imOnlineStatus   := cfsNoFile;
        end;
        FNoOnlineConnection := True;
        if E.Message = '301: Interrupted.' then
          ErrMsg := 'Time out reached!'
        else
          ErrMsg := E.Message;

        HelpfulErrorMsg('Unable to connect to ' + BANKLINK_ONLINE_NAME + ': ' + ErrMsg, 0);
      end;
    end;
  finally
    FSeverResponce.Status := '';
    CiCoClient.OnProgressEvent := Nil;
    StatusSilent := True;
    ClearStatus;
    Screen.Cursor := crDefault;
  end;
end;

procedure TfmeClientLookup.RefreshData;
const
  Error_Signature = $FFFFFF;
var
  SearchRec       : TSearchRec;
  Found           : longint;
  Wrapper         : TClientWrapper;
  WrapperOfExistingFile : TClientWrapper;

  pIDRec          : pIntermediateDataRec;
  sysClientRec    : pClient_File_Rec;
  cNo, i, j       : integer;

  AllowFileAccess : Boolean;
  S               : string;

  AddToData, Scheduled, IncludedInFilter : Boolean;

  Filtered: array[cmfsMin..cmfsMax] of Boolean;
  Grouped: array[cmfsTopMin..cmfsTopMax] of Boolean;
  User: pUser_Rec;
  Group: pGroup_Rec;
  ClientType: pClient_Type_Rec;

begin
  //clear intermediate data list
  FIntermediateDataList.FreeAll;
  if not assigned(CurrUser) then Exit;

  //first see if we are using local files or admin system
  FUsingAdminSystem := Assigned( AdminSnapshot);

  if FUsingAdminSystem and ( not (FFilterMode = fmFilesForCheckIn)) then
  begin
    //load all client files from list
    for cNo := AdminSnapshot.fdSystem_Client_File_List.First to AdminSnapshot.fdSystem_Client_File_List.Last do
    begin
      sysClientRec := AdminSnapshot.fdSystem_Client_File_List.Client_File_At( cNo);
      //see if the user is allowed to see this file
      AllowFileAccess := AdminSnapshot.fdSystem_File_Access_List.Allow_Access( CurrUser.LRN, sysClientRec^.cfLRN );
      if AllowFileAccess or (sysClientRec^.cfClient_Type = ctProspect) then // can always see all prospects
      begin
        AddToData := ( FViewMode = vmAllFiles) or
                      (
                        ( FViewMode = vmMyFiles) and
                        ( CurrUser.LRN = sysClientRec.cfUser_Responsible) and
                        ( not sysClientRec.cfForeign_File )
                      );

        //if the filter is for files to send then only show non read-only out files
        //the exception we also include the currently 'OPEN' file
        if FFilterMode = fmFilesForCheckOut then
        begin
          AddToData := AddToData and
                         (
                           ( sysClientRec^.cfFile_Status = fsNormal) or
                           (
                              (sysClientRec^.cfFile_Status = fsOpen) and
                              ( Assigned( MyClient)) and
                              ( MyClient.clFields.clCode = sysClientRec^.cfFile_Code)
                           ));
        end;

        if ((trim(SearchText)<>'') and ((Pos(UpperCase(SearchText), UpperCase(sysClientRec.cfFile_Code))>0) or
        (Pos(UpperCase(SearchText), UpperCase(sysClientRec.cfFile_Name))>0))) or (trim(SearchText)='')
        then
          AddToData := AddToData and True
        else AddToData := False;

        AddToData := AddToData and
                     (
                        (((FClientFilter = filterAllClients) or (FClientFilter = filterMyClients)) and (sysClientRec^.cfClient_Type = ctActive)) or
                        //(((FClientFilter = filterAllArchived) or (FClientFilter = filterMyArchived)) and (sysClientRec^.cfArchived)) or
                        (((FClientFilter = filterAllProspects) or (FClientFilter = filterMyProspects)) and (sysClientRec^.cfClient_Type = ctProspect))
                     );

        if FFilterMode = fmAvailableFiles then
        begin
          AddToData := AddToData and ( sysClientRec^.cfFile_Status = fsNormal);
        end;

        if FFilterMode = fmUpdateableFiles then
        begin
          AddToData := AddToData and ( not sysClientRec^.cfForeign_File) and
                         (
                           ( sysClientRec^.cfFile_Status = fsNormal) or
                           (
                              (sysClientRec^.cfFile_Status = fsOpen) and
                              ( Assigned( MyClient)) and
                              ( MyClient.clFields.clCode = sysClientRec^.cfFile_Code)
                           ));
        end;

        //Filter BankLink Online files
        AddToData := AddToData  and IncludeClientInList(sysClientRec.cfFile_Transfer_Method);

        if FUsingAdminSystem and AddToData and ((FSubFilter <> 0) or (FUserFilter.Count > 0) or (FGroupFilter.Count > 0) or (FClientTypeFilter.Count > 0))
             and ((FClientFilter = filterAllClients) or (FClientFilter = filterMyClients)) then
        begin

           for i := cmfsMin to cmfsMax do
             Filtered[i] := False;
           for i := cmfsTopMin to cmfsTopMax do
             Grouped[i] := False;

          //CLIENT CODING
          if (FSubFilter and cmfsBits[cmfsCoded]) = cmfsBits[cmfsCoded] then
            Filtered[cmfsCoded] := Not(IsUnCoded(sysClientRec,ProcStatDate));

          if (FSubFilter and cmfsBits[cmfsNotcoded]) = cmfsBits[cmfsNotcoded] then
            Filtered[cmfsNotCoded] := IsUnCoded(sysClientRec,ProcStatDate);

          //GST Due
          if (FSubFilter and cmfsBits[cmfsGSTThisMonth]) = cmfsBits[cmfsGSTThisMonth] then
            Filtered[cmfsGstThisMonth] := GetFutureDateGroupID(GetNextGSTDueDate(STDate.CurrentDate, sysClientRec^.cfGST_Start_Month,
              sysClientRec^.cfGST_Period, AdminSystem.fdFields.fdCountry)) = gidFutDates_ThisMonth;

          if (FSubFilter and cmfsBits[cmfsGSTNextMonth]) = cmfsBits[cmfsGSTNextMonth] then
            Filtered[cmfsGSTNextMonth] := GetFutureDateGroupID(GetNextGSTDueDate(STDate.CurrentDate, sysClientRec^.cfGST_Start_Month,
              sysClientRec^.cfGST_Period, AdminSystem.fdFields.fdCountry)) = gidFutDates_NextMonth;

          if (FSubFilter and cmfsBits[cmfsGST2MonthsOrMore]) = cmfsBits[cmfsGST2MonthsOrMore] then
            Filtered[cmfsGST2MonthsOrMore] := GetFutureDateGroupID(GetNextGSTDueDate(STDate.CurrentDate, sysClientRec^.cfGST_Start_Month,
              sysClientRec^.cfGST_Period, AdminSystem.fdFields.fdCountry)) = gidFutDates_TwoMonthsOrMore;

          if (FSubFilter and cmfsBits[cmfsGSTNotApplicable]) = cmfsBits[cmfsGSTNotApplicable] then
            Filtered[cmfsGSTNotApplicable] := GetFutureDateGroupID(GetNextGSTDueDate(STDate.CurrentDate, sysClientRec^.cfGST_Start_Month,
              sysClientRec^.cfGST_Period, AdminSystem.fdFields.fdCountry)) = gidFutDates_NA;

          // ACTION
          if (FSubFilter and cmfsBits[cmfsAction]) = cmfsBits[cmfsAction] then
               Filtered[cmfsAction] := (sysClientRec^.cfPending_ToDo_Count <> 0) and
                  (( sysClientRec^.cfNext_ToDo_Rem_Date = 0) or ( sysClientRec^.cfNext_ToDo_Rem_Date <= StDate.CurrentDate));
          if (FSubFilter and cmfsBits[cmfsLater]) = cmfsBits[cmfsLater] then
               Filtered[cmfsLater] := (sysClientRec^.cfPending_ToDo_Count <> 0) and
                  (( sysClientRec^.cfNext_ToDo_Rem_Date <> 0) and ( sysClientRec^.cfNext_ToDo_Rem_Date > StDate.CurrentDate));
          if (FSubFilter and cmfsBits[cmfsNoAction]) = cmfsBits[cmfsNoAction] then
               Filtered[cmfsNoAction] := sysClientRec^.cfPending_ToDo_Count = 0;

          // FILE STATUS
          if (FSubFilter and cmfsBits[cmfsCheckOut]) = cmfsBits[cmfsCheckOut] then
             Filtered[cmfsCheckOut] := (( sysClientRec^.cfFile_Status = fsCheckedOut) or ( sysClientRec^.cfFile_Status = fsOffsite));
          if (FSubFilter and cmfsBits[cmfsSynch]) = cmfsBits[cmfsSynch] then
             Filtered[cmfsSynch] := not ( sysClientRec^.cfForeign_File);
          if (FSubFilter and cmfsBits[cmfsUnsynch]) = cmfsBits[cmfsUnsynch] then
             Filtered[cmfsUnsynch] := ( sysClientRec^.cfForeign_File);
          if (FSubFilter and cmfsBits[cmfsBooks]) = cmfsBits[cmfsBooks] then
             Filtered[cmfsBooks] := sysClientRec^.cfFile_Status = fsCheckedOut;
          if (FSubFilter and cmfsBits[cmfsSecure]) = cmfsBits[cmfsSecure] then
             Filtered[cmfsSecure] := sysClientRec^.cfFile_Status = fsOffsite;
          if (FSubFilter and cmfsBits[cmfsArchive]) = cmfsBits[cmfsArchive] then
             Filtered[cmfsArchive] := sysClientRec^.cfArchived;
          if (FSubFilter and cmfsBits[cmfsNotArchive]) = cmfsBits[cmfsNotArchive] then
             Filtered[cmfsNotArchive] := not(sysClientRec^.cfArchived);

          // DATA
          if (FSubFilter and cmfsBits[cmfsNoData]) = cmfsBits[cmfsNoData] then
          begin
            Filtered[cmfsNoData] := True;
            if (sysClientRec.cfBank_Account_Count > 0) then // case 8332
            with  GetClientStat(sysClientRec,ProcStatDate) do For i := 1 to 12 do
            Begin
              if (Transferred[i] <> rtNoData)
              or (Finalized[i] <> rtNoData)
              or (Coded[i] <> rtNoData)
              or (Downloaded[i] <>rtNoData) then begin
                 Filtered[cmfsNoData] := False;
                 Break;
              end;
            end;
          end;

          if (FSubFilter and cmfsbits[cmfsData]) = cmfsbits[cmfsData] then
          begin
            if (sysClientRec.cfBank_Account_Count = 0) then
               Filtered[cmfsData] := True // case 8332
            else
             with  GetClientStat(sysClientRec,ProcStatDate) do For i := 1 to 12 do Begin
              If (Transferred[i] <>  rtNoData ) or
                 (Finalized[i] <>  rtNoData ) or
                 (Downloaded[i] <>  rtNoData ) or
                 (Coded[i] <>  rtNoData ) then
              begin
                 Filtered[cmfsData] := True;
                 Break;
              end;
            end;
          end;

          // ASSIGNMENT/USER
          User := AdminSnapshot.fdSystem_User_List.FindLRN( sysClientRec^.cfUser_Responsible );
          Group := AdminSnapshot.fdSystem_Group_List.FindLRN( sysClientRec^.cfGroup_LRN );
          ClientType := AdminSnapshot.fdSystem_Client_Type_List.FindLRN( sysClientRec^.cfClient_Type_LRN );
          // User filter OR include unassigned
          if (FUserFilter.Count > 0) and ((FSubFilter and cmfsBits[cmfsUnassigned]) = cmfsBits[cmfsUnassigned]) then
          begin
           Filtered[cmfsUnassigned] := (Assigned(User) and (FUserFilter.IndexOf(User.usCode) > -1) and (not sysClientRec^.cfForeign_File)) or
                                       (sysClientRec^.cfUser_Responsible <= 0);
          end
          // No user filter, include unassigned
          else if ((FSubFilter and cmfsBits[cmfsUnassigned]) = cmfsBits[cmfsUnassigned]) then
            Filtered[cmfsUnassigned] := (sysClientRec^.cfUser_Responsible <= 0)
          else if (FUserFilter.Count > 0) then // user filter only
            Filtered[cmfsUnassigned] := (Assigned(User) and (FUserFilter.IndexOf(User.usCode) > -1) and (not sysClientRec^.cfForeign_File));

          // Group filter OR include unassigned
          if (FGroupFilter.Count > 0) and ((FSubFilter and cmfsBits[cmfsUnassignedGroup]) = cmfsBits[cmfsUnassignedGroup]) then
          begin
           Filtered[cmfsUnassignedGroup] := (Assigned(Group) and (FGroupFilter.IndexOf(Group.grName) > -1) and (not sysClientRec^.cfForeign_File)) or
                                       (sysClientRec^.cfGroup_LRN <= 0);
          end
          // No group filter, include unassigned
          else if ((FSubFilter and cmfsBits[cmfsUnassignedGroup]) = cmfsBits[cmfsUnassignedGroup]) then
            Filtered[cmfsUnassignedGroup] := (sysClientRec^.cfGroup_LRN <= 0)
          else if (FGroupFilter.Count > 0) then // group filter only
            Filtered[cmfsUnassignedGroup] := (Assigned(Group) and (FGroupFilter.IndexOf(Group.grName) > -1) and (not sysClientRec^.cfForeign_File));

          // Client type filter OR include unassigned
          if (FClientTypeFilter.Count > 0) and ((FSubFilter and cmfsBits[cmfsUnassignedClientType]) = cmfsBits[cmfsUnassignedClientType]) then
          begin
           Filtered[cmfsUnassignedClientType] := (Assigned(ClientType) and (FClientTypeFilter.IndexOf(ClientType.ctName) > -1) and (not sysClientRec^.cfForeign_File)) or
                                       (sysClientRec^.cfClient_Type_LRN <= 0);
          end
          // No client type filter, include unassigned
          else if ((FSubFilter and cmfsBits[cmfsUnassignedClientType]) = cmfsBits[cmfsUnassignedClientType]) then
            Filtered[cmfsUnassignedClientType] := (sysClientRec^.cfClient_Type_LRN <= 0)
          else if (FClientTypeFilter.Count > 0) then // user filter only
            Filtered[cmfsUnassignedClientType] := (Assigned(ClientType) and (FClientTypeFilter.IndexOf(ClientType.ctName) > -1) and (not sysClientRec^.cfForeign_File));

          // SCHEDULED
          if (FSubFilter and cmfsBits[cmfsSDont]) = cmfsBits[cmfsSDont] then
               Filtered[cmfsSDont] := ( sysClientRec^.cfReporting_Period = roDontSendReports);

          Scheduled := ( sysClientRec^.cfReporting_Period > roDontSendReports) and
             ( sysClientRec^.cfSchd_Rep_Method_Filter > srdNone) and ( sysClientRec^.cfSchd_Rep_Method_Filter in [ srdMin..srdMax]);

          // SEND BY
          if (FSubFilter and cmfsBits[cmfsSPrint]) = cmfsBits[cmfsSPrint] then
            Filtered[cmfsSPrint] := (sysClientRec^.cfSchd_Rep_Method_Filter = srdPrinted);
          if (FSubFilter and cmfsBits[cmfsSEmail]) = cmfsBits[cmfsSEmail] then
            Filtered[cmfsSEmail] := (sysClientRec^.cfSchd_Rep_Method_Filter = srdEmail);
          if (FSubFilter and cmfsBits[cmfsSFax]) = cmfsBits[cmfsSFax] then
            Filtered[cmfsSFax] := (sysClientRec^.cfSchd_Rep_Method_Filter = srdFax);
          if (FSubFilter and cmfsBits[cmfsSNotes]) = cmfsBits[cmfsSNotes] then
            Filtered[cmfsSNotes] := (sysClientRec^.cfSchd_Rep_Method_Filter = srdECoding);
          if (FSubFilter and cmfsBits[cmfsSCSV]) = cmfsBits[cmfsSCSV] then
            Filtered[cmfsSCSV] := (sysClientRec^.cfSchd_Rep_Method_Filter = srdCSVExport);
          if (FSubFilter and cmfsBits[cmfsSWeb]) = cmfsBits[cmfsSWeb] then
            Filtered[cmfsSWeb] := (sysClientRec^.cfSchd_Rep_Method_Filter = srdWebX);
          if (FSubFilter and cmfsBits[cmfsSCheckOut]) = cmfsBits[cmfsSCheckOut] then
            Filtered[cmfsSCheckOut] := (sysClientRec^.cfSchd_Rep_Method_Filter = srdCheckOut);

          if Scheduled then
          begin
            // REPORT FREQUENCY
            if (FSubFilter and cmfsBits[cmfsSMonth]) = cmfsBits[cmfsSMonth] then
              Filtered[cmfsSMonth] := (sysClientRec^.cfReporting_Period = roSendEveryMonth);
            if (FSubFilter and cmfsBits[cmfsS2Month]) = cmfsBits[cmfsS2Month] then
              Filtered[cmfsS2Month] := (sysClientRec^.cfReporting_Period = roSendEveryTwoMonths);
            if (FSubFilter and cmfsBits[cmfsS3Month]) = cmfsBits[cmfsS3Month] then
              Filtered[cmfsS3Month] := (sysClientRec^.cfReporting_Period = roSendEveryThreeMonths);
            if (FSubFilter and cmfsBits[cmfsS4Month]) = cmfsBits[cmfsS4Month] then
              Filtered[cmfsS4Month] := (sysClientRec^.cfReporting_Period = roSendEveryFourMonths);
            if (FSubFilter and cmfsBits[cmfsS6Month]) = cmfsBits[cmfsS6Month] then
              Filtered[cmfsS6Month] := (sysClientRec^.cfReporting_Period = roSendEverySixMonths);
            if (FSubFilter and cmfsBits[cmfsSAnnual]) = cmfsBits[cmfsSAnnual] then
              Filtered[cmfsSAnnual] := (sysClientRec^.cfReporting_Period = roSendAnnually);
            if (FSubFilter and cmfsBits[cmfsSMQ]) = cmfsBits[cmfsSMQ] then
              Filtered[cmfsSMQ] := (sysClientRec^.cfReporting_Period = roSendEveryMonthQuarter);
            if (FSubFilter and cmfsBits[cmfsSM2M]) = cmfsBits[cmfsSM2M] then
              Filtered[cmfsSM2M] := (sysClientRec^.cfReporting_Period = roSendEveryMonthTwoMonths);
            if (FSubFilter and cmfsBits[cmfsS2MM]) = cmfsBits[cmfsS2MM] then
              Filtered[cmfsS2MM] := (sysClientRec^.cfReporting_Period = roSendEveryTwoMonthsMonth);
          end;
          AddToData := True;
          for i := cmfsTopMin to cmfsTopMax do
          begin
            IncludedInFilter := False;
            for j := cmfsMin to cmfsMax do
            begin
              if cmfsFilterGroup[j] = i then
              begin
                if ((FSubFilter AND cmfsBits[j]) = cmfsBits[j])
                or ((j = cmfsUnassigned) and (FUserFilter.Count > 0))
                or ((j = cmfsUnassignedGroup) and (FGroupFilter.Count > 0))
                or ((j = cmfsUnassignedClientType) and (FClientTypeFilter.Count > 0)) then
                  IncludedInFilter := True;
                Grouped[i] := Grouped[i] OR Filtered[j];
              end;
            end;
            if not IncludedInFilter then
              Grouped[i] := True;
            AddToData := AddToData AND Grouped[i];
          end;

          if (FViewMode = vmMyFiles)
          and (CurrUser.LRN <> sysClientRec.cfUser_Responsible) then
            AddToData := False; // Not My File
        end;

        if AddToData then begin
           pIDRec := FIntermediateDataList.Add;
           pIDRec^.imCode    := sysClientRec^.cfFile_Code;
           pIDRec^.imName    := sysClientRec^.cfFile_Name;
           pIDRec^.imGroupID := 0;
           pIDRec^.imData    := sysClientRec;
           pIDRec^.imTag     := 0;
           pIDRec^.imType    := sysClientRec^.cfClient_Type;
           pIDRec^.imSendMethod     := sysClientRec^.cfFile_Transfer_Method;
           pIDRec^.imOnlineStatusDesc := '';
           pIDRec^.imModifiedDate   := 0;
           pIDRec^.imOnlineStatus   := cfsNoFile;
        end;
      end;
    end;
  end else if (FFrameUseMode = fumGetOnline) and (FFilterMode = fmFilesForCheckIn) then
    //Client list is generated from Banklink Online status
  else begin
    //load all files in the bk5 directory
    Found := FindFirst( FFilesDirectory + '*' + Globals.FileExtn, faAnyFile, SearchRec);
    try
      while ( Found = 0 ) Do
      begin
        //file found, try to read wrapper
        try
          GetClientWrapper( FFilesDirectory + SearchRec.Name, Wrapper, ( FFilterMode = fmFilesForCheckIn));

        except
          on E : Exception do
          begin
            //unable to read the wrapper, Clear the wrapper, add the error
            FillChar(Wrapper, SizeOf(Wrapper), #0);
            Wrapper.wSignature := ERROR_SIGNATURE;
            Wrapper.wName := 'ERROR: ' + E.Message;
          end;
        end;

        //Load into client files list
        if (Wrapper.wSignature = BANKLINK_SIGNATURE) then
        begin
          //Filter BankLink Online files
          if (FFilterMode = fmFilesForCheckOut) and
             not IncludeClientInList(Wrapper.wFileTransferMethod) then begin
            Found := FindNext( SearchRec );
            Continue;
          end;

          pIDRec := FIntermediateDataList.Add;
          pIDRec^.imCode    := Wrapper.wCode;
          pIDRec^.imName    := Wrapper.wName;
          pIDRec^.imGroupID := 0;
          pIDRec^.imData    := nil;
          pIDRec^.imTag     := 0;
          pIDRec^.imType    := ctActive;
//          pIDRec^.imSendMethod     := Byte(ftmOnline);
          pIDRec^.imSendMethod       := Wrapper.wFileTransferMethod;
          pIDRec^.imOnlineStatusDesc := '';
          pIDRec^.imModifiedDate   := 0;
          pIDRec^.imOnlineStatus   := cfsNoFile;

          //if we are doing a update and we have an admin system then check
          //the file status
          if FUsingAdminSystem then
          begin
            sysClientRec := AdminSnapshot.fdSystem_Client_File_List.FindCode( Wrapper.wCode);
            pIDRec^.imData := sysClientRec;
          end
          else
            if ( FFilterMode = fmFilesForCheckIn) then begin
              //Update at offsite, see if file already exists
              //a conflict situation occurs only if the existing file is
              //currently writable
              //ie user is trying to update a file over the top of an
              //existing valid file.
              if BKFileExists( DataDir + SearchRec.Name) then
              begin
                try
                  GetClientWrapper( DataDir + SearchRec.Name, WrapperOfExistingFile, False);
                  if WrapperOfExistingFile.wRead_Only then
                    pIDRec^.imTag := 0
                  else
                    pIDRec^.imTag := Tag_CheckInConflict;
                except
                  on E : Exception do
                  begin
                    //unable to read the wrapper, create a dummy wrapper with the error
                    //assume that a conflict will exist
                    pIDRec^.imTag := Tag_CheckInConflict;
                  end;
                end;
              end;
            end else if ( Wrapper.wRead_Only) then
              pIDRec^.imTag := Tag_ReadOnlyFile;
        end
        else
        begin
          //this is not a banklink file!
          S := Copy( SearchRec.Name, 1, Pos( '.', SearchRec.Name) -1);

          pIDRec := FIntermediateDataList.Add;
          pIDRec^.imCode    := S;

          if Wrapper.wSignature = ERROR_SIGNATURE then
            pIDRec^.imName := Wrapper.wName
          else
            pIDRec^.imName    := 'ERROR: This is not a BankLink file!';

          pIDRec^.imGroupID := 0;
          pIDRec^.imData    := nil;
          pIDRec^.imTag     := Tag_CheckInConflict;
          pIDRec^.imOnlineStatusDesc := '';
          pIDRec^.imModifiedDate   := 0;
          pIDRec^.imOnlineStatus   := cfsNoFile;
        end;
        Found := FindNext( SearchRec );
      end;
    finally
       FindClose(SearchRec);
    end;
  end;

  //Get status if using BankLink Online
  if (FFrameUseMode in [fumGetOnline, fumSendOnline]) then
    RefeshBankLinkOnlineStatus;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.SetViewMode(const Value: TViewMode);
begin
  FViewMode := Value;
  if vtClients.Header.Columns.Count > 0 then
    LoadNodes( true); //reload the data
end;

procedure TfmeClientLookup.UpdateActions;
   function ProcessInVisible : Boolean;
   var I: integer;
   begin
     Result := True;
     for I := 0 to vtClients.Header.Columns.Count - 1 do
        if vtClients.Header.Columns[I].Tag = Ord(cluProcessing) then begin
            // Found the column
            Result := (vtClients.Header.Columns[I].Left > vtClients.Width)
                   or (vtClients.Header.Columns[I].Left + vtClients.Header.Columns[I].Width < 0)
        end;
   end;
begin
   BtnRight.Enabled := ProcStatOffset > MinProcOffset;
   BtnLeft.Enabled := ProcStatOffset < MaxProcOffset;
   FProcStatDate := 0; // Make sure it stays updated;
   if BtnLeft.Visible then
      if ProcessInVisible then begin
         BtnLeft.Visible := False;
         BtnRight.Visible := False;
      end;
end;


procedure TfmeClientLookup.UpdateCount;
begin
   if Assigned (OnUpdateCount) then
     OnUpdateCount(Self);
end;

procedure TfmeClientLookup.UpdateOnlineStatus;
var
  i, j: integer;
  ClientStatus : TClientStatusItem;
  pIDRec: pIntermediateDataRec;
  BK5FileName: string;
  WrapperOfExistingFile: TClientWrapper;
  sysClientRec: pClient_File_Rec;
  AddNew: Boolean;
  Online: Boolean;
begin
  if Assigned(FClientStatusList) then begin
    //Update status of existing intermediate records
    for i := FIntermediateDataList.First to FIntermediateDataList.Last do begin
      Online := False;
      pIDRec := FIntermediateDataList.IntermediateData_At(i);
      for j := 0 to FClientStatusList.Count - 1 do begin
        ClientStatus := FClientStatusList.Items[j];
        if (pIDRec^.imCode = ClientStatus.ClientCode) then begin
          Online := True;
          pIDRec^.imOnlineStatusDesc := ClientStatus.StatusDesc;
          pIDRec^.imModifiedDate     := ClientStatus.LastChange;
          pIDRec^.imOnlineStatus     := ClientStatus.StatusCode;
          //Hide online status for non-online files in Books send online
          if not Assigned(Adminsystem) and (FFrameUseMode = fumSendOnline) and
             (pIDRec^.imSendMethod <> ftmOnline) then begin
            pIDRec^.imOnlineStatusDesc := '';
            pIDRec^.imModifiedDate := 0;
          end;
        end;
      end;

      if (not Online) and
         (not Assigned(Adminsystem)) and
         (pIDRec^.imSendMethod = ftmOnline) then
        pIDRec^.imSendMethod := ftmNone;
    end;
    //Remove online files that the current Books user doesn't have access to i.e no status returned
    if (not Assigned(Adminsystem)) and (FFilterMode <> fmNoFilter) then begin
      for i := FIntermediateDataList.Last downto FIntermediateDataList.First do begin
        Online := False;
        pIDRec := FIntermediateDataList.IntermediateData_At(i);
        for j := 0 to FClientStatusList.Count - 1 do begin
          ClientStatus := FClientStatusList.Items[j];
          if (pIDRec^.imCode = ClientStatus.ClientCode) then
            Online := True;
        end;
        if not Online then
          FIntermediateDataList.Delete(pIDRec);
      end;
    end;
    //Add new intermediate records
    for j := 0 to FClientStatusList.Count - 1 do begin
      ClientStatus := FClientStatusList.Items[j];
      AddNew := True;
      if (ClientStatus.StatusCode = cfsNoFile)  then
        AddNew := False
      else if FFrameUseMode = fumSendOnline then
        AddNew := False            
      else begin
        for i := FIntermediateDataList.First to FIntermediateDataList.Last do begin
          pIDRec := FIntermediateDataList.IntermediateData_At(i);
          if (pIDRec^.imCode = ClientStatus.ClientCode) then begin
            AddNew := False;
            Break;
          end;
        end;
      end;
      if AddNew then begin
        pIDRec := FIntermediateDataList.Add;
        pIDRec^.imCode    := ClientStatus.ClientCode;
        pIDRec^.imName    := ClientStatus.ClientName;
        pIDRec^.imGroupID := 0;
        pIDRec^.imData    := nil;
        pIDRec^.imTag     := 0;
        pIDRec^.imType    := ctActive;
        pIDRec^.imSendMethod       := Byte(ftmOnline);
        pIDRec^.imOnlineStatusDesc := ClientStatus.StatusDesc;
        pIDRec^.imModifiedDate     := ClientStatus.LastChange;
        pIDRec^.imOnlineStatus     := ClientStatus.StatusCode;

        //if we are doing an update and we have an admin system then check the file status
        if FUsingAdminSystem then begin
          sysClientRec := AdminSnapshot.fdSystem_Client_File_List.FindCode(ClientStatus.ClientCode);
          pIDRec^.imData := sysClientRec;
        end else begin
          //Update at offsite, see if file already exists
          //a conflict situation occurs only if the existing file is
          //currently writable
          //ie user is trying to update a file over the top of an
          //existing valid file.
          BK5FileName := Format('%s%s%s', [DataDir, ClientStatus.ClientCode, FILEEXTN]);
          if BKFileExists(BK5FileName) then begin
            try
              GetClientWrapper(BK5FileName , WrapperOfExistingFile, False);
              if WrapperOfExistingFile.wRead_Only then
                pIDRec^.imTag := 0
              else
                pIDRec^.imTag := Tag_CheckInConflict;
            except
              on E: Exception do
                begin
                  //unable to read the wrapper, create a dummy wrapper with the error
                  //assume that a conflict will exist
                  pIDRec^.imTag := Tag_CheckInConflict;
                end;
            end;
          end;
        end;
      end;
    end;
  end;
  Self.vtClients.Refresh;
end;

procedure TfmeClientLookup.vtClientsGetHint(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  NodeData: pTreeData;
  MousePos : TPoint;
  CellRect : TRect;
  function GetProcessingHint: string;
  var LN: Integer;
  begin
     if MousePos.X > (LEDOffset + ProcStatBtnW) then
        ln := ((MousePos.X - (LEDOffset + ProcStatBtnW)) div (LEDWidth + LEDSpacing)) + 1
      else
         ln := 0;
      if (ln > 12) or (ln < 1) then
         exit;
      Result := Date2Str( IncDate(ProcStatDate,0,ln-12,0), 'nnn YYYY')
  end;
begin
  if FColumns.ColumnDefn_At( Column).FieldID <> cluProcessing then exit;
  try
    NodeData := vtClients.GetNodeData(Node);
    if Assigned(NodeData) then
    begin
      MousePos := Mouse.CursorPos;
      MousePos := vtClients.ScreenToClient(MousePos);
      CellRect := vtClients.GetDisplayRect(Node, Column, False);
      Dec(MousePos.X, CellRect.Left);
      CellText := GetProcessingHint;
    end;
  except
  end;
end;

procedure TfmeClientLookup.vtClientsGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
begin
  vtClientsGetTextEx(Sender, Node, Column, TextType, cluUnknown, False, CellText);
end;

procedure TfmeClientLookup.vtClientsGetTextEx(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; cID: TClientLookupCol;
  ProcAsText: Boolean; var CellText: WideString);
var
  NodeData : pTreeData;
  pIDRec   : pIntermediateDataRec;
  sysClientRec   : pClient_File_Rec;
  S              : string;
  ByName         : string;
  pUser          : pUser_Rec;
  pGroup         : pGroup_Rec;
  pClientType    : pClient_Type_Rec;
  i: Integer;
  Period, CD, M, MM, EM, Y, D: Integer;
  FoundIndex : integer;
  ClientCode : String;
  ProdIndex : integer;
  ProdGuid : TBloGuid;

  function FindClientIndex: integer;
  var
    j: integer;
  begin
    Result := -1;
    for j := low(ProductConfigService.Clients.Clients) to
             high(ProductConfigService.Clients.Clients) do
    begin
      ClientCode := ProductConfigService.Clients.Clients[j].ClientCode;
      if ClientCode = sysClientRec^.cfFile_Code then
      begin
        Result := j;
        break;
      end;
    end;
  end;

begin
  CellText := '';

  NodeData := Sender.GetNodeData( Node);
  if NodeData = nil then
    Exit;

  if cID <> cluUnknown then
    for i := 0 to FColumns.Count-1 do
    begin
      if FColumns.ColumnDefn_At( i).FieldID = cID then
      begin
        Column := i;
        Break;
      end;
    end;

  //see what type of node this is
  case NodeData.tdNodeType of
    ntGroup :
    begin
      if Column = 0 then
        CellText := gidNames[ NodeData.tdFolderID]
      else
        Exit;
    end;

    ntClient :
    begin
      //make sure column requested is in range
      if not ((Column >= 0) and ( Column < FColumns.Count)) then
        Exit;

      pIDRec := NodeData.tdData;
      if not Assigned( pIDRec) then
        Exit;

      //fill files that are contained in intermediate rec
      //need to get field id from columns object
      case FColumns.ColumnDefn_At( Column).FieldID of
        cluCode : CellText := pIDRec^.imCode;
        cluName : CellText := PIDRec^.imName;
        cluBankLinkOnline : CellText := PIDRec^.imOnlineStatusDesc;
        cluModifiedDate   : begin
                              CellText := '';
                              if (PIDRec^.imModifiedDate <> 0) then
                                CellText := FormatDateTime('dd/mm/yyyy', PIDRec^.imModifiedDate);
                            end;
      end;

      //now look for fields inside data
      if ( pIDRec^.imData = nil) or ( not FUsingAdminSystem) then
      begin
        if FColumns.ColumnDefn_At( Column).FieldID = cluStatus then
        begin
          if pIDRec^.imTag = Tag_ReadOnlyFile then
            CellText := 'Read-Only';
        end;

        //data is from disk so no other fields exist
        Exit;
      end
      else
      begin
        sysClientRec := pIDRec^.imData;

        case FColumns.ColumnDefn_At( Column).FieldID of
          cluType:
            CellText := ctNames[pIDRec^.imType];
          cluStatus:
          begin
            if sysClientRec^.cfFile_Status = bkconst.fsNormal then
              Exit
            else
            begin
              //get the user who did this
              ByName := '';
              if sysClientRec^.cfCurrent_User <> 0 then
              begin
                pUser := AdminSnapshot.fdSystem_User_List.FindLRN( sysClientRec^.cfCurrent_User );
                if Assigned( pUser ) then
                  if pUser^.usName <> '' then
                    ByName := pUser.usName
                  else
                    ByName := pUser.usCode;
              end;

              case sysClientRec^.cfFile_Status of
                bkconst.fsOpen       :
                  begin
                    if ByName <> '' then
                      S := 'Opened by ' + ByName
                    else
                      S := 'Open';
                  end;
                bkconst.fsCheckedOut,
                bkconst.fsOffsite:
                  begin
                    S := 'Read-only';
                    if ByName <> '' then
                      S := S + ' by ' + ByName;
                  end;
              else
                S := '';
              end;
            end;
            CellText := S;
          end;

          cluUser :
          begin
            //first see if this client is part of our admin system
            if sysClientRec^.cfForeign_File then
              exit
            else
            begin
              //find the user in our system assigned to this client
              if sysClientRec^.cfUser_Responsible > 0 then
              begin
                S := '';
                pUser := AdminSnapshot.fdSystem_User_List.FindLRN( sysClientRec^.cfUser_Responsible );
                if Assigned( pUser ) then
                begin
                  if pUser^.usName <> '' then
                    S := pUser.usName
                  else
                    S := pUser.usCode;
                end
                else
                  S := 'Unknown User';

                CellText := S;
              end;
            end;
          end;

          cluGroup :
          begin
            //first see if this client is part of our admin system
            if sysClientRec^.cfForeign_File then
              exit
            else
            begin
              //find the user in our system assigned to this client
              if sysClientRec^.cfGroup_LRN > 0 then
              begin
                S := '';
                pGroup := AdminSnapshot.fdSystem_Group_List.FindLRN( sysClientRec^.cfGroup_LRN );
                if Assigned( pGroup ) then
                  S := pGroup.grName
                else
                  S := 'Unknown Group';

                CellText := S;
              end;
            end;
          end;

          cluClientType :
          begin
            //first see if this client is part of our admin system
            if sysClientRec^.cfForeign_File then
              exit
            else
            begin
              //find the user in our system assigned to this client
              if sysClientRec^.cfClient_Type_LRN > 0 then
              begin
                S := '';
                pClientType := AdminSnapshot.fdSystem_Client_Type_List.FindLRN( sysClientRec^.cfClient_Type_LRN );
                if Assigned( pClientType ) then
                  S := pClientType.ctName
                else
                  S := 'Unknown Client Type';

                CellText := S;
              end;
            end;
          end;

          cluReportingPeriod :
          begin
            if sysClientRec^.cfReporting_Period > roDontSendReports then
            begin
              if not ( sysClientRec^.cfReporting_Period in [ roMin..roMax]) then
                Exit;

              CellText := stDatetoDateString('NNN', sysClientRec^.cfReport_Start_Date, true) + ' - ' + roNames[ sysClientRec^.cfReporting_Period];
            end;
          end;

          cluContactType :
          begin
            if ( sysClientRec^.cfContact_Details_To_Show in [ cdtMin..cdtMax]) then
              CellText := cdtNames[ sysClientRec^.cfContact_Details_To_Show];
          end;

          cluSendBy :
          begin
            if sysClientRec^.cfReporting_Period <> roDontSendReports then  // case 7608
            if ( sysClientRec^.cfSchd_Rep_Method_Filter > srdNone) then
            begin
              if not ( sysClientRec^.cfSchd_Rep_Method_Filter in [ srdMin..srdMax]) then
                Exit;

              CellText := srdNames[ sysClientRec^.cfSchd_Rep_Method_Filter];
            end;
          end;

          cluLastAccessed :
          begin
            if sysClientRec^.cfDate_Last_Accessed > 0 then
              CellText := BkDate2Str( sysClientRec^.cfDate_Last_Accessed);
          end;

          cluFinYearStarts :
          begin
            if sysClientRec^.cfFinancial_Year_Starts > 0 then
              CellText := BkDate2Str( sysClientRec^.cfFinancial_Year_Starts);
          end;

          cluAction :
          begin
            CellText := sysClientRec^.cfNext_ToDo_Desc;
          end;

          cluReminderDate :
          begin
            if sysClientRec^.cfNext_ToDo_Rem_Date > 0 then
              CellText := BkDate2Str( sysClientRec^.cfNext_ToDo_Rem_Date);
          end;

          cluNextGSTDue: CellText := BkDate2Str(GetNextGSTDueDate(STDate.CurrentDate, sysClientRec^.cfGST_Start_Month,
              sysClientRec^.cfGST_Period, AdminSystem.fdFields.fdCountry));

          cluProcessing:
            if ProcAsText then
            begin
              sysClientRec := GetSysClientRec( Sender, Node);

              with  GetClientStat(sysClientRec,ProcStatDate) do
              for Period := 1 to 12 do begin

                 if Transferred[Period] = rtFully then
                    CellText := CellText + bkBranding.TextTransferred
                 else if Finalized[Period] =  rtFully then
                    CellText := CellText + bkBranding.TextFinalised
                 else if Coded[Period] =  rtFully then
                    CellText := CellText + bkBranding.TextCoded
                 else if Coded[Period] in  [rtPartially,rtNone] then
                    CellText := CellText + bkBranding.TextUnCoded
                 else if (Downloaded[Period] in [rtFully,rtPartially]) then
                    CellText := CellText + bkBranding.TextDownloaded
                 else CellText := CellText + bkBranding.TextNoData;
              end;
            end;

          cluBOProduct :
          begin
            CellText := '';

            ProdGuid := FColumns.ColumnDefn_At(Column).ProdGuid;

            FoundIndex := FindClientIndex;
            if (FoundIndex > -1) then
            begin
              if ProductConfigService.Clients.Clients[FoundIndex].HasSubscription(ProdGuid) then
                CellText := #10004; // tick
            end;
          end;

          cluBOBillingFrequency :
          begin
            FoundIndex := FindClientIndex;
            if (FoundIndex > -1) then
            begin
              S := ProductConfigService.Clients.Clients[FoundIndex].BillingFrequency;
              if S = 'M' then
                CellText := 'Monthly'
              else if S = 'A' then
                CellText := 'Annually'
              else
                CellText := S;
            end;
          end;

          cluBOUserAdmin :
          begin

          end;

          cluBOAccess:
          begin
            FoundIndex := FindClientIndex;
            if (FoundIndex > -1) then
              CellText := ProductConfigService.Clients.Clients[FoundIndex].StatusString;
              // ProductConfigService.Clients.Clients[FoundIndex].Status;
          end;
        end;
      end;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.vtClientsPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  NodeData : pTreeData;
  ColID    : TClientLookupCol;
  sysClientRec : pClient_File_Rec;
  pIDRec   : pIntermediateDataRec;
begin

  NodeData := Sender.GetNodeData( Node);
  if nodeData = nil then
    Exit;

  if NodeData.tdNodeType = ntGroup then
  begin
    TargetCanvas.Font := appimages.Font;
    TargetCanvas.Font.Style  := [fsBold];
  end;

  if NodeData.tdNodeType = ntClient then
  begin
    ColID := FColumns.ColumnDefn_At( Column).FieldID;

{    if (ColID = cluName) or (ColID=cluCode) then
    begin
      sysClientRec := GetSysClientRec( Sender, Node);
      if Assigned(sysClientRec) then
      begin
        if pos(UpperCase(SearchText),UpperCase(sysClientRec^.cfFile_Name))>0 then
        begin
          //TargetCanvas.Font.Color := clGreen;
        end;
      end;
    end;}

    if ColID = cluReminderDate then
    begin
      sysClientRec := GetSysClientRec( Sender, Node);
      if Assigned( sysClientRec) then
      begin
        if ( sysClientRec^.cfNext_ToDo_Rem_Date < stDate.CurrentDate) and
           ( TargetCanvas.Brush.Color <> clHighlight) then
          TargetCanvas.Font.Color := clRed;
      end;
    end
    else
    if ColID = cluBOProduct then
    begin
      TargetCanvas.Font.Color := clGreen;
      TVirtualStringTree(Sender).Header.Columns[Column].Alignment := taCenter;
    end
    else begin
      pIDRec := GetIntermediateDataFromNode( Node);
      if Assigned( pIDRec) and Assigned( MyClient) then
      begin
        if ( pIDRec^.imCode = MyClient.clFields.clCode) and
           ( TargetCanvas.Brush.Color <> clHighlight) then
          TargetCanvas.Font.Color := clBlue;
      end;
    end;
    if not Assigned(Adminsystem) and Assigned(pIDRec) then begin
      case FFrameUseMode of
        fumSendFile  : if (pIDRec.imSendMethod = ftmOnline) then
                         Node.States := Node.States + [vsDisabled];
        fumSendOnline: if (pIDRec.imSendMethod <> ftmOnline) then
                         Node.States := Node.States + [vsDisabled];
      end;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CompareReminderDate( Date1, Date2 : integer) : integer;
//order is
//
//   Overdue
//   Due today
//   Blank
//   Not due yet
const
  DueNow   = 0;
  NoDate   = 1;
  DueLater = 2;
var
  TodaysDate   : integer;
  SubGroup1    : integer;
  SubGroup2    : integer;
begin
  TodaysDate := CurrentDate;

  //split the items into group and sort first by that group
  if ( Date1 <= TodaysDate) and ( Date1 <> 0) then
    SubGroup1 := DueNow
  else if ( Date1 <> 0) then
    SubGroup1 := DueLater
  else
    SubGroup1 := NoDate;

  if ( Date2 <= TodaysDate) and ( Date2 <> 0) then
    SubGroup2 := DueNow
  else if ( Date2 <> 0) then
    SubGroup2 := DueLater
  else
    SubGroup2 := NoDate;

  //sort
  if ( SubGroup1 < SubGroup2) then
    result := -1
  else
  if ( SubGroup1 > SubGroup2) then
    result := 1
  else
  begin
    //in same subgroup, sort by reminder date
    result := CompareValue( Date1, Date2);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.vtClientsCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  NodeData1 : pTreeData;
  NodeData2 : pTreeData;
  FieldID   : TClientLookupCol;

  pIDRec1   : pIntermediateDataRec;
  pIDRec2   : pIntermediateDataRec;

  sysRec1   : pClient_File_Rec;
  sysRec2   : pClient_File_Rec;

  String1  : string;
  String2  : string;
  DisplayText : WideString;
begin
  Result := 0;

  NodeData1 := Sender.GetNodeData( Node1);
  NodeData2 := Sender.GetNodeData( Node2);

  FieldID   := FColumns.GetColumnFieldID( Column);
  if FieldID = cluUnknown then
    exit;

  if ( NodeData1.tdNodeType = ntClient) and ( NodeData2.tdNodeType = ntClient) then
  begin
    pIDRec1   := GetIntermediateDataFromNode( Node1);
    pIDRec2   := GetIntermediateDataFromNode( Node2);

    sysRec1   := GetSysClientDataFromNode( Node1);
    sysRec2   := GetSysClientDataFromNode( Node2);

    if not (Assigned( pIDRec1) and Assigned( pIDRec2)) then
      Exit;

    if not ( Assigned( sysRec1) and Assigned( sysRec2)) then
    begin
      case FieldID of
        cluName           : Result := STStrS.CompStringS( Uppercase(pIDRec1.imName), Uppercase( pIDRec2.imName));
        cluBankLinkOnline : Result := CompareStr( pIDRec1.imOnlineStatusDesc, pIDRec2.imOnlineStatusDesc);
        cluModifiedDate   : Result := Round(pIDRec1.imModifiedDate - pIDRec2.imModifiedDate);
      end;
    end
    else
    begin
      //if the sysRecs are not assigned then can only sort by name or code
      case FieldID of
        cluName   : result := STStrS.CompStringS( Uppercase(pIDRec1.imName), Uppercase( pIDRec2.imName));
        cluUser, cluGroup, cluClientType :
        begin
          //get screen fields
          vtClientsGetText( Sender, Node1, Column, ttNormal, DisplayText );
          String1 := DisplayText;
          vtClientsGetText( Sender, Node2, Column, ttNormal, DisplayText );
          String2 := DisplayText;
          //compare
          result := StrComp( pChar( String1), pChar( String2));
        end;
        cluReportingPeriod :
        begin
          if FSortType = stMonth then
            result := CompareValue( sysRec1.cfReport_Start_Date, sysRec2.cfReport_Start_Date)
          else
            result := CompareValue( sysRec1.cfReporting_Period, sysRec2.cfReporting_Period);
        end;
        cluNextGSTDue:
        begin
          result := CompareValue(
            GetNextGSTDueDate(STDate.CurrentDate, sysRec1.cfGST_Start_Month,
              sysRec1.cfGST_Period, AdminSystem.fdFields.fdCountry),
            GetNextGSTDueDate(STDate.CurrentDate, sysRec2.cfGST_Start_Month,
              sysRec2.cfGST_Period, AdminSystem.fdFields.fdCountry));
        end;
        cluSendBy :                               
        begin
          result := CompareValue( sysRec1.cfSchd_Rep_Method_Filter, sysRec2.cfSchd_Rep_Method_Filter);
        end;
        cluLastAccessed :
        begin
          result := CompareValue( sysRec1^.cfDate_Last_Accessed, sysRec2^.cfDate_Last_Accessed);
        end;
        cluContactType :
        begin
          result := CompareValue( sysRec1^.cfContact_Details_To_Show, sysRec2^.cfContact_Details_To_Show);
        end;
        cluAction:
        begin
          //get screen fields
          vtClientsGetText( Sender, Node1, Column, ttNormal, DisplayText );
          String1 := Uppercase(DisplayText);
          vtClientsGetText( Sender, Node2, Column, ttNormal, DisplayText );
          String2 := Uppercase(DisplayText);
          //compare
          result := StrComp( pChar( String1), pChar( String2));
        end;
        cluReminderDate :
        begin
          result := CompareReminderDate( sysRec1^.cfNext_ToDo_Rem_Date, sysRec2^.cfNext_ToDo_Rem_Date);
        end;
        cluFinYearStarts :
        begin
          result := CompareReminderDate( sysRec1^.cfFinancial_Year_Starts, sysRec2^.cfFinancial_Year_Starts);
        end;
        cluProcessing:
        begin
          vtClients.Header.SortColumn    := FColumns.FindColumnIndex( cluCode);
          vtClients.Header.SortDirection := SortDirection;
        end;
        cluBankLinkOnline :
        begin
           result := CompareStr( pIDRec1.imOnlineStatusDesc, pIDRec2.imOnlineStatusDesc);
        end;
        cluModifiedDate :
        begin
           result := Round(pIDRec1.imModifiedDate - pIDRec2.imModifiedDate);
        end;
      end;
    end;

    //if still same then sort by code
    if result = 0 then
      result := STStrS.CompStringS( pIDRec1.imCode, pIDRec2.imCode);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfmeClientLookup.GetIntermediateDataFromNode( aNode: pVirtualNode): pIntermediateDataRec;
var
  NodeData : pTreeData;
begin
  NodeData := vtClients.GetNodeData( aNode);
  if Assigned( NodeData) then
    result := NodeData.tdData
  else
    result := nil;
end;
function TfmeClientLookup.GetCodeBelowSelection: string;
var
  FirstSelected: pVirtualNode;
  NextNode: pVirtualNode;
  NodeData : pTreeData;
  pIDRec : pIntermediateDataRec;
begin
  FirstSelected := vtClients.GetFirstSelected;
  Result := '';
  if Assigned(FirstSelected) then
  begin
    NextNode :=  vtClients.GetNext(FirstSelected);
    if Assigned(NextNode) then
    begin
      NodeData := vtClients.GetNodeData( NextNode);
      if NodeData.tdNodeType = ntClient then
      begin
        pIDRec := GetIntermediateDataFromNode( NextNode);
        Result := pIDRec.imCode;
      end;
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfmeClientLookup.GetSysClientDataFromNode(aNode: pVirtualNode): pClient_File_Rec;
var
  pIDRec : pIntermediateDataRec;
begin
  pIDRec := GetIntermediateDataFromNode( aNode);
  if Assigned( pIDRec) then
    result := pIDRec.imData
  else
    result := nil;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.vtClientsHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
//forces a resort of the tree
var
  OldCol : TColumnIndex;
  ScrollPos : integer;
begin
  if Button = mbRight then exit; // will show popup menu
  
  OldCol := vtClients.Header.SortColumn;
  ScrollPos := vtClients.OffsetX;

  vtClients.BeginUpdate;
  try
    if vtClients.Header.SortColumn > NoColumn then
        vtClients.Header.Columns[vtClients.Header.SortColumn].Options := vtClients.Header.Columns[vtClients.Header.SortColumn].Options + [coParentColor];

    if Column <> OldCol then
    begin
      vtClients.Header.SortColumn           := Column;
      vtClients.Header.SortDirection        := sdAscending;

      FSortType := stMonth; // 1. Starts with month ascending

      FSelectedColumn := FColumns.GetColumnFieldID( vtClients.Header.SortColumn);

      //reload the nodes
      LoadNodes( false);

      if Assigned( FOnSortChanged) then
        FOnSortChanged( Self);

      //reposition left most col
      vtClients.OffsetX := ScrollPos;
    end
    else
    begin
      //just reverse the direction as col hasn't changed
      if FColumns.GetColumnFieldID(Column) = cluReportingPeriod then // switch type
      begin
          if (FSortType = stMonth) and (vtClients.Header.SortDirection = sdAscending) then
            vtClients.Header.SortDirection := sdDescending // 2. Month descending
          else if (FSortType = stMonth) and (vtClients.Header.SortDirection = sdDescending) then
          begin // 3. Schedule ascending
            vtClients.Header.SortDirection := sdAscending;
            FSortType := stSchedule;
          end
          else if (FSortType = stSchedule) and (vtClients.Header.SortDirection = sdAscending) then
            vtClients.Header.SortDirection := sdDescending // 4. Schedule Descending
          else // stSchedule and descending
          begin // 5. And back to Month Ascending
            vtClients.Header.SortDirection := sdAscending;
            FSortType := stMonth;
          end;
      end
      else
      begin
        if vtClients.Header.SortDirection = sdAscending then
          vtClients.Header.SortDirection := sdDescending
        else
          vtClients.Header.SortDirection := sdAscending;
      end;

      with vtClients.Header do
        vtClients.SortTree( SortColumn, SortDirection);
    end;

  finally
    vtClients.EndUpdate;
  end;
end;




// XP style header button legacy code. This procedure is only used on non-XP systems to simulate the themed
// header style.
// Note: the theme elements displayed here only correspond to the standard themes of Windows XP

const
  XPMainHeaderColorUp = $DBEAEB;       // Main background color of the header if drawn as being not pressed.
  XPMainHeaderColorDown = $D8DFDE;     // Main background color of the header if drawn as being pressed.
  XPMainHeaderColorHover = $F3F8FA;    // Main background color of the header if drawn as being under the mouse pointer.
  XPDarkSplitBarColor = $B2C5C7;       // Dark color of the splitter bar.
  XPLightSplitBarColor = $FFFFFF;      // Light color of the splitter bar.
  XPDarkGradientColor = $B8C7CB;       // Darkest color in the bottom gradient. Other colors will be interpolated.
  XPDownOuterLineColor = $97A5A5;      // Down state border color.
  XPDownMiddleLineColor = $B8C2C1;     // Down state border color.
  XPDownInnerLineColor = $C9D1D0;      // Down state border color.



procedure TfmeClientLookup.vtClientsHeaderDraw(Sender: TVTHeader;
  HeaderCanvas: TCanvas; Column: TVirtualTreeColumn; R: TRect; Hover,
  Pressed: Boolean; DropMark: TVTDropMarkMode);
var
  Dots: Boolean;



  procedure FillHeaderRect (Canvas: TCanvas; ButtonR : TRect);
  var Details: TThemedElementDetails;
      PaintBrush: HBRUSH;
      Pen,
      OldPen: HPEN;
      PenColor,
      FillColor: COLORREF;
      dRed, dGreen, dBlue: Single;

  begin
     if tsUseThemes in Sender.Treeview.TreeStates then begin
        if Pressed then
           Details := ThemeServices.GetElementDetails(thHeaderItemPressed)
        else if Hover then
           Details := ThemeServices.GetElementDetails(thHeaderItemHot)
        else
           Details := ThemeServices.GetElementDetails(thHeaderItemNormal);
        ThemeServices.DrawElement(Canvas.Handle, Details, ButtonR, @ButtonR);
     end else begin
        inc( ButtonR.Left);
        FillColor := XPMainHeaderColorUp;
        PaintBrush := CreateSolidBrush(FillColor);
        FillRect(Canvas.Handle, ButtonR, PaintBrush);
        DeleteObject(PaintBrush);

        // One solid pen for the dark line...
        Pen := CreatePen(PS_SOLID, 1, XPDarkSplitBarColor);
        OldPen := SelectObject(Canvas.Handle, Pen);
        MoveToEx(Canvas.Handle, ButtonR.Right - 2, ButtonR.Top + 3, nil);
        LineTo(Canvas.Handle, ButtonR.Right - 2, ButtonR.Bottom - 5);
        // ... and one solid pen for the light line.
        Pen := CreatePen(PS_SOLID, 1, XPLightSplitBarColor);
        DeleteObject(SelectObject(Canvas.Handle, Pen));
        MoveToEx(Canvas.Handle, ButtonR.Right - 1, ButtonR.Top + 3, nil);
        LineTo(Canvas.Handle, ButtonR.Right - 1, ButtonR.Bottom - 5);
        SelectObject(Canvas.Handle, OldPen);
        DeleteObject(Pen);

        // There is a three line gradient near the bottom border which transforms from the button color to a dark,
        // clBtnFace like color (here XPDarkGradientColor).
        PenColor := XPMainHeaderColorUp;
        dRed := ((PenColor and $FF) - (XPDarkGradientColor and $FF)) / 3;
        dGreen := (((PenColor shr 8) and $FF) - ((XPDarkGradientColor shr 8) and $FF)) / 3;
        dBlue := (((PenColor shr 16) and $FF) - ((XPDarkGradientColor shr 16) and $FF)) / 3;

        // First line:
        PenColor := PenColor - Round(dRed) - Round(dGreen) shl 8 - Round(dBlue) shl 16;
        Pen := CreatePen(PS_SOLID, 1, PenColor);
        OldPen := SelectObject(Canvas.Handle, Pen);
        MoveToEx(Canvas.Handle, ButtonR.Left, ButtonR.Bottom - 3, nil);
        LineTo(Canvas.Handle, ButtonR.Right, ButtonR.Bottom - 3);

        // Second line:
        PenColor := PenColor - Round(dRed) - Round(dGreen) shl 8 - Round(dBlue) shl 16;
        Pen := CreatePen(PS_SOLID, 1, PenColor);
        DeleteObject(SelectObject(Canvas.Handle, Pen));
        MoveToEx(Canvas.Handle, ButtonR.Left, ButtonR.Bottom - 2, nil);
        LineTo(Canvas.Handle, ButtonR.Right, ButtonR.Bottom - 2);

        // Third line:
        Pen := CreatePen(PS_SOLID, 1, XPDarkGradientColor);
        DeleteObject(SelectObject(Canvas.Handle, Pen));
        MoveToEx(Canvas.Handle, ButtonR.Left, ButtonR.Bottom - 1, nil);
        LineTo(Canvas.Handle, ButtonR.Right, ButtonR.Bottom - 1);

        // Housekeeping:
        DeleteObject(SelectObject(Canvas.Handle, OldPen));
    end;
  end;



  procedure DrawMonth(const CellRect: TRect; const TargetCanvas: TCanvas;
    Period: Integer; Month: string);
  var
    R: TRect;
    XOffset: Integer;
  begin
    XOffset := ProcStatBtnW + 11 * ( Period - 1 );
    R := CellRect;
    R.Right := R.Left + 12 ;
    R.Top   := R.Bottom - ProcStatBtnH;

    OffsetRect( R, XOffset+1,0 ) ; { Move it Right }
    if Dots
    and (R.Right -3  + TargetCanvas.TextExtent('...').cx > CellRect.Right) then
    begin
      Dots := False;
      TargetCanvas.TextOut(R.Left, R.Top, '...');
    end
    else if Dots then
      DrawText(TargetCanvas.Handle, PChar(Month), 1, R, DT_CENTER);
  end;

  procedure DrawYears(const CellRect: TRect; const TargetCanvas: TCanvas;
    Period, Y : Integer);
  var
    R: TRect;
    XOffset: Integer;

    function ShortYearText(Value : Integer): string;
    begin
       Value := value MOD 100;
       Result := '00';
       wvsprintf(Pchar(Result),'%02i',@Value);
    end;

  begin
     XOffset := ProcStatBtnW + 11 * ( Period - 1 );
     R := CellRect;
     R.Right := R.Left + XOffset;
     R.Bottom   := R.Top + ProcStatBtnH;
     //OffsetRect( R, XOffset+1,0 ) ; { Move it Right }
     FillHeaderRect(TargetCanvas,R);

     case Period of
     1..2 : DrawText(TargetCanvas.Handle, PChar(ShortYearText(Y)), -1, R, DT_CENTER);
     3  : DrawText(TargetCanvas.Handle, PChar(ShortYearText(Y)), -1, R, DT_CENTER);
     else DrawText(TargetCanvas.Handle, PChar(IntToStr(Y)), -1, R, DT_CENTER);
     end;

     R.Left := R.Right;

     if Period = 1 then
        R.Right := CellRect.Left + ProcStatBtnW + 11 * ( 12 )
     else
        R.Right := CellRect.Right;

     FillHeaderRect(TargetCanvas,R);
     Inc(Y);
     case Period of
     11..12 : DrawText(TargetCanvas.Handle, PChar(ShortYearText(Y)), -1, R, DT_CENTER);
     10  : DrawText(TargetCanvas.Handle, PChar(ShortYearText(Y)) , -1, R, DT_CENTER);
     else DrawText(TargetCanvas.Handle, PChar(IntToStr(Y)), -1, R, DT_CENTER);
     end;

     if Period = 1 then begin
        R.Left := R.Right;
        R.Right := CellRect.Right;
        FillHeaderRect(TargetCanvas,R);
        Inc(Y);
        DrawText(TargetCanvas.Handle, PChar(ShortYearText(Y)) , -1, R, DT_CENTER);
     end;

  end;


var
  i, M, Y: Integer;
begin
  inherited;
  if Column.Tag = Ord(cluProcessing) then
  begin

    // While we are here, move the buttons
    BtnLeft.SetBounds ( R.Left -1,
                        R.Bottom - ProcStatBtnH -2,
                        ProcStatBtnW,ProcStatBtnH);

    BtnRight.SetBounds( R.Right  - ProcStatBtnW + 1,
                        R.Bottom - ProcStatBtnH -2,
                        ProcStatBtnW,ProcStatBtnH);

    if not btnLeft.Visible then begin
       btnLeft.Visible := True;
       btnRight.Visible := True;
    end;
    FillHeaderRect(HeaderCanvas,R);
    Dots := True;
    StDateToDMY(ProcStatDate,I,M,Y);
    DecMY(M,Y,11);
    for i := 1 to 12 do begin
       DrawMonth(R, HeaderCanvas, i, Copy(StDateSt.MonthToString(M), 1, 1));
       if M = 1 then begin  // Beggining of the year
          DrawYears(R,HeaderCanvas,I,Pred(Y));
       end;
       IncMY(M,Y);
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.LocateCode(aCode: string);
var
  aNode : pVirtualNode;
  pIDRec : pIntermediateDataRec;
begin
  //make sure not already on that code
  if ( vtClients.SelectedCount = 1) and ( GetFirstSelectedCode = aCode) then
    exit;

  //search through the nodes for the specified code
  aNode := vtClients.GetFirst;
  while Assigned( aNode) do
  begin
    pIDRec := GetIntermediateDataFromNode( aNode);
    if Assigned( pIDRec) and ( pIDRec^.imCode = aCode) then
      Break;
    aNode := vtClients.GetNext( aNode);
  end;

  if Assigned( aNode) then
  begin
    vtClients.ClearSelection;
    vtClients.Selected[ aNode] := True;
    vtClients.FocusedNode := aNode;
    vtClients.ScrollIntoView(aNode, True);
  end
  else // Select first client if there is one (#1678)
  begin
    aNode := vtClients.GetFirst;
    if Assigned(aNode) then
    begin
      aNode := vtClients.GetNext(aNode);
      if aNode <> nil then
      begin
        vtClients.ClearSelection;
        vtClients.Selected[ aNode] := True;
        vtClients.FocusedNode := aNode;
        vtClients.ScrollIntoView(aNode, True);
      end;
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfmeClientLookup.GetFirstSelectedCode: string;
var
  aNode : pVirtualNode;
  NodeData : pTreeData;
  pIDRec : pIntermediateDataRec;
begin
  result := '';
  aNode    := vtClients.GetFirstSelected;
  if Assigned( aNode) then
  begin
    NodeData := vtClients.GetNodeData( aNode);
    if NodeData.tdNodeType = ntClient then
    begin
      pIDRec := GetIntermediateDataFromNode( aNode);
      result := pIDRec.imCode;
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfmeClientLookup.GetFirstSelectedName: string;
var
  aNode : pVirtualNode;
  NodeData : pTreeData;
  pIDRec : pIntermediateDataRec;
begin
  result := '';
  aNode    := vtClients.GetFirstSelected;
  if Assigned( aNode) then
  begin
    NodeData := vtClients.GetNodeData( aNode);
    if NodeData.tdNodeType = ntClient then
    begin
      pIDRec := GetIntermediateDataFromNode( aNode);
      result := pIDRec.imName;
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfmeClientLookup.GetSelectedCodes: string;
//returns a list of codes in a string
//Note: If in multi select mode then the string will be returned with delimiters
//      and quotes for use by TStringList
//      Single select mode will return a string without quotes
var
  Codes : TStringList;
  aNode : pVirtualNode;
  NodeData : pTreeData;
  pIDRec : pIntermediateDataRec;
begin
  result := '';

  if toMultiSelect in vtClients.TreeOptions.SelectionOptions then
  begin
    Codes  := TSTringList.Create;
    try
      //set delimiter
      Codes.Delimiter := ClientCodeDelimiter;
      Codes.StrictDelimiter := true;
      //search through the nodes for the specified code
      aNode := vtClients.GetFirstSelected;
      while Assigned( aNode) do
      begin
        NodeData := vtClients.GetNodeData( aNode);
        if NodeData.tdNodeType = ntClient then
        begin
          pIDRec := GetIntermediateDataFromNode( aNode);
          Codes.Add( pIDRec^.imCode);
        end;
        aNode := vtClients.GetNextSelected( aNode);
      end;

      result := Codes.DelimitedText;
    finally
      Codes.Free;
    end;
  end
  else
  begin
    //tree is in single select mode, so just return first selected
    result := GetFirstSelectedCode;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.SetSelectMode(const Value: TSelectedMode);
begin
  FSelectMode := Value;
  if Value = smSingle then
    vtClients.TreeOptions.SelectionOptions := vtClients.TreeOptions.SelectionOptions - [ toMultiSelect]
  else
    vtClients.TreeOptions.SelectionOptions := vtClients.TreeOptions.SelectionOptions + [ toMultiSelect];
end;

procedure TfmeClientLookup.SetServiceResponse(const Value: TServerResponse);
begin
  FServerResponse := Value;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.SetOnSelectionChanged(
  const Value: TNotifyEvent);
begin
  FOnSelectionChanged := Value;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.vtClientsChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
//called when the selection state of a node changes, if the node is a folder
//then unselect it
var
  NodeData : pTreeData;
begin
  //check to see if node is a folder
  NodeData := Sender.GetNodeData( Node);
  if Assigned( NodeData) then
  begin
    if ( NodeData.tdNodeType = ntGroup) then
    begin
      if (vtClients.Selected[ Node]) then
        vtClients.Selected[ Node] := false;
    end;
  end;

  //firing the selection changed event causes too long a delay when
  //scrolling up and down the list, ignore until key come us
  if Assigned ( FOnSelectionChanged) and ( not FArrowKeyDown) then
  begin
    FOnSelectionChanged( Self);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfmeClientLookup.GetClientCount: integer;
begin
  result := FClientCodesList.Count;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfmeClientLookup.GetSelectionCount: integer;
var
  aNode    : pVirtualNode;
  NodeData : pTreeData;
  Count    : integer;
begin
  Count := 0;
  //search through the selected nodes
  aNode := vtClients.GetFirstSelected;
  while Assigned( aNode) do
  begin
    NodeData := vtClients.GetNodeData( aNode);
    if NodeData.tdNodeType = ntClient then
      Inc( Count);
    aNode := vtClients.GetNextSelected( aNode);
  end;
  result := Count;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.vtClientsIncrementalSearch(
  Sender: TBaseVirtualTree; Node: PVirtualNode;
  const SearchText: WideString; var Result: Integer);
begin
  //
end;
{
  function Min(const A, B: Integer): Integer;  //save us linking in math.pas
  begin
    if A < B then
      Result := A
    else
      Result := B;
  end;

var
  sCompare1, sCompare2 : String;
  DisplayText : WideString;
  ColToSearch : integer;
  NodeData    : pTreeData;
begin
  //exclude root nodes from search
  NodeData := Sender.GetNodeData( Node);
  if Assigned( NodeData) and ( NodeData.tdNodeType = ntGroup) then
  begin
    result := -1;
    Exit;
  end;
  //search on name if sorted by that column
  if FSelectedColumn = cluName then
    ColToSearch := FColumns.FindColumnIndex( cluName)
  else
    ColToSearch := 0;
  //get text for current node
  vtClientsGetText( Sender, Node, ColToSearch, ttNormal, DisplayText );
  sCompare1 := Uppercase(SearchText);
  sCompare2 := DisplayText;

  Result := StrLComp( pchar(sCompare1), pchar(sCompare2), Length(sCompare1));
//  Result := StrLIComp( pchar(sCompare1), pchar(sCompare2), Min(Length(sCompare1), Length(sCompare2)));
end;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.SetFocusToGrid;
begin
  try
    if vtClients.Visible then
      vtClients.SetFocus;
  except
  end;
end;

procedure TfmeClientLookup.SetFrameUseMode(const Value: TFrameUseMode);
begin
  FFrameUseMode := Value;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfmeClientLookup.ChangeBooksPassword: Boolean;
begin
  Result := ChangePasswordFrm.ChangeBankLinkOnlinePassword(FServerResponse, FClientStatusList);
end;

function TfmeClientLookup.CheckBooksLogin: Boolean;
begin
  Result := ChangePasswordFrm.LoginToBankLinkOnline(FServerResponse, FClientStatusList, False, True);
end;

procedure TfmeClientLookup.ClearColumns;
begin
  FColumns.Clear;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.DoStatusProgress(APercentComplete : integer;
                                            AMessage         : string);
begin
  UpdateAppStatus(BANKLINK_ONLINE_NAME, AMessage, APercentComplete);
end;

function TfmeClientLookup.EditBooksBankLinkOnlineLogin: Boolean;
var
  SaveSubdomain, SaveUsername, SavePassword: string;
begin
  SaveSubdomain := Globals.INI_BankLink_Online_SubDomain;
  SaveUsername  := Globals.INI_BankLink_Online_Username;
  SavePassword  := Globals.INI_BankLink_Online_Password;
  if ChangePasswordFrm.LoginToBankLinkOnline(FServerResponse, FClientStatusList, True) then begin
    Result := True;
    Reload;
  end else begin
    Globals.INI_BankLink_Online_SubDomain := SaveSubdomain;
    Globals.INI_BankLink_Online_Username  := SaveUsername;
    Globals.INI_BankLink_Online_Password  := SavePassword;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfmeClientLookup.SetOnGridDblClick(const Value: TNotifyEvent);
begin
  vtClients.OnDblClick := Value;
end;

function TfmeClientLookup.GetOnGridDblClick: TNotifyEvent;
begin
  result := vtClients.OnDblClick;
end;

function TfmeClientLookup.GetProcStatDate: Integer;
begin
   // We can just keep it for some time, so we dont have to calculate for each item in a paint cycle
   if FProcStatDate = 0 then
      FProcStatDate := IncDate (CurrentDate, 0, - ProcStatOffset, 0);

   Result := FProcStatDate;
end;

procedure TfmeClientLookup.SetOnGridColumnMoved(const Value: TVTHeaderDraggedEvent);
begin
  vtClients.OnHeaderDragged := Value;
end;

function TfmeClientLookup.GetOnGridColumnMoved: TVTHeaderDraggedEvent;
begin
  result := vtClients.OnHeaderDragged;
end;

procedure TfmeClientLookup.vtClientsBeforeCellPaint(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; CellRect: TRect);
begin
  if Column >= 0 then

  if Column = vtClients.Header.SortColumn then
  begin
    CellRect.Right := CellRect.Left + vtClients.Header.Columns[ Column].Width;
    TargetCanvas.Brush.Color := $F7F7F7;
    TargetCanvas.FillRect( CellRect);
  end;
end;

procedure TfmeClientLookup.Reload;
begin
  LoadNodes( True);
end;

procedure TfmeClientLookup.SetFilterMode(const Value: TFilterMode);
begin
  FFilterMode := Value;
end;

procedure TfmeClientLookup.SetSubFilter(const Value: UInt64);
begin
  FSubFilter := Value;
end;

procedure TfmeClientLookup.SetUserFilter(const Value: TStringList);
begin
  FUserFilter.Text := Value.Text;
end;

procedure TfmeClientLookup.SetGroupFilter(const Value: TStringList);
begin
  FGroupFilter.Text := Value.Text;
end;

procedure TfmeClientLookup.SetClientTypeFilter(const Value: TStringList);
begin
  FClientTypeFilter.Text := Value.Text;
end;

procedure TfmeClientLookup.SetClientFilter(const Value: Byte);
begin
  FClientFilter := Value;
end;

procedure TfmeClientLookup.SetClientStatusList(const Value: TClientStatusList);
begin
  FClientStatusList := Value;
end;

procedure TfmeClientLookup.SetFilesDirectory(const Value: string);
begin
  FFilesDirectory := AddSlash( Value);
end;

procedure TfmeClientLookup.ClearSelection;
begin
  vtClients.ClearSelection;
end;

procedure TfmeClientLookup.vtClientsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [VK_UP,VK_DOWN] then begin
     // #1678 - switch off the auto centering if using cursor keys
     vtClients.TreeOptions.SelectionOptions := vtClients.TreeOptions.SelectionOptions - [toCenterScrollIntoView];
     FArrowKeyDown := true;
     CurrentSearchKey := '';  //???
     LastSearchTime := 0;
  end else // switch back on for other keys
     vtClients.TreeOptions.SelectionOptions := vtClients.TreeOptions.SelectionOptions + [toCenterScrollIntoView];

  if Key = VK_F5 then begin //Refresh
     Key := 0;
     Reload;
  end;
end;

procedure TfmeClientLookup.vtClientsKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [ 38,40] then
  begin
    FArrowKeyDown := false;

    if Assigned ( FOnSelectionChanged) then
    begin
      FOnSelectionChanged( Self);
    end;
  end;
end;

procedure TfmeClientLookup.vtClientsScroll(Sender: TBaseVirtualTree; DeltaX,
  DeltaY: Integer);
begin
  FLastScrollPosition := DeltaY;
end;

procedure TfmeClientLookup.vtClientsShortenString(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  const S: WideString; TextSpace: Integer; RightToLeft: Boolean;
  var Result: WideString; var Done: Boolean);
var
  NodeData : pTreeData;
begin
  //dont shorten the text for group titles
  NodeData := Sender.GetNodeData( Node);
  if nodeData = nil then
    Exit;

  if NodeData.tdNodeType = ntGroup then
  begin
    Result := S;
    Done := true;
  end;
end;

procedure TfmeClientLookup.vtClientsBeforeItemPaint(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  ItemRect: TRect; var CustomDraw: Boolean);
var
  NodeData : pTreeData;
  S        : string;
  Column   : integer;
  CRect    : TRect;
  LRect    : TRect;
begin
  NodeData := Sender.GetNodeData( Node);

  if NodeData.tdNodeType = ntGroup then
  begin
    CustomDraw := true;

    //paint background
    TargetCanvas.Brush.Color := clWindow;
    TargetCanvas.FillRect( ItemRect);

    //paint sort column shading
    Column := vtClients.Header.SortColumn;
    if ( Column >= 0) and ( Column < vtClients.Header.Columns.Count) then
    begin
      //only paint if in view
      if ( vtClients.Header.Columns[ Column].Left < ItemRect.Right) then
      begin
        CRect.Left := vtClients.Header.Columns[ Column].Left;
        CRect.Top  := ItemRect.Top;
        CRect.Right := CRect.Left + vtClients.Header.Columns[ Column].Width;
        CRect.Bottom := ItemRect.Bottom;
        OffsetRect( CRect, -vtClients.OffsetX, 0);
        TargetCanvas.Brush.Color := $F7F7F7;
        TargetCanvas.FillRect( CRect);
      end;
    end;

    //paint text
    TargetCanvas.Brush.Color := clWindow;
    TargetCanvas.Brush.Style := bsClear;

    TargetCanvas.Font := appimages.Font;
    TargetCanvas.Font.Style := [fsBold];

    S := gidNames[ NodeData.tdFolderID];

    InflateRect( ItemRect, -6, -2 );
    DrawText( TargetCanvas.Handle, PChar( S ), StrLen( PChar( S ) ), ItemRect, DT_LEFT or DT_VCENTER or DT_SINGLELINE);

    //paint line
    LRect.Left     := 6;
    LRect.Top      := ItemRect.Bottom - 5;
    LRect.Bottom   := LRect.Top + 1;
    LRect.Right    := 200;
    RzGrafx.PaintGradient( TargetCanvas, LRect, gdVerticalCenter, clBtnFace, clHighlight);
  end;
end;

procedure TfmeClientLookup.vtClientsCollapsing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var Allowed: Boolean);
begin
  Allowed := false;
end;

procedure TfmeClientLookup.SetOptions(const Value: TLookupOptions);
begin
  FOptions := Value;
end;

procedure TfmeClientLookup.SetProcessStatusUpdateNeeded(const Value: Boolean);
begin
  FProcessStatusUpdateNeeded := Value;
end;

procedure TfmeClientLookup.SetProcStatOffset(const Value: Integer);
var OldValue: Integer;
begin
   OldValue := FProcStatOffset;
   FProcStatOffset := Value;
   // Savety net..
   if FProcStatOffset > MaxProcOffset then
      FProcStatOffset := MaxProcOffset;
   if FProcStatOffset < MinProcOffset then
      FProcStatOffset := MinProcOffset;

   if FProcStatOffset <> OldValue then begin
      FProcStatDate := 0; // Make sure it gets recalculated
      VTClients.Invalidate;
      VTClients.Header.Invalidate(nil);
      if (FSubFilter and cmfDateBits) <> 0 then begin
         LoadNodes(True);
      end;
   end;
end;

function TfmeClientLookup.GetSysClientRec( Sender: TBaseVirtualTree; Node: PVirtualNode) : pClient_File_Rec;
var
  NodeData : pTreeData;
  pIDRec : pIntermediateDataRec;
begin
  result := nil;
  if Assigned( Node) then
  begin
    NodeData := Sender.GetNodeData( Node);
    if NodeData.tdNodeType = ntClient then
    begin
      pIDRec := NodeData.tdData;
      if Assigned( pIDRec) and Assigned( pIDRec^.imData) then
        result := pIDRec^.imData;
    end;
  end;
end;

procedure TfmeClientLookup.vtClientsAfterCellPaint(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; CellRect: TRect);
var
  R: TRect;
  sysClientRec: pClient_File_Rec;
  ColID  : TClientLookupCol;
  Period, FirstOne : Integer;
  LEDColor : TColor;
  Dots: Boolean;
  NodeData : pTreeData;

  procedure DrawCellImgLED( Const Period, LEDColor : Integer; YearStart: Boolean );
  Var
    R : TRect;
    XOffset : Integer;
  Begin
    XOffset := ProcStatBtnW + 11 * ( Period - 1 );
    R := CellRect;
    R.Right := R.Left + ( R.Bottom - R.Top ) ;
    InflateRect( R, -LEDOffset, -LEDSpacing ) ; { Make it Smaller }
    OffsetRect( R, XOffset, 0 ) ; { Move it Right }
    NodeData := vtClients.GetNodedata(vtClients.GetPrevious(Node));
    // The first one after a header seems to think it has less space. weird.
    if Assigned(NodeData) and (NodeData.tdNodeType <> ntClient) then
      FirstOne := 3
    else
      FirstOne := 0;

    if Dots and (R.Right + 3 + TargetCanvas.TextExtent('...').cx - FirstOne > CellRect.Right) then
    begin
      if vsSelected in Node.States then
      begin
        if vtClients.Focused then
        begin
          TargetCanvas.Brush.Color := vtClients.Colors.FocusedSelectionColor;
          TargetCanvas.Font.Color := clWhite;
        end
        else
        begin
          TargetCanvas.Brush.Color := vtClients.Colors.UnFocusedSelectionColor;
          TargetCanvas.Font.Color := clBlack;
        end;
      end
      else
      begin
        TargetCanvas.Brush.Color := clWhite;
        TargetCanvas.Font.Color := clBlack;
      end;
      TargetCanvas.Font.Style := [];
      TargetCanvas.TextOut(R.Left, R.Top, '...');
      Dots := False;
    end
    else if Dots then
    begin
      TargetCanvas.Brush.Color := LEDColor;
      TargetCanvas.Pen.Color := clBtnShadow;
      if YearStart then
        TargetCanvas.Pen.Width := 2
      else
        TargetCanvas.Pen.Width := 1;
      TargetCanvas.RoundRect( R.Left, R.Top, R.Right, R.Bottom, 4, 4 );
    end;
  end;

begin
  if Column >= 0 then
     ColID := FColumns.ColumnDefn_At( Column).FieldID
  else
     Exit;

  if ( ColID = cluCode) and ( loShowNotesImage in FOptions) then
  begin
    sysClientRec := GetSysClientRec( Sender, Node);
    if Assigned( sysClientRec) then
    begin
      if sysClientRec^.cfHas_Client_Notes then
      begin
        R := CellRect;
        R.Left := R.Right - ( R.Bottom - R.Top ); { Square at RH End }
        InflateRect( R, -4, -4 ); { Make it Smaller }
        OffsetRect( R, 2, 0 ); { Move it Right a bit }

        AppImages.ilFileActions_ClientMgr.Draw( TargetCanvas, R.Left, R.Top, 15, dsTransparent, itImage );
      end;
    end;
  end;

  if ColID = cluProcessing then
  begin
      sysClientRec := GetSysClientRec( Sender, Node);
      Dots := true; //??
      with  GetClientStat(sysClientRec,ProcStatDate) do
      For Period := 1 to 12 do Begin

          LEDColor := ColorNoData;
          If (Downloaded[Period] in [rtFully,rtPartially]) then
             LEDColor := ColorDownloaded
          else begin
             If Coded[Period] = rtNone  then
                LEDColor := ColorUncoded;
             If Coded[Period] =  rtPartially  then
                LEDColor := ColorUncoded;
             If Coded[Period] =  rtFully then
                LEDColor := ColorCoded;
             If Finalized[Period] =  rtFully  then
                LEDColor := ColorFinalised;
             If Transferred[Period] =  rtFully  then
                LEDColor := ColorTransferred;
          end;
        DrawCellImgLED( Period, LEDColor, False );
      end;
  end;
end;

procedure TfmeClientLookup.vtClientsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  HitInfo: THitInfo;
  Node: PVirtualNode;
  CellRect: TRect;
  sysClientRec: pClient_File_Rec;
  ColID  : TClientLookupCol;
begin
  if ( Button = mbLeft ) then
  begin
    vtClients.GetHitTestInfoAt( X, Y, True, HitInfo );
    Node := HitInfo.HitNode;
    if not Assigned( Node ) then
      exit;

    ColID := FColumns.GetColumnFieldID( HitInfo.HitColumn);

    if ( ColID = cluCode) and ( loShowNotesImage in FOptions) then
    begin
      sysClientRec := GetSysClientRec( vtClients, Node);
      if Assigned( sysClientRec) then
      begin
        CellRect := vtClients.GetDisplayRect( Node, HitInfo.HitColumn, False );

        if ( ColID = cluCode ) and ( sysClientRec.cfHas_Client_Notes ) and
           ( X >= ( CellRect.Right - AppImages.ilFileActions_ClientMgr.Width - 4 ) )
        then
          if Assigned( FOnNotesClick) then
            FOnNotesClick( Sender);
      end;
    end;
  end;
end;

procedure TfmeClientLookup.SetOnNotesClick(const Value: TNotifyEvent);
begin
  FOnNotesClick := Value;
end;

procedure TfmeClientLookup.SetSearchText(const Value: String);
begin
  if not SameText (FSearchText, Value) then begin
     FSearchText := Value;
     Self.Reload;
  end;
end;

procedure TfmeClientLookup.SetSelectedCodes(const Value: string);
//selects a range of codes
var
  aNode : pVirtualNode;
  pIDRec : pIntermediateDataRec;
  CodesList : TStringList;
  i         : integer;
  aCode     : string;
begin
  ClearSelection;
  if Value <> '' then
  begin
    CodesList := TStringList.Create;
    try
      CodesList.Delimiter := ClientCodeDelimiter;
      CodesList.StrictDelimiter := true;
      CodesList.DelimitedText := Value;

      //search through the nodes for the specified code
      for i := 0 to CodesList.Count - 1 do
      begin
        aCode := CodesList[i];

        aNode := vtClients.GetFirst;
        while Assigned( aNode) do
        begin
          pIDRec := GetIntermediateDataFromNode( aNode);
          if Assigned( pIDRec) and ( pIDRec^.imCode = aCode) then
          begin
            vtClients.Selected[ aNode] := True;
            Break;
          end;
          aNode := vtClients.GetNext( aNode);
        end;
      end;
    finally
      CodesList.Free;
    end;
  end;

  if Assigned ( FOnSelectionChanged) then
  begin
    FOnSelectionChanged( Self);
  end;
end;

function TfmeClientLookup.FindColumnIndex( aFieldID : TClientLookupCol) : integer;
begin
  Result := FColumns.FindColumnIndex( aFieldID);
end;

function TfmeClientLookup.GetColumnPosition(aColIndex: Integer): integer;
begin
  if aColIndex = - 1 then
    Result := -1
  else
    Result := vtClients.Header.Columns[ aColIndex].Position;
end;

function TfmeClientLookup.GetColumnPosition(aFieldID: TClientLookupCol): integer;
var
  ColIndex : integer;
begin
  ColIndex := FColumns.FindColumnIndex( aFieldID);
  Result := GetColumnPosition(ColIndex);
end;

function TfmeClientLookup.GetColumnWidth(aColIndex: Integer): integer;
begin
  if aColIndex = - 1 then
    Result := -1
  else
    Result := vtClients.Header.Columns[ aColIndex].Width;
end;

function TfmeClientLookup.GetColumnWidth(aFieldID: TClientLookupCol): integer;
var
  ColIndex : integer;
begin
  ColIndex := FColumns.FindColumnIndex( aFieldID);
  Result := GetColumnWidth(ColIndex);
end;

function TfmeClientLookup.GetColumnCaption(aColIndex: Integer): string;
begin
  if aColIndex = - 1 then
    Result := ''
  else
    Result := vtClients.Header.Columns[ aColIndex].Text;
end;

function TfmeClientLookup.GetColumnCaption(aFieldID: TClientLookupCol): string;
var
  ColIndex : integer;
begin
  if aFieldID = cluProcessing then
    Result := FormatDateTime('mmm yy', IncMonth(ProcStatDate, -11)) + ' to ' + FormatDateTime('mmm yy', ProcStatDate)
  else
  begin
    ColIndex := FColumns.FindColumnIndex( aFieldID);
    Result := GetColumnCaption(ColIndex);
  end;
end;

function TfmeClientLookup.GetColumnVisibility(aColIndex: Integer): Boolean;
var
  VitTreeCol : TVirtualTreeColumn;
  VitTreeColOpt : TVTColumnOption;
begin
  if aColIndex = - 1 then
    Result := True
  else
  begin
    VitTreeCol := vtClients.Header.Columns[ aColIndex];
    VitTreeColOpt := coVisible;
    result := VitTreeColOpt in VitTreeCol.Options;
  end;
end;

function TfmeClientLookup.GetColumnVisibility(aFieldID: TClientLookupCol): Boolean;
var
  ColIndex : integer;
begin
  ColIndex := FColumns.FindColumnIndex( aFieldID);
  Result := GetColumnVisibility(ColIndex);
end;

function TfmeClientLookup.GetSortedByText: string;
begin
  result := vtClients.Header.Columns[ vtClients.Header.SortColumn].Text;
end;

procedure TfmeClientLookup.SetOnSortChanged(const Value: TNotifyEvent);
begin
  FOnSortChanged := Value;
end;

procedure TfmeClientLookup.SetOnUpdateCount(const Value: TNotifyEvent);
begin
  FOnUpdateCount := Value;
end;

procedure TfmeClientLookup.ResetColumns;
var
  i : integer;
  Col : TCluColumnDefn;
begin
  //reload default values
  for i := 0 to FColumns.Count - 1 do
  begin
    Col := FColumns.ColumnDefn_At(i);
    Col.DisplayWidth := Col.DefaultWidth;
    Col.DisplayPos   := Col.DefaultPos;
    Col.Visible      := True;
  end;

  BuildGrid(FSelectedColumn);
end;

function TfmeClientLookup.GetColumnCount: integer;
begin
  result := FColumns.Count;
end;

function TfmeClientLookup.GetColumnID(ColumnNo: integer): TClientLookupCol;
begin
  result := FColumns.GetColumnFieldID( ColumnNo);
end;

function TfmeClientLookup.GetColumnIDByPosition(ColumnNo: integer): TClientLookupCol;
var
  i, p: Integer;
begin
  result := cluCode;
  for i := 0 to Pred(FColumns.Count) do
  begin
    p := vtClients.Header.Columns[i].Position;
    if p = ColumnNo then
    begin
      result := Fcolumns.GetColumnFieldID(i);
      exit;
    end;
  end;
end;

procedure TfmeClientLookup.SetColumnVisiblity(aFieldID: TClientLookupCol; Status: Boolean);
var
  cIndex: Integer;
begin
  cIndex := FColumns.FindColumnIndex( aFieldID);

  if cIndex <> - 1 then begin
     FColumns.ColumnDefn_At(cIndex).Visible := Status;
     if Status then
       vtClients.Header.Columns[cIndex].Options := vtClients.Header.Columns[cIndex].Options + [coVisible]
     else
       vtClients.Header.Columns[cIndex].Options := vtClients.Header.Columns[cIndex].Options - [coVisible];
  end;
  if aFieldID = cluProcessing then begin
     BtnLeft.Visible := False; // Get turned on and moved on Paint so don't worry
     BtnRight.Visible := False;
     SetHeaderHeight(Status);
  end;

end;

procedure TfmeClientLookup.vtClientsKeyPress(Sender: TObject;
  var Key: Char);
var
  NewSearchKey: ShortString;
  ThisSearcTime: TDateTime;
begin
  ThisSearcTime := Now;
  if (LastSearchTime > 0)
  and ((ThisSearcTime - LastSearchTime) > TypeAheadTimeout) then
     CurrentSearchKey := ''; // Too Old

  NewSearchKey := CurrentSearchKey;
  LastSearchTime := ThisSearcTime;

  
  if (Byte(Key) = VK_BACK)
  and (Length(NewSearchKey) > 0) then begin
     SetLength(NewSearchKey, Pred(Length(NewSearchKey)));
  end else
     if Upcase(key) = NewSearchKey then begin
         DoNewSearch; // Same key.. Just move on..
         Key := #0;
     end else if Key in [' '..'~'] then begin  //???
        if Length( CurrentSearchKey) < 20 then
           NewSearchKey := CurrentSearchKey + UpCase( Key)
     else
        NewSearchKey := UpCase(Key);
  end;

  if CurrentSearchKey <> NewSearchKey then begin
     CurrentSearchKey := NewSearchKey;
     DoNewSearch;
     Key := #0;
  end;

  //now fire key press passed in by owner
  if ( Key <> #0)
  and Assigned(FOnKeyPress) then
     FOnKeyPress(Sender, Key);
end;

procedure TfmeClientLookup.SetOnKeyPress(const Value: TKeyPressEvent);
begin
  FOnKeyPress := Value;
end;

function TfmeClientLookup.HasMatch( SearchList : TStringList; aKey : ShortString) : boolean;
//search thru string list looking for match
var
  i : integer;
begin
  result := false;
  if ( SearchList.Count = 0) or ( aKey = '') then
    Exit;

  //look for matching string
  for i := 0 to SearchList.Count - 1 do
  begin
    if Copy( SearchList[i], 1, Length( aKey)) = aKey then
    begin
      result := true;
      Exit;
    end;
  end;
end;

function TfmeClientLookup.IncludeClientInList(ASendMethod: Byte): Boolean;
begin
  Result := True;
  //The client files only need to be filtered for Books
  if not Assigned(AdminSystem) then begin
    case FFrameUseMode of
      fumGetFile,
      fumSendFile  : Result := (ASendMethod <> ftmOnline);
      fumGetOnline,
      fumSendOnline: Result := (ASendMethod = ftmOnline);
    end;
  end;
end;

procedure TfmeClientLookup.InvalidPasswordDlg(AttemptCount: integer);
const
  THIS_METHOD_NAME = 'InvalidPasswordDlg';
var
  Msg : String;
  PasswordDlg: TBkPasswordDialog;
  PasswordChanged: boolean;
  NewPassword: string;
begin
  if not FUsingAdminSystem then Exit;
  PasswordDlg := TBkPasswordDialog.Create(self);
  try
    PasswordDlg.Caption := 'Log in to ' + BANKLINK_ONLINE_NAME;
    PasswordDlg.DefaultUser := AdminSystem.fdFields.fdBankLink_Code;
    if (AdminSystem.fdFields.fdBankLink_Connect_Password = '') and (AttemptCount = 0) then
      Msg := 'The login password has not been set.  Please enter your password.'
    else
      Msg := 'The password supplied is invalid.  Please enter your password (attempt #%d)';
    PasswordDlg.TextMessage := Format(Msg, [AttemptCount + 1]);
    if PasswordDlg.Execute then begin
      NewPassword := EncryptPassword(PasswordDlg.Password);
      PasswordChanged := (AdminSystem.fdFields.fdBankLink_Connect_Password <> NewPassword);
      if PasswordChanged then begin
        if LoadAdminSystem(True, THIS_METHOD_NAME) then begin
          AdminSystem.fdFields.fdBankLink_Connect_Password := NewPassword;
          SaveAdminSystem;
        end;
      end;
    end else
      raise Exception.Create('User cancelled attempt to enter correct password.');
  finally
    PasswordDlg.Free;
  end;
end;
function TfmeClientLookup.IsUnCoded(SysClientRec: pClient_File_Rec; Ondate: Integer) : boolean;
var i: integer;
begin
  Result := False;

  with GetClientStat(SysClientRec,OnDate) do  for i := 1 to 12 do begin
    if Coded[i] in  [rtNone,rtPartially{,rtNoData}] then begin
       Result := True;
       Break;
    end;
    if Downloaded[i] in  [rtFully, rtPartially] then begin
       Result := True;
       Break;
    end;
 end;
end;

function TfmeClientLookup.ClosestMatch( SearchList : TStringList; aKey : ShortString) : string;

  function GetCodeFromIndex( Index : integer) : string;
  var
    aNode : pVirtualNode;
    pIDRec : pIntermediateDataRec;
  begin
    //each of the string list contains a point to the child node, use this to
    //get the real code
    result := '';
    aNode := Pointer( SearchList.Objects[ Index]);
    if Assigned( aNode) then
    begin
      pIDRec := GetIntermediateDataFromNode( aNode);
      if Assigned( pIDRec) then
        result := pIDRec.imCode;
    end;
  end;

var
  i : integer;
begin
  result := '';

  if ( SearchList.Count = 0) or ( aKey = '') then
    Exit;

  for i := 0 to SearchList.Count - 1 do
  begin
    if Copy( SearchList[i], 1, Length( aKey)) = aKey then
    begin
      result := GetCodeFromIndex(i);
      exit;
    end;

    if SearchList[i] > aKey then
    begin
      if i > 0 then
        result := GetCodeFromIndex(i-1);
      exit;
    end;
  end;
end;

procedure TfmeClientLookup.CMShowingChanged(var M: TMessage);
begin
   inherited;
   TabStop := False;
end;


procedure TfmeClientLookup.DoNewSearch;
var
  Code : string;
  StartNode,
  CurNode: PVirtualNode;
  NodeData: pTreeData;
  pIDRec: pIntermediateDataRec;
  Looped: Boolean;

  function NextNode: Boolean;
  begin
     while assigned(CurNode) do begin
        CurNode := VTClients.GetNext(CurNode);

        if not Assigned(CurNode) then begin
           CurNode := VTClients.GetFirst;
           Looped := True;
        end;

        NodeData := VTClients.GetNodeData(CurNode);

        if NodeData.tdNodeType = ntClient then
            Break;
     end;
     Result :=  CurNode <> StartNode;
  end;

begin
  if CurrentSearchKey = '' then
     exit; // Nothing to look for

  StartNode := VTClients.FocusedNode;
  CurNode := StartNode;
  Looped := False;
  while assigned(CurNode) do begin

        NodeData := VTClients.GetNodeData(CurNode);
        pIDRec := NodeData.tdData;
        case NodeData.tdNodeType of
           ntClient : if assigned(pIDRec) then begin
                         if FSelectedColumn = cluName then
                            Code := uppercase(pIDRec.imName)
                         else
                             Code := uppercase(pIDRec.imCode);
                         if Pos(CurrentSearchKey,Code) = 1 then begin
                            if (CurNode = StartNode)
                            and (Length(CurrentSearchKey) = 1) then begin
                               if Looped then
                                  Break;
                            end else begin
                               vtClients.ClearSelection;
                               vtClients.Selected[CurNode] := true;
                               VTClients.FocusedNode := CurNode;
                               Exit; // Im done...
                            end;
                         end;
           end;
        end;
        if not NextNode then
           Break;
  end;
end;


procedure TfmeClientLookup.FilterBySearchKeys(Value: String);
begin

end;

function TfmeClientLookup.FirstUpload: Boolean;
var
  i, j: integer;
  SelectedCodes: TSTringList;
begin
  Result := True;
  SelectedCodes := TSTringList.Create;
  try
    SelectedCodes.Delimiter := ClientCodeDelimiter;
    SelectedCodes.StrictDelimiter := true;
    SelectedCodes.DelimitedText := GetSelectedCodes;
    for i := 0 to SelectedCodes.Count - 1 do begin
      for j := 0 to FClientStatusList.Count - 1 do begin
        if SelectedCodes[i] = FClientStatusList.Items[j].ClientCode then begin
          if FClientStatusList.Items[j].StatusCode <> cfsNoFile then begin
            Result := False;
            Exit;
          end;
        end;
      end;
    end;
  finally
    SelectedCodes.Free;
  end;
end;

// See what types of clients are selected
procedure TfmeClientLookup.GetSelectionTypes(var Prospect, Active, Unsync: Boolean);
var
  aNode : pVirtualNode;
  NodeData : pTreeData;
  pIDRec : pIntermediateDataRec;
begin
  Prospect := False;
  Active := False;
  Unsync := False;
  //search through the nodes for any prospects, active clients and unsynchronized files
  aNode := vtClients.GetFirstSelected;
  while Assigned( aNode) do
  begin
    NodeData := vtClients.GetNodeData( aNode);
    if NodeData.tdNodeType = ntClient then
    begin
      pIDRec := GetIntermediateDataFromNode( aNode);
      if pIDRec^.imType = ctProspect then
        Prospect := True
      else if pIDRec^.imType = ctActive then
        Active := True;
      if pIDRec^.imGroupID = gidForeignFile then
        Unsync := True;
    end;
    aNode := vtClients.GetNextSelected( aNode);
  end;
end;

procedure TfmeClientLookup.GetArchiveStates(var Unarchived, Archived: Boolean);
var
  SelectedCodes: TStringList;
  CodeIndex: Integer;
  sysClientRec: pClient_File_Rec;
begin
  UnArchived := false;
  Archived := false;
  SelectedCodes := TStringList.Create();
  try
    SelectedCodes.Delimiter := ClientCodeDelimiter;
    SelectedCodes.StrictDelimiter := true;
    SelectedCodes.DelimitedText := GetSelectedCodes;
    for CodeIndex := 0 to SelectedCodes.Count - 1 do
    begin
      sysClientRec := AdminSnapshot.fdSystem_Client_File_List.FindCode(SelectedCodes[CodeIndex]);
      if sysClientRec.cfArchived then
        Archived := true
      else
        Unarchived := true;
    end;
  finally
    SelectedCodes.Free;
  end;
end;

function TfmeClientLookup.GetSortDirection: TSortDirection;
begin
  Result := vtClients.Header.SortDirection;
end;

procedure TfmeClientLookup.mniDeleteClick(Sender: TObject);
var
  pIDRec : pIntermediateDataRec;
begin
  pIDRec := GetIntermediateDataFromNode( vtClients.GetFirstSelected);
  if not Assigned(pIDRec) then exit;
  if AskYesNo('Delete Client File', 'Deleting this read-only client file will remove all ' +
     'transaction information for this client from your system until you next update the file.'#13#13+
     'Do you want to delete ' + pIDRec.imCode + '?', DLG_YES, 0) = DLG_YES then
  begin
    if not DeleteFile(DATADIR + pIDRec.imCode + FILEEXTN) then
      HelpfulErrorMsg('Failed to delete client file ' + pIDRec.imCode + '.', 0);
    Reload;
  end;
end;

procedure TfmeClientLookup.popDeletePopup(Sender: TObject);
var
  pIDRec : pIntermediateDataRec;
begin
  pIDRec := GetIntermediateDataFromNode( vtClients.GetFirstSelected);
  mniDelete.Enabled := Assigned(pIDRec) and (pIDRec.imTag = Tag_ReadOnlyFile);
end;

procedure TfmeClientLookup.SetShowPopMenu(Value: Boolean);
begin
  if (not Assigned(AdminSystem)) and Value then
    PopupMenu := popDelete
  else
    PopupMenu := nil;
end;


initialization
cmfDateBits := cmfsBits[cmfsCoded]  // Bits that require a refresh when the Status date changes
              + cmfsBits[cmfsNotCoded]
              + cmfsBits[cmfsNoData]
              + cmfsBits[cmfsData];
end.

