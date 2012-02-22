unit ConfigColumnsFrm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:   Configure Columns

   Written: Apr 2000
   Authors: Matthew

   Purpose: Allows the user to set/reset the properties of columns in
            CES and HDE.

   Notes:   Requires that each of the items in the listbox has an object
            associated with it.  This object MUST be of type TColumnConfigInfo.

            The form will be created and populated by the calling routine.
            Currently this is only used by
               Code Entries Screen
               Historical Data Entry

}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ComCtrls, StdCtrls, ExtCtrls, Buttons, ColFmtListObj, baObj32,
  bkXPThemes, OSFont;

type
   TColumnConfigInfo = class
      ColFieldID    : integer;
      EditState     : byte;
      VisibleState  : byte;
      ColWidth      : integer;
      DefaultOrder  : integer;
      DefaultWidth  : integer;
      DefaultVisible: boolean;
      OrderIndex    : integer;
      Ptr           : pointer;
   end;

SetOfByte = Set of Byte;

type
  TfrmConfigure = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    PageControl1: TPageControl;
    tabConfigure: TTabSheet;
    tabRestore: TTabSheet;
    Label1: TLabel;
    lblEditModeDesc: TLabel;
    Label5: TLabel;
    imgEdit: TImage;
    imgVisible: TImage;
    GroupBox2: TGroupBox;
    btnUp: TBitBtn;
    btnDown: TBitBtn;
    imglist: TImageList;
    GroupBox1: TGroupBox;
    btnRestoreOrder: TButton;
    btnRestoreWidth: TButton;
    btnRestoreEdit: TButton;
    btnRestoreVisible: TButton;
    btnRestoreAll: TButton;
    lbColumns: TListBox;
    lblWarning: TLabel;
    Label3: TLabel;
    GroupBox3: TGroupBox;
    btnLoad: TBitBtn;
    btnSave: TBitBtn;
    dlgLoadCLS: TOpenDialog;
    dlgSaveCLS: TSaveDialog;
    lblSort: TLabel;

    procedure lbColumnsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure lbColumnsMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure lbColumnsDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure lbColumnsStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure lbColumnsEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure lbColumnsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure btnRestoreEditClick(Sender: TObject);
    procedure btnRestoreVisibleClick(Sender: TObject);
    procedure btnRestoreWidthClick(Sender: TObject);
    procedure btnRestoreAllClick(Sender: TObject);
    procedure btnRestoreOrderClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tabRestoreShow(Sender: TObject);
    procedure tabConfigureShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    CurrentIndex : integer;
    OverIndex    : integer;
    FColumnFormatList: TColFmtList;
    FDefaultEditable : SetOfByte;
    FNeverEditable : SetOfByte;
    FAlwaysEditable: SetOfByte;
    FAlwaysVisible: SetOfByte;
    FShowTemplates: Boolean;
    FSortColumn: Integer;
    FCodingScreen: string;
    FConfigBankAccount: TBank_Account;
    FColumnListSwapped: Boolean;
    procedure ReorderUsingDefaults;
    procedure SetUpHelp;
    procedure SaveTemplate;
    procedure LoadTemplate;
    procedure SetCodingScreen(Value: string);
    procedure SetColumnListSwapped(const Value: Boolean);
  public
    { Public declarations }
    property DefaultEditable: SetOfByte read FDefaultEditable write FDefaultEditable;
    property NeverEditable: SetOfByte read FNeverEditable write FNeverEditable;
    property AlwaysEditable: SetOfByte read FAlwaysEditable write FAlwaysEditable;
    property AlwaysVisible: SetOfByte read FAlwaysVisible write FAlwaysVisible;
    property ColumnFormatList: TColFmtList read FCOlumnFormatList write FColumnFormatList;
    property ShowTemplates: Boolean read FShowTemplates write FShowTemplates;
    property SortColumn: Integer read FSortColumn write FSortColumn;
    property CodingScreen: string read FCodingScreen write SetCodingScreen;
    property ConfigBankAccount: TBank_Account read FConfigBankAccount write FConfigBankAccount;
    property ColumnListSwapped: Boolean read FColumnListSwapped write SetColumnListSwapped;
  end;

const
   //editable state constants
   esAlwaysEditable  = 0;
   esEditable        = 1;
   esNotEditable     = 2;
   esNeverEditable   = 3;

   //visible state constants
   vsAlwaysVisible   = 0;
   vsVisible         = 1;
   vsNotVisible      = 2;

   SECTION_HEADER = 'Settings';
   SECTION_COLUMN = 'Column';

