unit ExchangeRateList;
//------------------------------------------------------------------------------
//  Title:   Exchange Rate List
//
//  Written: July 2010
//
//  Authors: Andre' Joosten
//
//  Purpose: Creates a binary tree for acessing exchange rates.
//
//  Notes:
//------------------------------------------------------------------------------
interface
uses
  ECollect, stDate, Classes, mcDefs, ioStream, stTree,stBase, sysUtils;

Type
   RateArray = array of Double;

   TExchangeRecord = class(tObject)
   // Record for each date
   // The rates are in a Dinamic array to save memory
   // These rates should be in step with the Header of the Source
   private
     FRates: RateArray;
     function GetRates(index: Integer): Double;
     procedure SetRates(index: Integer; const Value: Double);
     function Getwidth: integer;
   public
     Date: TStdate;
     Locked: Boolean;
     constructor Create(Fromrec: pExchange_Rate_Rec; Width: Integer); overload;
     constructor Create(ForDate: tstDate; Width: Integer); overload;
     destructor Destroy; override;
     procedure loadFromExchange_Rate_Rec(Value: pExchange_Rate_Rec);
     procedure SaveToExchange_Rate_Rec(Value: pExchange_Rate_Rec);
     property Rates [index: Integer]: Double read GetRates write SetRates;
     property Width: integer read Getwidth;
   end;

   PExchangeSource = ^TExchangeSource;
   TExchangeSource = class(TPersistent)
   // A specific Exchange rate source in a list, or just in the Client file as is.
   // Has a BinaryTree to store the records as above
   private
     FHeader: TExchange_Rates_Header_Rec;
     FExchangeTree: TStTree;
     procedure CreateExchangeTree;
     function GetISOIndex(Value: string; FromHeader: TExchange_Rates_Header_Rec): Integer;
     function GetHeaderWidth(Value: TExchange_Rates_Header_Rec): Integer;
     function GetWidth: Integer;
     function GetExchangeTree: TStTree;
   public
     constructor Create; overload;
     constructor Create(var S: TIOStream); overload;

     procedure SaveToStream(var S : TIOStream );
     procedure LoadFromStream(var S : TIOStream );
     procedure MapToHeader(NewHeader: TExchange_Rates_Header_Rec);
     procedure Assign(Source: TPersistent); override;

     property Width: Integer read GetWidth;
     property Header: TExchange_Rates_Header_Rec read FHeader;
     property ExchangeTree: TStTree read GetExchangeTree;
     function GetDateRates(Value: tstDate): TExchangeRecord;
     function Iterate (Action: TIterateFunc; Up: Boolean;
                       OtherData: Pointer): TStTreeNode;
   end;

   TExchangeRateList = class(TExtdSortedCollection)
   private
      CurrentRecord: LongInt;
      FLocked: Boolean;

      function Lock: Boolean;
      procedure SaveToFile(Filename: string);
      procedure ReadFromFile(Filename: string);

   protected
      procedure FreeItem( Item : Pointer ); override;
   public
      constructor Create;
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
   end;

   // So I Can use them in the admin system...
   procedure WriteCurrencyList(var Rec: TExchange_Rates_Header_Rec; var S : TIOStream);
   procedure ReadCurrencyList(var Rec: TExchange_Rates_Header_Rec; var S : TIOStream);


   const // Could make this a Type, but the record cannot handle it direct...
     ct_System = 0;
     ct_Base = 1;
     ct_User = 2;

 function GetExchangeRates(const KeepLock: Boolean = False): TExchangeRateList;

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
  logutil, MALLOC, StStrS, bkdbExcept, bk5Except;

const
   DebugMe : Boolean = FALSE;
   UnitName = 'ExchangeRateList';

   ExchangeRateFilename = 'ExchangeRates.db';


function GetExchangeRates(const KeepLock: Boolean = False): TExchangeRateList;
begin
    Result := TExchangeRateList.Create;
    Result.LockAndLoad(KeepLock);
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
  FillChar(fHeader, Sizeof(FHeader),0);
end;


procedure TExchangeSource.Assign(Source: TPersistent);
begin
   if not assigned(Source) then
      Exit;
   (*   
  // if Source is  TExchange_Rates_Header_Rec then begin
      // Make sure we have the same columns...
   end else ; ///
   *)
end;

constructor TExchangeSource.Create(var S: TIOStream);
begin
   Create;
   LoadFromStream(S);
end;

//******************************************************************************
function ExchangeRecordCompare(Item1, Item2: Pointer): Integer;
begin
  Result := Compare(TExchangeRecord(Item1).Date, TExchangeRecord(Item2).Date);
