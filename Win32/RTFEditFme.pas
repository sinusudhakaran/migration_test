unit RTFEditFme;

interface

uses
   SYDEFS,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ImgList, WPAction, ActnList, WPCTRRich, Menus, WPRuler, WPRTEDefs,
  WPCTRMemo, RzCmboBx, StdCtrls, Mask, RzEdit, RzPanel, RzButton, WPTbar,
  WPPanel, ExtCtrls, WPUtil, WpPagPrp, wpManHeadFoot ,BKManageHeaderFooterDlg;

type
  TfmeEditRTF = class(TFrame)
    Panel1: TPanel;
    WPToolPanel1: TWPToolPanel;
    ERTF: TWPRichText;
    LeftRuler: TWPVertRuler;
    TopRuler: TWPRuler;
    EditActions: TActionList;
    actBold: TWPABold;
    actItalic: TWPAItalic;
    ActImages: TImageList;
    TopToolbar: TRzToolbar;
    btnBold: TRzToolButton;
    btnItalic: TRzToolButton;
    btnUnderline: TRzToolButton;
    RzSpacer1: TRzSpacer;
    BtnLeftJustify: TRzToolButton;
    BtnCenterJustify: TRzToolButton;
    BtnRightJustify: TRzToolButton;
    cbFont: TRzFontComboBox;
    cbColor: TRzColorEdit;
    cbSize: TRzComboBox;
    cbBackGround: TRzColorEdit;
    actUnderline: TWPAUnderline;
    actNormal: TWPANorm;
    actLeft: TWPALeft;
    actCenter: TWPACenter;
    actRight: TWPARight;
    actJustified: TWPAJustified;
    BtnCut: TRzToolButton;
    BtnUndo: TRzToolButton;
    BtnFind: TRzToolButton;
    BtnReplace: TRzToolButton;
    RzSpacer2: TRzSpacer;
    btnJustified: TRzToolButton;
    BtnCopy: TRzToolButton;
    Btnpaste: TRzToolButton;
    actUndo: TWPAUndo;
    actCopy: TWPACopy;
    actPaste: TWPAPaste;
    actCut: TWPACut;
    actSearch: TWPASearch;
    actReplace: TWPAReplace;
    RzSpacer3: TRzSpacer;
    editPopup: TPopupMenu;
    mniUndo: TMenuItem;
    N4: TMenuItem;
    mniCut: TMenuItem;
    mniCopy: TMenuItem;
    mniPaste: TMenuItem;
    N3: TMenuItem;
    mniInsertPicture: TMenuItem;
    mniInsertField: TMenuItem;
    N1: TMenuItem;
    mniPageSetup: TMenuItem;
    mniHeadersAndFooters: TMenuItem;
    actPageSetup: TAction;
    PagePropDlg: TWPPagePropDlg;
    HeaderFooterDlg: TWPManageHeaderFooterDlg;
    actHeaderFooter: TAction;
    actSellAll: TWPASellAll;
    SelectAll1: TMenuItem;
    N2: TMenuItem;
    Find1: TMenuItem;
    Replace1: TMenuItem;
    actDelete: TWPADeleteText;
    DeleteText1: TMenuItem;
    N5: TMenuItem;
    btnDelete: TRzToolButton;
    RzSpacer4: TRzSpacer;
    procedure ERTFCharacterAttrChange(Sender: TObject;
      Attribute: TWPSetModeControl);
    procedure cbColorChange(Sender: TObject);
    procedure cbBackGroundChange(Sender: TObject);
    procedure cbSizeChange(Sender: TObject);
    procedure mniInsertPictureClick(Sender: TObject);
    procedure cbFontChange(Sender: TObject);
    procedure ERTFKeyPress(Sender: TObject; var Key: Char);
    procedure actPageSetupExecute(Sender: TObject);
    procedure actHeaderFooterExecute(Sender: TObject);
  private
    FFullPageMode: Boolean;
    FEditMode: Boolean;
    function GetAsString: string;
    procedure SetAsString(const Value: string);
    procedure SetFullPageMode(const Value: Boolean);
    procedure SetEditMode(const Value: Boolean);
    procedure Changed;
    { Private declarations }
  public
    procedure DoMergeMenu(Sender: TObject);
    procedure DoStandardMergeMenu(Sender: TObject);
    property AsString: string read GetAsString write SetAsString;
    function AddMergeMenuItem(Value: string; Tag: Integer = 0; ToPopup: TmenuItem = nil): TmenuItem;
    procedure LoadGlobalMergeMenues;
    procedure DoClose;
    procedure Clear;
    property EditMode: Boolean read FEditMode write SetEditMode;
    property FullPageMode: Boolean read FFullPageMode write SetFullPageMode;
    { Public declarations }
  end;




