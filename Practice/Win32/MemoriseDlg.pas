unit MemoriseDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   Memorise Entry Dlg

  Written:
  Authors:

  Purpose: Allows the user to memorise the current entry

  Notes:

     Recalculate GST Problem:

     GST cannot be recalculated in memorisations because we have no way of knowing if the
     memorisation has been setup using the default GST class, or if the class has been changed.

     There is also no way to edit a memorisation to change the gst class at a later date.

     Solution : Will need to add a flag to memorisations that tells us if the gst has been edited.
                If it has not been edited then we can update it during a recalc.

     Sort Term solution for AU is not to allow editing of the GST Class.  Therefore the default will
     always be used.  AutoCode will also be changed to use the current gst default for the chart code.

}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OvcTCmmn, OvcTCell, OvcTCStr, OvcTCHdr, OvcBase, OvcTable,
  bkdefs,baObj32, OvcTCEdt, OvcTCBEF, OvcTCNum, OvcTCCBx, ExtCtrls,
  BKConst, OvcTCBmp, OvcTCGly, OvcEF, OvcPB, OvcNF, Buttons, OvcABtn, globals,
  ImgList, ComCtrls, ToolWin, OvcTCPic,moneydef, OvcTCSim, glConst,
  MemorisationsObj, Menus, SuperFieldsutils,
  OsFont, ovcpf;

type

  TSplitArray = Array[ 1 .. GLCONST.Max_mx_Lines ] of TmemSplitRec;

type
  TdlgMemorise = class(TForm)
    GroupBox1: TGroupBox;
    lblType: TLabel;
    eRef: TEdit;
    ePart: TEdit;
    eOther: TEdit;
    eCode: TEdit;
    memController: TOvcController;
    cRef: TCheckBox;
    cPart: TCheckBox;
    cOther: TCheckBox;
    cCode: TCheckBox;
    Panel1: TPanel;
    ColAmount: TOvcTCNumericField;
    ColDesc: TOvcTCString;
    ColAcct: TOvcTCString;
    cmbValue: TComboBox;
    nValue: TOvcNumericField;
    cEntry: TCheckBox;
    Label1: TLabel;
    ColGSTCode: TOvcTCString;
    cNotes: TCheckBox;
    eNotes: TEdit;
    Panel2: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    ToolBar: TPanel;
    sbtnPayee: TSpeedButton;
    sbtnChart: TSpeedButton;
    sbtnJob: TSpeedButton;
    chkMaster: TCheckBox;
    tblSplit: TOvcTable;
    Header: TOvcTCColHead;
    chkStatementDetails: TCheckBox;
    eStatementDetails: TEdit;
    colNarration: TOvcTCString;
    cValue: TCheckBox;
    colLineType: TOvcTCComboBox;
    Panel4: TPanel;
    lblAmountHdr: TLabel;
    lblFixedHdr: TLabel;
    lblRemDollarHdr: TLabel;
    lblTotalPercHdr: TLabel;
    lblRemPercHdr: TLabel;
    lblRemPerc: TLabel;
    lblTotalPerc: TLabel;
    lblRemDollar: TLabel;
    lblFixed: TLabel;
    lblAmount: TLabel;
    lblMinus: TLabel;
    sBar: TStatusBar;
    popMem: TPopupMenu;
    LookupChart1: TMenuItem;
    LookupGSTClass1: TMenuItem;
    LookupPayee1: TMenuItem;
    Sep1: TMenuItem;
    FixedAmount1: TMenuItem;
    PercentageofTotal1: TMenuItem;
    Sep2: TMenuItem;
    CopyContentoftheCellAbove1: TMenuItem;
    AmountApplyRemainingAmount1: TMenuItem;
    ColPayee: TOvcTCNumericField;
    ColPercent: TOvcTCNumericField;
    sbtnSuper: TSpeedButton;
    chkAccountSystem: TCheckBox;
    cbAccounting: TComboBox;
    EditSuperfundDetails1: TMenuItem;
    ClearSuperfundDetails1: TMenuItem;
    colJob: TOvcTCString;
    eDateFrom: TOvcPictureField;
    eDateTo: TOvcPictureField;
    cbFrom: TCheckBox;
    cbTo: TCheckBox;
    btnCopy: TButton;
    LookupJob1: TMenuItem;
    Rowtmr: TTimer;

    procedure cRefClick(Sender: TObject);
    procedure cPartClick(Sender: TObject);
    procedure cOtherClick(Sender: TObject);
    procedure cCodeClick(Sender: TObject);
    procedure tblSplitActiveCellMoving(Sender: TObject; Command: Word;
      var RowNum, ColNum: Integer);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
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
    procedure cmbValueChange(Sender: TObject);
    procedure tblSplitGetCellAttributes(Sender: TObject; RowNum,
      ColNum: Integer; var CellAttr: TOvcCellAttributes);
    procedure tblSplitActiveCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure sbtnChartClick(Sender: TObject);
    procedure sbtnPayeeClick(Sender: TObject);
    procedure ColAcctKeyPress(Sender: TObject; var Key: Char);
    procedure ColGSTCodeOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure chkMasterClick(Sender: TObject);
    procedure ColAcctOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure cNotesClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure chkStatementDetailsClick(Sender: TObject);
    procedure cValueClick(Sender: TObject);
    procedure nValueChange(Sender: TObject);
    procedure nValueKeyPress(Sender: TObject; var Key: Char);
    procedure ColAmountKeyPress(Sender: TObject; var Key: Char);
    procedure ColGSTCodeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
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
    procedure ColPayeeOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure ColPayeeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sbtnSuperClick(Sender: TObject);
    procedure chkAccountSystemClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure popMemPopup(Sender: TObject);
    procedure ClearSuperfundDetails1Click(Sender: TObject);
    procedure cbFromClick(Sender: TObject);
    procedure cbToClick(Sender: TObject);
    procedure sbtnJobClick(Sender: TObject);
    procedure eDateFromDblClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure RowtmrTimer(Sender: TObject);
  private
    { Private declarations }
    AltLineColor : integer;
    EditMode : boolean;
    SplitData : TSplitArray;
    RemovingMask : boolean;
    ExistingCode: string;
    Loading : boolean; //set to true when loading values into form.  Stop onClick events being fired
    InEditMemorisationMode : Boolean;
    GSTClassEditable       : Boolean;

    AmountToMatch : Money;
    AmountMultiplier : integer;
    SourceTransaction : pTransaction_Rec;
    SourceBankAccount : TBank_Account;
    FTaxName : String;
    FCountry : Byte;
    FsuperTop, FSuperLeft: Integer;
    AllowMasterMemorised: boolean;
    EditMem :TMemorisation;
    EditMemorisedList: TMemorisations_List;
    WasAmount: Double;
    WasType: Byte;
    tmrRow: Integer;
    tmrCol: Integer;
    procedure UpdateFields(RowNum : integer);
    procedure UpdateTotal;
    function  OKtoPost : boolean;
    procedure RemoveBlankLines;
    procedure CompleteAmount;
    procedure CalcRemaining(var Fixed, TotalPerc, RemainingPerc, RemainingDollar : Money;
                            var HasDollarLines, HasPercentLines : boolean);
    procedure DoGSTLookup;
    procedure DoPayeeLookup;
    procedure DoJobLookup;

    procedure SetFirstLineDefaultAmount;

    procedure SaveToMemRec(var pM : TMemorisation; pT : pTransaction_Rec; IsMaster: Boolean);
    procedure DoDeleteCell;
    procedure DoDitto;
    procedure DoSuperEdit;
    procedure DoSuperClear;
    function SplitLineIsValid(LineNo: integer): boolean;
    procedure ApplyAmountShortcut(Key: Char);
    procedure ShowPopUp( x, y : Integer; PopMenu :TPopUpMenu );
    function HasPayees: Boolean;
    function HasJobs: Boolean;
    procedure SetAccountingSystem(const Value: Integer);
    function GetAccountingSystem: Integer;
    procedure LocaliseForm;
  public
    property AccountingSystem: Integer read GetAccountingSystem write SetAccountingSystem;
    { Public declarations }
  end;

  function MemoriseEntry(BA: TBank_Account; tr: pTransaction_Rec; var IsAMasterMem: boolean): boolean;
  function EditMemorisation(BA: TBank_Account; MemorisedList: TMemorisations_List;
                            pM: TMemorisation; IsCopy: Boolean = False; Prefix: string = '') : boolean;

//******************************************************************************
implementation

uses
  Software,
  bkdateutils,
  ovcConst,
  MaintainGroupsFrm,
  AccountLookupFrm,
  BKHelp,
  bkXPThemes,
  BKMLIO,
  ComboUtils,
  ErrorMoreFrm,
  PayeeLookupFrm,
  updateMF,
  GstLookupFrm,
  WarningMoreFrm,
  InfoMoreFrm,
  Malloc,
  LogUtil,
  ImagesFrm,
  GstCalc32,
  Math,
  mxFiles32,
  mxUtils,
  admin32,
  bkMaskUtils,
  CanvasUtils,
  GenUtils,
  WinUtils,
  StdHints,
  YesNoDlg, ECollect, MemUtils,
  CountryUtils,
  SystemMemorisationList,
  SYDEFS,
  AuditMgr;

{$R *.DFM}

CONST
  {table command const}
  tcLookup         = ccUserFirst + 1;
  tcDeleteCell     = ccUserFirst + 2;
  tcComplete       = ccUserFirst + 3;
  tcGSTLookup      = ccUserFirst + 4;
  tcDitto          = ccUserFirst + 5;
  tcPayeeLookup    = ccUserFirst + 6;
  tcSuperEdit      = ccUserFirst + 7;
  tcSuperClear     = ccUserFirst + 8;
  tcJobLookup      = ccUserFirst + 9;

  //Column Nos
  AcctCol      = 0;
  DescCol      = 1;
  NarrationCol = 2;
  PayeeCol     = 3;
  JobCol       = 4;
  GSTCodeCol   = 5;
  AmountCol    = 6;
  PercentCol   = 7;
  TypeCol      = 8;

  mrCopy = mrRetry;

const
  UnitName = 'MEMORISEDLG';

var
   DebugMe  : boolean = false;
   sDOLLAR  : string[1] = '$';
   sPERCENT : string[1] = '%';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgMemorise.FormCreate(Sender: TObject);
var
   i : Integer;
   W : Integer;

