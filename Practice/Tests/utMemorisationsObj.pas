unit utMemorisationsObj;
{$TYPEINFO ON} //Needed for classes with published methods
interface
uses
  TestFramework,  //DUnit
  MemorisationsObj;

type
  TTestMethod = procedure of object;

type
 TMemorisationsTestCase = class(TTestCase)
 private
   FMemorisationsList : TMemorisations_List;
   FOrder : integer;
   function AddMemorisation( aTypeNo : integer) : TMemorisation;
 protected
   procedure Setup; override;
   procedure TearDown; override;
   procedure CheckException(AMethod: TTestMethod; AExceptionClass: ExceptionClass);
 published
   procedure AddAndRemoveAMemorisation;
   procedure AddAndRemoveMemorisationLines;
   procedure AddAndRemoveAMemorisationWithLines;
   procedure AddMultipleMemorisations;
   procedure TestSequenceNumberAssigned;
   procedure TestStandardInsert;
   procedure Resequence;
   procedure TestLinksAreUpdated;
   procedure MastersAreDumped;
   procedure SwapItems;
   procedure LoadAndSaveToStream;
 end;

 TMasterMemorisationsTestCase = class(TTestCase)
 private
//   FMasterMemsList : TMaster_Memorisations_List;
 protected
   procedure Setup; override;
   procedure TearDown; override;
 published
   procedure LoadAndSaveToFile;
 end;

implementation
uses
  sysUtils,
  bkDefs,
  bkmlio,
  Tokens,
  ioStream, ECollect, bk5except,
  globals,
  bkConst,
  DBCreate,
  Admin32,
  SYDEFS,
  SystemMemorisationList,
  AuditMgr,
  SysObj32;

{ TMemorisationsTestCase }

procedure TMemorisationsTestCase.AddAndRemoveAMemorisation;
var
  NewMemorisation : TMemorisation;
  Count : integer;
begin
  Count := FMemorisationsList.ItemCount;

  NewMemorisation := TMemorisation.Create(SystemAuditMgr);
  FMemorisationsList.Insert_Memorisation(NewMemorisation);
  CheckEquals( Count + 1, FMemorisationsList.ItemCount, '1 added');

  FMemorisationsList.DelFreeItem(NewMemorisation);
  CheckEquals( Count, FMemorisationsList.ItemCount, '1 added and removed');
end;

procedure TMemorisationsTestCase.AddAndRemoveAMemorisationWithLines;
var
  NewMemorisation : TMemorisation;
  NewLine : pMemorisation_Line_Rec;
  Count : integer;
begin
  Count := FMemorisationsList.ItemCount;

  NewMemorisation := TMemorisation.Create(SystemAuditMgr);
  NewMemorisation.mdFields.mdReference := 'REF';
  NewMemorisation.mdFields.mdMatch_on_Refce := True;

  NewLine := bkmlio.New_Memorisation_Line_Rec;
  NewLine.mlAccount := '230';
  NewLine.mlPercentage := 70;
  NewMemorisation.mdLines.Insert(NewLine);

  NewLine := bkmlio.New_Memorisation_Line_Rec;
  NewLine.mlAccount := '231';
  NewLine.mlPercentage := 30;
  NewMemorisation.mdLines.Insert(NewLine);

  FMemorisationsList.Insert_Memorisation(NewMemorisation);

  CheckEquals( Count + 1, FMemorisationsList.ItemCount, 'item added and deleted');
end;

procedure TMemorisationsTestCase.AddAndRemoveMemorisationLines;
var
  LinesList : TMemorisationLinesList;
  NewLine : pMemorisation_Line_Rec;
