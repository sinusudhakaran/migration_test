unit UpdateMF;
//Updates items on the main form

interface

uses
   forms,
   stdCtrls,
   CodingFormConst,
   budobj32,
   CodingFormCommands,
   BudgetFrm,
   baObj32,
   codingfrm;

procedure UpdateStatusMsg(msg : string);
procedure UpdateName;
procedure MsgBar(msg: string; waitCursor : boolean);
procedure UpdateMenus;
procedure UpdateSortByMenu;
procedure UpdateSystemMenus;
function  CloseMDIChildren (DoClientHomepage : Boolean = False) : Boolean;
procedure SelectNextMDI;
procedure SelectPreviousMDI;
procedure ReloadCodingScreens(DoUpdateRecMemCandidates: boolean = True);

procedure DisableMainForm;
procedure EnableMainForm;

procedure CloseCodingScreen(aBankAccount : tBank_Account);
procedure CloseBudgetScreen(abudget : tBudget);

procedure OpenCodingScreen(DF, DT: Integer; BA: TBank_Account; CodingOptions: TCodingOptions;
                           DoUpdateRecMemCandidates: boolean = True);

procedure DisplayMRU;
procedure AddToMRU( const FileCode, FileName : ShortString );

{handle mdi children}
function  MDIParentForm : TForm;

procedure DoClosingCodingForm;
procedure DoActivateCodingForm;
procedure DoDeactivateCodingForm;
procedure DoActivateClientHomepage;
procedure SendCmdToAllCodingWindows( command : TExternalCmd);
function  AccountVisible(Acct : TBank_Account) : boolean;
function  CodingWindowLoaded : boolean;
procedure CodingWindowFocus(ActiveForm: TForm);
procedure BudgetWindowFocus(ActiveForm: TForm);
function GetActiveForm: TForm;
procedure CloseAllCodingForms;

procedure DoClosingBudgetForm;
procedure DoActivateBudgetForm;
procedure DoDeactivateBudgetForm;
function  BudgetVisible( aBudget : Tbudget) : boolean;

function  MDIChildInEditState : boolean;

{routines that act on the main form}
procedure MFViewClick;
procedure MFSortClick;
procedure MFUnpresentedClick;

procedure LockMainForm;
procedure UnlockMainForm;

procedure DoResize;

//******************************************************************************
implementation
uses
   BulkExtractFrm,
   ClientManagerFrm,
   ClientHomePagefrm,
   Math,
   Classes,
   sysutils,
   controls,
   bkUtil32,
   menus,
   bkhelp,
   Windows,
   comctrls,
   Files,
   MainFrm,
   bkConst,
   Globals,
   clObj32,
   Admin32,
   Progress,
   Software,
   InfoMorefrm,
   ColFmtListObj,
   AppUserObj,
   BKDEFS,
   WinUtils,
   ImagesFrm,
   UBatchBase,
   baUtils,
   RzButton,
   CountryUtils,
   ReportDefs,
   SimpleUIOpenPageFrm,
   CFHead,
   BankLinkOnlineServices,
   ForexHelpers,
   bkProduct,
   bkBranding;

var
  ClosingAllMDIForms : boolean = false;
  MainFormLockCount  : integer = 0;


// Update main form images, version label and minimized icons
// Called by mdi children when they are minimized
procedure DoResize;
begin
  frmMain.FormResize(frmMain);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Close any MDI child forms
//   Result : True if all child windows were able to close, False if not.
//
function CloseMDIChildren(DoClientHomepage : Boolean = False): Boolean;
var
  i : integer;
begin
  ClosingAllMDIForms := True;
  try
    LockMainForm;
    for i := 0 to frmMain.MDIChildCount-1 do begin
      if not ((frmMain.MDIChildren[i] is TfrmClientManager) or (frmMain.MDIChildren[i] is TfrmSimpleUIOpen )) then
        if (not (frmMain.MDIChildren[i] is TBaseClientHomePage))
        or DoClientHomepage then
        begin
           if Assigned(frmMain.MDIChildren[i]) then
             frmMain.MDIChildren[i].close;
        end;
    end;
    Application.ProcessMessages;  //force update of MDI child counter,
                                  //allows forms to close
  finally
    ClosingAllMDIForms := False;
    UnlockMainForm;
  end;

  Result := (frmMain.MDIChildCount = 0)
         or ((frmMain.MDIChildren[0] is TBaseClientHomePage) and (not DoClientHomepage))
         or (frmMain.MDIChildren[0] is TfrmClientManager)
         or (frmMain.MDIChildren[0] is TfrmSimpleUIOpen );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CloseAllCodingForms;
//close any MDI child forms
var
  i : integer;
  AllDone : Boolean;
begin
  //make sure mdi forms are maximised first
  if frmMain.MDIChildCount > 1 then
    TForm( frmMain.MDIChildren[0]).WindowState := wsMaximized;
  Application.ProcessMessages;

  ClosingAllMDIForms := True;
  try
    LockMainForm;
    repeat
        AllDone := True;
        for i := 0 to frmMain.MDIChildCount-1 do
           if (frmMain.MDIChildren[i] is TfrmCoding) then begin
              frmMain.MDIChildren[i].close;
              Application.ProcessMessages;  //force update of MDI child counter,
                                            //allows forms to close
              AllDone := False;
              Break; // Let the forms re-settle..
           end;
    until AllDone;


  finally
    ClosingAllMDIForms := False;
    UnlockMainForm;
  end;

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CloseCodingScreen(aBankAccount : tBank_Account);
//close the coding screen which is displaying the selected account
var i : integer;
begin
  for i := 0 to frmMain.MDIChildCount-1 do
     if (frmMain.MDIChildren[i] is TfrmCoding) and (aBankAccount = TfrmCoding(frmMain.MDIChildren[i]).Bank_Account) then
     begin
        TfrmCoding(frmMain.MDIChildren[i]).Close;
        Application.ProcessMessages;  //force update of MDI Child counter
        exit;
     end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ReloadCodingScreens(DoUpdateRecMemCandidates: boolean = True);
var
  i : integer;
  ActiveCaption : string;
