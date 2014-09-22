unit EditAccountDlg;
//------------------------------------------------------------------------------
interface

//------------------------------------------------------------------------------
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, bkDefs, Buttons, CheckLst, ExtCtrls, ComCtrls, Grids_ts, TSGrid,
  TSMask,
  OsFont;

type
  TDivisionDataRec = record
    DivisionNo : integer;
  end;

  TDivisionNamesRec = record
    DivisionNo : integer;
    DivisionName : string;
  end;

type
  TdlgEditAccount = class(TForm)
    pgAccountDetails: TPageControl;
    tsDetails: TTabSheet;
    lblDivision: TLabel;
    Label3: TLabel;
    cmbGroup: TComboBox;
    cmbGST: TComboBox;
    lblGST: TLabel;
    chkPosting: TCheckBox;
    eDesc: TEdit;
    Label5: TLabel;
    Label1: TLabel;
    eCode: TEdit;
    lblSubGroup: TLabel;
    cmbSubGroup: TComboBox;
    tsLinkedAccounts: TTabSheet;
    pnlLinkForStockOnHand: TPanel;
    Label6: TLabel;
    pnlButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    lblLinkAccount1: TLabel;
    edtLinkedAccount1: TEdit;
    lblLinkAccount1_Desc: TLabel;
    lblLinkAccount2: TLabel;
    edtLinkedAccount2: TEdit;
    lblLinkAccount2_Desc: TLabel;
    tgDivisions: TtsGrid;
    tsMaskDefs1: TtsMaskDefs;
    sbtnChart1: TSpeedButton;
    sbtnChart2: TSpeedButton;
    chkBasic: TCheckBox;
    lblAltCodeName: TLabel;
    eAltCode: TEdit;
    chkInactive: TCheckBox;

    procedure chkPostingClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure cmbGSTDropDown(Sender: TObject);
    procedure cmbGSTChange(Sender: TObject);
    procedure cmbGroupChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure eCodeChange(Sender: TObject);
    procedure edtLinkedAccount1Change(Sender: TObject);
    procedure edtLinkedAccount1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtLinkedAccount1KeyPress(Sender: TObject; var Key: Char);
    procedure edtLinkedAccount1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure DivisionLookupCellLoaded(Sender: TObject; DataCol, DataRow: Integer; var Value: Variant);
    procedure tgDivisionsCellLoaded(Sender: TObject; DataCol,
      DataRow: Integer; var Value: Variant);
    procedure tgDivisionsComboInit(Sender: TObject; Combo: TtsComboGrid;
      DataCol, DataRow: Integer);
    procedure tgDivisionsEndCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure tgDivisionsComboGetValue(Sender: TObject;
      Combo: TtsComboGrid; GridDataCol, GridDataRow, ComboDataRow: Integer;
      var Value: Variant);
    procedure sbtnChart1Click(Sender: TObject);
    procedure sbtnChart2Click(Sender: TObject);
    procedure edtLinkedAccount2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtLinkedAccount2KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    okPressed : boolean;
    Account   : pAccount_Rec;
    LastGSTCmbIndex : integer;
    InEditAccountMode : boolean;
    RemovingMask      : boolean;
    OldGroup    : Integer;
    OldSubGroup : Integer;
    FTaxName : String[10];

    UpdatingLinkedAccounts : boolean;

    DivisionData   : Array of TDivisionDataRec;
    DivisionNames  : Array of TDivisionNamesRec;
    FHasAlternativeCode: Boolean;

    // ---------------------
    function OKtoPost : boolean;
    Procedure AccountTypeChanged;
    Procedure SetupSubGroupList;
    function  GetCurrentlySelectedGroup : integer;
    procedure SetupDivisions;
    procedure LoadDivisions( FromAccount : pAccount_Rec);
    procedure SaveDivisions( Acct : pAccount_Rec);

    procedure SaveAccountDetails( Acct : pAccount_Rec);

    procedure LoadLinkedAccounts( FromAccount : pAccount_Rec);
    procedure SaveLinkedAccounts( ToAccount : pAccount_Rec);
    procedure UpdateLinkedAccounts;
    procedure VerifyLinkedAccounts( var FailureMsg : string);
    procedure SetHasAlternativeCode(const Value: Boolean);
    property HasAlternativeCode: Boolean read FHasAlternativeCode write SetHasAlternativeCode;
  public
    { Public declarations }
    function Execute : boolean;
  end;

function EditChartAccount(eAccount : pAccount_rec; AllowCodeChange: Boolean = True) : boolean;
function AddChartAccount( var nAccount : pAccount_Rec) : boolean;

//******************************************************************************
implementation

uses
  software,
  AccountLookupFrm,
  bkConst,
  bkchio,
  BKHelp,
  bkMaskUtils,
  bkXPThemes,
  ErrorMoreFrm,
  glConst,
  globals,
  ImagesFrm,
  infoMorefrm,
  winutils,
  YesNoDlg, clObj32, CustomHeadingsListObj, chList32, CountryUtils;

{$R *.DFM}

const
  ColID     = 1;
  ColDesc   = 2;

