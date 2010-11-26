unit MatchTransactions;

interface
uses
   trxList32,
   baObj32,
   bkDefs,
   MoneyDef,
   stTree,
   ARCHUTIL32;

type

TTransMatch = (tmNoMatch, tmDate, tmAmount, tmReference, tmAnalysis, tmNarration);

TMatchTrans = class (Tobject)
   Date: Integer;
   Amount: Money;
   Reference: string;
   Analysis: string;
   Narration: string;
   constructor Create(Value: tArchived_Transaction); overload;
   constructor Create(Value: tTransaction_Rec); overload;
   function ToText: string;
end;

TMatchTransactions = class (TObject)
private
   FTransTree: TStTree;
   procedure SetTransTree(const Value: TStTree);
   function GetTransTree: TStTree;
   procedure FillArchiveList(LRN: Integer); overload;
   procedure FillArchiveList(AccountNum: string); overload;
   procedure FillTransList(FromList: tTransaction_List);
   procedure DateCompare(Sender : TObject; Data1, Data2 : Pointer;  var Compare : Integer);
   function Match(Item1, Item2: TMatchTrans): TTransMatch;
   procedure SetAccount(const Value: TBank_Account);

public
   constructor Create;
   destructor Destroy; override;
   property  TransTree: TStTree read GetTransTree write SetTransTree;
   property Account : TBank_Account write SetAccount;
   function FindMatch(Date: integer; Amount: Money; Reference, Analysis, Narration: string):TTransMatch;
end;

implementation

uses
   GenUtils,
   BkDateUtils,
   LogUtil,
   bkConst,
   StBase,
   syDefs,
   Globals,
   sysUtils,
   WinUtils,
   malloc,
   compUtils;

{ TArchiveTransactions }


function ArchiveTranCompare(Item1, Item2: Pointer): Integer;
begin
  Result := Compare(TMatchTrans(Item1).Date, TMatchTrans(Item2).Date);
  if Result <> 0 then
     Exit;

  Result := Compare(TMatchTrans(Item1).Amount, TMatchTrans(Item2).Amount);
  if Result <> 0 then
     Exit;

  Result := Compare(TMatchTrans(Item1).Reference, TMatchTrans(Item2).Reference);
  if Result <> 0 then
     Exit;

  Result := Compare(TMatchTrans(Item1).Analysis, TMatchTrans(Item2).Analysis);
  if Result <> 0 then
     Exit;

  Result := Compare(TMatchTrans(Item1).Narration, TMatchTrans(Item2).Narration);

end;

procedure ArchiveTranFree(Item: Pointer);
begin
    TObject(Item).Free;
end;



constructor TMatchTransactions.Create;
begin
   inherited Create;
   FTransTree := nil;
end;

procedure TMatchTransactions.DateCompare(Sender: TObject; Data1, Data2: Pointer; var Compare: Integer);
begin
  Compare := compUtils.Compare(TMatchTrans(Data1).Date, TMatchTrans(Data2).Date);
end;

destructor TMatchTransactions.Destroy;
begin
  FreeAndNil(FTransTree);
  inherited;
end;


procedure TMatchTransactions.FillArchiveList(LRN: Integer);
Var
   ArchiveName: String;
   ArchiveFile: File of tArchived_Transaction;
   T: tArchived_Transaction;
Begin
   TransTree.Clear;

   ArchiveName := ArchiveFileName( LRN );
   if not BKFileExists(ArchiveName) then
     Exit; // Im done..

   TransTree.OnCompare := nil;
   Assignfile(ArchiveFile,ArchiveName);
   Reset(ArchiveFile);
   try
      while not EOF(ArchiveFile) do begin

         Read( ArchiveFile, T);
         try
            TransTree.Insert(TMatchTrans.Create(T));
         except
            // May already have duplicates...
         end;
      end;
   finally
      CloseFile(ArchiveFile);
   end;
end;

procedure TMatchTransactions.FillTransList(FromList: tTransaction_List);
var T: Integer;
begin
   TransTree.Clear;
   TransTree.OnCompare := nil;
   for T := FromList.First to FromList.Last do
        with FromList.Transaction_At(t)^ do begin
           //look for the first bank entry
           if (txSource = orBank) then
              Exit;
           try
              TransTree.Insert(TMatchTrans.Create(FromList.Transaction_At(t)^));
           except
              // May already have duplicates...
           end;
        end;
     
end;

