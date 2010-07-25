unit CodeDateDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Used for selecting date ranges for things such as the Code Entries date
//range selection
//
//uses orpheus dates not tDateTime
//list entries date dlg DECENDS from this
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  RptParams,
  StdCtrls, Forms, DateSelectorFme,  Classes
  ,Windows, Messages, SysUtils,  Graphics, Controls,  Dialogs,
  ComCtrls, Buttons, ovcDate, ExtCtrls,
  OvcABtn, OvcPF, OvcBase, OvcEF, OvcPB, OvcSC, Menus,
  OsFont, AccountSelectorFme;

type
  TdlgCodeDate = class(TForm)
    btnOK: TButton;
    btClose: TButton;
    btnPreview: TButton;
    btnFile: TButton;
    btnSave: TBitBtn;
    PCOptions: TPageControl;
    tsOptions: TTabSheet;
    Label1: TLabel;
    lblData: TLabel;
    DateSelector: TfmeDateSelector;
    radButton1: TRadioButton;
    radButton2: TRadioButton;
    chkWrapNarration: TCheckBox;
    tsAdvanced: TTabSheet;
    fmeAccountSelector1: TfmeAccountSelector;

    procedure btnOKClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure radButton1Click(Sender: TObject);

  private
    { Private declarations }
    FDatesOk  : boolean;
    FDateFrom,
    FDateTo   : TSTDate;
    FAllowBlank: boolean;
    FPressed: integer;
    FCheckEntries: boolean;
    FTransactionsFrom, FTransactionsTo : TstDate;
    FRptParams: TRPTParameters;

    procedure SetAllowBlank(const Value: boolean);
    function  CheckClose : boolean;
    procedure SetPressed(const Value: integer);
    procedure SetCheckEntries(const Value: boolean);
    procedure SetRptParams(const Value: TRPTParameters);
    procedure SetNextControl;
  public
    { Public declarations }
    property dlgDateFrom : TStDate read FDateFrom write FDateFrom;
    property dlgDateTo   : TStDate read FDateTo write FDateTo;
    property AllowBlank  : boolean read FAllowBlank write SetAllowBlank;

    function Execute : boolean;
    property Pressed : integer read FPressed write SetPressed;
    property CheckEntries : boolean read FCheckEntries write SetCheckEntries;
    property RptParams: TRPTParameters read FRptParams write SetRptParams;
  end;

function EnterDateRange(Caption : string;
                        Text : string;
                        var dateFrom,dateTo : TStDate;
                        HelpCtx : integer;
                        Blank : boolean;
                        CheckEntries : boolean) : boolean;

function EnterPrintDateRange(Caption : string; Text :string;
                             var DateFrom,DateTo : TstDate; HelpCtx: integer; Blank : Boolean;
                             Params: TRPTParameters
                             ) : boolean;

function EnterPrintDateRangeOptions(Caption : string; Text :string;
                           var DateFrom,DateTo : TstDate; HelpCtx: integer; Blank : Boolean;
                           Options : array of String;
                           var Button : Integer;
                           Params: TRPTParameters;
                           var WrapNarration: Boolean;
                           const ShowNarration: Boolean = False;
                           AccountSet: TAccountSet = []
                           ): boolean;

function EnterCodingDateRange(Caption : string; Text : string;
                            var dateFrom,dateTo : TStDate; HelpCtx : integer;Blank : boolean;
                            CheckEntries : boolean) : boolean;

//******************************************************************************
implementation

uses
  ClientHomePagefrm,
  BKHelp,
  bkXPThemes,
  globals,
  yesnodlg,
  stdaTest,
  InfoMoreFrm,
  selectDate,
  imagesfrm,
  baObj32,
  WarningMoreFrm,
  bkDateUtils,
  ClDateUtils,
  StdHints;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TdlgCodeDate.SetNextControl;
