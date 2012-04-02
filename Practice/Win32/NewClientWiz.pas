unit NewClientWiz;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, AuditMgr,
  OsFont;

type
  TOptionRec = Record
     Title     : String;
     Notes     : String;
     StepNo    : Integer;  //Step Number Assigned to this Option
     Visible   : Boolean;  //Display Option
     Available : Boolean;  //User can select option (ie If no BankAccounts then option not available)
     Complete  : Boolean;  //User has completed
  end;

  TOptions = ( opNewClient,
               opAccountSys,
               opGSTRate,
               opChart,
               opPayee,
               opBankAccount,
               opScheduledReports );

type
  TwizNewClient = class(TForm)
    btnQuit: TButton;
    Image1: TImage;
    lblTop: TLabel;
    lblNotes: TLabel;
    lblTitle: TLabel;
    pnlStep: TPanel;
    btnAccept: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

  private
    { Private declarations }
    StepLabel    : Array[ 0..Ord( High( TOptions ) ) ] of TLabel;
    StepButton   : Array[ 0..Ord( High( TOptions ) ) ] of TBitBtn;
    StepLight    : Array[ 0..Ord( High( TOptions ) ) ] of TImage;
    MouseStep    : TOptions; //Holds the Mouse move step
    IncBankAccounts : Boolean; //include bank accounts
    SystemAccounts: TStringList;
    FPCode : string;
    procedure Execute;
    procedure SetStepStatus;
    procedure AnyStepClick(Sender: TObject);  //Click method for all Step Buttons
    procedure AnyStepMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure CreateNewClient;
    function  AddClientToAdmin(LRN: Integer = -1; HasNotes: Boolean = False) : boolean;
  public
    { Public declarations }
    property PCode: string read FPCode write FPCode;
  end;


function CreateClient(w_PopupParent: TForm; DoBankAccounts : boolean; ProspectCode: string = ''): boolean;

//******************************************************************************
implementation

uses
  bkXPThemes,
  BKHelp,
  UBatchBase,
  ClientHomePageFrm,
  globals,clientdetailsfrm, acctsystemdlg, editgstdlg, MaintainChartfrm,
  MaintainPayeesFrm, updatemf, clobj32, YesNoDlg, files, admin32, Merge32,
  sycfIO, sydefs, bkconst, ovcDate, warningMoreFrm, ErrorMoreFrm, bkdefs,
  MaintainBankFrm, imagesfrm, Import32, glConst, LogUtil, baobj32,
  ClientReportScheduleDlg, ClientDetailCacheObj, GlobalClientSetupRoutines,
  ToDoHandler, ToDoListUnit, syamio, ClientManagerFrm,
  BanklinkOnlineSettingsFrm, BankLinkOnlineServices, InfoMoreFrm;

{$R *.DFM}

const
  UnitName = 'NewClientWiz';

var
  Option      : Array[ TOptions ] of TOptionRec = (
                ( Title    : 'Client Details';
                  Notes    : 'BankLink will take you through the steps to create a new '
                           + 'Client File.  Only Step 1 needs to be completed now.  All other steps '
                           + 'can be completed at a later stage.  Click Client Details to begin.';
                  Visible   : False;
                  Available : False;
                  Complete  : False  ),

                ( Title    : 'Accounting System';
                  Notes    : 'Specify the accounting system used and the location of the Client''s '
                           + 'Chart of Accounts in the accounting system.  If there is no direct '
                           + 'link between BankLink and the specified accounting system '
                           + 'the Load Chart From field will be disabled.  You can create a chart manually '
                           + 'in Step 4.';
                  Visible   : False;
                  Available : False;
                  Complete  : False  ),

                ( Title    : 'GST Set Up';
                  Notes    : 'Practice GST Rates are loaded into the Client File by default. '
                           + 'Enter the GST Reporting details.';
                  Visible   : False;  // Set by Practice options
                  Available : False;
                  Complete  : False  ),

                ( Title    : 'Chart of Accounts';
                  Notes    : 'Create a Chart of Accounts where there is no direct link to '
                           + 'your accounting system  Chart of Accounts.  You can copy a Chart '
                           + 'from an existing Client File.';
                  Visible   : False;
                  Available : False;
                  Complete  : False  ),

                ( Title    : 'Payees';
                  Notes    : 'Create a Payee List or copy a Payee List from an existing Client File.';
                  Visible   : False;
                  Available : False;
                  Complete  : False  ),

                ( Title    : 'Bank Accounts';
                  Notes    : 'This step is vital for accessing transactions and downloading new '
                           + 'transactions.  Attach all relevant Bank Accounts to this Client File.';
                  Visible   : False;
                  Available : False;  //Set if BankAccounts available
                  Complete  : False  ),

                ( Title    : 'Report Schedule';
                  Notes    : 'Set up the Report Schedule for this client.';
                  Visible  : False;
                  Available: False;
                  Complete : False )
                );


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CreateClient (w_PopupParent: TForm; DoBankAccounts : boolean; ProspectCode: string = ''): boolean;
// Note - This is not a Form Method
var
  pRec: pClient_File_Rec;
  LRN, i: Integer;
  HasNotes: Boolean;
  Msg : String;
  PraticeState : String;