//------------------------------------------------------------------------------
function OpeningStockFilter(const pAcct : pAccount_Rec) : boolean;
begin
  result := pAcct.chAccount_Type = atOpeningStock;
end;

function ClosingStockFilter(const pAcct : pAccount_Rec) : boolean;
begin
  result := pAcct.chAccount_Type = atClosingStock;
end;
//------------------------------------------------------------------------------
procedure TdlgEditAccount.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  SetUpHelp;
  pgAccountDetails.ActivePage := tsDetails;
  eCode.MaxLength               := BKCONST.MaxBK5CodeLen;
  eAltCode.MaxLength            := BKCONST.MaxBK5CodeLen;
  edtLinkedAccount1.MaxLength   := MaxBk5CodeLen;
  edtLinkedAccount2.MaxLength   := MaxBk5CodeLen;

  RemovingMask                  := false;
  UpdatingLinkedAccounts        := false;

  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,sbtnChart1.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,sbtnChart2.Glyph);

  //setup grid
  tgDivisions.Col[2].ParentCombo      := true;
  tgDivisions.Col[2].ButtonType       := btCombo;
  tgDivisions.Col[2].AssignCombo;
  FTaxName := MyClient.TaxSystemNameUC;
  lblGST.Caption := '&' + FTaxName + ' Class';
  HasAlternativeCode :=
    HasAlternativeChartCode(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used);
end;
//------------------------------------------------------------------------------
procedure TdlgEditAccount.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   eCode.Hint                :=
                             'Enter the Account Code|' +
                             'Enter the Account Code used in your main accounting system';
   eDesc.Hint                :=
                             'Enter a full description of the Account|' +
                             'Enter a full description of the Account';
   chkPosting.Hint           :=
                             'Check to allow entries to be posted to this Account Code|' +
                             'UnChecked means no entries can be posted, this is usually for narative purposes only';
   chkBasic.Hint             :=
                             'Check to include this Account Code in the basic chart|' +
                             'Check to include this Account Code in the basic chart';
   cmbGroup.Hint             :=
                             'Select the Report Heading for the Account Code|' +
                             'Select a Report Heading under which you want this Account Code to appear in the reports';
   cmbSubGroup.Hint          :=
                             'Select the Report Subgroup for the Account Code|' +
                             'Select the subgroup under which you want this Account Code to appear in the reports';
   tgDivisions.Hint          :=
                             'Select the division(s) for the Account Code|' +
                             'Select the division(s) which you want this Account Code in be included in';
   cmbGST.Hint               :=
                             'Select the ' + FTaxName + ' Class to apply to this Account Code|' +
                             'Select the ' + FTaxName + ' Class to apply to this Account Code';
end;
//------------------------------------------------------------------------------
procedure TdlgEditAccount.chkPostingClick(Sender: TObject);
begin
end;
//------------------------------------------------------------------------------
procedure TdlgEditAccount.cmbGSTDropDown(Sender: TObject);
begin
   //try to set default drop down width
   SendMessage(cmbGST.Handle, CB_SETDROPPEDWIDTH, 345, 0);
end;
//------------------------------------------------------------------------------
function EditChartAccount(eAccount: pAccount_rec; AllowCodeChange: Boolean = True) : boolean;
var
  MyDlg : TdlgEditAccount;
begin
  result := false;

  if not Assigned(eAccount) then exit;
  MyDlg := TdlgEditAccount.create(Application.MainForm);
  try
    BKHelpSetUp(MyDlg, BKH_Entering_a_chart_directly_into_BankLink);
    MyDlg.Account := eAccount;
    MyDlg.Caption := 'Edit Account';
    MyDlg.InEditAccountMode := true;
    MyDlg.OldGroup := eAccount.chAccount_Type;
    MyDlg.OldSubGroup := eAccount.chSubtype;
    MyDlg.eCode.Enabled := AllowCodeChange;
    //MyDlg.eAltCode.Enabled := AllowCodeChange;  not for now..
    if MyDlg.Execute then begin
       {write back new values}
       MyDlg.SaveAccountDetails( eAccount);
       result := true;
    end;
  finally
    MyDlg.free;
  end;
end;
//------------------------------------------------------------------------------
function AddChartAccount( var nAccount : pAccount_Rec) : boolean;
var
  MyDlg : TdlgEditAccount;
begin
  result := false;
  if Assigned(nAccount) then nAccount := nil;

  MyDlg := TdlgEditAccount.create(Application.MainForm);
  try
    BKHelpSetUp(MyDlg, BKH_Entering_a_chart_directly_into_BankLink);
    MyDlg.Account           := nAccount;
    MyDlg.Caption           := 'Add Chart Account';
    MyDlg.InEditAccountMode := false;
    MyDlg.OldGroup          := 0;
    MyDlg.OldSubGroup       := 0;

    if MyDlg.Execute then begin
       {create new account}
       nAccount := New_Account_Rec;
       {write back new values}
       MyDlg.SaveAccountDetails( nAccount);

       MyClient.clChart.Insert(nAccount);
       result := true;
    end;
  finally
    MyDlg.free;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditAccount.eCodeChange(Sender: TObject);
begin

end;
//------------------------------------------------------------------------------
procedure TdlgEditAccount.btnCancelClick(Sender: TObject);
begin
   okPressed := false;
   Close;
