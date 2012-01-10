unit Listhelpers;

interface
uses
BUDOBJ32,
clObj32,
baobj32,
trxList32,
MemorisationsObj,
PayeeObj,
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

public
  function MakeXML(value: TClientObj): string;

  function ReadClient(Value: string):TClientObj;
End;

procedure logDebug(msg: string);

implementation

uses
    webutils,
    LogUtil,
    sysutils,
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
   if DebugMe then
      logMsg(lmDebug,'BooksIO ListHelper',msg);
end;



{ TXML_Helper }

//-----------------------------  TClientObj ------------------------------------
procedure TXML_Helper.WriteToNode(value: TClientObj; var Node: IXMLNode);
var I: Integer;
    //BankNode: IXMLNode;
    lNode : IXMLNode;
begin

  value.clFields.WriteRecToNode(Node);
  value.clExtra.WriteRecToNode(Node);
  value.clMoreFields.WriteRecToNode(Node);

  logDebug('Start write Accounts');

  lNode := Node.AddChild('BankAccounts');
  for I := 0 to value.clBank_Account_List.last do begin

     WriteToNode(value.clBank_Account_List.Bank_Account_At(I),lNode);
  end;

  lNode := Node.AddChild('Chart');

  logDebug('Start write Chart');

  for I := 0 to value.clChart.Last do begin
     value.clChart.Account_At(I).WriteRecToNode(lNode);
  end;

  logDebug('Start write Payees');
  lNode := Node.AddChild('Payees');
  for I := 0 to value.clPayee_List.Last do begin
     WriteToNode(value.clPayee_List.Payee_At(I) ,lNode);
  end;

  logDebug('Start write Jobs');
  lNode := Node.AddChild('Jobs');
  for I := 0 to value.clJobs.Last do begin
     value.clJobs.Job_At(I).WriteRecToNode(lNode);
  end;

  logDebug('Start write Budgets');
  lNode := Node.AddChild('Budgets');
  for I := 0 to value.clBudget_List.Last do begin
     WriteToNode(value.clBudget_List.Budget_At(I), lNode);
  end;

  logDebug('Start write Balances');
  lNode := Node.AddChild('Balances');
  for I := 0 to value.clBalances_List.Last do begin
     value.clBalances_List.Balances_At(I).WriteRecToNode(lNode);
  end;

  logDebug('Start write Headings');
  lNode := Node.AddChild('Headings');
  for I := 0 to value.clCustom_Headings_List.Last do begin
     value.clCustom_Headings_List.Custom_Heading_At(I).WriteRecToNode(lNode); ;
  end;

  logDebug('Start write DiskLog');
  lNode := Node.AddChild('DiskLog');
  for I := 0 to value.clDisk_Log.Last do begin
     value.clDisk_Log.Disk_Log_At(I).WriteRecToNode(lNode); ;
  end;

end;

function BankAccountCompare(Item1,Item2:Pointer):integer;
begin
   result := CompareStr(TBank_Account(Item1).baFields.baBank_Account_Number,TBank_Account(Item2).baFields.baBank_Account_Number);
end;

