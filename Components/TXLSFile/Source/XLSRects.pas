unit XLSRects;

{-----------------------------------------------------------------
    SM Software, 2000-2004

    TXLSFile v.4.0

    Rev history:
    2004-02-21  FindRectContainingCellCoord added
    
-----------------------------------------------------------------}

interface
uses Classes, SysUtils, XLSBase;

type
  {TCellCoord}
  TCellCoord = packed record
    Row: Word;
    Column: Byte;
    RelativeFlags: Byte;
  end;
  PCellCoord = ^TCellCoord;

  {TCellCoords}
  TCellCoords = class
  protected
    FItems: TList;
    function GetItem(Ind: Integer): TCellCoord;
    function GetItemsCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddCellCoords(ACellCoords: TCellCoords);    
    procedure Add(Row: Word; Column: Byte);
    procedure Remove(Ind: Integer);
    property Item[Ind: Integer]: TCellCoord read GetItem;
    property ItemsCount: Integer read GetItemsCount;
  end;

  {TRangeRect}
  TRangeRect = packed record
    RowFrom, RowTo: Word;
    ColumnFrom, ColumnTo: Byte;
    RelativeFlags: Byte;
  end;
  PRangeRect = ^TRangeRect;

  {TRangeRects}
  TRangeRects = class
  protected
    FRects: TList;
    function GetRect(Ind: Integer): TRangeRect;
    function GetRectsCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddRect(const ARowFrom, ARowTo: Word; AColumnFrom, AColumnTo: Byte);
    procedure AddRectRec(const ARect: TRangeRect);
    procedure AddRangeRects(ARangeRects: TRangeRects);
    procedure SetRect(const Ind: Integer;
      const ARowFrom, ARowTo: Word; AColumnFrom, AColumnTo: Byte);
    procedure DeleteRect(const Ind: Integer);
    function FindRectContainingCellCoord(const ARow: Word; const AColumn: Byte;
      var ARect: TRangeRect): Boolean;
    procedure InternalShift(const ATopRow, ABottomRow, ALeftColumn, ARightColumn
          , ADestTopRow, ADestLeftColumn: Integer; const MoveCells: Boolean);
    property Rect[Ind: Integer]: TRangeRect read GetRect;
    property RectsCount: Integer read GetRectsCount;
  end;

function ParseAreaA1Ref(const AAreaA1Ref: AnsiString): TRangeRect;
function ParseAreaA1RefVar(const AAreaA1Ref: AnsiString; var AAreaRect: TRangeRect): Boolean;
function ParseRangeA1Ref(const ARangeA1Ref: AnsiString): TRangeRects;
function ParseRangeA1RefVar(const ARangeA1Ref: AnsiString; var ARangeRects: TRangeRects): Boolean;
function ParseCellA1Ref(const ACellA1Ref: AnsiString): TCellCoord;
function ParseCellA1RefVar(const ACellA1Ref: AnsiString; var ACellCoord: TCellCoord): Boolean;
  
function ColNameToColIndex(const AColName: AnsiString): Integer;
function ColIndexToColName(const AColIndex: Integer): AnsiString;
function ColNameToColIndexVar(const AColName: AnsiString; var AColIndex: Integer): Boolean;
function RectToText(const Rect: TRangeRect): AnsiString;

function IsCellCoordInRect(const ARow: Word; const AColumn: Byte; const ARect: TRangeRect): Boolean;

procedure RangeRectsApplyRowsShift(var Rects: TRangeRects;
  const ATopRow, ABottomRow: Word; const ADestTopRow: Word);
procedure RangeRectsApplyColumnsShift(var Rects: TRangeRects;
  const ALeftColumn, ARightColumn: Byte; const ADestLeftColumn: Byte);
function RectContainsInRect(
  const ALeftColumn, ARightColumn, ATopRow, ABottomRow: Integer;
  const InLeftColumn, InRightColumn, InTopRow, InBottomRow: Integer): Boolean;
function RangeRectContainsInRect(
  ARect: TRangeRect;
  const InLeftColumn, InRightColumn, InTopRow, InBottomRow: Integer): Boolean;


implementation
uses XLSError, XLSFormula, XLSStrUtil;

function ColNameToColIndexVar(const AColName: AnsiString; var AColIndex: Integer): Boolean;
var
  S: AnsiString;
  I: Integer;
  Base, Power : Integer;
