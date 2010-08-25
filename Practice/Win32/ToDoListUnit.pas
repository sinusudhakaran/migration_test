unit ToDoListUnit;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:

   Remarks:

}
//------------------------------------------------------------------------------

interface
uses
  Classes;

const
  tdSortByLRN           = 0;
  tdSortByDateEntered   = 1;
  tdSortByDescription   = 2;
  tdSortByReminderDate  = 3;
  tdSortByDateCompleted = 4;
  tdSortByEnteredBy     = 5;

type
  pClientToDoItem = ^TClientToDoItem;
  TClientToDoItem = record
    tdLRN                    : LongWord;
    tdDate_Entered           : integer;
    tdTime_Entered           : integer;
    tdEntered_By             : string[ 20];
    tdDescription            : string[ 80];
    tdReminderDate           : integer;
    tdDate_Completed         : integer;
    tdIs_Completed           : boolean;
    tdTemp_Edited            : boolean;
    tdTemp_Deleted           : boolean;
    tdTask_Type              : integer;
    tdFile_Number            : integer;
    tdSpare                  : Array[1..12] of byte;
  end;

  TClientToDoList = class( TList)
  private
    FHighest_ToDo_LRN : LongWord;
    FClientLRN  : integer;
    FLocked : boolean;
    FCurrentSortOrder : byte;

    procedure Lock;
    procedure Unlock;
  public
    constructor Create; overload;
    constructor Create( cLRN : integer; GetLock : boolean = true); overload;

    procedure LoadFromFile( GetLock : boolean = true);
    procedure SaveToFile;

    function  ToDoItemAt( index : integer) : pClientToDoItem;
    function  PendingCount : integer;
    function  EditedCount  : integer;
    function  OverdueCount : integer;
    function  AddToDoItem : pClientToDoItem;
    function  GetNextItemDue : pClientToDoItem;

    function  FindItemByLRN( aLRN : LongWord) : pClientToDoItem;
    procedure FreeAndNilItem( index : integer);

    procedure SortBy( FSortOrder : byte);

    destructor Destroy; override;
  end;

//******************************************************************************
implementation
uses
  LockUtils,
  Globals,
  DirUtils,
  sysUtils,
  stDate,
  WinUtils,
  Windows;

function CompareByLRN(Item1, Item2: pClientToDoItem): Integer;
begin
  if Item1^.tdLRN < Item2^.tdLRN then
    result := -1
  else
  if Item1^.tdLRN > Item2^.tdLRN then
    result := 1
  else
    result := 0;
end;

function CompareByDate(Item1, Item2: pClientToDoItem): Integer;
begin
  if Item1^.tdDate_Entered < Item2^.tdDate_Entered then
    result := -1
  else
  if Item1^.tdDate_Entered > Item2^.tdDate_Entered then
    result := 1
  else
  if Item1^.tdTime_Entered < Item2^.tdTime_Entered then
    result := -1
  else
  if Item1^.tdTime_Entered > Item2^.tdTime_Entered then
    result := 1
  else
    result := 0;
end;

function CompareByDesc(Item1, Item2: pClientToDoItem): Integer;
var
  s1, s2 : string;
begin
  s1 := Item1^.tdDescription;
  s2 := Item2^.tdDescription;

  result := StrLIComp( pChar( s1), pChar( s2), 10);

  if result = 0 then
    result := CompareByDate( Item1, Item2);
end;

function CompareByEntered(Item1, Item2: pClientToDoItem): Integer;
var
  s1, s2 : string;
begin
  s1 := Item1^.tdEntered_By;
  s2 := Item2^.tdEntered_By;

  result := StrLIComp( pChar( s1), pChar( s2), 10);

  if result = 0 then
    result := CompareByDate( Item1, Item2);
end;

function CompareByReminder(Item1, Item2: pClientToDoItem): Integer;
//sorts item by reminder date, note items with no date are sorted to the
//bottom of the list
begin
  if (Item1^.tdReminderDate = 0) and (Item2.tdReminderDate <> 0) then
    result := 1
  else
  if (Item1^.tdReminderDate <> 0) and (Item2.tdReminderDate = 0) then
    result := -1
  else
  if Item1^.tdReminderDate < Item2^.tdReminderDate then
    result := -1
  else
  if Item1^.tdReminderDate > Item2^.tdReminderDate then
    result := 1
  else
    result := CompareByDate( Item1, Item2);
