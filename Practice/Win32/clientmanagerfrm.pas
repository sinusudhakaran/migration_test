unit ClientManagerFrm;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:

   Remarks:

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
  RzGroupBar,
  RzCommon,
  ExtCtrls,
  ClientLookupFme,
  ImgList,
  ActnList,
  StdCtrls,
  Menus,
  OpShared,
  OpWrdXP,
  OpWord,
  jpeg,
  VirtualTrees,
  RzButton,
  Grids,
  RzPanel,
  OSFont,
  ImportProspectsDlg,
  dxGDIPlusClasses,
  Globals,
  BanklinkOnlineSettingsFrm,
  BanklinkOnlineServices,
  BlopiClient;

type
  TfrmClientManager = class(TForm)
    ActionList1: TActionList;
    actNewFile: TAction;
    actOpen: TAction;
    actCheckIn: TAction;
    actCheckOut: TAction;
    actScheduled: TAction;
    actAssignTo: TAction;
    actTasks: TAction;
    actTrackTasks: TAction;
    actClientEmail: TAction;
    actEditClientDetails: TAction;
    tmrUpdateClientDetails: TTimer;
    actCodingScreenLayout: TAction;
    actPracticeContact: TAction;
    actFinancialYear: TAction;
    actDeleteFile: TAction;
    actUnlockFile: TAction;
    pnlMain: TPanel;
    pnlFrameHolder: TPanel;
    popClientManager: TPopupMenu;
    mniRestoreColumns: TMenuItem;
    actHelp: TAction;
    actMergeDoc: TAction;
    actMergeEmail: TAction;
    pnlFilter: TPanel;
    cmbFilter: TComboBox;
    actNewProspect: TAction;
    actImportProspects: TAction;
    actConvertToBK: TAction;
    mniOpen: TMenuItem;
    mniTasks: TMenuItem;
    mniEdit: TMenuItem;
    mniScheduled: TMenuItem;
    mniAssignTo: TMenuItem;
    actDeleteProspect: TAction;
    popHeader: TPopupMenu;
    mniRestoreHeader: TMenuItem;
    popProspects: TPopupMenu;
    mniConvert: TMenuItem;
    mniProspectAssignTo: TMenuItem;
    mniProspectEdit: TMenuItem;
    mniProspectTask: TMenuItem;
    mniProspectRestoreCols: TMenuItem;
    popGlobal: TPopupMenu;
    mniGlobalAssign: TMenuItem;
    mniGlobalEdit: TMenuItem;
    mniGlobalScheduled: TMenuItem;
    ApplyCodingScreenLayout1: TMenuItem;
    AssignPracticeContact1: TMenuItem;
    ChangeFinancialYear1: TMenuItem;
    N1: TMenuItem;
    actCreateDoc: TAction;
    actSend: TAction;
    actCAF: TAction;
    actTPA: TAction;
    actPrint: TAction;
    actShowLegend: TAction;
    pnlLegend: TPanel;
    Label6: TLabel;
    N2: TMenuItem;
    btnFilter: TButton;
    tbtnClose: TRzToolButton;
    sgLegend: TStringGrid;
    N3: TMenuItem;
    mniFilter: TMenuItem;
    mniResetFilter: TMenuItem;
    N4: TMenuItem;
    btnResetFilter: TButton;
    actUpdateProcessing: TAction;
    PnlLogo: TRzPanel;
    imgLogo: TImage;
    imgRight: TImage;
    lblCount: TLabel;
    pnlClose: TPanel;
    btnClose: TButton;
    actArchive: TAction;
    actDataAvailable: TAction;
    actDownload: TAction;
    Action1: TAction;
    actGroup: TAction;
    actClientType: TAction;
    AssignGroup1: TMenuItem;
    AssignClientType1: TMenuItem;
    AssignGroup2: TMenuItem;
    AssignClientType2: TMenuItem;
    gbClientManager: TRzGroupBar;
    rzgFileTasks: TRzGroup;
    rzgProspects: TRzGroup;
    RzGroupGlobal: TRzGroup;
    rzgDetails: TRzGroup;
    rzgCommunicate: TRzGroup;
    rzgOptions: TRzGroup;
    ClientLookup: TfmeClientLookup;
    Archive1: TMenuItem;
    owMerge: TOpWord;
    EBFind: TEdit;
    btnFind: TButton;
    ActShowInstitutions: TAction;
    actNewAccounts: TAction;
    actImportClients: TAction;
    actMultiTasks: TAction;
    actPrintTasks: TAction;
    SearchTimer: TTimer;
    Label1: TLabel;
    actAssignBulkExport: TAction;
    Assignbulkexportformat1: TMenuItem;
    actUnAttached: TAction;
    actInActive: TAction;
    actSendOnline: TAction;
    lblCannotConnect: TLabel;
    imgCannotConnect: TImage;
    actBOSettings: TAction;
    mniEditBOSettings: TMenuItem;
    pnlFilterA: TPanel;
    pnlLegendA: TPanel;
    actICAF: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure SelectionChanged( Sender : TObject);
    procedure ColumnMoved(Sender: TVTHeader; Column: TColumnIndex; OldPosition: Integer);
    procedure actOpenExecute(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure actNewFileExecute(Sender: TObject);

    procedure BeginUpdate;
    procedure EndUpdate;

    procedure RefreshLookup(CodeToSelect : string); overload;

    procedure actCheckInExecute(Sender: TObject);
    procedure actCheckOutExecute(Sender: TObject);
    procedure actAssignToExecute(Sender: TObject);
    procedure actScheduledExecute(Sender: TObject);
    procedure actClientEmailExecute(Sender: TObject);
    procedure actEditClientDetailsExecute(Sender: TObject);
    procedure tmrUpdateClientDetailsTimer(Sender: TObject);
    procedure actTasksExecute(Sender: TObject);
    procedure actCodingScreenLayoutExecute(Sender: TObject);
    procedure actPracticeContactExecute(Sender: TObject);
    procedure actFinancialYearExecute(Sender: TObject);
    procedure actDeleteFileExecute(Sender: TObject);
    procedure actUnlockFileExecute(Sender: TObject);
    procedure actTrackTasksExecute(Sender: TObject);
    procedure FrameDblClick(Sender: TObject);
    procedure FrameNotesClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mniRestoreColumnsClick(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actMergeDocExecute(Sender: TObject);
    procedure actMergeEmailExecute(Sender: TObject);
    procedure actNewProspectExecute(Sender: TObject);
    procedure actImportProspectsExecute(Sender: TObject);
    procedure actConvertToBKExecute(Sender: TObject);
    procedure cmbFilterChange(Sender: TObject);
    procedure actDeleteProspectExecute(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure actCreateDocExecute(Sender: TObject);
    procedure actSendExecute(Sender: TObject);
    procedure actCAFExecute(Sender: TObject);
    procedure actTPAExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure actShowLegendExecute(Sender: TObject);
    procedure btnFilterClick(Sender: TObject);
    procedure sgLegendDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgLegendSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure mniFilterClick(Sender: TObject);
    procedure mniResetFilterClick(Sender: TObject);
    procedure actUpdateProcessingExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure pnlCloseResize(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure actArchiveExecute(Sender: TObject);
    procedure actDataAvailableExecute(Sender: TObject);
    procedure actDownloadExecute(Sender: TObject);
    procedure actGroupExecute(Sender: TObject);
    procedure actClientTypeExecute(Sender: TObject);
    procedure EBFindKeyPress(Sender: TObject; var Key: Char);
    procedure btnFindClick(Sender: TObject);
    procedure ActShowInstitutionsExecute(Sender: TObject);
    procedure actNewAccountsExecute(Sender: TObject);
    procedure actImportClientsExecute(Sender: TObject);
    procedure actMultiTasksExecute(Sender: TObject);
    procedure actPrintTasksExecute(Sender: TObject);
    procedure SearchTimerTimer(Sender: TObject);
    procedure EBFindChange(Sender: TObject);
    procedure actAssignBulkExportExecute(Sender: TObject);
    procedure actInActiveExecute(Sender: TObject);
    procedure actSendOnlineExecute(Sender: TObject);
    procedure actBOSettingsExecute(Sender: TObject);
    procedure ClientLookupvtClientsGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure actICAFExecute(Sender: TObject);

  private

    FScreenLockCount  : integer;
    FMode             : byte;
    FIsGlobal         : Boolean;
    FCurrentUserFilter, FCurrentGroupFilter, FCurrentClientTypeFilter: TStringList;
    FShowLegend       : Boolean;
    StartFocus        : Boolean;
    FUserSet: Boolean;
    InModal: Boolean;
    FBlopiClient: TBlopiClient;
    procedure FillClientDetails;
    procedure ShowSelectedNo( Count : integer);
    procedure UpdateClientDetails(Count: integer);
    procedure UpdateTasksPending;

    procedure ProcessModalCommand(cID : byte);
    procedure DoOpen;
    procedure DoNew;
    procedure DoCheckIn;
    procedure DoSendToFile;
    procedure DoSendViaOnline;
    procedure DoSendViaEmail;
    procedure DoAssignTo;
    procedure DoAssignBulkExport;
    procedure DoAssignGroup;
    procedure DoAssignClientType;
    procedure DoSetupSchedule;
    procedure DoLayout;
    procedure DoArchive;
    procedure DoAssignContact;
    procedure DoChangeFinYear;
    procedure DoMergeDoc;
    procedure DoMergeEMail;
    procedure DoCreateDoc(var LoseFocus: Boolean);
    procedure DoNewProspect;
    procedure DoDeleteProspect;
    procedure DoImportClientsProspects(ImportType: EImportType);
    procedure DoConvertToBK;
//    function GetUserCMStatus: Boolean;
    procedure UpdateFilter(Id: Integer);

    procedure DisableForm;
    procedure EnableForm(LooseFocus: Boolean);
    procedure DoTasks;
    procedure DoEditClientDetails;
    procedure DoDeleteFile;
    procedure DoUnlock;
    procedure AddCustomColumn(aCaption: string;
                              aDefWidth,aDefPos: integer;
                              aFieldID: TClientLookupCol;
                              aProductIndex : integer = -1;
                              aProductGuid  : TBloGuid = '');
    function GetINI_ID(aFieldID: TClientLookupCol): integer;
    procedure UpdateColumnINISettings;
    procedure ResetIniColumnDefaults;
    function GetSelectedEmail: string;
    procedure mniShowHideColumnsClick(Sender: TObject);
    procedure BuildHeaderContextMenu;
    procedure DoNewFilter(ShowForm: Boolean);
    procedure UpdateClientCountLabel(Sender: TObject);
    procedure SetShowLegend(const Value: Boolean);
    procedure SetUserSet(const Value: Boolean);
    procedure UpdateMultiTasks;
    procedure DoMultipleAddTasks;
    procedure UpdatePrintTasks;
    procedure DoPrintAllTasks;
    property ShowLegend : Boolean read FShowLegend write SetShowLegend;
    procedure SetUser;
    { Private declarations }
    procedure wmsyscommand( var msg: TWMSyscommand ); message wm_syscommand;
    procedure UpdateINI;
    procedure vtClientsHeaderMouseUp(Sender: TVTHeader;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CheckBOConnection (var message: TMessage); message BK_PRACTICE_DETAILS_CHANGED;
    procedure CheckBOConnectionLocal;
    function GetBlopiClientNew: TBloClientCreate;
    procedure SetBlopiClientNew(const Value: TBloClientCreate);
  protected
    procedure UpdateActions; override;
  public
    property IsGlobal: Boolean read FIsGlobal write FIsGlobal;
    property UserSet: Boolean read FUserSet write SetUserSet;
    property BlopiClientNew: TBloClientCreate read GetBlopiClientNew write SetBlopiClientNew;
    { Public declarations }
  end;

 TfrmClientMaint = class(TfrmClientManager)
   constructor Create(AOwner: tComponent); override;
 end;

//------------------------------------------------------------------------------
function DoClientManager(L, T, H, W: Integer) : boolean;
procedure CloseClientManager(ProcessMessage: Boolean = True);
function DoGlobalClientSetup(w_PopupParent: TForm; L, T, H, W: Integer) : boolean;
procedure RefreshClientManager(Code: string = ''; restore: Boolean = True);
procedure DisableClientManager;
procedure EnableClientManager;
procedure ClientManagerCheckout;
procedure ClientManagerSendOnline;
procedure ClientManagerSend;
procedure SetDownloadAvailability(Status: Byte);
procedure UpdateClientManagerCaption(Title: string);
function CheckOutEnabled: Boolean;
function SendFilesEnabled: Boolean;

//------------------------------------------------------------------------------
implementation

uses
  MaintainPracBankFrm,
  BulkExtractFrm,
  UpdateMF,
  Admin32,
  ApplicationUtils,
  ClientDetailCacheObj,
  bkconst,
  BKHelp,
  Files,
  GlobalClientSetupRoutines,
  InfoMoreFrm,
  ErrorMoreFrm,
  ImagesFrm,
  ClientManagerOptionsFrm,
  ToDoHandler,
  NewClientWiz,
  AppUserObj,
  MailFrm,
  logutil,
  ModalProcessorDlg,
  syDefs,
  SysObj32,
  clObj32,
  cfList32,
  MailMergeDlg,
  EMailMergeDlg,
  CreateMergeDocDlg, {threadData,}
  ComCtrls,
  UpdateClientDetailsDlg,
  ClientUtils,
  WinUtils,
  ShellAPI,
  stdate,
  bkdateutils,
  BK5Except,
  AuthorityUtils,
  CAFfrm,
  NewCAFfrm,
  rptCAF,
  TPAfrm,
  rptTPA,
  ReportDefs,
  ovcDate,
  rptClientManager,
  CMFilterForm,
  bkBranding,
  ClientHomePageFrm,
  Merge32,
  rptAdmin,
  MainFrm,
  CheckInOutFrm,
  Clipbrd,
  YesNoDlg,
  WebUtils,
  SelectInstitutionfrm,
  ImportCAFfrm;

{$R *.dfm}

const
  cm_mcUnknown            = 0;
  cm_mcOpen               = 1;
  cm_mcNew                = 2;
  cm_mcCheckIn            = 3;
  cm_mcCheckOut           = 4;
  cm_mcAssignTo           = 5;
  cm_mcSetupSchedule      = 6;
  cm_mcLoadLayout         = 7;
  cm_mcAssignContact      = 8;
  cm_mcChangeFinYear      = 9;
  cm_mcTasks              = 10;
  cm_mcEditClientDetails  = 11;
  cm_mcDeleteFile         = 12;
  cm_mcUnlockFile         = 13;
  cm_mcMergeDoc           = 14;
  cm_mcMergeEMail         = 15;
  cm_mcNewProspect        = 16;
  cm_mcImportProspects    = 17;
  cm_mcConvertToBK        = 18;
  cm_mcDeleteProspect     = 19;
  cm_mcCreateMergeDoc     = 20;
  cm_mcSend               = 21;
  cm_mcArchive            = 22;
  cm_mcAssignGroup        = 23;
  cm_mcAssignClientType   = 24;
  cm_mcImportClients      = 25;
  cm_mcAddMultipleTasks   = 26;
  cm_mcPrintAllTasks      = 27;
  cm_mcAssignBulkExport   = 28;
  cm_mcSendOnline         = 29;

  md_ClientManager   = 0;
  md_GlobalSetup     = 1;

  UnitName = 'CLIENTMANAGER';

  // Mail merge word document
  OfficeFialed = '"MS Office" options not installed, not available or encountered a problem';

var
  GLClientManager: TfrmClientManager;
  DebugMe : boolean = false;
  GlfrmClientManagerUp : Boolean;

//------------------------------------------------------------------------------
procedure TfrmClientManager.FormActivate(Sender: TObject);
   procedure UpdateActions(CanDo: Boolean);
      procedure SetAction(Value: tAction; Count: Integer; Caption: string);
      begin
         if Count > 0 then begin
            if Count = 1 then
                Value.Caption := Format('There is 1 %s Account',[Caption])
            else
               Value.Caption := Format('There are %d %s Accounts',[Count,Caption]);
            Value.Visible := True;
         end else
            Value.Visible := False;
            // Dont Worry about the caption..
      end;
   begin
      if CanDo then begin
         SetAction(actNewAccounts,AdminSystem.fdSystem_Bank_Account_List.NewAccountsCount,'New');
         SetAction(actInActive,AdminSystem.fdSystem_Bank_Account_List.InactiveAccounts,'Inactive');
         SetAction(actunAttached,AdminSystem.fdSystem_Bank_Account_List.UnAttachedAccounts,'Unattached');
      end else begin
         actNewAccounts.Visible := False;
         actInActive.Visible := False;
         actunAttached.Visible := False;
      end;
   end;
begin
  try
     RefreshLookup(''); //Do This first, gets a Admin Snapshot.
     UpdateActions(Assigned(AdminSystem)
                   and Assigned(CurrUser)
                   and CurrUser.CanAccessAdmin);

  except
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if FisGlobal then
  begin
    // update client manager
    if frmMain.ActiveMDIChild is TfrmClientManager then
      RefreshClientManager;
  end
  else
  begin
    Action := caNone;
    frmMain.Close;

  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.FormCreate(Sender: TObject);

begin
  //check max columns
  GBClientmanager.GradientColorStop := bkBranding.GroupBackGroundStopColor;
  GBClientmanager.GradientColorStart := bkBranding.GroupBackGroundStartColor;

  PnlLogo.GradientColorStart := bkBranding.TobBarStartColor;
  PnlLogo.GradientColorStop  := bkBranding.TopBarStopColor;

  imgLogo.Picture := AppImages.ImgLogo.Picture;

  imgRight.Transparent := True;
  imgRight.Picture := bkBranding.CodingBanner;
  PnlLogo.Height := bkBranding.CodingBanner.Height;

  pnlFilter.Height := cmbFilter.ClientHeight + 7;
  Assert( icid_Max <= Globals.MAX_CLIENT_MANAGER_COLUMNS, 'icid_Max <= Globals.MAX_CLIENT_MANAGER_COLUMNS');


  ClientLookup.DoCreate;
  ClientLookup.ClientFilter := filterAllClients;
  ClientLookup.vtClients.OnHeaderMouseUp := vtClientsHeaderMouseUp;
  ClientLookup.OnUpdateCount :=  UpdateClientCountLabel;
  //create and align the frame
  {
  ClientLookupFrame := TfmeClientLookup.Create(Self);
  ClientLookupFrame.ClientFilter := filterAllClients;
  ClientLookupFrame.vtClients.OnHeaderMouseUp := vtClientsHeaderMouseUp;
  ClientLookupFrame.Parent := pnlFrameHolder;
  ClientLookupFrame.Align  := alClient;
   }
  //Self.ActiveControl := ClientLookupFrame.vtClients;
  // Defaults
  FScreenLockCount := 0;
  FMode            := md_ClientManager;
  FIsGlobal        := False;
  FCurrentUserFilter := nil;
  FCurrentGroupFilter := nil;
  FCurrentClientTypeFilter := nil;
  actHelp.Visible := bkHelp.BKHelpFileExists;
  //StartFocus := True;

  if not ProductConfigService.OnLine then
    LogUtil.LogMsg(lmError, UnitName, 'Cannot connect to Banklink Online');

end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.FormDeactivate(Sender: TObject);
begin
  //ActiveControl := nil;
  tmrUpdateClientDetails.Enabled := False;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.UpdateINI;
begin
  if not IsGlobal then begin

    if Assigned(CurrUser)
    and (not CurrUser.HasRestrictedAccess)
    and UserSet then
    begin
      //save user settings
      case ClientLookup.ViewMode of
        vmAllFiles : UserINI_CM_Default_View := 0;
        vmMyFiles : UserINI_CM_Default_View := 1;
      else
        UserINI_CM_Default_View := 0;
      end;
      UserINI_CM_Filter := Integer(cmbFilter.Items.Objects[cmbFilter.ItemIndex]);
      UserINI_CM_SubFilter := ClientLookup.SubFilter;
      UserINI_CM_SubFilter_Name := btnFilter.Hint;
      if Assigned(UserINI_CM_UserFilter) then
        UserINI_CM_UserFilter.Text := FCurrentUserFilter.Text;
      if Assigned(UserINI_CM_GroupFilter) then
        UserINI_CM_GroupFilter.Text := FCurrentGroupFilter.Text;
      if Assigned(UserINI_CM_ClientTypeFilter) then
        UserINI_CM_ClientTypeFilter.Text := FCurrentClientTypeFilter.Text;
      //update user ini settings for columns
      if (ClientLookup.ClientFilter = filterAllClients)
      or (ClientLookup.ClientFilter = filterMyClients) then
         UpdateColumnINISettings;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.FormDestroy(Sender: TObject);
begin
  UpdateINI;
  if not FIsGlobal then
    GLClientManager := nil;
  if Assigned(FCurrentUserFilter) then // I Know..
     FreeAndnil(FCurrentUserFilter);   // It just reads better...
  if Assigned(FCurrentGroupFilter) then
     FreeAndnil(FCurrentGroupFilter);
  if Assigned(FCurrentClientTypeFilter) then
     FreeAndnil(FCurrentClientTypeFilter);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.FormShow(Sender: TObject);
begin
  actUpdateProcessing.Visible := False;

  if not IsGlobal then
     Windowstate := wsMaximized;
  try
     ClientLookup.vtClients.SetFocus;
  except
  end;

  CheckBOConnectionLocal;
end;

//------------------------------------------------------------------------------
function TfrmClientManager.GetBlopiClientNew: TBloClientCreate;
begin
  Result := FBlopiClient.ClientNew;
end;

function TfrmClientManager.GetINI_ID( aFieldID : TClientLookupCol ) : integer;
begin
  case aFieldID of
    cluCode : Result := icid_Code;
    cluName : Result := icid_Name;
    cluAction : Result := icid_Action;
    cluReminderDate : Result := icid_ReminderDate;
    cluStatus : Result := icid_Status;
    cluUser : Result := icid_User;
    cluReportingPeriod : Result := icid_ReportingPeriod;
    cluSendBy : Result := icid_SendBy;
    cluLastAccessed : Result := icid_LastAccessed;
    cluFinYearStarts : Result := icid_FinYearStarts;
    cluContactType : Result := icid_ContactType;
    cluProcessing : Result := icid_Processing;
    cluGroup : Result := icid_Group;
    cluClientType : Result := icid_ClientType;
    cluNextGSTDue : Result := icid_NextGSTDue;
    cluBankLinkOnline : Result := icid_BankLinkOnline;
    cluModifiedDate : Result := icid_ModifiedDate;
    cluBOProduct : Result := icid_BOProduct;
    // cluBOBillingFrequency : Result := icid_BOBillingFrequency;
    cluBOUserAdmin : Result := icid_BOUserAdmin;
    cluBOAccess : Result := icid_BOAccess;
  else
    Result := -1;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.AddCustomColumn( aCaption : string;
                                             aDefWidth, aDefPos : integer;
                                             aFieldID : TClientLookupCol;
                                             aProductIndex : integer;
                                             aProductGuid  : TBloGuid);
var
  UserPos, UserWidth : integer;
  IniColumnID : integer;
  UserVisible: Boolean;
  OldProdIndex: Integer;

  Function GetProdGuidIndex(aProductGuid : TBloGuid) : Integer;
  var
    Index : integer;
  begin
    Result := -1;

    for Index := 0 to High(UserINI_CM_Var_Col_Guid) do
    begin
      if UserINI_CM_Var_Col_Guid[Index] = aProductGuid then
      begin
        Result := Index;
        Exit;
      end;
    end;
  end;
begin

  UserPos := -1;  //-1 inidicates no info for this column
  UserWidth := aDefWidth; // #1665 - don't ever use zero as the default
  UserVisible := True;
  IniColumnID := GetINI_ID( aFieldID);

  //have column id, now load correct setting
  if not SuperUserLoggedIn then
  begin
    if IniColumnID in [ icid_Min..icid_Max] then
    begin
      if IniColumnID = icid_BOProduct then
      begin
        OldProdIndex := GetProdGuidIndex(aProductGuid);

        if OldProdIndex > -1 then
        begin
          UserPos := UserINI_CM_Var_Col_Positions[OldProdIndex];
          UserWidth := UserINI_CM_Var_Col_Widths[OldProdIndex];
          UserVisible := UserINI_CM_Var_Col_Visible[OldProdIndex];
        end
        else
        begin
          UserPos := aDefPos;
          UserWidth := aDefWidth;
          UserVisible := True;
        end;
      end
      else
      if FMode = md_ClientManager then
      begin
        UserPos := UserINI_CM_Column_Positions[ IniColumnID];
        UserWidth := UserINI_CM_Column_Widths[ IniColumnID];
        UserVisible := UserINI_CM_Column_Visible[ IniColumnID];
      end
      else
      if FMode = md_GlobalSetup then
      begin
        UserPos := UserINI_GS_Column_Positions[ IniColumnID];
        UserWidth := UserINI_GS_Column_Widths[ IniColumnID];
        UserVisible := True;
      end;
    end;
  end;

  ClientLookup.AddColumnEx( aFieldID, aCaption, aDefWidth, aDefPos, UserWidth,
                            UserPos, UserVisible, aProductIndex, aProductGuid);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.UpdateColumnINISettings;
var
  i : integer;
  IniColumnID : integer;
  FieldID : TClientLookupCol;
  ProdIndex : integer;
  ProdGuid : TBloGuid;
begin
  //cycle thru each column and update ini setting

  for i := 0 to ClientLookup.ColumnCount - 1 do
  begin
    ProdIndex := ClientLookup.Columns.ColumnDefn_At(i).ProdIndex;
    ProdGuid := ClientLookup.Columns.ColumnDefn_At(i).ProdGuid;
    FieldID := ClientLookup.GetColumnID( i);
    IniColumnID := GetINI_ID( FieldID);
    UserINI_CM_SortColumn := Ord(ClientLookup.SortColumn);
    UserINI_CM_SortDescending := ClientLookup.SortDirection = sdDescending;
    //have column id, now save correct setting
    if IniColumnID in [ icid_Min..icid_Max] then
    begin
      if IniColumnID = icid_BOProduct then
      begin
        UserINI_CM_Var_Col_Positions[ProdIndex] := ClientLookup.GetColumnPosition(i);
        UserINI_CM_Var_Col_Widths[ProdIndex] := ClientLookup.GetColumnWidth(i);
        UserINI_CM_Var_Col_Visible[ProdIndex] := ClientLookup.GetColumnVisibility(i);
        UserINI_CM_Var_Col_Guid[ProdIndex] := ProdGuid;
      end
      else
      if FMode = md_ClientManager then
      begin
        UserINI_CM_Column_Positions[ IniColumnID] := ClientLookup.GetColumnPosition( FieldID);
        UserINI_CM_Column_Widths[ IniColumnID] := ClientLookup.GetColumnWidth( FieldID);
        UserINI_CM_Column_Visible[ IniColumnID] := ClientLookup.GetColumnVisibility( FieldID);
      end
      else
      if FMode = md_GlobalSetup then
      begin
        UserINI_GS_Column_Positions[ IniColumnID] := ClientLookup.GetColumnPosition( FieldID);
        UserINI_GS_Column_Widths[ IniColumnID] := ClientLookup.GetColumnWidth( FieldID);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.CheckBOConnection(var message: TMessage); 
begin
  CheckBOConnectionLocal;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.CheckBOConnectionLocal;
var
  BOOnline, PracticeOnline: boolean;
begin
  BOOnline := ProductConfigService.OnLine;
  if BOOnline then
    PracticeOnline := ProductConfigService.IsPracticeActive;
  imgCannotConnect.Visible := (AdminSystem.fdFields.fdUse_BankLink_Online and
                              ((BOOnline = false) or (PracticeOnline = false)));
  lblCannotConnect.Visible := imgCannotConnect.Visible;
  if not BOOnline then
    lblCannotConnect.Caption := 'Cannot connect to Banklink Online'
  else if (ProductConfigService.OnlineStatus = staDeactivated) then
    lblCannotConnect.Caption := 'BankLink Online is currently deactivated. Please ' +
                                'contact BankLink Support for further assistance'
  else if (ProductConfigService.OnlineStatus = staSuspended) then
    lblCannotConnect.Caption := 'BankLink Online is currently in suspended (read-only) ' +
                                'mode. Please contact BankLink Support for further assistance';
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.ClientLookupvtClientsGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: WideString);
begin
  ClientLookup.vtClientsGetText(Sender, Node, Column, TextType, CellText);

end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.ResetIniColumnDefaults;
{ #1665 - if its somehow got to here without reading the ini file
  then its possible all the column settings could be zero which is invalid data
  because ColPositions should never all be 0. if thats the case then reset them
  to be -1 so a default is used.
}
var
  i: Integer;
begin
  for i := icid_Min to icid_Max do
  begin
    if FMode = md_ClientManager then
    begin
      if (UserINI_CM_Column_Positions[i] > 0) or (UserINI_CM_Column_Widths[i] > 0) or (not UserINI_CM_Column_Visible[i]) then
        exit;
    end
    else if FMode = md_GlobalSetup then
    begin
      if (UserINI_GS_Column_Positions[i] > 0) or (UserINI_GS_Column_Widths[i] > 0) then
        exit;
    end;
  end;
  if FMode = md_ClientManager then
    for i := icid_Min to icid_Max do
    begin
      UserINI_CM_Column_Positions[ i] := -1;
      UserINI_CM_Column_Widths[ i] := -1;
      UserINI_CM_Column_Visible[ i] := True;
    end
  else if FMode = md_GlobalSetup then
    for i := icid_Min to icid_Max do
    begin
      UserINI_GS_Column_Positions[ i] := -1;
      UserINI_GS_Column_Widths[ i] := -1;
    end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.BuildHeaderContextMenu;
var
  it: TMenuItem;
  i: Integer;
  c: TClientLookupCol;
begin

    popHeader.Items.Clear;
    it := TMenuItem.Create(popHeader);
    it.Caption := '&Restore default column layout';
    it.OnClick := mniRestoreColumnsClick;
    popHeader.Items.Insert(0, it);
    it := TMenuItem.Create(popHeader);
    it.Caption := '-';
    popHeader.Items.Insert(0, it);
    for i := Pred(ClientLookup.ColumnCount) downto 0 do
    begin
      it := TMenuItem.Create(popHeader);
      c := ClientLookup.GetColumnIDByPosition(i);
      it.Caption := ClientLookup.GetColumnCaption(c);
      if c= cluProcessing then
         it.Caption := 'Processing Status';
      it.Checked := ClientLookup.GetColumnVisibility(c);
      it.OnClick :=  mniShowHideColumnsClick;
      it.Tag := Ord(c);
      it.Visible := c <> cluCode;
      popHeader.Items.Insert(0, it);
    end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.btnFindClick(Sender: TObject);
begin
  EBFind.Text := '';
  SearchTimerTimer(nil);
end;

//------------------------------------------------------------------------------
procedure CloseClientManager(ProcessMessage: Boolean = True);
begin
   if assigned (GLClientManager) then
   begin
      GLClientManager.Release;
      if ProcessMessage then
        Application.ProcessMessages;
   end;
end;

//------------------------------------------------------------------------------
function DoClientManager(L, T, H, W: Integer) : boolean;
const
   NoSelection : TGridRect = (Left:-1; Top:-1; Right:-1; Bottom:-1 );
var
  i,lW: Integer;
begin
  result := false;
  if Assigned(CurrUser) and Assigned(AdminSystem) and CurrUser.HasRestrictedAccess then exit;
  // #6384: Should not realy need this.. the mainform is disabled before we get here
  // But I suppose because the Client-Home-page gets enabled, the shift-F12 can get trough
  // and the Client manager gets run again….

  if GlfrmClientManagerUp then exit;
  GlfrmClientManagerUp := true;
  try
  if Assigned (GLClientManager) then begin
     // Alread open...
     if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter Re Activate');
     if (GLClientManager.WindowState = wsMinimized) then
            ShowWindow(GLClientManager.Handle, SW_RESTORE);
     if GLClientManager.UserSet then begin
        GLClientManager.BringToFront;
        GLClientManager.StartFocus := True;
        GLClientManager.OnActivate(nil);
        GLClientManager.StartFocus := True;
     end;
  end else begin
     if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter Make New');
     Application.CreateForm(TfrmClientManager,GLClientManager);

     with GLClientManager do begin
        FormStyle := fsMDIChild;
        BKHelpSetUp(GLClientManager, BKH_The_Client_Manager);

        IsGlobal := False;    
        //pnlClose.Visible := False;
        pnlClose.Height := 0;
        FCurrentUserFilter := TStringList.Create;
        FCurrentGroupFilter := TStringList.Create;
        FCurrentClientTypeFilter := TStringList.Create;
        if Assigned(MyClient) then
           Merge32.UpdateProcessingStats(MyClient, True, True);
        //load a snapshot of the admin system

        Admin32.ReloadAdminAndTakeSnapshot(ClientLookup.AdminSnapshot);


        Caption := ClientLookup.AdminSnapshot.fdFields.fdPractice_Name_for_Reports + ' Clients';
        FMode   := md_ClientManager;


        with ClientLookup Do begin
           //set up events
           OnSelectionChanged := SelectionChanged;
           OnGridDblClick     := FrameDblClick;
           OnNotesClick       := FrameNotesClick;
           OnGridColumnMoved  := ColumnMoved;

           vtClients.PopupMenu := popClientManager;
           vtClients.Header.PopupMenu := popHeader;


        end; //ClientLookupFrame


        lw := Sglegend.Canvas.TextWidth('Available') + 15;
        i := 0;
        while i < 12 do begin
           sgLegend.ColWidths[i] := 20; // LED
           sgLegend.ColWidths[i+1] := lw; // Text
           Inc(i, 2);
        end;
        sgLegend.ColWidths[11] := lw+15;
        sgLegend.Selection := NoSelection;


     end;// GLClientManager

  end;
  if (not GLClientManager.UserSet)
  and Assigned(CurrUser) then
  begin
     GLClientManager.SetUser;
     GLClientManager.lblCount.Visible := True;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit Make New / Re Activate');
  finally
      GlfrmClientManagerUp := False;
  end;
end;

function CompareProductColumns(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := CompareText(List.ValueFromIndex[Index1], List.ValueFromIndex[Index2]); 
end;

//------------------------------------------------------------------------------
function DoGlobalClientSetup(w_PopupParent: TForm; L, T, H, W: Integer) : boolean;
var
  ClientManager : TfrmClientManager;
  i, NumColumns: Integer;
  ColumnName: string;
  ColumnSorter: TStringList;
const
   Offset = 30;
begin
  Result := false;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit Make New / Re Activate');
  ClientManager := TfrmClientMaint.Create(Application.MainForm);
  with ClientManager do
  begin
    try
      PopupParent := w_PopupParent;
      PopupMode := pmExplicit;
          
      BKHelpSetUp(ClientManager, BKH_Maintain_Clients);
      //load a snapshot of the admin system
      Admin32.ReloadAdminAndTakeSnapshot( ClientLookup.AdminSnapshot);

      //Set Window pos
      SetBounds(L + Offset,T + Offset,W - Offset * 2,H - Offset * 2);

      lblCount.Left := lblCount.Left - btnFilter.Width - btnResetFilter.Width;

      Caption := 'Maintain Clients';
      FMode   := md_GlobalSetup;

      rzgFileTasks.Visible := False;
      rzgCommunicate.Visible := False;
      rzgOptions.Visible := False;
      pnlLogo.Visible := False;

      with ClientLookup do
      begin
        ClientFilter := filterAllClients;

        //add columns and build the grid
        ClearColumns;
        ResetIniColumnDefaults;

        AddCustomColumn( 'Code', 100, 0, cluCode);
        AddCustomColumn( 'Name', 250, 1, cluName);
        AddCustomColumn( 'User', 120, 3, cluUser);
        AddCustomColumn( 'Group', 120, 4, cluGroup);
        AddCustomColumn( 'Client Type', 120, 5, cluClientType);
        AddCustomColumn( 'Report Schedule', 100, 6, cluReportingPeriod);
        AddCustomColumn( 'Send By', 100, 7, cluSendBy);
        AddCustomColumn( 'Status', 120, 8, cluStatus);
        AddCustomColumn( 'Last Accessed', 75, 9, cluLastAccessed);
        AddCustomColumn( 'Financial Year Starts', 75, 10, cluFinYearStarts);
        AddCustomColumn( 'Practice Contact', 75, 11, cluContactType);

        NumColumns := 12;

        if (ProductConfigService.OnLine and AdminSystem.fdFields.fdUse_BankLink_Online) then
        begin
          ProductConfigService.LoadClientList;

          if Assigned(ProductConfigService.Clients) then
          begin
            ColumnSorter := TStringList.Create;

            try
              for i := 0 to Length(ProductConfigService.Clients.Catalogue)-1 do
              begin
                if ProductConfigService.Clients.Catalogue[i].CatalogueType <> 'Service' then
                begin
                  ColumnSorter.Add(ProductConfigService.Clients.Catalogue[i].Id + '=' + ProductConfigService.Clients.Catalogue[i].Description);
                end;

                {
                if ProductConfigService.Clients.Catalogue[i].CatalogueType <> 'Service' then
                begin
                  ColumnName := ProductConfigService.Clients.Catalogue[i].Description;

                  AddCustomColumn(trim(ColumnName),
                                  trunc(vtClients.Canvas.TextWidth(trim(ColumnName)) * 2),
                                  NumColumns,
                                  cluBOProduct,
                                  i,
                                  ProductConfigService.Clients.Catalogue[i].Id);

                  inc(NumColumns);
                end;
                }
              end;

               //Sort the columns so that they appear by default in alphabetical order
              ColumnSorter.CustomSort(CompareProductColumns);

              for i := 0 to ColumnSorter.Count - 1 do
              begin
                ColumnName := ColumnSorter.ValueFromIndex[i];

                AddCustomColumn(trim(ColumnName),
                                trunc(vtClients.Canvas.TextWidth(trim(ColumnName)) * 2),
                                NumColumns,
                                cluBOProduct,
                                i,
                                ColumnSorter.Names[i]);

                inc(NumColumns);
              end; 
            finally
              ColumnSorter.Free;
            end;

            if UserINI_CM_Var_Col_Count <> Length(ProductConfigService.Clients.Catalogue) then
            begin
              UserINI_CM_Var_Col_Count := Length(ProductConfigService.Clients.Catalogue);
              SetLength(UserINI_CM_Var_Col_Positions, UserINI_CM_Var_Col_Count);
              SetLength(UserINI_CM_Var_Col_Widths,    UserINI_CM_Var_Col_Count);
              SetLength(UserINI_CM_Var_Col_Visible,   UserINI_CM_Var_Col_Count);
              SetLength(UserINI_CM_Var_Col_Guid,      UserINI_CM_Var_Col_Count);
            end;

            AddCustomColumn( 'User Admin',
              trunc(vtClients.Canvas.TextWidth(trim('User Admin')) * 2), NumColumns, cluBOUserAdmin);
            AddCustomColumn( 'Banklink Online Access',
              trunc(vtClients.Canvas.TextWidth(trim('Banklink Online Access')) * 2), NumColumns + 1, cluBOAccess);
          end;
        end;

        BuildGrid( cluCode);

        // Include non-prospect filters only
        cmbFilter.Clear;
        for i := filterMin to filterMax do
          if (filterConfig[i, 0] = ctActive) then
            cmbFilter.Items.AddObject(filterNames[i], TObject(i));
        cmbFilter.ItemIndex := 0;
        UpdateFilter(0);

        SelectMode := smMultiple;

        //set up events
        OnSelectionChanged := SelectionChanged;

        if SelectionCount = 1 then
          FillClientDetails;

        vtClients.PopupMenu := popGlobal;
        vtClients.Header.PopupMenu := popHeader;
      end;

      // Switch off Practice Management stuff for global setup
      rzgProspects.Visible := False;
      mniOpen.Visible := False;
      mniTasks.Visible := False;
      mniEdit.Visible := False;
      mniScheduled.Visible := False;
      mniAssignTo.Visible := False;

      //ShowCM := GetUserCMStatus;

      actShowLegend.Visible := False;
      pnlLegend.Visible := False;

      SelectionChanged(nil); // Force GUI update

      actCAF.Visible := (AdminSystem.fdFields.fdCountry = whAustralia);
      if (AdminSystem.fdFields.fdCountry = whUK) then
        actCAF.Caption := 'Open Customer Authority Form';
      actTPA.Visible := (AdminSystem.fdFields.fdCountry = whNewZealand);
      actICAF.Visible := (AdminSystem.fdFields.fdCountry = whUK);

      ShowModal;

      //update user ini settings for columns
      UpdateColumnINISettings;
    finally
      Free;
    end;
  end;
  if frmMain.ActiveMDIChild is TfrmClientManager then
    RefreshClientManager;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.SearchTimerTimer(Sender: TObject);
begin
   SearchTimer.Enabled := False;
   ClientLookup.SearchText := EBFind.Text;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.SelectionChanged(Sender: TObject);
var
  Count : integer;
  SingleClientSelected, NoClientSelected, ProspectSelected,
  UnsyncSelected, ActiveSelected : boolean;
  ArchivedSelected, UnArchivedSelected: boolean;
begin
  //need to change the options available in the group bar depending on
  //how many clients selected and what type of clients are selected
  if ApplicationIsTerminating then exit;
  if not Assigned(CurrUser) then exit;

  Count := ClientLookup.SelectionCount;
  SingleClientSelected   := Count = 1;
  NoClientSelected       := Count = 0;

  BeginUpdate;
  gbClientmanager.BeginUpdateLayout;
  try
    ClientLookup.GetSelectionTypes(ProspectSelected, ActiveSelected, UnsyncSelected);

    actBOSettings.Visible := ProductConfigService.Registered;

    actBOSettings.Enabled := (AdminSystem.fdFields.fdUse_BankLink_Online and
                             ProductConfigService.OnLine and
                             (not ProspectSelected) and
                             (not NoClientSelected) and
                             (not UnsyncSelected) and
                             SingleClientSelected and
                             (not (ProductConfigService.OnlineStatus = staDeactivated))
                             and actBOSettings.Visible);
                             
    actScheduled.Enabled := (not ProspectSelected) and (not NoClientSelected) and (not UnsyncSelected);
    actPracticeContact.Enabled := (not ProspectSelected) and (not NoClientSelected) and (not UnsyncSelected);
    actFinancialYear.Enabled := (not ProspectSelected) and (not NoClientSelected) and (not UnsyncSelected);
    actArchive.Enabled := (not ProspectSelected) and (not NoClientSelected) and (not UnsyncSelected);
    //if archive is enabled, there's still another check to no enabled, if records
    //that are archived, and not archived are selected at the same time.
    if actArchive.Enabled then
    begin
      ClientLookup.GetArchiveStates(UnArchivedSelected, ArchivedSelected);
      if ArchivedSelected and UnArchivedSelected then
      begin
        actArchive.Caption := 'Archive';
        actArchive.Enabled := False;
      end
      else if not ArchivedSelected and not ArchivedSelected then
        actArchive.Caption := 'Archive'
      else
        actArchive.Caption := 'Reinstate'; //must be only archived
    end;
    
    actCodingScreenLayout.Enabled := (not ProspectSelected) and (not NoClientSelected);
    actCheckOut.Enabled := (not ProspectSelected) and (not NoClientSelected);
    actDeleteProspect.Enabled := ProspectSelected and (not ActiveSelected);
    actAssignTo.Enabled := (not NoClientSelected) and (not UnsyncSelected);
    actAssignBulkExport.Enabled := (not NoClientSelected);
    actGroup.Enabled := (not NoClientSelected) and (not UnsyncSelected);
    actClientType.Enabled := (not NoClientSelected) and (not UnsyncSelected);
    actUnlockFile.Enabled  := (not NoClientselected) and (not ProspectSelected);
    actOpen.Enabled        := SingleClientSelected and (not ProspectSelected);
    actTasks.Enabled       := SingleClientSelected;
    actEditClientDetails.Enabled := SingleClientSelected;
    actDeleteFile.Enabled  := SingleClientSelected and (actDeleteFile.Visible);
    actConvertToBK.Enabled := SingleClientSelected and ProspectSelected;
    actConvertToBK.Visible := CurrUser.CanAccessAdmin;
    actMergeDoc.Enabled := not NoClientSelected;
    actMergeEmail.Enabled := not NoClientSelected;
    actSend.Enabled := (not ProspectSelected) and (SingleClientSelected);

    if FIsGlobal then // Never use in global setup
    begin
      // Client maintenance..
      if NoClientSelected then
        ClientLookup.vtClients.PopupMenu := popHeader
      else
        ClientLookup.vtClients.PopupMenu := popGlobal;


    end else begin
       // Client manager screen
       mniOpen.Visible := not NoClientSelected;
       mniTasks.Visible := not NoClientSelected;
       mniEdit.Visible := not NoClientSelected;
       mniScheduled.Visible := not NoClientSelected;
       mniAssignTo.Visible := not NoClientSelected;

       mniProspectRestoreCols.Visible := False;
       mniRestoreColumns.Visible := not NoClientSelected or (ClientLookup.ClientCount = 0);
       mniFilter.Visible := not NoClientSelected or (ClientLookup.ClientCount = 0);
       mniResetFilter.Visible := not NoClientSelected or (ClientLookup.ClientCount = 0);

       if ProspectSelected then
         ClientLookup.vtClients.PopupMenu := popProspects
       else
         ClientLookup.vtClients.PopupMenu := popClientManager;

       actMultiTasks.Enabled  := Count > 1;
    end;

    //rzgDetails.Items.Clear;

    //Trigger the client details to update, a timer is used so that details
    //are only updated once selection has settled
    tmrUpdateClientDetails.Enabled := false;
    tmrUpdateClientDetails.Enabled := true;

   finally
     EndUpdate;
     gbClientManager.EndUpdateLayout
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.UpdateClientDetails( Count : integer);
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter UpdateClientDetails');
  BeginUpdate;
  try
    tmrUpdateClientDetails.Enabled := false;
    if Count = 1 then
    begin
       FillClientDetails;
    end else
    begin
       ShowSelectedNo( Count);
       UpdateMultiTasks();
       actTasks.Caption := 'Task List and Comments';
    end;
    UpdatePrintTasks;
  finally
    EndUpdate;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit UpdateClientDetails');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.UpdateMultiTasks;
var
  Item: TRzGroupItem;
begin
  if not isGlobal then begin
     Item := rzgDetails.Items.Add;
     Item.Action := actMultiTasks;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.UpdatePrintTasks;
var
  Item: TRzGroupItem;
begin
  if not isGlobal then begin
     Item := rzgDetails.Items.Add;
     Item.Action := actPrintTasks;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.UpdateTasksPending
;
var
  S : string;
  Code : string;
  SysClientRec : pClient_File_Rec;
  Item         : TRzGroupItem;
begin

  Code := ClientLookup.FirstSelectedCode;
  sysClientRec := ClientLookup.AdminSnapshot.fdSystem_Client_File_List.FindCode( Code);

  S := 'Task List and Comments';
  if Assigned( sysClientRec) and ( sysClientRec^.cfPending_ToDo_Count > 0) then
    S := 'Task List (' + inttostr( sysClientRec^.cfPending_ToDo_Count) + ' pending) and Comments';

  actTasks.Caption := S;

  Item := rzgDetails.Items.Add;
  Item.Action := actTasks;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.FillClientDetails;
var
  S : string;
  Code : string;
  SysClientRec : pClient_File_Rec;
  Item         : TRzGroupItem;
  LastTop: Integer;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter FillClientDetails');

  Code := ClientLookup.FirstSelectedCode;
  sysClientRec := ClientLookup.AdminSnapshot.fdSystem_Client_File_List.FindCode(Code);
  LastTop := rzgFileTasks.Top;

  gbClientmanager.BeginUpdateLayout;
  rzgDetails.Items.BeginUpdate;
  try
  rzgDetails.Items.Clear;

  if Assigned( sysClientRec) then
  begin
    ClientDetailsCache.Load( sysClientRec.cfLRN);

    with ClientDetailsCache do
    begin
      S := Name;
      if S <> '' then
      begin
        rzgDetails.Items.Add.Caption := StringReplace(S, '&', '&&', [rfReplaceAll]);
        rzgDetails.Items[rzgDetails.Items.Count-1].FontColor := clBlack;
      end;

      S := '';
      if Address_L1 <> '' then
      begin
        S := Address_L1;
      end;

      if Address_L2 <> '' then
      begin
        if S > '' then S := S + #10;
        S := S + Address_L2;
      end;

      if Address_L3 <> '' then
      begin
        if S > '' then S := S + #10;
        S := S + Address_L3;
      end;
      if S > '' then
        rzgDetails.Items.Add.Caption := S;

      S := Contact_Name;
      if S <> '' then
      begin
        if Salutation <> '' then
          S := Salutation + ' ' + S;
        rzgDetails.Items.Add.Caption := 'Cn: ' + S;
        //rzgDetails.Items[rzgDetails.Items.Count-1].FontColor := clBlack;
      end;

      S := Phone_No;
      if S <> '' then
      begin
        rzgDetails.Items.Add.Caption := 'Ph: ' + S;
        //rzgDetails.Items[rzgDetails.Items.Count-1].FontColor := clBlack;
      end;

      S := Fax_No;
      if S <> '' then
      begin
        rzgDetails.Items.Add.Caption := 'Fx: ' + S;
        //rzgDetails.Items[rzgDetails.Items.Count-1].FontColor := clBlack;
      end;

      S := Mobile_No;
      if S <> '' then
      begin
        rzgDetails.Items.Add.Caption := 'Mb: ' + S;
        //rzgDetails.Items[rzgDetails.Items.Count-1].FontColor := clBlack;
      end;

      S := Email_Address;
      if S <> '' then
      begin
        Item := rzgDetails.Items.Add;
        Item.Action  := actClientEmail;
        Item.Caption := S;
        actClientEmail.Caption := S;
      end;

      rzgDetails.Items.Add.Caption := '-';

      Item := rzgDetails.Items.Add;
      Item.Action := actEditClientDetails;
    end;
  end
  else
  begin
    S := 'No details available for this client';
    rzgDetails.Items.Add.Caption := S;
  end;

  if FMode = md_ClientManager then
    UpdateTasksPending;

  finally
    rzgDetails.Items.EndUpdate;
    gbClientmanager.EndUpdateLayout;
  end;
  if LastTop <> rzgFileTasks.Top then
     gbClientManager.ScrollPosition := gbClientManager.ScrollPosition + ( rzgFileTasks.Top - LastTop);
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit FillClientDetails');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.ShowSelectedNo(Count : integer);
var
  S : string;
begin
  gbClientManager.BeginUpdateLayout;
  rzgDetails.Items.BeginUpdate;
  try
     rzgDetails.Items.Clear;

     if Count > 1 then
        S := Inttostr( ClientLookup.SelectionCount) + ' clients selected'
     else
        S := 'No client selected';

     rzgDetails.Items.Add.Caption := S;
  finally
     gbClientManager.EndUpdateLayout;
     rzgDetails.Items.EndUpdate;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.btnCancelClick(Sender: TObject);
begin
  Modalresult := Mrcancel;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.BeginUpdate;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Begin Update');
  if FScreenLockCount = 0 then
  begin
    if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Lock Update');
    Screen.Cursor   := crHourglass;
    LockWindowUpdate( Handle);
  end;
  Inc( FScreenLockCount);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.EndUpdate;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'End Update');
  Dec( FScreenLockCount);
  if FScreenLockCount = 0 then
  begin
    LockWindowUpdate( 0);
    Screen.Cursor := crDefault;
    if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Unlock Update');
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.RefreshLookup(CodeToSelect: string);
begin
  //reload list
  BeginUpdate;
  try
    ReloadAdminAndTakeSnapshot(ClientLookup.AdminSnapshot);
    ClientLookup.Reload;

    if CodeToSelect <> '' then
      ClientLookup.LocateCode(CodeToSelect);
  finally
    EndUpdate;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actOpenExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcOpen);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actNewFileExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcNew);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actCheckInExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcCheckIn);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actCheckOutExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcCheckOut);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// assign a staff member
