unit SQLHelpers;


interface
uses MoneyDef;

function ToSQL(Value: TGuid; addSep: Boolean = true): string; overload;
function ToSQL(Value: Money; addSep: Boolean = true): string; overload;
function QtyToSQL(Value: Money; addSep: Boolean = true): string; overload;
function PercentToSQL(Value: Money; addSep: Boolean = true): string; overload;
function ToSQL (Value: Integer; addSep: Boolean = true):string; overload;
function DateToSQL(Value: Integer; addSep: Boolean = true):string;
function ToSQL(Value: Boolean; addSep: Boolean = true):string; overload;
function ToSQL(Value: string; addSep: Boolean = true):string; overload;

var emptyGuid : TGuid;

implementation

uses sysutils,  StDateSt;

// These functions are more SQL specific..
const sep = ',';



function ToSQL(Value: TGuid; addSep: Boolean = true): string; overload;
// The default one has  "{}"
begin
  if IsEqualGUID(Value,emptyGuid) then
     Result := 'null'
  else

     Result := format('''%.8x-%.4x-%.4x-%.2x%.2x-%.2x%.2x%.2x%.2x%.2x%.2x''',[Value.D1,Value.D2,Value.D3,
      Value.D4[0],Value.D4[1],Value.D4[2],Value.D4[3],Value.D4[4],Value.D4[5],Value.D4[6],Value.D4[7]]);

  if Addsep then
      Result := result + sep;
end;

function ToSQL(Value: Money; addSep: Boolean = true): string; overload;
/// carefull, may need differnt for QTY or other 4dp
begin
   if Value=Unknown then
       Result:='null'
   else
       Result:=Format('%0.2f',[Value/100]);

   if Addsep then
      Result := result + sep;
end;

function QtyToSQL(Value: Money; addSep: Boolean = true): string;
/// carefull, may need differnt for QTY or other 4dp
begin
   if Value=Unknown then
       Result:='null'
   else
       Result:=Format('%0.4f',[Value/10000]);

   if Addsep then
      Result := result + sep;
end;

function PercentToSQL(Value: Money; addSep: Boolean = true): string;
/// carefull, may need differnt for QTY or other 4dp
begin
   if Value=Unknown then
       Result:='null'
   else
       Result:=Format('%0.4f',[Value/10000]);

   if Addsep then
      Result := result + sep;
end;

function DateToSQL(Value: Integer; addSep: Boolean = true):string;
begin
   if Value <= 0 then
      Result := 'null' { Bad date or null date }
   else if value = maxint then
      result := 'null' // clould make a 'maxdate'
   else
      Result := StDateSt.StDateToDateString( '''yyyy-mm-dd''', Value, False );

   if Addsep then
      Result := result + sep;
end;

function ToSQL(Value: Boolean; addSep: Boolean = true):string; overload;
begin
   if Value then
      Result := '1'
   else
      Result := '0';
   if Addsep then
      Result := Result + sep;
end;

function ToSQL(Value: string; addSep: Boolean = true):string; overload;
begin
   if Value = '' then
      Result := 'null'
   else
      Result := AnsiQuotedStr(Value, '''');
   if Addsep then
      result := result + sep;
end;

function ToSQL (Value: Integer; addSep: Boolean = true):string;
begin
   result := intToStr(Value);
   if Addsep then
      result := result + sep;
end;

initialization
  fillchar(emptyGuid,sizeof(emptyGuid),0);
end.
