unit Resync;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

procedure DoResyncClientFile;
procedure DoResyncMyClient;

//******************************************************************************
implementation
uses
   ReSyncClient,
   bkhelp,
   clObj32,
   globals,
   Admin32,
   bkConst,
   Files,
   bk5Except,
   ErrorMoreFrm,
   WarningMoreFrm,
   InfoMoreFrm,
   FrmAdoptOrSynchronise,
   LogUtil,
   YesNoDlg;
const
   UnitName = 'RESYNC';
var
   DebugMe : boolean = false;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoResyncClientFile;
const
   ThisMethodName = 'DoResyncAClientFile';
var
   aClient    : TClientObj;
   ClientCode : string;
begin
   if not RefreshAdmin then exit;

   //select client file to resync - client file should have been checked in
   aClient := nil;
   OpenAClient( '', aClient, False );    //will prompt for file name
   if not Assigned(aClient) then exit;

   try
     ClientCode := aClient.clFields.clCode;

     ResyncAClient( aClient );
     CloseAClient( aClient );

     HelpfulInfoMsg( 'Client File '+ClientCode+' has been synchronised '+
                     'with this Admin System.',0);
   except
     on e : EResyncFailed do begin
        AbandonAClient( aClient );
        HelpfulErrorMsg(e.Message,0);
     end;

     on e : EResyncVerifyFailed do begin
        AbandonAClient( aClient );
        HelpfulWarningMsg(e.Message,0);
        LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' '+e.Message);
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoResyncMyClient;
//uses the global client object
const
   ThisMethodName = 'DoResyncMyClient';
type
   tResyncAction = ( trResync, trAdopt);
var
   Action : tResyncAction;
begin
   if not (( Assigned(MyClient)) and ( RefreshAdmin )) then exit;

   //see if we are syncronising or adopting this client
   if (MyClient.clFields.clMagic_Number <> AdminSystem.fdFields.fdMagic_Number) and
      ( MyClient.clFields.clDownload_From <> bkConst.dlAdminSystem) then
   begin
     //ask the user
     Case AdoptOrSynchronise( MyClient.clFields.clName) of
       frmAdoptOrSynchronise.asAdoptClient : Action := trAdopt;
       frmAdoptOrSynchronise.asSyncroniseClient : Action := trResync;
     else
       exit;
     end;
   end
   else
   begin
     //we are sync'ing this file
     if AskYesNo( 'Synchronise Client File '+ MyClient.clFields.clCode,
                  'Synchronising this Client File will allow you to begin retrieving transactions '+
                  'from this Administration System.  If the Client File is from another Practice '+
                  'it will also be changed to belong to your Practice.'#13#13+
                  'Please confirm that you want to do this.',DLG_YES, BKH_Synchronising_client_files) <> DLG_YES then
        exit;

     Action := trResync;
   end;

   try
     case Action of
       trResync: begin
         ResyncAClient( MyClient );
         HelpfulInfoMsg( 'Client File '+MyClient.clFields.clCode+' has been synchronised '+
                     'with this Admin System.',0);
       end;
       trAdopt: begin
         AdoptAClient( MyClient);
         HelpfulInfoMsg( 'Client File '+MyClient.clFields.clCode+' is now associated '
                            + ' with your practice.',0);
       end;
     end;
   except
     on e : EResyncFailed do begin
        HelpfulErrorMsg(e.Message,0);
     end;

     on E : EResyncAbandoned do
     begin
       //user cancelled from prompts
     end;

     on e : EResyncVerifyFailed do begin
        HelpfulWarningMsg(e.Message,0);
        LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' '+e.Message);
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