implementation
uses
  ReportTypes,
  Globals,
  GlobalMergeFields;


{$R *.dfm}

procedure TfmeEditRTF.actHeaderFooterExecute(Sender: TObject);
begin
  HeaderFooterDlg.Execute;
end;

procedure TfmeEditRTF.actPageSetupExecute(Sender: TObject);
begin
  PagePropDlg.Execute;
end;

function TfmeEditRTF.AddMergeMenuItem(Value: string; Tag: Integer; ToPopup: TmenuItem): TmenuItem;
var P: Integer;
begin
   if ToPopup = nil then
      ToPopup := mniInsertField;

   Result := TmenuItem.Create(ToPopup);
   // Update the captions, when grouped.
   P := Pos('_',Value);
   if P > 0 then
      Result.Caption := Copy(Value,P+1,255)
   else
      Result.Caption := Value;

   ToPopup.Add(Result);
   Result.Tag := Tag;
   Result.OnClick := DoMergeMenu;
end;

procedure TfmeEditRTF.DoClose;
begin
   HeaderFooterDlg.Close;
   PagePropDlg.Close;
end;

procedure TfmeEditRTF.DoMergeMenu(Sender: TObject);
begin
   if sender is TMenuItem then
      with TMenuItem(sender) do begin
         if Tag = 0 then
            Exit;

         ERTF.InputMergeField( MergeFieldNames[TMergeFieldType(tag)],
                               MergeFieldNames[TMergeFieldType(tag)]);
         ERTF.Modified := True;
         if not EditMode then
            ERTF.MergeText(); // Dont want to see the Field..
      end;
end;

procedure TfmeEditRTF.DoStandardMergeMenu(Sender: TObject);
begin
   if sender is TMenuItem then
      with TMenuItem(sender) do begin

         ERTF.InputTextField(TWPTextFieldType(Tag));

         ERTF.Modified := True;
         if not EditMode then
            ERTF.MergeText(); // Dont want to see the Field..
      end;
end;

procedure TfmeEditRTF.cbBackGroundChange(Sender: TObject);
begin
   ERTF.CurrAttr.BKColor :=  ERTF.CurrAttr.ColorToNr(cbBackground.SelectedColor, True);
   ERTF.SetFocus;
   Changed;
end;

procedure TfmeEditRTF.cbColorChange(Sender: TObject);
begin
   ERTF.CurrAttr.Color :=  ERTF.CurrAttr.ColorToNr(cbColor.SelectedColor, True);
   ERTF.SetFocus;
   Changed;
end;


procedure TfmeEditRTF.cbFontChange(Sender: TObject);
begin
   ERTF.CurrAttr.FontName := cbFont.FontName;
   ERTF.SetFocus;
   Changed;
end;


procedure TfmeEditRTF.cbSizeChange(Sender: TObject);
begin
   ERTF.CurrAttr.Size := StrToInt(CbSize.Text);
   ERTF.SetFocus;
   Changed;
end;


procedure TfmeEditRTF.Changed;
begin
   if not ERTF.Modified then
      ERTF.Modified := True;
   if Assigned(ERTF.OnChange) then
      ERTF.OnChange(ERTF);
end;


procedure TfmeEditRTF.Clear;
begin
   ERTF.ClearEx(False,False,True);
end;

procedure TfmeEditRTF.ERTFCharacterAttrChange(Sender: TObject;
  Attribute: TWPSetModeControl);
var Color: tColor;
    bgcolor: Integer;
    fgcolor: Integer;
    fnt: TFontName;

    procedure SetSize(Value: string);
    var I: Integer;
    begin
       I := cbSize.Items.IndexOf(Value);
       if I >=0 then
          cbSize.ItemIndex := I
       else begin
          if Value <> '0' then
             cbSize.ItemIndex := cbSize.Items.Add(Value)
          else
             // Maybe multiple sizes selected.
             cbSize.ItemIndex := -1;
       end;
    end;
