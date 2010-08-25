unit WPUndoMan;
{ -----------------------------------------------------------------------------
  WPUndoMan - Copyright (C) 2002 by wpcubed GmbH     -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  This unit is used to mange global and local undo actions. The WPTools editor
  can use a local undo manager and also a global instance to allow one undo
  stack for several TWPRichText.
  The standard operations include undo for TEdit and TMemo objects.
  Since it is possible to provide an apply event it is easy to add custom undo
  operation to any applicateion. It is also possible to create custom undo
  objects to save additional data.
  The base implementation saves a minimum of 42 bytes per objects.

  The integer Operation is used to identify different operations within one
  class (faster than a class for each operation which is possible!)

  This means the Operation and Descript Integers must be unique within one
  class.
  -----------------------------------------------------------------------------
  Distribution of the unit "WPUndoMan" unit is *not* allowed.
  -----------------------------------------------------------------------------
  Please do *not* recompile this unit. It must remain in its original state.
  Otherwise a unit version mismatch is possible.
  Both, WPTools AND WPForm are using this unit in their engines.
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

interface

uses sysutils, classes, Controls, Forms;

// *** DO NOT EDIT THIS UNIT ***
{$D-}{$Y-}{$Q-}{$R-}{$L-}

type
  TWPUndoStack = class;
  TWPUndoObject = class;

  {: The base undo operations are created by the SaveString and other commands.
     When a new object is created the opreation is alwasy set to custom.
     You can use the Integer 'Command' to refine the operation for the basic
     undo class. We use this Operation and Command integeres to avoid the usage
     of the 'as' operator and make it possible to reuse one class for different,
     similar operations (for example if you use the 'data' property to save any
     binary stream) }
  TWPUndoObjectBaseOperations =
    (undoCustom, undoCheckpoint, undoSnapshot, undoCharInput, undoCharDelete,
    undoReplaceString, undoReplaceInteger, undoReplaceStream);

  TWPUndoActionEvent = procedure(Stack: TWPUndoStack; Source: TObject; var UndoObj: TWPUndoObject) of object;

  TWPEnumStackObjects = procedure(Stack: TWPUndoStack; UndoObject: TWPUndoObject) of object;

  TWPApplyStringUndoEvent = procedure(Stack: TWPUndoStack; Source: TObject;
    var UndoObj: TWPUndoObject; ID: Integer; const Value: string) of object;
  TWPApplyIntegerUndoEvent = procedure(Stack: TWPUndoStack; Source: TObject;
    var UndoObj: TWPUndoObject; ID: Integer; Value: Integer) of object;
  TWPApplyStreamUndoEvent = procedure(Stack: TWPUndoStack; Source: TObject;
    var UndoObj: TWPUndoObject; ID: Integer; Value: TMemoryStream) of object;

  TWPUndoObject = class(TObject)
    {$IFNDEF T2H}
  private
    // Used for the stack ------------------------------------------------------
    FOwner: TWPUndoStack;
    FLevel: Integer; // Current undo or Redo level (or 0)
    FIsRedo: Boolean; // Is on the Redo stack in contrast to the Undo Stack !
    // -------------------------------------------------------------------------
    // Used to store the data
    FSource: TObject; // The Source of the UNDO operation. Usually SetFocus is possible
    FSourceState: Integer; // The state of this object (if different states are possible)
    FElement: TObject; // Object within Source (for example embedded editor!)
    FID: Integer; // ID of the modified string/paragraph etc
    FPos: Integer; // Pos In Par
    FLen: Integer; // Length of the modification
    FOperation: TWPUndoObjectBaseOperations;
    FCommand: Integer; // The Command for undoCustom - what this is depends on the class 'Apply' !
    FText: string; // Any String
    FValue: Integer; // Any Integer
    FOwnedObject: TObject; // Freed in Destroy
    FStackObject: TObject; // Clones can be used in this stack (store bitmaps etc)
    FModified: Boolean; // Stores the prvios Modified state
    FOnApply: TWPUndoActionEvent;
    function GetData: TMemoryStream;
    procedure SetStackObject(x: TObject);
    procedure SetOwnedObject(x: TObject);
  protected
    FData: TMemoryStream;
    function GetDescription: string; virtual;
    property Owner: TWPUndoStack read FOwner;
    {$ENDIF T2H}
  public
    //: Creates a new object and places it on the undo stack
    constructor Create;
    //: Destroys the object and removes it from the undo stack
    destructor Destroy; override;
    //: Apply the undo object
    procedure Apply; virtual;
    {: Try to combine 2 actions (for example indent change etc) (if FUndoBreak=FALSE)
     If possible combination IS performed and the result is TRUE.
     Then NewUndoObject has to be freed! }
    function CanCombine(NewUndoObject: TWPUndoObject): Boolean; virtual;
    //: Data property. It will create the memory stream automatically !
    property Data: TMemoryStream read GetData;
    //: Where do we need to undo a opertaion
    property Source: TObject read FSource write FSource;
    //: In which state (if applicable) do we have to switch the source ?
    property SourceState: Integer read FSourceState write FSourceState;
    //: The current paragraph (or 0)
    property ID: Integer read FID write FID;
    //: The cursor position in 'Par'
    property Pos: Integer read FPos write FPos;
    //: This can be also the length of the replaced text !
    property SelLen: Integer read FLen write FLen;
    //: Save the current modified state (to restet 'modified')
    property Modified: Boolean read FModified write FModified;
    //: This property uses 'Command' to retrieve the description for the undo command
    property Description: string read GetDescription;
    //: This is the id of the operation which has to be undone (or redone!)
    property Operation: TWPUndoObjectBaseOperations read FOperation write FOperation;
    //: This is the refinement of the above
    property Command: Integer read FCommand write FCommand;
    //: Here we can store text, 'Par' is the identifyer for the String
    property Text: string read FText write FText;
    //: Here we can store an integer. 'Par' is the identifyer for the Integer
    property Value: Integer read FValue write FValue;
    {: Here we can specify an owned object (it belongs to the stack - cloning is possible!)
      This can be used for bitmap data or similar  }
    property StackObject: TObject read FStackObject write SetStackObject;
    //: This are properties for this entry. Different types are possible. All are freed in Destroy
    property OwnedObject: TObject read FOwnedObject write SetOwnedObject;
    {: This is the controlled object (if an object was selected within Source)
     or a reference, for examle the tabset the 'source' is located on.
     It could also be a bookmark in a table  }
    property Element: TObject read FElement write FElement;
    //: This event is used to add custom apply events. Those can never be combined by CanCombine
    property OnApply: TWPUndoActionEvent read FOnApply write FOnApply;
    //: This property is TRUE if the undo object lies on the redo stack
    property IsRedo: Boolean read FIsRedo;
  end;

  TWPUndoManagerNotifyEvent = procedure(Sender: TWPUndoStack; Source: TObject) of object;

  TWPUndoManagerLink = class(TObject) // in list FUndoLinks
  private
    FSource: TObject;
    FOnTakeSnapshot: TWPUndoActionEvent;
    FBeforeApply: TWPUndoManagerNotifyEvent;
    FAfterApply: TWPUndoManagerNotifyEvent;
    FApplied: Boolean;
  public
    property Source: TObject read FSource;
    property OnTakeSnapshot: TWPUndoActionEvent read FOnTakeSnapshot write FOnTakeSnapshot;
    property OnBeforeApply: TWPUndoManagerNotifyEvent read FBeforeApply write FBeforeApply;
    property OnAfterApply: TWPUndoManagerNotifyEvent read FAfterApply write FAfterApply;
  end;

  TWPUndoStack = class(TComponent)
    {$IFNDEF T2H}
  private
    FUndoList: TList;
    FRedoList: TList;
    FUndoLinks: TList; // TWPUndoManagerLink
    FOwnedObjects: TList;
    FUndoBreak: Boolean;
    FLevel: Integer;
    FUseLevel: Boolean;
    FCheckIDs, FCheckCount: Integer;
    FLevelsDepth: Integer;
    FWhileUndo, FWhileRedo: Boolean;
    FOnTakeSnapshot: TWPUndoActionEvent;
    FOnApplyUndoAction: TWPUndoActionEvent;
    FOnChange: TNotifyEvent;
    FOnUndoStringAction: TWPApplyStringUndoEvent;
    FOnUndoIntegerAction: TWPApplyIntegerUndoEvent;
    FOnUndoStreamAction: TWPApplyStreamUndoEvent;
    FBeforeApply: TWPUndoManagerNotifyEvent;
    FAfterApply: TWPUndoManagerNotifyEvent;
    FLockList: TList;
    FLockCount: Integer;
    FMaxCount: Integer;
    function GetCanUndo: Boolean;
    function GetCanRedo: Boolean;
    function GetInGroup: Boolean;
    procedure SetMaxCount(x: Integer);
  protected
    procedure Changed; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoBeforeApply(Source: TObject);
    procedure DoAfterApply;
    procedure CleanStackObjects;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    // Low Level Functions to check state of stack and objects
    function Locked(Source: TObject): Boolean;
    //: Creates a new link object and returns a pointer to it
    function AddUndoLink(Source: TObject): TWPUndoManagerLink;
    //: Deletes the link object
    procedure DeleteUndoLink(Source: TObject);
    function Saved(RedoStack: Boolean): TWPUndoObject;
    function InternSave(RedoStack: Boolean; NewUndoObject: TWPUndoObject): Boolean; virtual;
    procedure DoApplyUndoAction(var CurrentObject: TWPUndoObject);
    {$ENDIF}
  public
    //: Undo last undo action
    function Undo: Boolean; virtual; // TRUE if there is at least one operation left
    //: Undoes all operations stored for 'Source'
    function UndoSource(Source: TObject): Boolean;
    //: undoes all actions until the mentioned checkpoint is found
    function UndoToCheckpoint(CheckpointNr: Integer): Boolean;
    //: Fills a list with all checkpoints. The index in this list can be used in  UndoToCheckpoint
    procedure GetCheckpoints(List: TStrings);
    //: Redoes the last undo operation
    function Redo: Boolean; virtual;
    //: Clear all elements and also LockList !
    procedure Clear;
    //: Clear the elements which come from 'Source'
    procedure ClearSource(Source: TObject);
    //: Procedure to enumberate all stored objects
    procedure EnumStackObjects(Source: TObject;
      UndoObjects, RedoObjects: Boolean;
      EnumCallback: TWPEnumStackObjects);
    //: Counts the UNDO steps
    function Count: Integer;
    //: Save and undo object (in the Apply method of an UndoObject the objects are moved to redo)
    function Save(RedoStack: Boolean; NewUndoObject: TWPUndoObject): Boolean;
    //: This is a standard actions to add undo support for simple edit fields
    procedure SaveTextInput(RedoStack: Boolean; Source, Element: TObject; Pos: Integer; Key: Char; Modified: Boolean);
    //: This is a standard actions to add undo support for simple edit fields
    procedure SaveTextDelete(RedoStack: Boolean; Source, Element: TObject; Pos, Count: Integer; Modified: Boolean);
    //: This standard action saves the change to a certain string
    procedure SaveString(RedoStack: Boolean; Source, Element: TObject; const Value: string;
      ID, Pos, Len: Integer; Modified: Boolean);
    //: This standard action saves stream data
    function SaveStream(RedoStack: Boolean; Source, Element: TObject; const Stream: TStream;
      ID: Integer; Modified: Boolean): TMemoryStream;
    //: This standard action saves the change to a certain Integer
    procedure SaveInt(RedoStack: Boolean; Source, Element: TObject; const Value: Integer; ID: Integer; Modified: Boolean);
    //: With a snapshot we can save everything else
    procedure SaveSnapShot(RedoStack: Boolean; Source: TObject);
    //: Save a checkpoint, Makes it possible to undo all opertions until this checkpoint
    function SaveCheckpoint(const Title: string): Integer;
    //: Avoids the automatic combination of a new and the last undo operations
    procedure NewUndoBreak;
    {: Avoids the automatic combination of a new and the last undo operations
       It is only executed if the operation is not within Start/End UndoLevel }
    procedure NewUndoBreakTopLevel;
    {: Combines Undo actions to one (if one action caused multiple undo objects)
       Use "NewUndoLevel" at the end of the block! }
    procedure StartUndoLevel;
    function EndUndoLevel: Boolean;
    //: Prohibit saving of any changes in the specified object or all ( Source = nil)
    procedure LockSaving(Source: TObject; TakeSnapShot: Boolean);
    //: Enables the saving which was locked with 'LockSaving'
    procedure UnlockSaving(Source: TObject);
    //: Get the last undo operation. Can be nil !
    function RecentAction: TWPUndoObject;
    //: Get the last redo operation. Can be nil !
    function RecentRedoAction: TWPUndoObject;
    //: Check if we are doing UNDO
    property WhileUndo: Boolean read FWhileUndo;
    //: Check if we are doing REDO
    property WhileRedo: Boolean read FWhileRedo;
    //: Check if UNDO is possible
    property CanUndo: Boolean read GetCanUndo;
    //: Check if REDO is possible
    property CanRedo: Boolean read GetCanRedo;
    //: Check if we are in an UNDO Group
    property InGroup: Boolean read GetInGroup;
  published
    //: Maximum count of stored UNDO steps
    property MaxCount: Integer read FMaxCount write SetMaxCount default -1;
    //: Event to take a snapshot of all data
    property OnTakeSnapshot: TWPUndoActionEvent read FOnTakeSnapshot write FOnTakeSnapshot;
    property OnApplyUndoAction: TWPUndoActionEvent read FOnApplyUndoAction write FOnApplyUndoAction;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnUndoStringAction: TWPApplyStringUndoEvent read FOnUndoStringAction write FOnUndoStringAction;
    property OnUndoIntegerAction: TWPApplyIntegerUndoEvent read FOnUndoIntegerAction write FOnUndoIntegerAction;
    property OnUndoStreamAction: TWPApplyStreamUndoEvent read FOnUndoStreamAction write FOnUndoStreamAction;
    property BeforeApply: TWPUndoManagerNotifyEvent read FBeforeApply write FBeforeApply;
    property AfterApply: TWPUndoManagerNotifyEvent read FAfterApply write FAfterApply;
  end;

var
  WPUndoDescriptions: array[TWPUndoObjectBaseOperations] of string =
  ('Change', 'Checkpoint', 'Change', 'Deletion', 'Input', 'Text Change', 'Data Change', 'Data Change');
implementation

constructor TWPUndoStack.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FOwnedObjects := TList.Create;
  FLockList := TList.Create;
  FUndoList := TList.Create;
  FRedoList := TList.Create;
  FUndoLinks := TList.Create;
  FUseLevel := FALSE;
  FLevel := 1;
  FMaxCount := -1;
end;

destructor TWPUndoStack.Destroy;
var
  i: Integer;
begin
  FOnChange := nil;
  Clear;
  for i := 0 to FUndoLinks.Count - 1 do
    TWPUndoManagerLink(FUndoLinks[i]).Free;
  FUndoLinks.Free;
  FOwnedObjects.Free;
  FUndoList.Free;
  FRedoList.Free;
  FLockList.Free;
  inherited Destroy;
end;

procedure TWPUndoStack.Loaded;
begin
  inherited Loaded;
  Changed;
end;

function TWPUndoStack.Locked(Source: TObject): Boolean;
begin
  Result := (FLockCount > 0) or (FLockList.IndexOf(Source) >= 0);
end;

function TWPUndoStack.AddUndoLink(Source: TObject): TWPUndoManagerLink;
var
  i: Integer;
begin
  for i := FUndoLinks.Count - 1 downto 0 do
    if TWPUndoManagerLink(FUndoLinks[i]) = Source then
    begin
      TWPUndoManagerLink(FUndoLinks[i]).Free;
      FUndoLinks.Delete(i);
    end;
  Result := TWPUndoManagerLink.Create;
  Result.FSource := Source;
  FUndoLinks.Add(Result);
end;

procedure TWPUndoStack.DeleteUndoLink(Source: TObject);
var
  i: Integer;
begin
  for i := FUndoLinks.Count - 1 downto 0 do
    if TWPUndoManagerLink(FUndoLinks[i]).Source = Source then
    begin
      TWPUndoManagerLink(FUndoLinks[i]).Free;
      FUndoLinks.Delete(i);
    end;
end;

procedure TWPUndoStack.LockSaving(Source: TObject; TakeSnapShot: Boolean);
begin
  if Source <> nil then
  begin
    if TakeSnapShot then SaveSnapShot(false, Source);
    FLockList.Add(Source);
  end
  else
  begin
    if TakeSnapShot then SaveSnapShot(false, Source);
    inc(FLockCount);
  end;
end;

procedure TWPUndoStack.UnlockSaving(Source: TObject);
var
  i: Integer;
begin
  if Source <> nil then
  begin
    i := FLockList.IndexOf(Source);
    if i >= 0 then FLockList.Delete(i);
  end
  else
  begin
    dec(FLockCount);
    if FLockCount < 0 then FLockCount := 0;
  end;
end;

function TWPUndoStack.Undo: Boolean; // TRUE if there is at least one operation left
var
  oldFWhileUndo, noCheckPoint: Boolean;
  TheUndoLevel, i, c: Integer;
  oldcursor: TCursor;
begin
  oldFWhileUndo := FWhileUndo;
  if FUndoList.Count > 0 then
  try
    if not FWhileUndo then
      DoBeforeApply(nil);
    if not FWhileUndo then
    begin
      inc(FLevel);
      FUseLevel := FALSE;
    end;
    FWhileUndo := TRUE;
    TheUndoLevel := TWPUndoObject(FUndoList.Last).FLevel;
    // 1. Count
    i := FUndoList.Count - 1;
    c := 0;
    while (i >= 0) and (TWPUndoObject(FUndoList[i]).FLevel = TheUndoLevel) do
    begin
      if not oldFWhileUndo and (TWPUndoObject(FUndoList[i]).FOperation = undoCheckpoint) then
        noCheckPoint := FALSE
      else
        noCheckPoint := TRUE;
      if (TheUndoLevel = 0) and noCheckPoint then break;
      dec(i);
      inc(c);
    end;
    // More than 20 steps at once - better show a hourglass
    if c > 20 then
    begin
      oldcursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;
    end
    else
      oldcursor := crDefault;
    // Apply Undo
    TheUndoLevel := TWPUndoObject(FUndoList.Last).FLevel;
    while (FUndoList.Count > 0) and
      (TWPUndoObject(FUndoList.Last).FLevel = TheUndoLevel) do
    begin
      if not oldFWhileUndo and (TWPUndoObject(FUndoList.Last).FOperation = undoCheckpoint) then
        noCheckPoint := FALSE
      else
      begin
        if TWPUndoObject(FUndoList.Last).Source <> nil then
          DoBeforeApply(TWPUndoObject(FUndoList.Last).Source);
        TWPUndoObject(FUndoList.Last).Apply;
        noCheckPoint := TRUE;
      end;
      TWPUndoObject(FUndoList.Last).Free;
      if (TheUndoLevel = 0) and noCheckPoint then break;
    end;
    // Reset cursor
    if c > 20 then Screen.Cursor := oldcursor;
  finally
    FWhileUndo := oldFWhileUndo;
    if not FWhileUndo then DoAfterApply;
  end;
  Result := FUndoList.Count > 0;
  if not FWhileUndo then Changed;
end;

// Undoes all operation for 'Source' only

function TWPUndoStack.UndoSource(Source: TObject): Boolean;
var
  oldFWhileUndo: Boolean;
  i: Integer;
begin
  oldFWhileUndo := FWhileUndo;
  if FUndoList.Count > 0 then
  try
    if not FWhileUndo then
      DoBeforeApply(nil);
    if not FWhileUndo then
    begin
      inc(FLevel);
      FUseLevel := FALSE;
    end;
    FWhileUndo := TRUE;
    i := FUndoList.Count - 1;
    while i >= 0 do
    begin
      if TWPUndoObject(FUndoList[i]).FSource = Source then
      begin
        if TWPUndoObject(FUndoList[i]).Source <> nil then
          DoBeforeApply(TWPUndoObject(FUndoList[i]).Source);
        TWPUndoObject(FUndoList[i]).Apply;
        TWPUndoObject(FUndoList[i]).Free;
      end;
      dec(i);
    end;
  finally
    FWhileUndo := oldFWhileUndo;
    if not FWhileUndo then DoAfterApply;
  end;
  Result := FUndoList.Count > 0;
  if not FWhileUndo then Changed;
end;

// Undoes all operations until it finds a certain checkpoint. If this checkpoint
// does not exist it does not undo anything. The checkpoint is removed

function TWPUndoStack.UndoToCheckpoint(CheckpointNR: Integer): Boolean;
var
  found: Boolean;
  i, CheckpointID: Integer;
begin
  found := FALSE;
  CheckpointID := 0;
  for i := 0 to FUndoList.Count - 1 do
    if TWPUndoObject(FUndoList[i]).FOperation = undoCheckpoint then
    begin
      dec(CheckpointNR);
      if CheckpointNR = -1 then
      begin
        CheckpointID := TWPUndoObject(FUndoList[i]).FID;
        found := TRUE;
        break;
      end;
    end;

  if found then
  try
    inc(FLevel);
    FUseLevel := FALSE;
    FWhileUndo := TRUE;
    while found and (FUndoList.Count > 0) do
    begin
      if (TWPUndoObject(FUndoList.Last).FOperation = undoCheckpoint) and
        (TWPUndoObject(FUndoList.Last).FID = CheckpointID) then found := FALSE;
      Undo;
    end;
  finally
    FWhileUndo := FALSE;
  end;
  Result := FUndoList.Count > 0;
  Changed;
end;

procedure TWPUndoStack.GetCheckpoints(List: TStrings);
var
  i: Integer;
begin
  if FCheckCount = 0 then
  begin
    if List.Count > 0 then List.Clear;
  end
  else
  begin
    List.BeginUpdate;
    try
      List.Clear;
      for i := 0 to FUndoList.Count - 1 do
        if TWPUndoObject(FUndoList[i]).FOperation = undoCheckpoint then
          List.Add(TWPUndoObject(FUndoList[i]).FText);
    finally
      List.EndUpdate;
    end;
  end;
end;

function TWPUndoStack.Redo: Boolean;
var
  TheUndoLevel, i, c: Integer;
  oldcursor: TCursor;
begin
  if FRedoList.Count > 0 then
  try
    if not FWhileRedo then DoBeforeApply(nil);
    FWhileRedo := TRUE;
    inc(FLevel);
    FUseLevel := FALSE;
    TheUndoLevel := TWPUndoObject(FRedoList.Last).FLevel;
    // 1. Count
    i := FRedoList.Count - 1;
    c := 0;
    while (i >= 0) and (TWPUndoObject(FRedoList[i]).FLevel = TheUndoLevel) do
    begin
      if TheUndoLevel = 0 then break;
      dec(i);
      inc(c);
    end;
    // More than 20 steps at once - better show a hourglass
    if c > 20 then
    begin
      oldcursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;
    end
    else
      oldcursor := crDefault;
    // Apply Undo
    while (FRedoList.Count > 0) and (TWPUndoObject(FRedoList.Last).FLevel = TheUndoLevel) do
    begin
      if TWPUndoObject(FRedoList.Last).Source <> nil then
        DoBeforeApply(TWPUndoObject(FRedoList.Last).Source);
      TWPUndoObject(FRedoList.Last).Apply;
      TWPUndoObject(FRedoList.Last).Free;
      if TheUndoLevel = 0 then break;
    end;
    // Reset Cursor
    if c > 20 then Screen.Cursor := oldcursor;
  finally
    FWhileRedo := FALSE;
    if not FWhileRedo then DoAfterApply;
  end;
  Result := FRedoList.Count > 0;
  Changed;
end;

procedure TWPUndoStack.Clear;
var
  i: Integer;
begin
  for i := 0 to FUndoList.Count - 1 do
  begin
    TWPUndoObject(FUndoList[i]).FOwner := nil;
    TWPUndoObject(FUndoList[i]).Free;
  end;
  FUndoList.Clear;
  for i := 0 to FRedoList.Count - 1 do
  begin
    TWPUndoObject(FRedoList[i]).FOwner := nil;
    TWPUndoObject(FRedoList[i]).Free;
  end;
  FRedoList.Clear;
  for i := 0 to FOwnedObjects.Count - 1 do
    TObject(FOwnedObjects[i]).Free;
  FOwnedObjects.Clear;
  FLockList.Clear;
  FLockCount := 0;
  FUseLevel := FALSE;
  FCheckIDs := 0;
  FLevel := 1;
  Changed;
end;

// Remove all objects which are in the 'stack' but not used by and undo object
procedure TWPUndoStack.CleanStackObjects;
var
  i, j: Integer;
  obj: TObject;
begin
  for i := 0 to FOwnedObjects.Count - 1 do
  begin
    obj := FOwnedObjects[i];
    if obj <> nil then
      for j := 0 to FUndoList.Count - 1 do
        if TWPUndoObject(FUndoList[j]).FStackObject = obj then
        begin
          obj := nil;
          break;
        end;

    if obj <> nil then
      for j := 0 to FRedoList.Count - 1 do
        if TWPUndoObject(FRedoList[j]).FStackObject = obj then
        begin
          obj := nil;
          break;
        end;

    if obj <> nil then
    begin
      obj.Free;
      FOwnedObjects[i] := nil;
    end;
  end;
  FOwnedObjects.Pack;
end;

procedure TWPUndoStack.ClearSource(Source: TObject);
var
  i: Integer;
begin
  for i := 0 to FUndoList.Count - 1 do
    if TWPUndoObject(FUndoList[i]).FSource = Source then
    begin
      TWPUndoObject(FUndoList[i]).FOwner := nil;
      TWPUndoObject(FUndoList[i]).Free;
      FUndoList[i] := nil;
    end;
  FUndoList.Pack;
  for i := 0 to FRedoList.Count - 1 do
    if TWPUndoObject(FRedoList[i]).FSource = Source then
    begin
      TWPUndoObject(FRedoList[i]).FOwner := nil;
      TWPUndoObject(FRedoList[i]).Free;
      FRedoList[i] := nil;
    end;
  FRedoList.Pack;

  CleanStackObjects;

  repeat
    i := FLockList.IndexOf(Source);
    if i >= 0 then FLockList.Delete(i);
  until i < 0;

  FUseLevel := FALSE;
  Changed;
end;

// Save an object on the Undo Stack but check first if it can be combined

function TWPUndoStack.Save(RedoStack: Boolean; NewUndoObject: TWPUndoObject): Boolean;
var
  temp: TWPUndoObject;
begin
  temp := Saved(RedoStack);
  if (temp = nil) or not temp.CanCombine(NewUndoObject) then
    Result := InternSave(RedoStack, NewUndoObject)
  else
  begin
    NewUndoObject.Free;
    Result := FALSE;
  end;
end;

// Save an object on the Undo Stack

function TWPUndoStack.InternSave(RedoStack: Boolean; NewUndoObject: TWPUndoObject): Boolean;
begin
  if NewUndoObject <> nil then
  begin
    if NewUndoObject.FOperation = undoCheckpoint then inc(FCheckCount);
    NewUndoObject.FOwner := Self;
    if FWhileUndo or FWhileRedo or
      (FUseLevel and not RedoStack) then
      NewUndoObject.FLevel := FLevel;
    NewUndoObject.FIsRedo := RedoStack;
    if RedoStack then // REDO Stack
      FRedoList.Add(NewUndoObject)
    else // UNDO STACK
    begin
      if FMaxCount > 0 then SetMaxCount(FMaxCount);
      if not FWhileRedo then
        while FRedoList.Count > 0 do
          TWPUndoObject(FRedoList.First).Free;
      FUndoList.Add(NewUndoObject);
      FUndoBreak := FALSE;
    end;
    if (NewUndoObject.FStackObject <> nil) and
      (FOwnedObjects.IndexOf(NewUndoObject.FStackObject) < 0) then
      FOwnedObjects.Add(NewUndoObject.FStackObject);
    Changed;
    Result := TRUE;
  end
  else
    Result := FALSE;
end;

procedure TWPUndoStack.DoApplyUndoAction(var CurrentObject: TWPUndoObject);
begin
  if CurrentObject <> nil then
  begin
    if Assigned(FOnApplyUndoAction) then
      FOnApplyUndoAction(Self, CurrentObject.FSource, CurrentObject);
  end;
end;

procedure TWPUndoStack.DoBeforeApply(Source: TObject);
var
  i: Integer;
begin
  if Source = nil then
  begin
    for i := 0 to FUndoLinks.Count - 1 do
      TWPUndoManagerLink(FUndoLinks[i]).FApplied := FALSE
  end
  else
    for i := 0 to FUndoLinks.Count - 1 do
      if TWPUndoManagerLink(FUndoLinks[i]).FSource = Source then
      begin
        if assigned(FBeforeApply) then
          FBeforeApply(Self, TWPUndoManagerLink(FUndoLinks[i]).FSource);
        if assigned(TWPUndoManagerLink(FUndoLinks[i]).FBeforeApply) then
          TWPUndoManagerLink(FUndoLinks[i]).FBeforeApply(Self,
            TWPUndoManagerLink(FUndoLinks[i]).FSource);
        TWPUndoManagerLink(FUndoLinks[i]).FApplied := TRUE;
      end;
end;

procedure TWPUndoStack.DoAfterApply;
var
  i: Integer;
begin
  for i := 0 to FUndoLinks.Count - 1 do
    if TWPUndoManagerLink(FUndoLinks[i]).FApplied then
    begin
      if assigned(TWPUndoManagerLink(FUndoLinks[i]).FAfterApply) then
        TWPUndoManagerLink(FUndoLinks[i]).FAfterApply(Self,
          TWPUndoManagerLink(FUndoLinks[i]).FSource);
      if assigned(FAfterApply) then
        FAfterApply(Self, TWPUndoManagerLink(FUndoLinks[i]).FSource);
      TWPUndoManagerLink(FUndoLinks[i]).FApplied := FALSE;
    end;
end;

function TWPUndoStack.Saved(RedoStack: Boolean): TWPUndoObject;
begin
  Result := nil;
  if not FUndoBreak then
  begin
    if RedoStack and (FRedoList.Count > 0) then
      Result := TWPUndoObject(FRedoList.Last)
    else if FUndoList.Count > 0 then
      Result := TWPUndoObject(FUndoList.Last);
  end;
end;

// This are 2 standard actions to add undo support for simple edit fields
// The comparison "CanCombine" is not use to avoid the overhead of creating
// a new object

procedure TWPUndoStack.SaveTextInput(RedoStack: Boolean; Source, Element: TObject; Pos: Integer; Key: Char; Modified: Boolean);
var
  UndoObject: TWPUndoObject;
begin
  if not Locked(Source) then
  begin
    UndoObject := Saved(RedoStack);
    if (UndoObject = nil) or
      (UndoObject.FSource <> Source) or
      (UndoObject.FElement <> Element) or
      (UndoObject.FOperation <> undoCharInput) or
      (UndoObject.FPos + Length(UndoObject.FText) <> Pos) then
    begin
      UndoObject := TWPUndoObject.Create;
      UndoObject.FOperation := undoCharInput;
      UndoObject.FPos := Pos;
      UndoObject.FText := Key;
      UndoObject.Modified := Modified;
      InternSave(RedoStack, UndoObject);
    end
    else
      UndoObject.FText := UndoObject.FText + Key;
  end;
end;

procedure TWPUndoStack.SaveTextDelete(RedoStack: Boolean; Source, Element: TObject; Pos, Count: Integer; Modified: Boolean);
var
  UndoObject: TWPUndoObject;
begin
  if not Locked(Source) then
  begin
    UndoObject := Saved(RedoStack);
    if (UndoObject = nil) or
      (UndoObject.FSource <> Source) or
      (UndoObject.FElement <> Element) or
      (UndoObject.FOperation <> undoCharDelete) or
      (UndoObject.FPos + UndoObject.FLen <> Pos) then
    begin
      UndoObject := TWPUndoObject.Create;
      UndoObject.FOperation := undoCharDelete;
      UndoObject.FPos := Pos;
      UndoObject.FLen := Count;
      UndoObject.Modified := Modified;
      InternSave(RedoStack, UndoObject);
    end
    else
      inc(UndoObject.FLen, Count);
  end;
end;

// Easy to use function. Pos+Len is used to combine undo states
// If Len=0 then always a new item is created

procedure TWPUndoStack.SaveString(RedoStack: Boolean; Source, Element: TObject;
  const Value: string; ID, Pos, Len: Integer; Modified: Boolean);
var
  UndoObject: TWPUndoObject;
begin
  if not Locked(Source) then
  begin
    UndoObject := Saved(RedoStack);
    if (len = 0) or
      (UndoObject = nil) or
      (UndoObject.FSource <> Source) or
      (UndoObject.FElement <> Element) or
      (UndoObject.FID <> ID) or
      (UndoObject.FOperation <> undoReplaceString) or
      (UndoObject.FPos + UndoObject.FLen <> Pos) then
    begin
      UndoObject := TWPUndoObject.Create;
      UndoObject.FOperation := undoReplaceString;
      UndoObject.FID := ID;
      UndoObject.FPos := Pos;
      UndoObject.FSource := Source;
      UndoObject.FElement := Element;
      UndoObject.FLen := Len;
      UndoObject.Modified := Modified;
      UndoObject.FText := Value;
      InternSave(RedoStack, UndoObject);
    end
    else
    begin
      inc(UndoObject.FLen, Len);
    end;
  end;
end;

function TWPUndoStack.SaveStream(RedoStack: Boolean; Source, Element: TObject; const Stream: TStream;
  ID: Integer; Modified: Boolean): TMemoryStream;
var
  UndoObject: TWPUndoObject;
begin
  Result := nil;
  if not Locked(Source) then
  begin
    UndoObject := Saved(RedoStack);
    if (ID = 0) or
      (UndoObject = nil) or
      (UndoObject.FSource <> Source) or
      (UndoObject.FElement <> Element) or
      (UndoObject.FID <> ID) or
      (UndoObject.FOperation <> undoReplaceStream) then
    begin
      UndoObject := TWPUndoObject.Create;
      UndoObject.FOperation := undoReplaceStream;
      UndoObject.FID := ID;
      Result := UndoObject.Data;
      if Stream <> nil then
      begin
        Stream.Position := 0;
        Result.CopyFrom(Stream, Stream.Size);
      end;
      UndoObject.FSource := Source;
      UndoObject.FElement := Element;
      UndoObject.Modified := Modified;
      InternSave(RedoStack, UndoObject);
    end;
  end;
end;

procedure TWPUndoStack.SaveInt(RedoStack: Boolean; Source, Element: TObject;
  const Value: Integer; ID: Integer; Modified: Boolean);
var
  UndoObject: TWPUndoObject;
begin
  if not Locked(Source) then
  begin
    UndoObject := Saved(RedoStack);
    if (ID = 0) or
      (UndoObject = nil) or
      (UndoObject.FSource <> Source) or
      (UndoObject.FElement <> Element) or
      (UndoObject.FID <> ID) or
      (UndoObject.FOperation <> undoReplaceInteger) then
    begin
      UndoObject := TWPUndoObject.Create;
      UndoObject.FOperation := undoReplaceInteger;
      UndoObject.FID := ID;
      UndoObject.FValue := Value;
      UndoObject.FSource := Source;
      UndoObject.FElement := Element;
      UndoObject.Modified := Modified;
      InternSave(RedoStack, UndoObject);
    end;
  end;
end;

// never combined !

procedure TWPUndoStack.SaveSnapShot(RedoStack: Boolean; Source: TObject);
var
  newobj: TWPUndoObject;
  i: Integer;
begin
  if not Locked(Source) then
  begin
    for i := 0 to FUndoLinks.Count - 1 do
    begin
      if (TWPUndoManagerLink(FUndoLinks[i]).FSource = Source) and
        Assigned(TWPUndoManagerLink(FUndoLinks[i]).FOnTakeSnapshot) then
      begin
        newobj := TWPUndoObject.Create;
        try
          newobj.FSource := Source;
          TWPUndoManagerLink(FUndoLinks[i]).FOnTakeSnapshot(Self, Source, newobj);
          if newobj <> nil then
          begin
            //NO FUndoBreak := TRUE;
            Save(RedoStack, newobj);
          end;
        except
          newobj.Free;
        end;
      end;
    end;
    if Assigned(FOnTakeSnapshot) then
    begin
      newobj := TWPUndoObject.Create;
      try
        newobj.FSource := Source;
        FOnTakeSnapshot(Self, Source, newobj);
        if newobj <> nil then
        begin
          //NO FUndoBreak := TRUE;
          Save(RedoStack, newobj);
        end;
      except
        newobj.Free;
      end;
    end;
  end;
end;

function TWPUndoStack.SaveCheckpoint(const Title: string): Integer;
var
  UndoObject: TWPUndoObject;
begin
  inc(FCheckIDs);
  UndoObject := TWPUndoObject.Create;
  UndoObject.FOperation := undoCheckpoint;
  UndoObject.FID := FCheckIDs;
  UndoObject.FText := Title;
  Result := FCheckCount; // 0 based !
  InternSave(false, UndoObject);
end;

// Avoids the combination of a new and the last undo operations

procedure TWPUndoStack.NewUndoBreak;
begin
  // No combining of the same undo actions
  FUndoBreak := TRUE;
end;

procedure TWPUndoStack.NewUndoBreakTopLevel;
begin
  if FLevelsDepth <= 0 then FUndoBreak := TRUE;
end;

procedure TWPUndoStack.StartUndoLevel;
begin
  // now 'grouping' of undo actions
  inc(FLevelsDepth);
  if FLevelsDepth = 1 then
  begin
    inc(FLevel);
    Changed;
  end;
  FUseLevel := TRUE;
end;

function TWPUndoStack.EndUndoLevel: Boolean;
begin
  if FLevelsDepth > 0 then
    dec(FLevelsDepth);
  if FLevelsDepth = 0 then
  begin
    FUseLevel := FALSE;
    Changed;
  end;
  Result := FLevelsDepth > 0;
end;

// Get the last undo operation. Skips 'Checkpoint' markers

function TWPUndoStack.RecentAction: TWPUndoObject;
begin
  if FUndoList.Count > 0 then
    Result := TWPUndoObject(FUndoList.Last)
  else
    Result := nil;
end;

function TWPUndoStack.RecentRedoAction: TWPUndoObject;
begin
  if FRedoList.Count > 0 then
    Result := TWPUndoObject(FRedoList.Last)
  else
    Result := nil;
end;

function TWPUndoStack.GetCanUndo: Boolean;
var
  i: Integer;
begin
  Result := FALSE;
  for i := 0 to FUndoList.Count - 1 do
    if TWPUndoObject(FUndoList[i]).FOperation <> undoCheckpoint then
    begin
      Result := TRUE; break;
    end;
end;

function TWPUndoStack.GetCanRedo: Boolean;
begin
  Result := FRedoList.Count > 0;
end;

procedure TWPUndoStack.EnumStackObjects(
  Source: TObject; UndoObjects, RedoObjects: Boolean; EnumCallback: TWPEnumStackObjects);
var
  i: Integer;
begin
  if UndoObjects then
    for i := 0 to FUndoList.Count - 1 do
      if TWPUndoObject(FUndoList[i]).FSource = Source then
        EnumCallback(Self, TWPUndoObject(FUndoList[i]));
  if RedoObjects then
    for i := 0 to FRedoList.Count - 1 do
      if TWPUndoObject(FRedoList[i]).FSource = Source then
        EnumCallback(Self, TWPUndoObject(FRedoList[i]));
end;

function TWPUndoStack.GetInGroup: Boolean;
begin
  Result := FLevelsDepth > 0;
end;
// Reduces the size of the undo buffer

procedure TWPUndoStack.SetMaxCount(x: Integer);
var
  lastlevel, currlevel: Integer; ischeck: Boolean;
begin
  FMaxCount := x;
  if (FUndoList.Count > 0) and (FMaxCount > 0) then
  begin
    x := FMaxCount - Count;
    lastlevel := 0;
    while (x <= 0) and (FUndoList.Count > 0) do
    begin
      currlevel := TWPUndoObject(FUndoList.First).FLevel;
      ischeck := TWPUndoObject(FUndoList.First).FOperation = undoCheckpoint;
      TWPUndoObject(FUndoList.First).Free;
      if not ischeck and ((currlevel = 0) or (lastlevel <> currlevel)) then inc(x);
      lastlevel := currlevel;
    end;
  end;
end;

procedure TWPUndoStack.Changed;
begin
  if assigned(FOnChange) then FOnChange(Self);
end;

procedure TWPUndoStack.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent <> nil) then
  begin
    DeleteUndoLink(AComponent);
  end;
