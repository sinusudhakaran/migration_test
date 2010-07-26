{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10829: ad3CustomDictionaryEditDialog.pas 
{
{   Rev 1.4    1/27/2005 2:14:16 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:10 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:40 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:26 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:38 AM  mnovak
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
{   Rev 1.1    26/06/2002 4:45:06 pm  glenn
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

TAddictSpell3 Custom-Dictionary Editing Dialog

History:
8/16/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3CustomDictionaryEditDialog;

{$I addict3.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ad3ConfigurationDialogCtrl, ComCtrls, StdCtrls, ExtCtrls;

type
  TCustomDictionaryEditDialog = class(TForm)
    PageControl: TPageControl;
    AddedWordsSheet: TTabSheet;
    AutoCorrectWordsSheet: TTabSheet;
    ExcludedWordsSheet: TTabSheet;
    AddedWordsExplain: TLabel;
    IgnoreList: TListBox;
    IgnoreEdit: TEdit;
    AddIgnoreButton: TButton;
    DeleteIgnoreButton: TButton;
    AutoCorrectList: TListView;
    ReplaceEdit: TEdit;
    WithEdit: TEdit;
    ReplaceEditLabel: TLabel;
    WithEditLabel: TLabel;
    AddAutoCorrectButton: TButton;
    DeleteAutoCorrectButton: TButton;
    ExcludeWordsExplanation: TLabel;
    ExcludeList: TListBox;
    ExcludeEdit: TEdit;
    AddExcludeButton: TButton;
    DeleteExcludeButton: TButton;
    OK: TButton;
    IgnoreEditLabel: TLabel;
    ExcludeEditLabel: TLabel;
    AutoCorrectWordsExplain: TLabel;
    DialogControl: TConfigurationDialogCtrl;
    Timer: TTimer;
    HelpButton: TButton;
    procedure AddedWordsSheetShow(Sender: TObject);
    procedure IgnoreEditChange(Sender: TObject);
    procedure IgnoreListClick(Sender: TObject);
    procedure AddIgnoreButtonClick(Sender: TObject);
    procedure DeleteIgnoreButtonClick(Sender: TObject);
    procedure AutoCorrectWordsSheetShow(Sender: TObject);
    procedure ReplaceEditChange(Sender: TObject);
    procedure WithEditChange(Sender: TObject);
    procedure AutoCorrectListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure AddAutoCorrectButtonClick(Sender: TObject);
    procedure DeleteAutoCorrectButtonClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure ReplaceEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure WithEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure IgnoreEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DialogControlCustomDictionaryAvailable(Sender: TObject);
    procedure ExcludedWordsSheetShow(Sender: TObject);
    procedure ExcludeEditChange(Sender: TObject);
    procedure ExcludeEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ExcludeListClick(Sender: TObject);
    procedure AddExcludeButtonClick(Sender: TObject);
    procedure DeleteExcludeButtonClick(Sender: TObject);
    procedure DialogControlConfigurationAvailable(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
  private
  public
  end;

implementation

{$R *.DFM}

uses
    ad3SpellLanguages;


///***********************************************************
// Event Handlers
///***********************************************************

procedure TCustomDictionaryEditDialog.DialogControlConfigurationAvailable(
  Sender: TObject);
begin
    AddedWordsSheet.Caption         := DialogControl.GetString( lsDlgAddedWords );
    AddedWordsExplain.Caption       := DialogControl.GetString( lsDlgAddedWordsExplanation );
    IgnoreEditLabel.Caption         := DialogControl.GetString( lsDlgIgnoreThisWord );
    AddIgnoreButton.Caption         := DialogControl.GetString( lsDlgAdd );
    DeleteIgnoreButton.Caption      := DialogControl.GetString( lsDlgDelete );

    AutoCorrectWordsSheet.Caption   := DialogControl.GetString( lsDlgAutoCorrectPairs );
    AutoCorrectWordsExplain.Caption := DialogControl.GetString( lsDlgAutoCorrectPairsExplanation );
    ReplaceEditLabel.Caption        := DialogControl.GetString( lsDlgReplace );
    WithEditLabel.Caption           := DialogControl.GetString( lsDlgWith );
    AddAutoCorrectButton.Caption    := DialogControl.GetString( lsDlgAdd );
    DeleteAutoCorrectButton.Caption := DialogControl.GetString( lsDlgDelete );

    ExcludedWordsSheet.Caption      := DialogControl.GetString( lsDlgExcludedWords );
    ExcludeWordsExplanation.Caption := DialogControl.GetString( lsDlgExcludedWordsExplanation );
    ExcludeEditLabel.Caption        := DialogControl.GetString( lsDlgExcludeThisWord );
    AddExcludeButton.Caption        := DialogControl.GetString( lsDlgAdd );
    DeleteExcludeButton.Caption     := DialogControl.GetString( lsDlgDelete );

    HelpButton.Caption              := DialogControl.GetString( lsDlgHelp );
    OK.Caption                      := DialogControl.GetString( lsDlgOK );
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.DialogControlCustomDictionaryAvailable(
  Sender: TObject);
var
    FEditingInternal    :Boolean;
begin
    FEditingInternal                    :=  (DialogControl.CustomDictionary = DialogControl.InternalCustom);
    AddedWordsSheet.TabVisible          :=  (sdcAddedEdit in DialogControl.CommandsVisible);
    AutoCorrectWordsSheet.TabVisible    :=  (sdcAutoCorrectEdit in DialogControl.CommandsVisible);
    ExcludedWordsSheet.TabVisible       :=  DialogControl.UseExcludeWords and
                                            not(FEditingInternal) and
                                            (sdcExcludedEdit in DialogControl.CommandsVisible);

    if (FEditingInternal) then
    begin
        Caption                         := DialogControl.GetString( lsIgnoreAllChangeAllTitle );
        AddedWordsSheet.Caption         := DialogControl.GetString( lsDlgIgnoreAll );
        AutoCorrectWordsSheet.Caption   := DialogControl.GetString( lsDlgChangeAll );
    end
    else
    begin
        Caption := ExtractFileName( DialogControl.CustomDictionary.Filename );
    end;

    HelpButton.Visible  := (sdcHelp in DialogControl.CommandsVisible) and (0 <> DialogControl.HelpCtxDictionaryEditDialog);
    HelpButton.Enabled  := (sdcHelp in DialogControl.CommandsEnabled);
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.FormCreate(Sender: TObject);
begin
    {$IFDEF Delphi5AndAbove}
    Position := poOwnerFormCenter;
    {$ENDIF}
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.HelpButtonClick(Sender: TObject);
begin
    DialogControl.HelpDictionaryEditDialog;
end;




///***********************************************************
// Added Words Pane
///***********************************************************

procedure TCustomDictionaryEditDialog.AddedWordsSheetShow(Sender: TObject);
var
    Index       :LongInt;
    OldCursor   :TCursor;
begin
    if (DialogControl.CustomDictionary = nil) then
    begin
        ModalResult := mrCancel;
        exit;
    end;

    if (IgnoreList.Items.Count = 0) then
    begin
        AddIgnoreButton.Enabled     := False;
        DeleteIgnoreButton.Enabled  := False;

        OldCursor       := Screen.Cursor;
        Screen.Cursor   := crHourglass;
        try
            IgnoreList.Items.Capacity   := DialogControl.CustomDictionary.IgnoreCount;
            for Index := 0 to DialogControl.CustomDictionary.IgnoreCount - 1 do
            begin
                IgnoreList.Items.Add( DialogControl.CustomDictionary.GetIgnoreWord( Index ) );
            end;
        finally
            Screen.Cursor   := OldCursor;
        end;
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.IgnoreEditChange(Sender: TObject);
var
    Replacement :String;
begin
    if (DialogControl.CustomDictionary.IgnoreExists( IgnoreEdit.Text )) then
    begin
        AddIgnoreButton.Enabled     := False;
        IgnoreList.ItemIndex        := IgnoreList.Items.IndexOf( IgnoreEdit.Text );
        DeleteIgnoreButton.Enabled  := (IgnoreList.ItemIndex >= 0);
    end
    else
    begin
        IgnoreList.ItemIndex        := -1;
        DeleteIgnoreButton.Enabled  := False;
        AddIgnoreButton.Enabled     :=  (not(DialogControl.CustomDictionary.AutoCorrectExists( IgnoreEdit.Text, Replacement ))) and
                                        (not(DialogControl.CustomDictionary.ExcludeExists( IgnoreEdit.Text ))) and
                                        (IgnoreEdit.Text <> '');
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.IgnoreEditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
    if (Key = VK_RETURN) then
    begin
        if (AddIgnoreButton.Enabled) then
        begin
            AddIgnoreButtonClick( AddIgnoreButton );
        end;
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.IgnoreListClick(Sender: TObject);
begin
    if (IgnoreList.ItemIndex >= 0) then
    begin
        IgnoreEdit.Text := IgnoreList.Items[IgnoreList.ItemIndex];
    end
    else
    begin
        IgnoreEditChange( ExcludeEdit );
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.AddIgnoreButtonClick(Sender: TObject);
begin
    if (DialogControl.CustomDictionary.AddIgnore( IgnoreEdit.Text )) then
    begin
        IgnoreList.Items.Add( IgnoreEdit.Text );
        IgnoreEditChange( IgnoreEdit );
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.DeleteIgnoreButtonClick(
  Sender: TObject);
var
    Index   :LongInt;
begin
    if (DialogControl.CustomDictionary.RemoveIgnore( IgnoreEdit.Text )) then
    begin
        Index                   := IgnoreList.ItemIndex;
        IgnoreList.Items.Delete( IgnoreList.ItemIndex );
        if (Index >= IgnoreList.Items.Count) then
        begin
            Index := IgnoreList.Items.Count - 1;
        end;
        IgnoreList.ItemIndex    := Index;
        IgnoreListClick( IgnoreList );
    end;
end;



///***********************************************************
// Auto-Correct Pane
///***********************************************************

procedure TCustomDictionaryEditDialog.AutoCorrectWordsSheetShow(
  Sender: TObject);
var
    Index       :LongInt;
    OldCursor   :TCursor;
    Word        :String;
    Correction  :String;
    ListItem    :TListItem;
begin
    if (AutoCorrectList.Items.Count = 0) and (Assigned(DialogControl.CustomDictionary)) then
    begin
        AddAutoCorrectButton.Enabled    := False;
        DeleteAutoCorrectButton.Enabled := False;

        OldCursor       := Screen.Cursor;
        Screen.Cursor   := crHourglass;
        try
            AutoCorrectList.Items.BeginUpdate;

            AutoCorrectList.Columns[0].Width    := (WithEdit.Left - ReplaceEdit.Left );

            for Index := 0 to DialogControl.CustomDictionary.AutoCorrectCount - 1 do
            begin
                ListItem            := AutoCorrectList.Items.Add;
                Word                := DialogControl.CustomDictionary.GetAutoCorrectWord( Index, Correction );
                ListItem.Caption    := Word;
                ListItem.SubItems.Add( Correction );
            end;

            AutoCorrectList.Columns[1].Width    := AutoCorrectList.ClientWidth - AutoCorrectList.Columns[0].Width;

        finally
            Screen.Cursor   := OldCursor;
            AutoCorrectList.Items.EndUpdate;
        end;
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.ReplaceEditChange(Sender: TObject);
var
    Replacement :String;
begin
    if (DialogControl.CustomDictionary.AutoCorrectExists( ReplaceEdit.Text, Replacement )) then
    begin
        AddAutoCorrectButton.Enabled    := False;

        AutoCorrectList.ItemFocused     := AutoCorrectList.FindCaption( 0, ReplaceEdit.Text, false, true, false );
        AutoCorrectList.Selected        := AutoCorrectList.ItemFocused;
        DeleteAutoCorrectButton.Enabled := (AutoCorrectList.ItemFocused <> nil);
    end
    else
    begin
        AutoCorrectList.ItemFocused     := nil;
        AutoCorrectList.Selected        := nil;
        DeleteAutoCorrectButton.Enabled := False;
        AddAutoCorrectButton.Enabled    :=  (not(DialogControl.CustomDictionary.IgnoreExists( ReplaceEdit.Text ))) and
                                            (not(DialogControl.CustomDictionary.ExcludeExists( ReplaceEdit.Text ))) and
                                            (ReplaceEdit.Text <> '') and
                                            (WithEdit.Text <> '');
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.WithEditChange(Sender: TObject);
var
    Replacement :String;
begin
    if (AutoCorrectList.ItemFocused <> nil) then
    begin
        if  (DialogControl.CustomDictionary.AutoCorrectExists( ReplaceEdit.Text, Replacement )) and
            (Replacement <> ReplaceEdit.Text) then
        begin
            DialogControl.CustomDictionary.RemoveAutoCorrect( ReplaceEdit.Text );
            DialogControl.CustomDictionary.AddAutoCorrect( ReplaceEdit.Text, WithEdit.Text );
            AutoCorrectList.ItemFocused.SubItems[0] := WithEdit.Text;
        end;
    end
    else
    begin
        // This will enable the Add button if needed

        ReplaceEditChange( ReplaceEdit );
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.AutoCorrectListSelectItem(
  Sender: TObject; Item: TListItem; Selected: Boolean);
begin
    if (Selected) then
    begin
        ReplaceEdit.Text    := Item.Caption;
        WithEdit.Text       := Item.SubItems[0];
    end
    else
    begin
        if (AutoCorrectList.ItemFocused = Item) then
        begin
            // If an element still has focus, and we're losing selection, then
            // the user clicked off of the item...  we then re-select the item
            // for more better UI consistency.

            // However, there is a bug in the Listview Control (or Dephi's
            // wrapper for it) that prevents immediately turning around
            // and re-selecting the item without selecting strangeness later.

            // So, to get around this problem, we'll go ahead and update the
            // item that should be selected on a timer.

            Timer.Enabled := True;
        end;
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.AddAutoCorrectButtonClick(
  Sender: TObject);
var
    Item    :TListItem;
begin
    if (DialogControl.CustomDictionary.AddAutoCorrect( ReplaceEdit.Text, WithEdit.Text )) then
    begin
        Item            := AutoCorrectList.Items.Add;
        Item.Caption    :=  ReplaceEdit.Text;
        Item.SubItems.Add( WithEdit.Text );
        Item.Selected   := True;

        ReplaceEditChange( ReplaceEdit );

        AutoCorrectList.Columns[1].Width    := AutoCorrectList.ClientWidth - AutoCorrectList.Columns[0].Width;
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.DeleteAutoCorrectButtonClick(
  Sender: TObject);
var
    Index   :LongInt;
begin
    if (AutoCorrectList.ItemFocused <> nil) then
    begin
        if (DialogControl.CustomDictionary.RemoveAutoCorrect( ReplaceEdit.Text )) then
        begin
            Index := AutoCorrectList.ItemFocused.Index;
            AutoCorrectList.Items.Delete( AutoCorrectList.ItemFocused.Index );
            if (Index >= AutoCorrectList.Items.Count) then
            begin
                Index := AutoCorrectList.Items.Count - 1;
            end;
            if (Index >= 0) then
            begin
                AutoCorrectList.ItemFocused := AutoCorrectList.Items[Index];
                AutoCorrectList.Selected    := AutoCorrectList.Items[Index];
            end;

            AutoCorrectList.Columns[1].Width    := AutoCorrectList.ClientWidth - AutoCorrectList.Columns[0].Width;
        end;
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.TimerTimer(Sender: TObject);
begin
    // See the comment in AutoCorrectListSelectItem for the explanation of
    // why this call is necessary
    
    Timer.Enabled := False;
    ReplaceEditChange( ReplaceEdit );
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.ReplaceEditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
    if (Key = VK_RETURN) then
    begin
        if (ReplaceEdit.Text <> '') then
        begin
            WithEdit.SetFocus;
        end;
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.WithEditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
    if (Key = VK_RETURN) then
    begin
        if (AddAutoCorrectButton.Enabled) then
        begin
            AddAutoCorrectButtonClick( AddAutoCorrectButton );
        end;
    end;
end;



///***********************************************************
// Exclude Pane
///***********************************************************

procedure TCustomDictionaryEditDialog.ExcludedWordsSheetShow(
  Sender: TObject);
var
    Index       :LongInt;
    OldCursor   :TCursor;
begin
    if (ExcludeList.Items.Count = 0) then
    begin
        AddExcludeButton.Enabled    := False;
        DeleteExcludeButton.Enabled := False;

        OldCursor       := Screen.Cursor;
        Screen.Cursor   := crHourglass;
        try
            ExcludeList.Items.Capacity  := DialogControl.CustomDictionary.ExcludeCount;
            for Index := 0 to DialogControl.CustomDictionary.ExcludeCount - 1 do
            begin
                ExcludeList.Items.Add( DialogControl.CustomDictionary.GetExcludeWord( Index ) );
            end;
        finally
            Screen.Cursor   := OldCursor;
        end;
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.ExcludeEditChange(Sender: TObject);
var
    Replacement :String;
begin
    if (DialogControl.CustomDictionary.ExcludeExists( ExcludeEdit.Text )) then
    begin
        AddExcludeButton.Enabled    := False;
        ExcludeList.ItemIndex       := ExcludeList.Items.IndexOf( ExcludeEdit.Text );
        DeleteExcludeButton.Enabled := (ExcludeList.ItemIndex >= 0);
    end
    else
    begin
        ExcludeList.ItemIndex       := -1;
        DeleteExcludeButton.Enabled := False;
        AddExcludeButton.Enabled    :=  (not(DialogControl.CustomDictionary.AutoCorrectExists( ExcludeEdit.Text, Replacement ))) and
                                        (not(DialogControl.CustomDictionary.IgnoreExists( ExcludeEdit.Text ))) and
                                        (ExcludeEdit.Text <> '');
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.ExcludeEditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
    if (Key = VK_RETURN) then
    begin
        if (AddExcludeButton.Enabled) then
        begin
            AddExcludeButtonClick( AddExcludeButton );
        end;
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.ExcludeListClick(Sender: TObject);
begin
    if (ExcludeList.ItemIndex >= 0) then
    begin
        ExcludeEdit.Text := ExcludeList.Items[ExcludeList.ItemIndex];
    end
    else
    begin
        ExcludeEditChange( ExcludeEdit );
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.AddExcludeButtonClick(Sender: TObject);
begin
    if (DialogControl.CustomDictionary.AddExclude( ExcludeEdit.Text )) then
    begin
        ExcludeList.Items.Add( ExcludeEdit.Text );
        ExcludeEditChange( ExcludeEdit );
    end;
end;

///***********************************************************

procedure TCustomDictionaryEditDialog.DeleteExcludeButtonClick(
  Sender: TObject);
var
    Index   :LongInt;
begin
    if (DialogControl.CustomDictionary.RemoveExclude( ExcludeEdit.Text )) then
    begin
        Index                   := ExcludeList.ItemIndex;
        ExcludeList.Items.Delete( ExcludeList.ItemIndex );
        if (Index >= ExcludeList.Items.Count) then
        begin
            Index := ExcludeList.Items.Count - 1;
        end;
        ExcludeList.ItemIndex   := Index;
        ExcludeListClick( IgnoreList );
    end;
end;

end.