begin
   // Update the Tool bar..
   // Font colour
   if ERTF.CurrentCharAttr.getColor(Color) then
   else
      color := clBlack; //Prity save bet.. Look better than nothing
   cbColor.SelectedColor := Color;

   // Font Size
   SetSize(floatToStr(ERTF.CurrAttr.Size));

   // Font Name
   if ERTF.IsSelected then begin
      if not ERTF.SelectedTextAttr.GetFontName(fnt) then
         fnt := '  ';
   end else begin
      fnt :=  ERTF.CurrAttr.FontName;
   end;
   cbFont.FontName := fnt;

   // Paragraph Colour
   Color := clNone;
   if Assigned(ERTF.Memo.Cursor.active_paragraph) then begin
      bgcolor := 0;
      fgcolor := 0;
      ERTF.Memo.Cursor.active_paragraph.AGetFBBGCOlor(bgcolor, fgcolor);
      if bgcolor <> 0 then
         Color :=  ERTF.CurrAttr.NrToColor(bgcolor)
      else if fgcolor <> 0 then
         Color :=  ERTF.CurrAttr.NrToColor(fgcolor);
   end;
   cbBackGround.SelectedColor := Color;
end;


procedure TfmeEditRTF.ERTFKeyPress(Sender: TObject; var Key: Char);

  procedure ToggleStyle(sty : TOneWrtStyle);
  begin
    if sty in ERTF.CurrAttr.Style then
      ERTF.CurrAttr.DeleteStyle([sty])
    else ERTF.CurrAttr.AddStyle([sty]);
      ERTF.SetFocusValues(true);
  end;

begin
  if Key = Char(Integer('B') - 64) then // Ctrl + B
  begin
    ToggleStyle(afsBold);
    Key := #0;
  end else
  if Key = Char(Integer('I') - 64) then // Ctrl + I
  begin
    ToggleStyle(afsItalic);
    Key := #0;
  end else
  if Key = Char(Integer('U') - 64) then // Ctrl + U
  begin
    ToggleStyle(afsUnderline);
    Key := #0;
  end;

end;

function TfmeEditRTF.GetAsString: string;
begin
   if ERTF.IsEmpty then
      Result := ''
   else
      Result := ERTF.AsString;
end;

procedure TfmeEditRTF.LoadGlobalMergeMenues;
var
   I: Integer;
   LM: TmenuItem;

   const // The real ones are all in uppercase
   LWPTextFieldNames : array[TWPTextFieldType] of string =
       ('Page Num','Next Page','Prev Page','Num Pages','Date','Time','Section Pages');

   procedure AddDocMergeMenu(const value:TWPTextFieldType);
   begin
      AddMergeMenuItem(LWPTextFieldNames[value] ,Integer(value)).OnClick := DoStandardMergeMenu;
   end;

begin
   if Assigned(AdminSystem) then begin // User does not mean much in books
      LM := AddMergeMenuItem('User');
      for I := ord(User_First) to ord(User_Last) do
         AddMergeMenuItem(MergeFieldNames[TMergeFieldType(I)] ,I,LM);
   end;

   LM := AddMergeMenuItem('Client');
   for I := ord(Client_First) to ord(Client_Last) do
      AddMergeMenuItem(MergeFieldNames[TMergeFieldType(I)] ,I,LM);

   if Assigned(AdminSystem) then begin
      LM := AddMergeMenuItem('Practice');
      for I := ord(Practice_First) to ord(Practice_Last) do
         AddMergeMenuItem(MergeFieldNames[TMergeFieldType(I)] ,I,LM);
   end;

   // Standard..

   AddMergeMenuItem(MergeFieldNames[Document_Date] ,Integer(Document_Date));
   AddMergeMenuItem(MergeFieldNames[Document_Time] ,Integer(Document_Time));
   if FullPagemode then begin
      AddDocMergeMenu(wpoPageNumber);
      AddDocMergeMenu(wpoNumPages);
   end;


end;

procedure TfmeEditRTF.mniInsertPictureClick(Sender: TObject);
begin
   ERTF.InsertGraphicDialog;
end;

procedure TfmeEditRTF.SetAsString(const Value: string);
begin
   Clear;
   if Value > '' then
      ERTF.AsString := Value;
end;

procedure TfmeEditRTF.SetEditMode(const Value: Boolean);
begin
   FEditMode := Value;
   if FEditMode then begin
      ERTF.OnMailMergeGetText := nil;
      ERTF.InsertPointAttr.Hidden := False;
   end else begin
      ERTF.InsertPointAttr.Hidden := True;
      //ERTF.OnMailMergeGetText set by the implementation
   end;
end;

procedure TfmeEditRTF.SetFullPageMode(const Value: Boolean);
begin
  FFullPageMode := Value;
  // Hide the menu items if not full page mode
  actPageSetup.Visible := FFullPageMode;
  actHeaderFooter.Visible := FFullPageMode;
  N1.Visible := FFullPageMode;
end;

end.
