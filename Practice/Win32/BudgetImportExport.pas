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
     bNeedsUpdate : Boolean;
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
    procedure BudgetEditRow(var aBudgetData : TBudgetData; aBudgetAmount, RowNum, ColNum: Integer);
  public
    function GetDefaultFileLocation(aClientCode : string) : string;
    procedure SetDefaultFileLocation(aClientCode, aFileLocation : string);

    function ExportBudget(aBudgetFilePath : string;
                          aIncludeUnusedChartCodes : boolean;
                          aData : TBudgetData;
                          aStartDate : integer;
                          var aMsg : string) : boolean;
    function CopyBudgetData(aBudgetData : TBudgetData) : TBudgetData;
    procedure ClearWasUpdated(var aBudgetData : TBudgetData);
    procedure UpdateBudgetDetailRows(var aBudgetData : TBudgetData; var aBudget : TBudget);
    function ImportBudget(aBudgetFilePath: string;
                          aBudgetErrorFilePath : string;
                          var aRowsImported : integer;
                          var aRowsNotImported : integer;
                          var aBudgetData : TBudgetData;
                          var aMsg : string) : boolean;

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
  BKbdIO,
  GenUtils;

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

          // Add a space if account is not numeric
          if IsNumeric(aData[DataIndex].bAccount) then
            DataLine := DataLine + '"' + aData[DataIndex].bAccount + '",'
          else
            DataLine := DataLine + '" ' + aData[DataIndex].bAccount + '",';

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
procedure TBudgetImportExport.BudgetEditRow(var aBudgetData : TBudgetData; aBudgetAmount, RowNum, ColNum: Integer);
var
  NewLine : pBudget_Detail_Rec;
begin
  aBudgetData[RowNum].bAmounts[ColNum] := aBudgetAmount;
  if (aBudgetAmount = 0) or not AmountMatchesQuantityFormula(aBudgetData, RowNum, ColNum) then
  begin
    aBudgetData[RowNum].bQuantitys[ColNum] := 0;
    aBudgetData[RowNum].bUnitPrices[ColNum] := 0;
  end;
  aBudgetData[RowNum].bNeedsUpdate := false;
end;

//------------------------------------------------------------------------------
procedure TBudgetImportExport.UpdateBudgetDetailRows(var aBudgetData: TBudgetData;
                                                     var aBudget: TBudget);
var
  NewLine : pBudget_Detail_Rec;
  RowIndex, ColIndex : integer;
begin
  for RowIndex := 0 to length(aBudgetData) - 1 do
  begin
    if aBudgetData[RowIndex].bNeedsUpdate then
    begin
      if aBudgetData[RowIndex].bDetailLine = nil then
      begin
        NewLine := New_Budget_Detail_Rec;
        NewLine.bdAccount_Code := aBudgetData[RowIndex].bAccount;
        aBudget.buDetail.Insert(NewLine);

        aBudgetData[RowIndex].bDetailLine := NewLine;
      end;

      for ColIndex := 1 to 12 do
      begin
        aBudgetData[RowIndex].bDetailLine.bdBudget[ColIndex]      := aBudgetData[RowIndex].bAmounts[ColIndex];
        aBudgetData[RowIndex].bDetailLine.bdQty_Budget[ColIndex]  := aBudgetData[RowIndex].bQuantitys[ColIndex];
        aBudgetData[RowIndex].bDetailLine.bdEach_Budget[ColIndex] := aBudgetData[RowIndex].bUnitPrices[ColIndex];
      end;

      aBudgetData[RowIndex].bNeedsUpdate := false;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TBudgetImportExport.CopyBudgetData(aBudgetData: TBudgetData): TBudgetData;
var
  BudgetIndex : integer;
  MonthIndex : integer;
begin
  SetLength(Result, length(aBudgetData));

  for BudgetIndex := 0 to length(aBudgetData) - 1 do
  begin
    Result[BudgetIndex].bAccount := aBudgetData[BudgetIndex].bAccount;
    Result[BudgetIndex].bDesc    := aBudgetData[BudgetIndex].bDesc;

    for MonthIndex := 1 to 12 do
    begin
      Result[BudgetIndex].bAmounts[MonthIndex]    := aBudgetData[BudgetIndex].bAmounts[MonthIndex];
      Result[BudgetIndex].bQuantitys[MonthIndex]  := aBudgetData[BudgetIndex].bQuantitys[MonthIndex];
      Result[BudgetIndex].bUnitPrices[MonthIndex] := aBudgetData[BudgetIndex].bUnitPrices[MonthIndex];
    end;

    Result[BudgetIndex].bTotal := aBudgetData[BudgetIndex].bTotal;
    Result[BudgetIndex].bIsPosting := aBudgetData[BudgetIndex].bIsPosting;
    Result[BudgetIndex].bDetailLine := aBudgetData[BudgetIndex].bDetailLine;
    Result[BudgetIndex].bNeedsUpdate := aBudgetData[BudgetIndex].bNeedsUpdate;
  end;