begin
  bkXPThemes.ThemeForm(Self);
  AltLineColor := BKCOLOR_CREAM;

  for i := Low(SplitData) to High(SplitData) do begin
     ClearWorkRecDetails(@SplitData[i]);
  end;

  SourceBankAccount := nil;

  with MyClient, clFields do begin

    if Assigned(AdminSystem) then
       if AdminSystem.DualAccountingSystem then begin
          // fill the Accounting System dropdown ( Only used in Dual system}
          // Make sure they are both there;
          AccountingSystem := AdminSystem.fdFields.fdAccounting_System_Used;
          AccountingSystem := AdminSystem.fdFields.fdSuperfund_System;
          AccountingSystem := MyClient.clFields.clAccounting_System_Used;
       end;



    case clCountry of
     whNewZealand :
        Begin
           sbtnSuper.Visible := False;
        end;
     whAustralia, whUK :
        Begin
           cCode.Caption    := '&Bank Type';
           eCode.MaxLength  := 12;

           cPart.Visible    := false;
           ePart.Visible    := false;
           cOther.Visible   := false;
           eOther.Visible   := false;

           cNotes.Top       := cOther.Top;
           eNotes.Top       := eOther.Top;

           cValue.Top       := cPart.Top + 3;
           cmbValue.Top     := ePart.Top + 3;
           nValue.Top       := ePart.Top + 3;
           lblMinus.Top     := nValue.Top + 3;

           GroupBox1.Height := 180;
           sbtnSuper.Visible :=  CanUseSuperFundFields(MyClient.clFields.clCountry,  MyClient.clFields.clAccounting_System_Used, sfMem);
        end;
     end;
  end;
  if not sbtnSuper.Visible then begin
     EditSuperfundDetails1.Visible := False;
     ClearSuperfundDetails1.Visible := False;
  end; 

  //Resize for
  Width  := Max( 630, Round( (application.MainForm.Monitor.WorkareaRect.Right - application.MainForm.Monitor.WorkareaRect.Left) * 0.8));
  Height := Max( 450, Round( (application.MainForm.Monitor.WorkareaRect.Bottom - application.MainForm.Monitor.WorkareaRect.Top) * 0.8));

 

  // Resize the Desc Column to fit the table size
  with tblSplit do begin
     // Now resize the Desc Column to fit the table width
     W := 0;
     for i := 0 to Pred( Columns.Count ) do begin
        if not Columns[i].Hidden then
           W := W + Columns.Width[i];
     end;
     i := GetSystemMetrics( SM_CXVSCROLL ); //Get Width Vertical Scroll Bar
     W := W + i + 2;
     Columns[ NarrationCol ].Width := Columns[ NarrationCol ].Width + ( Width - W );
  end;
  EditMode := false;
  RemovingMask := false;

  if not ( Assigned( AdminSystem) and Assigned( CurrUser )) then
     AllowMasterMemorised := false
  else begin
     AllowMasterMemorised := ( CurrUser.CanMemoriseToMaster ) and
                             ( AdminSystem.fdFields.fdMagic_Number = MyClient.clFields.clMagic_Number) and
                             ( MyClient.clFields.clDownload_From = dlAdminSystem );
  end;
  chkMaster.Enabled := AllowMasterMemorised;

  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,sbtnChart.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_PAYEE_BMP,sBtnPayee.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_SUPER_BMP,sBtnSuper.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_JOB_BMP,sbtnJob.Glyph);

  tblSplit.CommandOnEnter := ccRight;
  tblSplit.RowLimit := GLCONST.Max_mx_Lines +1;

  //set up value grid
  cmbValue.Items.AddObject( mxNames[ mxAmtEqual], TObject( mxAmtEqual));
  cmbValue.Items.AddObject( mxNames[ mxAmtLessThan], TObject( mxAmtLessThan));
  cmbValue.Items.AddObject( mxNames[ mxAmtGreaterThan], TObject( mxAmtGreaterThan));
  cmbValue.Items.AddObject( mxNames[ mxAmtLessOrEqual], TObject( mxAmtLessOrEqual));
  cmbValue.Items.AddObject( mxNames[ mxAmtGreaterOrEqual], TObject( mxAmtGreaterOrEqual));

  with tblSplit.Controller.EntryCommands do begin
    {remove F2 functionallity}
    DeleteCommand('Grid',VK_F2,0,0,0);
    DeleteCommand('Grid',VK_F3,0,0,0);
    DeleteCommand('Grid',VK_DELETE,0,0,0);

    {add our commands}
    AddCommand('Grid',VK_F2,0,0,0,tcLookup);
    AddCommand('Grid',VK_F3,0,0,0,tcPayeeLookup);
    AddCommand('Grid',VK_F5,0,0,0,tcJobLookup);
    AddCommand('Grid',VK_F7,0,0,0,tcGSTLookup);
    AddCommand('Grid',VK_F6,0,0,0,ccTableEdit);
    AddCommand('Grid',VK_F11,0,0,0,tcSuperEdit);
    AddCommand('Grid',VK_DELETE,0,0,0,tcDeleteCell);
    AddCommand('Grid',VK_ADD,0,0,0,tcDitto);          {+ - NumPad}
    Addcommand('Grid',187,0,0,0,tcComplete);         {'=' to complete amount}
  end;
  SetUpHelp;

  //setup max length of gst-id
  ColGSTCode.MaxLength := GST_CLASS_CODE_LENGTH;
  ColAcct.MaxLength    := MaxBk5CodeLen;
  //resize the account col so that longest account code fits
  tblSplit.Columns[ AcctCol ].Width := CalcAcctColWidth( tblSplit.Canvas, tblSplit.Font, 100);

  eDateFrom.Epoch       := BKDATEEPOCH;
  eDateFrom.PictureMask := BKDATEFORMAT;
  eDateTo.Epoch         := BKDATEEPOCH;
  eDateTo.PictureMask   := BKDATEFORMAT;

  FsuperTop := -999;
  FSuperLeft := -999;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   eRef.Hint        :=
                    'Change the text or add wild card characters if needed|' +
                    'Change the text or add wild card characters if needed';
   eNotes.Hint      :=
                    'Change the text of add wild card characters if needed|' +
                    'Change the text of add wild card characters if needed.  Max 40 characters|';

   ePart.Hint       := eRef.Hint;

   eOther.Hint      := eRef.Hint;

   eCode.Hint       := eRef.Hint;

   nValue.Hint      :=
                    'Enter the amount to memorise on|'+
                    'Enter the amount to memorise on';
   cRef.Hint        :=
                    'Check to memorise on the contents of the Reference field|' +
                    'Check to memorise on the contents of the Reference field';
   cPart.Hint       :=
                    'Check to memorise on the contents of the Particulars field|' +
                    'Check to memorise on the contents of the Particulars field';

   cCode.Hint       :=
                    'Check to memorise on the contents of the Analysis Code field|' +
                    'Check to memorise on the contents of the Analysis Code field';
   cNotes.Hint      :=
                    'Check to memorise on the contents of the notes field|';
   cmbValue.Hint    :=
                    'Select to memorise by Value, Percentage or both|' +
                    'Select "Yes" to memorise on Value, "No" on Percentage, or "$/%" to memorise on both';
   tblSplit.Hint    :=
                    'Enter the details for coding this Memorisation|' +
                    'Enter the details for automatically coding this Memorisation';
   sbtnPayee.Hint   :=
                    STDHINTS.PayeeLookupHint;
   sbtnChart.Hint   :=
                    STDHINTS.ChartLookupHint;
   chkMaster.Hint   :=
                    'Check to make this a Master Memorisation|' +
                    'Check to make this a Master Memorisation';

   chkStatementDetails.Hint :=
                    'Check to memorise on the contents of the Statement Details field|' +
                    'Check to memorise on the contents of the Statement Details field';

   cbFrom.Hint   :=
                    'Check to enable a Tranaction date, from which this Memorisation will apply|' +
                    'Check to enable a Tranaction date, from which this Memorisation will apply';
   cbTo.Hint   :=
                    'Check to enable a Tranaction date, until which this Memorisation will apply|' +
                    'Check to enable a Tranaction date, until which this Memorisation will apply';
end;
//------------------------------------------------------------------------------
procedure ToggleEdit(Sender : TObjecT);
begin
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.cRefClick(Sender: TObject);
begin
   eRef.enabled  := cRef.Checked;
   if not Loading then
      if eRef.enabled then eRef.SetFocus;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.cPartClick(Sender: TObject);
begin
   ePart.enabled := cPart.Checked;
   if not Loading then
      if ePart.enabled then ePart.setFocus;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.cOtherClick(Sender: TObject);
begin
   eOther.Enabled := cOther.Checked;
   if not Loading then
      if eOther.enabled then eOther.setFocus;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.chkAccountSystemClick(Sender: TObject);
begin
    cbAccounting.Enabled := chkAccountSystem.Checked;
end;

procedure TdlgMemorise.cbFromClick(Sender: TObject);
begin
  eDateFrom.Enabled := cbFrom.Checked;
end;

procedure TdlgMemorise.cbToClick(Sender: TObject);
begin
  eDateTo.Enabled := cbTo.Checked;
end;

procedure TdlgMemorise.cCodeClick(Sender: TObject);
begin
   eCode.Enabled := cCode.Checked;
   if not Loading then
      if eCode.enabled then eCode.setFocus;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitActiveCellMoving(Sender: TObject;
  Command: Word; var RowNum, ColNum: Integer);
var
   Code : string;
begin
   Code := '';

   case ColNum of
      DescCol: case Command of
         ccLeft, ccPageLeft   : ColNum := AcctCol;
         ccRight, ccPageRight : ColNum := NarrationCol;
         ccMouse              : ColNum := AcctCol;
      end;

      GSTCodeCol : begin
         if not GSTClassEditable then begin
            case Command of
               ccRight, ccPageRight :  ColNum := AmountCol;
            else
               ColNum := NarrationCol;
            end;
         end;
      end;

      TypeCol :
       case Command of
          ccRight, ccPageRight :
            if RowNum < tblSplit.RowLimit then
            begin
              Inc(RowNum);
              ColNum := AcctCol;
            end;
       else
          ColNum := PercentCol;
       end;
    end;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.btnOKClick(Sender: TObject);
begin


   if OKtoPost then
      Modalresult := mrOk;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.btnCopyClick(Sender: TObject);
begin
   if OKtoPost then
     Modalresult := mrCopy;
end;

procedure TdlgMemorise.btnCancelClick(Sender: TObject);
begin
   modalresult := mrCancel;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitEnter(Sender: TObject);
begin
   btnOk.Default := false;
   btnCancel.Cancel := false;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitExit(Sender: TObject);
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
//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
var
  zero: Double;
begin
  data := nil;
  zero := 0.0;
  if Purpose = cdpForEdit then btnCancel.cancel := false;

  if (RowNum > 0) and (RowNum <= GLCONST.Max_mx_Lines) then
  Case ColNum of
    AcctCol :
      data := @SplitData[RowNum].AcctCode;

    DescCol:
      data := @SplitData[RowNum].desc;

    NarrationCol:
      data := @SplitData[RowNum].Narration;

    JobCol:
      data := @SplitData[RowNum].JobCode;

    GSTCodeCol:
      data := @SplitData[RowNum].GSTClassCode;

    AmountCol: begin
      if SplitData[RowNum].LineType = mltPercentage then
        data := @zero
      else
        data := @SplitData[RowNum].Amount;
      if Purpose = cdpForEdit then
         WasAmount := SplitData[RowNum].Amount;
    end;

    PercentCol: begin
      if SplitData[RowNum].LineType = mltPercentage then
        data := @SplitData[RowNum].Amount
      else
        data := @zero;
      if Purpose = cdpForEdit then
         WasAmount := SplitData[RowNum].Amount ;
     end;
    TypeCol:
      data := @SplitData[RowNum].LineType;

    PayeeCol:
      data := @SplitData[RowNum].Payee;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitBeginEdit(Sender: TObject; RowNum,
  ColNum: Integer; var AllowIt: Boolean);
begin
    if ColNum <> 1 then
      EditMode := true;


end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitEndEdit(Sender: TObject;
  Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
  var AllowIt: Boolean);
var
  tempNo   : integer;
  tempID   : string;



begin
  btnCancel.Cancel := false;

  EditMode := false;
  WasType :=  SplitData[RowNum].LineType;
  case ColNum of
     GSTCodeCol : begin
        {find the gst class no and the replace the given gst class code to make sure
         that only valid codes are allowed}
        tempId   := Trim(TEdit(ColGSTCode.CellEditor).Text);
        tempNo   := GetGSTClassNo( MyClient, tempId);
        if (trim(tempID) <> '') and (tempNo = 0) then begin
           WinUtils.ErrorSound;
           AllowIt := false;
           EditMode := true;  //still editing
        end
        else
          TEdit(ColGSTCode.CellEditor).Text:= GetGSTClassCode( MyClient, tempNo);
     end;
     PayeeCol : begin
        {find the gst class no and the replace the given gst class code to make sure
         that only valid codes are allowed}
        tempNo   := TOvcNumericField( ColPayee.CellEditor).AsInteger;
        if (tempNo <> 0) and (not Assigned(MyClient.clPayee_List.Find_Payee_Number(tempNo))) then begin
           WinUtils.ErrorSound;
           AllowIt := false;
           EditMode := true;  //still editing
        end;
     end;

     AmountCol: SplitData[RowNum].LineType := pltDollarAmt;
     PercentCol: SplitData[RowNum].LineType := pltPercentage;
    
  end;
end;
//------------------------------------------------------------------------------

procedure TdlgMemorise.DoGSTLookup;
var
   Msg           : TWMKey;
   InEditOnEntry : boolean;
   GSTCode : string;
begin
    if not Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then exit;

    with tblSplit do begin
       if not StopEditingState(True) then Exit;
       if (ActiveCol <> GSTCodeCol) then
          ActiveCol := GSTCodeCol;

       InEditOnEntry := InEditingState;
       if not InEditOnEntry then begin
          if not StartEditingState then Exit;   //returns true if already in edit state
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
procedure TdlgMemorise.DoJobLookup;
var
   Msg           : TWMKey;
   InEditOnEntry : boolean;
   JobCode : string;
begin
    with tblSplit do begin
       if not StopEditingState(True) then
          Exit;
       if (ActiveCol <> JobCol) then
          ActiveCol := JobCol;

       InEditOnEntry := InEditingState;
       if not InEditOnEntry then begin
          if not StartEditingState then Exit;   //returns true if already in edit state
       end;

       JobCode := Tedit(colJob.CellEditor).Text;
       if PickJob (JobCode) then begin
           //if get here then have a valid char from the picklist
           Tedit(colJob.CellEditor).Text := JobCode;
           Msg.CharCode := VK_RIGHT;
           colPayee.SendKeyToTable(Msg);
       end else begin
           if not InEditOnEntry then begin
              StopEditingState(true);  //end edit
           end;
       end;
    end;
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgMemorise.DoDeleteCell;
//Pressing Delete key while not in Editing mode should delete the content of the
//current cell.  Note that this routine can't be called while Edit mode is selected
//as key stroke will be processed by the cell
var
  ColNum : integer;
