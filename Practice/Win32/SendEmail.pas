unit SendEmail;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   Mail Module

  Written: Feb 00
  Authors: Matthew

  Purpose: Provide access to mail either via Mapi or Internet Mail

  Notes:   Plan is to provide a mail module that provide a common interface
           regardless of whether we are using MAPI or SMTP.

           Is a non-visual module.

           OnStatusChangeProc provides a link to a procedure for updating the status.
           OnStatusChangeMeth provides a link to a method for updating the status.

           Exceptions are raised on failures in Connect, SendMail and Disconnect
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  RzSndMsg, WinUtils, ipscore, ipssmtps, DIMimeStreams, WPRTEDefs, WPCTRMemo, WPCTRRich,
  IdBaseComponent, IdMessage, IdText,IdAttachmentFile, idMessageParts;

const
   UnitName = 'SendEmail';
type
   TStatusChangeProc  = procedure ( Sender : TObject; sMsg : string);
   TStatusChangeMeth  = procedure ( Sender : TObject; sMsg : string) of object;

type
  TMailModule = class(TDataModule)
    rzMailMAPI: TRzSendMessage;
    ipsSMTPS1: TipsSMTPS;
    smtpMessage: TIdMessage;

    procedure MailModuleCreate(Sender: TObject);
    procedure MailModuleDestroy(Sender: TObject);
    procedure ipsSMTPS1Error(Sender: TObject; ErrorCode: Integer;
      const Description: String);

  private
    IsConnected : boolean;
    FOnStatusChangeProc: TStatusChangeProc;
    FOnStatusChangeMeth: TStatusChangeMeth;
    OutlookApplication,
    MAPINamespace: OleVariant;
    OutlookUsingActiveInstance: Boolean;
    ImagesList: TStringList;

    procedure SetOnStatusChangeProc(const Value: TStatusChangeProc);
    procedure SetOnStatusChangeMeth(const Value: TStatusChangeMeth);
    procedure EMailPrepareImageforSaving(RTFData: TWPRTFDataCollection;
                Writer: TWPCustomTextWriter; TextObject: TWPTextObj; var DontSave: Boolean);
    procedure UpdateStatus( NewMsg : string);
    function SendViaRedemption: Boolean;
    function SendViaSMTP: Boolean;
    procedure ClearImages;
    { Private declarations }
  public
    { Public declarations }
    Subject    : string;
    Recipients : TStringList;
    CarbonCopy : TStringList;
    Attachments: TStringList;


    EMail: TWPRichText;

    FromName   : string;
    FromAddr   : string;
    UsingAddr  : string;

    property  OnStatusChangeProc  : TStatusChangeProc read FOnStatusChangeProc write SetOnStatusChangeProc;
    property  OnStatusChangeMeth  : TStatusChangeMeth read FOnStatusChangeMeth write SetOnStatusChangeMeth;

    procedure InitComponents;
    function  Connect : boolean;
    procedure NewMessage;
    procedure SendMail;
    function  Disconnect : boolean;
    procedure Abort;
  end;

function CheckMailSetup( var Error : string) : boolean;
procedure ParseRecipients(Recipients: string; List: TStrings);
function EmailDir: string;

//******************************************************************************
implementation
uses
   Globals,
   bk5Except,
   ErrorMoreFrm,
   Redemption_TLB,
   LogUtil,
   MAPI,
   ComObj,
   Variants;
{$R *.DFM}
var
   DebugMe : boolean;
{ TMailModule }

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMailModule.ClearImages;

  procedure Delete(Value: string);
  begin
     if bkFileExists(Value) then
        Deletefile(Value);
  end;

var I: Integer;
begin
  for I := 0 to ImagesList.Count - 1 do
     Delete(ImagesList[i]);
  ImagesList.Clear;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TMailModule.Connect: boolean;
