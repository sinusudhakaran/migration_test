unit utToDo;
{$TYPEINFO ON} //Needed for classes with published methods

interface

uses
  TestFramework,
  ToDoListUnit;

type
  TToDoTest = class(TTestCase)
  private
    fList: TClientToDoList;

  public
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure TestEditedCount;
    procedure TestPendingCount;
    procedure TestOverdueCount;
    procedure TestNextToDo;
    procedure TestFind;
    procedure TestLoadSave;
    procedure TestSort;
  end;

implementation

uses
  SysUtils,
  StDate;

{ TToDoTest }

procedure TToDoTest.SetUp;
begin
  fList := TClientToDoList.Create;

  { Setup for use with sorting, LRNs should be index+1
    Note: tdTemp_Edited needs to be set to true, or it won't save
  }

  with fList.AddToDoItem^ do
  begin
    tdLRN            := 1;
    tdDate_Entered   := 2013;
    tdTime_Entered   := 5;
    tdEntered_By     := 'Albert';
    tdDescription    := 'Test 1';
    tdReminderDate   := 2014;
    tdDate_Completed := 0;
    tdIs_Completed   := false;
    tdTemp_Edited    := true;
  end;

  with fList.AddToDoItem^ do
  begin
    tdLRN            := 3;
    tdDate_Entered   := 2012;
    tdTime_Entered   := 5;
    tdEntered_By     := 'Kris';
    tdDescription    := 'Test 2';
    tdReminderDate   := 2013;
    tdDate_Completed := 0;
    tdIs_Completed   := false;
    tdTemp_Edited    := true;
  end;

  with fList.AddToDoItem^ do
  begin
    tdLRN            := 2;
    tdDate_Entered   := 2011;
    tdTime_Entered   := 5;
    tdEntered_By     := 'Bert';
    tdDescription    := 'Test 3';
    tdReminderDate   := CurrentDate;
    tdDate_Completed := 2013;
    tdIs_Completed   := false;
    tdTemp_Edited    := true;
  end;

  // Note: adding more, you must also update TestEditedCount and TestPendingCount
end;

procedure TToDoTest.TearDown;
begin
  FreeAndNil(fList);
end;

procedure TToDoTest.TestEditedCount;
begin
  Check(fList.EditedCount = 3, 'Otherwise the Save won''t work either');
end;

procedure TToDoTest.TestPendingCount;
begin
  Check(fList.PendingCount = 2, 'Only two items are pending');
end;

procedure TToDoTest.TestOverdueCount;
begin
  Check(fList.OverdueCount = 2, 'Only one item is overdue');
end;

procedure TToDoTest.TestNextToDo;
var
  pItem: pClientToDoItem;
begin
  pItem := fList.GetNextItemDue;
  Check(pItem.tdLRN = 3, 'Error finding the next ToDo item');
end;

procedure TToDoTest.TestFind;
var
  pItem: pClientToDoItem;
begin
  pItem := fList.FindItemByLRN(1);
  Check(pItem.tdLRN = 1, 'Not found the right item');
end;

procedure TToDoTest.TestLoadSave;
var
  arrLRNs: array of LongWord;
  i: integer;
  pItem: pClientToDoItem;
  iLength: integer;
begin
  SetLength(arrLRNs, fList.Count);
  for i := 0 to fList.Count-1 do
  begin
    pItem := fList.ToDoItemAt(i);
    arrLRNs[i] := pItem.tdLRN;
  end;

  fList.SaveToFile;
  fList.Clear;
  fList.LoadFromFile;

  iLength := Length(arrLRNs);
  Check(fList.Count = iLength, 'Load/Save size not the same');
  for i := 0 to fList.Count-1 do
  begin
    pItem := fList.ToDoItemAt(i);
    Check(pItem.tdLRN = arrLRNs[i], 'Not loading the same data');
  end;
end;

procedure TToDoTest.TestSort;
var
  i: integer;
  pItem: pClientToDoItem;
begin
  fList.SortBy(tdSortByEnteredBy);
  for i := 0 to fList.Count-1 do
  begin
    pItem := fList.ToDoItemAt(i);
    Check(pItem.tdLRN = LongWord(i+1), 'Should be sorted by LRN now');
  end;
end;

initialization
begin
  TestFramework.RegisterTest(TToDoTest.Suite);
end;

end.