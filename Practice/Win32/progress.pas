Unit progress;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   Progress Form Interface

  Written:
  Authors:

  Purpose:  Controls access to the Status Frm.

  Notes:    Due to the bad coupling within BankLink this form can link in
            everything that the main form calls.  To avoid this add the
            define

            NoMainFormProgress

            This will avoid linking in UPDATEMF.PAS which links in MAINFRM.PAS
            which links in everything else!!

            Each of the calls has an optional parameter that tells the routine
            to call process message.  The reason for this parameter is that
            much of the code that is uses UpdateAppStatus is not design to
            expect application process messages to be called.
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Interface

type
  TUpdateMessageBarEvent = procedure ( aMsg : string; WaitCursor : boolean);

  ISingleProgressForm = interface
  ['{64625C68-46EE-482D-B2FD-1F9B3979075B}']
    function GetCancelled: Boolean;
    procedure Initialize;
    procedure UpdateProgressLabel(const ProgressLabel: String); overload;
    procedure UpdateProgress(const ProgressLabel: String; StepSize: Double); overload;
    procedure UpdateProgress(StepSize: Double); overload;
    procedure CompleteProgress;

    property Cancelled: Boolean read GetCancelled; 
  end;

procedure UpdateAppStatus(sMsgLine1: string; sMsgLine2: string; dPercentage: double; ProcessMessages : Boolean = false);
procedure UpdateAppStatusLine2(Msg: string; ProcessMessages : Boolean = false);
procedure UpdateAppStatusPerc(dPercentage: double; ProcessMessages : Boolean = false);
procedure UpdateAppStatusPerc_NR(dPercentage: double; ProcessMessages : Boolean = false);
procedure ClearStatus(ProcessMessages : Boolean = false);

Const
  ProcessMessages_On = true;

Var
  StatusSilent : boolean = true;
  OnUpdateMessageBar : TUpdateMessageBarEvent;

//This variable is set in the modalprocessordlg and allows us to make sure that
//any routine which sets process messages to true was called from the
//modal processor.  It has not however been implemented in 5.2
   CalledFromModalProcessor : boolean = false;

Implementation

Uses
  windows,
  Forms,
  StatusFrm;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpdateMessageBar( aMsg : string; WaitCursor : boolean);
begin
  if Assigned( OnUpdateMessageBar) then
    OnUpdateMessageBar( aMsg, WaitCursor);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure UpdateAppStatus(sMsgLine1: string; sMsgLine2: string; dPercentage: double; ProcessMessages : Boolean = false);
Begin
  if StatusSilent then
    Exit;

  if Assigned(frmStatus) then begin
    frmStatus.pbarAppStatus.Visible := ( dPercentage >= 0);
    frmStatus.UpdateFrmStatus(sMsgLine1, sMsgLine2, dPercentage, true);
    UpdateMessageBar( sMsgLine1, true);
    frmStatus.Invalidate;
    frmStatus.Refresh;

    if ProcessMessages then
      Application.ProcessMessages;
  End ;
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure UpdateAppStatusLine2(Msg: string; ProcessMessages : Boolean = false);
Begin
  If StatusSilent Then
    Exit;

  If Assigned(frmStatus) Then
  Begin
    frmStatus.lblLine2.caption := Msg;
    frmStatus.lblLine2.Invalidate;
    frmStatus.lblLine2.Refresh;

    if ProcessMessages then
      Application.ProcessMessages;
  End;
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure UpdateAppStatusPerc(dPercentage: double; ProcessMessages : Boolean = false);
Begin { UpdateAppStatusPerc }
  If StatusSilent Then
    Exit;

  If Assigned( frmStatus ) then
  begin
    if ( dPercentage >= 0 ) and ( dPercentage <= 100 ) then
    begin
      frmStatus.pbarAppStatus.Percent := round(dPercentage);
      frmStatus.pbarAppStatus.Refresh;

      if ProcessMessages then
        Application.ProcessMessages;
    end;
  end;
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure UpdateAppStatusPerc_NR(dPercentage: double; ProcessMessages : Boolean = false);
//update the progress bar but dont call refresh, this is to avoid flicker
Begin
  If StatusSilent Then
    Exit;

  If Assigned( frmStatus) and ( dPercentage >= 0 ) and ( dPercentage <= 100 ) then
  Begin
    frmStatus.pbarAppStatus.Percent := round(dPercentage);
  End;

  if ProcessMessages then
    Application.ProcessMessages;
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure ClearStatus(ProcessMessages : Boolean = false);
Begin
  Try
    // Must process messages first otherwise status window may not hide itself (#1673)
    if ProcessMessages then
      Application.ProcessMessages;
    If Assigned(frmStatus) Then
    Begin
      frmStatus.UpdateFrmStatus('', '', 0, false)
    End;
    UpdateMessageBar( '', false);
  Except
     ;
  End;
End;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
  OnUpdateMessageBar := nil;

End.
