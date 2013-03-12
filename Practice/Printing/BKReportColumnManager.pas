unit BKReportColumnManager;

interface

uses
  Classes, SysUtils, NewReportUtils, NewReportObj, BKDEFS, bkConst, RepCols,
  TravList , OmniXML, OmniXMLUtils, RptParams, clObj32;

const
  COLUMN_MGR_VERSION = 1;

  DEFAULT_GAP = GCGap;
  DEFAULT_LEFT_MARGIN = GCLeft;
  MAX_TEXT_FIELD_SIZE = 40;
  MIN_TEXT_FIELD_SIZE = 20;
  PORTRAIT_WIDTH_MM = 210;
  LANDSCAPE_WIDTH_MM = 297;
  LANDSCAPE_RATIO = PORTRAIT_WIDTH_MM / LANDSCAPE_WIDTH_MM;

  BOX_EMPTY  = '[  ]';
  BOX_TICKED = '[x]';

  //used for writting node values as stings
  PageOrientationArray: array[0..1] of string = ('Portrait', 'Landscape');

  //Format string
//  NUMBER_FORMAT = '#,##0.00;(#,##0.00)';
//  DOLLAR_FORMAT = '$#,##0.00;$(#,##0.00)';
//  NUMBER_FORMAT = '#,##0.00;(#,##0.00);-'; //This format string is also used
//  DOLLAR_FORMAT = '$#,##0.00;$(#,##0.00);-';
  QUANTITY_FORMAT = '#,##0.0000;(#,##0.0000);-';
  BAL_FORMAT = '#,##0.00 "OD ";#,##0.00 "IF "; ';
  INTEGER_FORMAT = '#,##0;#,##0';

  //Data Units
  NO_DATA_UNIT = 'NONE';
  BKTX = 'BKTXIO'; //Transaction
  BKDS = 'BKDSIO'; //Disection
  BKCH = 'BKCHIO'; //Chart of Accounts
  BKJH = 'BKJHIO'; //Job
  BKPD = 'BKPDIO'; //Payee Detail

  //Calculated field tokens start at 1M
  CALC_FIELD = 1000000;

  //Default field sizes
  AMOUNT_SIZE   = 12.0;
  BYTE_SIZE     =  4.0;
  QUANTITY_SIZE =  6.0;
  DATE_SIZE     =  7.0;
  INTEGER_SIZE  =  7.0;
  CHECKBOX_SIZE =  5.0;

  //Transaction field tokens - these should match BKtxIO tokens which are
  //unfortunately in the implementation section so they can't be accessed
  tktxType                             = 164 ;
  tktxDate_Presented                   = 166 ;
  tktxDate_Effective                   = 167 ;
  tktxAmount                           = 169 ;
  tktxGST_Class                        = 170 ;
  tktxGST_Amount                       = 171 ;
  tktxQuantity                         = 173 ;
  tktxReference                        = 175 ;
  tktxParticulars                      = 176 ;
  tktxAnalysis                         = 177 ;
  tktxOther_Party                      = 179 ;
  tktxAccount                          = 181 ;
  tktxCoded_By                         = 182 ;
  tktxPayee_Number                     = 183 ;
  tktxNotes                            = 194 ;
  tktxGL_Narration                     = 197 ;
  tktxStatement_Details                = 198 ;
  tktxTax_Invoice_Available            = 199 ;
  tktxJob_Code                         = 240 ;
  tktxForex_Conversion_Rate            = 241 ;
  tktxForeign_Currency_Amount          = 242 ;

  //Chart of Accounts
  tkchAccount_Code                     = 82 ;
  tkchChart_ID                         = 83 ;
  tkchAccount_Description              = 84 ;
  tkchGST_Class                        = 85 ;
  tkchPosting_Allowed                  = 86 ;
  tkchAccount_Type                     = 87 ;
  tkchEnter_Quantity                   = 88 ;
  tkchPrint_in_Division                = 89 ;
  tkchMoney_Variance_Up                = 90 ;
  tkchMoney_Variance_Down              = 91 ;
  tkchPercent_Variance_Up              = 92 ;
  tkchPercent_Variance_Down            = 93 ;
  tkchLast_Years_Totals_SB_Only        = 94 ;
  tkchOpening_Balance_SB_Only          = 95 ;
  tkchSubtype                          = 96 ;
  tkchAlternative_Code                 = 97 ;
  tkchLinked_Account_OS                = 98 ;
  tkchLinked_Account_CS                = 99 ;
  tkchHide_In_Basic_Chart              = 100 ;

  //Job
  tkjhHeading                          = 212 ;
  tkjhDate_Completed                   = 214 ;
  tkjhCode                             = 215 ;

  //Payee Detail
  tkpdNumber                           = 92 ;
  tkpdName                             = 93 ;

  //Balance - calculated field so have too make-up a token
//  txTemp_Balance                       = CALC_FIELD + 1;

type
  TColumnType = (ctAuto, ctJob, ctJobFormat, ctJobAverage, ctAverage, ctFormat);

  TReportColumnList = class;

  TReportColumnItem = class(TObject)
  private
    FColumnType: TColumnType;
    FDataToken: integer;
    FDataUnit: string;
    FDisableColumn: boolean;
    FDoTotal: Boolean;
    FFormatString: string;
    FFormatString2: string;
    FGap: Double;
    FJustification: TJustifyType;
    FOutputCol: boolean;
    FRenderStyle: TRenderStyle;
    FTitle: string;
    FWidthPercent: Double;
    procedure SetDataToken(const Value: integer);
    procedure SetDataUnit(const Value: string);
    procedure SetWidthPercent(const Value: double);
    procedure SetDisableColumn(const Value: Boolean);
  public
    FWrapText: TStringList;
    constructor Create;
    destructor Destroy; override;
    procedure ReadFromNode(Value: IXmlNode);
    procedure SaveToNode(Value: IXmlNode);
    property DataToken: integer read FDataToken write SetDataToken;
    property DataUnit: string read FDataUnit write SetDataUnit;
    property DisableColumn: Boolean read FDisableColumn write SetDisableColumn;
    property OutputCol: Boolean read FOutputCol;
    property Title: string read FTitle;
    property WidthPercent: double read FWidthPercent write SetWidthPercent;
  end;

  TReportColumnList = class(TObject)
  private
    FAccountingSystemUsed: integer;
    FCountry: integer;
    FLeftMargin: double;
    FTravManager: TTravManagerWithNewReport;
    FCurrentColumn: integer;
    FVersion: integer;
    FTaxName: string;
    FHasForeignCurrencyAccounts: Boolean;
    function GetColumns(Index: integer): TReportColumnItem;
    function GetCount: integer;
    procedure ScaleColumns;
    procedure SetOrientation(const Value: integer);
    procedure SetWrapColumns(const Value: boolean);
    procedure SetAccountingSystemUsed(const Value: integer);
    procedure SetCountry(const Value: integer);
    procedure SetHasForeignCurrencyAccounts(const Value: Boolean);
  protected
    NUMBER_FORMAT: string;
    DOLLAR_FORMAT: string;
    FColumnList: TList;
    FBKReport: TBKReport;
    FClient: TClientObj;
    FIsDefault: Boolean; //default columns and witdhs. Change to TTravManagerClass
    FOrientation: integer;
    FReportSettings: TRPTParameters;
    FVerticalColumnLines: boolean;
    FWrapColumns: Boolean;
    FWrapLineCount: Integer;
    function CanClipColumn(aColumnItem: TReportColumnItem): boolean; virtual; abstract;
    function CanWrapColumn(aColumnItem: TReportColumnItem): boolean; virtual; abstract;
    function GetFieldSize(aReportColumnItem: TReportColumnItem): double; virtual; abstract;
    function GetColumnTitle(aDataUnit: string; aDataToken: integer): string; virtual;
    procedure AddColumn(aDataUnit: string; aDataToken: integer;
                        aPercentWidth: double = 0.0;
                        aJustification: TJustifyType = jtLeft;
                        aColumnType: TColumnType = ctAuto;
                        aFormatString: string = '';
                        aFormatString2: string = '';
                        aGap: Double = DEFAULT_GAP;
                        DoTotal: Boolean = False;
                        OutputCol: boolean = False;
                        DisableCol: boolean = False);
    procedure AddReportColumn(aReportColumnItem: TReportColumnItem); virtual;
    procedure AutoCalcColumnWidths; virtual; abstract;
    procedure ClearColumnList;
    procedure OutputColumn(aReportColumnItem: TReportColumnItem); virtual; abstract;
    procedure SaveReportSettings; virtual; abstract;
    procedure WrapColumn(aReportColumnItem: TReportColumnItem; Text: WideString);
    procedure OutputWrappedColumns; virtual;
  public
    constructor Create(aClient: TClientObj);
    destructor Destroy; override;
    procedure AddReportColumns(aBKReport: TBKReport); virtual;
    procedure ExchangeColumns(Index1, Index2: Integer);
    procedure Move(Index1, Index2: integer);
    procedure OutputCol(Index: integer; Value: Boolean);
    procedure EnableCol(Index: Integer; Value: Boolean);
    procedure OutputColumns(aBKReport: TBKReport;
                            aTravManager: TTravManagerWithNewReport); virtual;
    procedure SaveToNode(Value: IXmlNode);
    procedure SaveColumnListSettingsToNode(Value: IXmlNode); virtual;
    procedure ReadColumnListSettingsFromNode(Value: IXmlNode); virtual;
    procedure SetupColumns; virtual; abstract;
    procedure ReadFromNode(Value: IXmlNode);
    property BKReport: TBKReport read FBKReport;
    property Columns[index: integer]: TReportColumnItem read GetColumns;
    property Count: integer read GetCount;
    property Country: integer read FCountry write SetCountry;
    property AccountingSystemUsed: integer read FAccountingSystemUsed write SetAccountingSystemUsed;
    property IsDefault: Boolean read FIsDefault;
    property Orientation: integer read FOrientation write SetOrientation;
    property TravManager: TTravManagerWithNewReport read FTravManager;
    property WrapColumns: boolean read FWrapColumns write SetWrapColumns;
    property TaxName: string read FTaxName;
    property HasForeignCurrencyAccounts: Boolean read FHasForeignCurrencyAccounts write SetHasForeignCurrencyAccounts;
  end;

  TCodingReportColumnList = class(TReportColumnList)
  private
