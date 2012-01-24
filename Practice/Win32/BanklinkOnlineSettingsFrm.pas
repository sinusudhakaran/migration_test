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
    SubArray: ArrayOfGuid;
  protected
    procedure FillClientDetails;

    procedure SetStatus(aStatus : TStatus);
    function GetStatus : TStatus;
//    FContactName, FEmailAddress: string;
  public
//    procedure SetContactName(Value: string);
//    procedure SetEmailAddress(Value: string);
    function Execute : boolean;

    procedure LoadClientInfo;
    procedure SaveClientInfo;
    property Status : TStatus read GetStatus write SetStatus;
  end;

  // function to create BanklinkOnlineSettingsFrm goes here
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
  MailFrm;

const
  UnitName = 'BanklinkOnlineSettingsFrm';

var
  frmBanklinkOnlineSettings: TfrmBanklinkOnlineSettings;
  BanklinkOnlineConnected : boolean = true;

//------------------------------------------------------------------------------
function EditBanklinkOnlineSettings : boolean;
var
  i: integer;
  BanklinkOnlineSettings: TfrmBanklinkOnlineSettings;
  SuccessMessage: string;
const
  ThisMethodName = 'EditBanklinkOnlineSettings';
begin
  Result := False;
  if AdminSystem.fdFields.fdUse_BankLink_Online then
  begin
    ProductConfigService.LoadClientList;
    BanklinkOnlineSettings := TfrmBanklinkOnlineSettings.Create(Application.MainForm);
    try
      Result := BanklinkOnlineSettings.Execute;
      if Result then begin
        //Update access
        BanklinkOnlineSettings.SaveClientInfo;

        SuccessMessage := 'Settings for ' + MyClient.clFields.clCode +
                          'have been successfully updated to Banklink Online';
        ShowMessage(SuccessMessage);
        LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' - ' + SuccessMessage);
      end;
    finally
      BanklinkOnlineSettings.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.btnOKClick(Sender: TObject);
var
  EmailChanged, ProductsChanged, BillingFrequencyChanged, ProductFound: boolean;
  NewProducts, ProductsRemoved: TStringList;
  PromptMessage, ErrorMsg, NewUserName, NewEmail, MailTo, MailSubject, MailBody: string;
  i, j, ButtonPressed: integer;

  ClientStatus : TStatus;
  BillingFrequency : WideString;
