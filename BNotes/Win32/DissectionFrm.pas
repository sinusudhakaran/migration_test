unit DissectionFrm;
//------------------------------------------------------------------------------
{
   Title:       Dissection Form

   Description:

   Remarks:

   Author:      Matthew Hopkins  Aug 2001

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  BaseFrm, ExtCtrls, RzCommon, RzEdit, StdCtrls, RzCmboBx, Mask,
  RzPanel, Grids_ts, TSGrid,
  ecDefs, ecObj, glConst, bkconst, moneydef, TSMask, RzBorder, RzButton,
  RzRadChk, ECPayeeObj, Menus;

type
  PWork_Dissect_Rec = ^TWork_Dissect_Rec;
  TWork_Dissect_Rec = Record
     dtAccount             : Bk5CodeStr;
     dtAmount              : Money;
     dtGST_Class           : Byte;
     dtGST_Amount          : Money;
     dtPayee_Number        : Integer;
     dtJob_Code            : String;
     dtQuantity            : Money;
     dtNarration           : String[ MaxNarrationEditLength ];
     dtNotes               : String;
     dtHas_Been_Edited     : Boolean;
     dtGST_Has_Been_Edited : Boolean;
     dtSF_Edited           : Boolean;
     dtSF_Franked          : Money;
     dtSF_Unfranked        : Money;
     dtSF_Franking_Credit  : Money;
     dtTaxInvoice          : Boolean;
     dtTransaction         : pTransaction_Rec;
  end;

type
  TfrmDissection = class(TfrmBase)
    pnlTop: TPanel;
    pnlCoding: TPanel;
    tgDissect: TtsGrid;
    Panel1: TPanel;
    Label5: TLabel;
    lblTotal: TLabel;
    Label14: TLabel;
    lblRemain: TLabel;
    RzFrameController1: TRzFrameController;
    MaskSet: TtsMaskDefs;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    pnlBottom: TPanel;
    pnlPanel: TPanel;
    lblAccount: TLabel;
    lblAccountName: TLabel;
    lblPayee: TLabel;
    Label9: TLabel;
    lblGST: TLabel;
    lblQuantity: TLabel;
    lblNarration: TLabel;
    Label2: TLabel;
    tgAccountLookup: TtsGrid;
    rzAmount: TRzNumericEdit;
    rzGSTAmount: TRzNumericEdit;
    rzQuantity: TRzNumericEdit;
    rzNarration: TRzEdit;
    rzNotes: TRzMemo;
    pnlHeader: TPanel;
    Label1: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    lblDate: TLabel;
    lblNarrationField: TLabel;
    lblPayeeName: TLabel;
    tgPayeeLookup: TtsGrid;
    rbtnPrev: TButton;
    rbtnNext: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    chkShowPanel: TRzCheckBox;
    Label3: TLabel;
    Label6: TLabel;
    lblAmount: TLabel;
    lblRef: TLabel;
    rzFakeAccountBorder: TRzEdit;
    rzFakePayeeBorder: TRzEdit;
    imgCoded: TImage;
    tmrHideHint: TTimer;
    PopupMenu1: TPopupMenu;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Copycontentsofthecellabove1: TMenuItem;
    btnSuper: TButton;
    N1: TMenuItem;
    EditSuperFields1: TMenuItem;
    lblJob: TLabel;
    tgJobLookup: TtsGrid;
    rzFakeJobBorder: TRzEdit;
    chkTaxInv: TCheckBox;
    lblJobName: TLabel;

    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;

    procedure tgDissectCellLoaded(Sender: TObject; DataCol, DataRow: Integer;
      var Value: Variant);
    procedure FormCreate(Sender: TObject);
    procedure tgDissectRowLoaded(Sender: TObject; DataRow: Integer);
    procedure tgDissectRowChanged(Sender: TObject; OldRow,
      NewRow: Integer);
    procedure tgDissectCellChanged(Sender: TObject; OldCol, NewCol, OldRow,
      NewRow: Integer);
    procedure tgDissectCellEdit(Sender: TObject; DataCol, DataRow: Integer;
      ByUser: Boolean);
    procedure tgDissectComboDropDown(Sender: TObject; Combo: TtsComboGrid;
      DataCol, DataRow: Integer);
    procedure tgDissectComboRollUp(Sender: TObject; Combo: TtsComboGrid;
      DataCol, DataRow: Integer);
    procedure tgDissectComboInit(Sender: TObject; Combo: TtsComboGrid;
      DataCol, DataRow: Integer);
    procedure ChartLookupCellLoaded(Sender: TObject; DataCol,
      DataRow: Integer; var Value: Variant);
    procedure tgDissectEndCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure tgAccountLookupKeyPress(Sender: TObject; var Key: Char);
    procedure tgAccountLookupCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; ByUser: Boolean);
    procedure tgAccountLookupCellLoaded(Sender: TObject; DataCol,
      DataRow: Integer; var Value: Variant);
    procedure tgAccountLookupEndCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure rbtnNextClick(Sender: TObject);
    procedure pfEdited( Sender : TObject);
    procedure pfBeginEdit( DataCol : integer);
    procedure pfEndEdit( DataCol : integer);
    procedure pfEnter( Sender : TObject);
    procedure pfExit( Sender : TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tgDissectKeyPress(Sender: TObject; var Key: Char);
    procedure rzAmountKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    function  CalcAmountFromPercentStr( sPercent : string) : string;
    function  CalcAmountToCompleteStr : string;
    procedure tgDissectKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    //procedure RzSizePanel1Enter(Sender: TObject);
    //procedure RzSizePanel1Exit(Sender: TObject);
    procedure tgDissectExit(Sender: TObject);
    procedure tgDissectEnter(Sender: TObject);
    procedure rbtnPrevClick(Sender: TObject);
    procedure tgAccountLookupEnter(Sender: TObject);
    procedure tgAccountLookupExit(Sender: TObject);
    procedure tgDissectInvalidMaskValue(Sender: TObject; DataCol,
      DataRow: Integer; var Accept: Boolean);
    procedure rzGSTAmountKeyPress(Sender: TObject; var Key: Char);
    procedure tgDissectColMoved(Sender: TObject; ToDisplayCol,
      Count: Integer; ByUser: Boolean);
    procedure chkShowPanelClick(Sender: TObject);
    procedure tgPayeeLookupCellLoaded(Sender: TObject; DataCol,
      DataRow: Integer; var Value: Variant);
    procedure tgPayeeLookupEndCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure tgPayeeLookupEnter(Sender: TObject);
    procedure tgPayeeLookupExit(Sender: TObject);
    procedure tgPayeeLookupKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDeactivate(Sender: TObject);
    procedure rzQuantityKeyPress(Sender: TObject; var Key: Char);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
    procedure tgDissectMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure tgDissectKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tgDissectMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tmrHideHintTimer(Sender: TObject);
    procedure tgAccountLookupKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure Copycontentsofthecellabove1Click(Sender: TObject);
    procedure btnSuperClick(Sender: TObject);
    procedure tgDissectButtonClick(Sender: TObject; DataCol, DataRow: Integer);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure EditSuperFields1Click(Sender: TObject);
    procedure tgJobLookupCellLoaded(Sender: TObject; DataCol, DataRow: Integer;
      var Value: Variant);
    procedure tgJobLookupEndCellEdit(Sender: TObject; DataCol, DataRow: Integer;
      var Cancel: Boolean);
    procedure tgJobLookupEnter(Sender: TObject);
    procedure tgJobLookupExit(Sender: TObject);
    procedure tgJobLookupKeyPress(Sender: TObject; var Key: Char);
    procedure chkTaxInvKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FHint : THintWindow;
    FHintShowing : boolean;
    LastHintRow           : integer;
    LastHintCol           : integer;
    KeyIsDown             : boolean;
    KeyIsCopy             : boolean;    

    FocusedControl : TWinControl;
    DataArray : Array[ 1..Max_tx_Lines] of TWork_Dissect_Rec;
    AccountComboDown          : Boolean;
    PayeeComboDown            : Boolean;
    JobComboDown              : Boolean;
    PanelFieldEdited          : boolean;
    CurrentPanelField         : integer;
    ReloadingPanel            : boolean;
    AnyKeysPressed            : boolean;

    MyClientFile              : TEcClient;
    ParentTransaction         : pTransaction_Rec;
    RowColor                  : TColor;
    RowSelectedColor          : TColor;
    RemovingMask, AllowMinus : Boolean;

    procedure CMFocusChanged(var Msg: TCMFocusChanged); message CM_FocusChanged;

    procedure BuildGrid;
    procedure BuildPanel;
    procedure ReloadPanel( DataRow : integer);
    procedure SetDesktopTheme;
    function  NextEditableCellRight: integer;
    procedure PayeeLookupCellLoaded(Sender: TObject; DataCol, DataRow: Integer; var Value: Variant);
    procedure PayeeLookupKeyPress(Sender: TObject; var Key: Char);
    procedure RemoveBlanks;
    procedure AccountEdited( NewValue : string; DataRow : integer);
    procedure GSTAmountEdited( NewValue : double; DataRow : integer; ValueEmpty : Boolean);
    procedure AmountEdited( NewValue : double; DataRow : integer);
    procedure PayeeEdited( NewValue : string; DataRow : integer);
    procedure UpdateDisplayTotals(Denominator: integer = 1);

    function  GSTDifferentToDefault( DataRow : integer) : boolean;
    procedure CalcControlTotals(var Count: Integer; var Total,
      Remainder: Double);
    procedure pfEndPanelEdit(Undo: boolean);
    procedure InsertRowsAfter(Row, NewRows: integer);
    procedure RepositionOnRow(NewDataRow: integer);
    function CalcGSTAmountFromPercentStr(sPercent: string): string;
    procedure DoClearRow(DataRow: integer);
    procedure DoGotoNextUncoded;
    function  FindUnCoded(const TheCurrentRow: integer): integer;
    procedure HideCustomHint;
    procedure ShowHintForCell(const RowNum, ColNum: integer);
    function NumberIsValid( aControl : TCustomEdit; const LeftDigits, RightDigits: integer): boolean;
    function GetDissectionHint(const Disection: PWork_Dissect_Rec): string;
    procedure JobLookupCellLoaded(Sender: TObject; DataCol, DataRow: Integer;
      var Value: Variant);
    procedure JobLookupKeyPress(Sender: TObject; var Key: Char);
    procedure JobEdited(NewValue: string; DataRow: Integer);
    Function MoneyStr( Const Amount : Money): String;
  public
    { Public declarations }
  end;

  function DissectEntry( aClient : TECClient; pT : pTransaction_Rec) : boolean;

//******************************************************************************
implementation

uses
   GenUtils,
   GSTUtils,
   WinUtils,
   ecdsio,
   StStrS,
   MainFrm,
   editSuperFrm,
   ecTransactionListObj,
   ecColors,
   ecMessageBoxUtils, ECpyIO, FormUtils,
   ECollect, mxUtils, NotesHelp, ecJobObj,
   Dialogs;

{$R *.DFM}
const
   ccMin = 1;

   ccIcon              = 1;
   ccNarration         = 2;
   ccAccount           = 3;
   ccAmount            = 4;
   ccGSTAmount         = 5;
   ccTaxInvoice        = 6;
   ccQuantity          = 7;
   ccPayee             = 8;
   ccJob               = 9;
   ccNotes             = 10;

   ccMax = 10;

   ccNames : Array[ ccMin..ccMax] of string =
      ( '',
        'Narration',
        'Account',
        'Amount',
        'GST',
        'Tax Invoice',
        'Quantity',
        'Payee',
        'Job',
        'Notes'
        );

   ccDefaultWidth : Array[ ccMin..ccMax] of integer =
         (26,
          150,          //ccNarration
          80,           //ccAccount
          140,          //ccAmount
          70,           //ccGSTAmount
          80,           //ccTaxInvoice
          70,           //ccQuantity
          90,           //ccPayee
          90,           //ccJob
          130           //ccNotes
          );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetFocusSafe( Control : TWinControl);
begin
   try
      Control.SetFocus;
   except
      On E : EInvalidOperation do ;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DissectEntry( aClient : TECClient; pT : pTransaction_Rec) : boolean;
var
   i : integer;
   pDissection : pDissection_Rec;
   APayee      : TECPayee;
   HasBlank    : boolean;

   Rec1        : TWork_Dissect_Rec;
   Rec2        : TWork_Dissect_Rec;
   Count       : integer;
   Total, Remain : double;
   FrmDissection: TfrmDissection;
begin
   result := false;
   FrmDissection := TfrmDissection.Create(Application.MainForm);

   with FrmDissection do
   begin
     try
       ParentTransaction      := pT;
       MyClientFile           := aClient;
       SetDeskTopTheme;
       EditSuperFields1.Visible := (MyClientFile.ecFields.ecSuper_Fund_System > 0);
       N1.Visible := (MyClientFile.ecFields.ecSuper_Fund_System > 0);
       chkShowPanel.Checked := frmMain.chkShowPanel.Checked;
       pnlPanel.Visible := chkShowPanel.Checked;
       imgCoded.Visible := ParentTransaction^.txCode_Locked;
       if aClient.ecFields.ecSuper_Fund_System > 0 then begin
          BtnSuper.Visible := true;
          PnlTop.Height := 33;
       end else begin
          BtnSuper.Visible := False;
          PnlTop.Height := 24;
       end;
       //build grid
       BuildGrid;
       //build panel
       BuildPanel;
       //load parent transaction details
       with ParentTransaction^ do
       begin
         lblDate.Caption   := bkDate2Str( txDate_Effective );
         lblRef.Caption    := GetFormattedReference( ParentTransaction);
         lblAmount.Caption := MoneyStr(txAmount); // division by 100 is handled by the MoneyStr function
         if txPayee_Number <> 0 then begin
           APayee := MyClientFile.ecPayees.Find_Payee_Number( txPayee_Number);
           if Assigned(APayee) then
             lblPayeeName.Caption := APayee.pdName
           else
             lblPayeeName.Caption := ''
         end
         else
            lblPayeeName.Caption := '';

         lblNarrationField.caption := txNarration;
         lblNarrationField.Hint := lblNarrationField.caption;
         lblRef.Hint            := lblRef.caption;
       end;
       //load dissection details
       FillChar( DataArray, SizeOf( DataArray) ,0);
       i := 1;
       pDissection := ParentTransaction^.txFirst_Dissection;
       while pDissection <> nil do
       begin
         with pDissection^ do
         begin
           DataArray[ i].dtAccount         := dsAccount;
           DataArray[ i].dtAmount          := dsAmount;
           DataArray[ i].dtGST_Class       := dsGST_Class;
           DataArray[ i].dtGST_Amount      := dsGST_Amount;
           DataArray[ i].dtPayee_Number    := dsPayee_Number;
           DataArray[ i].dtJob_Code        := dsJob_Code;
           DataArray[ i].dtQuantity        := dsQuantity;
           DataArray[ i].dtNarration       := dsNarration;
           DataArray[ i].dtHas_Been_Edited := dsHas_Been_Edited;
           DataArray[ i].dtGST_Has_Been_Edited := dsGST_Has_Been_Edited;
           DataArray[ i].dtNotes           := dsNotes;
           DataArray[ i].dtSF_Edited       := dsSF_Edited;
           DataArray[ i].dtSF_Franked          := dsSF_Franked;
           DataArray[ i].dtSF_UnFranked        := dsSF_UnFranked;
           DataArray[ i].dtSF_Franking_Credit  := dsSF_Franking_Credit;
           DataArray[ i].dtTransaction     := ParentTransaction;
           DataArray[i].dtTaxInvoice := dsTax_Invoice;

         end;
         pDissection := pDissection^.dsNext;
         Inc( i );
       end;

       if ParentTransaction^.txCode_Locked then
         //only allow editing of current rows
         tgDissect.Rows := ( i - 1)
       else
         tgDissect.rows := glConst.Max_tx_Lines;

       tgDissect.RowColor[ 1] := RowSelectedColor;
       tgDissect.CurrentDataRow := 1;
//       tgDissectCellChanged( tgDissect, 1,1,1,1);
       ReloadPanel( 1);

       UpdateDisplayTotals;

       if ( ShowModal = mrOK) then
       begin
         //Check if there is blank record within records.  This is to prevent
         //the changing of order of entries, but this only works when there is
         //no blank entry within entries.
         HasBlank := False;
         for i := 1 to ( GLCONST.Max_tx_Lines - 1 ) do begin
            Rec1 := DataArray[ i];
            Rec2 := DataArray[ i+1];

            if (( Rec1.dtAccount = '') and ( Rec2.dtAccount <> '' )) or
               (( Rec1.dtAmount  = 0 ) and ( Rec2.dtAmount  <> 0   )) or
               (( Rec1.dtNotes  = '' ) and ( Rec2.dtNotes <> ''   )) then begin
               HasBlank := True;
               Break;
            end;
         end;
         if HasBlank then //Remove blank record in between records
           RemoveBlanks;
         CalcControlTotals( Count, Total, Remain );
         ecTransactionListObj.Dump_Dissections( ParentTransaction ); //Clear current dissection lines

         //if there is only 1 line in the dissection then
         //remove dissection and treat like normal transaction
         if (Count = 1) then begin
           with ParentTransaction^, DataArray[ 1] do begin
              txAccount    := dtAccount;
              txGST_Class  := dtGST_Class;
              txGST_Amount := dtGST_Amount;
              txNarration   := dtNarration;
              txHas_Been_Edited := dtHas_Been_Edited;
              txGST_Has_Been_Edited := dtGST_Has_Been_Edited;
              txQuantity        := dtQuantity;
              txPayee_Number    := dtPayee_Number;
              txJob_Code        := dtJob_Code;
           end;
         end
         else begin
            // Store dissection lines
            for i := 1 to Count do begin
              pDissection := New_Dissection_Rec;
               with pDissection^, DataArray[ i] do begin
                 dsTransaction     := ParentTransaction;
                 dsAccount         := dtAccount;
                 dsAmount          := dtAmount;
                 dsGST_Class       := dtGST_Class;
                 dsGST_Amount      := dtGST_Amount;
                 dsQuantity        := dtQuantity;
                 dsPayee_Number    := dtPayee_Number;
                 dsJob_Code        := dtJob_Code;
                 dsNarration       := dtNarration;
                 dsHas_Been_Edited := dtHas_Been_Edited;
                 dsGST_Has_Been_Edited := dtGST_Has_Been_Edited;
                 dsNotes           := dtNotes;
                 dsSF_Edited           := dtSF_Edited;
                 dsSF_Franked          := dtSF_Franked;
                 dsSF_Unfranked        := dtSF_Unfranked;
                 dsSF_Franking_Credit  := dtSF_Franking_Credit;
                 dsTax_Invoice := dtTaxInvoice;
                 ecTransactionListObj.AppendDissection( ParentTransaction, pDissection );
              end;
            end;
            ParentTransaction^.txCoded_By    := cbManual;
            ParentTransaction^.txAccount     := 'DISSECTED';
            //clean up any gst amounts that are left on the transaction
            ParentTransaction^.txGST_Class   := 0;
            ParentTransaction^.txGST_Amount  := 0;
            ParentTransaction^.txQuantity    := 0;
            ParentTransaction^.txGST_Has_Been_Edited := false;
         end;
         result := true;
       end;
     finally
       Free;
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TfrmDissection }

