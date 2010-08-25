// Include File: UNDOMAN_INT.INC

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
    undoReplaceString, undoReplaceInteger, undoReplaceStream, undoCustomSkip);

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
  public
    FOwner: TWPUndoStack;
  private
    // Used for the stack ------------------------------------------------------
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
  public
    FUndoList: TList;
    FRedoList: TList;
  private
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
    // Get last undo object
    function LastUndoObj: TWPUndoObject;
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
    // Saves object directly to undo or redo stack
    procedure SaveObjectDirectly(RedoStack: Boolean; NewUndoObject: TWPUndoObject);
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
    property WhileRedo: Boolean read FWhileRedo write FWhileRedo;
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
  ('Change', 'Checkpoint', 'Change', 'Deletion', 'Input', 'Text Change', 'Data Change', 'Data Change', 'Set Position');

