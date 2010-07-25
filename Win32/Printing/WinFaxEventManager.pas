//------------------------------------------------------------------------------
{
   Title:       WinFax Pro Event Manager Class

   Description: Handles events for printing to a Winfax Printer

   Remarks:     WinFax Pro was proving to be unreliable - sometimes it would fail
                to send a fax or sometimes it would send faxes to the wrong recipients.
                This class tries to make it more reliable by:
                - waiting for an Entry ID to be generated before continuing on and sending another fax.
                - checking last error status
                An entry ID is generated once WinFax has received sent data from the
                WinFax printer, so we know it has reached WinFax Pro successfully.

   Author:      Steve Teare, 28 April 2004

}
//------------------------------------------------------------------------------
unit WinFaxEventManager;

interface

uses ExtCtrls, NNWFax;

type
   TWinFaxEventMgr = class
     private
      GotEntryId,         // Do we have the entry ID?
      FIsError,           // Was there a fax error?
      TimedOut : Boolean; // Did it time out waiting for entry ID?
      TmrGiveUp: TTimer;  // Need to timeout waiting for entry ID so we don't get stuck
      procedure GiveUp(Sender: TObject); // Event handler for timeout
     public
      property IsError: Boolean write FIsError;
      constructor Create;
      destructor Destroy; override;
      procedure SetFaxEvents(Fax: TNNWFax); // Set up the Fax event handlers
      procedure EntryIDReady(Sender: TObject; const entryID: WideString; index: Smallint); // Event handler for receiving entry ID
      function WaitForFaxSent: Boolean; // Poll waiting for entry ID to be returned
      function IsWinFaxReady(Fax: TNNWFax; var LastError: string): Boolean; // See if WinFax is ready to go
   end;

implementation

uses Forms, Windows, Globals;

// Constructor - set vars and create timer
constructor TWinFaxEventMgr.Create;
begin
   GotEntryID := False;
   FIsError := False;
   TimedOut := False;
   TmrGiveUp := TTimer.Create(nil);
   TmrGiveUp.Interval := Globals.PRACINI_msToWaitForWinfaxPrinter;
   TmrGiveUp.OnTimer := GiveUp;
end;

// Destructor - free timer
destructor TWinFaxEventMgr.Destroy;
begin
  TmrGiveUp.Enabled := False;
  TmrGiveUp.Free;
end;

// Require an entry ID so we can tell when the fax is received by WinFax
procedure TWinFaxEventMgr.SetFaxEvents(Fax: TNNWFax);
begin
  Fax.NeedEntryID := True;
  Fax.OnEntryIDReady := self.EntryIDReady;
end;

// Give up waiting for entry ID to be generated
procedure TWinFaxEventMgr.GiveUp(Sender: TObject);
begin
  TmrGiveUp.Enabled := False;
  TimedOut := True;
end;

// WinFax Pro has received the fax from winfax printer
procedure TWinFaxEventMgr.EntryIDReady(Sender: TObject; const entryID: WideString; index: Smallint);
begin
  GotEntryID := True;
end;

// Loop waiting for entry ID to be returned so we know fax has got as far as WinFax Pro
// Times out if it waits too long
// Returns TRUE if fax sent ok, FALSE if timed out/error
function TWinFaxEventMgr.WaitForFaxSent: Boolean;
begin
  if FIsError then
    Result := False
  else
  begin
    TimedOut := False;
    TmrGiveUp.Enabled := True;
    try
      while (not GotEntryId) and (not TimedOut) do
      begin
        Sleep(10);
        Application.ProcessMessages;
      end;
    finally
      TmrGiveUp.Enabled := False;
    end;
    // If the cover page requires manual send (i.e. contains a filler box) then
    // the timeout will happen - we don't care about errors in this case so
    // always return true if the fax object has returned no real errors up to this point
    Result := True;
  end;
end;

// See if WinFax is ready
// Returns TRUE if WinFax ready and available to print, FALSE if error occured and
// LastError is filled with the last error message
function TWinFaxEventMgr.IsWinFaxReady(Fax: TNNWFax; var LastError: string): Boolean;
begin
  LastError := Fax.GetLastError;
  Result := LastError = 'OK-Success.';
end;

end.
