unit EditBankDlg;
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
  StdCtrls,
  Buttons,
  OvcBase,
  OvcEF,
  OvcPB,
  OvcNF,
  baObj32,
  OvcPF,
  Mask,
  ExtCtrls,
  ComCtrls,
  OsFont,
  VirtualTrees,
  CheckLst,
  BankLinkOnlineServices;

type
  //Node data record
  PTreeData = ^TTreeData;
  TTreeData = record
    tdCaption: widestring;
    tdObject: TObject;
  end;

  TdlgEditBank = class(TForm)
    OvcController1: TOvcController;
    PageControl1: TPageControl;
    tbDetails: TTabSheet;
    lblNo: TLabel;
    eNumber: TEdit;
    eName: TEdit;
    Label1: TLabel;
    pnlContra: TPanel;
    Label2: TLabel;
    sbtnChart: TSpeedButton;
    lblContraDesc: TLabel;
    eContra: TEdit;
    pnlBankOnly: TPanel;
    lblBank: TLabel;
    sbCalc: TSpeedButton;
    chkMaster: TCheckBox;
    nBalance: TOvcNumericField;
    cmbBalance: TComboBox;
    tbAnalysis: TTabSheet;
    Label8: TLabel;
    rbAnalysisEnabled: TRadioButton;
    rbRestricted: TRadioButton;
    rbVeryRestricted: TRadioButton;
    rbDisabled: TRadioButton;
    gCalc: TPanel;
    lblPeriod: TLabel;
    Label7: TLabel;
    nCalculated: TOvcNumericField;
    lblSign: TLabel;
    btnUpdate: TButton;
    Bevel1: TBevel;
    btnCalc: TButton;
    eDateFrom: TOvcPictureField;
    Label6: TLabel;
    cmbSign: TComboBox;
    nCalcBal: TOvcNumericField;
    Label4: TLabel;
    pnlFooter: TPanel;
    btnAdvanced: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    stNumber: TLabel;
    pnlManual: TPanel;
    lblType: TLabel;
    cmbType: TComboBox;
    eInst: TEdit;
    lblInst: TLabel;
    chkPrivacy: TCheckBox;
    lblClause: TLabel;
    lblM: TLabel;
    btnLedgerID: TButton;
    lblLedgerID: TLabel;
    lblCurrency: TLabel;
    cmbCurrency: TComboBox;
    tbBankLinkOnline: TTabSheet;
    lblSelectExport: TLabel;
    lblExportTo: TLabel;
    chkLstAccVendors: TCheckListBox;

    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure sbtnChartClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure sbCalcClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure eDateFromError(Sender: TObject; ErrorCode: Word;
      ErrorMsg: String);
    procedure btnCalcClick(Sender: TObject);
    procedure nCalcBalKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure nBalanceKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure nBalanceChange(Sender: TObject);
    procedure eContraChange(Sender: TObject);
    procedure eContraKeyPress(Sender: TObject; var Key: Char);
    procedure eContraKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnAdvancedClick(Sender: TObject);
    procedure eContraExit(Sender: TObject);
    procedure eNumberExit(Sender: TObject);
    procedure btnLedgerIDClick(Sender: TObject);
  private
    { Private declarations }
    AutoUpdate : boolean;
    BankAcct : TBank_Account;
    okPressed : boolean;
    RemovingMask : boolean;
    FAddNew: Boolean;
    LastTrxDate,
    FirstTrxDate : integer;
    LedgerCode: shortString;
    fExportDataEnabled : Boolean;
    fAccountVendors : TAccountVendors;
    fClientId : TBloGuid;
    fVendorDirty : Boolean;

    procedure SetAddNew(Value: Boolean);
    procedure DoList;
    function OKtoPost : boolean;
    procedure SetLedgerLabel;
    procedure FillCurrencies;
    procedure LoadAcccountVendors;
    function SaveAccountVendors : Boolean;
    function IsGuidInCurrentVendors(aGuid : TBloGuid) : boolean;
    function HaveVendorExportsChanged(out aMessage : string) : Boolean;
    procedure UpdateAccountVendorInfo;
    function AccountHasNoTicks(out aMessage : string) : Boolean;
    function GetVendorIndex(aGuid : TBloGuid) : integer;
  public
    { Public declarations }
    function Execute : boolean;
    property AddNew: Boolean write SetAddNew;
    property ExportDataEnabled : Boolean read fExportDataEnabled write fExportDataEnabled;
    property AccountVendors : TAccountVendors read fAccountVendors write fAccountVendors;
    property ClientId : TBloGuid read fClientId write fClientId;
  end;

{$IFDEF SmartBooks}
  function AddBankAccount : Boolean;
{$ENDIF}

  function EditBankAccount(aBankAcct : TBank_Account;
                           var aAccountVendors : TAccountVendors;
                           aClientId : TBloGuid;
                           IsNew: Boolean = False) : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.DFM}

