unit MCAuditUtils;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.


interface

uses
  MoneyDef;

type

  TChanged_Fields_Array = MoneyDef.TChanged_Fields_Array;
  TISO_Codes_Array = Array[ 1..99 ] of String[ 3 ];
  TCur_Type_Array = Array[ 1..99 ] of Byte;
  TRate_Array = Array[ 1..99 ] of Double;

 function ISO_Codes_Changed(const V1, V2: TISO_Codes_Array; var V3: TISO_Codes_Array): boolean;
 function Cur_Type_Changed(const V1, V2: TCur_Type_Array; var V3: TCur_Type_Array): boolean;
 function Rate_Changed(const V1, V2: TRate_Array; var V3: TRate_Array): boolean;
 function Changed_Fields_Changed(const V1, V2: TChanged_Fields_Array; var V3: TChanged_Fields_Array): boolean;

implementation

function ISO_Codes_Changed(const V1, V2: TISO_Codes_Array; var V3: TISO_Codes_Array): boolean;
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

function Cur_Type_Changed(const V1, V2: TCur_Type_Array; var V3: TCur_Type_Array): boolean;
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

function Rate_Changed(const V1, V2: TRate_Array; var V3: TRate_Array): boolean;
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
