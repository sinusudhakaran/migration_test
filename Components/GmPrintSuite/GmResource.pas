{******************************************************************************}
{                                                                              }
{                              GmResource.pas                                  }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmResource;

interface

{$I GMPS.INC}

uses Windows, SyncObjs, Forms, Classes, Graphics, GmTypes,
  {$IFDEF D5+}
  contnrs,
  {$ENDIF}
  StdCtrls;

type
  TGmNeedRichEditEvent     = procedure(Sender: TObject; var ARichEdit: TCustomMemo) of object;

  // *** TGmObjectList ***

  {$IFDEF D5+}
  TGmObjectList = TObjectList;
  {$ELSE}
  TGmObjectList = class(TObject)
  private
    FList: TList;
    function GetCount: integer;
    function GetItem(index: integer): TObject;
    procedure SetItem(index: integer; AObject: TObject);
  public
    constructor Create(const OwnsObjects: Boolean = True);
    destructor Destroy; override;
    function Extract(AObject: TObject): TObject;
    function IndexOf(AObject: TObject): integer;
    procedure Add(AObject: TObject);
    procedure Clear;
    procedure Delete(index: integer);
    procedure Insert(Index: integer; AObject: TObject);
    property Count: integer read GetCount;
    property Items[index: integer]: TObject read GetItem write SetItem; default;
  end;
  {$ENDIF}

  // *** TGmReferenceList ***

  TGmReferenceList = class(TStringList)
  private
    function GetValue(index: integer): integer;
    procedure SetValue(index: integer; Value: integer);
  public
    procedure AddValue(Value: integer);
    procedure DecValueAtIndex(index: integer);
    procedure IncValueAtIndex(index: integer);
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    property Value[index: integer]: integer read GetValue write SetValue; default;
  end;

  //----------------------------------------------------------------------------

  // *** TGmResourceList ***

  TGmResourceList = class(TGmObjectList)
  private
    FReferenceList: TGmReferenceList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure DeleteResource(AResource: TObject);
    procedure LoadFromStream(Stream: TStream); virtual; abstract;
    procedure SaveToStream(Stream: TStream); virtual; abstract;
    property ReferenceList: TGmReferenceList read FReferenceList;
  end;

  //----------------------------------------------------------------------------

  // *** TGmBrush ***

  TGmBrush = class(TPersistent)
  private
    FColor: TColor;
    FStyle: TBrushStyle;
    // events...
    FOnChange: TNotifyEvent;
    procedure Changed;
    procedure SetColor(const Value: TColor);
    procedure SetStyle(const Value: TBrushStyle);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure AssignToCanvas(ACanvas: TCanvas);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property Color: TColor read FColor write SetColor default clWhite;
    property Style: TBrushStyle read FStyle write SetStyle default bsClear;
    // events...
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  //----------------------------------------------------------------------------

  // *** TGmBrushList ***

  TGmBrushList = class(TGmResourceList)
  private
    function GetBrush(index: integer): TGmBrush;
    procedure SetBrush(index: integer; ABrush: TGmBrush);
  public
    function AddBrush(ABrush: TGmBrush): TGmBrush;
    function IndexOf(ABrush: TGmBrush): integer;
    //procedure DeleteBrush(ABrush: TGmBrush);
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    property Brush[index: integer]: TGmBrush read GetBrush write SetBrush; default;
  end;

  //----------------------------------------------------------------------------

  // *** TGmFont ***

  TGmFont = class(TPersistent)
  private
    FSize: integer;
    FStyle: TFontStyles;
    FAngle: Extended;
    FColor: TColor;
    FCharset: TFontCharset;
    FName: string;
    // events...
    FOnChange: TNotifyEvent;
    procedure Changed;
    procedure SetSize(Value: integer);
    procedure SetStyle(Value: TFontStyles);
    procedure SetAngle(Value: Extended);
    procedure SetColor(Value: TColor);
    procedure SetCharset(Value: TFontCharset);
    procedure SetName(Value: string);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure AssignToCanvas(ACanvas: TCanvas);
    procedure AssignToFont(AFont: TFont);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property Size: integer read FSize write SetSize default 12;
    property Style: TFontStyles read FStyle write SetStyle default [];
    property Angle: Extended read FAngle write SetAngle;
    property Color: TColor read FColor write SetColor default clBlack;
    property Charset: TFontCharset read FCharset write SetCharset default DEFAULT_CHARSET;
    property Name: string read FName write SetName;
    // events...
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  //----------------------------------------------------------------------------

  // *** TGmFontList ***

  TGmFontList = class(TGmResourceList)
  private
    function GetFont(index: integer): TGmFont;
    procedure SetFont(index: integer; AFont: TGmFont);
  public
    function AddFont(AFont: TGmFont): TGmFont;
    function IndexOf(AFont: TGmFont): integer;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    property Font[index: integer]: TGmFont read GetFont write SetFont; default;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPen ***

  TGmPen = class(TPersistent)
  private
    FWidth: integer;
    FColor: TColor;
    FStyle: TPenStyle;
    FMode: TPenMode;
    // events...
    FOnChange: TNotifyEvent;
    procedure Changed;
    procedure SetColor(Value: TColor);
    procedure SetMode(Value: TPenMode);
    procedure SetStyle(Value: TPenStyle);
    procedure SetWidth(Value: integer);
  public
    procedure Assign(Source: TPersistent); override;
    procedure AssignToCanvas(Canvas: TCanvas; Ppi: integer);
    procedure AssignToPen(APen: TPen);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property Color: TColor read FColor write SetColor default clBlack;
    property Mode: TPenMode read FMode write SetMode default pmCopy;
    property Style: TPenStyle read FStyle write SetStyle default psSolid;
    property Width: integer read FWidth write SetWidth;
    // events...
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPenList ***

  TGmPenList = class(TGmResourceList)
  private
    function GetPen(index: integer): TGmPen;
    procedure SetPen(index: integer; APen: TGmPen);
  public
    function AddPen(APen: TGmPen): TGmPen;
    function IndexOf(APen: TGmPen): integer;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    property Pen[index: integer]: TGmPen read GetPen write SetPen; default;
  end;

  //----------------------------------------------------------------------------

  
  // *** TGmGraphicList ***

  TGmGraphicList = class(TGmResourceList)
  private
    FGraphicCompare: Boolean;
    function GetGraphic(index: integer): TGraphic;
    function GetGraphicType(AGraphic: TGraphic): TGmGraphicType;
    procedure SetGraphic(index: integer; Graphic: TGraphic);
  public
    constructor Create; override;
    function AddGraphic(AGraphic: TGraphic): TGraphic;
    function IndexOf(AGraphic: TGraphic): integer;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    property GraphicCompare: Boolean read FGraphicCompare write FGraphicCompare default True;
    property Graphic[index: integer]: TGraphic read GetGraphic write SetGraphic;
  end;

  //----------------------------------------------------------------------------

  // *** TGmCustomMemoList ***

  TGmCustomMemoList = class(TGmResourceList)
  private
    FParentForm: TForm;
    // events...
    FNeedRichEdit: TGmNeedRichEditEvent;
    function GetMemo(index: integer): TCustomMemo;
    function GetMemoType(AMemo: TCustomMemo): TGmMemoType;
    procedure SetMemo(index: integer; AMemo: TCustomMemo);
  public
    constructor Create; override;
    destructor Destroy; override;
    function AddMemo(AMemo: TCustomMemo): TCustomMemo;
    function CreateMemo: TCustomMemo;
    function IndexOf(AMemo: TCustomMemo): integer;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    property Memo[index: integer]: TCustomMemo read GetMemo write SetMemo;
    // events...
    property OnNeedRichEdit: TGmNeedRichEditEvent read FNeedRichEdit write FNeedRichEdit;
  end;

  //----------------------------------------------------------------------------

  // *** TGmResourceTable ***

  TGmResourceTable = class(TPersistent)
  private
    FBrushList: TGmBrushList;
    FCustomMemoList: TGmCustomMemoList;
    FFontList: TGmFontList;
    FPenList: TGmPenList;
    FGraphicList: TGmGraphicList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property BrushList: TGmBrushList read FBrushList;
    property CustomMemoList: TGmCustomMemoList read FCustomMemoList;
    property FontList: TGmFontList read FFontList;
    property PenList: TGmPenList read FPenList;
    property GraphicList: TGmGraphicList read FGraphicList;
  end;

  TGmFontMapper = class
  private
    FRenderBitmap: TBitmap;
    FCharSpacing: array of integer;
    FCalcPpi: integer;
    FDestPpi: integer;
    FWrapText: Boolean;
    procedure GmDrawText(ACanvas: TCanvas; X, Y: integer; ARect: PRect; AText: string; const Spacing: array of integer);
    procedure CalculateCharSpacing(ACanvas: TCanvas; AText: string);
  public
    constructor Create;
    destructor Destroy; override;
    function TextExtent(ACanvas: TCanvas; AText: string): TGmSize;
    function TextHeight(ACanvas: TCanvas; AText: string): Extended;
    function TextWidth(ACanvas: TCanvas; AText: string): Extended;
    function TextBox(ACanvas: TCanvas; ARect: TRect; AText: string; Alignment: TAlignment; const AFastDraw: Boolean = False): Extended;
    function TextBoxHeight(AFont: TFont; ARect: TRect; AText: string): Extended;
    procedure TextOut(ACanvas: TCanvas; X, Y: integer; ARect: PRect; AText: string; const AFastDraw: Boolean = False);
    property WrapText: Boolean read FWrapText write FWrapText default True;
  end;

