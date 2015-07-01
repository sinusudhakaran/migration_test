unit uNPS;

interface


uses
  Classes, uLeanEngageLib, Contnrs, uNPSServer;

type
  TNPSSurvey = class
  private
    FName: String;
    FId: String;
    FUrl: String;
  public
    property Id: String read FId write FId;
    property Name: String read FName write FName;
    property Url: String read FUrl write FUrl;
  end;

  TNPSSurveys = class
  private
    FItems: TObjectList;
    function GetCount: Integer;
    function GetSurvey(Index: Integer): TNPSSurvey;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;

    procedure Add(Survey: TNPSSurvey);

    function SurveyByName(SurveyName: String): TNPSSurvey;

    property Items[Index: Integer]: TNPSSurvey read GetSurvey; default;
    property Count: Integer read GetCount;
  end;

  TLEInitializationThread = class(TThread)
  private
    FOnCompleted: TNotifyEvent;

    FSurvey: TLESurvey;
    FHasSurvey: Boolean;

    FModuleVersion: String;
    FCompanyName: String;
    FIdentityId: String;
    FParentCompanyName: String;
    FModuleId: String;
    FStaffId: String;
    FCountry: String;
    FDBVersion: String;
    FSqlVersion: String;
    FServerKey: String;
    FServerUrl: String;
  protected
    procedure Execute; override;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    property IdentityId: String read FIdentityId write FIdentityId;
    property StaffID: String read FStaffId write FStaffId;
    property Country: String read FCountry write FCountry;
    property CompanyName: String read FCompanyName write FCompanyName;
    property ParentCompanyName: String read FParentCompanyName write FParentCompanyName;
    property ModuleId: String read FModuleId write FModuleId;
    property ModuleVersion: String read FModuleVersion write FModuleVersion;
    property DbVersion: String read FDBVersion write FDBVersion;
    property SqlVersion: String read FSqlVersion write FSqlVersion;
    property ServerKey: String read FServerKey write FServerKey;
    property ServerUrl: String read FServerUrl write FServerUrl;
    property HasSurvey: boolean read fHasSurvey;

    property OnCompleted: TNotifyEvent read FOnCompleted write FOnCompleted;

    procedure GetSurveys(Surveys: TNPSSurveys);
  end;

  TNPSLeanEngage = class
  private
    FModuleVersion: String;
    FCompanyName: String;
    FParentCompanyName: String;
    FCountry: String;
    FDBVersion: String;
    FStaffID: string;
    FModuleId: String;
    FSqlVersion: String;

    FInitializationThread: TLEInitializationThread;

    procedure StartInitializationThread(ServerUrl, ServerKey, IdentityId: String; OnCompleted: TNotifyEvent);
    procedure FreeInitializationThread;
  public
    constructor Create;
    destructor Destroy; override;

    procedure InitializeAsync(ServerUrl, ServerKey, IdentityId: String; OnCompleted: TNotifyEvent = nil);

    procedure GetSurveys(Surveys: TNPSSurveys);
    function GetHasSurvey : boolean;

    property StaffID: string read FStaffID write FStaffID;
    property Country: String read FCountry write FCountry;
    property CompanyName: String read FCompanyName write FCompanyName;
    property ParentCompanyName: String read FParentCompanyName write FParentCompanyName;
    property ModuleId: String read FModuleId write FModuleId;
    property ModuleVersion: String read FModuleVersion write FModuleVersion;
    property DbVersion: String read FDBVersion write FDBVersion;
    property SqlVersion: String read FSqlVersion write FSqlVersion;
    property HasSurvey: boolean read GetHasSurvey;
  end;

implementation
uses
  SysUtils,
  idCoder,
  IdCoderMIME;

{ TNPSLeanEngage }

constructor TNPSLeanEngage.Create;
begin
  FInitializationThread := nil;
end;

destructor TNPSLeanEngage.Destroy;
begin
  FreeInitializationThread;
  
  inherited;
end;

procedure TNPSLeanEngage.FreeInitializationThread;
begin
  if FInitializationThread <> nil then
  begin
    FInitializationThread.Terminate;

    if FInitializationThread.Suspended then
    begin
      FInitializationThread.Resume;
    end;

    FInitializationThread.WaitFor;

    FInitializationThread.Free;

    FInitializationThread := nil;
  end;
end;

function TNPSLeanEngage.GetHasSurvey: boolean;
begin
  result := FInitializationThread.HasSurvey;
end;

procedure TNPSLeanEngage.GetSurveys(Surveys: TNPSSurveys);
begin
  if FInitializationThread <> nil then
  begin
    FInitializationThread.GetSurveys(Surveys);
  end;
