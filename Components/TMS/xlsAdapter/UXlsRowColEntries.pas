unit UXlsRowColEntries;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}
{$IFDEF LINUX}{$INCLUDE ../FLXCONFIG.INC}{$ELSE}{$INCLUDE ..\FLXCONFIG.INC}{$ENDIF}

interface
uses Classes, SysUtils, UXlsBaseRecords, UXlsBaseRecordLists, UXlsOtherRecords,
     XlsMessages, UXlsRangeRecords, UXlsBaseList, UXlsCellRecords, UXlsFormula,
     {$IFDEF ConditionalExpressions}{$if CompilerVersion >= 14} variants,{$IFEND}{$ENDIF} //Delphi 6 or above
     UXlsSST, UFlxMessages, UXlsColInfo, UXlsReferences, UXlsWorkbookGlobals, UXlsTokenArray;

type
  TListClass= class of TBaseRowColRecordList;

  TBaseRowColList = class(TBaseList) //records are TBaseRowColRecordList
    {$INCLUDE TBaseRowColListHdr.inc}
  protected
    ListClass: TListClass;
  public
    procedure AddRecord(const aRecord: TBaseRowColRecord; const aRow: integer);

    procedure CopyFrom(const aList: TBaseRowColList);

    procedure SaveToStream(const DataStream: TStream);
    procedure SaveRangeToStream(const DataStream: TStream; const CellRange: TXlsCellRange);
    function TotalSize: int64;
    function TotalRangeSize(const CellRange: TXlsCellRange): int64;

    procedure InsertAndCopyRows(const FirstRow, LastRow, DestRow, aCount: integer; const SheetInfo: TSheetInfo; const OnlyFormulas: boolean);
    procedure InsertAndCopyCols(const FirstCol, LastCol, DestCol, aCount: integer; const SheetInfo: TSheetInfo; const OnlyFormulas: boolean);
    procedure DeleteRows(const aRow, aCount: word; const SheetInfo: TSheetInfo);
    procedure DeleteCols(const aCol, aCount: word; const SheetInfo: TSheetInfo);
    procedure ArrangeInsertRowsAndCols(const InsRowPos, InsRowCount, InsColPos, InsColCount: integer; const SheetInfo: TSheetInfo);

    constructor Create(const aListClass: TListClass);
  end;

  TCellList = class (TBaseRowColList)//records are TCellRecordList
  private
    FGlobals: TWorkbookGlobals;
    FRowRecordList: TRowRecordList;
    FColInfoList: TColInfoList;

    function GetValue(Row, Col: integer): TXlsCellValue;
    procedure SetValue(Row, Col: integer; const Value: TXlsCellValue);
    procedure FixFormulaTokens(const Formula: TFormulaRecord; const ShrFmlas: TShrFmlaRecordList);
    function GetFormula(Row, Col: integer): widestring;
    procedure SetFormula(Row, Col: integer; const Value: widestring);
    {$INCLUDE TCellListHdr.inc}
  public
    constructor Create(const aGlobals: TWorkbookGlobals; const aRowRecordList: TRowRecordList; const aColInfoList: TColInfoList);
    property Value[Row,Col:integer]:TXlsCellValue  read GetValue write SetValue;
    procedure SetValueX2(const Row, Col: integer; const Value: TXlsCellValue; const RTFRuns: TRTFRunList);
    procedure GetValueX2(const Row, Col: integer; out V: TXlsCellValue; out RTFRuns: TRTFRunList);
    procedure SetFormat(const Row, Col: integer; const XF: integer);
    property Formula[Row,Col: integer]: widestring read GetFormula write SetFormula;
    procedure AssignFormulaX(const Row, Col: integer; const Formula: widestring; const Value: variant);
    function ArrayFormula(const Row, Col: integer): PArrayOfByte;
    function TableFormula(const Row, Col: integer): PArrayOfByte;
    procedure FixFormulas(const ShrFmlas: TShrFmlaRecordList);

    function GetSheetName(const SheetNumber: integer): widestring;
    function AddExternSheet(const FirstSheet, LastSheet: Integer): Integer;
    function FindSheet(SheetName: widestring; out SheetIndex: Integer): Boolean;
    procedure ArrangeInsertSheet(const SheetInfo: TSheetInfo);
  end;

  TCells = class
  private
    FRowList: TRowRecordList;
    FCellList: TCellList;
    procedure WriteDimensions(const DataStream: TStream; const CellRange: TXlsCellRange);
    function DimensionsSize: integer;
    procedure CalcUsedRange(var CellRange: TXlsCellRange);
    procedure ArrangeCols;
  public
    constructor Create(const aGlobals: TWorkbookGlobals; const aColInfoList: TColInfoList);
    destructor Destroy; override;

    procedure Clear;
    procedure CopyFrom(const aList: TCells);

    procedure SaveToStream(const DataStream: TStream);
    procedure SaveRangeToStream(const DataStream: TStream; const CellRange: TXlsCellRange);
    function TotalSize: int64;
    function TotalRangeSize(const CellRange: TXlsCellRange): int64;

    procedure FixRows;

    procedure InsertAndCopyRows(const FirstRow, LastRow, DestRow, aCount: integer; const SheetInfo: TSheetInfo; const OnlyFormulas: boolean);
    procedure InsertAndCopyCols(const FirstCol, LastCol, DestCol, aCount: integer; const SheetInfo: TSheetInfo; const OnlyFormulas: boolean);
    procedure DeleteRows(const aRow, aCount: word; const SheetInfo: TSheetInfo);
    procedure DeleteCols(const aCol, aCount: word; const SheetInfo: TSheetInfo);
    procedure ArrangeInsertRowsAndCols(const InsRowPos, InsRowCount, InsColPos, InsColCount: integer; const SheetInfo: TSheetInfo);
    procedure ArrangeInsertSheet(const SheetInfo: TSheetInfo);

    procedure AddRow(const aRecord: TRowRecord);
    procedure AddCell(const aRecord: TCellRecord;  const aRow: integer);
    procedure AddMultipleCells(const aRecord: TMultipleValueRecord);

    property CellList: TCellList read FCellList;
    property RowList: TRowRecordList read FRowList;
  end;


  TRangeList = class(TBaseList) //records are TRangeEntry
    {$INCLUDE TRangeListHdr.inc}
    procedure CopyFrom(const aRangeList: TRangeList);

    procedure SaveToStream(const DataStream: TStream);
    procedure SaveRangeToStream(const DataStream: TStream; const CellRange: TXlsCellRange);
    function TotalSize: int64;
    function TotalRangeSize(const CellRange: TXlsCellRange): int64;

    procedure InsertAndCopyRowsOrCols(const FirstRow, LastRow, DestRow, aCount: integer; const SheetInfo: TSheetInfo; const UseCols: boolean);
    procedure DeleteRowsOrCols(const aRow, aCount: word; const SheetInfo: TSheetInfo; const UseCols: boolean);

  end;

