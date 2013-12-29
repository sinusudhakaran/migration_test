unit CSAUDIT;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

interface

uses
  SysUtils;

type
TAuditTableArray = array[byte] of string;
TAuditNamesArray = array[byte, byte] of string;

TCSAuditNames = class(TObject)
private
  FAuditNamesArray: TAuditNamesArray;
  FAuditTableArray: TAuditTableArray;
  procedure FillArray;
public
  constructor Create;
  function GetAuditTableName(ATable: byte): string;
  function GetAuditFieldName(ATable, AField: byte): string;
end;

function CSAuditNames: TCSAuditNames;

implementation

var
  _AuditNames: TCSAuditNames;

function CSAuditNames: TCSAuditNames;
begin
  if not Assigned(_AuditNames) then
    _AuditNames := TCSAuditNames.Create;
  Result := _AuditNames;
end;

{ TAuditNames }

constructor TCSAuditNames.Create;
begin
  FillArray;
end;

function TCSAuditNames.GetAuditFieldName(ATable, AField: byte): string;
begin
  Result := FAuditNamesArray[ATable, AField];
end;

function TCSAuditNames.GetAuditTableName(ATable: byte): string;
begin
  Result := FAuditTableArray[ATable];
end;

procedure TCSAuditNames.FillArray;
var
  i, j: integer;
begin
  //Clear arrays
  for i := 0 to High(FAuditNamesArray) do begin
    FAuditTableArray[i] := '';
    for j := 0 to High(FAuditNamesArray[i]) do
      FAuditNamesArray[i, j] := '';
  end;
   FAuditTableArray[20] := 'Coding_Stat_Fields';
    FAuditNamesArray[20,22] := 'File_Version';
    FAuditNamesArray[20,23] := 'Read_Version';

   FAuditTableArray[10] := 'Coding_Statistics';
    FAuditNamesArray[10,12] := 'Client_LRN';
    FAuditNamesArray[10,13] := 'Month';
    FAuditNamesArray[10,14] := 'Updated';
    FAuditNamesArray[10,15] := 'Memorization_Count';
    FAuditNamesArray[10,16] := 'Analysis_Count';
    FAuditNamesArray[10,17] := 'Payee_Count';
    FAuditNamesArray[10,18] := 'Manual_Count';
    FAuditNamesArray[10,19] := 'Uncoded_Count';
    FAuditNamesArray[10,20] := 'Master_Mem_Count';
    FAuditNamesArray[10,21] := 'Man_Super_Count';
    FAuditNamesArray[10,22] := 'Notes_Count';
    FAuditNamesArray[10,23] := 'Client_Files_Sent';
    FAuditNamesArray[10,24] := 'Client_Files_Received';

end;

initialization
  _AuditNames := nil;
finalization
  if Assigned(_AuditNames) then
    FreeAndNil(_AuditNames);
end.
