unit BlopiClient;

interface

uses
  SysUtils,
  BankLinkOnlineServices;

type
  TBlopiClient = Class
  private
    FClientDetail: ClientDetail;
    FClientNew: TClientNew;
    procedure SetClientDetail(const Value: ClientDetail);
    procedure SetClientNew(const Value: TClientNew);
  public
    constructor create;
    destructor destroy; override;
    function SaveClientDetail: boolean;
    function SaveClientNew: boolean;
    function GetClientDetail(const AClientCode: string): ClientDetail;
    property ClientDetail: ClientDetail read FClientDetail write SetClientDetail;
    property ClientNew: TClientNew read FClientNew write SetClientNew;
  End;

implementation

{ TBlopiClient }

constructor TBlopiClient.create;
begin
  FClientDetail := nil;
  FClientNew := TClientNew.Create;
end;

destructor TBlopiClient.destroy;
begin
  FreeAndNil(FClientDetail);
  FreeAndNil(FClientNew);
  inherited;
end;

function TBlopiClient.GetClientDetail(const AClientCode: string): ClientDetail;
begin
  Result := ProductConfigService.GetClientDetailsWithCode(AClientCode);
end;

function TBlopiClient.SaveClientDetail: boolean;
begin

end;

function TBlopiClient.SaveClientNew: boolean;
begin

end;

procedure TBlopiClient.SetClientDetail(const Value: ClientDetail);
begin
  FClientDetail := Value;
end;

procedure TBlopiClient.SetClientNew(const Value: TClientNew);
begin
  FClientNew := Value;
end;


end.
