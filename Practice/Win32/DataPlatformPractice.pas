// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : https://integration.banklinkonline.com/Services/DataPlatformPractice.svc?wsdl
//  >Import : https://integration.banklinkonline.com/Services/DataPlatformPractice.svc?wsdl=wsdl0
//  >Import : https://integration.banklinkonline.com/Services/DataPlatformPractice.svc?wsdl=wsdl0>0
//  >Import : https://integration.banklinkonline.com/Services/DataPlatformPractice.svc?xsd=xsd0
//  >Import : https://integration.banklinkonline.com/Services/DataPlatformPractice.svc?xsd=xsd1
// Encoding : utf-8
// Codegen  : [wfMapStringsToWideStrings+, wfUseScopedEnumeration-]
// Version  : 1.0
// (28/03/2012 2:33:09 p.m. - - $Rev: 25127 $)
// ************************************************************************ //

unit DataPlatformPractice;

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
  // typically map to predefined/known XML or Embarcadero types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]



  // ************************************************************************ //
  // Namespace : http://integration.banklinkonline.com/DataPlatform/Practice/2012/03
  // soapAction: http://integration.banklinkonline.com/DataPlatform/Practice/2012/03/IDataPlatformPractice/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : DataPlatformPracticeHttp
  // service   : DataPlatformPractice
  // port      : DataPlatformPracticeHttp
  // URL       : https://integration.banklinkonline.com/Services/DataPlatformPractice.svc
  // ************************************************************************ //
  IDataPlatformPractice = interface(IInvokable)
  ['{0BA77D44-09E1-67D0-1DC2-FBB2714CB8D7}']
    function  Echo(const aString: WideString): WideString; stdcall;
    function  UploadData(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const xmlData: WideString): Boolean; stdcall;
    function  SetAccountTags(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const xmlData: WideString): Boolean; stdcall;
  end;

function GetIDataPlatformPractice(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IDataPlatformPractice;


implementation
  uses SysUtils;

function GetIDataPlatformPractice(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IDataPlatformPractice;
const
  defWSDL = 'https://integration.banklinkonline.com/Services/DataPlatformPractice.svc?wsdl';
  defURL  = 'https://integration.banklinkonline.com/Services/DataPlatformPractice.svc';
  defSvc  = 'DataPlatformPractice';
  defPrt  = 'DataPlatformPracticeHttp';
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
    Result := (RIO as IDataPlatformPractice);
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
  InvRegistry.RegisterInterface(TypeInfo(IDataPlatformPractice), 'http://integration.banklinkonline.com/DataPlatform/Practice/2012/03', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IDataPlatformPractice), 'http://integration.banklinkonline.com/DataPlatform/Practice/2012/03/IDataPlatformPractice/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(IDataPlatformPractice), ioDocument);

end.