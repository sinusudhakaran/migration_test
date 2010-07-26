unit AppUserObj;

interface
uses
  classes;

type TAppUser = class
                 Code           : string;
                 FullName       : string;
                 CanAccessAdmin : boolean;
                 LRN            : integer;
                 SecurityLevel  : integer;
                 CanMemoriseToMaster : boolean;
                 HasRestrictedAccess : boolean;
                 ShowCMOnOpen   : boolean;
                 ShowPrinterDialog : boolean;
                 SuppressHeaderFooter: byte;
                 ShowPracticeLogo: boolean;
                end;

implementation

end.
 
