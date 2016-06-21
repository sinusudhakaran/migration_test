unit UFrmTestRESTClient;

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
  StdCtrls,
  Buttons,
  ExtCtrls,
  WinUtils,
  SyDefs,
  ComCtrls,
  sysobj32,
  appuserobj,
  INISettings,
  Globals,
  BaseRESTClient,
  clObj32,
  BKdsIO,
  baObj32,
  BkDefs,
  bkChio,
  trxList32,
  PracticeLedgerObj,
  uLeanEngageLib,
  IdCoder,
  IdCoderMIME;

type
  TFrmTestRESTClient = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnCallAPI: TBitBtn;
    rgOptions: TRadioGroup;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    procedure btnCallAPIClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    Token : TAPIAuthTokens;
    BK5TestClient : TClientObj;
    Chart230,
    Chart400 : pAccount_Rec;
    procedure CreateBK5TestClient;

    procedure ThreadFinish(var AAPIResponse : string);
    procedure ThreadError(var AAPIError : string);
    
    procedure LeanIdentityFinish(var AAPIResponse : string);
    procedure LeanIdentityError(var AAPIError : string);

    procedure LeanSurveyFinish(var AAPIResponse : string);
    procedure LeanSurveyError(var AAPIError : string);

    function Base64Encode( aString : string ) : string;
  public
    { Public declarations }
  end;

var
  FrmTestRESTClient: TFrmTestRESTClient;

const
  MY_DOT_GRANT_PASSWORD = 'password';
  CASHBOOK_AUTH_PREFIX = 'Bearer ';

  cttGST = 'GST';
  cttNA  = 'NA';

  ctiCAP = 1;
  cttCAP = 'CAP';
  ctnCAP = 'Capital Acquisitions';

  ctiEXP = 2;
  cttEXP = 'EXP';
  ctnEXP = 'Export Sales';

  ctiFRE = 3;
  cttFRE = 'FRE';
  ctnFRE = 'GST Free';

  ctiGNR = 4;
  cttGNR = 'GNR';
  ctnGNR = 'Not Registered';

  ctiGSTI = 5;
  cttGSTI = GSTIncome;
  ctnGSTI = 'Goods & Services Input Tax';

  ctiGSTO = 6;
  cttGSTO = GSTOutcome;
  ctnGSTO = 'Goods & Services Output Tax';

  ctiUnCAT = 7;
  cttUnCAT = GSTUnCategorised;
  ctnUCAT = 'Goods & Services Uncategorised Tax';

  ctiINP = 8;
  cttINP = 'INP';
  ctnINP = 'Input Taxed Purchases';

  ctiITS = 9;
  cttITS = 'ITS';
  ctnITS = 'Input Tax Sales';

  ctiNTR = 10;
  cttNTR = 'NTR';
  ctnNTR = 'Not Reportable';

  Apr01_2004 = 147649;
  Apr02_2004 = Apr01_2004 + 1;
  Apr03_2004 = Apr01_2004 + 2;
  Apr04_2004 = Apr01_2004 + 3;
  Apr05_2004 = Apr01_2004 + 4;

implementation

uses
  uLKJSON,
  PromoWindowObj,
  CashbookMigration,
  CashbookMigrationRestData;
  
{$R *.dfm}

function TFrmTestRESTClient.Base64Encode(aString: string): string;
begin
  Result := IdCoder.EncodeString(TIdEncoderMIME, aString);
end;

procedure TFrmTestRESTClient.btnCallAPIClick(Sender: TObject);
var
  BaseClient : TRESTClient;
  RetryCount , Retries : Integer;
  Response : string;
  APIError : string;
  URL, Auth : string;
  PostData : TStringList;
  HTTPParams : THTTPParams;
  Selected : TStringList;
  RequestJson : TlkJSONobject;
  BankAcToExport : TBankAccountData;
  Identity : TLEIdentity;