end;
//------------------------------------------------------------------------------
procedure TdlgEditAccount.btnOKClick(Sender: TObject);
begin
  if OKtoPost then
  begin
    okPressed := true;
    Close;
  end;
end;
//------------------------------------------------------------------------------
function TdlgEditAccount.Execute: boolean;
const
   ReportGroupsToExclude = [ atRetainedPorL, atCurrentYearsEarnings, atUncodedCR, atUncodedDR ];
var
  i : integer;
  ReportGroup : byte;
begin
  okPressed := false;

  //load combos
  cmbGroup.Items.Clear;
  for i := atMin to atMax do begin
     ReportGroup := ReportGroupsDisplayOrder[ i];
     if not( ReportGroup in ReportGroupsToExclude) then
        cmbGroup.Items.AddObject( Localise(MyClient.clFields.clCountry, atNames[ ReportGroup]),
                                  TObject( ReportGroup));
  end;

  //Load GST Types combo,  only load items that have a id and a description
  //Store the actual gst type in the object value of the item.
  //load 'not assigned' as the first item so it can be selected
  cmbGST.Items.Clear;
  cmbGST.Items.add('N/A');

  with MyClient.clFields do begin
     for i := 1 to MAX_GST_CLASS do begin
        if ( clGST_Class_Names[i] <> '') and ( clGST_Class_Codes[i] <> '') then begin
           cmbGST.Items.AddObject( clGST_Class_Codes[i]+'  '+clGST_Class_Names[i], TObject( i));
        end;
     end;
  end;

  //load divisions
  SetupDivisions;

  //setup report groups
  SetupSubGroupList;

  {load values}
  if Assigned(Account) then
  begin
    eCode.Text           := Account.chAccount_Code;
    eAltCode.Text        := Account.chAlternative_Code;
    eDesc.Text           := Account.chAccount_Description;
    chkPosting.Checked   := Account.chPosting_Allowed;
    chkBasic.Checked     := not Account.chHide_In_Basic_Chart;
    chkInactive.Checked  := Account.chInactive;
    LoadLinkedAccounts( Account);

    //report groups
    cmbGroup.ItemIndex := 0;
    if (Account.chAccount_Type in [atMin..atMax]) then begin
       for i := 0 to cmbGroup.Items.Count - 1 do
          if Integer( cmbGroup.Items.Objects[ i]) = Account.chAccount_Type then
            cmbGroup.ItemIndex := i;
    end;
    //subgroups
    if Account.chSubtype in [0..Max_SubGroups] then
      cmbSubGroup.ItemIndex := Account.chSubtype
    else
      cmbSubGroup.ItemIndex := 0;

    //Divisions
    LoadDivisions( Account);

    //GST
    cmbGST.ItemIndex := 0;  // not assigned
    if Account.chGST_Class in [1..MAX_GST_CLASS] then begin
       for i := 1 to Pred( cmbGST.Items.Count) do
          if Integer( cmbGST.Items.Objects[ i]) = Account.chGST_Class then begin
             cmbGST.ItemIndex := i;
             break;
          end;
    end;
    LastGSTCmbIndex := cmbGST.ItemIndex;
  end
  else
  begin
    eCode.text := '';
    eAltCode.text := '';
    eDesc.text := '';
    cmbGroup.ItemIndex := 0;
    cmbGst.ItemIndex   := 0;
    cmbSubGroup.ItemIndex := 0;

    chkPosting.Checked := true;
    chkBasic.Checked := true;
    chkInactive.Visible := false;
    chkInactive.Checked := false;

    LoadLinkedAccounts( nil);
  end;

  if not Assigned(AdminSystem) then
    chkBasic.Visible := false; //in books they can't add an item to the full chart.

  AccountTypeChanged;
  UpdateLinkedAccounts;

  ShowModal;
  result := okPressed;
end;
//------------------------------------------------------------------------------
function TdlgEditAccount.OKtoPost: boolean;
var
  Account_Code,
  wasCode : string;
  aMsg    : string;
  ExistingAccount: pAccount_Rec;
  Msg: String;
begin
  result := false;

  if Assigned(Account) then
     wasCode := Account.chAccount_Code
  else
     wasCode := '';

  Account_Code := eCode.Text;

  If (Account_Code = '') then
  Begin
    HelpfulErrorMsg( 'You must enter an account code', 0 );
    pgAccountDetails.ActivePage := tsDetails;
    if eCode.Enabled then eCode.SetFocus else eDesc.SetFocus;
    exit;
  end;

  //Check if code already exists. For books the error message changes depending on if the
  //existing account is in the basic or full chart. Case 5333.
  ExistingAccount := MyClient.clChart.FindCode(Account_Code);
  If Assigned(ExistingAccount) and (Account_Code <> wasCode) then
  Begin
    if Assigned(AdminSystem) or not ExistingAccount^.chHide_In_Basic_Chart then
      Msg := 'This account code has already been entered'
    else
      Msg := Format('The code %s:%s already exists in the full chart of accounts used by your accountant', [Account_Code, ExistingAccount^.chAccount_Description]);
    HelpfulErrorMsg(Msg, 0);
    pgAccountDetails.ActivePage := tsDetails;
    if eCode.Enabled then
      eCode.SetFocus
    else
      eDesc.SetFocus;
    Exit;
  end;

  //verify linked accounts
  VerifyLinkedAccounts( aMsg);
  if aMsg <> '' then begin
    HelpfulErrorMsg( aMsg, 0);
    pgAccountDetails.ActivePage := tsLinkedAccounts;
    edtLinkedAccount1.SetFocus;
    Exit;
  end;

  result := true;