begin
  result := false;
  if not RefreshAdmin then exit;

  if Assigned(MyClient) then
  begin
    //if AskYesNo('Setup New Client','You must close the client you are working '
    //         + 'on before creating a new Client.  Do you want to do this now?',DLG_YES,0) <> DLG_YES then
    //  exit;
    CloseClientHomePage;
  end;

  with TWizNewClient.Create(Application.mainForm) do begin
     try
       PopupParent := w_PopupParent;
       PopupMode := pmExplicit;
       
        PCode := ProspectCode;
        IncBankAccounts := DoBankAccounts;
        // Bank Accounts button available, not avail if entered thru Start New Month...
        Execute;
        ShowModal;
        Result := ( ModalResult = mrOK );
        if Result then
        begin
           if (MyClient.clFields.clWeb_Export_Format = wfWebNotes) then
           begin
             if (ProductConfigService.Online) and
                (ProductConfigService.IsPracticeActive(false)) then
             begin
               if TOptionRec(Option[opAccountSys]).Complete = false then
               begin
                 Msg := 'You have selected to use BankLink Notes Online for this client. ' +
                        'Please confirm the BankLink Online details for this client. ' +
                        #13#10 + #13#10 +
                        'The BankLink Online settings for this client will be displayed ' +
                        'at the end of this wizard.';
                 HelpfulInfoMsg(Msg, 0);
               end;
             end
             else
             begin
               if (ProductConfigService.Online = false) then
                 PraticeState := 'unavailable'
               else if (ProductConfigService.IsPracticeSuspended(false)) then
                 PraticeState := 'suspended'
               else if (ProductConfigService.IsPracticeDeactivated(false)) then
                 PraticeState := 'deactivated';

               Msg := 'BankLink Online is currently %s. The Web Export Format ' +
                      ' will be set to ''None''.';

               HelpfulInfoMsg(format(Msg,[PraticeState]), 0);

               MyClient.clFields.clWeb_Export_Format := wfNone;
             end;
           end;

           LogUtil.LogMsg( lmInfo, UnitName, 'CreateClient: ' + MyClient.clFields.clCode);
           if ProspectCode <> '' then
           begin
             // Set pRec again to avoid compiler warning
             pRec := AdminSystem.fdSystem_Client_File_List.FindCode(ProspectCode);
             LRN := pRec^.cfLRN;
             HasNotes := pRec^.cfHas_Client_Notes;
             DeleteProspects(ProspectCode, True, True);
           end
           else
           begin
             LRN := -1;
             HasNotes := False;
           end;
           if AddClientToAdmin(LRN, HasNotes) then begin
              SyncClientToAdmin( MyClient, False );
              MyClient.clFields.clUse_Minus_As_Lookup_Key  := MyClient.clChart.UseMinusAsLookup;
              MyClient.clFields.clLedger_Report_Show_Non_Trf := True;
              // Show contra summaries in ledger report by default
              MyClient.clFields.clLedger_Report_Bank_Contra := Byte(bcTotal);
              MyClient.clFields.clLedger_Report_GST_Contra := Byte(gcTotal);
              MyClient.clFields.clAll_EditMode_CES := PRACINI_DefaultCodeEntryMode = 0;
              MyClient.clFields.clAll_EditMode_DIS := PRACINI_DefaultDissectionMode = 0;
              for i := btMin to btMax do
                MyClient.clFields.clAll_EditMode_Journals[i] := True;

              //Flag Audit - need to audit everything that can be changed in
              //the new client wizard.
              MyClient.ClientAuditMgr.FlagAudit(arClientFiles);
              MyClient.ClientAuditMgr.FlagAudit(arChartOfAccounts);
              MyClient.ClientAuditMgr.FlagAudit(arPayees);

              SaveClient(false);
           end;
           if Assigned(MyClient) then
            RefreshClientManager(MyClient.clFields.clCode);
        end
        else begin
           if Assigned(MyClient) then begin
              MyClient.Free;
              MyClient := nil;
              BatchReports.XMLString := '';
           end;
        end;
        UpdateName;
        UpdateMenus;
        if ProspectCode <> '' then
          Files.CloseClient(False, False) //There is no client home page open for Prospects
        else
          ClientHomePageFrm.RefreshHomepage;
     finally
       Free;
     end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TwizNewClient.FormCreate(Sender: TObject);
