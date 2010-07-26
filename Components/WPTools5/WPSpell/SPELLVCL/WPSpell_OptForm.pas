// ----------------------------------------------------------------
// WPCubed SpellCheck - WPSPELL
// ----------------------------------------------------------------
// SpellCheck Options Form
// ----------------------------------------------------------------
// Copyright (c) 2004, WPCubed GmbH, Munich
// Last Modification: 27.9.2005
// ----------------------------------------------------------------
unit WPSpell_OptForm;

{---$DEFINE HIDE_WPSpellLabel}
{--$DEFINE OLDDELPHI}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, ComCtrls, ExtCtrls, WPSpell_Controller,
  ImgList, Menus, Buttons, WPSpell_Language, ShellAPI;

type
  TWPSpellOptions = class(TWPCustomSpellOptionForm)
    PageControl1: TPageControl;
    Panel1: TPanel;
    btnOK: TButton;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    allDictsTree: TTreeView;
    TabSheet3: TTabSheet;
    btnLoadDCT: TButton;
    btnEnableDCT: TButton;
    btnRemoveUserDict: TButton;
    btnAddUserDict: TButton;
    btnMakeStandard: TButton;
    chkCompound: TCheckBox;
    chkCaptital: TCheckBox;
    chkIgnoreCAPS: TCheckBox;
    chkIgnoreNumbers: TCheckBox;
    lstUserDicts: TListBox;
    OpenDictsDialog: TOpenDialog;
    ImageList1: TImageList;
    btnRemoveDCT: TButton;
    chkAutoCASE: TCheckBox;
    chkAutocorrectAutoWords: TCheckBox;
    chkSpellAsYouGo: TCheckBox;
    btnLanguage: TBitBtn;
    labSelLanguage: TLabel;
    LanguagePopup: TPopupMenu;
    WPSpellLabel: TLabel;
    chDlgLanguage: TComboBox;
    btnEditUserDict: TButton;
    procedure lstUserDictsClick(Sender: TObject);
    procedure btnAddUserDictClick(Sender: TObject);
    procedure btnMakeStandardClick(Sender: TObject);
    procedure btnRemoveUserDictClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnLoadDCTClick(Sender: TObject);
    procedure allDictsTreeChange(Sender: TObject; Node: TTreeNode);
    procedure btnEnableDCTClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnRemoveDCTClick(Sender: TObject);
    procedure allDictsTreeEditing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure chkIgnoreNumbersClick(Sender: TObject);
    procedure btnLanguageClick(Sender: TObject);
    procedure allDictsTreeKeyPress(Sender: TObject; var Key: Char);
    procedure btnOKClick(Sender: TObject);
    procedure chDlgLanguageClick(Sender: TObject);
    procedure btnEditUserDictClick(Sender: TObject);
  private
    FUpdating : Boolean;
    procedure UseDictInfoClick(Sender : TObject);
  public
    procedure SetLabelLanguage(LabelLanguage: TWPSLanguages);
    function currdct : TWPDCT;
    procedure UpdateUserDicts;
    procedure UpdateMainDicts;
    procedure OnLanguageClick(Sender : TObject);
    procedure EditUserDict(user : TWPUserDic);
  end;

var
  WPSpellOptions: TWPSpellOptions;

implementation

{$R *.dfm}

{$I WPLanguages.INC}

procedure TWPSpellOptions.lstUserDictsClick(Sender: TObject);
begin
 btnRemoveUserDict.Enabled := lstUserDicts.ItemIndex>=0;
 btnMakeStandard.Enabled := lstUserDicts.ItemIndex>=0;

end;

procedure TWPSpellOptions.UpdateUserDicts;
var i : Integer;
    dict : TWPUserDic;
    s : string;
begin
  lstUserDicts.Items.Clear;
  for i:=0 to SpellControler.UserDictCount-1 do
  begin
     dict := SpellControler.UserDict[i];
     s := dict.FileName;
     if Length(s)>40 then
        s := '...'+ Copy(s,Length(s)-40,41);
     lstUserDicts.Items.AddObject(s, dict);
  end;
end;

function CurrLanguage : TWPSLanguages;
begin
  if assigned(WPGetSpellCurrentLabelLanguage) then
       Result := WPGetSpellCurrentLabelLanguage
  else Result := WPSpellCurrentLabelLanguage;
