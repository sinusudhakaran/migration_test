unit BankLinkOnlineServices;

interface

uses
  BlopiServiceFacade,InvokeRegistry;

type
  TClientHelper = Class helper for BlopiServiceFacade.Client
  private
    function GetDeactivated: boolean;
    function GetClientConnectDays: string;
    function GetFreeTrialEndDate: TDateTime;
    function GetBillingEndDate: TDateTime;
    function GetUserOnTrial: boolean;
    function GetBillingFrequency: string;
    function GetUseClientDetails: boolean;
    function GetUserName: string;
    function GetEmailAddress: string;
  public
    procedure AddSubscription(AProductID: guid);
    property Deactivated: boolean read GetDeactivated;
    property ClientConnectDays: string read GetClientConnectDays; // 0 if client must always be online
    property FreeTrialEndDate: TDateTime read GetFreeTrialEndDate;
    property BillingEndDate: TDateTime read GetBillingEndDate;
    property UserOnTrial: boolean read GetUserOnTrial;
    property BillingFrequency: string read GetBillingFrequency;
    property UseClientDetails: boolean read GetUseClientDetails;
    property UserName: string read GetUserName;
    property EmailAddress: string read GetEmailAddress;
  End;

  TClientSummaryHelper = Class helper for BlopiServiceFacade.ClientSummary
  public
    procedure AddSubscription(AProductID: guid);
  End;

  TProductConfigService = class(TObject)
  private
    FPractice, FPracticeCopy: Practice;
    FRegisteredForBankLinkOnline: boolean;
    FListOfClients: ClientList;
    FClient: Client;
    procedure LoadDummyPractice;
    procedure CopyRemotableObject(ASource, ATarget: TRemotable);

    function DeletePracticeUser(const countryCode  : WideString;
                                const practiceCode : WideString;
                                const passwordHash : WideString;
                                const userId       : guid) : MessageResponse;
    function SavePracticeUser(const countryCode  : WideString;
                              const practiceCode : WideString;
                              const passwordHash : WideString;
                              const aUser        : User) : MessageResponse;
    function CreatePracticeUser(const countryCode  : WideString;
                                const practiceCode : WideString;
                                const passwordHash : WideString;
                                const newUser      : NewUser) : MessageResponseOfguid;
    function IsUserCreatedOnBankLinkOnline(const APractice : Practice;
                                           const AUserId   : Guid   = '';
                                           const AUserCode : string = ''): Boolean;
    function GetUseBankLinkOnline: Boolean;
    procedure SetUseBankLinkOnline(const Value: Boolean);
    procedure SaveRemotableObjectToFile(ARemotable: TRemotable);
    function LoadRemotableObjectFromFile(ARemotable: TRemotable): Boolean;
    procedure SetRegisteredForBankLinkOnline(const Value: Boolean);
    procedure LoadDummyClientList;
  public
    constructor Create;
    destructor Destroy; override;
    //Practice methods
    function GetPractice: Practice;
    function GetCatalogueEntry(AProductId: Guid): CatalogueEntry;
    function IsPracticeProductEnabled(AProductId: Guid): Boolean;
    function IsNotesOnlineEnabled: Boolean;
    function IsCICOEnabled: Boolean;
    function SavePractice: Boolean;
    procedure AddProduct(AProductId: Guid);
    procedure ClearAllProducts;
    procedure RemoveProduct(AProductId: Guid);
    procedure SelectAllProducts;
    procedure SetPrimaryContact(AUser: User);
    property UseBankLinkOnline: Boolean read GetUseBankLinkOnline write SetUseBankLinkOnline;
    property RegisteredForBankLinkOnline: Boolean read FRegisteredForBankLinkOnline write SetRegisteredForBankLinkOnline;
    //Client methods
    function AddClient: ClientSummary;
    function GetClientDetails(ClientID: WideString): Client;
    property Clients: ClientList read FListOfClients;
    //User methods
    function AddCreateUser(var   aUserId        : Guid;
                           const aEMail         : WideString;
                           const aFullName      : WideString;
                           const aRoleNames     : ArrayOfstring;
                           const aUserCode      : WideString;
                           var   aIsUserCreated : Boolean ) : Boolean;
    function DeleteUser(AUserId : Guid): Boolean;
    function IsPrimaryUser(const AUserId : Guid = ''): Boolean;
  end;

  //Product config singleton
  function ProductConfigService: TProductConfigService;

