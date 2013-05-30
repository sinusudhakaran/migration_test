unit MYOBAO_Utils;
//------------------------------------------------------------------------------
{
   Title:        MYOB Accountants Office utilities

   Description:  Provides a set of utilities that do not link many other units

   Author:       Matthew Hopkins May 2005

   Remarks:

   Revisions:

}
//------------------------------------------------------------------------------
interface
uses
  bk5except, sysUtils;

const
  bkMYOBAO_COM_Refresh_Supported_User_Cancelled = 0;
  bkMYOBAO_COM_Refresh_Supported_User_Selected_Ledger = 1;
  bkMYOBAO_COM_Refresh_List_Retrieved = 10;
  bkMYOBAO_COM_Refresh_AccessDenied = 254;
  bkMYOBAO_COM_Refresh_NotSupported = 255;

//returns true if bclink object can be instantiated and logon succeeds
function MYOBAO_bcLink_Exists : boolean;

//returns the ledger path from myob db
function GetMYOBLedgerPath( var LedgerPath : string) : integer;

//takes an xml string and uploads it to MYOBAO
function SendTransactionToMYOBAO( const XMLString : string; var ResultStr : string) : boolean;

//returns an xml string containing the chart for the selected ledger path
function GetXMLChart( const bkClientCode : string;
                      const LedgerPath : string;
                      var CreditAdjAcct, DebitAdjAcct, PrivateUseAdjAcct : string) : string;

//gets the bankman id (banklink id) from myob ao
function GetBankManID( const LedgerPath : string; var BankManID : string) : boolean;

//sets the bankman id (banklink id) from myob ao
procedure SetBankManID( const LedgerPath : string; ID : string);

function GetLastMYOBError : string;
function GetLastMYOBErrorNo : integer;

//returns true if bankman id matches the current bk5 client code, prompts user
//to change it if required
function CheckBankManID( const LedgerPath, bkCode : string;
                          AllowUpdateIfDiff : boolean = true; NoMsgIfOK : boolean = false) : boolean;

function SetBankPath() : boolean;

//returns true if the bankpath is set in the users environment settings
function BankPathIsSet : boolean;


{$IFDEF BK_UNITTESTINGON}
function ReadStatus( RawXML : string; var StatusStr : string) : integer; overload;
{$ENDIF}

//******************************************************************************
implementation

uses
  ComObj, Variants, Dialogs, Select_MYOBAO_GLfrm, OmniXMLUtils, LogUtil,
  glConst, classes,
  OmniXml, xmlUtils,
  errormorefrm, warningmorefrm, infoMorefrm, yesnodlg, GlobalDirectories,
  Registry, windows, WinUtils, Globals, bkProduct;

const
  bcLinkComID = 'bclink.bclink';
  unitname = 'MYOBAO_Utils';

var
  bkMYOBAO_SecurityID : string;
  bkMYOBAO_LastError : string;
  bkMYOBAO_LastErrorNo : integer;
  DebugMe : boolean;

function GetLastMYOBError : string;
begin
  result := bkMYOBAO_LastError;
end;

function GetLastMYOBErrorNo : integer;
begin
  result := bkMYOBAO_LastErrorNo;
end;

function ReadStatus( parentNode : IXMLNode; var StatusStr : string) : integer; overload;
var
  aNode : IXMLNode;
begin
  result := -1;
  StatusStr := 'No status node found';

  aNode := FindNode( parentnode, 'status');
  if Assigned( aNode) then
  begin
    result := GetNodeTextInt64( aNode, 'code', -1);
    StatusStr := '[' + inttostr( result) + '] ' + GetNodeTextStr( aNode, 'message', '');
  end;


  bkMYOBAO_LastError := StatusStr;
  bkMYOBAO_LastErrorNo := result;
end;

function ReadStatus( RawXML : string; var StatusStr : string) : integer; overload;
var
  xmlDoc : IXMLDocument;
