unit MigrateTable;



interface

uses
   Moneydef,
   Classes,
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
    procedure TestField (name: string);

    procedure SetFields(FieldList: array of string; SFFieldList: array of string); virtual;
    procedure SetupTable; virtual; abstract;

  public
    constructor Create(AConnection: TAdoConnection);
    function RunValues(values: array of Variant; SFValues: array of Variant):Boolean;overload; virtual;
    property Count: Integer read FCount write SetCount;
    property Tablename: string read FTablename write SetTablename;
    property DoSuperfund: Boolean read FDoSuperfund write SetDoSuperfund default false;

    class function ToSQL(Value: TGuid): variant; overload; static;
    class function ToSQL(Value: Money): variant; overload; static;
    class function DateTimeToSQL(Value: TDateTime): variant; overload; static;
    class function QtyToSQL(Value: Money): variant;overload;  static;
    class function PercentToSQL(Value: Money): variant;overload;  static;
    class function ToSQL(Value: Integer):variant;overload;  static;
    class function DateToSQL(Value: Integer):variant;overload;static;
    class function NullToSQL(Value: Integer):variant;overload; static ;
    class function ToSQL(Value: Boolean):variant;overload;  static;
    class function ToSQL(Value: string):variant;overload;  static;
    class function ToSQL(Date: Integer; Time: Integer):variant;overload;  static;
    class function PWToSQL(Value: string):variant;overload;  static;

    class function CleanToSQL(Value: string): string;
    class function NewGuid : TGuid;

    function GuidToText(Value: TGuid): string;
  end;

  TBatchMigrateTable = class (TMigrateTable)
  private
    // Header: string;
    // TheFile: Text;
     baseSQL: string;
     theValues : TStringList;
  protected
     procedure SetFields(FieldList: array of string; SFFieldList: array of string); override;
     function RunTxtValues(values: array of Shortstring; SFValues: array of Shortstring):Boolean;overload;

  public
    procedure BeginBatch;
    procedure PostBatch;

    class function ToTxt(Value: TGuid): string; overload; static;
    class function ToTxt(Value: Money): string; overload; static;
    class function QtyToTxt(Value: Money): string;overload;  static;
    class function PercentToTxt(Value: Money): string;overload;  static;
    class function ToTxt (Value: Integer):string;overload;  static;
    class function DateToTxt(Value: Integer):string;overload;static;
    class function NullToTxt (Value: Integer):string;overload; static ;
    class function ToTxt(Value: Boolean):string;overload;  static;
    class function ToTxt(Value: string):string;overload;  static;
    class function ToTxt(Date, Time: Integer): string; overload; static;
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


const MigratorName = 'Migrator'; 

implementation
uses
OmniXMLUtils,
   Cryptutils,
   strUtils,
   stDate,
   StDateSt,
   Variants,
   SysUtils;

{ TMigateTable }

