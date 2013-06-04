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
  {
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := 'www.bankstream.com.au';
  end
  else
  }
  begin
    Result := 'www.banklink.com.au';
  end;
end;

class function TUrls.DefaultBConnectPrimaryHost: String;
begin
  {
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := 'secure1.bankstream.co.nz';
  end
  else
  }
  begin
    Result := 'secure1.banklink.co.nz'
  end;
end;

class function TUrls.DefaultBConnectSecondaryHost: String;
begin
  {
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := 'secure2.bankstream.co.nz';
  end
  else
  }
  begin
    Result := 'secure2.banklink.co.nz'
  end;
end;

class function TUrls.DefaultDownloaderURL: String;
begin
  {
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := 'https://secure2.bankstream.co.nz/DownloaderService/DownloaderService.svc';
  end
  else
  }
  begin
    Result := 'https://secure2.banklink.co.nz/DownloaderService/DownloaderService.svc';
  end;
end;

class function TUrls.DefaultDownloaderURL2: String;
begin
  {
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := 'https://secure1.bankstream.co.nz/DownloaderService/DownloaderService.svc';
  end
  else
  }
  begin
    Result := 'https://secure1.banklink.co.nz/DownloaderService/DownloaderService.svc';
  end;
end;

class function TUrls.DefaultNZCatalogServer: String;
begin
  {
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := 'www.bankstream.co.nz'
  end
  else
  }
  begin
    Result := 'www.banklink.co.nz'
  end;
end;

class function TUrls.DefaultUKCatalogServer: String;
begin
  {
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := 'www.bankstream.co.uk';
  end
  else
  }
  begin
    Result := 'www.banklink.co.uk';
  end;
end;

class function TUrls.DefaultWebNotesMethodURI: String;
begin
  {
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := 'http://Bankstream.WebNotes.Interfaces/IPracticeIntegrationFacade';
  end
  else
  }
  begin
    Result := 'http://BankLink.WebNotes.Interfaces/IPracticeIntegrationFacade';
  end;
end;

class function TUrls.DefaultWebNotesURL: String;
begin
  {
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := 'https://www.bankstreamonline.com/services/practiceintegrationfacade.svc';
  end
  else
  }
  begin
    Result := 'https://www.banklinkonline.com/services/practiceintegrationfacade.svc';
  end;
end;

class function TUrls.DefInstListLinkAU: String;
begin
  {
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := 'http://www.bankstream.com.au/about_institutions.html';
  end
  else
  }
  begin
    Result := 'http://www.banklink.com.au/about_institutions.html';
  end;
end;

class function TUrls.DefInstListLinkNZ: String;
begin
  {
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := 'http://www.bankstream.co.nz/about_institutions.html';
  end
  else
  }
  begin
    Result := 'http://www.banklink.co.nz/about_institutions.html';
  end;
end;

class function TUrls.DefInstListLinkUK: String;
begin
  {
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := 'http://www.bankstream.co.uk/about_institutions.html';
  end
  else
  }
  begin
    Result := 'http://www.banklink.co.uk/about_institutions.html';
  end;
end;

class function TUrls.GetWebSites(Index: Integer): String;
begin
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := BankstreamWebSites[Index];
  end
  else
  begin
    Result := whBankLinkWebSites[Index];
  end;
end;

class function TUrls.GetWebSiteURLs(Index: Integer): String;
begin
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := BankstreamWebSiteURLs[Index];
  end
  else
  begin
    Result := whBankLinkWebSiteURLs[Index];
  end;
end;

class function TUrls.OnlineServicesDefaultUrl: String;
begin
  {
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := 'https://www.bankstreamonline.com';
  end
  else
   }
  begin
    Result := 'https://www.banklinkonline.com';
  end;
end;

class function TUrls.ProvisionalAccountUrl: String;
begin
  {
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := 'http://www.bankstream.co.nz';
  end
  else
  }
  begin
    Result := 'http://www.banklink.co.nz';
  end;  
end;

end.
