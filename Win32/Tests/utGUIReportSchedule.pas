// seeing how useful gui testing wud be...
unit utGUIReportSchedule;
{$TYPEINFO ON} //Needed for classes with published methods
interface

uses TestFrameWork, GUITesting, clObj32, ClientReportScheduleDlg;

type
  TReportSetupTest = class(TGUITestCase)
  private
    BK5TestClient : TClientObj;
    MyDlg : TdlgClientReportSchedule;
  protected
    procedure SetUp; override;
    procedure CreateBK5TestClient;
  published
    procedure BNotesEnableButton;
    procedure EMailEnableButton;
    procedure WebEnableButton;
    procedure StoreEmail;
  public
    procedure TearDown; override;
  end;

implementation

procedure TReportSetupTest.BNotesEnablebutton;
begin
  ClickLeftMouseButtonOn(MyDlg.rbToECoding);
  CheckEnabled(MyDlg.btnECodingSetup);
end;

procedure TReportSetupTest.EmailEnablebutton;
begin
  ClickLeftMouseButtonOn(MyDlg.rbToEMail);
  CheckEnabled(MyDlg.cmbEmailFormat);
end;

procedure TReportSetupTest.WebEnablebutton;
begin
  ClickLeftMouseButtonOn(MyDlg.rbToWebX);
  CheckEnabled(MyDlg.btnWebXSetup);
end;

procedure TReportSetupTest.StoreEmail;
begin
  ClickLeftMouseButtonOn(MyDlg.rbToEMail);
  EnterTextInto(MyDlg.eMail, 'steve.teare@banklink.co.nz');
  WriteClientSchedule(BK5TestClient, MyDlg);
  Check(BK5TestClient.clFields.clClient_EMail_Address = 'steve.teare@banklink.co.nz');
  Check(BK5TestClient.clFields.clEmail_Scheduled_Reports);
end;

procedure TReportSetupTest.Setup;
begin
  CreateBK5TestClient;
  MyDlg := TdlgClientReportSchedule.Create(nil);
  MyDlg.ClientToUse := BK5TestClient;
  ReadClientSchedule(BK5TestClient, MyDlg);
  GUI := MyDlg;
end;

procedure TReportSetupTest.TearDown;
begin
  BK5TestClient.Free;
  inherited; // frees GUI
end;

procedure TReportSetupTest.CreateBK5TestClient;
begin
  //create a test client
  BK5TestClient := TClientObj.Create;
  //basic client details
  BK5TestClient.clFields.clCode := 'UNITTEST';
  BK5TestClient.clFields.clName := 'DUnit Test Client';
  BK5TestClient.clFields.clCountry := 0;    //New Zealand
  BK5TestClient.clFields.clFile_Type := 0;  //banklink file
  BK5TestClient.clFields.clAccounting_System_Used := 0;
  BK5TestClient.clFields.clFinancial_Year_Starts := 147649; //01 April 2004
  BK5TestClient.clFields.clMagic_Number  := 123456;
  BK5TestClient.clExtra.ceLocal_Currency_Code := 'NZD';
end;

initialization
  TestFramework.RegisterTest(TReportSetupTest.Suite);

end.
