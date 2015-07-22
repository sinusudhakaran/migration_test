unit clientHomepageItems;

interface

uses //Logutil,
     ActnList,
     BASCalc,
     Menus,
     Classes,
     CodingFrm,
     CodingFormCommands,
     Contnrs,Controls,bkDateUtils,VirtualTrees, graphics,
     Windows,gstUtil32,clObj32, baObj32,
     ClientCodingStatistics,
     RzGroupBar,VirtualTreeHandler,
     ExchangeGainLoss;

type
  TSelectionArray = array [stFirstPeriod..stLastPeriod] of boolean;
  TBoxType = (LeftBox, CenterBox,LeftArrow, RightBox);

  TRangeCount = record
    Range : TDateRange;
    Count : Integer;
  end;

  TCHPBaseList = class (TTreeBaseList)
  protected
    FLEDWidth: Integer;
    FFillDate: Integer;
    FLEDHeight: Integer;
    FClient: TClientObj;
    FPEDates: TMonthEndDates;
    FFirstDrawSel : Integer;
    FLastDrawSel : Integer;

    procedure SetFillDate(const Value: Integer);
    procedure SetLEDHeight(const Value: Integer);
    procedure SetLEDWidth(const Value: Integer);
    procedure SetClient(const Value: TClientObj);
    function GetCodingMonths: TRangeCount;
    function GetGSTMonths: TRangeCount;
    function GetCodingAndGSTMonths: TRangeCount;
    function GetMonths(RetrieveCodingMonths: boolean; RetrieveInvalidGST: boolean): TRangeCount;
    // Had to overload GetTransferMonths, as reads for propertys won't take parameters
    function GetTransferMonths: TRangeCount; overload;
    function GetTransferMonths(CheckValidity: boolean = False): TRangeCount; overload;
    function GetTransferMonthsValidOnly: TRangeCount;
    procedure TreeBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect); override;
    function CheckCodingItem(Item : TTreeBaseItem): Boolean;
    function GetDateRangeStr: string;
  public
     FSelection : TSelectionArray;
     constructor Create (ATree : TVirtualStringTree; AClient: TClientObj);
     procedure OnKeyDown(var Key: Word; Shift: TShiftState); override;
     procedure TreeOnDblClick(Sender: TObject); override;
     procedure CodeRange(Value: TRangeCount);
     property Client: TClientObj read FClient write SetClient;
     property LEDWidth : Integer read FLEDWidth write SetLEDWidth;
     property LEDHeight : Integer read FLEDHeight write SetLEDHeight;
     property FillDate : Integer read FFillDate write SetFillDate;
     property CodingMonths: TRangeCount read getCodingMonths;
     property GSTMonths: TRangeCount read getGSTMonths;
     property CodingAndGSTMonths: TRangeCount read getCodingAndGSTMonths;
     property TransferMonths: TRangeCount read GetTransferMonths;
     property TransferMonthsValidGST: TRangeCount read GetTransferMonthsValidOnly;
     property DateRangeStr: string read GetDateRangeStr;
     // Find..
     function  TestAccount  (Item : TTreeBaseItem; var TestFor): Boolean;
     //function  TestAccounts (Item : TTreeBaseItem; var TestFor): Boolean;
     function  TestYear     (Item : TTreeBaseItem; var TestFor): Boolean;
     function  TestGST      (Item : TTreeBaseItem; var TestFor): Boolean;
     function  TestGroup    (Item : TTreeBaseItem; var TestFor): Boolean;
     function  TestAccountType (Item : TTreeBaseItem; var TestFor): Boolean;
     function  TestBlanks   (Item : TTreeBaseItem; var TestFor): Boolean;
     function  TestForeign  (Item : TTreeBaseItem; var TestFor): Boolean;
  end;



  TCHPBaseItem = class (TTreeBaseItem)
  private
  // Is mainly 'titles' and common bits
  protected
     FClient: TClientObj;
     FMonth, FYear, Fday : Integer;
     FMultiSelect: Boolean;
     procedure SetMultiSelect(const Value: Boolean);
     procedure SetClient(const Value: TClientObj);

     function PEDates : TMonthEndDates;

     function GetPeriod(const Offset : Integer) : Integer;
     function GetMonthText (const Value: Integer):string;

     function GetSelected(Index: Integer): Boolean;
     procedure SetSelected(Index: Integer; const Value: Boolean);
     procedure DrawBox  (FillColor, PenColor : Integer; Canvas: TCanvas; Rect: TRect; Rounded: Boolean = True);
     procedure DrawLeft (FillColor, PenColor : Integer; Canvas: TCanvas; Rect : TRect);
     procedure DrawRight(FillColor, PenColor : Integer; Canvas: TCanvas; Rect : TRect);
     procedure DrawLeftArrow(FillColor, PenColor : Integer; Canvas: TCanvas; Rect : TRect);
     procedure DrawCell (FillColor, PenColor : Integer; Canvas: TCanvas; Rect : TRect;
                         Selected : Boolean; BoxType : tBoxType = CenterBox); overload;

     procedure DrawCell (Period, FillColor, PenColor : Integer; Canvas: TCanvas; Rect : TRect;
                         Selected : Boolean ); overload;
     function SelectPeriod(const Value:Integer; Shift: TShiftstate): Boolean; virtual;
     function HasAction(Period: Integer): Boolean; virtual;
     function GetPeriodPenColor(Period: Integer): Integer;
     //function GetFontColor: Integer;
     // Pickup from Parent
     function FillDate: Integer;
     function LEDWidth: Integer;
     function LEDHeight: integer;
     function FirstSelected: Integer;

     procedure CheckMultiSelect;
     // Common Actions
     //procedure EditGST(Sender: TObject);

     //procedure EditAccounts(Sender: TObject);
     procedure CodeRange (ARange : TDateRange; anAccount : TBank_Account;Options : TCodingOptions);
  public
     constructor Create(AClient: TClientObj; ATitle : string; AGroupID : Integer );
     property MultiSelect: Boolean read FMultiSelect write SetMultiSelect;
     // Tree Actions
     //procedure UpdateDetails(Value : TRZGroup);override;
     procedure DoChange(const value: TVirtualNodeStates); override;
     function GetNodeHeight (const Value : Integer) : Integer; override;
     function GetTagHint(const Tag: Integer; Offset: TPoint) : string; override;
     procedure ClickTag(const Tag: Integer; Offset: TPoint; Button: TMouseButton; Shift:TShiftstate ); override;
     procedure OnKeyDown(var Key: Word; Shift: TShiftState); override;
     procedure OnPaintText(const Tag : integer; Canvas: TCanvas;TextType: TVSTTextType );override;
     function GetTagText(const tag : Integer) : string; override;
     procedure AfterPaintCell(const Tag : integer; Canvas: TCanvas; CellRect: TRect);override;
     property Client : TClientObj read FClient write SetClient;
     property Selected [index: Integer]: Boolean read GetSelected write SetSelected;
  end;


  //  ClientCodingStatistics Items..

  TCHPCodingStatItem = class (TCHPBaseItem)
  protected
     FCodingStats : TClientCodingStatistics;
     FStats : TStatisticsType;
  public
     constructor Create( AClient: TClientObj; Stats : TStatisticsType);
     destructor Destroy; override;
     function GetTagHint(const Tag: Integer; Offset: TPoint) : string; override;
     property CodingStats : TClientCodingStatistics read FCodingStats;
     function GetSelectDateRange : TDateRange;
     procedure OpeningBalances(Sender: TObject);
  end;

  TCHAccountItem = class (TCHPCodingStatItem)
  protected
     FAccount : TBank_Account;
     function GetBankAccount: TBank_Account;
     procedure EditAccount (Sender : TObject);
     procedure ContextCode (Sender : TObject); virtual;
     procedure SetBankAccount(const Value: TBank_Account);
     function HasAction(Period: Integer): Boolean; override;
  public
     FBankCode : Shortstring;
     constructor Create(AClient: TClientObj; ABankAccount: TBank_Account; ATitle: string; AGroupID: Integer );
     function Refresh: Boolean; override;
     function AccountType : Byte; virtual;

     property BankAccount : TBank_Account read GetBankAccount write SetBankAccount;
     procedure AfterPaintCell(const Tag : integer; Canvas: TCanvas; CellRect: TRect);override;
     function GetTagText(const tag : Integer) : string; override;
     function CompareTagText(const Tag: integer; WithItem: TTreeBaseItem; SortDirection: TSortDirection): Integer; override;
     function GetTagHint(const Tag: Integer; Offset: TPoint) : string; override;
     procedure DoubleClickTag(const Tag: Integer; Offset: TPoint); override;
     //procedure UpdateDetails(Value : TRZGroup);override;
     procedure DoChange(const value: TVirtualNodeStates); override;
     procedure UpdateMenu(const Tag: Integer; Offset: TPoint; Value: TpopupMenu); override;
     procedure OnPaintText(const Tag: Integer; Canvas: TCanvas; TextType: TVSTTextType );override;
  end;

  TCHJournalItem = class (TCHAccountItem)
  // Journal Account Item;
  protected
     //procedure EditTransaction (Sender :TObject);
     procedure AddTransaction (Sender : TObject);
     procedure ContextCode (Sender : TObject); override;
     procedure DoCoding;
  public
     //function Refresh: Boolean; override;
     function GetTagText(const Tag: Integer) : string; override;
     //function SelectPeriod(const Value:Integer; Shift: TShiftstate):Boolean; override;
     procedure DoubleClickTag(const Tag: Integer; Offset : TPoint); override;
     //procedure UpdateDetails(Value: TRZGroup);override;
     procedure UpdateMenu(const Tag: Integer; Offset: TPoint; Value: TpopupMenu); override;
     //procedure DoChange(const value: TVirtualNodeStates); override;
     function CompareTagText(const Tag : integer; WithItem : TTreeBaseItem; SortDirection : TSortDirection) : Integer; override;
  end;

  TCHEmptyJournal = class (TCHJournalItem)
  // Operate as journal, without actualy having an account
  protected
     fAccountType : Byte;
  public
     function AccountType : Byte; override;
     function Refresh: Boolean; override;
     constructor Create( AClient: TClientObj; aAccountType : byte; ATitle : string; AGroupID : Integer );
  end;

  // Period Items...
  TCHPeriodBaseItem = class (TCHPBaseItem)
  protected
  public
     function GetTagText(const Tag : Integer) : string; override;
     procedure OnPaintText(const Tag : integer; Canvas: TCanvas;TextType: TVSTTextType );override;
  end;

  TPeriodInfo = class(TObject)
  private
    Info  : TGSTInfo;
  public
    DateRange : TdateRange;
    function GetText: string; virtual;
    function GetFillColor: Integer; virtual;
    function HasAction: Boolean; virtual;
  end;

  TCHGSTPeriodItem = class (TCHPeriodBaseItem)
  protected
     FInfoList: TObjectlist;
     function GetGSTPeriod(AnyDate,StartMonth,PeriodType : Integer): TDateRange;
     function GetInfo (const Index: Integer): TPeriodInfo;
     function DateInfo(const EndDate: Integer): TPeriodInfo;
     function PeriodInfo (Period: Integer): TPeriodInfo;
     procedure RunReturn(Sender: TObject);virtual;
     procedure RunAuditTrail(Sender: TObject);
     procedure RunSummary(Sender: TObject);
     procedure RunAllocationSummary(Sender: TObject);
     //procedure RunReconcile(Sender: TObject); not that apropriate from here...
     procedure RunOverides(Sender: TObject);

     function DueText (Value: Integer) : string;
     function HasAction(Period: Integer): Boolean; override;
     function GetPeriodText (Value : TPeriodInfo): string;
  public
     constructor Create( AClient: TClientObj );
     destructor Destroy; override;
     function Refresh: Boolean; override;
     function SelectPeriod(const Value:Integer; Shift: TShiftstate): Boolean; override;
     procedure DoubleClickTag(const Tag: Integer; Offset: TPoint ); override;
     //procedure UpdateDetails(Value: TRZGroup);override;
     procedure UpdateMenu(const Tag: Integer; Offset: TPoint; Value: TpopupMenu); override;
     function GetTagHint(const Tag : Integer; Offset : TPoint) : string; override;
     procedure AfterPaintCell(const Tag: integer; Canvas: TCanvas; CellRect: TRect);override;
     procedure DoChange(const value: TVirtualNodeStates); override;
     function GetTagText(const Tag: Integer): string; override;
  end;

  TCHBASPeriodItem = class (TCHGSTPeriodItem)
  protected
     FMonthly : Boolean;
     procedure RunReturn (Sender : TObject);override;
  public
     constructor Create( AClient: TClientObj; IsMonthly : Boolean );
     function Refresh: Boolean; override;
     function CompareTagText(const Tag : integer; WithItem : TTreeBaseItem; SortDirection : TSortDirection) : Integer; override;
  end;

  TCHVATPeriodItem = class(TCHGSTPeriodItem )
  protected
    procedure RunReturn (Sender : TObject);override;
  end;

  TCHYearItem = class (TCHPeriodBaseItem)
  protected
     FMonthLeft,FMonthRight,
     FYearLeft,FYearRight :TControl;
  public
     constructor Create(AClient: TClientObj; ML,MR,YL,YR: TControl );
     function GetNodeHeight(const Value: Integer): Integer; override;
     procedure AfterPaintCell(const Tag: integer; Canvas: TCanvas; CellRect: TRect);override;
  end;

  TCHForeignItem = class (TCHPBaseItem)
  private
    FMonthEndings: TMonthEndings;
    function GetSelectedPeriod: integer;
    procedure OpenGainLossFromPeriod(Period: integer);
    function GetMonthEnding(P: integer): integer;
    function GetPeriodFillColor(MonthEnding: TMonthEnding): integer;
    function GetCellPosition(Period: integer): integer;
  protected
    FCodingStats : TClientCodingStatistics;
    procedure ContextCode (Sender : TObject); virtual;
    function HasAction(Period: Integer): Boolean; override;
    procedure OpenGainLossFromOffset(OffsetX: integer);
    procedure OpenGainLoss(Period: integer; DT: TDateTime);
    procedure YMDFromPeriod(P: integer; var PeriodY, PeriodM, PeriodD: Word);
    function DateTimeFromPeriod(P: integer): TDateTime;
  public
    constructor Create(AClient: TClientObj; ATitle: string; AGroupID: Integer; MonthEndingsClass: TMonthEndingsClass); reintroduce; virtual;
    property MultiSelect: Boolean read FMultiSelect;
    procedure AfterPaintCell(const Tag: integer; Canvas: TCanvas; CellRect: TRect); override;
    procedure OnPaintText(const Tag: Integer; Canvas: TCanvas; TextType: TVSTTextType );override;
    function GetTagHint(const Tag: Integer; Offset: TPoint) : string; override;
    function GetTagText(const tag : Integer) : string; override;
    function SelectPeriod(const Value:Integer; Shift: TShiftstate): Boolean; override;
    procedure DoChange(const value: TVirtualNodeStates); override;
    procedure UpdateMenu(const Tag: Integer; Offset: TPoint; Value: TpopupMenu); override;
    function GetSelectDateRange : TDateRange;
    procedure DoubleClickTag(const Tag: Integer; Offset: TPoint ); override;
    procedure OnKeyDown(var Key: Word; Shift: TShiftState); override;
    destructor Destroy; override;
  end;

