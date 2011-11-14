unit BanklinkOnlineSettingsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, CheckLst;

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
    procedure rbClientAlwaysOnlineClick(Sender: TObject);
    procedure rbClientMustConnectClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
  private
    productBoxes: array of TCheckBox;
  public
    { Public declarations }
  end;

var
  frmBanklinkOnlineSettings: TfrmBanklinkOnlineSettings;

implementation

uses
  BlopiServiceFacade;

{$R *.dfm}

procedure TfrmBanklinkOnlineSettings.btnSelectAllClick(Sender: TObject);
var
  Cat: CatalogueEntry;
  CatArray: ArrayOfCatalogueEntry;
  ListOfClients: ClientList;
  ClientArray: ArrayOfClient;
  SubArray: ArrayOfGuid;
  GUID: TGuid;
  i, k: integer;
  Client1: Client;
  GUID1, GUID2: WideString;
begin
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

    Client1 := Client.Create;
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
      end;
    end;
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
