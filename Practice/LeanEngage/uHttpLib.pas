unit uHttpLib;

interface

uses
  Classes, StrUtils, uLKJSON;

type
  TJsonObject = class abstract
  public
    procedure Deserialize(Json: String); virtual; abstract;
    function Serialize: String; virtual; abstract;
  end;

  TDynamicJsonObject = class(TJsonObject)
  private
    FJsonObject: TlkJSONobject;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Deserialize(Json: String); override;
    function Serialize: String; override;

    procedure Add(Name: String; Value: String);
  end;

  TUrlParams = class
  private
    FParams: TStrings;
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure Add(Name, Value: String);
    procedure Clear;

    function FillParams(EndPoint: String): String;
  end;

  THttpLib = class
  public
    class function MakeUrl(BaseUrl, EndPoint: String; Params: TUrlParams = nil): String;
//    class function ParseUrlParams(const aUrl : string; Params: TUrlParams): String;
  end;

implementation

{ TUrlParams }

procedure TUrlParams.Add(Name, Value: String);
begin
  FParams.Add('{' + Name + '}' + ':' + Value);
end;

procedure TUrlParams.Clear;
begin
  FParams.Clear;
end;

constructor TUrlParams.Create;
begin
  FParams := TStringList.Create;

  FParams.NameValueSeparator := ':';
end;

destructor TUrlParams.Destroy;
begin
  FParams.Free;
  
  inherited;
end;

function TUrlParams.FillParams(EndPoint: String): String;
var
  Index: Integer;
begin
  for Index := 0 to FParams.Count - 1 do
  begin
    if Pos(FParams.Names[Index], EndPoint) > 0 then
    begin
      EndPoint := ReplaceStr(EndPoint, FParams.Names[Index], FParams.ValueFromIndex[Index]);
    end;
  end;

  Result := EndPoint;
end;

{ THttpLib }

class function THttpLib.MakeUrl(BaseUrl, EndPoint: String; Params: TUrlParams): String;
begin
  if (Length(BaseUrl) = 0) and (Length(EndPoint) = 0) then
  begin
    Result := '';

    Exit;
  end;

  if Params <> nil then
  begin
    EndPoint := Params.FillParams(EndPoint);
  end;

  if (BaseUrl[Length(BaseUrl)] <> '/') and (EndPoint[1] <> '/') then
  begin
    Result := BaseUrl + '/' + EndPoint;

    Exit;
  end;

  if (BaseUrl[Length(BaseUrl)] = '/') and (EndPoint[1] = '/') then
  begin
    Result := Copy(BaseUrl, 0, Length(BaseUrl) -1) + EndPoint;

    Exit;
  end;

  Result := BaseUrl + EndPoint;
end;


(*
class function THttpLib.ParseUrlParams(const aUrl : string; Params: TUrlParams): String;
var
  i : integer;
  TempS : string;
begin
  i := pos( '&', aUrl);
  if i > 0 then begin
    Params.Clear;

    Params
  end;
end;
*)

{ TDynamicJsonObject }

procedure TDynamicJsonObject.Add(Name, Value: String);
begin
  FJsonObject.Add(Name, Value);
end;

constructor TDynamicJsonObject.Create;
begin
  FJsonObject := TlkJSONobject.Create();
end;

procedure TDynamicJsonObject.Deserialize(Json: String);
var
  Obj: TlkJSONbase;
begin
  Obj := TlkJSON.ParseText(Json);
  if Obj is TlkJSONobject then
  begin
    FJsonObject.Free;
    FJsonObject := Obj as TlkJSONobject;
  end;
end;

destructor TDynamicJsonObject.Destroy;
begin
  FJsonObject.Free;
  
  inherited;
end;

function TDynamicJsonObject.Serialize: String;
begin
  Result := TlkJSON.GenerateText(FJsonObject);
end;

end.
