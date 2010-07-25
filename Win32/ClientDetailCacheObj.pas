unit ClientDetailCacheObj;
//------------------------------------------------------------------------------
{
   Title:

   Description:  Caches the clients contact details in ini files
                 Files are held in the CDCACHE directory and stored in
                 sub folders ala the archive


   Author:       Matthew Hopkins  Apr 2003

   Remarks:      borrowed from code by Steve Agnew

}
//------------------------------------------------------------------------------

interface
uses
  Classes;

type
  TClientDetailsCache = class
  private
    FLastLRN : integer;
    FLastEditDate : integer;
    FAddress_L1: string;
    FName: string;
    FAddress_L2: string;
    FContact_Name: string;
    FPhone_No: string;
    FMobile_No: string;
    FAddress_L3: string;
    FEmail_Address: string;
    FFax_No: string;
    FCode: string;
    FSalutation: string;
    procedure SetAddress_L1(const Value: string);
    procedure SetAddress_L2(const Value: string);
    procedure SetAddress_L3(const Value: string);
    procedure SetContact_Name(const Value: string);
    procedure SetEmail_Address(const Value: string);
    procedure SetFax_No(const Value: string);
    procedure SetName(const Value: string);
    procedure SetPhone_No(const Value: string);
    procedure SetMobile_No(const Value: string);
    procedure SetCode(const Value: string);
    procedure SetSalutation(const Value: string);
  public
    property Code : string read FCode write SetCode;
    property Name : string read FName write SetName;
    property Address_L1 : string read FAddress_L1 write SetAddress_L1;
    property Address_L2 : string read FAddress_L2 write SetAddress_L2;
    property Address_L3 : string read FAddress_L3 write SetAddress_L3;
    property Contact_Name : string read FContact_Name write SetContact_Name;
    property Phone_No : string read FPhone_No write SetPhone_No;
    property Mobile_No : string read FMobile_No write SetMobile_No;
    property Fax_No : string read FFax_No write SetFax_No;
    property Email_Address : string read FEmail_Address write SetEmail_Address;
    property LastEditDate : integer read FLastEditDate;
    property Salutation : string read FSalutation write SetSalutation;

    procedure Clear;
    function Load( const cLRN : integer) : Boolean;
    procedure Save( const cLRN : integer);
    function CacheExists( const cLRN : integer) : Boolean;

    constructor Create;
    destructor Destroy; override;
  end;

  function ClientDetailsCache : TClientDetailsCache;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
uses
  LockUtils, sysUtils, Globals, IniFiles, DirUtils, stDate, WinUtils;

var
  FClientDetailsCache : TClientDetailsCache;


function ClientDetailsCache : TClientDetailsCache;
begin
  if not Assigned( FClientDetailsCache) then
    FClientDetailsCache := TClientDetailsCache.Create;

  result := FClientDetailsCache;
end;

{ TClientDetailsCache }

function TClientDetailsCache.CacheExists(const cLRN: integer): Boolean;
var
  Filename : string;
begin
  Filename := GetClientDetailsCacheFilename( cLRN);
  LockUtils.ObtainLock( ltClientDetailsCache, cLRN, Globals.PRACINI_TicksToWaitForAdmin div 1000);
  try
    result := BKFileExists( Filename);
  finally
    ReleaseLock( ltClientDetailsCache, cLRN);
  end;
end;

procedure TClientDetailsCache.Clear;
begin
  FLastLRN       := -1;
  FLastEditDate  := 0;
  FAddress_L1    := '';
  FName          := '';
  FAddress_L2    := '';
  FContact_Name  := '';
  FPhone_No      := '';
  FMobile_No     := '';
  FAddress_L3    := '';
  FEmail_Address := '';
  FFax_No        := '';
  FCode          := '';
  FSalutation    := '';
end;

constructor TClientDetailsCache.Create;
begin
  inherited;
  Self.Clear;
end;

destructor TClientDetailsCache.Destroy;
begin
  inherited;
end;

function TClientDetailsCache.Load(const cLRN: integer) : boolean;
//returns true if the cached record was found
var
  filename : string;
  CacheFile : TMemIniFile;
