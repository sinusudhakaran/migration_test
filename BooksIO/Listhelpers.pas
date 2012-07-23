unit Listhelpers;

interface
uses
BUDOBJ32,
clObj32,
baobj32,
trxList32,
MemorisationsObj,
PayeeObj,
sysutils,
XMLIntf,
bkdefs;

Type
TXML_Helper = class
private
	procedure WriteToNode(value: PTransaction_rec; var Node :IXMLNode); overload;
  procedure WriteToNode(value: TBank_Account; var Node :IXMLNode); overload;
  procedure WriteToNode(value: TMemorisation; var Node :IXMLNode); overload;
  procedure WriteToNode(value: TClientObj; var Node :IXMLNode); overload;
  procedure WriteToNode(value: TPayee; var Node :IXMLNode); overload;
  procedure WriteToNode(value: TBudget; var Node :IXMLNode); overload;


 	procedure ReadFromNode(var value: PTransaction_rec; Node :IXMLNode); overload;
  procedure ReadFromNode(var value: TBank_Account; Node :IXMLNode); overload;
  procedure ReadFromNode(var value: TMemorisation; Node :IXMLNode); overload;
  procedure ReadFromNode(var value: TClientObj; Node :IXMLNode); overload;
  procedure ReadFromNode(var value: TPayee; Node :IXMLNode); overload;
  procedure ReadFromNode(var value: TBudget; Node :IXMLNode); overload;

  procedure Reraise(E: Exception; Doing: string);
public
  function MakeXML(value: TClientObj): string;

  function ReadClient(Value: string):TClientObj;
End;

//procedure logDebug(msg: string);

implementation

uses
    webutils,

    logger,
    classes,
    BKplIO,
    BKmlIO,
    BKtxIO,
    BKdsIO,
    BKbdIO,
    BKchIO,
    BKjhIO,
    BKblIO,
    BKhdIO,
    BKdlIO,
    XMLDoc,
    BK_XMLHelper
    //rexhelpers
    //BK_XMLHelper
    ;

//-----------  DEbug Options --------------

var DebugMe : boolean = true;

procedure logDebug(msg: string);
begin
   if DebugMe then begin

      logger.LogDebug(msg);
   end;
end;



{ TXML_Helper }

//-----------------------------  TClientObj ------------------------------------
procedure TXML_Helper.WriteToNode(value: TClientObj; var Node: IXMLNode);
var I: Integer;
    //BankNode: IXMLNode;
    LNode : IXMLNode;
begin

  value.clFields.WriteRecToNode(Node);
  value.clMoreFields.WriteRecToNode(Node);
  value.clExtra.WriteRecToNode(Node);


  logDebug('Start write Accounts');
  LNode := Node.AddChild('BankAccounts');
  for I := 0 to value.clBank_Account_List.last do begin
     WriteToNode(value.clBank_Account_List.Bank_Account_At(I),LNode);
  end;

  logDebug('Start write Chart');
  LNode := Node.AddChild('Chart');
  for I := 0 to value.clChart.Last do begin
     value.clChart.Account_At(I).WriteRecToNode(LNode);
  end;

  logDebug('Start write Payees');
  LNode := Node.AddChild('Payees');
  for I := 0 to value.clPayee_List.Last do begin
     WriteToNode(value.clPayee_List.Payee_At(I) ,LNode);
  end;

  logDebug('Start write Jobs');
  LNode := Node.AddChild('Jobs');
  for I := 0 to value.clJobs.Last do begin
     value.clJobs.Job_At(I).WriteRecToNode(LNode);
  end;

  logDebug('Start write Budgets');
  LNode := Node.AddChild('Budgets');
  for I := 0 to value.clBudget_List.Last do begin
     WriteToNode(value.clBudget_List.Budget_At(I), LNode);
  end;

  logDebug('Start write Balances');
  LNode := Node.AddChild('Balances');
  for I := 0 to value.clBalances_List.Last do begin
     value.clBalances_List.Balances_At(I).WriteRecToNode(LNode);
  end;

  logDebug('Start write Headings');
  LNode := Node.AddChild('Headings');
  for I := 0 to value.clCustom_Headings_List.Last do begin
     value.clCustom_Headings_List.Custom_Heading_At(I).WriteRecToNode(LNode);
  end;

  logDebug('Start write DiskLog');
  LNode := Node.AddChild('DiskLog');
  for I := 0 to value.clDisk_Log.Last do begin
     value.clDisk_Log.Disk_Log_At(I).WriteRecToNode(LNode); ;
  end;

end;

function BankAccountCompare(Item1,Item2:Pointer):integer;
begin
   result := CompareStr(TBank_Account(Item1).baFields.baBank_Account_Number,TBank_Account(Item2).baFields.baBank_Account_Number);