uses
  ClassSuperIP,
  ForexHelpers,
  AccountLookupFrm,
  admin32,
  BKHelp,
  imagesFrm,
  bkDateUtils,
  GenUtils,
  bkMaskUtils,
  moneyDef,
  globals,
  selectDate,
  WarningMoreFrm,
  Software,
  bkConst,
  bkDefs,
  stdHints,
  ISO_4217,
  ComboUtils,
  AdvanceAccountOptionsFrm,
  pwdSeed,
  EnterPwdDlg,
  chList32,
  bkXPThemes,
  baUtils,
  YesNoDlg,
  OkCancelDlg,
  DesktopSuper_Utils;

const
  GMargin = 10;
  BAL_INFUNDS = 0;
  BAL_OVERDRAWN = 1;
  BAL_UNKNOWN = 2;

//------------------------------------------------------------------------------
procedure TdlgEditBank.SetAddNew(Value: Boolean);
begin
  if Value then
    Caption := 'Add Manual Bank Account'
  else
    Caption := 'Edit Bank Account Details';
  FAddNew := Value;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.DoList;
var s : string;
begin
   s := eContra.text;
   if PickAccount(s) then eContra.text := s;
   eContra.Refresh;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.FillCurrencies;
var
  Cursor: TCursor;
  i: Integer;
begin
  Cursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  cmbCurrency.Items.BeginUpdate;
  try
    cmbCurrency.Clear;
    if Assigned(AdminSystem) then begin
      AdminSystem.SyncCurrenciesToSystemAccounts;
      for i := low(AdminSystem.fCurrencyList.ehISO_Codes) to high(AdminSystem.fCurrencyList.ehISO_Codes) do
        if AdminSystem.fCurrencyList.ehISO_Codes[i] > '' then
          cmbCurrency.Items.Add(AdminSystem.fCurrencyList.ehISO_Codes[i]);
    end else begin
      for i := low(MyClient.ExchangeSource.Header.ehISO_Codes) to high(MyClient.ExchangeSource.Header.ehISO_Codes) do
        if MyClient.ExchangeSource.Header.ehISO_Codes[i] > '' then
          cmbCurrency.Items.Add(MyClient.ExchangeSource.Header.ehISO_Codes[i]);
        //Must have the base currency
        if cmbCurrency.Items.Count = 0 then
          cmbCurrency.Items.Add(MyClient.clExtra.ceLocal_Currency_Code);
    end;
  finally
    cmbCurrency.Items.EndUpdate;
    Screen.Cursor := Cursor;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  bkXPThemes.ThemeForm( Self);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,sbtnChart.Glyph);

  left := (Screen.WorkAreawidth - width) div 2;
  top  := (Screen.WorkAreaHeight - Height) div 2;
  lblClause.Font.Name := font.Name;
  
  gCalc.Visible := false;
  lblContraDesc.Caption := '';
  FAddNew := False;

  cmbType.Clear;
  case MyClient.clFields.clCountry of
    //No manual superfund accounts for NZ or UK.
    whNewZealand, whUK: for i := mtMin to mtOther do
                          cmbType.Items.AddObject(mtNames[i], TObject(i));
    whAustralia:        for i := mtMin to mtMax do
                          cmbType.Items.AddObject(mtNames[i], TObject(i));
  end;
  cmbType.ItemIndex := -1;

  eDateFrom.PictureMask := BKDATEFORMAT;
  eDateFrom.Epoch       := BKDATEEPOCH;
  eContra.MaxLength     := MaxBk5CodeLen;
  removingMask          := false;

  cmbSign.itemIndex := BAL_INFUNDS;

  FillCurrencies;

  SetUpHelp;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   eNumber.Hint     :=
                    'Enter the Bank Account Number|' +
                    'Enter the Bank Account Number';
   cmbCurrency.Hint :=
                    'Select the currency for this Bank Account|' +
                    'Select the currency for this Bank Account';
   eName.Hint       :=
                    'Edit the Bank Account name if necessary|' +
                    'Edit the Bank Account name if necessary or use the default name downloaded with the transactions';
   eContra.Hint     :=
                    'Enter the Contra Account Code to use for this Bank Account|' +
                    'Enter the Contra Account Code from the Chart of Accounts which corresponds to this Bank Account';

   sbtnChart.Hint   :=
                    STDHINTS.ChartLookupHint;

   chkMaster.Hint   :=
                    'Allow Master Memorised Entries for this Bank Account|' +
                    'Allow Master Memorised Entries to be automatically applied to this the Bank Account';
   nBalance.Hint    :=
                    'Enter the Current Balance as at the date of the last transaction received|' +
                    'Enter the Current Balance for this Bank Account as at the date of the last transaction received';
   cmbBalance.Hint  :=
                    'Select whether the account is In-Funds or Overdrawn|' +
                    'Select whether the account is In-Funds or Overdrawn';

   nCalcBal.Hint    :=
                    'Enter the Account Balance as at the date specified|' +
                    'Enter the Account Balance as at the beginning of the day on the date specified';
   cmbSign.Hint     :=
                    'Select whether the account is In Funds (IF) or Overdrawn (OD)|' +
                    'Select whether the account is In Funds (IF) or Overdrawn (OD)';
   eDateFrom.Hint   :=
                    'Enter the date for the specified Account Balance|' +
                    'Enter the date for the specified Account Balance';
   btnCalc.Hint     :=
                    'Calculate the Current Balance for this Account|' +
                    'Calculate the Current Balance for this Account';
   btnUpdate.Hint   :=
                    'Update the Current Balance with new Calculated Current Balance|' +
                    'Update the Current Balance for this Account with the new Calculated Current Balance';

   sbCalc.Hint      :=
                    'Show the Current Balance worksheet|'+
                    'Drop down the Current Balance worksheet to allow you to enter a balance at a specified date';

   eInst.Hint     :=
                    'Enter the Institution|' +
                    'Enter the Institution';
   cmbType.Hint     :=
                    'Choose the Account Type|' +
                    'Choose the Account Type';
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.UpdateAccountVendorInfo;
var
  VendorIndex : integer;
  VendorCount : integer;
  Current : TBloArrayOfDataPlatformSubscriber;