end;

// Counts the elements on the und stack. Elements with the same level are
// counted as one element! Checkpoints are not counted !

function TWPUndoStack.Count: Integer;
var
  temp: TWPUndoObject;
  lastlevel, i: Integer;
begin
  Result := 0;
  lastlevel := 0;
  for i := 0 to FUndoList.Count - 1 do
  begin
    temp := TWPUndoObject(FUndoList[i]);
    if (temp.FOperation <> undoCheckpoint) and
      (temp.FLevel = 0) or (temp.FLevel <> lastlevel) then inc(Result);
    lastlevel := temp.FLevel;
  end;
end;

// Creates a new object and places it on the undo stack

constructor TWPUndoObject.Create;
begin
  inherited Create;
end;

// Destroys the object and removes it from the undo or redo stack
// The stack must always be freed from the tail !

destructor TWPUndoObject.Destroy;
var
  i: Integer;
begin
  if FData <> nil then FData.Free;
  if FOwnedObject <> nil then FOwnedObject.Free;
  FText := '';
  if FOwner <> nil then
  begin
    if FOperation = undoCheckpoint then dec(FOwner.FCheckCount);
    // Remove from Owner
    if FIsRedo then
    begin
      i := FOwner.FRedoList.IndexOf(Self);
      if i >= 0 then
        FOwner.FRedoList.Delete(i)
      else
        raise Exception.Create('Error - Redostack');
    end
    else
    begin
      i := FOwner.FUndoList.IndexOf(Self);
      if i >= 0 then
        FOwner.FUndoList.Delete(i)
      else
        raise Exception.Create('Error - Undostack');
    end;
  end;
  SetStackObject(nil);
  inherited Destroy;