implementation

uses
  Globals, 
  SysUtils, 
  XMLIntf, 
  XMLDoc, 
  OPToSOAPDomConv,
  LogUtil,
  WarningMoreFrm,
  IniSettings,
  WebUtils;

Const
  UNIT_NAME = 'BankLinkOnlineServices';  

var
  __BankLinkOnlineServiceMgr: TProductConfigService;

function ProductConfigService: TProductConfigService;
begin
  if not Assigned(__BankLinkOnlineServiceMgr) then
    __BankLinkOnlineServiceMgr := TProductConfigService.Create;
  Result := __BankLinkOnlineServiceMgr;
end;

{ TProductConfigService }

procedure TProductConfigService.AddProduct(AProductId: Guid);
var
  i: integer;
  SubArray: ArrayOfGuid;
begin
  //Add product
  for i := Low(FPracticeCopy.Subscription) to High(FPracticeCopy.Subscription) do
    if AProductId = FPracticeCopy.Subscription[i] then
      Exit;
  //Add if still here
  SubArray := FPracticeCopy.Subscription;
  try
    SetLength(SubArray, Length(SubArray) + 1);
    SubArray[High(SubArray)] := AProductId;
  finally
    FPracticeCopy.Subscription := SubArray;
  end;
end;

procedure TProductConfigService.ClearAllProducts;
var
  i: integer;
  SubArray: ArrayOfGUID;
begin
  SubArray := FPracticeCopy.Subscription;
  try
    //Free subscription GUID's
    for i := Low(SubArray) to High(SubArray) do
      //Make sure no memory is left allocated
      SubArray[i] := '';
    SetLength(SubArray, 0);
  finally
    FPracticeCopy.Subscription := SubArray;
  end;
end;

procedure TProductConfigService.CopyRemotableObject(ASource,
  ATarget: TRemotable);
var
  Converter: IObjConverter;
  NodeObject: IXMLNode;
  NodeParent: IXMLNode;
  NodeRoot: IXMLNode;
  XML: IXMLDocument;
  XMLStr: WideString;
begin
  XML:= NewXMLDocument;
  NodeRoot:= XML.AddChild('Root');
  NodeParent:= NodeRoot.AddChild('Parent');
  Converter:= TSOAPDomConv.Create(NIL);
  NodeObject:= ASource.ObjectToSOAP(NodeRoot, NodeParent, Converter,
                                    'CopyObject', '', [ocoDontPrefixNode],
                                    XMLStr);
  ATarget.SOAPToObject(NodeRoot, NodeObject, Converter);
end;

constructor TProductConfigService.Create;
begin
  //Create practice
  FPractice := Practice.Create;
  //Load practice 
  if UseBankLinkOnline then
    if not LoadRemotableObjectFromFile(FPractice) then
      LoadDummyPractice;
  RegisteredForBankLinkOnline := UseBankLinkOnline;
  //Create clients
  LoadDummyClientList;
end;

destructor TProductConfigService.Destroy;
begin
  //Clear all created objects etc???
  FPracticeCopy.Free;
  FPractice.Free;
  inherited;
end;

function TProductConfigService.GetCatalogueEntry(
  AProductId: Guid): CatalogueEntry;
var
  i: integer;
begin
  Result :=  nil;
  for i := Low(FPractice.Catalogue) to High(FPractice.Catalogue) do begin
    if (AProductId = FPractice.Catalogue[i].Id) then begin
      Result := FPractice.Catalogue[i];
      Break;
    end;
  end;
end;

