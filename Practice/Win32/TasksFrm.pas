unit TasksFrm;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, RzListVw, RzBckgnd, RzEdit, ExtCtrls,
  VirtualTrees, Grids_ts, TSGrid, ToDoListUnit, TSDateTimeDef, TSDateTime,
  TSMask, Mask, RzPanel, RzPopups, StdActns, Menus, ActnList,
  bkXPThemes,
  OsFont;

const
  BK_AFTERSHOW = (WM_USER + 2);

type
  TViewMode = ( vmAll, vmOpen);

type
  TfrmTasks = class(TForm)
    pnlButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Masks: TtsMaskDefs;
    pgToDo: TPageControl;
    tsToDo: TTabSheet;
    tsNotes: TTabSheet;
    pnlTasks: TPanel;
    pnlTasksFooter: TPanel;
    btnAdd: TButton;
    btnDelete: TButton;
    gdToDo: TtsGrid;
    pnlNotes: TPanel;
    memNotes: TRzMemo;
    pnlHeader: TPanel;
    lblClientName: TLabel;
    chkShowClosed: TCheckBox;
    btnReport: TButton;
    popEditMenu: TPopupMenu;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Delete1: TMenuItem;
    SelectAll1: TMenuItem;
    N1: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure gdToDoCellEdit(Sender: TObject; DataCol, DataRow: Integer;
      ByUser: Boolean);
    procedure gdToDoCellLoaded(Sender: TObject; DataCol, DataRow: Integer;
      var Value: Variant);
    procedure btnAddClick(Sender: TObject);
    procedure gdToDoButtonClick(Sender: TObject; DataCol,
      DataRow: Integer);
    procedure gdToDoEndCellEdit(Sender: TObject; DataCol, DataRow: Integer;
      var Cancel: Boolean);
    procedure gdToDoExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnDeleteClick(Sender: TObject);
    procedure gdToDoHeadingClick(Sender: TObject; DataCol: Integer);
    procedure gdToDoInvalidMaskValue(Sender: TObject; DataCol,
      DataRow: Integer; var Accept: Boolean);
    procedure chkShowClosedClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure gdToDoRowLoaded(Sender: TObject; DataRow: Integer);
    procedure btnReportClick(Sender: TObject);
    procedure bkAfterShow( var msg: TMessage ); message BK_AFTERSHOW;
    procedure FormShow(Sender: TObject);
    procedure gdToDoEnter(Sender: TObject);
    procedure gdToDoEditTextResized(Sender: TObject; ByUser: Boolean);
    procedure gdToDoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Cut1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
  private
    { Private declarations }
    VisibleToDoList : TList;
    FToDoList: TClientToDoList;
    FViewMode: TViewMode;
    FSortOrder: byte;
    FClientCode: string;
    procedure SetToDoList(const Value: TClientToDoList);
    procedure AddNewItem;
    procedure PopUpCalendar( aRect : TRect; var aDate : integer);
    function GridStr2Date(S: String): Integer;

    function ValidateLines : boolean;
    procedure SetViewMode(const Value: TViewMode);

    procedure SetRowFont( DataRow : integer);
    procedure SetSortOrder(const Value: byte);
    procedure SetClientCode(const Value: string);
    procedure SetHeightForRow(DataRow: integer);
  public
    { Public declarations }
    procedure LoadToDoList;

    property  ToDoList : TClientToDoList read FToDoList write SetToDoList;
    property  ViewMode : TViewMode read FViewMode write SetViewMode;
    property  SortOrder : byte read FSortOrder write SetSortOrder;
    property  ClientCode : string read FClientCode write SetClientCode;
  end;

//******************************************************************************
implementation

uses
  Clipbrd,
  bkDateUtils,
  BKHelp,
  WarningMoreFrm,
  Globals,
  AppUserObj,
  stDate,
  stDatest,
  Types,
  ReportDefs,
  RptAdmin;

