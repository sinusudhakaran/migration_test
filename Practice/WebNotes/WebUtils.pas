unit WebUtils;

//------------------------------------------------------------------------------
interface

uses
  sysutils,
  bkConst,
  XMLDoc,
  stDate,
  MoneyDef,
  XMLIntf,
  xmldom;

  function FormatXMLdate(Value: TstDate): string;
  procedure AddBooleanOption(var ToNode: IXMLNode; name: string; Value: Boolean);
  procedure SetTextAttr(var OnNode: IXMLNode; Name, Value: string);
  procedure SetSourceAttr(var OnNode: IXMLNode; Name: string;  Value: Integer);
  procedure SetMoneyAttr(var OnNode: IXMLNode; Name: string; Value: Money);
  procedure SetBoolAttr(var OnNode: IXMLNode; Name: string; Value: Boolean);
  procedure SetQtyAttr(var OnNode: IXMLNode; Name: string; Value: Money);
  procedure SetRateAttr(var OnNode: IXMLNode; Name: string; Value: Money);
  procedure SetDateAttr(var OnNode: IXMLNode; Name: string; Value: TstDate);
  procedure SetCodeByAttr(var OnNode: IXMLNode; Name: string; Value: Byte);
  procedure SetUPIState(var OnNode: IXMLNode; Name: string; Value: Byte);

  function GetIntAttr(FromNode: IXMLNode; Name: string): Integer;
  function GetDateAttr(FromNode: IXMLNode; Name : string): TStDate;
  function GetStringAttr(FromNode: IXMLNode; Name : string): string;
  function GetUPIStateAttr(FromNode: IXMLNode; Name : string): Integer;
  function GetMoneyAttr(FromNode: IXMLNode; Name : string): Money;
  function GetQtyAttr(FromNode: IXMLNode; Name : string): Money;
  function GetBoolAttr(FromNode: IXMLNode; Name : string): Boolean;
  function GetCodeByAttr(FromNode: IXMLNode; Name: string): Integer;
  function GetFirstDissection(FromNode: IXMLNode): IXMLNode;
  function GetDissectionCount(FromNode: IXMLNode): Integer;

  function EncodeText(Value: string): string;
  function DecodeText(Value: string): string;

  function CountryText(Value: byte):string;

  function TestResponse(Value: IXMLNode; name: string): Boolean;

  function MakeXMLDoc (FromXML: string): IXMLDocument;

//------------------------------------------------------------------------------
implementation

uses
  OmniXMLUtils,
  ZLibExGZ,
  glConst,
  Classes,
  WebNotesSchema,
  stDateSt;

const
  CodecCode = 'GZIP';
  MinLength = 300;

//------------------------------------------------------------------------------
function GetFirstDissection(FromNode: IXMLNode): IXMLNode;
begin
  Result := FromNode.ChildNodes.FindNode(nDissections);
  if Assigned(Result) then
    Result := Result.ChildNodes.First;
end;

//------------------------------------------------------------------------------
function GetDissectionCount(FromNode: IXMLNode): Integer;
var
  lNode: IXMLNode;
begin
  lNode := FromNode.ChildNodes.FindNode(nDissections);
  if Assigned(LNode) then
    Result := LNode.ChildNodes.Count
  else
    Result := 0;
end;

//------------------------------------------------------------------------------
function FormatXMLdate(Value: TstDate): string;
begin
  Result :=  StDateToDateString(nDateMask, Value, True);
end;

//------------------------------------------------------------------------------
procedure SetBoolAttr(var OnNode: IXMLNode; Name: string; Value: Boolean);
begin
  if Value then
    OnNode.Attributes [Name] := nTrue
  else
    OnNode.Attributes [Name] := nFalse;
end;

//------------------------------------------------------------------------------
procedure AddBooleanOption(var ToNode: IXMLNode; name: string; Value: Boolean);
var
  lNode : IXMLNode;
begin
  lnode := ToNode.AddChild(nOption);
  lnode.Attributes [nName] := Name;
  if Value then
    lnode.Attributes [nValue] := nTrue
  else
    lnode.Attributes [nValue] := nFalse
end;

//------------------------------------------------------------------------------
procedure SetCodeByAttr(var OnNode: IXMLNode; Name: string; Value: Byte);
begin
  if value in [cbManual ..cbMax] then  // Skip cbNotCoded
    OnNode.Attributes [Name] := cbNames[Value];