begin
  Retries := 0;
  ReadPracticeINI;
  BaseClient := TRESTClient.Create(Nil);
  APIError := '';
  Response := '';
  HTTPParams := THTTPParams.Create;

  try
    case rgOptions.ItemIndex of
      0: // get contentful
      begin
        HTTPParams.RequestURL := rgOptions.Items[rgOptions.ItemIndex] + '/' + PRACTICE_CONTENTSPACE_ID + '/entries';
        HTTPParams.RequestURLParams.Add('access_token', PRACTICE_CONTENTSPACE_ACCESSTOKEN);
        HTTPParams.ResponseDataType := rdtJSON;
        if BaseClient.DoHttpGet(HTTPParams, Response, APIError, False) then
          ShowMessage(Response)
        else
          ShowMessage(APIError);
      end;
      1: // get contentful
      begin
        HTTPParams.RequestURL := rgOptions.Items[rgOptions.ItemIndex] + '/' + PRACTICE_CONTENTSPACE_ID + '/entries';
        HTTPParams.RequestURLParams.Add('access_token', PRACTICE_CONTENTSPACE_ACCESSTOKEN);

        BaseClient.OnAPIFinished := ThreadFinish;
        BaseClient.OnAPIError := ThreadError;
        HTTPParams.ResponseDataType := rdtJSON;
        BaseClient.DoHttpGet(HTTPParams ,Response, APIError, True);
      end;
      2: // post a ledger transaction
      begin
        PostData := TStringList.Create;
        try
          PostData.Delimiter := '&';
          PostData.StrictDelimiter := true;
          PostData.Values['client_id']     := PRACINI_CashbookAPILoginID;
          PostData.Values['client_secret'] := PRACINI_CashbookAPILoginSecret;
          PostData.Values['username']      := 'kanga1blp@gmail.com';
          PostData.Values['password']      := 'password1';
          PostData.Values['grant_type']    := MY_DOT_GRANT_PASSWORD;
          PostData.Values['scope']         := PRACINI_CashbookAPILoginScope;

          HTTPParams.RequestURL := PRACINI_CashbookAPILoginURL;
          HTTPParams.RequestHeader := 'Content-Type: ' + HTTPParams.RequestContentType + CRLF ;
          HTTPParams.PostData := PostData.DelimitedText;
          if BaseClient.DoHttpPost(HTTPParams, Response, APIError, False) then
          begin
            Token.Deserialize(Response);
            ShowMessage(Response);
          end
          else
            ShowMessage(APIError);
        finally
          FreeAndNil(PostData);
        end;

      end;
      3:
      begin
        if Trim(Token.AccessToken) = '' then
        begin
          ShowMessage('Please get an access token first by log in to my.myob');
          Exit;
        end;

        HTTPParams.RequestURL := PRACINI_CashbookAPIFirmsURL;
        HTTPParams.RequestContentType := 'application/json; charset=utf-8';
        HTTPParams.RequestAccept := 'application/vnd.cashbook-v1+json';
        // can set retries and rerycount if want
        HTTPParams.RequestHeader := 'Content-Type: ' + HTTPParams.RequestContentType + CRLF +
        'Accept: ' + HTTPParams.RequestAccept + CRLF +
        'Authorization: ' + CASHBOOK_AUTH_PREFIX + Token.AccessToken + CRLF  +
        'x-myobapi-accesstoken: ' + Token.AccessToken;
        HTTPParams.ResponseDataType := rdtJSON;
        if BaseClient.DoHttpGet(HTTPParams, Response, APIError, False) then
          ShowMessage(Response)
        else
          ShowMessage(APIError);
      end;
      4: // export a ledger transaction
      begin
        if Trim(Token.AccessToken) = '' then
        begin
          ShowMessage('Please get an access token first by log in to my.myob');
          Exit;
        end;
        CreateBK5TestClient;

        if Assigned(BK5TestClient) then
        begin
          Selected := TStringList.Create;
          Selected.AddObject(TBank_Account(bk5testClient.clBank_Account_List.Items[0]).baFields.baBank_Account_Number , bk5testClient.clBank_Account_List.Items[0]);
          Selected.AddObject(TBank_Account(bk5testClient.clBank_Account_List.Items[1]).baFields.baBank_Account_Number , bk5testClient.clBank_Account_List.Items[1]);
          PracticeLedger.PrepareTransAndJournalsToExport(Selected, ttbank, Apr01_2004, Apr05_2004);
          BankAcToExport := PracticeLedger.GetBankAccount(1);
          RequestJson := TlkJSONobject.Create;

          BankAcToExport.Write(RequestJson, 0, 200);

          HTTPParams.RequestURL := Format(PRACINI_CashbookAPITransactionsURL, ['ef6fb386-aca9-4a52-8425-c92517437b7f']);
          HTTPParams.RequestContentType := 'application/json; charset=utf-8';
          HTTPParams.RequestAccept := 'application/vnd.cashbook-v1+json';
          HTTPParams.RequestHeader := 'Content-Type: ' + HTTPParams.RequestContentType + CRLF +
          'Accept: ' + HTTPParams.RequestAccept + CRLF +
          'Authorization: ' + CASHBOOK_AUTH_PREFIX + Token.AccessToken + CRLF  +
          'x-myobapi-accesstoken: ' + Token.AccessToken;

          HTTPParams.PostData := TlkJSON.GenerateText(RequestJson);

          BaseClient.OnAPIFinished := ThreadFinish;
          BaseClient.OnAPIError := ThreadError;

          if BaseClient.DoHttpPost(HTTPParams , Response, APIError, True) then
            ShowMessage(Response)
          else
            ShowMessage(APIError);
        end;
      end;
      5 : // lean enagage url check
      begin
        HttpParams.RequestURL := 'https://www.leanengage.com';
        HTTPParams.ResponseDataType := rdtHTML;
        if BaseClient.DoHttpGet(HttpParams,Response,APIError, False) then
          ShowMessage(Response)
        else
          ShowMessage(APIError);
      end;
      6 : // lean enagage url check
      begin
        HttpParams.RequestURL := 'https://www.leanengage.com';
        BaseClient.OnAPIFinished := ThreadFinish;
        BaseClient.OnAPIError := ThreadError;
        HTTPParams.ResponseDataType := rdtHTML;
        BaseClient.DoHttpGet(HttpParams,Response,APIError, True);
      end;
      7 : // lean engage identity
      begin
        HttpParams.RequestURL := 'https://www.leanengage.com/api/v1/identify';

        Auth := 'axcUDK7vH2HhUZfLvMXgcA';   // Test Key
        HttpParams.Authorization := 'Basic ' + Base64Encode(Auth + ':');
        HttpParams.RequestUser := Auth;

        HttpParams.RequestContentType := 'application/json';
        HttpParams.RequestAccept := 'text/plain';

        HttpParams.PostData := '{"user_id":"U1VQRVJWSVNTSU5V","traits":{"name":"U1VQRVJWSVNTSU5V","country":"NZ",' +
                                  '"module_id":"MYOB BankLink Practice","module_version":"5.29.1 Build 0"},' +
                                  '"companies":[{"company_id":"SINUNZ","traits":{"name":"SINU"}}]}';

        HTTPParams.ResponseDataType := rdtJSON;
        if BaseClient.DoHttpPost(HttpParams,Response,APIError, False) then
          ShowMessage(Response)
        else
          ShowMessage(APIError);
      end;
      8 : // lean engage identity thread
      begin
        HttpParams.RequestURL := 'https://www.leanengage.com/api/v1/identify';

        Auth := 'axcUDK7vH2HhUZfLvMXgcA';    // Test Key
        HttpParams.Authorization := 'Basic ' + Base64Encode(Auth + ':');
        HttpParams.RequestUser := Auth;
        HttpParams.RequestContentType := 'application/json';
        HttpParams.RequestAccept := 'text/plain';

        (*HttpParams.PostData := '{"user_id":"U1VQRVJWSVNTSU5V","traits":{"name":"U1VQRVJWSVNTSU5V","country":"NZ",' +
                                  '"module_id":"MYOB BankLink Practice","module_version":"5.29.1 Build 0"},' +
                                  '"companies":[{"company_id":"SINUNZ","traits":{"name":"SINU"}}]}';
        *)

        HttpParams.PostData := '{"user_id":"SINUSABU","traits":{"name":"SINUSABU","country":"NZ",' +
                                  '"module_id":"MYOB BankLink Practice","module_version":"5.29.1 Build 0"},' +
                                  '"companies":[{"company_id":"SINUNZ","traits":{"name":"SINU"}}]}';

        BaseClient.OnAPIFinished := ThreadFinish;
        BaseClient.OnAPIError := ThreadError;

        HTTPParams.ResponseDataType := rdtJSON;

        BaseClient.DoHttpPost(HttpParams,Response,APIError, True);
      end;
      9 : // lean engage identity thread
      begin
        HttpParams.RequestURL := 'https://www.leanengage.com/api/v1/feedback/check';
        Auth := 'axcUDK7vH2HhUZfLvMXgcA';    // Test Key

        { If you have URL params (URL query strings, use the HTTPParams.RequestURLParams and
        use HTTPParams.RequestURLParams.Add to add each query string)}

        HttpParams.Authorization := 'Basic ' + Base64Encode(Auth + ':');
        HttpParams.RequestUser := Auth;

        HttpParams.RequestContentType := 'application/json';
        HttpParams.RequestAccept := 'text/plain';

        HttpParams.PostData := '{"user_id":"SINUSABU"}';
        HTTPParams.ResponseDataType := rdtJSON;

        BaseClient.OnAPIFinished := LeanSurveyFinish;
        BaseClient.OnAPIError := LeanSurveyError;

        BaseClient.DoHttpPost(HttpParams,Response,APIError, True);
      end;
      10 : // lean engage identity with timer enabled
      begin
        HttpParams.RequestURL := 'https://www.leanengage.com/api/v1/identify';

        Auth := 'axcUDK7vH2HhUZfLvMXgcA';   // Test Key
        HttpParams.Authorization := 'Basic ' + Base64Encode(Auth + ':');
        HttpParams.RequestUser := Auth;
        HttpParams.APIResponseWaitInterval := 3;
        HttpParams.RequestContentType := 'application/json';
        HttpParams.RequestAccept := 'text/plain';

        HttpParams.PostData := '{"user_id":"U1VQRVJWSVNTSU5V","traits":{"name":"U1VQRVJWSVNTSU5V","country":"NZ",' +
                                  '"module_id":"MYOB BankLink Practice","module_version":"5.29.1 Build 0"},' +
                                  '"companies":[{"company_id":"SINUNZ","traits":{"name":"SINU"}}]}';

        HTTPParams.ResponseDataType := rdtJSON;
        if BaseClient.DoHttpPost(HttpParams,Response,APIError, False) then
          ShowMessage(Response)
        else
          ShowMessage(APIError);
      end;

    end;
  finally
    FreeAndNil(BaseClient);
    FreeAndNil(HTTPParams);
  end;
