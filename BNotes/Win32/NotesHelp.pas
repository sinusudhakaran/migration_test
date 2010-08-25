//------------------------------------------------------------------------------
//
// NotesHelp.pas
//
// Help wrapper for initializing and finalizing HTML help system for BK Notes.
// Re-written because it doesn't work on Vista!
// Map IDs are stored in Notes_Help.inc.
//
//------------------------------------------------------------------------------
unit NotesHelp;

interface

uses
  Forms, Windows;

{$I NotesHelp.inc}

procedure BKHelpSetUp(Form : TForm; HelpContextID : Integer);

implementation

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure BKHelpSetUp(Form : TForm; HelpContextID : Integer);
//- - - - - - - - - - - - - - - - - - - -
// Purpose:     Configure the help settings for supplied form
//
// Parameters:  Form - form to setup
//              HelpContextID - helpContext value from bkHelp.inc
//
// Remarks:     Can be called anytime to allow for context to change as tab
//              or other options are changed in UI
//
//- - - - - - - - - - - - - - - - - - - -
begin
  TForm(Form).HelpContext := HelpContextID;
end;

end.
