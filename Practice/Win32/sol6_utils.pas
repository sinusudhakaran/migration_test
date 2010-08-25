unit Sol6_Utils;
//------------------------------------------------------------------------------
{
   Title:        MYOB Sol6 MAS utilities

   Description:  Provides a set of utilities that do not link many other units

   Author:       Matthew Hopkins Aug 2005

   Remarks:

   Revisions:

}
//------------------------------------------------------------------------------
interface
uses
  SysUtils;

//returns true if the s6bnk object can be instatiated and called sucessfully
function MAS_S6BNK_DLL_Exists : boolean;

//returns an xml string containing the chart for the selected ledger path
function GetXMLChart( const bkClientCode : string;
                      const LedgerPath : string) : string;

//request the xml string containg the list of gls that can be selected
function GetListOfMAS_GLs( const S6SystemLocation : string; var GLList : string) : integer;

function GetLastS6Error : string;
function GetLastS6ErrorNo : integer;

implementation
uses
  bk5Except,
  ComObj,
  Variants,
  Dialogs,
  classes,
  LogUtil,
  glConst,
  GlobalDirectories,
  OmniXMLUtils,
  OmniXml,
  Sol6_Const,
  xmlUtils;


const
  Unitname = 'Sol6_Utils';

var
  DebugMe : boolean;
  bkS6_LastError : string;
  bkS6_LastErrorNo : integer;

function GetLastS6Error : string;
begin
  result := bkS6_LastError;
end;

function GetLastS6ErrorNo : integer;
begin
  result := bkS6_LastErrorNo;
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

  bkS6_LastError := StatusStr;
  bkS6_LastErrorNo := result;
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

function MAS_S6BNK_DLL_Exists : boolean;
//returns true if the s6bnk object can be instatiated and called sucessfully
var
  s6bnkObj : OleVariant;
  //s : string;
  //Code : integer;
  //status : string;
begin
  result := false;

  try
    s6bnkObj := CreateOLEObject(s6bnkComID);
  except
    //invalid class string
    s6bnkObj := UnAssigned;
  end;

  if not (VarIsEmpty(s6bnkObj)) then
  begin
    result := true;
    try
      {try
        s := s6bnkobj.GetGLList('c:\s6client\');
        result := (ReadStatus( s, status) = 0);
      except
        On E : Exception do
          LogError( Unitname, 'MAS_S6BNK_DLL_Exists failed with error ' + E.Message);
      end;}
    finally
      s6bnkobj := UnAssigned;
    end;
  end;
end;

function GetXMLChart( const bkClientCode : string;
                      const LedgerPath : string) : string;
//reads the chart in XML format from MAS
//parameters:
//  LedgerPath       : code for the MYOB AO GL
//Raise exception if error detected, returns xml string containing the chart
var
  s6bnkObj : Variant;
  Code : integer;
  StatusStr : string;
begin
  result := '';
  try
    s6bnkObj := CreateOLEObject(s6bnkComID);
  except
    //invalid class string
    s6bnkObj := UnAssigned;
  end;

  if not (VarIsEmpty(s6bnkObj)) then
  begin
    try
      //read xml chart
      result := s6bnkObj.GetChart( LedgerPath);
      if DebugMe then
        SaveXMLStringToFile( result, glDataDir + 'mas_chart_' + bkClientCode + '.xml');

      //check status
      code := ReadStatus( result, StatusStr);
      if code <> 0 then
        raise EInterfaceError.Create('Error reading chart - ' + StatusStr);
    finally
      s6bnkObj := UnAssigned;
    end;
  end
  else
    raise EInterfaceError.Create( 'Error instantiating ' + s6bnkComID);
end;


//request the xml string containg the list of gls that can be selected
function GetListOfMAS_GLs( const S6SystemLocation : string; var GLList : string) : integer;
var
  s6bnkObj : OleVariant;
  statusStr : string;
begin
  result := bkS6_COM_Refresh_NotSupported;

  try
    s6bnkObj := CreateOLEObject(s6bnkComID);
  except
    //invalid class string
    s6bnkObj := UnAssigned;
  end;

  if not (VarIsEmpty(s6bnkObj)) then
  begin
    try
      GLList := s6bnkObj.GetGLList( S6SystemLocation);
      //parse result
      if ReadStatus( GlList, StatusStr) <> 0 then
      begin
        result := bkS6_COM_Refresh_AccessDenied;
       GLList := StatusStr;
      end
      else
        result := bkS6_COM_Refresh_List_Retrieved;
    finally
      s6bnkObj := UnAssigned;
    end;
  end;
end;

initialization
  DebugMe := LogUtil.DebugUnit( UnitName );

end.
