unit EditGSTDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   Edit GST Setup Dlg

  Written:
  Authors: Matthew

  Purpose: Edit the GST Detail and Rates and Reporting Options for a client

  Notes:   Can be called using function EditGstDetails or function SetupGSTReportOptions
           The second call just makes the Report Options page the first page.

           The tree view works like this

           Level 0 ( top level)
              Broad Categories for the form - Calc Sheet, PAYG, Witholding
              Data pointer is not used

           Level 1
              The individual Boxes used on the form
              Data pointer is a integer that stores the BAS field no for the box

           Level 2
              GST Class or Account which adds into the parent box
              Data pointer points to a record structure which hold the information for this
              accumulator.  The structure is filled when the tree view is populated, or
              when a new item is added.
              The memory associated with these records must be freed when the tree view is
              destroyed, or when an individual item is deleted.

              The MAX number of level 2 nodes that can be used is 100.  This is determined
              by the max size of the clBAS_Field arrays

}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcBase, StdCtrls, OvcTCBEF, OvcTCNum, OvcTCCBx, OvcTCEdt, OvcTCmmn,
  OvcTCell, OvcTCStr, OvcTCHdr, OvcTable, OvcEF, OvcPB, OvcPF, ImgList,
  ComCtrls, OvcTCPic, Buttons, Mask, MoneyDef, ExtCtrls, ovcnf,
  OSFont;