begin
  result := -1;
  StatusStr := 'No status node found';

  xmlDoc := CreateXMLDoc;
  try
    xmlDoc.PreserveWhiteSpace := false;

    if XMLLoadFromString( xmlDoc, RawXML) then
      result := ReadStatus( xmlDoc.FirstChild, StatusStr)
    else
      raise EBkXMLError.Create( 'XML parse error: ' + xmlDoc.ParseError.Reason);
  finally
    xmlDoc := nil;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MYOBAO_bcLink_Exists : boolean;
var
  bcLinkObj : OleVariant;
  DenyString : string;
begin
  result := false;

  try
    bcLinkObj := CreateOLEObject(bcLinkComID);
  except
    //invalid class string
    bcLinkObj := UnAssigned;
  end;

  if not (VarIsEmpty(bcLinkObj)) then
  begin
    try
      try
        //pass security token
        result := bcLinkObj.logon(bkMYOBAO_SecurityID,'','');
        DenyString := bcLinkObj.SecurityDenyLogonText;

        if DenyString <> '' then
          LogUtil.LogError( Unitname, 'Logon failed with DenyString = ' + DenyString);
      except
        On E : Exception do
          LogError( Unitname, 'MYOBAO_bcLink_Exists failed with error ' + E.Message);
      end;
    finally
      bcLinkObj := UnAssigned;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetListOfMYOB_GLs( var GLList : string) : integer;
var
  bcLinkObj : OleVariant;
  LoginOK : boolean;
begin
  result := bkMYOBAO_COM_Refresh_NotSupported;

  try
    bcLinkObj := CreateOLEObject(bcLinkComID);
  except
    //invalid class string
    bcLinkObj := UnAssigned;
  end;

  if not (VarIsEmpty(bcLinkObj)) then
  begin
    try
      //pass security token
      loginOK := bcLinkObj.logon(bkMYOBAO_SecurityID,'','');
      if (not loginOK) then
      begin
        result := bkMYOBAO_COM_Refresh_AccessDenied;
      end
      else
      begin
        //security login ok, get xml string
        GLList := bcLinkObj.GetGLList;
        result := bkMYOBAO_COM_Refresh_List_Retrieved;

       if DebugMe then
         SaveXMLStringToFile( GlList, glDataDir + 'myobao_gllist.xml');
      end;
    finally
      bcLinkObj := UnAssigned;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetMYOBLedgerPath( var LedgerPath : string) : integer;
var
  s : string;
begin
  try
    //get list of gl's
    result := GetListOfMYOB_GLs( S);
    if result <> bkMYOBAO_COM_Refresh_List_Retrieved then
      exit;

    //list retrieved, display list in dialog
    result := SelectMYOBAO_GL( LedgerPath, s);
  except
    on e : exception do
    begin
      //exception raised getting list, save to log
      LogError( Unitname, 'GetMYOBLedgerPath failed with error ' + e.Message);
      result := bkMYOBAO_COM_Refresh_NotSupported;
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SendTransactionToMYOBAO( const XMLString : string; var ResultStr : string) : boolean;
var
  bcLinkObj : Variant;
  s : string;
begin
  try
    bcLinkObj := CreateOLEObject(bcLinkComID);
  except
    //invalid class string
    bcLinkObj := UnAssigned;
  end;

  if not (VarIsEmpty(bcLinkObj)) then
  begin
    try
      //pass security token
      bcLinkObj.logon(bkMYOBAO_SecurityID,'','');

      //send string
      s := bcLinkObj.SendTransactionsToAO( XMLString);

      //get status from response
      //need to convert to lowercase as MYOB are mixing their cases
      s := lowercase(s);

      result := ( ReadStatus( s, ResultStr) = 0);   // 0 = OK
    finally
      bcLinkObj := UnAssigned;
    end;
  end
  else
    raise EInterfaceError.Create( 'Error instantiating ' + bcLinkComID);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetXMLChart( const bkClientCode : string;
                      const LedgerPath : string;
                      var CreditAdjAcct, DebitAdjAcct, PrivateUseAdjAcct : string) : string;
//reads the chart in XML format from MYOBAO
//parameters:
//  LedgerPath       : code for the MYOB AO GL
//  CreditAdjAcct    : account code for BAS credit adjustments
//  DebitAdjAcct     : account code for BAS debit adjustments
//  PrivateUseAdj    : account code for BAS private use
//
//Raise exception if error detected, returns xml string containing the chart
var
  XmlParser : IXMLDocument;
  n : IXMLNode;
  bcLinkObj : Variant;
  s : string;
  bmid : string;
  Code : integer;
  StatusStr : string; //bankman id in GL
  aMsg : string;
