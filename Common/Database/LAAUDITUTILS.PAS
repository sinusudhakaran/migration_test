unit LAAuditUtils;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.


interface

uses
  MoneyDef;

type

  TChanged_Fields_Array = MoneyDef.TChanged_Fields_Array;

 function Changed_Fields_Changed(const V1, V2: TChanged_Fields_Array; var V3: TChanged_Fields_Array): boolean;

implementation


function Changed_Fields_Changed(const V1, V2: TChanged_Fields_Array; var V3: TChanged_Fields_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

end.