//

//------------------------------------------------------------------------------
procedure TfrmClientManager.actShowLegendExecute(Sender: TObject);
begin
  ShowLegend := not ShowLegend;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actArchiveExecute(Sender: TObject);
begin
  ProcessModalCommand( cm_mcArchive);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actAssignBulkExportExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcAssignBulkExport);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actAssignToExecute(Sender: TObject);
begin
  ProcessModalCommand( cm_mcAssignTo);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actBOSettingsExecute(Sender: TObject);
var
  ClientCode: string;
  ShowServicesAvailable: boolean;
begin
  ClientLookup.vtClients.BeginUpdate;
  try
    ClientCode := ClientLookup.FirstSelectedCode;
    OpenClient(ClientCode);
    try
      ShowServicesAvailable := ((MyClient.clFields.clDownload_From <> dlBankLinkConnect) or
                                (Trim(MyClient.clFields.clBankLink_Code) = ''));
      if ProductConfigService.IsExportDataEnabled then
        ShowServicesAvailable := ShowServicesAvailable and
                                 ProductConfigService.PracticeHasVendors;
      if EditBanklinkOnlineSettings(Self, false, false, ShowServicesAvailable) then
      begin
        //Need to reload TProductConfigService.Clients after blopi has been updated.  Probably better to update this locally somehow.
        ProductConfigService.LoadClientList;
      end;
    finally
      CloseClient();
    end;
  finally
    ClientLookup.vtClients.EndUpdate;
  end;