begin
  ActiveCaption := '';
  for i := 0 to frmMain.MDIChildCount-1 do
  begin
    if TForm(frmMain.MDIChildren[i]).Active then
      ActiveCaption := TForm(frmMain.MDIChildren[i]).Caption;
  end;

  for i := 0 to frmMain.MDIChildCount-1 do
  begin
    if (frmMain.MDIChildren[i] is TfrmCoding) then
    begin
       TfrmCoding(frmMain.MDIChildren[i]).Reload(DoUpdateRecMemCandidates);
       Application.ProcessMessages;  //force update of MDI Child counter
    end else if (frmMain.MDIChildren[i] is TBaseClientHomePage) then
    begin
       TBaseClientHomePage(frmMain.MDIChildren[i]).RefreshRequest := [HPR_Coding];
       Application.ProcessMessages;  //force update of MDI Child counter
    end
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpdateStatusMsg(msg : string);
begin
   frmMain.MainStatus.Panels[1].Text := Msg;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpdateName;
var
  ClientCaption : string;
  NewCaption    : string;
begin
  if Assigned(MyClient) then
  begin
    ClientCaption := trim(MyClient.clFields.clCode)+ ' : '+ trim(MyClient.clFields.clName);
    if MyClient.clFields.clFile_Read_Only then
      ClientCaption := ClientCaption + ' (Read-Only)';

    if MyClient.clFields.clFile_Save_Required then
      ClientCaption := ClientCaption+' [modified]';

    NewCaption                    := APPTITLE +' ' +ClientCaption;
    frmMain.lblClientName.Caption := Myclient.clExtendedName;
  end
  else
  begin
    NewCaption                    := APPTITLE + '   <No Client Selected>';
    frmMain.lblClientName.Caption := 'No Client Selected';
  end;

  if GLOBALS.SuperUserLoggedIn then
     NewCaption := NewCaption + ' {Super User}';

  frmMain.Caption := NewCaption;

  frmMain.ReloadCustomLogo;
  frmMain.RedrawClientName;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure MsgBar(msg: string; waitCursor : boolean);
var
  UseCursor : TCursor;
begin
   if msg = '' then
      msg := 'Ready';

   msg := msg + '...';
   if waitCursor then
      UseCursor := crHourGlass
   else
      UseCursor := crDefault;
   Screen.Cursor  := UseCursor;
   frmMain.MainStatus.Panels[PANELMSG].text := msg;
   frmMain.Refresh;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpdateSystemMenus;
var
  UserHasAdminAccess    : boolean;  // inidicate if the current user has admin access
  CheckInOutAllowed : boolean;
  IsOffsiteClient: boolean;
  NotRestrictedUser : boolean;
  UsingAdmin     : boolean;  //inidicates if there is an admin system
begin
  UsingAdmin := Assigned( AdminSystem);

  with frmMain do
  begin
    if Assigned(myClient) then
       IsOffsiteClient := not (MyClient.clFields.clDownload_From = dlAdminSystem)
    else
       IsOffsiteClient := false;

    mniExtractBulkData.Visible := BulkExtractFrm.CanBulkExtract;
    //system access?
    if Assigned(CurrUser) then begin
      UserHasAdminAccess    := CurrUser.CanAccessAdmin and UsingAdmin;
      CheckInOutAllowed := ( UserHasAdminAccess or (not PRACINI_OSAdminOnly) or ((not UsingAdmin) and (not PRACINI_DisableCheckInCheckOut)));
    end
    else begin
      UserHasAdminAccess    := false;
      CheckInOutAllowed := false;
    end;

    //system access required
    mnsSystem.visible        := UserHasAdminAccess;
    mniFileNew.enabled       := UserHasAdminAccess;

    if Assigned( AdminSystem) then begin
       case AdminSystem.fdFields.fdCountry of
       whNewZealand,whUK  :    mniSystemGSTDefaults.Caption := 'Practice &'+whTaxSystemNamesUC[ AdminSystem.fdFields.fdCountry ]+ ' Defaults';
       whAUstralia:   mniSystemGSTDefaults.Caption := 'Practice &Tax Defaults'; // Is actaualy Company tax rather than GST
       end;
    end;

    //check in/out send to
    if Assigned(AdminSystem) then
    begin
      mniSendClientFiles.enabled := CheckInOutAllowed;
      tbSendClientFiles.enabled := CheckInOutAllowed;
    end else
    begin
      mniSendClientFiles.Enabled := (not PRACINI_DisableCheckInCheckOut);
      tbSendClientFiles.Enabled := (not PRACINI_DisableCheckInCheckOut);
    end;
    mniFileCheckIn.enabled       := CheckInOutAllowed;
    tbGetClientFiles.enabled            := CheckInOutAllowed;

    //Purge Entries - Client
    mniOFPurgeOldEntries.enabled := UserHasAdminAccess or IsOffsiteClient;

    //Transfer entries from temp accounts
    mniTransferEntries.enabled   := UserHasAdminAccess;

    //System Reports
    mniClientFileAccessReport.Visible := True;

    //Update menus for restricted user
    if Assigned( CurrUser) then
       NotRestrictedUser := not CurrUser.HasRestrictedAccess
    else
       NotRestrictedUser := true;

    //check-in extention plugin
    mniInstallCheckInExtn.Visible := (( not CheckInExtnDetected) and ( CheckInOutAllowed) and ( NotRestrictedUser)) and UsingAdmin;

    //File Menu
    mniFileNew.Visible              := NotRestrictedUser;
    mniFileSaveAs.Visible           := NotRestrictedUser;
    NA2.Visible                     := NotRestrictedUser;
//    mniFileSendTo.Visible           := NotRestrictedUser;
    NA4.Visible                     := NotRestrictedUser;
    mniSendClientFiles.Visible      := NotRestrictedUser;
    mniFileCheckIn.Visible          := NotRestrictedUser;

    //Reports Menu
    mniReportSchedule.Visible       := NotRestrictedUser and UsingAdmin;
    sepReportSchedule.Visible       := NotRestrictedUser and UsingAdmin;

    //Other functions menu

    mnsTemplates.Visible            := NotRestrictedUser;
    n16.Visible                     := NotRestrictedUser;
    mniOFRefreshChart.Visible       := NotRestrictedUser;
    {$IFNDEF SmartLink}
    mniOFExtractData.Visible        := NotRestrictedUser and (UsingAdmin or INI_BooksExtact);
    mniOFAccountingSystem.Visible   := NotRestrictedUser;
    mniOFRefreshChart.Visible       := NotRestrictedUser;
    {$ENDIF}
    n26.Visible                     := NotRestrictedUser;
    mnsExportBNoteFile.Visible      := NotRestrictedUser;
    mnsImportBNotes.Visible         := NotRestrictedUser;
    n17.Visible                     := NotRestrictedUser;
    mnsOFHouseKeeping.Visible       := NotRestrictedUser;

    if Assigned(AdminSystem) then
    begin
      mniExportWebX.Visible           := NotRestrictedUser and not ProductConfigService.ServiceSuspended;
      mniImportWebX.Visible           := NotRestrictedUser and not ProductConfigService.ServiceSuspended;
    end
    else
    begin
      mniExportWebX.Visible           := NotRestrictedUser;
      mniImportWebX.Visible           := NotRestrictedUser;
    end;

    //About Menu
    n4.Visible                      := NotRestrictedUser;
    EmailSupport1.Visible           := NotRestrictedUser;
    EmailSystemLog1.Visible         := NotRestrictedUser;
    n28.Visible                     := NotRestrictedUser;
    mniHelpViewSystemLog.Visible    := NotRestrictedUser;
    actTasks.Visible                := NotRestrictedUser;


    //File Toolbar
    tbGetClientFiles.Visible        := NotRestrictedUser;
    tbSendClientFiles.Visible       := NotRestrictedUser;
