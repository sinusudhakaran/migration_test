unit bkhandlr_main;
//------------------------------------------------------------------------------
{
   Title:       BankLink File Assocation handler

   Description: main for for bk handler

   Author:      Matthew Hopkins Feb 2005

   Remarks:     this application handles the file associations and determines
                which bk5 folder to use when handling requests

                is hidden on application startup

   Additions:   Is to be extended to Handle trf filse

}
//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  DdeMan,
  StdCtrls,
  ExtCtrls,
  XPMan,
  shellapi;

type
  //----------------------------------------------------------------------------
  TfrmMain = class(TForm)
    DDEClientConv_BK: TDdeClientConv;
    bkSystem: TDdeServerConv;
    tmrClose: TTimer;
    XPManifest1: TXPManifest;
    procedure FormDestroy(Sender: TObject);
    procedure tmrCloseTimer(Sender: TObject);
    procedure bkSystemExecuteMacro(Sender: TObject; Msg: TStrings);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FBNotesPath: TFilename;
    FFGWindow: THandle;

    (*procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;*)
    procedure SetBNotesPath(const Value: TFilename);
    function DDECommandIs(Keyword : string; Command: string): boolean;
    procedure ProcessDDECommand( Command : string);

    Procedure ProcessCheckIn (Command : string);
    procedure ProcessOpen    (Command : string);
    Procedure ProcessImport  (Command : string);

    procedure BK5_FileTo_BK5    (Filename,Path : TFilename);
    procedure TRF_FileTo_BK5    (Filename,Path : TFilename);
    Procedure TRF_FileTo_BNotes (Filename : TFilename);


    Procedure ResetTimer;
    var DDECommandList : TStringList; //allow us to process multiple commands in sequence
    var ProcessingDDECommand : boolean; //flag to tell if we are currently processing
    var DDECommandReceived : boolean; //flag to tell if a command has been recieved, close app if nothing in 2 min
    var ListOfBK5Paths : TStringList;
    var TerminateAfterCurrentCommand : boolean; //ignore other waiting commands and terminate

    function FindBK5( var Status : integer) : boolean;
    var PathOfRunningBK5 : string;
    //var HandleOfRunningBK5 : THandle;

    function CheckIntoBK5Dir( bk5Dir : string;
                              IsRunning : boolean;
                              Filename : string;
                              iBk5Status : integer) : boolean;

    procedure SendCheckInCommand(Filename, bk5Dir: string);
    function GetBK5Status( bk5path : string): string;

    procedure DebugMsg( s : string);
    Function BNotesInstalled : boolean;
    Function BK5Installed : boolean;
    Function BNotesRunning : Boolean;
    Function MoveFile(Var Filename : TFilename; Const ToPath: TFilename): Boolean;
    Property BNotesPath: TFilename read FBNotesPath write SetBNotesPath;
    procedure SetFGWindow(const Value: THandle);

  public
    property FGWindow : THandle read FFGWindow write SetFGWindow;
  end;

var
  frmMain: TfrmMain;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  Registry,
  selectbkFolderFrm,
  TimeUtils,
  selectTRFcheckinfrm,
  RegistryUtils,
  BKHandConsts;

const
  //Command keywords - must be lower case
  cmd_CheckIn = 'checkin';     KeywordLength_Checkin = length(cmd_Checkin);
  cmd_Open    = 'open';        KeywordLength_Open    = length(cmd_open);
  cmd_Import  = 'import';      KeywordLength_Import  = length(cmd_Import);
  cmd_Hello   = 'sayhello';

Const
  // As per unit ecGlobalConst for BNotes
  // Should link direct but too had for Source-safe ??
  BN_APP_NAME         = BRAND_NAME + ' BNotes';
  BN_APP_TITLE        = 'BNotes';
  TRF_FILE_EXTN       = '.trf';

  BK5_FILE_EXTN       = '.bk5';
  BN_REG_ROOT         = BRAND_NAME + 'BNotesFile';

