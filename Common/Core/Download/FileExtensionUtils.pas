unit FileExtensionUtils;

interface

//Move these functions from DownloadUtils so they can be shared with BConnect
function MakeSuffix(Number: Integer) : string;
function SuffixToSequenceNo(Suffix : string) : integer;
function IsValidSuffix(Suffix: string): Boolean;
function CompareDiskExtensions(Ext1, Ext2: String): Integer;

const
  InvalidSuffixValue = 999999;  //used to indicate value is invalid, set high
                                //so if ever got set then no downloads could be
                                //done
  LastSequenceNumber = 35999;

implementation

uses
  SysUtils,
  Math;

const
  FS = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

//------------------------------------------------------------------------------
Function MakeSuffix( Number : Integer ): String;
{  Summary: Make a Suffix for a DiskNumber
   Parameters: Number - DiskNumber
   Returns: 001 - Z99, then 3600 - Z999
}
Var
   i        : Integer;
   c        : Integer;
Begin
   if Number<3600 then
   begin
     i := ( Number div 100 ) + 1;
     c := Number mod 100;
     result:=Format('%s%2.2d',[FS[i],c]);
   end
   else
     if Number<=LastSequenceNumber then
     begin
       i := ( Number div 1000 ) + 1;
       c := Number mod 1000;
       result:=Format('%s%3.3d',[FS[i],c]);
     end
     else
       raise Exception.Create('Fatal Error!!! End of available disk image extension range');
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SuffixToSequenceNo( Suffix : string) : integer;
//expects a 3 character suffix to convert to a integer
var
  l : integer;
  LastDigits : integer;
  FirstDigit : integer;
  Hundreds: Integer;
begin
  result := InvalidSuffixValue;

  l := length( Suffix);

  if l = 0 then   //empty
    result := 0
  else if l > 4 then //too long
    result := InvalidSuffixValue
  else if l < 3 then
  begin
    //should be able to convert to a number
    Result := StrToIntDef(Suffix, -1);
    if Result = -1 then
      Result := InvalidSuffixValue;
  end
  else  //l = 3 or 4
  begin
    //All characters after first must be numeric
    LastDigits := StrToIntDef(Copy( Suffix, 2, l - 1), -1);
    if LastDigits = -1 then    
    begin
      result := InvalidSuffixValue;
      exit;
    end;
    //LastDigits will now contain 0 - 100, the first character is a multiplier
    //0 - 9, A - Z where A = 10;
    FirstDigit := Pos( Copy( Suffix,1,1), FS);
    if FirstDigit = - 1 then
    begin
      result := InvalidSuffixValue;
      exit;
    end;
    FirstDigit := FirstDigit - 1;

    result := FirstDigit * Trunc(Power(10, l - 1)) + LastDigits;
    
    //Some 4 digit suffixes are invalid. i.e. between 1000-3599
    //since they can be represented as A00-Z99
    if l = 4 then
    begin
      Hundreds := result div 100;
      if Hundreds + 1 <= Length(FS) then
        result := InvalidSuffixValue;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsValidSuffix(Suffix: string): Boolean;
begin
  Result := SuffixToSequenceNo(Suffix) <> InvalidSuffixValue;
end;

function CompareDiskExtensions(Ext1, Ext2: String): Integer;
var
  DiskNo1: Integer;
  DiskNo2: Integer;
begin
  DiskNo1 := SuffixToSequenceNo(Ext1);
  DiskNo2 := SuffixToSequenceNo(Ext2);
  if DiskNo1 = DiskNo2 then
    Result := 0
  else if DiskNo1 < DiskNo2 then
    Result := -1
  else
    Result := 1;
end;

end.
