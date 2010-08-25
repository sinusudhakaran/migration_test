{*********************************************************}
{*                   OVCDBHAp.PAS 3.00                   *}
{*     Copyright 1995-2000 (c) TurboPower Software Co    *}
{*                 All rights reserved.                  *}
{*********************************************************}

{$I OVC.INC}

{$IFNDEF VERSION3}
!! Error - The Apollo engine helper class is for Delphi 3+ and BCB3+ only
{$ENDIF}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{.W-} {Windows Stack Frame}                                          {!!.02}
{$X+} {Extended Syntax}

unit OvcDbHAp;
  {Apollo database engine helper class}

{Notes: Apollo is a database engine by Vista Software.
          http://www.vistasoftware.com/
        Apollo does not support aliases (at least in the BDE form),
          hence all alias name support is defaulted to the ancestor.
        The ApolloDataSet does not support referring indexes by
          fields in the BDE/Paradox sense, hence only the first field
          is used, the one available through sx_IndexKeyField}

interface

uses
  Windows, Messages, SysUtils, Classes, OvcBase, Db, ApoDSet, OvcDbHLL;

type
  TOvcDbApolloEngineHelper = class(TOvcDbEngineHelperBase)
  {.Z+}
  protected {private}
  protected
  public
  {.Z-}
    {===GENERAL TABLE AND INDEX-BASED METHODS===}
    procedure FindNearestKey(aDataSet   : TDataSet;
                       const aKeyValues : array of const); override;
      {-position the dataset on the nearest record that matches the
        passed key}
    function GetIndexDefs(aDataSet : TDataSet) : TIndexDefs; override;
      {-return the index definitions for the given dataset}
    function GetIndexField(aDataSet    : TDataSet;
                           aFieldIndex : integer) : TField; override;
      {-return the TField object for the given field number in the
        current index.}
    function GetIndexFieldCount(aDataSet : TDataSet) : integer; override;
      {-return the number of fields in the key for the current index.}
    procedure GetIndexFieldNames(aDataSet         : TDataSet;
                             var aIndexFieldNames : string); override;
      {-return the field names for the current index for the given
        dataset}
    procedure GetIndexName(aDataSet   : TDataSet;
                       var aIndexName : string); override;
      {-return the name of the current index for the given dataset}
    function IsChildDataSet(aDataSet : TDataSet) : boolean; override;
      {-return whether the dataset is the detail part of a
        master/detail relationship (ie, the current index is 'locked'
        to the master dataset)}

    procedure SetIndexFieldNames(aDataSet         : TDataSet;
                           const aIndexFieldNames : string); override;
      {-set the current index to that containing the given fields for
        the given dataset}
    procedure SetIndexName(aDataSet   : TDataSet;
                     const aIndexName : string); override;
      {-set the current index to the given name for the given dataset}
  end;

implementation

{===TOvcDbApolloEngineHelper=========================================}
procedure TOvcDbApolloEngineHelper.FindNearestKey(aDataSet   : TDataSet;
                                            const aKeyValues : array of const);
begin
  (aDataSet as TApolloTable).FindNearest(aKeyValues);
end;
{--------}
function TOvcDbApolloEngineHelper.GetIndexDefs(aDataSet : TDataSet) : TIndexDefs;
begin
  Result := (aDataSet as TApolloTable).IndexDefs;
end;
{--------}
function TOvcDbApolloEngineHelper.GetIndexField(aDataSet    : TDataSet;
                                                aFieldIndex : integer) : TField;
var
  i       : integer;
  FoundIt : boolean;
  ApTable : TApolloTable;
begin
  {assume we can't find the field}
  Result := nil;
  {Apollo only exposes the first index field so if aFieldIndex is two
   or more we return nil}
  if (aFieldIndex > 0) then
    Exit;
  {now we need to find the current index and hence the name of the
   field}
  ApTable := (aDataSet as TApolloTable);
  ApTable.IndexDefs.Update;
  FoundIt := false;
  for i := 0 to pred(ApTable.IndexDefs.Count) do begin
    if (CompareText(ApTable.IndexName, ApTable.IndexDefs[i].Name) = 0) then begin
      FoundIt := true;
      Break;
    end;
  end;
  {if we didn't find the indexname return nil}
  if not FoundIt then
    Exit;
  {now return the proper field}
  Result := ApTable.FieldByName(ApTable.IndexDefs[i].Fields);
end;
{--------}
function TOvcDbApolloEngineHelper.GetIndexFieldCount(aDataSet : TDataSet) : integer;
begin
  Result := 1; 
end;
{--------}
procedure TOvcDbApolloEngineHelper.GetIndexFieldNames(aDataSet         : TDataSet;
                                                  var aIndexFieldNames : string);
var
  i       : integer;
  FoundIt : boolean;
  ApTable : TApolloTable;
begin
  {the current index is given by the property IndexName. We need to
   find this name in the IndexDefs array, and from that we'll know
   which is the major field in the key}
  ApTable := (aDataSet as TApolloTable);
  ApTable.IndexDefs.Update;
  FoundIt := false;
  for i := 0 to pred(ApTable.IndexDefs.Count) do begin
    if (CompareText(ApTable.IndexName, ApTable.IndexDefs[i].Name) = 0) then begin
      FoundIt := true;
      Break;
    end;
  end;
  if FoundIt then
    aIndexFieldNames := ApTable.IndexDefs[i].Fields
  else
    aIndexFieldNames := '';
end;
{--------}
procedure TOvcDbApolloEngineHelper.GetIndexName(aDataSet   : TDataSet;
                                            var aIndexName : string);
begin
  aIndexName := (aDataSet as TApolloTable).IndexName;
end;
{--------}
function TOvcDbApolloEngineHelper.IsChildDataSet(aDataSet : TDataSet) : boolean;
begin
  Result := (aDataSet as TApolloTable).MasterSource <> nil;
end;
{--------}
procedure TOvcDbApolloEngineHelper.SetIndexFieldNames(aDataSet         : TDataSet;
                                                const aIndexFieldNames : string);
var
  i       : integer;
  FoundIt : boolean;
  ApTable : TApolloTable;
  FldName : string;
begin
  {strip off all but the first field name}
  i := Pos(';', aIndexFieldNames);
  if (i = 0) then
    FldName := aIndexFieldNames
  else
    FldName := Copy(aIndexFieldNames, 1, pred(i));
  {now search through all of the index definitions for one that uses
   this particular field}
  ApTable := (aDataSet as TApolloTable);
  ApTable.IndexDefs.Update;
  FoundIt := false;
  for i := 0 to pred(ApTable.IndexDefs.Count) do begin
    if (CompareText(FldName, ApTable.IndexDefs[i].Fields) = 0) then begin
      FoundIt := true;
      Break;
    end;
  end;
  {if we didn't find the field, do nothing}
  if not FoundIt then
    Exit;
  {if we did, make that index the current one}
  ApTable.IndexName := ApTable.IndexDefs[i].Name;
end;
{--------}
procedure TOvcDbApolloEngineHelper.SetIndexName(aDataSet   : TDataSet;
                                          const aIndexName : string);
begin
  (aDataSet as TApolloTable).IndexName := aIndexName;
end;
{====================================================================}


end.