var
  i: Integer;
  p: pSystem_Bank_Account_Rec;
  TaxName : String;
  Country : Byte;
begin
  Country := AdminSystem.fdFields.fdCountry;
  TaxName := whTaxSystemNamesUC[ Country ];

  bkXPThemes.ThemeForm( Self);
  lblTitle.Font.Name := Font.Name;
  lblTop.Font.Name := Font.Name;
  BKHelpSetUp(Self, BKH_Creating_a_client_in_BankLink_the_New_Client_Wizard);
  TOptionRec(Option[opNewClient]).Notes := SHORTAPPNAME +' will take you through the steps to create a new '
                           + 'Client File.  Only Step 1 needs to be completed now.  All other steps '
                           + 'can be completed at a later stage.  Click Client Details to begin.';
  TOptionRec(Option[opAccountSys]).Notes := 'Specify the accounting system used and the location of the Client''s '
                           + 'Chart of Accounts in the accounting system.  If there is no direct '
                           + 'link between ' + SHORTAPPNAME + ' and the specified accounting system '
                           + 'the Load Chart From field will be disabled.  You can create a chart manually '
                           + 'in Step 4.';
  TOptionRec(Option[opGSTRate]).Title := TaxName + ' Set Up';
  TOptionRec(Option[opGSTRate]).Notes := 'Practice ' + TaxName + ' Rates are loaded into the Client File by default. '
                                          + 'Enter the ' + TaxName + ' Reporting details.';

  FPCode := '';
  // Need to remember all bank account attach status so we can undo
  SystemAccounts := TStringList.Create;
  for i := 0 to Pred(AdminSystem.fdSystem_Bank_Account_List.ItemCount) do
  begin
    p := AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(i);
    if p.sbAttach_Required then
      SystemAccounts.AddObject(p.sbAccount_Number, TObject(1))
    else
      SystemAccounts.AddObject(p.sbAccount_Number, TObject(0));
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TwizNewClient.FormActivate(Sender: TObject);
begin
   SetStepStatus;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TwizNewClient.FormDestroy(Sender: TObject);
begin
  SystemAccounts.Free;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TwizNewClient.Execute;
const
   XStep   = 40;
   XOffset = 5;
   YLight  = 0;
   YLabel  = 25;
   YButton = 75;
var
   o : TOptions;
   i : Integer;
