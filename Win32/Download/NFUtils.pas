unit NFUtils;
//------------------------------------------------------------------------------
{
   Title:       New Disk Format utilities

   Description: Constants used to create disks in new format

   Remarks:

   Author:      Piotr 14/08/2002
}
//------------------------------------------------------------------------------

interface

const
  NFFileType = 'NFBankLink';
  NFDataStr = 'Data';
  NFUpdateStr = 'Update';
  NFVersion = '2.3.0';
  NFExpFields = 'F14A17E17T4X5';
  NFCountryNZ = 'NZ';
  NFCountryAU = 'AU';
  NFCountryUK = 'UK';


type
  NewDiskIDRec = Packed Record  // Written at start of Compressed Data Disk Image.
    nidFileType        : Array[1..10] of char;  { always 'NFBankLink' }
    nidFileSubType     : Array[1..8] of char;   { currently: 'Data' or 'Update' }
    nidCountryID       : Array[1..2] of char;   { 'AU' or 'NZ' }
    nidVersion         : Array[1..10] of char;  { starts from: '2.0.0' }
    nidFileName        : Array[1..30] of char;  { this file name (what was this file name when it was created) }
    nidFloppyDesc      : Array[1..12] of char;  { short version of file name (serial No) }
    nidFileDate        : Array[1..8] of char;   { dd/mm/yy }
    nidFromDate        : Array[1..8] of char;   { dd/mm/yy (date of first transaction) }
    nidToDate          : Array[1..8] of char;   { dd/mm/yy (date of last transaction) }
    nidClientCode      : Array[1..20] of char;  { currently only 8 characters are used, longer codes will be possible after disabling old format }
    nidClientName      : Array[1..200] of char; { only 40 characters are used by old production }
    nidThisDiskNumber  : LongInt;
    nidSequenceInSet   : Integer;
    nidNoOfDisksInSet  : Integer;
    nidCRC             : LongInt;               { calculated as in old format}
    nidSpare           : Array[1..300] of char;
  end;

function filterBar(const inp: string): string;

//******************************************************************************
implementation

uses SysUtils;

function filterBar(const inp: string): string;
// replace unwanted characters with spaces
var
  i: integer;
begin
  result:='';
  for i:=1 to length(inp) do
    if (inp[i]<' ') or (inp[i]='|') or (inp[i]>#$7F) then
      result:=result+' '
    else
      result:=result+inp[i];
  result:=Trim(result);
end;
//------------------------------------------------------------------------------

end.