end;

procedure ExchangeRecordFree(Item: Pointer);
begin
   TObject(Item).Free;
end;
//******************************************************************************


procedure TExchangeSource.CreateExchangeTree;
begin
   FExchangeTree := TStTree.Create(TStTreeNode);
   FExchangeTree.Compare := ExchangeRecordCompare;
   FExchangeTree.DisposeData := ExchangeRecordFree;
end;



function TExchangeSource.GetISOIndex(Value: string; FromHeader: TExchange_Rates_Header_Rec): Integer;
begin
   for Result := low(FromHeader.ehISO_Codes) to High(FromHeader.ehISO_Codes) do
      if SameText(fHeader.ehISO_Codes[Result], Value) then 
         Exit;
         
   Result := 0; // Not in it...
end;

function TExchangeSource.GetWidth: Integer;
begin
   Result := GetHeaderWidth(FHeader);
end;

function TExchangeSource.Iterate(Action: TIterateFunc; Up: Boolean;
  OtherData: Pointer): TStTreeNode;
begin
   Result := nil;
   if Assigned(FExchangeTree) then
      Result := FExchangeTree.Iterate(Action, Up, OtherData);
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

function TExchangeSource.GetExchangeTree: TStTree;
begin
   if not assigned(FExchangeTree) then
      CreateExchangeTree;
   Result := FExchangeTree;
end;

function TExchangeSource.GetHeaderWidth(Value: TExchange_Rates_Header_Rec): Integer;
var C: Integer;
begin
   for C := low(Value.ehISO_Codes) to High(Value.ehISO_Codes) do
      if fHeader.ehISO_Codes[C] = '' then begin
         // The first empty one..
         Result := C - low(Value.ehISO_Codes);
         Exit;
      end;
   Result := High(fHeader.ehISO_Codes) - Low(fHeader.ehISO_Codes);
end;

procedure TExchangeSource.LoadFromStream(var S: TIOStream);
const
  THIS_METHOD_NAME = 'TExchangeSource.LoadFromFile';
var
  Token: Byte;
  Msg: string;

  procedure LoadExchangeRates;
  var Token: Byte;
      Rec: tExchange_Rate_Rec;
      W: Integer;
  begin
     W := Width;
     if W > 0 then
        CreateExchangeTree;

     Token := S.ReadToken;
     while (Token <> tkEndSection) do begin
        case token of
           tkBegin_Exchange_Rate: begin
              Read_Exchange_Rate_Rec(Rec,S);
              if W > 0 then
                 FExchangeTree.Insert(TExchangeRecord.Create(@Rec, Width) );
               end;
               else begin { Should never happen }
                  Msg := Format( '%s : Unknown Token %d', [ 'LoadExchangeRates', Token ] );
                  LogUtil.LogMsg(lmError, UnitName, Msg );
                  raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
               end;
          end;
          Token := S.ReadToken;
      end;

  end;

begin
  FreeAndNil(FExchangeTree);
  Token := S.ReadToken;
  while (Token <> tkEndSection) do begin
     case Token of
        tkBegin_Exchange_Rates_Header: begin
           Read_Exchange_Rates_Header_Rec(fHeader, S);
        end;

        tkBeginExchangeRates: LoadExchangeRates;

        else begin { Should never happen }
           Msg := Format( '%s : Unknown Token %d', [ THIS_METHOD_NAME, Token ] );
           LogUtil.LogMsg(lmError, UnitName, Msg );
           raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
        end;
     end; { of Case }
     Token := S.ReadToken;
  end;

  if fHeader.ehFile_Version <> MC_FILE_VERSION then begin
     // Handle upgrades??
     fHeader.ehFile_Version := MC_FILE_VERSION;
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
var I: Integer;
begin
   // Write The header
   fHeader.ehRecord_Type := tkBegin_Exchange_Rates_Header;
   fHeader.ehEOR := tkEnd_Exchange_Rates_Header;
   fHeader.ehFile_Version := MC_FILE_VERSION;
   Write_Exchange_Rates_Header_Rec (fHeader, S);

   if Assigned(FExchangeTree)
   and (FExchangeTree.Count > 0) then begin
      //Got something to write
      s.WriteToken(tkBeginExchangeRates);
        // Write them all out...
        FExchangeTree.Iterate(WriteExchangeRates, True, @S);
      s.WriteToken(tkEndSection);
   end;
end;



type
   RemapArray = array[1..2] of integer;

