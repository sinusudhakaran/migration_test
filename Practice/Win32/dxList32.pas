unit dxList32;

interface

uses
   classes, bkdefs, ecollect, iostream;

type
   TDeleted_Transaction_List = class(TExtdSortedCollection)
   protected
      procedure FreeItem(Item : Pointer); override;
   private
      FLoading: boolean;
   public
      constructor Create;
      function Compare(Item1,Item2 : Pointer): Integer; override;
      procedure LoadFromFile(var S : TIOStream);
      procedure SaveToFile(var S: TIOStream);
      function  Transaction_At(Index : longint) : pDeleted_Transaction_Rec;
      procedure AddTransaction(Transaction: pTransaction_Rec; const DeletedBy: String);
   end;

procedure Dispose_Deleted_Transaction_Rec(DeletedTransaction: pDeleted_Transaction_Rec);

implementation

uses
   BKdxIO,
   tokens,
   LogUtil,
   malloc,
   SysUtils,
   bkdbExcept,
   StDate;
   
const
   DebugMe: boolean = false;
   UnitName = 'DXLIST32';
   
procedure Dispose_Deleted_Transaction_Rec(DeletedTransaction: pDeleted_Transaction_Rec);
const
  ThisMethodName = 'Dispose_Transaction_Rec';
begin
  if DebugMe then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');
  end;

  if (IsADeleted_Transaction_Rec(DeletedTransaction)) then with DeletedTransaction^ do
  begin
    Free_Deleted_Transaction_Rec_Dynamic_Fields(DeletedTransaction^);
    
    MALLOC.SafeFreeMem(DeletedTransaction, Deleted_Transaction_Rec_Size);
  end;

  if DebugMe then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
  end;
end;

{ TDeleted_Transaction_List }

procedure TDeleted_Transaction_List.AddTransaction(Transaction: pTransaction_Rec; const DeletedBy: String);
var
  DeletedTransaction: pDeleted_Transaction_Rec;
begin
  DeletedTransaction := New_Deleted_Transaction_Rec;

  DeletedTransaction.dxDate_Deleted := CurrentDate;
  DeletedTransaction.dxDeleted_By := DeletedBy;
  DeletedTransaction.dxExternal_GUID := Transaction.txExternal_GUID;
  DeletedTransaction.dxDate_Effective := Transaction.txDate_Effective;
  DeletedTransaction.dxSequence_No := Transaction.txSequence_No;
  DeletedTransaction.dxAmount := Transaction.txAmount;
  DeletedTransaction.dxGST_Amount := Transaction.txGST_Amount;
  DeletedTransaction.dxQuantity := Transaction.txQuantity;
  DeletedTransaction.dxAccount := Transaction.txAccount;
  DeletedTransaction.dxReference := Transaction.txReference;
  DeletedTransaction.dxParticulars := Transaction.txParticulars;
  DeletedTransaction.dxCore_Transaction_ID := Transaction.txCore_Transaction_ID;
  DeletedTransaction.dxCore_Transaction_ID_High := Transaction.txCore_Transaction_ID_High;

  Insert(DeletedTransaction);
end;

function TDeleted_Transaction_List.Compare(Item1, Item2: Pointer): Integer;
begin
  if pDeleted_Transaction_Rec(Item1)^.dxDate_Effective < pDeleted_Transaction_Rec(Item2)^.dxDate_Effective then result := -1 else
  if pDeleted_Transaction_Rec(Item1)^.dxDate_Effective > pDeleted_Transaction_Rec(Item2)^.dxDate_Effective then result := 1 else
  if pDeleted_Transaction_Rec(Item1)^.dxSequence_No    < pDeleted_Transaction_Rec(Item2)^.dxSequence_No then result := -1 else
  if pDeleted_Transaction_Rec(Item1)^.dxSequence_No    > pDeleted_Transaction_Rec(Item2)^.dxSequence_No then result := 1 else
  result := 0;
end;

constructor TDeleted_Transaction_List.Create;
begin

end;

procedure TDeleted_Transaction_List.FreeItem(Item: Pointer);
begin
  Dispose_Deleted_Transaction_Rec(pDeleted_Transaction_Rec(item));
end;

procedure TDeleted_Transaction_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TTransaction_List.LoadFromFile';
var
   Token: Byte;
   pDeletedTransaction: pDeleted_Transaction_Rec;
   Msg: string;
begin
  if DebugMe then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');
  end;

  FLoading := True;
  
  try
    Token := S.ReadToken;

    while (Token <> tkEndSection) do
    begin
      case Token of
        tkBegin_Deleted_Transaction:
        begin
          pDeletedTransaction := New_Deleted_Transaction_Rec;

          Read_Deleted_Transaction_Rec (pDeletedTransaction^, S);

          Insert(pDeletedTransaction);
        end;

        else
        begin { Should never happen }
          Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);

          LogUtil.LogMsg(lmError, UnitName, Msg );

          raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
        end;
      end; { of Case }

      Token := S.ReadToken;
    end;
  finally
    FLoading := False;
  end;

  if DebugMe then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
  end;
end;

procedure TDeleted_Transaction_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TTransaction_List.SaveToFile';
var
   Index: LongInt;
   pDeletedTransaction: pDeleted_Transaction_Rec;
   Count: LongInt;
begin
  if DebugMe then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');
  end;

  Count := 0;

  S.WriteToken(tkBeginDeleted_Transaction_List);

  for Index := 0 to Pred(ItemCount) do
  begin
    pDeletedTransaction := Transaction_At(Index);

    Write_Deleted_Transaction_Rec(pDeletedTransaction^, S);

    Inc(Count);
  end;

  S.WriteToken(tkEndSection);

  if DebugMe then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
    LogUtil.LogMsg(lmDebug, UnitName, Format('%s : %d deleted transactions saved',[ThisMethodName, Count]));
  end;
end;

function TDeleted_Transaction_List.Transaction_At(Index: Integer): pDeleted_Transaction_Rec;
const
  ThisMethodName = 'TDeleted_Transaction_List.Transaction_At';
var
   DeletedTransaction : Pointer;
begin
   if DebugMe then
   begin
     LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');
   end;

   Result := nil;

   DeletedTransaction := At(Index);

   if IsADeleted_Transaction_Rec(DeletedTransaction) then
   begin
      Result := DeletedTransaction;
   end;

   if DebugMe then
   begin
     LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
   end;
end;

initialization
   DebugMe := DebugUnit(UnitName);
   
end.