//    tbSendTo.Visible                := NotRestrictedUser;

    actClientManager.Visible        := UsingAdmin;
    actClientManager.Enabled        := actClientManager.Visible;

    mniStatistics.Visible        := PRACINI_ShowStatistics;

    if UsingAdmin then begin
       tbOpen.Caption := 'Clients';
       tbOpen.ImageIndex := 16;
       if NotRestrictedUser then
          tbOpen.Hint  :=
                'Open Clients (Shift+F12)|'
                +'Open Clients (Click the arrow for recently used files)'
       else
           tbOpen.Hint  :=
                  'Open a Client File (Shift+F12)|'
                  +'Open a Client File';
       mniFileOpen.Caption := 'C&lients';
       mniFileOpen.ImageIndex := 16;
       mniFileOpen.ShortCut := ShortCut(VK_F12, [ssShift]);
       mniOFPurgeOldEntries.Visible := True;
       // Report menu
       mniReportOption.Visible := False;
       n41.Visible := False;

    end else begin
       tbOpen.Caption := 'Open';
       tbOpen.ImageIndex := 1;
       tbOpen.Hint := 'Open a Client File';
       tbOpen.Hint  :=
                'Open a Client File|'
                +'Open a Client File (Click the arrow for recently used files)';
       mniFileOpen.Caption := '&Open';
       mniFileOpen.ImageIndex := 1;
       mniFileOpen.ShortCut := 0;
       mniFileNew.Visible := False;
       mniOFPurgeOldEntries.Visible := False;
       mniReportOption.Visible := True;
       n41.Visible := True;
    end;

    //override everything if simpleUI
    if Active_UI_Style = UIS_Simple then
    begin
      //disable items on main toolbar
      tbGetClientFiles.visible := false;
      tbSendClientFiles.visible := false;
      tbOnline.Visible := false;
      tbQuery.Visible := false;

      //turn on extra buttons for simpleUI
      tbClose.Visible := true;
      tbCodingClose.Visible := true;
      tbAbout.Visible := true;
      tbBudgetClose.Visible := true;

      //turn off the high level menu items
      mnsFile.Visible := false;
      mnsDataEntry.Visible := false;
      mnsReport.visible := false;
      mnsGraph.visible := false;
      mnsOtherfunctions.visible := false;
      mnssystem.Visible := false;
      mnsWindow.Visible := false;
      mnsHelp.Visible := false;
      mnsTest.Visible := false;
    end;

    //Audit Report
    mniSystemAuditReport.Visible := False;
    if Assigned( AdminSystem) then
      mniSystemAuditReport.Visible := (AdminSystem.fdFields.fdCountry = whUK);

    rztFile.PositionControls;
    bkArrangeToolBars;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpdateMenus;
var
  format: Integer;
  ClientFileOpen : boolean;
  RestrictedUser : boolean;
  UsingAdmin     : boolean;
  Country        : Byte;
  TaxName        : String;
  ShowFinReports : boolean;
  i: integer;
