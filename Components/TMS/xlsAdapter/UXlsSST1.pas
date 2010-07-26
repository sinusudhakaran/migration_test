//This unit is now obsoleted by UXlsSST.
//It does the same, but using objects instead of records.

unit UXlsSST;

interface
uses UXlsBaseRecordLists, UXlsBaseRecords, UXlsOtherRecords, XLSMessages, SysUtils,
     Contnrs, Classes, UXlsStrings, UXlsBaseList;
type
  TSST=class;

  TSSTEntry   = class(TExcelString)
  //We derive TSSTEntry from TExcelString instead of including a TExcelString inside it for performance
  //Avoiding the creation / disposal of 100.000 ExcelStrings can make some difference...
  //Maybe this should be just pointers, to have better performance. And maybe each pointer including many strings.
  private
    Refs: integer;

    AbsStreamPos: Cardinal;
    RecordStreamPos: Word;
  public
    PosInTable:Cardinal;

    procedure AddRef;
    procedure ReleaseRef;

    procedure SaveToStream(const DataStream: TStream; const BeginRecordPos: Cardinal);
  end;

  TLabelSSTRecord= class(TCellRecord)
  private
    pSSTEntry: TSSTEntry;
    SST: TSST;
    function GetAsString: WideString;
    procedure SetAsString(const Value: WideString);
  protected
    function GetValue: Variant; override;
    procedure SetValue(const Value: Variant); override;
    function DoCopyTo: TBaseRecord; override;
  public
    constructor  Create(const aId: word; const aData: PArrayOfByte; const aDataSize: integer);override;
    constructor CreateFromData(const aRow, aCol, aXF: word; const aSST: TSST);

    procedure AttachToSST(const aSST: TSST);
    procedure SaveToStream(const Workbook: TStream); override;

    destructor Destroy;override;

    property AsString: WideString read GetAsString write SetAsString;
  end;



  TSST = class (TBaseList)
    {$INCLUDE TSSTHdr.inc}
    function Find(const s:TExcelString; var Index: integer): boolean;
    procedure Load(const aSSTRecord: TSSTRecord);
    procedure SaveToStream(const DataStream: TStream);
    procedure WriteExtSST(const DataStream: TStream);
    function AddString(const s:Widestring):integer;
    procedure Sort;
    function TotalSize: int64;
    function SSTRecordSize: int64;
    function ExtSSTRecordSize: int64;
    procedure FixRefs;
  private
    procedure CalcNextContinue(const First: integer; var Last: integer;
      var RecordSize: word);
  end;

implementation
{$INCLUDE TSSTImp.inc}

{ TSSTEntry }

procedure TSSTEntry.AddRef;
begin
  inc(Refs);
end;

procedure TSSTEntry.ReleaseRef;
begin
  dec(Refs);
end;

procedure TSSTEntry.SaveToStream(const DataStream: TStream; const BeginRecordPos: Cardinal);
begin
  AbsStreamPos:=DataStream.Position;
  RecordStreamPos:= AbsStreamPos- BeginRecordPos;
  inherited SaveToStream(DataStream);
end;

function CompareSSTEntries(Item1, Item2: Pointer): Integer;
begin
  CompareSSTEntries:= TSSTEntry(Item1).Compare(TSSTEntry(Item2));
end;


{ TSST }
function TSST.AddString(const s: Widestring): integer;
var
  es: TSSTEntry;
begin
  es:= TSSTEntry.Create(2,s);
  try
    if Find(es, Result) then Items[Result].AddRef else
    begin
      Insert(Result, es);
      es.AddRef;
      es:=nil;  //so we dont free it
    end;
  finally
    FreeAndNil(es);
  end;
end;