end;

procedure TWPSpellOptions.btnAddUserDictClick(Sender: TObject);
begin
  OpenDictsDialog.Filter := cLabels[CurrLanguage][tlblFilterDIC];
  OpenDictsDialog.DefaultExt := '.DIC';
  OpenDictsDialog.Options :=
      [ofHideReadOnly,ofNoValidate,ofPathMustExist,ofCreatePrompt,
       ofNoNetworkButton,ofEnableSizing
       {$IFNDEF OLDDELPHI}
         ,ofDontAddToRecent
       {$ENDIF} ];
  if OpenDictsDialog.Execute then
  begin
     if not FileExists(OpenDictsDialog.FileName) then
        OpenDictsDialog.FileName :=
          ChangeFileExt(OpenDictsDialog.FileName, '.DIC');
     SpellControler.UserDictAdd(OpenDictsDialog.FileName);
     UpdateUserDicts;
     SpellControler.InitialDirectory :=
       ExtractFilePath(OpenDictsDialog.FileName);
  end;
end;

procedure TWPSpellOptions.btnMakeStandardClick(Sender: TObject);
begin
  if lstUserDicts.ItemIndex>=0 then
     TWPUserDic(lstUserDicts.Items.Objects[lstUserDicts.ItemIndex]).Standard := TRUE;
  UpdateUserDicts;
end;

procedure TWPSpellOptions.btnRemoveUserDictClick(Sender: TObject);
begin
  if lstUserDicts.ItemIndex>=0 then
     TWPUserDic(lstUserDicts.Items.Objects[lstUserDicts.ItemIndex]).Remove;
  UpdateUserDicts;
end;

procedure TWPSpellOptions.UseDictInfoClick(Sender : TObject);
begin
   ShowMessage( UserDictInfoHint );

end;

procedure TWPSpellOptions.EditUserDict(user : TWPUserDic);
 var
  Memo1: TMemo;
  Panel1: TPanel;
  Button1: TButton;
  Button2: TButton;
  Button3: TButton;
  aForm : TForm;
begin
  aForm := TForm.Create(nil);
  aForm.Width := 210;
  aForm.Height := 400;
  aForm.Left := Left;
  aForm.Top := Top;
  aForm.Caption := ExtractFileName(user.FileName);
  Memo1 := TMemo.Create(aForm);
  Panel1 := TPanel.Create(aForm);
  Button1 := TButton.Create(aForm);
  Button2 := TButton.Create(aForm);
  Button3 := TButton.Create(aForm);
  with Memo1 do
  begin
    Parent := aForm;
    Left := 0;
    Top := 0;
    Align := alClient;
    ScrollBars := ssVertical;
    TabOrder := 0;
  end;
  with Panel1 do
  begin
    Parent := aForm;
    Caption := '';
    Left := 0;
    Top := 312;
    Width := 275;
    Height := 41;
    Align := alBottom;
    TabOrder := 1;
  end;
  with Button1 do
  begin
    Parent := Panel1;
    Left := 9;
    Top := 9;
    Width := 75;
    Height := 25;
    Caption := 'OK';
    ModalResult := 1;
    TabOrder := 0;
  end;
  with Button2 do
  begin
    Parent := Panel1;
    Left := 86;
    Top := 9;
    Width := 75;
    Height := 25;
    Caption := 'Cancel';
    ModalResult := 2;
    TabOrder := 1;
  end;
  with Button3 do
  begin
    Parent := Panel1;
    Left := 86+75+2;
    Top := 9;
    Width := 25;
    Height := 25;
    Caption := '?';
    TabOrder := 2;
    OnClick := UseDictInfoClick;
  end;
  try
    Memo1.Lines.Clear;
    user.ListWords(Memo1.Lines);
    if aForm.ShowModal=IDOK then
    begin
      Memo1.Lines.SaveToFile(user.FileName);
      user.Load;
    end;
  finally
    aForm.Free;
  end; 
end;

procedure TWPSpellOptions.btnEditUserDictClick(Sender: TObject);
begin
  if lstUserDicts.ItemIndex>=0 then
     EditUserDict(TWPUserDic(lstUserDicts.Items.Objects[lstUserDicts.ItemIndex]));
end;

