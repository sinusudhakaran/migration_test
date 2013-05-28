// Import prospective clients

unit ImportProspectsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, DB, OpDbOlk, OpShared, OpOlkXP, OpOutlk,
  CheckLst, ExtCtrls,
  OSFont;

type
  EImportType = (itProspects,itClients);


  TImport_Client = class
  private
    Fic_Email: String;
    Fic_Mobile: String;
    Fic_Fax: String;
    Fic_Code: String;
    Fic_Phone: String;
    Fic_Address2: String;
    Fic_Address3: String;
    Fic_Salutation: String;
    Fic_Address1: String;
    Fic_User: String;
    Fic_Contact: String;
    Fic_Name: String;
    procedure Setic_Address1(const Value: String);
    procedure Setic_Address2(const Value: String);
    procedure Setic_Address3(const Value: String);
    procedure Setic_Code(const Value: String);
    procedure Setic_Contact(const Value: String);
    procedure Setic_Email(const Value: String);
    procedure Setic_Fax(const Value: String);
    procedure Setic_Mobile(const Value: String);
    procedure Setic_Name(const Value: String);
    procedure Setic_Phone(const Value: String);
    procedure Setic_Salutation(const Value: String);
    procedure Setic_User(const Value: String);
  public
    property ic_Code : String read Fic_Code write Setic_Code;
    property ic_Name : String read Fic_Name write Setic_Name;
    property ic_Address1  : String read Fic_Address1 write Setic_Address1;
    property ic_Address2  : String read Fic_Address2 write Setic_Address2;
    property ic_Address3  : String read Fic_Address3 write Setic_Address3;
    property ic_Phone  : String read Fic_Phone write Setic_Phone;
    property ic_Fax  : String read Fic_Fax write Setic_Fax;
    property ic_Mobile  : String read Fic_Mobile write Setic_Mobile;
    property ic_Salutation  : String read Fic_Salutation write Setic_Salutation;
    property ic_Email  : String read Fic_Email write Setic_Email;
    property ic_Contact  : String read Fic_Contact write Setic_Contact;
    property ic_User  : String read Fic_User write Setic_User;
  end;

  TfrmImportProspects = class(TForm)
    OpenDialog1: TOpenDialog;
    pnlButtons: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    pnlOptions: TPanel;
    lblImport: TLabel;
    lblFilename: TLabel;
    btnFromFile: TSpeedButton;
    cmbImport: TComboBox;
    edtCSV: TEdit;
    chkHeaders: TCheckBox;
    pnlOutlook: TPanel;
    clbContacts: TCheckListBox;
    pnlTitle2: TPanel;
    Panel1: TPanel;
    btnCheck: TButton;
    btnClear: TButton;
    chkSelect: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnFromFileClick(Sender: TObject);
    procedure cmbImportChange(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCheckClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure chkSelectClick(Sender: TObject);
    procedure clbContactsClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormPosChanging(var Msg: TWmWindowPosChanging); message WM_WINDOWPOSCHANGING;
  private
    FImportType: EImportType;
    opoContacts: TOpOutlook;
    ocdsContacts: TOpContactsDataSet;
    RestoreHeight, MaxHeight, StickyLeft, StickyTop: Integer;
    HeightChanged, Populated: Boolean;
    function ImportFromCSV(Verify: Boolean): TModalResult;
    procedure PopulateFromOutlook;
    function ImportFromOutlook: TModalResult;
    function LookupColumn(ColumnName: string): Integer;
    function ConvertX400ToSMTP(x400: string): string;
    procedure SetDelimitedText(const Value: string; var strl: TStringList);

    function ValidFileName: Boolean;
    function LoadImportList(ImportList: TStringList): Boolean;
    function RewriteColOrder(CurrentClient: TStringList; ColOrder: Array of Integer): Boolean;
    procedure LoadClientValues(CurrentClient: TStringList; ColOrder: Array of Integer;
      Import_Client: TImport_Client);
    function GetUserID(ImportClient: TImport_Client): Integer;
    procedure RestrictToCSV;
    function CheckFileOkToImport(ClientCode: string; var ErrorMessage: string): boolean;
    public
    { Public declarations }
    function ShowModal(ImportType: EImportType = itProspects):TModalResult;reintroduce;overload;
  end;

var
  frmImportProspects: TfrmImportProspects;
  DebugMe : boolean;

const
  UnitName = 'ImportProspectsDlg';
  IMPORT_CSV = 0;
  IMPORT_OUTLOOK = 1;


implementation

uses bkXPThemes, GlobalDirectories, ErrorMoreFrm, BKConst, ImagesFrm,
  ClientDetailCacheObj, ClientUtils, SyDefs, Globals, InfoMoreFrm, LogUtil,
  MAPIDefs, MAPIUtil, COMObj, ECodingImportResultsFrm, progress, WinUtils,
  bkHelp, Admin32, bkBranding;

{$R *.dfm}

procedure TfrmImportProspects.FormCreate(Sender: TObject);
begin
  MAPIInitialize(nil);
  bkXPThemes.ThemeForm( Self);
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnFromFile.Glyph);
  RestoreHeight := pnlOutlook.Height;
  MaxHeight := Self.Height;
  Populated := False;
  HeightChanged := True;
  cmbImportChange(Self);
  clbContacts.MultiSelect := True;
  StickyLeft := Left;
  StickyTop := Top;
  opoContacts := nil;
  ocdsContacts := nil;