{$R *.dfm}

const
  ColDateEntered  = 1;
  ColEnteredBy    = 2;
  ColDescription  = 3;
  ColReminderDate = 4;
  ColComplete     = 5;
  ColDateComplete = 6;

{ TfrmTasks }

procedure TfrmTasks.LoadToDoList;
var
  i : integer;
  Item : pClientToDoItem;
  IncludeItem : boolean;
begin
  gdToDo.BeginUpdate;
  try
    //clear existing list
    VisibleToDoList.Clear;

    if Assigned( FToDoList) then
    begin
      //Sort main list
      FToDoList.SortBy( FSortOrder);

      for i := 0 to FToDoList.Count - 1 do
      begin
        Item := FToDoList.ToDoItemAt( i);

        IncludeItem := ( not Item^.tdTemp_Deleted) and
                       (( FViewMode = vmAll) or (( FViewMode = vmOpen) and (Item^.tdDate_Completed = 0)));

        if IncludeItem then
          VisibleToDoList.Add( Item);
      end;
    end;

    //now set up grid
    gdToDo.Rows := VisibleToDoList.Count;
    for i := 1 to gdToDo.Rows do
      SetRowFont( i);

  finally
    gdToDo.EndUpdate;
  end;
end;

procedure TfrmTasks.SetToDoList(const Value: TClientToDoList);
begin
  FToDoList := Value;
end;

procedure TfrmTasks.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  BKHelpSetUp(Self, BKH_The_Client_Manager);
  gdToDo.HeadingFont := Font;
  VisibleToDoList := TList.Create;
  FViewMode       := vmAll;
  FSortOrder      := tdSortByDateEntered;

  //setup columns in grid
  gdToDo.Col[ ColComplete].ControlType    := ctCheck;
  gdToDo.Col[ ColComplete].CheckBoxValues := 'Y|N';

  gdToDo.Col[ ColDescription].MaxLength   := 80;
  gdToDo.Col[ ColDescription].WordWrap    := wwOn;
  gdToDo.Col[ ColDescription].Width       := 50;

  gdToDo.Col[ ColReminderDate].MaxLength  := 10;

  gdToDo.Col[ ColDateEntered].SortPicture := tsGrid.spDown;

  //set read only for columns
  gdToDo.Col[ ColDateEntered].ReadOnly := True;
  gdToDo.Col[ ColEnteredBy].ReadOnly := True;
  gdToDo.Col[ ColDateComplete].ReadOnly := True;

  if Screen.WorkAreaWidth < 750 then
    Width := Screen.WorkAreaWidth - 10;

  Left := ( Screen.WorkAreaWidth - Width) div 2;
  Top  := ( Screen.WorkAreaHeight - Height) div 2;
end;

procedure TfrmTasks.FormDestroy(Sender: TObject);
begin
  //don't free items as they are part of the main ToDoList
  VisibleToDoList.Free;
end;

function TfrmTasks.GridStr2Date( S : String ): Integer;
Var { Use the Raize library for this }
  DT : TDateTime;
Begin
  Result := 0;
  Try
    //DT := RzPopups.StrToDateEx( S );
   if not RzPopups.StrToDateEx( S, DT ) then exit;
  Except
    exit;
  end;
  If DT = 0 then exit;
  Result := DateTimeToStDate( DT );
end;

procedure TfrmTasks.gdToDoCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; ByUser: Boolean);
var
  Item : pClientToDoItem;