end;
//------------------------------------------------------------------------------
procedure TdlgEditAccount.cmbGSTChange(Sender: TObject);
begin
   if INI_DontShowMe_EditChartGST or ( not InEditAccountMode) then exit;
   //Ask to user if the want to do this
   if AskYesNoCheck( 'Edit ' + FTaxName + ' Class for Account',
                     'This will change the ' + FTaxName + ' Class and Amount for all Entries that '+
                     'are coded to this chart code, which are yet to be transferred or finalised. '#13#13+
                     'Entries where the ' + FTaxName + ' has been overridden will not be affected.'#13#13+
                     'Please confirm you want to do this?',
                     '&Don''t ask me this again',
                     INI_DontShowMe_EditChartGST,
                     DLG_YES, 0) <> DLG_YES then begin
      cmbGST.ItemIndex := LastGSTCmbIndex;
   end
   else
      LastGSTCmbIndex := cmbGST.ItemIndex;
end;

//------------------------------------------------------------------------------

procedure TdlgEditAccount.cmbGroupChange(Sender: TObject);
begin
   AccountTypeChanged;
end;

//------------------------------------------------------------------------------

Procedure TdlgEditAccount.AccountTypeChanged;
Var
   aType : Integer;
   LinkedAccountsNeeded : boolean;
Begin
   aType := GetCurrentlySelectedGroup;

   LinkedAccountsNeeded := aType in [ atOpeningStock,
                                      atClosingStock,
                                      atStockOnHand ];
   if not LinkedAccountsNeeded then
     pgAccountDetails.ActivePage := tsDetails;

   tsLinkedAccounts.TabVisible := LinkedAccountsNeeded;
   UpdateLinkedAccounts;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure TdlgEditAccount.SetupSubGroupList;
Var
   i     : Integer;
   Desc  : String;
Begin
   cmbSubGroup.ItemIndex := -1;
   cmbSubGroup.Items.Clear;

   Desc := MyClient.clCustom_Headings_List.Get_SubGroup_Heading( 0);
   If Desc = '' then
      cmbSubGroup.Items.Add( 'Unallocated' )
   else
      cmbSubGroup.Items.Add( Desc );

   For i := 1 to Max_SubGroups do
   Begin
      Desc := Format( '%d - %s', [ i, MyClient.clCustom_Headings_List.Get_SubGroup_Heading( i)]);
      cmbSubGroup.Items.Add( Desc );
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgEditAccount.GetCurrentlySelectedGroup: integer;
//returns the corresponding account type for the current selected item
//returns -1 if not allocated
begin
   if cmbGroup.ItemIndex >= 0 then
      result := Integer( cmbGroup.Items.Objects[ cmbGroup.ItemIndex])
   else
      result := -1;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgEditAccount.FormActivate(Sender: TObject);
begin
  if eCode.Enabled then eCode.SetFocus else eDesc.SetFocus;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditAccount.SaveAccountDetails(Acct: pAccount_Rec);
begin
   Acct.chAccount_Code := eCode.Text;
   //Acct.chAlternative_Code := eAltCode.Text;  Cannot edit for now
   Acct.chAccount_Description := eDesc.text;
   Acct.chPosting_Allowed := chkPosting.checked;
   Acct.chHide_In_Basic_Chart := not chkBasic.Checked;
   Acct.chInactive := chkInactive.Checked;
   //gst
   if cmbGST.ItemIndex > 0 then begin
      Acct.chGST_Class := Integer( cmbGST.Items.Objects[ cmbGST.ItemIndex]);
   end
   else
      Acct.chGST_Class := 0;  //not assigned

   if (GetCurrentlySelectedGroup > - 1 ) then
      Acct.chAccount_Type := GetCurrentlySelectedGroup;

   If cmbSubGroup.ItemIndex > -1 then
      Acct.chSubtype     := cmbSubGroup.ItemIndex;

   //divisions
   SaveDivisions( Acct);

   //find currently linked accounts
   SaveLinkedAccounts( Acct);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditAccount.UpdateLinkedAccounts;
var
  aType : integer;
  pAcct : pAccount_Rec;

  AccountCode : string;