begin
  if Length(AColName) = 0 then
  begin
    Result:= False;
    Exit;
  end;

  Base:= Ord('Z') - Ord('A') + 1;
  Power:= 1;
  S:= AnsiStringUpperCase(AColName);
  AColIndex:= 0;

  for I:= Length(S) downto 1 do
  begin
    if ( (Ord(S[I]) < Ord('A')) or (Ord(S[I]) > Ord('Z')) ) then
    begin
      Result:= False;
      Exit;
    end;
    AColIndex:= AColIndex + Power * (Ord(S[I]) - Ord('A') + 1);
    Power:= Power * Base;
  end;

  // return 0-based
  AColIndex:= AColIndex - 1;
  Result:= True;
end;

function ColNameToColIndex(const AColName: AnsiString): Integer;
begin
  if not ColNameToColIndexVar(AColName, Result) then
    raise EXLSError.Create(EXLS_BADROWCOL);
end;

function ColIndexToColName(const AColIndex: Integer): AnsiString;
var
  LMod, LDiv: Integer;
begin
  Result:= '';
  LDiv:= AColIndex + 1;
  while (LDiv > 0) do
  begin
    LMod:= LDiv mod 26;
    LDiv:= LDiv div 26;
    if (LMod = 0) then
    begin
      Result:= 'Z' + Result;
      LDiv:= LDiv - 1;
    end
    else
      Result:= AnsiChar(LMod + Ord('A') - 1) + Result;
  end;
end;

function RectToText(const Rect: TRangeRect): AnsiString;
begin
  { if ColumnFrom > ColumnTo then hide columns names,
    if RowFrom > RowTo then hide rows numbers
  }
  Result:= '';
  if (Rect.ColumnFrom <= Rect.ColumnTo) then
  begin
    if ( Rect.RelativeFlags and $01 ) <> 0 then
      Result:= Result + '$';
    Result:= Result + ColIndexToColName(Rect.ColumnFrom);
  end;

  if (Rect.RowFrom <= Rect.RowTo) then
  begin
    if ( Rect.RelativeFlags and $02 ) <> 0 then
      Result:= Result + '$';
    Result:= Result + AnsiSTring(IntToStr(Rect.RowFrom + 1));
  end;

  Result:= Result + ':';

  if (Rect.ColumnFrom <= Rect.ColumnTo) then
  begin
    if ( Rect.RelativeFlags and $04 ) <> 0 then
      Result:= Result + '$';
    Result:= Result + ColIndexToColName(Rect.ColumnTo);
  end;

  if (Rect.RowFrom <= Rect.RowTo) then
  begin
    if ( Rect.RelativeFlags and $08 ) <> 0 then
      Result:= Result + '$';
    Result:= Result + AnsiString(IntToStr(Rect.RowTo + 1));
  end;
end;

function ParseCellA1RefVar(const ACellA1Ref: AnsiString; var ACellCoord: TCellCoord): Boolean;
var
  Row, Col: Integer;
  S, SCol, SRow: AnsiString;
  I: Integer;
  RelativeFlags: Byte;

  function StrToIntVar(const S: AnsiString; var I: Integer): Boolean;
  var
    E: Integer;
  begin
    Val(String(S), I, E);
    Result:= (E = 0);
  end;

begin
  S:= AnsiStringUpperCase(ACellA1Ref);
  SCol:= '';
  SRow:= '';
  RelativeFlags:= 0;

  // find column
  if Copy(S, 1, 1) = '$' then
  begin
    RelativeFlags:= RelativeFlags or $01;
    S:= Copy(S, 2, Length(S) - 1);
  end;

  for I:= 1 to Length(S) do
    if S[I] in ['A'..'Z'] then
      SCol:= SCol + S[I]
    else
      break;

  // find row
  SRow:= Copy(S, Length(SCol) + 1, Length(S));
  if Copy(SRow, 1, 1) = '$' then
  begin
    RelativeFlags:= RelativeFlags or $02;
    SRow:= Copy(SRow, 2, Length(SRow) - 1);
  end;

  // convert to indexes
  if not StrToIntVar(SRow, Row) then
  begin
    Result:= false;
    Exit;
  end;
  Row:= Row - 1;

  if not ColNameToColIndexVar(SCol, Col) then
  begin
    Result:= false;
    Exit;
  end;

  ACellCoord.Row:= Row;
  ACellCoord.Column:= Col;
  ACellCoord.RelativeFlags:= RelativeFlags;
  Result:= true;
end;

