{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10825: ad3CustomDictionariesDialog.pas 
{
{   Rev 1.5    28/07/2005 1:49:06 pm  Glenn
{ Fixed for Delphi 2005 changes
}
{
{   Rev 1.3    20/12/2004 3:24:06 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:38 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:24 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:36 AM  mnovak
}
{
{   Rev 1.3    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.2    7/29/2002 10:43:02 PM  mnovak
{ Change back to binary DFMs.
}
{
{   Rev 1.1    26/06/2002 4:44:54 pm  glenn
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

TAddictSpell3 Custom-Dictionary Configuration Dialog

History:
8/14/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3CustomDictionariesDialog;

{$I addict3.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ad3ConfigurationDialogCtrl, ComCtrls, StdCtrls,
  shellapi,
  ad3Util,
  ad3CustomDictionary,
  ad3SpellLanguages,
  ad3NewCustomDictionaryDialog;

type
  TCustomDictionariesDialog = class(TForm)
    OK: TButton;
    CustomGroup: TGroupBox;
    NewButton: TButton;
    DeleteButton: TButton;
    EditButton: TButton;
    DialogControl: TConfigurationDialogCtrl;
    CustomDictionaries: TListView;
    HelpButton: TButton;
    procedure FormShow(Sender: TObject);
    procedure DialogControlConfigurationAvailable(Sender: TObject);
    procedure CustomDictionariesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure CustomDictionariesEdited(Sender: TObject; Item: TListItem;
      var S: String);
    procedure CustomDictionariesEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure DeleteButtonClick(Sender: TObject);
    procedure NewButtonClick(Sender: TObject);
    procedure EditButtonClick(Sender: TObject);
    procedure CustomDictionariesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormCreate(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure CustomDictionariesDeletion(Sender: TObject; Item: TListItem);
  private
  public
    FFormShown :Boolean;
    FPopulate  :Boolean;
    function SelectFile( Filename:String ):Boolean;
  end;

implementation

{$R *.DFM}

type
  TListEntry = class(TObject)
  public
    FChecked        :Boolean;
    FIgnoreAllList  :Boolean;
    FMSWordCustom   :Boolean;
    FCanRename      :Boolean;
    FName           :String;
  public
    constructor Create;
  end;


//************************************************************
// TListEntry
//************************************************************

constructor TListEntry.Create;
begin
    FChecked        := True;
    FIgnoreAllList  := False;
    FMSWordCustom   := False;
    FName           := '';
    FCanRename      := False;
end;



//************************************************************
// Utility Functions
//************************************************************

function TCustomDictionariesDialog.SelectFile( Filename:String ):Boolean;
var
    Item        :TListItem;
begin
    Result  := False;
    Item    := CustomDictionaries.FindCaption( 0, Filename, False, True, False );
    if (Item <> nil) then
    begin
        CustomDictionaries.Items[Item.Index].Selected := True;
        CustomDictionaries.ItemFocused := CustomDictionaries.Items[Item.Index];
        Result := True;
    end
end;



//************************************************************
// Event Hooks
//************************************************************

procedure TCustomDictionariesDialog.DialogControlConfigurationAvailable(
  Sender: TObject);
var
    CustomList          :TStringList;
    MSWordCustomList    :TStringList;
    ListItem            :TListItem;
    Index               :LongInt;
    Custom              :TCustomDictionary;
    Entry               :TListEntry;
begin
    FPopulate := True;
    if (not FFormShown) then
    begin
        Exit;
    end;
    Caption                 := DialogControl.GetString( lsDictionaries );

    CustomGroup.Caption     := DialogControl.GetString( lsDlgCustomDictionaries );
    EditButton.Caption      := DialogControl.GetString( lsDlgEdit );
    DeleteButton.Caption    := DialogControl.GetString( lsDlgDelete );
    NewButton.Caption       := DialogControl.GetString( lsDlgNew );
    OK.Caption              := DialogControl.GetString( lsDlgOK );
    HelpButton.Caption      := DialogControl.GetString( lsDlgHelp );

    HelpButton.Visible      := (sdcHelp in DialogControl.CommandsVisible) and (0 <> DialogControl.HelpCtxDictionariesDialog);

    HelpButton.Enabled      := (sdcHelp in DialogControl.CommandsEnabled);
    EditButton.Enabled      := False;
    DeleteButton.Enabled    := False;

    CustomList          := DialogControl.AvailableCustom;
    MSWordCustomList    := DialogControl.AvailableMSWordCustom;

    if (not(Assigned(CustomList))) or (not(Assigned(MSWordCustomList))) then
    begin
        exit;
    end;

    // First setup the Custom Dictionaries List...

    CustomDictionaries.Items.Clear;

    // See if we should add the Ignore All / Change All dictionary

    Custom    := DialogControl.InternalCustom;
    if  (Assigned(Custom)) and
        (sdcInternalEdit in DialogControl.CommandsVisible) and
        ((Custom.IgnoreCount > 0) or (Custom.AutoCorrectCount > 0)) then
    begin
        ListItem    := CustomDictionaries.Items.Add;
        if (Assigned(ListItem)) then
        begin
            Entry                   := TListEntry.Create;

            ListItem.Data           := Entry;
            ListItem.Caption        := DialogControl.GetString( lsIgnoreAllChangeAll );
            ListItem.Checked        := True;

            Entry.FChecked          := True;
            Entry.FIgnoreAllList    := True;
        end;
    end;

    // Add all of the standard Custom-dictionaries

    for Index := 0 to CustomList.Count - 1 do
    begin
        ListItem    := CustomDictionaries.Items.Add;
        if (Assigned(ListItem)) then
        begin
            Entry                   := TListEntry.Create;

            ListItem.Data           := Entry;
            ListItem.Caption        := ExtractFileName( CustomList[Index] );
            ListItem.Checked        := (DialogControl.Configuration.CustomDictionaries.IndexOf( CustomList[Index] ) >= 0);

            Entry.FChecked          := ListItem.Checked;
            Entry.FName             := CustomList[Index];
            Entry.FCanRename        := (CustomList[Index] = ListItem.Caption);
        end;
    end;

    // Add any MS-Word custom dictioanries

    for Index := 0 to MSWordCustomList.Count - 1 do
    begin
        ListItem    := CustomDictionaries.Items.Add;
        if (Assigned(ListItem)) then
        begin
            Entry                   := TListEntry.Create;

            ListItem.Data           := Entry;
            ListItem.Caption        := ExtractFileName( MSWordCustomList[Index] );
            ListItem.Checked        := (DialogControl.Configuration.MSWordCustomDictionaries.IndexOf( MSWordCustomList[Index] ) >= 0);

            Entry.FMSWordCustom     := True;
            Entry.FChecked          := ListItem.Checked;
            Entry.FName             := MSWordCustomList[Index];
        end;
    end;
end;

//************************************************************

procedure TCustomDictionariesDialog.CustomDictionariesSelectItem(
  Sender: TObject; Item: TListItem; Selected: Boolean);
var
    ListEntry   :TListEntry;
begin
    ListEntry := TListEntry(Item.Data);

    DeleteButton.Enabled    :=  Item.Selected and
                                not(ListEntry.FIgnoreAllList) and
                                not(ListEntry.FMSWordCustom);
    EditButton.Enabled      :=  Item.Selected;
end;

//************************************************************

procedure TCustomDictionariesDialog.CustomDictionariesEdited(
  Sender: TObject; Item: TListItem; var S: String);
var
    ListEntry   :TListEntry;
begin
    ListEntry   := TListEntry(Item.Data);

    if (not( DialogControl.RenameCustomDictionary( Item.Caption, S ))) then
    begin
        S := Item.Caption;
    end
    else
    begin
        ListEntry.FName := S;
    end;
end;

//************************************************************

procedure TCustomDictionariesDialog.CustomDictionariesEditing(
  Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
var
    ListEntry   :TListEntry;
begin
    ListEntry := TListEntry(Item.Data);

    // We don't allow re-name of the Ignore All / Change All list

    if (not(ListEntry.FCanRename)) then
    begin
        AllowEdit := False;
        exit;
    end;

    // Turns out that our OK button is hooking the Enter key when
    // pressed to save a selection that is edited in the listview.  So,
    // when the user edits, we turn off the default property.

    OK.Default  := False;
end;

//************************************************************

procedure TCustomDictionariesDialog.DeleteButtonClick(Sender: TObject);
var
    ListEntry   :TListEntry;
begin
    if (CustomDictionaries.ItemFocused <> nil) then
    begin
        ListEntry   := TListEntry(CustomDictionaries.ItemFocused.Data);

        if (IDYES = Application.MessageBox( PChar(DialogControl.GetString(lsRemoveCustomDict)),
                                            PChar(DialogControl.GetString(lsConfirmation)),
                                            MB_YESNO or MB_ICONWARNING )) then
        begin
            DialogControl.RemoveCustomDictionary( ListEntry.FName );

            DialogControlConfigurationAvailable( DialogControl );
        end;
    end;
end;

//************************************************************

procedure TCustomDictionariesDialog.NewButtonClick(Sender: TObject);
var
    NewDialog       :TNewCustomDictionary;
    Filename        :String;
begin
    NewDialog   := TNewCustomDictionary.Create(Self);
    if (Assigned(NewDialog)) then
    begin
        NewDialog.DialogControl.AddictSpell := DialogControl.AddictSpell;
        if (NewDialog.ShowModal = mrOk) then
        begin
            Filename    := ChangeFileExt( ExtractFileName(NewDialog.NameEdit.Text), '.adu' );
            if (not(SelectFile(Filename))) then
            begin
                DialogControl.CreateNewCustomDictionary( Filename );

                DialogControlConfigurationAvailable( DialogControl );

                SelectFile( Filename );
                CustomDictionaries.SetFocus;
            end;
        end;
        NewDialog.Free;
    end;
end;

//************************************************************

procedure TCustomDictionariesDialog.EditButtonClick(Sender: TObject);
var
    CustomDictionary  :TCustomDictionary;
    ListEntry       :TListEntry;
begin
    if (CustomDictionaries.ItemFocused <> nil) then
    begin
        ListEntry := TListEntry(CustomDictionaries.ItemFocused.Data);

        // Fetch the correct dictionary... either the requested one, or
        // the internal Change All / Ignore All list.

        if (ListEntry.FIgnoreAllList) then
        begin
            DialogControl.EditCustomDictionary( DialogControl.InternalCustom );
        end
        else if (ListEntry.FMSWordCustom) then
        begin
            ShellExecute( Self.Handle, 'open', PChar(ListEntry.FName), nil, PChar(ExtractFilePath(ListEntry.FName)), SW_SHOWNORMAL );
        end
        else
        begin
            CustomDictionary := DialogControl.GetCustomDictionary( ListEntry.FName );
            if (Assigned(CustomDictionary)) then
            begin
                DialogControl.EditCustomDictionary( CustomDictionary );
                CustomDictionary.Free;
            end;
        end;
    end;
end;

//************************************************************

procedure TCustomDictionariesDialog.CustomDictionariesChange(
  Sender: TObject; Item: TListItem; Change: TItemChange);
var
    ListEntry       :TListEntry;
begin
    ListEntry := TListEntry(Item.Data);
    if (not Assigned(ListEntry)) then
    begin
        exit;
    end;

    // We don't allow unchecking the Ignore All / Change All list...
    // This wouldn't make much sense.

    if (ListEntry.FIgnoreAllList) then
    begin
        Item.Checked := True;
        exit;
    end;

    // We're looking for a change to the checked property of the item.
    // We can filter out the duplicate messages by also keeping the checked
    // state in the item's data pointer.

    if (Change = ctState) and (Item.Checked <> ListEntry.FChecked) then
    begin
        ListEntry.FChecked  := Item.Checked;
        Item.Selected       := True;

        if (ListEntry.FMSWordCustom) then
        begin
            DialogControl.EnableWordDictionary( ListEntry.FName, Item.Checked );
        end
        else
        begin
            DialogControl.EnableCustomDictionary( ListEntry.FName, Item.Checked );
        end;
    end;
end;

procedure TCustomDictionariesDialog.FormCreate(Sender: TObject);
begin
    {$IFDEF Delphi5AndAbove}
    Position := poOwnerFormCenter;
    {$ENDIF}
    FFormShown  := False;
    FPopulate   := False;
end;

procedure TCustomDictionariesDialog.HelpButtonClick(Sender: TObject);
begin
    DialogControl.HelpDictionariesDialog;
end;

procedure TCustomDictionariesDialog.CustomDictionariesDeletion(
  Sender: TObject; Item: TListItem);
var
    ListEntry   :TListEntry;
begin
    if (Integer(Item.Data) > 0) then
    begin
        ListEntry := TListEntry(Item.Data);
        ListEntry.Free;
        Item.Data := nil;
    end;
end;

procedure TCustomDictionariesDialog.FormShow(Sender: TObject);
begin
    FFormShown := True;
    if (FPopulate) then
    begin
        DialogControlConfigurationAvailable( Self );
    end;
end;

end.