function TProductConfigService.GetClientDetails(ClientID: WideString): Client;
var
  i: integer;
  ClientArray: ArrayOfClientSummary;
begin
  Result := nil;
  ClientArray := FListOfClients.Clients;
  for i := Low(ClientArray) to High(ClientArray) do
  begin
    if (ClientArray[i].Id = ClientID) then
    begin
      // Result := ClientArray[i];
      // Do get client details using ClientArray[i].Id (replace below when Banklink Online is connected properly)
      Result := FClient;
      break;
    end;
  end;
end;

function TProductConfigService.GetPractice: Practice;
begin
  try
    //Test - make a copy for editing
    FPracticeCopy.Free;
    FPracticeCopy := Practice.Create;
    CopyRemotableObject(FPractice, FPracticeCopy);
    Result := FPracticeCopy;
    //Live
//    Result := GetIBlopiServiceFacade.GetPracticeDetail(CountryText(AdminSystem.fdFields.fdCountry),
//                                                       AdminSystem.fdFields.fdBankLink_Code,
//                                                       AdminSystem.fdFields.fdBankLink_Connect_Password);
  except
    on E : Exception do
      raise Exception.Create('BankLink Practice was unable to connect to BankLink Online. ' + #13#13 + E.Message );
  end;
end;

function TProductConfigService.GetUseBankLinkOnline: Boolean;
begin
  Result := False; 
  if Assigned(AdminSystem) then
    Result := AdminSystem.fdFields.fdUse_BankLink_Online;
end;

function TProductConfigService.AddClient: ClientSummary;
var
  SubArray: ArrayOfGuid;
  Guid1: TGuid;
  ClientArray: ArrayOfClientSummary;
begin
  ClientArray := FListOfClients.Clients;
  try
    SetLength(ClientArray, Length(ClientArray) + 1);
    ClientArray[High(ClientArray)] := ClientSummary.Create;
    CreateGUID(Guid1);
    ClientArray[High(ClientArray)].Id := GuidToString(Guid1);
    // ClientArray[High(ClientArray)].Subscription := SubArray;
  finally
     FListOfClients.Clients := ClientArray;
  end;
  Result := FListOfClients.Clients[High(FListOfClients.Clients)];
end;

procedure TProductConfigService.LoadDummyClientList;
begin
  FListOfClients := ClientList.Create;
  FListOfClients.Catalogue := FPractice.Catalogue;

  AddClient;
  if (High(FPractice.Subscription) <> - 1) then
    if Assigned(FListOfClients.Clients[0]) then
      ClientSummary(FListOfClients.Clients[0]).AddSubscription(FPractice.Subscription[0]);

  FClient := Client.Create;
  FClient.Id := FListOfClients.Clients[0].Id;
  FClient.Catalogue := FPractice.Catalogue;
  FClient.AddSubscription(FPractice.Subscription[0]);

  // add subscriptions to client
end;

procedure TProductConfigService.LoadDummyPractice;
var
  Cat: CatalogueEntry;
  CatArray: ArrayOfCatalogueEntry;
  UserArray: ArrayOfUser;
  SubArray: ArrayOfGuid;
  GUID: TGuid;
  AdminUser: User;
begin
  FPractice.DisplayName := 'practice';
  FPractice.DomainName := 'Domain';
  FPractice.EMail := 'scott.wilson@banklink.co.nz';
  FPractice.Phone := '555 5555';

  //Products and sevices
  CatArray := FPractice.Catalogue;
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

    //Auto Subscribe to these services
    SubArray := FPractice.Subscription;
    try
      CreateGUID(GUID);
      Cat := CatalogueEntry.Create;
      Cat.Id := GuidToString(GUID);
      Cat.CatalogueType := 'Service';
      Cat.Description := 'BankLink Notes Online';
      CatArray[2] := Cat;
      SetLength(SubArray, Length(SubArray) + 1);
      SubArray[High(SubArray)] := Cat.Id;

      CreateGUID(GUID);
      Cat := CatalogueEntry.Create;
      Cat.Id := GuidToString(GUID);
      Cat.CatalogueType := 'Service';
      Cat.Description := 'Send and Receive Client Files';
      CatArray[3] := Cat;
      SetLength(SubArray, Length(SubArray) + 1);
      SubArray[High(SubArray)] := Cat.Id;
    finally
      FPractice.Subscription := SubArray;
    end;

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
  try
    SetLength(UserArray, 2);

    CreateGUID(GUID);
    AdminUser := User.Create;
    AdminUser.Id := GuidToString(GUID);
    AdminUser.FullName := 'Andrew Will';
    UserArray[0] := AdminUser;

    CreateGUID(GUID);
    AdminUser := User.Create;
    AdminUser.Id := GuidToString(GUID);
    AdminUser.FullName := 'Scott Wilson';
    UserArray[1] := AdminUser;
  finally
    FPractice.Users := UserArray;
  end;

  //Set primary contact
  FPractice.DefaultAdminUserId := UserArray[1].Id;
end;

function TProductConfigService.LoadRemotableObjectFromFile(ARemotable: TRemotable): Boolean;
var
  Converter: IObjConverter;
  NodeObject: IXMLNode;
  NodeParent: IXMLNode;
  NodeRoot: IXMLNode;
  XML: IXMLDocument;
begin
  Result := False;
  if FileExists(ARemotable.ClassName + '.xml') then begin
    Converter:= TSOAPDomConv.Create(NIL);
    XML := NewXMLDocument;
    XML.LoadFromFile(ARemotable.ClassName + '.xml');
    NodeRoot := XML.ChildNodes.FindNode('Root');
    NodeParent := NodeRoot.ChildNodes.FindNode('Parent');
    NodeObject := NodeParent.ChildNodes.FindNode('CopyObject');
    ARemotable.SOAPToObject(NodeRoot, NodeObject, Converter);
    RegisteredForBankLinkOnline := True;
    Result := True;    
  end;
end;

function TProductConfigService.IsCICOEnabled: Boolean;
var
  i, j: integer;
  Cat: CatalogueEntry;
begin
  Result := False;
  if Assigned(FPracticeCopy) then begin
    for i := Low(FPracticeCopy.Catalogue) to High(FPracticeCopy.Catalogue) do begin
      Cat := FPracticeCopy.Catalogue[i];
      if Cat.Description = 'Send and Receive Client Files' then begin
        for j := Low(FPracticeCopy.Subscription) to High(FPracticeCopy.Subscription) do begin
          if FPracticeCopy.Subscription[j] = Cat.Id then begin
            Result := True;
            Break;
          end;
        end;
      end;
    end;
  end;
end;

function TProductConfigService.IsNotesOnlineEnabled: Boolean;
var
  i, j: integer;
  Cat: CatalogueEntry;
begin
  Result := False;
  if Assigned(FPracticeCopy) then begin
    for i := Low(FPracticeCopy.Catalogue) to High(FPracticeCopy.Catalogue) do begin
      Cat := FPracticeCopy.Catalogue[i];
      if Cat.Description = 'BankLink Notes Online' then begin
        for j := Low(FPracticeCopy.Subscription) to High(FPracticeCopy.Subscription) do begin
          if FPracticeCopy.Subscription[j] = Cat.Id then begin
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
  if Assigned(FPracticeCopy) then begin
    for i := Low(FPracticeCopy.Subscription) to High(FPracticeCopy.Subscription) do begin
      if FPracticeCopy.Subscription[i] = AProductID then begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

procedure TProductConfigService.RemoveProduct(AProductId: Guid);
var
  i, j: integer;
  SubArray: ArrayOfGuid;
  ClientsUsingProduct: integer;
  Msg: string;
  TempCatalogueEntry: CatalogueEntry;
begin
  ClientsUsingProduct := 1;
  //Check if any clients are using the product
//  for i := Low(FListOfClients.Clients) to Low(FListOfClients.Clients) do begin
//    for j := Low(Client.SubList) to High(Client.SubList) do begin
//      if AProductId = Client.SubList[j] then
//        Inc(ClientsUsingProduct);
//    end;
//  end;

  TempCatalogueEntry := GetCatalogueEntry(AProductId);
  if Assigned(TempCatalogueEntry) then begin
    if ClientsUsingProduct > 0 then begin
      Msg := Format('There are currently %d clients using %s. Please remove ' +
                    'access for these clients from this product before ' +
                    'disabling it',
                    [ClientsUsingProduct, TempCatalogueEntry.Description]);
      HelpfulWarningMsg(MSg, 0);
      Exit;
    end;
  end;     

  for i := Low(FPracticeCopy.Subscription) to High(FPracticeCopy.Subscription) do begin
    if AProductId = FPracticeCopy.Subscription[i] then begin
      SubArray := FPracticeCopy.Subscription;
      try
        if (i < 0) or (i > High(SubArray)) then
          Exit;
        for j := i to High(SubArray) - 1 do
          SubArray[j] := SubArray[j+1];
        SubArray[High(SubArray)] := '';
        SetLength(SubArray, Length(SubArray) - 1);
      finally
        FPracticeCopy.Subscription := SubArray;
      end;
    end;
  end;
end;

function TProductConfigService.SavePractice: Boolean;
begin
  Result := False;
  if UseBankLinkOnline then begin
    if Assigned(FPracticeCopy) then begin
      FPractice.Free;
      FPractice := Practice.Create;
      CopyRemotableObject(FPracticeCopy, FPractice);
      //Save to the web service
      SaveRemotableObjectToFile(FPractice);
      Result := True;
    end;
  end else begin
    FPractice.Free;
    FPractice := Practice.Create;
    LoadDummyPractice;
  end;
end;

procedure TProductConfigService.SaveRemotableObjectToFile(ARemotable: TRemotable);
var
  Converter: IObjConverter;
  NodeObject: IXMLNode;
  NodeParent: IXMLNode;
  NodeRoot: IXMLNode;
  XML: IXMLDocument;
  XMLStr: WideString;
begin
  XML:= NewXMLDocument;
  NodeRoot:= XML.AddChild('Root');
  NodeParent:= NodeRoot.AddChild('Parent');
  Converter:= TSOAPDomConv.Create(NIL);
  NodeObject:= ARemotable.ObjectToSOAP(NodeRoot, NodeParent, Converter,
                                       'CopyObject', '', [ocoDontPrefixNode],
                                       XMLStr);
  XML.SaveToFile(ARemotable.ClassName + '.xml');
end;

procedure TProductConfigService.SelectAllProducts;
var
  i: integer;
  Cat: CatalogueEntry;
  SubArray: ArrayOfGUID;
begin
  SubArray := FPracticeCopy.Subscription;
  try
    SetLength(SubArray, Length(FPracticeCopy.Catalogue));
    for i := Low(FPracticeCopy.Catalogue) to High(FPracticeCopy.Catalogue) do begin
      Cat := FPracticeCopy.Catalogue[i];
      SubArray[i] := Cat.Id;
    end;
  finally
    FPracticeCopy.Subscription := SubArray;
  end;
end;

procedure TProductConfigService.SetPrimaryContact(AUser: User);
begin
  FPracticeCopy.DefaultAdminUserId := AUser.Id;
end;

procedure TProductConfigService.SetRegisteredForBankLinkOnline(
  const Value: Boolean);
begin
  FRegisteredForBankLinkOnline := Value;
end;

procedure TProductConfigService.SetUseBankLinkOnline(const Value: Boolean);
begin
  if Assigned(AdminSystem) then
    AdminSystem.fdFields.fdUse_BankLink_Online := Value;
end;              

{ TClientHelper }

function TClientHelper.GetClientConnectDays: string;
begin
  Result := '90';
end;

function TClientHelper.GetDeactivated: boolean;
begin
  Result := true;
end;

function TClientHelper.GetEmailAddress: string;
begin
  Result := 'someone@somewhere.com';
end;

function TClientHelper.GetFreeTrialEndDate: TDateTime;
begin
  Result := StrToDate('31/12/2011');
end;

function TClientHelper.GetUseClientDetails: boolean;
begin
  Result := true;
end;

function TClientHelper.GetUserName: string;
begin
  Result := 'Joe Bloggs';
end;

function TClientHelper.GetUserOnTrial: boolean;
begin
  Result := false;
end;

procedure TClientHelper.AddSubscription(AProductID: guid);
var
  SubArray: arrayofguid;
  i: integer;
begin
  for i := Low(Subscription) to High(Subscription) do
    if (Subscription[i] = AProductID) then
      Exit;

  SubArray := Subscription;
  try
    SetLength(SubArray, Length(SubArray) + 1);
    SubArray[High(SubArray)] := AProductId;
  finally
    Subscription := SubArray;
  end;
end;

function TClientHelper.GetBillingEndDate: TDateTime;
begin
  Result := StrToDate('31/12/2011');
end;

function TClientHelper.GetBillingFrequency: string;
begin
  Result := 'Monthly';
end;

function TProductConfigService.DeletePracticeUser(const countryCode  : WideString;
                                                  const practiceCode : WideString;
                                                  const passwordHash : WideString;
                                                  const userId       : Guid) : MessageResponse;
var
  UserIndex : integer;
  DeleteIndex : integer;
  UserArray : ArrayOfUser;
begin
  Result := MessageResponse.Create;
  Result.Success := False;

  UserArray := FPractice.Users;

  if  (countryCode  = 'NZ')
  and (practiceCode = 'PRACTEST')
  and (passwordHash = '123') then
  begin
    // Find User to Delete
    DeleteIndex := -1;
    for UserIndex := 0 to high(UserArray) do
    begin
      if UserArray[UserIndex].Id = userId then
      begin
        DeleteIndex := UserIndex;
        Break;
      end;
    end;

    // If found Delete User
    if DeleteIndex > -1 then
    begin
      for UserIndex := high(UserArray) downto DeleteIndex+1 do
      begin
        UserArray[UserIndex-1] := UserArray[UserIndex];
      end;
      SetLength(UserArray, high(UserArray));
      Result.Success := True;
    end;
  end;

  if Result.Success = True then
    FPractice.Users := UserArray;
end;

function TProductConfigService.SavePracticeUser(const countryCode  : WideString;
                                                const practiceCode : WideString;
                                                const passwordHash : WideString;
                                                const aUser        : User) : MessageResponse;
var
  UserIndex : integer;
  UpdateIndex : integer;
  UserArray : ArrayOfUser;
begin
  Result := MessageResponse.Create;
  Result.Success := False;

  UserArray := FPractice.Users;

  if  (countryCode  = 'NZ')
  and (practiceCode = 'PRACTEST')
  and (passwordHash = '123') then
  begin
    // Find User to Update
    UpdateIndex := -1;
    for UserIndex := 0 to high(UserArray) do
    begin
      if UserArray[UserIndex].Id = aUser.Id then
      begin
        UpdateIndex := UserIndex;
        Break;
      end;
    end;

    if UpdateIndex > -1 then
    begin
      UserArray[UserIndex] := aUser;
      Result.Success := True;
    end;
  end;

  if Result.Success = True then
    FPractice.Users := UserArray;
end;

function TProductConfigService.CreatePracticeUser(const countryCode  : WideString;
                                                  const practiceCode : WideString;
                                                  const passwordHash : WideString;
                                                  const newUser      : NewUser) : MessageResponseOfguid;
var
  UserIndex : integer;
  UpdateIndex : integer;
  UserArray : ArrayOfUser;
  NewGuid : TGuid;
begin
  Result := MessageResponseOfguid.Create;
  Result.Success := False;

  UserArray := FPractice.Users;

  if  (countryCode  = 'NZ')
  and (practiceCode = 'PRACTEST')
  and (passwordHash = '123') then
  begin
    SetLength(UserArray, High(UserArray)+2);
    UserArray[High(UserArray)].EMail        := newUser.EMail;
    UserArray[High(UserArray)].FullName     := newUser.FullName;
    UserArray[High(UserArray)].RoleNames    := newUser.RoleNames;
    UserArray[High(UserArray)].Subscription := newUser.Subscription;
    UserArray[High(UserArray)].UserCode     := newUser.UserCode;

    CreateGuid(NewGuid);
    Result.Result := GuidtoString(NewGuid);
    UserArray[High(UserArray)].Id := Result.Result;

    Result.Success := True;
  end;

  if Result.Success = True then
    FPractice.Users := UserArray;
end;

function TProductConfigService.IsUserCreatedOnBankLinkOnline(const APractice : Practice;
                                                             const AUserId   : Guid   = '';
                                                             const AUserCode : string = '') : Boolean;
var
  UserIndex : Integer;
begin
  Result := False;

  for UserIndex := 0 to High(APractice.Users) do
  begin
    if (APractice.Users[UserIndex].Id       = AUserId)
    or (APractice.Users[UserIndex].UserCode = AUserCode) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TProductConfigService.AddCreateUser(var   aUserId        : Guid;
                                             const aEMail         : WideString;
                                             const aFullName      : WideString;
                                             const aRoleNames     : ArrayOfstring;
                                             const aUserCode      : WideString;
                                             var   aIsUserCreated : Boolean ) : Boolean;
var
  UpdateUser      : User;
  CreateUser      : NewUser;
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  MsgResponce     : MessageResponse;
  MsgResponceGuid : MessageResponseOfguid;
  ErrMsg          : String;
  ErrIndex        : integer;
  CurrPractice    : Practice;
  IsUserOnline    : Boolean;
begin
  Result := false;

  PracCountryCode := 'NZ';
  PracCode        := 'PRACTEST';
  PracPassHash    := '123';

  try
    CurrPractice := GetPractice;
    IsUserOnline := IsUserCreatedOnBankLinkOnline(CurrPractice, aUserId, aUserCode);
  except
    on E : Exception do
    begin
      LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running IsUserCreatedOnBankLinkOnline, Error Message : ' + E.Message);
      raise Exception.Create('BankLink Practice was unable to connect to BankLink Online. ' + #13#13 + E.Message );
    end;
  end;

  if IsUserOnline then
  begin
    UpdateUser := User.Create;
    UpdateUser.EMail        := aEMail;
    UpdateUser.FullName     := aFullName;
    UpdateUser.Id           := aUserId;
    UpdateUser.RoleNames    := aRoleNames;
    UpdateUser.Subscription := CurrPractice.Subscription;
    UpdateUser.UserCode     := aUserCode;

    try
      MsgResponce := SavePracticeUser(PracCountryCode, PracCode, PracPassHash, UpdateUser);
    except
      on E : Exception do
      begin
        LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running SavePracticeUser, Error Message : ' + E.Message);
        raise Exception.Create('BankLink Practice was unable to connect to BankLink Online. ' + #13#13 + E.Message );
      end;
    end;
      
    Result := MsgResponce.Success;
    if not Result then
    begin
      ErrMsg := '';
      for ErrIndex := 0 to high(MsgResponce.ErrorMessages) do
        ErrMsg := ErrMsg + #13 + MsgResponce.ErrorMessages[ErrIndex].ErrorCode + ' : ' +
                           MsgResponce.ErrorMessages[ErrIndex].Message_;
      if not (ErrMsg = '') then
        ErrMsg := #13 + ErrMsg;

      LogUtil.LogMsg(lmError, UNIT_NAME, 'Server Error running SavePracticeUser, Error Message : ' + ErrMsg);  
      raise Exception.Create('BankLink Practice was unable to create ' + UpdateUser.FullName +
                             ' on BankLink Online. ' + ErrMsg );
    end;

    aIsUserCreated := false;
  end
  else
  begin
    CreateUser := NewUser.Create;
    CreateUser.EMail        := aEMail;
    CreateUser.FullName     := aFullName;
    CreateUser.RoleNames    := aRoleNames;
    CreateUser.Subscription := CurrPractice.Subscription;
    CreateUser.UserCode     := aUserCode;

    try
      MsgResponceGuid := CreatePracticeUser(PracCountryCode, PracCode, PracPassHash, CreateUser);
    except
      on E : Exception do
      begin
        LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running CreatePracticeUser, Error Message : ' + E.Message);
        raise Exception.Create('BankLink Practice was unable to connect to BankLink Online. ' + #13#13 + E.Message );
      end;
    end;
    Result  := MsgResponceGuid.Success;
    aUserId := MsgResponceGuid.Result;
      
    if not Result then
    begin
      ErrMsg := '';
      for ErrIndex := 0 to high(MsgResponce.ErrorMessages) do
        ErrMsg := ErrMsg + #13 + MsgResponce.ErrorMessages[ErrIndex].ErrorCode + ' : ' +
                           MsgResponce.ErrorMessages[ErrIndex].Message_;
      if not (ErrMsg = '') then
        ErrMsg := #13 + ErrMsg;

      LogUtil.LogMsg(lmError, UNIT_NAME, 'Server Error running CreatePracticeUser, Error Message : ' + ErrMsg);
      raise Exception.Create('BankLink Practice was unable to update ' + CreateUser.FullName +
                             ' on BankLink Online. ' + ErrMsg );
    end;

    aIsUserCreated := True;
  end;
end;

function TProductConfigService.DeleteUser(AUserId: Guid) : Boolean;
var
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  MsgResponce     : MessageResponse;
  ErrMsg          : String;
  ErrIndex        : integer;
begin
  Result := false;

  PracCountryCode := 'NZ';
  PracCode        := 'PRACTEST';
  PracPassHash    := '123';

  try
    MsgResponce := DeletePracticeUser(PracCountryCode, PracCode, PracPassHash, AUserId);
    Result := MsgResponce.Success;
  except
    on E : Exception do
    begin
      LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running DeletePracticeUser, Error Message : ' + E.Message);
      raise Exception.Create('BankLink Practice was unable to connect to BankLink Online. ' + #13#13 + E.Message );
    end;
  end;

  if not Result then
  begin
    ErrMsg := '';
    for ErrIndex := 0 to high(MsgResponce.ErrorMessages) do
      ErrMsg := ErrMsg + #13 + MsgResponce.ErrorMessages[ErrIndex].ErrorCode + ' : ' +
                         MsgResponce.ErrorMessages[ErrIndex].Message_;
    if not (ErrMsg = '') then
      ErrMsg := #13 + ErrMsg;

    LogUtil.LogMsg(lmError, UNIT_NAME, 'Server Error running DeletePracticeUser, Error Message : ' + ErrMsg);
    raise Exception.Create('BankLink Practice was unable to delete user ' +
                           ' from BankLink Online. ' + ErrMsg );
  end;
end;

function TProductConfigService.IsPrimaryUser(const AUserId : Guid): Boolean;
var
  currPractice : Practice;
begin
  currPractice := GetPractice;
  Result := (AUserId = currPractice.DefaultAdminUserId);
end;

{ TClientSummaryHelper }

procedure TClientSummaryHelper.AddSubscription(AProductID: guid);
var
  SubArray: arrayofguid;
  i: integer;
begin
  for i := Low(Subscription) to High(Subscription) do
    if (Subscription[i] = AProductID) then
      Exit;

  SubArray := Subscription;
  try
    SetLength(SubArray, Length(SubArray) + 1);
    SubArray[High(SubArray)] := AProductId;
  finally
    Subscription := SubArray;
  end;
end;

end.
