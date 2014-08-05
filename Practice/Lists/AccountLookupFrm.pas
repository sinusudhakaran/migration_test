unit AccountLookupFrm;

(*

   Function LookUpChart( Guess : ShortString ): ShortString;

   Display the chart of accounts and select an account code.

   Returns '' if no account was selected, or an account code if an
   account was selected.

*)

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Grids_ts,
  TSGrid,
  CHSL,
  bkDefs,
  StdCtrls,
  ExtCtrls,
  OSFont,
  RzBHints;

//------------------------------------------------------------------------------
type
  TAcctFilterFunction = function(const pAcct : pAccount_Rec) : boolean;

  TfrmAcctLookup = class(TForm)
    Grid: TtsGrid;
    pnlBasic: TPanel;
    rbFull: TRadioButton;
    rbBasic: TRadioButton;
    btnRefreshChart: TButton;
    pnlRefreshChart: TPanel;

    procedure GridCellLoaded(Sender: TObject; DataCol, DataRow: Integer;
      var Value: Variant);
    procedure GridHeadingDown(Sender: TObject; DataCol: Integer);
    procedure GridRowChanged(Sender: TObject; OldRow, NewRow: Integer);
    procedure GridKeyPress(Sender: TObject; var Key: Char);
    procedure GridDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure rbFullClick(Sender: TObject);
    procedure rbBasicClick(Sender: TObject);
    procedure btnRefreshChartClick(Sender: TObject);
    procedure GridColResized(Sender: TObject; RowColnr: Integer);
  private
    FFilter: TAcctFilterFunction;
    FDefaultSortOrder : tchsSortType;
    FHasAlternativeCode: Boolean;
    fShowRefreshChart : boolean;
    fHasChartBeenRefreshed : boolean;

    procedure DoNewSearch(Startup: Boolean = False);
    procedure ShowHeadingArrows;
    procedure SetFilter(const Value: TAcctFilterFunction);

    procedure SetColumnSortOrder(aSortOrder : tCHSSortType);

    function GetCurrentlySelectedItem : pchsRec;
    function IndexOf( aAccountCode: ShortString; List : tchSList): integer;
    procedure ResortMaintainCurrentPos(NewSortOrder: tchsSortType);
    function ShowBasicChart: Boolean;
    procedure SetSize;
    procedure RefreshGrid;
    procedure SetHasAlternativeCode(const Value: Boolean);
    property HasAlternativeCode: Boolean read FHasAlternativeCode write SetHasAlternativeCode;
  public
    { Public declarations }

    CurrentSearchKey  : ShortString;
    CurrentSortOrder  : tCHSSortType;
    CHSListByCode     : TCHSList;
    CHSListByDesc     : TCHSList;
    CHSListByAltCode : TCHSList;

    property Filter : TAcctFilterFunction read FFilter write SetFilter;
    property ShowRefreshChart : boolean read fShowRefreshChart write fShowRefreshChart;
    property HasChartBeenRefreshed : boolean read fHasChartBeenRefreshed write fHasChartBeenRefreshed;
  end;

function  LookUpChart( Guess : ShortString; var aHasChartBeenRefreshed : boolean; FilterFunction : TAcctFilterFunction = nil; ShowOptions: Boolean = True; ShowRefreshChart : Boolean = True ): ShortString;
function  PickAccount( var AcctCode : string; var aHasChartBeenRefreshed : boolean; FilterFunction : TAcctFilterFunction = nil; ShowOptions: Boolean = True; ShowRefreshChart : Boolean = True  ) : boolean;
procedure PickCodeForEdit( Sender: TObject; FilterFunction : TAcctFilterFunction = nil; ShowOptions: Boolean = True; ShowRefreshChart : Boolean = True  );

//------------------------------------------------------------------------------
implementation
{$R *.DFM}

uses
  Software,
  math,
  bkConst,
  BKUtil32,
  CanvasUtils,
  GenUtils,
  Globals,
  ImagesFrm,
  bkHelp,
  LogUtil,
  SysUtils,
  WinUtils,
  chList32,
  bkXPThemes,
  MAINFRM;