//will normally raise an exception.  Handled exceptions are re-raised as EMailConnectFailed
//if not exception is raised or the user aborts the connect then connect returns false
begin
   try
      IsConnected := false;
      if DebugMe then
          logutil.LogMsg( lmInfo, Unitname, 'Connect' );

      if INI_Mail_Type = SMTP_MAIL then begin
         //SMTP Mail
         UpdateStatus('Connecting to '+ INI_SMTP_Server);
         ipsSMTPS1.MailServer := INI_SMTP_Server;
         ipsSMTPS1.Connect;
         IsConnected := ipsSMTPS1.Connected;
      end else begin
         //MAPI Mail
         //The connections to the mail client occurs when the mail is sent
         UpdateStatus( 'Logon to MAPI Client');
         if INI_MAPI_UseExtended then begin
           try
             try
               // try to use existing instance if it exists
               OutlookApplication := GetActiveOleObject('Outlook.Application');
               OutlookUsingActiveInstance := True;
             except // otherwise create one
               OutlookApplication := CreateOleObject('Outlook.Application') ;
             end;
             // Logon
             if DebugMe then
                logutil.LogMsg( lmInfo, Unitname, 'logon' );
             MAPINamespace := OutlookApplication.GetNamespace('MAPI');
             MAPINamespace.Logon;
           except on E: Exception do
             raise EMailConnectFailed.Create('You do not have a MAPI compliant application (such as Outlook) '+
                                  'installed on your workstation (' + E.Message + ').'#13#13 +
                                  'Please choose "Preferences" from the "File" menu and select the "Email" tab. Then change your preferred mail '+
                                  'method to "Use Internet Mail"');
           end;
         end
         else
           rzMailMAPI.Logon;
         IsConnected := true;
      end;
      Result := IsConnected;
   except
      on E : EMapiError do begin
         raise EMailConnectFailed.Create(E.Message);
      end;
      on E : EipsSMTPS do begin
        case E.Code of
          162 : raise EMailConnectFailed.Create('Cannot connect to the specified mail server (' +
                            ipsSMTPS1.MailServer  + ')');
        else
          raise EMailConnectFailed.Create(E.Message);
        end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TMailModule.Disconnect: boolean;
begin
   try
      if INI_Mail_Type = SMTP_MAIL then begin
         //SMTP Mail
         ipsSMTPS1.Disconnect;
         result := not ipsSMTPS1.Connected;
      end
      else begin
         //MAPI Mail, disconnect to mail client occurs after mail sent
         if INI_MAPI_UseExtended then
         begin
           if not OutlookUsingActiveInstance then // Do not shut down their active Outlook!
              OutlookApplication.Quit
         end
         else
           rzMailMAPI.Logoff;
         result := true;
      end;
   except
      on E : EMapiError do begin
         //reraise as EMailConnectFailed
         raise EMailDisconnectFailed.Create(  E.Message);
      end;
      on E : EipsSMTPS do begin
        raise EMailConnectFailed.Create(E.Message);
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMailModule.Abort;
//send abort message to mail controls
begin
   ipsSMTPS1.Interrupt;
   //MailMAPI has no abort procedure
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMailModule.InitComponents;
//setup the properties for each of the components
//clear all existing fields
var OutPortNo: Integer;
begin
   //initialise MAPI Component

   //initialise SMTP Component
   with ipsSMTPS1 do begin
      ResetHeaders;
      {$IFDEF SSLV6} // Make sure is set when using IPWorks version 6...
         Config( 'SSLProvider=');
      {$ELSE}
         SSLProvider := '';  //turn OFF SSL
      {$ENDIF}
      if (INI_SMTP_PortNo='') then
        MailPort := 25
      else if TryStrToInt(INI_SMTP_PortNo,OutPortNo) then
        MailPort := OutPortNo;
      if INI_SMTP_Auth then
      begin
        User := INI_SMTP_Account;
        Password := INI_SMTP_Password;
      end
      else
      begin
        User := '';
        Password := '';
      end;
      if INI_INTERNET_TIMEOUT <= 0 then
        INI_INTERNET_TIMEOUT := 60;
      TimeOut := INI_INTERNET_TIMEOUT;
   end;
   //clear message details
   NewMessage;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMailModule.MailModuleCreate(Sender: TObject);
begin
   Recipients  := TStringList.Create;
   CarbonCopy  := TstringList.Create;
   Attachments := TStringList.Create;
   ImagesList  := TStringList.Create;
   UsingAddr   := 'Reply To';
   OutlookUsingActiveInstance := False;
   InitComponents;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMailModule.MailModuleDestroy(Sender: TObject);
