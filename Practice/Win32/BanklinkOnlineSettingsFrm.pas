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
  BankLinkOnlineServices,
  Progress;

const
  UM_AFTERSHOW = WM_USER + 1;

type

  TfrmBanklinkOnlineSettings = class(TForm)
    grpProductAccess: TGroupBox;
    lblSelectProducts: TLabel;
    btnSelectAll: TButton;
    btnClearAll: TButton;
    grpBillingFrequency: TGroupBox;
    lblNextBillingFrequency: TLabel;
    grpDefaultClientAdministrator: TGroupBox;
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
    btnUseClientDetails: TButton;
    grpServicesAvailable: TGroupBox;
    lblExportTo: TLabel;
    chkListServicesAvailable: TCheckListBox;
    chkDeliverData: TCheckBox;
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnClearAllClick(Sender: TObject);
    procedure rbSuspendedClick(Sender: TObject);
    procedure rbActiveClick(Sender: TObject);
    procedure rbDeactivatedClick(Sender: TObject);
    procedure CheckClientConnectControls;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnUseClientDetailsClick(Sender: TObject);
  private
    fOkPressed : Boolean;
    fBusyKeyPress : Boolean;
    fReadOnly : Boolean;
    fOldEmail : string;

    ClientReadDetail : TBloClientReadDetail;
    PracticeServiceArray  : TBloDataPlatformSubscription;
    procedure ExportTaggedAccounts(ProgressForm: ISingleProgressForm);
  protected
    function Validate : Boolean;
    procedure FillClientDetails;

    procedure SetStatus(aStatus : TBloStatus);
    function GetStatus : TBloStatus;
    procedure UpdateClientWebFormat(Subscription: TBloArrayOfGuid);
    procedure SetReadOnly;
    function IsClientOnline : boolean;
    
    procedure AfterShow(var Message: TMessage); message UM_AFTERSHOW;
  public
    function Execute(TickNotesOnline, ForceActiveClient: boolean) : boolean;

    procedure LoadClientInfo(TickNotesOnline: boolean);
    function SaveClientInfo : Boolean;
    property Status : TBloStatus read GetStatus write SetStatus;
  end;

  function EditBanklinkOnlineSettings(w_PopupParent: TForm; TickNotesOnline, ForceActiveClient,
                                      ShowServicesAvailable: boolean): boolean;

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
  StrUtils,
  InfoMoreFrm,
  BanklinkOnlineTaggingServices,
  ModalProgressFrm;

const
  UnitName = 'BanklinkOnlineSettingsFrm';

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.btnSelectAllClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to chkListProducts.Items.Count - 1 do
    chkListProducts.Checked[i] := true;
end;

procedure TfrmBanklinkOnlineSettings.btnUseClientDetailsClick(Sender: TObject);
begin
  FillClientDetails;
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
procedure TfrmBanklinkOnlineSettings.rbSuspendedClick(Sender: TObject);
begin
  CheckClientConnectControls;
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
procedure TfrmBanklinkOnlineSettings.FormShow(Sender: TObject);
begin
  FillClientDetails;
  PostMessage(Handle, UM_AFTERSHOW, 0, 0);
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if fOkPressed = false then
  begin
    CanClose := True;
    Exit;
  end;

  CanClose := Validate;

  if CanClose then
    CanClose := SaveClientInfo
  else
    fOkPressed := false;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.btnOKClick(Sender: TObject);
begin
  fOkPressed := True;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.btnCancelClick(Sender: TObject);
begin
  fOkPressed := False;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.CheckClientConnectControls;
begin
  lblClientConnect.Enabled := rbActive.Checked;
  cmbConnectDays.Enabled := rbActive.Checked;
end;

//------------------------------------------------------------------------------
function EditBanklinkOnlineSettings(w_PopupParent: TForm; TickNotesOnline, ForceActiveClient,
                                    ShowServicesAvailable: boolean): boolean;