begin
  ClientFileOpen := Assigned(MyClient);
  UsingAdmin := Assigned(AdminSystem);

  if Assigned(CurrUser) then
     RestrictedUser := CurrUser.HasRestrictedAccess
  else
     RestrictedUser := false;

  if Assigned( MyClient ) then
    Country := MyClient.clFields.clCountry
  else
  if Assigned( AdminSystem ) then
    Country := AdminSystem.fdFields.fdCountry
  else
    Country := whNewZealand;

  TaxName := whTaxSystemNamesUC[ Country ];

  with frmMain do
  begin
     //File ToolBar
     tbSave.Enabled              := ClientFileOpen;
     tbHome.Enabled              := ClientFileOpen;

     mniBackup.Enabled           := ClientFileOpen;
     mniRestore.Enabled          := not ClientFileOpen;
     mniBackup.Visible           := not UsingAdmin;
     mniRestore.Visible          := not UsingAdmin;

     //Main menu
     mnsDataEntry.Enabled        := ClientFileOpen;
     mnsReport.Enabled           := ClientFileOpen;
     mnsGraph.Enabled            := ClientFileOpen;
     mnsOtherFunctions.enabled   := ClientFileOpen;


     {$B-}
     //Report Menu Items (Hide Financial Reports if Client Generate Reports set to False and no Admin System)
     ShowFinReports :=  (ClientFileOpen  //Client File is open
        and MyClient.clExtra.ceBook_Gen_Finance_Reports //Allow Generate Financial REports
        and not Assigned(AdminSystem))  //Books User
        or
        (
        ClientFileOpen  //Client File is open
          and Assigned(AdminSystem) //Practice User
        );
     mnsCashFlowReports.visible := ShowFinReports;


     mnsProfitabilityReports.visible := ShowFinReports;
     mnsTrialBalance.visible := ShowFinReports;
     mnsBalanceSheet.visible := ShowFinReports;


     //help
{$IFDEF CSVImport}
     mniImportFromCSV.Enabled   := ClientFileOpen;
{$ELSE}
     mniImportFromCSV.Enabled := false;
     mniImportFromCSV.Visible := false;
{$ENDIF}

     //File
     mniFileClose.Enabled            := ClientFileOpen;
     mniFileSave.Enabled             := ClientFileOpen;
     mniHome.Enabled                 := ClientFileOpen;
     mniFileSaveAs.Enabled           := ClientFileOpen;
     mniFileInformation.Enabled      := ClientFileOpen;
     mniFileAbandonChanges.Enabled   := ClientFileOpen;

     //Hide abandon changes for UK
     mniFileExchangeRates.Visible    := False;
     mniFileAbandonChanges.Visible   := True;
     if Assigned(AdminSystem) then
       mniFileAbandonChanges.Visible   := (AdminSystem.fdFields.fdCountry <> whUK)
     else if Assigned(MyClient) then begin
       mniFileAbandonChanges.Visible   := (MyClient.clFields.clCountry <> whUK);
       //Only show exchange rates menu option for Books if UK and is offsite client
       mniFileExchangeRates.Visible  := (MyClient.clFields.clCountry = whUK) and
                                        (MyClient.clFields.clDownload_From <> dlAdminSystem);
     end;

     if ClientFileOpen and ( MyClient.clFields.clFile_Read_Only) then
     begin
       tbSave.Enabled := false;
       mniFileabandonChanges.Enabled := False;
       mniFileSave.Enabled := false;
     end;


     mniAddManual.Enabled := ClientFileOpen and (BKUTIL32.CountManualBankAccounts > 0);
     mniCombineAccounts.Enabled := ClientFileOpen and CanBankAccountsBeCombined(MyClient.clBank_Account_List);
     mniCombineAccounts.Visible := Assigned(CurrUser) and CurrUser.CanAccessAdmin and UsingAdmin;
     mniCombineManual.Enabled := ClientFileOpen and CanManualBankAccountsBeCombined(MyClient.clBank_Account_List);
     mniCombineManual.Visible := Assigned(CurrUser) and CurrUser.CanAccessAdmin and UsingAdmin;

     // This can currently only be accessed from the coding screen
     N39.Visible := False;
     mniQuery.Visible := False;

     //Data Entry
     //mniYearEnd.Enabled := ClientFileOpen and MyClient.clFields.clBalance_Forward_Available;
     mniOpeningsBalanceJnls.Visible := PRACINI_ViewOpeningBalanceJournals or SuperUserLoggedIn;
     mniStockBalancesJnls.Visible := mniOpeningsBalanceJnls.Visible;

     mniDENTJGSTJournals.Caption        := '&' + TaxName + ' Journals';
     mnsGSTReports.Caption              := '&' + TaxName + ' Reports';
     mniGSTReturn.Caption               := TaxName + ' &Return';
     mniGSTAuditTrail.Caption           := TaxName + ' &Audit Trail';
     mniGSTSummary.Caption              := TaxName + ' &Summary';
     mniGSTAllocationSummary.Caption    := TaxName + ' Allocation Summary';
     mniGST12MonthSummary.Caption       := TaxName + ' Re&conciliation';
     GSTOverrides1.Caption              := TaxName + ' &Overrides';

     mniAnnualGSTReport.Caption         := 'Annual ' + TaxName + ' &Information Report';
     mniAnnualGSTReturn.Caption         := 'Annual ' + TaxName + ' R&eturn';
     mniGSTSetupReportOptions.Caption   := '&' + TaxName + ' Set Up';
     mniListGSTDetails.Caption          := 'List &' + TaxName + ' Details';

     tbGST.Caption := TaxName;
     tbGST.Hint  :=  Localise(Country, tbGST.Hint);


     mniOFGSTDetailsAndRates.Caption := '&'+TaxName + ' Set Up';

     mmiTaxablePaymentsReport.Visible := False;

     { Override ReportDefs Constants }

     REPORT_LIST_NAMES[ Report_GST101                 ]  := TaxName + ' Return';
     REPORT_LIST_NAMES[ Report_GST_Summary            ]  := TaxName + ' Summary';
     REPORT_LIST_NAMES[ Report_GST_allocationSummary  ]  := TaxName + ' Allocation Summary';
     REPORT_LIST_NAMES[ Report_GST_Summary_12         ]  := TaxName + ' Reconciliation';
     REPORT_LIST_NAMES[ Report_GST_Audit              ]  := TaxName + ' Audit';
     REPORT_LIST_NAMES[ Report_GST_Overrides          ]  := TaxName + ' Overrides';
     REPORT_LIST_NAMES[ Report_List_GST_Details       ]  := 'List ' + TaxName + ' Details';

     pltNames[ pltDollarAmt ] := whCurrencySymbols[ Country ];
     mltNames[ mltDollarAmt ] := whCurrencySymbols[ Country ];

     for i  := hdMin to hdMax do hdNames[ i ] := Localise( Country, hdNames[ i ] );

     //Other Functions
     if ClientFileOpen then begin
       if ( not assigned( AdminSystem ) ) and
          ( MyClient.clFields.clAccounting_System_Used in [ snMYOBOnlineLedger, saBGL360, saMYOBOnlineLedger ] ) then            // Books users may not Refresh Chart
         mniOFRefreshChart.Enabled := false
       else
         mniOFRefreshChart.Enabled  := not MyClient.clFields.clChart_Is_Locked and
           CanRefreshChart(MyClient.clFields.clCountry,
             MyClient.clFields.clAccounting_System_Used);
        mniRemapChart.Visible :=  (UsingAdmin xor RestrictedUser);
        if (MyClient.clFields.clFile_Read_Only) then
        begin
          mniOFExtractData.Enabled   := False;
          mnsExportBNoteFile.Enabled := False;
          mniExportWebX.Enabled      := False;
          mniRemapChart.Enabled      := False;
          mniImportWebX.Enabled      := False;
        end
        else
        begin
          mniOFExtractData.Enabled   := CanExtractData(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used);
          mnsExportBNoteFile.Enabled := True;
          mniRemapChart.Enabled      := True;

          if Assigned(AdminSystem) then
          begin
            mniExportWebX.Enabled      := not ProductConfigService.ServiceSuspended;
            mniImportWebX.Enabled      := not ProductConfigService.ServiceSuspended;
          end
          else
          begin
            mniExportWebX.Enabled      := True;
            mniImportWebX.Enabled      := True;         
          end;
        end;

        mniOFMemorisedEntries.Visible := UsingAdmin or (not  MyClient.clExtra.ceBlock_Client_Edit_Mems);
        tbMemorise.Visible :=  UsingAdmin or (not  MyClient.clExtra.ceBlock_Client_Edit_Mems);
        //rename gst report menu item for appropriate country
        case MyClient.clFields.clCountry of
           whNewZealand : begin
                             mniGSTReturn.Caption := 'GST &Return';
                             if PRACINI_PaperSmartBooks then
                               mniGSTAllocationSummary.Visible := True;
                          end;
           whAustralia  :
           begin
             mniGSTReturn.Caption := '&Business/Instalment Activity Statement';
             mmiTaxablePaymentsReport.Visible := True;
           end;
           whUK :
             Begin
               mniGSTReturn.Caption := 'VAT &Return';
               mniGSTAllocationSummary.Visible := False;
               mniGST12MonthSummary.Visible := False;
             End;
        end;
        //show business norms report menu item for AU
        mniBusinessNorms.Visible    := ( MyClient.clFields.clCountry = whAustralia);
        mniAnnualGSTreport.Visible  := ( MyClient.clFields.clCountry = whAustralia);
        mniAnnualGSTReturn.Visible  := ( MyClient.clFields.clCountry = whAustralia);
        N25.Visible                 := ( MyClient.clFields.clCountry = whAustralia);

        //Hide Templates menu for NZ
        mnsTemplates.Visible :=  ( MyClient.clFields.clCountry = whAustralia) and ( not RestrictedUser);
        mnsTemplates.Enabled := UsingAdmin;

        tbQuery.Visible := UsingAdmin;
        //mniRemapChart.Visible := PRACINI_AllowChartRemap;
        mniForexReport.Visible := ClientFileOpen and
                                  MyClient.HasForeignCurrencyAccounts;

     end;