function SwapRates(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  Data : RemapArray;
  Keep: Double;
  ExchangeRecord: TExchangeRecord;
begin
  Data := RemapArray(OtherData^);
  ExchangeRecord := TExchangeRecord(Node.Data);
  Keep := ExchangeRecord.Rates[Data[1]];
  ExchangeRecord.Rates[Data[1]] := ExchangeRecord.Rates[Data[2]];
  ExchangeRecord.Rates[Data[2]] := Keep;
  Result := True;
end;

function InsertRates(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  Data: RemapArray;
  NewRates: RateArray;
  I: Integer;
begin
  Data := RemapArray(OtherData^);
  with  TExchangeRecord(Node.Data) do begin
     SetLength(NewRates, Data[2]);
     for I := 0 to Pred(Data[2]) do
       if I < Data[1] then
          NewRates[I] := Rates[I]
       else if I = Data[1] then
          NewRates[I] := 0.0
       else
          NewRates[I] := Rates[I-1];
     FRates := Copy( NewRates);
     NewRates := nil;
  end;
  Result := True;
end;


procedure TExchangeSource.MapToHeader(NewHeader: TExchange_Rates_Header_Rec);
var
   C: Integer;
   Data: RemapArray;
begin
   if Assigned(FExchangeTree) then begin

      for C := low(NewHeader.ehISO_Codes) to
            low(NewHeader.ehISO_Codes) + GetHeaderWidth(NewHeader) do begin
         Data[1] := C;
         Data[2] := GetISOIndex(NewHeader.ehISO_Codes[C],FHeader);
         if Data[2] >= 0 then begin
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
   FreeAndNil(TObject(Item));
end;

function TExchangeRateList.GetSource(const Value: string): TExchangeSource;
begin
   Result := FindSource(Value);
   if not Assigned(Result) then begin
      Result := TExchangeSource.Create;
      Result.FHeader.ehLRN := ItemCount;
      Result.FHeader.ehName := Value;
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
   Token := S.ReadToken;
   while (Token <> tkEndSection) do begin
      case token of
         tkBeginExchangeRateList:; // In the Client file ill already be past this
                                   // But in the file version, it will be here..
         tkBeginExchangeRateSource: begin
            Insert(TExchangeSource.Create(S));
         end;

         else begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ 'TExchangeRateList.LoadFromStream', Token ] );
            LogUtil.LogMsg(lmError, UnitName, Msg );
            raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
         end;
      end;
      Token := S.ReadToken;
   end;
end;

procedure TExchangeRateList.SaveToStream(var S: TIOStream);
var I: Integer;
begin
    if ItemCount > 0 then begin
       S.WriteToken(tkBeginExchangeRateList);
          for I := First to Last do begin
             ExchangeSource(I).FHeader.ehLRN := I;
             S.WriteToken(tkBeginExchangeRateSource);
               ExchangeSource(I).SaveToStream(S);
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
  if DebugMe then
     LogUtil.LogMsg(lmDebug, UnitName, THIS_METHOD_NAME + ' Begins');

  if Lock then begin

     ReadFromFile(DataDir + ExchangeRateFilename);
     if not KeepLock then
        UnLock;

     Result := True;
  end else
     Result := False;


  if DebugMe then
     LogUtil.LogMsg(lmDebug, UnitName, THIS_METHOD_NAME + ' Ends');
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

     finally
       S.Free;
     end;

  end;
end;

function TExchangeRateList.Save: Boolean;
const
  THIS_METHOD_NAME = 'TExchangeRateList.Save';
begin
  if DebugMe then
     LogUtil.LogMsg(lmDebug, UnitName, THIS_METHOD_NAME + ' Begins');

  // Assert locked ??
  SaveToFile(DataDir + ExchangeRateFilename);
  Result := UnLock;


  if DebugMe then
     LogUtil.LogMsg(lmDebug, UnitName, THIS_METHOD_NAME + ' Ends');
end;

procedure TExchangeRateList.SaveToFile(Filename: string);
var
  S: TIOStream;
  L: LongInt;
begin
  //Delete old stats
  if BKFileExists(Filename) then
     SysUtils.DeleteFile(Filename);
  //Write out new List
  S := TIOStream.Create;
  try
    L := 0;
    S.Write(L, Sizeof(LongInt)); //Leave space for the CRC

    SaveToStream(S);

    EmbedCRC(S);

    S.SaveToFile(Filename);
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

constructor TExchangeRecord.Create(ForDate: TstDate; Width: Integer);
begin
  inherited Create;
  SetLength(FRates,Width);
  Date := ForDate;
  Locked := False;
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
   DebugMe := DebugUnit(UnitName);
finalization
end.