begin
  if UpdatingLinkedAccounts then exit;

  UpdatingLinkedAccounts := true;
  try
    aType := GetCurrentlySelectedGroup;

    //Opening Stock
    case aType of
      atOpeningStock : begin
        //this accounts links to closing stock accounts
        lblLinkAccount1.Caption := 'Closing Stoc&k Account';
        AccountCode := Trim( edtLinkedAccount1.Text);
        pAcct := MyClient.clChart.FindCode( AccountCode);
        if Assigned( pAcct) then
          lblLinkAccount1_Desc.Caption := pAcct^.chAccount_Description
        else
          lblLinkAccount1_Desc.Caption := '';
      end;

      atClosingStock : begin
        //linked to opening stock
        lblLinkAccount1.Caption := '&Opening Stock Account';
        AccountCode := Trim( edtLinkedAccount1.Text);
        pAcct := MyClient.clChart.FindCode( AccountCode);
        if Assigned( pAcct) then
          lblLinkAccount1_Desc.Caption := pAcct^.chAccount_Description
        else
          lblLinkAccount1_Desc.Caption := '';
      end;

      atStockOnHand : begin
        //linked to opening stock
        lblLinkAccount1.Caption := '&Opening Stock Account';
        AccountCode := Trim( edtLinkedAccount1.Text);
        pAcct := MyClient.clChart.FindCode( AccountCode);
        if Assigned( pAcct) then
          lblLinkAccount1_Desc.Caption := pAcct^.chAccount_Description
        else
          lblLinkAccount1_Desc.Caption := '';

        //this accounts links to closing stock accounts
        lblLinkAccount2.Caption := 'Closing Stoc&k Account';
        AccountCode := Trim( edtLinkedAccount2.Text);
        pAcct := MyClient.clChart.FindCode( AccountCode);
        if Assigned( pAcct) then
          lblLinkAccount2_Desc.Caption := pAcct^.chAccount_Description
        else
          lblLinkAccount2_Desc.Caption := '';
      end;
      else begin
        //tab will be hidden if account type has no linked accounts

      end
    end; //case

    lblLinkAccount1.Visible       := aType in [atOpeningStock, atClosingStock, atStockOnHand];
    edtLinkedAccount1.Visible     := lblLinkAccount1.Visible;
    lblLinkAccount1_Desc.Visible  := lblLinkAccount1.Visible;
    sbtnChart1.Visible            := lblLinkAccount1.Visible;

    lblLinkAccount2.Visible       := aType in [ atStockOnHand];
    edtLinkedAccount2.Visible     := lblLinkAccount2.Visible;
    lblLinkAccount2_Desc.Visible  := lblLinkAccount2.Visible;
    sbtnChart2.Visible            := lblLinkAccount2.Visible;

  finally
    UpdatingLinkedAccounts := false;
  end;
end;

procedure TdlgEditAccount.LoadLinkedAccounts( FromAccount : pAccount_Rec);
var
  aType : integer;
begin
  //clear existing values
  edtLinkedAccount1.Text := '';
  edtLinkedAccount2.Text := '';

  if not Assigned( FromAccount) then
    Exit;

  aType := FromAccount.chAccount_Type;
  case aType of
    atOpeningStock : begin  //links to closing stock
      edtLinkedAccount1.Text := Account.chLinked_Account_CS;
    end;
    atClosingStock : begin
      edtLinkedAccount1.Text := Account.chLinked_Account_OS;
    end;
    atStockOnHand : begin
      edtLinkedAccount1.Text := Account.chLinked_Account_OS;
      edtLinkedAccount2.Text := Account.chLinked_Account_CS;
    end;
  end;
  UpdateLinkedAccounts;
end;

procedure TdlgEditAccount.SaveLinkedAccounts( ToAccount : pAccount_Rec);
var
  aType : integer;
  pAcct : pAccount_Rec;
  CS    : string;
  OS    : string;
begin
  aType := ToAccount.chAccount_Type;

  case aType of
    atOpeningStock : begin
      //find the existing closing stock account
      CS := ToAccount.chLinked_Account_CS;
      pAcct := MyClient.clChart.FindCode( CS);
      if Assigned( pAcct) then begin
        pAcct^.chLinked_Account_OS := '';
      end;
      ToAccount^.chLinked_Account_CS := '';

      //assign new links
      CS := Trim( edtLinkedAccount1.Text);
      pAcct := MyClient.clChart.FindCode( CS);
      if Assigned( pAcct) then begin
        pAcct^.chLinked_Account_OS     := ToAccount.chAccount_Code;
        ToAccount^.chLinked_Account_CS := CS;
      end;
    end;
    atClosingStock : begin
      //clear old links
      OS := ToAccount.chLinked_Account_OS;
      pAcct := MyClient.clChart.FindCode( OS);
      if Assigned( pAcct) then begin
        pAcct^.chLinked_Account_CS := '';
      end;
      ToAccount^.chLinked_Account_OS := '';

      //assign new links
      OS := Trim( edtLinkedAccount1.Text);
      pAcct := MyClient.clChart.FindCode( OS);
      if Assigned( pAcct) then begin
        pAcct^.chLinked_Account_CS     := ToAccount.chAccount_Code;
        ToAccount^.chLinked_Account_OS := OS;
      end;
    end;

    atStockOnHand : begin
      //clear old links
      ToAccount^.chLinked_Account_OS := '';
      ToAccount^.chLinked_Account_CS := '';

      //assign new links
      OS := Trim( edtLinkedAccount1.Text);
      pAcct := MyClient.clChart.FindCode( OS);
      if Assigned( pAcct) then begin
        ToAccount^.chLinked_Account_OS := OS;
      end;
      CS := Trim( edtLinkedAccount2.Text);
      pAcct := MyClient.clChart.FindCode( CS);
      if Assigned( pAcct) then begin
        ToAccount^.chLinked_Account_CS := CS;
      end;
    end;

    else begin
      //delete links to this account as it is no longer correct type
    end;
  end;
