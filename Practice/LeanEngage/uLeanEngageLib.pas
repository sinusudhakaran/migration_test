unit uLeanEngageLib;

interface

uses
  Classes, uHttpLib, StrUtils, uLKJSON, Contnrs;

type
  TLEIdentity = class(TJsonObject)
  private
    type
      TCompany = class
      private
        FName: String;
        FParentName: String;
      public
        property Name: String read FName write FName;
        property ParentName: String read FParentName write FParentName;
      end;

      TModule = class
      private
        FVersion: String;
        FModule: String;
      public
        property Id: String read FModule write FModule;
        property Version: String read FVersion write FVersion;
      end;

  private
    FStaffId: String;
    FIndustry: String;
    FId: String;
    FCompany: TCompany;
    FModule: TModule;
    FCountry: String;
  public
    constructor Create; virtual;

    procedure Deserialize(Json: String); override;
    function Serialize: String; override;

    property Id: String read FId write FId;
    property StaffId: String read FStaffId write FStaffId;
    property Industry: String read FIndustry write FIndustry;
    property Country: String read FCountry write FCountry;
    property Company: TCompany read FCompany;
    property Module: TModule read FModule;
  end;

  TLESurvey = class(TJsonObject)
  private
    FName: String;
    FId: String;
    FUrl: String;
  public
    procedure Deserialize(Json: String); override;
    function Serialize: String; override;

    property Id: String read FId write FId;
    property Name: String read FName write FName;
    property Url: String read FUrl write FUrl;
  end;

  TLESurveys = class(TJsonObject)
  private
    FItems: TObjectList;

    function GetItems(Index: Integer): TLESurvey;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Deserialize(Json: String); override;
    function Serialize: String; override;

    function SurveyByName(SurveyName: String): TLESurvey;
    
    property Items[Index: Integer]: TLESurvey read GetItems; default;
    property Count: Integer read GetCount;
  end;

  TLEEventTrack = class(TJsonObject)
  private
    FId: String;
    FEventTrack: String;
  public
    function Serialize: String; override;

    property Id: String read FId write FId;
    property EventTrack: String read FEventTrack write FEventTrack;
  end;

  TLEFeedbackResponse = class(TJsonObject)
  private
    FId: String;
    FFeedbackResponse: String;
  public
    function Serialize: String; override;

    property Id: String read FId write FId;
    property FeedbackResponse: String read FFeedbackResponse write FFeedbackResponse;
  end;


implementation


{ TLEIdentity }

constructor TLEIdentity.Create;
begin
  FCompany := TCompany.Create;
  FModule := TModule.Create;
end;

function TLEIdentity.Serialize: String;

  procedure AddTraits(User: TlkJSONobject);
  var
    JsonObject: TlkJSONobject;
  begin
    JsonObject := TlkJSONobject.Create();

    JsonObject.Add('name', FStaffId);
    JsonObject.Add('industry', FIndustry);
    JsonObject.Add('country', FCountry);
    JsonObject.Add('module_id', FModule.Id);
    JsonObject.Add('module_vesion', FModule.Version);

    User.Add('traits', JsonObject);
  end;

  procedure AddCompany(User: TlkJSONobject);
  var
    JsonObject: TlkJSONobject;
    Companies: TlkJSONlist;
    Traits: TlkJSONobject;
  begin
    JsonObject := TlkJSONobject.Create();

    JsonObject.Add('company_id', ReplaceStr(FCompany.Name, ' ', '_'));

    Traits := TlkJSONobject.Create();

    Traits.Add('name', FCompany.Name);

    if FCompany.ParentName <> '' then
    begin
      Traits.Add('parentname', FCompany.ParentName);
    end;

    JsonObject.Add('traits', Traits);
    
    Companies := TlkJSONlist.Create;

    Companies.Add(JsonObject);

    User.Add('companies', Companies);
  end;

var
  User: TlkJSONobject;
begin
  User := TlkJSONobject.Create();

  try
    User.Add('user_id', FId);

    AddTraits(User);
    AddCompany(User);

    Result := TlkJSON.GenerateText(User);
  finally
    User.Free;
  end;
end;

procedure TLEIdentity.Deserialize(Json: String);
begin

end;

{ TLESurveys }

constructor TLESurveys.Create;
begin
  FItems := TObjectList.Create(True);
end;

function TLESurveys.Serialize: String;
begin

end;

destructor TLESurveys.Destroy;
begin
  FItems.Free;
  
  inherited;
end;

function TLESurveys.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TLESurveys.GetItems(Index: Integer): TLESurvey;
begin
  Result := FItems[Index] as TLESurvey;
end;

procedure TLESurveys.Deserialize(Json: String);
var
  JsonObject: TlkJSONbase;
  JsonList: TlkJSONlist;
  Index: Integer;
  Survey: TLESurvey;
begin
  FItems.Clear;
  
  JsonObject := TlkJSON.ParseText(Json);

  if (JsonObject = nil) then
  begin
    Exit;
  end;
  
  try
    if not (JsonObject.Field['feedback'] is TlkJSONobject) then
    begin
      Exit;
    end;

    JsonList :=  JsonObject.Field['feedback'] as TlkJSONlist;

    for Index := 0 to JsonList.Count - 1 do
    begin
      Survey := TLESurvey.Create;

      try
        Survey.Id := JsonList.Child[Index].Field['id'].Value;
        Survey.Name := JsonList.Child[Index].Field['name'].Value;
        Survey.Url := JsonList.Child[Index].Field['url'].Value;

        FItems.Add(Survey);
      except
        Survey.Free;
      end;
    end;
  finally
    JsonObject.Free;
  end;
end;

function TLESurveys.SurveyByName(SurveyName: String): TLESurvey;
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

{ TLESurvey }

function TLESurvey.Serialize: String;
begin

end;

procedure TLESurvey.Deserialize(Json: String);
var
  JsonObject: TlkJSONbase;
  Feedback: TlkJSONbase;
begin
  JsonObject := TlkJSON.ParseText(Json);

  if (JsonObject = nil) then
  begin
    Exit;
  end;
  
  try
    if not (JsonObject.Field['feedback'] is TlkJSONobject) then
    begin
      Exit;
    end;

    Feedback :=  JsonObject.Field['feedback'] as TlkJSONobject;

    FId := Feedback.Field['id'].Value;
    FName := Feedback.Field['name'].Value;
    FUrl := Feedback.Field['url'].Value;
  finally
    JsonObject.Free;
  end;
end;

{ TLEEventTrack }

procedure TLEEventTrack.Deserialize(Json: String);
begin
end;

function TLEEventTrack.Serialize: String;
var
  User: TlkJSONobject;
begin
  User := TlkJSONobject.Create();

  try
    User.Add('user_id', FId);

    User.Add('event', FEventTrack);

    Result := TlkJSON.GenerateText(User);
  finally
    User.Free;
  end;
end;

{ TLEFeedbackResponse }

function TLEFeedbackResponse.Serialize: String;
var
  User: TlkJSONobject;
begin
  User := TlkJSONobject.Create();

  try
    User.Add('user_id', FId);

    User.Add('text', FFeedbackResponse);

    Result := TlkJSON.GenerateText(User);
  finally
    User.Free;
  end;
end;

end.