type
  TdlgEditGST = class(TForm)
    OvcController1: TOvcController;
    colDesc: TOvcTCString;
    colRate1: TOvcTCNumericField;
    colRate2: TOvcTCNumericField;
    colRate3: TOvcTCNumericField;
    colAccount: TOvcTCString;
    btnOk: TButton;
    btnCancel: TButton;
    colHeader: TOvcTCColHead;
    ColID: TOvcTCString;
    celGSTType: TOvcTCComboBox;
    pcGST: TPageControl;
    pgDetails: TTabSheet;
    tsGSTRates: TTabSheet;
    lblNumber: TLabel;
    lsvPeriodDisplay: TListView;
    cmbBasis: TComboBox;
    lblBasis: TLabel;
    lblPeriod: TLabel;
    cmbPeriod: TComboBox;
    cmbStarts: TComboBox;
    lblStarts: TLabel;
    tblRates: TOvcTable;
    eDate1: TOvcPictureField;
    eDate2: TOvcPictureField;
    eDate3: TOvcPictureField;
    Label5: TLabel;
    sbtnChart: TSpeedButton;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    eABN_Division: TEdit;
    eGSTNumber: TMaskEdit;
    btnDefaults: TButton;
    pgBASRules: TTabSheet;
    BASTV: TTreeView;
    btnAddTaxLevel: TButton;
    btnAddAccount: TButton;
    btnDelete: TButton;
    Label10: TLabel;
    pgReportSettings: TTabSheet;
    gbxAccrual: TGroupBox;
    Label2: TLabel;
    lblPaymentsOn: TLabel;
    chkJournals: TCheckBox;
    gbxClassify: TGroupBox;
    Label1: TLabel;
    Label6: TLabel;
    cmbEntriesBy: TComboBox;
    colNormPercent: TOvcTCNumericField;
    pgCalcMethod: TTabSheet;
    rbFull: TRadioButton;
    Label12: TLabel;
    Label13: TLabel;
    rbSimple: TRadioButton;
    pnlMethodWarning: TPanel;
    Label15: TLabel;
    WarningBmp: TImage;
    lblPAYG: TLabel;
    cmbPAYGWithheld: TComboBox;
    lblPeriodsTitle: TLabel;
    lblPAYGInstalment: TLabel;
    cmbPAYGInstalment: TComboBox;
    bvlBAS: TBevel;
    chkIncludeFBT: TCheckBox;
    pnlBASReportOptions: TPanel;
    Label16: TLabel;
    rbATOBas: TRadioButton;
    rbOnePageBAS: TRadioButton;
    chkDontPrintCS: TCheckBox;
    chkIncludeFuel: TCheckBox;
    lblTFN: TLabel;
    eTFN: TMaskEdit;
    chkDontPrintFuel: TCheckBox;
    cbProvisional: TCheckBox;
    cbRatioOption: TCheckBox;
    lblRatio: TLabel;
    ERatio: TOvcNumericField;
    tsTaxRates: TTabSheet;
    Label3: TLabel;
    Label4: TLabel;
    Label17: TLabel;
    lh10: TLabel;
    Bevel7: TBevel;
    Label18: TLabel;
    Label19: TLabel;
    EDateT3: TOvcPictureField;
    EDateT2: TOvcPictureField;
    EDateT1: TOvcPictureField;
    eRate3: TOvcPictureField;
    ERate2: TOvcPictureField;
    eRate1: TOvcPictureField;
    btndefaultTax: TButton;

    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure lsvPeriodDisplayEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure tblRatesGetCellData(Sender: TObject; RowNum, ColNum: Integer;
      var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure cmbPeriodChange(Sender: TObject);
    procedure colAccountKeyPress(Sender: TObject; var Key: Char);
    procedure colAccountChange(Sender: TObject);
    procedure colAccountKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tblRatesUserCommand(Sender: TObject; Command: Word);
    procedure tblRatesExit(Sender: TObject);
    procedure tblRatesBeginEdit(Sender: TObject; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tblRatesEndEdit(Sender: TObject; Cell: TOvcTableCellAncestor;
      RowNum, ColNum: Integer; var AllowIt: Boolean);
    procedure tblRatesActiveCellMoving(Sender: TObject; Command: Word;
      var RowNum, ColNum: Integer);
    procedure tblRatesActiveCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure sbtnChartClick(Sender: TObject);
    procedure tblRatesEnter(Sender: TObject);
    procedure tblRatesGetCellAttributes(Sender: TObject; RowNum,
      ColNum: Integer; var CellAttr: TOvcCellAttributes);
    procedure celGSTTypeDropDown(Sender: TObject);
    procedure tblRatesDoneEdit(Sender: TObject; RowNum, ColNum: Integer);
    procedure cmbBasisChange(Sender: TObject);
    procedure btnDefaultsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddTaxLevelClick(Sender: TObject);
    procedure btnAddAccountClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure pcGSTChange(Sender: TObject);
    procedure BASTVCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure rbSimpleClick(Sender: TObject);
    procedure cmbPAYGWithheldChange(Sender: TObject);
    procedure colAccountOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure rbATOBasClick(Sender: TObject);
    procedure eGSTNumberClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure colAccountKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure colAccountExit(Sender: TObject);
    procedure chkIncludeFuelClick(Sender: TObject);
    procedure cbProvisionalClick(Sender: TObject);
    procedure cbRatioOptionClick(Sender: TObject);
    procedure btndefaultTaxClick(Sender: TObject);
    procedure EDateT1DblClick(Sender: TObject);
    procedure Label12Click(Sender: TObject);
  private
    { Private declarations }
    okPressed          : boolean;
    editMode           : boolean;
    removingMask       : boolean;
    StdLineLightColor  : integer;
    StdLineDarkColor   : integer;

    SlotCount          : integer;

    tmpShortStr : ShortString;
    tmpPaintShortStr : ShortString;
    FTaxName: String;

    procedure DisplayPeriods;
    procedure DoDeleteCell;
    procedure UpdateProvisional;
{$IFNDEF SmartBooks}
    procedure SetupBASRulesPage;
    procedure AddNewSlotNode( Parent : TTreeNode; aFieldNo : byte; aSource : byte; aAccountCode : string; aBalanceType : byte; aPercent : Money);
{$ENDIF}
    function OKtoPost : boolean;
    Procedure AddNodesForBASField( ParentNode : TTreeNode; BASFieldNo : Integer );
    procedure SetTaxName(const Value: String);
    property TaxName : String read FTaxName write SetTaxName;
  public
    { Public declarations }
    function Execute : boolean;
  end;

function EditGSTDetails(ContextID : Integer) : boolean;
//******************************************************************************
implementation

uses
  bkconst,
  BKHelp,
  bkXPThemes,
  glConst,
  globals,
  ovcConst,
  bkBranding,
  GenUtils,
  BASUtils,
  BasFieldLookup,
  GSTCalc32,
  GSTUtil32,
  WinUtils,
  ovcDate,
  stDateSt,
  AccountLookupFrm,
  GSTLookupFrm,
  updateMf,
  bkMaskUtils,
  CanvasUtils,
  imagesfrm,
  warningMorefrm,
  infoMoreFrm,
  bkDateUtils,
  StdHints,
  stStrs,
  Admin32,
  Math,
  StringListHelper,
  ComboUtils,
  StrUtils,
  BKDEFS,
  AuditMgr;

{$R *.DFM}

type
   TGSTInfoRec = record
      GST_ID               : string[GST_CLASS_CODE_LENGTH];
      GST_Class_Name       : String[60];
      GST_Rates            : Array[ 1..MAX_VISIBLE_GST_CLASS_RATES ] of double;
      GST_Account_Code     : Bk5CodeStr;
      GSTClassTypeCmbIndex : integer;
      GST_BusinessNormPercent : Double;
   end;

type
   pBasAccumulatorInfo = ^TBasAccumulatorInfo;

   TBasAccumulatorInfo = record
      FieldNo       : Byte;
      Source        : Byte;
      AccountCode   : string;
      BalanceType   : Byte;
      Percent       : Money;
   end;

const
    {table command const}
  tcLookup                = ccUserFirst + 1;
  tcDeleteCell            = ccUserFirst + 2;

  IDCol                   = 0;  FirstCol = 0;
  DescCol                 = 1;
  TypeCol                 = 2;
  Rate1Col                = 3;
  Rate2Col                = 4;
  Rate3Col                = 5;
  AccountCol              = 6;
  BusinessNormPercentCol  = 7;  LastCol  = 7;

var
   GST_Table : Array[1..MAX_GST_CLASS] of TGSTInfoRec;
   LastVisibleCol : integer = LastCol;

//------------------------------------------------------------------------------
{$IFNDEF SmartBooks}
procedure  UpdateBasSlotDesc( aNode : TTreeNode);
//return the string which describes this slot.
//GST descriptions may change if the user changes the description in the rates
//setup so we need to reload the desc everytime.
//The account description will not change so we only need to get it from the
//chart if the current description is empty
var
   Desc : string;
   sPerc : string;
   Account : pAccount_Rec;
begin
   if ( aNode.Level <> 2) or ( aNode.Data = nil) then exit;

   with pBASAccumulatorInfo( aNode.Data)^ do begin
      if Source = BasUtils.bsFrom_Chart then begin
         if aNode.Text = '' then begin
            sPerc := Percent2Str( Percent) + '% of ';
            Account := MyClient.clChart.FindCode( AccountCode );
            if Assigned( Account ) then With Account^ do
               Desc := '<'+ AccountCode + '> ' + chAccount_Description
            else
               Desc := AccountCode + ' < INVALID CODE >';
            Case BalanceType of
               blGross : Desc := 'Gross Total of Account ' + Desc;
               blNet   : Desc := 'Net Total of Account '   + Desc;
               blTax   : Desc := 'Tax Total of Account '   + Desc;
            end;
            Desc := sPerc + Desc;
         end
         else
            //no change
            Desc := aNode.Text;
      end
      else begin
         //if a gst class so need to use the CURRENT description from the grid
         if Source in [ 0..MAX_GST_CLASS ] then
         begin
            sPerc := Percent2Str( Percent) + ' % of ';
            if Source = 0 then
               Desc := '[Unallocated]'
            else
               Desc := GST_Table[ Source].GST_ID + ' : ' + GST_Table[ Source].GST_Class_Name;
            Case BalanceType of
               blGross : Desc := 'Gross Total of GST Class ' + Desc;
               blNet   : Desc := 'Net Total of GST Class '   + Desc;
               blTax   : Desc := 'Tax Total of GST Class '   + Desc;
            end;
            Desc := sPerc + Desc;
         end;
      end;
   end;
   //update node text
   aNode.Text := Desc;

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditGST.AddNewSlotNode( Parent : TTreeNode;
                                      aFieldNo : byte;
                                      aSource : byte;
                                      aAccountCode : string;
                                      aBalanceType : byte;
                                      aPercent : Money);

var
   Node      : TTreeNode;
   p         : pBasAccumulatorInfo;
begin
   New( p);
   with p^ do begin
      FieldNo      := aFieldNo;
      Source       := aSource;
      AccountCode  := aAccountCode;
      BalanceType  := aBalanceType;
      Percent      := aPercent;
   end;
   Node      := BASTV.Items.AddChild( Parent, '');
   Node.Data := p;
   UpdateBasSlotDesc( Node);
   Inc( SlotCount);
end;
//------------------------------------------------------------------------------

Procedure TdlgEditGST.AddNodesForBASField( ParentNode : TTreeNode; BASFieldNo : Integer );
//add nodes to level 2
Var
   i         : Integer;
begin
   With MyClient.clFields, MyClient.clChart do begin
      For i := BASUtils.MIN_SLOT to BASUtils.MAX_SLOT do
         if clBAS_Field_Number[ i ] = BASFieldNo then begin
            AddNewSlotNode( ParentNode,
                            clBAS_Field_Number[ i],
                            clBAS_Field_Source[ i],
                            clBAS_Field_Account_Code[ i],
                            clBAS_Field_Balance_Type[ i],
                            clBAS_Field_Percent[ i]);
         end;
   end;
end;

procedure TdlgEditGST.SetTaxName(const Value: String);
begin
  FTaxName := Value;
  Caption := Value + ' Set Up';
  colHeader.Headings[ TypeCol ] := TaxName + ' Type';
  lblPeriod.Caption := TaxName + ' Period';
end;

procedure TdlgEditGST.SetupBASRulesPage;
Var
   First       : TTreeNode;
   N1, N2      : TTreeNode;
   BASFieldNo  : Integer;
begin
   SlotCount := 0;

   With MyClient.clFields do
   begin
      if clCountry = whNewZealand then
      begin
         pgBASRules.Visible := False;
         exit;
      end;

      if clCountry = whUK then
      begin
         pgBASRules.Visible := False;
         exit;
      end;

      if clCountry = whAustralia then
      begin
         {Load up the Tree View}
         With pgBASRules do
         begin
            BASTV.Items.BeginUpdate;
            Try
               BASTV.Items.Clear;
               { ------------------------------------------------------------------- }
               //level 0
               N1 := BASTV.Items.Add( NIL, 'GST Calculation Sheet' ); First := N1;
               //level 1
               For BASFieldNo := bfG1 to bfG18 do
               begin
                  { The left most node is the field description }
                  N2 := BASTV.Items.AddChild( N1, bfFieldIDs[ BASFieldNo ]  + ': ' + bfNames[ BASFieldNo ] );
                  N2.Data := Pointer( BASFieldNo );
                  AddNodesForBASField( N2, BASFieldNo );
               end;
               N1.Expand( False );
               { ------------------------------------------------------------------- }
               //level 0
               N1 := BASTV.Items.Add( NIL, 'PAYG Withholding' );
               //level 1
               For BASFieldNo := bfW1 to bfW4 do
               begin
                  { The left most node is the field description }
                  N2 := BASTV.Items.AddChild( N1, bfFieldIDs[ BASFieldNo ] + ': ' + bfNames[ BASFieldNo ] );
                  N2.Data := Pointer( BASFieldNo );
                  AddNodesForBASField( N2, BASFieldNo );
               end;
               { ------------------------------------------------------------------- }
                //level 0
               N1 := BASTV.Items.Add( NIL, 'PAYG Instalment' );
               //level 1
                  { The left most node is the field description}
               For BASFieldNo := bfT1 to bfT1 do // Just being prepaired..
               begin
                  N2 := BASTV.Items.AddChild( N1, bfFieldIDs[ BASFieldNo ] + ': ' + bfNames[ BASFieldNo ] );
                  N2.Data := Pointer( BASFieldNo );
                  AddNodesForBASField( N2, BASFieldNo );
               end;
               { ------------------------------------------------------------------- }
               //level 0
               N1 := BASTV.Items.Add( NIL, 'Totals' );
               //level 1
               For BASFieldNo := bf1C to bf7 do
               if not (BASFieldNo in bfObsoleteFields) then begin
                  { The left most node is the field description }
                  N2 := BASTV.Items.AddChild( N1, bfFieldIDs[ BASFieldNo ] + ': ' + bfNames[ BASFieldNo ] );
                  N2.Data := Pointer( BASFieldNo );
                  AddNodesForBASField( N2, BASFieldNo );
               end;
               { ------------------------------------------------------------------- }
               // Add 7D if required
               chkIncludeFuelClick(Self);
               First.Selected := True;
            Finally
               BASTV.Items.EndUpdate;
            end;
         end;

         //see if there are any available slots to put new info into
         if SlotCount = BasUtils.MAX_SLOT then
         begin
            btnAddTaxLevel.Enabled := False;
            btnAddAccount.Enabled := False;
         end
         else
         begin
            btnAddTaxLevel.Enabled := True;
            btnAddAccount.Enabled := True;
         end;

         //see if any data has been entered
         if SlotCount = 0 then
            btnDelete.Enabled := False
         else
            btnDelete.Enabled := True;
      end;
   end;
end;
{$ENDIF}
//------------------------------------------------------------------------------

procedure TdlgEditGST.FormCreate(Sender: TObject);
var
   i : Integer;
   Country : Integer;
begin
  bkXPThemes.ThemeForm( Self);
  lblPaymentsOn.Font.Style := [fsBold];
  Label15.Font.Style := [fsBold];
  SetVistaTreeView(BASTV.Handle);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,sbtnChart.Glyph);
  removingMask := false;

  TaxName := MyClient.TaxSystemNameUC;
  Country := MyClient.clFields.clCountry;

  if TaxName <> 'GST' then
  Begin
    Label2.Caption := ReplaceStr( Label2.Caption, 'GST', TaxName );
    lblPaymentsOn.Caption := ReplaceStr( lblPaymentsOn.Caption, 'GST', TaxName );
    Label6.Caption := ReplaceStr( Label6.Caption, 'GST', TaxName );
  End;

  lblPAYG.Visible             := ( Country = whAustralia);
  cmbPAYGWithheld.Visible     := ( Country = whAustralia);
  lblPAYGInstalment.Visible   := ( Country = whAustralia);
  cmbPAYGInstalment.Visible   := ( Country = whAustralia);
  chkIncludeFBT.Visible       := ( Country = whAustralia);
  chkIncludeFuel.Visible      := ( Country = whAustralia);
  bvlBas.Visible              := ( Country = whAustralia);
  lblTFN.Visible              := ( Country = whAustralia);
  eTFN.Visible                := ( Country = whAustralia);

  lblRatio.Visible            := ( Country = whNewZealand);
  ERatio.Visible              := ( Country = whNewZealand);
  CbProvisional.Visible       := ( Country = whNewZealand);
  cbRatioOption.Visible       := ( Country = whNewZealand);

  if ( Country <> whAustralia ) then
  begin
    lblBasis.Top  := lblNumber.Top  + 37;
    lblStarts.Top := lblBasis.Top   + 37;
    lblPeriod.Top := lblStarts.Top  + 37;

    cmbBasis.Top  := eGSTNumber.Top + 37;
    cmbStarts.Top := cmbBasis.Top  + 37;
    cmbPeriod.Top := cmbStarts.Top  + 37;
    // Must be NZ
    cbProvisional.Top := cmbPeriod.Top + 37;
    cbRatioOption.Top := cbProvisional.Top + 37;
    ERatio.Top        := cbRatioOption.Top + 37;
    lblRatio.Top      := cbRatioOption.Top + 37;
  end;

  //Change labels to suit country, assume myClient is assigned, set alternate colors
  case Country of
    whNewZealand : begin
       lblPeriodsTitle.caption := 'GST Periods:';
       lblNumber.Caption   := 'GST Number';
       lblBasis.Caption    := 'GST Basis';

       //set colors for alternate lines
       StdLineLightColor := clWindow;
       StdLineDarkColor  := bkBranding.GSTAlternateLineColor;

       tblRates.RowLimit   := MAX_GST_CLASS+1;

       pgBASRules.TabVisible := false;
       pgCalcMethod.TabVisible := false;
       pnlBASReportOptions.Visible := false;

       tblRates.Columns[ BusinessNormPercentCol].Hidden := true;
       LastVisibleCol  := AccountCol;

    end;

    whAustralia : begin
       lblPeriodsTitle.caption := 'BAS/IAS Statement Periods:';
       eGSTNumber.EditMask   := '99\ 999\ 999\ 999;0; ';
       eTFN.EditMask         := '9999999999;0; ';
       lblNumber.Caption     := 'Australian Business No';
       lblBasis.Caption      := 'GST Basis';
       lblPAYG.Visible       := true;
       cmbPAYGWithheld.Visible := true;

       eABN_Division.Visible := true;

       //set colors for alternate lines
       StdLineLightColor := clWindow;
       StdLineDarkColor  := bkBranding.GSTAlternateLineColor;

       tblRates.Columns[ TypeCol ].Hidden := True;
       tblRates.Columns[ DescCol ].Width  := 260;

       tblRates.RowLimit := MAX_GST_CLASS+1;
       LastVisibleCol := BusinessNormPercentCol;
    end;

    whUK : begin
       lblPeriodsTitle.caption := 'VAT Periods:';
       lblNumber.Caption   := 'VAT Number';
       lblBasis.Caption    := 'VAT Basis';

       //set colors for alternate lines
       StdLineLightColor := clWindow;
       StdLineDarkColor  := bkBranding.GSTAlternateLineColor;

       tblRates.RowLimit   := MAX_GST_CLASS+1;

       pgBASRules.TabVisible := false;
       pgCalcMethod.TabVisible := false;
       pnlBASReportOptions.Visible := false;

       tblRates.Columns[ BusinessNormPercentCol].Hidden := true;
       LastVisibleCol  := AccountCol;
    end;
  end;
  {load combos}
  cmbBasis.clear;
  case Country of
    whNewZealand : begin
       for i := gbMin to gbMax do cmbBasis.AddComboItem(gbNames[i], i );
       //set text of the PaymentsOn lable
       lblPaymentsOn.Caption := Format( lblPaymentsOn.caption, [ gbNames[ gbPayments]]);
    end;
    whAustralia : begin
       for i := gbMin to gbMax do cmbBasis.AddComboItem(gbaNames[i], i );
       //set text of the PaymentsOn lable
       lblPaymentsOn.Caption := Format( lblPaymentsOn.caption, [ gbaNames[ gbPayments]]);
      end;
    whUK : begin
       for i := gbUKMin to gbUKMax do cmbBasis.AddComboItem(gbuNames[i], i );
       //set text of the PaymentsOn lable
       lblPaymentsOn.Caption := Format( lblPaymentsOn.caption, [ gbuNames[ gbUKMin ]]);
    end;
  end;

  cmbStarts.Clear;
  for i := moMin to moMax do cmbstarts.AddComboItem(moNames[i], i+1);

  //monthly, bi-monthly etc.
  //note: Only Monthly and Quarterly are valid for Australia.
  //Store the period value in the object property.  Cannot use the index
  //because we will be skipping some of the period types.
  cmbPeriod.Clear;
  cmbPAYGWithheld.Clear;
  cmbPAYGInstalment.Clear;

  for i := gpMin to gpMax do begin
     case Country of
        whNewZealand : begin
           if i in [gpNone, gpMonthly, gp2Monthly, gp6Monthly] then
             cmbPeriod.AddComboItem( gpNames[i], i);
        end;
        whAustralia : begin
           if i in [gpNone, gpMonthly, gpQuarterly] then begin
              cmbPeriod.AddComboItem( gpNames[i], i );
              cmbPAYGWithheld.AddComboItem( gpNames[i], i);
           end;
           if i in [ gpNone, gpQuarterly] then
              cmbPAYGInstalment.AddComboItem( gpNames[i], i);
        end;
        whUK : begin
           if i in [gpNone, gpMonthly, gpQuarterly, gpAnnually ] then
             cmbPeriod.AddComboItem( gpNames[i], i );
        end;
     end;
  end;

  //Load GST Types combo - different for NZ and AU
  with celGSTType do begin
     Items.Clear;
     case Country of
        whNewZealand : begin
           for i := gtMin to gtMax do begin
              //exclude the undefined type.  Store the actual type in the
              //object property.  This allows the type to be independant of the
              //index.
              if i <> gtUndefined then
                 Items.AddID( gtNames[i], i );
           end;
        end;
        whUK :
          Begin
            for i := vtMin to vtMax do begin
              //exclude the undefined type.  Store the actual type in the
              //object property.  This allows the type to be independant of the
              //index.
              Items.AddID( vtNames[i] , i );
           end;

        end;
     end;
  end;

  eGSTNumber.text :='';
  eTFN.text := '';
  eABN_Division.text := '';

  if Assigned( AdminSystem) then begin
     btnDefaults.Visible := ( Country <> whAustralia);
     //check that client file belong to this admin system
     btnDefaultTax.Enabled := (AdminSystem.fdFields.fdMagic_Number = MyClient.clFields.clMagic_Number);
     btnDefaults.Enabled := (AdminSystem.fdFields.fdMagic_Number = MyClient.clFields.clMagic_Number);
  end else begin
     btnDefaults.Visible := False;
     btnDefaultTax.Visible := False;
  end;

  okPressed := false;
  EditMode := false;

  tblRates.CommandOnEnter := ccRight;

  with tblRates.Controller.EntryCommands do begin
    {remove F2 functionallity}
    DeleteCommand('Grid',VK_F2,0,0,0);
    DeleteCommand('Grid',vK_DELETE,0,0,0);

    {add our commands}
    AddCommand('Grid',VK_F2,0,0,0,tcLookup);
    AddCommand('Grid',VK_F6,0,0,0,ccTableEdit);
    AddCommand('Grid',VK_DELETE,0,0,0,tcDeleteCell);
  end;

  eDate1.Epoch       := BKDATEEPOCH;
  eDate1.PictureMask := BKDATEFORMAT;
  eDate2.Epoch       := BKDATEEPOCH;
  eDate2.PictureMask := BKDATEFORMAT;
  eDate3.Epoch       := BKDATEEPOCH;
  eDate3.PictureMask := BKDATEFORMAT;

  eDateT1.Epoch       := BKDATEEPOCH;
  eDateT1.PictureMask := BKDATEFORMAT;
  eDateT2.Epoch       := BKDATEEPOCH;
  eDateT2.PictureMask := BKDATEFORMAT;
  eDateT3.Epoch       := BKDATEEPOCH;
  eDateT3.PictureMask := BKDATEFORMAT;

{$IFDEF SmartBooks}
  Label5.Visible     := false;
  Label7.Visible     := false;
  Label8.Visible     := false;
  Label9.Visible     := false;
  eDate1.Visible     := false;
  eDate2.Visible     := false;
  eDate3.Visible     := false;
  pgReportSettings.TabVisible := False;
{$ENDIF}

  SetUpHelp;

  //set max gst id length
  colID.MaxLength := GST_CLASS_CODE_LENGTH;
  //restrict to 3 char if sol 6
  case Country of
     whNewZealand : begin
        if ( MyClient.clFields.clAccounting_System_Used in [ snSolution6MAS42, snSolution6MAS41]) then
           colID.MaxLength := 3;
     end;
     whAustralia  : begin
        if ( MyClient.clFields.clAccounting_System_Used in [ saSolution6MAS42, saSolution6MAS41]) then
           colID.MaxLength := 3;
     end;
  end; //case

  colAccount.MaxLength := MaxBk5CodeLen;
  //resize the account col so that longest account code fits
  tblRates.Columns[ AccountCol ].Width := CalcAcctColWidth( tblRates.Canvas, tblRates.Font, 100);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditGST.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   //set gst field hint
   cmbBasis.Hint    :=
                    'Select applicable '+TaxName+' Basis|' +
                    'Select which '+ TaxName+' Basis is applicable to this client';
   cmbPeriod.Hint   :=
                    'Select how often to produce the '+ TaxName+' Return|' +
                    'Select how often you want to produce the '+ TaxName+' Return for this client';
   cmbPAYGInstalment.Hint :=
                    'Select how often to report the PAYG income tax instalment|' +
                    'Select how often you want to produce the PAYG income tax instalment for this client';
   cmbPAYGWithheld.Hint :=
                    'Select how often to report the PAYG tax withheld|' +
                    'Select how often you want to produce the PAYG tax withheld for this client';
   cmbStarts.Hint   :=
                    'Select the month to start the producing the '+ TaxName+' Return|' +
                    'Select the month to start the producing the '+ TaxName+' Return';
   eDate1.Hint      :=
                    'Enter the date when this '+ TaxName+' Rate becomes effective|' +
                    'Enter the date when this '+ TaxName+' Rate becomes effective';
   eDate2.Hint      :=
                    'Enter the date when this '+ TaxName+' Rate becomes effective|' +
                    'Enter the date when this '+ TaxName+' Rate becomes effective';
   eDate3.Hint      :=
                    'Enter the date when this '+ TaxName+' Rate becomes effective|' +
                    'Enter the date when this '+ TaxName+' Rate becomes effective';
   sbtnChart.Hint   :=
                    STDHINTS.ChartLookupHint;
   chkJournals.Hint :=
                    'Check to include Accruals Journal entries in '+ TaxName+' Reports|' +
                    'Check to include Accruals Journal entries in '+ TaxName+' Reports';
   cmbEntriesBy.Hint :=
                    'Select method to classify transactions by|' +
                    'Select method to classify transactions by for the '+ TaxName+' Report';
   btnDefaults.Hint  :=
                    'Load the Default '+ TaxName+' Rates from your Practice Settings|' +
                    'Load the Default '+ TaxName+' Rates from your Practice Settings';

   case MyClient.clFields.clCountry of
      whNewZealand : begin
         eGSTNumber.Hint  := 'Enter this client''s GST Number|' +
                          'Enter this client''s Registered GST Number';
      end;

      whAustralia : begin
         eGSTNumber.Hint  := 'Enter this client''s ABN|' +
                          'Enter this client''s Australian Business Number';
         eTFN.Hint  := 'Enter this client''s TFN|' +
                          'Enter this client''s Tax File Number';
      end;
      whUK : begin
         eGSTNumber.Hint  := 'Enter this client''s VAT Number|' +
                          'Enter this client''s Registered VAT Number';
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditGST.btnOkClick(Sender: TObject);
begin
  tblRates.StopEditingState(True);
  if okToPost then begin
    okpressed := true;

    //Flag Audit
    MyClient.ClientAuditMgr.FlagAudit(arClientFiles);

    close;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.btnCancelClick(Sender: TObject);
begin
   close;
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.lsvPeriodDisplayEnter(Sender: TObject);
begin
  cmbStarts.SetFocus;
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.tblRatesGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
begin
  data := nil;

  if (RowNum > 0) and (RowNum <= MAX_GST_CLASS +1) then
  Case ColNum of
    IDCol: begin //trim id for save
       case Purpose of
          cdpForPaint : begin
             tmpPaintShortStr := Trim(GST_Table[RowNum].GST_ID);
             data := @tmpPaintShortStr;
          end;
          cdpForEdit : begin
             tmpShortStr := Trim(GST_Table[RowNum].GST_ID);
             data := @tmpShortStr;
          end;
          cdpForSave : begin
             data := @tmpShortStr;
          end;
       end;
    end;
    DescCol:
       data := @GST_Table[RowNum].GST_class_name;
    Rate1Col, Rate2Col, Rate3Col :
       data := @GST_Table[RowNum].GST_Rates[ColNum - (Rate1Col -1)];
    AccountCol:
       data := @GST_Table[RowNum].GST_Account_Code;
    TypeCol:
       data := @GST_Table[RowNum].GSTClassTypeCmbIndex;
    BusinessNormPercentCol :
       data := @GST_Table[RowNum].GST_BusinessNormPercent;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.DisplayPeriods;
var
   ListItem         : TListItem;
   i                : integer;
   tempDate         : tStDate;
   GSTPeriodType    : integer;
   PAYGInstalmentType   : integer;
   PAYGWithheldType : integer;
   SmallestPeriod   : integer;
begin
   lsvPeriodDisplay.Items.Clear;

   if ((cmbPeriod.itemIndex <= 0) and ( cmbPAYGWithheld.ItemIndex <= 0))
      or (cmbStarts.itemIndex  <= 0) then exit;
   UpdateProvisional;
   tempDate := dmyToStdate(1,cmbStarts.ItemIndex,90,BKDATEEPOCH);

   GSTPeriodType := 99;
   PAYGInstalmentType := 99;
   PAYGWithheldType := 99;

   //get the real type out of the objects property
   if ( cmbPeriod.ItemIndex > 0) then
      GSTPeriodType := cmbPeriod.IntValue;
   if ( cmbPAYGWithheld.ItemIndex > 0) then
      PAYGWithheldType := cmbPAYGWithheld.IntValue;
   if ( cmbPAYGInstalment.ItemIndex > 0) then
      PAYGInstalmentType := cmbPAYGInstalment.IntValue;

   SmallestPeriod := Min( PAYGWithheldType, Min( GSTPeriodType, PAYGInstalmentType));

   case SmallestPeriod of
    1: {monthly}
         for i := 0 to 11 do begin
{            if MyClient.clFields.clCountry = whAustralia then begin
               BasFormType := ' ' + bsNames[ BasUtils.BasIasFormType( MyClient, (i in [2,5,8,11]))];
            end
            else
               BasFormType := '';
}
            ListItem := lsvPeriodDisplay.Items.Add;
            ListItem.Caption := inttostr(i+1)+'. '+StDatetoDateString('nnn',IncDate(tempDate,0,i,0),true); { + BasFormType;}
         end;

    2: {two monthly}
      for i := 0 to 5 do
         begin
           ListItem := lsvPeriodDisplay.Items.Add;
           ListItem.Caption := inttostr(i+1)+'. '+
                               StDatetoDateString('nnn',IncDate(tempDate,0,i*2,0),true)
                               +'-'+StDatetoDateString('nnn',IncDate(tempDate,0,i*2+1,0),true);
         end;
    3: {six monthly}
      for i := 0 to 1 do
         begin
           ListItem := lsvPeriodDisplay.Items.Add;
           ListItem.Caption := inttostr(i+1)+'. '+StDatetoDateString('nnn',IncDate(tempDate,0,i*6,0),true)
                               +'-'+StDatetoDateString('nnn',IncDate(tempDate,0,i*6+5,0),true);
         end;
    4: {quarterly}
    for i := 0 to 3 do
         begin
           ListItem := lsvPeriodDisplay.Items.Add;
           ListItem.Caption := inttostr(i+1)+'. '+StDatetoDateString('nnn',IncDate(tempDate,0,i*3,0),true)
                               +'-'+StDatetoDateString('nnn',IncDate(tempDate,0,i*3+2,0),true);
         end;
     5: {annually} begin
           ListItem := lsvPeriodDisplay.Items.Add;
           ListItem.Caption := '1. ' + StDateToDateString( 'nnn', tempDate, true) +
                               '-' + StDateToDateString('nnn', IncDate( tempDate, 0, 11, 0), true);
        end;
     end; {case}
end;
//------------------------------------------------------------------------------

procedure TdlgEditGST.cmbPAYGWithheldChange(Sender: TObject);
begin
   DisplayPeriods;
end;

//------------------------------------------------------------------------------
procedure TdlgEditGST.cmbPeriodChange(Sender: TObject);
begin
   if cmbPeriod.ItemIndex <= 0 then begin
      cbProvisional.Checked := False;
      cbProvisional.Enabled := False;
   end else
      cbProvisional.Enabled := True;
   DisplayPeriods;
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.colAccountKeyPress(Sender: TObject; var Key: Char);
var
  Msg : TWMKey;
begin
   {ignore * press if editing}
   if key = '*' then key := #0;
   if key = '-' then begin
       if Assigned(myClient) and (myClient.clFields.clUse_Minus_As_Lookup_Key) then begin
         key := #0;
         Msg.CharCode := VK_F2;
         ColAccount.SendKeyToTable(Msg);
       end;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditGST.colAccountChange(Sender: TObject);
var
  Msg : TWMKey;
  EditText : ShortString;
begin
  EditText := TEdit(ColAccount.CellEditor).text;
  if Assigned(MyClient) then
  begin
     if MyClient.clChart.CanPressEnterNow(EditText) then
     begin
       TEdit(ColAccount.CellEditor).text := EditText;
       Msg.CharCode := VK_F6;
       ColAccount.SendKeyToTable(Msg);
       Msg.CharCode := VK_DOWN;
       ColAccount.SendKeyToTable(Msg);
     end;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.colAccountKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  {handle F2 while editing}
var
   msg : TWMKey;
begin
   if key = vk_f2 then
   begin
      Msg.CharCode := VK_F2;
      ColAccount.SendKeyToTable(Msg);
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.tblRatesUserCommand(Sender: TObject; Command: Word);
var
   Msg : TWmKey;
   Code : string;
begin
   case Command of
     tcLookup :
       begin
         if EditMode then
           Code := TEdit(ColAccount.CellEditor).Text
         else
           Code := GST_Table[tblRates.ActiveRow].GST_Account_Code;

         if PickAccount(Code) then
           if EditMode then
             TEdit(ColAccount.CellEditor).Text := Code
           else
           begin
             GST_Table[tblRates.ActiveRow].GST_Account_Code := Code;
             Msg.CharCode := VK_RIGHT;
             ColAccount.SendKeyToTable(Msg);
           end;
       end;
     tcDeleteCell :  DoDeleteCell;
   end;
end;

procedure TdlgEditGST.UpdateProvisional;
begin
   if cbProvisional.Visible then begin
      // Must be NZ


      if cbProvisional.Checked then begin
         if (cmbPeriod.ItemIndex > 0) then begin
            if  ( cmbPeriod.IntValue  in [gpMonthly, gp2Monthly] ) then
               // Can have Ratio
               cbRatioOption.Enabled := True
            else begin
               // 6 Monthly (or None)
               // Can't have Ratio
               cbRatioOption.Enabled := False;
               cbRatioOption.Checked := False;
            end;
         end;
      end else begin
         // No Provisional, No Ratio
         cbRatioOption.Enabled := False;
         cbRatioOption.Checked := False;
      end;
      cbratioOptionClick(nil);// Sort the rest
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditGST.tblRatesExit(Sender: TObject);
begin
   btnOk.Default := true;
   btnCancel.Cancel := true;
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.tblRatesBeginEdit(Sender: TObject; RowNum,
  ColNum: Integer; var AllowIt: Boolean);
begin
   EditMode := true;
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.tblRatesEndEdit(Sender: TObject;
  Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
  var AllowIt: Boolean);
begin
   EditMode := false;
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.tblRatesActiveCellMoving(Sender: TObject;
  Command: Word; var RowNum, ColNum: Integer);
begin
   if (Command = ccRight) and ( tblRates.ActiveCol = LastVisibleCol) then
      if RowNum < tblRates.RowLimit then begin
        Inc(RowNum);
        ColNum := FirstCol;
      end;
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.tblRatesActiveCellChanged(Sender: TObject; RowNum,
  ColNum: Integer);
var
   HintText : string;
begin
  case ColNum of
  IDCol:
     HintText   := 'Enter a short ID for this class (up to '+ inttostr(GST_CLASS_CODE_LENGTH)+' chars)';
  DescCol:
     HintText   := 'Enter a description for this class, eg. Exempt, '+ TaxName+' Income';
  Rate1Col, Rate2Col, Rate3Col:
     HintText   := 'Enter the '+ TaxName+' rate for this class.';
  AccountCol:
     HintText   := 'Enter the Account Code to which this class should be posted.';
  BusinessNormPercentCol:
     HintText   := 'Enter the Business Norm Percentage associated with this class.';     
  end;

  tblRates.Hint := HintText;
  MsgBar(HintText,false);
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.DoDeleteCell;
//Pressing Delete key while not in Editing mode should delete the content of the
//current cell.  Note that this routine can't be called while Edit mode is selected
//as key stroke will be processed by the cell
var
   cdTableCell    : TOvcBaseTableCell;
begin
   with tblrates do begin
      if not StartEditingState then Exit;
      cdTableCell := Columns[ ActiveCol ].DefaultCell;
         if (cdTableCell is TOvcTCString) then begin
            TEdit(cdTableCell.CellEditor).Text := '';
         end;
         if cdTableCell is TOvcTCPictureField then begin
            TOvcTCPictureFieldEdit( cdTableCell.CellEditor).AsString := '';
         end;
         if cdTableCell is TOvcTCNumericField then begin
           //setting by variant no longer seems to work in orpheus 4
           if TOvcNumericField( cdTableCell.CellEditor).DataType = nftDouble then
             TOvcNumericField( cdTableCell.CellEditor).AsFloat := 0.0
           else if TOvcNumericField( cdTableCell.CellEditor).DataType = nftLongInt then
             TOvcNumericField( cdTableCell.CellEditor).AsInteger := 0
           else
             TOvcNumericField( cdTableCell.CellEditor).AsVariant := 0;
         end;
         if cdTableCell is TOvcTCComboBox then begin
            TComboBox( cdTableCell.CellEditor).ItemIndex := -1;
         end;
      StopEditingState( True );
   end;
end;
procedure TdlgEditGST.EDateT1DblClick(Sender: TObject);
var ld: Integer;
begin
   if sender is TOVcPictureField then begin
      ld := TOVcPictureField(Sender).AsStDate;
      PopUpCalendar(TEdit(Sender),ld);
      TOVcPictureField(Sender).AsStDate := ld;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditGST.sbtnChartClick(Sender: TObject);
begin
  tblRates.ActiveCol := AccountCol;
  keybd_event(vk_f2,0,0,0);
  tblRates.SetFocus;
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.tblRatesEnter(Sender: TObject);
begin
   btnOk.Default    := false;
   btnCancel.Cancel := false;
end;
//------------------------------------------------------------------------------
function TdlgEditGST.OKtoPost: boolean;
  var D1, D2: Integer;

    function ValidateABN( ABN : string) : boolean;
    {
      To verify an ABN  ( From ATO Document)

      1)  Subtract 1 from the first left digit to give a new eleven digit number
      2)  Multiply each of the digits in this new number by its weighting factor
      3)  Sum the resulting 11 products
      4)  Divide the total by 89
      5)  if the remainder is zero then number is valid
    }
    const
       Weighting : Array [ 1..11] of integer = ( 10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19 );
    var
       ABN_Digits : Array[ 1..11] of integer;
       Sum : integer;
       i   : integer;

    begin
       result := false;
       //check length
       if Length( ABN) <> 11 then exit;

       //check all char are numeric
       if not (IsNumeric( ABN)) then exit;

       //load string into digits
       for i := 1 to 11 do begin
          ABN_Digits[ i] := Ord( ABN[ i]) - 48;
       end;
       //subtract 1
       Dec( ABN_Digits[ 1]);
       //multiply and add
       Sum := 0;
       for i := 1 to 11 do begin
          Sum := Sum + ( ABN_Digits[ i] * Weighting[ i]);
       end;
       //check the remainder is zero
       if ( Sum mod 89) <> 0 then exit;

       result := true;
    end;



  procedure FocusMessage(Control: TWinControl; Page: tTabSheet; Msg: String);
  begin
     pcGST.ActivePage := Page;
     Control.SetFocus;
     HelpfulWarningMsg( Msg, 0);
  end;

  function FailRate(Edit: TOvcPictureField): Boolean;
  var lr: Double;
  begin
     Result := True;
     lr := Edit.AsFloat;
     if lR <= 0 then begin
        FocusMessage(Edit,tsTaxRates,'Please enter a tax rate greater than zero.');
        Exit;
     end;
     if lR >= 100 then begin
        FocusMessage(Edit,tsTaxRates,'Please enter a tax rate less than 100%.');
        Exit;
     end;
     Result := False;
  end;