{$IFNDEF SmartLink}
     mniResetFingerTipsLinks.Visible := false;
     N40.visible := false;
{$ENDIF}

     actTasks.Visible := UsingAdmin and ( not RestrictedUser);

     //toolbar
     if Globals.Active_UI_Style = UIS_Simple then
       rztClient.Visible := false
     else
       rztClient.Visible := ClientFileOpen;

     //offsite download
     if ClientFileOpen and (MyClient.clFields.clDownload_From <> dlAdminSystem) then begin
        mniOffsiteDownload.visible := true;
        mniOffsiteDownloadLog.visible := true;
        mniOffsiteDownload.enabled := not MyClient.clFields.clFile_Read_Only;
     end
     else begin
        mniOffsiteDownload.visible := false;
        mniOffsiteDownloadLog.visible := false;
     end;

     mniCheckForUpdates.Visible      := (not UsingAdmin) and ClientFileOpen;
     nUpdates.Visible                := mniCheckForUpdates.Visible;

     if (not UsingAdmin) then
     begin
       mniSendClientFiles.Enabled := (not PRACINI_DisableCheckInCheckOut);
     end;

     //only show if an admin system exists and allow flag is set
     mniTransferEntries.Visible := UsingAdmin;
     //No Find And Replace for Books
     mniFindandReplace.Visible := UsingAdmin;
     n44.Visible := UsingAdmin;

     //can client be synchronised
     if UsingAdmin then begin
        mniSyncroniseMyClient.visible := true;
        N21.visible := true;
        {
        if ( ClientFileOpen ) and ( CurrUser.CanAccessAdmin ) and
           //foreign file or offsite download
           (( MyClient.clFields.clMagic_Number <> AdminSystem.fdFields.fdMagic_Number) or ( MyClient.clFields.clDownload_From <> dlAdminSystem ))
        then
           mniSyncroniseMyClient.Enabled := true
        else
           mniSyncroniseMyClient.enabled := false;
         }
        //mjch: 1724 removed the above condition (AnyAccountIsInAdmin(MyClient)) and...
        //      as it prevents sync being done when admin system doesn't contain
        //      same bank accounts as the file being sync'ed
     end
     else begin
        mniSyncroniseMyClient.visible := false;
        N21.visible := false;
     end;

     tbOnline.Visible := ProductConfigService.OnLine;

     // Hide Web Export if no format selected or if OZ
     if ClientFileOpen then begin
        if MyClient.clFields.clWeb_Export_Format = 255 then
           MyClient.clFields.clWeb_Export_Format := wfDefault;

        if (MyClient.clFields.clWeb_Export_Format = wfNone) then begin
           mniExportWebX.Visible := False;
           mniImportWebX.Visible := False;
        end
        else
        begin
           if Assigned(AdminSystem) then
           begin
             mniExportWebX.Visible := (not RestrictedUser) and not ProductConfigService.ServiceSuspended;
             mniImportWebX.Visible := (not RestrictedUser) and not ProductConfigService.ServiceSuspended;
           end
           else
           begin
             mniExportWebX.Visible := (not RestrictedUser);
             mniImportWebX.Visible := (not RestrictedUser);
           end;
        end;
        // Change name depending on export format selected
        format := MyClient.clFields.clWeb_Export_Format;

        case format of
            wfWebX : begin
               // Acclipse has been bought by CCH, so we don't want the 'A' icon
               // mniExportwebX.ImageIndex := 19;
               // mniImportwebX.ImageIndex := 19;
               mniExportWebX.Caption := 'Export ' + wfNames[format] + ' File';
               mniImportWebX.Caption := 'Import ' + wfNames[format] + ' File';
            end;
            wfWebNotes : begin
               mniExportwebX.ImageIndex := 20;//31 not approved
               mniImportwebX.ImageIndex := 20;

               bkBranding.StyleECFHOnlineMenuItem(mniExportwebX);
               bkBranding.StyleECFHOnlineMenuItem(mniImportwebX);

               mniExportWebX.Caption := 'Export to ' + BRAND_NOTES_ONLINE;
               mniImportWebX.Caption := 'Import from ' + BRAND_NOTES_ONLINE;
            end;
            else begin
               mniExportwebX.ImageIndex := -1;
               mniImportwebX.ImageIndex := -1;
            end;
         end;
     end;


     // If offsite then hide import/export, unless switched on in INI
     if (not UsingAdmin) and (not PRACINI_ShowImportExportInOffsite) then
     begin
       mnsExportBNoteFile.Visible := False;
       mnsImportBNotes.Visible := False;
       mniExportWebX.Visible := False;
       mniImportWebX.Visible := False;
     end;

     //Hide menu options related to the Allow Client Unlock Entries option
     if (not UsingAdmin)
     and ClientFileOpen
     and (not MyClient.clExtra.ceAllow_Client_Unlock_Entries) then
     begin
        mniClearTransferFlags.Visible := false;
        SettheTransferFlagsforaPeriod1.Visible := false;
        mniDEFinalisePeriod.Visible := false;
        mniOFUnlockaFinalisedPeriod.Visible := false;
     end else begin
        mniClearTransferFlags.Visible := True;
        SettheTransferFlagsforaPeriod1.Visible := True;
        mniDEFinalisePeriod.Visible := True;
        mniOFUnlockaFinalisedPeriod.Visible := True;
     end;

     //Rebuild the dropdown popup menus so that reflect latest menus
     frmMain.RebuildPopups;

     if (ClientFileOpen) then
       UpdateSortByMenu;

     //toolbars
     if ClientFileOpen then
        frmMain.tbSuper.Visible := Software.CanUseSuperFundFields( MyClient.clFields.clCountry,
                                                                   MyClient.clFields.clAccounting_System_Used);

     //Get and send client file menu options
     actSendViaEmail.Enabled := True;

     if UsingAdmin then
     begin
       actSendToFile.Enabled := True;
     end
     else
     begin
       actSendToFile.Enabled := INI_AllowCheckOut;
     end;

     actSendViaOnline.Enabled := True;

     if UsingAdmin then
     begin
       actSendViaOnline.Visible := False;
       actGetFromOnline.Visible := False;
       
       UseBankLinkOnline := ProductConfigService.ServiceActive;
       
       if UseBankLinkOnline then
       begin
         if ProductConfigService.IsCICOEnabled then
         begin
           actSendViaOnline.Visible := True;
           actGetFromOnline.Visible := True;
         end;

         ProductConfigService.UpdateUserAllowOnlineSetting;
       end;
     end
     else if ClientFileOpen then
     begin
       actSendToFile.Enabled := (MyClient.clExtra.ceFile_Transfer_Method <> ftmOnline) and INI_AllowCheckOut;
       actSendViaEmail.Enabled := (MyClient.clExtra.ceFile_Transfer_Method <> ftmOnline);
       actSendViaOnline.Enabled := (MyClient.clExtra.ceFile_Transfer_Method = ftmOnline);
     end;

     if Assigned(CurrUser) then // Checking CurrUser in case the Practice window has been closed
       RefreshUserControls;

     Batchreports.FillMenu(frmMain.mniBatchReports,ShowFinReports);
     frmMain.MenuCopyToPopUp('mnsReport', popReport);

     mniExchangeGainLossWizard.Visible := IsForeignCurrencyClient;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpdateSortByMenu;

  procedure UpdateSortByVisible(CodingForm: TfrmCoding; i: Integer);
  var
    j  : integer;
    Found : Boolean;
    ColDefn : pColumnDefn;
  begin
    //popSortBy.items[i].Tag := csMin..csMax
    //The order of the columns in the coding form is not the
    //same as the sort by menu which is in csMin..csMax order.
    //Therefore the sort order on the column needs to match with
    //the Tag on the menu before the properties can be read.
    j := 0;
    Found := False;
    ColDefn := nil; //surpress compiler warning
    while (j < CodingForm.ColumnList.ItemCount) and (not Found) do
    begin
      ColDefn := CodingForm.ColumnList.ColumnDefn_At(j);
      if (ColDefn.cdSortOrder = frmMain.popSortBy.items[i].Tag) then
        Found := True
      else
        Inc(j);
    end;

    if (Found) then
    begin
      frmMain.popSortBy.items[ i].Visible := (not ColDefn.cdHidden);
      if (frmMain.popSortBy.items[ i].Tag = csChequeNumber) then
      begin
        //find csReference in popSortBy
        j := 0;
        while (j < frmMain.popSortBy.Items.Count)
        and (frmMain.popSortBy.items[j].Tag <> csReference) do
          Inc(j);
        if (j < frmMain.popSortBy.Items.Count) then
          frmMain.popSortBy.items[ j].Visible := (not ColDefn.cdHidden);
      end;
    end else begin
       // Added for Journals
       frmMain.popSortBy.items[ i].Visible := False;
    end;
  end;

  procedure HideJournalItems(Value : Boolean);
  begin
     frmMain.tbNew.Visible := not Value;
     frmMain.tbChart.Visible := Value;
     frmMain.tbPayee.Visible := Value;
     frmMain.tbJob.Visible := Value;
     frmMain.tbSuper.Visible := Value
                   // Only Trun it on if we need it..
                   and Software.CanUseSuperFundFields( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used);
     frmMain.tbMemorise.Visible := Value
                   and ( Assigned(AdminSystem) or (not  MyClient.clExtra.ceBlock_Client_Edit_Mems));
     frmMain.tbUPI.Visible := Value;
     frmMain.tbQuery.Visible := (Value and AdminExists);  

     if Value then begin
        frmMain.tbDissect.Caption := 'Dissect';
        frmMain.tbDissect.Hint  :=
                'Dissect a Transaction|'
                +'Dissect the transaction total over multiple chart codes';
     end else begin
        frmMain.tbDissect.Caption := 'Edit';
        frmMain.tbDissect.Hint  :=
                'Edit or View the Journal entries|'
                +'Edit or View the Journal entries';

     end;



     frmMain.rztCoding.PositionControls;
     frmMain.bkArrangeToolBars;

  end;