end;

//------------------------------------------------------------------------------
function GetCodeByAttr(FromNode: IXMLNode; Name: string): Integer;
begin
  if Assigned(FromNode.AttributeNodes.FindNode(Name)) then
  begin
    for Result := cbManual to cbMax do
      if sameText(cbNames[Result],FromNode.Attributes[Name]) then
        Exit;
  end;

  Result := cbNotCoded;
end;

//------------------------------------------------------------------------------
procedure SetDateAttr(var OnNode: IXMLNode; Name: string; Value: TstDate);
begin
  if Value <> 0 then
    OnNode.Attributes [Name] := FormatXMLdate(Value);
end;

//------------------------------------------------------------------------------
procedure SetMoneyAttr(var OnNode: IXMLNode; Name: string; Value: Money);
begin
  if Value <> 0 then
    OnNode.Attributes [Name] := (Value / 100);
end;

//------------------------------------------------------------------------------
procedure SetQtyAttr(var OnNode: IXMLNode; Name: string; Value: Money);
begin
  if Value <> 0 then
    OnNode.Attributes [Name] := Value / 10000;
end;

//------------------------------------------------------------------------------
procedure SetRateAttr(var OnNode: IXMLNode; Name: string; Value: Money);
begin
  if Value <> 0 then
    OnNode.Attributes [Name] := (Value / 10000);
end;

//------------------------------------------------------------------------------
procedure SetSourceAttr(var OnNode: IXMLNode; Name: string;  Value: Integer);
begin
  case Value of
    orBank : OnNode.Attributes [Name] := 'Bank';
    else
      OnNode.Attributes [Name] := 'Generated';
    (* At this stage this should do...*)
   //orGenerated    : OnNode.Attributes [Name] := 'Generated';
   //orManual       : OnNode.Attributes [Name] := Value;
   //orHistorical   : OnNode.Attributes [Name] := Value;
   //orGeneratedRev : OnNode.Attributes [Name] := Value;
   end;
end;

//------------------------------------------------------------------------------
procedure SetTextAttr(var OnNode: IXMLNode; Name, Value: string);
begin
  if Value > '' then
    OnNode.Attributes [Name] := Value;
end;

//------------------------------------------------------------------------------
procedure SetUPIState(var OnNode: IXMLNode; Name: string; Value: Byte);
begin
  if Value in [upUPC .. upMax] then
    OnNode.Attributes [Name] := nUPINames[Value];
end;

//------------------------------------------------------------------------------
function GetIntAttr(FromNode: IXMLNode; Name: string): Integer;
begin
  if Assigned(FromNode.AttributeNodes.FindNode(Name)) then
    try // Things like Payee may become text...
      Result := FromNode.Attributes[Name];
    except
      Result := 0;
    end
  else
    Result := 0;
end;

//------------------------------------------------------------------------------
function GetDateAttr(FromNode: IXMLNode; Name : string): tStDate;
begin
  if Assigned(FromNode.AttributeNodes.FindNode(Name)) then
  begin
    Result := DateStringToStDate(nDateMask,FromNode.Attributes[Name], BKDATEEPOCH);
  end
  else
    Result := 0;
end;

//------------------------------------------------------------------------------
function GetStringAttr(FromNode: IXMLNode; Name : string): string;
begin
  if Assigned(FromNode.AttributeNodes.FindNode(Name)) then
  begin
    Result := FromNode.Attributes[Name]
  end
  else
    Result := '';
end;

//------------------------------------------------------------------------------
function GetUPIStateAttr(FromNode: IXMLNode; Name : string): integer;
var
  lString: string;
begin
  if Assigned(FromNode.AttributeNodes.FindNode(Name)) then
  begin
    lString := FromNode.Attributes[Name];
    for Result := upMin to upMax do
      if SameText(lString,nUPINames[Result]) then
        Exit;

  end;
  Result := 0;
end;

//------------------------------------------------------------------------------
function GetMoneyAttr(FromNode: IXMLNode; Name : string): Money;
begin
  if Assigned(FromNode.AttributeNodes.FindNode(Name)) then
  begin
    Result := strToFloat(FromNode.Attributes[Name]) * 100;
  end
  else
    Result := 0;
