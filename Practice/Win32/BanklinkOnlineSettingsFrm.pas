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
  Progress, RzLstBox, RzChkLst;

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
    chkDeliverData: TCheckBox;
    edtSecureCode: TEdit;
    lblSecureCode: TLabel;
    chkListProducts: TCheckListBox;
    chklistServicesAvailable: TCheckListBox;
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
    procedure FormDestroy(Sender: TObject);
    procedure chkDeliverDataClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure chklistServicesAvailableClickCheck(Sender: TObject);
    procedure rbActiveMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure grpDefaultClientAdministratorClick(Sender: TObject);
  private
    fOkPressed : Boolean;
    fBusyKeyPress : Boolean;
    fReadOnly : Boolean;
    fOldEmail : string;
    fClientStatus : integer;

    ClientReadDetail : TBloClientReadDetail;
    AvailableServiceArray : TBloArrayOfDataPlatformSubscriber;
    OriginalDataExports: TBloArrayOfGuid;
    ModifiedDataExports: TBloArrayOfGuid;

    procedure ExportTaggedAccounts(ProgressForm: ISingleProgressForm);
    procedure AdjustControlPositions;

    function GetClientSubscriptionCategory(SubscriptionId: TBloGuid): TBloCatalogueEntry;
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

  TDataExportOption = class
  private
    FGuid: TBloGuid;
  public
    constructor Create(Guid: TBloGuid);
    property Guid: TBloGuid read FGuid;
  end;

  function EditBanklinkOnlineSettings(w_PopupParent: TForm; TickNotesOnline, ForceActiveClient,
                                      ShowServicesAvailable: boolean): boolean;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  Globals,
  LogUtil,
  BkConst,
  SysUtils,
  Variants,
  MailFrm,
  YesNoDlg,
  OkCancelDlg,
  Files,
  StrUtils,
  InfoMoreFrm,
  BanklinkOnlineTaggingServices,
  ModalProgressFrm,
  RegExprUtils,
  GenUtils,
  BlopiServiceFacade;

const
  UnitName = 'BanklinkOnlineSettingsFrm';

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.btnSelectAllClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to chkListProducts.Items.Count - 1 do
  begin
    if chkListProducts.ItemEnabled[i]  then
    begin
      chkListProducts.Checked[i] := true;
    end;
  end;
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
  begin
    if chkListProducts.ItemEnabled[i]  then
    begin
      chkListProducts.Checked[i] := false;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.rbActiveClick(Sender: TObject);
begin
  CheckClientConnectControls;
end;

procedure TfrmBanklinkOnlineSettings.rbActiveMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Msg: String;
  WasSuspended, WasDeactivated: boolean;
//  ClientReadDetail : TBloClientReadDetail;
  ClientDetailResponse: MessageResponseOfClientReadDetailMIdCYrSK;
  BlopiInterface: IBlopiServiceFacade;
begin
  WasSuspended := rbSuspended.Checked;
  WasDeactivated := rbDeactivated.Checked;

  if (ProductConfigService.GetOnlineClientIndex(MyClient.clFields.clCode) > -1) then
  begin
    Msg := 'Are you sure you want to link this client file to the ' +
           'following BankLink Online client? Note that this will overwrite ' +
           'your local client settings with those from the BankLink Online ' +
           'client. (%s) - (%s)';
    if AskYesNo('Activating a client',
                format(Msg, [MyClient.clFields.clCode, MyClient.clFields.clName]),
                DLG_NO,
                0) = DLG_YES then
    begin
      ClientReadDetail := ProductConfigService.GetClientDetailsWithCode(MyClient.clFields.clCode);
      ClientReadDetail.Status := BlopiServiceFacade.Active;
      LoadClientInfo(True);
      ProductConfigService.UpdateClientStatus(ClientReadDetail, MyClient.clFields.clCode);
    end else
    begin
      if WasSuspended then
        rbSuspended.Checked := True;
      if WasDeactivated then
        rbDeactivated.Checked := True;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBanklinkOnlineSettings.rbSuspendedClick(Sender: TObject);
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
  //FillClientDetails;
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

procedure TfrmBanklinkOnlineSettings.FormDestroy(Sender: TObject);
var
  Index: Integer;
begin
  for Index := 0 to chklistServicesAvailable.Count - 1 do
  begin
    if Assigned(chklistServicesAvailable.Items.Objects[Index]) then
    begin
      chklistServicesAvailable.Items.Objects[Index].Free;
    end;
  end;