var
  BanklinkOnlineSettings: TfrmBanklinkOnlineSettings;
  OkTop: integer;
const
  ThisMethodName = 'EditBanklinkOnlineSettings';
begin
  Result := False;

  if not Assigned(MyClient) then
    Exit;

  BanklinkOnlineSettings := TfrmBanklinkOnlineSettings.Create(Application.MainForm);
  try
    BanklinkOnlineSettings.PopupParent := w_PopupParent;
    BanklinkOnlineSettings.PopupMode := pmExplicit;
    BanklinkOnlineSettings.grpServicesAvailable.Visible := ShowServicesAvailable;
    OkTop := BanklinkOnlineSettings.grpBillingFrequency.Top +
             BanklinkOnlineSettings.grpBillingFrequency.Height + 10;
    if (BanklinkOnlineSettings.grpServicesAvailable.Visible = false) then
      OkTop := OkTop - BanklinkOnlineSettings.grpServicesAvailable.Height;
    if (BanklinkOnlineSettings.grpBillingFrequency.Visible = false) then
      OkTop := OkTop - BanklinkOnlineSettings.grpBillingFrequency.Height;
    BanklinkOnlineSettings.btnOk.Top := OkTop;
    BanklinkOnlineSettings.btnCancel.Top := OkTop;
    BanklinkOnlineSettings.Height := OkTop + 70;

    Result := BanklinkOnlineSettings.Execute(TickNotesOnline, ForceActiveClient);
  finally
    FreeAndNil(BanklinkOnlineSettings);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.SetReadOnly;
begin
  rbActive.Enabled := false;
  lblClientConnect.Enabled := false;
  cmbConnectDays.Enabled := false;
  rbSuspended.Enabled := false;
  rbDeactivated.Enabled := false;
  lblSelectProducts.Enabled := false;
  chklistProducts.Enabled := false;
  btnSelectAll.Enabled := false;
  btnClearAll.Enabled := false;
  lblNextBillingFrequency.Enabled := false;
  cmbBillingFrequency.Enabled := false;
  btnUseClientDetails.Enabled := false;
  lblUserName.Enabled := false;
  edtUserName.Enabled := false;
  lblEmailAddress.Enabled := false;
  edtEmailAddress.Enabled := false;
  btnOK.Enabled := false;
  btnCancel.Caption := 'Close';
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
procedure TfrmBanklinkOnlineSettings.UpdateClientWebFormat(Subscription: TBloArrayOfGuid);
var
  NotesId : TBloGuid;
begin
  NotesId := ProductConfigService.GetNotesId;
  if ProductConfigService.IsItemInArrayGuid(Subscription, NotesId) then
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
function TfrmBanklinkOnlineSettings.Validate: Boolean;
var
  EmailChanged, ProductsChanged, ProductFound, NotesOnlineTicked: boolean;
  NewProducts, RemovedProducts, AllProducts: TStringList;
  PromptMessage, ErrorMsg, MailTo, MailSubject, MailBody: string;
  i, j, NumProdTicked : integer;
  ClientStatus : TBloStatus;
  MaxOfflineDays : String;
  BillingFrequency : WideString;
  ClientAccessChanged: Boolean;
