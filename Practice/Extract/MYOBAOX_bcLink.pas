unit MYOBAOX_bcLink;
//------------------------------------------------------------------------------
{
   Title:        MYOB Accountants Office extract (COM obj interface)

   Description:  Extracts the data as an XML string and passes it to bcLink.dll

   Author:       Matthew Hopkins Jun 2005

   Remarks:

   Revisions:

}
//------------------------------------------------------------------------------

interface
uses
  classes;


procedure ExtractData( const FromDate, ToDate : integer; const SaveTo : string);

{$IFDEF BK_UNITTESTINGON}
function PrepareXML( const FromDate, ToDate : integer; SelectedAccounts : TStringList) : string;
//routine to generate the xml string, split out so can use in unit tests
{$ENDIF}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
uses
  baObj32,
  bk5except,
  bkConst,
  bkDateUtils,
  bkDefs,
  caUtils,
  dlgSelect,
  ErrorMoreFrm,
  TransactionUtils,
  glConst,
  Globals,
  GenUtils,
  InfoMoreFrm,
  LogUtil,
  MYOBAO_Utils,
  OmniXML,
  OmniXMLUtils,
  XMLUtils,
  Software,
  stDate,
  stDatest,
  StStrs,
  SysUtils,
  Traverse,
  TravUtils,
  YesNoDlg,
  baUtils;

const
  UnitName = 'MYOBAOX_bcLink';
  AmountFormat = '0.00';

var
  XMLDoc : IXMLDocument;
  AccountNode : OmniXML.IXmlNode;  //node for current account
  TrxNode : OmniXML.IXmlNode;      //node for current transaction
  ExtractNode : OmniXML.IXmlNode;
  NoOfEntries : integer;
  DebugMe  : Boolean = False;

procedure DoAccountHeader;
//use variables defined in traverse.pas
var
  sAccountNo : string;
begin
  //add account header
  AccountNode := AppendNode( ExtractNode, 'ACCT');
  if Traverse.Bank_Account.IsAJournalAccount then
  begin
    case Traverse.Bank_Account.baFields.baAccount_Type of
      btCashJournals : sAccountNo := 'BLCJ:' + MyClient.clFields.clCode;
      btAccrualJournals : sAccountNo := 'BLAJ:' + MyClient.clFields.clCode;
    else
      sAccountNo := 'BLJ:'+ MyClient.clFields.clCode;
    end;
  end
  else
    sAccountNo := Uppercase( StripM(Traverse.Bank_Account));

  //see if we need to strip the alpha characters
  //from bank accounts
  if Traverse.Bank_Account.baFields.baAccount_Type = btBank then
  begin
    if PRACINI_MYOBStripAlpha then
      sAccountNo := StripAlphaFromAccount( sAccountNo);
  end;

  SetNodeText( AccountNode, 'ACCTID', sAccountNo);
  SetNodeText( AccountNode, 'ACCTCODE', Traverse.Bank_Account.baFields.baContra_Account_Code);     //contra?
end;

procedure DoTransaction;
//use variables defined in traverse.pas
var
  pT : pTransaction_Rec;
  CodingNode : IXmlNode;
  IsSingleCodedTransaction : boolean;
  GLNarr : string;
