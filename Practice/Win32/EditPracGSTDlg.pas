unit EditPracGSTDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:      Edit Practice Default GST Configuration

  Written:
  Authors:    Matthew

  Purpose:    Allows the user to setup default GST rates and type that will be
              loaded into a new client when it is created.

  Notes:
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcBase, StdCtrls, OvcTCBEF, OvcTCNum, OvcTCCBx, OvcTCEdt, OvcTCmmn,
  OvcTCell, OvcTCStr, OvcTCHdr, OvcTable, OvcEF, OvcPB, OvcPF, ImgList,
  ComCtrls, OvcTCPic, Buttons,
  OsFont, ExtCtrls, VatTemplates;

type
  TdlgEditPracGST = class(TForm)
    PcTax: TPageControl;
    tsGST: TTabSheet;
    Label1: TLabel;
    gbxRates: TGroupBox;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    tblRates: TOvcTable;
    eDate1: TOvcPictureField;
    eDate2: TOvcPictureField;
    eDate3: TOvcPictureField;
    OvcController1: TOvcController;
    colDesc: TOvcTCString;
    colRate1: TOvcTCNumericField;
    colRate2: TOvcTCNumericField;
    colRate3: TOvcTCNumericField;
    colAccount: TOvcTCString;
    OvcTCColHead1: TOvcTCColHead;
    ColID: TOvcTCString;
    celGSTType: TOvcTCComboBox;
    pnlBtn: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    tsOther: TTabSheet;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lh10: TLabel;
    Bevel7: TBevel;
    Label11: TLabel;
    Label13: TLabel;
    eDateT3: TOvcPictureField;
    eDateT2: TOvcPictureField;
    eDateT1: TOvcPictureField;
    eRate3: TOvcPictureField;
    ERate2: TOvcPictureField;
    eRate1: TOvcPictureField;
    Label6: TLabel;
    btnLoadTemplate: TButton;
    btnSaveTemplate: TButton;

    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure tblRatesGetCellData(Sender: TObject; RowNum, ColNum: Integer;
      var Data: Pointer; Purpose: TOvcCellDataPurpose);
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
    procedure tblRatesEnter(Sender: TObject);
    procedure celGSTTypeDropDown(Sender: TObject);
    procedure tblRatesGetCellAttributes(Sender: TObject; RowNum,
      ColNum: Integer; var CellAttr: TOvcCellAttributes);
    procedure tblRatesDoneEdit(Sender: TObject; RowNum, ColNum: Integer);
    procedure colAccountKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure eDateT1DblClick(Sender: TObject);
    procedure btnLoadTemplateClick(Sender: TObject);
    procedure btnSaveTemplateClick(Sender: TObject);
  private
    okPressed : boolean;
    editMode  : boolean;
    StdLineLightColor  : integer;
    StdLineDarkColor   : integer;
    tmpShortStr        : ShortString;
    tmpPaintShortStr   : ShortString;
    FTaxName: String;
    FCountry: Byte;
    function OKtoPost : boolean;
    procedure DoDeleteCell;
    procedure SetTaxName(const Value: String);
    procedure SetCountry(const Value: Byte);
    procedure SetupVatTemplates;
    procedure ClearRates;
    property TaxName : String read FTaxName write SetTaxName;
    property Country : Byte read FCountry write SetCountry;
  public
    { Public declarations }
    function Execute : boolean;
  end;

function EditPracticeGSTDetails : boolean;

//******************************************************************************
implementation

uses
  WinUtils,
  bkconst,
  BKHelp,
  bkBranding,
  bkXPThemes,
  CanvasUtils,
  Genutils,
  globals,
  ovcConst,
  ovcDate,
  ovcNf,
  stDateSt,
  AccountLookupFrm,
  updateMf,
  imagesfrm,
  admin32,
  LogUtil,
  ErrorMoreFrm,
  WarningMoreFrm,
  bkDateUtils,
  stStrs,
  ComboUtils,
  StringListHelper,
  glConst,
  AuditMgr;


{$I BKHelp.inc}
{$R *.DFM}

const
  UnitName = 'EDITPRACGSTDLG';

var
  DebugMe : boolean = false;

