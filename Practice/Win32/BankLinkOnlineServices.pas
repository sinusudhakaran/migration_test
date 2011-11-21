unit BankLinkOnlineServices;

interface

uses
  BlopiServiceFacade;

type
  TProductConfigService = class(TObject)
  private
    FPractice: Practice;
    procedure ClearAllSubscriptions(var ASubscriptions: ArrayOfGUID);
    procedure ClearCatalogue(var ACatalogue: ArrayOfCatalogueEntry);
    procedure ClearUsers(var AUsers: ArrayOfUser);
    procedure LoadDummyPractice;
    procedure SelectAllSubscriptions(var ASubscriptions: ArrayOfGUID);
  public
    constructor Create;
    destructor Destroy; override;
    //Practice methods
    function GetPractice: Practice;
    function IsPracticeProductEnabled(AProductId: Guid): Boolean;
    function IsPracticeRegisteredForBankLinkOnline: Boolean;
    function IsNotesOnlineEnabled: Boolean;
    procedure AddProduct(AProductId: Guid);
    procedure ClearAllProducts;
    procedure RemoveProduct(AProductId: Guid);
    procedure SelectAllProducts;
    //Client methods
    //User methods
  end;

  //Product config singleton
  function ProductConfigService: TProductConfigService;

implementation

uses
  SysUtils;

var
  __BankLinkOnlineServiceMgr: TProductConfigService;

function ProductConfigService: TProductConfigService;
begin
  if not Assigned(__BankLinkOnlineServiceMgr) then
    __BankLinkOnlineServiceMgr := TProductConfigService.Create;
  Result := __BankLinkOnlineServiceMgr;
end;

{ TProductConfigService }

procedure TProductConfigService.ClearCatalogue(var ACatalogue: ArrayOfCatalogueEntry);
var
  i: integer;
begin
  //Free catalogue entries
  for i := Low(ACatalogue) to High(ACatalogue) do begin
    //Make sure no memory is left allocated
    if Assigned(ACatalogue[i]) then
      CatalogueEntry(ACatalogue[i]).Free;
    ACatalogue[i] := nil;
  end;
  SetLength(ACatalogue, 0);
end;

procedure TProductConfigService.ClearAllSubscriptions(
  var ASubscriptions: ArrayOfGUID);
var
  i: integer;
begin
  //Free subscription GUID's
  for i := Low(ASubscriptions) to High(ASubscriptions) do
    //Make sure no memory is left allocated
    ASubscriptions[i] := '';
  SetLength(ASubscriptions, 0);
end;

procedure TProductConfigService.AddProduct(AProductId: Guid);
var
  i: integer;
  SubArray: ArrayOfGuid;
begin
  //Add product
  for i := Low(FPractice.Subscription) to High(FPractice.Subscription) do
    if AProductId = FPractice.Subscription[i] then
      Exit;
  //Add if still here
  SubArray := FPractice.Subscription;
  try
    SetLength(SubArray, Length(SubArray) + 1);
    SubArray[High(SubArray)] := AProductId;
  finally
    FPractice.Subscription := SubArray;
  end;
end;

procedure TProductConfigService.ClearAllProducts;
var
  SubArray: ArrayOfGUID;
begin
  SubArray := FPractice.Subscription;
  try
    ClearAllSubscriptions(SubArray);
  finally
    FPractice.Subscription := SubArray;
  end;
end;

procedure TProductConfigService.ClearUsers(var AUsers: ArrayOfUser);
var
  i: integer;
begin
  //Free the users
  for i := Low(AUsers) to High(AUsers) do begin
    //Make sure no memory is left allocated
    if Assigned(AUsers[i]) then
      User(AUsers[i]).Free;
    AUsers[i] := nil;
  end;
  SetLength(AUsers, 0);
end;

constructor TProductConfigService.Create;
begin
  //Create practice
  FPractice := Practice.Create;
  LoadDummyPractice;
  //Create client list
    //Create clients
end;

destructor TProductConfigService.Destroy;
begin
  //Clear all created objects etc???
  FPractice.Free;
  inherited;
