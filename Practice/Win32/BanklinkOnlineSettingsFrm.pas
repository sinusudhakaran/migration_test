unit BanklinkOnlineSettingsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, CheckLst, BlopiServiceFacade;

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

  published
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
    rbMonthly: TRadioButton;
    rbAnnually: TRadioButton;
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
    Client1: Client;
    procedure rbClientAlwaysOnlineClick(Sender: TObject);
    procedure rbClientMustConnectClick(Sender: TObject);
    procedure btnTempClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnClearAllClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    productBoxes: array of TCheckBox;
  public
    { Public declarations }
  end;

var
  frmBanklinkOnlineSettings: TfrmBanklinkOnlineSettings;

implementation

{$R *.dfm}

procedure TfrmBanklinkOnlineSettings.btnOKClick(Sender: TObject);
begin
  if (edtEmailAddress.Text <> Client1.EmailAddress) then
    ShowMessage('You have changed the Default Client Administrator Email Address. ' +
                'The new Default Client Administrator will be set to ' +
                '‘' + edtEmailAddress.Text + '’.' + #10 + #10 +
                'Are you sure you want to continue?');
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
  Cat: CatalogueEntry;
  CatArray: ArrayOfCatalogueEntry;
  ListOfClients: ClientList;
  ClientArray: ArrayOfClient;
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
    Cat := CatalogueEntry.Create;
    Cat.CatalogueType := 'TestCat1';
    CreateGUID(GUID);
    Cat.Id := GuidToString(GUID);

    SetLength(CatArray, 1);
    CatArray[0] := Cat;

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
    SetLength(SubArray, 1);
    SubArray[0] := CatArray[0].Id;
    Client1.Subscription := SubArray;

    ListOfClients.Clients[0] := Client1;

    chklistProducts.AddItem(ListOfClients.Catalogue[0].CatalogueType, TObject(ListOfClients.Catalogue[0].Id));

    for i := 0 to chklistProducts.Items.Count - 1 do begin
      for k := Low(Client(ListOfClients.Clients[0]).Subscription) to High(Client(ListOfClients.Clients[0]).Subscription) do begin
        GUID1 := Client(ListOfClients.Clients[0]).Subscription[k];
        GUID2 := WideString(chklistProducts.Items.Objects[i]);
        chklistProducts.Checked[i] := (GUID1 = GUID2);
        // Set deactivated checkbox to checked if client is deactivated
      end;
    end;
  end;  
end;

procedure TfrmBanklinkOnlineSettings.FormCreate(Sender: TObject);
begin
  Client1 := Client.Create;
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

function TClientHelper.GetBillingEndDate: TDateTime;
begin
  Result := StrToDate('31/12/2011');
end;

function TClientHelper.GetBillingFrequency: string;
begin
  Result := 'Monthly';
end;

end.
