unit CodeDateChequeDlg;
//------------------------------------------------------------------------------
{
   Title:        Missing Cheques criteria dialog

   Description:  Allows you to select account, dates and cheque ranges

   Author:       Michael Foot, Matthew Hopkins

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  rptParams,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons, ovcDate, ExtCtrls,
  OvcABtn, OvcPF, OvcBase, OvcEF, OvcPB, OvcSC, Menus, 
  DateSelectorFme, ovctchdr, ovctcbef, ovctcnum, ovctcmmn, ovctcell,
  ovctcstr, ovctable,  baObj32,
  OSFont;

type
  TAccountSet = set of byte;

  pChqArray = ^tChqArray;
  tChqArray = Array[1..5] of record
                SN1,SN2 : integer;
              end;
type
  TdlgCodeDateCheque = class(TForm)
    pnlButtons: TPanel;
    btnPreview: TButton;
    btnFile: TButton;
    btnOK: TButton;
    btClose: TButton;
    OvcController1: TOvcController;
    OvcTCColHead1: TOvcTCColHead;
    ColFrom: TOvcTCNumericField;
    Col2: TOvcTCNumericField;
    OvcTCRowHead1: TOvcTCRowHead;
    pnldates: TPanel;
    eDateSelector: TfmeDateSelector;
    pnlaccount: TPanel;
    cmbAccountList: TComboBox;
    lblSelectAccounts: TLabel;
    pnlrange: TPanel;
    Label2: TLabel;
    tblFromTo: TOvcTable;
    Label1: TLabel;
    lblRange: TLabel;
    btnSave: TBitBtn;
    Button1: TButton;
    btnEmail: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure SetUpHelp;
    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure tblFromToGetCellData(Sender: TObject; RowNum,
      ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure tblFromToEnter(Sender: TObject);
    procedure tblFromToExit(Sender: TObject);
    procedure tblFromToActiveCellMoving(Sender: TObject; Command: Word;
      var RowNum, ColNum: Integer);
    procedure tblFromToKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnSaveClick(Sender: TObject);
    procedure UpdateRange;
    procedure cmbAccountListChange(Sender: TObject);
    procedure eDateSelectoreDateFromChange(Sender: TObject);
    procedure eDateSelectoreDateToChange(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
  private
    { Private declarations }
    FDateFrom,
    FDateTo   : TSTDate;
    FAllowBlank: boolean;
    FPressed: integer;
    FTransactionsFrom, FTransactionsTo : TstDate;
    FValidAccountTypes: TAccountSet;
    FData : pChqArray;
    FParams: TRptParameters;

    procedure SetAllowBlank(const Value: boolean);
    function  CheckClose(DoDates : Boolean = true) : boolean;
    procedure SetPressed(const Value: integer);
    procedure SetValidAccountTypes(const Value: TAccountSet);
    procedure SetParams(const Value: TRptParameters);

  public
    { Public declarations }
    property dlgDateFrom : TStDate read FDateFrom;
    property dlgDateTo   : TStDate read FDateTo;
    property AllowBlank  : boolean read FAllowBlank write SetAllowBlank;
    property ValidAccountTypes : TAccountSet read FValidAccountTypes write SetValidAccountTypes;
    property Pressed : integer read FPressed write SetPressed;
    property Params: TRptParameters read FParams write SetParams;
    function Execute : boolean;
  end;

function EnterPrintDateAccountChequeRange( Caption : string;
                                     Text :string;
                                     ValidAccounts : TAccountSet;
                                     var DateFrom,DateTo : TstDate;
                                     var BankAccount : TBank_Account;
                                     HelpCtx: integer;
                                     Blank : Boolean;
                                     ChequeRange : Pointer;
                                     RptParams: TRptParameters;
                                     var IncludeUPCs : boolean) : boolean;

//******************************************************************************
implementation

uses
  BKConst,
  bkDateUtils,
  BKHelp,
  bkXPThemes,
  ClDateUtils,
  globals,
  imagesfrm,
  InfoMoreFrm,
  selectDate,
  stdaTest,
  StdHints,
  ovcconst,
  Math,
  WarningMoreFrm,
  bkdefs,
  yesnodlg, trxList32;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TdlgCodeDateCheque.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  FTransactionsFrom := BAllData( MyClient );
  FTransactionsTo   := EAllData( MyClient );
  eDateSelector.ClientObj := MyClient;
  eDateSelector.InitDateSelect(FTransactionsFrom, FTransactionsTo, tblFromTo);
  FValidAccountTypes := [];

  AllowBlank            := false;

  tblFromTo.RowLimit := High(tChqArray) - Low(tChqArray) + 2;  {+1, +1 for header}
  tblFromTo.CommandOnEnter := ccright;

  SetUpHelp;

  ColFrom.PictureMask := ChequeNoMask;
  Col2.PictureMask    := ChequeNoMask;

  //favorite reports functionality is disabled in simpleUI
  if Active_UI_Style = UIS_Simple then
     btnSave.Hide;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCodeDateCheque.SetUpHelp;
begin
   Self.ShowHint     := INI_ShowFormHints;
   Self.HelpContext  := 0;
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDateCheque.FormShow(Sender: TObject);
begin
   gCodingDateFrom := MyClient.clFields.clPeriod_Start_Date;
   gCodingDateTo   := Myclient.clFields.clPeriod_End_Date;
   FDateFrom := gCodingDateFrom;
   FDateTo   := gCodingDateTo;
   eDateSelector.eDateFrom.asStDate := BkNull2St(gCodingDateFrom);
   eDateSelector.eDateTo.asStDate   := BkNull2St(gCodingDateTo);
   UpdateRange;
end;
//------------------------------------------------------------------------------
{dialog routines}
procedure TdlgCodeDateCheque.btnOKClick(Sender: TObject);
begin
   if CheckClose then
   begin
     Pressed := BTN_PRINT;
     Close;
   end
   else
     Pressed := BTN_NONE;
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDateCheque.btCloseClick(Sender: TObject);
begin
   Pressed := BTN_NONE;
   close;
end;
//------------------------------------------------------------------------------

procedure TdlgCodeDateCheque.SetAllowBlank(const Value: boolean);
begin
  FAllowBlank := Value;
end;

//------------------------------------------------------------------------------
procedure TdlgCodeDateCheque.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  case Msg.CharCode of
    109: begin
           eDateSelector.btnPrev.Click;
           Handled := true;
         end;
    107: begin
           eDateSelector.btnNext.click;
           Handled := true;
         end;
    VK_MULTIPLY : begin
           eDateSelector.btnQuik.click;
           handled := true;
         end;
  end;
end;
//------------------------------------------------------------------------------
function TdlgCodeDateCheque.CheckClose(DoDates : Boolean = true): boolean;
var I : Integer;


  function Checkdates : Boolean;
  var D1, D2 : integer;
      I : integer;
  begin
     Result := false;
     if (not eDateSelector.ValidateDates) then
        Exit;

     D1 := stNull2Bk(eDateSelector.eDateFrom.AsStDate);
     D2 := stNull2Bk(eDateSelector.eDateTo.AsStDate);

     if  (((D1=0) and AllowBlank) or DateIsValid(eDateSelector.eDateFrom.AsString))
     and (((D2=MaxInt) and AllowBlank) or DateisValid(eDateSelector.eDateTo.AsString)) then begin
        {validate from after to, first day of mth, last day of mth}
        if D1 > D2 then begin
           HelpfulWarningMsg('"From" Date is later than "To" Date.  Please select valid dates.',0);
           eDateSelector.eDateTo.SetFocus;
           Exit;
        end;
     end else begin
         eDateSelector.eDateFrom.SetFocus;
         Exit;
     end;

     with TBank_Account(cmbAccountList.Items.Objects[cmbAccountList.ItemIndex]) do
        for i := baTransaction_List.First to baTransaction_List.Last do
        with baTransaction_List.Transaction_At(i)^ do
        if ( CompareDates( txDate_Effective, D1, D2 )=Within )
        and ( txCheque_Number <> 0) then begin
           Result := True;
           Break;
        end;

     if not Result then begin
        HelpfulWarningMsg( 'There are no cheques in the selected date range.', 0);
        eDateSelector.eDateFrom.SetFocus;
        Exit;
     end;

     FDateFrom := D1;
     FDateTo := D2;
  end;

begin
  Result := false;

  if Dodates then
    if not CheckDates then
      Exit;

  if (cmbAccountList.ItemIndex < 0) then
     exit;

  for i := Low(tChqArray) to High(tChqArray) do with FData^[i] do
     if sn2 < sn1 then begin
        HelpfulWarningMsg( Format( '%d to %d is not a valid range.', [ sn1, sn2 ] ), 0 );
        tblFromTo.SetFocus;
        exit;
     end;
  Result := True;
end;


procedure TdlgCodeDateCheque.cmbAccountListChange(Sender: TObject);
begin
   UpdateRange;
end;

procedure TdlgCodeDateCheque.eDateSelectoreDateFromChange(Sender: TObject);
begin
  eDateSelector.eDateFromChange(Sender);
  UpdateRange;
end;

procedure TdlgCodeDateCheque.eDateSelectoreDateToChange(Sender: TObject);
begin
  eDateSelector.eDateFromChange(Sender);
  UpdateRange;
end;

//------------------------------------------------------------------------------
procedure TdlgCodeDateCheque.SetParams(const Value: TRptParameters);
begin
  FParams := Value;
  if assigned(FParams) then begin
     FParams.SetDlgButtons(btnPreview, btnFile, btnEmail, btnSave, btnOk);
     if assigned(FParams.RptBatch) then
        Caption := Caption + ' [' + FParams.RptBatch.Name + ']';
  end else
     BtnSave.Hide
end;

procedure TdlgCodeDateCheque.SetPressed(const Value: integer);
begin
  FPressed := Value;
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDateCheque.btnPreviewClick(Sender: TObject);
begin
   if CheckClose then
   begin
     Pressed := BTN_PREVIEW;
     Close;
   end
   else
     Pressed := BTN_NONE;
end;
procedure TdlgCodeDateCheque.btnSaveClick(Sender: TObject);
begin
   if CheckClose(False) then
   begin
     if not FParams.CheckForBatch then
         Exit;
     Pressed := BTN_SAVE;
     Close;
   end
   else
     Pressed := BTN_NONE;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCodeDateCheque.btnEmailClick(Sender: TObject);
begin
   if CheckClose then begin
     Pressed := BTN_EMAIL;
     Close;
   end
   else
     Pressed := BTN_NONE;
end;

procedure TdlgCodeDateCheque.btnFileClick(Sender: TObject);
begin
   if CheckClose then begin
     Pressed := BTN_FILE;
     Close;
   end
   else
     Pressed := BTN_NONE;
end;
//------------------------------------------------------------------------------
function TdlgCodeDateCheque.Execute: boolean;
begin
   Pressed  := BTN_NONE;
   Self.ShowModal;
   result := ( Pressed <> BTN_NONE);
end;    //
//------------------------------------------------------------------------------
function EnterPrintDateAccountChequeRange(Caption : string;
                                    Text :string;
                                    ValidAccounts : TAccountSet;
                                    var DateFrom,DateTo : TstDate;
                                    var BankAccount : TBank_Account;
                                    HelpCtx: integer;
                                    Blank : Boolean;
                                    ChequeRange : Pointer;
                                    RptParams: TRptParameters;
                                    var IncludeUPCs : boolean): boolean;
var
  MyCodeDate : TdlgCodeDateCheque;
  i : Integer;
  BA : TBank_Account;

begin
  result := false;
  RptParams.RunBtn := BTN_NONE;

  MyCodeDate := TdlgCodeDateCheque.Create(Application.MainForm);
  try
    with MyCodeDate do begin
      BKHelpSetUp(MyCodeDate, HelpCtx);
      AllowBlank         := Blank;
      Caption   := caption;
      ValidAccountTypes := ValidAccounts;

      FData := pChqArray(ChequeRange);

      //fill the accounts list
      cmbAccountList.Clear;
      with MyClient.clBank_Account_List do
        for i := 0 to Pred(itemCount) do
        begin
          BA := Bank_Account_At(i);
          if (Ba.baFields.baAccount_Type = btBank) then
            cmbAccountList.Items.AddObject(BA.Title, Bank_Account_At(i));
        end;

      //automatically select the first item
      if (cmbAccountList.Items.Count > 0) then begin

         if assigned(bankaccount) then
            i :=  cmbAccountList.Items.IndexOfObject(bankaccount)
         else
            i := 0;
         if i < 0 then  i := 0;

         cmbAccountList.ItemIndex := i;
      end else
      begin
        HelpfulInfoMsg( 'No valid bank accounts have been set up for this client.',0);
        Exit;
      end;

      btnpreview.Visible := true;
      btnPreview.default := true;
      btnPreview.Hint    := STDHINTS.PreviewHint;

      btnFile.Visible    := true;
      btnFile.Hint       := STDHINTS.PrintToFileHint;

      btnEmail.Visible   := true;

      btnOK.default      := false;
      btnOK.Caption      := '&Print';
      btnOK.Hint         := STDHINTS.PrintHint;

      Params := RptParams;
      //UpdateRange;
    end;

    if MyCodeDate.Execute then
    begin
      DateFrom := MyCodeDate.dlgDateFrom;
      DateTo   := MyCodeDate.dlgDateTo;

      if not MyCodeDate.AllowBlank then
      begin
         gCodingDateFrom := DateFrom;
         gCodingDateTo   := DateTo;

         MyClient.clFields.clPeriod_Start_Date := gCodingDateFrom;
         Myclient.clFields.clPeriod_End_Date   := gCodingDateTo;
      end;

      if (MyCodeDate.cmbAccountList.ItemIndex <> -1) then
        BankAccount := TBank_Account(MyCodeDate.cmbAccountList.Items.Objects[MyCodeDate.cmbAccountList.ItemIndex]);

      RptParams.RunBtn := MyCodeDate.Pressed;
      IncludeUPCs := True;  //upc's should always be treated as missing cheques
      result := true;
    end;

  finally // wrap up
    MyCodeDate.Free;
  end;    // try/finally
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDateCheque.SetValidAccountTypes(
  const Value: TAccountSet);
begin
  FValidAccountTypes := Value;
end;

procedure TdlgCodeDateCheque.tblFromToGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
begin
  Data := nil;
  if Assigned(FData) then
  begin
      if not ((RowNum>0) and (RowNum <= tblFromTo.RowLimit)) then exit;
      case ColNum of
        1:
           Data := @FData^[RowNum].SN1;
        2:
           Data := @FData^[RowNum].SN2;
      end;    // case
  end;
end;

// Set Default Behaviours for Buttons Off when entering Grid
procedure TdlgCodeDateCheque.tblFromToEnter(Sender: TObject);
begin
  btnPreview.Default := False;
  btClose.Cancel := False;
end;

// Set Default Behaviours for Buttons back on
procedure TdlgCodeDateCheque.tblFromToExit(Sender: TObject);
begin
  btnPreview.Default := True;
  btClose.Cancel := True;
  tblFromTo.StopEditingState(True);
end;

procedure TdlgCodeDateCheque.tblFromToActiveCellMoving(Sender: TObject;
  Command: Word; var RowNum, ColNum: Integer);
begin
  if (tblFromTo.ActiveCol = 2) and (command = ccRight) then begin
     if Rownum+1 <= tblFromTo.RowLimit then begin
        Inc(RowNum);
        ColNum := 1;
     end;
  end;
end;

procedure TdlgCodeDateCheque.tblFromToKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_DELETE, VK_BACK :
      begin
        case tblFromTo.ActiveCol of
          1:
            FData^[tblFromTo.ActiveRow].SN1 := 0;
          2:
            FData^[tblFromTo.ActiveRow].SN2 := 0;
        end;
        tblFromTo.AllowRedraw := False;
        tblFromTo.InvalidateCell(tblFromTo.ActiveRow, tblFromTo.ActiveCol);
        tblFromTo.AllowRedraw := True;
      end;
  end;
end;

procedure TdlgCodeDateCheque.UpdateRange;
var
  d1, d2 : integer;
  ba : TBank_Account;
  t : integer;
  pT : pTransaction_Rec;
  Qmin,QMax : Integer;

begin
  lblRange.Caption := '';
  if (not eDateSelector.ValidateDates(False)) then
    Exit;

  D1 := stNull2Bk(eDateSelector.eDateFrom.AsStDate);
  D2 := stNull2Bk(eDateSelector.eDateTo.AsStDate);

  //  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //Validate the dates entered
  //  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if (((D1=0) and AllowBlank) or DateIsValid(eDateSelector.eDateFrom.AsString))
  and (((D2=MaxInt) and AllowBlank) or DateisValid(eDateSelector.eDateTo.AsString)) then
  begin

     {validate from after to, first day of mth, last day of mth}
     if D1 > D2 then exit;
     QMin := MaxLongInt;
     QMax := 0;

     //look for cheques within the date range
     if (cmbAccountList.ItemIndex <> -1) then
        ba := TBank_Account(cmbAccountList.Items.Objects[cmbAccountList.ItemIndex])
     else
        exit;


     for t := ba.baTransaction_List.First to ba.baTransaction_List.Last do begin
        pT := ba.baTransaction_List.Transaction_At(t);
        if ( CompareDates( pT^.txDate_Effective, D1, D2 )=Within )
        and ( pT^.txCheque_Number <> 0) then begin
             QMin := Min(QMin,pT^.txCheque_Number);
             QMax := Max(QMax,pT^.txCheque_Number);
        end;
     end;

     if Qmax > 0 then begin
        // must have some Cheques
        if Qmax <> Qmin then
           lblRange.Caption := '(' + IntToStr(Qmin) + ' - ' + IntToStr(Qmax) + ')'
        else
           lblRange.Caption := '(' + IntToStr(Qmax) + ')';
     end;

  end;
end;

end.