//------------------------------------------------------------------------------
procedure TfrmMain.FormCreate(Sender: TObject);
var
  ExeFilename : string;
  i : integer;
begin
  DebugMsg( 'Create');
  Self.Caption := BRAND_FULL_APP_NAME;

  fgWindow := GetForegroundWindow;
  DDECommandList := TSTringList.Create;
  ListOfBK5Paths := TStringList.Create;

  DDECommandReceived := false;  //if no command received in 2 minutes then close
  TerminateAfterCurrentCommand := false;

  //get paths from registry
  GetExePaths( ListOfBK5Paths);
  //remove invalid paths, may happen if network drive is no longer available
  i := 0;
  while ( i < ListOfBK5Paths.Count) do
  begin
    ExeFilename := ListOfBK5Paths.Strings[i] + 'bk5win.exe';
    if not FileExists( ExeFilename) then
    begin
      ListOfBK5Paths.Delete(i);
    end
    else
      i := i + 1;
  end;

  //set self destruct timer
  tmrClose.Interval := 60000 * 5;
  tmrClose.Enabled := true;
end;

//------------------------------------------------------------------------------
procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  DDECommandList.Free;
  ListOfBK5Paths.Free;
  if FGwindow <> 0 then
     SetForeGroundwindow(FGwindow);
end;

//------------------------------------------------------------------------------
procedure TfrmMain.bkSystemExecuteMacro(Sender: TObject; Msg: TStrings);
//checks that there is a command to process and then closes the application
var
  Command : string;
begin
  if Msg.Text <> '' then
  begin
    Command := Msg[0];

    DDECommandReceived := true;

    //is this a valid command?
    if DDECommandIs(cmd_CheckIn, Command)
    or DDECommandIs(cmd_Open,    Command)
    or DDECommandIs(cmd_Import,  Command)
    or DDECommandIs(cmd_Hello,   Command) then
       ProcessDDECommand(Command);
  end;
  //close app now

  if (not ProcessingDDECommand)
  or (TerminateAfterCurrentCommand) then
     Application.Terminate;

end;

(*procedure TfrmMain.WMCopyData(var Msg: TWMCopyData);
//expect to receive back a message from currently running bk5 application to
//tell us what directory it is running in
var
  PData: PChar;  // walks thru data
  Param : string;
begin
  //check that the message is for us
  Msg.Result := 0;
  if Msg.CopyDataStruct.dwData <> Self.Handle then
    exit;

  // extract strings from data
  PData := Msg.CopyDataStruct.lpData;
  Param := StrPas(PData);
  PathOfRunningBK5 := Param;

  // set return value to indicate we handled message
  Msg.Result := 1;
end;*)

//------------------------------------------------------------------------------
procedure TfrmMain.tmrCloseTimer(Sender: TObject);
begin
  //force a close if still running 2 min after processing the last command
  If ProcessingDDECommand Then ResetTimer
  Else Application.Terminate;
end;

//------------------------------------------------------------------------------
function TfrmMain.DDECommandIs(Keyword : string; Command: string): boolean;
begin
    result := Pos( '[' + Keyword, lowercase(Command)) = 1;
end;

//------------------------------------------------------------------------------
procedure TfrmMain.ProcessDDECommand(Command: string);
//decides which method should process a particular command
//can cache DDE commands and act on them after current command has finished
var
  CachedCommand : string;