//******************************************************************************
implementation

uses
  BKHelp,
  Globals,
  IniFiles,
  CodingFormConst,
  BKConst, YesNoDlg, WinUtils, InfoMoreFrm;

{$R *.DFM}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.lbColumnsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
//custom draw routine, handles drawing the bitmap and text for the current item
var
   Offset         : Integer;      { text offset width }
   ConfigSettings : TColumnConfigInfo;
begin
   with lbColumns.Canvas do begin { draw on control canvas, not on the form }
      FillRect(Rect);       { clear the rectangle }
      Offset := 2;          { provide default offset }

      ConfigSettings := TColumnConfigInfo( lbColumns.Items.Objects[ index]);
      //draw editable bitmap
      if ConfigSettings.EditState <> esNeverEditable then
         imgList.Draw( (Control as TListBox).Canvas, Rect.Left + Offset, Rect.Top + 1, ConfigSettings.EditState);
      Offset := Offset + 22;  { add four pixels between bitmap and text}
      //draw visible bitmap
      imgList.Draw( (Control as TListBox).Canvas, Rect.Left + Offset, Rect.Top + 1 , ConfigSettings.VisibleState + 4);
      Offset := Offset + 22;  { add four pixels between bitmap and text}
      //gray out if is not currently enabled
      if not ( lbColumns.Enabled) then Font.Color := clGray;

      TextOut(Rect.Left + Offset, Rect.Top, (Control as TListBox).Items[Index])  { display the text }
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.lbColumnsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//detect if the user has clicked on one of the bitmaps.  If so it changes state
//if it is ok to.
var
   OverIndex : integer;
   ItemConfig : TColumnConfigInfo;
begin
   //determine if an item is beneath mouse
   OverIndex := lbColumns.ItemAtPos(Point(x,y),true);
   if OverIndex <> -1 then begin
      //determine if a click has occured in the visible or editable box of an item
      if X in [ 2..18] then begin
         //in EDITABLE box
         ItemConfig := TColumnConfigInfo( lbColumns.Items.Objects[ OverIndex]);
         if ItemConfig.EditState = esEditable then
            ItemConfig.EditState := esNotEditable
         else if ItemConfig.EditState = esNotEditable then begin
            ItemConfig.EditState := esEditable;
            //turn on visible if currently off
            if ( ItemConfig.VisibleState = vsNotVisible) then
               ItemConfig.VisibleState := vsVisible;
         end;
      end
      else if X in [ 24..40] then begin
         //in VISIBLE box
         ItemConfig := TColumnConfigInfo( lbColumns.Items.Objects[ OverIndex]);
         if ItemConfig.VisibleState = vsVisible then begin
            ItemConfig.VisibleState := vsNotVisible;
            //turn off editable if it is on
            if ItemConfig.EditState = esEditable then
               ItemConfig.EditState := esNotEditable;
         end
         else if ItemConfig.VisibleState = vsNotVisible then
            ItemConfig.VisibleState := vsVisible;
      end;
   end;
   lbColumns.Refresh;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.lbColumnsDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
//Sender = control being dropped on
//Source = object being dropped
var
  OldIndex  : Integer;
  ListRect  : TRect;
begin
  accept := Source is TListBox;
  if accept then begin
     OldIndex := OverIndex;
     OverIndex := lbColumns.ItemAtPos(Point(x,y),true);
     //See if we need to paint anything
     if OldIndex = OverIndex then exit;
     //Draw Focus Rect
     if ( OverIndex > - 1 ) then begin
       ListRect := lbColumns.ItemRect( OverIndex );
       lbColumns.Canvas.DrawFocusRect(ListRect);
     end;
     //Clear old Focus Rect
     if (OldIndex <> -1) and (OverIndex <> OldIndex) then
        with lbColumns do begin
           ListRect := ItemRect( OldIndex );
           //need to set Brush.Color to table color if using TCheckListBox,
           //not needed for normal TListBox otherwise get strange painting effects
           if Selected[ OldIndex] then
              Canvas.Brush.Color := clHighlight
           else
              Canvas.Brush.Color := Color;
           Canvas.FrameRect( ListRect);
        end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.lbColumnsStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
   CurrentIndex := lbColumns.ItemIndex;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.lbColumnsEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
   CurrentIndex := -1;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.lbColumnsDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
   with lbColumns do
      if ( CurrentIndex <> -1 ) and ( OverIndex <> -1 ) then begin
         //Clear old Focus Rect
         lbColumns.Canvas.FrameRect( ItemRect( OverIndex ));
         //move item
         Items.Move(CurrentIndex, OverIndex);
         ItemIndex := OverIndex;
      end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.btnUpClick(Sender: TObject);
