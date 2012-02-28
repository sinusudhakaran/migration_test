unit BanklinkOnlineSettingsFrm;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  CheckLst,
  OSFont,
  BankLinkOnlineServices;

type

  TfrmBanklinkOnlineSettings = class(TForm)
    grpProductAccess: TGroupBox;
    lblSelectProducts: TLabel;
    btnSelectAll: TButton;
    btnClearAll: TButton;
    grpBillingFrequency: TGroupBox;
    lblNextBillingFrequency: TLabel;
    grpDefaultClientAdministrator: TGroupBox;
    chkUseClientDetails: TCheckBox;
    lblUserName: TLabel;
    lblEmailAddress: TLabel;
    edtUserName: TEdit;
    edtEmailAddress: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    chklistProducts: TCheckListBox;
    cmbBillingFrequency: TComboBox;
    grpClientAccess: TGroupBox;
    rbActive: TRadioButton;
    rbSuspended: TRadioButton;
    rbDeactivated: TRadioButton;
    lblClientConnect: TLabel;
    cmbConnectDays: TComboBox;
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnClearAllClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rbSuspendedClick(Sender: TObject);
    procedure CheckClientConnectControls;
    procedure rbActiveClick(Sender: TObject);
    procedure rbDeactivatedClick(Sender: TObject);
    procedure chkUseClientDetailsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  protected
    procedure FillClientDetails;

    procedure SetStatus(aStatus : TBloStatus);
    function GetStatus : TBloStatus;
    procedure UpdateClientWebFormat;
  public
    function Execute : boolean;

    procedure LoadClientInfo;
    procedure SaveClientInfo;
    property Status : TBloStatus read GetStatus write SetStatus;
  end;

  function EditBanklinkOnlineSettings : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  Globals,
  LogUtil,
  RegExprUtils,
  BkConst,
  SysUtils,
  Variants,
  MailFrm,
  YesNoDlg,
  Files,
  StrUtils;

const
  UnitName = 'BanklinkOnlineSettingsFrm';

var
  BanklinkOnlineConnected : boolean = true;

//------------------------------------------------------------------------------
function EditBanklinkOnlineSettings : boolean;
var
  BanklinkOnlineSettings: TfrmBanklinkOnlineSettings;
const
  ThisMethodName = 'EditBanklinkOnlineSettings';
begin
  Result := False;
  if not Assigned(MyClient) then
    Exit;

  if not Assigned(MyClient.BlopiClientNew) and
     not MyClient.BlopiClientChanged then begin
    //Get Practice details (so we can load the list of available products)
    ProductConfigService.GetPractice;
    if (not Assigned(ProductConfigService.CachedPractice)) or
       (not ProductConfigService.ValidBConnectDetails) then
      Exit;
    //Get client list (so that we can lookup the client code)
    ProductConfigService.LoadClientList;
    //Get client details
    MyClient.RefreshBlopiClient;
    if not Assigned(MyClient.BlopiClientDetail) and
       not Assigned(MyClient.BlopiClientNew) then
    begin
      MyClient.BlopiClientNew := TBloClientCreate.Create;
      MyClient.CopyPracticeClientNew;
      ProductConfigService.CreateNewClient(MyClient.BlopiClientNew);

      MyClient.RefreshBlopiClient;
    end;
  end;

  if not (Assigned(MyClient.BlopiClientNew) or Assigned(MyClient.BlopiClientDetail)) then
  begin
    MyClient.BlopiClientNew := TBloClientCreate.Create;
    DoClientSave(false, MyClient);
  end;
  if Assigned(MyClient.BlopiClientNew) or Assigned(MyClient.BlopiClientDetail) then begin
    BanklinkOnlineSettings := TfrmBanklinkOnlineSettings.Create(Application.MainForm);
    try
      Result := BanklinkOnlineSettings.Execute;
      if Result then
      begin
        ProductConfigService.LoadClientList;

        //Update access
        // BanklinkOnlineSettings.SaveClientInfo;
      end;
    finally
      BanklinkOnlineSettings.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.btnOKClick(Sender: TObject);
var
  EmailChanged, ProductsChanged, ProductFound: boolean;
  NewProducts, ProductsRemoved: TStringList;
  PromptMessage, ErrorMsg, NewUserName, NewEmail, MailTo, MailSubject, MailBody: string;
  i, j, ButtonPressed: integer;
  ClientStatus : TBloStatus;
  MaxOfflineDays : String;
  BillingFrequency : WideString;
  MyUserCreate: TBloUserCreate;
  BlankSubscription: TBloArrayOfGuid;
  TheCreateClient: TBloClientCreate;
