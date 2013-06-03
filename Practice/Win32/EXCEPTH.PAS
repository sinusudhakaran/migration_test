unit ExceptH;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//loads the unexpected error dialog
//seperated out so that debugging could be turned on for this only
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface
uses
   SysUtils;

procedure UnHandledError( Sender:TObject; E:Exception);

//******************************************************************************
implementation
uses
   Dialogs,
   ErrorLog,
   LogUtil,
   WinUtils,
   forms,
   globals,
   graphics,
   files,
   windows,
   UErrDlg,
   BKConst,
   {$ifdef MadExceptLog}
   MadExcept,
   {$endif}
   BKUTIL32,
   bkContactInformation;

const
   UnitName = 'EXCEPTH';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UnHandledError( Sender:TObject; E:Exception);
const
   ThisMethodName = 'UnHandledError';
var
   dlgAppError : TDlgUError;
   Msg         : string;
   LogFileErrorMsg : string;
  ContactName: String;
  ContactPhone: String;
  ContactEmail: String;
  WebsiteAddress: String;
begin
   //set global flag
   AppCriticalErrorOccured := true;
   dlgAppError := nil;
   try
      if Assigned( Application.MainForm) then
        LockWindowUpdate(Application.MainForm.Handle);
        
      Msg := 'CRITICAL APP ERROR :'+
             ' E.Message =' + E.Message+
             ' E.ClassName = '+ E.ClassName+
             ' Sender.ClassName = '+Sender.ClassName;

      //Attempt to Log error
      LogFileErrorMsg := '';
      try
         LogUtil.LogMsg(lmError,UnitName,Msg, stat_UnhandledError);
         {$ifdef MadExceptLog}
         if Assigned(SysLog) then
            SysLog.SyslogTextBlock('Problem Report',CreateBugReport(etNormal,E,nil,GetCurrentThreadID,0,0,nil,false) );
         {$endif}
      except
         on e2 : Exception do
           LogFileErrorMsg := e2.Message;
      end;

      dlgAppError := TDlgUError.Create(Application.MainForm);
      with dlgAppError do Begin
         Caption := 'Critical Application Error in ' + ShortAppName;

         with lblMessage do begin
            caption := SHORTAPPNAME+' will now terminate because of the following error:'+#13+#13+
                       E.Message;
            Width   := 470;
         end;

         lblVersion.caption := 'Version '+WinUtils.GetAppYearVersionStr + ' [' + AppVersionStr + ']';



         //try to set Support Contact Details.
         try
           if Assigned( AdminSystem) and ( not CurrUser.HasRestrictedAccess) then begin
             lblSupportContact1.Caption := whNames[AdminSystem.fdFields.fdCountry];
             lblSupportContact2.Caption := TContactInformation.SupportPhoneNo[AdminSystem.fdFields.fdCountry];
           end
            else
            begin
              lblSupport.Caption := 'Please contact your accountant immediately!';
              if Assigned( MyClient) then
              begin
                GetPracticeContactDetails( MyClient, ContactName, ContactPhone, ContactEmail, WebsiteAddress);
                lblSupportContact1.Caption := ContactName;
                lblSupportContact2.Caption := ContactPhone;
              end
              else
              begin
                lblSupportContact1.visible := false;
                lblSupportContact2.visible := false;
              end;
            end;
         except //something went wrong with getting the admin system or something (may be why we're here to begin with)
            lblSupport.Caption := 'Please contact Support immediately!';
            lblSupportContact1.visible := false;
            lblSupportContact2.visible := false;
         end;

         with MemoError.Lines do begin
            Clear;
            Add('ClassName:'   +#9+Sender.ClassName);
            Add('ErrorClass:'  +#9+E.ClassName);
            Add('');
            Add('Message:   '+#9+ E.Message);
            Add('');
            Add(ShortAppName + ' is using '+ Uppercase( GLOBALS.DataDir ));
            Add('Current Directory is ' + GetCurrentDir);

            if LogfileErrorMsg <> '' then
               Add('Log Error Failed:'+#9+LogFileErrorMsg);

            WinUtils.ErrorSound;
         end;
         ShowModal;
      end;
   finally
      dlgAppError.Free;
      Application.Terminate;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -



end.
