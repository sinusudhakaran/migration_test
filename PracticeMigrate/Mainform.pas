unit Mainform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  logger,
  LogMigrater, Dialogs, StdCtrls, ExtCtrls, ComCtrls, DB, ADODB, GuidList, sydefs, VirtualTreeHandler,
  VirtualTrees, MigrateActions,ClientMigrater,SystemMigrater, jpeg, ImgList,
  FMTBcd, SqlExpr;

type
   Tprogress = (SelectSource, Selection, Migrate, Done);

   TProvider = (AccountingSystem, TaxSystem);

type
  TformMain = class(TForm)
    pTop: TPanel;
    pBottom: TPanel;
    BtnCancel: TButton;
    BtnNext: TButton;
    PCMain: TPageControl;
    tsSelect: TTabSheet;
    cbUsers: TCheckBox;
    cbAccounts: TCheckBox;
    cbGroups: TCheckBox;
    cbClientTypes: TCheckBox;
    cbCustomDocs: TCheckBox;
    gbClients: TGroupBox;
    cbClients: TCheckBox;
    cbSync: TCheckBox;
    cbUnsync: TCheckBox;
    cbArchive: TCheckBox;
    cbClientFiles: TCheckBox;
    cbStyles: TCheckBox;
    TsProgress: TTabSheet;
    StatusTree: TVirtualStringTree;
    StatusTimer: TTimer;
    tsBrowse: TTabSheet;
    EFromDir: TEdit;
    BBrowse: TButton;
    btnPrev: TButton;
    btnClear: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    imgHeader: TImage;
    Label4: TLabel;
    LBankLink: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    LOptionsImp: TLabel;
    btnDef: TButton;
    pTitle: TPanel;
    LProgressImp: TLabel;
    ilActions: TImageList;
    Cbservers: TComboBox;
    TabSheet1: TTabSheet;
    Panel1: TPanel;
    LStatsImp: TLabel;
    VirtualStringTree1: TVirtualStringTree;
    LVersion: TLabel;
    btnSQLBrowse: TButton;
    cbSysTrans: TCheckBox;
    LPractice: TLabel;
    cbDocuments: TCheckBox;
    procedure BBrowseClick(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure StatusTimerTimer(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure CbserversSelect(Sender: TObject);
    procedure btnSQLBrowseClick(Sender: TObject);
    procedure cbUnsyncClick(Sender: TObject);
    procedure cbUsersClick(Sender: TObject);
    procedure cbArchiveClick(Sender: TObject);
    procedure btnDefClick(Sender: TObject);
    procedure CbserversDropDown(Sender: TObject);
    procedure cbSysTransClick(Sender: TObject);
    procedure cbClientsClick(Sender: TObject);
    procedure cbDocumentsClick(Sender: TObject);

     procedure WMPOWERBROADCAST(var Msg: Tmessage ); message WM_POWERBROADCAST;
  private
    Fprogress: Tprogress;

    FPW: string;
    FUser: string;
    FTreeList: TMigrateList;
    FClientMigrater: TClientMigrater;
    FSystemMigrater: TSystemMigrater;
    FLogMigrater: TLogMigrater;
    FPreLoaded: Boolean;
    FLogFileName: string;
    FPracticeCode: string;
    procedure SetFromDir(const Value: string);
    function GetFromDir: string;
    procedure Setprogress(const Value: Tprogress);
    function NewAction(const Title: string; ActionObject: Tguidobject = nil): TMigrateAction;
    // Test The source
    function TestSystem: Boolean;
    // Destination
    function Connect(ForAction: TMigrateAction; connection:TADOConnection; ASource,ACatalog,AUser,APW: string):Boolean;
    function ConnectSystem(ForAction: TMigrateAction): Boolean;
    function ConnectClient(ForAction: TMigrateAction): Boolean;
    function ConnectLog(ForAction: TMigrateAction): Boolean;
    procedure Disconnect(ForAction: TMigrateAction; connection:TADOConnection; ACatalog: string);
    procedure DoDisconnects(ForAction: TMigrateAction);
    function ClearPracticeLogs(ForAction: TMigrateAction): Boolean;

    // Connection properies
    procedure SetPW(const Value: string);
    procedure SetDestination(const Value: string);
    procedure SetUser(const Value: string);

    procedure MigrateSystem;
    function GetDestination: string;
    procedure SetPreLoaded(const Value: Boolean);

    procedure LogMessage(const msgType: TLogMsgType;  const logMsg: string);
    procedure SetLogFileName(const Value: string);
    procedure SetPracticeCode(const Value: string);

    { Private declarations }
  protected
    procedure UpdateActions; override;

  public
    property PreLoaded: Boolean read FPreLoaded write SetPreLoaded;
    property FromDir: string read GetFromDir write SetFromDir;
    property progress: Tprogress read Fprogress write Setprogress;
    property Destination: string read GetDestination write SetDestination;
    property PracticeCode: string read FPracticeCode write SetPracticeCode;
    property LogFileName: string read FLogFileName write SetLogFileName;
    property User: string read FUser write SetUser;
    property PW: string read FPW write SetPW;
    { Public declarations }
  end;

var
  formMain: TformMain;

implementation

uses
EnterPwdDlg,
Migraters,
ErrorLog,
Progress,
Upgrade,
ReportTypes,
CustomDocEditorFrm,
GlobalDirectories,
AvailableSQLServers,
ErrorMorefrm,
YesNoDlg,
PasswordHash,
bkConst,
BUDOBJ32,
MemorisationsObj,
PayeeObj,
math,
GLConst,
Software,
sysObj32,
baObj32,
admin32,
Archutil32,
WinUtils,
Globals,
FromBrowseForm,
clobj32,
bkDefs,
files,
SQLHelpers,
bthelpers,
bkHelpers,
syhelpers
,LogUtil
;

{$R *.dfm}


type
  TSystemCritical = class
  private
    FIsCritical: Boolean;
    procedure SetIsCritical(const Value: Boolean) ;
  protected
    procedure UpdateCritical(Value: Boolean) ; virtual;
  public
    constructor Create;
    property IsCritical: Boolean read FIsCritical write SetIsCritical;
  end;


var
  SystemCritical: TSystemCritical;


const
   PracticeUser = 'Practice';
   PracticePw = 'Pr4ct1C#U$er';

procedure TformMain.Setprogress(const Value: Tprogress);
begin
  fprogress := Value;
  case fprogress of
   SelectSource : begin
        btnDef.Visible := False;
        btnPrev.Enabled := False;
        btnNext.Enabled := True;
        btnNext.Caption := 'Next';
        btnCancel.Caption := 'Cancel';
        pcMain.ActivePage := tsBrowse;
        tsBrowse.Update;
      end;
   Selection :begin
        btnDef.Visible := True;
        btnPrev.Enabled := True;
        btnNext.Enabled := True;
        btnNext.Caption := 'Next';
        btnCancel.Caption := 'Cancel';

        pcMain.ActivePage := tsSelect;

        LOptionsImp.Caption := Format('Please select what you would like to import to %s',[Destination]);
        LProgressImp.Caption := Format('Execute import %s into %s',[AdminSystem.fdFields.fdBankLink_Code, Destination]);
        LStatsImp.Caption := Format('Import %s into %s Statistics',[AdminSystem.fdFields.fdBankLink_Code, Destination]);

        tsSelect.Update;
     end;
   Migrate :begin
        btnDef.Visible := False;
        btnPrev.Enabled := False;
        btnNext.Enabled := False;
        btnNext.Caption := 'Next';
        btnCancel.Caption := 'Cancel';
        pcMain.ActivePage := TsProgress;
        TsProgress.Update;
     end;
   Done: begin
        btnDef.Visible := False;
        btnPrev.Enabled := True;
        btnNext.Enabled := True;
        btnNext.Caption := 'Finished';
        btnCancel.Caption := 'OK';
   end;
  end;
  pcMain.Update;
  self.update;
  
  Application.ProcessMessages;
  
end;


procedure TformMain.BBrowseClick(Sender: TObject);
begin
   FromDir := FromBrowseForm.GetFromDir;
   if (FromDir > '')
   and (Destination > '')then
      TestSystem;

end;

procedure TformMain.BtnNextClick(Sender: TObject);
begin
   case fprogress of
   SelectSource : TestSystem;


   Selection : MigrateSystem;
   Migrate :; // has no meaning..
   Done: Close;
  end;
end;

procedure TformMain.btnPrevClick(Sender: TObject);
begin
  case progress of
    SelectSource: ;
    Selection: progress := SelectSource;
    Migrate: ;
    Done: Progress := SelectSource;
  end;
end;

procedure TformMain.btnSQLBrowseClick(Sender: TObject);
begin
  cbServers.Enabled := true;
  ListAvailableSQLServers(cbservers.Items);
  cbServers.DroppedDown := true;
end;

procedure TformMain.cbArchiveClick(Sender: TObject);
begin
   FSystemMigrater.DoArchived := cbArchive.Checked;
end;

procedure TformMain.cbClientsClick(Sender: TObject);
begin
   FSystemMigrater.DoClients := cbClients.Checked;
end;

procedure TformMain.cbDocumentsClick(Sender: TObject);
begin
   FSystemMigrater.DoDocuments := cbDocuments.Checked;
end;

procedure TformMain.BtnCancelClick(Sender: TObject);
begin
  case Progress of
  SelectSource : Close;
  Selection : Close;
  Migrate : begin
        if AskYesNo('Are You Sure',
                  'Canceling in the middle of the import, will leave the data incomplete',
                  DLG_No,
                  0,
                  False) = DLG_No then
            exit;
         // Ok then .. Lets cancel..
         SetMigrationCanceled;
     end;
  Done :   Close;
  end;
end;

procedure TformMain.btnClearClick(Sender: TObject);
var Action: TMigrateAction;
begin
   FTreeList.Clear;
   FTreeList.Tree.Clear;
   progress := Migrate;
   Action := NewAction('Clear All');
   try
     if ConnectSystem(Action) then begin
        FSystemMigrater.ClearData(Action)
     end else
        Action.Error := format('Could not connect to [%s]',[Destination]);

     if ConnectClient(Action) then begin
        FClientMigrater.ClearData(Action);
     end else
         Action.Error := format('Could not connect to [%s]',[Destination]);

     if ConnectLog(Action) then begin
        FLogMigrater.ClearData(Action);
     end else
         Action.Error := format('Could not connect to [%s]',[Destination]);

     // this can only be looged after the fact...
     logger.LogMessage(Audit,'All data cleared By user');
     //ClearPracticeLogs(Action);
     // Cleanup
   finally
     DoDisconnects(Action);
   end;
   Action.Status := Success;
   progress := Done;
end;


procedure TformMain.btnDefClick(Sender: TObject);
begin
  cbUsers.Checked := cbUsers.Enabled;
  cbArchive.Checked := cbArchive.Enabled;
  cbClients.Checked := cbClients.Enabled;
  cbDocuments.Checked := cbDocuments.Enabled;
  cbUnsync.Checked := false;
end;

procedure TformMain.CbserversDropDown(Sender: TObject);
begin
   if cbservers.Items.Count <=1 then
      ListAvailableSQLServers(cbservers.Items);
end;

procedure TformMain.CbserversSelect(Sender: TObject);
begin
   Destination := CBServers.text;
end;

procedure TformMain.cbSysTransClick(Sender: TObject);
begin
  FSystemMigrater.DoSystemTransactions := cbSysTrans.Checked;
end;

procedure TformMain.cbUnsyncClick(Sender: TObject);
begin
   FSystemMigrater.DoUnsynchronised := cbUnsync.Checked;
end;

procedure TformMain.cbUsersClick(Sender: TObject);
begin
    FSystemMigrater.DoUsers := cbUsers.Checked;
end;

function TformMain.ClearPracticeLogs(ForAction: TMigrateAction): Boolean;
var Con : TADOConnection;
    MyAction,ClearAction : TMigrateAction;
    CallStack: TStringList;
begin
   Con := TADOConnection.Create(nil);
   Con.LoginPrompt := false;
   Con.Provider := 'SQLNCLI10.1';
   Con.CommandTimeout := 120;
   MyAction := ForAction.InsertAction('Clear Logs');
   try
     if Connect(MyAction, Con, Destination, 'PracticeLog', User, Pw) then begin

        ClearAction := MyAction.InsertAction('Clearing Logs');

//        TMigrater.RunSQL(con,ClearAction,

//     'IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N''[dbo].[FK_CategoryLog_Log]'') AND parent_object_id = OBJECT_ID(N''[dbo].[CategoryLogs]'')) ALTER TABLE [dbo].[CategoryLogs] DROP CONSTRAINT [FK_CategoryLog_Log]'
//                 ,'Drop foreign keys' );
       // TMigrater.RunSQL(con,ClearAction,'Delete categorylogs', 'Delete categorylogs');

        TMigrater.RunSQL(con,ClearAction,'Delete logs', 'Delete Logs');

//        TMigrater.RunSQL(con,ClearAction,'ALTER TABLE [dbo].[CategoryLogs]  WITH CHECK ADD  CONSTRAINT [FK_CategoryLog_Log] FOREIGN KEY([LogID]) REFERENCES [dbo].[Logs] ([LogID])'
//        , 'Add foreign keys');

//        TMigrater.RunSQL(con,ClearAction,'ALTER TABLE [dbo].[CategoryLogs] CHECK CONSTRAINT [FK_CategoryLog_Log]'
//        ,'Check Constraints');

        TMigrater.RunSQL(con,ClearAction,'DBCC SHRINKFILE(''PracticeLog_Log'',1)', 'Shrink log');
        ClearAction.Status := Success;

        disconnect(MyAction,con,'PracticeLog');
        MyAction.Status := Success;
     end;
   except
     on E : Exception do
        logger.LogMessage(Warning, 'ClearPracticeLogs - ' + MyAction.Title + ', ' +
                    Con.ConnectionString + ', ' + Destination + ', ' + User + ', ' + Pw);

   end;
   FreeAndNil(Con);
end;

function TformMain.Connect(ForAction: TMigrateAction; connection: TADOConnection; ASource, ACatalog, AUser,
  APW: string): Boolean;
var ConnStr:TStringList;
    MyAction: TMigrateAction;
    function BuildConnStr: string;
    var I: Integer;
    begin
      Result := ConnStr[0];
      for I := 1 to ConnStr.Count - 1 do
         result := result + ';' + ConnStr[I]
    end;

begin
   Result := false;
   Connection.Connected := False;
   if ASource = '' then
      Exit;
   MyAction := ForAction.InsertAction(format('Connecting %s',[ACatalog]));

   ConnStr := TStringList.Create;
   try
      Connstr.add('Provide=SQLNCLI10.1');
      //Connstr.add('Initial File Name=""');
      //Connstr.add('Server SPN=""');
      //Connstr.add('Persist Security Info=False');
      Connstr.add(format('Initial Catalog=%s',[ACatalog]));
      Connstr.add(format('Data Source=%s',[ASource]));
      //Connstr.add('Use Procedure for Prepare=1');
     //Connstr.add('Use Encryption for Data=True');

      if (AUser = '')
      and (APW = '') then begin
         Connstr.add('Integrated Security=SSPI');
         Connstr.add('User ID=""');
         Connstr.add('Password=""');
      end else begin
         //Connstr.add('Integrated Security=""');
         Connstr.add(format('User ID=%s',[AUser]));
         Connstr.add(format('Password=%s',[APW]));
      end;

      Connection.ConnectionString := BuildConnStr;

      Connection.Connected := true;
      try
         //TMigrater.RunSQL(Connection,MyAction,'DBCC TRACEON (610)', 'Trace on');
         TMigrater.RunSQL(Connection,MyAction,Format('DBCC SHRINKFILE(''%s_Log'',1)',[ACatalog]), 'Shrink Log');
         TMigrater.RunSQL(Connection,MyAction,format('ALTER DATABASE [%s] SET SINGLE_USER WITH ROLLBACK IMMEDIATE',[ACatalog]),'Single user');

         MyAction.Status := Success;
      except
          on e: exception do
             MyAction.Exception(E);
      end;


      Result := Connection.Connected;
   finally
      ConnStr.Free;
   end;
end;

function TformMain.ConnectClient(ForAction: TMigrateAction): Boolean;
begin
   Result := false;
   try
      Result := Connect(ForAction, FClientMigrater.Connection, Destination, 'PracticeClient', User, Pw);
   except
      on e: exception do
         ForAction.Exception(e,'Connect to Client Database');
   end;
end;

function TformMain.ConnectLog(ForAction: TMigrateAction): Boolean;
begin
   Result := false;
   try
      Result := Connect(ForAction, FLogMigrater.Connection, Destination, 'PracticeLog', User, Pw);
   except
      on e: exception do
         ForAction.Exception(e,'Connect to Log Database')
   end;
end;

function TformMain.ConnectSystem(ForAction: TMigrateAction): Boolean;
begin
   Result := false;
   try
      Result := Connect(ForAction, FSystemMigrater.Connection, Destination, 'PracticeSystem', User, Pw);
   except
      on e: exception do
         ForAction.Exception(e,'Connect to Practice Database')
   end;
end;



procedure TformMain.Disconnect(ForAction: TMigrateAction; connection: TADOConnection; ACatalog: string);
var MyAction :TMigrateAction;
begin
   if not assigned(connection) then
      exit;
   if connection.Connected then begin
      try
         MyAction := ForAction.InsertAction(Format('Disconnect %s',[ACatalog]));
         //TMigrater.RunSQL(connection,MyAction,'DBCC TRACEOFF (610)', 'Trace Off');
         TMigrater.RunSQL(connection,MyAction,Format('DBCC SHRINKFILE(''%s_Log'',1)',[ACatalog]), 'Shrink log' );
         TMigrater.RunSQL(connection,MyAction,format('ALTER DATABASE [%s] SET MULTI_USER WITH ROLLBACK IMMEDIATE',[ACatalog]),'Multi User');
         MyAction.Status := Success;
      except
             // Had a Go..
      end;
      connection.Connected := false;
   end;
end;

procedure TformMain.DoDisconnects(ForAction: TMigrateAction);
begin
  if Assigned(FSystemMigrater) then
     Disconnect(ForAction,FSystemMigrater.Connection,'PracticeSystem');
  if Assigned(FClientMigrater) then
     Disconnect(ForAction,FClientMigrater.Connection,'PracticeClient');
  if Assigned(FLogMigrater) then
     Disconnect(ForAction,FLogMigrater.Connection,'PracticeLog');
end;

procedure TformMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;
  case Progress of

  Migrate : begin
        if AskYesNo('Are You Sure',
                  'Closing in the middle of the import, will leave the data incomplete',
                  DLG_No,
                  0,
                  False) <> DLG_No then begin
                      SetMigrationCanceled;
                      Exit;
                  end;


         CanClose := false;
     end;
  end;
end;




procedure TformMain.FormCreate(Sender: TObject);
var I: Integer;
begin
   logger.logMessageProc := self.LogMessage;
   // Create the Global List...
   FTreeList := TMigrateList.Create(StatusTree);
   FTreeList.HookUp;
   FClientMigrater := TClientMigrater.Create('');
   FSystemMigrater := TSystemMigrater.Create();
   FLogMigrater := TLogMigrater.Create();

   FClientMigrater.SystemMirater := FSystemMigrater;

   lVersion.Caption := format('Version %s',[VersionInfo.FileVersion]);

   for I := 0 to pcmain.PageCount - 1 do
      pcmain.Pages[I].TabVisible := False;



end;

procedure TformMain.FormDestroy(Sender: TObject);
begin

   FreeAndnil(FTreeList);
   FreeAndnil(FClientMigrater);
   FreeAndNil(FSystemMigrater);
   FreeAndNil(FLogMigrater);

   FreeAndNil(AdminSystem);
end;

procedure TformMain.FormResize(Sender: TObject);
var B : Integer;
begin
   B := PTop.Width - imgHeader.Width;
   if B > 2  then
      B := B div 2
   else
      B := 0;

   imgHeader.Left := B;
   LVersion.Left := B + 597;
end;

procedure TformMain.FormShow(Sender: TObject);
const
  //UserSwitch = '/USER=';
  PracticeSwitch = 'PRACTICE=';
  LocationSwitch = 'LOCATION=';
  LogFileSwitch  = 'ACTIONLOG=';
  //pwSwitch = '/PW=';
var I: Integer;
    s: string;
    kc: TCursor;
begin
   kc := screen.Cursor;
   Screen.Cursor := crHourGlass;
   try
      show;
      PW := '';
      User := '';
      // setup what we know..
      for i := 1 to ParamCount do begin
         s := Uppercase( ParamStr(i));
         if Pos(PracticeSwitch, S) > 0 then begin
            //Practice Code specified
            PracticeCode := Copy( S, Pos( PracticeSwitch, S) + Length(PracticeSwitch), 20);
         end else if Pos( LocationSwitch, S) > 0 then begin
            //location specified
            Destination := Copy( S, Pos( LocationSwitch, S) + Length(LocationSwitch), 255);
            {}
            User := PracticeUser;
            PW := PracticePw;
            {}
         end else if Pos(LogFileSwitch, S) > 0 then begin
            logFileName := Copy( S, Pos( LogFileSwitch, S) + Length(LogFileSwitch), 255);
         end;

      end;
      {
      if (PW = '')
      and (User = '') then begin
         User := PracticeUser;
         PW := PracticePw;
      end;
      {}
      PreLoaded := Destination > '';
      fromDir := '';

      progress := SelectSource;
   finally
      screen.Cursor := kc
   end;
end;


function TformMain.GetDestination: string;
begin
   Result := Cbservers.Text;
end;

function TformMain.GetFromDir: string;
begin
   Result := Globals.DataDir;
end;

procedure TformMain.LogMessage(const msgType: TLogMsgType;  const logMsg: string);
begin
   LogData.StampTime;
   try
      // Are we connected ??
      if FLogMigrater.Connected then
         FLogMigrater.UserActionLogTable.Insert(msgType, logMsg);
   except
   end;

   try
      case msgtype of
         Audit: logUtil.LogMsg(lmInfo,'Migrator',logMsg);
         Info: logUtil.LogMsg(lmDebug,'Migrator',logMsg);
         Warning: logUtil.LogMsg(lmError,'Migrator',logMsg);
      end;
   except
   end;

   try
      LogData.LogToFile(msgType, logMsg);
   except
   end;
end;

function TformMain.NewAction(const Title: string;
  ActionObject: Tguidobject): TMigrateAction;
begin
   Result := TMigrateAction.Create(Title, ActionObject);
   FTreeList.AddNodeItem(StatusTree.RootNode ,Result);
end;


procedure TformMain.SetFromDir(const Value: string);
begin
  Globals.DataDir := Value;

  SysLog.LogPath            := Globals.DataDir;
  DownloadWorkDir           := DataDir + 'WORK\';
  DownloadOffsiteWorkDir    := DataDir + 'OffSiteWORK\';
  DownloadArchiveDir        := DataDir + 'ARCHIVE\';
  EmailOutboxDir            := DataDir + 'OUTBOX\';
  Templatedir               := DataDir + 'TEMPLATE\';
  LogFileBackupDir          := DataDir + 'OLDLOGS\';
  CSVExportDefaultDir       := DataDir + 'EXPORT\';
  UsageDir                  := DataDir + 'USAGE\';
  StyleDir                  := DataDir + 'STYLES\';
  GlobalDirectories.glDataDir :=  Globals.DataDir;
  ExecDir := DataDir;

  EFromDir.Text := Value;
end;


procedure TformMain.SetLogFileName(const Value: string);
begin
  FLogFileName := Value;
  // While we are here...
   LogData.LogFileName := Value;
end;

procedure TformMain.SetPracticeCode(const Value: string);
begin
  FPracticeCode := Value;
end;

procedure TformMain.SetPreLoaded(const Value: Boolean);
{var
   I: Integer;
   Databases : TStringList;}
begin
  FPreLoaded := Value;

  btnClear.Visible := not FPreLoaded;
  cbservers.Enabled := not FPreLoaded;
  btnSQLBrowse.Visible := not FPreLoaded;

  if not FPreLoaded then begin

     (*Databases := TStringList.Create;
       Good plan but takes far too long...
     try

     // Now Test the locations...
     I := 0;
     while I < CBServers.Items.Count do begin
        DatabasesOnServer(cbservers.Items[I], PracticeUser, PracticePW, Databases);
        if Databases.IndexOf( 'PracticeSystem') < 0 then
            cbservers.Items.Delete(I)
        else
           inc(I)

     end;
     finally
         FreeAndnil(Databases);
     end;
     *)
  end;
end;

procedure TformMain.SetPW(const Value: string);
begin
  FPW := Value;
end;

procedure TformMain.SetDestination(const Value: string);
begin
  Cbservers.Text := Value;
end;

procedure TformMain.SetUser(const Value: string);
begin
  FUser := Value;
end;
    procedure TformMain.StatusTimerTimer(Sender: TObject);
begin
   Statustime := Now;
end;


function TformMain.TestSystem: boolean;
   var I : Integer;
       SysAccounts,
       TypeCount,
       userProfiles,
       GroupCount,
       Clientfiles,
       ArchiveCount,
       ForeignCount: integer;
       kc: Tcursor;


  function SetCheckBox(Value: TCheckBox; Caption: string; Count: Double; Disable: boolean = false; unticked: boolean = false): boolean;
  var CountText: string;
  begin
     Result := Count > 0 ;
     if Result then begin
        Value.Checked := not unticked;
        Value.Enabled := not Disable;
        CountText := format('(%.0n) ',[count]);
     end else begin
        Value.Checked := false;
        Value.Enabled := false;
        CountText := '';
     end;
     Value.Caption := format(Caption,[CountText]);
     if Assigned(Value.OnClick) then
        Value.OnClick(value);
  end;

  procedure getStyles;
  var ll : TStringList;
  begin
     ll := TStringList.Create;
      try
         FillStyleList(ll);
          SetCheckBox(cbStyles,'Styles %s',ll.Count);
      finally
        ll.Free
      end;
  end;


  procedure GetWorkFiles;
  var ll : TStringList;
  begin
     ll := FSystemMigrater.GetWorkFileList;
     try
        SetCheckBox(cbDocuments,'Invoices and Charges %s',ll.Count);
     finally
        ll.Free
     end;
  end;


begin
   Result := false;
   FreeAndnil(AdminSystem);

   if FromDir = '' then begin
      HelpfulErrorMsg('Please select a BankLink Practice 5 database location ',0 ,false);
      if EFromDir.CanFocus then
         EFromDir.SetFocus;
      Exit;
   end;

   if Destination = '' then begin
      HelpfulErrorMsg('Please select a destination',0 ,false);
      if cbservers.CanFocus then
         cbservers.SetFocus;
      Exit;
   end;

   if not BKFileExists(DATADIR + SYSFILENAME) then begin
      HelpfulErrorMsg(format('Could not open %s'#13'Please select a valid location',[DATADIR + SYSFILENAME]), 0,false);
      if EFromDir.CanFocus then
         EFromDir.SetFocus;
      Exit;
   end;

   kc := Screen.Cursor;
   Screen.Cursor := crHourGlass;
   try
      ArchiveCount := 0;
      ForeignCount := 0;
      SysAccounts := 0;
      ClientFiles := 0;
      TypeCount := 0;
      GroupCount := 0;
      userProfiles := 0;
      try
         //LoadAdminSystem(false,'Migrator');
         AdminSystem := TSystemObj.Create;
         AdminSystem.Open;
         UpgradeAdminToLatestVersion;

         ClientFiles := Adminsystem.fdSystem_Client_File_List.ItemCount;
         SysAccounts := Adminsystem.fdSystem_Bank_Account_List.ItemCount;
         TypeCount :=  Adminsystem.fdSystem_Client_Type_List.ItemCount;
         GroupCount := Adminsystem.fdSystem_Group_List.ItemCount;
         userProfiles := Adminsystem.fdSystem_User_List.ItemCount;


         FSystemMigrater.System := AdminSystem;
         Result := true;

         except
            on e: Exception do begin
               HelpfulErrorMsg(format('Could not open %s'#13'Please select a valid location',[DATADIR + SYSFILENAME]), 0,false);
               FreeAndnil(AdminSystem);
               Exit;
            end;

         end;

         LPractice.Caption := Format('%s: %s',[Adminsystem.fdFields.fdBankLink_Code, Adminsystem.fdFields.fdPractice_Name_for_Reports]);

         if SetCheckBox(cbAccounts,'System Accounts %s,',SysAccounts, true) then begin
             SysAccounts := FSystemMigrater.SystemAccountList.TotSize div sizeof(tArchived_Transaction);
             SetCheckBox(cbSysTrans,'&&Transactions %s',SysAccounts,false);
         end;

         cbSysTransClick(nil);

         if SetCheckBox(cbClients,'Client Files %s',ClientFiles) then begin
             for I := 0 to ClientFiles - 1 do
                with Adminsystem.fdSystem_Client_File_List.Client_File_At(I)^ do begin
                   if cfForeign_File then
                      inc(ForeignCount);
                   if cfArchived then
                      inc(ArchiveCount);
                end;
             cbClientFiles.Checked := true;
         end else
            cbClientFiles.Checked := false;


         SetCheckBox(CBSync,'Synchronised %s',ClientFiles - (ForeignCount + ArchiveCount), True);
         SetCheckBox(cbUnsync,'Unynchronised %s',ForeignCount, false, true);
         SetCheckBox(CBArchive,'Archived %s',ArchiveCount, false, true);

         SetCheckBox(cbusers,'User Profiles %s',UserProfiles);
         SetCheckBox(cbGroups,'Client Groups %s',GroupCount);
         SetCheckBox(cbClientTypes,'Client Types %s',TypeCount);

         SetCheckBox(cbCustomDocs,'Custom documents %s',CustomDocManager.ReportList.Count);

         GetStyles;

         GetWorkFiles;

   finally
      Screen.Cursor := kc;
   end;

   if Result then begin
      Progress := Selection;
   end;

end;

procedure TformMain.UpdateActions;
begin
  inherited;
  case Progress of
    SelectSource: begin
          btnClear.Enabled := Destination > '';
          btnSQLBrowse.Enabled := cbServers.Items.Count <= 1;
       end;
    Selection: begin
          btnDef.Enabled := not (    (cbUsers.Checked = cbUsers.Enabled)
                                 and (cbArchive.Checked = cbArchive.Enabled)
                                 and (not cbUnsync.Checked ));
       end;
    Migrate: ;
    Done: ;
  end;
end;

procedure TformMain.WMPOWERBROADCAST(var Msg: Tmessage);
begin // This won't work after vista...
   if msg.wParam = PBT_APMQUERYSUSPEND then
     msg.Result :=  BROADCAST_QUERY_DENY
end;

procedure TformMain.MigrateSystem;
 var Myaction : TMigrateAction;

   function YesNo(Value: TCheckBox): string;
   begin
      if Value.Enabled then
         if Value.Checked then
            Result := 'Yes'
         else
            Result := 'No'
      else
         Result := 'NA (None)'
   end;
begin
   ClearMigrationCanceled;
   FTreeList.Clear;
   FTreeList.Tree.Clear;

   logger.LogMessage(Audit,'Migration Started by User'
      + format ('; Include System transactions: %s', [YesNo(cbSysTrans)])
      + format ('; Include Unsynchronised clients: %s', [YesNo(cbUnsync)])
      + format ('; Include Archived clients: %s', [YesNo(cbUnsync)])
      + format ('; Include User profiles: %s', [YesNo(cbUsers)])
      + format ('; Include Client Groups: %s', [YesNo(cbGroups)])
      + format ('; Include Client Types: %s', [YesNo(cbClientTypes)])
      + format ('; Include Custom Documents: %s', [YesNo(cbCustomDocs)])
      + format ('; Include Styles: %s', [YesNo(cbStyles)])
      + format ('; Include Invoices and Charges: %s', [YesNo(cbDocuments)])

      );

 {$ifDef DEBUG}
 {$Else}

  if not EnterPassword('Migrate Data',TimeToStr(Now) + 'Migrate'  ,0, true, false) then begin
     logger.LogMessage(Audit,'Migration Password failed');
     Exit;
  end;
 {$EndIf}


   Myaction := NewAction('Migrate');
   progress := migrate;
   SystemCritical.IsCritical := true;
   try
      if ConnectLog(MyAction)
      and ConnectSystem(MyAction)
      and ConnectClient(MyAction) then begin

         Logger.LogMessage(info,'Clearing Practice System Database');

         FSystemMigrater.ClearData(MyAction);

         Logger.LogMessage(Info,'Clearing Practice Client database');
         FClientMigrater.ClearData(MyAction);
         //FlogMigrater.ClearData(MyAction); // Dont Clear Log...
               
         FSystemMigrater.ClientMigrater := FClientMigrater;
         //FSystemMigrater.System := Adminsystem; already done ??

         {}
         FSystemMigrater.Migrate(MyAction);
         {}
         
         DoDisconnects(MyAction);
         MyAction.Status := Success;

      end else
          MyAction.Status := failed;
   finally
      progress := Done;
      SystemCritical.IsCritical := false;
      DoDisconnects(MyAction);
   end;

end;


 
type

   EXECUTION_STATE = DWORD;
const
  ES_SYSTEM_REQUIRED = $00000001;
  ES_DISPLAY_REQUIRED = $00000002;
  ES_USER_PRESENT = $00000004;
  ES_AWAYMODE_REQUIRED = $00000040;
  ES_CONTINUOUS = $80000000;
  KernelDLL = 'kernel32.dll';



  (*
    SetThreadExecutionState Function

   Enables an application to inform the system that it is in use,
   thereby preventing the system from entering sleep or turning off the display while the application is running.
  *)

procedure SetThreadExecutionState(ESFlags: EXECUTION_STATE) ; stdcall; external kernel32 name 'SetThreadExecutionState';

constructor TSystemCritical.Create;
begin
  inherited;
  FIsCritical := False;
end;

procedure TSystemCritical.SetIsCritical(const Value: Boolean) ;
begin
  if FIsCritical = Value then Exit;

  FIsCritical := Value;
  UpdateCritical(FIsCritical);
end;

procedure TSystemCritical.UpdateCritical(Value: Boolean) ;
begin
  if Value then //Prevent the sleep idle time-out and Power off.
    SetThreadExecutionState(ES_SYSTEM_REQUIRED or ES_CONTINUOUS)
  else //Clear EXECUTION_STATE flags to disable away mode and allow the system to idle to sleep normally.
    SetThreadExecutionState(ES_CONTINUOUS) ;
end;




initialization
   Progress.OnUpdateMessageBar := nil;
   SystemCritical := TSystemCritical.Create;

finalization
   SystemCritical.IsCritical := False;
   SystemCritical.Free;
end.