begin
  EmailChanged := False;
  ProductsChanged := False;

  if (Trim(edtUserName.Text) = '') then
  begin
    ShowMessage('You must enter a user name. Please try again');
    ModalResult := mrNone;
    Exit;
  end;

  if not RegExIsEmailValid(edtEmailAddress.Text) then
  begin
    ShowMessage('You must enter a valid e-mail address. Please try again');
    ModalResult := mrNone;
    Exit;
  end;

  if not BanklinkOnlineConnected then
  begin
    ErrorMsg := 'Banklink Practice is unable to connect to Banklink Online and so ' +
                'cannot update this client''s settings';
    ShowMessage(ErrorMsg);
    LogUtil.LogMsg(lmError, UnitName, ErrorMsg);
    ModalResult := mrNone;
    Exit;
  end;

  ButtonPressed := mrOk;

  if Assigned(MyClient.BlopiClientDetail) then
    ClientStatus := MyClient.BlopiClientDetail.Status
  else if Assigned(MyClient.BlopiClientNew) then
    ClientStatus := MyClient.BlopiClientNew.Status;

  if (ClientStatus <> staActive) and rbActive.Checked
    then ButtonPressed := AskYesNo('Resuming client',
                                   'You are about to resume this Client on ' +
                                   'Banklink Online. They will be able to access BankLink Online as per ' +
                                   'normal.' + #10#10 + 'Are you sure you want to continue?',
                                   DLG_YES, 0, false)
  else if (ClientStatus <> staSuspended) and rbSuspended.Checked
    then ButtonPressed := AskYesNo('Suspending client',
                                   'You are about to suspend this Client from BankLink ' +
                                   'Online. They will be able to access BankLink Online in read-only mode.' +
                                   #10#10 + 'Are you sure you want to continue?',
                                   DLG_YES, 0, false)
  else if (ClientStatus <> staDeactivated) and rbDeactivated.Checked
    then ButtonPressed := AskYesNo('Deactivating client',
                                   'You are about to deactivate this Client from BankLink ' +
                                   'Online. All user log-ins will be disabled.' + #10#10 +
                                   'Are you sure you want to continue?',
                                   DLG_YES, 0, false)
  else
  begin
    if Assigned(MyClient.BlopiClientDetail) then
      if Length(MyClient.BlopiClientDetail.Users) > 0 then
        EmailChanged := (edtEmailAddress.Text <> TBloUserRead(MyClient.BlopiClientDetail.Users[0]).EMail);

    NewProducts := TStringList.Create;
    ProductsRemoved := TStringList.Create;
    for i := 0 to chklistProducts.Count - 1 do
    begin
      ProductFound := false;
      if Assigned(MyClient.BlopiClientDetail) then
      begin
        for j := 0 to High(MyClient.BlopiClientDetail.Subscription) do
        begin
          if (TBloCatalogueEntry(chklistProducts.Items.Objects[i]).Id = MyClient.BlopiClientDetail.Subscription[j]) then
          begin
            ProductFound := true;
            break
          end;
        end;
      end;
      if (chklistProducts.Checked[i] = true) and not ProductFound then
        NewProducts.Add(chklistProducts.Items[i])
      else if (chklistProducts.Checked[i] = false) and ProductFound then
        ProductsRemoved.Add(chklistProducts.Items[i]);
    end;

    if (BillingFrequency = 'A') then
      BillingFrequency := 'Annually'
    else if (BillingFrequency = 'M') then
      BillingFrequency := 'Monthly';

    if Assigned(MyClient.BlopiClientDetail) then
    begin
      BillingFrequency := MyClient.BlopiClientDetail.BillingFrequency;
      MaxOfflineDays := IntToStr(MyClient.BlopiClientDetail.MaxOfflineDays);
    end
    else if Assigned(MyClient.BlopiClientNew) then
    begin
      BillingFrequency := MyClient.BlopiClientNew.BillingFrequency;
      MaxOfflineDays := IntToStr(MyClient.BlopiClientNew.MaxOfflineDays);
    end;

    ProductsChanged := NewProducts.Count > 0;
    if (EmailChanged and ProductsChanged) then
    begin
      PromptMessage := 'Are you sure you want to update the following for ' +
                       edtUserName.text + ':' + #10#10 +
                       'Activate the following products & services:' + #10 +
                       Trim(NewProducts.Text) + #10#10 + 'Change the Default Client ' +
                       'Administrator Email Address. The new Default Client ' +
                       'Adminstrator will be sent to ' + edtEmailAddress.Text + '.';
      ButtonPressed := AskYesNo('Changing client details',
                                PromptMessage, DLG_YES, 0, false);
    end
    else if EmailChanged then
      ButtonPressed := AskYesNo('Changing Default Administrator Address',
                                'You have changed the Default Client Administrator Email Address. ' +
                                'The new Default Client Administrator will be set to ' +
                                'â€˜' + edtEmailAddress.Text + 'â€™.' + #10 + #10 +
                                'Are you sure you want to continue?',
                                DLG_YES, 0, false)
    else if ProductsChanged then
      ButtonPressed := AskYesNo('Reactiving products',
                                'Are you sure you want to activate the following products:' + #10#10 +
                                NewProducts.Text + #10 +
                                'By clicking ''OK'' you are confirming that you wish to activate these products ' +
                                'for ' + edtUserName.Text,
                                DLG_YES, 0, false);
  end;
  if ButtonPressed in [mrNo, mrCancel] then
    ModalResult := mrNone
  else
  begin
    NewUserName := edtUserName.Text;
    NewEmail := edtEmailAddress.Text;
    if Assigned(MyClient.BlopiClientDetail) then
      MyClient.BlopiClientDetail.UpdateAdminUser(NewUserName, NewEmail);

    if ProductsChanged then
    begin
      // Send email to support
      MailTo := whSupportEmail[AdminSystem.fdFields.fdCountry];
      MailSubject := 'Banklink Online product and service updates (' + AdminSystem.fdFields.fdBankLink_Code + ')';
      MailBody := 'This practice has changed its Banklink Online product and service settings' + #10#10 +
                  'Practice Name: ' + AdminSystem.fdFields.fdPractice_Name_for_Reports + #10 +
                  'Practice Code: ' + AdminSystem.fdFields.fdBankLink_Code + #10#10 +
                  'The BankLink Online Administrator (Primary Contact) for the practice' + #10 +
                  'Name: ' + edtUserName.text + #10 +
                  // Can't find phone number... do we have this at all for the practice administrator?
                  'Email Address: ' + edtEmailAddress.text + #10#10 +
                  'Updated settings:' + #10;
      for i := 0 to NewProducts.Count - 1 do
        MailBody := MailBody + NewProducts[i] + ' is now enabled' + #10;
      for i := 0 to ProductsRemoved.Count - 1 do
        MailBody := MailBody + ProductsRemoved[i] + ' is now disabled' + #10;
      MailBody := MailBody + #10 +
                     'Product and service settings:' + #10;
      for i := 0 to chklistProducts.Count - 1 do
      begin
        MailBody := MailBody + chklistProducts.Items[i] + ' - ';
        if chklistProducts.Checked[i] then
          MailBody := MailBody + 'enabled' + #10
        else
          MailBody := MailBody + 'disabled' + #10;
      end;
      SendMailTo('Email to Support', MailTo, MailSubject, MailBody);
    end;                                                            

    ModalResult := mrOk;

    if Assigned(MyClient.BlopiClientNew) then
    begin
      //Create new client admin user
      MyUserCreate := TBloUserCreate.Create;
      try
        MyUserCreate.FullName := edtUserName.Text;
        MyUserCreate.EMail    := edtEmailAddress.Text;
        MyUserCreate.AddRoleName('Client Administrator');
        MyUserCreate.UserCode := MyClient.BlopiClientDetail.ClientCode;
        SetLength(BlankSubscription, 0);
        MyUserCreate.Subscription := BlankSubscription;
        MyClient.CopyPracticeClientNew;
      finally
        FreeAndNil(TheCreateClient);
        FreeAndNil(MyUserCreate);
      end;
    end;

    SaveClientInfo;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.btnSelectAllClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to chkListProducts.Items.Count - 1 do
    chkListProducts.Checked[i] := true;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.CheckClientConnectControls;
