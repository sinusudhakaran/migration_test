unit upgConstants;

interface
type
  TbkUpgDownloaderType = (dtHTTP, dtFILE);

const
  //upgrade actions
  uaCloseCallingApp = 100;
  uaInstallPending = 101;
  uaReloadUpgrader = 102;
  uaInstallComplete = 103;
  uaNothingPending = 104;

  uaDownloadFailed = 252;
  uaExceptionRaised = 253;
  uaUserCancelled = 254;
  uaUnableToLoad = 255;

  //application ids
  aidBK5_Practice = 5;
  aidBK5_Offsite = 6;
  aidUpgrader = 7;
  aidInvoicePlus = 8;
  aidBNotes = 9;
  aidSmartLink = 20;
  aidInternal = 90;
  aidGeneric = 99;
  aidPayablesPlus = 10;


  //application mutexes
  amuBK5_Practice  = 'BankLink 5';
  amuBK5_Offsite   = 'BankLink 5';
  amuInvoicePlus   = 'InvoicePlus';
  amuPayablesPlus  = 'PayablesPlus';
  amuBNotes        = 'BNotes';
  amuInternal      = '_BANKLINK_CORE_APPLICATION_';

  //actions
  acDownloadUpdates = 1;
  acInstallUpdates = 2;

  //country
  coNewZealand    = 0;
  coAustralia     = 1;
  coUnitedKingdom = 2;  
  coInternal      = 253;
  coSpecial       = 254;
  coTest          = 255;

  dbcoNewZealand = 1;
  dbcoAustralia = 2;
  dbcoUnitedKingdom = 3;

  //install filters
  //install all files
  ifAll = 0;
  //install only files that can be installed with app open
  ifUpgradeWithAppOpen = 1;
  //install only files that can be installed with app closed
  //most likely filter used by bkinstall
  ifUpgradeWithAppClosed = 2;
  //upgrade all files except one that require
  //app to be closed, then call bkinstall and close
  ifCloseIfRequired = 3;

  //Upgrade Method
  umNone = 0;             //Don't check this component
  umVersion = 1;          //Check File Version only
  umVersionCRC = 2;       //Check File Version and then CRC if file version the same
  umCRC = 3;              //Check File CRC only
  umCRCSize = 4;          //Check File CRC and then Size if file crc the same ???
  umSize = 5;             //Check File Size only
  umSizeDate = 6;         //Check File Size and then the Date if the file size is the same
  umDate = 7;             //Check File Date only
  umVersionDate = 8;      //Check File Version and then Date if file version the same
  umFull = 9;             //Check File Version then the file CRC then the file size then the file date


  DEFAULT_TEMP_DIR = 'butemp\';
  CatalogFilename = 'catalog.xml';
  UpgradeDllname = 'bkupgcor.dll';
  InstallExeName = 'bkinstall.exe';

  DefaultNZCatalogServer = 'www.banklink.co.nz';
  DefaultAUCatalogServer = 'www.banklink.com.au';
  DefaultUKCatalogServer = 'www.banklink.co.uk';  
  DefaultInternalCatalogServer = 'c:\';

  bkupgIniFile = 'bkupgcor.ini';

  IniDownloaderSection = 'Download Server';
  IniAppSection = 'AppID_%d';
  DefaultDownloaderURL = 'https://secure2.banklink.co.nz/DownloaderService/DownloaderService.svc';
  DefaultDownloaderURL2 = 'https://secure1.banklink.co.nz/DownloaderService/DownloaderService.svc';
  DefaultDownloaderMethodURI = 'http://BankLink.Downloader.Interfaces/IWebService';
  WriteErrorInfoKey = 'WriteErrorInfo';

  //Download Service Error Codes

  //Stages - Ones digit represents AppID
  dsAppParser = 100;
  dsUpdateAvailable = 200;
  dsDownloadVersionXML = 300;
  dsDownloadFiles = 400;

  {Errors (not constants since they come from SOAPS component
  See IP*Works Help for SOAPS Error Codes
  0-099 - TCP/IP Errors. Are the TCP/IP Errors (corespond to 100xx 110xx errors, where xx is
  the code we use.
        Notable: 001 - Host Not Found
                 007 - DNS Error Couldn't Resolve
                 020 - Connection Dropped by Remote Host
                 029 - Couldn't connect to the Internet (host not found)
                 060 - Connection Timed Out
                 061 - Connection Refused
  100-399 - Error Code from SOAP
        Notable: 118 - Firewall Error
                 151 - HTTP Error: NOTE: This shouldn't show up as it should be
                                   translated to the actual HTTP Response (see below)
                 173 - SOAP Fault
                 270-284 - SSL Error
  400-499 - HTTP Client Errors
        Notable: 404 - Server not Found
  500-599 - HTTP Server Errors - Error on Server
  800 - Upgrader Errors
  999 - Unknown Exception
  }
  deParserDownloadError = 800;
  deParserDLLError = 810; //ones digit = -dllresult
    //811 - Parser Fail (Unknown App)
    //812 - No DLL
    //813 - Wrong DLL
    //814 - Parser DLL Fail
  deAppXMLEmpty = 820;
  deUnknown = 999;


  //Extra Info Value Names (For Downloader Server)
  eiPracticeName = 'PracticeName';
  eiPracticeCode = 'PracticeCode';
  eiClientCode   = 'ClientCode';
  eiBankLinkCode = 'BankLinkCode';
  eiWinVersion   = 'WinVersion';
  eiPreviousVersion = 'PrevVersion';
  //InvoicePlus
  eiRegistration = 'Registration';
  eiActivation   = 'Activation';

  //App Parser Return Values
  Pa_Success = 0;
  Pa_PracticeCode = $01;
  Pa_PracticeName = $02;
  Pa_ClientCode   = $04;
  Pa_BankLinkCode = $08;
  // InvoicePlus
  Pa_Registration = $01;
  Pa_Activation   = $02;

  Pa_DllFailed = -4; //Returned by the Dll
  Pa_WrongDll = -3;
  Pa_NoDll = -2;
  Pa_Fail = -1;

  Pn_ParseBK5  = 'ParseBK5win.dll';
  Pn_ParseBNotes = 'ParseBNotes.dll';
  Pn_ParseIPlus  = 'parseIplus.dll';
  Pn_ParsePPlus  = 'parsePplus.dll';

  function GetAppIDMutex (AnAppID : integer) : string;

implementation

  function GetAppIDMutex (AnAppID : integer) : string;
  begin
    case AnAppID of
      aidBK5_Practice  :Result := amuBK5_Practice;
      aidBK5_Offsite   :Result := amuBK5_Practice;
      aidInvoicePlus   :Result := amuInvoicePlus;
      aidBNotes        :Result := amuBNotes;
      aidInternal      :Result := amuInternal;
      aidPayablesPlus  :Result := amuPayablesPlus;
    else
      Result := '';
    end;
  end;
end.
