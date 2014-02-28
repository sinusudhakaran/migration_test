unit cpObj32;

interface

uses
  BKDEFS, IOSTREAM, BKcpIO, TOKENS, SysUtils, LogUtil, BKDbExcept;

type
  { ----------------------------------------------------------------------------
    TCandidate_Mem_Processing
  ---------------------------------------------------------------------------- }
  TCandidate_Mem_Processing = class
  public
    cpFields: tCandidate_Mem_Processing_Rec;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  GetAs_pRec: pCandidate_Mem_Processing_Rec;
    property  As_pRec: pCandidate_Mem_Processing_Rec read GetAs_pRec;
  end;


implementation

const
   UnitName = 'cpObj32';
   DebugMe: boolean = false;


{ ------------------------------------------------------------------------------
  TCandidate_Mem_Processing
------------------------------------------------------------------------------ }
constructor TCandidate_Mem_Processing.Create;
begin
  inherited;

  FillChar(cpFields, SizeOf(cpFields), 0);
  with cpFields do
  begin
    cpRecord_Type := tkBegin_Candidate_Mem_Processing;
    cpEOR := tkEnd_Candidate_Mem_Processing;
  end;
end;

{------------------------------------------------------------------------------}
destructor TCandidate_Mem_Processing.Destroy;
begin
  Free_Candidate_Mem_Processing_Rec_Dynamic_Fields(cpFields);

  inherited;
end;

{------------------------------------------------------------------------------}
procedure TCandidate_Mem_Processing.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TCandidate_Mem_Processing.SaveToFile';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Write_Candidate_Mem_Processing_Rec(cpFields, S);
  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
procedure TCandidate_Mem_Processing.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TCandidate_Mem_Processing.LoadFromFile';
var
  Token: byte;
  Msg: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := tkBegin_Candidate_Mem_Processing;
  While (Token <> tkEndSection) do
  Begin
    if (Token <> tkBegin_Candidate_Mem_Processing) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    Read_Candidate_Mem_Processing_Rec(cpFields, S);

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
function TCandidate_Mem_Processing.GetAs_pRec: pCandidate_Mem_Processing_Rec;
begin
  result := @cpFields;
end;

{------------------------------------------------------------------------------}
initialization
  DebugMe := DebugUnit(UnitName);


end.
