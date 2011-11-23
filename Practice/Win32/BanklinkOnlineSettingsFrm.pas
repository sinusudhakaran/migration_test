unit BanklinkOnlineSettingsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, CheckLst, BankLinkOnlineServices, BlopiServiceFacade;

type

  TfrmBanklinkOnlineSettings = class(TForm)
    grpProductAccess: TGroupBox;
    lblSelectProducts: TLabel;
    btnSelectAll: TButton;
    btnClearAll: TButton;
    chkSuspendClient: TCheckBox;
    chkDeactivateClient: TCheckBox;
    rbClientAlwaysOnline: TRadioButton;
    rbClientMustConnect: TRadioButton;
    cmbDays: TComboBox;
    grpBillingFrequency: TGroupBox;
    lblFreeTrial: TLabel;
    lblNextBillingPeriod: TLabel;
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
    btnTemp: TButton;
    cmbBillingFrequency: TComboBox;
    procedure rbClientAlwaysOnlineClick(Sender: TObject);
    procedure rbClientMustConnectClick(Sender: TObject);
    procedure btnTempClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnClearAllClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    SubArray: ArrayOfGuid;
    FClient: ClientSummary;
  public
    { Public declarations }
  end;

var
  frmBanklinkOnlineSettings: TfrmBanklinkOnlineSettings;
  BanklinkOnlineConnected : boolean = false;

implementation


{$R *.dfm}

procedure TfrmBanklinkOnlineSettings.btnOKClick(Sender: TObject);
var
  EmailChanged, ProductsChanged, BillingFrequencyChanged, SuspendChanged,
  DeactivateChanged, ProductFound: boolean;
  NewProducts: TStringList;
  PromptMessage: string;
  i, j, ButtonPressed: integer;
begin
  if not BanklinkOnlineConnected then
  begin
    ShowMessage('Banklink Practice is unable to connect to Banklink Online and so ' +
                'cannot update this client''s settings');
    ModalResult := mrNone;
    Exit;
  end;

  EmailChanged := (edtEmailAddress.Text <> FClient.EmailAddress);
  NewProducts := TStringList.Create;
  for i := 0 to chklistProducts.Count - 1 do
  begin
    if chklistProducts.Checked[i] then
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
      if not ProductFound then
        NewProducts.Add(chklistProducts.Items[i]);
    end;
  end;
  ProductsChanged := NewProducts.Count > 0;
  BillingFrequencyChanged := cmbBillingFrequency.Text <> FClient.BillingFrequency;

  ButtonPressed := mrOk;
  if EmailChanged and not (ProductsChanged or BillingFrequencyChanged) then
    ButtonPressed := MessageDlg('You have changed the Default Client Administrator Email Address. ' +
                'The new Default Client Administrator will be set to ' +
                '‘' + edtEmailAddress.Text + '’.' + #10 + #10 +
                'Are you sure you want to continue?', mtConfirmation, [mbYes, mbNo], 0)
  else if ProductsChanged and not (EmailChanged or BillingFrequencyChanged) then
    ButtonPressed := MessageDlg('Are you sure you want to activate the following products:' + #13#10 +
                NewProducts.Text, mtConfirmation, [mbYes, mbNo], 0)
  else if BillingFrequencyChanged and not (ProductsChanged or EmailChanged) then
    ButtonPressed := MessageDlg('You have changed this Client''s billing frequency. Your next ' +
                'invoice for this Client will be for the period...', // fill in later
                mtConfirmation, [mbYes, mbNo], 0)
  else if (EmailChanged or ProductsChanged or BillingFrequencyChanged) then // will reach and trigger this if two or more have changed
  begin
    PromptMessage := 'Are you sure you want to update the following for ' +
                     FClient.UserName + ':';
    if ProductsChanged then
      PromptMessage := PromptMessage + #13#10#10 + 'Activate the following products:' +
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

  if ButtonPressed = mrNo
      then ModalResult := mrNone
      else ModalResult := mrOk;