//    FAccountBalance: Double;
    procedure CR_EnterAccount(Sender: TObject);
    procedure CR_EnterEntry(Sender: TObject);
    procedure OutputDissection(aReportColumnItem: TReportColumnItem);
    procedure OutputTransaction(aReportColumnItem: TReportColumnItem);
  protected
    function CanClipColumn(aColumnItem: TReportColumnItem): boolean; override;
    function CanWrapColumn(aColumnItem: TReportColumnItem): boolean; override;
    function GetColumnTitle(aDataUnit: string; aDataToken: integer): string; override;
    function GetFieldSize(aReportColumnItem: TReportColumnItem): double; override;
    procedure AutoCalcColumnWidths; override;
    procedure OutputColumn(aReportColumnItem: TReportColumnItem); override;
    procedure SaveReportSettings; override;
  public
    procedure SetupColumns; override;
  end;

implementation

uses
  MoneyUtils,
  Software,
  MoneyDef,
  Globals, bkdateutils, PayeeObj, RptCoding, GenUtils, TransactionUtils,
  CodingRepDlg, baObj32, UserReportSettings, Math, GSTCALC32,
  rptCodingScheduled, ForexHelpers;

{ TReportColumnItem }

constructor TReportColumnItem.Create;
begin
  FRenderStyle := TRenderStyle.Create;
  FWrapText := TStringList.Create;
end;

destructor TReportColumnItem.Destroy;
begin
  FreeAndNil(FWrapText);
  FRenderStyle.Free;
  inherited;
end;

procedure TReportColumnItem.ReadFromNode(Value: IXmlNode);
begin
  FColumnType := TColumnType(GetNodeTextInt(Value, '_Column_Type', Integer(FColumnType)));
  FDataToken := GetNodeTextInt(Value, '_Data_Token', FDataToken);
  FDataUnit := GetNodeTextStr(Value, '_Data_Unit', FDataUnit);
  FDoTotal := GetNodeTextBool(Value, '_Do_Total', FDoTotal);
  FFormatString := GetNodeTextStr(Value, '_Format_String', FFormatString);
  FFormatString2 := GetNodeTextStr(Value, '_Format_String2', FFormatString2);
  FGap := GetNodeTextReal(Value, '_Gap', FGap);
  FJustification := TJustifyType(GetNodeTextInt(Value, '_Justification', Integer(FJustification)));
  FOutputCol := GetNodeTextBool(Value, '_Output_Col', FOutputCol);
  FTitle := GetNodeTextStr(Value, '_Title', FTitle);
  FWidthPercent := GetNodeTextReal(Value, '_Width_Percent', FWidthPercent);
  FDisableColumn := GetNodeTextBool(Value, '_DisableColumn', FDisableColumn);
end;

procedure TReportColumnItem.SaveToNode(Value: IXmlNode);
begin
  SetNodeTextInt(Value, '_Column_Type', Integer(FColumnType));
  SetNodeTextInt(Value, '_Data_Token', FDataToken);
  SetNodeTextStr(Value, '_Data_Unit', FDataUnit);
  SetNodeTextBool(Value, '_Do_Total',FDoTotal);
  SetNodeTextStr(Value, '_Format_String', FFormatString);
  SetNodeTextStr(Value, '_Format_String2', FFormatString2);
  SetNodeTextReal(Value, '_Gap', FGap);
  SetNodeTextInt(Value, '_Justification', Integer(FJustification));
  SetNodeTextBool(Value, '_Output_Col', FOutputCol);
  SetNodeTextStr(Value, '_Title', FTitle);
  SetNodeTextReal(Value, '_Width_Percent', FWidthPercent);
  SetNodeTextBool(Value, '_DisableColumn', FDisableColumn);
end;

procedure TReportColumnItem.SetDataToken(const Value: integer);
begin
  FDataToken := Value;
end;

procedure TReportColumnItem.SetDataUnit(const Value: string);
begin
  FDataUnit := Value;
end;

procedure TReportColumnItem.SetDisableColumn(const Value: Boolean);
begin
  FDisableColumn := Value;
end;

procedure TReportColumnItem.SetWidthPercent(const Value: double);
begin
  FWidthPercent := Value;
end;

{ TReportColumnList }

procedure TReportColumnList.AddColumn(
                     aDataUnit: string;
                     aDataToken: integer;
                     aPercentWidth: double;
                     aJustification: TJustifyType;
                     aColumnType: TColumnType;
                     aFormatString, aFormatString2: string;
                     aGap: Double; DoTotal,
                     OutputCol: boolean;
                     DisableCol: boolean);
var
  ReportColumnItem: TReportColumnItem;
begin
  //Create column
  ReportColumnItem := TReportColumnItem.Create;

  //Populate column properties
  ReportColumnItem.FColumnType := aColumnType;
  ReportColumnItem.FDataToken := aDataToken;
  ReportColumnItem.FDataUnit := aDataUnit;
  ReportColumnItem.FDoTotal := DoTotal;
  ReportColumnItem.FFormatString := aFormatString;
  ReportColumnItem.FFormatString2 := aFormatString2;
  ReportColumnItem.FGap := aGap;
  ReportColumnItem.FJustification := aJustification;
  ReportColumnItem.FOutputCol := OutputCol;
  ReportColumnItem.FDisableColumn := DisableCol;
