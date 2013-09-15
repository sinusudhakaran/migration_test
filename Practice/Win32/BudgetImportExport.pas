//------------------------------------------------------------------------------
unit BudgetImportExport;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  Classes,
  bkConst,
  MoneyDef,
  BKDefs,
  BUDOBJ32;

const
  BUDGET_DEFAULT_FILENAME = 'BudgetDefaultLocations.dat';
  UnitName = 'BudgetImportExport';

//------------------------------------------------------------------------------
type
   EClearType = (clrAll,clrColumn,clrRow);

   TBudgetRec = record
     bAccount     : Bk5CodeStr;
     bDesc        : string[40];
     bAmounts     : Array[1..12] of integer;
     bQuantitys   : Array[1..12] of Money;
     bUnitPrices  : Array[1..12] of Money;
     bTotal       : integer;
     bIsPosting   : boolean;
     bDetailLine  : pBudget_Detail_Rec;
   end;

   TBudgetData = Array of tBudgetRec;  {dynamic array}

   TExternalCmdBudget = ( ecbGenerate,     {budget form commands}
                          ecbCopy,
                          ecbSplit,
                          ecbAverage,
                          ecbSmooth,
                          ecbZero,
                          ecbPercentageChange,
                          ecbHideUnused,
                          ecbShowAll,
                          ecbChart,
                          ecbQuit,
                          ecbImport,
                          ecbExport
                          );

  TBudgetImportExport = class
  private
    fBudgetDefaultFile : string;

    function GetIOErrorDescription(ErrorCode : integer; ErrorMsg : string) : string;
    function GetFileLocIndex(aBudgetDefaults : TStringList; aClientCode: string; var aIndex : integer) : boolean;
    function AmountMatchesQuantityFormula(var aData : TBudgetData; RowIndex, ColIndex: Integer): boolean;
    procedure BudgetEditRow(var aData : TBudgetData; var aBudget : TBudget; aBudgetAmount, RowNum, ColNum: Integer);
  public
    function GetDefaultFileLocation(aClientCode : string) : string;
    procedure SetDefaultFileLocation(aClientCode, aFileLocation : string);

    function ExportBudget(aBudgetFilePath : string;
                          aIncludeUnusedChartCodes : boolean;
                          aData : TBudgetData;
                          aStartDate : integer;
                          var aMsg : string) : boolean;
    function ImportBudget(aBudgetFilePath : string;
                          var aData : TBudgetData;
                          var aBudget : TBudget;
                          var aMsg : string;
                          var aChartCodesSkipped : boolean ) : boolean;

    property BudgetDefaultFile : string read fBudgetDefaultFile write fBudgetDefaultFile;
  end;

//------------------------------------------------------------------------------
implementation

uses
  ovcdate,
  StDateSt,
  strutils,
  LogUtil,
  Globals,
  BudgetUnitPriceEntry,
  BKbdIO;

{ TBudgetImportExport }
//------------------------------------------------------------------------------
function TBudgetImportExport.GetFileLocIndex(aBudgetDefaults: TStringList;
                                             aClientCode: string;
                                             var aIndex: integer): boolean;
var
  CommaIndex : integer;
  Index : integer;
  ClientCode : string;
begin
  aIndex := -1;
  Result := false;
  for Index := 0 to aBudgetDefaults.Count - 1 do
  begin
    CommaIndex := pos(',',aBudgetDefaults.Strings[Index]);

    if (CommaIndex > 1) then
    begin
      ClientCode := LeftStr(aBudgetDefaults.Strings[Index], CommaIndex-1);

      if aClientCode = ClientCode then
      begin
        Result := true;
        aIndex := Index;
        break;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TBudgetImportExport.GetDefaultFileLocation(aClientCode: string): string;
const
  ThisMethodName = 'GetDefaultFileLocation';
var
  BudgetDefaults : TStringList;
  Index, CommaIndex : integer;
begin
  Result := '';
  if FileExists(fBudgetDefaultFile) then
  begin
    BudgetDefaults := TStringList.Create;
    try
      try
        BudgetDefaults.LoadFromFile(fBudgetDefaultFile);

        if GetFileLocIndex(BudgetDefaults, aClientCode, Index) then
        begin
          CommaIndex := pos(',',BudgetDefaults.Strings[Index]);
          Result := RightStr(BudgetDefaults.Strings[Index], length(BudgetDefaults.Strings[Index]) - CommaIndex);
        end;

      except
        on e : Exception do
          LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : Error loading file : ' +
                                             UserDir + BUDGET_DEFAULT_FILENAME + ' : ' + e.Message);
      end;
    finally
      FreeAndNil(BudgetDefaults);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TBudgetImportExport.SetDefaultFileLocation(aClientCode, aFileLocation: string);
const
  ThisMethodName = 'SetDefaultFileLocation';
