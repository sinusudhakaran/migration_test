unit CodeDateAccountDlg;
//------------------------------------------------------------------------------
{
   Title:        Date and Account selector dialog

   Description:  Allows you to select dates and select accounts from same window

   Author:

   Remarks:

}
//------------------------------------------------------------------------------

interface
uses
  rptParams, StdCtrls, AccountSelectorFme, Forms,  Controls,
  ExtCtrls, ComCtrls, Classes,
  Windows,
  Messages, SysUtils,  Graphics, Dialogs,
  Buttons, ovcDate,
  OvcABtn, OvcPF, OvcBase, OvcEF, OvcPB, OvcSC, Menus,
  DateSelectorFme,
  OSFont;

type
    TAccountSet = set of byte;

type
  TdlgCodeDateAccount = class(TForm)
    PageControl1: TPageControl;
    tbsOptions: TTabSheet;
    Panel1: TPanel;
    eDateSelector: TfmeDateSelector;
    tbsAdvanced: TTabSheet;
    Panel2: TPanel;
    fmeAccountSelector1: TfmeAccountSelector;
    pnlButtons: TPanel;
    Label1: TLabel;
    lblData: TLabel;
    btnPreview: TButton;
    btnFile: TButton;
    btnOK: TButton;
    btClose: TButton;
    chkWrapNarration: TCheckBox;
    btnSave: TBitBtn;
    btnEmail: TButton;
    ShapeBorder: TShape;

    procedure btnOKClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure SetUpHelp;
    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure BtnsaveClick(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
  private
    { Private declarations }
    FDatesOk  : boolean;
    FDateFrom,
    FDateTo   : TSTDate;
    FAllowBlank: boolean;
    FPressed: integer;
    FCheckEntries: boolean;
    FTransactionsFrom, FTransactionsTo : TstDate;
    FValidAccountTypes: TAccountSet;
    FRptParams: TRptParameters;
    FForceFullPeriod: Boolean;

    procedure SetAllowBlank(const Value: boolean);
    function  CheckClose(Dodates: Boolean= True) : boolean;
    procedure SetPressed(const Value: integer);
    procedure SetCheckEntries(const Value: boolean);
    procedure SetValidAccountTypes(const Value: TAccountSet);
    procedure SetRptParams(const Value: TRptParameters);
    procedure SetDateFrom(const Value: TStDate);
    procedure SetDateTo(const Value: TStDate);
    procedure SetForceFullPeriod(const Value: Boolean);
  public
    { Public declarations }
    property dlgDateFrom : TStDate read FDateFrom write SetDateFrom;
    property dlgDateTo   : TStDate read FDateTo write SetDateTo;
    property AllowBlank  : boolean read FAllowBlank write SetAllowBlank;
    property ValidAccountTypes : TAccountSet read FValidAccountTypes write SetValidAccountTypes;
    property Pressed : integer read FPressed write SetPressed;
    property CheckEntries : boolean read FCheckEntries write SetCheckEntries;
    property RptParams: TRptParameters read FRptParams write SetRptParams;
    property ForceFullPeriod: Boolean read FForceFullPeriod write SetForceFullPeriod;
    function Execute : boolean;
    procedure LoadAccounts;
  end;

function EnterPrintDateAccountRange( Caption : string;
                                     Text :string;
                                     ValidAccounts : TAccountSet;
                                     Params : TRptParameters;
                                     HelpCtx: integer;
                                     Blank : Boolean;
                                     var WrapNarration: Boolean;
                                     const ShowNarration: Boolean = False;
                                     ForceFullPeriod: Boolean = False): boolean;

//function EnterDateAccountRange(Caption : string; Text : string;
//  var dateFrom,dateTo : TStDate; var AccountList : TStringList;
//  HelpCtx : integer;Blank : boolean; CheckEntries : boolean) : boolean;
//function EnterCodingDateAccountRange(Caption : string; Text : string;
//  var dateFrom,dateTo : TStDate; var AccountList : TStringList;
//  HelpCtx : integer;Blank : boolean; CheckEntries : boolean) : boolean;

//******************************************************************************
implementation

uses
  globals,
  BKConst,
  BKHelp,
  yesnodlg,
  stdaTest,
  InfoMoreFrm,
  selectDate,
  imagesfrm,
  baObj32,
  WarningMoreFrm,
  bkDateUtils,
  ClDateUtils,
  StdHints,
  bkXPThemes;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TdlgCodeDateAccount.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  PageControl1.ActivePageIndex := 0;

  FTransactionsFrom := BAllData( MyClient );
  FTransactionsTo   := EAllData( MyClient );
  lblData.caption := 'Transactions from: '+bkDate2Str(FTransactionsFrom)+ ' to '+bkDate2Str(FTransactionsTo);
  eDateSelector.ClientObj := MyClient;
  eDateSelector.InitDateSelect(FTransactionsFrom, FTransactionsTo, btnPreview);
  FValidAccountTypes := [];

  AllowBlank            := false;
  CheckEntries          := false;
  chkWrapNarration.Visible := False;
  FForceFullPeriod := False;
  SetUpHelp;

  gCodingDateFrom := MyClient.clFields.clPeriod_Start_Date;
  gCodingDateTo   := Myclient.clFields.clPeriod_End_Date;

  //favorite reports functionality is disabled in simpleUI
  if Active_UI_Style = UIS_Simple then
     btnSave.Hide;

  (*
  eDateSelector.eDateFrom.asStDate := BkNull2St(gCodingDateFrom);
  eDateSelector.eDateTo.asStDate   := BkNull2St(gCodingDateTo);
  *)
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDlgCodeDateAccount.LoadAccounts;
begin
  fmeAccountSelector1.LoadAccounts( MyClient, FValidAccountTypes);
  fmeAccountSelector1.btnSelectAllAccounts.Click;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCodeDateAccount.SetUpHelp;
begin
   Self.ShowHint     := INI_ShowFormHints;
   Self.HelpContext  := 0;
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDateAccount.FormShow(Sender: TObject);
begin


   eDateSelector.eDateFrom.SetFocus;
end;
//------------------------------------------------------------------------------
{dialog routines}
procedure TdlgCodeDateAccount.btnOKClick(Sender: TObject);
begin
   if CheckClose then
   begin
     Pressed := BTN_PRINT;
     Close;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDateAccount.btCloseClick(Sender: TObject);
begin
   FDatesOk := false;
   close;
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDateAccount.SetAllowBlank(const Value: boolean);
begin
  FAllowBlank := Value;
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDateAccount.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
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
function TdlgCodeDateAccount.CheckClose(Dodates: Boolean= True): boolean;
var I : Integer;

  function Checkdates : boolean;
  var d1, d2 : integer;
  begin
     Result := False;
     if (not eDateSelector.ValidateDates) then
       Exit;

     D1 := stNull2Bk(eDateSelector.eDateFrom.AsStDate);
     D2 := stNull2Bk(eDateSelector.eDateTo.AsStDate);

     if (((D1=0) and AllowBlank) or DateIsValid(eDateSelector.eDateFrom.AsString)) and (((D2=MaxInt) and AllowBlank) or DateisValid(eDateSelector.eDateTo.AsString)) then
     begin
       //dates are valid
       {validate from after to, first day of mth, last day of mth}
       if D1 > D2 then
       begin
         PageControl1.ActivePage := tbsOptions;
         eDateSelector.eDateFrom.SetFocus;
         HelpfulInfoMsg('"From" Date is later than "To" Date.  Please select valid dates.',0);
         exit;
       end
       else
       if FForceFullPeriod then
       begin
         if (not IsTheFirstDayOfTheMonth(D1)) and not IsTheLastDayOfTheMonth(D2) then
         begin
           PageControl1.ActivePage := tbsOptions;
           eDateSelector.eDateFrom.SetFocus;
           HelpfulInfoMsg('The From and To dates entered must be the first day and last day of the month respectively.',0);
           eDateSelector.eDateFrom.AsStDate := GetFirstDayOfMonth(D1);
           eDateSelector.eDateTo.AsStDate := GetLastDayOfMonth(D2);
           exit;
         end
         else
         if not IsTheFirstDayOfTheMonth(D1) then
         begin
           PageControl1.ActivePage := tbsOptions;
           eDateSelector.eDateFrom.SetFocus;
           HelpfulInfoMsg('The From date entered must be the first day of the month.',0);
           eDateSelector.eDateFrom.AsStDate := GetFirstDayOfMonth(D1);
           exit;
         end
         else
         if not IsTheLastDayOfTheMonth(D2) then
         begin
           PageControl1.ActivePage := tbsOptions;
           eDateSelector.eDateTo.SetFocus;
           HelpfulInfoMsg('The To date entered must be the last day of the month.',0);
           eDateSelector.eDateTo.AsStDate := GetLastDayOfMonth(D2);
           exit;
         end;
       end;
     end
     else
     begin
        HelpfulInfoMsg('The Dates entered are Invalid!' +#13+#13+'Please select valid dates.',0);
        PageControl1.ActivePage := tbsOptions;
        eDateSelector.eDateFrom.SetFocus;
        Exit;
     end;

     if CheckEntries then begin // Only relevant if we have dates..
        if   (   (d1 < FTransactionsFrom) and (d2 < FTransactionsFrom)
              or (d1 > FTransactionsTo)   and (d2 > FTransactionsTo))

        then begin
          HelpfulWarningMsg('There are no Entries for this client in the current date range.',0);
          Exit;
        end;
     end;

     // Still here..
     FDateFrom := D1;
     FDateTo   := D2;
     Result := True;
  end;

begin
  result := False;
  FDatesOK := False; // Don't ask...
  if Dodates then
    if not Checkdates then exit;

  //check if any accounts have been selected
  with fmeAccountSelector1 do
     for i := 0 to pred(AccountCheckBox.Items.Count)do
        if (AccountCheckBox.Checked[i]) then begin
           Result := True;
           Break;
         end;

  if Result then
     FDatesOK := True
  else begin
     HelpfulWarningMsg('No accounts have been selected.',0);
     PageControl1.ActivePage := tbsAdvanced;
     fmeAccountSelector1.AccountCheckBox.Setfocus;
  end;

end;
//------------------------------------------------------------------------------
procedure TdlgCodeDateAccount.SetPressed(const Value: integer);
begin
  FPressed := Value;
end;
procedure TdlgCodeDateAccount.SetRptParams(const Value: TRptParameters);
begin
  FRptParams := Value;
  if assigned(FRptParams) then begin
     FRptParams.SetDlgButtons(BtnPreview,BtnFile,BtnEmail,Btnsave,BtnOk);
     if Assigned(FRptParams.RptBatch) then
        Caption := Caption + ' [' + FRptParams.RptBatch.Name + ']';
  end;

end;

//------------------------------------------------------------------------------
procedure TdlgCodeDateAccount.btnPreviewClick(Sender: TObject);
begin
   if CheckClose then
   begin
     Pressed := BTN_PREVIEW;
     Close;
   end;
end;
procedure TdlgCodeDateAccount.BtnsaveClick(Sender: TObject);
begin
   if CheckClose(False) then begin
     if not FRptParams.CheckForBatch('',Caption) then
         Exit;
     Pressed := BTN_SAVE;
     Close;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCodeDateAccount.btnEmailClick(Sender: TObject);
begin
   if CheckClose then begin
     Pressed := BTN_EMAIL;
     Close;
   end;
end;

procedure TdlgCodeDateAccount.btnFileClick(Sender: TObject);
begin
   if CheckClose then begin
     Pressed := BTN_FILE;
     Close;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDateAccount.SetCheckEntries(const Value: boolean);
begin
  FCheckEntries := Value;
end;

procedure TdlgCodeDateAccount.SetDateFrom(const Value: TStDate);
begin
  FDateFrom := Value;
  eDateSelector.eDateFrom.AsStDate := FDateFrom;
end;

procedure TdlgCodeDateAccount.SetDateTo(const Value: TStDate);
begin
  FDateTo := Value;
  eDateSelector.eDateTo.AsStDate := FDateTo;
end;

procedure TdlgCodeDateAccount.SetForceFullPeriod(const Value: Boolean);
begin
  FForceFullPeriod := Value;
end;

//------------------------------------------------------------------------------
function TdlgCodeDateAccount.Execute: boolean;
begin
   FDatesOK := false;
   Pressed  := BTN_NONE;
   Self.ShowModal;
   result := FDatesOK;
end;    //
//------------------------------------------------------------------------------
function EnterPrintDateAccountRange( Caption : string;
                                     Text :string;
                                     ValidAccounts : TAccountSet;
                                     Params : TRptParameters;
                                     HelpCtx: integer;
                                     Blank : Boolean;
                                     var WrapNarration: Boolean;
                                     const ShowNarration: Boolean = False;
                                     ForceFullPeriod: Boolean = False): boolean;
var
  MyCodeDate : TdlgCodeDateAccount;
  i : Integer;
  BA : TBank_Account;
begin
  result := false;
  MyCodeDate := TdlgCodeDateAccount.Create(Application.MainForm);
  try
    BKHelpSetUp(MyCodeDate, HelpCtx);
    MyCodeDate.Label1.caption  := text;
    MyCodeDate.AllowBlank      := Blank;
    MyCodeDate.caption         := caption;
    MyCodeDate.ValidAccountTypes := ValidAccounts;
    MyCodeDate.chkWrapNarration.Visible := ShowNarration;
    MyCodeDate.chkWrapNarration.Checked := WrapNarration;
    MyCodeDate.ForceFullPeriod := ForceFullPeriod;
    //fill the accounts list
    MyCodeDate.LoadAccounts;

    with MyCodeDate do begin

      btnpreview.Visible := true;
      btnPreview.default := true;
      btnPreview.Hint    := STDHINTS.PreviewHint;

      btnFile.Visible    := true;
      btnFile.Hint       := STDHINTS.PrintToFileHint;

      btnOK.default      := false;
      btnOK.Caption      := '&Print';
      btnOK.Hint         := STDHINTS.PrintHint;

      RptParams := Params;
      dlgDateFrom := Params.FromDate;
      dlgDateTo := Params.ToDate;


      for I := 0 to fmeAccountSelector1.AccountCheckBox.Count - 1 do
         if params.AccountList.IndexOf (fmeAccountSelector1.AccountCheckBox.Items.Objects[I]) = -1 then
            MyCodeDate.fmeAccountSelector1.AccountCheckBox.Checked[i] := False;
    end;



    if MyCodeDate.Execute then
    begin
      {store updates in globals}
      Params.FromDate := MyCodeDate.dlgDateFrom;
      params.ToDate   := MyCodeDate.dlgDateTo;

      if not MyCodeDate.chkWrapNarration.Visible then
        WrapNarration := False
      else
        WrapNarration  := MyCodeDate.chkWrapNarration.Checked;

        (*
      if not MyCodeDate.AllowBlank then
      begin
         gCodingDateFrom := DateFrom;
         gCodingDateTo   := DateTo;

         MyClient.clFields.clPeriod_Start_Date := gCodingDateFrom;
         Myclient.clFields.clPeriod_End_Date   := gCodingDateTo;
      end;
          *)
      Params.AccountList.Clear;
      for i := 0 to MyCodeDate.fmeAccountSelector1.AccountCheckBox.Count-1 do
        if MyCodeDate.fmeAccountSelector1.AccountCheckBox.Checked[i] then
        begin
          BA := TBank_Account(MyCodeDate.fmeAccountSelector1.AccountCheckBox.Items.Objects[i]);
          Params.AccountList.Add(BA);
        end;

      Result :=  Params.DlgResult(MyCodeDate.Pressed);
    end;

  finally // wrap up
    MyCodeDate.Free;
  end;    // try/finally
end;
//------------------------------------------------------------------------------
function EnterCodingDateAccountRange(Caption : string; Text : string; var dateFrom,dateTo : TStDate;
  var AccountList : TStringList; HelpCtx : integer;Blank : boolean; CheckEntries : boolean) : boolean;
var
  MyCodeDate : TdlgCodeDateAccount;
  i : Integer;
  BA : TBank_Account;
begin
  result := false;

  MyCodeDate := TdlgCodeDateAccount.Create(Application); {create a coding date dialog and get values}
  try
    BKHelpSetUp(MyCodeDate, HelpCtx);
    MyCodeDate.Label1.caption := text;
    MyCodeDate.caption        := caption;
    MyCodeDate.AllowBlank     := Blank;
    MyCodeDate.CheckEntries   := CheckEntries;
    MyCodeDate.chkWrapNarration.Visible := False;
    with MyCodeDate do begin
       FTransactionsFrom := BBankData( MyClient );
       FTransactionsTo   := EBankData( MyClient );
       lblData.caption := 'Transactions from: '+bkDate2Str(FTransactionsFrom)+ ' to '+bkDate2Str(FTransactionsTo);
    end;

    if MyCodeDate.Execute then
    begin
      {store updates in globals}
      DateFrom := MyCodeDate.dlgDateFrom;
      DateTo   := MyCodeDate.dlgDateTo;

      if not MyCodeDate.AllowBlank then
      begin
        gCodingDateFrom := DateFrom;
        gCodingDateTo   := DateTo;

        MyClient.clFields.clPeriod_Start_Date := gCodingDateFrom;
        Myclient.clFields.clPeriod_End_Date   := gCodingDateTo;
      end;

      AccountList.Clear;
      for i := 0 to MyCodeDate.fmeAccountSelector1.AccountCheckBox.Count-1 do
        if MyCodeDate.fmeAccountSelector1.AccountCheckBox.Checked[i] then
        begin
          BA := TBank_Account(MyCodeDate.fmeAccountSelector1.AccountCheckBox.Items.Objects[i]);
          AccountList.Add(BA.baFields.baBank_Account_Number);
        end;

      result := true;
    end;
  finally // wrap up
    MyCodeDate.Free;
  end;    // try/finally
end;
//------------------------------------------------------------------------------
function EnterDateAccountRange(Caption : string; Text : string; var dateFrom,dateTo : TStDate;
  var AccountList : TStringList; HelpCtx : integer; Blank : boolean;CheckEntries : boolean) : boolean;
var
  MyCodeDate : TdlgCodeDateAccount;
  i : Integer;
  BA : TBank_Account;
begin
  result := false;

  MyCodeDate := TdlgCodeDateAccount.Create(Application); {create a coding date dialog and get values}
  try
    BKHelpSetUp(MyCodeDate, HelpCtx);
    MyCodeDate.Label1.caption := text;
    MyCodeDate.caption        := caption;
    MyCodeDate.AllowBlank     := Blank;
    MyCodeDate.CheckEntries   := CheckEntries;
    MyCodeDate.chkWrapNarration.Visible := False;
    if MyCodeDate.Execute then
    begin
      {store updates in globals}
      DateFrom := MyCodeDate.dlgDateFrom;
      DateTo   := MyCodeDate.dlgDateTo;

      if not MyCodeDate.AllowBlank then
      begin
         gCodingDateFrom := DateFrom;
         gCodingDateTo   := DateTo;

         MyClient.clFields.clPeriod_Start_Date := gCodingDateFrom;
         Myclient.clFields.clPeriod_End_Date   := gCodingDateTo;
      end;

      AccountList.Clear;
      for i := 0 to MyCodeDate.fmeAccountSelector1.AccountCheckBox.Count-1 do
        if MyCodeDate.fmeAccountSelector1.AccountCheckBox.Checked[i] then
        begin
          BA := TBank_Account(MyCodeDate.fmeAccountSelector1.AccountCheckBox.Items.Objects[i]);
          AccountList.Add(BA.baFields.baBank_Account_Number);
        end;

      result := true;
    end;

  finally // wrap up
    MyCodeDate.Free;
  end;    // try/finally
end;
//------------------------------------------------------------------------------

procedure TdlgCodeDateAccount.SetValidAccountTypes(
  const Value: TAccountSet);
begin
  FValidAccountTypes := Value;
end;

end.

