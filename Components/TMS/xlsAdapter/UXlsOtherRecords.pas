unit UXlsOtherRecords;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}

interface
uses Classes, SysUtils, UXlsBaseRecords, XlsMessages, UXlsStrings;

type
  TBOFRecord = class(TBaseRecord)
  private
    function GetBOFType: Word;
  protected
  public
    property BOFType: Word read GetBOFType;

    constructor Create(const aId: word; const aData: PArrayOfByte; const aDataSize: integer);override;
  end;

  TEOFRecord= class(TBaseRecord)
  end;

  TObjRecord = class(TBaseRecord)
    ObjId: word;
    CmoId: word;
    constructor Create(const aId: word; const aData: PArrayOfByte; const aDataSize: integer);override;
  end;

  TTXORecord = class (TBaseRecord)
    constructor CreateFromData;
  end;

  TSSTRecord   = class(TBaseRecord)
  private
  public
    Count: LongWord;
    constructor Create(const aId: word; const aData: PArrayOfByte; const aDataSize: integer);override;
  end;

  TBoundSheetRecord = class(TBaseRecord)
  private
    function GetSheetName: WideString;
    procedure SetSheetName(const Value: WideString);
    function GetOptionFlags: word;
    procedure SetOptionFlags(const Value: word);
  public
    property OptionFlags: word read GetOptionFlags write SetOptionFlags;
    property SheetName: WideString read GetSheetName write SetSheetName;

    constructor CreateNew(const aOptionFlags: word; const aName: WideString);
    procedure SetOffset(aOffset: LongWord);
  end;

  TCodeNameRecord = class (TBaseRecord)
  private
    function GetSheetName: WideString;
    procedure SetSheetName(const Value: WideString);
  public
    property SheetName: WideString read GetSheetName write SetSheetName;
    constructor CreateNew(const aName: WideString);
  end;

  TObProjRecord= class(TBaseRecord)
  end;

  TRangeRecord= class(TBaseRecord)
  end;

  TCellMergingRecord= class(TRangeRecord)
  end;

  TDValRecord= class(TRangeRecord)
  end;

  TGutsRecord= class (TBaseRecord)
  private
    function GetColLevel: integer;
    function GetRowLevel: integer;
    procedure SetColLevel(const Value: integer);
    procedure SetRowLevel(const Value: integer);
  public
    RecalcNeeded: boolean;

    constructor Create(const aId: word; const aData: PArrayOfByte; const aDataSize: integer);override;
    property RowLevel: integer read GetRowLevel write SetRowLevel;
    property ColLevel: integer read GetColLevel write SetColLevel;

    function DoCopyTo: TBaseRecord; override;
  end;

  /// <summary>
  /// Window Freeze
  /// </summary>
  TPaneRecord = class (TBaseRecord)
  private
    function Get_RowSplit(): integer;
    procedure Set_RowSplit(const value: integer);
    function Get_ColSplit(): integer;
    procedure Set_ColSplit(const value: integer);
    function Get_FirstVisibleRow(): integer;
    procedure Set_FirstVisibleRow(const value: integer);
    function Get_FirstVisibleCol(): integer;
    procedure Set_FirstVisibleCol(const value: integer);
    function Get_ActivePane(): integer;
    procedure Set_ActivePane(const value: integer);

  public
    procedure EnsureSelectedVisible();
    property RowSplit: integer read Get_RowSplit write Set_RowSplit;
    property ColSplit: integer read Get_ColSplit write Set_ColSplit;
    property FirstVisibleRow: integer read Get_FirstVisibleRow write Set_FirstVisibleRow;
    property FirstVisibleCol: integer read Get_FirstVisibleCol write Set_FirstVisibleCol;
    property ActivePane: integer read Get_ActivePane write Set_ActivePane;
  end;

implementation
uses UEscherRecords;
{ TBOFRecord }

constructor TBOFRecord.Create(const aId: word; const aData: PArrayOfByte;
  const aDataSize: integer);
begin
  inherited;
  if GetWord( aData, 0)<> xlr_BofVersion then raise Exception.Create(ErrInvalidVersion);
