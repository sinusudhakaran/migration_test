unit XLSCellComment;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4.0

    Cell comment classes

-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses HList, XLSBase, XLSError, XLSFormat;

type
  TCellComments = class;

  { TCellComment }
  TCellComment = class
  protected
    FOwner: TCellComments;
    FRow, FColumn: Word;
    FStored: Boolean;
    FText: WideString;
    FAuthor: WideString;
    FRichFormat: AnsiString;
    FWidthPx, FHeightPx: Word;
    procedure SetText(const AText: WideString);
    function GetText: WideString;
    procedure SetAuthor(const AAuthor: WideString);
    function GetAuthor: WideString;
    procedure SetRichFormat(const ARichFormat: AnsiString);
    function GetRichFormat: AnsiString;
    procedure SetWidthPx(const AWidthPx: Word);
    function GetWidthPx: Word;
    procedure SetHeightPx(const AHeightPx: Word);
    function GetHeightPx: Word;
  public
    constructor Create(const AOwner: TCellComments; const ARow, AColumn: Word);
    procedure Clear;
    procedure Assign(
      const AText: WideString;
      const AAuthor: WideString;
      const ARichFormat: AnsiString;
      const AddAuthorToText: Boolean);
    procedure AssignWithSize(
      const AText: WideString;
      const AAuthor: WideString;
      const ARichFormat: AnsiString;
      const AWidthPx: Integer;
      const AHeightPx: Integer;
      const AddAuthorToText: Boolean);
    property Column: Word read FColumn;
    property Row: Word read FRow;
    property Text: WideString read GetText write SetText;
    property Author: WideString read GetAuthor write SetAuthor;
    property RichFormat: AnsiString read GetRichFormat write SetRichFormat;
    property WidthPx: Word read GetWidthPx write SetWidthPx;
    property HeightPx: Word read GetHeightPx write SetHeightPx;
  end;

  { TCellComments }
  TCellComments = class
  protected
    FTmpItem: TCellComment;
    FItems: THashedList;
    procedure ForceStoreItem(AItem: TCellComment);
    procedure GetItemKey(AItem: Pointer; var Key: AnsiString);
    function GetItemIndex(AItem: Pointer): Integer;
    procedure SetKey(ARow, AColumn: Word; var Key: AnsiString);
    procedure ClearKey(var Key: AnsiString);
    function FindRowCol(ARow, AColumn: Word): TCellComment;
    procedure Add(AItem: TCellComment);
    function GetItem(Ind: Integer): TCellComment;
    function GetComment(ARow, AColumn: Word): TCellComment;
    function GetCount: Integer;
    procedure RemoveCellComment(ACellComment: TCellComment);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Copy(const ASource, ADest: TCellComment);
    property Item[Ind: Integer]: TCellComment read GetItem;
    property Comment[ARow, AColumn: Word]: TCellComment read GetComment; default;
    property Count: Integer read GetCount;
  end;

implementation
uses SysUtils, XLSRichString;

var
  xlCommentDefaultWidthPx: Word; // 128;
  xlCommentDefaultHeightPx: Word; // 75;

{ TCellComment }
constructor TCellComment.Create(const AOwner: TCellComments; const ARow, AColumn: Word);
begin
  FOwner:= AOwner; 
  FRow:= ARow;
  FColumn:= AColumn;
  FStored:= False;

  Text:= '';
  Author:= '';
  RichFormat:= ''; 
  
  { set default rect size }
  FWidthPx:= xlCommentDefaultWidthPx;
  FHeightPx:= xlCommentDefaultHeightPx
end;

procedure TCellComment.Clear;
begin
  if Assigned(FOwner) then
    TCellComments(FOwner).RemoveCellComment(Self);
end;

procedure TCellComment.SetText(const AText: WideString);
begin
  if (AText <> FText) then
    FText:= AText;
  if (AText <> '') then
    FOwner.ForceStoreItem(Self);
end;

function TCellComment.GetText: WideString;
begin
  Result:= FText;
end;

procedure TCellComment.SetAuthor(const AAuthor: WideString);
begin
  if (AAuthor <> FAuthor) then
    FAuthor:= AAuthor;
  if (AAuthor <> '') then
    FOwner.ForceStoreItem(Self);
end;

function TCellComment.GetAuthor: WideString;
begin
  Result:= FAuthor;
end;

procedure TCellComment.SetRichFormat(const ARichFormat: AnsiString);
begin
  if (ARichFormat <> FRichFormat) then
    FRichFormat:= ARichFormat;
  if (ARichFormat <> '') then
    FOwner.ForceStoreItem(Self);
end;

function TCellComment.GetRichFormat: AnsiString;
begin
  Result:= FRichFormat;
end;

procedure TCellComment.SetWidthPx(const AWidthPx: Word);
begin
  if (AWidthPx <> FWidthPx) then
    FWidthPx:= AWidthPx;
  FOwner.ForceStoreItem(Self);
end;

function TCellComment.GetWidthPx: Word;
begin
  Result:= FWidthPx;
end;

procedure TCellComment.SetHeightPx(const AHeightPx: Word);
begin
  if (AHeightPx <> FHeightPx) then
    FHeightPx:= AHeightPx;
  FOwner.ForceStoreItem(Self);
end;

function TCellComment.GetHeightPx: Word;
begin
  Result:= FHeightPx;
