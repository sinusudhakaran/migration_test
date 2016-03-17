unit repcols;
{--------------------------------}
{
    Author   : Matthew Hopkins
    Date     : Oct 97

    Purpose  : Provides collection objects for the report columns
             : and Header Footer colection
}
{--------------------------------}

interface
uses
  Classes,
  ReportTypes,
  graphics,
  eCollect;

type
  TJustifyType = (jtLeft, jtCenter, jtRight);
  TTotalType =(ttSubSection,ttSection,ttSub,ttGrand,ttRunning,ttNone);

  TBorderStyles = (bsLeft, bsRight, bsTop, bsBottom);
  TBorderStyle = set of TBorderStyles;

  TRenderStyle = class
  public
      BackColor   : TColor;
      BorderColor : TColor;
      FontColor   : TColor;
      BorderStyle : TBorderStyle;
      constructor Create;
      procedure Assign( Source : TRenderStyle);
  end;

  TReportColumns = class;

  TReportColumn = class
  private
    FCaption          : string;
    FAlignment        : TJustifyType;
    FLeft             : longint;
    FWidth            : longInt;
    FLeftPercent      : double;
    FWidthPercent     : double;
    FStyle            : TRenderStyle;
    FFormatString     : string;
    FCanvasWidth      : integer;
    fWrappedStr       : TStringList;
    fDoWrapStr        : Boolean;

    FSubSectionTotal  : Currency;
    FSectionTotal     : currency;
    FSubTotal         : currency;
    FGrandTotal       : currency;
    FRunningTotal     : Currency;

    FTotalCol         : boolean;
    FGrandTotalCol    : boolean;
    FTotalFormat      : string;
    FColValue         : TReportColumn;
    FColQuantity      : TReportColumn;
    FCaptionLine2     : string;
    FPercentReference : Currency;
    FIsPercentageCol  : Boolean;
    FCustomFont       : TFont;

    procedure SetTotalCol(newValue :boolean);
    procedure SetFormatString(const Value: string);
    procedure SetTotalFormat(const Value: string);
    procedure SetColQuantity(const Value: TReportColumn);
    procedure SetColValue(const Value: TReportColumn);
    procedure SetCaptionLine2(const Value: string);
    procedure SetPercentReference(const Value: Currency);
    procedure SetIsPercentageCol(const Value: Boolean);
    function GetTotal(index: TTotalType): currency;
    procedure Settotal(index: TTotalType; const Value: currency);
  public
    constructor Create;
    destructor Destroy; override;

    property Caption: string read FCaption write FCaption;
    property CaptionLine2 : string read FCaptionLine2 write SetCaptionLine2;
    property Alignment: TJustifyType read FAlignment write FAlignment default jtLeft;
    property Left : longint read FLeft write FLeft;
    property Width: longint read FWidth write FWidth default 50;
    property Style: TRenderStyle read FStyle write FStyle;
    property LeftPercent: double read FLeftPercent write FLeftPercent;
    property WidthPercent : double read FWidthPercent write FWidthPercent;

    property isTotalCol : boolean read FTotalCol write SetTotalCol default false;
    property isGrandTotalCol : boolean read FGrandTotalCol write FGrandTotalCol default true;
    property SubSectionTotal : currency read FSubSectionTotal write FSubSectionTotal;
    property SectionTotal : currency read FSectionTotal write FSectionTotal;
    property SubTotal : currency read FSubTotal write FSubTotal;
    property GrandTotal :currency read FGrandTotal write FGrandTotal;
    property RunningTotal : Currency read FRunningTotal write FRunningTotal;
    property IsPercentageCol : Boolean read FIsPercentageCol write SetIsPercentageCol;
    property PercentReference : Currency read FPercentReference write SetPercentReference;
    property FormatString : string read FFormatString write SetFormatString;
    property TotalFormat : string read FTotalFormat write SetTotalFormat;

    property Total [index :TTotalType]: currency read GetTotal write Settotal;
    property ColQuantity : TReportColumn read FColQuantity write SetColQuantity;
    property ColValue : TReportColumn read FColValue write SetColValue;
    function IsAverageCol : boolean;
    property CustomFont: TFont read FCustomFont write FCustomFont;

    property CanvasWidth : integer read fCanvasWidth write fCanvasWidth;
    property WrappedStr : TStringList read fWrappedStr write fWrappedStr;
    property DoWrapStr : Boolean read fDoWrapStr write fDoWrapStr;
  end;

  TReportColumns  = class(TExtdCollection)
  private
    FWrapCaptions: Boolean;
    
    procedure SetWrapCaptions(const Value: Boolean);
  protected
     procedure FreeItem(Item : Pointer); override;
  public
    constructor Create; override;
    
    function  Report_Column_At(Index : integer): TReportColumn;
    function  TwoLines : boolean;

    property WrapCaptions: Boolean read FWrapCaptions write SetWrapCaptions;
  end;

  THeaderFooterLineType = ( hftDefault, hftCustom, hftUnwrapped, hftWrapped);

  THeaderFooterCollection = class;

  THeaderFooterLine = class (TPersistent)
  private
     FText : string;
     FFont : TFont;
     FAlignment : TJustifyType;
     FStyleAlignment : TJustifyType;
     FStyle     : TRenderStyle;
     FLineSize  : longint;
     FDoNewLine : boolean;
     FFontFactor : double;
     FAutoSize : boolean;
     FWrapTextOn: boolean;
     FLineType: THeaderFooterLineType;
     FuserLine: Boolean;
     FReportStyle: TStyleTypes;
    FBackFilled: Boolean;

     procedure SetLineSize(value : integer);
     procedure SetWrapTextOn(const Value: boolean);
     procedure SetLineType(const Value: THeaderFooterLineType);
     procedure SetUserLine(const Value: Boolean);
     procedure SetReportStyle(const Value: TStyleTypes);
     function GetAlignment: TJustifyType;
     procedure SetBackFilled(const Value: Boolean);
  public
     constructor Create;
     destructor  Destroy; override;
     procedure Assign(Source: TPersistent);override;

     property Text: string read FText write FText;
     property Font: TFont read FFont write FFont;
     property Alignment: TJustifyType read GetAlignment write FAlignment default jtCenter;
     property StyleAlignment: TJustifyType read FStyleAlignment write FStyleAlignment;
     property Style: TRenderStyle read FStyle write FStyle;
     property LineSize: longint read FLineSize write SetLineSize;
     property DoNewLine: boolean read FDoNewLine write FDoNewLine default true;
     property FontFactor : double read FFontFactor write FFontFactor;
     property AutoLineSize : boolean read FAutoSize write FAutoSize;
     property SetAutoLineSize : integer read FLineSize write FLineSize;
     property WrapTextOn : boolean read FWrapTextOn write SetWrapTextOn;
     property LineType : THeaderFooterLineType read FLineType write SetLineType;
     property UserLine: Boolean read FUserLine write SetuserLine;
     property BackFilled: Boolean read FBackFilled write SetBackFilled;
     property ReportStyle: TStyleTypes read FReportStyle write SetReportStyle;
  end;

  THeaderFooterCollection = class(TExtdCollection)
  protected
     procedure FreeItem(Item : Pointer); override;

  public
     function  HFLine_At(Index : integer): THeaderFooterLine;
     //function  GetHeight: longint;
     //property  Height: longint read GetHeight;
  end;

  function MergeStyles(ReportStyle: TStyleItem;  RenderStyle: TRenderStyle): TRenderStyle;

