{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10873: ad3ThesaurusDialog.pas 
{
{   Rev 1.4    1/27/2005 2:14:24 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:42 pm  Glenn
}
{
{   Rev 1.2    2/22/2004 12:00:00 AM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:48 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:56 AM  mnovak
}
{
{   Rev 1.3    7/30/2002 12:07:14 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.2    7/29/2002 10:43:04 PM  mnovak
{ Change back to binary DFMs.
}
{
{   Rev 1.1    26/06/2002 4:45:42 pm  glenn
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

Addict Thesaurus Dialog

History:
9/23/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3ThesaurusDialog;

interface

{$I addict3.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, commctrl, ComCtrls, ExtCtrls,
  {$IFDEF Delphi5AndAbove} contnrs, {$ENDIF}
  ad3Util,
  ad3ThesaurusDialogCtrl,
  ad3ThesaurusFile,
  ad3ThesaurusLanguages;

type
  TThesDialog = class(TForm)
    LookedUpLabel: TLabel;
    LookupCombo: TComboBox;
    ContextsLabel: TLabel;
    ContextLV: TListView;
    ReplaceWithLabel: TLabel;
    ReplaceEdit: TEdit;
    CloseButton: TButton;
    PreviousButton: TButton;
    ReplaceButton: TButton;
    DialogControl: TThesaurusDialogCtrl;
    WordList: TListView;
    LookupButton: TButton;
    Timer: TTimer;
    procedure DialogControlPromptLookup(Sender: TObject; Word: String;
      ContextList: TObjectList);
    procedure DialogControlPromptContext(Sender: TObject;
      Words: TStringList);
    procedure ContextLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure TimerTimer(Sender: TObject);
    procedure WordListChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ReplaceEditChange(Sender: TObject);
    procedure LookupButtonClick(Sender: TObject);
    procedure LookupComboChange(Sender: TObject);
    procedure PreviousButtonClick(Sender: TObject);
    procedure ReplaceButtonClick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure WordListDblClick(Sender: TObject);
    procedure DialogControlActivate(Sender: TObject);
  private
  public
  end;

implementation

{$R *.DFM}


procedure TThesDialog.DialogControlActivate(Sender: TObject);
var
    Dist    :Integer;
begin
    Caption                     := DialogControl.GetString( lsThesaurus );

    LookedUpLabel.Caption       := DialogControl.GetString( lsDlgLookedUp );
    ContextsLabel.Caption       := DialogControl.GetString( lsDlgContexts );
    ReplaceWithLabel.Caption    := DialogControl.GetString( lsDlgReplaceWith );

    PreviousButton.Caption      := DialogControl.GetString( lsDlgPrevious );
    LookupButton.Caption        := DialogControl.GetString( lsDlgLookup );
    ReplaceButton.Caption       := DialogControl.GetString( lsDlgReplace );
    CloseButton.Caption         := DialogControl.GetString( lsDlgClose );

    CloseButton.Enabled         := (tdcClose in DialogControl.CommandsEnabled);
    LookedUpLabel.Enabled       := (tdcLookedUp in DialogControl.CommandsEnabled);
    LookupCombo.Enabled         := (tdcLookedUp in DialogControl.CommandsEnabled);

    if not(tdcLookedUp in DialogControl.CommandsVisible) then
    begin
        Dist                    := ContextsLabel.Top - LookedUpLabel.Top;

        LookedUpLabel.Visible   := False;
        LookupCombo.Visible     := False;

        ContextsLabel.Top       := ContextsLabel.Top - Dist;
        ContextLV.Top           := ContextLV.Top - Dist;
        ContextLV.Height        := ContextLV.Height + Dist;
    end;

    PreviousButton.Visible      := (tdcPrevious in DialogControl.CommandsVisible);
    LookupButton.Visible        := (tdcLookup in DialogControl.CommandsVisible);
    ReplaceButton.Visible       := (tdcReplace in DialogControl.CommandsVisible);
    CloseButton.Visible         := (tdcClose in DialogControl.CommandsVisible);
end;

procedure TThesDialog.DialogControlPromptLookup(Sender: TObject;
  Word: String; ContextList: TObjectList);
var
    Position    :Integer;
    Index       :Integer;
    ListItem    :TListItem;
begin
    // Ensure that the current word we're looking at is only in our
    // drop-down list once and is at the first position in the list.

    Position := LookupCombo.Items.IndexOf( Word );
    if (Position >= 0) then
    begin
        LookupCombo.Items.Delete( Position );
    end;
    if (Word <> '') then
    begin
        LookupCombo.Items.Insert( 0, Word );
        LookupCombo.ItemIndex := 0;
    end
    else
    begin
        LookupCombo.ItemIndex := -1;
    end;

    // Populate the context list (including the word-type column).

    ContextLV.Items.BeginUpdate;
    try
        ContextLV.Items.Clear;
        for Index := 0 to ContextList.Count - 1 do
        begin
            ListItem            := ContextLV.Items.Add;
            ListItem.Caption    := TThesaurusEntry(ContextList[Index]).ContextWord;
            ListItem.SubItems.Add( TThesaurusEntry(ContextList[Index]).ContextKindName );
        end;
    finally
        ContextLV.Items.EndUpdate;
    end;

    // Adjust the column widths of the context listview to take the full width
    // of the control.

    ContextLV.Columns[1].Width := ColumnTextWidth;
    ContextLV.Columns[1].Width := ContextLV.Perform( LVM_GETCOLUMNWIDTH, 1, 0 );
    ContextLV.Columns[0].Width := (ContextLV.Width - 4 - GetSystemMetrics(SM_CXVSCROLL) - ContextLV.Columns[1].Width);

    ContextLV.Enabled := (ContextLV.Items.Count > 0);
    if (ContextLV.Enabled) then
    begin
        // This call will automatically cause the change event to fire and
        // populate the Replace-With wordlist on the right side of the dialog.

        ContextLV.Selected := ContextLV.Items[0];
    end
    else
    begin
        ContextLV.Items.Add.Caption := DialogControl.GetString( lsDlgNotFound );
        WordList.Items.Clear;
    end;

    // Set State

    PreviousButton.Enabled  := (LookupCombo.Items.Count > 1) and (tdcPrevious in DialogControl.CommandsEnabled);
end;

procedure TThesDialog.DialogControlPromptContext(Sender: TObject;
  Words: TStringList);
var
    Index       :Integer;
    ListItem    :TListItem;
begin
    // Populate the wordlist listview based upon the given input

    WordList.Items.BeginUpdate;
    try
        WordList.Items.Clear;
        for Index := 0 to Words.Count - 1 do
        begin
            ListItem            := WordList.Items.Add;
            ListItem.Caption    := Words[Index];
        end;
    finally
        WordList.Items.EndUpdate;
    end;

    // Adjust the column width to take the full width of the control

    WordList.Columns[0].Width := (WordList.Width - 4 - GetSystemMetrics(SM_CXVSCROLL));

    // Attempt to find and select the looked up word in the list of given
    // words.

    if (LookupCombo.Items.Count > 0) then
    begin
        Index := Words.IndexOf( LookupCombo.Items[0] );
        if (Index >= 0) then
        begin
            WordList.Selected       := WordList.Items[ Index ];
            WordList.ItemFocused    := WordList.Items[ Index ];
            WordList.ItemFocused.MakeVisible( False );
            ReplaceEdit.Text        := '';

            // See explanation for timer in the timer ontimer handler.

            Timer.Enabled := True;
        end;
    end;

    // Set State

    LookupButton.Enabled    := False;
    ReplaceButton.Enabled   := False;
end;

procedure TThesDialog.ContextLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
    // Changing selection in the contexts list implicitly changes the list
    // of matching words viewed.

    if (Change = ctState) and (Item.Selected) then
    begin
        DialogControl.SetContext( Item.Index );
    end;
end;

procedure TThesDialog.TimerTimer(Sender: TObject);
var
    FocusRect   :TRect;
    Dist        :Integer;
begin
    Timer.Enabled   := False;

    // All we're really trying to do here is to scroll the word we're looking
    // for into the center of the listview.  We would normally do this
    // immediately after we populate the listview.  However, the scroll call
    // doesn't work until the form is up and visible (not detectable by an
    // event).  So, to handle this, we simply set a timer to do it since it
    // doesn't need to be done synchronously.

    if (Assigned( WordList.ItemFocused )) then
    begin
        FocusRect   := WordList.ItemFocused.DisplayRect( drBounds );
        Dist        := FocusRect.Top - (WordList.ClientHeight div 2);
        WordList.Scroll( 0, Dist );
    end;
end;

procedure TThesDialog.WordListChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
    // Propogate the item's text to the replace with edit field.

    if (Change = ctState) and (Item.Selected) then
    begin
        if (AnsiLowerCase( Item.Caption ) <> AnsiLowerCase( LookupCombo.Text )) then
        begin
            ReplaceEdit.Text := Item.Caption;
        end
        else
        begin
            ReplaceEdit.Text := '';
        end;
    end;
end;

procedure TThesDialog.ReplaceEditChange(Sender: TObject);
begin
    LookupButton.Enabled    := (Length(ReplaceEdit.Text) > 0) and (tdcLookup in DialogControl.CommandsEnabled);
    ReplaceButton.Enabled   := (Length(ReplaceEdit.Text) > 0) and (tdcReplace in DialogControl.CommandsEnabled);
end;

procedure TThesDialog.LookupButtonClick(Sender: TObject);
begin
    DialogControl.LookupWord( ReplaceEdit.Text );
end;

procedure TThesDialog.LookupComboChange(Sender: TObject);
begin
    if (LookupCombo.ItemIndex >= 0) then
    begin
        DialogControl.LookupWord( LookupCombo.Items[ LookupCombo.ItemIndex ] );
    end;
end;

procedure TThesDialog.PreviousButtonClick(Sender: TObject);
begin
    // Delete the current lookup and lookup the previous one

    if (LookupCombo.Items.Count >= 2) then
    begin
        LookupCombo.Items.Delete( 0 );
        DialogControl.LookupWord( LookupCombo.Items[ 0 ] );
    end;
end;

procedure TThesDialog.ReplaceButtonClick(Sender: TObject);
begin
    DialogControl.ReplaceWord( ReplaceEdit.Text );
end;

procedure TThesDialog.CloseButtonClick(Sender: TObject);
begin
    DialogControl.Cancel;
end;

procedure TThesDialog.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
    DialogControl.Cancel;
end;

procedure TThesDialog.WordListDblClick(Sender: TObject);
begin
    if (Assigned( WordList.ItemFocused )) then
    begin
        DialogControl.DoubleClickWord( WordList.ItemFocused.Caption );
    end;
end;

end.