begin
   // Set Initial State
   for o := Low( TOptions ) to High( TOptions ) do begin
     if (IncBankAccounts) or ((not IncBankAccounts) and (o <> opBankAccount)) then
     begin
       with Option[ o ] do begin
         Visible   := True;
         Available := True;
         Complete  := False;
       end;
     end;
   end;

   // Set Lights, Labels and Buttons in Panel
   i := 0;
   for o := Low( TOptions ) to High( TOptions ) do begin
     if (IncBankAccounts) or ((not IncBankAccounts) and (o <> opBankAccount)) then
     begin
       with Option[ o ] do begin
         if Visible then begin
            StepNo := i; // Store Step Number in Option Array;
            StepLight[ i ] := TImage.Create( Self );
            with StepLight[ i ] do begin
              Parent  := pnlStep;
              Picture := AppImages.GreyLightBmp.Picture;
              Transparent := True;
              Left := YLight;
              Top  := ( XStep * i ) + XOffset;
            end;
            StepLabel[ i ] := TLabel.Create( Self );
            with StepLabel[ i ] do begin
              Parent  := pnlStep;
              Caption := Format( 'Step %d', [ i + 1 ] );
              Left := YLabel;
              Top  := ( XStep * i ) + XOffset;
            end;
            //StepButton is of type TBitBtn so the text can be left justified
            StepButton[ i ] := TBitBtn.Create( Self );
            with StepButton[ i ] do begin
              Parent  := pnlStep;
              Caption := Title;         //Option[ o ].Title
              Tag     := Ord( o );      //Set the Option in Tag;
              OnClick := AnyStepClick;  //Method Pointer
              OnMouseMove := AnyStepMouseMove;  //Method Pointer
              Width   := 180;
              Margin  := 5;
              Height  := 25;
              Left    := YButton;
              Top     := ( XStep * i );
            end;
            Inc( i );
         end;
       end;
     end;
   end;
   MouseStep := opBankAccount;
   AnyStepMouseMove( StepButton[ 0 ], [], 0, 0 );
   //StepButton[ Ord( opNewClient ) ].SetFocus; Speed Button can't have focus
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TwizNewClient.SetStepStatus;
// Enables buttons, sets light states etc
var
   o : TOptions;
   i : Integer;
begin
   for o := Low( TOptions ) to High( TOptions ) do begin
     if (IncBankAccounts) or ((not IncBankAccounts) and (o <> opBankAccount)) then
     begin
       with Option[ o ] do begin
         i := StepNo; //Held in Option Array

         //set visibility
         StepLight[i].visible  := Visible;
         StepButton[i].visible := Visible;
         StepLabel[i].visible  := Visible;

         if Visible then begin
            if Complete then begin
               with StepLight[i] do begin
                  Picture := AppImages.GreenLightBmp.Picture;
               end;
            end;
            // Enable/Disable Buttons
            with StepButton[i] do begin
               if ( o > opNewClient ) then begin
                  if  Available and ( Option[ opNewClient ].Complete ) then begin
                     Enabled := True;
                  end
                  else begin
                     Enabled := False;
                  end;
               end;
            end;
         end;
       end;
     end;
   end;
   if ( Option[ opNewClient ].Complete) and not ( btnAccept.Enabled) then begin
      btnAccept.Enabled :=true;
      btnAccept.SetFocus;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TwizNewClient.AnyStepClick(Sender: TObject);
//Click method for all Step Buttons - Assumes illegal option buttons disabled
//Tag field holds option
var
  AutoRefreshDone : Boolean;
  ContextID : Integer;
  pRec: pClient_File_Rec;
