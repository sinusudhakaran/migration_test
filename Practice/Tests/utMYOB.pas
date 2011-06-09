unit utMYOB;
//------------------------------------------------------------------------------
{
   Title:       Unit Tests for MYOB AO interface
   Description:

   Author:      Matthew Hopkins           July 2005
   Remarks:     Test the chart refresh and extract routine generate/process
                expected xml correctly


}
//------------------------------------------------------------------------------
{$TYPEINFO ON} //Needed for classes with published methods
interface
uses
  TestFramework, bkDefs, clObj32, chList32, classes;

type
  TBcLinkTests = class(TTestCase)
  private
     bk5TestClient : TClientObj;
     Chart230,
     Chart400 : pAccount_Rec;
  protected
     procedure CreateBK5TestClient;
     procedure Setup; override;
     procedure TearDown; override;
     procedure CheckException(AMethod: TTestMethod; AExceptionClass: ExceptionClass);

     procedure CheckChartCode( aCode : string; aDesc : string; aGSTClass : integer; aPosting : boolean; aChart : TChart);
  published
     procedure TestExtract;
     procedure HandlingOfStatusNode;
     procedure ChartRefreshAU;
     procedure ChartRefreshNZ;
  end;

implementation
uses
  Globals, baObj32, trxList32, bktxio, baList32, bkdsio, bkConst, bkchio,
  myobaox_bclink, omnixml, omniXmlUtils, myobao_utils, sysUtils,
  myobao;

const
  Apr01_2004 = 147649;
  Apr02_2004 = Apr01_2004 + 1;
  Apr03_2004 = Apr01_2004 + 2;
  Apr04_2004 = Apr01_2004 + 3;
  Apr05_2004 = Apr01_2004 + 4;

{ TBcLinkTests }

procedure TBcLinkTests.CreateBK5TestClient;
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
  ba.baFields.baContra_Account_Code := '680';
  ba.baFields.baCurrency_Code := 'NZD';

  bk5testClient.clBank_Account_List.Insert( ba);

  //create transactions
  pT := ba.baTransaction_List.New_Transaction;

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

  //create dissected
  pT := ba.baTransaction_List.New_Transaction;

  pT^.txDate_Presented  := Apr02_2004;
  pT.txDate_Effective   := Apr02_2004;
  pT.txAmount           := 15000;
  pT.txAccount          := 'DISSECTED';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran2';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txExternal_GUID := '12';

    pD := bkdsio.New_Dissection_Rec;
    pD^.dsAccount         := '400';
    pD.dsAmount           := 6000;
    pD.dsGST_Class        := 2;
    pD.dsGST_Amount       := Round(6000/9);
    pD.dsNotes            := 'L1 NOTE';
    pD.dsGL_Narration     := 'Line 1';
    AppendDissection( pT, pD);

    pD := bkdsio.New_Dissection_Rec;
    pD^.dsAccount         := '402';
    pD.dsAmount           := 9000;
    pD.dsGST_Class        := 3;
    pD.dsGST_Amount       := 0;
    pD.dsGST_Has_Been_Edited := True;
    pD.dsNotes            := 'L2 NOTE';
    pD.dsGL_Narration     := 'Line 2';
    AppendDissection( pT, pD);

  ba.baTransaction_List.Insert_Transaction_Rec( pT);

  //create 2nd bank account
  ba := TBank_Account.Create(nil);
//  ba.baClient := bk5testClient;
  ba.baFields.baBank_Account_Number := '67890';
  ba.baFields.baBank_Account_Name   := 'Account 2';
  ba.baFields.baCurrent_Balance := 100;
  ba.baFields.baContra_Account_Code := '681';
  ba.baFields.baCurrency_Code := 'NZD';
  bk5testClient.clBank_Account_List.Insert( ba);

  pT := ba.baTransaction_List.New_Transaction;

  pT^.txDate_Presented  := Apr03_2004;
  pT.txDate_Effective   := Apr03_2004;
  pT.txAmount           := -4000;
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

  //create dissected
  pT := ba.baTransaction_List.New_Transaction;

  pT^.txDate_Presented  := Apr04_2004;
  pT.txDate_Effective   := Apr04_2004;
  pT.txAmount           := 20000;
  pT.txAccount          := 'DISSECTED';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := '[A]c<c/>"&ount 2 Tran2';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txExternal_GUID := '14';

    pD := bkdsio.New_Dissection_Rec;
    pD^.dsAccount         := '400';
    pD.dsAmount           := 6000;
    pD.dsGST_Class        := 2;
    pD.dsGST_Amount       := Round(6000/9);
    pD.dsNotes            := 'L1 NOTE';
    pD.dsGL_Narration     := 'Line 1';
    AppendDissection( pT, pD);

    pD := bkdsio.New_Dissection_Rec;
    pD^.dsAccount         := '402';
    pD.dsAmount           := 14000;
    pD.dsGST_Class        := 3;
    pD.dsGST_Amount       := 0;
    pD.dsGST_Has_Been_Edited := True;
    pD.dsNotes            := 'L2 NOTE';
    pD.dsGL_Narration     := 'Line 2';
    AppendDissection( pT, pD);

  ba.baTransaction_List.Insert_Transaction_Rec( pT);