end;

function CompareByNextToDo( Item1, Item2 : pClientToDoItem) : integer;
//similiar to compareByReminder, but sorted in order that will be used
//to pick the item to show in the client manager.
//order is
//
//   Overdue
//   Due today
//   Blank
//   Not due yet
const
  DueNow   = 0;
  NoDate   = 1;
  DueLater = 2;
var
  TodaysDate   : integer;
  Group1       : integer;
  Group2       : integer;
begin
  TodaysDate := CurrentDate;

  //split the items into group and sort first by that group
  if ( Item1^.tdReminderDate <= TodaysDate) and ( Item1.tdReminderDate <> 0) then
    Group1 := DueNow
  else if ( Item1^.tdReminderDate <> 0) then
    Group1 := DueLater
  else
    Group1 := NoDate;

  if ( Item2^.tdReminderDate <= TodaysDate) and ( Item2.tdReminderDate <> 0) then
    Group2 := DueNow
  else if ( Item2^.tdReminderDate <> 0) then
    Group2 := DueLater
  else
    Group2 := NoDate;

  //sort
  if ( Group1 < Group2) then
    result := -1
  else
  if ( Group1 > Group2) then
    result := 1
  else
  begin
    //in same group, sort by reminder date
    result := CompareByReminder( Item1, Item2);
  end;
end;

function CompareByDateComplete(Item1, Item2: pClientToDoItem): Integer;
begin
  if Item1^.tdDate_Completed < Item2^.tdDate_Completed then
    result := -1
  else
  if Item1^.tdDate_Completed > Item2^.tdDate_Completed then
    result := 1
  else
    result := CompareByDate( Item1, Item2);
end;

{ TClientToDoList }

function TClientToDoList.AddToDoItem: pClientToDoItem;
var
  Item : pClientToDoItem;
begin
  New( Item);
  Self.Add( Item);
  FillChar( Item^, SizeOf( TClientToDoItem), 0);

  result := Item;
end;

constructor TClientToDoList.Create( cLRN : integer; GetLock : boolean = true);
begin
  inherited Create;

  FClientLRN := cLRN;
  FHighest_ToDo_LRN := 0;
  FLocked := false;

  LoadFromFile( GetLock);
end;

constructor TClientToDoList.Create;
begin
  inherited Create;
end;

destructor TClientToDoList.Destroy;
var
  i : integer;
begin
  for i := ( Count - 1) downto 0 do
    FreeAndNilItem( i);

  inherited;
end;

procedure TClientToDoList.LoadFromFile( GetLock : boolean = true);
//returns false if the file was locked at time of request
var
  S : TMemoryStream;
  Filename : string;
  Item     : pClientToDoItem;
begin
  filename := DirUtils.GetTaskListFilename( FClientLRN);
  Self.Clear;

  if GetLock then
    Self.Lock;

  try
    if BKFileExists( filename) then
    begin
      S := TMemoryStream.Create;
      try
        S.LoadFromFile( filename);
        S.Position := 0;

        //read sequence number of the front
        if s.Position < s.Size then
          S.Read( FHighest_ToDo_LRN, SizeOf( LongWord));

        //now read the records
        while s.Position < s.Size do
        begin
          New( Item);
          S.Read( Item^, sizeof( TClientToDoItem));
          Self.Add( Item);
        end;
      finally
        S.Free;
      end;
    end;
  finally
    if GetLock then
      Self.Unlock;
  end;
end;

procedure TClientToDoList.Lock;
//except raised if lock could not be obtained
begin
  Assert( FLocked = false, 'ToDo List already locked');

  ObtainLock( ltClientToDoList, FClientLRN, Globals.PRACINI_TicksToWaitForAdmin div 1000);
  FLocked := true;
end;

function TClientToDoList.PendingCount: integer;
var
  i : integer;
begin
  result := 0;
  for i := 0 to Count -1 do
    if ToDoItemAt( i).tdDate_Completed = 0 then
      Inc( Result);
end;

procedure TClientToDoList.SaveToFile;
//this involves loading the current list and update the items in the current
//list that have changed
var
  S : TMemoryStream;
  Filename : string;
  TempFilename : string;
  Item : pClientToDoItem;
  i    : integer;

  LatestToDoList : TClientToDoList;

  pMyItem        : pClientToDoItem;
  pSharedItem    : pClientToDoItem;

