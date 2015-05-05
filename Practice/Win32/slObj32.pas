unit slObj32;

interface

uses
  BKDEFS,
  IOSTREAM,
  BKslIO,
  TOKENS,
  SysUtils,
  LogUtil,
  BKDbExcept;

type
  //----------------------------------------------------------------------------
  TSuggested_Account_Link = class
  public
    slFields : TSuggested_Account_Link_Rec;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  GetAs_pRec: pSuggested_Account_Link_Rec;
    property  As_pRec: pSuggested_Account_Link_Rec read GetAs_pRec;
  end;


implementation

const
   UnitName = 'slObj32';
   DebugMe: boolean = false;


{ ------------------------------------------------------------------------------
  TRecommended_Mem
------------------------------------------------------------------------------ }
constructor TSuggested_Account_Link.Create;
begin
  inherited;

  FillChar(slFields, SizeOf(slFields), 0);
  with slFields do
  begin
    slRecord_Type := tkBegin_Suggested_Account_Link;
    slEOR := tkEnd_Suggested_Account_Link;
  end;
end;

{------------------------------------------------------------------------------}
destructor TSuggested_Account_Link.Destroy;
begin
  Free_Suggested_Account_Link_Rec_Dynamic_Fields(slFields);

  inherited;
end;

{------------------------------------------------------------------------------}
procedure TSuggested_Account_Link.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TRecommended_Mem.SaveToFile';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Write_Suggested_Account_Link_Rec(slFields, S);
  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
procedure TSuggested_Account_Link.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TRecommended_Mem.LoadFromFile';
var
  Token: byte;
  Msg: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := tkBegin_Suggested_Account_Link;
  While (Token <> tkEndSection) do
  Begin
    if (Token <> tkBegin_Suggested_Account_Link) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    Read_Suggested_Account_Link_Rec(slFields, S);

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
function TSuggested_Account_Link.GetAs_pRec: pSuggested_Account_Link_Rec;
begin
  result := @slFields;
end;

{------------------------------------------------------------------------------}
initialization
  DebugMe := DebugUnit(UnitName);


end.
