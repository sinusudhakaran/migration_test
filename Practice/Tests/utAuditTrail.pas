unit utAuditTrail;

interface

uses
  TestFramework, SysUtils, AuditMgr;

{$TYPEINFO ON} //Needed for classes with published methods

type
  TTestMethod = procedure of object;

  TAuditTrailTestCase = class(TTestCase)
  private
    FAuditLog: TextFile;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure OutputAuditFieldsForSystemDB;
    procedure OutputAuditFieldsForClientDB;
  published
    procedure TestAuditPracticeDetails;
  end;

implementation

uses
  Classes, DBCreate, SysObj32, Globals, bkConst, SYAuditValues, baObj32,
  clObj32, trxList32,
  SYDEFS, SYATIO, SYFDIO, SYUSIO, SYCFIO, SYSBIO, SYCTIO, SYSMIO, SYAMIO,
  BKDEFS, BKBAIO, BKCHIO, BKDSIO;

{ TMemorisationsTestCase }

procedure TAuditTrailTestCase.OutputAuditFieldsForClientDB;
const
  Apr01_2004 = 147649;
  Apr02_2004 = Apr01_2004 + 1;
  Apr03_2004 = Apr01_2004 + 2;
  Apr04_2004 = Apr01_2004 + 3;
  Apr05_2004 = Apr01_2004 + 4;
var
  AuditIdx: integer;
  ba: TBank_Account;
  pt: pTransaction_Rec;
  pD: pDissection_Rec;
  BK5TestClient: TClientObj;
  Chart100: pAccount_Rec;
  ValueList: TStringList;
  AuditFieldsFile: TextFile;

  procedure OutputValues(Index: integer);
  var
    i: integer;
    AuditRecord: pAudit_Trail_Rec;
    Values: string;
  begin
    //get values
    with BK5TestClient.AuditTable do
      AuditRecord := AuditRecords.Audit_Pointer_At(Index);
    BK5TestClient.ClientAuditMgr.GetValues(AuditRecord^, Values);
    ValueList.DelimitedText := Values;
    //output to file AuditFieldsSystem.txt
    Write(AuditFieldsFile, '*** ' + BK5TestClient.ClientAuditMgr.AuditTypeToStr(AuditRecord.atTransaction_Type) + ' ***' + sLineBreak);
    for i := 0 to ValueList.Count - 1 do
      Write(AuditFieldsFile, ValueList[i] + sLineBreak);
    Write(AuditFieldsFile, sLineBreak);
    ValueList.Clear;
  end;

