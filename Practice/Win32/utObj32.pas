unit utObj32;

interface

uses
  BKDEFS, IOSTREAM, BKutIO, TOKENS, SysUtils, LogUtil, BKDbExcept;

type
  { ----------------------------------------------------------------------------
    TUnscanned_Transaction
  ---------------------------------------------------------------------------- }
  TUnscanned_Transaction = class
  public
    utFields: tUnscanned_Transaction_Rec;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  GetAs_pRec: pUnscanned_Transaction_Rec;
    property  As_pRec: pUnscanned_Transaction_Rec read GetAs_pRec;
  end;


implementation

const
   UnitName = 'utObj32';
   DebugMe: boolean = false;


{ ------------------------------------------------------------------------------
  TUnscanned_Transaction
------------------------------------------------------------------------------ }
constructor TUnscanned_Transaction.Create;
begin
  inherited;

  FillChar(utFields, SizeOf(utFields), 0);
  with utFields do
  begin
    utRecord_Type := tkBegin_Unscanned_Transaction;
    utEOR := tkEnd_Unscanned_Transaction;
  end;
end;

{------------------------------------------------------------------------------}
destructor TUnscanned_Transaction.Destroy;
begin
  Free_Unscanned_Transaction_Rec_Dynamic_Fields(utFields);

  inherited;
end;

{------------------------------------------------------------------------------}
procedure TUnscanned_Transaction.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TUnscanned_Transaction.SaveToFile';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Write_Unscanned_Transaction_Rec(utFields, S);
  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
procedure TUnscanned_Transaction.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TUnscanned_Transaction.LoadFromFile';
var
  Token: byte;
  Msg: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := tkBegin_Unscanned_Transaction;
  While (Token <> tkEndSection) do
  Begin
    if (Token <> tkBegin_Unscanned_Transaction) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    Read_Unscanned_Transaction_Rec(utFields, S);

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
function TUnscanned_Transaction.GetAs_pRec: pUnscanned_Transaction_Rec;
begin
  result := @utFields;
end;

{------------------------------------------------------------------------------}
initialization
  DebugMe := DebugUnit(UnitName);


end.