begin
  Result := true;
  if ( cLRN <> FLastLRN) then
  begin
    Self.Clear;
    Filename := GetClientDetailsCacheFilename( cLRN);
    LockUtils.ObtainLock( ltClientDetailsCache, cLRN, Globals.PRACINI_TicksToWaitForAdmin div 1000);
    try
      if BKFileExists( Filename) then
      begin
        CacheFile := TMemIniFile.Create( Filename);
        try
          FCode          := CacheFile.ReadString( 'Details',  'Code'     , '');        
          FName          := CacheFile.ReadString( 'Details',  'Name'     , '');
          FContact_Name  := CacheFile.ReadString( 'Details',  'Contact'  , '');
          FAddress_L1    := CacheFile.ReadString( 'Details',  'Address1' ,'');
          FAddress_L2    := CacheFile.ReadString( 'Details',  'Address2' ,'');
          FAddress_L3    := CacheFile.ReadString( 'Details',  'Address3' ,'');
          FPhone_No      := CacheFile.ReadString( 'Details',  'Phone'    ,'');
          FMobile_No     := CacheFile.ReadString( 'Details',  'Mobile'   ,'');
          FEmail_Address := CacheFile.ReadString( 'Details',  'Email'    ,'');
          FFax_No        := CacheFile.ReadString( 'Details',  'Fax'      ,'');
          FLastEditDate  := CacheFile.ReadInteger('Details',  'LastEdited', 0);
          FSalutation    := CacheFile.ReadString( 'Details',  'Salutation','');
        finally
          CacheFile.Free;
        end;
      end
      else
        //no record found
        result := false;
    finally
      LockUtils.ReleaseLock( ltClientDetailsCache, cLRN);
    end;
    FLastLRN := cLRN;
  end;
end;

procedure TClientDetailsCache.Save(const cLRN: integer);
var
  filename : string;
  CacheFile : TMemIniFile;
begin
  Filename := GetClientDetailsCacheFilename( cLRN);
  LockUtils.ObtainLock( ltClientDetailsCache, cLRN, Globals.PRACINI_TicksToWaitForAdmin div 1000);
  try
    CacheFile := TMemIniFile.Create( Filename);
    try
      FLastEditDate := StDate.CurrentDate;
      CacheFile.WriteString( 'Details',  'Code'     ,FCode);
      CacheFile.WriteString( 'Details',  'Name'     ,FName);
      CacheFile.WriteString( 'Details',  'Contact'  ,FContact_Name);
      CacheFile.WriteString( 'Details',  'Address1' ,FAddress_L1);
      CacheFile.WriteString( 'Details',  'Address2' ,FAddress_L2);
      CacheFile.WriteString( 'Details',  'Address3' ,FAddress_L3);
      CacheFile.WriteString( 'Details',  'Phone'    ,FPhone_No);
      CacheFile.WriteString( 'Details',  'Mobile'   ,FMobile_No);
      CacheFile.WriteString( 'Details',  'Email'    ,FEmail_Address);
      CacheFile.WriteString( 'Details',  'Fax'      ,FFax_No);
      CacheFile.WriteInteger( 'Details',  'LastEdit', FLastEditDate);
      CacheFile.WriteString( 'Details',  'Salutation', FSalutation);
    finally
      CacheFile.UpdateFile;
      CacheFile.Free;
    end;
  finally
    LockUtils.ReleaseLock( ltClientDetailsCache, cLRN);
  end;
end;

procedure TClientDetailsCache.SetAddress_L1(const Value: string);
begin
  FAddress_L1 := Value;
end;

procedure TClientDetailsCache.SetAddress_L2(const Value: string);
begin
  FAddress_L2 := Value;
end;

procedure TClientDetailsCache.SetAddress_L3(const Value: string);
begin
  FAddress_L3 := Value;
end;

procedure TClientDetailsCache.SetCode(const Value: string);
begin
  FCode := Value;
end;

procedure TClientDetailsCache.SetContact_Name(const Value: string);
begin
  FContact_Name := Value;
end;

procedure TClientDetailsCache.SetEmail_Address(const Value: string);
begin
  FEmail_Address := Value;
end;

procedure TClientDetailsCache.SetFax_No(const Value: string);
begin
  FFax_No := Value;
end;

procedure TClientDetailsCache.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TClientDetailsCache.SetPhone_No(const Value: string);
begin
  FPhone_No := Value;
end;

procedure TClientDetailsCache.SetMobile_No(const Value: string);
begin
  FMobile_No := Value;
end;

procedure TClientDetailsCache.SetSalutation(const Value: string);
begin
  FSalutation := Value;
end;

initialization
  FClientDetailsCache := nil;
finalization
  FClientDetailsCache.Free;

end.