begin
   Recipients.Free;
   CarbonCopy.Free;
   Attachments.Free;
   ClearImages;
   ImagesList.Free;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMailModule.NewMessage;
//clears the message fields so that a new message can be built
begin
   //clear values;
   Subject    := '';
   Recipients.Clear;
   CarbonCopy.Clear;
   Attachments.Clear;
   ClearImages;
   //Clear MAPI Component
   rzMailMAPI.ClearLists;
   //Clear SMTP Component
   ipsSMTPS1.ResetHeaders;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


//write a string to file
procedure SaveStringToFile( s : string; filename : string);
var
  sl : TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Text := s;
    sl.SaveToFile( filename);
  finally
    sl.Free;
  end;
end;

procedure TMailModule.SendMail;
//if send mail fails an exception will be raised.  This reason for raising exceptions
//rather than just returning a true/false is that there are many reasons why it might fail.
const
  CRLF = #13#10;
var
  MailSentOk : boolean;
  i          : Integer;
  eMsg       : string;
  S : String;
begin
   MailSentOK := false;
   try
      //fill the fields in the components with the correct values
      if INI_Mail_Type = SMTP_MAIL then begin
         MailSentOk := SendViaSMTP

      end else begin
         //MAPI Mail
         //From Details will be added by MAPI client
         if DebugMe then
         begin
           logutil.LogMsg( lmInfo, Unitname, 'mapi client');
           if INI_MAPI_UseExtended then
             logutil.LogMsg( lmInfo, Unitname, 'Using Extended MAPI')
           else
             logutil.LogMsg( lmInfo, Unitname, 'Using Raize MAPI');
           logutil.LogMsg( lmInfo, Unitname, 'to : + ' + Recipients.Text);
           logutil.LogMsg( lmInfo, Unitname, 'cc : + ' + CarbonCopy.Text);
           logutil.LogMsg( lmInfo, Unitname, 'mapi profile = ' +  INI_MAPI_Profile);
           if (INI_MAPI_Password <> '') then
               logutil.LogMsg( lmInfo, Unitname, 'Password supplied');
         end;

         if INI_MAPI_UseExtended then
           MailSentOk := SendViaRedemption
         else
         begin         
           rzMailMAPI.Subject := Subject;
           rzMailMAPI.ClearLists;
           Email.OnPrepareImageforSaving := nil;
           rzMailMAPI.MessageText.Text := EMail.AsAnsiString('ANSI');
           rzMailMAPI.Review := false;
           rzMailMAPI.ToRecipients.Assign(Recipients);
           rzMailMAPI.CcRecipients.Assign(CarbonCopy);
           for i := 0 to Attachments.Count-1 do
           begin
             if (BKFileExists(Attachments[i])) then
             begin
               rzMailMAPI.Attachments.Add( Attachments[i]);
               if DebugMe then
                 LogUtil.LogMsg(lmInfo, UnitName, 'Attachment ' + Attachments[i]);
             end
             else
              LogUtil.LogMsg(lmInfo, UnitName, 'Attachment Not Found (' + Attachments[i] + ').');
           end;
           rzMailMAPI.ProfileName := INI_MAPI_Profile;
           rzMailMAPI.Password    := INI_MAPI_Password;

           with rzMailMAPI do begin
              try
                 UpdateStatus('Sending Mail to MAPI Outbox');
                 Send;
                 UpdateStatus('Send Mail Successful');
                 MailSentOk := true;
              except
                 on E : EMapiError do begin
                    case E.ErrorCode of
                       MAPI_E_UNKNOWN_RECIPIENT,
                       MAPI_E_BAD_RECIPTYPE,
                       MAPI_E_AMBIGUOUS_RECIPIENT,
                       MAPI_E_INVALID_RECIPS : begin
                          EMsg := 'Recipient List is not valid';
                       end;
                       MAPI_E_NOT_SUPPORTED : begin
                          EMsg := 'You do not have a MAPI compliant application (such as Outlook) '+
                                  'installed on your workstation.'#13#13 +
                                  'Please choose "Preferences" from the "File" menu and select the "Email" tab. Then change your preferred mail '+
                                  'method to "Use Internet Mail"';
                       end;
                    else
                       EMsg := E.Message;
                    end;
                 end;
              end;
              if EMsg <> '' then
              begin
                Application.ProcessMessages; //to stop lock up if an error occurs
                raise EMapiError.Create( EMsg);
              end;
           end;
         end;
      end;
      //if failed raise an exception.  Known failure reasons should raise their
      //own exceptions, so this is just a catch for anything that failed but did not
      //raise an exception
      if MailSentOK then
      begin
        S := ' to: ';
        for i := 0 to Recipients.Count - 1 do
         S := S + Recipients[i] + ';';

        if CarbonCopy.Count > 0 then
        begin
          S := S + '  cc: ';
          for i := 0 to CarbonCopy.Count - 1 do
           S := S + CarbonCopy[i] + ';';
        end;

        LogUtil.LogMsg(lmInfo, UnitName, Subject + S);
      end else begin
         raise EMailSendFailed.Create( 'Unknown');
      end;

   //re-raise handled exceptions
   except
      on e : EMapiError do begin
         //reraise as SendFailed
         raise EMailSendFailed.Create( E.Message);
      end;

      on E: Exception do begin
        // could be an invalid return address
        if Pos('invalid address', LowerCase(E.Message)) > 0 then
        begin
          if Pos(' ', ipsSMTPS1.From) > 0 then
            raise EMailSendFailed.Create( 'Invalid ' + UsingAddr + ' email address: ' + ipsSMTPS1.From)
          else if Pos(' ', ipsSMTPS1.SendTo) > 0 then
            raise EMailSendFailed.Create( 'Invalid TO email address: ' + ipsSMTPS1.SendTo)
          else
            raise EMailSendFailed.Create( 'Invalid email address')
        end
        else
          raise EMailSendFailed.Create(E.Message);
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMailModule.SetOnStatusChangeMeth(const Value: TStatusChangeMeth);
begin
  FOnStatusChangeMeth := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMailModule.SetOnStatusChangeProc(const Value: TStatusChangeProc);
