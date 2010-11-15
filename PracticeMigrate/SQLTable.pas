unit SQLTable;


interface

uses MoneyDef,Variants;

function ToSQL(Value: TGuid): variant; overload;
function ToSQL(Value: Money): variant; overload;
function QtyToSQL(Value: Money): variant; overload;
function PercentToSQL(Value: Money): variant; overload;
function ToSQL (Value: Integer):variant; overload;
function DateToSQL(Value: Integer):variant;
function ToSQL(Value: Boolean):variant; overload;
function ToSQL(Value: string):variant; overload;

var emptyGuid : TGuid;

implementation

uses sysutils,  StDate;

// These functions are more SQL specific..
const sep = ',';



function ToSQL(Value: TGuid): Variant; overload;
// The default one has  "{}"
begin
  if IsEqualGUID(Value,emptyGuid) then
     Result := Null
  else
     //Result := format('{%.8x-%.4x-%.4x-%.2x%.2x-%.2x%.2x%.2x%.2x%.2x%.2x}',[Value.D1,Value.D2,Value.D3,
     //     Value.D4[0],Value.D4[1],Value.D4[2],Value.D4[3],Value.D4[4],Value.D4[5],Value.D4[6],Value.D4[7]]);
      Result := GuidToStrinG(value);

end;

function ToSQL(Value: Money): Variant; overload;
/// carefull, may need differnt for QTY or other 4dp
begin
   if Value=Unknown then
       Result:= Null
   else
       Result:=Value/100;

end;

function QtyToSQL(Value: Money): variant;
/// carefull, may need differnt for QTY or other 4dp
begin
   if Value=Unknown then
       Result:= Null
   else
       Result:=Value/10000;

end;

function PercentToSQL(Value: Money): variant;
/// carefull, may need differnt for QTY or other 4dp
begin
   if Value=Unknown then
       Result:= Null
   else
       Result:= Value/10000;


end;

function DateToSQL(Value: Integer): variant;
begin
   if Value <= 0 then
      Result := Null { Bad date or null date }
   else if value = maxint then
      result := Null // clould make a 'maxdate'
   else
      Result := StDate.StDateToDateTime(Value);

end;

function ToSQL(Value: Boolean): variant; overload;
begin
   Result := Value;
end;

function ToSQL(Value: string):Variant; overload;
begin
   if Value = '' then
      Result := Null
   else
      //Result := AnsiQuotedStr(Value, '''');
      Result := Value;

end;

function ToSQL (Value: Integer):Variant; overload;
begin
   result := Value;
end;

initialization
  fillchar(emptyGuid,sizeof(emptyGuid),0);
end.