procedure TfrmDissection.SetDesktopTheme;
begin
  ApplyStandards(Self);

  RzFrameController1.FrameColor := clBorderColor;
  pnlTop.Color := clBorderColor;
  pnlLeft.Color := clBorderColor;
  pnlBottom.Color := clBorderColor;
  pnlRight.Color := clBorderColor;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.BuildGrid;
var
  i : integer;
begin
  tgDissect.Cols  := ccMax;
  ccNames[5]:=MyClientFile.SalesTaxNameFromCountry(MyClientFile.ecFields.ecCountry);

  for i := ccMin to ccMax do begin
     tgDissect.Col[ i].Heading        := ccNames[ i];
     tgDissect.Col[ i].ControlType    := tsGrid.ctText;
     tgDissect.Col[ i].ReadOnly       := false;  //default
     tgDissect.Col[ i].Width          := ccDefaultWidth[ i];
  end;

  if MyClientFile.ecFields.ecSuper_Fund_System = 0 then
     tgDissect.Col[ccIcon].Width := 0;


  //set max length
  tgDissect.Col[ ccAccount].MaxLength     := MaxBK5CodeLen;
  tgDissect.Col[ ccNarration].MaxLength     := MaxNarrationEditLength;

  tgDissect.Col[ ccIcon].ReadOnly := True;
  tgDissect.Col[ ccIcon].ControlType := ctPicture;

  //set read status
  tgDissect.Col[ ccNarration].ReadOnly := True;
  tgDissect.Col[ ccNarration].ParentFont := False;
  tgDissect.Col[ ccNarration].Font.Color := clNavy; //clGray;

  //set Tax Invoice Column
  tgDissect.Col[ccTaxInvoice].ControlType    := ctCheck;
  tgDissect.Col[ccTaxInvoice].CheckBoxValues := 'Y|N';


  //set data masks
  tgDissect.Col[ ccAmount ].MaskName      := 'MoneyMask';
  tgDissect.Col[ ccGSTAmount ].MaskName   := 'MoneyMask';
  tgDissect.Col[ ccQuantity ].MaskName    := 'QtyMask';

  //set word wrap
  tgDissect.Col[ ccNarration ].WordWrap   := wwOn;
  tgDissect.Col[ ccPayee ].WordWrap       := wwOn;

  //set alignment
  tgDissect.Col[ ccAmount].Alignment      := taRightJustify;
  tgDissect.Col[ ccGSTAmount].Alignment   := taRightJustify;
  tgDissect.Col[ ccQuantity].Alignment    := taRightJustify;

  tgDissect.Col[ ccPayee].DropDownStyle   := ddDropDownList;
  tgDissect.Col[ ccJob].DropDownStyle     := ddDropDownList;

  //client specific fields
  //account col editable if chart exists by default
  tgDissect.Col[ ccAccount].ReadOnly := ( MyClientFile.ecChart.CountBasicItems = 0) or
                                        ( ParentTransaction^.txCode_Locked);
  tgDissect.Col[ ccAmount].ReadOnly  := ( ParentTransaction^.txCode_Locked);
  if ( tgDissect.Col[ ccAccount].ReadOnly) then begin
    tgDissect.Col[ ccAccount].ParentFont := false;
    tgDissect.Col[ ccAccount].Font.Color := clNavy; //clGray;
  end;
  if ( tgDissect.Col[ ccAmount].ReadOnly) then begin
    tgDissect.Col[ ccAmount].ParentFont := false;
    tgDissect.Col[ ccAmount].Font.Color := clNavy; //clGray;
  end;
  tgDissect.Col[ ccGSTAmount].ReadOnly  := ( ParentTransaction^.txCode_Locked);

  //payee col visible if payee list exists
  tgDissect.Col[ccGSTAmount].Visible := (not MyClientFile.ecFields.ecHide_GST_Col);
  tgDissect.Col[ccQuantity].Visible := (not MyClientFile.ecFields.ecHide_Quantity_Col);
  tgDissect.Col[ccAccount].Visible := (not MyClientFile.ecFields.ecHide_Account_Col);
  tgDissect.Col[ccPayee].Visible := (not MyClientFile.ecFields.ecHide_Payee_Col);
  tgDissect.Col[ccJob].Visible := (not MyClientFile.ecFields.ecHide_Job_Col);
  tgDissect.Col[ccTaxInvoice].Visible := (not MyClientFile.ecFields.ecHide_Tax_Invoice_Col);

  if (ParentTransaction^.txPayee_Number <> 0) then
    tgDissect.Col[ccPayee].Visible := false
  else
  begin
    if (ParentTransaction^.txCode_Locked) then
    begin
      tgDissect.Col[ ccPayee].ReadOnly   := True;
      tgDissect.Col[ ccPayee].ParentFont := false;
      tgDissect.Col[ ccPayee].Font.color := clNavy; //clGray;
    end else
    begin
      tgDissect.Col[ ccPayee].ReadOnly   := false;
      tgDissect.Col[ ccPayee].ParentFont := true;
    end;
  end;

  if (ParentTransaction^.txJob_Code <> '') then
    tgDissect.Col[ccJob].Visible := false
  else
  begin
    if (ParentTransaction^.txCode_Locked) then
    begin
      tgDissect.Col[ ccJob].ReadOnly   := True;
      tgDissect.Col[ ccJob].ParentFont := false;
      tgDissect.Col[ ccJob].Font.color := clNavy; //clGray;
    end else
    begin
      tgDissect.Col[ ccJob].ReadOnly   := false;
      tgDissect.Col[ ccJob].ParentFont := true;
    end;
  end;

  tgDissect.CurrentDataCol := ccAccount;

  if not tgDissect.Col[ccAccount].Visible then
    tgDissect.CurrentDataCol := NextEditableCellRight;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.BuildPanel;
var
  STax: string;
begin
  //setup tags
  rzAmount.Tag    := ccAmount;
  rzGSTAmount.Tag := ccGSTAmount;
  rzQuantity.Tag  := ccQuantity;
  rzNarration.Tag := ccNarration;
  rzNotes.Tag     := ccNotes;
  chkTaxInv.Tag   := ccTaxInvoice;

  //set max length
  tgAccountLookup.Col[ 1].MaxLength := MaxBK5CodeLen;
  tgPayeeLookup.Col[ 1].MaxLength   := MaxBK5CodeLen;

  //account col editable if chart exists by default
  tgAccountLookup.Col[ 1].ReadOnly := ( MyClientFile.ecChart.CountBasicItems = 0);
  //payee col editable if chart exists by default
  tgPayeeLookup.Col[ 1].ReadOnly := ( MyClientFile.ecPayees.ItemCount = 0);

  with MyClientFile.ecFields do
  begin
    tgAccountLookup.Visible := (not ecHide_Account_Col);
    lblAccount.Visible      := tgAccountLookup.Visible;
    rzFakeAccountBorder.Visible := tgAccountLookup.Visible;
    lblAccountName.Visible  := tgAccountLookup.Visible;

    tgPayeeLookup.Visible := (not ecHide_Payee_Col) and tgDissect.Col[ccPayee].Visible;
    lblPayee.Visible      := tgPayeeLookup.Visible;
    rzFakePayeeBorder.Visible := tgPayeeLookup.Visible;

    tgJobLookup.Visible   := (not ecHide_Job_Col) and tgDissect.Col[ccJob].Visible;
    lblJob.Visible        := tgJobLookup.Visible;
    rzFakeJobBorder.Visible := tgJobLookup.Visible;
    lblJobName.Visible    := tgJobLookup.Visible;

    lblGST.Visible := (not ecHide_GST_Col);
    rzGSTAmount.Visible := (not ecHide_GST_Col);
    lblQuantity.Visible := (not ecHide_Quantity_Col);
    rzQuantity.Visible  := (not ecHide_Quantity_Col);
    chkTaxInv.Visible := (not ecHide_Tax_Invoice_Col);

    STax:=MyClientFile.SalesTaxNameFromCountry(ecCountry);
    lblGST.Caption := STax;
  end;

  SetEditState(rzQuantity, True);
  SetEditState(rzNarration, False);
  if (MyClientFile.ecPayees.ItemCount = 0) or
    (ParentTransaction^.txPayee_Number <> 0) or
    (ParentTransaction^.txCode_Locked) then
    tgPayeeLookup.Enabled := False
  else
    tgPayeeLookup.Enabled := True;


  tgJobLookup.Enabled := (ParentTransaction.txJob_Code = '') and not ParentTransaction^.txCode_Locked;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgDissectCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