begin
  Result := False;
  NotesOnlineTicked := False;
  NumProdTicked := 0;

  EmailChanged := (uppercase(fOldEmail) <> uppercase(edtEmailAddress.Text));
  ProductsChanged := False;

  ClientAccessChanged := False;

  if (Trim(edtUserName.Text) = '') then
  begin
    ShowMessage('You must enter a user name. Please try again');
    edtUserName.SetFocus;
    Exit;
  end;

  if not RegExIsEmailValid(edtEmailAddress.Text) then
  begin
    ShowMessage('You must enter a valid e-mail address. Please try again');
    edtEmailAddress.SetFocus;
    Exit;
  end;

  if not ProductConfigService.OnLine then
  begin
    ErrorMsg := 'Banklink Practice is unable to connect to Banklink Online and so ' +
                'cannot update this client''s settings';
    ShowMessage(ErrorMsg);
    LogUtil.LogMsg(lmError, UnitName, ErrorMsg);
    Exit;
  end;

  if IsClientOnline then
    ClientStatus := ClientReadDetail.Status
  else
    ClientStatus := staActive;

  if (ClientStatus <> staActive) and (rbActive.Checked) then
  begin
    if AskYesNo('Resuming client',
                'You are about to resume this Client on ' +
                'Banklink Online. They will be able to access BankLink Online as per ' +
                'normal.' + #10#10 + 'Are you sure you want to continue?',
                DLG_YES, 0, false) <> DLG_YES then
    begin
      Exit;
    end
    else
    begin
      ClientAccessChanged := True;
    end;
  end;

  if (ClientStatus <> staSuspended) and (rbSuspended.Checked) then
  begin
    if AskYesNo('Suspending client',
                'You are about to suspend this Client from BankLink ' +
                'Online. They will be able to access BankLink Online in read-only mode.' +
                #10#10 + 'Are you sure you want to continue?',
                DLG_YES, 0, false) <> DLG_YES then
    begin
      Exit;
    end
    else
    begin
      ClientAccessChanged := True;
    end;
  end;

  if (ClientStatus <> staDeactivated) and (rbDeactivated.Checked) then
  begin
    if AskYesNo('Deactivating client',
                'You are about to deactivate this Client from BankLink ' +
                'Online. All user log-ins will be disabled.' + #10#10 +
                'Are you sure you want to continue?',
                DLG_YES, 0, false) <> DLG_YES then
    begin
      Exit;
    end
    else
    begin
      ClientAccessChanged := True;
    end;
  end;

  NewProducts := TStringList.Create;
  RemovedProducts := TStringList.Create;
  AllProducts     := TStringList.Create;
  try
    for i := 0 to chklistProducts.Count - 1 do
    begin
      ProductFound := false;

      if chklistProducts.Checked[i] then
      begin
        AllProducts.Add(chklistProducts.Items[i]);
        if TBloCatalogueEntry(chklistProducts.Items.Objects[i]).Id = ProductConfigService.GetNotesId then
          NotesOnlineTicked := True;

        inc(NumProdTicked);
      end;
      if IsClientOnline then
      begin
        for j := 0 to High(ClientReadDetail.Subscription) do
        begin
          if (TBloCatalogueEntry(chklistProducts.Items.Objects[i]).Id = ClientReadDetail.Subscription[j]) then
          begin
            ProductFound := true;
            break
          end;
        end;
      end;

      if (chklistProducts.Checked[i] = true) and not ProductFound then
      begin
        NewProducts.Add(chklistProducts.Items[i]);
        ProductsChanged := True;
      end
      else if (chklistProducts.Checked[i] = false) and ProductFound then
      begin
        RemovedProducts.Add(chklistProducts.Items[i]);
        ProductsChanged := True;
      end;

      if IsClientOnline then
      begin
        BillingFrequency := ClientReadDetail.BillingFrequency;
        MaxOfflineDays   := IntToStr(ClientReadDetail.MaxOfflineDays);
      end
      else
      begin
        BillingFrequency := 'Monthly';
        MaxOfflineDays   := '0';
      end;
    end;

    if (NumProdTicked = 0) then
    begin
      PromptMessage := 'You have edited the BankLink Online settings for this client, ' +
                       'but have not enabled any products so your changes will not be saved. ' + #10#10 +
                       'Click OK to continue without saving your changes, ' +
                       'or click Cancel if you wish to go back and enable a BankLink Online product for this client.';

      if MessageDlg(PromptMessage, mtWarning, [mbOK, mbCancel], 0) = idCancel then
        Exit;
    end
    else
    if (not IsClientOnline) and
       (NotesOnlineTicked) and
       (NumProdTicked > 1) then
    begin
      PromptMessage := 'BankLink Practice will create this client with the following ' +
                       'details onto BankLink Online: ' + #10#10 +
                       'Name: ' + edtUserName.text + #10 +
                       'Email Address: ' + edtEmailAddress.text + #10#10 +
                       'Products: ' + #10 +
                       Trim(AllProducts.Text) + #10#10 +
                       'Are you sure you want to continue? ';
      if AskYesNo('Create Client Online',
                  PromptMessage, DLG_YES, 0, false) <> DLG_YES then
        Exit;
    end
    else
    if (EmailChanged and ProductsChanged) and (NewProducts.Count > 0) and not ClientAccessChanged then
    begin
        PromptMessage := 'Are you sure you want to update the following for ' +
                         edtUserName.text + ':' + #10#10 +
                         'Activate the following products & services:' + #10 +
                         Trim(NewProducts.Text) + #10#10 + 'Change the Default Client ' +
                         'Administrator Email Address. The new Default Client ' +
                         'Adminstrator will be sent to ' + edtEmailAddress.Text + '.';
      
      if AskYesNo('Changing client details',
                  PromptMessage, DLG_YES, 0, false) <> DLG_YES then
        Exit;
    end
    else
    if EmailChanged and not ClientAccessChanged then
    begin
      if AskYesNo('Changing Default Administrator Address',
                  'You have changed the Default Client Administrator Email Address. ' +
                  'The new Default Client Administrator will be set to ' +
                  edtEmailAddress.Text + #10#10 +
                  'Are you sure you want to continue?',
                  DLG_YES, 0, false) <> DLG_YES then
        Exit;
    end
    else
    if ProductsChanged and (NewProducts.Count > 0) and not ClientAccessChanged then
    begin
      if AskYesNo('Activating products',
                  'Are you sure you want to activate the following products:' + #10#10 +
                  NewProducts.Text + #10 +
                 'By clicking ''OK'' you are confirming that you wish to activate these products ' +
                 'for ' + edtUserName.Text,
                 DLG_YES, 0, false) <> DLG_YES then
        Exit;
    end;

    (* We only want to send an email with products at the practice level have changed, not at the client level.
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
      for i := 0 to RemovedProducts.Count - 1 do
        MailBody := MailBody + RemovedProducts[i] + ' is now disabled' + #10;
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
    *)
    
    Result := True;
  finally
    FreeAndNil(NewProducts);
    FreeAndNil(RemovedProducts);
    FreeAndNil(AllProducts);
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
function TfrmBanklinkOnlineSettings.IsClientOnline: boolean;
begin
  Result := (MyClient.Opened) and (Assigned(ClientReadDetail));
