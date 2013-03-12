unit glObj32;

interface

uses
  BKDEFS, IOSTREAM, BKglIO, TOKENS, SysUtils, LogUtil, BKDbExcept;

type
  { ----------------------------------------------------------------------------
    TExchange_Gain_Loss
  ---------------------------------------------------------------------------- }
  TExchange_Gain_Loss = class
  public
    glFields: tExchange_Gain_Loss_Rec;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  GetAs_pRec: pExchange_Gain_Loss_Rec;
    property  As_pRec: pExchange_Gain_Loss_Rec read GetAs_pRec;
  end;


implementation

const
   UnitName = 'glObj32';
   DebugMe: boolean = false;


{ ------------------------------------------------------------------------------
  TExchange_Gain_Loss
------------------------------------------------------------------------------ }
constructor TExchange_Gain_Loss.Create;
begin
  inherited;

  FillChar(glFields, SizeOf(glFields), 0);
  With glFields do
  Begin
    glRecord_Type := tkBegin_Exchange_Gain_Loss;
    glEOR := tkEnd_Exchange_Gain_Loss;
  end;
end;

{------------------------------------------------------------------------------}
destructor TExchange_Gain_Loss.Destroy;
begin
  Free_Exchange_Gain_Loss_Rec_Dynamic_Fields(glFields);

  inherited;
end;

{------------------------------------------------------------------------------}
procedure TExchange_Gain_Loss.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TExchange_Gain_Loss.SaveToFile';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Write_Exchange_Gain_Loss_Rec(glFields, S);
  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
procedure TExchange_Gain_Loss.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TExchange_Gain_Loss.LoadFromFile';
var
  Token: byte;
  Msg: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := tkBegin_Exchange_Gain_Loss;
  While (Token <> tkEndSection) do
  Begin
    if (Token <> tkBegin_Exchange_Gain_Loss) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    Read_Exchange_Gain_Loss_Rec(glFields, S);

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
function TExchange_Gain_Loss.GetAs_pRec: pExchange_Gain_Loss_Rec;
begin
  result := @glFields;
end;

{------------------------------------------------------------------------------}
initialization
  DebugMe := DebugUnit(UnitName);


end.