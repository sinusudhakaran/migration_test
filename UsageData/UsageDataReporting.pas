unit UsageDataReporting;

//------------------------------------------------------------------------------
interface

uses
  Classes,
  DB,
  SqlExpr,
  OfficeDM,
  OpExcel,
  ExtCtrls;

type
  //----------------------------------------------------------------------------
  TProgressEvent = procedure (aUsageGroup : integer;
                              aUsageCount : integer) of object;

  //----------------------------------------------------------------------------
  TUsageDataReporting = class(TObject)
  private
    fSQLConnection : TSQLConnection;
    fSQLDataSet    : TSQLDataSet;

    fOfficeDataModule : TDataModuleOffice;

    fHostName : string;
    fDatabase : string;
    fUserName : string;
    fPassword : string;

    fProgressEvent : TProgressEvent;
  protected
    procedure SetRangeToHeading(const aExcelRange : TOpExcelRange);
    procedure SetRangeToBorder(const aExcelRange : TOpExcelRange);
    function ExcelAddress(const aValue: integer; aRow: integer) : string;
    procedure SetupDatabase(aHostName : string;
                            aDatabase : string;
                            aUserName : string;
                            aPassword : string);

    procedure FeatureUsageReportMainPage(const aWorkbook : TOpExcelWorkbook;
                                         const aWorksheet: TOpExcelWorksheet;
                                         aFeatureCount : integer);
    procedure BkHandlerFeatureUsageReport(const aWorksheet: TOpExcelWorksheet;
                                          aDateDataStartsStr : string;
                                          aNZPracCount : integer;
                                          aAUPracCount : integer);
    procedure BuildFeatureHeader(const aWorksheet: TOpExcelWorksheet;
                                 const aExcelRange : TOpExcelRange;
                                 aFeatureGroupName, aDateDataStartsStr: string;
                                 aNZPracCount, aAUPracCount: integer;
                                 aHeaderPeriodStr : string;
                                 aNZMaxLineNo, aAUMaxLineNo : integer);
    procedure RunOneFeatureUsageReport(const aWorksheet: TOpExcelWorksheet;
                                       aFeatureGroupId : integer;
                                       aFeatureGroupName : string;
                                       aDateDataStartsStr : string;
                                       aNZPracCount : integer;
                                       aAUPracCount : integer);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Connect();
    procedure Disconnect();

    procedure RunFeatureUsageReport(aFileName : string);

    property HostName : string read fHostName write fHostName;
    property Database : string read fDatabase write fDatabase;
    property UserName : string read fUserName write fUserName;
    property Password : string read fPassword write fPassword;

    property ProgressEvent : TProgressEvent read fProgressEvent write fProgressEvent;
  end;

//------------------------------------------------------------------------------
implementation

uses
  SysUtils,
  StrUtils,
  omniXML,
  logutil,
  Forms,
  Graphics,
  Windows;