end;

procedure TFrmTestRESTClient.CreateBK5TestClient;
var
  ba : TBank_Account;
  pt : pTransaction_Rec;
  pD : pDissection_Rec;

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

  //gst rates (NZ)
  BK5TestClient.clFields.clGST_Applies_From[1] := 138883; // 01 Jan 1980

  {Capital Acquisitions}
  BK5TestClient.clFields.clGST_Class_Codes[ctiCAP]  := cttCAP;
  BK5TestClient.clFields.clGST_Class_Names[ctiCAP]  := ctnCAP;
//  BK5TestClient.clFields.clGST_Class_Types[ctiCAP]  := gtOutputTax;
  BK5TestClient.clFields.clGST_Rates[ctiCAP,1]      := 100000;
  {Export Sales}
  BK5TestClient.clFields.clGST_Class_Codes[ctiEXP]  := cttEXP;
  BK5TestClient.clFields.clGST_Class_Names[ctiEXP]  := ctnEXP;
//  BK5TestClient.clFields.clGST_Class_Types[ctiEXP]  := gtInputTax;
  BK5TestClient.clFields.clGST_Rates[ctiEXP,1]      := 0;
  {GST Free}
  BK5TestClient.clFields.clGST_Class_Codes[ctiFRE]  := cttFRE;
  BK5TestClient.clFields.clGST_Class_Names[ctiFRE]  := ctnFRE;