begin
  result := '';
  CreditAdjAcct := '';
  DebitAdjAcct := '';
  PrivateUseAdjAcct := '';

  try
    bcLinkObj := CreateOLEObject(bcLinkComID);
  except
    //invalid class string
    bcLinkObj := UnAssigned;
  end;

  if not (VarIsEmpty(bcLinkObj)) then
  begin
    try
      //pass security token
      bcLinkObj.logon(bkMYOBAO_SecurityID,'','');

      //get gst settings and bankman id
      s := bcLinkObj.GetGSTSettings( LedgerPath);

      if DebugMe then
        SaveXMLStringToFile( s, glDataDir + 'myobao_gstsettings_' + LedgerPath + '.xml');

      xmlParser := CreateXMLDoc;
      try
        xmlParser.PreserveWhiteSpace := false;
        if XMLLoadFromString( xmlParser, s) then
        begin
          code := ReadStatus( xmlParser.FirstChild, StatusStr);
          if code = 0 then
          begin
            //status was ok
            //find ledger settings node
            n := bkSelectChildNode( xmlParser.FirstChild, 'LedgerSettings');
            n := bkSelectChildNode( n, 'LedgerSetting');
            bmid := GetNodeCData( bkSelectChildNode( n, 'bankmanid'));

            //verify that this is the correct ledger to refresh from
            if bmid <> bkClientCode then
            begin
              //raise EInterfaceError.Create( 'BankManID field mismatch.  Expected ' + bkClientCode +
              //                              ' but found ' + bmid);

              if bmid = '' then
                aMsg := 'The ' + TProduct.BrandName + ' ID for the selected ledger path is not set.'#13#13 +
                        'Do you still want to refresh the chart?'
              else
              aMsg := 'The ' + TProduct.BrandName + ' ID for the selected ledger path is set to ' + bmid +'. '#13#13 +
                      'This does not match your current ' + ShortAppName + ' client code (' + bkClientCode + ') '+
                      'do you still want to refresh the chart?';

              if AskYesNo( 'Refresh Chart',
                           aMsg,
                           DLG_YES,
                           0) <> DLG_YES then
              begin
                raise ERefreshAbandoned.Create( 'User abandoned refresh');
              end;
            end;

            //read adjustment account values, these are used to set
            //the GST class for AU charts
            CreditAdjAcct := GetNodeText( bkSelectChildNode( n, 'acc_gstcad'));
            DebitAdjAcct := GetNodeText( bkSelectChildNode( n, 'acc_gstdad'));
            PrivateUseAdjAcct := GetNodeText( bkSelectChildNode( n, 'acc_gstpri'));

            //bankman id and GST settings read successfully
            //read xml chart
            result := bcLinkObj.GetChart( LedgerPath);

            if DebugMe then
              SaveXMLStringToFile( result, glDataDir + 'myobao_chart_' + LedgerPath + '.xml');

            //check status
            code := ReadStatus( result, StatusStr);
            if code <> 0 then
              raise EInterfaceError.Create('Error reading chart - ' + StatusStr);
          end
          else
          begin
            //error reading gst status
            if Code = 67 then
              raise EInterfaceError.Create('Unknown ledger path [' + LedgerPath+ '].')
            else
              raise EInterfaceError.Create('Unable to read GST settings - ' + StatusStr);
          end;
        end
        else
          raise EBkXMLError.Create( 'XML parse error: ' + xmlParser.ParseError.Reason);

      finally
        xmlParser := nil;
      end;
    finally
      bcLinkObj := UnAssigned;
    end;
  end
  else
    raise EInterfaceError.Create( 'Error instantiating ' + bcLinkComID);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetBankManID( const LedgerPath : string; var BankManID : string) : boolean;
var
  XmlParser : IXMLDocument;
  n : IXMLNode;
  bcLinkObj : Variant;
  s : string;
  Status : string;
  Code : integer;