var
   currIndex, newIndex : integer;
begin
   with lbColumns do
      if (ItemIndex > 0) then begin
         currIndex := ItemIndex;
         newIndex  := Pred(currIndex);
         Items.Move( currIndex, newIndex);
         ItemIndex := newIndex;
      end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.btnDownClick(Sender: TObject);
var
   currIndex, newIndex : integer;
begin
   with lbColumns do
      if (ItemIndex <> -1) and (ItemIndex < Pred(Items.Count)) then begin
         currIndex := ItemIndex;
         newIndex := Succ(currIndex);
         Items.Move( currIndex, newIndex);
         ItemIndex := newIndex;
      end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.btnRestoreEditClick(Sender: TObject);
var
   i : integer;
   cRec : pColumnDefn;
begin
   //set all columns to editable if current notEditable
   with lbColumns do begin
      for i := 0 to Pred( Items.Count) do begin
            if ( TColumnConfigInfo( Items.Objects[i]).EditState in [ esEditable, esNotEditable]) then
            begin
               cRec := TColumnConfigInfo( Items.Objects[i]).Ptr;
               if cRec^.cdFieldId in FDefaultEditable then
                 TColumnConfigInfo( Items.Objects[i]).EditState := esEditable
               else
                 TColumnConfigInfo( Items.Objects[i]).EditState := esNotEditable;
            end;
      end;
      //Update display
      Refresh;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.btnRestoreVisibleClick(Sender: TObject);
var
   i : integer;
begin
   //set all columns to default visibility unless state is vsAlreadyVisible
   with lbColumns do begin
      for i := 0 to Pred( Items.Count) do begin
         if TColumnConfigInfo( Items.Objects[i]).VisibleState in [ vsVisible, vsNotVisible] then begin
           if TColumnConfigInfo( Items.Objects[i]).DefaultVisible then
              TColumnConfigInfo( Items.Objects[i]).VisibleState := vsVisible
           else
              TColumnConfigInfo( Items.Objects[i]).VisibleState := vsNotVisible;
         end;
      end;
      //Update display
      Refresh;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.btnRestoreWidthClick(Sender: TObject);
var
   i : integer;
begin
   with lbColumns do begin
      for i := 0 to Pred( Items.Count) do begin
         TColumnConfigInfo( Items.Objects[i]).ColWidth := TColumnConfigInfo( Items.Objects[i]).DefaultWidth;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.btnRestoreAllClick(Sender: TObject);
var
   i : integer;
   cRec : pColumnDefn;
begin
   with lbColumns do begin
      for i := 0 to Pred( Items.Count) do begin
         //width
         TColumnConfigInfo( Items.Objects[i]).ColWidth := TColumnConfigInfo( Items.Objects[i]).DefaultWidth;
         //editability
         if ( TColumnConfigInfo( Items.Objects[i]).EditState in [ esEditable, esNotEditable]) then
         begin
            cRec := TColumnConfigInfo( Items.Objects[i]).Ptr;
            if cRec^.cdFieldId in FDefaultEditable then
              TColumnConfigInfo( Items.Objects[i]).EditState := esEditable
            else
              TColumnConfigInfo( Items.Objects[i]).EditState := esNotEditable;
         end;
         //visibility
         if TColumnConfigInfo( Items.Objects[i]).VisibleState in [ vsVisible, vsNotVisible] then begin
            if TColumnConfigInfo( Items.Objects[i]).DefaultVisible then
               TColumnConfigInfo( Items.Objects[i]).VisibleState := vsVisible
            else
               TColumnConfigInfo( Items.Objects[i]).VisibleState := vsNotVisible;
         end;
      end;
      //order
      ReorderUsingDefaults;
      SortColumn := csDateEffective;
      //Update display
      Refresh;
   end;
   if lblSort.Visible then
     lblSort.Caption := 'Sort By: ' + csNames[SortColumn];
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.ReorderUsingDefaults;
var
   i, j : integer;
   ItemA, ItemB : TColumnConfigInfo;
