unit LockingTestFrm;
//------------------------------------------------------------------------------
{
   Title:       Main form for lock testing utility

   Description:

   Author:      Matthew Hopkins Apr 2002

   Remarks:     Can be compiled as part of a standalone application or as part
                of BK5.

                Requires the following conditional compiler directives
                
                TESTLOCKING            Tells LockUtils not to make the progress
                                       dialog modal.  Without this can't stop test
                NoMainFormProgress     Avoiding linking in Coding Form and associated
                                       units.
}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, RzButton, Buttons;

type
  TTestLockingFrm = class(TForm)
    Label1: TLabel;
    Timer1: TTimer;
    Edit1: TEdit;
    Label4: TLabel;
    Edit2: TEdit;
    Label5: TLabel;
    Panel1: TPanel;
    Label2: TLabel;
    lblAttempts: TLabel;
    Label3: TLabel;
    lblErrors: TLabel;
    Label6: TLabel;
    edtWait: TEdit;
    Label7: TLabel;
    lblAvg: TLabel;
    Label8: TLabel;
    lblLast: TLabel;
    Panel2: TPanel;
    btnStart: TButton;
    btnStop: TButton;
    btnClose: TButton;
    btnTerminate: TRzButton;
    chkCaptureExceptions: TCheckBox;
    Memo1: TMemo;
    lblVersion: TLabel;
    chkSaveAdmin: TCheckBox;
    lblUsing: TLabel;
    edtFileCode: TEdit;
    chkFileSave: TCheckBox;
    rbFileAccess: TRadioButton;
    rbLog: TRadioButton;
    rbAdmin: TRadioButton;
    Label9: TLabel;
    lblTime: TLabel;
    Timer2: TTimer;
    Label10: TLabel;
    Edit3: TEdit;
    Label11: TLabel;
    lblUser: TLabel;
    SpeedButton1: TSpeedButton;
    btnViewLog: TButton;
    chkRefresh: TCheckBox;
    procedure btnCloseClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure rbAdminClick(Sender: TObject);
    procedure btnTerminateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure btnViewLogClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    AttemptsCount : integer;
    ErrorCount    : integer;
    ElapsedTime   : Int64;
    TotalTime     : Int64;

    LongestTime   : integer;

    LocksObtained : integer;

    StopClicked   : boolean;

    procedure ResetCounters;
  public
    { Public declarations }
  end;

  var
     TestLockingFrm : TTestLockingFrm;

procedure TestLocking;

implementation
uses
   clObj32,
   Login32,
   ClientLookupExFrm,
   Admin32,
   Files,
   ErrorLog,
   ShellAPI,
   Globals,
   TimeUtils,
   WinUtils, AppUserObj;

{$R *.DFM}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TestLocking;
begin
   with TTestLockingFrm.Create( Application) do begin
     try
        ShowModal;
     finally
       Free;
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTestLockingFrm.btnCloseClick(Sender: TObject);
begin
   Timer1.Enabled := false;
   Timer2.Enabled := false;
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTestLockingFrm.btnStopClick(Sender: TObject);
var
   AvgTimeForLock : double;
begin
   if StopClicked then exit;

   btnStart.enabled := true;
   Timer1.Enabled := false;
   Timer2.Enabled := false;
   StopClicked    := true;

   rbFileAccess.enabled := true;
   edtFileCode.enabled  := rbFileAccess.enabled;
   rbAdmin.Enabled := true;
   rbLog.Enabled   := true;


   if LocksObtained > 0 then
      AvgTimeForLock := ( TotalTime div LocksObtained) / 1000
   else
      AvgTimeForLock := 0;

   memo1.Lines.add( 'Average time: ' + FormatFloat( '0.00#', AvgTimeForLock));
   memo1.Lines.add( 'Longest time: ' + FormatFloat( '0.00#', LongestTime / 1000));
   memo1.Lines.add( 'Attempts: ' + inttostr( AttemptsCount));
   memo1.Lines.add( 'Errors: ' + inttostr( ErrorCount));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTestLockingFrm.btnStartClick(Sender: TObject);
begin
   ResetCounters;

   if rbFileAccess.Checked then
   begin
     if Trim( edtFileCode.Text) = '' then exit;

     //need to start admin system and login user
     if not Assigned( CurrUser) then
     begin
       if AdminExists then
         Admin32.LoadAdminSystem( false, 'Start File Test');

       if Login32.LoginUser( WinUtils.ReadUserName) then
         lblUser.Caption := Globals.CurrUser.Code
       else
         Exit;
     end;
     rbAdmin.Enabled := false;
     rbLog.Enabled   := false;
   end;

   rbFileAccess.Enabled := false;
   edtFileCode.enabled  := rbFileAccess.enabled;
   StopClicked      := false;

   Timer1.Interval  := StrToIntDef( edit1.text, 100);
   Timer1.Enabled   := true;
   btnStart.Enabled := false;

   Timer2.Enabled   := true;
   Timer2.Interval  := 100;  //0.1s
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTestLockingFrm.Timer1Timer(Sender: TObject);
var
   TimeForLock : integer;
   AvgTimeForLock : Double;
   ElapsedS        : Double;
   ElapsedM        : integer;
   rLast          : Double;
   aClient        : TClientObj;