end;

procedure TfrmBanklinkOnlineSettings.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((ssAlt in Shift) and (Key = 86)) then // Alt + V
    chkDeliverData.Checked := not chkDeliverData.Checked;
  if ((ssAlt in Shift) and (Key = 66) and edtSecureCode.Visible) then // Alt + B
    Self.ActiveControl := Self.edtSecureCode;
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

procedure TfrmBanklinkOnlineSettings.chkDeliverDataClick(Sender: TObject);
begin
  if (chkDeliverData.Checked) and
     (MyClient.clFields.clDownload_From = dlBankLinkConnect) then
  begin
    { Shouldn't be able to reach here, as the Services Available panel should be invisible
      if the second and third conditions are true, and thus chkDeliverData can't be
      checked }
    ShowMessage('This client is set up to download data directly from BankLink to the ' +
                'client file. Please contact BankLink Client Services if you want to ' +
                'change the data delivery method to BankLink Online');
    chkDeliverData.Checked := False;
    Exit;
  end;

  lblSecureCode.Visible := chkDeliverData.Checked;
  edtSecureCode.Visible := chkDeliverData.Checked;
end;

procedure TfrmBanklinkOnlineSettings.chklistServicesAvailableClickCheck(
  Sender: TObject);
begin
  if chklistServicesAvailable.Checked[chklistServicesAvailable.ItemIndex] then
    ProductConfigService.AddItemToArrayGuid(ModifiedDataExports, TDataExportOption(chklistServicesAvailable.Items.Objects[chklistServicesAvailable.ItemIndex]).Guid)
  else
    ProductConfigService.RemoveItemFromArrayGuid(ModifiedDataExports, TDataExportOption(chklistServicesAvailable.Items.Objects[chklistServicesAvailable.ItemIndex]).Guid);
end;

//------------------------------------------------------------------------------
function EditBanklinkOnlineSettings(w_PopupParent: TForm; TickNotesOnline, ForceActiveClient,
                                    ShowServicesAvailable: boolean): boolean;
var
  BanklinkOnlineSettings: TfrmBanklinkOnlineSettings;
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
    BanklinkOnlineSettings.AdjustControlPositions;

    Result := BanklinkOnlineSettings.Execute(TickNotesOnline, ForceActiveClient);
  finally
    FreeAndNil(BanklinkOnlineSettings);
  end;
end;

procedure TfrmBanklinkOnlineSettings.AdjustControlPositions;
var
  OkTop: integer;