procedure TWPSpellOptions.FormCreate(Sender: TObject);
begin
  lstUserDicts.BoundsRect := allDictsTree.BoundsRect;
  {$IFNDEF SHOW_LANGUAGE_COMBO}
  chDlgLanguage.Visible := FALSE;
  {$ENDIF} 
  {$IFDEF HIDE_WPSpellLabel}
  WPSpellLabel.Visible := FALSE;
  {$ENDIF}
  {$IFDEF WPSPELL_DEMODLL}
  WPSpellLabel.Visible := TRUE;
  WPSpellLabel.Font.Color := clRed;
  WPSpellLabel.Caption := 'This is the WPSpell DEMO - Info: www.wpcubed.com';
  {$ENDIF}
  // Apply global language setting
  SetLabelLanguage(CurrLanguage);
end;

procedure TWPSpellOptions.chDlgLanguageClick(Sender: TObject);
begin
  SetLabelLanguage(TWPSLanguages(chDlgLanguage.ItemIndex));
end;

procedure TWPSpellOptions.SetLabelLanguage(LabelLanguage: TWPSLanguages);
begin
  WPSpellCurrentLabelLanguage := LabelLanguage;
  Caption := cLabels[LabelLanguage][tlblTitleOptions];
  TabSheet1.Caption := cLabels[LabelLanguage][tlblTabDictionaries];
  TabSheet2.Caption := cLabels[LabelLanguage][tlblTabUserDict];
  TabSheet3.Caption := cLabels[LabelLanguage][tlblTabSpellCheckOpt];
  btnLoadDCT.Caption := cLabels[LabelLanguage][tlblAddDictionaries];
  btnEnableDCT.Caption := cLabels[LabelLanguage][tlblEnableDisable];
  btnRemoveDCT.Caption := cLabels[LabelLanguage][tlblRemoveDCT];
  labSelLanguage.Caption := cLabels[LabelLanguage][tlblDefaultLanguage];
  btnMakeStandard.Caption := cLabels[LabelLanguage][tlblUserDictStandard];
  btnAddUserDict.Caption := cLabels[LabelLanguage][tlblUserDictAdd];
  btnRemoveUserDict.Caption := cLabels[LabelLanguage][tlblUserDictRemove];
  btnEditUserDict.Caption := cLabels[LabelLanguage][tlblUserDictEdit];
  // Checkboxes
  chkCompound.Caption := cLabels[LabelLanguage][tlblOptNoCompoundWord];
  chkCaptital.Caption := cLabels[LabelLanguage][tlblOptIgnoreCase];
  chkIgnoreCAPS.Caption := cLabels[LabelLanguage][tlblOptIgnoreCAPSWords];
  chkIgnoreNumbers.Caption := cLabels[LabelLanguage][tlblOptIgnoreWordsWithNums];
  chkSpellAsYouGo.Caption := cLabels[LabelLanguage][tlblOptSpellAsYouGo];
  chkAutoCASE.Caption := cLabels[LabelLanguage][tlblOptAutocorrectCaseMistakes];
  chkAutocorrectAutoWords.Caption := cLabels[LabelLanguage][tlblOptAutoCorrectUserDict];

  btnOK.Caption := cLabels[LabelLanguage][tlblOptOK];
end;

procedure TWPSpellOptions.allDictsTreeEditing(Sender: TObject;
  Node: TTreeNode; var AllowEdit: Boolean);
begin
  AllowEdit := FALSE;
end;

procedure TWPSpellOptions.UpdateMainDicts;
var i, j, l : Integer;
    node, cnode : TTreeNode;
    dct  : TWPDCT;
    s : string;
    MItem : TMenuItem;
    defid, defidneed : Integer;