var
  GmFontMapper: TGmFontMapper;

  function PenToString(APen: TPen): string;
  procedure PenFromString(APen: TPen; AString: string);

implementation

uses SysUtils, GmConst, GmStream, GmFuncs, JPeg, GmRtfFuncs, ComCtrls;

//------------------------------------------------------------------------------

function PenToString(APen: TPen): string;
var
  AValues: TStringList;
begin
  AValues := TStringList.Create;
  try
    AValues.Add(IntToStr(APen.Color));
    AValues.Add(IntToStr(APen.Width));
    AValues.Add(IntToStr(Ord(APen.Style)));
    AValues.Add(IntToStr(Ord(APen.Mode)));
    Result := AValues.CommaText;
  finally
    AValues.Free;
  end;
end;

procedure PenFromString(APen: TPen; AString: string);
var
  AValues: TStringList;
begin
  AValues := TStringList.Create;
  try
    AValues.CommaText := AString;
    APen.Color := StrToInt(AValues[0]);
    APen.Width := StrToInt(AValues[1]);
    APen.Style := TPenStyle(StrToInt(AValues[2]));
    APen.Mode  := TPenMode(StrToInt(AValues[3]));
  finally
    AValues.Free;
  end;
end;

function CompareBrushes(Brush1, Brush2: TGmBrush): Boolean;
begin
  Result := (Brush1.Color = Brush2.Color) and (Brush1.Style = Brush2.Style);
end;

function CompareFonts(Font1, Font2: TGmFont): Boolean;
begin
  Result := (Font1.Name = Font2.Name) and
            (Font1.Size = Font2.Size) and
            (Font1.Charset = Font2.Charset) and
            (Font1.Angle = Font2.Angle) and
            (Font1.Color = Font2.Color) and
            (Font1.Style = Font2.Style);
end;

function ComparePens(Pen1, Pen2: TGmPen): Boolean;
begin
  Result := (Pen1.Color = Pen2.Color) and
            (Pen1.Mode = Pen2.Mode) and
            (Pen1.Style = Pen2.Style) and
            (Pen1.Width = Pen2.Width)
end;

function CompareGraphics(Graphic1, Graphic2: TGraphic): Boolean;
var
  Stream1,
  Stream2: TMemoryStream;
begin
  Result := False;
  if (Graphic1.Height <> Graphic2.Height) or
     (Graphic1.Width <> Graphic2.Width) then Exit;
  Stream1 := TMemoryStream.Create;
  Stream2 := TMemoryStream.Create;
  try
    Stream1.Clear;
    Stream2.Clear;
    Graphic1.SaveToStream(Stream1);
    Graphic2.SaveToStream(Stream2);
    if Stream1.Size <> Stream2.Size then Exit;
    Result := CompareMem(Stream1.Memory, Stream2.Memory, Stream1.Size);
  finally
    Stream1.Free;
    Stream2.Free;
  end;
end;

//------------------------------------------------------------------------------

{$IFDEF DELPHI4}

// A class which owns the objects it contains similar to the D5+ TObjectList class
// needed for D4 compatability... 

// *** TGmObjectList ***

constructor TGmObjectList.Create(const OwnsObjects: Boolean = True);
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TGmObjectList.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

function TGmObjectList.Extract(AObject: TObject): TObject;
var
  ObjectIndex: integer;
begin
  Result := nil;
  ObjectIndex := IndexOf(AObject);
  if ObjectIndex = -1 then Exit;
  Result := Items[ObjectIndex];
  FList.Delete(ObjectIndex);