//  BK5TestClient.clFields.clGST_Class_Types[ctiFRE]  := gtExempt;
  BK5TestClient.clFields.clGST_Rates[ctiFRE,1]      := 0;
  {Not Registered}
  BK5TestClient.clFields.clGST_Class_Codes[ctiGNR]  := cttGNR;
  BK5TestClient.clFields.clGST_Class_Names[ctiGNR]  := ctnGNR;
//  BK5TestClient.clFields.clGST_Class_Types[ctiGNR]  := gtExempt;
  BK5TestClient.clFields.clGST_Rates[ctiGNR,1]      := 0;
  {Goods & Services Input Tax}
  BK5TestClient.clFields.clGST_Class_Codes[ctiGSTI]  := cttGSTI;
  BK5TestClient.clFields.clGST_Class_Names[ctiGSTI]  := ctnGSTI;
//  BK5TestClient.clFields.clGST_Class_Types[ctiGSTI]  := gtExempt;
  BK5TestClient.clFields.clGST_Rates[ctiGSTI,1]      := 100000;
  {Goods & Services Output Tax}
  BK5TestClient.clFields.clGST_Class_Codes[ctiGSTO]  := cttGSTO;
  BK5TestClient.clFields.clGST_Class_Names[ctiGSTO]  := ctnGSTO;