//  ReportColumnItem.FTitle := aTitle;
  ReportColumnItem.FTitle := GetColumnTitle(aDataUnit, aDataToken);
  ReportColumnItem.FWidthPercent := aPercentWidth; //Gets calculated later

  //Add to column list
  FColumnList.Add(ReportColumnItem);
end;

procedure TReportColumnList.AddReportColumn(
  aReportColumnItem: TReportColumnItem);
//var
//  RepCol: TReportColumn;
begin
  with aReportColumnItem do begin
    case FColumnType of
      ctAuto       : AddColAuto(FBKReport, FLeftMargin,
                                FWidthPercent, FGap,
                                FTitle, FJustification);
      ctJob        : AddJobColumn(FBKReport, FLeftMargin,
                                  FWidthPercent, FTitle,
                                  FJustification);
      ctJobFormat  : AddJobFormatColumn(FBKReport, FLeftMargin,
                                        FWidthPercent, FTitle,
                                        FJustification, FFormatString,
                                        FFormatString2, FDoTotal);
//        ctJobAverage : AddJobAverageColumn(FBKReport, FLeftMargin,
//                                           FWidthPercent, FTitle, FJustification,
//                                           FFormatString, FDoTotal);
//        ctAverage    : AddAverageColAuto(FBKReport, FLeftMargin,
//                                         FWidthPercent, FGap, FTitle,
//                                         FJustification, FFormatString, FDoTotal);
      ctFormat     : AddFormatColAuto(FBKReport, FLeftMargin,
                                      FWidthPercent, FGap, FTitle,
                                      FJustification, FFormatString,
                                      FFormatString2, FDoTotal);
    end;
    //Set border style - for future use to do Excel type grids
//    FRenderStyle.BorderStyle := [bsTop, bsLeft, bsRight];
//    RepCol.Style.BorderStyle := FRenderStyle.BorderStyle;
  end;
end;

procedure TReportColumnList.AddReportColumns(aBKReport: TBKReport);
var
  i: integer;
begin
  //Save the report
  FBKReport := aBKReport;
  //Clear current columns if any
  aBKReport.Columns.FreeAll;
  //Reset left margin
  FLeftMargin := DEFAULT_LEFT_MARGIN;
  //Save required report settings
  SaveReportSettings;
  //Calculate column widths based on field size
  if IsDefault then
    ScaleColumns
  else
    AutoCalcColumnWidths;
  //Output each column
  for i := 0 to Pred(FColumnList.Count) do begin
    if TReportColumnItem(FColumnList.Items[i]).FOutputCol then
      AddReportColumn(TReportColumnItem(FColumnList.Items[i]));
  end;
end;

procedure TReportColumnList.ClearColumnList;
var
  i: integer;
begin
  for i := 0 to Pred(FColumnList.Count) do
    if Assigned(FColumnList[i]) then
      TReportColumnItem(FColumnList[i]).Free;
  FColumnList.Clear;
end;

constructor TReportColumnList.Create(aClient: TClientObj);
begin
  FColumnList := TList.Create;
  FLeftMargin := DEFAULT_LEFT_MARGIN;
  FClient := aClient;

  FTaxName := 'GST';
  NUMBER_FORMAT := '#,##0.00;(#,##0.00)';
  DOLLAR_FORMAT := '$#,##0.00;$(#,##0.00)';

  if Assigned(FClient) then begin
    FAccountingSystemUsed := aClient.clFields.clAccounting_System_Used;
    FCountry := aClient.clFields.clCountry;
    FTaxName := aClient.TaxSystemNameUC;
    NUMBER_FORMAT := aClient.FmtMoneyStrBracketsNoSymbol;
    DOLLAR_FORMAT := aClient.FmtMoneyStrBrackets;
    HasForeignCurrencyAccounts := AClient.HasForeignCurrencyAccounts
  end;

  SetupColumns;
end;

destructor TReportColumnList.Destroy;
begin
  ClearColumnList;
  FColumnList.Free;

  inherited;
end;

procedure TReportColumnList.ExchangeColumns(Index1, Index2: Integer);
begin
  FColumnList.Exchange(Index1, Index2);
  FIsDefault := False;
end;

function TReportColumnList.GetColumns(Index: integer): TReportColumnItem;
begin
  Result := TReportColumnItem(FColumnList[Index]);
end;

function TReportColumnList.GetColumnTitle(aDataUnit: string; aDataToken: integer): string;
begin
  Result := '';
end;

function TReportColumnList.GetCount: integer;
begin
  Result := FColumnList.Count;
end;

procedure TReportColumnList.Move(Index1, Index2: integer);
begin
  FColumnList.Move(Index1, Index2);
end;                                                                           

procedure TReportColumnList.OutputCol(Index: integer; Value: Boolean);
begin
  if Assigned(TReportColumnItem(FColumnList.Items[Index])) then
    if (TReportColumnItem(FColumnList.Items[Index]).FOutputCol <> Value) then begin
      TReportColumnItem(FColumnList.Items[Index]).FOutputCol := Value;
      FIsDefault := False;
    end;
end;

procedure TReportColumnList.EnableCol(Index: Integer; Value: Boolean);
begin
  if Assigned(TReportColumnItem(FColumnList.Items[Index])) then
    if (TReportColumnItem(FColumnList.Items[Index]).FDisableColumn = Value) then begin
      TReportColumnItem(FColumnList.Items[Index]).FDisableColumn := not Value;
      FIsDefault := False;
    end;
end;
procedure TReportColumnList.OutputColumns(aBKReport: TBKReport;
  aTravManager: TTravManagerWithNewReport);
var
  i: integer;
begin
  FWrapLineCount := 0;
  FCurrentColumn := 0;
  //Save the report and trav manager
  FBKReport := aBKReport;
  FTravManager :=  aTravManager;
  //Output each column
  for i := 0 to Pred(FColumnList.Count) do
    if TReportColumnItem(FColumnList.Items[i]).FOutputCol then begin
      OutputColumn(TReportColumnItem(FColumnList.Items[i]));
      Inc(FCurrentColumn);
    end;
  if FWrapColumns then
    OutputWrappedColumns;
end;

procedure TReportColumnList.OutputWrappedColumns;
var
  i: integer;
  ColumnItem: TReportColumnItem;
  CurrentLine: integer;
  CurrentDetail: TStringList;
begin
  CurrentLine := 0;

  if (FWrapLineCount > 0) then begin
    //Save current detail
    CurrentDetail := TStringList.Create;
    try
      CurrentDetail.Text := FBkReport.CurrDetail.Text;
      //Set required lines
      FBkReport.RequireLines(FWrapLineCount + 1); //allow for line already in buffer
      //Reset current detail
      FBkReport.SetCurrDetail(CurrentDetail);
    finally
      FreeAndNil(CurrentDetail);
    end;
  end;

  while (FWrapLineCount > 0) do begin
    //lines between columns
    if FVerticalColumnLines then
      FBkReport.RenderAllVerticalColumnLines;
    FBkReport.RenderDetailLine;
    for i := 0 to Pred(FColumnList.Count) do begin
      ColumnItem := TReportColumnItem(FColumnList.Items[i]);
      if ColumnItem.FOutputCol then
        if CanWrapColumn(ColumnItem) and (ColumnItem.FWrapText.Count > CurrentLine) then begin
          FBkReport.PutString(ColumnItem.FWrapText[CurrentLine]);
        end else
          FBkReport.SkipColumn;
    end;
    Inc(CurrentLine);
    Dec(FWrapLineCount);
  end;
end;

procedure TReportColumnList.WrapColumn(aReportColumnItem: TReportColumnItem;
  Text: WideString);
const
  MAX_WRAP_LINES = 9; //First line already output
var
  i, ColWidth, OldWidth: Integer;
