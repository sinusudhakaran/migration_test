unit ReportStyleDlg;

interface

uses
  ReportTypes,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ExtCtrls, TBX, TB2Item, TB2ExtItems, TBXLists, TBXExtItems,
  TB2Dock, TB2Toolbar, RzCmboBx, RzPanel, Mask, RzEdit, ImgList, RzButton,
  OsFont;

type
  TfrmReportStyle = class(TForm)
    pBtn: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    pPreview: TPanel;
    tbFont: TRzToolbar;
    cbReportItem: TRzComboBox;
    cbFont: TRzFontComboBox;
    cbColor: TRzColorEdit;
    cbSize: TRzComboBox;
    btnBold: TRzToolButton;
    btnItalic: TRzToolButton;
    btnUnderline: TRzToolButton;
    ImageList1: TImageList;
    Label2: TLabel;
    lClientName: TPanel;
    lTitle: TPanel;
    lSubTitle: TPanel;
    lHeading: TPanel;
    lFooter: TPanel;
    lFootNote: TPanel;
    lGrandTotal: TPanel;
    lSectionTitle: TPanel;
    lsectiontotal: TPanel;
    ldetail: TPanel;
    cbBackGround: TRzColorEdit;
    tbAlign: TRzToolbar;
    btnLeft: TRzToolButton;
    btnCentre: TRzToolButton;
    btnRight: TRzToolButton;
    btnBlinds: TRzToolButton;
    lNormal: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    btnSaveas: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure lableClick(Sender: TObject);
    procedure FontChange(Sender: TObject);
    procedure btnLeftClick(Sender: TObject);
    procedure cbReportItemChange(Sender: TObject);
    procedure btnSaveasClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fSetup: Boolean;
    fStyles: TStyleItems;
    FLastIndex: Integer;
    procedure SetColor (Value: TColor);
    function GetColor: TColor;
    procedure SetBackGround (Value: TColor);
    function GetBackGround: TColor;
    procedure GetStyleItem(Value: TStyleItem);
    procedure SetStyleItem(const Value: TStyleItem);
    function GetItemIndex: Integer;
    function GetAlignment: TAlignment;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetItemIndex(const Value: Integer);
    function GetLables(index: integer): TPanel;
    function GetStyleItems(index: integer): TStyleItem;
    procedure SetStyles(const Value: TStyleItems);
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property Lables [index :integer]: TPanel read GetLables;
    property StyleItems [index :integer]: TStyleItem read GetStyleItems;
    property Styles: TStyleItems read FStyles write SetStyles;
    { Private declarations }
  public
    { Public declarations }
  end;

function EditReportStyle(Value: TStyleItems ): Tmodalresult;


implementation

uses
  Globals,
  ImagesFrm,
  Printers, bkXPThemes;

function EditReportStyle;
begin
   Result := mrCancel;
   if Assigned(Value) then
      with TfrmReportStyle.Create(Application.Mainform) do
      try try
         Styles := Value;
         Result := showModal;
      except
      end;
      finally
         free;
      end;
end;

{$R *.dfm}

{ TForm2 }



procedure TfrmReportStyle.SetAlignment(const Value: TAlignment);
begin
   case Value of
      taLeftJustify: btnLeft.Down := True;
      taRightJustify: btnRight.Down := True;
      taCenter: btnCentre.Down := True;
   end;
end;

procedure TfrmReportStyle.SetBackGround(Value: TColor);
begin
   if Value = clWindow then
      Value := clWhite;
   cbBackGround.SelectedColor := Value;
end;

procedure TfrmReportStyle.SetColor(Value: TColor);
begin
   if Value = clWindowtext then
       Value := clBlack;

   cbColor.SelectedColor := Value;
end;


procedure TfrmReportStyle.btnLeftClick(Sender: TObject);
begin
   Lables[Itemindex].Alignment := GetAlignment;
   StyleItems[ItemIndex].Alignment := GetAlignment;
end;

procedure TfrmReportStyle.btnOKClick(Sender: TObject);
begin
   /// save...
   FStyles.DetailBlinds := btnBlinds.Down;
   ModalResult := mrOK;
end;

procedure TfrmReportStyle.btnSaveasClick(Sender: TObject);
begin
   FStyles.DetailBlinds := btnBlinds.Down;
   ModalResult := mrYes;
end;

procedure TfrmReportStyle.cbReportItemChange(Sender: TObject);
begin
   Itemindex := ItemIndex;
end;

procedure TfrmReportStyle.FontChange(Sender: TObject);
begin
   if not fSetup then begin
      GetStyleItem(Styleitems[ItemIndex]);
      StyleItems[ItemIndex].AssignTo(Lables[Itemindex]);
   end;
end;

procedure TfrmReportStyle.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm(Self);
   fLastIndex := -1;
   fStyles := nil
end;

procedure TfrmReportStyle.FormDestroy(Sender: TObject);
begin
   INI_CustomColors := AppImages.GlCustomColors.Colors.CommaText;
