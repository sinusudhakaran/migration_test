unit QuickBooks2003;
//------------------------------------------------------------------------------
{
   Title:        Quickbooks 2003 Chart Refresh

   Description:

   Remarks:     Imports chart from Quickbooks 2003

   Revision History:
     v1.00   14/08/2003  Initial version. [MichaelF]

}
//------------------------------------------------------------------------------

!! Not used

interface

uses
  chList32;

procedure RefreshChart;
function XMLExtractAccountRet(XMLResponse: WideString) : TChart;

//******************************************************************************
implementation
//------------------------------------------------------------------------------

uses
   Classes,
   ComObj,
   Globals,
   SysUtils,
   Variants,
   Windows,
   bkchio,
   BK5Except,
   BKConst,
   bkdefs,
   ovcDate,
   InfoMoreFrm,
   ErrorMoreFrm,
   LogUtil,
   ChartUtils,
   GenUtils,
   Templates,
   gstCalc32,
   bkProduct;

Const
  UnitName = 'QuickBooks 2003';
  DebugMe  : Boolean = False;

  qbFileOpenSingleUser = 0;
  qbFileOpenMultiUser = 1;
  qbFileOpenDoNotCare = 2;

  XML_QBXML = 'QBXML';
  XML_QBXMLMsgsRs = 'QBXMLMsgsRs';
  XML_AccountQueryRs = 'AccountQueryRs';
  XML_AccountRet = 'AccountRet';

//------------------------------------------------------------------------------

function LoadQB2003Chart : TChart;
const
  ThisMethodName = 'LoadQB2003Chart';
var
  AChart     : TChart;
  OK         : Boolean;
  qbXMLRP : OleVariant;
  hr : Integer;
  Ticket : String;
  XMLIN, XMLOut : String;
  Msg : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  OK     := False;
  AChart := nil;
  try
    try
      qbXMLRP := CreateOLEObject('QBXMLRP.RequestProcessor');
    except
      //invalid class string
      qbXMLRP := UnAssigned;
    end;
    if not (VarIsEmpty(qbXMLRP)) then
    begin
      try
        //Open connection to qbXMLRP COM
        //HRESULT OpenConnection([IN], BSTR appID, [IN], BSTR appName);
        hr := qbXMLRP.OpenConnection('', APPTITLE);

        if (hr = 0) then
        begin
          //Begin Session
          //HRESULT BeginSession([in] BSTR qbCompanyFileName, [in] QBFileMode qbOpenFileMode, [out, retval] BSTR* ticket);
          Ticket := qbXMLRP.BeginSession(''{'C:\Program Files\Intuit\QuickBooks Pro - Accountant Edition\Stadium Construction and Hardware Pty Ltd QB Pro.qbw'}, qbFileOpenDoNotCare); //QBXMLRP.qbFileOpenDoNotCare); //, qbXMLRP.qbFileOpen); //qbFileOpenDoNotCare); //QBXMLRP.qbFileOpenDoNotCare);

          //hr := qbXMLRP.GetCurrentCompanyFileName([in] BSTR ticket,
          //               [out, retval] BSTR* pFileName);

          if (hr = 0) then
          begin
            //Send request to QuickBooks
            //HRESULT ProcessRequest([in] BSTR ticket, [in] BSTR qbXMLIn, [out, retval] BSTR* qbXMLOut);
            XMLIn := ' <?qbxml version="OZ2.0"?>' + #13#10 + //must have a space at the beginning
              '<QBXML>' + #13#10 +
              '  <QBXMLMsgsRq onError="stopOnError">' + #13#10 +
              '    <AccountQueryRq requestID="1">' + #13#10 +
              //'    <FromModifiedDate>2002-01-01</FromModifiedDate>' + #13#10 +
              //'    <ToModifiedDate>2004-01-01</ToModifiedDate>' + #13#10 +
              '    </AccountQueryRq>' + #13#10 +
              '  </QBXMLMsgsRq>' + #13#10 +
              '</QBXML>' + #13#10;
            XMLOut := qbXMLRP.ProcessRequest(Ticket, XMLIn);
            AChart := XMLExtractAccountRet(XMLOut);
            OK := True;
          end;

          if (hr = 0) then
            //End the session
            //HRESULT EndSession([in] BSTR ticket);
            qbXMLRP.EndSession(Ticket);
          //Close the connection
          qbXMLRP.CloseConnection;
        end;
      except
        on e:Exception do
          Raise ERefreshFailed.Create( E.Message );
      end;
      qbXMLRP := UnAssigned;
    end;
  finally
    if not OK then Begin
      if Assigned( AChart ) then Begin
        AChart.Free;
        AChart := nil;
      end;
    end;
  end;

  if Assigned( AChart ) and ( AChart.ItemCount = 0 ) then
  Begin
    FreeAndNil(AChart);
    Msg := TProduct.BrandName + ' couldn''t find any accounts to import.';
    LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
    Raise ERefreshFailed.Create( Msg );
  end;

  Result := AChart;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------
//
//  XMLExtractAccountRet
//
//  Parses through the XML string to extract the Account information.
//
//  Parameters:
//    XMLResponse : XML string.
//
//------------------------------------------------------------------------------
function XMLExtractAccountRet(XMLResponse: WideString) : TChart;
const
  StdTypeNames : array[ 1..14 ] of string[10] =
     ( 'AP','AR','BANK','CCARD','COGS','EQUITY','EXEXP','EXINC','FIXASSET','INC',
       'LTLIAB','NONPOSTING','OASSET','OCASSET' );

  StdTypeCodes : array[ 1..14 ] of Byte =
     ( { 'AP'         } atCreditors       ,
       { 'AR'	       } atDebtors         ,
       { 'BANK'       } atBankAccount     ,
       { 'CCARD'      } atBankAccount     ,
       { 'COGS'       } atPurchases       ,
       { 'EQUITY'     } atEquity          ,
       { 'EXEXP'      } atExpense         ,
       { 'EXINC'      } atIncome          ,
       { 'FIXASSET'   } atFixedAssets     ,
       { 'INC'        } atIncome          ,
       { 'LTLIAB'     } atLongTermLiability,
       { 'NONPOSTING' } atNone            ,
       { 'OASSET'     } atFixedAssets     ,
       { 'OCASSET'    } atCurrentAsset );