end;

procedure TdlgEditAccount.VerifyLinkedAccounts( var FailureMsg : string);
var
  aType : integer;
  OS    : string;
  CS    : string;
  pAcct : pAccount_Rec;
  i     : integer;
begin
  FailureMsg := '';

  aType := GetCurrentlySelectedGroup;

  //Opening Stock
  case aType of
    atOpeningStock : begin
      //must be linked to a closing stock account
      CS := Trim( edtLinkedAccount1.Text);
      if CS = '' then
        Exit;

      pAcct := MyClient.clChart.FindCode( CS);
      if not Assigned( pAcct) then begin
        FailureMsg := 'The specified Closing Stock account does not exist';
        Exit;
      end;

      //account found
      if pAcct^.chAccount_Type <> atClosingStock then begin
        FailureMsg := 'The specified Closing Stock account does not have the report group "Closing Stock"';
        Exit;
      end;

      //account exists and is a closing stock account, make sure is not
      //attached to other opening stock
      for i := 0 to Pred( MyClient.clChart.ItemCount) do begin
        pAcct := MyClient.clChart.Account_At( i);
        if (pAcct^.chAccount_Code <> Trim( eCode.Text)) and
           (pAcct^.chAccount_Type = atOpeningStock) and
           (pAcct^.chLinked_Account_CS = CS) then begin
          FailureMsg := 'The specified Closing Stock account is already linked to by '#13#13 +
                        pAcct^.chAccount_Code + ' ' + pAcct^.chAccount_Description;
          Exit;
        end;
      end;
      //all ok
    end;  //atOpeningStock

    atClosingStock : begin
      //must be linked to an opening stock account
      OS := Trim( edtLinkedAccount1.Text);
      if OS = '' then
        Exit;

      pAcct := MyClient.clChart.FindCode( OS);
      if not Assigned( pAcct) then begin
        FailureMsg := 'The specified Opening Stock account does not exist';
        Exit;
      end;

      //account found
      if pAcct^.chAccount_Type <> atOpeningStock then begin
        FailureMsg := 'The specified Opening Stock account does not have the report group "Opening Stock"';
        Exit;
      end;

      //account exists and is a closing stock account, make sure is not
      //attached to other opening stock
      for i := 0 to Pred( MyClient.clChart.ItemCount) do begin
        pAcct := MyClient.clChart.Account_At( i);
        if (pAcct^.chAccount_Code <> Trim( eCode.Text)) and
           (pAcct^.chAccount_Type = atClosingStock) and
           (pAcct^.chLinked_Account_OS = OS) then begin
          FailureMsg := 'The specified Opening Stock account is already linked to by '#13#13 +
                        pAcct^.chAccount_Code + ' ' + pAcct^.chAccount_Description;
          Exit;
        end;
      end;
    end;

    atStockOnHand : begin
      OS := Trim( edtLinkedAccount1.Text);
      CS := Trim( edtLinkedAccount2.Text);
      if (OS = '') and (CS = '') then
        Exit;

      //make sure that both opening and closing stock are specified
      if (OS = '') or (CS = '') then begin
        FailureMsg := 'You must specify both an Opening Stock and a Closing Stock account';
        Exit;
      end;

      //check opening stock
      pAcct := MyClient.clChart.FindCode( OS);
      if not Assigned( pAcct) then begin
        FailureMsg := 'The specified Opening Stock account does not exist';
        Exit;
      end;
      //account found
      if pAcct^.chAccount_Type <> atOpeningStock then begin
        FailureMsg := 'The specified Opening Stock account does not have the report group "Opening Stock"';
        Exit;
      end;
      //account exists and is a closing stock account, make sure is not
      //attached to other stock on hand accounts
      for i := 0 to Pred( MyClient.clChart.ItemCount) do begin
        pAcct := MyClient.clChart.Account_At( i);
        if (pAcct^.chAccount_Code <> Trim( eCode.Text)) and
           (pAcct^.chAccount_Type = atStockOnHand) and
           (pAcct^.chLinked_Account_OS = OS) then begin
          FailureMsg := 'The specified Opening Stock account is already linked to by '#13#13 +
                        pAcct^.chAccount_Code + ' ' + pAcct^.chAccount_Description;
          Exit;
        end;
      end;

      //check closing stock
      pAcct := MyClient.clChart.FindCode( CS);
      if not Assigned( pAcct) then begin
        FailureMsg := 'The specified Closing Stock account does not exist';
        Exit;
      end;
      //account found
      if pAcct^.chAccount_Type <> atClosingStock then begin
        FailureMsg := 'The specified Closing Stock account does not have the report group "Closing Stock"';
        Exit;
      end;
      //account exists and is a closing stock account, make sure is not
      //attached to other stock on hand accounts
      for i := 0 to Pred( MyClient.clChart.ItemCount) do begin
        pAcct := MyClient.clChart.Account_At( i);
        if (pAcct^.chAccount_Code <> Trim( eCode.Text)) and
           (pAcct^.chAccount_Type = atStockOnHand) and
           (pAcct^.chLinked_Account_CS = CS) then begin
          FailureMsg := 'The specified Closing Stock account is already linked to by '#13#13 +
                        pAcct^.chAccount_Code + ' ' + pAcct^.chAccount_Description;
          Exit;
        end;
      end;
    end;
  end; //case
