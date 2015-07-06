unit uNPS;

interface


uses
  Classes, uLeanEngageLib, Contnrs, uNPSServer;

type
(*  TNPSSurvey = class
  private
    FName: String;
    FId: String;
    FUrl: String;
  public
    property Id: String read FId write FId;
    property Name: String read FName write FName;
    property Url: String read FUrl write FUrl;
  end; *)

  TNPSSurveys = class
  private
    FItems: TObjectList;
    function GetCount: Integer;
    function GetSurvey(Index: Integer): TLESurvey;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;

    procedure Add(Survey: TLESurvey);

    function SurveyByName(SurveyName: String): TLESurvey;

    property Items[Index: Integer]: TLESurvey read GetSurvey; default;
    property Count: Integer read GetCount;
  end;

  TLENPSBaseThread = class(TThread)
  private
    fIdentity: TLEIdentity;
    fServer: TNPSServer;
    fOnCompleted: TNotifyEvent;
  protected
    property Identity: TLEIdentity read FIdentity;
    property Server: TNPSServer read fServer;
  public
    constructor Create( aIdentityID, aServerUrl, aServerKey : string ); reintroduce;
    destructor Destroy; override;

    procedure FireAndForget( aOnCompleted: TNotifyEvent = nil); virtual;
  end;

  TLENPSBaseIdentifySurveyThread = class(TLENPSBaseThread)
  private
  protected
  public
    constructor Create( aIdentityID, aServerUrl, aServerKey, aCompanyName,
      aCountry, aStaffID, aModuleId, aModuleVersion : string ); reintroduce;

    property OnCompleted: TNotifyEvent read FOnCompleted write FOnCompleted;

  end;

  TLENPSIdentifyThread = class(TLENPSBaseIdentifySurveyThread)
  private
  protected
    procedure Execute; override;
  public
  end;

  TLENPSSurveyThread = class(TLENPSBaseIdentifySurveyThread)
  private
    fSurveys: TNPSSurveys;

    FHasSurvey: Boolean;

  protected
    procedure Execute; override;
  public
    constructor Create( aIdentityID, aServerUrl, aServerKey, aCompanyName,
      aCountry, aStaffID, aModuleId, aModuleVersion : string );

    destructor Destroy; override;
  end;

  TLETriggeredActionThread = class(TLENPSBaseThread)
  private
    FTriggerActionType : TTriggerActionType;
    FMessageContent: String;
    FHasFeedbackURL : boolean;
    FFeedbackURL : string;
  protected
    procedure Execute; override;
  public
    procedure FireAndForget( aTriggerActionType : TTriggerActionType;
      aMessageContent : string; aOnCompleted: TNotifyEvent = nil); reintroduce;

    property OnCompleted: TNotifyEvent read FOnCompleted write FOnCompleted;
    property HasFeedbackURL : boolean read FHasFeedbackURL;
    property FeedbackURL : string read FFeedbackURL;
  end;


  TNPSLeanEngage = class
  private
    FIdentityId    : string;
    FServerUrl     : string;
    FServerKey     : string;
    FCompanyName: String;
    FCountry: String;
    FStaffID: string;
    FModuleId: String;
    FModuleVersion : String;

    FLENPSIdentityThread: TLENPSIdentifyThread;
    FLENPSSurveyThread: TLENPSSurveyThread;
    FLETriggeredActionThread: TLETriggeredActionThread;

    procedure StartNPSIdentifyThread; //( aOnCompleted: TNotifyEvent );
    procedure FreeNPSIdentifyThread;
    procedure StartNPSSurveyThread; //( aOnCompleted: TNotifyEvent );
    procedure FreeNPSSurveyThread;
    procedure StartTriggerFeedbackThread; //( aOnCompleted: TNotifyEvent );
    procedure FreeTriggerFeedbackThread;

  protected
    procedure InitNPSIdentityAsync(aOnCompleted: TNotifyEvent = nil);
    procedure InitNPSSurveyAsync(aOnCompleted: TNotifyEvent = nil);
    procedure InitTriggerFeedbackAsync(aOnCompleted: TNotifyEvent = nil);

    function GetHasSurvey : boolean;
    function GetHasFeedbackURL : boolean;
    function GetFeedbackURL : string;
    procedure SetIdentityId( aValue : string );
  public
    constructor Create(aIdentityID, aServerUrl, aServerKey, aCompanyName,
      aCountry, aStaffID, aModuleId, aModuleVersion : string);
    destructor Destroy; override;

    procedure TriggerIdentifyAsync( aOnCompleted: TNotifyEvent = nil );
    procedure TriggerSurveyAsync( aOnCompleted: TNotifyEvent = nil );
    procedure TriggerFeedbackAsync(aTriggerActionType : TTriggerActionType;
      aMessageContent: String; aOnCompleted: TNotifyEvent = nil);

    function GetSurveys: TNPSSurveys;

    property IdentityId: String read FIdentityId write SetIdentityId;

    property HasSurvey: boolean read GetHasSurvey;
    property HasFeedbackURL : boolean read GetHasFeedbackURL;
    property FeedbackURL : string read GetFeedbackURL;
    property StaffID: string read FStaffID write FStaffID;
    property Country: String read FCountry write FCountry;
    property CompanyName: String read FCompanyName write FCompanyName;
    property ModuleId: String read FModuleId write FModuleId;
    property ModuleVersion: String read FModuleVersion write FModuleVersion;
    property Surveys: TNPSSurveys read GetSurveys;
  end;