begin
  if radButton1.Visible and radButton1.Checked then
    DateSelector.NextControl := radButton1
  else if radButton2.Visible and radButton2.Checked then
    DateSelector.NextControl := radButton2
  else if chkWrapNarration.Visible then
    DateSelector.NextControl := chkWrapNarration
  else
    DateSelector.NextControl :=  btnOK;
end;

procedure TdlgCodeDate.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  FTransactionsFrom := BAllData( MyClient );
  FTransactionsTo   := EAllData( MyClient );
  DateSelector.ClientObj := MyClient;
  DateSelector.InitDateSelect( FTransactionsFrom, FTransactionsTo, btnPreview);
  chkWrapNarration.Visible := False;
  AllowBlank            := false;
  CheckEntries          := false;

  lblData.caption := 'Transactions from: '+bkDate2Str(FTransactionsFrom)+ ' to '+bkDate2Str(FTransactionsTo);

  SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCodeDate.SetUpHelp;
begin
   Self.ShowHint     := INI_ShowFormHints;
   Self.HelpContext  := 0;
   //Components
   btnPreview.Hint   :=
                     STDHINTS.PreviewHint;
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDate.FormShow(Sender: TObject);
begin
   gCodingDateFrom := MyClient.clFields.clPeriod_Start_Date;
   gCodingDateTo   := Myclient.clFields.clPeriod_End_Date;

   if  FDateFrom = 0 then
       FDateFrom := gCodingDateFrom;
   if  FDateTo = 0 then
       FDateTo := gCodingDateTo;

   DateSelector.eDateFrom.asStDate := BkNull2St( FDateFrom);
   DateSelector.eDateTo.asStDate   := BkNull2St( FDateTo);

   DateSelector.eDateFrom.SetFocus;
end;
procedure TdlgCodeDate.radButton1Click(Sender: TObject);
begin
  SetNextControl;
end;

//------------------------------------------------------------------------------
{dialog routines}
procedure TdlgCodeDate.btnOKClick(Sender: TObject);
begin
   if CheckClose then
   begin
     Pressed := BTN_PRINT;
     Close;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDate.btCloseClick(Sender: TObject);
begin
   FDatesOk := false;
   close;
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDate.SetAllowBlank(const Value: boolean);
begin
  FAllowBlank := Value;
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDate.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  case Msg.CharCode of
    109: begin
           DateSelector.btnPrev.Click;
           Handled := true;
         end;
    107: begin
           DateSelector.btnNext.click;
           Handled := true;
         end;
    VK_MULTIPLY : begin
           DateSelector.btnQuik.click;
           handled := true;
         end;
  end;
end;
//------------------------------------------------------------------------------
function TdlgCodeDate.CheckClose: boolean;
var
//  y,m,d : integer;
  CloseOK : boolean;
  Focus : integer;
  d1, d2 : integer;
  NoData : boolean;