begin
   Inc( AttemptsCount);

   if chkRefresh.Checked then
     lblAttempts.caption := inttostr( AttemptsCount);

   PRACINI_TicksToWaitForAdmin := StrToIntDef( edtWait.Text, 15) * 1000;
   if PRACINI_TicksToWaitForAdmin < 5000 then PRACINI_TicksToWaitForAdmin := 5000;

   TimeForLock := 0;

   Timer1.enabled  := false;
   Timer1.Interval := StrToIntDef( edit1.text, 100);
   try

     if rbLog.checked then begin
        TimeUtils.StartTimer;

        ErrorLog.SysLog.SysLogMessage( slDebug, 'LockingTest','This is a test');

        TimeUtils.StopTimer;
        TimeForLock := TimeUtils.ElapsedTimeMS;
        Inc( LocksObtained);
        TotalTime := TotalTime + TimeForLock;
     end;

     if rbAdmin.checked then begin
        TimeUtils.StartTimer;
        Admin32.LoadAdminSystem( true, 'LockingTest');
        TimeUtils.StopTimer;
        TimeForLock := TimeUtils.ElapsedTimeMS;
        Inc( LocksObtained);
        TotalTime := TotalTime + TimeForLock;

        Sleep( StrToIntDef( edit2.text, 100));
        if chkSaveAdmin.checked then
           Admin32.SaveAdminSystem
        else
           Admin32.UnlockAdmin;
     end;

     if ( rbFileAccess.Checked) and ( edtFileCode.Text <> '') then
     begin
       TimeUtils.StartTimer;
       Files.OpenAClient( edtFileCode.Text, aClient, true, false);
       if Assigned( aClient) then
       begin
         if chkFileSave.Checked then
         begin
           if aClient.clFields.clAddress_L3 = '' then
             aClient.clFields.clAddress_L3 := 'TESTING'
           else
             aClient.clFields.clAddress_L3 := '';
         end;

         Sleep( StrToIntDef( edit3.text, 100));

         Files.CloseAClient( aClient);
         TimeUtils.StopTimer;
         TimeForLock := TimeUtils.ElapsedTimeMS;
         Inc( LocksObtained);
         TotalTime := TotalTime + TimeForLock;
       end
       else
         raise Exception.Create( 'Cannot open file ' + edtFileCode.Text);

     end;

   except
      On E : Exception do begin
         if chkCaptureExceptions.checked then begin
            Inc( ErrorCount);
            Memo1.Lines.add( '(' + inttostr( AttemptsCount) + ') ' + E.Message + ' ' + E.ClassName);
         end
         else begin
            btnStop.Click;
            Raise
         end;
      end;
   end;

   if chkRefresh.Checked then
   begin
     lblErrors.caption   := inttostr( ErrorCount);

     if LocksObtained > 0 then
        AvgTimeForLock := ( TotalTime div LocksObtained) / 1000
     else
        AvgTimeForLock := 0;

     lblAvg.caption := FormatFloat( '0.00#', AvgTimeForLock);

     rLast := TimeForLock / 1000;
     lblLast.caption := FormatFloat( '0.00#', rLast);

     ElapsedS := ( ElapsedTime mod 600) / 10;
     ElapsedM := ( ElapsedTime div 600);

     lblTime.caption := IntToStr( ElapsedM) + ':' + FormatFloat( '0.00#', ElapsedS) + 's';

     if TimeForLock > LongestTime then
        LongestTime := TimeForLock;
   end;

   if not StopClicked then
      Timer1.enabled := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTestLockingFrm.rbAdminClick(Sender: TObject);
begin
   ResetCounters;

   label4.enabled := rbAdmin.checked;
   edit2.enabled  := rbAdmin.checked;
   label6.enabled := rbAdmin.checked;
   edtWait.enabled := rbAdmin.checked;
   chkSaveAdmin.enabled := rbAdmin.checked;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTestLockingFrm.btnTerminateClick(Sender: TObject);
begin
   if MessageDlg( 'The will terminate the application and any current tests.  Use STOP to stop the test.  Terminate Application?',
                  mtWarning, [ mbNo, mbYes], 0) = mrYes then
      Halt(0);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTestLockingFrm.ResetCounters;
begin
   LongestTime      := 0;
   AttemptsCount    := 0;
   ErrorCount       := 0;
   TotalTime        := 0;
   LocksObtained    := 0;
   ElapsedTime      := 0;
   Memo1.Lines.Clear;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTestLockingFrm.FormCreate(Sender: TObject);
begin
{$IFNDEF BK5_TESTLOCKING}
   AdminSystem := nil;
   CurrUser    := nil;
   MyClient    := nil;
{$ENDIF}

   lblVersion.caption := WinUtils.GetShortAppVersionStr;
   lblUsing.caption   := 'Using  ' + Globals.DataDir;

end;

procedure TTestLockingFrm.Timer2Timer(Sender: TObject);
begin
  Inc( ElapsedTime); // in 0.1s
end;

procedure TTestLockingFrm.SpeedButton1Click(Sender: TObject);
begin
  if not Assigned( CurrUser) then
  begin
     if not Assigned( AdminSystem) then
       if AdminExists then
         Admin32.LoadAdminSystem( false, 'Login User');

     if Login32.LoginUser( WinUtils.ReadUserName) then
     begin
       lblUser.Caption := Globals.CurrUser.Code;
     end;
  end;

  if Assigned( CurrUser) then
     edtFileCode.Text := ClientLookupExFrm.LookupClientCodes( 'Open a file', '', []);
end;

procedure TTestLockingFrm.btnViewLogClick(Sender: TObject);
begin
  ShellExecute(Handle,'open',pChar('notepad'),PChar(ExecDir + ERRORLOG.sysLog.LogFilename) ,nil,SW_SHOWNORMAL);
end;

procedure TTestLockingFrm.FormDestroy(Sender: TObject);
begin
{$IFNDEF BK5_TESTLOCKING}
  if Assigned( CurrUser) then
       Login32.LogoutUser;
{$ENDIF}
end;

end.