begin
  //create a test client
  BK5TestClient := TClientObj.Create;
  try
    //basic client details
    BK5TestClient.clFields.clCode := 'UNITTEST';
    BK5TestClient.clFields.clName := 'DUnit Test Client';
    BK5TestClient.clFields.clCountry := 2;    //UK
    BK5TestClient.Save;

    //Rest of client details
    BK5TestClient.clFields.clFile_Type := 0;  //banklink file
    BK5TestClient.clFields.clAccounting_System_Used := 0;
    BK5TestClient.clFields.clFinancial_Year_Starts := 147649; //01 April 2004
    BK5TestClient.clFields.clMagic_Number  := 123456;

    //gst rates (NZ)
    BK5TestClient.clFields.clGST_Applies_From[1] := 138883; // 01 Jan 1980

    {Income}
    BK5TestClient.clFields.clGST_Class_Codes[1]  := 'I';
    BK5TestClient.clFields.clGST_Class_Names[1]  := 'GST on Sales';
    BK5TestClient.clFields.clGST_Class_Types[1]  := gtOutputTax;
    BK5TestClient.clFields.clGST_Rates[1,1]      := 125000;
    {Expenditure}
    BK5TestClient.clFields.clGST_Class_Codes[2]  := 'E';
    BK5TestClient.clFields.clGST_Class_Names[2]  := 'GST on Purchases';
    BK5TestClient.clFields.clGST_Class_Types[2]  := gtInputTax;
    BK5TestClient.clFields.clGST_Rates[2,1]      := 125000;
    {Exempt}
    BK5TestClient.clFields.clGST_Class_Codes[3]  := 'X';
    BK5TestClient.clFields.clGST_Class_Names[3]  := 'Exempt';
    BK5TestClient.clFields.clGST_Class_Types[3]  := gtExempt;
    BK5TestClient.clFields.clGST_Rates[3,1]      := 0;
    BK5TestClient.ClExtra.ceLocal_Currency_Code  := 'NZD';

    //Chart
    Chart100 := New_Account_Rec;
    Chart100^.chAccount_Code := '230';
    Chart100^.chAccount_Description := 'Sales';
    Chart100^.chGST_Class := 1;
    Chart100^.chPosting_Allowed := true;
    BK5TestClient.clChart.Insert(Chart100);
    BK5TestClient.ClientAuditMgr.FlagAudit(arChartofAccounts);

    //Bank account
    ba := TBank_Account.Create(BK5TestClient);
    ba.baFields.baBank_Account_Number := '12345';
    ba.baFields.baBank_Account_Name   := 'Account 1';
    ba.baFields.baCurrent_Balance := 100;
    ba.baFields.baContra_Account_Code := '680';
    ba.baFields.baCurrency_Code := 'GBP';
    bk5testClient.clBank_Account_List.Insert(ba);

    //Transaction
    pT := ba.baTransaction_List.Setup_New_Transaction;
    pT^.txDate_Presented  := Apr01_2004;
    pT.txDate_Effective   := Apr01_2004;
    pT.txAmount           := 6000;
    pT.txAccount          := '230';
    pT.txNotes            := 'NOTE';
    pT.txGL_Narration     := 'Account 1 Tran1';
    pT.txTax_Invoice_Available   := false;
    pT.txPayee_Number     := 0;
    pT.txGST_Class := 1;
    pt.txGST_Amount := Round(12000 / 9);
    pT.txExternal_GUID := '11';
    //Dissection
    pD := New_Dissection_Rec;
    pD^.dsAccount         := '400';
    pD.dsAmount           := 6000;
    pD.dsGST_Class        := 2;
    pD.dsGST_Amount       := Round(6000/9);
    pD.dsNotes            := 'L1 NOTE';
    pD.dsGL_Narration     := 'Line 1';
    AppendDissection( pT, pD);
    ba.baTransaction_List.Insert_Transaction_Rec( pT);

    //ToDo
    //Client Rec
    //Payee
    //Custom Headings
    //Memorisation
    //VAT Setup
    //Historical Entries
    //Provisional Entries
    //Manual Entries
    //Automatic Coding
    //Journals
    //Opening Balances
    //Unpresented Items
    //BankLink Notes
    //BankLink Notes Online
    //BankLink Books

    BK5TestClient.Save;
    ValueList := TStringList.Create;
    try
      ValueList.StrictDelimiter := True;
      ValueList.Delimiter := VALUES_DELIMITER;
      Assign(AuditFieldsFile, 'AuditFieldsClient.txt');
      Rewrite(AuditFieldsFile);
      for AuditIdx := 0 to BK5TestClient.AuditTable.AuditRecords.ItemCount - 1 do
        OutputValues(AuditIdx);
      CloseFile(AuditFieldsFile);
    finally
      ValueList.Free;
    end;

  finally
    BK5TestClient.Free;
  end;
end;

procedure TAuditTrailTestCase.OutputAuditFieldsForSystemDB;
var
  User_Rec: pUser_Rec;
  Values: string;
  AuditFieldsFile: TextFile;
  ValueList: TStringList;
  Client_File_Rec: pClient_File_Rec;
  AuditRecord: pAudit_Trail_Rec;
  System_Bank_Account_Rec: pSystem_Bank_Account_Rec;
  Client_Account_Map_Rec: pClient_Account_Map_Rec;
  Client_Type_Rec: pClient_Type_Rec;
  System_Memorisation_List_Rec: pSystem_Memorisation_List_Rec;

  procedure OutputValues;
  var
    i: integer;
  begin
    //get values
    with AdminSystem.AuditTable do
      AuditRecord := AuditRecords.Audit_Pointer_At(AuditRecords.ItemCount - 1);
    SystemAuditMgr.GetValues(AuditRecord^, Values);
    ValueList.DelimitedText := Values;
    //output to file AuditFieldsSystem.txt
    Write(AuditFieldsFile, '*** ' + SystemAuditMgr.AuditTypeToStr(AuditRecord.atTransaction_Type) + ' ***' + sLineBreak);
    for i := 0 to ValueList.Count - 1 do
      Write(AuditFieldsFile, ValueList[i] + sLineBreak);
    Write(AuditFieldsFile, sLineBreak);
    ValueList.Clear;
  end;