end;

function TBOFRecord.GetBOFType: Word;
begin
  Result:= GetWord( Data, 2);
end;

{ TSSTRecord }

constructor TSSTRecord.Create(const aId: word; const aData: PArrayOfByte;
  const aDataSize: integer);
begin
  inherited;
  Count:= GetLongWord(aData,4); // Total unique strings
end;

{ TBoundSheetRecord }

constructor TBoundSheetRecord.CreateNew(const aOptionFlags: word;
  const aName: WideString);
var
  Xs: TExcelString;
  PData: PArrayOfByte;
  DataSize: integer;
begin
  Xs:= TExcelString.Create(1, aName);
  try
    DataSize:=6 + Xs.TotalSize;
    GetMem(PData, DataSize);
    try
      SetLongWord( PData, 0, 0);
      SetWord( PData, 4, aOptionFlags );
      Xs.CopyToPtr( PData, 6 );
      Create( xlr_BOUNDSHEET, PData, DataSize);
      PData:=nil;
    finally
      FreeMem(Pdata);
    end;
  finally
    FreeAndNil(Xs);
  end;
end;

function TBoundSheetRecord.GetSheetName: WideString;
var
  Xs: TExcelString;
  Ofs: integer;
  Rec: TBaseRecord;
begin
  Ofs:=6;Rec:= Self;
  Xs:= TExcelString.Create(1, Rec, Ofs);
  try
    Result:= Xs.Value;
  finally
    FreeAndNil(Xs);
  end;
end;

function TBoundSheetRecord.GetOptionFlags: word;
begin
  Result:= GetWord(Data, 4);
end;

procedure TBoundSheetRecord.SetOffset(aOffset: LongWord);
begin
  SetLongWord(Data, 0, aOffset);
end;

procedure TBoundSheetRecord.SetSheetName(const Value: WideString);
  //Important: This method changes the size of the record without notifying it's parent list
  //It's necessary to adapt the Totalsize in the parent list.
var
  Xs: TExcelString;
  NewDataSize: integer;
begin
  Xs:= TExcelString.Create(1, Value);
  try
    NewDataSize:=6 + Xs.TotalSize;
    ReallocMem( Data, NewDataSize);
    DataSize:=NewDataSize;
    Xs.CopyToPtr( Data, 6 );
  finally
    FreeAndNil(Xs);
  end;

end;

procedure TBoundSheetRecord.SetOptionFlags(const Value: word);
begin
  SetWord(Data, 4, Value);
end;

{ TObjRecord }

constructor TObjRecord.Create(const aId: word; const aData: PArrayOfByte;
  const aDataSize: integer);
begin
  inherited;
  ObjId:=GetWord(aData, 0);
  if ObjId= ftCmo then CmoId:= GetWord(aData, 4);
end;


{ TTXORecord }

constructor TTXORecord.CreateFromData;
var
  aData: PArrayOfByte;
  aDataSize: integer;
begin
  aDataSize:= 18;
  GetMem(aData, aDataSize);
  try
    FillChar(aData^, aDataSize, 0);
    SetWord(aData, 0, $212);
    Create(xlr_TXO, aData, aDataSize);
  except
    FreeMem(aData);
    raise;
  end; //except
end;

{ TCodeNameRecord }

{ TCodeNameRecord }

constructor TCodeNameRecord.CreateNew(const aName: WideString);
var
  Xs: TExcelString;
  PData: PArrayOfByte;
  DataSize: integer;
begin
  Xs:= TExcelString.Create(2, aName);
  try
    DataSize:=Xs.TotalSize;
    GetMem(PData, DataSize);
    try
      Xs.CopyToPtr( PData, 0 );
      Create( xlr_CODENAME, PData, DataSize);
      PData:=nil;
    finally
      FreeMem(Pdata);
    end;
  finally
    FreeAndNil(Xs);
  end;
end;

function TCodeNameRecord.GetSheetName: WideString;
var
  Xs: TExcelString;
  Ofs: integer;
  Rec: TBaseRecord;