begin
  LinesList := TMemorisationLinesList.create(SystemAuditMgr);
  try
    NewLine := bkmlio.New_Memorisation_Line_Rec;
    NewLine.mlAccount := '230';
    NewLine.mlPercentage := 70;
    LinesList.Insert(NewLine);

    NewLine := bkmlio.New_Memorisation_Line_Rec;
    NewLine.mlAccount := '231';
    NewLine.mlPercentage := 30;
    LinesList.Insert(NewLine);

    CheckEquals(  2,LinesList.ItemCount, 'Check List has both lines');

    LinesList.FreeAll;
    CheckEquals( 0,  LinesList.ItemCount, 'Check List is Empty');
  finally
    LinesList.Free;
  end;
end;

function TMemorisationsTestCase.AddMemorisation( aTypeNo : integer) : TMemorisation;
var
  NewMemorisation : TMemorisation;
begin
  NewMemorisation := TMemorisation.Create(SystemAuditMgr);
  NewMemorisation.mdFields.mdType := aTypeNo;
  NewMemorisation.mdFields.mdTemp_Tag := FOrder;
  FMemorisationsList.Insert_Memorisation(NewMemorisation);
  FOrder := FOrder + 1;
  result := NewMemorisation;
end;

procedure TMemorisationsTestCase.AddMultipleMemorisations;
var
  NewMemorisation : TMemorisation;
begin
  NewMemorisation := TMemorisation.Create(SystemAuditMgr);
  FMemorisationsList.Insert_Memorisation(NewMemorisation);

  NewMemorisation := TMemorisation.Create(SystemAuditMgr);
  FMemorisationsList.Insert_Memorisation(NewMemorisation);

  NewMemorisation := TMemorisation.Create(SystemAuditMgr);
  NewMemorisation.mdFields.mdFrom_Master_List := true;
  FMemorisationsList.Insert_Memorisation(NewMemorisation);

  FMemorisationsList.CheckIntegrity;
end;

procedure TMemorisationsTestCase.CheckException(AMethod: TTestMethod;
  AExceptionClass: ExceptionClass);
begin
  try
    AMethod;
    fail('Expected exception not raised');
  except
    on E: Exception do
    begin
      if E.ClassType <> AExceptionClass then
        raise;
    end
  end;
end;

procedure TMemorisationsTestCase.LoadAndSaveToStream;
var
  Token : Integer;
  S : TIOStream;
  CRCAfterInsert : LongWord;
  CRCAfterReload : LongWord;
  NewMemorisation : TMemorisation;
  NewLine : pMemorisation_Line_Rec;
begin
  CRCAfterReload := 0;
  CRCAfterInsert := 0;

  NewMemorisation := TMemorisation.Create(SystemAuditMgr);
  NewMemorisation.mdFields.mdReference := 'REF 1';
  NewMemorisation.mdFields.mdMatch_on_Refce := True;
  FMemorisationsList.Insert_Memorisation(NewMemorisation);

  NewLine := bkmlio.New_Memorisation_Line_Rec;
  NewLine.mlAccount := '230';
  NewLine.mlPercentage := 5000;
  NewMemorisation.mdLines.Insert(NewLine);

  NewLine := bkmlio.New_Memorisation_Line_Rec;
  NewLine.mlAccount := '230';
  NewLine.mlPercentage := 5000;
  NewMemorisation.mdLines.Insert(NewLine);

  NewMemorisation := TMemorisation.Create(SystemAuditMgr);
  NewMemorisation.mdFields.mdReference := 'REF 2';
  NewMemorisation.mdFields.mdMatch_on_Refce := True;
  FMemorisationsList.Insert_Memorisation(NewMemorisation);

  NewLine := bkmlio.New_Memorisation_Line_Rec;
  NewLine.mlAccount := '230';
  NewLine.mlPercentage := 5000;
  NewMemorisation.mdLines.Insert(NewLine);

  NewLine := bkmlio.New_Memorisation_Line_Rec;
  NewLine.mlAccount := '230';
  NewLine.mlPercentage := 5000;
  NewMemorisation.mdLines.Insert(NewLine);

  FMemorisationsList.UpdateCRC( CRCAfterInsert);

  S := TIOStream.Create;
  try
    FMemorisationsList.SaveToStream(S);
    FMemorisationsList.FreeAll;
    S.Position := 0;
    Token := S.ReadToken;
    CheckEquals( tkBeginMemorisationsList, Token, 'Start Memorisation list token wrong');
    FMemorisationsList.LoadFromStream(S);
    FMemorisationsList.UpdateCRC( CRCAfterReload);
    CheckEquals( CRCAfterInsert, CRCAfterReload , 'Check CRC after reload');
  finally
    S.Free;
  end;