begin
  if EditedCount = 0 then  //no need to save if nothing changed
    Exit;

  Filename := DirUtils.GetTaskListFilename( FClientLRN);

  Self.Lock;
  //load updated list
  LatestToDoList := TClientToDoList.Create( FClientLRN, False);
  try
    //backup existing list
    if BKFileExists( filename) then
    begin
      TempFilename := ChangeFileExt( filename, '.BAK');
      if BKFileExists( tempFilename) then
        SysUtils.DeleteFile( TempFilename);

      RenameFileEx( filename, tempFilename);
    end;

    //update items that have been edited
    for i := 0 to Self.Count - 1 do
    begin
      pMyItem := ToDoItemAt( i);
      if pMyItem.tdTemp_Edited then
      begin
        pSharedItem := LatestToDoList.FindItemByLRN( pMyItem.tdLRN);
        if Assigned( pSharedItem) then
        begin
          //match found, update details
          if pMyItem.tdTemp_Deleted then
          begin
            LatestToDoList.Delete( LatestToDoList.IndexOf( pSharedItem));
          end
          else
          begin
            pSharedItem.tdDate_Entered   := pMyItem.tdDate_Entered;
            pSharedItem.tdTime_Entered   := pMyItem.tdTime_Entered;
            pSharedItem.tdEntered_By     := pMyItem.tdEntered_By;
            pSharedItem.tdDescription    := pMyItem.tdDescription;
            pSharedItem.tdReminderDate   := pMyItem.tdReminderDate;
            pSharedItem.tdDate_Completed := pMyItem.tdDate_Completed;
            pSharedItem.tdIs_Completed   := pMyItem.tdIs_Completed;
            pSharedItem.tdTask_Type      := pMyItem.tdTask_Type;
            pSharedItem.tdFile_Number    := pMyItem.tdFile_Number;
            pSharedItem.tdTemp_Edited    := False;
            pSharedItem.tdTemp_Deleted   := False;
          end;
        end
        else
        begin
          //no match found, may be a new item, or one that has been deleted
          if pMyItem.tdLRN <> 0 then
          begin
            //item has been deleted from main list by was edited in my list
            //reintroduce
            pSharedItem := LatestToDoList.AddToDoItem;
            pSharedItem.tdLRN            := pMyItem.tdLRN;
            pSharedItem.tdDate_Entered   := pMyItem.tdDate_Entered;
            pSharedItem.tdTime_Entered   := pMyItem.tdTime_Entered;
            pSharedItem.tdEntered_By     := pMyItem.tdEntered_By;
            pSharedItem.tdDescription    := pMyItem.tdDescription;
            pSharedItem.tdReminderDate   := pMyItem.tdReminderDate;
            pSharedItem.tdDate_Completed := pMyItem.tdDate_Completed;
            pSharedItem.tdIs_Completed   := pMyItem.tdIs_Completed;
            pSharedItem.tdTask_Type      := pMyItem.tdTask_Type;
            pSharedItem.tdFile_Number    := pMyItem.tdFile_Number;
            pSharedItem.tdTemp_Edited    := False;
            pSharedItem.tdTemp_Deleted   := False;
          end
          else
          begin
            //is a new item
            pSharedItem := LatestToDoList.AddToDoItem;
            LatestToDoList.FHighest_ToDo_LRN := LatestToDoList.FHighest_ToDo_LRN + 1;
            pSharedItem.tdLRN            := LatestToDoList.FHighest_ToDo_LRN;
            pSharedItem.tdDate_Entered   := pMyItem.tdDate_Entered;
            pSharedItem.tdTime_Entered   := pMyItem.tdTime_Entered;
            pSharedItem.tdEntered_By     := pMyItem.tdEntered_By;
            pSharedItem.tdDescription    := pMyItem.tdDescription;
            pSharedItem.tdReminderDate   := pMyItem.tdReminderDate;
            pSharedItem.tdDate_Completed := pMyItem.tdDate_Completed;
            pSharedItem.tdIs_Completed   := pMyItem.tdIs_Completed;
            pSharedItem.tdTask_Type      := pMyItem.tdTask_Type;
            pSharedItem.tdFile_Number    := pMyItem.tdFile_Number;            
            pSharedItem.tdTemp_Edited    := False;
            pSharedItem.tdTemp_Deleted   := False;
          end;
        end;
      end;
    end;

    //sort by date entered
    LatestToDoList.SortBy( tdSortByLRN);

    //now save new list
    S := TMemoryStream.Create;
    try
      S.Write( LatestToDoList.FHighest_ToDo_LRN, SizeOf( LongWord));
      for i := 0 to LatestToDoList.Count -1 do
      begin
        Item := LatestToDoList.ToDoItemAt( i);
        S.Write( Item^, Sizeof( TClientToDoItem));
      end;
      S.SaveToFile( filename);
    finally
      S.Free;
    end;

    //now delete pointers from this list and copy from latest list
    Self.Clear;
    Self.Assign( LatestToDoList);
    Self.FHighest_ToDo_LRN := LatestToDoList.FHighest_ToDo_LRN;
    Self.FCurrentSortOrder := LatestToDoList.FCurrentSortOrder;
    LatestToDoList.Clear;
  finally
    LatestToDoList.Free;
    Self.Unlock;
  end;

  if BKFileExists( tempFilename) then
    SysUtils.DeleteFile( tempFilename);
