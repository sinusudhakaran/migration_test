unit MultiCast;

//------------------------------------------------------------------------------
interface

uses
  Classes;

type
  TMultiCastEvent  = class;
  TMultiCastNotify = class;

  PMethod          = ^TMethod;
  PMultiCastNotify = ^TMultiCastNotify;

  //----------------------------------------------------------------------------
  TMultiCastEvent = class
  private
    fDisableCount: Integer;
    fMethods: TList;
    function get_Count: Integer;
    function get_Enabled: Boolean;
    function get_Method(const aIndex: Integer): TMethod;

    procedure ListenerDestroyed(aSender: TObject);
  protected
    {$ifopt C+}
    class procedure CheckReferences(const aArray; const aCount: Integer);
    {$endif}

    procedure Call(const aMethod: TMethod); virtual; abstract;

    procedure Add(const aMethod: TMethod); overload;
    procedure Remove(const aMethod: TMethod); overload;

    property Method[const aIndex: Integer]: TMethod read get_Method;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure DoEvent;
    procedure Enable;
    procedure Disable;

    property Count: Integer read get_Count;
    property Enabled: Boolean read get_Enabled;
  end;

  //----------------------------------------------------------------------------
  IOn_Destroy = interface
  ['{D2AD6882-0CB7-40A6-839D-F527071918FC}']
    procedure Add(const aHandler: TNotifyEvent);
    procedure Remove(const aHandler: TNotifyEvent);
    procedure DoEvent;
    procedure Enable;
    procedure Disable;
  end;

  //----------------------------------------------------------------------------
  TMultiCastNotify = class(TMultiCastEvent)
  private
    fSender: TObject;
  protected
    property Sender: TObject read fSender;
    procedure Call(const aMethod: TMethod); override;
  public
    class procedure CreateEvents(const aSender: TObject;
                                 const aEvents: array of PMultiCastNotify);
    constructor Create(const aSender: TObject); reintroduce; virtual;
    procedure Add(const aHandler: TNotifyEvent); overload;
    procedure Remove(const aHandler: TNotifyEvent); overload;
    procedure DoEventFor(const aSender: TObject);
  end;

  //----------------------------------------------------------------------------
  TOnDestroy = class(TInterfacedObject, IOn_Destroy)
  private
   fEvent: TMultiCastNotify;
  public
    constructor Create(const aOwner: TObject);
    destructor Destroy; override;
  public // IOn_Destroy
    procedure Add(const aHandler: TNotifyEvent);
    procedure Remove(const aHandler: TNotifyEvent);
    procedure DoEvent;
    procedure Enable;
    procedure Disable;
  end;

//------------------------------------------------------------------------------
implementation

uses
  SysUtils;

//------------------------------------------------------------------------------
constructor TMultiCastEvent.Create;
begin
  inherited Create;

  fMethods := TList.Create;
end;

//------------------------------------------------------------------------------
destructor TMultiCastEvent.Destroy;
var
  i: Integer;
  obj: TObject;
  listener: IOn_Destroy;
begin
  for i := 0 to Pred(fMethods.Count) do
  begin
    obj := TObject(PMethod(fMethods[i]).Data);

    if Supports(obj, IOn_Destroy, listener) then
      listener.Remove(ListenerDestroyed);

    Dispose(PMethod(fMethods[i]));
    fMethods[i] := NIL;
  end;

  FreeAndNIL(fMethods);

  inherited;
end;

//------------------------------------------------------------------------------
function TMultiCastEvent.get_Count: Integer;
begin
  result := fMethods.Count;
end;

//------------------------------------------------------------------------------
function TMultiCastEvent.get_Enabled: Boolean;
begin
  result := (fDisableCount = 0);
end;

//------------------------------------------------------------------------------
function TMultiCastEvent.get_Method(const aIndex: Integer): TMethod;
begin
  result := TMethod(fMethods[aIndex]^);
end;

{$ifopt C+}
//------------------------------------------------------------------------------
class procedure TMultiCastEvent.CheckReferences(const aArray; const aCount: Integer);
type
  PointerArray  = array of Pointer;
  PPointerArray = ^PointerArray;
var
  i, j: Integer;
  this: Pointer;
  next: Pointer;
begin
  if aCount = 1 then
  begin
    // No need to check for coincident references if there is only 1 of them,
    //  just check that it isn't already assigned.
    if (PointerArray(aArray)[0] <> NIL) then
      raise EInvalidPointer.CreateFmt('%s.CreateEvents: The reference has already been assigned.',
                                      [ClassName]);
  end
  else
    for i := 0 to Pred(aCount) do
    begin
      this := PointerArray(@aArray)[i];
      if (Pointer(this^) <> NIL) then
        raise EInvalidPointer.CreateFmt('%s.CreateEvents: The reference at index %d has already '
                                      + 'been assigned.', [ClassName, i]);

      for j := i + 1 to Pred(aCount) do
      begin
        next := PointerArray(@aArray)[j];
        if (this = next) then
          raise EInvalidPointer.CreateFmt('%s.CreateEvents: Duplicate event references at '
                                        + 'indices %d and %d.', [ClassName, i, j]);
      end;
    end;
end;
{$endif}

