unit ThirdPartyHelper;
//------------------------------------------------------------------------------
{
   Title:         Third Party Helper

   Description:   Handles third party customisation if a thirdparty branding DLL
                  is detected

   Author:        Matthew Hopkins  Aug 2010

   Remarks:       Handles loading of DLL
                  Holds custom images

   Revisions:

}
//------------------------------------------------------------------------------

interface
uses
  Graphics, Windows, Classes, dxGDIPlusClasses;

procedure CheckForThirdPartyDLL;
procedure FreeThirdPartyObjects;
function ThirdPartyBannerLogo : TPicture;
function ThirdPartyAboutLogo : TPicture;
function ThirdPartyCodingLogo : TPicture;

var
  ThirdPartyDLLDetected : boolean;
  ThirdPartyName        : string;
  DefaultUIStyle        : integer;
  AllowCheckOut         : integer;
  ThirdPartyID          : integer;
  ThirdPartySupportName : string;
  ThirdPartySupportEmail : string;
  ThirdPartySupportPhone : string;
  ThirdPartySupportWebsite : string;
  AllowEditingOfCustomContactDetails : boolean;

//---------------------------------------------------------------------
implementation
uses
  ExtCtrls, SysUtils;

type
  TIntFunction = function ( id : LongInt): LongInt; stdcall;
  TGetConfigStrLen = function ( id : LongInt) : LongInt; stdcall;
  TGetConfigStr = function ( id : LongInt; Buffer : PChar; BufferLen : DWord) : LongBool; stdcall;

var
  BannerHolder : TImage;
  CodingBannerHolder : TImage;
  AboutHolder : TImage;

const
  ThirdPartyDLLName = 'thirdparty.dll';  //must be in same dir as exe

//----------------------------------------------------------------
//   THESE IDS MUST MATCH THE ONES IN THIRDPARTY.DPR (the DLL)
//----------------------------------------------------------------
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
//----------------------------------------------------------------
//   THESE IDS MUST MATCH THE ONES IN THIRDPARTY.DPR (the DLL)
//----------------------------------------------------------------



//------------------------------------------------------------------------------
procedure CheckForThirdPartyDLL;
//mh: checks for the presence of the file and then loads all of the customisable
//    settings from it.
var
  LibHandle : THandle;
  ResStream: TResourceStream;
  PNGImage: TdxPNGImage;
  GetConfigInt :  TIntFunction;
  GetConfigStrLen : TGetConfigStrLen;
  GetConfigStr : TGetConfigStr;
  LoadBitmap: boolean;

  function GetThirdPartyConfigStr( id : LongInt) : string;
  var
    s : string;
    BufferLen : LongInt;
  begin
    result := '';
    try
      //get length
      BufferLen := GetConfigStrLen( id);
      //-1 indicates an invalid string, 2  indicates an empty string
      if BufferLen > 2 then begin
        SetLength( s, BufferLen);
        if GetConfigStr( id, PChar(s), BufferLen) then
          result := s;
      end;
    except
      on e : Exception do ;
    end;
  end;

  function GetThirdPartyConfigInt( id : integer) : integer;
  //will return -1 if invalid
  begin
    result := GetConfigInt( id);
  end;

begin
  //load dll if can
  LibHandle := LoadLibrary( PANSIChar(ThirdPartyDLLName));

  try
    if LibHandle <> 0 then begin
      //load the functions
      @GetConfigInt := GetProcAddress(LibHandle, 'GetConfigInt');
      @GetConfigStrLen := GetProcAddress(LibHandle, 'GetConfigStringLen');
      @GetConfigStr := GetProcAddress(LibHandle, 'GetConfigString');
      if (@GetConfigInt <> nil) and (@GetConfigStrLen <> nil) and (@GetConfigStr <> nil) then
      begin
        //------------------------------------------------------
        //all function successfully loaded, now read settings
        //------------------------------------------------------
        //load banner image
        LoadBitmap := false;
        BannerHolder := TImage.Create( nil);
        try
          ResStream := TResourceStream.Create(LibHandle, 'BANNERLOGOPNG', RT_RCDATA);

          try
            PNGImage := TdxPNGImage.Create;
            PNGImage.LoadFromStream(ResStream);
            BannerHolder.Picture.Graphic := PNGImage;
          finally
            FreeAndNil(ResStream);
          end;
        except
          on E : EResNotFound do
          begin
            LoadBitmap := true;
          end;
        end;
        if LoadBitmap then
        begin
          try
            BannerHolder.Picture.Bitmap.LoadFromResourceName( LibHandle, 'BANNERLOGO');
          except
            FreeAndNil( BannerHolder);
          end;
        end;

        //load coding banner image
        {
        CodingBannerHolder := TImage.Create( nil);
        try
          CodingBannerHolder.Picture.Bitmap.LoadFromResourceName( LibHandle, 'CODINGLOGO');
        except
          FreeAndNil( CodingBannerHolder);
        end;
        }

        //load about image
        AboutHolder := TImage.Create( nil);
        try
          AboutHolder.Picture.Bitmap.LoadFromResourceName( LibHandle, 'ABOUTLOGO');
        except
          FreeAndNil( AboutHolder);
        end;

        //load custom setting strings
        ThirdPartyName := GetThirdPartyConfigStr( cidThirdPartyName);
        ThirdPartySupportName := GetThirdPartyConfigStr( cidSupportName);
        ThirdPartySupportEmail := GetThirdPartyConfigStr( cidSupportEmail);
        ThirdPartySupportPhone := GetThirdPartyConfigStr( cidSupportPhone);
        ThirdPartySupportWebsite := GetThirdPartyConfigStr( cidSupportWebpage);

        //load custom setting ints
        DefaultUIStyle := GetThirdPartyConfigInt( cidDefaultUIStyle);
        ThirdPartyID   := GetThirdPartyConfigInt( cidThirdPartyID);
        AllowCheckOut  := GetThirdPartyConfigInt( cidDefaultAllowCheckOut);
        AllowEditingOfCustomContactDetails := GetThirdPartyConfigInt( cidAllowEditingofContactDetails) = 1;
        ThirdPartyDllDetected := true;
      end;
    end;
  finally
    FreeLibrary(LibHandle);
  end;
end;

function ThirdPartyBannerLogo : TPicture;
begin
  if Assigned( BannerHolder) then
    result := BannerHolder.Picture
  else
    result := nil;
end;

function ThirdPartyCodingLogo : TPicture;
begin
  if Assigned( CodingBannerHolder) then
    result := CodingBannerHolder.Picture
  else
    result := nil;
end;

function ThirdPartyAboutLogo : TPicture;
begin
  if Assigned( AboutHolder) then
    result := AboutHolder.Picture
  else
    result := nil;
end;

procedure FreeThirdPartyObjects;
begin
   FreeAndNil( BannerHolder);
   FreeAndNil( CodingBannerHolder);
   FreeAndNil( AboutHolder);
end;

initialization
   ThirdPartyDLLDetected := false;
   BannerHolder := nil;


end.