begin
  pT := Traverse.Transaction;
  NoOfEntries := NoOfEntries + 1;

  if Traverse.Bank_Account.IsAJournalAccount then
  begin
    //journal accounts must be exported as individual lines
    exit;
  end;

  //make sure guid exists
  TransactionUtils.CheckExternalGUID( pT);
  GLNarr := Trim(Copy(GetNarration(TransAction,Bank_Account.baFields.baAccount_Type),1, GetMaxNarrationLength));

  TrxNode := AppendNode( AccountNode, 'STMTTRN');
  if pT^.txAmount < 0 then
    SetNodeText( TrxNode, 'TRNTYPE','CREDIT')
  else
    SetNodeText( TrxNode, 'TRNTYPE','DEBIT');

  SetNodeText( TrxNode,  'DTPOSTED', bkDateUtils.Date2Str( pT^.txDate_Effective, 'yyyymmdd'));
  SetNodeText( TrxNode,  'TRNAMT', Money2Str( pT^.txAmount, AmountFormat));
  SetNodeText( TrxNode,  'FITID', TrimGUID( pT.txExternal_GUID));
  SetNodeText( TrxNode,  'TRNCODE', LeftPadChS( IntToStr( pT^.txType), '0',3));
  if Trim(GetReference(TransAction,Bank_Account.baFields.baAccount_Type)) <> '' then
    SetNodeText( TrxNode, 'REFERENCE',Trim(GetReference(TransAction,Bank_Account.baFields.baAccount_Type)))
  else
    //all entries need to have a 0 reference so that they can be viewed
    //in AO otherwise the user will not be able to view/edit the line
    SetNodeText( TrxNode, 'REFERENCE', '0');

  SetNodeText( TrxNode,  'MEMO', GLNarr);


  IsSingleCodedTransaction := ( pT^.txFirst_Dissection = nil) and
                              ( pT^.txAccount <> '');

  if (IsSingleCodedTransaction) then
  begin
    //write a coding node
    CodingNode := AppendNode( TrxNode, 'CODINGDETAIL');
    SetNodeText( CodingNode,  'GLCODE', pT.txAccount);
    SetNodeText( CodingNode,  'AMT', Money2Str( pT^.txAmount - pT^.txGST_Amount, AmountFormat));
    if ( pT^.txGST_Class in [ 1..MAX_GST_CLASS]) then
    begin
      SetNodeText( CodingNode,  'GSTAMT', Money2Str( pT^.txGST_Amount, AmountFormat));
      //only copy the first character of the gst code, MYOB only supports I,O,E,X,Z
      SetNodeText( CodingNode,  'GSTTYPE', Copy( MyClient.clFields.clGST_Class_Codes[ pT^.txGST_Class], 1, 1));
    end;
    SetNodeText( CodingNode, 'DESCRIPTION', GLNarr);
    if Globals.PRACINI_ExtractQuantity then
      SetNodeText( CodingNode,  'QUANTITY', GetQuantityStringForExtract( pT^.txQuantity ));
  end;
end;

procedure DoDissection;
//use variables defined in traverse.pas
var
  CodingNode : IXmlNode;
  DissectedTrxNode : IXmlNode;
  GLNarr : string;
  pD : pDissection_Rec;
  pT : pTransaction_Rec;