begin
   with tblSplit do begin
      if not StartEditingState then Exit;
      ColNum := ActiveCol;
      case ColNum of
        AcctCol :      TEdit(ColAcct.CellEditor).Text := '';
        NarrationCol : TEdit(ColNarration.CellEditor).Text := '';
        GSTCodeCol :   TEdit(ColGSTCode.CellEditor).Text := '';
        JobCol :       TEdit(ColJob.CellEditor).Text := '';
        AmountCol :    TOvcNumericField( ColAmount.CellEditor).AsFloat := 0.0;
        PercentCol :   TOvcNumericField( ColPercent.CellEditor).AsFloat := 0.0;
        PayeeCol :     TOvcNumericField( ColPayee.CellEditor).AsInteger := 0;
      end;
      StopEditingState( True );
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgMemorise.tblSplitUserCommand(Sender: TObject; Command: Word);
var
   Msg   : TWMKey;
   Code  : string;
begin
  Code := '';

  case Command of
    tcLookup :
      begin
        if not tblSplit.StopEditingState(True) then
           Exit;
        if EditMode then
           Code := TEdit(ColAcct.CellEditor).Text
        else
           Code := SplitData[tblSplit.ActiveRow].AcctCode;

        if PickAccount(Code) then begin
           // got a Code
           if (ExistingCode = '') // new row started and previous row had a payee
           and (tblSplit.ActiveRow > 1)
           and (SplitData[tblSplit.ActiveRow-1].Payee <> 0) then begin
              SplitData[tblSplit.ActiveRow].Payee := SplitData[tblSplit.ActiveRow-1].Payee;
              tblSplit.InvalidateCell(tblSplit.ActiveRow, PayeeCol);
           end;
           ExistingCode := Code;
           if EditMode then
               TEdit(ColAcct.CellEditor).Text := Code
           else begin
              SplitData[tblSplit.ActiveRow].AcctCode := Code;
              UpdateFields(tblSplit.ActiveRow);
              Msg.CharCode := VK_RIGHT;
              ColAcct.SendKeyToTable(Msg);
           end;
           tblSplit.InvalidateCell(tblSplit.ActiveRow,AcctCol);
           tblSplit.InvalidateCell(tblSplit.ActiveRow,DescCol);
        end;
      end;
    tcGSTLookup : DoGSTLookup;

    tcDeleteCell : DoDeleteCell;

    tcComplete : CompleteAmount;

    tcDitto :
      DoDitto;

    tcPayeeLookup : DoPayeeLookup;
    tcSuperEdit : DoSuperEdit;
    tcJobLookup : DoJobLookup;

    tcSuperClear : DoSuperClear;
  end;
end;


procedure TdlgMemorise.RowtmrTimer(Sender: TObject);

  type
    ChangeMode = (Amount, ToAmount, ToPercent);

 function TestAmount: boolean;

     function HasSFRevenuSplit: Boolean;
     begin
        Result := True;
        if SplitData[tmrRow].SF_Tax_Free_Dist <> 0 then Exit;
        if SplitData[tmrRow].SF_Tax_Exempt_Dist <> 0 then Exit;
        if SplitData[tmrRow].SF_Tax_Deferred_Dist <> 0 then Exit;
        if SplitData[tmrRow].SF_Foreign_Income <> 0 then Exit;
        if SplitData[tmrRow].SF_Capital_Gains_Indexed <> 0 then Exit;
        if SplitData[tmrRow].SF_Capital_Gains_Disc <> 0 then Exit;
        if SplitData[tmrRow].SF_Capital_Gains_Other <> 0 then Exit;
        if SplitData[tmrRow].SF_Other_Expenses <> 0 then Exit;
        if SplitData[tmrRow].SF_Interest <> 0 then Exit;
        if SplitData[tmrRow].SF_Capital_Gains_Foreign_Disc <> 0 then Exit;
        if SplitData[tmrRow].SF_Rent <> 0 then Exit;
        if SplitData[tmrRow].SF_Special_Income <> 0 then Exit;
        if SplitData[tmrRow].SF_Foreign_Capital_Gains_Credit <> 0 then Exit;
        // Nothing found
        Result := false;
     end;


     function EditSuperfund(Mode:ChangeMode): Boolean;
     var Move: TFundNavigation;
         BA: TBank_Account;
         ldata: TmemSplitRec;

         procedure DoToAmount(NewAmount:Money);
         var TotalRate, Remainder: Money;
            procedure MakeAmount(var Value: Money);
            begin
               if Value <> 0 then begin
                  TotalRate := TotalRate + Value;
                  if TotalRate = 1000000 then begin
                     Value := Remainder; // 100% just copy the leftover, stop rounding errors
                  end else begin
                     Value := abs(Double2Money (Percent2Double(Value) * Money2Double(NewAmount)/100));
                  end;
               end;
               Remainder := Remainder - Value;
            end;
         begin
            TotalRate := 0;
            Remainder := abs(NewAmount);
            MakeAmount(ldata.SF_Tax_Free_Dist);
            MakeAmount(ldata.SF_Tax_Exempt_Dist);
            MakeAmount(ldata.SF_Tax_Deferred_Dist);
            MakeAmount(ldata.SF_Foreign_Income);
            MakeAmount(ldata.SF_Capital_Gains_Indexed);
            MakeAmount(ldata.SF_Capital_Gains_Disc);
            MakeAmount(ldata.SF_Capital_Gains_Other);
            MakeAmount(ldata.SF_Capital_Gains_Foreign_Disc);
            MakeAmount(ldata.SF_Other_Expenses);
            MakeAmount(ldata.SF_Interest);
            MakeAmount(ldata.SF_Rent);
            MakeAmount(ldata.SF_Special_Income);
         end;

         procedure DoToPercent(OldAmount:Money);
         var TotalAmount, Remainder: Money;
            procedure MakeAmount(var Value: Money);
            begin
               if Value <> 0 then begin
                  TotalAmount := TotalAmount + Value;
                  if TotalAmount = OldAmount then begin
                     Value := Remainder; // Full amount just copy the leftover, stop rounding errors
                  end else begin
                     Value := Money2Double(Value) / Money2Double(OldAmount) * 1000000;
                  end;
               end;
               Remainder := Remainder - Value;
            end;
         begin
            TotalAmount := 0;
            Remainder := 1000000;
            MakeAmount(ldata.SF_Tax_Free_Dist);
            MakeAmount(ldata.SF_Tax_Exempt_Dist);
            MakeAmount(ldata.SF_Tax_Deferred_Dist);
            MakeAmount(ldata.SF_Foreign_Income);
            MakeAmount(ldata.SF_Capital_Gains_Indexed);
            MakeAmount(ldata.SF_Capital_Gains_Disc);
            MakeAmount(ldata.SF_Capital_Gains_Other);
            MakeAmount(ldata.SF_Capital_Gains_Foreign_Disc);
            MakeAmount(ldata.SF_Other_Expenses);
            MakeAmount(ldata.SF_Interest);
            MakeAmount(ldata.SF_Rent);
            MakeAmount(ldata.SF_Special_Income);
         end;

     begin //EditSuperfund
        Result := false;
        Move := fnNoMove;

        if chkMaster.Checked then
           BA := nil
        else
           BA := SourceBankAccount;

        // Make a temp Copy
        ldata := SplitData[tmrRow];
        // Apply any changes if we can...
        case Mode of
           Amount: ; // fine..
           ToAmount: DoToAmount(Double2Money(SplitData[tmrRow].Amount));
           ToPercent: DoToPercent(Double2Money(WasAmount));
        end;

        if SuperFieldsUtils.EditSuperFields(SourceTransaction,ldata, Move, FSuperTop, FSuperLeft,sfMem, BA) then begin
           // Use the tempdata..
           SplitData[tmrRow] := ldata;
           Result := True;
        end;
     end; //EditSuperfund

  begin //TestAmount
     Result := True;
     if not sbtnSuper.Visible then
        Exit; // No superfund so I don't care...

     if not SplitData[tmrRow].SF_Edited then
        Exit; //No Superfund data ...

     if not HasSFRevenuSplit then
        Exit; // No split .. so I don't care

     case tmrCol of
        AmountCol: if wasType <> pltDollarAmt then begin
               // Mode change to Amount
               if AskYesNo('Confirm Line Type Change',
                  'This line has superfund percentages,'#13'which you are about to changed to amounts'#13#13+
                  'Please confirm you want to continue.', DLG_NO, 0) = DLG_YES then
               begin
                  Result := EditSuperfund(ToAmount);
               end else begin
                  // Set it back..
                  Result := False;
               end;

            end else begin
               // Was and is amount.. Test for change
               if SplitData[tmrRow].Amount <> WasAmount then begin
                  if AskYesNo('Confirm Line Amount Change',
                        'This line has superfund amounts that should balance.'#13#13+
                        'Please confirm you want to continue.', DLG_NO, 0) = DLG_YES then
                  begin
                     // Just let the user do it..
                    Result := EditSuperfund(Amount);
                  end else begin
                     // Set it back..
                     Result := False;
                  end;
               end;
            end;
        PercentCol: if Wastype <> pltPercentage then begin
               // Mode change to Percentage
               if AskYesNo('Confirm Line Type Change',
                  'This line has superfund amounts,'#13'which you are about to changed to percentages'#13#13+
                  'Please confirm you want to continue.', DLG_NO, 0) = DLG_YES then
               begin
                  // Convert it first
                  Result := EditSuperfund(ToPercent);
               end else begin
                  // Set it back..
                  Result := False;
               end;
        end;
     end;
  end; //TestAmount



begin //RowtmrTimer
   if RowTmr.Enabled then
      RowTmr.Enabled := False// So I Don't  do it agian
   else
      Exit; // might be handeled in CloseQuery

   if TestAmount then
      // all done..
   else begin
      // Set it back..
      SplitData[tmrRow].Amount := WasAmount;
      SplitData[tmrRow].LineType := WasType;
   end;

   tblSplit.AllowRedraw := false;
   try
      tblSplit.InvalidateRow(tmrRow);
   finally
      tblSplit.AllowRedraw := true;
   end;

   UpdateTotal;
end;//RowtmrTimer

//------------------------------------------------------------------------------
procedure TdlgMemorise.UpdateFields(RowNum: integer);
var
   Acct : pAccount_Rec;
begin
   if not Assigned(myClient) then exit;
   Acct := MyClient.clChart.FindCode(SplitData[RowNum].AcctCode);
   if Assigned(Acct) then
   begin
     SplitData[RowNum].GSTClassCode := GetGSTClassCode( MyClient, Acct^.chGST_Class);
     SplitData[RowNum].Desc         := Acct^.chAccount_Description;
     SplitData[RowNum].GST_Has_Been_Edited := false;
   end
   else
   begin
     SplitData[RowNum].GSTClassCode := '';
     SplitData[RowNum].Desc         := '';
     SplitData[RowNum].GST_Has_Been_Edited := false;
   end;

   if ( SplitData[ RowNum].AcctCode <> '') then
   begin
     if ( SplitData[ RowNum].LineType = -1) then
     begin
       if (RowNum > 1) and ( SplitData[RowNum - 1].LineType <> -1) then
         SplitData[ RowNum].LineType := SplitData[ RowNum - 1].LineType
       else
       begin
         if GetComboCurrentIntObject(cmbValue) = mxAmtEqual then
           SplitData[ RowNum].LineType := mltDollarAmt
         else
           SplitData[ RowNum].LineType := mltPercentage;
       end;
       UpdateTotal;
     end;
   end
   else
   begin
     //blank code, blank type
     SplitData[ RowNum].LineType := mltPercentage;
     UpdateTotal;
   end;

   tblSplit.InvalidateCell(RowNum,GSTCodeCol);  {gst class}
   tblSplit.InvalidateCell(RowNum,DescCol);  {desc}
   tblSplit.InvalidateCell(RowNum,TypeCol);  {type}
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitDoneEdit(Sender: TObject; RowNum,
  ColNum: Integer);
var
   DefaultClass : integer;
   SelectedClass : integer;

begin
   Case ColNum of
      AcctCol : begin
        if (ExistingCode = '') and // new row started and previous row had a payee
           (RowNum > 1) and (SplitData[RowNum-1].Payee <> 0) then
        begin
           SplitData[tblSplit.ActiveRow].Payee := SplitData[RowNum-1].Payee;
           tblSplit.InvalidateCell(RowNum, PayeeCol);
        end;
        SplitData[RowNum].AcctCode := Trim(SplitData[RowNum].AcctCode);
        ExistingCode := SplitData[RowNum].AcctCode;
        UpdateFields(RowNum);
      end;
      AmountCol, PercentCol : begin
         tmrRow := RowNum;
         tmrCol := ColNum;

         RowTmr.Enabled := true;
      end;
      GSTCodeCol : begin
         //see if different to default for chart
         DefaultClass := MyClient.clChart.GSTClass( SplitData[RowNum].AcctCode);
         SelectedClass := GetGSTClassNo( MyClient, SplitData[RowNum].GSTClassCode);
         SplitData[RowNum].GST_Has_Been_Edited := ( DefaultClass <> SelectedClass);
      end;
      TypeCol : begin
         UpdateTotal;
      end;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.ColAcctKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg : TWMKey;