implementation
uses
  SysUtils,
  idCoder,
  IdCoderMIME,
  uHttpLib;

{ TNPSLeanEngage }

constructor TNPSLeanEngage.Create(aIdentityID, aServerUrl, aServerKey, aCompanyName,
              aCountry, aStaffID, aModuleId, aModuleVersion : string);
begin
  FLENPSIdentityThread := nil;
  FLENPSSurveyThread:= nil;
  FLETriggeredActionThread := nil;
  IdentityID     := aIdentityID; // Force through the SetIdentity write method for MIME encoding
  fServerUrl     := aServerUrl;
  fServerKey     := aServerKey;
  fCompanyName   := aCompanyName;
  fCountry       := aCountry;
  fStaffID       := aStaffID;
  fModuleId      := aModuleId;
  fModuleVersion := aModuleVersion;
end;

destructor TNPSLeanEngage.Destroy;
begin
  FreeTriggerFeedbackThread;
  FreeNPSIdentifyThread;

  inherited;
end;

procedure TNPSLeanEngage.FreeNPSIdentifyThread;
begin
  if FLENPSIdentityThread <> nil then
  begin
    FLENPSIdentityThread.Terminate;

    if FLENPSIdentityThread.Suspended then
    begin
      FLENPSIdentityThread.Resume;
    end;

    FLENPSIdentityThread.WaitFor;

    FLENPSIdentityThread.Free;

    FLENPSIdentityThread:= nil;
  end;
end;

procedure TNPSLeanEngage.FreeNPSSurveyThread;
begin
  if FLENPSSurveyThread <> nil then
  begin
    FLENPSSurveyThread.Terminate;

    if FLENPSSurveyThread.Suspended then
    begin
      FLENPSSurveyThread.Resume;
    end;

    FLENPSSurveyThread.WaitFor;

    FLENPSSurveyThread.Free;

    FLENPSSurveyThread:= nil;
  end;
end;

procedure TNPSLeanEngage.FreeTriggerFeedbackThread;
begin
  if FLETriggeredActionThread <> nil then
  begin
    FLETriggeredActionThread.Terminate;

    if FLETriggeredActionThread.Suspended then
    begin
      FLETriggeredActionThread.Resume;
    end;

    FLETriggeredActionThread.WaitFor;

    FLETriggeredActionThread.Free;

    FLETriggeredActionThread:= nil;
  end;
