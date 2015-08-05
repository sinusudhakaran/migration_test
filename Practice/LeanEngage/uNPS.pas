unit uNPS;

interface


uses
  Classes, uLeanEngageLib, Contnrs, uNPSServer;

type
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

  TLENPSBaseThread = class( TThread )
  private
    fIdentity: TLEIdentity;
    fServer: TNPSServer;
    fOnCompleted: TNotifyEvent;
    fSynchroniseLogMessage : string;

  protected
    property Identity: TLEIdentity read FIdentity;
    property Server: TNPSServer read fServer;
    procedure SetAndSynchroniseLogMessage( aLogMessage : string );
    procedure SynchroniseLogMessage;
  public
    constructor Create( aIdentityID, aServerUrl, aServerKey : string ); reintroduce;
    destructor Destroy; override;

    procedure CallBack;
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

    procedure StartNPSIdentifyThread;
    procedure FreeNPSIdentifyThread;
    procedure StartNPSSurveyThread;
    procedure FreeNPSSurveyThread;
    procedure StartTriggerFeedbackThread; 
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
      aMessageContent: String = ''; aOnCompleted: TNotifyEvent = nil);

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
  LogUtil,
  SysUtils,
  idCoder,
  IdCoderMIME,
  uHttpLib,
  strUtils,
  bkConst;

const
  unitname = 'uNPS';
  DebugAutoSave: Boolean = False;
  AutoSaveUnit = 'AutoSave';

var
  DebugMe : boolean = false;

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
  fStaffID       := IdentityID; //aStaffID;
  fModuleId      := aModuleId;
  fModuleVersion := aModuleVersion;
end;

destructor TNPSLeanEngage.Destroy;
begin
  FreeTriggerFeedbackThread;
  FreeNPSSurveyThread;
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
  result := false;
  if FLENPSSurveyThread <> nil then
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

  StartNPSIdentifyThread;
end;

procedure TNPSLeanEngage.InitNPSSurveyAsync(aOnCompleted: TNotifyEvent);
begin
  FreeNPSSurveyThread;

  StartNPSSurveyThread;
end;

procedure TNPSLeanEngage.InitTriggerFeedbackAsync(aOnCompleted: TNotifyEvent = nil);
begin
  FreeTriggerFeedbackThread;

  StartTriggerFeedbackThread; 
end;

procedure TNPSLeanEngage.TriggerIdentifyAsync(aOnCompleted: TNotifyEvent);
begin
  FreeNPSIdentifyThread;

  StartNPSIdentifyThread;

  FLENPSIdentityThread.FireAndForget( aOnCompleted );
end;

procedure TNPSLeanEngage.TriggerSurveyAsync(aOnCompleted: TNotifyEvent);
begin
  FreeNPSSurveyThread;

  StartNPSSurveyThread;

  FLENPSSurveyThread.FireAndForget( aOnCompleted );
end;

procedure TNPSLeanEngage.TriggerFeedbackAsync(aTriggerActionType : TTriggerActionType;
      aMessageContent: String = ''; aOnCompleted: TNotifyEvent = nil);
begin
  FreeTriggerFeedbackThread;

  StartTriggerFeedbackThread;

  FLETriggeredActionThread.FireAndForget( aTriggerActionType, aMessageContent, aOnCompleted );
end;

procedure TNPSLeanEngage.SetIdentityId(aValue: string);
begin
  if trim( aValue ) <> '' then
    FIdentityID := EncodeString( TIdEncoderMIME, aValue)
  else
    FIdentityID := '';
end;

procedure TNPSLeanEngage.StartNPSIdentifyThread;
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

procedure TNPSLeanEngage.StartTriggerFeedbackThread;
begin
  if FLETriggeredActionThread = nil then
  begin
    FLETriggeredActionThread := TLETriggeredActionThread.Create( fIdentityID, fServerUrl,
      fServerKey );
  end;
end;

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

procedure TLENPSBaseThread.CallBack;
begin
  FOnCompleted(Self); //FOnCompleted has to be fired from within this routine,
                      // because it has to be Synchronised to main thread (VCL)
end;

constructor TLENPSBaseThread.Create(aIdentityID, aServerUrl, aServerKey : string);
begin
  inherited Create(True);

  fIdentity:= TLEIdentity.Create;
  fIdentity.ID := aIdentityID;

  fServer:= TNPSServer.Create(Self, aServerKey, aServerUrl);

  Priority     := tpLowest;
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