begin
   if key = vk_f2 then
   begin
      Msg.CharCode := VK_F2;
      ColAcct.SendKeyToTable(Msg);
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgMemorise.SetAccountingSystem(const Value: Integer);
begin
   if Value = asNone then
      Exit; // Don't care
   SetComboIndexByIntObject(Value,cbAccounting,True);
   if cbAccounting.ItemIndex < 0 then begin
      // Just add it..  Check Country in future?
      cbAccounting.Items.AddObject(saNames[Value], TObject(Value));
      SetComboIndexByIntObject(Value,cbAccounting);
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgMemorise.SetFirstLineDefaultAmount;
begin
  if ( SplitData[1].AcctCode = '') then
  begin
    if  ( GetComboCurrentIntObject(cmbValue) = mxAmtEqual) then
    begin
      SplitData[1].Amount := AmountToMatch/100;
      SplitData[1].LineType := mltDollarAmt;
    end
    else
    begin
      SplitData[1].Amount := 100.0;
      SplitData[1].LineType := mltPercentage;
    end;

    tblSplit.AllowRedraw := false;
    try
      tblSplit.InvalidateRow(1);
    finally
      tblSplit.AllowRedraw := true;
    end;
  end;
  UpdateTotal;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.cmbValueChange(Sender: TObject);
begin
  SetFirstLineDefaultAmount;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.CalcRemaining(var Fixed, TotalPerc, RemainingPerc, RemainingDollar : Money;
                                     var HasDollarLines, HasPercentLines : boolean);
var
  i : integer;
begin
  Fixed := 0;
  TotalPerc := 0;
  RemainingPerc := 0;
  RemainingDollar := 0;

  HasPercentLines := false;
  HasDollarLines  := false;
  for i := 1 to GLCONST.Max_mx_Lines do
  begin
    if (SplitData[i].LineType = pltPercentage) and (SplitData[i].Amount <> 0) then
      HasPercentLines := true;

    if (SplitData[i].LineType = pltDollarAmt) and (SplitData[i].Amount <> 0) then
      HasDollarLines := true;
  end;

  for i := 1 to GLCONST.Max_mx_Lines do
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

  if HasDollarLines and (not HasPercentLines) and ( GetComboCurrentIntObject(cmbValue) = mxAmtEqual) then
  begin
    RemainingPerc   := 0;
    RemainingDollar := AmountToMatch - Fixed;
  end
  else
  begin
    RemainingPerc   := Double2Percent(100.0) - TotalPerc;
    RemainingDollar := AmountToMatch - Fixed;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.UpdateTotal;
var
  Fixed  : Money;
  TotalPerc  : Money;
  RemainingPerc, RemainingDollar : Money;
  HasPercentLines : boolean;
  HasDollarLines  : boolean;
  MatchOnEquals : boolean;
begin
  CalcRemaining(Fixed, TotalPerc, RemainingPerc, RemainingDollar, HasDollarLines, HasPercentLines);
  if Assigned(SourceBankAccount)  then begin
     lblAmount.Caption := SourceBankAccount.MoneyStr( AmountToMatch );
     lblFixed.Caption  := SourceBankAccount.MoneyStr( Fixed );
     lblRemDollar.Caption := SourceBankAccount.MoneyStr( RemainingDollar );
  end else if Assigned(MyClient) then begin
     lblAmount.Caption := MyClient.MoneyStr( AmountToMatch );
     lblFixed.Caption  := MyClient.MoneyStr( Fixed );
     lblRemDollar.Caption := MyClient.MoneyStr( RemainingDollar );
  end else if assigned(AdminSystem) then  begin
     lblAmount.Caption := AdminSystem.MoneyStr( AmountToMatch );
     lblFixed.Caption  := AdminSystem.MoneyStr( Fixed );
     lblRemDollar.Caption := AdminSystem.MoneyStr( RemainingDollar );
  end;

  lblTotalPerc.Caption := Format( '%0.4f%%', [TotalPerc/ 10000]);
  lblRemPerc.Caption := Format( '%0.4f%%', [RemainingPerc/ 10000]);

  MatchOnEquals := GetComboCurrentIntObject(cmbValue) = mxAmtEqual;

{
  lblFixed.Enabled := MatchOnEquals or HasDollarLines;
  lblFixedHdr.Enabled := lblFixed.Enabled;

  lblRemDollar.Enabled := MatchOnEquals;
  lblRemDollarHdr.Enabled := lblRemDollar.Enabled;

  lblTotalPerc.Enabled := ( not MatchOnEquals) or HasPercentLines;
  lblTotalPercHdr.Enabled := lblTotalPerc.Enabled;

  lblRemPerc.Enabled   := ( not MatchOnEquals) or HasPercentLines;
  lblRemPercHdr.Enabled := lblRemPerc.Enabled;
}
  lblFixed.Visible := MatchOnEquals or HasDollarLines;
  lblFixedHdr.Visible := lblFixed.Visible;

  lblRemDollar.Visible := MatchOnEquals;
  lblRemDollarHdr.Visible := lblRemDollar.Visible;

  lblTotalPerc.Visible := ( not MatchOnEquals) or HasPercentLines;
  lblTotalPercHdr.Visible := lblTotalPerc.Visible;

  lblRemPerc.Visible   := ( not MatchOnEquals) or HasPercentLines;
  lblRemPercHdr.Visible := lblRemPerc.Visible;

  if RemainingPerc = 0 then
    lblRemPerc.Font.Color := clGreen
  else
    lblRemPerc.Font.Color := clRed;

  if ( not lblRemPerc.Visible) then
  begin
    if RemainingDollar = 0 then
      lblRemDollar.Font.Color := clGreen
    else
      lblRemDollar.Font.Color := clRed;
  end
  else
    lblRemDollar.Font.Color := clWindowText;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgMemorise.OKtoPost : boolean;
var
  i,j : integer;
  ExtraMsg : string;
  aMsg : string;

  Fixed  : Money;
  TotalPerc  : Money;
  RemainingPerc : Money;
  RemainingDollar : Money;
  HasPercentLines : boolean;
  HasDollarLines  : boolean;

  AmountMatchType : integer;
  TempMem : TMemorisation;
  FMemorisationsList : TMemorisations_List; //list of other memorisations to check for duplicates
  BankPrefix : string;
  ValidLineFound : boolean;
  SystemMemorisation: pSystem_Memorisation_List_Rec;
begin
   Result := false;

   if Rowtmr.Enabled then begin
      RowtmrTimer(nil); // execute the prompts
   end;

   RemoveBlankLines;
   tblSplit.ActiveRow := 1;

   //check at least one valid line exists
   ValidLineFound := false;
   for i := 1 to GLCONST.Max_mx_Lines do
   begin
     if SplitLineIsValid( i) then
     begin
       ValidLineFound := true;
       Break;
     end;
   end;

   if not ValidLineFound then
   begin
     HelpfulErrorMsg( 'The Memorisation must have at least one line.', 0);
     Exit;
   end;

   i := 0;
   j := 0;
   if cbFrom.Checked then begin
      i := EDateFrom.AsStDate;
      if (I < MinValidDate)
      or (I > MaxValidDate) then begin
         HelpfulErrorMsg( 'Please enter a valid Applies from date.', 0);
         EDateFrom.SetFocus;
         Exit;
      end;
   end;
   if cbTo.Checked then begin
      j := EDateTo.AsStDate;
      if (j < MinValidDate)
      or (j > MaxValidDate) then begin
         HelpfulErrorMsg( 'Please enter a valid Applies to date.', 0);
         EDateTo.SetFocus;
         Exit;
      end;
   end;
   if (i <> 0)
   and (J <> 0) then
      if J < I then begin
         HelpfulErrorMsg( 'Please enter a Applies to date, later than the Applies from date.', 0);
      end;

   //check that all of memorisation is allocated
   CalcRemaining(Fixed, TotalPerc, RemainingPerc, RemainingDollar, HasDollarLines, HasPercentLines);
   AmountMatchType := GetComboCurrentIntObject(cmbValue);

   //special case if matching by amount, no percentage split is required
   if AmountMatchType = mxAmtEqual then
   begin
     //if only have dollar lines then check that full amount has been allocated
     if ( HasDollarLines and not( HasPercentLines)) then
     begin
       if ( RemainingDollar <> 0) then
       begin
         HelpfulErrorMsg( 'The full amount of the transaction has not been allocated.  Remaining dollar amount is ' +
           MyClient.MoneyStr( RemainingDollar ) + '.', 0 );
         Exit;
       end;
     end;
   end;

   if RemainingPerc <> 0 then
   begin
     HelpfulErrorMsg( 'The remaining percentage is not zero.  You must allocate 100% of the variable component for this Memorisation.',0);
     Exit;
   end;

   //make sure each line has an account code
   for i := 1 to GLCONST.Max_mx_Lines do with SplitData[i] do
     If (double2Money(Amount) <> 0) and (Trim(AcctCode)='') then
     begin
        HelpfulErrorMsg( 'You must enter an account code!', 0 );
        exit;
     end;



   //if not InEditMemorisationMode then
   begin
     //warn user if the only criteria is entry type
     if not ( cRef.Checked or
              cCode.Checked or
              chkStatementDetails.Checked or
              cOther.Checked or
              cPart.Checked or
              cNotes.Checked or
              cValue.Checked) then
       begin
         if AskYesNo( 'Confirm Criteria',
                      'You have not selected any criteria to match on!'#13 +
                      'This Memorisation will be applied to ALL transactions with Entry Type ' +
                      lblType.Caption + #13#13+
                      'Please confirm you want to do this.',
                      DLG_NO, 0) <> DLG_YES then
                        Exit;
       end;

     //check that this transaction will be coded
     TempMem := TMemorisation.Create;
     try
       SaveToMemRec( TempMem, SourceTransaction, chkMaster.Checked);
       if Assigned( SourceBankAccount) then begin
          if chkMaster.Checked then
             begin
               //memorise to relevant master file then reload to get new global list
               BankPrefix := mxFiles32.GetBankPrefix( SourceBankAccount.baFields.baBank_Account_Number);

//               Master_Mem_Lists_Collection.ReloadSystemMXList( BankPrefix);
//               FMemorisationsList := Master_Mem_Lists_Collection.FindPrefix( BankPrefix);
               SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(BankPrefix);
               if Assigned(SystemMemorisation) then
                 FMemorisationsList := TMemorisations_List(SystemMemorisation.smMemorisations);

               TempMem.mdFields.mdFrom_Master_List := true;
             end
          else
             FMemorisationsList := SourceBankAccount.baMemorisations_List;
       end else begin
          FMemorisationsList := EditMemorisedList;
       end;

       if Assigned(editMem) then
           TempMem.mdFields.mdType := editMem.mdFields.mdType;

       if Assigned( FMemorisationsList)
       and (HasDuplicateMem(TempMem, FMemorisationsList, EditMem)) then begin
          if TempMem.mdFields.mdFrom_Master_List then
             aMsg := 'A Master Memorisation already exists that uses the same Match-On criteria. '+
                                'You cannot add duplicate Master Memorisations.'
          else
             aMsg := 'A Memorisation already exists that uses the same Match-On criteria. '+
                                'You cannot add duplicate Memorisations.';

          HelpfulErrorMsg( aMsg, 0);
          Exit;
       end;

       //Warn the user if the selected transaction does not match the criteria
       if assigned(SourceTransaction) then
       if (not mxUtils.CanMemorise( SourceTransaction, TempMem)) then
         begin
           if AskYesNo( 'Confirm Criteria',
                        'The transaction you have selected will NOT be memorised because "Match On" criteria you have used do not result in a match.'#13#13+
                        'Please confirm you want to continue.', DLG_NO, 0) <> DLG_YES then
             Exit;
         end;

     finally
       //free the memory associated with this memorisation
       TempMem.Free;
     end;

   end;

   if InEditMemorisationMode then begin
      //check to see if this is a master memorisation and add an extra warning
      ExtraMsg := '';
      if chkMaster.checked then begin
         if not Assigned( AdminSystem) then
            //the memorisation is marked as a MASTER, however there is no valid admin system.
            //therefore we are dealing with a memorisation which has been saving into the client file
            ExtraMsg := #13+#13+'NOTE: This will only change the MASTER Memorisation TEMPORARILY. '+
                        'To change it permanently it must be altered at the PRACTICE.'
         else
            ExtraMsg := #13+#13+'NOTE: This will apply to ALL clients in your practice that have '+
                        'accounts with this bank and use MASTER Memorisations.';
      end;

      if AskYesNo( 'Confirm Edit',
                   'Saving the changes to this Memorisation will re-code all Entries'+
                   ', which match this criteria, '+
                   'that are yet to be transferred or finalised. '#13#13+
                   'Please confirm you want to do this.' + ExtraMsg,
                   DLG_YES, 0) <> DLG_YES then exit;
   end;



   result := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgMemorise.SplitLineIsValid( LineNo : integer) : boolean;
