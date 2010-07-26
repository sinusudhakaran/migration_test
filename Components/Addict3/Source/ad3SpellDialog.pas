{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10861: ad3SpellDialog.pas 
{
{   Rev 1.5    8/19/2005 1:32:56 AM  mnovak
{ Delphi 2005 Bug Workaround
}
{
{   Rev 1.3    20/12/2004 3:24:34 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:54 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:42 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:50 AM  mnovak
}
{
{   Rev 1.4    1/17/2003 7:46:52 PM  mnovak
{ Fix dialog parenting code issue
}
{
{   Rev 1.3    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.2    7/29/2002 10:43:04 PM  mnovak
{ Change back to binary DFMs.
}
{
{   Rev 1.1    26/06/2002 4:45:30 pm  glenn
{ Form Fixes, Font Fix, D7 Support
}
{
{   Rev 1.0    6/23/2002 11:55:28 PM  mnovak
}
{
{   Rev 1.0    6/17/2002 1:34:20 AM  Supervisor
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

AddictSpell Primary Spellcheck Dialog

History:
8/6/00      - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3SpellDialog;

{$I addict3.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ad3ConfigurationDialogCtrl,
  ad3SpellLanguages;

type
  TSpellDialog = class(TForm)
    NotFoundEdit: TEdit;
    NotFoundText: TLabel;
    ReplaceWithText: TLabel;
    ReplaceWithEdit: TEdit;
    SuggestionsListbox: TListBox;
    SuggestionsText: TLabel;
    UndoButton: TButton;
    OptionsButton: TButton;
    IgnoreAllButton: TButton;
    IgnoreButton: TButton;
    ChangeAllButton: TButton;
    ChangeButton: TButton;
    AddButton: TButton;
    AutoCorrectButton: TButton;
    HelpButton: TButton;
    CancelButton: TButton;
    DialogControl: TConfigurationDialogCtrl;
    procedure DialogControlPromptWord(Sender: TObject;
      const Word: String; Repeated:Boolean );
    procedure IgnoreAllButtonClick(Sender: TObject);
    procedure IgnoreButtonClick(Sender: TObject);
    procedure ChangeAllButtonClick(Sender: TObject);
    procedure ChangeButtonClick(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure AutoCorrectButtonClick(Sender: TObject);
    procedure SuggestionsListboxClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure OptionsButtonClick(Sender: TObject);
    procedure SuggestionsListboxDblClick(Sender: TObject);
    procedure UndoButtonClick(Sender: TObject);
    procedure ReplaceWithEditChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure DialogControlConfigurationAvailable(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure NotFoundEditDblClick(Sender: TObject);
  private
  protected
    procedure CreateParams(var params:TCreateParams);override;
    {$IFDEF Delphi9andAbove}
    function GetOwnerWindow: HWND; override;
    {$ENDIF}
  public
    FRepeated       :Boolean;
    FDeactivated    :Boolean;
    procedure FullEnable( Enable:Boolean );
  end;

implementation

{$R *.DFM}

// This is a D2005 bug fix.  When you set the owner of a form to any form other
// than the application, Delphi kindly puts your form into an array that it
// never cleans up (Application.AddPopupWindow).  The Destructor of the form is
// such that they attempt to clean up the array prior to actually adding the
// form to the array (thus they leave it in there forever to fault when they
// next access it).  This fix skirts the issue by lying to the code that adds
// the form to the array (it doesn't do so when the owner window is NULL).  So
// when we're destroying the window, we pretend not to have an owner window.

{$IFDEF Delphi9andAbove}
function TSpellDialog.GetOwnerWindow:HWND;
begin
    if (csDestroying in ComponentState) then
    begin
        Result := 0;
    end
    else
    begin
        Result := inherited GetOwnerWindow;
    end;
end;
{$ENDIF}


procedure TSpellDialog.CreateParams(var params:TCreateParams);
var
    OwnerForm   :TComponent;
begin
    inherited;

    // Unfortunately, Delphi will never parent a form to anything other than
    // the application window...  other modal windows do not get proper
    // parenting... so we go ahead and parent the form ourselves.  This keeps
    // us in front of our parent form (which is what we want), but doesn't have
    // us occlude modal forms that should be on top of us...

    OwnerForm := Owner;
    while (assigned(OwnerForm) and not(OwnerForm is TForm)) do
    begin
        OwnerForm := OwnerForm.Owner;
    end;
    if assigned(OwnerForm) and (OwnerForm is TWinControl) then
    begin
        Params.WndParent := (OwnerForm as TWinControl).Handle;
    end;
end;

procedure TSpellDialog.FullEnable( Enable:Boolean );
begin
    // This utility function simply enables or disables most of the
    // controls on the dialog.  Its used when the form loses focus, etc.

    UndoButton.Enabled          := Enable and DialogControl.CanUndo and (sdcUndo in DialogControl.CommandsEnabled);
    OptionsButton.Enabled       := Enable and (sdcOptions in DialogControl.CommandsEnabled);
    ReplaceWithEdit.Enabled     := Enable;
    SuggestionsListbox.Enabled  := Enable;
    IgnoreAllButton.Enabled     := Enable and (sdcIgnoreAll in DialogControl.CommandsEnabled);
    IgnoreButton.Enabled        := Enable and (sdcIgnore in DialogControl.CommandsEnabled);
    ChangeAllButton.Enabled     := Enable and (sdcChangeAll in DialogControl.CommandsEnabled);
    ChangeButton.Enabled        := Enable and (sdcChange in DialogControl.CommandsEnabled);
    AddButton.Enabled           := Enable and Assigned(DialogControl.ActiveCustomDictionary) and (sdcAdd in DialogControl.CommandsEnabled);
    AutoCorrectButton.Enabled   := Enable and Assigned(DialogControl.ActiveCustomDictionary) and (sdcAutoCorrect in DialogControl.CommandsEnabled);
end;

procedure TSpellDialog.DialogControlConfigurationAvailable(
  Sender: TObject);
begin
    // This event is simply used as a point to initialize our dialog with
    // strings from Addict's currently selected UILanguage

    FRepeated                   := False;
    FDeactivated                := False;
    Caption                     := DialogControl.GetString( lsSpelling );

    NotFoundText.Caption        := DialogControl.GetString( lsDlgNotFound );
    ReplaceWithText.Caption     := DialogControl.GetString( lsDlgReplaceWith );
    SuggestionsText.Caption     := DialogControl.GetString( lsDlgSuggestions );
    UndoButton.Caption          := DialogControl.GetString( lsDlgUndo );
    OptionsButton.Caption       := DialogControl.GetString( lsDlgOptions );
    IgnoreAllButton.Caption     := DialogControl.GetString( lsDlgIgnoreAll );
    IgnoreButton.Caption        := DialogControl.GetString( lsDlgIgnore );
    ChangeAllButton.Caption     := DialogControl.GetString( lsDlgChangeAll );
    ChangeButton.Caption        := DialogControl.GetString( lsDlgChange );
    AddButton.Caption           := DialogControl.GetString( lsDlgAdd );
    AutoCorrectButton.Caption   := DialogControl.GetString( lsDlgAutoCorrect );
    HelpButton.Caption          := DialogControl.GetString( lsDlgHelp );
    CancelButton.Caption        := DialogControl.GetString( lsDlgCancel );

    UndoButton.Visible          := (sdcUndo in DialogControl.CommandsVisible);
    OptionsButton.Visible       := (sdcOptions in DialogControl.CommandsVisible);
    IgnoreAllButton.Visible     := (sdcIgnoreAll in DialogControl.CommandsVisible);
    IgnoreButton.Visible        := (sdcIgnore in DialogControl.CommandsVisible);
    ChangeButton.Visible        := (sdcChange in DialogControl.CommandsVisible);
    ChangeAllButton.Visible     := (sdcChangeAll in DialogControl.CommandsVisible);
    AddButton.Visible           := (sdcAdd in DialogControl.CommandsVisible);
    AutoCorrectButton.Visible   := (sdcAutoCorrect in DialogControl.CommandsVisible);
    HelpButton.Visible          := (sdcHelp in DialogControl.CommandsVisible) and (0 <> DialogControl.HelpCtxSpellDialog);
    CancelButton.Visible        := (sdcCancel in DialogControl.CommandsVisible);

    HelpButton.Enabled          := (sdcHelp in DialogControl.CommandsEnabled);
    CancelButton.Enabled        := (sdcCancel in DialogControl.CommandsEnabled);

    if not(OptionsButton.Visible) then
    begin
        UndoButton.Top := OptionsButton.Top;
    end;
end;

procedure TSpellDialog.DialogControlPromptWord(Sender: TObject; const Word: String; Repeated:Boolean );
begin
    NotFoundEdit.Text       := Word;

    SuggestionsListbox.Clear;

    // Here we see if we've switched from repeated-word mode to normal-mode, or
    // the other way around.  If so, we make some subtle changes to the UI...

    if (FRepeated <> Repeated) then
    begin
        FRepeated := Repeated;

        FullEnable( not FRepeated );

        if (FRepeated) then
        begin
            OptionsButton.Enabled   := (sdcOptions in DialogControl.CommandsEnabled);
            IgnoreButton.Enabled    := True;
            ChangeButton.Enabled    := True;
            NotFoundText.Caption    := DialogControl.GetString( lsDlgRepeatedWord );
        end
        else
        begin
            NotFoundText.Caption    := DialogControl.GetString( lsDlgNotFound );
        end;
    end;

    UndoButton.Enabled      := DialogControl.CanUndo and (sdcUndo in DialogControl.CommandsEnabled);

    // Here we perform any initializations necessary for the current word
    // this event was called for.

    if (Repeated) then
    begin
        ReplaceWithEdit.Text := copy(Word, 1, (Length(Word) div 2));
    end
    else
    begin
        AddButton.Enabled           := Assigned(DialogControl.ActiveCustomDictionary) and (sdcAdd in DialogControl.CommandsEnabled);
        AutoCorrectButton.Enabled   := Assigned(DialogControl.ActiveCustomDictionary) and (sdcAutoCorrect in DialogControl.CommandsEnabled);
        DialogControl.Suggest( Word, SuggestionsListbox.Items );
        SuggestionsListbox.Enabled  := (SuggestionsListbox.Items.Count > 0);
        if (SuggestionsListbox.Enabled) then
        begin
            ReplaceWithEdit.Text            := SuggestionsListbox.Items[ 0 ];
            SuggestionsListbox.ItemIndex    := 0;
        end
        else
        begin
            ReplaceWithEdit.Text    := '';
            ReplaceWithEditChange( Self );
            SuggestionsListbox.Items.Add( DialogControl.GetString( lsMnNoSuggestions ) );
        end;
    end;
end;

procedure TSpellDialog.IgnoreAllButtonClick(Sender: TObject);
begin
    DialogControl.IgnoreAll;
end;

procedure TSpellDialog.IgnoreButtonClick(Sender: TObject);
begin
    if (FRepeated) then
    begin
        DialogControl.RepeatIgnore;
    end
    else
    begin
        DialogControl.Ignore;
    end;
end;

procedure TSpellDialog.ChangeAllButtonClick(Sender: TObject);
begin
    DialogControl.ChangeAll( ReplaceWithEdit.Text );
end;

procedure TSpellDialog.ChangeButtonClick(Sender: TObject);
begin
    if (FRepeated) then
    begin
        DialogControl.RepeatDelete;
    end
    else
    begin
        DialogControl.Change( ReplaceWithEdit.Text );
    end;
end;

procedure TSpellDialog.AddButtonClick(Sender: TObject);
begin
    DialogControl.Add;
end;

procedure TSpellDialog.AutoCorrectButtonClick(Sender: TObject);
begin
    DialogControl.AutoCorrect( ReplaceWithEdit.Text );
end;

procedure TSpellDialog.SuggestionsListboxClick(Sender: TObject);
begin
    if (SuggestionsListbox.ItemIndex >= 0) then
    begin
        ReplaceWithEdit.Text := SuggestionsListBox.Items[ SuggestionsListbox.ItemIndex ];
    end;
end;

procedure TSpellDialog.SuggestionsListboxDblClick(Sender: TObject);
begin
    if (SuggestionsListbox.ItemIndex >= 0) then
    begin
        DialogControl.Change( SuggestionsListBox.Items[ SuggestionsListbox.ItemIndex ] );
    end;
end;

procedure TSpellDialog.CancelButtonClick(Sender: TObject);
begin
    DialogControl.Cancel;
end;

procedure TSpellDialog.OptionsButtonClick(Sender: TObject);
begin
    DialogControl.Setup;
    DialogControlPromptWord( Self, NotFoundEdit.Text, FRepeated );
end;

procedure TSpellDialog.UndoButtonClick(Sender: TObject);
begin
    DialogControl.Undo;
end;

procedure TSpellDialog.ReplaceWithEditChange(Sender: TObject);
var
    Enabled :Boolean;
begin
    if (not FRepeated) then
    begin
        Enabled                     := (ReplaceWithEdit.Text <> '');
        ChangeAllButton.Enabled     := Enabled and (sdcChangeAll in DialogControl.CommandsEnabled);
        ChangeButton.Enabled        := Enabled and (sdcChange in DialogControl.CommandsEnabled);
        AutoCorrectButton.Enabled   := Enabled and Assigned(DialogControl.ActiveCustomDictionary) and (sdcAutoCorrect in DialogControl.CommandsEnabled);
    end;
end;

procedure TSpellDialog.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
    DialogControl.Cancel;
end;

procedure TSpellDialog.FormDeactivate(Sender: TObject);
begin
    FDeactivated := True;
    FullEnable( False );
end;

procedure TSpellDialog.FormActivate(Sender: TObject);
begin
    if (FDeactivated) then
    begin
        FDeactivated := False;
        FullEnable( True );
    end;
end;

procedure TSpellDialog.HelpButtonClick(Sender: TObject);
begin
    DialogControl.HelpSpellDialog;
end;

procedure TSpellDialog.NotFoundEditDblClick(Sender: TObject);
begin
    ReplaceWithEdit.Text := NotFoundEdit.Text;
end;

end.

