unit bkContactInformation;

interface

uses
  bkProduct;

type
  TContactInformation = class
  private
    class function GetSupportPhoneNo(Index: Integer): String; static;
    class function GetSupportEmail(Index: Integer): String; static;
    class function GetClientServicesEmail(Index: Integer): String; static;
  public
    class property SupportPhoneNo[Index: Integer]: String read GetSupportPhoneNo;
    class property SupportEmail[Index: Integer]: String read GetSupportEmail;
    class property ClientServicesEmail[Index: Integer]: String read GetClientServicesEmail;
  end;

implementation

uses
  bkBranding, Globals, bkConst;

var
  BankstreamSupportPhoneNo : Array[ whMin..whMax ] of String[ 20 ] = ('0800 226 554', '1 800 123 242', '0800 500 3081');

  BankstreamSupportEmail : Array[ whMin..whMax ] of String[ 30 ] = ('support@bankstream.co.nz', 'support@bankstream.com.au', 'support@bankstream.com');

  BankstreamClientServicesEmail : Array[ whMin..whMax ] of String[ 30 ] = ('clientservices@bankstream.co.nz', 'clientservices@bankstream.com.au', 'clientservices@bankstream.com');

{ TContactInformation }

class function TContactInformation.GetClientServicesEmail(Index: Integer): String;
begin
  if TProduct.ProductBrand = btbankstream then
  begin
    Result := BankstreamClientServicesEmail[Index];
  end
  else
  begin
    Result := whClientServicesEmail[Index];
  end;
end;

class function TContactInformation.GetSupportEmail(Index: Integer): String;
begin
  if TProduct.ProductBrand = btbankstream then
  begin
    Result := BankstreamSupportEmail[Index];
  end
  else
  begin
    Result := whSupportEmail[Index];
  end;
end;

class function TContactInformation.GetSupportPhoneNo(Index: Integer): String;
begin
  if TProduct.ProductBrand = btbankstream then
  begin
    Result := BankstreamSupportPhoneNo[Index];
  end
  else
  begin
    Result := whSupportPhoneNo[Index];
  end;
end;

end.