end;

function TGmObjectList.IndexOf(AObject: TObject): integer;
begin
  Result := FList.IndexOf(AObject);
end;

function TGmObjectList.GetCount: integer;
begin
  Result := FList.Count;
end;

function TGmObjectList.GetItem(index: integer): TObject;
begin
  Result := FList[index];
end;

procedure TGmObjectList.SetItem(index: integer; AObject: TObject);
begin
  FList[index] := AObject;
end;

procedure TGmObjectList.Add(AObject: TObject);
begin
  FList.Add(AObject);
end;


procedure TGmObjectList.Clear;
var
  ICount: integer;
begin
  for ICount := FList.Count-1 downto 0 do
  begin
    Delete(ICount);
  end;
end;

procedure TGmObjectList.Delete(index: integer);
var
  AObject: TObject;
begin
  AObject := FList.Items[index];
  AObject.Free;
  FList.Delete(index);
end;

procedure TGmObjectList.Insert(Index: integer; AObject: TObject);
begin
  FList.Insert(Index, AObject);
end;

{$ENDIF}

//------------------------------------------------------------------------------
// *** TGmReferenceList ***

procedure TGmReferenceList.AddValue(Value: integer);
begin
  Add(IntToStr(Value));
end;

procedure TGmReferenceList.DecValueAtIndex(index: integer);
begin
  Value[index] := Value[index] - 1;
end;

procedure TGmReferenceList.IncValueAtIndex(index: integer);
begin
  Value[index] := Value[index] + 1;
end;

procedure TGmReferenceList.LoadFromStream(Stream: TStream);
var
  ICount: integer;
  NumValues: integer;
  Values: TGmValueList;
begin
  Values := TGmValueList.Create;
  try
    NumValues := Values.ReadIntValue(C_RC, 0);
    for ICount := 1 to NumValues do
      AddValue(Values.ReadIntValue(C_RN+IntToStr(ICount), 0));
  finally
    Values.Free;
  end;
end;

procedure TGmReferenceList.SaveToStream(Stream: TStream);
var
  Values: TGmValueList;
  ICount: integer;
begin
  Values := TGmValueList.Create;
  try
    Values.WriteIntValue(C_RC, Count);
    for ICount := 1 to Count do
      Values.WriteIntValue(C_RN+IntToStr(ICount), Value[ICount-1]);
  finally
    Values.Free;
  end;
end;

function TGmReferenceList.GetValue(index: integer): integer;
begin
  Result := StrToInt(Strings[index]);
end;

procedure TGmReferenceList.SetValue(index: integer; Value: integer);
begin
  Strings[index] := IntToStr(Value);
end;

//------------------------------------------------------------------------------

constructor TGmResourceList.Create;
begin
  inherited Create(True);
  FReferenceList := TGmReferenceList.Create;
end;

destructor TGmResourceList.Destroy;
begin
  FReferenceList.Free;
  inherited Destroy;
end;

procedure TGmResourceList.DeleteResource(AResource: TObject);
var
  Index: integer;
begin
  Index := IndexOf(AResource);
  if Index = -1 then Exit;
  if ReferenceList[Index] = 1 then
  begin
    ReferenceList.Delete(Index);
    Delete(Index);
  end
  else
    ReferenceList.DecValueAtIndex(Index);
end;

//------------------------------------------------------------------------------

// *** TGmBrush ***

constructor TGmBrush.Create;
begin
  inherited Create;
  FColor := clWhite;
  FStyle := bsClear;
end;

procedure TGmBrush.Assign(Source: TPersistent);
begin
  if not Assigned(Source) then Exit;
  if (Source is TGmBrush) then
  begin
    FColor := (Source as TGmBrush).Color;
    FStyle := (Source as TGmBrush).Style;
    Changed;
  end
  else
  if (Source is TBrush) then
  begin
    FColor := (Source as TBrush).Color;
    FStyle := (Source as TBrush).Style;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure TGmBrush.AssignToCanvas(ACanvas: TCanvas);
var
  ABrush: TBrush;
begin
  ABrush := TBrush.Create;
  try
    ABrush.Color := FColor;
    if ABrush.Color = clNone then
      ABrush.Style := bsClear
    else
      ABrush.Style := FStyle;
    ACanvas.Brush.Assign(ABrush);
  finally
    ABrush.Free;
  end;
end;

procedure TGmBrush.LoadFromStream(Stream: TStream);
var
  AValues: TGmValueList;
begin
  AValues := TGmValueList.Create;
  try
    AValues.LoadFromStream(Stream);
    FColor := AValues.ReadIntValue(C_CL, clWhite);
    FStyle := TBrushStyle(AValues.ReadIntValue(C_ST, 0));
  finally
    AValues.Free;
  end;
end;

procedure TGmBrush.SaveToStream(Stream: TStream);
var
  AValues: TGmValueList;
begin
  AValues := TGmValueList.Create;
  try
    AValues.WriteIntValue(C_CL, FColor);
    AValues.WriteIntValue(C_ST, Ord(FStyle));
    AValues.SaveToStream(Stream);
  finally
    AValues.Free;
  end;
end;

procedure TGmBrush.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TGmBrush.SetColor(const Value: TColor);
begin
  if FColor = Value then Exit;
  FColor := Value;
  FStyle := bsSolid;
  Changed;
end;

procedure TGmBrush.SetStyle(const Value: TBrushStyle);
begin
  if FStyle = Value then Exit;
  FStyle := Value;
  Changed;
end;

//------------------------------------------------------------------------------

// *** TGmBrushList ***

function TGmBrushList.GetBrush(index: integer): TGmBrush;
begin
  if index = -1 then
  begin
    Result := nil;
    Exit;
  end;
  Result := TGmBrush(Items[index]);
end;

procedure TGmBrushList.SetBrush(index: integer; ABrush: TGmBrush);
begin
  Items[index] := ABrush;
end;

function TGmBrushList.AddBrush(ABrush: TGmBrush): TGmBrush;
var
  NewBrush: TGmBrush;
  Index: integer;
begin
  Index := IndexOf(ABrush);
  if Index > -1 then
  begin
    Result := Self[Index];
    ReferenceList.IncValueAtIndex(Index);
    Exit;
  end;
  NewBrush := TGmBrush.Create;
  NewBrush.Assign(ABrush);
  Add(NewBrush);
  ReferenceList.AddValue(1);
  Result := NewBrush;
end;

function TGmBrushList.IndexOf(ABrush: TGmBrush): integer;
var
  ICount: integer;
  CompareBrush: TGmBrush;