end;

//------------------------------------------------------------------------------
function GetQtyAttr(FromNode: IXMLNode; Name : string): Money;
begin
  if Assigned(FromNode.AttributeNodes.FindNode(Name)) then
  begin
    Result := strToFloat(FromNode.Attributes[Name]) * 10000;
  end
  else
    Result := 0;
end;

//------------------------------------------------------------------------------
function GetBoolAttr(FromNode: IXMLNode; Name : string): Boolean;
begin
  if Assigned(FromNode.AttributeNodes.FindNode(Name)) then
  begin
    Result := Sametext(nTrue,FromNode.Attributes[Name])
  end
  else
    Result := False;
end;

//------------------------------------------------------------------------------
function CountryText(Value: byte): string;
begin
  case Value of
     1: Result := 'AU';
     2: Result := 'UK';
  else
    Result := 'NZ';
  end;
end;

//------------------------------------------------------------------------------
function TestResponse(Value: IXMLNode; Name: string): Boolean;
var
  lNode,
  ENode: IXMLNode;
begin
  result := False;

  if not SameText(Value.NodeName, Name) then // Wrong Reply Type..
    raise Exception.Create('Wrong server response' );

  lNode := Value.ChildNodes.FindNode(nSuccess);
  if Assigned(lNode) then
    if LNode.NodeValue = nTrue then
    begin
      Result := true;
      Exit;
    end;

  // see if we can raise a sensible exception
  ENode := Value.ChildNodes.FindNode(nError);
  if Assigned(ENode) then
  begin
    lNode := ENode.ChildNodes.FindNode(nMessage);
      if Assigned(lNode) then
        raise Exception.Create(LNode.NodeValue);
    lNode := ENode.ChildNodes.FindNode(nCode);
      if Assigned(lNode) then
        raise Exception.Create(format('Code(%s)',[LNode.NodeValue]));
  end;
end;

//------------------------------------------------------------------------------
function MakeXMLDoc (FromXML: string): IXMLDocument;
begin
  Result := XMLDoc.NewXMLDocument;
  try
    Result.Active := true;
    Result.LoadFromXML(FromXML);
  except
    on e: exception do
    begin
      Result := nil;
      raise exception.Create(e.Message);
    end;
  end;
end;

(*****************************************************************************

Mirrors code at the  PracticeIntegration facade

*****************************************************************************)
//------------------------------------------------------------------------------
function EncodeText(Value: string): string;
var
  InStream : TStringStream;
  OutStream : TMemoryStream;
  Len : Integer;
begin
  Result := value;

  if Length(Value) < MinLength then
    Exit; // No point is likely just to get longer...

  Instream := TStringStream.Create (Value);
  OutStream := TMemoryStream.Create;
  try
    try
      Len := Length(Value);
      // Write the size in first
      OutStream.Write(Len,Sizeof(Len));
      // Add The Gziped String
      GZCompressStream(Instream,OutStream);

      //Position back at the start
      OutStream.Position := 0;

      //reuse the streams reversed, so clear the Instream
      Instream.Size := 0;
      Base64Encode(OutStream, Instream);
      //Instream is now the result..
      Result := CodecCode + Instream.DataString;
    except
      // just send as is...
    end;
  finally
    FreeandNil(Instream);
    FreeandNil(Outstream);
  end;
end;

//------------------------------------------------------------------------------
function DecodeText(Value: string): string;
var
  InStream : TStringStream;
  OutStream : TMemoryStream;
  Len: Integer;
begin
  Result := Value;
  if Length(Value) < Length(CodecCode) then
    Exit;

  if not SameText(copy(Value,1,Length(CodecCode)),CodecCode) then
    Exit;

  OutStream := TMemoryStream.Create;
  // Strip the CodecCode
  Instream := TStringStream.Create (copy(Value,Length(CodecCode) + 1,Length(Value)));
  try
    if not Base64Decode(InStream, OutStream) then
      Exit;
    OutStream.Position := 0;
    // Get the size first..
    OutStream.Read(Len,Sizeof(Len));
    // Reuse the InStream
    InStream.Size := 0;
    GZDeCompressStream(Outstream,InStream);
    Result := Instream.DataString;
  finally
    FreeandNil(Instream);
    FreeandNil(Outstream);
  end;
end;

end.
