unit BulkExtractfrm;

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
  ExtCtrls, 
  StdCtrls, 
  DateSelectorFme, 
  osFont, 
  ClientSelectFme;

type
  TfrmBulkExtract = class(TForm)
    pBtn: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    pnlClientSelect: TPanel;
    pnlBulkExtract: TPanel;
    Label1: TLabel;
    cbExtractor: TComboBox;
    btnSetup: TButton;
    DateSelector: TfmeDateSelector;
    ClientSelect: TFmeClientSelect;
    ShapeBorder: TShape;
    procedure btnOKClick(Sender: TObject);
    procedure btnSetupClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    function Validate: Boolean; virtual;
  protected
     procedure UpdateActions; override;
  public
    Selected: TStringList;
  end;

  TfrmAssignBulkExtract = class(TfrmBulkExtract)
  private
    function Validate: Boolean; override;
  end;


function CanBulkExtract: Boolean;
function CouldBulkExtract: Boolean;

function DoBulkExtract(SelectedCodes: string; ClearExtract:Boolean): Boolean;
function AssignBulkExtract(SelectedCodes: string): Boolean;

// ComboBox handeling
function FillExtractorComboBox(Value: TComboBox; SelCode: string = ''; UnAssigned: Boolean = True): Boolean;
function GetComboBoxExtractorCode(Value: TComboBox): string;
function SelectExtractor(Code: string; ComboBox:TComboBox): Boolean;

procedure CleanupBulkExtract;

implementation

{$R *.dfm}

uses
   HTTPSConnector,
   software,
   BKUTIL32,
   Merge32,
   TransactionUtils,
   ExtractCommon,
   Contnrs,
   baObj32,
   clobj32,
   SyDefs,
   bkDefs,
   Admin32,
   AutoCode32,
   BulkExtractResult,
   imagesfrm,
   bkXPThemes,
   stDate,
   StDateSt,
   bkdateutils,
   BKconst,
   Files,
   progress,
   errorLog,
   InfoMoreFrm,
   YesNoDlg,
   EnterPwdDlg,
   ipscore,
   ipshttps,
   glConst,
   Globals,
   Winutils,
   SageHandisoftSuperConst,
   bkProduct,
   MoneyDef,
   GenUtils;

type

  TBulkExtractorLib = class; // Forward


   // Base Extractor
   // Represents one of the Indexed Extrators of a DLL
   TBulkExtractor = class(TObject)
   private
     FCode: string;
     FExtractClass: Integer;
     FDescription: string;
     FLibIndex: Integer;
     FBulkExtractorLib: TBulkExtractorLib;
     FAbortExtract: Boolean;
     FFields,
     FStatus: TStringList;
     FBankAccount: TBank_Account;
     FClient: TClientObj;
     //DllTestFields
     Ft_TransID,
     Ft_TransType,
     Ft_BankType,
     Ft_ClientType: Integer;

     FLineCount, //Transaction / Dissection Count
     FTransCount,
     FCodedCount,
     FAccountCount,
     FClientCount,
     FClientsSkipped: Integer;
     FCurrentBal: Money;
     FExtractDate: Integer;
     FSkipClient: Boolean;
     // Properties
     procedure SetCode(const Value: string);
     procedure SetDescription(const Value: string);
     procedure SetExtractClass(const Value: Integer);
     procedure SetLibIndex(const Value: Integer);
     procedure SetBankAccount(const Value: TBank_Account);
     procedure SetClient(const Value: TClientObj);
     procedure SetAbortExtract(const Value: Boolean);
     procedure SetSkipClient(const Value: Boolean);

     // Tests
     function IncludeTrans(Session: TExtractSession; aTrans: pTransaction_Rec; PreTest: Boolean): Boolean;
     function IncludeAccount(Session: TExtractSession; anAccount: TBank_Account; preTest: Boolean): Boolean;
     function CanConfig: Boolean;
     // DoBits
     function DoConfig: Boolean;
     function DoExport(var Session: TExtractSession; Extract: Integer; Data: string): Boolean;
     procedure CheckDllFeatures;
     // Lookups
     function LookupChart(const Value: string): string;
     function LookupTaxClass(const Value: integer; var Code, Desc: string ): boolean;
     function LookupJob(const Value: string): string;
     // Text conversions
     function AccountToText(anAccount: TBank_Account): string;
     function ClientToText(aClient: TClientObj): string;
     function TransactionToText(aTrans: pTransaction_Rec): string;
     function DissectionToText(const Index: Integer; aDiss: pDissection_Rec): string;
     function ClientStatustext(aClient: pClient_File_Rec): string;
     function SessionText(Session: TExtractSession): string;
     // Field helpers
     procedure AddField(const Name, Value: string);
     procedure AddNumberField(const Name: string; Value: Integer);
     procedure AddMoneyField(const Name: string; Value: Money);
     procedure AddDateField(const Name: string; Value: Integer);
     procedure AddQtyField(const Name: string; Value: Money);
     procedure AddBoolField(const Name: string; Value: Boolean);
     procedure AddFractionField(const Name: string; Value: Boolean);
     procedure AddCountryField(Value: Integer);
     // Superfund/Tax Helpers
     procedure AddBGLFields(Date, Component: Integer);
     procedure AddBGL360ComponentFields(Date, Component: Integer);
     procedure AddTaxFields(TaxAmount: Money; TaxClass: Integer);
     // Status helpers
     procedure AddStatus(const Value: string;const Log: Boolean = True);
     procedure ClearStatus;
   public
     constructor Create(ABulkExtractorLib: TBulkExtractorLib; Anindex, AClass: Integer; ACode, ADescription: string);
     destructor Destroy; override;

     function ExportClient(var Session: TExtractSession; var aClient: TClientObj):Boolean;
     function ExportAccount(var Session: TExtractSession; var anAccount: TBank_Account):Boolean;
     function ExportTrans(var Session: TExtractSession; aTrans: pTransaction_Rec):Boolean;
     function StartSession(var Session: TExtractSession): Boolean;
     function EndSession(var Session: TExtractSession): Boolean;
     procedure ReportSession(ClearExtract:Boolean);
     function NeedBankContra: Boolean;
     function NeedCoded: Boolean;

     property Code: string read FCode write SetCode;
     property LibIndex: Integer read FLibIndex write SetLibIndex;
     property Description: string read FDescription write SetDescription;
     property ExtractClass: Integer read FExtractClass write SetExtractClass;
     property BulkExtractorLib: TBulkExtractorLib read FBulkExtractorLib;
     property AbortExtract: Boolean read FAbortExtract write SetAbortExtract;
     property Client: TClientObj read FClient write SetClient;
     property BankAccount: TBank_Account read FBankAccount write SetBankAccount;
     property SkipClient: Boolean read FSkipClient write SetSkipClient;
   end;

   // Extractor DLL
   // It's a list of Base extractors, build up by interogating the Dll
   TBulkExtractorLib = class(TObjectList)
   private
     FLib: THandle;
     FVersion: Integer;
     FBulkExportProc : ProcBulkExport;
     FInitDone: Boolean;
     function GeTBulkExtractor(Index: Integer): TBulkExtractor;
   public

     constructor Create(ALib: THandle; AVersion: Integer);
     destructor Destroy; override;
     procedure CheckInit;
     property Version: Integer read FVersion;
     property Items[Index: Integer]: TBulkExtractor read GeTBulkExtractor;
   end;

   TAuthenticateResult= (arFailed, arCanExtract, arCannotExtract);

   // Extactor List
   // Has an internal List with all tle Dlls (LIbList)
   // Is a list of all all the Base Extractors
   // Is available as Singelton
   TBulkExtractors = class(TObjectList)
   private
      // HTTP Fields
      FHeaders: TStringList;

      // Extractor Fields
      FLibList: TObjectList;
      FExportLog: TSystemLog;

      // BulkExtractor methodes
      procedure AddLib(FileName: string);
      procedure FillLibList;
      function GeTBulkExtractor(Index: Integer): TBulkExtractor;
      function Authenticate: TAuthenticateResult;
      procedure InitSesssion;
   public
      CurSession: TExtractSession;
      constructor Create;
      destructor Destroy; override;
      function CanExtract: Boolean;
      procedure LogMessage(const Value: string);
      procedure LogError(const Action,Value: string);
      procedure FillComboBox(Value: TComboBox; UnAssigned: Boolean = True);
      function GetComboBoxExtractor(Value: TComboBox):TBulkExtractor;
      function SelectExtractor(Code: string; ComboBox:TComboBox): Boolean;
      property Items[Index: Integer]: TBulkExtractor read GeTBulkExtractor;
   end;


//******************************************************************************
//
//         Manage BulkExtractors Singelton
//
//******************************************************************************

var
  FBulkExtractors : TBulkExtractors;

function BulkExtractors : TBulkExtractors;
begin
   if not Assigned (FBulkExtractors) then
      FBulkExtractors:= TBulkExtractors.Create;
   Result :=  FBulkExtractors;
end;

procedure CleanupBulkExtract;
begin
   if Assigned (FBulkExtractors) then
      FBulkExtractors.Free;
   FBulkExtractors := nil;
end;

function CanBulkExtract;
begin
   Result := False;
   if not Assigned(AdminSystem) then
      Exit;
   RefreshAdmin;
   if not AdminSystem.fdFields.fdBulk_Export_Enabled then
      Exit;
   if BulkExtractors.Count < 1 then
      Exit;
   // Still here...
   Result := True;
end;

function CouldBulkExtract: Boolean;
begin
   Result := False;
   if not Assigned(AdminSystem) then
      Exit;

   if BulkExtractors.Count < 1 then
      Exit;
   // Still here...
   Result := True;
end;


//******************************************************************************
//
//        ComboBox Functions
//
//******************************************************************************

function FillExtractorComboBox(Value: TComboBox; SelCode: string = ''; UnAssigned: Boolean = True): Boolean;

begin
   BulkExtractors.FillComboBox(Value, UnAssigned);
   Result := BulkExtractors.SelectExtractor(SelCode, Value);
end;

function GetComboBoxExtractorCode(Value: TComboBox): string;
var lExtract: TBulkExtractor;
begin
   Result := '';
   lExtract := BulkExtractors.GetComboBoxExtractor(Value);
   if Assigned(LExtract) then
      Result := LExtract.Code;
end;

function SelectExtractor(Code: string; ComboBox:TComboBox): Boolean;
begin
   Result := BulkExtractors.SelectExtractor(Code,ComboBox);
end;


//******************************************************************************
//
//        Do the Bulk Extract
//
//******************************************************************************

