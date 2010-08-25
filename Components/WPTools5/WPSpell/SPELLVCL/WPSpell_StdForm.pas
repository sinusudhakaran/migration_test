// ----------------------------------------------------------------
// WPCubed SpellCheck - WPSPELL
// ----------------------------------------------------------------
// Standard SpellCheck Form
// ----------------------------------------------------------------
// Original Copyright (c) 1995-2002, Eminent Domain Software
// included in WPSpell used under OEM license
// Modifications Copyright (c) 2004, WPCubed GmbH, Munich
// Last Modification: 18.3.2006
// ----------------------------------------------------------------

unit WPSpell_STDForm;

interface

{$I WPSpell_INC.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,WPSpell_Language,ComCtrls, Menus
  {$IFDEF WPSPELL_DEMO} ,WPSpell_DemoDLL {$ELSE} ,WPSpell_Controller {$ENDIF};

{$I WPSpell_INC.INC}


type
  TWPSpellForm = class;

  TWPSpellForm = class(TForm)
    pnlMain: TPanel;
    edtReplace: TEdit;
    edtBadWord: TEdit;
    pnlLabels: TPanel;
    lblSuggestions: TLabel;
    lblReplace: TLabel;
    lblNotFound: TLabel;
    Panel1: TPanel;
    btnCancel: TBitBtn;
    btnHelp: TBitBtn;
    btnIgnore: TBitBtn;
    btnIgnoreAll: TBitBtn;
    btnOptions: TBitBtn;
    btnLearn: TBitBtn;
    btnReplace: TBitBtn;
    btnReplaceAll: TBitBtn;
    btnLanguage: TBitBtn;
    StatusBar1: TStatusBar;
    LanguagePopup: TPopupMenu;
    chDlgLanguage: TComboBox;
    Timer1: TTimer;
    procedure btnReplaceClick(Sender: TObject);
    procedure btnReplaceAllClick(Sender: TObject);
    procedure btnLearnClick(Sender: TObject);
    procedure btnSuggestClick(Sender: TObject);
    procedure btnIgnoreClick(Sender: TObject);
    procedure btnIgnoreAllClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnAClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure lstSuggestChange(Sender: TObject);
    procedure lstSuggestDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pnlMainResize(Sender: TObject);
    procedure edtReplaceChange(Sender: TObject);
    procedure btnOptionsClick(Sender: TObject);
    procedure edtReplaceKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnLanguageClick(Sender: TObject);
    procedure chDlgLanguageClick(Sender: TObject);
    procedure edtReplaceClick(Sender: TObject);
    procedure edtBadWordKeyPress(Sender: TObject; var Key: Char);
    procedure Timer1Timer(Sender: TObject);
    procedure edtReplaceKeyPress(Sender: TObject; var Key: Char);
  private
     lstSuggest      : TListBox;
     FSpellInterface : TWPSpellInterface;
     FKeyChanged, FLastWasReplaceSugg : Boolean;
  protected
    procedure SetLabelLanguage(LabelLanguage: TWPSLanguages);
  public
    function SpellCheck(AControl: TControl): Boolean;
    property SpellInterface : TWPSpellInterface read
      FSpellInterface write FSpellInterface;
    function NextWord : Boolean;
    procedure OnLanguageClick(Sender : TObject);
    procedure UpdatedLanguage;
    function  NextWordOrClose: Boolean;
  end;

implementation

{$R *.DFM}

const
  // Modal Results for Spell Dialog and CheckWord
  mrReplace = 20;
  mrAdd = 21;
  mrSkipOnce = 22;
  mrSkipAll = 23;
  mrReplaceAll = 24;
  mrSuggest = 25;

// OnClick event for the accent buttons

procedure TWPSpellForm.chDlgLanguageClick(Sender: TObject);
var MaxLabelWidth,i : Integer;
begin
   SetLabelLanguage(TWPSLanguages(chDlgLanguage.ItemIndex));