implementation
{$IFNDEF TMSASGx}
uses UXlsFormulaParser, UXlsEncodeFormula;
{$ENDIF}

{$INCLUDE TBaseRowColListImp.inc}
{$INCLUDE TRangeListImp.inc}
{$INCLUDE TCellListImp.inc}
{ TBaseRowColList }


procedure TBaseRowColList.AddRecord(const aRecord: TBaseRowColRecord; const aRow: integer);
var
  i:integer;
begin
  for i:= Count to aRow do Add(ListClass.Create);
  Items[aRow].Add(aRecord);
end;

procedure TBaseRowColList.ArrangeInsertRowsAndCols(const InsRowPos, InsRowCount, InsColPos, InsColCount: integer; const SheetInfo: TSheetInfo);
var
  i:integer;
begin
  for i:=0 to Count-1 do Items[i].ArrangeInsertRowsAndCols(InsRowPos, InsRowCount,InsColPos,InsColCount, SheetInfo);
end;

procedure TBaseRowColList.CopyFrom(const aList: TBaseRowColList);
var
  i: integer;
  Tr: TBaseRowColRecordList;
begin
  for i:=0 to aList.Count - 1 do
  begin
    Tr:= ListClass.Create;
    Tr.CopyFrom(aList[i]);
    Add(Tr);
  end;
end;

constructor TBaseRowColList.Create(const aListClass: TListClass);
begin
  inherited Create(true);
  ListClass:=aListClass;
end;

procedure TBaseRowColList.DeleteRows(const aRow, aCount: word; const SheetInfo: TSheetInfo);
var
  i, Max: integer;
begin
  Max:=aRow+aCount ; if Max>Count then Max:= Count;
  for i:= Max-1 downto aRow do Delete(i);
  //Delete the cells. we have to look at all the formulas, not only those below arow
  ArrangeInsertRowsAndCols(aRow, -aCount, 0, 0, SheetInfo);

end;

procedure TBaseRowColList.DeleteCols(const aCol, aCount: word; const SheetInfo: TSheetInfo);
var
  Index: integer;
  r,c: integer;
begin
  for r:=0 to Count-1 do
    for c:= aCol to ACol+aCount-1 do
      if Items[r].Find(c, Index) then Items[r].Delete(Index);
  //Delete the cells. we have to look at all the formulas, not only those below arow
  ArrangeInsertRowsAndCols(0, 0, aCol, -aCount, SheetInfo);

end;

procedure TBaseRowColList.InsertAndCopyRows(const FirstRow, LastRow, DestRow,
  aCount: integer; const SheetInfo: TSheetInfo; const OnlyFormulas: boolean);
var
  i, k, z, a, CopyOffs, MyDestRow: integer;
  aRecordList: TBaseRowColRecordList;