end;

procedure TBcLinkTests.TestExtract;
var
  accounts : Tstringlist;
  xmlstring : string;
  xmlDoc : IXMLDocument;
  s1,
  s2,
  s3,
  s4,
  node : IXMLNode;
  stmtnodelist,
  acctnodeList : IXMLNodeList;
  cdList : IXMLNodeList;
  cdNode : IXMLNode;
  transamount : integer;
  i : integer;
begin
  //create list of accounts for extract
  accounts := tstringlist.Create;
  try
    accounts.AddObject( bk5testclient.clBank_Account_List.Bank_Account_at(0).baFields.baBank_Account_Number,
                        bk5testclient.clBank_Account_List.Bank_Account_at(0));
    accounts.AddObject( bk5testclient.clBank_Account_List.Bank_Account_at(1).baFields.baBank_Account_Number,
                        bk5testclient.clBank_Account_List.Bank_Account_at(1));

    xmlstring := myobaox_bclink.PrepareXML( Apr01_2004, Apr05_2004, Accounts);

    //now check xml string is as expected
    xmlDoc := CreateXMLDoc;
    try
      XMLLoadFromString( xmlDoc, xmlString);
      //check for parser errors
      CheckEquals( 0, xmlDoc.ParseError.ErrorCode, xmlDoc.ParseError.Reason);

      //check for 2 accounts and 4 entries
      node := FindNode( xmlDoc.FirstChild, 'EXTRACT');
      acctnodeList := FilterNodes( node, 'ACCT');
      CheckEquals( 2, AcctNodeList.Length, 'Count of Acct nodes');

      //check stmtrn lines
      stmtNodeList := FilterNodes( AcctNodeList.Item[0], 'STMTTRN');
      s1 := stmtNodeList.NextNode;
      s2 := stmtNodeList.NextNode;
      CheckEquals( 2, stmtNodeList.Length, 'Count of STMTTRN nodes Acct 1');
      stmtNodeList := nil;

      stmtNodeList := FilterNodes( AcctNodeList.Item[1], 'STMTTRN');
      s3 := stmtNodeList.NextNode;
      s4 := stmtNodeList.NextNode;
      CheckEquals( 2, stmtNodeList.Length, 'Count of STMTTRN nodes Acct 2');
      stmtNodeList := nil;

      //check stmt  1
      CheckEquals( 'DEBIT', GetNodeTextStr( s1, 'TRNTYPE'), 's1 TRNTYPE');
      CheckEquals( '20040401', GetNodeTextStr( s1, 'DTPOSTED'), 's1 DTPOSTED');
      transamount := Round(GetNodeTextReal( s1, 'TRNAMT') * 100);
      CheckEquals( 12000 , transamount, 's1 TRNAMT');
      CheckEquals( '11', GetNodeTextStr( s1, 'FITID'), 's1 FITID');

      //check only 1 coding detail line
      CheckEquals( 1, FilterNodes( s1, 'CODINGDETAIL').Length, 'Count of CODINGDETAIL node(s)');

      cdNode := FindNode( s1, 'CODINGDETAIL');
      CheckEquals( '230', GetNodeTextStr( cdNode, 'GLCODE'), 's1 GLCODE');
      CheckEquals( transAmount, Round(GetNodeTextReal( cdNode, 'AMT') * 100) +
                                Round(GetNodeTextReal( cdNode, 'GSTAMT') * 100),
                                'S1 AMT + GSTAMT = TRNAMT');
      CheckEquals( 'I', GetNodeTextStr( cdNode, 'GSTTYPE'), 'S1 GSTTYPE');

      //check stmt 2
      cdList := FilterNodes( s2, 'CODINGDETAIL');
      CheckEquals( 2, cdList.Length, 'S2 Count of CODINGDETAIL node(s) ');
      transamount := Round(GetNodeTextReal( s2, 'TRNAMT') * 100);

      cdNode := cdList.NextNode;
      CheckEquals( 'Line 1', GetNodeTextStr( cdNode, 'DESCRIPTION'), 'S2 L1 Desc');
      i := Round(GetNodeTextReal( cdNode, 'AMT') * 100) + Round(GetNodeTextReal( cdNode, 'GSTAMT') * 100);

      cdNode := cdList.NextNode;
      CheckEquals( 'Line 2', GetNodeTextStr( cdNode, 'DESCRIPTION'), 'S2 L2 Desc');
      i := i + Round(GetNodeTextReal( cdNode, 'AMT') * 100) + Round(GetNodeTextReal( cdNode, 'GSTAMT') * 100);

      //total transaction amount must match individual lines total of amt + gst
      CheckEquals( transAmount, i, 'TransAmount matched dissection lines');

      //check stmt 3
      CheckEquals( 'CREDIT', GetNodeTextStr( s3, 'TRNTYPE'), 'S3 TRNTYPE');
      cdNode := FindNode( s3, 'CODINGDETAIL');
      CheckEquals( '12.3456', GetNodeTextStr( cdNode, 'QUANTITY'), 'S3 Quantity');
    finally
      xmlDoc := nil;
      node := nil;
    end;

  finally
    accounts.Free;
  end;
