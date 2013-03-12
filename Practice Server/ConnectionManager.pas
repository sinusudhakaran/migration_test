unit ConnectionManager;

interface

uses
  Windows, SysUtils, ExtCtrls, LogUtil, Contnrs, IdContext, Common;

type
  TConnectionManager = class sealed
  private
    FConnections: TObjectList;
    
    function GetConnection(Index: Integer): TConnectionRecord;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure AddConnection(Identifier: ULongLong; Context: TIdContext);
    procedure RemoveConnection(Context: TIdContext); overload;
    procedure RemoveConnection(Connection: TConnectionRecord); overload;
    
    function FindConnection(Context: TIdContext): TConnectionRecord;

    procedure Clear;
    
    property Count: Integer read GetCount;
    property Connections[Index: Integer]: TConnectionRecord read GetConnection; default;
  end;
  
implementation

{ TStatisticsManager }

procedure TConnectionManager.AddConnection(Identifier: ULongLong; Context: TIdContext);
begin
  FConnections.Add(TConnectionRecord.Create(Identifier, Context));  
end;

procedure TConnectionManager.Clear;
begin
  FConnections.Clear;
end;

constructor TConnectionManager.Create;
begin
  FConnections := TObjectList.Create(True);
end;

destructor TConnectionManager.Destroy;
begin
  FConnections.Free;
  
  inherited;
end;

function TConnectionManager.FindConnection(Context: TIdContext): TConnectionRecord;
var
  Index: Integer;
  ConnectionRecord: TConnectionRecord;
begin
  Result := nil;
  
  for Index := 0 to FConnections.Count - 1 do
  begin
    ConnectionRecord := TConnectionRecord(FConnections[Index]);
     
    if ConnectionRecord.Context = Context then
    begin
      Result := ConnectionRecord; 

      Break; 
    end;
  end; 
end;

function TConnectionManager.GetConnection(Index: Integer): TConnectionRecord;
begin
  Result := TConnectionRecord(FConnections[Index]);
end;

function TConnectionManager.GetCount: Integer;
begin
  Result := FConnections.Count;
end;

procedure TConnectionManager.RemoveConnection(Connection: TConnectionRecord);
begin
  FConnections.Remove(Connection); 
end;

procedure TConnectionManager.RemoveConnection(Context: TIdContext);
var
  Index: Integer;
begin
  for Index := 0 to FConnections.Count - 1 do
  begin
    if TConnectionRecord(FConnections[Index]).Context = Context then
    begin
      FConnections.Delete(Index);

      Break; 
    end;
  end;
end;

end.