function TSST.Find(const S: TExcelString; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := Items[I].Compare(S);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        L := I;
      end;
    end;
  end;
  Index := L;
end;

procedure TSST.Load(const aSSTRecord: TSSTRecord);
var
  i, Ofs:integer;
  Es: TSSTEntry;
  TmpSSTRecord: TBaseRecord;
begin
  Ofs:=8;
  TmpSSTRecord:= aSSTRecord;
  for i:=0 to aSSTRecord.Count-1 do
  begin
    Es:= TSSTEntry.Create(2, TmpSSTRecord, Ofs);
    try
      Add(Es);
      Es:=nil;
    finally
      FreeAndNil(Es);
    end; //Finally
  end;
  //We can't sort now, this should be done after all the LABELSST records have been loaded
end;

procedure TSST.FixRefs;
var
  i: integer;
begin
  for i:=count-1 downto 0 do
    if Items[i].Refs<=0 then Delete(i);
end;

procedure TSST.SaveToStream(const DataStream: TStream);
var
  i:integer;
  TotalRefs, aCount: Cardinal;
  RecordHeader: TRecordHeader;
  BeginRecordPos: Cardinal;
  First, Last: integer;
  Se: TSSTEntry;
begin
  BeginRecordPos:=DataStream.Position;
  RecordHeader.Id:= xlr_SST;

  //Renum the items
  i:=0; TotalRefs:=0;
  while i< Count do
  begin
    Se:=Items[i];
    Assert(Se.Refs>0,'Refs should be >0');
    Se.PosInTable:=i;
    TotalRefs:=TotalRefs+Cardinal(Se.Refs);
    inc(i);
   end;


  First:=0;
  RecordHeader.Size:=8;
  CalcNextContinue(First, Last, RecordHeader.Size);

  DataStream.Write(RecordHeader, SizeOf(RecordHeader));
  DataStream.Write(TotalRefs, SizeOf(TotalRefs));
  aCount:=Count;
  DataStream.Write(aCount, Sizeof(aCount));

  while First<Count do
  begin
    for i:= First to Last-1 do
    begin
      Items[i].SaveToStream(DataStream, BeginRecordPos);
    end;

    //Write continue
    First:=Last;
    if First<Count then
    begin
      BeginRecordPos:= DataStream.Position;
      RecordHeader.Id:= xlr_CONTINUE;
      RecordHeader.Size:=0;
      CalcNextContinue(First, Last, RecordHeader.Size);
      DataStream.Write(RecordHeader, SizeOf(RecordHeader));
    end;
  end;

  WriteExtSST(DataStream);
end;

procedure TSST.WriteExtSST(const DataStream: TStream);
var
  n, nBuckets, Dummy: Word;
  i: integer;
  RecordHeader: TRecordHeader;
begin
  // Calc number of strings per hash bucket
  n:=Count div 128+1;
  if n<8 then n:=8;

  if Count=0 then nBuckets:=0 else nBuckets:= (Count-1) div n + 1;

  RecordHeader.Id:= xlr_EXTSST;
  RecordHeader.Size:= 2+8*nBuckets;
  DataStream.Write(RecordHeader, SizeOf(RecordHeader));
  DataStream.Write(n, SizeOf(n));
  i:= 0; Dummy:=0;
  while i<Count do
  begin
    DataStream.Write(Items[i].AbsStreamPos, SizeOf(Items[i].AbsStreamPos));
    DataStream.Write(Items[i].RecordStreamPos, SizeOf(Items[i].RecordStreamPos));
    DataStream.Write(Dummy, SizeOf(Dummy));
    inc(i,n);
  end;

end;

procedure TSST.Sort;
begin
  inherited Sort(CompareSSTEntries)
end;

function TSST.ExtSSTRecordSize: int64;
var
  n, nBuckets: word;
begin
  n:=Count div 128+1;
  if n<8 then n:=8;

  if Count=0 then nBuckets:=0 else nBuckets:= (Count-1) div n + 1;
  Result:= 2+8*nBuckets;
end;

function TSST.SSTRecordSize: int64;
//Has to handle continue records
var
  First, Last: integer;
  Rs: Word;
begin
  Result:=8;
  Rs:=0;
  First:=0;
  while First<Count do
  begin
    CalcNextContinue(First,Last, Rs);
    First:=Last;
    Result:=Result+Rs;
    if Last< Count then Result:=Result+SizeOf(TRecordHeader);
    Rs:=0;
  end;
end;


function TSST.TotalSize: int64;
begin
  Result:= SSTRecordSize + ExtSSTRecordSize + 2* SizeOf(TRecordHeader);
end;

procedure TSST.CalcNextContinue(const First: integer; var Last: integer; var RecordSize: word);
var
 RSize: integer;
begin
  Last:=First;
  if Last<Count then RSize:=Items[Last].TotalSize else RSize:=0;
  while (Last<Count) and (RecordSize+ RSize< MaxRecordDataSize) do
  begin
    inc(RecordSize, RSize);
    inc(Last);
    if Last<Count then RSize:=Items[Last].TotalSize;
  end;
  if (First=Last) and (Last<Count) then raise Exception.Create(ErrStringTooLarge);
end;

{ TLabelSSTRecord }

constructor TLabelSSTRecord.Create(const aId: word;
  const aData: PArrayOfByte; const aDataSize: integer);
begin
  inherited Create(aId, aData, aDataSize);
end;

procedure TLabelSSTRecord.AttachToSST(const aSST: TSST);
var
  a:int64;
begin
  SST:=aSST;
  a:=GetCardinal(Data,6);
  if a> SST.Count then raise Exception.Create(ErrExcelInvalid);
  pSSTEntry:= SST[a];
  pSSTEntry.AddRef;
end;

destructor TLabelSSTRecord.Destroy;
begin
  if pSSTEntry<>nil then pSSTEntry.ReleaseRef;
  inherited;
end;

procedure TLabelSSTRecord.SaveToStream(const Workbook: TStream);
begin
  SetCardinal(Data, 6, pSSTEntry.PosInTable);
  inherited;
end;

function TLabelSSTRecord.DoCopyTo: TBaseRecord;
begin
  Result:= inherited DoCopyTo;
  (Result as TLabelSSTRecord).SST:= SST;
  (Result as TLabelSSTRecord).pSSTEntry:= pSSTEntry;
  (Result as TLabelSSTRecord).pSSTEntry.AddRef;

end;

function TLabelSSTRecord.GetValue: Variant;
begin
  Result:=GetAsString;
end;

procedure TLabelSSTRecord.SetValue(const Value: Variant);
begin
  SetAsString(Value);
end;

function TLabelSSTRecord.GetAsString: WideString;
begin
  Result:=pSSTEntry.Value;
end;

procedure TLabelSSTRecord.SetAsString(const Value: WideString);
var
  OldpSSTEntry: TSSTEntry;
begin
  OldpSSTEntry:=pSSTEntry;
  pSSTEntry:= SST[SST.AddString(Value)];
  if OldpSSTEntry<>nil then OldpSSTEntry.ReleaseRef;
end;

constructor TLabelSSTRecord.CreateFromData(const aRow, aCol, aXF: word; const aSST: TSST);
begin
  inherited CreateFromData(xlr_LABELSST, 10, aRow, aCol, aXF);
  SST:=aSST;
end;

end.