begin
  lblClientConnect.Enabled := rbActive.Checked;
  cmbConnectDays.Enabled := rbActive.Checked;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.chkUseClientDetailsClick(Sender: TObject);
begin
  FillClientDetails;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.SetStatus(aStatus : TBloStatus);
begin
  case aStatus of
    staActive      : rbActive.Checked := true;
    staSuspended   : rbSuspended.Checked := true;
    staDeactivated : rbDeactivated.Checked := true;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.UpdateClientWebFormat;
var
  NotesId : TBloGuid;
begin
  if not assigned(MyClient.BlopiClientDetail) then
    Exit;

  NotesId := ProductConfigService.GetNotesId;
  if MyClient.BlopiClientDetail.HasSubscription(NotesId) then
  begin
    if MyClient.clFields.clWeb_Export_Format <> wfWebNotes then
      MyClient.clFields.clWeb_Export_Format := wfWebNotes;
  end
  else
  begin
    if MyClient.clFields.clWeb_Export_Format = wfWebNotes then
      MyClient.clFields.clWeb_Export_Format := wfNone;
  end;
end;

//------------------------------------------------------------------------------
function TfrmBanklinkOnlineSettings.GetStatus : TBloStatus;
begin
  if rbActive.Checked then
    Result := staActive
  else if rbSuspended.Checked then
    Result := staSuspended
  else // if rbDeactivated.Checked then
    Result := staDeactivated
