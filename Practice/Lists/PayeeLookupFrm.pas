unit PayeeLookupFrm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   PayeeLookup form

  Written:
  Authors:

  Purpose:

  Notes:
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  Grids_ts, TSGrid, PYSL, Buttons, ExtCtrls, ActnList, StdCtrls,
  OSFont;

type
  TfrmPayeeLookup = class(TForm)
    Grid: TtsGrid;
    Panel1: TPanel;
    sbtnNewPayee: TSpeedButton;
    ActionList1: TActionList;
    actAddNewPayee: TAction;

    procedure GridCellLoaded(Sender: TObject; DataCol, DataRow: Integer;
      var Value: Variant);
    procedure GridHeadingDown(Sender: TObject; DataCol: Integer);
    procedure GridRowChanged(Sender: TObject; OldRow, NewRow: Integer);
    procedure GridKeyPress(Sender: TObject; var Key: Char);
    procedure GridDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure GridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure actAddNewPayeeExecute(Sender: TObject);
  private
    FDefaultSortOrder : tPYSSortType;

    function Execute( Guess : ShortString;
                      SelectMode : TtsRowSelectMode) : Integer;
    procedure ResizeForm;
    procedure DoNewSearch;
    procedure ShowHeadingArrows;

    procedure ResortMaintainCurrentPos( NewSortOrder : tPYSSortType);
    function GetCurrentlySelectedItem: TPYSObj;
    { Private declarations }
  public
    CurrentSearchKey  : ShortString;
    CurrentSortOrder  : tPYSSortType;
    PYSListByNo       : tPYSList;
    PYSListByName     : tPYSList;
    { Public declarations }
  end;

function LookUpPayee( Guess : ShortString): Integer;
function PickPayee(var PayeeCode : Integer) : Boolean;

//******************************************************************************
implementation

uses
  SysUtils,
  WinUtils,
  bkdefs,
  BkUtil32,
  bkXPThemes,
  bkhelp,
  imagesfrm,
  clObj32,
  ECollect,
  Globals,
  LogUtil,
  PayeeDetailDlg,
  PayeeObj;

Const
   UnitName = 'PayeeLookupFrm';
   DebugMe  : Boolean = False;

   NameCol = 2;
   NoCol   = 1;

{$R *.DFM}

//------------------------------------------------------------------------------
function TfrmPayeeLookup.Execute( Guess : ShortString;
                                  SelectMode : TtsRowSelectMode) : Integer;
begin
  with Grid do
  Begin
     Rows             := PYSListByName.ItemCount;
     Cols             := 2;
     Align            := alClient;
     EditMode         := emNone;
     RowSelectMode    := SelectMode;
     RowMoving        := False;
     ColSelectMode    := csNone;
     ResizeCols       := rcNone;

     DefaultRowHeight := 18;
     {Font.Size        := 11;
     Font.Name        := 'MS Sans Serif';
     Font.Style       := [];

     HeadingHeight    := 18;
     HeadingFont.Name := 'MS Sans Serif';
     HeadingFont.Size := 11;
     HeadingFont.Style:= [];}
     HeadingAlignment := taLeftJustify;

     with Col[ NameCol ] do
     Begin
        Alignment   := taLeftJustify;
        Heading     := 'Payee Name';
        Visible     := True;
        Width       := 200;
        ControlType := ctText;
        SortPicture := TSGrid.spDown;
     end;

     with Col[ NoCol ] do
     Begin
        Alignment   := taLeftJustify;
        Heading     := 'Number';
        Visible     := True;
        Width       := 80;
        ControlType := ctText;
        SortPicture := TSGrid.spNone;
     end;

     CurrentSortOrder := pysSortByNo;

     if tPYSSortType(UserINI_Payee_Lookup_Sort_Column) = pysSortByName then
       FDefaultSortOrder := PYSSortByName
     else
       FDefaultSortOrder := pysSortByNo;

     CurrentSearchKey := UpperCase( Guess );
     ShowHeadingArrows;
  end;
  Result := ShowModal;
end;

//------------------------------------------------------------------------------
procedure TfrmPayeeLookup.ResizeForm;
var
  NonClientHeight : Integer;
  MaxNoRows       : Integer;
  MaxHeight       : Integer;