end;

//------------------------------------------------------------------------------
//
// set up report schedule
//
procedure TfrmClientManager.actScheduledExecute(Sender: TObject);
begin
  ProcessModalCommand( cm_mcSetupSchedule);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actClientEmailExecute(Sender: TObject);
var
  unused: Boolean;
  CanSelectClients: Boolean;
begin
  CanSelectClients := CurrUser.CanAccessAdmin or (not PRACINI_OSAdminOnly);
  MailFrm.SendFileTo( 'Send Mail', actClientEmail.Caption, '', '', unused, CanSelectClients);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actClientTypeExecute(Sender: TObject);
begin
  ProcessModalCommand( cm_mcAssignClientType);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actEditClientDetailsExecute(Sender: TObject);
begin
  ProcessModalCommand( cm_mcEditClientDetails);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.tmrUpdateClientDetailsTimer(Sender: TObject);
begin

  UpdateClientDetails(ClientLookup.SelectionCount);
  if StartFocus then
   try
      activecontrol := nil;

      activecontrol := ClientLookup.vtClients;
      StartFocus := False;

      gbClientmanager.ShowEntireGroup(rzgFiletasks);
   except
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actTasksExecute(Sender: TObject);
begin
  ProcessModalCommand( cm_mcTasks);
end;

//------------------------------------------------------------------------------
//
// apply coding screen layouts
//
procedure TfrmClientManager.actCodingScreenLayoutExecute(Sender: TObject);
begin
  ProcessModalCommand( cm_mcLoadLayout);
