unit UXlsDBTemplateStore;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}

interface

uses
  DB, SysUtils, Classes, XlsBaseTemplateStore, contnrs, XlsMessages;

type
  TNamedStorageList= class
    Name: string;
    StList: TXlsStorageList;
    constructor Create( const aName: string; const aStList: TXlsStorageList);
    destructor Destroy;override;
  end;

  TStorageListCache = class(TObjectList)
    {$INCLUDE TStorageListCacheHdr.inc}
  end;

  TXlsDBTemplateStore = class(TXlsBaseTemplateStore)
  private
    FDataSet: TDataSet;
    FNameField: TField;
    FDataField: TBlobField;

    StorageCache: TStorageListCache;
    { Private declarations }
  protected
    function GetStorages(Name: string): TXlsStorageList;override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
    procedure ClearCache;
    function IsUpToDate: boolean;override;
    procedure Refresh; override;
    { Public declarations }
  published
    property DataSet: TDataSet read FDataSet write FDataSet;
    property NameField: TField read FNameField write FNameField;
    property DataField: TBlobField read FDataField write FDataField;
    { Published declarations }
  end;

procedure Register;
implementation
{$R XlsDBTemplateStore.res}

{$INCLUDE TStorageListCacheImp.inc}

procedure Register;
begin
  RegisterComponents('FlexCel', [TXlsDBTemplateStore]);
end;

constructor TNamedStorageList.Create( const aName: string; const aStList: TXlsStorageList);
begin
  inherited Create;
  Name:=aName;
  StList:=aStList;
end;

destructor TNamedStorageList.Destroy;
begin
  FreeAndNil(StList);
  inherited;
end;


constructor TXlsDBTemplateStore.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  StorageCache:= TStorageListCache.Create;
end;

destructor TXlsDBTemplateStore.Destroy;
begin
  FreeAndNil(StorageCache);
  inherited;
end;

procedure TXlsDBTemplateStore.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FDataSet then
        FDataSet:= nil;
    if AComponent = FNameField then
        FNameField:= nil;
    if AComponent = FDataField then
        FDataField:= nil;
  end;
end;

function TXlsDBTemplateStore.GetStorages(Name: string): TXlsStorageList;
var
  k: integer;
  Sl:TXlsStorageList;
  Ms: TMemoryStream;
begin
  if StorageCache.Find(Name, k) then
  begin
    Result:= StorageCache[k].StList;
    exit;
  end;

  //This is an unoptimized routine and should be only used as an example
  //In 'real world' you should use an sql dataset, and fetch only the report needed
  DataSet.Open;
  try
    if not Assigned(DataSet) then raise Exception.Create(ErrNoDataSet);
    DataSet.First;
    while not DataSet.Eof do
    begin
      if FNameField.Value= Name then
      begin
        Sl:=TXlsStorageList.Create;
        try
          Ms:=TMemoryStream.Create;
          try
            FDataField.SaveToStream (Ms);
            Ms.Position:=0;
            Sl.ReadData(Ms);
          finally
            FreeAndNil(Ms);
          end;
          StorageCache.Add(TNamedStorageList.Create(Name, Sl));
        except
          FreeAndNil(Sl);
          raise;
        end; //except;

        Result:=Sl;
        exit;
      end;
      DataSet.Next;
    end;
  finally
    DataSet.Close;
  end; //finally

  raise Exception.CreateFmt(ErrReportNotFound, [Name]);
end;

procedure TXlsDBTemplateStore.ClearCache;
begin
  StorageCache.Clear;
end;

function TXlsDBTemplateStore.IsUpToDate: boolean;
begin
  Result:=true;
end;

procedure TXlsDBTemplateStore.Refresh;
begin
  //Not implemented
end;

end.