var
  BudgetDefaults : TStringList;
  Index, CommaIndex : integer;
  found : boolean;
begin
  found := false;
  BudgetDefaults := TStringList.Create;

  try
    try
      if FileExists(fBudgetDefaultFile) then
      begin
        BudgetDefaults.LoadFromFile(fBudgetDefaultFile);

        found := GetFileLocIndex(BudgetDefaults, aClientCode, Index);
        if found then
          BudgetDefaults.Strings[Index] := aClientCode + ',' + aFileLocation;
      end;

      if not found then
        BudgetDefaults.Add(aClientCode + ',' + aFileLocation);

      BudgetDefaults.SaveToFile(fBudgetDefaultFile);
    except
      on e : Exception do
        LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : Error Accessing file : ' +
                                             UserDir + BUDGET_DEFAULT_FILENAME + ' : ' + e.Message);
    end;
  finally
    FreeAndNil(BudgetDefaults);
  end;
end;

//------------------------------------------------------------------------------
function TBudgetImportExport.GetIOErrorDescription(ErrorCode: integer; ErrorMsg: string): string;
begin
  case ErrorCode of
    2  : Result := 'No such file or directory';
    3  : Result := 'Path not found';
    5  : Result := 'I/O Error';
    13 : Result := 'Permission denied';
    20 : Result := 'Not a directory';
    21 : Result := 'Is a directory';
    32 : Result := 'Check that the file is not already open and try again.';
  else
    Result := ErrorMsg;
  end;
end;

//------------------------------------------------------------------------------
function TBudgetImportExport.ExportBudget(aBudgetFilePath: string;
                                          aIncludeUnusedChartCodes : boolean;
                                          aData : TBudgetData;
                                          aStartDate : integer;
                                          var aMsg : string): boolean;
const
  ThisMethodName = 'ExportBudget';
var
  OutputFile : Text;
  DateIndex  : integer;
  ColDate    : integer;
  DataIndex  : integer;
  HeaderLine : string;
  DataLine   : string;
  OkToWriteLine : Boolean;
begin
  Result := false;
  aMsg := '';

  try
    AssignFile(OutPutFile, aBudgetFilePath);
    Rewrite(OutPutFile);
    try
      // Header
      HeaderLine := '"Account","Description","Total"';
      for DateIndex := 0 to 11 do
      begin
        ColDate := IncDate(aStartDate, 0, DateIndex, 0);
        HeaderLine := HeaderLine + ',"' + StDateToDateString('nnn yy', ColDate, true) + '"';
      end;
      Writeln(OutputFile, HeaderLine );

      // Data
      for DataIndex := 0 to high(aData) do
      begin
        OkToWriteLine := true;
        if Not aIncludeUnusedChartCodes then
        begin
          OkToWriteLine := false;
          for DateIndex := 1 to 12 do
          begin
            if aData[DataIndex].bAmounts[DateIndex] <> 0 then
            begin
              OkToWriteLine := true;
              break;
            end;
          end;
        end;

        if OkToWriteLine then
        begin
          aData[DataIndex].bTotal := 0;
          for DateIndex := 1 to 12 do
            aData[DataIndex].bTotal := aData[DataIndex].bTotal +
                                       aData[DataIndex].bAmounts[DateIndex];

          DataLine := '';
          DataLine := DataLine + '"' + aData[DataIndex].bAccount + '",';
          DataLine := DataLine + '"' + aData[DataIndex].bDesc + '",';
          DataLine := DataLine + IntToStr(aData[DataIndex].bTotal) + ',';

          for DateIndex := 1 to 12 do
          begin
            DataLine := DataLine + IntToStr(aData[DataIndex].bAmounts[DateIndex]);
            if DateIndex < 12 then
              DataLine := DataLine +  ',';
          end;

          Writeln(OutputFile, DataLine );
        end;
      end;

      Result := true;
    finally
      CloseFile(OutPutFile);
    end;
  except
    on e : EInOutError do
    begin
      aMsg := Format( 'Unable to Export file. %s', [ GetIOErrorDescription(E.ErrorCode, E.Message) ] );
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + aMsg );
    end;
  end;
end;

//------------------------------------------------------------------------------
function TBudgetImportExport.AmountMatchesQuantityFormula(var aData : TBudgetData; RowIndex, ColIndex: Integer): boolean;
var
  Quantity: Money;
  UnitPrice: Money;
  CalculatedAmount : Money;
  Amount: Integer;
begin
  Quantity := aData[RowIndex].bQuantitys[ColIndex];
  UnitPrice := aData[RowIndex].bUnitPrices[ColIndex];
  CalculatedAmount := TfrmBudgetUnitPriceEntry.CalculateTotal(UnitPrice, Quantity);
  Amount := aData[RowIndex].bAmounts[ColIndex];
  Result := CalculatedAmount = Amount;
