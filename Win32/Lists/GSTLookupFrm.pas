unit GSTLookupFrm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:    GST Lookup Form

  Written:  Apr 2000
  Authors:  Matthew

  Purpose:  Display the GST Class table and select a GST Class.
            Sorted by GST Class Code ( ID ) or by Description

  Notes:
           Function LookUpGSTClass( Guess : String ): String;
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  Grids_ts, TSGrid, gstSL,
  OSFont;

type
  TfrmGSTLookup = class(TForm)
    Grid: TtsGrid;
    procedure GridCellLoaded(Sender: TObject; DataCol, DataRow: Integer;
      var Value: Variant);
    procedure GridRowChanged(Sender: TObject; OldRow, NewRow: Integer);
    procedure GridKeyPress(Sender: TObject; var Key: Char);
    procedure GridHeadingDown(Sender: TObject; DataCol: Integer);
    procedure GridDblClick(Sender: TObject);
    procedure GridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FDefaultSortOrder : tgsSortType;

    procedure DoNewSearch;
    procedure ShowHeadingArrows;

    function GetCurrentlySelectedItem : pgSRec;
    function IndexOf(aGSTID: ShortString; List : tgSList): integer;
    procedure ResortMaintainCurrentPos(NewSortOrder: tgsSortType);
  public
    { Public declarations }
    CurrentSearchKey  : ShortString;
    CurrentSortOrder  : tGSSortType;
    GSListByCode      : tGSList;
    GSListByDesc      : tGSList;
  end;

function LookUpGSTClass( Guess : String; AllowNoRate: boolean = false ): String;
function PickGSTClass(var GSTClassCode : String; AllowNoRate: boolean = false) : boolean;

//******************************************************************************
implementation
uses
   LogUtil,
   SysUtils,
   ImagesFrm,
   WinUtils,
   GenUtils,
   bkhelp,
   glConst,
   Globals,
   stStrs, bkXPThemes;

Const
   UnitName = 'GSTLookupFrm';
   DebugMe  : Boolean = False;

   CodeCol  = 1;
   DescCol  = 2;

{$R *.DFM}

//------------------------------------------------------------------------------

procedure TfrmGSTLookup.GridCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
const
   ThisMethodName = 'TfrmGSTLookup.GridCellLoaded';
Var
   GS : pGSRec;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   GS := nil;

   case CurrentSortOrder of
       GSSortByCode : GS := GSListByCode.GSRec_At( Pred( DataRow ) );
       GSSortByDesc : GS := GSListByDesc.GSRec_At( Pred( DataRow ) );
   end;

   Assert( Assigned( GS ), 'GS is NIL in '+ThisMethodName );

   with GS^ do Begin
      case DataCol of
         CodeCol  : Value := GS^.gSIDCode;
         DescCol  : Value := GS^.gSDesc;
      end;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmGSTLookup.GridDblClick(Sender: TObject);
const
   ThisMethodName = 'TfrmGSTLookup.GridDblClick';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   ModalResult := mrOK;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmGSTLookup.ShowHeadingArrows;
// Change the arrow markers on the grid heading depending on whic sort order is
// active.
const
   ThisMethodName = 'TfrmGSTLookup.ShowMarkers';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   case CurrentSortOrder of
      gSSortByCode :
         Begin
            Grid.Col[ CodeCol ].SortPicture := TSGrid.spDown;
            Grid.Col[ DescCol ].SortPicture := TSGrid.spNone;
         end;
      GSSortByDesc :
         Begin
            Grid.Col[ CodeCol ].SortPicture := TSGrid.spNone;
            Grid.Col[ DescCol ].SortPicture := TSGrid.spDown;
         end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmGSTLookup.GridHeadingDown(Sender: TObject; DataCol: Integer);
const
   ThisMethodName = 'TfrmGSTLookup.GridHeadingDown';
Var
   NewSortOrder : TGSSortType;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   NewSortOrder := CurrentSortOrder;
   case DataCol of
      CodeCol : NewSortOrder := gSSortByCode;
      DescCol : NewSortOrder := GSSortByDesc;
   end;
   if NewSortOrder <> CurrentSortOrder then
   begin { Change the order and return to the top }
      Screen.Cursor  := crHourGlass;
      CurrentSortOrder := NewSortOrder;
      ShowHeadingArrows;
      Grid.RefreshData( roBoth, rpNone );
      CurrentSearchKey    := '';
      Grid.CurrentDataRow := 1;
      Grid.PutCellInView( 1, 1 );
      Screen.Cursor := crDefault;
   end;

   UserINI_GST_Lookup_Sort_Column := Ord(CurrentSortOrder);

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//------------------------------------------------------------------------------

