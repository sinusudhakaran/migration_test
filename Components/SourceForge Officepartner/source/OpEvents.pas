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

// Steps to use the EventAdapter from your office classes:
//
// 1.  Implement a method with the signature of TEventHandler.
//
// 2.  Create an instance on TOpEventAdapter, passing Automation Server
//     and TEventHandler callback.
//
// 3.  Call AddEvents for each event sink desired, passing the IID.
//
// 4.  Free when finished, all connection points will be UnAdvised.
//
//
// To Do:  Support multiple servers within single EventAdapter (Singleton ?)


unit OpEvents;

interface

uses classes, sysutils, activeX, windows;

type

  TEventHandler = procedure(const IID : TIID; DispID : Integer; const Params : TVariantArgList) of object;

  EEventSinkException = class(Exception);
  TOpEventOperation = (eoAdvise,eoUnadvise);

  TOpEventAdapter = class(TObject)
  private
    FServer : IUnknown;
    FHandler : TEventHandler;
    FEventList : TList;
    function DoesExist(IID : TIID) : boolean;
    function FindEvent(IID : TIID) : integer;
  public
    constructor Create(const Server : IUnknown ; Handler : TEventHandler);
    destructor Destroy; override;
    procedure AddEvents(const IID : TIID);
    procedure RemoveEvents(const IID : TIID);
    procedure RemoveAllEvents;
  end;

  TOpEventSink = class(TObject, IUnknown, IDispatch)
  private
    FServer : IUnknown;
    FCookie : integer;
    FHandler : TEventHandler;
    FIID : TIID;
    function InstallEvent(Op : TOpEventOperation) : boolean;
  public
    constructor Create(const Server : IUnknown; Handler : TEventHandler; const EventDisp : TIID);
    // IUnknown
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    // IDispatch
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
      destructor Destroy; override;
    property IID : TIID read FIID;
  end;

implementation

uses
  {$IFDEF TRIALRUN} OpTrial, {$ENDIF}
  {$IFDEF DEBUGEVENTSINKS} ComObj, {$ENDIF}
  dialogs;


{ TOpEventSink }
function TOpEventSink._AddRef: Integer;
begin
  Result := 1;
end;

function TOpEventSink._Release: Integer;
begin
  Result := 1;
end;

function TOpEventSink.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  Result := E_NOTIMPL ;
end;

function TOpEventSink.GetTypeInfo(Index, LocaleID: Integer;
  out TypeInfo): HResult;
begin
  pointer(TypeInfo) := nil;
  Result := E_NOTIMPL;
end;

function TOpEventSink.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Count := 0;
  Result := E_NOTIMPL;
end;

function TOpEventSink.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult;


var
  i : integer;
  CrackedParams : pVariantArgList;
  TempParams : TDispParams;
begin
  {Maybe a bit more expensive that necessary, could pass out Params with a fixed-up
   dispId list for named params, but component code would be messier }

  Result := S_OK;
  {$IFDEF DEBUGEVENTSINKS}
    OutputDebugString(pchar(inttostr(DispID) + ' - ' + GUIDToString(FIID)));
  {$ENDIF}

  //Optomize later, don't need to do this if no params.

  TempParams := TDispParams(Params);
  GetMem(CrackedParams,(sizeOf(TVariantArg) * TempParams.cArgs));
  try
    for i := 0 to TempParams.cArgs - 1 do
      CrackedParams^[i] := TempParams.rgvarg^[TempParams.cArgs - 1 - i];

    for i := 0 to TempParams.cNamedArgs - 1 do
      CrackedParams^[i] := TempParams.rgvarg^[TempParams.rgdispidNamedArgs^[i]];

    FHandler(FIID,DispId,CrackedParams^);
  finally
    FreeMem(CrackedParams,(sizeOf(TVariantArg) * TDispParams(Params).cArgs));
  end;


end;

function TOpEventSink.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID,Obj) then
    Result := S_OK
  else
  begin
    if IsEqualGuid(IID,FIID) then
      Result := QueryInterface(IDispatch,Obj)
    else
      Result := E_NOINTERFACE;
  end;
end;

constructor TOpEventSink.Create(const Server : IUnknown; Handler: TEventHandler; const EventDisp: TIID);
begin
  FServer := Server;
  FHandler := Handler;
  FIID := EventDisp;
  if not(InstallEvent(eoAdvise)) then raise EEventSinkException.Create('Cannot Register Events');

{$IFDEF TRIALRUN}
  _CC_;
  _VC_;
{$ENDIF}
end;

function TOpEventSink.InstallEvent(Op: TOpEventOperation): boolean;
var
  cpc : IConnectionPointContainer;
  cp  : IConnectionPoint;
begin
  Result := False;
  if succeeded(FServer.QueryInterface(IConnectionPointContainer,cpc)) then
  begin
    if succeeded(cpc.FindConnectionPoint(FIID,cp)) then
    begin
      case Op of
        eoAdvise   : Result := succeeded(Cp.Advise(self,FCookie));
        eoUnadvise : Result := succeeded(Cp.UnAdvise(FCookie));
      end;
    end;
  end;
end;

destructor TOpEventSink.Destroy;
begin
  InstallEvent(eoUnadvise);
  inherited Destroy;
end;

{ TOpEventAdapter }
procedure TOpEventAdapter.AddEvents(const IID: TIID);
begin
  if not(DoesExist(IID)) then
    FEventList.Add(TOpEventSink.Create(FServer,FHandler,IID));
end;

constructor TOpEventAdapter.Create(const Server: IUnknown;
  Handler: TEventHandler);
begin
  FEventList := TList.Create;
  FServer := Server;
  FHandler := Handler;

{$IFDEF TRIALRUN}
  _CC_;
  _VC_;
{$ENDIF}
end;

destructor TOpEventAdapter.Destroy;
begin
  RemoveAllEvents;
  FEventList.Free;
  inherited Destroy;
end;

function TOpEventAdapter.DoesExist(IID: TIID): boolean;
begin
  result := FindEvent(IID) <> -1;
end;

function TOpEventAdapter.FindEvent(IID: TIID): integer;
var
  i : Integer;
begin
  result := -1;
  for i := 0 to FEventList.Count - 1 do
  begin
    if IsEqualGUID(IID,TOpEventSink(FEventList[i]).IID) then
    begin
      result := i;
    end;
  end;
end;

procedure TOpEventAdapter.RemoveAllEvents;
var
  i : Integer;
begin
  for i := 0 to FEventList.Count - 1 do
  begin
    TObject(FEventList[i]).Free;
  end;
end;

procedure TOpEventAdapter.RemoveEvents(const IID: TIID);
var
  Event : integer;
begin
  Event :=  FindEvent(IID);
  if Event <> -1 then
  begin
    FEventList.Delete(Event);
  end;
end;

end.