var
  APayee : TECPayee;
begin
   Value := '';
   case DataCol of
      ccIcon : begin
          if DataArray[DataRow].dtSF_Edited then
             Value := BitmapToVariant(frmMain.imgSuper.Picture.Bitmap)

      end;
      ccAccount: begin
         Value    := DataArray[ DataRow].dtAccount;
         if ( Value = '' )
         or  ( MyClientFile.ecChart.CanCodeTo( Value )) then begin
            tgDissect.CellParentFont[ DataCol, DataRow] := true;
            tgDissect.CellColor[ DataCol, DataRow]      := clNone;
         end
         else begin
            tgDissect.CellParentFont[ DataCol, DataRow] := false;
            tgDissect.CellFont[ DataCol, DataRow].color := clWhite;
            tgDissect.CellColor[ DataCol, DataRow]      := clRed;
         end;
      end;

      ccAmount: begin
         Value := MakeAmountStr( DataArray[ DataRow].dtAmount);
         {if DataArray[ DataRow].dtSF_Edited then begin
            tgDissect.CellParentFont[ DataCol, DataRow] := False;
            tgDissect.CellFont[ DataCol, DataRow].color := clWhite;
            tgDissect.CellColor[ DataCol, DataRow]      := clSuperFields;
         end else }begin
            tgDissect.CellParentFont[ DataCol, DataRow] := true;
            tgDissect.CellColor[ DataCol, DataRow]      := clNone;
         end;

      end;

      ccGSTAmount: begin
        if (DataArray[ DataRow].dtGST_Amount = 0.00) and (not DataArray[ DataRow].dtGST_Has_Been_Edited) then
          Value := ''
        else
          Value  := MakeAmountStr( DataArray[ DataRow].dtGST_Amount);
      end;

      ccPayee        : begin
         APayee := MyClientFile.ecPayees.Find_Payee_Number(  DataArray[ DataRow].dtPayee_Number);
         if Assigned(APayee) then Value := APayee.pdName;
      end;

      ccJob: Value := DataArray[DataRow].dtJob_Code;

      ccQuantity: Value   := MakeQuantityStr( DataArray[ DataRow].dtQuantity);

      ccNarration: Value  := DataArray[ DataRow].dtNarration;

      ccNotes: Value      := DataArray[ DataRow].dtNotes;

      ccTaxInvoice:
      begin
        if DataArray[DataRow].dtTaxInvoice then Value := 'Y' else Value := 'N';
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.ReloadPanel(DataRow: integer);
var
  pAccount : pAccount_Rec;
  pJob: TECJob;
  //pPayee : pPayee_Rec;
begin
  ReloadingPanel := true;
  try
    tgAccountLookup.Invalidate;
    tgPayeeLookup.Invalidate;
    tgJobLookup.Invalidate;
    rzAmount.Text        := MakeAmountStr( DataArray[ DataRow].dtAmount);
    if (DataArray[ DataRow].dtGST_Amount = 0) and (not DataArray[ DataRow].dtGST_Has_Been_Edited) then
      rzGSTAmount.Text   := ''
    else
      rzGSTAmount.Text   := MakeAmountStr( DataArray[ DataRow].dtGST_Amount);
    rzNarration.Text     := DataArray[ DataRow].dtNarration;
    rzQuantity.Text      := MakeQuantityStr( DataArray[ DataRow].dtQuantity);
    rzNotes.Text         := DataArray[ DataRow].dtNotes;
    chkTaxInv.Checked    := DataArray[ DataRow].dtTaxInvoice;

    //set description label
    pAccount := MyClientFile.ecChart.FindCode( DataArray[ DataRow].dtAccount);
    if Assigned( pAccount) then
      lblAccountName.caption := pAccount.chAccount_Description
    else
      lblAccountName.caption := '';

    //set appearance
    //account code
    if (MyClientFile.ecChart.CountBasicItems = 0) or
      (ParentTransaction^.txCode_Locked) then
    begin
    //if ( ParentTransaction.txCode_Locked) then begin
      tgAccountLookup.CellReadOnly[ 1, 1] := tsGrid.roOn;
      tgAccountLookup.CellParentFont[ 1, 1] := false;
      tgAccountLookup.CellFont[ 1, 1].color := clNavy; //clGray;
      tgAccountLookup.CellColor[ 1, 1]      := clNone;
    end else
    if ( DataArray[ DataRow].dtAccount='' ) or
       ( MyClientFile.ecChart.CanCodeTo( DataArray[ DataRow].dtAccount )) then begin
          tgAccountLookup.CellParentFont[ 1, 1] := true;
          tgAccountLookup.CellColor[ 1, 1]      := clNone;
    end
    else begin
      tgAccountLookup.CellParentFont[ 1, 1] := false;
      tgAccountLookup.CellColor[ 1, 1]      := clRed;
      tgAccountLookup.CellFont[ 1, 1].color := clWhite;
    end;

    //payee
    if (MyClientFile.ecPayees.ItemCount = 0) or
      (ParentTransaction^.txPayee_Number <> 0) or
      (ParentTransaction^.txCode_Locked) then
    begin
      tgPayeeLookup.CellReadOnly[ 1, 1] := tsGrid.roOn;
      tgPayeeLookup.CellParentFont[ 1, 1] := false;
      tgPayeeLookup.CellFont[ 1, 1].color := clNavy; //clGray;
    end
    else
      if ( DataArray[ DataRow].dtPayee_Number = 0 ) or
        Assigned(MyClientFile.ecPayees.Find_Payee_Number( DataArray[ DataRow].dtPayee_Number)) then
      begin
        tgPayeeLookup.CellParentFont[ 1, 1] := true;
        tgPayeeLookup.CellColor[ 1, 1]      := clNone;
      end else
      begin
        tgPayeeLookup.CellParentFont[ 1, 1] := false;
        tgPayeeLookup.CellColor[ 1, 1]      := clRed;
        tgPayeeLookup.CellFont[ 1, 1].color := clWhite;
      end;

    if (MyClientFile.ecJobs.ItemCount = 0) or
      (ParentTransaction^.txJob_Code <> '') or
      (ParentTransaction^.txCode_Locked) then
    begin
      tgJobLookup.CellReadOnly[1, 1] := tsGrid.roOn;
      tgJobLookup.CellParentFont[1,1] := false;
      tgJobLookup.CellFont[1,1].Color := clNavy;
    end
    else
    begin
      if (DataArray[DataRow].dtJob_Code = '') or
        Assigned(MyClientFile.ecJobs.Find_Job_Code(DataArray[DataRow].dtJob_Code)) then
      begin
        tgJobLookup.CellParentFont[1,1] := true;
        tgJobLookup.CellColor[1,1] := clNone;
      end
      else
      begin
        tgJobLookup.CellParentFont[1,1] := false;
        tgJobLookup.CellColor[1,1] := clRed;
        tgJobLookup.CellFont[1,1].Color := clWhite;
      end;
    end;

    //set job name label
    pJob := MyClientFile.ecJobs.Find_Job_Code( DataArray[ DataRow].dtJob_Code);
    if Assigned( pJob) then
      lblJobName.caption := pJob.jhFields.jhHeading
    else
      lblJobName.caption := '';
    
    SetEditState(rzAmount, (not ParentTransaction.txCode_Locked));
    SetEditState(rzGSTAmount, (not ParentTransaction.txCode_Locked));
  finally
     ReloadingPanel := false;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.FormCreate(Sender: TObject);
begin
  inherited;
  Self.WindowState  := wsMaximized;

  FHint := THintWindow.Create( Self );
  FHint.Canvas.Font.Name := 'Courier';
  FHint.Canvas.Font.Size := 5;
  FHintShowing := false;

  RowColor          := ecColors.clAltLine;
  RowSelectedColor  := ecColors.clSelectedRow;

  AccountComboDown := false;
  PayeeComboDown   := false;
  JobComboDown     := false;
  AnyKeysPressed   := false;
  KeyIsDown        := false;
  KeyIsCopy        := false;
  AllowMinus := True;

  BKHelpSetUp(Self, BKH_Dissecting_transactions);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmDissection.CMFocusChanged(var Msg: TCMFocusChanged);
begin
  if not (Msg.Sender is TButton) then
    FocusedControl := Msg.Sender;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgDissectRowLoaded(Sender: TObject;
  DataRow: Integer);
var
   mTH, cTH : Integer;
   i : Integer;
begin
   //set row height for cols with word wrap
   mTH := 0;
   For i := ccMin to ccMax do begin
      If ( tgDissect.Col[ i ].Visible) and ( tgDissect.Col[ i].WordWrap = wwOn) then begin
         cTH := tgDissect.CellTextHeight[ i, DataRow ];
         If cTH > mTH then mTH := cTH;
      end;
   end;
   if ( mth + 1) < ( tgDissect.DefaultRowHeight) then
      mth := tgDissect.defaultrowheight - 1;

   tgDissect.RowHeight[ DataRow ] := mTH + 1;
   //make sure correct row color is set
   if Odd( DataRow) and ( DataRow <> tgDissect.CurrentDataRow) then
      tgDissect.RowColor[ DataRow ] := RowColor;
end;

procedure TfrmDissection.tgJobLookupCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
begin
  if ( tgDissect.Rows < 1) then exit;  //no transactions in account

  Value := DataArray[ tgDissect.CurrentDataRow].dtJob_Code;
    
  if (tgDissect.Col[ ccJob].ReadOnly) then
    tgPayeeLookup.CellButtonType[ 1, 1] := btNone
  else begin
    tgPayeeLookup.CellButtonType[ 1, 1] := btCombo;
    tgPayeeLookup.CellParentCombo[ 1, 1] := False;
  end;
end;

procedure TfrmDissection.tgJobLookupEndCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
var
  sValue : string;
begin
  sValue := '';
  //convert variant to string
  sValue := tgJobLookup.CurrentCell.Value;
  //update the transaction
  JobEdited( sValue, tgDissect.CurrentDataRow);
  tgDissect.RowInvalidate( tgDissect.DisplayRownr[ DataRow]);
  ReloadPanel( tgDissect.CurrentDataRow);
end;

procedure TfrmDissection.tgJobLookupEnter(Sender: TObject);
begin
  inherited;
  tgJobLookup.AlwaysShowFocus := true;
end;

procedure TfrmDissection.tgJobLookupExit(Sender: TObject);
begin
  inherited;
  tgJobLookup.AlwaysShowFocus := true;
end;

procedure TfrmDissection.tgJobLookupKeyPress(Sender: TObject; var Key: Char);
begin
  if JobComboDown then exit;

  if ( Ord( Key ) = vk_Return ) then
  begin
    Key := #0;
    PostMessage( Handle, wm_KeyDown, vk_Tab, 0 );
  end
  else
    inherited KeyPress( Key );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgDissectRowChanged(Sender: TObject; OldRow,
  NewRow: Integer);
begin
  HideCustomHint;
  //it is necessary to test if the row values are in range because changing the row
  //count will force this event to be called
  if (( OldRow >= 1) and ( OldRow <= tgDissect.Rows)) then begin
    //reset normal color
    if Odd( OldRow) then
      tgDissect.RowColor[ OldRow ] := RowColor
    else
      tgDissect.RowColor[ OldRow] := tgDissect.Color;

    tgDissect.RowInvalidate( tgDissect.DisplayRownr[ OldRow]);
  end;

  if (( NewRow >= 1) and ( NewRow <= tgDissect.Rows)) then begin
    //set row selected color
    tgDissect.RowColor[ NewRow] :=  RowSelectedColor;
    //reload current transaction
    ReloadPanel( NewRow);

    tgDissect.RowInvalidate( tgDissect.DisplayRownr[ NewRow]);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgDissectButtonClick(Sender: TObject; DataCol,
  DataRow: Integer);
begin
  inherited;
  if dataCol = ccAmount then
  if MyClientFile.ecFields.ecSuper_Fund_System > 0 then
     btnSuperClick(nil);   
end;

procedure TfrmDissection.tgDissectCellChanged(Sender: TObject; OldCol,
  NewCol, OldRow, NewRow: Integer);
begin
   if (( OldRow >= 1) and ( OldRow <= tgDissect.Rows)) and
      (( NewRow >= 1) and ( NewRow <= tgDissect.Rows)) then begin
      if OldCol in [ ccAccount, ccPayee, ccJob] then begin
         tgDissect.CellButtonType[ OldCol, OldRow] := btDefault;
         tgDissect.CellReadOnly[ NewCol, NewRow]   := roDefault;
      end;

      if NewCol in [ ccAccount] then
      begin
        if ParentTransaction^.txCode_Locked then
        begin
          tgDissect.CellButtonType[ NewCol, NewRow] := tsGrid.btDefault;
        end
        else
        begin
          tgDissect.CellButtonType[ NewCol, NewRow] := btCombo;
          tgDissect.CellParentCombo[ NewCol, NewRow] := False;
        end;  
      end;

      (*tgDissect.CellButtonType[ccAmount, OldRow] := btDefault;
      if NewCol in [ccAmount] then begin
          if True {(MyClientFile.ecFields.ecSuper_Fund_System > 0)} then
             tgDissect.CellButtonType[ NewCol, NewRow] := btNormal
          else
             tgDissect.CellButtonType[ NewCol, NewRow] := btDefault;
      end;*)

      if NewCol in [ccPayee, ccJob] then
      begin
        if ParentTransaction^.txCode_Locked then
        begin
          tgDissect.CellButtonType[ NewCol, NewRow] := tsGrid.btDefault;
        end
        else
        begin
          tgDissect.CellButtonType[ NewCol, NewRow] := btCombo;
          tgDissect.CellParentCombo[ NewCol, NewRow] := False;
        end;
      end;
   end;

   if NewCol < ccAccount then
     tgDissect.CurrentDataCol := NextEditableCellRight;

   ShowHintForCell(NewRow, NewCol);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmDissection.NextEditableCellRight: integer;