end;

//------------------------------------------------------------------------------
//
// assign practice contact
//
procedure TfrmClientManager.actPracticeContactExecute(Sender: TObject);
begin
  ProcessModalCommand( cm_mcAssignContact);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actPrintExecute(Sender: TObject);
begin

  DoClientManagerReport(rdAsk, ClientLookup, btnFilter.Hint);
end;

//------------------------------------------------------------------------------
//
// Change Financial Year
//
procedure TfrmClientManager.actFinancialYearExecute(Sender: TObject);
begin
  ProcessModalCommand( cm_mcChangeFinYear);
end;
procedure TfrmClientManager.actGroupExecute(Sender: TObject);
begin
  ProcessModalCommand( cm_mcAssignGroup);
end;

//------------------------------------------------------------------------------
//
// Delete Client File
//
procedure TfrmClientManager.actDeleteFileExecute(Sender: TObject);
begin
  ProcessModalCommand( cm_mcDeleteFile);
end;

//------------------------------------------------------------------------------
//
// Unlock Client File
//

procedure TfrmClientManager.actNewAccountsExecute(Sender: TObject);
begin
  frmMain.DoMainFormCommand(mf_mcSys_AttachAccounts);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actUnlockFileExecute(Sender: TObject);
begin
  ProcessModalCommand( cm_mcUnlockFile);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actUpdateProcessingExecute(Sender: TObject);