begin
  EmailChanged := False;
  ProductsChanged := False;
  BillingFrequencyChanged := False;

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

  if (ClientStatus = staSuspended) and not rbSuspended.Checked
    then ButtonPressed := MessageDlg('You are about to resume this Client on ' +
                     'Banklink Online. They will be able to access BankLink Online as per ' +
                     'normal.' + #13#10#10 + 'Are you sure you want to continue?',
                     mtConfirmation, [mbYes, mbNo], 0)
  else if (ClientStatus <> staSuspended) and rbSuspended.Checked
    then ButtonPressed := MessageDlg('You are about to suspend this Client from BankLink ' +
                     'Online. They will be able to access BankLink Online in read-only mode.' +
                     #13#10#10 + 'Are you sure you want to continue?',
                     mtConfirmation, [mbYes, mbNo], 0)
  else if (ClientStatus <> staDeactivated) and rbDeactivated.Checked
    then ButtonPressed := MessageDlg('You are about to deactivate this Client from BankLink ' +
                     'Online. All user log-ins will be disabled.' + #13#10#10 +
                     'Are you sure you want to continue?',
                     mtConfirmation, [mbYes, mbNo], 0)
  else if (ClientStatus = staDeactivated) and not rbDeactivated.Checked
    then ButtonPressed := MessageDlg('You are about to re-activate this Client from BankLink ' +
                     'Online. All user log-ins will be enabled.' + #13#10#10 +
                     'Are you sure you want to continue?',
                     mtConfirmation, [mbYes, mbNo], 0)
  else
  begin
    if Assigned(MyClient.BlopiClientDetail) then
      if Length(MyClient.BlopiClientDetail.Users) > 0 then
        EmailChanged := (edtEmailAddress.Text <> UserDetail(MyClient.BlopiClientDetail.Users[0]).EMail);

    NewProducts := TStringList.Create;
    ProductsRemoved := TStringList.Create;
    for i := 0 to chklistProducts.Count - 1 do
    begin
      ProductFound := false;
      for j := 0 to High(SubArray) do
      begin
        if (WideString(chklistProducts.Items.Objects[i]) = SubArray[j]) then
        begin
          ProductFound := true;
          break
        end;
      end;
      if (chklistProducts.Checked[i] = true) and not ProductFound then
        NewProducts.Add(chklistProducts.Items[i])
      else if (chklistProducts.Checked[i] = false) and ProductFound then
        ProductsRemoved.Add(chklistProducts.Items[i]);


      {if chklistProducts.Checked[i] then
      begin
        for j := 0 to High(SubArray) do
        begin
          if (WideString(chklistProducts.Items.Objects[i]) = SubArray[j]) then
          begin
            ProductFound := true;
            break
          end;
        end;
        if not ProductFound then
          NewProducts.Add(chklistProducts.Items[i]);
      end; }

    end;

    if Assigned(MyClient.BlopiClientDetail) then
      BillingFrequency := MyClient.BlopiClientDetail.BillingFrequency
    else if Assigned(MyClient.BlopiClientNew) then
      BillingFrequency := MyClient.BlopiClientNew.BillingFrequency;

    ProductsChanged := NewProducts.Count > 0;
    BillingFrequencyChanged := cmbBillingFrequency.Text <> BillingFrequency;

    if EmailChanged and not (ProductsChanged or BillingFrequencyChanged) then
      ButtonPressed := MessageDlg('You have changed the Default Client Administrator Email Address. ' +
                  'The new Default Client Administrator will be set to ' +
                  '‘' + edtEmailAddress.Text + '’.' + #10 + #10 +
                  'Are you sure you want to continue?', mtConfirmation, [mbYes, mbNo], 0)
    else if ProductsChanged and not (EmailChanged or BillingFrequencyChanged) then
      ButtonPressed := MessageDlg('Are you sure you want to activate the following products:' + #13#10 +
                  NewProducts.Text + #13#10#10 +
                  'By clicking ''OK'' you are confirming that you wish to activate these products ' +
                  'for ' + edtUserName.Text, mtConfirmation, [mbYes, mbNo], 0)
    else if BillingFrequencyChanged and not (ProductsChanged or EmailChanged) then
      ButtonPressed := MessageDlg('You have changed this Client''s billing frequency. Your next ' +
                  'invoice for this Client will be for the period...', // fill in later
                  mtConfirmation, [mbYes, mbNo], 0)
    else if (EmailChanged or ProductsChanged or BillingFrequencyChanged) then // will reach and trigger this if two or more have changed
    begin
      PromptMessage := 'Are you sure you want to update the following for ' +
                       edtUserName.text + ':';
      if ProductsChanged then
        PromptMessage := PromptMessage + #13#10#10 + 'Activate the following products & services:' +
                         #13#10 + Trim(NewProducts.Text);
      if BillingFrequencyChanged then
        PromptMessage := PromptMessage + #13#10#10 + 'Change this Client''s billing ' +
                         'frequency. Your next invoice for this Client will be for ' +
                         'the period...'; // fill in later
      if EmailChanged then
        PromptMessage := PromptMessage + #13#10#10 + 'Change the Default Client ' +
                         'Administrator Email Address. The new Default Client ' +
                         'Adminstrator will be sent to ' + edtEmailAddress.Text + '.';
      ButtonPressed := MessageDlg(PromptMessage, mtConfirmation, [mbYes, mbNo], 0);
    end;
  end;
  if ButtonPressed = mrNo then
    ModalResult := mrNone
  else
  begin
    // Update client with data from fields
//    UserDetail(FClient.Users[0]).FullName := edtUserName.Text;
//    UserDetail(FClient.Users[0]).EMail := edtEmailAddress.Text;

    NewUserName := edtUserName.Text;
    NewEmail := edtEmailAddress.Text;
    MyClient.BlopiClientDetail.UpdateAdminUser(NewUserName, NewEmail);
    // MyClient.BlopiClientDetail.UseClientDetails := chkUseClientDetails.Checked;

    if ProductsChanged then
    begin
      // Send email to support
      MailTo := whSupportEmail[AdminSystem.fdFields.fdCountry];
      MailSubject := 'Banklink Online product and service updates (' + AdminSystem.fdFields.fdBankLink_Code + ')';
      MailBody := 'This practice has changed its Banklink Online product and service settings' + #13#10#10 +
                  'Practice Name: ' + AdminSystem.fdFields.fdPractice_Name_for_Reports + #13#10 +
                  'Practice Code: ' + AdminSystem.fdFields.fdBankLink_Code + #13#10#10 +
                  'The BankLink Online Administrator (Primary Contact) for the practice' + #13#10 +
                  'Name: ' + edtUserName.text + #13#10 +
                  // Can't find phone number... do we have this at all for the practice administrator?
                  'Email Address: ' + edtEmailAddress.text + #13#10#10 +
                  'Updated settings:' + #13#10;
      for i := 0 to NewProducts.Count - 1 do
        MailBody := MailBody + NewProducts[i] + ' is now enabled' + #13#10;
      for i := 0 to ProductsRemoved.Count - 1 do
        MailBody := MailBody + ProductsRemoved[i] + ' is now disabled' + #13#10;
      MailBody := MailBody + #10 +
                     'Product and service settings:' + #13#10;
      for i := 0 to chklistProducts.Count - 1 do
      begin
        MailBody := MailBody + chklistProducts.Items[i] + ' - ';
        if chklistProducts.Checked[i] then
          MailBody := MailBody + 'enabled' + #13#10
        else
          MailBody := MailBody + 'disabled' + #13#10;
      end;
    end;
    SendMailTo('Email to Support', MailTo, MailSubject, MailBody);

    ModalResult := mrOk;
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
procedure TfrmBanklinkOnlineSettings.SetStatus(aStatus : TStatus);
begin
  case aStatus of
    staActive      : rbActive.Checked := true;
    staSuspended   : rbSuspended.Checked := true;
    staDeactivated : rbDeactivated.Checked := true;
  end;
