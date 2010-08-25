unit UXlsSST;
//This is a unit to optimize the SST for a big number of strings.
//Optimizations:
  //We use records, no objects to strore the strings (4 bytes of VMT per string and avoid calling create/destroy)
  //We don't use Widestrings or Strings to store them (8+6 bytes / string and avoid double allocation, one for the record and one for the string)
  //We use a Big heap to keep all records in same memory position.

interface
uses SysUtils, XlsMessages, UXlsBaseRecords,
     UXlsOtherRecords, UXlsStrings, Classes;
type
  TExtraData=Packed Record
    Refs: word;
    AbsStreamPos: LongWord;
    RecordStreamPos: Word;
    PosInTable:LongWord;
  end;

  PExtraData=^TExtraData;

  PSSTEntry   = PArrayOfByte;
  TSSTEntry   = PSSTEntry; //This is just to be compliant with the object oriented approach

  TSST = class (TList)
    {$INCLUDE TSSTHdr.inc}
    function Find(const s:PSSTEntry; var Index: integer): boolean;
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
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;

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

implementation
{$INCLUDE TSSTImp.inc}

procedure CreateSSTEntryFromString(const s: wideString; var Entry: PSSTEntry);
var
  OptionFlags: byte;
begin
  if IsWide(s) then OptionFlags:=1 else OptionFlags:=0;

  GetMem(Entry, SizeOf(TExtraData)+ //Extra data not to be saved
                SizeOf(Word) + // String Length
                SizeOf(byte) + // OptionsFlag
                Length(s)*(1+OptionFlags));

  PExtraData(Entry).Refs:=0;
  PExtraData(Entry).AbsStreamPos:=0;
  PExtraData(Entry).RecordStreamPos:=0;
  PExtraData(Entry).PosInTable:=0;

  SetWord(Entry, SizeOf(TExtraData), Length(s));
  Entry[2+SizeOf(TExtraData)]:=OptionFlags;
  if OptionFlags= 1 then System.Move(s[1], Entry^[3+SizeOf(TExtraData)], Length(s)*2)
    else System.Move(WideStringToStringNoCodePage(s)[1], Entry^[3+SizeOf(TExtraData)], Length(s));
end;

procedure CreateSSTEntryFromRecord(var aSSTRecord: TBaseRecord; var Ofs: integer; var Entry: PSSTEntry);
var
  Xs: TExcelString;
begin
  Xs:=TExcelString.Create(2, aSSTRecord, Ofs); //Ok, we use TExcelString... This could be done without creating an object, but I don't think there is a difference
                                             // and it's complicated, because it has to handle all continues and char-widechar issues
  try
    GetMem(Entry, SizeOf(TExtraData)+Xs.TotalSize);
    PExtraData(Entry).Refs:=0;
    PExtraData(Entry).AbsStreamPos:=0;
    PExtraData(Entry).RecordStreamPos:=0;
    PExtraData(Entry).PosInTable:=0;
    Xs.CopyToPtr(Entry, SizeOf(TExtraData));
  finally
    FreeAndNil(Xs);
  end;

end;

function SSTLength(const S: PSSTEntry): int64;
var
  OptionFlags: byte;
  Ofs: integer;
begin
    Ofs:=0;
    OptionFlags:=S[2+SizeOf(TExtraData)];
    Result:=SizeOf(TExtraData)+
            2+ //Length
            SizeOf(OptionFlags);
    if OptionFlags and $1 = 0 then Result:=Result+GetWord(s, SizeOf(TExtraData))
        else Result:= Result+GetWord(s, SizeOf(TExtraData))*2;

    //Rich text
    if OptionFlags and $8 = $8 {HasRichText} then
    begin
      Result:=Result + 2+ 4* GetWord(S,3+SizeOf(TExtraData));
      Ofs:=2;
    end;

    //FarEast
    if OptionFlags and $4 = $4 {HasFarInfo} then
      Result:=Result+ 4 + GetCardinal(S, 3+SizeOf(TExtraData)+Ofs);
end;

function SSTRealLength(const S: PSSTEntry): int64;
begin
  Result:=SSTLength(S)-SizeOf(TExtraData);
end;
function CompareSSTEntry(const S1, S2: PSSTEntry): integer;
var
  i:integer;
  L1, L2: integer;
begin
  Result:=0;
  L1:= SSTLength(S1);
  L2:= SSTLength(S2);
  if L1<L2 then Result:=-1 else if L1>L2 then Result:=1
  else
  for i:=SizeOf(TExtraData) to L1-1 do
  begin
    if S1[i]=S2[i] then continue
    else if S1[i]<S2[i] then Result:=-1 else Result:=1;
    exit;
  end;
end;

function CompareSSTEntries(Item1, Item2: Pointer): Integer;
begin
  CompareSSTEntries:= CompareSSTEntry(TSSTEntry(Item1),TSSTEntry(Item2));
end;


procedure AddSSTRef(const Entry: PSSTEntry);
begin
  Inc(PExtraData(Entry).Refs);
end;

procedure DecSSTRef(const Entry: PSSTEntry);
begin
  Dec(PExtraData(Entry).Refs);
end;

function SSTRefs(const Entry: PSSTEntry): word;
begin
  Result:=PExtraData(Entry).Refs;