end;

procedure TXML_Helper.ReadFromNode(var value: TClientObj; Node: IXMLNode);
var
   LNode: IXMLNode;
   nAccount: TBank_Account;
   nChart: PAccount_Rec;
   nJob: PJob_Heading_Rec;
   nPayee: TPayee;
   nBudget: TBudget;
   nBalance: PBalances_rec;
   nHeading: pCustom_Heading_Rec;
   nLog: pDisk_Log_Rec;
begin

   value.clFields.ReadRecFromNode(Node);
   value.clMoreFields.ReadRecFromNode(Node);
   value.clExtra.ReadRecFromNode(Node);

   try
   LNode := Node.ChildNodes.FindNode('BankAccounts');
   value.clBank_Account_List.DeleteAll;
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(LNode) do begin
         nAccount := TBank_Account.Create(value);
         ReadFromNode(nAccount,LNode);
         //LogDebug(LNode.XML);
         value.clBank_Account_List.Insert(nAccount);

         LNode := LNode.NextSibling;
      end;
   end;
   //value.clBank_Account_List.Sort(BankAccountCompare);
   except
      on e: exception do
         Reraise(e, 'Reading Bank Accounts');
   end;


   try
   LNode := Node.ChildNodes.FindNode('Chart');
   value.clChart.DeleteAll;
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(LNode) do begin
         nChart := New_Account_Rec;
         nChart.ReadRecFromNode(LNode);
         value.clChart.Insert(nChart);
         LNode := LNode.NextSibling;
      end;
   end;
   except
      on e: exception do
         Reraise(e, 'Reading Chart');
   end;

   try
   LNode := Node.ChildNodes.FindNode('Payees');
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(LNode) do begin
         nPayee := tPayee.Create;
         ReadFromNode(nPayee,LNode);
         value.clPayee_List.Insert(nPayee);
         LNode := LNode.NextSibling;
      end
   end;
   except
      on e: exception do
         Reraise(e, 'Reading Payees');
   end;

   try
   LNode := Node.ChildNodes.FindNode('Jobs');
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(LNode) do begin
         nJob := New_Job_Heading_Rec;
         nJob.ReadRecFromNode(LNode);
         value.clJobs.Insert(nJob);
         LNode := LNode.NextSibling;
      end
   end;
   except
      on e: exception do
         Reraise(e, 'Reading Jobs');
   end;

   try
   LNode := Node.ChildNodes.FindNode('Budgets');
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(LNode) do begin
         nBudget := TBudget.Create;
         ReadFromNode(nBudget, LNode);
         value.clBudget_List.Insert(nBudget);
         LNode := LNode.NextSibling;
      end
   end;
   except
      on e: exception do
         Reraise(e, 'Reading Budgets');
   end;

   try
   LNode := Node.ChildNodes.FindNode('Balances');
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(LNode) do begin
         nBalance := New_Balances_rec;
         nBalance.ReadRecFromNode(LNode);
         value.clBalances_List.Insert(nBalance);
         LNode := LNode.NextSibling;
      end
   end;
   except
      on e: exception do
         Reraise(e, 'Reading Balances');
   end;

   try
   LNode := Node.ChildNodes.FindNode('Headings');
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(LNode) do begin
         nHeading := New_Custom_Heading_Rec;
         nHeading.ReadRecFromNode(LNode);
         value.clCustom_Headings_List.Insert(nHeading);
         LNode := LNode.NextSibling;
      end
   end;
   except
      on e: exception do
         Reraise(e, 'Reading Headings');
   end;

   try
   LNode := Node.ChildNodes.FindNode('DiskLog');
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(LNode) do begin
         nLog := New_Disk_Log_Rec;
         nLog.ReadRecFromNode(LNode);
         value.clDisk_Log.Insert(nLog);
         LNode := LNode.NextSibling;
      end
   end;
   except
      on e: exception do
         Reraise(e, 'Reading DiskLog');
   end;

   LNode := nil;
end;


//----------------------------  PTransaction_rec -----------------------------------

function AddDissection(value: PTransaction_rec): pDissection_Rec;
var
  Seq : Integer;
begin
  Result := New_Dissection_Rec;
  Seq := 0;
  If value.txLast_Dissection <> nil then
     Seq := value.txLast_Dissection^.dsSequence_No;
  Inc(Seq);
  with Result^ do
  begin
    dsTransaction  := value;
    dsSequence_No  := Seq;
    dsNext         := NIL;
    dsClient       := value.txClient;
    dsBank_Account := value.txBank_Account;
  end;
  if (value.txFirst_Dissection = nil) then
     value.txFirst_Dissection := Result; // Im the first
  if (value.txLast_Dissection <> nil) then
     value.txLast_Dissection^.dsNext := Result; // Hook me in
  value.txLast_Dissection := Result;// Im always the last