begin
  if ( DataRow >= 1 ) and ( DataRow <= VisibleToDoList.Count ) then
  begin
    Item := VisibleToDoList.Items[ DataRow - 1];

    case DataCol of
      ColComplete        :
        begin
          //change the date immediately so user can see change
          if gdToDo.CurrentCell.Value = 'Y' then
          begin
            Item^.tdDate_Completed := StDate.CurrentDate;

            if FViewMode = vmOpen then
            begin
              //reload immediately
              gdToDo.EndEdit( false);
              LoadToDoList;
              Exit;
            end;
          end
          else
            Item^.tdDate_Completed := 0;

          SetRowFont( DataRow);
          gdToDo.RowInvalidate( gdToDo.DisplayRownr[ DataRow]);
        end;
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmTasks.gdToDoEndCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
{
   The OnEndCellEdit event occurs at the end of a cell edit operation either
   when the user leaves the current cell, when the grid loses the focus or when
   the EndEdit method is called.
}
var
  Item : pClientToDoItem;
  TempDate : integer;
begin
  if ( DataRow >= 1 ) and ( DataRow <= VisibleToDoList.Count ) then
  begin
    Item := VisibleToDoList.Items[ DataRow - 1];

    case DataCol of
      ColDescription     : Item^.tdDescription := Trim( gdToDo.CurrentCell.Value);
      ColReminderDate    :
        begin
          TempDate := GridStr2Date( gdToDo.CurrentCell.Value);
          if TempDate > 0 then
            Item^.tdReminderDate := TempDate
          else
            Item^.tdReminderDate := 0;

          SetRowFont( DataRow);
          gdToDo.RowInvalidate( gdToDo.DisplayRownr[ DataRow]);
        end;
      ColComplete        :
        begin
          if gdToDo.CurrentCell.Value = 'Y' then
          begin
            Item^.tdDate_Completed := StDate.CurrentDate;
          end
          else
          begin
            Item^.tdDate_Completed := 0;
          end;

          if gdToDo.Rows > 0 then
          begin
            SetRowFont( DataRow);
            gdToDo.RowInvalidate( gdToDo.DisplayRownr[ DataRow]);
          end;
        end;
    end;

    Item^.tdTemp_Edited := DataCol in [ ColDescription, ColReminderDate, ColComplete];
  end;
end;

procedure TfrmTasks.gdToDoCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
var
  Item : pClientToDoItem;
begin
  if ( DataRow >= 1 ) and ( DataRow <= VisibleToDoList.Count ) then
  begin
    Item := VisibleToDoList.Items[ DataRow - 1];

    case DataCol of
      ColDateEntered     : Value := bkDate2Str( Item^.tdDate_Entered);
      ColEnteredBy       : Value := Item^.tdEntered_By;
      ColDescription     : Value := Item^.tdDescription;
      ColReminderDate    : Value := bkDate2Str( Item^.tdReminderDate);
      ColComplete        :
        begin
          if (Item^.tdDate_Completed <> 0) then
            Value := 'Y'
          else
            Value := 'N';
        end;
      ColDateComplete    : Value := bkDate2Str( Item^.tdDate_Completed);
    end;
  end;
end;

procedure TfrmTasks.AddNewItem;
var
  NewItem : pClientToDoItem;
begin
  gdToDo.BeginUpdate;
  try
    NewItem := FToDoList.AddToDoItem;
    NewItem^.tdDate_Entered  := StDate.CurrentDate;
    NewItem.tdTime_Entered   := StDate.CurrentTime;
    NewItem.tdEntered_By     := Globals.CurrUser.Code;
    NewItem.tdTemp_Edited    := True;

    LoadToDoList;
    gdToDo.Invalidate;
  finally
    gdtoDo.EndUpdate;
  end;
end;

procedure TfrmTasks.btnAddClick(Sender: TObject);
begin
  if not ValidateLines then
    exit;

  AddNewItem;

  //new items are added to the bottom of the list, reposition on new item
  gdToDo.CurrentDataCol := ColDescription;
  gdToDo.CurrentDataRow := gdToDo.Rows;
  gdToDo.TopRow         := gdToDo.CurrentDataRow;
  gdToDo.SetFocus;
end;

