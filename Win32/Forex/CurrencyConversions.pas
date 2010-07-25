unit CurrencyConversions;

// ----------------------------------------------------------------------------
interface

uses
   Classes,
   Contnrs;
// ----------------------------------------------------------------------------

Type
  JulDate = Integer;

  TExchangeRateInfo = Class
    Date : Integer;
    Rate : Extended;
  end;

  TExchangeRateTable = Class( TObjectList )
  private
    fSortRequired     : Boolean;
    procedure SetBaseCurrencyCode(const Value: String);
    procedure SetDestCurrencyCode(const Value: String);
    procedure SortRates;
    function GetRates(Index: Integer): TExchangeRateInfo;
    procedure SetRates(Index: Integer; const Value: TExchangeRateInfo);
    function GetFromDate: JulDate;
    function GetToDate: JulDate;
  public
    fBaseCurrencyCode : String;
    fDestCurrencyCode : String;
    Constructor Create( Const ABaseCurrencyCode, ADestCurrencyCode : String );
    Function FindRate( Const ADate : JulDate ): Extended;
    property BaseCurrencyCode : String read FBaseCurrencyCode write SetBaseCurrencyCode;
    property DestCurrencyCode : String read FDestCurrencyCode write SetDestCurrencyCode;
    property Rates[ Index : Integer ]:  TExchangeRateInfo read GetRates write SetRates;
    property FromDate : JulDate read GetFromDate;
    property ToDate : JulDate read GetToDate;
  end;

  TExchangeRateTables = Class( TObjectList )
  private
    function GetTable(Index: Integer): TExchangeRateTable;
    procedure SetTable(Index: Integer; const Value: TExchangeRateTable );
  public
    property Table[ Index : Integer ]:  TExchangeRateTable read GetTable write SetTable;
  end;

  TExchangeRateFileInfo = Class( TObjectList )
  private
    fBaseCurrency : String;
    fDescription : String;
    fDataSource : String;
    fCurrencies : TStringList;
    fFileName: String;
    fFromDate : JulDate;
    fToDate : JulDate;
    fColumns : TStringList;
    fTables  : TExchangeRateTables;
    fLastUpdated : Int64;
    fExists : Boolean;
  public
    Constructor Create( AFileName : String );
    Destructor Destroy; Override;
    Procedure LoadData;
    Function CanConvert( SourceCurrency, DestCurrency : String ): Boolean;
    Function Rate( SourceCurrency, DestCurrency : String;
                   AsAt : JulDate ): Extended; Overload;
    Function Rate( SourceCurrency, DestCurrency : String;
                   AsAt : String ): Extended; Overload;
    Function TableIdx( SourceCurrency, DestCurrency : String ): Integer;
    Property Filename : String read fFileName;
    Property Description : String read FDescription;
    Property DataSource : String read FDataSource;
    Property FromDate : JulDate read fFromDate;
    Property ToDate : JulDate read fToDate;
    Property BaseCurrency : String read fBaseCurrency;
    Property Currencies : TStringList read fCurrencies;
    Property Columns : TStringList read FColumns;
    Property Tables : TExchangeRateTables read fTables;
    Property LastUpdated : Int64 read fLastUpdated;
    Property Exists : Boolean read fExists write fExists;
  end;

  // --------------------------------------------------------------------------

  TExchangeRateSuggestion = Class
    Description : String;
    DataSource : String;
    Rate : Extended;
  end;

  TExchangeRateSuggestions = Class( TObjectList )
  private
    function GetSuggestion(Index: Integer): TExchangeRateSuggestion;
    procedure SetSuggestion(Index: Integer; const Value: TExchangeRateSuggestion);
  public
    Property Suggestion[ Index : Integer ]: TExchangeRateSuggestion read GetSuggestion write SetSuggestion;
    Function FindSourceByDescriptionAndDataSource( ADescription, ADataSource : String ): TExchangeRateSuggestion;
  end;

  // --------------------------------------------------------------------------

  TExchangeRateSource = Class
    Description : String;
    DataSource : String;
    FileName   : String;
    ForexInfo  : TExchangeRateFileInfo;
  end;

  TExchangeRateSources = Class( TObjectList )
  private
    function GetSource(Index: Integer): TExchangeRateSource;
    procedure SetSource(Index: Integer; const Value: TExchangeRateSource);
  public
    Property Source[ Index : Integer ]: TExchangeRateSource read GetSource write SetSource;
    Function FindSourceByDescriptionAndDataSource( ADescription, ADataSource : String ): TExchangeRateSource;
  end;

  // --------------------------------------------------------------------------

  TExchangeRateFinder = Class( TObjectList )
  private
    fFolder : String;
    function GetFiles(Index: Integer): TExchangeRateFileInfo;
    procedure SetFiles(Index: Integer; const Value: TExchangeRateFileInfo);
  public
    Constructor Create;
    Property Files[ Index : Integer ]: TExchangeRateFileInfo read GetFiles write SetFiles;
    Function SuggestRates( SourceCurrency, DestCurrency : String; AsAt : JulDate ): TExchangeRateSuggestions; Overload;
    Function SuggestRates( SourceCurrency, DestCurrency : String; AsAt : String ): TExchangeRateSuggestions; Overload;
    Function SuggestSources( SourceCurrency, DestCurrency : String ): TExchangeRateSources;

    Function FindRateInfoFileByName( FileName : String ): TExchangeRateFileInfo;
    Procedure Refresh;
  end;