end;

procedure TMemorisationsTestCase.MastersAreDumped;
var
  MX : TMemorisation;
begin
  AddMemorisation( 1);
  AddMemorisation( 1);
  MX := AddMemorisation( 1);
  MX.mdFields.mdFrom_Master_List := true;
  MX := AddMemorisation( 2);
  MX.mdFields.mdFrom_Master_List := true;

  CheckEquals( FMemorisationsList.ItemCount, 4);
  FMemorisationsList.DumpMasters;
  CheckEquals( FMemorisationsList.ItemCount, 2);
  FMemorisationsList.CheckIntegrity;
end;

procedure TMemorisationsTestCase.Resequence;
var
  i :integer;
begin
  with FMemorisationsList do
    for i := (First + 1) to Last do
      Check(Memorisation_At(i).mdFields.mdSequence_No > Memorisation_At(i - 1).mdFields.mdSequence_No, 'Out of sequence');
end;

procedure TMemorisationsTestCase.Setup;
begin
  inherited;
  NewAdminSystem(whNewZealand, 'MEMTEST', 'Test Admin system for unit testing');
  FMemorisationsList := TMemorisations_List.Create;
  FOrder := 1;
end;

procedure TMemorisationsTestCase.SwapItems;
var
  Mem1, Mem2 : TMemorisation;
  Seq1, Seq2 : integer;
begin
  Mem1 := TMemorisation.Create(SystemAuditMgr);
  Mem1.mdFields.mdReference := 'REF1';
  FMemorisationsList.Insert_Memorisation(Mem1);
  Seq1 := Mem1.mdFields.mdSequence_No;

  Mem2 := TMemorisation.Create(SystemAuditMgr);
  Mem2.mdFields.mdReference := 'REF2';
  FMemorisationsList.Insert_Memorisation(Mem2);
  Seq2 := Mem2.mdFields.mdSequence_No;

  FMemorisationsList.SwapItems( Mem1, Mem2);

  CheckEquals( FMemorisationsList.Memorisation_At(0).mdFields.mdReference, 'REF2');
  CheckEquals( FMemorisationsList.Memorisation_At(1).mdFields.mdReference, 'REF1');
  CheckEquals( FMemorisationsList.Memorisation_At(0).mdFields.mdSequence_No, Seq1);
  CheckEquals( FMemorisationsList.Memorisation_At(1).mdFields.mdSequence_No, Seq2);
end;

procedure TMemorisationsTestCase.TearDown;
begin
  FMemorisationsList.Free;
  FreeAndNil(AdminSystem);
  inherited;
end;

procedure TMemorisationsTestCase.TestLinksAreUpdated;
var
  MX : TMemorisation;
  MXNext : TMemorisation;