procedure TfrmTasks.PopUpCalendar( aRect : TRect; var aDate : integer);
var
  PopupPanel: TRzPopupPanel;
  Calendar: TRzCalendar;
  HiddenEdit : TEdit;
begin
  PopupPanel := TRzPopupPanel.Create( Self );
  try
    Calendar := TRzCalendar.Create( PopupPanel );
    Calendar.Parent := PopupPanel;
    PopupPanel.Parent := Self;
    PopupPanel.Font.Name := gdToDo.Font.Name;
    PopupPanel.Font.Color := gdToDo.Font.Color;

    Calendar.IsPopup := True;
    Calendar.Color := gdToDo.Color;
    Calendar.Elements := [ceYear,ceMonth,ceArrows,ceDaysOfWeek,ceFillDays,ceTodayButton,ceClearButton];
    Calendar.FirstDayOfWeek := fdowLocale;
    Calendar.Handle;

    if aDate <> 0 then
      Calendar.Date := StDate.StDateToDateTime( aDate);

    //Calendar.BorderOuter := fsFlat;
    Calendar.Visible := True;
    Calendar.OnClick := PopupPanel.Close;

    //create a hidden edit box to position the popup under, need to
    //move into position of the rect provided
    HiddenEdit := TEdit.Create( Self);
    HiddenEdit.Parent  := Self;
    HiddenEdit.Visible := False;
    HiddenEdit.BoundsRect := aRect;

    if PopupPanel.Popup( HiddenEdit) then
      if ( Calendar.Date <> 0 ) then
        aDate := StDate.DateTimeToStDate( Calendar.Date)
      else
        aDate := 0;
  finally
    PopupPanel.Free;
  end;
end;

procedure TfrmTasks.gdToDoButtonClick(Sender: TObject; DataCol, DataRow: Integer);
var
  R : TRect;
  P : TPoint;
  dCol, dRow : integer;
  aDate : integer;
begin
  //popup a date time selector underneath the cell
  dCol := gdToDo.DisplayColnr[ DataCol];
  dRow := gdtoDo.DisplayRownr[ DataRow];
  R := gdToDo.CellRect( dCol, dRow);
  P := gdtoDo.ClientToParent(R.TopLeft, Self);
  OffsetRect( R, ( P.X - R.Left), (  P.Y - R.Top));

  //get current value
  aDate := bkStr2Date( gdToDo.CurrentCell.Value);
  PopUpCalendar( R, aDate);
  //set current value
  if aDate <> -1 then
    gdToDo.CurrentCell.Value := BkDate2Str( aDate);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmTasks.gdToDoExit(Sender: TObject);
begin
  gdToDo.EndEdit( false);
  btnCancel.Cancel := true;
end;

procedure TfrmTasks.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  gdToDo.EndEdit( false);

  if ModalResult = mrOK then
  begin
    CanClose := false;

    if not ValidateLines then
      exit;

    //all tests passed
    CanClose := true;
  end;
end;

procedure TfrmTasks.btnDeleteClick(Sender: TObject);
//if the currently selected item(s) has an id then mark it as deleted but
//dont remove it from the list because it must be deleted from the disk image
var
  Item : pClientToDoItem;
  i    : integer;
  Index : integer;
begin
  gdToDo.EndEdit( false);
  gdToDo.BeginUpdate;
  try
    //select current row
    if gdToDo.CurrentDataRow > 0 then
      gdToDo.RowSelected[ gdToDo.CurrentDataRow] := true;

    for i := 1 to gdToDo.Rows do
    begin
      Item := VisibleToDoList.Items[ i - 1];
      if gdToDo.RowSelected[ i] then
      begin
        if Item.tdLRN <> 0 then
        begin
          Item.tdTemp_Edited  := true;
          Item.tdTemp_Deleted := true;
        end
        else
        begin
          //see if the item can be found in the full to do list and remove it
          Index := FToDoList.IndexOf( Item);
          if Index >= 0 then
          begin
            //free the memory for this item
            FToDoList.FreeAndNilItem( Index);
          end;
        end;
      end;
      //now remove all blank pointers from the list
      FToDoList.Pack;
    end;

    LoadToDoList;

    //deselect all rows
    for i := 1 to gdToDo.Rows do
      gdToDo.RowSelected[ i] := False;

    gdToDo.Invalidate;
  finally
    gdToDo.EndUpdate;
  end;
