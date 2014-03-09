unit PayeeDetailDlg;
//------------------------------------------------------------------------------
{
   Title:       Payee Dialog

   Description: Allows creation and editing of payee's

   Remarks:

   Author:

}
//------------------------------------------------------------------------------
interface

uses
  superfieldsUtils,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OvcTCmmn, OvcTCell, OvcTCStr, OvcTCHdr, OvcBase, OvcTable,
  bkdefs,baObj32, OvcTCEdt, OvcTCBEF, OvcTCNum, OvcTCCBx, ExtCtrls,
  OvcTCBmp, OvcTCGly, OvcEF, OvcPB, OvcNF, Buttons, OvcABtn, globals,
  OvcTCPic, BkConst, glConst, OvcTCSim, moneydef,
  PayeeObj, ComCtrls, Menus,
  OSFont, Mask, BKNumericEdit;                  

{----------------------------------------------------}
type

  TSplitArray = Array[1 .. GLCONST.Max_py_Lines ] of TmemSplitRec;

type
  TdlgPayeeDetail = class(TForm)
    Panel3: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    pnlTotalAmounts: TPanel;
    lblFixedHdr: TLabel;
    lblTotalPercHdr: TLabel;
    lblRemPercHdr: TLabel;
    lblRemPerc: TLabel;
    lblTotalPerc: TLabel;
    lblFixed: TLabel;
    sBar: TStatusBar;
    PageControl1: TPageControl;
    tsPayeeDetails: TTabSheet;
    tsContractorDetails: TTabSheet;
    pnlMain: TPanel;
    tblSplit: TOvcTable;
    Panel2: TPanel;
    sbtnChart: TSpeedButton;
    sbtnSuper: TSpeedButton;
    Header: TOvcTCColHead;
    ColAcct: TOvcTCString;
    ColDesc: TOvcTCString;
    colNarration: TOvcTCString;
    ColGSTCode: TOvcTCString;
    colLineType: TOvcTCComboBox;
    popPayee: TPopupMenu;
    LookupChart1: TMenuItem;
    LookupGSTClass1: TMenuItem;
    Sep1: TMenuItem;
    FixedAmount1: TMenuItem;
    PercentageofTotal1: TMenuItem;
    AmountApplyRemainingAmount1: TMenuItem;
    Sep2: TMenuItem;
    CopyContentoftheCellAbove1: TMenuItem;
    colPercent: TOvcTCNumericField;
    ColAmount: TOvcTCNumericField;
    memController: TOvcController;
    pnlPayeeDetails: TPanel;
    Label2: TLabel;
    nPayeeNo: TOvcNumericField;
    chkContractorPayee: TCheckBox;
    Label1: TLabel;
    eName: TEdit;
    grpContractorType: TGroupBox;
    grpStreetAddress: TGroupBox;
    lblPayeeSurname: TLabel;
    edtPayeeSurname: TEdit;
    lblGivenName: TLabel;
    edtPayeeGivenName: TEdit;
    lblSecondGivenName: TLabel;
    edtSecondGivenName: TEdit;
    radIndividual: TRadioButton;
    radBusiness: TRadioButton;
    lblBusinessName: TLabel;
    edtBusinessName: TEdit;
    edtTradingName: TEdit;
    lblTradingName: TLabel;
    cmbState: TComboBox;
    edtPostCode: TEdit;
    edtStreetAddressLine1: TEdit;
    edtStreetAddressLine2: TEdit;
    edtSuburb: TEdit;
    edtSupplierCountry: TEdit;
    lblPostCode: TLabel;
    lblState: TLabel;
    lblStreetAddress: TLabel;
    lblSuburb: TLabel;
    lblSupplierCountry: TLabel;
    lblPhoneNumber: TLabel;
    edtPhoneNumber: TEdit;
    lblABN: TLabel;
    mskABN: TMaskEdit;
    lblBankAccount: TLabel;
    Label7: TLabel;
    edtBankBSB: TEdit;
    edtBankAccount: TEdit;

    procedure tblSplitActiveCellMoving(Sender: TObject; Command: Word;
      var RowNum, ColNum: Integer);
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure tblSplitEnter(Sender: TObject);
    procedure tblSplitExit(Sender: TObject);
    procedure tblSplitGetCellData(Sender: TObject; RowNum, ColNum: Integer;
      var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure tblSplitBeginEdit(Sender: TObject; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tblSplitEndEdit(Sender: TObject; Cell: TOvcTableCellAncestor;
      RowNum, ColNum: Integer; var AllowIt: Boolean);
    procedure tblSplitUserCommand(Sender: TObject; Command: Word);
    procedure tblSplitDoneEdit(Sender: TObject; RowNum, ColNum: Integer);
    procedure ColAcctKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ColGSTOldKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tblSplitGetCellAttributes(Sender: TObject; RowNum,
      ColNum: Integer; var CellAttr: TOvcCellAttributes);
    procedure tblSplitActiveCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure sbtnChartClick(Sender: TObject);
    procedure ColAcctKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure ColAcctOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure ColGSTCodeOwnerDraw(Sender: TObject;
      TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure eNameEnter(Sender: TObject);
    procedure eNameChange(Sender: TObject);
    procedure ColAmountKeyPress(Sender: TObject; var Key: Char);
    procedure FormResize(Sender: TObject);
    procedure tblSplitEnteringRow(Sender: TObject; RowNum: Integer);
    procedure LookupGSTClass1Click(Sender: TObject);
    procedure CopyContentoftheCellAbove1Click(Sender: TObject);
    procedure AmountApplyRemainingAmount1Click(Sender: TObject);
    procedure FixedAmount1Click(Sender: TObject);
    procedure PercentageofTotal1Click(Sender: TObject);
    procedure tblSplitMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ColAcctKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ColAcctExit(Sender: TObject);
    procedure sbtnSuperClick(Sender: TObject);
    procedure edtPhoneNumberKeyPress(Sender: TObject; var Key: Char);
    procedure cmbStateChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure radBusinessClick(Sender: TObject);
    procedure radIndividualClick(Sender: TObject);
    procedure edtPostCodeKeyPress(Sender: TObject; var Key: Char);
    procedure mskABNClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    { Private declarations }
    fLoading : boolean;
    OKPressed     : boolean;
    AltLineColor  : integer;
    EditMode      : boolean;
    SplitData     : TSplitArray;
    Payee         : TPayee;
    RemovingMask  : boolean;
    OldPayeeName  : string;
    GSTClassEditable : boolean;
    FTaxName      : string;
    FsuperTop, FSuperLeft: Integer;

    procedure UpdateFields(RowNum : integer);
    procedure UpdateTotal;
    function  OKtoPost : boolean;
    procedure RemoveBlankLines;
    procedure SetUpHelp;

    procedure CompletePercentage;
    procedure DoGSTLookup;
    procedure SavePayee(aPayee : TPayee; DeleteFirst: boolean = false);
    procedure CalcRemaining(var Fixed, TotalPerc, RemainingPerc: Money;
      var HasDollarLines, HasPercentLines: boolean);
    function SplitLineIsValid( Index : integer) : boolean;
    procedure DoDitto;
    procedure DoSuperEdit;
    procedure ApplyAmountShortcut(Key: Char);
    procedure ShowPopUp( x, y : Integer; PopMenu :TPopUpMenu );
    function ValidateForAustralia: Boolean;
    procedure SetIndividualBusinessControls(aIsIndividual : boolean);
  public
    { Public declarations }
    function Execute(AddContractorPayee: Boolean = False) : boolean;
  end;

  function EditPayeeDetail(APayee : TPayee) : boolean;
  function AddPayee(var APayee : TPayee; ContractorPayee: Boolean = False) : boolean;

//******************************************************************************
implementation

uses
  WinUtils,
  ovcConst,
  BKHelp,
  bkmxio,
  BKPLIO,
  bkXPThemes,
  AccountLookupfrm,
  GenUtils,
  ErrorMoreFrm,
  updateMF,
  gstLookupfrm,
  InfoMoreFrm,
  YesNoDlg,
  LogUtil,
  bkpyio,
  imagesfrm,
  GSTCalc32,
  bkMaskUtils,
  CanvasUtils,
  StdHints,
  Math,
  Software,
  AuditMgr,
  warningMorefrm,
  Clipbrd,
  bautils,
  countryutils;

{$R *.DFM}

const
  {table command const}
  tcLookup         = ccUserFirst + 1;
  tcDeleteCell     = ccUserFirst + 2;
  tcComplete       = ccUserFirst + 3;
  tcGSTLookup      = ccUserFirst + 4;
  tcDitto          = ccUserFirst + 5;
  tcSuperEdit      = ccUserFirst + 6;

  AccountCol       = 0;
  DescCol          = 1;
  NarrationCol     = 2;
  GSTCol           = 3;
  AmountCol        = 4;
  PercentCol       = 5;
  TypeCol          = 6;

  // The following should not be used as payee codes as they occasionally
  // appear spuriously in cheque data when no payee was entered in the
  // analysis panel.
  UnWisePayeeCodes   : Set of Byte = [ 1, 7, 51, 57 ];

const
  UnitName = 'PAYEEDETAILDLG';

var
   DebugMe : boolean = false;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.FormActivate(Sender: TObject);
begin
  fLoading := true;
  try
    cmbStateChange(Sender);
  finally
    fLoading := false;
  end;
end;

procedure TdlgPayeeDetail.FormCreate(Sender: TObject);
var
  w, i : integer;
  vsbWidth : integer;
begin
  bkXPThemes.ThemeForm( Self);
  okPressed := false;
  EditMode := false;
  removingMask := false;

  for i := Low(SplitData) to High(SplitData) do begin
     ClearWorkRecDetails(@SplitData[i]);
  end;

  //Resize for
  Width := Max( 630, Round( Application.MainForm.Monitor.Width * 0.8));
  Height := Max( 450, Round( Application.MainForm.Monitor.Height * 0.8));

  tblSplit.CommandOnEnter := ccRight;
  tblSplit.RowLimit := GLCONST.Max_py_Lines +1;

  ColGSTCode.MaxLength := GST_CLASS_CODE_LENGTH;
  ColAcct.MaxLength    := MaxBk5CodeLen;
  ColNarration.MaxLength := MaxNarrationEditLength;

  vsbWidth    := GetSystemMetrics( SM_CXVSCROLL );
  //resize the account col so that longest account code fits
  tblSplit.Columns[ AccountCol ].Width := CalcAcctColWidth( tblSplit.Canvas, tblSplit.Font, 80);

  with tblSplit.Controller.EntryCommands do begin
    {remove F2 functionallity}
    DeleteCommand('Grid',VK_F2,0,0,0);
    DeleteCommand('Grid',VK_DELETE,0,0,0);

    {add our commands}
    AddCommand('Grid',VK_F2,0,0,0,tcLookup);
    AddCommand('Grid',VK_F6,0,0,0,ccTableEdit);
    AddCommand('Grid',VK_F7,0,0,0,tcGSTLookup);
    AddCommand('Grid',VK_DELETE,0,0,0,tcDeleteCell);
    AddCommand('Grid',VK_ADD,0,0,0,tcDitto);          {+ - NumPad}
    Addcommand('Grid',187,0,0,0,tcComplete);         {'=' to complete amount}
    AddCommand('Grid',VK_F11,0,0,0,tcSuperEdit);
  end;

  // Resize Desc Column to fit the table size
  with tblSplit do
  begin
     // resize the Desc Column to fit the table width
     W := 0;
     for i := 0 to Pred( Columns.Count ) do begin
        if not Columns[i].Hidden then
           W := W + Columns.Width[i];
     end;
     Columns[ NarrationCol ].Width := Columns[ NarrationCol ].Width + ( Width - W ) - 2 - vsbWidth;;
  end;

  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,sbtnChart.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_SUPER_BMP,sBtnSuper.Glyph);


  sbtnSuper.Visible := CanUseSuperFundFields(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used, sfpayee);
  FsuperTop := -999;
  FSuperLeft := -999;

  //load line type combo
  colLineType.Items.Clear;
  colLineType.Items.Add( BKCONST.pltNames[ pltPercentage]);
  if MyClient.HasForeignCurrencyAccounts then
    colLineType.Items.Add( '')
  else
    colLineType.Items.Add( BKCONST.pltNames[ pltDollarAmt]);

  FTaxName := MyClient.TaxSystemNameUC;
  Header.Headings[ GSTCol  ] := FTaxName;

  if MyClient.HasForeignCurrencyAccounts then begin
    Header.Headings[ TypeCol ] := pltNames[ mltPercentage ];
    lblFixedHdr.Caption := 'Fixed';
  end else begin
    Header.Headings[ TypeCol ] := pltNames[ mltPercentage ] + '/' + pltNames[ mltDollarAmt ];
    lblFixedHdr.Caption := 'Fixed ' + pltNames[ pltDollarAmt ];
  end;

  FixedAmount1.Caption := 'Apply &fixed amount                              ' + pltNames[ pltDollarAmt ];
  LookupGSTClass1.Caption := 'Lookup &' + FTaxName + ' class                                F7';
  SetUpHelp;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.FormShow(Sender: TObject);
begin
  
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.SetIndividualBusinessControls(aIsIndividual: boolean);
begin
  lblPayeeSurname.Enabled    := aIsIndividual;
  lblGivenName.Enabled       := aIsIndividual;
  lblSecondGivenName.Enabled := aIsIndividual;
  lblBusinessName.Enabled    := not aIsIndividual;
  lblTradingName.Enabled     := not aIsIndividual;

  edtPayeeSurname.Enabled    := aIsIndividual;
  edtPayeeGivenName.Enabled  := aIsIndividual;
  edtSecondGivenName.Enabled := aIsIndividual;
  edtBusinessName.Enabled    := not aIsIndividual;
  edtTradingName.Enabled     := not aIsIndividual;

  edtPayeeSurname.Text    := '';
  edtPayeeGivenName.Text  := '';
  edtSecondGivenName.Text := '';
  edtBusinessName.Text    := '';
  edtTradingName.Text     := '';
end;

procedure TdlgPayeeDetail.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   nPayeeNo.Hint    :=
                    'Enter a unique Payee number|'+
                    'Enter a unique Payee number to identify this Payee';
   eName.Hint       :=
                    'Enter the name for this Payee|'+
                    'Enter the name for this Payee';

   edtPayeeSurname.Hint       :=
                    'Enter the surname for this Payee.|'+
                    'Enter the surname for this Payee.';

   edtPayeeGivenName.Hint       :=
                    'Enter the given name for this Payee.|'+
                    'Enter the given name for this Payee.';

   edtSecondGivenName.Hint       :=
                    'Enter any other name for this Payee.|'+
                    'Enter any other name for this Payee.';

   edtStreetAddressLine1.Hint       :=
                    'Enter the address for this Payee.|'+
                    'Enter the address for this Payee.';

   edtStreetAddressLine2.Hint       :=
                    'Enter the address for this Payee.|'+
                    'Enter the address for this Payee.';

   edtSuburb.Hint       :=
                    'Enter the town for this Payee.|'+
                    'Enter the town for this Payee.';

   cmbState.Hint       :=
                    'Select the state for this Payee.|'+
                    'Select the state for this Payee.';

   edtPostCode.Hint       :=
                    'Enter the post code for this Payee.|'+
                    'Enter the post code for this Payee.';

   edtPhoneNumber.Hint       :=
                    'Enter the phone number for this Payee.|'+
                    'Enter the phone number for this Payee.';

   mskABN.Hint       :=
                     'Enter the ABN for this Payee.|' +
                     'Enter the Australian Business Number for this Payee.';

   tblSplit.Hint    :=
                    'Enter the details for coding transactions using this Payee|'+
                    'Enter the details for coding transactions using this Payee';
                    
   sbtnChart.Hint   :=
                    STDHINTS.ChartLookupHint;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.btnOKClick(Sender: TObject);
begin
   tblSplit.StopEditingState(True);
   if OKtoPost then
   begin
      OKPressed := true;
      close;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.btnCancelClick(Sender: TObject);
begin
   okPressed := false;
   close;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.tblSplitEnter(Sender: TObject);
begin
  btnOk.Default := false;
  btnCancel.Cancel := false;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.tblSplitExit(Sender: TObject);
var
  Msg : TWMKey;
begin
  {lost focus so finalise edit if in edit mode}
   if EditMode then
   begin
      Msg.CharCode := vk_f6;
      ColAcct.SendKeyToTable(Msg);
   end;

   btnOK.Default := true;
   btnCancel.Cancel := true;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.tblSplitGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
var
  zero: Double;
begin
  data := nil;
  zero := 0.0;
  if Purpose = cdpForEdit then btnCancel.cancel := false;

  if (RowNum > 0) and (RowNum <= GLCONST.Max_py_Lines) then
  Case ColNum of
    AccountCol:
      data := @SplitData[RowNum].AcctCode;

    DescCol:
      data := @SplitData[RowNum].desc;

    GSTCol:
      data := @SplitData[RowNum].GstClassCode;

    PercentCol:
      if SplitData[RowNum].LineType = mltPercentage then
        data := @SplitData[RowNum].Amount
      else
        data := @zero;

    AmountCol:
      if SplitData[RowNum].LineType = mltPercentage then
        data := @zero
      else
        data := @SplitData[RowNum].Amount;

    NarrationCol :
        data := @SplitData[RowNum].Narration;

    TypeCol:
      data := @SplitData[RowNum].LineType;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.tblSplitBeginEdit(Sender: TObject; RowNum,
  ColNum: Integer; var AllowIt: Boolean);
begin
  EditMode := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.tblSplitEndEdit(Sender: TObject;
  Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
  var AllowIt: Boolean);
var
  tempGSTNo   : integer;
  tempGSTCode : string;
begin
  EditMode := false;

  if ColNum = GSTCol then begin
    {find the gst class no and the replace the given gst class code to make sure
     that only valid codes are allowed}
    tempGSTCode := Trim(TEdit(ColGSTCode.CellEditor).Text);
    tempGSTNo   := GetGSTClassNo( MyClient, tempGSTCode);

    if (tempGSTCode <> '') and (tempGSTNo = 0) then begin
      WinUtils.ErrorSound;
      AllowIt := false;
      EditMode := true;  //still editing
    end
    else
      TEdit(ColGSTCode.CellEditor).Text := GetGSTClassCode( MyClient, tempGSTNo);
  end
  else if ColNum = AmountCol then
    SplitData[RowNum].LineType := pltDollarAmt
  else if ColNum = PercentCol then
    SplitData[RowNum].LineType := pltPercentage;
end;
//------------------------------------------------------------------------------

procedure TdlgPayeeDetail.DoGSTLookup;
var
   Msg           : TWMKey;
   InEditOnEntry : boolean;
   GSTCode : string;
begin
    if not Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then exit;

    with tblSplit do begin
       if not (ActiveCol = GSTCol) then begin
          if not StopEditingState(True) then Exit;
          ActiveCol := GSTCol;
       end;

       InEditOnEntry := InEditingState;
       if not InEditOnEntry then begin
          if not StartEditingState then Exit;   //returns true if alreading in edit state
       end;

       GSTCode := TEdit(colGSTCode.CellEditor).Text;
       if PickGSTClass(GSTCode, True) then begin
           //if get here then have a valid char from the picklist
           TEdit(colGSTCode.CellEditor).Text := GSTCode;
           Msg.CharCode := VK_RIGHT;
           colGSTCode.SendKeyToTable(Msg);
       end
       else begin
           if not InEditOnEntry then begin
              StopEditingState(true);  //end edit
           end;
       end;
    end;
end;
procedure TdlgPayeeDetail.DoSuperEdit;
var
  i: integer;
  Move: TFundNavigation;
  DefaultDesktopSuperFund: integer;
  DefaultClassSuperFund: string;
begin
   with tblSplit do begin
      if not StopEditingState(True) then
         Exit;
       // Check the row ??

       if High(SplitData) = ActiveRow then
          Move := fnIsLast
       else if ActiveRow = 1 then
          Move := fnIsFirst
       else
          Move := fnNothing;

       if SuperFieldsUtils.EditSuperFields( nil,SplitData[ActiveRow] , Move, FSuperTop, FSuperLeft, sfpayee) then
       begin

          //If DesktopSuper and has Ledger ID in Payee Line then all Ledger ID's must be the same
          case MyClient.clFields.clAccounting_System_Used of
            saDesktopSuper:
              begin
                DefaultDesktopSuperFund := SplitData[ActiveRow].SF_Ledger_ID;
                if DefaultDesktopSuperFund <> -1 then begin
                  for i := 1 to GLCONST.Max_py_Lines do
                    SplitData[ i].SF_Ledger_ID := DefaultDesktopSuperFund;
                end else begin
                  //Check if DefaultDesktopSuperFund already set and make this Payee line the same
                  for i := 1 to GLCONST.Max_py_Lines do begin
                    if SplitLineIsValid(i) and (SplitData[i].SF_Ledger_ID <> -1) then begin
                      SplitData[ActiveRow].SF_Ledger_ID := SplitData[ i].SF_Ledger_ID;
                      Break;
                    end else
                      SplitData[ i].SF_Ledger_ID := -1;
                  end;
                end;
              end;
            saClassSuperIP:
              begin
                DefaultClassSuperFund := SplitData[ActiveRow].SF_Ledger_Name;
                if DefaultClassSuperFund <> '' then begin
                  for i := 1 to GLCONST.Max_py_Lines do
                    SplitData[ i].SF_Ledger_Name := DefaultClassSuperFund;
                end else begin
                  //Check if DefaultClassSuperFund already set and make this Payee line the same
                  for i := 1 to GLCONST.Max_py_Lines do begin
                    if SplitLineIsValid(i) and (SplitData[i].SF_Ledger_Name <> '') then begin
                      SplitData[ActiveRow].SF_Ledger_Name := SplitData[ i].SF_Ledger_Name;
                      Break;
                    end else
                      SplitData[ i].SF_Ledger_Name := '';
                  end;
                end;
              end;
          end;

          tblSplit.AllowRedraw := false;
          try
              UpdateFields(tblSplit.ActiveRow);
             tblSplit.InvalidateRow(ActiveRow);

          finally
             tblSplit.AllowRedraw := true;
          end;
          tblSplit.Refresh;

          case Move of
             fnGoBack: begin
                ActiveRow := ActiveRow - 1;
                DoSuperEdit;
             end;
             fnGoForward: begin
                ActiveRow := ActiveRow + 1;
                DoSuperEdit;
             end;
          end;
        end;


   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.tblSplitUserCommand(Sender: TObject; Command: Word);
var
   Msg : TWMKey;
   Code: string;
begin
  Code := '';

  case Command of
    tcLookup :
      begin
        if EditMode then
          Code := TEdit(ColAcct.CellEditor).Text
        else
          Code := SplitData[tblSplit.ActiveRow].AcctCode;

        if PickAccount(Code) then
          if EditMode then
             TEdit(ColAcct.CellEditor).Text := Code
          else begin
             SplitData[tblSplit.ActiveRow].AcctCode := Code;
             UpdateFields(tblSplit.ActiveRow);
             Msg.CharCode := VK_RIGHT;
             ColAcct.SendKeyToTable(Msg);
         end;
      end;
    tcGSTLookup : DoGSTLookup;

    tcDeleteCell :  begin
          if EditMode then exit;
           Keybd_event(VK_SPACE,0,0,0);
           Keybd_event(VK_BACK ,0,0,0);
           Keybd_event(VK_F6   ,0,0,0);
        end;

    tcComplete : CompletePercentage;

    tcDitto :  DoDitto;
    tcSuperEdit : DoSuperEdit;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.UpdateFields(RowNum: integer);
var
   Acct : pAccount_Rec;
   Code : string;
begin
   if not Assigned(myClient) then exit;

   Code := SplitData[RowNum].AcctCode;
   Acct := MyClient.clChart.FindCode( Code);

   if Assigned(Acct) then
   begin
     SplitData[RowNum].GstClassCode        := GetGSTClassCode( MyClient, Acct^.chGST_Class);
     SplitData[RowNum].Desc                := Acct^.chAccount_Description;
     SplitData[RowNum].GST_Has_Been_Edited := false;
     //only overwrite narration if blank
     if SplitData[RowNum].Narration = '' then
       SplitData[RowNum].Narration           := Trim( eName.Text);
   end
   else
   begin
     SplitData[RowNum].GstClassCode        := ' ';
     SplitData[RowNum].Desc                := '';
     SplitData[RowNum].GST_Has_Been_Edited := false;

     if ( Code <> '') or ( RowNum = 1) then
     begin
       if SplitData[RowNum].Narration = '' then
         SplitData[RowNum].Narration := Trim( eName.Text)
     end
     else
       SplitData[RowNum].Narration := '';
   end;

   //set the line type
   if ( SplitData[ RowNum].AcctCode <> '') or ( RowNum = 1) then
   begin
     if ( SplitData[ RowNum].LineType = -1) then
     begin
       if ( RowNum > 1) and ( SplitData[RowNum - 1].LineType <> -1) then
         SplitData[ RowNum].LineType := SplitData[ RowNum - 1].LineType
       else
       begin
         SplitData[ RowNum].LineType := pltPercentage;
       end;
     end;
   end
   else
     begin
       //blank code, blank type
       if ( RowNum > 1) then
         SplitData[ RowNum].LineType := bkconst.pltPercentage;
     end;

   UpdateTotal;

   tblSplit.InvalidateCell(RowNum,AccountCol);  {Account}
   tblSplit.InvalidateCell(RowNum,GSTCol);  {gst class}
   tblSplit.InvalidateCell(RowNum,DescCol);  {desc}
   tblSplit.InvalidateCell(RowNum,NarrationCol);
   tblSplit.InvalidateCell(RowNum,TypeCol);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.tblSplitDoneEdit(Sender: TObject; RowNum,
  ColNum: Integer);
var
   DefaultClass : integer;
   SelectedClass : integer;
begin
   case ColNum of
      AccountCol :
        begin
          SplitData[RowNum].AcctCode := Trim(SplitData[RowNum].AcctCode);
          UpdateFields(RowNum);
        end;
      AmountCol, PercentCol:
      begin
          UpdateTotal;
          tblSplit.InvalidateRow(RowNum);
      end;
      GSTCol     : begin
         //see if different to default for chart
         DefaultClass   := MyClient.clChart.GSTClass( SplitData[RowNum].AcctCode);
         SelectedClass  := GetGSTClassNo( MyClient, SplitData[RowNum].GSTClassCode);
         SplitData[RowNum].GST_Has_Been_Edited := ( DefaultClass <> SelectedClass);
      end;
      TypeCol : begin
         UpdateTotal;
      end;
   end; //case
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.ColAcctKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  var
   msg : TWMKey;
begin
   if key = vk_f2 then
   begin
      Msg.CharCode := VK_F2;
      ColAcct.SendKeyToTable(Msg);
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.ColGSTOldKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
  var
   msg : TWMKey;
begin
   if key = vk_f2 then
   begin
      Msg.CharCode := VK_F2;
      ColGSTCode.SendKeyToTable(Msg);
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.CalcRemaining(var Fixed, TotalPerc, RemainingPerc : Money;
                                        var HasDollarLines, HasPercentLines : boolean);
var
  i : integer;
begin
  Fixed := 0;
  TotalPerc := 0;
  RemainingPerc := 0;

  HasPercentLines := false;
  HasDollarLines  := false;
  for i := 1 to GLCONST.Max_py_Lines do
  begin
    if (SplitData[i].LineType = pltPercentage) and (SplitData[i].Amount <> 0) then
      HasPercentLines := true;

    if (SplitData[i].LineType = pltDollarAmt) and (SplitData[i].Amount <> 0) then
      HasDollarLines := true;
  end;

  for i := 1 to GLCONST.Max_py_Lines do
  begin
    if HasDollarLines and ( not HasPercentLines) then
    begin
      //all lines are dollar amount, add values to both fixed and total
      if SplitData[i].LineType = mltDollarAmt then
      begin
        Fixed := Fixed + Double2Money( SplitData[i].Amount);
      end;
    end
    else
    begin
      //add dollar amounts to fixed, percentage amounts to total
      if SplitData[i].LineType = mltDollarAmt then
        Fixed := Fixed + Double2Money( SplitData[i].Amount);

      if SplitData[i].LineType = mltPercentage then
        TotalPerc := TotalPerc + Double2Percent( SplitData[i].Amount);
    end;
  end;

  RemainingPerc   := Double2Percent(100.0) - TotalPerc;
end;

procedure TdlgPayeeDetail.cmbStateChange(Sender: TObject);
begin
  if ((lblSupplierCountry.Visible) and not (cmbState.ItemIndex = MAX_STATE)) or
     (not (lblSupplierCountry.Visible) and (cmbState.ItemIndex = MAX_STATE)) then
  begin
    if not fLoading then
    begin
      edtPostCode.text := '';
      edtSupplierCountry.text := '';
    end;
  end;

  lblSupplierCountry.Visible := (cmbState.ItemIndex = MAX_STATE);
  edtSupplierCountry.Visible := (cmbState.ItemIndex = MAX_STATE);
  lblPostCode.Visible := not (cmbState.ItemIndex = MAX_STATE);
  edtPostCode.Visible := not (cmbState.ItemIndex = MAX_STATE);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.UpdateTotal;
var
  Fixed  : Money;
  TotalPerc  : Money;
  RemainingPerc : Money;
  HasPercentLines : boolean;
  HasDollarLines  : boolean;
begin
  CalcRemaining(Fixed, TotalPerc, RemainingPerc, HasDollarLines, HasPercentLines);

  if MyClient.HasForeignCurrencyAccounts then
    lblFixed.Caption :=  MyClient.MoneyStrNoSymbol( Fixed )
  else
    lblFixed.Caption :=  MyClient.MoneyStr( Fixed );

  lblTotalPerc.Caption := Format( '%0.4f%%', [TotalPerc/ 10000]);
  lblRemPerc.Caption := Format( '%0.4f%%', [RemainingPerc/ 10000]);

  lblFixed.Visible := HasDollarLines;
  lblFixedHdr.Visible := lblFixed.Visible;

  lblTotalPerc.Visible := True;
  lblTotalPercHdr.Visible := lblTotalPerc.Visible;

  lblRemPerc.Visible   := True;
  lblRemPercHdr.Visible := lblRemPerc.Visible;

  if RemainingPerc = 0 then
    lblRemPerc.Font.Color := clGreen
  else
    lblRemPerc.Font.Color := clRed;
end;

function TdlgPayeeDetail.ValidateForAustralia: Boolean;

  function ValidateField(Field: TWinControl; Condition: Boolean; MessageText: String): Boolean;
  begin
    if Field.Visible and not Condition then
    begin
      HelpfulWarningMsg(MessageText , 0);

      tsContractorDetails.Show;
      Field.SetFocus;

      Result := False;
    end
    else
    begin
      Result := True;
    end;
  end;

  function ValidateRequiredEditField(EditField: TCustomEdit; FieldMsgText: String): Boolean;
  begin
    Result := ValidateField(EditField, Trim(EditField.Text) <> '', Format('You must enter %s. Please try again.', [FieldMsgText]));
  end;

  function ValidateRequiredFields: Boolean;
  begin
    Result := False;

    if not ValidateRequiredEditField(edtStreetAddressLine1, 'an Address') then Exit;
    if not ValidateRequiredEditField(edtSuburb, 'a Town') then Exit;
    if not ValidateRequiredEditField(edtPostCode, 'a Postcode') then Exit;
    if not ValidateRequiredEditField(edtPhoneNumber, 'a Phone Number') then Exit;

    Result := True;
  end;

begin
  Result := False;

  if chkContractorPayee.Checked then
  begin
    if not ValidateRequiredFields then Exit;
  end;

  if Trim(mskABN.Text) <> '' then
  begin
    if not ValidateField(mskABN, ValidateABN(mskABN.Text),
                         'Your Australian Business Number (ABN) is invalid.  Please re-enter it.') then
      Exit;
  end;

  Result := True;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgPayeeDetail.OKtoPost : boolean;

  function ExistingPayeeContractor: Boolean;
  begin
    if Assigned(Payee) then
    begin
      Result := Payee.pdFields.pdContractor;
    end
    else
    begin
      Result := False;
    end;
  end;
  
const
   NullStr = 'XNULLX';
var
  i : integer;
  dNumber : integer;
  dName   : string;
  wasNumber : integer;
  wasName   : string;
  S         : String;
  IsDissected : boolean;
  StartFrom   : integer;
  Fixed  : Money;
  TotalPerc  : Money;
  RemainingPerc : Money;
  HasPercentLines : boolean;
  HasDollarLines  : boolean;
begin
   result := false;

   //trim payee name
   eName.Text := Trim( eName.Text);

   If ( nPayeeNo.AsInteger = 0 ) then
   begin
     HelpfulInfoMsg( 'The payee number 0 can not be used!', 0 );
     tsPayeeDetails.Show;
     nPayeeNo.SetFocus;
     exit;
   end;

   // NZ Only - No Analysis Coding in Australia
   if ( MyClient.clFields.clCountry = whNewZealand ) and
      ( nPayeeNo.AsInteger in UnwisePayeeCodes ) then begin
      S := 'Does this client use analysis coded cheques?  '#13+
           'If so then payee number %0:d should not be used because '+
           'it can appear spuriously on uncoded cheques.'#13#13+
           'Do you wish to select another payee number?';

      if AskYesNo('Payee Code Warning',
                  Format( S, [ nPayeeNo.AsInteger] ),
                  DLG_YES,0 ) <> DLG_NO then
      begin
        tsPayeeDetails.Show;
        nPayeeNo.SetFocus;
        exit;
      end;
   end;

   RemoveBlankLines;
   tblSplit.ActiveRow := 1;

   CalcRemaining( Fixed, TotalPerc, RemainingPerc, HasDollarLines, HasPercentLines);
   if ( RemainingPerc <> 0) then
   begin
     HelpfulErrorMsg( 'Remaining percentage is not zero!', 0 );
     exit;
   end;

   //the first line of the payee can be blank as long as it is the only line
   IsDissected := false;
   for i := 2 to GLCONST.Max_py_Lines do
   begin
     if ( SplitData[i].Amount <> 0) or ( SplitData[i].AcctCode <> '') then
     begin
       IsDissected := true;
       Break;
     end;
   end;

   //only the first line of the payee can have a blank account code
   //this is to allow for single line payees that only edit the narration
   if IsDissected then
     StartFrom := 1
   else
     StartFrom := 2;

   for i := StartFrom to GLCONST.Max_py_Lines do with SplitData[i] do
     If ( double2Money( Amount) <> 0) and ( Trim( AcctCode)='') then
     begin
        HelpfulErrorMsg( 'You must enter an account code!', 0 );
        tblSplit.ActiveCol := AccountCol;
        //reposition on the line that need the code
        tblSplit.ActiveRow := i;
        tblSplit.SetFocus;
        exit;
     end;

   //check account code used
   dNumber := nPayeeNo.AsInteger;
   dName   := eName.text;

   if Assigned(Payee) then
   begin
     wasName := payee.pdName;
     wasNumber := payee.pdNumber;
   end
   else
   begin
     wasName := NULLSTR;
     wasNumber := -1;
   end;

   With MyClient.clPayee_List do
   Begin
     If ( dNumber <> 0 ) and ( Find_Payee_Number( dNumber )<>nil ) and (dNumber <> wasNumber) then
     Begin
        HelpfulInfoMsg( 'The payee number '+inttostr( dNumber )+' has already been used.', 0 );
        tsPayeeDetails.Show;
        nPayeeNo.SetFocus;
        exit;
     end;

     If dName = '' then
     Begin
        HelpfulInfoMsg( 'You must enter a payee name', 0 );
        tsPayeeDetails.Show;
        eName.SetFocus;
        exit;
     end;

     If ( Find_Payee_Name( dName )<> nil ) and (dName <> wasName) then
     Begin
        HelpfulInfoMsg( 'The payee "'+dName+'" has already been entered.', 0 );
        tsPayeeDetails.Show;
        eName.setFocus;
        exit;
     end;
   end;

   if MyClient.clFields.clCountry = whAustralia then
   begin
     if not ValidateForAustralia then Exit;

     if chkContractorPayee.Checked and not ExistingPayeeContractor and (Trim(mskABN.Text) = '') then
     begin
       HelpfulWarningMsg('The ABN is blank for this Contractor Payee. Please ensure that you have completed the below:' + #10#13#10#13 + 'Included a ''No ABN Withholding Tax'' account in the Contractor Payee setup.' + #10#13 + 'Included the ''No ABN Withholding Tax'' account in the W4 rule in GST set up.', 0);
     end;
   end;

   result := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.RemoveBlankLines;
var
   NewData : TSplitArray;
   i       : integer;
   NewC    : integer;

   procedure CopyLine( LineNo : integer);
   begin
     begin
        Inc(NewC);
        NewData[NewC] := SplitData[LineNo];

     end;
   end;

begin
   {initialise temp Array}
   NewC := 0;
   for i := Low(NewData) to High(NewData) do begin
      ClearWorkrecdetails(@NewData[i]);
   end;


   //copy valid lines to new array
   //copy $ amounts first
   for i := 1 to GLCONST.Max_py_Lines do
     if SplitData[i].LineType = pltDollarAmt then
       if SplitLineIsValid( i) then
         CopyLine( i);

   //copy % and blank types
   for i := 1 to GLCONST.Max_py_Lines do
     if SplitData[i].LineType <> pltDollarAmt then
       if SplitLineIsValid( i) then
         CopyLine( i);

   {now replace Splitdata}
    //now replace Splitdata
   if NewC > 0 then begin
      SplitData := NewData;
      tblSplit.Refresh;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.tblSplitActiveCellMoving(Sender: TObject;
  Command: Word; var RowNum, ColNum: Integer);
var
   Code : string;
begin
   Code := '';

   case ColNum of
      DescCol: case Command of
         ccLeft, ccPageLeft   : ColNum := AccountCol;
         ccRight, ccPageRight : ColNum := NarrationCol;
         ccMouse              : ColNum := AccountCol;
      end;

      GSTCol : begin
         if not GSTClassEditable then begin
            case Command of
               ccRight, ccPageRight :  ColNum := AmountCol;
            else
               ColNum := NarrationCol;
            end;
         end;
      end;

      PercentCol: case Command of
         ccRight :
            if ( tblSplit.ActiveCol = ColNum) then begin
               //only try to move down if already in row
               if RowNum < Pred( tblSplit.RowLimit) then
               begin
                 Inc(RowNum);
                 ColNum := AccountCol;
               end;
           end;
      end;
      TypeCol :
       case Command of
          ccRight, ccPageRight :
            if RowNum < tblSplit.RowLimit then
            begin
              Inc(RowNum);
              ColNum := AccountCol;
            end;
       else
          ColNum := PercentCol;
       end;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.tblSplitGetCellAttributes(Sender: TObject; RowNum,
  ColNum: Integer; var CellAttr: TOvcCellAttributes);
begin
  if (CellAttr.caColor = tblSplit.Color) then
    if (RowNum >= tblSplit.LockedRows) and (Odd(Rownum)) then CellAttr.caColor := AltLineColor;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.tblSplitActiveCellChanged(Sender: TObject; RowNum,
  ColNum: Integer);
begin
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.sbtnChartClick(Sender: TObject);
begin
//  keybd_event(vk_f2,0,0,0); seems to be unreliable when called from the pop-up menu
  tblSplit.SetFocus;
  tblSplitUserCommand(Self, tcLookup);  
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.sbtnSuperClick(Sender: TObject);
begin
   if not EditMode then
      tblSplit.SetFocus;
   tblSplitUserCommand(Self, tcSuperEdit);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.ColAcctKeyPress(Sender: TObject; var Key: Char);
var
  Msg : TWMKey;
begin
  if key = '-' then begin
    if Assigned(myClient) and (myClient.clFields.clUse_Minus_As_Lookup_Key) then
    begin
      key := #0;
      Msg.CharCode := VK_F2;
      ColAcct.SendKeyToTable(Msg);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure TdlgPayeeDetail.ColGSTCodeOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
//If gst has been edited show amount in blue
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
begin
  If ( data = nil ) then exit;
  //if selected dont do anything
  if CellAttr.caColor = clHighlight then exit;
  //check is a data row
  if not( (RowNum > 0) and (RowNum <= GLCONST.Max_py_Lines)) then exit;
  //see if edited
  if not SplitData[ RowNum].GST_Has_Been_Edited then
     exit;

  R := CellRect;
  C := TableCanvas;
  S := ShortString( Data^);
  {paint background}
  c.Brush.Color := CellAttr.caColor;
  c.FillRect(R);
  {draw data}
  InflateRect( R, -2, -2 );
  C.Font.Color := bkGSTEditedColor; // cellAttr.caFontColor;
  DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  DoneIt := true;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgPayeeDetail.Execute(AddContractorPayee: Boolean = False) : boolean;
var
  i, SplitIndex : integer;
  NewPayee : integer;
  PayeeLine : pPayee_Line_Rec;
  pAcct    : pAccount_Rec;
  DefaultDesktopSuperFund: integer;
  DefaultClassSuperFund: string;
  CountryCode : string;
  CountryDesc : string;
  StateCodeWidth : integer;
  SpaceWidth : integer;
  SpaceString : string;
  index : integer;
begin
   fLoading  := true;
   okPressed := false;
   EditMode  := false;
   PageControl1.ActivePageIndex := 0;

   {set init values}

   //If DesktopSuper and has Ledger ID in Payee Line then all Ledger ID's must be the same
   DefaultDesktopSuperFund := -1;
   DefaultClassSuperFund := '';
   case MyClient.clFields.clAccounting_System_Used of
     saDesktopSuper:
         if Assigned(Payee) then begin
           for i := 0 to Payee.pdLines.ItemCount - 1 do begin
             if Payee.pdLines.PayeeLine_At(i).plSF_Ledger_ID <> -1 then begin
               DefaultDesktopSuperFund := Payee.pdLines.PayeeLine_At(i).plSF_Ledger_ID;
               Break;
             end;
           end;
         end;
     saClassSuperIP:
         if Assigned(Payee) then begin
           for i := 0 to Payee.pdLines.ItemCount - 1 do begin
             if Payee.pdLines.PayeeLine_At(i).plSF_Ledger_Name <> '' then begin
               DefaultClassSuperFund := Payee.pdLines.PayeeLine_At(i).plSF_Ledger_Name;
               Break;
             end;
           end;
         end;
   end;

   FillChar(SplitData,Sizeof(SplitData),#0);
   for i := 1 to GLCONST.Max_py_Lines do begin
      SplitData[ i].LineType := pltPercentage;
      case MyClient.clFields.clAccounting_System_Used of
        saDesktopSuper: SplitData[ i].SF_Ledger_ID := DefaultDesktopSuperFund;
        saClassSuperIP: SplitData[ i].SF_Ledger_Name := DefaultClassSuperFund;
      end;
   end;
   SplitData[1].Amount := 100.0;
   SplitData[1].LineType := BKCONST.pltPercentage;

   SpaceWidth := self.Canvas.TextWidth(' ');
   for i := MIN_STATE to MAX_STATE do
   begin
     GetAustraliaStateFromIndex(i, CountryCode, CountryDesc);
     StateCodeWidth := self.Canvas.TextWidth(CountryCode);

     SpaceString := '';
     for index := 0 to trunc((49 - StateCodeWidth) / SpaceWidth) do
       SpaceString := SpaceString + ' ';

     if i = MAX_STATE then
       SpaceString := SpaceString + ' ';

     cmbState.AddItem(CountryCode + SpaceString + CountryDesc, nil)
   end;
   SendMessage(cmbState.Handle, CB_SETDROPPEDWIDTH, 250, 0);

   if Assigned(Payee) then
   begin
     eName.Text := Payee.pdName;
     nPayeeNo.asInteger := Payee.pdNumber;
     chkContractorPayee.Checked := Payee.pdFields.pdContractor;

     if Payee.pdFields.pdIsIndividual then
       radIndividual.checked := true
     else
       radBusiness.checked := true;
     SetIndividualBusinessControls(Payee.pdFields.pdIsIndividual);

     edtPayeeSurname.Text := Payee.pdFields.pdSurname;
     edtPayeeGivenName.Text := Payee.pdFields.pdGiven_Name;
     edtSecondGivenName.Text := Payee.pdFields.pdOther_Name;
     edtBusinessName.Text := Payee.pdFields.pdBusinessName;
     edtTradingName.Text := Payee.pdFields.pdTradingName;
     edtStreetAddressLine1.Text := Payee.pdFields.pdAddress;
     edtStreetAddressLine2.Text := Payee.pdFields.pdAddressLine2;
     edtSuburb.Text := Payee.pdFields.pdTown;
     cmbState.ItemIndex := Payee.pdFields.pdStateId;
     edtPostCode.Text := Payee.pdFields.pdPost_Code;
     edtSupplierCountry.Text := Payee.pdFields.pdCountry;
     edtPhoneNumber.Text := Payee.pdFields.pdPhone_Number;
     mskABN.Text := Payee.pdFields.pdABN;
     edtBankBsb.Text := Payee.pdFields.pdInstitutionBSB;
     edtBankAccount.Text := Payee.pdFields.pdInstitutionAccountNumber;

     SplitIndex := 1;
     for i := Payee.pdLines.First to Payee.pdLines.Last do begin
        PayeeLine := Payee.pdLines.PayeeLine_At(i);

        SplitData[SplitIndex].AcctCode := PayeeLine^.plAccount;
        if PayeeLine^.plLine_Type = pltPercentage then
           SplitData[SplitIndex].Amount := Percent2Double(PayeeLine^.plPercentage)
        else
           SplitData[SplitIndex].Amount := Money2Double(PayeeLine^.plPercentage);
        SplitData[SplitIndex].GSTClassCode := GetGSTClassCode( MyClient, PayeeLine^.plGST_Class);
        SplitData[SplitIndex].GST_Has_Been_Edited := PayeeLine^.plGST_Has_Been_Edited;
        SplitData[SplitIndex].Narration := PayeeLine^.plGL_Narration;
        SplitData[SplitIndex].LineType := PayeeLine^.plLine_Type;

        pAcct := MyClient.clChart.FindCode( PayeeLine^.plAccount);
        if Assigned( pAcct) then
           SplitData[SplitIndex].Desc   := pAcct^.chAccount_Description
        else
           SplitData[SplitIndex].Desc  := '';

           //SplitData[SplitIndex].Payee := MemLine^.mlPayee;

        SplitData[SplitIndex].SF_PCFranked := PayeeLine.plSF_PCFranked;
        SplitData[SplitIndex].SF_PCUnFranked := PayeeLine.plSF_PCUnFranked;

        SplitData[SplitIndex].SF_Member_ID := PayeeLine.plSF_Member_ID;
        SplitData[SplitIndex].SF_Fund_ID   := PayeeLine.plSF_Fund_ID;
        SplitData[SplitIndex].SF_Fund_Code := PayeeLine.plSF_Fund_Code;
        SplitData[SplitIndex].SF_Trans_ID  := PayeeLine.plSF_Trans_ID;
        SplitData[SplitIndex].SF_Trans_Code  := PayeeLine.plSF_Trans_Code;
        SplitData[SplitIndex].SF_Member_Account_ID := PayeeLine.plSF_Member_Account_ID;
        SplitData[SplitIndex].SF_Member_Account_Code := PayeeLine.plSF_Member_Account_Code;
        SplitData[SplitIndex].SF_Member_Component := PayeeLine.plSF_Member_Component;

        SplitData[SplitIndex].Quantity := PayeeLine.plQuantity;

        SplitData[SplitIndex].SF_GDT_Date := PayeeLine.plSF_GDT_Date;
        SplitData[SplitIndex].SF_Tax_Free_Dist := PayeeLine.plSF_Tax_Free_Dist;
        SplitData[SplitIndex].SF_Tax_Exempt_Dist := PayeeLine.plSF_Tax_Exempt_Dist;
        SplitData[SplitIndex].SF_Tax_Deferred_Dist := PayeeLine.plSF_Tax_Deferred_Dist;
        SplitData[SplitIndex].SF_TFN_Credits := PayeeLine.plSF_TFN_Credits;
        SplitData[SplitIndex].SF_Foreign_Income := PayeeLine.plSF_Foreign_Income;
        SplitData[SplitIndex].SF_Foreign_Tax_Credits := PayeeLine.plSF_Foreign_Tax_Credits;
        SplitData[SplitIndex].SF_Capital_Gains_Indexed := PayeeLine.plSF_Capital_Gains_Indexed;
        SplitData[SplitIndex].SF_Capital_Gains_Disc := PayeeLine.plSF_Capital_Gains_Disc;
        SplitData[SplitIndex].SF_Capital_Gains_Other := PayeeLine.plSF_Capital_Gains_Other;
        SplitData[SplitIndex].SF_Other_Expenses := PayeeLine.plSF_Other_Expenses;
        SplitData[SplitIndex].SF_Interest := PayeeLine.plSF_Interest;
        SplitData[SplitIndex].SF_Capital_Gains_Foreign_Disc := PayeeLine.plSF_Capital_Gains_Foreign_Disc;
        SplitData[SplitIndex].SF_Rent := PayeeLine.plSF_Rent;
        SplitData[SplitIndex].SF_Special_Income := PayeeLine.plSF_Special_Income;
        SplitData[SplitIndex].SF_Other_Tax_Credit := PayeeLine.plSF_Other_Tax_Credit;
        SplitData[SplitIndex].SF_Non_Resident_Tax := PayeeLine.plSF_Non_Resident_Tax;
        SplitData[SplitIndex].SF_Foreign_Capital_Gains_Credit := PayeeLine.plSF_Foreign_Capital_Gains_Credit;
        SplitData[SplitIndex].SF_Capital_Gains_Fraction_Half := PayeeLine.plSF_Capital_Gains_Fraction_Half;

        SplitData[SplitIndex].SF_Edited := PayeeLine.plSF_Edited;

        Inc(SplitIndex);
     end;
   end
   else
   begin
     chkContractorPayee.Checked := false;
     radIndividual.checked := true;
     edtPayeeSurname.Text := '';
     edtPayeeGivenName.Text := '';
     edtSecondGivenName.Text := '';
     edtBusinessName.Text := '';
     edtTradingName.Text := '';
     edtStreetAddressLine1.Text := '';
     edtStreetAddressLine2.Text := '';
     edtSuburb.Text := '';
     cmbState.ItemIndex := 0;
     edtPostCode.Text := '';
     edtSupplierCountry.Text := '';
     edtPhoneNumber.Text := '';
     mskABN.Text := '';
     edtBankBsb.Text := '';
     edtBankAccount.Text := '';

     // user is adding a new payee so find the current highest number and inc
     NewPayee := 0;
     for i := MyClient.clPayee_List.First to MyClient.clPayee_List.Last do
       with MyClient.clPayee_List.Payee_At(i) do
       begin
         if pdNumber > NewPayee then
            NewPayee := pdNumber;
     end;
     Inc(NewPayee);
     // If in Unwise Payee Codes then increment again until not
     if ( MyClient.clFields.clCountry = whNewZealand ) then begin
         while NewPayee in UnwisePayeeCodes do
            Inc(NewPayee);
     end;

     eName.Text := '';
     nPayeeNo.asInteger := NewPayee;

     if AddContractorPayee and chkContractorPayee.Visible then
     begin
       chkContractorPayee.Checked := True;
     end;
   end;

   UpdateTotal;

   GSTClassEditable := Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used );

   {show form}
   AltLineColor := BKCOLOR_CREAM;

   chkContractorPayee.Visible := Assigned(Adminsystem) and (MyClient.clFields.clCountry = whAustralia);
   tsContractorDetails.Visible := Assigned(Adminsystem) and (MyClient.clFields.clCountry = whAustralia);
   tsContractorDetails.TabVisible := Assigned(Adminsystem) and (MyClient.clFields.clCountry = whAustralia);

   // Skip Focus on Payee Number
   if chkContractorPayee.Visible and not AddContractorPayee then
   begin
     ActiveControl := chkContractorPayee;
   end
   else
   begin
     ActiveControl := eName;
   end;

   fLoading  := false;
   ShowModal;
   result := okPressed;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EditPayeeDetail(APayee : TPayee) : boolean;
var
  MyDlg : TdlgPayeeDetail;
begin
   result := false;

   if not Assigned(aPayee) then exit;

   MyDlg := TdlgPayeeDetail.Create(Application.MainForm);
   try
     BKHelpSetUp(MyDlg, BKH_Editing_a_payee);
     MyDlg.Caption := 'Edit Payee Details';
     MyDlg.Payee := aPayee;


     if MyDlg.execute then
     with Mydlg do
     begin
       {save back values}
       SavePayee(aPayee, True);

       Result := true;
     end;
   finally
     MyDlg.Free;
   end;

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AddPayee(var APayee : TPayee; ContractorPayee: Boolean = False) : boolean;
var
  MyDlg : TdlgPayeeDetail;
begin
   result := false;

   if Assigned(aPayee) then aPayee := nil;

   MyDlg := TdlgPayeeDetail.Create(Application.MainForm);
   try
     BKHelpSetUp(MyDlg, BKH_Adding_a_payee);
     MyDlg.Caption := 'Add New Payee';
     MyDlg.Payee := aPayee;

     if MyDlg.execute(ContractorPayee) then
     with Mydlg do
     begin
       {first create a new payee}
       aPayee := TPayee.Create;
       {save back values}
       SavePayee(aPayee);
       {insert into client}
       MyClient.clPayee_List.Insert(aPayee);

       //Flag Audit
       MyClient.ClientAuditMgr.FlagAudit(arPayees);

       Result := true;
     end;
   finally
     MyDlg.Free;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.CompletePercentage;
var
   mFixed     : Money;
   mRemaining : Money;
   mPercent   : Money;
   HasDollar, HasPercent : boolean;
begin
   //Make sure table is not in edit mode
   if not tblSplit.StopEditingState( true ) then exit;
   //Calculate the percentage remaining
   CalcRemaining( mFixed, mPercent, mRemaining, HasDollar, HasPercent);
   if (mRemaining = 0 ) then exit;

   //Update data with new value
   with tblSplit do begin
      //Add the current line to the remaining value because otherwise the remainder
      //will be not include what is currently in this cell
      if SplitData[ tblSplit.ActiveRow].LineType = mltPercentage then
        mPercent := mRemaining + Double2Percent( SplitData[tblSplit.ActiveRow].Amount )
      else
        //the cell contains a dollar amount so ignore it and complete the percentage
        mPercent := mRemaining;

      //make sure in correct column
      if ( ActiveCol <> PercentCol ) then
        ActiveCol := PercentCol;
      //Start editing mode
      if not StartEditingState then exit;
      //update cell editor
      TOvcNumericField(colPercent.CellEditor).AsFloat := Percent2Double( mPercent );
      SplitData[tblSplit.ActiveRow].LineType := pltPercentage;
      tblSplit.InvalidateCell(tblSplit.ActiveRow, TypeCol);
      //Finish editing
      StopEditingState( true );
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.ColAcctOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
// If the code is invalid, show it in red
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
const
  margin = 4;
  procedure PaintCommentIndicator(CommentColor: TColor);
  begin
      //draw a red triangle in the top right
      TableCanvas.Brush.Color := CommentColor;
      TableCanvas.Pen.Color := CommentColor;

      TableCanvas.Polygon( [Point( CellRect.Right - (Margin+ 1), CellRect.Top),
                            Point( CellRect.Right -1, CellRect.Top),
                            Point( CellRect.Right -1, CellRect.Top + Margin)]);
  end;


begin
  If (data = nil) then
      exit;

   S := ShortString(Data^);

   R := CellRect;

   if CellAttr.caColor <> clHighlight then begin
      if (S = '')
      or (S = BKCONST.DISSECT_DESC)
      or MyClient.clChart.CanCodeTo(S) then begin
         // Ok.
         TableCanvas.Brush.Color := CellAttr.caColor;
         TableCanvas.FillRect(R);
         TableCanvas.Font.Color := clWindowtext;
      end else begin
         TableCanvas.Brush.Color := clRed;
         TableCanvas.Font.Color := clWhite;
         TableCanvas.FillRect(R);
         //paint border
         TableCanvas.Pen.Color := CellAttr.caColor;
         TableCanvas.Polyline( [ Point( R.Left, R.Bottom-1), Point( R.Right, R.Bottom-1) ]);

      end;
   end else begin
     TableCanvas.Brush.Color := clHighlight;
     TableCanvas.Font.Color := clHighlightText;
     TableCanvas.FillRect(R);
   end;
   //paint background
   InflateRect( R, -2, -2 );

   DrawText(TableCanvas.Handle, PChar( S ), -1 , R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);

   if SplitData[RowNum].SF_Edited
   and sbtnSuper.Visible then
      PaintCommentIndicator(clRed);

   DoneIt := True;
end;
//------------------------------------------------------------------------------

procedure TdlgPayeeDetail.eNameEnter(Sender: TObject);
begin
   OldPayeeName := eName.Text;
end;

procedure TdlgPayeeDetail.edtPhoneNumberKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in['0'..'9', #1, #3, #8, #22, #24, #26]) then
  begin
    Key := #0;
  end;
end;

procedure TdlgPayeeDetail.edtPostCodeKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', Chr(VK_DELETE), Chr(VK_BACK)]) then
    Key := chr(0);
end;

procedure TdlgPayeeDetail.eNameChange(Sender: TObject);
var
   i : integer;
begin
   //set the narration for the first line by default
   if ( SplitData[1].AcctCode = '') and (( SplitData[1].Narration = OldPayeeName) or ( SplitData[1].Narration = '')) then
   begin
     SplitData[1].Narration := eName.Text;
   end;

   for i := 1 to GLCONST.Max_py_Lines do begin
      if ( SplitData[i].Narration = OldPayeeName) and ( SplitData[i].AcctCode <> '') then
         SplitData[i].Narration := eName.Text;
   end;
   OldPayeeName := eName.Text;
   tblSplit.AllowRedraw := false;
   try
     tblSplit.Invalidate;
   finally
     tblSplit.AllowRedraw := true;
   end;
end;

procedure TdlgPayeeDetail.SavePayee(aPayee: TPayee; DeleteFirst: boolean = false);
//only valid lines will be added to the list of payee lines
var
  i : Integer;
  PayeeLine : pPayee_Line_Rec;
  AuditIDList: TList;
begin
  AuditIDList := TList.Create;
  try
    if DeleteFirst then begin
      //Pool the audit ID's
      for i := aPayee.pdLines.First to aPayee.pdLines.Last do
        AuditIDList.Add(Pointer(aPayee.pdLines.PayeeLine_At(i).plAudit_Record_ID));
      aPayee.pdLines.FreeAll;
    end;

    {save back values}
    aPayee.pdFields.pdNumber := nPayeeNo.AsInteger;
    aPayee.pdFields.pdName   := Trim( eName.Text);
    aPayee.pdFields.pdContractor := chkContractorPayee.Checked;
    aPayee.pdFields.pdIsIndividual := (radIndividual.checked);
    aPayee.pdFields.pdSurname := edtPayeeSurname.Text;
    aPayee.pdFields.pdGiven_Name := edtPayeeGivenName.Text;
    aPayee.pdFields.pdOther_Name := edtSecondGivenName.Text;
    aPayee.pdFields.pdBusinessName := edtBusinessName.Text;
    aPayee.pdFields.pdTradingName := edtTradingName.Text;
    aPayee.pdFields.pdAddress := edtStreetAddressLine1.Text;
    aPayee.pdFields.pdAddressLine2 := edtStreetAddressLine2.Text;
    aPayee.pdFields.pdTown := edtSuburb.Text;
    aPayee.pdFields.pdStateId := cmbState.ItemIndex;
    aPayee.pdFields.pdPost_Code := edtPostCode.Text;
    aPayee.pdFields.pdCountry := edtSupplierCountry.Text;
    aPayee.pdFields.pdPhone_Number := edtPhoneNumber.Text;
    aPayee.pdFields.pdABN := mskABN.Text;
    aPayee.pdFields.pdInstitutionBSB := edtBankBsb.Text;
    aPayee.pdFields.pdInstitutionAccountNumber := edtBankAccount.Text;

    aPayee.pdLines.FreeAll;
    for i := 1 to GLCONST.Max_py_Lines do
    begin
      if SplitLineIsValid( i) then
      begin
        PayeeLine := New_Payee_Line_Rec;

        PayeeLine^.plAccount := SplitData[i].AcctCode;
        if SplitData[i].LineType = pltPercentage then
          PayeeLine.plPercentage := Double2Percent(SplitData[i].Amount)
        else
          PayeeLine.plPercentage := Double2Money(SplitData[i].Amount);
        PayeeLine.plGST_Has_Been_Edited := SplitData[i].GST_Has_Been_Edited;
        PayeeLine.plGST_Class := GetGSTClassNo( MyClient, SplitData[i].GSTClassCode);
        PayeeLine.plGL_Narration := SplitData[i].Narration;
        PayeeLine.plLine_Type := SplitData[i].LineType;

        PayeeLine.plSF_Edited := SplitData[i].SF_Edited;
        PayeeLine.plSF_PCFranked := SplitData[i].SF_PCFranked;
        PayeeLine.plSF_PCUnFranked := SplitData[i].SF_PCUnFranked;
        PayeeLine.plSF_Member_ID := SplitData[i].SF_Member_ID;
        PayeeLine.plSF_Fund_ID := SplitData[i].SF_Fund_ID;
        PayeeLine.plSF_Fund_Code := SplitData[i].SF_Fund_Code;
        PayeeLine.plSF_Trans_ID := SplitData[i].SF_Trans_ID;
        PayeeLine.plSF_Trans_Code := SplitData[i].SF_Trans_Code;

        PayeeLine.plSF_Member_Account_ID := SplitData[i].SF_Member_Account_ID;
        PayeeLine.plSF_Member_Account_Code := SplitData[i].SF_Member_Account_Code;
        PayeeLine.plSF_Member_Component := SplitData[i].SF_Member_Component;

        PayeeLine.plQuantity := SplitData[i].Quantity;

        PayeeLine.plSF_GDT_Date := SplitData[i].SF_GDT_Date;
        PayeeLine.plSF_Tax_Free_Dist := SplitData[i].SF_Tax_Free_Dist;
        PayeeLine.plSF_Tax_Exempt_Dist := SplitData[i].SF_Tax_Exempt_Dist;
        PayeeLine.plSF_Tax_Deferred_Dist := SplitData[i].SF_Tax_Deferred_Dist;
        PayeeLine.plSF_TFN_Credits := SplitData[i].SF_TFN_Credits;
        PayeeLine.plSF_Foreign_Income := SplitData[i].SF_Foreign_Income;
        PayeeLine.plSF_Foreign_Tax_Credits := SplitData[i].SF_Foreign_Tax_Credits;
        PayeeLine.plSF_Capital_Gains_Indexed := SplitData[i].SF_Capital_Gains_Indexed;
        PayeeLine.plSF_Capital_Gains_Disc := SplitData[i].SF_Capital_Gains_Disc;
        PayeeLine.plSF_Capital_Gains_Other := SplitData[i].SF_Capital_Gains_Other;
        PayeeLine.plSF_Other_Expenses := SplitData[i].SF_Other_Expenses;
        PayeeLine.plSF_Interest := SplitData[i].SF_Interest;
        PayeeLine.plSF_Capital_Gains_Foreign_Disc := SplitData[i].SF_Capital_Gains_Foreign_Disc;
        PayeeLine.plSF_Rent := SplitData[i].SF_Rent;
        PayeeLine.plSF_Special_Income := SplitData[i].SF_Special_Income;
        PayeeLine.plSF_Other_Tax_Credit := SplitData[i].SF_Other_Tax_Credit;
        PayeeLine.plSF_Non_Resident_Tax := SplitData[i].SF_Non_Resident_Tax;
        PayeeLine.plSF_Foreign_Capital_Gains_Credit := SplitData[i].SF_Foreign_Capital_Gains_Credit;
        PayeeLine.plSF_Capital_Gains_Fraction_Half := SplitData[i].SF_Capital_Gains_Fraction_Half;
        PayeeLine.plSF_Ledger_ID := SplitData[i].SF_Ledger_ID;
        PayeeLine.plSF_Ledger_Name := SplitData[i].SF_Ledger_Name;

        if AuditIDList.Count > 0 then begin
          PayeeLine.plAudit_Record_ID := integer(AuditIDList.Items[0]);
          aPayee.pdLines.Insert(PayeeLine, nil);
          AuditIDList.Delete(0);
        end else
          aPayee.pdLines.Insert(PayeeLine, MyClient.ClientAuditMgr);
      end;
    end;
  finally
    AuditIDList.Free;
  end;
end;

procedure TdlgPayeeDetail.ColAmountKeyPress(Sender: TObject;
  var Key: Char);
var
  RowNum, ColNum : integer;
  V: Double;
begin
  RowNum := tblSplit.ActiveRow;
  ColNum := tblSplit.ActiveCol;

  {treat value as percentage}
  if key in [ '$', '£', '%'] then
  begin
    V := SplitData[tblSplit.ActiveRow].Amount;

    tblSplit.StopEditingState( true);

    if ((Key = '%') and (ColNum = PercentCol) and (SplitData[tblSplit.ActiveRow].Amount = 0)) or
       ((Key in [ '$', '£' ]) and (ColNum = AmountCol) and (SplitData[tblSplit.ActiveRow].Amount = 0)) or
       ((SplitData[tblSplit.ActiveRow].Amount = 0) and (V <> 0)) then
      SplitData[tblSplit.ActiveRow].Amount := V;

    if key = '%' then
      SplitData[ RowNum].LineType := pltPercentage;

    if key in [ '$', '£' ] then
      SplitData[ RowNum].LineType := pltDollarAmt;

    Key := #0;

    tblSplit.AllowRedraw := false;
    try
      tblSplit.InvalidateCell(RowNum,TypeCol);
      tblSplit.InvalidateCell(RowNum,AmountCol);
      tblSplit.InvalidateCell(RowNum,PercentCol);
    finally
      tblSplit.AllowRedraw := true;
      UpdateTotal;
    end;
  end;
end;

function TdlgPayeeDetail.SplitLineIsValid(Index : integer) : boolean;
begin
   result := (Trim(SplitData[Index].AcctCode)<>'') or
             (GetGSTClassNo( MyClient, SplitData[Index].GSTClassCode) <> 0) or
             (SplitData[Index].Amount <>0) or
             ((Trim( SplitData[Index].Narration) <> '') and (Index = 1));
end;

procedure TdlgPayeeDetail.FormResize(Sender: TObject);
var
   i : integer;
   W : integer;
begin
   with tblSplit do begin
      // Now resize the Desc Column to fit the table width
      W := 0;
      for i := 0 to Pred( Columns.Count ) do begin
         if not Columns[i].Hidden then
            W := W + Columns.Width[i];
      end;
      i := GetSystemMetrics( SM_CXVSCROLL ); //Get Width Vertical Scroll Bar
      W := W + i + 4;
      Columns[ NarrationCol ].Width := Columns[ NarrationCol ].Width + ( Width - W );
   end;
end;

procedure TdlgPayeeDetail.tblSplitEnteringRow(Sender: TObject;
  RowNum: Integer);
begin
  sBar.Panels[0].Text := Format( '%d of %d', [ tblSplit.ActiveRow, GLCONST.Max_py_Lines ] );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPayeeDetail.DoDitto;
var
  Msg            : TWMKey;
  FieldId        : integer;
  DittoOK        : boolean;
Begin
   with tblSplit do begin
      if not (ActiveRow > 1) then exit; //Must have line above to copy from
      if not StartEditingState then Exit;   //returns true if alreading in edit state

      DittoOK := false;
      FieldID := tblSplit.ActiveCol;

      case FieldID of
         AccountCol: begin
            //make sure current cell is blank and that previous trx is not dissected
            if (Trim(TEdit(ColAcct.CellEditor).Text) = '') then
            begin
              TEdit(ColAcct.CellEditor).Text := SplitData[tblSplit.ActiveRow-1].AcctCode;
              DittoOK := true;
            end;
         end;

         DescCol:
           begin
            if (Trim(TEdit(ColDesc.CellEditor).Text) = '') then begin
              TEdit(ColDesc.CellEditor).Text := SplitData[tblSplit.ActiveRow-1].Desc;
              DittoOK := true;
            end;
           end;

         NarrationCol: begin
            if (Trim(TEdit(ColNarration.CellEditor).Text) = '') then begin
              TEdit(ColNarration.CellEditor).Text := SplitData[tblSplit.ActiveRow-1].Narration;
              DittoOK := true;
            end;
         end;

         GSTCol : begin
            if (Trim(TEdit(ColGSTCode.CellEditor).Text) = '') then begin
               TEdit(ColGSTCode.CellEditor).Text := SplitData[tblSplit.ActiveRow-1].GSTClassCode;
               DittoOK := true;
            end;
         end;

         AmountCol: begin
            if (TOvcNumericField(ColAmount.CellEditor).AsFloat = 0) then begin
               if SplitData[tblSplit.ActiveRow-1].Linetype = mltPercentage then
                 TOvcNumericField(ColAmount.CellEditor).AsFloat := 0.0
               else
               begin
                 SplitData[tblSplit.ActiveRow].LineType := mltDollarAmt;
                 TOvcNumericField(ColAmount.CellEditor).AsFloat := SplitData[tblSplit.ActiveRow-1].Amount;
                 InvalidateRow(ActiveRow);
               end;
               DittoOK := true;
            end;
         end;

         PercentCol: begin
            if (TOvcNumericField(ColPercent.CellEditor).AsFloat = 0) then begin
               if SplitData[tblSplit.ActiveRow-1].Linetype = mltPercentage then
               begin
                 SplitData[tblSplit.ActiveRow].LineType := mltPercentage;
                 TOvcNumericField(ColPercent.CellEditor).AsFloat := SplitData[tblSplit.ActiveRow-1].Amount;
                 InvalidateRow(ActiveRow);                 
               end
               else
                 TOvcNumericField(ColPercent.CellEditor).AsFloat := 0.0;
               DittoOK := true;
            end;
         end;
      end;

      if DittoOK then begin
         //if field was updated the save the edit and move right
         if not StopEditingState(True) then exit;
         if (FieldID in [AccountCol, DescCol, NarrationCol, GSTCol,
            AmountCol, PercentCol, TypeCol]) then
         begin
           Msg.CharCode := VK_RIGHT;
           ColAcct.SendKeyToTable(Msg);
         end;
      end
      else begin
         //field not updated, abandon edit and don't move off current cell
         StopEditingState(true); //SaveData = false doesnt seem to work, message posted on turbopower news group
      end;
   end;
end;

// #1727 - add more shortcuts to the right-click menu

procedure TdlgPayeeDetail.LookupGSTClass1Click(Sender: TObject);
begin
  Self.DoGSTLookup;
end;

procedure TdlgPayeeDetail.mskABNClick(Sender: TObject);
var
  Control: TMaskEdit;
begin
  Control := Sender as TMaskEdit;
  if Control.Text = '' then
  begin
    Control.SelText := '';
    Control.SelStart := 0;
  end;
end;

procedure TdlgPayeeDetail.CopyContentoftheCellAbove1Click(Sender: TObject);
begin
  Self.DoDitto;
end;

procedure TdlgPayeeDetail.AmountApplyRemainingAmount1Click(
  Sender: TObject);
var
  Col: Integer;
begin
  Col := -1;
  with tblSplit do
  begin
    if ActiveCol <> PercentCol then
    begin
      if not StopEditingState(True) then Exit;
      Col := ActiveCol;
      ActiveCol := PercentCol;
    end;
    Self.CompletePercentage;
    if Col > -1 then
      ActiveCol := Col;
  end;
end;

procedure TdlgPayeeDetail.FixedAmount1Click(Sender: TObject);
begin
  if SplitData[tblSplit.ActiveRow].LineType = mltDollarAmt then exit;
  ApplyAmountShortcut('$');
end;

procedure TdlgPayeeDetail.PageControl1Change(Sender: TObject);
begin
  pnlTotalAmounts.Visible := (PageControl1.ActivePage = tsPayeeDetails);
end;

procedure TdlgPayeeDetail.PercentageofTotal1Click(Sender: TObject);
begin
  if SplitData[tblSplit.ActiveRow].LineType = mltPercentage then exit;
  ApplyAmountShortcut('%');
end;

procedure TdlgPayeeDetail.radIndividualClick(Sender: TObject);
begin
  SetIndividualBusinessControls(true);
end;

procedure TdlgPayeeDetail.radBusinessClick(Sender: TObject);
begin
  SetIndividualBusinessControls(false);
end;

procedure TdlgPayeeDetail.ApplyAmountShortcut(Key: Char);
var
  Col: Integer;
begin
  Col := -1;
  with tblSplit do
  begin
    if ActiveCol <> PercentCol then
    begin
      if not StopEditingState(True) then Exit;
      Col := ActiveCol;
      ActiveCol := PercentCol;
    end;
    StartEditingState;    
    Self.ColAmountKeyPress(tblSplit, Key);
    if Col > -1 then
      ActiveCol := Col;
  end;
end;

procedure TdlgPayeeDetail.tblSplitMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
// Catch Right Click and decide which PopUp to display
var
  ColEstimate, RowEstimate : integer;
begin
{$IFNDEF SmartBooks}
  if (Button = mbRight) then begin
    //estimate where click happened
    if tblSplit.CalcRowColFromXY(x,y,RowEstimate,ColEstimate) in [ otrOutside, otrInUnused ] then
      exit;
    // Select row
    tblSplit.SetFocus;
    tblSplit.ActiveRow := RowEstimate;
    ShowPopup( x,y,popPayee);
  end;
{$ENDIF}
end;

procedure TdlgPayeeDetail.ShowPopUp( x, y : Integer; PopMenu :TPopUpMenu );
var
   ClientPt, ScreenPt : TPoint;
begin
   ClientPt.x := x;
   ClientPt.y := y;
   ScreenPt   := tblSplit.ClientToScreen(ClientPt);
   PopMenu.Popup(ScreenPt.x, ScreenPt.y);
end;

procedure TdlgPayeeDetail.ColAcctKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Account : ShortString;
  Msg     : TWMKey;
begin
   if ( Key = VK_BACK ) then
    bkMaskUtils.CheckRemoveMaskChar(TEdit(colAcct.CellEditor),RemovingMask)
  else
    bkMaskUtils.CheckForMaskChar(TEdit(colAcct.CellEditor),RemovingMask);

  if not Assigned(MyClient) then exit;

  Account := TEdit(ColAcct.CellEditor).text;
  if MyClient.clChart.CanPressEnterNow(Account) then
  begin
     TEdit(ColAcct.CellEditor).text := Account;
     //SplitData[tblSplit.ActiveRow].AcctCode := Account;
     Msg.CharCode := VK_RIGHT;
     ColAcct.SendKeyToTable(Msg);
  end;
end;

procedure TdlgPayeeDetail.ColAcctExit(Sender: TObject);
begin
  if not MyClient.clChart.CodeIsThere(TEdit(colAcct.CellEditor).Text) then
    bkMaskUtils.CheckRemoveMaskChar(TEdit(colAcct.CellEditor),RemovingMask);
end;

initialization
   DebugMe := DebugUnit(UnitName);
end.