procedure TLENPSBaseThread.SetAndSynchroniseLogMessage(aLogMessage: string);
begin
  if DebugMe then begin
    fSynchroniseLogMessage := aLogMessage;
    self.Synchronize( self, SynchroniseLogMessage );
  end;
end;

procedure TLENPSBaseThread.SynchroniseLogMessage;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, unitname, fSynchroniseLogMessage );
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

  if DebugMe then
    SetAndSynchroniseLogMessage(
      format( 'TLENPSBaseIdentifySurveyThread.Create( aIdentityID = %s, ' +
        'aServerUrl = %s, aServerKey = %s, aCompanyName = %s, aCountry = %s, ' +
        'aStaffID = %s, aModuleId = %s, aModuleVersion = %s )',
      [ aIdentityID, aServerUrl, aServerKey, aCompanyName,
      aCountry, aStaffID, aModuleId, aModuleVersion ] ) );

  Priority           := tpLowest;
end;

{ TLENPSIdentifyThread }

procedure TLENPSIdentifyThread.Execute;
begin
  inherited;

  if not Terminated then
  begin
    try
      try
        if DebugMe then
          SetAndSynchroniseLogMessage(
            format( 'TLENPSIdentifyThread.Execute, JSON= %s )',
            [ fIdentity.Serialize ] ) );
        fServer.SetNPSIdentity(fIdentity);
      except
        on E: Exception do ;
      end;
      if not Terminated then
      begin
        if Assigned(FOnCompleted) then
        begin
          Synchronize( Self, CallBack );
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

  function ReplaceLEParams( aURL : string ) : string;
  const
//    cLEFeedback = '&user_id=%s&widget_title=%s&textarea_placeholder=%s&background_color=%231abc9c&one_way=true';
    cLEFeedbackTitle = 'Give us your ideas and feedback for ' + BRAND_PRACTICE + '.';
    cLEFeedbackBreadCrum = 'Enter feedback here...';
  var
    i : integer;

  begin
    result := '';
    i := pos('&', aUrl);
    if i > 0 then begin
      delete(aURL, i, length( aUrl ) );

//      result := Format( cLEFeedback, [ fIdentity.Id, cLEFeedbackTitle, cLEFeedbackBreadCrum ] );
      result := aUrl + '&user_id=' + fIdentity.Id + '&widget_title=' +
        cLEFeedbackTitle + '&textarea_placeholder=' + cLEFeedbackBreadCrum +
        '&background_color=%231abc9c&one_way=true';
    end;
  end;

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
                FFeedbackURL    := ReplaceLEParams( Feedback.Url );
              finally
                freeAndNil( Feedback );
              end;
            end;
          end;

          if not Terminated then
          begin
            if Assigned(FOnCompleted) then
            begin
              Synchronize( Self, CallBack );
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
  bHasNewSurvey : boolean;

  function CheckAndAddedToSurveys( aSurveyJSON : TLESurvey ) : boolean;
  begin
    result := False; //Make sure the default is false

    try
      if DebugMe then
        SetAndSynchroniseLogMessage(
          'TLENPSSurveyThread.Execute.CheckAndAddedToSurveys about to ' +
          'execute fServer.GetNPSSurvey' );
      fServer.GetNPSSurvey( fIdentity.Id, aSurveyJSON);
    except
      on E: Exception do begin
        freeAndNil( aSurveyJSON ); // If there is an exception, we need to destroy
          // the created object and exit the function else a memory leak will occur
        exit;
      end; // Swallow the event
    end;
    result := trim( aSurveyJSON.Url ) <> '';
    if trim( aSurveyJSON.Url ) <> '' then
      fSurveys.Add( aSurveyJSON );
  end;
begin
  inherited;

  FHasSurvey := False;

  if not Terminated then
  begin
    try
      bHasNewSurvey := true;
      while bHasNewSurvey and (not Terminated) do begin
        bHasNewSurvey := false;

        FSurveyJSON := TLESurvey.Create;
        try
          bHasNewSurvey := CheckAndAddedToSurveys( FSurveyJSON );
          if bHasNewSurvey then
            FHasSurvey := true;
        except
        // We DO NEED need to destroy the JSON object as it is Added to a ObjectList
//          freeAndNil( FSurveyJSON );
        end;
      end;

      if not Terminated then
      begin
        if Assigned(FOnCompleted) then
        begin
          Synchronize( Self, CallBack );
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

initialization
   DebugMe := DebugUnit(UnitName);
   DebugAutoSave := DebugUnit(AutoSaveUnit);
end.