var
  i : integer;
  CodingForm : TfrmCoding;
begin
  //get the coding form handle,  note: the coding toolbar, which holds this
  //popup, will only be visible if a coding form is active
  if (frmMain.ActiveMDIChild is TfrmCoding) then
    CodingForm := TfrmCoding(frmMain.ActiveMDIChild)
  else
    Exit;

  if Assigned(CodingForm.ColumnList) then with frmMain do begin
     for i := 0 to (popSortBy.items.Count) -1 do begin
        UpdateSortByVisible(CodingForm, i);
     end;
     frmMain.tbFind.Down := CodingForm.SearchVisible;
  end;
  // While we are here..
  HideJournalItems(not CodingForm.IsJournal);

  if (Globals.Active_UI_Style = UIS_Simple) then
     frmMain.tbQuery.Visible := false;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CodingWindowLoaded : boolean;
//returns true if a coding form is currently loaded
var i : integer;
begin
  result := false;
  for i := 0 to frmMain.MDIChildCount-1 do
    if  frmMain.MDIChildren[i] is TfrmCoding then
    begin
      result := true;
      exit;
    end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//returns the current active MDI form or nil if nothing active
//the active form is always first in the list
function GetActiveForm: TForm;
begin
  Result := nil;
  if (frmMain.MDIChildCount > 0) then
    Result := frmMain.MDIChildren[0];
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CodingWindowFocus(ActiveForm: TForm);
// After autosave we need to refocus the coding form otherwise
// the selected cell may be lost or the cursor disappears from the edit (#1596)
//returns true if a coding form is currently loaded and has now been focused
var f: TfrmCoding;
    e: TEdit;