begin
  BankManID := '';
  Code := 0;
  result := false;

  try
    bcLinkObj := CreateOLEObject(bcLinkComID);
  except
    //invalid class string
    bcLinkObj := UnAssigned;
  end;

  try
    if not (VarIsEmpty(bcLinkObj)) then
    begin
      try
        //pass security token
        bcLinkObj.logon(bkMYOBAO_SecurityID,'','');

        //get gst settings and bankman id
        s := bcLinkObj.GetGSTSettings( LedgerPath);

        xmlParser := CreateXMLDoc;
        try
          xmlParser.PreserveWhiteSpace := false;
          if XMLLoadFromString( xmlParser, s) then
          begin
            //expect a top level status node
            code := ReadStatus( xmlParser.FirstChild, status);
            //return value of 0 indicates success
            if code = 0 then
            begin
              //expected structure
              //<ledgersettings>
              //  <ledgersetting>
              //    <bankmanid>[CData...
              n := bkSelectChildNode( xmlParser.FirstChild, 'LedgerSettings');
              n := bkSelectChildNode( n, 'LedgerSetting');
              //read cdata value
              BankManID := GetNodeCData( n, 'bankmanid', #1);
              if (BankManID = #1) then
                raise EInterfaceError.Create( 'BankManID field not present')
              else
                result := true;
            end
            else
              raise EInterfaceError.Create( Status);
          end
          else
            raise EBkXMLError.Create( 'XML parse error: ' + xmlParser.ParseError.Reason);
        finally
          xmlParser := nil;
        end;
      finally
        bcLinkObj := UnAssigned;
      end;
    end
    else
      raise EInterfaceError.Create( 'Error instantiating ' + bcLinkComID);
  except
    on e : exception do
    begin
      bkMYOBAO_LastError := E.Message;
      bkMYOBAO_LastErrorNo := Code;
      LogUtil.LogError( Unitname, 'GetBankManId failed - ' + E.Message);
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetBankManID( const LedgerPath : string; ID : string);
//sets the bankman id in the specified ledger path
//raises an exception if it cant be set
var
  bcLinkObj : Variant;
  Code : integer;
  Status : string;
  bmid : string; //bankman id in GL
begin
  try
    bcLinkObj := CreateOLEObject(bcLinkComID);
  except
    //invalid class string
    bcLinkObj := UnAssigned;
  end;

  if not (VarIsEmpty(bcLinkObj)) then
  begin
    try
      //pass security token
      bcLinkObj.logon(bkMYOBAO_SecurityID,'','');

      //set bankman id
      bmid := bcLinkObj.SetBankManID( LedgerPath, ID);
      code := ReadStatus( bmid, Status);

      if code <> 0 then
        raise EInterfaceError.Create( 'Error setting bankmanid - ' + Status);
    finally
      bcLinkObj := UnAssigned;
    end;
  end
  else
    raise EInterfaceError.Create( 'Error instantiating ' + bcLinkComID);
end;

function CheckBankManID( const LedgerPath, bkCode : string;
                          AllowUpdateIfDiff : boolean = true; NoMsgIfOK : boolean = false) : boolean;
//check that the bank man id in the save to field is set
// LedgerPath :        contains the ledger path to the MYOB GL
// bkCode :            is the BankLink code to test against the bankman id in the GL
// AllowUpdateIfDiff : allow the user to override existing bankman id
// NoMsgIfOk         : dont show message if bankman id is ok
//
// Returns true if bankman id matched current client code
var
  bmid : string;
  aMsg : string;
begin
  result := false;

  //get current banklink id
  if LedgerPath = '' then
  begin
    HelpfulErrorMsg( 'Please select a ledger path to save entries into.',0);
    exit;
  end;

  if myobao_utils.GetBankManID( LedgerPath, bmid) then
  begin
    //is it set
    if (bmid = bkCode) then
    begin
      result := true;
      if not NoMsgIfOK then
        HelpfulInfoMsg( 'The ' + TProduct.BrandName + ' ID is set correctly for ledger path ' + LedgerPath, 0);
    end
    else
    begin
      if bmid = '' then
      begin
        //is blank, ask user if they want to set it to current code
        aMsg := 'The ' + TProduct.BrandName + ' ID in ledger path ' + LedgerPath + ' is not currently set.'#13#13+
                'Do you want to set it to "' + bkCode + '"?';
      end
      else
      begin
        if AllowUpdateIfDiff then
        begin
          //is set already to something else
          aMsg := 'The ' + TProduct.BrandName + ' ID in ledger path ' + LedgerPath + ' is currently set to "' +
                bmid + '"."'#13#13 +
                'Do you want to change it to "'+ bkCode + '"?';
        end
        else
        begin
          //is set already but user is not allowed to update it
          aMsg := 'The ' + TProduct.BrandName + ' ID in ledger path ' + LedgerPath + ' does not match your existing client code.';
          HelpfulErrorMsg( aMSg, 0);
          exit;
        end;
      end;

      if AskYesNo( 'Set ' + TProduct.BrandName + ' ID', aMsg, dlg_Yes, 0) = dlg_Yes then
      begin
        try
          SetBankManID( LedgerPath, bkCode);
          Logutil.LogMsg( lminfo, UnitName, 'BankManID for ledger path ' + LedgerPath + ' updated to ' + bkcode);

          Result := true;
        except
          On e : exception do
            HelpfulErrorMsg( 'The ' + TProduct.BrandName + ' ID could not be set due to the following error:'#13#13+
                             E.Message + '.', 0);
        end;
      end;
    end;
  end
  else
  begin
    if myobao_utils.GetLastMYOBErrorNo = 67 then
      aMsg := 'Unable to check ' + TProduct.BrandName + ' ID. ' + LedgerPath + ' may not be a valid ledger path.'
    else
      aMsg := 'Unable to check ' + TProduct.BrandName + ' ID. ' + GetLastMYOBError + '.';

    HelpfulWarningMsg( aMsg, 0);
  end;
end;

function BankPathEnv : string;
begin
  try
    //check user setting first then system setting
    result := WinUtils.GetGlobalEnvironment( 'BankPath', false);
    if result = '' then
      result := WinUtils.GetGlobalEnvironment( 'BankPath', true); //user
  except
    on e : exception do
    begin
      result := 'ERR';
    end;
  end;
end;

function BankPathIsSet : boolean;
begin
  result := (lowerCase( BankPathEnv) = lowerCase( GlobalDirectories.glDataDir));
end;

function SetBankPath() : boolean;
var
  bPath : string;
  aMsg : string;
  SetOK : boolean;
begin
  result := true;
  bPath := BankPathEnv;

  if bPath = GlobalDirectories.glDataDir then
  begin
    HelpfulInfoMsg( 'The BankPath environment variable is set correctly.', 0);
    Exit;
  end;


  if bPath = '' then
  begin
    //is blank, ask user if they want to set it to current code
    aMsg := 'The BankPath environment variable is not currently set.'#13#13+
            'Do you want to set it to "' + GlobalDirectories.glDataDir + '"?';
  end
  else
  begin
    aMsg := 'The BankPath environment variable is currently set to'#13+
            bPath + #13#13+
            'Do you want to change it to "' + GlobalDirectories.glDataDir + '"?';
  end;

  if AskYesNo( 'Set Bankpath environment variable', aMsg, dlg_yes, 0) = dlg_yes then
  begin
    try
      //try setting at system level first
      SetOK := WinUtils.SetGlobalEnvironment( 'BankPath', GlobalDirectories.glDataDir, false);
      if not SetOK then
        //try settings at user level
        SetOK := WinUtils.SetGlobalEnvironment( 'BankPath', GlobalDirectories.glDataDir, true);

      if SetOK then
        HelpfulInfoMsg('BankPath has been updated.', 0)
      else
        HelpfulErrorMsg( 'BankPath could not be updated. ', 0);

    except
      On E : Exception do
        HelpfulErrorMsg( 'BankPath could not be updated. ' + E.Message + ' [' + E.ClassName + ']',0);
    end;
  end;
end;

initialization
  bkMYOBAO_SecurityID := '1475286309';
  bkMYOBAO_LastError := '';
  DebugMe := LogUtil.DebugUnit( UnitName );

end.
