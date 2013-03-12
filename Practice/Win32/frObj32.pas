unit frObj32;

interface

uses
  BKDEFS, IOSTREAM, BKfrIO, TOKENS, SysUtils, LogUtil, BKDbExcept;
  
type
  TFinalized_Exchange_Rate = class
  public
    frFields: tFinalized_Exchange_Rate_Rec;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);
  end;
  
implementation

const
   UnitName = 'frObj32';
   DebugMe: boolean = false;
   
{ TFinalized_Exchange_Rate }

constructor TFinalized_Exchange_Rate.Create;
begin
  inherited;

  FillChar(frFields, SizeOf(frFields), 0);
  With frFields do
  Begin
    frRecord_Type := tkBegin_Finalized_Exchange_Rate;
    frEOR := tkEnd_Finalized_Exchange_Rate;
  end;
end;

destructor TFinalized_Exchange_Rate.Destroy;
begin
  inherited;
end;

procedure TFinalized_Exchange_Rate.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TFinalized_Exchange_Rate.LoadFromFile';
var
  Token: byte;
  Msg: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := tkBegin_Finalized_Exchange_Rate;
  While (Token <> tkEndSection) do
  Begin
    if (Token <> tkBegin_Finalized_Exchange_Rate) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    Read_Finalized_Exchange_Rate_Rec(frFields, S);

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

procedure TFinalized_Exchange_Rate.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TFinalized_Exchange_Rate.SaveToFile';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Write_Finalized_Exchange_Rate_Rec(frFields, S);
  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
initialization
  DebugMe := DebugUnit(UnitName);
end.