end;

function TWPUndoObject.GetDescription: string;
begin
  Result := WPUndoDescriptions[FOperation];
end;

function TWPUndoObject.GetData: TMemoryStream;
begin
  if FData = nil then FData := TMemoryStream.Create;
  Result := FData;
end;

// Set and/or free the stack object

procedure TWPUndoObject.SetStackObject(x: TObject);
var
  oldstackobj: TObject;
  i, j: Integer;
begin
  if (FOwner <> nil) and (FStackObject <> x) then
  try
    oldstackobj := FStackObject;
    FStackObject := x;
    // Free the stack object - but only if it is not referenced somewhere else in the stack !
    if oldstackobj <> nil then
    begin
      // Do we list this object in the list of stack objects
      i := FOwner.FOwnedObjects.IndexOf(oldstackobj);
      // Yes, then we can check if we may free it
      if i >= 0 then
      begin
        // Free it and remove it from the FOwnedObjects if it is not used anywhere else
        for j := 0 to FOwner.FUndoList.Count - 1 do
          if TWPUndoObject(FOwner.FUndoList[j]).FStackObject = oldstackobj then exit;
        for j := 0 to FOwner.FRedoList.Count - 1 do
          if TWPUndoObject(FOwner.FRedoList[j]).FStackObject = oldstackobj then exit;
        // If we come here we may delete that
        oldstackobj.Free;
        FOwner.FOwnedObjects.Delete(i);
      end;
    end;
  finally
    if (FStackObject <> nil) and (FOwner <> nil) and (FOwner.FOwnedObjects.IndexOf(x) < 0) then
      FOwner.FOwnedObjects.Add(FStackObject);
  end;