end;

  //------------------------------------------------------------------------------
procedure TBudgetImportExport.BudgetEditRow(var aData : TBudgetData; var aBudget : TBudget; aBudgetAmount, RowNum, ColNum: Integer);
var
  NewLine : pBudget_Detail_Rec;
begin
  aData[RowNum].bAmounts[ColNum] := aBudgetAmount;
  if (aBudgetAmount = 0) or not AmountMatchesQuantityFormula(aData, RowNum, ColNum) then
  begin
    aData[RowNum].bQuantitys[ColNum] := 0;
    aData[RowNum].bUnitPrices[ColNum] := 0;
  end;

  if aData[RowNum].bDetailLine = nil then
  begin
    NewLine := New_Budget_Detail_Rec;
    NewLine.bdAccount_Code := aData[Rownum].bAccount;
    aBudget.buDetail.Insert(NewLine);

    aData[RowNum].bDetailLine := NewLine;
  end;

  aData[RowNum].bDetailLine.bdBudget[ColNum] := aBudgetAmount;
  aData[RowNum].bDetailLine.bdQty_Budget[ColNum] := aData[RowNum].bQuantitys[ColNum];
  aData[RowNum].bDetailLine.bdEach_Budget[ColNum] := aData[RowNum].bUnitPrices[ColNum];
end;

//------------------------------------------------------------------------------
function TBudgetImportExport.ImportBudget(aBudgetFilePath: string;
                                          var aData : TBudgetData;
                                          var aBudget : TBudget;
                                          var aMsg : string;
                                          var aChartCodesSkipped : boolean): boolean;
const
  ThisMethodName = 'ImportBudget';
var
  InputFile : Text;
  InStrLine : string;
  Done : boolean;
  InLineData : TStringList;
  ErrorLines : TStringList;
  DataIndex, DateIndex : integer;
  LineHasError : boolean;
  LineNumber : integer;
  InValue : integer;

  function GetDataIndexWithAccount(aAccount : string) : integer;
  var
    Index : integer;
  begin
    Result := -1;
    for Index := 0 to high(aData) do
    begin
      if aData[Index].bAccount = aAccount then
      begin
        Result := Index;
        Exit;
      end;
    end;
  end;

begin
  Done := false;
  Result := false;
  LineNumber := 0;
  try
    AssignFile(InputFile, aBudgetFilePath);
    Reset(InputFile);

    try
      InLineData := TStringList.Create;
      ErrorLines := TStringList.Create;
      try
        if eof(InputFile) then
        begin
          aMsg := 'Unable to Import file. The file is empty.';
          Exit;
        end;

        // Ignore header
        readln(InputFile, InStrLine);
        inc(LineNumber);

        // ignore header
        if eof(InputFile) then
        begin
          aMsg := 'Unable to Import file. The file has no data.';
          Exit;
        end;

        while not eof(InputFile) do
        begin
          LineHasError := false;
          readln(InputFile, InStrLine);
          inc(LineNumber);
          InLineData.CommaText := InStrLine;

          if InLineData.Count <> 15 then
          begin
            ErrorLines.Add('Line-' + inttostr(LineNumber) + ' Incorrect amount of columns');
            break;
          end;

          DataIndex := GetDataIndexWithAccount(InLineData[0]);
          if DataIndex <> -1 then
          begin
            for DateIndex := 1 to 12 do
            begin
              if TryStrtoInt(InLineData[2 + DateIndex], InValue) then
              begin
                BudgetEditRow(aData, aBudget, InValue, DataIndex, DateIndex);
                ErrorLines.Add('');
              end
              else
              begin
                ErrorLines.Add('Line-' + inttostr(LineNumber) + 'Date Row-' +
                               inttostr(DateIndex) + ' Can''t convert value to a number');
              end;
            end;

            aData[DataIndex].bTotal := 0;
            for DateIndex := 1 to 12 do
              aData[DataIndex].bTotal := aData[DataIndex].bTotal +
                                         aData[DataIndex].bAmounts[DateIndex];
          end
          else
          begin
            ErrorLines.Add('Line-' + inttostr(LineNumber) + ' Can''t find account');
            aChartCodesSkipped := true;
          end;
        end;

        Result := true;
      finally
        FreeAndNil(InLineData);
        FreeAndNil(ErrorLines);
      end;
    finally
      CloseFile(InputFile);
    end;

  except
    on e : EInOutError do
    begin
      aMsg := Format( 'Unable to Import file. %s', [ GetIOErrorDescription(E.ErrorCode, E.Message) ] );
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + aMsg );
      Done := true;
    end;
    on e : Exception do
    begin
      if not Done then
      begin
        aMsg := Format( 'Unable to Import file. %s', [E.Message] );
        LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + aMsg );
      end;
    end;
  end;
end;

end.
