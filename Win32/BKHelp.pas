//------------------------------------------------------------------------------
//
// BKHelp.pas
//
// Help wrapper for initializing and finalizing HTML help system for BK5.
// Map IDs are stored in BKHelp.inc.
//
//------------------------------------------------------------------------------
unit BKHelp;

interface

uses
  Forms, Windows, SysUtils, WinUtils;

{$I BKHelp.inc}

procedure BKHelpSetUp(Form : TForm; HelpContextID : Integer);
procedure BKHelpShow(Form : TForm);
procedure BKHelpShowContext( HelpContextID : integer);
function BKHelpFileExists: Boolean;

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
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure BKHelpShow(Form : TForm);
//- - - - - - - - - - - - - - - - - - - -
// Purpose:      Allows help for provided form to be called specifically
//
// Parameters:   Form to show help for
//
// Remarks:      Relies on the .helpContext value being set in the form
//
//- - - - - - - - - - - - - - - - - - - -
begin
  if ( TForm(Form).HelpContext <> 0) and BKHelpFileExists then
    Application.HelpContext(TForm(Form).HelpContext);
end;

procedure BKHelpShowContext( HelpContextID : integer);
begin
  if ( HelpContextID <> 0) and BKHelpFileExists then
    Application.HelpContext(HelpContextID);
end;

function BKHelpFileExists: Boolean;
begin
  Result := BKFileExists(Application.HelpFile);
end;

end.