end;

function TfrmTasks.ValidateLines : boolean;
var
  i : integer;
  Item : pClientToDoItem;
begin
  result := true;
  //make sure each line has a description
  for i := 1 to gdToDo.Rows do
  begin
    Item := VisibleToDoList.Items[ i - 1];
    if Item^.tdDescription = '' then
    begin
      HelpfulWarningMsg( 'You must enter the action required for each task!', 0);
      pgToDo.ActivePage := tsToDo;

      gdToDo.CurrentDataCol := ColDescription;
      gdToDo.CurrentDataRow := gdToDo.Rows;
      gdToDo.TopRow         := gdToDo.CurrentDataRow;
      gdToDo.SetFocus;

      result := false;
      Exit;
    end;
  end;
end;

procedure TfrmTasks.SetViewMode(const Value: TViewMode);
begin
  FViewMode := Value;
end;

procedure TfrmTasks.SetRowFont(DataRow: integer);
var
  Item  : PClientToDoItem;
begin
  if ( DataRow >= 1 ) and ( DataRow <= FToDoList.Count ) then
  begin
    Item := VisibleToDoList.Items[ DataRow - 1];

    if Item^.tdDate_Completed <> 0 then
    begin
      gdToDo.RowParentFont[ DataRow ] := False;
      gdToDo.RowFont[ DataRow ].Style := [ fsStrikeOut ];
      gdToDo.RowFont[ DataRow ].Color := clDkGray;
    end
    else
    begin
      //item is not complete, show color based on date
      if ( Item^.tdReminderDate <> 0) and ( Item^.tdReminderDate < StDate.CurrentDate) then
      begin
        gdToDo.RowParentFont[ DataRow ] := False;
        gdToDo.RowFont[ DataRow ].Style := [];
        gdToDo.RowFont[ DataRow ].Color := clRed;
      end
      else
        gdToDo.RowParentFont[ DataRow ] := True;
    end;
  end;
end;

procedure TfrmTasks.SetSortOrder(const Value: byte);
begin
  FSortOrder := Value;
end;

procedure TfrmTasks.gdToDoHeadingClick(Sender: TObject; DataCol: Integer);
var
  NewSortOrder : integer;
  i            : integer;
begin
  gdToDo.EndEdit( false);
  if not ValidateLines then
    Exit;

  //change sort order
  case DataCol of
    ColEnteredBy     : NewSortOrder := tdSortByEnteredBy;
    ColDescription   : NewSortOrder := tdSortByDescription;
    ColReminderDate  : NewSortOrder := tdSortByReminderDate;
    ColComplete      : NewSortOrder := tdSortByDateCompleted;
    ColDateComplete  : NewSortOrder := tdSortByDateCompleted;
  else
    NewSortOrder := tdSortByDateEntered;
  end;

  gdToDo.BeginUpdate;
  try
    if NewSortOrder <> FSortOrder then
    begin
      FSortOrder := NewSortOrder;
      LoadToDoList;
    end
    else begin
      //reverse sort
    end;
    //update sort picture
    for i := 1 to gdToDo.Cols do
        gdToDo.Col[ i].SortPicture := tsGrid.spNone;

    gdToDo.Col[ DataCol].SortPicture := tsGrid.spDown;
  finally
    gdToDo.EndUpdate;
  end;
end;

procedure TfrmTasks.gdToDoInvalidMaskValue(Sender: TObject; DataCol,
  DataRow: Integer; var Accept: Boolean);
var
  S : string;