//------------------------------------------------------------------------------
procedure TMultiCastEvent.Add(const aMethod: TMethod);
var
  i: Integer;
  obj: TObject;
  handler: PMethod;
  listener: IOn_Destroy;
begin
  if NOT Assigned(self) then
    EXIT;

  // Check to ensure that the specified method is not already attached
  for i := 0 to Pred(fMethods.Count) do
  begin
    handler := fMethods[i];

    if (aMethod.Code = handler.Code) and (aMethod.Data = handler.Data) then
      EXIT;
  end;

  // Not already attached - create a new TMethod reference and copy the
  //  details from the specific method, then add to our list of handlers
  handler := New(PMethod);
  handler.Code := aMethod.Code;
  handler.Data := aMethod.Data;
  fMethods.Add(handler);

  // Check the object implementing this handler for support of the
  //  IOn_Destroy interface.  If available, add our own
  //  ReceiverDestroyed event handler to that object's On_Destroy event
  obj := TObject(aMethod.Data);

  if Supports(obj, IOn_Destroy, listener) then
    listener.Add(ListenerDestroyed);
end;

//------------------------------------------------------------------------------
procedure TMultiCastEvent.Remove(const aMethod: TMethod);
var
  i: Integer;
  handler: PMethod;
begin
  if NOT Assigned(self) then
    EXIT;

  for i := 0 to Pred(fMethods.Count) do
  begin
    handler := fMethods[i];

    if (aMethod.Code = handler.Code) and (aMethod.Data = handler.Data) then
    begin
      Dispose(handler);
      fMethods.Delete(i);

      // Only one reference to any method can be attached to any one event, so
      //  once we have found and removed the method there is no need to check the
      //  remaining method references.
      BREAK;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TMultiCastEvent.ListenerDestroyed(aSender: TObject);
var
  i: Integer;
  method: PMethod;
begin
  for i := 0 to Pred(Count) do
  begin
    method := fMethods[i];
    if (method.Data = Pointer(aSender)) then
    begin
      Dispose(method);
      fMethods[i] := NIL;
    end;
  end;

  fMethods.Pack;
end;

//------------------------------------------------------------------------------
procedure TMultiCastEvent.DoEvent;
var
  i: Integer;
begin
  if NOT Assigned(self) or (NOT Enabled) then
    EXIT;

  for i := 0 to Pred(Count) do
    Call(Method[i]);
end;

//------------------------------------------------------------------------------
procedure TMultiCastEvent.Enable;
begin
  Dec(fDisableCount);
  ASSERT(fDisableCount >= 0);
end;

//------------------------------------------------------------------------------
procedure TMultiCastEvent.Disable;
begin
  Inc(fDisableCount);
end;

//------------------------------------------------------------------------------
class procedure TMultiCastNotify.CreateEvents(const aSender: TObject;
                                              const aEvents: array of PMultiCastNotify);
var
  i: Integer;
begin
  {$ifopt C+}
  CheckReferences(aEvents, Length(aEvents));
  {$endif}

  for i := Low(aEvents) to High(aEvents) do
    aEvents[i]^ := Create(aSender);
end;

//------------------------------------------------------------------------------
constructor TMultiCastNotify.Create(const aSender: TObject);
begin
  inherited Create;

  fSender := aSender;
end;

//------------------------------------------------------------------------------
procedure TMultiCastNotify.Add(const aHandler: TNotifyEvent);
begin
  inherited Add(TMethod(aHandler));
end;

//------------------------------------------------------------------------------
procedure TMultiCastNotify.Remove(const aHandler: TNotifyEvent);
begin
  inherited Remove(TMethod(aHandler));
end;

//------------------------------------------------------------------------------
procedure TMultiCastNotify.Call(const aMethod: TMethod);
begin
  TNotifyEvent(aMethod)(Sender);
end;

//------------------------------------------------------------------------------
procedure TMultiCastNotify.DoEventFor(const aSender: TObject);
var
  originalSender: TObject;
begin
  originalSender := Sender;
  fSender := aSender;
  try
    DoEvent;
  finally
    fSender := originalSender;
  end;
end;

//------------------------------------------------------------------------------
constructor TOnDestroy.Create(const aOwner: TObject);
begin
  inherited Create;
  fEvent := TMultiCastNotify.Create(aOwner);
end;

//------------------------------------------------------------------------------
destructor TOnDestroy.Destroy;
begin
  try
    fEvent.DoEvent;
  finally
    FreeAndNIL(fEvent);
  end;

  inherited;
end;

//------------------------------------------------------------------------------
procedure TOnDestroy.Add(const aHandler: TNotifyEvent);
begin
  fEvent.Add(aHandler);
end;

//------------------------------------------------------------------------------
procedure TOnDestroy.Remove(const aHandler: TNotifyEvent);
begin
  fEvent.Remove(aHandler);
end;

//------------------------------------------------------------------------------
procedure TOnDestroy.DoEvent;
begin
  fEvent.DoEvent;
end;

//------------------------------------------------------------------------------
procedure TOnDestroy.Enable;
begin
  fEvent.Enable;
end;

//------------------------------------------------------------------------------
procedure TOnDestroy.Disable;
begin
  fEvent.Disable;
end;

end.