end;

//------------------------------------------------------------------------------
function TfrmBanklinkOnlineSettings.Execute(TickNotesOnline, ForceActiveClient: boolean) : boolean;
begin
  fOkPressed := false;
  fBusyKeyPress := false;
  Result := False;

  if MyClient.Opened then
  begin
    //Get Practice details (so we can load the list of available products)
    ProductConfigService.GetPractice;
    //Get client list (so that we can lookup the client code)
    ProductConfigService.LoadClientList;
    
     //Get client details
    if Assigned(ProductConfigService.Clients) then
    begin
      ClientReadDetail := ProductConfigService.GetClientDetailsWithGUID(ProductConfigService.Clients.GetClientGuid(MyClient.clFields.clCode), True);
    end;
  end;

  LoadClientInfo(TickNotesOnline);

  fReadOnly := ProductConfigService.IsPracticeSuspended(not MyClient.Opened);

  if fReadOnly then
    SetReadOnly;

  if (ShowModal = mrOk) then
  begin
    Result := True;
    TfrmModalProgress.ShowProgress(Self, 'Please wait...', 'Sending selected vendors to BankLink Online',
                                   ExportTaggedAccounts);
  end;
end;

procedure TfrmBanklinkOnlineSettings.ExportTaggedAccounts(ProgressForm: ISingleProgressForm);
var
  VendorsSelected: TBloArrayOfGuid;
  i: integer;