begin
  Ofs:=0;Rec:= Self;
  Xs:= TExcelString.Create(2, Rec, Ofs);
  try
    Result:= Xs.Value;
  finally
    FreeAndNil(Xs);
  end;
end;

procedure TCodeNameRecord.SetSheetName(const Value: WideString);
var
  Xs: TExcelString;
  NewDataSize: integer;
begin
  Xs:= TExcelString.Create(2, Value);
  try
    NewDataSize:=Xs.TotalSize;
    ReallocMem( Data, NewDataSize);
    DataSize:=NewDataSize;
    Xs.CopyToPtr( Data, 0);
  finally
    FreeAndNil(Xs);
  end;
end;

{ TGutsRecord }

constructor TGutsRecord.Create(const aId: word; const aData: PArrayOfByte;
  const aDataSize: integer);
begin
  inherited;
  RecalcNeeded:=false;
end;

function TGutsRecord.DoCopyTo: TBaseRecord;
begin
  Result:= inherited DoCopyTo;
  (Result as TGutsRecord).RecalcNeeded:=RecalcNeeded;
end;

function TGutsRecord.GetColLevel: integer;
begin
  Result:=GetWord(Data, 6);
end;

function TGutsRecord.GetRowLevel: integer;
begin
  Result:=GetWord(Data, 4);
end;

procedure TGutsRecord.SetColLevel(const Value: integer);
begin
  if Value<=0 then
  begin
    SetWord(Data, 2, 0);
    SetWord(Data, 6, 0);
  end else
  if Value <8 then
  begin
    SetWord(Data, 2, 17+(1+value)*12);
    SetWord(Data, 6, 1+value);
  end else
  begin
    SetWord(Data, 2, 17+(1+7)*12);
    SetWord(Data, 6, 1+7);
  end;
end;

procedure TGutsRecord.SetRowLevel(const Value: integer);
begin
  if Value<=0 then
  begin
    SetWord(Data, 0, 0);
    SetWord(Data, 4, 0);
  end else
  if Value <8 then
  begin
    SetWord(Data, 0, 17+(1+value)*12);
    SetWord(Data, 4, 1+value);
  end else
  begin
    SetWord(Data, 0, 17+(1+7)*12);
    SetWord(Data, 4, 1+7);
  end;
end;

{ TPaneRecord }
procedure TPaneRecord.EnsureSelectedVisible();
begin
  case ActivePane of
  0:
    begin
      if ColSplit <= 0 then
      begin
        if RowSplit <= 0 then
        begin
          ActivePane := 3;
          exit;
        end;

        ActivePane := 2;
        exit;
      end;

      if RowSplit <= 0 then
        ActivePane := 1;

      exit;
    end;
  2:
    begin
      if RowSplit <= 0 then
        ActivePane := 3;

      exit;
    end;
  1:
    begin
      if ColSplit <= 0 then
        ActivePane := 3;

      exit;
    end;
  end;
end;

function TPaneRecord.Get_RowSplit(): integer;
begin
  Result := GetWord(Data, 2);
end;

procedure TPaneRecord.Set_RowSplit(const value: integer);
begin
  SetWord(Data, 2, value);
end;

function TPaneRecord.Get_ColSplit(): integer;
begin
  Result := GetWord(Data, 0);
end;

procedure TPaneRecord.Set_ColSplit(const value: integer);
begin
  SetWord(Data, 0, value);
end;

function TPaneRecord.Get_FirstVisibleRow(): integer;
begin
  Result := GetWord(Data, 4);
end;

procedure TPaneRecord.Set_FirstVisibleRow(const value: integer);
begin
  SetWord(Data, 4, value);
end;

function TPaneRecord.Get_FirstVisibleCol(): integer;
begin
  Result := GetWord(Data, 6);
end;

procedure TPaneRecord.Set_FirstVisibleCol(const value: integer);
begin
  SetWord(Data, 6, value);
end;

function TPaneRecord.Get_ActivePane(): integer;
begin
  Result := GetWord(Data, 8);
end;

procedure TPaneRecord.Set_ActivePane(const value: integer);
begin
  SetWord(Data, 8, value);
end;

end.
