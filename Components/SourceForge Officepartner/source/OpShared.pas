(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is TurboPower OfficePartner
 *
 * The Initial Developer of the Original Code is
 * TurboPower Software
 *
 * Portions created by the Initial Developer are Copyright (C) 2000-2002
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

{$I OPDEFINE.INC}

unit OpShared;

interface

uses SysUtils, Classes, Forms, ActiveX, OpEvents
     {$IFDEF VERSION7},Variants{$ENDIF};

{$IFDEF VERSION3}
var
  {: Introduced for Delphi3/CBuilder3 support.}
  EmptyParam: OLEVariant;

type
  PControlData2 = ^TControlData2;
  TControlData2 = record
    ClassID: TGUID;
    EventIID: TGUID;
    EventCount: Longint;
    EventDispIDs: Pointer;
    LicenseKey: Pointer;
    Flags: Cardinal;
    Version: Integer;
    FontCount: Integer;
    FontIDs: PDispIDList;
    PictureCount: Integer;
    PictureIDs: PDispIDList;
    Reserved: Integer;
    InstanceCount: Integer;
    EnumPropDescs: TList;
    FirstEventOfs: Cardinal;
  end;

{$ENDIF}

type
  TOpCoCreateInstanceExProc = function (const clsid: TCLSID;
    unkOuter: IUnknown; dwClsCtx: Longint; ServerInfo: PCoServerInfo;
    dwCount: Longint; rgmqResults: PMultiQIArray): HResult stdcall;

var
  OpCoCreateInstanceEx: TOpCoCreateInstanceExProc = nil;

type
  TOpNestedCollection = class;
  TOpNestedCollectionItem = class;
  TOpOfficeComponent = class;
  {: Generic parameterless event.}
  TOpOfficeEvent = procedure of object;
  {: TOpNestedForEachProc is the signature for the callback method passed to the ForEachItem method
     of TOpNestedCollection}
  TOpNestedForEachProc = procedure (Item: TOpNestedCollectionItem) of object;
  {: TOpNestedFindItemProc is the signature for the callback method passed to the FindItem method
     of TOpNestedCollection}
  TOpNestedFindItemProc = function (var Key; Item: TOpNestedCollectionItem): Boolean of object;
  {: Callback method used to notify the Assistant that the Office Component has connected.}
  TOpOfficeConnectEvent = procedure (Instance: TOpOfficeComponent; Connect: Boolean) of object;

  {Enums}

  TOpPropDirection = (pdToServer, pdFromServer);
  TOpCallType = (ctMethod, ctProperty);
  TOpClientState = set of (csConnecting, csDisconnecting, csInEvent);
  TOpOfficeVersion = (ovUnknown, ov97, ov98, ov2000, ovXP);          {!!.63}

  TOpGetInstanceEvent = procedure (Sender: TObject; var Instance: IDispatch;
    const CLSID, IID: TGUID) of object;

  EOpOfficeError = class(Exception);

  TOpBaseComponent = class(TComponent)
  private
    function GetVersion : string;
    procedure SetVersion(const Value : string);
  published
    property Version : string
      read GetVersion write SetVersion;
  end;

  {: TOpOfficeComponent is the base class for the main OfficePartner components.
     Base class functionality is introduced for Automation event support, correctly handling property
     fixups, and creation of Automation server (CoClass) instances.}
  TOpOfficeComponent = class(TOpBaseComponent)
  private
    FClientState: TOpClientState;
    FConnectListeners: TList;
    FEvents: TOpEventAdapter;
    FMachineName: WideString;
    FPropDirection: TOpPropDirection;
    FStreamedConnected: Boolean;
    FOnOpConnect: TNotifyEvent;
    FOnOpDisconnect: TNotifyEvent;
    FOnGetInstance: TOpGetInstanceEvent;
    procedure CallConnectListeners(Connect: Boolean);
    procedure SetMachineName(const Value: WideString);
  protected
    FOfficeVersion: TOpOfficeVersion;
    function ParseOfficeVersion(VersionStr: string): TOpOfficeVersion; virtual;
    procedure DoConnect; virtual; abstract;
    procedure DoDisconnect; virtual; abstract;
    {: Virtual method intended to call the OnOpConnect event. }
    procedure DoOpConnect; virtual;
    {: Virtual method intended to call the OnOpDisconnect event. }
    procedure DoOpDisconnect; virtual;
    {: Virtual method intended to call the DoGetInstance event. }
    procedure DoGetInstance(var Instance: IDispatch; const CLSID, IID: TGUID); virtual;
    procedure FixupProps; virtual;
    function GetOfficeVersion: TOpOfficeVersion; virtual;
    function GetOfficeVersionStr: string; virtual;
    procedure UpdateDesigner;
    function CheckActive(RaiseException: Boolean; CallType: TOpCallType): Boolean;
    procedure CreateEvents(Server: IUnknown; EventsIID: TIID); virtual;
    function GetConnected: Boolean; virtual; abstract;
    procedure Loaded; override;
    procedure SetConnected(Value: Boolean);
    property Events: TOpEventAdapter read FEvents write FEvents;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {: The AddConnectListener is used to notify external objects (e.g. TOpAssistant) that the
       Office Component has connected.}
    procedure AddConnectListener(Listener: TOpOfficeConnectEvent);
    {: An customized OfficePartner routine for creating CoClasses.  Uses MultiQI to reduce
       round trips to the server when using DCOM.}
    function CoCreate(const CoClass: TCLSID; const Intf: TIID; out Obj): HRESULT; virtual;
    {: All Collection children delegate initial Automation connections to this method.  This is
       done so that the component can properly synchronize and manage CoClass/Interface retrieval
       and maintenance.  Developers should not call this method directly.}
    function CreateItem(Item: TOpNestedCollectionItem): IDispatch; virtual; abstract;
    {: Returns system/application information from the Automation server in "Key=Value" pairs.  If the component
       is not connected, this method will temporarily launch the server.}
    procedure GetAppInfo(Info: TStrings); virtual; abstract;
    {: Returns filename extensions supported by this component.}
    procedure GetFileInfo(var Filter, DefExt: string); virtual;
    {: HandleEvent is overridden in each TOpOfficeComponent subclass in order to correctly dispatch
       Automation events to VCL Event Handlers.}
    procedure HandleEvent(const IID: TIID; DispId: Integer; const Params: TVariantArgList); virtual; abstract;
    {: The OfficeVersion property indicates the Office product version to }
    {  which the component is connected. }
    property OfficeVersion: TOpOfficeVersion read GetOfficeVersion;
    {: The OfficeVersionStr property contains the string (if available) }
    { representing the version number of the Office product to which the }
    { component is connected. }
    property OfficeVersionStr: string read GetOfficeVersionStr;
    {: The RemoveConnectListener is used to unregister an external object (such as TOpAssistant) from
       receiving connection notifications.}
    procedure RemoveConnectListener(Listener: TOpOfficeConnectEvent);
    {: A set of TClientState enums that allows the Office Component to tell if it is
       connecting, disconnecting, or receiving events.}
    property ClientState: TOpClientState read FClientState write FClientState;
    property Connected: Boolean read GetConnected write SetConnected default False;
    {: Used for DCOM, An Office Component can be launched on another computer provided DCOM is configured
       correctly.}
    property MachineName: WideString read FMachineName write SetMachineName;
    {: The PropDirection property controls what happens to
     the component properties when the component is initially connected.  If PropDirection is pdToServer,
     the streamed design-time properties will be pushed to the Automation server immediately after the server is launched.
     If PropDirection is set to pdFromServer, the streamed properties will be ignored and the
     component properties will represent the state of the server when it is launched.}
    //#<Events>
    property PropDirection: TOpPropDirection read FPropDirection write FPropDirection default pdToServer;
    {: The OnOpConnect event is fired after the component connects to the
       Office application Automation server. }
    property OnOpConnect: TNotifyEvent read FOnOpConnect write FOnOpConnect;
    {: The OnOpDisconnect event is fired immediately prior to the component
       disconnecting from the Office application Automation server. }
    property OnOpDisconnect: TNotifyEvent read FOnOpDisconnect write FOnOpDisconnect;
    {: The OnGetInstance event enables the client to customize how the component
       obtains the instance of the Office Automation application.  Leave this
       event unhandled in order to cause the Automation server to be created
       traditionally via CoCreateInstance or CoCreateInstanceEx.
       IMPORTANT:
       If you choose to handle this method, keep in mind that it is the
       responsibility of the event handler to ensure that the instance returned
       in the Instance parameter is of the type of interface specified by the
       IID parameter surfaced by a COM class of the type specified by the CLSID
       parameter. }
    property OnGetInstance: TOpGetInstanceEvent read FOnGetInstance write FOnGetInstance;
    //#</Events>
  end;

  {: TOpNestedCollection is a TCollection descendant that holds TOpNestedCollectionItems.  TOpNestedCollection
     introduces functionality which allows easy navigation throughout collection hierarchies.}
  TOpNestedCollection = class(TCollection)
  private
    FOwner : TPersistent;
    FRootComponent: TComponent;
    function GetParentItem: TOpNestedCollectionItem;
    function GetRootCollection: TOpNestedCollection;
  protected
    function GetItemName: string; virtual;
    function GetOwner: TPersistent; override;
  public
    constructor Create(RootComponent: TComponent; Owner: TPersistent; ItemClass: TCollectionItemClass); virtual;
    {: The ForEachItem method will iterate through the entire Nested Collection hierarchy, calling the
       method passed in the Proc parameter for each TOpNestedCollectionItem.}
    procedure ForEachItem(Proc: TOpNestedForEachProc); virtual;
    {: The FindItem method iterates the entire collection and calls the callback method passed in Proc.
       The callback method is free to implement any algorithm to match the untyped Key parameter
       with a Nested Collection Item.  The callback should return True if it finds a match and FindItem
       with automatically add the Item to the FindList parameter (which must be allocated by the
       caller.  Once FindItem returns, FindList will be populated with all of the matched items.}
    function FindItem(var Key; Proc: TOpNestedFindItemProc; FindList: TList): Boolean; virtual;
    {: The RootComponent property returns the TComponent (usually a descendant of TOpOfficeComponent)
       that owns the entire Nested Collection hierarchy.}
    property RootComponent: TComponent read FRootComponent;
    {: The RootCollection property returns the TCollection at the top of the Nested
       Collection hierarchy.}
    property RootCollection: TOpNestedCollection read GetRootCollection;
    {: The ParentItem property returns the TOpNestedCollectionItem that owns this Nested Collection.}
    property ParentItem: TOpNestedCollectionItem read GetParentItem;
    {: Readable class name for designer support.}
    property ItemName: string read GetItemName;
    {: Exposed for designer support.}
    property PropName;
  end;

  {: TOpNestedCollectionItem is a descendant of TCollectionItem.  This class implements functionality
     which allows it to own other Collections and be queried for the Collections it owns.  The TOpNestedCollectionItem
     class also implements functionality for easy navigation through a Nested Collection hierarchy.  Currently
     TOpNestedCollectionItem is also linked to our Office Automation functionality.}
  TOpNestedCollectionItem = class(TCollectionItem)
  private
    FIntf: IDispatch;
    function GetParent: TOpNestedCollection;
    function GetRootComponent: TComponent;
    function GetParentItem: TOpNestedCollectionItem;
    function GetIntf: IDispatch;
    procedure SetIntf(const Value: IDispatch);
    function GetRootCollection: TOpNestedCollection;
  protected
    function CheckActive(RaiseException: Boolean; CallType: TOpCallType): Boolean;
    function GetSubCollection(index: Integer): TCollection; virtual;
    function GetSubCollectionCount: Integer; virtual;
    procedure CreateSubCollections; virtual;
    function GetVerbCount: Integer; virtual;
    function GetVerb(index: Integer): string; virtual;
    procedure UpdateDesigner;
  public
    constructor Create(Collection: TCollection); override;
    {: The Connect method is called at construction time, and when the parent
       Office Component is Connected.  Care should be taked when overriding Connect as
       it may be called before the class has fully constructed.  Connect is used internally
       for fixing up Automation Server properties.}
    procedure Connect; virtual;
    procedure ExecuteVerb(index: Integer); virtual;
    procedure Activate; virtual;
    {: A raw IDispatch Automation interface representing the server entity we are connected to.
      Intf will be unassigned if the RootComponent is not connected, and for some TOpNestedCollectionItems
      may be unassigned even if the RootComponent is connected.}
    property Intf: IDispatch read GetIntf write SetIntf;
    {: The SubCollectionCount property specifies the number of child Collections that this
       item contains.}
    property SubCollectionCount: Integer read GetSubCollectionCount;
    {: The SubCollection array property can be used in conjunction with the SubCollectionCount
       property in order to dynamically retrieve Nested Collections.}
    property SubCollection[index: Integer]: TCollection read GetSubCollection;
    {: The ParentCollection property returns the TOpNestedCollection that owns this particular
       TOpNestedCollectionItem.}
    property ParentCollection: TOpNestedCollection read GetParent;
    {: The ParentItem property returns the TOpNestedCollectionItem that is the
       parent of this TOpNestedCollectionItem, skipping the TOpNestedCollection that
       sits between them.}
    property ParentItem: TOpNestedCollectionItem read GetParentItem;
    {: The RootComponent property returns the TComponent (usually a descendant of TOpOfficeComponent)
       that owns the entire Nested Collection hierarchy.}
    property RootComponent: TComponent read GetRootComponent;
    {: The RootCollection property returns the TCollection at the top of the Nested
       Collection hierarchy.}
    property RootCollection: TOpNestedCollection read GetRootCollection;
    {: Internal: Used for designer support.}
    property VerbCount: Integer read GetVerbCount;
    {: Internal: Used for designer support.}    
    property Verb[index: integer]: string read GetVerb;
  end;

  TOpFreeList = class(TList)
  public
    destructor Destroy; override;
  end;

procedure OfficeError(const S: string);

implementation

uses
  {$IFDEF TRIALRUN} OpTrial, {$ENDIF}
  {$IFNDEF VERSION3} ComConst, {$ENDIF}
   Windows, Dialogs, ComObj, OpConst;

var
  ComObjDispCallByIdProc: Pointer;

procedure OfficeError(const S: string);
begin
  raise EOpOfficeError.Create(S);
end;

  { TOpBaseComponent }

function TOpBaseComponent.GetVersion : string;
begin
  Result := OpConst.SVersion;
end;

procedure TOpBaseComponent.SetVersion(const Value : string);
begin
  { NOP }
end;


{ TOpNestedCollectionItem }

procedure TOpNestedCollectionItem.Activate;
begin
  //  NOP: for backward compatability don't want abstract.
end;

function TOpNestedCollectionItem.CheckActive(RaiseException: Boolean;
  CallType: TOpCallType): Boolean;
begin
  Result := (RootComponent as TOpOfficeComponent).CheckActive(RaiseException,CallType);
end;

procedure TOpNestedCollectionItem.Connect;
begin
  FIntf := (RootComponent as TOpOfficeComponent).CreateItem(self);
end;

constructor TOpNestedCollectionItem.Create(Collection: TCollection);
begin
{$IFDEF TRIALRUN}
  _CC_;
  _VC_;
{$ENDIF}

  inherited Create(Collection);
  CreateSubCollections;
  if not(csLoading in RootComponent.ComponentState) then Connect;
end;

procedure TOpNestedCollectionItem.CreateSubCollections;
begin
  //Not abstract, not forcing subclasses to CreateSubcollections if they have none.
end;

procedure TOpNestedCollectionItem.ExecuteVerb(index: Integer);
begin

end;

function TOpNestedCollectionItem.GetIntf: IDispatch;
begin
  result := FIntf;
end;

function TOpNestedCollectionItem.GetParent: TOpNestedCollection;
begin
  if (Collection is TOpNestedCollection) then
    Result := TOpNestedCollection(Collection)
  else
    Result := nil;
end;

function TOpNestedCollectionItem.GetParentItem: TOpNestedCollectionItem;
begin
  if (Collection is TOpNestedCollection) then
    result := TOpNestedCollection(Collection).ParentItem
  else
    result := nil;
end;

function TOpNestedCollectionItem.GetRootCollection: TOpNestedCollection;
begin
  Result := ParentCollection.RootCollection;
end;

function TOpNestedCollectionItem.GetRootComponent: TComponent;
begin
  if assigned(ParentCollection) then
    result := ParentCollection.RootComponent
  else
    result := nil;
end;

function TOpNestedCollectionItem.GetSubCollection(
  index: Integer): TCollection;
begin
  Result := nil;
end;

function TOpNestedCollectionItem.GetSubCollectionCount: Integer;
begin
  Result := 0;
end;


function TOpNestedCollectionItem.GetVerb(index: Integer): string;
begin

end;

function TOpNestedCollectionItem.GetVerbCount: Integer;
begin
  Result := 0;
end;

procedure TOpNestedCollectionItem.SetIntf(const Value: IDispatch);
begin
  FIntf := Value;
end;

procedure TOpNestedCollectionItem.UpdateDesigner;
begin
  (RootComponent as TOpOfficeComponent).UpdateDesigner;
end;

{ TOpNestedCollection }


constructor TOpNestedCollection.Create(RootComponent: TComponent;
  Owner: TPersistent; ItemClass: TCollectionItemClass);
begin
  FOwner := Owner;
  inherited Create(ItemClass);
  FRootComponent := RootComponent;

{$IFDEF TRIALRUN}
  _CC_;
  _VC_;
{$ENDIF}
end;

function TOpNestedCollection.FindItem(var Key; Proc: TOpNestedFindItemProc; FindList: TList): Boolean;
var
  i,j : Integer;
  Item : TOpNestedCollectionItem;
  Found: Boolean;
begin
  Result := False;
  for i := 0 to Count - 1 do
  begin
    Item := Items[i] as TOpNestedCollectionItem;
    Found := Proc(Key,Item);
    Result :=  Found or Result;
    if Found then
    begin
      if FindList <> nil then FindList.Add(Item);
    end;
    for j := 0 to Item.SubCollectionCount - 1 do
    begin
      Result := Result or (Item.SubCollection[j] as TOpNestedCollection).FindItem(Key, Proc, FindList);
    end;
  end;
end;

procedure TOpNestedCollection.ForEachItem(Proc: TOpNestedForEachProc);
var
  i,j : Integer;
  Item : TOpNestedCollectionItem;
begin
  for i := 0 to Count - 1 do
  begin
    Item := Items[i] as TOpNestedCollectionItem;
    Proc(Item);
    for j := 0 to Item.SubCollectionCount - 1 do
    begin
      (Item.SubCollection[j] as TOpNestedCollection).ForEachItem(proc);
    end;
  end;
end;

function TOpNestedCollection.GetItemName: string;
begin
  Result := SNestedItem;
end;

function TOpNestedCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TOpNestedCollection.GetParentItem: TOpNestedCollectionItem;
begin
  if (GetOwner is TOpNestedCollectionItem) then
    Result := TOpNestedCollectionItem(GetOwner)
  else
    Result := nil;
end;

function TOpNestedCollection.GetRootCollection: TOpNestedCollection;
begin
  Result := self;
  while assigned(Result.ParentItem) do
    Result := Result.ParentItem.ParentCollection;
end;

{ TOpOfficeComponent }

constructor TOpOfficeComponent.Create(AOwner: TComponent);
begin
{$IFDEF TRIALRUN}
  _CC_;
  _VC_;
{$ENDIF}
  inherited Create(AOwner);
  FConnectListeners := TList.Create;
  FPropDirection := pdToServer;
end;

destructor TOpOfficeComponent.Destroy;
var
  I: Integer;
begin
  Connected := False;
  for I := 0 to FConnectListeners.Count - 1 do
    FreeMem(FConnectListeners[I]);
  FConnectListeners.Free;
  inherited Destroy;
end;

function TOpOfficeComponent.CoCreate(const CoClass: TCLSID; const Intf: TIID;
  out Obj): HRESULT;
const
  CreateRemoteFlags: array[Boolean] of DWORD = (
    CLSCTX_LOCAL_SERVER or CLSCTX_INPROC_SERVER or CLSCTX_REMOTE_SERVER,
    CLSCTX_REMOTE_SERVER);
var
  RunRemotely: Boolean;
  MQI: TMultiQI;
  ServerInfo: TCoServerInfo;
  Size: DWORD;
  LocalMachine: array [0..MAX_COMPUTERNAME_LENGTH] of char;
begin
  IDispatch(Obj) := nil;
  // We first give the component the opportunity to provide the instance by
  // calling the DoGetInstance method, which fires the OnGetInstance
  // event.  If no instance comes from there, we try to get an instance using
  // CoCreateInstance or CoCreateInstanceEx.
  DoGetInstance(IDispatch(Obj), CoClass, Intf);
  if IDispatch(Obj) = nil then
  begin
    if FMachineName = '' then
      // If MachineName is empty, object is local, so we first try to get the
      // instance from CoCreateInstance.
      Result := CoCreateInstance(CoClass, nil, CLSCTX_INPROC_SERVER or
        CLSCTX_LOCAL_SERVER, Intf, Obj)
    else begin
      // If MachineName isn't empty, we will create it via CoCreateInstanceEx, and
      // allow local creation only when MachineName matches the name of the current
      // machine.
      if @OpCoCreateInstanceEx = nil then
        OfficeError(SNeedDCOM);
      Size := SizeOf(LocalMachine);
      RunRemotely := GetComputerName(LocalMachine, Size) and
        (AnsiCompareText(LocalMachine, FMachineName) <> 0);
      FillChar(ServerInfo, SizeOf(ServerInfo), 0);
      ServerInfo.pwszName := PWideChar(FMachineName);
      MQI.IID := @Intf;
      MQI.itf := nil;
      MQI.hr := 0;
      Result := OpCoCreateInstanceEx(CoClass, nil, CreateRemoteFlags[RunRemotely],
        @ServerInfo, 1, @MQI);
      if Result = S_OK then Result := MQI.HR;
      if Result = S_OK then
      begin
        IUnknown(Obj) := MQI.itf;
        IUnknown(Obj)._AddRef;
      end
      else
        Pointer(Obj) := nil;
    end;
  end
  else Result := S_OK;
end;

procedure TOpOfficeComponent.CreateEvents(Server: IUnknown; EventsIID: TIID);
begin
  FEvents := TOpEventAdapter.Create(Server, HandleEvent);
  FEvents.AddEvents(EventsIID);
end;

procedure TOpOfficeComponent.GetFileInfo(var Filter, DefExt: string);
begin
  Filter := SAllFiles;
  DefExt := '';
end;

procedure TOpOfficeComponent.SetMachineName(const Value: WideString);
begin
  if AnsiCompareText(FMachineName, Value) <> 0 then
  begin
    if Connected then
      OfficeError(SCantSetWhileConnected);
    FMachineName := Value;
  end;
end;

function TOpOfficeComponent.CheckActive(RaiseException: Boolean;
  CallType: TOpCallType): Boolean;
begin
  Result := Connected;
  if RaiseException and not Result then
  begin
    if CallType = ctMethod then
      OfficeError(SMethodNeedsConnection)
    else
      OfficeError(SPropNeedsConnection)
  end;
end;

procedure TOpOfficeComponent.Loaded;
begin
  inherited Loaded;
  SetConnected(FStreamedConnected);
end;

procedure TOpOfficeComponent.SetConnected(Value: Boolean);
const
  ConnectStates: array[Boolean] of TOpClientState = ([csDisconnecting],
    [csConnecting]);
begin
  if csLoading in ComponentState then
    FStreamedConnected := Value
  else if Value <> GetConnected then
  begin
    ClientState := ClientState + ConnectStates[Value];
    try
      if Value then
      begin
        DoConnect;
        FixupProps;
        DoOpConnect;
      end
      else begin
        DoOpDisconnect;
        DoDisconnect;
        FOfficeVersion := ovUnknown;
      end;
    finally
      ClientState := ClientState - ConnectStates[Value];
    end;
    CallConnectListeners(Value);
  end;
end;

procedure TOpOfficeComponent.UpdateDesigner;
begin
  if assigned(Owner) and (Owner is TCustomForm) then
  begin
    if assigned(TCustomForm(Owner).Designer) then
      TCustomForm(Owner).Designer.Modified;
  end;
end;

procedure TOpOfficeComponent.AddConnectListener(Listener: TOpOfficeConnectEvent);
var
  Proc: Pointer;
begin
  Proc := AllocMem(SizeOf(TOpOfficeConnectEvent));
  Move(Listener, Proc^, SizeOf(TOpOfficeConnectEvent));
  FConnectListeners.Add(Proc);
end;

procedure TOpOfficeComponent.RemoveConnectListener(Listener: TOpOfficeConnectEvent);
var
  I: Integer;
begin
  for I := 0 to FConnectListeners.Count - 1 do
  begin
    if @TOpOfficeConnectEvent(FConnectListeners[I]^) = @Listener then
    begin
      FreeMem(FConnectListeners[I]);
      FConnectListeners.Delete(I);
      Exit;
    end;
  end;
end;

procedure TOpOfficeComponent.CallConnectListeners(Connect: Boolean);
var
  I: Integer;
begin
  for I := 0 to FConnectListeners.Count - 1 do
    TOpOfficeConnectEvent(FConnectListeners[I]^)(Self, Connect);
end;

procedure TOpOfficeComponent.FixupProps;
begin
  // This space intentionally left blank
end;

procedure TOpOfficeComponent.DoOpConnect;
begin
  if Assigned(FOnOpConnect) then FOnOpConnect(Self);
end;

procedure TOpOfficeComponent.DoOpDisconnect;
begin
  if Assigned(FOnOpDisconnect) then FOnOpDisconnect(Self);
end;

procedure TOpOfficeComponent.DoGetInstance(var Instance: IDispatch;
  const CLSID, IID: TIID);
begin
  if Assigned(FOnGetInstance) then FOnGetInstance(Self, Instance, CLSID, IID);
end;

function TOpOfficeComponent.ParseOfficeVersion(VersionStr: string): TOpOfficeVersion;
var
  P, MajorVer, Code: Integer;
begin
  Result := ovUnknown;
  if (VersionStr <> '') then
  begin
    P := AnsiPos('.', VersionStr);
    if P > 1 then
      VersionStr := Copy(VersionStr, 1, P - 1);
    Val(VersionStr, MajorVer, Code);
    if (Code = 0) and (MajorVer = 9) then                            {!!.63}
      Result := ov2000                                               {!!.63}
    else if (Code = 0) and (MajorVer = 10) then                      {!!.63}
      Result := ovXP                                                 {!!.63}
    else
      Result := ov97;
  end;
end;

function TOpOfficeComponent.GetOfficeVersion: TOpOfficeVersion;
begin
  if Connected and (FOfficeVersion = ovUnknown) then
    FOfficeVersion := ParseOfficeVersion(OfficeVersionStr);
  Result := FOfficeVersion;
end;

function TOpOfficeComponent.GetOfficeVersionStr: string;
begin
  Result := '';
end;


{ TOpFreeList }

destructor TOpFreeList.Destroy;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    TObject(Items[I]).Free;
  inherited Destroy;
end;

procedure LoadDCOMProcs;
var
  Ole32: HModule;
begin

{$IFDEF TRIALRUN}
  _CC_;
  _VC_;
{$ENDIF}

  Ole32 := GetModuleHandle('ole32.dll');
  if Ole32 <> 0 then
  begin
    @OpCoCreateInstanceEx := GetProcAddress(Ole32,'CoCreateInstanceEx');
  end;
end;

// Replace assembler routines from ComObj.pas to fix incorrect stack push for GUID_NULL in CBUilder.

procedure DispCallError(Status: Integer; var ExcepInfo: TExcepInfo;
  ErrorAddr: Pointer; FinalizeExcepInfo: Boolean);
var
  E: Exception;
begin
  if Status = Integer(DISP_E_EXCEPTION) then
  begin
    with ExcepInfo do
      E := EOleException.Create(bstrDescription, scode, bstrSource,
        bstrHelpFile, dwHelpContext);
    if FinalizeExcepInfo then
      Finalize(ExcepInfo);
  end else
    E := EOleSysError.Create('', Status, 0);
  if ErrorAddr <> nil then
    raise E at ErrorAddr
  else
    raise E;
end;

procedure ClearExcepInfo(var ExcepInfo: TExcepInfo);
begin
  FillChar(ExcepInfo, SizeOf(ExcepInfo), 0);
end;

const
{ Parameter type masks }

  atVarMask  = $3F;
  atTypeMask = $7F;
  atByRef    = $80;


procedure OpDispCall(const Dispatch: IDispatch; CallDesc: PCallDesc;
  DispID: Integer; NamedArgDispIDs, Params, Result: Pointer); stdcall;
type
  TExcepInfoRec = record  // mock type to avoid auto init and cleanup code
    wCode: Word;
    wReserved: Word;
    bstrSource: PWideChar;
    bstrDescription: PWideChar;
    bstrHelpFile: PWideChar;
    dwHelpContext: Longint;
    pvReserved: Pointer;
    pfnDeferredFillIn: Pointer;
    scode: HResult;
  end;
const
  NULLGUID: TGUID = '{00000000-0000-0000-0000-000000000000}';
var
  DispParams: TDispParams;
  ExcepInfo: TExcepInfoRec;
asm
        PUSH    EBX
        PUSH    ESI
        PUSH    EDI
        MOV     EBX,CallDesc
        XOR     EDX,EDX
        MOV     EDI,ESP
        MOVZX   ECX,[EBX].TCallDesc.ArgCount
        MOV     DispParams.cArgs,ECX
        TEST    ECX,ECX
        JE      @@10
        ADD     EBX,OFFSET TCallDesc.ArgTypes
        MOV     ESI,Params
@@1:    MOVZX   EAX,[EBX].Byte
        TEST    AL,atByRef
        JNE     @@3
        CMP     AL,varVariant
        JE      @@2
        CMP     AL,varDouble
        JB      @@4
        CMP     AL,varDate
        JA      @@4
        PUSH    [ESI].Integer[4]
        PUSH    [ESI].Integer[0]
        PUSH    EDX
        PUSH    EAX
        ADD     ESI,8
        JMP     @@5
@@2:    PUSH    [ESI].Integer[12]
        PUSH    [ESI].Integer[8]
        PUSH    [ESI].Integer[4]
        PUSH    [ESI].Integer[0]
        ADD     ESI,16
        JMP     @@5
@@3:    AND     AL,atTypeMask
        OR      EAX,varByRef
@@4:    PUSH    EDX
        PUSH    [ESI].Integer[0]
        PUSH    EDX
        PUSH    EAX
        ADD     ESI,4
@@5:    INC     EBX
        DEC     ECX
        JNE     @@1
        MOV     EBX,CallDesc
@@10:   MOV     DispParams.rgvarg,ESP
        MOVZX   EAX,[EBX].TCallDesc.NamedArgCount
        MOV     DispParams.cNamedArgs,EAX
        TEST    EAX,EAX
        JE      @@12
        MOV     ESI,NamedArgDispIDs
@@11:   PUSH    [ESI].Integer[EAX*4-4]
        DEC     EAX
        JNE     @@11
@@12:   MOVZX   ECX,[EBX].TCallDesc.CallType
        CMP     ECX,DISPATCH_PROPERTYPUT
        JNE     @@20
        PUSH    DISPID_PROPERTYPUT
        INC     DispParams.cNamedArgs
        CMP     [EBX].TCallDesc.ArgTypes.Byte[0],varDispatch
        JE      @@13
        CMP     [EBX].TCallDesc.ArgTypes.Byte[0],varUnknown
        JNE     @@20
@@13:   MOV     ECX,DISPATCH_PROPERTYPUTREF
@@20:   MOV     DispParams.rgdispidNamedArgs,ESP
        PUSH    EDX                     { ArgErr }
        LEA     EAX,ExcepInfo
        PUSH    EAX                     { ExcepInfo }
        PUSH    ECX
        PUSH    EDX
        CALL    ClearExcepInfo
        POP     EDX
        POP     ECX
        PUSH    Result                  { VarResult }
        LEA     EAX,DispParams
        PUSH    EAX                     { Params }
        PUSH    ECX                     { Flags }
        PUSH    EDX                     { LocaleID }
        PUSH    OFFSET NULLGUID         { IID }
        PUSH    DispID                  { DispID }
        MOV     EAX,Dispatch
        PUSH    EAX
        MOV     EAX,[EAX]
        CALL    [EAX].Pointer[24]
        TEST    EAX,EAX
        JE      @@30
        LEA     EDX,ExcepInfo
        MOV     CL, 1
        PUSH    ECX
        MOV     ECX,[EBP+4]
        JMP     DispCallError
@@30:   MOV     ESP,EDI
        POP     EDI
        POP     ESI
        POP     EBX
end;

procedure OpDispCallByID(Result: Pointer; const Dispatch: IDispatch;
  DispDesc: PDispDesc; Params: Pointer); cdecl;
asm
        PUSH    EBX
        MOV     EBX,DispDesc
        XOR     EAX,EAX
        PUSH    EAX
        PUSH    EAX
        PUSH    EAX
        PUSH    EAX
        MOV     EAX,ESP
        PUSH    EAX
        LEA     EAX,Params
        PUSH    EAX
        PUSH    EAX
        PUSH    [EBX].TDispDesc.DispID
        LEA     EAX,[EBX].TDispDesc.CallDesc
        PUSH    EAX
        PUSH    Dispatch
        CALL    OpDispCall
        MOVZX   EAX,[EBX].TDispDesc.ResType
        MOV     EBX,Result
        JMP     @ResultTable.Pointer[EAX*4]

@ResultTable:
        DD      @ResEmpty
        DD      @ResNull
        DD      @ResSmallint
        DD      @ResInteger
        DD      @ResSingle
        DD      @ResDouble
        DD      @ResCurrency
        DD      @ResDate
        DD      @ResString
        DD      @ResDispatch
        DD      @ResError
        DD      @ResBoolean
        DD      @ResVariant
        DD      @ResUnknown
        DD      @ResDecimal
        DD      @ResError
        DD      @ResByte

@ResSingle:
        FLD     [ESP+8].Single
        JMP     @ResDone

@ResDouble:
@ResDate:
        FLD     [ESP+8].Double
        JMP     @ResDone

@ResCurrency:
        FILD    [ESP+8].Currency
        JMP     @ResDone

@ResString:
        MOV     EAX,[EBX]
        TEST    EAX,EAX
        JE      @@1
        PUSH    EAX
        CALL    SysFreeString
@@1:    MOV     EAX,[ESP+8]
        MOV     [EBX],EAX
        JMP     @ResDone

@ResDispatch:
@ResUnknown:
        MOV     EAX,[EBX]
        TEST    EAX,EAX
        JE      @@2
        PUSH    EAX
        MOV     EAX,[EAX]
        CALL    [EAX].Pointer[8]
@@2:    MOV     EAX,[ESP+8]
        MOV     [EBX],EAX
        JMP     @ResDone

@ResVariant:
        MOV     EAX,EBX
        {$IFDEF VERSION7}
          CALL    Variants.@VarClear
        {$ELSE}
          CALL    System.@VarClear
        {$ENDIF}
        MOV     EAX,[ESP]
        MOV     [EBX],EAX
        MOV     EAX,[ESP+4]
        MOV     [EBX+4],EAX
        MOV     EAX,[ESP+8]
        MOV     [EBX+8],EAX
        MOV     EAX,[ESP+12]
        MOV     [EBX+12],EAX
        JMP     @ResDone

@ResSmallint:
@ResInteger:
@ResBoolean:
@ResByte:
        MOV     EAX,[ESP+8]

@ResDecimal:
@ResEmpty:
@ResNull:
@ResError:
@ResDone:
        ADD     ESP,16
        POP     EBX
end;


initialization
  LoadDCOMProcs;
{$IFDEF VERSION3}
  TVarData(EmptyParam).VType := varError;
  TVarData(EmptyParam).VError := $80020004; {DISP_E_PARAMNOTFOUND}
{$ENDIF}
  DispCallByIdProc := @OpDispCallById;
  OleInitialize(nil);
finalization
  DispCallByIdProc := ComObjDispCallByIdProc;
  OleUnInitialize;

end.