begin
  FOnStatusChangeProc := Value;
end;

procedure TMailModule.EMailPrepareImageforSaving(RTFData: TWPRTFDataCollection;
  Writer: TWPCustomTextWriter; TextObject: TWPTextObj; var DontSave: Boolean);
var lName: string;

   function NewImagesFilename: string;
   var I: Integer;
   begin
      I := 0;
      repeat
         Inc(I);
         Result := EmailDir + Format( 'Picture%d.', [I] ) + TextObject.ObjRef.FileExtension;
      until not BKFileExists(Result);
   end;


begin
  // We clear Source and StreamName to make sure the embedded data is saved to file
  TextObject.Source := '';
  if TextObject.ObjRef <> nil then begin
     TextObject.ObjRef.StreamName := '';
     lName := NewImagesFilename;
     TextObject.ObjRef.SaveToFile('', LName, '' );

     TextObject.ObjRef.FileName := ExtractFileName( LName);

     ImagesList.Add(LName);
  end;
end;



//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMailModule.UpdateStatus(NewMsg: string);
//call the procedure or method if assigned which updates the status msg info
//allows a routine calling this module to receive status change updates
begin
   if Assigned( FOnStatusChangeProc) then
      FOnStatusChangeProc( Self, NewMsg);

   if Assigned( FOnStatusChangeMeth) then
      FOnStatusChangeMeth( Self, NewMsg);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CheckMailSetup( var Error : string) : boolean;
//check the selected email method is setup correctly, returns an error message
//and false if not setup correctly
//var
//   MAPIControl : TEmail;

begin
   result := true;
   if ( INI_Mail_Type = MAPI_MAIL ) then begin
      //see if mapi is available on this PC

   end;

   if ( INI_Mail_Type = SMTP_MAIL) then begin
      //check that a mail server has been setup
      if INI_SMTP_Server = '' then begin
         Error := 'Your Email settings are configured to use Internet Mail, however '+
                  'you have not specified a Internet Mail Server to use.' +#13+#13+
                  'Please change your Email settings (File | Preferences)';
         result := false;
      end;
   end;
end;