begin
   with ( Sender as TBitBtn ) do begin
      case TOptions( Tag ) of
         opNewClient  : begin
            if not Option[ opNewClient ].Complete then begin
               // Add New Client
               CreateNewClient;
               if FPCode <> '' then
               begin
                 pRec := AdminSystem.fdSystem_Client_File_List.FindCode(FPCode);
                 with ClientDetailsCache, MyClient.clFields do
                 begin
                   clCode := pRec^.cfFile_Code;
                   Load(pRec^.cfLRN);
                   clName := Name;
                   clAddress_L1 := Address_L1;
                   clAddress_L2 := Address_L2;
                   clAddress_L3 := Address_L3;
                   clContact_Name := Contact_Name;
                   clPhone_No := Phone_No;
                   clMobile_No := Mobile_No;
                   clSalutation := Salutation;
                   clFax_No := Fax_No;
                   clClient_EMail_Address := Email_Address;
                   clStaff_Member_LRN := pRec^.cfUser_Responsible;
                   clGroup_LRN := pRec^.cfGroup_LRN;
                   clClient_Type_LRN := pRec^.cfClient_Type_LRN;
                 end;
               end;
               if NewClientDetails(Self, FPCode, false) then begin
                  Option[ opNewClient ].Complete := True;
               end;
            end
            else begin
               // Edit existing New Client Details
               NewClientDetails(Self, FPCode, false);
            end;
         end;
         opAccountSys : begin
            if EditAccountingSystem(Self, AutoRefreshDone, BKH_Step_2_Accounting_System) then begin
               Option[ opAccountSys ].Complete := True;
               if (AutoRefreshDone) then
                 Option[ opChart ].Complete := True;
            end;
         end;
         opGSTRate    : begin
           if (MyClient.clFields.clCountry = whAustralia) then
             ContextID := BKH_Step_3_GST_set_up_Australia_
           else
             ContextID := BKH_Step_3_GST_set_up_New_Zealand_;
           if EditGstDetails(ContextID) then begin
             Option[ opGSTRate ].Complete := True;
           end;
         end;
         opChart      : begin
            if MaintainChart(True, BKH_Step_4_Chart_of_Accounts) then begin
               Option[ opChart ].Complete := True;
            end;
         end;
         opPayee      : begin
            if MaintainPayees(BKH_Step_5_Payees) then begin
               Option[ opPayee ].Complete := MyClient.clPayee_List.ItemCount > 0;
            end;
         end;
         opBankAccount : begin
            if MaintainBankAccounts(BKH_Step_6_Bank_Accounts) then begin
               Option[ opBankAccount ].Complete := True;
            end;
         end;
         opScheduledReports : begin
            if SetupClientSchedule(MyClient, BKH_Step_7_Report_Schedule) then begin
               Option[ opScheduledReports ].Complete := True;
            end;
         end;
      end;
   end;
   SetStepStatus
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TwizNewClient.AnyStepMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
   with ( Sender as TBitBtn ) do begin
      if not ( TOptions( Tag ) = MouseStep ) then begin
         MouseStep := TOptions( Tag );
         lblTitle.Caption := Option[ MouseStep ].Title;
         lblNotes.Caption := Option[ MouseStep ].Notes;
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TwizNewClient.AddClientToAdmin(LRN: Integer = -1; HasNotes: Boolean = False) : boolean;
const
   ThisMethodName = 'AddClientToAdmin';
var
  NewCF : pClient_File_Rec;
  ProspectsToDoList : TClientToDoList;
  pS: pSystem_Bank_Account_Rec;
  pM: pClient_Account_Map_Rec;
  i: Integer;
