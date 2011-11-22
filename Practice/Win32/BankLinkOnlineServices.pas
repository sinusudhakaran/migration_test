unit BankLinkOnlineServices;

interface

uses
  BlopiServiceFacade,InvokeRegistry;

type
  TProductConfigService = class(TObject)
  private
    FPractice: Practice;
    FPracticeCopy: Practice;
    FUseBankLinkOnline: Boolean;
    FRegisteredForBankLinkOnline: Boolean;
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
                                const aUser        : User) : MessageResponseOfguid;
    procedure SetUseBankLinkOnline(const Value: Boolean);
    procedure SaveRemotableObjectToFile(ARemotable: TRemotable);
    function LoadRemotableObjectFromFile(ARemotable: TRemotable): Boolean;
    procedure SetRegisteredForBankLinkOnline(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    //Practice methods
    function GetPractice: Practice;
    function IsPracticeProductEnabled(AProductId: Guid): Boolean;
    function IsNotesOnlineEnabled: Boolean;
    function SavePractice: Boolean;
    procedure AddProduct(AProductId: Guid);
    procedure ClearAllProducts;
    procedure RemoveProduct(AProductId: Guid);
    procedure SelectAllProducts;
    procedure SetPrimaryContact(AUser: User);
    property UseBankLinkOnline: Boolean read FUseBankLinkOnline write SetUseBankLinkOnline;
    property RegisteredForBankLinkOnline: Boolean read FRegisteredForBankLinkOnline write SetRegisteredForBankLinkOnline;
    //Client methods
    //User methods
    function AddCreateUser(var   aUserId        : Guid;
                           const aEMail         : WideString;
                           const aFullName      : WideString;
                           const aRoleNames     : ArrayOfstring;
                           const aSubscription  : ArrayOfguid;
                           const aUserCode      : WideString;
                           var   aIsUserCreated : Boolean ) : Boolean;
    function DeleteUser(AUserId : Guid): Boolean;
    function IsUserCreatedOnBankLinkOnline(AUserId   : Guid   = '';
                                           AUserCode : string = ''): Boolean;
  end;

  //Product config singleton
  function ProductConfigService: TProductConfigService;

implementation

uses
  Globals, SysUtils, XMLIntf, XMLDoc, OPToSOAPDomConv;

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
  if not LoadRemotableObjectFromFile(FPractice) then
    LoadDummyPractice;
  FUseBankLinkOnline := False;
  //Create client list
    //Create clients
end;

destructor TProductConfigService.Destroy;
begin
  //Clear all created objects etc???
  FPracticeCopy.Free;
  FPractice.Free;
  inherited;
end;

function TProductConfigService.GetPractice: Practice;
begin
  //Make a copy for editing
  FPracticeCopy.Free;
  FPracticeCopy := Practice.Create;
  CopyRemotableObject(FPractice, FPracticeCopy);
  Result := FPracticeCopy;
end;

procedure TProductConfigService.LoadDummyPractice;
var
  Cat: CatalogueEntry;
  CatArray: ArrayOfCatalogueEntry;
  UserArray: ArrayOfUser;
  GUID: TGuid;
  AdminUser: User;
begin
  FPractice.DisplayName := 'practice';

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
begin
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
var
  i, j: integer;
  TempUser: User;
  UserRoles: ArrayofString;
begin
  for i := Low(FPracticeCopy.Users) to High(FPracticeCopy.Users) do begin
    TempUser := FPracticeCopy.Users[i];
    UserRoles := TempUser.RoleNames;
    try
      if (TempUser = AUser) then begin
        //Primary contact
        SetLength(UserRoles, 1);
        UserRoles[0] := 'Primary Contact';
      end else begin
        //Normal user
        for j := Low(UserRoles) to High(UserRoles) do
          UserRoles[j] := '';
        SetLength(UserRoles, 0);
      end;
    finally
      TempUser.RoleNames := UserRoles;
    end;
  end;
end;

procedure TProductConfigService.SetRegisteredForBankLinkOnline(
  const Value: Boolean);
begin
  FRegisteredForBankLinkOnline := Value;
end;

procedure TProductConfigService.SetUseBankLinkOnline(const Value: Boolean);
begin
  FUseBankLinkOnline := Value;
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


    UserArray[UserIndex] := aUser;
    Result.Success := True;
  end;

  if Result.Success = True then
    FPractice.Users := UserArray;
end;

function TProductConfigService.CreatePracticeUser(const countryCode  : WideString;
                                                  const practiceCode : WideString;
                                                  const passwordHash : WideString;
                                                  const aUser        : User) : MessageResponseOfguid;
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
    UserArray[High(UserArray)] := aUser;
    CreateGuid(NewGuid);

    Result.Result := GuidtoString(NewGuid);
    UserArray[High(UserArray)].Id := Result.Result;
    Result.Success := True;
  end;

  if Result.Success = True then
    FPractice.Users := UserArray;
end;

function TProductConfigService.AddCreateUser(var   aUserId        : Guid;
                                             const aEMail         : WideString;
                                             const aFullName      : WideString;
                                             const aRoleNames     : ArrayOfstring;
                                             const aSubscription  : ArrayOfguid;
                                             const aUserCode      : WideString;
                                             var   aIsUserCreated : Boolean ) : Boolean;
var
  varUser         : User;
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  MsgResponce     : MessageResponse;
  MsgResponceGuid : MessageResponseOfguid;
  ErrMsg          : String;
  ErrIndex        : integer;
begin
  Result := false;

  PracCountryCode := 'NZ';
  PracCode        := 'PRACTEST';
  PracPassHash    := '123';

  varUser := User.Create;
  varUser.EMail        := aEMail;
  varUser.FullName     := aFullName;
  varUser.Id           := aUserId;
  varUser.RoleNames    := aRoleNames;
  varUser.Subscription := aSubscription;
  varUser.UserCode     := aUserCode;

  try
    if IsUserCreatedOnBankLinkOnline(aUserId, aUserCode) then
    begin
      MsgResponce := SavePracticeUser(PracCountryCode, PracCode, PracPassHash, varUser);
      Result := MsgResponce.Success;
      if not Result then
      begin
        ErrMsg := '';
        for ErrIndex := 0 to high(MsgResponce.ErrorMessages) do
          ErrMsg := ErrMsg + #13 + MsgResponce.ErrorMessages[ErrIndex].ErrorCode + ' : ' +
                             MsgResponce.ErrorMessages[ErrIndex].Message_;
        if not (ErrMsg = '') then
          ErrMsg := #13 + ErrMsg;

        raise Exception.Create( 'BankLink Practice was unable to create ' + varUser.FullName +
                                ' on BankLink Online. ' + ErrMsg );
      end;

      aIsUserCreated := false;
    end
    else
    begin
      MsgResponceGuid := CreatePracticeUser(PracCountryCode, PracCode, PracPassHash, varUser);
      Result := MsgResponceGuid.Success;
      aUserId := MsgResponceGuid.Result;

      if not Result then
      begin
        ErrMsg := '';
        for ErrIndex := 0 to high(MsgResponce.ErrorMessages) do
          ErrMsg := ErrMsg + #13 + MsgResponce.ErrorMessages[ErrIndex].ErrorCode + ' : ' +
                             MsgResponce.ErrorMessages[ErrIndex].Message_;
        if not (ErrMsg = '') then
          ErrMsg := #13 + ErrMsg;

        raise Exception.Create( 'BankLink Practice was unable to update ' + varUser.FullName +
                                ' on BankLink Online. ' + ErrMsg );
      end;

      aIsUserCreated := True;
    end;
  except
    on E : Exception do
      raise Exception.Create( 'BankLink Practice was unable to connect to BankLink Online. ' + #13#13 + E.Message );
  end;
end;

function TProductConfigService.DeleteUser(AUserId: Guid) : Boolean;
var
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  MsgResponce     : MessageResponse;
begin
  Result := false;

  PracCountryCode := 'NZ';
  PracCode        := 'PRACTEST';
  PracPassHash    := '123';

  MsgResponce := DeletePracticeUser(PracCountryCode, PracCode, PracPassHash, AUserId);
  Result := MsgResponce.Success;
end;

function TProductConfigService.IsUserCreatedOnBankLinkOnline(AUserId   : Guid   = '';
                                                             AUserCode : string = '') : Boolean;
var
  currPractice : Practice;
  UserIndex : Integer;
begin
  Result := False;
  currPractice := GetPractice;

  for UserIndex := 0 to High(currPractice.Users) do
  begin
    if (currPractice.Users[UserIndex].Id       = AUserId)
    or (currPractice.Users[UserIndex].UserCode = AUserCode) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

end.
