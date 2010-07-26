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

unit OpDbOfc;

interface

uses Sysutils, Classes, Db, OpModels {$IFDEF DCC6ORLATER}, Variants {$ENDIF} ;

type

  EModelException = class(Exception);

  TOpDataSetModel = class(TOpUnknownComponent, IOpModel)
  private
    FWantFullMemos      : Boolean;
    FDataset            : TDataset;
    FDetailModel        : TOpDataSetModel;
    FInDetail           : Boolean;
    FCurrentPos         : TBookmark;
    function GetRowData : Variant;
    function GetText(Index: Integer): string;
    procedure SetDetailModel(const Value: TOpDataSetModel);
    procedure SetDataset(const Value: TDataset);
  protected
    { IOpModel Implementation}
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
    function GetCurrentRow: Integer;
    function GetData(Index: Integer; Mode: TOpRetrievalMode;
                     var Size: Integer): Variant;
    procedure BeginRead;
    procedure EndRead;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AOwner: TComponent); override;

  published
    property Dataset: TDataset
      read FDataset write SetDataset;
    property DetailModel: TOpDataSetModel
      read FDetailModel write SetDetailModel;
    property WantFullMemos: Boolean
      read FWantFullMemos write FWantFullMemos;
  end;

implementation

uses
  {$IFDEF TRIALRUN} OpTrial, {$ENDIF}
  OpConst;

{ TOpDataSetModel }

constructor TOpDataSetModel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FInDetail := false;

{$IFDEF TRIALRUN}
  _CC_;
  _VC_;
{$ENDIF}
end;

procedure TOpDataSetModel.First;
begin
  if assigned(FDataset) then
    FDataset.First;
end;

function TOpDataSetModel.GetBOF: Boolean;
begin
  Result := false;
  if assigned(FDataset) then
    Result := FDataset.Bof;
end;

function TOpDataSetModel.GetColCount: Integer;
begin
  Result := 0;
  if assigned(FDataset) then
  begin
    if FInDetail then
      Result := FDetailModel.GetColCount
    else
      Result := FDataset.FieldCount;
  end;
end;

function TOpDataSetModel.GetCurrentRow: Integer;
  { Not used by DataSetModel }
begin
  Result := 0;
end;

function TOpDataSetModel.GetEOF: Boolean;
begin
  Result := false;
  if assigned(FDataset) then
    Result := FDataset.Eof;
end;

function TOpDataSetModel.GetRowData: Variant;
var
  i: integer;
begin
  if assigned(FDataset) then
  begin
    if FInDetail then
      Result := FDetailModel.GetRowData
    else
    begin
      Result := VarArrayCreate([0,GetColCount],varVariant);
      for i := 0 to GetColCount - 1 do
      begin
        if (FDataset.Fields[i] is TMemoField) and (FWantFullMemos) then
          Result[i] := FDataset.Fields[i].AsString
        else
          Result[i] := FDataset.Fields[i].Text;
      end;
    end;
  end;
end;

function TOpDataSetModel.GetSupportedModes: TOpRetrievalModes;
begin
  Result := [rmCell, rmPacket];
end;

function TOpDataSetModel.GetText(Index: Integer): string;
begin
  if assigned(FDataset) then
  begin
    if FInDetail then
      Result := FDetailModel.GetText(index)
    else
      if (FDataset.Fields[index] is TMemoField) and (FWantFullMemos) then
        Result := FDataset.Fields[index].AsString
      else
        Result := FDataset.Fields[index].Text;
  end;
end;

function TOpDataSetModel.GetVariableLengthRows: Boolean;
begin
  if assigned(FDetailModel) then
    Result := true
  else
    Result := false;
end;

procedure TOpDataSetModel.Last;
begin
  if assigned(FDataset) then FDataset.Last;
end;

procedure TOpDataSetModel.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent,Operation);
  if (Operation = opRemove) then
  begin
    if (FDataset = AComponent) then FDataset := nil;
    if (FDetailModel = AComponent) then FDetailModel := nil;
  end;
end;

procedure TOpDataSetModel.Next;
begin
  if assigned(FDataset) then
  begin
    if assigned(FDetailModel) then
    begin
      if FInDetail then
      begin
        FDetailModel.Next;
        if FDetailModel.GetEof then
        begin
          FInDetail := false;
          FDataset.Next;
        end;
      end
      else
      begin
        FDetailModel.First;
        FInDetail := true;
      end;
    end
    else
    begin
      FDataset.Next;
    end;
  end;
end;

procedure TOpDataSetModel.Prior;
begin
  if assigned(FDataset) then
  begin
    if assigned(FDetailModel) then
    begin
      if FInDetail then
      begin
        FDetailModel.Prior;
        if FDetailModel.GetBof then
        begin
          FInDetail := false;
          FDataset.Prior;
        end;
      end
      else
      begin
        FDetailModel.Last;
        FInDetail := true;
      end;
    end
    else
    begin
      FDataset.Prior;
    end;
  end;
end;

function TOpDataSetModel.GetLevel: Integer;
begin
  if FInDetail then
    Result := FDetailModel.GetLevel + 1
  else
    Result := 1;
end;

function TOpDataSetModel.GetColHeaders: Variant;
var
  i: Integer;
begin
  Result := null;
  if assigned(FDataset) then
  begin
    Result := VarArrayCreate([0,FDataset.FieldCount-1],varOLEStr);
    for i := 0 to FDataset.FieldCount - 1 do
    begin
      Result[i] := FDataset.Fields[i].DisplayLabel;
    end;
  end;
end;

function TOpDataSetModel.GetData(Index: Integer; Mode: TOpRetrievalMode;
  var Size: Integer): Variant;
begin
  case Mode of
    rmPacket:  begin
                 Size := 1;
                 Result := GetRowData;
               end;
    rmCell:    begin
                 Size := 0;
                 Result := GetText(Index);
               end;
    else
      raise EUnsupportedMode.Create('Model does not support requested mode.');
  end;
end;

procedure TOpDataSetModel.BeginRead;
begin
  if not(assigned(FDataset)) then raise EModelException.Create(SModelDatasetMissing)
  else
    if not(FDataset.Active) then raise EModelException.Create(SModelDatasetInactive);
  FCurrentPos := FDataset.GetBookmark;
  if not assigned(FDetailModel) then
    FDataset.DisableControls;
end;

procedure TOpDataSetModel.EndRead;
begin
  if assigned(FCurrentPos) then
  begin
    FDataset.GotoBookmark(FCurrentPos);
    FDataset.FreeBookmark(FCurrentPos);
  end;
  if not assigned(FDetailModel) then
    FDataset.EnableControls;
end;

procedure TOpDataSetModel.SetDetailModel(const Value: TOpDataSetModel);
begin
  if Value <> FDetailModel then
  begin
    if FDetailModel = self then EModelException.Create(SCircularModelLink);
    if assigned(Value) then Value.FreeNotification(self);
    FDetailModel := Value;
  end;
end;

procedure TOpDataSetModel.SetDataset(const Value: TDataset);
begin
  FDataset := Value;
end;

end.