end;

procedure SaveSSTToStream(const Entry: PSSTEntry; const DataStream: TStream; const BeginRecordPos: Cardinal);
begin
  PExtraData(Entry).AbsStreamPos:=DataStream.Position;
  PExtraData(Entry).RecordStreamPos:= PExtraData(Entry).AbsStreamPos- BeginRecordPos;
  DataStream.Write((PChar(Entry)+SizeOf(TExtraData))^, SSTRealLength(Entry));
end;

function GetSSTValue(const Entry: PSSTEntry): widestring;
var
  OptionFlags: byte;
  Ini: integer;
  St: string;
begin
    OptionFlags:=Entry[2+SizeOf(TExtraData)];
    Ini:=SizeOf(TExtraData)+
            2+ //Length
            SizeOf(OptionFlags);
    //Rich text
    if OptionFlags and $8 = $8 {HasRichText} then
      Inc(Ini, 2);

    //FarEast
    if OptionFlags and $4 = $4 {HasFarInfo} then
      Inc(Ini, 4);

    if OptionFlags and $1 = 0 then
    begin
      SetLength(St, GetWord(Entry, SizeOf(TExtraData)));
      Move(Entry[Ini], St[1], Length(St));
      Result:=StringToWideStringNoCodePage(St);
      exit;
    end else
    begin
      SetLength(Result, GetWord(Entry, SizeOf(TExtraData)));
      Move(Entry[Ini], Result[1], Length(Result)*2);
    end;

end;

//**************************************************************
{ TSST }
function TSST.AddString(const s: Widestring): integer;
var
  es: PSSTEntry;
begin
  CreateSSTEntryFromString(s, es);
  try
    if Find(es, Result) then AddSSTRef(Items[Result]) else
    begin
      Insert(Result, es);
      AddSSTRef(es);
      es:=nil;  //so we dont free it
    end;
  finally
    if es<>nil then Freemem(es);
  end;
end;

function TSST.Find(const S: PSSTEntry; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := CompareSSTEntry(Items[I],S);
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
    CreateSSTEntryFromRecord(TmpSSTRecord, Ofs, Es);
    try
      Add(Es);
      Es:=nil;
    finally
      if es<>nil then Freemem(Es);
    end; //Finally
  end;
  //We can't sort now, this should be done after all the LABELSST records have been loaded
end;

procedure TSST.FixRefs;
var
  i: integer;
begin
  for i:=count-1 downto 0 do
    if SSTRefs(Items[i])<=0 then Delete(i);
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
    Assert(SSTRefs(Se)>0,'Refs should be >0');
    PExtraData(Se).PosInTable:=i;
    TotalRefs:=TotalRefs+Cardinal(SSTRefs(Se));
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
      SaveSSTToStream(Items[i], DataStream, BeginRecordPos);
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
    DataStream.Write(PExtraData(Items[i]).AbsStreamPos, SizeOf(PExtraData(Items[i]).AbsStreamPos));
    DataStream.Write(PExtraData(Items[i]).RecordStreamPos, SizeOf(PExtraData(Items[i]).RecordStreamPos));
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
  if Last<Count then RSize:=SSTRealLength(Items[Last]) else RSize:=0;
  while (Last<Count) and (RecordSize+ RSize< MaxRecordDataSize) do
  begin
    inc(RecordSize, RSize);
    inc(Last);
    if Last<Count then RSize:=SSTRealLength(Items[Last]);
  end;
  if (First=Last) and (Last<Count) then raise Exception.Create(ErrStringTooLarge);
end;

procedure TSST.Notify(Ptr: Pointer; Action: TListNotification);
begin
    if Action = lnDeleted then
      FreeMem(Ptr);
  inherited Notify(Ptr, Action);
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
  AddSSTRef(pSSTEntry);
end;

destructor TLabelSSTRecord.Destroy;
begin
  if pSSTEntry<>nil then DecSSTRef(pSSTEntry);
  inherited;
end;

procedure TLabelSSTRecord.SaveToStream(const Workbook: TStream);
begin
  SetCardinal(Data, 6, PExtraData(pSSTEntry).PosInTable);
  inherited;
end;

function TLabelSSTRecord.DoCopyTo: TBaseRecord;
begin
  Result:= inherited DoCopyTo;
  (Result as TLabelSSTRecord).SST:= SST;
  (Result as TLabelSSTRecord).pSSTEntry:= pSSTEntry;
  AddSSTRef((Result as TLabelSSTRecord).pSSTEntry);

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
  Result:=GetSSTValue(pSSTEntry);
end;

procedure TLabelSSTRecord.SetAsString(const Value: WideString);
var
  OldpSSTEntry: TSSTEntry;
begin
  OldpSSTEntry:=pSSTEntry;
  pSSTEntry:= SST[SST.AddString(Value)];
  if OldpSSTEntry<>nil then DecSSTRef(OldpSSTEntry);
end;

constructor TLabelSSTRecord.CreateFromData(const aRow, aCol, aXF: word; const aSST: TSST);
begin
  inherited CreateFromData(xlr_LABELSST, 10, aRow, aCol, aXF);
  SST:=aSST;
end;


end.