implementation
{----------------------------------}
uses
  globals,
  math,
  sysutils,
  windows;

function MergeStyles(ReportStyle: TStyleItem;  RenderStyle: TRenderStyle): TRenderStyle;
  function MergeColor(A, B : TColor): tColor;
   begin
      Result := RGB(max (lo(Hiword(A)), lo(Hiword(B))),
                    max (hi(Loword(A)), hi(Loword(B))),
                    max (lo(Loword(A)), lo(Loword(B))));
   end;
begin
   Result := TRenderStyle.Create;
   Result.Assign(RenderStyle);
   if RenderStyle.BackColor <> clNone then begin
      if ReportStyle.backGround <> clNone then // Colors for both...
         Result.BackColor := MergeColor(RenderStyle.BackColor,ReportStyle.backGround);
      //else .. already done..
   end else
      if ReportStyle.backGround <> clNone then
         Result.BackColor := ReportStyle.backGround;
end;



{TRenderStyle}
procedure TRenderStyle.Assign(Source: TRenderStyle);
begin
   BackColor := Source.BackColor;
   BorderColor := Source.BorderColor;
   FontColor := Source.FontColor;
   BorderStyle := Source.BorderStyle;
end;

constructor TRenderStyle.create;
begin
   inherited Create;
   BackColor   := clNone;
   BorderColor := clNone;
   FontColor   := clNone;