procedure TfrmGSTLookup.GridKeyPress( Sender: TObject; var Key: char );
//detect if current search key matches anything
const
   ThisMethodName = 'TfrmGSTLookup.GridKeyPress';
Var
   SaveSearchKey : ShortString;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if Key = #$0D then ModalResult := mrOK;
   if Key = #$1B then ModalResult := mrCancel;

   //Save search key so that know what original was
   SaveSearchKey := CurrentSearchKey;

   //if backspace press and length > 0 then delete last char
   if ( Key = #8 ) and ( Length(CurrentSearchKey) > 0) then begin
      CurrentSearchKey[0] := Pred( CurrentSearchKey[0]);
   end;

   //if valid char then add to search string
   if ( Key in [#32..#126]) then begin
      CurrentSearchKey := CurrentSearchKey + UpperCase( Key);
   end;

   //if search has changed then do search
   if ( SaveSearchKey <> CurrentSearchKey) then begin
      DoNewSearch;
      UserINI_GST_Lookup_Sort_Column := Ord(CurrentSortOrder);
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmGSTLookup.FormResize(Sender: TObject);
const
   ThisMethodName = 'TfrmGSTLookup.FormResize';
Var
   FixedWidth     : Integer;
   VScrollerWidth : Integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   VScrollerWidth := GetSystemMetrics( SM_CXVSCROLL );
   FixedWidth :=
      Grid.Col[ CodeCol  ].Width +
      VScrollerWidth;
   Grid.Col[ DescCol ].Width := ClientWidth - FixedWidth - 4;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmGSTLookup.FormShow( Sender: TObject );
const
   ThisMethodName = 'TfrmGSTLookup.FormShow';
Var
   FixedWidth     : Integer;                
   VScrollerWidth : Integer;
   InitialSearchBlank : boolean;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   InitialSearchBlank := ( CurrentSearchKey = '');
   VScrollerWidth := GetSystemMetrics( SM_CXVSCROLL );

   with Grid do
   Begin
      FixedWidth :=
        Col[ CodeCol  ].Width +
         VScrollerWidth;
      Col[ DescCol ].Width := ClientWidth - FixedWidth - 4;
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
procedure TfrmGSTLookup.FormCreate(Sender: TObject);
const
   ThisMethodName = 'TfrmGSTLookup.FormCreate';
   RowHeight = 18;
Var
   NonClientHeight : Integer;
   MaxNoRows       : Integer;
   MaxHeight       : Integer;
   ValidClasses    : integer;
   i               : integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   bkXPThemes.ThemeForm( Self);
   Grid.HeadingFont := Font;
   NonClientHeight := Height - ClientHeight;
   MaxHeight       := Round( Screen.WorkAreaHeight * 0.7 );
   MaxNoRows       := ( MaxHeight - NonClientHeight ) div RowHeight;

   ValidClasses := 0;
   with MyClient.clFields do begin
      for i := 1 to MAX_GST_CLASS do
         if ( clGST_Class_Codes[ i] <> '') and ( clGST_Class_Names[ i] <> '') then
            Inc( ValidClasses);
   end;

   if MaxNoRows > ValidClasses then
      MaxNoRows := Succ( ValidClasses );

   //add one extra row for dislay;
   Inc(MaxNoRows);

   Height  := NonClientHeight + ( MaxNoRows * RowHeight );
   Width   := Round( Screen.WorkAreaWidth * 0.4 ); if Width < 300 then Width := 300;
   Top     := ( Screen.WorkAreaHeight - Height ) div 2;
   Left    := ( Screen.WorkAreaWidth - Width ) div 2;

   Caption := 'Select '+ MyClient.TaxSystemNameUC + ' Class';

   // Set up Help Information

   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   Grid.Hint        := 'Highlight the '+ MyClient.TaxSystemNameUC +' Class you want, then press Enter';

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmGSTLookup.GridMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
   DisplayC, DisplayR : integer;
begin
   Grid.CellFromXY( x, y, DisplayC, DisplayR );
   if ( DisplayR = 0) then
      Grid.Cursor := crHandPoint
   else
      Grid.Cursor := crDefault;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmGSTLookup.DoNewSearch;
{ Called when the dialog is first loaded, or when anything is typed on the
  keyboad }
const
   ThisMethodName = 'TfrmGSTLookup.DoNewSearch';
Var
   NewSortOrder  : tGSSortType;
   SaveSearchKey : ShortString;
   CFound        : Boolean;
   DFound        : Boolean;
   FoundInBoth   : Boolean;
   FoundInNone   : Boolean;
   CRow          : Integer;
   DRow          : Integer;
   NewCFound     : Boolean;
   NewDFound     : Boolean;
   NewCRow       : Integer;
   NewDRow       : Integer;
   LastChar      : char;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if CurrentSearchKey = '' then
   begin { Reset }
      NewSortOrder := gSSortByCode;
      if CurrentSortOrder <> NewSortOrder then
      begin { Special Case }
         Screen.Cursor  := crHourGlass;
         CurrentSortOrder := NewSortOrder;
         ShowHeadingArrows;
         Grid.RefreshData( roBoth, rpNone );
         Screen.Cursor := crDefault;
      end;
      Grid.CurrentDataRow := 1;
      Grid.PutCellInView( 1, 1 );
      Exit;
   end;

   CFound := GSListByCode.HasMatch( CurrentSearchKey );
   CRow := Succ( GSListByCode.SearchFor( CurrentSearchKey ) );

   DFound := GSListByDesc.HasMatch( CurrentSearchKey );
   DRow := Succ( GSListByDesc.SearchFor( CurrentSearchKey ) );

   FoundInNone := ( not CFound ) and ( not DFound );

   SaveSearchKey := CurrentSearchKey;
   
   if FoundInNone then
   begin // Do we have a match on the last character?
      LastChar := CurrentSearchKey[ Length( CurrentSearchKey ) ];
      CurrentSearchKey[ 1 ] := LastChar;
      CurrentSearchKey[ 0 ] := #1;
      NewCFound := GSListByCode.HasMatch( CurrentSearchKey );
      NewCRow := Succ( GSListByCode.SearchFor( CurrentSearchKey ) );
      NewDFound := GSListByDesc.HasMatch( CurrentSearchKey );
      NewDRow := Succ( GSListByDesc.SearchFor( CurrentSearchKey ) );
      if NewCFound or NewDFound then
      Begin
         // Start a new search
         CFound := NewCFound; CRow := NewCRow;
         DFound := NewDFound; DRow := NewDRow;
      end
      else
         CurrentSearchKey := SaveSearchKey;
   end;
   
   FoundInBoth := CFound and DFound;
   FoundInNone := ( not CFound ) and ( not DFound );

   if ( FoundInBoth or FoundInNone ) then
     { Don't change the current sort order }
      NewSortOrder := CurrentSortOrder
   else
   if CFound then
      NewSortOrder := gSSortByCode
   else { DFound }
      NewSortOrder := GSSortByDesc;

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
      gSSortByCode : Grid.CurrentDataRow := CRow;
      GSSortByDesc : Grid.CurrentDataRow := DRow;
   end;
   Grid.PutCellInView( 1, Grid.CurrentDataRow );

   CurrentSearchKey := SaveSearchKey;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function LookUpGSTClass( Guess : String; AllowNoRate: boolean = false ): String;
Const
  ThisMethodName = 'LookUpChart';
Var
   LookUpDlg  : TfrmGSTLookup;
   i          : Integer;
   ByCodeList   : tGSList;
   ByDescList : tGSList;
   SelectedCode: String;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Result := '';

   //build temp list to check that something to show
   ByCodeList := tGSList.Create( gSSortByCode);
   byDescList := tGSList.Create( gSSortByDesc);
   try
      with MyClient.clFields do begin
         for i := 1 to MAX_GST_CLASS do begin
            if ( clGST_Class_Names[i]<>'' ) and ( clGST_Class_Codes[ i] <> '' ) then begin
               ByCodeList.Insert( NewGSRec( clGST_Class_Codes[ i], clGST_Class_Names[ i]));
               byDescList.Insert( NewGSRec( clGST_Class_Codes[ i], clGST_Class_Names[ i]));
            end;
         end;
      end;
   finally
      if ( ByCodeList.ItemCount = 0) or ( byDescList.ItemCount = 0) then begin
         ByCodeList.Free;
         ByCodeList := nil;
         byDescList.Free;
         ByDescList := nil;
      end;
   end;

   if ( ByCodeList = nil) then exit;

   //Add No Rate Items
   if AllowNoRate then
   begin
     ByCodeList.Insert( NewGSRec(' ', 'No Rate'));
     ByDescList.Insert( NewGSRec(' ', 'No Rate'));
   end;

   LookUpDlg := TfrmGSTLookup.Create(Application.Mainform);
   Try
      LookupDlg.GSListByCode  := ByCodeList;
      LookupDlg.GSListByDesc  := byDescList;

      with LookUpDlg.Grid do
      Begin
         Rows             := LookupDlg.GSListByCode.ItemCount;
         Cols             := 2;
         Align            := alClient;
         EditMode         := emNone;
         RowSelectMode    := rsSingle;
         RowMoving        := False;
         ColSelectMode    := csNone;
         ResizeCols       := rcNone;

         DefaultRowHeight := 18;

         HeadingAlignment := taLeftJustify;

         with Col[ CodeCol ] do
         Begin
            Alignment   := taLeftJustify;
            Heading     := 'ID';
            Visible     := True;
            Width       := 50;
            ControlType := ctText;
            SortPicture := TSGrid.spDown;
         end;

         with Col[ DescCol ] do
         Begin
            Alignment   := taLeftJustify;
            Heading     := 'Description';
            Visible     := True;
            Width       := 150;
            ControlType := ctText;
            SortPicture := TSGrid.spNone;
         end;
         if AllowNoRate then
          LookupDlg.Height := LookupDlg.Height + DefaultRowHeight;
         LookupDlg.CurrentSortOrder := GSSortByCode;

         if tgSSortType(UserINI_GST_Lookup_Sort_Column) = GSSortByDesc then
           LookupDlg.FDefaultSortOrder := gSSortByDesc
         else
           LookupDlg.FDefaultSortOrder := gSSortByCode;

         LookupDlg.CurrentSearchKey := UpperCase( Guess);
      end;

      If LookUpDlg.ShowModal = mrOK then
      begin
        if AllowNoRate then
        begin
          SelectedCode := LookupDlg.Grid.Cell[0,LookUpDlg.Grid.SelectedRows.First];
          if SelectedCode = ' ' then
          begin
            Result := ' ';
            Exit;
          end;

        end;
        case LookupDlg.CurrentSortOrder of
          gsSortByCode :
            begin
              for i := 0 to Pred( LookupDlg.GSListByCode.ItemCount ) do
                if LookUpDlg.Grid.RowSelected[ i+1 ] then
                 Result := LookUpDlg.GSListByCode.GSRec_At( i )^.gSIDCode;
            end;
          gsSortByDesc :
          begin
            for i := 0 to Pred( LookupDlg.GSListByDesc.ItemCount ) do
              if LookUpDlg.Grid.RowSelected[ i+1 ] then
               Result := LookUpDlg.GSListByDesc.GSRec_At( i )^.gSIDCode;
          end;
        end;
      end;
   Finally
      LookUpDlg.GSListByCode.Free;
      LookUpDlg.GSListByDesc.Free;
      LookUpDlg.Free;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
End;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function PickGSTClass(var GSTClassCode : String; AllowNoRate: boolean = false) : boolean;
Var
   NewGSTClass : String;
begin
   result := false;

   if not Assigned(MyClient) then exit;

   NewGSTClass := GSTLookupFrm.LookupGSTClass( GSTClassCode, AllowNoRate );
   if NewGSTClass <> '' then
   Begin
      Result := True;
      //using space to represent no rate, so replace space with empty
      if NewGSTClass <> ' ' then      
        GSTClassCode := NewGSTClass
      else
        GSTClassCode := '';
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmGSTLookup.GridRowChanged(Sender: TObject; OldRow,
  NewRow: Integer);
begin
   CurrentSearchKey := '';
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TfrmGSTLookup.IndexOf( aGSTID : ShortString; List : tgSList) : integer;
var
  i : integer;
begin
  result := -1;

  for i := List.First to List.Last do
    if list.gSRec_At(i).gSIDCode = aGSTID then
      result := i;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmGSTLookup.GetCurrentlySelectedItem: pgSRec;
begin
  result := nil;

  if ( GSListByCode.ItemCount = 0) or ( Grid.CurrentDataRow < 1) then
    exit;

  case CurrentSortOrder of
    gSSortByCode : result := GSListByCode.gSRec_At( Grid.CurrentDataRow - 1);
    gSSortByDesc : result := GSListByDesc.gSRec_At( Grid.CurrentDataRow - 1);
  end;
end;

procedure TfrmGSTLookup.ResortMaintainCurrentPos( NewSortOrder : tgsSortType);
var
  CurrentItem : pgSRec;
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
        gSSortByDesc : ItemIndex := IndexOf( CurrentItem.gSIDCode, GSListByDesc);
        gSSortByCode : ItemIndex := IndexOf( CurrentItem.gSIDCode, GSListByCode);
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



Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