var
  dspCol : integer; //display col
  newDataCol : integer;
begin
  result := tgDissect.currentDataCol;     

  dspCol := tgDissect.DisplayColnr[ tgDissect.CurrentDataCol];
  while dspCol <= tgDissect.Cols do
  begin
    Inc( dspCol);
    NewDataCol := tgDissect.DataColnr[ dspCol];
    
    if ( tgDissect.Col[ NewDataCol].Visible) and ( NewDataCol >= ccAccount) then begin
      result := NewDataCol;
      exit;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgDissectCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; ByUser: Boolean);
//occurs with every keystroke
var
  sValue : string;
  MaskChar : Char;
  APayee : TECPayee;
  AJob: TECJob;
begin
   if DataCol in [ ccAccount] then
      sValue := tgDissect.CurrentCell.Value;

   case DataCol of
      ccAmount:
      begin
        if not AllowMinus then exit;
        AllowMinus := False;
        if DataRow > 1 then
          sValue := tgDissect.Cell[DataCol, DataRow - 1]
        else if ParentTransaction.txAmount < 0 then
          sValue := '-1.0'
        else
          sValue := '1.0';
        if (StrToFloatDef(sValue, 0) < 0) and (StrToFloatDef(tgDissect.CurrentCell.Value, -1) >= 0) then
          tgDissect.CurrentCell.Value := '-' + tgDissect.CurrentCell.Value;
      end;
      ccAccount : begin
         if AccountComboDown then exit;

         if (tgDissect.CellEditing) then
         begin
           sValue := tgDissect.CurrentCell.Value;
           if (not RemovingMask) and MyClientFile.ecChart.AddMaskCharToCode(sValue,
              MyClientFile.ecFields.ecAccount_Code_Mask, MaskChar) Then
           begin
             sValue := sValue + MaskChar;
             tgDissect.CurrentCell.Value := sValue;
             //move cursor to the last character
             tgDissect.CurrentCell.SelStart := Length(sValue);
           end;
         end;

         //check to see if is a valid code
         if MyClientFile.ecChart.CanPressEnterNow( sValue) then begin
            //move to next editable display col
            tgDissect.EndEdit( false);
            tgDissect.CurrentDataCol := NextEditableCellRight;
         end;
      end;
      ccPayee : begin
         if PayeeComboDown then exit;
         //check to see if is a valid code
         APayee := MyClientFile.ecPayees.Find_Payee_Name( sValue);
         if assigned(APayee) then
         begin
            //move to next editable display col
            tgDissect.EndEdit( false);
            tgDissect.CurrentDataCol := NextEditableCellRight;
         end;
      end;
      ccJob: begin
        if JobComboDown then
          Exit;
        AJob := MyClientFile.ecJobs.Find_Job_Code(sValue);
        if Assigned(AJob) then
        begin
          tgDissect.EndEdit(false);
          tgDissect.CurrentDataCol := NextEditableCellRight;
        end;
      end;
   end; //case
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgDissectComboDropDown(Sender: TObject;
  Combo: TtsComboGrid; DataCol, DataRow: Integer);
begin
  case DataCol of
    ccAccount : AccountComboDown := true;
    ccPayee : PayeeComboDown := true;
    ccJob   : JobComboDown := true;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgDissectComboRollUp(Sender: TObject;
  Combo: TtsComboGrid; DataCol, DataRow: Integer);
begin
  case DataCol of
    ccAccount :
      begin
        AccountComboDown := false;
        //now auto move if correct
        tgDissectCellEdit( Sender, DataCol, DataRow, false);
      end;
    ccPayee :
      begin
        PayeeComboDown := false;
        //now auto move if correct
        tgDissectCellEdit( Sender, DataCol, DataRow, false);
      end;
    ccJob:
      begin
        JobComboDown := false;
        tgDissectCellEdit(Sender, DataCol, DataRow, false);
      end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgDissectComboInit(Sender: TObject;
  Combo: TtsComboGrid; DataCol, DataRow: Integer);
begin
   if not Assigned( MyClientFile) then exit;

   //detect if a combobox from the panel is selected
   if (TtsComboGrid(Sender).Name = tgAccountLookup.Name) then
     DataCol := ccAccount
   else if (TtsComboGrid(Sender).Name = tgPayeeLookup.Name) then
     DataCol := ccPayee
   else if (TTsComboGrid(Sender).Name = tgJobLookup.Name) then
    DataCol := ccJob;


   case DataCol of
      ccAccount : begin
          HideCustomHint;
          Combo.DropDownRows  := 10;
          Combo.DropDownCols  := 2;
          Combo.Grid.Rows     := MyClientFile.ecChart.CountBasicItems;
          Combo.Grid.Cols     := 2;
          Combo.Grid.Width    := 275;
          Combo.Grid.Font.Size        := 8;
          Combo.Grid.Col[ 1].Width    := 75;
          Combo.Grid.Col[ 2].Width    := 200;
          Combo.Grid.ValueCol         := 1;
          Combo.Grid.ValueColSorted   := True;
          Combo.Grid.AutoSearch       := asCenter;
          Combo.Grid.DefaultRowHeight := 22;
          Combo.Grid.AutoFill         := False;
          Combo.Grid.GridLines        := tsgrid.glHorzLines;

          Combo.Grid.OnCellLoaded     := ChartLookupCellLoaded;
          Combo.Grid.OnKeyPress       := nil;
      end;

      ccPayee : begin
          HideCustomHint;
          Combo.DropDownRows  := 10;
          Combo.DropDownCols  := 2;
          Combo.Grid.Rows     := MyClientFile.ecPayees.ItemCount;
          Combo.Grid.Cols     := 2;
          Combo.Grid.Width    := 250;
          Combo.Grid.Font.Size        := 8;
          Combo.Grid.Col[ 1].Width    := 50;
          Combo.Grid.Col[ 2].Width    := 200;
          Combo.Grid.ValueCol         := 2;
          Combo.Grid.ValueColSorted   := True;
          Combo.AutoLookup            := True;
          Combo.Grid.AutoSearch       := asCenter;
          Combo.Grid.AutoFill         := True;
          Combo.Grid.DefaultRowHeight := 22;
          Combo.Grid.GridLines        := tsgrid.glHorzLines;

          Combo.Grid.OnCellLoaded     := PayeeLookupCellLoaded;
          Combo.Grid.OnKeyPress       := PayeeLookupKeyPress;
      end;
      ccJob : begin
          HideCustomHint;
          Combo.DropDownRows  := 10;
          Combo.DropDownCols  := 2;
          Combo.Grid.Rows     := MyClientFile.ecJobs.NonCompletedJobCount;
          Combo.Grid.Cols     := 2;
          Combo.Grid.Width    := 300;
          Combo.Grid.Font.Size        := 8;
          Combo.Grid.Col[ 1].Width    := 100;
          Combo.Grid.Col[ 2].Width    := 200;
          Combo.Grid.ValueCol         := 1;
          Combo.Grid.ValueColSorted   := True;
          Combo.AutoLookup            := True;
          Combo.Grid.AutoSearch       := asCenter;
          Combo.Grid.AutoFill         := True;
          Combo.Grid.DefaultRowHeight := 22;
          Combo.Grid.GridLines        := tsgrid.glHorzLines;

          Combo.Grid.OnCellLoaded     := JobLookupCellLoaded;
          Combo.Grid.OnKeyPress       := JobLookupKeyPress;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.JobLookupCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
var
  AJob : TECJob;
begin
   if not Assigned( MyClientFile) then exit;

   AJob := MyClientFile.ecJobs.NonCompletedJobAt( Pred( DataRow));
   if Assigned(AJob) then begin
      case DataCol of
         1 : Value := AJob.jhFields.jhCode;
         2 : value := AJob.jhFields.jhHeading;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.PayeeLookupCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
var
  APayee : TECPayee;
begin
   if not Assigned( MyClientFile) then exit;

   APayee := MyClientFile.ecPayees.Payee_At( Pred( DataRow));
   if Assigned(APayee) then begin
      case DataCol of
         1 : Value := IntToStr(APayee.pdNumber);
         2 : value := APayee.pdName;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.ChartLookupCellLoaded(Sender: TObject; DataCol, DataRow: Integer; var Value: Variant);
var
  Account : pAccount_Rec;
  Combo   : TTsComboGrid;
   i       : Integer;
begin
  if not Assigned( MyClientFile) then exit;
  i := StrToInt(frmMain.BasicChart[DataRow-1]);
  Account := MyClientFile.ecChart.Account_At(i);
  if Assigned( Account) then
  begin
    // find next basic acct
    while Assigned(Account) and Account.chHide_In_Basic_Chart and (i < MyClientFile.ecChart.ItemCount) do
    begin
      Inc(i);
      Account := MyClientFile.ecChart.Account_At(i);
    end;
    if (i = MyClientFile.ecChart.ItemCount) then
      exit;
    case DataCol of
       1: value := Account.chAccount_Code;
       2: value := Account.chAccount_Description;
    end;
    //gray out if no posting allowed
    Combo := TTsComboGrid( Sender);
    if Account.chPosting_Allowed then
      Combo.RowParentFont[ DataRow] := true
    else
    begin
      Combo.RowParentFont[ DataRow] := false;
      Combo.RowFont[ DataRow].Color := clNavy; //clGray;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.PayeeLookupKeyPress(Sender: TObject;
  var Key: Char);
begin
  if (Key in ['0'..'9']) then
    Key := '0'
  else
    Key := 'A';
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.JobLookupKeyPress(Sender: TObject;
  var Key: Char);
begin
  if (Key in ['0'..'9']) then
    Key := '0'
  else
    Key := 'A';
end;

function TfrmDissection.MoneyStr(const Amount: Money): String;
begin
  if Amount = Unknown then
    Result := 'Unknown'
  else
    Result := FormatFloat( MyClientFile.ActiveBankAccount.FmtMoneyStr, Amount/100.0 );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgDissectEndCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
{
   The OnEndCellEdit event occurs at the end of a cell edit operation either
   when the user leaves the current cell, when the grid loses the focus or when
   the EndEdit method is called.

}
var
   sValue : string;
   dValue : double;
begin
   sValue := '';
   dValue := 0;
   AllowMinus := True;
   //convert variant to string
   if DataCol in [ ccAccount,
                   ccNarration,
                   ccPayee,
                   ccJob,
                   ccNotes,
                   ccTaxInvoice ] then
      sValue := tgDissect.CurrentCell.Value;
   //convert variant to double
   if DataCol in [ ccAmount,
                   ccGSTAmount,
                   ccQuantity ] then begin
      sValue := tgDissect.CurrentCell.Value;
      try
         if sValue = '' then sValue := '0.00';
         dValue := StrToFloat( sValue);
      except
         on E : EConvertError do begin
            exit;
         end;
      end;
   end;

   //update the transaction
   case DataCol of
      ccAccount : begin
         AccountEdited( sValue, DataRow);
      end;
      ccAmount : begin
         AmountEdited( dValue, DataRow);
      end;
      ccGSTAmount : begin
       if (tgDissect.CurrentCell.Value = '') then
         GSTAmountEdited( dValue, DataRow, True)
       else
         GSTAmountEdited( dValue, DataRow, False);
      end;
      ccNarration : begin
         DataArray[ DataRow].dtNarration    := sValue;
      end;
      ccQuantity : begin
         DataArray[ DataRow].dtQuantity     :=  dValue * 10000;
      end;
      ccNotes : begin
         DataArray[ DataRow].dtNotes        := sValue;
      end;
      ccPayee : begin
         PayeeEdited( sValue, DataRow);
      end;
      ccJob: begin
        JobEdited(sValue, DataRow);
      end;
      ccTaxInvoice : begin
        DataArray[DataRow].dtTaxInvoice := sValue='Y';
      end;
   end; //case
  ReloadPanel( DataRow);
  tgDissect.RowInvalidate( tgDissect.DisplayRownr[ DataRow]);  //required to update other fields.
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.AccountEdited(NewValue: string; DataRow: integer);
//update other fields that change when account changes
var
  NewClass   : byte;
  NewGST     : money;
begin
  DataArray[ DataRow].dtAccount :=  Trim( NewValue);

  with DataArray[ DataRow] do begin
     if MyClientFile.ecChart.CanCodeTo( dtAccount) then begin
        CalculateGST( MyClientFile, ParentTransaction^.txDate_Effective, dtAccount, dtAmount, NewClass, NewGST);
        dtGST_Class  := NewClass;
        dtGST_Amount := NewGST;
        dtGST_Has_Been_Edited := false;
     end
     else begin
        //note: Gst not cleared by an invalid account to allow independant editing of gst
        //      however it should be cleared if the account code has been deleted
        if ( dtAccount = '' ) then begin
           dtGST_Class := 0;
           dtGST_Amount := 0;
           dtHas_Been_Edited := false;
           dtGST_Has_Been_Edited := false;
        end;
     end;
  end;
  UpdateDisplayTotals;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.CalcControlTotals( var Count : Integer; var Total, Remainder : Double );
//Calculate the total amount in the tblDissection, number of valid dissections, and the remaining
//amount
//NOTE:   Total is returned as if it were a money amount, ie. amount * 100.
//        Remainder is returned as a double ( money / 100)
var
   i       : integer;
begin
   Count := 0;
   Total := 0;
   for i := 1 to GLCONST.Max_tx_Lines do begin
      with DataArray[ i] do begin
         if (dtAccount <> '') or (dtAmount <> 0.0) or (dtNotes <> '') then
            Inc( Count );
         Total := Total + dtAmount;
      end;
   end;
   Remainder   := GenUtils.Money2Double((ParentTransaction^.txAmount - Total) * 100);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.UpdateDisplayTotals(Denominator: integer = 1);