end;

procedure TdlgEditAccount.edtLinkedAccount1Change(Sender: TObject);
begin
  CheckforMaskChar( TEdit( Sender),RemovingMask);
  UpdateLinkedAccounts;
end;

procedure TdlgEditAccount.edtLinkedAccount1KeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if key = vk_back then CheckRemoveMaskChar( TEdit(Sender),RemovingMask);
end;

procedure TdlgEditAccount.edtLinkedAccount1KeyPress(Sender: TObject;
  var Key: Char);
var
  aType : Integer;
begin
  if ((key='-') and (myClient.clFields.clUse_Minus_As_Lookup_Key)) then
  begin
    key := #0;
    aType := GetCurrentlySelectedGroup;
    case aType of
      atOpeningStock : PickCodeForEdit(Sender, ClosingStockFilter, False);
      atClosingStock : PickCodeForEdit(Sender, OpeningStockFilter, False);
      atStockOnHand  : PickCodeForEdit(Sender, OpeningStockFilter, False);
    end;
 end;
end;

procedure TdlgEditAccount.edtLinkedAccount1KeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  aType : Integer;
begin
  if (key = VK_F2) or ((key=40) and (Shift = [ssAlt])) then
  begin
    aType := GetCurrentlySelectedGroup;
    case aType of
      atOpeningStock : PickCodeForEdit(Sender, ClosingStockFilter, False);
      atClosingStock : PickCodeForEdit(Sender, OpeningStockFilter, False);
      atStockOnHand  : PickCodeForEdit(Sender, OpeningStockFilter, False);
    end;
  end;
end;

procedure TdlgEditAccount.edtLinkedAccount2KeyPress(Sender: TObject;
  var Key: Char);
var
  aType : Integer;
begin
  if ((key='-') and (myClient.clFields.clUse_Minus_As_Lookup_Key)) then
  begin
    key := #0;
    aType := GetCurrentlySelectedGroup;
    case aType of
      atStockOnHand  : PickCodeForEdit(Sender, ClosingStockFilter, False);
    end;
 end;
end;

procedure TdlgEditAccount.edtLinkedAccount2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  aType : Integer;
begin
  if (key = VK_F2) or ((key=40) and (Shift = [ssAlt])) then
  begin
    aType := GetCurrentlySelectedGroup;
    case aType of
      atStockOnHand  : PickCodeForEdit(Sender, ClosingStockFilter, False);
    end;
  end;
end;

procedure TdlgEditAccount.SetHasAlternativeCode(const Value: Boolean);
begin
  FHasAlternativeCode := Value;
  if FHasAlternativeCode then begin
     lblAltCodeName.Caption :=  AlternativeChartCodeName(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used);
  
  end;
  lblAltCodeName.Visible := FHasAlternativeCode;
  eAltCode.Visible := FHasAlternativeCode;
end;

procedure TdlgEditAccount.SetupDivisions;
var
  i : integer;
  DivName : string;
begin
  //initialise divisions array
  SetLength( DivisionData, GlConst.Max_Divisions);
  for i := Low( DivisionData) to High( DivisionData) do begin
    DivisionData[i].DivisionNo  := 0;
  end;
  //initialise grid
  tgDivisions.Rows := glconst.Max_Divisions;
  //load division names into temp array
  SetLength( DivisionNames, glconst.Max_Divisions);
  for i := 1 to Max_Divisions do begin
    DivName := Trim(MyClient.clCustom_Headings_List.Get_Division_Heading( i));
    DivisionNames[i-1].DivisionNo  := i;
    DivisionNames[i-1].DivisionName := DivName;
  end;
end;

procedure TdlgEditAccount.FormDestroy(Sender: TObject);
begin
  SetLength( DivisionData, 0);
end;

procedure TdlgEditAccount.LoadDivisions( FromAccount : pAccount_Rec);
var
  i            : integer;
  CurrentLine  : integer;
begin
  if not Assigned( FromAccount) then
    Exit;

  CurrentLine := 0;
  //find out which divisions are being used by this chart code
  for i := 1 to Max_Divisions do
    if FromAccount.chPrint_in_Division[i] then begin
      DivisionData[CurrentLine].DivisionNo  := i;
      Inc( CurrentLine);
    end;
end;

procedure TdlgEditAccount.SaveDivisions( Acct : pAccount_Rec);
var
  DivNo  : integer;
  i      : integer;
begin
  //reset current flags
  for i := 1 to Max_Divisions do
    Acct.chPrint_in_Division[i] := false;
  //set new flags
  for i := Low( DivisionData) to High( DivisionData) do begin
    DivNo := DivisionData[ i].DivisionNo;
    if DivNo in [ 1..Max_Divisions] then
      Acct.chPrint_In_Division[ DivNo] := true;
  end;