//  BK5TestClient.clFields.clGST_Class_Types[ctiGSTO]  := gtExempt;
  BK5TestClient.clFields.clGST_Rates[ctiGSTO,1]      := 100000;
  {Goods & Services Uncategorised Tax}
  BK5TestClient.clFields.clGST_Class_Codes[ctiUnCAT]  := cttUnCAT;
  BK5TestClient.clFields.clGST_Class_Names[ctiUnCAT]  := ctnUCAT;
//  BK5TestClient.clFields.clGST_Class_Types[ctiUCAT]  := gtExempt;
  BK5TestClient.clFields.clGST_Rates[ctiUnCAT,1]      := 100000;
  {Input Taxed Purchases}
  BK5TestClient.clFields.clGST_Class_Codes[ctiINP]  := cttINP;
  BK5TestClient.clFields.clGST_Class_Names[ctiINP]  := ctnINP;
//  BK5TestClient.clFields.clGST_Class_Types[ctiINP]  := gtExempt;
  BK5TestClient.clFields.clGST_Rates[ctiINP,1]      := 0;
  {Input Tax Sales}
  BK5TestClient.clFields.clGST_Class_Codes[ctiITS]  := cttITS;
  BK5TestClient.clFields.clGST_Class_Names[ctiITS]  := ctnITS;
//  BK5TestClient.clFields.clGST_Class_Types[ctiITS]  := gtExempt;
  BK5TestClient.clFields.clGST_Rates[ctiITS,1]      := 0;
  {Not Reportable}
  BK5TestClient.clFields.clGST_Class_Codes[ctiNTR]  := cttNTR;
  BK5TestClient.clFields.clGST_Class_Names[ctiNTR]  := ctnNTR;
//  BK5TestClient.clFields.clGST_Class_Types[ctiNTR0]  := gtExempt;
  BK5TestClient.clFields.clGST_Rates[ctiNTR,1]      := 0;


  BK5TestClient.ClExtra.ceLocal_Currency_Code  := 'NZD';
  MyClient := BK5TestClient;
  //chart
  Chart230 := bkChio.New_Account_Rec;
  Chart230^.chAccount_Code := '230';
  Chart230^.chAccount_Description := 'Sales';
  Chart230^.chGST_Class := 1;
  Chart230^.chPosting_Allowed := true;
  BK5TestClient.clChart.Insert( Chart230);

  Chart400 := bkChio.New_Account_Rec;
  Chart400^.chAccount_Code := '400';
  Chart400^.chAccount_Description := 'Expenses 400';
  Chart400^.chGST_Class := 2;
  Chart400^.chPosting_Allowed := true;
  BK5TestClient.clChart.Insert( Chart400);

  //create two bank accounts
  ba := TBank_Account.Create(nil);