var
  i,j : integer;
begin
   result := false;

   for i := 1 to MAX_GST_CLASS do begin
      //trim all gst_id's
      GST_Table[i].GST_ID := Trim( GST_Table[i].GST_ID);
   end;

   //check that there are no duplicates GST Rates IDs, ignore blanks
   for i := 1 to MAX_GST_CLASS do
      if GST_Table[i].GST_ID <> '' then begin
         for j := (i+1) to MAX_GST_CLASS do
            if (UpperCase( GST_Table[i].GST_ID) = UpperCase( GST_Table[j].GST_ID)) then begin
               //duplicate found
               HelpfulWarningMsg(TaxName + ' ID "'+Gst_Table[i].GST_ID+'" has been used for more than one '+ TaxName+' class.  Each ID MUST be unique.',0);
               exit;
            end;
      end;

   //validate ABN
   if MyClient.clFields.clCountry = whAustralia then begin
      if ( eGSTNumber.Text <> '') then begin
         if  not ValidateABN( eGSTNumber.text) then begin
            FocusMessage(eGSTNumber, pgDetails, 'Your Australian Business Number (ABN) is invalid.  Please re-enter it.');
            //make sure on correct page before doing set focus, otherwise error occurs
            exit;
         end;
      end;
   end;

   // Check the Tax Rates;
  D1 := StNull2Bk(eDateT1.AsStDate);
  if D1 > 0 then begin
     if FailRate(eRate1) then
        Exit;

     d2 := StNull2Bk(eDateT2.AsStDate);
     if (d2 > 0) then begin
        if (d2< d1) then begin
           FocusMessage(eDateT2,tsTaxRates,'Please enter a date later than Rate 1.');
           Exit;
        end;
        if FailRate(eRate2) then
           Exit;
     end else begin
        if eRate2.AsFloat <> 0 then begin
           FocusMessage(eDateT2,tsTaxRates,'Please enter a valid date.');
           Exit;
        end;
     end;
     d1 := d2;
     d2 := StNull2Bk(eDateT3.AsStDate);
     if (d2 > 0) then begin
        if d1 = 0 then begin
           FocusMessage(eDateT2,tsTaxRates,'Please use Rate 2 first.');
           exit;
        end;

        if (d2< d1) then begin
           FocusMessage(eDateT3,tsTaxRates,'Please enter a date later than Rate 2.');
           exit;
        end;
        if FailRate(eRate3) then
           Exit;
     end else begin
        if eRate3.AsFloat <> 0 then begin
           FocusMessage(eDateT3,tsTaxRates,'Please enter a valid date.');
           Exit;
        end;
     end;
  end else begin
     d2 := StNull2Bk(eDateT2.AsStDate);
     if d2 > 0 then begin
        FocusMessage(eDateT1,tsTaxRates,'Please use Rate 1 first.');
        Exit;
     end;
     d2 := StNull2Bk(eDateT3.AsStDate);
     if d2 > 0 then begin
        FocusMessage(eDateT1,tsTaxRates,'Please use Rate 1 first.');
        Exit;
     end;
     if eRate1.AsFloat <> 0 then begin
        FocusMessage(eDateT1,tsTaxRates,'Please enter a valid date.');
        Exit;
     end;
     if eRate2.AsFloat <> 0 then begin
        FocusMessage(eDateT1,tsTaxRates,'Please use Rate 1 first.');
        Exit;
     end;
     if eRate3.AsFloat <> 0 then begin
        FocusMessage(eDateT1,tsTaxRates,'Please use Rate 1 first.');
        Exit;
     end;

  end;


   result := true;
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.tblRatesGetCellAttributes(Sender: TObject; RowNum,
  ColNum: Integer; var CellAttr: TOvcCellAttributes);
