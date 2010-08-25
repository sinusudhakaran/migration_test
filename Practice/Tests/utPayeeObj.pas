unit utPayeeObj;
{$TYPEINFO ON} //Needed for classes with published methods
interface
uses
  TestFramework,  //DUnit
  PayeeObj;

type
 TPayeesTestCase = class(TTestCase)
 private
   FPayeeList : TPayee_List;
 protected
   procedure Setup; override;
   procedure TearDown; override;
 published
   procedure AddAndRemoveAPayee;
   procedure AddAndRemovePayeeLines;
   procedure AddAndRemoveAPayeeWithLines;

   procedure LoadAndSaveToStream;
   procedure FindAPayeeByName;
   procedure FindAPayeeByNumber;
 end;

implementation
uses
  bkDefs,
  bkplio,
  Tokens,
  ioStream, ECollect;

{ TPayeesTestCase }

procedure TPayeesTestCase.AddAndRemoveAPayee;
var
  NewPayee : TPayee;
  Count : integer;
begin
  Count := FPayeeList.ItemCount;

  NewPayee := TPayee.Create;
  FPayeeList.Insert(NewPayee);
  FPayeeList.DelFreeItem(NewPayee);
  Check( FPayeeList.ItemCount = Count);
end;

procedure TPayeesTestCase.AddAndRemoveAPayeeWithLines;
var
  NewPayee : TPayee;
  NewLine : pPayee_Line_Rec;
begin
  NewPayee := TPayee.Create;
  NewPayee.pdFields.pdName := 'TEST PAYEE';
  NewPayee.pdFields.pdNumber := 1;
  FPayeeList.Insert(NewPayee);
  NewLine := bkplio.New_Payee_Line_Rec;
  NewLine.plAccount := '230';
  NewLine.plPercentage := 5000;
  NewPayee.pdLines.Insert(NewLine);

  NewLine := bkplio.New_Payee_Line_Rec;
  NewLine.plAccount := '230';
  NewLine.plPercentage := 5000;
  NewPayee.pdLines.Insert(NewLine);

  Check( NewPayee.pdLines.ItemCount = 2, 'NewPayee.pdLines.ItemCount = 2');

  FPayeeList.DelFreeItem(NewPayee);
end;

procedure TPayeesTestCase.AddAndRemovePayeeLines;
var
  LinesList : TPayeeLinesList;
  NewLine : pPayee_Line_Rec;
begin
  LinesList := TPayeeLinesList.create;
  try
    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '230';
    NewLine.plPercentage := 5000;
    LinesList.Insert(NewLine);

    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '230';
    NewLine.plPercentage := 5000;
    LinesList.Insert(NewLine);

    LinesList.FreeAll;
    Check( LinesList.ItemCount = 0, 'LinesList.ItemCount = 0');
  finally
    LinesList.Free;
  end;
end;

procedure TPayeesTestCase.FindAPayeeByName;
var
  aPayee : TPayee;
begin
  aPayee := TPayee.Create;
  aPayee.pdFields.pdName := 'TEST PAYEE 1';
  aPayee.pdFields.pdNumber := 1;
  FPayeeList.Insert(aPayee);

  aPayee := TPayee.Create;
  aPayee.pdFields.pdName := 'TEST PAYEE 2';
  aPayee.pdFields.pdNumber := 2;
  FPayeeList.Insert(aPayee);

  Check(FPayeeList.Find_Payee_Name('TEST PAYEE 1').pdNAme = 'TEST PAYEE 1', 'Find By Payee Name 1');
  Check(FPayeeList.Find_Payee_Name('TEST PAYEE 2').pdName = 'TEST PAYEE 2', 'Find By Payee Name 1');
end;

procedure TPayeesTestCase.FindAPayeeByNumber;
var
  aPayee : TPayee;
begin
  aPayee := TPayee.Create;
  aPayee.pdFields.pdName := 'TEST PAYEE 1';
  aPayee.pdFields.pdNumber := 1;
  FPayeeList.Insert(aPayee);

  aPayee := TPayee.Create;
  aPayee.pdFields.pdName := 'TEST PAYEE 2';
  aPayee.pdFields.pdNumber := 2;
  FPayeeList.Insert(aPayee);

  Check(FPayeeList.Find_Payee_Number(1).pdNumber = 1, 'Find By Payee Number 1');
  Check(FPayeeList.Find_Payee_Number(2).pdNumber = 2, 'Find By Payee Number 2');
end;

procedure TPayeesTestCase.LoadAndSaveToStream;
var
  Token : byte;
  S : TIOStream;
  CRCAfterInsert : LongWord;
  CRCAfterReload : LongWord;
  NewPayee : TPayee;
  NewLine : pPayee_Line_Rec;
begin
  CRCAfterReload := 0;
  CRCAfterInsert := 0;

  NewPayee := TPayee.Create;
  NewPayee.pdFields.pdName := 'TEST PAYEE 1';
  NewPayee.pdFields.pdNumber := 1;
  FPayeeList.Insert(NewPayee);

  NewLine := bkplio.New_Payee_Line_Rec;
  NewLine.plAccount := '230';
  NewLine.plPercentage := 5000;
  NewPayee.pdLines.Insert(NewLine);

  NewLine := bkplio.New_Payee_Line_Rec;
  NewLine.plAccount := '230';
  NewLine.plPercentage := 5000;
  NewPayee.pdLines.Insert(NewLine);

  NewPayee := TPayee.Create;
  NewPayee.pdFields.pdName := 'TEST PAYEE 2';
  NewPayee.pdFields.pdNumber := 2;
  FPayeeList.Insert(NewPayee);

  NewLine := bkplio.New_Payee_Line_Rec;
  NewLine.plAccount := '230';
  NewLine.plPercentage := 5000;
  NewPayee.pdLines.Insert(NewLine);

  NewLine := bkplio.New_Payee_Line_Rec;
  NewLine.plAccount := '230';
  NewLine.plPercentage := 5000;
  NewPayee.pdLines.Insert(NewLine);

  FPayeeList.UpdateCRC( CRCAfterInsert);

  S := TIOStream.Create;
  try
    FPayeeList.SaveToFile(S);
    FPayeeList.FreeAll;
    S.Position := 0;
    Token := S.ReadToken;
    Check( Token = tkBeginPayeesList, 'Start Payee list token wrong');
    FPayeeList.LoadFromFile(S);
    FPayeeList.UpdateCRC( CRCAfterReload);
    Check( CRCAfterReload = CRCAfterInsert, 'Check CRC after reload');
  finally
    S.Free;
  end;
end;

procedure TPayeesTestCase.Setup;
begin
  FPayeeList := TPayee_List.Create;
end;

procedure TPayeesTestCase.TearDown;
begin
  FPayeeList.Free;
end;

initialization
  TestFramework.RegisterTest(TPayeesTestCase.Suite);
end.

