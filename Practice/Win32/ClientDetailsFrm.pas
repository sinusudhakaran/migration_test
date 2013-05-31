unit ClientDetailsFrm;
//------------------------------------------------------------------------------
{
  Title:    Client Detail Form

  Written:
  Authors:

  Purpose:  Allow editing of client details

  Notes:
}
//------------------------------------------------------------------------------

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  OvcBase,
  Buttons,
  OvcABtn,
  OvcEF,
  OvcPB,
  OvcPF,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  OvcNF,
  WinUtils,
  OsFont,
  BanklinkOnlineSettingsFrm,
  BankLinkOnlineServices,
  BlopiClient;

const
  UM_AFTERSHOW = WM_USER + 1;

type

  TfrmClientDetails = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    OvcController1: TOvcController;
    PageControl1: TPageControl;
    tbsClient: TTabSheet;
    tbsAdmin: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    eCode: TEdit;
    eName: TEdit;
    eContact: TEdit;
    ePhone: TEdit;
    ePassword: TEdit;
    eFinYear: TOvcPictureField;
    eMail: TEdit;
    Label12: TLabel;
    eConfirm: TEdit;
    eFax: TEdit;
    Label13: TLabel;
    Label14: TLabel;
    lblCountry: TLabel;
    tbsNotes: TTabSheet;
    meNotes: TMemo;
    chkShowOnOpen: TCheckBox;
    cmbResponsible: TComboBox;
    Label6: TLabel;
    tbsOptions: TTabSheet;
    chkNewTrx: TCheckBox;
    chkOffsite: TCheckBox;
    grpDownLoadSettings: TGroupBox;
    lblConnectName: TLabel;
    eConnectCode: TEdit;
    pnlContactOptions: TPanel;
    radPractice: TRadioButton;
    radStaffMember: TRadioButton;
    radCustom: TRadioButton;
    pnlContactDetails: TPanel;
    edtContactName: TEdit;
    edtContactPhone: TEdit;
    edtContactEmail: TEdit;
    lblContactNameView: TLabel;
    lblPhoneView: TLabel;
    lblEmailView: TLabel;
    lblEmail: TLabel;
    lblPhone: TLabel;
    lblContactName: TLabel;
    Label17: TLabel;
    eAddr1: TEdit;
    eAddr2: TEdit;
    eAddr3: TEdit;
    Label10: TLabel;
    pnlWebsiteOptions: TPanel;
    radPracticeWebSite: TRadioButton;
    radCustomWebsite: TRadioButton;
    pnlWebsiteDetails: TPanel;
    Label16: TLabel;
    edtLoginURL: TEdit;
    lblWebSite: TLabel;
    chkFillNarration: TCheckBox;
    lblMethod: TLabel;
    cmbOSDMethod: TComboBox;
    Label15: TLabel;
    eMobile: TEdit;
    Label11: TLabel;
    txtLastDiskID: TEdit;
    Label18: TLabel;
    eSal: TEdit;
    tsSmartLink: TTabSheet;
    Label19: TLabel;
    edtFingertipsClientID: TEdit;
    Label20: TLabel;
    grpBooks: TGroupBox;
    chkForceCheckout: TCheckBox;
    chkDisableCheckout: TCheckBox;
    chkArchived: TCheckBox;
    Label21: TLabel;
    cmbGroup: TComboBox;
    Label22: TLabel;
    cmbType: TComboBox;
    chkGenerateFinancial: TCheckBox;
    chkUnlockEntries: TCheckBox;
    chkEditChart: TCheckBox;
    chkEditMems: TCheckBox;
    grpBOClients: TGroupBox;
    btnClientSettings: TButton;
    Panel1: TPanel;
    lblClientBOProducts: TLabel;

    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure FormShow(Sender: TObject);
    procedure chkOffsiteClick(Sender: TObject);
    procedure eFinYearError(Sender: TObject; ErrorCode: Word;
      ErrorMsg: String);
    procedure cmbResponsibleChange(Sender: TObject);
    procedure radPracticeClick(Sender: TObject);
    procedure radPracticeWebSiteClick(Sender: TObject);
    procedure txtLastDiskIDChange(Sender: TObject);
    procedure chkForceCheckoutClick(Sender: TObject);
    procedure chkDisableCheckoutClick(Sender: TObject);
    procedure btnClientSettingsClick(Sender: TObject);
    procedure UpdateProductsLabel;

  private
    { Private declarations }
    okPressed : boolean;
    wasClientCode, prospectCode : string;
    CreatingClient : boolean;
    ChangingDiskID : boolean;
    PassGenCodeEntered : boolean;
    FViewNotes : Boolean;
    FEnableClientSettings : boolean;
    FUseClientDetailsForBankLinkOnline: Boolean;

    FInWizard: Boolean;

    FClientReadDetail: TBloClientReadDetail;
    FLoading: Boolean;

    function CountClientProducts(ClientDetails: TBloClientReadDetail): Integer;
    function GetClientSubscriptionCategory(SubscriptionId: TBloGuid): TBloCatalogueEntry;
    
    function  OkToPost : boolean;
    procedure UpdatePracticeContactDetails( ContactType : byte);
    procedure ShowPracticeContactDetails(ReadOnly : Boolean);
    procedure SetProductsCaption(NewCaption: string);

    procedure WMKillFocus(var w_Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMActivate(var w_Message: TWMActivate); message WM_ACTIVATE;

    procedure AfterShow(var Message: TMessage); message UM_AFTERSHOW;
  public
    { Public declarations }
    function Execute(PCode: string = ''; InWizard: Boolean = False) : boolean;
  end;

  function EditClientDetails (w_PopupParent: Forms.TForm; ViewNotes : Boolean = False) : boolean;
  function NewClientDetails(w_PopupParent: Forms.TForm; PCode: string = ''; EnableClientSettings: boolean = true; InWizard: Boolean = False) : boolean;

//------------------------------------------------------------------------------
implementation

uses
   ClientHomePagefrm,
   ComboUtils,
   globals,
   WarningMoreFrm,
   admin32,
   BKHelp,
   syDefs,
   YesNoDlg,
   LogUtil,
   bkDateUtils,
   EnterPwdDlg,
   SelectDate,
   files,
   DownloadUtils,
   stDate,
   bkXPThemes,
   ThirdPartyHelper,
   bkConst,
   BKDEFS,
   ClientUtils,
   AuditMgr,
   InfoMoreFrm,
   WebUtils,
   BlopiServiceFacade,
   RegExprUtils,
   glConst,
   BankLinkSecureCodeDlg,
   GenUtils,
   bkBranding, bkProduct;

{$R *.DFM}

const
   Unitname = 'ClientDetailsFrm';
   lnone = '<none>';

//------------------------------------------------------------------------------
procedure TfrmClientDetails.FormCreate(Sender: TObject);
begin
   FLoading := False;
   FEnableClientSettings := true;
   bkXPThemes.ThemeForm( Self);
   lblCountry.Font.Name := Font.Name;
   lblConnectName.caption := bkBranding.BooksProductName+' Co&de';
   chkOffsite.Caption := 'Allow client to download directly via ' + TProduct.BrandName + ' &Secure';

   SetUpHelp;

   eFinYear.Epoch         := BKDATEEPOCH;
   eFinYear.PictureMask   := BKDATEFORMAT;

   SetPasswordFont(ePassword);
   SetPassWordFont(eConfirm);

   cmbOSDMethod.Clear;
   cmbOSDMethod.Items.AddObject( bkConst.dfNames[ dfConnect], TObject( dfConnect));
   cmbOSDMethod.Items.AddObject( bkConst.dfNames[ dfFloppy], TObject( dfFloppy));

   ChangingDiskID := false;
   grpBooks.Caption := bkBranding.BooksProductName + ' Clients';

   grpBOClients.Caption := TProduct.Rebrand(grpBOClients.Caption);
end;

//------------------------------------------------------------------------------
procedure TfrmClientDetails.FormShow(Sender: TObject);
var
  ClientSynced: boolean;
  CachedPracticeDetail: TBloPracticeRead;
begin
  PageControl1.ActivePage := tbsClient;

  If Assigned( AdminSystem) and ( not MyClient.clFields.clFile_Read_Only) then begin
     ECode.Enabled := True;
     ECode.SetFocus;
  end
  else begin
     ECode.Enabled := False;
  end;

  if (CurrUser.HasRestrictedAccess) then
  begin
    eCode.Color := clBtnFace;
    eCode.ReadOnly := True;
  end else
  begin
    eCode.Color := clWindow;
    eCode.ReadOnly := False;
  end;

  case MyClient.clFields.clContact_Details_To_Show of
    cdtPractice:
      radPractice.Checked := True;
    cdtStaffMember:
      radStaffMember.Checked := True;
    cdtCustom:
      radCustom.Checked := True;
  else
    radPractice.Checked := True;
  end;

  //Third party DLL allows users to specify the custom contact details even
  //when the file is not part of the practice
  if ThirdPartyDllDetected and AllowEditingOfCustomContactDetails then
    radCustom.Checked := true;

  lblMethod.Visible := PRACINI_AllowOffsiteDiskDownload or (MyClient.clFields.clTemp_Old_Download_From = dfFloppy);
  cmbOSDMethod.Visible := lblMethod.Visible;

  edtContactName.Text  := MyClient.clFields.clCustom_Contact_Name;
  edtContactPhone.Text := MyClient.clFields.clCustom_Contact_Phone;
  edtContactEmail.Text := MyClient.clFields.clCustom_Contact_EMail_Address;

  edtLoginURL.Text     := MyClient.clFields.clWeb_Site_Login_URL;

  radPracticeWebSite.Checked := edtLoginURL.Text = '';
  radCustomWebsite.Checked   := not radPracticeWebSite.Checked;
  radPracticeWebSiteClick( nil);

  if prospectCode <> '' then // Hopefully they will only need to fill in the year start...
    eFinYear.SetFocus
  else if FViewNotes then
     PageControl1.ActivePage := tbsNotes;
  chkArchived.Visible := CurrUser.CanAccessAdmin;
  chkArchived.Enabled :=Assigned(AdminSystem) and (AdminSystem.fdFields.fdMagic_Number = MyClient.clFields.clMagic_Number);
{$IFDEF SmartLink}
  tsSmartLink.TabVisible := CurrUser.CanAccessAdmin;
{$ELSE}
  tsSmartLink.TabVisible := false;
{$ENDIF}

  //BankLink Online
  lblClientBOProducts.Visible := False;
  btnClientSettings.Enabled := False;
  grpBOClients.Visible := Assigned(AdminSystem) and not CurrUser.HasRestrictedAccess;
  if grpBOClients.Visible then
  begin
    ClientSynced := AdminSystem.fdFields.fdMagic_Number = MyClient.clFields.clMagic_Number;

    if ProductConfigService.ServiceActive then begin
      lblClientBOProducts.Visible := ClientSynced;

      btnClientSettings.Enabled := ClientSynced and
                                   FEnableClientSettings and
                                   not (ProductConfigService.OnlineStatus = staDeactivated) and
                                   CurrUser.CanAccessAdmin;

      lblClientBOProducts.Visible := ClientSynced and
                                     CurrUser.CanAccessAdmin;

      ProductConfigService.LoadClientList;
      if lblClientBOProducts.Visible  then
      begin
        if not FEnableClientSettings then
          SetProductsCaption('Please save the client to access the ' + bkBranding.ProductOnlineName + ' settings')
        else if not (ProductConfigService.OnlineStatus = staActive) then
          case ProductConfigService.OnlineStatus of
            Suspended:   SetProductsCaption(bkBranding.ProductOnlineName + ' is currently in suspended ' +
                                            '(read-only) mode. Please contact ' + TProduct.BrandName +
                                            'Support for further assistance');
            Deactivated: SetProductsCaption(bkBranding.ProductOnlineName + ' is currently deactivated. Please ' +
                                            'contact ' + TProduct.BrandName + ' Support for further assistance');
          end
        else
        begin
          CachedPracticeDetail := ProductConfigService.CachedPractice;

          if btnClientSettings.Enabled then
          begin
            FClientReadDetail := ProductConfigService.GetClientDetailsWithCode(MyClient.clFields.clCode, True);
          end;
          
          if btnClientSettings.Enabled and Assigned(CachedPracticeDetail) then
            UpdateProductsLabel;
        end;
      end;
    end;
  end;

  PostMessage(Handle, UM_AFTERSHOW, 0, 0);
end;

function TfrmClientDetails.GetClientSubscriptionCategory(SubscriptionId: TBloGuid): TBloCatalogueEntry;
var
  Index: Integer;
begin
  Result := nil;

  if not Assigned(FClientReadDetail) then
  begin
    Exit;
  end;

  for Index := 0 to Length(FClientReadDetail.Catalogue) - 1 do
  begin
    if ProductConfigService.GuidsEqual(FClientReadDetail.Catalogue[Index].Id, SubscriptionId) then
    begin
      Result := FClientReadDetail.Catalogue[Index];

      Break;
    end;
  end;
end;

procedure TfrmClientDetails.SetProductsCaption(NewCaption: string);
begin
  lblClientBOProducts.Caption := TProduct.Rebrand(NewCaption);
end;

procedure TfrmClientDetails.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   eCode.Hint           :=
                        'Enter a unique code for this Client|' +
                        'Enter a unique code for this Client';
   eName.Hint           :=
                        'Enter the Client''s full name|' +
                        'Enter the Client''s full name for use on Reports';
   eAddr1.Hint          :=
                        'Enter the Client''s full postal address|' +
                        'Enter the Client''s full postal address';
   eAddr2.Hint          :=
                        'Enter the Client''s full postal address|' +
                        'Enter the Client''s full postal address';
   eAddr3.Hint          :=
                        'Enter the Client''s full postal address|' +
                        'Enter the Client''s full postal address';
   eContact.Hint        :=
                        'Enter a contact name|' +
                        'Enter name of a contact person at this Client';
   ePhone.Hint          :=
                        'Enter the Client''s Phone number|' +
                        'Enter the Client''s contact Phone number';
   eMobile.Hint         :=
                        'Enter the Client''s Mobile number|' +
                        'Enter the Client''s contact Mobile number';
   eSal.Hint         :=
                        'Enter the Client''s Salutation|' +
                        'Enter the Client''s Salutation';
   eFax.Hint            :=
                        'Enter the Client''s Fax number|' +
                        'Enter the Client''s Fax number';
   eMail.Hint           :=
                        'Enter the Client''s E-mail address|' +
                        'Enter the Client''s E-mail address';
   eFinYear.Hint        :=
                        'Enter financial year start date|' +
                        'Enter the Client''s current financial year start date';
   ePassword.Hint       :=
                        'Enter a Password|' +
                        'Enter a Password to restrict access to this Client File';
   eConfirm.hint        :=
                        'Confirm the Password entered above|'+
                        'Re-enter the Password entered above to confirm it';
   cmbResponsible.hint  :=
                        'Select a Staff Member|' +
                        'Select the Staff Memeber who is responsible for this Client';
   cmbGroup.hint  :=
                        'Select a Group|' +
                        'Select the Group for this Client';
   cmbType.hint  :=
                        'Select a Client Type|' +
                        'Select the Client Type of this Client';

   chkNewTrx.Hint       :=
                        'Do you want to check for new transactions when the Client File is opened?|'+
                        'Check this if you want to retrieve new transaction data as it becomes available.';

   {chkPurge.Hint        :=
                        'Do you want to be prompted to purge old entries when the Client File is opened?|'+
                        'Check this if you want to be prompted on open to purge old entries.'; }

   chkOffsite.Hint      :=
                        'Check to configure this Client for downloading of transactions in ' + bkBranding.BooksProductName + '|'+
                        'Check to configure this Client for downloading of transactions in ' + bkBranding.BooksProductName;

   eConnectCode.Hint    :=
                        'Enter the '+SHORTAPPNAME+' Code for this Off-site Client|'+
                        'Enter the '+SHORTAPPNAME+' Code assigned to your Off-site Client';

   txtLastDiskID.Hint     :=
                        'Enter the id of the last '+SHORTAPPNAME+' data file processed|'+
                        'Enter the id of the last '+SHORTAPPNAME+' data file processed for this Client';

   meNotes.Hint         :=
                        'Enter any notes about the client file|'+
                        'Enter any notes about the client file';

   chkArchived.Hint       :=
                        'Do you want to archive this client file?|'+
                        'Check this if you want to archive this client file.';

   chkGenerateFinancial.Hint := 'Allow Books Users to Generate Financial Reports|'+
    'Allow Books Users to Generate Financial Reports ';

   chkUnlockEntries.Hint := 'Allow Books Users to unlock entries and clear the transfer flags|' +
                            'Allow Books Users to unlock entries and clear the transfer flags';

   chkEditChart.Hint := 'Allow Books Users to edit the chart of account items|' +
                        'Allow Books Users to edit the chart of account items';

end;

//------------------------------------------------------------------------------
procedure TfrmClientDetails.btnClientSettingsClick(Sender: TObject);
var
  ShowServicesAvailable: boolean;
begin
  // These need to be updated immediately so that the user name and email address in
  // the Banklink Online Settings form will be populated correctly when 'Use Client
  // Details' is ticked
  MyClient.clFields.clContact_name := econtact.text;
  MyClient.clFields.clClient_EMail_Address := eMail.text;

  // Without Data Export nothing will be displayed
  if ProductConfigService.IsExportDataEnabled then
  begin
    // Display services, provided it has vendors
    // Note: services are always visible - no matter what chkOffsite is
    ShowServicesAvailable := ProductConfigService.PracticeHasVendors
  end
  else
  begin
    // BanklinkOnlineSettingsFrm will determine whether to display services or not
    ShowServicesAvailable := true;
  end;

  if EditBanklinkOnlineSettings(Self, MyClient.clFields.clWeb_Export_Format = wfWebNotes,
                                false, ShowServicesAvailable) then
  begin
    FClientReadDetail := ProductConfigService.GetClientDetailsWithCode(MyClient.clFields.clCode, False);
    
    UpdateProductsLabel;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientDetails.btnOkClick(Sender: TObject);
begin
  if okToPost then
  begin
    okPressed := true;
    Close;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientDetails.AfterShow(var Message: TMessage);
begin
  //Prevent the application from disapearing begin another application
  BringToFront;
end;

procedure TfrmClientDetails.btnCancelClick(Sender: TObject);
begin
  close;
end;

//------------------------------------------------------------------------------
function TfrmClientDetails.OkToPost: boolean;
var
  cfRec : pClient_File_REc;
  NameExists : boolean;
  CodeType: string;
  BlankEmailIsValid: boolean;
  SecureCode: String;
begin
  result := false;

  //check code
  eCode.Text := Trim( eCode.Text);

  if eCode.Text = '' then
  begin
     HelpfulWarningMsg('You must enter a client code. Please try again', 0 );
     PageControl1.ActivePage := tbsClient;
     eCode.setfocus;
     exit;
  end;

  if ((eCode.Text <> wasClientCode) or CreatingClient) and (eCode.Text <> prospectCode) then
  begin
     {check for duplicate name or file if no admin}
     NameExists := false;
     if Assigned(AdminSystem) then
     begin
       cfRec := AdminSystem.fdSystem_Client_File_List.FindCode(eCode.Text);
       if cfRec <> nil then
       begin
         if cfRec.cfClient_Type = ctProspect then
           CodeType := 'Prospect'
         else
           CodeType := 'Client';
         NameExists := true;
       end;
     end
       else
     begin
       {no admin system.. check for file with this name}
       if BKFileExists(DATADIR + eCode.Text + FILEEXTN) then
       begin
         CodeType := 'Client';
         NameExists := true;
       end;
     end;

     if NameExists then
     begin
       HelpfulWarningMsg('A ' + CodeType + ' with this code already exists. Please try a different code.', 0 );
       PageControl1.ActivePage := tbsClient;
       eCode.setfocus;
       exit;
     end;
  end;

  if IsaBadCode(eCode.Text) then
  begin
    HelpfulWarningMsg('You have entered an illegal client code, or a code that contains illegal characters.  Please try again.',0);
    PageControl1.ActivePage := tbsClient;
    eCode.setfocus;
    exit;
  end;

  //check name
  if eName.Text = '' then
  begin
     HelpfulWarningMsg('You must enter a client name. Please try again.',0);
     PageControl1.ActivePage := tbsClient;
     eName.setfocus;
     exit;
  end;

  if not (ePassword.Text = eConfirm.Text) then
  begin
     HelpfulWarningMsg('The passwords you have entered do not match. Please enter them again.',0);
     PageControl1.ActivePage := tbsClient;
     ePassword.SetFocus;
     exit;
  end;

  if eFinYear.AsStDate = -1 then
  begin
     HelpfulWarningMsg('You must specify a financial year start date.  Please try again.',0);
     PageControl1.ActivePage := tbsClient;
     eFinYear.SetFocus;
     exit;
  end;

  if not (eFinYear.IsValid) then
  begin
     HelpfulWarningMsg('The financial year start date is not valid. Please try again.', 0 );
     PageControl1.ActivePage := tbsClient;
     eFinYear.SetFocus;
     exit;
  end;

  //see if the client is assigned to unknown user
  if cmbResponsible.Enabled then
  begin
    if (cmbResponsible.ItemIndex = cmbResponsible.Items.Count - 1) then
    begin
      HelpfulWarningMsg('The person responsible is set to an unknown user. Please correct this.', 0 );
      PageControl1.ActivePage := tbsAdmin;
      cmbResponsible.SetFocus;
      Exit;
    end;
  end;

  //see if the client is assigned to unknown group
  if cmbGroup.Enabled then
  begin
    if (cmbGroup.ItemIndex = cmbGroup.Items.Count - 1) then
    begin
      HelpfulWarningMsg('This client is set to an unknown Group. Please correct this.', 0 );
      PageControl1.ActivePage := tbsAdmin;
      cmbGroup.SetFocus;
      Exit;
    end;
  end;

  //see if the client is assigned to unknown typ
  if cmbType.Enabled then
  begin
    if (cmbType.ItemIndex = cmbType.Items.Count - 1) then
    begin
      HelpfulWarningMsg('This client is set to an unknown Client Type. Please correct this.', 0 );
      PageControl1.ActivePage := tbsAdmin;
      cmbType.SetFocus;
      Exit;
    end;
  end;

  //last disk id
  if DownloadUtils.SuffixToSequenceNo( txtLastDiskID.Text) = DownloadUtils.InvalidSuffixValue then
  begin
    if txtLastDiskID.Visible then
    begin
      HelpfulWarningMsg( 'The Last Disk Processed ID is invalid.', 0);
      PageControl1.ActivePage := tbsOptions;
      txtLastDiskID.SetFocus;
      Exit;
    end;
  end;

  BlankEmailIsValid := false;
  // Cico valid Email
  if (Assigned(AdminSystem)) and
     (ProductConfigService.ServiceActive) and
     (ProductConfigService.IsCICOEnabled) and
     (not RegExIsEmailValid(EMail.Text)) then
  begin
    if (Trim(Email.Text) = '') then
    begin
      BlankEmailIsValid := true; // blank emails are allowed under these circumstances
    end else
    begin
      HelpfulWarningMsg('You have selected' + #13 +
                        'Enhanced Client File Handling.' + #13#13 +
                        'This requires a Valid E-mail address.', 0);
      PageControl1.ActivePage := tbsClient;
      EMail.SetFocus;
      Exit;
    end;
  end;

  // Web Export to BankLink test
  if (MyClient.clFields.clWeb_Export_Format = wfWebNotes) and not FInWizard then
  begin
    CodeType := format( 'You have selected'#13'Web export to %s,'#13'under Accounting System.'#13#13, [bkBranding.NotesOnlineProductName]);
    if EContact.Text = '' then
    begin
      HelpfulWarningMsg(CodeType + 'This requires a Contact Name.', 0);
      PageControl1.ActivePage := tbsClient;
      EContact.SetFocus;
      Exit;
    end;
    if (not RegExIsEmailValid(EMail.Text)) then
    begin
      if not (BlankEmailIsValid) and (Trim(Email.Text) = '') then
      begin
        HelpfulWarningMsg(CodeType + 'This requires a Valid E-mail address.', 0);
        PageControl1.ActivePage := tbsClient;
        EMail.SetFocus;
        Exit;
      end;
    end;
  end;

  if chkOffsite.Checked then
  begin
    if Trim(eConnectCode.Text) = '' then
    begin
      case AskYesNo(TProduct.BrandName + ' Secure Code', 'The ' + TProduct.BrandName + ' Secure Code for this client has not been set.  Would you like to set it now?', DLG_YES, 0, True) of
        glConst.DLG_CANCEL:
        begin
          if PageControl1.ActivePage <> tbsOptions then
          begin
            PageControl1.ActivePage := tbsOptions;
          end;
          
          eConnectCode.SetFocus;

          Exit;
        end;

        glConst.DLG_YES:
        begin
          if TfrmBankLinkSecureCode.PromptUser(Self, SecureCode) then
          begin
            eConnectCode.Text := SecureCode;
          end
          else
          begin
            if PageControl1.ActivePage <> tbsOptions then
            begin
              PageControl1.ActivePage := tbsOptions;
            end;

            eConnectCode.SetFocus;

            Exit;
          end;
        end;
      end;
    end;
  end;

  Result := true;
end;

//------------------------------------------------------------------------------
function TfrmClientDetails.Execute(PCode: string = ''; InWizard: Boolean = False): boolean;
var
  AdminLoaded   : boolean;
  i             : integer;
  StoredIndex, StoredIndexGroup, StoredIndexType : integer;
  User          : pUser_Rec;
  Group         : pGroup_Rec;
  ClientType    : pClient_Type_Rec;
  indx, IndxGroup, IndxType: integer;
  FileRenamed   : boolean;
  StaffName     : string;
  S             : string;
  MemoText      : string;
  StartPos      : integer;
  d,m,y         : integer;

  OldFinancialYear : integer;
  DetailsChanged   : boolean;
  LastDiskSequenceNo : integer;
  AllowClientDirectDownload: Boolean;
  SecureCode: String;
  PrimaryUser: TBloUserRead;
begin
   FClientReadDetail := nil;

   okPressed := false;
   FileRenamed := false;
   AdminLoaded := RefreshAdmin;  //stored - will be used later too

   FInWizard := InWizard;

   with MyClient.clFields do
   begin
     FLoading := True;

     try
       eCode.text    := clCode;
       wasClientCode := clCode;    //store for later
       prospectCode := PCode;

       eName.Text    := clName;
       eAddr1.text   := clAddress_L1;
       eAddr2.text   := clAddress_L2;
       eAddr3.text   := clAddress_L3;
       eContact.Text := clContact_Name;
       ePhone.text   := clPhone_No;
       eMobile.Text  := clMobile_No;
       eFax.text     := clFax_No;
       eSal.Text     := clSalutation;


       eFinYear.AsStDate := BKNull2St( clFinancial_Year_Starts );
       eMail.Text        := clClient_EMail_Address;

       edtLoginURL.Text  := clWeb_Site_Login_URL;

       ePassword.text := clFile_Password;
       eConfirm.Text  := clFile_Password;

       ChangingDiskID := true;
       try
         txtLastDiskID.Text    := DownloadUtils.MakeSuffix(clDisk_Sequence_No);
       finally
         ChangingDiskID := false;
       end;

       chkGenerateFinancial.Visible := AdminLoaded and CurrUser.CanAccessAdmin;
       chkUnlockEntries.Visible := AdminLoaded and CurrUser.CanAccessAdmin;
       chkEditChart.Visible := AdminLoaded and CurrUser.CanAccessAdmin;
       chkEditMems.Visible := AdminLoaded and CurrUser.CanAccessAdmin;

       if CreatingClient then
        chkGenerateFinancial.Checked := True
       else
        chkGenerateFinancial.checked := MyClient.clExtra.ceBook_Gen_Finance_Reports;

       eConnectCode.Text     := clBankLink_Code;
       chkNewTrx.Checked     := not clSuppress_Check_for_New_TXns;
  //     chkPurge.Checked      := not clRetain_Entries;
       chkArchived.Checked    := MyClient.clMoreFields.mcArchived;
       chkFillNarration.Checked := clCopy_Narration_Dissection;
       chkForceCheckout.Checked := clForce_Offsite_Check_Out;
       chkDisableCheckout.Checked := clDisable_Offsite_Check_Out;
       chkUnlockEntries.Checked := MyClient.clExtra.ceAllow_Client_Unlock_Entries;
       chkEditChart.Checked := MyClient.clExtra.ceAllow_Client_Edit_Chart;
       chkEditMems.Checked := not MyClient.clExtra.ceBlock_Client_Edit_Mems;
       //stored so that can tell what balances to use for Balance Forward Routine
       OldFinancialYear := clFinancial_Year_Starts;

       //administration tab
       cmbResponsible.Clear;
       cmbGroup.Clear;
       cmbType.Clear;

       if AdminLoaded and
         (AdminSystem.fdFields.fdMagic_Number = clMagic_Number) and
         (not CurrUser.HasRestrictedAccess) then  
       begin
          //admin exists and file is part of admin system
          StoredIndex := -1;
          StoredIndexGroup := -1;
          StoredIndexType := -1;
          Indx := 0;
          IndxGroup := 0;
          IndxType := 0;

          //load none line
          cmbResponsible.Items.AddObject( '--- Not Allocated ---', nil);
          cmbGroup.Items.AddObject( '--- Not Allocated ---', nil);
          cmbType.Items.AddObject( '--- Not Allocated ---', nil);

          //load admin staff with full names
          with AdminSystem.fdSystem_User_List do
          begin
            for i := 0 to Pred(itemCount) do begin
               User := User_At(i);

               if ( User^.usName <> '' ) then
                  StaffName := User^.usName
               else
                  StaffName := User^.usCode;

               if ( StaffName <> '' ) then begin
                  cmbResponsible.Items.AddObject(StaffName,TObject(User));
                  Inc(indx);
                  //see if user assigned matches this one
                  if User^.usLRN = clStaff_Member_LRN then
                     StoredIndex := indx;
               end;
            end;
          //load groups
          with AdminSystem.fdSystem_Group_List do
          begin
            for i := 0 to Pred(itemCount) do
            begin
               Group := Group_At(i);
               if ( Group.grName <> '' ) then
               begin
                  cmbGroup.Items.AddObject(Group.grName,TObject(Group));
                  Inc(indxGroup);
                  //see if user assigned matches this one
                  if Group.grLRN = clGroup_LRN then
                     StoredIndexGroup := indxGroup;
               end;
            end;
          end;
          //load client types
          with AdminSystem.fdSystem_Client_Type_List do
          begin
            for i := 0 to Pred(itemCount) do
            begin
               ClientType := Client_Type_At(i);
               if ( ClientType.ctName <> '' ) then
               begin
                  cmbType.Items.AddObject(ClientType.ctName,TObject(ClientType));
                  Inc(indxType);
                  //see if user assigned matches this one
                  if ClientType.ctLRN = clClient_Type_LRN then
                     StoredIndexType := indxType;
               end;
            end;
          end;

          cmbResponsible.Items.AddObject( '--- Unknown User ---', nil);
          cmbGroup.Items.AddObject( '--- Unknown Group ---', nil);
          cmbType.Items.AddObject( '--- Unknown Client Type ---', nil);

          if StoredIndex <> - 1 then begin
             cmbResponsible.ItemIndex := StoredIndex;
          end
          else begin
             if clStaff_Member_LRN = 0 then
               cmbResponsible.ItemIndex := 0
             else
               //no match found, set to unknown
               cmbResponsible.ItemIndex := Pred( cmbResponsible.Items.Count);
          end;
          if StoredIndexGroup <> - 1 then begin
             cmbGroup.ItemIndex := StoredIndexGroup;
          end
          else begin
             if clGroup_LRN = 0 then
               cmbGroup.ItemIndex := 0
             else
               //no match found, set to unknown
               cmbGroup.ItemIndex := Pred( cmbGroup.Items.Count);
          end;
          if StoredIndexType <> - 1 then begin
             cmbType.ItemIndex := StoredIndexType;
          end
          else begin
             if clClient_Type_LRN = 0 then
               cmbType.ItemIndex := 0
             else
               //no match found, set to unknown
               cmbType.ItemIndex := Pred( cmbType.Items.Count);
          end;
        end;
       end
       else begin
          //no admin system or foreign file so disable contact and staff details
          cmbResponsible.Items.Add( clStaff_Member_Name);
          cmbResponsible.ItemIndex := 0;
          cmbResponsible.Enabled := false;
          cmbGroup.Items.Add( clGroup_Name);
          cmbGroup.ItemIndex := 0;
          cmbGroup.Enabled := false;
          cmbType.Items.Add( clClient_Type_Name);
          cmbType.ItemIndex := 0;
          cmbType.Enabled := false;

          pnlContactOptions.Visible := false;
          pnlContactDetails.Top     := pnlContactOptions.Top;

          pnlWebsiteOptions.Visible := false;
          pnlWebsiteDetails.Top     := pnlWebsiteOptions.Top;
       end;

       //set off-site settings
       chkNewTrx.enabled := ( MyClient.clDisk_Log.ItemCount = 0 );

       if AdminLoaded then
       begin
          chkOffsite.enabled := (CurrUser.CanAccessAdmin) and (MyClient.clDisk_Log.ItemCount = 0);
          //turn off narration edit box unless if foreign file
          chkFillNarration.Visible := ( AdminSystem.fdFields.fdMagic_Number <> clMagic_Number);
       end
       else
       begin
          chkOffsite.enabled := false;
          chkFillNarration.Visible := true;
          chkForceCheckout.Enabled := false;
          chkDisableCheckout.Enabled := false;
  //        chkPurge.Enabled := False;
       end;

       chkOffsite.checked    := (clDownload_From <> dlAdminSystem);

       if chkOffsite.checked then
       begin
         SetComboIndexByIntObject( clDownload_From, cmbOSDMethod);
         if cmbOSDMethod.ItemIndex = -1 then
           SetComboIndexByIntObject( dfConnect, cmbOSDMethod);
       end;

       grpDownloadSettings.visible := chkOffsite.Checked;
       eConnectCode.text     := clBankLink_Code;

       //set country specific settings                
       lblCountry.Caption := whShortNames[ clCountry ];

       //load notes field from notes array
       meNotes.Lines.Clear;
       S := '';
       for i := Low( clNotes) to High( clNotes) do
          S := S + clNotes[i];
       meNotes.Text := S;

       chkShowOnOpen.checked := clShow_Notes_On_Open;

       edtContactName.Text  := MyClient.clFields.clCustom_Contact_Name;
       edtContactPhone.Text := MyClient.clFields.clCustom_Contact_Phone;
       edtContactEmail.Text := MyClient.clFields.clCustom_Contact_EMail_Address;

       edtLoginURL.Text     := MyClient.clFields.clWeb_Site_Login_URL;

  {$IFDEF SmartLink}
       edtFingertipsClientID.Text := MyClient.clFields.clExternal_ID;
       edtFingertipsClientID.Enabled := TRUE; //AdminLoaded and (AdminSystem.fdFields.fdMagic_Number = clMagic_Number);
  {$ENDIF}


       AllowClientDirectDownload := chkOffsite.Checked;
       SecureCode := eConnectCode.Text;
     
       //****************************
    finally
      FLoading := False;
    end;

   Self.ShowModal;
   if okPressed then begin
      if not CreatingClient then begin
        if (eCode.text <> clCode) then begin
          {user has rename'd the client file}
          clcode := ecode.text;
          FileRenamed := true;
        end;
      end
      else begin
        {creating client so must set both of these name markers}
        clcode := ecode.text;
        MyClient.clWas_Code := eCode.Text;
      end;

      eMail.Text := Trim( eMail.Text);

      //set flag to determine if contact details changed, this will force
      //an update of the details cache when the file is reloaded/saved
      DetailsChanged := (
          ( clname <> ename.text) or
          ( clAddress_l1 <> eAddr1.text) or
          ( clAddress_l2 <> eAddr2.Text) or
          ( clAddress_l3 <> eAddr3.text) or
          ( clContact_name <> econtact.text) or
          ( clPhone_No <> ePhone.text) or
          ( clMobile_No <> eMobile.text) or
          ( clSalutation <> eSal.text) or
          ( clFax_No <> eFax.text) or
          ( clClient_EMail_Address <> eMail.text) or
{$IFDEF Smartlink}
          ( clExternal_ID <> edtFingertipsClientID.Text) or
{$ENDIF}
          ( PCode <> '') // converting prospect to client
          );

      //update fields
      clname               := ename.text;
      clAddress_l1         := eAddr1.text;
      clAddress_l2         := eAddr2.Text;
      clAddress_l3         := eAddr3.text;
      clContact_name       := econtact.text;
      clPhone_No           := ePhone.text;
      clMobile_No          := eMobile.text;
      clSalutation         := eSal.Text;
      clFax_No             := eFax.text;
      clFile_password      := epassword.text;
      clClient_EMail_Address := eMail.text;
      clWeb_Site_Login_URL := edtLoginURL.Text ;

      if DetailsChanged then
      begin
        clContact_Details_Edit_Date := StDate.CurrentDate;
        clContact_Details_Edit_Time := StDate.CurrentTime;
      end;

      //log change of last download no!!!
      LastDiskSequenceNo := SuffixToSequenceNo( txtLastDiskID.Text);
      if clDisk_Sequence_No <> LastDiskSequenceNo then
      begin
        LogUtil.LogMsg(lmInfo, UnitName, 'Last Download No changed from ' +
                                         inttostr( clDisk_Sequence_No) +
                                         ' to ' +
                                         txtLastDiskID.Text);
      end;
      clBankLink_Code := eConnectCode.Text;
      clDisk_Sequence_No := LastDiskSequenceNo;
      clSuppress_Check_for_New_TXns := not chkNewTrx.Checked;
//        clRetain_Entries := not chkPurge.Checked;
      MyClient.clMoreFields.mcArchived := chkArchived.Checked;
      clCopy_Narration_Dissection := chkFillNarration.Checked;
      clForce_Offsite_Check_Out := chkForceCheckout.Checked;
      clDisable_Offsite_Check_Out := chkDisableCheckout.Checked;
      MyClient.clExtra.ceBook_Gen_Finance_Reports := chkGenerateFinancial.Checked;
      MyClient.clExtra.ceAllow_Client_Unlock_Entries := chkUnlockEntries.Checked;
      MyClient.clExtra.ceAllow_Client_Edit_Chart := chkEditChart.Checked;
      MyClient.clExtra.ceBlock_Client_Edit_Mems := not chkEditMems.Checked;
      //save memo back to clnotes array, split into 100 char chunks
      //first clean out existing notes
      for i := Low( clNotes) to High( clNotes) do
          clNotes[ i] := '';
      clShow_Notes_On_Open      := chkShowOnOpen.checked;

      MemoText := meNotes.Text;
      StartPos := 1;
      for i := Low( clNotes) to High( clNotes) do begin
         S := Copy( MemoText, StartPos, 100);
         if S = '' then break;
         clNotes[ i] := S;
         StartPos := StartPos + 100;
      end;

      //save financial year start, make sure that day = 01
      clFinancial_Year_Starts := StNull2BK( eFinYear.asStDate );
      StDateToDMY( clFinancial_Year_Starts, d, m, y);
      clFinancial_Year_Starts := DMYToStDate( 1, m, y, bkDateEpoch);

      //update reporting year start date
      if clReporting_Year_Starts <= 0 then
        clReporting_Year_Starts := clFinancial_Year_Starts;

      //see if fin year start was updated
      if OldFinancialYear <> clFinancial_Year_Starts then begin
        clLast_Financial_Year_Start := OldFinancialYear;
      end;

      //reset last financial year if not set already, or financial year starts has been set back
      if ( clLast_Financial_Year_Start <= 0) or (clFinancial_Year_Starts < clLast_Financial_Year_Start) then begin
        clLast_Financial_Year_Start := GetPrevYearStartDate( clFinancial_Year_Starts);
      end;

      //update person responsible settings
      if AdminLoaded and ( AdminSystem.fdFields.fdMagic_Number = clMagic_Number )then begin
         //position 0 is none, -1 is also not assigned
         if cmbResponsible.ItemIndex > 0 then begin
            User := pUser_Rec(cmbResponsible.Items.Objects[cmbResponsible.itemindex]);
            if Assigned(User) then begin //will be nil if user is unknown
               if User^.usName <> '' then
                  clStaff_Member_Name := User^.usName
               else
                  clStaff_Member_Name := User^.usCode;

               clStaff_Member_LRN           := User^.usLRN;
               clStaff_Member_EMail_Address := User^.usEMail_Address;
               clStaff_Member_Direct_Dial   := User^.usDirect_Dial;
            end;
         end
         else begin
            clStaff_Member_Name          := '';
            clStaff_Member_LRN           := 0;
            clStaff_Member_EMail_Address := '';
            clStaff_Member_Direct_Dial   := '';
         end;
         clGroup_LRN := 0;
         if cmbGroup.ItemIndex > 0 then begin
            Group := pGroup_Rec(cmbGroup.Items.Objects[cmbGroup.itemindex]);
            if Assigned(Group) then begin //will be nil if group is unknown
               clGroup_Name := Group^.grName;
               clGroup_LRN := Group^.grLRN;
            end;
         end;
         clClient_Type_LRN := 0;
         if cmbType.ItemIndex > 0 then begin
            ClientType := pClient_Type_Rec(cmbType.Items.Objects[cmbType.itemindex]);
            if Assigned(ClientType) then begin //will be nil is user is unknown
              clClient_Type_Name := ClientType^.ctName;
              clClient_Type_LRN := ClientType^.ctLRN;
            end;
         end
      end;

      //update off-site settings
      if chkOffsite.checked then
      begin
         if PRACINI_AllowOffsiteDiskDownload or (clTemp_Old_Download_From = dfFloppy) then
           clDownload_From := GetComboCurrentIntObject( cmbOSDMethod)
         else
           clDownload_From := dfConnect;

         clBankLink_Code    := eConnectCode.Text;
      end
      else
      begin
         clDownload_From    := dlAdminSystem;
         clBankLink_Code    := '';
      end;
        
      if (radPractice.Checked) then
        clContact_Details_To_Show := cdtPractice
      else if (radStaffMember.Checked) then
        clContact_Details_To_Show := cdtStaffMember
      else if (radCustom.Checked) then
      begin
        clContact_Details_To_Show := cdtCustom;
        clCustom_Contact_Name := edtContactName.Text;
        clCustom_Contact_Phone := edtContactPhone.Text;
        clCustom_Contact_EMail_Address := Trim( edtContactEMail.Text);
      end;

      if radPracticeWebSite.Checked then
        clWeb_Site_Login_URL := ''
      else
        clWeb_Site_Login_URL := Trim( edtLoginURL.Text);

{$IFDEF Smartlink}
      if ( clExternal_ID <> edtFingertipsClientID.Text) then
        LogUtil.LogMsg(lmInfo, UnitName, 'Fingertip ID changed from ' +
                                         clExternal_ID +
                                         ' to ' +
                                         edtFingertipsClientID.Text);
      clExternal_ID := edtFingertipsClientID.Text;
{$ENDIF}

      if FileRenamed then begin //force a save immediately
         //Flag Audit
         MyClient.ClientAuditMgr.FlagAudit(arClientFiles);
         SaveClient(false);
      end;
        
      if Assigned(FClientReadDetail) and (SecureCode <> clBankLink_Code) then
      begin
        PrimaryUser := FClientReadDetail.GetPrimaryUser;
        
        if Assigned(PrimaryUser) then
        begin
          ProductConfigService.UpdateClient(
            FClientReadDetail,
            FClientReadDetail.BillingFrequency,
            FClientReadDetail.MaxOfflineDays,
            FClientReadDetail.Status,
            FClientReadDetail.Subscription,
            PrimaryUser.EMail,
            PrimaryUser.FullName);
        end;
      end;
   end;   // if okPressed
 end;  //with MyClient
  result := okPressed;
end;

//------------------------------------------------------------------------------
function EditClientDetails (w_PopupParent: Forms.TForm; ViewNotes : Boolean = False): boolean;
var
  ClientDetails : TfrmClientDetails;
begin
   Result := false;
   if not assigned(myClient) then exit;

   ClientDetails := TfrmClientDetails.Create( Application);
   with ClientDetails do
   begin
     try
        //Required for the proper handling of the window z-order so that a modal window does not show-up behind another window
        PopupParent := w_PopupParent;
        PopupMode := pmExplicit;
        
        BKHelpSetUp(ClientDetails, BKH_Editing_client_details);
        CreatingClient := false;
        FViewNotes := ViewNotes;
        Result := Execute('');
        //Flag Audit
        if Result then
          MyClient.ClientAuditMgr.FlagAudit(arClientFiles);
        RefreshHomepage([HPR_Client]);
     finally
        Free;
     end;
   end;
end;

//------------------------------------------------------------------------------
function NewClientDetails(w_PopupParent: Forms.TForm; PCode: string = ''; EnableClientSettings: boolean = true; InWizard: Boolean = False) : boolean;
var
  ClientDetails : TfrmClientDetails;
begin
   result := false;
   if not assigned(myClient) then exit;

   ClientDetails := TfrmClientDetails.Create( Application);
   with ClientDetails do
   begin
     try
        PopupParent := w_PopupParent;
        PopupMode := pmExplicit;

        FEnableClientSettings := EnableClientSettings;
        btnClientSettings.Enabled := FEnableClientSettings;
        BKHelpSetUp(ClientDetails, BKH_Step_1_Client_Details);
        CreatingClient := true;
        Result := Execute(PCode, InWizard);

     finally
        Free;
     end;
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientDetails.chkOffsiteClick(Sender: TObject);
var
  ClientExportDataService : TBloDataPlatformSubscription;
  VendorCount, i: integer;
  VendorNames: TStringList;
  ClientGuid: TBloGuid;
begin
   if chkOffsite.Checked then
   begin
     if MyClient.clExtra.ceDeliverDataDirectToBLO and (MyClient.clExtra.ceBLOSecureCode <> '') and
     ProductConfigService.IsPracticeProductEnabled(ProductConfigService.GetExportDataId, False) then
     begin
       HelpfulWarningMsg('This client is set up for data delivery directly to ' + bkBranding.ProductOnlineName + '. ' +
                         'Please contact ' + TProduct.BrandName + ' Client Services if you want to change the ' +
                         'data delivery method to downloading data directly from ' + TProduct.BrandName + ' to ' +
                         'the client file.', 0);
       chkOffsite.Checked := False;
       Exit;
     end
     else
     begin
       if not FLoading then
       begin
         ClientGuid := ProductConfigService.GetClientGuid(MyClient.clFields.clCode);

         if Trim(ClientGuid) <> '' then
         begin
           ClientExportDataService := ProductConfigService.GetClientVendorExports(ClientGuid);
           
           if Assigned(ClientExportDataService) then
           begin
             VendorCount := Length(ClientExportDataService.Current);
             if (VendorCount > 0) then
             begin
               try
                 VendorNames := TStringList.Create;
                 VendorNames.QuoteChar := ' ';
                 for i := 0 to VendorCount - 1 do
                   VendorNames.Add(ClientExportDataService.Current[i].Name_);
                 HelpfulWarningMsg('Your changes will allow the client to download data directly from ' +
                                   TProduct.BrandName + ' but this client is set up to export data to ' + bkBranding.ProductOnlineName +
                                   'for ' + GetCommaSepStrFromList(VendorNames) + '.' +
                                   ' This means that data can be exported to ' + GetCommaSepStrFromList(VendorNames) +
                                   ' only when the file is available in ' + bkBranding.PracticeProductName + '.', 0);
               finally
                 FreeAndNil(VendorNames);
               end;
             end;
           end;
         end;
       end;
     end;
   end;

   grpDownloadSettings.visible := chkOffsite.Checked;
   if chkOffsite.Checked then
   begin
     if cmbOSDMethod.ItemIndex = -1 then
       SetComboIndexByIntObject( dfConnect, cmbOSDMethod);
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientDetails.eFinYearError(Sender: TObject; ErrorCode: Word;
  ErrorMsg: String);
begin
  SelectDate.ShowDateError(Sender);
end;

//------------------------------------------------------------------------------
procedure TfrmClientDetails.UpdatePracticeContactDetails( ContactType : byte);
var
  Contact        : string;
  Email          : string;
  Phone          : string;
  User           : pUser_Rec;
begin
  //practice contact details will be used as the default details, there are
  //cached when syncronising the client with the admin system
  //#1725 - if foreign file then use details from the file itself
  if Assigned( AdminSystem) and
    (AdminSystem.fdFields.fdMagic_Number = MyClient.clFields.clMagic_Number) then
  begin
    Contact  := AdminSystem.fdFields.fdPractice_Name_for_Reports;
    Phone    := AdminSystem.fdFields.fdPractice_Phone;
    Email    := AdminSystem.fdFields.fdPractice_EMail_Address;
  end
  else
  begin
    Contact  := MyClient.clFields.clPractice_Name;
    Email    := MyClient.clFields.clPractice_EMail_Address;
    Phone    := MyClient.clFields.clPractice_Phone;
  end;

  if ContactType = BKCONST.cdtStaffMember then
  begin
    //update staff member details
    if Assigned( AdminSystem) and ( AdminSystem.fdFields.fdMagic_Number = MyClient.clFields.clMagic_Number )then
    begin
      //position 0 is none, -1 is also not assigned
      if cmbResponsible.ItemIndex > 0 then
      begin
         //replace with current users contact details if set
         User := pUser_Rec(cmbResponsible.Items.Objects[cmbResponsible.itemindex]);
         if Assigned(User) then begin //will be nil is user is unknown
            if User^.usName <> '' then
               Contact := User^.usName
            else
               Contact := User^.usCode;

            if User^.usEMail_Address <> '' then
              Email := User^.usEMail_Address;

            if User^.usDirect_Dial <> '' then
              Phone := User^.usDirect_Dial;
         end;
      end;
    end
    else begin
      //admin system is not loaded, show contact details embeded in file
      if MyClient.clFields.clStaff_Member_Name <> '' then
        Contact := MyClient.clFields.clStaff_Member_Name;

      if MyClient.clFields.clStaff_Member_EMail_Address <> '' then
        Email := MyClient.clFields.clStaff_Member_EMail_Address;

      if MyClient.clFields.clStaff_Member_Direct_Dial <> '' then
        Phone := MyClient.clFields.clStaff_Member_Direct_Dial;
    end;
  end;

  if ContactType = BKCONST.cdtCustom then
  begin
    //if the admin system is assigned then the custom details will be editable
    Contact  := MyClient.clFields.clCustom_Contact_Name;
    Phone    := MyClient.clFields.clCustom_Contact_Phone;
    Email    := MyClient.clFields.clCustom_Contact_EMail_Address;
  end;

  //update labels
  if Contact = '' then
    Contact := lnone;
  lblContactNameView.Caption  := Contact;

  if Phone = '' then
    Phone := lnone;
  lblPhoneView.Caption := Phone;

  if Email = '' then
    Email := lnone;
  lblEmailView.Caption := Email;
end;

procedure TfrmClientDetails.UpdateProductsLabel;
var
  NumProducts: string;
  NotesId : TBloGuid;
  NotesIndex : integer;
  WebExportSetToNotes : Boolean;
  Subscription : TBloArrayOfguid;
  UserName : String;
  UserEmail : String;
  SubIndex : integer;
  SubscriptionSetToNotes : Boolean;
  PrimaryUser: TBloUserRead;
begin
  if Assigned(MyClient) then
  begin
    NotesId := ProductConfigService.GetNotesId;
    NumProducts := '0';
    WebExportSetToNotes := (MyClient.clFields.clWeb_Export_Format = wfWebNotes);

    if Assigned(FClientReadDetail) then
    begin
      SubscriptionSetToNotes := ProductConfigService.IsItemInArrayGuid(FClientReadDetail.Subscription, NotesId);

      // Sync up Web Export Fromat with Online Subscription
      if SubscriptionSetToNotes <> WebExportSetToNotes then
      begin
        Subscription := FClientReadDetail.Subscription;

        if WebExportSetToNotes then
          ProductConfigService.AddItemToArrayGuid(Subscription, NotesId)
        else
          ProductConfigService.RemoveItemFromArrayGuid(Subscription, NotesId);

          PrimaryUser := FClientReadDetail.GetPrimaryUser;

        if Assigned(PrimaryUser) then
        begin
          UserEmail := PrimaryUser.EMail;
          UserName  := PrimaryUser.FullName;
        end
        else
        begin
          UserEMail := MyClient.clFields.clClient_EMail_Address;
          UserName  := MyClient.clFields.clContact_Name;
        end;

        if ProductConfigService.UpdateClient(FClientReadDetail,
                                          FClientReadDetail.BillingFrequency,
                                          FClientReadDetail.MaxOfflineDays,
                                          FClientReadDetail.Status,
                                          Subscription,
                                          UserEmail,
                                          UserName) then
        begin
          FClientReadDetail.Subscription := Subscription;
        end;
      end;
    end
    else if MyClient.clExtra.ceOnlineValuesStored then
    begin
      SubscriptionSetToNotes := false;
      for SubIndex := 1 to MyClient.clExtra.ceOnlineSubscriptionCount do
      begin
        if MyClient.clExtra.ceOnlineSubscription[SubIndex] = NotesId then
        begin
          SubscriptionSetToNotes := True;
          NotesIndex := SubIndex;
          break;
        end;
      end;

      // Sync up Web Export Fromat with Offline Subscription
      if SubscriptionSetToNotes <> WebExportSetToNotes then
      begin
        if not SubscriptionSetToNotes then
        begin
          inc(MyClient.clExtra.ceOnlineSubscriptionCount);
          SubIndex := MyClient.clExtra.ceOnlineSubscriptionCount;

          MyClient.clExtra.ceOnlineSubscription[SubIndex] := NotesId;
          // Add Notes to offline Subscription
        end
        else
        begin
          // Remove Notes from offline Subscription
          if (NotesIndex + 1) <= MyClient.clExtra.ceOnlineSubscriptionCount then
          begin
            for SubIndex := (NotesIndex + 1) to MyClient.clExtra.ceOnlineSubscriptionCount do
            begin
              MyClient.clExtra.ceOnlineSubscription[SubIndex-1] :=
                MyClient.clExtra.ceOnlineSubscription[SubIndex];
            end;
          end;
          Dec(MyClient.clExtra.ceOnlineSubscriptionCount);
        end;
      end;
    end;

    if Assigned(FClientReadDetail) then
      NumProducts := IntToStr(CountClientProducts(FClientReadDetail))
    else if MyClient.clExtra.ceOnlineValuesStored then
      NumProducts := IntToStr(MyClient.clExtra.ceOnlineSubscriptionCount)
    else if MyClient.clFields.clWeb_Export_Format = wfWebNotes then
      NumProducts := '1';

    SetProductsCaption('This client currently has access to ' + NumProducts +
                       bkBranding.ProductOnlineName + ' product(s)');
  end;
end;

procedure TfrmClientDetails.WMActivate(var w_Message: TWMActivate);
begin
  inherited;
end;

procedure TfrmClientDetails.WMKillFocus(var w_Message: TWMKillFocus);
begin
  inherited;

end;

//------------------------------------------------------------------------------
procedure TfrmClientDetails.cmbResponsibleChange(Sender: TObject);
begin
  if (radStaffMember.Checked)then
    UpdatePracticeContactDetails( cdtStaffMember);
end;

function TfrmClientDetails.CountClientProducts(ClientDetails: TBloClientReadDetail): Integer;
var
  Index: Integer;
  CatEntry: TBloCatalogueEntry;
begin
  Result := 0;

  for Index := 0 to Length(ClientDetails.Subscription) - 1 do
  begin
    CatEntry := GetClientSubscriptionCategory(ClientDetails.Subscription[Index]);

    if Assigned(CatEntry) then
    begin
      if (CatEntry.CatalogueType <> 'Service') then
      begin
        Inc(Result);
      end;
    end;    
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientDetails.ShowPracticeContactDetails(ReadOnly : Boolean);
begin
  if (ReadOnly) then
  begin
    lblContactNameView.Visible := True;
    lblPhoneView.Visible       := True;
    lblEmailView.Visible       := True;

    edtContactName.Visible     := False;
    edtContactPhone.Visible    := False;
    edtContactEmail.Visible    := False;
  end else
  begin
    lblContactNameView.Visible := False;
    lblPhoneView.Visible       := False;
    lblEmailView.Visible       := False;

    edtContactName.Visible     := True;
    edtContactPhone.Visible    := True;
    edtContactEmail.Visible    := True;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientDetails.radPracticeClick(Sender: TObject);
var
  ReadOnly : boolean;
  aType    : byte;
begin
  ReadOnly := true;

  if Assigned( AdminSystem) then
    ReadOnly := not radCustom.checked
  else
  if ThirdPartyDLLDetected and AllowEditingOfCustomContactDetails then
    ReadOnly := false;

  if radStaffMember.checked then
    aType := cdtStaffMember
  else
  if radCustom.checked then
    aType := cdtCustom
  else
    aType := cdtPractice;

  UpdatePracticeContactDetails( aType);
  ShowPracticeContactDetails( ReadOnly);
end;

//------------------------------------------------------------------------------
procedure TfrmClientDetails.radPracticeWebSiteClick(Sender: TObject);
var
  ReadOnly : boolean;
  Website  : string;
begin
  if Assigned( AdminSystem) then
  begin
    ReadOnly := radPracticeWebSite.Checked;
    if ReadOnly then
      WebSite := MyClient.clFields.clPractice_Web_Site
    else
      WebSite := '';
  end
  else
  begin
    ReadOnly := true;

    if MyClient.clFields.clWeb_Site_Login_URL <> '' then
      WebSite := MyClient.clFields.clWeb_Site_Login_URL
    else
      WebSite := MyClient.clFields.clPractice_Web_Site;
  end;

  if WebSite = '' then
    WebSite := lnone;

  if ReadOnly then
  begin
    lblWebSite.Caption := WebSite;
    lblWebSite.Visible := true;
    edtLoginURL.Visible := false;
  end
  else
  begin
    lblWebSite.Visible := false;
    edtLoginURL.Visible := true;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientDetails.txtLastDiskIDChange(Sender: TObject);
begin
   if PassGenCodeEntered or PRACINI_DontAskForPGDiskNo then
     exit;

   if ChangingDiskID then
   begin
     exit;
   end;

   //trying to change code, ask for password
   PassGenCodeEntered := EnterPassword('Change Last Disk Processed', 'LASTDOWNLOAD', 0, true, false);
   if not PassGenCodeEntered then
   begin
     ChangingDiskID := true;
     try
       txtLastDiskID.Text := DownloadUtils.MakeSuffix( MyClient.clFields.clDisk_Sequence_No)
     finally
       ChangingDiskID := false;
     end;
   end
   else
   begin
      //log the fact that the user can change the download no
      LogUtil.LogMsg(lmInfo, UnitName, 'Password Used to Access Last Download No');;
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientDetails.chkForceCheckoutClick(Sender: TObject);
begin
  if chkForceCheckout.Checked then
    chkDisableCheckout.Checked := False;
end;

//------------------------------------------------------------------------------
procedure TfrmClientDetails.chkDisableCheckoutClick(Sender: TObject);
begin
  if chkDisableCheckout.Checked then
    chkForceCheckout.Checked := False;
end;

end.
                                   