end;


procedure TXML_Helper.WriteToNode(value: PTransaction_rec; var Node :IXMLNode) overload;
var
   Diss: PDissection_Rec;
   DisNode, MyNode: IXMLNode;
begin
  MyNode := value^.WriteRecToNode(Node);
  Diss := Value.txFirst_Dissection;
  if Assigned(Diss) then begin
     DisNode := MyNode.AddChild('Dissections');
     while assigned(Diss) do begin
        Diss^.WriteRecToNode(DisNode);
        Diss := Diss.dsNext;
     end;
  end;
  MyNode := nil;
  DisNode := nil;
end;

procedure TXML_Helper.ReadFromNode(var value: PTransaction_rec; Node: IXMLNode);
var LNode : IXMLNode;
    new: PDissection_Rec;
begin
   LNode := value^.ReadRecFromNode(Node);
   if not assigned(lnode) then exit;
   LNode := Node.ChildNodes.FindNode('Dissections');
   if not assigned(lnode) then Exit;
   lnode := lnode.ChildNodes.First;
   while Assigned(LNode) do begin
       new := AddDissection(value);
       new.ReadRecFromNode(LNode);
       //pendDissection(value, new);
       LNode := LNode.NextSibling;
   end;
   LNode := nil;
end;


//----------------------------  TBankAccount -----------------------------------
procedure TXML_Helper.WriteToNode(value: TBank_Account; var Node: IXMLNode);
var I: Integer;
    MyNode, LNode: IXMLNode;
begin
   MyNode := value.baFields.WriteRecToNode(Node);
   if not Assigned(MyNode) then exit;

   LNode := MyNode.AddChild('Transactions');
   for I := 0 to value.baTransaction_List.last do begin
      WriteToNode(value.baTransaction_List.Transaction_At(I),LNode);
   end;

   LNode := MyNode.AddChild('Memorisations');
   for I := 0 to value.baMemorisations_List.last do begin
      WriteToNode(value.baMemorisations_List.Memorisation_At(I),LNode);
   end;
   MyNode := nil;
   LNode := nil;
end;

procedure TXML_Helper.ReadFromNode(var value: TBank_Account; Node: IXMLNode);
var LNode : IXMLNode;
    new: pTransaction_Rec;
    NMem: Tmemorisation;
