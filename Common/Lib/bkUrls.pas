unit bkUrls;

interface

uses
  bkProduct;
  
type
  TUrls = class
  private
    class function GetWebSites(Index: Integer): String; static;
    class function GetWebSiteURLs(Index: Integer): String; static;
  public
    class function DefaultNZCashMigrationURLOverview1 : String; static;
    class function DefaultAUCashMigrationURLOverview1 : String; static;
    class function DefaultNZCashMigrationURLOverview2 : String; static;
    class function DefaultAUCashMigrationURLOverview2 : String; static;
    class function DefaultCashbookForgotPasswordURL : String; static;
    class function DefaultCashbookSignupURL : String; static;
    class function DefaultCashbookLoginNZURL : String; static;
    class function DefaultCashbookLoginAUURL : String; static;
    class function CashbookAPILoginURL : String; static;
    class function CashbookAPIFirmsURL : String; static;

    class function CashbookAPIBusinessesURL : String; static;
    class function CashbookTransactionViewURL : String; static;
    class function CashbookAPITransactionsURL: string; static;
    class function CashbookAPIJournalsURL : string; static;
    class function CashbookAPICOAURL : String; static;

    class function CashbookAPIUploadURL : String; static;

    class function DefaultNZCatalogServer: String; static;
    class function DefaultAUCatalogServer: String; static;
    class function DefaultUKCatalogServer: String; static;
    class function DefaultDownloaderURL: String; static;
    class function DefaultDownloaderURL2: String; static;
    class function DefaultWebNotesURL: String; static;
    class function DefaultWebNotesMethodURI: String; static;
    class function DefaultBConnectPrimaryHost: String; static;
    class function DefaultBConnectSecondaryHost: String; static;
    class function BooksOnlineDefaultUrl: String; static;
    class function OnlineServicesDefaultUrl: String; static;
    class function DefInstListLinkNZ: String; static;
    class function DefInstListLinkAU: String; static;
    class function DefInstListLinkUK: String; static;
    class function ProvisionalAccountUrl: String; static;
    class function DefSecureFormLinkNZ: String; static;
    class function DefSecureFormLinkAU: String; static;
    class function DefIBizzFormLinkAU: String; static;
    class function DefAdditionalFormLinkAU: String; static;
    class function DefBGL360APIUrl : string; static;
    class function DefContentfulAPIUrl: string; static;

    class property WebSites[Index: Integer]: String read GetWebSites;
    class property WebSiteURLs[Index: Integer]: String read GetWebSiteURLs;
  end;
  
implementation

uses
  bkBranding, Globals, bkConst;

const
  BankstreamWebSites : Array[ whMin..whMax ] of String[ 20 ] =
  ( 'www.banklink.co.nz', 'www.banklink.com.au', 'www.bankstream.co.uk' );

  BankstreamWebSiteURLs : Array[ whMin..whMax ] of String[ 30 ] =
  ( 'http://www.banklink.co.nz', 'http://www.banklink.com.au', 'http://www.bankstream.co.uk' );

{ TUrls }

class function TUrls.BooksOnlineDefaultUrl: String;
begin
  Result := OnlineServicesDefaultUrl;
end;

class function TUrls.DefaultAUCatalogServer: String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := 'www.banklink.com.au';
  end
  else
  begin
    Result := 'www.banklink.com.au';
  end;
end;

class function TUrls.DefaultBConnectPrimaryHost: String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := 'secure1.banklink.co.nz'
  end
  else
  begin
    Result := 'secure1.banklink.co.nz'
  end;
end;

class function TUrls.DefaultBConnectSecondaryHost: String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := 'secure2.banklink.co.nz'
  end
  else
  begin
    Result := 'secure2.banklink.co.nz'
  end;
end;

class function TUrls.DefaultDownloaderURL: String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := 'https://secure2.banklink.co.nz/DownloaderService/DownloaderService.svc';
  end
  else
  begin
    Result := 'https://secure2.banklink.co.nz/DownloaderService/DownloaderService.svc';
  end;
end;

class function TUrls.DefaultDownloaderURL2: String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := 'https://secure1.banklink.co.nz/DownloaderService/DownloaderService.svc';
  end
  else
  begin
    Result := 'https://secure1.banklink.co.nz/DownloaderService/DownloaderService.svc';
  end;
end;

class function TUrls.DefaultNZCashMigrationURLOverview1 : String;
begin
  Result := 'https://www.banklinkonline.com/practice/nz/beforeyoustart.html';
end;

class function TUrls.DefaultAUCashMigrationURLOverview1 : String;
begin
  Result := 'https://www.banklinkonline.com/practice/au/beforeyoustart.html';
end;

class function TUrls.DefaultNZCashMigrationURLOverview2 : String;
begin
  Result := 'https://www.banklinkonline.com/practice/nz/migrationdetails.html';
end;

class function TUrls.DefaultAUCashMigrationURLOverview2 : String;
begin
  Result := 'https://www.banklinkonline.com/practice/au/migrationdetails.html';
end;

class function TUrls.DefaultCashbookForgotPasswordURL: String;
begin
  Result := 'https://secure.myob.com/oauth2/ManageIdentity/ForgotPassword';
end;

