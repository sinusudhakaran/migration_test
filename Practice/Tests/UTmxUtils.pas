unit UTmxUtils;
{$TYPEINFO ON} //Needed for classes with published methods
interface
uses
  SysUtils,
  TestFramework,  //DUnit
  PayeeObj,
  MemorisationsObj;

type
 TAutoCodeTests = class(TTestCase)
 private

 protected
   procedure Setup; override;
   procedure TearDown; override;
 published
   procedure TestPayeeSplitWithSimplePayee;
   procedure TestPayeeSplitWithDollarLines;

   procedure TestMemsWithSimpleMem;
   procedure TestMemsWithDollarLines;
 end;

implementation
uses
  mxUtils, bkdefs, bkplio, bkmlio, bkconst, moneydef, AuditMgr, DBCreate,
  Globals;

{ TAutoCodeTests }

procedure TAutoCodeTests.TestPayeeSplitWithSimplePayee;
//test payee split routine
//create dummy payee
var
  aPayee : TPayee;
  NewLine : pPayee_Line_Rec;
  SplitArray : mxUtils.PayeeSplitTotals;
  PercentArray: mxUtils.PayeeSplitPercentages;
  i : integer;
  Total : Money;
  Amount : Money;
begin
  aPayee := TPayee.Create;
  try
    aPayee.pdFields.pdNumber := 1;
    aPayee.pdFields.pdName := 'TESTPAYEE';

    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '230';
    NewLine.plPercentage := 7000;
    NewLine.plLine_Type := bkconst.pltPercentage;

    aPayee.pdLines.Insert(NewLine);

    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '231';
    NewLine.plPercentage := 3000;
    NewLine.plLine_Type := bkconst.pltPercentage;

    aPayee.pdLines.Insert(NewLine);

    Amount := 1234567;
    mxUtils.PayeePercentageSplit( Amount, aPayee, SplitArray, PercentArray);

    Total := 0;
    for i := Low( SplitArray) to High( SplitArray) do
      Total := Total + SplitArray[i];

    Check( Total = Amount, 'Total <> Amount');
    Check( High( SplitArray) = 1, 'Wrong number of lines');
  finally
    aPayee.Free;
  end;
end;

procedure TAutoCodeTests.TestPayeeSplitWithDollarLines;
//test payee split routine
//create dummy payee
var
  aPayee : TPayee;
  NewLine : pPayee_Line_Rec;
  SplitArray : mxUtils.PayeeSplitTotals;
  PercentArray: mxUtils.PayeeSplitPercentages;
  i : integer;
  Total : Money;
  Amount : Money;
begin
  aPayee := TPayee.Create;
  try
    aPayee.pdFields.pdNumber := 1;
    aPayee.pdFields.pdName := 'TESTPAYEE';

    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '230';
    NewLine.plPercentage := 700000;
    NewLine.plLine_Type := bkconst.pltPercentage;

    aPayee.pdLines.Insert(NewLine);

    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '231';
    NewLine.plPercentage := 300000;
    NewLine.plLine_Type := bkconst.pltPercentage;

    aPayee.pdLines.Insert(NewLine);

    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '';
    NewLine.plPercentage := 1000;
    NewLine.plLine_Type := bkconst.pltPercentage;

    aPayee.pdLines.Insert(NewLine);

    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '232';
    NewLine.plPercentage := 5000;
    NewLine.plLine_Type := bkconst.pltDollarAmt;

    aPayee.pdLines.Insert(NewLine);

    Amount := 1234567;
    mxUtils.PayeePercentageSplit( Amount, aPayee, SplitArray, PercentArray);

    Total := 0;
    for i := Low( SplitArray) to High( SplitArray) do
      Total := Total + SplitArray[i];

    Check( Total = Amount, 'Total <> Amount');
    CheckEquals( SplitArray[0], Round((Amount - 5000) * 0.7), '70% amount incorrect');
    CheckEquals( SplitArray[1], Round((Amount - 5000) * 0.3), '30% amount incorrect');
    CheckEquals( SplitArray[2], 0, 'Blank line not zero');
    CheckEquals( SplitArray[3] , 5000, 'Dollar Amount Incorrect');


  finally
    aPayee.Free;
  end;
end;


procedure TAutoCodeTests.Setup;
begin
  inherited;
  NewAdminSystem(whNewZealand, 'MEMTEST', 'Test Admin system for unit testing');
end;

procedure TAutoCodeTests.TearDown;
begin
  FreeAndNil(AdminSystem);

  inherited;
end;