begin
  allDictsTree.Items.Clear;
  defid := SpellControler.CurrentLanguage;
  defidneed := -1;
  for i:= 0 to SpellControler.LanguageIDCount-1 do
  begin
    l := SpellControler.LanguageID[i]; // This is the group ID !
    s := wplanguages[0].name;
    for j := 0 to length(wplanguages)-1 do
       if wplanguages[j].id=l then
       begin
         s := wplanguages[j].name;
         break;
       end;
    node := allDictsTree.Items.AddChild(nil, s);
    node.ImageIndex := 0;
    node.SelectedIndex := 1;
    node.Data := nil;
    for j := 0 to SpellControler.DCTCount-1 do
    begin
      dct := SpellControler.DCT[j];
      if defid=dct.LanguageIDGroup then
         defid := -1;
      if dct.LanguageIDGroup=l then   // NOT: dct.LanguageID
      begin
        cnode := allDictsTree.Items.AddChild(node,dct.Name);
        if dct.Disabled then
             cnode.ImageIndex := 3
        else
        begin
           cnode.ImageIndex := 2;
           if defidneed<0 then           //<--- The first enabled!
              defidneed := dct.LanguageIDGroup;
        end;
        cnode.SelectedIndex := cnode.ImageIndex;
        cnode.Data := dct;
      end;
    end;
  end;

  // We didn't found an entry!
  if defid>=0 then
  begin
     if defidneed<0 then
        SpellControler.CurrentLanguage := 0
     else SpellControler.CurrentLanguage := defidneed;  
  end;

    LanguagePopup.Items.Clear;
    for i:= 0 to SpellControler.LanguageIDCount-1 do
    begin
       MItem := TMenuItem.Create(LanguagePopup);
       MItem.Caption := SpellControler.LanguageName[i];
       MItem.Tag     := SpellControler.LanguageId[i];
       MItem.OnClick := OnLanguageClick;
       LanguagePopup.Items.Add(MItem);
    end;
    btnLanguage.Caption := SpellControler.CurrentLanguageName;
end;

procedure TWPSpellOptions.btnLoadDCTClick(Sender: TObject);
var i : Integer;
begin
  OpenDictsDialog.Filter := cLabels[CurrLanguage][tlblFilterDCT];
  OpenDictsDialog.DefaultExt := '.DCT';
  OpenDictsDialog.Options :=
  [ofHideReadOnly,ofAllowMultiSelect,ofPathMustExist,ofFileMustExist,ofEnableSizing,ofDontAddToRecent];
  if OpenDictsDialog.Execute then
  begin
     for i:=0 to OpenDictsDialog.Files.Count-1 do
      SpellControler.AddFromFile(OpenDictsDialog.Files[i]);
     UpdateMainDicts;
     SpellControler.InitialDirectory :=
       ExtractFilePath(OpenDictsDialog.FileName);
  end;
end;

procedure TWPSpellOptions.allDictsTreeChange(Sender: TObject;
  Node: TTreeNode);
var dct : TWPDCT;
begin
  if allDictsTree.Selected<>nil then
       dct := TWPDCT(allDictsTree.Selected.Data)
  else dct := nil;

  if (dct=nil) then
  begin
    btnEnableDCT.Enabled := FALSE;
    btnEnableDCT.Caption := cLabels[CurrLanguage][tlblEnableDisable];
    allDictsTree.Hint := '';
    allDictsTree.ShowHint := FALSE;
  end else
  begin
    btnEnableDCT.Enabled := TRUE;
    if dct.Disabled then
         btnEnableDCT.Caption := cLabels[CurrLanguage][tlblEnable]
    else btnEnableDCT.Caption := cLabels[CurrLanguage][tlblDisable];
    allDictsTree.Hint := dct.Filename;
    allDictsTree.ShowHint := TRUE;
  end;   
end;

function TWPSpellOptions.currdct : TWPDCT;
begin
   if allDictsTree.Selected<>nil then
       Result := TWPDCT(allDictsTree.Selected.Data)
   else Result := nil;
end;

procedure TWPSpellOptions.btnEnableDCTClick(Sender: TObject);
begin
  if currdct<>nil then
  begin
    currdct.Disabled := not currdct.Disabled;

    if currdct.Disabled then
    begin
         allDictsTree.Selected.ImageIndex := 3;
         allDictsTree.Selected.SelectedIndex := 3;
         btnEnableDCT.Caption := 'Enable'
    end
    else
    begin
         btnEnableDCT.Caption := 'Disable';
         allDictsTree.Selected.ImageIndex := 2;
         allDictsTree.Selected.SelectedIndex := 2;
    end;
    allDictsTree.SetFocus;
  end;
end;

procedure TWPSpellOptions.btnRemoveDCTClick(Sender: TObject);
begin
  if currdct<>nil then
  begin
    SpellControler.RemoveDCT(currdct);
    UpdateMainDicts;
    allDictsTree.SetFocus;
  end;