Function ExchangeRateFinder : TExchangeRateFinder;

// ----------------------------------------------------------------------------
implementation
uses
  Controls,
  Forms,
  SysUtils,
  ISO_4217,
  BkDateUtils,
  Math,
  XlsFile,
  XLSWorkBook,
  Excel_Settings, Variants, Windows, GlobalDirectories;
// ----------------------------------------------------------------------------

var
  fExchangeRateFinder : TExchangeRateFinder = NIL;

Function ExchangeRateFinder : TExchangeRateFinder;
var kC: TCursor;
Begin
  if fExchangeRateFinder = NIL then begin
    kC := Screen.Cursor;
    Screen.Cursor := crHourGlass;
    try
       fExchangeRateFinder := TExchangeRateFinder.Create;
    finally
       Screen.Cursor := kC;
    end;
  end;
  Result := fExchangeRateFinder;
end;

// ----------------------------------------------------------------------------

function GetFileTimeAsInt64( FileName: string ): int64;
var
  Handle: THandle;
  FindData: TWin32FindData;
begin
  Result := -1;
  Handle := FindFirstFile( PChar( FileName ), FindData );
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose( Handle );
    Result := Int64( FindData.ftLastWriteTime );
  end;
end;

// ----------------------------------------------------------------------------
{ TExchangeRateFileFinder }
// ----------------------------------------------------------------------------

constructor TExchangeRateFinder.Create;
Var
  F    : TSearchRec;
  Path : String;
  Res  : Integer;
begin
  Inherited Create;
  fFolder := glDataDir + 'Exchange Rates\';
  if not DirectoryExists( fFolder ) then
     ForceDirectories( fFolder );

  Path := fFolder + '*.xls';
  Res := FindFirst( Path, faAnyFile, F );
  While ( Res = 0 ) do
  Begin
    if ( F.Attr and faDirectory ) = 0 then
      Add( TExchangeRateFileInfo.Create( fFolder + F.Name ) );
    Res := FindNext( F );
  end;
  SysUtils.FindClose( F );
end;

// ----------------------------------------------------------------------------

function TExchangeRateFinder.FindRateInfoFileByName(FileName: String): TExchangeRateFileInfo;
Var
  i : Integer;
begin
  for I := 0 to Count - 1 do
  Begin
    Result := Files[ i ];
    if Result.Filename = FileName then exit;
  end;
  Result := NIL;
end;

// ----------------------------------------------------------------------------