var
  Doc         : OleVariant; //IXMLDOMDocument;
  AChart      : TChart;
  DOMNode1    : OleVariant; //IXMLDOMNode;
  DOMNode2    : OleVariant; //IXMLDOMNode;
  DOMNode3    : OleVariant; //IXMLDOMNode;
  DOMNode4    : OleVariant; //IXMLDOMNode;
  DOMNode5    : OleVariant; //IXMLDOMNode;
  i, j : Integer;
  Index1, Index2 : Integer;
  Index3, Index4 : Integer;
  Index5 : Integer;
  FullName : String;
  AccountType : String;
  AccountNumber : String;
  TaxCodeRef : String;
  nodeName : String;
  NewAccount : pAccount_Rec;
begin
  Result := nil;
  try
    Doc := CreateOleObject('Microsoft.XMLDOM'); // as IXMLDomDocument;
    if (not VarIsEmpty(Doc)) then
    begin
      AChart := TChart.Create(MyClient.ClientAuditMgr);
      Doc.loadXML(XMLResponse);
      for i := 0 to Doc.childNodes.length - 1 do
      begin
        DOMNode1 := Doc.childNodes.item[i];
        if (DOMNode1.nodeName = XML_QBXML) then
        begin
          //QBXML
          for Index1 := 0 to DOMNode1.childNodes.length - 1 do
          begin
            DOMNode2 := DOMNode1.childNodes.item[Index1];
            if (DOMNode2.nodeName = XML_QBXMLMsgsRs) then
            begin
              //QBXMLMsgsRs
              for Index2 := 0 to DOMNode2.childNodes.length-1 do
              begin
                DOMNode3 := DOMNode2.childNodes.item[Index2];
                if (DOMNode3.nodeName = XML_AccountQueryRs) then
                begin
                  //AccountQueryRs
                  for Index3 := 0 to DOMNode3.childNodes.length-1 do
                  begin
                    DOMNode4 := DOMNode3.childNodes.item[Index3];
                    if (DOMNode4.nodeName = XML_AccountRet) then
                    begin
                      //AccountRet
                      FullName := '';
                      AccountType := '';
                      AccountNumber := '';
                      TaxCodeRef := '';
                      for Index4 := 0 to DOMNode4.childNodes.length-1 do
                      begin
                        if (DOMNode4.childNodes.item[Index4].hasChildNodes) then
                        begin
                          nodeName := DOMNode4.childNodes.item[Index4].nodeName;
                          if (nodeName = 'FullName') then
                            FullName := DOMNode4.childNodes.item[Index4].Text
                          else if (nodeName = 'AccountType') then
                            AccountType := DOMNode4.childNodes.item[Index4].Text
                          else if (nodeName = 'AccountNumber') then
                            AccountNumber := DOMNode4.childNodes.item[Index4].Text
                          else if (nodeName = 'TaxCodeRef') then
                          begin
                            DOMNode5 := DOMNode4.childNodes.item[Index4];
                            for Index5 := 0 to DOMNode5.childNodes.length-1 do
                            begin
                              if (DOMNode5.childNodes.item[Index5].hasChildNodes) then
                              begin
                                nodeName := DOMNode5.childNodes.item[Index5].nodeName;
                                if (nodeName = 'FullName') then
                                  TaxCodeRef := DOMNode5.childNodes.item[Index5].Text
                              end;
                            end;
                          end;
                        end;
                      end;
                      if (AccountNumber <> '') then
                      begin
                        if ( AChart.FindCode( AccountNumber )<> nil ) then
                        begin
                          LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code ' + AccountNumber);
                        end else
                        begin
                           NewAccount := New_Account_Rec;
                           with NewAccount^ do
                           begin
                             chAccount_Code        := AccountNumber;
                             chAccount_Description := FullName;
                             chGST_Class           := GSTCalc32.GetGSTClassNo( MyClient, TaxCodeRef );
                             chPosting_Allowed     := true;

                             for j := 1 to 14 do
                               if (AccountType = StdTypeNames[ j ] ) then chAccount_Type := stdTypeCodes[ j ];
                           end;
                           AChart.Insert(NewAccount);
                        end;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
      Doc := unAssigned;
    end;
  except
    on E: Exception do
       Raise ERefreshFailed.Create( E.Message );
  end;
  Result := AChart;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;
const
   ThisMethodName    = 'RefreshChart';
var
   NewChart          : TChart;
   Msg               : string;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not Assigned( MyClient ) then exit;
   
   with MyClient.clFields do
   begin
      try
   		NewChart := LoadQB2003Chart;
        if (Assigned(NewChart)) then
        begin
          MergeCharts( NewChart, MyClient.clChart ); { Frees NewChart }
          //clLoad_Client_Files_From := QBWFileName;
          clChart_Last_Updated     := CurrentDate;
        end;

        HelpfulInfoMsg( 'The client''s chart of accounts has been refreshed.', 0 );

      except
         on E : ERefreshFailed do begin
            Msg := Format( 'Error Refreshing Chart: %s', [ E.Message ] );
            LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
            HelpfulErrorMsg( Msg + #13+#13+'The existing chart has not been modified.', 0 );
            exit;
         end;
      end; {except}
   end; {with}
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