type
   TGSTInfoRec = record
      GST_ID               : string[GST_CLASS_CODE_LENGTH];
      GST_Class_Name       : String[60];
      GST_Rates            : Array[ 1..MAX_VISIBLE_GST_CLASS_RATES ] of double;
      GST_Account_Code     : Bk5CodeStr;
      GSTClassTypeCmbIndex : integer;
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
  AccountCol              = 6;  LastCol  = 6;

var
   GST_Table : Array[1..MAX_GST_CLASS] of TGSTInfoRec;
//------------------------------------------------------------------------------
procedure TdlgEditPracGST.btnOkClick(Sender: TObject);
begin
  IF oktoPost then
  begin
    okpressed := true;
    close;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgEditPracGST.btnCancelClick(Sender: TObject);
begin
   close;
end;
//------------------------------------------------------------------------------
procedure TdlgEditPracGST.FormCreate(Sender: TObject);
var
   i : integer;
begin
  bkXPThemes.ThemeForm( Self);

  okPressed := false;
  EditMode := false;

  lh10.Font.Name := Font.name;


  //set colors for alternate lines
  StdLineLightColor := clWindow;
  StdLineDarkColor  := bkBranding.GSTAlternateLineColor;

  tblRates.RowLimit   := MAX_GST_CLASS +1;

  Country := AdminSystem.fdFields.fdCountry;

  //Load GST Types combo - different for NZ and AU
  with celGSTType do begin
     Items.Clear;
     case Country of
        whNewZealand : For i := gtMin to gtMax do if ( i <> gtUndefined ) then Items.AddID( gtNames[i], i );
        whUK         : For i := vtMin to vtMax do Items.AddID( vtNames[i] , i );
     end;
  end;

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

  eDate1.Epoch        := BKDATEEPOCH;
  eDate1.PictureMask  := BKDATEFORMAT;
  eDate2.Epoch        := BKDATEEPOCH;
  eDate2.PictureMask  := BKDATEFORMAT;
  eDate3.Epoch        := BKDATEEPOCH;
  eDate3.PictureMask  := BKDATEFORMAT;

  eDateT1.Epoch       := BKDATEEPOCH;
  eDateT1.PictureMask := BKDATEFORMAT;
  eDateT2.Epoch       := BKDATEEPOCH;
  eDateT2.PictureMask := BKDATEFORMAT;
  eDateT3.Epoch       := BKDATEEPOCH;
  eDateT3.PictureMask := BKDATEFORMAT;

  SetUpHelp;

  //set max lenght of gst id
  ColId.MaxLength := GST_CLASS_CODE_LENGTH;
  ColAccount.MaxLength := MaxBk5CodeLen;
  //resize the account col so that longest account code fits
  tblRates.Columns[ AccountCol ].Width := CalcAcctColWidth( tblRates.Canvas, tblRates.Font, 100);

  SetupVatTemplates;
end;
//------------------------------------------------------------------------------
procedure TdlgEditPracGST.DoDeleteCell;
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

procedure TdlgEditPracGST.eDateT1DblClick(Sender: TObject);
var ld: Integer;
begin
   if sender is TOVcPictureField then begin
      ld := TOVcPictureField(Sender).AsStDate;
      PopUpCalendar(TEdit(Sender),ld);
      TOVcPictureField(Sender).AsStDate := ld;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditPracGST.SetCountry(const Value: Byte);
begin
  FCountry := Value;
  TaxName := BKCONST.whTaxSystemNamesUC[ Country ];
end;

procedure TdlgEditPracGST.SetTaxName(const Value: String);
begin
  FTaxName := Value;
  if Country <> whAustralia then // Fix for bug 21586
    Caption := 'Practice ' + TaxName + ' Defaults';
  OvcTCColHead1.Headings[ TypeCol ] := TaxName + ' Type';
  tsGST.Caption := TaxName + ' Rates';
end;

procedure TdlgEditPracGST.SetUpHelp;
var
 S: string;
