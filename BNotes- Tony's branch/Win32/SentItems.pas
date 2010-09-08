unit SentItems;
//------------------------------------------------------------------------------
{
   Title:       Sent Items

   Description: Sent Items utility routines

   Remarks:

   Author:      Matthew Hopkins Aug 2001

}
//------------------------------------------------------------------------------

interface

procedure AddToSendItemsFolder( ToAddress : String;
                                Subject : String;
                                Body : String;
                                AttachmentFilename : string;
                                SentOk : boolean;
                                StatusMessage : string);

var
   SendLogFilename : string;

//******************************************************************************
implementation
uses
   Forms,
   sysutils,
   SysLog;

procedure AddToSendItemsFolder( ToAddress : String;
                                Subject : String;
                                Body : String;
                                AttachmentFilename : string;
                                SentOk : boolean;
                                StatusMessage : string);
var
   MailLogFile : SysLog.TSystemLogger;
   sMsg        : string;
begin
   if SentOK then
      sMsg := 'Status: SENT OK '
   else
      sMsg := 'Status: FAILED ';

   sMsg := sMsg +
           ' To: ' + ToAddress +
           ' Subj: ' + Subject +
           ' Attach: ' + AttachmentFilename;

   if StatusMessage <> '' then
      sMsg := sMSg + ' Extra Info: ' + StatusMessage;

   try
      MailLogFile := TSystemLogger.Create( SendLogFilename);
      MailLogFile.LogInfo( sMsg);
      MailLogFile.Free;
   except
      on E : exception do begin
         //try to log in normal error log
         SysLog.ApplicationLog.LogInfo( sMsg);
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   SendLogFilename := ExtractFilePath( Application.ExeName) + 'bnmail.log'

end.
