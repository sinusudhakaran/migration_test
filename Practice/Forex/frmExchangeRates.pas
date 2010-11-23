unit frmExchangeRates;

interface

uses
  Virtualtreehandler,
  ExchangeRateList,  stDate,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OsFont, ActnList, VirtualTrees, ExtCtrls, RzGroupBar, StdCtrls,
  ovcbase, ovcef, ovcpb, ovcpf, Menus;

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
  private
    FTreeList: TTreeBaseList;
    FSource: TExchangeSource;
    FChangeCount: integer;
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
  bkDateUtils,
  Globals,
  YesNoDlg,
  ErrorMoreFrm,
  bkBranding,
  ISO_4217,
  bkXPThemes,
  frmEditExchangeRate,
  InfoMoreFrm,
  DateUtils,
  IniSettings;


{$R *.dfm}


function MaintainExchangeRates: Boolean;
begin
   with TExchangeRatesfrm.Create(Application.MainForm) do try
      ToDate :=  CurrentDate;
      FromDate := GetFirstDayOfMonth(IncDate(CurrentDate, 0, -1, 0));
      FChangeCount := 0;

      Result := ShowModal = mrOK;
      if Result and (FChangeCount > 0) then
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

function LockRates(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
begin
   Result := true;
   if TExchangeRecord(Node.Data).Locked then
      Exit;
   if TExchangeRecord(Node.Data).Date < tDateRange(OtherData^).FromDate then
      Exit;
   if TExchangeRecord(Node.Data).Date > tDateRange(OtherData^).ToDate then
      Exit;
   TExchangeRecord(Node.Data).Locked := True;
end;

//*****************************************************************************
procedure TExchangeRatesfrm.acLockExecute(Sender: TObject);
var Range: tDateRange;
begin
   Range := MakeDateRange(FromDate,ToDate);
   FSource.Iterate(FindLocked,True,@Range);

   if not GetDateRange(Range, 'Lock Exchange Rate Period',
         'Enter the starting and finishing date for the period you want to lock.') then exit;

   FSource.Iterate(LockRates,True,@Range);
   vtRates.Invalidate;
end;



//*****************************************************************************
function FindUnLocked(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
begin
   Result := true;
   if TExchangeRecord(Node.Data).Locked then
      tDateRange(OtherData^).ToDate := TExchangeRecord(Node.Data).Date //Last UnLocked date
   else
     if ((TExchangeRecord(Node.Data).Date + 1) < tDateRange(OtherData^).ToDate) then
       tDateRange(OtherData^).FromDate := (TExchangeRecord(Node.Data).Date + 1) // Last Unlocked date
end;


type
  TUnlockRatesRec = record
    Range: TDateRange;
    UnLockCount: integer;
  end;

function UnLockRates(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  i: integer;
begin
   Result := true;
   if not TExchangeRecord(Node.Data).Locked then
      Exit;
   if TExchangeRecord(Node.Data).Date < TUnlockRatesRec(OtherData^).Range.FromDate then
      Exit;
   if TExchangeRecord(Node.Data).Date > TUnlockRatesRec(OtherData^).Range.ToDate then
      Exit;
   if TExchangeRecord(Node.Data).Locked then begin
     for i := 1 to TExchangeRecord(Node.Data).Width do
       if (TExchangeRecord(Node.Data).Rates[i] <> 0) then
         Inc(TUnlockRatesRec(OtherData^).UnLockCount);
     TExchangeRecord(Node.Data).Locked := False;
   end;
end;

//*****************************************************************************

procedure TExchangeRatesfrm.acUnlockExecute(Sender: TObject);
const
  UNLOCK_WARNING = 'If you edit the exchange rates BankLink Practice will ' +
                   'update the base amounts of coded transactions and journals ' +
                   'that are not transferred or finalised.'#13#13 +
                   'Are you sure you want to do this?';
var
  Range: tDateRange;
  UnlockRatesRec: TUnlockRatesRec;
begin
   Range := MakeDateRange(FromDate,ToDate);
   FSource.Iterate(FindUnLocked,True,@Range);

   if not GetDateRange(Range, 'Unlock Exchange Rate Period',
         'Enter the starting and finishing date for the period you want to unlock.') then exit;

   //Warning
   if AskYesNo('Unlock Exchange Rate Period', UNLOCK_WARNING, Dlg_No, 0) = DLG_YES then begin
     UnlockRatesRec.Range := Range;
     UnlockRatesRec.UnLockCount := 0;
     FSource.Iterate(UnLockRates,True,@UnlockRatesRec);
     vtRates.Invalidate;
     if (UnlockRatesRec.UnLockCount > 0) then
       HelpfulInfoMsg(Format('%d exchange rates have been unlocked',[UnlockRatesRec.UnLockCount]), 0)
     else
       HelpfulInfoMsg('There are no exchange rates to be unlocked in this period', 0)
   end;
end;


procedure TExchangeRatesfrm.BtnoKClick(Sender: TObject);
var
  LExchangeRates: TExchangeRateList;
begin
   // Validate..
   FChangeCount := GetChangeCount;

   LExchangeRates := GetExchangeRates(True);
   try
      FSource :=  LExchangeRates.MergeSource(FSource);
      LExchangeRates.Save;
      Modalresult := mrOk;
   finally
      LExchangeRates.Free;
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
      vtRates.Header.Columns.Clear;
      FTreeList.Clear;

      // ReBuild the Columns
      AddColumn('S',Tag_Lock,20, false);
      AddColumn('Date',Tag_Date,80, false);

      for C := low(FSource.Header.ehISO_Codes) to high(FSource.Header.ehISO_Codes) do
         if FSource.Header.ehISO_Codes[C] > '' then begin
            if FSource.Header.ehCur_Type[C] = ct_Base then
               grpDetails.Items[0].Caption := format('Base currency: %s', [FSource.Header.ehISO_Codes[C]])
            else
               AddColumn(FSource.Header.ehISO_Codes[C],-C,50);

         end else
            Break;

      // Add the items..
      OtherData.Range := MakeDateRange(FromDate, ToDate);
      OtherData.TreeList := FTreeList;
      FSource.Iterate(AddItem,True,@OtherData);

      //load column widths and positions
      for i := 0 to Pred(vtRates.Header.Columns.Count) do begin
        if PRACINI_ER_Column_Widths[i] <> -1 then
           vtRates.Header.Columns[i].Width := PRACINI_ER_Column_Widths[i];
        if PRACINI_ER_Column_Positions[i] <> -1 then
           vtRates.Header.Columns[i].Position := PRACINI_ER_Column_Positions[i];
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
  if FChangeCount = 0 then //Recheck change count if cancel clicked or no changes when OK clicked
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

   LExchangeRates := GetExchangeRates;
   try
      FSource :=  LExchangeRates.GiveMeSource('Master');
   finally
      LExchangeRates.Free;
   end;
   AdminSystem.SyncCurrenciesToSystemAccounts;
   FSource.MapToHeader(AdminSystem.fCurrencyList);
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

  FreeAndNil(FTreeList);
end;

function TExchangeRatesfrm.GetChangeCount: integer;
var
  i, j: integer;
  ExchangeTreeItem: TExchangeTreeItem;
  ExchangeRecord: TExchangeRecord;
  ExchangeSource: TExchangeSource;
  ExchangeRates: TExchangeRateList;
begin
  Result := 0;
  ExchangeRates := GetExchangeRates;
  try
    ExchangeSource := ExchangeRates.GetSource(FSource.Header.ehName);
    if Assigned(ExchangeSource) then begin
      for i := 0 to FTreeList.Count - 1 do begin
        ExchangeTreeItem := TExchangeTreeItem(FTreeList.Items[i]);
        ExchangeRecord := ExchangeSource.GetDateRates(ExchangeTreeItem.FExchangeRecord.Date);
        if Assigned(ExchangeRecord) then begin
          //Edits
          for j := 1 to ExchangeTreeItem.FExchangeRecord.Width do
            if (ExchangeRecord.Rates[j] <> ExchangeTreeItem.FExchangeRecord.Rates[j]) then
              Inc(Result);
          //Locks
          if (ExchangeRecord.Locked <> ExchangeTreeItem.FExchangeRecord.Locked) then begin
            for j := 1 to ExchangeTreeItem.FExchangeRecord.Width do
              if (ExchangeTreeItem.FExchangeRecord.Rates[j] <> 0) then
                Inc(Result);
          end;
        end else begin
          //Adds
          for j := 1 to ExchangeTreeItem.FExchangeRecord.Width do
            if (ExchangeTreeItem.FExchangeRecord.Rates[j] <> 0) then
              Inc(Result);
        end;
      end;
    end;
  finally
    ExchangeRates.Free;
  end;
end;

function TExchangeRatesfrm.GetFromDate: tstDate;
begin
   Result := eDateFrom.AsStDate;
end;

function TExchangeRatesfrm.GetToDate: tstDate;
begin
    Result := eDateTo.AsStDate;
end;

function SetRateForMonth(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  i: integer;
  SelectedDate: TDateTime;
  FromDate, ToDate: integer;
begin
  Result := true;

  SelectedDate := stDate.StDateToDateTime(TExchangeRecord(OtherData^).Date);
  FromDate := stDate.DateTimeToStDate(DateUtils.StartOfTheMonth(SelectedDate));
  ToDate := stDate.DateTimeToStDate(DateUtils.EndOfTheMonth(SelectedDate));

  if TExchangeRecord(Node.Data).Locked then
    Exit;
  if TExchangeRecord(Node.Data).Date < FromDate then
    Exit;
  if TExchangeRecord(Node.Data).Date > ToDate then
    Exit;

  for i := 1 to TExchangeRecord(OtherData^).Width do
    TExchangeRecord(Node.Data).Rates[i] := TExchangeRecord(OtherData^).Rates[i]
end;

procedure TExchangeRatesfrm.miSetForWholeMonthClick(Sender: TObject);
var
  ExchangeRecord: TExchangeRecord;
begin
  if Assigned(FSource) and Assigned(vtRates.FocusedNode) then begin
    //Use the selected rates for all days of the current month
    ExchangeRecord := TExchangeTreeItem(FTreeList.Items[vtRates.FocusedNode^.Index]).FExchangeRecord;
    FSource.Iterate(SetRateForMonth, True, @ExchangeRecord);
    vtRates.Invalidate;    
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

procedure TExchangeRatesfrm.vtRatesFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  acEditExchangeRate.Enabled := (vtRates.SelectedCount > 0) and
                                (not TExchangeTreeItem(FTreeList.Items[Node.Index]).FExchangeRecord.Locked);
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

end.
