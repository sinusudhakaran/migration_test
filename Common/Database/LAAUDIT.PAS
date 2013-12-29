unit LAAUDIT;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

interface

uses
  SysUtils;

type
TAuditTableArray = array[byte] of string;
TAuditNamesArray = array[byte, byte] of string;

TLAAuditNames = class(TObject)
private
  FAuditNamesArray: TAuditNamesArray;
  FAuditTableArray: TAuditTableArray;
  procedure FillArray;
public
  constructor Create;
  function GetAuditTableName(ATable: byte): string;
  function GetAuditFieldName(ATable, AField: byte): string;
end;

function LAAuditNames: TLAAuditNames;

implementation

var
  _AuditNames: TLAAuditNames;

function LAAuditNames: TLAAuditNames;
begin
  if not Assigned(_AuditNames) then
    _AuditNames := TLAAuditNames.Create;
  Result := _AuditNames;
end;

{ TAuditNames }

constructor TLAAuditNames.Create;
begin
  FillArray;
end;

function TLAAuditNames.GetAuditFieldName(ATable, AField: byte): string;
begin
  Result := FAuditNamesArray[ATable, AField];
end;

function TLAAuditNames.GetAuditTableName(ATable: byte): string;
begin
  Result := FAuditTableArray[ATable];
end;

procedure TLAAuditNames.FillArray;
var
  i, j: integer;
begin
  //Clear arrays
  for i := 0 to High(FAuditNamesArray) do begin
    FAuditTableArray[i] := '';
    for j := 0 to High(FAuditNamesArray[i]) do
      FAuditNamesArray[i, j] := '';
  end;
   FAuditTableArray[40] := 'Printer';
    FAuditNamesArray[40,42] := 'Printer_Name';
    FAuditNamesArray[40,43] := 'Printer_Model_Name';
    FAuditNamesArray[40,44] := 'Library_File_Name';
    FAuditNamesArray[40,45] := 'Connection_Type';
    FAuditNamesArray[40,46] := 'Queue_Name';
    FAuditNamesArray[40,47] := '  ** Used for Report Setting Link **'; //LRN

   FAuditTableArray[60] := 'Form';
    FAuditNamesArray[60,62] := 'Form_Number';
    FAuditNamesArray[60,63] := 'Description';
    FAuditNamesArray[60,64] := 'Page_Type';
    FAuditNamesArray[60,65] := 'Page_Length';
    FAuditNamesArray[60,66] := 'Page_Width';
    FAuditNamesArray[60,67] := 'Left_Margin';
    FAuditNamesArray[60,68] := 'Right_Margin';
    FAuditNamesArray[60,69] := 'Top_Margin';
    FAuditNamesArray[60,70] := 'Bottom_Margin';
    FAuditNamesArray[60,71] := 'Windows_Form_Type';

   FAuditTableArray[80] := 'Report_Setting';
    FAuditNamesArray[80,82] := 'Report_Name';
    FAuditNamesArray[80,83] := 'Printer';
    FAuditNamesArray[80,84] := 'Form_Number';
    FAuditNamesArray[80,85] := 'Location';
    FAuditNamesArray[80,86] := 'Orientation';
    FAuditNamesArray[80,87] := 'Typeface';
    FAuditNamesArray[80,88] := 'Font';
    FAuditNamesArray[80,89] := 'Font_Size';
    FAuditNamesArray[80,90] := 'Style';
    FAuditNamesArray[80,91] := 'CPI';
    FAuditNamesArray[80,92] := 'LPI';
    FAuditNamesArray[80,93] := 'Number_of_Copies';

   FAuditTableArray[80] := 'Windows_Report_Setting';
    FAuditNamesArray[80,82] := 'Report_Name';
    FAuditNamesArray[80,83] := 'Printer_Name';
    FAuditNamesArray[80,84] := 'Paper';
    FAuditNamesArray[80,85] := 'Bin';
    FAuditNamesArray[80,86] := 'Orientation';
    FAuditNamesArray[80,87] := 'Base_Font_Name';
    FAuditNamesArray[80,88] := 'Base_Font_Style';
    FAuditNamesArray[80,89] := 'Base_Font_Size';
    FAuditNamesArray[80,90] := 'Top_Margin';
    FAuditNamesArray[80,91] := 'Left_Margin';
    FAuditNamesArray[80,92] := 'Bottom_Margin';
    FAuditNamesArray[80,93] := 'Right_Margin';
    FAuditNamesArray[80,94] := 'Format_Style';

end;

initialization
  _AuditNames := nil;
finalization
  if Assigned(_AuditNames) then
    FreeAndNil(_AuditNames);
end.
