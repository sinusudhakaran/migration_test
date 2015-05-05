unit saObj32;

interface

uses
  BKDEFS,
  IOSTREAM,
  BKsaIO,
  TOKENS,
  SysUtils,
  LogUtil,
  BKDbExcept;

type
  //----------------------------------------------------------------------------
  TSuggested_Account = class
  public
    saFields : TSuggested_Account_Rec;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  GetAs_pRec: pSuggested_Account_Rec;
    property  As_pRec: pSuggested_Account_Rec read GetAs_pRec;
  end;


implementation

const
   UnitName = 'saObj32';
   DebugMe: boolean = false;


{ ------------------------------------------------------------------------------
  TRecommended_Mem
------------------------------------------------------------------------------ }
constructor TSuggested_Account.Create;
begin
  inherited;

  FillChar(saFields, SizeOf(saFields), 0);
  with saFields do
  begin
    saRecord_Type := tkBegin_Suggested_Account;
    saEOR := tkEnd_Suggested_Account;
  end;
end;

{------------------------------------------------------------------------------}
destructor TSuggested_Account.Destroy;
begin
  Free_Suggested_Account_Rec_Dynamic_Fields(saFields);

  inherited;
end;

{------------------------------------------------------------------------------}
procedure TSuggested_Account.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TRecommended_Mem.SaveToFile';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Write_Suggested_Account_Rec(saFields, S);
  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
procedure TSuggested_Account.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TRecommended_Mem.LoadFromFile';
var
  Token: byte;
  Msg: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := tkBegin_Suggested_Account;
  While (Token <> tkEndSection) do
  Begin
    if (Token <> tkBegin_Suggested_Account) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    Read_Suggested_Account_Rec(saFields, S);

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
function TSuggested_Account.GetAs_pRec: pSuggested_Account_Rec;
begin
  result := @saFields;
end;

{------------------------------------------------------------------------------}
initialization
  DebugMe := DebugUnit(UnitName);


end.