begin
  OkTop := grpBillingFrequency.Top +
           grpBillingFrequency.Height + 10;
  if (grpServicesAvailable.Visible = false) then
    OkTop := OkTop - grpServicesAvailable.Height;
  if (grpDefaultClientAdministrator.Visible = false) then
    OkTop := OkTop - grpDefaultClientAdministrator.Height;
  if (grpBillingFrequency.Visible = false) then
    OkTop := OkTop - grpBillingFrequency.Height;
  btnOk.Top := OkTop;
  btnCancel.Top := OkTop;
  Height := OkTop + 70;
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
  NewProducts, RemovedProducts, AllProducts, NewExports: TStringList;
  PromptMessage, ErrorMsg, MailTo, MailSubject, MailBody: string;
  i, j, NumProdTicked : integer;
  ClientStatus : TBloStatus;
  MaxOfflineDays, NewExportsStr : String;
  BillingFrequency : WideString;
  ClientAccessChanged, ExportFound: Boolean;
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

      if not (ProductFound or Assigned(ClientReadDetail)) then
      begin
        for j := 1 to High(MyClient.clExtra.ceOnlineSubscription) do
        begin
          if (TBloCatalogueEntry(chklistProducts.Items.Objects[i]).Id =
              MyClient.clExtra.ceOnlineSubscription[j]) then
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

    {
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
    }
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
      if AskOkCancel('Activate Products',
                     'Are you sure you want to activate the following products:' + #10#10 +
                    NewProducts.Text + #10 +
                    'By clicking ''OK'' you are confirming that you wish to activate these products ' +
                    'for ' + edtUserName.Text,
                    DLG_OK, 0) <> DLG_OK then
        Exit;
    end;
    if grpServicesAvailable.Visible and edtSecureCode.Visible then
    begin
      if not RegExIsAlphaNumeric(Trim(edtSecureCode.Text), false) then
      begin
        ShowMessage('You must enter a BankLink Online Secure Code if you want data for this ' +
                    'client to be sent direct to BankLink Online.  Click OK to return and enter ' +
                    'the code, or remove the tick from the Deliver data direct to BankLink Online ' +
                    'checkbox before saving your changes.');
        Exit;
      end;
    end;

    // Below is not really 'validation'
    if Assigned(NewExports) then
      NewExports.Clear;
    for i := 0 to High(ModifiedDataExports) do
    begin
      ExportFound := False;
      for j := 0 to High(OriginalDataExports) do
      begin
        if (ModifiedDataExports[i] = OriginalDataExports[j]) then
        begin
          ExportFound := True;
          break;
        end;
      end;
      if not ExportFound then
      begin
        if not Assigned(NewExports) then
          NewExports := TStringList.Create;
        for j := 0 to High(AvailableServiceArray) do
        begin
          if (ModifiedDataExports[i] = AvailableServiceArray[j].Id) then
          begin
            NewExports.Add(AvailableServiceArray[j].Name_);
            break;
          end;
        end;
      end;
    end;

    if Assigned(NewExports) then
    begin
      NewExportsStr := GetCommaSepStrFromList(NewExports);

      ShowMessage('You have enabled the export of data to BankLink Online for ' +
                  NewExportsStr + ' for all the Bank Accounts currently attached to ' +
                  'this client file. If there are Bank Accounts that you do not ' +
                  'want to send to ' + NewExportsStr + ' you can deselect them via ' +
                  'Other Functions | Bank Accounts.');
    end;

    FreeAndNil(NewExports);  


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
function TfrmBanklinkOnlineSettings.GetClientSubscriptionCategory(SubscriptionId: TBloGuid): TBloCatalogueEntry;
var
  Index: Integer;
begin
  Result := nil;

  if not Assigned(ClientReadDetail) then
  begin
    Exit;
  end;

  for Index := 0 to Length(ClientReadDetail.Catalogue) - 1 do
  begin
    if ProductConfigService.GuidsEqual(ClientReadDetail.Catalogue[Index].Id, SubscriptionId) then
    begin
      Result := ClientReadDetail.Catalogue[Index];

      Break;
    end;
  end;
end;

function TfrmBanklinkOnlineSettings.GetStatus : TBloStatus;
begin
  if rbActive.Checked then
    Result := staActive
  else if rbSuspended.Checked then
    Result := staSuspended
  else // if rbDeactivated.Checked then
    Result := staDeactivated
end;

procedure TfrmBanklinkOnlineSettings.grpDefaultClientAdministratorClick(
  Sender: TObject);
begin

end;

//------------------------------------------------------------------------------
function TfrmBanklinkOnlineSettings.IsClientOnline: boolean;
begin
  Result := (MyClient.Opened) and (Assigned(ClientReadDetail));
end;

//------------------------------------------------------------------------------
function TfrmBanklinkOnlineSettings.Execute(TickNotesOnline, ForceActiveClient: boolean) : boolean;
var
  ClientGuid: TBloGuid;
begin
  fOkPressed := false;
  fBusyKeyPress := false;
  Result := False;
  rbSuspended.Enabled   := not ForceActiveClient;
  rbDeactivated.Enabled := not ForceActiveClient;

  if MyClient.Opened then
  begin
    if ProductConfigService.GetClientGuid(MyClient.clFields.clCode, ClientGuid) then
    begin
      ClientReadDetail := ProductConfigService.GetClientDetailsWithGUID(ClientGuid, True);
    end;

    if not Assigned(ClientReadDetail) then
    begin
      //Get Practice details (so we can load the list of available products)
      ProductConfigService.GetPractice;
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
  i: integer;
