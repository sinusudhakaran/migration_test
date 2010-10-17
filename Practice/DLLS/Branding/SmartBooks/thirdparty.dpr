library thirdparty;
{
  Author - Matthew Hopkins    Aug 2010

  This dll holds third party images and settings for use by BankLink Practice/Books
  Images must be added into the same dir as the thirdpartyimgs.rc file

  The .rc contains the name of each image and its id
  i.e.

  BANNERLOGO BITMAP banner.bmp

}

{$R 'thirdpartyimgs.res' 'thirdpartyimgs.rc'}

uses
  SysUtils, Types;

{$R *.res}

const
  //id's for config elements
  cidDefaultUIStyle         =  1;
  cidThirdPartyID           =  2;
  cidDefaultAllowCheckOut   =  3;
  cidAllowEditingofContactDetails = 4;

  //id's for string elements
  cidVersion                = 100;   //config ID
  cidAppName                = 101;
  cidSupportName            = 102;
  cidSupportEmail           = 103;
  cidSupportPhone           = 104;
  cidThirdPartyName         = 105;
  cidSupportWebpage         = 106;

//-----------------------------------------------------------------------
function ConfigString( id : LongInt) : string;
//returns ? if invalid ID
//returns string for id if valid
begin
  case id of
    cidVersion       : result := '1.0.1.0';
    cidAppName       : result := '';
    cidSupportName   : result := 'SmartBooks';
    cidSupportEmail  : result := 'support@smartbooks.co.nz';
    cidSupportPhone  : result := '0800 10 10 38';
    cidThirdPartyName : result := 'SmartBooks';
    cidSupportWebPage : result := 'http:\\www.smartbooks.co.nz';
  else
    result := '?';
  end;
end;
//-----------------------------------------------------------------------
function GetConfigInt( id : LongInt): LongInt; stdcall;
begin
  case id of
    cidDefaultUIStyle       : result := 1;    //simple UI
    cidThirdPartyID         : result := 1000;
    cidDefaultAllowCheckOut : result := 2;   //Force OFF (0 = default off, 1 = default on, 2 = FORCE OFF);
    cidAllowEditingofContactDetails : result := 1;   //yes
  else
    result := -1;
  end;
end;
//-----------------------------------------------------------------------
function GetConfigString( id : LongInt; Buffer : PChar; BufferLen : DWord) : LongBool; stdCall;
//handled this way to make passing through dll easier
//if pass a pchar then dont have to worry about delphi mem manager addin
//returns false if invalid id
//returns true if value found
var
  s : string;
begin
  result := false;
  try
    s := ConfigString( id);
    if (s <> '?') and ((Length(s) + 2) <= Int(BufferLen)) then
    begin
      StrPCopy( Buffer, s);
      result := true;
    end;
  except
    On E : Exception do
      result := false;
  end;
end;
//-----------------------------------------------------------------------
function GetConfigStringLen( id : LongInt) : LongInt; stdCall;
//returns -1 if invalid id
//returns 0 if no value set for id
var
  s : string;
begin
  result := -1;
  s := ConfigString( id);
  if s <> '?' then
    result := Length(s) + 2;
end;

//-----------------------------------------------------------------------

exports
   GetConfigInt,
   GetConfigStringLen,
   GetConfigString;
end.


