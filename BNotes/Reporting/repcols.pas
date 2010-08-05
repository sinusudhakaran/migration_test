unit repcols;
{--------------------------------}
{
    Author   : Matthew Hopkins
    Date     : Oct 97

    Purpose  : Provides collection objects for the report columns
}
{--------------------------------}

interface
uses
  classes, graphics, eCollect;

type
  TJustifyType = (jtLeft, jtCenter, jtRight);

  TRenderStyle = class
  public
      BackColor   : TColor;
      BorderColor : TColor;
      FontColor   : TColor;
      constructor Create;
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
    FSectionTotal     : currency;
    FSubTotal         : currency;
    FGrandTotal       : currency;
    FTotalCol         : boolean;
    FTotalFormat      : string;
    FColValue: TReportColumn;
    FColQuantity: TReportColumn;
    FCaptionLine2: string;

    procedure SetTotalCol(newValue :boolean);
    procedure SetFormatString(const Value: string);
    procedure SetTotalFormat(const Value: string);
    procedure SetColQuantity(const Value: TReportColumn);
    procedure SetColValue(const Value: TReportColumn);
    procedure SetCaptionLine2(const Value: string);
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
    property SectionTotal : currency read FSectionTotal write FSectionTotal;
    property SubTotal : currency read FSubTotal write FSubTotal;
    property GrandTotal :currency read FGrandTotal write FGrandTotal;

    property FormatString : string read FFormatString write SetFormatString;
    property TotalFormat : string read FTotalFormat write SetTotalFormat;

    property ColQuantity : TReportColumn read FColQuantity write SetColQuantity;
    property ColValue    : TReportColumn read FColValue write SetColValue;
    function IsAverageCol : boolean;
  end;

  TReportColumns  = class(TExtdCollection)
  protected
     procedure FreeItem(Item : Pointer); override;
  public
     function  Report_Column_At(Index : integer): TReportColumn;
     function  TwoLines : boolean;
  end;

  THeaderFooterCollection = class;

  THeaderFooterLine = class
  private
     FText : string;
     FFont : TFont;
     FAlignment : TJustifyType;
     FStyle     : TRenderStyle;
     FLineSize  : longint;
     FDoNewLine : boolean;
     FFontFactor : double;
     FAutoSize : boolean;

     procedure SetLineSize(value : integer);
  public
     constructor Create;
     destructor  Destroy; override;

     property Text: string read FText write FText;
     property Font: TFont read FFont write FFont;
     property Alignment: TJustifyType read FAlignment write FAlignment default jtCenter;
     property Style: TRenderStyle read FStyle write FStyle;
     property LineSize: longint read FLineSize write SetLineSize;
     property DoNewLine: boolean read FDoNewLine write FDoNewLine default true;
     property FontFactor : double read FFontFactor write FFontFactor;
     property AutoLineSize : boolean read FAutoSize write FAutoSize;
     property SetAutoLineSize : integer read FLineSize write FLineSize;
  end;

  THeaderFooterCollection = class(TExtdCollection)
  protected
     procedure FreeItem(Item : Pointer); override;
     function  GetHeight : longint;
  public
     function  HFLine_At(Index : integer): THeaderFooterLine;
     property  Height : longint read GetHeight;
  end;


implementation
{----------------------------------}
//uses
{TRenderStyle}
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

  FSectionTotal := 0;
  FSubTotal     := 0;
  FGrandTotal   := 0;
end;

{----------------------------------}
destructor TReportColumn.Destroy;
begin
  FStyle.Free;
  inherited Destroy;
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

procedure TReportColumn.SetTotalCol(newValue : boolean);
begin
     FTotalCol     := newValue;
     FSectionTotal := 0;
     FSubTotal     := 0;
     FGrandTotal   := 0;
end;        {  }

procedure TReportColumn.SetTotalFormat(const Value: string);
begin
  FTotalFormat := Value;
end;

{----------------------------------}
{THeaderFooterLine}
{----------------------------------}
constructor THeaderFooterLine.Create;
begin
  inherited Create;
  FStyle := TRenderStyle.Create;
  FFont := TFont.Create;
  FFontFactor := 0;
  FAutoSize := true;
end;

{----------------------------------}
destructor THeaderFooterLine.Destroy;
begin
   FStyle.Free;
   FFont.Free;
   inherited Destroy;
end;

{----------------------------------}
{THeaderFooterCollection}
{----------------------------------}

function THeaderFooterCollection.GetHeight : longint;
var
   i :integer;
begin
   result := 0;
   for i := 0 to Pred(ItemCount)  do        { Iterate }
          result := result + HFLine_At(i).LineSize;
end;

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

end.
