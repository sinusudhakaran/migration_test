unit BanklinkOnlineSettingsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, CheckLst, BankLinkOnlineServices, OSFont;

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
    procedure FillClientDetails;
    procedure FormShow(Sender: TObject);
  private
    SubArray: ArrayOfGuid;
    FClient: Client;
    FContactName, FEmailAddress: string;
  public
    procedure SetContactName(Value: string);
    procedure SetEmailAddress(Value: string);
    function Execute(AClient: Client): boolean;
  end;

  // function to create BanklinkOnlineSettingsFrm goes here
  function EditBanklinkOnlineSettings(AClient: Client): boolean;

const
  UnitName = 'BanklinkOnlineSettingsFrm';

var
  frmBanklinkOnlineSettings: TfrmBanklinkOnlineSettings;
  BanklinkOnlineConnected : boolean = true;

implementation

uses Globals, LogUtil, RegExprUtils, ClientDetailsFrm;

{$R *.dfm}

function EditBanklinkOnlineSettings(AClient: Client): boolean;
var
  BanklinkOnlineSettings: TfrmBanklinkOnlineSettings;
begin
  if AdminSystem.fdFields.fdUse_BankLink_Online then
  begin
    BanklinkOnlineSettings := TfrmBanklinkOnlineSettings.Create(Application.MainForm);
    try
      Result := BanklinkOnlineSettings.Execute(AClient);
    finally
      BanklinkOnlineSettings.Free;
    end;
  end;
end;

procedure TfrmBanklinkOnlineSettings.btnOKClick(Sender: TObject);
var
  EmailChanged, ProductsChanged, BillingFrequencyChanged, ProductFound: boolean;
  NewProducts: TStringList;
  PromptMessage, ErrorMsg: string;
  i, j, ButtonPressed: integer;
begin
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
                '�' + edtEmailAddress.Text + '�.' + #10 + #10 +
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

procedure TfrmBanklinkOnlineSettings.CheckClientConnectControls;
begin
  lblClientConnect.Enabled := rbActive.Checked;
  cmbConnectDays.Enabled := rbActive.Checked;
end;

procedure TfrmBanklinkOnlineSettings.chkUseClientDetailsClick(Sender: TObject);
begin
  FillClientDetails;
end;

function TfrmBanklinkOnlineSettings.Execute(AClient: Client): boolean;
var
  i, k: integer;
  CatArray: ArrayOfCatalogueEntry;
  GUID1, GUID2: WideString;
  AClientID: WideString;
begin
  //ClientGUID = ProductConfigService.GetClientGUID(MyClient.Code);
  //if ClientGUID <> '' then
  //  FClient := ProductConfigService.GetClient(ClientGUID )
  //else
  //  FClient := Client.Create;
  //  FClient.ClientCode :=  MyClient.Code;
  //  FClient.Email :=  MyClient.Email;
  //  FClient.Name :=  MyClient.Name;
  //  FClient.Catalogue :=  ProductConfigService.Clients.Catalogue

//    AClientID := ProductConfigService.Clients.Clients[0].Id;
    Result := False;
    if Assigned(AClient) then begin
      FClient := AClient;
      rbActive.Checked := true; // may be overriden by one of the two lines below
      rbSuspended.Checked := FClient.Suspended;
      rbDeactivated.Checked := FClient.Deactivated;
      cmbConnectDays.Text := FClient.ClientConnectDays;
      chkUseClientDetails.Checked := FClient.UseClientDetails;
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

    if ShowModal = mrOk then
      Result := True;
end;

procedure TfrmBanklinkOnlineSettings.btnClearAllClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to chkListProducts.Items.Count - 1 do
    chkListProducts.Checked[i] := false;
end;

procedure TfrmBanklinkOnlineSettings.FillClientDetails;
begin
  if chkUseClientDetails.Checked then
  begin
    edtUserName.Text := FContactName;
    edtEmailAddress.Text  := FEmailAddress;
  end;
  edtUserName.Enabled := not chkUseClientDetails.Checked;
  edtEmailAddress.Enabled := not chkUseClientDetails.Checked;
end;

procedure TfrmBanklinkOnlineSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  ListOfClients.Free;
  chklistProducts.Clear;
end;

procedure TfrmBanklinkOnlineSettings.FormShow(Sender: TObject);
begin
  FillClientDetails;
end;

procedure TfrmBanklinkOnlineSettings.rbActiveClick(Sender: TObject);
begin
  CheckClientConnectControls;
end;

procedure TfrmBanklinkOnlineSettings.rbDeactivatedClick(Sender: TObject);
begin
  CheckClientConnectControls;
end;

procedure TfrmBanklinkOnlineSettings.rbSuspendedClick(Sender: TObject);
begin
  CheckClientConnectControls;
end;   

procedure TfrmBanklinkOnlineSettings.SetContactName(Value: string);
begin
  FContactName := Value;
end;

procedure TfrmBanklinkOnlineSettings.SetEmailAddress(Value: string);
begin
  FEmailAddress := Value;
end;

end.