begin
  // Insert the cells. we have to look at all the formulas, not only those below destrow
  ArrangeInsertRowsAndCols(DestRow, aCount*(LastRow-FirstRow+1), 0,0, SheetInfo);

  //Copy the cells
  MyDestRow:=DestRow;
  CopyOffs:=0;
  for k:=1 to aCount do
    for i:=FirstRow to LastRow do
    begin
      aRecordList:= ListClass.Create;
      try
        //Will only copy the cells if copyfrom < recordcount. This allows us to only insert, and not copy.
        if i+CopyOffs<Count then
        begin
          if OnlyFormulas then
          begin
            for a:=0 to Items[i+CopyOffs].Count-1 do
              if (Items[i+CopyOffs][a] is TFormulaRecord) then
                aRecordList.Add(Items[i+CopyOffs][a].CopyTo as TBaseRowColRecord);
          end else aRecordList.CopyFrom(Items[i+CopyOffs]);

          if (aRecordList.Count>0) then aRecordList.ArrangeCopyRowsAndCols(MyDestRow-aRecordList[0].Row,0);
        end;
        for z:= Count to MyDestRow-1 do Add(ListClass.Create);
        Insert(MyDestRow, aRecordList);
        aRecordList:=nil;
      finally
        FreeAndNil(aRecordList);
      end; //finally
      Inc(MyDestRow);
      if FirstRow>=DestRow then Inc(CopyOffs);
    end;

end;

procedure TBaseRowColList.InsertAndCopyCols(const FirstCol, LastCol, DestCol,
  aCount: integer; const SheetInfo: TSheetInfo; const OnlyFormulas: boolean);
var
  i, k, r, CopyOffs, MyDestCol: integer;
  Index: integer;
  Rec: TBaseRowColRecord;
begin
  // Insert the cells. we have to look at all the formulas, not only those at the left from destcol
  ArrangeInsertRowsAndCols(0,0,DestCol, aCount*(LastCol-FirstCol+1), SheetInfo);

  //Copy the cells
  MyDestCol:=DestCol;
  if (DestCol<=FirstCol) then CopyOffs:=aCount*(LastCol-FirstCol+1) else CopyOffs:=0;

  for k:=1 to aCount do
    for i:=FirstCol to LastCol do
    begin
      for r:=0 to Count-1 do
      begin
        if Items[r].Find(i+CopyOffs, Index)
          and  ( not OnlyFormulas or (Items[r][Index] is TFormulaRecord)) then
          begin
            Rec:=(Items[r][Index].CopyTo as TBaseRowColRecord);
            try
              Rec.ArrangeCopyRowsAndCols(0,MyDestCol-Rec.Column);
            except
              FreeAndNil(Rec);
              raise;
            end; //except
            Items[r].Find(Rec.Column, Index);
            Items[r].Insert(Index, Rec);
          end;

      end;
      Inc(MyDestCol);
    end;
end;

procedure TBaseRowColList.SaveRangeToStream(const DataStream: TStream; const CellRange: TXlsCellRange);
var
  i:integer;
begin
  for i:=0 to Count-1 do Items[i].SaveRangeToStream(DataStream, CellRange);
end;

procedure TBaseRowColList.SaveToStream(const DataStream: TStream);
var
  i:integer;
begin
  for i:=0 to Count-1 do Items[i].SaveToStream(DataStream);
end;

function TBaseRowColList.TotalRangeSize(const CellRange: TXlsCellRange): int64;
var
  i: integer;
begin
  Result:=0;
  for i:=CellRange.Top to CellRange.Bottom do Result:=Result+Items[i].TotalRangeSize(CellRange);
end;

function TBaseRowColList.TotalSize: int64;
var
  i:integer;
begin
  Result:=0;
  for i:=0 to Count-1 do Result:=Result+Items[i].TotalSize;
end;

{ TCellList }

constructor TCellList.Create(const aGlobals: TWorkbookGlobals; const aRowRecordList: TRowRecordList; const aColInfoList: TColInfoList);
begin
  inherited Create(TCellRecordList);
  FGlobals:= aGlobals;
  FRowRecordList:=aRowRecordList;
  FColInfoList:=aColInfoList;
end;

procedure TCellList.GetValueX2(const Row, Col: integer;
  out V: TXlsCellValue; out RTFRuns: TRTFRunList);
var
  Index: integer;
  Rs: TRichString;
begin
  if (Row<0) or (Row>Max_Rows) then raise Exception.CreateFmt(ErrInvalidRow,[Row]);
  if (Col>Max_Columns)or (Col<0) then raise Exception.CreateFmt(ErrInvalidCol,[Col]);
  SetLength(RTFRuns,0);
  if Row>=Count then begin; V.Value:=Unassigned; V.XF:=-1; V.IsFormula:=false; exit; end;
  if Items[Row].Find(Col,Index) then
  begin
    V.XF:=Items[Row][Index].XF;
    V.IsFormula:=Items[Row][Index] is TFormulaRecord;
    if Items[Row][Index] is TLabelSSTRecord then
    begin
      Rs:=(Items[Row][Index] as TLabelSSTRecord).AsRichString;
      V.Value:=Rs.Value;
      RTFRuns:= Copy(Rs.RTFRuns);
    end else V.Value:=Items[Row][Index].Value;

  end else
  begin
    V.Value:=Unassigned;
    V.XF:=-1;
    V.IsFormula:=false;
  end;