begin
  Self.Enabled := False;
  RefreshAllProcessingStatistics(True);
  Self.Enabled := True;
  HelpfulInfoMsg('Processing Statistics Updated', 0);
  RefreshClientManager;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actTrackTasksExecute(Sender: TObject);
begin
  UpdateClientManagerOptions;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoOpen;
var
  Code: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoOpen');
  Code := ClientLookup.FirstSelectedCode;
  if (Code <> '') then begin

     if Assigned(MyClient) then
      CloseClientHomePage;

     Files.OpenClient(Code);
     RefreshLookup(Code);
  end;

  RefreshHomepage([HRP_Init]);
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoOpen');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoNew;
begin
  frmMain.DoMainFormCommand( mf_mcNewFile);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoUnlock;
var
  Codes : string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoUnlock');
  Codes := ClientLookup.SelectedCodes;

  UnlockClientFile(Codes);
  RefreshLookup( '');
  ClientLookup.SelectedCodes := Codes;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoUnlock');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoCheckIn;
var
  Codes : string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoCheckIn');
  Codes := ClientLookup.SelectedCodes;

  Files.Checkin(ftmFile, Codes);
  RefreshLookup( '');
  ClientLookup.SelectedCodes := Codes;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoCheckIn');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoSendToFile;
var
  Codes : string;
  FirstUpload: Boolean;
  FlagReadOnly, EditEmail, SendEmail: Boolean;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoSendClientFiles');

  //Standard file transfer
  Codes := CheckInOutFrm.SelectCodesToSend('Select Client(s) to Send',
                                           ftmFile, FirstUpload,
                                           FlagReadOnly, EditEmail, SendEmail,
                                           ClientLookup.SelectedCodes);
  if Codes <> '' then begin
    Files.SendClientFiles(Codes, ftmFile, False, True);
    RefreshLookup( '');
    ClientLookup.SelectedCodes := Codes;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoSendClientFiles');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoAssignTo;
var
  Codes         : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoAssignTo');
  if (ClientLookup.SelectionCount > 0) then
  begin
    Codes := ClientLookup.SelectedCodes;

    if AssignStaffMember( Codes) then
    begin
      RefreshLookup( '');
      UpdateFilter(Integer(cmbFilter.Items.Objects[cmbFilter.ItemIndex]));
      ClientLookup.SelectedCodes := Codes;
    end;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoAssignTo');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoAssignGroup;
var
  Codes         : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoAssignGroup');
  if (ClientLookup.SelectionCount > 0) then
  begin
    Codes := ClientLookup.SelectedCodes;

    if AssignGroup( Codes) then
    begin
      RefreshLookup( '');
      UpdateFilter(Integer(cmbFilter.Items.Objects[cmbFilter.ItemIndex]));
      ClientLookup.SelectedCodes := Codes;
    end;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoAssignGroup');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoAssignBulkExport;
var
  Codes: String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoAssignBulkExport');
  if (ClientLookup.SelectionCount > 0) then
  begin
    Codes := ClientLookup.SelectedCodes;

    if BulkExtractfrm.AssignBulkExtract(Codes) then
    begin
      RefreshLookup( '');
      UpdateFilter(Integer(cmbFilter.Items.Objects[cmbFilter.ItemIndex]));
      ClientLookup.SelectedCodes := Codes;
    end;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoAssignBulkExport');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoAssignClientType;
var
  Codes         : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoAssignClientType');
  if (ClientLookup.SelectionCount > 0) then
  begin
    Codes := ClientLookup.SelectedCodes;

    if AssignClientType( Codes) then
    begin
      RefreshLookup( '');
      UpdateFilter(Integer(cmbFilter.Items.Objects[cmbFilter.ItemIndex]));
      ClientLookup.SelectedCodes := Codes;
    end;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoAssignClientType');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoSetupSchedule;
var
  Codes : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoSetupSchedule');
  if (ClientLookup.SelectionCount > 0) then
  begin
    Codes := ClientLookup.SelectedCodes;

    if ConfigureScheduledReports( Codes) then
    begin
      RefreshLookup( '');
      ClientLookup.SelectedCodes := Codes;
    end;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoSetupSchedule');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoAssignContact;
var
  Codes : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoAssignContact');
  if (ClientLookup.SelectionCount > 0) then
  begin
    Codes := ClientLookup.SelectedCodes;

    if AssignPracticeContact( Codes) then
    begin
      RefreshLookup( '');
      ClientLookup.SelectedCodes := Codes;
    end;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoAssignContact');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoChangeFinYear;
var
  Codes : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoChangeFinYear');
  if (ClientLookup.SelectionCount > 0) then
  begin
    Codes := ClientLookup.SelectedCodes;

    if ChangeFinancialYear( Codes) then
    begin
      RefreshLookup( '');
      ClientLookup.SelectedCodes := Codes;
    end;
  end;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoChangeFinYear');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoLayout;
var
  Codes : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoLayout');
  if (ClientLookup.SelectionCount > 0) then
  begin
    Codes := ClientLookup.SelectedCodes;

    if CodingScreenLayout( Codes) then
    begin
      RefreshLookup( '');
      ClientLookup.SelectedCodes := Codes;
    end;
  end;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoLayout');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoArchive;
var
  Codes : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoArchive');
  if (ClientLookup.SelectionCount > 0) then
  begin
    Codes := ClientLookup.SelectedCodes;

    if ArchiveFiles( Codes) then
    begin
      RefreshLookup( '');
      ClientLookup.SelectedCodes := Codes;
    end;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoArchive');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoPrintAllTasks;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoPrintAllTasks');
  rptAdmin.PrintTasksForMultipleClients(ClientLookup.SelectedCodes, rdAsk);
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoPrintAllTasks');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoMultipleAddTasks;
var
  ClientsSelected : TStringList;
  Code: String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoMultipleAddTasks');
  ClientsSelected := TStringList.Create;
  try
    //Get the codes of the clients selected
    ClientsSelected.Delimiter := '~';
    ClientsSelected.DelimitedText := ClientLookup.SelectedCodes;
    //Prompt the user to add tasks
    if AddToDoForMultipleClients(ClientsSelected) then
    begin
      //Refresh the clients that have changed
      for Code in ClientsSelected do
        RefreshLookup( Code);
      //Reselect the same clients that were selected before
      ClientLookup.SelectedCodes := ClientsSelected.DelimitedText;
    end;
  finally
    ClientsSelected.Free;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoMultipleAddTasks');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoTasks;
var
  Code : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoTasks');
  Code := ClientLookup.FirstSelectedCode;
  if MaintainToDoItems( Code, false) then
    RefreshLookup( Code);
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoTasks');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoEditClientDetails;
var
  Code : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoEditClientDetails');
  Code := ClientLookup.FirstSelectedCode;
  if UpdateContactDetails( Code) then
  begin
    RefreshLookup( Code);
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoEditClientDetails');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoDeleteFile;
var
  ScrollPos, i: Integer;
  StringCodeToSelect, DeleteMsgStr: string;
  ClientID: WideString;
  ClientDet : TBloClientReadDetail;
  ClientCode : String;
  ClientName : String;
  CatalogueEntry : TBloCatalogueEntry;
begin
  ClientCode := ClientLookup.FirstSelectedCode;
  ClientName := ClientLookup.FirstSelectedName;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoDeleteFile');
  //act upon a single client only
  ScrollPos := ClientLookup.LastScrollPosition;
  StringCodeToSelect := ClientLookup.GetCodeBelowSelection;

  try
    ClientID := '';
    if UseBankLinkOnline then
    begin
      if not ProductConfigService.OnLine then
      begin
        ShowMessage('BankLink Practice is unable to connect to BankLink Online');
        Exit;
      end;

      if not ProductConfigService.Online then
        Exit;

      ClientDet := ProductConfigService.GetClientDetailsWithCode(ClientCode);
      if Assigned(ClientDet) then
      begin
        if not ProductConfigService.IsPracticeActive then
          Exit;

        ClientID := ClientDet.Id;
      end;
    end;

    DeleteMsgStr := 'Deleting this client will remove ALL TRANSACTIONS in the ' +
                    'client file and will REMOVE the client file from the ' +
                    'Administration System.' + #13#10 + #13#10;

    if not(ClientID = '') and
      (high(ClientDet.Subscription) > -1) then
    begin
      DeleteMsgStr := DeleteMsgStr +
                      'Deleting this client will also, permanently remove ALL CLIENT DATA ' + #13#10 +
                      '& ACCESS for the following products: ' + #13#10 + #13#10;

      for i := low(ClientDet.Subscription) to high(ClientDet.Subscription) do
      begin
        CatalogueEntry := ProductConfigService.GetCatFromSub(ClientDet.Subscription[i]);

        if Assigned(CatalogueEntry) then
        begin
          DeleteMsgStr := DeleteMsgStr + '  ' +
            ProductConfigService.GetCatFromSub(ClientDet.Subscription[i]).Description +
            #13#10;

          if i = high(ClientDet.Subscription) then
            DeleteMsgStr := DeleteMsgStr + #13#10;
        end;
      end;
    end;

    DeleteMsgStr := DeleteMsgStr + 'Are you sure you want to delete Client (' +
                    ClientCode + ' : ' + ClientName + ')';
    if not(ClientID = '') then
      DeleteMsgStr := DeleteMsgStr + ' from BankLink Pratice';
    DeleteMsgStr := DeleteMsgStr + '?';

    if (AskYesNo('Delete Client', DeleteMsgStr, DLG_NO, 0) <> DLG_YES) then
      Exit;

    if not(ClientID = '') and
      (high(ClientDet.Subscription) > -1) then
    begin
      if not ProductConfigService.DeleteClient(ClientDet) then
      begin
        HelpfulErrorMsg('Unable to Connect to BankLink Online.', 0);
        Exit;
      end;
    end;

  except
    on E : Exception do
    begin
      HelpfulErrorMsg(E.Message, 0);
      Exit;
    end;
  end;

  if DeleteClientFile(ClientCode) then
  begin
    RefreshLookup(StringCodeToSelect);
    UpdateFilter(Integer(cmbFilter.Items.Objects[cmbFilter.ItemIndex]));
    ClientLookup.ScrollBy(0, ScrollPos);
  end
  else
    Exit;

  DeleteMsgStr := 'Client (' + ClientCode + ' : ' + ClientName + ') has been ' +
                  'removed from Banklink Practice';
  if not(ClientID = '') and
    (high(ClientDet.Subscription) > -1) then
    DeleteMsgStr := DeleteMsgStr + ' and BankLink Online';

  DeleteMsgStr := DeleteMsgStr + '.';

  HelpfulInfoMsg(DeleteMsgStr, 0 );

  if DebugMe then
    LogUtil.LogMsg(lmDebug,UnitName,'Exit DoDeleteFile');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.ProcessModalCommand(cID: byte);
