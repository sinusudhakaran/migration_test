unit MigrateTable;



interface

uses
   Moneydef,
   DB,
   ADODB;

type
  TFieldNameList = array of string;
  TMigrateTable = class (TADOQuery)
  private
    FCount: Integer;
    FTablename: string;
    FDoSuperfund: Boolean;
    procedure SetTablename(const Value: string);
    procedure SetDoSuperfund(const Value: Boolean);
    procedure MakeQuery;
  protected
    procedure SetCount(const Value: Integer);


    procedure SetFields(FieldList: array of string; SFFieldList: array of string);
    procedure SetupTable; virtual; abstract;

  published
  public
    constructor Create(AConnection: TAdoConnection);
    function RunValues(values: array of Variant; SFValues: array of Variant):Boolean;
    property Count: Integer read FCount write SetCount;
    property Tablename: string read FTablename write SetTablename;
    property DoSuperfund: Boolean read FDoSuperfund write SetDoSuperfund default false;

    class function ToSQL(Value: TGuid): variant; overload; static;
    class function ToSQL(Value: Money): variant; overload; static;
    class function QtyToSQL(Value: Money): variant;overload;  static;
    class function PercentToSQL(Value: Money): variant;overload;  static;
    class function ToSQL (Value: Integer):variant;overload;  static;
    class function DateToSQL(Value: Integer):variant;static;
    class function NullToSQL (Value: Integer):variant; static ;
    class function ToSQL(Value: Boolean):variant;overload;  static;
    class function ToSQL(Value: string):variant;overload;  static;
    class function ToSQL(Date: Integer; Time: Integer):variant;overload;  static;
    function GuidToText(Value: TGuid): string;
  end;

var emptyGuid : TGuid;

const SFLineFields : array[0..31] of string = (
{1}   'SFEdited', 'SFFranked', 'SFUnFranked',

{2}   'SFMemberID','SFFundID', 'SFFundCode',

{3}   'SFTransactionID', 'SFTransactionCode', 'SFMemberAccountID', 'SFMemberAccountCode', 'SFLedgerID',

{4}   'SFMemberComponent', 'SFOtherExpenses', 'SFInterest', 'SFRent', 'SFSpecialIncome', 'SFImputedCredit',

{5}   'SFTaxFreeDist', 'SFTaxExemptDist', 'SFTaxDeferredDist', 'SFTFNCredits', 'SFOtherTaxCredit', 'SFNonResidentTax',

{6}   'SFForeignIncome', 'SFForeignTaxCredits', 'SFCapitalGainsIndexed', 'SFCapitalGainsDisc',
{7}   'SFCapitalGainsOther', 'SFCapitalGainsForeignDisc','SFForeignCapitalGainsCredit',

{8}   'SFCGTDate',  'SFCapitalGainsFractionHalf');



implementation
uses
   stDate,
   Variants,
   SysUtils;

{ TMigateTable }

constructor TMigrateTable.Create(AConnection: TAdoConnection);
begin
  inherited Create(nil);
  Paramcheck := True;
  Connection := AConnection;

  MakeQuery;

  Count := 0;
end;

class  function TMigrateTable.DateToSQL(Value: Integer): variant;
begin
   if Value <= 0 then
      Result := Null // Bad date or null date
   else if value = maxint then
      result := Null // clould make a 'maxdate'
   else
      Result := StDate.StDateToDateTime(Value);
end;

function TMigrateTable.GuidToText(Value: TGuid): string;
begin
 if IsEqualGUID(Value,emptyGuid) then
     Result := 'Null'
  else
     Result := GuidTostring(Value);
end;

procedure TMigrateTable.MakeQuery;
begin

   SetupTable;

   Prepared := true;
end;

class function TMigrateTable.NullToSQL(Value: Integer): variant;
begin
  if value = 0 then
     Result := Null
  else
     Result := Value;
end;


class function TMigrateTable.PercentToSQL(Value: Money): variant;
begin
   if Value=Unknown then
       Result:= Null
   else
       Result:= Value/10000;
end;

class function TMigrateTable.QtyToSQL(Value: Money): variant;
begin
    if Value=Unknown then
       Result:= Null
   else
       Result:= Value/10000;
end;

