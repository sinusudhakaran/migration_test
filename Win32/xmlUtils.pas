unit xmlUtils;
interface
uses
  OmniXML,
  OmniXMLUtils,
  SysUtils,
  bk5Except;

type
   EBkXMLError = class( EInterfaceError);
   EBkXMLTagMissing = class( EBkXMLError);

//try to find a specified child node, raise exception if not found
function bkSelectChildNode( parentNode : IXMLNode; ChildNodeName : string; RaiseExceptIfMissing : boolean = true) : IXMLNode;

//write a string to file
procedure SaveXMLStringToFile( s : string; filename : string);

implementation
uses
  Classes;

//try to find a specified child node, raise exception if not found
function bkSelectChildNode( parentNode : IXMLNode; ChildNodeName : string; RaiseExceptIfMissing : boolean = true) : IXMLNode;
// param  parentNode     Node to search in
// param  childnodename  Text name of child node
// opt param raiseExceptionIfMissing
// returns childnode if found otherwise raises exception
begin
  result := FindNode( parentNode, childNodeName);

  if (result = nil) and RaiseExceptIfMissing then
    raise EBkXMLTagMissing.Create( 'XML Node ' + childNodeName + ' is missing');
end;

//write a string to file
procedure SaveXMLStringToFile( s : string; filename : string);
var
  sl : TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Text := s;
    sl.SaveToFile( filename);
  finally
    sl.Free;
  end;
end;


end.