var
  LoseFocus: Boolean;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter Modal Command');

  if InModal then
     exit;
  InModal := True;
  try
     LoseFocus := (cID in [cm_mcOpen,cm_mcNew]);
     DisableForm;
     try
     case cID of
       cm_mcOpen : DoOpen;
       cm_mcNew  : DoNew;
       cm_mcCheckIn : DoCheckIn;
       cm_mcCheckOut : DoSendToFile;
       cm_mcAssignTo : DoAssignTo;
       cm_mcAssignGroup : DoAssignGroup;
       cm_mcAssignClientType : DoAssignClientType;
       cm_mcSetupSchedule : DoSetupSchedule;
       cm_mcLoadLayout : DoLayout;
       cm_mcAssignContact : DoAssignContact;
       cm_mcChangeFinYear : DoChangeFinYear;
       cm_mcTasks : DoTasks;
       cm_mcAddMultipleTasks: DoMultipleAddTasks;
       cm_mcEditClientDetails : DoEditClientDetails;
       cm_mcPrintAllTasks: DoPrintAllTasks;
       cm_mcUnlockFile : DoUnlock;
       cm_mcDeleteFile : DoDeleteFile;
       cm_mcMergeDoc : DoMergeDoc;
       cm_mcMergeEMail : DoMergeEMail;
       cm_mcNewProspect : DoNewProspect;
       cm_mcCreateMergeDoc : DoCreateDoc(LoseFocus);
       cm_mcImportProspects : DoImportClientsProspects(itProspects);
       cm_mcConvertToBK : DoConvertToBK;
       cm_mcDeleteProspect : DoDeleteProspect;
       cm_mcSend : DoSendViaEmail;
       cm_mcarchive : DoArchive;
       cm_mcImportClients : DoImportClientsProspects(itClients);
       cm_mcAssignBulkExport : DoAssignBulkExport;
       cm_mcSendOnline: DoSendViaOnline;
     end;
     finally
        EnableForm(LoseFocus);
     end;
  finally
     InModal := False;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit Modal Command');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DisableForm;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Disable Form');
  gbClientManager.Enabled := false;
  pnlFrameHolder.Enabled := false;
  pnlFilter.Enabled := False;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.EBFindChange(Sender: TObject);
begin
  SearchTimer.Enabled := False;
  SearchTimer.Enabled := True;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.EBFindKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key)=VK_RETURN then
      SearchTimerTimer(nil);
end;

procedure TfrmClientManager.EnableForm(LooseFocus: Boolean);
begin
  gbClientManager.Enabled := true;
  pnlFrameHolder.Enabled := true;
  pnlFilter.Enabled := True;

  if LooseFocus then
  else
     ClientLookup.SetFocusToGrid;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enable Form');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.FrameDblClick(Sender: TObject);
var
  Prospect, Active, Unsync: Boolean;
begin
  ClientLookup.GetSelectionTypes(Prospect, Active, Unsync);
  if Prospect then
  begin
    if CurrUser.CanAccessAdmin then
      actConvertToBK.Execute;
  end
  else
    actOpen.Execute;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.FrameNotesClick(Sender: TObject);
var
  Code         : String;
begin
  Code := ClientLookup.FirstSelectedCode;
  MaintainToDoItems( Code, false, true);
  RefreshLookup( Code);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Prospect, Active, Unsync: Boolean;
begin
  if (Key = VK_ESCAPE)
  and (IsGlobal) then
  begin
    Key := 0;
    ModalResult := mrCancel;
  end;
  if FMode = md_ClientManager then
  begin
    if (Key = VK_RETURN) and not(EBFind.Focused) then
    begin
      Key := 0;
      ClientLookup.GetSelectionTypes(Prospect, Active, Unsync);
      if Prospect then
      begin
        if CurrUser.CanAccessAdmin then
          actConvertToBK.Execute;
      end
      else
        actOpen.Execute;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.FormResize(Sender: TObject);
begin
  if not FIsGlobal then
  begin
    EnableMenuItem( GetSystemMenu( handle, False ),
                    SC_MINIMIZE,
                    MF_BYCOMMAND or MFS_GRAYED );
    EnableMenuItem( GetSystemMenu( handle, False ),
                    SC_RESTORE,
                    MF_BYCOMMAND or MFS_GRAYED );
    EnableMenuItem( GetSystemMenu( handle, False ),
                    SC_MAXIMIZE,
                    MF_BYCOMMAND or MFS_GRAYED );
  end;
   (*
  if FIsGlobal then
    btnClose.Left := Max(280, pnlFilter.Width  - btnClose.Width - 10)
  else
    btnClose.Left := Max(530, pnlFilter.Width  - btnClose.Width - 10);
    *)
end;

procedure TfrmClientManager.mniFilterClick(Sender: TObject);
begin
  DoNewFilter(True);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.mniResetFilterClick(Sender: TObject);
begin
  btnFilter.Hint := FILTER_ALL;
  FCurrentUserFilter.Clear;
  FCurrentGroupFilter.Clear;
  FCurrentClientTypeFilter.Clear;
  ClientLookup.SubFilter := 0;
  DoNewFilter(False);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.mniRestoreColumnsClick(Sender: TObject);
begin
  ClientLookup.vtClients.OnHeaderMouseUp := nil;
  BeginUpdate;
  try
    ClientLookup.ResetColumns;
    BuildHeaderContextMenu;
    if (ClientLookup.ClientFilter = filterMyProspects)
    or (ClientLookup.ClientFilter = filterAllProspects) then
    begin
      UpdateColumnINISettings;
      ClientLookup.SetColumnVisiblity(cluProcessing, False);
      ClientLookup.SetColumnVisiblity(cluStatus, False);
      ClientLookup.SetColumnVisiblity(cluReportingPeriod, False);
      ClientLookup.SetColumnVisiblity(cluSendBy, False);
      ClientLookup.SetColumnVisiblity(cluLastAccessed, False);
      ClientLookup.SetColumnVisiblity(cluGroup, False);
      ClientLookup.SetColumnVisiblity(cluClientType, False);
      ClientLookup.SetColumnVisiblity(cluNextGSTDue, False);
      BuildHeaderContextMenu;
    end
  finally
    EndUpdate;
    ClientLookup.vtClients.OnHeaderMouseUp := vtClientsHeaderMouseUp;
    UpdateINI;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.mniShowHideColumnsClick(Sender: TObject);
var
  mi: TMenuItem;
begin
  mi := Sender As TMenuItem;
  ClientLookup.SetColumnVisiblity(TClientLookupCol(mi.Tag), not mi.Checked);
  mi.Checked := not mi.Checked;
  UpdateINI;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.pnlCloseResize(Sender: TObject);
begin
   if pnlClose.Height > 1  then
      btnClose.Left :=  pnlClose.Width - 85;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actHelpExecute(Sender: TObject);
begin
  BKHelpShow(Self);
end;

//------------------------------------------------------------------------------
// === Practice Management Actions ===
procedure TfrmClientManager.actMergeDocExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcMergeDoc);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actMergeEmailExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcMergeEMail);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actMultiTasksExecute(Sender: TObject);
begin
  ProcessModalCommand( cm_mcAddMultipleTasks);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actPrintTasksExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcPrintAllTasks);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actCreateDocExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcCreateMergeDoc);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actICAFExecute(Sender: TObject);
var
  ImportCAFfrm: TfrmImportCAF;
begin
  ImportCAFfrm := TfrmImportCAF.Create(Application.MainForm);
  try
    ImportCAFfrm.ShowModal;
  finally
    ImportCAFfrm.Free;
  end;
end;

procedure TfrmClientManager.actImportClientsExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcImportClients);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actImportProspectsExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcImportProspects);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actInActiveExecute(Sender: TObject);
begin
   MaintainPracticeBankAccounts(mpba_Inactive);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actNewProspectExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcNewProspect);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actDeleteProspectExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcDeleteProspect);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actDownloadExecute(Sender: TObject);
begin
  ModalProcessorDlg.DoModalCommand( mpcDoDownloadFromBConnect);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actDataAvailableExecute(Sender: TObject);
begin
  ModalProcessorDlg.DoModalCommand( mpcDoDownloadFromBConnect);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actConvertToBKExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcConvertToBK);
end;

//------------------------------------------------------------------------------
// === Practice Management Methods ===
procedure TfrmClientManager.DoMergeDoc;
var
  Codes: string;
  Index: Integer;
begin
  try
    //Clear any document objects that point to deleted files.
    if (Pos('Vista', WinUtils.GetWinVer) > 0) then
    begin
      if owMerge.Connected then
      begin
        owMerge.Connected := False;
      end;

      owMerge.Documents.Clear;

      owMerge.Connected := True;
    end
    else
    if not owMerge.Connected then
    begin
      owMerge.Connected := True;
    end;


    if not owMerge.Connected then begin
      HelpfulInfoMsg(OfficeFialed, 0);
      Exit;
    end;

    Codes := ClientLookup.SelectedCodes;
    if PerformMailMerge(Codes, owMerge) then
      RefreshLookup( '');
    ClientLookup.SelectedCodes := Codes;
  except
    on E: Exception do
      HelpfulInfoMsg(OfficeFialed, 0);
  end;
end;

//------------------------------------------------------------------------------
// Mail merge email
procedure TfrmClientManager.DoMergeEMail;
var
  Codes: string;
  Index: Integer;
begin
  try
    //Clear any document objects that point to deleted files.
    if (Pos('Vista', WinUtils.GetWinVer) > 0) then
    begin
      if owMerge.Connected then
      begin
        owMerge.Connected := False;
      end;

      owMerge.Documents.Clear;

      owMerge.Connected := True;
    end
    else
    if not owMerge.Connected then
    begin
      owMerge.Connected := True;
    end;

    if not owMerge.Connected then begin
      HelpfulInfoMsg(OfficeFialed, 0);
      Exit;
    end;

    Codes := ClientLookup.SelectedCodes;
    if PerformEMailMerge(Codes, owMerge) then
      RefreshLookup( '');
    ClientLookup.SelectedCodes := Codes;
  except
    on E: Exception do
      HelpfulInfoMsg(OfficeFialed, 0);
  end;
end;

//------------------------------------------------------------------------------
// Create a new mail merge document
procedure TfrmClientManager.DoCreateDoc(var LoseFocus: Boolean);
var
  Codes: string;
  Index: Integer;
begin
  try
    //Clear any document objects that point to deleted files.
    if (Pos('Vista', WinUtils.GetWinVer) > 0) then
    begin
      if owMerge.Connected then
      begin
        owMerge.Connected := False;
      end;

      owMerge.Documents.Clear;

      owMerge.Connected := True;
    end
    else
    if not owMerge.Connected then
    begin
      owMerge.Connected := True;
    end;
      
    if not owMerge.Connected then begin
      HelpfulInfoMsg(OfficeFialed, 0);
      Exit;
    end;

    Codes := ClientLookup.SelectedCodes;
    PerformDocCreation(owMerge, LoseFocus);
    RefreshLookup('');
    ClientLookup.SelectedCodes := Codes;
  except
    on E: Exception do
      HelpfulInfoMsg(OfficeFialed, 0);
  end;
end;

//------------------------------------------------------------------------------
// Add a new prospect - re-use the update contact details form
procedure TfrmClientManager.DoNewProspect;
var
  i, userLRN: Integer;
  user: pUser_rec;
begin
  with TContactDetailsFrm.Create(Self) do
  begin
    try
      Caption := 'Add Prospect Contact Details';
      ClientType := ctProspect;
      cmbUsers.Clear;
      cmbUsers.AddItem('Not Allocated', TObject(0));
      cmbUsers.ItemIndex := 0;
      for i := 0 to Pred(AdminSystem.fdSystem_User_list.ItemCount) do
      begin
        user := AdminSystem.fdSystem_User_List.User_At(i);
        if Trim(user.usName) = '' then
          cmbUsers.AddItem(user.usCode, TObject(user.usLRN))
        else
          cmbUsers.AddItem(user.usName, TObject(user.usLRN));
        if CurrUser.Code = user.usCode then // Default it to the current user
          cmbUsers.ItemIndex := Pred(cmbUsers.Items.Count);
      end;
      if ShowModal = mrOk then
      begin
        if cmbUsers.ItemIndex = -1 then
          userLRN := 0
        else
          userLRN := Integer(cmbUsers.Items.Objects[cmbUsers.ItemIndex]);
        AddNewProspectRec(eCode.Text, eName.Text, eAddr1.Text,
          eAddr2.Text, eAddr3.Text, ePhone.Text, eFax.Text, eMobile.Text,
          eSal.Text, eMail.Text, eContact.Text, userLRN);
        RefreshLookup(eCode.Text);
      end;
    finally
      Free;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoDeleteProspect;
var
  Codes         : String;
begin
  if (ClientLookup.SelectionCount > 0) then
  begin
    Codes := ClientLookup.SelectedCodes;

    Self.Enabled := False;
    try
      if DeleteProspects(Codes) then
      begin
        pnlFrameHolder.Enabled := True; // Must be re-enabled in case filter needs resetting below
        Self.Enabled := True;
        RefreshLookup( '');
        UpdateFilter(Integer(cmbFilter.Items.Objects[cmbFilter.ItemIndex]));
      end;
    finally
      pnlFrameHolder.Enabled := True;
      Self.Enabled := True;
    end;
  end;
end;

//------------------------------------------------------------------------------
// Bulk Insert Prospects or Bulk Update Client Details
procedure TfrmClientManager.DoImportClientsProspects(ImportType: EImportType);
var
  Codes: string;
begin
  Codes := ClientLookup.SelectedCodes;
  with TfrmImportProspects.Create(Self) do
    try
      if ShowModal(ImportType) = mrOK then
      begin
        RefreshLookup(ClientLookup.FirstSelectedCode);
        ClientLookup.SelectedCodes := Codes;
      end;
    finally
      Free;
    end;
end;

//------------------------------------------------------------------------------
// Create an active client based on prospect details
procedure TfrmClientManager.DoConvertToBK;
var
  NewCode: string;
begin
  if CheckCodeExists(ClientLookup.FirstSelectedCode) then
  begin
    NewClientWiz.CreateClient(Self, true, ClientLookup.FirstSelectedCode);
    if Assigned( MyClient) then
      NewCode := MyClient.clFields.clCode
    else
      NewCode := '';
    CloseClientHomePage;
    RefreshLookup( NewCode);
  end;
end;

