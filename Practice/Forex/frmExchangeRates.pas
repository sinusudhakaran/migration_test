unit frmExchangeRates;

interface

uses
  Virtualtreehandler,
  ExchangeRateList,  stDate,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OsFont, ActnList, VirtualTrees, ExtCtrls, RzGroupBar, StdCtrls,
  ovcbase, ovcef, ovcpb, ovcpf, Menus, bkDateUtils;

type
  TExchangeRatesfrm = class(TForm)
    pButtons: TPanel;
    btnCancel: TButton;
    BtnoK: TButton;
    RSGroupBar: TRzGroupBar;
    grpStyles: TRzGroup;
    grpDetails: TRzGroup;
    Splitter1: TSplitter;
    pTree: TPanel;
    pTop: TPanel;
    vtRates: TVirtualStringTree;
    ActionList1: TActionList;
    acImport: TAction;
    acLock: TAction;
    acUnlock: TAction;
    eDateFrom: TOvcPictureField;
    eDateTo: TOvcPictureField;
    Label1: TLabel;
    Label2: TLabel;
    ReloadTimer: TTimer;
    acAddExchangeRate: TAction;
    acEditExchangeRate: TAction;
    PopupMenu1: TPopupMenu;
    miSetForWholeMonth: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure acImportExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnoKClick(Sender: TObject);
    procedure acLockExecute(Sender: TObject);
    procedure acUnlockExecute(Sender: TObject);
    procedure eDateToDblClick(Sender: TObject);
    procedure eDateFromChange(Sender: TObject);
    procedure ReloadTimerTimer(Sender: TObject);
    procedure acAddExchangeRateExecute(Sender: TObject);
    procedure acEditExchangeRateExecute(Sender: TObject);
    procedure vtRatesColumnDblClick(Sender: TBaseVirtualTree;
      Column: TColumnIndex; Shift: TShiftState);
    procedure vtRatesFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure miSetForWholeMonthClick(Sender: TObject);
    procedure vtRatesHeaderDragging(Sender: TVTHeader; Column: TColumnIndex;
      var Allowed: Boolean);
    procedure vtRatesContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FTreeList: TTreeBaseList;
    FSource: TExchangeSource;
    FChangeCount: integer;
    FBooksSecure: boolean;
    FColumnOrderLoaded: Boolean;

    function GetFullMonthEditedDeletedCount: Integer;

    function GetEditedDeletedCount: Integer;
    function GetChangeCount: integer;
    procedure SetFromDate(const Value: tstDate);
    procedure SetToDate(const Value: tstDate);
    function GetFromDate: tstDate;
    function GetToDate: tstDate;
    property FromDate: tstDate read GetFromDate write SetFromDate;
    property ToDate: tstDate read GetToDate write SetToDate;
    procedure ReStartTimer;
    procedure FillRates;
    { Private declarations }
  public
    { Public declarations }
    property BooksSecure: boolean read FBooksSecure;
  end;

  TSetForMonth = class(TObject)
  private
    FRange: TDateRange;
    FExchangeRecord: TExchangeRecord;
    FDatesToAdd: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetRange(ADate: integer);
  end;

function MaintainExchangeRates: Boolean;

implementation

uses
  GenUtils,
  frmDateRange,
  ImagesFrm,
  math,
  stTree,
  stBase,
  ImportExchangeDlg,
  Globals,
  YesNoDlg,
  ErrorMoreFrm,
  bkBranding,
  ISO_4217,
  bkXPThemes,
  frmEditExchangeRate,
  InfoMoreFrm,
  DateUtils,
  IniSettings,
  BKHelp,
  ForexHelpers,
  ExchangeGainLoss,
  bkProduct;


{$R *.dfm}


function MaintainExchangeRates: Boolean;
begin
   with TExchangeRatesfrm.Create(Application.MainForm) do try
      ToDate :=  CurrentDate;
      FromDate := GetFirstDayOfMonth(IncDate(CurrentDate, 0, -1, 0));
      FChangeCount := 0;

      Result := ShowModal = mrOK;
      if Result and (FChangeCount > 0) then
        if (FChangeCount = 1) then
          HelpfulInfoMsg(Format('%d exchange rate has been updated to the database',[FChangeCount]), 0)
        else
          HelpfulInfoMsg(Format('%d exchange rates have been updated to the database',[FChangeCount]), 0);
   finally
      Free;
   end;