end;

function TCellList.GetValue(Row, Col: integer): TXlsCellValue;
var
  RTFRuns: TRTFRunList;
begin
  GetValueX2(Row, Col, Result, RTFRuns);
end;

procedure TCellList.SetValue(Row, Col: integer; const Value: TXlsCellValue);
begin
  SetValueX2(Row, col, Value, nil);
end;

procedure TCellList.SetValueX2(const Row, Col: integer; const Value: TXlsCellValue; const RTFRuns: TRTFRunList);
var
  Index, k: integer;
  XF, DefaultXF: integer;
  Found: boolean;
  Cell: TCellRecord;
  ValueType: integer;
  Rs: TRichString;
begin
  if (Row<0) or (Row>Max_Rows) then raise Exception.CreateFmt(ErrInvalidRow,[Row]);
  if (Col>Max_Columns)or (Col<0) then raise Exception.CreateFmt(ErrInvalidCol,[Col]);

  FRowRecordList.AddRow(Row);

  if FRowRecordList[Row].IsFormatted then DefaultXF:=FRowRecordList[Row].XF
  else if FColInfoList.Find(Col, Index) then DefaultXF:=FColInfoList[Index].XF
  else DefaultXF:=15;

  Cell:=nil;
  Found:=(Row<Count) and Items[Row].Find(Col,Index);
  XF:=DefaultXF;
  if Found then XF:=Items[Row][Index].XF;
  if Value.XF>=0 then XF:=Value.XF;


  ValueType:= VarType(Value.Value);

  {$IFDEF ConditionalExpressions}{$if CompilerVersion >= 14}
  //Check for Custom Variants
  if (ValueType>=$010F) and (ValueType<=$0FFF) then
  begin
    ValueType:=VarDouble; //should be VarType(OleVariant(Value.Value)), but this converts numbers to strings
  end;
  {$IFEND}{$ENDIF} //Delphi 6 or above

  case ValueType of
    varEmpty,
    varNull      : if (XF<>DefaultXF) then Cell:= TBlankRecord.CreateFromData(Row,Col,XF);

    varByte,
    varSmallint,
    varInteger,
    varSingle,
    varDouble,
    {$IFDEF ConditionalExpressions}{$if CompilerVersion >= 14}
      varShortInt, VarWord, VarLongWord, varInt64,
    {$IFEND}{$ENDIF} //Delphi 6 or above
    varCurrency : if IsRK(Value.Value) then Cell:= TRKRecord.CreateFromData(Row,Col,XF)
                                 else Cell:= TNumberRecord.CreateFromData(Row,Col,XF);

    varDate     : Cell:= TLabelSSTRecord.CreateFromData(Row,Col,XF,FGlobals.SST);

    varOleStr,
    varStrArg,
    varString   : if (Value.Value='') then
                  begin
                    if (XF<>DefaultXF) then Cell:= TBlankRecord.CreateFromData(Row,Col,XF);
                  end
                  else Cell:= TLabelSSTRecord.CreateFromData(Row,Col,XF,FGlobals.SST);

    varBoolean	: Cell:= TBoolErrRecord.CreateFromData(Row,Col,XF);
  end; //case

  if Found then Items[Row].Delete(Index);


  if Found and (Cell=nil) then  //We are deleting a cell
  begin
    if (Row>=Count) or (Items[Row]=nil)or(Items[Row].Count=0)then //Row emptied
      if (not FRowRecordList[Row].IsModified)  then     //Row always exists... it is added at the top
        FRowRecordList[Row]:=nil  //this frees the object
      else
      begin
        FRowRecordList[Row].MinCol:= 0;
        FRowRecordList[Row].MaxCol:= 0;
      end
    else
    begin
      FRowRecordList[Row].MinCol:= Items[Row][0].Column;
      FRowRecordList[Row].MaxCol:= Items[Row][Items[Row].Count-1].Column+1;
    end;
  end;

  //Remove all empty Rows at the end.
  k:=FRowRecordList.Count-1;
  while ((k>Row) or (Cell=nil)) and
        (k>=0) and (not FRowRecordList.HasRow(k) or (not FRowRecordList[k].IsModified)) and
        ((k>=Count) or (Items[k]=nil) or (Items[k].Count=0)) do
  begin
    FRowRecordList.Delete(k);
    if k<Count then Delete(k);
    dec(k);
  end;

  if Cell=nil then exit;

  if Col+1> FRowRecordList[Row].MaxCol then FRowRecordList[Row].MaxCol:=Col+1;
  if Col< FRowRecordList[Row].MinCol then FRowRecordList[Row].MinCol:=Col;

  if (Cell is TLabelSSTRecord) and (Length(RTFRuns)>0) then
  begin
    Rs.Value:=Value.Value;
    Rs.RTFRuns:=Copy(RTFRuns);
    (Cell as TLabelSSTRecord).AsRichString:=Rs;
  end else
  Cell.Value:=Value.Value;
  if Row>=Count then AddRecord(Cell, Row) else Items[Row].Insert(Index, Cell);