begin
   if (CellAttr.caColor = tblRates.Color) and (RowNum >= tblRates.LockedRows) then begin
      if Odd(RowNum) then
         CellAttr.caColor := StdLineLightColor
      else
         CellAttr.caColor := StdLineDarkColor;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditGST.cbProvisionalClick(Sender: TObject);
begin
  UpdateProvisional;
end;

procedure TdlgEditGST.cbRatioOptionClick(Sender: TObject);
begin
   if cbRatioOption.Checked then begin
      ERatio.Enabled := True;
      lblRatio.Enabled := True;
   end else begin
      ERatio.Enabled := False;
      lblRatio.Enabled := False;
      ERatio.AsFloat := 0;
   end;
end;

procedure TdlgEditGST.celGSTTypeDropDown(Sender: TObject);
begin
   //try to set default drop down width
   SendMessage(celGSTType.EditHandle, CB_SETDROPPEDWIDTH, 300, 0);
end;
procedure TdlgEditGST.chkIncludeFuelClick(Sender: TObject);

  function FindNode(s: string): TTreeNode;
  var
    i: Integer;
    N: TTreeNode;
  begin
    Result := nil;
    with BasTV do begin
       for i := 0 to Pred( Items.Count) do begin
          N := Items[ i];
          if N.Text = s then
          begin
            Result := N;
            exit;
          end;
       end;
    end;
  end;