begin
  // Tag accounts attached to this client for the vendor(s) selected
  for i := 0 to chkListServicesAvailable.Items.Count - 1 do
  begin
    if chkListServicesAvailable.Checked[i] then
    begin
      SetLength(VendorsSelected, Length(VendorsSelected) + 1);
      VendorsSelected[High(VendorsSelected)] := PracticeServiceArray.Current[i].ID;
    end;
  end;

  TBankLinkOnlineTaggingServices.UpdateAccountVendors(ClientReadDetail, MyClient, VendorsSelected, ProgressForm);
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.LoadClientInfo(TickNotesOnline: boolean);
var
  ProdIndex            : integer;
  SubIndex             : integer;
  ProductGuid          : TBloGuid;
  ClientSubGuid        : TBloGuid;
  CatEntry             : TBloCatalogueEntry;
  UserEMail            : String;
  UserFullName         : String;
  Subscription         : TBloArrayOfguid;
  ClientServiceArray   : TBloDataPlatformSubscription;
  Index                : Integer;
  PracticeServiceIndex : Integer;
  ClientServiceIndex   : Integer;
  ClientID             : String;
  DataExportEnabled    : boolean;

  procedure FillDetailIn(const aBillingFrequency : WideString;
                         const aMaxOfflineDays   : Integer;
                         const aStatus           : TBloStatus;
                         const aSubscription     : TBloArrayOfguid;
                         const aUserEMail        : WideString;
                         const aUserFullName     : WideString);
  var
    ProdIndex : integer;
    SubIndex  : integer;
  begin
    Status := aStatus;
    if (aMaxOfflineDays = 0) then
      cmbConnectDays.Text := 'Always'
    else
      cmbConnectDays.Text := IntToStr(aMaxOfflineDays) + ' days';
    cmbConnectDays.SelLength := 0;
    if aBillingFrequency = 'M' then
      cmbBillingFrequency.Text := 'Monthly'
    else if aBillingFrequency = 'A' then
      cmbBillingFrequency.Text := 'Annually'
    else
      cmbBillingFrequency.Text := aBillingFrequency; // shouldn't ever need this line
    cmbBillingFrequency.SelLength := 0;

    // Checks the Products that Client Subscribes to
    for ProdIndex := 0 to chklistProducts.Items.Count - 1 do
    begin
      for SubIndex := 0 to High(aSubscription) do
      begin
        ClientSubGuid := aSubscription[SubIndex];
        ProductGuid   := TBloCatalogueEntry(chklistProducts.Items.Objects[ProdIndex]).id;
        chklistProducts.Checked[ProdIndex] := (ClientSubGuid = ProductGuid);
        if chklistProducts.Checked[ProdIndex] then
          break;
      end;
    end;

    edtUserName.Text := aUserFullName;
    edtEmailAddress.Text := aUserEMail;
  end;