function TExchangeRateFinder.GetFiles(
  Index: Integer): TExchangeRateFileInfo;
begin
  Result := TExchangeRateFileInfo( Items[ Index ] );
end;

// ----------------------------------------------------------------------------

procedure TExchangeRateFinder.Refresh;
Var
  F    : TSearchRec;
  Path : String;
  Res  : Integer;
  FileInfo : TExchangeRateFileInfo;
  FQFileName : String;
  I : Integer;
begin
  for I := 0 to Count - 1 do Files[ i ].Exists := False;

  Path := fFolder + '*.xls';
  Res := FindFirst( Path, faAnyFile, F );
  While ( Res = 0 ) do
  Begin
    if ( F.Attr and faDirectory ) = 0 then
    Begin
      FQFileName := fFolder + F.Name;
      FileInfo := FindRateInfoFileByName( FQFileName );
      if FileInfo = NIL then
        Add( TExchangeRateFileInfo.Create( FQFileName ) )
      else
      Begin
        FileInfo.Exists := True;
        If GetFileTimeAsInt64( FQFileName ) <> FileInfo.fLastUpdated then
        Begin
          Remove( FileInfo );
          Add( TExchangeRateFileInfo.Create( FQFileName ) )
        end;
      end;
    end;
    Res := FindNext( F );
  end;
  SysUtils.FindClose( F );

  for I := Count - 1 downto 0 do
  Begin
    FileInfo := Files[ i ];
    if not FileInfo.Exists then Remove( FileInfo );
  end;
end;

// ----------------------------------------------------------------------------

procedure TExchangeRateFinder.SetFiles(Index: Integer;
  const Value: TExchangeRateFileInfo);
begin
  Items[ Index ] := TObject( Value );
end;

// ----------------------------------------------------------------------------

function TExchangeRateFinder.SuggestRates(SourceCurrency, DestCurrency,
  AsAt: String): TExchangeRateSuggestions;
begin
  Result := SuggestRates( SourceCurrency, DestCurrency, bkStr2Date( AsAt ) );
end;

function TExchangeRateFinder.SuggestSources(SourceCurrency,
  DestCurrency: String): TExchangeRateSources;
Var
  i    : Integer;
  FI   : TExchangeRateFileInfo;
  Source : TExchangeRateSource;
begin
  Result := TExchangeRateSources.Create;
  for i  := 0 to Count - 1 do
  Begin
    FI := Files[ i ];
    if FI.CanConvert( SourceCurrency, DestCurrency ) then
    Begin
      Source := TExchangeRateSource.Create;
      Source.Description := FI.Description;
      Source.DataSource  := FI.DataSource;
      Source.FileName    := FI.Filename;
      Source.ForexInfo   := FI;
      Result.Add( Source );
    end;
  end;
end;

// ----------------------------------------------------------------------------

function TExchangeRateFinder.SuggestRates(SourceCurrency, DestCurrency : String;
  AsAt : JulDate): TExchangeRateSuggestions;
Var
  i    : Integer;
  FI   : TExchangeRateFileInfo;
  Suggestion : TExchangeRateSuggestion;
begin
  Result := TExchangeRateSuggestions.Create;
  for i  := 0 to Count - 1 do
  Begin
    FI := Files[ i ];
    if FI.CanConvert( SourceCurrency, DestCurrency ) then
    Begin
      Suggestion := TExchangeRateSuggestion.Create;
      Suggestion.Description := FI.Description;
      Suggestion.DataSource  := FI.DataSource;
      Suggestion.Rate        := FI.Rate( SourceCurrency, DestCurrency, AsAt );
      Result.Add( Suggestion );
    end;
  end;
end;

// ----------------------------------------------------------------------------
{ TExchangeRateFileInfo }
// ----------------------------------------------------------------------------