procedure TMatchTransactions.FillArchiveList(AccountNum: string);
var acc: pSystem_Bank_Account_Rec;
begin
   if AccountNum = '' then
      Exit;

   if not assigned(AdminSystem) then
      Exit;

   acc := AdminSystem.fdSystem_Bank_Account_List.FindCode(AccountNum);
   if not assigned(acc) then
      Exit;

   FillArchiveList(Acc.sbLRN);
end;

function TMatchTransactions.FindMatch(Date: integer; Amount: Money; Reference, Analysis, Narration: string): TTransMatch;
var
  T: TMatchTrans;
  M,N: TStTreeNode;
  res: TTransMatch;
begin
   Result := tmNoMatch;
   T := TMatchTrans.Create;
   try
      T.Date := Date;
      T.Amount := Amount;
      T.Reference := Reference;
      T.Analysis := Analysis;
      T.Narration := Narration;

      TransTree.OnCompare := DateCompare;

      M := TransTree.Find(T);
      // Since we do not use the same Compare, we may land anywhere on the same date
      // Try forward
      N := M;
      while Assigned(N) do begin
         res :=  Match(TMatchTrans(N.Data) ,T);

         //LogUtil.LogMsg(lmDebug,'Match', Format('%d List %s  In %s' ,[ord(res), TMatchTrans(N.Data).ToText, T.ToText]));

         if res > Result then
            Result := res
         else
           if res = tmNoMatch then
               Break;

         N := TransTree.Next(N);
      end;
      
      // Try backward
      N := TransTree.Prev(M);
      while Assigned(N) do begin
         res :=  Match(TMatchTrans(N.Data) ,T);

         //LogUtil.LogMsg(lmDebug,'Match', Format('%d List %s  In %s' ,[ord(res), TMatchTrans(N.Data).ToText, T.ToText]));

         if res > Result then
            Result := res
         else
            if res = tmNoMatch  then
               Break;

         N := TransTree.Prev(N);
      end;

   finally
     T.Free;
   end;

end;

function TMatchTransactions.GetTransTree: TStTree;
begin
   if not Assigned(FTransTree) then begin
      FTransTree := TStTree.Create(TStTreeNode);
      FTransTree.Compare := ArchiveTranCompare;
      FTransTree.DisposeData := ArchiveTranFree;
      FTransTree.OnCompare := nil;
   end;

   Result := FTransTree;
end;

function TMatchTransactions.Match(Item1,Item2: TMatchTrans): TTransMatch;
var cmp: Integer;
begin
  Result := tmNoMatch; // start somewhere

  cmp := Compare(Item1.Date, Item2.Date);
  if cmp <> 0 then
     Exit;

  Result := tmDate; // Dates are the same..
  cmp := Compare(Item1.Amount, Item2.Amount);

  if cmp <> 0 then
     Exit;

  Result := tmAmount; // Amount is the same...
  cmp := Compare(Item1.Reference, Item2.Reference);
  if cmp <> 0 then
     Exit;

  Result := tmReference; // reference is the same

  cmp := Compare(Item1.Analysis, Item2.Analysis);
  if cmp <> 0 then
     Exit;

  Result := tmAnalysis; // analysis is the same

  cmp := Compare(Item1.Narration, Item2.Narration);
  if cmp <> 0 then
     Exit;

  Result := tmNarration; // Narration is the same..
end;

procedure TMatchTransactions.SetAccount(const Value: TBank_Account);
begin
   if Value.IsProvisional then
      FillArchiveList(Value.baFields.baBank_Account_Number)
   else
      FillTransList(Value.baTransaction_List);
end;

procedure TMatchTransactions.SetTransTree(const Value: TStTree);
begin
  FTransTree := Value;
end;



constructor TMatchTrans.Create(Value: tArchived_Transaction);
begin
  inherited Create;
  Date := Value.aDate_Presented;
  Amount := Value.aAmount;
  Reference := Value.aReference;
  Analysis := Value.aAnalysis;
  Narration := Value.aStatement_Details;  //?? Narration...
 
end;

constructor TMatchTrans.Create(Value: tTransaction_Rec);
begin
   inherited Create;
   Date := Value.txDate_Presented;
   Amount := Value.txAmount;
   Reference := Value.txReference;
   Analysis := Value.txAnalysis;
   Narration := Value.txGL_Narration;

end;

function TMatchTrans.ToText: string;
begin
   result := Format('%s %s "%s" "%s" "%s"', [bkDate2Str(Date), Money2Str(Amount), Reference, Analysis, Narration]);
end;

end.
