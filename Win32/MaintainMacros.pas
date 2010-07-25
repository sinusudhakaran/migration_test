unit MaintainMacros;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

       !!!! NOT USED !!!!

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TB97Tlbr, TB97Ctls, TB97, ImagesFrm, Grids_ts, TSGrid;

type
  TMacroListForm = class(TForm)
    DockBar: TDock97;
    Toolbar: TToolbar97;
    tbMerge: TToolbarButton97;
    tbNew: TToolbarButton97;
    tbEdit: TToolbarButton97;
    tbDel: TToolbarButton97;
    tbClose: TToolbarButton97;
    ToolbarSep971: TToolbarSep97;
    ToolbarSep972: TToolbarSep97;
    Grid: TtsGrid;
    procedure GridCellLoaded(Sender: TObject; DataCol,
      DataRow: Integer; var Value: Variant);
    procedure FormCreate(Sender: TObject);
    procedure tbNewClick(Sender: TObject);
    procedure tbDelClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure tbEditClick(Sender: TObject);
    procedure GridDblClickCell(Sender: TObject; DataCol,
      DataRow: Integer; Pos: TtsClickPosition);
    procedure tbMergeClick(Sender: TObject);
    procedure GridKeyPress(Sender: TObject; var Key: Char);
    procedure GridRowChanged(Sender: TObject; OldRow, NewRow: Integer);
  private
    CurrentSearchKey  : ShortString;
    procedure DoNewSearch;
  
    procedure SetupGrid;
    procedure SetupHelp;
    procedure UpdateGrid;
    procedure DoMerge;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MacroListForm: TMacroListForm;

procedure MaintainMacroList;

// --------------------------------------------------------------------
implementation

uses
  BKDefs,
  bkmaio,
  bkXPThemes,
  Globals, maList32, LogUtil, Admin32,
  EditMacroDlg, CopyFromDlg, ClObj32;
// --------------------------------------------------------------------

{$R *.DFM}

// --------------------------------------------------------------------

Const
   UnitName = 'MaintainMacroListFrm';
   DebugMe  : Boolean = False;
   

procedure TMacroListForm.GridCellLoaded(Sender: TObject;
  DataCol, DataRow: Integer; var Value: Variant);
const
   ThisMethodName = 'TTFrmMaintainMacroList.GridCellLoaded';
Var
   M : pMacro_Rec;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   with MyClient.clMacro_List do
   Begin
      if DataRow > ItemCount then Exit;
      M := Macro_At( Pred( DataRow ) );
      with M^ do
      Begin
         case DataCol of
            1 : Value := maCode;
            2 : Value := maDescription;
         end;
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// --------------------------------------------------------------------

procedure TMacroListForm.SetupGrid;
Begin
   with Grid do
   Begin
      Rows             := MyClient.clMacro_List.ItemCount;
      Cols             := 2;
      Align            := alClient;
      EditMode         := emNone;
      RowSelectMode    := rsSingle;
      RowMoving        := False;
      ColSelectMode    := csNone;
      ResizeCols       := rcNone;
         
      DefaultRowHeight := 18;
      Font.Size        := 11;
      Font.Name        := 'MS Sans Serif';
      Font.Style       := [];

      HeadingHeight    := 18;
      HeadingFont.Name := 'MS Sans Serif';
      HeadingFont.Size := 11;
      HeadingFont.Style:= [];
      HeadingAlignment := taLeftJustify;
      
      // --------------------------------------------------------------------

      with Col[ 1 ] do
      Begin
         Alignment   := taLeftJustify;
         Heading     := 'Code';
         Visible     := True;
         Width       := 80;
         ControlType := ctText;
         SortPicture := TSGrid.spDown;
      end;
      
      with Col[ 2 ] do
      Begin
         Alignment   := taLeftJustify;
         Heading     := 'Text';
         Visible     := True;
         Width       := 380;
         ControlType := ctText;
         SortPicture := TSGrid.spNone;
      end;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TMacroListForm.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   //Components
   tbNew.Hint       :=
                    'Add a Macro|' +
                    'Add a new Macro';
   tbEdit.Hint      :=
                    'Edit a Macro|' +
                    'Edit a Macro';
   tbDel.Hint       :=
                    'Delete a Macro|' +
                    'Delete a Macro';
   tbMerge.Hint     :=
                    'Merge a Macro List from another Client File|' +
                    'Merge another Client''s Macro List into this Macro List';
   tbClose.Hint     :=
                    'Close this window|' +
                    'Close this window';
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
procedure TMacroListForm.UpdateGrid;
Begin
   with Grid do
   Begin
      Rows := MyClient.clMacro_List.ItemCount;
      RefreshData( roBoth, rpNone );
   end;
end;

// --------------------------------------------------------------------
   
procedure TMacroListForm.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  SetupGrid;
  SetupHelp;
  tbMerge.Enabled := Assigned( AdminSystem);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure MaintainMacroList;
var
  MyDlg : TMacroListForm;
begin
   if Assigned( MyClient ) then
   Begin
      MyDlg := TMacroListForm.Create(Application);
      try
         MyDlg.ShowModal;
      finally
         MyDlg.Free;
      end;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TMacroListForm.tbNewClick(Sender: TObject);

Var
   M : pMacro_Rec;
   ACode : string;
   ADesc : string;