begin
  //with Self do
  //begin
    NonClientHeight := Height - ClientHeight;
    MaxHeight       := Round( Screen.WorkAreaHeight * 0.7 );  // 70% of total screen height
    MaxNoRows       := ( MaxHeight - NonClientHeight ) div Grid.DefaultRowHeight;

    with MyClient do begin
      if MaxNoRows > clPayee_List.ItemCount then begin
        //box can show more lines than there are payees. so show number of items in list,
        //unless less than 6, in that case set max Rows to 6 ( 6 = 5 data rows + header)
        MaxNoRows := Succ( clPayee_List.ItemCount );
        if MaxNoRows < 6 then MaxNoRows := 6
      end;
    end;

    Height  := NonClientHeight + ( MaxNoRows * Grid.DefaultRowHeight ) + 4 + Panel1.Height;
    // form width is 40% of screen width or 300 units wide
    Width   := Round( Screen.WorkAreaWidth * 0.4 ); if Width < 300 then Width := 300;
  //end;
end;
//------------------------------------------------------------------------------
procedure TfrmPayeeLookup.GridCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
const
   ThisMethodName = 'TfrmPayeeLookup.GridCellLoaded';
Var
   PYS : TPYSObj;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   PYS := nil;

   case CurrentSortOrder of
       pysSortByName : PYS := PYSListByName.PYSObj_At( Pred( DataRow ) );
       pysSortByNo   : PYS := PYSListByNo.PYSObj_At( Pred( DataRow ) );
   end;

   Assert( Assigned( PYS ), 'PYS is NIL in '+ThisMethodName );

   case DataCol of
      NameCol : Value := PYS.pysPayee.pdName;
      NoCol   : Value := IntToStr( PYS.pysPayee.pdNumber );
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmPayeeLookup.ShowHeadingArrows;

// Change the arrow markers on the grid heading depending on whic sort order is
// active.

const
   ThisMethodName = 'TfrmPayeeLookup.ShowMarkers';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   case CurrentSortOrder of
      pysSortByName : 
         Begin
            Grid.Col[ NoCol ].SortPicture := TSGrid.spNone;
            Grid.Col[ NameCol ].SortPicture := TSGrid.spDown;
         end;
      pysSortByNo :
         Begin
            Grid.Col[ NoCol ].SortPicture := TSGrid.spDown;
            Grid.Col[ NameCol ].SortPicture := TSGrid.spNone;
         end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmPayeeLookup.GridHeadingDown(Sender: TObject; DataCol: Integer);
const
   ThisMethodName = 'TfrmPayeeLookup.GridHeadingDown';
Var
   NewSortOrder : tPYSSortType;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   NewSortOrder := CurrentSortOrder;
   case DataCol of
      NameCol : NewSortOrder := pysSortByName;
      NoCol   : NewSortOrder := pysSortByNo;
   end;
   if NewSortOrder <> CurrentSortOrder then
   begin { Change the order and return to the top }
      Screen.Cursor  := crHourGlass;
      CurrentSortOrder := NewSortOrder;
      ShowHeadingArrows;
      Grid.RefreshData( roBoth, rpNone );
      CurrentSearchKey    := '';
      if (Grid.Rows = 0) then
        Grid.CurrentDataRow := 0
      else
      begin
        Grid.CurrentDataRow := 1;
        Grid.PutCellInView( 1, 1 );
      end;
      Screen.Cursor := crDefault;
   end;

   //use this as the new default sort order
   UserINI_Payee_Lookup_Sort_Column := Ord(CurrentSortOrder);

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmPayeeLookup.GridDblClick(Sender: TObject);
const
   ThisMethodName = 'TfrmPayeeLookup.GridDblClick';
Var
   Ch : char;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Ch := #$0D;
   GridKeyPress( nil, Ch );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmPayeeLookup.GridKeyPress( Sender: TObject; var Key: char );
const
   ThisMethodName = 'TfrmPayeeLookup.GridKeyPress';