begin
  //this may be caused by a blank date
  if DataCol = ColReminderDate then
  begin
    S := gdToDo.CurrentCell.Value;
    if S = '' then
    begin
      Accept := true
    end
    else
      ShowMessage('Invalid Date Entered');
  end;
end;

procedure TfrmTasks.chkShowClosedClick(Sender: TObject);
begin
  if chkShowClosed.Checked then
    FViewMode := vmAll
  else
    FViewMode := vmOpen;

  LoadToDoList;
end;

procedure TfrmTasks.FormResize(Sender: TObject);
const
  MinColSize = 150;
var
  Value : integer;
  i     : integer;
begin
  Value := 0;
  for i := 1 to gdToDo.Cols do
    if (i <> ColDescription) then
      Value := Value + gdToDo.Col[i].Width;

  //test for minimum size
  if ((gdToDo.Width - Value) < MinColSize) then
    gdToDo.Col[ColDescription].Width := MinColSize
  else
    gdToDo.Col[ColDescription].Width := (gdToDo.ClientWidth - Value);
end;

procedure TfrmTasks.SetHeightForRow( DataRow : integer);
var
   mTH, cTH : Integer;
   i : Integer;
begin
   //set row height for cols with word wrap
   mTH := 0;
   For i := ColDateEntered to ColDateComplete do begin
      If ( gdToDo.Col[ i ].Visible) and ( gdToDo.Col[ i].WordWrap = wwOn) then begin
         cTH := gdToDo.CellTextHeight[ i, DataRow ];
         If cTH > mTH then mTH := cTH;
      end;
   end;
   if ( mth + 1) < ( gdToDo.DefaultRowHeight) then
      mth := gdToDo.defaultrowheight - 1;

   //make sure no more than 3 rows high
   if ( mth + 1) > ( 2 * gdToDo.DefaultRowHeight) then
      mth := ( 2 * gdToDo.DefaultRowHeight) -1;

   gdToDo.RowHeight[ DataRow ] := mTH + 4; //4 pixel gap between rows
end;

procedure TfrmTasks.gdToDoRowLoaded(Sender: TObject; DataRow: Integer);
begin
  //set row height for cols with word wrap
  SetHeightForRow( DataRow);
end;

procedure TfrmTasks.btnReportClick(Sender: TObject);
var LDest : TReportDest;
begin
  if not ValidateLines then
    exit;
  LDest := rdAsk;
  RPTADMIN.PrintTasksForClient( ClientCode, LDest, VisibleToDoList);
end;

procedure TfrmTasks.SetClientCode(const Value: string);
begin
  FClientCode := Value;
end;

procedure TfrmTasks.FormShow(Sender: TObject);
begin
  //Set default width and height
  Width   := Round( Screen.WorkAreaWidth * 0.9 );
  if Width > 800 then
    Width := 800;

  //Position window
  Left    := ( Screen.WorkAreaWidth - Width ) div 2;

  //After show
  PostMessage( Self.Handle, BK_AFTERSHOW, 0, 0);
end;

procedure TfrmTasks.bkAfterShow(var msg: TMessage);
begin
  if gdToDo.Rows > 0 then
    gdToDo.RowSelected[1] := true;

  if pgToDo.ActivePage = tsToDo then
    gdToDo.SetFocus
  else
    memNotes.SetFocus;
end;

procedure TfrmTasks.gdToDoEnter(Sender: TObject);
begin
  btnCancel.Cancel := false;
end;

procedure TfrmTasks.gdToDoEditTextResized(Sender: TObject;
  ByUser: Boolean);
begin
  if (ByUser) then
    //resize the height of the cell so that all the text is visible on screen
    SetHeightForRow(gdToDo.CurrentDataRow);
end;

