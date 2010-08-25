unit MadUtils;

interface

procedure SetApplicationName(const Value: string);
procedure MadAddEmailBodyValue(const Name, Value: string);
procedure MadAddEmailSubjectValue(const Name, Value: string);
procedure SetMadEmailOptions;

implementation

uses
   {$ifdef MadExcept}
   MadExcept,
   forms,
   Windows,
   ErrorMoreFrm,
   {$Endif}

   WinUtils,
   SysUtils,

   Globals,
   Classes;

procedure MadAddEmailBodyValue(const Name, Value : string);
var lParams: TStringList;

begin
  {$ifdef MadExcept}
  if (Value = '')
  or (Name = '') then
     Exit;
  lParams := TStringList.Create;
  try
     lparams.Text := MESettings.MailBody;
     lParams.Values[Name] := Value;
     MESettings.MailBody := lParams.Text;
  finally
     Lparams.Free;
  end;
  {$Endif}
end;


procedure MadAddEmailSubjectValue(const Name, Value : string);
var lParams: TStringList;
begin
 {$ifdef MadExcept}
  if (Value = '')
  or (Name = '') then
     Exit;
  lParams := TStringList.Create;
  try
     lparams.StrictDelimiter := True;
     lParams.Delimiter := ',';
     lparams.DelimitedText := MESettings.MailSubject;
     lParams.Values[Name] := Value;
     MESettings.MailSubject := lParams.DelimitedText;
  finally
     Lparams.Free;
  end;
  {$Endif}
end;

procedure SetMadEmailOptions;
begin
   {$ifdef MadExcept}
   if INI_Mail_Type = SMTP_MAIL then begin
      MESettings.MailAsSmtpClient := True;
      MESettings.SmtpServer := INI_SMTP_Server;
      MESettings.SmtpPort := StrToInt(INI_SMTP_PortNo);
      MESettings.MailFrom := INI_SMTP_From;
      if INI_SMTP_Auth then begin
         MESettings.SmtpAccount := INI_SMTP_Account;
         MESettings.SmtpPassword := INI_SMTP_Password;
      end else begin
         MESettings.SmtpAccount := '';
         MESettings.SmtpPassword := '';
      end; 


   end else begin
      MESettings.MailAsSmtpClient := False;
      // Do we need any other settings...
   end;
   {$Endif}
end;


procedure SetApplicationName(const Value: string);
begin
   {$ifdef MadExcept}
  with MESettings do begin

      TitleBar := Value;
      ExceptMsg := Value + ' encountered an unexpected problem and cannot continue';
      MailSubject := 'Problem report ' + Value +  Format(' Version %s ', [VersionInfo.GetAppVersionStr]);

      //SendBtnCaption :=  'Send '+ APPTITLE + ' Problem report';
      RestartBtnCaption := 'Restart '+ Value;
      CloseBtnCaption := 'Close '+ Value;
  end;
   {$Endif}
end;

{$ifdef MadExcept}


function DoDisableWindow(Window: HWnd; Data: Longint): Bool; stdcall;
begin
  if IsWindowVisible(Window) // may not need any of this, just Disable them all.
  and IsWindowEnabled(Window) then
     EnableWindow(Window, False);
  Result := True;
end;


procedure MyOnExceptBoxCreate(exceptBox: dword;
                              simpleMsgBox: boolean);
begin
   // Make it appear more Modal...
   // The idea comes from forms.DisableTaskWindows
   // but we don't need a elaborite list... will never enable them.
   // Just make sure we do not use currentThreadID, because that is the Madexcept Thread...
   EnumThreadWindows(System.MainThreadID, @DoDisableWindow, 0);
   //Windows.SetParent(exceptBox,Application.Mainform.Handle); Nice try but the ExceptionBox remains disabled.
   //EnableWindow(exceptBox, True);
end;

initialization
   MadExcept.OnExceptBoxCreate := MyOnExceptBoxCreate;
{$Endif}

end.