{ TUsageDataReporting }
//------------------------------------------------------------------------------
procedure TUsageDataReporting.SetupDatabase(aHostName, aDatabase, aUserName, aPassword: string);
begin
  fSQLConnection := TSQLConnection.Create(Nil);
  fSQLConnection.DriverName    := 'MSSQL';
  fSQLConnection.GetDriverFunc := 'getSQLDriverMSSQL';
  fSQLConnection.LibraryName   := 'dbxmss30.dll';
  fSQLConnection.VendorLib     := 'oledb';
  fSQLConnection.Connected     := false;

  fSQLConnection.Params.Clear;
  fSQLConnection.Params.Add('SchemaOverride=%.dbo');
  fSQLConnection.Params.Add('DriverUnit=DBXDynalink');
  fSQLConnection.Params.Add('DriverPackageLoader=TDBXDynalinkDriverLoader,DBXDynalinkDriver100.bpl');
  fSQLConnection.Params.Add('DriverAssemblyLoader=Borland.Data.TDBXDynalinkDriverLoader,Borland.Data.DbxDynalinkDriver,Version=11.0.5000.0,Culture=neutral,PublicKeyToken=91d62ebb5b0d1b1b');
  fSQLConnection.Params.Add('MetaDataPackageLoader=TDBXMsSqlMetaDataCommandFactory,DbxReadOnlyMetaData100.bpl');
  fSQLConnection.Params.Add('MetaDataAssemblyLoader=Borland.Data.TDBXMsSqlMetaDataCommandFactory,Borland.Data.DbxReadOnlyMetaData,Version=11.0.5000.0,Culture=neutral,PublicKeyToken=91d62ebb5b0d1b1b');
  fSQLConnection.Params.Add('HostName='  + aHostName);
  fSQLConnection.Params.Add('DataBase='  + aDatabase);
  fSQLConnection.Params.Add('User_Name=' + aUserName);
  fSQLConnection.Params.Add('Password='  + aPassword);
  fSQLConnection.Params.Add('BlobSize=-1');
  fSQLConnection.Params.Add('ErrorResourceFile=');
  fSQLConnection.Params.Add('LocaleCode=0000');
  fSQLConnection.Params.Add('MSSQL TransIsolation=ReadCommited');
  fSQLConnection.Params.Add('OS Authentication=False');
  fSQLConnection.Params.Add('Prepare SQL=False');

  fSQLDataSet := TSQLDataSet.Create(Nil);
  fSQLDataSet.SQLConnection  := fSQLConnection;
  fSQLDataSet.DbxCommandType := 'Dbx.SQL';
  fSQLDataSet.SchemaName     := 'Dbo';
  fSQLDataSet.Active         := false;
end;

//------------------------------------------------------------------------------
constructor TUsageDataReporting.Create;
begin
  fOfficeDataModule := TDataModuleOffice.Create( nil);
end;

//------------------------------------------------------------------------------
destructor TUsageDataReporting.Destroy;
begin
  FreeandNil(fOfficeDataModule);
  FreeandNil(fSQLDataSet);
  FreeandNil(fSQLConnection);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TUsageDataReporting.Connect;
begin
  SetupDatabase(fHostName, fDatabase, fUserName, fPassword);
  fSQLConnection.Connected := true;
end;

//------------------------------------------------------------------------------
procedure TUsageDataReporting.Disconnect;
begin
  if Assigned(fSQLConnection) then
    fSQLConnection.Connected := false;
end;

//------------------------------------------------------------------------------
function TUsageDataReporting.ExcelAddress(const aValue: integer; aRow: integer): string;
var
  i : integer;
  Col : integer;
begin
  Col := aValue + 1;  //value starts at 0 for first col
  i   := 0;
  while Col > 26 do begin
     Inc( i);
     Col := Col - 26
  end;
  if i > 0 then
     result := Chr( 64 + i) + Chr( 64 + Col)
  else
     result := Chr(64 + Col);

  result := result + inttostr( aRow);
end;

//------------------------------------------------------------------------------
procedure TUsageDataReporting.SetRangeToHeading(const aExcelRange : TOpExcelRange);
begin
  aExcelRange.FontColor := clWhite;
  aExcelRange.Color := $AA0000;
  aExcelRange.Borders := [xlbLeft, xlbRight, xlbTop, xlbBottom];
  aExcelRange.BorderStyle := xlblsContinuous;
  aExcelRange.BorderLineWeight := xlbwThin;
end;

//------------------------------------------------------------------------------
procedure TUsageDataReporting.SetRangeToBorder(const aExcelRange : TOpExcelRange);
begin
  aExcelRange.Borders := [xlbLeft, xlbRight, xlbTop, xlbBottom];
  aExcelRange.BorderStyle := xlblsContinuous;
  aExcelRange.BorderLineWeight := xlbwThin;
end;

