unit AppUserObj;

//------------------------------------------------------------------------------
interface

uses
  classes;

type
  TAppUser = class
  private
    fCode                 : string;
    fFullName             : string;
    fCanAccessAdmin       : boolean;
    fLRN                  : integer;
    fSecurityLevel        : integer;
    fCanMemoriseToMaster  : boolean;
    fHasRestrictedAccess  : boolean;
    fShowCMOnOpen         : boolean;
    fShowPrinterDialog    : boolean;
    fSuppressHeaderFooter : byte;
    fShowPracticeLogo     : boolean;
    fAllowBanklinkOnline  : boolean;
    FPassword: String;
    FEmailAddress: String;
    FMYOBEmailAddress: string;
  public
    property Code                 : string  read  fCode                 write fCode;
    property FullName             : string  read  fFullName             write fFullName;
    property CanAccessAdmin       : boolean read  fCanAccessAdmin       write fCanAccessAdmin;
    property LRN                  : integer read  fLRN                  write fLRN;
    property SecurityLevel        : integer read  fSecurityLevel        write fSecurityLevel;
    property CanMemoriseToMaster  : boolean read  fCanMemoriseToMaster  write fCanMemoriseToMaster;
    property HasRestrictedAccess  : boolean read  fHasRestrictedAccess  write fHasRestrictedAccess;
    property ShowCMOnOpen         : boolean read  fShowCMOnOpen         write fShowCMOnOpen;
    property ShowPrinterDialog    : boolean read  fShowPrinterDialog    write fShowPrinterDialog;
    property SuppressHeaderFooter : byte    read  fSuppressHeaderFooter write fSuppressHeaderFooter;
    property ShowPracticeLogo     : boolean read  fShowPracticeLogo     write fShowPracticeLogo;
    property AllowBanklinkOnline  : boolean read  fAllowBanklinkOnline  write fAllowBanklinkOnline;
    property Password             : String  read  FPassword             write FPassword;
    property EmailAddress         : String  read  FEmailAddress         write FEmailAddress;
    property MYOBEmailAddress     : string  read  FMYOBEmailAddress     write FMYOBEmailAddress;

    function IsAdminUser :Boolean;
    function IsNormalUser : Boolean;
    function IsRestrictedUser : Boolean;
  end;

//------------------------------------------------------------------------------
implementation

{ TAppUser }

function TAppUser.IsAdminUser: Boolean;
begin
  Result := CanAccessAdmin and (not HasRestrictedAccess);
end;

function TAppUser.IsNormalUser: Boolean;
begin
  Result := ((not CanAccessAdmin) and (not HasRestrictedAccess));
end;

function TAppUser.IsRestrictedUser: Boolean;
begin
  Result := ((not CanAccessAdmin) and (HasRestrictedAccess));
end;

end.
 