end;

//------------------------------------------------------------------------------
procedure TBudgetImportExport.ClearWasUpdated(var aBudgetData: TBudgetData);
var
  BudgetIndex : integer;
begin
  for BudgetIndex := 0 to length(aBudgetData) - 1 do
    aBudgetData[BudgetIndex].bNeedsUpdate := false;
end;

//------------------------------------------------------------------------------
function TBudgetImportExport.ImportBudget(aBudgetFilePath: string;
                                          aBudgetErrorFilePath : string;
                                          var aRowsImported : integer;
                                          var aRowsNotImported : integer;
                                          var aBudgetData : TBudgetData;
                                          var aMsg : string): boolean;
const
  ThisMethodName = 'ImportBudget';
var
  InputFile : Text;
  ErrorFile : Text;
  InStrLine : string;
  Done : boolean;
  InLineData : TStringList;
  DataIndex, DateIndex : integer;
  LineHasError : boolean;
  LineNumber : integer;
  InValue : integer;
  DataHolder : array[1..12] of integer;

  function GetDataIndexWithAccount(aAccount : string) : integer;
  var
    Index : integer;
  begin
    Result := -1;
    for Index := 0 to high(aBudgetData) do
    begin
      if aBudgetData[Index].bAccount = aAccount then
      begin
        Result := Index;
        Exit;
      end;
    end;
  end;

begin
  aRowsImported := 0;
  aRowsNotImported := 0;
  Done := false;
  Result := false;
  LineNumber := 0;
  try
    AssignFile(InputFile, aBudgetFilePath);
    Reset(InputFile);

    try
      AssignFile(ErrorFile, aBudgetErrorFilePath);
      Rewrite(ErrorFile);

      try
        InLineData := TStringList.Create;
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

            InLineData.Delimiter := ',';
            InLineData.StrictDelimiter := True;
            InLineData.DelimitedText := InStrLine;

            if InLineData.Count <> 15 then
            begin
              WriteLn(ErrorFile, 'Row-' + inttostr(LineNumber) + ', Code-' + Trim(InLineData[0]) +
                                 ', Incorrect amount of columns, 15 expected, ' + inttostr(InLineData.Count) + ' found.');
              aRowsNotImported := aRowsNotImported + 1;
            end
            else
            begin
              DataIndex := GetDataIndexWithAccount(Trim(InLineData[0]));
              if DataIndex <> -1 then
              begin
                if aBudgetData[DataIndex].bIsPosting then
                begin
                  for DateIndex := 1 to 12 do
                  begin
                    if not TryStrtoInt(InLineData[2 + DateIndex], DataHolder[DateIndex]) then
                    begin
                      WriteLn(ErrorFile, 'Row-' + inttostr(LineNumber) + ', Column-' + inttostr(DateIndex+2) +
                                         ', Code-' + Trim(InLineData[0]) + ' Error converting value to a number.');
                      LineHasError := true;
                      aRowsNotImported := aRowsNotImported + 1;
                      break;
                    end;
                  end;

                  if not LineHasError then
                  begin
                    for DateIndex := 1 to 12 do
                      BudgetEditRow(aBudgetData, DataHolder[DateIndex], DataIndex, DateIndex);

                    aBudgetData[DataIndex].bTotal := 0;
                    for DateIndex := 1 to 12 do
                      aBudgetData[DataIndex].bTotal := aBudgetData[DataIndex].bTotal +
                                                       aBudgetData[DataIndex].bAmounts[DateIndex];
                    aBudgetData[DataIndex].bNeedsUpdate := true;
                    aRowsImported := aRowsImported + 1;
                  end;
                end
                else
                begin
                  WriteLn(ErrorFile, 'Row-' + inttostr(LineNumber) + ', Code-' + Trim(InLineData[0]) +
                                     ' Data Row is not a posting row and cannot be updated.');
                  aRowsNotImported := aRowsNotImported + 1;
                end;
              end
              else
              begin
                WriteLn(ErrorFile, 'Row-' + inttostr(LineNumber) + ', Code-' + Trim(InLineData[0]) +
                                   ', Cannot find Account code');
                aRowsNotImported := aRowsNotImported + 1;
              end;
            end;
          end;

          Result := true;
        finally
          FreeAndNil(InLineData);
        end;
      finally
        CloseFile(ErrorFile);
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