end;

{----------------------------------}
{TReportColumns}
{----------------------------------}
constructor TReportColumns.Create;
begin
  inherited;

  FWrapCaptions := False;
end;

procedure TReportColumns.FreeItem(Item : pointer);
begin
   TReportColumn(Item).Free;
end;

{----------------------------------}
function TReportColumns.Report_Column_At(Index : integer): TReportColumn;
var
  p : pointer;
begin
  P := At(index);
  result := P;
end;

procedure TReportColumns.SetWrapCaptions(const Value: Boolean);
begin
  FWrapCaptions := Value;
end;

{----------------------------------}
{TReportColumn}
{----------------------------------}
constructor TReportColumn.Create;
begin
  inherited Create;
  FWidth        := 50;
  FAlignment    := jtLeft;
  FStyle        := TRenderStyle.Create;
  FLeftPercent  := 0.0;
  FWidthPercent := 0.0;
  FFormatString := '';
  FTotalFormat  := '';
  FColQuantity  := nil;
  FColValue     := nil;
  FCaption      := '';
  FCaptionLine2 := '';

  FSubSectionTotal := 0;
  FSectionTotal := 0;
  FSubTotal     := 0;
  FGrandTotal   := 0;
  FRunningTotal := 0;
  FPercentReference := 0;
  FIsPercentageCol := False;
  FCustomFont := nil;
  fDoWrapStr  := false;

  fWrappedStr := TStringList.Create;
end;

{----------------------------------}
destructor TReportColumn.Destroy;
begin
  Freeandnil(fWrappedStr);

  FStyle.Free;
  inherited Destroy;
end;

function TReportColumn.GetTotal(index: TTotalType): currency;
begin
  case index of
  ttSubSection : Result := FSubSectionTotal;
  ttSection   : Result := FSectionTotal;
  ttSub       : Result := FSubTotal;
  ttGrand     : Result := FGrandTotal;
  ttRunning   : Result := FRunningTotal;
  else Result := 0;
  end;
end;

{----------------------------------}
function TReportColumn.IsAverageCol: boolean;
begin
  result := Assigned(ColQuantity) and Assigned(ColValue);
end;

procedure TReportColumn.SetCaptionLine2(const Value: string);
begin
  FCaptionLine2 := Value;
end;

procedure TReportColumn.SetColQuantity(const Value: TReportColumn);
begin
  FColQuantity := Value;
end;

procedure TReportColumn.SetColValue(const Value: TReportColumn);
begin
  FColValue := Value;
end;

procedure TReportColumn.SetFormatString(const Value: string);
begin
  FFormatString := Value;
end;

procedure TReportColumn.SetIsPercentageCol(const Value: Boolean);
begin
  FIsPercentageCol := Value;
end;

procedure TReportColumn.SetPercentReference(const Value: Currency);
begin
  FPercentReference := Value;
end;


procedure TReportColumn.Settotal(index: TTotalType; const Value: currency);
begin
  case Index of
   ttSubSection: FSubSectionTotal := Value;
   ttSection:    FSectionTotal    := Value;
   ttSub:        FSubTotal        := value;
   ttGrand:      FGrandTotal      := Value;
   ttRunning:    FRunningTotal    := Value;
  end;
end;