procedure TMigrateTable.SetCount(const Value: Integer);
begin
  FCount := Value;
end;

procedure TMigrateTable.SetDoSuperfund(const Value: Boolean);
begin
   if  FDoSuperfund <> Value then begin
       FDoSuperfund := Value;
       MakeQuery;
   end;
end;

procedure TMigrateTable.SetFields(FieldList: array of string; SFFieldList: array of string);
var
   Fields, values: string;
   I: Integer;

   procedure TestField (name: string);
   begin
      try
      SQL.Text := format('SELECT [%s] FROM [%s]', [name,TableName]);
      self.ExecSQL;
      except
         raise exception.Create(Format('Field %s not found in table %s',[name, TableName]));
      end;
   end;
begin
   // Build The Field and Vlaue list
  Fields := Format('[%s]',[FieldList[0]]);
  Values := Format(':%s',[FieldList[0]]);
  for I := Low(FieldList) + 1 to High(FieldList) do begin
     TestField( FieldList[I]);
     Fields := Fields + Format(',[%s]',[FieldList[I]]);
     Values := Values + Format(',:%s',[FieldList[I]]);
  end;

  for I := Low(SFFieldList) to High(SFFieldList) do
     TestField( SFFieldList[I]);

  if FDoSuperfund then // add the super fields
     for I := Low(SFFieldList) to High(SFFieldList) do begin
        TestField( SFFieldList[I]);
        Fields := Fields + Format(',[%s]',[SFFieldList[I]]);
        Values := Values + Format(',:%s',[SFFieldList[I]]);
     end;

  // Make the query
  SQL.Text := Format('Insert into [%s] (%s) Values (%s)',[TableName,Fields,Values]);
  self.Prepared := true;
end;

procedure TMigrateTable.SetTablename(const Value: string);
begin
  FTablename := Value;
end;


class function TMigrateTable.ToSQL(Date, Time: Integer): variant;
begin
   if Date <= 0 then
      Result := Null // Bad date or null date
   else if Date = maxint then
      Result := Null // clould make a 'maxdate'
   else
      Result := StDate.StDateToDateTime(Date) + StDate.StTimeToDateTime(Time);
end;

function TMigrateTable.RunValues(values: array of Variant; SFValues: array of Variant):Boolean;
var I,S: Integer;
   procedure SetParam(Index: Integer; value: variant);
   begin
      try
         Parameters[Index].Value := Value;
      except
         on e: exception do begin
            raise exception.Create(Format('Error : <%s> with %s in table %s',[e.Message,Parameters[Index].Name, TableName]));
         end;
      end;
   end;
begin
   result := False;

   if High(values) >= Parameters.Count then
      raise exception.Create(Format('Too many values for table %s',[TableName]) );

   for I := low(Values) to High(Values) do
      SetParam(I, Values[I]);

   if FDoSuperfund then begin
      S :=  High(Values) + 1; // Could use I, but tecnically undetermined...
      if S + High(SFValues) >= Parameters.Count then
          raise exception.Create(Format('Too many values for table %s',[TableName]));

      for I := low(SFValues) to High(SFValues) do
        SetParam(S + I, SFValues[I]);
   end;
   

   // Run the query
   try
      Result := ExecSQL = 1;
   except
      on e: exception do begin
         raise exception.Create(Format('Error : %s in table %s',[e.Message,TableName]));
      end;
   end;
end;

class function TMigrateTable.ToSQL(Value: Money): variant;
begin
   if Value = Unknown then
       Result:= Null
   else
       Result:= Value/100;
end;

class function TMigrateTable.ToSQL(Value: TGuid): variant;
begin
  if IsEqualGUID(Value,emptyGuid) then
     Result := Null
  else
     Result := GuidTostring(Value);

end;

class function TMigrateTable.ToSQL(Value: string): variant;
var ls: string;
begin
   ls := trim(value);
   if ls = '' then
      Result := Null
   else
      Result := ls;
end;

class function TMigrateTable.ToSQL(Value: Boolean): variant;
begin
   Result := Value;
end;

class function TMigrateTable.ToSQL(Value: Integer): variant; 
begin
   Result := Value;
end;


initialization
  fillchar(emptyGuid,sizeof(emptyGuid),0);

end.