begin
  Self.ShowHint    := INI_ShowFormHints;
  Self.HelpContext := 0;
  S := 'Enter the date when this ' + TaxName + ' rate becomes effective|' +
       'Enter the date when this ' + TaxName + ' rate becomes effective';
  eDate1.Hint      := S;
  eDate2.Hint      := S;
  eDate3.Hint      := S;

  eDateT1.Hint     := S;
  eDateT2.Hint     := S;
  eDateT3.Hint     := S;

  S := 'Enter the  ' + TaxName + ' rate|' +
       'Enter the  ' + TaxName + ' rate';

  eRate1.Hint      := S;
  eRate2.Hint      := S;
  eRate3.Hint      := S;
end;
//------------------------------------------------------------------------------
function TdlgEditPracGST.Execute: boolean;
const
   ThisMethodName = 'TDlgEditPracGST.Execute';

var
   ClassNo,
   RateNo   : integer;
begin
   result := false;
   editmode := false;
   if not RefreshAdmin then exit;

   {assign current settings}
   with AdminSystem.fdFields do begin
     {load dates}
     eDate1.AsStDate := BkNull2St(fdGST_Applies_From[1]);
     eDate2.AsStDate := BkNull2St(fdGST_Applies_From[2]);
     eDate3.AsStDate := BkNull2St(fdGST_Applies_From[3]);

     {load table}
     FillChar(GST_Table,Sizeof(GST_Table),#0);

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

        GSTClassTypeCmbIndex := celGSTType.Items.IndexOfID( fdGST_Class_Types[ ClassNo] );
     end;

     // Tax Rates;
     if fdCountry = whAustralia then begin
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
       tsGST.TabVisible := False;
    end else begin
       tsOther.TabVisible := False;
    end;
   end;

   ///////////////////////////////
   Self.ShowModal;
   ///////////////////////////////

   if okPressed then begin
      {save new values}

      if DebugMe then
         LogUtil.LogMsg(lmDebug,'EDITPRACGSTDLG','Update Practice GST Details Starts');

      if LoadAdminSystem(true, ThisMethodName ) then with AdminSystem.fdFields do begin
         {save dates}
         fdGST_Applies_From[1] := StNull2Bk(eDate1.AsStDate);
         fdGST_Applies_From[2] := StNull2Bk(eDate2.AsStDate);
         fdGST_Applies_From[3] := StNull2Bk(eDate3.AsStDate);

         {table}
         for ClassNo := 1 to MAX_GST_CLASS do With GST_Table[ClassNo] do begin
            fdGST_Class_Codes[ ClassNo] := GST_ID;
            fdGST_Class_Names[ ClassNo] := GST_Class_Name;
            For RateNo := 1 to MAX_VISIBLE_GST_CLASS_RATES do
               fdGST_Rates[ ClassNo, RateNo ] := Double2GSTRate(GST_Rates[ RateNo ]);
            fdGST_Account_Codes  [ ClassNo ] := GST_Account_Code;
            //set the type value, default to undefined
            case fdCountry of
               whNewZealand : fdGST_Class_Types[ClassNo] := gtUndefined;
                //whAustralia  : fdGST_Class_Types[ClassNo] := gaUndefined;
            end;
            //convert from cmb index back to type.  Use the object value, this is where
            //the real type was stored
            if GSTClassTypeCmbIndex <> -1 then
               fdGST_Class_Types[ClassNo] := Integer( celGSTType.Items.Objects[ GSTClassTypeCmbIndex]);
         end;

         if fdCountry = whAustralia then begin
            fdTAX_Applies_From[tt_CompanyTax][1] := StNull2Bk(eDateT1.AsStDate);
            fdTAX_Applies_From[tt_CompanyTax][2] := StNull2Bk(eDateT2.AsStDate);
            fdTAX_Applies_From[tt_CompanyTax][3] := StNull2Bk(eDateT3.AsStDate);
            fdTAX_Rates[tt_CompanyTax][1] := Double2GSTRate(eRate1.AsFloat);
            fdTAX_Rates[tt_CompanyTax][2] := Double2GSTRate(eRate2.AsFloat);
            fdTAX_Rates[tt_CompanyTax][3] := Double2GSTRate(eRate3.AsFloat);
         end;

         //*** Flag Audit ***
         SystemAuditMgr.FlagAudit(arPracticeGSTDefaults);

         SaveAdminSystem;

         if DebugMe then
            LogUtil.LogMsg(lmDebug,'EDITPRACGSTDLG','Update Practice GST Details Complete.');

      end else
        HelpfulErrorMsg('Could not update Practice Default GST Details at this time. Admin System unavailable.',0);

   end; // Ok Pressed
   Result := okPressed;
end;
//------------------------------------------------------------------------------
procedure TdlgEditPracGST.tblRatesGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
begin
  data := nil;

  if (RowNum > 0) and (RowNum <= MAX_GST_CLASS +1) then
  Case ColNum of
    IDCol: begin //trim id for save
       case Purpose of
          cdpForPaint: begin
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
    Rate1Col, Rate2Col, Rate3Col:
       data := @GST_Table[RowNum].GST_Rates[ColNum-( Rate1Col-1)];
    AccountCol:
       data := @GST_Table[RowNum].GST_Account_Code;
    TypeCol:
       data := @GST_Table[RowNum].GSTClassTypeCmbIndex;
  end;
end;
//------------------------------------------------------------------------------
function EditPracticeGSTDetails : boolean;
var
  MyDlg : TdlgEditPracGST;
begin
  MyDlg := TdlgEditPracGst.Create(Application.MainForm);
  try
    BKHelpSetUp(MyDlg, BKH_Setting_Practice_GST_Defaults);
    result := MyDlg.Execute;
  finally
    MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgEditPracGST.tblRatesUserCommand(Sender: TObject; Command: Word);
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
//------------------------------------------------------------------------------
procedure TdlgEditPracGST.tblRatesExit(Sender: TObject);
var
  Msg :TWMKey;
begin
   if EditMode then
   begin
      Msg.CharCode := vk_f6;
      ColAccount.SendKeyToTable(Msg);
   end;

   btnOk.Default := true;
   btnCancel.Cancel := true;
end;
//------------------------------------------------------------------------------
procedure TdlgEditPracGST.tblRatesBeginEdit(Sender: TObject; RowNum,
  ColNum: Integer; var AllowIt: Boolean);
begin
   EditMode := true;
end;
//------------------------------------------------------------------------------
procedure TdlgEditPracGST.tblRatesEndEdit(Sender: TObject;
  Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
  var AllowIt: Boolean);
begin
   EditMode := false;
end;
//------------------------------------------------------------------------------
procedure TdlgEditPracGST.tblRatesActiveCellMoving(Sender: TObject;
  Command: Word; var RowNum, ColNum: Integer);
begin
   if (Command = ccRight) and ( tblRates.ActiveCol = LastCol) then
      if RowNum < tblRates.RowLimit then begin
        Inc(RowNum);
        ColNum := FirstCol;
      end;
end;
//------------------------------------------------------------------------------
procedure TdlgEditPracGST.tblRatesActiveCellChanged(Sender: TObject; RowNum,
  ColNum: Integer);
var
   HintText : string;
begin
  case ColNum of
  IDCol:
     HintText   := 'Enter a short ID for this class (up to '+inttostR(GST_CLASS_CODE_LENGTH)+' chars)';
  DescCol:
     HintText   := 'Enter a description for this class, eg. Exempt, ' + TaxName + ' Income';
  Rate1Col, Rate2Col, Rate3Col:
     HintText   := 'Enter the ' + TaxName + ' rate for this class.';
  AccountCol:
     HintText   := 'Enter the Account Code to which this class should be posted.';
  end;

  tblRates.Hint := HintText;
  MsgBar(HintText,false);
end;
//------------------------------------------------------------------------------
procedure TdlgEditPracGST.tblRatesEnter(Sender: TObject);
begin
   btnOk.Default    := false;
   btnCancel.Cancel := false;;
end;
//------------------------------------------------------------------------------
function TdlgEditPracGST.OKtoPost: boolean;
var
  i,j : integer;
  D : Array[ 1..3 ] of Integer;
  R : Array[ 1..3 ] of Double;

//  D1, D2: Integer;

  procedure FocusMessage(Control: TWinControl; Page: tTabSheet; Msg: String);
  begin
     PcTax.ActivePage := Page;
     Control.SetFocus;
     HelpfulWarningMsg( Msg, 0);
  end;

  function FailRate(Edit: TOvcPictureField): Boolean;
  var lr: Double;
  begin
     Result := True;
     lr := Edit.AsFloat;
     if lR <= 0 then begin
        FocusMessage(Edit,tsOther,'Please enter a tax rate greater than zero.');
        Exit;
     end;
     if lR >= 100 then begin
        FocusMessage(Edit,tsOther,'Please enter a tax rate less than 100%.');
        Exit;
     end;
     Result := False;
  end;

begin
  result := false;
  //check that there are no duplicates GST Rates IDs
  for i := 1 to MAX_GST_CLASS do begin
     GST_Table[i].GST_ID := Trim( GST_Table[i].GST_ID);
     if GST_Table[ i].GST_ID <> '' then begin
        for j := (i+1) to MAX_GST_CLASS do
          if ( UpperCase( GST_Table[i].GST_ID) = UpperCase( GST_Table[j].GST_ID)) then begin
            //duplicate found
            HelpfulWarningMsg( TaxName +  ' ID "'+Gst_Table[i].GST_ID+'" has been used for more than one ' + TaxName + ' class.  Each ID MUST be unique.',0);
            exit;
          end;
     end;
  end;

  if Country = whAustralia then
  Begin
    D[1] := StNull2Bk(eDateT1.AsStDate);  R[1] := eRate1.AsFloat;
    D[2] := StNull2Bk(eDateT2.AsStDate);  R[2] := eRate2.AsFloat;
    D[3] := StNull2Bk(eDateT3.AsStDate);  R[3] := eRate3.AsFloat;

    if ( D[1] > 0 ) and FailRate( eRate1 ) then Exit;
    if ( D[2] > 0 ) and FailRate( eRate2 ) then exit;
    if ( D[3] > 0 ) and FailRate( eRate3 ) then exit;

    if ( D[1] = 0 ) and ( ( D[2] > 0 ) or ( D[3] > 0 ) ) then
    Begin
      FocusMessage(eDateT1,tsOther,'Please use Rate 1 first.');
      Exit;
    end;

    if ( D[2] > 0 ) and  ( D[2] < D[1] ) then
    Begin
      FocusMessage(eDateT2,tsOther,'Please enter a date later than Rate 1.');
      Exit;
    End;

    if ( D[3] > 0 ) and  ( D[3] < D[2] ) then
    Begin
      FocusMessage(eDateT3,tsOther,'Please enter a date later than Rate 2.');
      Exit;
    End;

    if ( R[1] <> 0 ) and ( D[1]= 0 )  then
    Begin
      FocusMessage(eDateT1,tsOther,'Please enter a valid date.');
      Exit;
    End;

    if ( R[2] <> 0 ) and ( D[2]= 0 )  then
    Begin
      FocusMessage(eDateT2,tsOther,'Please enter a valid date.');
      Exit;
    End;

    if ( R[3] <> 0 ) and ( D[3]= 0 )  then
    Begin
      FocusMessage(eDateT3,tsOther,'Please enter a valid date.');
      Exit;
    End;
  end;
  result := true;
end;
//------------------------------------------------------------------------------
procedure TdlgEditPracGST.celGSTTypeDropDown(Sender: TObject);
begin
   //try to set default drop down width
   SendMessage(celGSTType.EditHandle, CB_SETDROPPEDWIDTH, 300, 0);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditPracGST.tblRatesGetCellAttributes(Sender: TObject;
  RowNum, ColNum: Integer; var CellAttr: TOvcCellAttributes);
begin
   if (CellAttr.caColor = tblRates.Color) and (RowNum >= tblRates.LockedRows) then begin
      if Odd(RowNum) then
         CellAttr.caColor := StdLineLightColor
      else
         CellAttr.caColor := StdLineDarkColor;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditPracGST.tblRatesDoneEdit(Sender: TObject; RowNum,
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
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditPracGST.colAccountKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  msg : TWMKey;
begin
   //check for lookup key
   if ( Key = VK_F2 ) then begin
      Msg.CharCode := VK_F2;
      colAccount.SendKeyToTable(Msg);
   end;
end;

{-------------------------------------------------------------------------------
  VAT Templates
-------------------------------------------------------------------------------}
procedure TdlgEditPracGST.SetupVatTemplates;
var
  ExtraHeight: integer;
begin
  // Extend grid if buttons are not visible?
  if not VatSetupButtons(vlPractice, [btnLoadTemplate, btnSaveTemplate]) then
  begin
    // Move grid and groupbox down
    ExtraHeight := (btnLoadTemplate.BoundsRect.Bottom) - (gbxRates.BoundsRect.Bottom);
    gbxRates.Height := gbxRates.Height + ExtraHeight;
    tblRates.Height := tblRates.Height + ExtraHeight;
  end;
end;

{------------------------------------------------------------------------------}
procedure TdlgEditPracGST.ClearRates;
begin
  eRate1.ClearContents;
  eRate2.ClearContents;
  eRate3.ClearContents;

  ZeroMemory(@GST_Table, SizeOf(GST_Table));
  tblRates.Refresh;
end;

{------------------------------------------------------------------------------}
procedure TdlgEditPracGST.btnLoadTemplateClick(Sender: TObject);
var
  FileName: string;
  VatRates: TVatRates;
  Rate1: integer;
  Rate2: integer;
  Rate3: integer;
  i: integer;
  Src: ^TVatRatesRow;
  Dst: ^TGSTInfoRec;
  iRate: integer;
begin
  try
    // User cancel?
    if not VatOpenDialog(self, FileName) then
      exit;

    ClearRates;

    VatLoadFromFile(Filename, Rate1, Rate2, Rate3, VatRates);

    // Copy effective rates
    eDate1.AsStDate := Rate1;
    eDate2.AsStDate := Rate2;
    eDate3.AsStDate := Rate3;

    // Copy rates
    for i := 1 to MAX_GST_CLASS do
    begin
      Src := @VatRates[i];
      Dst := @GST_Table[i];

      Dst.GST_ID := Src.GST_ID;
      Dst.GST_Class_Name := Src.GST_Class_Name;

      for iRate := 1 to MAX_VISIBLE_GST_CLASS_RATES do
      begin
        Dst.GST_Rates[iRate] := Src.GST_Rates[iRate];
      end;

      Dst.GST_Account_Code := Src.GST_Account_Code;

      // Convert the VAT Type ID to the combo box index
      if (Src.GSTClassType <> -1) then
      begin
        Dst.GSTClassTypeCmbIndex := celGSTType.Items.IndexOfID(Src.GSTClassType);
        if (Dst.GSTClassTypeCmbIndex = -1) then
          raise Exception.CreateFmt('%s type on row %d not recognized', [TaxName, i]);
      end;

      // BusinessNormPercent is not used at the practice level
    end;

    // Refresh the display
    tblRates.Refresh;
  except
    on E: Exception do
    begin
      ClearRates;
      VatShowLoadException(E);
    end;
  end;
end;

{------------------------------------------------------------------------------}
procedure TdlgEditPracGST.btnSaveTemplateClick(Sender: TObject);
var
  FileName: string;
  VatRates: TVatRates;
  Src: ^TGSTInfoRec;
  Dst: ^TVatRatesRow;
  i: integer;
  iRate: integer;
begin
  try
    // User cancel?
    if not VatSaveDialog(self, FileName) then
      exit;

    // Copy rates
    for i := 1 to MAX_GST_CLASS do
    begin
      Src := @GST_Table[i];
      Dst := @VatRates[i];

      Dst.GST_ID := Src.GST_ID;
      Dst.GST_Class_Name := Src.GST_Class_Name;

      for iRate := 1 to MAX_VISIBLE_GST_CLASS_RATES do
      begin
        Dst.GST_Rates[iRate] := Src.GST_Rates[iRate];
      end;

      Dst.GST_Account_Code := Src.GST_Account_Code;

      // Copy the VAT Type ID (not the index itself)
      if (Src.GSTClassTypeCmbIndex = -1) then
        Dst.GSTClassType := -1 // Save "as is" with no valid selection
      else
        Dst.GSTClassType := Integer(celGSTType.Items.Objects[Src.GSTClassTypeCmbIndex]);

      Dst.GST_BusinessNormPercent := 0; // This is not used at the practice level
    end;

    VatSaveToFile(eDate1.AsStDate, eDate2.AsStDate, eDate3.AsStDate, VatRates,
      FileName);
  except
    on E: Exception do
    begin
      VatShowSaveException(E);
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   debugMe := DebugUnit(UnitName);
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
end.