function ParseCellA1Ref(const ACellA1Ref: AnsiString): TCellCoord;
begin
  if not ParseCellA1RefVar(ACellA1Ref, Result) then
    raise EXLSError.Create(EXLS_BADROWCOL);
end;

function ParseAreaA1RefVar(const AAreaA1Ref: AnsiString;
  var AAreaRect: TRangeRect): Boolean;
var
  C1, C2: TCellCoord;
  P: Integer;
  S: AnsiString;
begin
  P:= Pos(AnsiSTring(':'), AAreaA1Ref);
  if (P > 0) then
  begin
    S:= Copy(AAreaA1Ref, 1, P-1);
    if not ParseCellA1RefVar(S, C1) then
    begin
      Result:= false;
      Exit;
    end;
    S:= Copy(AAreaA1Ref, P+1, Length(AAreaA1Ref));
    if not ParseCellA1RefVar(S, C2) then
    begin
      Result:= false;
      Exit;
    end;
  end
  else
  begin
    if not ParseCellA1RefVar(AAreaA1Ref, C1) then
    begin
      Result:= false;
      Exit;
    end;
    C2:= C1;
  end;

  AAreaRect.RowFrom:= C1.Row;
  AAreaRect.RowTo  := C2.Row;
  AAreaRect.ColumnFrom:= C1.Column;
  AAreaRect.ColumnTo  := C2.Column;
  AAreaRect.RelativeFlags:= C1.RelativeFlags or (C2.RelativeFlags shl 2);
  Result:= true;
end;

function ParseAreaA1Ref(const AAreaA1Ref: AnsiString): TRangeRect;
begin
  if not ParseAreaA1RefVar(AAreaA1Ref, Result) then
    raise EXLSError.Create(EXLS_BADROWCOL);
end;

function ParseRangeA1RefVar(const ARangeA1Ref: AnsiString;
  var ARangeRects: TRangeRects): Boolean;
var
  Rect: TRangeRect;
  Rects: TRangeRects;
  S, SS: AnsiString;
  P: Integer;
begin
  Rects:= TRangeRects.Create;

  S:= AnsiStringUpperCase(ARangeA1Ref) + FMLA_ARG_SEPARATOR;
  P:= Pos(FMLA_ARG_SEPARATOR, S);
  while (P>0) do
  begin
    SS:= Copy(S, 1, P-1);
    if not ParseAreaA1RefVar(SS, Rect) then
    begin
      Result:= false;
      Rects.Destroy;
      Exit;
    end;
    Rects.AddRect(Rect.RowFrom, Rect.RowTo, Rect.ColumnFrom, Rect.ColumnTo);
    S:=  Copy(S, P+1, Length(S));
    P:= Pos(FMLA_ARG_SEPARATOR, S);
  end;

  ARangeRects:= Rects;
  Result:= true;
end;

function ParseRangeA1Ref(const ARangeA1Ref: AnsiString): TRangeRects;
begin
  if not ParseRangeA1RefVar(ARangeA1Ref, Result) then
    raise EXLSError.Create(EXLS_BADROWCOL);
end;

function IsCellCoordInRect(const ARow: Word; const AColumn: Byte;
  const ARect: TRangeRect): Boolean;
begin
  Result:= (ARect.RowFrom <= ARow)
       and (ARow <= ARect.RowTo)
       and (ARect.ColumnFrom <= AColumn)
       and (AColumn <= ARect.ColumnTo);
end;

procedure RangeRectsApplyRowsShift(var Rects: TRangeRects; const ATopRow, ABottomRow: Word; 
  const ADestTopRow: Word);
var
  RectInd: Integer;
  Rect: TRangeRect;
  DeleteRect: Boolean;
  Transformed: Boolean;
  NewTopRow, NewBottomRow: Integer;
