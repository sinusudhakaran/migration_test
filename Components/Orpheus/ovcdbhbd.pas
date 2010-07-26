{*********************************************************}
{*                   OVCDBHBD.PAS 4.05                   *}
{*     COPYRIGHT (C) 1995-2002 TurboPower Software Co    *}
{*                 All rights reserved.                  *}
{*********************************************************}

{$I OVC.INC}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{.W-} {Windows Stack Frame}                                          {!!.02}
{$X+} {Extended Syntax}

unit ovcdbhbd;
  {Borland Database Engine helper class}

{$IFNDEF VERSION3}
!! Error - The Borland Database Engine helper class is for Delphi 3+ only
{$ENDIF}


interface

uses
  Windows, Messages, SysUtils, Classes, OvcBase, Db, DBTables, OvcDbHLL;

type
  TOvcDbBDEHelper = class(TOvcDbEngineHelperBase)
  {.Z+}
  protected {private}
  protected
  public
  {.Z-}
    {===GENERAL SESSION-BASED METHODS===}
    procedure GetAliasNames(aList : TStrings); override;
      {-fill list with available alias names; assumes default session}
    procedure GetAliasPath(const aAlias : string;
                             var aPath  : string); override;
      {-return the path for a given alias}
    procedure GetAliasDriverName(const aAlias  : string;
                                   var aDriver : string); override;
      {-return the driver name for a given alias}
    procedure GetTableNames(const aAlias : string;
                                  aList  : TStrings); override;
      {-fill list with available table names in the given alias.}


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

uses
  BDE;

{===TOvcDbBDEHelper==================================================}
procedure TOvcDbBDEHelper.FindNearestKey(aDataSet   : TDataSet;
                                   const aKeyValues : array of const);
begin
  (aDataSet as TTable).FindNearest(aKeyValues);
end;
{--------}
procedure TOvcDbBDEHelper.GetAliasDriverName(const aAlias  : string;
                                               var aDriver : string);
var
  AliasZ : array[0..31] of char;
  Desc   : DBDesc;
begin
  StrPLCopy(AliasZ, aAlias, pred(sizeOf(AliasZ)));
  AnsiToOem(AliasZ, AliasZ);
  Check(DbiGetDatabaseDesc(AliasZ, @Desc));
  OemToAnsi(Desc.szDbType, Desc.szDbType);
  aDriver := StrPas(Desc.szDbType);
end;
{--------}
procedure TOvcDbBDEHelper.GetAliasNames(aList : TStrings);
begin
  Session.GetAliasNames(aList);
end;
{--------}
procedure TOvcDbBDEHelper.GetAliasPath(const aAlias : string;
                                         var aPath  : string);
var
  List : TStringList;
begin
  List := TStringList.Create;
  try
    Session.GetAliasParams(aAlias, List);
    aPath := List.Values['PATH'];
  finally
    List.Free;
  end;
end;
{--------}
function TOvcDbBDEHelper.GetIndexDefs(aDataSet : TDataSet) : TIndexDefs;
begin
  Result := (aDataSet as TTable).IndexDefs;
end;
{--------}
function TOvcDbBDEHelper.GetIndexField(aDataSet    : TDataSet;
                                       aFieldIndex : integer) : TField;
begin
  Result := (aDataSet as TTable).IndexFields[aFieldIndex];
end;
{--------}
function TOvcDbBDEHelper.GetIndexFieldCount(aDataSet : TDataSet) : integer;
begin
  Result := (aDataSet as TTable).IndexFieldCount;
end;
{--------}
procedure TOvcDbBDEHelper.GetIndexFieldNames(aDataSet         : TDataSet;
                                         var aIndexFieldNames : string);
begin
  aIndexFieldNames := (aDataSet as TTable).IndexFieldNames;
end;
{--------}
procedure TOvcDbBDEHelper.GetIndexName(aDataSet   : TDataSet;
                                   var aIndexName : string);
begin
  aIndexName := (aDataSet as TTable).IndexName;
end;
{--------}
procedure TOvcDbBDEHelper.GetTableNames(const aAlias : string;
                                                   aList  : TStrings);
begin
  Session.GetTableNames(aAlias, '', true, false, aList);
end;
{--------}
function TOvcDbBDEHelper.IsChildDataSet(aDataSet : TDataSet) : boolean;
begin
  Result := (aDataSet as TTable).MasterSource <> nil;
end;
{--------}
procedure TOvcDbBDEHelper.SetIndexFieldNames(aDataSet         : TDataSet;
                                       const aIndexFieldNames : string);
begin
  (aDataSet as TTable).IndexFieldNames := aIndexFieldNames;
end;
{--------}
procedure TOvcDbBDEHelper.SetIndexName(aDataSet   : TDataSet;
                                 const aIndexName : string);
begin
  (aDataSet as TTable).IndexName := aIndexName;
end;
{====================================================================}


end.