end;


const
  Tag_Lock = 0;
  Tag_Date = 1;


type
  TExchangeTreeItem = class(TTreeBaseItem)
  private
     FExchangeRecord: TExchangeRecord;
  public
     constructor Create(aExchangeRecord: TExchangeRecord);
     function GetTagText(const Tag: Integer): string; override;
     procedure AfterPaintCell(const Tag : integer; Canvas: TCanvas; CellRect: TRect);override;
  end;


procedure TExchangeRatesfrm.acAddExchangeRateExecute(Sender: TObject);
begin
  if Assigned(FSource) then begin
    if EditExchangeRate(vtRates.Header.Columns, FSource) then
      FillRates;
  end;
end;

procedure TExchangeRatesfrm.acEditExchangeRateExecute(Sender: TObject);
var
  ExchangeRecord: TExchangeRecord;
begin
  if Assigned(FSource) and Assigned(vtRates.FocusedNode) then begin
    ExchangeRecord := TExchangeTreeItem(FTreeList.Items[vtRates.FocusedNode^.Index]).FExchangeRecord;
    if not ExchangeRecord.Locked then
      EditExchangeRate(vtRates.Header.Columns, FSource, ExchangeRecord);
    FillRates;      
  end;
end;

procedure TExchangeRatesfrm.acImportExecute(Sender: TObject);
begin
   if Assigned(FSource) then begin
      if ImportExchangeRates(@FSource, vtRates.Header.Columns) then
         FillRates;
   end;
end;