begin
  Result := -1;
  for ICount := 0 to Count-1 do
  begin
    CompareBrush := Self[ICount];
    if CompareBrushes(CompareBrush, ABrush) then
    begin
      Result := ICount;
      Exit;
    end;
  end;
end;

procedure TGmBrushList.LoadFromStream(Stream: TStream);
var
  ICount,
  NumBrushes: integer;
  ABrush: TGmBrush;
begin
  Clear;
  Stream.ReadBuffer(NumBrushes, SizeOf(NumBrushes));
  ABrush := TGmBrush.Create;
  try
    for ICount := 1 to NumBrushes do
    begin
      ABrush.LoadFromStream(Stream);
      AddBrush(ABrush);
    end;
  finally
    ABrush.Free;
  end;
  FReferenceList.LoadFromStream(Stream);
end;

procedure TGmBrushList.SaveToStream(Stream: TStream);
var
  ICount,
  NumBrushes: integer;
begin
  NumBrushes := Count;
  Stream.WriteBuffer(NumBrushes, SizeOf(NumBrushes));
  for ICount := 0 to NumBrushes-1 do
    Brush[ICount].SaveToStream(Stream);
  FReferenceList.SaveToStream(Stream);
end;

//------------------------------------------------------------------------------

// *** TGmFont ***

constructor TGmFont.Create;
begin
  inherited Create;
  FSize := 12;
  FStyle := [];
  FCharset := DEFAULT_CHARSET;
  FAngle := 0;
  FColor := clBlack;
end;

procedure TGmFont.Assign(Source: TPersistent);
begin
  if (Source is TFont) then
  begin
    FSize     := (Source as TFont).Size;
    FColor    := (Source as TFont).Color;
    FCharset  := (Source as TFont).Charset;
    FName     := (Source as TFont).Name;
    FStyle    := (Source as TFont).Style;
    FAngle    := 0;
  end
  else
  if (Source is TGmFont) then
  begin
    FSize     := (Source as TGmFont).Size;
    FColor    := (Source as TGmFont).Color;
    FCharset  := (Source as TGmFont).Charset;
    FName     := (Source as TGmFont).Name;
    FStyle    := (Source as TGmFont).Style;
    FAngle    := (Source as TGmFont).Angle;
  end
  else
    inherited Assign(Source);
end;

procedure TGmFont.AssignToCanvas(ACanvas: TCanvas);
begin
  AssignToFont(ACanvas.Font);
end;

procedure TGmFont.AssignToFont(AFont: TFont);
var
  logFont : TLogFont;
begin
  AFont.Color := FColor;
  AFont.Size := FSize;
  AFont.Name := FName;
  AFont.Charset := FCharset;
  AFont.Style := FStyle;
  if FAngle <> 0 then
  begin
    GetObject(AFont.Handle, sizeof(logFont), @logFont);
    logFont.lfEscapement := Round(FAngle * 10);
    logFont.lfOrientation := Round(FAngle * 10);
    AFont.Handle := CreateFontIndirect(logFont);
  end;
end;

procedure TGmFont.LoadFromStream(Stream: TStream);
var
  AValues: TGmValueList;
begin
  AValues := TGmValueList.Create;
  try
    AValues.LoadFromStream(Stream);
    FColor   := AValues.ReadIntValue(C_CL, clWhite);
    FStyle   := FontStyleFromString(AValues.ReadStringValue(C_ST, ''));
    FName    := AValues.ReadStringValue(C_FN, DEFAULT_FONT);
    FSize    := AValues.ReadIntValue(C_SZ, DEFAULT_FONT_SIZE);
    FAngle   := AValues.ReadExtValue(C_FA, 0);
    FCharset := AValues.ReadIntValue(C_CS, DEFAULT_CHARSET);
  finally
    AValues.Free;
  end;
end;

procedure TGmFont.SaveToStream(Stream: TStream);
var
  AValues: TGmValueList;
begin
  AValues := TGmValueList.Create;
  try
    AValues.WriteIntValue(C_CL, FColor);
    AValues.WriteStringValue(C_ST, FontStyleToString(FStyle));
    AValues.WriteExtValue(C_FA, FAngle);
    AValues.WriteIntValue(C_SZ, FSize);
    AValues.WriteIntValue(C_CS, Ord(FCharset));
    AValues.WriteStringValue(C_FN, FName);
    AValues.SaveToStream(Stream);
  finally
    AValues.Free;
  end;
end;

procedure TGmFont.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TGmFont.SetSize(Value: integer);
begin
  if FSize = Value then Exit;
  FSize := Value;
  Changed;
end;

procedure TGmFont.SetStyle(Value: TFontStyles);
begin
  if FStyle = Value then Exit;
  FStyle := Value;
  Changed;
end;

procedure TGmFont.SetAngle(Value: Extended);
begin
  if FAngle = Value then Exit;
  FAngle := Value;
  Changed;
end;

procedure TGmFont.SetColor(Value: TColor);
begin
  if FColor = Value then Exit;
  FColor := Value;
  Changed;
end;

procedure TGmFont.SetCharset(Value: TFontCharset);
begin
  if FCharset = Value then Exit;
  FCharset := Value;
  Changed;
end;

procedure TGmFont.SetName(Value: string);
begin
  if FName = Value then Exit;
  FName := Value;
  Changed;
end;

//------------------------------------------------------------------------------

// *** TGmFontList ***

function TGmFontList.AddFont(AFont: TGmFont): TGmFont;
var
  NewFont: TGmFont;
  Index: integer;
begin
  Index := IndexOf(AFont);
  if Index > -1 then
  begin
    Result := Self[Index];
    ReferenceList.IncValueAtIndex(Index);
    Exit;
  end;
  NewFont := TGmFont.Create;
  NewFont.Assign(AFont);
  Add(NewFont);
  ReferenceList.AddValue(1);
  Result := NewFont;
end;

procedure TGmFontList.LoadFromStream(Stream: TStream);
var
  ICount,
  NumFonts: integer;
  AFont: TGmFont;
begin
  Clear;
  Stream.ReadBuffer(NumFonts, SizeOf(NumFonts));
  AFont := TGmFont.Create;
  try
    for ICount := 1 to NumFonts do
    begin
      AFont.LoadFromStream(Stream);
      AddFont(AFont);
    end;
  finally
    AFont.Free;
  end;
  FReferenceList.LoadFromStream(Stream);
end;

procedure TGmFontList.SaveToStream(Stream: TStream);
var
  ICount,
  NumFonts: integer;
