unit AuditUtils;

interface

type
  TStrArray = array[1..99] of string[60];
  TRatesArray = array[1..99] of array[1..5] of comp;

  function StringArrayChanged(A1, A2: TStrArray): boolean;
  function RatesArrayChanged(A1, A2: TRatesArray): boolean;


implementation

function StringArrayChanged(A1, A2: TStrArray): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(A1) to High(A2) do
    if A1[i] <> A2[i] then begin
      Result := True;
      Break;
    end;
end;

function RatesArrayChanged(A1, A2: TRatesArray): boolean;
var
  i, j: integer;
begin
  Result := False;
  for i := Low(A1) to High(A1) do
    for j := Low(A1[i]) to High(A1[i]) do
      if A1[i, j] <> A2[i, j] then begin
        Result := True;
        Break;
      end;
end;

end.