begin
  for VendorIndex := 0 to high(fAccountVendors.AccountVendors.Current) do
    FreeAndNil(fAccountVendors.AccountVendors.Current[VendorIndex]);

  VendorCount := 0;
  for VendorIndex := 0 to chkLstAccVendors.Items.Count-1 do
  begin
    if chkLstAccVendors.Checked[VendorIndex] then
      inc(VendorCount);
  end;

  SetLength(Current, VendorCount);
  fAccountVendors.AccountVendors.Current := Current;

  for VendorIndex := 0 to VendorCount-1 do
  begin
    fAccountVendors.AccountVendors.Current[VendorIndex] := TBloDataPlatformSubscriber.Create;
    fAccountVendors.AccountVendors.Current[VendorIndex].Id :=
      TBloDataPlatformSubscriber(chkLstAccVendors.Items.Objects[VendorIndex]).Id;
    fAccountVendors.AccountVendors.Current[VendorIndex].Name_ :=
      TBloDataPlatformSubscriber(chkLstAccVendors.Items.Objects[VendorIndex]).Name_;
  end;

  {fAccountVendors.AccountVendors :=
        ProductConfigService.GetAccountVendors(ClientID,
                                               AccountVendors.AccountNumber);}
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.sbtnChartClick(Sender: TObject);
begin
  DoList;
  eContra.setFocus;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 113) or ((key=40) and (Shift = [ssAlt])) then
     DoList;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.LoadAcccountVendors;
var
  ItemIndex : Integer;
  AccAvailableIndex : integer;
  AccCurrentIndex : integer;
  VendorName : String;
begin
  for AccAvailableIndex := 0 to high(AccountVendors.AccountVendors.Available) do
  begin
    VendorName := AccountVendors.AccountVendors.Available[AccAvailableIndex].Name_;
    ItemIndex := chkLstAccVendors.Items.AddObject(VendorName, AccountVendors.AccountVendors.Available[AccAvailableIndex]);

    for AccCurrentIndex := 0 to high(AccountVendors.AccountVendors.Current) do
    begin
      if AccountVendors.AccountVendors.Available[AccAvailableIndex].id =
         AccountVendors.AccountVendors.Current[AccCurrentIndex].id then
      begin
        chkLstAccVendors.Checked[ItemIndex] := true;
        break;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TdlgEditBank.SaveAccountVendors: Boolean;
var
  ItemIndex : integer;
  VendorID : TBloGuid;
  VendorCount : integer;
  CurrentVendors : TBloArrayOfGuid;
begin
  VendorCount := 0;
  SetLength(CurrentVendors, VendorCount);

  for ItemIndex := 0 to chkLstAccVendors.Items.Count-1 do
  begin
    if chkLstAccVendors.Checked[ItemIndex] = true then
    begin
      inc(VendorCount);
      SetLength(CurrentVendors, VendorCount);

      CurrentVendors[VendorCount-1] :=
        TBloDataPlatformSubscriber(chkLstAccVendors.Items.Objects[ItemIndex]).Id;
    end;
  end;

  Result := ProductConfigService.SaveAccountVendorExports(ClientID,
                                                          AccountVendors.AccountNumber,
                                                          CurrentVendors,
                                                          True);
  if Result then
    UpdateAccountVendorInfo;
end;

//------------------------------------------------------------------------------
function TdlgEditBank.IsGuidInCurrentVendors(aGuid : TBloGuid) : boolean;
var
  AccCurrentIndex : integer;
begin
  Result := False;

  if not ExportDataEnabled then
    Exit;

  for AccCurrentIndex := 0 to high(AccountVendors.AccountVendors.Current) do
  begin
    if aGuid = AccountVendors.AccountVendors.Current[AccCurrentIndex].id then
    begin
      Result := true;
      break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TdlgEditBank.GetVendorIndex(aGuid : TBloGuid) : integer;
var
  VendorIndex : integer;
begin
  Result := -1;

  for VendorIndex := 0 to high(AccountVendors.AccountVendors.Available) do
  begin
    if aGuid = AccountVendors.AccountVendors.Available[VendorIndex].id then
    begin
      Result := VendorIndex;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TdlgEditBank.HaveVendorExportsChanged(out aMessage : string) : Boolean;
var
  VendorIndex : integer;
  VendorId : TBloGuid;