begin
   //cycle thru sorting into order using default order
   with lbColumns do begin
      for i := 0 to Pred( Items.Count) do begin
         for j := ( i+1) to Pred( Items.Count) do begin
            ItemA := TColumnConfigInfo( Items.Objects[i]);
            ItemB := TColumnConfigInfo( Items.Objects[j]);

            if ItemB.DefaultOrder < ItemA.DefaultOrder then
               Items.Move( j, i);
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.btnRestoreOrderClick(Sender: TObject);
begin
   ReorderUsingDefaults;
   lbColumns.Refresh;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(Self);
  lblSort.Font.Style := [fsBold];
  lblWarning.Font.Style := [fsBold];
  imgList.GetBitmap( 1, imgEdit.Picture.Bitmap);
  imgList.GetBitmap( 5, imgVisible.Picture.Bitmap);
  FShowTemplates := False;
  FCodingScreen := CODING_SCREEN;
  SetupHelp;
  FConfigBankAccount := nil;
  ColumnListSwapped := False;

  btnLoad.Enabled := not CurrUser.HasRestrictedAccess;
  btnSave.Enabled := not CurrUser.HasRestrictedAccess;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.tabRestoreShow(Sender: TObject);
begin
   lbColumns.MultiSelect := true;
   lbColumns.Enabled     := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.tabConfigureShow(Sender: TObject);
begin
   lbColumns.Enabled     := true;
   lbColumns.MultiSelect := false;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmConfigure.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := BKH_Configure_columns;
   //Components
   btnUp.Hint            := 'Move the selected Column up the list|' +
                            'Move the selected Column up the list.  This will move the column to the left of the screen.';
   btnDown.Hint          := 'Move the selected Column down the list|' +
                            'Move the selected Column down the list.  This will move the column to the right of the screen.';
   btnRestoreOrder.Hint  := 'Restore the Default Order of all the Columns';

   btnRestoreWidth.Hint  := 'Restore the Default Widths of all the Columns';

   btnRestoreEdit.Hint   := 'Restore the Default Editable Status of all the Columns';

   btnRestoreVisible.Hint:= 'Restore the Default Visibility of all the Columns';

   btnRestoreAll.Hint    := 'Restore ALL Defaults for all the Columns|'+
                            'Restore ALL Defaults for all the Columns.  This means Order, Width, Editability and Visibility.';

   btnLoad.Hint          := 'Load a previously saved column layout template';

   btnSave.Hint          := 'Save this layout as a template';
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmConfigure.SaveTemplate;
var
  Filename : String;
  INIFile : TMemINIFile;
  i : Integer;
  ColumnConfig   : TColumnConfigInfo;
  cRec           : pColumnDefn;
begin
  //save template
  dlgSaveCLS.InitialDir := Globals.DataDir;

  if (dlgSaveCLS.Execute) then
  begin
    // save current dialog layout info from the config columns for
    // save other dialog layout info from the bank account record

    //make sure the filename has the correct extension
    Filename := dlgSaveCLS.FileName;
    i := Length(Filename);
    if (Copy(Filename, i-3, 4) <> '.cls') then
      Filename := Filename + '.cls';
    while BKFileExists(FileName) do
    begin
      if AskYesNo('Overwrite File','The file '+ExtractFileName(FileName)+' already exists. Overwrite?',dlg_yes,0) = DLG_YES then
        Break;
      if not dlgSaveCLS.Execute then exit;
      FileName := dlgSaveCLS.FileName;
      i := Length(Filename);
      if (Copy(Filename, i-3, 4) <> '.cls') then
        Filename := Filename + '.cls';
    end;
    INIFile := TMemINIFile.Create(FileName);
    try
      with INIFile do
      begin
        WriteString(FCodingScreen + SECTION_HEADER, 'Filename', ExtractFilename(dlgSaveCLS.FileName));
        WriteInteger(FCodingScreen + SECTION_HEADER, 'Columns', lbColumns.Items.Count);
        WriteInteger(FCodingScreen + SECTION_HEADER, 'SortBy', SortColumn);
        for i := 0 to lbColumns.Items.Count-1 do
        begin
          ColumnConfig := TColumnConfigInfo(lbColumns.Items.Objects[i]);
          with ColumnConfig do
          begin
            cRec := ColumnConfig.Ptr;
            WriteString(FCodingScreen + SECTION_COLUMN+IntToStr(i),';FieldName', cRec^.cdHeading);
            WriteInteger(FCodingScreen + SECTION_COLUMN+IntToStr(i), 'FieldID', cRec^.cdFieldId);
            WriteInteger(FCodingScreen + SECTION_COLUMN+IntToStr(i), 'Position', i);
            WriteInteger(FCodingScreen + SECTION_COLUMN+IntToStr(i), 'Width', ColWidth);
            WriteBool(FCodingScreen + SECTION_COLUMN+IntToStr(i), 'Hidden', VisibleState in [ vsNotVisible ]);
            WriteBool(FCodingScreen + SECTION_COLUMN+IntToStr(i), 'EditGeneral', EditState in [ esAlwaysEditable, esEditable]);
          end
        end;