function TExchangeRateFileInfo.CanConvert(SourceCurrency, DestCurrency: String ): Boolean;
begin
  Result := False;
  if not ISO_4217_Code_Exists( SourceCurrency ) then exit;
  if not ISO_4217_Code_Exists( DestCurrency ) then exit;
  if ( BaseCurrency = SourceCurrency ) then
    Result := ( Currencies.IndexOf( DestCurrency ) >= 0 )
  else
  if ( BaseCurrency = DestCurrency ) then
    Result := ( Currencies.IndexOf( SourceCurrency ) >= 0 );
end;

// ----------------------------------------------------------------------------

constructor TExchangeRateFileInfo.Create( AFileName: String );
begin
  Inherited Create;
  fFilename     := AFileName;
  fBaseCurrency := '';
  fDescription  := '';
  fDataSource   := '';
  fCurrencies   := TStringList.Create;
  fColumns      := TStringList.Create;
  fTables       := TExchangeRateTables.Create;
  fFromDate     := 0;
  fToDate       := 0;
  fLastUpdated  := GetFileTimeAsInt64( AFileName );
  fExists       := True;
  LoadData;
end;

// ----------------------------------------------------------------------------

destructor TExchangeRateFileInfo.Destroy;
begin
  FreeAndNil( fCurrencies );
  FreeAndNil( fColumns );
  FreeAndNil( fTables );
  inherited;
end;

// ----------------------------------------------------------------------------

procedure TExchangeRateFileInfo.LoadData;
Var
  XLFile : TXlsFile;
  XLInfo : TExcelFileInfo;
  WorkSheet : TSheet;
  InfoFileName : String;
  S, Name : String;
  Cell : TCell;
  i, p, Col, Row, DateCol : Integer;
  SDate : String;
  RDate : JulDate;
  RRate : Extended;
  RateInfo : TExchangeRateInfo;