procedure TfrmTasks.gdToDoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

   procedure ShowPopUp( x, y : Integer; PopMenu :TPopUpMenu );
   var
      ClientPt, ScreenPt : TPoint;
   begin
      ClientPt.x := x;
      ClientPt.y := y;
      ScreenPt   := gdToDo.ClientToScreen(ClientPt);
      PopMenu.Popup(ScreenPt.x, ScreenPt.y);
   end;
begin
  if (Button = mbRight) then
  begin
    if (gdToDo.CurrentDataCol = ColDescription) or (gdToDo.CurrentDataCol = ColReminderDate) then
    begin
      //disable menu options depending on SelStart and Sellength.
      ShowPopUp(X, Y, popEditMenu);
    end;
  end;
end;

procedure TfrmTasks.Cut1Click(Sender: TObject);
var
  sValue : String;
  CursorPos : Integer;
begin
  //store the values
  sValue := gdToDo.CurrentCell.Value;
  CursorPos := gdToDo.CurrentCell.SelStart;
  //copy the selected text to the clipboard
  Clipboard.AsText := Copy(sValue, gdToDo.CurrentCell.SelStart + 1, gdToDo.CurrentCell.SelLength);
  //remove the selected text from the text data
  gdToDo.CurrentCell.Value := Copy(sValue, 1, gdToDo.CurrentCell.SelStart) +
    Copy(sValue, gdToDo.CurrentCell.SelStart + gdToDo.CurrentCell.SelLength + 1, Length(sValue));

  //reset the cursor position
  if (CursorPos < Length(gdToDo.CurrentCell.Value)) then
    gdToDo.CurrentCell.SelStart := CursorPos
  else
    gdToDo.CurrentCell.SelStart := Length(gdToDo.CurrentCell.Value);

  gdToDo.CurrentCell.SelLength := 0;
end;

procedure TfrmTasks.Copy1Click(Sender: TObject);
begin
  //copy the selected text to the clipboard
  Clipboard.AsText := Copy(gdToDo.CurrentCell.Value, gdToDo.CurrentCell.SelStart + 1, gdToDo.CurrentCell.SelLength);
end;

procedure TfrmTasks.Paste1Click(Sender: TObject);
var
  sValue : String;
  CursorPos : Integer;
begin
  //store the values
  sValue := gdToDo.CurrentCell.Value;
  CursorPos := gdToDo.CurrentCell.SelStart;
  //copy the selected text from the clipboard into the text data
  gdToDo.CurrentCell.Value := Copy(sValue, 1, CursorPos) +
    Clipboard.AsText + Copy(sValue, CursorPos + 1, Length(sValue) - CursorPos);

  //reset the cursor position
  if (CursorPos < Length(gdToDo.CurrentCell.Value)) then
    gdToDo.CurrentCell.SelStart := CursorPos
  else
    gdToDo.CurrentCell.SelStart := Length(gdToDo.CurrentCell.Value);

  gdToDo.CurrentCell.SelLength := 0;
end;

procedure TfrmTasks.Delete1Click(Sender: TObject);
var
  sValue : String;
  CursorPos : Integer;
begin
  //store the values
  sValue := gdToDo.CurrentCell.Value;
  CursorPos := gdToDo.CurrentCell.SelStart;
  //remove the selected text from the text data
  gdToDo.CurrentCell.Value := Copy(sValue, 1, gdToDo.CurrentCell.SelStart) +
    Copy(sValue, gdToDo.CurrentCell.SelStart + gdToDo.CurrentCell.SelLength + 1, Length(sValue));

  //reset the cursor position
  if (CursorPos < Length(gdToDo.CurrentCell.Value)) then
    gdToDo.CurrentCell.SelStart := CursorPos
  else
    gdToDo.CurrentCell.SelStart := Length(gdToDo.CurrentCell.Value);

  gdToDo.CurrentCell.SelLength := 0;
end;

procedure TfrmTasks.SelectAll1Click(Sender: TObject);
begin
  gdToDo.CurrentCell.SelectAll;
end;

end.

