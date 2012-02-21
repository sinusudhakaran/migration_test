unit BlopiClient;

interface

uses
  SysUtils,
  BankLinkOnlineServices;

type
  TBlopiClient = Class
  private
    FClientDetail: TBloClientReadDetail;
    FClientNew: TBloClientCreate;
    FIsEdited: Boolean;
    procedure SetClientDetail(const Value: TBloClientReadDetail);
    procedure SetClientNew(const Value: TBloClientCreate);
    procedure SetIsEdited(const Value: Boolean);
  public
    constructor create;
    destructor destroy; override;
    function SaveClient(ClientToSave: TBloClientReadDetail = nil): Boolean;
    function GetClientDetail(const AClientCode: string): TBloClientReadDetail;
    property ClientDetail: TBloClientReadDetail read FClientDetail write SetClientDetail;
    property ClientNew: TBloClientCreate read FClientNew write SetClientNew;
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

function TBlopiClient.GetClientDetail(const AClientCode: string): TBloClientReadDetail;
begin
  Result := ProductConfigService.GetClientDetailsWithCode(AClientCode);
end;

function TBlopiClient.SaveClient(ClientToSave: TBloClientReadDetail = nil): Boolean;
begin
  if Assigned(ClientNew) then
  begin
    ProductConfigService.CreateNewClient(ClientNew);
    ProductConfigService.LoadClientList;
    ClientDetail := ProductConfigService.GetClientDetailsWithCode(ClientNew.ClientCode);
    FreeAndNil(FClientNew)
  end else begin
    if IsEdited then
      ProductConfigService.SaveClient(ClientToSave);
  end;
end;

procedure TBlopiClient.SetClientDetail(const Value: TBloClientReadDetail);
begin
  FClientDetail := Value;
end;

procedure TBlopiClient.SetClientNew(const Value: TBloClientCreate);
begin
  FClientNew := Value;
end;


procedure TBlopiClient.SetIsEdited(const Value: Boolean);
begin
  FIsEdited := Value;
end;

end.