end;

//------------------------------------------------------------------------------
function TfrmBanklinkOnlineSettings.GetStatus : TStatus;
begin
  if rbActive.Checked then
    Result := staActive
  else if rbSuspended.Checked then
    Result := staSuspended
  else if rbDeactivated.Checked then
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
  PracDetail    : PracticeDetail;
  ProductGuid   : Guid;
  ClientSubGuid : Guid;
  CatEntry      : CatalogueEntry;
begin
  //Load products
  PracDetail := ProductConfigService.GetPractice;
  if Not Assigned(PracDetail) then
    Exit;

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
    cmbConnectDays.Text := MyClient.BlopiClientDetail.ClientConnectDays;
    //chkUseClientDetails.Checked := MyClient.BlopiClientDetail.UseClientDetails;
    chkUseClientDetails.Checked := false;

    // Checks the Products that Client Subscribes to
    for ProdIndex := 0 to chklistProducts.Items.Count - 1 do
    begin
      for SubIndex := Low(MyClient.BlopiClientDetail.Subscription) to
                      High(MyClient.BlopiClientDetail.Subscription) do
      begin
        ClientSubGuid := MyClient.BlopiClientDetail.Subscription[SubIndex];
        ProductGuid   := CatalogueEntry(chklistProducts.Items.Objects[ProdIndex]).id;

        chklistProducts.Checked[ProdIndex] := (ClientSubGuid = ProductGuid);

        if chklistProducts.Checked[ProdIndex] then
          break;
      end;
    end;

    if (not (chkUseClientDetails.Checked)) and
       (high(MyClient.BlopiClientDetail.Users) > -1) then
    begin
      edtUserName.Text := UserDetail(MyClient.BlopiClientDetail.Users[0]).FullName;
      edtEmailAddress.Text := UserDetail(MyClient.BlopiClientDetail.Users[0]).Email;
    end else
    begin
      edtUserName.Text := MyClient.clFields.clContact_Name;
      edtEmailAddress.Text := MyClient.clFields.clClient_EMail_Address;
    end;
  end
  // New Client
  else if Assigned(MyClient.BlopiClientNew) then
  begin
    Status := MyClient.BlopiClientNew.Status;
    cmbConnectDays.Text := '0';
    chkUseClientDetails.Checked := False;

    // Checks the Products that Client Subscribes to
    for ProdIndex := 0 to chklistProducts.Items.Count - 1 do
    begin
      chklistProducts.Checked[ProdIndex] := True;
    end;

    edtUserName.Text := MyClient.clFields.clContact_Name;
    edtEmailAddress.Text := MyClient.clFields.clClient_EMail_Address;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.SaveClientInfo;
var
  ProdIndex : integer;
begin
  if Assigned(MyClient.BlopiClientDetail) then
  begin
    MyClient.BlopiClientDetail.Status := Status;
    MyClient.BlopiClientDetail.Subscription := Nil;

    for ProdIndex := 0 to chklistProducts.Count - 1 do
      if chklistProducts.Checked[ProdIndex] then
        MyClient.BlopiClientDetail.AddSubscription(WideString(chklistProducts.Items.Objects[ProdIndex]));

    MyClient.BlopiClientDetail.UpdateAdminUser(edtUserName.Text,
                                               edtEmailAddress.Text);
  end
  else if Assigned(MyClient.BlopiClientNew) then
  begin
    MyClient.BlopiClientNew.Status := Status;
    MyClient.BlopiClientDetail.Subscription := Nil;

    for ProdIndex := 0 to chklistProducts.Count - 1 do
      if chklistProducts.Checked[ProdIndex] then
        MyClient.BlopiClientNew.AddSubscription(WideString(chklistProducts.Items.Objects[ProdIndex]));

    MyClient.BlopiClientDetail.UpdateAdminUser(edtUserName.Text,
                                               edtEmailAddress.Text);
  end;
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
//  ListOfClients.Free;
//  chklistProducts.Clear;
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

//procedure TfrmBanklinkOnlineSettings.SetContactName(Value: string);
//begin
//  FContactName := Value;
//end;

//procedure TfrmBanklinkOnlineSettings.SetEmailAddress(Value: string);
//begin
//  FEmailAddress := Value;
//end;

end.