end;

procedure TBcLinkTests.Setup;
//create a client for use within each test
begin
  inherited;

  CreateBK5TestClient;

  //set my client pointer
  Globals.MyClient := bk5TestClient;
end;

procedure TBcLinkTests.TearDown;
begin
  //destroy the test client
  BK5TestClient.Free;

  inherited;
end;

procedure TBcLinkTests.CheckException(AMethod: TTestMethod;
  AExceptionClass: ExceptionClass);
begin
  try
    AMethod;
    fail('Expected exception not raised');
  except
    on E: Exception do
    begin
      if E.ClassType <> AExceptionClass then
        raise;
    end
  end;
end;

procedure TBcLinkTests.ChartRefreshAU;
var
  Bk5Chart : chlist32.TChart;
  RawXML : string;
  Duplicates : boolean;
begin
  RawXML :=
        '<xml>'+
          '<status>'+
            '<code>0</code>'+
            '<message>OK</message>'+
          '</status>'+
          '<Accounts>'+

//gst type "0" class 1
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[190\]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Professional Fees]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[R]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[O]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.F.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+

//gst type "Z2" class 2
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[882\]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Export Sales]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[R]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[Z]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.T.</acc_export>'+
              '<acc_inbas>.F.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+
//gst type "Z3" class 3
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[883\]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[GST Free Supplies]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[R]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[Z]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.F.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+
//gst type "E4" class 4
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[199/01]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[- Savings Account]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[R]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.T.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.F.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+
//gst type "I" class 5
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[314/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Cleaning]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[E]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[I]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.F.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+

//gst type "IC" class 6
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[742/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Plant & Equipment]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[A]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[I]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.T.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+

//gst type "E13" class 7
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[887\]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[E13]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[E]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.F.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.T.</acc_taxed>'+
              '</Account>'+

//gst type "E13C" class 8
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[888\]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[E13C]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[A]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.T.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.T.</acc_taxed>'+
              '</Account>'+

//gst type "E14" class 9
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[383/01]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[- National Australia Bank]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[E]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.F.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+

//gst type "E14C" class 10
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[810]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[E14C]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[A]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.T.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+
//gst type "Z14" class 11
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[309/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Bank Charges]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[E]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[Z]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.F.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+

//gst type "Z14C" class 12
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[812/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Z14C]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[A]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[Z]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.T.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+