{        // Write CES from bank account record
        if FCodingScreen <> CODING_SCREEN then
        begin
          ColCount := 0;
          for i := 0 to Length(FConfigBankAccount.baFields.baColumn_Width)-1 do
            if FConfigBankAccount.baFields.baColumn_Width[i] <> 0 then
              Inc(ColCount);
          WriteInteger(CODING_SCREEN + SECTION_HEADER, 'Columns', ColCount);
          WriteInteger(CODING_SCREEN + SECTION_HEADER, 'SortBy', FConfigBankAccount.baFields.baCoding_Sort_Order);
          for i := 0 to Length(FConfigBankAccount.baFields.baColumn_Width)-1 do
          begin
            if FConfigBankAccount.baFields.baColumn_Width[i] <> 0 then
            begin
              WriteInteger(CODING_SCREEN + SECTION_COLUMN+IntToStr(i), 'FieldID', i);
              WriteInteger(CODING_SCREEN + SECTION_COLUMN+IntToStr(i), 'Position', FConfigBankAccount.baFields.baColumn_Order[i]);
              WriteInteger(CODING_SCREEN + SECTION_COLUMN+IntToStr(i), 'Width', FConfigBankAccount.baFields.baColumn_Width[i]);
              WriteBool(CODING_SCREEN + SECTION_COLUMN+IntToStr(i), 'Hidden', FConfigBankAccount.baFields.baColumn_Is_Hidden[i]);
              WriteBool(CODING_SCREEN + SECTION_COLUMN+IntToStr(i), 'EditGeneral', not FConfigBankAccount.baFields.baColumn_Is_Not_Editable[i]);
            end;
          end;
        end;

        // Write dissection from bank account record
        if FCodingScreen <> DISSECTION_SCREEN then
        begin
          ColCount := 0;
          for i := 0 to Length(FConfigBankAccount.baFields.baDIS_Column_Width)-1 do
            if FConfigBankAccount.baFields.baDIS_Column_Width[i] <> 0 then
              Inc(ColCount);
          WriteInteger(DISSECTION_SCREEN + SECTION_HEADER, 'Columns', ColCount);
          WriteInteger(DISSECTION_SCREEN + SECTION_HEADER, 'SortBy', FConfigBankAccount.baFields.baDIS_Sort_Order);
          for i := 0 to Length(FConfigBankAccount.baFields.baDIS_Column_Width)-1 do
          begin
            if FConfigBankAccount.baFields.baDIS_Column_Width[i] <> 0 then
            begin
              WriteInteger(DISSECTION_SCREEN + SECTION_COLUMN+IntToStr(i), 'FieldID', i);
              WriteInteger(DISSECTION_SCREEN + SECTION_COLUMN+IntToStr(i), 'Position', FConfigBankAccount.baFields.baDIS_Column_Order[i]);
              WriteInteger(DISSECTION_SCREEN + SECTION_COLUMN+IntToStr(i), 'Width', FConfigBankAccount.baFields.baDIS_Column_Width[i]);
              WriteBool(DISSECTION_SCREEN + SECTION_COLUMN+IntToStr(i), 'Hidden', FConfigBankAccount.baFields.baDIS_Column_Is_Hidden[i]);
              WriteBool(DISSECTION_SCREEN + SECTION_COLUMN+IntToStr(i), 'EditGeneral', not FConfigBankAccount.baFields.baDIS_Column_Is_Not_Editable[i]);
            end;
          end;
        end;

        // Write MDE from bank account record
        if FCodingScreen <> MDE_SCREEN then
        begin
          ColCount := 0;
          for i := 0 to Length(FConfigBankAccount.baFields.baMDE_Column_Width)-1 do
            if FConfigBankAccount.baFields.baMDE_Column_Width[i] <> 0 then
              Inc(ColCount);
          WriteInteger(MDE_SCREEN + SECTION_HEADER, 'Columns', ColCount);
          WriteInteger(MDE_SCREEN + SECTION_HEADER, 'SortBy', FConfigBankAccount.baFields.baMDE_Sort_Order);
          for i := 0 to Length(FConfigBankAccount.baFields.baMDE_Column_Width)-1 do
          begin
            if FConfigBankAccount.baFields.baMDE_Column_Width[i] <> 0 then
            begin
              WriteInteger(MDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'FieldID', i);
              WriteInteger(MDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'Position', FConfigBankAccount.baFields.baMDE_Column_Order[i]);
              WriteInteger(MDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'Width', FConfigBankAccount.baFields.baMDE_Column_Width[i]);
              WriteBool(MDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'Hidden', FConfigBankAccount.baFields.baMDE_Column_Is_Hidden[i]);
              WriteBool(MDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'EditGeneral', not FConfigBankAccount.baFields.baMDE_Column_Is_Not_Editable[i]);
            end;
          end;
        end;

        // Write HDE from bank account record
        if FCodingScreen <> HDE_SCREEN then
        begin
          ColCount := 0;
          for i := 0 to Length(FConfigBankAccount.baFields.baHDE_Column_Width)-1 do
            if FConfigBankAccount.baFields.baHDE_Column_Width[i] <> 0 then
              Inc(ColCount);
          WriteInteger(HDE_SCREEN + SECTION_HEADER, 'Columns', ColCount);
          WriteInteger(HDE_SCREEN + SECTION_HEADER, 'SortBy', FConfigBankAccount.baFields.baHDE_Sort_Order);
          for i := 0 to Length(FConfigBankAccount.baFields.baMDE_Column_Width)-1 do
          begin
            if FConfigBankAccount.baFields.baHDE_Column_Width[i] <> 0 then
            begin
              WriteInteger(HDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'FieldID', i);
              WriteInteger(HDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'Position', FConfigBankAccount.baFields.baHDE_Column_Order[i]);
              WriteInteger(HDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'Width', FConfigBankAccount.baFields.baHDE_Column_Width[i]);
              WriteBool(HDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'Hidden', FConfigBankAccount.baFields.baHDE_Column_Is_Hidden[i]);
              WriteBool(HDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'EditGeneral', not FConfigBankAccount.baFields.baHDE_Column_Is_Not_Editable[i]);
            end;
          end;
        end; }

      end;
    finally
      DeleteFile(INIFile.FileName);
      INIFile.UpdateFile;
      INIFile.Free;
      HelpfulInfoMsg( 'Template saved to '+ FileName, 0 );
    end;
  end;
  SysUtils.SetCurrentDir(Globals.DATADIR);
