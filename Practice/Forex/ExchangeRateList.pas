unit ExchangeRateList;
//------------------------------------------------------------------------------
//  Title:   Exchange Rate List
//
//  Written: July 2010
//
//  Authors: Andre' Joosten, Scott Wilson
//
//  Purpose: Creates a binary tree for acessing exchange rates.
//
//  Notes:
//------------------------------------------------------------------------------
interface

uses
  ECollect, stDate, Classes, mcDefs, ioStream, stTree,stBase, sysUtils,
  AuditMgr;

type
  RateArray = array of Double;

  TExchangeRecord = class(TPersistent)
  // Record for each date
  // The rates are in a Dinamic array to save memory
  // These rates should be in step with the Header of the Source
  private
    FRates: RateArray;
    FAuditID: integer;
    function GetRates(index: Integer): Double;
    procedure SetRates(index: Integer; const Value: Double);
    function Getwidth: integer;
    procedure SetDate(const Value: TstDate);
    procedure SetLocked(const Value: Boolean);
    procedure SetAuditID(const Value: integer);
  public
    FDate: TStdate;
    FLocked: Boolean;
    constructor Create(Fromrec: pExchange_Rate_Rec; Width: Integer); overload;
    constructor Create(ForDate: tstDate; Width: Integer); overload;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure loadFromExchange_Rate_Rec(Value: pExchange_Rate_Rec);
    procedure SaveToExchange_Rate_Rec(Value: pExchange_Rate_Rec);
    property Rates [index: Integer]: Double read GetRates write SetRates;
    property Width: integer read Getwidth;
    property Date: TstDate read FDate write SetDate;
    property Locked: Boolean read FLocked write SetLocked;
    property AuditID: integer read FAuditID write SetAuditID;
  end;

  PExchangeSource = ^TExchangeSource;
  TExchangeSource = class(TPersistent)
  // A specific Exchange rate source in a list, or just in the Client file as is.
  // Has a BinaryTree to store the records as above
  private
    FHeader: TExchange_Rates_Header_Rec;
    FExchangeTree: TStTree;
    FAuditTable: TAuditTable;  //used in AuditExchangeRates    
    function GetHeaderWidth(Value: TExchange_Rates_Header_Rec): Integer;
    function GetWidth: Integer;
    procedure LoadExchangeRates(var S : TIOStream);
    function GetAuditTrialID: integer;
    procedure SetAuditTrialID(const Value: integer);
    function GetFileVersion: integer;
    procedure SetFileVersion(const Value: integer);
    procedure SetAuditInfo(P1, P2: pExchange_Rates_Header_Rec; var AAuditInfo: TAuditInfo);
    function ISOCodesAsStr: string;
  public
    constructor Create; overload;
    constructor Create(var S: TIOStream); overload;
    destructor Destroy; override;
    function GetISOIndex(Value: string; FromHeader: TExchange_Rates_Header_Rec): Integer;
    procedure SaveToStream(var S : TIOStream );
    procedure LoadFromStream(var S : TIOStream );
    procedure MapToHeader(NewHeader: TExchange_Rates_Header_Rec);
    procedure Assign(Source: TPersistent); override;
    property Width: Integer read GetWidth;
    property Header: TExchange_Rates_Header_Rec read FHeader;
    property ExchangeTree: TStTree read FExchangeTree;
    function GetDateRates(Value: tstDate): TExchangeRecord;
    function Iterate (Action: TIterateFunc; Up: Boolean;
                      OtherData: Pointer): TStTreeNode;
    procedure DoAudit(AAuditType: TAuditType; AExchangeRateSourceCopy: TExchangeSource;
                      AAuditManager: TExchangeRateAuditManager; AAuditTable: TAuditTable);
    property AuditTrialID: integer read GetAuditTrialID write SetAuditTrialID;
    property FileVersion: integer read GetFileVersion write SetFileVersion;
  end;

  TExchangeRateList = class(TExtdSortedCollection)
  private
    FAuditTable: TAuditTable;
    FAuditManager: TExchangeRateAuditManager;
    FLocked: Boolean;
    FLastAuditRecordID: integer;
    FExchangeRateListCopy: TExchangeRateList;
    FLoading: Boolean;
    function Lock: Boolean;
    procedure SaveToFile(Filename: string);
    procedure ReadFromFile(Filename: string);
    procedure ExchangeRateCopyReload(var S: TIOStream);
    function GetExchangeRateListCopy: TExchangeRateList;
  protected
    procedure FreeItem( Item : Pointer ); override;
  public
    constructor Create;
    destructor Destroy; override;
    function Compare( Item1, Item2 : pointer ) : integer; override;
    function ExchangeSource( Index : LongInt ): TExchangeSource;
    procedure SaveToStream(var S : TIOStream );
    procedure LoadFromStream(var S : TIOStream );
    function LockAndLoad(const KeepLock: Boolean = False): Boolean;
    function Unlock: Boolean;
    function Save: Boolean;// Saves and unlocks
    function GetSource(const Value: string):TExchangeSource; // Forces if not there
    function GiveMeSource(const Value: string):TExchangeSource; // As above but takes it from the list
    function FindSource(const Value: string):TExchangeSource; // is it in the list
    function MergeSource(Value:TExchangeSource):TExchangeSource; // update in the list...
    function NextAuditRecordID: integer;
    procedure ExchangeRateCopyReset;
    procedure DoAudit(AAuditType: TAuditType; AExchangeRateListCopy: TExchangeRateList);
    property AuditTable: TAuditTable read FAuditTable;
    property AuditMgr: TExchangeRateAuditManager read FAuditManager;
    property ExchangeRateListCopy: TExchangeRateList read GetExchangeRateListCopy;
  end;

  // So I Can use them in the admin system...
  procedure WriteCurrencyList(var Rec: TExchange_Rates_Header_Rec; var S : TIOStream);
  procedure ReadCurrencyList(var Rec: TExchange_Rates_Header_Rec; var S : TIOStream);

  const // Could make this a Type, but the record cannot handle it direct...
    ct_System = 0;
    ct_Base = 1;
    ct_User = 2;
    EXCHANGE_RATE_FILENAME = 'ExchangeRates.db';

  function GetExchangeRates(const KeepLock: Boolean = False): TExchangeRateList;

  function AddAuditIDs(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;

//******************************************************************************

implementation

uses
  Math,
  CRCFileUtils,
  WinUtils,
  LockUtils,
  Admin32,
  SysObj32,
  Globals,
  compUtils,
  mcehIO,
  mcerIO,
  TOKENS,
  logutil,
  MALLOC,
  StStrS,
  bkdbExcept,
  bk5Except,
  bkdateutils;

const
  DEBUG_ME : Boolean = FALSE;
  UNIT_NAME = 'ExchangeRateList';

function GetExchangeRates(const KeepLock: Boolean = False): TExchangeRateList;
begin
  Result := TExchangeRateList.Create;
  Result.LockAndLoad(KeepLock);
end;

function ExchangeRecordCompare(Item1, Item2: Pointer): Integer;
begin
  Result := Compare(TExchangeRecord(Item1).Date, TExchangeRecord(Item2).Date);
end;

procedure ExchangeRecordFree(Item: Pointer);
begin
  TExchangeRecord(Item).Free;
end;

procedure WriteCurrencyList(var Rec: TExchange_Rates_Header_Rec; var S : TIOStream);
begin
   S.WriteToken(tkBeginExchangeRateHeader);
     Rec.ehRecord_Type := tkBegin_Exchange_Rates_Header;
     Rec.ehEOR := tkEnd_Exchange_Rates_Header;
     MCehIO.Write_Exchange_Rates_Header_Rec(Rec,S);
   S.WriteToken(tkEndSection);
end;

procedure ReadCurrencyList(var Rec: TExchange_Rates_Header_Rec; var S : TIOStream);
begin
   Read_Exchange_Rates_Header_Rec(Rec,S);
   S.ReadToken;
end;


{ TExchangeSource }

constructor TExchangeSource.Create;
begin
  inherited;

  FExchangeTree := TStTree.Create(TStTreeNode);
  FExchangeTree.Compare := ExchangeRecordCompare;
  FExchangeTree.DisposeData := ExchangeRecordFree;

  FillChar(FHeader, Sizeof(FHeader),0);
end;

function AssignExchangeRecords(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  ExchangeRecord, SourceExchangeRec: TExchangeRecord;
  ExchangeSource: TExchangeSource;
begin
  Result := True;
  ExchangeSource := TExchangeSource(OtherData^);
  SourceExchangeRec := TExchangeRecord(Node.Data);
  //new rec
  ExchangeRecord := TExchangeRecord.Create(SourceExchangeRec.Date, SourceExchangeRec.Width);
  ExchangeRecord.Assign(SourceExchangeRec);
  ExchangeSource.ExchangeTree.Insert(ExchangeRecord)
end;

procedure TExchangeSource.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TExchangeSource) then begin
    //Header
    FHeader.ehRecord_Type  := TExchangeSource(Source).Header.ehRecord_Type;
    FHeader.ehFile_Version := TExchangeSource(Source).Header.ehFile_Version;
    FHeader.ehLRN          := TExchangeSource(Source).Header.ehLRN;
    FHeader.ehName         := TExchangeSource(Source).Header.ehName;
    FHeader.ehList_Type    := TExchangeSource(Source).Header.ehList_Type;
    FHeader.ehISO_Codes    := TExchangeSource(Source).Header.ehISO_Codes;
    FHeader.ehCur_Type     := TExchangeSource(Source).Header.ehCur_Type;
    FHeader.ehEOR          := TExchangeSource(Source).Header.ehEOR;
    //Tree
//    FExchangeTree.Assign(TExchangeSource(Source).FExchangeTree); //This only copies the pointers into the new stTree
    FExchangeTree.Clear;
    TExchangeSource(Source).FExchangeTree.Iterate(AssignExchangeRecords, true, @Self);
  end;
end;

constructor TExchangeSource.Create(var S: TIOStream);
begin
   Create;
   LoadFromStream(S);
end;

destructor TExchangeSource.Destroy;
begin
  FreeAndNil(FExchangeTree);
  inherited;
end;

function AuditExchangeRates(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  ER: TExchangeRecord;
  P1, P2: pExchange_Rate_Rec;
  ExchangeRateSourceCopy: TExchangeSource;
  AuditInfo: TAuditInfo;
begin
  ER := TExchangeRecord(Node.Data);
  New(P1);
  try
    ER.SaveToExchange_Rate_Rec(P1);
    ExchangeRateSourceCopy := TExchangeSource(OtherData^);

    AuditInfo.AuditType := atExchangeRates;
    AuditInfo.AuditUser := '';
    AuditInfo.AuditRecordType := tkBegin_Exchange_Rate;
    //Adds, changes
    if Assigned(ExchangeRateSourceCopy) then begin
      ER := ExchangeRateSourceCopy.GetDateRates(P1.erApplies_Until);
      AuditInfo.AuditRecord := New_Exchange_Rate_Rec;
      try
        AuditInfo.AuditAction := aaNone;
        //Parent ID will always be zero because we only have one ER source
        AuditInfo.AuditParentID := 0;
        AuditInfo.AuditOtherInfo := Format('%s=%s', ['RecordType','Exchange Rates']) +
                                    VALUES_DELIMITER +
                                    Format('%s=%d', ['ParentID', 0]) +
                                    VALUES_DELIMITER +
                                    Format('%s=%s', ['Date', bkDate2Str(P1^.erApplies_Until)]) +
                                    VALUES_DELIMITER +
                                    Format('%s=%s', ['ISO Codes', ExchangeRateSourceCopy.ISOCodesAsStr]);

        if Assigned(ER) then begin
          New(P2);
          try
            ER.SaveToExchange_Rate_Rec(P2);
            //Change
            AuditInfo.AuditRecordID := P1.erAudit_Record_ID;
            if Exchange_Rate_Rec_Delta(P1, P2, AuditInfo.AuditRecord, AuditInfo.AuditChangedFields) then
              AuditInfo.AuditAction := aaChange;
          finally
            Dispose(P2);
          end;
        end else begin
          //Add
          AuditInfo.AuditAction := aaAdd;
          AuditInfo.AuditRecordID := P1.erAudit_Record_ID;
          P1.erAudit_Record_ID := AuditInfo.AuditRecordID;
          MCERIO.SetAllFieldsChanged(AuditInfo.AuditChangedFields);
          Copy_Exchange_Rate_Rec(P1, AuditInfo.AuditRecord);
        end;
        if AuditInfo.AuditAction in [aaAdd, aaChange] then
           ExchangeRateSourceCopy.FAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
    end;
  finally
    Dispose(P1);
  end;
  Result := True;
end;

procedure TExchangeSource.DoAudit(AAuditType: TAuditType;
  AExchangeRateSourceCopy: TExchangeSource; AAuditManager: TExchangeRateAuditManager;
  AAuditTable: TAuditTable);
var
  AuditInfo: TAuditInfo;
  HeaderCopy: TExchange_Rates_Header_Rec;
begin
  AuditInfo.AuditAction := aaNone;
  AuditInfo.AuditType := atExchangeRates;
  AuditInfo.AuditRecordType := tkBegin_Exchange_Rates_Header;
  //Exchange source
  AuditInfo.AuditRecord := New_Exchange_Rates_Header_Rec;
  try
    HeaderCopy := AExchangeRateSourceCopy.Header;
    SetAuditInfo(@Header, @HeaderCopy, AuditInfo);
    if (AuditInfo.AuditAction <> aaNone) then begin
      AuditInfo.AuditUser := AAuditManager.CurrentUserCode;
      AAuditTable.AddAuditRec(AuditInfo);
    end;
  finally
    Dispose(AuditInfo.AuditRecord);
  end;

  //Exchange Rates
  //Exchangr rates are stored in a binary tree. Need to iterate both the current
  //tree (adds/changes) and the copy (deletes)
  //May need new object to be able to audit in the interate function: AuditManager, Rates Copy, AuditTable
  AExchangeRateSourceCopy.FAuditTable := AAuditTable;
  FExchangeTree.Iterate(AuditExchangeRates, True, @AExchangeRateSourceCopy);
end;

function TExchangeSource.GetISOIndex(Value: string; FromHeader: TExchange_Rates_Header_Rec): Integer;
begin
   for Result := low(FromHeader.ehISO_Codes) to High(FromHeader.ehISO_Codes) do
      if SameText(FHeader.ehISO_Codes[Result], Value) then 
         Exit;
         
   Result := 0; // Not in it...
end;

function TExchangeSource.GetWidth: Integer;
begin
   Result := GetHeaderWidth(FHeader);
end;

function TExchangeSource.ISOCodesAsStr: string;
var
  i: integer;
begin
  Result := '';
  i := 1;
  while FHeader.ehISO_Codes[i] <> '' do begin
    if Result = '' then
      Result := FHeader.ehISO_Codes[i]
    else
      Result := Result + ',' + FHeader.ehISO_Codes[i];
    Inc(i);
  end;
end;

function TExchangeSource.Iterate(Action: TIterateFunc; Up: Boolean;
  OtherData: Pointer): TStTreeNode;
begin
   Result := nil;
   if Assigned(FExchangeTree) then
      Result := FExchangeTree.Iterate(Action, Up, OtherData);
end;

function TExchangeSource.GetAuditTrialID: integer;
begin
  Result := FHeader.ehAudit_Record_ID;
end;

function TExchangeSource.GetDateRates(Value: tstDate): TExchangeRecord;
var LR: TExchangeRecord;
    lt: TStTreeNode;
begin
   result := nil;
   if Assigned(FExchangeTree) then begin
      LR := TExchangeRecord.Create(Value,0);
      try
         lt := FExchangeTree.Find(LR);
         if Assigned(lt) then
            Result := TExchangeRecord(lt.Data);
      finally
         FreeAndNil(LR);
      end;
   end;
end;

function TExchangeSource.GetFileVersion: integer;
begin
  Result := FHeader.ehFile_Version;
end;

function TExchangeSource.GetHeaderWidth(Value: TExchange_Rates_Header_Rec): Integer;
var C: Integer;
begin
   for C := low(Value.ehISO_Codes) to High(Value.ehISO_Codes) do
//      if FHeader.ehISO_Codes[C] = '' then begin
      if Value.ehISO_Codes[C] = '' then begin
         // The first empty one..
         Result := C - low(Value.ehISO_Codes);
         Exit;
      end;
//   Result := High(FHeader.ehISO_Codes) - Low(FHeader.ehISO_Codes);
   Result := High(Value.ehISO_Codes) - Low(Value.ehISO_Codes);
end;

procedure TExchangeSource.LoadExchangeRates(var S: TIOStream);
var
  Token: Byte;
  Rec: tExchange_Rate_Rec;
  W: Integer;
  Msg: string;
begin
  W := Width;
  Token := S.ReadToken;
  while (Token <> tkEndSection) do begin
    case token of
      tkBegin_Exchange_Rate:
        begin
          Read_Exchange_Rate_Rec(Rec,S);
          if (W > 0) then
            FExchangeTree.Insert(TExchangeRecord.Create(@Rec, Width));
          end;
      else begin { Should never happen }
        Msg := Format('%s : Unknown Token %d', ['LoadExchangeRates', Token]);
        LogUtil.LogMsg(lmError, UNIT_NAME, Msg );
        raise ETokenException.CreateFmt( '%s - %s', [ UNIT_NAME, Msg ] );
      end;
    end;
    Token := S.ReadToken;
  end;
end;

procedure TExchangeSource.LoadFromStream(var S: TIOStream);
const
  THIS_METHOD_NAME = 'TExchangeSource.LoadFromFile';
var
  Token: Byte;
  Msg: string;
begin
  FExchangeTree.Clear;
  Token := S.ReadToken;
  while (Token <> tkEndSection) do begin
     case Token of
        tkBeginExchangeRateHeader:;
        tkBegin_Exchange_Rates_Header: begin
           Read_Exchange_Rates_Header_Rec(FHeader, S);
        end;

        tkBeginExchangeRates: LoadExchangeRates(S);

        else begin { Should never happen }
           Msg := Format( '%s : Unknown Token %d', [ THIS_METHOD_NAME, Token ] );
           LogUtil.LogMsg(lmError, UNIT_NAME, Msg );
           raise ETokenException.CreateFmt( '%s - %s', [ UNIT_NAME, Msg ] );
        end;
     end; { of Case }
     Token := S.ReadToken;
  end;
end;

//******************************************************************************
function WriteExchangeRates(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  S: TIOStream;
  ER: tExchange_Rate_Rec;
begin
  S := TIOStream(OtherData^);
  TExchangeRecord(Node.Data).SaveToExchange_Rate_Rec(@ER);
  mcerIO.Write_Exchange_Rate_Rec(ER, S);
  Result := True;
end;
//******************************************************************************

procedure TExchangeSource.SaveToStream(var S: TIOStream);

begin
  S.WriteToken(tkBeginExchangeRateHeader);
  try
     // Write The header
     FHeader.ehRecord_Type := tkBegin_Exchange_Rates_Header;
     FHeader.ehEOR := tkEnd_Exchange_Rates_Header;
     FHeader.ehFile_Version := MC_FILE_VERSION;
     Write_Exchange_Rates_Header_Rec(FHeader, S);

     if Assigned(FExchangeTree) and (FExchangeTree.Count > 0) then begin
       //Got something to write
       s.WriteToken(tkBeginExchangeRates);
       try
         // Write them all out...
         FExchangeTree.Iterate(WriteExchangeRates, True, @S);
       finally
         s.WriteToken(tkEndSection);
       end;
     end;
  finally
    S.WriteToken(tkEndSection);
  end;
end;

procedure TExchangeSource.SetAuditInfo(P1, P2: pExchange_Rates_Header_Rec;
  var AAuditInfo: TAuditInfo);
var
  i: integer;
begin
  AAuditInfo.AuditAction := aaNone;
  AAuditInfo.AuditParentID := 0;
  AAuditInfo.AuditOtherInfo := Format('%s=%s', ['RecordType','Currencies']);
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.ehAudit_Record_ID;
  end else if Assigned(P2) and (P2^.ehAudit_Record_ID = P1^.ehAudit_Record_ID) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.ehAudit_Record_ID;
    if Exchange_Rates_Header_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then begin
      //Always set the currency types to match the ISO codes
      for i := Low(P1^.ehCur_Type) to High(P1^.ehCur_Type) do
        pExchange_Rates_Header_Rec(AAuditInfo.AuditRecord)^.ehCur_Type[i] := P1^.ehCur_Type[i];
      AAuditInfo.AuditAction := aaChange;
    end;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.ehAudit_Record_ID;
    P1.ehAudit_Record_ID := AAuditInfo.AuditRecordID;
    P1.ehRecord_Type := tkBegin_Exchange_Rates_Header;
    P1.ehEOR := tkEnd_Exchange_Rates_Header;
    MCEHIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_Exchange_Rates_Header_Rec(P1, AAuditInfo.AuditRecord);
  end;
end;

procedure TExchangeSource.SetAuditTrialID(const Value: integer);
begin
  FHeader.ehAudit_Record_ID := Value;
end;

procedure TExchangeSource.SetFileVersion(const Value: integer);
begin
  FHeader.ehFile_Version := Value;
end;

type
   RemapArray = array[1..2] of integer;

function SwapRates(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  Data : RemapArray;
  Keep: Double;
begin
  Data := RemapArray(OtherData^);
  with  TExchangeRecord(Node.Data) do begin
     Keep := Rates[Data[1]];
     Rates[Data[1]] := Rates[Data[2]];
     Rates[Data[2]] := Keep;
  end;
  Result := True;
end;

function InsertRates(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  Data: RemapArray;
  NewRates: RateArray;
  I: Integer;
begin
  Data := RemapArray(OtherData^);
  SetLength(NewRates, Data[2]);
  for I := 1 to Data[2] do
    if I < Data[1] then
      NewRates[I-1] :=  TExchangeRecord(Node.Data).Rates[I]
    else if I = Data[1] then
      NewRates[I-1] := 0.0
    else
      NewRates[I-1] :=  TExchangeRecord(Node.Data).Rates[I];
  TExchangeRecord(Node.Data).FRates := Copy( NewRates);
  NewRates := nil;
  Result := True;
end;

procedure TExchangeSource.MapToHeader(NewHeader: TExchange_Rates_Header_Rec);
var
   C: Integer;
   Data: RemapArray;
   {OldWidth,} NewWidth: integer;
begin
   if Assigned(FExchangeTree) then begin
     // OldWidth := GetHeaderWidth(FHeader);
      NewWidth := GetHeaderWidth(NewHeader);
      for C := low(NewHeader.ehISO_Codes) to
            low(NewHeader.ehISO_Codes) + NewWidth do begin
         Data[1] := C;
         Data[2] := GetISOIndex(NewHeader.ehISO_Codes[C],FHeader);
         if Data[2] > 0 then begin
            // SwapColumn
            if Data[1] <> Data[2] then
               FExchangeTree.Iterate(SwapRates, True, @Data);
         end else begin
            Data[2] := Width + 1;
            FExchangeTree.Iterate(InsertRates, True, @Data);
         end;
      end;
   end;
   FHeader.ehISO_Codes := NewHeader.ehISO_Codes;
   FHeader.ehCur_Type := NewHeader.ehCur_Type;
end;


{ TExchangeRateList }

function TExchangeRateList.Compare(Item1, Item2: pointer): integer;
begin
   Result := CompUtils.compare(TExchangeSource(Item1^).FHeader.ehLRN, TExchangeSource(Item2^).FHeader.ehLRN);
end;

constructor TExchangeRateList.Create;
begin
   inherited create;

   FLastAuditRecordID := 0;
   FAuditManager := TExchangeRateAuditManager.Create(Self);
   FAuditTable := TAuditTable.Create(FAuditManager);
   FExchangeRateListCopy := nil;
end;

destructor TExchangeRateList.Destroy;
begin
  //Audit table
  FreeAndNil(FAuditTable);
  FreeAndNil(FAuditManager);

  inherited;
end;

function AddAuditIDs(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  ER : TExchangeRecord;
  ExchangeRateList: TExchangeRateList;
begin
  ExchangeRateList := TExchangeRateList(OtherData^);
  ER := TExchangeRecord(Node.Data);
  if (ER.AuditID = 0) then
    ER.AuditID := ExchangeRateList.NextAuditRecordID;
  Result := True;
end;

procedure TExchangeRateList.DoAudit(AAuditType: TAuditType;
  AExchangeRateListCopy: TExchangeRateList);
var
  i: integer;
  ExchangeRateSource, ExchangeRateSourceCopy: TExchangeSource;
begin
  //Audit each exchange source
  for i := 0 to Pred(ItemCount) do begin
    ExchangeRateSource := ExchangeSource(i);
    ExchangeRateSourceCopy := AExchangeRateListCopy.ExchangeSource(i);

    //Because we are comparing exchange rates by data, not audit ID, we can add
    //audit ID's here.
    ExchangeRateSource.ExchangeTree.Iterate(AddAuditIDs, True, @Self);
    
    //Audit exchage rates
    ExchangeRateSource.DoAudit(AAuditType, ExchangeRateSourceCopy, FAuditManager, AuditTable);
  end;
end;

procedure TExchangeRateList.ExchangeRateCopyReload(var S: TIOStream);
begin
  //Reload exchange rate copy DB
  FreeAndNil(FExchangeRateListCopy); //Delete current copy
  S.Seek(Sizeof(LongInt), soFromBeginning);
  FLoading := True;
  try
    ExchangeRateListCopy.LoadFromStream(S);
  finally
    FLoading := False;
  end;
end;

procedure TExchangeRateList.ExchangeRateCopyReset;
var
  S: TIOStream;
  CRC: longword;
begin
  //This should only be done after an exchange rates db upgrade
  //so that existing data is not audited.
  S := TIOStream.Create;
  try
    S.Write(CRC, SizeOf(CRC));
    Self.SaveToStream(S);
    ExchangeRateCopyReload(S);
  finally
    S.Free;
  end;
end;

function TExchangeRateList.ExchangeSource(Index: Integer): TExchangeSource;
begin
   Result := TExchangeSource(Items[Index]);
end;

function TExchangeRateList.FindSource(const Value: string): TExchangeSource;
var I: Integer;
begin
  for I := First to Last do
     if SameText( ExchangeSource(I).FHeader.ehName, Value) then begin
        Result := ExchangeSource(I);
        Exit;
     end;
  Result := nil;
end;

procedure TExchangeRateList.FreeItem(Item: Pointer);
begin
   FreeAndNil(TExchangeSource(Item));
end;

function TExchangeRateList.GetExchangeRateListCopy: TExchangeRateList;
var
  i: integer;
  ExchangeSource, ExchangeSourceCopy: TExchangeSource;
  Header, HeaderCopy: TExchange_Rates_Header_Rec;
begin
  if not Assigned(FExchangeRateListCopy) then begin
    FExchangeRateListCopy := TExchangeRateList.Create;
    if not FLoading then begin
      //Make header the same (no auditing of exchange source at the moment
      //because there is only one)
      for i := 0 to ItemCount - 1 do begin
        ExchangeSource := TExchangeSource(Items[i]);
        ExchangeSourceCopy := FExchangeRateListCopy.GetSource(ExchangeSource.FHeader.ehName);

        //GetSource increments the Audit ID, but the ExchangeSourceCopy is
        //not saved, so we have to decrement it
        Dec(FLastAuditRecordID);

        Header := ExchangeSource.Header;
        Header.ehRecord_Type := tkBegin_Exchange_Rates_Header;
        Header.ehEOR := tkEnd_Exchange_Rates_Header;
        HeaderCopy := ExchangeSourceCopy.Header;
        HeaderCopy.ehRecord_Type := tkBegin_Exchange_Rates_Header;
        HeaderCopy.ehEOR := tkEnd_Exchange_Rates_Header;
        Copy_Exchange_Rates_Header_Rec(@Header, @HeaderCopy);
      end;
    end;
  end;
  Result := FExchangeRateListCopy;
end;

function TExchangeRateList.GetSource(const Value: string): TExchangeSource;
begin
   Result := FindSource(Value);
   if not Assigned(Result) then begin
      Result := TExchangeSource.Create;
      Result.FHeader.ehLRN := ItemCount;
      Result.FHeader.ehName := Value;
      Result.FHeader.ehAudit_Record_ID := NextAuditRecordID;
      Self.Insert(Result);
   end;
end;

function TExchangeRateList.GiveMeSource(const Value: string): TExchangeSource;
begin
   Result := FindSource(Value);
   if Assigned(Result) then begin
      Self.Delete(Result);
   end else begin
      Result := TExchangeSource.Create;
      Result.FHeader.ehLRN := 0;
      Result.FHeader.ehName := Value;
   end;
end;

procedure TExchangeRateList.LoadFromStream(var S: TIOStream);
var
   Token: Byte;
   msg: string;
begin
  FLoading := True;
  try
    Token := S.ReadToken;
    while (Token <> tkEndSection) do begin
      case token of
         tkLastAuditRecordID: FLastAuditRecordID := S.ReadIntegerValue;
         tkBeginExchangeRateHeader: ;
         tkBeginExchangeRateList:; // In the Client file ill already be past this
                                   // But in the file version, it will be here..
         tkBeginExchangeRateSource: begin
            Insert(TExchangeSource.Create(S));
         end;
         tkBeginSystem_Audit_Trail_List  : FAuditTable.LoadFromStream(S);

         else begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ 'TExchangeRateList.LoadFromStream', Token ] );
            LogUtil.LogMsg(lmError, UNIT_NAME, Msg );
            raise ETokenException.CreateFmt( '%s - %s', [ UNIT_NAME, Msg ] );
         end;
      end;
      Token := S.ReadToken;
    end;
  finally
    FLoading := False;
  end;
end;

procedure TExchangeRateList.SaveToStream(var S: TIOStream);
var
  I: Integer;
begin
  // Write the exchange rates
  if ItemCount > 0 then begin
    S.WriteToken(tkBeginExchangeRateList);
    //Write last audit ID
    S.WriteIntegerValue(tkLastAuditRecordID, FLastAuditRecordID);
    for I := First to Last do begin
      ExchangeSource(I).FHeader.ehLRN := I;
      S.WriteToken(tkBeginExchangeRateSource);
      ExchangeSource(I).SaveToStream(S);
      fAuditTable.SaveToStream( S );
      S.WriteToken(tkEndSection);
    end;
    S.WriteToken(tkEndSection);
  end;
end;


function TExchangeRateList.Lock: Boolean;
begin
   Assert(not FLocked, 'Exchange Rates already locked');
   FLocked := LockUtils.ObtainLock(ltExchangeRates,PRACINI_TicksToWaitForAdmin div 1000);
   Result := FLocked;
end;

function TExchangeRateList.LockAndLoad(const KeepLock: Boolean): Boolean;
const
  THIS_METHOD_NAME = 'TExchangeRateList.LockAndLoad';
begin
  if DEBUG_ME then
     LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Begins');

  if Lock then begin

     ReadFromFile(DataDir + EXCHANGE_RATE_FILENAME);
     if not KeepLock then
        UnLock;

     Result := True;
  end else
     Result := False;

  if DEBUG_ME then
     LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Ends');
end;

function TExchangeRateList.MergeSource(Value: TExchangeSource): TExchangeSource;
var I: Integer;
begin
   Result := GetSource(Value.Header.ehName);
   // Should do more but we just fudge for now..
   if Assigned(Result) then begin
      I := indexof(result);
      FList[I] := Value;
      Value.FHeader.ehLRN := I;
   end;
end;

function TExchangeRateList.NextAuditRecordID: integer;
begin
  Inc(FLastAuditRecordID);
  Result := FLastAuditRecordID;
end;

procedure TExchangeRateList.ReadFromFile(Filename: string);
var
  S: TIOStream;
  CRC: LongInt;
begin
  if BKFileExists(FileName) then begin
     S := TIOStream.Create;
     try
        S.LoadFromFile(Filename);
        CheckEmbeddedCRC(S);
        S.Position := 0;
        S.Read(CRC, Sizeof(LongInt));

        LoadFromStream(S);

        //Load audit copy
        ExchangeRateCopyReload(S);
     finally
       S.Free;
     end;

  end;
end;

function TExchangeRateList.Save: Boolean;
const
  THIS_METHOD_NAME = 'TExchangeRateList.Save';
begin
  if DEBUG_ME then
     LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Begins');

  // Assert locked ??
  SaveToFile(DataDir + EXCHANGE_RATE_FILENAME);
  Result := UnLock;


  if DEBUG_ME then
     LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Ends');
end;

procedure TExchangeRateList.SaveToFile(Filename: string);
var
  S: TIOStream;
  L: LongInt;
begin
  //Delete old file
  if BKFileExists(Filename) then
     SysUtils.DeleteFile(Filename);
  //Write out new List
  S := TIOStream.Create;
  try
    //*** Flag Audit ***
    FAuditManager.FlagAudit(atExchangeRates);
    FAuditManager.DoAudit;

    L := 0;
    S.Write(L, Sizeof(LongInt)); //Leave space for the CRC

    SaveToStream(S);

    EmbedCRC(S);

    S.SaveToFile(Filename);

    //Load audit copy
    ExchangeRateCopyReload(S);
  finally
    S.Free;
  end;
end;

function TExchangeRateList.Unlock: Boolean;
begin
   Assert(FLocked, 'Exchange Rates not locked');
   FLocked := not LockUtils.ReleaseLock(ltExchangeRates);
   Result := FLocked;
end;

{ TExchangeRecord }

constructor TExchangeRecord.Create(Fromrec: pExchange_Rate_Rec; Width: Integer);
begin
  inherited Create;
  SetLength(FRates,Width);
  loadFromExchange_Rate_Rec(FromRec);
end;

procedure TExchangeRecord.Assign(Source: TPersistent);
var
  i: integer;
begin
  SetLength(FRates, High(TExchangeRecord(Source).FRates) + 1);
  for i := Low(TExchangeRecord(Source).FRates) to High(TExchangeRecord(Source).FRates) + 1 do
    Rates[i]  := TExchangeRecord(Source).Rates[i];
  Date   := TExchangeRecord(Source).Date;
  Locked := TExchangeRecord(Source).Locked;
end;

constructor TExchangeRecord.Create(ForDate: TstDate; Width: Integer);
begin
  inherited Create;
  SetLength(FRates,Width);
  FDate := ForDate;
  FLocked := False;
end;

destructor TExchangeRecord.Destroy;
begin
  SetLength(FRates,0);
  inherited;
end;

function TExchangeRecord.GetRates(Index: Integer): Double;
begin
   // The index actually Starts at 1;
   // FRates starts at 0
   dec(index);
   if (Index >=0)
   and (Index <= High(FRates)) then
      Result := FRates[Index]
   else
      Result := 0;
end;

function TExchangeRecord.Getwidth: integer;
begin
   Result := Length(FRates);
end;

procedure TExchangeRecord.loadFromExchange_Rate_Rec(Value: pExchange_Rate_Rec);
var I: Integer;
begin
   AuditID := Value.erAudit_Record_ID;
   Date := Value.erApplies_Until;
   Locked := Value.erLocked;
   for I := low(FRates) to High(FRates) do
      FRates[I] := Value.erRate[Succ(I)];
end;

procedure TExchangeRecord.SaveToExchange_Rate_Rec(Value: pExchange_Rate_Rec);
var I: Integer;
begin
   FillChar( Value^, Exchange_Rate_Rec_Size, 0);

   // Set the required Tokens
   Value.erRecord_Type := tkBegin_Exchange_Rate;
   Value.erEOR := tkEnd_Exchange_Rate;

   for I := low(FRates) to High(FRates) do
      Value.erRate[Succ(i)] := FRates[I];

   Value.erApplies_Until := Date;
   Value.erLocked := Locked;
   Value.erAudit_Record_ID := AuditID;
end;

procedure TExchangeRecord.SetAuditID(const Value: integer);
begin
  FAuditID := Value;
end;

procedure TExchangeRecord.SetDate(const Value: TstDate);
begin
  FDate := Value;
end;

procedure TExchangeRecord.SetLocked(const Value: Boolean);
begin
  FLocked := Value;
end;

procedure TExchangeRecord.SetRates(index: Integer; const Value: Double);
begin
  // The index actually Starts at 1;
   dec(index);
   if (Index >=0)
   and (Index <= High(FRates)) then
      FRates[Index] := Value;
end;

initialization
   DEBUG_ME := DebugUnit(UNIT_NAME);
finalization
end.