begin
  NumFonts := Count;
  Stream.WriteBuffer(NumFonts, SizeOf(NumFonts));
  for ICount := 0 to NumFonts-1 do
    Font[ICount].SaveToStream(Stream);
  FReferenceList.SaveToStream(Stream);
end;

function TGmFontList.GetFont(index: integer): TGmFont;
begin
  Result := TGmFont(Items[index]);
end;

procedure TGmFontList.SetFont(index: integer; AFont: TGmFont);
begin
  Items[index] := AFont;
end;

function TGmFontList.IndexOf(AFont: TGmFont): integer;
var
  ICount: integer;
  CompareFont: TGmFont;
begin
  Result := -1;
  for ICount := 0 to Count-1 do
  begin
    CompareFont := Self[ICount];
    if CompareFonts(CompareFont, AFont) then
    begin
      Result := ICount;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------

// *** TGmPen ***

procedure TGmPen.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TGmPen.SetColor(Value: TColor);
begin
  if FColor = Value then Exit;
  FColor := Value;
  Changed;
end;

procedure TGmPen.SetMode(Value: TPenMode);
begin
  if FMode = Value then Exit;
  FMode := Value;
  Changed;
end;

procedure TGmPen.SetStyle(Value: TPenStyle);
begin
  if FStyle = Value then Exit;
  FStyle := Value;
  Changed;
end;

procedure TGmPen.SetWidth(Value: integer);
begin
  if FWidth = Value then Exit;
  FWidth := Value;
  Changed;
end;

procedure TGmPen.Assign(Source: TPersistent);
begin
  if (Source is TGmPen) then
  begin
    FWidth := TGmPen(Source).Width;
    FColor := TGmPen(Source).Color;
    FStyle := TGmPen(Source).Style;
    FMode  := TGmPen(Source).Mode;
    Changed;
  end
  else
  if (Source is TPen) then
  begin
    FWidth := TPen(Source).Width;
    FColor := TPen(Source).Color;
    FStyle := TPen(Source).Style;
    FMode  := TPen(Source).Mode;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure TGmPen.AssignToCanvas(Canvas: TCanvas; Ppi: integer);
var
  OnePt: Extended;
  LineStyle: Byte;
  AWidth: integer;
  APenStyle: Cardinal;
  lb: TLogBrush;
begin
  OnePt := Ppi / 72;
  Canvas.Pen.Color := FColor;
  Canvas.Pen.Style := FStyle;
  Canvas.Pen.Width := Round((OnePt/4) * FWidth);
  if FColor = clNone then
  begin
    Canvas.Pen.Style := psClear;
    Exit;
  end;
  AWidth := Canvas.Pen.Width;
  lb.lbStyle := BS_SOLID;
  lb.lbColor := ColorToRGB(Canvas.Pen.Color);
  lb.lbHatch := 0;

  LineStyle := PS_SOLID;
  case Canvas.Pen.Style of
    psSolid     : LineStyle := PS_SOLID;
    psDash      : LineStyle := PS_DASH;
    psDot       : LineStyle := PS_DOT;
    psDashDot   : LineStyle := PS_DASHDOT;
    psDashDotDot: LineStyle := PS_DASHDOTDOT;
    psClear     : LineStyle := PS_NULL;
  end;
  APenStyle := PS_GEOMETRIC;
  if (AWidth <= 1) and (LineStyle = PS_SOLID) then
  begin
    AWidth := 1;
    APenStyle := PS_COSMETIC;
  end;

  Canvas.Pen.Handle := ExtCreatePen(APenStyle or
                                    LineStyle or
                                    PS_ENDCAP_SQUARE or
                                    PS_JOIN_MITER,
                                    AWidth,
                                    lb,
                                    0,
                                     nil);
  if FColor = clNone then Canvas.Pen.Style := psClear;
end;

procedure TGmPen.AssignToPen(APen: TPen);
begin
  APen.Color := FColor;
  APen.Style := FStyle;
  APen.Width := FWidth;
end;

procedure TGmPen.LoadFromStream(Stream: TStream);
var
  AValues: TGmValueList;
begin
  AValues := TGmValueList.Create;
  try
    AValues.LoadFromStream(Stream);
    FColor := AValues.ReadIntValue(C_CL, clBlack);
    FWidth := AValues.ReadIntValue(C_SZ, 1);
    FStyle := TPenStyle(AValues.ReadIntValue(C_ST, Ord(psSolid)));
    FMode  := TPenMode(AValues.ReadIntValue(C_PM, Ord(pmCopy)));
  finally
    AValues.Free;
  end;
end;

procedure TGmPen.SaveToStream(Stream: TStream);
var
  AValues: TGmValueList;
begin
  AValues := TGmValueList.Create;
  try
    AValues.WriteIntValue(C_CL, FColor);
    AValues.WriteIntValue(C_SZ, FWidth);
    AValues.WriteIntValue(C_ST, Ord(FStyle));
    AValues.WriteIntValue(C_PM, Ord(FMode));
    AValues.SaveToStream(Stream);
  finally
    AValues.Free;
  end;
end;

//------------------------------------------------------------------------------

// *** TGmPenList ***

function TGmPenList.GetPen(index: integer): TGmPen;
begin
  if index = -1 then
  begin
    Result := nil;
    Exit;
  end;
  Result := TGmPen(Items[index]);
end;

procedure TGmPenList.SetPen(index: integer; APen: TGmPen);
begin
  Items[index] := APen;
end;

function TGmPenList.AddPen(APen: TGmPen): TGmPen;
var
  NewPen: TGmPen;
  Index: integer;
begin
  Index := IndexOf(APen);
  if Index > -1 then
  begin
    Result := Self[Index];
    ReferenceList.IncValueAtIndex(Index);
    Exit;
  end;
  NewPen := TGmPen.Create;
  NewPen.Assign(APen);
  Add(NewPen);
  ReferenceList.AddValue(1);
  Result := NewPen;
end;

function TGmPenList.IndexOf(APen: TGmPen): integer;
var
  ICount: integer;
  ComparePen: TGmPen;
begin
  Result := -1;
  for ICount := 0 to Count-1 do
  begin
    ComparePen := Self[ICount];
    if ComparePens(ComparePen, APen) then
    begin
      Result := ICount;
      Exit;
    end;
  end;
end;

procedure TGmPenList.LoadFromStream(Stream: TStream);
var
  ICount,
  NumPens: integer;
  NewPen: TGmPen;
begin
  Stream.ReadBuffer(NumPens, SizeOf(NumPens));
  NewPen := TGmPen.Create;
  try
    for ICount := 0 to NumPens-1 do
    begin
      NewPen.LoadFromStream(Stream);
      AddPen(NewPen);
    end;
  finally
    NewPen.Free;
  end;
  FReferenceList.LoadFromStream(Stream);