end;

procedure TfrmConfigure.btnSaveClick(Sender: TObject);
begin
  SaveTemplate;
end;

procedure TfrmConfigure.LoadTemplate;
const
  SECTION_HEADER = 'Settings';
  SECTION_COLUMN = 'Column';
var
  INIFile : TMemINIFile;
  i, ColWidth : Integer;
  FieldID : Integer;
  PositionOfLastColumn : integer;
  cRec           : pColumnDefn;
  ColumnIndex : integer;
  ColumnCount : Integer;
  ColDefn : pColumnDefn;
  ColumnConfig   : TColumnConfigInfo;  
begin
  //load template
  dlgLoadCLS.InitialDir := Globals.DataDir;

  if (dlgLoadCLS.Execute) then
  begin
    INIFile := TMemINIFile.Create(dlgLoadCLS.FileName);
    try
      //build set of columns that are editable by default
      with INIFile do
      begin
        ColumnCount := ReadInteger(FCodingScreen + SECTION_HEADER, 'Columns', FColumnFormatList.ItemCount);
        SortColumn  := ReadInteger(FCodingScreen + SECTION_HEADER, 'SortBy', 1);
        //reset the required position of all columns so we can tell if any have not been set
        for i := 0 to FColumnFormatList.ItemCount-1 do
        begin
          ColDefn := FColumnFormatList.ColumnDefn_At(i);
          ColDefn^.cdRequiredPosition := -1;
        end;

        for i := 0 to ColumnCount-1 do
        begin
          //if (i < FColumnFormatList.ItemCount) then
          begin
            FieldID := ReadInteger(FCodingScreen + SECTION_COLUMN+IntToStr(i), 'FieldID', i);
            //Find the column defn rec in the list that matches this field ID
            ColumnIndex := FColumnFormatList.GetColNumOfField(FieldID);
            if (ColumnIndex <> -1) then
            begin
              ColDefn := FColumnFormatList.ColumnDefn_At(ColumnIndex);
              with ColDefn^ do
              begin
                ColWidth := ReadInteger(FCodingScreen + SECTION_COLUMN+IntToStr(i), 'Width', 60);
                if ColWidth <> 0 then
                begin
                  cdRequiredPosition := ReadInteger(FCodingScreen + SECTION_COLUMN+IntToStr(i), 'Position', i);
                  cdWidth            := ColWidth;
                  cdHidden           := ReadBool(FCodingScreen + SECTION_COLUMN+IntToStr(i), 'Hidden', False);
                  //make sure that the edit mode cannot be turned on for columns
                  //that should never be editable
                  if not (FieldID in FNeverEditable) then
                    cdEditMode[emGeneral] := ReadBool(FCodingScreen + SECTION_COLUMN+IntToStr(i), 'EditGeneral', False)
                  else
                    cdEditMode[emGeneral] := False;
                end else
                begin
                  //defaults will be used
                  cdWidth            := cdDefWidth;
                  cdRequiredPosition := cdDefPosition;
                  cdHidden           := cdDefHidden;
                  cdEditMode[ emGeneral] := (cdFieldId in FDefaultEditable);
                end;
              end;
            end
          end;
        end;

        PositionOfLastColumn := ColumnCount; //from INI file
        //move any columns that were not found in the ini file to the
        //end of the list, set them to default appearance
        for i := 0 to FColumnFormatList.ItemCount-1 do
        begin
          ColDefn := FColumnFormatList.ColumnDefn_At(i);
          if (ColDefn^.cdRequiredPosition = -1) then
          begin
            ColDefn^.cdRequiredPosition := PositionOfLastColumn;

            ColDefn^.cdWidth            := ColDefn^.cdDefWidth;
            ColDefn^.cdHidden           := ColDefn^.cdDefHidden;
            ColDefn^.cdEditMode[ emGeneral] := (ColDefn^.cdFieldId in FDefaultEditable);

            Inc(PositionOfLastColumn);
          end;
        end;