end;

procedure TCellList.FixFormulaTokens(const Formula: TFormulaRecord; const ShrFmlas: TShrFmlaRecordList);
var
  Key: Cardinal;
  Index: integer;
begin
  if not Formula.IsExp(Key) then exit;
  if ShrFmlas.Find(Key, Index) then
    Formula.MixShared(ShrFmlas[Index].Data, ShrFmlas[Index].DataSize)
  else //Array formula
  begin
    //nothing, it's ok
    //raise Exception.Create(ErrShrFmlaNotFound);
  end;
end;

procedure TCellList.FixFormulas(const ShrFmlas: TShrFmlaRecordList);
var
  i, k: integer;
  it: TCellRecordList;
  OldFormulaSize: integer;
begin
  for i:=0 to Count-1 do
  begin
    it:=Items[i];
    for k:=0 to it.Count-1 do
      if it.Items[k] is TFormulaRecord then
      begin
        OldFormulaSize:=(it.Items[k] as TFormulaRecord).DataSize;
        FixFormulaTokens(it.Items[k] as TFormulaRecord, ShrFmlas);
        it.AdaptSize((it.Items[k] as TFormulaRecord).DataSize-OldFormulaSize);
      end;
  end;
end;

function TCellList.GetFormula(Row, Col: integer): widestring;
{$IFNDEF TMSASGx}
var
  Index: integer;
{$ENDIF}
begin
{$IFDEF TMSASGx}
  Result:='';
{$ELSE}
  if (Row<0) or (Row>Max_Rows) then raise Exception.CreateFmt(ErrInvalidRow,[Row]);
  if (Col>Max_Columns)or (Col<0) then raise Exception.CreateFmt(ErrInvalidCol,[Col]);
  if Row>=Count then begin; Result:=''; exit; end;
  if Items[Row].Find(Col,Index) and (Items[Row][Index] is TFormulaRecord) then
  begin
    Result:=RPNToString(Items[Row][Index].Data, 22, FGlobals.Names, Self);
  end else
  begin
    Result:='';
  end;
{$ENDIF}
end;

procedure TCellList.SetFormula(Row, Col: integer; const Value: widestring);
begin
  AssignFormulaX(Row, Col, Value, unassigned);
end;

function TCellList.ArrayFormula(const Row, Col: integer): PArrayOfByte;
var
  Index: integer;
  Fmla: TFormulaRecord;
begin
  if (Row<0) or (Row>=Count) then raise Exception.CreateFmt(ErrInvalidRow,[Row]);
  if (Col>Max_Columns)or (Col<0) then raise Exception.CreateFmt(ErrInvalidCol,[Col]);
  if Items[Row].Find(Col,Index) and (Items[Row][Index] is TFormulaRecord) then
  begin
    Fmla:=(Items[Row][Index] as TFormulaRecord);
    if Fmla.ArrayRecord=nil then raise Exception.CreateFmt(ErrBadFormula,[Row, Col,1]);
    Result:=Fmla.ArrayRecord.Data;
  end else
  begin
    raise Exception.Create(ErrShrFmlaNotFound);
  end;
end;

function TCellList.TableFormula(const Row, Col: integer): PArrayOfByte;
var
  Index: integer;
  Fmla: TFormulaRecord;
begin
  if (Row<0) or (Row>=Count) then raise Exception.CreateFmt(ErrInvalidRow,[Row]);
  if (Col>Max_Columns)or (Col<0) then raise Exception.CreateFmt(ErrInvalidCol,[Col]);
  if Items[Row].Find(Col,Index) and (Items[Row][Index] is TFormulaRecord) then
  begin
    Fmla:=(Items[Row][Index] as TFormulaRecord);
    if Fmla.TableRecord=nil then raise Exception.CreateFmt(ErrBadFormula,[Row, Col,1]);
    Result:=(Items[Row][Index] as TFormulaRecord).TableRecord.Data;
  end else
  begin
    raise Exception.Create(ErrShrFmlaNotFound);
  end;
end;

function TCellList.GetSheetName(const SheetNumber: integer): widestring;
begin
  Result:= FGlobals.References.GetSheetName(SheetNumber, FGlobals);
end;

function TCellList.FindSheet(SheetName: widestring; out SheetIndex: Integer): Boolean;
var
  i: Integer;
