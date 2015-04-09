unit tsObj32;

interface

uses
  BKDEFS,
  IOSTREAM,
  BKtsIO,
  TOKENS,
  SysUtils,
  LogUtil,
  BKDbExcept;

type
  //----------------------------------------------------------------------------
  TTran_Suggested_Link = class
  public
    tsFields : TTran_Suggested_Link_Rec;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  GetAs_pRec: pTran_Suggested_Link_Rec;
    property  As_pRec: pTran_Suggested_Link_Rec read GetAs_pRec;
  end;


implementation

const
   UnitName = 'smObj32';
   DebugMe: boolean = false;


{ ------------------------------------------------------------------------------
  TRecommended_Mem
------------------------------------------------------------------------------ }
constructor TTran_Suggested_Link.Create;
begin
  inherited;

  FillChar(tsFields, SizeOf(tsFields), 0);
  with tsFields do
  begin
    tsRecord_Type := tkBegin_Tran_Suggested_Link;
    tsEOR := tkEnd_Tran_Suggested_Link;
  end;
end;

{------------------------------------------------------------------------------}
destructor TTran_Suggested_Link.Destroy;
begin
  Free_Tran_Suggested_Link_Rec_Dynamic_Fields(tsFields);

  inherited;
end;

{------------------------------------------------------------------------------}
procedure TTran_Suggested_Link.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TRecommended_Mem.SaveToFile';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Write_Tran_Suggested_Link_Rec(tsFields, S);
  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
procedure TTran_Suggested_Link.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TRecommended_Mem.LoadFromFile';
var
  Token: byte;
  Msg: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := tkBegin_Tran_Suggested_Link;
  While (Token <> tkEndSection) do
  Begin
    if (Token <> tkBegin_Tran_Suggested_Link) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    Read_Tran_Suggested_Link_Rec(tsFields, S);

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
function TTran_Suggested_Link.GetAs_pRec: pTran_Suggested_Link_Rec;
begin
  result := @tsFields;
end;

{------------------------------------------------------------------------------}
initialization
  DebugMe := DebugUnit(UnitName);


end.
