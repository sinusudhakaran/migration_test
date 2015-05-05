unit spObj32;

interface

uses
  BKDEFS,
  IOSTREAM,
  BKspIO,
  TOKENS,
  SysUtils,
  LogUtil,
  BKDbExcept;

type
  //----------------------------------------------------------------------------
  TSuggested_Phrase = class
  public
    spFields : TSuggested_Phrase_Rec;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  GetAs_pRec: pSuggested_Phrase_Rec;
    property  As_pRec: pSuggested_Phrase_Rec read GetAs_pRec;
  end;


implementation

const
   UnitName = 'spObj32';
   DebugMe: boolean = false;


{ ------------------------------------------------------------------------------
  TRecommended_Mem
------------------------------------------------------------------------------ }
constructor TSuggested_Phrase.Create;
begin
  inherited;

  FillChar(spFields, SizeOf(spFields), 0);
  with spFields do
  begin
    spRecord_Type := tkBegin_Suggested_Phrase;
    spEOR := tkEnd_Suggested_Phrase;
  end;
end;

{------------------------------------------------------------------------------}
destructor TSuggested_Phrase.Destroy;
begin
  Free_Suggested_Phrase_Rec_Dynamic_Fields(spFields);

  inherited;
end;

{------------------------------------------------------------------------------}
procedure TSuggested_Phrase.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TRecommended_Mem.SaveToFile';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Write_Suggested_Phrase_Rec(spFields, S);
  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
procedure TSuggested_Phrase.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TRecommended_Mem.LoadFromFile';
var
  Token: byte;
  Msg: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := tkBegin_Suggested_Phrase;
  While (Token <> tkEndSection) do
  Begin
    if (Token <> tkBegin_Suggested_Phrase) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    Read_Suggested_Phrase_Rec(spFields, S);

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
function TSuggested_Phrase.GetAs_pRec: pSuggested_Phrase_Rec;
begin
  result := @spFields;
end;

{------------------------------------------------------------------------------}
initialization
  DebugMe := DebugUnit(UnitName);


end.