begin
  SheetName:=WideUpperCase98(SheetName);
  for i:=0 to FGlobals.SheetCount-1 do
  begin
    if SheetName= UpperCase(FGlobals.SheetName[i]) then
    begin
      SheetIndex := i;
      Result := True;
      exit;
    end;
  end;
  SheetIndex := -1;
  Result := False;
end;

function TCellList.AddExternSheet(const FirstSheet: Integer; const LastSheet: Integer): Integer;
begin
  Result := FGlobals.References.AddSheet(FGlobals.SheetCount, FirstSheet, LastSheet);
end;



procedure TCellList.AssignFormulaX(const Row, Col: integer; const Formula: widestring; const Value: variant);
{$IFNDEF TMSASGx}
var
  Cell: TCellRecord;
  ds: integer;
  Ps: TParseString;
  Index, k: integer;
  XF, DefaultXF: integer;
  Found: boolean;
{$ENDIF}
begin
{$IFNDEF TMSASGx}
  if (Row<0) or (Row>Max_Rows) then raise Exception.CreateFmt(ErrInvalidRow,[Row]);
  if (Col>Max_Columns)or (Col<0) then raise Exception.CreateFmt(ErrInvalidCol,[Col]);
  FRowRecordList.AddRow(Row);
  if FRowRecordList[Row].IsFormatted then DefaultXF:=FRowRecordList[Row].XF
  else if FColInfoList.Find(Col, Index) then DefaultXF:=FColInfoList[Index].XF
  else DefaultXF:=15;

  Cell:=nil;
  Found:=(Row<Count) and Items[Row].Find(Col,Index);
  XF:=DefaultXF;
  if Found then XF:=Items[Row][Index].XF;
  //if Formula.XF>=0 then XF:=Formula.XF;

  if Formula='' then Cell:=nil else
  begin
    Ps:=TParseString.Create(Formula, FGlobals.Names, Self);
    try
      Ps.Parse;
      ds:= Ps.TotalSize+20;
      Cell:= TFormulaRecord.CreateFromData(xlr_FORMULA, ds, Row, Col, XF, Value);
      Ps.CopyToPtr(Cell.Data, 20);
    finally
      FreeAndNil(Ps);
    end;
  end;

  try
    if Found then Items[Row].Delete(Index);

    if Found and (Cell=nil) then  //We are deleting a cell
    begin
      if (Row>=Count) or (Items[Row]=nil)or(Items[Row].Count=0)then //Row emptied
        if (not FRowRecordList[Row].IsModified)  then     //Row always exists... it is added at the top
          FRowRecordList[Row]:=nil  //this frees the object
        else
        begin
          FRowRecordList[Row].MinCol:= 0;
          FRowRecordList[Row].MaxCol:= 0;
        end
      else
      begin
        FRowRecordList[Row].MinCol:= Items[Row][0].Column;
        FRowRecordList[Row].MaxCol:= Items[Row][Items[Row].Count-1].Column+1;
      end;
    end;

    //Remove all empty Rows at the end.
    k:=FRowRecordList.Count-1;
    while ((k>Row) or (Cell=nil)) and
          (k>=0) and (not FRowRecordList.HasRow(k) or (not FRowRecordList[k].IsModified)) and
          ((k>=Count) or (Items[k]=nil) or (Items[k].Count=0)) do
    begin
      FRowRecordList.Delete(k);
      if k<Count then Delete(k);
      dec(k);
    end;

    if Cell=nil then exit;

    if Col+1> FRowRecordList[Row].MaxCol then FRowRecordList[Row].MaxCol:=Col+1;
    if Col< FRowRecordList[Row].MinCol then FRowRecordList[Row].MinCol:=Col;
    if Row>=Count then AddRecord(Cell, Row) else Items[Row].Insert(Index, Cell);
  except
    FreeAndNil(Cell);
    raise;
  end; //except
{$ENDIF}
end;

procedure TCellList.SetFormat(const Row, Col, XF: integer);
var
  Index: integer;
  Value: TXlsCellValue;
begin
  if (Row<0) or (Row>Max_Rows) then raise Exception.CreateFmt(ErrInvalidRow,[Row]);
  if (Col>Max_Columns)or (Col<0) then raise Exception.CreateFmt(ErrInvalidCol,[Col]);

  if FRowRecordList.HasRow(Row) and (Row<Count) and (Row>=0) and Items[Row].Find(Col,Index) then
    Items[Row][Index].XF:=XF else
  begin
    Value.Value:=null;
    Value.XF:=XF;
    SetValue(Row,Col,Value);
  end;
end;

procedure TCellList.ArrangeInsertSheet(const SheetInfo: TSheetInfo);
var
  Data: PArrayOfByte;
  i, k: integer;
  it: TCellRecordList;
begin
  for i:=0 to Count-1 do
  begin
    it:=Items[i];
    for k:=0 to it.Count-1 do
      if it.Items[k] is TFormulaRecord then
      begin
        Data:= it.Items[k].Data;
        ArrangeInsertSheets(Data, 22, 22 + GetWord(Data, 20), SheetInfo);
      end;
  end;