begin 
  TBankLinkOnlineTaggingServices.UpdateAccountVendors(ClientReadDetail, MyClient, OriginalDataExports,
                                                      ModifiedDataExports, ProgressForm);
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
  ClientExportDataService   : TBloDataPlatformSubscription;
  Index                : Integer;
  AvailableServiceIndex : Integer;
  ClientServiceIndex   : Integer;
  ClientID             : String;
  DataExportEnabled    : boolean;
  ClientHasServices    : boolean;
  PracticeExportDataService   : TBloDataPlatformSubscription;
  ExportToSortList: TStringList;
  
  function HasCachedSubscription(CachedProdId: TBloGuid): boolean;
  var
    j: integer;
  begin
    Result := false;
    for j := 1 to High(MyClient.clExtra.ceOnlineSubscription) do      
    begin
      if (MyClient.clExtra.ceOnlineSubscription[j] = CachedProdId) then
      begin
        Result := true;
        break;
      end;
    end;
  end;

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
    chkDeliverData.Checked := MyClient.clExtra.ceDeliverDataDirectToBLO;
    edtSecureCode.Text := MyClient.clExtra.ceBLOSecureCode;
  end;
begin
  DataExportEnabled := False;
  //Load products
  chklistProducts.Clear;

  if not Assigned(ClientReadDetail) then
  begin
    // Adds the Subscriptions/Products for the Practice to the List
    for ProdIndex := Low(ProductConfigService.ProductList) to High(ProductConfigService.ProductList) do
    begin
      ProductGuid := ProductConfigService.ProductList[ProdIndex];
      CatEntry := ProductConfigService.GetCatalogueEntry(ProductGuid);

      if Assigned(CatEntry) then
      begin
        if (CatEntry.CatalogueType <> 'Service') then
          chklistProducts.AddItem(CatEntry.Description, CatEntry)
        else if (CatEntry.Id = ProductConfigService.GetExportDataId) then
          DataExportEnabled := True;
      end;
    end;
  end else
  begin
    for ProdIndex := Low(ClientReadDetail.Catalogue) to High(ClientReadDetail.Catalogue) do
    begin
      CatEntry := ClientReadDetail.Catalogue[ProdIndex]; 

      if Assigned(CatEntry) then
      begin
        if (CatEntry.CatalogueType <> 'Service') then
          chklistProducts.AddItem(CatEntry.Description, CatEntry)
        else if (CatEntry.Id = ProductConfigService.GetExportDataId) then
          DataExportEnabled := True;
      end;  
    end;
  end;

  // Load services
  if DataExportEnabled then
  begin
    if Assigned(ClientReadDetail) then
    begin
      ClientID := ClientReadDetail.Id;
    end;

    if ClientID <> '' then
    begin
      ClientExportDataService := ProductConfigService.GetClientVendorExports(ClientID);

      if Assigned(ClientExportDataService) then
      begin
        AvailableServiceArray := ClientExportDataService.Available;
      end;
    end
    else
    begin
      PracticeExportDataService := ProductConfigService.GetPracticeVendorExports;

      if Assigned(PracticeExportDataService) then
      begin
        AvailableServiceArray := PracticeExportDataService.Current;
      end;  
    end;

    ExportToSortList := TStringList.Create;

    try
      ExportToSortList.Sorted := True;

      for AvailableServiceIndex := 0 to High(AvailableServiceArray) do
      begin
        ExportToSortList.AddObject(AvailableServiceArray[AvailableServiceIndex].Name_, TDataExportOption.Create(AvailableServiceArray[AvailableServiceIndex].Id));
      end;

      for AvailableServiceIndex := 0 to ExportToSortList.Count - 1 do
      begin
        chkListServicesAvailable.AddItem(ExportToSortList[AvailableServiceIndex], ExportToSortList.Objects[AvailableServiceIndex]);
      end;
    finally
      ExportToSortList.Free;
    end;
  
    if Assigned(ClientExportDataService) then
    begin
      for ClientServiceIndex := 0 to High(ClientExportDataService.Current) do
      begin
        for AvailableServiceIndex := 0 to High(AvailableServiceArray) do
        begin
          if (ClientExportDataService.Current[ClientServiceIndex].Id = AvailableServiceArray[AvailableServiceIndex].Id) then
          begin
            chkListServicesAvailable.Checked[AvailableServiceIndex] := true;

            ProductConfigService.AddItemToArrayGuid(OriginalDataExports, ClientExportDataService.Current[ClientServiceIndex].Id);
            ProductConfigService.AddItemToArrayGuid(ModifiedDataExports, ClientExportDataService.Current[ClientServiceIndex].Id);

            break;
          end;
        end;
      end;
    end;
  end
  else
  begin
    grpServicesAvailable.Visible := false;
    AdjustControlPositions;
  end;

  if TickNotesOnline then
  begin
    // Checks the Products that Client Subscribes to
    for ProdIndex := 0 to chklistProducts.Items.Count - 1 do
    begin
      if TBloCatalogueEntry(chklistProducts.Items.Objects[ProdIndex]).id = ProductConfigService.GetNotesId then
        chklistProducts.Checked[ProdIndex] := True;
    end;

    if not HasCachedSubscription(ProductConfigService.GetNotesId) then
    begin
      MyClient.clExtra.ceOnlineSubscription[MyClient.clExtra.ceOnlineSubscriptionCount + 1] := 
        ProductConfigService.GetNotesId;  
      MyClient.clExtra.ceOnlineSubscriptionCount := MyClient.clExtra.ceOnlineSubscriptionCount + 1;
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
  NotesOnlineTicked, ShowUpdateMsg : Boolean;
  NumProdTicked : Integer;
  ClientCode : WideString;
  ClientID: TBloGuid;
