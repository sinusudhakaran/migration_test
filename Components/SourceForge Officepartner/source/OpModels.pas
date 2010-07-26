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

unit OpModels;

interface

uses Sysutils, Windows, Classes, OpShared {$IFDEF DCC6ORLATER} , Variants {$ENDIF};

type
  EUnsupportedMode = Exception;

  TOpRetrievalMode = (rmCell,rmPacket,rmEntire);
  TOpRetrievalModes = set of TOpRetrievalMode;

  TOpModelGetColHeadersEvent = procedure(Sender: TObject; var ColHeaders: Variant) of object;
  TOpModelGetColCountEvent = procedure(Sender: TObject; var ColCount: Integer) of object;
  TOpModelGetDataEvent = procedure(Sender: TObject; Index: Integer; Row: Integer;
                                   Mode: TOpRetrievalMode; var Size: Integer;
                                   var Data: Variant) of object;

  IOpModel = interface
  ['{AD426B00-2A14-11D3-9703-0000861F6726}']
    procedure First;
    procedure Last;
    procedure Next;
    procedure Prior;
    function GetSupportedModes: TOpRetrievalModes;
    function GetEOF: Boolean;
    function GetBOF: Boolean;
    function GetColCount: Integer;
    function GetCurrentRow: Integer;
    function GetVariableLengthRows: Boolean;
    function GetLevel: Integer;
    function GetColHeaders: Variant;
    procedure BeginRead;
    procedure EndRead;

    property EOF: Boolean read GetEOF;
    property BOF: Boolean read GetBOF;
    property ColCount: Integer read GetColCount;
    property VariableLengthRows: Boolean read GetVariableLengthRows;
    property Level: Integer read GetLevel;
    property ColHeaders: Variant read GetColHeaders;
    property CurrentRow : Integer read GetCurrentRow;
    function GetData(Index: Integer; Mode: TOpRetrievalMode;
                     var Size: Integer): Variant;
  end;

  TOpUnknownComponent = class(TOpBaseComponent, IUnknown)
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult;
      {$IFNDEF VERSION3}override;{$ENDIF}stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  TOpEventModel = class(TOpUnknownComponent, IOpModel)
  private
    FEof                : Boolean;
    FBof                : Boolean;
    FSupportedModes     : TOpRetrievalModes;
    FVariableLengthRows : Boolean;
    FCurrentRow         : Integer;
    FRowCount           : Integer;
    FOnGetData          : TOpModelGetDataEvent;
    FOnGetColCount      : TOpModelGetColCountEvent;
    FOnGetColHeaders    : TOpModelGetColHeadersEvent;
  protected
    procedure First;
    procedure Last;
    procedure Next;
    procedure Prior;
    function GetSupportedModes: TOpRetrievalModes;
    function GetEOF: Boolean;
    function GetBOF: Boolean;
    function GetColCount: Integer;
    function GetVariableLengthRows: Boolean;
    function GetLevel: Integer;
    function GetColHeaders: Variant;
    function GetCurrentRow : Integer;
    function GetData(Index: Integer; Mode: TOpRetrievalMode;
                     var Size: Integer): Variant;
    procedure BeginRead;
    procedure EndRead;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property CurrentRow : Integer
      read GetCurrentRow;
    property RowCount: Integer
      read FRowCount write FRowCount;
    property SupportedModes: TOpRetrievalModes
      read FSupportedModes write FSupportedModes;
    property VariableLengthRows: Boolean
      read FVariableLengthRows write FVariableLengthRows;
    property OnGetColCount: TOpModelGetColCountEvent
      read FOnGetColCount write FOnGetColCount;
    property OnGetColHeaders: TOpModelGetColHeadersEvent
      read FOnGetColHeaders write FOnGetColHeaders;
    property OnGetData: TOpModelGetDataEvent
      read FOnGetData write FOnGetData;
  end;

implementation

{$IFDEF TRIALRUN}
uses
  OpTrial;
{$ENDIF}

{ TOpComponentModel }

function TOpUnknownComponent.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID,Obj) then Result := S_OK else Result := E_NOINTERFACE;
end;

function TOpUnknownComponent._AddRef: Integer;
begin
  Result := 2;
end;

function TOpUnknownComponent._Release: Integer;
begin
  Result := 1;
end;

{ TOpEventModel }

procedure TOpEventModel.First;
begin
  FCurrentRow := 0;
  FBof := true;
  FEof := (FCurrentRow >= FRowCount);
end;

function TOpEventModel.GetBOF: Boolean;
begin
  Result := FBof;
end;

function TOpEventModel.GetColCount: Integer;
begin
  Result := 0;
  if assigned(FOnGetColCount) then FOnGetColCount(self,Result);
end;

function TOpEventModel.GetCurrentRow: Integer;
begin
  Result := FCurrentRow;
end;

function TOpEventModel.GetColHeaders: Variant;
begin
  Result := Null;
  if assigned(FOnGetColHeaders) then FOnGetColHeaders(self,Result);
end;

function TOpEventModel.GetEOF: Boolean;
begin
  Result := FEof;
end;

function TOpEventModel.GetLevel: Integer;
begin
  Result := 1;
end;

function TOpEventModel.GetSupportedModes: TOpRetrievalModes;
begin
  Result := FSupportedModes;
end;

function TOpEventModel.GetData(Index: Integer; Mode: TOpRetrievalMode;
                               var Size: Integer): Variant;
begin
  Size := 0;
  Result := null;
  if assigned(FOnGetData) then FOnGetData(Self, Index, FCurrentRow,
    Mode, Size, Result);
end;

procedure TOpEventModel.Last;
begin
  FCurrentRow := FRowCount - 1;
  FEof := true;
end;

procedure TOpEventModel.Next;
begin
  inc(FCurrentRow);
  FBof := false;
  if FCurrentRow >= FRowCount then
  begin
    FCurrentRow := FRowCount - 1;
    FEof := true;
  end;
end;

procedure TOpEventModel.Prior;
begin
  dec(FCurrentRow);
  FEof := False;
  if FCurrentRow < 0 then
  begin
    FCurrentRow := 0;
    FBof := true;
  end;
end;

constructor TOpEventModel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  First;

{$IFDEF TRIALRUN}
  _CC_;
  _VC_;
{$ENDIF}
end;

function TOpEventModel.GetVariableLengthRows: Boolean;
begin
  Result := FVariableLengthRows;
end;

procedure TOpEventModel.BeginRead;
begin
  // Not implemented for event model.
end;

procedure TOpEventModel.EndRead;
begin
  // Not implemented for event model.
end;

end.