end;

function TNPSLeanEngage.GetFeedbackURL: string;
begin
  if assigned( FLETriggeredActionThread ) then
    result := FLETriggeredActionThread.FFeedbackURL;
end;

function TNPSLeanEngage.GetHasFeedbackURL: boolean;
begin
  if assigned( FLETriggeredActionThread ) then
    result := FLETriggeredActionThread.FHasFeedbackURL;
end;

function TNPSLeanEngage.GetHasSurvey: boolean;
begin
    if FLENPSIdentityThread <> nil then
    result := FLENPSSurveyThread.FHasSurvey; 
end;

function TNPSLeanEngage.GetSurveys: TNPSSurveys;
begin
  if assigned( FLENPSSurveyThread ) then
    result := FLENPSSurveyThread.fSurveys;
end;




procedure TNPSLeanEngage.InitNPSIdentityAsync; //(aOnCompleted: TNotifyEvent = nil);
begin
  FreeNPSIdentifyThread;

  StartNPSIdentifyThread; //( aOnCompleted );
end;

procedure TNPSLeanEngage.InitNPSSurveyAsync(aOnCompleted: TNotifyEvent);
begin
  FreeNPSSurveyThread;

  StartNPSSurveyThread; //( aOnCompleted );
end;

procedure TNPSLeanEngage.InitTriggerFeedbackAsync(aOnCompleted: TNotifyEvent = nil);
begin
  FreeTriggerFeedbackThread;

  StartTriggerFeedbackThread; //( aOnCompleted );
end;

procedure TNPSLeanEngage.TriggerIdentifyAsync(aOnCompleted: TNotifyEvent);
begin
  FreeNPSIdentifyThread;

  StartNPSIdentifyThread; //( aOnCompleted );

  FLENPSIdentityThread.FireAndForget( aOnCompleted );
end;

procedure TNPSLeanEngage.TriggerSurveyAsync(aOnCompleted: TNotifyEvent);
begin
  FreeNPSSurveyThread;

  StartNPSSurveyThread;

  FLENPSSurveyThread.FireAndForget( aOnCompleted );
end;

procedure TNPSLeanEngage.TriggerFeedbackAsync(aTriggerActionType : TTriggerActionType;
      aMessageContent: String; aOnCompleted: TNotifyEvent = nil);
begin
  FreeTriggerFeedbackThread;

  StartTriggerFeedbackThread; // ( aOnCompleted );

  FLETriggeredActionThread.FireAndForget( aTriggerActionType, aMessageContent );
end;

procedure TNPSLeanEngage.SetIdentityId(aValue: string);
begin
  if trim( aValue ) <> '' then
    FIdentityID := EncodeString( TIdEncoderMIME, aValue)
  else
    FIdentityID := '';
end;

procedure TNPSLeanEngage.StartNPSIdentifyThread; //( aOnCompleted: TNotifyEvent );
begin
  if FLENPSIdentityThread = nil then
  begin
    FLENPSIdentityThread := TLENPSIdentifyThread.Create( fIdentityId,
      fServerURL, fServerKey, fCompanyName, fCountry, fStaffID, fModuleId,
      fModuleVersion );
  end;
end;

procedure TNPSLeanEngage.StartNPSSurveyThread;
begin
  if FLENPSSurveyThread = nil then
    FLENPSSurveyThread := TLENPSSurveyThread.Create( fIdentityId,
      fServerURL, fServerKey, fCompanyName, fCountry, fStaffID, fModuleId,
      fModuleVersion );

end;

procedure TNPSLeanEngage.StartTriggerFeedbackThread; //( aOnCompleted: TNotifyEvent );
begin
  if FLETriggeredActionThread = nil then
  begin
    FLETriggeredActionThread := TLETriggeredActionThread.Create( fIdentityID, fServerUrl,
      fServerKey );
  end;
end;