//------------------------------------------------------------------------------
procedure TUsageDataReporting.FeatureUsageReportMainPage(const aWorkbook : TOpExcelWorkbook;
                                                         const aWorksheet: TOpExcelWorksheet;
                                                         aFeatureCount: integer);
var
  ExcelRange : TOpExcelRange;
  FeatureIndex : integer;
begin
  aWorksheet.Name        := 'Summary';
  aWorksheet.DisplayName := 'Summary';

  ExcelRange := aWorksheet.Ranges.Add;
  ExcelRange.Address := ExcelAddress(1, 2);
  ExcelRange.Value   := 'Usage Report Summary for the Period 2016-05-25 to 2016-06-15';

  ExcelRange.Address := ExcelAddress(2, 4);
  ExcelRange.Value   := 'New Zealand';
  ExcelRange.Address := ExcelAddress(6, 4);
  ExcelRange.Value   := 'Australia';

  ExcelRange.Address := ExcelAddress(1, 5);
  ExcelRange.Value   := 'Usage Group Name';
  SetRangeToBorder(ExcelRange);
  ExcelRange.Address := ExcelAddress(2, 5);
  ExcelRange.Value   := 'Prac Count';
  SetRangeToBorder(ExcelRange);
  ExcelRange.Address := ExcelAddress(3, 5);
  ExcelRange.Value   := 'Prac Percent';
  SetRangeToBorder(ExcelRange);
  ExcelRange.Address := ExcelAddress(4, 5);
  ExcelRange.Value   := 'Usage Count';
  SetRangeToBorder(ExcelRange);
  ExcelRange.Address := ExcelAddress(5, 5);
  ExcelRange.Value   := 'Usage Avg per Prac';
  SetRangeToBorder(ExcelRange);
  ExcelRange.Address := ExcelAddress(6, 5);
  ExcelRange.Value   := 'Prac Count';
  SetRangeToBorder(ExcelRange);
  ExcelRange.Address := ExcelAddress(7, 5);
  ExcelRange.Value   := 'Prac Percent';
  SetRangeToBorder(ExcelRange);
  ExcelRange.Address := ExcelAddress(8, 5);
  ExcelRange.Value   := 'Usage Count';
  SetRangeToBorder(ExcelRange);
  ExcelRange.Address := ExcelAddress(9, 5);
  ExcelRange.Value   := 'Usage Avg per Prac';
  SetRangeToBorder(ExcelRange);

  for FeatureIndex := 1 to aFeatureCount do
  begin
    ExcelRange.Address := ExcelAddress(1, 5 + FeatureIndex);
    ExcelRange.Value   := aWorkbook.Worksheets[FeatureIndex].Name;
    ExcelRange.Address := ExcelAddress(2, 5 + FeatureIndex);
    ExcelRange.Value   := '=''' + aWorkbook.Worksheets[FeatureIndex].Name + '''!C5';
    ExcelRange.Address := ExcelAddress(3, 5 + FeatureIndex);
    ExcelRange.Value   := '=''' + aWorkbook.Worksheets[FeatureIndex].Name + '''!C7';
    ExcelRange.AsRange.NumberFormat := '0.0%';
    ExcelRange.Address := ExcelAddress(4, 5 + FeatureIndex);
    ExcelRange.Value   := '=''' + aWorkbook.Worksheets[FeatureIndex].Name + '''!C9';
    ExcelRange.Address := ExcelAddress(5, 5 + FeatureIndex);
    ExcelRange.Value   := '=''' + aWorkbook.Worksheets[FeatureIndex].Name + '''!C10';
    ExcelRange.AsRange.NumberFormat := '0.0';
    ExcelRange.Address := ExcelAddress(6, 5 + FeatureIndex);
    ExcelRange.Value   := '=''' + aWorkbook.Worksheets[FeatureIndex].Name + '''!F5';
    ExcelRange.Address := ExcelAddress(7, 5 + FeatureIndex);
    ExcelRange.Value   := '=''' + aWorkbook.Worksheets[FeatureIndex].Name + '''!F7';
    ExcelRange.AsRange.NumberFormat := '0.0%';
    ExcelRange.Address := ExcelAddress(8, 5 + FeatureIndex);
    ExcelRange.Value   := '=''' + aWorkbook.Worksheets[FeatureIndex].Name + '''!F9';
    ExcelRange.Address := ExcelAddress(9, 5 + FeatureIndex);
    ExcelRange.Value   := '=''' + aWorkbook.Worksheets[FeatureIndex].Name + '''!F10';
    ExcelRange.AsRange.NumberFormat := '0.0';
  end;

  ExcelRange.Address := 'B6:B' + inttostr(5+aFeatureCount);
  ExcelRange.ColumnWidth := 25;
  SetRangeToBorder(ExcelRange);

  ExcelRange.Address := 'C6:C' + inttostr(5+aFeatureCount);
  ExcelRange.ColumnWidth := 12;
  SetRangeToBorder(ExcelRange);

  ExcelRange.Address := 'D6:D' + inttostr(5+aFeatureCount);
  ExcelRange.ColumnWidth := 12;
  SetRangeToBorder(ExcelRange);

  ExcelRange.Address := 'E6:E' + inttostr(5+aFeatureCount);
  ExcelRange.ColumnWidth := 12;
  SetRangeToBorder(ExcelRange);

  ExcelRange.Address := 'F6:F' + inttostr(5+aFeatureCount);
  ExcelRange.ColumnWidth := 18;
  SetRangeToBorder(ExcelRange);

  ExcelRange.Address := 'G6:G' + inttostr(5+aFeatureCount);
  ExcelRange.ColumnWidth := 12;
  SetRangeToBorder(ExcelRange);

  ExcelRange.Address := 'H6:H' + inttostr(5+aFeatureCount);
  ExcelRange.ColumnWidth := 12;
  SetRangeToBorder(ExcelRange);

  ExcelRange.Address := 'I6:I' + inttostr(5+aFeatureCount);
  ExcelRange.ColumnWidth := 12;
  SetRangeToBorder(ExcelRange);

  ExcelRange.Address := 'J6:J' + inttostr(5+aFeatureCount);
  ExcelRange.ColumnWidth := 18;
  SetRangeToBorder(ExcelRange);
end;

//------------------------------------------------------------------------------
procedure TUsageDataReporting.BkHandlerFeatureUsageReport(const aWorksheet: TOpExcelWorksheet;
                                                          aDateDataStartsStr: string;
                                                          aNZPracCount, aAUPracCount: integer);
const
  USAGE_FEATURE_SQL = 'select CountryId, ' +
                      'CODE, ' +
                      'sum(UsageCount) as UsageCount ' +
                      'from ' +
                      '(select PRA.CountryId, ' +
                      'PRA.CODE, ' +
                      'FET.COUNT as UsageCount ' +
                      'from Feature FET ' +
                      'left join ' +
                      'FeatureType  FTT on FET.FeatureTypeId = FTT.Id ' +
                      'left join ' +
                      'PracticeInfo PRA on FET.PracticeInfoId = PRA.id ' +
                      'where FTT.Id in (%s) ' +
                      'and FET.UploadDateTime > ''%s'') CHK ' +
                      'group by CountryId, CODE ' +
                      'order by CountryId, CODE ';
var
  ExcelRange : TOpExcelRange;
  PrevCountryId : integer;
  CountryId : integer;
  PracCode  : string;
  UsageCount : integer;
  CountryOffset : integer;
  CurrentLineNo : integer;
  NZMaxLineNo : integer;
  AUMaxLineNo : integer;
  DataLines : integer;
begin
  Forms.Application.ProcessMessages;

  aWorksheet.Name        := 'BkHandler';
  aWorksheet.DisplayName := 'BkHandler';

  // Write the Data to the current Sheet
  ExcelRange := aWorksheet.Ranges.Add;
  PrevCountryId := 1;
  CountryOffset := 0;
  CurrentLineNo := 14;
  NZMaxLineNo := 13;
  AUMaxLineNo := 13;
  DataLines := 1;
  fSQLDataSet.CommandText := Format(USAGE_FEATURE_SQL, ['168, 242', aDateDataStartsStr]);
  fSQLDataSet.Prepared := true;
  fSQLDataSet.Open;

  try
    while (not fSQLDataSet.Eof) do
    begin
      CountryId  := fSQLDataSet.FieldByName('CountryId').AsInteger;
      PracCode   := fSQLDataSet.FieldByName('Code').AsString;
      UsageCount := fSQLDataSet.FieldByName('UsageCount').AsInteger;

      if PrevCountryId <> CountryId then
      begin
        CountryOffset := 3;
        CurrentLineNo := 14;
        PrevCountryId := CountryId;
      end;

      if CountryId = 1 then
        NZMaxLineNo := CurrentLineNo
      else
        AUMaxLineNo := CurrentLineNo;

      ExcelRange.Address := ExcelAddress( 1 + CountryOffset , CurrentLineNo);
      ExcelRange.Value   := PracCode;

      ExcelRange.Address := ExcelAddress( 2 + CountryOffset , CurrentLineNo);
      ExcelRange.Value   := UsageCount;


      if Assigned(fProgressEvent) then
      begin
        if Frac(DataLines/100) = 0 then
        begin
          fProgressEvent(168, DataLines);
        end;
      end;

      inc(DataLines);
      inc(CurrentLineNo);
      fSQLDataSet.Next;
    end;
  finally
    fSQLDataSet.Close;
  end;

  BuildFeatureHeader(aWorksheet, ExcelRange, 'BkHandler',
                     aDateDataStartsStr, aNZPracCount, aAUPracCount,
                     '2016-05-25 to 2016-06-15', NZMaxLineNo, AUMaxLineNo);
end;

//------------------------------------------------------------------------------
procedure TUsageDataReporting.BuildFeatureHeader(const aWorksheet: TOpExcelWorksheet;
                                                 const aExcelRange : TOpExcelRange;
                                                 aFeatureGroupName, aDateDataStartsStr: string;
                                                 aNZPracCount, aAUPracCount: integer;
                                                 aHeaderPeriodStr : string;
                                                 aNZMaxLineNo, aAUMaxLineNo : integer);
begin
  aExcelRange.Address := 'B13:B' + inttostr(aNZMaxLineNo);
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := 'C13:C' + inttostr(aNZMaxLineNo);
  SetRangeToBorder(aExcelRange);

  aExcelRange.Address := 'E13:E' + inttostr(aAUMaxLineNo);
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := 'F13:F' + inttostr(aAUMaxLineNo);
  SetRangeToBorder(aExcelRange);

  // Write the heading data to the Current Sheet
  aExcelRange.Address := ExcelAddress(0, 1);
  aExcelRange.ColumnWidth := 4;
  aExcelRange.Address := ExcelAddress(1, 1);
  aExcelRange.ColumnWidth := 21;
  aExcelRange.Address := ExcelAddress(2, 1);
  aExcelRange.ColumnWidth := 9;
  aExcelRange.Address := ExcelAddress(3, 1);
  aExcelRange.ColumnWidth := 4;
  aExcelRange.Address := ExcelAddress(4, 1);
  aExcelRange.ColumnWidth := 21;
  aExcelRange.Address := ExcelAddress(5, 1);
  aExcelRange.ColumnWidth := 9;

  aExcelRange.Address := ExcelAddress(1, 2);
  aExcelRange.Value   := aFeatureGroupName;
  aExcelRange.Address := ExcelAddress(2, 2);
  aExcelRange.Value   := 'for the Period ' + aHeaderPeriodStr;

  aExcelRange.Address := ExcelAddress(1, 4);
  aExcelRange.Value   := 'Practices';
  aExcelRange.Address := ExcelAddress(4, 4);
  aExcelRange.Value   := 'Practices';

  aExcelRange.Address := ExcelAddress(1, 5);
  aExcelRange.Value   := 'Using ' + aFeatureGroupName;
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(2, 5);
  aExcelRange.Value   := (aNZMaxLineNo - 13);
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(4, 5);
  aExcelRange.Value   := 'Using ' + aFeatureGroupName;
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(5, 5);
  aExcelRange.Value   := (aAUMaxLineNo - 13);
  SetRangeToBorder(aExcelRange);

  aExcelRange.Address := ExcelAddress(1, 6);
  aExcelRange.Value   := 'Total';
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(2, 6);
  aExcelRange.Value   := aNZPracCount;
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(4, 6);
  aExcelRange.Value   := 'Total';
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(5, 6);
  aExcelRange.Value   := aAUPracCount;
  SetRangeToBorder(aExcelRange);

  aExcelRange.Address := ExcelAddress(2, 7);
  if (aNZMaxLineNo - 13) = 0 then
    aExcelRange.Value   := 0
  else
    aExcelRange.Value   := '=C5/C6';
  aExcelRange.AsRange.NumberFormat := '0.0%';
  aExcelRange.Address := ExcelAddress(5, 7);
  if (aAUMaxLineNo - 13) = 0 then
    aExcelRange.Value   := 0
  else
    aExcelRange.Value   := '=F5/F6';
  aExcelRange.AsRange.NumberFormat := '0.0%';

  aExcelRange.Address := ExcelAddress(1, 9);
  aExcelRange.Value   := 'Usage Count';
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(2, 9);
  aExcelRange.Value   := format('=SUM(C15:C%s)',[inttostr(aNZMaxLineNo)]);
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(4, 9);
  aExcelRange.Value   := 'Usage Count';
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(5, 9);
  aExcelRange.Value   := format('=SUM(F15:F%s)',[inttostr(aAUMaxLineNo)]);
  SetRangeToBorder(aExcelRange);

  aExcelRange.Address := ExcelAddress(1, 10);
  aExcelRange.Value   := 'Avg usage per Practice';
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(2, 10);
  if (aNZMaxLineNo - 13) = 0 then
    aExcelRange.Value := 0
  else
    aExcelRange.Value := '=C9/C5';
  SetRangeToBorder(aExcelRange);
  aExcelRange.AsRange.NumberFormat := '0.0';
  aExcelRange.Address := ExcelAddress(4, 10);
  aExcelRange.Value   := 'Avg usage per Practice';
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(5, 10);
  if (aAUMaxLineNo - 13) = 0 then
    aExcelRange.Value := 0
  else
    aExcelRange.Value := '=F9/F5';
  SetRangeToBorder(aExcelRange);
  aExcelRange.AsRange.NumberFormat := '0.0';

  aExcelRange.Address := ExcelAddress(1, 12);
  aExcelRange.Value   := 'New Zealand';
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(4, 12);
  aExcelRange.Value   := 'Australia';
  SetRangeToBorder(aExcelRange);

  aExcelRange.Address := ExcelAddress(1, 13);
  aExcelRange.Value   := 'Practice Code';
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(2, 13);
  aExcelRange.Value   := 'Count';
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(4, 13);
  aExcelRange.Value   := 'Practice Code';
  SetRangeToBorder(aExcelRange);
  aExcelRange.Address := ExcelAddress(5, 13);
  aExcelRange.Value   := 'Count';
  SetRangeToBorder(aExcelRange);
end;

//------------------------------------------------------------------------------
procedure TUsageDataReporting.RunOneFeatureUsageReport(const aWorksheet: TOpExcelWorksheet;
                                                       aFeatureGroupId : integer;
                                                       aFeatureGroupName : string;
                                                       aDateDataStartsStr : string;
                                                       aNZPracCount : integer;
                                                       aAUPracCount : integer);
const
  USAGE_FEATURE_SQL = 'select CountryId, ' +
                      'CODE, ' +
                      'sum(UsageCount) as UsageCount ' +
                      'from ' +
                      '(select PRA.CountryId, ' +
                      'PRA.CODE, ' +
                      'FET.COUNT as UsageCount ' +
                      'from Feature FET ' +
                      'left join ' +
                      'FeatureType  FTT on FET.FeatureTypeId = FTT.Id ' +
                      'left join ' +
                      'PracticeInfo PRA on FET.PracticeInfoId = PRA.id ' +
                      'where featureGroupId = %s ' +
                      'and FET.UploadDateTime > ''%s'') CHK ' +
                      'group by CountryId, CODE ' +
                      'order by CountryId, CODE ';
var
  ExcelRange : TOpExcelRange;
  PrevCountryId : integer;
  CountryId : integer;
  PracCode  : string;
  UsageCount : integer;
  CountryOffset : integer;
  CurrentLineNo : integer;
  NZMaxLineNo : integer;
  AUMaxLineNo : integer;
  DataLines : integer;
begin
  Forms.Application.ProcessMessages;

  aWorksheet.Name        := aFeatureGroupName;
  aWorksheet.DisplayName := aFeatureGroupName;

  // Write the Data to the current Sheet
  ExcelRange := aWorksheet.Ranges.Add;
  PrevCountryId := 1;
  CountryOffset := 0;
  CurrentLineNo := 14;
  NZMaxLineNo := 13;
  AUMaxLineNo := 13;
  DataLines := 1;
  fSQLDataSet.CommandText := Format(USAGE_FEATURE_SQL, [inttostr(aFeatureGroupId), aDateDataStartsStr]);
  fSQLDataSet.Prepared := true;
  fSQLDataSet.Open;

  try
    while (not fSQLDataSet.Eof) do
    begin
      CountryId  := fSQLDataSet.FieldByName('CountryId').AsInteger;
      PracCode   := fSQLDataSet.FieldByName('Code').AsString;
      UsageCount := fSQLDataSet.FieldByName('UsageCount').AsInteger;

      if PrevCountryId <> CountryId then
      begin
        CountryOffset := 3;
        CurrentLineNo := 14;
        PrevCountryId := CountryId;
      end;

      if CountryId = 1 then
        NZMaxLineNo := CurrentLineNo
      else
        AUMaxLineNo := CurrentLineNo;

      ExcelRange.Address := ExcelAddress( 1 + CountryOffset , CurrentLineNo);
      ExcelRange.Value   := PracCode;

      ExcelRange.Address := ExcelAddress( 2 + CountryOffset , CurrentLineNo);
      ExcelRange.Value   := UsageCount;


      if Assigned(fProgressEvent) then
      begin
        if Frac(DataLines/100) = 0 then
        begin
          fProgressEvent(aFeatureGroupId, DataLines);
        end;
      end;

      inc(DataLines);
      inc(CurrentLineNo);
      fSQLDataSet.Next;
    end;
  finally
    fSQLDataSet.Close;
  end;

  BuildFeatureHeader(aWorksheet, ExcelRange, aFeatureGroupName,
                     aDateDataStartsStr, aNZPracCount, aAUPracCount,
                     '2016-05-25 to 2016-06-15', NZMaxLineNo, AUMaxLineNo);
end;

//------------------------------------------------------------------------------
procedure TUsageDataReporting.RunFeatureUsageReport(aFileName : string);
const
  USAGE_PRAC_COUNT_SQL = 'Select CountryId, ' +
                         'Count(1) as PracCount ' +
                         'from ' +
                         '(select CountryId, ' +
                         'CODE ' +
                         'from ' +
                         '(select PRA.CountryId, ' +
                         'PRA.CODE, ' +
                         'FET.COUNT as UsageCount ' +
                         'from Feature      FET ' +
                         'left join ' +
                         'FeatureType  FTT on FET.FeatureTypeId = FTT.Id ' +
                         'left join ' +
                         'PracticeInfo PRA on FET.PracticeInfoId = PRA.id ' +
                         'where FET.UploadDateTime > ''%s'') CHK ' +
                         'group by CountryId, ' +
                         'CODE) PRA ' +
                         'group by CountryId ' +
                         'order by CountryId ';
var
  StartDateStr : string;
  NZPracCount : integer;
  AUPracCount : integer;
begin
  Forms.Application.ProcessMessages;
  StartDateStr := '2016-05-25 00:00:00';

  fSQLDataSet.CommandText := Format(USAGE_PRAC_COUNT_SQL, [StartDateStr]);
  fSQLDataSet.Prepared := true;
  fSQLDataSet.Open;
  try
    while (not fSQLDataSet.Eof) do
    begin
      if fSQLDataSet.FieldByName('CountryId').AsInteger = 1 then
        NZPracCount := fSQLDataSet.FieldByName('PracCount').AsInteger
      else
        AUPracCount := fSQLDataSet.FieldByName('PracCount').AsInteger;

      fSQLDataSet.Next;
    end;
  finally
    fSQLDataSet.Close;
  end;

  fOfficeDataModule.OpExcel1.Visible     := False;
  fOfficeDataModule.OpExcel1.Interactive := False;
  fOfficeDataModule.OpExcel1.Connected   := true;
  fOfficeDataModule.OpExcel1.WindowState := xlwsNormal;
  fOfficeDataModule.OpExcel1.Caption     := 'Feature Usage';
  fOfficeDataModule.OpExcel1.Connected := true;
  fOfficeDataModule.OpExcel1.Workbooks.Add;

  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 12, 'Do Coding', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 39, 'Historical Entries', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 21, 'Manual Entries', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 3, 'Budgets', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 36, 'Cash Journals', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 2, 'Accrual Journals', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 40, 'Non-Transferring Journals', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 26, 'Opening Balances', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 41, 'Year End Balances', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 16, 'Find and Replace', StartDateStr, NZPracCount, AUPracCount);

  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 31, 'Scheduled Reports', StartDateStr, NZPracCount, AUPracCount);

  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 25, 'Graphs', StartDateStr, NZPracCount, AUPracCount);

  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 13, 'Edit Superfund', StartDateStr, NZPracCount, AUPracCount);

  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 20, 'Maintain Chart', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 11, 'Divisions', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 34, 'Sub Groups', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 19, 'BAS Template', StartDateStr, NZPracCount, AUPracCount);

  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 27, 'Payees', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 18, 'Jobs', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 22, 'Memorised Entries', StartDateStr, NZPracCount, AUPracCount);

  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 4, 'CheckIn CheckOut', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 5, 'ECFH', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 23, 'Notes', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 24, 'Notes Online', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 1, 'CCH', StartDateStr, NZPracCount, AUPracCount);

  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 8, 'Combine Bank Accounts', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 9, 'Combine Manual Bank Accounts', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 30, 'Purge Entries', StartDateStr, NZPracCount, AUPracCount);

  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 6, 'Client Groups', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 7, 'Client Types', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 14, 'Email Signature', StartDateStr, NZPracCount, AUPracCount);
  RunOneFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, 32, 'Email', StartDateStr, NZPracCount, AUPracCount);
  BkHandlerFeatureUsageReport(fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Add, StartDateStr, NZPracCount, AUPracCount);


  FeatureUsageReportMainPage(fOfficeDataModule.OpExcel1.Workbooks[0],
                             fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets[0], fOfficeDataModule.OpExcel1.Workbooks[0].Worksheets.Count-1);

  fOfficeDataModule.OpExcel1.Workbooks[0].SaveAs(aFilename);
end;

end.