//gst type "E15" class 13
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[813/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[E15]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[E]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.F.</acc_inbas>'+
              '<acc_nonded>.T.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+
//gst type "E" class 14
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[330/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Depreciation]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[E]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.T.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.F.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+

//gst type "Z" class 15
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[815/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Z]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[X]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[Z]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.F.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+



//unfortunately the non posting flag is updated when the chart is merged so cant
//test here, can still test handling of account names

//non posting
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[96Z/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[*** INFORMATION ACCOUNTS [970 - 999]]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[A]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.F.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+

              '<Account>'+
              '<exp_1>'+
              '<![CDATA[969/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[<>?/>]SUSPENSE ACCOUNT]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[A]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '<acc_exbas>.F.</acc_exbas>'+
              '<acc_export>.F.</acc_export>'+
              '<acc_inbas>.F.</acc_inbas>'+
              '<acc_nonded>.F.</acc_nonded>'+
              '<acc_taxed>.F.</acc_taxed>'+
              '</Account>'+

            '</Accounts>'+
        '</xml>';

  // for au
  bk5Chart := chList32.TChart.Create(nil);
  try
    MYOBAO.ProcessXMLChart_AU( RawXML, bk5Chart, Duplicates);

    CheckEquals( 17, bk5Chart.ItemCount, 'Count of account codes');

    //check expected chart codes
    CheckChartCode( '190', 'Professional Fees', 1, true, bk5Chart);
    CheckChartCode( '882', 'Export Sales', 2, true, bk5Chart);
    CheckChartCode( '883', 'GST Free Supplies', 3, true, bk5Chart);
    CheckChartCode( '199/01', '- Savings Account', 4, true, bk5Chart);
    CheckChartCode( '314', 'Cleaning', 5, true, bk5Chart);
    CheckChartCode( '742', 'Plant & Equipment', 6, true, bk5Chart);
    CheckChartCode( '887', 'E13', 7, true, bk5Chart);
    CheckChartCode( '888', 'E13C', 8, true, bk5Chart);
    CheckChartCode( '383/01', '- National Australia Bank', 9, true, bk5Chart);
    CheckChartCode( '810', 'E14C', 10, true, bk5Chart);
    CheckChartCode( '309', 'Bank Charges', 11, true, bk5Chart);
    CheckChartCode( '812', 'Z14C', 12, true, bk5Chart);
    CheckChartCode( '813', 'E15', 13, true, bk5Chart);
    CheckChartCode( '330', 'Depreciation', 14, true, bk5Chart);
    CheckChartCode( '815', 'Z', 15, true, bk5Chart);

    //non posting
    CheckChartCode( '96', '*** INFORMATION ACCOUNTS [970 - 999]', 14, true, bk5Chart);

  finally
    bk5Chart.Free;
  end;
end;

procedure TBcLinkTests.ChartRefreshNZ;
var
  Bk5Chart : chlist32.TChart;
  RawXML : string;
  Duplicates : boolean;
begin
  RawXML :=
        '<xml>'+
          '<status>'+
            '<code>0</code>'+
            '<message>OK</message>'+
          '</status>'+
          '<Accounts>'+

//gst type "0" class 1
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[190\]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Professional Fees]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[R]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[O]]>'+
              '</acc_gstind>'+
              '</Account>'+

//gst type "Z2" class 2
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[882\]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Export Sales]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[R]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[Z]]>'+
              '</acc_gstind>'+
              '</Account>'+
//gst type "Z3" class 3
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[883\]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[GST Free Supplies]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[R]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[Z]]>'+
              '</acc_gstind>'+
              '</Account>'+
//gst type "E4" class 4
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[199/01]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[- Savings Account]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[R]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '</Account>'+
//gst type "I" class 5
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[314/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Cleaning]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[E]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[I]]>'+
              '</acc_gstind>'+
              '</Account>'+

//gst type "IC" class 6
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[742/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Plant & Equipment]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[A]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[I]]>'+
              '</acc_gstind>'+
              '</Account>'+

//gst type "E13" class 7
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[887\]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[E13]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[E]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '</Account>'+

//gst type "E13C" class 8
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[888\]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[E13C]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[A]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '</Account>'+

//gst type "E14" class 9
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[383/01]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[- National Australia Bank]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[E]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '</Account>'+

//gst type "E14C" class 10
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[810]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[E14C]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[A]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '</Account>'+
//gst type "Z14" class 11
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[309/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Bank Charges]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[E]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[Z]]>'+
              '</acc_gstind>'+
              '</Account>'+

//gst type "Z14C" class 12
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[812/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Z14C]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[A]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[Z]]>'+
              '</acc_gstind>'+
              '</Account>'+