function EmailDir: string;
begin
   Result := DataDir + 'Email\';
   CreateDir(Result);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(*
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure StatusChange ( Sender : TObject; sMsg : string);
begin
   Logutil.LogMsg( lmInfo, 'test', sMsg);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TestMail;
var
   MailObj : TMailModule;
   i : integer;
   sMsg : string;
   MailSent : boolean;
   Code : string;
begin
   //Create Mail Object and message
   MailObj := TMailModule.Create(nil);
   try
      with MailObj do begin
         //Assign Status Procedural Pointer
         OnStatusChangeProc := StatusChange;
         //Connect, Send Mail, Disconnect
         try
            if Connect then begin
               MailSent := false;
               for i := 1 to 1 do begin
                  //Build Message
                  NewMessage;
                  with AdminSystem.fdFields do begin
                     FromName  := Username;
                     FromAddr  := fdPractice_EMail_Address;
                     Recipients.Add('mhopkins@banklink.co.nz');
                     Subject   := fdSched_Rep_Email_Subject;
                     Body.Text := fdSched_Rep_Email_Line1 + fdSched_Rep_Email_Line2;
                     //Attachments.Add( EmailOutboxDir + 'CODING.TXT');
                  end;
                  //Send Message(s)
                  try
                     SendMail;
                  except
                     //if mail cannot be sent an exception will be raised
                     on e: EMailSendFailed do begin
                        sMsg := 'Unable to Send Mail ('+e.Message+')';
                        LogUtil.LogMsg( lmError, UnitName, sMsg);
                        HelpfulErrorMsg( sMsg,0);
                     end;
                  end;
               end;
               Disconnect;
            end
            else begin
               //Should only get here if Connect failed without causing an exception
               //Could be because User aborted the connect
               HelpfulErrorMsg('Unable to Send Mail. Connection Failed',0);
            end;

         //Handle exceptions from Mail Object
         except
            on e: EMailConnectFailed do begin
               sMsg := 'Unable to Send Mail. Connection Failed ('+ e.Message +')';
               LogUtil.LogMsg( lmError, UnitName, sMsg);
               HelpfulErrorMsg( sMsg,0);
            end;
            on e: EMailDisconnectFailed do begin
               //Just log it.  Don't need to tell user.  Connection should be
               //terminated when object is freed
               sMsg := 'Disconnect Failed (' + e.Message + ')';
               LogUtil.LogMsg( lmError, UnitName, sMsg);
            end;
         end;
         //
      end;
   finally
      MailObj.Free;
   end;
end;
*)
procedure TMailModule.ipsSMTPS1Error(Sender: TObject; ErrorCode: Integer;
  const Description: String);
begin
  showmessage(description);
end;

procedure ParseRecipients(Recipients: string; List: TStrings);
Var
   Recip : string;
   i     : Integer;
begin
   List.beginUpdate;
   Try
      List.Clear;
      i := Pos(';', Recipients);
      While i <> 0 do begin
         Recip := Trim(Copy(Recipients, 1, i - 1));
         if Recip <> '' then begin
            List.Add(Recip)
         end;

         Delete(Recipients, 1, i);
         i := Pos(';', Recipients);
      end { i <> 0 };

      Recip := Trim(Recipients);
      if Recip <> '' then begin
         List.Add(Recip)
      end;
   Finally
      List.endUpdate;
   end { try };
end;

// Use Redemption library to send a 'safe' mail item. i.e. one that does not show a security prompt
// Note that the 'out-of-proc' exceptions you see when running in the IDE are expected (they do not show when running outside the IDE)
// http://www.dimastr.com/redemption/
function TMailModule.SendViaRedemption: Boolean;
var
  OleItem, Session: OleVariant;
  RedemptionRecipient: Variant;
  i: Integer;

  function FailMask( E: EOleSysError): Boolean;
  begin
     Result := True;
     if PracIni_MAPI_MaskError = '' then
        Exit;
     if not Sametext(intToStr(E.ErrorCode),PracIni_MAPI_MaskError) then
        Exit;
     Result := False;
  end;