//------------------------------------------------------------------------------
// Filter has changed - update GUI as required
procedure TfrmClientManager.UpdateFilter(Id: Integer);
var
  SearchFor: Byte;
  i: Integer;
  RequireNewSubFilter: Boolean;
begin
  BeginUpdate;
  try
    RequireNewSubFilter :=  ((ClientLookup.ClientFilter = filterMyProspects) or (ClientLookup.ClientFilter = filterMyClients))
                        and ((Id = filterAllProspects) or (Id = filterAllClients));

    rzgProspects.Visible := (filterConfig[Id, 0] = ctProspect);

    rzgFileTasks.Visible := (filterConfig[Id, 0] = ctActive)
                         and (not FIsGlobal)
                         and (not rzgProspects.Visible);

    if (filterConfig[Id, 0] = ctProspect) then begin // Looking at prospects
       rzgDetails.Caption := 'Prospect Details';
       rzgCommunicate.Caption := 'Contact Prospects';
    end else begin // Looking at Clients
       rzgDetails.Caption := 'Client Details';
       rzgCommunicate.Caption := 'Contact Clients';
    end;

    btnFilter.Visible := (filterConfig[Id, 0] = ctActive)
                      and (not FIsGlobal) ;

    btnResetFilter.Visible := (filterConfig[Id, 0] = ctActive)
                           and (not FIsGlobal) ;

    if  ((Id = filterMyProspects) or (Id = filterAllProspects))
    and ((ClientLookup.ClientFilter = filterMyClients) or (ClientLookup.ClientFilter = filterAllClients)) then
    begin
      UpdateColumnINISettings;
      ClientLookup.SetColumnVisiblity(cluProcessing, False);
      ClientLookup.SetColumnVisiblity(cluStatus, False);
      ClientLookup.SetColumnVisiblity(cluReportingPeriod, False);
      ClientLookup.SetColumnVisiblity(cluSendBy, False);
      ClientLookup.SetColumnVisiblity(cluLastAccessed, False);
      ClientLookup.SetColumnVisiblity(cluGroup, False);
      ClientLookup.SetColumnVisiblity(cluClientType, False);
      ClientLookup.SetColumnVisiblity(cluNextGSTDue, False);
      BuildHeaderContextMenu;
    end
    else if ((Id = filterMyClients) or (Id = filterAllClients) {or (Id = filterMyArchived) or (Id = filterAllArchived)}) and
         ((ClientLookup.ClientFilter = filterMyProspects) or (ClientLookup.ClientFilter = filterAllProspects)) then
    begin
      ClientLookup.SetColumnVisiblity(cluProcessing, UserINI_CM_Column_Visible[ icid_Processing]);
      ClientLookup.SetColumnVisiblity(cluStatus, UserINI_CM_Column_Visible[ icid_Status]);
      ClientLookup.SetColumnVisiblity(cluReportingPeriod, UserINI_CM_Column_Visible[ icid_ReportingPeriod]);
      ClientLookup.SetColumnVisiblity(cluSendBy, UserINI_CM_Column_Visible[ icid_SendBy]);
      ClientLookup.SetColumnVisiblity(cluLastAccessed, UserINI_CM_Column_Visible[icid_LastAccessed]);
      ClientLookup.SetColumnVisiblity(cluGroup, UserINI_CM_Column_Visible[icid_Group]);
      ClientLookup.SetColumnVisiblity(cluClientType, UserINI_CM_Column_Visible[icid_ClientType]);
      ClientLookup.SetColumnVisiblity(cluNextGSTDue,  UserINI_CM_Column_Visible[icid_NextGSTDue]);
      BuildHeaderContextMenu;
    end;

    ClientLookup.ClientFilter := Id;
    if (Id = filterMyProspects) or (Id = filterMyClients) {or (Id = filterMyArchived)} then // View my files only
      ClientLookup.ViewMode := vmMyFiles
    else
      ClientLookup.ViewMode := vmAllFiles;

    ClientLookup.Reload;

    if (not IsGlobal) and RequireNewSubFilter then
    begin
      i := FCurrentUserFilter.IndexOf(CurrUser.Code);
      if (i > -1) and (FCurrentUserFilter.Count = 1) then
      begin
        FCurrentUserFilter.Delete(i);
        DoNewFilter(False);
      end;
    end;

  finally
    EndUpdate;
  end;          
  // Check if we have any clients to show
  if (filterConfig[Id, 2] = Byte(vmMyFiles))
  and (ClientLookup.vtClients.RootNodeCount = 0) then begin
     if (filterConfig[Id, 0] = ctProspect) then
        HelpfulInfoMsg( 'No Prospect Files have been assigned to your user code, switching back to All Prospects.',0)
     else
        HelpfulInfoMsg( 'No Client Files for your user code match the current filter, switching back to All Clients.',0);

    if Id = filterMyProspects then
       SearchFor := filterAllProspects
    else
       SearchFor := filterAllClients;
    // Need to search in case all filters are not displayed
    for i := 0 to Pred(cmbFilter.Items.Count) do begin
      if Integer(cmbFilter.Items.Objects[i]) = SearchFor then begin
         cmbFilter.ItemIndex := i;
         cmbFilterChange(Self);
         Break;
      end;
    end;
  end else if (not IsGlobal)
           and ((Id = filterMyClients) {or (Id = filterMyArchived)})
           and Assigned(FCurrentUserFilter)
           and (FCurrentUserFilter.IndexOf(CurrUser.Code) = -1) then begin
    FCurrentUserFilter.Add(CurrUser.Code);
    DoNewFilter(False);
  end;


  //UpdateClientCountLabel;
  UpdateINI;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.cmbFilterChange(Sender: TObject);
begin
  UpdateFilter(Integer(cmbFilter.Items.Objects[cmbFilter.ItemIndex]));
  RefreshLookup(ClientLookup.FirstSelectedCode);
  if pnlFrameHolder.Enabled then
    try
    ClientLookup.SetFocusToGrid;
    except
    end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.btnFilterClick(Sender: TObject);
begin
  DoNewFilter(True);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoNewFilter(ShowForm: Boolean);
var
  p: TPoint;
  s: string;
  h: Integer;
  i: UInt64;
 // FilterChanged: Boolean;
  function FilterNotBlank: Boolean;
  begin
     Result := True;
     if FCurrentUserFilter.Count > 0 then
        Exit;
     if FCurrentGroupFilter.Count > 0 then
        Exit;
     if FCurrentClientTypeFilter.Count > 0 then
        Exit;
     if FCurrentClientTypeFilter.Count > 0 then
        Exit;
     if ClientLookup.SubFilter <> 0 then
        Exit;
     Result := False;
  end;
begin
  if not assigned(CurrUser)  then exit;

 // FilterChanged := False;
  h := pnlFrameHolder.Height;
  p.X := pnlFrameHolder.Left;
  p.Y := pnlFrameHolder.Top;
  if pnlLegend.Visible then
    h := h - pnlLegend.Height
  else
    p.Y := p.Y - pnlLegend.Height;
  p := pnlFrameHolder.ClientToScreen(p);
  s := btnFilter.Hint;
  i := ChooseCMFilter(p, pnlFrameHolder.Width, h, ClientLookup.SubFilter, s,
         FCurrentUserFilter, FCurrentGroupFilter, FCurrentClientTypeFilter, ShowForm);

  BeginUpdate;
  try
    btnFilter.Hint:= s;
    ClientLookup.SubFilter := i;
    ClientLookup.UserFilter := FCurrentUserFilter;
    ClientLookup.GroupFilter := FCurrentGroupFilter;
    ClientLookup.ClientTypeFilter := FCurrentClientTypeFilter;
    ClientLookup.Reload;
    //UpdateClientCountLabel;
    btnResetFilter.Enabled := FilterNotBlank;
  finally
    EndUpdate;
  end;

  if (ClientLookup.vtClients.RootNodeCount = 0) and (AdminSystem.fdSystem_Client_File_List.ItemCount > 0) then
    HelpfulInfoMsg( 'No Client Files match the current filter.',0);
  UpdateINI;

end;

procedure TfrmClientManager.SetBlopiClientNew(const Value: TBloClientCreate);
begin
  FBlopiClient.ClientNew := Value;
end;

//------------------------------------------------------------------------------
// Set the user status for opening CM on opening BK5

procedure TfrmClientManager.SetShowLegend(const Value: Boolean);
begin
   FShowLegend := Value;
   if FShowLegend then
   begin
      actShowLegend.ImageIndex := 21;
      //rzgOptions.Items[2].ImageIndex := 21;
   end
   else
   begin
      actShowLegend.ImageIndex := 22;
      //rzgOptions.Items[2].ImageIndex := 22;
   end;

   UserINI_CM_ShowLegend := FShowLegend;
   pnlLegend.Visible := FShowLegend;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.SetUser;
var CanSendFilesOffsite : boolean;
  i, p: Integer;
  s: string;
  d: TDateTime;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter SetUser');

  //turn off any action the user is not allowed to do
  if not Assigned(ClientLookup) then
     Exit; // Will showup in the log
        actNewFile.Visible  := CurrUser.CanAccessAdmin;
        actDownload.Visible := CurrUser.CanAccessAdmin;

        CanSendFilesOffsite   := CurrUser.CanAccessAdmin or ( not PRACINI_OSAdminOnly);
        actCheckIn.Visible    := CanSendFilesOffsite;
        if (Assigned(AdminSystem)) then begin
           actCheckOut.Visible := CanSendFilesOffsite;
           actCAF.Visible := (AdminSystem.fdFields.fdCountry in [whAustralia, whUK]);
           actICAF.Visible := (AdminSystem.fdFields.fdCountry = whUK);
           actTPA.Visible := (AdminSystem.fdFields.fdCountry = whNewZealand);
        end else begin
           actCheckOut.Enabled := INI_AllowCheckOut;
           actCAF.Visible := False;
           actICAF.Visible := False;
           actTPA.Visible := False;
        end;
        actDeleteFile.Visible := false;
        RzGroupGlobal.Visible := False;

        with ClientLookup do begin
           //add columns and build the grid
           ClearColumns;
           ResetIniColumnDefaults;

           AddCustomColumn( 'Code', 120, 0, cluCode);
           AddCustomColumn( 'Name', 200, 1, cluName);
           d := IncMonth(Date, -11);
           s := FormatDateTime('mmm yy', d) + ' to ' + FormatDateTime('mmm yy', Date);
           AddCustomColumn( s, 150, 2, cluProcessing);
           //Position and width actually set in INISettings when upgrading
           //so that it's added in the correct position after the processin column
           if Assigned(AdminSystem) then begin
             if (AdminSystem.fdFields.fdCountry = whUK) then
                AddCustomColumn( 'Next VAT Due', 100, 3, cluNextGSTDue)
             else if (AdminSystem.fdFields.fdCountry = whNewZealand) then
                AddCustomColumn( 'Next GST Due', 100, 3, cluNextGSTDue);
           end;

           AddCustomColumn( 'Action', 175, 4, cluAction);
           AddCustomColumn( 'Reminder Date', 100, 5, cluReminderDate);
           AddCustomColumn( 'Status', 120, 6, cluStatus);
           AddCustomColumn( 'User', 100, 7, cluUser);
           AddCustomColumn( 'Group', 100, 8, cluGroup);
           AddCustomColumn( 'Client Type', 100, 9, cluClientType);
           AddCustomColumn( 'Report Schedule', 100, 10, cluReportingPeriod);
           AddCustomColumn( 'Send By', 75, 11, cluSendBy);
           AddCustomColumn( 'Last Accessed', 75, 12, cluLastAccessed);

           Options := [ loShowNotesImage];

           BuildGrid( TClientLookupCol(UserINI_CM_SortColumn), TSortDirection(UserINI_CM_SortDescending));

           // Include default filters
           cmbFilter.Clear;
           for i := filterMin to filterMax do begin
              cmbFilter.Items.AddObject(filterNames[i], TObject(i));
              if UserINI_CM_Filter = i then // Set current filter
              begin
                 cmbFilter.ItemIndex := Pred(cmbFilter.Items.Count);
                 UpdateFilter(i);
              end;
           end;

           SelectMode := smMultiple;

           BuildHeaderContextMenu;

           { MH, functionality below not required but keep code in case }

           //is a client currently open then select that one by default
           //otherwise select the last item in the mru

           if Assigned( MyClient) then
              LocateCode(MyClient.clFields.clCode)
           else begin
              //find code of first MRU an position on that
              S := INI_MRUList[1];
              p := Pos(#9, S) - 1;
              If p <= 0 Then Begin
                 p := Length(S)
              End;
              S := Copy(S, 1, p);
              LocateCode( S);
           end;



        end;

        if Assigned(UserINI_CM_UserFilter) then begin
           btnFilter.Hint := UserINI_CM_SubFilter_Name;
           ClientLookup.SubFilter := UserINI_CM_SubFilter;
           FCurrentUserFilter.Text := UserINI_CM_UserFilter.Text;
           FCurrentGroupFilter.Text := UserINI_CM_GroupFilter.Text;
           FCurrentClientTypeFilter.Text := UserINI_CM_ClientTypeFilter.Text;
        end else begin // superuser
           btnFilter.Hint := FILTER_ALL;
           ClientLookup.SubFilter := 0;
           FCurrentUserFilter.Text := '';
           FCurrentGroupFilter.Text := '';
           FCurrentClientTypeFilter.Text := '';
        end;

        DoNewFilter(False);

        ShowLegend := UserINI_CM_ShowLegend;

        SelectionChanged(nil); // Force GUI update


   userSet := True;
   StartFocus := True;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit SetUser');
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.SetUserSet(const Value: Boolean);
begin
  FUserSet := Value;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.sgLegendDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);

  procedure DrawCellImgLED( Const LEDColor : Integer );
  Var
    R : TRect;
  Begin
    R := sgLegend.CellRect(ACol, ARow);
    R.Top := R.Top + 5;
    R.Left := R.Left + 5;
    R.Bottom := R.Top + 14;
    R.Right := R.Left + 8;
    sgLegend.Canvas.Brush.Color := LEDColor;
    sgLegend.Canvas.Pen.Color := clBtnShadow;
    sgLegend.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 4, 4);
  end;

  procedure DrawCentreText(S: string);
  begin
    DrawText(sgLegend.Canvas.Handle, PChar(S), -1, Rect, DT_SINGLELINE or DT_VCENTER or DT_LEFT);
  end;