end;

procedure TGmPenList.SaveToStream(Stream: TStream);
var
  WritePen: TGmPen;
  ICount,
  NumPens: integer;
begin
  NumPens := Count;
  Stream.WriteBuffer(NumPens, SizeOf(NumPens));
  for ICount := 0 to Count-1 do
  begin
    WritePen := Pen[ICount];
    WritePen.SaveToStream(Stream);
  end;
  FReferenceList.SaveToStream(Stream);
end;

//------------------------------------------------------------------------------

constructor TGmGraphicList.Create;
begin
  inherited Create;
  FGraphicCompare := True;
end;

function TGmGraphicList.GetGraphic(index: integer): TGraphic;
begin
  if index = -1 then
  begin
    Result := nil;
    Exit;
  end;
  Result := TGraphic(Items[index]);
  if (Result is TBitmap) then TBitmap(Result).Handle;
end;

function TGmGraphicList.GetGraphicType(AGraphic: TGraphic): TGmGraphicType;
begin
  Result := gmBitmap;
  if (AGraphic is TJPEGImage) then Result := gmJPeg
  else
  if (AGraphic is TMetafile) then Result := gmMetafile;
end;

procedure TGmGraphicList.SetGraphic(index: integer; Graphic: TGraphic);
begin
  Items[index] := Graphic;
end;

function TGmGraphicList.AddGraphic(AGraphic: TGraphic): TGraphic;
var
  AddGraphic: TGraphic;
  ICount: integer;
  CompareGraphic: TGraphic;
begin
  if FGraphicCompare then
  begin
    for ICount := 0 to Count-1 do
    begin
      CompareGraphic := TGraphic(Self[ICount]);
      if CompareGraphics(AGraphic, CompareGraphic) then
      begin
        Result := TGraphic(Items[ICount]);
        FReferenceList.IncValueAtIndex(ICount);
        Exit;
      end;
    end;
  end;

  if (AGraphic is TJPegImage) then AddGraphic := TJPegImage.Create
  else
  if (AGraphic is TMetafile) then AddGraphic := TMetafile.Create
  else
  if (AGraphic is TBitmap) then AddGraphic := TBitmap.Create
  else
  begin
    Result := nil;
    Exit;
  end;

  AddGraphic.Assign(AGraphic);
  Add(AddGraphic);
  if (AddGraphic is TBitmap) then
    TBitmap(AddGraphic).Dormant;
  FReferenceList.AddValue(1);
  Result := AddGraphic;
end;

function TGmGraphicList.IndexOf(AGraphic: TGraphic): integer;
var
  ICount: integer;
  CompareGraphic: TGraphic;
begin
  Result := -1;
  for ICount := 0 to Count-1 do
  begin
    CompareGraphic := TGraphic(Self[ICount]);
    if CompareGraphics(CompareGraphic, AGraphic) then
    begin
      Result := ICount;
      Exit;
    end;
  end;
end;

procedure TGmGraphicList.LoadFromStream(Stream: TStream);
var
  ICount,
  NumGraphics: integer;
  ReadGraphic: TGraphic;
  GraphicType: TGmGraphicType;
  Marker: integer;
begin
  Stream.ReadBuffer(NumGraphics, SizeOf(NumGraphics));
  for ICount := 0 to NumGraphics-1 do
  begin
    Stream.ReadBuffer(GraphicType, SizeOf(GraphicType));
    ReadGraphic := nil;
    case GraphicType of
      gmJPeg:     ReadGraphic := TJPEGImage.Create;
      gmMetafile: ReadGraphic := TMetafile.Create;
      gmBitmap:   ReadGraphic := TBitmap.Create;
    end;
    Stream.Read(Marker, SizeOf(Marker));
    if Assigned(ReadGraphic) then
    begin
      ReadGraphic.LoadFromStream(Stream);
      Add(ReadGraphic);
    end;
    Stream.Seek(Marker, soFromBeginning);
  end;
  FReferenceList.LoadFromStream(Stream);
end;

procedure TGmGraphicList.SaveToStream(Stream: TStream);
var
  ICount,
  NumGraphics: integer;
  WriteGraphic: TGraphic;
  GraphicType: TGmGraphicType;
  InsertPos: Integer;
  Marker: integer;
begin
  NumGraphics := Count;
  Stream.WriteBuffer(NumGraphics, SizeOf(NumGraphics));
  for ICount := 0 to Count-1 do
  begin
    WriteGraphic := Graphic[ICount];
    GraphicType := GetGraphicType(WriteGraphic);
    Stream.WriteBuffer(GraphicType, SizeOf(GraphicType));
    InsertPos := Stream.Position;
    Stream.Seek(4, soFromCurrent);
    WriteGraphic.SaveToStream(Stream);
    Stream.Seek(InsertPos, soFromBeginning);
    Marker := Stream.Size;
    Stream.WriteBuffer(Marker, SizeOf(Marker));
    Stream.Seek(0, soFromEnd);
  end;
  FReferenceList.SaveToStream(Stream);
end;

//------------------------------------------------------------------------------

// *** TGmCustomMemoList ***

constructor TGmCustomMemoList.Create;
begin
  inherited Create;
  FParentForm := TForm.Create(nil);
  FParentForm.Width := 0;
  FParentForm.Height := 0;
  FParentForm.BorderStyle := bsNone;
  FParentForm.Visible := True;
end;

destructor TGmCustomMemoList.Destroy;
begin
  inherited Destroy;
  FParentForm.Free;
end;

function TGmCustomMemoList.CreateMemo: TCustomMemo;
begin
  Result := nil;
  if Assigned(FNeedRichEdit) then FNeedRichEdit(Self, Result);
  if Result = nil then
    Result := CreateTRichEdit
  else
  begin
    Result.Width := 0;
    Result.Height := 0;
  end;
  Result.Parent := FParentForm;
end;

function TGmCustomMemoList.GetMemo(index: integer): TCustomMemo;
begin
  if index = -1 then
  begin
    Result := nil;
    Exit;
  end;
  Result := TCustomMemo(Items[index]);
end;

function TGmCustomMemoList.GetMemoType(AMemo: TCustomMemo): TGmMemoType;
begin
  if AMemo.ClassName = 'TMemo' then
    Result := gmMemo
  else
    Result := gmRichEdit;
end;

procedure TGmCustomMemoList.SetMemo(index: integer; AMemo: TCustomMemo);
begin
  Items[index] := AMemo;