begin
  AddMemorisation(1); //1
  AddMemorisation(1); //2
  AddMemorisation(2); //3
  AddMemorisation(3); //4
  AddMemorisation(3); //5
  AddMemorisation(3); //6

  FMemorisationsList.UpdateLinkedLists;

  //check correct entry types at start of list
  CheckEquals( FMemorisationsList.mxFirstByEntryType[ 1].mdFields.mdType, 1);
  CheckEquals( FMemorisationsList.mxFirstByEntryType[ 2].mdFields.mdType, 2);
  CheckEquals( FMemorisationsList.mxFirstByEntryType[ 3].mdFields.mdType, 3);
  CheckNull( FMemorisationsList.mxFirstByEntryType[ 4]);

  //check order
  MX := FMemorisationsList.mxFirstByEntryType[ 3];
  while ( mx <> nil) do
    begin
      MXNext := TMemorisation( MX.mdFields.mdNext_Memorisation);
      if Assigned( MXNext) then
        begin
          Check( MXNext.mdFields.mdTemp_Tag < MX.mdFields.mdTemp_Tag, 'FirstByEntryType out of order');
        end;

      MX := TMemorisation( MX.mdFields.mdNext_Memorisation);
    end;

  //check correct entry types at start of list
  CheckEquals( FMemorisationsList.mxLastByEntryType[ 1].mdFields.mdType, 1);
  CheckEquals( FMemorisationsList.mxLastByEntryType[ 2].mdFields.mdType, 2);
  CheckEquals( FMemorisationsList.mxLastByEntryType[ 3].mdFields.mdType, 3);
  CheckNull( FMemorisationsList.mxLastByEntryType[ 4]);

  //check order
  CheckEquals( FMemorisationsList.mxLastByEntryType[ 3].mdFields.mdTemp_Tag, 4);
end;

procedure TMemorisationsTestCase.TestSequenceNumberAssigned;
var
  NewMemorisation : TMemorisation;
  Seq1, Seq2 : integer;
begin
  NewMemorisation := TMemorisation.Create(SystemAuditMgr);
  FMemorisationsList.Insert_Memorisation(NewMemorisation);
  Seq1 := NewMemorisation.mdFields.mdSequence_No;

  NewMemorisation := TMemorisation.Create(SystemAuditMgr);
  FMemorisationsList.Insert_Memorisation(NewMemorisation);
  Seq2 := NewMemorisation.mdFields.mdSequence_No;

  Check( Seq1 <> Seq2, 'Sequence number are the same');
end;

procedure TMemorisationsTestCase.TestStandardInsert;
begin
  try
    FMemorisationsList.Insert( nil);
    Fail( 'No exception raised');
  except
    On E : Exception do
      if E.ClassType <> EInvalidCall then
        raise;
  end;
end;

{ TMasterMemorisationsTestCase }

procedure TMasterMemorisationsTestCase.LoadAndSaveToFile;
const
  BANK_PREFIX = 'AA';
var
  MasterMemList: TMemorisations_List;
  SystemMemorisation: pSystem_Memorisation_List_Rec;
  NewMemorisation : TMemorisation;
  NewLine : pMemorisation_Line_Rec;
