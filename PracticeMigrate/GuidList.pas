unit GuidList;

interface
uses Contnrs,Sysutils,ECollect, MoneyDef;


type

TGuidObject = class (TObject)
  GuidID: TGuid;
  Data: Pointer;
  SequenceNo: Integer;
  Size: Money;
end;


TGuidList = class(TObjectList)
private

public
   constructor Create(Source: TExtdCollection = nil);
   function CloneList(Source: TExtdCollection): TGuidList;
   function FindLRNObject(Value: Integer): TGuidObject; overload;
   function FindLRNGuid(Value: Integer): TGuid; overload;
end;

function GuidSort(Item1, Item2: Pointer): Integer;

implementation

uses math;

function compareGuid(Item1,Item2: TGuid): Integer;
begin

   Result := CompareValue(Item1.D4[2],Item2.D4[2]);
   if result <> 0 then exit;
   Result := CompareValue(Item1.D4[3],Item2.D4[3]);
   if result <> 0 then exit;
   Result := CompareValue(Item1.D4[4],Item2.D4[4]);
   if result <> 0 then exit;
   Result := CompareValue(Item1.D4[5],Item2.D4[5]);
   if result <> 0 then exit;
   Result := CompareValue(Item1.D4[6],Item2.D4[6]);
   if result <> 0 then exit;
   Result := CompareValue(Item1.D4[7],Item2.D4[7]);
   if result <> 0 then exit;

   Result := CompareValue(Item2.D4[0],Item1.D4[0]);
   if result <> 0 then exit;
   Result := CompareValue(Item2.D4[1],Item1.D4[1]);
   if result <> 0 then exit;

   Result := CompareValue(Item2.D3,Item1.D3);
   if result <> 0 then exit;

   Result := CompareValue(Item2.D2,Item1.D2);
   if result <> 0 then exit;

   Result := CompareValue(Item2.D1,Item1.D1);
   if result <> 0 then exit;



end;


function GuidSort(Item1, Item2: Pointer): Integer;
begin
  Result := CompareGuid (TGuidObject(Item1).GuidID,TGuidObject(Item1).GuidID);

end;


{ TGuidList }

function TGuidList.CloneList(Source: TExtdCollection): TGuidList;
var i: Integer;
    nItem : TGuidObject;
begin
   Result := Self;

   Clear;

   if not assigned(Source) then
      Exit;

   for I := 0 to Source.ItemCount - 1 do begin
      nItem := TGuidObject.Create;
      CreateGUID(nitem.GuidID);
      add(nItem);
   end;

   Sort(GuidSort);

   for I := 0 to Source.ItemCount - 1 do with TGuidObject(Items[I]) do begin
      Data := Source.Items[I];
      SequenceNo := Succ(I);
   end;
end;

constructor TGuidList.Create(Source: TExtdCollection);
begin
   inherited create(True);
   CloneList(Source);
end;


function TGuidList.FindLRNGuid(Value: Integer): TGuid;
var Test: TGuidObject;
begin
   FillChar(Result,Sizeof(result),0);
   Test := FindLRNobject(Value);
   if Assigned(Test) then
       Result := test.GuidID;


end;

function TGuidList.FindLRNObject(Value: Integer): TGuidObject; 

type

baserec = Packed Record
      Record_Type: Byte;
      LRN: Integer;
end;

var I: integer;
begin
   for I := 0 to Count - 1 do
      if baserec(TGuidObject(Items[I]).Data^).LRN = Value then begin
         result := TGuidObject(Items[I]);
         Exit;
      end;
   Result := nil;
end;

end.