end;

{ TCells }

procedure TCells.AddCell(const aRecord: TCellRecord; const aRow: integer);
begin
  FCellList.AddRecord(aRecord, aRow);
end;

procedure TCells.AddMultipleCells(const aRecord: TMultipleValueRecord);
var
  OneRec: TCellRecord;
begin
  while not aRecord.Eof do
  begin
    OneRec:=aRecord.ExtractOneRecord;
    FCellList.AddRecord( OneRec, OneRec.Row);
  end;
end;

procedure TCells.AddRow(const aRecord: TRowRecord);
begin
  FRowList.AddRecord(aRecord);
end;

procedure TCells.ArrangeInsertRowsAndCols(const InsRowPos, InsRowCount, InsColPos, InsColCount: integer;
  const SheetInfo: TSheetInfo);
begin
  FRowList.ArrangeInsertRowsAndCols(InsRowPos, InsRowCount, InsColPos, InsColCount, SheetInfo);
  FCellList.ArrangeInsertRowsAndCols(InsRowPos, InsRowCount, InsColPos, InsColCount, SheetInfo);
end;

procedure TCells.Clear;
begin
  if FRowList<>nil then FRowList.Clear;
  if FCellList<>nil then FCellList.Clear;
end;

procedure TCells.CopyFrom(const aList: TCells);
begin
  FRowList.CopyFrom(aList.FRowList);
  FCellList.CopyFrom(aList.FCellList);
end;

constructor TCells.Create(const aGlobals: TWorkbookGlobals; const aColInfoList: TColInfoList);
begin
  inherited Create;
  FRowList:=TRowRecordList.Create;
  FCellList:=TCellList.Create(aGlobals, FRowList, aColInfoList);
end;

procedure TCells.DeleteRows(const aRow, aCount: word; const SheetInfo: TSheetInfo);
begin
  FRowList.DeleteRows(aRow, aCount, SheetInfo);
  FCellList.DeleteRows(aRow, aCount, SheetInfo);
end;

procedure TCells.DeleteCols(const aCol, aCount: word; const SheetInfo: TSheetInfo);
begin
  FCellList.DeleteCols(aCol, aCount, SheetInfo);
  ArrangeCols;
end;

destructor TCells.Destroy;
begin
  FreeAndNil(FRowList);
  FreeAndNil(FCellList);
  inherited;
end;

procedure TCells.InsertAndCopyRows(const FirstRow, LastRow, DestRow,
  aCount: integer; const SheetInfo: TSheetInfo; const OnlyFormulas: boolean);
begin
  FRowList.InsertAndCopyRows(FirstRow, LastRow, DestRow, aCount, SheetInfo);
  FCellList.InsertAndCopyRows(FirstRow, LastRow, DestRow, aCount, SheetInfo, OnlyFormulas);
end;

procedure TCells.InsertAndCopyCols(const FirstCol, LastCol, DestCol,
  aCount: integer; const SheetInfo: TSheetInfo; const OnlyFormulas: boolean);
begin
  FCellList.InsertAndCopyCols(FirstCol, LastCol, DestCol, aCount, SheetInfo, OnlyFormulas);
  ArrangeCols;
end;

procedure TCells.ArrangeCols;
var
  i: integer;
begin
  for i:= 0 to FRowList.Count-1 do
    if (FRowList.HasRow(i)) then
    begin
      if ((i<FCellList.Count) and (FCellList[i]<>nil) and (FCellList[i].Count>0)) then
      begin
        FRowList[i].MinCol:= FCellList[i][0].Column;
        FRowList[i].MaxCol:= FCellList[i][FCellList[i].Count-1].Column+1;
      end
      else
      begin
        FRowList[i].MinCol:= 0;
        FRowList[i].MaxCol:= 0;
      end;
    end;
end;

function TCells.DimensionsSize: integer;
begin
  Result:= SizeOf(TDimensionsRec)+SizeOf(TRecordHeader);
end;

procedure TCells.CalcUsedRange(var CellRange: TXlsCellRange);
var
  i: integer;
begin
  CellRange.Top:=0;
  while (int64(CellRange.Top)<RowList.Count) and not RowList.HasRow(CellRange.Top) do inc(CellRange.Top);
  CellRange.Bottom:=RowList.Count-1;
  CellRange.Left:=0;
  CellRange.Right:=0;
  for i:=CellRange.Top to RowList.Count-1 do
    if RowList.HasRow(i) then
    begin
      if RowList[i].MaxCol>CellRange.Right then CellRange.Right:=RowList[i].MaxCol;
      if RowList[i].MinCol<CellRange.Left then CellRange.Left:=RowList[i].MinCol;
    end;
  if CellRange.Right>0 then Dec(CellRange.Right); //MaxCol is the max col+1
end;