//gst type "E15" class 13
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[813/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[E15]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[E]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '</Account>'+
//gst type "E" class 14
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[330/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Depreciation]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[E]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '</Account>'+

//gst type "Z" class 15
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[815/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[Z]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[X]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[Z]]>'+
              '</acc_gstind>'+
              '</Account>'+



//unfortunately the non posting flag is updated when the chart is merged so cant
//test here, can still test handling of account names

//non posting
              '<Account>'+
              '<exp_1>'+
              '<![CDATA[96Z/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[*** INFORMATION ACCOUNTS [970 - 999]]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[A]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '</Account>'+

              '<Account>'+
              '<exp_1>'+
              '<![CDATA[969/]]>'+
              '</exp_1>'+
              '<acc_desc>'+
              '<![CDATA[<>?/>]SUSPENSE ACCOUNT]]>'+
              '</acc_desc>'+
              '<acc_type>'+
              '<![CDATA[A]]>'+
              '</acc_type>'+
              '<acc_gstind>'+
              '<![CDATA[E]]>'+
              '</acc_gstind>'+
              '</Account>'+

            '</Accounts>'+
        '</xml>';

  // again for NZ
  bk5Chart := chList32.TChart.Create(nil);
  try
    MYOBAO.ProcessXMLChart_NZ( RawXML, bk5Chart, Duplicates);

    CheckEquals( 17, bk5Chart.ItemCount, 'Count of account codes');

    // NZ gst:
    {'I' : result := 1;    //input  = expenses
    'O' : result := 2;    //output = sales
    'E' : result := 3;
    'Z' : result := 4;
    'N' : result := 5;}

    //check expected chart codes
    CheckChartCode( '190', 'Professional Fees', 2, true, bk5Chart);
    CheckChartCode( '882', 'Export Sales', 4, true, bk5Chart);
    CheckChartCode( '883', 'GST Free Supplies', 4, true, bk5Chart);
    CheckChartCode( '199/01', '- Savings Account', 3, true, bk5Chart);
    CheckChartCode( '314', 'Cleaning', 1, true, bk5Chart);
    CheckChartCode( '742', 'Plant & Equipment', 1, true, bk5Chart);
    CheckChartCode( '887', 'E13', 3, true, bk5Chart);
    CheckChartCode( '888', 'E13C', 3, true, bk5Chart);
    CheckChartCode( '383/01', '- National Australia Bank', 3, true, bk5Chart);
    CheckChartCode( '810', 'E14C', 3, true, bk5Chart);
    CheckChartCode( '309', 'Bank Charges', 4, true, bk5Chart);
    CheckChartCode( '812', 'Z14C', 4, true, bk5Chart);
    CheckChartCode( '813', 'E15', 3, true, bk5Chart);
    CheckChartCode( '330', 'Depreciation', 3, true, bk5Chart);
    CheckChartCode( '815', 'Z', 4, true, bk5Chart);

    //non posting
    CheckChartCode( '96', '*** INFORMATION ACCOUNTS [970 - 999]', 3, true, bk5Chart);

  finally
    bk5Chart.Free;
  end;
end;

procedure TBcLinkTests.HandlingOfStatusNode;
var
  r : integer;
  rawxml : string;
  status : string;
begin
  RawXML := '<xml><status><code>42</code><message>The Answer</message></status><a><b>Value</b></a></xml>';
  r := myobao_utils.ReadStatus( RawXML, status);

  CheckEquals( 42, r);
  CheckEquals( '[42] The Answer', status);
end;

procedure TBcLinkTests.CheckChartCode(aCode, aDesc: string; aGSTClass: integer;
  aPosting: boolean; aChart : TChart);
var
  pAcc : pAccount_Rec;
begin
  pAcc := aChart.FindCode( aCode);
  Check( pAcc <> nil, 'Chart code ' + aCode + ' missing');
  CheckEquals( aDesc, pAcc^.chAccount_Description, 'check desc for ' + aCode);
  CheckEquals( aGSTClass,pAcc^.chGST_Class, 'check GST class for ' + aCode);
  CheckEquals( aPosting, pAcc^.chPosting_Allowed, 'check Posting flag for ' + aCode);
end;

initialization
  TestFramework.RegisterTest(TBcLinkTests.Suite);

end.
