unit rmObj32;

interface

uses
  BKDEFS, IOSTREAM, BKrmIO, TOKENS, SysUtils, LogUtil, BKDbExcept;

type
  { ----------------------------------------------------------------------------
    TRecommended_Mem
  ---------------------------------------------------------------------------- }
  TRecommended_Mem = class
  public
    rmFields: tRecommended_Mem_Rec;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  GetAs_pRec: pRecommended_Mem_Rec;
    property  As_pRec: pRecommended_Mem_Rec read GetAs_pRec;
  end;


implementation

const
   UnitName = 'rmObj32';
   DebugMe: boolean = false;


{ ------------------------------------------------------------------------------
  TRecommended_Mem
------------------------------------------------------------------------------ }
constructor TRecommended_Mem.Create;
begin
  inherited;

  FillChar(rmFields, SizeOf(rmFields), 0);
  with rmFields do
  begin
    rmRecord_Type := tkBegin_Recommended_Mem;
    rmEOR := tkEnd_Recommended_Mem;
  end;
end;

{------------------------------------------------------------------------------}
destructor TRecommended_Mem.Destroy;
begin
  Free_Recommended_Mem_Rec_Dynamic_Fields(rmFields);

  inherited;
end;

{------------------------------------------------------------------------------}
procedure TRecommended_Mem.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TRecommended_Mem.SaveToFile';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Write_Recommended_Mem_Rec(rmFields, S);
  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
procedure TRecommended_Mem.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TRecommended_Mem.LoadFromFile';
var
  Token: byte;
  Msg: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := tkBegin_Recommended_Mem;
  While (Token <> tkEndSection) do
  Begin
    if (Token <> tkBegin_Recommended_Mem) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    Read_Recommended_Mem_Rec(rmFields, S);

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
function TRecommended_Mem.GetAs_pRec: pRecommended_Mem_Rec;
begin
  result := @rmFields;
end;

{------------------------------------------------------------------------------}
initialization
  DebugMe := DebugUnit(UnitName);


end.
