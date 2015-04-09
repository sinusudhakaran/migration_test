unit smObj32;

interface

uses
  BKDEFS,
  IOSTREAM,
  BKsmIO,
  TOKENS,
  SysUtils,
  LogUtil,
  BKDbExcept;

type
  //----------------------------------------------------------------------------
  TSuggested_Mem = class
  public
    smFields : TSuggested_Mem_Rec;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  GetAs_pRec: pSuggested_Mem_Rec;
    property  As_pRec: pSuggested_Mem_Rec read GetAs_pRec;
  end;


implementation

const
   UnitName = 'smObj32';
   DebugMe: boolean = false;


{ ------------------------------------------------------------------------------
  TRecommended_Mem
------------------------------------------------------------------------------ }
constructor TSuggested_Mem.Create;
begin
  inherited;

  FillChar(smFields, SizeOf(smFields), 0);
  with smFields do
  begin
    smRecord_Type := tkBegin_Suggested_Mem;
    smEOR := tkEnd_Suggested_Mem;
  end;
end;

{------------------------------------------------------------------------------}
destructor TSuggested_Mem.Destroy;
begin
  Free_Suggested_Mem_Rec_Dynamic_Fields(smFields);

  inherited;
end;

{------------------------------------------------------------------------------}
procedure TSuggested_Mem.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TRecommended_Mem.SaveToFile';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Write_Suggested_Mem_Rec(smFields, S);
  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
procedure TSuggested_Mem.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TRecommended_Mem.LoadFromFile';
var
  Token: byte;
  Msg: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := tkBegin_Suggested_Mem;
  While (Token <> tkEndSection) do
  Begin
    if (Token <> tkBegin_Suggested_Mem) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    Read_Suggested_Mem_Rec(smFields, S);

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
function TSuggested_Mem.GetAs_pRec: pSuggested_Mem_Rec;
begin
  result := @smFields;
end;

{------------------------------------------------------------------------------}
initialization
  DebugMe := DebugUnit(UnitName);


end.