end;

//------------------------------------------------------------------------------
function TfrmBanklinkOnlineSettings.Execute : boolean;
begin
  Result := False;

  LoadClientInfo;

  if ShowModal = mrOk then
    Result := True;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.LoadClientInfo;
var
  ProdIndex     : integer;
  SubIndex      : integer;
  ProductGuid   : TBloGuid;
  ClientSubGuid : TBloGuid;
  CatEntry      : TBloCatalogueEntry;
begin
  //Load products
  chklistProducts.Clear;
  // Adds the Subscriptions/Products for the Practice to the List
  for ProdIndex := Low(ProductConfigService.ProductList) to High(ProductConfigService.ProductList) do
  begin
    ProductGuid := ProductConfigService.ProductList[ProdIndex];
    CatEntry := ProductConfigService.GetCatalogueEntry(ProductGuid);

    chklistProducts.AddItem(CatEntry.Description, CatEntry);
  end;

  // Existing Client
  if Assigned(MyClient.BlopiClientDetail) then
  begin
    Status := MyClient.BlopiClientDetail.Status;
    if (MyClient.BlopiClientDetail.MaxOfflineDays = 0) then
      cmbConnectDays.Text := 'Always'
    else
      cmbConnectDays.Text := IntToStr(MyClient.BlopiClientDetail.MaxOfflineDays) + ' days';
    cmbConnectDays.SelLength := 0;
    if MyClient.BlopiClientDetail.BillingFrequency = 'M' then
      cmbBillingFrequency.Text := 'Monthly'
    else if MyClient.BlopiClientDetail.BillingFrequency = 'A' then
      cmbBillingFrequency.Text := 'Annually'
    else
      cmbBillingFrequency.Text := MyClient.BlopiClientDetail.BillingFrequency; // shouldn't ever need this line
    cmbBillingFrequency.SelLength := 0;
    chkUseClientDetails.Checked := false;

    // Checks the Products that Client Subscribes to
    for ProdIndex := 0 to chklistProducts.Items.Count - 1 do
    begin
      for SubIndex := Low(MyClient.BlopiClientDetail.Subscription) to
                      High(MyClient.BlopiClientDetail.Subscription) do
      begin
        ClientSubGuid := MyClient.BlopiClientDetail.Subscription[SubIndex];
        ProductGuid   := TBloCatalogueEntry(chklistProducts.Items.Objects[ProdIndex]).id;
        chklistProducts.Checked[ProdIndex] := (ClientSubGuid = ProductGuid);
        if chklistProducts.Checked[ProdIndex] then
          break;
      end;
    end;

    if (Length(MyClient.BlopiClientDetail.Users) > 0) then
    begin
      edtUserName.Text := TBloUserRead(MyClient.BlopiClientDetail.Users[0]).FullName;
      edtEmailAddress.Text := TBloUserRead(MyClient.BlopiClientDetail.Users[0]).Email;
    end;
  end
  // New Client
  else if Assigned(MyClient.BlopiClientNew) then
  begin
    Status := MyClient.BlopiClientNew.Status;
    if (MyClient.BlopiClientNew.MaxOfflineDays = 0) then
      cmbConnectDays.Text := 'Always'
    else
      cmbConnectDays.Text := IntToStr(MyClient.BlopiClientNew.MaxOfflineDays) + ' days';
    if MyClient.BlopiClientNew.BillingFrequency = 'M' then
      cmbBillingFrequency.Text := 'Monthly'
    else if MyClient.BlopiClientNew.BillingFrequency = 'A' then
      cmbBillingFrequency.Text := 'Annually'
    else
      cmbBillingFrequency.Text := 'Monthly'; // default value
    cmbBillingFrequency.SelLength := 0;
    cmbConnectDays.SelLength := 0;
    chkUseClientDetails.Checked := False;

    // Checks the Products that Client Subscribes to
    for ProdIndex := 0 to chklistProducts.Items.Count - 1 do
    begin
      for SubIndex := Low(MyClient.BlopiClientNew.Subscription) to
                      High(MyClient.BlopiClientNew.Subscription) do
      begin
        ClientSubGuid := MyClient.BlopiClientNew.Subscription[SubIndex];
        ProductGuid   := TBloCatalogueEntry(chklistProducts.Items.Objects[ProdIndex]).id;
        chklistProducts.Checked[ProdIndex] := (ClientSubGuid = ProductGuid);
        if chklistProducts.Checked[ProdIndex] then
          break;
      end;
    end;

    edtUserName.Text := MyClient.clFields.clContact_Name;
    edtEmailAddress.Text := MyClient.clFields.clClient_EMail_Address;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.SaveClientInfo;
