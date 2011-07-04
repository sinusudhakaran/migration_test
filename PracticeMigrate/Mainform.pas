unit Mainform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, DB, ADODB, GuidList, sydefs, VirtualTreeHandler,
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

  private
    Fprogress: Tprogress;

    FPW: string;
    FUser: string;
    FTreeList: TMigrateList;
    FClientMigrater: TClientMigrater;
    FSystemMigrater: TSystemMigrater;
    FPreLoaded: Boolean;
    procedure SetFromDir(const Value: string);
    function GetFromDir: string;
    procedure Setprogress(const Value: Tprogress);
    function NewAction(const Title: string; ActionObject: Tguidobject = nil): TMigrateAction;
    // Test The source
    function TestSystem: Boolean;
    // Destination
    function Connect(connection:TADOConnection; ASource,ACatalog,AUser,APW: string):Boolean;
    function ConnectSystem(ForAction: TMigrateAction): Boolean;
    function ConnectClient(ForAction: TMigrateAction): Boolean;

    // Connection properies
    procedure SetPW(const Value: string);
    procedure SetDestination(const Value: string);
    procedure SetUser(const Value: string);

    procedure MigrateSystem;
    function GetDestination: string;
    procedure SetPreLoaded(const Value: Boolean);

    { Private declarations }
  protected
    procedure UpdateActions; override;
  public
    property PreLoaded: Boolean read FPreLoaded write SetPreLoaded;
    property FromDir: string read GetFromDir write SetFromDir;
    property progress: Tprogress read Fprogress write Setprogress;
    property Destination: string read GetDestination write SetDestination;
    property User: string read FUser write SetUser;
    property PW: string read FPW write SetPW;
    { Public declarations }
  end;

var
  formMain: TformMain;

implementation

uses
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
syhelpers;

{$R *.dfm}


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

        pcMain.ActivePage := tsBrowse;
        tsBrowse.Update;
      end;
   Selection :begin
        btnDef.Visible := True;
        btnPrev.Enabled := True;
        btnNext.Enabled := True;
        btnNext.Caption := 'Next';

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

        pcMain.ActivePage := TsProgress;
        TsProgress.Update;
     end;
   Done: begin
        btnDef.Visible := False;
        btnPrev.Enabled := True;
        btnNext.Enabled := True;
        btnNext.Caption := 'Finished';

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
     if ConnectSystem(Action) then begin
        FSystemMigrater.ClearData(Action)
     end else
        Action.Error := format('Could not connect to [%s]',[Destination]);

     if ConnectClient(Action) then begin
        FClientMigrater.ClearData(Action);
     end else
         Action.Error := format('Could not connect to [%s]',[Destination]);

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

function TformMain.Connect(connection: TADOConnection; ASource, ACatalog, AUser,
  APW: string): Boolean;
var ConnStr:TStringList;

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

   ConnStr := TStringList.Create;
   try
      Connstr.add('Provide=SQLNCLI10.1');
      //Connstr.add('Initial File Name=""');
      //Connstr.add('Server SPN=""');
      //Connstr.add('Persist Security Info=False');
      Connstr.add(format('Initial Catalog=%s',[ACatalog]));
      Connstr.add(format('Data Source=%s',[ASource]));
      //Connstr.add('Use Procedure for Prepare=1');


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

      Result := Connection.Connected;
   finally
      ConnStr.Free;
   end;
end;

function TformMain.ConnectClient(ForAction: TMigrateAction): Boolean;
begin
   Result := false;
   try
      Result := Connect(FClientMigrater.Connection, Destination, 'PracticeClient', User, Pw);
   except
      on e: exception do
         ForAction.Exception(e,'Connect to Client Database');
   end;
end;

function TformMain.ConnectSystem(ForAction: TMigrateAction): Boolean;
begin
   Result := false;
   try
      Result := Connect(FSystemMigrater.Connection, Destination, 'PracticeSystem', User, Pw);
   except
      on e: exception do
         ForAction.Exception(e,'Connect to Practice Database')
   end;
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
   // Create the Global List...
   FTreeList := TMigrateList.Create(StatusTree);
   FTreeList.HookUp;
   FClientMigrater := TClientMigrater.Create('');
   FSystemMigrater := TSystemMigrater.Create();

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
  PracticeSwitch = '/PRACTICE=';
  LocationSwitch = '/LOCATION=';
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
            s := Copy( S, Pos( PracticeSwitch, S) + Length(PracticeSwitch), 20);
         end else if Pos( LocationSwitch, S) > 0 then begin
            //location specified
            Destination := Copy( S, Pos( LocationSwitch, S) + Length(LocationSwitch), 255);
            {}
            User := PracticeUser;
            PW := PracticePw;
            {}
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

function TformMain.NewAction(const Title: string;
  ActionObject: Tguidobject): TMigrateAction;
begin
   Result := TMigrateAction.Create(Title, ActionObject);
   FTreeList.AddNodeItem(StatusTree.RootNode ,Result);
end;


procedure TformMain.SetFromDir(const Value: string);
begin
  Globals.DataDir := Value;


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

procedure TformMain.MigrateSystem;
 var Myaction : TMigrateAction;
begin
   ClearMigrationCanceled;
   FTreeList.Clear;
   FTreeList.Tree.Clear;
   Myaction := NewAction('Migrate');
   progress := migrate;
   try
      if ConnectSystem(MyAction)
      and ConnectClient(MyAction) then begin

         FSystemMigrater.ClearData(MyAction);
         FClientMigrater.ClearData(MyAction);
               
         FSystemMigrater.ClientMigrater := FClientMigrater;
         //FSystemMigrater.System := Adminsystem; already done ??

         FSystemMigrater.Migrate(MyAction);

         MyAction.Status := Success;

      end else
          MyAction.Status := failed;
   finally
      progress := Done;
   end;

end;

end.