class function TUrls.DefaultCashbookLoginAUURL: String;
begin
  Result := 'https://Cashbook.myob.com.au';
end;

class function TUrls.DefaultCashbookLoginNZURL: String;
begin
  Result := 'https://Cashbook.myob.co.nz';
end;

class function TUrls.DefaultCashbookSignupURL: String;
begin
  Result := 'https://test.secure.myob.com/oauth2/Account/Login?ReturnUrl=%2f';
end;

class function TUrls.CashbookAPILoginURL: String;
begin
  Result := 'https://secure.myob.com/oauth2/v1/Authorize';
end;

class function TUrls.CashbookAPIFirmsURL: String;
begin
  Result := 'https://cashbook.myob.com.au/api/firms';
end;

class function TUrls.CashbookAPIUploadURL: String;
begin
  Result := 'https://adcloudservices.com.au/adcommon/v1/Upload';
end;

class function TUrls.DefaultNZCatalogServer: String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := 'www.banklink.co.nz';
  end
  else
  begin
    Result := 'www.banklink.co.nz';
  end;
end;

class function TUrls.DefaultUKCatalogServer: String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := 'www.banklink.co.uk';
  end
  else
  begin
    Result := 'www.banklink.co.uk';
  end;
end;

class function TUrls.DefaultWebNotesMethodURI: String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := 'http://BankLink.WebNotes.Interfaces/IPracticeIntegrationFacade';
  end
  else
  begin
    Result := 'http://BankLink.WebNotes.Interfaces/IPracticeIntegrationFacade';
  end;
end;

class function TUrls.DefaultWebNotesURL: String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := 'https://www.banklinkonline.com/services/practiceintegrationfacade.svc';
  end
  else
  begin
    Result := 'https://www.banklinkonline.com/services/practiceintegrationfacade.svc';
  end;
end;

class function TUrls.DefBGL360APIUrl: string;
begin
  {$ifdef DEBUG }
    Result := 'https://api-staging.bgl360.com.au/'
  {$else}
    Result := 'https://api.bgl360.com.au/';
  {$endif}
end;

class function TUrls.DefContentfulAPIUrl: string;
begin
  Result := 'https://cdn.contentful.com/spaces';
end;

class function TUrls.DefInstListLinkAU: String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := 'http://www.banklink.com.au/about_institutions.html';
  end
  else
  begin
    Result := 'http://www.banklink.com.au/about_institutions.html';
  end;
end;

class function TUrls.DefInstListLinkNZ: String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := 'http://www.banklink.co.nz/about_institutions.html';
  end
  else
  begin
    Result := 'http://www.banklink.co.nz/about_institutions.html';
  end;
end;

class function TUrls.DefInstListLinkUK: String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := 'http://www.banklink.co.uk/about_institutions.html';
  end
  else
  begin
    Result := 'http://www.banklink.co.uk/about_institutions.html';
  end;
end;

class function TUrls.GetWebSites(Index: Integer): String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := whBankLinkWebSites[Index];
  end
  else
  begin
    Result := whBankLinkWebSites[Index];
  end;
end;

class function TUrls.GetWebSiteURLs(Index: Integer): String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := whBankLinkWebSiteURLs[Index];
  end
  else
  begin
    Result := whBankLinkWebSiteURLs[Index];
  end;
end;

class function TUrls.OnlineServicesDefaultUrl: String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := 'https://www.banklinkonline.com';
  end
  else
  begin
    Result := 'https://www.banklinkonline.com';
  end;
end;

class function TUrls.CashbookAPIBusinessesURL: String;
begin
  Result := 'https://cashbook.myob.com.au/api/businesses';
end;

class function TUrls.CashbookAPICOAURL: String;
begin
  Result := 'https://cashbook.myob.com.au/api/businesses/%s/accounts';
end;

class function TUrls.CashbookAPIJournalsURL: string;
begin
  Result := 'https://cashbook.myob.com.au/api/businesses/%s/general_journals';
end;

class function TUrls.CashbookAPITransactionsURL: string;
begin
  Result := 'https://cashbook.myob.com.au/api/businesses/%s/bank_transactions';
end;

class function TUrls.CashbookTransactionViewURL: String;
begin
  Result := 'https://cashbook.myob.com.au/#businesses/%s/bank_transactions';
end;

class function TUrls.ProvisionalAccountUrl: String;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := 'http://www.banklink.co.nz';
  end
  else
  begin
    Result := 'http://www.banklink.co.nz';
  end;
end;

class function TUrls.DefSecureFormLinkNZ: String;
begin
  Result := 'http://www.banklink.co.nz/pdfs/NZ/NZ_BankLink_Secure_Client_Order_Form.pdf';
end;

class function TUrls.DefSecureFormLinkAU: String;
begin
  Result := 'http://www.banklink.com.au/pdfs/AU/AU_BankLink_Secure_Client_Order_Form.pdf';
end;

class function TUrls.DefIBizzFormLinkAU: String;
begin
  Result := 'http://www.banklink.co.nz';
end;

class function TUrls.DefAdditionalFormLinkAU: String;
begin
  Result := 'http://www.banklink.com.au/clientresources/forms/loading_new_accounts_au';
end;

end.