begin
  //Create Audit Fields File
  Assign(AuditFieldsFile, 'AuditFieldsSystem.txt');
  Rewrite(AuditFieldsFile);

  ValueList := TStringList.Create;
  try
    ValueList.StrictDelimiter := True;
    ValueList.Delimiter := VALUES_DELIMITER;
    //Practice Details
    OutputValues;    
    //Users
    User_Rec := New_User_Rec;
    AdminSystem.fdSystem_User_List.Insert(User_Rec);
    SystemAuditMgr.FlagAudit(arUsers);
    AdminSystem.Save;
    OutputValues;
    //Client File List
    Client_File_Rec := New_Client_File_Rec;
    Client_File_Rec.cfLRN := 1;
    Client_File_Rec.cfFile_Code := 'TESTCODE';
    AdminSystem.fdSystem_Client_File_List.Insert(Client_File_Rec);
    SystemAuditMgr.FlagAudit(arSystemClientFiles);
    AdminSystem.Save;
    OutputValues;
    //Bank Account List
    System_Bank_Account_Rec := New_System_Bank_Account_Rec;
    System_Bank_Account_Rec.sbLRN := 1;
    System_Bank_Account_Rec.sbAccount_Number := '99999999999';
    System_Bank_Account_Rec.sbAccount_Name := 'TEST SYSTEM BANK ACCOUNT';    
    AdminSystem.fdSystem_Bank_Account_List.Insert(System_Bank_Account_Rec);
    SystemAuditMgr.FlagAudit(arSystemBankAccounts);
    AdminSystem.Save;
    OutputValues;
    //Client Account Map
    Client_Account_Map_Rec := New_Client_Account_Map_Rec;
    Client_Account_Map_Rec.amClient_LRN := 1;
    Client_Account_Map_Rec.amAccount_LRN := 1;
    AdminSystem.fdSystem_Client_Account_Map.Insert(Client_Account_Map_Rec);
    SystemAuditMgr.FlagAudit(arAttachBankAccounts);
    AdminSystem.Save;
    OutputValues;
//    //Client Type List
//    Client_Type_Rec := New_Client_Type_Rec;
//    AdminSystem.fdSystem_Client_Type_List.Insert(Client_Type_Rec);
//    SystemAuditMgr.FlagAudit(arSystemClientFiles); //No seperate audit type
//    AdminSystem.Save;
//    OutputValues;
    //Memorisation List
    System_Memorisation_List_Rec := New_System_Memorisation_List_Rec;
    AdminSystem.fSystem_Memorisation_List.Insert(System_Memorisation_List_Rec);
    SystemAuditMgr.FlagAudit(arMasterMemorisations);
    AdminSystem.Save;
    OutputValues;
  finally
    ValueList.Free;
  end;
  CloseFile(AuditFieldsFile);
end;

procedure TAuditTrailTestCase.Setup;
begin
  inherited;
  //Create admin system
  NewAdminSystem(whUK, 'MEMTEST', 'Test Admin system for unit testing');
  AdminSystem.TestSystemFileName := DATADIR + 'TESTSYSTEM.DB';
  AdminSystem.Save;
  SystemAuditMgr.Country := whUK;
  //Create audit log
  Assign(FAuditLog, 'AuditLog.txt');
  Rewrite(FAuditLog);
end;

procedure TAuditTrailTestCase.TearDown;
begin
  CloseFile(FAuditLog);
  FreeAndNil(AdminSystem);
  inherited;
end;

procedure TAuditTrailTestCase.TestAuditPracticeDetails;
var
  AuditRecord: pAudit_Trail_Rec;
  ValuesBefore, ValuesAfter: string;
  PracticeDetailsBefore: string;
