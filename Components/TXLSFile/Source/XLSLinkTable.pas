unit XLSLinkTable;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4.0
    Link table

    Rev history:
    2008-04-21  Link table started
    2008-09-27  Add: Bloomberg API names support added

-----------------------------------------------------------------}

{$I XLSFile.inc}

interface

uses Classes
   , XLSRects
   , XLSBase
   , XLSError
   , Lists;

type
  PWord = ^Word;
  PByte = ^Byte;
  
  { Link type }
  TXLSLinkType =
    ( tlUnknown
    , tlLocalRef
    , tlLocalRect
    , tl3dRef
    , tl3dRect
    , tlSheet
    , tlName
    , tlExternalName
    , tlExternal3dRef
    , tlExternal3dRect
    );

  { Indices types }
  TXLSLinkTableRef = Word;
  TXLSSheetIndex = Word;
  TXLSNameIndex = Word;
  TXLSDocumentIndex = Word;

  { Built-in names }
  TXLSBuiltInName =
    ( binNoName
    , binConsolidateArea
    , binAutoOpen
    , binAutoClose
    , binExtract
    , binDatabase
    , binCriteria
    , binPrintArea
    , binPrintTitles
    , binRecorder
    , binDataForm
    , binAutoActivate
    , binAutoDeactivate
    , binSheetTitle
    , binFilterDatabase
    );
    
  { TXLSLinkName }
  TXLSLinkName = class
  protected
    FName: WideString;
    FSheetIndex: TXLSSheetIndex;
    FArea: TRangeRects;
    FBuiltInName: TXLSBuiltInName;
    FRawData: AnsiString;
  public
    constructor Create;
    destructor Destroy; override;
    property Area: TRangeRects read FArea;
    property Name: WideString read FName write FName;
    property BuiltInName: TXLSBuiltInName read FBuiltInName write FBuiltInName;
    property SheetIndex: TXLSSheetIndex read FSheetIndex write FSheetIndex;
    property RawData: AnsiString read FRawData;
  end;

  { TXLSLinkParameters }
  TXLSLinkParameters = packed record
    LinkText: WideString;
    LinkType: TXLSLinkType;
    ExternSheetIndex: TXLSLinkTableRef;
    RowFrom, RowTo: Word;
    ColumnFrom, ColumnTo: Byte;
    RowFromIsAbsolute   : Boolean;
    RowToIsAbsolute     : Boolean;
    ColumnFromIsAbsolute: Boolean;
    ColumnToIsAbsolute  : Boolean;
    NameIndex: TXLSNameIndex;
  end;
  PXLSLinkParameters = ^TXLSLinkParameters;

  { TXLSLinkDocument }
  TXLSLinkDocument = class
  protected
    FDocumentName: WideString;
    FSheetNames: TAnsiStringList;
    FNames: TList;
    FIsLocal: Boolean;
    FIsAddin: Boolean;
    FRawData: AnsiString;
    function GetName(Index: Integer): TXLSLinkName;
    function GetNamesCount: Integer;
    function GetSheetName(Index: Integer): WideString;
    function GetSheetsCount: Integer;
    function GetIsExternal: Boolean;
    function GetNameArea(Index: Integer): WideString;
  public
    constructor Create;
    destructor Destroy; override;

    function GetNameIndex(const Name: WideString): TXLSNameIndex;
    function GetSheetIndex(const SheetName: WideString): TXLSSheetIndex;
    procedure AddNameObject(const NewName: TXLSLinkName);
    procedure AddName(const Name: WideString; const Area: TRangeRects;
      const BuiltInName: TXLSBuiltInName;
      const SheetIndex: TXLSSheetIndex);
    procedure AddSheetName(const SheetName: WideString);
    procedure ClearData;

    property Name[Index: Integer]: TXLSLinkName read GetName;
    property NameArea[Index: Integer]: WideString read GetNameArea;
    property NamesCount: Integer read GetNamesCount;
    property SheetName[Index: Integer]: WideString read GetSheetName;
    property SheetsCount: Integer read GetSheetsCount;
    property DocumentName: WideString read FDocumentName write FDocumentName;
    property RawData: AnsiString read FRawData;
    property IsLocal: Boolean read FIsLocal;
    property IsAddin: Boolean read FIsAddin write FIsAddin;
    property IsExternal: Boolean read GetIsExternal;
  end;

  { TLinkTableItem }
  TLinkTableItem = packed record
    Document: TXLSDocumentIndex;
    SheetFrom: TXLSSheetIndex;
    SheetTo: TXLSSheetIndex;
  end;
  PLinkTableItem = ^TLinkTableItem;

  {TXLSLinkTable}
  TXLSLinkTable = class
  protected
    FXLSLinkDocuments: TList; { list of TXLSLinkDocument }
    FLinkTableItems: TList;   { list of PLinkTableItem }
    FLocalDocument: TXLSLinkDocument;

    function GetDocument(Index: Integer): TXLSLinkDocument;
    function GetDocumentsCount: Integer;
    function GetItem(Index: Integer): PLinkTableItem;
    function GetItemsCount: Integer;
    function GetLocalDocumentIndex: TXLSDocumentIndex;

    { Parse help functions }
    function ParseCell(const ARef: AnsiString; var ALinkParam: TXLSLinkParameters): Boolean;
    function ParseArea(const ARef: AnsiString; var ALinkParam: TXLSLinkParameters): Boolean;
    function ParseSheetPart(const ARef: WideString; var XTIIndex: TXLSLinkTableRef): Boolean;
    function ParseExternalSheetPart(const ARef: WideString; var XTIIndex: TXLSLinkTableRef): Boolean;
    function ParseDocumentName(const ARef: WideString): TXLSDocumentIndex;
    function Parse3DCell(const ARef: WideString; var ALinkParam: TXLSLinkParameters): Boolean;
    function Parse3DArea(const ARef: WideString; var ALinkParam: TXLSLinkParameters): Boolean;
    function ParseName(const ARef: WideString; var ALinkParam: TXLSLinkParameters): Boolean;
    function ParseExternalCell(const ARef: WideString; var ALinkParam: TXLSLinkParameters): Boolean;
    function ParseExternalArea(const ARef: WideString; var ALinkParam: TXLSLinkParameters): Boolean;
    function ParseExternalName(const ARef: WideString; var ALinkParam: TXLSLinkParameters): Boolean;        

    function GetSheetExternsheetIndex(const ASheetName: WideString): TXLSLinkTableRef;
    function Get2SheetsExternsheetIndex(const ASheetName1: WideString;
      ASheetName2: WideString): TXLSLinkTableRef;
    function FindExternsheetIndex(const DocumentIndex: TXLSDocumentIndex;
      const SheetFrom: TXLSSheetIndex; const SheetTo: TXLSSheetIndex;
      const ForceAddItem: Boolean): TXLSLinkTableRef;

  public
    constructor Create;
    destructor Destroy; override;

    { Procedures for reading XLS file }
    procedure AddSupbook(const SupbookRawData: AnsiString);
    procedure AddExternname(const ExternnameRawData: AnsiString);
    procedure AddName(const NameRawData: AnsiString);
    procedure AddExternsheet(const ExternsheetRawData: AnsiString);
    procedure ClearLocalDocumentData;
    procedure AddLocalSheetIndexes;
    procedure Clear;

    { Methods for writing XLS file }
    function GetSupbookData(const DocumentIndex: TXLSDocumentIndex): AnsiString;
    function GetExternalNameData(const DocumentIndex: TXLSDocumentIndex;
      const NameIndex: TXLSNameIndex): AnsiString;
    function GetExternsheetData: AnsiString;
    function GetNameData(const NameIndex: TXLSNameIndex): AnsiString;

    { Methods for formula's parsing }
    function ParseLinkText(var Link: TXLSLinkParameters): Boolean;
    function CompileLinkText(var Link: TXLSLinkParameters): Boolean;
    function ParseNameData(var Name: TXLSLinkName): Boolean;

    { Properties }
    property LocalDocument: TXLSLinkDocument read FLocalDocument;
    property LocalDocumentIndex: TXLSDocumentIndex read GetLocalDocumentIndex;
    property Document[Index: Integer]: TXLSLinkDocument read GetDocument;
    property DocumentsCount: Integer read GetDocumentsCount;
    property Item[Index: Integer]:PLinkTableItem read GetItem;
    property ItemsCount: Integer read GetItemsCount;
  end;


implementation

uses SysUtils
   , Unicode
   , Streams
   , XLSStrUtil
   , XLSFormula
   {$IFDEF XLF_D2009}
   , AnsiStrings
   {$ENDIF}
   ;

const
  XLT_ITEM_NOTFOUND = Word($FFFF);
  XLT_EXTNAME_SHEETINDEX = Word($FFFE);

{ Help functions }
function DecodeDocumentName(const DocumentName: AnsiString; IsUnicode: Boolean): WideString;
var
  IsEncoded: Boolean;
  S: AnsiString;
  WS: WideString;
  I: Integer;
begin
  if (Trim(String(DocumentName)) = '') then
  begin
    Result := '';
    Exit;
  end;

  if not IsUnicode then
  begin
    S:= DocumentName;
    IsEncoded:= (S[1] = #1);

    if not IsEncoded then
    begin
      { Make some conversions and exit }

      { Bloomberg encoded names }
      {$IFDEF XLF_D2009}
      S:= AnsiStrings.StringReplace(S, #3, '|', [rfReplaceAll]);
      {$ELSE}
      S:= StringReplace(S, #3, '|', [rfReplaceAll]);
      {$ENDIF}

      Result:= WideString(S);
      Exit;
    end;

    S:= Copy(S, 2, Length(S) - 1);

    I:= 1;
    while I<= Length(S) do
    begin
      if (S[I] = #3) or (S[I] = #2) then S[I]:= '\';

      if (S[I] = #1) then
      begin
        if (S[I + 1] <> '@') then
        begin
          { Disk char }
          S[I]:= S[I + 1];
          S[I + 1]:= ':';
          if ((I + 1) < Length(S)) then
            S:= Copy(S, 1, I + 1) + '\' + Copy(S, I + 2, Length(S));
        end
        else
        begin
          S[I]:= '\';
          S[I + 1]:= '\';
        end;
      end;

      I:= I + 1;
    end;

    { Trim right slash }
    if (S[Length(S)] = '\') then
      S:= Copy(S, 1, Length(S) - 1);

    Result:= StringToWideString(S);
  end
  else
  begin
    WS:= ANSIWideStringToWideString(DocumentName);
    IsEncoded:= (WS[1] = #1);

    if not IsEncoded then
    begin
      Result:= WS;
      Exit;
    end;

    WS:= Copy(WS, 2, Length(WS) - 1);

    I:= 1;
    while I<= Length(WS) do
    begin
      if (WS[I] = #3) or (WS[I] = #2) then WS[I]:= '\';

      if (WS[I] = #1) then
      begin
        if (WS[I + 1] <> '@') then
        begin
          { Disk char }
          WS[I]:= WS[I + 1];
          WS[I + 1]:= ':';
          if ((I + 1) < Length(WS)) then
            WS:= Copy(WS, 1, I + 1) + '\' + Copy(WS, I + 2, Length(WS));
        end
        else
        begin
          WS[I]:= '\';
          WS[I+1]:= '\';
        end;
      end;

      I:= I + 1;
    end;

    { Trim right slash }
    if (WS[Length(WS)] = '\') then
      WS:= Copy(WS, 1, Length(WS) - 1);

    Result:= WS;
  end;
end;

function EncodeDocumentName(const DocumentName: WideString): AnsiString;
var
  WS: WideString;
  DoEncode: Boolean;
begin
  DoEncode:= True;
  WS:= Trim(DocumentName);
  WS:= WideStringReplace(WS, '\\', #1'@');
  WS:= WideStringReplace(WS, '\', #3);

  { Disk char }
  if (Length(WS) >= 2) then
    if (WS[2] = ':') then
    begin
      WS[2]:= WS[1];
      WS[1]:= #1;
      if (Length(WS) >=3) then
      begin
        { remove slash after disk char }
        if (WS[3] = #3) then
          WS:= Copy(WS, 1, 2) + Copy(WS, 4, Length(WS) - 3);
      end;
    end;

  { Some Bloomberg encodings }
  if Pos('|', WS) > 0 then
  begin
    DoEncode:= False;
    WS:= WideStringReplace(WS, '|', #03);
  end;

  if DoEncode then
    Result:= #1#0 + WideStringToANSIWideString(WS)
  else
    Result:= WideStringToANSIWideString(WS);
end;

function BuiltInNameByCode(const Code: TXLSBuiltInName): WideString;
begin
  case Code of
    binConsolidateArea : Result:= 'Consolidate_Area';
    binAutoOpen        : Result:= 'Auto_Open';
    binAutoClose       : Result:= 'Auto_Close';
    binExtract         : Result:= 'Extract';
    binDatabase        : Result:= 'Database';
    binCriteria        : Result:= 'Criteria';
    binPrintArea       : Result:= 'Print_Area';
    binPrintTitles     : Result:= 'Print_Titles';
    binRecorder        : Result:= 'Recorder';
    binDataForm        : Result:= 'Data_From';
    binAutoActivate    : Result:= 'Auto_Activate';
    binAutoDeactivate  : Result:= 'Auto_Deactivate';
    binSheetTitle      : Result:= 'Sheet_Title';
    binFilterDatabase  : Result:= '_FilterDatabase';
    else                 Result:= '';
  end;
end;

function BuiltInDataByCode(const Code: TXLSBuiltInName): Byte;
begin
  case Code of
    binConsolidateArea : Result:= 0;
    binAutoOpen        : Result:= 1;
    binAutoClose       : Result:= 2;
    binExtract         : Result:= 3;
    binDatabase        : Result:= 4;
    binCriteria        : Result:= 5;
    binPrintArea       : Result:= 6;
    binPrintTitles     : Result:= 7;
    binRecorder        : Result:= 8;
    binDataForm        : Result:= 9;
    binAutoActivate    : Result:= 10;
    binAutoDeactivate  : Result:= 11;
    binSheetTitle      : Result:= 12;
    binFilterDatabase  : Result:= 13;
    else Result:= $FF;
  end;
end;

{ TXLSLinkName }
constructor TXLSLinkName.Create;
begin
  FArea:= TRangeRects.Create;
  FSheetIndex:= 0;
  FBuiltInName:= binNoName;
  FName:= '';
  FRawData:= '';
end;

destructor TXLSLinkName.Destroy;
begin
  FArea.Destroy;
  inherited;
end;

{ TXLSLinkDocument }
constructor TXLSLinkDocument.Create;
begin
  FDocumentName:= '';
  FIsLocal:= False;
  FIsAddin:= False;
  FSheetNames:= TAnsiStringList.Create;
  FNames:= TList.Create;
  FRawData:= ''
end;

destructor TXLSLinkDocument.Destroy;
var
  I: Integer;
begin
  FSheetNames.Destroy;

  for I:= 0 to FNames.Count - 1 do
    TXLSLinkName(FNames[I]).Destroy;

  FNames.Destroy;
  inherited;
end;

function TXLSLinkDocument.GetName(Index: Integer): TXLSLinkName;
begin
  Result:= TXLSLinkName(FNames[Index]);
end;

function TXLSLinkDocument.GetNameArea(Index: Integer): WideString;
var
  AName: TXLSLinkName;
  TotalAreaText, AreaText, SheetName: WideString;
  R: TRangeRect;
  RectIndex: Integer;
begin
  Result:= '';
  AreaText:= '';
  TotalAreaText:= '';
  SheetName:= '';

  AName:= TXLSLinkName(FNames[Index]);

  { Get sheet name }
  if AName.SheetIndex < Self.SheetsCount then
    SheetName:= Self.SheetName[AName.SheetIndex];

  { Get rects }
  for RectIndex:= 0 to AName.Area.RectsCount - 1 do
  begin
    R:= AName.Area.Rect[RectIndex];
    AreaText:= WideString(RectToText(R));

    if AreaText <> '' then
    begin
      if SheetName <> '' then
        AreaText:= '''' + SheetName + '''' + '!' + AreaText;

      if TotalAreaText <> '' then TotalAreaText:= TotalAreaText + ',';
      TotalAreaText:= TotalAreaText + AreaText;
    end;
  end;
  
  Result:= TotalAreaText;
end;

function TXLSLinkDocument.GetNamesCount: Integer;
begin
  Result:= FNames.Count;
end;

function TXLSLinkDocument.GetSheetName(Index: Integer): WideString;
begin
  Result:= ANSIWideStringToWideString(FSheetNames[Index]);
end;

function TXLSLinkDocument.GetSheetsCount: Integer;
begin
  Result:= FSheetNames.Count;
end;

procedure TXLSLinkDocument.AddNameObject(const NewName: TXLSLinkName);
begin
  FNames.Add(NewName);
end;

procedure TXLSLinkDocument.AddName(const Name: WideString; const Area: TRangeRects;
      const BuiltInName: TXLSBuiltInName;
      const SheetIndex: TXLSSheetIndex);
var
  NewName: TXLSLinkName;
begin
  NewName:= TXLSLinkName.Create;
  NewName.BuiltInName:= BuiltInName;
  if (BuiltInName <> binNoName) then
    NewName.Name:=  BuiltInNameByCode(BuiltInName)
  else
    NewName.Name:= Name;

  NewName.SheetIndex:= SheetIndex;
  if Assigned(Area) then
    NewName.Area.AddRangeRects(Area);
  FNames.Add(NewName);
end;

procedure TXLSLinkDocument.AddSheetName(const SheetName: WideString);
var
  S: AnsiString;
begin
  S:= WideStringToANSIWideString(SheetName);
  if (FSheetNames.IndexOf(S) < 0) then
    FSheetNames.Add(S);
end;

function TXLSLinkDocument.GetNameIndex(const Name: WideString): TXLSNameIndex;
var
  I: Integer;
begin
  Result:= XLT_ITEM_NOTFOUND;
  for I:= 0 to FNames.Count - 1 do
    if (TXLSLinkName(FNames[I]).Name = Name) then
    begin
      Result:= I;
      Exit;
    end;
end;

function TXLSLinkDocument.GetSheetIndex(const SheetName: WideString): TXLSSheetIndex;
var
  S: AnsiString;
  I: Integer;
begin
  S:= WideStringToANSIWideString(SheetName);
  I:= FSheetNames.IndexOf(S);

  if (I>= 0) then
    Result:= I
  else
    Result:= XLT_ITEM_NOTFOUND;    
end;

procedure TXLSLinkDocument.ClearData;
var
  I: Integer;
begin
  { Destroy }
  FSheetNames.Destroy;

  for I:= 0 to FNames.Count - 1 do
    TXLSLinkName(FNames[I]).Destroy;

  FNames.Destroy;

  { Create new }
  FDocumentName:= '';
  FIsLocal:= False;
  FSheetNames:= TAnsiStringList.Create;
  FNames:= TList.Create;
end;

function TXLSLinkDocument.GetIsExternal: Boolean;
begin
  Result:= (not FIsLocal) and (not FIsAddin);
end;

{ TXLSLinkTable }
constructor TXLSLinkTable.Create;
begin
  FXLSLinkDocuments:= TList.Create;
  FLinkTableItems:= TList.Create;

  { Add local document }
  FLocalDocument:= TXLSLinkDocument.Create;
  FLocalDocument.FIsLocal:= True;
  FXLSLinkDocuments.Add(Pointer(FLocalDocument));
end;

destructor TXLSLinkTable.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FXLSLinkDocuments.Count - 1 do
    TXLSLinkDocument(FXLSLinkDocuments[I]).Destroy;
  FXLSLinkDocuments.Destroy;

  for I:= 0 to FLinkTableItems.Count - 1 do
    Dispose(PLinkTableItem(FLinkTableItems[I]));
  FLinkTableItems.Destroy;

  inherited;
end;

procedure TXLSLinkTable.Clear;
var
  I: Integer;
begin
  { Destroy }
  for I:= 0 to FXLSLinkDocuments.Count - 1 do
    TXLSLinkDocument(FXLSLinkDocuments[I]).Destroy;
  FXLSLinkDocuments.Destroy;

  for I:= 0 to FLinkTableItems.Count - 1 do
    Dispose(PLinkTableItem(FLinkTableItems[I]));
  FLinkTableItems.Destroy;

  { Re-create }
  FXLSLinkDocuments:= TList.Create;
  FLinkTableItems:= TList.Create;

  { Add local document }
  FLocalDocument:= TXLSLinkDocument.Create;
  FLocalDocument.FIsLocal:= True;
  FXLSLinkDocuments.Add(Pointer(FLocalDocument));
end;

function TXLSLinkTable.GetLocalDocumentIndex: TXLSDocumentIndex;
var
  I: Integer;
begin
  Result:= XLT_ITEM_NOTFOUND;
  for I:= 0 to DocumentsCount - 1 do
    if (Document[I] = LocalDocument) then
    begin
      Result:= I;
      Exit;
    end;
end;

procedure TXLSLinkTable.AddLocalSheetIndexes;
var
  SheetIndex: TXLSSheetIndex;
  DocumentIndex: TXLSDocumentIndex;
begin
  DocumentIndex:= LocalDocumentIndex;

  for SheetIndex:= 0 to LocalDocument.SheetsCount - 1 do
    FindExternsheetIndex(DocumentIndex, SheetIndex, SheetIndex, True);
end;

function TXLSLinkTable.GetDocument(Index: Integer): TXLSLinkDocument;
begin
  Result:= TXLSLinkDocument(FXLSLinkDocuments[Index]);
end;

function TXLSLinkTable.GetDocumentsCount: Integer;
begin
  Result:= FXLSLinkDocuments.Count;
end;

function TXLSLinkTable.GetItem(Index: Integer): PLinkTableItem;
begin
  Result:= PLinkTableItem(FLinkTableItems[Index]);
end;

function TXLSLinkTable.GetItemsCount: Integer;
begin
  Result:= FLinkTableItems.Count;
end;

procedure TXLSLinkTable.ClearLocalDocumentData;
begin
  FLocalDocument.ClearData;
  FLocalDocument.FIsLocal:= True;
end;

procedure TXLSLinkTable.AddSupbook(const SupbookRawData: AnsiString);
var
  S, DocumentEncodedName: AnsiString;
  IsUnicode: Boolean;
  DocumentName: WideString;
  SheetName: WideString;
  SheetsCount: Word;
  W: Word;
  NewDocument: TXLSLinkDocument;
  I: Integer;
begin
  Move(SupbookRawData[1], SheetsCount, 2);
  S:= Copy(SupbookRawData, 3, Length(SupbookRawData) - 2);

  { If local document }
  if (S = #01#04) then
  begin
    { Move local document to current position in list.
      Currently it is 1st. }
    for I:= 0 to FXLSLinkDocuments.Count - 2 do
      FXLSLinkDocuments[I]:= FXLSLinkDocuments[I+1];

    FXLSLinkDocuments[FXLSLinkDocuments.Count - 1]:= LocalDocument;
    Exit;
  end;

  { New document }
  NewDocument:= TXLSLinkDocument.Create;
  FXLSLinkDocuments.Add(NewDocument);
  NewDocument.FRawData:= SupbookRawData;

  { If add-in }
  if (S = #01#$3A) then
  begin
    NewDocument.DocumentName:= '';
    NewDocument.IsAddin:= True;
    Exit;
  end;

  { Get document name }
  Move(S[1], W, 2);
  IsUnicode:= (S[3] = #01);
  if IsUnicode then
  begin
    DocumentEncodedName:= Copy(S, 4, W * 2);
    S:= Copy(S, 4 + W * 2, Length(S));
  end
  else
  begin
    DocumentEncodedName:= Copy(S, 4, W);
    S:= Copy(S, 4 + W, Length(S));
  end;
  DocumentName:= DecodeDocumentName(DocumentEncodedName, IsUnicode);
  NewDocument.DocumentName:= DocumentName;

  { Sheet names }
  while (S <> '') do
  begin
    Move(S[1], W, 2);
    IsUnicode:= (S[3] = #01);
    SetLength(SheetName, W);

    if IsUnicode then
    begin
      Move(S[4], SheetName[1], W * 2);
      S:= Copy(S, 4 + W * 2, Length(S));
    end
    else
    begin
      SheetName:= StringToWideSTring(Copy(S, 4, W));
      S:= Copy(S, 4 + W, Length(S));
    end;

    NewDocument.AddSheetName(SheetName);
  end;
end;

procedure TXLSLinkTable.AddExternname(const ExternnameRawData: AnsiString);
var
  NewName: TXLSLinkName;
  Document: TXLSLinkDocument;
  W: Word;
  NameLength: Integer;
  IsUnicode: Boolean;
  S: AnsiString;
begin
  { Link table must contain documents: 1 local and >=1 externals }
  if (FXLSLinkDocuments.Count < 2 ) then
    raise EXLSError.Create(EXLS_INVALIDLINKTABLE);

  { Add new name object to last document }
  Document:= TXLSLinkDocument(FXLSLinkDocuments[FXLSLinkDocuments.Count - 1]);
  NewName:= TXLSLinkName.Create;
  Document.FNames.Add(NewName);
  NewName.FRawData:= ExternnameRawData;

  { Parse name data }
  Move(ExternnameRawData[3], W, 2);
  NewName.SheetIndex:= W;

  NameLength:= Byte(ExternnameRawData[7]);
  IsUnicode:= (ExternnameRawData[8] = #1);

  if IsUnicode then
  begin
    S:= Copy(ExternnameRawData, 9, NameLength * 2);
    NewName.Name:= ANSIWideStringToWideString(S);
  end
  else
  begin
    S:= Copy(ExternnameRawData, 9, NameLength);
    NewName.Name:= StringToWideString(S);
  end;  
end;

function TXLSLinkTable.ParseNameData(var Name: TXLSLinkName): Boolean;
var
  Options: Word;
  NameLength: Byte;
  NameDefLength: Word;
  UnicodeFlag: Byte;
  Position: Integer;
  RectCount: Integer;
  NameDef, S: AnsiString;
  IsBuiltIn: Boolean;
  BuiltInCode: Byte;
  Ptg: Byte;
  RectDefLen: Integer;
  RowFrom, RowTo: Integer;
  ColumnFrom, ColumnTo: Integer;
  XTIIndex: Word;
  ASheetIndex: Integer;
begin
  Result:= False;

  if (Name.RawData = '') then Exit;

  Options:= (PWord(@(Name.RawData[1])))^;

  { Accept only built-in and user-defined ranges }
  if not ((Options = 0) or (Options = $20)) then
    Exit;

  IsBuiltIn:= ((Options and $20) <> 0);

  NameLength:= (PByte(@(Name.RawData[4])))^;
  NameDefLength:= (PWord(@(Name.RawData[5])))^;

  Name.FSheetIndex:= XLT_ITEM_NOTFOUND;

  { Name text }
  UnicodeFlag:= (PByte(@(Name.RawData[15])))^;

  if IsBuiltIn then
  begin
    BuiltInCode:= Byte(Name.RawData[16]);

    case BuiltInCode of
      0  : Name.FBuiltInName:= binConsolidateArea;
      1  : Name.FBuiltInName:= binAutoOpen;
      2  : Name.FBuiltInName:= binAutoClose;
      3  : Name.FBuiltInName:= binExtract;
      4  : Name.FBuiltInName:= binDatabase;
      5  : Name.FBuiltInName:= binCriteria;
      6  : Name.FBuiltInName:= binPrintArea;
      7  : Name.FBuiltInName:= binPrintTitles;
      8  : Name.FBuiltInName:= binRecorder;
      9  : Name.FBuiltInName:= binDataForm;
      10 : Name.FBuiltInName:= binAutoActivate;
      11 : Name.FBuiltInName:= binAutoDeactivate;
      12 : Name.FBuiltInName:= binSheetTitle;
      13 : Name.FBuiltInName:= binFilterDatabase;
      else Name.FBuiltInName:= binNoName;
    end;
  end;

  if UnicodeFlag = 1 then
  begin
    NameLength:= NameLength * 2;
    S:= Copy(Name.RawData, 16, NameLength);
    Name.FName:= ANSIWideStringToWideString(S);
  end
  else
  begin
    S:= Copy(Name.RawData, 16, NameLength);
    Name.FName:= StringToWideString(S);
  end;

  if IsBuiltIn then
    Name.FName:= BuiltInNameByCode(Name.FBuiltInName);

  { Name definition }
  Position:= 16 + NameLength;
  NameDef:= Copy(Name.RawData, Position, NameDefLength);
  Position:= 1;

  if (NameDef = '') then
    Exit;

  { Skip header }
  if Byte(NameDef[Position]) = $29 then
    Position:= Position + 3;

  RectCount:= 0;
  while (Position <= NameDefLength) do
  begin
    RowFrom:= 0;
    RowTo:= 0;
    ColumnFrom:= 0;
    ColumnTo:= 0;

    Ptg:= PByte(@NameDef[Position])^;

    case Ptg of
      FMLA_PTG_3DREF_VAL,
      FMLA_PTG_3DREF_REF,
      FMLA_PTG_3DREF_ARR:  RectDefLen:= 6;
      FMLA_PTG_3DAREA_VAL,
      FMLA_PTG_3DAREA_REF,
      FMLA_PTG_3DAREA_ARR: RectDefLen:= 10;
      else                 RectDefLen:= $FFFF;
    end;

    if (Position + RectDefLen > NameDefLength) then break;

    Position:= Position + 1;

    XTIIndex:= (PWord(@NameDef[Position]))^;
    if (XTIIndex >= ItemsCount) then
      raise EXLSError.Create(EXLS_INVALIDLINKTABLE);

    ASheetIndex:= Item[XTIIndex]^.SheetFrom;
    if (Name.FSheetIndex = XLT_ITEM_NOTFOUND) then
      Name.FSheetIndex:= ASheetIndex;

    case Ptg of
      FMLA_PTG_3DREF_VAL,
      FMLA_PTG_3DREF_REF,
      FMLA_PTG_3DREF_ARR:
        begin
          RowFrom   := (PWord(@NameDef[Position + 2]))^;
          RowTo     := RowFrom;
          ColumnFrom:= (PWord(@NameDef[Position + 4]))^;
          ColumnTo  := ColumnFrom;
        end;
      FMLA_PTG_3DAREA_VAL,
      FMLA_PTG_3DAREA_REF,
      FMLA_PTG_3DAREA_ARR:
        begin
          RowFrom   := (PWord(@NameDef[Position + 2]))^;
          RowTo     := (PWord(@NameDef[Position + 4]))^;
          ColumnFrom:= (PWord(@NameDef[Position + 6]))^;
          ColumnTo  := (PWord(@NameDef[Position + 8]))^;
        end;
    end;

    Name.FArea.AddRect(RowFrom, RowTo,ColumnFrom, ColumnTo);

    Position:= Position + RectDefLen;
    RectCount:= RectCount + 1;

    {skip union operator}
    if RectCount >=2 then
      Position:= Position + 1;
  end;

  {Check if the area is valid}
  if (Name.SheetIndex = XLT_ITEM_NOTFOUND) then
    Exit;

  Result:= True;
end;

procedure TXLSLinkTable.AddName(const NameRawData: AnsiString);
var
  NewName: TXLSLinkName;
begin
  NewName:= TXLSLinkName.Create;
  NewName.FRawData:= NameRawData;
  ParseNameData(NewName);
  LocalDocument.AddNameObject(NewName);
end;

function TXLSLinkTable.FindExternsheetIndex(const DocumentIndex: TXLSDocumentIndex;
  const SheetFrom: TXLSSheetIndex; const SheetTo: TXLSSheetIndex;
  const ForceAddItem: Boolean): TXLSLinkTableRef;
var
  I: Integer;
  NewItem: PLinkTableItem;  
begin
  Result:= XLT_ITEM_NOTFOUND;

  for I:= 0 to ItemsCount - 1 do
  begin
    if (   (Item[I]^.Document = DocumentIndex)
       and (Item[I]^.SheetFrom = SheetFrom)
       and (Item[I]^.SheetTo = SheetTo)
       ) then
    begin
      Result:= I;
      Exit;
    end;
  end;

  if (Result = XLT_ITEM_NOTFOUND) and ForceAddItem then
  begin
    New(NewItem);
    NewItem^.Document:= DocumentIndex;
    NewItem^.SheetFrom:= SheetFrom;
    NewItem^.SheetTo:= SheetTo;
    FLinkTableItems.Add(NewItem);

    Result:= FLinkTableItems.Count - 1;
  end;
end;

function TXLSLinkTable.GetSheetExternsheetIndex(const ASheetName: WideString): TXLSLinkTableRef;
var
  DocumentIndex: TXLSDocumentIndex;
  SheetIndex: TXLSSheetIndex;
begin
  Result:= XLT_ITEM_NOTFOUND;

  DocumentIndex:= LocalDocumentIndex;
  if (DocumentIndex = XLT_ITEM_NOTFOUND) then
    Exit;

  { find sheet index }
  SheetIndex:= LocalDocument.GetSheetIndex(ASheetName);

  if (SheetIndex = XLT_ITEM_NOTFOUND) then Exit;

  { find externsheet index }
  Result:= FindExternsheetIndex(DocumentIndex, SheetIndex, SheetIndex, True);
end;

function TXLSLinkTable.Get2SheetsExternsheetIndex(const ASheetName1: WideString;
  ASheetName2: WideString): TXLSLinkTableRef;
var
  DocumentIndex: TXLSDocumentIndex;
  SheetIndex1, SheetIndex2: TXLSSheetIndex;
begin
  Result:= XLT_ITEM_NOTFOUND;

  DocumentIndex:= LocalDocumentIndex;
  if (DocumentIndex = XLT_ITEM_NOTFOUND) then
    Exit;

  { find sheet index }
  SheetIndex1:= LocalDocument.GetSheetIndex(ASheetName1);
  if (SheetIndex1 = XLT_ITEM_NOTFOUND) then Exit;

  SheetIndex2:= LocalDocument.GetSheetIndex(ASheetName2);
  if (SheetIndex2 = XLT_ITEM_NOTFOUND) then Exit;

  { find externsheet index }
  Result:= FindExternsheetIndex(DocumentIndex, SheetIndex1, SheetIndex2, True);
end;

procedure TXLSLinkTable.AddExternsheet(const ExternsheetRawData: AnsiString);
var
  ItemsCount, I: Word;
  DocumentIndex: TXLSDocumentIndex;
  SheetFrom: TXLSSheetIndex;
  SheetTo: TXLSSheetIndex;
  NewItem: PLinkTableItem;
  Position: Integer;
begin
  if (Length(ExternsheetRawData) < 2)
    then Exit;

  Move(ExternsheetRawData[1], ItemsCount, 2);
  if (Length(ExternsheetRawData) < (2 + ItemsCount * 6)) then
    raise EXLSError.Create(EXLS_INVALIDLINKTABLE);

  Position:= 3;
  for I:= 0 to ItemsCount - 1 do
  begin
    Move(ExternsheetRawData[Position], DocumentIndex, 2);
    Move(ExternsheetRawData[Position + 2], SheetFrom, 2);
    Move(ExternsheetRawData[Position + 4], SheetTo, 2);
    Position:= Position + 6;
    { Add new item }
    New(NewItem);
    NewItem^.Document:= DocumentIndex;
    NewItem^.SheetFrom:= SheetFrom;
    NewItem^.SheetTo:= SheetTo;
    FLinkTableItems.Add(NewItem);
  end;
end;

function TXLSLinkTable.ParseCell(const ARef: AnsiString; var ALinkParam: TXLSLinkParameters): Boolean;
var
  C: TCellCoord;
begin
  if ParseCellA1RefVar(ARef, C) then
  begin
    ALinkParam.RowFrom:= C.Row;
    ALinkParam.ColumnFrom:= C.Column;
    ALinkParam.RowFromIsAbsolute:= ((C.RelativeFlags and $02) <> 0);
    ALinkParam.ColumnFromIsAbsolute:= ((C.RelativeFlags and $01) <> 0);
    ALinkParam.LinkType:= tlLocalRef;
    Result:= True;
  end
  else
    Result:= False;
end;

function TXLSLinkTable.ParseArea(const ARef: AnsiString; var ALinkParam: TXLSLinkParameters): Boolean;
var
  R: TRangeRect;
begin
  if ParseAreaA1RefVar(ARef, R) then
  begin

    ALinkParam.RowFrom             := R.RowFrom;
    ALinkParam.ColumnFrom          := R.ColumnFrom;
    ALinkParam.RowFromIsAbsolute   := ((R.RelativeFlags and $02) <> 0);
    ALinkParam.ColumnFromIsAbsolute:= ((R.RelativeFlags and $01) <> 0);

    ALinkParam.RowTo             := R.RowTo;
    ALinkParam.ColumnTo          := R.ColumnTo;
    ALinkParam.RowToIsAbsolute   := ((R.RelativeFlags and $08) <> 0);
    ALinkParam.ColumnToIsAbsolute:= ((R.RelativeFlags and $04) <> 0);;

    ALinkParam.LinkType:= tlLocalRect;
    Result:= True;
  end
  else
    Result:= False;
end;

function TXLSLinkTable.ParseSheetPart(const ARef: WideString; var XTIIndex: TXLSLinkTableRef): Boolean;
var
  P: Integer;
  S, ASheetName1, ASheetName2: WideString;
begin
  Result:= False;
  ASheetName1:= '';
  ASheetName2:= '';

  if ( Length(ARef) = 0 ) then
    Exit;

  S:= ARef;
  {remove quotes from name if present}
  if ( (S[1] = '''') and (S[Length(S)] = '''') ) then
    S:= Copy(S, 2, Length(S) - 2);

  if ( Length(S) = 0 ) then
    Exit;

  { 1 or 2 sheet names? }
  P:= Pos(':', S);
  if (P > 0) then
  begin
    ASheetName1:= Copy(S, 1, P-1);
    ASheetName2:= Copy(S, P+1, Length(S) - P);
    if (ASheetName1 = '') or (ASheetName2 = '') then
      Exit;
  end
  else
    ASheetName1:= S;

   if (ASheetName2 = '') then
    XTIIndex:= GetSheetExternsheetIndex(ASheetName1)
  else
    XTIIndex:= Get2SheetsExternsheetIndex(ASheetName1, ASheetName2);

  if (XTIIndex = XLT_ITEM_NOTFOUND) then
    Exit;

  Result:= True;
end;

function TXLSLinkTable.ParseExternalSheetPart(const ARef: WideString; var XTIIndex: TXLSLinkTableRef): Boolean;
var
  P: Integer;
  S, SheetPart, DocumentPart, ASheetName1, ASheetName2: WideString;
  DocumentIndex: TXLSDocumentIndex;
  SheetFrom: TXLSSheetIndex;
  SheetTo: TXLSSheetIndex;
begin
  Result:= False;
  ASheetName1:= '';
  ASheetName2:= '';

  if ( Length(ARef) = 0 ) then
    Exit;

  S:= ARef;
  {remove quotes from name if present}
  if ( (S[1] = '''') and (S[Length(S)] = '''') ) then
    S:= Copy(S, 2, Length(S) - 2);

  if ( Length(S) = 0 ) then
    Exit;

  { get document part }
  P:= Pos(']', S);
  if (P <= 0) then
    Exit;

  DocumentPart:= Copy(S, 1, P);
  SheetPart:= Copy(S, P + 1, Length(S) - P);

  { parse document part }
  DocumentPart:= WideStringReplace(DocumentPart, '[', '');
  DocumentPart:= WideStringReplace(DocumentPart, ']', '');
  DocumentIndex:= ParseDocumentName(DocumentPart);

  { 1 or 2 sheet names? }
  P:= Pos(':', SheetPart);
  if (P > 0) then
  begin
    ASheetName1:= Copy(SheetPart, 1, P-1);
    ASheetName2:= Copy(SheetPart, P+1, Length(SheetPart) - P);
    if (ASheetName1 = '') or (ASheetName2 = '') then
      Exit;
  end
  else
    ASheetName1:= SheetPart;

  SheetFrom:= Document[DocumentIndex].GetSheetIndex(ASheetName1);
  if (SheetFrom = XLT_ITEM_NOTFOUND) then
  begin
    Document[DocumentIndex].AddSheetName(ASheetName1);
    SheetFrom:= Document[DocumentIndex].SheetsCount - 1;
  end;

  if (ASheetName2 <> '') then
  begin
    SheetTo:= Document[DocumentIndex].GetSheetIndex(ASheetName2);
    if (SheetTo = XLT_ITEM_NOTFOUND) then
    begin
      Document[DocumentIndex].AddSheetName(ASheetName2);
      SheetTo:= Document[DocumentIndex].SheetsCount - 1;
    end
  end
  else
    SheetTo:= SheetFrom;

  if (SheetFrom = XLT_ITEM_NOTFOUND) or (SheetTo = XLT_ITEM_NOTFOUND) then
    Exit;

  XTIIndex:= FindExternsheetIndex(DocumentIndex, SheetFrom, SheetTo, True);

  Result:= True;
end;

function TXLSLinkTable.Parse3DCell(const ARef: WideString; var ALinkParam: TXLSLinkParameters): Boolean;
var
  P: Integer;
  SheetPart, CellPart: WideString;
  C: TXLSLinkParameters;
  XTIIndex: TXLSLinkTableRef;
begin
  Result:= False;

  P:= Pos('!', ARef);
  if (P > 0) then
  begin
    SheetPart:= Copy(ARef, 1, P-1);
    if ( Length(SheetPart) = 0 ) then
      Exit;

    CellPart:= Copy(ARef, P+1, Length(ARef) - P);

    if not ParseSheetPart(SheetPart, XTIIndex) then
      Exit;
  end
  else
    Exit;

  { parse cell part }
  if not ParseCell(AnsiSTring(CellPart), C) then
    Exit;

  ALinkParam:= C;
  ALinkParam.ExternSheetIndex:= XTIIndex;
  ALinkParam.LinkType:= tl3dRef;

  Result:= True;
end;

function TXLSLinkTable.Parse3DArea(const ARef: WideString; var ALinkParam: TXLSLinkParameters): Boolean;
var
  P: Integer;
  SheetPart, AreaPart: WideString;
  C: TXLSLinkParameters;
  XTIIndex: TXLSLinkTableRef;
begin
  Result:= False;

  P:= Pos('!', ARef);
  if (P > 0) then
  begin
    SheetPart:= Copy(ARef, 1, P-1);
    if ( Length(SheetPart) = 0 ) then
      Exit;

    AreaPart:= Copy(ARef, P+1, Length(ARef) - P);

    if not ParseSheetPart(SheetPart, XTIIndex) then
      Exit;
  end
  else
    Exit;

  { parse area part }
  if not ParseArea(AnsiString(AreaPart), C) then
    Exit;

  ALinkParam:= C;
  ALinkParam.ExternSheetIndex:= XTIIndex;
  ALinkParam.LinkType:= tl3dRect;

  Result:= True;
end;

function TXLSLinkTable.ParseName(const ARef: WideString; var ALinkParam: TXLSLinkParameters): Boolean;
var
  Name: WideString;
  NameIndex: TXLSNameIndex;
begin
  { local name }
  Result:= False;

  if ( Length(ARef) = 0 ) then
    Exit;

  Name:= ARef;
  {remove quotes from name if present}
  if ( (Name[1] = '''') and (Name[Length(Name)] = '''') ) then
    Name:= Copy(Name, 2, Length(Name) - 2);

  if ( Length(Name) = 0 ) then
    Exit;

  NameIndex:= LocalDocument.GetNameIndex(Name);
  if (NameIndex = XLT_ITEM_NOTFOUND) then
    Exit;

  ALinkParam.NameIndex:= NameIndex + 1; // return 1-based index
  ALinkParam.LinkType:= tlName;
  Result:= True;
end;

function TXLSLinkTable.ParseDocumentName(const ARef: WideString): TXLSDocumentIndex;
var
  I: Integer;
  NewItem: TXLSLinkDocument;
begin
  Result:= XLT_ITEM_NOTFOUND;
  for I:= 0 to DocumentsCount - 1 do
  begin
    if (Document[I].DocumentName = ARef) then
    begin
      if (((ARef = '') and Document[I].IsAddin )  or  ( ARef <> '')) then
      begin
        Result:= I;
        Break;
      end;  
    end;
  end;

  if (Result = XLT_ITEM_NOTFOUND) then
  begin
    NewItem:= TXLSLinkDocument.Create;
    NewItem.DocumentName:= ARef;
    if ARef = '' then
      NewItem.IsAddin:= True;
    FXLSLinkDocuments.Add(NewItem);
    Result:= FXLSLinkDocuments.Count - 1;
  end;
end;

function TXLSLinkTable.ParseExternalCell(const ARef: WideString; var ALinkParam: TXLSLinkParameters): Boolean;
var
  SheetPart, CellPart: WideString;
  P: Integer;
  C: TXLSLinkParameters;
  XTIIndex: TXLSLinkTableRef;
begin
  Result:= False;

  P:= Pos('!', ARef);
  if (P > 0) then
  begin
    SheetPart:= Copy(ARef, 1, P-1);
    if ( Length(SheetPart) = 0 ) then
      Exit;

    CellPart:= Copy(ARef, P+1, Length(ARef) - P);
  end
  else
    Exit;

  { parse cell part }
  if not ParseCell(AnsiString(CellPart), C) then
    Exit;

  if not ParseExternalSheetPart(SheetPart, XTIIndex) then
    Exit;

  ALinkParam:= C;
  ALinkParam.ExternSheetIndex:= XTIIndex;
  ALinkParam.LinkType:= tlExternal3dRef;
  Result:= True;
end;

function TXLSLinkTable.ParseExternalArea(const ARef: WideString; var ALinkParam: TXLSLinkParameters): Boolean;
var
  SheetPart, AreaPart: WideString;
  P: Integer;
  C: TXLSLinkParameters;
  XTIIndex: TXLSLinkTableRef;
begin
  Result:= False;

  P:= Pos('!', ARef);
  if (P > 0) then
  begin
    SheetPart:= Copy(ARef, 1, P-1);
    if ( Length(SheetPart) = 0 ) then
      Exit;

    AreaPart:= Copy(ARef, P+1, Length(ARef) - P);
  end
  else
    Exit;

  { parse area part }
  if not ParseArea(AnsiString(AreaPart), C) then
    Exit;

  if not ParseExternalSheetPart(SheetPart, XTIIndex) then
    Exit;

  ALinkParam:= C;
  ALinkParam.ExternSheetIndex:= XTIIndex;
  ALinkParam.LinkType:= tlExternal3dRect;
  Result:= True;
end;

function TXLSLinkTable.ParseExternalName(const ARef: WideString; var ALinkParam: TXLSLinkParameters): Boolean;
var
  NamePart, DocumentPart: WideString;
  P: Integer;
  XTIIndex: TXLSLinkTableRef;
  DocumentIndex: TXLSDocumentIndex;
  NameIndex: TXLSNameIndex;
begin
  Result:= False;

  { Find document part. If it is empty, it may be add-in. }
  P:= Pos('!', ARef);
  if (P > 0) then
  begin
    DocumentPart:= Copy(ARef, 1, P-1);
    NamePart:= Copy(ARef, P+1, Length(ARef) - P);
  end
  else
  begin
    DocumentPart:= '';
    NamePart:= ARef;
  end;

  if (NamePart = '') then
    Exit;

  { parse document part }
  if (DocumentPart <> '') then
    if ( (DocumentPart[1] = '''') and (DocumentPart[Length(DocumentPart)] = '''') ) then
      DocumentPart:= Copy(DocumentPart, 2, Length(DocumentPart) - 2);
  DocumentPart:= WideStringReplace(DocumentPart, '[', '');
  DocumentPart:= WideStringReplace(DocumentPart, ']', '');
  DocumentIndex:= ParseDocumentName(DocumentPart);

  { parse name part }
  NameIndex:= Document[DocumentIndex].GetNameIndex(NamePart);

  if (NameIndex = XLT_ITEM_NOTFOUND) then
  begin
    Document[DocumentIndex].AddName(NamePart, nil, binNoName, 0);
    NameIndex:= Document[DocumentIndex].NamesCount - 1;
  end;

  { get externsheet index }
  XTIIndex:= FindExternsheetIndex(DocumentIndex, XLT_EXTNAME_SHEETINDEX, XLT_EXTNAME_SHEETINDEX, True);

  ALinkParam.NameIndex:= NameIndex + 1; // return 1-based index
  ALinkParam.ExternSheetIndex:= XTIIndex;
  ALinkParam.LinkType:= tlExternalName;

  Result:= True; 
end;

function TXLSLinkTable.GetSupbookData(const DocumentIndex: TXLSDocumentIndex): AnsiString;
var
  St: TEasyStream;
  S: AnsiString;
  I: Integer;
  D: TXLSLinkDocument;
begin
  D:= Document[DocumentIndex];
  St:= TEasyStream.Create;
  try
    { Document name }
    if D.IsLocal then
    begin
      St.WriteWord(D.SheetsCount);
      St.WriteByte(1);
      St.WriteByte(4);
    end
    else
    if D.IsAddin then
    begin
      St.WriteWord(1);
      St.WriteByte(1);
      St.WriteByte($3A);
    end
    else
    begin
      if (D.RawData <> '') then
      begin
        S:= D.RawData;
        St.WriteBytes(@S[1], Length(S));
      end
      else
      begin
        St.WriteWord(D.SheetsCount);
        
        S:= EncodeDocumentName(D.DocumentName);
        St.WriteWord(Length(S) div 2);
        St.WriteByte(1); // unicode
        St.WriteBytes(@S[1], Length(S));

        { Sheet names }
        for I:= 0 to D.SheetsCount - 1 do
        begin
          St.WriteWord(Length(D.SheetName[I]));
          St.WriteByte(1);
          S:= WideStringToANSIWideString(D.SheetName[I]);
          St.WriteBytes(@S[1], Length(S));
        end;
      end;
    end;
    
    SetLength(Result, St.Size);
    St.Position:= 0;
    St.ReadBytes(@Result[1], St.Size);
  finally
    St.Destroy;
  end;
end;

function TXLSLinkTable.GetExternalNameData(const DocumentIndex: TXLSDocumentIndex;
  const NameIndex: TXLSNameIndex): AnsiString;
var
  D: TXLSLinkDocument;
  N: TXLSLinkName;
  St: TEasyStream;
  S: AnsiString;
  Name: WideString;
begin
  D:= Document[DocumentIndex];
  N:= D.Name[NameIndex];

  St:= TEasyStream.Create;
  try
    if (N.RawData <> '') then
      St.WriteBytes(@(N.RawData[1]), Length(N.RawData))
    else
    begin
      St.WriteWord(0);
      St.WriteWord(0); // Ext name is global (N.FSheetIndex)
      St.WriteWord(0);
      { Name }
      Name:= N.Name;
      { remove ' }
      if Copy(Name, 1, 1) = '''' then
        Name:= Copy(Name, 2, Length(Name) - 1);
      if Copy(Name, Length(Name), 1) = '''' then
        Name:= Copy(Name, 1, Length(Name) - 1);

      St.WriteByte(Length(Name));
      St.WriteByte(1); // unicode
      S:= WideStringToANSIWideString(Name);
      St.WriteBytes(@S[1], Length(S));

      { Name def = #REF!}
      St.WriteWord(0);
      St.WriteByte(0);
      St.WriteByte($02);
      St.WriteByte($00);
      St.WriteByte($1C); // Err token
      St.WriteByte($17); // error code
    end;

    SetLength(Result, St.Size);
    St.Position:= 0;
    St.ReadBytes(@Result[1], St.Size);
  finally
    St.Destroy;
  end;
end;

function TXLSLinkTable.GetExternsheetData: AnsiString;
var
  XTIIndex: Integer;
  St: TEasyStream;
begin
  St:= TEasyStream.Create;

  try
    St.WriteWord(FLinkTableItems.Count);

    for XTIIndex:= 0 to FLinkTableItems.Count - 1 do
    begin
      St.WriteWord(Item[XTIIndex]^.Document);
      St.WriteWord(Item[XTIIndex]^.SheetFrom);
      St.WriteWord(Item[XTIIndex]^.SheetTo);
    end;

    SetLength(Result, St.Size);
    St.Position:= 0;
    St.ReadBytes(@Result[1], St.Size);
  finally
    St.Destroy;
  end;
end;

function TXLSLinkTable.GetNameData(const NameIndex: TXLSNameIndex): AnsiString;
var
  N: TXLSLinkName;
  NameDef, RectsDef, NameText, S: AnsiString;
  W: Word;
  RectsCount, R, L, NameLength: Integer;
  DocumentIndex: TXLSDocumentIndex;
begin
  Result:= '';
  N:= LocalDocument.Name[NameIndex];
  DocumentIndex:= LocalDocumentIndex;

  { Name definition }
  RectsCount:= N.Area.RectsCount;

  if RectsCount > 1 then
    NameDef:= AnsiChar($29) + AnsiChar(0) + AnsiChar(0)
  else
    NameDef:= '';

  RectsDef:= '';
  for R:= 0 to RectsCount - 1 do
  begin
    {rect stuff}
    RectsDef:= RectsDef + AnsiChar($3B);
    L:= Length(RectsDef);
    SetLength(RectsDef, L + 2);

    {XTI index}
    W:= FindExternsheetIndex(DocumentIndex, N.SheetIndex, N.SheetIndex, True);
    Move(W, RectsDef[L+1], 2);

    L:= Length(RectsDef);
    SetLength(RectsDef, L + 8);
    W:= N.Area.Rect[R].RowFrom;
    Move(W, RectsDef[L+1], 2);
    W:= N.Area.Rect[R].RowTo;
    Move(W, RectsDef[L+3], 2);
    W:= N.Area.Rect[R].ColumnFrom;
    Move(W, RectsDef[L+5], 2);
    W:= N.Area.Rect[R].ColumnTo;
    Move(W, RectsDef[L+7], 2);

    {union operation for rects}
    if (RectsCount > 1) and (R > 0) then
      RectsDef:= RectsDef + AnsiChar($10);
  end;

  NameDef:= NameDef + RectsDef;

  if RectsCount > 1 then
  begin
    L:= Length(RectsDef);
    Move(L, NameDef[2], 2);
  end;

  { Name text }
  if (N.BuiltInName <> binNoName) then
  begin
    NameLength:= 1;
    NameText:= AnsiChar(#0) + AnsiChar(BuiltInDataByCode(N.BuiltInName)
    ); // non-unicode flag + built-in name code
  end
  else
  begin
    NameLength:= Length(N.Name);
    NameText:= #1 + WideStringToANSIWideString(N.Name); // add unicode byte
  end;

  { Compile name data }
  SetLength(S, 14);
  FillChar(S[1], 14, 0);

  {options}
  if (N.BuiltInName <> binNoName) then
    S[1]:= AnsiChar($20);

  {name text length}
  S[4]:= AnsiChar(NameLength);

  {name def length}
  L:= Length(NameDef);
  Move(L, S[5], 2);

  { sheet index: user-defined names are global }
  if (N.BuiltInName <> binNoName) then
    W:= N.SheetIndex + 1 // 1-based
  else
    W:= 0;

  Move(W, S[7], 2);    
  Move(W, S[9], 2);

  Result:= S + NameText + NameDef;
end;

function TXLSLinkTable.CompileLinkText(var Link: TXLSLinkParameters): Boolean;
var
  DocumentName: WideString;
  SheetName: WideString;
  Name: WideString;
  DocumentIndex: TXLSDocumentIndex;
  SheetFrom: TXLSSheetIndex;
  SheetTo: TXLSSheetIndex;
  I: Integer;
begin
  Link.LinkText:= '';
  DocumentName:= '';
  SheetName:= '';
  Name:= '';
  DocumentIndex:= 0;
  SheetFrom:= 0;
  SheetTo:= 0;

  if Link.LinkType in [tlSheet, tlExternalName] then
  begin
    if (Link.ExternSheetIndex >= ItemsCount) then
      raise EXLSError.Create(EXLS_INVALIDLINKTABLE);

    DocumentIndex:= Item[Link.ExternSheetIndex]^.Document;
    SheetFrom:= Item[Link.ExternSheetIndex]^.SheetFrom;
    SheetTo:= Item[Link.ExternSheetIndex]^.SheetTo;
  end;

  if Link.LinkType in [tlSheet, tlExternalName] then
  begin
    if (DocumentIndex >= DocumentsCount) then
      raise EXLSError.Create(EXLS_INVALIDLINKTABLE);
    DocumentName:= Document[DocumentIndex].DocumentName;
  end;

  if (Link.LinkType = tlName) then
  begin
    if (Link.NameIndex >= LocalDocument.NamesCount) then
      raise EXLSError.Create(EXLS_INVALIDLINKTABLE);
    Name:= LocalDocument.Name[Link.NameIndex].Name;
  end;

  if (Link.LinkType = tlExternalName) then
  begin
    if (Link.NameIndex >= Document[DocumentIndex].NamesCount) then
      raise EXLSError.Create(EXLS_INVALIDLINKTABLE);
    Name:= Document[DocumentIndex].Name[Link.NameIndex].Name;
  end;

  if (Link.LinkType = tlSheet) then
  begin
    if (SheetFrom >= Document[DocumentIndex].SheetsCount)
      or (SheetTo >= Document[DocumentIndex].SheetsCount) then
      raise EXLSError.Create(EXLS_INVALIDLINKTABLE);

    if (SheetFrom = SheetTo) then
      SheetName:= Document[DocumentIndex].SheetName[SheetFrom]
    else
      SheetName:= Document[DocumentIndex].SheetName[SheetFrom] + ':'
                + Document[DocumentIndex].SheetName[SheetTo];
  end;

  { Compile link text }
  if (DocumentName <> '') then
    Link.LinkText:= Link.LinkText + DocumentName;

  if (SheetName <> '') then
  begin
    { If document and sheet present, then add [ ] to file name }
    if (Link.LinkText <> '') then
    begin
      I:= Length(Link.LinkText);
      while ((I >= 1) and (Link.LinkText[I] <> '\')) do
        I:= I - 1;

      Link.LinkText:= Copy(Link.LinkText, 1, I) + '['
        + Copy(Link.LinkText, I + 1, Length(Link.LinkText))
        + ']';
    end;

    Link.LinkText:= Link.LinkText + SheetName;
  end;

  if (Link.LinkText <> '') then
    Link.LinkText:= '''' + Link.LinkText + '''';

  if (Link.LinkType = tlExternalName) then
    if Link.LinkText <> '' then
      Link.LinkText:= Link.LinkText + '!';

  if (Name <> '') then
  begin
    if (Pos(' ', Name) > 0) and (Copy(Name, 1, 1) <> '''' ) then
      Link.LinkText:= Link.LinkText + '''' + Name + ''''
    else
      Link.LinkText:= Link.LinkText + Name;
  end;

  Result:= True;   
end;

function TXLSLinkTable.ParseLinkText(var Link: TXLSLinkParameters): Boolean;
begin
  Result:= True;

  if ParseCell(AnsiString(Link.LinkText), Link) then Exit;
  if ParseArea(AnsiString(Link.LinkText), Link) then Exit;
  if Parse3DCell(Link.LinkText, Link)       then Exit;
  if Parse3DArea(Link.LinkText, Link)       then Exit;
  if ParseName(Link.LinkText, Link)         then Exit;
  if ParseExternalCell(Link.LinkText, Link) then Exit;
  if ParseExternalArea(Link.LinkText, Link) then Exit;
  if ParseExternalName(Link.LinkText, Link) then Exit;

  // not parsed 
  Result:= False;
end;

end.