procedure TCells.WriteDimensions(const DataStream: TStream; const CellRange: TXlsCellRange);
var
  DimRec: TDimensionsRecord;
  DimRecDat: PDimensionsRec;
begin
  GetMem(DimRecDat, SizeOf(TDimensionsRec));
  try
    DimRecDat.FirstRow:=CellRange.Top;
    DimRecDat.LastRow:=CellRange.Bottom+1; //This adds an extra row. Dimensions do from firstrow to lastrow+1
    DimRecDat.FirstCol:=CellRange.Left;
    DimRecDat.LastCol:=CellRange.Right+1;
    DimRecDat.Extra:=0;
    DimRec:=TDimensionsRecord.Create(xlr_DIMENSIONS, PArrayOfByte(DimRecDat), SizeOf(TDimensionsRec));
  except
    FreeMem(DimRecDat);
    raise;
  end;
  try
    DimRec.SaveToStream(DataStream);
  finally
    FreeAndNil(DimRec);
  end; //Finally
end;

procedure TCells.SaveToStream(const DataStream: TStream);
var
  CellRange: TXlsCellRange;
begin
  FixRows;
  CalcUsedRange(CellRange);
  SaveRangetoStream(DataStream, CellRange);
end;

function TCells.TotalSize: int64;
begin
  TotalSize:= DimensionsSize + FRowList.TotalSize + FCellList.TotalSize;
end;

procedure TCells.FixRows;
var
  i: integer;
begin
  if FRowList.Count>= FCellList.Count then exit;
  for i:=0 to FCellList.Count - 1 do
    if (not FRowList.HasRow(i) and (FCellList[i].Count>0)) then FRowList.AddRow(i);

  if (FCellList.Count >0) then FRowList.AddRow(FCellList.Count-1);
end;

procedure TCells.SaveRangeToStream(const DataStream: TStream; const CellRange: TXlsCellRange);
var
  i,k,j, Written :integer;
begin
  FixRows;
  WriteDimensions(DataStream, CellRange);
  i:=CellRange.Top;
  while (i<=CellRange.Bottom) do
  begin
    k:=0;Written:=0;
    while (Written<32) and (k+i<=CellRange.Bottom) do
    begin
      if FRowList.HasRow(k+i) then
      begin
        FRowList[k+i].SaveRangeToStream(DataStream, CellRange.Left, CellRange.Right);
        //inc(Written);  //We want 32 records in total, counting blanks. that's why not here
      end;
      inc(Written);
      inc(k);
    end;

    for j:= i to k+i-1 do
      if (j<=CellRange.Bottom) and (j<FCellList.Count) then FCellList[j].SaveRangeToStream(DataStream, CellRange);

    inc(i, k);
  end;

end;


function TCells.TotalRangeSize(const CellRange: TXlsCellRange): int64;
begin
  TotalRangeSize:= DimensionsSize + FRowList.TotalRangeSize(CellRange) + FCellList.TotalRangeSize(CellRange);
end;

procedure TCells.ArrangeInsertSheet(const SheetInfo: TSheetInfo);
begin
  FCellList.ArrangeInsertSheet(SheetInfo);
end;

{ TRangeList }

procedure TRangeList.CopyFrom(const aRangeList: TRangeList);
var
  i: integer;
begin
  for i:=0 to aRangeList.Count - 1 do
    Add(aRangeList.Items[i].CopyTo);
end;

procedure TRangeList.DeleteRowsOrCols(const aRow, aCount: word;
  const SheetInfo: TSheetInfo; const UseCols: boolean);
var
  i: integer;
begin
  for i:=0 to Count-1 do Items[i].DeleteRowsOrCols(aRow, aCount, SheetInfo, UseCols);
end;

procedure TRangeList.InsertAndCopyRowsOrCols(const FirstRow, LastRow, DestRow,
  aCount: integer; const SheetInfo: TSheetInfo; const UseCols: boolean);
var
  i: integer;
begin
  for i:=0 to Count-1 do Items[i].InsertAndCopyRowsOrCols(FirstRow, LastRow, DestRow, aCount, SheetInfo, UseCols);
end;

procedure TRangeList.SaveRangeToStream(const DataStream: TStream; const CellRange: TXlsCellRange);
var
  i:integer;
begin
  for i:=0 to Count-1 do Items[i].SaveRangeToStream(DataStream, CellRange);
end;

procedure TRangeList.SaveToStream(const DataStream: TStream);
var
  i:integer;
begin
  for i:=0 to Count-1 do Items[i].SaveToStream(DataStream);
end;

function TRangeList.TotalRangeSize(const CellRange: TXlsCellRange): int64;
var
  i:integer;
begin
  Result:=0;
  for i:=0 to Count-1 do Result:=Result+Items[i].TotalRangeSize(CellRange);
end;

function TRangeList.TotalSize: int64;
var
  i:integer;
begin
  Result:=0;
  for i:=0 to Count-1 do Result:=Result+Items[i].TotalSize;
end;


end.
