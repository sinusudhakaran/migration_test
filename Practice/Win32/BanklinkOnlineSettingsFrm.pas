unit BanklinkOnlineSettingsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, CheckLst, BlopiServiceFacade;

type
  TClientHelper = Class helper for BlopiServiceFacade.ClientSummary
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

  published
    procedure SetUseClientDetails(value: boolean);
  public
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
    Client1: ClientSummary;
    procedure rbClientAlwaysOnlineClick(Sender: TObject);
    procedure rbClientMustConnectClick(Sender: TObject);
    procedure btnTempClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnClearAllClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    SubArray: ArrayOfGuid;
    productBoxes: array of TCheckBox;
  public
    { Public declarations }
  end;

var
  frmBanklinkOnlineSettings: TfrmBanklinkOnlineSettings;
  BanklinkOnlineConnected : boolean = true;

implementation

{$R *.dfm}

procedure TfrmBanklinkOnlineSettings.btnOKClick(Sender: TObject);
var
  EmailChanged, ProductsChanged, BillingFrequencyChanged, ProductFound: boolean;
  NewProducts: TStringList;
  AllNewProducts, PromptMessage: string;
  i, j, ButtonPressed: integer;
begin
  if not BanklinkOnlineConnected then
  begin
    ShowMessage('Banklink Practice is unable to connect to Banklink Online and so ' +
                'cannot update this client''s settings');
    Exit;
  end;

  EmailChanged := (edtEmailAddress.Text <> Client1.EmailAddress);
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
  BillingFrequencyChanged := cmbBillingFrequency.Text <> Client1.BillingFrequency;

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
                     Client1.UserName + ':';
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
  ListOfClients: ClientList;
  ClientArray: ArrayOfClientSummary;
  SubArray: ArrayOfGuid;
  GUID: TGuid;
  i, k: integer;
  GUID1, GUID2: WideString;
begin
  if btnTemp.Caption = 'Switch to offline' then
  begin
    // Switched to offline
    btnTemp.Caption := 'Switch to online';
  end else
  begin
    // Switched to online
    btnTemp.Caption := 'Switch to offline';

    // Temporary functionality, move it to FormCreate or FormShow later
    SetLength(CatArray, 2);

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
    ListOfClients.Clients := ClientArray;

    chkSuspendClient.Checked := Client1.Status = Suspended;
    chkDeactivateClient.Checked := Client1.Deactivated;
    if (StrToInt(Client1.ClientConnectDays) = 0) then
    begin
      rbClientAlwaysOnline.Checked := true;
    end else
    begin
      rbClientMustConnect.Checked := true;
      cmbDays.Text := Client1.ClientConnectDays;
    end;
    if (Client1.UserOnTrial) then
    begin
      lblFreeTrial.Caption := 'Free Trial until ' + DateTimeToStr(Client1.FreeTrialEndDate);
    end else
    begin
      lblFreeTrial.Caption := 'Currently billed {' + Client1.BillingFrequency + '} until ' + DateTimeToStr(Client1.BillingEndDate);
    end;
    if (Client1.UseClientDetails) then
    begin
      chkUseClientDetails.Checked := true;
      edtUserName.Text := Client1.UserName;
      edtEmailAddress.Text := Client1.EmailAddress;
    end;

    CreateGUID(GUID);
    Client1.Id := GuidToString(GUID);
    {
    SetLength(SubArray, 2);
    SubArray[0] := CatArray[0].Id;
    SubArray[1] := CatArray[1].Id;
    }
    Client1.Subscription := SubArray;

    ListOfClients.Clients[0] := Client1;

    for i := Low(CatArray) to High(CatArray) do
      chklistProducts.AddItem(ListOfClients.Catalogue[i].CatalogueType, TObject(ListOfClients.Catalogue[i].Id));

    for i := 0 to chklistProducts.Items.Count - 1 do begin
      for k := Low(Client(ListOfClients.Clients[0]).Subscription) to High(Client(ListOfClients.Clients[0]).Subscription) do begin
        GUID1 := Client(ListOfClients.Clients[0]).Subscription[k];
        GUID2 := WideString(chklistProducts.Items.Objects[i]);
        chklistProducts.Checked[i] := (GUID1 = GUID2);
        if chklistProducts.Checked[i] then break;
      end;
    end;
  end;
end;

procedure TfrmBanklinkOnlineSettings.FormCreate(Sender: TObject);
begin
  Client1 := ClientSummary.Create;
end;

procedure TfrmBanklinkOnlineSettings.rbClientAlwaysOnlineClick(Sender: TObject);
begin
  cmbDays.Enabled := false;
end;

procedure TfrmBanklinkOnlineSettings.rbClientMustConnectClick(Sender: TObject);
begin
  cmbDays.Enabled := true;
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

procedure TClientHelper.SetUseClientDetails(value: boolean);
begin
  SetUseClientDetails(value);
end;

function TClientHelper.GetBillingEndDate: TDateTime;
begin
  Result := StrToDate('31/12/2011');
end;

function TClientHelper.GetBillingFrequency: string;
begin
  Result := 'Monthly';
end;

end.
