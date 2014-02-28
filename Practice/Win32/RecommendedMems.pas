unit RecommendedMems;

interface

uses
  IOStream,
  BKutIO,
  utList32,
  cpObj32,
  cmList32,
  rmList32;

const
  tkBegin_Recommended_Mems = tkBegin_Unscanned_Transaction;

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
  SysUtils;

{ TSomeClass }

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
begin
  fUnscanned.LoadFromFile(S);
  fCandidate.LoadFromFile(S);
  fCandidates.LoadFromFile(S);
  fRecommended.LoadFromFile(S);
end;

procedure TRecommended_Mems.SaveToFile(var S: TIOStream);
begin
  fUnscanned.SaveToFile(S);
  fCandidate.SaveToFile(S);
  fCandidates.SaveToFile(S);
  fRecommended.SaveToFile(S);
end;

end.