(* 03/07/2015 **** procedure TLENPSBaseIdentifySurveyThread.Execute;
begin

  if not Terminated then
  begin
    try
      Identity := TLEIdentity.Create;

      try
        Identity.Id :=  fIdentityID; // Moved responsibility to using code //EncodeString( TIdEncoderMIME, FStaffID + FCompanyName);

        Identity.StaffId := FStaffId; { TODO : Check whether BA agrees that StaffID must be Encoded (MIME) }
        Identity.Country := FCountry;
        Identity.Company.Name := FCompanyName;
//DN - Unsure if available in Practice        Identity.Company.ParentName := FParentCompanyName;
        Identity.Module.Id := FModuleId;
        Identity.Module.Version := FModuleVersion;

        Server := TNPSServer.Create(ServerKey, ServerUrl
                    {//DN - Probably Redundant code  , FCompanyName});

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
end;   *****************)


(*procedure TLENPSBaseIdentifySurveyThread.GetSurveys(Surveys: TNPSSurveys);
var
  Survey: TNPSSurvey;
begin
  WaitFor;

  Surveys.Clear;

  if FHasSurvey then
  begin
    Survey := TNPSSurvey.Create;
    try
      while fHasSurvey do
      try
        Survey.Id := FSurvey.Id;
        Survey.Name := FSurvey.Name;
        Survey.Url := FSurvey.Url;

        Surveys.Add(Survey);
      finally
        FireAndForget();
      end;
    except
      Survey.Free;
    end;
  end;
end;
*)
{ TNPSSurveys }

procedure TNPSSurveys.Add(Survey: TLESurvey);
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

function TNPSSurveys.GetSurvey(Index: Integer): TLESurvey;
begin
  Result := FItems[Index] as TLESurvey;
end;

function TNPSSurveys.SurveyByName(SurveyName: String): TLESurvey;
var
  Index: Integer;
  Survey: TLESurvey;
begin
  Result := nil;

  for Index := 0 to FItems.Count - 1 do
  begin
    Survey := FItems[Index] as TLESurvey;

    if Survey.Name = SurveyName then
    begin
      Result := Survey;

      Exit;
    end;
  end;
end;

{ TLENPSBaseThread }

constructor TLENPSBaseThread.Create(aIdentityID, aServerUrl, aServerKey : string);
begin
  inherited Create(True);

//  FreeOnTerminate    := true; // Drop this Thread when done.

  fIdentity:= TLEIdentity.Create;
  fIdentity.ID := aIdentityID;

  fServer:= TNPSServer.Create(aServerKey, aServerUrl);

  Priority           := tpLowest;
end;

destructor TLENPSBaseThread.Destroy;
begin
  freeAndNil( fServer );

  freeAndNil( fIdentity );

  inherited;
end;

procedure TLENPSBaseThread.FireAndForget(aOnCompleted: TNotifyEvent);
begin
  fOnCompleted := aOnCompleted;

  Resume;
end;

{ TLENPSBaseIdentifySurveyThread }

constructor TLENPSBaseIdentifySurveyThread.Create( aIdentityID, aServerUrl, aServerKey, aCompanyName,
      aCountry, aStaffID, aModuleId, aModuleVersion : string );
begin
  inherited Create( aIdentityID, aServerUrl, aServerKey);

  fIdentity.Company.Name := aCompanyName;
  fIdentity.Country := aCountry;
  fIdentity.StaffId := aStaffId; { TODO : Check whether BA agrees that StaffID must be Encoded (MIME) }
  fIdentity.Module.Id := aModuleId;
  fIdentity.Module.Version := aModuleVersion;

  Priority           := tpLowest;

//  FreeOnTerminate := true; // Drop this Thread when done.
end;

{ TLENPSIdentifyThread }

procedure TLENPSIdentifyThread.Execute;
begin
  inherited;

  if not Terminated then
  begin
    try
      fServer.SetNPSIdentity(fIdentity);

      if not Terminated then
      begin
        if Assigned(FOnCompleted) then
        begin
          FOnCompleted(Self);
        end;
      end;
    except
      on E: Exception do begin
        raise Exception.Create(E.Message);
      //Raise the error don't Suppress error;
      end;
    end;
  end;
end;

{ TLETriggeredActionThread }

procedure TLETriggeredActionThread.Execute;
var
  JSONObject: TJsonObject;
  Feedback: TFeedbackJSON;
begin
  if not Terminated then
  begin
    try
      try
        JSONObject := TLETriggerActionJSON.Create( FTriggerActionType, fIdentity.Id, FMessageContent );
        try
          case FTriggerActionType of
            taEventTrack       : Server.setEventTrack( fIdentity.Id, JSONObject );
            taFeedbackResponse : begin
              Feedback:= TFeedbackJSON.Create;
              try
                Server.setFeedBackResponse( fIdentity.Id, JSONObject, Feedback );
                FHasFeedbackURL := Feedback.HasUrl;
                FFeedbackURL    := Feedback.Url;
              finally
                freeAndNil( Feedback );
              end;
            end;
          end;

          if not Terminated then
          begin
            if Assigned(FOnCompleted) then
            begin
              FOnCompleted(Self);
            end;
          end;
        finally
          JSONObject.Free;
        end;
      except
        on E: Exception do begin
          raise Exception.Create(E.Message);
        //Raise the error don't Suppress error;
        end;
      end;
    finally
      Terminate;
    end;
  end;
end;


procedure TLETriggeredActionThread.FireAndForget(
  aTriggerActionType: TTriggerActionType; aMessageContent: string;
    aOnCompleted: TNotifyEvent = nil );
begin
  fMessageContent    := aMessageContent;
  fTriggerActionType := aTriggerActionType;

  inherited FireAndForget( aOnCompleted );
end;


{ TLENPSSurveyThread }

constructor TLENPSSurveyThread.Create(aIdentityID, aServerUrl, aServerKey,
  aCompanyName, aCountry, aStaffID, aModuleId, aModuleVersion: string);
begin
  inherited;

  FSurveys:= TNPSSurveys.Create;

  fHasSurvey := false;
end;

destructor TLENPSSurveyThread.Destroy;
begin
  freeAndNil( fSurveys );

  inherited;
end;

procedure TLENPSSurveyThread.Execute;
var
  FSurveyJSON : TLESurvey;

  function CheckAndAddedToSurveys( aSurveyJSON : TLESurvey ) : boolean;
  begin
    try
      FHasSurvey := False; //Make sure the default is false

      fServer.GetNPSSurvey( fIdentity.Id, aSurveyJSON);

      FHasSurvey := trim( aSurveyJSON.Url ) <> '';
      if FHasSurvey then
        fSurveys.Add( aSurveyJSON );
    finally
      result := FHasSurvey;
    end;
  end;
begin
  inherited;

  FHasSurvey := False;

  if not Terminated then
  begin
    try
      FSurveyJSON := TLESurvey.Create;
      try
        CheckAndAddedToSurveys( FSurveyJSON )
      except
      // We need to destroy the JSON object
        freeAndNil( FSurveyJSON );
      end;

//      if not CheckAndAddedToSurveys( FSurveyJSON ) then // We need to destroy the JSON object
//        freeAndNil( FSurveyJSON );


      while FHasSurvey and (not Terminated) do begin

        FSurveyJSON := TLESurvey.Create;
        try
          CheckAndAddedToSurveys( FSurveyJSON )
        except
        // We need to destroy the JSON object
          freeAndNil( FSurveyJSON );
        end;

//        if not CheckAndAddedToSurveys( FSurveyJSON ) then // We need to destroy the JSON object
//          freeAndNil( FSurveyJSON );
      end;
      
      if not Terminated then
      begin
        if Assigned(FOnCompleted) then
        begin
          FOnCompleted(Self);
        end;
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

end.
