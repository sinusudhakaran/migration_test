// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : https://www.banklinkonline.com/Services/P5Auth.svc/mex?wsdl
//  >Import : https://www.banklinkonline.com/Services/P5Auth.svc/mex?wsdl:0
//  >Import : https://www.banklinkonline.com/Services/P5Auth.svc/mex?xsd=xsd0
//  >Import : https://www.banklinkonline.com/Services/P5Auth.svc/mex?xsd=xsd1
// Encoding : utf-8
// Version  : 1.0
// (6/08/2012 3:46:30 p.m. - - $Rev: 10138 $)
// ************************************************************************ //

unit P5Auth;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_OPTN = $0001;
  IS_NLBL = $0004;
  IS_REF  = $0080;


type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Borland types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]



  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: http://tempuri.org/IP5Auth/AuthenticateUser
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : BasicHttpBinding_IP5Auth
  // service   : P5Auth
  // port      : BasicHttpBinding_IP5Auth
  // URL       : https://dbserver/services/P5auth.svc
  // ************************************************************************ //
  IP5Auth = interface(IInvokable)
  ['{0C52ACC9-6BD0-9229-DD2B-F30A652F0ECE}']
    function  AuthenticateUser(const domain: WideString; const username: WideString; const password: WideString): Boolean; stdcall;
  end;

function GetIP5Auth(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IP5Auth;


implementation
  uses SysUtils;

function GetIP5Auth(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IP5Auth;
const
  defWSDL = 'https://www.banklinkonline.com/Services/P5Auth.svc/mex?wsdl';
  defURL  = 'https://www.banklinkonline.com/services/P5auth.svc';
  defSvc  = 'P5Auth';
  defPrt  = 'BasicHttpBinding_IP5Auth';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as IP5Auth);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


initialization
  InvRegistry.RegisterInterface(TypeInfo(IP5Auth), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IP5Auth), 'http://tempuri.org/IP5Auth/AuthenticateUser');
  InvRegistry.RegisterInvokeOptions(TypeInfo(IP5Auth), ioDocument);

end.