begin
  //Create a new System memorisation list
  MasterMemList := TMemorisations_List.Create(SystemAuditMgr);
  try
    SystemMemorisation := AdminSystem.SystemMemorisationList.AddMemorisation(BANK_PREFIX, MasterMemList);
  finally
    MasterMemList.Free;
  end;
  MasterMemList := TMemorisations_List(SystemMemorisation.smMemorisations);

  //Memorisation 1.
  NewMemorisation := TMemorisation.Create(SystemAuditMgr);
  NewMemorisation.mdFields.mdSequence_No := 1;
  NewMemorisation.mdFields.mdReference := 'REF 1';
  NewMemorisation.mdFields.mdMatch_on_Refce := True;
  NewMemorisation.mdFields.mdFrom_Master_List := true;
  //Memorisation line 1
  NewLine := bkmlio.New_Memorisation_Line_Rec;
  NewLine.mlAccount := '200';
  NewLine.mlPercentage := 5000;
  NewMemorisation.mdLines.Insert(NewLine);
  //Memorisation line 2
  NewLine := bkmlio.New_Memorisation_Line_Rec;
  NewLine.mlAccount := '210';
  NewLine.mlPercentage := 5000;
  NewMemorisation.mdLines.Insert(NewLine);
  //Insert mem
  MasterMemList.Insert_Memorisation(NewMemorisation);

  //Memorisation 2.
  NewMemorisation := TMemorisation.Create(SystemAuditMgr);
  NewMemorisation.mdFields.mdSequence_No := 2;
  NewMemorisation.mdFields.mdReference := 'REF 2';
  NewMemorisation.mdFields.mdMatch_on_Refce := True;
  NewMemorisation.mdFields.mdFrom_Master_List := true;
  //Memorisation line 1
  NewLine := bkmlio.New_Memorisation_Line_Rec;
  NewLine.mlAccount := '220';
  NewLine.mlPercentage := 5000;
  NewMemorisation.mdLines.Insert(NewLine);
  //Memorisation line 2
  NewLine := bkmlio.New_Memorisation_Line_Rec;
  NewLine.mlAccount := '230';
  NewLine.mlPercentage := 5000;
  NewMemorisation.mdLines.Insert(NewLine);
  //Insert mem
  MasterMemList.Insert_Memorisation(NewMemorisation);


  //Save and free Admin System
  AdminSystem.Save;
  FreeAndNil(AdminSystem);

  //Reload Admin System
  AdminSystem := TSystemObj.Create;
  AdminSystem.TestSystemFileName := DATADIR + 'TESTSYSTEM.DB';
  AdminSystem.Open;

  //Tests
  CheckEquals(AdminSystem.SystemMemorisationList.ItemCount, 1, 'Check system memorisation list count after reload');
  SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(BANK_PREFIX);
  if Assigned(SystemMemorisation) then begin
    MasterMemList := TMemorisations_List(SystemMemorisation.smMemorisations);
    if assigned(MasterMemList) then begin
      CheckEquals(MasterMemList.ItemCount, 2, 'Check memorisation count after reload');
      //Check mem 1
      NewMemorisation := MasterMemList.Memorisation_At(0);
      if Assigned(NewMemorisation) then begin
        CheckEquals(NewMemorisation.mdFields.mdSequence_No, 1, 'Check memorisation 1 sequence number');
        CheckEquals(NewMemorisation.mdFields.mdReference, 'REF 1', 'Check memorisation 1 reference');
        CheckEquals(NewMemorisation.mdFields.mdMatch_on_Refce, True, 'Check memorisation 1 match on reference');
        CheckEquals(NewMemorisation.mdFields.mdFrom_Master_List, True, 'Check memorisation 1 is master mem');
      end else
        Fail('Master memorisation not found');
      //Check mem 2
      NewMemorisation := MasterMemList.Memorisation_At(1);
      if Assigned(NewMemorisation) then begin
        CheckEquals(NewMemorisation.mdFields.mdSequence_No, 2, 'Check memorisation 2 sequence number');
        CheckEquals(NewMemorisation.mdFields.mdReference, 'REF 2', 'Check memorisation 2 reference');
        CheckEquals(NewMemorisation.mdFields.mdMatch_on_Refce, True, 'Check memorisation 2 match on reference');
        CheckEquals(NewMemorisation.mdFields.mdFrom_Master_List, True, 'Check memorisation 2 is master mem');
      end else
        Fail('Master memorisation not found');
    end else
      Fail('Master memorisation list not found');
  end else
    Fail('System memorisation list for bank prefix ' + BANK_PREFIX + ' not found');
end;

procedure TMasterMemorisationsTestCase.Setup;
begin
  inherited;
  NewAdminSystem(whNewZealand, 'MEMTEST', 'Test Admin system for unit testing');
  AdminSystem.TestSystemFileName := DATADIR + 'TESTSYSTEM.DB';
  AdminSystem.Save;
//  FMasterMemsList := TMaster_Memorisations_List.Create( 'ZZ');
end;

procedure TMasterMemorisationsTestCase.TearDown;
begin
//  FMasterMemsList.Free;
  FreeAndNil(AdminSystem);
  inherited;
end;

initialization
  TestFramework.RegisterTest(TMemorisationsTestCase.Suite);
  TestFramework.RegisterTest(TMasterMemorisationsTestCase.Suite);
end.