end;

procedure TNPSLeanEngage.InitializeAsync(ServerUrl, ServerKey, IdentityId: String; OnCompleted: TNotifyEvent = nil);
begin
  FreeInitializationThread;

  StartInitializationThread(ServerUrl, ServerKey, IdentityId, OnCompleted);
end;

procedure TNPSLeanEngage.StartInitializationThread(ServerUrl, ServerKey, IdentityId: String; OnCompleted: TNotifyEvent);
begin
  if FInitializationThread = nil then
  begin
    FInitializationThread := TLEInitializationThread.Create;

    FInitializationThread.IdentityId := IdentityId;
    FInitializationThread.StaffID := StaffID;
    FInitializationThread.Country := Country;
    FInitializationThread.CompanyName := CompanyName;
    FInitializationThread.ParentCompanyName := ParentCompanyName;
    FInitializationThread.ModuleId := ModuleId;
    FInitializationThread.ModuleVersion := ModuleVersion;
    FInitializationThread.SqlVersion := FSqlVersion;
    FInitializationThread.DbVersion := DbVersion;
    FInitializationThread.ServerKey := ServerKey;
    FInitializationThread.ServerUrl := ServerUrl;

    FInitializationThread.OnCompleted := OnCompleted;

    FInitializationThread.Resume;
  end;
end;

{ TLEInitializationThread }

constructor TLEInitializationThread.Create;
begin
  inherited Create(True);

  FSurvey := TLESurvey.Create;

  FHasSurvey := False;
end;

destructor TLEInitializationThread.Destroy;
begin
  FSurvey.Free;

  inherited;
end;

procedure TLEInitializationThread.Execute;
var
  Identity: TLEIdentity;
  Server: TNPSServer;
begin
  FHasSurvey := False;

  if not Terminated then
  begin
    try
      Identity := TLEIdentity.Create;

      try
        Identity.Id :=  EncodeString( TIdEncoderMIME, FStaffID + FCompanyName);

        Identity.StaffId := Identity.Id (*FStaffId*); { TODO : Check whether BA agrees that StaffID must be Encoded (MIME) }
        Identity.Country := FCountry;
        Identity.Company.Name := FCompanyName;
        Identity.Company.ParentName := FParentCompanyName;
        Identity.Module.Id := FModuleId;
        Identity.Module.Version := FModuleVersion;

        Server := TNPSServer.Create(ServerKey, ServerUrl, FCompanyName);

        try
          Server.SetNPSIdentity(Identity);

          Server.GetNPSSurvey( Identity.Id, FSurvey);

          FHasSurvey := trim( FSurvey.Url ) <> '';

          if not Terminated then
          begin
            if Assigned(FOnCompleted) then
            begin
              FOnCompleted(Self);
            end;
          end;
        finally
          Server.Free;
        end;
      finally
        Identity.Free;
      end;
    except
      on E: Exception do begin
        FHasSurvey := False;
        raise Exception.Create(E.Message);
      //Raise the error don't Suppress error;
      end;
    end;
  end;
end;

procedure TLEInitializationThread.GetSurveys(Surveys: TNPSSurveys);
var
  Survey: TNPSSurvey;
begin
  WaitFor;
       
  Surveys.Clear;

  if FHasSurvey then
  begin
    Survey := TNPSSurvey.Create;

    try
      Survey.Id := FSurvey.Id;
      Survey.Name := FSurvey.Name;
      Survey.Url := FSurvey.Url;

      Surveys.Add(Survey);
    except
      Survey.Free;
    end;
  end;
end;

{ TNPSSurveys }

procedure TNPSSurveys.Add(Survey: TNPSSurvey);
begin
  FItems.Add(Survey);
end;

procedure TNPSSurveys.Clear;
begin
  FItems.Clear;
end;

constructor TNPSSurveys.Create;
begin
  FItems := TObjectList.Create(True);
end;

destructor TNPSSurveys.Destroy;
begin
  FItems.Free;
  
  inherited;
end;

function TNPSSurveys.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TNPSSurveys.GetSurvey(Index: Integer): TNPSSurvey;
begin
  Result := FItems[Index] as TNPSSurvey;
end;

function TNPSSurveys.SurveyByName(SurveyName: String): TNPSSurvey;
var
  Index: Integer;
  Survey: TNPSSurvey;
begin
  Result := nil;

  for Index := 0 to FItems.Count - 1 do
  begin
    Survey := FItems[Index] as TNPSSurvey;

    if Survey.Name = SurveyName then
    begin
      Result := Survey;

      Exit;
    end;
  end;
end;

end.