begin
  for RectInd:= Rects.RectsCount - 1 downto 0 do
  begin
    Rect:= Rects.Rect[RectInd];
    DeleteRect:= False;
    Transformed:= False;

    if (Rect.RowFrom >= ATopRow) and (Rect.RowFrom <= ABottomRow) then
    begin
      if (Integer(Rect.RowFrom + (ADestTopRow - ATopRow)) < 0) then
        Rect.RowFrom:= 0
      else
      if (Integer(Rect.RowFrom + (ADestTopRow - ATopRow)) > BIFF8_MAXROWS - 1) then
        {if top row become more than max row - then delete this rect}
        DeleteRect:= True
      else
        Rect.RowFrom:= Rect.RowFrom + (ADestTopRow - ATopRow);

      Transformed:= True;
    end;

    if (Rect.RowTo >= ATopRow) and (Rect.RowTo <= ABottomRow) then
    begin
      {if bottom row become less than min row - then delete this rect}
      if (Integer(Rect.RowTo + (ADestTopRow - ATopRow)) < 0) then
        DeleteRect:= True
      else
      if (Integer(Rect.RowTo + (ADestTopRow - ATopRow)) > BIFF8_MAXROWS - 1) then
        Rect.RowTo:= BIFF8_MAXROWS - 1
      else
        Rect.RowTo:= Rect.RowTo + (ADestTopRow - ATopRow);

      Transformed:= True;
    end;

    NewTopRow:= ADestTopRow;
    if (not Transformed)
       and (Rect.RowFrom <= NewTopRow) and (NewTopRow <= Rect.RowTo)  then
    begin
      if not IsValidRow(NewTopRow - 1) then
         DeleteRect:= True
      else 
         Rect.RowTo:= NewTopRow - 1;
    end;

    NewBottomRow:= Integer(ABottomRow + (ADestTopRow - ATopRow));
    if (not Transformed)
       and (Rect.RowFrom <= NewBottomRow) and (NewBottomRow <= Rect.RowTo)  then
    begin
      if not IsValidRow(NewBottomRow + 1) then
         DeleteRect:= True
      else 
         Rect.RowFrom:= NewBottomRow + 1;
    end;

    { shifting may erase a rect }
    if (not Transformed)
      and ( (     (ADestTopRow <= Rect.RowFrom) and (Rect.RowFrom <= ATopRow)
              and (ADestTopRow <= Rect.RowTo) and (Rect.RowTo <= ATopRow)
            )
            or
            (     (ATopRow <= Rect.RowFrom) and (Rect.RowFrom <= ADestTopRow)
              and (ATopRow <= Rect.RowTo) and (Rect.RowTo <= ADestTopRow)
            )
          )  
      then DeleteRect:= True;

    { finally delete or change the Rect }
    if DeleteRect or (Rect.RowFrom > Rect.RowTo) then
      Rects.DeleteRect(RectInd)
    else
      Rects.SetRect(RectInd, Rect.RowFrom, Rect.RowTo, Rect.ColumnFrom, Rect.ColumnTo);

  end;
end;

procedure RangeRectsApplyColumnsShift(var Rects: TRangeRects; const ALeftColumn, ARightColumn: Byte;
  const ADestLeftColumn: Byte);
var
  RectInd: Integer;
  Rect: TRangeRect;
  DeleteRect: Boolean;
  Transformed: Boolean;
begin
  for RectInd:= Rects.RectsCount - 1 downto 0 do
  begin
    Rect:= Rects.Rect[RectInd];
    DeleteRect:= False;
    Transformed:= False;

    if (Rect.ColumnFrom >= ALeftColumn) and (Rect.ColumnFrom <= ARightColumn) then
    begin
      if (Integer(Rect.ColumnFrom + (ADestLeftColumn - ALeftColumn)) < 0) then
        Rect.ColumnFrom:= 0
      else
      if (Integer(Rect.ColumnFrom + (ADestLeftColumn - ALeftColumn)) > BIFF8_MAXCOLS - 1) then
        {if top Column become more than max Column - then delete this rect}
        DeleteRect:= True
      else
        Rect.ColumnFrom:= Rect.ColumnFrom + (ADestLeftColumn - ALeftColumn);

      Transformed:= True;
    end;

    if (Rect.ColumnTo >= ALeftColumn) and (Rect.ColumnTo <= ARightColumn) then
    begin
      {if bottom Column become less than min Column - then delete this rect}
      if (Integer(Rect.ColumnTo + (ADestLeftColumn - ALeftColumn)) < 0) then
        DeleteRect:= True
      else
      if (Integer(Rect.ColumnTo + (ADestLeftColumn - ALeftColumn)) > BIFF8_MAXCOLS - 1) then
        Rect.ColumnTo:= BIFF8_MAXCOLS - 1
      else
        Rect.ColumnTo:= Rect.ColumnTo + (ADestLeftColumn - ALeftColumn);

      Transformed:= True;
    end;

    if (not Transformed)
       and (Rect.ColumnFrom <= Integer(ALeftColumn + (ADestLeftColumn - ALeftColumn)))
       and (Rect.ColumnTo   >= Integer(ALeftColumn + (ADestLeftColumn - ALeftColumn)))  then
    begin
      if not IsValidColumn(Integer(ALeftColumn + (ADestLeftColumn - ALeftColumn) -1 )) then
         DeleteRect:= True
      else
         Rect.ColumnTo:= ALeftColumn + (ADestLeftColumn - ALeftColumn) - 1;
    end;

    if (not Transformed)
       and (Rect.ColumnFrom <= Integer(ARightColumn + (ADestLeftColumn - ALeftColumn)))
       and (Rect.ColumnTo   >= Integer(ARightColumn + (ADestLeftColumn - ALeftColumn)))  then
    begin
      if not IsValidColumn(Integer(ARightColumn + (ADestLeftColumn - ALeftColumn) + 1 )) then
         DeleteRect:= True
      else 
         Rect.ColumnFrom:= ARightColumn + (ADestLeftColumn - ALeftColumn) + 1;
    end;

    { shifting may erase a rect }
    if (not Transformed)
      and ( (     (ADestLeftColumn <= Rect.ColumnFrom) and (Rect.ColumnFrom <= ALeftColumn)
              and (ADestLeftColumn <= Rect.ColumnTo) and (Rect.ColumnTo <= ALeftColumn)
            )
            or
            (     (ALeftColumn <= Rect.ColumnFrom) and (Rect.ColumnFrom <= ADestLeftColumn)
              and (ALeftColumn <= Rect.ColumnTo) and (Rect.ColumnTo <= ADestLeftColumn)
            )
          )  
      then DeleteRect:= True;
      
    { finally delete or change the Rect }
    if DeleteRect or (Rect.ColumnFrom > Rect.ColumnTo) then
      Rects.DeleteRect(RectInd)
    else
      Rects.SetRect(RectInd, Rect.RowFrom, Rect.RowTo, Rect.ColumnFrom, Rect.ColumnTo);
  end;