//Calculate the Total, dissection count, remaining then updates the displays
//with new values
var
   Count : Integer;
   Total, Remain : Double;
begin
   CalcControlTotals( Count, Total, Remain );
   lblTotal.Caption  := MoneyStr(Total);
   lblRemain.Caption := MoneyStr(Remain);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.AmountEdited(NewValue: double; DataRow: integer);
begin
   DataArray[ DataRow].dtAmount := Double2Money( NewValue);

   with DataArray[ DataRow] do begin
     if MyClientFile.ecChart.CanCodeTo( dtAccount) then begin
        //recalculate the gst using the current class.  No need to change the GST has been edited flag
        //because its status will stay the same.
        dtGST_Amount := CalculateGSTForClass( MyClientFile, ParentTransaction.txDate_Effective,
                                              dtAmount, dtGST_Class);
     end
     else begin
        //note: Gst not cleared by an invalid account to allow independant editing of gst
        if ( dtAccount = '' ) then begin
           dtHas_Been_Edited := false;
        end;

        if dtAmount = 0 then begin
           dtGST_Amount := 0;
        end;
     end;
  end;
  UpdateDisplayTotals(100);
end;

procedure TfrmDissection.btnSuperClick(Sender: TObject);
var
   SuperDlg: TfrmEditSuper;
   LDiss: PWork_Dissect_Rec;
begin
   LDiss := @DataArray[tgDissect.CurrentDataRow];
   if not assigned(LDiss) then
      Exit;
   LDiss.dtTransaction := ParentTransaction;
   SuperDlg := TfrmEditSuper.Create(Self);
   try
      SuperDlg.ClientFile := MyClientFile;
      SuperDlg.Dissection := LDiss;
      SuperDlg.ShowModal;
      tgDissect.Invalidate;
   finally
      SuperDlg.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.GSTAmountEdited(NewValue: double; DataRow: integer; ValueEmpty : Boolean);
var
   TestGSTAmount : Money;
begin
   //correct amount, should always be the same as sign of trans
   if ( DataArray[ DataRow].dtAmount < 0) and ( NewValue > 0) or
      ( DataArray[ DataRow].dtAmount > 0) and ( NewValue < 0) then
      NewValue := -1 * NewValue;
   //should be zero if trans amount zero
   TestGSTAmount := Double2Money( NewValue);
   if ( ParentTransaction^.txAmount = 0) or ( Abs(ParentTransaction^.txAmount) < Abs(TestGSTAmount)) then
   begin
      NewValue := 0;
      WinUtils.ErrorSound;
   end;

   DataArray[ DataRow].dtGST_Amount := Double2Money( NewValue);

   //check if gst edited
   if (ValueEmpty) then
     DataArray[ DataRow].dtGST_Has_Been_Edited := False
   else
   begin
     if (DataArray[ DataRow].dtGST_Amount = 0.00) then
     begin
        DataArray[ DataRow].dtHas_Been_Edited     := true;
        DataArray[ DataRow].dtGST_Has_Been_Edited := true;
     end else
     begin
       if GSTDifferentToDefault( DataRow ) then begin
         DataArray[ DataRow].dtHas_Been_Edited := true;
         DataArray[ DataRow].dtGST_Has_Been_Edited := true;
       end else
         DataArray[ DataRow].dtGST_Has_Been_Edited := false;
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgAccountLookupKeyPress(Sender: TObject;
  var Key: Char);
begin
  if AccountComboDown then exit;

  if ( Ord( Key ) = vk_Return ) then
  begin
    Key := #0;
    PostMessage( Handle, wm_KeyDown, vk_Tab, 0 );
  end
  //else if ( Win32MajorVersion = 4 ) and ( Win32MinorVersion = 0 ) and ( Ord( Key ) = vk_Return ) then
  //  Key := #0
  else
    inherited KeyPress( Key );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgAccountLookupCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; ByUser: Boolean);
var
  sValue : string;
  MaskChar : Char;
begin
  if AccountComboDown then exit;

  sValue := tgAccountLookup.CurrentCell.Value;
  if (tgAccountLookup.CellEditing) then
  begin
    if (not RemovingMask) and MyClientFile.ecChart.AddMaskCharToCode(sValue,
       MyClientFile.ecFields.ecAccount_Code_Mask, MaskChar) Then
    begin
      sValue := sValue + MaskChar;
      tgAccountLookup.CurrentCell.Value := sValue;
      //move cursor to the last character
      tgAccountLookup.CurrentCell.SelStart := Length(sValue);
    end;
  end;
  //check to see if is a valid code
  if MyClientFile.ecChart.CanPressEnterNow( sValue) then
  begin
    //press enter
    PostMessage( Handle, wm_KeyDown, vk_Tab, 0 );
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgAccountLookupCellLoaded(Sender: TObject;
  DataCol, DataRow: Integer; var Value: Variant);
begin
  Value := DataArray[ tgDissect.CurrentDataRow].dtAccount;
  if (tgDissect.Col[ ccAccount].ReadOnly) then
    tgAccountLookup.CellButtonType[ 1, 1] := btNone
  else begin
    tgAccountLookup.CellButtonType[ 1, 1] := btCombo;
    tgAccountLookup.CellParentCombo[ 1, 1] := False;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgAccountLookupEndCellEdit(Sender: TObject;
  DataCol, DataRow: Integer; var Cancel: Boolean);
var
  sValue : string;
begin
  sValue := '';
  //convert variant to string
  sValue := tgAccountLookup.CurrentCell.Value;
  //update the transaction
  AccountEdited( sValue, tgDissect.CurrentDataRow);
  tgDissect.RowInvalidate( tgDissect.DisplayRownr[ DataRow]);
  ReloadPanel( tgDissect.CurrentDataRow);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.rbtnNextClick(Sender: TObject);
var
   NewRow : integer;
begin
  //set focus
  if (FocusedControl <> nil) then
  begin
    if (FocusedControl <> rbtnPrev) and (FocusedControl <> rbtnNext) and
       (FocusedControl.Parent = pnlPanel) then
    begin
      //pressing alt+n does not cause the exit/enter events because the
      //focus has not changed. CurrentPanelField <> 0 indicates that we are
      //current in a field
      if CurrentPanelField <> 0 then
        begin
          pfExit(FocusedControl);
          pfEnter(FocusedControl);
        end;
    end;
    SetFocusSafe(FocusedControl);
  end;

  NewRow := ( tgDissect.CurrentDataRow + 1);
  RepositionOnRow( NewRow);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.pfBeginEdit(DataCol: integer);
begin
   panelFieldEdited := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.pfEdited(Sender: TObject);
begin
   if ReloadingPanel then exit;  //don't want to pickup automatic updates

   if CurrentPanelField <> 0 then begin
      Assert( CurrentPanelField = TComponent( Sender).Tag, 'pfEdited - Wrong Tag ' +
                                                           inttostr( CurrentPanelField) + ' ' +
                                                           inttostr( TComponent( Sender).Tag));
      pfBeginEdit( CurrentPanelField);
      if CurrentPanelField = ccNotes then
         rzNotes.TabOnEnter := false;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.pfEndEdit(DataCol: integer);
var
  dValue  : double;
  DataRow : integer;
  sValue  : String;
  lOK     : Boolean;
  Index   : Integer;
begin
  if panelFieldEdited then
  begin
    lOK := True;
    panelFieldEdited := false;
    DataRow          := tgDissect.CurrentDataRow;
    //save new value
    case DataCol of
       //ccAccount :  handled by tgAccountLookup grid
       ccAmount : begin
         sValue := RemoveCharsFromString(rzAmount.Text,[',']);
         if (sValue <> '') and (sValue[1] = '(') then
         begin
           //negative value
           sValue[1] := '-';
           Index := Pos(')', sValue);
           if (Index > 0) then
             sValue := Copy(sValue,1,Index-1);
         end;
         lOK := MaskSet.Masks.Items[tgDissect.Col[ccAmount].MaskName].ValidText(sValue, True);
         if (lOK) then
         begin
           dValue := StrToFloatDef( rzAmount.Text, 0);
           AmountEdited( dValue, DataRow);
         end else
         begin
           pfEnter(rzAmount);
           SetFocusSafe( rzAmount);
         end;
       end;
       ccGSTAmount : begin
         sValue := RemoveCharsFromString(rzGSTAmount.Text,[',']);
         if (sValue <> '') and (sValue[1] = '(') then
         begin
           //negative value
           sValue[1] := '-';
           Index := Pos(')', sValue);
           if (Index > 0) then
             sValue := Copy(sValue,1,Index-1);
         end;
         lOK := MaskSet.Masks.Items[tgDissect.Col[ccGSTAmount].MaskName].ValidText(sValue, True);
         if (lOK) then
         begin
           if (rzGSTAmount.Text = '') then
           begin
             dValue := 0.00;
             GSTAmountEdited(dValue, DataRow, True);
           end else
           begin
             dValue := StrToFloatDef( rzGSTAmount.Text, 0);
             GSTAmountEdited( dValue, DataRow, False);
           end;
         end else
         begin
           pfEnter(rzGSTAmount);
           SetFocusSafe( rzGSTAmount);
         end;
       end;
       ccTaxInvoice : begin
          DataArray[ DataRow].dtTaxInvoice := chkTaxInv.Checked;
       end;
       ccNarration : begin
         DataArray[ DataRow].dtNarration    := rzNarration.Text;
       end;
       ccQuantity : begin
         sValue := RemoveCharsFromString(rzQuantity.Text,[',']);
         lOK := MaskSet.Masks.Items[tgDissect.Col[ccQuantity].MaskName].ValidText(sValue, True);
         if (lOK) then
         begin
          dValue := StrToFloatDef( rzQuantity.Text, 0);
          DataArray[ DataRow].dtQuantity := dValue * 10000;
         end else
         begin
           pfEnter(rzQuantity);
           SetFocusSafe( rzQuantity);
         end;
       end;
       //ccPayee : begin
       //   PayeeEdited( rzPayee.Text, DataRow);
       //end;
       ccNotes : begin
         DataArray[ DataRow].dtNotes := rzNotes.Text;
       end;

    end; //case
    if (lOK) then
    begin
      tgDissect.RowInvalidate( tgDissect.DisplayRownr[ tgDissect.CurrentDataRow]);;
      ReloadPanel( tgDissect.CurrentDataRow);
    end else
      ErrorMessage('The entered amount is too large. Please divide the value into smaller amounts.');
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.pfEnter(Sender: TObject);
//called when a panel field gets focus
begin
   CurrentPanelField := TComponent( Sender).Tag;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.pfExit(Sender: TObject);
var
  PanelField : Integer;
begin
   Assert( CurrentPanelField = TComponent( Sender).Tag, 'pfExit.  Wrong Tag. ' +
                                                        inttostr( CurrentPanelField) + ' ' +
                                                        inttostr( TComponent( Sender).Tag));

   if CurrentPanelField <> 0 then
   begin
     //value is copied in case there is an error in the pfEndEdit procedure
     PanelField := CurrentPanelField;
     CurrentPanelField := 0;
     pfEndEdit(PanelField);

     if (PanelField = ccNotes) then
       rzNotes.TabOnEnter := true;
   end;
end;
procedure TfrmDissection.PopupMenu1Popup(Sender: TObject);
begin

end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmDissection.GSTDifferentToDefault( DataRow : integer) : boolean;
//calculate default gst amount and class and see if current values are
//different
var
   DefaultGSTClass :  byte;
   DefaultGSTAmount   : money;
begin
   with DataArray[ DataRow] do begin
      CalculateGST( myClientFile, ParentTransaction^.txDate_Effective, dtAccount, dtAmount,
                    DefaultGSTClass, DefaultGSTAmount);
      Result := ( dtGST_Class <> DefaultGSTClass) or ( dtGST_Amount <> DefaultGSTAmount);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.FormKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if AnyKeysPressed then exit;

  AnyKeysPressed := true;
  if Key = #27 then ModalResult := mrCancel;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
   Count : integer;
   Remain, Total : double;

begin
   if ModalResult = mrOK then begin
      //make sure all edits are finished
      tgDissect.EndEdit( false);
      pfEndPanelEdit( false);
      //recalculate remaining amounts
      CalcControlTotals( Count, Total, Remain );
      if Total <> ParentTransaction^.txAmount then begin
         ErrorMessage( 'The remaining balance is not zero!  You must assign the remaining amount');
         CanClose := false;
         exit;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.pfEndPanelEdit(Undo: boolean);
begin
   pfEndEdit( CurrentPanelField);
   tgAccountLookup.EndEdit( Undo);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmDissection.tgDissectKeyPress(Sender: TObject; var Key: Char);
var
   DataCol : integer;
   sValue  : string;