end;

procedure TWPUndoObject.SetOwnedObject(x: TObject);
begin
  if FOwnedObject <> x then
  begin
    if FOwnedObject <> nil then FOwnedObject.Free;
    FOwnedObject := x;
  end;
end;

// Apply the undo object

procedure TWPUndoObject.Apply;
var
  o: TWPUndoObject;
begin
  if FOperation = undoCheckpoint then exit;
  o := Self;
  if assigned(FOnApply) then FOnApply(FOwner, Self, o);
  if (o <> nil) and (FOwner <> nil) then
  begin
    if assigned(FOwner.FOnUndoStringAction) and
      (FOperation = undoReplaceString) then
      FOwner.FOnUndoStringAction(FOwner, FSource, o, FID, FText)
    else if assigned(FOwner.FOnUndoIntegerAction) and
      (FOperation = undoReplaceInteger) then
      FOwner.FOnUndoIntegerAction(FOwner, FSource, o, FID, FValue)
    else if assigned(FOwner.FOnUndoStreamAction) and
      (FOperation = undoReplaceStream) and (FData <> nil) then
    begin
      FData.Position := 0;
      FOwner.FOnUndoStreamAction(FOwner, FSource, o, FID, FData);
    end;
    FOwner.DoApplyUndoAction(o);
  end;
end;

// This implementation only checks the minimum requirements

function TWPUndoObject.CanCombine(NewUndoObject: TWPUndoObject): Boolean;
begin
  if (NewUndoObject = nil) or (FOwner = nil) or
    (FOwner.FUndoBreak) then
    Result := FALSE
  else
    Result := (NewUndoObject.FOperation = FOperation) and // Same Operation (custom!)
    (NewUndoObject.FElement = FElement) and // Same Element
    (NewUndoObject.FSource = FSource) and // Same Source
    (NewUndoObject.FID = FID) and // same ID
    (NewUndoObject.ClassName = Self.ClassName); // and in the same class only
end;

initialization

finalization


end.