  MaxLabelWidth := lblNotFound.Width;
  for i := 0 to pnlLabels.ControlCount - 1 do
    if pnlLabels.Controls[i] is TLabel then
      if MaxLabelWidth < TLabel(pnlLabels.Controls[i]).Width then
        MaxLabelWidth := TLabel(pnlLabels.Controls[i]).Width;
  pnlLabels.Width := MaxLabelWidth + 10;
end;

// sets the label language

function CurrLanguage : TWPSLanguages;
begin
  if assigned(WPGetSpellCurrentLabelLanguage) then
       Result := WPGetSpellCurrentLabelLanguage
  else Result := WPSpellCurrentLabelLanguage;
end;

procedure TWPSpellForm.SetLabelLanguage(LabelLanguage: TWPSLanguages);
begin
  WPSpellCurrentLabelLanguage := LabelLanguage;
  Caption := cLabels[LabelLanguage][tlblTitle];
  lblNotFound.Caption := cLabels[LabelLanguage][tlblFound];
  lblReplace.Caption := cLabels[LabelLanguage][tlblReplace];
  lblSuggestions.Caption := cLabels[LabelLanguage][tlblSuggestions];
  btnReplace.Caption := cLabels[LabelLanguage][tbtnReplace];
  btnReplaceAll.Caption := cLabels[LabelLanguage][tbtnReplaceAll];
  btnLearn.Caption := cLabels[LabelLanguage][tbtnAdd];
  btnIgnore.Caption := cLabels[LabelLanguage][tbtnSkip];
  btnIgnoreAll.Caption := cLabels[LabelLanguage][tbtnSkipAll];

  btnOptions.Caption := cLabels[LabelLanguage][tbtnConfigure];
  // btnSuggest.Caption := cLabels[LabelLanguage][tbtnSuggest];
  btnCancel.Caption := cLabels[LabelLanguage][tbtnClose];
  btnHelp.Caption := cLabels[LabelLanguage][tbtnHelp];
                   

end;


function TWPSpellForm.SpellCheck(AControl: TControl): Boolean;
var s : string;
begin
   if NextWord then
   begin
     Show;
     edtReplace.SetFocus;
     Result := TRUE;
   end
   else
   begin
     // ShowMessage(cLabels[WPSpellCurrentLabelLanguage][tlblCompleteMesg]);
     s := cLabels[WPSpellCurrentLabelLanguage][tlblCompleteMesg];
     MessageBox(Handle, PChar(s), '', 0);
     Result := FALSE;
   end;
end;

function TWPSpellForm.NextWordOrClose: Boolean;
var s : string;
begin
   Result := NextWord;
   if Result then
   begin
       edtReplace.Text := edtBadWord.Text;
       edtReplace.SelectAll;
       edtReplace.SetFocus;
   end
   else
   begin
     // ShowMessage(cLabels[WPSpellCurrentLabelLanguage][tlblCompleteMesg]);
     s := cLabels[WPSpellCurrentLabelLanguage][tlblCompleteMesg];
     MessageBox(Handle, PChar(s), '', 0);
     //optional: SpellInterface.ToStart;
     Close;
   end;
end;

// Locates next wrong word
function TWPSpellForm.NextWord : Boolean;
var
   s : String;
   Mode: TWPInDictionaryMode;
   Res: TWPInDictionaryResult;
   languageid, lang : Integer;
begin
  Mode := [wpAutoOpenDictionaries];
  Result := FALSE;
  SpellInterface.StartNextWord;
  lang := SpellInterface.SpellController.CurrentLanguage;
  if SpellInterface<>nil then
  while true do
  begin
    languageid := lang;
    s := SpellInterface.GetNextWord(languageid);
    Res := [];
    if s='' then exit;
    if (languageid<>0) and (languageid<>SpellInterface.SpellController.CurrentLanguage) then
           SpellInterface.SpellController.CurrentLanguage := languageid;
    if
     {$IFDEF IGNOREONECHARS}
     (Length(s) > 1) and
    {$ENDIF}
    not SpellInterface.SpellController.InDictionary(s, Mode, Res) then
    begin
      edtBadWord.Text := s;
      SpellInterface.SaveState;
      lstSuggest.Items.Clear;
      SpellInterface.SpellController.Suggest(
        s,
        lstSuggest.Items,
        20);
      SpellInterface.MoveCursor;
      Result := TRUE;
      break;
    end;
  end;
end;

procedure TWPSpellForm.btnReplaceClick(Sender: TObject);
begin
  if SpellInterface.RestoreState then
  SpellInterface.Replace(edtBadWord.Text, edtReplace.Text);
  NextWordOrClose;
end;

procedure TWPSpellForm.btnReplaceAllClick(Sender: TObject);
begin
  SpellInterface.ReplaceAll(edtBadWord.Text, edtReplace.Text);
end;

procedure TWPSpellForm.btnLearnClick(Sender: TObject);
begin
  SpellInterface.SpellController.AddWord(edtBadWord.Text,'', wpUserAdded );
  SpellInterface.IgnoreAll(edtBadWord.Text);
  NextWordOrClose;
end;

procedure TWPSpellForm.btnSuggestClick(Sender: TObject);
var
  TempList: TStringList;
begin
  TempList:= TStringList.Create;
  SpellInterface.SpellController.Suggest(edtReplace.Text, TempList, 30);
  lstSuggest.Items.Assign(TempList);
  TempList.Free;
end;

procedure TWPSpellForm.btnIgnoreClick(Sender: TObject);
begin
  SpellInterface.Ignore(edtBadWord.Text);
  NextWordOrClose;
end;

procedure TWPSpellForm.btnIgnoreAllClick(Sender: TObject);
begin
  SpellInterface.IgnoreAll(edtBadWord.Text);
  NextWordOrClose;  
end;

procedure TWPSpellForm.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TWPSpellForm.btnAClick(Sender: TObject);
begin
  if Sender is TSpeedButton then
    edtReplace.SelText := TSpeedButton(Sender).Caption[1];
end;