begin
   if tgDissect.CellEditing then begin
      DataCol := tgDissect.CurrentDataCol;
      case DataCol of
         ccAmount : begin
            //calculate amount based on percentage
            if Key in ['%','/'] then begin
               Key := #0;
               sValue := tgDissect.CurrentCell.Value;
               tgDissect.CurrentCell.Value := CalcAmountFromPercentStr( sValue);
               tgDissect.EndEdit( false);
               tgDissect.CurrentDataCol := NextEditableCellRight;
            end;
            //complete the amount
            if Key = '=' then begin
               Key := #0;
               sValue := CalcAmountToCompleteStr;
               if (MaskSet.Masks.Items[tgDissect.Col[ccAmount].MaskName].ValidText(sValue, True)) then
               begin
                 tgDissect.CurrentCell.Value := sValue;
                 tgDissect.EndEdit( false);
                 tgDissect.CurrentDataCol := NextEditableCellRight;
               end else
               begin
                 tgDissect.CurrentCell.Value := '0.00';
                 tgDissect.EndEdit(False);
                 ErrorMessage('The calculated amount is too large. Please divide the value into smaller amounts.');
               end;
            end;
            if Key = '-' then begin
              Key := #0;
              sValue := tgDissect.CurrentCell.Value;
              if (Pos('(', sValue) = 1) then
                tgDissect.CurrentCell.Value := Copy(sValue, 2, Length(sValue)-2)
              else if (Pos('-', sValue) = 1) then
                tgDissect.CurrentCell.Value := Copy(sValue, 2, Length(sValue)-1)
              else if StrToFloatDef(sValue, 0) = 0 then
                tgDissect.CurrentCell.Value := '-'
              else
                tgDissect.CurrentCell.Value := '-' + sValue;
            end;
         end;

         ccGSTAmount : begin
            if Key in ['%','/'] then begin
               Key := #0;
               sValue := tgDissect.CurrentCell.Value;
               tgDissect.CurrentCell.Value := CalcGSTAmountFromPercentStr( sValue);
               tgDissect.EndEdit( false);
               tgDissect.CurrentDataCol := NextEditableCellRight;
            end;
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.rzAmountKeyPress(Sender: TObject; var Key: Char);
var
  NextControl : TWinControl;
begin
  if ( Key >= '0') and ( Key <= '9') then
  begin
    if not NumberIsValid( rzAmount, 9, 2) then
    begin
      Key := #0;
      exit;
    end;
  end;

  if PanelFieldEdited then
  begin
    //calculate amount based on percentage
    if Key in ['%','/'] then
    begin
      Key := #0;
      rzAmount.Text := CalcAmountFromPercentStr( rzAmount.Text);
      NextControl := FindNextControl(TWinControl(Sender), True, True, False);
      NextControl.SetFocus;
    end;
  end
  else
  begin
    if Key = '=' then
    begin
      Key := #0;
      rzAmount.Text := CalcAmountToCompleteStr;
      NextControl := FindNextControl(TWinControl(Sender), True, True, False);
      NextControl.SetFocus;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.RemoveBlanks;
//remove blank lines from the dissection
//starting with first line, if line is blank move next line in,
var
   FirstBlankPos     : integer;
   NotBlankPos   : integer;
   Rec1        : TWork_Dissect_Rec;
   Rec2        : TWork_Dissect_Rec;
   BlankRec    : TWork_Dissect_Rec;
begin
   FirstBlankPos := 1;
   NotBlankPos := 1;
   FillChar( BlankRec, SizeOf( BlankRec), 0);

   while not (( FirstBlankPos > glConst.Max_tx_Lines) or ( NotBlankPos > glConst.Max_tx_Lines)) do
   begin
      Rec1 := DataArray[ FirstBlankPos];
      //if current line is not blank move onto next
      if ( Rec1.dtAccount <> '') or ( Rec1.dtAmount <> 0) or (Rec1.dtNotes <> '') then begin
         Inc( FirstBlankPos);
      end
      else begin
         //current line is blank, search for a line to copy into it.
         NotBlankPos := FirstBlankPos + 1;
         while ( NotBlankPos <= glConst.Max_tx_Lines) do begin
            Rec2 := DataArray[ NotBlankPos];
            if (( Rec2.dtAccount = '') and ( Rec2.dtAmount = 0) and (Rec2.dtNotes = '')) then
               Inc( NotBlankPos)
            else begin
               //a non blank line found, copy line into first blank pos
               DataArray[ FirstBlankPos] := DataArray[ NotBlankPos];
               DataArray[ NotBlankPos]  := BlankRec;
               Break;
            end;
         end;
      end;
   end;
   //reload table
   tgDissect.Invalidate;
   tgDissect.CurrentDataRow := 1;
   ReloadPanel( 1);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.Button1Click(Sender: TObject);
begin
  inherited;
  RemoveBlanks;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmDissection.CalcAmountFromPercentStr(sPercent: string): string;
//accepts a text string and converts it to a percentage
//returns a text string which is the new amount
var
   mNewAmount : Money;
   mRowAmount : Money;
   mTotal     : Money;
   mRemainder : Money;
   Percentage: Double;
   Count       : integer;
   dTotal, dRemain : double;
begin
     Percentage := StrToFloatDef( sPercent, 0);
     //find the rounded money value for the amount
     mNewAmount  := Double2Money( Money2Double( ParentTransaction^.txAmount ) * ( Percentage/100.0 ));
     //now figure out what the remainder will be with this new NewAmount
     CalcControlTotals( Count, dTotal, dRemain );
     //calccontrol will have given the remainder based on the last value in this cell
     //remove that value then add the current value.
     mRowAmount := DataArray[ tgDissect.CurrentDataRow].dtAmount;
     mTotal := dTotal - mRowAmount + mNewAmount;
     mRemainder := ParentTransaction.txAmount - mTotal;
     //if it is less $0.05 then add it to the NewAmount
     if Abs( mRemainder) < 5 then
        mNewAmount := mNewAmount + mRemainder;
     result := FormatFloat( '0.00', mNewAmount / 100 );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmDissection.CalcGSTAmountFromPercentStr(sPercent: string): string;
//accepts a text string and converts it to a percentage
//returns a text string which is the new amount
var
   mNewAmount : Money;
   InclusiveAmt : Money;
   Percentage: Double;
begin
     Percentage := StrToFloatDef( sPercent, 0);
     //check that the percentage value make sense
     if ( Percentage <= 0.0 ) or ( Percentage > 100.0) then exit;
     //find the new GST Amount
     InclusiveAmt := DataArray[ tgDissect.CurrentDataRow].dtAmount;
        // Gst = Inclusive *      1
        //                    --------
        //                     1
        //              --------------
        //             ((Rate / 100) + 1 )
     mNewAmount := InclusiveAmt * ( 1 / ( 1/( Percentage/100) +1));
     //find the rounded money value for the amount
     result := FormatFloat( '0.00', mNewAmount / 100 );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmDissection.CalcAmountToCompleteStr: string;
var
   RowAmount : Money;
   Count       : integer;
   dTotal, dRemain : double;
begin
   CalcControlTotals( Count, dTotal, dRemain );
   RowAmount := DataArray[ tgDissect.CurrentDataRow].dtAmount;
   // Calc the new RowAmount
   RowAmount := RowAmount + ( dRemain{*100});
   result := FormatFloat( '0.00', RowAmount / 100 );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.JobEdited(NewValue: string; DataRow: Integer);
var
  Job: TECJob;
  Msg: String;
  NewCode: string[8];
begin
  if NewValue = '' then
  begin
     DataArray[ DataRow].dtJob_Code := '';
    Exit;
  end;

  //see if they've entered in code or name
  Job := MyClientFile.ecJobs.Job_Search(NewValue);

  if not Assigned(Job) then
  begin
       //need to check if a job already exists with the new job code
     NewCode := NewValue;
     if Assigned(MyClientFile.ecJobs.Find_Job_Code(NewCode)) then
     begin
       WarningMessage('This job already exists');
       Exit;
     end;

     Msg := 'This job does not currently exist.' + #13#10 +
       'Would you like to add ' + NewValue + ' as a new job?';
     if Application.MessageBox(PChar(Msg), 'Add new job',
                           MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON1) = IDYES then
     begin
       Job := TECJob.Create;
       Job.jhFields.jhLRN := MyClientFile.ecJobs.Get_New_Job_Number;
       if (Job.jhFields.jhLRN = -1) then
         Job.jhFields.jhLRN := 1;
       Job.jhFields.jhCode := NewValue;
       Job.jhFields.jhHeading := NewValue;
       Job.jhFields.jhAdded_By_ECoding := true;
       MyClientFile.ecJobs.Insert(Job);
       DataArray[ DataRow].dtJob_Code :=Job.jhFields.jhCode;

       //refresh the combo boxes
       if (tgDissect.CurrentDataCol = ccJob) then
         tgDissect.ResetCombo;
       tgJobLookup.ResetCombo;
     end;
    Exit;
  end;

  if Job.jhFields.jhIsCompleted then
  begin
    WarningMessage('This job is completed and cannot be selected');
    exit;
  end;

  DataArray[ DataRow].dtJob_Code := Job.jhFields.jhCode;
end;


procedure TfrmDissection.PayeeEdited(NewValue: string; DataRow: integer);
var
  Value, Code      : Integer;
  APayee : TECPayee;
  isPayeeDissected : boolean;
  DissectAmt   : PayeeSplitTotals;  //dynamic array
  i            : integer;
  S            : string;
  lineNo         : integer;
  LinesRequired  : integer;
  NotEnoughLines : Boolean;
  Rec1           : TWork_Dissect_Rec;
  Msg              : String;
  PayeeLine      : pPayee_Line_Rec;
begin
  NewValue := Trim( NewValue);
  if NewValue <> '' then begin
    Val(NewValue, Value, Code);
    if (Code = 0) then
      //try to find payee by code
      APayee := MyClientFile.ecPayees.Find_Payee_Number(Value)
    else
      //try to find payee by name
      APayee := MyClientFile.ecPayees.Find_Payee_Name( NewValue);
    if Assigned(APayee) then
      DataArray[ DataRow].dtPayee_Number := APayee.pdNumber
    else
    begin
      if (Code <> 0) then
      begin
        //new entry is not numeric
        Msg := 'This payee does not currently exist.' + #13#10 +
          'Would you like to add ' + NewValue + ' as a new payee?';
        if Application.MessageBox(PChar(Msg), 'Add new payee',
                              MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON1) = IDYES then
        begin
          aPayee := TECPayee.Create;
          aPayee.pdFields.pdNumber := MyClientFile.ecPayees.Get_New_Payee_Number;
          if (aPayee.pdFields.pdNumber = -1) then
            aPayee.pdFields.pdNumber := 1;
          aPayee.pdFields.pdName := NewValue;
          aPayee.pdFields.pdAdded_By_ECoding := True;
          MyClientFile.ecPayees.Insert(aPayee);
          DataArray[ DataRow].dtPayee_Number := aPayee.pdNumber;
          //refresh the combo boxes
          if (tgDissect.CurrentDataCol = ccPayee) then
            tgDissect.ResetCombo;
          tgPayeeLookup.ResetCombo;
        end;
      end else
        DataArray[ DataRow].dtPayee_Number := 0;
    end;
  end
  else begin
    //blank payee entered, see if user is deleting payee
    if DataArray[ DataRow].dtPayee_Number <> 0 then begin
       //deleting payee, clear payee and coding
       DataArray[ DataRow].dtPayee_Number  := 0;
       if ParentTransaction.txCode_Locked then
          Exit;
       //clear coding
       DataArray[ DataRow].dtAccount       := '';
       DataArray[ DataRow].dtGST_Class     := 0;
       DataArray[ DataRow].dtGST_Amount    := 0;
       DataArray[ DataRow].dtGST_Has_Been_Edited := false;
       DataArray[ DataRow].dtHas_Been_Edited     := false;
    end;
    exit;
  end;

  if ( DataArray[ DataRow].dtPayee_Number = 0) then exit;
  if ( ParentTransaction^.txCode_Locked) then exit;

  APayee := MyClientFile.ecPayees.Find_Payee_Number(DataArray[ DataRow].dtPayee_Number);
  //Payee is dissected if more than one line with Account Code
  isPayeeDissected := APayee.IsDissected;
  with DataArray[ DataRow], APayee do begin
     //code the entry with the details from the payee
     if not (isPayeeDissected) then begin
       if (APayee.pdLines.ItemCount > 0) then
       begin
         //payee is a single line so alter existing transaction
         PayeeLine := APayee.FirstLine;
         dtAccount     := PayeeLine.plAccount;
         dtNarration :=   PayeeLine.plGL_Narration;
         if (PayeeLine.plGST_Has_Been_Edited) then begin
            dtGST_Class    := PayeeLine.plGST_Class;
            dtGST_Amount   := CalculateGSTForClass( MyClientFile, ParentTransaction.txDate_Effective, dtAmount, dtGST_Class);
            dtGST_Has_Been_Edited := true;
         end
         else begin
            //must check to see if a chart is available, if not use the gst class in the payee
            if MyClientFile.ecChart.ItemCount > 0 then
               CalculateGST( MyClientFile, ParentTransaction.txDate_Effective, dtAccount, dtAmount, dtGST_Class, dtGST_Amount)
            else begin
               dtGST_Class    := PayeeLine.plGST_Class;
               dtGST_Amount   := CalculateGSTForClass( MyClientFile, ParentTransaction.txDate_Effective, dtAmount, dtGST_Class);
            end;
            dtGST_Has_Been_Edited := false;
         end;
       end;
     end
     else begin
        //payee is dissected, so dissect the transaction
        LinesRequired := APayee.pdLines.ItemCount;

        //check something to do
        if LinesRequired = 0 then exit;

        //can reduce by 1 because will use current line.
        Dec( LinesRequired);

        //check if we can insert this required no on lines.
        //count valid lines below this line
        LineNo := tgDissect.CurrentDataRow;
        //see if there are blank lines at the bottom of the table so can more
        //all subsequent rows down.
        NotEnoughLines := false;
        if ( LineNo + LinesRequired) > ( glConst.Max_tx_Lines) then
           NotEnoughLines := true
        else begin
           for i := 1 to LinesRequired do begin
              Rec1 := DataArray[ (tgDissect.Rows - i) +1];
              if ( Rec1.dtAccount <> '') or ( Rec1.dtAmount <> 0) or (Rec1.dtNotes <> '') then begin
                 NotEnoughLines := true;
                 Break;
              end;
           end;
        end;
        if NotEnoughLines then begin
           S := 'The are not enough empty dissection lines to expand this entry.';
           WarningMessage( S);
           exit;
        end;

        //shuffle existing lines down x rows
        InsertRowsAfter( LineNo, LinesRequired);
        //split value
        PayeePercentageSplit( dtAmount, aPayee, DissectAmt);
        //insert lines
        for i := aPayee.pdLines.First to aPayee.pdLines.Last do
        begin
           PayeeLine := aPayee.pdLines.PayeeLine_At(i);
           with DataArray[ LineNo] do begin
              dtPayee_Number := pdNumber;
              dtNarration    := PayeeLine.plGL_Narration;
              dtAccount      := PayeeLine.plAccount;
              dtAmount       := DissectAmt[ i];
              if ( PayeeLine.plGST_Has_Been_Edited) then begin
                 dtGST_Class    := PayeeLine.plGST_Class;
                 dtGST_Amount   := CalculateGSTForClass( MyClientFile,
                                                         ParentTransaction.txDate_Effective,
                                                         dtAmount,
                                                         dtGST_Class);
                 dtGST_Has_Been_Edited := true;
              end
              else begin
                 //if no chart then take default gst from the payee
                 if MyClientFile.ecChart.ItemCount > 0 then begin
                    CalculateGST( MyClientFile,
                                  ParentTransaction.txDate_Effective,
                                  dtAccount,
                                  dtAmount,
                                  dtGST_Class,
                                  dtGST_Amount);
                 end
                 else begin
                    dtGST_Class    := PayeeLine.plGST_Class;
                    dtGST_Amount   := CalculateGSTForClass( MyClientFile,
                                                         ParentTransaction.txDate_Effective,
                                                         dtAmount,
                                                         dtGST_Class);
                 end;
                 dtGST_Has_Been_Edited := false;
              end;
           end;
           //move to next line
           Inc( LineNo);
        end;
     end;
  end;  {with payee^, pd^}
  UpdateDisplayTotals;
  tgDissect.Invalidate;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.InsertRowsAfter(Row, NewRows: integer);