//*****************************************************************************
function FindLocked(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
begin
   Result := true;
   if TExchangeRecord(Node.Data).Locked then
      tDateRange(OtherData^).FromDate := TExchangeRecord(Node.Data).Date //Last Locked date
   else
      tDateRange(OtherData^).ToDate := TExchangeRecord(Node.Data).Date // Last Unlocked date
end;

type
  TLockRatesRec = record
    Range: TDateRange;
    LockCount: integer;
  end;

function LockRates(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
begin
   Result := true;
   if TExchangeRecord(Node.Data).Locked then
      Exit;
   if TExchangeRecord(Node.Data).Date < TLockRatesRec(OtherData^).Range.FromDate then
      Exit;
   if TExchangeRecord(Node.Data).Date > TLockRatesRec(OtherData^).Range.ToDate then
      Exit;
   TExchangeRecord(Node.Data).Locked := True;
   Inc(TLockRatesRec(OtherData^).LockCount);
end;

//*****************************************************************************
procedure TExchangeRatesfrm.acLockExecute(Sender: TObject);
var
  Range: tDateRange;
  LockRatesRec: TLockRatesRec;
begin
  Range := MakeDateRange(FromDate,ToDate);

  FSource.Iterate(FindLocked,True, @Range);

  if not GetDateRange(Range, 'Lock Exchange Rate Period',
                      'Enter the starting and finishing date for the period you want to lock.') then exit;

  LockRatesRec.LockCount := 0;
  LockRatesRec.Range := Range;
  FSource.Iterate(LockRates, True, @LockRatesRec);
  if LockRatesRec.LockCount > 0 then
    HelpfulInfoMsg(Format('%d exchange rates have been locked',[LockRatesRec.LockCount]), 0)
  else
    HelpfulInfoMsg('There are no exchange rates to be locked in this period', 0);
  vtRates.Invalidate;
end;



//*****************************************************************************

function FindLastLocked(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
begin
   Result := True;
   if TExchangeRecord(Node.Data).Locked then begin
      tDateRange(OtherData^).ToDate := TExchangeRecord(Node.Data).Date; //Last locked date
      Result := False;
   end;
end;

function UnLockRates(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
begin
   Result := true;
   if not TExchangeRecord(Node.Data).Locked then
      Exit;
   if TExchangeRecord(Node.Data).Date < TLockRatesRec(OtherData^).Range.FromDate then
      Exit;
   if TExchangeRecord(Node.Data).Date > TLockRatesRec(OtherData^).Range.ToDate then
      Exit;
   if TExchangeRecord(Node.Data).Locked then begin
     Inc(TLockRatesRec(OtherData^).LockCount);
     TExchangeRecord(Node.Data).Locked := False;
   end;
end;

//*****************************************************************************

procedure TExchangeRatesfrm.acUnlockExecute(Sender: TObject);
const
  UNLOCK_WARNING = 'If you edit the exchange rates BankLink Practice will ' +
                   'update the base amounts of coded transactions ' +
                   'that are not transferred or finalised.'#13#13 +
                   'Are you sure you want to do this?';
var
  Range: tDateRange;
  UnlockRatesRec: TLockRatesRec;
begin
   Range := MakeDateRange(FromDate,ToDate);
   FSource.Iterate(FindLastLocked,False,@Range);
   //Default from date to the start of the last locked period
   Range.FromDate := stDate.DateTimeToStDate(DateUtils.StartOfTheMonth(StDateToDateTime(Range.ToDate)));

   if not GetDateRange(Range, 'Unlock Exchange Rate Period',
         'Enter the starting and finishing date for the period you want to unlock.') then exit;

   //Warning
   if AskYesNo('Unlock Exchange Rate Period', TProduct.Rebrand(UNLOCK_WARNING), Dlg_No, 0) = DLG_YES then begin
     UnlockRatesRec.Range := Range;
     UnlockRatesRec.LockCount := 0;
     FSource.Iterate(UnLockRates,True,@UnlockRatesRec);
     vtRates.Invalidate;
     if (UnlockRatesRec.LockCount > 0) then
       HelpfulInfoMsg(Format('%d exchange rates have been unlocked',[UnlockRatesRec.LockCount]), 0)
     else
       HelpfulInfoMsg('There are no exchange rates to be unlocked in this period', 0)
   end;
end;


procedure TExchangeRatesfrm.BtnoKClick(Sender: TObject);
var
  sMsg: string;
  iResult: integer;
  LExchangeRates: TExchangeRateList;
  FullMonthCount: Integer;
begin
   //Get change count
   FChangeCount := GetChangeCount;

   // Confirm changes for exchange gain/loss
   if SupportsForeignCurrencies then
   begin
     FullMonthCount := GetFullMonthEditedDeletedCount;

     if FullMonthCount > 0 then
     begin
       if (FullMonthCount = 1) then
         sMsg := '1 exchange rate has been edited which may affect clients with existing exchange gain/loss entries.' + #10#13#10#13 + 'Are you sure you want to continue?'
       else
         sMsg := Format('%d exchange rates have been edited which may affect clients with existing exchange gain/loss entries.' + #10#13#10#13 + 'Are you sure you want to continue?', [FullMonthCount]);

       // User cancel?
       iResult := AskYesNo('Confirmation', sMsg, DLG_YES, 0);
       if (iResult <> DLG_YES) then
         exit;
     end;
   end;

   if BooksSecure then begin
     //Save
     MyClient.ExchangeSource.Assign(FSource);
     MyClient.Save;
     Modalresult := mrOk;
   end else begin
     // Validate..
     LExchangeRates := GetExchangeRates(True);
     try
        FSource :=  LExchangeRates.MergeSource(FSource);
        LExchangeRates.Save;
        Modalresult := mrOk;
     finally
        LExchangeRates.Free;
     end;
   end;
end;


procedure TExchangeRatesfrm.eDateFromChange(Sender: TObject);
begin
   ReStartTimer;
end;

procedure TExchangeRatesfrm.eDateToDblClick(Sender: TObject);
var ld: Integer;
begin
   if sender is TOVcPictureField then begin
      ld := TOVcPictureField(Sender).AsStDate;
      PopUpCalendar(TEdit(Sender),ld);
      TOVcPictureField(Sender).AsStDate := ld;
   end;
   ReStartTimer;
end;


//*****************************************************************************
type
   OtherAddItemRec = record
      Range: TDateRange;
      TreeList: TTreeBaseList;
   end;

function AddItem(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
begin
    Result := true;
    with OtherAddItemRec(OtherData^) do begin
       if TExchangeRecord(Node.Data).Date < Range.FromDate then
          Exit;
       if TExchangeRecord(Node.Data).Date > Range.ToDate then
          Exit;
       TreeList.AddNodeItem(nil, TExchangeTreeItem.Create(TExchangeRecord(Node.Data)));
    end;
end;
//*****************************************************************************
procedure TExchangeRatesfrm.FillRates;
var
   i: integer;
   keep: TCursor;
   C: Integer;
   OtherData : OtherAddItemRec;

   function AddColumn(Name: string; Tag, Width: Integer; Draggable: boolean = true) : TVirtualTreeColumn;
   begin
       Result := vtRates.Header.Columns.Add;
       if not Draggable then
         Result.Options := Result.Options - [coDraggable, coShowDropMark];
       Result.Text := Name;
       Result.Tag := Tag;
       Result.Width := Width;

   end;

begin
   keep := Screen.Cursor;
   Screen.Cursor := crHourGlass;
   vtRates.BeginUpdate;
   try
      vtRates.Clear;
      FTreeList.Clear;

      if not FColumnOrderLoaded then begin
        vtRates.Header.Columns.Clear;
        // ReBuild the Columns
        AddColumn('S',Tag_Lock,20, false);
        AddColumn('Date',Tag_Date,80, false);
        vtRates.Header.Columns[1].Options := vtRates.Header.Columns[1].Options - [coShowDropMark];

        for C := low(FSource.Header.ehISO_Codes) to high(FSource.Header.ehISO_Codes) do
           if FSource.Header.ehISO_Codes[C] > '' then begin
              if FSource.Header.ehCur_Type[C] = ct_Base then
                 grpDetails.Items[0].Caption := format('Base currency: %s', [FSource.Header.ehISO_Codes[C]])
              else
                 AddColumn(FSource.Header.ehISO_Codes[C],-C,50);

           end else
              Break;
      end;

      // Add the items..
      OtherData.Range := MakeDateRange(FromDate, ToDate);
      OtherData.TreeList := FTreeList;
      FSource.Iterate(AddItem,True,@OtherData);

      //load column widths and positions
      if not FColumnOrderLoaded then begin
        FColumnOrderLoaded := True; //only do once
        for i := 0 to Pred(vtRates.Header.Columns.Count) do begin
          if PRACINI_ER_Column_Widths[i] <> -1 then
             vtRates.Header.Columns[i].Width := PRACINI_ER_Column_Widths[i];
          if PRACINI_ER_Column_Positions[i] <> -1 then
             vtRates.Header.Columns[i].Position := PRACINI_ER_Column_Positions[i];
        end;
      end;

   finally
      vtRates.EndUpdate;
      Screen.Cursor := Keep;
   end;
end;


procedure TExchangeRatesfrm.FormActivate(Sender: TObject);
begin
  FillRates;
end;

procedure TExchangeRatesfrm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
const
  CANCEL_PROMPT = 'If you cancel, the exchange rate information you have entered will be lost.'#13#13 +
                  'Are you sure you want to cancel and lose these changes?';
begin
  if (FChangeCount = 0) then //Recheck change count if cancel clicked or no changes when OK clicked
    FChangeCount := GetChangeCount;
  if not (ModalResult = mrOK) and (FChangeCount > 0) then
    CanClose := (AskYesNo('Cancel Maintain Exchange Rates', CANCEL_PROMPT, Dlg_No, 0) = DLG_YES);
end;

procedure TExchangeRatesfrm.FormCreate(Sender: TObject);
var
  LExchangeRates: TExchangeRateList;
begin
  // Common bits
  bkXPThemes.ThemeForm(Self);
  vtRates.Header.Font := Font;
  vtRates.Header.Height := Abs(vtRates.Header.Font.height) * 10 div 6;
  vtRates.DefaultNodeHeight := Abs(Self.Font.Height * 15 div 8); //So the editor fits

  RSGroupBar.GradientColorStop := bkBranding.GroupBackGroundStopColor;
  RSGroupBar.GradientColorStart := bkBranding.GroupBackGroundStartColor;

  FTreeList := TTreeBaseList.Create(vtRates);

  if Assigned( AdminSystem) then begin
    LExchangeRates := GetExchangeRates;
    try
      FSource :=  LExchangeRates.GiveMeSource('Master');
      AdminSystem.SyncCurrenciesToSystemAccounts;
      FSource.MapToHeader(AdminSystem.fCurrencyList);
    finally
      LExchangeRates.Free;
    end;
  end else if Assigned(myClient) then   //Books secure
    if Assigned(MyClient.ExchangeSource) then begin
      FSource :=  TExchangeSource.Create;
      FSource.Assign(MyClient.ExchangeSource);
      FBooksSecure := True;
    end;

  BKHelpSetUp(Self, BKH_Maintain_Exchange_Rates);
end;

procedure TExchangeRatesfrm.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to Pred(vtRates.Header.Columns.Count) do begin
    PRACINI_ER_Column_Widths[i] := vtRates.Header.Columns[i].Width;
    PRACINI_ER_Column_Positions[i] := vtRates.Header.Columns[i].Position;
  end;
  WritePracticeINI_WithLock;

  FreeAndNil(FSource);
  FreeAndNil(FTreeList);
end;

procedure TExchangeRatesfrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    Char(VK_ESCAPE):
      begin
        Key := #0;
        ModalResult := mrCancel;
      end;
  end;
end;

type
  TChangeCountRec = record
    ChangeCount: integer;
    ExchangeSource: TExchangeSource;
  end;

function ChangeDeleteCount(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  i: integer;
  ER1, ER2: TExchangeRecord;
  RateChange: boolean;
begin
  Result := true;
  RateChange := False;
  ER1 := TExchangeRecord(Node.Data);
  ER2 := TChangeCountRec(OtherData^).ExchangeSource.GetDateRates(ER1.FDate);
  if Assigned(ER2) then begin
    RateChange := False;
    for i := 1 to ER2.Width do begin
      if ER2.Rates[i] <> ER1.Rates[i] then begin
        //Rate edited
        Inc(TChangeCountRec(OtherData^).ChangeCount);
        RateChange := True;
      end;
    end;
    if not RateChange then
      if ER2.Locked <> ER1.Locked then
        //Lock changed
        Inc(TChangeCountRec(OtherData^).ChangeCount);
  end else
    for i := 1 to ER1.Width do
      if (ER1.Rates[i] <> 0) then //Base rate should always be 0
        //Delete
        Inc(TChangeCountRec(OtherData^).ChangeCount);
end;

function AddCount(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  i: integer;
  ER1, ER2: TExchangeRecord;
begin
  Result := true;
  ER1 := TExchangeRecord(Node.Data);
  ER2 := TChangeCountRec(OtherData^).ExchangeSource.GetDateRates(ER1.FDate);
  if not Assigned(ER2) then
    for i := 1 to ER1.Width do
      if (ER1.Rates[i] <> 0) then //Base rate should always be 0
        //Add
        Inc(TChangeCountRec(OtherData^).ChangeCount);
end;

function FullPeriodCount(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  i: integer;
  ER1, ER2: TExchangeRecord;
  RateChange: boolean;
begin
  Result := true;

  ER1 := TExchangeRecord(Node.Data);
  ER2 := TChangeCountRec(OtherData^).ExchangeSource.GetDateRates(ER1.FDate);

  if Assigned(ER2) then
  begin
    RateChange := False;

    for i := 1 to ER2.Width do
    begin
      if ER2.Rates[i] <> ER1.Rates[i] then
      begin
        //Rate edited

        if not IsPartialPeriod(ER2.Date) then
        begin
          Inc(TChangeCountRec(OtherData^).ChangeCount);
        end;

        RateChange := True;
      end;
    end;
    
    if not RateChange then
    begin
      if ER2.Locked <> ER1.Locked then
      begin
        //Lock changed
        
        if not IsPartialPeriod(ER2.Date) then
        begin
          Inc(TChangeCountRec(OtherData^).ChangeCount);
        end;
      end;
    end;
  end
  else
  begin
    for i := 1 to ER1.Width do
    begin
      if (ER1.Rates[i] <> 0) then //Base rate should always be 0
      begin
        //Delete
        
        if not IsPartialPeriod(ER1.Date) then
        begin
          Inc(TChangeCountRec(OtherData^).ChangeCount);
        end;
      end;
    end;
  end;
end;

function TExchangeRatesfrm.GetChangeCount: integer;
var
  ExchangeRates: TExchangeRateList;
  ExchangeSource: TExchangeSource;
  ChangeCountRec: TChangeCountRec;
begin
  Result := 0;

  ExchangeRates := GetExchangeRates;
  try
    if BooksSecure then
      ExchangeSource := MyClient.ExchangeSource
    else
      ExchangeSource := ExchangeRates.GetSource(FSource.Header.ehName);

    if Assigned(ExchangeSource) then begin
      ChangeCountRec.ChangeCount := 0;

      //Change and delete count
      ChangeCountRec.ExchangeSource := FSource;
      ExchangeSource.Iterate(ChangeDeleteCount, true, @ChangeCountRec);

      //Add count
      ChangeCountRec.ExchangeSource := ExchangeSource;
      FSource.Iterate(AddCount, true, @ChangeCountRec);

      Result := ChangeCountRec.ChangeCount;
    end;

  finally
    ExchangeRates.Free;
  end;
end;

function TExchangeRatesfrm.GetEditedDeletedCount: Integer;
var
  ExchangeRates: TExchangeRateList;
  ExchangeSource: TExchangeSource;
  ChangeCountRec: TChangeCountRec;
begin
  Result := 0;

  ExchangeRates := GetExchangeRates;
  try
    if BooksSecure then
      ExchangeSource := MyClient.ExchangeSource
    else
      ExchangeSource := ExchangeRates.GetSource(FSource.Header.ehName);

    if Assigned(ExchangeSource) then begin
      ChangeCountRec.ChangeCount := 0;

      //Change and delete count
      ChangeCountRec.ExchangeSource := FSource;
      ExchangeSource.Iterate(ChangeDeleteCount, true, @ChangeCountRec);
      
      Result := ChangeCountRec.ChangeCount;
    end;

  finally
    ExchangeRates.Free;
  end;
end;

function TExchangeRatesfrm.GetFromDate: tstDate;
begin
   Result := eDateFrom.AsStDate;
end;

function TExchangeRatesfrm.GetFullMonthEditedDeletedCount: Integer;
var
  ExchangeRates: TExchangeRateList;
  ExchangeSource: TExchangeSource;
  ChangeCountRec: TChangeCountRec;
begin
  Result := 0;

  ExchangeRates := GetExchangeRates;
  try
    if BooksSecure then
      ExchangeSource := MyClient.ExchangeSource
    else
      ExchangeSource := ExchangeRates.GetSource(FSource.Header.ehName);

    if Assigned(ExchangeSource) then begin
      ChangeCountRec.ChangeCount := 0;

      ChangeCountRec.ExchangeSource := FSource;
      ExchangeSource.Iterate(FullPeriodCount, true, @ChangeCountRec);

      Result := ChangeCountRec.ChangeCount;
    end;
  finally
    ExchangeRates.Free;
  end;
end;

function TExchangeRatesfrm.GetToDate: tstDate;
begin
    Result := eDateTo.AsStDate;
end;

function SetRateForMonth(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  FromDate, ToDate: integer;

  procedure RemoveDate(ADate: integer; Update: Boolean = True);
  var
    i: integer;
  begin
    if Update then
      for i := 1 to TSetForMonth(OtherData^).FExchangeRecord.Width do
        TExchangeRecord(Node.Data).Rates[i] := TSetForMonth(OtherData^).FExchangeRecord.Rates[i];
    if TSetForMonth(OtherData^).FDatesToAdd.IndexOf(Pointer(ADate)) <> -1 then
      TSetForMonth(OtherData^).FDatesToAdd.Delete(TSetForMonth(OtherData^).FDatesToAdd.IndexOf(Pointer(ADate)));
  end;

begin
  Result := true;

  FromDate := TSetForMonth(OtherData^).FRange.FromDate;
  ToDate := TSetForMonth(OtherData^).FRange.ToDate;

  if TExchangeRecord(Node.Data).Locked then begin
    RemoveDate(TExchangeRecord(Node.Data).FDate, False); //Can't set rates for a locked date
    Exit;
  end;
  if TExchangeRecord(Node.Data).Date < FromDate then
    Exit;
  if TExchangeRecord(Node.Data).Date > ToDate then
    Exit;

  RemoveDate(TExchangeRecord(Node.Data).FDate);
end;

procedure TExchangeRatesfrm.miSetForWholeMonthClick(Sender: TObject);
var
  i: integer;
  ExchangeRecord, NewExchangeRecord: TExchangeRecord;
  SetForMonth: TSetForMonth;
begin
  if Assigned(FSource) and Assigned(vtRates.FocusedNode) then begin
    //Use the selected rates for all days of the current month
    ExchangeRecord := TExchangeTreeItem(FTreeList.Items[vtRates.FocusedNode^.Index]).FExchangeRecord;
    SetForMonth := TSetForMonth.Create;
    try
      SetForMonth.SetRange(ExchangeRecord.FDate);
      SetForMonth.FExchangeRecord := ExchangeRecord;
      FSource.Iterate(SetRateForMonth, True, @SetForMonth);
      //Add missing dates
      for i := 0 to SetForMonth.FDatesToAdd.Count - 1 do begin
        NewExchangeRecord := TExchangeRecord.Create(0, ExchangeRecord.Width);
        NewExchangeRecord.Assign(ExchangeRecord);
        NewExchangeRecord.FDate := Integer(SetForMonth.FDatesToAdd[i]);
        NewExchangeRecord.Locked := False;
        FSource.ExchangeTree.Insert(NewExchangeRecord);
        FTreeList.AddNodeItem(nil, TExchangeTreeItem.Create(NewExchangeRecord));
      end;
    finally
      SetForMonth.Free;
    end;
    //vtRates.Invalidate;
    FillRates;
  end;
end;

procedure TExchangeRatesfrm.ReloadTimerTimer(Sender: TObject);
begin
   // Validate..
    ReloadTimer.Enabled := False;
    FillRates;
end;

procedure TExchangeRatesfrm.ReStartTimer;
begin
   ReloadTimer.Enabled := False;
   ReloadTimer.Enabled := True;
end;

procedure TExchangeRatesfrm.SetFromDate(const Value: tstDate);
begin
  eDateFrom.AsStDate := Value;
end;

procedure TExchangeRatesfrm.SetToDate(const Value: tstDate);
begin
  eDateTo.AsStDate := Value;
end;

procedure TExchangeRatesfrm.vtRatesColumnDblClick(Sender: TBaseVirtualTree;
  Column: TColumnIndex; Shift: TShiftState);
begin
  acEditExchangeRateExecute(Sender);
end;

procedure TExchangeRatesfrm.vtRatesContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  //Disable context popup if nothing selected
  if vtRates.SelectedCount = 0 then
    Handled := True;
end;

procedure TExchangeRatesfrm.vtRatesFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  acEditExchangeRate.Enabled := (vtRates.SelectedCount > 0) and
                                (not TExchangeTreeItem(FTreeList.Items[Node.Index]).FExchangeRecord.Locked);
end;

procedure TExchangeRatesfrm.vtRatesHeaderDragging(Sender: TVTHeader;
  Column: TColumnIndex; var Allowed: Boolean);
begin

end;

{ TExchangeTreeItem }

procedure TExchangeTreeItem.AfterPaintCell(const Tag: integer; Canvas: TCanvas;
  CellRect: TRect);
begin
   case Tag  of
   Tag_Lock : begin
          if FExchangeRecord.Locked then
           Canvas.Draw(CellRect.Left,CellRect.Top,  ImagesFrm.AppImages.imgLock.Picture.Bitmap);
      end;
   end;
end;

constructor TExchangeTreeItem.Create(aExchangeRecord: TExchangeRecord);
begin
  inherited Create(BKDate2Str(aExchangeRecord.Date) ,0);
  FExchangeRecord := aExchangeRecord;
end;

function TExchangeTreeItem.GetTagText(const Tag: Integer): string;
    function GetRateText(const Value: Double): string;
    begin
       Result := '';
       if IsNAN(Value) then
          Exit;
       if Value = 0.0 then
          Exit;
       Result := Format('%2.4f',[Value])
    end;
begin
  if Tag >=0 then
     case Tag  of
     Tag_Lock : Result := '';
     Tag_Date : Result := Title;
     end
  else begin
     // < 0, Must be a rate..
     if -Tag <= FExchangeRecord.Width + 1 then
        Result := GetRateText(FExchangeRecord.Rates[-Tag]);
  end;

end;

{ TSetForMonth }

constructor TSetForMonth.Create;
begin
  FDatesToAdd := TList.Create;
end;

destructor TSetForMonth.Destroy;
begin
  FreeAndNil(FDatesToAdd);
  inherited;
end;

procedure TSetForMonth.SetRange(ADate: integer);
var
  i: integer;
  DateTime: TDateTime;
begin
  DateTime := StDateToDateTime(ADate);
  FRange.FromDate := stDate.DateTimeToStDate(DateUtils.StartOfTheMonth(DateTime));
  FRange.ToDate := stDate.DateTimeToStDate(DateUtils.EndOfTheMonth(DateTime));
  //Make a list of dates for the month
  FDatesToAdd.Clear;
  for i := FRange.FromDate to FRange.ToDate do
    FDatesToAdd.Add(Pointer(i));
end;

end.