begin
  Result := False;
  try
     try
        // try to use existing instance if it exists
        session := GetActiveOleObject(ExtendedMapiComName + '.bkRDOSession');
     except // otherwise create one
        session := CreateOleObject(ExtendedMapiComName + '.bkRDOSession') ;
     end;
     Session.AuthKey := MapiAuthKey;
     Session.Logon;

     try

     OleItem := Session.GetDefaultFolder( olFolderOutbox ).Items.Add;

     for i := 0 to Recipients.Count - 1 do
        OleItem. Recipients. Add(Recipients[i]);
     for i := 0 to CarbonCopy.Count - 1 do begin
        RedemptionRecipient := OleItem.Recipients.Add(CarbonCopy[i]);
        RedemptionRecipient.Type := olCC;
        RedemptionRecipient.Resolve;
     end;

     OleItem.Recipients.ResolveAll;

     OleItem .Subject := Subject;
     // Do The plain text first..
     Email.OnPrepareImageforSaving := nil;
     OleItem.Body := EMail.AsAnsiString('ANSI');

     // Do The HTML part..
     Email.OnPrepareImageforSaving := EMailPrepareImageforSaving;
     OleItem.HTMLBody := EMail.AsAnsiString('HTML');
     for i := 0 to ImagesList.Count-1 do begin
        if (BKFileExists(ImagesList[i])) then begin
           OleItem.Attachments.Add( ImagesList[i]);
           if DebugMe then
              LogUtil.LogMsg(lmInfo, UnitName, 'Attachment ' + ImagesList[i]);
        end else
           LogUtil.LogMsg(lmInfo, UnitName, 'Attachment Not Found (' + ImagesList[i] + ').');
     end;
     Email.OnPrepareImageforSaving := nil;


     for i := 0 to Attachments.Count-1 do begin
        if (BKFileExists(Attachments[i])) then begin
           OleItem.Attachments.Add( Attachments[i]);
           if DebugMe then
              LogUtil.LogMsg(lmInfo, UnitName, 'Attachment ' + Attachments[i]);
        end else
           LogUtil.LogMsg(lmInfo, UnitName, 'Attachment Not Found (' + Attachments[i] + ').');
     end;

     //RedemptionItem.Save; not needed?

     UpdateStatus('Sending Mail to MAPI Outbox');

     try try
        OleItem.Send;
     except
     end;
     finally
        OleItem := Unassigned;
     end;


     // Next bits are tricks to make sure various versions of outlook,
     // Or types of connections (Exchange versus SMTP)
     // actually send the Emial. (Move from the outbox)
     try try
        OleItem := MAPINamespace.SyncObjects.Item(1);
        OleItem.Start;
     except
     end;
     finally
        OleItem := Unassigned;
     end;

     OleItem := CreateOleObject(ExtendedMapiComName+'.bkMAPIUtils');
     try try
        OleItem.AuthKey := MapiAuthKey;
        OleItem.DeliverNow;
        OleItem.Cleanup;
     except
     end;
     finally
        OleItem := Unassigned;
     end;


     UpdateStatus('Send Mail Successful');
     Result := true;

     finally
        Session . LogOff;

        Session := UnAssigned;
     end;
  except
     // obvoiusly a problem with the 'Redemption DLL
     On E : Exception do
     begin
       raise EMailSendFailed.Create('Extended MAPI failure: ' + E.Message + ' [' + E.ClassName + ']'); // 'does not appear to be enabled on this Workstation');
     end;
  end;

end;

function TMailModule.SendViaSMTP: Boolean;
var I: Integer;
    MultipartLevel: Integer;

    function GetMsgString(HeadersOnly: Boolean): string;
    var ls: TStringStream;
    begin
       ls := TStringStream.Create('');
       try
          smtpMessage.SaveToStream(ls,HeadersOnly);
          Result := ls.DataString;
       finally
          ls.Free;
       end;
    end;

    function GetOtherHeaders: string;
    var
      j: integer;
      IPWorksHeaderList: TStringList;
      IndyHeaderList: TStringList;
      ls: TStringStream;
    begin
      Result := '';
      //TFS 4762 - Remove duplicate headers
      IPWorksHeaderList := TStringList.Create;
      try
        IPWorksHeaderList.NameValueSeparator := ':';
        IPWorksHeaderList.Text := ipsSMTPS1.MessageHeaders;

        IndyHeaderList := TStringList.Create;
        try
          IndyHeaderList.NameValueSeparator := ':';
          ls := TStringStream.Create('');
          try
            smtpMessage.SaveToStream(ls, True);
            IndyHeaderList.Text := ls.DataString;
          finally
            ls.Free;
          end;

          for j := Pred(IndyHeaderList.Count) downto 0 do begin
            if IPWorksHeaderList.IndexOfName(IndyHeaderList.Names[j]) >= 0 then
              IndyHeaderList.Delete(j);
          end;

          Result := IndyHeaderList.Text;

        finally
          IndyHeaderList.Free;
        end;
      finally
        IPWorksHeaderList.Free;
      end;
    end;