begin
  InfoFileName := ChangeFileExt( FileName, '.Ini' );
  XLInfo := TExcelFileInfo.Create;
  Try
    if not XLInfo.Load( InfoFileName ) then
    Begin
      XLInfo.Save; { Create a Template File }
      Raise Exception.CreateFmt( 'We need some extra infomation about %s, please edit the file %s', [ FileName, InfoFileName ] );
    end;

    fBaseCurrency := XLInfo.Base_Currency;
    if not ISO_4217_Code_Exists( fBaseCurrency ) then
      Raise Exception.CreateFmt( 'TExchangeRateFileInfo.LoadData Error in %s : The Base_Currency property "%s" is not a valid currency code', [ InfoFileName, fBaseCurrency ] );

    fDescription := XLInfo.Description;
    if fDescription = '' then
      Raise Exception.CreateFmt( 'TExchangeRateFileInfo.LoadData Error : %s : The Description property cannot be blank', [ InfoFileName ] );

    fDataSource := XLInfo.Data_Source;
    if fDataSource = '' then
      Raise Exception.CreateFmt( 'TExchangeRateFileInfo.LoadData Error in %s : The Data_Source property cannot be blank', [ InfoFileName ] );

    XLFile := TXlsFile.Create;
    Try
      XLFile.OpenFile( FileName );

      if XLFile.Workbook.Sheets.Count > 1 then
      Begin
        WorkSheet := XLFile.Workbook.SheetByName( XLInfo.Worksheet_Name );
        if WorkSheet = NIL then
          Raise Exception.CreateFmt( 'Error in %s, Worksheet %s does not exist', [ FileName, XLInfo.Worksheet_Name ] );
      end
      else
        WorkSheet := XLFile.Workbook.Sheets[0];


      S := XLInfo.Column_Names;
      p := pos( ',', S );
      While( p > 0 ) do
      Begin
        Name := Copy( S, 1, p-1 );
        if ( Name <> '' ) then
        Begin
          fColumns.Add( Name );
          if ISO_4217_Code_Exists( Name ) then
            fCurrencies.Add( Name );
        end;
        System.Delete( S, 1, p );
        p := pos( ',', S );
      end;
      Name := S;
      if ( Name <> '' ) then
      Begin
        fColumns.Add( Name );
        if ISO_4217_Code_Exists( Name ) then
          fCurrencies.Add( Name );
      end;

      DateCol := Columns.IndexOf( 'Date' );
      if DateCol = -1 then
        Raise Exception.CreateFmt( 'TExchangeRateFileInfo.LoadData Error in %s, Column_Names must include a "Date" column', [ InfoFileName ] );

      If XLInfo.Data_Starts_In_Row  = 0 then
        Raise Exception.CreateFmt( 'TExchangeRateFileInfo.LoadData Error in %s, Data_Starts_In_Row can''t be zero', [ InfoFileName ] );


      if fCurrencies.Count = 0 then
        Raise Exception.CreateFmt( 'TExchangeRateFileInfo.LoadData Error in %s, Column_Names didn''t have any valid ISO 4217 currency codes', [ InfoFileName ] );

      for I := 0 to Currencies.Count - 1 do fTables.Add( TExchangeRateTable.Create( BaseCurrency, Currencies[ i ] ) );

      Row := XLInfo.Data_Starts_In_Row; { Zero based Row Numbers }

      fFromDate := 0;
      fToDate   := 0;

      Repeat
        Cell := Worksheet.Cells.Cell[ Row-1, DateCol ];
        RDate := 0;
        if VarType( Cell.Value ) = varDate then
        Begin
          SDate := FormatDateTime('dd/mm/yy', Cell.Value );
          RDate := bkStr2Date( SDate );
          if RDate <= 0 then
            Raise Exception.CreateFmt( 'TExchangeRateFileInfo.LoadData Error in %s, The cell at row %d, column %d doesn''t contain a valid date', [ FileName, Row, DateCol ] );
        end;
        if RDate > 0 then
        Begin
          if ( RDate < fFromDate ) or ( fFromDate = 0 ) then fFromDate := RDate;
          if ( RDate > fToDate ) then fToDate := RDate;
          for I := 0 to Currencies.Count - 1 do
          Begin
            Name := Currencies[ i ];
            Col := Columns.IndexOf( Name );
            if Col >= 0 then
            Begin
              Cell := Worksheet.Cells.Cell[ Row-1, Col ];
              if VarType( Cell.Value ) = varDouble then
              Begin
                RRate := Cell.Value;
                RateInfo := TExchangeRateInfo.Create;
                RateInfo.Date := RDate;
                RateInfo.Rate := RRate;
                fTables.Table[ I ].Add( RateInfo );
                fTables.Table[ I ].fSortRequired := True;
              end;
            end;
          end;
          Inc( Row );
        end;
      Until ( RDate = 0 );
    Finally
      FreeAndNil( XLFile );
    end;
  Finally
    XLInfo.Free;
  end;
end;

// ----------------------------------------------------------------------------

function TExchangeRateFileInfo.Rate(SourceCurrency, DestCurrency,
  AsAt: String): Extended;
begin
  Result := Rate( SourceCurrency, DestCurrency, bkStr2Date( AsAt ) );
end;

// ----------------------------------------------------------------------------

function TExchangeRateFileInfo.TableIdx(SourceCurrency,
  DestCurrency: String): Integer;
begin
  Result := -1;
  if not ISO_4217_Code_Exists( SourceCurrency ) then
    Raise Exception.CreateFmt( 'TExchangeRateFileInfo.Rate Error, %s is not a valid currency code', [ SourceCurrency ] );

  if not ISO_4217_Code_Exists( DestCurrency ) then
    Raise Exception.CreateFmt( 'TExchangeRateFileInfo.Rate Error, %s is not a valid currency code', [ DestCurrency ] );

  if ( BaseCurrency = DestCurrency ) then
  Begin
    Result := Currencies.IndexOf( SourceCurrency );
    exit;
  end;

  if ( BaseCurrency = SourceCurrency ) then
  Begin
    Result := Currencies.IndexOf( DestCurrency );
    exit;
  end;
end;

// ----------------------------------------------------------------------------