end;

function TProductConfigService.GetPractice: Practice;
begin
  Result := FPractice;
end;

procedure TProductConfigService.LoadDummyPractice;
var
  i: integer;
  Cat: CatalogueEntry;
  CatArray: ArrayOfCatalogueEntry;
  UserArray: ArrayOfUser;
  GUID: TGuid;
  AdminUser: User;
begin
  FPractice.DisplayName := 'practice';

  //Products and sevices
  CatArray := FPractice.Catalogue;
  ClearCatalogue(CatArray);
  try
    SetLength(CatArray, 11);
    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Product';
    Cat.Description := 'WagesPlus';
    CatArray[0] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Product';
    Cat.Description := 'InvoicePlus';
    CatArray[1] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Notes Online';
    CatArray[2] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[3] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[4] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[5] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[6] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[7] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[8] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[9] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[10] := Cat;
  finally
    FPractice.Catalogue := CatArray;
  end;

  //Practice users
  UserArray := FPractice.Users;
  ClearUsers(UserArray);
  try
    SetLength(UserArray, 2);

    AdminUser := User.Create;
    AdminUser.FullName := 'Andrew Will';
    UserArray[0] := AdminUser;

    AdminUser := User.Create;
    AdminUser.FullName := 'Scott Wilson';
    UserArray[1] := AdminUser;
  finally
    FPractice.Users := UserArray;
  end;
end;

function TProductConfigService.IsNotesOnlineEnabled: Boolean;
var
  i, j: integer;
  SubArray: ArrayOfGuid;
  Cat: CatalogueEntry;
begin
  Result := False;
  if Assigned(FPractice) then begin
    for i := Low(FPractice.Catalogue) to High(FPractice.Catalogue) do begin
      Cat := FPractice.Catalogue[i];
      if Cat.Description = 'BankLink Notes Online' then begin
        for j := Low(FPractice.Subscription) to High(FPractice.Subscription) do begin
          if FPractice.Subscription[j] = Cat.Id then begin
            Result := True;
            Break;
          end;
        end;
      end;
    end;
  end;
end;

function TProductConfigService.IsPracticeProductEnabled(
  AProductId: Guid): Boolean;
var
  i: integer;
begin
  Result := False;
  if Assigned(FPractice) then begin
    for i := Low(FPractice.Subscription) to High(FPractice.Subscription) do begin
      if FPractice.Subscription[i] = AProductID then begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function TProductConfigService.IsPracticeRegisteredForBankLinkOnline: Boolean;
begin
  Result := True;
//  Result := False;  
end;

procedure TProductConfigService.RemoveProduct(AProductId: Guid);
var
  i, j: integer;
  SubArray: ArrayOfGuid;
begin
  for i := Low(FPractice.Subscription) to High(FPractice.Subscription) do
    if AProductId = FPractice.Subscription[i] then begin
      SubArray := FPractice.Subscription;
      try
        if (i < 0) or (i > High(SubArray)) then
          Exit;
        for j := i to High(SubArray) - 1 do
          SubArray[j] := SubArray[j+1];
        SubArray[High(SubArray)] := '';
        SetLength(SubArray, Length(SubArray) - 1);
      finally
        FPractice.Subscription := SubArray;
      end;
    end;
end;

procedure TProductConfigService.SelectAllProducts;
var
  SubArray: ArrayOfGUID;
begin
  SubArray := FPractice.Subscription;
  try
    SelectAllSubscriptions(SubArray);
  finally
    FPractice.Subscription := SubArray;
  end;
end;

procedure TProductConfigService.SelectAllSubscriptions(
  var ASubscriptions: ArrayOfGUID);
var
  i: integer;
  Cat: CatalogueEntry;
begin
  SetLength(ASubscriptions, Length(FPractice.Catalogue));
  for i := Low(FPractice.Catalogue) to High(FPractice.Catalogue) do begin
    Cat := FPractice.Catalogue[i];
    ASubscriptions[i] := Cat.Id;
  end;
end;

end.