//  ba.baClient := bk5testClient;
  ba.baFields.baBank_Account_Number := '12345';
  ba.baFields.baBank_Account_Name   := 'Account 1';
  ba.baFields.baCurrent_Balance := 100;
  ba.baFields.baContra_Account_Code := '297';
  ba.baFields.baCurrency_Code := 'NZD';

  bk5testClient.clBank_Account_List.Insert( ba);

  //create transactions
  pT := ba.baTransaction_List.Setup_New_Transaction;

  pT^.txDate_Presented  := Apr01_2004;
  pT.txDate_Effective   := Apr01_2004;
  pT.txAmount           := 12000;
  pT.txAccount          := '230';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran1';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '11';


  ba.baTransaction_List.Insert_Transaction_Rec( pT);

  //create 2nd bank account
  ba := TBank_Account.Create(nil);
  ba.baFields.baBank_Account_Number := '67890';
  ba.baFields.baBank_Account_Name   := 'Account 2';
  ba.baFields.baCurrent_Balance := 100;
  ba.baFields.baContra_Account_Code := '200';
  ba.baFields.baCurrency_Code := 'NZD';
  bk5testClient.clBank_Account_List.Insert( ba);

  pT := ba.baTransaction_List.Setup_New_Transaction;

  pT^.txDate_Presented  := Apr03_2004;
  pT.txDate_Effective   := Apr03_2004;
  pT.txAmount           := 4000;
  pT.txAccount          := '230';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 2 Tran1';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(4000 / 9);
  pT.txExternal_GUID := '13';
  pT^.txQuantity := 123456;

  ba.baTransaction_List.Insert_Transaction_Rec( pT);
end;

procedure TFrmTestRESTClient.FormCreate(Sender: TObject);
begin
  Token := TAPIAuthTokens.Create;
end;

procedure TFrmTestRESTClient.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Token);
end;

procedure TFrmTestRESTClient.LeanIdentityError(var AAPIError: string);
begin

end;

procedure TFrmTestRESTClient.LeanIdentityFinish(var AAPIResponse: string);
var
  Auth, Response, APIError: string;
  HttpParams : THTTPParams;
  BaseClient : TRESTClient;
begin
  Exit;
  
  HttpParams := THTTPParams.Create;
  BaseClient := TRESTClient.Create(Nil);
  // Call lean engage surveys
  try
    HttpParams.RequestURL := 'https://www.leanengage.com/api/v1/feedback/check';

    Auth := 'axcUDK7vH2HhUZfLvMXgcA';    // Test Key
    HttpParams.Authorization := 'Basic ' + Base64Encode(Auth + ':');
    HttpParams.RequestUser := Auth;
    HttpParams.RequestContentType := 'application/json';
    HttpParams.RequestAccept := 'text/plain';

    HttpParams.PostData := '{"user_id":"U1VQRVJWSVNTSU5V"}';

    HTTPParams.ResponseDataType := rdtJSON;

    BaseClient.OnAPIFinished := LeanSurveyFinish;
    BaseClient.OnAPIError := LeanSurveyError;
    BaseClient.DoHttpPost(HttpParams,Response,APIError, True);

  finally
    FreeAndNil(HttpParams);
    FreeAndNil(BaseClient);
  end;
end;

procedure TFrmTestRESTClient.LeanSurveyError(var AAPIError: string);
begin
  ShowMessage(AAPIError);
end;

procedure TFrmTestRESTClient.LeanSurveyFinish(var AAPIResponse: string);
begin
  ShowMessage(AAPIResponse);
end;

procedure TFrmTestRESTClient.ThreadError(var AAPIError: string);
begin
  ShowMessage(' Inside Thread Error Event '  + #13#10 + AAPIError);
end;

procedure TFrmTestRESTClient.ThreadFinish(var AAPIResponse: string);
begin
  ShowMessage(' Inside Thread Finish Event '  + #13#10 + AAPIResponse);
end;

end.