begin
  if not Traverse.Bank_Account.IsAJournalAccount then
  begin
    CodingNode := AppendNode( TrxNode, 'CODINGDETAIL');
    pD := Traverse.Dissection;

    SetNodeText( CodingNode,  'GLCODE', pD.dsAccount);
    SetNodeText( CodingNode,  'AMT', Money2Str( pD^.dsAmount - pD^.dsGST_Amount, AmountFormat));

    if ( pD^.dsGST_Class in [ 1..MAX_GST_CLASS]) then
    begin
      SetNodeText( CodingNode,  'GSTAMT', Money2Str( pD^.dsGST_Amount, AmountFormat));
      //only copy the first character of the gst code, MYOB only supports I,O,E,X,Z
      SetNodeText( CodingNode,  'GSTTYPE', Copy( MyClient.clFields.clGST_Class_Codes[ pD^.dsGST_Class], 1, 1));
    end;
    SetNodeText( CodingNode,  'DESCRIPTION', Copy(pD.dsGL_Narration,1, GetMaxNarrationLength) );
    if Globals.PRACINI_ExtractQuantity then
      SetNodeText( CodingNode,  'QUANTITY', GetQuantityStringForExtract( pD^.dsQuantity ));
  end
  else
  begin
    //journals must be exported as individual lines, so each line needs
    //a guid and a stmttrn node
    pT := Traverse.Transaction;
    pD := Traverse.Dissection;

    TransactionUtils.CheckExternalGUID( pD);

    DissectedTrxNode := AppendNode( AccountNode, 'STMTTRN');
    if pD^.dsAmount < 0 then
      SetNodeText( DissectedTrxNode, 'TRNTYPE','CREDIT')
    else
      SetNodeText( DissectedTrxNode, 'TRNTYPE','DEBIT');

    SetNodeText( DissectedTrxNode,  'DTPOSTED', bkDateUtils.Date2Str( pT^.txDate_Effective, 'yyyymmdd'));
    SetNodeText( DissectedTrxNode,  'TRNAMT', Money2Str( pD^.dsAmount, AmountFormat));
    SetNodeText( DissectedTrxNode,  'FITID', TrimGUID( pD.dsExternal_GUID));
    SetNodeText( DissectedTrxNode,  'TRNCODE', LeftPadChS( IntToStr( pT^.txType), '0',3));
    if Trim(getDsctReference(pD,pT,Traverse.Bank_Account.baFields.baAccount_Type)) <> '' then
      SetNodeText( DissectedTrxNode, 'REFERENCE',Trim( getDsctReference(pD,pT,Traverse.Bank_Account.baFields.baAccount_Type)));

    GLNarr := Trim(Copy(pD.dsGL_Narration,1, GetMaxNarrationLength));
    SetNodeText( DissectedTrxNode,  'MEMO', GLNarr);

    CodingNode := AppendNode( DissectedTrxNode, 'CODINGDETAIL');
    SetNodeText( CodingNode,  'GLCODE', pD.dsAccount);
    SetNodeText( CodingNode, 'DESCRIPTION', GLNarr);
    SetNodeText( CodingNode,  'AMT', Money2Str( pD^.dsAmount - pD^.dsGST_Amount, AmountFormat));
    if ( pD^.dsGST_Class in [ 1..MAX_GST_CLASS]) then
    begin
      SetNodeText( CodingNode,  'GSTAMT', Money2Str( pD^.dsGST_Amount, AmountFormat));
      //only copy the first character of the gst code, MYOB only supports I,O,E,X,Z
      SetNodeText( CodingNode,  'GSTTYPE', Copy( MyClient.clFields.clGST_Class_Codes[ pD^.dsGST_Class], 1, 1));
    end;
    if Globals.PRACINI_ExtractQuantity then
      SetNodeText( CodingNode,  'QUANTITY', GetQuantityStringForExtract( pD^.dsQuantity ));
  end;
end;

procedure FlagTransactionAsTransferred;
begin
  Transaction^.txDate_Transferred := CurrentDate;
end;

procedure FlagEntriesAsTransferred( Ba : TBank_Account; FromDate, ToDate : TStDate);
begin
  TRAVERSE.Clear;
  TRAVERSE.SetSortMethod( csDateEffective );
  TRAVERSE.SetSelectionMethod( twAllNewEntries );
  TRAVERSE.SetOnEHProc( FlagTransactionAsTransferred );
  TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
end;

function PrepareXML( const FromDate, ToDate : integer; SelectedAccounts : TStringList) : string;
//routine to generate the xml string, split out so can use in unit tests
var
  i : integer;
  ba : TBank_Account;
begin
  XMLDoc := ConstructXMLDocument( 'XML');
  try
    try
      XMLDoc.PreserveWhiteSpace := false;
      SetNodeAttr( XMLDoc.FirstChild, 'xmlns', 'http://3rdParty.Myob.Data/bclink.xsd');

      ExtractNode := AppendNode( XMLDoc.FirstChild, 'EXTRACT');

      SetNodeText( ExtractNode, 'CLIENTID', MyClient.clFields.clCode);
      SetNodeText( ExtractNode, 'EXTRACTID', StDateSt.StDateToDateString( 'yyyymmdd', StDate.CurrentDate, false) +
                                             StDateSt.StTimeToTimeString( 'hhmmss', stDate.CurrentTime, false));
      SetNodeText( ExtractNode, 'DTSTART', StDateToDateString( 'yyyymmdd', FromDate, false));
      SetNodeText( ExtractNode, 'DTEND', StDateToDateString( 'yyyymmdd', ToDate, false));

      for i := 0 to SelectedAccounts.Count - 1 do
      begin
        ba := TBank_Account( SelectedAccounts.Objects[i]);
        //NOTE: Traverse Units use MyClient object!!!!!!
        Traverse.Clear;
        Traverse.SetSortMethod( csdateEffective);
        Traverse.SetSelectionMethod( twAllNewEntries);
        Traverse.SetIncludeZeroAmounts(PRACINI_ExtractZeroAmounts);
        Traverse.SetOnAHProc( DoAccountHeader);
        Traverse.SetOnEHProc( DoTransaction);
        Traverse.SetOnDSProc( DoDissection);

        Traverse.TraverseEntriesForAnAccount( ba, FromDate, ToDate);
      end;

      result := XMLDoc.XML;

      if DebugMe then
        SaveXMLStringToFile( result, datadir + 'myobao_extract_' + MyClient.clFields.clCode + '.xml');
    except
      On e : Exception do
      begin
        raise EInterfaceError.Create( 'Error generating output - ' + E.Message);
      end;
    end;
  finally
    XMLDoc := nil;
    AccountNode := nil;
    TrxNode := nil;
    ExtractNode := nil;
  end;