begin
 try // could be in the middle of this when the user closes the window
  f := TfrmCoding(ActiveForm);
  // First regain the focus
  f.SetFocus;
  // Now redraw the cell we were on
  f.tblCoding.AllowRedraw := False;
  f.tblCoding.InvalidateCell(f.tblCoding.ActiveRow, f.tblCoding.ActiveCol);
  f.tblCoding.AllowRedraw := True;
  // If a cell was being edited then move the cursor to the end of the current text
  case f.ColumnList.ColumnDefn_At(f.tblCoding.ActiveCol)^.cdFieldID of
    ceAccount:
      e := TEdit(f.celAccount.CellEditor);
    ceNarration:
      e := TEdit(f.celNarration.CellEditor);
    ceGSTClass:
      e := TEdit(f.celGSTCode.CellEditor);
    ceQuantity:
      e := TEdit(f.celQuantity.CellEditor);
    cePayee:
      e := TEdit(f.celPayee.CellEditor);
    else
      e := nil;
  end;
  if Assigned(e) then
    e.SelStart := e.GetTextLen;
 except
 end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure BudgetWindowFocus(ActiveForm: TForm);
// After autosave we need to refocus the budget form otherwise
// the selected cell may be lost or the cursor disappears from the edit (#1800)
//returns true if a budget form is currently loaded and has now been focused
var f: TfrmBudget;
    e: TEdit;
begin
 try // could be in the middle of this when the user closes the window
  f := TfrmBudget(ActiveForm);
  // First regain the focus
  f.SetFocus;
  // Now redraw the cell we were on
  f.tblBudget.AllowRedraw := False;
  f.tblBudget.InvalidateCell(f.tblBudget.ActiveRow, f.tblBudget.ActiveCol);
  f.tblBudget.AllowRedraw := True;
  // If a cell was being edited then move the cursor to the end of the current text
  if Assigned(f.tblBudget.Cells[f.tblBudget.ActiveRow, f.tblBudget.ActiveCol]) then
  begin
    e := TEdit(f.tblBudget.Cells[f.tblBudget.ActiveRow, f.tblBudget.ActiveCol].CellEditor);
    if Assigned(e) then
      e.SelStart := e.GetTextLen;
  end;
 except
 end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure MFViewClick;
var
  ClientP, ScreenP : TPoint;
begin
  with frmMain do
  begin
    ClientP.x := 0;
    ClientP.y := tbView.Height;
    ScreenP   := tbView.ClientToScreen(ClientP);
    popView.Popup(ScreenP.x, ScreenP.y);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure MFSortClick;
var
  ClientP, ScreenP : TPoint;
begin
  with frmMain do
  begin
    ClientP.x := 0;
    ClientP.y := tbSort.Height;
    ScreenP   := tbSort.ClientToScreen(ClientP);
    popSortBy.Popup(ScreenP.x, ScreenP.y);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure MFUnpresentedClick;
var
  ClientP, ScreenP : TPoint;
begin
  with frmMain do
  begin
   ClientP.x := 0;
   ClientP.y := tbUPI.Height;
   ScreenP   := tbUPI.ClientToScreen(ClientP);
   popUPI.Popup(Screenp.x, Screenp.y);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  MDIParentForm : TForm;
//provide the pointer to the MDI Parent form for this application
begin
   result := frmMain;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{if no coding windows are show then hide toolbar, if deactivated then disable toolbar}
procedure DoClosingCodingForm;
begin
  if ClosingAllMDIForms then
    exit;

  //auto save only occurs while a MDI child is showing, so check that an
  //auto save does not need to be done before closing the MDI form
  if frmMain.AutoSaveOutstanding then
    frmMain.TryAutoSave;

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoActivateCodingForm;
begin
  if ClosingAllMDIForms then exit;

  //UpdateSortByMenu;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoDeactivateCodingForm;
begin
  if ClosingAllMDIForms then exit;
end;

procedure DoActivateClientHomepage;
begin
   if ClosingAllMDIForms then exit;

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoClosingBudgetForm;
begin
  if ClosingAllMDIForms then
    exit;

  //auto save only occurs while a MDI child is showing, so check that an
  //auto save does not need to be done before closing the MDI child
  if (frmMain.AutoSaveOutstanding) then
    frmMain.TryAutoSave;

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoActivateBudgetForm;
begin
  if ClosingAllMDIForms then exit;


end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoDeactivateBudgetForm;
begin
  if ClosingAllMDIForms then exit;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CloseBudgetScreen(abudget : tBudget);
var
  i : integer;
begin
  for i := 0 to frmMain.MDIChildCount - 1 do    // Iterate
     if (frmMain.MDIChildren[i] is TfrmBudget) and (aBudget = TfrmBudget(frmMain.MDIChildren[i]).Budget) then
     begin
       frmMain.MDIChildren[i].close;
       Application.ProcessMessages;  //force update of MDI Child counter
       exit;
     end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DisplayMRU;
// MRU on File and on ToolBar Open Combo
// MRU List contains Code and Name
var
  i : Integer;
  p : Integer;
  S : String;
  NewItem : TMenuItem;
  MRUFrom, MRU_To : integer;