var
   N1, N2: TTreeNode;
begin
  chkDontPrintFuel.Enabled := chkIncludeFuel.Checked;
  N2 := FindNode(bfFieldIDs[ bf7d ] + ': ' + bfNames[ bf7d ]);
  if chkIncludeFuel.Checked and (not Assigned(N2)) then // add it, if not there
  begin
    N1 := FindNode('Totals');
    if Assigned(N1) then
    begin
      N2 := BASTV.Items.AddChild( N1, bfFieldIDs[ bf7d ] + ': ' + bfNames[ bf7d ] );
      N2.Data := Pointer( bf7d );
      AddNodesForBASField( N2, bf7d );
    end;
  end
  else if (not chkIncludeFuel.Checked) and Assigned(N2) then // remove it
    N2.Delete;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditGST.tblRatesDoneEdit(Sender: TObject; RowNum,
  ColNum: Integer);
//Occurs after ReadCellForSave
//Save the current edited field and update any fields affected by this change

//In the table only the ID col should get here, all other fields are updated
//directly.  This reason for the ID col being saved this was is so that it can be
//trimmed.
begin
   if (RowNum > 0) and (RowNum <= MAX_GST_CLASS +1) then
   Case ColNum of
      IDCol: begin //trim id for save
         GST_Table[RowNum].GST_ID := Trim( tmpShortStr);
      end;
   end;