begin

   LNode := value.baFields.ReadRecFromNode(Node);
   if not assigned(lnode) then exit;

   LNode := Node.ChildNodes.FindNode('Transactions');
   if Assigned(lnode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(LNode) do begin
         new := new_Transaction_Rec;
         value.baTransaction_List.Insert_Transaction_Rec(new);
         ReadFromNode(new, LNode);

         LNode := LNode.NextSibling;
      end;
   end;

   LNode := Node.ChildNodes.FindNode('Memorisations');
   if Assigned(lnode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(LNode) do begin
         NMem := Tmemorisation.Create(nil);
         ReadFromNode(NMem,LNode);
         value.baMemorisations_List.Insert_Memorisation(NMem, False);
         LNode := LNode.NextSibling;
      end;
   end;
   LNode := nil;
end;



//---------------------------  TMemorisation -----------------------------------
procedure TXML_Helper.WriteToNode(value: TMemorisation; var Node: IXMLNode);
var LNode : IXMLNode;
    I: Integer;
begin
   LNode := value.mdFields.WriteRecToNode(Node);
   LNode := LNode.AddChild('Lines');
   for I := 0 to value.mdLines.Last do begin
       value.mdLines.MemorisationLine_At(I).WriteRecToNode(LNode);
   end;
   LNode := nil;
end;

procedure TXML_Helper.ReadFromNode(var value: TMemorisation; Node: IXMLNode);
var LNode : IXMLNode;
    new: pMemorisation_Line_Rec;
begin
   LNode := value.mdFields.ReadRecFromNode(Node);
   if not assigned(LNode) then exit;
   LNode := LNode.ChildNodes.FindNode('Lines');
   if not assigned(LNode) then Exit;
   LNode := LNode.ChildNodes.First;
   while Assigned(LNode) do begin
       new := new_Memorisation_Line_Rec;
       new.ReadRecFromNode(LNode);
       value.mdLines.Insert(new);
       LNode := LNode.NextSibling;
   end;
   LNode := nil;
end;


//---------------------------  TPayee ---------------------------------------
procedure TXML_Helper.WriteToNode(value: TPayee; var Node: IXMLNode);
var LNode : IXMLNode;
    I: Integer;
begin
   LNode := value.pdFields.WriteRecToNode(Node);
   LNode := LNode.AddChild('Lines');
   for I := 0 to value.pdLines.Last do begin
       value.pdLines.PayeeLine_At(I).WriteRecToNode(LNode);
   end;
   LNode := nil;
end;

procedure TXML_Helper.ReadFromNode(var value: TPayee; Node: IXMLNode);
var LNode : IXMLNode;
    new: pPayee_Line_Rec;
begin
   LNode := value.pdFields.ReadRecFromNode(Node);
   if not assigned(LNode) then exit;
   LNode := LNode.ChildNodes.FindNode('Lines');
   if not assigned(LNode) then Exit;
   lnode := lnode.ChildNodes.First;
   while Assigned(LNode) do begin
       new := new_Payee_Line_Rec;
       new.ReadRecFromNode(LNode);
       value.pdLines.Insert(new);
       LNode := LNode.NextSibling;
   end;
   LNode := nil;
end;



//-----------------------------  TBudget ---------------------------------------
procedure TXML_Helper.WriteToNode(value: TBudget; var Node: IXMLNode);
var LNode : IXMLNode;
    I: Integer;
begin
   LNode := value.buFields.WriteRecToNode(Node);
   LNode := LNode.AddChild('Details');
   for I := 0 to value.buDetail.Last do begin
       value.buDetail.Budget_Detail_At(I).WriteRecToNode(LNode);
   end;
   LNode := nil;
end;

procedure TXML_Helper.ReadFromNode(var value: TBudget; Node: IXMLNode);
var LNode : IXMLNode;
    new: pBudget_Detail_Rec;
begin
   LNode := value.buFields.ReadRecFromNode(Node);
   if not assigned(lnode) then exit;
   LNode := LNode.ChildNodes.FindNode('Details');
   if not assigned(lnode) then Exit;
   lnode := lnode.ChildNodes.First;
   while Assigned(LNode) do begin
       new := new_Budget_Detail_Rec;
       new.ReadRecFromNode(LNode);
       value.buDetail.Insert(new);
       LNode := LNode.NextSibling;
   end;
   LNode := nil;
end;


//---------------------------  local helper ------------------------------------
procedure TXML_Helper.Reraise(E: Exception; Doing: string);
begin
  raise exception.Create( format('Error : %s While : %s',[E.Message, Doing]));
end;


//---------------------------  XML direct --------------------------------------
function TXML_Helper.MakeXML(value: TClientObj): string;
var
  LNode : IXMLNode;
  lXMLDoc: IXMLDocument;
begin
  //setup XML Document
  logDebug('Write XML Start');
  lXMLDoc := XMLDoc.NewXMLDocument;
  lXMLDoc.Active := true;
  lXMLDoc.Options := [doNodeAutoIndent,doAttrNull,doNamespaceDecl];
  lXMLDoc.version:= '1.0';
  lXMLDoc.encoding:= 'UTF-8'; // Have no choice for now, its not a WideString


   // Build the notes
  LNode := lXMLDoc.CreateNode('BKClientFile');
  LNode.Attributes['Version'] := BK_FILE_VERSION;
  //LNode.DeclareNamespace('','BankLink.Practice');

  lXMLDoc.DocumentElement := LNode;
  //LNode := LNode.AddChild('Client','BankLink.Practice');

  WriteToNode(value,LNode);


  // Return the XML String...
  Result := lXMLDoc.XML.Text;

  logDebug('Write XML Done');
  LNode := nil;
  lXMLDoc := nil;
end;



function TXML_Helper.ReadClient(Value: string): TClientObj;
var
  LNode : IXMLNode;
  lXMLDoc: IXMLDocument;
  version : string;
begin
     Result := nil;

     lXMLDoc := MakeXMLDoc(value);
     logDebug('Make doc Done');

     LNode :=  lXMLDoc.ChildNodes.FindNode('BKClientFile');

     logDebug('Find Client Done ');
     if not assigned(Lnode) then
        raise Exception.Create('BKClientFile Node not found');

     if not lnode.HasAttribute('Version') then
        raise Exception.Create('Version not found');

     // This Code may Change over time
     version := format('%d',[BK_FILE_VERSION]);
     if not SameText(version,LNode.Attributes['Version']) then
         raise Exception.Create(format('Versions not the same; XML is %s, Expected %s ',[LNode.Attributes['Version'], version]));

     Result := TClientObj.Create;
     logDebug('Make Client Done ');
     // All Good have a Go...
     ReadFromNode(Result,LNode);

     lXMLDoc := nil;
end;








end.
