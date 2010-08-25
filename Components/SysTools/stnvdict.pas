{*********************************************************}
{* SysTools: StNVDict.pas 3.03                           *}
{* Copyright (c) TurboPower Software Co 1996, 2001       *}
{* All rights reserved.                                  *}
{*********************************************************}
{* SysTools: non visual component for TStDictionary      *}
{*********************************************************}

{$I StDefine.inc}

{$IFDEF WIN16}
  {$C MOVEABLE,DEMANDLOAD,DISCARDABLE}
{$ENDIF}

unit StNVDict;

interface

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  {$IFDEF WIN16}
  WinTypes, WinProcs,
  {$ENDIF}
  Classes,
  StBase, StDict, StNVCont;

type
  TStNVDictionary = class(TStNVContainerBase)
  {.Z+}
  protected {private}
    {property variables}
    FContainer : TStDictionary; {instance of the container}
    FHashSize  : Integer;

    {property methods}
    function GetHashSize : Integer;
    function GetOnEqual : TStStringCompareEvent;
    procedure SetHashSize(Value : Integer);
    procedure SetOnEqual(Value : TStStringCompareEvent);

  protected
    function GetOnDisposeData : TStDisposeDataEvent;
      override;
    function GetOnLoadData : TStLoadDataEvent;
      override;
    function GetOnStoreData : TStStoreDataEvent;
      override;
    procedure SetOnDisposeData(Value : TStDisposeDataEvent);
      override;
    procedure SetOnLoadData(Value : TStLoadDataEvent);
      override;
    procedure SetOnStoreData(Value : TStStoreDataEvent);
      override;

  public
    constructor Create(AOwner : TComponent);
      override;
    destructor Destroy;
      override;
  {.Z-}

    property Container : TStDictionary
      read FContainer;

  published
    property HashSize : Integer
      read GetHashSize
      write SetHashSize;

    property OnEqual : TStStringCompareEvent
      read GetOnEqual
      write SetOnEqual;

    property OnDisposeData;
    property OnLoadData;
    property OnStoreData;
  end;


implementation

{$IFDEF TRIALRUN}
uses
  {$IFDEF MSWINDOWS}
  Registry,
  {$ENDIF}
  {$IFDEF WIN16}
  Ver,
  {$ENDIF}
  Forms,
  IniFiles,
  ShellAPI,
  SysUtils,
  StTrial;
{$I TRIAL00.INC} {FIX}
{$I TRIAL01.INC} {CAB}
{$I TRIAL02.INC} {CC}
{$I TRIAL03.INC} {VC}
{$I TRIAL04.INC} {TCC}
{$I TRIAL05.INC} {TVC}
{$I TRIAL06.INC} {TCCVC}
{$ENDIF}


{*** TStNVDictionary ***}

constructor TStNVDictionary.Create(AOwner : TComponent);
begin
  {$IFDEF TRIALRUN} TCCVC; {$ENDIF}
  inherited Create(AOwner);

  {defaults}
  FHashSize := 509;

  if Classes.GetClass(TStDictionary.ClassName) = nil then
    RegisterClass(TStDictionary);
  if Classes.GetClass(TStDictNode.ClassName) = nil then
    RegisterClass(TStDictNode);

  FContainer := TStDictionary.Create(FHashSize);
end;

destructor TStNVDictionary.Destroy;
begin
  FContainer.Free;
  FContainer := nil;

  inherited Destroy;
end;

function TStNVDictionary.GetHashSize : Integer;
begin
  Result := FContainer.HashSize;
end;

function TStNVDictionary.GetOnDisposeData : TStDisposeDataEvent;
begin
  Result := FContainer.OnDisposeData;
end;

function TStNVDictionary.GetOnEqual : TStStringCompareEvent;
begin
  Result := FContainer.OnEqual;
end;

function TStNVDictionary.GetOnLoadData : TStLoadDataEvent;
begin
  Result := FContainer.OnLoadData;
end;

function TStNVDictionary.GetOnStoreData : TStStoreDataEvent;
begin
  Result := FContainer.OnStoreData;
end;

procedure TStNVDictionary.SetHashSize(Value : Integer);
begin
  FContainer.HashSize := Value;
end;

procedure TStNVDictionary.SetOnDisposeData(Value : TStDisposeDataEvent);
begin
  FContainer.OnDisposeData := Value;
end;

procedure TStNVDictionary.SetOnEqual(Value : TStStringCompareEvent);
begin
  FContainer.OnEqual := Value;
end;

procedure TStNVDictionary.SetOnLoadData(Value : TStLoadDataEvent);
begin
  FContainer.OnLoadData := Value;
end;

procedure TStNVDictionary.SetOnStoreData(Value : TStStoreDataEvent);
begin
  FContainer.OnStoreData := Value;
end;



end.