end;
//------------------------------------------------------------------------------
function TdlgEditGST.Execute: boolean;
var
   ClassNo,
   RateNo   : integer;
   i        : integer;
   DashPos  : integer;
   Node     : TTreeNode;
   ArrayPos : integer;
   V        : Double;
   MethodChanged, UserState: Boolean;
begin
   Result := false;
   Editmode := false;
   if not Assigned(myClient) then
      Exit;

   if cmbBasis.Items.Count > 0 then
      cmbBasis.ItemIndex := 0;
   if cmbPeriod.Items.Count > 0 then
      cmbPeriod.ItemIndex := 0;
   if cmbStarts.Items.Count > 0 then
      cmbStarts.ItemIndex := 0;
   if cmbPAYGWithheld.Items.Count > 0 then
      cmbPAYGWithheld.ItemIndex := 0;
   if cmbPAYGInstalment.Items.Count > 0 then
      cmbPAYGInstalment.ItemIndex := 0;

   {assign current settings}
   with Myclient, clFields, clExtra do begin
     //the clGST_Number contains two parts - the ABN and the ABN division a dash ( - ) is used
     //as the delimiter
     case clCountry of
        whNewZealand :
          begin
            tsTaxRates.TabVisible := False;
            eGSTNumber.text := clGST_Number;
            // While we are here do the Provisional bits..
            cbProvisional.Checked := clBAS_Field_Source[bfGSTProvisional] = GSTprovisional;
            cbRatioOption.Checked := clBAS_Field_Number[bfGSTProvisional] = GSTRatio;
            V := clBAS_Field_Percent[bfGSTProvisional] / 10;
            ERatio.AsFloat := V;
            UpdateProvisional;
          end;
        whAustralia  :
          begin
            dashPos := Pos( '-' , clGST_Number);
            if dashPos > 0 then begin
              eGSTNumber.Text := Copy( clGST_Number, 1, dashPos -1);
              eABN_Division.Text := Copy ( clGST_Number, dashPos + 1, length( clGST_Number));
            end
            else
              eGSTNumber.Text := clGST_Number;

            eTFN.Text := clTFN;

            // Double check defaults
            if ceTAX_Applies_From[tt_CompanyTax][1] < 146644 then begin
              ceTAX_Applies_From[tt_CompanyTax][1] := 146644;
              ceTAX_Rates[tt_CompanyTax][1] := Double2CreditRate(30.0);
            end;
            eDateT1.AsStDate :=   BKNull2St(ceTAX_Applies_From[tt_CompanyTax][1]);
            eDateT2.AsStDate :=   BKNull2St(ceTAX_Applies_From[tt_CompanyTax][2]);
            eDateT3.AsStDate :=   BKNull2St(ceTAX_Applies_From[tt_CompanyTax][3]);
            eRate1.AsFloat   :=   GSTRate2Double(ceTAX_Rates[tt_CompanyTax][1]);
            eRate2.AsFloat   :=   GSTRate2Double(ceTAX_Rates[tt_CompanyTax][2]);
            eRate3.AsFloat   :=   GSTRate2Double(ceTAX_Rates[tt_CompanyTax][3]);
          end;
        whUK :
          begin
            tsTaxRates.TabVisible := False;
            eGSTNumber.text := clGST_Number;
          end;
     end;

     cmbBasis.IntValue := clGST_Basis;

     if clGST_Start_Month in [moMin..moMax] then
        cmbStarts.itemIndex := clGST_Start_Month;
     //go thru cmb trying to find a items with the object value equal to client setting

     cmbPeriod.IntValue := clGST_Period;
     if cmbPeriod.ItemIndex <= 0 then begin
        cbProvisional.Checked := False;
        cbProvisional.Enabled := False;
     end else
        cbProvisional.Enabled := True;

     //go thru cmb trying to find a items with the object value equal to client setting
     cmbPAYGWithheld.IntValue := clBAS_PAYG_Withheld_Period;

     cmbPAYGInstalment.IntValue := clBAS_PAYG_Instalment_Period;

     chkIncludeFBT.Checked := clBAS_Include_FBT_WET_LCT;
     chkIncludeFuel.Checked := clBAS_Include_Fuel;

     DisplayPeriods;

     {load dates}
     eDate1.AsStDate := BkNull2St(clGST_Applies_From[1]);
     eDate2.AsStDate := BkNull2St(clGST_Applies_From[2]);
     eDate3.AsStDate := BkNull2St(clGST_Applies_From[3]);

     {load table}
     FillChar(GST_Table,Sizeof(GST_Table),#0);

     For ClassNo := 1 to MAX_GST_CLASS do With GST_Table[ClassNo] do begin
        //load gst id's from delimited string
        GST_ID            := clGST_Class_Codes[ClassNo];
        GST_Class_Name    := clGST_Class_Names[ClassNo];
        For RateNo := 1 to MAX_VISIBLE_GST_CLASS_RATES do GST_Rates[ RateNo ] := GSTRate2Double( clGST_Rates[ ClassNo, RateNo ] );
        GST_Account_Code  := trim(clGST_Account_Codes  [ ClassNo ]);
        //load current combo indexes.  Only the combo index for the current type will be stored because
        //this is easy to manipulate in the grid.  The index can then be converted back to the
        //actual type value before saving.
        //find index of combo item which has the object value = gst type
        GSTClassTypeCmbIndex := celGSTType.Items.IndexOfID( clGST_Class_Types[ClassNo] );
        GST_BusinessNormPercent := Money2Double( clGST_Business_Percent[ ClassNo]);
     end;
   end;
   //set check box status in rates
   Self.cmbBasisChange( nil);
   //Report Options
   with MyClient.clFields do begin
     //must set this after all changes to cmbBasis as the onChange event sets this.
     chkJournals.Checked := not (clGST_Excludes_Accruals);
     if clGST_on_Presentation_Date then
        cmbEntriesBy.ItemIndex := 1
     else
        cmbEntriesBy.ItemIndex := 0;
   end;

{$IFNDEF SmartBooks}
   //Build BAS Field form
   SetupBASRulesPage;

   //Load calculation method page
   case MyClient.clFields.clBAS_Calculation_Method of
      bmFull : rbFull.Checked := true;
      bmSimplified : rbSimple.Checked := true;
   end;
   pnlMethodWarning.Visible := rbSimple.Checked;

   chkDontPrintCS.Checked := MyClient.clFields.clBAS_Dont_Print_Calc_Sheet;
   chkDontPrintFuel.Checked := MyClient.clMoreFields.mcBAS_Dont_Print_Fuel_Sheet;
   chkDontPrintFuel.Enabled := chkIncludeFuel.Checked;

   rbATOBas.Checked := false;
   rbOnePageBAS.Checked := false;

   case MyClient.clFields.clBAS_Report_Format of
     0 : rbATOBas.Checked := true;
     1 : rbOnePageBAS.Checked := true;
   else
     rbATOBas.Checked := true;
   end;

{$ENDIF}
//*********************************
   Self.ShowModal;
//*********************************

   if okPressed then begin
     //save new values
     with Myclient, clFields, clMoreFields, clextra do
     begin
        {details}
        case clCountry of
           whNewZealand :  begin
                       clGst_Number := eGSTNumber.text;
                       // Do The provisional Tax While we are here..
                       if cbProvisional.Checked then
                          clBAS_Field_Source[bfGSTProvisional] := GSTprovisional
                       else
                          clBAS_Field_Source[bfGSTProvisional] := 0;

                       if cbRatioOption.Checked then
                          clBAS_Field_Number[bfGSTProvisional] := GSTRatio
                       else
                          clBAS_Field_Number[bfGSTProvisional] := 0;

                       clBAS_Field_Percent[bfGSTProvisional] := Round(ERatio.AsFloat * 10)

                  end;
           whAustralia  :  begin
              if eABN_Division.text = '' then
                 clGST_Number := eGSTNumber.Text
              else
                 clGst_Number := eGSTNumber.Text + '-' + eABN_Division.Text;
              clTFN := eTFN.Text;
              ceTAX_Applies_From[tt_CompanyTax][1] := StNull2Bk(eDateT1.AsStDate);
              ceTAX_Applies_From[tt_CompanyTax][2] := StNull2Bk(eDateT2.AsStDate);
              ceTAX_Applies_From[tt_CompanyTax][3] := StNull2Bk(eDateT3.AsStDate);
              ceTAX_Rates[tt_CompanyTax][1] := Double2GSTRate(eRate1.AsFloat);
              ceTAX_Rates[tt_CompanyTax][2] := Double2GSTRate(eRate2.AsFloat);
              ceTAX_Rates[tt_CompanyTax][3] := Double2GSTRate(eRate3.AsFloat);
           end;
           whUK :
            begin
              clGST_Number := eGSTNumber.Text
            end;
        end;

        if (cmbBasis.ItemIndex <> -1)  then clGST_Basis  := cmbBasis.ItemIndex;
        if (cmbPeriod.ItemIndex <> -1) then clGST_Period := cmbPeriod.IntValue;
        if (cmbPAYGWithheld.ItemIndex <> -1) then clBAS_PAYG_Withheld_Period := Integer(cmbPAYGWithheld.Items.Objects[cmbPAYGWithheld.ItemIndex]);
        if (cmbStarts.ItemIndex <> -1) then clGST_Start_Month := cmbStarts.ItemIndex;
        if (cmbPAYGInstalment.ItemIndex <> -1) then clBAS_PAYG_Instalment_Period := cmbPAYGInstalment.IntValue;

        clBAS_Include_FBT_WET_LCT := chkIncludeFBT.Checked;
        clBAS_Include_Fuel := chkIncludeFuel.Checked;

        {save dates}
        clGST_Applies_From[1] := StNull2Bk(eDate1.AsStDate);
        clGST_Applies_From[2] := StNull2Bk(eDate2.AsStDate);
        clGST_Applies_From[3] := StNull2Bk(eDate3.AsStDate);

        {table}
        For ClassNo := 1 to MAX_GST_CLASS do With GST_Table[ClassNo] do begin
           clGST_Class_Names[ClassNo] := GST_Class_Name;
           clGST_Class_Codes[ClassNo] := GST_ID;
           For RateNo := 1 to 3 do clGST_Rates[ ClassNo, RateNo ] := Double2GSTRate(GST_Rates[ RateNo ]);
           clGST_Account_Codes  [ ClassNo ] := GST_Account_Code;
           //set the type value, default to undefined
           case clCountry of
              whNewZealand : clGST_Class_Types[ClassNo] := gtUndefined;
           end;
           //convert from cmb index back to type.  Use the object value, this is where
           //the real type was stored
           if GSTClassTypeCmbIndex <> -1 then
              clGST_Class_Types[ClassNo] := Integer( celGSTType.Items.Objects[ GSTClassTypeCmbIndex]);
           //business norm percentage
           clGST_Business_Percent[ ClassNo] := Double2Money( GST_BusinessNormPercent);
        end;
        //Store Report Options
        //test the enabled state because the check value is not cleared when disabling the checkbox
        //value is only cleared on the save.
        clGST_Excludes_Accruals :=  not (chkJournals.Checked and chkJournals.enabled);
        if cmbEntriesBy.itemIndex = 0 then
           clGST_on_Presentation_Date := FALSE
        else
           clGST_on_Presentation_Date := TRUE;

        clBAS_Dont_Print_Calc_Sheet  := chkDontPrintCS.Checked;
        mcBAS_Dont_Print_Fuel_Sheet  := chkDontPrintFuel.Checked;

        if rbOnePageBAS.Checked then
          clBAS_Report_Format := 1
        else
          clBAS_Report_Format := 0;

{$IFNDEF SmartBooks}
        //Save Tree View back into BAS Field Arrays
        // Always save 7D
        if clCountry = whAustralia then begin

        UserState := chkIncludefuel.Checked;
        if not UserState then
          chkIncludefuel.Checked := True;
        BasUtils.ClearAll;
        ArrayPos := 0;
        //Go sequentially thru items looking a level 2 items only
        with BasTV do begin
           for i := 0 to Pred( Items.Count) do begin
              Node := Items[ i];
              if Node.Level = 2 then with pBasAccumulatorInfo( Node.Data)^ do begin
                 Inc( ArrayPos);
                 if ArrayPos <= MAX_SLOT then begin
                    clBAS_Field_Number[ ArrayPos]       := FieldNo;
                    clBAS_Field_Source[ ArrayPos]       := Source;
                    clBAS_Field_Account_Code[ ArrayPos] := AccountCode;
                    clBAS_Field_Balance_Type[ ArrayPos] := BalanceType;
                    clBAS_Field_Percent[ ArrayPos]      := Percent;
                 end;
              end;
           end;
        end;
        if not UserState then
          chkIncludefuel.Checked := False;
        end;
{$ENDIF}

        //store calculation method
        if rbFull.Checked then
        begin
           MethodChanged := clBAS_Calculation_Method <> bmFull;
           clBAS_Calculation_Method := bmFull
        end
        else
        begin
           MethodChanged := clBAS_Calculation_Method <> bmSimplified;
           clBAS_Calculation_Method := bmSimplified;
        end;
        if MethodChanged then
          ReloadCodingScreens;
     end; {with}
   end;
   result := okPressed;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditGST.cmbBasisChange(Sender: TObject);
begin
   //disable include accruals if payments/cash basis selected
   chkJournals.enabled := ( cmbBasis.ItemIndex = gbInvoice);
   lblPaymentsOn.visible := not chkJournals.enabled;

   if cmbBasis.ItemIndex = gbInvoice then
      chkJournals.Checked := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditGST.btnDefaultsClick(Sender: TObject);
//reload the gst values from the practice settings, overwriting current settings
//assumes that admin system is loaded.  button would not be visible otherwise
var
   classNo         : integer;
   RateNo          : integer;
begin
   //stop any editing state - ignore change
   if not tblRates.StopEditingState( false) then exit;
   //reload admin system to get current values
   RefreshAdmin;
   //turn off updating
   tblRates.AllowRedraw := false;
   try
      //reload cells from admin system settings
      with AdminSystem.fdFields do begin
        {load dates}
        eDate1.AsStDate := BkNull2St(fdGST_Applies_From[1]);
        eDate2.AsStDate := BkNull2St(fdGST_Applies_From[2]);
        eDate3.AsStDate := BkNull2St(fdGST_Applies_From[3]);

        For ClassNo := 1 to MAX_GST_CLASS do With GST_Table[ClassNo] do begin
           //load gst id's from delimited string
           GST_ID := fdGST_Class_Codes[ ClassNo];
           GST_Class_Name    := fdGST_Class_Names[ClassNo];
           For RateNo := 1 to MAX_VISIBLE_GST_CLASS_RATES do GST_Rates[ RateNo ] := GSTRate2double( fdGST_Rates[ ClassNo, RateNo ] );
           GST_Account_Code  := trim(fdGST_Account_Codes  [ ClassNo ]);
           //load current combo indexes.  Only the combo index for the current type will be stored because
           //this is easy to manipulate in the grid.  The index can then be converted back to the
           //actual type value before saving.
           //find index of combo item which has the object value = gst type
           GSTClassTypeCmbIndex := celGSTType.Items.IndexOfID( fdGST_Class_Types[ClassNo] );
        end;
      end;
   finally
      //turn on updating and do refresh;
      tblRates.AllowRedraw := true;
      tblRates.Refresh;
   end;
end;
procedure TdlgEditGST.btndefaultTaxClick(Sender: TObject);
begin
   if not assigned(AdminSystem) then
      Exit;
   with AdminSystem.fdFields do begin
   // Double check defaults
       if fdTAX_Applies_From[tt_CompanyTax][1] < 146644 then begin
           Adminsystem.fdFields.fdTAX_Applies_From[tt_CompanyTax][1] := 146644;
           fdTAX_Rates[tt_CompanyTax][1] := Double2CreditRate(30.0);
       end;

       eDateT1.AsStDate :=   BKNull2St(fdTAX_Applies_From[tt_CompanyTax][1]);
       eDateT2.AsStDate :=   BKNull2St(fdTAX_Applies_From[tt_CompanyTax][2]);
       eDateT3.AsStDate :=   BKNull2St(fdTAX_Applies_From[tt_CompanyTax][3]);
       eRate1.AsFloat  :=   GSTRate2Double(fdTAX_Rates[tt_CompanyTax][1]);
       eRate2.AsFloat  :=   GSTRate2Double(fdTAX_Rates[tt_CompanyTax][2]);
       eRate3.AsFloat  :=   GSTRate2Double(fdTAX_Rates[tt_CompanyTax][3]);
   end;
end;

//------------------------------------------------------------------------------
{$IFNDEF SmartBooks}
{
  The code below here is for the events fired by controls that are not needed
  in Smartbooks.  It is clearer to put these events into ONE conditional define
  rather than have multiple defines within each procedure.
}
//------------------------------------------------------------------------------
procedure TdlgEditGST.pcGSTChange(Sender: TObject);
var
   i : integer;
begin
   if pcGST.ActivePage = pgBASRules then begin
      //reload descriptions for node with latest gst descriptions
      with BASTV do begin
         for i := 0 to Pred( Items.Count) do
            UpdateBASSlotDesc( Items[ i]);
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgEditGST.btnAddAccountClick(Sender: TObject);
//must be at a level 1 node to add something
Var
   Node       : TTreeNode;
   BASFieldNo : LongInt;
   Code       : String;
   TotalType  : byte;
   Percent    : Money;
begin
   if Assigned( BASTV.Selected) then begin
      Node := BASTV.Selected;
      //if at level 0 then expand branch
      if ( Node.Level = 0 ) and ( not Node.Expanded ) then begin
         Node.Expand( True );
         exit;
      end;
      //see if there is any space
      if SlotCount = BasUtils.MAX_SLOT then begin
         HelpfulInfoMsg( 'Unable to add new '+ TaxName+' Class.  You have reach the limit of 100 Classes and Account Codes.',0);
         exit;
      end;
      //cant add items to level 2, must add into a box ie level 1 so reassign node to parent
      if Node.Level = 2 then
         Node := Node.Parent;
      //must be at level 1 now, so data pointer to an integer of the field no
      BASFieldNo := LongInt( Node.Data );

      if BASFieldNo in [ bfMin..bfMax ] then begin
         Code := '';
         if PickAccountForBAS( Node.Text, Code, TotalType, Percent, BASFieldNo <> bf7d) then With MyClient.clFields do begin
            if SlotCount < BasUtils.MAX_SLOT then begin
               //create a new node and fill with data
               AddNewSlotNode( Node,
                               BasFieldNo,
                               bsFrom_Chart,
                               Code,
                               TotalType,
                               Percent);
               //make sure new node can be seen under parent
               Node.Expand( true);
            end;
            { No room to add any more accounts }
         end;
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgEditGST.btnAddTaxLevelClick(Sender: TObject);
Var
   Node         : TTreeNode;
   ClassNo,
   BASFieldNo   : LongInt;
   GSTClass     : Integer;
   TotalType    : byte;
   CurrentGSTClassList :TStringList;
   Percent      : Money;
begin
   if Assigned( BASTV.Selected) then begin
      Node := BASTV.Selected;
      //if at level 0 then expand branch
      if ( Node.Level = 0 ) and ( not Node.Expanded ) then begin
         Node.Expand( True );
         exit;
      end;
      //see if there is any space
      if SlotCount = BasUtils.MAX_SLOT then begin
         HelpfulInfoMsg( 'Unable to add new '+ TaxName+' Class.  You have reach the limit of 100 Classes and Account Codes.',0);
         exit;
      end;
      //cant add items to level 2, must add into a box ie level 1 so reassign node to parent
      if Node.Level = 2 then
         Node := Node.Parent;
      //must be at level 1 now, so data pointer to an integer of the field no
      BASFieldNo := LongInt( Node.Data );
      if BASFieldNo in [ bfMin..bfMax ] then begin
         //need to build a list of the CURRENT gst classes.  The client record will not be updated until
         //the edit gst dlg closes so we need to use the values directly that the grid uses
         CurrentGSTClassList := TStringList.Create;
         try
            for ClassNo := 1 to MAX_GST_CLASS do With GST_Table[ClassNo] do begin
               if ( GST_Class_Name <> '') and ( GST_ID <> '') then
                  CurrentGSTClassList.AddObject( GST_ID + ' ' + GST_Class_Name, TObject( ClassNo));
            end;
            if PickGSTClassForBAS( Node.Text, CurrentGSTClassList, GSTClass, TotalType, Percent) then With MyClient.clFields do begin
               if SlotCount < BasUtils.MAX_SLOT then begin
                  //create a new node and fill with data
                  AddNewSlotNode( Node,
                                  BasFieldNo,
                                  GSTClass,
                                  '',
                                  TotalType,
                                  Percent);
                  //make sure new node can be seen under parent
                  Node.Expand( true);
               end;
               {no room to add any mode items}
            end;
         finally
            CurrentGSTClassList.Free;
         end;

      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgEditGST.btnDeleteClick(Sender: TObject);
Var
   Node         : TTreeNode;
   pBA          : pBasAccumulatorInfo;
begin
   if BASTV.Selected<>NIL then begin
      Node := BASTV.Selected;
      if Node.Level <> 2 then exit; //cant delete other levels
      //free memory for node and delete it
      pBA := pBasAccumulatorInfo( Node.Data);
      Node.Data := nil;
      Dispose( pBA);
      BasTV.Items.Delete( Node);
      Dec( SlotCount);
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgEditGST.BASTVCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
var
   pBA        : pBasAccumulatorInfo;
begin
   with BASTV.Canvas do begin
    //if DefaultDraw it is true, any of the node's font properties can be
    //changed. Note also that when DefaultDraw = True, Windows draws the
    //buttons and ignores our font background colors, using instead the
    //TreeView's Color property.
    if Node.Level = 0 then begin
       Font.Style := [fsBold];
    end;

    if (cdsSelected in State) then exit;

    if Node.Level = 2 then begin
       pBA := pBASAccumulatorInfo( Node.Data);
       if pBA^.Source = bsFrom_Chart then
             Font.Color := clGreen
          else begin
             Font.Color := clNavy;
          end;
    end;
    DefaultDraw := true;
  end;
end;
//------------------------------------------------------------------------------

procedure TdlgEditGST.FormDestroy(Sender: TObject);
var
   pBA   : pBasAccumulatorInfo;
   i     : integer;
   Node  : TTreeNode;
begin
   //free memory associated with any remaining data pointers in the tree view
        //Go sequentially thru items looking a level 2 items only
        with BasTV do begin
           for i := 0 to Pred( Items.Count) do begin
              Node := Items[ i];
              if Node.Level = 2 then begin
                 pBA := pBasAccumulatorInfo( Node.Data);
                 Node.Data := nil;
                 Dispose( pBA);
              end;
           end;
        end;
end;
procedure TdlgEditGST.Label12Click(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------
{$ELSE}
{
  Stub routines are provided for smartbooks so that the events can still be
  associated with the controls at design time.  Otherwise we would need conditional
  defines in the dfm file also.
}
//------------------------------------------------------------------------------
procedure TdlgEditGST.FormDestroy(Sender: TObject);
begin
   //
end;

procedure TdlgEditGST.btnAddTaxLevelClick(Sender: TObject);
begin
   //
end;

procedure TdlgEditGST.btnAddAccountClick(Sender: TObject);
begin
   //
end;

procedure TdlgEditGST.btnDeleteClick(Sender: TObject);
begin
   //
end;

procedure TdlgEditGST.pcGSTChange(Sender: TObject);
begin
   //
end;

procedure TdlgEditGST.BASTVCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
   //
end;

//------------------------------------------------------------------------------
{$ENDIF}
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
function EditGSTDetails(ContextID : Integer) : boolean;
var
  MyDlg : TdlgEditGST;
begin
  result := false;
  if not Assigned(myClient) then exit;

  MyDlg := TdlgEditGst.Create(Application.MainForm);
  try
     BKHelpSetUp(MyDlg, ContextID);
     MyDlg.pcGST.ActivePage := MyDlg.pgDetails;
     if MyDlg.Execute then begin
        Result := true;
        //update gst values for client
        GSTUTIL32.ApplyDefaultGST( false);
     end;
  finally
    MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------

procedure TdlgEditGST.rbSimpleClick(Sender: TObject);
begin
   pnlMethodWarning.Visible := rbSimple.Checked;
end;
//------------------------------------------------------------------------------
procedure TdlgEditGST.colAccountOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
  IsValid : boolean;
  pAcct   : pAccount_Rec;
begin
  If ( data = nil ) then exit;
  //if selected dont do anything
  if CellAttr.caColor = clHighlight then exit;
  S := ShortString( Data^ );

  pAcct   := MyClient.clChart.FindCode( S);
  IsValid := Assigned( pAcct) and
             (pAcct^.chAccount_Type in [ atGSTReceivable, atGSTPayable]) and
             pAcct^.chPosting_Allowed;

  If ( S = '') or IsValid then exit;

  R := CellRect;
  C := TableCanvas;
  //paint background
  C.Brush.Color := clRed;
  C.FillRect( R );
  //paint border
  C.Pen.Color := CellAttr.caColor;
  //  C.Polyline( [ R.TopLeft, Point( R.Right, R.Top)]);
  C.Polyline( [ Point( R.Left, R.Bottom-1), Point( R.Right, R.Bottom-1) ]);
  {draw data}
  InflateRect( R, -2, -2 );
  C.Font.Color := clWhite;
  DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  DoneIt := True;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgEditGST.rbATOBasClick(Sender: TObject);
begin
  chkDontPrintCS.Enabled := rbATOBas.checked;
  chkDontPrintFuel.Enabled := rbATOBas.checked and chkIncludeFuel.Checked;
end;

procedure TdlgEditGST.eGSTNumberClick(Sender: TObject);
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

procedure TdlgEditGST.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  with tblRates do begin
    if InEditingState then
      StopEditingState( true);
  end;
  CanClose := True;
end;

procedure TdlgEditGST.colAccountKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if ( Key = VK_BACK ) then
    bkMaskUtils.CheckRemoveMaskChar(TEdit(colAccount.CellEditor),RemovingMask)
  else
    bkMaskUtils.CheckForMaskChar(TEdit(colAccount.CellEditor),RemovingMask);
end;

procedure TdlgEditGST.colAccountExit(Sender: TObject);
begin
  if not MyClient.clChart.CodeIsThere(TEdit(colAccount.CellEditor).Text) then
    bkMaskUtils.CheckRemoveMaskChar(TEdit(colAccount.CellEditor),RemovingMask);
end;

end.