begin
  //make sure that we are not already processing a command, this is in case
  //multiple dde calls have been made to this exe
  if ProcessingDDECommand then
  begin
    DebugMsg( 'Busy, command cached ' + Command);
    //add to list of pending dde commands, only add if not already there
    if DDECommandList.IndexOf( Command) = -1 then
      DDECommandList.Add( Command);
    exit;
  end;
  // Do this first.. ResetTimer will 'yield'
  ProcessingDDECommand := true;

  //reset the self destruct timer
  ResetTimer;
  try
    DebugMsg( 'Processing ' + Command);
    if DDECommandIs( cmd_CheckIn, Command) then
    begin
      ProcessCheckIn( Command);
    end
    else
    if DDECommandIs( cmd_Open, Command) then
    begin
      ProcessOpen(Command);
    end
    else
    if DDECommandIs( cmd_Import, Command) then
    begin
      ProcessImport(Command);
    end
    else
    if DDECommandIs( cmd_Hello, Command) then
      ShowMessage( Application.ExeName + ' says hello!'+ #13 + Command);
  finally
    ProcessingDDECommand := false;
  end;

  //see if we should immediately exit, ignoring cached commands
  if not TerminateAfterCurrentCommand then
  begin
    //process any cached commands
    while DDECommandList.Count > 0 do
    begin
      CachedCommand := DDECommandList[0];
      DDECommandList.Delete(0);

      ProcessDDECommand( CachedCommand);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TfrmMain.CheckIntoBK5Dir( bk5Dir : string; IsRunning : boolean; Filename : string; iBk5Status : integer) : boolean;
//confirm that the user wants to check in the selected directory
//parameters:  bk5Dir : directory to check file into
//             IsRunning : allows us to alter the message to the user if Bk5 is running
//             filename : filename to check in
var
  aMsg : string;
begin
  result := false;
  if IsRunning then
  begin
    if ( iBK5Status <> 1) then
    begin
      aMsg := BRAND_NAME + ' cannot handle your request at the moment, please try again later.';
      //add some info to tell us why  0 = no path, 1 = send message failed
      aMsg := aMsg + ' [' + inttostr( iBK5Status) + ']';

      //bk5 application is running but cannot process commands at the moment
      ShowMessage( aMsg);
      TerminateAfterCurrentCommand := true;
      exit;
    end
    else
      aMsg := BRAND_NAME + ' is currently running in folder '#13#13 +
            bk5Dir + #13+#13 +
            'Would you like to update the file ' + ExtractFileName( Filename) +
            ' in this copy of ' + BRAND_NAME + '?';

  end
  else
  begin
    aMsg := 'Would you like to update the file ' + ExtractFilename( Filename) + #13#13 +
            'in the copy of ' + BRAND_NAME + ' in the '+  bk5Dir + ' folder?';
  end;

  if MessageDlg( aMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    result := true;
end;

//------------------------------------------------------------------------------
procedure TfrmMain.SendCheckInCommand( Filename : string; bk5Dir : string);
//set up a macro to send to bk5
var
  Macro : string;
begin
  if not FileExists( bk5Dir + 'bk5win.exe') then
  begin
    ShowMessage('The location specified is not a valid ' + BRAND_NAME + ' folder');
    Exit;
  end;

  ddeClientConv_BK.ServiceApplication := bk5Dir + 'bk5win';
  ddeClientConv_BK.SetLink( 'bk5win','bk5win');

  if ddeClientConv_BK.OpenLink then
  begin
    Macro := '[Checkin("' + filename + '")]';
    ddeClientConv_BK.ExecuteMacro( PChar(Macro), false);
    ddeClientConv_BK.CloseLink;
  end
  else
    ShowMessage('Error processing request');
end;

//------------------------------------------------------------------------------
procedure TfrmMain.BK5_FileTo_BK5(FileName,Path: TFilename);
//handle check in command
//checks to see that we are not in a bk5 folder
//asks the user which folder to use if more than one found
var
  FilePath : string;
  BkPathToUse : string;
  BKIsRunning : boolean;
  ET : EventTimer;
  int_Bk5Status : integer;

  //----------------------------------------------------------------------------
  procedure CleanUpOutlookTempDir;
  begin
    //if this is the temp outlook folder then need to delete it, otherwise
    //the next time we dbl click outlook will create file CLIENT (2).BK5
    if Pos( 'temporary internet files\olk', lowercase( filepath)) > 0 then
    begin
      //delete temporary attachment
      DeleteFile( Filename);
      //delete .bk! file ???

    end;
  end;

begin
  if ListOfBK5Paths.Count = 0 then
  begin
    MessageDlg( 'Cannot find ' + BRAND_NAME + ' on this workstation, please run ' + BRAND_NAME + ' before '+
                'attempting to do this.', mtInformation, [mbOK], 0);
    Exit;
  end;

  //command will be in the format  [Checkin("filename")], need to extract just the filename part
  FilePath := ExtractFilePath( Filename);

  //test of bk5 in this directory
  if FileExists( Filepath + 'bk5win.exe') then
  begin
    MessageDlg('Cannot update this file because it is already in a ' + BRAND_NAME + ' folder.', mtInformation, [mbOK], 0);
    CleanUpOutlookTempDir;
    exit;
  end;


  DebugMsg( 'check in command  ' + Filename);
  //this is designed to handle multiple checkins
  TimeUtils.NewTimerSecs( ET, 45);
  repeat
    bkIsRunning := FindBK5( int_Bk5Status);
    if (int_Bk5Status = 3)
    or ( int_bk5status = 4) then
    begin
      //bk5 is currenty busy, wait 2 sec and try again
      DelayMS( 2000, true);
      debugMsg( 'waiting check in ' + Filename);
    end;
  until (not ((int_Bk5Status = 3) or (int_Bk5Status = 4))) or ( TimerExpired( ET));

  //is banklink running?
  if bkIsRunning then
  begin
    //ask the user if they want to check in to the current BK5
    if CheckIntoBK5Dir( PathOfRunningBK5, true, filename, int_Bk5Status) then
      SendCheckInCommand( Filename, PathOfRunningBK5)
    else
    begin
      CleanUpOutlookTempDir;
    end;
  end
  else
  begin
    //how many bk5 paths are there is the registry, if only one then ask to
    //check in there
    if ListOfBK5Paths.Count = 1 then
    begin
      if CheckIntoBK5Dir( ListOfBK5Paths[0], false, filename, int_Bk5Status) then
        SendCheckInCommand( Filename, ListOfBK5Paths[0])
      else
      begin
        CleanUpOutlookTempDir;
      end;
    end
    else
    begin
      //multiple copies of bk5 exist, please select one
      bkPathToUse := SelectBK5Folder( ListOfBK5Paths.Text, filename);
      if bkPathToUse <> '' then
        SendCheckInCommand( Filename, BkPathToUse)
      else
        CleanUpOutlookTempDir;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TfrmMain.GetBK5Status( bk5path : string) : string;
var
  Cmd : string;
  ReturnString : string;
begin
  result := '';

  ddeClientConv_BK.ServiceApplication := bk5path + 'bk5win';
  ddeClientConv_BK.SetLink( 'bk5win','bk5win');

  if ddeClientConv_BK.OpenLink then
  begin
    Cmd := '?='+bk5path;
    ddeClientConv_Bk.PokeData('DdeStatus', PChar( Cmd) );
    ReturnString := ddeClientConv_bk.RequestData('DdeStatus');
    result := Copy( ReturnString, 1, pos( '>', ReturnString));
    ddeClientConv_BK.CloseLink;
  end;
end;

//------------------------------------------------------------------------------
function TfrmMain.FindBK5( var Status : integer) : boolean;
//sets the handle and dir variables in this form to details of the current bk5
//also sets the bk5IsBusy flag so we can make sure that bk5 processed the message
//message result values 0 = none, 1 = ok, 2 = busy, -1 = error

//parameters:
//     result : true if can find a running bk5

  //----------------------------------------------------------------------------
  function CheckMutex  : Boolean;
  var
    Mutex : THandle;
  begin
    Result := False;
    Mutex := CreateMutex(nil, False , BRAND_NAME + ' 5');
    if (Mutex <> 0) then try
    case GetlastError of
       0 : ; //Nobody owened one..Done..
       ERROR_ALREADY_EXISTS : begin
            Result := true;
         end;
    end;//case
    finally
       CloseHandle(Mutex);
    end;
  end;

var
  bk5StatusStr : string;
begin
  //find bk5 application
  //HandleOfRunningBK5 := FindWindow( nil, 'BankLink 5');
  PathOfRunningBK5 := '';
  Status := 0;
  PathOfRunningBK5 := RegistryUtils.GetCurrentExePath;
  if CheckMutex  then
  begin  // Is running...

    bk5StatusStr := GetBK5Status( PathOfRunningBK5);

    if bk5StatusStr = '<OK>' then
      Status := 1
    else
    if bk5StatusStr = '<BUSY>' then
      Status := 2
    else
    if bk5StatusStr = '<BUSYDDE>' then
      Status := 3
    else
    if bk5StatusStr = '<BUSYSTART>' then
      Status := 4
    else
    if bk5StatusStr = '<WRONG>' then
      Status := -2
    else
      Status := -1;

    //code below is for alternative methods that i tried to get the status and
    //bk5 dir for the current bk5

    //MessageResult := SendMessage( HandleOfRunningBK5, BK_DIR_REQUEST, Self.Handle, 0);
    //alternative method, relies on reg entry being correct rather than
    //a conversation to determine where bk5 is running
    //check registry to see read current dir
    //see if is able to process message and is not doing something modal
    //MessageResult := SendMessage( HandleOfRunningBK5, BK_IS_BUSY, 0, 0);
    //if ( MessageResult = 1) and ( PathOfRunningBK5 = '') then
    //  MessageResult := 6;
  end;
  result := ( Status <> 0);
end;

//------------------------------------------------------------------------------
procedure TfrmMain.ProcessOpen(Command: string);

Var Filename : String;
    LExt : String;
    OpenWith : TOpenWith;
    OpenOptions : TOpenOptions;
    BK5path : String;
    int_Bk5Status : integer;
begin
   //command will be in the format  [Open("filename")], need to extract just the filename part
   Filename := Copy( Command, KeywordLength_Open + 4, Length( Command) - KeywordLength_Open - 6);  //-6 =  [(" + ")]
   //Should be a trf file, but could be double clicked.. so could mean 'import'
   if BNotesInstalled then begin
      if BK5Installed then begin
         // BK5 AND BNotes
         if findbk5(int_Bk5Status) then
            BK5path := PathOfRunningBK5 // The only valid path..
         Else
            BK5Path := ListOfBK5Paths.Text;
         If SelectOpenWith
               (BK5path,OpenWith,[OW_BNotes, OW_BK5_Path],Filename,BK5Path) then
            Case OpenWith of
            OW_BNotes : TRF_FileTo_BNotes(Filename);
            OW_BK5_Path : TRF_FileTo_BK5 (Filename,BK5Path);
            end;
      end else begin
         // BNotes Only
         TRF_FileTo_BNotes(Filename);
      end;
   end else if BK5Installed then begin
      // BK5 only...
      if ListOfBK5Paths.Count > 1 then begin
         // Check if running..

         if findbk5(int_Bk5Status) then begin
            // confirm first..
            if MessageDlg(
               BRAND_FULL_NAME + ' is currently running in folder '#13#13 +
                  PathOfRunningBK5 +
               #13#13'Would you like to import the file ' +
                  ExtractFileName( Filename) +
               ' to this copy of ' + BRAND_NAME + '?'
                 ,mtConfirmation, [mbYes, mbNo], 0) = mrYes then
                     TRF_FileTo_BK5 (Filename,PathOfRunningBK5);

         end else begin
            If SelectOpenWith
               (BK5path,OpenWith,[OW_BK5_Path],Filename,ListOfBK5Paths.Text) then begin
                 TRF_FileTo_BK5 (Filename,BK5Path);
            end
         end
      end else begin
         TRF_FileTo_BK5(Filename,ListOfBK5Paths[0] );
      end
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmMain.ProcessImport(Command: string);
var FileName : string;
    int_Bk5Status : integer;
    OpenWith : TOpenWith;
    OpenOptions : TOpenOptions;
    BK5path : String;
begin // to KB 5 ONLY
  Filename := Copy( Command, KeywordLength_import + 4, Length( Command) - KeywordLength_import - 6);  //-6 =  [(" + ")]
  if BK5Installed then begin
     if ListOfBK5Paths.Count > 1 then begin
        //More than 1, Check if running..
        if findbk5(int_Bk5Status) then begin
            // confirm first..
            if MessageDlg(
               BRAND_NAME + ' is currently running in folder '#13#13 +
                  PathOfRunningBK5 +
               #13#13'Would you like to import the file ' +
                  ExtractFileName( Filename) +
               ' to this copy of ' + BRAND_NAME + '?'
                 ,mtConfirmation, [mbYes, mbNo], 0) = mrYes then
                     TRF_FileTo_BK5 (Filename,PathOfRunningBK5);

        end else begin
            If SelectOpenWith
               (BK5path,OpenWith,[OW_BK5_Path],Filename,ListOfBK5Paths.Text) then begin
                 TRF_FileTo_BK5 (Filename,BK5Path);
            end
         end
      end else begin
         TRF_FileTo_BK5(Filename,ListOfBK5Paths[0] );
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmMain.ProcessCheckIn(Command: String);
Var Filename : String;
begin
  //command will be in the format  [Checkin("filename")], need to extract just the filename part
  Filename := Copy( Command, KeywordLength_Checkin + 4, Length( Command) - KeywordLength_Checkin - 6);  //-6 =  [(" + ")]

  // BK5 File...

  BK5_FileTo_BK5(Filename,'');

end;

//------------------------------------------------------------------------------
procedure TfrmMain.DebugMsg(s: string);
begin
{$IFDEF bkDebugMsgOn}
  OutputDebugString( PChar(s));
{$ENDIF}
end;

//------------------------------------------------------------------------------
procedure TfrmMain.ResetTimer;
begin
   Try // Courtesy only, Dont want any Exceptions to float to ProcessDDECommand
     if tmrClose.Enabled Then tmrClose.Enabled := false;
     tmrClose.Enabled := true;
   Except
   End;
end;

//------------------------------------------------------------------------------
procedure TfrmMain.TRF_FileTo_BNotes(Filename: TFilename);

  function BNotesNotRunning : Boolean;
  begin
     Result := false;
     while bNotesRunning do begin
        case MessageDlg(BRAND_NOTES_NAME + ' is running, please exit first',
            mtError,
            [mbCancel,mbretry],
            0) of
            idCancel : Exit; // Just cancel..
        end;
     end;
     result := true;
  end;

begin
  // This assumes that 'BNotesInstalled' has run..

  if Length(BNotesPath) > 0 then begin
     if BNotesNotRunning then
        if MoveFile(Filename, BNotesPath) then
            Shellexecute(0,'Open',
                       Pchar( '"' + BNotesPath + '"'),
                       pchar ('"'+ Filename + '"'),
                       nil,
                       SW_ShowNormal);

           {
           Winexec(Pchar( '"' + BNotesPath + '" "'
                           + Filename + '"'),
                           SW_ShowNormal   );
           }
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMain.SetBNotesPath(const Value: TFilename);
begin
  FBNotesPath := Value;
end;

//------------------------------------------------------------------------------
function TfrmMain.BNotesRunning: Boolean;
Var hMutex : THandle;
begin
  Result := False;
  hMutex := CreateMutex( nil, false, BN_APP_TITLE );
  if ( hMutex <> 0 ) Then Try
     Result := ( GetLastError = ERROR_ALREADY_EXISTS );
  Finally
     // Must close imidiate.. Stops the 'realone' from running..
     CloseHandle( hMutex );
  End;
end;

//------------------------------------------------------------------------------
procedure TfrmMain.TRF_FileTo_BK5(Filename, Path : TFilename);
Var macro : String;

    Function CheckRrunning : Boolean;
    Var  Status : Integer;
    begin
       Result := False;
       if FindBK5( Status ) then begin
          case status of
           // is running...
           1 : Result := true; // Bk5 checks the rest...

           Else Begin
               MessageDlg(BRAND_NAME + ' cannot handle your request at the moment'#13' please try again later.',
                       mtInformation,
                       [mbOK],
                       0);

             End;
          end;
      end else begin
         // Not running...
         // But the DDE link will fix that...
         Result := true;
      end;
    end;
begin
   If CheckRrunning Then

   If MoveFile(Filename, Path) then begin

      ddeClientConv_BK.ServiceApplication := path + 'bk5win';
      ddeClientConv_BK.SetLink( 'bk5win','bk5win');
      if ddeClientConv_BK.OpenLink then begin
         Macro := '[Import("' + filename + '")]';
         ddeClientConv_BK.ExecuteMacro( PChar(Macro), false);
         ddeClientConv_BK.CloseLink;
      end
   end;
end;

//------------------------------------------------------------------------------
function TfrmMain.BNotesInstalled: boolean;
var
  RegObj : TRegistry;
  S : String;

  function CheckFile (Value : String): boolean;
  var P : integer;
  begin
     Result := false;
     If Length(Value) = 0 then
        Exit;

     if pos('"',Value) = 1 then begin
        value := copy(Value,2,Length(Value));
        p := pos('"',Value);
        if p > 0 then
           Value := Copy(Value,1,pred(p))
        else
           Exit; // Not sure what we have here
     end else begin
        // maybe not quoted...
        p := pos ('%',Value);
        if p > 0 then
           Value := Copy(Value,1,pred(p));
     end;
     // Should be a valid file name now...
     Result := FileExists(value);
     if result then   // While we are here....
        BNotesPath := value;
  end;

begin
  BNotesPath := '';
  Result := False;
  RegObj := TRegistry.Create;
  try  try
     RegObj.RootKey := HKEY_CLASSES_ROOT;
     if NOT RegObj.OpenKeyReadOnly(BN_REG_ROOT) then
        Exit;

     if NOT RegObj.OpenKeyReadOnly('Shell\open\command') then
        Exit;

     S := RegObj.ReadString ('');

     if not Checkfile(s) then
        Exit;

     Result := True;
  except
  end;
  finally
    RegObj.Free;
  end;
end;

//------------------------------------------------------------------------------
function TfrmMain.BK5Installed: boolean;
begin
   Result := ListOfBK5Paths.Count > 0;
end;

//------------------------------------------------------------------------------
function TfrmMain.MoveFile(Var Filename : TFilename; Const ToPath: TFilename): Boolean;
Var Sourcepath, DestPath : TFilename;

    function CleanFilename (Value : Tfilename): TFilename;
    //var bp,ep : Integer;
    begin
       result := ExtractFilename(Filename);
       (*   May not be needed...
       bp := Pos('(',result);
       if bp = 0 then exit;
       ep := Pos(')',result);
       if ep > bp then begin
         result := Trim(copy(result,1,pred(bp))) // Outlook adds a space as well
                 + Trim(Copy(result,Succ(ep),255)); //Could work out the count..
       end else begin
          // could find the '.'
       end;
       *)
    end;

begin
   // copies the file and clean sup the name....
   Result := true;
   SourcePath := ExtractFilePath(Filename);
   Destpath := ExtractFilePath(ToPath);
   if NOT sametext(SourcePath, Destpath) then begin
      try
         // but while we are here, check if we need to clean up the file name
         Destpath := Destpath + CleanFilename (FileName);

         if CopyFile(pChar(FileName),
                     pchar(Destpath),false)  then begin
            Filename := DestPath;
            // I direct from outlook, it will be read only...
            SetFileAttributes(PChar(Filename),FILE_ATTRIBUTE_NORMAL);
         end else
            result := false;
      except
         result := false;
      end;
   end; // else already there...
end;

//------------------------------------------------------------------------------
procedure TfrmMain.SetFGWindow(const Value: THandle);
begin
  FFGWindow := Value;
end;

end.