end;

function TGmCustomMemoList.AddMemo(AMemo: TCustomMemo): TCustomMemo;
var
  MemoIndex: integer;
  AddMemo: TCustomMemo;
  AText: string;
begin
  MemoIndex := IndexOf(AMemo);
  if MemoIndex <> -1 then
  begin
    Result := TCustomMemo(Items[MemoIndex]);
    FReferenceList.IncValueAtIndex(MemoIndex);
    Exit;
  end;
  AddMemo := CreateMemo;
  AText := GetRtfText(AMemo);
  AddMemo.Parent := FParentForm;
  // showing and hiding the below form will trigger the "OnActivate" event of
  // the active form in the application.  This is unavoidable as the TRichEdit's
  // parent form has to be Visible to work under Windows 98.
  //FParentForm.Visible := True;
  try
    InsertRtfText(AddMemo, AText);
  finally
  //  FParentForm.Visible := False;
  end;
  if AddMemo.Lines.Text = '' then;
  Add(AddMemo);
  FReferenceList.AddValue(1);
  Result := AddMemo;
end;

function TGmCustomMemoList.IndexOf(AMemo: TCustomMemo): integer;
var
  ICount: integer;
  FindMemo,
  CompareMemo: TCustomMemo;
begin
  Result := -1;
  FindMemo := AMemo;
  for ICount := 0 to Count-1 do
  begin
    CompareMemo := TCustomMemo(Self[ICount]);
    if FindMemo = CompareMemo then
    begin
      Result := ICount;
      Exit;
    end;
  end;
end;

procedure TGmCustomMemoList.LoadFromStream(Stream: TStream);
var
  ICount,
  NumMemos: integer;
  ReadMemo: TCustomMemo;
  MemoType: TGmMemoType;
  ATextStream: TMemoryStream;
  Reader: TGmReader;
begin
  Reader := TGmReader.Create(Stream);
  try
    NumMemos := Reader.ReadInteger;
    for ICount := 0 to NumMemos-1 do
    begin
      MemoType := TGmMemoType(Reader.ReadInteger);
      if MemoType = gmMemo then
      begin
        ReadMemo := CreateTRichEdit;
        TRichEdit(ReadMemo).PlainText := True;
      end
      else
        ReadMemo := CreateMemo;
      ReadMemo.Parent := FParentForm;
      ATextStream := TMemoryStream.Create;
      try
        Reader.ReadStream(ATextStream);
        ATextStream.Seek(0, soFromBeginning);
        InsertRtfStream(ReadMemo, ATextStream);
      finally
        ATextStream.Free;
      end;
      AddMemo(ReadMemo);
    end;
  finally
    Reader.Free;
  end;
  FReferenceList.LoadFromStream(Stream);
end;

procedure TGmCustomMemoList.SaveToStream(Stream: TStream);
var
  ICount,
  NumMemos: integer;
  WriteMemo: TCustomMemo;
  MemoType: TGmMemoType;
  ATextStream: TStringStream;
  Writer: TGmWriter;
begin
  NumMemos := Count;
  Writer := TGmWriter.Create(Stream);
  try
    Writer.WriteInteger(NumMemos);

    for ICount := 0 to Count-1 do
    begin
      WriteMemo := Memo[ICount];
      MemoType := GetMemoType(WriteMemo);
      Writer.WriteInteger(Ord(MemoType));
      ATextStream := TStringStream.Create('');
      try
        ATextStream.WriteString(GetRtfText(WriteMemo));
        ATextStream.Seek(0, soFromBeginning);
        Writer.WriteStream(ATextStream);
      finally
        ATextStream.Free;
      end;
    end;
  finally
    Writer.Free;
  end;
  FReferenceList.SaveToStream(Stream);
end;

//------------------------------------------------------------------------------

// *** TGmResourceTable ***

constructor TGmResourceTable.Create;
begin
  inherited Create;
  FBrushList := TGmBrushList.Create;
  FFontList := TGmFontList.Create;
  FPenList := TGmPenList.Create;
  FGraphicList := TGmGraphicList.Create;
  FCustomMemoList := TGmCustomMemoList.Create;
end;

destructor TGmResourceTable.Destroy;
begin
  FBrushList.Free;
  FFontList.Free;
  FPenList.Free;
  FGraphicList.Free;
  FCustomMemoList.Free;
  inherited Destroy;
end;

procedure TGmResourceTable.Clear;
begin
  FBrushList.Clear;
  FFontList.Clear;
  FPenList.Clear;
  FGraphicList.Clear;
  FCustomMemoList.Clear;
end;

procedure TGmResourceTable.LoadFromStream(Stream: TStream);
begin
  FBrushList.LoadFromStream(Stream);
  FFontList.LoadFromStream(Stream);
  FPenList.LoadFromStream(Stream);
  FGraphicList.LoadFromStream(Stream);
  FCustomMemoList.LoadFromStream(Stream);
end;

procedure TGmResourceTable.SaveToStream(Stream: TStream);
begin
  FBrushList.SaveToStream(Stream);
  FFontList.SaveToStream(Stream);
  FPenList.SaveToStream(Stream);
  FGraphicList.SaveToStream(Stream);
  FCustomMemoList.SaveToStream(Stream);
end;

//------------------------------------------------------------------------------

// *** TGmFontMapper ***

constructor TGmFontMapper.Create;
begin
  inherited Create;
  if (ReturnOSVersion = 'Windows 98') or
     (ReturnOSVersion = 'Windows 95') then
    CALC_PPI := 14400 div 4
  else
    CALC_PPI := 14400 div 2;

  FCalcPpi := CALC_PPI;
  FRenderBitmap := TBitmap.Create;
  FRenderBitmap.Canvas.Font.PixelsPerInch := FCalcPpi;
  FWrapText := True;
end;

destructor TGmFontMapper.Destroy;
begin
  FRenderBitmap.Free;
  inherited Destroy;
end;

function TGmFontMapper.TextExtent(ACanvas: TCanvas; AText: string): TGmSize;
var
  FontSize: integer;
  Ppi: integer;
begin
  FRenderBitmap.Canvas.Font.Assign(ACanvas.Font);
  FontSize := ACanvas.Font.Size;
  FRenderBitmap.Canvas.Font.PixelsPerInch := FCalcPpi;
  FRenderBitmap.Canvas.Font.Size := FontSize;
  Ppi := FCalcPpi;
  Result.Width := FRenderBitmap.Canvas.TextWidth(AText) / Ppi;
  Result.Height := FRenderBitmap.Canvas.TextHeight(AText) / Ppi;