procedure TAutoCodeTests.TestMemsWithDollarLines;
var
  NewMemorisation : TMemorisation;
  NewLine : pMemorisation_Line_Rec;
  SplitArray : mxUtils.MemSplitTotals;
  PercentArray: mxUtils.MemSplitPercentages;
  i : integer;
  Total : Money;
  Amount : Money;
begin
  NewMemorisation := TMemorisation.Create(SystemAuditMgr);
  try
    NewMemorisation := TMemorisation.Create(SystemAuditMgr);
    NewMemorisation.mdFields.mdReference := 'REF 1';
    NewMemorisation.mdFields.mdMatch_on_Refce := True;

    NewLine := bkmlio.New_Memorisation_Line_Rec;
    NewLine.mlAccount := '230';
    NewLine.mlPercentage := 700000;
    NewLine.mlLine_Type := bkconst.mltPercentage;
    NewMemorisation.mdLines.Insert(NewLine);

    NewLine := bkmlio.New_Memorisation_Line_Rec;
    NewLine.mlAccount := '231';
    NewLine.mlPercentage := 300000;
    NewLine.mlLine_Type := bkconst.mltPercentage;
    NewMemorisation.mdLines.Insert(NewLine);

    NewLine := bkmlio.New_Memorisation_Line_Rec;
    NewLine.mlAccount := '';
    NewLine.mlPercentage := 10000;
    NewLine.mlLine_Type := bkconst.mltPercentage;
    NewMemorisation.mdLines.Insert(NewLine);

    NewLine := bkmlio.New_Memorisation_Line_Rec;
    NewLine.mlAccount := '232';
    NewLine.mlPercentage := 1000;
    NewLine.mlLine_Type := bkconst.mltDollarAmt;
    NewMemorisation.mdLines.Insert(NewLine);

    Amount := 1234567;
    mxUtils.MemorisationSplit( Amount, NewMemorisation, SplitArray, PercentArray);

    Total := 0;
    for i := Low( SplitArray) to High( SplitArray) do
      Total := Total + SplitArray[i];

    Check( Total = Amount, 'Total <> Amount');
    CheckEquals( SplitArray[0], Round((Amount - 1000) * 0.7), '70% amount incorrect');
    CheckEquals( SplitArray[1], Round((Amount - 1000) * 0.3), '30% amount incorrect');
    CheckEquals( SplitArray[2], 0, 'Blank line not zero');
    CheckEquals( SplitArray[3] , 1000, 'Dollar Amount Incorrect');
    Check( High( SplitArray) = 3, 'Wrong number of lines');

  finally
    NewMemorisation.Free;
  end;
end;

procedure TAutoCodeTests.TestMemsWithSimpleMem;
var
  NewMemorisation : TMemorisation;
  NewLine : pMemorisation_Line_Rec;
  SplitArray : mxUtils.MemSplitTotals;
  PercentArray: mxUtils.MemSplitPercentages;
  i : integer;
  Total : Money;
  Amount : Money;
begin
  NewMemorisation := TMemorisation.Create(SystemAuditMgr);
  try
    NewMemorisation := TMemorisation.Create(SystemAuditMgr);
    NewMemorisation.mdFields.mdReference := 'REF 1';
    NewMemorisation.mdFields.mdMatch_on_Refce := True;

    NewLine := bkmlio.New_Memorisation_Line_Rec;
    NewLine.mlAccount := '230';
    NewLine.mlPercentage := 700000;
    NewLine.mlLine_Type := bkconst.mltPercentage;
    NewMemorisation.mdLines.Insert(NewLine);

    NewLine := bkmlio.New_Memorisation_Line_Rec;
    NewLine.mlAccount := '231';
    NewLine.mlPercentage := 300000;
    NewLine.mlLine_Type := bkconst.mltPercentage;
    NewMemorisation.mdLines.Insert(NewLine);

    Amount := 1234567;
    mxUtils.MemorisationSplit( Amount, NewMemorisation, SplitArray, PercentArray);

    Total := 0;
    for i := Low( SplitArray) to High( SplitArray) do
      Total := Total + SplitArray[i];

    Check( Total = Amount, 'Total <> Amount');
    CheckEquals( SplitArray[0], Round((Amount) * 0.7), '70% amount incorrect');
    CheckEquals( SplitArray[1], Round((Amount) * 0.3), '30% amount incorrect');
    Check( High( SplitArray) = 1, 'Wrong number of lines');

  finally
    NewMemorisation.Free;
  end;
end;

initialization
  TestFramework.RegisterTest(TAutoCodeTests.Suite);
end.
