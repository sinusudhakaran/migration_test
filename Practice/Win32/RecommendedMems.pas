unit RecommendedMems;

interface

uses
  IOStream,
  BKutIO,
  BKcpIO,
  utList32,
  cpObj32,
  cmList32,
  rmList32,
  Tokens;

type
  TRecommended_Mems = class(TObject)
  private
    fUnscanned: TUnscanned_Transaction_List;
    fCandidate: TCandidate_Mem_Processing;
    fCandidates: TCandidate_Mem_List;
    fRecommended: TRecommended_Mem_List;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    property  Unscanned: TUnscanned_Transaction_List read fUnscanned;
    property  Candidate: TCandidate_Mem_Processing read fCandidate;
    property  Candidates: TCandidate_Mem_List read fCandidates;
    property  Recommended: TRecommended_Mem_List read fRecommended;
  end;

implementation

uses
  SysUtils,
  BKDbExcept;

const
  UnitName = 'RecommendedMems';
  DebugMe: boolean = false;{ TSomeClass }

constructor TRecommended_Mems.Create;
begin
  fUnscanned := TUnscanned_Transaction_List.Create;
  fCandidate := TCandidate_Mem_Processing.Create;
  fCandidates := TCandidate_Mem_List.Create;
  fRecommended := TRecommended_Mem_List.Create;
end;

destructor TRecommended_Mems.Destroy;
begin
  FreeAndNil(fUnscanned);
  FreeAndNil(fCandidate);
  FreeAndNil(fCandidates);
  FreeAndNil(fRecommended);

  inherited;
end;

procedure TRecommended_Mems.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TRecommended_Mems.LoadFromStream';
var
  Token : byte;
  Msg   : String;
begin
  Token := s.ReadToken;

  while (Token <> tkEndSection) do
  begin
    case Token of
      tkBeginUnscanned_Transaction_List : fUnscanned.LoadFromFile(S);
      tkBegin_Candidate_Mem_Processing  : fCandidate.LoadFromFile(S);
      tkBeginCandidate_Mem_List         : fCandidates.LoadFromFile(S);
      tkBeginRecommended_Mem_List       : fRecommended.LoadFromFile(S);
    else
      begin { Should never happen }
        Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
        raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
      end;
    end;

    Token := S.ReadToken;
  end;
end;

procedure TRecommended_Mems.SaveToFile(var S: TIOStream);
begin
  S.WriteToken(tkBeginRecommended_Mems);

  fUnscanned.SaveToFile(S);
  fCandidate.SaveToFile(S);
  fCandidates.SaveToFile(S);
  fRecommended.SaveToFile(S);

  S.WriteToken(tkEndSection);
end;

end.