function DoBulkExtract(SelectedCodes: string; ClearExtract:Boolean): Boolean;
var
   I: integer;
   LSessionStarted: Boolean;
   Extractor: TBulkExtractor;
   ProgressCaption: string;
   LSelected,
   LClients : TStringList;
   ClientSelectOptions: TClientSelectOptions;

   function CheckSession: Boolean;
   begin
      Result := True;
      if not LSessionStarted then begin
         if ClearExtract then begin
            BulkExtractors.LogMessage('*************  Bulk Clear Transfer Flags for ' + Extractor.SessionText(BulkExtractors.CurSession) );
            Extractor.ClearStatus;
         end else begin
            BulkExtractors.LogMessage('*************  Bulk Data Export for ' + Extractor.SessionText(BulkExtractors.CurSession) );
            Result := Extractor.StartSession(BulkExtractors.CurSession);
            if not Result then
               Extractor.AbortExtract := True;
         end;
         LSessionStarted := True; // try only once
      end;
   end;

   function GetSessionDetails: Boolean;
   var lDlg: TfrmBulkExtract;

       procedure Findparams;
       const
           FormatSwitch  = '/FORMAT=';
       var P: string;
           I,E: Integer;
       begin
          for i := 1 to ParamCount do begin
            p := Uppercase(ParamStr(i));
            if Pos(FormatSwitch, p) > 0 then begin
               //Format specified
               p := Trim(Copy(p, Pos(FormatSwitch, P) + Length(FormatSwitch),255));
               if p <> '' then begin
                  p := StringReplace(P,'_', ' ', [rfReplaceAll, rfIgnoreCase]);
                  for E := 0 to ldlg.cbExtractor.Items.Count - 1 do
                  if Assigned(ldlg.cbExtractor.Items.Objects[E])then begin
                     if Sametext(TBulkExtractor(ldlg.cbExtractor.Items.Objects[E]).FDescription,P) then begin
                        ldlg.cbExtractor.ItemIndex := E;
                        Break;
                     end;
                  end;
               end;
            end;// else ..any other params..
          end;
       end;

   begin // Run the selection dialog
      Result := False;
      lDlg := TfrmBulkExtract.Create(Application.MainForm);
      try
         FillExtractorComboBox (ldlg.cbExtractor,AdminSystem.fdFields.fdBulk_Export_Code ,False);
         // default to last month;
         if Globals.StartupParam_Action = sa_BulkExport then begin
            ldlg.DateSelector.eDateTo.AsStDate := CurrentDate;
            ldlg.DateSelector.eDateFrom.AsStDate :=  GetFirstDayOfMonth(IncDate(ldlg.DateSelector.eDateTo.AsStDate, 0, -1, 0));
         end else begin
            ldlg.DateSelector.eDateTo.AsStDate :=  GetLastDayOfMonth(IncDate(CurrentDate, 0, -1, 0));
            ldlg.DateSelector.eDateFrom.AsStDate :=  GetFirstDayOfMonth(ldlg.DateSelector.eDateTo.AsStDate);
         end;
         // Update the Dialog caption
         if ClearExtract then  begin
            lDlg.Caption := 'Bulk Clear Transfer Flags';
            lDlg.btnSetup.Visible := False; //Confusing for Clear
         end else begin
            lDlg.Caption := 'Bulk Data Export';
            Findparams;
         end;

         if (
               not ClearExtract
               and (Globals.StartupParam_Action = sa_BulkExport)
               and (ldlg.Validate)  // Is all OK
             )
         or (ldlg.ShowModal = mrOK) then begin  // Show the dialog..
            Extractor := BulkExtractors.GetComboBoxExtractor(lDlg.cbExtractor);
            BulkExtractors.CurSession.FromDate := ldlg.DateSelector.eDateFrom.AsStDate;
            BulkExtractors.CurSession.ToDate := ldlg.DateSelector.eDateTo.AsStDate;

            //Client selection options
            ClientSelectOptions.ReportSort := lDlg.ClientSelect.ReportSort;
            ClientSelectOptions.RangeOption := lDlg.ClientSelect.RangeOption;
            ClientSelectOptions.FromCode := lDlg.ClientSelect.edtFromCode.Text;
            ClientSelectOptions.ToCode := lDlg.ClientSelect.edtToCode.Text;
            ClientSelectOptions.CodeSelectionList.DelimitedText := lDlg.ClientSelect.edtSelection.Text;

            Result := True;
         end;
      finally
         ldlg.Free;
      end;
   end;

   function StartExtactList: boolean;
   var CFRec: pClient_File_Rec;
       I: integer;
   begin
      LClients.Clear;
      Result := False;
      if not assigned(Extractor) then
         Exit; //savety net..
      // While we are here...
      Extractor.CheckDllFeatures;

      if LoadAdminSystem(True,'BulkExtract') then try
         for I := AdminSystem.fdSystem_Client_File_List.First to AdminSystem.fdSystem_Client_File_List.Last do begin
         CFRec := AdminSystem.fdSystem_Client_File_List.Client_File_At(i);
         if CFRec.cfArchived then
            Continue; // Dont care much


         if Extractor.Code <> CFRec.cfBulk_Extract_Code then
            Continue; // Not in this extract...


         if Assigned(LSelected) then
            if LSelected.IndexOf(CFRec.cfFile_Code) < 0 then
               Continue; // Not Part of the selected ..

         if CFRec.cfFile_Status = fsnormal then begin
            // Assume we can proceeed
            CFRec.cfCurrent_User := CurrUser.LRN;
            CFRec.cfFile_Status := fsOpen;
            // Make a list of what we opened
            LClients.Add(CFRec.cfFile_Code);
            Result := True;// Have atleast one..
         end else begin
            Extractor.AddStatus(Extractor.ClientStatusText(CFRec));
            inc(Extractor.FClientsSkipped);
         end;
      end;
      finally
         if Result then
            SaveAdminSystem
         else
            UnlockAdmin;//Nothing to save...
      end;
   end;

   procedure ProcessClientFile(const Code: string);
   var CFRec: pClient_File_Rec;
       aClient: TClientObj;
       NeedAdminClose: Boolean;
       HasEntriesInPeriod: Boolean;
   begin
      CFRec := nil;
      NeedAdminClose := True;
      try try
         if Assigned(Extractor) then
         if not Extractor.AbortExtract then begin
            // Try this client
            aClient := nil;
            OpenaClientForRead(Code,aClient);
            if Assigned(aClient) then begin
               if ClientSelectOptions.ClientInSelection(Code) then begin
                   try
                    //Update non stored fields
                    aClient.clWas_Code := aClient.clFields.clCode; {so can detect a rename}
                    with aClient.clFields do begin
                       clFile_Name := Code;
                       clFile_Memory_Usage  := 0;
                       clFile_Load_Time     := 0;
                       clFile_Save_Required := False;
                       clFile_Read_Only     := False;
                    end;
                    if ClearExtract then begin
                       SetOrClearTransferFlags(Aclient,False,
                                                BulkExtractors.CurSession.FromDate,BulkExtractors.CurSession.ToDate,
                                                [btBank.. btStockBalances],
                                                HasEntriesInPeriod
                                              );
                       Inc(Extractor.FClientCount);
                    end else begin
                       // Could make these Extractor Dependant
                       // Strip out any master memorised entries if there is an admin system
                       SyncMasterMemorised(aClient);
                       MergeNewDataYN(aClient, True, False, False, True);

                          if (not Extractor.ExportClient(BulkExtractors.CurSession,aClient))
                          or (Extractor.AbortExtract) then
                             Exit; // Donot save this one..
                    end;
                    DoClientSave(True, aClient, True);
                    NeedAdminClose := False; //Updates Admin as well..
                  finally
                   aClient.Free;
                  end;
               end;
            end else begin
                Extractor.AddStatus( Format('Client file %s failed to open',[Code]));
                inc(Extractor.FClientsSkipped);
            end;

         end;
      except
         on E: Exception do begin
            Extractor.AddStatus( Format('Error %s'#13'Opening Client file %s',[e.Message,Code]));
         end;
      end;
      finally
         // Regardless of what happened, I have to update the Client file status
         if NeedAdminClose then begin
            if LoadAdminSystem(True,'BulkExtract') then
            try
               CFRec := AdminSystem.fdSystem_Client_File_List.FindCode(Code);
               if Assigned(CFRec) then begin
                  CFrec.cfCurrent_User := 0;
                  CFRec.cfFile_Status := fsNormal;
               end;
            finally
               if Assigned(CFRec) then
                  SaveAdminSystem
               else
                  UnlockAdmin;
            end;
         end;
      end;
   end;


begin //DoBulkExtract
   Result := False;
   //Makes sure we have the current list
   BulkExtractors.FillLibList;
   if ClearExtract then begin
      //While we are here...
      ProgressCaption := 'Clearing transfer flags for ';
   end else begin
      {$IFNDEF ExportTest}
      if not BulkExtractors.CanExtract then
         Exit;
      {$ENDIF}
      ProgressCaption := 'Exporting bulk data for ';
   end;

   if SelectedCodes > '' then begin
      LSelected := TStringList.Create;
      LSelected.Delimiter := Globals.ClientCodeDelimiter;
      LSelected.StrictDelimiter := True;
      LSelected.DelimitedText := SelectedCodes;
   end else
      LSelected := nil;

   ClientSelectOptions := TClientSelectOptions.Create;
   try
     LClients := TStringList.Create;
     try
        BulkExtractors.InitSesssion;
        //Get Dates and type etc.
        if not GetSessionDetails then
           Exit;
        if CheckSession then
        if StartExtactList then begin
           // Do the main Loop

           for i := 0 to LClients.Count -1 do begin

              UpdateAppStatus(ProgressCaption + Extractor.Description,
                           'Client : ' + LClients[I],
                           I/LClients.Count*100
                          );

              ProcessClientFile(LClients[I]);
           end;
          if LSessionStarted
          and Assigned(Extractor) then begin

             if ClearExtract then begin
                Extractor.ReportSession(True);
                ShowExtractResults(Format('%s Bulk Clear Transfer Flag Result',[ Extractor.FDescription ]), Extractor.FStatus);
                Result := True;
             end else begin
                Result := Extractor.EndSession(BulkExtractors.CurSession);
                if Globals.StartupParam_Action = sa_BulkExport then
                   // Log somtehing ??
                else
                   ShowExtractResults(Format('%s  Bulk Export Result',[Extractor.FDescription]), Extractor.FStatus);
             end;

          end;
          ClearStatus;
        end;

     finally
        if Assigned(LSelected) then
           LSelected.Free;
        LClients.Free;
     end;
   finally
     ClientSelectOptions.Free;
   end;
end; //DoBulkExtract

//******************************************************************************
//
//         ASSIGN BULK EXPORT FORMAT
//
//******************************************************************************

function AssignBulkExtract(SelectedCodes: string): Boolean;
var ldlg: TfrmAssignBulkExtract;
    lSelected: TStringList;
begin
  Result := False;
  if SelectedCodes = '' then
     Exit;

  lSelected := TStringList.Create;
  ldlg := TfrmAssignBulkExtract.Create(Application.MainForm);
  try
     LSelected.Delimiter := Globals.ClientCodeDelimiter;
     LSelected.StrictDelimiter := True;
     LSelected.DelimitedText := SelectedCodes;
     ldlg.Selected := LSelected;
     ldlg.DateSelector.Visible := False;
     ldlg.btnSetup.Visible := False;
     ldlg.pnlBulkExtract.Height := 66;
     ldlg.ClientSelect.Visible := False;
     ldlg.Height := 142;
     ldlg.Caption := 'Assign Bulk Export format';
     FillExtractorComboBox(ldlg.cbExtractor,AdminSystem.fdFields.fdBulk_Export_Code);

     Result := ldlg.ShowModal = mrOK;
  finally
     ldlg.Free;
     LSelected.Free;
  end;
end;

//******************************************************************************
//
//         TBulkExtractors
//
//******************************************************************************

{ TBulkExtractors }


procedure TBulkExtractors.AddLib(FileName: string);
var
  lLib: THandle;
  GetversionProc: ProcGetversion;
  NewLib: TBulkExtractorLib;
  I: Integer;
begin
   lLib := LoadLibrary(PChar(FileName));
   if lLib <> 0 then begin
      @GetversionProc := GetProcAddress(LLib,GetVersionName);
      if @GetversionProc <> nil then begin
         NewLib := TBulkExtractorLib.Create(LLib,GetversionProc);
         FLibList.Add(NewLib);
         for I := 0 to NewLib.Count - 1 do
            self.Add(NewLib.Items[I])
      end else
         FreeLibrary(llib);
   end;
end;

function TBulkExtractors.Authenticate: TAuthenticateResult;

var
  BConnect: THTTPSConnector;

begin
   UpdateAppStatus('Authenticate Bulk Export' , '' ,0);
   Result := arFailed;
   BConnect := THTTPSConnector.Create('Bulk Export');
   try
        // Try to logon
        if BConnect.Login then begin
           if BConnect.CheckBulkExtract then
              Result := arCanExtract
           else
              Result := arCannotExtract;
           BConnect.LogOut;
        end;
   finally
      BConnect.Free;
      ClearStatus;
   end;
end;


function TBulkExtractors.CanExtract: Boolean;
begin
   Result := False;

   case Authenticate of
      arFailed : begin

             // Need to ask..
             if AskYesNo('Information',
                        'Cannot authenticate access to this feature.'#13
                      + 'You must contact ' + TProduct.BrandName + ' Support to continue.'#13#13
                      + 'Do you wish to continue?',DLG_NO,0) = DLG_No then begin
                LogMessage('Support Password Cancelled');
                Exit; //Canceled
             end;

             // Ask for a password...
             if not EnterPwdDlg.EnterRandomPassword('Bulk Export') then begin
                LogMessage('Support Password Failed');
                HelpfulInfoMsg( 'Cannot authenticate access to this feature.'#13
                           +'Please contact ' + TProduct.BrandName + ' Support for further information.', 0 );
                Exit;
             end;

             LogMessage('Support Password obtained');
         end;

      arCannotExtract: begin
            // Just Need to prompt
            LogMessage('Export attempted');
            HelpfulInfoMsg( 'Cannot authenticate access to this feature.'#13
                           +'Please contact ' + TProduct.BrandName + ' Support for further information.', 0 );
            Exit;
         end;


   end;

   // Still here..
   Result := True;
end;

constructor TBulkExtractors.Create;
begin
   inherited Create(False);
   FLibList := TObjectList.Create(True);
   FHeaders := TStringList.Create;
   FExportLog := TSystemLog.Create;
   FExportLog.LogPath := Globals.DataDir;
   FExportLog.LogFilename := 'BulkExport';
   FExportLog.SysLogStart;
   FillLibList;
end;

destructor TBulkExtractors.Destroy;
begin
  FHeaders.Free;
  self.Clear;// so no longer point to the libList items
  FLibList.Free;
  FExportLog.Free;
  inherited;
end;

procedure TBulkExtractors.FillComboBox(Value: TComboBox; UnAssigned: Boolean = True);
var I: Integer;
begin
   Value.Items.Clear;

   for I := 0 to self.Count - 1 do
      Value.Items.AddObject(self.Items[I].Description,self.Items[I]);
   if UnAssigned then
      Value.Items.Insert(0,'[Not assigned]');
   if self.Count > 0 then
      Value.ItemIndex := 0;
end;

procedure TBulkExtractors.FillLibList;
var F: TSearchRec;
begin
   Self.Clear;
   FLibList.Clear;
   if FindFirst(globals.DataDir + DllFilemask,faAnyFile,F) = 0 then
      repeat
         AddLib(globals.DataDir + F.Name);
      until FindNext(F) <> 0;
   SysUtils.FindClose(F);
end;

function TBulkExtractors.GeTBulkExtractor(Index: Integer): TBulkExtractor;
begin
   Result := TBulkExtractor(Self[Index]);
end;

function TBulkExtractors.GetComboBoxExtractor(Value: TComboBox): TBulkExtractor;
begin
   if Value.ItemIndex >=0 then
      Result := TBulkExtractor(Value.Items.Objects[Value.ItemIndex])
   else
      Result := nil;
end;


procedure TBulkExtractors.InitSesssion;
begin
   Fillchar(Cursession,Sizeof(CurSession),0);

   //test to see if the log file should be archived
   FExportLog.MinSize  := PRACINI_MinLogFileSize * 1000; //convert KB to Bytes
   FExportLog.MaxSize  := PRACINI_MaxLogFileSize * 1000;
   if FExportLog.ArchiveNeeded then begin
      if Trim( PRACINI_LogBackupDir) <> '' then
         FExportLog.Archive(IncludeTrailingBackSlash(PRACINI_LogBackupDir),'BE')
      else
        FExportLog.Archive(Globals.LogFileBackupDir,'BE');
   end;

end;

procedure TBulkExtractors.LogError(const Action,Value: string);
begin
   FExportLog.SysLogMessage(slError,Action,Value);
end;

procedure TBulkExtractors.LogMessage(const Value: string);
begin
   FExportLog.SysLogMessage(slMsg,'',Value);
end;

function TBulkExtractors.SelectExtractor(Code: string; ComboBox: TComboBox): boolean;
var I: integer;
begin
   Result := True;
   for I := 0 to ComboBox.Items.Count - 1 do
      if Assigned(ComboBox.Items.Objects[i])then begin
         if Sametext(TBulkExtractor(ComboBox.Items.Objects[i]).Code,Code) then begin
            ComboBox.ItemIndex := I;
            Exit;
          end;
      end else begin
         if Code = ''  then begin
            Result := False; // Not Assigned
            ComboBox.ItemIndex := I;
            Exit;
         end;
      end;
   // Still here, not found...
   Result := False;
   ComboBox.ItemIndex := -1;
end;

//******************************************************************************
//
//         TBulkExtractorLib
//
//******************************************************************************



{ TBulkExtractorLib }

procedure TBulkExtractorLib.CheckInit;
var initProc: procInitDllApplication;
begin
   if FInitDone then
      Exit; // Only once
   try
      @initProc := GetProcAddress(FLib, procInitDllApplicationName);
      if @initProc = nil then
         Exit;
      initProc(Application.MainFormHandle, Application.MainForm.Font);
   finally
      FInitDone := True;
   end;
end;

constructor TBulkExtractorLib.Create(ALib: THandle; AVersion: Integer);
var
   LGetExtractType: ProcGetExtractType;
   I: Integer;
   let: ExtractType;
begin
   inherited Create(True);
   FInitDone := False;
   FLib := ALib;
   FVersion := AVersion;
   @FBulkExportProc := GetProcAddress(FLib,BulkExportName);
   @LGetExtractType := GetProcAddress(FLib,GetExtractTypeName);
   if @LGetExtractType <> nil then begin
      I := 0;
      while LGetExtractType(I,let) do begin
         self.Add( TBulkExtractor.Create(Self, let.Index, let.ExtractClass, string(let.Code), string(let.Description)));
         inc(I);
      end;
   end;//Else Fail ???
end;

destructor TBulkExtractorLib.Destroy;
begin
  Clear;
  if FLib <> 0 then begin
      FreeLibrary(FLib);
      FLib := 0;
  end;
  inherited;
end;

function TBulkExtractorLib.GeTBulkExtractor(Index: Integer): TBulkExtractor;
begin
   Result := TBulkExtractor(Self[Index]);
end;

//******************************************************************************
//
//         TBulkExtractor
//
//******************************************************************************



{ TBulkExtractor }

                                    
function TBulkExtractor.AccountToText(anAccount: TBank_Account): string;
var
  lsBSB,
  lsAccountNumber : string;

begin
   FFields.Clear;

   AddField(f_AccountType, IntToStr(anAccount.baFields.baAccount_Type));
   AddField(f_Date, StDateToDateString('dd/mm/yyyy', bulkextractors.cursession.fromdate, false));
   AddField(f_Name, anAccount.baFields.baBank_Account_Name );
   
// BGL 360
   RetrieveBSBAndAccountNum(
     anAccount.baFields.baExtract_Account_Number,
     anAccount.baFields.baBank_Account_Number,
     CanExtractAccountNumberAs(
       Client.clFields.clCountry,
       Client.clFields.clAccounting_System_Used ),
     lsBSB, lsAccountNumber );

   AddField(f_Number, concat( lsBSB, lsAccountNumber ));
/////////////////////////////////// DN - Redundant code   AddField(f_Number, anAccount.baFields.baBank_Account_Number);

   AddField(f_ContraCode, anAccount.baFields.baContra_Account_Code);
   AddField(f_ContraDesc, LookupChart(anAccount.baFields.baContra_Account_Code) );

   if Software.HasSuperfundLegerID( Client.clFields.clCountry, Client.clFields.clAccounting_System_Used ) then
      AddNumberField(f_FundID, anAccount.baFields.baDesktop_Super_Ledger_ID )
   else if Software.HasSuperfundLegerCode( Client.clFields.clCountry, Client.clFields.clAccounting_System_Used ) then
      AddField(f_FundID, anAccount.baFields.baSuperFund_Ledger_Code);

   // Bulk extracts need to be able to distinguish between unknown amounts and zero amounts
   if (anAccount.baFields.baCurrent_balance = UNKNOWN) then
     AddField(f_IsUnknownAmount, '1')
   else
     AddField(f_IsUnknownAmount, '0');

   if FCurrentBal <> Unknown then
      AddMoneyField(f_Balance,FCurrentBal);
   Result := FFields.DelimitedText;
end;


procedure TBulkExtractor.AddBGL360ComponentFields(Date, Component: Integer);
begin
  if (Date = 0)
  or (Date >= mcSwitchDate) then begin
     if Component in [mcnewMin .. mcnewMax] then
        AddField(f_MemComp,mcNewNames[Component]);

  end else begin
      if Component in [mcOldMin .. mcOldMax] then
         AddField(f_MemComp,mcOldNames[Component]);
  end;
end;

procedure TBulkExtractor.AddBGLFields(Date, Component: Integer);
begin
  if (Date = 0)
  or (Date >= mcSwitchDate) then begin
     if Component in [mcnewMin .. mcnewMax] then
        AddField(f_MemComp,mcNewNames[Component]);

  end else begin
      if Component in [mcOldMin .. mcOldMax] then
         AddField(f_MemComp,mcOldNames[Component]);
  end;
end;

procedure TBulkExtractor.AddBoolField(const Name: string; Value: Boolean);
begin
   if Value then
       FFields.Add(Name + '=T')
   else
       FFields.Add(Name + '=F')
end;

procedure TBulkExtractor.AddCountryField(Value: Integer);
begin
   case Value of
   whNewZealand : FFields.Add(f_Country + '=' + c_NZ);
   whAustralia  : FFields.Add(f_Country + '=' + c_AU);
   //whUK         : FFields.Add(f_Country + '=' + c_UK);
   end;
end;

procedure TBulkExtractor.AddDateField(const Name: string; Value: Integer);
begin
   if Value (*<*)> 0 then
      FFields.Add(Name + '=' + StDateToDateString('dd/mm/yyyy',Value,False));
end;

procedure TBulkExtractor.AddField(const Name, Value: string);
begin
   if Value > '' then
      FFields.Add(Name + '=' + Value );
end;

procedure TBulkExtractor.AddFractionField(const Name: string; Value: Boolean);
begin
   if Value then
      FFields.Add(Name + '=1/2' )
   else
      FFields.Add(Name + '=2/3' )
end;

procedure TBulkExtractor.AddMoneyField(const Name: string; Value: Money);
begin
   if (Value=UnKnown)
   or (Value=0) then
   else
      FFields.Add(Name + '=' + Format('%.2f',[Value/100]));
end;

procedure TBulkExtractor.AddNumberField(const Name: string; Value: Integer);
begin
   FFields.Add(Name + '=' + InttoStr(Value));
end;

procedure TBulkExtractor.AddQtyField(const Name: string; Value: Money);
begin
  if Value <> 0 then
      FFields.Add(Name + '=' + Format('%.4f',[Value/10000]));
end;



procedure TBulkExtractor.AddStatus(const Value: string;const Log: Boolean = True);
begin
  fStatus.Add(Value);
  if Log then
     BulkExtractors.LogMessage(Value);
end;

procedure TBulkExtractor.AddTaxFields(TaxAmount: Money; TaxClass: Integer);
var Code, Desc : string;
begin
   if TaxClass > 0 then begin
      if LookupTaxClass(TaxClass, Code, Desc) then begin
         AddField(f_TaxCode,Code);
         AddField(f_TaxDesc,Desc);
      end;
      AddMoneyField(f_Tax,TaxAmount);
   end;
end;

function TBulkExtractor.CanConfig: Boolean;
begin
   // is a bit cheeky
   // But it also allows the Dll to pick up any settings (Full ini Path)
   Result := DoExport(BulkExtractors.CurSession,ef_CanConfig,'');
end;

procedure TBulkExtractor.ClearStatus;
begin
   FStatus.Clear;
   FLineCount := 0;
   FTransCount := 0;
   FCodedCount := 0;
   FAccountCount := 0;
   FClientCount := 0;
   FClientsSkipped := 0;
end;

function TBulkExtractor.ClientStatustext(aClient: pClient_File_Rec): string;
var lUser: pUser_Rec;
begin
   case aClient.cfFile_Status of
   fsOpen         : begin
                       Result := ' is opened';
                       lUser := AdminSystem.fdSystem_User_List.FindLRN(aClient.cfCurrent_User);
                       if Assigned(LUser) then
                          Result := Result + ' by ' + luser.usName
                       else
                          Result := result + ' by <Unknown>';
                    end;
   fsCheckedOut   : Result := ' is read-only';
   fsOffsite      : Result := ' is offsite';
   fsError        : Result := ' has an unknown error';
   end;
   Result := 'Client file ' + aClient.cfFile_Name + Result;
end;

function TBulkExtractor.ClientToText(aClient: TClientObj): string;
begin
   FFields.Clear;

   //AddField('type', 'CLIENT' ); // just for testing

   AddField(f_Name, AClient.clFields.clName);
   AddField(f_Code, AClient.clFields.clCode);
   AddField(f_TaxCode, AClient.clFields.clGST_Number);// GST / ABN Number
   AddCountryField(AClient.clFields.clCountry);

   Result := FFields.DelimitedText;
end;

constructor TBulkExtractor.Create(ABulkExtractorLib: TBulkExtractorLib;
                                  Anindex, AClass: Integer; ACode, ADescription: string);
begin
  inherited Create;
  FBulkExtractorLib := ABulkExtractorLib;
  LibIndex := AnIndex;
  ExtractClass := AClass;
  Code := ACode;
  Description := ADescription;
  FStatus := TStringList.create;
  FFields := TStringList.create;
  FFields.Delimiter := ',';
  FFields.StrictDelimiter := True;
end;

destructor TBulkExtractor.Destroy;
begin
  FStatus.Free;
  FFields.Free;
  inherited;
end;

function TBulkExtractor.DissectionToText(const Index: Integer; aDiss: pDissection_Rec): string;

  procedure AddBGL360Fields;
  begin
//  fBGL360_Accrual_Date
    AddDateField(fBGL360_Accrual_Date, aDiss^.dsDissection_Extension^.deSF_Accrual_Date);
//  fBGL360_Cash_Date
    AddDateField(fBGL360_Cash_Date, aDiss^.dsDissection_Extension^.deSF_Cash_Date);
//  fBGL360_Record_Date
    AddDateField(fBGL360_Record_Date, aDiss^.dsDissection_Extension^.deSF_Record_Date);

   //Distribution Entry Type
       {// sffIdxBGL360_Entry Type}
       {// sffIdxBGL360_Units}
       {// sffIdxBGL360_Cash_Date}
       {// sffIdxBGL360_Accrual Date}
       {// sffIdxBGL360_Record_Date}


///////////// ***************** Share Trade Tab ***************** ////////////////
//    fBGL360_Units
      AddQtyField(fBGL360_Units {fQuantity}, aDiss^.dsQuantity);
//    fBGL360_Contract_Date
      AddDateField(fBGL360_Contract_Date, aDiss^.dsDissection_Extension^.deSF_Contract_Date);
//    fBGL360_Settlement_Date
      AddDateField(fBGL360_Settlement_Date, aDiss^.dsDissection_Extension^.deSF_Settlement_Date);
//    fBGL360_Brokerage
      AddMoneyField( fBGL360_Brokerage,
        abs( aDiss^.dsDissection_Extension^.deSF_Share_Brokerage ) ) ;
//    fBGL360_GST_Rate
      AddNumberField( fBGL360_GST_Rate,
        Abs( StrToIntDef( aDiss^.dsDissection_Extension^.deSF_Share_GST_Rate, 0 ) ) );
//    fBGL360_GST_Amount
      AddMoneyField( fBGL360_GST_Amount,
        Abs( aDiss^.dsDissection_Extension^.deSF_Share_GST_Amount ) );
//    fBGL360_Consideration
      AddMoneyField( fBGL360_Consideration,
        ( aDiss^.dsDissection_Extension^.deSF_Share_Consideration ) );
///////////// ***************** Share Trade Tab ***************** ////////////////

///////////// ***************** Dividend / Distribution Tabs ***************** ////////////////
//    fBGL360_Dividends_Franked
      AddMoneyField( fBGL360_Dividends_Franked,
        abs(aDiss^.dsSF_Franked) );
//    fBGL360_Dividends_Unfranked
      AddMoneyField( fBGL360_Dividends_Unfranked,
        abs(aDiss^.dsSF_Unfranked) );
//    fBGL360_Franking_Credits
      AddMoneyField( fBGL360_Franking_Credits,
        Abs(aDiss^.dsSF_Imputed_Credit) );
///////////// ***************** Dividend / Distribution Tabs ***************** ////////////////

///////////// ***************** Distribution / Interest Tabs ***************** ////////////////
//   fBGL360_Interest
      AddMoneyField( fBGL360_Interest,
        Abs( aDiss^.dsSF_Interest) );
//    fBGL360_Other_Income
      AddMoneyField( fBGL360_Other_Income,
        Abs(aDiss^.dsDissection_Extension^.deSF_Other_Income ) );
///////////// ***************** Distribution / Interest Tabs ***************** ////////////////

///////////// ***************** Distribution ***************** ////////////////
//    fBGL360_Less_Other_Allowable_Trust_Deductions
      AddMoneyField( fBGL360_Less_Other_Allowable_Trust_Deductions,
        Abs(aDiss^.dsDissection_Extension^.deSF_Other_Trust_Deductions ) );
//    fBGL360_Discounted_Capital_Gain_Before_Discount
      AddMoneyField( fBGL360_Discounted_Capital_Gain_Before_Discount,
        Abs(aDiss^.dsSF_Capital_Gains_Disc) );
//    fBGL360_Capital_Gains_CGT_Concessional_Amount
      AddMoneyField( fBGL360_Capital_Gains_CGT_Concessional_Amount,
        Abs(aDiss^.dsDissection_Extension^.deSF_CGT_Concession_Amount ) );
//    fBGL360_Capital_Gain_Indexation_Method
      AddMoneyField( fBGL360_Capital_Gain_Indexation_Method,
        Abs( aDiss^.dsSF_Capital_Gains_Indexed) );
//    fBGL360_Capital_Gain_Other_Method
      AddMoneyField( fBGL360_Capital_Gain_Other_Method,
        Abs( aDiss^.dsSF_Capital_Gains_Other) );
//    fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount
      AddMoneyField( fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount,
        Abs( aDiss^.dsDissection_Extension^.deSF_CGT_ForeignCGT_Before_Disc ) );
//    fBGL360_Foreign_Capital_Gains_Indexation_Method
      AddMoneyField( fBGL360_Foreign_Capital_Gains_Indexation_Method,
        Abs( aDiss^.dsDissection_Extension^.deSF_CGT_ForeignCGT_Indexation ) );
//    fBGL360_Foreign_Capital_Gains_Other_Method
      AddMoneyField( fBGL360_Foreign_Capital_Gains_Other_Method,
        Abs( aDiss^.dsDissection_Extension^.deSF_CGT_ForeignCGT_Other_Method ) );
//    fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount_Tax_Paid
      AddMoneyField( fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount_Tax_Paid,
        Abs( aDiss^.dsSF_Capital_Gains_Foreign_Disc ) );
//    fBGL360_Foreign_Capital_Gains_Indexation_Method_Tax_Paid
      AddMoneyField( fBGL360_Foreign_Capital_Gains_Indexation_Method_Tax_Paid,
        Abs( aDiss^.dsDissection_Extension^.deSF_CGT_TaxPaid_Indexation ) );
//    fBGL360_Foreign_Capital_Gains_Other_Method_Tax_Paid
      AddMoneyField( fBGL360_Foreign_Capital_Gains_Other_Method_Tax_Paid,
        Abs( aDiss^.dsDissection_Extension^.deSF_CGT_TaxPaid_Other_Method ) );
///////////// ***************** Distribution ***************** ////////////////

///////////// ***************** Distribution / Dividend ***************** ////////////////
//    fBGL360_Assessable_Foreign_Source_Income
      AddMoneyField( fBGL360_Assessable_Foreign_Source_Income,
        Abs( aDiss^.dsSF_Foreign_Income ) );
//    fBGL360_Foreign_Income_Tax_Paid_Offset_Credits
      AddMoneyField( fBGL360_Foreign_Income_Tax_Paid_Offset_Credits,
        Abs( aDiss^.dsSF_Foreign_Tax_Credits ) );
//    fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company
      AddMoneyField( fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company,
        Abs( aDiss^.dsDissection_Extension^.deSF_AU_Franking_Credits_NZ_Co ) );
///////////// ***************** Distribution / Dividend ***************** ////////////////

///////////// ***************** Distribution ***************** ////////////////
//    fBGL360_Other_Net_Foreign_Source_Income
      AddMoneyField( fBGL360_Other_Net_Foreign_Source_Income,
        Abs( aDiss^.dsDissection_Extension^.deSF_Other_Net_Foreign_Income ) );
//    fBGL360_Cash_Distribution
      AddMoneyField( fBGL360_Cash_Distribution,
        Abs( aDiss^.dsDissection_Extension^.deSF_Cash_Distribution ) );
//    fBGL360_Tax_Exempted_Amounts
      AddMoneyField( fBGL360_Tax_Exempted_Amounts,
        Abs( aDiss^.dsSF_Tax_Exempt_Dist ) );
//    fBGL360_Tax_Free_Amounts
      AddMoneyField( fBGL360_Tax_Free_Amounts,
        Abs( aDiss^.dsSF_Tax_Free_Dist ) );
//    fBGL360_Tax_Deferred_amounts
      AddMoneyField( fBGL360_Tax_Deferred_amounts,
        Abs( aDiss^.dsSF_Tax_Deferred_Dist ) );
///////////// ***************** Distribution ***************** ////////////////

///////////// ***************** Distribution / Dividend  / Interest tabs ***************** ////////////////
//    fBGL360_TFN_Amounts_withheld
      AddMoneyField( fBGL360_TFN_Amounts_withheld,
        Abs( aDiss^.dsSF_TFN_Credits ) );
//    fBGL360_Non_Resident_Withholding_Tax
      AddMoneyField( fBGL360_Non_Resident_Withholding_Tax,
        Abs( aDiss^.dsDissection_Extension^.deSF_Non_Res_Witholding_Tax ) );
///////////// ***************** Distribution / Dividend  / Interest tabs ***************** ////////////////

///////////// ***************** Distribution Tab ***************** ////////////////
//    fBGL360_Other_Expenses
      AddMoneyField( fBGL360_Other_Expenses,
        Abs( aDiss^.dsSF_Other_Expenses ) );
//    fBGL360_Other_Net_Foreign_Source_Income
      AddMoneyField( fBGL360_Other_Net_Foreign_Source_Income,
        Abs( aDiss^.dsDissection_Extension^.deSF_Other_Net_Foreign_Income ) );
//    fBGL360_Cash_Distribution
      AddMoneyField( fBGL360_Cash_Distribution,
        Abs( aDiss^.dsDissection_Extension^.deSF_Cash_Distribution ) );
//    fBGL360_Tax_Exempted_Amounts
      AddMoneyField( fBGL360_Tax_Exempted_Amounts,
      Abs( aDiss^.dsSF_Tax_Exempt_Dist ) );
//    fBGL360_Tax_Free_Amounts
      AddMoneyField( fBGL360_Tax_Free_Amounts,
      Abs( aDiss^.dsSF_Tax_Free_Dist ) );
//    fBGL360_Tax_Deferred_amounts
      AddMoneyField( fBGL360_Tax_Deferred_amounts,
      Abs( aDiss^.dsSF_Tax_Deferred_Dist ) );
//    fBGL360_TFN_Amounts_withheld
      AddMoneyField( fBGL360_TFN_Amounts_withheld,
      Abs( aDiss^.dsSF_TFN_Credits ) );
//    fBGL360_Non_Resident_Withholding_Tax
      AddMoneyField( fBGL360_Non_Resident_Withholding_Tax,
        Abs( aDiss^.dsDissection_Extension^.deSF_Non_Res_Witholding_Tax ) );
//    fBGL360_Other_Expenses
      AddMoneyField( fBGL360_Other_Expenses,
      Abs( aDiss^.dsSF_Other_Expenses ) );
///////////// ***************** Distribution Tab ***************** ////////////////

///////////// ***************** Distribution / Dividend Tabs ***************** ////////////////
//    fBGL360_LIC_Deduction
      AddMoneyField( fBGL360_LIC_Deductions,
        Abs( aDiss^.dsDissection_Extension^.deSF_LIC_Deductions ) );
///////////// ***************** Distribution / Dividend Tabs ***************** ////////////////

///////////// ***************** Distribution Tab ***************** ////////////////
//    fBGL360_Discounted_Capital_Gain_Before_Discount_Non_Cash
      AddMoneyField( fBGL360_Discounted_Capital_Gain_Before_Discount_Non_Cash,
        Abs( aDiss^.dsDissection_Extension^.deSF_Non_Cash_CGT_Discounted_Before_Discount ) );
//    fBGL360_Capital_Gains_Indexation_Method_Non_Cash
      AddMoneyField( fBGL360_Capital_Gains_Indexation_Method_Non_Cash,
        Abs( aDiss^.dsDissection_Extension^.deSF_Non_Cash_CGT_Indexation ) );
//    fBGL360_Capital_Gains_Other_Method_Non_Cash
      AddMoneyField( fBGL360_Capital_Gains_Other_Method_Non_Cash,
        Abs( aDiss^.dsDissection_Extension^.deSF_Non_Cash_CGT_Other_Method ) );
//    fBGL360_Capital_Losses_Non_Cash
      AddMoneyField( fBGL360_Capital_Losses_Non_Cash,
        Abs( aDiss^.dsDissection_Extension^.deSF_Non_Cash_CGT_Capital_Losses ) );
///////////// ***************** Distribution Tab ***************** ////////////////
  end;
begin
   FFields.Clear;
   AddNumberField(f_Line,FlineCount);
   AddNumberField(f_Trans,FTransCount);
   AddNumberField(f_Dissect,Index);
   // Any other IDs

   case Ft_TransID of
     tr_BNotes   : AddNumberField(f_TransID, aDiss^.dsTransaction.txECoding_Transaction_UID);
     tr_GUID     : AddField(f_TransID,aDiss^.dsExternal_GUID);
   end;

   AddDateField(f_Date,aDiss^.dsTransaction.txDate_Effective);
   AddMoneyField(f_Amount,aDiss^.dsAmount);

   AddTaxFields(aDiss^.dsGST_Amount, aDiss^.dsGST_Class);

   AddQtyField(f_Quantity, aDiss^.dsQuantity);
   AddNumberField(f_TransType, aDiss^.dsTransaction.txType);

   // Naratives
   AddField(f_Reference, TransactionUtils.getDsctReference(aDiss, BankAccount.baFields.baAccount_Type));
   AddField(f_Analysis, aDiss^.dsTransaction.txAnalysis);
   AddField(f_OtherParty, aDiss^.dsTransaction.txOther_Party);
   AddField(f_Particulars, aDiss^.dsTransaction.txParticulars);

   if trim( aDiss^.dsGL_Narration ) <> '' then
     AddField(f_Narration, aDiss^.dsGL_Narration)
   else
     AddField(f_Narration, aDiss^.dsTransaction^.txGL_Narration);

   AddField(f_Notes, GetFullNotes(aDiss));

   // Coding
   AddField(f_Code,aDiss^.dsAccount);
   AddField(f_Desc,LookupChart(aDiss^.dsAccount));
   // Job
   AddField(f_JobCode, aDiss^.dsJob_Code);
   AddField(f_JobDesc, lookupJob(aDiss^.dsJob_Code));

   // Superfund...
   // Superfund...
   if IsSuperFund(Client.clFields.clCountry,Client.clFields.clAccounting_System_Used) then begin

       // Common Money Fields
       AddDateField(f_CGTDate,aDiss^.dsSF_CGT_Date);

       AddMoneyField(f_Franked,aDiss^.dsSF_Franked);
       AddMoneyField(f_UnFranked,aDiss^.dsSF_UnFranked);

       AddMoneyField(f_Imp_Credit,aDiss^.dsSF_Imputed_Credit);
       AddMoneyField(f_TFN_Credit,aDiss^.dsSF_TFN_Credits);
       AddMoneyField(f_Frn_Credit,aDiss^.dsSF_Foreign_Tax_Credits);

       AddMoneyField(f_TF_Dist,aDiss^.dsSF_Tax_Free_Dist);
       AddMoneyField(f_TE_Dist,aDiss^.dsSF_Tax_Exempt_Dist);
       AddMoneyField(f_TD_Dist,aDiss^.dsSF_Tax_Deferred_Dist);

       AddMoneyField(f_CGI,aDiss^.dsSF_Capital_Gains_Indexed);
       AddMoneyField(f_CGD,aDiss^.dsSF_Capital_Gains_Disc);
       AddMoneyField(f_CGO,aDiss^.dsSF_Capital_Gains_Other);

       AddMoneyField(f_Frn_Income,aDiss^.dsSF_Foreign_Income);
       AddMoneyField(f_CGO,aDiss^.dsSF_Capital_Gains_Other);

       AddMoneyField(f_OExpences,aDiss^.dsSF_Other_Expenses);
       AddMoneyField(f_Interest, aDiss^.dsSF_Interest);
       AddMoneyField(f_ForeignCG, aDiss^.dsSF_Capital_Gains_Other);
       AddMoneyField(f_ForeignDiscCG, aDiss^.dsSF_Capital_Gains_Foreign_Disc);
       AddMoneyField(f_Rent, aDiss^.dsSF_Rent);
       AddMoneyField(f_SpecialIncome, aDiss^.dsSF_Special_Income);
       AddMoneyField(f_ForeignCGCredit, aDiss^.dsSF_Foreign_Capital_Gains_Credit);
       AddMoneyField(f_OT_Credit, aDiss^.dsSF_Other_Tax_Credit);
       AddMoneyField(f_NonResidentTax, aDiss^.dsSF_Non_Resident_Tax);

       // Member, Fund and Transaction fields are more System specific
       case Client.clFields.clAccounting_System_Used of
         saBGLSimpleFund,
         saBGLSimpleLedger : AddBGLFields(aDiss^.dsTransaction.txDate_Effective,
                                          aDiss^.dsSF_Member_Component);

         saBGL360: begin
           AddBGL360ComponentFields( aDiss^.dsTransaction.txDate_Effective,
                                    aDiss^.dsSF_Member_Component );
           AddBGL360Fields;
         end;

         saSupervisor, saSolution6SuperFund: ;

         saDesktopSuper: begin
               if aDiss^.dsSF_Transaction_ID <> -1 then
                  AddNumberField(f_SFTransID, aDiss^.dsSF_Transaction_ID);

               if aDiss^.dsSF_Fund_ID <> -1 then
                  AddNumberField(f_FundID, aDiss^.dsSF_Fund_ID);

               if aDiss^.dsSF_Member_Account_ID <> -1 then
                  AddNumberField(f_MemID, aDiss^.dsSF_Member_Account_ID);

               if aDiss^.dsSF_Capital_Gains_Foreign_Disc <> 0 then
                  AddFractionField(f_CGFraction, aDiss^.dsSF_Capital_Gains_Fraction_Half);
           end;

         saClassSuperIp: begin
               AddField(f_FundID, aDiss^.dsSF_Fund_Code);
               AddField(f_MemID, aDiss^.dsSF_Member_Account_Code);
               AddFractionField(f_CGFraction, aDiss^.dsSF_Capital_Gains_Fraction_Half);
            end;

         saSageHandisoftSuperfund:
            if aDiss^.dsSF_Transaction_ID <> -1 then begin
               AddField(f_SFTransID, TypesArray[TTxnTypes(aDiss^.dsSF_Transaction_ID)]);
               AddField(f_SFTransCode, aDiss^.dsSF_Transaction_Code);
            end;

         saSuperMate:  begin
               AddField(f_MemID, aDiss^.dsSF_Member_ID);

            end;
       end;

   end;
   // Running balance
   if FCurrentBal <> Unknown then
      AddMoneyField(f_Balance,FCurrentBal);
   Result := FFields.DelimitedText;
end;

function TBulkExtractor.DoConfig: Boolean;
begin
   Result := DoExport(BulkExtractors.CurSession,ef_DoConfig,'');
end;

function TBulkExtractor.DoExport(var Session: TExtractSession; Extract: Integer; Data: string): Boolean;

    procedure GetStat;
    var stat: string;

       function ExtractText: string;
       begin
          case Extract of
           ef_ClientStart,
           ef_ClientEnd  : Result := format(' exporting client %s ', [Client.clExtendedName]);
           ef_AccountStart,
           ef_AccountEnd : Result := format(' exporting Account %s for client %s ',[BankAccount.AccountName, Client.clExtendedName]);
           ef_Transaction,
           ef_Dissection : Result := format(' exporting transaction for Account %s for client %s ',[BankAccount.AccountName, Client.clExtendedName]);
           else  Result := ' exporting ';
          end;
       end;
    begin
       stat := '';
       if Session.Data <> nil then begin
          stat := string(Session.Data);
       end;

       AddStatus('Error' + ExtractText);
       if stat > '' then
          AddStatus('    ' + stat);

    end;

begin
   Result := False; // Fail by default
   //Update the session bits
   Session.ExtractFunction := Extract;
   Session.Data := PChar(Data);
   Session.Index := Self.FLibIndex;
   Session.IniFile := pchar(ExecDir + PRACTICEINIFILENAME);
   // Make sure Lib is initialized
   FBulkExtractorLib.CheckInit;

   case FBulkExtractorLib.FBulkExportProc(Session) of
       er_NotImplemented,
       er_OK : Result := True;
       er_Error : begin
             // Record the Error
             GetStat;
             Result := True; // But carry on
          end;
       else if not AbortExtract then begin
          // Do this Only Once
          // Endsession, endClient and EndAccount are still run
          // Record the Error
          GetStat;
          AddStatus('Export Aborted');
          AbortExtract := True;
       end;
   end;
end;

function TBulkExtractor.EndSession(var Session: TExtractSession): Boolean;

begin
    Result := DoExport(Session,ef_SessionEnd,'');
    // While we are here...
    ReportSession(False);
end;

function TBulkExtractor.ExportAccount(var Session: TExtractSession; var anAccount: TBank_Account): Boolean;
var I:Integer;
    lTrans: pTransaction_Rec;
    AccountText: string;
begin
   // It is already determined that the account has exportable transactions..
   Inc(FAccountCount);
   Result := True;
   BankAccount := anAccount;
   //Update the session
   Session.AccountType := AnAccount.baFields.baAccount_Type;

   // Workout the opening balance
   FCurrentBal := anAccount.baFields.baCurrent_Balance;
   if FCurrentBal <> Unknown then
      // Got something to work with
      for I := anAccount.baTransaction_List.Last downto anAccount.baTransaction_List.first do begin
         lTrans := anAccount.baTransaction_List.Transaction_At(I);
         if lTrans.txDate_Effective >= Session.FromDate then
            FCurrentBal := FCurrentBal - lTrans.txAmount
         else
            Break;
      end;

   AccountText := AccountToText(anAccount);
   if DoExport(Session,ef_AccountStart,AccountText) then begin
      BulkExtractors.LogMessage('Export Account ' + BankAccount.baFields.baBank_Account_Number);

      for I := AnAccount.baTransaction_List.First to AnAccount.baTransaction_List.Last do
      begin
        lTrans := AnAccount.baTransaction_List.Transaction_At(I);

        if IncludeTrans(Session,LTrans,false) then
        begin
          if not ExportTrans(Session,LTrans) then
          begin
            Result := False;
            Break;
          end;
        end
        else
        //We need to increment the current balance if we skip a transaction otherwise the calculated closing balance of the next exported transaction will be wrong.
        if (lTrans.txDate_Transferred <> 0) and (lTrans.txDate_Effective >= Session.FromDate) and (FCurrentBal <> Unknown) then
        begin
          FCurrentBal := FCurrentBal + lTrans.txAmount;
        end;
      end;

      if FCurrentBal <> Unknown then
         AccountText := AccountToText(anAccount); // Update The 'Closing' Ballance
      if not DoExport(Session,ef_AccountEnd,AccountText) then
         Result := False;
   end else
      Result := False;
end;

function TBulkExtractor.ExportClient(var Session: TExtractSession; var aClient: TClientObj): Boolean;
var I: Integer;
    ClientStarted: Boolean;
    ThingsToDo: Boolean;
    Lba: TBank_Account;
    ClientText: string;


    function StartClient: Boolean;
    begin
          //Fill the Data Bit..
        ClientText := ClientToText(aClient);
        Result := DoExport(Session,ef_ClientStart,ClientText);
        ClientStarted := Result;
        if Result then begin
           inc(FClientCount);
           BulkExtractors.LogMessage('Export Client ' + Client.clExtendedName);
        end;
    end;
begin
   Result := True;
   Client := aClient;//So we don't have to use it as a Param all the time..

   // Check the Client..
   ThingsToDo := False;
   // Check all the accounts first..
   for I := aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do begin
      Lba :=  aClient.clBank_Account_List.Bank_Account_At(I);
      if IncludeAccount(Session,Lba, True) then
         ThingsToDo := True; // Have somtething to do
      if SkipClient then
         Exit;//Cannot do this client
   end;
   if not ThingsToDo then
      Exit;// Nothing to do..

   // Now Run The Client
   ClientStarted := False;
   try
      for I := aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do begin
         Lba :=  aClient.clBank_Account_List.Bank_Account_At(I);
         if IncludeAccount(Session,Lba, False) then begin
            if not ClientStarted then
               if not StartClient then begin
                  Result := False;
                  Break; // Cannot Continue
               end;
            if not ExportAccount(Session,lba) then
               Break;
         end;
      end;

   finally
      if ClientStarted then
         if not DoExport(Session,ef_ClientEnd,ClientText) then// Call this in any case
            Result := False; // Fail the Rest
   end
end;


function TBulkExtractor.ExportTrans(var Session: TExtractSession; aTrans: pTransaction_Rec): Boolean;
var lDiss: pDissection_Rec;
    LDissCount: Integer;
begin

   if SkipZeroAmountExport(aTrans) then begin
      //nothing to do, but set the txDate_Transferred
      aTrans.txDate_Transferred := FExtractDate;
      Result := true;
      Exit; // Im done...
   end;

   Inc(FTransCount);
   if (Client.clChart.ItemCount > 0) then  //Don't inc coded count if no chart
     if IsCoded(Client, aTrans) then
        Inc(FCodedCount);
   // Check any required ids
   case Ft_TransID of
     tr_BNotes   : if aTrans.txECoding_Transaction_UID = 0 then begin
                     Inc( BankAccount.baFields.baLast_ECoding_Transaction_UID);
                     aTrans.txECoding_Transaction_UID := BankAccount.baFields.baLast_ECoding_Transaction_UID;
                  end;

     tr_GUID     : CheckExternalGUID(aTrans);
   end;

   lDiss := aTrans.txFirst_Dissection;
   if Assigned(lDiss)then begin
      // Export the base transaction
      // The Ballance is not updated
      Result := DoExport(Session,ef_Dissected,TransactionToText(aTrans));
      // Export the Dissections
      LDissCount := 0;
      while Assigned(LDiss) do begin
         Inc(LDissCount);
         if FCurrentBal <> Unknown then
            FCurrentBal := FCurrentBal + LDiss.dsAmount;

         case Ft_TransID of
            // Dissection does not have a BNotes ID..
            tr_GUID     : CheckExternalGUID(lDiss);
         end;

         Inc(FLineCount);
         Result := DoExport(Session,ef_Dissection,DissectionToText(LDissCount,LDiss));
         if not Result then
            Exit;
         lDiss := LDiss.dsNext;
      end
   end else begin
      // Just This Transaction..
      Inc(FLineCount);
      if FCurrentBal <> Unknown then
         FCurrentBal := FCurrentBal + aTrans.txAmount;
      Result := DoExport(Session,ef_Transaction,TransactionToText(aTrans));
   end;
   if Result then
      aTrans.txDate_Transferred := FExtractDate;
end;

procedure TBulkExtractor.CheckDllFeatures;
var CheckProc: ProcCheckFeature;
begin
    Ft_TransID := 0;
    Ft_TransType := 0;
    Ft_BankType := 0;
    Ft_ClientType := 0;
    @CheckProc := GetProcAddress( BulkExtractorLib.FLib,CheckFeatureName);
    if @CheckProc <> nil then begin
       Ft_TransID    := CheckProc(LibIndex,tf_TransactionID);
       Ft_TransType  := CheckProc(LibIndex,tf_TransactionType);
       Ft_BankType   := CheckProc(LibIndex,tf_BankAccountType);
       Ft_ClientType := CheckProc(LibIndex,tf_ClientType);
    end;
end;

function TBulkExtractor.IncludeAccount(Session: TExtractSession; anAccount: TBank_Account; preTest: Boolean): Boolean;
var I: Integer;
begin
   // This could be
   Result := (anAccount.baFields.baAccount_Type in [btBank, btCashJournals, btAccrualJournals]);

   if Result then begin

      if PreTest then begin
         AutoCodeEntries(Client, anAccount,AllEntries, Session.FromDate, Session.ToDate);
          //Have to test All the transactions..
         Result := False;
         for I := anAccount.baTransaction_List.First to anAccount.baTransaction_List.Last do begin
            if IncludeTrans(Session,AnAccount.baTransaction_List.Transaction_At(I),True) then
               Result := True; // Need at least one..
            if SkipClient then begin
               Result := False;
               Exit;
            end;
          end;

          if Result then
          // Check the account only if has exportable transactions
          if NeedBankContra then
          if anAccount.baFields.baContra_Account_Code = '' then begin
            SkipClient := True;
            AddStatus(format('Client %s skipped, Account %s does not have a contra code',[Client.clExtendedName, anAccount.baFields.baBank_Account_Number]));
            Result := False;
            Exit;
         end;

      end else begin
        // Thats ok but do I have anything to do..
        for I := anAccount.baTransaction_List.First to anAccount.baTransaction_List.Last do
           if IncludeTrans(Session,AnAccount.baTransaction_List.Transaction_At(I),false) then
              Exit; // one is enough
        // Did not find any..
        Result := False;
      end;
   end;
end;

function TBulkExtractor.IncludeTrans(Session: TExtractSession; aTrans: pTransaction_Rec; PreTest: Boolean): Boolean;

begin
   Result := False;
   if (aTrans.txDate_Transferred <> 0)
   or (aTrans.txDate_Effective < Session.FromDate)
   or (aTrans.txDate_Effective > Session.ToDate) then
      Exit; //Not included

   if PreTest then begin
      if NeedCoded then begin
         if SkipClient then
            exit
         else if (Client.clChart.ItemCount = 0) then begin
            SkipClient := True;
            AddStatus(format('Client %s skipped, no chart found',[Client.clExtendedName]));
            Exit;
         end else if not IsCoded(Client,aTrans) then begin
            SkipClient := True;
            AddStatus(format('Client %s skipped, uncoded transactions found',[Client.clExtendedName]));
            Exit;
         end;
      end;
   end;

   //Still Here..
   Result := True;
end;


function TBulkExtractor.LookupChart(const Value: string): string;
begin
   Result := '';
   if (Value > '')
   and Assigned(Client) then
       Result := Client.clChart.FindDesc(Value);
end;

function TBulkExtractor.LookupJob(const Value: string): string;
begin
   Result := '';
   if (Value > '')
   and Assigned(Client) then
       Result := Client.clJobs.JobName(Value);
end;

function TBulkExtractor.LookupTaxClass(const Value: integer; var Code, Desc: string ): boolean;
begin
   Result := false;
   if Assigned(Client)
   and (Value in [1..MAX_GST_CLASS]) then begin
      Desc := Client.clFields.clGST_Class_Names [Value];
      Code := Client.clFields.clGST_Class_Codes [Value];
      Result := True;
   end;
end;

function TBulkExtractor.NeedBankContra: Boolean;
begin
   Result := (tr_Contra and Ft_BankType) = tr_Contra;
end;

function TBulkExtractor.NeedCoded: Boolean;
begin
   Result := (tr_Coded and Ft_TransType) = tr_Coded;
end;

procedure TBulkExtractor.ReportSession(ClearExtract:Boolean);
 var sectionStarted : boolean;
   procedure CheckSection;
   begin
      if not sectionStarted then begin
         if fStatus.Count > 0 then begin
            AddStatus('', false);
            AddStatus('-------------------------------------');
            AddStatus('', false);
         end;
      end;
      sectionStarted := true;
   end;
begin
    sectionStarted := False;
    CheckSection;
    if ClearExtract then
    else begin
       if fTransCount > 0 then begin
          AddStatus(Format('%d Transaction(s) exported'  ,[fTranscount]));
          if fCodedCount > 0 then
             AddStatus(Format('  of which %d were coded'  ,[fCodedCount]));
       end else begin
          AddStatus('No transactions found');
       end;

       if fAccountCount > 0 then begin
          //CheckSection;
          AddStatus(Format('%d Account(s) exported'  ,[fAccountCount]));
       end;
    end;

    if fClientCount > 0 then begin
       //CheckSection;
       AddStatus(Format('%d Client file(s) processed'  ,[fClientCount]));
    end;

    if fClientsSkipped > 0 then begin
       AddStatus(Format('%d Client file(s) not processed', [FClientsSkipped]));
    end;
end;


function TBulkExtractor.StartSession(var Session: TExtractSession): Boolean;
begin
   BankAccount := nil;
   Client := nil;

   FExtractDate := CurrentDate;
   ClearStatus;

   AbortExtract := False;

   // Pass Some basics just in case its needed
   FFields.Clear;

   AddField(f_Code, AdminSystem.fdFields.fdBankLink_Code );
   AddField(f_Name, AdminSystem.fdFields.fdPractice_Name_for_Reports);
   AddField(f_Date,StDateToDateString('ddmmyyyy',Session.FromDate,False)
                   + '_'
                   + StDateToDateString('ddmmyyyy',Session.ToDate,False));
   Result := DoExport(Session,ef_SessionStart,FFields.DelimitedText);
end;

function TBulkExtractor.SessionText(Session: TExtractSession): string;
begin
   Result := Self.Description
          + ' From ' +  StDateToDateString('dd/mm/yyyy',Session.FromDate,False)
          + ' until ' + StDateToDateString('dd/mm/yyyy',Session.ToDate,False)
end;

procedure TBulkExtractor.SetAbortExtract(const Value: Boolean);
begin
  FAbortExtract := Value;
end;

procedure TBulkExtractor.SetBankAccount(const Value: TBank_Account);
begin
  FBankAccount := Value;
end;

procedure TBulkExtractor.SetClient(const Value: TClientObj);
begin
  FClient := Value;
  SkipClient := False;
end;

procedure TBulkExtractor.SetCode(const Value: string);
begin
  FCode := Value;
end;

procedure TBulkExtractor.SetDescription(const Value: string);
begin
  FDescription := Value;
end;

procedure TBulkExtractor.SetExtractClass(const Value: Integer);
begin
  FExtractClass := Value;
end;

procedure TBulkExtractor.SetLibIndex(const Value: Integer);
begin
  FLibIndex := Value;
end;

procedure TBulkExtractor.SetSkipClient(const Value: Boolean);
begin
  FSkipClient := Value;
end;

function TBulkExtractor.TransactionToText(aTrans: pTransaction_Rec): string;

  procedure AddBGL360Fields;
  begin
//  fBGL360_Accrual_Date
    if True then
    
    AddDateField(fBGL360_Accrual_Date, aTrans^.txTransaction_Extension^.teSF_Accrual_Date);
//  fBGL360_Cash_Date
    AddDateField(fBGL360_Cash_Date, aTrans^.txTransaction_Extension^.teSF_Cash_Date);
//  fBGL360_Record_Date
    AddDateField(fBGL360_Record_Date, aTrans^.txTransaction_Extension^.teSF_Record_Date);

   //Distribution Entry Type
       {// sffIdxBGL360_Entry Type}
       {// sffIdxBGL360_Units}
       {// sffIdxBGL360_Cash_Date}
       {// sffIdxBGL360_Accrual Date}
       {// sffIdxBGL360_Record_Date}


///////////// ***************** Share Trade Tab ***************** ////////////////
//    fBGL360_Units
      AddQtyField(fBGL360_Units {fQuantity}, aTrans^.txQuantity);
//    fBGL360_Contract_Date
      AddDateField(fBGL360_Contract_Date, aTrans^.txTransaction_Extension^.teSF_Contract_Date);
//    fBGL360_Settlement_Date
      AddDateField(fBGL360_Settlement_Date, aTrans^.txTransaction_Extension^.teSF_Settlement_Date);
//    fBGL360_Brokerage
      AddMoneyField( fBGL360_Brokerage,
        abs( aTrans^.txTransaction_Extension^.teSF_Share_Brokerage ) ) ;
//    fBGL360_GST_Rate
      AddNumberField( fBGL360_GST_Rate,
        Abs( StrToIntDef( aTrans^.txTransaction_Extension^.teSF_Share_GST_Rate, 0 ) ) );
//    fBGL360_GST_Amount
      AddMoneyField( fBGL360_GST_Amount,
        Abs( aTrans^.txTransaction_Extension^.teSF_Share_GST_Amount ) );
//    fBGL360_Consideration
      AddMoneyField( fBGL360_Consideration,
        ( aTrans^.txTransaction_Extension^.teSF_Share_Consideration ) );
///////////// ***************** Share Trade Tab ***************** ////////////////

///////////// ***************** Dividend / Distribution Tabs ***************** ////////////////
//    fBGL360_Dividends_Franked
      AddMoneyField( fBGL360_Dividends_Franked,
        abs(aTrans^.txSF_Franked) );
//    fBGL360_Dividends_Unfranked
      AddMoneyField( fBGL360_Dividends_Unfranked,
        abs(aTrans^.txSF_Unfranked) );
//    fBGL360_Franking_Credits
      AddMoneyField( fBGL360_Franking_Credits,
        Abs(aTrans^.txSF_Imputed_Credit) );
///////////// ***************** Dividend / Distribution Tabs ***************** ////////////////

///////////// ***************** Distribution / Interest Tabs ***************** ////////////////
//   fBGL360_Interest
      AddMoneyField( fBGL360_Interest,
        Abs( aTrans^.txSF_Interest) );
//    fBGL360_Other_Income
      AddMoneyField( fBGL360_Other_Income,
        Abs(aTrans^.txTransaction_Extension^.teSF_Other_Income ) );
///////////// ***************** Distribution / Interest Tabs ***************** ////////////////

///////////// ***************** Distribution ***************** ////////////////
//    fBGL360_Less_Other_Allowable_Trust_Deductions
      AddMoneyField( fBGL360_Less_Other_Allowable_Trust_Deductions,
        Abs(aTrans^.txTransaction_Extension^.teSF_Other_Trust_Deductions ) );
//    fBGL360_Discounted_Capital_Gain_Before_Discount
      AddMoneyField( fBGL360_Discounted_Capital_Gain_Before_Discount,
        Abs(aTrans^.txSF_Capital_Gains_Disc) );
//    fBGL360_Capital_Gains_CGT_Concessional_Amount
      AddMoneyField( fBGL360_Capital_Gains_CGT_Concessional_Amount,
        Abs(aTrans^.txTransaction_Extension^.teSF_CGT_Concession_Amount ) );
//    fBGL360_Capital_Gain_Indexation_Method
      AddMoneyField( fBGL360_Capital_Gain_Indexation_Method,
        Abs( aTrans^.txSF_Capital_Gains_Indexed) );
//    fBGL360_Capital_Gain_Other_Method
      AddMoneyField( fBGL360_Capital_Gain_Other_Method,
        Abs( aTrans^.txSF_Capital_Gains_Other) );
//    fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount
      AddMoneyField( fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount,
        Abs( aTrans^.txTransaction_Extension^.teSF_CGT_ForeignCGT_Before_Disc ) );
//    fBGL360_Foreign_Capital_Gains_Indexation_Method
      AddMoneyField( fBGL360_Foreign_Capital_Gains_Indexation_Method,
        Abs( aTrans^.txTransaction_Extension^.teSF_CGT_ForeignCGT_Indexation ) );
//    fBGL360_Foreign_Capital_Gains_Other_Method
      AddMoneyField( fBGL360_Foreign_Capital_Gains_Other_Method,
        Abs( aTrans^.txTransaction_Extension^.teSF_CGT_ForeignCGT_Other_Method ) );
//    fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount_Tax_Paid
      AddMoneyField( fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount_Tax_Paid,
        Abs( aTrans^.txSF_Capital_Gains_Foreign_Disc ) );
//    fBGL360_Foreign_Capital_Gains_Indexation_Method_Tax_Paid
      AddMoneyField( fBGL360_Foreign_Capital_Gains_Indexation_Method_Tax_Paid,
        Abs( aTrans^.txTransaction_Extension^.teSF_CGT_TaxPaid_Indexation ) );
//    fBGL360_Foreign_Capital_Gains_Other_Method_Tax_Paid
      AddMoneyField( fBGL360_Foreign_Capital_Gains_Other_Method_Tax_Paid,
        Abs( aTrans^.txTransaction_Extension^.teSF_CGT_TaxPaid_Other_Method ) );
///////////// ***************** Distribution ***************** ////////////////

///////////// ***************** Distribution / Dividend ***************** ////////////////
//    fBGL360_Assessable_Foreign_Source_Income
      AddMoneyField( fBGL360_Assessable_Foreign_Source_Income,
        Abs( aTrans^.txSF_Foreign_Income ) );
//    fBGL360_Foreign_Income_Tax_Paid_Offset_Credits
      AddMoneyField( fBGL360_Foreign_Income_Tax_Paid_Offset_Credits,
        Abs( aTrans^.txSF_Foreign_Tax_Credits ) );
//    fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company
      AddMoneyField( fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company,
        Abs( aTrans^.txTransaction_Extension^.teSF_AU_Franking_Credits_NZ_Co ) );
///////////// ***************** Distribution / Dividend ***************** ////////////////

///////////// ***************** Distribution ***************** ////////////////
//    fBGL360_Other_Net_Foreign_Source_Income
      AddMoneyField( fBGL360_Other_Net_Foreign_Source_Income,
        Abs( aTrans^.txTransaction_Extension^.teSF_Other_Net_Foreign_Income ) );
//    fBGL360_Cash_Distribution
      AddMoneyField( fBGL360_Cash_Distribution,
        Abs( aTrans^.txTransaction_Extension^.teSF_Cash_Distribution ) );
//    fBGL360_Tax_Exempted_Amounts
      AddMoneyField( fBGL360_Tax_Exempted_Amounts,
        Abs( aTrans^.txSF_Tax_Exempt_Dist ) );
//    fBGL360_Tax_Free_Amounts
      AddMoneyField( fBGL360_Tax_Free_Amounts,
        Abs( aTrans^.txSF_Tax_Free_Dist ) );
//    fBGL360_Tax_Deferred_amounts
      AddMoneyField( fBGL360_Tax_Deferred_amounts,
        Abs( aTrans^.txSF_Tax_Deferred_Dist ) );
///////////// ***************** Distribution ***************** ////////////////

///////////// ***************** Distribution / Dividend  / Interest tabs ***************** ////////////////
//    fBGL360_TFN_Amounts_withheld
      AddMoneyField( fBGL360_TFN_Amounts_withheld,
        Abs( aTrans^.txSF_TFN_Credits ) );
//    fBGL360_Non_Resident_Withholding_Tax
      AddMoneyField( fBGL360_Non_Resident_Withholding_Tax,
        Abs( aTrans^.txTransaction_Extension^.teSF_Non_Res_Witholding_Tax ) );
///////////// ***************** Distribution / Dividend  / Interest tabs ***************** ////////////////

///////////// ***************** Distribution Tab ***************** ////////////////
//    fBGL360_Other_Expenses
      AddMoneyField( fBGL360_Other_Expenses,
        Abs( aTrans^.txSF_Other_Expenses ) );
//    fBGL360_Other_Net_Foreign_Source_Income
      AddMoneyField( fBGL360_Other_Net_Foreign_Source_Income,
        Abs( aTrans^.txTransaction_Extension^.teSF_Other_Net_Foreign_Income ) );
//    fBGL360_Cash_Distribution
      AddMoneyField( fBGL360_Cash_Distribution,
        Abs( aTrans^.txTransaction_Extension^.teSF_Cash_Distribution ) );
//    fBGL360_Tax_Exempted_Amounts
      AddMoneyField( fBGL360_Tax_Exempted_Amounts,
      Abs( aTrans^.txSF_Tax_Exempt_Dist ) );
//    fBGL360_Tax_Free_Amounts
      AddMoneyField( fBGL360_Tax_Free_Amounts,
      Abs( aTrans^.txSF_Tax_Free_Dist ) );
//    fBGL360_Tax_Deferred_amounts
      AddMoneyField( fBGL360_Tax_Deferred_amounts,
      Abs( aTrans^.txSF_Tax_Deferred_Dist ) );
//    fBGL360_TFN_Amounts_withheld
      AddMoneyField( fBGL360_TFN_Amounts_withheld,
      Abs( aTrans^.txSF_TFN_Credits ) );
//    fBGL360_Non_Resident_Withholding_Tax
      AddMoneyField( fBGL360_Non_Resident_Withholding_Tax,
        Abs( aTrans^.txTransaction_Extension^.teSF_Non_Res_Witholding_Tax ) );
//    fBGL360_Other_Expenses
      AddMoneyField( fBGL360_Other_Expenses,
      Abs( aTrans^.txSF_Other_Expenses ) );
///////////// ***************** Distribution Tab ***************** ////////////////

///////////// ***************** Distribution / Dividend Tabs ***************** ////////////////
//    fBGL360_LIC_Deduction
      AddMoneyField( fBGL360_LIC_Deductions,
        Abs( aTrans^.txTransaction_Extension^.teSF_LIC_Deductions ) );
///////////// ***************** Distribution / Dividend Tabs ***************** ////////////////

///////////// ***************** Distribution Tab ***************** ////////////////
//    fBGL360_Discounted_Capital_Gain_Before_Discount_Non_Cash
      AddMoneyField( fBGL360_Discounted_Capital_Gain_Before_Discount_Non_Cash,
        Abs( aTrans^.txTransaction_Extension^.teSF_Non_Cash_CGT_Discounted_Before_Discount ) );
//    fBGL360_Capital_Gains_Indexation_Method_Non_Cash
      AddMoneyField( fBGL360_Capital_Gains_Indexation_Method_Non_Cash,
        Abs( aTrans^.txTransaction_Extension^.teSF_Non_Cash_CGT_Indexation ) );
//    fBGL360_Capital_Gains_Other_Method_Non_Cash
      AddMoneyField( fBGL360_Capital_Gains_Other_Method_Non_Cash,
        Abs( aTrans^.txTransaction_Extension^.teSF_Non_Cash_CGT_Other_Method ) );
//    fBGL360_Capital_Losses_Non_Cash
      AddMoneyField( fBGL360_Capital_Losses_Non_Cash,
        Abs( aTrans^.txTransaction_Extension^.teSF_Non_Cash_CGT_Capital_Losses ) );
///////////// ***************** Distribution Tab ***************** ////////////////
  end;
begin
   FFields.Clear;
   AddNumberField(f_Line,FlineCount);
   AddNumberField(f_Trans,FTransCount);
   // Any other IDs

   case Ft_TransID of
     tr_BNotes   : AddNumberField(f_TransID,aTrans.txECoding_Transaction_UID);
     tr_GUID     : AddField(f_TransID,aTrans.txExternal_GUID);
   end;

   AddDateField(f_Date,aTrans.txDate_Effective);
   AddMoneyField(f_Amount,aTrans.txAmount);

   AddTaxFields(aTrans.txGST_Amount, aTrans.txGST_Class);

   AddQtyField(f_Quantity, aTrans.txQuantity);
   AddNumberField(f_TransType, aTrans.txType);

   // Narratives
   if Atrans.txCheque_Number <> 0 then
      AddNumberField(f_ChequeNo, Atrans.txCheque_Number);

   AddField(f_Reference,   aTrans.txReference);
   AddField(f_Analysis,    aTrans.txAnalysis);
   AddField(f_OtherParty,  aTrans.txOther_Party);
   AddField(f_Particulars, aTrans.txParticulars);
   AddField(f_Narration,   aTrans.txGL_Narration);
   AddField(f_Notes,       GetFullNotes(aTrans));

   // Coding
   AddField(f_Code,aTrans.txAccount);
   AddField(f_Desc,LookupChart(aTrans.txAccount));
   // Job
   AddField(f_JobCode, aTrans.txJob_Code);
   AddField(f_JobDesc, lookupJob(aTrans.txJob_Code));

   // Superfund...
   if IsSuperFund(Client.clFields.clCountry,Client.clFields.clAccounting_System_Used) then begin

       // Common Fields (Typically Money)
       AddDateField(f_CGTDate,aTrans.txSF_CGT_Date);

       AddMoneyField(f_Franked,aTrans.txSF_Franked);
       AddMoneyField(f_UnFranked,aTrans.txSF_UnFranked);

       AddMoneyField(f_Imp_Credit,aTrans.txSF_Imputed_Credit);
       AddMoneyField(f_TFN_Credit,aTrans.txSF_TFN_Credits);
       AddMoneyField(f_Frn_Credit,aTrans.txSF_Foreign_Tax_Credits);

       AddMoneyField(f_TF_Dist,aTrans.txSF_Tax_Free_Dist);
       AddMoneyField(f_TE_Dist,aTrans.txSF_Tax_Exempt_Dist);
       AddMoneyField(f_TD_Dist,aTrans.txSF_Tax_Deferred_Dist);

       AddMoneyField(f_CGI,aTrans.txSF_Capital_Gains_Indexed);
       AddMoneyField(f_CGD,aTrans.txSF_Capital_Gains_Disc);
       AddMoneyField(f_CGO,aTrans.txSF_Capital_Gains_Other);

       AddMoneyField(f_Frn_Income,aTrans.txSF_Foreign_Income);
       AddMoneyField(f_CGO,aTrans.txSF_Capital_Gains_Other);

       AddMoneyField(f_OExpences,aTrans.txSF_Other_Expenses);
       AddMoneyField(f_Interest, aTrans.txSF_Interest);
       AddMoneyField(f_ForeignCG, aTrans.txSF_Capital_Gains_Other);
       AddMoneyField(f_ForeignDiscCG, aTrans.txSF_Capital_Gains_Foreign_Disc);
       AddMoneyField(f_Rent, aTrans.txSF_Rent);
       AddMoneyField(f_SpecialIncome, aTrans.txSF_Special_Income);
       AddMoneyField(f_ForeignCGCredit, aTrans.txSF_Foreign_Capital_Gains_Credit);
       AddMoneyField(f_OT_Credit, aTrans.txSF_Other_Tax_Credit);
       AddMoneyField(f_NonResidentTax, aTrans.txSF_Non_Resident_Tax);

       // Fund, Member and Transaction are more system specific
       case Client.clFields.clAccounting_System_Used of
         saBGLSimpleFund,
         saBGLSimpleLedger : AddBGLFields( aTrans.txDate_Effective,
                                           aTrans.txSF_Member_Component );

         saBGL360: begin
           AddBGL360ComponentFields( aTrans.txDate_Effective,
                                    aTrans.txSF_Member_Component );
           AddBGL360Fields;
         end;

         saSupervisor, saSolution6SuperFund: ;

         saDesktopSuper:  begin
               if aTrans.txSF_Transaction_ID <> -1 then
                  AddNumberField(f_SFTransID, aTrans.txSF_Transaction_ID);

               if aTrans.txSF_Fund_ID <> -1 then
                  AddNumberField(f_FundID, aTrans.txSF_Fund_ID);

               if aTrans.txSF_Member_Account_ID <> -1 then
                  AddNumberField(f_MemID, aTrans.txSF_Member_Account_ID);

               if aTrans.txSF_Capital_Gains_Foreign_Disc <> 0 then
                  AddFractionField(f_CGFraction, aTrans.txSF_Capital_Gains_Fraction_Half);
           end;

         saClassSuperIp: begin
               AddField(f_FundID, aTrans.txSF_Fund_Code);
               AddField(f_MemID, aTrans.txSF_Member_Account_Code);
               AddFractionField(f_CGFraction, aTrans.txSF_Capital_Gains_Fraction_Half);
            end;

         saSageHandisoftSuperfund:
           if aTrans.txSF_Transaction_ID <> -1 then begin
              AddField(f_SFTransID, TypesArray[TTxnTypes(aTrans.txSF_Transaction_ID)]);
              AddField(f_SFTransCode, aTrans.txSF_Transaction_Code);
           end;

         saSuperMate: begin
              AddField(f_MemID, aTrans.txSF_Member_ID);
         end;

       end;

   end;


   // Running balance
   if FCurrentBal <> Unknown then
      AddMoneyField(f_Balance,FCurrentBal);
   Result := FFields.DelimitedText;
end;



{ TfrmBulkExtract }

procedure TfrmBulkExtract.btnOKClick(Sender: TObject);
begin
   if not Validate then
      Exit;

   Modalresult := mrOK;
end;



procedure TfrmBulkExtract.btnSetupClick(Sender: TObject);
var lExtract: TBulkExtractor;
begin
   lExtract := BulkExtractors.GetComboBoxExtractor(cbExtractor);
   if assigned(LExtract) then
      LExtract.DoConfig;
end;

procedure TfrmBulkExtract.FormCreate(Sender: TObject);
begin
    bkXPThemes.ThemeForm( Self);
    self.DateSelector.InitDateSelect(0,maxint,nil);
    Selected := nil;
end;

procedure TfrmBulkExtract.UpdateActions;
var lExtract: TBulkExtractor;
begin
   inherited;
   lExtract := BulkExtractors.GetComboBoxExtractor(cbExtractor);
   if assigned(LExtract) then
       btnSetup.Enabled := LExtract.CanConfig
   else
      btnSetup.Enabled := false;
end;

function TfrmBulkExtract.Validate: Boolean;
var I: Integer;
    lExtract: TBulkExtractor;
    CFRec: pClient_File_Rec;

begin
   Result := False;

   lExtract := BulkExtractors.GetComboBoxExtractor(cbExtractor);
   // Basic validation
   if not assigned(lExtract) then begin
      HelpfulInfoMsg( 'Please select an export format.', 0 );
      if Self.Visible
      and cbExtractor.CanFocus then
         cbExtractor.SetFocus;
      Exit;
   end;

   if not DateSelector.ValidateDates(true) then
      Exit;
   // Test the adminSystem
   lExtract.ClearStatus;
   lExtract.CanConfig;//Make sure this get called for sa_BulkExport
   RefreshAdmin;
   for i := AdminSystem.fdSystem_Client_File_List.First to AdminSystem.fdSystem_Client_File_List.Last do begin
      CFRec := AdminSystem.fdSystem_Client_File_List.Client_File_At(i);
      if CFRec.cfArchived then
         Continue; // Dont care much

      if lExtract.Code <> CFRec.cfBulk_Extract_Code then
         Continue; // Not Included..


      if Assigned(Selected) then
         if Selected.IndexOf(CFRec.cfFile_Code) < 0 then
            Continue; // Not Part of the selected ..

      if CFRec.cfFile_Status = fsnormal then begin
         inc(LExtract.FClientCount);
      end else begin
         LExtract.AddStatus(LExtract.ClientStatustext(CFRec), false);
         inc(LExtract.FClientsSkipped );
      end;
   end;

   if lExtract.FStatus.Count > 0 then begin
            // Have s
      lExtract.FStatus.Insert(0, ' ');
      lExtract.FStatus.Insert(0, 'The following files may not be included in the process:' );

      if ShowExtractResults(format('Problem with %s %s ',[LExtract.FDescription, Self.Caption] ),
                                lExtract.FStatus,False) <> mrOK then
             Exit;
   end;

   if LExtract.FClientCount  = 0 then begin
      HelpfulInfoMsg(format( 'No Client files found for %s export format', [LExtract.FDescription]) , 0 );
      Exit;
   end;
   // Still here...
   Result := True;
end;

{ TfrmAssignBulkExtract }

function TfrmAssignBulkExtract.Validate: Boolean;
var I: Integer;
    lExtract: TBulkExtractor;
    CFRec: pClient_File_Rec;
    lCount: Integer;
    NewCode: string;
begin
   Result := False;
   if not Assigned(Selected) then
      Exit; //Savety net

   if cbExtractor.ItemIndex < 0 then
      Exit;

   if cbExtractor.ItemIndex = 0 then
      NewCode := ''
   else begin
      lExtract := BulkExtractors.GetComboBoxExtractor(cbExtractor);
      // Basic validation
      if not Assigned(lExtract) then begin // ?? Will never hapen
         HelpfulInfoMsg( 'Please select an export format.', 0 );
         if self.Visible
         and cbExtractor.CanFocus then
            cbExtractor.SetFocus;
         Exit;
      end;
      NewCode := LExtract.Code;
   end;

   // Might as well do the job...
   lCount := 0;
   if LoadAdminSystem(True,'Assign BulkExport') then try
       for I := 0 to Selected.Count - 1 do begin
           CFRec := AdminSystem.fdSystem_Client_File_List.FindCode(Selected[I]);
           if Assigned(CFRec) then begin
              if CFRec.cfBulk_Extract_Code <> NewCode then begin
                 CFRec.cfBulk_Extract_Code := NewCode;
                 Inc(lCount);
              end;
           end;

       end;
   finally
       if LCount > 0 then
          SaveAdminSystem
       else
          UnlockAdmin;//Nothing to save...
   end;

   if lCount > 0 then
      HelpfulInfoMsg('New settings have been applied:'#13#13
                     + Format('%d client(s) updated',[lCount]) , 0 )
   else begin
      HelpfulInfoMsg('No Client files updated' , 0 );
      ModalResult := mrCancel;
      Exit;//Should not need this...
   end;

   Result := true;
end;

initialization
   FBulkExtractors := nil;
finalization
   CleanupBulkExtract;
end.