begin
   result := false;
   if not Assigned( MyClient) then exit;

   if LoadAdminSystem(true, ThisMethodName ) then
   begin
     {create a new client file record}
     NewCF := New_Client_File_Rec;

     with AdminSystem, NewCF^, MyClient.clFields do
     begin
       cfFile_Code           := clCode;
       cfFile_Name           := clName;
       cfFile_Type           := clFile_Type;
       cfFile_Status         := fsOpen;
       cfDate_Last_Accessed  := CurrentDate;
       cfFile_Save_Count     := 0;
       cfUser_Responsible    := clStaff_Member_LRN;
       cfGroup_LRN           := clGroup_LRN;
       cfClient_Type_LRN     := clClient_Type_LRN;
       cfCurrent_User        := CurrUser.LRN;

       if (Option[opAccountSys].Complete) then
          cfBulk_Extract_Code := clTemp_FRS_Job_To_Use // Temp Stored
       else
          cfBulk_Extract_Code  := fdFields.fdBulk_Export_Code; // Default Extract Code

       if (Option[opScheduledReports].Complete) then
          cfWebNotes_Email_Notifications := clTemp_FRS_From_Date // Temp Stored
       else
          cfWebNotes_Email_Notifications  := 0; // Default, Notify all

       {update the LRN}
       if LRN > -1 then
       begin
         cfLRN := LRN;
         cfHas_Client_Notes := HasNotes;
         ProspectsToDoList := TClientToDoList.Create( LRN);
         try
           SyncCFRecWithToDoList( NewCF, ProspectsToDoList);
         finally
          ProspectsToDoList.Free;
         end;
       end
       else
       begin
         Inc( fdFields.fdClient_File_LRN_Counter );
         cfLRN := fdFields.fdClient_File_LRN_Counter ;
       end;
     end;

     AdminSystem.fdSystem_Client_File_List.Insert(NewCF);

     // Update any accounts that were attached during the wizard
     for i := 0 to Pred(MyClient.clBank_Account_List.ItemCount) do
     begin
       pS := AdminSystem.fdSystem_Bank_Account_List.FindCode(MyClient.clBank_Account_List.Bank_Account_At(i).baFields.baBank_Account_Number);
       if Assigned(pS) and (not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindLRN(pS.sbLRN, NewCF.cfLRN))) then
       begin
         pM := New_Client_Account_Map_Rec;
         if Assigned(pM) then
         begin
           pM.amClient_LRN := NewCF.cfLRN;
           pM.amAccount_LRN := pS.sbLRN;
           pM.amLast_Date_Printed := 0;
           AdminSystem.fdSystem_Client_Account_Map.Insert(pM);
         end;
       end;
     end;

     //*** Flag Audit ***
     SystemAuditMgr.FlagAudit(arSystemClientFiles);
     SystemAuditMgr.FlagAudit(arAttachBankAccounts);

     SaveAdminSystem;

     result := true;
   end
   else
     HelpfulErrorMsg('Unable to update Client List at this time.  Admin system unavailable',0);

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TwizNewClient.CreateNewClient;
//- - - - - - - - - - - - - - - - - - - -
// Purpose:     Create a new client and do a basic sync-to-admin
//
// Parameters:
//
// Result:
//- - - - - - - - - - - - - - - - - - - -
var
   i,j : integer;
begin
   BatchReports.XMLString := '';

   MyClient := TClientObj.Create;
   if not assigned(MyClient) then
     Close;

   {now load default settings from admin system}
   with AdminSystem.fdFields, MyClient, clFields do
   begin
     {default client values}
     clPractice_Name                    := fdPractice_Name_for_Reports;
     clPractice_EMail_Address           := fdPractice_EMail_Address;
     clPractice_Web_Site                := fdPractice_Web_Site;
     clPractice_Phone                   := fdPractice_Phone;
     clCountry                          := fdCountry;
     clExtra.ceLocal_Currency_Code      := whCurrencyCodes[clCountry];
     clFile_Type                        := 0;  {banklink file}
     if fdAccounting_System_Used = asNone then begin
        // Use the super defaults
        clAccounting_System_Used := fdSuperfund_System;
        clAccount_Code_Mask      := fdSuperfund_Code_Mask;
        clLoad_Client_Files_From := fdLoad_Client_Super_Files_From;
        clSave_Client_Files_To   := fdSave_Client_Super_Files_To;
     end else begin
        clAccounting_System_Used := fdAccounting_System_Used;
        clAccount_Code_Mask      := fdAccount_Code_Mask;
        clLoad_Client_Files_From := fdLoad_Client_Files_From;
        clSave_Client_Files_To   := fdSave_Client_Files_To;
     end;
     clTemp_FRS_Job_To_Use              := AdminSystem.fdFields.fdBulk_Export_Code; // Use as temp Var
     clTemp_FRS_From_Date               := 0;// Use as temp Var
     clTax_Interface_Used               := fdTax_Interface_Used;
     clSave_Tax_Files_To                := fdSave_Tax_Files_To;
     clFinancial_Year_Starts            := 0;  //set to blank
     clSend_Coding_Report               := True;  //set this by default for new clients
     clEmail_Report_Format              := rfPDF;
     clWeb_Export_Format                := fdWeb_Export_Format;


     //Defaults for new client
     clExtra.ceAllow_Client_Edit_Chart := True;
     clExtra.ceAllow_Client_Unlock_Entries := True;

     //Set country for client audit
     MyClient.ClientAuditMgr.Country := clCountry;

     {matches client file to this admin system - VERY IMPORTANT}
     clMagic_Number                     := fdMagic_Number;

     {copy transaction types}
     for i := 0 to MAX_TRX_TYPE do
     begin
       clShort_Name[i] := fdShort_Name[i];
       clLong_Name[i]  := fdLong_Name[i];
     end;

     case clCountry of
        whNewZealand, whUK : begin  //AU systems use templates rather than gst defaults
           {copy default GST Rates Accross}
           for i := 1 to MAX_GST_CLASS_RATES do
              clGST_Applies_From[i] := fdGST_Applies_From[i];

           for i := 1 to MAX_GST_CLASS do begin
              clGST_Class_Codes[i]   := fdGST_Class_Codes[i];
              clGST_Class_Names[i]   := fdGST_Class_Names[i];
              clGST_Class_Types[i]   := fdGST_Class_Types[i];
              clGST_Account_Codes[i] := fdGST_Account_Codes[i];
              clGST_Business_Percent[i] := 0;  //not used for NZ but make sure zero anyway
           end;

           for i := 1 to MAX_GST_CLASS do
              for j := 1 to MAX_GST_CLASS_RATES do
                 clGST_Rates[i,j] := fdGST_Rates[i,j];
        end;
        whAustralia : with clExtra do begin
            // Copy the default tax rates
            for i := low(ceTAX_Applies_From) to High(ceTAX_Applies_From) do
             for j := low(ceTAX_Applies_From[i]) to High(ceTAX_Applies_From[i]) do begin
                ceTAX_Applies_From[i][j] := fdTAX_Applies_From[i][j];
                ceTAX_Rates[i][j] := fdTAX_Rates[i][j];
             end;
               
        end;
     end;
     //set gst include accruals to false, trouble is that is stored as exclude accruals
     clGST_Excludes_Accruals := true;
   end;  {with}
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TwizNewClient.FormShow(Sender: TObject);
begin
  Image1.Picture := imagesfrm.AppImages.imgBankLinkB.Picture;