procedure TXML_Helper.ReadFromNode(var value: TClientObj; Node: IXMLNode);
var
   lNode: IXMLNode;
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
   value.clExtra.ReadRecFromNode(Node);
   value.clMoreFields.ReadRecFromNode(Node);

   lNode := Node.ChildNodes.FindNode('BankAccounts');
   value.clBank_Account_List.DeleteAll;
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(lNode) do begin
         nAccount := TBank_Account.Create(value);
         nAccount.baFields.baCurrency_Code := 'XXX'; // default value
         value.clBank_Account_List.Insert(nAccount);
         ReadFromNode(nAccount,LNode);
         lNode := lNode.NextSibling;
      end;
   end;
   value.clBank_Account_List.Sort(BankAccountCompare);

   lNode := Node.ChildNodes.FindNode('Payees');
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(lNode) do begin
         nPayee := tPayee.Create;
         ReadFromNode(nPayee,LNode);
         value.clPayee_List.Insert(nPayee);
         lNode := lNode.NextSibling;
      end
   end;

   lNode := Node.ChildNodes.FindNode('Jobs');
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(lNode) do begin
         nJob := New_Job_Heading_Rec;
         nJob.ReadRecFromNode(LNode);
         value.clJobs.Insert(nJob);
         lNode := lNode.NextSibling;
      end
   end;
   
   lNode := Node.ChildNodes.FindNode('Budgets');
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(lNode) do begin
         nBudget := TBudget.Create;
         ReadFromNode(nBudget, LNode);
         value.clBudget_List.Insert(nBudget);
         lNode := lNode.NextSibling;
      end
   end;

   lNode := Node.ChildNodes.FindNode('Balances');
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(lNode) do begin
         nBalance := New_Balances_rec;
         nBalance.ReadRecFromNode(lNode);
         value.clBalances_List.Insert(nBalance);
         lNode := lNode.NextSibling;
      end
   end;

   lNode := Node.ChildNodes.FindNode('Headings');
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(lNode) do begin
         nHeading := New_Custom_Heading_Rec;
         nHeading.ReadRecFromNode(lNode);
         value.clBalances_List.Insert(nHeading);
         lNode := lNode.NextSibling;
      end
   end;

   lNode := Node.ChildNodes.FindNode('DiskLog');
   if Assigned(LNode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(lNode) do begin
         nLog := New_Disk_Log_Rec;
         nLog.ReadRecFromNode(lNode);
         value.clDisk_Log.Insert(nLog);
         lNode := lNode.NextSibling;
      end
   end;
   lNode := nil;
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
var lNode : IXMLNode;
    new: PDissection_Rec;
begin
   lNode := value^.ReadRecFromNode(Node);
   if not assigned(lnode) then exit;
   lNode := Node.ChildNodes.FindNode('Dissections');
   if not assigned(lnode) then Exit;
   lnode := lnode.ChildNodes.First;
   while Assigned(lNode) do begin
       new := AddDissection(value);
       new.ReadRecFromNode(LNode);
       //pendDissection(value, new);
       LNode := LNode.NextSibling;
   end;
   lNode := nil;
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
   lNode := nil;
end;

procedure TXML_Helper.ReadFromNode(var value: TBank_Account; Node: IXMLNode);
var lNode : IXMLNode;
    new: pTransaction_Rec;
    NMem: Tmemorisation;
begin

   LNode := value.baFields.ReadRecFromNode(Node);
   if not assigned(lnode) then exit;

   lNode := Node.ChildNodes.FindNode('Transactions');
   if Assigned(lnode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(lNode) do begin
         new := new_Transaction_Rec;
         value.baTransaction_List.Insert_Transaction_Rec(new);
         ReadFromNode(new, lNode);

         LNode := LNode.NextSibling;
      end;
   end;

   lNode := Node.ChildNodes.FindNode('Memorisations');
   if Assigned(lnode) then begin
      lnode := lnode.ChildNodes.First;
      while Assigned(lNode) do begin
         NMem := Tmemorisation.Create(nil);
         ReadFromNode(NMem,LNode);
         value.baMemorisations_List.Insert_Memorisation(NMem, False);
         LNode := LNode.NextSibling;
      end;
   end;
   lNode := nil;
end;



//---------------------------  TMemorisation -----------------------------------
procedure TXML_Helper.WriteToNode(value: TMemorisation; var Node: IXMLNode);
var lNode : IXMLNode;
    I: Integer;
begin
   lNode := value.mdFields.WriteRecToNode(Node);
   lNode := LNode.AddChild('Lines');
   for I := 0 to value.mdLines.Last do begin
       value.mdLines.MemorisationLine_At(I).WriteRecToNode(LNode);
   end;
   lNode := nil;
end;

procedure TXML_Helper.ReadFromNode(var value: TMemorisation; Node: IXMLNode);
var lNode : IXMLNode;
    new: pMemorisation_Line_Rec;
begin
   lNode := value.mdFields.ReadRecFromNode(Node);
   if not assigned(lnode) then exit;
   lNode := Node.ChildNodes.FindNode('Lines');
   if not assigned(lnode) then Exit;
   lnode := lnode.ChildNodes.First;
   while Assigned(lNode) do begin
       new := new_Memorisation_Line_Rec;
       new.ReadRecFromNode(LNode);
       value.mdLines.Insert(new);
       LNode := LNode.NextSibling;
   end;
   lNode := nil;
end;


//---------------------------  TPayee ---------------------------------------
procedure TXML_Helper.WriteToNode(value: TPayee; var Node: IXMLNode);
var lNode : IXMLNode;
    I: Integer;
begin
   LNode := value.pdFields.WriteRecToNode(Node);
   lNode := Node.AddChild('Lines');
   for I := 0 to value.pdLines.Last do begin
       value.pdLines.PayeeLine_At(I).WriteRecToNode(LNode);
   end;
   lNode := nil;
end;

procedure TXML_Helper.ReadFromNode(var value: TPayee; Node: IXMLNode);
var lNode : IXMLNode;
    new: pPayee_Line_Rec;
begin
   LNode := value.pdFields.ReadRecFromNode(Node);
   if not assigned(lnode) then exit;
   lNode := LNode.ChildNodes.FindNode('Lines');
   if not assigned(lnode) then Exit;
   lnode := lnode.ChildNodes.First;
   while Assigned(lNode) do begin
       new := new_Payee_Line_Rec;
       new.ReadRecFromNode(LNode);
       value.pdLines.Insert(new);
       LNode := LNode.NextSibling;
   end;
   lNode := nil;
end;



//-----------------------------  TBudget ---------------------------------------
procedure TXML_Helper.WriteToNode(value: TBudget; var Node: IXMLNode);
var lNode : IXMLNode;
    I: Integer;
begin
   LNode := value.buFields.WriteRecToNode(Node);
   lNode := Node.AddChild('Details');
   for I := 0 to value.buDetail.Last do begin
       value.buDetail.Budget_Detail_At(I).WriteRecToNode(LNode);
   end;
   lNode := nil;
end;

procedure TXML_Helper.ReadFromNode(var value: TBudget; Node: IXMLNode);
var lNode : IXMLNode;
    new: pBudget_Detail_Rec;
begin
   LNode := value.buFields.ReadRecFromNode(Node);
   if not assigned(lnode) then exit;
   lNode := LNode.ChildNodes.FindNode('Details');
   if not assigned(lnode) then Exit;
   lnode := lnode.ChildNodes.First;
   while Assigned(lNode) do begin
       new := new_Budget_Detail_Rec;
       new.ReadRecFromNode(LNode);
       value.buDetail.Insert(new);
       LNode := LNode.NextSibling;
   end;
   lNode := nil;
end;



//---------------------------  XML direct --------------------------------------
function TXML_Helper.MakeXML(value: TClientObj): string;
var
  lNode : IXMLNode;
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
  lNode := lXMLDoc.CreateNode('BKClientFile');
  LNode.Attributes['Version'] := BK_FILE_VERSION_STR;
  //LNode.DeclareNamespace('','BankLink.Practice');

  lXMLDoc.DocumentElement := lNode;
  //lNode := lNode.AddChild('Client','BankLink.Practice');

  WriteToNode(value,lNode);


  // Return the XML String...
  Result := lXMLDoc.XML.Text;

  logDebug('Write XML Done');
  lNode := nil;
  lXMLDoc := nil;
end;

function TXML_Helper.ReadClient(Value: string): TClientObj;
var
  lNode: IXMLNode;
  lXMLDoc: IXMLDocument;
begin
  //setup XML Document
  lXMLDoc := MakeXMLDoc(value);


  Result := TClientObj.Create;
  lNode :=  lXMLDoc.ChildNodes.FindNode('BKClientFile');
  if not assigned(Lnode) then
       raise Exception.Create('No BKClientFile Node found');

  ReadFromNode(Result,LNode);

  lXMLDoc := nil;
end;








end.
