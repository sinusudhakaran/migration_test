unit upgExceptions;

interface
uses
   sysUtils;

type
  EbkUpgradeError = class( Exception);

  EbkupgFileAccess = class( EbkUpgradeError);
  EbkupgCatalogError = class( EbkUpgradeError);
  EbkupgIntegrityError = class( EbkUpgradeError);
  EbkupgDirectoryAccess = class( EbkUpgradeError);


implementation

end.