function TExchangeRateFileInfo.Rate(SourceCurrency, DestCurrency: String;
  AsAt: JulDate ): Extended;
Var
  Idx : Integer;
  F1, F2 : Extended;
  ActionS : String;
begin
  ActionS := Format( 'Finding rate for %s -> %s as at %s', [ SourceCurrency, DestCurrency, bkDate2Str( AsAt ) ] );

  if not ISO_4217_Code_Exists( SourceCurrency ) then
    Raise Exception.CreateFmt( 'TExchangeRateFileInfo.Rate Error, %s is not a valid currency code', [ SourceCurrency ] );

  if not ISO_4217_Code_Exists( DestCurrency ) then
    Raise Exception.CreateFmt( 'TExchangeRateFileInfo.Rate Error, %s is not a valid currency code', [ DestCurrency ] );

  if SourceCurrency = DestCurrency then
  Begin
    Result := 1.0;
    exit;
  end;

  if ( BaseCurrency = DestCurrency ) then
  Begin
    Idx := Currencies.IndexOf( SourceCurrency );
    If Idx = -1 then
      Raise Exception.CreateFmt( 'TExchangeRateFileInfo.Rate Error, currency code %s does not exist in %s', [ SourceCurrency, FileName  ] );
    Result := Tables.Table[ Idx ].FindRate( AsAt );
    exit;
  end;

  if ( BaseCurrency = SourceCurrency ) then
  Begin
    Idx := Currencies.IndexOf( DestCurrency );
    If Idx = -1 then
      Raise Exception.CreateFmt( 'TExchangeRateFileInfo.Rate Error, currency code %s does not exist in %s', [ DestCurrency, FileName  ] );
    Result := Tables.Table[ Idx ].FindRate( AsAt );
    if Result <> 0.0 then Result := 1.0 / Result;
    exit;
  end;

  Idx := Currencies.IndexOf( SourceCurrency );
  If Idx = -1 then
    Raise Exception.CreateFmt( 'TExchangeRateFileInfo.Rate Error, currency code %s does not exist in %s', [ SourceCurrency, FileName  ] );
  F1 := Tables.Table[ Idx ].FindRate( AsAt );

  Idx := Currencies.IndexOf( DestCurrency );
  If Idx = -1 then
    Raise Exception.CreateFmt( 'TExchangeRateFileInfo.Rate Error, currency code %s does not exist in %s', [ DestCurrency, FileName  ] );
  F2 := Tables.Table[ Idx ].FindRate( AsAt );

  if ( F1 <> 0.0 ) and ( F2 <> 0.0 ) then
    Result := F2 / F1
  else
    Result := 0.0;
end;

// ----------------------------------------------------------------------------
{ TExchangeRateTable }
// ----------------------------------------------------------------------------

constructor TExchangeRateTable.Create(const ABaseCurrencyCode,
  ADestCurrencyCode: String);
begin
  Inherited Create;
  BaseCurrencyCode := ABaseCurrencyCode;
  DestCurrencyCode := ADestCurrencyCode;
  fSortRequired := True;
end;

// ----------------------------------------------------------------------------

function TExchangeRateTable.FindRate(const ADate: JulDate): Extended;
Var
  H, L, I, C : Integer;
  R : TExchangeRateInfo;
begin
  if fSortRequired then SortRates;
  Result := 0.0;

  H := Count -1;
  L := 0;
  if L > H then Exit;

  repeat
    I := ( L + H ) shr 1;
    R := Rates[ i ];
    C := CompareValue( ADate, R.Date );
    if C > 0 then L := I + 1 else H := I - 1;
  until ( c = 0 ) or ( L > H );
  if C = 0 then
    Result := R.Rate
  else
  if H > 0 then
    Result := Rates[ H ].Rate
end;

// ----------------------------------------------------------------------------

function TExchangeRateTable.GetFromDate: JulDate;
begin
  Result := 0;
  If fSortRequired then SortRates;
  if Count > 0 then Result := Rates[ 0 ].Date;
