unit BaSelFrm;

interface

{..$DEFINE UseGlyphs}

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  Grids_ts, TSGrid, ECollect, StdCtrls, ExtCtrls, StDate,
  OSFont;
  
type
  tMultiSelect = ( SingleAccount, MultipleAccounts );

  TfrmBALookup = class(TForm)
    Grid: TtsGrid;
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;

    procedure GridCellLoaded(Sender: TObject; DataCol, DataRow: Integer;
      var Value: Variant);
    procedure GridKeyPress(Sender: TObject; var Key: Char);
    procedure GridDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GridClickCell(Sender: TObject; DataColDown, DataRowDown,
      DataColUp, DataRowUp: Integer; DownPos, UpPos: TtsClickPosition);
  private
    { Private declarations }
    AList        : TExtdCollection;
    SelectMethod : tMultiSelect;
  public
    { Public declarations }
  end;

Function SelectBankAccountsForExport( const D1, D2 : tStDate; const MultiSelect : tMultiSelect ) : Boolean;

var
  frmBALookup: TfrmBALookup;

implementation uses LogUtil, SysUtils, WinUtils, Globals, BKDefs,
  clObj32, baObj32, BKConst, TravUtils, imagesfrm;

Const
   UnitName = 'BaSelFrm';
   DebugMe  : Boolean = False;

   GlyphCol  = 1;
   CodeCol   = 2;
   DescCol   = 3;
   CountCol  = 4;
            
{$R *.DFM}

//------------------------------------------------------------------------------

procedure TfrmBALookup.GridClickCell(Sender: TObject; DataColDown,
  DataRowDown, DataColUp, DataRowUp: Integer; DownPos,
  UpPos: TtsClickPosition);

Var
   BA : TBank_Account;  
begin
   if ( DataRowUp <= 0 ) or ( DataRowUp > AList.ItemCount ) then Exit;
   BA := TBank_Account( AList.Items[ Pred( DataRowUp ) ] );
   with BA.baFields do
   Begin
      baIs_Selected := not baIs_Selected;
      Grid.CellInvalidate( GlyphCol, DataRowUp );
   end;
end;

//------------------------------------------------------------------------------

procedure TfrmBALookup.GridCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
const
   ThisMethodName = 'TFrmBALookup.GridCellLoaded';
Var
   BA : tBank_Account;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if ( DataRow <= 0 ) or ( DataRow > AList.ItemCount ) then Exit;
   
   BA := TBank_Account( AList.Items[ Pred( DataRow ) ] );
   with BA.baFields do
   Begin
      case DataCol of
         GlyphCol  : if baIs_Selected then Value := BitMapToVariant( AppImages.imgTick.Picture.Bitmap );
         CodeCol   : Value := baBank_Account_Number;
         DescCol   : Value := baBank_Account_Name;
         CountCol  : Value := Format( '%10d', [ baEntries_Available ] );
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmBALookup.GridDblClick(Sender: TObject);
const
   ThisMethodName = 'TFrmBALookup.GridDblClick';
Var
   BA : TBank_Account;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   
   if ( Grid.CurrentDataRow > 0 ) and ( Grid.CurrentDataRow <= AList.ItemCount ) then 
   Begin
      BA := TBank_Account( AList.Items[ Pred( Grid.CurrentDataRow ) ] );
      with BA.baFields do
      Begin
         baIs_Selected := TRUE;
         Grid.CellInvalidate( GlyphCol, Grid.CurrentDataRow );
      end;
   end;
   
   If ( SelectMethod = SingleAccount ) then // return mrOK
   Begin
      ModalResult := mrOK;
   end;
   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmBALookup.GridKeyPress( Sender: TObject; var Key: char );
const
   ThisMethodName = 'TFrmBALookup.GridKeyPress';