end;

function TClientToDoList.ToDoItemAt(index: integer): pClientToDoItem;
begin
  result := pClientToDoItem( Items[ index]);
end;

function ToDoListExists( cLRN : integer) : boolean;
var
  filename : string;
begin
  ObtainLock( ltClientToDoList, cLRN, Globals.PRACINI_TicksToWaitForAdmin div 1000);
  try
    Filename := DirUtils.GetTaskListFilename( cLRN);
    result := BKFileExists( filename);
  finally
    ReleaseLock( ltClientToDoList, cLRN);
  end;
end;

procedure TClientToDoList.Unlock;
begin
  Assert( FLocked = true, 'ToDo List not locked on unlock');
  ReleaseLock( ltClientToDoList, FClientLRN);
  FLocked := false;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TClientToDoList.EditedCount: integer;
var
  i : integer;
begin
  result := 0;
  for i := 0 to Count -1 do
    if ToDoItemAt( i).tdTemp_Edited then
      Inc( Result);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TClientToDoList.FindItemByLRN(aLRN: LongWord): pClientToDoItem;
var
  i : integer;
begin
  result := nil;
  for i := 0 to Count -1 do
  begin
    if ToDoItemAt( i).tdLRN = aLRN then
    begin
      result := ToDoItemAt( i);
      exit;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TClientToDoList.FreeAndNilItem(index: integer);
begin
  Dispose( ToDoItemAt( index));
  Items[ index] := nil;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TClientToDoList.GetNextItemDue: pClientToDoItem;
var
  Item : pClientToDoItem;
  i    : integer;
begin
  result := nil;
  //need to sort by reminder date
  Self.Sort( @CompareByNextToDo);

  for i := 0 to Self.Count - 1 do
  begin
    Item := ToDoItemAt(i);
    if Item^.tdDate_Completed = 0 then
    begin
      //take first item that is not complete
      result := Item;
      exit;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TClientToDoList.SortBy(FSortOrder: byte);
begin
  if FSortOrder <> FCurrentSortOrder then
  begin
    case FSortOrder of
      tdSortByDescription   : Self.Sort( @CompareByDesc);
      tdSortByReminderDate  : Self.Sort( @CompareByReminder);
      tdSortByDateCompleted : Self.Sort( @CompareByDateComplete);
      tdSortByEnteredBy     : Self.Sort( @CompareByEntered);
      tdSortByLRN           : Self.Sort( @CompareByLRN);
    else
      Self.Sort( @CompareByDate);
    end;

    FCurrentSortOrder := FSortOrder;
  end;
end;

function TClientToDoList.OverdueCount: integer;
//returns the number of transactions in the list that are currently overdue
var
  i : integer;
  Item : pClientToDoItem;
begin
  result := 0;
  for i := 0 to Count -1 do
  begin
    Item := ToDoItemAt( i);
    if ( Item^.tdDate_Completed = 0) and ( Item^.tdReminderDate <> 0) and
      ( Item^.tdReminderDate < CurrentDate) then
    begin
      Inc( Result);
    end;
  end;
end;

end.
