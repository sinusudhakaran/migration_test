unit XMLSave;

interface


uses comctrls, controls, omniXML;


procedure SavePosition (Value : TControl; ByName : string; ToNode : IXMLNode);overload;
procedure ReadPosition (Value : Tcontrol; ByName : string; FromNode : IXMLNode);overload;

procedure SavePosition (Value : TControl; ToNode : IXMLNode);overload;
procedure ReadPosition (Value : Tcontrol; FromNode : IXMLNode);overload;


procedure SavePagetab (Value : TPageControl; ByName: string; ToNode : IXMLNode);overload;
procedure ReadPageTab (Value : TPageControl; ByName: string; FromNode : IXMLNode);overload ;

procedure SavePagetab (Value : TPageControl; ToNode : IXMLNode);overload;
procedure ReadPageTab (Value : TPageControl; FromNode : IXMLNode);overload ;



procedure SaveColumns (Value : TListView; ByName: string; ToNode : IXMLNode);overload;
procedure ReadColumns (Value : TListView; ByName: string; FromNode : IXMLNode);overload;

procedure SaveColumns (Value : TListView; ToNode : IXMLNode);overload;
procedure ReadColumns (Value : TListView; FromNode : IXMLNode);overload;




implementation

uses OMNIXMLUtils,Sysutils;


procedure SavePosition (Value : TControl; ByName : string; ToNode : IXMLNode);
var NN : IXMLNode;
begin
  if not Assigned(Value) then Exit;
  if not Assigned(ToNode) then Exit;

  NN := EnsureNode(ToNode,ByName);
  SetNodeTextInt(NN,'Left',   Value.Left);
  SetNodeTextInt(NN,'Top',    Value.Top);
  SetNodeTextInt(NN,'Width',  Value.Width);
  SetNodeTextInt(NN,'Height', Value.Height);
end;

procedure ReadPosition (Value : Tcontrol; ByName : string; FromNode : IXMLNode);
var NN : IXMLNode;
begin
  if not Assigned(Value) then Exit;
  if not Assigned(FromNode) then Exit;

  NN := EnsureNode(FromNode,ByName);
  Value.SetBounds
  (
     GetNodeTextInt(NN,'Left',   Value.Left),
     GetNodeTextInt(NN,'Top',    Value.Top),
     GetNodeTextInt(NN,'Width',  Value.Width),
     GetNodeTextInt(NN,'Height', Value.Height)
  );
end;

procedure SavePosition (Value : TControl; ToNode : IXMLNode);overload;
begin
   if not Assigned(Value) then Exit;
   if not Assigned(ToNode) then Exit;
   Saveposition (Value, Value.Name, ToNode);
end;

procedure ReadPosition (Value : Tcontrol; FromNode : IXMLNode);overload;
begin
   if not Assigned(Value) then Exit;
   if not Assigned(FromNode) then Exit;
   Readposition (Value, Value.Name, FromNode);
end;


procedure SavePagetab (Value : TPageControl; ByName: string; ToNode : IXMLNode);
begin
   if not Assigned(Value) then Exit;
   if not Assigned(ToNode) then Exit;
   SetNodeTextInt (EnsureNode(ToNode,ByName),
        'Pageindex', Value.ActivePageIndex);
end;

procedure ReadPageTab (Value : TPageControl; ByName: string;FromNode : IXMLNode);overload ;
begin
   if not Assigned(Value) then Exit;
   if not Assigned(FromNode) then Exit;
   Value.ActivePageIndex := GetNodeTextInt (EnsureNode(FromNode,ByName),
        'Pageindex', Value.ActivePageIndex);
end;

procedure SavePagetab (Value : TPageControl; ToNode : IXMLNode);
begin
   if not Assigned(Value) then Exit;
   if not Assigned(ToNode) then Exit;
   SavePagetab (Value, Value.Name, ToNode);
end;

procedure ReadPageTab (Value : TPageControl; FromNode : IXMLNode);
begin
   if not Assigned(Value) then Exit;
   if not Assigned(FromNode) then Exit;
   ReadPageTab(Value, Value.Name, FromNode);
end;


procedure SaveColumns (Value : TListView; ByName: string; ToNode : IXMLNode);
var I : Integer;
    NN : IXMLNode;
begin
   if not Assigned(Value) then Exit;
   if not Assigned(ToNode) then Exit;
   NN := EnsureNode(ToNode,ByName);
   if not Assigned(Value) then Exit;
   for I := 0 to Pred(Value.Columns.Count) do begin
      SetNodeTextInt(NN,'Col' + IntToStr(Succ(I)),Value.Columns[i].Width);
   end;
end;



procedure ReadColumns (Value : TListView; ByName: string;FromNode : IXMLNode);overload;
var I : Integer;
    NN : IXMLNode;
begin
   if not Assigned(Value) then Exit;
   if not Assigned(FromNode) then Exit;
   NN := EnsureNode(FromNode,ByName);
   for I := 0 to Pred(Value.Columns.Count) do begin
      Value.Columns[i].Width := GetNodeTextInt(NN,'Col' + IntToStr(Succ(I)),Value.Columns[i].Width);
   end;
end;

procedure SaveColumns (Value : TListView; ToNode : IXMLNode);overload;
begin
  if not Assigned(Value) then Exit;
  if not Assigned(ToNode) then Exit;
  SaveColumns(Value,Value.Name,ToNode);
end;

procedure ReadColumns (Value : TListView; FromNode : IXMLNode);overload;
begin
  if not Assigned(Value) then Exit;
  if not Assigned(FromNode) then Exit;
  ReadColumns(Value,Value.Name,FromNode);
end;


end.