end;

function TGmFontMapper.TextHeight(ACanvas: TCanvas; AText: string): Extended;
begin
  Result := TextExtent(ACanvas, AText).Height;
end;

function TGmFontMapper.TextWidth(ACanvas: TCanvas; AText: string): Extended;
begin
  Result := TextExtent(ACanvas, AText).Width;
end;

function TGmFontMapper.TextBox(ACanvas: TCanvas; ARect: TRect; AText: string; Alignment: TAlignment; const AFastDraw: Boolean = False): Extended;

  function GetNextWord(var AText: string): string;
  var
    NextSpace: integer;
    NextCr: integer;
    LineBreak: string;
  begin
    NextSpace := Pos(' ', AText);
    LineBreak := #13;
    NextCr := Pos(LineBreak, AText);
    if (NextSpace = 0) and (NextCr > 0) then NextSpace := NextCr
    else
    if (NextCr <> 0) and (NextCr < NextSpace) then NextSpace := NextCr;
    if NextSpace = 0 then NextSpace := Length(AText);
    Result := Copy(AText, 1, NextSpace);
    Delete(AText, 1, NextSpace);
  end;

  procedure DrawLine(ACanvas: TCanvas; ARect: TRect; LineNum: integer; AText: string; Align: TAlignment; AFastDraw: Boolean);
  var
    LineWidth: integer;
    XPos: integer;
    TextBoxWidth: integer;
  begin
    AText := TrimRight(AText);
    TextBoxWidth := ARect.Right - ARect.Left;
    LineWidth := Round(GmFontMapper.TextWidth(ACanvas, AText) * FDestPpi);
    XPos := ARect.Left;
    case Alignment of
      taCenter:      XPos := ARect.Left + (TextBoxWidth - LineWidth) div 2;
      taRightJustify:Xpos := ARect.Left + (TextBoxWidth - LineWidth);
    end;
    TextOut(ACanvas,
            XPos,
            ARect.Top + Round((GmFontMapper.TextHeight(ACanvas, AText) * LineNum) * FDestPpi),
            @ARect,
            AText,
            AFastDraw);
  end;

var
  LineNum: integer;
  str: string;
  NextWord: string;
  TextBoxWidth: Extended;
  CurrentLine: string;
  LineWidth: Extended;
  BreakLine: Boolean;
begin
  if AFastDraw then
    FCalcPpi := SCREEN_PPI
  else
    FCalcPpi := CALC_PPI;

  FDestPpi := ACanvas.Font.PixelsPerInch;
  LineNum := 0;
  CurrentLine := '';
  TextBoxWidth := (ARect.Right - ARect.Left) / FDestPpi;
  BreakLine := False;
  Str := AText;
  Str := ReplaceStringFields(Str, #13#10, #13);
  while Length(str) > 0 do
  begin
    NextWord := GetNextWord(str);
    LineWidth :=  GmFontMapper.TextWidth(ACanvas, CurrentLine + NextWord);
    if ((LineWidth > TextBoxWidth) or (BreakLine)) and (FWrapText) then
    begin
      if GmFontMapper.TextWidth(ACanvas, NextWord) > TextBoxWidth then
      begin
        CurrentLine := CurrentLine + NextWord;
        NextWord := '';
      end;
      DrawLine(ACanvas, ARect, LineNum, CurrentLine, taLeftJustify, AFastDraw);
      CurrentLine := '';
      Inc(LineNum);
      BreakLine := False;
    end;
    CurrentLine := CurrentLine + NextWord;
    if NextWord <> '' then
    begin
      if NextWord[Length(NextWord)] = #13 then BreakLine := True;
    end;
  end;
  if CurrentLine <> '' then
  begin
    DrawLine(ACanvas, ARect, LineNum, CurrentLine, taLeftJustify, AFastDraw);
    Inc(LineNum);
  end;
  Result := (GmFontMapper.TextHeight(ACanvas, AText) * LineNum);
end;

function TGmFontMapper.TextBoxHeight(AFont: TFont; ARect: TRect; AText: string): Extended;
begin
  FRenderBitmap.Canvas.Font.PixelsPerInch := FCalcPpi;
  FRenderBitmap.Canvas.Font.Assign(AFont);
  Result := TextBox(FRenderBitmap.Canvas, ARect,AText, taLeftJustify);
end;

procedure TGmFontMapper.TextOut(ACanvas: TCanvas; X, Y: integer; ARect: PRect; AText: string; const AFastDraw: Boolean = False);
begin
  if AFastDraw then
    FCalcPpi := SCREEN_PPI
  else
    FCalcPpi := CALC_PPI;
  FDestPpi := ACanvas.Font.PixelsPerInch;
  SetLength(FCharSpacing, 0);
  FRenderBitmap.Canvas.Font.PixelsPerInch := FCalcPpi;
  FRenderBitmap.Canvas.Font.Assign(ACanvas.Font);
  CalculateCharSpacing(FRenderBitmap.Canvas, AText);
  GmDrawText(ACanvas, X, Y, ARect, AText, FCharSpacing);
end;

procedure TGmFontMapper.GmDrawText(ACanvas: TCanvas; X, Y: integer; ARect: PRect; AText: string; const Spacing: array of integer);
begin
  if (High(Spacing) = -1) or (ReturnOSVersion = 'Windows NT') then
    ExtTextOut(ACanvas.Handle, X, Y, ETO_CLIPPED, ARect, PChar(AText), Length(AText), nil)
  else
    ExtTextOut(ACanvas.Handle, X, Y, ETO_CLIPPED, ARect, PChar(AText), Length(AText), @Spacing);
end;

procedure TGmFontMapper.CalculateCharSpacing(ACanvas: TCanvas; AText: string);
var
  CharSpacing: Extended;
  ICount: integer;
  ExtraKern: Extended;
begin
  ExtraKern := 0;
  SetLength(FCharSpacing, Length(AText));
  for ICount := 0 to Length(AText)-1 do
  begin
    CharSpacing := (ACanvas.TextWidth(AText[ICount+1]) / FCalcPpi) * FDestPpi;
    FCharSpacing[ICount] := Trunc(CharSpacing);
    ExtraKern := ExtraKern + Frac(CharSpacing);
    if ExtraKern > 1 then
    begin
      FCharSpacing[ICount] := FCharSpacing[ICount] + Trunc(ExtraKern);
      ExtraKern := ExtraKern - Round(ExtraKern);
    end;
  end;
end;

initialization
  GmFontMapper := TGmFontMapper.Create;

finalization
  GmFontMapper.Free;

end.