class function TMigrateTable.CleanToSQL(Value: string): string;
begin
   result := AnsiReplaceStr(Value,'''', '''''' );
end;

constructor TMigrateTable.Create(AConnection: TAdoConnection);
begin
  inherited Create(nil);
  Paramcheck := True;
  Connection := AConnection;

  MakeQuery;

  Count := 0;
end;

class function TMigrateTable.DateTimeToSQL(Value: TDateTime): variant;
begin
   if Value = 0 then
     result := null
   else
     result := Value;
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

class function TMigrateTable.NewGuid: TGuid;
begin
    CreateGuid(result);
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

procedure TMigrateTable.TestField (name: string);
begin
   try
      SQL.Text := format('SELECT [%s] FROM [%s]', [name,TableName]);
      self.ExecSQL;
   except
      raise exception.Create(Format('Field %s not found in table %s',[name, TableName]));
   end;
end;


procedure TMigrateTable.SetFields(FieldList: array of string; SFFieldList: array of string);
var
   Fields, values: string;
   I: Integer;

begin
   // Build The Field and Value list
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



class function TBatchMigrateTable.ToTxt(Value: Integer): string;
begin
   Result := IntTostr(Value);
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
      ExecSQL;
      Result := true;
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
//var ls: string;
begin
   //ls := trim(value);
   if Value = '' then
      Result := Null
   else
      Result := Value;
end;

class function TMigrateTable.ToSQL(Value: Boolean): variant;
begin
   Result := Value;
end;

class function TMigrateTable.ToSQL(Value: Integer): variant; 
begin
   Result := Value;
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


class function TMigrateTable.NullToSQL(Value: Integer): variant;
begin
  if value = 0 then
     Result := Null
  else
     Result := Value;
end;


class function TBatchMigrateTable.NullToTxt(Value: Integer): string;
begin
  if value = 0 then
     Result := 'null'
  else
     Result := IntToStr(Value);
end;

class function TMigrateTable.PercentToSQL(Value: Money): variant;
begin
   if Value=Unknown then
       Result:= Null
   else
       Result:= Value/10000;
end;


 function DecodeText(Value: string): string;
var
  InStream : TStringStream;
  OutStream : TMemoryStream;
  I: Integer;

begin
  Result := '';
  OutStream := TMemoryStream.Create;
  // Strip the CodecCode
  Instream := TStringStream.Create (Value);
  try
    if not Base64Decode(InStream, OutStream) then
      Exit;
    OutStream.Position := 0;
    SetLength(result,OutStream.Size);
    OutStream.Read(Result[1],OutStream.Size);
  finally
    FreeandNil(Instream);
    FreeandNil(Outstream);
  end;
end;



class function TMigrateTable.PWToSQL(Value: string): variant;
begin
   Result := Value;
   if Result = '' then
      Exit; // All Good
   // This key needs to be matched to the other side.   
   Result := EncryptPass16(DecodeText('srECIIYwVAHXECQO35zO1rF9gZ/DQfjO'), Result) + '.BF1';
end;

class function TBatchMigrateTable.PercentToTxt(Value: Money): string;
begin
   if Value=Unknown then
       Result:= 'null'
   else
       Result:= FloatToStr(Value/10000);
end;

class function TMigrateTable.QtyToSQL(Value: Money): variant;
begin
    if Value=Unknown then
       Result:= Null
   else
       Result:= Value/10000;
end;


class function TBatchMigrateTable.QtyToTxt(Value: Money): string;
begin
    if Value=Unknown then
       Result:= 'null'
   else
      Result:= FloatToStr(Value/10000);
end;


class function TBatchMigrateTable.DateToTxt(Value: Integer): string;
begin
   if Value <= 0 then
      Result := 'null' // Bad date or null date
   else if value = maxint then
      result := 'null' // clould make a 'maxdate'
   else
      Result := format('''%s''',[ StDateSt.StDateToDateString( 'yyyy-mm-dd', Value, False )]);
end;

class function TBatchMigrateTable.ToTxt(Value: TGuid): string; overload;
begin
  if IsEqualGUID(Value,emptyGuid) then
     Result := 'null'
  else begin
     Result := GuidTostring(Value);
     Result[1] := '''';
     Result[Length(Result)] := '''';
  end;
end;

class function TBatchMigrateTable.ToTxt(Value: string): string; overload;
begin
   Result := format('''%s''',[CleanToSQL( Value)]);
end;

class function TBatchMigrateTable.ToTxt(Date, Time: Integer): string;
begin

end;

class function TBatchMigrateTable.ToTxt(Value: Money): string; overload;
begin
   result := floatToStr(Value / 100);
end;

class function TBatchMigrateTable.ToTxt(Value: Boolean): string; overload;
begin
   if Value then
      result := '1'
   else
      result := '0';
end;

{ TBatchMigrateTable }

procedure TBatchMigrateTable.BeginBatch;
begin
  //AssignFile(TheFile,'Data.txt');
  //Rewrite(TheFile);
  //WriteLn(TheFile,Header);
  theValues := TstringList.Create;
end;
         {
procedure TBatchMigrateTable.PostBatch;
begin
   //Closefile(TheFile);


end;
   }
procedure TBatchMigrateTable.PostBatch;
begin
   if TheValues.Count > 0  then begin
      //SQL.text := baseSQL + TheValues.Text;
      //self.ExecSQL;
      self.Connection.Execute(baseSQL + TheValues.Text);
   end;
   FreeAndNil(theValues);
end;


function TBatchMigrateTable.RuntxtValues(values,
  SFValues: array of Shortstring): Boolean;

  var valuetxt : string;
      I: integer;
   function sep: string;
   begin
      if theValues.Count = 0 then
         result := ''
      else
         result := ',';
   end;
begin
   Result := false;
   valuetxt := values[0];
   for I := Low(values) + 1 to High(values) do begin
      valuetxt := valuetxt + Format(',%s',[values[I]]);
   end;
   for I := Low(SFValues) + 1 to High(SFValues) do begin
      valuetxt := valuetxt + Format(',%s',[SFValues[I]]);
   end;
   //WriteLn(TheFile,valuetxt);
   theValues.Add(format ('%s(%s)',[sep,valuetxt]));

   if theValues.Count > 999 then begin
      PostBatch; // Post this batch
      BeginBatch; // start a New one..
   end;

   Result := true;
end;
  {
procedure TBatchMigrateTable.SetFields(FieldList, SFFieldList: array of string);
var

   I: Integer;
begin
   // Build The Field and Value list
  Header := FieldList[0];

  TestField( FieldList[Low(FieldList)]);

  for I := Low(FieldList) + 1 to High(FieldList) do begin
     TestField(FieldList[I]);
     Header := Header + Format(',%s',[FieldList[I]]);
  end;



  if FDoSuperfund then // add the super fields
     for I := Low(SFFieldList) to High(SFFieldList) do begin
        TestField( SFFieldList[I]);
        Header := Header + Format(',%s',[SFFieldList[I]]);

     end;
end;
}

procedure TBatchMigrateTable.SetFields(FieldList, SFFieldList: array of string);
        var
   Fields, values: string;
   I: Integer;

begin
   // Build The Field and Value list
  Fields := Format('[%s]',[FieldList[0]]);

  for I := Low(FieldList) + 1 to High(FieldList) do begin
     TestField( FieldList[I]);
     Fields := Fields + Format(',[%s]',[FieldList[I]]);

  end;

  for I := Low(SFFieldList) to High(SFFieldList) do
     TestField( SFFieldList[I]);

  if FDoSuperfund then // add the super fields
     for I := Low(SFFieldList) to High(SFFieldList) do begin
        TestField( SFFieldList[I]);
        Fields := Fields + Format(',[%s]',[SFFieldList[I]]);
     end;

  // Make the query
  baseSQL := Format('Insert into [%s] (%s)  Values  ',[TableName,Fields]);
  //self.Prepared := true;
end;


initialization
  fillchar(emptyGuid,sizeof(emptyGuid),0);

end.