const
   CHPT_Code = 1;
   CHPT_Name = 2;
   CHPT_Text = 3;
   CHPT_Processing = 4;
   CHPT_Period  = 5;
   CHPT_Balance = 6;
   CHPT_Report_Processing = 7;
   CHPT_Currency = 8;

   grp_Year     = 0;
   grp_Banks    = 1;
   grp_Bank     = 2;
   grp_Journals = 3;
   grp_Journal  = 4;

   grp_Taxes    = 5;
   grp_Tax      = 6;

   grp_Financials  = 7;
   grp_Financial = 8;

   grp_Foreigns = 9;
   grp_Foreign = 10;

   grpTitles = [grp_Banks, grp_Journals, grp_Taxes, grp_Financials, grp_Foreigns];


const

   {}
   lLEDWidth  = 28;
   lLEDHeight = 25;
   HLEDGap = 8;
   VLEDgap = 2;
   MonthHeight = 24;
   BtnWidth = 28;
   {}
   {
   lLEDWidth  = 22;
   lLEDHeight = 22;
   HLEDGap = 5;
   VLEDgap = 2;
   MonthHeight = 28;
   BtnWidth = 35;
   {}

implementation

uses
//   LogUtil,
   ImagesFrm,
   Merge32,
   Progress,
   OpeningBalancesDlg,
   ModalProcessorDlg,
   ReportDefs,
   ExtCtrls,
   rzCommon,
   RzGrafx,
   MainFrm,
   PDDATES32,
   StDateSt,
   math,
   bkBranding,
   Forms,
   Themes,
   UpdateMF,
   RptGst,
   Gst101Frm,
   VATReturn,
   InfoMoreFrm,
   BASfrm,
   bkConst,
   Journals,
   EditbankDlg,
   MoneyDef,
   Globals,
   ApplicationUtils,
   UsageUtils,
   AutoSaveUtils,
   ClientHomePagefrm,
   JnlUtils32,
   JournalDlg,
   sysutils,
   stdate,
   BKDEFS,
   //SelectJournalDlg,
   ReportImages,
   AuditMgr,
   BankLinkOnlineServices,
   GainLossfrm,
   Dialogs,
   LogUtil,
   DateUtils,
   ForexHelpers;
const

  ActionBorderColor   = clLtGray;
  BlankBorderColor    = clLtGray;
  SelectedBorderColor = clWhite;

  { TCHPBaseItem }

constructor TCHPBaseItem.Create(AClient: TClientObj; ATitle : string; AGroupID : Integer );
begin
   inherited Create(ATitle,AGroupId);
   MultiSelect := True;
   Client := AClient;
end;

procedure TCHPBaseItem.AfterPaintCell(const Tag: integer; Canvas: TCanvas;
  CellRect: TRect);
var LRect : TRect;
    TextColorBackup : Integer;
    BackColorBackup : Integer;
begin
  case Tag of
    CHPT_Text : if GroupID in grpTitles then begin
          LRect.Left := CellRect.Left + 6;
          LRect.Top  := CellRect.Bottom - 4;
          LRect.Bottom   := LRect.Top + 1 ;
          LRect.Right    := 200;
          RzGrafx.PaintGradient( Canvas, LRect, gdVerticalCenter, clBtnFace, clHighlight);
       end;
    CHPT_Processing : begin
          if not assigned(ParentList) then Exit;
          if not assigned(Node) then Exit;
          if not ParentList.Tree.Focused then Exit;

          if ParentList.Tree.FocusedNode <> Node then exit;
          //LRect := CellRect;
          //InflateRect(LRect,-3,-3);
          //Windows.DrawFocusRect(Canvas.Handle,CelLRect);


          TextColorBackup := GetTextColor(Canvas.Handle);
          SetTextColor(Canvas.Handle, $FFFFFF);
          BackColorBackup := GetBkColor(Canvas.Handle);
          SetBkColor(Canvas.Handle, 0);

          Windows.DrawFocusRect(Canvas.Handle, CellRect);

          SetTextColor(Canvas.Handle, TextColorBackup);
          SetBkColor(Canvas.Handle, BackColorBackup);

       end;
  end;
end;

procedure TCHPBaseItem.CheckMultiSelect;
var Wassel : boolean;
begin
   if not (Multiselect =  (toMultiselect in ParentList.Tree.TreeOptions.SelectionOptions)) then begin
      Wassel := ParentList.Tree.Selected [Node];
      if Multiselect then
         ParentList.Tree.TreeOptions.SelectionOptions :=
           ParentList.Tree.TreeOptions.SelectionOptions + [toMultiselect]
      else
          ParentList.Tree.TreeOptions.SelectionOptions :=
           ParentList.Tree.TreeOptions.SelectionOptions - [toMultiselect];

      ParentList.Tree.Selected [Node] := Wassel;
   end;
end;

procedure TCHPBaseItem.ClickTag(const Tag: Integer; Offset: TPoint; Button: TMouseButton; Shift:TShiftstate );
var P : Integer;
begin
   CheckMultiSelect;
   case Tag of
      CHPT_Processing : begin
         P := GetPeriod(Offset.X);
         if ((button = mbRight)
             and (Selected [p] )
             and NodeSelected)
         or (ssCtrl in Shift )
         then
            // Don't change the selection
         else begin
            SelectPeriod(P,Shift);
         end;
      end;
      else SelectPeriod(-1,Shift);
   end;
end;

procedure TCHPBaseItem.CodeRange(ARange: TDateRange; anAccount: TBank_Account; Options : TCodingOptions);
begin
   if not assigned(anAccount) then
      Exit;
   if ARange.ToDate <= ARange.FromDate then
      Exit;

   ApplicationUtils.DisableMainForm;
   try
      CodeTheseEntries(ARange.Fromdate, ARange.ToDate ,anAccount, Options, False);
      Client.clFields.clPeriod_Start_Date := ARange.FromDate;
      Client.clFields.clPeriod_End_Date := ARange.ToDate;
   finally
      ApplicationUtils.EnableMainForm;
      ApplicationUtils.MakeMainFormForeground;
   end;
end;


procedure TCHPBaseItem.DoChange(const value: TVirtualNodeStates);
begin
  CheckMultiSelect;
  inherited;
end;

procedure TCHPBaseItem.DrawBox(FillColor, PenColor: Integer; Canvas: TCanvas;
  Rect: TRect; Rounded: Boolean = True);
begin
   Canvas.Pen.Color := PenColor;
   Canvas.Brush.Color := FillColor;
   if Rounded then
      Canvas.RoundRect(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom, ProcessCornerRadius,ProcessCornerRadius)
   else
      Canvas.Rectangle(Rect);
end;

procedure TCHPBaseItem.DrawCell(FillColor, PenColor: Integer; Canvas: TCanvas;
  Rect: TRect; Selected: Boolean; BoxType: tBoxType);
begin
  if Selected then  // Fill the Whole box...
     DrawBox(bkBranding.SelectionColor, bkBranding.SelectionColor, Canvas, Rect, False);

  InflateRect(Rect,-HLEDGap,- VLEDGap); // Apply margins
  case BoxType of
    LeftBox   : DrawLeft  (FillColor, PenColor, Canvas, Rect);
    CenterBox : DrawBox   (FillColor, PenColor, Canvas, Rect);
    RightBox  : DrawRight (FillColor, PenColor, Canvas, Rect);
    LeftArrow : DrawLeftArrow (FillColor, PenColor, Canvas, Rect);
  end;
end;


procedure TCHPBaseItem.DrawCell(Period, FillColor, PenColor: Integer;
  Canvas: TCanvas; Rect: TRect; Selected: Boolean);
begin
   // Recalc the Rect based on the period..
   Rect.Right := Rect.Left + LEDWidth;
   OffsetRect(Rect,LEDWidth * Period + (BtnWidth -LEDWidth) ,0);

   case period of  // Set the BoxType
   0  : DrawCell(FillColor,Pencolor,Canvas,Rect,Selected and self.Selected[Period],LeftBox);
   13 : DrawCell(FillColor,Pencolor,Canvas,Rect,Selected and self.Selected[Period],RightBox);
   else DrawCell(FillColor,Pencolor,Canvas,Rect,Selected and self.Selected[Period]);
   end;
end;


procedure TCHPBaseItem.DrawLeft(FillColor, PenColor: Integer; Canvas: TCanvas;
  Rect: TRect);
var H,B : Integer;
begin
   Dec(Rect.Right); //canvas Rectangle  misses these
   Dec(Rect.Bottom);
   H := (Rect.Top + Rect.Bottom) div 2;
   B := Min (Rect.Right ,Rect.Left + 4 );
   Canvas.Pen.color := PenColor;
   Canvas.Brush.Color := FillColor;
   Canvas.MoveTo(Rect.Left,  H);
   Canvas.LineTo(B,          Rect.Top );
   Canvas.LineTo(Rect.Right, Rect.Top );
   Canvas.LineTo(Rect.Right, Rect.Bottom );
   Canvas.LineTo(B ,         Rect.Bottom );
   Canvas.LineTo(Rect.Left,  H );
   Canvas.FloodFill(Rect.Right - 4, h, PenColor, fsBorder);
end;

procedure TCHPBaseItem.DrawLeftArrow(FillColor, PenColor: Integer;
  Canvas: TCanvas; Rect: TRect);
var H,B : Integer;
begin
   Dec(Rect.Right); //canvas Rectangle  misses these
   Dec(Rect.Bottom);
   H := (Rect.Top + Rect.Bottom) div 2;
   B := (Rect.Bottom - Rect.Top) div 2;
   Canvas.Pen.color := PenColor;
   Canvas.Brush.Color := FillColor;
   Canvas.MoveTo(Rect.Left - B,        H);
   Canvas.LineTo(Rect.Left,    Rect.Top );
   Canvas.LineTo(Rect.Right,       Rect.Top );
   Canvas.LineTo(Rect.Right - B,   H );
   Canvas.LineTo(Rect.Right,       Rect.Bottom );
   Canvas.LineTo(Rect.Left,    Rect.Bottom );
   Canvas.LineTo(Rect.Left - B,        H );
   Canvas.FloodFill(Rect.Left + 4, h, PenColor, fsBorder);
end;

procedure TCHPBaseItem.DrawRight(FillColor, PenColor: Integer; Canvas: TCanvas;
  Rect: TRect);
var H,B : Integer;
begin
   Dec(Rect.Right); //canvas Rectangle  misses these
   Dec(Rect.Bottom);
   H := (Rect.Top + Rect.Bottom) div 2;
   B := Max (Rect.Left, Rect.Right - 4);
   Canvas.Pen.color := PenColor;
   Canvas.Brush.Color := FillColor;
   Canvas.MoveTo(Rect.Left,  Rect.Top);
   Canvas.LineTo(B,          Rect.Top);
   Canvas.LineTo(Rect.Right, H);
   Canvas.LineTo(B,          Rect.Bottom);
   Canvas.LineTo(Rect.Left,  Rect.Bottom);
   Canvas.LineTo(Rect.Left,  Rect.Top);
   Canvas.FloodFill(Rect.Left + 4, h, PenColor, fsBorder);
end;

function TCHPBaseItem.FillDate: Integer;
begin
   if Assigned(ParentList) then
      Result := TCHPBaseList(ParentList).FillDate
   else
      Result := CurrentDate;
end;

(*
function TCHPBaseItem.GetFontColor : Integer;
begin
   Result := clWindowText;
end;
*)

function TCHPBaseItem.GetMonthText(const Value: Integer): string;
begin
   StDateToDMY(value , FDay, FMonth, FYear );
   Result := ShortMonthNames[FMonth];
end;

function TCHPBaseItem.GetNodeHeight(const Value: Integer): Integer;
begin
   if GroupId in grpTitles then
      Result := max(Value,LEDHeight * 3 div 2 )
   else
      Result := max(Value,LEDHeight);
end;

function TCHPBaseItem.GetPeriod(const Offset: Integer): Integer;
begin
   if offset > btnWidth  then begin
      Result := ((Offset - BtnWidth + LEDWidth {- HLEDGap}) Div LEDWidth);
      if Result > 13 then
         Result := 13; // Last bit looks/is wider.. Also what else is it going to be
   end else
      Result := 0
end;

function TCHPBaseItem.GetPeriodPenColor(Period: Integer): Integer;
begin
   if HasAction(Period) then
      Result := ActionBorderColor
   else
      Result := BlankBorderColor;
end;

function TCHPBaseItem.GetSelected(Index: Integer): Boolean;
begin
   Result := false;
   if not (index in  [stFirstPeriod..stLastPeriod]) then
      Exit;
   if not Assigned(ParentList) then
      Exit;
   Result := TCHPBaseList(ParentList).FSelection[Index];
end;

function TCHPBaseItem.GetTagHint(const Tag: Integer; Offset: TPoint): string;
begin
  result := Title;
end;


function TCHPBaseItem.GetTagText(const tag: Integer): string;
begin
  case Tag of
     CHPT_Name,
     CHPT_Code,
     CHPT_Text : Result := Title;
     CHPT_Processing : Result := ' '; //so we get a font...
     else  Result := '';
   end;
end;

function TCHPBaseItem.HasAction(Period: Integer): Boolean;
begin
   Result := False;
end;

function TCHPBaseItem.LEDHeight: integer;
begin
   if Assigned(ParentList) then
      Result := TCHPBaseList(ParentList).LEDHeight
   else
      Result := lLEDHeight;
end;

function TCHPBaseItem.LEDWidth: Integer;
begin
   if Assigned(ParentList) then
      Result := TCHPBaseList(ParentList).LEDWidth
   else
      Result := lLEDWidth;
end;



procedure TCHPBaseItem.OnKeyDown(var Key: Word; Shift: TShiftState);

    procedure TabNext;
    begin
       Key := VK_Down;
       if Assigned (Node) then
          if not Assigned(ParentList.Tree.GetNext(Node)) then
            Key := VK_Home;

    end;

    procedure TabBack;
    begin
       Key := VK_Up;
       if Assigned (Node) then
          if not Assigned(ParentList.Tree.GetNext(Node)) then
            Key := VK_End;
    end;

    procedure SelectNext(Shift: TShiftState);
    var I : Integer;
    begin
       for I := pred(stLastPeriod) downto stFirstPeriod do
          if Selected[i] then begin
             if SelectPeriod(Succ(I), Shift) then
                 Key := 0;
                   Break;
             end;
          if Key = VK_Tab then begin
             for i := stFirstPeriod to stLastPeriod do
                Selected[i] := (i = 1 {stFirstPeriod});

             TabNext;
          end;
    end;

    procedure SelectBack(Shift: TShiftState);
    var I : Integer;
    begin
        for I := Succ(stFirstPeriod) to  stLastPeriod do
          if Selected[i] then begin
             if SelectPeriod(Pred(I), Shift) then
                Key := 0;
             Break;
          end;
        if Key = VK_Tab then begin
             for i := stFirstPeriod to stLastPeriod do
                Selected[i] := (i = 12);

             TabBack;
          end;
    end;

begin
   case key of
    VK_Tab : if GroupID in grpTitles then begin
                if ssShift in Shift then TabBack
                else TabNext;
             end else begin
                if ssShift in Shift then selectBack (Shift - [ssShift])
                else selectNext(Shift);
             end;

    VK_RIGHT : if GroupID in grpTitles then TabNext
               else SelectNext(Shift);

    VK_Left : if GroupID in grpTitles then TabBack
              else SelectBack(Shift);

    VK_Return : DoubleClickTag(CHPT_Processing,Point(0,0));

   end;
end;

procedure TCHPBaseItem.OnPaintText(const Tag: integer; Canvas: TCanvas;
  TextType: TVSTTextType);
begin
   Canvas.Font := appimages.Font;
   Canvas.Font.Style := [fsBold];
   //Canvas.Font.Color := GetFontColor;
end;

procedure TCHPCodingStatItem.OpeningBalances(Sender: TObject);
begin
   //frmMain.DoMainFormCommand(mf_mcOpeningBalances);

   ClientHomePage.Lock;
   frmMain.Enabled := False;
   with TdlgModalProcessor.Create(nil)do
   try
      Show;
      EditOpeningBalances(MyClient, SHOW_BAL,GetSelectDateRange.FromDate) ;
   finally
      Free;
      frmMain.Enabled := True;
      ClientHomePage.Unlock;
   end;
   frmMain.ActiveFormChange(self);

end;

function TCHPBaseItem.PEDates: TMonthEndDates;

begin
   if assigned(ParentList) then
      Result := TCHPBaseList(ParentList).FPEDates
   else
      Result := GetMonthEndDates(Filldate);
end;

function TCHPBaseItem.FirstSelected: Integer;
var I : Integer;
begin
   Result := -1;
   for I := stFirstPeriod to stLastPeriod do
      if Selected[I] then begin
         Result := I;
         Exit;
      end;
end;

function TCHPBaseItem.SelectPeriod(const Value: Integer; Shift:TShiftstate): Boolean;
var  F, L, I  : Integer;
begin
   if (Value < stFirstPeriod)
   or (Value > stLastPeriod) then begin
      for i := stFirstPeriod to stLastPeriod do
         Selected[i] := False;
      Result := false;
   end else if ssShift in Shift then begin
       F := 0;
       L := 0;
       for i := stFirstPeriod to stLastPeriod do // Get the current range...
          if Selected[i] then begin
             if F = 0 then F := I;
             L := I;
          end;
       if Value > L then
          for I := Succ(L) to Value  do Selected[i] := True
       else
          for I := Value to Pred(F)  do Selected[i] := True;
      Result := Value in [ (stFirstPeriod + 1) .. (stLastPeriod -1)];
      //Result := true;
   end else begin

       for i := stFirstPeriod to stLastPeriod do
         Selected[i] := (i = Value);
       Result := Value in [ (stFirstPeriod + 1) .. (stLastPeriod -1)];
       //result := true;
   end;
   ParentList.Tree.InvalidateColumn(1);

end;

procedure TCHPBaseItem.SetClient(const Value: TClientObj);
begin
  FClient := Value;
end;


procedure TCHPBaseItem.SetMultiSelect(const Value: Boolean);
begin
  FMultiSelect := Value;
end;

procedure TCHPBaseItem.SetSelected(Index: Integer; const Value: Boolean);
begin
   if not (index in  [stFirstPeriod..stLastPeriod]) then
      Exit;
   if not Assigned(ParentList) then
      Exit;
   TCHPBaseList(ParentList).FSelection[Index] := Value;
end;

(*
procedure TCHPBaseItem.UpdateDetails(Value: TRZGroup);
begin
  Value.Caption := Title;
  // Could make base types..
  case GroupId of
  grp_Banks    : begin
        AddDetail('Maintain Accounts ',value,EditAccounts);
     end;
  grp_Journals : begin
        AddDetail('Maintain Accounts ',value,EditAccounts);
     end;

  grp_Taxes : AddDetail('GST Settings',Value,EditGST);

  grp_Financials  : begin
        AddDetail('Maintain Accounts ',value,EditAccounts);
        if Client.clFields.clFinancial_Year_Starts <> 0 then
           AddDetail('Opening Balance ' +
            StDateToDateString( 'dd nnn yyyy', Client.clFields.clFinancial_Year_Starts, true) ,Value, OpeningBalances);
     end;
  end;
end;
*)


{ TCHAccountItem }

constructor TCHAccountItem.Create( AClient: TClientObj;
                                   ABankAccount : TBank_Account;
                                   ATitle : string; AGroupID : Integer);
begin
  inherited Create(AClient,stBlank);
  MultiSelect := AGroupID in [grp_Bank];
  Title := ATitle;
  GroupID :=  AGroupID;
  BankAccount := aBankAccount; // May override the title...
end;


procedure TCHAccountItem.DoChange(const value: TVirtualNodeStates);
begin
   if vsSelected in Value then
      CheckMultiSelect;
      {
      if not (toMultiselect in ParentList.Tree.TreeOptions.SelectionOptions)  then begin
        ParentList.Tree.TreeOptions.SelectionOptions :=
          ParentList.Tree.TreeOptions.SelectionOptions + [toMultiselect];
        ParentList.Tree.Selected [Node] := True;
      end;
      }
end;

procedure TCHAccountItem.DoubleClickTag(const Tag: Integer; Offset: TPoint);
var Retrieved: Boolean;

    procedure RetrieveRange;
    var
      P : Integer;
    begin
      if (not Assigned(AdminSystem)) then
        Exit;

      if Client.clFields.clMagic_Number <> AdminSystem.fdFields.fdMagic_Number then
        Exit;  //Case #9341

      for P := stFirstPeriod to stLastPeriod do
      begin
        if Selected[P] and (FCodingStats.NoOfDownloadedEntries(P)> 0) then
        begin
          MergeNewDataYN(Client, False, False, False, True, True);

          RefreshHomepage ([HPR_ExchangeGainLoss_NewData]);

          Retrieved := True;
          // One is enough.
          Exit;
        end;
      end;
    end;

    function FailRange : Boolean;
      var P : Integer;
      begin
         Result := False;
         // Note: don't use stFirstPeriod or stLastPeriod here
         for P := 1 to 12 do
           if Selected[P]
           and (FCodingStats.NoOfEntries(P)> 0) then
             Exit;
         // Still here.. Nothing found
         Result := True;
      end;
begin
   case tag of
   CHPT_Processing  : begin
        Retrieved := false;
        try
           RetrieveRange;
           if FailRange then
              exit;

           incUsage('Do Coding(Homepage)');

           Coderange(GetSelectDateRange,BankAccount,[]);
        finally
           if Retrieved then
             RefreshHomepage([HPR_Files, HPR_Coding]);
        end;

     end;
   end; //Case

end;

procedure TCHAccountItem.EditAccount(Sender: TObject);
var
  B: TBank_Account;
  DummyAccVendor : TAccountVendors;
begin
   GetBankaccount;
   if Assigned(FAccount) then
   begin
     B := FAccount;
     if B.IsManual then // a/c number may of changed (for manual accounts) - need to re-insert in the correct position
       FClient.clBank_Account_List.Delete(B);
     EditBankAccount(FAccount, DummyAccVendor, '', False);
     if B.IsManual then
       FClient.clBank_Account_List.Insert(B);

     //Flag Audit
     FClient.FClientAuditMgr.FlagAudit(arClientBankAccounts);
   end;
end;

procedure TCHAccountItem.AfterPaintCell(const Tag: integer; Canvas: TCanvas;
  CellRect: TRect);
var
  Period: Integer;
  PeriodPenColor : integer;
begin
  if (tag = CHPT_Processing) and assigned(FCodingStats) then
  begin
    for Period := 1 to 12 do
    begin
      if (FCodingStats.GetPeriodFillColor(Period) = bkBranding.ColorNoData) then
        PeriodPenColor := GetPeriodPenColor(Period)
      else
        PeriodPenColor := FCodingStats.GetPeriodFillColor(Period);

      DrawCell(Period,
               FCodingStats.GetPeriodFillColor(Period),
               PeriodPenColor,
               Canvas,
               CellRect,NodeSelected)
    end;
  end;

  inherited;
end;

procedure TCHAccountItem.ContextCode(Sender: TObject);
var DR : TDateRange;
    I : Integer;
    NoData,
    Retrieved : Boolean;

   procedure CheckItem(Item: TTreeBaseItem);

      function FailRange : Boolean;
      var P : Integer;
      begin with TCHAccountItem(Item) do begin
         Result := False;
         for P := stFirstPeriod to stLastPeriod do
           if Selected[P]
           and (FCodingStats.NoOfEntries(P)> 0) then
             Exit;
         // Still here.. Nothing found
         Result := True;
      end;end;

   begin
      if not Item.NodeSelected then
         Exit;
      if not (Item is TCHAccountItem) then
         Exit;
      with TCHAccountItem(Item) do begin
         if (GetBankAccount = nil) then
            Exit;
         if FailRange then
            Exit;
         CodeRange(DR,FAccount,[]);// View Or Code...
         NoData := False;
      end;
   end;

   procedure RetrieveRange;
      var P : Integer;
      begin
         for P := stFirstPeriod to stLastPeriod do
           if Selected[P]
           and (FCodingStats.NoOfDownloadedEntries(P)> 0) then begin
              MergeNewDataYN(Client, False, False, False, True);
              Retrieved := True;
              // One is enough.
              Exit;
           end;

      end;
begin
   if Assigned(ParentList) then begin
      DR := GetSelectDateRange;
      if DR.ToDate <= DR.FromDate then
         exit;
      Retrieved := False;
      RetrieveRange;

      // Note: do this before we enter the coding screens
      if Retrieved then
        RefreshHomePage([HPR_ExchangeGainLoss_NewData]);

      CloseAllCodingForms;
      NoData := True;

      with ParentList do
        for I := 0 to Count - 1 do
           CheckItem(TTreeBaseItem(List[i]));

      if Nodata then
         HelpfulInfoMsg('There are no Entries in the selected range.',0)
      else
         incUsage('Do Coding(Homepage)');

      if Retrieved then
         RefreshHomepage([HPR_Files, HPR_Coding]);
   end;
end;

function TCHAccountItem.CompareTagText(const Tag: integer;
  WithItem: TTreeBaseItem; SortDirection: TSortDirection): Integer;
var I1, I2 : comp;

    procedure doCompare;
    begin
       if I1 > I2 then
          Result := 1
       else if I1 < I2 then
          Result := -1;
    end;

begin
  result := 0;
  case Tag of

   CHPT_Period : begin
            if not assigned(FCodingStats) then exit;
            I1 :=  FCodingStats.GetPeriodStartDate(stFirstPeriod);
            if not (WithItem is TCHAccountItem) then exit;
            with TCHAccountItem(WithItem) do begin
              if not assigned(FCodingStats) then exit;
              I2 :=  FCodingStats.GetPeriodStartDate(stFirstPeriod);
            end;
            doCompare;
         end;

   CHPT_Balance : begin
            GetbankAccount;
            if not assigned (FAccount) then exit;
            I2 := FAccount.baFields.baCurrent_Balance;

            if not (withitem is TCHAccountItem) then exit;
            with TCHAccountItem(withitem) do begin
               GetbankAccount;
               if not assigned (FAccount) then exit;
               I1 := FAccount.baFields.baCurrent_Balance;
            end;
            doCompare;
         end;
    else
    Result := inherited CompareTagText(Tag,WithItem, SortDirection);
  end;
end;

function TCHAccountItem.AccountType: Byte;
begin
  GetBankAccount;
  if assigned (FAccount) then
     Result := FAccount.baFields.baAccount_Type
  else Result := 0;
end;

function TCHAccountItem.GetBankAccount: TBank_Account;
begin
  FAccount := nil;
  if Assigned(FClient) then
     if Assigned(FClient.clBank_Account_List) then
       FAccount := FClient.clBank_Account_List.FindCode(FbankCode);
  Result := FAccount;       
end;

function TCHAccountItem.GetTagHint(const Tag: Integer; Offset: TPoint): string;
begin
  case tag of
   CHPT_Code,
   CHPT_Name,
   CHPT_Text   : begin
         GetBankAccount;
         fHint := '';
         if Assigned(FAccount) then

         if FAccount.IsAJournalAccount then begin
             AddHint('Journal:');
             addHint(FAccount.AccountName);
         end else begin
             AddHint('Bank Account');
             addHint('Name: ' + FAccount.AccountName);
             addHint('Number: ' + FAccount.baFields.baBank_Account_Number);
         end;
         Result := FHint;
      end;
   CHPT_Processing  : result := inherited GetTagHint(Tag, Offset);
   end;
end;

function TCHAccountItem.GetTagText(const Tag: Integer): string;
var lr : TdateRange;
    Period: Integer;
begin
   Result := '';
   case tag of
   CHPT_Code        : begin
            GetbankAccount;
            if assigned (FAccount) then
               Result := FAccount.baFields.baBank_Account_Number;
         end;

   CHPT_Name        : Result := Title;
   CHPT_Text        : begin
            GetbankAccount;
            if assigned (FAccount) then
                Result := FAccount.baFields.baBank_Account_Number
                        + ' '
                        + FAccount.baFields.baBank_Account_Name
            else Result := Title;
         end;

   CHPT_Period : if assigned(FCodingStats) then begin
                    lr := MakeDateRange(
                       FCodingStats.GetPeriodStartDate(stFirstPeriod),
                       FCodingStats.GetPeriodEndDate(stLastPeriod));
                    //if lr.FromDate = 0 then Exit;
                    if lr.ToDate = 0 then Exit;
                    if lr.ToDate > MaxDate then Exit;
                     {
                    Result := Format( '%s-%s', [ Date2Str(Lr.FromDate, 'dd/mm/yy'),
                                                    Date2Str(Lr.ToDate,   'dd/mm/yy')]);
                    }
                     Result := Date2Str(Lr.ToDate,   'dd nnn yyyy');
         end;
   //100..113 : Result := 'box';
   CHPT_Balance : begin
                    GetbankAccount;
                    if Assigned (FAccount) and ( FAccount.baFields.baCurrent_Balance <> Unknown ) then
                      Result := FAccount.BalanceStr( FAccount.baFields.baCurrent_Balance );
                  end;

   CHPT_Report_Processing:
    begin
      if Assigned(FCodingStats) then
        for Period := 1 to 12 do
        begin
          if FCodingStats.GetPeriodFillColor(Period) = bkBranding.ColorTransferred then
            Result := Result + bkBranding.TextTransferred
          else if FCodingStats.GetPeriodFillColor(Period) = bkBranding.ColorFinalised then
            Result := Result + bkBranding.TextFinalised
          else if FCodingStats.GetPeriodFillColor(Period) = bkBranding.ColorUncoded then
            Result := Result + bkBranding.TextUncoded
          else if FCodingStats.GetPeriodFillColor(Period) = bkBranding.ColorCoded then
            Result := Result + bkBranding.TextCoded
          else if FCodingStats.GetPeriodFillColor(Period) = bkBranding.ColorDownloaded then
            Result := Result + bkBranding.TextDownloaded
          else
            Result := Result + bkBranding.TextNoData;
        end;
    end;

   CHPT_Currency :
    begin
      GetbankAccount;
      if Assigned (FAccount) then
        Result := FAccount.baFields.baCurrency_Code;
    end;
  end;
end;



function TCHAccountItem.HasAction(Period: Integer): Boolean;
begin
  case AccountType of
  btBank : Result := (FCodingStats.NoOfEntries(Period) > 0);
  btOpeningBalances,btYearEndAdjustments
         : Result := (Period > 0)
                  and (Period < 13)
                  and (FCodingStats.NoOfEntries(Period) > 0);
  else Result := (Period > 0)
             and (Period < 13);
  end;

end;


procedure TCHAccountItem.OnPaintText(const Tag: integer; Canvas: TCanvas;
  TextType: TVSTTextType);
begin
   //Canvas.Font.Color := GetFontColor;
end;

function TCHAccountItem.Refresh : boolean;
var FAccount : TBank_Account;
  function Checkstat : Boolean;
  var I : Integer;
  begin // Kicks out the ones we don't want o see...
     Result := True;
     //if FCodingStats.NoOfUncodedEntries(0) > 0 then Exit;

     for I  := 1 to stLastPeriod do
       if (FCodingStats.NoOfEntries(I) > 0)
       or (FCodingStats.NoOfDownloadedEntries(I) > 0) then
          Exit;
     // Still Here ... Nothing to show...
     Result := False;
  end;
begin
  Result := False;
  FCodingStats.Reset(Filldate);
  if FBankCode = '' then
     Exit;

  if Assigned(Client) then
     FAccount := FClient.clBank_Account_List.FindCode(FbankCode)
  else Exit;

  if not assigned(FAccount) then
     Exit;

  FCodingStats.GetStatistics(FClient, True, FAccount);
  Result := Checkstat;
end;


procedure TCHAccountItem.SetBankAccount(const Value: TBank_Account);
begin
  if Assigned(Value) then begin
     Title := Value.AccountName;
     FBankCode := Value.baFields.baBank_Account_Number;
  end else begin
     FBankCode := '';
  end;
end;

(*
procedure TCHAccountItem.UpdateDetails(Value: TRZGroup);
begin
    {
   if AperiodSelected then begin
      Value.Caption := 'Period Details';
      AddDetail('Account: ' + GetTagtext( CHPT_Text), Value);
      AddDetail('Period: ' + FCodingStats.GetDateRangeS(PeriodIndex), Value);
      AddDetail(  FCodingStats.GetPeriodText(PeriodIndex),value);
      if HasAction(PeriodIndex) then
         AddDetail('Code this period' ,Value,Code,Pointer(PeriodIndex));
   end else begin
      GetBankAccount;
      if not assigned (fAccount) then Exit;

      Value.Caption := 'Bank Account Details';
      AddDetail('Name: ' + FAccount.baFields.baBank_Account_Name,Value);
      AddDetail('Number: ' + FAccount.baFields.baBank_Account_Number,Value);
      AddDetail('Institution: ' + FAccount.baFields.baManual_Account_Institution,Value);
      AddDetail('Edit',Value,EditAccount,nil);
      if assigned(ParentList) then
          AddDetail('Code ' + bkDateUtils.GetDateRangeS(TCHPBaseList(parentlist).ReportPeriod),
                        Value,Code,Pointer(-1))

      else
          AddDetail('Code',Value,Code,Pointer(-1));
    end;
    }
end;
*)
procedure TCHAccountItem.UpdateMenu(const Tag: Integer; Offset: TPoint;
  Value: TpopupMenu);

var Dr: TDateRange;
    HasData: Boolean;
    I: Integer;

    function CheckItem(Item: TTreeBaseItem): Boolean;

      function FailRange : Boolean;
      var P : Integer;
      begin with TCHAccountItem(Item) do begin
         Result := False;
         for P := stFirstPeriod to stLastPeriod do
           if Selected[P]
           and ((FCodingStats.NoOfEntries(P)> 0) or (FCodingStats.NoOfDownloadedEntries(P)> 0)) then
             Exit;
         // Still here.. Nothing found
         Result := True;
      end;end;

   begin
      Result := False;
      if not Item.NodeSelected then
         Exit;
      if not (Item is TCHAccountItem) then
         Exit;
      with TCHAccountItem(Item) do begin
         if (GetBankAccount = nil) then
            Exit;
         if FailRange then
            Exit;
         HasData := True;
      end;
      Result := HasData;
   end;
begin
   if Tag = CHPT_Processing then begin
      if not (Assigned(BankAccount) or (Self is TCHJournalItem)) then
         Exit;

      if Assigned(ParentList) then begin
         DR := GetSelectDateRange;
         if DR.ToDate <= DR.FromDate then
            Exit;
         HasData := False;
         with ParentList do
           for I := 0 to Count - 1 do
              if CheckItem(TTreeBaseItem(List[i])) then
                 Break;

         if Hasdata then
            AddMenuItem('View ' + GetDateRangeS(DR),Value.Items,ContextCode,0);
       end;
   end;
end;


{ TCHPClienItem }

constructor TCHPCodingStatItem.Create( AClient: TClientObj; Stats : TStatisticsType);
begin
  inherited Create(AClient,'',0);
  FStats := Stats;
  FCodingStats := TClientCodingStatistics.Create(Client,True,stBlank,Filldate);
end;

destructor TCHPCodingStatItem.Destroy;
begin
  FCodingStats.Free;
  inherited;
end;

function TCHPCodingStatItem.GetSelectDateRange: TDateRange;
var p : Integer;
begin
   Result.FromDate := 0;
   Result.ToDate := 0;
   for p := {stFirstPeriod} 1 to 12 {stLastPeriod}  do
     if Selected[p] then begin
        if Result.FromDate = 0 then
           Result.FromDate := FCodingStats.GetPeriodStartDate(P);
        Result.ToDate := FCodingStats.GetPeriodEndDate(P);
     end;
end;

function TCHPCodingStatItem.GetTagHint(const Tag: Integer; Offset: TPoint): string;
var P : Integer;
begin
  case tag of

    CHPT_Processing : if assigned(FCodingStats) then begin
       FHint := '';
       AddHint(GetTagText(CHPT_Text));

       P := GetPeriod(Offset.x);
       if not (P in [0..13]) then exit;

       AddHint(FCodingStats.GetDateRangeS(P));
       AddHint(FCodingStats.GetPeriodText(P));
       Result := FHint;
    end;
    else Result := Title;
  end;
end;



{ TCHPeriodItem }


function TCHPeriodBaseItem.GetTagText(const Tag: Integer): string;
begin
  case Tag of
     CHPT_Code,
     CHPT_Text : Result := Title;
     CHPT_Processing : Result := ' '; //so we get a font...
     else  Result := '';
  end;
end;


procedure TCHPeriodBaseItem.OnPaintText(const Tag: integer; Canvas: TCanvas;
  TextType: TVSTTextType);
begin
    Canvas.Font:= appimages.Font;
    //Canvas.Font.Color := clBlack;
    Canvas.TextFlags  := Canvas.TextFlags and (not ETO_OPAQUE);
end;


{ TCHGSTPeriodItem }

function TCHGSTPeriodItem.GetTagText(const Tag: Integer): string;
var
  GSTp: Integer;
  GSTInfo: TPeriodInfo;  
begin
  if Tag = CHPT_Report_Processing then
  begin
    Result := '';
    for GSTp := 0 to FinfoList.Count - 1 do
    begin
      GSTInfo := GetInfo(GSTP);
      if GSTInfo.GetFillColor = bkBranding.ColorTransferred then
        Result := Result + bkBranding.TextTransferred
      else if GSTInfo.GetFillColor = bkBranding.ColorFinalised then
        Result := Result + bkBranding.TextFinalised
      else if GSTInfo.GetFillColor = bkBranding.ColorUncoded then
        Result := Result + bkBranding.TextUncoded
      else if GSTInfo.GetFillColor = bkBranding.ColorCoded then
        Result := Result + bkBranding.TextCoded
      else if GSTInfo.GetFillColor = bkBranding.ColorDownloaded then
        Result := Result + bkBranding.TextDownloaded
      else
        Result := Result + bkBranding.TextNoData;
    end;
  end
  else
    Result := inherited GetTagText(Tag);
end; 

procedure TCHGSTPeriodItem.AfterPaintCell(const Tag: integer; Canvas: TCanvas;
  CellRect: TRect);
var P: integer;
    GSTP: Integer;
    R: TRect;
    BoxType: TBoxType;
    GSTInfo: TPeriodInfo;
    LSelected: Boolean;
    PenColor : Integer;

begin
  if (tag = CHPT_Processing) then begin
      R := CellRect;
      for GSTp := 0 to FinfoList.Count - 1 do begin
         BoxType := CenterBox;
         GSTInfo := GetInfo(GSTP);
         Lselected := false;
         // Look for the start..
         // period 0 ...

         for p := 0 to 12 do begin
            if Incdate(PEDates[p]+ 1,0,-1,0) >= GSTInfo.DateRange.FromDate then begin
               // Frirst one Past the start date
               R.Left := CellRect.Left + LEDWidth * P;
               if P = 0 then begin
                  inc(R.Left,LedWidth);
                  BoxType := LeftBox;
               end;
               if Selected[p] then
                  Lselected := True;
               Break;
            end else if (PEDates[p] > GSTInfo.DateRange.FromDate) then begin
                R.Left := CellRect.Left + LEDWidth * (P+1);
               //if P = 0 then
                //BoxType := LeftArrow;

               if Selected[P+1] then
                  Lselected := True;
               Break;
            end;
         end;
         for P := P to 12 do begin

            if PEDates[P] >= GSTInfo.DateRange.ToDate  then begin
                // Firtst One past..
                if Selected[P] then
                   Lselected := True;
                R.Right := CellRect.left + LEDWidth * ( P +1 );
                Break;
            end{ else if PEDates[P] = GSTInfo.DateRange.ToDate  then begin
                // Firtst One past..
                R.Right := CellRect.left + LEDWidth * ( P + 1 );
                if PeriodIndex = P then
                   Lselected := True;
                Break;
            end};

         end;
         if P = 13 then begin
            BoxType := RightBox;
            R.Right := CellRect.left + LEDWidth * ( P {+1} );
         end;

         offsetRect(R,(BtnWidth - LEDWidth),0);

         if GSTInfo.HasAction then
            PenColor := ActionBorderColor
         else
            PenColor := BlankBorderColor;
         DrawCell(GSTInfo.GetFillColor,PenColor,Canvas,R,NodeSelected and Lselected,BoxType);
      end;
  end;
  inherited;
end;

constructor TCHGSTPeriodItem.Create(AClient: TClientObj);
Var
  TaxName : String;
begin
  TaxName := AClient.TaxSystemNameUC;
   inherited create(AClient, TaxName + ' Returns', grp_tax );
   MultiSelect := False;
   FInfoList := TObjectlist.Create(True);
end;

function TCHGSTPeriodItem.DateInfo(const EndDate: Integer): TPeriodInfo;
var I : Integer;
begin
   Result := nil;
   for I := 0 to FinfoList.Count - 1 do
      with TPeriodInfo(FinfoList[I]) do
         if (DateRange.FromDate < EndDate)
         and (EndDate <= DateRange.ToDate) then begin
            Result := TPeriodInfo(FinfoList[I]);
            Break;
         end;
end;


function TCHGSTPeriodItem.GetInfo(const Index: Integer): TPeriodInfo;
begin
   Result := nil;
   if (Index < FInfoList.Count)
   and (Index >= 0) then
      Result := TPeriodInfo( FInfoList[Index]);

end;

function TCHGSTPeriodItem.GetPeriodText(Value: TPeriodInfo): string;
begin
   fHint := Title;
   AddHint(GetdateRangeS(Value.DateRange));
   Addhint(Value.GetText);
   Result := FHint;
end;

function TCHGSTPeriodItem.GetTagHint(const Tag: Integer;
  Offset: TPoint): string;
var LInfo : TPeriodInfo;
    P : Integer;
begin
   Result := Title;
   case Tag of
   CHPT_Processing : begin
           P := GetPeriod(Offset.x);
           if  (P in [0..13]) then begin
              FHint := '';
              LInfo := PeriodInfo(P);
              if Assigned(LInfo) then begin
                 Result := GetPeriodText(LInfo);
              end;
           end;
      end;
   end;
end;

function TCHGSTPeriodItem.HasAction(Period: Integer): Boolean;
var LInfo : TPeriodInfo;
begin
   LInfo := PeriodInfo(Period);
   if Assigned(LInfo) then
      Result := LInfo.HasAction
   else
      Result := False;
end;

destructor TCHGSTPeriodItem.Destroy;
begin
  FInfoList.Free;
  inherited;
end;

function TCHGSTPeriodItem.DueText(Value: Integer): string;
begin
   case Value  of
      gpMonthly   :  Result := 'Due Monthly';
      gp2Monthly  :  Result := 'Due every 2 Months';
      gp6Monthly  :  Result := 'Due 6 Monthly';
      gpQuarterly :  Result := 'Due Quarterly';
      gpAnnually  :  Result := 'Due Annually';
      else Result := '';
   end;
end;


function TCHGSTPeriodItem.GetGSTPeriod(AnyDate, StartMonth, PeriodType : integer):TDateRange;
var
  D,  Y : Integer;
  Bal: pBalances_Rec;
Begin
  if Client.clFields.clCountry in [whNewZealand, whUK] then  // Check the balances first..

    with Client.clBalances_List do
      for D := First to Last do begin
         Bal := Balances_At(D); // easier to debug
         if (Bal.blGST_Period_Ends < AnyDate) then
            Continue; // Too early..
         if (Bal.blGST_Period_Starts > AnyDate) then
            Break; // Too Late
         {if not(GetPeriodMonths(Bal.blGST_Period_Starts,Bal.blGST_Period_Ends) in [1,2,6]) then
            Continue; // Not a valid period}
         // Basic date must be ok...
         Result.FromDate := Bal.blGST_Period_Starts;
         Result.ToDate := Bal.blGST_Period_Ends;
         Exit; // Done...
      end;

   if PeriodType = gpNone then
      exit;
   StDateToDMY( AnyDate, D, D, Y );
   Result.FromDate := DMYTostDate( 1, StartMonth, Y , EPOCH);
   if Result.FromDate > Anydate then begin
      // Too late.. find earlier
      repeat
         Result.FromDate := Get_Previous_PSDate_GST( Result.FromDate,PeriodType );
      until  Result.FromDate < AnyDate;
   end else if Result.FromDate = AnyDate then // fine..
   else
      // To small , but do we have the latest..
      repeat
         D := Get_Next_PSDate_GST( Result.FromDate,PeriodType );
         if D <= AnyDate then
           Result.FromDate := D;
         //else break...
      until  D > AnyDate;

   Result.ToDate :=   Get_PEDate_GST( Result.FromDate,PeriodType);
end;



function TCHGSTPeriodItem.PeriodInfo(Period: Integer): TPeriodInfo;
begin
  Result := nil;
  if FinfoList.Count = 0 then
      Exit;
  if assigned(ParentList) then
  with TCHPBaseList(ParentList) do
     case Period of
     0 : if (GetInfo(0).DateRange.FromDate < FPEDates[0]) then
            Result := GetInfo(0);
     13 : if (GetInfo(Pred(FinfoList.Count)).DateRange.ToDate > FPEDates[12]) then
            Result := GetInfo(Pred(FinfoList.Count));
     1..12 : Result := DateInfo( {Parent}FPEDates[Period]);
     end;
end;

function TCHGSTPeriodItem.Refresh: Boolean;
var LItem: TPeriodInfo;
    Ldate: Integer;
    I{,J} : Integer;
    (*  We Could look at balances as wel....
    p1,p2,n1,n2 : integer;
    This,Prev,Next : pBalances_Rec;

    function HaveBalances : Boolean;
    begin
       Result := true;
       if Assigned(This) then with This^ do begin
           if blClosing_Debtors_Balance <> 0 then exit;
           if blOpening_Debtors_Balance <> 0 then exit;
           if blFBT_Adjustments <> 0 then exit;
           if blOther_Adjustments <> 0 then exit;
           if blClosing_Creditors_Balance <> 0 then exit;
           if blOpening_Creditors_Balance <> 0 then exit;
           if blCredit_Adjustments <> 0 then exit;

           if blBAS_Adj_PrivUse <> 0 then exit;
           if blBAS_Adj_BAssets <> 0 then exit;
           if blBAS_Adj_Assets <> 0 then exit;
           if blBAS_Adj_Entertain <> 0 then exit;
           if blBAS_Adj_Change <> 0 then exit;
           if blBAS_Adj_Exempt <> 0 then exit;
           if blBAS_Adj_Other <> 0 then exit;

           if blBAS_Cdj_BusUse <> 0 then exit;
           if blBAS_Cdj_PAssets <> 0 then exit;
           if blBAS_Cdj_Change <> 0 then exit;
           if blBAS_Cdj_Other <> 0 then exit;
       end;
       if Assigned(Prev) then with Prev^ do begin
           if blClosing_Debtors_Balance <> 0 then exit;
           if blClosing_Creditors_Balance <> 0 then exit;
       end;

       if Assigned(Next) then with Next^ do begin
           if blOpening_Debtors_Balance <> 0 then exit;
           if blOpening_Creditors_Balance <> 0 then exit;
       end;
       // Still here...
       Result := False;
    end;
    *)
begin
   Result := True;
   FInfoList.Clear;
   Ldate := 0;
   for I := 1 to 12 do
     if not Assigned(DateInfo(PEDates[I])) then begin
        // Not covered yet...
        LItem := TPeriodInfo.Create;
        LItem.DateRange :=
           GetGSTPeriod(PEDates[I],Client.clFields.clGST_Start_Month, Client.clFields.clGST_Period);
        if LDate > Litem.DateRange.FromDate then begin
           Litem.DateRange.FromDate := Ldate + 1;
        end;
        LDate := Litem.DateRange.ToDate;

        CalculateGSTTotalsForPeriod(
             LItem.DateRange.FromDate,
             LItem.DateRange.ToDate,
             LItem.Info,
             -1);
        // See if we have balances

        (*
             {get balances for this gst period if available}
        This := nil;
        Prev := nil;
        Next := nil;
        with client, clFields do begin
          P1 := Get_Previous_PSDate_GST(  LItem.DateRange.FromDate, clGST_Period );
          P2 := Get_PEDate_GST( P1, clGST_Period );

          N1 := Get_Next_PSDate_GST( LItem.DateRange.FromDate, clGST_Period );
          N2 := Get_PEDate_GST( N1, clGST_Period );

          with clBalances_List do
             for J := 0 to Pred( itemCount ) do with Balances_At( J )^ do
                if  (blGST_Period_Starts = P1)
                and (blGST_Period_Ends   = P2) then
                   Prev := Balances_At( J )
                else
                if  (blGST_Period_Starts = LItem.DateRange.FromDate)
                and (blGST_Period_Ends   = LItem.DateRange.ToDate) then
                   This := Balances_At( J )
                else
                if (blGST_Period_Starts = N1 )
                and(blGST_Period_Ends   = N2 ) then
                   Next := Balances_At( J );

        end;

        if Havebalances then
           LItem.Info.guHasJournals := True;
        *)
        FinfoList.Add(LItem);
     end;
end;


procedure TCHGSTPeriodItem.RunAllocationSummary(Sender: TObject);
var LInfo : TPeriodInfo;
begin
   LInfo := PeriodInfo(FirstSelected);
   if Assigned(LInfo) then begin
      ApplicationUtils.DisableMainForm;
      try
         DoGSTAllocationSummary(rdScreen, nil,LInfo.DateRange.Fromdate, LInfo.DateRange.ToDate);
      finally
         ApplicationUtils.EnableMainForm;
         ApplicationUtils.MakeMainFormForeground;
      end;
   end;
end;


procedure TCHGSTPeriodItem.RunAuditTrail(Sender: TObject);
var LInfo : TPeriodInfo;
begin
  LInfo := PeriodInfo(FirstSelected);
  if Assigned(LInfo) then
  begin
    ApplicationUtils.DisableMainForm;
    CreateReportImageList;
    try
      DoGSTAudit(rdScreen, nil,LInfo.DateRange.Fromdate, LInfo.DateRange.ToDate);
    finally
      DestroyReportImageList;
      ApplicationUtils.EnableMainForm;
      ApplicationUtils.MakeMainFormForeground;
    end;
  end;
end;

procedure TCHGSTPeriodItem.RunOverides(Sender: TObject);
var LInfo : TPeriodInfo;
begin
   LInfo := PeriodInfo(FirstSelected);
   if Assigned(LInfo) then
   begin
      ApplicationUtils.DisableMainForm;
      CreateReportImageList;
      try
        DoGSTOverrides(rdScreen, nil,LInfo.DateRange.Fromdate, LInfo.DateRange.ToDate);
      finally
        DestroyReportImageList;
        ApplicationUtils.EnableMainForm;
        ApplicationUtils.MakeMainFormForeground;
      end;
   end;

end;

(*
procedure TCHGSTPeriodItem.RunReconcile(Sender: TObject);
var LInfo : TPeriodInfo;
begin
   LInfo := PeriodInfo(FirstSelected);
   if Assigned(LInfo) then
       DoGSTReconciliation(rdScreen, nil,
         LInfo.DateRange.Fromdate, LInfo.DateRange.ToDate)
end;
*)

procedure TCHGSTPeriodItem.RunReturn(Sender: Tobject);
var LInfo : TPeriodInfo;
begin
   LInfo := PeriodInfo(FirstSelected);
   if Assigned(LInfo) then  begin
      ShowGST101Form ( LInfo.DateRange.Fromdate, LInfo.DateRange.ToDate );
      incUsage(REPORT_LIST_NAMES[Report_GST101] + '(Home Page)');
   end;
end;


procedure TCHGSTPeriodItem.RunSummary(Sender: TObject);
var LInfo : TPeriodInfo;
begin
  LInfo := PeriodInfo(FirstSelected);
  if Assigned(LInfo) then
  begin
    ApplicationUtils.DisableMainForm;
    CreateReportImageList;
    try
      DoGSTSummary(rdScreen, nil,LInfo.DateRange.Fromdate, LInfo.DateRange.ToDate);
    finally
      DestroyReportImageList;
      ApplicationUtils.EnableMainForm;
      ApplicationUtils.MakeMainFormForeground;
    end;
  end;
end;              

function TCHGSTPeriodItem.SelectPeriod(const Value: Integer; Shift: TShiftstate): Boolean;
var LInfo :TPeriodInfo;
    I,P : Integer;
begin
   Result := False;
   if (Value < stFirstPeriod)
   or (Value > stLastPeriod) then begin
      for i := stFirstPeriod to stLastPeriod do
         Selected[i] := False;

   end else begin
      if Value = stFirstPeriod then begin
         p := 1
      end else if value = stLastPeriod then begin
         p := 12
      end else begin
         P := Value;
         Result := True;
      end;

      LInfo := PeriodInfo(P);

      for i := stFirstPeriod to stLastPeriod do
         if assigned(LInfo) then
            Selected[i] := (PeriodInfo(I) = Linfo)
         else Selected[i] := False;
   end;
   ParentList.Tree.InvalidateColumn(1);
end;

(*
procedure TCHGSTPeriodItem.UpdateDetails(Value: TRZGroup);
var LInfo :TPeriodInfo;
begin
   if APeriodSelected then begin
      Value.Caption :='GST Return';
      LInfo := PeriodInfo(FirstSelected);

      if Assigned(LInfo) then
      with LInfo do begin
          AddDetail('Period '
              + GetDateRangeS(DateRange), Value);
          AddDetail('View Return' ,Value,RunReturn,Pointer(FirstSelected));
      end;

   end else begin
      Value.Caption :='GST Returns';
      if (Client.clFields.clGST_Period = 0)
      or (Client.clFields.clGST_Start_Month = 0) then
         AddDetail('Please Set Up GST', Value,EditGst)
      else begin
         AddDetail(DueText(Client.clFields.clGST_Period), Value);
         AddDetail('Starting ' + LongMonthNames[Client.clFields.clGST_Start_Month], Value);
         AddDetail('GST Settings' ,Value,EditGst);
      end;
   end;
end;
*)

procedure TCHGSTPeriodItem.UpdateMenu(const Tag: Integer; Offset: TPoint;
  Value: TpopupMenu);
var P : Integer;
    LInfo : TPeriodInfo;
    TaxName : String;
begin
   case Tag of
   CHPT_Processing : begin
              P := FirstSelected;
              LInfo := PeriodInfo(P);
              if assigned(LInfo) then
              begin
                TaxName := fClient.TaxSystemNameUC;
                //if LInfo.HasAction then
                case fClient.clFields.clCountry of
                  whNewZealand : AddMenuItem('GST Return', Value.Items, RunReturn,P);
                  whAustralia  : AddMenuItem('Business/Instalment Activity Statements' ,Value.Items,RunReturn,P);
                  whUK         : AddMenuItem('VAT Return', Value.Items, RunReturn,P);
                end;
                AddMenuItem( TaxName + ' Audit Trail', Value.Items, RunAudittrail,P);
                AddMenuItem( TaxName + ' Summary', Value.Items, RunSummary,P);
                if (fCLient.clFields.clCountry = whNewZealand)
                and PRACINI_PaperSmartBooks then
                    AddMenuItem('GST Allocation Summary', Value.Items,RunAllocationSummary,P);

                AddMenuItem( TaxName + ' Overrides',Value.Items ,RunOverides,P);
              end;
           end;
   //else AddMenuItem('GST Settings' ,Value,EditGst);
   end;
end;

procedure TCHGSTPeriodItem.DoChange(const value: TVirtualNodeStates);
begin
   if vsSelected in Value then begin
      if toMultiselect in ParentList.Tree.TreeOptions.SelectionOptions  then begin
        ParentList.Tree.TreeOptions.SelectionOptions :=
          ParentList.Tree.TreeOptions.SelectionOptions - [toMultiselect];
        ParentList.Tree.Selected [Node] := True
      end;
      SelectPeriod(FirstSelected,[]);
   end;
end;

procedure TCHGSTPeriodItem.DoubleClickTag(const Tag: Integer; Offset: TPoint);
begin
   case tag of
    {
   CHPT_Code,
   CHPT_Name,
   CHPT_Text : EditGst(nil);
     }
   CHPT_Processing : RunReturn(nil)
   end; //Case
end;

{ TCHYearItem }




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


procedure TCHYearItem.AfterPaintCell(const Tag: integer; Canvas: TCanvas;
  CellRect: TRect);

const
  OTop  = 2{20};
  OLeft = 2;

var
  Period: Integer;
  R : TRect;

  mt : string;

  procedure FillHeaderRect (ButtonR : TRect);
  var Details: TThemedElementDetails;
      PaintBrush: HBRUSH;
      Pen,
      OldPen: HPEN;
      PenColor,
      FillColor: COLORREF;
      dRed, dGreen, dBlue: Single;

  begin
     if tsUseThemes in Parentlist.Tree.TreeStates then begin
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

  procedure LDrawCell( const Period : integer{; LEDColor,PenColor : TColor});
  var
    XOffset : Integer;
    function ShortYearText(Value : Integer): string;
    begin
       Value := value MOD 100;
       Result := '00';
       wvsprintf(Pchar(Result),'%02i',@Value);
      // Result := Format('%02D',[Value]);
    end;

    procedure DoMonthText ( Value : string);
    begin
       Canvas.TextOut(R.Left + 7,R.Top - 8, Value [1]);
       Canvas.TextOut(R.Left + 7,R.Top + 2, Value [2]);
       Canvas.TextOut(R.Left + 7,R.Top + 12, Value [3]);
    end;

  begin
    XOffset := LEDWidth * ( Period  ) + (BtnWidth - LEDWidth);
    R := CellRect;
    R.Right   := R.Left +  LEDWidth + 1;

    OffsetRect( R, XOffset, 0) ;

    mt := GetMonthText( PEDates[Period]); // Set fMonth
    if fMonth <> 12 then
        R.Top  := R.Bottom  -  MonthHeight;

    if period < 12 then
       FillHeaderRect (R);

    R.Top  := R.Bottom  -  MonthHeight;
    DrawText(Canvas.Handle, PChar(mt), -1, R, DT_SINGLELINE or DT_VCENTER or DT_CENTER);

    if FMonth = 1 then begin
       // Draw the year boxes
       OffsetRect( R, 0, - MonthHeight ) ;
       R.Right   := R.Left +  LEDWidth * (12 - Period) + BtnWidth  -1;



      // Canvas.Rectangle( R );
       if period = 1 then begin
          // Only one year (box)
          Canvas.TextOut(r.Left + 2 ,r.Top + 1, IntToStr(FYear));
          //DrawText(Canvas.Handle, PChar(IntToStr(FYear)), -1, R, DT_SINGLELINE or DT_VCENTER or DT_CENTER);
       end else begin
          if Period = 12 then
             Canvas.TextOut(r.Left + 2,r.Top + 1,  ShortYearText(FYear))
          else
             Canvas.TextOut(r.Left + 2 ,r.Top + 1, IntToStr(FYear));
          // Now make the other box
          R.Right := R.Left -1;
          R.Left := CellRect.Left + 1 + btnWidth;

          //Canvas.Rectangle( R );
          if Period = 2 then
             Canvas.TextOut(r.Left + 2 ,r.Top + 1, ShortYearText(Pred(FYear)))
          else
             Canvas.TextOut(r.Left + 2,r.Top + 1, IntToStr(Pred(FYear)));
       end;

    end;

  end;

begin


  if (tag = CHPT_Processing) then begin

     FMonthLeft.SetBounds
        (CellRect.Left+OLeft,
         CellRect.Top + OTop + MonthHeight,
         BtnWidth, MonthHeight );

     FMonthRight.SetBounds
        (CellRect.Left+OLeft + LEDWidth * 13+ (BtnWidth -LEDWidth),
         CellRect.Top + OTop + MonthHeight,
         btnWidth, MonthHeight );

     FYearLeft.SetBounds
        (CellRect.Left+OLeft,
         CellRect.Top + OTop,
         BtnWidth, MonthHeight );

     FYearRight.SetBounds
        (CellRect.Left + LEDWidth * 13+OLeft + (BtnWidth -LEDWidth),
         CellRect.Top+ OTop,
         BtnWidth ,MonthHeight );

     FillHeaderRect (CellRect);

     for Period := 1 to 12 do
        LDrawCell( Period{,clWebWhite{,clBtnshadow});

  end else begin
     FillHeaderRect (CellRect);
  end;


end;

constructor TCHYearItem.Create(AClient: TClientObj; ML, MR,
  YL, YR : TControl);
begin
   inherited create(AClient,'',-1);
   FMonthLeft  := ML;
   FMonthRight := MR;
   FYearLeft   := YL;
   FYearRight  := YR;
end;

function TCHYearItem.GetNodeHeight(const Value: Integer): Integer;
begin
  Result := max (Value, (MonthHeight * 2) + 2 );
end;


{ TCHPeBaseList }
function TCHPBaseList.CheckCodingItem(Item: TTreeBaseItem): Boolean;
begin
  if (Item is TCHAccountItem) and
     (TCHAccountItem(Item).AccountType = btBank) then
  begin
    CloseAllCodingForms;
    Result := True;
  end
  else if (Item is TCHJournalItem) then
  begin
    CloseCodingScreen(TCHJournalItem(Item).GetBankAccount);
    Result := True;
  end
  else
    Result := False;
end;

procedure TCHPBaseList.CodeRange(Value: TRangeCount);
var I,P : Integer;
begin
  for I := 0 to Count - 1 do
      if (Items[I] is TCHAccountItem) then
      with TCHAccountItem(Items[I]) do
         if GroupID = grp_Bank then
         for P := 1 to 12 do
           if ((FCodingStats.NoOfUncodedEntries(P) > 0) or
               (FCodingStats.NoOfNonPostingEntries(P) > 0) or
               (FCodingStats.NoOfInvalidGSTEntries(P) > 0))
           and (FCodingStats.GetPeriodStartDate(P) >= Value.Range.Fromdate)
           and (FCodingStats.GetPeriodEndDate(P) <= Value.Range.Todate) then begin
              incUsage('Do Coding(Homepage)');
              CodeTheseEntries(Value.Range.FromDate, value.Range.ToDate, BankAccount, [CC_GotoFirstUncoded]);
              Break;
           end;
end;

constructor TCHPBaseList.Create(ATree: TVirtualStringTree; AClient: TClientObj);
begin
   inherited create (ATree);
   FClient := AClient;
end;

function TCHPBaseList.GetMonths(RetrieveCodingMonths: boolean; RetrieveInvalidGST: boolean): TRangeCount;
var lSel: array [1..12] of integer;
    I, P : Integer;
begin
   Result.Range.ToDate := 0;
   Result.Range.FromDate := 0;
   Result.Count := 0;
   FillChar(lsel,Sizeof(LSel),0);
   for I := 0 to Count - 1 do
      if (Items[I] is TCHPCodingStatItem) then
      with TCHPCodingStatItem(Items[I]) do
         if GroupID = grp_Bank then
            for P := 1 to 12 do
            begin
              if RetrieveCodingMonths then
              begin
                inc(Lsel[P],FCodingStats.NoOfUncodedEntries(P));
                inc(Lsel[P],FCodingStats.NoOfNonPostingEntries(P));
              end;
              if RetrieveInvalidGST then
                inc(Lsel[P],FCodingStats.NoOfInvalidGSTEntries(P));
            end;

   for P := 12 downto 1 do
     if Lsel[P] > 0 then begin
        if Result.Count = 0 then // Last Period
           Result.Range.ToDate := FPEDates[P];
        Inc(Result.Count,Lsel[P]);
     end else begin
        if Result.Count> 0 then begin// First Period Past
           Result.Range.FromDate := FPEDates[P] + 1;
           Break;
        end;
     end;
   if (Result.Count > 0)
   and (Result.Range.FromDate = 0) then
        Result.Range.FromDate := FPEDates[0] + 1;
end;

function TCHPBaseList.GetCodingAndGSTMonths: TRangeCount;
begin
  Result := GetMonths(True, True);
end;

function TCHPBaseList.GetCodingMonths: TRangeCount;
begin
  Result := GetMonths(True, False);
end;

function TCHPBaseList.GetGSTMonths: TRangeCount;
begin
  Result := GetMonths(False, True);
end;

function TCHPBaseList.GetTransferMonths: TRangeCount;
begin
  Result := GetTransferMonths(False);
end;

// Skips transactions with non posting chart codes, or invalid GST classes
function TCHPBaseList.GetTransferMonthsValidOnly: TRangeCount;
begin
  Result := GetTransferMonths(True);
end;

function TCHPBaseList.GetTransferMonths(CheckValidity: boolean = False): TRangeCount;
var lSel: array [1..12] of integer;
    I, P : Integer;
begin
   Result.Range.ToDate := 0;
   Result.Range.FromDate := 0;
   Result.Count := 0;
   FillChar(lsel,Sizeof(LSel),0);
   for I := 0 to Count - 1 do // add them up...
     if Items[I] is TCHAccountItem then with TCHAccountItem(Items[I]) do
     if AccountType in [btBank, btCashJournals, btAccrualJournals]  then
        for P := 1 to 12 do
           if LSel[P] >= 0 then begin // else turned off
              if FCodingStats.NoOfUncodedEntries(P) = 0 then
                if ((FCodingStats.NoOfInvalidGSTEntries(P) = 0) and (FCodingStats.NoOfNonPostingEntries(P) = 0))
                or (CheckValidity = False) then
                  inc(Lsel[P],FCodingStats.NoOfEntriesReadyToTransfer(P))
              else
                Lsel[P] := -1; // Only one needs to be uncoded..
           end;

   for P := 12 downto 1 do
     if Lsel[P] > 0 then begin
        if Result.Count = 0 then // Last Period
           Result.Range.ToDate := FPEDates[P];
        Inc(Result.Count,Lsel[P]);
     end else begin
        if Result.Count> 0 then begin// First Period  Past
           Result.Range.FromDate := FPEDates[P] + 1;
           Break;
        end;
     end;
   if (Result.Count > 0)
   and (Result.Range.FromDate = 0) then
        Result.Range.FromDate := FPEDates[0] + 1;

end;

procedure TCHPBaseList.OnKeyDown(var Key: Word; Shift: TShiftState);
var
  lNode: PVirtualNode;
  CheckAction: Boolean;
  I: Integer;
begin

  CheckAction := False;
  if (Key = VK_Return) then
  begin
    lNode := Tree.GetFirstSelected;
    while assigned(lNode) do
    begin
      if CheckCodingItem (GetNodeItem(lNode)) then
      begin
        // make sure all coding screens are closed...
        CheckAction := true;
        Break;
      end;
      lNode := Tree.GetNextSelected(LNode);
    end;
  end;

  inherited;

  if CheckAction then
  begin
    for I := 0 to Pred(frmMain.MDIChildCount) do
      if (frmMain.MDIChildren[i] is TfrmCoding) then
        Exit;

    HelpfulInfoMsg('There are no Entries in the selected range.',0);
  end;
end;

procedure TCHPBaseList.SetClient(const Value: TClientObj);
begin
  FClient := Value;
end;

function TCHPBaseList.GetDateRangeStr: string;
begin
  Result := FormatDateTime('mmm yy', FPEdates[1]) + ' to ' + FormatDateTime('mmm yy', FPEDates[12]);
end;

procedure TCHPBaseList.SetFillDate(const Value: Integer);
var LOldPEDates  : TMonthEndDates;
    LOldSel : TSelectionArray;
    I,J : Integer;
begin
  if FFillDate <> Value then begin
     LOldPEDates := FPEDates;
     lOldSel := FSelection;

     FPEDates := GetMonthEndDates(Value);
     // Redo the selection...
     FillChar(FSelection,Sizeof(FSelection),0);
     for I := 1 to 12 do
        if lOldSel[I] then
           for J := 1 to 12 do
             if LOldPEDates[I] = FPEDates[J] then
                FSelection[J] := True;

      if (Value > FFilldate) then begin
        if lOldSel[0]
        or loldsel[1] then FSelection[0] := true
        else
        if lOldSel[13] then FSelection[12] := true ;
      end else begin
        if lOldSel[13]
        or lOldSel[12] then FSelection[13] := true
        else
        if loldSel[0] then FSelection[1] := true;

      end;

      FFillDate := Value;
  end;
end;


procedure TCHPBaseList.SetLEDHeight(const Value: Integer);
begin
  FLEDHeight := Value;
end;

procedure TCHPBaseList.SetLEDWidth(const Value: Integer);
begin
  FLEDWidth := Value;
end;

function TCHPBaseList.TestAccount(Item: TTreeBaseItem; var TestFor): Boolean;
begin
  Result := False;
  if Item is TCHAccountItem then
     Result := Sametext(TCHAccountItem(Item).FBankCode ,
                         TBank_Account(TestFor).baFields.baBank_Account_Number
                       );
end;

function TCHPBaseList.TestAccountType(Item: TTreeBaseItem;
  var TestFor): Boolean;
begin
  Result := False;
  if Item is TCHAccountItem then
     Result := (TCHAccountItem(Item).AccountType = Integer(TestFor));
end;

function TCHPBaseList.TestBlanks(Item: TTreeBaseItem; var TestFor): Boolean;
begin
   Result := Item is TCHEmptyJournal;
end;

function TCHPBaseList.TestForeign(Item: TTreeBaseItem; var TestFor): Boolean;
begin
  Result := Item is TCHForeignItem;
end;

function TCHPBaseList.TestGroup(Item: TTreeBaseItem; var TestFor): Boolean;
begin
   Result := Item.GroupID = Integer(TestFor);
end;

function TCHPBaseList.TestGST(Item: TTreeBaseItem; var TestFor): Boolean;
begin
   Result := Item is TCHGSTPeriodItem;
end;

function TCHPBaseList.TestYear(Item: TTreeBaseItem; var TestFor): Boolean;
begin
  Result := Item is TCHYearItem;
end;

procedure TCHPBaseList.TreeBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellRect: TRect);

 var MousePos : TPoint;
     P : Integer;
     ProcCol : Integer;

     function GetPeriod(const Offset: Integer): Integer;
     begin
        if offset > btnWidth  then
           Result := ((Offset - BtnWidth + LEDWidth {- HLEDGap}) Div LEDWidth)
        else
           Result := 0
     end;
begin

   if (([tsDrawSelecting,tsDrawSelPending] * Sender.TreeStates) <> [])
   and (not (toMultiselect in Tree.TreeOptions.SelectionOptions)) then begin
      Sender.TreeStates := Sender.TreeStates - [tsDrawSelecting,tsDrawSelPending];

   end;

   if (([tsDrawSelecting{,tsDrawSelPending}] * Sender.TreeStates) <> [])
   and (toMultiselect in Tree.TreeOptions.SelectionOptions) then begin
      // repaint During Selection...
      ProcCol := 1; // Assumes Process is Col 1 Should make a loop...


      MousePos := Mouse.CursorPos;
      MousePos := Tree.ScreenToClient(MousePos);

      if (MousePos.X < Tree.Header.Columns[ProcCol].Left) then
         P := -1
      else if (MousePos.X > Tree.Header.Columns[ProcCol].Left
            + Tree.Header.Columns[ProcCol].Width ) then
         P := 14
      else
         P := GetPeriod(MousePos.X - Tree.Header.Columns[ProcCol].Left);

      if FFirstDrawSel = -2 then
         FFirstDrawSel := p;


      if P <> FLastDrawSel then begin
         FLastDrawSel := P;
         if FLastDrawSel >= FFirstDrawSel then
            for P := stFirstPeriod to stLastPeriod do
               FSelection[P] := (P >= FFirstDrawSel)
                             and (P <= FlastDrawSel)
         else
            for P := stFirstPeriod to stLastPeriod do
               FSelection[P] := (P <= FFirstDrawSel)
                             and (P >= FlastDrawSel);

         Tree.InvalidateColumn(ProcCol);

      end;
   end else begin

      if  FFirstDrawSel >= -1 then begin // Turn it off
         FFirstDrawSel := -2;
         FLastDrawSel := -2;
      end;
   end;



end;


procedure TCHPBaseList.TreeOnDblClick(Sender: TObject);
var lNode: PVirtualNode;
begin
   lNode := Tree.GetFirstSelected;
   while assigned(lNode) do begin
      if CheckCodingItem (GetNodeItem(lNode)) then
         Break;
      lNode := Tree.GetNextSelected(LNode);
   end;

  inherited;
end;

{ TCHJournalItem }


procedure TCHJournalItem.AddTransaction(Sender: TObject);
begin
    if Assigned(Sender) then begin
      // 'is' does not like it when the object is nil...
      if Sender is TRzGroupItem then
         EnterJournal(AccountType, integer (TRzGroupItem(Sender).Data))
      else if Sender is TmenuItem then
         EnterJournal(AccountType, TmenuItem(Sender).Tag)
      else
         Exit;
    end else
       Exit;

    Refresh;
end;


(*
procedure TCHJournalItem.DoChange(const value: TVirtualNodeStates);
begin
   if vsSelected in Value then begin
      if toMultiselect in ParentList.Tree.TreeOptions.SelectionOptions  then begin
        ParentList.Tree.TreeOptions.SelectionOptions :=
          ParentList.Tree.TreeOptions.SelectionOptions - [toMultiselect];
        ParentList.Tree.Selected [Node] := True
      end;
      SelectPeriod(FirstSelected,[]);
   end;
end;
*)
procedure TCHJournalItem.DoCoding;
var DR: TdateRange;
begin
   if AccountType = btOpeningBalances then begin
      OpeningBalances(nil);
      Exit;
   end;

   DR := GetSelectDateRange;

   FAccount := GetJournalAccount(AccountType);
   if not assigned(FAccount) then
      Exit; // Should never happen


   CodeRange(DR, FAccount,[]);

   case AccountType of
        btCashJournals       : IncUsage('Cash Journals(Home Page)');
        btAccrualJournals    : IncUsage('Accrual Journals(Home Page)');
        btGSTJournals        : IncUsage('Non-Transferring Journals - GST Journals(Home Page)');
        btStockJournals      : IncUsage('Non-Transferring Journals - Stock Adjustment Journals(Home Page)');
        btOpeningBalances    : IncUsage('Opening Balances(Home Page)');
        btYearEndAdjustments : IncUsage('Non-Transferring Journals - Year End Adjustments(Home Page)');
   end;


   //Account may have become invalid
   Refresh;
   if Assigned(ParentList) then
      TCHPBaseList(ParentList).Tree.Update;

end;


procedure TCHJournalItem.DoubleClickTag(const Tag: Integer; Offset: TPoint);

var Dr: TDateRange;
    HasData: Boolean;
    I: Integer;

    function CheckItem(Item: TTreeBaseItem): Boolean;

      function FailRange : Boolean;
      var P : Integer;
      begin with TCHAccountItem(Item) do begin
         Result := False;
         for P := stFirstPeriod to stLastPeriod do
           if Selected[P]
           and (FCodingStats.NoOfEntries(P)> 0) then
             Exit;
         // Still here.. Nothing found
         Result := True;
      end;end;

   begin
      Result := False;
      if not Item.NodeSelected then
         Exit;
      if not (Item is TCHAccountItem) then
         Exit;
      with TCHAccountItem(Item) do begin
         if (GetBankAccount = nil) then
            Exit;
         if FailRange then
            Exit;
         HasData := True;
      end;
      Result := HasData;
   end;
begin
   if Tag = CHPT_Processing then begin
      if not (Assigned(BankAccount) or (Self is TCHJournalItem)) then
         Exit;
      // Is a bit overkill, but allows for multi select..
      if Assigned(ParentList) then begin
         DR := GetSelectDateRange;
         if DR.ToDate <= DR.FromDate then
            Exit;

         HasData := False;
         with ParentList do
           for I := 0 to Count - 1 do
              if CheckItem(TTreeBaseItem(List[i])) then
                 Break;

         if Hasdata then begin
            DoCoding;
         end else begin
            if AccountType <> btOpeningBalances then  // Should do this first ??
               EnterJournal(AccountType, DR.ToDate);
         end;

       end;
   end;
end;



procedure TCHJournalItem.ContextCode(Sender: TObject);
   procedure CheckItem(Item: TTreeBaseItem);
   begin
      if not Item.NodeSelected then
         Exit;
      if not (Item is TCHJournalItem) then
         Exit;
      with TCHJournalItem(Item) do begin
         DoCoding;
      end;
   end;

var I: Integer;
begin
   if Assigned(ParentList) then begin
      CloseAllCodingForms;
      with ParentList do
         for I := 0 to Count - 1 do
           CheckItem(TTreeBaseItem(List[i]));
   end;
end;


function TCHJournalItem.CompareTagText(const Tag: integer;
  WithItem: TTreeBaseItem; SortDirection: TSortDirection): Integer;
Type
  TByteSet = set of byte;
  procedure LTest ( Bigger : TByteSet );
  begin
     if TCHJournalItem (WithItem).AccountType in Bigger then
        Result := -1;
  end;
begin
   Result := 1; // I am bigger...
   case AccountType of
   btBank            :; // What the...
   btCashJournals    :; //Ok
   btAccrualJournals : LTest( [btCashJournals]);
   btGSTJournals     : LTest( [btOpeningBalances,btOpeningBalances,btAccrualJournals,btCashJournals]);
   btStockJournals   : LTest( [btCashJournals,btAccrualJournals,btOpeningBalances]);
   btOpeningBalances : LTest( [btCashJournals,btAccrualJournals]);
   btYearEndAdjustments : LTest( [btOpeningBalances,btOpeningBalances,btAccrualJournals,btCashJournals,btGSTJournals]);
   end;
   if SortDirection = sdAscending then
     Result := - Result;
end;

(*procedure TCHJournalItem.EditTransaction(Sender: TObject);
begin
   //Sender is expected to be the GroupItem;
   if Assigned(Sender) then begin
      // 'is' does not like it when the object is nil...
      GetBankaccount;
      if not assigned(FAccount) then Exit;

      if Sender is TRzGroupItem then
         EditJournalEntry(FAccount, TRzGroupItem(Sender).Data ,AccountType, 0)
      else
      if Sender is TmenuItem then
         EditJournalEntry(FAccount, Pointer (TmenuItem(Sender).Tag) ,AccountType, 0)
      else exit;
   end else
     exit;
    // Account may have become invalid
   Refresh;
end;
*)


function TCHJournalItem.GetTagText(const tag: Integer): string;
var
  Period: Integer;
begin
   Result := '';
   case tag of
   CHPT_Code        : Result := FBankCode;
   CHPT_Name        : Result := Title;
   CHPT_Text        : Result := Title;
   CHPT_Period : if assigned(FCodingStats) then begin
                    Period := FCodingStats.GetPeriodEndDate(stLastPeriod);
                    if Period = 0 then Exit;
                    if Period > MaxDate then Exit;
                    Result := Date2Str(Period,   'dd nnn yyyy');
         end;
   CHPT_Report_Processing:
    begin
      if Assigned(FCodingStats) then
        for Period := 1 to 12 do
        begin
          if FCodingStats.GetPeriodFillColor(Period) = bkBranding.ColorTransferred then
            Result := Result + bkBranding.TextTransferred
          else if FCodingStats.GetPeriodFillColor(Period) = bkBranding.ColorFinalised then
            Result := Result + bkBranding.TextFinalised
          else if FCodingStats.GetPeriodFillColor(Period) = bkBranding.ColorUncoded then
            Result := Result + bkBranding.TextUncoded
          else if FCodingStats.GetPeriodFillColor(Period) = bkBranding.ColorCoded then
            Result := Result + bkBranding.TextCoded
          else if FCodingStats.GetPeriodFillColor(Period) = bkBranding.ColorDownloaded then
            Result := Result + bkBranding.TextDownloaded
          else
            Result := Result + bkBranding.TextNoData;
        end;
    end;
   //CHPT_Processing  :
   end;
end;

(*
function TCHJournalItem.Refresh: Boolean;
begin
   Result := inherited Refresh;
   if nodeselected then SelectPeriod(FirstSelected,[]);
end;
*)
(*
function TCHJournalItem.SelectPeriod(const Value: Integer; Shift: TShiftstate): Boolean;
var I : Integer;
begin
   if (Value < stFirstPeriod)
   or (Value > stLastPeriod) then begin
      for i := stFirstPeriod to stLastPeriod do
         Selected[i] := False;
      Result := False;
   end else begin
       for i := stFirstPeriod to stLastPeriod do
         Selected[i] := (i = Value);
       Result := Value in [ (stFirstPeriod + 1) .. (stLastPeriod -1)];
   end;
   if Assigned(ParentList) then
      ParentList.Tree.InvalidateColumn(1);
end;
*)
(*
procedure TCHJournalItem.UpdateDetails(Value: TRZGroup);
var i : Integer;
    lTrans : pTransaction_Rec;
    DR : tDateRange;

    function CodedText : string;
    var Dissection: pDissection_Rec;
        Uncoded : Integer;
    begin
       Uncoded := 0;
       Dissection := Ltrans.txFirst_Dissection;
       while Dissection <> nil do begin
          if not Client.clChart.CanCodeTo( Dissection.dsAccount ) then
             Inc( Uncoded);
          Dissection := Dissection.dsNext;
       end;
       if Uncoded = 0 then
          Result := ''
       else
          Result := ' (' + IntTostr(Uncoded) + ' uncoded)'

    end;
begin

   AddDetail(Title,Value);
   if FirstSelected < 0  then begin
      Value.Caption := 'Journal Details';
      if assigned(BankAccount) then
         AddDetail('Edit',Value,EditAccount);
   end else if AccountType = btOpeningBalances then begin
      // Special case...
      // Only the
      Value.Caption := 'Opening Balance';
      AddDetail('Date:' + StDateToDateString( 'dd nnn yyyy', Client.clFields.clFinancial_Year_Starts, true),
                 value);
      AddDetail('Opening Balance',Value, OpeningBalances);
   end else begin
      Value.Caption := 'Period Details';

      AddDetail('Period: ' + FCodingStats.GetDateRangeS(FirstSelected), Value);

      AddDetail(  FCodingStats.GetPeriodText(FirstSelected),value);
      if HasAction(FirstSelected) then begin

         DR := FCodingStats.GetDateRange(FirstSelected);
         GetBankAccount;
         if assigned(FAccount) then begin
            for i := 0 to Pred(FAccount.baTransaction_List.ItemCount) do
               with FAccount.baTransaction_List.Transaction_At( i)^ do
                  if (txDate_Effective >= Dr.FromDate)
                  and (txDate_Effective <= Dr.ToDate) then begin
                     lTrans := FAccount.baTransaction_List.Transaction_At( i);
                     AddDetail(  Date2Str( txDate_Effective, 'dd-nnn-yyyy' ) + CodedText ,
                            Value,EditTransaction,Ltrans);
                  end;
         end;
         AddDetail('Add Entry' ,Value,AddTransaction,Pointer(DR.ToDate));
      end;
   end;
end;
*)

procedure TCHJournalItem.UpdateMenu(const Tag: Integer; Offset: TPoint;
  Value: TpopupMenu);
var DR : TDateRange;

begin
   inherited;
   if AccountType <> btOpeningBalances then 
   if Tag = CHPT_Processing then begin
      DR := GetSelectDateRange;
      AddMenuItem('Add Entry' ,Value.Items ,AddTransaction,DR.ToDate);
   end;
end;


{ TCHBASPeriodItem }


function TCHBASPeriodItem.CompareTagText(const Tag: integer;
  WithItem: TTreeBaseItem; SortDirection: TSortDirection): Integer;
begin
   if FMonthly then
      Result := 1
   else
      Result := -1;
   if SortDirection = sdAscending then
      Result := - Result;
end;

constructor TCHBASPeriodItem.Create(AClient: TClientObj; IsMonthly: Boolean);
begin
   inherited Create (AClient);
   FMonthly := IsMonthly;
   if FMonthly then
      Title := 'Monthly BAS'
   else
      Title := 'Quarterly BAS';
end;

function TCHBASPeriodItem.Refresh:Boolean;
var LItem : TPeriodInfo;
    I : Integer;
begin
   Result := True;
   FInfoList.Clear;
   for I := 1 to 12 do
     if not assigned(DateInfo(PEDates[I])) then begin
        //LItem := nil; // for the compiler,
        // Not covered yet...
        if fMonthly then  begin
           // Skip the Quarters
           {
           if (( GetGSTPeriod(PEDates[I],Client.clFields.clGST_Start_Month, gpQuarterly).ToDate
                <> PEDates[I]))then
           begin  }
              LItem := TPeriodInfo.Create;
              LItem.DateRange :=
                  GetGSTPeriod(PEDates[I],Client.clFields.clGST_Start_Month,gpMonthly);
           {end else
             Continue};
        end else begin
           LItem := TPeriodInfo.Create;
           LItem.DateRange :=
              GetGSTPeriod(PEDates[I],Client.clFields.clGST_Start_Month, gpQuarterly);
        end;

        CalculateGSTTotalsForPeriod(
                LItem.DateRange.FromDate,
                LItem.DateRange.ToDate,
                LItem.Info,
                -1);
           FinfoList.Add(LItem);
     end;
end;

procedure TCHBASPeriodItem.RunReturn(Sender: TObject);
   var LInfo : TPeriodInfo;
begin
   LInfo := nil;
   if assigned(Sender) then begin
      if Sender is TRzGroupItem then
         LInfo := PeriodInfo(Integer( TRzGroupItem(Sender).Data))
      else if Sender is TMenuItem then
         LInfo := PeriodInfo(TMenuItem(Sender).Tag)
   end else
      LInfo := PeriodInfo(FirstSelected);

   if Assigned(LInfo) then begin
      with  GetGSTPeriod(LInfo.DateRange.ToDate,Client.clFields.clGST_Start_Month, Client.clFields.clGST_Period) do
        if FMonthly then
          ShowBASForm ( LInfo.DateRange.FromDate, LInfo.DateRange.ToDate )
        else
          ShowBASForm ( FromDate, ToDate );

      incUsage(REPORT_LIST_NAMES[Report_BAS] + '(Home Page)');
   end;
end;

{ TCHEmptyJournal }

function TCHEmptyJournal.AccountType: Byte;
begin
   Result := FAccountType;
end;

constructor TCHEmptyJournal.Create(AClient: TClientObj; aAccountType: byte;
  ATitle: string; AGroupID: Integer);
begin
   inherited Create(AClient,nil,ATitle,AGroupID);
   MultiSelect := False;
   FAccountType := aAccountType;
end;

function TCHEmptyJournal.Refresh: Boolean;
begin
   inherited Refresh;
   Result := True;
end;

{ TPeriodInfo }

function TPeriodInfo.GetFillColor: Integer;
begin
 if HasActivity(Info) then begin
     if Info.guAllTransferred then begin
        Result :=  bkBranding.ColorFinalised;
     end else if Info.guAllLocked then begin
        Result :=  bkBranding.ColorFinalised;
     end else if Info.guHasUncodes then
        Result := bkBranding.ColorUncoded
     else
        Result :=  bkBranding.ColorCoded;
  end else begin
     Result :=  bkBranding.ColorNoData;
  end;
end;


function TPeriodInfo.GetText: string;
begin
   if HasActivity(Info) then begin
      if Info.guAllTransferred then begin
          Result := 'Transferred';
      end else if Info.guAllLocked then begin
          Result := 'Finalised';
      end else if Info.guHasUncodes then begin
          Result := 'Uncoded';
      end else
          Result := 'Coded';
   end else begin
      Result := '';
   end;
end;

function TPeriodInfo.HasAction: Boolean;
begin
   result := HasActivity(Info);
end;


{ TCHVATPeriodItem }

procedure TCHVATPeriodItem.RunReturn(Sender: TObject);
var LInfo : TPeriodInfo;
begin
   LInfo := PeriodInfo(FirstSelected);
   if Assigned(LInfo) then  begin
      ShowVATReturn( LInfo.DateRange.Fromdate, LInfo.DateRange.ToDate );
      incUsage(REPORT_LIST_NAMES[Report_VAT] + '(Home Page)');
   end;
end;

{ TCHForeignItem }

procedure TCHForeignItem.ContextCode(Sender: TObject);
var
  P: integer;
  DT: TDateTime;
begin
  for P := stFirstPeriod to stLastPeriod do
  begin
    if Selected[P] then
    begin
      DT := DateTimeFromPeriod(P);
      OpenGainLoss(P, DT);
      Break;
    end;
  end;
end;

constructor TCHForeignItem.Create(AClient: TClientObj; ATitle: string; AGroupID: Integer; MonthEndingsClass: TMonthEndingsClass);
begin
  inherited Create(AClient, ATitle, grp_Foreign);
  if not Assigned(fMonthEndings) then
    FMonthEndings := TMonthEndingsClass.Create(AClient);
  FMonthEndings.Refresh;
  FMultiSelect := False;
end;

function TCHForeignItem.GetPeriodFillColor(MonthEnding: TMonthEnding): integer;
var
  i: integer;
  ValidGainLossCode: boolean;
begin
  ValidGainLossCode := False;
  
  for i := 0 to High(MonthEnding.BankAccounts) do
  begin
    ValidGainLossCode := IsValidGainLossCode(MonthEnding.BankAccounts[i].PostedEntry.ExchangeGainLossCode);

    if ValidGainLossCode then
      break;
  end;

  if ValidGainLossCode then
  begin
    if (MonthEnding.Transferred) then
      Result := bkBranding.ColorTransferred
    else if (MonthEnding.Finalised) then
      Result := bkBranding.ColorFinalised
    else if (MonthEnding.AlreadyRun) then
      Result := bkBranding.ColorCoded
    else if (MonthEnding.NrAlreadyRun > 0) then
      Result := bkBranding.ColorUncoded // Show as uncoded if some but not all foreign accounts have gain/loss entries
    else
      Result := bkBranding.ColorNoData;
  end else
  begin
    if MonthEnding.Transferred or MonthEnding.Finalised or
    MonthEnding.AlreadyRun or MonthEnding.AvailableData then
      Result := bkBranding.ColorUncoded
    else
      Result := bkBranding.ColorNoData;
  end;
end;


procedure TCHForeignItem.AfterPaintCell(const Tag: integer; Canvas: TCanvas;
  CellRect: TRect);
var
  Period, CellPosition, CellColor, i: Integer;
  CellsFilled: array[1..12] of boolean;
  ExchangeGainOrLossPosted, LSelected: boolean;

begin
  if (tag = CHPT_Processing) then begin
    for i := Low(CellsFilled) to High(CellsFilled) do
      CellsFilled[i] := False;

    ExchangeGainOrLossPosted := False;

    for Period := 0 to FMonthEndings.Count - 1 do
    begin
      CellPosition := GetCellPosition(Period);
      if (CellPosition > 0) then
      begin
        CellColor := GetPeriodFillColor(FMonthEndings.Items[Period]);
        if (CellColor <> bkBranding.ColorNoData) then
          ExchangeGainOrLossPosted := True;
        if (CellPosition < 13) then
        begin
          CellsFilled[CellPosition] := True;
          LSelected := Selected[CellPosition];
          DrawCell(CellPosition, CellColor, GetPeriodPenColor(CellPosition), Canvas, CellRect, NodeSelected and LSelected);
        end;
      end;
    end;

    if ExchangeGainOrLossPosted then
    for i := Low(CellsFilled) to High(CellsFilled) do
      if not CellsFilled[i] then
      begin
        LSelected := Selected[i];
        DrawCell(i, bkBranding.ColorNoData, GetPeriodPenColor(i), Canvas, CellRect, NodeSelected and LSelected);
      end;
  end;
  inherited;
end;

function TCHForeignItem.HasAction(Period: Integer): Boolean;
begin
   Result := False;
end;

procedure TCHForeignItem.OnKeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_Return : OpenGainLossFromPeriod(GetSelectedPeriod);
    VK_Left:
    begin
      inherited;
    end
    else inherited;
  end;
end;

procedure TCHForeignItem.OnPaintText(const Tag: Integer; Canvas: TCanvas;
  TextType: TVSTTextType);
begin
  inherited;
  Canvas.Font.Style := [];
end;

function TCHForeignItem.SelectPeriod(const Value: Integer; Shift: TShiftstate): Boolean;
var
  PeriodNum, SelectedPeriod, i : Integer;
begin
  Result := False;
  if (Value < stFirstPeriod) or (Value > stLastPeriod) then
  begin
    for PeriodNum := stFirstPeriod to stLastPeriod do
       Selected[PeriodNum] := False;
  end else
  if (Value > stFirstPeriod) and (Value < stLastPeriod) then
  begin
    if (Value < stFirstPeriod)
    or (Value > stLastPeriod) then begin
      for PeriodNum := stFirstPeriod to stLastPeriod do
         Selected[PeriodNum] := False;

    end else begin
      if Value = stFirstPeriod then begin
         SelectedPeriod := 1
      end else if value = stLastPeriod then begin
         SelectedPeriod := 12
      end else begin
         SelectedPeriod := Value;
         Result := True;
      end;

      for PeriodNum := stFirstPeriod to stLastPeriod do
        Selected[PeriodNum] := (PeriodNum = SelectedPeriod);
    end;
  end else // Value = stFirstPeriod or stLastPeriod
  begin
    for i := stFirstPeriod to stLastPeriod do
       Selected[i] := (i = Value);
     Result := Value in [ (stFirstPeriod + 1) .. (stLastPeriod -1)];
  end;
  ParentList.Tree.InvalidateColumn(1);
end;

procedure TCHForeignItem.UpdateMenu(const Tag: Integer; Offset: TPoint; Value: TpopupMenu);
var
  Dr: TDateRange;
  Period, MonthEnding: integer;
begin
  if Tag = CHPT_Processing then
  begin
    if not (Self is TCHForeignItem) then
      Exit;

    if Assigned(ParentList) then
    begin
      DR := GetSelectDateRange;
      if DR.ToDate <= DR.FromDate then
        Exit;

      // Checking if the selected period has exchange gain/loss entries,
      // right clicking an empty cell shouldn't bring up anything
      Period := GetSelectedPeriod;
      if (Period > -1) then
      begin
        MonthEnding := GetMonthEnding(Period);
        if (MonthEnding > -1) then
        begin
          if (GetPeriodFillColor(FMonthEndings.Items[MonthEnding]) <>
          bkBranding.ColorNoData) then
            AddMenuItem('View ' + GetDateRangeS(DR),Value.Items,ContextCode,0);
        end;
      end;
    end;
  end;
end;

destructor TCHForeignItem.Destroy;
begin
  FreeAndNil(FMonthEndings);
  inherited;
end;

procedure TCHForeignItem.DoChange(const value: TVirtualNodeStates);
begin
  if vsSelected in Value then
  begin
    if toMultiselect in ParentList.Tree.TreeOptions.SelectionOptions  then
    begin
      ParentList.Tree.TreeOptions.SelectionOptions :=
        ParentList.Tree.TreeOptions.SelectionOptions - [toMultiselect];
      ParentList.Tree.Selected [Node] := True
    end;
    SelectPeriod(FirstSelected,[]);
  end;
end;

procedure TCHForeignItem.DoubleClickTag(const Tag: Integer; Offset: TPoint);
begin
   case tag of
     CHPT_Processing : OpenGainLossFromOffset(Offset.X);
   end;
end;

function TCHForeignItem.GetSelectedPeriod: integer;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to High(TCHPBaseList(ParentList).FSelection) do
  begin
    if TCHPBaseList(ParentList).FSelection[i] then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure TCHForeignItem.OpenGainLossFromOffset(OffsetX: integer);
var
  Period: integer;
begin
  Period := GetPeriod(OffsetX);
  OpenGainLossFromPeriod(Period);
end;

procedure TCHForeignItem.OpenGainLossFromPeriod(Period: integer);
var
  DT: TDateTime;
begin
  DT := DateTimeFromPeriod(Period);
  OpenGainLoss(Period, DT);
end;

procedure TCHForeignItem.OpenGainLoss(Period: integer; DT: TDateTime);
var
  Y,M,D: Word;
begin
  // Getting the end of the month
  DecodeDate(DT, Y, M, D);
  if (M = 12) then
    DT := EncodeDate(Y + 1, 1, 1) - 1
  else
    DT := EncodeDate(Y, M + 1, 1) - 1;
  RunGainLoss(Client, DT);
end;

function TCHForeignItem.GetSelectDateRange: TDateRange;
var
  P : Integer;
  Y, M, D: Word;
begin
  Result.FromDate := 0;
  Result.ToDate := 0;
  for p := 1 to 12 do
  begin
    if Selected[p] then begin
      YMDFromPeriod(P, Y, M, D);
      Result.FromDate := DateTimeToStDate(StartOfAMonth(Y, M));
      Result.ToDate := DateTimeToStDate(EndOfAMonth(Y, M));
      break;
    end;
  end;
end;

function TCHForeignItem.GetTagHint(const Tag: Integer; Offset: TPoint): string;
var
  P, MonthEnding: integer;
  PeriodDate: TDateTime;

  function GetProcessingStatus(MonthEnding: TMonthEnding): string;
  var
    i, NumValid, NumInvalid: integer;
  begin
    if (MonthEnding.Transferred) then
      Result := 'Transferred'
    else if (MonthEnding.Finalised) then
      Result := 'Finalised'
    else
    begin
      NumValid := 0;
      NumInvalid := 0;
      for i := 0 to High(MonthEnding.BankAccounts) do
        if IsValidGainLossCode(MonthEnding.BankAccounts[i].PostedEntry.ExchangeGainLossCode) then
          inc(NumValid)
        else
          inc(NumInvalid);

      if (NumInvalid > 0) then
      begin
        if (NumValid = 0) then
          Result := 'All Uncoded'
        else
        begin
          Result := 'Uncoded: ' + IntToStr(NumInvalid) + #10 +
                    'Coded: ' + IntToStr(NumValid);
        end;
      end else
      if (MonthEnding.NrAlreadyRun < Length(MonthEnding.BankAccounts)) then
        Result := 'Uncoded'
      else if (NumValid > 0) then
        Result := 'All Coded'
      else
        Result := '';
    end;
  end;

begin
  FHint := btNames[btForeign];
  if (Tag = 4) then // 3 is the tag for the Account/Name column, 4 is the tag for the column with the indicators
  begin
    P := GetPeriod(Offset.x);
    if not (P in [1..12]) then exit;
    PeriodDate := DateTimeFromPeriod(P);
    AddHint(FormatDateTime('mmm yyyy', PeriodDate));

    MonthEnding := GetMonthEnding(P);
    if (MonthEnding > -1) then
      if FMonthEndings[MonthEnding].NrAlreadyRun > 0 then
        AddHint(GetProcessingStatus(FMonthEndings[MonthEnding]));
  end;

  Result := FHint
end;

// Pass in a period, returns the position of the period in the FMonthEndings array, or -1 if it's not in there
function TCHForeignItem.GetMonthEnding(P: integer): integer;
var
  PeriodY, PeriodM, PeriodD, MonthEndingY, MonthEndingM, MonthEndingD: Word;
  i: integer;
  MonthEndingDate: TDateTime;
begin
  Result := -1;
  YMDFromPeriod(P, PeriodY, PeriodM, PeriodD);
  for i := 0 to FMonthEndings.Count - 1 do
  begin
    MonthEndingDate := FMonthEndings[i].Date;
    DecodeDate(MonthEndingDate, MonthEndingY, MonthEndingM, MonthEndingD);
    if (CompareDate(StartOfAMonth(PeriodY, PeriodM), StartOfAMonth(MonthEndingY, MonthEndingM)) = 0) then // Same month
    begin
      Result := i;
      break;
    end;
  end;
end;

function TCHForeignItem.GetCellPosition(Period: integer): integer;
var
  DateRange: TDateTime;
  RangeYear, RangeMonth, RangeDay: Word;
begin
  DateRange := StDateToDateTime(ClientHomePage.GetFillDate);
  DecodeDate(DateRange, RangeYear, RangeMonth, RangeDay);
  Result := ((FMonthEndings.Items[Period].GetYear - RangeYear) * 12) +
            FMonthEndings.Items[Period].GetMonth - RangeMonth + 12;
end;

// Fills in the 'Last Entry' field for the Exchange Gains/Losses row on the client home page
function TCHForeignItem.GetTagText(const tag: Integer): string;
var
  Y, M, i, LastMonthEnding, Period, CellPosition, CellColor: integer;
  DT: TDateTime;
  PeriodCells: array[1..12] of string;
begin
  case Tag of
     CHPT_Name,
     CHPT_Code,
     CHPT_Text : Result := Title;
     CHPT_Processing : Result := ' '; //so we get a font...
     CHPT_Report_Processing:
     begin
       // Any period which isn't in the FMonthEndings array is uncoded
       for Period := 1 to 12 do
         PeriodCells[Period] := bkBranding.TextNoData;
       for Period := 0 to FMonthEndings.Count - 1 do
       begin
         CellPosition := GetCellPosition(Period);
         if (CellPosition > 0) and (CellPosition < 13) then
         begin
           CellColor := GetPeriodFillColor(FMonthEndings.Items[Period]);
           if CellColor = bkBranding.ColorTransferred then
             PeriodCells[CellPosition] := bkBranding.TextTransferred
           else if CellColor = bkBranding.ColorFinalised then
             PeriodCells[CellPosition] := bkBranding.TextFinalised
           else if CellColor = bkBranding.ColorUncoded then
             PeriodCells[CellPosition] := bkBranding.TextUncoded
           else if CellColor = bkBranding.ColorCoded then
             PeriodCells[CellPosition] := bkBranding.TextCoded
           else if CellColor = bkBranding.ColorDownloaded then
             PeriodCells[CellPosition] := bkBranding.TextDownloaded
           else
             PeriodCells[CellPosition] := bkBranding.TextNoData;
         end;
       end;
       // Making a string out of the array elements
       Result := '';
       for Period := 1 to 12 do
         Result := Concat(Result, PeriodCells[Period]);
     end;
     CHPT_Period :
     begin
       LastMonthEnding := -1;
       for i := FMonthEndings.Count - 1 downto 0 do
       begin
         if FMonthEndings[i].AlreadyRun then
         begin
           LastMonthEnding := i;
           break;
         end;
       end;

       if (LastMonthEnding > -1) then
       begin
         Y := FMonthEndings[LastMonthEnding].Year;
         M := FMonthEndings[LastMonthEnding].Month;
         if (M = 12) then
           DT := EncodeDate(Y + 1, 1, 1) - 1
         else
           DT := EncodeDate(Y, M + 1, 1) - 1;
         Result := DateToStr(DT);
         Result := FormatDateTime('dd mmm yyyy', DT);
       end else
         Result := '';
     end;
   end;
end;

procedure TCHForeignItem.YMDFromPeriod(P: integer; var PeriodY, PeriodM, PeriodD: Word);
var
  DT: TDateTime;
  DayTable: PDayTable;
begin
  if not (P in [0..13]) then exit;
  DT := StrToDate(bkDate2Str(ClientHomePage.GetFillDate));
  DecodeDate(DT, PeriodY, PeriodM, PeriodD);
  PeriodM := PeriodM - (12 - P) + 12;
  if (PeriodM > 12) then
    dec(PeriodM, 12)
  else
    dec(PeriodY);
  DayTable := @MonthDays[IsLeapYear(PeriodY)];
  if PeriodD > DayTable^[PeriodM] then
    PeriodD := DayTable^[PeriodM]
end;

function TCHForeignItem.DateTimeFromPeriod(P: integer): TDateTime;
var
  Y, M, D: word;
begin
  YMDFromPeriod(P, Y, M, D);
  Result := EncodeDate(Y, M, D);
end;

end.