end;

procedure TdlgEditAccount.tgDivisionsComboInit(Sender: TObject;
  Combo: TtsComboGrid; DataCol, DataRow: Integer);
const
  ColComboID   = 1;
  ColComboDesc = 2;
begin
  Combo.DropDownRows          := 10;
  Combo.DropDownCols          := 2;
  Combo.Grid.Rows             := glConst.Max_Divisions;
  Combo.Grid.Cols             := 2;
  Combo.Grid.Width            := tgDivisions.Col[ ColDesc].Width;
  Combo.Grid.Font.Size        := 8;
  Combo.Grid.Col[ ColComboID].Width      := 30;
  Combo.Grid.Col[ ColComboDesc].Width    := tgDivisions.Col[ ColDesc].Width - Combo.Grid.Col[ ColComboID].Width;
  Combo.Grid.ValueCol         := 2;
  Combo.Grid.ValueColSorted   := False;
  Combo.Grid.AutoSearch       := asCenter;
  Combo.Grid.DefaultRowHeight := 16;
  Combo.Grid.AutoFill         := False;
  Combo.Grid.OnCellLoaded     := DivisionLookupCellLoaded;
  Combo.Grid.GridLines        := glNone;
  Combo.Grid.SelectionType    := sltColor;
end;

procedure TdlgEditAccount.tgDivisionsCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
var
  DivNo : integer;
begin
  DivNo := DivisionData[ DataRow -1].DivisionNo;
  Value := '';

  if ( DivNo in [1..Max_Divisions]) then begin
    case DataCol of
      ColID   : value := inttostr( DivNo);
      ColDesc : value := DivisionNames[ DivNo - 1].DivisionName;
    end;
  end;
end;

procedure TdlgEditAccount.DivisionLookupCellLoaded(Sender: TObject;
  DataCol, DataRow: Integer; var Value: Variant);
begin
  if DataRow in [1..Max_Divisions] then begin
    case DataCol of
      ColID   : value := inttostr( DivisionNames[DataRow - 1].DivisionNo);
      ColDesc : value := DivisionNames[DataRow - 1].DivisionName;
    end;
  end;
end;

procedure TdlgEditAccount.tgDivisionsEndCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
var
  sValue : string;
  iValue : integer;
begin
  sValue := tgDivisions.CurrentCell.Value;

  //occurs when editing of cell complete
  case DataCol of
    ColID : begin
      //make sure is a valid division no
      iValue := StrToIntDef( sValue, 0);
      if iValue in [ 0,1..Max_Divisions] then begin
        DivisionData[ DataRow -1].DivisionNo := iValue;
        //refresh the row
        tgDivisions.RowInvalidate( tgDivisions.DisplayRownr[ tgDivisions.CurrentDataRow]);
      end
      else begin
        Cancel := true;
        ErrorSound;
      end;
    end;
  end;
end;

procedure TdlgEditAccount.tgDivisionsComboGetValue(Sender: TObject;
  Combo: TtsComboGrid; GridDataCol, GridDataRow, ComboDataRow: Integer;
  var Value: Variant);
var
  iValue : integer;
begin
  //set the id value here
  iValue := ComboDataRow;
  if iValue in [ 0,1..Max_Divisions] then begin
    DivisionData[ GridDataRow -1].DivisionNo := iValue;
    //refresh the row
    tgDivisions.RowInvalidate( tgDivisions.DisplayRownr[ tgDivisions.CurrentDataRow]);
  end;
end;

{ TODO 3 : Force cursor to go down automatically, not across }

procedure TdlgEditAccount.sbtnChart1Click(Sender: TObject);
//show picklist of accounts, only show relevant accounts types
var
  s : string;
  AccountSelected : boolean;
  aType : integer;
  HasChartBeenRefreshed : Boolean;
begin
  s := edtLinkedAccount1.text;

  aType := GetCurrentlySelectedGroup;
  case aType of
    atOpeningStock : AccountSelected := PickAccount( S, HasChartBeenRefreshed, ClosingStockFilter, False);
    atClosingStock : AccountSelected := PickAccount( S, HasChartBeenRefreshed, OpeningStockFilter, False);
    atStockOnHand  : AccountSelected := PickAccount( S, HasChartBeenRefreshed, OpeningStockFilter, False);
    else
      AccountSelected := False;
  end;

  if AccountSelected then
    edtLinkedAccount1.text := s;

  edtLinkedAccount1.Refresh;
end;

procedure TdlgEditAccount.sbtnChart2Click(Sender: TObject);
//show picklist of accounts, only show relevant accounts types
var
  s : string;
  AccountSelected : boolean;
  aType : integer;
  HasChartBeenRefreshed : boolean;
begin
  s := edtLinkedAccount2.text;

  aType := GetCurrentlySelectedGroup;
  case aType of
    atStockOnHand  : AccountSelected := PickAccount( S, HasChartBeenRefreshed, ClosingStockFilter, False);
    else
      AccountSelected := False;
  end;

  if AccountSelected then
    edtLinkedAccount2.text := s;

  edtLinkedAccount2.Refresh;
end;

end.