  // custom TListbox
 type  TNewListBox = class(TListBox)
  private
    { Private declarations }
    FOnChange: TNotifyEvent;
    FLastSel: integer;
  protected
    { Protected declarations }
    procedure Change; virtual;
    procedure Click; override;
  published
    { Published declarations }
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure SetFocus; override;
  end; { TNewListBox }

  constructor TNewListBox.Create;
begin
  inherited Create(AOwner);
  FLastSel := -1;
end; { TNewListBox.Create }

procedure TNewListBox.SetFocus;
begin
   if (Items.Count>0) and (ItemIndex=-1) then ItemIndex := 0;
   inherited SetFocus;
end;

procedure TNewListBox.Change;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end; { TNewListBox.Change }

procedure TNewListBox.Click;
begin
  inherited Click;
  if FLastSel <> ItemIndex then
    Change;
end; { TNewListBox.Click }

procedure TWPSpellForm.FormCreate(Sender: TObject);
var t : Integer;
begin
  if HelpContext = 0 then btnHelp.Visible := FALSE;
  lstSuggest := TNewListBox.Create(Self);
  t := edtReplace.Top + edtReplace.Height + 4;
  lstSuggest.SetBounds(edtReplace.Left,t,edtReplace.Width, pnlMain.Height -10 - t);
  lstSuggest.Parent := pnlMain;
  lstSuggest.OnDblClick := lstSuggestDblClick;
  lstSuggest.OnKeyPress := edtReplaceKeyPress;
  TNewListBox(lstSuggest).OnChange := lstSuggestChange;
  {center the dialog on the screen}
  Left := (Screen.Width div 2) - (Width div 2);
  {$IFNDEF SHOW_LANGUAGE_COMBO}
  chDlgLanguage.Visible := FALSE;
  {$ENDIF}
  {$IFDEF WPSPELL_DEMO}
   StatusBar1.SimpleText := '  This is the WPSpell DEMO - Info: www.wpcubed.com';
  {$ENDIF}
end;

// on click for help

procedure TWPSpellForm.btnHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

// when the suggest list changes

procedure TWPSpellForm.lstSuggestChange(Sender: TObject);
begin
  edtReplace.Text := lstSuggest.Items[lstSuggest.ItemIndex];
end;

// when the suggest list is clicked

procedure TWPSpellForm.lstSuggestDblClick(Sender: TObject);
begin
  if lstSuggest.ItemIndex <> -1 then
  begin
     if SpellInterface.RestoreState then
     SpellInterface.Replace(edtBadWord.Text, lstSuggest.Items[lstSuggest.ItemIndex]);
     NextWordOrClose;
  end;
end;

// displays the form

procedure TWPSpellForm.FormShow(Sender: TObject);
var
  MaxLabelWidth: integer;
  i: integer;
  MItem : TMenuItem;
begin
  edtReplace.Text := ''; //<-- !

  // Apply global language setting
  SetLabelLanguage(CurrLanguage);

  // set the size of the labels panel
  MaxLabelWidth := lblNotFound.Width;
  for i := 0 to pnlLabels.ControlCount - 1 do
    if pnlLabels.Controls[i] is TLabel then
      if MaxLabelWidth < TLabel(pnlLabels.Controls[i]).Width then
        MaxLabelWidth := TLabel(pnlLabels.Controls[i]).Width;
  pnlLabels.Width := MaxLabelWidth + 10;

  // set the width of the form
  Width := pnlLabels.Width + 550; // pnlMain.Width;