var
  ProdIndex : integer;
  CatEntry  : TBloCatalogueEntry;
  ConnectDays : string;
begin
  // Existing Client
  if Assigned(MyClient.BlopiClientDetail) then
  begin
    MyClient.BlopiClientDetail.Status := Status;
    MyClient.BlopiClientDetail.BillingFrequency := AnsiLeftStr(cmbBillingFrequency.Text, 1);
    ConnectDays := StringReplace(cmbConnectDays.Text, 'Always', '0', [rfReplaceAll]);
    ConnectDays := StringReplace(ConnectDays, ' days', '', [rfReplaceAll]);
    MyClient.BlopiClientDetail.MaxOfflineDays := StrToInt(ConnectDays);
    MyClient.BlopiClientDetail.Subscription := Nil;

    for ProdIndex := 0 to chklistProducts.Count - 1 do
    begin
      if chklistProducts.Checked[ProdIndex] then
      begin
        CatEntry := TBloCatalogueEntry(chklistProducts.Items.Objects[ProdIndex]);
        MyClient.BlopiClientDetail.AddSubscription(CatEntry.id);
      end;
    end;

    MyClient.BlopiClientDetail.UpdateAdminUser(edtUserName.Text,
                                               edtEmailAddress.Text);

    if Assigned(MyClient.BlopiClientDetail.Users) then
      // Temporarily passing in the email address while waiting for a change request to go through, as
      // BlopiInterface.CreateClientUser requires the user to have one
      ProductConfigService.SaveClient(MyClient.BlopiClientDetail, edtEmailAddress.Text);
  end;

  // New Client
  if Assigned(MyClient.BlopiClientNew) then
  begin
    MyClient.BlopiClientNew.Status := Status;
    MyClient.BlopiClientNew.BillingFrequency := AnsiLeftStr(cmbBillingFrequency.Text, 1);
    ConnectDays := StringReplace(cmbConnectDays.Text, 'Always', '0', [rfReplaceAll]);
    ConnectDays := StringReplace(ConnectDays, ' days', '', [rfReplaceAll]);
    MyClient.BlopiClientNew.MaxOfflineDays := StrToInt(ConnectDays);
    MyClient.BlopiClientNew.Subscription := Nil;

    for ProdIndex := 0 to chklistProducts.Count - 1 do
    begin
      if chklistProducts.Checked[ProdIndex] then
      begin
        CatEntry := TBloCatalogueEntry(chklistProducts.Items.Objects[ProdIndex]);
        MyClient.BlopiClientNew.AddSubscription(CatEntry.id);
      end;
    end;
  end;

  UpdateClientWebFormat;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.btnClearAllClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to chkListProducts.Items.Count - 1 do
    chkListProducts.Checked[i] := false;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.FillClientDetails;
begin
  if (chkUseClientDetails.Checked) then
  begin
    edtUserName.Text := MyClient.clFields.clContact_Name;
    edtEmailAddress.Text := MyClient.clFields.clClient_EMail_Address;
  end;
  edtUserName.Enabled := not chkUseClientDetails.Checked;
  edtEmailAddress.Enabled := not chkUseClientDetails.Checked;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.FormShow(Sender: TObject);
begin
  FillClientDetails;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.rbActiveClick(Sender: TObject);
begin
  CheckClientConnectControls;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.rbDeactivatedClick(Sender: TObject);
begin
  CheckClientConnectControls;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.rbSuspendedClick(Sender: TObject);
begin
  CheckClientConnectControls;
end;

end.