begin
  DataExportEnabled := False;
  //Load products
  chklistProducts.Clear;
  // Adds the Subscriptions/Products for the Practice to the List
  for ProdIndex := Low(ProductConfigService.ProductList) to High(ProductConfigService.ProductList) do
  begin
    ProductGuid := ProductConfigService.ProductList[ProdIndex];
    CatEntry := ProductConfigService.GetCatalogueEntry(ProductGuid);

    if (Assigned(CatEntry)) and
    (CatEntry.CatalogueType <> 'Service') then
      chklistProducts.AddItem(CatEntry.Description, CatEntry);

    if (CatEntry.CatalogueType = 'Service') and
    ((CatEntry.Description = 'Data Export') or (CatEntry.Description = 'Export Data')) then
      DataExportEnabled := True;     
  end;

  // Load services
  PracticeServiceArray := ProductConfigService.GetPracticeVendorExports;
  for PracticeServiceIndex := 0 to High(PracticeServiceArray.Current) do
    chkListServicesAvailable.Items.Add(PracticeServiceArray.Current[PracticeServiceIndex].Name_);

  // Tick the services that the client has enabled
  if Assigned(ClientReadDetail) then
    ClientID := ClientReadDetail.Id
  else
    ClientID := ProductConfigService.GetClientGuid(MyClient.clFields.clCode);
  if (ClientID <> '') then
  begin
    if DataExportEnabled then    
      ClientServiceArray := ProductConfigService.GetClientVendorExports(ClientReadDetail.Id);
    if Assigned(ClientServiceArray) then
    begin
      for ClientServiceIndex := 0 to High(ClientServiceArray.Current) do
      begin
        for PracticeServiceIndex := 0 to High(PracticeServiceArray.Current) do
        begin
          if (ClientServiceArray.Current[ClientServiceIndex].Id =
          PracticeServiceArray.Current[PracticeServiceIndex].Id) then
          begin
            chkListServicesAvailable.Checked[PracticeServiceIndex] := true;
            break;
          end;
        end;
      end;
    end else
      grpServicesAvailable.Visible := false;
  end;

  if TickNotesOnline then
  begin
    // Checks the Products that Client Subscribes to
    for ProdIndex := 0 to chklistProducts.Items.Count - 1 do
    begin
      if TBloCatalogueEntry(chklistProducts.Items.Objects[ProdIndex]).id = ProductConfigService.GetNotesId then
        chklistProducts.Checked[ProdIndex] := True;
    end;
  end;

  // Existing Client
  if IsClientOnline then
  begin
    if MyClient.clExtra.ceOnlineValuesStored then
      MyClient.clExtra.ceOnlineValuesStored := false;

    if (Length(ClientReadDetail.Users) > 0) then
    begin
      UserFullName := ClientReadDetail.Users[0].FullName;
      UserEMail    := ClientReadDetail.Users[0].Email;
    end
    else
    begin
      UserFullName := MyClient.clFields.clContact_Name;
      UserEMail    := MyClient.clFields.clClient_EMail_Address;
    end;

    FillDetailIn(ClientReadDetail.BillingFrequency,
                 ClientReadDetail.MaxOfflineDays,
                 ClientReadDetail.Status,
                 ClientReadDetail.Subscription,
                 UserEMail,
                 UserFullName);
  end
  // New Client
  else
  begin
    if MyClient.clExtra.ceOnlineValuesStored then
    begin
      SetLength(Subscription, MyClient.clExtra.ceOnlineSubscriptionCount);
      for SubIndex := 1 to MyClient.clExtra.ceOnlineSubscriptionCount do
        Subscription[SubIndex-1] := MyClient.clExtra.ceOnlineSubscription[SubIndex];

      FillDetailIn(MyClient.clExtra.ceOnlineBillingFrequency,
                   MyClient.clExtra.ceOnlineMaxOfflineDays,
                   TBloStatus(MyClient.clExtra.ceOnlineStatus),
                   Subscription,
                   MyClient.clExtra.ceOnlineUserEMail,
                   MyClient.clExtra.ceOnlineUserFullName);
    end
    else
    begin
      Status := staActive;
      cmbConnectDays.Text := 'Always';
      cmbBillingFrequency.Text := 'Monthly';
      cmbBillingFrequency.SelLength := 0;
      cmbConnectDays.SelLength := 0;
      edtUserName.Text := MyClient.clFields.clContact_Name;
      edtEmailAddress.Text := MyClient.clFields.clClient_EMail_Address;
    end;
  end;

  //If the client is opened in read-only mode then disable the notes online product.
  if MyClient.clFields.clFile_Read_Only then
  begin
    for Index := 0 to chklistProducts.Items.Count - 1 do
    begin
      if TBloCatalogueEntry(chklistProducts.Items.Objects[Index]).id = ProductConfigService.GetNotesId then
      begin
        chklistProducts.ItemEnabled[Index] := False;

        Break;
      end;
    end;
  end;

  fOldEmail := edtEmailAddress.Text;
