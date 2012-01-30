unit BlopiClient;

interface

uses
  SysUtils,
  BankLinkOnlineServices;

type
  TBlopiClient = Class
  private
    FClientDetail: TBloClientDetail;
    FClientNew: TBloClientNew;
    FIsEdited: Boolean;
    procedure SetClientDetail(const Value: TBloClientDetail);
    procedure SetClientNew(const Value: TBloClientNew);
    procedure SetIsEdited(const Value: Boolean);
  public
    constructor create;
    destructor destroy; override;
    function SaveClientDetail: boolean;
    function SaveClientNew: boolean;
    function GetClientDetail(const AClientCode: string): TBloClientDetail;
    property ClientDetail: TBloClientDetail read FClientDetail write SetClientDetail;
    property ClientNew: TBloClientNew read FClientNew write SetClientNew;
    property IsEdited: Boolean read FIsEdited write SetIsEdited;
  End;

implementation

{ TBlopiClient }

constructor TBlopiClient.create;
begin
  FClientDetail := nil;
  FClientNew := nil
end;

destructor TBlopiClient.destroy;
begin
  FreeAndNil(FClientDetail);
  FreeAndNil(FClientNew);
  inherited;
end;

function TBlopiClient.GetClientDetail(const AClientCode: string): TBloClientDetail;
begin
  Result := ProductConfigService.GetClientDetailsWithCode(AClientCode);
end;

function TBlopiClient.SaveClientDetail: boolean;
begin

end;

function TBlopiClient.SaveClientNew: boolean;
begin

end;

procedure TBlopiClient.SetClientDetail(const Value: TBloClientDetail);
begin
  FClientDetail := Value;
end;

procedure TBlopiClient.SetClientNew(const Value: TBloClientNew);
begin
  FClientNew := Value;
end;


procedure TBlopiClient.SetIsEdited(const Value: Boolean);
begin
  FIsEdited := Value;
end;

end.