begin
  aReportColumnItem.FWrapText.Clear;

  Text := Trim(Text);

  //Nothing to do
  if (not FWrapColumns) or (Text = '') then begin
    //Remove CR/LF's
    if (Text <> '') and (Pos(#13#10, Text) > 0) then
      Text := StringReplace(Text, #13#10, ' ', [rfReplaceAll]);
    FBkReport.PutString(Text);
    Exit;
  end;

  //Add text to col stringlist
  aReportColumnItem.FWrapText.Text := Text;

  // Remove any Blank lines..
  for i := Pred(aReportColumnItem.FWrapText.Count) downto 0 do
    if aReportColumnItem.FWrapText[i] = '' then
      aReportColumnItem.FWrapText.Delete(i);

  i := 0;
  while (i < aReportColumnItem.FWrapText.Count) and (i < (MAX_WRAP_LINES + 1)) do begin
    ColWidth := FBKReport.RenderColumnWidth(FCurrentColumn, aReportColumnItem.FWrapText[i]);
    if (ColWidth < Length(aReportColumnItem.FWrapText[i])) then begin
      //line needs to be split
      OldWidth := ColWidth; //store
      while (ColWidth > 0) and (aReportColumnItem.FWrapText[i][ColWidth] <> ' ') do
        Dec(ColWidth);
      if (ColWidth = 0) then
        ColWidth := OldWidth; //unexpected!
      aReportColumnItem.FWrapText.Insert(i + 1,
                                         Copy(aReportColumnItem.FWrapText[i],
                                              ColWidth + 1,
                                              Length(aReportColumnItem.FWrapText[i]) - ColWidth + 1));
      aReportColumnItem.FWrapText[i] := Copy(aReportColumnItem.FWrapText[i], 1, ColWidth);
    end;
    Inc(i);
  end;

  //Output 1st line
  FBkReport.PutString(Trim(aReportColumnItem.FWrapText[0]));
  aReportColumnItem.FWrapText.Delete(0);
  if (aReportColumnItem.FWrapText.Count > FWrapLineCount) then
    if aReportColumnItem.FWrapText.Count > MAX_WRAP_LINES then
      FWrapLineCount := MAX_WRAP_LINES
    else
      FWrapLineCount := aReportColumnItem.FWrapText.Count;
end;

procedure TReportColumnList.ReadColumnListSettingsFromNode(Value: IXmlNode);
begin
  //Version number
  FVersion := GetNodeTextInt(Value, '_Column_Mgr_Version', COLUMN_MGR_VERSION);
  //Default Report
  if FindNode(Value, '_Default_Report') <> nil then
    FIsDefault := GetNodeTextBool(Value, '_Default_Report', FIsDefault)
  else
    FIsDefault := False;
  //Orientation
  FOrientation := LoadBatchIntAsStringValue(Value, 'Orientation',
                                            PageOrientationArray,
                                            FOrientation);
  //Country
  FCountry := GetNodeTextInt(Value, '_Country', FCountry);
  //Superfund ID
  FAccountingSystemUsed := GetNodeTextInt(Value, '_Accounting_System_Used', FAccountingSystemUsed);
end;

procedure TReportColumnList.ReadFromNode(Value: IXmlNode);
var
  i: integer;
  ReportColumn: TReportColumnItem;
  ReportColumnNode: IXMLNode;
  ReportColumnNodes: IXMLNodeList;
  ColumnTitle: string;
begin
  //Read column list settings
  ReadColumnListSettingsFromNode(Value);
  //Columns
  ReportColumnNodes := FilterNodes(Value, '_Report_Column');
  ReportColumnNode := ReportColumnNodes.NextNode;
  if Assigned(ReportColumnNode) then
    ClearColumnList;
  while Assigned(ReportColumnNode) do begin
    ReportColumn := TReportColumnItem.Create;
    try
      ReportColumn.ReadFromNode(ReportColumnNode);
      FColumnList.Add(ReportColumn);
    except
      FreeAndNil(ReportColumn);
      raise;
    end;
    ReportColumnNode := ReportColumnNodes.NextNode;
  end;
  //Check column titles
  for i := 0 to FColumnList.Count - 1 do begin
    //BugzId 11562 - renamed column
    ColumnTitle := GetColumnTitle(Columns[i].FDataUnit, Columns[i].FDataToken);
    if (ColumnTitle <> '') and (Columns[i].FTitle <> ColumnTitle) then
      Columns[i].FTitle := ColumnTitle;
  end;
end;

procedure TReportColumnList.SaveColumnListSettingsToNode(Value: IXmlNode);
begin
  //Version number
  SetNodeTextInt(Value, '_Column_Mgr_Version', COLUMN_MGR_VERSION);
  //Default Report
  SetNodeTextBool(Value, '_Default_Report', FIsDefault);
  //Orientation
  SaveBatchIntAsStringValue(Value, 'Orientation', FOrientation, PageOrientationArray);
  //Country
  SetNodeTextInt(Value, '_Country', FCountry);
  //Superfund ID
  SetNodeTextInt(Value, '_Accounting_System_Used', FAccountingSystemUsed);
end;

procedure TReportColumnList.SaveToNode(Value: IXmlNode);
var
  i: integer;
  ReportColumnNode: IXMLNode;
begin
  //Save column list settings
  SaveColumnListSettingsToNode(Value);
  //Save each column
  for i := 0 to Pred(FColumnList.Count) do begin
    ReportColumnNode := AppendNode(Value, '_Report_Column');
    TReportColumnItem(FColumnList.Items[i]).SaveToNode(ReportColumnNode);
  end;
end;

procedure TReportColumnList.ScaleColumns;
var
  i: integer;
  ColumnItem: TReportColumnItem;
  StretchColCount: integer;
  TotalWidthPercent, FixedWidthPercent, VarWidthPercent: double;
  TotalColCount, FixedColCount, VarColCount: integer;
  VarRatio, Ratio: double;
  VarWeight: double;
  WeightingFactor: integer;

  function CanStretchColumn(aColumnItem: TReportColumnItem): boolean;
  begin
    Result := False;
    if Assigned(aColumnItem) then
      Result := aColumnItem.FOutputCol and (CanClipColumn(aColumnItem) or CanWrapColumn(aColumnItem));
  end;

  procedure ScaleAllColumns;
  var
    ColIdx: integer;
  begin
    Ratio := (100 / TotalWidthPercent);
    for ColIdx := 0 to Pred(FColumnList.Count) do begin
      ColumnItem := TReportColumnItem(FColumnList.Items[ColIdx]);
      if ColumnItem.FOutputCol then
        ColumnItem.FWidthPercent := (Ratio * ColumnItem.FWidthPercent);
    end;
  end;

begin
  TotalWidthPercent := 0;
  FixedWidthPercent := 0;
  TotalColCount := 0;
  FixedColCount := 0;

  for i := 0 to Pred(FColumnList.Count) do begin
    ColumnItem := TReportColumnItem(FColumnList.Items[i]);
    if ColumnItem.FOutputCol then begin
      //set widths based on field size
      if ColumnItem.FWidthPercent = 0 then
        ColumnItem.FWidthPercent := GetFieldSize(ColumnItem);
      if not CanStretchColumn(ColumnItem) then begin
        FixedWidthPercent := FixedWidthPercent + ColumnItem.FWidthPercent;
        Inc(FixedColCount);
      end;
      TotalWidthPercent := TotalWidthPercent + ColumnItem.FWidthPercent;
      Inc(TotalColCount);
    end;
  end;

  if (TotalWidthPercent = 0) then Exit;

  //If percent of var cols plus percent of var space > WEIGHTING_FACTOR
  //then all columns get scaled down
  if (FixedColCount < (TotalColCount - FixedColCount)) then
    WeightingFactor := MaxInt //Don't scale fixed columns if there are more var colunms
  else
    WeightingFactor :=  300 - (TotalColCount * 10);

  if (FixedWidthPercent < 100) then begin
    VarWidthPercent := TotalWidthPercent - FixedWidthPercent;
    VarColCount := TotalColCount - FixedColCount;
    VarWeight := (VarWidthPercent/TotalWidthPercent * 100) + (VarColCount/TotalColCount * 100);
    if (VarWidthPercent > 0) then begin
      if (VarWeight < WeightingFactor) then begin
        //Scale variable 'stretchable' columns down
        VarRatio := ((100 - FixedWidthPercent) / VarWidthPercent);
        for i := 0 to Pred(FColumnList.Count) do begin
          ColumnItem := TReportColumnItem(FColumnList.Items[i]);
          if CanStretchColumn(ColumnItem) then
            ColumnItem.FWidthPercent := Round(VarRatio * ColumnItem.FWidthPercent);
        end;
      end else begin
        //Scale all columns down
        ScaleAllColumns;
      end;
    //Stretch fixed columns to fit page
    end else begin
      //Get number of stretchable columns
      StretchColCount := 0;
      for i := 0 to Pred(FColumnList.Count) do
        if CanStretchColumn(TReportColumnItem(FColumnList.Items[i])) then
          Inc(StretchColCount);
      //Get ratio
      Ratio := ((100 - FixedWidthPercent)/ FixedWidthPercent);
      if (StretchColCount > 0) then begin
        //Scale stretchable columns up
        for i := 0 to Pred(FColumnList.Count) do begin
          ColumnItem := TReportColumnItem(FColumnList.Items[i]);
          if CanStretchColumn(ColumnItem) then
            ColumnItem.WidthPercent := ColumnItem.WidthPercent +
                                       (ColumnItem.WidthPercent * Ratio);
        end;
      end else begin
        //Scale all columns up
        for i := 0 to Pred(FColumnList.Count) do begin
          ColumnItem := TReportColumnItem(FColumnList.Items[i]);
          if ColumnItem.FOutputCol then
            ColumnItem.WidthPercent := ColumnItem.WidthPercent +
                                       (ColumnItem.WidthPercent * Ratio);
        end;
      end;
    end;
  end else begin
    //Scale all columns down
    ScaleAllColumns;
  end;
end;

procedure TReportColumnList.SetAccountingSystemUsed(const Value: integer);
begin
  FAccountingSystemUsed := Value;
end;

procedure TReportColumnList.SetCountry(const Value: integer);
begin
  FCountry := Value;
end;

procedure TReportColumnList.SetHasForeignCurrencyAccounts(const Value: Boolean);
begin
  FHasForeignCurrencyAccounts := Value;
end;

procedure TReportColumnList.SetOrientation(const Value: integer);
begin
  FOrientation := Value;
end;

procedure TReportColumnList.SetWrapColumns(const Value: boolean);
begin
  FWrapColumns := Value;
end;

{ TCodingReportColumnList }

function TCodingReportColumnList.CanClipColumn(
  aColumnItem: TReportColumnItem): boolean;
begin
  Result := ((aColumnItem.FDataUnit = BKTX) and
             (aColumnItem.FDataToken in [tktxGL_Narration,
                                         tktxStatement_Details,
                                         tktxOther_Party,
                                         tktxParticulars,
                                         tktxNotes])) or
            ((aColumnItem.FDataUnit = BKCH) and
             (aColumnItem.FDataToken = tkchAccount_Description)) or
            ((aColumnItem.FDataUnit = BKPD) and
             (aColumnItem.FDataToken = tkpdName)) or
            ((aColumnItem.FDataUnit = BKJH) and
             (aColumnItem.FDataToken = tkjhHeading));
end;

procedure TCodingReportColumnList.AutoCalcColumnWidths;
//Algorithm to set reasonable column sizes for a custom Coding Report
// - Date, Amount, and Number columns have a default size and
//   'CanClipColumn' = false so they're not truncated.
// - AnsiString columns are sized depending on the max string length. They are
//   then scaled by the ratio of the amount of space left over after fixed
//   columns are set.
// - Note: at the moment column widths are calculated on the number of
//   characters and not the actual rendered text size.
var
  i: integer;
  TempTravMgr: TTravManagerWithNewReport;
  BA : TBank_Account;
  ColumnItem: TReportColumnItem;
  ReportSettings: TCodingReportSettings;
begin
  if Assigned(FBKReport) then begin
    FOrientation := FBKReport.UserReportSettings.s7Orientation;
    TempTravMgr := TTravManagerWithNewReport.Create;
    try
      TempTravMgr.Clear;
      TempTravMgr.ReportJob := FBKReport;

      ReportSettings := TCodingReportSettings(FReportSettings);
      if (ReportSettings = nil) then Exit;

      case ReportSettings.Include of
        esAllEntries  : TempTravMgr.SelectionCriteria := twAllEntries;
        esUncodedOnly : TempTravMgr.SelectionCriteria := twAllUncoded;
      end;

      TempTravMgr.OnEnterEntryExt := CR_EnterEntry;
      TempTravMgr.OnEnterAccountExt := CR_EnterAccount;

      //set all column width percentages to zero
      for i := 0 to Pred(FColumnList.Count) do begin
        ColumnItem := TReportColumnItem(FColumnList.Items[i]);
        ColumnItem.FWidthPercent := 0;
      end;

      //traverse each account and set column width based on data size (CR_EnterEntry)
      for i := 0 to ReportSettings.AccountList.Count-1 do begin
        BA := ReportSettings.AccountList[i];
        if (BA.baTransaction_List.ItemCount > 0) then
          TempTravMgr.TraverseAccount(BA, ReportSettings.FromDate, ReportSettings.ToDate);
      end;

      //Set remaining column widths and scale
      ScaleColumns;

    finally
      FreeAndNil(TempTravMgr);
    end;
  end;
end;

procedure TCodingReportColumnList.CR_EnterAccount(Sender: TObject);
//var
//  TravMgr: TTravManagerWithNewReport;
begin
//  TravMgr := TTravManagerWithNewReport(Sender);
//  FAccountBalance := TravMgr.Bank_Account.baFields.baCurrent_Balance;
end;

procedure TCodingReportColumnList.CR_EnterEntry(Sender: TObject);
var
  Account_Rec: pAccount_Rec;
  ColumnItem: TReportColumnItem;
  CurrDataWidth, NewDataWidth: Double;
  i: integer;
  Job_Rec: pJob_Heading_Rec;
  Payee: TPayee;
  Transaction_Rec: pTransaction_Rec;
  TravMgr: TTravManagerWithNewReport;
begin
  TravMgr := TTravManagerWithNewReport(Sender);
  Transaction_Rec := TravMgr.Transaction;
  //Get the max data length for each field
  for i := 0 to Pred(FColumnList.Count) do begin
    ColumnItem := TReportColumnItem(FColumnList.Items[i]);
    if ColumnItem.FOutputCol then begin
      //get current data width
      CurrDataWidth := 0;
      if (ColumnItem.FWidthPercent > 0) then
        if CanClipColumn(ColumnItem) and (FOrientation = BK_LANDSCAPE) then
          CurrDataWidth := ColumnItem.FWidthPercent / LANDSCAPE_RATIO
        else
          CurrDataWidth := ColumnItem.FWidthPercent;
      //get new data width
      NewDataWidth := 0;
      if CanWrapColumn(ColumnItem) then
        NewDataWidth := MAX_TEXT_FIELD_SIZE
      else begin
        case ColumnItem.FDataToken of
          tktxReference:
            NewDataWidth := Length(Transaction_Rec.txReference);
          tktxAccount:
            NewDataWidth := Max(Length(ColumnItem.FTitle),
                                Length(Transaction_Rec.txAccount));
          tktxAnalysis:
            NewDataWidth := Max(Length(ColumnItem.FTitle),
                                Length(Transaction_Rec.txAnalysis));
          tkchAccount_Description:
            begin
              Account_Rec := MyClient.clChart.FindCode(Transaction_Rec.txAccount);
              if Assigned(Account_Rec) then
                NewDataWidth := Max(Length(ColumnItem.FTitle),
                                    Length(Account_Rec.chAccount_Description));
            end;
          tkchAlternative_Code:
            begin
              Account_Rec := MyClient.clChart.FindCode(Transaction_Rec.txAccount);
              if Assigned(Account_Rec) then
                NewDataWidth := Max(Length(ColumnItem.FTitle),
                                    Length(Account_Rec.chAlternative_Code));
            end;
          tktxGL_Narration:
            NewDataWidth := Max(Length(ColumnItem.FTitle),
                                Length(Transaction_Rec.txGL_Narration));
          tktxStatement_Details:
            NewDataWidth := Max(Length(ColumnItem.FTitle),
                                Length(Transaction_Rec.txStatement_Details));
          tktxOther_Party:
            NewDataWidth := Max(Length(ColumnItem.FTitle),
                                Length(Transaction_Rec.txOther_Party));
          tktxParticulars:
            NewDataWidth := Max(Length(ColumnItem.FTitle),
                                Length(Transaction_Rec.txParticulars));
          tktxCoded_By:
            NewDataWidth := Max(Length(ColumnItem.FTitle),
                                Length(cbNames[Transaction_Rec.txCoded_By]));
          tktxNotes:
            NewDataWidth := Max(Length(ColumnItem.FTitle),
                                Length(Transaction_Rec.txNotes));
          tkpdName:
            begin
              Payee := MyClient.clPayee_List.Find_Payee_Number(Transaction_Rec.txPayee_Number);
              if Assigned(Payee) then
                NewDataWidth := Length(Payee.pdName);
            end;
          tkjhHeading:
            begin
              Job_Rec := MyClient.clJobs.FindCode(Transaction_Rec.txJob_Code);
              if Assigned(Job_Rec) then
                NewDataWidth := Length(Job_Rec.jhHeading);
            end;
        end; //case
      end;
      // set max a column width
      if NewDataWidth > MAX_TEXT_FIELD_SIZE then
        NewDataWidth := MAX_TEXT_FIELD_SIZE;
      //Scale for landscape
      if (NewDataWidth > 0) and (FOrientation = BK_LANDSCAPE) then
        NewDataWidth := Round(NewDataWidth * LANDSCAPE_RATIO);
      //Set the column width
      if NewDataWidth > CurrDataWidth then
        ColumnItem.FWidthPercent := NewDataWidth;
    end;
  end;
end;

function TCodingReportColumnList.GetColumnTitle(aDataUnit: string; aDataToken: integer): string;
begin
  //Coding report column title/data mapping
  case aDataToken of
    tktxDate_Effective          : Result := 'Date';
    tktxType                    : Result :=  'No';
    tktxReference               : Result :=  'Reference';
    tktxAnalysis                : Result :=  'Analysis';
    tktxAccount                 : Result :=  'Code To';
    tktxAmount                  : if HasForeignCurrencyAccounts then
                                     Result :=  'Bank Amount'
                                  else
                                     Result :=  'Amount';
    tktxForex_Conversion_Rate   : Result :=  'Rate';
    tktxForeign_Currency_Amount : Result :=  Format('Amount (%s)',[whCurrencyCodes[Country]]);
    tktxGL_Narration            : Result :=  'Narration';
    tkchAccount_Description     : Result :=  'A/c Desc';
    tkchAlternative_Code        : Result := Software.AlternativeChartCodeName(Country,AccountingSystemUsed);
    tktxStatement_Details       : Result :=  'Statement Details';
    tktxOther_Party             : Result :=  'Other Party';
    tktxParticulars             : Result :=  'Particulars';
    tktxPayee_Number            : Result :=  'Payee';
    tkpdName                    : Result :=  'Payee Name';
    tktxJob_Code                : Result :=  'Job';
    tkjhHeading                 : Result :=  'Job Name';
    tktxGST_Class               : Result :=  TaxName + ' Class';
    tktxGST_Amount              : if HasForeignCurrencyAccounts then
                                     Result := Format('%s (%s)*',[TaxName,whCurrencyCodes[Country]])
                                  else
                                     Result :=  TaxName + ' Amt';
    tktxTax_Invoice_Available   : Result :=  'Tax Inv';
    tktxQuantity                : Result :=  'Quantity';
    tktxDate_Presented          : Result :=  'Pres Date';
    tktxCoded_By                : Result :=  'Coded By';
    tktxNotes                   : Result :=  'Notes';

  else
    Result := inherited GetColumnTitle(aDataUnit, aDataToken);
  end;
end;

function TCodingReportColumnList.GetFieldSize(aReportColumnItem: TReportColumnItem): double;
var
  Transaction_Rec: pTransaction_Rec;
  Account_Rec: pAccount_Rec;
  Payee_Detail_Rec: pPayee_Detail_Rec;
  Job_Rec: pJob_Heading_Rec;
begin
  Result := 0;
  if (aReportColumnItem.FDataUnit = BKTX) then begin
    GetMem(Transaction_Rec, SizeOf(tTransaction_Rec));
    try
      case aReportColumnItem.FDataToken of
        tktxType                  : Result := BYTE_SIZE;
        tktxDate_Presented        : Result := DATE_SIZE;
        tktxDate_Effective        : Result := DATE_SIZE;
        tktxAmount                : Result := AMOUNT_SIZE;
        tktxForex_Conversion_Rate : Result := DATE_SIZE;
        tktxForeign_Currency_Amount:
            Result := AMOUNT_SIZE;
        tktxGST_Class             : Result := Max(Length(aReportColumnItem.FTitle), BYTE_SIZE);
        tktxGST_Amount            : Result := AMOUNT_SIZE;
        tktxQuantity              : Result := QUANTITY_SIZE;
        tktxReference             : Result := SizeOf(Transaction_Rec.txReference);
        tktxAnalysis              : Result := SizeOf(Transaction_Rec.txAnalysis);
        tktxOther_Party           : Result := SizeOf(Transaction_Rec.txOther_Party);
        tktxParticulars           : Result := SizeOf(Transaction_Rec.txParticulars);
        tktxGL_Narration          : Result := MIN_TEXT_FIELD_SIZE;
        tktxAccount               : Result := SizeOf(Transaction_Rec.txAccount);
        tktxCoded_By              : Result := BYTE_SIZE;
        tktxPayee_Number          : Result := INTEGER_SIZE;
        tktxNotes                 : Result := MIN_TEXT_FIELD_SIZE;
        tktxStatement_Details     : Result := MIN_TEXT_FIELD_SIZE;
        tktxTax_Invoice_Available : Result := CHECKBOX_SIZE;
        tktxJob_Code              : Result := SizeOf(Transaction_Rec.txJob_Code);
//        txTemp_Balance            : Result := AMOUNT_SIZE;
      end;
    finally
      FreeMem(Transaction_Rec);
    end;
  end else if (aReportColumnItem.FDataUnit = BKCH) then begin
    GetMem(Account_Rec, SizeOf(TAccount_Rec));
    try
      case aReportColumnItem.FDataToken of
        tkchAccount_Description   : Result := Min(MAX_TEXT_FIELD_SIZE,
                                                  Max(MIN_TEXT_FIELD_SIZE,
                                                      SizeOf(Account_Rec.chAccount_Description)));
        tkchAlternative_Code   : Result := Min(MAX_TEXT_FIELD_SIZE,
                                                  Max(MIN_TEXT_FIELD_SIZE,
                                                      SizeOf(Account_Rec.chAlternative_Code)));
      end;
    finally
      FreeMem(Account_Rec);
    end;
  end else if (aReportColumnItem.FDataUnit = BKJH) then begin
    GetMem(Job_Rec, SizeOf(TJob_Heading_Rec));
    try
      case aReportColumnItem.FDataToken of
        tkjhHeading               : Result := SizeOf(Job_Rec.jhHeading);
      end;
    finally
      FreeMem(Job_Rec);
    end;
  end else if (aReportColumnItem.FDataUnit = BKPD) then begin
    GetMem(Payee_Detail_Rec, SizeOf(TPayee_Detail_Rec));
    try
      case aReportColumnItem.FDataToken of
        tkpdName                  : Result := SizeOf(Payee_Detail_Rec.pdName);
      end;
    finally
      Freemem(Payee_Detail_Rec);
    end;
  end;

  if (Result > 0) and (FOrientation = BK_LANDSCAPE) then
    Result := Round(Result * LANDSCAPE_RATIO);
end;


procedure TCodingReportColumnList.OutputColumn(
  aReportColumnItem: TReportColumnItem);
begin
  if (FTravManager.Dissection <> nil) then begin
    OutputDissection(aReportColumnItem);
  end else begin
    OutputTransaction(aReportColumnItem);
  end;
end;

procedure TCodingReportColumnList.OutputDissection(
  aReportColumnItem: TReportColumnItem);
var
  Transaction_Rec: tTransaction_Rec;
  Dissection_Rec: tDissection_Rec;
  Amt: Money;
begin
  if (aReportColumnItem.FDataUnit = BKTX) then begin
    Transaction_Rec := tTransaction_Rec(FTravManager.Transaction^);
    Dissection_Rec := tDissection_Rec(FTravManager.Dissection^);
    case aReportColumnItem.FDataToken of
      tktxType                  : FBkReport.PutString('');
      tktxDate_Presented        : FBkReport.PutString(bkDate2Str(Transaction_Rec.txDate_Presented));
      tktxDate_Effective        : FBkReport.PutString(bkDate2Str(Transaction_Rec.txDate_Effective));
      tktxAmount                :
        begin
          // Always the amount, not the base amount
          Amt := Dissection_Rec.dsAmount;

          if FTravManager.SortType = csAccountCode then
            FBkReport.PutMoney(Amt)
          else
            FBkReport.PutMoneyDontAdd(Amt);
        end;

      tktxForex_Conversion_Rate :
            // Always use the default forex rate (helper function), as the forex
            // rate on the dissection is not used.
            if FTravManager.Bank_Account.IsAForexAccount
            and (Dissection_Rec.Default_Forex_Rate <> 0.0) then
               FBkReport.PutString(ForexRate2Str(Dissection_Rec.Default_Forex_Rate))
            else
               FBkReport.SkipColumn;

      tktxForeign_Currency_Amount : begin
          if FTravManager.Bank_Account.IsAForexAccount then
             // Always the base amount, not the amount
             Amt := Dissection_Rec.dsTemp_Base_Amount
          else begin
             FBkReport.SkipColumn;
             Exit;
          end;

          if FTravManager.SortType = csAccountCode then
            FBkReport.PutMoney(Amt)
          else
            FBkReport.PutMoneyDontAdd(Amt);
      end;

      tktxGST_Class             : FBkReport.PutString(GetGSTClassCode(MyClient, Dissection_Rec.dsGST_Class));
      tktxGST_Amount            : if Dissection_Rec.dsGST_Amount <> 0 then
                                    FBkReport.PutMoney((Dissection_Rec.dsGST_Amount))
                                  else
                                    FBkReport.SkipColumn;
      tktxQuantity              : if (Dissection_Rec.dsQuantity <> 0) then
                                    FBkReport.PutQuantity(Dissection_Rec.dsQuantity)
                                  else
                                    FBkReport.PutString('');
      tktxReference             :
        begin
          if Dissection_Rec.dsReference <> '' then
            FBkReport.PutString(Dissection_Rec.dsReference)
          else
            FBkReport.PutString(' /' + IntToStr(Dissection_Rec.dsSequence_No));
      end;
      tktxAnalysis              : FBkReport.PutString('');
      tktxOther_Party           : FBkReport.PutString('');
      tktxParticulars           : FBkReport.PutString('');
      tktxGL_Narration          : WrapColumn(aReportColumnItem, Dissection_Rec.dsGL_Narration);
      tktxAccount               : FBkReport.PutString(Dissection_Rec.dsAccount);
      tktxCoded_By              : FBkReport.PutString('');
      tktxPayee_Number          :
        begin
          if (Dissection_Rec.dsPayee_Number > 0) then
            FBkReport.PutString(IntToStr(Dissection_Rec.dsPayee_Number))
          else
            FBkReport.PutString('');
        end;
      tktxNotes                 : WrapColumn(aReportColumnItem, GetFullNotes(FTravManager.Dissection));
      tktxStatement_Details     : FBkReport.PutString('');
      tktxTax_Invoice_Available :
        begin
          if Dissection_Rec.dsTax_Invoice then
            FBkReport.PutString(BOX_TICKED)
          else
            FBkReport.PutString(BOX_EMPTY);
        end;
      tktxJob_Code              : FBkReport.PutString(Dissection_Rec.dsJob_Code);
    else
      FBkReport.PutString('');
    end;
  end else
    FBkReport.PutString('');
end;

procedure TCodingReportColumnList.OutputTransaction(
  aReportColumnItem: TReportColumnItem);
var
  Transaction_Rec: tTransaction_Rec;
  Account_Rec: pAccount_Rec;
  Payee: TPayee;
  Job_Rec: pJob_Heading_Rec;
begin
  if (aReportColumnItem.FDataUnit = BKTX) then begin
    Transaction_Rec := tTransaction_Rec(FTravManager.Transaction^);
    case aReportColumnItem.FDataToken of
      tktxType                  : FBkReport.PutString(IntToStr(Transaction_Rec.txType));
      tktxDate_Presented        : FBkReport.PutString(bkDate2Str(Transaction_Rec.txDate_Presented));
      tktxDate_Effective        : FBkReport.PutString(bkDate2Str(Transaction_Rec.txDate_Effective));

      tktxAmount                : // Banked amount
//                                  if FTravManager.Bank_Account.IsAForexAccount then
//                                     FBkReport.PutMoney(Transaction_Rec.txForeign_Currency_Amount)
//                                  else
//                                     FBkReport.PutMoney(Transaction_Rec.txAmount);
                                     FBkReport.PutMoney(Transaction_Rec.txAmount);

      tktxForex_Conversion_Rate : if FTravManager.Bank_Account.IsAForexAccount then
//                                  and (Transaction_Rec.txForex_Conversion_Rate <> 0) then
//                                     FBkReport.PutString(ForexRate2Str(Transaction_Rec.txForex_Conversion_Rate))
                                     FBkReport.PutString(ForexRate2Str(Transaction_Rec.Default_Forex_Rate))
                                  else
                                     FBKReport.SkipColumn;

      tktxForeign_Currency_Amount : // Local amount
                                  if FTravManager.Bank_Account.IsAForexAccount then
                                     FBkReport.PutMoney(Transaction_Rec.Local_Amount)
                                  else
                                     FBKReport.SkipColumn;

      tktxGST_Class             : FBkReport.PutString(GetGstClassCode(MyClient, Transaction_Rec.txGST_Class));
      tktxGST_Amount            : if (Transaction_Rec.txGST_Amount <> 0) then
                                    FBkReport.PutMoney((Transaction_Rec.txGST_Amount))
                                  else
                                    FBKReport.SkipColumn;
      tktxQuantity              : if (Transaction_Rec.txQuantity <> 0) then
                                    FBkReport.PutQuantity(Transaction_Rec.txQuantity)
                                  else
                                    FBkReport.PutString('');
      tktxReference             : FBkReport.PutString(GetFormattedReference(FTravManager.Transaction));
      tktxAnalysis              : FBkReport.PutString(Trim(Transaction_Rec.txAnalysis));
      tktxOther_Party           : FBkReport.PutString(Trim(Transaction_Rec.txOther_Party));
      tktxParticulars           : FBkReport.PutString(Trim(Transaction_Rec.txParticulars));
      tktxGL_Narration          : WrapColumn(aReportColumnItem, Transaction_Rec.txGL_Narration);
      tktxAccount               : FBkReport.PutString(Trim(Transaction_Rec.txAccount));
      tktxCoded_By              : FBkReport.PutString(cbNames[Transaction_Rec.txCoded_By]);
      tktxPayee_Number          :
        begin
          if (Transaction_Rec.txPayee_Number > 0) then
            FBkReport.PutString(IntToStr(Transaction_Rec.txPayee_Number))
          else
            FBkReport.PutString('');
        end;
      //?Usually joined with GL_Narration to make Transaction Details column
      tktxNotes                 : WrapColumn(aReportColumnItem, GetFullNotes(FTravManager.Transaction));
      tktxStatement_Details     : FBkReport.PutString(Trim(Transaction_Rec.txStatement_Details));
      tktxTax_Invoice_Available :
        begin
          if Transaction_Rec.txTax_Invoice_Available then
            FBkReport.PutString(BOX_TICKED)
          else
            FBkReport.PutString(BOX_EMPTY);
        end;
      tktxJob_Code              : FBkReport.PutString(Trim(Transaction_Rec.txJob_Code));
//      txTemp_Balance            : FBkReport.PutMoney((Transaction_Rec.txTemp_Balance));
    else
      FBkReport.PutString('');
    end;
  end else if (aReportColumnItem.FDataUnit = BKCH) then begin
    Account_Rec := MyClient.clChart.FindCode(FTravManager.Transaction^.txAccount);
    if Assigned(Account_Rec) then
      case aReportColumnItem.FDataToken of
        tkchAccount_Description   : FBkReport.PutString(Trim(Account_Rec.chAccount_Description));
        tkchAlternative_Code   : FBkReport.PutString(Trim(Account_Rec.chAlternative_Code));
      else
        FBkReport.PutString('');
      end
    else
      FBkReport.PutString('');
  end else if (aReportColumnItem.FDataUnit = BKJH) then begin
    Job_Rec := MyClient.clJobs.FindCode(FTravManager.Transaction^.txJob_Code);
    if Assigned(Job_Rec) then
      case aReportColumnItem.FDataToken of
        tkjhHeading               : FBkReport.PutString(Trim(Job_Rec.jhHeading));
      else
        FBkReport.PutString('');
      end
    else
      FBkReport.PutString('');
  end else if (aReportColumnItem.FDataUnit = BKPD) then begin
    Payee := MyClient.clPayee_List.Find_Payee_Number(FTravManager.Transaction^.txPayee_Number);
    if Assigned(Payee) then
      case aReportColumnItem.FDataToken of
        tkpdName                  : FBkReport.PutString(Trim(Payee.pdFields.pdName));
      end
    else
      FBkReport.PutString('');
  end else
    FBkReport.PutString('');
end;

procedure TCodingReportColumnList.SaveReportSettings;
var
  CodingReport: TCodingReport;
  CodingReportSettings: TCodingReportSettings;
  ScheduledCodingReport: TScheduledCodingReport;
begin
  FReportSettings := nil;
  CodingReportSettings := nil;
  if Assigned(FBKReport) then begin
    //Needs to allow for the two versions of the Coding Report
    if FBKReport is TCodingReport then begin
      CodingReport := TCodingReport(FBKReport);
      CodingReportSettings := TCodingReportSettings(CodingReport.ReportSettings);
    end else if FBKReport is TScheduledCodingReport then begin
      ScheduledCodingReport := TScheduledCodingReport(FBKReport);
      CodingReportSettings := TCodingReportSettings(ScheduledCodingReport.ReportSettings);
    end;
    //Save required settings
    if Assigned(CodingReportSettings) then begin
      FWrapColumns := CodingReportSettings.WrapNarration;
      FVerticalColumnLines := CodingReportSettings.RuleLineBetweenColumns;
      //Have to typecast as TRPTParameters otherwise get circular reference -
      //TCodingReportSettings defined in CodingRepDlg.pas which uses TCodingReportColumnList
      FReportSettings := TRPTParameters(CodingReportSettings);
    end;
  end;
end;

procedure TCodingReportColumnList.SetupColumns;
//Note: Minimum prams required: Title, DataUnit, DataField
begin
  FIsDefault := True;
  FOrientation := 0;

  ClearColumnList;

  //Standard Coding Report
  AddColumn(BKTX, tktxDate_Effective, 7.0, jtLeft,
            ctAuto, '', '', DEFAULT_GAP, False, True);

  AddColumn(BKTX, tktxType, 2.5, jtRight,
            ctAuto, '', '', DEFAULT_GAP, False, (Country = whNewZealand));

  AddColumn(BKTX, tktxReference, 13.0, jtLeft,
            ctAuto, '', '', DEFAULT_GAP, False, True);

  if Country = whNewZealand then
    AddColumn(BKTX, tktxAnalysis, 12.0, jtLeft,
              ctAuto, '', '', DEFAULT_GAP, False, (Country = whNewZealand));

  AddColumn(BKTX, tktxAccount, 9.0, jtLeft,
            ctAuto, '', '', DEFAULT_GAP, False, True);

  AddColumn(BKTX, tktxAmount, 12.0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True , True);

  if HasForeignCurrencyAccounts then begin
     AddColumn(BKTX, tktxForex_Conversion_Rate, 7.0, jtRight, ctFormat,
            '', '', DEFAULT_GAP, False , True);

     // Is actualy local amount
     AddColumn(BKTX, tktxForeign_Currency_Amount, 12.0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True , True);
  end;

  AddColumn(BKTX, tktxGL_Narration, 31.0, jtLeft,
            ctAuto, '', '', DEFAULT_GAP, False, True);

  //Extra Custom Columns
  AddColumn(BKCH, tkchAccount_Description, 0, jtLeft);
  //Balance - calculated field - However the code to calc the balance is too
  //          embedded in CodingFrm.pas to be able to use here. Maybe it could
  //          be refactored and moved into TBankAccount (BaObj32.pas)?
//  AddColumn(BKTX, txTemp_Balance, 0, jtRight, False, ctFormat,
//            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True , False);
  AddColumn(BKTX, tktxStatement_Details, 0, jtLeft);
  if Country = whNewZealand then begin
    AddColumn(BKTX, tktxOther_Party, 0, jtLeft);
    AddColumn(BKTX, tktxParticulars, 0, jtLeft);
  end;
  AddColumn(BKTX, tktxPayee_Number);
  AddColumn(BKPD, tkpdName, 0, jtLeft);
  AddColumn(BKTX, tktxJob_Code);
  AddColumn(BKJH, tkjhHeading, 0, jtLeft);
  AddColumn(BKTX, tktxGST_Class);
  AddColumn(BKTX, tktxGST_Amount,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxTax_Invoice_Available,  0, jtCenter);
  AddColumn(BKTX, tktxQuantity, 0, jtRight, ctFormat,
            QUANTITY_FORMAT, QUANTITY_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxDate_Presented, 0, jtLeft,
            ctAuto, '', '', DEFAULT_GAP, False, False);
  AddColumn(BKTX, tktxCoded_By);
  AddColumn(BKTX, tktxNotes, 0, jtLeft, ctAuto, '', '',
            DEFAULT_GAP, False, False);
end;

function TCodingReportColumnList.CanWrapColumn(
  aColumnItem: TReportColumnItem): boolean;
begin
  Result := (aColumnItem.FDataUnit = BKTX) and
            (aColumnItem.FDataToken in [tktxNotes, tktxGL_Narration]);
end;

end.
