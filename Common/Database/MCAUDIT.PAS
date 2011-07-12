unit MCAUDIT;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

interface

uses
  SysUtils;

type
TAuditTableArray = array[byte] of string;
TAuditNamesArray = array[byte, byte] of string;

TMCAuditNames = class(TObject)
private
  FAuditNamesArray: TAuditNamesArray;
  FAuditTableArray: TAuditTableArray;
  procedure FillArray;
public
  constructor Create;
  function GetAuditTableName(ATable: byte): string;
  function GetAuditFieldName(ATable, AField: byte): string;
end;

function MCAuditNames: TMCAuditNames;

implementation

var
  _AuditNames: TMCAuditNames;

function MCAuditNames: TMCAuditNames;
begin
  if not Assigned(_AuditNames) then
    _AuditNames := TMCAuditNames.Create;
  Result := _AuditNames;
end;

{ TAuditNames }

constructor TMCAuditNames.Create;
begin
  FillArray;
end;

function TMCAuditNames.GetAuditFieldName(ATable, AField: byte): string;
begin
  Result := FAuditNamesArray[ATable, AField];
end;

function TMCAuditNames.GetAuditTableName(ATable: byte): string;
begin
  Result := FAuditTableArray[ATable];
end;

procedure TMCAuditNames.FillArray;
var
  i, j: integer;
begin
  //Clear arrays
  for i := 0 to High(FAuditNamesArray) do begin
    FAuditTableArray[i] := '';
    for j := 0 to High(FAuditNamesArray[i]) do
      FAuditNamesArray[i, j] := '';
  end;
   FAuditTableArray[10] := 'Exchange_Rates_Header';
    FAuditNamesArray[10,12] := 'File_Version';
    FAuditNamesArray[10,13] := 'LRN';
    FAuditNamesArray[10,14] := 'Name';
    FAuditNamesArray[10,15] := 'List_Type';
    FAuditNamesArray[10,16] := 'ISO_Codes';
    FAuditNamesArray[10,17] := 'Cur_Type';
    FAuditNamesArray[10,18] := 'Audit_Record_ID';

   FAuditTableArray[15] := 'Exchange_Rate';
    FAuditNamesArray[15,17] := 'Applies_Until';
    FAuditNamesArray[15,18] := 'Rate';
    FAuditNamesArray[15,19] := 'Locked';
    FAuditNamesArray[15,20] := 'Audit_Record_ID';

end;

initialization
  _AuditNames := nil;
finalization
  if Assigned(_AuditNames) then
    FreeAndNil(_AuditNames);
end.