begin
  result := false;

  if (not DateSelector.ValidateDates) then
    Exit;

  D1 := stNull2Bk(DateSelector.eDateFrom.AsStDate);
  D2 := stNull2Bk(DateSelector.eDateTo.AsStDate);

  if (((D1=0) and AllowBlank) or DateIsValid(DateSelector.eDateFrom.AsString)) and
     (((D2=MaxInt) and AllowBlank) or DateisValid(DateSelector.eDateTo.AsString)) then
  begin
     {dates are valid}
     FDatesOK := true;
     Focus    := 1;
     CloseOK  := true;

     {validate from after to, first day of mth, last day of mth}
     if D1 > D2 then
     begin
        HelpfulInfoMsg('"From" Date is later than "To" Date.  Please select valid dates.',0);
        CloseOk := false;
     end
     else
     begin
       {from date not 1st of mth}
       (*
       if D1 <> 0 then
       begin
         stDateToDMY(D1,d,m,y);
         if (d <> 1) and (not(d1 = FTransactionsFrom)) then
            if AskYesNo('Please Confirm Dates','The "From" date you entered (' + bkDate2Str(D1)+ ') is not the'
                          +' first day of the month.  Would you like '+SHORTAPPNAME+' to correct it for you?',DLG_YES,0)
                           = DLG_YES then
               D1 := DMYtoStDate(1,m,y,BKDATEEPOCH);
       end;

       if D2 <> MaxInt then
       begin
         {to date not last of mth}
         if CloseOK = true then  {havent asked a question yet!}
         if (not IsTheLastDayOfTheMonth(D2)) and (not(d2 = FTransactionsTo )) then
            if AskYesNo('Please Confirm Dates','The "To" date you entered (' + bkDate2Str(D2)+ ') is not the'
                          +' last day of the month.  Would you like '+SHORTAPPNAME+' to correct it for you?',DLG_YES,0)
                           = DLG_YES then
            begin
              stDateToDMY(d2,d,m,y);
              D2 := DMYtoSTDate(DaysInMonth(m,y,BKDATEEPOCH),m,y, BKDATEEPOCH);
            end;
       end;
       *)
     end; {d2 > d1}

     if CheckEntries and CloseOK then
     begin
        NoData := ((d1 < FTransactionsFrom) and (d2 < FTransactionsFrom) or (d1 > FTransactionsTo) and (d2 > FTransactionsTo));

        if NoData then
        begin
          HelpfulWarningMsg('There are no Entries for this client in the current date range.',0);
          CloseOK := false;
        end;
     end;

     if CloseOK then
     begin
       FDateFrom := D1;
       FDateTo   := D2;
       result    := true;
     end
     else
        if focus = 2 then DateSelector.eDateTo.SetFocus else DateSelector.eDateFrom.SetFocus;
  end
  else
     HelpfulInfoMsg('A valid date range has not been entered' +#13+#13+'Please select new dates.',0);
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDate.SetPressed(const Value: integer);
begin
  FPressed := Value;
end;
procedure TdlgCodeDate.SetRptParams(const Value: TRPTParameters);
begin
  FRptParams := Value;
  if assigned(FRptParams) then begin
     FRptParams.SetDlgButtons(btnPreview, btnFile, btnSave, btnOk);
     if assigned(FRptParams.RptBatch) then
        Caption := Caption + ' [' + FRptParams.RptBatch.Name + ']';
  end else
     BtnSave.Hide
end;

//------------------------------------------------------------------------------
procedure TdlgCodeDate.btnPreviewClick(Sender: TObject);
begin
   if CheckClose then
   begin
     Pressed := BTN_PREVIEW;
     Close;
   end;
end;

procedure TdlgCodeDate.BtnSaveClick(Sender: TObject);
begin
   //if CheckClose then begin
   if not RptParams.CheckForBatch then
     Exit;

     Pressed := BTN_SAVE;
     FDatesOK := True;  // No its not....
     Close;
   //end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCodeDate.btnFileClick(Sender: TObject);
begin
   if CheckClose then begin
     Pressed := BTN_FILE;
     Close;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgCodeDate.SetCheckEntries(const Value: boolean);
begin
  FCheckEntries := Value;
end;
//------------------------------------------------------------------------------
function TdlgCodeDate.Execute: boolean;
begin
   FDatesOK := false;
   Pressed  := BTN_NONE;
   Self.ShowModal;
   result := FDatesOK;
end;    //
//------------------------------------------------------------------------------
function EnterPrintDateRange(Caption : string; Text :string;
                             var DateFrom,DateTo : TstDate; HelpCtx: integer; Blank : Boolean;
                             Params: TRPTParameters
                             ) : boolean;
var
  MyCodeDate : TdlgCodeDate;
begin
  result := false;
  Params.RunBtn    := BTN_NONE;

  MyCodeDate := TdlgCodeDate.Create(Application.MainForm);
  try
    BKHelpSetUp(MyCodeDate, HelpCtx);
    MyCodeDate.Label1.caption     := text;
    MyCodeDate.AllowBlank         := Blank;
    MyCodeDate.caption   := caption;
    MyCodeDate.chkWrapNarration.Visible := False;
    MyCodeDate.tsAdvanced.TabVisible := False;
    MyCodeDate.tsOptions.TabVisible := False;
    MyCodeDate.pcoptions.ActivePage := MyCodeDate.tsOptions;

    with MyCodeDate do begin
      btnpreview.Visible := true;
      btnPreview.default := true;
      btnPreview.Hint    := STDHINTS.PreviewHint;

      btnFile.Visible    := true;
      btnFile.Hint       := STDHINTS.PrintToFileHint;

      btnOK.default      := false;
      btnOK.Caption      := '&Print';
      btnOK.Hint         := STDHINTS.PrintHint;

      dlgDateFrom        := DateFrom;
      dlgDateTo          := DateTo;
     
      RptParams := Params;
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
         Result := Params.DlgResult(MyCodeDate.Pressed);
    end;

  finally // wrap up
    MyCodeDate.Free;
  end;    // try/finally
end;
//------------------------------------------------------------------------------
function EnterPrintDateRangeOptions(Caption : string; Text :string;
                           var DateFrom,DateTo : TstDate; HelpCtx: integer; Blank : Boolean;
                           Options : array of String;
                           var Button : Integer;
                           Params: TRPTParameters;
                           var WrapNarration: Boolean;
                           const ShowNarration: Boolean = False;
                           AccountSet: TAccountSet = []): boolean;
var
  MyCodeDate : TdlgCodeDate;
begin
  result := false;
  Params.RunBtn    := BTN_NONE;

  MyCodeDate := TdlgCodeDate.Create(Application.MainForm);
  try
    BKHelpSetUp(MyCodeDate, HelpCtx);
    MyCodeDate.Label1.caption := text;
    MyCodeDate.AllowBlank := Blank;
    MyCodeDate.caption := caption;
    MyCodeDate.chkWrapNarration.Visible := ShowNarration;
    MyCodeDate.chkWrapNarration.Checked := WrapNarration;

    if AccountSet = [] then begin
       MyCodeDate.tsAdvanced.TabVisible := False;
       MyCodeDate.tsoptions.TabVisible := False;
       MyCodeDate.pcoptions.ActivePage := MyCodeDate.tsOptions;
    end else begin
       MyCodeDate.fmeAccountSelector1.LoadAccounts(Params.Client,AccountSet);
       MyCodeDate.fmeAccountSelector1.UpdateSelectedAccounts(Params);
    end;
    
    with MyCodeDate do begin
      if (Length(Options) > 0) then
      begin
        radButton1.Caption := Options[0];
        radButton1.Checked := Button = 0;
        radButton1.Visible := True;
      end;
      if (Length(Options) > 1) then
      begin
        radButton2.Caption := Options[1];
        radButton2.Checked := Button = 1;
        radButton2.Visible := True;
      end;

      btnpreview.Visible := true;
      btnPreview.default := true;
      btnPreview.Hint    := STDHINTS.PreviewHint;

      btnFile.Visible    := true;
      btnFile.Hint       := STDHINTS.PrintToFileHint;

      btnOK.default      := false;
      btnOK.Caption      := '&Print';
      btnOK.Hint         := STDHINTS.PrintHint;

      RptParams := Params;

      SetNextControl;

      dlgDateFrom := DateFrom;
      dlgDateTo   := DateTo;
    end;

    if MyCodeDate.Execute then
    begin
      {store updates in globals}
      DateFrom := MyCodeDate.dlgDateFrom;
      DateTo   := MyCodeDate.dlgDateTo;

      if not MyCodeDate.chkWrapNarration.Visible then
        WrapNarration := False
      else
        WrapNarration  := MyCodeDate.chkWrapNarration.Checked;

      if (MyCodeDate.radButton1.Visible and MyCodeDate.radButton1.Checked) then
        Button := 0
      else if (MyCodeDate.radButton2.Visible and MyCodeDate.radButton2.Checked) then
        Button := 1
      else
        Button := -1;

      if not (AccountSet = [])  then begin
         MyCodeDate.fmeAccountSelector1.SaveAccounts(Params.Client,Params);
      end;

      if not MyCodeDate.AllowBlank then
      begin
         gCodingDateFrom := DateFrom;
         gCodingDateTo   := DateTo;

         MyClient.clFields.clPeriod_Start_Date := gCodingDateFrom;
         Myclient.clFields.clPeriod_End_Date   := gCodingDateTo;
      end;
      Result := Params.DlgResult(MyCodeDate.Pressed);
    end;

  finally // wrap up
    MyCodeDate.Free;
  end;    // try/finally
end;
//------------------------------------------------------------------------------
function EnterCodingDateRange(Caption : string; Text : string;
                              var dateFrom,dateTo : TStDate;
                              HelpCtx : integer;
                              Blank : boolean;
                              CheckEntries : boolean) : boolean;
var
  MyCodeDate : TdlgCodeDate;
begin
  result := false;

  MyCodeDate := TdlgCodeDate.Create(Application.MainForm); {create a coding date dialog and get values}
  try
    BKHelpSetUp(MyCodeDate, HelpCtx);
    MyCodeDate.Label1.caption := text;
    MyCodeDate.caption        := caption;
    MyCodeDate.AllowBlank     := Blank;
    MyCodeDate.CheckEntries   := CheckEntries;
    MyCodeDate.chkWrapNarration.Visible := False;
    MyCodeDate.RptParams := nil;
    MyCodeDate.tsAdvanced.TabVisible := False;
    MyCodeDate.tsOptions.TabVisible := False;
     MyCodeDate.pcoptions.ActivePage := MyCodeDate.tsOptions;
    with MyCodeDate do begin
       //only want a date range that included bank account rather than accounts and journals
       FTransactionsFrom := BBankData( MyClient );
       FTransactionsTo   := EBankData( MyClient );
       lblData.caption := 'Transactions from: '+bkDate2Str(FTransactionsFrom)+ ' to '+bkDate2Str(FTransactionsTo);
       //reinitialise the frame with new from, to dates
       DateSelector.InitDateSelect( FTransactionsFrom, FTransactionsTo, btnOK);
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
       result := true;
    end;
  finally // wrap up
    MyCodeDate.Free;
  end;    // try/finally
   RefreshHomepage ([HPR_Coding]);
end;
//------------------------------------------------------------------------------
function EnterDateRange(Caption : string; Text : string; var dateFrom,dateTo : TStDate; HelpCtx : integer; Blank : boolean;CheckEntries : boolean) : boolean;
var
  MyCodeDate : TdlgCodeDate;
begin
  result := false;

  MyCodeDate := TdlgCodeDate.Create(Application.MainForm); {create a coding date dialog and get values}
  try
    BKHelpSetUp(MyCodeDate, HelpCtx);
    MyCodeDate.Label1.caption := text;
    MyCodeDate.caption        := caption;
    MyCodeDate.AllowBlank     := Blank;
    MyCodeDate.CheckEntries   := CheckEntries;
    MyCodeDate.DateSelector.NextControl := MyCodeDate.btnOK;
    MyCodeDate.chkWrapNarration.Visible := False;
    MyCodeDate.RptParams := nil;
    MyCodeDate.tsAdvanced.TabVisible := False;
    MyCodeDate.tsOptions.TabVisible := False;
     MyCodeDate.pcoptions.ActivePage := MyCodeDate.tsOptions;

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
         result := true;
    end;

  finally // wrap up
    MyCodeDate.Free;
  end;    // try/finally
end;
//------------------------------------------------------------------------------


end.