begin
  ClientID := '';
  ShowUpdateMsg := True;
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

  if Assigned(ClientReadDetail) then
  begin
    for ProdIndex := 0 to Length(ClientReadDetail.Subscription) - 1 do
    begin
      CatEntry := GetClientSubscriptionCategory(ClientReadDetail.Subscription[ProdIndex]);

      if Assigned(CatEntry) then
      begin
        if (CatEntry.CatalogueType = 'Service') then
        begin
          ProductConfigService.AddItemToArrayGuid(Subscription, CatEntry.id); 
        end;
      end;
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
                                                edtUserName.Text,
                                                false);
                                                
    MyClient.clExtra.ceOnlineValuesStored := False;
  end
  else
  // New Client
  begin
    // If Notes Online is selected and no other products are selected instead of creating a
    // new client then it stores the values offline (in the client file) to be uploaded
    // after the first Note upload when it does create the client
    if (((NotesOnlineTicked) and (NumProdTicked = 1)) or (NumProdTicked = 0)) and (Length(ModifiedDataExports) = 0) then
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
      for SubIndex := 1 to MyClient.clExtra.ceOnlineSubscriptionCount do
      begin
        if SubIndex > Length(Subscription) then               
          MyClient.clExtra.ceOnlineSubscription[SubIndex] := ''
        else
          MyClient.clExtra.ceOnlineSubscription[SubIndex] := Subscription[SubIndex-1];
      end;       
    
      if (NumProdTicked > 0) or (Length(ModifiedDataExports) > 0) then
      begin
        Result := ProductConfigService.CreateClient(AnsiLeftStr(cmbBillingFrequency.Text, 1),
                                                    StrToInt(ConnectDays),
                                                    Status,
                                                    Subscription,
                                                    edtEmailAddress.Text,
                                                    edtUserName.Text,
                                                    ClientID);
        
        MyClient.clExtra.ceOnlineValuesStored := False;
        
        ShowUpdateMsg := not Result;

        if Result then
        begin
          ClientReadDetail := ProductConfigService.GetClientDetailsWithCode(MyClient.clFields.clCode);
        end;
      end
      else
      begin
        SetLength(Subscription,0);
        Result := True;
      end;
    end;
  end;
  
  MyClient.clExtra.ceDeliverDataDirectToBLO := chkDeliverData.Checked;

  if MyClient.clExtra.ceDeliverDataDirectToBLO then
  begin
    MyClient.clExtra.ceBLOSecureCode := edtSecureCode.Text;
  end
  else
  begin
    MyClient.clExtra.ceBLOSecureCode := '';
  end;
  
  if Result then
  begin
    UpdateClientWebFormat(Subscription);

    if not ProductConfigService.GuidArraysEqual(OriginalDataExports, ModifiedDataExports) then
    begin
      if Assigned(ClientReadDetail) then
        Result := ProductConfigService.SaveClientVendorExports(ClientReadDetail.Id, ModifiedDataExports, true, True, False)
      else if (ClientID <> '') then
        Result := ProductConfigService.SaveClientVendorExports(ClientID, ModifiedDataExports, true, True, False);
    end;

    if Result then
    begin
      ClientCode := MyClient.clFields.clCode;
      if ShowUpdateMsg then      
        HelpfulInfoMsg(Format('Settings for %s have been successfully updated to ' +
                       '%s.',[ClientCode, BANKLINK_ONLINE_NAME]), 0);
    end;
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

{ TDataExport }

constructor TDataExportOption.Create(Guid: TBloGuid);
begin
  FGuid := Guid;
end;

end.