begin
   Result := (Trim(SplitData[LineNo].AcctCode)<>'')
          or (SplitData[LineNo].Amount <>0)
          or (SplitData[LineNo].SF_Edited);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgMemorise.RemoveBlankLines;
var
   NewData : TSplitArray;
   i       : integer;
   NewC    : integer;

   procedure CopyLine( LineNo : integer);
   begin
      Inc(NewC);
      NewData[NewC] := SplitData[LineNo];
   end;

begin
   if not tblSplit.StopEditingState(True) then Exit;

   {initialise temp Array}
   NewC := 0;
   for i := Low(NewData) to High(NewData) do begin
      ClearWorkrecdetails(@NewData[i]);
   end;

   //copy valid lines to new array
   //copy $ amounts first
   for i := 1 to GLCONST.Max_mx_Lines do
     if SplitData[i].LineType = mltDollarAmt then
       if SplitLineIsValid(i) then
          CopyLine(i);

   //copy % amounts
   for i := 1 to GLCONST.Max_mx_Lines do
     if SplitData[i].LineType = mltPercentage then
       if SplitLineIsValid( i) then
         CopyLine( i);

   //now replace Splitdata
   if NewC > 0 then begin
      SplitData := NewData;
      tblSplit.Refresh;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitGetCellAttributes(Sender: TObject; RowNum,
  ColNum: Integer; var CellAttr: TOvcCellAttributes);
begin
  if (CellAttr.caColor = tblSplit.Color) then
    if (RowNum >= tblSplit.LockedRows) and (Odd(Rownum)) then CellAttr.caColor := AltLineColor;

end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitActiveCellChanged(Sender: TObject; RowNum,
  ColNum: Integer);
{var
   HelpCtx : integer;}
begin
{  HelpCtx := 0;

  case ColNum of
  AcctCol :
    HelpCtx := hcMemorisecode;
  GSTCodeCol :
    HelpCtx := hcMemoriseGSTClass;
  PercentCol:
    HelpCtx := hcMemoriseAmount;
  end;

  tblSplit.HelpContext := HelpCtx;
  MsgBar(HintMsg(HelpCtx),false);}
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.sbtnChartClick(Sender: TObject);
begin
  if not EditMode then
     tblSplit.SetFocus;
//  keybd_event(vk_f2,0,0,0); seems to be unreliable when called from the pop-up menu
  tblSplitUserCommand(Self, tcLookup);
end;

procedure TdlgMemorise.sbtnJobClick(Sender: TObject);
begin
  if not EditMode then
     tblSplit.SetFocus;
  tblSplitUserCommand(Self, tcJobLookup);
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.sbtnPayeeClick(Sender: TObject);
begin
  if not EditMode then
     tblSplit.SetFocus;
  tblSplitUserCommand(Self, tcPayeeLookup);
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.sbtnSuperClick(Sender: TObject);
begin
   if not EditMode then
      tblSplit.SetFocus;
   tblSplitUserCommand(Self, tcSuperEdit);
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.CompleteAmount;
var
  MoneyAmt : Money;
  RowNum   : integer;
  Fixed, TotalPerc : Money;
  RemainingPerc, RemainingDollar : Money;
  HasPercentLines : boolean;
  HasDollarLines  : boolean;

  MatchOnEquals : boolean;
begin
   if ((tblSplit.ActiveCol <> PercentCol) and (tblSplit.ActiveCol <> AmountCol)) or (EditMode) then exit;
   RowNum := tblSplit.ActiveRow;

   if not ( SplitData[ RowNum].LineType in [ mltPercentage, mltDollarAmt]) then
     Exit;

   //figure out remaining amount
   CalcRemaining( Fixed, TotalPerc, RemainingPerc, RemainingDollar, HasDollarLines, HasPercentLines);
   MatchOnEquals := GetComboCurrentIntObject(cmbValue) = mxAmtEqual;

   if MatchOnEquals and ( not HasPercentLines) then
   begin
     MoneyAmt := Double2Money(RemainingDollar + Double2Money(SplitData[RowNum].Amount));
     if MoneyAmt <> 0 then
       SplitData[ RowNum].LineType := mltDollarAmt;
   end
   else
   begin
     if SplitData[RowNum].LineType = mltPercentage then
         MoneyAmt := RemainingPerc + Double2Percent(SplitData[RowNum].Amount)
     else
     begin
       MoneyAmt := RemainingPerc;
       if MoneyAmt <> 0 then
         SplitData[ RowNum].LineType := mltPercentage;
     end;
   end;

   if (MoneyAmt <> 0) then
   begin
     SplitData[Rownum].Amount := Percent2Double(MoneyAmt);
     tblSplit.AllowRedraw := false;
     try
       Keybd_event(VK_LEFT   ,0,0,0);
       Keybd_event(VK_RIGHT   ,0,0,0);
       tblSplit.InvalidateRow( RowNum);
     finally
       tblSplit.AllowRedraw := true;
     end;
     UpdateTotal;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.ColAcctKeyPress(Sender: TObject; var Key: Char);
var
  Msg : TWMKey;