Var
   BA : TBank_Account;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if Key = ' ' then // Space key to toggle selection
   Begin
      if ( Grid.CurrentDataRow > 0 ) and ( Grid.CurrentDataRow <= AList.ItemCount ) then 
      Begin
         BA := TBank_Account( AList.Items[ Pred( Grid.CurrentDataRow ) ] );
         with BA.baFields do
         Begin
            baIs_Selected := not baIs_Selected;
            Grid.CellInvalidate( GlyphCol, Grid.CurrentDataRow );
         end;
      end;
      Key := #0;
   end;

   if Key = #$0D then ModalResult := mrOK;       // Return
   if Key = #$1B then ModalResult := mrCancel;   // Escape

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmBALookup.FormShow(Sender: TObject);
const
   ThisMethodName = 'TFrmBALookup.FormShow';
Var
   FixedWidth     : Integer;
   VScrollerWidth : Integer;
   CW             : Integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   
   VScrollerWidth := GetSystemMetrics( SM_CXVSCROLL );
   CW             := ClientWidth;

   if Assigned( AList ) then
   Begin 
      if Grid.Height > ( Succ( AList.ItemCount ) * 18 ) then 
      Begin
         VScrollerWidth := 0;
      end;
   end;

   with Grid do
   Begin
      FixedWidth := 
      Grid.Col[ GlyphCol  ].Width + 
      Grid.Col[ CodeCol  ].Width + 
      Grid.Col[ CountCol ].Width + 
         VScrollerWidth;
      Col[ DescCol ].Width := CW - FixedWidth - 4;
      SetFocus;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure TfrmBALookup.FormCreate( Sender: TObject );

const
   ThisMethodName = 'TFrmBALookup.FormCreate';
   RowHeight = 18;

Var
   NonClientHeight : Integer;
   MaxNoRows       : Integer;
   MaxHeight       : Integer;
   GridHeight      : Integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );


   GridHeight      := Grid.Height;   
   NonClientHeight := Height - GridHeight;
   MaxHeight       := Round(self.Monitor.Height * 0.7 );
   MaxNoRows       := ( MaxHeight -  NonClientHeight  ) div RowHeight;

   if MaxNoRows > MyClient.clBank_Account_List.ItemCount then MaxNoRows := 
      Succ( MyClient.clBank_Account_List.ItemCount );

   if MaxNoRows < 6 then MaxNoRows := 6;
   

   Height  := NonClientHeight + ( MaxNoRows * RowHeight );
   Width   := Round( Screen.WorkAreaWidth * 0.6 ); if Width < 400 then Width := 400;
   Top     := ( Screen.WorkAreaHeight - Height ) div 2;
   Left    := ( Screen.WorkAreaWidth - Width ) div 2;

   Caption := '';

   // Set up Help Information
   
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   Grid.Hint        := '';
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

Function SelectBankAccountsForExport( const D1, D2 : tStDate; const MultiSelect : tMultiSelect ) : Boolean;

Const
  ThisMethodName = 'SelectAccountsForExport';