end;

function RectContainsInRect(
  const ALeftColumn, ARightColumn, ATopRow, ABottomRow: Integer;
  const InLeftColumn, InRightColumn, InTopRow, InBottomRow: Integer): Boolean;
begin
  Result:= ( (InLeftColumn <= ALeftColumn) and (ALeftColumn <= InRightColumn)
         and (InLeftColumn <= ARightColumn) and (ARightColumn <= InRightColumn)
         and (InTopRow <= ATopRow) and (ATopRow <= InBottomRow)
         and (InTopRow <= ABottomRow) and (ABottomRow <= InBottomRow)
         );
end;

function RangeRectContainsInRect(
  ARect: TRangeRect;
  const InLeftColumn, InRightColumn, InTopRow, InBottomRow: Integer): Boolean;
begin
  Result:= RectContainsInRect(
      ARect.RowFrom, ARect.RowTo, ARect.ColumnFrom, ARect.ColumnTo
    , InLeftColumn, InRightColumn, InTopRow, InBottomRow
    );
end;

{TCellCoords}
constructor TCellCoords.Create;
begin
  FItems:= TList.Create;
end;

destructor TCellCoords.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FItems.Count - 1 do
    if Assigned(FItems[I]) then
      FreeMem(PCellCoord(FItems[I]));
  FItems.Destroy;
  inherited;
end;

function TCellCoords.GetItem(Ind: Integer): TCellCoord;
begin
  Result:= PCellCoord(FItems[Ind])^;
end;

function TCellCoords.GetItemsCount: Integer;
begin
  Result:= FItems.Count;
end;

procedure TCellCoords.Add(Row: Word; Column: Byte);
var
  P: PCellCoord;
begin
  New(P);
  P^.Row:= Row;
  P^.Column:= Column;
  FItems.Add(P);
end;

procedure TCellCoords.Remove(Ind: Integer);
begin
  if Assigned(FItems[Ind]) then
    FreeMem(PCellCoord(FItems[Ind]));
  FItems.Delete(Ind);
end;

procedure TCellCoords.AddCellCoords(ACellCoords: TCellCoords);
var
  I: Integer;
begin
  for I:= 0 to ACellCoords.ItemsCount - 1 do
    Add(ACellCoords.Item[I].Row, ACellCoords.Item[I].Column);
end;

{TRangeRects}
constructor TRangeRects.Create;
begin
  FRects:= TList.Create;
end;

destructor TRangeRects.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FRects.Count-1 do
    FreeMem(PRangeRect(FRects[I]));
  FRects.Destroy;
  inherited;
end;

procedure TRangeRects.AddRect(const ARowFrom, ARowTo: Word; AColumnFrom, AColumnTo: Byte);
var
  P: PRangeRect;