end;

procedure TCellComment.Assign(
  const AText: WideString;
  const AAuthor: WideString;
  const ARichFormat: AnsiString;
  const AddAuthorToText: Boolean);
var
  LRichFormat: AnsiString;
  L, LText: Integer;
begin
  L:= Length(AAuthor);
  LText:= Length(AText);

  { Set default format if it is empty }
  LRichFormat:= ARichFormat;
  if (LRichFormat = '') and (LText > 0) then
    LRichFormat:= '1-' + AnsiString(IntToStr(LText)) + '(font:Tahoma;size:8);';

  Author:= AAuthor;

  if AddAuthorToText and (L > 0) then
  begin
    Text:= AAuthor + ':' + #$0A + AText;
    LRichFormat:= '1-' + AnsiString(IntToStr(L + 2)) + '(style:b;font:Tahoma;size:8);'
                + ShiftRichFormatChars(LRichFormat, L + 2);
    RichFormat:= LRichFormat;
  end
  else
  begin
    Text:= AText;
    RichFormat:= LRichFormat;
  end;
end;

procedure TCellComment.AssignWithSize(
  const AText: WideString;
  const AAuthor: WideString;
  const ARichFormat: AnsiString;
  const AWidthPx: Integer;
  const AHeightPx: Integer;
  const AddAuthorToText: Boolean);
begin
  Assign
    ( AText
    , AAuthor
    , ARichFormat
    , AddAuthorToText);

  Self.WidthPx:= AWidthPx;
  Self.HeightPx:= AHeightPx;
end;

{ TCellComments }
constructor TCellComments.Create;
begin
  FItems:= THashedList.Create(1024 * 16 - 1, GetItemKey);
  FTmpItem:= nil;
end;

destructor TCellComments.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FItems.Count - 1 do
    if Assigned(FItems[I]) then
      TCellComment(FItems[I]).Destroy;
  FItems.Destroy;

  if Assigned(FTmpItem) then
    FTmpItem.Destroy;

  inherited;    
end;

procedure TCellComments.RemoveCellComment(ACellComment: TCellComment);
var
  Key: AnsiString;
begin
  if ACellComment.FStored then
  begin
    GetItemKey(ACellComment, Key);
    FItems.RemoveItemByKey(Key);
    ACellComment.Destroy;
  end;
end;

procedure TCellComments.Copy(const ASource, ADest: TCellComment);
begin
  ADest.Text      := ASource.Text;
  ADest.Author    := ASource.Author;
  ADest.RichFormat:= ASource.RichFormat;
  ADest.WidthPx   := ASource.WidthPx;
  ADest.HeightPx  := ASource.HeightPx;
end;

procedure TCellComments.ForceStoreItem(AItem: TCellComment);
begin
  if not AItem.FStored then
    Add(AItem);
  if AItem = FTmpItem then
    FTmpItem:= nil;
end;

procedure TCellComments.GetItemKey(AItem: Pointer; var Key: AnsiString);
begin
  SetKey(TCellComment(AItem).Row, TCellComment(AItem).Column, Key);
end;

procedure TCellComments.SetKey(ARow, AColumn: Word; var Key: AnsiString);
begin
  SetLength(Key, 4);
  Key[1]:= AnsiChar(Lo(ARow));
  Key[2]:= AnsiChar(Hi(ARow));
  Key[3]:= AnsiChar(Lo(AColumn));
  Key[4]:= AnsiChar(Hi(AColumn));
end;

procedure TCellComments.ClearKey(var Key: AnsiString);
begin
  SetLength(Key, 0);
end;

function TCellComments.GetItemIndex(AItem: Pointer): Integer;
var
  Key: AnsiString;
begin
  GetItemKey(AItem, Key);
  Result:= FItems.IndexByKey(Key);
end;

function TCellComments.FindRowCol(ARow, AColumn: Word): TCellComment;
var
  Key: AnsiString;
begin
  SetKey(ARow, AColumn, Key);
  result:= TCellComment(FItems.ItemByKey(Key));
  ClearKey(Key);
end;

procedure TCellComments.Add(AItem: TCellComment);
begin
  FItems.Add(AItem);
  AItem.FStored:= true; {here and only here}
end;

function TCellComments.GetItem(Ind: Integer): TCellComment;
begin
  result:= TCellComment(FItems[Ind]);
end;

function TCellComments.GetComment(ARow, AColumn: Word): TCellComment;
  procedure CheckRowCol;
  begin
    if AColumn > (BIFF8_MAXCOLS - 1) then
      raise EXLSError.Create(EXLS_BADROWCOL);
  end;
begin
  CheckRowCol;
  Result:= FindRowCol(ARow, AColumn);
  if not Assigned(Result) then
  begin
    if Assigned(FTmpItem) then
    begin
      FTmpItem.Destroy;
      FTmpItem:= nil;
    end;
    Result:= TCellComment.Create(Self, ARow, AColumn);
    FTmpItem:= Result;
  end;
end;

function TCellComments.GetCount: Integer;
begin
  result:= FItems.Count;
end;

initialization
  xlCommentDefaultWidthPx:= 2 * xlDefaultColumnWidthPx;
  xlCommentDefaultHeightPx:= 5 * (xlDefaultRowHeightPx - 2);
end.


