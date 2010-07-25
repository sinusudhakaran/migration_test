unit DownloadFloppy;

interface

function DoCopyFloppy(BankLinkCode : string; StartAt : integer) : integer;

implementation
uses
   SysUtils,
   GenUtils,
   LogUtil,
   Globals,
   DownloadUtils,
   ConfirmDlg,
   Controls,
   ErrorMoreFrm,
   Progress,
   FCopy,
   WinUtils;

const
   UnitName = 'DOWNLOADFLOPPY';
var
   DebugMe : boolean = false;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoCopyFloppy(BankLinkCode : string; StartAt : integer) : integer;
// Returns number of Floppy read or -1 if cancelled
const
   ThisMethodName = 'DoCopyFloppy';
var
   DownloadDir    : string;
   Count          : integer;
   LabelFilename  : string;
   OldFormatFilename : string;
   NewFormatFilename : string;
   DiskImageFound    : boolean;
   FloppyFileName : string;
   LocalFileName  : string;
   DiskAbort      : boolean;
   DiskOK         : boolean;
   DownloadCount  : integer;
   aMsg           : String;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   //check which drive - default is a:\
   if INI_DownloadFrom <> '' then
     DownloadDir := INI_DownloadFrom
   else
     DownloadDir := 'A:\';

   Count         := 0;
   DownloadCount := 0;
   DiskAbort     := False;
   DiskOk        := true;

   //exit loop if user selected cancel, or there was a problem copying the file
   while ((not DiskAbort) and DiskOK) do
   begin
     Inc(Count);
     DiskOK        := false;
     LabelFileName     := BankLinkCode + '.' + MakeSuffix(StartAt + Count);

     OldFormatFilename := GetOldFormatFilename( BankLinkCode, StartAt + Count);
     NewFormatFilename := GetNewFormatFilename( BankLinkCode, StartAt + Count);

     repeat
        if DownLoadCount = 0 then
           aMsg := Format( 'Please insert the %s Disk labelled '#13#13'%s', [ SHORTAPPNAME, LabelFileName ] )
        else
           aMsg := Format( 'If you have an additional Disk labelled'#13'%s'#13'Please Insert it now.'#13#13+
                          'Otherwise press Process to complete the %s download.', [ LabelFileName, SHORTAPPNAME ] );

        case ConfirmOKCancel('Download '+SHORTAPPNAME+' Disk', aMsg ) of
           mrOK : begin
             DiskImageFound := false;

             //Always look for the new format disk image first
             if BKFileExists( DOWNLOADDIR + NewFormatFilename) then
             begin
               LocalFileName  := DOWNLOADINBOXDIR + NewFormatFilename;
               FloppyFileName := DOWNLOADDIR + NewFormatFilename;
               DiskImageFound := true;
             end
             else if BKFileExists( DOWNLOADDIR + OldFormatFilename) then
             begin
               LocalFileName  := DOWNLOADINBOXDIR + OldFormatFilename;
               FloppyFileName := DOWNLOADDIR + OldFormatFilename;
               DiskImageFound := true;
             end;

             if not DiskImageFound then
             begin
               aMsg := 'The file was not found on this Floppy.'#13#13 +
                       'Please check that you have inserted the disk labelled ' + LabelFilename;

               HelpfulErrorMsg( aMsg, 0 );
               if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, aMsg );
             end
             else begin
               //File found so copy it
               try
                 aMsg := Format( 'Downloading Data on Floppy %s', [ LabelFilename ] );
                 UpdateAppStatus( 'Download Disk', aMsg, 0);
                 try
                    FCopy.CopyFile( FloppyFileName, LocalFileName );

                    aMsg := Format( 'Copied %s to %s', [ FloppyFileName, LocalFileName ] );
                    LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' - ' + aMsg );
                    DiskOK := true;
                    Inc(DownloadCount);
                 except
                   on E : EFCopyFailed do begin
                      aMsg := Format( 'File Copy Failed %s.', [ E.Message ] );
                      HelpfulErrorMsg( aMsg, 0);

                      SysUtils.DeleteFile(LocalFileName);  //clean up incase some leftover
                   end;
                 end;
               finally
                  ClearStatus;
               end;
             end;
           end;

           mrCancel : begin
             result := -1;
             Exit;
           end;

           mrYes : begin
             //process button returns this
             DiskAbort := true;
           end;
        end;
     Until DiskAbort or DiskOK;
   end;
   Result := DownloadCount;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
end.