  if SpellInterface<>nil then
  begin
    {$IFDEF OLDDELPHI}
    while LanguagePopup.Items.Count>0 do
       LanguagePopup.Items.Delete(LanguagePopup.Items.Count-1);
    {$ELSE}
    LanguagePopup.Items.Clear;
    {$ENDIF}
    for i:= 0 to SpellInterface.SpellController.LanguageIDCount-1 do
    begin
       MItem := TMenuItem.Create(LanguagePopup);
       MItem.Caption := SpellInterface.SpellController.LanguageName[i];
       MItem.Tag     := SpellInterface.SpellController.LanguageId[i];
       MItem.OnClick := OnLanguageClick;
       LanguagePopup.Items.Add(MItem);
    end;
    btnLanguage.Caption := SpellInterface.SpellController.CurrentLanguageName;
  end;
end;

procedure TWPSpellForm.OnLanguageClick(Sender : TObject);
begin
  SpellInterface.SpellController.CurrentLanguage := (Sender as TMenuItem).Tag;
  btnLanguage.Caption := SpellInterface.SpellController.CurrentLanguageName;
  UpdatedLanguage;
end;

procedure TWPSpellForm.pnlMainResize(Sender: TObject);
begin
  edtBadWord.Left := 4;
  edtReplace.Left := 4;
  edtBadWord.Width := pnlMain.Width - edtBadWord.Left -8;
  edtReplace.Width := pnlMain.Width - edtReplace.Left -8;
 // edtBadWord.Width := pnlMain.Width - edtBadWord.Left *2;
  btnLanguage.Top := pnlMain.Height - btnLanguage.Height - 6;
  btnLanguage.Left := pnlMain.Width - btnLanguage.Width - 4;
  lstSuggest.Left := 4;
  lstSuggest.Width := pnlMain.Width - 8;
  lstSuggest.Height := btnLanguage.Top - lstSuggest.Top-2;
end;

procedure TWPSpellForm.edtReplaceChange(Sender: TObject);
begin
 Timer1.Enabled := TRUE;
end; 

procedure TWPSpellForm.UpdatedLanguage;
begin
  btnLanguage.Caption := SpellInterface.SpellController.CurrentLanguageName;
  if FLastWasReplaceSugg then
  begin
    FKeyChanged := true;
    edtReplaceChange(nil);
  end else
  SpellInterface.SpellController.Suggest(
        edtBadWord.Text,
        lstSuggest.Items,
        20);
  SpellInterface.DoSpellAsYouGo;
end;

procedure TWPSpellForm.btnOptionsClick(Sender: TObject);
begin
  {$IFNDEF WPSPELL_DEMO}
  SpellInterface.SpellController.DlgLeft := Left;
  SpellInterface.SpellController.DlgTop := Top;
  {$ENDIF}
  SpellInterface.Configure;
  UpdatedLanguage;
end;

procedure TWPSpellForm.edtReplaceKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FKeyChanged := TRUE;
end;

procedure TWPSpellForm.btnLanguageClick(Sender: TObject);
var p : TPoint;
begin
  p := btnLanguage.ClientToScreen(Point(0,btnLanguage.Height+1));
  LanguagePopup.Popup(p.x,p.y);
end;



procedure TWPSpellForm.edtReplaceClick(Sender: TObject);
begin
  if edtReplace.Text='' then
  begin
     edtReplace.Text := edtBadWord.Text;
     edtReplace.SelectAll;
  end;
end;

procedure TWPSpellForm.edtBadWordKeyPress(Sender: TObject; var Key: Char);
var cp, sl : Integer;
begin
  if Key>=#32 then
  begin
   cp := edtBadWord.SelStart;
   sl := edtBadWord.SelLength;
   edtReplace.Text := edtBadWord.Text;
   edtReplace.SetFocus;
   edtReplace.SelStart := cp;
   if sl>0 then edtReplace.SelLength := sl;
   SendMessage(edtReplace.Handle, WM_CHAR, Integer(Key), 0);
  end;
end;

procedure TWPSpellForm.Timer1Timer(Sender: TObject);
var
  TempList: TStringList;
begin
  if FKeyChanged then
  begin
    FKeyChanged := FALSE;
    Timer1.Enabled := FALSE;
  TempList:= TStringList.Create;
  if Length(edtReplace.Text)<2 then
       SpellInterface.SpellController.Suggest(edtBadWord.Text, TempList, 20)
  else if Length(edtReplace.Text)>1 then
       SpellInterface.SpellController.Suggest(edtReplace.Text, TempList, 30, [wpSuggestStartChar]);
  if TempList.Count>0 then
     lstSuggest.Items.Assign(TempList)
  else lstSuggest.Items.Clear;
  TempList.Free;
  FLastWasReplaceSugg := TRUE;
  end;
end;

procedure TWPSpellForm.edtReplaceKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then
  begin
     Key := #0;
     if (Sender = lstSuggest) and
     (lstSuggest.ItemIndex>=0) then
     begin
         edtReplace.Text := lstSuggest.Items[lstSuggest.ItemIndex];
         edtReplace.SetFocus;
     end else if
     Sender = edtReplace then btnReplaceClick(nil);
  end;
end;

end.