//insert x newrows after the current row num
var
   FromRowNum : integer;
   ToRowNum   : integer;
begin
   //move rows down, starting from bottom of list
   ToRowNum := tgDissect.Rows;
   FromRowNum := ToRowNum - NewRows;

   while FromRowNum > Row do begin
      //copy fields
      DataArray[ ToRowNum] := DataArray[ FromRowNum];
      //blank from rec
      FillChar( DataArray[ FromRowNum], SizeOf( TWork_Dissect_Rec), #0);
      Dec( ToRowNum);
      FromRowNum := ToRowNum - NewRows;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgDissectKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  sValue : String;
  MaskChar : Char;
   DataRow : integer;
begin
  KeyIsDown := true;

  if (Key = VK_BACK) then
  begin
    if (tgDissect.CurrentDataCol = ccAccount) then
    begin
      sValue := tgDissect.CurrentCell.Value;
      sValue := Copy(sValue, 1, Length(sValue) - 1);
      if MyClientFile.ecChart.AddMaskCharToCode(sValue,
         MyClientFile.ecFields.ecAccount_Code_Mask, MaskChar) Then
      begin
        RemovingMask := True;
        try
          tgDissect.CurrentCell.Value := sValue;
          //move cursor to the last character
          tgDissect.CurrentCell.SelStart := Length(sValue);
        finally
          RemovingMask := False;
        end;
      end;
    end;
  end;

  if tgDissect.CellEditing then exit;

  DataRow := tgDissect.CurrentDataRow;

  case Key of
    107, 43: // +
      begin
        if tgDissect.EditorActive then exit;
        Key := 0;
        KeyIsCopy := True;
      end;
    vk_delete :
      begin
        if (Shift = [ssCtrl]) then begin
           DoClearRow( DataRow);
           tgDissect.Invalidate;
           ReloadPanel( DataRow);
        end;

        if ( tgDissect.CellReadOnly[ tgDissect.CurrentDataCol, tgDissect.CurrentDataRow] = roOn) or
           ( tgDissect.Col[ tgDissect.CurrentDataCol].ReadOnly) then exit;

        Key := 0;
        tgDissect.ShowEditor;
        tgDissect.CurrentCell.Value := '';
        tgDissect.HideEditor;
      end;
    VK_F8 :
    begin
      DoGotoNextUncoded;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.DoClearRow( DataRow : integer);
begin
   //make sure code is not locked
   if ParentTransaction.txCode_Locked then exit;

   FillChar( DataArray[ DataRow], SizeOf( TWork_Dissect_Rec), #0);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgDissectExit(Sender: TObject);
begin
  tgDissect.HideEditor;
  tgDissect.FocusBorder  := tsGrid.fbNone;
end;

procedure TfrmDissection.tgDissectEnter(Sender: TObject);
begin
  tgDissect.FocusBorder  := tsGrid.fbDouble;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.rbtnPrevClick(Sender: TObject);
var
   NewRow : integer;
begin
  //set focus
  if (FocusedControl <> nil) then
  begin
    if (FocusedControl <> rbtnPrev) and (FocusedControl <> rbtnNext) and
       (FocusedControl.Parent = pnlPanel) then
    begin
      //pressing alt+n does not cause the exit/enter events because the
      //focus has not changed. CurrentPanelField <> 0 indicates that we are
      //current in a field
      if CurrentPanelField <> 0 then
        begin
          pfExit(FocusedControl);
          pfEnter(FocusedControl);
        end;
    end;
    SetFocusSafe(FocusedControl);
  end;

  NewRow := ( tgDissect.CurrentDataRow - 1);
  RepositionOnRow( NewRow);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.RepositionOnRow(NewDataRow: integer);
const
   RowsDown = 4;
begin
   if NewDataRow > tgDissect.Rows then
      NewDataRow := tgDissect.Rows;

   if NewDataRow < 1 then
      NewDataRow := 1;

   tgDissect.CurrentDataRow := NewDataRow;
   if ( NewDataRow > RowsDown) then
      tgDissect.TopRow := NewDataRow - RowsDown
   else begin
      tgDissect.TopRow := 1;
   end;

   //there seems to be a problem scrolling to the last row
   if ( tgDissect.CurrentDataRow = tgDissect.Rows) then begin
      PostMessage( tgDissect.Handle, wm_KeyDown, VK_UP, 0 );
      PostMessage( tgDissect.Handle, wm_KeyDown, VK_DOWN, 0 );
   end;

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgAccountLookupEnter(Sender: TObject);
begin
  inherited;
  tgAccountLookup.AlwaysShowFocus := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgAccountLookupExit(Sender: TObject);
begin
  inherited;
  tgAccountLookup.AlwaysShowFocus := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgDissectInvalidMaskValue(Sender: TObject;
  DataCol, DataRow: Integer; var Accept: Boolean);
begin
   if DataCol in [ ccAmount, ccGSTAmount, ccQuantity] then begin
      //assume that invalid characters will have been filtered out
      //StrToFloatDef will handle the rest
      Accept := true;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.rzGSTAmountKeyPress(Sender: TObject;
  var Key: Char);
var
  NextControl : TWinControl;
begin
  if ( Key >= '0') and ( Key <= '9') then
  begin
    if not NumberIsValid( rzGSTAmount, 9 ,2) then
    begin
      Key := #0;
      exit;
    end;
  end;

  if PanelFieldEdited then begin
     //calculate amount based on percentage
     if Key in ['%','/'] then begin
        Key := #0;
        rzGSTAmount.Text := CalcGSTAmountFromPercentStr( rzGSTAmount.Text);
        NextControl := FindNextControl(TWinControl(Sender), True, True, False);
        NextControl.SetFocus;
     end;
  end
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tgDissectColMoved(Sender: TObject; ToDisplayCol,
  Count: Integer; ByUser: Boolean);
var
   i : integer;
begin
   //unselect cols
   if ByUser then begin
      for i := 1 to tgDissect.cols do
         tgDissect.Col[ i].Selected := false;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmDissection.DoGotoNextUncoded;
//Move the cursor to the next uncoded line from the current position by pressing F8
var
  NextPos : integer;
  SaveRow : integer;
begin
  if tgDissect.EditorActive then exit;

  //Sort the list and remove all the blank lines in between, store current row
  //so that can start from there
  SaveRow := tgDissect.CurrentDataRow;
  RemoveBlanks;
  tgDissect.CurrentDataRow := SaveRow;

  NextPos := FindUncoded( tgDissect.CurrentDataRow );  //ActiveRow?
  if NextPos < 0 then
     InfoMessage( 'All lines have been coded')
  else
  begin
    tgDissect.CurrentDataRow := NextPos;
    //tgDissect.CurrentDataCol := ColumnFmtList.GetColNumOfField(ceAccount);
  end;
end;

procedure TfrmDissection.EditSuperFields1Click(Sender: TObject);
begin
  inherited;
  btnsuperclick(nil);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Search Transaction list for Uncoded Entries.
// Search from ( current row + 1 ) back round to current row.
// Return Row Number of Uncoded Entry or -1.
// Note that this routine accepts and returns Grid Row which = FTranList Row + 1
function TfrmDissection.FindUncoded( const TheCurrentRow : Integer ) : Integer;

   function DissectLineUncoded(pD : TWork_Dissect_Rec) : boolean;
   var
     Coded : boolean;
   begin
     Coded := MyClientFile.ecChart.CanCodeTo(pD.dtAccount) or ( pD.dtPayee_Number <> 0) or ( pD.dtNotes <> '');
     result := not Coded;
   end;

   procedure IncEntry( var Entry : Integer );
   //Increments List Entry number in circular fashion
   begin
      Inc( Entry );
      if ( Entry > GLCONST.Max_tx_Lines ) then
        Entry := 1;
   end;

var
   CurrentEntry : Integer;
   i            : Integer;
   FoundUnCoded : boolean;
   pD           : TWork_Dissect_Rec;
begin
   foundUnCoded := false;

   CurrentEntry := TheCurrentRow;
   i := CurrentEntry;
   IncEntry( i );
   Repeat
      pD := DataArray[i];
      with pD do begin
         if (dtAccount <> '') or (dtAmount <> 0) or (dtNotes <> '') then begin //valid line
           if MyClientFile.ecChart.CountBasicItems > 0 then //check to see if a chart exists
             foundUnCoded := DissectLineUncoded(pD)
           else
             foundUnCoded := (
                               ( pD.dtAccount = '') and
                               ( pD.dtNotes ='') and
                               ( pD.dtPayee_Number = 0)
                              );
           if FoundUnCoded then begin
             Result := i;
             Exit;
           end;
         end;
      end;
      IncEntry( i );
   Until ( i = CurrentEntry );

   //have checked all other lines now check current line, if it is valid
   pD := DataArray[CurrentEntry];
   if (pD.dtAccount <> '') or (pd.dtAmount <> 0) or (pd.dtNotes <> '') then begin //valid line
     if MyClientFile.ecChart.CountBasicItems > 0 then //check to see if a chart exists
       foundUnCoded := DissectLineUncoded(pD)
     else
       foundUnCoded := (
                         ( pD.dtAccount = '') and
                         ( pD.dtNotes ='') and
                         ( pD.dtPayee_Number = 0)
                        );
   end;

   if FoundUnCoded then
      Result := i
   else
      result := -1;
end;

procedure TfrmDissection.chkShowPanelClick(Sender: TObject);
begin
  pnlPanel.Visible := chkShowPanel.Checked;
  if (tgDissect.Cols > 0) and (tgDissect.Rows > 0) then
    tgDissect.PutCellInView(tgDissect.CurrentDataCol,tgDissect.CurrentDataRow);
end;

procedure TfrmDissection.chkTaxInvKeyPress(Sender: TObject; var Key: Char);
//reinterpret enter as tab,
//can't use raise check box because exit event does not seem to work
begin
  if ( Ord( Key ) = vk_Return ) then
  begin
    Key := #0;
    PostMessage( Handle, wm_KeyDown, vk_Tab, 0 );
  end else
    inherited KeyPress( Key );
end;

procedure TfrmDissection.tgPayeeLookupCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
var
  APayee : TECPayee;
begin
  if ( tgDissect.Rows < 1) then exit;  //no transactions in account

  APayee := MyClientFile.ecPayees.Find_Payee_Number(  DataArray[ tgDissect.CurrentDataRow].dtPayee_Number);
  if Assigned(APayee) then Value := APayee.pdName;
  //Value := IntToStr(DataArray[ tgDissect.CurrentDataRow].dtPayee_Number);
  if (tgDissect.Col[ ccPayee].ReadOnly) then
    tgPayeeLookup.CellButtonType[ 1, 1] := btNone
  else begin
    tgPayeeLookup.CellButtonType[ 1, 1] := btCombo;
    tgPayeeLookup.CellParentCombo[ 1, 1] := False;
  end;
end;

procedure TfrmDissection.tgPayeeLookupEndCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
var
  sValue : string;
begin
  sValue := '';
  //convert variant to string
  sValue := tgPayeeLookup.CurrentCell.Value;
  //update the transaction
  PayeeEdited( sValue, tgDissect.CurrentDataRow);
  tgDissect.RowInvalidate( tgDissect.DisplayRownr[ DataRow]);
  ReloadPanel( tgDissect.CurrentDataRow);
end;

procedure TfrmDissection.tgPayeeLookupEnter(Sender: TObject);
begin
  inherited;
  tgPayeeLookup.AlwaysShowFocus := true;
end;

procedure TfrmDissection.tgPayeeLookupExit(Sender: TObject);
begin
  inherited;
  tgPayeeLookup.AlwaysShowFocus := false;
end;

procedure TfrmDissection.tgPayeeLookupKeyPress(Sender: TObject;
  var Key: Char);
begin
  if PayeeComboDown then exit;

  if ( Ord( Key ) = vk_Return ) then
  begin
    Key := #0;
    PostMessage( Handle, wm_KeyDown, vk_Tab, 0 );
  end
  //else if ( Win32MajorVersion = 4 ) and ( Win32MinorVersion = 0 ) and ( Ord( Key ) = vk_Return ) then
  //  Key := #0
  else
    inherited KeyPress( Key );
end;

procedure TfrmDissection.FormDestroy(Sender: TObject);
begin
  inherited;
  if Assigned( FHint ) then begin
    if FHint.HandleAllocated then FHint.ReleaseHandle;
    FHint.Free;
    FHint := nil;
  end;

  tgPayeeLookup.DestroyDefaultCombo;
  tgAccountLookup.DestroyDefaultCombo;
end;

procedure TfrmDissection.FormResize(Sender: TObject);
var
  i, Value : Integer;
begin
  HideCustomHint;
  //resize the notes column
  if (tgDissect.Cols = ccNotes) then
  begin
    Value := 0;
    for i := 1 to tgDissect.Cols - 1 do
      if (i <> ccNotes) and (tgDissect.Col[i].Visible) then
        Value := Value + tgDissect.Col[i].Width;

    //test for minimum size
    if ((tgDissect.Width - Value) <= 64) then
      tgDissect.Col[ccNotes].Width := ccDefaultWidth[ccNotes]
    else
      tgDissect.Col[ccNotes].Width := (tgDissect.ClientWidth - Value);
  end;
end;

procedure TfrmDissection.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_Return :
      begin
        //allows the enter key to perform a button click
        if (ActiveControl is TButton) then
        begin
          TButton(ActiveControl).Click;
          Key := 0;
        end;
      end;
  end;
end;

function TfrmDissection.GetDissectionHint(const Disection: PWork_Dissect_Rec): string;
//returns a hint message for use in the dissection screen
//
//
var
  A: pAccount_Rec ;
  DS: string[ 80 ] ;
  HintSL: TStringList;
  MaxVLen: Integer;

begin
  Result    := '' ;

  HintSL := TStringList.Create;
  Try
    //show coding information
    if ( Disection.dtAccount <> '' ) and ( MyClientFile.ecChart.CountBasicItems > 0) then
    begin
      A := MyClientFile.ecChart.FindCode( Disection.dtAccount ) ;
      if not Assigned( A ) then
      begin
        HintSL.Add( 'INVALID CODE!' );
      end
      else
      begin
        //show chart code description
        DS := A^.chAccount_Description ;
        HintSL.Add( DS );
      end;
    end;

    if Disection.dtSF_Edited then begin
          MaxVLen := Length(TrimSpacesS(Format( '%15.2n', [ Abs( Disection.dtAmount ) / 100 ] ))) + 1;
          if Disection.dtSF_Franked  <> 0  then
             HintSL.Add( '         Franked ' +  LeftPadS(TrimSpacesS(Format('%15.2n', [Abs(Disection.dtSF_Franked) / 100 ])),MaxVLen));
          if Disection.dtSF_Franked <> 0  then
             HintSL.Add( '       Unfranked ' +  LeftPadS(TrimSpacesS(Format('%15.2n', [Abs(Disection.dtSF_Unfranked) / 100 ])),MaxVLen));
          if Disection.dtSF_Franking_Credit <> 0  then
             HintSL.Add( 'Franking Credits ' +  LeftPadS(TrimSpacesS(Format('%15.2n', [Abs(Disection.dtSF_Franking_Credit) / 100 ])),MaxVLen));
      end;

    if HintSL.Count = 0 then exit;

    //trim final ODOA
    result := HintSL.Text;
    // Remove the final #$0D#$0A
    if Length( Result ) > 2 then
      SetLength( Result, Length( Result )-2 );
  Finally
    HintSL.Free;
  end;
end ;

procedure TfrmDissection.HideCustomHint;
var
  R : TRect;
begin
  if Assigned( FHint ) then begin
    if FHint.HandleAllocated then
    begin
      //find where the Hint is, so we can redraw the cells beneath it.
      GetWindowRect( FHint.Handle, R );
      R.TopLeft      := tgDissect.ScreenToClient(R.TopLeft);
      R.BottomRight  := tgDissect.ScreenToClient(R.BottomRight);
      FHint.ReleaseHandle;
      FHintShowing := false;

      tmrHideHint.Enabled := false;
    end;
  end;
end;

procedure TfrmDissection.ShowHintForCell(const RowNum, ColNum: integer);
var
  HR, CR : TRect;
  MP     : TPoint;
  Msg    : String;

  Code   : string;
  pJob: TECJob;
begin
  if not PtInRect( pnlCoding.BoundsRect, Self.ScreenToClient( Mouse.CursorPos ) ) then
    Exit;

  if (tgDissect.Rows < 1) then
    Exit;

  Msg := '';
  Code := DataArray[ RowNum].dtAccount;
  tmrHideHint.Enabled := false;

  case ColNum of
    ccAccount,
    ccAmount : begin
      if tgDissect.Col[ccAccount].Visible then
      begin
        Msg := GetDissectionHint(@DataArray[RowNum]);

        if ParentTransaction^.txCode_Locked then
          if Msg <> '' then
            Msg := 'Coded by Accountant:'#13 + Msg
          else
            Msg := 'Coded by Accountant';
      end;
    end;

    ccPayee : begin
      if tgDissect.Col[ccPayee].Visible then
      begin
        if ParentTransaction^.txCode_Locked then
          Msg := 'Coded by Accountant';
      end;
    end;
    ccJob:
      begin
        if tgDissect.Col[ccJob].Visible then
        begin
          if DataArray[RowNum].dtJob_Code <> '' then
          begin
            pJob := MyClientFile.ecJobs.Find_Job_Code(DataArray[RowNum].dtJob_Code);
            if Assigned(pJob) then
              Msg := pJob.jhFields.jhHeading;
          end;
        end;
      end;
    ccIcon : begin
       if DataArray[RowNum].dtSF_Edited then
             MSG := MSG + 'Superfund details added'
    end;
  end;

  //show the hint
  if (Msg <> '') then
  begin
    //set description label
    HR := FHint.CalcHintRect( Screen.Width, Msg, NIL );
    Inc( HR.Bottom, 2 );
    Inc( HR.Right, 6 );
    CR := tgDissect.CellRect(ColNum, RowNum);
    MP.X := CR.Right;
    MP.Y := CR.Bottom;
    MP := tgDissect.ClientToScreen(MP);
    OffsetRect( HR, MP.X, MP.Y);

    //now show hint
    if Msg = 'INVALID CODE!' then
       FHint.Color := clRed
    else
       FHint.Color := Application.HintColor;

    FHint.ActivateHint(HR, Msg);
    FHintShowing := true;

    tmrHideHint.Enabled := true;
  end;

  LastHintRow := RowNum;
  LastHintCol := ColNum;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.FormDeactivate(Sender: TObject);
begin
  HideCustomHint;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.CMMouseLeave(var Message: TMessage);
begin
  HideCustomHint;
end;

procedure TfrmDissection.Copy1Click(Sender: TObject);
begin
  inherited;
  keybd_event( 17, 1, 0, 0 );   // Ctrl key down
  keybd_event( 67, 1, 0, 0 );   // C key
  keybd_event( 17, 1, 2, 0 );   // Ctrl key up
end;

procedure TfrmDissection.Copycontentsofthecellabove1Click(Sender: TObject);
var
  Copied: Boolean;
  wPrev: TWork_Dissect_Rec;
  Row: Integer;
begin
  Copied := False;
  Row := tgDissect.CurrentDataRow;
  if Row > 1 then
  begin
    wPrev := DataArray[Row-1];
    case tgDissect.CurrentDataCol of
      ccAccount:
        begin
          if tgDissect.CurrentCell.Value = '' then
          begin
            Copied := True;
            AccountEdited(wPrev.dtAccount, Row);
          end;
        end;
      ccAmount:
        begin
          if tgDissect.CurrentCell.Value = 0 then
          begin
            Copied := True;
            AmountEdited(Money2Double(wPrev.dtAmount), Row);
          end;
        end;
      ccGSTAmount:
        begin
          try
            if tgDissect.CurrentCell.Value = '' then
            begin
              Copied := True;
              DataArray[tgDissect.CurrentDataRow].dtGST_Amount := wPrev.dtGST_Amount;
            end;
          except
          end;
        end;
      ccNarration:
        begin
          Copied := True;
          DataArray[tgDissect.CurrentDataRow].dtNarration := wPrev.dtNarration;
        end;
      ccQuantity:
        begin
          if tgDissect.CurrentCell.Value = 0 then
          begin
            Copied := True;
            DataArray[tgDissect.CurrentDataRow].dtQuantity := wPrev.dtQuantity;
          end;
        end;
      ccPayee:
        begin
          if tgDissect.CurrentCell.Value = '' then
          begin
            Copied := True;
            PayeeEdited(tgDissect.Cell[tgDissect.CurrentDataCol, tgDissect.CurrentDataRow-1], Row);
          end;
        end;
      ccJob:
        begin
          if tgDissect.CurrentCell.Value = '' then
          begin
            Copied := True;
            JobEdited(tgDissect.Cell[tgDissect.CurrentDataCol, tgDissect.CurrentDataRow - 1], Row);
          end;
        end;
      ccNotes:
        begin
          if tgDissect.CurrentCell.Value = '' then
          begin
            Copied := True;
            DataArray[tgDissect.CurrentDataRow].dtNotes := wPrev.dtNotes;
          end;
        end;
      ccTaxInvoice:
      begin
        if tgDissect.CurrentCell.Value = '' then
          begin
            Copied := True;
            DataArray[tgDissect.CurrentDataRow].dtTaxInvoice := wPrev.dtTaxInvoice;
          end;
      end;
    end;
    if Copied then
    begin
      tgDissect.Invalidate;
      keybd_event(vk_right, 1 ,0 ,0);
    end;
  end;
end;

procedure TfrmDissection.Paste1Click(Sender: TObject);
begin
  inherited;
  keybd_event( 17, 1, 0, 0 );   // Ctrl key down
  keybd_event( 86, 1, 0, 0 );   // V key
  keybd_event( 17, 1, 2, 0 );   // Ctrl key up
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.CMMouseEnter(var Message: TMessage);
var
  pt: TPoint;
begin
  if GetActiveWindow <> Self.Handle then
    Exit;

  if FHintShowing then
    Exit;

  try
    if tgDissect.Visible and GetCursorPos(pt) then
    begin
      pt := pnlCoding.ScreenToClient(pt);
      if (pt.X > tgDissect.Left) and (pt.X <= (tgDissect.Left + tgDissect.Width)) and
         (pt.Y > tgDissect.Top) and (pt.Y <= (tgDissect.Top + tgDissect.Height)) then
          ShowHintForCell(tgDissect.CurrentDataRow,tgDissect.CurrentDataCol);
    end;
  except
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmDissection.NumberIsValid( aControl : TCustomEdit; const LeftDigits, RightDigits: integer): boolean;
//make sure the user can't key in incorrect number of digits
var
  StrippedNumber : string;
  CurrLeftDigits : integer;
  CurrRightDigits: integer;
  dpPos          : integer;
  RawLength      : integer;
  StrippedLength : integer;
  CurrPos        : integer;
begin
  Result := true;

  RawLength := Length( aControl.Text);
  if ( RawLength = 0) or ( aControl.SelLength = RawLength) then
    exit;

  StrippedNumber := RemoveCharsFromString( aControl.Text, ['(',')','-', ',']);
  StrippedLength := Length( StrippedNumber);

  DpPos := Pos( '.', StrippedNumber);
  if DpPos = 0 then
  begin
    CurrLeftDigits  := StrippedLength;
    CurrRightDigits := 0;
  end
  else
  begin
    CurrLeftDigits  := DpPos - 1;
    CurrRightDigits := StrippedLength - DpPos;
  end;

  //whether we accept another key depends on where the cursor is sitting
  CurrPos := aControl.SelStart;
  if ( DpPos = 0) or (CurrPos < DpPos) then
  begin
    //we are to the left of the dp
    result := ( CurrLeftDigits < LeftDigits);
  end
  else
  begin
    //we are to the right of the dp
    result := ( CurrRightDigits < RightDigits);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmDissection.rzQuantityKeyPress(Sender: TObject;
  var Key: Char);
begin
  if ( Key >= '0') and ( Key <= '9') then
  begin
    if not NumberIsValid( rzQuantity, 8, 4) then
    begin
      Key := #0;
      exit;
    end;
  end;
end;

procedure TfrmDissection.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  HideCustomHint;
end;

procedure TfrmDissection.FormShow(Sender: TObject);
begin
  RemovingMask := False;
end;

procedure TfrmDissection.tgDissectMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  //don't scroll the main grid if a comobo box is showing
  if (AccountComboDown) or (PayeeComboDown) or (JobComboDown) then
    Handled := True;

  HideCustomHint;
end;

procedure TfrmDissection.tgDissectKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  KeyIsDown := false;
  if KeyIsCopy then
  begin
    KeyIsCopy := False;
    tgDissect.EndEdit(True);
    Copycontentsofthecellabove1Click(Sender);
  end;
end;

procedure TfrmDissection.tgDissectMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDissection.tmrHideHintTimer(Sender: TObject);
begin
  HideCustomHint;
end;

procedure TfrmDissection.tgAccountLookupKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  sValue : String;
  MaskChar : Char;
begin
  if (Key = VK_BACK) then
  begin
    sValue := tgAccountLookup.CurrentCell.Value;
    sValue := Copy(sValue, 1, Length(sValue) - 1);
    if MyClientFile.ecChart.AddMaskCharToCode(sValue,
       MyClientFile.ecFields.ecAccount_Code_Mask, MaskChar) Then
    begin
      RemovingMask := True;
      try
        tgAccountLookup.CurrentCell.Value := sValue;
        //move cursor to the last character
        tgAccountLookup.CurrentCell.SelStart := Length(sValue);
      finally
        RemovingMask := False;
      end;
    end;
  end;
end;

end.