begin
  CheckEquals(Assigned(AdminSystem), True, 'Check admin system assigned');
  //Set audit data for practice details fields
  AdminSystem.fdFields.fdPractice_Name_for_Reports := 'Practice_Name_for_Reports';
  AdminSystem.fdFields.fdPractice_Phone := 'Practice_Phone';
  AdminSystem.fdFields.fdPractice_EMail_Address := 'email_address@test.com';
  AdminSystem.fdFields.fdPractice_Web_Site := 'www.Practice_Web_Site.com';
  AdminSystem.fdFields.fdPractice_Logo_Filename := 'practicelogo.jpg';
  AdminSystem.fdFields.fdBankLink_Code := 'AUDIT';
  AdminSystem.fdFields.fdDisk_Sequence_No := 1;
  AdminSystem.fdFields.fdAccounting_System_Used := 1;
  AdminSystem.fdFields.fdGST_Class_Names[1] := 'GST_Class_Names';
  AdminSystem.fdFields.fdGST_Rates[1, 1] := 1000;
  AdminSystem.fdFields.fdGST_Rates[1, 2] := 2000;
  AdminSystem.fdFields.fdGST_Rates[1, 3] := 3000;
  AdminSystem.fdFields.fdGST_Applies_From[1] := 15024;
  //***System Options
  AdminSystem.fdFields.fdSystem_Report_Password := 'System_Report_Password';
  AdminSystem.fdFields.fdBulk_Export_Enabled := True;
  AdminSystem.fdFields.fdBulk_Export_Code := 'Bulk_Export_Code';
  AdminSystem.fdFields.fdUpdates_Pending := True;
  AdminSystem.fdFields.fdUpdate_Server_For_Offsites := 'Update_Server_For_Offsites';
  AdminSystem.fdFields.fdLogin_Bitmap_Filename := 'Login_Bitmap_Filename';
  AdminSystem.fdFields.fdForce_Login := True;
  AdminSystem.fdFields.fdAuto_Print_Sched_Rep_Summary := True;
  AdminSystem.fdFields.fdIgnore_Quantity_In_Download := True;
  AdminSystem.fdFields.fdReplace_Narration_With_Payee := True;
  AdminSystem.fdFields.fdCollect_Usage_Data := False;
  AdminSystem.fdFields.fdAuto_Retrieve_New_Transactions := True;
  AdminSystem.fdFields.fdMaximum_Narration_Extract := 10;
  AdminSystem.fdFields.fdCoding_Font := 'Coding_Font';
  AdminSystem.fdFields.fdCopy_Dissection_Narration := True;
  AdminSystem.fdFields.fdUse_Xlon_Chart_Order := True;
  AdminSystem.fdFields.fdExtract_Multiple_Accounts_PA := True;
  AdminSystem.fdFields.fdExtract_Journal_Accounts_PA := True;
  AdminSystem.fdFields.fdExtract_Quantity := True;
  AdminSystem.fdFields.fdExtract_Quantity_Decimal_Places := 1;

  AuditRecord := New_Audit_Trail_Rec;
  try
    AuditRecord.atAudit_ID := 0;
    AuditRecord.atTransaction_Type := arPracticeSetup;
    AuditRecord.atAudit_Action := aaAdd;
    AuditRecord.atDate_Time := Now;
    AuditRecord.atUser_Code := 'SYSTEM';
    AuditRecord.atRecord_ID := 0;
    AuditRecord.atParent_ID := -1;
    SetAllFieldsChanged(TChanged_Fields_Array(AuditRecord.atChanged_Fields));
    AuditRecord.atOther_Info := '';
    AuditRecord.atAudit_Record_Type := tkBegin_Practice_Details;
    SystemAuditMgr.CopyAuditRecord(tkBegin_Practice_Details, @AdminSystem.fdFields, AuditRecord.atAudit_Record);
    SystemAuditMgr.GetValues(AuditRecord^, PracticeDetailsBefore);
    Write(FAuditLog, 'BEFORE_SAVE' + PracticeDetailsBefore + sLineBreak);
  finally
    Dispose(AuditRecord);
  end;

  //Flag audit
  AdminSystem.fdFields.fdAudit_Record_ID := 0;
  SystemAuditMgr.FlagAudit(arPracticeSetup);

  //Save and free the admin system
  AdminSystem.Save;
  SystemAuditMgr.GetValues(AdminSystem.AuditTable.AuditRecords.Audit_At(0), ValuesBefore);
  Write(FAuditLog, 'AFTER_SAVE ' + ValuesBefore + sLineBreak);
  FreeAndNil(AdminSystem);

  //Reload admin system
  AdminSystem := TSystemObj.Create;
  AdminSystem.TestSystemFileName := DATADIR + 'TESTSYSTEM.DB';
  AdminSystem.Open;

  //Tests
  CheckEquals(AdminSystem.AuditTable.AuditRecords.ItemCount, 1, 'Check practice details audited');
  AuditRecord := AdminSystem.AuditTable.AuditRecords.Audit_Pointer_At(0);
  if Assigned(AuditRecord) then begin
    //Practice details can only ever be a change audit 
    CheckEquals(AuditRecord.atAudit_Action, aaChange, 'Check practice details add');
    SystemAuditMgr.GetValues(AuditRecord^, ValuesAfter);
    Write(FAuditLog, 'AFTER_READ ' + ValuesAfter + sLineBreak);
    CheckEquals(ValuesBefore, ValuesAfter, 'Check practice details values saved');
  end else
    Fail('Practice details add audit not found');

  OutputAuditFieldsForSystemDB;
  OutputAuditFieldsForClientDB;
end;

initialization
  TestFramework.RegisterTest(TAuditTrailTestCase.Suite);
end.