begin
  with frmMain do begin
     // File Menu
     // Clear items below MRUStart
     MRUFrom := mnsFile.IndexOf(MRUStart);
     MRU_To  := mnsFile.IndexOf(MRUEnd);
     for i := MRUFrom+1 to MRU_To-1 do
     begin
       NewItem := mnsFile[MRUFrom+1];
       mnsFile.Delete(MRUFrom+1);
       FreeAndNil(NewItem);
     end;
     MRUStart.visible := false;

     // Clear items from pop up
     with popOpen do begin
        while (Items.Count > 0) do
        begin
          NewItem := Items[0];
          Items.Delete(0);
          FreeAndNil(NewItem);
        end;
     end;

     if Assigned( CurrUser) then
        if CurrUser.HasRestrictedAccess then
        begin
           tbOpen.ToolStyle := tsButton;
           tbOpen.Width := 70;
           Exit;
        end;

     // Add items to menu, assumes values have been shuffled up
     for i := MAX_MRU downto 1 do begin
        if INI_MRUList[i] <> '' then begin
           MRUStart.visible := true;
           NewItem := TMenuItem.Create(mnsFile);
           // Extract Code
           S := INI_MRUList[i];
           p :=  pos( #9, S ) - 1;
           if p <= 0 then
              p := Length( S );
           S := Copy( S, 1, p );
           NewItem.Caption := '&'+inttostr(i)+' '+StringReplace(S, '&', '&&', [rfReplaceAll]);
           NewItem.OnClick := MRUStartClick;
           mnsFile.Insert(MRUFrom+1,NewItem);
        end;
     end;

     // Popup
     with popOpen do begin
        for i := 1 to MAX_MRU do begin
           if INI_MRUList[i] <> '' then begin
              NewItem := TMenuItem.Create(popOpen);
              NewItem.Caption := '&'+inttostr(i)+' '+StringReplace(INI_MRUList[i], '&', '&&', [rfReplaceAll]);
              NewItem.OnClick := MRUStartClick;
              popOpen.Items.Insert(i-1,NewItem);
           end;
        end;
     end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure AddToMRU( const FileCode, FileName : ShortString );

var
   NewFileCodes : array[ 1..MAX_MRU ] of ShortString;
   NewFileNames : array[ 1..MAX_MRU ] of ShortString;
   NewFileCount : Integer;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   
   procedure AddNewMRUItem( ACode, AName : ShortString );
   Var
      i     : Integer;
   Begin
      if ( ACode = '' ) then Exit;  // Code is Blank
      if not BKFileExists( DataDir + ACode + FILEEXTN ) then Exit; // File isn't there
      if ( NewFileCount = MAX_MRU ) then Exit; // List is Full

      for i := 1 to NewFileCount do
      Begin
         if NewFileCodes[ i ] = ACode then Exit; // Already in the list
      end;         
      
      Inc( NewFileCount );
      NewFileCodes[ NewFileCount ] := ACode;
      NewFileNames[ NewFileCount ] := AName;
   end;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   
   procedure ExtractMRUItem( S : ShortString; var ACode, AName : ShortString );
   Var
      p : Integer;
   Begin
      ACode := '';
      AName := '';
      if ( S<>'' ) then
      Begin
         p :=  pos( #9, S );
         if p > 0 then 
         Begin
            ACode := Copy( S, 1, p-1 );
            AName := Copy( S, p+1, 255 );
         end;
      end;
   end;

Var
   ACode : ShortString;
   AName : ShortString;
   i     : Integer;
begin
   // Clear out the new List
   for i := 1 to MAX_MRU do NewFileCodes[ i ] := '';
   for i := 1 to MAX_MRU do NewFileNames[ i ] := '';
   NewFileCount := 0;

   // Put the new file code and name at the top
   
   AddNewMRUItem( FileCode, FileName );

   // Add in the existing INI_MRUList data
   
   for i := 1 to MAX_MRU do
   Begin
      if INI_MRUList[ i ]<>'' then
      Begin
         ExtractMRUItem( INI_MRUList[i], ACode, AName );
         AddNewMRUItem( ACode, AName );
      end;
   end;

   // Put it all back into the INI_MRUList
   

   for i := 1 to MAX_MRU do INI_MRUList[i] := '';
   for i := 1 to NewFileCount do 
   Begin
      INI_MRUList[ i ] := NewFileCodes[ i ] + #09 + NewFileNames[ i ];
   end;

   // Update the menus.
   DisplayMRU;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SelectNextMDI;
begin
   frmMain.Next;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SelectPreviousMDI;
begin
   frmMain.Previous;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DisableMainForm;
begin
   frmMain.enabled :=false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure EnableMainForm;
begin
   frmMain.enabled := true;
end;



//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SendCmdToAllCodingWindows( command : TExternalCmd);
//send the same command to any coding windows that are loaded
var
  ChildIndex : integer;
begin
  if not Assigned(MyClient) then
    exit;
  for ChildIndex := 0 to frmMain.MDIChildCount - 1 do
  begin
    if (frmMain.MDIChildren[ChildIndex] is TfrmCoding) then
      TfrmCoding(frmMain.MDIChildren[ChildIndex]).ProcessExternalCmd( command)
    else if (frmMain.MDIChildren[ChildIndex] is TBaseClientHomePage) then
      TBaseClientHomePage(frmMain.MDIChildren[ChildIndex]).ProcessExternalCmd( command)
    else if (frmMain.MDIChildren[ChildIndex] is TFrmBudget) then
      TFrmBudget(frmMain.MDIChildren[ChildIndex]).ProcessExternalCmd( command);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AccountVisible(Acct : TBank_Account) : boolean;
var
  i : integer;
begin
   result := false;
   for i := 0 to frmMain.MDIChildCount - 1 do    // Iterate
   begin
        if (frmMain.MDIChildren[i] is TfrmCoding) and (Acct = TfrmCoding(frmMain.MDIChildren[i]).Bank_Account) then
           result := true;
   end;    // for
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function BudgetVisible( aBudget : Tbudget) : boolean;
{a copy of this procedure is in the budget lookup form also}
var
  i : integer;
begin
  result := false;
  for i := 0 to frmMain.MDIChildCount - 1 do    // Iterate
     if (frmMain.MDIChildren[i] is TfrmBudget) and (aBudget = TfrmBudget(frmMain.MDIChildren[i]).Budget) then
       result := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure LockMainForm;
begin
  if MainFormLockCount = 0 then
  begin
    Screen.Cursor   := crHourglass;
    LockWindowUpdate( frmMain.Handle);
  end;
  Inc( MainFormLockCount);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UnlockMainForm;
begin
  Dec( MainFormLockCount);
  if MainFormLockCount = 0 then
  begin
    LockWindowUpdate( 0);
    Screen.Cursor := crDefault;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  MDIChildInEditState
//
//  Detects if one of the MainForms child forms is in an editing state.
//
//  Returns:
//    True if a child form is currently being edited, False if not.
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MDIChildInEditState : boolean;
var
  i : integer;
begin
  Result := false;
  i := 0;
  while (not Result) and (i < frmMain.MDIChildCount) do // Iterate
  begin
    if (frmMain.MDIChildren[i] is TfrmCoding) then
      Result := TfrmCoding( frmMain.MDIChildren[i]).FormIsInEditMode
    else if (frmMain.MDIChildren[i] is TfrmBudget) then
      Result := TfrmBudget( frmMain.MDIChildren[i]).FormIsInEditMode;

    Inc(i);
  end; // while
end;

procedure OpenCodingScreen(DF, DT: Integer; BA: TBank_Account; CodingOptions: TCodingOptions;
                           DoUpdateRecMemCandidates: boolean = True);
begin
  CodeTheseEntries(DF, DT, BA, CodingOptions, DoUpdateRecMemCandidates);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
  //set up message bar callback
{$IFNDEF BK_UNITTESTINGON}
  Progress.OnUpdateMessageBar := MsgBar;
{$ENDIF}
end.