begin
  New(P);
  P^.RowFrom:= ARowFrom;
  P^.RowTo:= ARowTo;
  P^.ColumnFrom:= AColumnFrom;
  P^.ColumnTo:= AColumnTo;
  FRects.Add(P);
end;

procedure TRangeRects.AddRectRec(const ARect: TRangeRect);
var
  P: PRangeRect;
begin
  New(P);
  P^ := ARect;
  FRects.Add(P);
end;

procedure TRangeRects.AddRangeRects(ARangeRects: TRangeRects);
var
  I: Integer;
begin
  for I:= 0 to ARangeRects.RectsCount - 1 do
    AddRectRec(ARangeRects.Rect[I]);
end;

function TRangeRects.GetRect(Ind: Integer): TRangeRect;
begin
  Result:= PRangeRect(FRects[Ind])^;
end;

function TRangeRects.GetRectsCount: Integer;
begin
  Result:= FRects.Count;
end;

procedure TRangeRects.SetRect(const Ind: Integer;
  const ARowFrom, ARowTo: Word; AColumnFrom, AColumnTo: Byte);
begin
  with PRangeRect(FRects[Ind])^ do
  begin
    RowFrom:= ARowFrom;
    RowTo:= ARowTo;
    ColumnFrom:= AColumnFrom;
    ColumnTo:= AColumnTo;
  end;
end;

function TRangeRects.FindRectContainingCellCoord(const ARow: Word;
  const AColumn: Byte; var ARect: TRangeRect): Boolean;
var
  I: Integer;
begin
  Result:= False;

  for I:= 0 to FRects.Count - 1 do
    if IsCellCoordInRect(ARow, AColumn, PRangeRect(FRects[I])^) then
    begin
      ARect:= PRangeRect(FRects[I])^;
      Result:= True;
    end;
end;

procedure TRangeRects.DeleteRect(const Ind: Integer);
begin
  if (Ind >=0) and (Ind < FRects.Count) then
    FRects.Delete(Ind);
end;

procedure TRangeRects.InternalShift(const ATopRow, ABottomRow, ALeftColumn, ARightColumn
      , ADestTopRow, ADestLeftColumn: Integer; const MoveCells: Boolean);
var
  RectInd: Integer;
  NewTopRow, NewBottomRow, NewLeftColumn, NewRightColumn: Integer;
  NewRectIsValid: Boolean;

  function GetNewRect: Boolean;
  begin
    Result:= True;

    NewTopRow:= Rect[RectInd].RowFrom - (ATopRow - ADestTopRow);
    if NewTopRow < 0 then NewTopRow:= 0;
    if NewTopRow > (BIFF8_MAXROWS - 1) then
    begin
      Result:= False;
      Exit;
    end;

    NewBottomRow:= Rect[RectInd].RowTo - (ATopRow - ADestTopRow);
    if NewBottomRow < 0 then
    begin
      Result:= False;
      Exit;
    end;
    if NewBottomRow > (BIFF8_MAXROWS - 1) then NewBottomRow:= BIFF8_MAXROWS - 1;

    NewLeftColumn:= Rect[RectInd].ColumnFrom - (ALeftColumn - ADestLeftColumn);
    if NewLeftColumn < 0 then NewLeftColumn:= 0;
    if NewLeftColumn > (BIFF8_MAXCOLS - 1) then
    begin
      Result:= False;
      Exit;
    end;

    NewRightColumn:= Rect[RectInd].ColumnTo - (ALeftColumn - ADestLeftColumn);
    if NewRightColumn < 0 then
    begin
      Result:= False;
      Exit;
    end;
    if NewRightColumn > (BIFF8_MAXCOLS - 1) then  NewRightColumn:= BIFF8_MAXCOLS - 1;
  end;

begin
  for RectInd:= Self.RectsCount - 1 downto 0 do
  begin
    if RangeRectContainsInRect(Self.Rect[RectInd]
        , ATopRow, ABottomRow, ALeftColumn, ARightColumn) then
    begin
      NewRectIsValid:= GetNewRect;

      if MoveCells then
      begin
        if NewRectIsValid then
          Self.SetRect(RectInd, NewTopRow, NewBottomRow, NewLeftColumn, NewRightColumn)
        else
          Self.DeleteRect(RectInd);
      end
      else
        if NewRectIsValid then
          Self.AddRect(NewTopRow, NewBottomRow, NewLeftColumn, NewRightColumn);
    end;
  end;
end;

end.