Var
   LookUpDlg  : TfrmBALookup;
   i          : Integer;
   Count      : Integer;
   BA         : tBank_Account;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   
   Result := False;

   if MyClient = nil then Exit;

   // Do we have any accounts to choose from?
   
   Count := 0;
   with MyClient.clBank_Account_List do
   Begin
      For i := 0 to Pred( ItemCount ) do
      Begin
         BA := Bank_Account_At( i );
         With BA, baFields do
         Begin
            If ( baAccount_Type in [btBank, btCashJournals, btAccrualJournals] ) then 
               Inc( Count );
         end;
      end;
   end;
   
   if Count = 0 then Exit; // No Suitable Accounts

   // --------------------------------------------------------------------------
  
   LookUpDlg := TfrmBALookup.Create( nil );

   Try
      with LookUpDlg do
      Begin
         AList := TExtdCollection.Create;
         SelectMethod := MultiSelect;

         // --------------------------------------------------------------------
         // Put the accounts into the list
         // --------------------------------------------------------------------
         
         with MyClient.clBank_Account_List do
         Begin
            For i := 0 to Pred( ItemCount ) do
            Begin
               BA := Bank_Account_At( i );
               With BA, baFields do
               Begin
                  baIs_Selected := False;
                  If ( baAccount_Type in [btBank, btCashJournals, btAccrualJournals] ) then
                  Begin
                     AList.Insert( BA );
                     baEntries_Available := TravUtils.NumberAvailableForExport( BA, D1, D2 );
                  end;
               end;         
            end;
         end;

         // --------------------------------------------------------------------
         // Set the caption and hint
         // --------------------------------------------------------------------

         case MultiSelect of
            SingleAccount    : 
               Begin
                  Caption   := 'Select a Bank Account';
                  Grid.Hint := 'Select the Bank Account you want to extract, then press OK';
               end;
            MultipleAccounts : 
               Begin
                  Caption := 'Select Bank Accounts';
                  Grid.Hint := 'Select the Bank Accounts you want to extract, then press OK';
               end;
         end;     

         // --------------------------------------------------------------------
         // Select the first account with entries, or (multi-only) all accounts with entries
         // --------------------------------------------------------------------
      
         case MultiSelect of
            SingleAccount    : 
               with AList do for i := 0 to Pred( ItemCount ) do
               Begin
                  BA := TBank_Account( Items[ i ] );
                  with BA.baFields do if baEntries_Available > 0 then
                  Begin
                     baIs_Selected := True;
                     Break; // Do the first only.
                  end;
               end;
            MultipleAccounts : 
               with AList do for i := 0 to Pred( ItemCount ) do
               Begin
                  BA := TBank_Account( Items[ i ] );
                  with BA.baFields do 
                     if baEntries_Available > 0 then
                        baIs_Selected := True;
               end;
         end; // of Case
         
         // --------------------------------------------------------------------
         // Set up the grid
         // --------------------------------------------------------------------
         
         with LookUpDlg.Grid do
         Begin
            Rows             := AList.ItemCount;
            Cols             := CountCol;
            Align            := alClient;
            EditMode         := emNone;
            RowSelectMode    := TSGrid.rsSingle;
            RowMoving        := False;
            ColSelectMode    := csNone;
            ResizeCols       := rcNone;
            CenterPicture    := True;
            StretchPicture   := False;
         
            DefaultRowHeight := 18;
            Font.Size        := 11;
            Font.Name        := 'MS Sans Serif';
            Font.Style       := [];

            HeadingHeight    := 18;
            HeadingFont.Name := 'MS Sans Serif';
            HeadingFont.Size := 11;
            HeadingFont.Style:= [];
            HeadingAlignment := taLeftJustify;
            HeadingButton    := hbNone;
            Heading3D        := False;

            with Col[ GlyphCol ] do
            Begin
               Alignment   := taLeftJustify;
               Heading     := '';
               Visible     := True;
               Width       := 22;
               ControlType := ctPicture;
            end;
            
            with Col[ CodeCol ] do
            Begin
               Alignment   := taLeftJustify;
               Heading     := 'Account Number';
               Visible     := True;
               Width       := 150;
               ControlType := ctText;
            end;
         
            with Col[ DescCol ] do
            Begin
               Alignment   := taLeftJustify;
               Heading     := 'Account Name';
               Visible     := True;
               Width       := 250;
               ControlType := ctText;
            end;

            with Col[ CountCol ] do
            Begin
               Alignment   := taRightJustify;
               Heading     := 'Entries Available';
               Visible     := True;
               Width       := 120;
               ControlType := ctText;
            end;
         end;   
      end;

      // -----------------------------------------------------------------------
      // OK, now show the dialog and let the user select which account they want
      // -----------------------------------------------------------------------
      
      If ( LookUpDlg.ShowModal = mrOK ) then 
      Begin
         Count := 0;
         with MyClient.clBank_Account_List do
         Begin
            For i := 0 to Pred( ItemCount ) do
            Begin
               BA := Bank_Account_At( i );
               With BA.baFields do
               Begin
                  If ( baIs_Selected ) then Inc( Count );
               end;
            end;
         end;
         Result := ( Count > 0 );
      end;

   Finally
      
      if Assigned( LookUpDlg.AList ) then
      Begin
         LookUpDlg.AList.DeleteAll;
         LookUpDlg.AList.Free;
         LookUpDlg.AList := nil;
      end;
      LookUpDlg.Free;
      
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
End; 

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