end;

procedure TwizNewClient.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  i, x: Integer;
  ba: TBank_Account;
  p: pSystem_Bank_Account_Rec;
  Msg : String;
begin
  CanClose := True;

  if (ModalResult = mrOk) and
     (MyClient.clFields.clWeb_Export_Format = wfWebNotes) and
     (UseBankLinkOnline) and
     (ProductConfigService.GetOnlineClientIndex(MyClient.clFields.clCode) > -1) then
  begin
    Msg := 'A BankLink Online client with this client code already exists. ' +
           'Linking the BankLink Practice and BankLink Online clients cannot ' +
           'be undone. Are you sure you want to link this client file to the ' +
           'following BankLink Online client? (%s) - (%s)';

    if AskYesNo('New Client Wizard',
                format(Msg, [MyClient.clFields.clCode, MyClient.clFields.clName]),
                DLG_NO,
                0) <> DLG_YES then
    begin
      CanClose := False;
      Exit;
    end;
  end;


  if (ModalResult <> mrOk) and (Option[ opNewClient ].Complete) then
  begin
    if AskYesNo('New Client Wizard', 'Are you sure you want to cancel the New Client Wizard?' + #13#13 +
      'All steps of the set up will be lost and a new client will not be created.', DLG_NO, 0) = DLG_YES then
    begin
     if LoadAdminSystem(true, 'TwizNewClient.FormCloseQuery' ) then
     begin
      for i := 0 to Pred(MyClient.clBank_Account_List.ItemCount) do
      begin
        ba := MyClient.clBank_Account_List.Bank_Account_At(i);
        x := SystemAccounts.IndexOf(ba.baFields.baBank_Account_Number);
        if x > -1 then
        begin
          p := AdminSystem.fdSystem_Bank_Account_List.FindCode(ba.baFields.baBank_Account_Number);
          if Integer(SystemAccounts.Objects[x]) = 0 then
            p.sbAttach_Required := False
          else
            p.sbAttach_Required := True;
        end;
      end;
      //*** Flag Audit ***
      SystemAuditMgr.FlagAudit(arAttachBankAccounts);

      SaveAdminSystem;
      ModalResult := mrCancel;
     end
     else
      HelpfulErrorMsg('Unable to Cancel at this time - please re-try.  Admin System cannot be loaded',0);     
    end
    else
      CanClose := False;
  end;
end;

end.