end;

procedure ExtractData( const FromDate, ToDate : integer; const SaveTo : string);
const
  ThisMethodName = 'ExtractData';
var
  SelectedAccounts : TStringList;
  i : integer;
  ba : TBank_Account;
  s : string;
  TransferOK : boolean;
  TransferMsg : string;
  ResultStr : string;
  sMYOBTitle : string;
  NumEntriesToExtract : integer;

  //UncodedDataFound : boolean;
  InvalidDataFound : boolean;

  CodedCount, UncodedCount, InvalidCount : integer;
begin
  //select accounts to extract
  SelectedAccounts := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate);
  if SelectedAccounts = nil then
    exit;

  try
    sMYOBTitle := Software.GetMYOBAO_Name( MyClient.clFields.clCountry);
    NoOfEntries := 0;

    //check for uncoded data
    //UncodedDataFound := false;
    InvalidDataFound := false;
    NumEntriesToExtract := 0;

    //check for invalid GST codes
    s := ''; 
    for i := 0 to SelectedAccounts.Count - 1 do
    begin
      ba := TBank_Account( SelectedAccounts.Objects[i]);
      //count number of entries to extract
      NumEntriesToExtract := NumEntriesToExtract + TravUtils.NumberAvailableForExport( ba, FromDate, ToDate);
      //test for invalidly coded entries, will detect invalid GST classes as well
      TravUtils.CountTransactionStatus( ba, CodedCount, UncodedCount, InvalidCount, FromDate, ToDate);

      //UncodedDataFound := UncodedDataFound or ( UncodedCount > 0);
      InvalidDataFound := InvalidDataFound or ( InvalidCount > 0);

      if InvalidCount > 0 then
      begin
        s := s + 'Account ' + ba.baFields.baBank_Account_Number + ' contains ' +
             inttostr( InvalidCount) + ' invalidly coded entries'#13;
      end;
    end;

    if NumEntriesToExtract = 0 then
    begin
      HelpfulErrorMsg('There are no entries to transfer in the selected accounts.', 0);
      exit;
    end;

    if InvalidDataFound then
    begin
      HelpfulErrorMsg( s + #13 + 'You must correct this before continuing.', 0);
      Exit;

      //if AskYesNo( 'Invalidly coded entries found', s + #13'Do you want to continue?' , DLG_YES, 0) <> DLG_YES then
      //  Exit;
    end;

    //Form xml string for COM obj
    s := PrepareXML( FromDate, ToDate, SelectedAccounts);
    TransferOK := MYOBAO_Utils.SendTransactionToMYOBAO( s, ResultStr);

    //flag entries as transfered iff status is ok
    if TransferOK then
    Begin
       TransferMsg := 'Data successfully transferred to ' + sMYOBTitle + '.  ' + IntToStr( NoOfEntries) +  ' entries were transferred.';
       LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + TransferMsg );

       //now flag entries as have being transferred
       for i := 0 to SelectedAccounts.Count-1 do
       begin
         BA := TBank_Account( SelectedAccounts.Objects[ i ] );
         FlagEntriesAsTransferred( Ba, FromDate, ToDate);
       end;
       HelpfulInfoMsg( TransferMsg, 0 );
    end
    else
    begin
      HelpfulErrorMsg( 'Transfer to ' + sMYOBTitle + ' failed. ' + ResultStr,0);
    end;
  finally
    SelectedAccounts.Free;
  end;
end;

initialization
   DebugMe := LogUtil.DebugUnit( UnitName );

end.