begin
  case ACol of
    0: DrawCellImgLED(ColorNoData );
    1: DrawCentreText('No Data');
    2: DrawCellImgLED(ColorDownloaded );
    3: DrawCentreText('Available');
    4: DrawCellImgLED(ColorUncoded );
    5: DrawCentreText('Uncoded');
    6: DrawCellImgLED(ColorCoded );
    7: DrawCentreText('Coded');
    8: DrawCellImgLED(ColorFinalised );
    9: DrawCentreText('Finalised');
    10: DrawCellImgLED(ColorTransferred );
    11: DrawCentreText('Transferred');

  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.sgLegendSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  ClientLookup.SetFocusToGrid;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
var
  filter: Integer;
begin
  case Msg.CharCode of
    VK_INSERT:
      begin
        filter := Integer(cmbFilter.Items.Objects[cmbFilter.ItemIndex]);
        if (filterConfig[filter, 0] = ctProspect) then
          actNewProspect.Execute
        else if CurrUser.CanAccessAdmin then
          actNewFile.Execute;
        Handled := True;
      end;
    VK_DELETE:
      if not ebFind.Focused then begin
        filter := Integer(cmbFilter.Items.Objects[cmbFilter.ItemIndex]);
        if (filterConfig[filter, 0] = ctProspect) then
          actDeleteProspect.Execute
        else if FIsGlobal then
          actDeleteFile.Execute;
        Handled := True;
      end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actSendExecute(Sender: TObject);
begin
  ProcessModalCommand( cm_mcSend);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actSendOnlineExecute(Sender: TObject);
begin
  ProcessModalCommand(cm_mcSendOnline);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.ActShowInstitutionsExecute(Sender: TObject);
var link: String;
begin
  case AdminSystem.fdFields.fdCountry of
    whNewZealand: link := Globals.PRACINI_InstListLinkNZ;
    whAustralia : link := Globals.PRACINI_InstListLinkAU;
    whUK        : link := Globals.PRACINI_InstListLinkUK;
  end;

  if length(link) = 0 then exit;
  ShellExecute(0, 'open', PChar(link), nil, nil, SW_NORMAL);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoSendViaEmail;
var
  Code, Codes, Recipient : string;
  SysClientRec : pClient_File_Rec;
begin
  Codes := ClientLookup.SelectedCodes;
  if Codes <> '' then
  begin
    // use first email as recipient
    Code := ClientLookup.FirstSelectedCode;
    sysClientRec := ClientLookup.AdminSnapshot.fdSystem_Client_File_List.FindCode( Code);
    if Assigned( sysClientRec) then
    begin
      ClientDetailsCache.Load( sysClientRec.cfLRN);
      Recipient := ClientDetailsCache.Email_Address;
    end
    else
      Recipient := '';
    SendClientFileTo(Recipient, Codes);
    RefreshLookup( '');
    ClientLookup.SelectedCodes := Codes;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.DoSendViaOnline;
var
  Codes : string;
  FirstUpload: Boolean;
  FlagReadOnly, EditEmail, SendEmail: Boolean;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter DoSendOnline');

  //BankLink Online transfer
  Codes := CheckInOutFrm.SelectCodesToSend('Select Client(s) to Send via ' + BANKLINK_ONLINE_NAME,
                                           ftmOnline, FirstUpload,
                                           FlagReadOnly, EditEmail, SendEmail,
                                           ClientLookup.SelectedCodes);
  if Codes <> '' then
    Files.SendClientFiles(Codes, ftmOnline, FirstUpload, FlagReadOnly, EditEmail, SendEmail);

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit DoSendOnline');
end;

//------------------------------------------------------------------------------
function TfrmClientManager.GetSelectedEmail: string;
var
  SysClientRec : pClient_File_Rec;
begin
  Result := '';
  if ClientLookup.SelectionCount = 1 then
  begin
    sysClientRec := ClientLookup.AdminSnapshot.fdSystem_Client_File_List.FindCode(ClientLookup.FirstSelectedCode);
    if Assigned( sysClientRec) then
    begin
      ClientDetailsCache.Load( sysClientRec.cfLRN);
      Result := ClientDetailsCache.Email_Address;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actCAFExecute(Sender: TObject);
var
  aForm: TfrmCAF;
  InstitutionForm: TfrmSelectInstitution;
begin
  case AdminSystem.fdFields.fdCountry of
    whAustralia:
      begin
        aForm := TfrmCAF.Create(Application.MainForm);
        with aForm do
        begin
          try
            if IsTaskbarHorizontal then
            begin
              Height := Application.MainForm.Monitor.WorkareaRect.Bottom - Application.MainForm.Monitor.WorkareaRect.Top - GetTaskBarHeight;
            end
            else
            begin
              Height := Application.MainForm.Monitor.WorkareaRect.Bottom - Application.MainForm.Monitor.WorkareaRect.Top - GetTaskBarWidth;
            end;

            if Screen.DesktopWidth < 720 then
              Width := Screen.DesktopWidth
            else
              Width := 720;
            Top := 0;
            edtPractice.Text := AdminSystem.fdFields.fdBankLink_Code;
            edtAdvisors.Text := AdminSystem.fdFields.fdPractice_Name_for_Reports;
            cmbMonth.ItemIndex := 0;
            repeat
            begin
              ShowModal;
              case ButtonPressed of
                BTN_PREVIEW: DoCAFReport(aForm, rdScreen,  AFNormal);
                BTN_FILE   : DoCAFReport(aForm, rdFile,    AFNormal);
                BTN_PRINT  : DoCAFReport(aForm, rdPrinter, AFNormal);
                BTN_EMAIL  : DoCAFReport(aForm, rdFile,    AFEmail, GetSelectedEmail);
                BTN_IMPORT : DoCAFReport(aForm, rdFile,    AFImport);
                BTN_NONE   : Break;
              end;
            end;
            until ButtonPressed = BTN_NONE;
          finally
            Free;
          end;
        end;
      end;
    whUK:
      begin
        InstitutionForm := TfrmSelectInstitution.Create(Application.MainForm);
        try
          InstitutionForm.SetClientEmail(GetSelectedEmail);
          InstitutionForm.ShowModal;
        finally
          InstitutionForm.Free;
        end;
      end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.actTPAExecute(Sender: TObject);
var
  aForm: TfrmTPA;
begin
  aForm := TfrmTPA.Create(Application.MainForm);
  with aForm do
  begin
    try
      if IsTaskbarHorizontal then
      begin
        Height := Application.MainForm.Monitor.WorkareaRect.Bottom - Application.MainForm.Monitor.WorkareaRect.Top - GetTaskBarHeight;
      end
      else
      begin
        Height := Application.MainForm.Monitor.WorkareaRect.Bottom - Application.MainForm.Monitor.WorkareaRect.Top - GetTaskBarWidth;
      end;

      if Screen.DesktopWidth < 700 then
        Width := Screen.DesktopWidth
      else
        Width := 700;
      Top := 0;
      edtPractice.Text := AdminSystem.fdFields.fdBankLink_Code;
      edtAdvisors.Text := AdminSystem.fdFields.fdPractice_Name_for_Reports;
      cmbMonth.ItemIndex := 0;      
      cmbDay.ItemIndex := 0;
      repeat
      begin
        ShowModal;
        case ButtonPressed of
          BTN_PREVIEW: DoTPAReport(aForm, rdScreen,  AFNormal);
          BTN_FILE   : DoTPAReport(aForm, rdFile,    AFNormal);
          BTN_PRINT  : DoTPAReport(aForm, rdPrinter, AFNormal);
          BTN_EMAIL  : DoTPAReport(aForm, rdFile,    AFEmail, GetSelectedEmail);
          BTN_IMPORT : DoTPAReport(aForm, rdFile,    AFImport);
        end;
      end;
      until ButtonPressed = BTN_NONE;
    finally
      Free;
    end;
  end;                                           
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.ColumnMoved(Sender: TVTHeader; Column: TColumnIndex; OldPosition: Integer);
begin
  BuildHeaderContextMenu;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.UpdateActions;
begin
  inherited;

  if PRACINI_AutoUpdateProcessing then
     if ClientLookup.ProcessStatusUpdateNeeded then begin
        Merge32.RefreshAllProcessingStatistics(True);
        ClientLookup.ProcessStatusUpdateNeeded := False;
        PRACINI_AutoUpdateProcessing := False; // Only do this once See case 9466
     end;
   ClientLookup.UpdateActions;
   btnFind.Enabled := ebFind.Text > '';
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.UpdateClientCountLabel;
begin

  if ClientLookup.ClientCount = 1 then
    lblCount.Caption := IntToStr(ClientLookup.ClientCount) + ' Client Listed'
  else
    lblCount.Caption := IntToStr(ClientLookup.ClientCount) + ' Clients Listed';
end;

//------------------------------------------------------------------------------
procedure RefreshClientManager(Code: string = ''; Restore: Boolean = True);
begin

  if ApplicationIsTerminating or (not Assigned(AdminSystem)) then exit;
  if Assigned(CurrUser) and Assigned(AdminSystem) and CurrUser.HasRestrictedAccess then exit;
  if Assigned(GLClientManager) then
  begin
    if Code <> '' then
      GLClientManager.RefreshLookup(Code)
    else if GLClientManager.ClientLookup.SelectionCount = 1 then
      GLClientManager.RefreshLookup(GLClientManager.ClientLookup.FirstSelectedCode)
    else
      GLClientManager.RefreshLookup('');
//Mmaximized not required - seems to cause bug in case #14379
//    if restore then
//       GLClientManager.WindowState := wsMaximized;
  end;
end;

//------------------------------------------------------------------------------
procedure DisableClientManager;
begin
  if Assigned(GLCLientManager) then
  begin
    GLClientManager.Enabled := False;
    GLClientManager.ClientLookup.Enabled := False;
    GLClientManager.ClientLookup.vtClients.Enabled := False;
    GLClientManager.ClientLookup.vtClients.BeginUpdate;
  end;
end;

//------------------------------------------------------------------------------
procedure EnableClientManager;
begin
  if Assigned(GLClientManager) then
  begin
    GLClientManager.Enabled := True;
    GLClientManager.ClientLookup.Enabled := True;
    GLClientManager.ClientLookup.vtClients.Enabled := True;
    GLClientManager.ClientLookup.vtClients.EndUpdate;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.wmsyscommand(var msg: TWMSyscommand);
begin
  if (not FIsGlobal) and (((msg.CmdType and $FFF0) = SC_MINIMIZE) or
     ((msg.CmdType and $FFF0) = SC_RESTORE)) then
    exit
  else
    inherited;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManager.vtClientsHeaderMouseUp(Sender: TVTHeader; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  UpdateINI;
end;

//------------------------------------------------------------------------------
procedure ClientManagerCheckout;
begin
  if Assigned(GLClientManager) then
    GLClientManager.actCheckOutExecute(GLClientManager);
end;

//------------------------------------------------------------------------------
procedure ClientManagerSendOnline;
begin
  if Assigned(GLClientManager) then
    GLClientManager.actSendOnlineExecute(GLClientManager);
end;

//------------------------------------------------------------------------------
procedure ClientManagerSend;
begin
  if Assigned(GLClientManager) then
  begin
    GLClientManager.actSendExecute(GLClientManager);
    RefreshClientManager;
  end;
end;

//------------------------------------------------------------------------------
procedure SetDownloadAvailability(Status: Byte);
begin
  (*
  if Assigned(GLCLientManager) then
  begin
    if Status = THREAD_DATA_AVAILABLE then begin
       GLCLientManager.actDataAvailable.Visible := True;
       GLCLientManager.actDownload.Visible := False;
    end else if Status in [THREAD_NOT_ONLINE, THREAD_NO_DATA] then begin
       GLCLientManager.actDataAvailable.Visible := False;
       GLCLientManager.actDownload.Visible := True;
    end;
  end;
  *)
end;

//------------------------------------------------------------------------------
procedure UpdateClientManagerCaption(Title: string);
begin
  if Assigned(GLClientManager) then
    GLClientManager.Caption := Title + ' Clients';
end;

//------------------------------------------------------------------------------
function CheckOutEnabled: Boolean;
begin
  Result := False;
  if Assigned(GLClientManager) then
    Result := GLClientManager.actCheckOut.Enabled;
end;

//------------------------------------------------------------------------------
function SendFilesEnabled: Boolean;
begin
  Result := False;
  if Assigned(GLClientManager) then
    Result := GLClientManager.actsend.Enabled;
end;

//------------------------------------------------------------------------------
{ TfrmClientMaint }
constructor TfrmClientMaint.Create(AOwner: tComponent);
begin
   FormStyle := forms.fsNormal;
   Visible := false;
   inherited;
   //FormStyle := forms.fsNormal;
   WindowState := wsNormal;
   BorderIcons := [biSystemMenu,biMaximize];
   IsGlobal := True;
   Visible := false;
   actAssignBulkExport.Visible := BulkExtractFrm.CanBulkExtract;
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UnitName);
  GlfrmClientManagerUp := False;
  GLClientManager := nil;
end.