end;

function TfrmReportStyle.GetAlignment: TAlignment;
begin
 if btnLeft.Down then
    Result := taLeftJustify
 else if btnRight.Down then
    Result := taRightJustify
 else
    Result := taCenter;
end;

function TfrmReportStyle.GetBackGround: TColor;
begin
  Result := cbBackGround.selectedColor;
end;

function TfrmReportStyle.GetColor: TColor;
begin
   Result := cbColor.selectedColor;
end;

function TfrmReportStyle.GetItemIndex: Integer;
begin
   Result := cbReportItem.ItemIndex;
end;

function TfrmReportStyle.GetLables(index: integer): TPanel;
begin
    case TStyleTypes(index) of
    siTitle : Result := lTitle;
    siSubTitle : Result := lSubTitle;
    siHeading : Result := lHeading;
    siSectionTitle : Result := lSectionTitle;
    siSectionTotal : Result := lSectionTotal;
    siNormal : Result := lnormal;
    siDetail : Result := ldetail;
    siGrandTotal : Result := lGrandTotal;
    siFootNote : Result := lFootNote;
    siFooter : Result := lFooter;
    else Result := lClientName;
    end;
end;

procedure TfrmReportStyle.GetStyleItem(Value: TStyleItem);
var Style: TFontStyles;
    function GetSize: integer;
    var
       S: string;
       V,C : Integer;
    begin
       Result := 9;
       S := cbSize.Text;
       if S = '' then Exit;
       val(S,V,C);
       if (C <> 0) then Exit;
       if (V < 6) then Exit;
       if V > 48 then Exit;
       Result := V;
    end;
begin
   Value.FontName := cbFont.FontName;

   Value.Size := GetSize;

   Style := [];
   if btnBold.Down then
      Style := Style + [fsBold];
   if btnItalic.Down then
      Style := Style + [fsItalic];
   if btnUnderLine.Down then
      Style := Style + [fsUnderline];
   Value.Style := Style;
   Value.Alignment := GetAlignment;
   Value.Color := GetColor;
   Value.BackGround := GetBackground;
end;

function TfrmReportStyle.GetStyleItems(index: integer): TStyleItem;
begin
  if assigned(fStyles) then
     Result := fStyles.StyleItems[index]
  else
     Result := nil;
end;

procedure TfrmReportStyle.lableClick(Sender: TObject);
begin
   ItemIndex := TLabel(sender).Tag;
end;


procedure TfrmReportStyle.SetItemIndex(const Value: Integer);
begin
   if FLastIndex >= 0 then
      lables[FLastIndex].BorderStyle := bsnone;
   FLastIndex := Value;
   cbFont.PreviewText := lables[Value].Caption;

   lables[Value].BorderStyle := bsSingle;
   cbReportItem.ItemIndex := Value;

   TBAlign.Enabled := TStyleTypes(Value) in
        [siClientName,
         siTitle,
         siSubTitle,
         siSectionTitle];

   cbBackground.Enabled := TStyleTypes(Value) in
        [siClientName,
         siTitle,
         siSubTitle,
         siHeading,
         siSectionTitle,
         siSectionTotal,
         siDetail,
         siGrandTotal,
         siFooter];
         
   btnBlinds.Enabled := TStyleTypes(Value) in [siDetail];
   SetStyleItem(StyleItems[Value]);
end;

procedure TfrmReportStyle.SetStyleItem(const Value: TStyleItem);
begin
   fSetup := True;
   try
      cbFont.FontName := Value.FontName;
      btnBold.Down := fsBold in Value.Style;  //(fsBold, fsItalic, fsUnderline, fsStrikeOut)
      btnItalic.Down := fsItalic in Value.Style;
      btnUnderLine.Down := fsUnderline in Value.Style;
      cbSize.ItemIndex := cbSize.Items.IndexOf(intTostr(Value.Size));
      if cbSize.ItemIndex < 0 then // go back to default...
         cbSize.ItemIndex := cbSize.Items.IndexOf('9');
      SetColor(Value.Color);
      SetBackground(Value.BackGround);
      SetAlignment(Value.Alignment);
   finally
      fSetup := false;
   end;
end;



procedure TfrmReportStyle.SetStyles(const Value: TStyleItems);
var I: integer;
begin
   FStyles := Value;
   Caption := 'Edit Style [' + FStyles.Name + ']';
   cbReportItem.Items.BeginUpdate;
   try
        cbReportItem.Items.Clear;
        for I := ord(Low(TStyleTypes)) to ord(High(TStyleTypes)) do begin
           StyleItems[I].AssignTo(Lables[i]);
           cbReportItem.Items.Add (Lables[i].Caption);
        end;
   finally
     cbReportItem.Items.EndUpdate;
   end;
   btnBlinds.Down := FStyles.DetailBlinds;
   ItemIndex := 0;
end;

end.