Const
  UnitName = 'AccountLookupFrm';
  DebugMe  : Boolean = False;

  GlyphCol = 1;
  CodeCol  = 2;
  DescCol  = 3;
  AltCodeCol  = 4;

  Glyph    : TBitMap = nil;
  GlyphColWidth = 22;

//------------------------------------------------------------------------------
procedure TfrmAcctLookup.btnRefreshChartClick(Sender: TObject);
var
  DataRowIndex : integer;
  SelectedCode : string;
  FoundRowIndex : integer;
  SortOrder : tCHSSortType;
begin
  fHasChartBeenRefreshed := true;
  frmMain.DoMainFormCommand( mf_mcRefreshChart, Sender, true);

  if Grid.Rows > 0 then
    SelectedCode := Grid.Cell[2, Grid.CurrentDataRow]
  else
    SelectedCode := '';

  SortOrder := CurrentSortOrder;

  RefreshGrid;

  SetColumnSortOrder(SortOrder);

  if (Grid.Rows > 0) then
  begin
    if (SelectedCode = '') then
    begin
      Grid.CurrentDataRow := 1;
      Grid.PutCellInView( 2, 1 );
    end
    else
    begin
      FoundRowIndex := 0;
      for DataRowIndex := 1 to Grid.Rows do
      begin
        if Grid.Cell[2, DataRowIndex] = SelectedCode then
        begin
          FoundRowIndex := DataRowIndex;
          break;
        end;
      end;

      if FoundRowIndex > 0 then
      begin
        Grid.CurrentDataRow := FoundRowIndex;
        Grid.PutCellInView( 2, FoundRowIndex );
      end
      else
      begin
        Grid.CurrentDataRow := 1;
        Grid.PutCellInView( 2, 1 );
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmAcctLookup.GridCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
const
   ThisMethodName = 'TfrmAcctLookup.GridCellLoaded';
Var
   CHS : pCHSRec;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   CHS := nil;

   case CurrentSortOrder of
       chsSortByCode : CHS := CHSListByCode.CHSRec_At( Pred( DataRow ) );
       chsSortByDesc : CHS := CHSListByDesc.CHSRec_At( Pred( DataRow ) );
       chsSortByAltCode : CHS := CHSListByAltCode.CHSRec_At( Pred( DataRow ) );
   end;

   Assert( Assigned( CHS ), 'CHS is NIL in '+ThisMethodName );
   
   with CHS^.chsAccount_Ptr^ do
   Begin
      case DataCol of
         GlyphCol :
           begin
             if not chPosting_Allowed then
             Value := BitMapToVariant( Glyph );
           end;

         CodeCol  : Value := CHS^.chsAccount_Ptr^.chAccount_Code;
         DescCol  : Value := CHS^.chsAccount_Ptr^.chAccount_Description;
         AltCodeCol  : Value := CHS^.chsAccount_Ptr^.chAlternative_Code ;
      end;
   end;
   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

procedure TfrmAcctLookup.GridColResized(Sender: TObject; RowColnr: Integer);
begin
  Grid.Col[GlyphCol].Width := GlyphColWidth;
end;

//------------------------------------------------------------------------------

procedure TfrmAcctLookup.ShowHeadingArrows;

// Change the arrow markers on the grid heading depending on whic sort order is
// active.

const
   ThisMethodName = 'TfrmAcctLookup.ShowMarkers';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   case CurrentSortOrder of
      chsSortByCode :
         Begin
            Grid.Col[ CodeCol ].SortPicture := TSGrid.spDown;
            Grid.Col[ DescCol ].SortPicture := TSGrid.spNone;
            if FHasAlternativeCode then
               Grid.Col[ AltCodeCol ].SortPicture := TSGrid.spNone;

         end;
      chsSortByDesc : 
         Begin
            Grid.Col[ CodeCol ].SortPicture := TSGrid.spNone;
            Grid.Col[ DescCol ].SortPicture := TSGrid.spDown;
            if FHasAlternativeCode then
               Grid.Col[ AltCodeCol ].SortPicture := TSGrid.spNone;
         end;
       chsSortByAltCode :
         Begin
            Grid.Col[ AltCodeCol ].SortPicture := TSGrid.spDown;
            Grid.Col[ CodeCol ].SortPicture := TSGrid.spNone;
            Grid.Col[ DescCol ].SortPicture := TSGrid.spNone;
         end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmAcctLookup.GridHeadingDown(Sender: TObject; DataCol: Integer);