begin
  if key = '-' then begin
    if Assigned(myClient) and (myClient.clFields.clUse_Minus_As_Lookup_Key) then begin
      key := #0;
      Msg.CharCode := VK_F2;
      ColAcct.SendKeyToTable(Msg);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure TdlgMemorise.ColGSTCodeOwnerDraw(Sender: TObject;
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
  if not( (RowNum > 0) and (RowNum <= GLCONST.Max_mx_Lines)) then exit;
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
//------------------------------------------------------------------------------
function MemoriseEntry(BA : TBank_Account; tr : pTransaction_Rec; var IsAMasterMem : boolean) : boolean;
// create a new memorisation based on the transaction
//
// parameters: ba   Bank Account that transaction and memorisation belong to
//             tr   Transaction to base memorisation on
//
// Returns true if ok pressed and memorisation added
var
  MemDlg : TdlgMemorise;
  Memorised_Trans : TMemorisation;
  BankPrefix : BankPrefixStr;
//  MasterMemList : TMaster_Memorisations_List;
  MasterMemList : TMemorisations_List;
  SystemMemorisation: pSystem_Memorisation_List_Rec;
begin
   result := false;
   IsAMasterMem := false;

   if not(Assigned(ba) and Assigned(tr)) then exit;

   MemDlg := TdlgMemorise.Create(Application.MainForm);
   try
      with MemDlg,tr^ do
      begin
         BKHelpSetUp(MemDlg, BKH_Chapter_5_Memorisations);
         InEditMemorisationMode := false;
         SourceBankAccount := ba;
         EditMem := nil;
         EditMemorisedList := nil;
         if ((ba.IsManual) and chkMaster.Enabled) or SourceBankAccount.IsAForexAccount then begin
            chkMaster.Enabled := False;
            AllowMasterMemorised := False;
         end;
         LocaliseForm;

         if chkMaster.Enabled then begin
            AccountingSystem := MyClient.clFields.clAccounting_System_Used;
         end;
         chkMasterClick(nil);

         GSTClassEditable := Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used );

         lblType.Caption := IntToStr(txType) + ':' + MyClient.clFields.clshort_name[txType];
         eRef.text      := txReference;

         //only use first line
         if Pos( #13, txNotes) > 0 then
            eNotes.Text := Copy( txNotes, 1, Pos( #13, txNOtes) -1)
         else
            eNotes.text    := txNotes;

         AmountToMatch := txAmount;

         if AmountToMatch < 0 then
         begin
           AmountMultiplier := -1;
           lblMinus.Caption := 'CR';
         end
         else
         begin
           AmountMultiplier := 1;
           lblMinus.Caption := 'DR';
         end;

         nValue.AsFloat := GenUtils.Money2Double( AmountToMatch) * AmountMultiplier;

         case MyClient.clFields.clCountry of
            whNewZealand :
               Begin
                  eOther.Text   := txOther_Party;
                  eCode.Text    := txAnalysis;
                  ePart.text    := txParticulars;
                  eStatementDetails.Text := txStatement_Details;
               end;
            whAustralia, whUK :
               Begin
                  eCode.Text    := txParticulars; { Shows the Bank Type Information }
                  eOther.Text   := '';
                  ePart.Text    := '';
                  eStatementDetails.Text := txStatement_Details;
               end;
         end;

         //initialise form
         EditMode  := false;

         //init data, Filled in Create
         SplitData[1].Amount := 100.0;

         //set init values
         cmbValue.ItemIndex := -1;
         UpdateTotal;

         SourceTransaction := Tr;
         btnCopy.Visible := False;
         btnCopy.Enabled := False;

         //**************************
         if ShowModal = mrOK then begin
         //**************************

            //{have enough data to create a memorised entry record
            Memorised_Trans := TMemorisation.Create;
            SaveToMemRec(Memorised_Trans, Tr, chkMaster.Checked);

             //have details of the new master memorisation, now need to update to relevant location
             if chkMaster.Checked then
             begin
               //memorise to relevant master file then reload to get new global list
               BankPrefix := mxFiles32.GetBankPrefix( ba.baFields.baBank_Account_Number);

               //--ADD MASTER MEM---
               if LoadAdminSystem(true, 'MemoriseEntry') then begin
                 SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(BankPrefix);
                 if not Assigned(SystemMemorisation) then
                   UnlockAdmin
                 else begin
                   MasterMemList := TMemorisations_List(SystemMemorisation.smMemorisations);
                   if not Assigned( MasterMemList) then
                     MasterMemList := TMaster_Memorisations_List.Create(BankPrefix);
                   //insert into list
                   Memorised_Trans.mdFields.mdFrom_Master_List := true;
                   MasterMemList.Insert_Memorisation(Memorised_Trans);
                   IsAMasterMem := True;
                   //*** Flag Audit ***
                   SystemAuditMgr.FlagAudit(atMasterMemorisations);
                   SaveAdminSystem;
                 end;
               end else
                 HelpfulErrorMsg('Could not add master memorisation at this time. Admin System unavailable.', 0);
               //--END ADD MASTER MEM---

             end
             else
               ba.baMemorisations_List.Insert_Memorisation(Memorised_Trans);

             if txDate_Transferred <> 0 then
                HelpfulInfoMsg('The transaction was memorised OK.' + #13+#13+
                               'The transaction had already been transferred '+
                               'into your accounting software so the code won''t change '+
                               'when you close this dialog.  All future transactions that match the cr'+
                               'iteria you entered will be coded automatically.',0);

             Result := true;
         end; {execute}
        end; {with}
   finally
     MemDlg.Free;
   end;
end;

//------------------------------------------------------------------------------
function EditMemorisation(BA: TBank_Account; MemorisedList: TMemorisations_List;
  pM: TMemorisation; IsCopy: Boolean = False; Prefix: string = '') : boolean;
// edits an existing memorisation
//
// parameters: pM   Memorisation to edit
//
// Returns true if ok pressed
const
   ThisMethodName = 'EditMemorisation';
var
   MemDlg : TdlgMemorise;
   pAcct : pAccount_Rec;
   i     : integer;
   AmountMatchType : byte;
   MemLine : pMemorisation_Line_Rec;
   Memorised_Trans: TMemorisation;
   SystemMemorisation: pSystem_Memorisation_List_Rec;
   SaveSeq: integer;
begin
   Result := false;
   if not Assigned(pM) then
      Exit;

   MemDlg := TdlgMemorise.Create(Application.MainForm);
   with MemDlg do begin
      try
         BKHelpSetUp(MemDlg, BKH_Chapter_5_Memorisations);
         InEditMemorisationMode := true;
         EditMem  := pM;
         EditMemorisedList := MemorisedList;
         ExistingCode := '';
         //Controls will be initialise in the FormCreate method
         //load memorisation into form
         SourceBankAccount := ba;

         LocaliseForm;
         
         with pM do begin
            if mdFields.mdFrom_Master_List then
               Caption := 'Edit MASTER Memorisation'
            else
               Caption := 'Edit Memorisation';

            lblType.Caption := inttostr(mdFields.mdType) + ':' + MyClient.clFields.clShort_Name[mdFields.mdType];
            //set edit boxes
            eRef.Text              := mdFields.mdReference;
            case MyClient.clFields.clCountry of
               whNewZealand : begin
                  eCode.Text             := mdFields.mdAnalysis;
                  eStatementDetails.Text := mdFields.mdStatement_Details;
                  ePart.Text             := mdFields.mdParticulars;
                  eOther.Text            := mdFields.mdOther_Party;
               end;
               whAustralia, whUK : begin
                  eCode.Text             := mdFields.mdParticulars;
                  eStatementDetails.Text := mdFields.mdStatement_Details;
                  ePart.Text             := '';
                  eOther.Text            := '';
               end;
            end;

            if mdFields.mdFrom_Date > 0 then begin
               cbFrom.Checked := True;
               EdateFrom.AsStDate :=  BKNull2St(mdFields.mdFrom_Date);
            end else
               EdateFrom.AsStDate := -1;

            if mdFields.mdUntil_Date > 0 then begin
               cbTo.Checked := True;
               EdateTo.AsStDate :=  BKNull2St(mdFields.mdUntil_Date);
            end else
               EdateTo.AsStDate := -1;

            eNotes.Text     := mdFields.mdNOtes;
            //set amount and combo
            AmountToMatch   := mdFields.mdAmount;
            if AmountToMatch < 0 then
            begin
              AmountMultiplier := -1;
              lblMinus.Caption := 'CR';
            end
            else
            begin
              AmountMultiplier := 1;
              lblMinus.Caption := 'DR';
            end;
            nValue.AsFloat  := Money2Double( AmountToMatch) * AmountMultiplier;
            //set check boxes, set loading so click events dont fire
            Loading := true;

            cRef.Checked    := mdFields.mdMatch_on_Refce;
            case MyClient.clFields.clCountry of
               whNewZealand : begin
                  cCode.Checked  := mdFields.mdMatch_on_Analysis;
                  chkStatementDetails.Checked := mdFields.mdMatch_On_Statement_Details;
                  cPart.Checked  := mdFields.mdMatch_on_Particulars;
                  cOther.Checked := mdFields.mdMatch_on_Other_Party;
               end;
               whAustralia, whUK : begin
                  cCode.Checked  := mdFields.mdMatch_on_Particulars;
                  chkStatementDetails.Checked := mdFields.mdMatch_On_Statement_Details;
                  cPart.Checked  := false;
                  cOther.Checked := false;
               end;
            end;

            cNotes.Checked  := mdFields.mdMatch_on_Notes;

            cValue.Checked  := mdFields.mdMatch_on_Amount <> mxNo;
            AmountMatchType := mdFields.mdMatch_on_Amount;
            if AmountMultiplier = -1 then
            begin
              //need to reverse the match type because real value is -ve
              case AmountMatchType of
                mxAmtGreaterThan    : AmountMatchType := mxAmtLessThan;
                mxAmtGreaterOrEqual : AmountMatchType := mxAmtLessOrEqual;
                mxAmtLessThan       : AmountMatchType := mxAmtGreaterThan;
                mxAmtLessOrEqual    : AmountMatchType := mxAmtGreaterOrEqual;
              end;
            end;
            SetComboIndexByIntObject( AmountMatchType, cmbValue);

            chkMaster.Checked  := mdFields.mdFrom_Master_List;
            if mdFields.mdUse_Accounting_System then begin

               chkAccountSystem.Checked := True;
               if not assigned(adminSystem) then begin
                  // Better have something...
                  // Can be Au only
                  cbAccounting.items.Clear;
                  with MyClient.clFields do for i := saMin to saMax do begin
                     if ((not Software.ExcludeFromAccSysList(clCountry, i)) or ( i = claccounting_system_used)) then
                        cbAccounting.items.AddObject(saNames[i], TObject( i ) );
                  end;
               end;
               AccountingSystem := mdFields.mdAccounting_System;

               // Better see them...
               chkAccountSystem.Visible := True;
               cbAccounting.Visible := True;
            end else begin
               chkAccountSystem.Checked := False;
               AccountingSystem := MyClient.clFields.clAccounting_System_Used;
            end;
            chkMasterClick(nil);

            Loading := false;
            //fill detail
            for i := pM.mdLines.First to pM.mdLines.Last do
            begin
               MemLine := pM.mdLines.MemorisationLine_At(i);
               SplitData[ i+1].AcctCode         := MemLine^.mlAccount;
               SplitData[ i+1].GST_Has_Been_Edited := MemLine^.mlGST_Has_Been_Edited;
               pAcct := MyClient.clChart.FindCode( MemLine^.mlAccount);
               if Assigned( pAcct) then begin
                  SplitData[ i+1].Desc   := pAcct^.chAccount_Description;
               end
               else begin
                  SplitData[ i+1].Desc  := '';
               end;
               SplitData[ i+1].JobCode  := MemLine^.mlJob_Code;
               //load in the gst class code.  If this is master memorisation and the gst
               //has not been edited then load in the current default for the account code
               //There is no need to do this for client memorisations because they will be
               //updated when the chart is changed
               if mdFields.mdFrom_Master_List and ( not MemLine^.mlGST_Has_Been_Edited) then begin
                  //load default for chart
                  SplitData[ i+1].GSTClassCode  := GetGSTClassCode( MyClient, MyClient.clChart.GSTClass( MemLine^.mlAccount));
               end
               else begin
                  //memorisation stores class no so load in class id
                  SplitData[ i+1].GSTClassCode     := GetGSTClassCode( MyClient, MemLine^.mlGST_Class);
               end;
               if MemLine^.mlLine_Type = mltPercentage then
                  SplitData[ i+1].Amount := Percent2Double( MemLine^.mlPercentage)
               else
                  SplitData[ i+1].Amount := Money2Double( MemLine^.mlPercentage);
               SplitData[ i+1].Narration := MemLine^.mlGL_Narration;

               if MemLine^.mlAccount <> '' then
                  SplitData[ i+1].LineType := MemLine^.mlLine_Type
               else
                  SplitData[ i+1].LineType := pltPercentage;

               SplitData[ i+1].Payee := MemLine^.mlPayee;

               SplitData[ i+1].SF_PCFranked := MemLine^.mlSF_PCFranked;
               SplitData[ i+1].SF_PCUnFranked := MemLine^.mlSF_PCUnFranked;

               SplitData[ i+1].SF_Member_ID := MemLine^.mlSF_Member_ID;
               SplitData[ i+1].SF_Fund_ID   := MemLine^.mlSF_Fund_ID;
               SplitData[ i+1].SF_Fund_Code := MemLine^.mlSF_Fund_Code;
               SplitData[ i+1].SF_Trans_ID  := MemLine^.mlSF_Trans_ID;
               SplitData[ i+1].SF_Trans_Code  := MemLine^.mlSF_Trans_Code;
               SplitData[ i+1].SF_Member_Account_ID := MemLine^.mlSF_Member_Account_ID;
               SplitData[ i+1].SF_Member_Account_Code := MemLine^.mlSF_Member_Account_Code;
               SplitData[ i+1].SF_Member_Component := MemLine^.mlSF_Member_Component;

               SplitData[ i+1].Quantity := MemLine.mlQuantity;

               SplitData[ i+1].SF_GDT_Date := MemLine.mlSF_GDT_Date;
               SplitData[ i+1].SF_Tax_Free_Dist := MemLine.mlSF_Tax_Free_Dist;
               SplitData[ i+1].SF_Tax_Exempt_Dist := MemLine.mlSF_Tax_Exempt_Dist;
               SplitData[ i+1].SF_Tax_Deferred_Dist := MemLine.mlSF_Tax_Deferred_Dist;
               SplitData[ i+1].SF_TFN_Credits := MemLine.mlSF_TFN_Credits;
               SplitData[ i+1].SF_Foreign_Income := MemLine.mlSF_Foreign_Income;
               SplitData[ i+1].SF_Foreign_Tax_Credits := MemLine.mlSF_Foreign_Tax_Credits;
               SplitData[ i+1].SF_Capital_Gains_Indexed := MemLine.mlSF_Capital_Gains_Indexed;
               SplitData[ i+1].SF_Capital_Gains_Disc := MemLine.mlSF_Capital_Gains_Disc;
               SplitData[ i+1].SF_Capital_Gains_Other := MemLine.mlSF_Capital_Gains_Other;
               SplitData[ i+1].SF_Other_Expenses := MemLine.mlSF_Other_Expenses;
               SplitData[ i+1].SF_Interest := MemLine.mlSF_Interest;
               SplitData[ i+1].SF_Capital_Gains_Foreign_Disc := MemLine.mlSF_Capital_Gains_Foreign_Disc;
               SplitData[ i+1].SF_Rent := MemLine.mlSF_Rent;
               SplitData[ i+1].SF_Special_Income := MemLine.mlSF_Special_Income;
               SplitData[ i+1].SF_Other_Tax_Credit := MemLine.mlSF_Other_Tax_Credit;
               SplitData[ i+1].SF_Non_Resident_Tax := MemLine.mlSF_Non_Resident_Tax;
               SplitData[ i+1].SF_Foreign_Capital_Gains_Credit := MemLine.mlSF_Foreign_Capital_Gains_Credit;
               SplitData[ i+1].SF_Capital_Gains_Fraction_Half := MemLine.mlSF_Capital_Gains_Fraction_Half;
               SplitData[ i+1].SF_Edited := MemLine^.mlSF_Edited;
            end;
         end;
         //Show Total Line
         UpdateTotal;
         //turn off memorise to master
         chkMaster.Enabled := false;
         AllowMasterMemorised := False; // Sounds wrong, but also used for 'Can I Change MasterMem'.. You Cannot ...
         //turn off editing of gst col if master
         //or if using Ledger Elite

         GSTClassEditable := Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used );
         if chkMaster.Checked then GSTClassEditable := False;

         if not GSTClassEditable then
           ColGSTCode.Font.Color := clGrayText;

         SourceTransaction := nil;

   //**********************
         case ShowModal of
           mrok : begin
               //save new values back
               if chkMaster.Checked then begin
                 //---EDIT MASTER MEM---
                 SaveSeq := pM.mdFields.mdSequence_No;
                 if LoadAdminSystem(true, ThisMethodName) then begin
                   SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(Prefix);
                   if not Assigned(SystemMemorisation) then begin
                     UnlockAdmin;
                     HelpfulErrorMsg('The master memorisation can no longer be found in the Admin System.', 0);
                     Exit;
                   end else if not Assigned(SystemMemorisation.smMemorisations) then begin
                     UnlockAdmin;
                     HelpfulErrorMsg('The master memorisation can no longer be found in the Admin System.', 0);
                     Exit;
                   end else begin
                     EditMemorisedList := TMemorisations_List(SystemMemorisation.smMemorisations);
                     //Find and save memorisation
                     for i := EditMemorisedList.First to EditMemorisedList.Last do begin
                       Memorised_Trans := EditMemorisedList.Memorisation_At(i);
                       if Assigned(Memorised_Trans) then begin
                         if (Memorised_Trans.mdFields.mdSequence_No = SaveSeq) then begin
                           SaveToMemRec(Memorised_Trans, nil, chkMaster.Checked);
                           Break;
                         end;
                       end;
                     end;
                     //*** Flag Audit ***
                     SystemAuditMgr.FlagAudit(atMasterMemorisations);
                     SaveAdminSystem;
                   end;
                 end else
                   HelpfulErrorMsg('Could not update master memorisation at this time. Admin System unavailable.', 0);
                 //---END EDIT MASTER MEM---
               end else
                 SaveToMemRec(pM, nil, chkMaster.Checked);
               Result := true;
           end;
           mrCopy : begin
               SaveToMemRec(pM, nil, chkMaster.Checked);// Save this one..
               //{have enough data to create a memorised entry record
               Memorised_Trans := TMemorisation.Create;
               SaveToMemRec(Memorised_Trans, nil, chkMaster.Checked);
               Memorised_Trans.mdFields.mdType := pm.mdFields.mdType;
               if chkMaster.Checked then begin
                  //save master mem list
//                  TMaster_Memorisations_List(MemorisedList).SaveToFile;
//                  EditMemorisation(ba,MemorisedList,Memorised_Trans, True);
                 //---COPY MASTER MEM---
                 if LoadAdminSystem(true, ThisMethodName) then begin
                   SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(Prefix);
                   if not Assigned(SystemMemorisation) then begin
                     UnlockAdmin;
                     HelpfulErrorMsg('The master memorisation can no longer be found in the Admin System.', 0);
                     Exit;
                   end else if not Assigned(SystemMemorisation.smMemorisations) then begin
                     UnlockAdmin;
                     HelpfulErrorMsg('The master memorisation can no longer be found in the Admin System.', 0);
                     Exit;
                   end else begin
                     Memorised_Trans.mdFields.mdFrom_Master_List := True;
                     EditMemorisedList := TMemorisations_List(SystemMemorisation.smMemorisations);
                     EditMemorisedList.Insert_Memorisation(Memorised_Trans);
                     SaveSeq := Memorised_Trans.mdFields.mdSequence_No;
                     //*** Flag Audit ***
                     SystemAuditMgr.FlagAudit(atMasterMemorisations);
                     SaveAdminSystem;
                     Memorised_Trans.mdFields.mdSequence_No := SaveSeq;

                     //Have to get list again after save
                     SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(Prefix);
                     if Assigned(SystemMemorisation) then
                       MemorisedList := TMemorisations_List(SystemMemorisation.smMemorisations);

                     //Edit copy
                     if Assigned(MemorisedList) then
                       EditMemorisation(ba, MemorisedList, Memorised_Trans, True, Prefix);
                   end;
                 end else
                   HelpfulErrorMsg('Could not update master memorisation at this time. Admin System unavailable.', 0);
                 //---END COPY MASTER MEM---
               end else begin
                  MemorisedList.Insert_Memorisation(Memorised_Trans);
                  EditMemorisation(ba,ba.baMemorisations_List,Memorised_Trans, True);
               end;
               Result := true;

           end;
           else if iscopy then begin
               //need to remove the copy..
               if pm.mdFields.mdFrom_Master_List then begin
                   MemorisedList.DelFreeItem(pm);
//                   TMaster_Memorisations_List(MemorisedList).SaveToFile;
               end else begin
                   ba.baMemorisations_List.DelFreeItem(pm);
               end;
               Result := True;
           end;
         end;
   //**********************

      finally
         Free;
      end;
   end;
end;
//------------------------------------------------------------------------------

function TdlgMemorise.HasJobs: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to GLCONST.Max_mx_Lines do
    if SplitData[i].JobCode > '' then
    begin
      Result := True;
      exit;
    end;
end;

function TdlgMemorise.HasPayees: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to GLCONST.Max_mx_Lines do
    if SplitData[i].Payee <> 0 then
    begin
      Result := True;
      exit;
    end;
end;

procedure TdlgMemorise.chkMasterClick(Sender: TObject);
var
   i          : integer;
   GSTEdited  : Boolean;

   procedure SetJobPayee(Value: Boolean);
   begin
      sbtnPayee.Enabled := Value;
      sbtnJob.Enabled := Value;
      LookupJob1.Enabled := Value;
      LookupPayee1.Enabled := Value;
      if value then begin
         colPayee.Access := otxDefault;
         colJob.Access := otxDefault;
      end else begin
         colPayee.Access := otxReadOnly;
         colJob.Access := otxReadOnly;
      end;
   end;
   
begin
   if chkMaster.Checked then begin
      if Assigned(AdminSystem) then begin
         chkAccountSystem.Visible := AdminSystem.DualAccountingSystem;
         cbAccounting.Visible := chkAccountSystem.Visible;
      end else begin
         chkAccountSystem.Visible := False;
         cbAccounting.Visible := False;
      end;
      SetJobPayee(False);
   end else begin
      chkAccountSystem.Visible := False;
      cbAccounting.Visible := False;
      SetJobPayee(True);
   end;
   chkAccountSystemClick(nil);
   if Loading
   or InEditMemorisationMode then
      Exit;
   //must be in create mode
   //if checked then make sure we have default GST Classes.
   if chkMaster.Checked then begin
      GSTEdited := False;
      for i := 1 to GLCONST.Max_mx_Lines do
         if SplitData[i].GST_Has_Been_Edited then begin
            GSTEdited := true;
            Break;
         end;
      if GSTEdited then begin
         chkMaster.Checked := False;
         HelpfulInfoMsg( 'You cannot memorise at a MASTER level if you have altered the GST Class column in the memorisation. '+
                             #$0D+#$0D+'MASTER memorised entries always apply GST at the default rate for the account in the client''s chart.', 0 );
         Exit;

      end;


      for i := 1 to GLCONST.Max_mx_Lines do
         if SplitData[i].SF_Edited
         and ((SplitData[i].SF_Fund_ID > -1) or (SplitData[i].SF_Member_Account_ID > -1))   then begin
            GSTEdited := true;
            Break;
         end;
      if GSTEdited then begin
         chkMaster.Checked := False;
         HelpfulInfoMsg( 'You cannot memorise at a MASTER level if you have fund specific selections in the memorisation.', 0 );
         Exit;

      end;

      if HasPayees
      or HasJobs then
         HelpfulInfoMsg('Payees or Jobs cannot be used in Master Memorisations.'#13'The Payees or Jobs you have used in this memorisation will not be saved.', 0);


   end;
end;
//------------------------------------------------------------------------------

procedure TdlgMemorise.ColAcctOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
// If the code is invalid, show it in red
var
  R: TRect;
  S: String;
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
      or MyClient.clChart.CanCodeTo(S,HasAlternativeChartCode (MyClient.clFields.clCountry,MyClient.clFields.clAccounting_System_Used)) then begin
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

procedure TdlgMemorise.cNotesClick(Sender: TObject);
begin
   eNotes.Enabled := cNOtes.Checked;
   if not Loading then
      if eNOtes.enabled then eNotes.setFocus;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgMemorise.FormResize(Sender: TObject);
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
      if Columns[NarrationCol ].Width <= 0 then
      begin
        Columns[NarrationCol].Width := 100;
        Columns[PercentCol].Width := Columns[PercentCol].Width - 25;
        Columns[DescCol].Width := Columns[DescCol].Width - 75;
      end;
   end;
end;

procedure TdlgMemorise.FormShow(Sender: TObject);
   procedure AutoSize(value: tCheckBox);
   begin
      Value.Width := Canvas.TextWidth(Value.caption) + 15;
   end;
begin
  AutoSize(chkMaster);
  AutoSize(chkAccountSystem);
end;

function TdlgMemorise.GetAccountingSystem: Integer;
begin
   Result := GetComboCurrentIntObject(cbAccounting, snother);
end;

procedure TdlgMemorise.chkStatementDetailsClick(Sender: TObject);
begin
   eStatementDetails.Enabled := chkStatementDetails.Checked;
   if not Loading then
      if eStatementDetails.enabled then eStatementDetails.setFocus;
end;

procedure TdlgMemorise.ClearSuperfundDetails1Click(Sender: TObject);
begin
   if not EditMode then
      tblSplit.SetFocus;
   tblSplitUserCommand(Self, tcSuperClear);
end;

procedure TdlgMemorise.cValueClick(Sender: TObject);
begin
   cmbValue.Enabled := cValue.Checked;
   nValue.Enabled   := cValue.Checked;

   //set default value
   if not cValue.Checked then
     cmbValue.ItemIndex := -1
   else
     if cmbValue.ItemIndex = -1 then
       SetComboIndexByIntObject( mxAmtEqual, cmbValue);

   //set first line
   SetFirstLineDefaultAmount;

   if not Loading then
     if cmbValue.enabled then cmbValue.setFocus;
end;

procedure TdlgMemorise.nValueChange(Sender: TObject);
begin
  AmountToMatch := Double2Money( nValue.AsFloat) * AmountMultiplier;
  UpdateTotal;
end;

procedure TdlgMemorise.nValueKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = '-' then
    Key := #0;
end;

procedure TdlgMemorise.SaveToMemRec(var pM: TMemorisation; pT: pTransaction_Rec; IsMaster: Boolean);
var
  i : integer;
  MemLine : pMemorisation_Line_Rec;
begin
  with pM do begin
     //see if this is a new memorisation
     if Assigned(pT) then
     begin
       mdFields.mdType := pT^.txType;
       mdFields.mdSequence_No := 0;
     end;

     mdFields.mdAmount    := AmountToMatch;
     mdFields.mdReference := eRef.text;
     mdFields.mdNotes     := eNOtes.text;

     if cbFrom.Checked then
        mdFields.mdFrom_Date := StNull2BK( EDateFrom.AsStDate)
     else
        mdFields.mdFrom_Date := 0;

     if cbTo.Checked then
        mdFields.mdUntil_Date := StNull2BK( EDateTo.AsStDate)
     else
        mdFields.mdUntil_Date := 0;

     //save amount match type
     if cValue.Checked then
     begin
       mdFields.mdMatch_on_Amount        := GetComboCurrentIntObject(cmbValue);

       if AmountMultiplier = -1 then
       begin
         //need to reverse the match type because real value is -ve
         case mdFields.mdMatch_on_Amount of
           mxAmtGreaterThan    : mdFields.mdMatch_on_Amount := mxAmtLessThan;
           mxAmtGreaterOrEqual : mdFields.mdMatch_on_Amount := mxAmtLessOrEqual;
           mxAmtLessThan       : mdFields.mdMatch_on_Amount := mxAmtGreaterThan;
           mxAmtLessOrEqual    : mdFields.mdMatch_on_Amount := mxAmtGreaterOrEqual;
         end;
       end;
     end
     else
       mdFields.mdMatch_on_Amount  := mxNo;

     mdFields.mdMatch_on_Refce     := (cRef.Checked);
     mdFields.mdMatch_On_Notes     := (cNotes.Checked);

     //save country specific fields
     case MyClient.clFields.clCountry of
        whNewZealand :
           Begin
              mdFields.mdAnalysis               := eCode.text;
              mdFields.mdParticulars            := ePart.text;
              mdFields.mdOther_Party            := eOther.text;
              mdFields.mdStatement_Details      := eStatementDetails.text;

              mdFields.mdMatch_on_other_party   := (cOther.Checked);
              mdFields.mdMatch_on_Particulars   := (cPart.Checked);
              mdFields.mdMatch_on_Analysis      := (cCode.Checked);
              mdFields.mdMatch_On_Statement_Details := ( chkStatementDetails.checked);
           end;
        whAustralia, whUK :
           Begin
              mdFields.mdParticulars                := eCode.text;
              mdFields.mdStatement_Details          := eStatementDetails.text;

              mdFields.mdMatch_on_Particulars       := cCode.Checked;
              mdFields.mdMatch_On_Statement_Details := chkStatementDetails.checked;
           end;
     end;

     if IsMaster then begin
        mdFields.mdUse_Accounting_System := chkAccountSystem.Checked;
        mdFields.mdAccounting_System := AccountingSystem; // Only When checked..
     end else begin
        mdFields.mdUse_Accounting_System := False;
        mdFields.mdAccounting_System := 0; // -1 ??
     end;


     pM.mdLines.FreeAll;
     for i := 1 to GLCONST.Max_mx_Lines do
     begin
       if SplitLineIsValid( i) then
       begin
         MemLine := BKMLIO.New_Memorisation_Line_Rec;
         with MemLine^ do
         begin
           mlAccount := SplitData[i].AcctCode;
           if SplitData[i].LineType = mltPercentage then
              mlPercentage := Double2Percent(SplitData[i].Amount)
           else
              mlPercentage := Double2Money(SplitData[i].Amount);
           mlGst_Class := GetGSTClassNo( MyClient, SplitData[i].GSTClassCode);
           mlGST_Has_Been_Edited := SplitData[i].GST_Has_Been_Edited;
           mlGL_Narration  := SplitData[i].Narration;


           if SplitData[i].LineType = -1 then
              mlLine_Type := 0
           else
              mlLine_Type := SplitData[i].LineType;
           // No payees or Jobs for master mems
           if IsMaster then begin
              mlPayee := 0;
              mlJob_Code := '';
           end else begin
              mlPayee := SplitData[i].Payee;
              mlJob_Code := SplitData[i].JobCode;
           end;
           mlSF_PCFranked := SplitData[i].SF_PCFranked;
           mlSF_PCUnFranked := SplitData[i].SF_PCUnFranked;
           mlSF_Member_ID := SplitData[i].SF_Member_ID;
           mlSF_Fund_ID := SplitData[i].SF_Fund_ID;
           mlSF_Fund_Code := SplitData[i].SF_Fund_Code;
           mlSF_Trans_ID := SplitData[i].SF_Trans_ID;
           mlSF_Trans_Code := SplitData[i].SF_Trans_Code;

           mlSF_Member_Account_ID := SplitData[i].SF_Member_Account_ID;
           mlSF_Member_Account_Code := SplitData[i].SF_Member_Account_Code;
           mlSF_Member_Component := SplitData[i].SF_Member_Component;

           mlQuantity := SplitData[i].Quantity;

           mlSF_GDT_Date := SplitData[i].SF_GDT_Date;
           mlSF_Tax_Free_Dist := SplitData[i].SF_Tax_Free_Dist;
           mlSF_Tax_Exempt_Dist := SplitData[i].SF_Tax_Exempt_Dist;
           mlSF_Tax_Deferred_Dist := SplitData[i].SF_Tax_Deferred_Dist;
           mlSF_TFN_Credits := SplitData[i].SF_TFN_Credits;
           mlSF_Foreign_Income := SplitData[i].SF_Foreign_Income;
           mlSF_Foreign_Tax_Credits := SplitData[i].SF_Foreign_Tax_Credits;
           mlSF_Capital_Gains_Indexed := SplitData[i].SF_Capital_Gains_Indexed;
           mlSF_Capital_Gains_Disc := SplitData[i].SF_Capital_Gains_Disc;
           mlSF_Capital_Gains_Other := SplitData[i].SF_Capital_Gains_Other;
           mlSF_Other_Expenses := SplitData[i].SF_Other_Expenses;
           mlSF_Interest := SplitData[i].SF_Interest;
           mlSF_Capital_Gains_Foreign_Disc := SplitData[i].SF_Capital_Gains_Foreign_Disc;
           mlSF_Rent := SplitData[i].SF_Rent;
           mlSF_Special_Income := SplitData[i].SF_Special_Income;
           mlSF_Other_Tax_Credit := SplitData[i].SF_Other_Tax_Credit;
           mlSF_Non_Resident_Tax := SplitData[i].SF_Non_Resident_Tax;
           mlSF_Foreign_Capital_Gains_Credit := SplitData[i].SF_Foreign_Capital_Gains_Credit;
           mlSF_Capital_Gains_Fraction_Half := SplitData[i].SF_Capital_Gains_Fraction_Half;



           mlSF_edited := SplitData[i].SF_edited;
         end;
         pM.mdLines.Insert(MemLine);
       end;
     end;

     Assert( pM.mdLines.ItemCount > 0, 'Memorisation is empty');
   end;
end;

procedure TdlgMemorise.ColAmountKeyPress(Sender: TObject; var Key: Char);
var
  RowNum, ColNum : integer;
  V: Double;
begin
  RowNum := tblSplit.ActiveRow;
  ColNum := tblSplit.ActiveCol;

  {treat value as percentage}
  if key in [ '$', '£', '%', '€' ] then
  begin
    V := SplitData[tblSplit.ActiveRow].Amount;

    tblSplit.StopEditingState( true);

    if ((Key = '%') and (ColNum = PercentCol) and (SplitData[tblSplit.ActiveRow].Amount = 0)) or
       ((Key in [ '$', '£', '€' ]) and (ColNum = AmountCol) and (SplitData[tblSplit.ActiveRow].Amount = 0)) or
       ((SplitData[tblSplit.ActiveRow].Amount = 0) and (V <> 0)) then
      SplitData[tblSplit.ActiveRow].Amount := V;

    if key = '%' then
      SplitData[ RowNum].LineType := mltPercentage;

    if key in [ '$', '£', '€' ] then
      SplitData[ RowNum].LineType := mltDollarAmt;

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

procedure TdlgMemorise.ColGSTCodeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg : TWMKey;
begin
  //check for lookup key
  if ( Key = VK_F7 ) then begin
    Msg.CharCode := VK_F7;
    ColGSTCode.SendKeyToTable(Msg);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgMemorise.DoDitto;
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
         AcctCol: begin
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

         JobCol:
           begin
            if (Trim(TEdit(ColJob.CellEditor).Text) = '') then begin
              TEdit(ColJob.CellEditor).Text := SplitData[tblSplit.ActiveRow-1].JobCode;
              DittoOK := true;
            end;
           end;

         NarrationCol: begin
            if (Trim(TEdit(ColNarration.CellEditor).Text) = '') then begin
              TEdit(ColNarration.CellEditor).Text := SplitData[tblSplit.ActiveRow-1].Narration;
              DittoOK := true;
            end;
         end;

         GSTCodeCol : begin
            if (Trim(TEdit(ColGSTCode.CellEditor).Text) = '') then begin
               TEdit(ColGSTCode.CellEditor).Text := SplitData[tblSplit.ActiveRow-1].GSTClassCode;
               DittoOK := true;
            end;
         end;

         AmountCol: begin
            if (TOvcNumericField(ColPercent.CellEditor).AsFloat = 0) then begin
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

         PayeeCol: begin
            if (TOvcNumericField(ColPayee.CellEditor).AsInteger = 0) then begin
               TOvcNumericField(ColPayee.CellEditor).AsInteger := SplitData[tblSplit.ActiveRow-1].Payee;
               DittoOK := true;
            end;
         end;
      end;

      if DittoOK then begin
         //if field was updated then save the edit and move right
         if not StopEditingState(True) then exit;
         if (FieldID in [AcctCol, DescCol, NarrationCol, GSTCodeCol,
            AmountCol, PercentCol, TypeCol, PayeeCol]) then
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

procedure TdlgMemorise.tblSplitEnteringRow(Sender: TObject;
  RowNum: Integer);
begin
  sBar.Panels[0].Text := Format( '%d of %d', [ tblSplit.ActiveRow, GLCONST.Max_mx_Lines ] );
  ExistingCode := SplitData[tblSplit.ActiveRow].AcctCode;
end;

// #1727 - add more shortcuts to the right-click menu

procedure TdlgMemorise.LocaliseForm;
var LCur: string[5];
begin
  if Assigned( SourceBankAccount)  then
     LCur := SourceBankAccount.CurrencySymbol
  else
     LCur := MyClient.CurrencySymbol;

  colLineType.Items.Clear;
  colLineType.Items.Add( '%' );
  colLineType.Items.Add( LCur );

  FCountry := MyClient.clFields.clCountry;
  FTaxName := MyClient.TaxSystemNameUC;
  Header.Headings[ GSTCodeCol ] := FTaxName;
  Header.Headings[ TypeCol ] := '%' + '/' + LCur;


  lblFixedHdr.Caption := 'Fixed ' + LCur;
  lblRemDollarHdr.Caption := 'Rem ' + LCur;

  With FixedAmount1 do
      Caption := 'Apply &fixed amount                             ' + LCur;
      
  With LookupGSTClass1 do
     Caption := Localise( FCountry, Caption );
end;


procedure TdlgMemorise.LookupGSTClass1Click(Sender: TObject);
begin
  Self.DoGSTLookup;
end;

procedure TdlgMemorise.CopyContentoftheCellAbove1Click(Sender: TObject);
begin
  Self.DoDitto;
end;

procedure TdlgMemorise.AmountApplyRemainingAmount1Click(Sender: TObject);
var
  Col: Integer;
begin
  Col := -1;
  with tblSplit do
  begin
    if (ActiveCol <> PercentCol) and (ActiveCol <> AmountCol) then
    begin
      if not StopEditingState(True) then Exit;
      Col := ActiveCol;
      ActiveCol := PercentCol;
    end;
    Self.CompleteAmount;
    if Col > -1 then
      ActiveCol := Col;
  end;
end;

procedure TdlgMemorise.FixedAmount1Click(Sender: TObject);
begin
  if SplitData[tblSplit.ActiveRow].LineType = mltDollarAmt then exit;
  ApplyAmountShortcut('$');
end;

procedure TdlgMemorise.PercentageofTotal1Click(Sender: TObject);
begin
  if SplitData[tblSplit.ActiveRow].LineType = mltPercentage then exit;
  ApplyAmountShortcut('%');
end;

procedure TdlgMemorise.popMemPopup(Sender: TObject);
begin
   if sbtnSuper.Visible then begin
       ClearSuperfundDetails1.Visible := SplitData[tblSplit.ActiveRow].SF_Edited;
   end;
end;

procedure TdlgMemorise.ApplyAmountShortcut(Key: Char);
var
  Col: Integer;
begin
  Col := -1;
  with tblSplit do
  begin
    if (ActiveCol <> PercentCol) and (ActiveCol <> AmountCol) then
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

procedure TdlgMemorise.tblSplitMouseDown(Sender: TObject;
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
    ShowPopup( x,y,popMem);
  end;
{$ENDIF}
end;

procedure TdlgMemorise.ShowPopUp( x, y : Integer; PopMenu :TPopUpMenu );
var
   ClientPt, ScreenPt : TPoint;
begin
   ClientPt.x := x;
   ClientPt.y := y;
   ScreenPt   := tblSplit.ClientToScreen(ClientPt);
   PopMenu.Popup(ScreenPt.x, ScreenPt.y);
end;

procedure TdlgMemorise.ColAcctKeyUp(Sender: TObject; var Key: Word;
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
  if MyClient.clChart.CanPressEnterNow(Account,True) then
  begin
     TEdit(ColAcct.CellEditor).text := Account;
     if (ExistingCode = '') and // new row started and previous row had a payee
        (tblSplit.ActiveRow > 1) and (SplitData[tblSplit.ActiveRow-1].Payee <> 0) then
     begin
        SplitData[tblSplit.ActiveRow].Payee := SplitData[tblSplit.ActiveRow-1].Payee;
        tblSplit.InvalidateCell(tblSplit.ActiveRow, PayeeCol);
     end;
     SplitData[tblSplit.ActiveRow].AcctCode := Account;
     ExistingCode := Account;
     Msg.CharCode := VK_RIGHT;
     ColAcct.SendKeyToTable(Msg);
  end;
end;

procedure TdlgMemorise.ColAcctExit(Sender: TObject);
begin
  if not MyClient.clChart.CodeIsThere(TEdit(colAcct.CellEditor).Text) then
    bkMaskUtils.CheckRemoveMaskChar(TEdit(colAcct.CellEditor),RemovingMask);
end;

procedure TdlgMemorise.ColPayeeOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
// If the payee is invalid, show it in red
var
  R   : TRect;
  C   : TCanvas;
  S   : Integer;
begin
   If ( data = nil ) then exit;
   //if selected dont do anything
   if CellAttr.caColor = clHighlight then exit;
   S := Integer( Data^ );
   If (S=0) or Assigned(MyClient.clPayee_List.Find_Payee_Number(S)) then exit;
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
   DrawText(C.Handle, PChar( IntToStr(S) ), StrLen( PChar( IntToStr(S) ) ), R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
   DoneIt := True;
end;

procedure TdlgMemorise.ColPayeeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg : TWMKey;
begin
  //check for lookup key
  if ( Key = VK_F3 ) then begin
    Msg.CharCode := VK_F3;
    ColGSTCode.SendKeyToTable(Msg);
  end;
end;

procedure TdlgMemorise.DoPayeeLookup;
var
   Msg           : TWMKey;
   InEditOnEntry : boolean;
   PayeeCode : Integer;
begin
    with tblSplit do begin
       if not StopEditingState(True) then
          Exit;
       if (ActiveCol <> PayeeCol) then
          ActiveCol := PayeeCol;

       InEditOnEntry := InEditingState;
       if not InEditOnEntry then begin
          if not StartEditingState then Exit;   //returns true if already in edit state
       end;

       PayeeCode := TOvcNumericField(colPayee.CellEditor).AsInteger;
       if PickPayee(PayeeCode) then begin
           //if get here then have a valid char from the picklist
           TOvcNumericField(colPayee.CellEditor).AsInteger := PayeeCode;
           Msg.CharCode := VK_RIGHT;
           colPayee.SendKeyToTable(Msg);
       end
       else begin
           if not InEditOnEntry then begin
              StopEditingState(true);  //end edit
           end;
       end;
    end;
end;

procedure TdlgMemorise.DoSuperClear;
begin
    with tblSplit do begin
      if not StopEditingState(True) then
         Exit;
      if ActiveRow <= 0 then
         Exit;

      ClearSuperfundDetails(@SplitData[ActiveRow]);

      tblSplit.AllowRedraw := false;
      try
         tblSplit.InvalidateRow(ActiveRow);
      finally
         tblSplit.AllowRedraw := true;
      end;

    end;
end;

procedure TdlgMemorise.DoSuperEdit;
var Move: TFundNavigation;
    BA: TBank_Account;
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

       if chkMaster.Checked then
          BA := nil
       else
          BA := SourceBankAccount;

       if SuperFieldsUtils.EditSuperFields( SourceTransaction,SplitData[ActiveRow] , Move, FSuperTop, FSuperLeft,sfMem, BA) then
       begin
          // Confirm if we still can Use MasterMem
          { Moved to the Tick box to follow GST and Payee
          if Assigned(SourceBankAccount)
          and AllowMasterMemorised then begin
             if (SplitData[ActiveRow].SF_Fund_ID <> -1)
             or (SplitData[ActiveRow].SF_Member_Account_ID <> -1) then begin
                if chkMaster.Enabled then begin
                   chkMaster.Enabled := False;
                   chkMaster.Checked := False;
                   chkMasterClick(nil);
                end;
             end else begin
                chkMaster.Enabled := True;
             end;
          end;
          }
          tblSplit.AllowRedraw := false;
          try
             UpdateFields(tblSplit.ActiveRow);
             tblSplit.InvalidateRow(ActiveRow);
          finally
             tblSplit.AllowRedraw := true;
          end;
          tblSplit.Refresh;

          if Move = fnGoForward then
          begin
            ActiveRow := ActiveRow + 1;
            DoSuperEdit;
          end
          else if Move = fnGoBack then
          begin
            ActiveRow := ActiveRow - 1;
            DoSuperEdit;
          end;
        end;


   end;
end;

procedure TdlgMemorise.eDateFromDblClick(Sender: TObject);
var ld: Integer;
begin
   if sender is TOVcPictureField then begin
      ld := TOVcPictureField(Sender).AsStDate;
      PopUpCalendar(TEdit(Sender),ld);
      TOVcPictureField(Sender).AsStDate := ld;
   end;
end;



initialization
   debugMe := debugUnit(UnitName);
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
end.