end;

//------------------------------------------------------------------------------
function TfrmBanklinkOnlineSettings.SaveClientInfo : Boolean;
var
  ProdIndex : integer;
  SubIndex : integer;
  CatEntry  : TBloCatalogueEntry;
  ConnectDays : string;
  Subscription: TBloArrayOfGuid;
  NotesOnlineTicked : Boolean;
  NumProdTicked : Integer;
begin
  NotesOnlineTicked := False;
  NumProdTicked := 0;

  ConnectDays := StringReplace(cmbConnectDays.Text, 'Always', '0', [rfReplaceAll]);
  ConnectDays := StringReplace(ConnectDays, ' days', '', [rfReplaceAll]);

  for ProdIndex := 0 to chklistProducts.Count - 1 do
  begin
    if chklistProducts.Checked[ProdIndex] then
    begin
      CatEntry := TBloCatalogueEntry(chklistProducts.Items.Objects[ProdIndex]);
      ProductConfigService.AddItemToArrayGuid(Subscription, CatEntry.id);

      if CatEntry.id = ProductConfigService.GetNotesId then
        NotesOnlineTicked := True;

      Inc(NumProdTicked);
    end;
  end;

  // Existing Client
  if IsClientOnline then
  begin
    Result := ProductConfigService.UpdateClient(ClientReadDetail,
                                                AnsiLeftStr(cmbBillingFrequency.Text, 1),
                                                StrToInt(ConnectDays),
                                                Status,
                                                Subscription,
                                                edtEmailAddress.Text,
                                                edtUserName.Text);
  end
  else
  // New Client
  begin
    // If Notes Online is selected and no other products are selected instead of creating a
    // new client then it stores the values offline (in the client file) to be uploaded
    // after the first Note upload when it does create the client
    if (NotesOnlineTicked) and
       (NumProdTicked = 1) then
    begin
      MyClient.clExtra.ceOnlineBillingFrequency := AnsiLeftStr(cmbBillingFrequency.Text, 1);
      MyClient.clExtra.ceOnlineMaxOfflineDays   := StrToInt(ConnectDays);
      MyClient.clExtra.ceOnlineStatus           := Ord(Status);

      if Length(Subscription) > 64 then
        MyClient.clExtra.ceOnlineSubscriptionCount := 64
      else
        MyClient.clExtra.ceOnlineSubscriptionCount := Length(Subscription);

      for SubIndex := 1 to MyClient.clExtra.ceOnlineSubscriptionCount do
      begin
        MyClient.clExtra.ceOnlineSubscription[SubIndex] := Subscription[SubIndex-1];
      end;

      MyClient.clExtra.ceOnlineUserEMail    := edtEmailAddress.Text;
      MyClient.clExtra.ceOnlineUserFullName := edtUserName.Text;
      MyClient.clExtra.ceOnlineValuesStored := True;
      Result := True;
    end
    else
    begin
      if NumProdTicked > 0 then
      begin
        Result := ProductConfigService.CreateClient(AnsiLeftStr(cmbBillingFrequency.Text, 1),
                                                    StrToInt(ConnectDays),
                                                    Status,
                                                    Subscription,
                                                    edtEmailAddress.Text,
                                                    edtUserName.Text);
      end
      else
      begin
        SetLength(Subscription,0);
        MyClient.clExtra.ceOnlineValuesStored := False;
        Result := True;
      end;
    end;
  end;

  if Result then
  begin
    UpdateClientWebFormat(Subscription);
  end
  else
  begin
    ClientReadDetail := ProductConfigService.GetClientDetailsWithCode(MyClient.clFields.clCode);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.AfterShow(var Message: TMessage);
begin
  //Prevent the application from disapearing begin another application
  BringToFront;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.FillClientDetails;
begin
  edtUserName.Text := MyClient.clFields.clContact_Name;
  edtEmailAddress.Text := MyClient.clFields.clClient_EMail_Address;
end;

end.