procedure TReportColumn.SetTotalCol(newValue : boolean);
begin
     FTotalCol     := newValue;
     FGrandTotalCol := True;     
     FSubSectionTotal := 0;
     FSectionTotal := 0;
     FSubTotal     := 0;
     FGrandTotal   := 0;
     FRunningTotal := 0;
end;        {  }

procedure TReportColumn.SetTotalFormat(const Value: string);
begin
  FTotalFormat := Value;
end;

{----------------------------------}
{THeaderFooterLine}
{----------------------------------}
procedure THeaderFooterLine.Assign(Source: TPersistent);
begin
  if Source is THeaderFooterLine then begin

  FFont.Assign(THeaderFooterLine(Source).Font);
  FAlignment := THeaderFooterLine(Source).Alignment;
  FStyleAlignment := THeaderFooterLine(Source).StyleAlignment;
  FStyle.Assign(THeaderFooterLine(Source).Style);
  FDoNewLine := THeaderFooterLine(Source).DoNewLine;
  FFontFactor := THeaderFooterLine(Source).FontFactor;
  FAutoSize := THeaderFooterLine(Source).AutoLineSize;
  FLineSize := THeaderFooterLine(Source).LineSize;
  FWrapTextOn := THeaderFooterLine(Source).WrapTextOn;
  FText := THeaderFooterLine(Source).Text;
  FUserLine := THeaderFooterLine(Source).Userline;
  FBackFilled := THeaderFooterLine(Source).BackFilled;
  end;
end;

constructor THeaderFooterLine.Create;
begin
  inherited Create;
  FStyle := TRenderStyle.Create;
  FFont := TFont.Create;
  FFontFactor := 0;
  FAutoSize := true;
  FWrapTextOn := false;
  FLineType := hftDefault;
  FReportStyle := siSubTitle;
  FAlignment := jtCenter;
  FStyleAlignment := jtCenter;
end;

{----------------------------------}
destructor THeaderFooterLine.Destroy;
begin
   FStyle.Free;
   FFont.Free;
   inherited Destroy;
end;

function THeaderFooterLine.GetAlignment: TJustifyType;
begin
  if FAlignment = jtCenter then
     Result := FStyleAlignment
  else
     Result := FAlignment;
end;

{----------------------------------}
{THeaderFooterCollection}
{----------------------------------}
      (*
function THeaderFooterCollection.GetHeight : longint;
var
   i :integer;
begin
  result := 0;
  for i := 0 to Pred(ItemCount)  do        { Iterate }
  begin
    if HFLine_At(i).LineType <> hftUnWrapped then
      result := result + HFLine_At(i).LineSize;
  end;
end;
        *)
{----------------------------------}
procedure THeaderFooterCollection.FreeItem(Item : pointer);
begin
  THeaderFooterLine(Item).Free;
end;

{-----------------------------------}
function THeaderFooterCollection.HFLine_At(Index : integer): THeaderFooterLine;
var
  p : pointer;
begin
  P := At(index);
  result := P;
end;

procedure THeaderFooterLine.SetUserLine(const Value: Boolean);
begin
  FUserLine := Value;
end;

procedure THeaderFooterLine.SetBackFilled(const Value: Boolean);
begin
  FBackFilled := Value;
  if FBackFilled then
     FStyle.BackColor := clNone;
end;

procedure THeaderFooterLine.SetLineSize(value: integer);
begin
   FLineSize := value;
   FAutoSize := false;
end;
{----------------------------------}
function TReportColumns.TwoLines: boolean;
var i :integer;
begin
   result := false;
   for i := 0 to Pred(ItemCount) do
     if Report_Column_At(i).FCaptionLine2 <> '' then
     begin
        result := true;
        break;
     end;
end;

procedure THeaderFooterLine.SetLineType(const Value: THeaderFooterLineType);
begin
  FLineType := Value;
end;

procedure THeaderFooterLine.SetReportStyle(const Value: TStyleTypes);
begin
  FReportStyle := Value;
end;

procedure THeaderFooterLine.SetWrapTextOn(const Value: boolean);
begin
  FWrapTextOn := Value;
end;

end.