Var
   SaveSearchKey : ShortString;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if Key = #$0D then ModalResult := mrOK;
   if Key = #$1B then ModalResult := mrCancel;

   SaveSearchKey := CurrentSearchKey;

   if ( ( Key = #8 ) and ( CurrentSearchKey[0] > #0) ) then
   Begin
      CurrentSearchKey[ 0 ] := Pred( CurrentSearchKey[0] );
   end
   else
   if Key in [ #32..#126 ] then
   Begin
      CurrentSearchKey := CurrentSearchKey + UpCase( Key );
   end;
   if CurrentSearchKey <> SaveSearchKey then begin
       DoNewSearch;
       UserINI_Payee_Lookup_Sort_Column := Ord(CurrentSortOrder); // May have changed
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmPayeeLookup.DoNewSearch;

const
   ThisMethodName = 'TfrmPayeeLookup.DoNewSearch';

{ Called when the dialog is first loaded, or when anything is typed on the
  keyboad }

Var
   NewSortOrder  : tPYSSortType;
   SaveSearchKey : ShortString;
   NameFound     : Boolean;
   NoFound       : Boolean;
   FoundInBoth   : Boolean;
   FoundInNone   : Boolean;
   NameRow       : Integer;
   NoRow         : Integer;

   NewNameRow    : Integer;
   NewNoRow      : Integer;
   LastChar      : char;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if CurrentSearchKey = '' then
   begin { Reset }
      NewSortOrder := FDefaultSortOrder;
      if CurrentSortOrder <> NewSortOrder then
      begin { Special Case }
         Screen.Cursor  := crHourGlass;
         CurrentSortOrder := NewSortOrder;
         ShowHeadingArrows;
         Grid.RefreshData( roBoth, rpNone );
         Screen.Cursor := crDefault;
      end;
      if (Grid.Rows = 0) then
        Grid.CurrentDataRow := 0
      else
      begin
        Grid.CurrentDataRow := 1;
        Grid.PutCellInView( 1, 1 );
      end;
      Exit;
   end;

   NameRow := PYSListByName.HasMatch( CurrentSearchKey );
   NameFound := (NameRow >= 0);
   if (not NameFound) then
     NameRow := Succ( PYSListByName.SearchFor( CurrentSearchKey ) );

   NoRow := PYSListByNo.HasMatch( CurrentSearchKey );
   NoFound := (NoRow >= 0);
   if (not NoFound) then
     NoRow := Succ( PYSListByNo.SearchFor( CurrentSearchKey ) );

   FoundInNone := ( not NameFound ) and ( not NoFound );

   SaveSearchKey := CurrentSearchKey;
   
   if FoundInNone then
   begin // Do we have a match on the last character?
      LastChar := CurrentSearchKey[ Length( CurrentSearchKey ) ];
      CurrentSearchKey[ 1 ] := LastChar;
      CurrentSearchKey[ 0 ] := #1;

      NewNameRow := PYSListByName.HasMatch( CurrentSearchKey );
      if (NewNameRow = -1) then
        NewNameRow := Succ( PYSListByName.SearchFor( CurrentSearchKey ) );

      NewNoRow := PYSListByNo.HasMatch( CurrentSearchKey );
      if (NewNoRow = -1) then
        NewNoRow := Succ( PYSListByNo.SearchFor( CurrentSearchKey ) );

      if (NewNameRow >= 0) or (NewNoRow >= 0) then
      Begin
         // Start a new search
         NameFound := (NewNameRow >= 0); NameRow := NewNameRow;
         NoFound := (NewNoRow >= 0); NoRow := NewNoRow;
      end
      else
         CurrentSearchKey := SaveSearchKey;
   end;
   
   FoundInBoth := NameFound and NoFound;
   FoundInNone := ( not NameFound ) and ( not NoFound );

   if ( FoundInBoth or FoundInNone ) then
     { Don't change the current sort order }
      NewSortOrder := CurrentSortOrder
   else
   if NameFound then
      NewSortOrder := pysSortByName
   else { DFound }
      NewSortOrder := pysSortByNo;

   SaveSearchKey := CurrentSearchKey;

   if CurrentSortOrder <> NewSortOrder then
   begin
      Screen.Cursor  := crHourGlass;
      CurrentSortOrder := NewSortOrder;
      ShowHeadingArrows;
      Grid.RefreshData( roBoth, rpNone );
      Screen.Cursor := crDefault;
   end;

   case CurrentSortOrder of
      pysSortByName : Grid.CurrentDataRow := NameRow;
      pysSortByNo   : Grid.CurrentDataRow := NoRow;
   end;

   if (Grid.CurrentDataRow > 0) then
     Grid.PutCellInView( 1, Grid.CurrentDataRow );

   CurrentSearchKey := SaveSearchKey;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmPayeeLookup.GridRowChanged(Sender: TObject; OldRow,
  NewRow: Integer);
const
  ThisMethodName = 'TfrmAcctLookup.GridRowChanged';

begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   CurrentSearchKey := '';
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPayeeLookup.GridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
   DisplayC, DisplayR : integer;
begin
   Grid.CellFromXY( x, y, DisplayC, DisplayR );
   if ( DisplayR = 0) then
      Grid.Cursor := crHandPoint
   else
      Grid.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure TfrmPayeeLookup.FormResize(Sender: TObject);
const
   ThisMethodName = 'TfrmAcctLookup.FormResize';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Grid.Col[ NameCol ].Width := ClientWidth - Grid.Col[ NoCol  ].Width;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmPayeeLookup.FormShow(Sender: TObject);
const
   ThisMethodName = 'TfrmAcctLookup.FormShow';
var
   InitialSearchBlank : boolean;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   InitialSearchBlank := (CurrentSearchKey = '');
   with Grid do
   Begin
      Col[ NameCol ].Width := ClientWidth - Col[ NoCol  ].Width;
      SetFocus;
   end;
   DoNewSearch;
   ResortMaintainCurrentPos( FDefaultSortOrder);

   if InitialSearchBlank and (Grid.Rows > 0) then
   begin
     Grid.CurrentDataRow := 1;
     Grid.PutCellInView( 1, 1 );
   end;
   CurrentSearchKey := '';
   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmPayeeLookup.FormCreate(Sender: TObject);
const
   ThisMethodName = 'TfrmPayeeLookup.FormCreate';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  bkXPThemes.ThemeForm( Self);
  Grid.HeadingFont := Font;
  ResizeForm;
  Top     := ( Screen.WorkAreaHeight - Height ) div 2;
  Left    := ( Screen.WorkAreaWidth - Width ) div 2;

  Caption := 'Select a Payee';

  // Set up Help Information

  Self.ShowHint    := INI_ShowFormHints;
  Self.HelpContext := 0;

  BKHelpSetUp( Self, BKH_Coding_by_payee);

  Grid.Hint        := 'Highlight the payee you want, then press Enter';

  ImagesFrm.AppImages.Maintain.GetBitmap(MAINTAIN_INSERT_BMP, sbtnNewPayee.Glyph);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ReBuildLists( var SortByNoList : tPYSList; var SortByNameList : tPYSList; aClient : TClientObj);
//this routine builds the sorted list that are used by the lookup
//a sorted list must exist for each sort order
var
  i : integer;
begin
  if Assigned( SortByNameList) then
    SortByNameList.Free;

  SortByNameList := tPYSList.Create( PYSSortByName );

  if Assigned( SortByNoList) then
    SortByNoList.Free;

  SortByNoList := tPYSList.Create( PYSSortByNo );

    with aClient.clPayee_List do
      for i := First to Last do
      begin
        SortByNoList.Insert(NewPYSObj(Payee_At(i)));
        SortByNameList.Insert(NewPYSObj(Payee_At(i)));
      end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IndexOf( const aPayee : TPayee; List : tPYSList) : integer;
var
  i : integer;
begin
  result := -1;
  for i := List.First to List.Last do
    if List.PYSObj_At(i).PYSPayee = aPayee then
      Result := i;
end;
//------------------------------------------------------------------------------

function LookUpPayee( Guess : ShortString): Integer;
const
  ThisMethodName = 'LookUpPayee';
var
  LookUpDlg  : TfrmPayeeLookup;
  i          : Integer;
  NoList     : tPYSList;
  NameList   : tPYSList;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  Result := -1;

  NoList   := nil;
  NameList := nil;

  ReBuildLists( NoList, NameList, MyClient);

  //if NameList = nil then Exit; //removed 25/09/2002 [MJF]

  LookUpDlg := TfrmPayeeLookup.Create( Application.MainForm );
  try
    LookUpDlg.PYSListByName := NameList;
    LookUpDlg.PYSListByNo   := NoList;

    if (LookUpDlg.Execute(Guess, rsSingle) = mrOK) then
    begin
      case LookUpDlg.CurrentSortOrder of
        pysSortByName :
          Begin
            with LookUpDlg.PYSListByName do
              for i := 0 to Pred( ItemCount ) do if LookUpDlg.Grid.RowSelected[ i+1 ] then
                  Result := LookUpDlg.PYSListByName.PYSObj_At( i ).pysPayee.pdNumber;
          end;
        pysSortByNo :
          Begin
            with LookUpDlg.PYSListByNo do
              for i := 0 to Pred( ItemCount ) do if LookUpDlg.Grid.RowSelected[ i+1 ] then
                  Result := LookUpDlg.PYSListByNo.PYSObj_At( i ).pysPayee.pdNumber;
          end;
       end;
    end;
  finally
    if Assigned(LookUpDlg.PYSListByName ) then
    Begin
      LookUpDlg.PYSListByName.Free;
      LookUpDlg.PYSListByName := nil;
    end;
    if Assigned(LookUpDlg.PYSListByNo ) then
    Begin
      LookUpDlg.PYSListByNo.Free;
      LookUpDlg.PYSListByNo := nil;
    end;
    LookUpDlg.Free;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
End;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function PickPayee( var PayeeCode : Integer) : Boolean;
var
  Guess : ShortString;
  No : Integer;
begin
  Result := False;

  //if not HasPayees then exit; //removed 25/09/2002 [MJF]

  Guess := ''; if PayeeCode <> 0 then Str( PayeeCode, Guess );
  No := PayeeLookupFrm.LookUpPayee( Guess);

  if No > 0 then
  begin
    PayeeCode := No;
    Result := True;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmPayeeLookup.FormMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPayeeLookup.actAddNewPayeeExecute(Sender: TObject);
var
  NewPayee : TPayee;
  FoundAt  : integer;
  i        : integer;
begin
  //fire new payee dialog
  if AddPayee( NewPayee) then
  begin
    //freeze current drawing
    Grid.BeginUpdate;
    try
      //clear rows
      Grid.Rows := 0;
      //reload lists
      ReBuildLists( Self.PYSListByNo, Self.PYSListByName, MyClient);
      if Self.PYSListByNo = nil then
      begin
        ModalResult := mrCancel;
        Close;
      end;
      //reset row count
      Grid.Rows := Self.PYSListByName.ItemCount;
      //find new item in list
      FoundAt := -1;
      case Self.CurrentSortOrder of
         pysSortByName : FoundAt := IndexOf( NewPayee, PYSListByName);
         pysSortByNo   : FoundAt := IndexOf( NewPayee, PYSListByNo);
      end;
      //set row selected state
      for i := 1 to Grid.Rows do
        Grid.RowSelected[ i] := false;

      if ( FoundAt >= 0) and ( FoundAt < Grid.Rows) then
      begin
        Grid.RowSelected[ FoundAt + 1] := true;
        Grid.TopRow := FoundAt + 1;
      end;
      //allow drawing
    finally
      Grid.EndUpdate;
    end;
    //resize the window
    ResizeForm;
  end;
end;

procedure TfrmPayeeLookup.ResortMaintainCurrentPos( NewSortOrder : tPYSSortType);
var
  CurrentItem : TPysObj;
  ItemIndex : integer;
begin
  if CurrentSortOrder = NewSortOrder then
    exit;

  CurrentItem := GetCurrentlySelectedItem;
  ItemIndex := -1;

  Screen.Cursor  := crHourGlass;
  try
    CurrentSortOrder := NewSortOrder;
    ShowHeadingArrows;
    Grid.RefreshData( roBoth, rpNone );

    if CurrentItem <> nil then
    begin
      case CurrentSortOrder of
        pysSortByName : ItemIndex := IndexOf( CurrentItem.PYSPayee, PYSListByName);
        PYSSortByNo : ItemIndex := IndexOf( CurrentItem.PYSPayee, PYSListByNo);
      end;
    end;

    if ( ItemIndex >= 0) and ( ItemIndex < Grid.Rows) then
      Grid.CurrentDataRow := ItemIndex + 1
    else
      Grid.CurrentDataRow := 0;

    if (Grid.CurrentDataRow > 0) then
      Grid.PutCellInView( 1, Grid.CurrentDataRow );
  finally
    Screen.Cursor := crDefault;
  end;
end;


function TfrmPayeeLookup.GetCurrentlySelectedItem: TPYSObj;
begin
  result := nil;

  if ( PYSListByNo.ItemCount = 0 ) or ( Grid.CurrentDataRow < 1) then
    exit;

  case CurrentSortOrder of
    PYSSortByName : result := PYSListByName.PYSObj_At( Grid.CurrentDataRow - 1);
    PYSSortByNo : result := PYSListByNo.PYSObj_At( Grid.CurrentDataRow - 1);
  end;
end;

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