begin
  Result := False;
  aMessage := 'You have updated the Export To options for the following for bank account ''' + AccountVendors.AccountNumber + '''' + #10#10;
  for VendorIndex := 0 to chkLstAccVendors.Items.Count-1 do
  begin
    VendorId := TBloDataPlatformSubscriber(chkLstAccVendors.Items.Objects[VendorIndex]).Id;

    if chkLstAccVendors.Checked[VendorIndex] <> IsGuidInCurrentVendors(VendorId) then
    begin
      Result := True;
      if chkLstAccVendors.Checked[VendorIndex] then
        aMessage := aMessage + 'Enabled '
      else
        aMessage := aMessage + 'Disabled ';

      aMessage := aMessage + 'the export to BankLink Online for ' +
                  chkLstAccVendors.Items.Strings[VendorIndex] + #10;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TdlgEditBank.AccountHasNoTicks(out aMessage : string) : Boolean;
var
  VIndex : integer;
  VendorIndex : integer;
  VendorId : TBloGuid;
  VendorNames : string;
begin
  Result := false;
  VendorNames := '';
  aMessage := '';

  for VIndex := 0 to chkLstAccVendors.Items.Count-1 do
  begin
    VendorId := TBloDataPlatformSubscriber(chkLstAccVendors.Items.Objects[VIndex]).Id;
    VendorIndex := GetVendorIndex(VendorId);

    if (chkLstAccVendors.Checked[VIndex] = False)
       (AccountVendors.IsLastAccForVendors[VendorIndex])  then
    begin
      if Length(VendorNames) > 0 then
        VendorNames := VendorNames + ', ';
      
      VendorNames := VendorNames + AccountVendors.AccountVendors.Available[VendorIndex].Name_;
    end;
  end;

  if Length(VendorNames) > 0 then
  begin
    aMessage := 'Client ' + MyClient.clFields.clCode + ' no longer has any bank accounts using ' + VendorNames + '.' + #10 +
                'Would you like BankLink Practice to remove ' + VendorNames + ' for this client?';
    Result := True;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.btnCancelClick(Sender: TObject);
begin
  okPressed := false;
  close;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.btnLedgerIDClick(Sender: TObject);
begin
  case MyClient.clFields.clAccounting_System_Used of
  saDesktopSuper :  LedgerCode := IntToStr(DesktopSuper_Utils.SetLedger(strToIntdef( LedgerCode, -1)));
  saClassSuperIP :  LedgerCode := ClassSuperIP.SetLedger(LedgerCode);
  end;

  SetLedgerLabel;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.btnOKClick(Sender: TObject);
begin
  eNumberExit(eNumber);
  eNumberExit(eName);
  eNumberExit(eInst);
  if okToPost then
  begin
    if (ExportDataEnabled) and
      (fVendorDirty) then
    begin
      try
        if not SaveAccountVendors then
          Exit;
      finally
        fVendorDirty := false;
      end;
    end;

    okPressed := true;
    Close;
  end;
end;

//------------------------------------------------------------------------------
function TdlgEditBank.OKtoPost: boolean;
var
  AccName : string;
  i: Integer;
  BA: TBank_Account;
  PromptMessage : String;
begin
  result := false;

{$IFDEF SmartBooks}
  if ( eNumber.Visible ) and ( eNumber.Text = '' ) then begin
     HelpfulWarningMsg('Account Number is empty. Please Enter one now.',0);
     eNumber.SetFocus;
     Exit;
  end;
{$ENDIF}

  if BankAcct.IsManual then // type and institution are mandatory
  begin
    for i := MyClient.clBank_Account_List.First to MyClient.clBank_Account_List.Last do
    begin
      if (Uppercase(MyClient.clBank_Account_List.Bank_Account_At(i).baFields.baBank_Account_Number) = Uppercase(lblM.Caption + eNumber.Text))
      and (MyClient.clBank_Account_List.Bank_Account_At(i) <> BankAcct) then
      begin
        HelpfulWarningMsg('Account Number already exists for a bank account in this client file.',0);
        PageControl1.ActivePage := tbDetails;
        eNumber.SetFocus;
        Exit;
      end;
    end;
    if Trim(eNumber.Text) = '' then
    begin
      HelpfulWarningMsg('Account Number is empty. Please enter one now.',0);
      PageControl1.ActivePage := tbDetails;
      eNumber.SetFocus;
      Exit;
    end;
    if Trim(eInst.Text) = '' then
    begin
      HelpfulWarningMsg('Institution is empty. Please enter one now.',0);
      PageControl1.ActivePage := tbDetails;
      eInst.SetFocus;
      Exit;
    end;
    if cmbType.ItemIndex = -1 then
    begin
      HelpfulWarningMsg('Account Type is empty. Please choose one now.',0);
      PageControl1.ActivePage := tbDetails;
      cmbType.SetFocus;
      Exit;
    end;
  end;

  if ContraCodeRequired(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used)
     and (eContra.Text='')
     and (BankAcct.baFields.baAccount_Type = btBank) then
  begin
     AccName := MyClient.clAccountingSystemName;
     HelpfulWarningMsg('A Contra Account code is required by '+AccName+' for this Bank Account. Please Enter one now.',0);
     PageControl1.ActivePage := tbDetails;
     eContra.SetFocus;
     exit;
  end;

  //Contra code can only be used for bank accounts with the same currency
  if (eContra.Text <> '') then begin
    for i := 0 to Pred(MyClient.clBank_Account_List.ItemCount) do begin
      BA := MyClient.clBank_Account_List.Bank_Account_At(i);
      if Assigned(BA) then begin
        if (eContra.Text = BA.baFields.baContra_Account_Code) and
           (BA.baFields.baCurrency_Code <> BankAcct.baFields.baCurrency_Code) then begin
          HelpfulWarningMsg('The Contra Account you have entered cannot be used because ' +
                            'it is already assigned to a bank account with a different currency. ' +
                            'Please choose a different code for the Contra Account.',0);
          PageControl1.ActivePage := tbDetails;
          eContra.SetFocus;
          Exit;
        end;
      end;
    end;
  end;

  if ExportDataEnabled then
  begin
    fVendorDirty := HaveVendorExportsChanged(PromptMessage);
    if fVendorDirty then
    begin
      if AskOkCancel('Export Options Updated', PromptMessage, DLG_OK, 0) <> DLG_OK then
      begin
        fVendorDirty := false;
        Exit;
      end;
    end;

    if (fVendorDirty) and
       (AccountHasNoTicks(PromptMessage)) then
    begin

    end;
  end;

  result := true;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.sbCalcClick(Sender: TObject);
begin
  if gCalc.visible then
  begin
//    Height := Height - (gCalc.Height + GMargin);
    gCalc.Visible := false;
    nBalance.setFocus;
  end
  else
  begin
//    Height := Height + (gCalc.Height + GMargin);
    gCalc.Visible := true;
    nCalcBal.SetFocus;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.btnUpdateClick(Sender: TObject);
begin
   nBalance.AsFloat := nCalculated.asFloat;
   if (lblSign.caption = 'IF') then cmbBalance.itemIndex := BAL_INFUNDS
     else
      cmbBalance.itemIndex := BAL_OVERDRAWN;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.eDateFromError(Sender: TObject; ErrorCode: Word;
  ErrorMsg: String);
begin
  ShowDateError(Sender);
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.btnCalcClick(Sender: TObject);
//need to calculate the balance from a given date - just run through all trans adding up
var
   FromDate : integer;
   Amt      : Money;
   i : integer;
   Total : Money;
   Trans : pTransaction_Rec;
begin
   FromDate := eDateFrom.AsStDate;

   //Verify Date
   if FromDate = -1 then exit;

   if (FromDate > LastTrxDate) then begin
     HelpfulWarningMsg('This date is after the date of the last transaction received for this account ('+ bkDate2Str(LastTrxDate)+').  The balance cannot be calculated past this date.',0);
     exit;
   end;

   if (FromDate < FirstTrxDate) then begin
     HelpfulWarningMsg('This date is before the date of the first transaction received for this account ('+ bkDate2Str(FirstTrxDate)+').  The balance cannot be calculated before this date.',0);
     exit;
   end;

   //Get Money
   Amt := Double2Money(nCalcBal.asFloat);

   if cmbSign.itemIndex = BAL_INFUNDS then
      Amt := -Amt;


   {add transactions greater than then from date to the balance given}
   Total := 0;
   for i := 0 to (BankAcct.baTransaction_List.ItemCount -1) do
   begin
     Trans := BankAcct.baTransaction_List.Transaction_At(i);
     if (Trans.txDate_Presented >= FromDate) then
       Total := Total + Trans.Statement_Amount;
   end;

   Amt := Amt + Total;
   if Amt > 0 then lblSign.caption := 'OD' else
    lblSign.caption := 'IF';

   nCalculated.AsFloat := Abs(Money2Double(Amt));
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.nCalcBalKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_subtract) or (key = 189) then key := 0;  {ignore minus key}
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.nBalanceKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_subtract) or (key = 189) then key := 0;  {ignore minus key}
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.nBalanceChange(Sender: TObject);
begin
  if (cmbBalance.ItemIndex = BAL_UNKNOWN) and (nBalance.asFloat <> 0) then
    cmbBalance.ItemIndex := BAL_INFUNDS;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.eContraChange(Sender: TObject);
var
  pAcct   : pAccount_Rec;
  S       : string;
  IsValid : boolean;
begin
  if MyClient.clChart.ItemCount = 0 then
    Exit;

  s       := Trim( eContra.Text);
  pAcct   := MyClient.clChart.FindCode( S);
  IsValid := Assigned( pAcct) and
             (pAcct^.chAccount_Type = atBankAccount) and
             pAcct^.chPosting_Allowed;

  if Assigned( pAcct) then
    lblContraDesc.Caption := pAcct^.chAccount_Description
  else
    lblContraDesc.Caption := '';

  if (S = '') or ( IsValid) then begin
    eContra.Font.Color := clWindowText;
    eContra.Color      := clWindow;
    S := eContra.Text;
    eContra.BorderStyle := bsNone;
    eContra.BorderStyle := bsSingle;
    eContra.Text := S;
  end
  else begin
    eContra.Font.Color := clWhite;
    eContra.Color      := clRed;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.eContraKeyPress(Sender: TObject; var Key: Char);
begin
  if ((key='-') and (myClient.clFields.clUse_Minus_As_Lookup_Key)) then
  begin
    key := #0;
    PickCodeForEdit(Sender);
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.eContraKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 113) or ((key=40) and (Shift = [ssAlt])) then
     PickCodeForEdit(Sender)
  else if ( Key = VK_BACK ) then
    bkMaskUtils.CheckRemoveMaskChar(eContra,RemovingMask)
  else
    bkMaskUtils.CheckForMaskChar(eContra,RemovingMask);

end;

//------------------------------------------------------------------------------
function TdlgEditBank.Execute: boolean;
var
  Amount : money;
  begin
  result := false;
  okPressed := false;
  fVendorDirty := false;

  if not Assigned(BankAcct) then exit;
  AutoUpdate := false;

  {load values}
  stNumber.Caption := BankAcct.baFields.baBank_Account_Number;
  eName.Text := BankAcct.baFields.baBank_Account_Name;
  eContra.Text := BankAcct.baFields.baContra_Account_Code;

  chkMaster.Checked := BankAcct.baFields.baApply_Master_Memorised_Entries;
  chkMaster.Enabled := MyClient.clFields.clDownload_From = dlAdminSystem;
  chkMaster.Visible := not BankAcct.IsManual;

  btnAdvanced.Visible := ( BankAcct.IsManual)
                         and( Assigned(AdminSystem) and CurrUser.CanAccessAdmin)
                         and((PRACINI_AllowAdvanceOptions) or SuperUserLoggedIn);

  if FAddNew
  or (not BankAcct.IsManual) then
  begin
    cmbType.ItemIndex := -1;
    eInst.Text := '';
  end
  else
  begin
    eInst.Text := BankAcct.baFields.baManual_Account_Institution;
    cmbType.ItemIndex := BankAcct.baFields.baManual_Account_Type;
  end;
  eNumber.Visible := BankAcct.IsManual;
  if eNumber.Visible then
    lblNo.Caption := 'A&ccount No'
  else
    lblNo.Caption := 'Account No';
  stNumber.Visible := not eNumber.Visible;
  if (Pos(lblM.Caption, BankAcct.baFields.baBank_Account_Number) = 1) then
  begin
    if Length(BankAcct.baFields.baBank_Account_Number) = 1 then
      eNumber.Text := ''
   else
      eNumber.Text := Copy(BankAcct.baFields.baBank_Account_Number, 2, Length(BankAcct.baFields.baBank_Account_Number));
  end
  else
    eNumber.Text := BankAcct.baFields.baBank_Account_Number;

  //Set currency
  lblCurrency.Visible := (BankAcct.IsManual)
                     and (MyClient.clFields.clCountry = whUK);

  cmbCurrency.Visible := lblCurrency.Visible;
  cmbCurrency.Enabled := cmbCurrency.Visible and FAddNew;
  if cmbCurrency.Items.IndexOf(BankAcct.baFields.baCurrency_Code) <> -1 then
    cmbCurrency.ItemIndex := cmbCurrency.Items.IndexOf(BankAcct.baFields.baCurrency_Code);

  if BankAcct.IsAJournalAccount then
  begin
    pnlBankOnly.visible := false;
    self.Height := self.Height - pnlBankOnly.Height;
    self.top    := (Screen.WorkAreaHeight - Self.Height) div 2;
    self.caption := 'Edit Journal Account Details';
  end;
  if not BankAcct.IsManual then
  begin
    eInst.Text := '';
    cmbType.ItemIndex := -1;
    pnlManual.Visible := False;
    lblClause.Visible := False;
    lblM.Visible := False;
    Self.Height := Self.Height - pnlManual.Height;
    gCalc.Top := gCalc.Top - pnlManual.Height;
    btnLedgerID.Top := btnLedgerID.Top - pnlManual.Height;
    lblLedgerID.Top := lblLedgerID.Top - pnlManual.Height;
  end
  else
    eNumber.MaxLength := 19;

  LastTrxDate := BankAcct.baTransaction_List.LastPresDate;
  FirstTrxDate := BankAcct.baTransaction_List.FirstPresDate;
  if LastTrxDate = 0 then
  begin
    lblBank.Top := lblBank.Top + 5;
    lblBank.caption := 'Current &Balance';
  end
  else
    lblBank.caption := 'Current &Balance as at '+ bkDate2Str(LastTrxDate);

  if FirstTrxDate = 0 then
    lblperiod.caption := 'There are no transactions in this account'
  else
    lblperiod.caption := 'Transactions from '+ bkDate2Str(FirstTrxDate)+ ' to '+bkDate2Str(LastTrxDate);

  if (BankAcct.baFields.baCurrent_balance = UNKNOWN) then
  begin
    nBalance.AsFloat := 0;
    cmbBalance.ItemIndex := BAL_UNKNOWN;
  end
  else
  begin
    Amount := Abs(BankAcct.baFields.baCurrent_balance);
    nBalance.AsFloat := Money2Double(Amount);

    if (BankAcct.baFields.baCurrent_Balance > 0) then
      cmbBalance.ItemIndex := BAL_OVERDRAWN
    else
      cmbBalance.ItemIndex := BAL_INFUNDS;
  end;

  //show analysis coding settings if relevant
  tbAnalysis.TabVisible := (MyClient.clFields.clCountry = whNewZealand) and ( BankAcct.baFields.baAccount_Type = btBank);
  rbAnalysisEnabled.Checked := False;
  rbRestricted.checked := False;
  rbVeryRestricted.checked := False;
  rbDisabled.checked := False;

  case BankAcct.baFields.baAnalysis_Coding_Level of
    acRestrictedLevel1 : rbRestricted.checked := true;
    acRestrictedLevel2 : rbVeryRestricted.checked := true;
    acDisabled : rbDisabled.checked := true;
  else
    rbAnalysisEnabled.Checked := true;
  end;

  if Software.HasSuperfundLegerID(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used) then
  begin
    LedgerCode := IntToStr(BankAcct.baFields.baDesktop_Super_Ledger_ID);
    btnLedgerID.Visible := True;
    lblLedgerID.Visible := True;
    SetLedgerLabel;
  end
  else
  if Software.HasSuperfundLegerCode(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used) then
  begin
    LedgerCode := BankAcct.baFields.baSuperFund_Ledger_Code;
    btnLedgerID.Visible := True;
    lblLedgerID.Visible := True;
    SetLedgerLabel;
  end
  else
  begin
    LedgerCode := '';
    btnLedgerID.Visible := False;
    lblLedgerID.Visible := False;
  end;

  tbBankLinkOnline.TabVisible := ExportDataEnabled;

  if ExportDataEnabled then
    LoadAcccountVendors;

  ///////////////////////
  ShowModal;
  ///////////////////////

  if okPressed then
  begin

     {save values}
    if BankAcct.IsManual then
    begin
      BankAcct.baFields.baBank_Account_Number := lblM.Caption + eNumber.Text;
      if FAddNew then
      begin
        if chkPrivacy.Checked then
        begin
          if Assigned(AdminSystem) then
          begin
            if LoadAdminSystem(true, 'TdlgEditBank.Execute' ) then
            begin
              AdminSystem.fdFields.fdManual_Account_XML := AdminSystem.fdFields.fdManual_Account_XML +
              MakeManualXMLString(mtNames[cmbType.ItemIndex], eInst.Text);
              SaveAdminSystem;
            end;
          end;
          BankAcct.baFields.baManual_Account_Sent_To_Admin := Assigned(AdminSystem);
        end
        else
          BankAcct.baFields.baManual_Account_Sent_To_Admin := True;
      end;
    end;
    BankAcct.baFields.baCurrency_Code := cmbCurrency.Items[cmbCurrency.ItemIndex];
    BankAcct.baFields.baBank_Account_Name := eName.Text;
    BankAcct.baFields.baContra_Account_Code := eContra.Text;
    BankAcct.baFields.baApply_Master_Memorised_Entries := chkMaster.Checked;
    BankAcct.baFields.baManual_Account_Institution := eInst.Text;
    BankAcct.baFields.baManual_Account_Type := cmbType.ItemIndex;

    if Software.HasSuperfundLegerID(MyClient.clFields.clCountry,MyClient.clFields.clAccounting_System_Used) then
    begin
      BankAcct.baFields.baDesktop_Super_Ledger_ID := StrToIntDef(LedgerCode, -1);
      BankAcct.baFields.baSuperFund_Ledger_Code := '';
    end
    else
    begin
      if Software.HasSuperfundLegerCode(MyClient.clFields.clCountry,MyClient.clFields.clAccounting_System_Used) then
      begin
        BankAcct.baFields.baSuperFund_Ledger_Code := LedgerCode;
        BankAcct.baFields.baDesktop_Super_Ledger_ID := -1;
      end
      else
      begin
        BankAcct.baFields.baDesktop_Super_Ledger_ID := -1;
        BankAcct.baFields.baSuperFund_Ledger_Code := '';
      end;
    end;

    Amount := Double2Money(nBalance.AsFloat);
    Amount := Abs(Amount);

    case cmbBalance.itemIndex of
      BAL_INFUNDS : Amount := -Amount;
      BAL_OVERDRAWN : ;
      BAL_UNKNOWN : Amount := UNKNOWN;
    end;

    if rbAnalysisEnabled.Checked then
      BankAcct.baFields.baAnalysis_Coding_Level := acEnabled
    else
      if rbRestricted.checked then
        BankAcct.baFields.baAnalysis_Coding_Level := acRestrictedLevel1
      else
        if rbVeryRestricted.checked then
          BankAcct.baFields.baAnalysis_Coding_Level := acRestrictedLevel2
        else
          BankAcct.baFields.baAnalysis_Coding_Level := acDisabled;

    BankAcct.baFields.baCurrent_Balance := Amount;
  end;
  result := okPressed;
end;

//------------------------------------------------------------------------------
function EditBankAccount(aBankAcct : TBank_Account;
                         var aAccountVendors : TAccountVendors;
                         aClientId : TBloGuid;
                         IsNew: Boolean = False) : boolean;
var
  MyDlg : tdlgEditBank;
begin
  MyDlg := tdlgEditBank.Create(Application.MainForm);
  try
    if aBankAcct.IsManual then
    begin
      if IsNew then
        BKHelpSetUp(MyDlg, BKH_Adding_manual_bank_accounts)
      else
        BKHelpSetUp(MyDlg, BKH_Editing_manual_bank_accounts_details);
    end
    else
      BKHelpSetUp(MyDlg, BKH_Edit_bank_account_details);
    MyDlg.BankAcct := aBankAcct;
    MyDlg.AddNew := IsNew;
    MyDlg.ExportDataEnabled := (ProductConfigService.OnLine and
                               ProductConfigService.IsPracticeProductEnabled(ProductConfigService.GetExportDataId, False)) and
                               (not aBankAcct.baFields.baIs_A_Manual_Account) and
                               (not (aBankAcct.baFields.baAccount_Type in [sbtProvisional]));

    if MyDlg.ExportDataEnabled then
    begin
      MyDlg.ClientId       := aClientId;
      MyDlg.AccountVendors := aAccountVendors;
    end;

    result := MyDlg.Execute;

    if (Result) and
       (MyDlg.ExportDataEnabled) then
      aAccountVendors := MyDlg.AccountVendors;
  finally
    MyDlg.Free;
  end;
end;

//------------------------------------------------------------------------------
{$IFDEF SmartBooks}
function AddBankAccount : Boolean;
//This function is used by SmartBooks to allow users to add new Bank Account
//and use HDE to add entries for this Account until EOY procedure is run.
var
  MyDlg : tdlgEditBank;
begin
   MyDlg := tdlgEditBank.Create(Application);
   try
      with MyDlg do begin
         eNumber.Visible  := true;
         stNumber.Visible := false;
         eNumber.Text     := '';
         eName.Text       := '';
         eContra.Text     := '';
         pnlManual.Visible := False;
         lblClause.Visible := False;
         eInst.Text := '';
         cmbType.ItemIndex := -1;
         Self.Height := Self.Height - pnlManual.Height;
         gCalc.Top := gCalc.Top = pnlManual.Height;

         nBalance.AsFloat := 0;
         cmbBalance.ItemIndex := BAL_UNKNOWN;

         BankAcct := TBank_Account.Create(MyClient);
         BankAcct.baFields.baBank_Account_Number := '';
         BankAcct.baFields.baBank_Account_Name   := '';
         BankAcct.baFields.baAccount_Type        := btBank;
         BankAcct.baFields.baDesktop_Super_Ledger_ID := -1;
         BankAcct.baFields.baCurrency_Code      := MyClient.clExtra.ceLocal_Currency_Code;

         result := Execute;
         if result then
           MyClient.clBank_Account_List.Insert( BankAcct );
      end;
   finally
      MyDlg.Free;
   end;
end;
{$ENDIF}

//------------------------------------------------------------------------------
procedure TdlgEditBank.btnAdvancedClick(Sender: TObject);
const
   ThisMethodName = 'AdvancedBankAccountOptions';
var
   AdvancedAccessPassword : string;
   rndSeed : integer;

begin
   if not RefreshAdmin then exit;

   //get password from passgen
   Randomize;
   RndSeed := Random(100000);
   AdvancedAccessPassword := PasswordFromSeed(RndSeed);

   if EnterPassword( 'Password Required', AdvancedAccessPassword, 0, true, true) then begin
      with TfrmAdvanceAccountOptions.Create(Self) do
      begin
        try
          chkEnhancedTempAccounts.Checked := AdminSystem.fdFields.fdEnhanced_Software_Options[ sfUnlimitedDateTempAccounts];
          ShowModal;
          if ( ModalResult = mrOK) then begin
            //update admin system
            if LoadAdminSystem(true, ThisMethodName ) then with AdminSystem.fdFields do begin
               AdminSystem.fdFields.fdEnhanced_Software_Options[ sfUnlimitedDateTempAccounts] := chkEnhancedTempAccounts.Checked;
               SaveAdminSystem;
            end
            else
               HelpfulWarningMsg('Could not update admin system at this time. Admin System unavailable.',0);
          end;
        finally
          Free;
        end;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.eContraExit(Sender: TObject);
begin
  if not MyClient.clChart.CodeIsThere(eContra.Text) then
    bkMaskUtils.CheckRemoveMaskChar(eContra,RemovingMask);
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.eNumberExit(Sender: TObject);
begin
  (Sender as TEdit).Text := Trim((Sender as TEdit).Text);
end;

//------------------------------------------------------------------------------
procedure TdlgEditBank.SetLedgerLabel;
var lDesc: string;
begin
   case MyClient.clFields.clAccounting_System_Used of
      saDesktopSuper : lDesc := DesktopSuper_Utils.GetLedgerName(StrToIntDef(LedgerCode, -1));
      saClassSuperIP : lDesc := ClassSuperIP.GetLedgerName(LedgerCode);
   end;
   if LDesc = '' then
      LDesc := '<none>';
   lblLedgerID.Caption := format('Selected Fund: %s',[LDesc]);
end;

end.