end;

procedure TWPSpellOptions.OnLanguageClick(Sender : TObject);
begin
  if SpellControler.CurrentLanguage<>(Sender as TMenuItem).Tag then
  begin
     SpellControler.CurrentLanguage := (Sender as TMenuItem).Tag;
  end;
  btnLanguage.Caption := SpellControler.CurrentLanguageName;
end;

procedure TWPSpellOptions.FormShow(Sender: TObject);
begin
  if SpellControler<>nil then
  try
     FUpdating := TRUE;
     UpdateUserDicts;
     UpdateMainDicts;
     OpenDictsDialog.InitialDir := SpellControler.InitialDirectory;

     chkCompound.Checked :=
        (SpellControler.OptionFlags and WPSPELLOPT_IGNORECOMPOUND)<>0;
     chkCaptital.Checked :=
        (SpellControler.OptionFlags and WPSPELLOPT_IGNORECASE)<>0;
     chkIgnoreCAPS.Checked :=
        (SpellControler.OptionFlags and WPSPELLOPT_IGNOREALLCAPS)<>0;
     chkIgnoreNumbers.Checked :=
        (SpellControler.OptionFlags and WPSPELLOPT_IGNORENUMS)<>0;

     chkSpellAsYouGo.Checked :=
        (SpellControler.OptionFlags and WPSPELLOPT_SPELLASYOUGO)<>0;  

     chkAutoCASE.Visible := SpellControler.SupportAutoCorrect;
     chkAutocorrectAutoWords.Visible := SpellControler.SupportAutoCorrect;

     chkAutoCASE.Checked :=
        (SpellControler.OptionFlags and WPSPELLOPT_AUTOCORRECT_CAPS)<>0;

     chkAutocorrectAutoWords.Checked :=
        (SpellControler.OptionFlags and WPSPELLOPT_AUTOCORRECT_LIST)<>0;


  finally
    FUpdating := FALSE;
  end;
end;



procedure TWPSpellOptions.chkIgnoreNumbersClick(Sender: TObject);
var o : Integer;
begin
  if FUpdating then exit;
  o := 0; { SpellControler.OptionFlags and not
    (WPSPELLOPT_IGNORECOMPOUND+WPSPELLOPT_IGNORECASE+
     WPSPELLOPT_IGNOREALLCAPS+WPSPELLOPT_IGNORENUMS); }
  if chkCompound.Checked then
     o := o + WPSPELLOPT_IGNORECOMPOUND;
  if chkCompound.Checked then
     o := o + WPSPELLOPT_IGNORECASE;
  if chkCaptital.Checked then
     o := o + WPSPELLOPT_IGNORECOMPOUND;
  if chkIgnoreCAPS.Checked then
     o := o + WPSPELLOPT_IGNOREALLCAPS;
  if chkIgnoreNumbers.Checked then
     o := o + WPSPELLOPT_IGNORENUMS;
  if chkSpellAsYouGo.Checked then
     o := o + WPSPELLOPT_SPELLASYOUGO;
  if chkAutoCASE.Checked then
     o := o + WPSPELLOPT_AUTOCORRECT_CAPS;
  if chkAutocorrectAutoWords.Checked then
     o := o + WPSPELLOPT_AUTOCORRECT_LIST;
  SpellControler.OptionFlags := o;
end;

procedure TWPSpellOptions.btnLanguageClick(Sender: TObject);
var p : TPoint;
begin
  p := btnLanguage.ClientToScreen(Point(0,btnLanguage.Height+1));
  LanguagePopup.Popup(p.x,p.y);
end;       

procedure TWPSpellOptions.allDictsTreeKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key=#32 then
  begin
     if currdct<>nil then btnEnableDCTClick(nil)
     else if allDictsTree.Selected<>nil then
        allDictsTree.Selected.Expanded := not allDictsTree.Selected.Expanded;
  end;
end;

procedure TWPSpellOptions.btnOKClick(Sender: TObject);
begin
  chkIgnoreNumbersClick(nil);
  SpellControler.AutoSaveSetup;
  ModalResult := mrOk;
end;





initialization
  glWPSpellOptionForm := TWPSpellOptions;

finalization
  glWPSpellOptionForm := nil;
  
end.