end;

// ----------------------------------------------------------------------------

function TExchangeRateTable.GetRates(Index: Integer): TExchangeRateInfo;
begin
  Result := TExchangeRateInfo( Items[ Index ] );
end;

// ----------------------------------------------------------------------------

function TExchangeRateTable.GetToDate: Integer;
begin
  Result := 0;
  If fSortRequired then SortRates;
  if Count > 0 then Result := Rates[ Count-1 ].Date;
end;

// ----------------------------------------------------------------------------

procedure TExchangeRateTable.SetBaseCurrencyCode(const Value: String);
begin
  FBaseCurrencyCode := Value;
end;

// ----------------------------------------------------------------------------

procedure TExchangeRateTable.SetDestCurrencyCode(const Value: String);
begin
  FDestCurrencyCode := Value;
end;

// ----------------------------------------------------------------------------

procedure TExchangeRateTable.SetRates(Index: Integer;
  const Value: TExchangeRateInfo);
begin
  Items[ Index ] := TObject( Value );
end;

// ----------------------------------------------------------------------------

Function SortExchangeRateItems( Item1, Item2: Pointer ): Integer;
Var
  R1 : TExchangeRateInfo Absolute Item1;
  R2 : TExchangeRateInfo Absolute Item2;
Begin
  Result := CompareValue( R1.Date, R2.Date );
end;

// ----------------------------------------------------------------------------

procedure TExchangeRateTable.SortRates;
begin
  Sort( SortExchangeRateItems );
  fSortRequired := False;
end;

// ----------------------------------------------------------------------------
{ TExchangeRateTables }
// ----------------------------------------------------------------------------

function TExchangeRateTables.GetTable(Index: Integer): TExchangeRateTable;
begin
  Result := TExchangeRateTable( Items[ Index ] );
end;

// ----------------------------------------------------------------------------

procedure TExchangeRateTables.SetTable(Index: Integer;
  const Value: TExchangeRateTable);
begin
  Items[ Index ] := TObject( Value );
end;

// ----------------------------------------------------------------------------
{ TExchangeRateSuggestions }
// ----------------------------------------------------------------------------

function TExchangeRateSuggestions.FindSourceByDescriptionAndDataSource(
  ADescription, ADataSource: String): TExchangeRateSuggestion;
Var
  i : Integer;
begin
  for I := 0 to Count - 1 do
  Begin
    Result := Suggestion[ i ];
    if ( Result.Description = ADescription ) and ( Result.DataSource = ADataSource ) then exit;
  end;
  Result := NIL;
end;

function TExchangeRateSuggestions.GetSuggestion(
  Index: Integer): TExchangeRateSuggestion;
begin
  Result := TExchangeRateSuggestion( Items[ Index ] );
end;

// ----------------------------------------------------------------------------

procedure TExchangeRateSuggestions.SetSuggestion(Index: Integer;
  const Value: TExchangeRateSuggestion);
begin
  Items[ Index ] := TObject( Value );
end;

// ----------------------------------------------------------------------------
{ TExchangeRateSources }
// ----------------------------------------------------------------------------

function TExchangeRateSources.FindSourceByDescriptionAndDataSource(ADescription,
  ADataSource: String): TExchangeRateSource;
Var
  i : Integer;
begin
  for I := 0 to Count - 1 do
  Begin
    Result := Source[ i ];
    if ( Result.Description = ADescription ) and ( Result.DataSource = ADataSource ) then exit;
  end;
  Result := NIL;
end;

function TExchangeRateSources.GetSource(Index: Integer): TExchangeRateSource;
begin
  Result := TExchangeRateSource( Items[ Index ] );
end;

procedure TExchangeRateSources.SetSource(Index: Integer;
  const Value: TExchangeRateSource);
begin
  Items[ Index ] := TObject( Value );
end;

Initialization
  fExchangeRateFinder := NIL;
Finalization
  FreeAndNil( fExchangeRateFinder );
end.