end;

// Choose a CSV file to import
procedure TfrmImportProspects.btnFromFileClick(Sender: TObject);
begin
  with OpenDialog1 do
  begin
    InitialDir := ExtractFilePath(edtCSV.Text);
    Filename := ExtractFilename(edtCSV.Text);
    if Execute then
      edtCSV.Text := Filename;
  end;

  //make sure all relative paths are relative to data dir after browse
  SysUtils.SetCurrentDir(GlobalDirectories.glDataDir);
end;

// Change UI based on import method selected
procedure TfrmImportProspects.cmbImportChange(Sender: TObject);
begin
  case cmbImport.ItemIndex of
    IMPORT_CSV:
      begin
        if HeightChanged then
        begin
          Height := Height - RestoreHeight;
          Top := Top + (RestoreHeight div 2);
          HeightChanged := False;
        end;
        lblFilename.Visible := True;
        edtCSV.Visible := True;
        btnFromFile.Visible := True;
//        chkHeaders.Visible := True;
        pnlOutlook.Visible := False;
      end;
    IMPORT_OUTLOOK:
      begin
        lblFilename.Visible := False;
        edtCSV.Visible := False;
        btnFromFile.Visible := False;
      end;
  end;
end;

procedure TfrmImportProspects.btnOkClick(Sender: TObject);
begin
  StickyLeft := Left;
  StickyTop := Top;
  case cmbImport.ItemIndex of // Call relevant import method
    IMPORT_CSV:
      begin
        if ImportFromCSV(True) = mrOk then
        begin
          Self.Enabled := False;
          ModalResult := mrNone;
          try
            ModalResult := ImportFromCSV(False);
          finally
            if ModalResult = mrNone then
              Self.Enabled := True;
          end;
        end;
      end;
    IMPORT_OUTLOOK:
      begin
        try
          if not Assigned(opoContacts) then
          begin
            opoContacts := TOpOutlook.Create(Self);
            opoContacts.NewSession := False;
            opoContacts.ShowLoginDialog := False;
          end;
          if not Assigned(ocdsContacts) then
          begin
            ocdsContacts := TOpContactsDataSet.Create(Self);
            ocdsContacts.Outlook := opoContacts;
            ocdsContacts.ContactInfo := [citDefault,citBusiness,citPersonal,citNetwork,citMisc];
          end;
        except
          exit;
        end;
        if not Populated then
        begin
          Self.Enabled := False;
          try
            PopulateFromOutlook
          finally
            Self.Enabled := True;
            // Centre vertically so that OK/Cancel don't drop off the screen
            Self.Top := (Screen.Height - Self.Height) div 2;
            Self.SetFocus;
          end
        end
        else
        begin
          Self.Enabled := False;
          ModalResult := mrNone;
          try
            ModalResult := ImportFromOutlook;
          finally
            if ModalResult = mrNone then
            begin
              Self.Enabled := True;
              Self.SetFocus;
            end;
          end;
        end;
      end;
  end;
end;