const
  ThisMethodName = 'TfrmAcctLookup.GridHeadingDown';
var
  NewSortOrder : TCHSSortType;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  NewSortOrder := CurrentSortOrder;
  case DataCol of
    CodeCol : NewSortOrder := chsSortByCode;
    DescCol : NewSortOrder := chsSortByDesc;
    AltCodeCol : NewSortOrder := chsSortByAltCode;
  end;

  SetColumnSortOrder(NewSortOrder);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmAcctLookup.GridDblClick(Sender: TObject);
const
   ThisMethodName = 'TfrmAcctLookup.GridDblClick';
Var
   Ch : char;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Ch := #$0D;
   GridKeyPress( nil, Ch );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmAcctLookup.GridMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
   DisplayC, DisplayR : integer;
begin
   Grid.CellFromXY( x, y, DisplayC, DisplayR );
   if ( DisplayR = 0) and ( DisplayC > 1) then
      Grid.Cursor := crHandPoint
   else
      Grid.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure TfrmAcctLookup.GridKeyPress( Sender: TObject; var Key: char );
const
   ThisMethodName = 'TfrmAcctLookup.GridKeyPress';
Var
   i             : Integer;
   SaveSearchKey : ShortString;
   pCH           : pCHSRec;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if Key = #$0D then 
   Begin
      i := Grid.CurrentDataRow;
      if ( i > 0 ) and ( i<= CHSListByCode.ItemCount ) then
      Begin
         pCH := nil;
         case CurrentSortOrder of
            chsSortByCode : with CHSListByCode do pCH := CHSRec_At( Pred( i ) );
            chsSortByDesc : with CHSListByDesc do pCH := CHSRec_At( Pred( i ) );
            chsSortByAltCode : with CHSListByAltCode do pCH := CHSRec_At( Pred( i ) );
         end;
         if not pCH^.chsAccount_Ptr^.chPosting_Allowed then 
         Begin
            WinUtils.ErrorSound;
            Key := #0;
            Exit;
         end;
         ModalResult := mrOK;
      end;
   end;
   
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
      UserINI_Chart_Lookup_Sort_Column := Ord(CurrentSortOrder);
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------
procedure TfrmAcctLookup.DoNewSearch(Startup: Boolean = False);
const
   ThisMethodName = 'TfrmAcctLookup.DoNewSearch';

{ Called when the dialog is first loaded, or when anything is typed on the
  keyboad }

