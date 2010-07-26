{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10821: ad3ConfigurationDialog.pas 
{
{   Rev 1.4    1/27/2005 2:14:16 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:04 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:36 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:22 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:36 AM  mnovak
}
{
{   Rev 1.3    7/30/2002 12:07:10 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.2    7/29/2002 10:43:02 PM  mnovak
{ Change back to binary DFMs.
}
{
{   Rev 1.1    26/06/2002 4:44:42 pm  glenn
{ Form Fixes, Font Fix, D7 Support
}
{
{   Rev 1.0    6/23/2002 11:55:26 PM  mnovak
}
{
{   Rev 1.0    6/17/2002 1:34:18 AM  Supervisor
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

TAddictSpell3 Configuration Dialog

History:
8/13/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3ConfigurationDialog;

{$I addict3.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ad3ConfigurationDialogCtrl,
  ad3SpellLanguages,
  ad3Configuration,
  ad3MainDictionary, ImgList;

type
  TSpellCheckConfigDialog = class(TForm)
    OK: TButton;
    DictionariesGroup: TGroupBox;
    CustomLabel: TLabel;
    CustomCombo: TComboBox;
    DictionariesButton: TButton;
    MainDictionaries: TListView;
    OptionsGroup: TGroupBox;
    Option1: TCheckBox;
    Option2: TCheckBox;
    Option3: TCheckBox;
    Option4: TCheckBox;
    Option5: TCheckBox;
    Option6: TCheckBox;
    Option7: TCheckBox;
    Option10: TCheckBox;
    Option9: TCheckBox;
    Option8: TCheckBox;
    DialogControl: TConfigurationDialogCtrl;
    HelpButton: TButton;
    ResetButton: TButton;
    XPImageList: TImageList;
    procedure DialogControlConfigurationAvailable(Sender: TObject);
    procedure MainDictionariesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure MainDictionariesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure OptionsClick(Sender: TObject);
    procedure CustomComboChange(Sender: TObject);
    procedure DictionariesButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure MainDictionariesClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ResetButtonClick(Sender: TObject);
  private
  public
    procedure PopulateDropDown;
    procedure FixHeader;
    procedure PopulateMainList;
    function PopulateOptions:Integer;
  end;

implementation

{$R *.DFM}



//************************************************************
// Utility Methods
//************************************************************

procedure TSpellCheckConfigDialog.PopulateDropDown;
var
    CustomList  :TStringList;
    Index       :LongInt;
begin
    CustomList    := DialogControl.AvailableCustom;

    if (not(Assigned(CustomList))) then
    begin
        exit;
    end;

    CustomCombo.Clear;
    for Index := 0 to CustomList.Count - 1 do
    begin
        CustomCombo.Items.Add( CustomList[Index] );
    end;
    if (DialogControl.Configuration.ActiveCustomDictionary <> '') then
    begin
        CustomCombo.ItemIndex := CustomCombo.Items.IndexOf( DialogControl.Configuration.ActiveCustomDictionary );
    end;
end;

//************************************************************

procedure TSpellCheckConfigDialog.FixHeader;
var
    nWidth  :Integer;
begin
    nWidth := MainDictionaries.Width - 4 - MainDictionaries.Columns[0].Width;
    if (MainDictionaries.Items.Count > 4) then
    begin
        nWidth := nWidth - GetSystemMetrics(SM_CXVSCROLL);
    end;
    MainDictionaries.Columns[1].Width := nWidth;
end;

//************************************************************

procedure TSpellCheckConfigDialog.PopulateMainList;
var
    ListItem            :TListItem;
    Index               :LongInt;
    MainList            :TStringList;
    MainDictionary      :TMainDictionary;
begin
    MainList    := DialogControl.AvailableMain;

    if (not(Assigned(MainList))) then
    begin
        exit;
    end;

    // First setup the Main Dictionaries List...

    MainDictionaries.Items.Clear;

    for Index := 0 to MainList.Count - 1 do
    begin
        ListItem    := MainDictionaries.Items.Add;
        if (Assigned(ListItem)) then
        begin
            MainDictionary      := DialogControl.GetMainDictionary( MainList[Index] );
            if (Assigned( MainDictionary )) then
            begin
                ListItem.Caption    := MainDictionary.Title;
                MainDictionary.Free;
            end
            else
            begin
                ListItem.Caption    := '???';
            end;
            ListItem.SubItems.Add( MainList[Index] );
        end;
    end;

    if (sdcMainDictFolderBrowse in DialogControl.CommandsVisible) then
    begin
        ListItem    := MainDictionaries.Items.Add;
        if (Assigned(ListItem)) then
        begin
            ListItem.Caption    := DialogControl.GetString( lsDlgBrowseForMain );
            ListItem.SubItems.Add(  '' );
            ListItem.Data       := Pointer(False);
            ListItem.Checked    := False;
        end;
    end;

    // Ordinarily, this code should be in the loop above that is filling the
    // listview full of information.  However, Delphi 4 has a bug in it that
    // unchecks previous items as you add new ones, so we must adjust the
    // checkmarks after we're done adding items.

    for Index := 0 to MainList.Count - 1 do
    begin
        ListItem            := MainDictionaries.Items[Index];
        ListItem.Data       := Pointer((DialogControl.Configuration.MainDictionaries.IndexOf( MainList[Index] ) >= 0));
        ListItem.Checked    := (Boolean(ListItem.Data));
    end;

    FixHeader;
end;

//************************************************************

function TSpellCheckConfigDialog.PopulateOptions:Integer;
var
    Index               :LongInt;
    MaxIndex            :LongInt;
    Options             :Array[1..10] of TCheckBox;
    SpellOption         :TSpellOption;
begin
    Options[1]  := Option1;
    Options[2]  := Option2;
    Options[3]  := Option3;
    Options[4]  := Option4;
    Options[5]  := Option5;
    Options[6]  := Option6;
    Options[7]  := Option7;
    Options[8]  := Option8;
    Options[9]  := Option9;
    Options[10] := Option10;

    Index       := 1;
    MaxIndex    := 10;

    for SpellOption := Low(TSpellOption) to High(TSpellOption) do
    begin
        if (SpellOption in DialogControl.AvailableOptions) then
        begin
            Options[Index].Tag      := Integer(SpellOption);
            Options[Index].Caption  := DialogControl.GetOptionString( SpellOption );
            Options[Index].Checked  := SpellOption in DialogControl.Configuration.SpellOptions;
            inc(Index);
            if (Index > MaxIndex) then
            begin
                break;
            end;
        end;
    end;

    Result := 0;

    // Remove those options that aren't needed from the form

    while (Index <= MaxIndex) do
    begin
        inc(Result);
        Options[Index].Visible := False;
        inc(Index);
    end;
end;


//************************************************************
// Event Hooks
//************************************************************

procedure TSpellCheckConfigDialog.DialogControlConfigurationAvailable( Sender: TObject);
begin
    Caption                             := DialogControl.GetString( lsSpellingOptions );

    OptionsGroup.Caption                := DialogControl.GetString( lsDlgOptionsLabel );
    DictionariesGroup.Caption           := DialogControl.GetString( lsDlgDictionariesLabel );
    MainDictionaries.Columns[0].Caption := DialogControl.GetString( lsDlgName );
    MainDictionaries.Columns[1].Caption := DialogControl.GetString( lsDlgFilename );
    CustomLabel.Caption                 := DialogControl.GetString( lsDlgCustomDictionary );
    DictionariesButton.Caption          := DialogControl.GetString( lsDlgDictionaries );
    HelpButton.Caption                  := DialogControl.GetString( lsDlgHelp );
    ResetButton.Caption                 := DialogControl.GetString( lsDlgResetDefaults );

    OK.Caption                          := DialogControl.GetString( lsDlgOK );

    DictionariesButton.Visible          := (sdcCustomDictionaries in DialogControl.CommandsVisible);
    CustomCombo.Visible                 := (sdcCustomDictionary in DialogControl.CommandsVisible);
    CustomLabel.Visible                 := CustomCombo.Visible;
    ResetButton.Visible                 := (sdcResetDefaults in DialogControl.CommandsVisible);
    OK.Visible                          := (sdcConfigOK in DialogControl.CommandsVisible);
    HelpButton.Visible                  := (sdcHelp in DialogControl.CommandsVisible) and (0 <> DialogControl.HelpCtxConfigDialog);

    DictionariesButton.Enabled          := (sdcCustomDictionaries in DialogControl.CommandsEnabled);
    CustomCombo.Enabled                 := (sdcCustomDictionary in DialogControl.CommandsEnabled);
    ResetButton.Enabled                 := (sdcResetDefaults in DialogControl.CommandsVisible);
    OK.Enabled                          := (sdcConfigOK in DialogControl.CommandsEnabled);
    HelpButton.Enabled                  := (sdcHelp in DialogControl.CommandsEnabled);

    if (not DictionariesButton.Visible) and (not CustomCombo.Visible) then
    begin
        MainDictionaries.Height := (DictionariesButton.Top + DictionariesButton.Height) - MainDictionaries.Top;
    end;
    if (not OK.Visible) and (not HelpButton.Visible) then
    begin
        DictionariesGroup.Height := (OK.Top + OK.Height) - DictionariesGroup.Top;
    end;

    // Now populate the dictionary lists...

    PopulateMainList;
    PopulateDropDown;

    // Setup the options based upon what should be available...

    Height := Height - (PopulateOptions * (Option2.Top - Option1.Top));

    OptionsGroup.Anchors        := [akLeft, akTop, akRight ];
    {$IFDEF Delphi5AndAbove}
    DictionariesGroup.Anchors   := [akLeft, akTop, akRight, akBottom ];
    {$ENDIF}
end;

//************************************************************

procedure TSpellCheckConfigDialog.MainDictionariesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
    // We don't allow items to become selected in the listview, as we only
    // really care about the state of the checkbox.

    if (Item.Selected) then
    begin
        Item.Selected   := False;
    end;
end;

//************************************************************

procedure TSpellCheckConfigDialog.MainDictionariesChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
var
    Index   :LongInt;
begin
    // We're looking for a change to the checked property of the item.
    // We can filter out the duplicate messages by also keeping the checked
    // state in the item's data pointer.

    if (Change = ctState) and (Item.Checked <> Boolean(Item.Data)) then
    begin
        if  (sdcMainDictFolderBrowse in DialogControl.CommandsVisible) and
            (Item.Index = MainDictionaries.Items.Count - 1) and
            Item.Checked then
        begin
            Item.Checked := False;
            DialogControl.SetupAddDictionaryDir;
            PopulateMainList;
        end
        else
        begin
            Item.Data := Pointer(Item.Checked);
            Index := DialogControl.Configuration.MainDictionaries.IndexOf( Item.SubItems[0] );
            if (Item.Checked) then
            begin
                if (Index = -1) then
                begin
                    DialogControl.Configuration.MainDictionaries.Add( Item.SubItems[0] );
                end;
            end
            else
            begin
                if (Index <> -1) then
                begin
                    DialogControl.Configuration.MainDictionaries.Delete( Index );
                end;
            end;
        end;
    end;
end;

//************************************************************

procedure TSpellCheckConfigDialog.OptionsClick(Sender: TObject);
var
    CheckBox    :TCheckBox;
    SpellOption :TSpellOption;
begin
    // We cache the option that a checkbox represents in its Tag field to avoid
    // tons of replicated code.  We then simply use this option to interact with
    // the configuration's options set.

    CheckBox    := TCheckBox(Sender);
    SpellOption := TSpellOption(CheckBox.Tag);

    if (CheckBox.Checked) then
    begin
        if (not( SpellOption in DialogControl.Configuration.SpellOptions )) then
        begin
            DialogControl.Configuration.SpellOptions := DialogControl.Configuration.SpellOptions + [ SpellOption ];
        end;
    end
    else
    begin
        if (SpellOption in DialogControl.Configuration.SpellOptions ) then
        begin
            DialogControl.Configuration.SpellOptions := DialogControl.Configuration.SpellOptions - [ SpellOption ];
        end;
    end;
end;

//************************************************************

procedure TSpellCheckConfigDialog.CustomComboChange(Sender: TObject);
begin
    if (CustomCombo.ItemIndex >= 0) then
    begin
        DialogControl.Configuration.ActiveCustomDictionary := CustomCombo.Items[CustomCombo.ItemIndex];
    end;
end;

//************************************************************

procedure TSpellCheckConfigDialog.DictionariesButtonClick(Sender: TObject);
begin
    DialogControl.SetupCustomDictionaries;
    PopulateDropDown;
end;

//************************************************************

procedure TSpellCheckConfigDialog.FormCreate(Sender: TObject);
begin
    {$IFDEF Delphi5AndAbove}
    Position := poOwnerFormCenter;
    {$ENDIF}
end;

//************************************************************

procedure TSpellCheckConfigDialog.HelpButtonClick(Sender: TObject);
begin
    DialogControl.HelpConfigDialog;
end;

//************************************************************

procedure TSpellCheckConfigDialog.MainDictionariesClick(Sender: TObject);
var
    ListItem    :TListItem;
    ptCursor    :TPoint;
    rcLabel     :TRect;
begin
    GetCursorPos( ptCursor );
    ptCursor    := MainDictionaries.ScreenToClient( ptCursor );
    ListItem    := MainDictionaries.GetItemAt( ptCursor.X, ptCursor.Y );
    if (Assigned(ListItem)) then
    begin
        rcLabel             := ListItem.DisplayRect( drLabel );
        if (ptCursor.X >= rcLabel.left) then
        begin
            ListItem.Checked    := not(ListItem.Checked);
        end;
    end;
end;

//************************************************************

procedure TSpellCheckConfigDialog.FormShow(Sender: TObject);
begin
    FixHeader;
end;

//************************************************************

procedure TSpellCheckConfigDialog.ResetButtonClick(Sender: TObject);
begin
    DialogControl.Configuration.ResetConfigurationDefaults;

    PopulateMainList;
    PopulateDropDown;
    PopulateOptions;
end;

end.