// Given a CSV column name, return the index in the array or -1 if it doesnt exist
function TfrmImportProspects.LookupColumn(ColumnName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := pfMin to pfMax do
    if Lowercase(pfNames[i]) = Lowercase(ColumnName) then
    begin
      Result := i;
      Break;
    end;
end;

// Import prospects from Outlook Contacts list
function TfrmImportProspects.ImportFromOutlook: TModalResult;
const
  ThisMethodName = 'ImportFromOutlook';
var
  code, clientname, address1, address2, address3, phone, fax, mobile, email, sal,
  contact, user, entry, str: string;
  address: TStrings;
  total: Integer;
begin
  Result := mrNone;
  total := 0;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');
  if clbContacts.Items.Count > 0 then
  begin
   try
    try
      opoContacts.Connected := True;
      ocdsContacts.Active := True;
      ocdsContacts.First;
      UpdateAppStatus('Importing Prospects', 'Please wait...', 100, True);
      while not ocdsContacts.Eof do
      begin
        code := '';
        clientname := Trim(ocdsContacts.FieldByName('CompanyName').AsString);
        address1 := '';
        address2 := '';
        address3 := '';
        phone := '';
        fax := '';
        mobile := '';
        sal := '';
        email := '';
        contact := Trim(ocdsContacts.FieldByName('FirstName').AsString + ' ' +
            ocdsContacts.FieldByName('MiddleName').AsString + ' ' +
            ocdsContacts.FieldByName('LastName').AsString);
        user := '';
        if clientname = '' then
          clientname := contact;
        if clientname <> '' then
        begin
          entry := clientname;
          if contact <> '' then
            entry := entry + ' (' + contact + ')';
          // Import selected contacts
          if clbContacts.Checked[clbContacts.Items.IndexOf(entry)] then
          begin
            address := TStringList.Create;
            try
              str := Trim(ocdsContacts.FieldByName('MailingAddressStreet').AsString);
              str := StringReplace(str, #$D#$A, ' ' , [rfReplaceAll]);
              if str <> '' then
                address.Add(str);
              str := Trim(ocdsContacts.FieldByName('MailingAddressCity').AsString);
              if str <> '' then
                address.Add(str);
              str := Trim(ocdsContacts.FieldByName('MailingAddressState').AsString);
              if str <> '' then
                address.Add(str);
              str := Trim(ocdsContacts.FieldByName('MailingAddressPostalCode').AsString);
              if str <> '' then
                address.Add(str);
              str := Trim(ocdsContacts.FieldByName('MailingAddressCountry').AsString);
              if str <> '' then
                address.Add(str);
              if address.Count = 0 then
              begin
                address1 := '';
                address2 := '';
                address3 := '';
              end
              else if address.Count = 1 then
              begin
                address1 := address[0];
                address2 := '';
                address3 := '';
              end
              else if address.Count = 2 then
              begin
                address1 := address[0];
                address2 := address[1];
                address3 := '';
              end
              else if address.Count = 3 then
              begin
                address1 := address[0];
                address2 := address[1];
                address3 := address[2];
              end
              else if address.Count = 4 then
              begin
                address1 := address[0];
                address2 := address[1];
                address3 := address[2] + ', ' + address[3];
              end
              else if address.Count = 5 then
              begin
                address1 := address[0];
                address2 := address[1] + ', ' + address[2];
                address3 := address[3] + ', ' + address[4];
              end;
            finally
              address.Free;
            end;
            phone := Trim(ocdsContacts.FieldByName('BusinessTelephoneNumber').AsString);
            if phone = '' then
              phone := Trim(ocdsContacts.FieldByName('HomeTelephoneNumber').AsString);
            fax := Trim(ocdsContacts.FieldByName('BusinessFaxNumber').AsString);
            if fax = '' then
              fax := Trim(ocdsContacts.FieldByName('HomeFaxNumber').AsString);
            mobile := Trim(ocdsContacts.FieldByName('MobileTelephoneNumber').AsString);
            if mobile = '' then
              mobile := Trim(ocdsContacts.FieldByName('CarTelephoneNumber').AsString);
            sal := Trim(ocdsContacts.FieldByName('Title').AsString);
            email := ConvertX400ToSMTP(Trim(ocdsContacts.FieldByName('Email1Address').AsString));
            if email = '' then
              email := ConvertX400ToSMTP(Trim(ocdsContacts.FieldByName('Email2Address').AsString));
            if email = '' then
              email := ConvertX400ToSMTP(Trim(ocdsContacts.FieldByName('Email3Address').AsString));
            // Generate a code
            if code = '' then
              code := GenerateProspectCode(code, clientname, '');
            AddNewProspectRec(code, clientname, address1, address2, address3,
              phone, fax, mobile, sal, email, contact, 0);
            Inc(total);
            UpdateAppStatusPerc( total / Pred(ocdsContacts.RecordCount) * 100, True);
          end;
        end;
        ocdsContacts.Next;
      end;
     except
       HelpfulInfoMsg('Outlook cannot be accessed.' + #13#13 +
         'If Outlook asked the security question "Do you want to allow access"' +
         ' then please select Yes. It is suggested that you allow 10 minutes access to allow ' + bkBranding.ProductName +
         ' to complete the import process.', 0);
       exit;
     end;
    finally
      ocdsContacts.Active := False;
      opoContacts.Connected := False;
      ClearStatus(True);
    end;
  end;
  if total = 0 then
    HelpfulInfoMsg('There are no Prospects to import.', 0)
  else
  begin
    if total = 1 then
      HelpfulInfoMsg(IntToStr(total) + ' Prospect was imported successfully.', 0)
    else
      HelpfulInfoMsg(IntToStr(total) + ' Prospects were imported successfully.', 0);
    Result := mrOk;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

// Read Outlook contacts and populate the listbox
procedure TfrmImportProspects.PopulateFromOutlook;
const
  ThisMethodName = 'PopulateFromOutlook';
var
  clientname, contact, entry: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');
  clbContacts.Clear;
  clbContacts.Sorted := False;
  try
   try
    opoContacts.Connected := True;
    ocdsContacts.Active := True;
    Application.BringToFront;
    if Self.Visible and Self.Enabled then
      Self.SetFocus;
    ocdsContacts.First;
    UpdateAppStatus('Reading Contacts', 'Please wait...', 0, True);
    while not ocdsContacts.Eof do
    begin
      clientname := Trim(ocdsContacts.FieldByName('CompanyName').AsString);
      contact := Trim(ocdsContacts.FieldByName('FirstName').AsString + ' ' +
          ocdsContacts.FieldByName('MiddleName').AsString + ' ' +
          ocdsContacts.FieldByName('LastName').AsString);
      if clientname = '' then
        clientname := contact;
      // Must have client name otherwise we wont import it
      if clientname <> '' then
      begin
        entry := clientname;
        if contact <> '' then
            entry := entry + ' (' + contact + ')';
        if (clbContacts.Items.IndexOf(entry) = -1) then
          clbContacts.Items.Add(entry);
        clbContacts.Checked[clbContacts.Count - 1] := True;
      end;
      ocdsContacts.Next;
      UpdateAppStatusPerc( clbContacts.Items.Count / Pred(ocdsContacts.RecordCount) * 100, True);
    end;
    clbContacts.Sorted := True;
    if clbContacts.Items.Count = 0 then
      HelpfulInfoMsg('Could not read any Contacts from Outlook.', 0);
   except
     clbContacts.Clear;
     HelpfulInfoMsg('Outlook cannot be accessed.' + #13#13 +
       'If Outlook asked the security question "Do you want to allow access"' +
       ' then please select Yes. It is suggested that you allow 10 minutes access to allow ' + bkBranding.ProductName +
       ' to complete the import process.', 0);
     exit;
   end;
  finally
    ClearStatus;
    ocdsContacts.Active := False;
    opoContacts.Connected := False;
    if clbContacts.Items.Count > 0 then
    begin
      Populated := True;
      clbContactsClick(Self);
      if Height < MaxHeight then // not at correct size
      begin
        Height := Height + RestoreHeight;
        HeightChanged := True;
        Top := Top - (RestoreHeight div 2);
        chkHeaders.Visible := False;
        pnlOutlook.Visible := True;
        pnlOptions.Visible := False;
        clbContacts.Selected[0] := True;
        clbContactsClick(Self);
      end
    end
    else
      cmbImport.ItemIndex := 1;
    Application.BringToFront;
    if Self.Visible and Self.Enabled then
      Self.SetFocus;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

// The default stringlist commatext uses spaces as delimiters as well as commas
// so use our own version of it...
procedure TfrmImportProspects.SetDelimitedText(const Value: string; var strl: TStringList);
var
  P, P1: PChar;
  S: string;
begin
  strl.BeginUpdate;
  try
    strl.Clear;
    P := PChar(Value);
    while P^ in [#1..' '] do
      P := CharNext(P);
    while P^ <> #0 do
    begin
      if P^ = '"' then
        S := AnsiExtractQuotedStr(P, '"')
      else
      begin
        P1 := P;
        while (P^ >= ' ') and (P^ <> ',') do
          P := CharNext(P);
        SetString(S, P1, P - P1);
      end;
      strl.Add(S);
      while P^ in [#1..' '] do
        P := CharNext(P);
      if P^ = ',' then
      begin
        P1 := P;
        if CharNext(P1)^ = #0 then
          strl.Add('');
        repeat
          P := CharNext(P);
        until not (P^ in [#1..' ']);
      end;
    end;
  finally
    strl.EndUpdate;
  end;
end;

function TfrmImportProspects.ShowModal(ImportType: EImportType = itProspects):TModalResult;
begin
  FImportType := ImportType;
  case (FImportType) of
    itProspects:
      begin
         Caption := 'Import Prospects';
         BKHelpSetUp(Self, BKH_Adding_and_importing_Prospects);
      end;
    itClients:
      begin
         Caption := 'Import Contact Details';
         RestrictToCSV;
         BKHelpSetUp(Self, BKH_Importing_contact_details);
      end;
  end;
  result := inherited ShowModal;
end;

procedure TfrmImportProspects.RestrictToCSV;
begin
  //Updating client details only works from CSV
  cmbImport.ItemIndex := IMPORT_CSV;
  cmbImport.Items.Delete(IMPORT_OUTLOOK);
  //Only one option, so no need for a Combo box.
  cmbImport.Visible := false;
  lblImport.Caption := 'Import from CSV File';
end;

function TfrmImportProspects.ValidFileName: Boolean;
begin
  result := True;
  if Trim(edtCSV.Text) = '' then
  begin
    if FImportType = itProspects then
      HelpfulErrorMsg('Please specify the filename to import the prospects from.', 0)
    else //itClients
      HelpfulErrorMsg('Please specify the filename to import contact details from.', 0);


    result := False;
  end
  else if not BKFileExists(edtCSV.Text) then
  begin
    HelpfulErrorMsg('The specified file does not exist.' + #13#13 +
      'Filename:' + edtCSV.Text, 0);
    result := False;
  end;
end;

function TfrmImportProspects.LoadImportList(ImportList: TStringList): Boolean;
begin
  Result := True;
  try
    ImportList.LoadFromFile(edtCSV.Text);
  except
    on E: SysUtils.Exception do
    begin
      HelpfulErrorMsg('Cannot import file ' + edtCSV.Text  + '. ' + E.Message, 0);
      Result := False;
    end;
  end;
  if ImportList.Count = 0 then
  begin
    HelpfulErrorMsg('The file is empty!' + #13#13 + 'Filename: ' + edtCSV.Text, 0);
    Result := False;
  end;
end;

//Re-write column order based on first row in CSV File
function TfrmImportProspects.RewriteColOrder(CurrentClient: TStringList; ColOrder: Array of Integer): Boolean;
var ClientNameColumnExists: Boolean;
    i: Integer;
begin
  Result := True;
  ClientNameColumnExists := False;
  for i := 0 to Pred(CurrentClient.Count) do
  begin
    colOrder[i] := LookupColumn(CurrentClient[i]);
    if colOrder[i] = -1 then
    begin
      HelpfulErrorMsg('The column "' + CurrentClient[i] + '" is not a valid column name.' + #13#13 +
        'Please see ' + bkBranding.ProductName + ' Help for information on the required import CSV fields.', 0);
      Result := False
    end
    else if ColOrder[i] = pfClientName then
      ClientNameColumnExists := True;
  end;
  // ClientName is a mandatory field
  if not ClientNameColumnExists then
  begin
    HelpfulErrorMsg('The column "ClientName" is a mandatory column, please add it to your import data.' + #13#13 +
      'Please see ' + bkBranding.ProductName + ' Help for information on the required import CSV fields.', 0);
    Result := False;
  end;
end;

procedure TfrmImportProspects.LoadClientValues(CurrentClient: TStringList; ColOrder: Array of Integer;
  Import_Client: TImport_Client);
var i: Integer;
begin
  Import_Client.ic_Code := '';
  Import_Client.ic_Name := '';
  Import_Client.ic_Address1 := '';
  Import_Client.ic_Address2 := '';
  Import_Client.ic_Address3 := '';
  Import_Client.ic_Phone := '';
  Import_Client.ic_Fax := '';
  Import_Client.ic_Mobile := '';
  Import_Client.ic_Salutation := '';
  Import_Client.ic_Email := '';
  Import_Client.ic_Contact := '';
  Import_Client.ic_User := '';


  for i := 0 to CurrentClient.Count-1 do // Import the Client Values
  begin
    case ColOrder[i] of
      pfCode:         Import_Client.ic_Code := Trim(CurrentClient[i]);
      pfClientName:   Import_Client.ic_Name := Trim(CurrentClient[i]);
      pfAddr1:        Import_Client.ic_Address1 := Trim(CurrentClient[i]);
      pfAddr2:        Import_Client.ic_Address2 := Trim(CurrentClient[i]);
      pfAddr3:        Import_Client.ic_Address3 := Trim(CurrentClient[i]);
      pfPhone:        Import_Client.ic_Phone := Trim(CurrentClient[i]);
      pfFax:          Import_Client.ic_Fax := Trim(CurrentClient[i]);
      pfMobile:       Import_Client.ic_Mobile := Trim(CurrentClient[i]);
      pfEmail:        Import_Client.ic_Email := Trim(CurrentClient[i]);
      pfContactName:  Import_Client.ic_Contact := Trim(CurrentClient[i]);
      pfUser:         Import_Client.ic_User := Trim(CurrentClient[i]);
      pfSalutation:   Import_Client.ic_Salutation := Trim(CurrentClient[i]);
    end;
  end;
end;

//User Value in Grid Column can either be name or code, if its unknown then set to not allocated
function TfrmImportProspects.GetUserID(ImportClient: TImport_Client): Integer;
var i: Integer;
    UserID: Integer;
    vUser: pUser_Rec;
begin
  UserID := 0;
  if (ImportClient.ic_User <> '') then
    for i := 0 to AdminSystem.fdSystem_User_list.ItemCount-1 do
    begin
      vUser := AdminSystem.fdSystem_User_List.User_At(i);
      if (UpperCase(ImportClient.ic_User) = vUser.usCode) or
        (Uppercase(ImportClient.ic_User) = Uppercase(vUser.usName)) then
      begin
        UserID := vUser.usLRN;
        break;
      end;
    end;
  result := UserID;
end;

// Import prospects from a CSV file
// If Verify parameter is true it returns a list of errors, if any
function TfrmImportProspects.ImportFromCSV(Verify: Boolean): TModalResult;
const
  ThisMethodName = 'ImportFromCSV';
var
  ImportList, CurrentClient, ImportFailures : TStringList;
  i, NumCols, UserID, TotalCnt: Integer;
  colOrder: array[pfMin..pfMax] of Integer;
  Errors, InfoMsg: string;
  ImportClient : TImport_Client;
  ErrorReason: string;

  function GetImportNounStr: String;
  begin
    case FImportType of
      itProspects: result := ' Prospect(s)';
      itClients: result := ' Client(s)';
    else result := ' Item(s)';
    end;
  end;

  function GetImportVerbStr: String;
  begin
    case FImportType of
      itProspects: Result := 'imported';
      itClients: Result := 'updated';
    else
      Result := 'imported';
    end;
  end;



begin
  Result := mrNone;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  if NOT(ValidFileName) then exit;
  
  TotalCnt  := 0;
  NumCols   := pfMax + 1;
  // Set default column order
  for i := pfMin to pfMax do
    colOrder[i] := i;

  ImportClient := TImport_Client.Create;
  ImportList := TStringlist.Create; // Holds entire CSV List of Clients or Prospects
  CurrentClient := TStringlist.Create; // Holds Current Client/Prospect Row
  ImportFailures := TStringlist.Create; // Holds records that couldnt be imported

  try
    if NOT(LoadImportList(ImportList)) then exit;
    if FImportType=itProspects then
      UpdateAppStatus('Importing Prospects', 'Please wait...', 100, True)
    else
      UpdateAppStatus('Updating Client Details', 'Please wait...', 100, True);

    for i := 0 to Pred(ImportList.Count) do // Process each row
    begin
      UpdateAppStatusPerc( i / ImportList.Count * 100, True);

      // Note must include quotes otherwise it includes space as a delimiter
      if Trim(ImportList[i]) = '' then
        Continue;
      SetDelimitedText(Trim(ImportList[i]), CurrentClient);

      if  (i = 0) and chkHeaders.Checked then  //Technically this will never happen chkHeaders is never visible
      begin
        if NOT(RewriteColOrder(CurrentClient,colOrder)) then Exit;
        NumCols := CurrentClient.Count;
        Continue;
      end
      else if CurrentClient.Count <> NumCols then // Mismatched row
      begin
        ImportFailures.Add('The CSV file does not contain the correct number of columns (' +
          IntToStr(numcols) + ') at row ' + IntToStr(i + 1));
        Continue;
      end;
      //Load Current Client Values into Object
      LoadClientValues(CurrentClient,Colorder,ImportClient);

      if Trim(ImportClient.ic_Name) = '' then
        ImportFailures.Add('Client name field cannot be blank: ' + CurrentClient.CommaText)
      else
      begin
        UserID := GetUserID(ImportClient);

        //Importing Prospects
        if FImportType=itProspects then
        begin
          // If theres no code we generate one
          //if there is then we check it and if it cant be used we flag an error
          if (ImportClient.ic_Code = '') then
            ImportClient.ic_Code := GenerateProspectCode(ImportClient.ic_Code,ImportClient.ic_Name,'');
          if not IsCodeValid(ImportClient.ic_Code, Errors, '') then
            ImportFailures.Add(Errors + ': ' + CurrentClient.CommaText)
          else begin
            if not Verify then
              AddNewProspectRec(
                  ImportClient.ic_Code,
                  ImportClient.ic_Name,
                  ImportClient.ic_Address1,
                  ImportClient.ic_Address2,
                  ImportClient.ic_Address3,
                  ImportClient.ic_Phone,
                  ImportClient.ic_Fax,
                  ImportClient.ic_Mobile,
                  ImportClient.ic_Salutation,
                  ImportClient.ic_Email,
                  ImportClient.ic_Contact,
                  UserID);
              Inc(TotalCnt);
          end;
        //Importing Clients (Unlike Prospects we are updating existing Clients only)
        end
        else
        begin
          if not CheckFileOkToImport(ImportClient.ic_Code, ErrorReason) then
            ImportFailures.Add(ErrorReason + ' ' + CurrentClient.CommaText)
          else
          begin
            if not Verify then
              UpdateClientRecord(
                ImportClient.ic_Code,
                ImportClient.ic_Name,
                ImportClient.ic_Address1,
                ImportClient.ic_Address2,
                ImportClient.ic_Address3,
                ImportClient.ic_Phone,
                ImportClient.ic_Fax,
                ImportClient.ic_Mobile,
                ImportClient.ic_Salutation,
                ImportClient.ic_Email,
                ImportClient.ic_Contact,
                UserID);
            Inc(TotalCnt);
          end;
        end;
      end;
    end;

    ClearStatus(True);
    if Verify then
    begin
      LogUtil.LogMsg( lmInfo, UnitName, 'File verified ' +
                  IntToStr(TotalCnt) + GetImportNounStr +' will be ' + GetImportVerbStr + ', ' +
                  IntToStr(importfailures.Count) + ' rejected '+GetImportNounStr);
      ImportFailures.SaveToFile(glDataDir + ExtractFilename(edtCSV.Text) + '.log');
      if not ConfirmImport( edtCSV.Text, TotalCnt, -1, ImportFailures.Count,
        glDataDir + ExtractFilename(edtCSV.Text) + '.log', GetImportNounStr, GetImportVerbStr) then
      begin
         LogUtil.LogMsg( lmInfo, unitname, 'User aborted import');
         exit;
      end;
      Result := mrOk;
    end
    else
    begin
      Result := mrOk;
      if importfailures.Count = 0 then
      begin
        InfoMsg := IntToStr(TotalCnt) + GetImportNounStr+' were ' + GetImportVerbStr + ' successfully.';
        if (FImportType = itClients) then
          InfoMsg := InfoMsg + ' Client files that are open or read-only may not be updated until ' +
                     'updated or closed.';
        HelpfulInfoMsg(InfoMsg, 0)
      end else
      begin
        HelpfulErrorMsg('Some'+GetImportNounStr+' could not be ' + GetImportVerbStr + '. Please see log for more details.' + #13#13 +
          IntToStr(TotalCnt) + GetImportNounStr+' were ' + GetImportVerbStr + ' successfully.' + #13 +
          IntToStr(ImportFailures.Count) + GetImportNounStr+' could not be ' + GetImportVerbStr + '.', 0);
        for i := 0 to Pred(ImportFailures.Count) do
          LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + ImportFailures[i]);
      end;
    end;
  finally
    DeleteFile(glDataDir + ExtractFilename(edtCSV.Text) + '.log');
    ImportFailures.Free;
    CurrentClient.Free;
    ImportList.Free;
    ImportClient.Free;
    ClearStatus(True);
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

function TfrmImportProspects.CheckFileOkToImport(ClientCode: string; var ErrorMessage: string): boolean;
var
  cfRec: pClient_File_Rec;
begin
  ErrorMessage := 'Unknown Error.';
  Result := false;
  if ClientCode = '' then
  begin
    ErrorMessage := 'Client Code cannot be blank.';
    Exit;
  end;

  RefreshAdmin;
  cfRec := AdminSystem.fdSystem_Client_File_List.FindCode(ClientCode);

  if not Assigned(cfRec) then
  begin
    ErrorMessage := 'Client Code must already exist in System.';
    Exit;
  end;

  if cfRec.cfClient_Type = ctProspect then
  begin
    ErrorMessage := 'Client Code must not be that of an existing prospect.';
    Exit;
  end;

  Result := true;
end;


// If emails are in the Global Address List then Outlook returns them in X.400 format
// So we will need to convert them to SMTP
function TfrmImportProspects.ConvertX400ToSMTP(x400: string): string;
const
  PR_EMAIL = $39FE001E; // SMTP email property
  ThisMethodName = 'ConvertX400ToSMTP';
var
  pProp: PSPropValue;
  MP: IMAPIProp;
  address : String;
  i, j, k: Integer;
  outlook, namespace: Variant;
  aList: AddressList;
  allLists: AddressLists;
  allEntries, GALEntries: AddressEntries;
  anEntry, GALEntry: AddressEntry;
begin
  if ((Pos('@', x400) > 0) and (Pos('.', x400) > 0)) or
     (x400 = '') then // Its SMTP or blank
  begin
    Result := x400;
    exit;
  end;
  address := '';
  // Get all address lists
  try
    outlook := CreateOleObject('Outlook.Application');
    namespace := outlook.GetNameSpace('MAPI');
    try
      allLists := IUnknown(namespace.AddressLists) as AddressLists;
      // Find the GAL entries for later lookup
      for i := 1 to allLists.Count do
      begin
        aList := allLists.Item(i);
        if aList.Name = 'Global Address List' then
        begin
          GALEntries := aList.AddressEntries;
          Break;
        end;
      end;
      // Read in from local Contacts address list
      for i := 1 to allLists.Count do
      begin
        aList := allLists.Item(i);
        if aList.Name = 'Contacts' then
        begin
          allEntries := aList.AddressEntries;
          // Search entries for the one we are looking for
          for j := 1 to allEntries.Count do
          begin
            anEntry := allEntries.Item(j);
            if (anEntry.Address = x400) and (anEntry.Type_ = 'EX') then
            begin
              // Find it in the GAL
              for k := 1 to GALEntries.Count do
              begin
                GALEntry := GALEntries.Item(k);
                if GALEntry.Address = anEntry.Address then
                begin
                  try
                    MP:= IUnknown(GALEntry.MAPIOBJECT) as IMailUser;
                  except
                    MP:= IUnknown(GALEntry.MAPIOBJECT) as IDistList;
                  end;
                  // Get the SMTP email
                  if HrGetOneProp(MP, PR_EMAIL, pProp) = S_OK then
                  begin
                    address := pProp.Value.lpszA;
                    MAPIFreeBuffer(pProp);
                    Break;
                  end;
                end;
              end;
            end;
            Application.ProcessMessages;
          end;
          Break;
        end;
      end;
      Result := address;
    finally
      namespace := UnAssigned;
      outlook := UnAssigned;
    end;
  except on E: SysUtils.Exception do
   begin
    result := '';
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Error converting:' + x400 + ' message: ' + E.Message);
   end;
  end; 
end;

procedure TfrmImportProspects.FormDestroy(Sender: TObject);
begin
  MAPIUninitialize;
  if Assigned(opoContacts) then
    FreeAndNil(opoContacts);
  if Assigned(ocdsContacts) then
    FreeAndNil(ocdsContacts);
end;

procedure TfrmImportProspects.btnCheckClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Pred(clbContacts.Items.Count) do
    clbContacts.Checked[i] := True;
  clbContactsClick(Self);
end;

procedure TfrmImportProspects.btnClearClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Pred(clbContacts.Items.Count) do
    clbContacts.Checked[i] := False;
  clbContactsClick(Self);
end;

procedure TfrmImportProspects.chkSelectClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Pred(clbContacts.Items.Count) do
    if clbContacts.Selected[i] then
      clbContacts.Checked[i] := chkSelect.Checked;
  clbContactsClick(Self);      
end;

procedure TfrmImportProspects.clbContactsClick(Sender: TObject);
var
  i: Integer;
  AnyUnchecked, AnyChecked: Boolean;
begin
  chkSelect.Enabled := clbContacts.SelCount > 0;
  AnyUnchecked := False;
  AnyChecked := False;
  for i := 0 to Pred(clbContacts.Items.Count) do
    if not clbContacts.Checked[i] then
      AnyUnchecked := True
    else
      AnyChecked := True;
  btnCheck.Enabled := AnyUnchecked;
  btnClear.Enabled := AnyChecked;
end;

procedure TfrmImportProspects.FormActivate(Sender: TObject);
begin
  Application.BringToFront;
end;

procedure TfrmImportProspects.FormPosChanging(var Msg: TWmWindowPosChanging);
begin
  // Do not allow the form to be moved during import
  if not Enabled then
  begin
    Msg.WindowPos.x := StickyLeft;
    Msg.WindowPos.y := StickyTop;
    Msg.Result := 0;
  end;
end;


{ TImport_Client }

procedure TImport_Client.Setic_Address1(const Value: String);
begin
  Fic_Address1 := Value;
end;

procedure TImport_Client.Setic_Address2(const Value: String);
begin
  Fic_Address2 := Value;
end;

procedure TImport_Client.Setic_Address3(const Value: String);
begin
  Fic_Address3 := Value;
end;

procedure TImport_Client.Setic_Code(const Value: String);
begin
  Fic_Code := Value;
end;

procedure TImport_Client.Setic_Contact(const Value: String);
begin
  Fic_Contact := Value;
end;

procedure TImport_Client.Setic_Email(const Value: String);
begin
  Fic_Email := Value;
end;

procedure TImport_Client.Setic_Fax(const Value: String);
begin
  Fic_Fax := Value;
end;

procedure TImport_Client.Setic_Mobile(const Value: String);
begin
  Fic_Mobile := Value;
end;

procedure TImport_Client.Setic_Name(const Value: String);
begin
  Fic_Name := Value;
end;

procedure TImport_Client.Setic_Phone(const Value: String);
begin
  Fic_Phone := Value;
end;

procedure TImport_Client.Setic_Salutation(const Value: String);
begin
  Fic_Salutation := Value;
end;

procedure TImport_Client.Setic_User(const Value: String);
begin
  Fic_User := Value;
end;

initialization
   DebugMe := DebugUnit(UnitName);

end.