Var
   NewSortOrder  : tchsSortType;
   SaveSearchKey : ShortString;
   CFound,
   DFound,
   AFound        : Boolean;
   FoundInBoth   : Boolean;
   FoundInNone   : Boolean;
   CRow,
   DRow,
   ARow          : Integer;
   NewCRow,
   NewDRow,
   NewARow       : Integer;
   LastChar      : char;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if CurrentSearchKey = '' then
   begin { Reset }
      NewSortOrder := chsSortByCode;
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

   CRow := CHSListByCode.HasMatch( CurrentSearchKey );
   CFound := (CRow >= 0);
   if (not CFound) then
     CRow := Succ( CHSListByCode.SearchFor( CurrentSearchKey ) );

   DRow := CHSListByDesc.HasMatch( CurrentSearchKey );
   DFound := (DRow >= 0);
   if (not DFound) then
     DRow := Succ( CHSListByDesc.SearchFor( CurrentSearchKey ) );

   ARow := -1;
   if FHasAlternativeCode then begin
     ARow := CHSListByAltCode.HasMatch( CurrentSearchKey );
     AFound := (ARow >= 0);
     if (not AFound) then
       ARow := Succ( CHSListByAltCode.SearchFor( CurrentSearchKey ) );
   end else
      AFound := false;

   FoundInNone := (not CFound)
              and (not DFound)
              and (not AFound);

   SaveSearchKey := CurrentSearchKey;

   if FoundInNone then
   begin // Do we have a match on the last character?
      LastChar := CurrentSearchKey[ Length( CurrentSearchKey ) ];
      CurrentSearchKey[ 1 ] := LastChar;
      CurrentSearchKey[ 0 ] := #1;

      NewCRow := CHSListByCode.HasMatch( CurrentSearchKey );
      if (NewCRow = -1) then
        NewCRow := Succ( CHSListByCode.SearchFor( CurrentSearchKey ) );

      NewDRow := CHSListByDesc.HasMatch( CurrentSearchKey );
      if (NewDRow = -1) then
        NewDRow := Succ( CHSListByDesc.SearchFor( CurrentSearchKey ) );

      if FHasAlternativeCode then begin
         NewARow := CHSListByAltCode.HasMatch( CurrentSearchKey );
         if (NewARow = -1) then
            NewARow := Succ( CHSListByAltCode.SearchFor( CurrentSearchKey ) );
      end else begin
         NewARow := -1;
      end;

      if (NewCRow >= 0)
      or (NewDRow >= 0)
      or (NewARow >=0) then
      Begin
         // Start a new search
         CFound := (NewCRow >= 0);
         CRow := NewCRow;
         DFound := (NewDRow >= 0);
         DRow := NewDRow;
         AFound := (NewARow >= 0);
         ARow := NewARow

      end
      else
         CurrentSearchKey := SaveSearchKey;
   end;

   FoundInBoth := CFound
               and DFound
               and AFound;
   FoundInNone := (not CFound)
               and (not DFound)
               and (not AFound);

   NewSortOrder := CurrentSortOrder;
   if ( FoundInBoth or FoundInNone ) then
     { Don't change the current sort order }
      NewSortOrder := CurrentSortOrder
   else
   if CFound then
      NewSortOrder := chsSortByCode
   else if DFound  then
      NewSortOrder := chsSortByDesc
   else if FHasAlternativeCode then
      NewSortOrder := chsSortByAltCode;

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
      chsSortByCode : Grid.CurrentDataRow := CRow;
      chsSortByDesc : Grid.CurrentDataRow := DRow;
      chsSortByAltCode : Grid.CurrentDataRow := ARow;
   end;

   if (Grid.CurrentDataRow > 0) then
     Grid.PutCellInView( 1, Grid.CurrentDataRow );

   CurrentSearchKey := SaveSearchKey;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
   
//------------------------------------------------------------------------------

procedure TfrmAcctLookup.GridRowChanged(Sender: TObject; OldRow,
  NewRow: Integer);
const
  ThisMethodName = 'TfrmAcctLookup.GridRowChanged';
     
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   CurrentSearchKey := '';
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmAcctLookup.FormResize(Sender: TObject);
const
   ThisMethodName = 'TfrmAcctLookup.FormResize';
Var
   FixedWidth     : Integer;
   VScrollerWidth : Integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   VScrollerWidth := GetSystemMetrics( SM_CXVSCROLL );
   FixedWidth := 
      Grid.Col[ GlyphCol ].Width +
      Grid.Col[ CodeCol  ].Width +
      VScrollerWidth;

   if FHasAlternativeCode then
      inc(FixedWidth,  Grid.Col[AltCodeCol].Width);
      
   Grid.Col[ DescCol ].Width := ClientWidth - FixedWidth - 4;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmAcctLookup.FormShow(Sender: TObject);
const
  ThisMethodName = 'TfrmAcctLookup.FormShow';
  HINT_CHART_IS_LOCKED = 'Chart is locked';
Var
  InitialSearchBlank : boolean;
  NotRestrictedUser : boolean;
  RefresChartShown : boolean;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if Assigned( CurrUser) then
    NotRestrictedUser := not CurrUser.HasRestrictedAccess
  else
    NotRestrictedUser := true;

  RefresChartShown := NotRestrictedUser and
                      CanRefreshChart(MyClient.clFields.clCountry,
                                      MyClient.clFields.clAccounting_System_Used);

  if (RefresChartShown) and (ShowRefreshChart) then
  begin
    if MyClient.clFields.clChart_Is_Locked then
    begin
      btnRefreshChart.visible := false;
      pnlRefreshChart.visible := true;
      pnlRefreshChart.Hint := HINT_CHART_IS_LOCKED;
    end
    else
      btnRefreshChart.Enabled := true;
  end
  else
    btnRefreshChart.visible := false;

  InitialSearchBlank := (CurrentSearchKey = '');

  FormResize(self);
  DoNewSearch(True);

  ResortMaintainCurrentPos( FDefaultSortOrder);
  if InitialSearchBlank then
  begin
    //reposition at top of list
    if Grid.Rows > 0 then
    begin
      Grid.CurrentDataRow := 1;
      Grid.PutCellInView( 1, 1 );
    end;
  end;
  CurrentSearchKey := '';

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmAcctLookup.FormCreate(Sender: TObject);
const
  ThisMethodName = 'TfrmAcctLookup.FormCreate';
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  fHasChartBeenRefreshed := false;
  Grid.HeadingFont := Font;
  bkXPThemes.ThemeForm( Self);
  HasAlternativeCode :=
    HasAlternativeChartCode(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used);

  SetSize;
  if not Assigned( Glyph ) then
  Begin
    Glyph   := TBitMap.Create;
    ImagesFrm.AppImages.Maintain.GetBitmap( MAINTAIN_LOCK_BMP, Glyph );
  end;

  Caption := 'Select an Account';

  // Set up Help Information

  Self.ShowHint    := INI_ShowFormHints;
  Self.HelpContext := 0;
  Grid.Hint        := 'Highlight the account you want, then press Enter';

  if Assigned(AdminSystem) then
  begin
    // Have admin system so just use the Clientfile..
    rbBasic.Checked := MyClient.clFields.clUse_Basic_Chart;
  end
  else
  begin
    // Books, Always Basic
    pnlBasic.Visible := False;
    rbBasic.Checked := True;
  end;

  BKHelpSetUp( Self, BKH_Chart_look_up);

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

Function LookUpChart( Guess : ShortString; var aHasChartBeenRefreshed : boolean; FilterFunction : TAcctFilterFunction = nil; ShowOptions: Boolean = True ; ShowRefreshChart : Boolean = True ): ShortString;

Const
  ThisMethodName = 'LookUpChart';
Var
   LookUpDlg  : TfrmAcctLookup;
   i           : Integer;
   TempListC,
   TempListD,
   TempListA  : TCHSList;
   IncludeAccount : boolean;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Result := '';

   LookUpDlg := TfrmAcctLookup.Create(Application.MainForm);
   Try
     LookUpDlg.ShowRefreshChart := ShowRefreshChart;
      //set filter function if specified
      LookupDlg.Filter := FilterFunction;
      if not ShowOptions then
        LookupDlg.pnlBasic.Visible := False;
      //load lists
      TempListC := tCHSList.Create( chsSortByCode );
      TempListD := tCHSList.Create( chsSortByDesc );
      TempListA := tCHSList.Create( chsSortByAltCode );
      Try
        TempListC.Use_Xlon_Sort_Order := UseXlonSort;

         with MyClient.clChart do
            for i := 0 to Pred( ItemCount ) do
            Begin
               if Assigned(LookUpDlg.Filter) then begin
                 IncludeAccount := LookUpDlg.Filter(Account_At(i));
               end
               else
                 IncludeAccount := true;

               if Account_At(i).chHide_In_Basic_Chart and LookupDlg.ShowBasicChart then
                Continue;

               if IncludeAccount then begin
                 TempListC.Insert( NewCHSRec( Account_At( i ) ) );
                 TempListD.Insert( NewCHSRec( Account_At( i ) ) );
                 TempListA.Insert( NewCHSRec( Account_At( i ) ) );
               end;
            end;
      Finally
         if TempListC.ItemCount = 0 then
         Begin
            TempListC.Free;
            TempListC := nil;
         end;
         if TempListD.ItemCount = 0 then
         Begin
            TempListD.Free;
            TempListD := nil;
         end;
         if TempListA.ItemCount = 0 then
         Begin
            TempListA.Free;
            TempListA := nil;
         end;
      end;
      if ( TempListC = nil )
      or ( TempListD = nil )
      or ( TempListA = nil )then
         Exit;

      LookUpDlg.CHSListByCode := TempListC;
      LookUpDlg.CHSListByDesc := TempListD;
      LookUpDlg.CHSListByAltCode := TempListA;

      LookupDlg.rbBasic.OnClick := LookupDlg.rbBasicClick;
      LookupDlg.rbFull.OnClick := LookupDlg.rbFullClick;

      with LookUpDlg.Grid do
      Begin
         Rows             := LookUpDlg.CHSListByCode.ItemCount;

         Align            := alClient;
         EditMode         := emNone;
         RowSelectMode    := rsSingle;
         RowMoving        := False;
         ColSelectMode    := csNone;
         ResizeCols       := rcSingle;
         CenterPicture    := True;
         StretchPicture   := False;

         DefaultRowHeight := 18;
         {Font.Size        := 11;
         Font.Name        := 'MS Sans Serif';
         Font.Style       := [];

         HeadingHeight    := 18;
         HeadingFont.Name := 'MS Sans Serif';
         HeadingFont.Size := 11;
         HeadingFont.Style:= [];}
         HeadingAlignment := taLeftJustify;

         // --------------------------------------------------------------------

         with Col[ GlyphCol ] do
         Begin
            Alignment   := taLeftJustify;
            Heading     := '';
            Visible     := True;
            Width       := GlyphColWidth;
            ControlType := ctPicture;
            SortPicture := TSGrid.spNone;
         end;

         with Col[ CodeCol ] do
         Begin
            Alignment   := taLeftJustify;
            Heading     := 'Code';
            Visible     := True;
            Width       := 80;
            ControlType := ctText;
            SortPicture := TSGrid.spDown;
         end;


         if LookUpDlg.HasAlternativeCode then with Col[ AltCodeCol ] do
         Begin
            Alignment   := taLeftJustify;
            Heading     := AlternativeChartCodeName(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used);
            Visible     := True;
            Width       := 120;
            ControlType := ctText;
            SortPicture := TSGrid.spNone;
         end;


         with Col[ DescCol ] do
         Begin
            Alignment   := taLeftJustify;
            Heading     := 'Account Description';
            Visible     := True;
            Width       := 200;
            ControlType := ctText;
            SortPicture := TSGrid.spNone;
         end;
         LookUpDlg.CurrentSortOrder := chsSortByCode;

         if tCHSSortType(UserINI_Chart_Lookup_Sort_Column) = chsSortByDesc then
           LookupDlg.FDefaultSortOrder := chsSortByDesc
         else
           LookUpDlg.FDefaultSortOrder := chsSortByCode;

         LookUpDlg.CurrentSearchKey := UpperCase( Guess );
      end;

      If LookUpDlg.ShowModal = mrOK Then
      Begin
         aHasChartBeenRefreshed := LookUpDlg.HasChartBeenRefreshed;

         case LookUpDlg.CurrentSortOrder of
            chsSortByCode : 
               Begin
                   with LookUpDlg.CHSListByCode do
                      for i := 0 to Pred( ItemCount ) do if LookUpDlg.Grid.RowSelected[ i+1 ] then
                          Result := LookUpDlg.CHSListByCode.CHSRec_At( i )^.chsAccount_Ptr^.chAccount_Code;
               end;
            chsSortByDesc :
               Begin
                   with LookUpDlg.CHSListByDesc do
                      for i := 0 to Pred( ItemCount ) do if LookUpDlg.Grid.RowSelected[ i+1 ] then
                          Result := LookUpDlg.CHSListByDesc.CHSRec_At( i )^.chsAccount_Ptr^.chAccount_Code;
               end;
            chsSortByAltCode :
               Begin
                   with LookUpDlg.CHSListByAltCode do
                      for i := 0 to Pred( ItemCount ) do if LookUpDlg.Grid.RowSelected[ i+1 ] then
                          Result := LookUpDlg.CHSListByAltCode.CHSRec_At( i )^.chsAccount_Ptr^.chAccount_Code;
               end;
         end;
      end;

   Finally
      if Assigned( LookUpDlg.CHSListByCode ) then
      Begin
         LookUpDlg.CHSListByCode.Free;
         LookUpDlg.CHSListByCode := nil;
      end;
      if Assigned( LookUpDlg.CHSListByDesc ) then
      Begin
         LookUpDlg.CHSListByDesc.Free;
         LookUpDlg.CHSListByDesc := nil;
      end;
      if Assigned( LookUpDlg.CHSListByAltCode ) then
      Begin
         LookUpDlg.CHSListByAltCode.Free;
         LookUpDlg.CHSListByAltCode := nil;
      end;
      LookUpDlg.Free;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function PickAccount( var AcctCode : string; var aHasChartBeenRefreshed : boolean; FilterFunction : TAcctFilterFunction = nil; ShowOptions: Boolean = True; ShowRefreshChart : Boolean = True ) : Boolean;
// Creates Chart Account Lookup form positioned on passed AcctCode.
// User can select/search for chart code
begin
  Result := False;
  if not HasAChart then exit;
  AcctCode := AccountLookupFrm.LookUpChart( AcctCode, aHasChartBeenRefreshed, FilterFunction, ShowOptions, ShowRefreshChart );
  if AcctCode<>'' then Result := True;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure PickCodeForEdit(Sender : Tobject; FilterFunction : TAcctFilterFunction = nil; ShowOptions: Boolean = True; ShowRefreshChart : Boolean = True );
var
  S : string;
  HasChartBeenRefreshed : boolean;
begin
   if not ( Sender is TEdit ) then
      Exit;

   TEdit(Sender).SetFocus;
   S := TEdit(Sender).Text;
   if PickAccount( S, HasChartBeenRefreshed, FilterFunction, ShowOptions, ShowRefreshChart) then
     TEdit(Sender).text := S;
   TEdit(Sender).SelStart := length(S);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmAcctLookup.SetColumnSortOrder(aSortOrder : tCHSSortType);
begin
  if aSortOrder <> CurrentSortOrder then
  begin
    Screen.Cursor  := crHourGlass;
    CurrentSortOrder := aSortOrder;
    ShowHeadingArrows;
    Grid.RefreshData( roBoth, rpNone );
    CurrentSearchKey    := '';
    Grid.CurrentDataRow := 1;
    Grid.PutCellInView( 1, 1 );
    Screen.Cursor := crDefault;
  end;

  UserINI_Chart_Lookup_Sort_Column := Ord(CurrentSortOrder);
end;

procedure TfrmAcctLookup.SetFilter(const Value: TAcctFilterFunction);
begin
  FFilter := Value;
end;

procedure TfrmAcctLookup.SetHasAlternativeCode(const Value: Boolean);
begin
  FHasAlternativeCode := Value;
  if FHasAlternativeCode then
     Grid.Cols := AltCodeCol
  else
     Grid.Cols := DescCol;

end;

function TfrmAcctLookup.GetCurrentlySelectedItem: pchsRec;
begin
  result := nil;

  if ( chSListByCode.ItemCount = 0)
  or ( Grid.CurrentDataRow < 1) then
    exit;

  case CurrentSortOrder of
    chSSortByCode : result := chSListByCode.CHSRec_At( Grid.CurrentDataRow - 1);
    chSSortByDesc : result := chSListByDesc.CHSRec_At( Grid.CurrentDataRow - 1);
    chSSortByAltCode : result := chSListByAltCode.CHSRec_At( Grid.CurrentDataRow - 1);
  end;
end;


function TfrmAcctLookup.IndexOf(aAccountCode: ShortString;
  List: tchSList): integer;
var
  i : integer;
begin
  result := -1;

  for i := List.First to List.Last do
    if list.chSRec_At(i).chsAccount_Ptr.chAccount_Code = aAccountCode then
      result := i;
end;

procedure TfrmAcctLookup.ResortMaintainCurrentPos(
  NewSortOrder: tchsSortType);
var
  CurrentItem : pCHSRec;
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
        chSSortByDesc : ItemIndex := IndexOf( CurrentItem.chsAccount_Ptr.chAccount_Code, chSListByDesc);
        chSSortByCode : ItemIndex := IndexOf( CurrentItem.chsAccount_Ptr.chAccount_Code, chSListByCode);
        chSSortByAltCode : ItemIndex := IndexOf( CurrentItem.chsAccount_Ptr.chAccount_Code, chSListByAltCode);
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

procedure TfrmAcctLookup.rbFullClick(Sender: TObject);
begin
  if Assigned (AdminSystem) then // Save it to Clientfile
     MyClient.clFields.clUse_Basic_Chart := False;
  RefreshGrid;
end;

procedure TfrmAcctLookup.rbBasicClick(Sender: TObject);
begin
  if Assigned (AdminSystem) then // Save it to Clientfile
     MyClient.clFields.clUse_Basic_Chart := True;
  RefreshGrid;
end;

procedure TfrmAcctLookup.SetSize;
const
   ThisMethodName = 'TfrmAcctLookup.FormCreate';
   RowHeight = 18;
Var
   NonClientHeight : Integer;
   MaxNoRows       : Integer;
   MaxHeight       : Integer;
   cCount, i       : Integer;
begin
   NonClientHeight := Height - ClientHeight + pnlBasic.Height + Grid.HeadingHeight;
   MaxHeight       := Round( (Monitor.WorkareaRect.Bottom - Monitor.WorkareaRect.Top) * 0.7 );
   MaxNoRows       := ( MaxHeight - NonClientHeight ) div RowHeight;

   cCount := 0;
   for i := 0 to MyClient.clChart.ItemCount - 1 do
   Begin
     with MyClient.clChart.Account_At( I )^ do
     Begin
       if (chHide_In_Basic_Chart) and ShowBasicChart then
         Continue
       else
         Inc(cCount);
     end;
   end;

   with MyClient do begin
      if MaxNoRows > cCount then begin
         //box can show more lines than there are charts. so show number of items in list,
         //unless less than 6, in that case set max Rows to 6 ( 6 = 5 data rows + header)
         MaxNoRows := Succ( cCount );
         if MaxNoRows < 6 then MaxNoRows := 6;
      end;
   end;

   Height  := NonClientHeight + ( MaxNoRows * RowHeight );
   Width   := max(300, Round( (self.Monitor.WorkareaRect.Right - self.Monitor.WorkareaRect.Left) * 0.4 ));

end;

//------------------------------------------------------------------------------
function TfrmAcctLookup.ShowBasicChart: Boolean;
begin
  Result := rbBasic.Checked;
end;

//------------------------------------------------------------------------------
procedure TfrmAcctLookup.RefreshGrid;
var
  i: Integer;
  IncludeAccount: Boolean;
  Code: string;
begin
   Grid.EnableRedraw := False;
   try
     Code := '';
     case CurrentSortOrder of
        chsSortByCode :
           Begin
               with CHSListByCode do
                  for i := 0 to Pred( ItemCount ) do if Grid.RowSelected[ i+1 ] then
                      Code := CHSListByCode.CHSRec_At( i )^.chsAccount_Ptr^.chAccount_Code;
           end;
        chsSortByDesc :
           Begin
               with CHSListByDesc do
                  for i := 0 to Pred( ItemCount ) do if Grid.RowSelected[ i+1 ] then
                      Code := CHSListByDesc.CHSRec_At( i )^.chsAccount_Ptr^.chAccount_Description;
           end;
        chsSortByAltCode :
           Begin
               with CHSListByAltCode do
                  for i := 0 to Pred( ItemCount ) do if Grid.RowSelected[ i+1 ] then
                      Code := CHSListByAltCode.CHSRec_At( i )^.chsAccount_Ptr^.chAccount_Code;
           end;
     end;
     CHSListByCode.DeleteAll;
     CHSListByDesc.DeleteAll;
     CHSListByAltCode.DeleteAll;
     with MyClient.clChart do
        for i := 0 to Pred( ItemCount ) do
        Begin
           if Assigned(Filter) then begin
             IncludeAccount := Filter(Account_At(i));
           end
           else
             IncludeAccount := true;

           if Account_At(i).chHide_In_Basic_Chart and ShowBasicChart then
            Continue;

           if IncludeAccount then begin
             CHSListByCode.Insert( NewCHSRec( Account_At( i ) ) );
             CHSListByDesc.Insert( NewCHSRec( Account_At( i ) ) );
             CHSListByAltCode.Insert( NewCHSRec( Account_At( i ) ) );
           end;
        end;
   finally
     Grid.Rows := CHSListByCode.ItemCount;
     CurrentsearchKey := Code;
     SetSize;
     Grid.EnableRedraw := True;
     DoNewSearch;
     Grid.RefreshData( roBoth, rpNone );
     Grid.SetFocus;
   end;
end;

//------------------------------------------------------------------------------
Initialization
  DebugMe := LogUtil.DebugUnit( UnitName );

//------------------------------------------------------------------------------
Finalization
  if Assigned( Glyph ) then
  Begin
    Glyph.Free;
    Glyph := nil;
  end;

end.