begin
    Result := false;
    if DebugMe then begin
       logutil.LogMsg( lmInfo, Unitname, 'smtp server ' + INI_SMTP_Server);
       logutil.LogMsg( lmInfo, Unitname, 'from : ' + FromAddr);
       logutil.LogMsg( lmInfo, Unitname, 'to : + ' + Recipients.Text);
       logutil.LogMsg( lmInfo, Unitname, 'cc : + ' + CarbonCopy.Text);
       if INI_SMTP_Auth then begin
          logutil.LogMsg( lmInfo, Unitname, 'User = ' +  INI_SMTP_Account);
          if (INI_SMTP_Password <> '') then
             logutil.LogMsg( lmInfo, Unitname, 'Password supplied');
       end
    end;

    //SMTP Mail
    ipsSMTPS1.From := FromAddr;
    ipsSMTPS1.Subject := Subject;
    ipsSMTPS1.SendTo := Recipients.CommaText;
    ipsSMTPS1.Cc := CarbonCopy.CommaText;

    smtpMessage.Clear;
    // Seems a bit double-up,
    // Just making sure the header gets filled in
    smtpMessage.From.Address := FromAddr;
    smtpMessage.Subject := Subject;

    //http://www.indyproject.org/Sockets/Blogs/RLebeau/2005_08_17_A.EN.aspx
    if Attachments.Count > 0 then begin
       // Need more levels...
       MultipartLevel := 1;
       with TIdText.Create(smtpMessage.MessageParts, nil) do begin
          ContentType :='multipart/related; type="multipart/alternative"';
       end;
       smtpMessage.ContentType := 'multipart/mixed'
    end else begin
       MultipartLevel := 0;
       smtpMessage.ContentType :=  'multipart/related; type="multipart/alternative"'
    end;

    // Add the Plain / HTML alternative parts..
    with TIdText.Create(smtpMessage.MessageParts, nil) do begin
       ContentType := 'multipart/alternative';
       ParentPart :=  Pred(MultipartLevel);
    end;
    // Add the Plain text
    with TIdText.Create(smtpMessage.MessageParts, nil) do begin

       Email.OnPrepareImageforSaving := nil;
          Body.Text := Email.AsANSIString('Ansi');
       ContentType := 'text/plain';
       ParentPart := MultipartLevel;
    end;

    // Add the HTML part
    with TIdText.Create(smtpMessage.MessageParts, nil) do begin
       ClearImages;
       Email.OnPrepareImageforSaving := EMailPrepareImageforSaving;
          Body.Text := EMail.AsAnsiString('HTML');
       Email.OnPrepareImageforSaving := nil;
       ContentType := 'text/html';
       ParentPart := MultipartLevel;
       // Does not need to be in the HTML Begin-End
       for I := 0 to ImagesList.Count - 1 do begin
           with TIdAttachmentFile.Create(smtpMessage.MessageParts, ImagesList[I]) do begin
              ContentID := IntToStr(Succ(I)); // Should end up in the HTML text (but it does not..)
              FileName := extractFilename( ImagesList[I]);
              //ContentType := 'image';
              ParentPart := Pred(MultipartLevel); // Does not relate to MultipartLevel
           end;
       end;

    end;

    if Attachments.Count > 0 then // not needed, but reads better..
       for I := 0 to Attachments.Count - 1 do begin
           with TIdAttachmentFile.Create(smtpMessage.MessageParts, Attachments[I]) do begin
              FileName := extractFilename( Attachments[I]);
              // No ParentPart, No ContentID
           end;
       end;


    try
       //Add Indy headers
       ipsSMTPS1.OtherHeaders := GetOtherHeaders;
       //Add Indy message
       ipsSMTPS1.MessageText := GetMsgString(False);
       ipsSMTPS1.Send;
       Result := True;
    finally
       ClearImages;
    end;
end;

initialization
  DebugMe := LogUtil.DebugUnit( UnitName );
end.