begin
   ACode := '';
   ADesc := '';

   if AddMacro( ACode, ADesc ) and ( ACode<>'' ) then
   Begin
      if MyClient.clMacro_List.FindCode( ACode )=nil then
      Begin
         M := bkmaio.New_Macro_Rec;
         M^.maCode := ACode;
         M^.maDescription := ADesc;
         MyClient.clMacro_List.Insert( M );
         UpdateGrid;
      end
      else
         MessageDlg('Sorry, the Macro code "'+ACode+'" already exists.', mtError, [mbOK], 0);
   end;
   CurrentSearchKey := '';
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TMacroListForm.tbDelClick(Sender: TObject);
Var
   I       : Integer;
   NewList : TMacro_List;
   O       : pMacro_Rec;
   N       : pMacro_Rec;
begin
   NewList := TMacro_List.Create;
   with MyClient.clMacro_List do for i := 0 to Pred( ItemCount ) do
   Begin
      O := Macro_At( i );
      if not ( Grid.RowSelected[ i+1 ] ) then
      begin { Not selected, so keep it }
         N := bkmaio.New_Macro_Rec;
         Move( O^, N^, SizeOf( TMacro_Rec ) );
         NewList.Insert( N );
      end;
   end;
   MyClient.clMacro_List.Free;
   MyClient.clMacro_List := NewList;
   UpdateGrid;
   CurrentSearchKey := '';
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TMacroListForm.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
  
begin
  Handled := true;
  case Msg.CharCode of
    VK_INSERT : tbNew.click;
    VK_DELETE : tbDel.click;
    VK_RETURN : tbEdit.click;
    VK_ESCAPE : tbClose.click;
  else
    Handled := false;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TMacroListForm.tbEditClick(Sender: TObject);
Var
   I : Integer;
   ACode, ADesc : string;
begin
   with MyClient.clMacro_List do for i := 0 to Pred( ItemCount ) do 
   Begin
      if ( Grid.RowSelected[ i+1 ] ) then
      begin { Not selected, so keep it }
         with Macro_At( i )^ do
         Begin
            ACode := maCode;
            ADesc := maDescription;
            if EditMacro( ACode, ADesc ) then
            Begin
               maDescription := ADesc;
               UpdateGrid;
            end;
         end;
      end;
   end;
   CurrentSearchKey := '';
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TMacroListForm.GridDblClickCell(Sender: TObject;
  DataCol, DataRow: Integer; Pos: TtsClickPosition);
begin
   tbEdit.Click;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TMacroListForm.DoMerge;

var
  SCode   : string;
  SClient : TClientObj;
  sM      : pMacro_Rec;
  dM      : pMacro_Rec;
  i       : integer;
begin
   if SelectCopyFrom( 'Merge Macros from ...', SCode ) then
   begin
      SClient := TClientObj.Create;
      Try
         SClient.Open( SCode );
         with SClient.clMacro_List do
         Begin
            for I := 0 to Pred( ItemCount ) do
            Begin
               sM := Macro_At( I );
               dM := MyClient.clMacro_List.FindCode( sm^.maCode );
               if dM = nil then
               begin { Create it if it doesn't exist }
                  dM := bkmaio.New_Macro_Rec;
                  Move( sM^, dM^, SizeOf( TMacro_Rec ) );
                  MyClient.clMacro_List.Insert( dM );
               end
               else { update the description if it does }
                  dm^.maDescription := sm^.maDescription;
            end;
         end;
      Finally
         SClient.Free;
      end;
   end;
   UpdateGrid;
   CurrentSearchKey := '';
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TMacroListForm.tbMergeClick(Sender: TObject);
begin
   DoMerge;
   UpdateGrid;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TMacroListForm.DoNewSearch;

const
   ThisMethodName = 'TMacroListForm.DoNewSearch';

{ Called when anything is typed on the keyboard }

Var
   FoundInRow    : Integer;
   I             : Integer;
   SaveSearchKey : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if CurrentSearchKey = '' then
   begin { Reset }
      Grid.CurrentDataRow := 1;
      Grid.PutCellInView( 1, 1 );
      Exit;
   end;

   FoundInRow := -1;
   
   with MyClient.clMacro_List do begin
      for I := 0 to Pred( ItemCount ) do Begin
         if Copy( Macro_At( I )^.maCode, 1, Length( CurrentSearchKey ) ) = CurrentSearchKey then
         begin 
            FoundInRow := I;
            Break;
         end;
         if ( Macro_At( I )^.maCode > CurrentSearchKey ) then
         begin 
            if I > 0 then 
               FoundInRow := Pred( I );
            Break;
         end;
      end;
   end;

   SaveSearchKey := CurrentSearchKey;
   
   if FoundInRow >=0 then
   Begin
      Grid.CurrentDataRow := Succ( FoundInRow );
      Grid.PutCellInView( 1, Grid.CurrentDataRow );
   end;

   CurrentSearchKey := SaveSearchKey;
   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TMacroListForm.GridKeyPress(Sender: TObject; var Key: Char);
const
   ThisMethodName = 'TMacroListForm.GridKeyPress';
Var
   SaveSearchKey : ShortString;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
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
   if CurrentSearchKey <> SaveSearchKey then DoNewSearch;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TMacroListForm.GridRowChanged(Sender: TObject; OldRow,
  NewRow: Integer);
begin
   CurrentSearchKey := '';
end;

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