{        // Load other screens
        if FCodingScreen <> CODING_SCREEN then
          for i := 0 to Length(FConfigBankAccount.baFields.baColumn_Width)-1 do
          begin
            ColWidth := ReadInteger(CODING_SCREEN + SECTION_COLUMN+IntToStr(i), 'Width', 0);
            if ColWidth <> 0 then
            begin
              ColumnIndex := ReadInteger(CODING_SCREEN + SECTION_COLUMN+IntToStr(i), 'FieldID', i);
              FConfigBankAccount.baFields.baColumn_Order[ColumnIndex] := ReadInteger(CODING_SCREEN + SECTION_COLUMN+IntToStr(i), 'Position', ColumnIndex);
              FConfigBankAccount.baFields.baColumn_Width[ColumnIndex] := ColWidth;
              FConfigBankAccount.baFields.baColumn_Is_Hidden[ColumnIndex] := ReadBool(CODING_SCREEN + SECTION_COLUMN+IntToStr(i), 'Hidden', False);
              FConfigBankAccount.baFields.baColumn_Is_Not_Editable[ColumnIndex] := not ReadBool(CODING_SCREEN + SECTION_COLUMN+IntToStr(i), 'EditGeneral', True);
            end;
          end;

        if FCodingScreen <> DISSECTION_SCREEN then
          for i := 0 to Length(FConfigBankAccount.baFields.baDIS_Column_Width)-1 do
          begin
            ColWidth := ReadInteger(DISSECTION_SCREEN + SECTION_COLUMN+IntToStr(i), 'Width', 0);
            if ColWidth <> 0 then
            begin
              ColumnIndex := ReadInteger(DISSECTION_SCREEN + SECTION_COLUMN+IntToStr(i), 'FieldID', i);
              FConfigBankAccount.baFields.baDIS_Column_Order[ColumnIndex] := ReadInteger(DISSECTION_SCREEN + SECTION_COLUMN+IntToStr(i), 'Position', ColumnIndex);
              FConfigBankAccount.baFields.baDIS_Column_Width[ColumnIndex] := ColWidth;
              FConfigBankAccount.baFields.baDIS_Column_Is_Hidden[ColumnIndex] := ReadBool(DISSECTION_SCREEN + SECTION_COLUMN+IntToStr(i), 'Hidden', False);
              FConfigBankAccount.baFields.baDIS_Column_Is_Not_Editable[ColumnIndex] := not ReadBool(DISSECTION_SCREEN + SECTION_COLUMN+IntToStr(i), 'EditGeneral', True);
            end;
          end;

        if FCodingScreen <> HDE_SCREEN then
          for i := 0 to Length(FConfigBankAccount.baFields.baHDE_Column_Width)-1 do
          begin
            ColWidth := ReadInteger(HDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'Width', 0);
            if ColWidth <> 0 then
            begin
              ColumnIndex := ReadInteger(HDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'FieldID', i);
              FConfigBankAccount.baFields.baHDE_Column_Order[ColumnIndex] := ReadInteger(HDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'Position', ColumnIndex);
              FConfigBankAccount.baFields.baHDE_Column_Width[ColumnIndex] := ColWidth;
              FConfigBankAccount.baFields.baHDE_Column_Is_Hidden[ColumnIndex] := ReadBool(HDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'Hidden', False);
              FConfigBankAccount.baFields.baHDE_Column_Is_Not_Editable[ColumnIndex] := not ReadBool(HDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'EditGeneral', True);
            end;
          end;

        if FCodingScreen <> MDE_SCREEN then
          for i := 0 to Length(FConfigBankAccount.baFields.baMDE_Column_Width)-1 do
          begin
            ColWidth := ReadInteger(MDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'Width', 0);
            if ColWidth <> 0 then
            begin
              ColumnIndex := ReadInteger(MDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'FieldID', i);
              FConfigBankAccount.baFields.baMDE_Column_Order[ColumnIndex] := ReadInteger(MDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'Position', ColumnIndex);
              FConfigBankAccount.baFields.baMDE_Column_Width[ColumnIndex] := ColWidth;
              FConfigBankAccount.baFields.baMDE_Column_Is_Hidden[ColumnIndex] := ReadBool(MDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'Hidden', False);
              FConfigBankAccount.baFields.baMDE_Column_Is_Not_Editable[ColumnIndex] := not ReadBool(MDE_SCREEN + SECTION_COLUMN+IntToStr(i), 'EditGeneral', True);
            end;
          end;  }
      end;

      //now resort list into correct order based on the new required position
      FColumnFormatList.ReOrder;

      // Now reset the listbox
       //Assign Values to ListBox
       ColumnIndex := lbColumns.ItemIndex;
       lbColumns.Clear;
       ColumnListSwapped := True;
       //Build TColumnConfigInfo for the column that can be manipulated in dlg
       for i := 0 to Pred( FColumnFormatList.ItemCount ) do begin
          cRec := FColumnFormatList.ColumnDefn_At(i);
          ColumnConfig := TColumnConfigInfo.Create;
          with ColumnConfig do begin
             //set editable state
             if cRec.cdFieldID in AlwaysEditable then
                EditState := esAlwaysEditable
             else
             if cRec.cdFieldID in FNeverEditable then
                EditState := esNeverEditable
             else
             if cRec.cdEditMode[ emGeneral] then
                EditState := esEditable
             else
                EditState := esNotEditable;
             //set visible state
             if cRec.cdFieldID in AlwaysVisible then
                VisibleState := vsAlwaysVisible
             else
             if cRec.cdHidden then
                VisibleState := vsNotVisible
             else
                VisibleState := vsVisible;
             //set default width
             DefaultOrder    := cRec.cdDefPosition;
             ColWidth        := cRec.cdWidth;
             //set default col order
             DefaultWidth    := cRec.cdDefWidth;
             //set default visibility
             DefaultVisible := not cRec.cdDefHidden;
             //set pointer to cRec, used when rebuilding the column list
             Ptr             := cRec;
          end;
          lbColumns.Items.AddObject(cRec^.cdDescriptiveName, ColumnConfig);
       end;
       //set the selected col to the current active col
       lbColumns.ItemIndex := ColumnIndex;
    finally
      INIFile.Free;
    end;
  end;
  SysUtils.SetCurrentDir(Globals.DATADIR);
end;

procedure TfrmConfigure.btnLoadClick(Sender: TObject);
begin
  LoadTemplate;
  if lblSort.Visible then
    lblSort.Caption := 'Sort By: ' + csNames[SortColumn];
end;

procedure TfrmConfigure.FormShow(Sender: TObject);
begin
  GroupBox3.Visible := FShowTemplates;
  if SortColumn = -1 then
    lblSort.Visible := False
  else
  begin
    lblSort.Visible := False;
    lblSort.Caption := 'Sort By: ' + csNames[SortColumn];
  end;
end;

procedure TfrmConfigure.SetCodingScreen(Value: string);
begin
  FCodingScreen := Value;
  if FCodingScreen = DISSECTION_SCREEN then
    BKHelpSetUp(Self, BKH_Configuring_columns_for_dissections)
  else if (CodingScreen = MDE_SCREEN) or (FCodingScreen = HDE_SCREEN) then
    BKHelpSetUp(Self, BKH_Configuring_Columns_for_historical_and_manual_data_entry)
  else
    BKHelpSetUp(Self, BKH_Configure_columns);
end;

procedure TfrmConfigure.SetColumnListSwapped(const Value: Boolean);
begin
  FColumnListSwapped := Value;
end;

end.