end;

procedure TfrmBanklinkOnlineSettings.btnSelectAllClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to chkListProducts.Items.Count - 1 do
    chkListProducts.Checked[i] := true;
end;

procedure TfrmBanklinkOnlineSettings.btnClearAllClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to chkListProducts.Items.Count - 1 do
    chkListProducts.Checked[i] := false;
end;

procedure TfrmBanklinkOnlineSettings.btnTempClick(Sender: TObject);
var
  CatArray: ArrayOfCatalogueEntry;
  ClientArray: ArrayOfClientSummary;
  SubArray: ArrayOfGuid;
  GUID: TGuid;
  i, k: integer;
  GUID1, GUID2: WideString;
  AClientID: WideString;
begin
  AClientID := ProductConfigService.Clients.Clients[0].Id;
  FClient := ProductConfigService.GetClientDetails(AClientID);

  BanklinkOnlineConnected := not BanklinkOnlineConnected;
  if btnTemp.Caption = 'Switch to offline' then
  begin
    // Switched to offline
    btnTemp.Caption := 'Switch to online';
  end else
  begin
    // Switched to online
    btnTemp.Caption := 'Switch to offline';

    // Temporary functionality, move it to FormCreate or FormShow later
{    SetLength(CatArray, 2);

    CatArray[0] := CatalogueEntry.Create;
    CatArray[0].CatalogueType := 'TestCat1';
    CreateGUID(GUID);
    CatArray[0].Id := GuidToString(GUID);

    CatArray[1] := CatalogueEntry.Create;
    CatArray[1].CatalogueType := 'TestCat2';
    CreateGUID(GUID);
    CatArray[1].Id := GuidToString(GUID);

    ListOfClients := ClientList.Create;
    ListOfClients.Catalogue := CatArray;
    SetLength(ClientArray, 1);
    ListOfClients.Clients := ClientArray; }

    chkSuspendClient.Checked := FClient.Status = Suspended;
    chkDeactivateClient.Checked := FClient.Deactivated;
    if (StrToInt(FClient.ClientConnectDays) = 0) then
    begin
      rbClientAlwaysOnline.Checked := true;
    end else
    begin
      rbClientMustConnect.Checked := true;
      cmbDays.Text := FClient.ClientConnectDays;
    end;
    if (FClient.UserOnTrial) then
    begin
      lblFreeTrial.Caption := 'Free Trial until ' + DateTimeToStr(FClient.FreeTrialEndDate);
    end else
    begin
      lblFreeTrial.Caption := 'Currently billed {' + FClient.BillingFrequency + '} until ' + DateTimeToStr(FClient.BillingEndDate);
    end;
    chkUseClientDetails.Checked := FClient.UseClientDetails;
    edtUserName.Text := FClient.UserName;
    edtEmailAddress.Text := FClient.EmailAddress;

    CatArray := ProductConfigService.Clients.Catalogue;
    for i := Low(CatArray) to High(CatArray) do
      chklistProducts.AddItem(CatArray[i].Description, TObject(CatArray[i].Id));

    for i := 0 to chklistProducts.Items.Count - 1 do begin
      for k := Low(FClient.Subscription) to High(FClient.Subscription) do begin
        GUID1 := FClient.Subscription[k];
        GUID2 := WideString(chklistProducts.Items.Objects[i]);
        chklistProducts.Checked[i] := (GUID1 = GUID2);
        if chklistProducts.Checked[i] then break;
      end;
    end;
  end;

end;

procedure TfrmBanklinkOnlineSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  ListOfClients.Free;
  chklistProducts.Clear;
end;

procedure TfrmBanklinkOnlineSettings.rbClientAlwaysOnlineClick(Sender: TObject);
begin
  cmbDays.Enabled := false;
end;

procedure TfrmBanklinkOnlineSettings.rbClientMustConnectClick(Sender: TObject);
begin
  cmbDays.Enabled := true;
end;

end.
