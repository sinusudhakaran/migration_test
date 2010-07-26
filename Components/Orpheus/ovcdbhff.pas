{*********************************************************}
{*                   OVCDBHFF.PAS 4.05                   *}
{*     COPYRIGHT (C) 1995-2002 TurboPower Software Co    *}
{*                 All rights reserved.                  *}
{*********************************************************}

{$I OVC.INC}

{$IFNDEF VERSION3}
!! Error - The FlashFiler engine helper class is for Delphi 3+ only
{$ENDIF}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{.W-} {Windows Stack Frame}                                          {!!.02}
{$X+} {Extended Syntax}

unit OvcDbHFF;
  {FlashFiler database engine helper class}

interface

uses
  Windows, Messages, SysUtils, Classes, OvcBase, Db, FFDb, OvcDbHLL;

type
  TOvcDbFFEngineHelper = class(TOvcDbEngineHelperBase)
  {.Z+}
  protected {private}
    FSession : TffSession;
  protected
  public
  {.Z-}
    {===GENERAL SESSION-BASED METHODS===}
    procedure GetAliasNames(aList : TStrings); override;
      {-fill list with available alias names; assumes for default session}
    procedure GetAliasPath(const aAlias : string;
                             var aPath  : string); override;
      {-return the path for a given alias}
    procedure GetAliasDriverName(const aAlias  : string;
                                   var aDriver : string); override;
      {-return the driver name for a given alias - always returns
        'FlashFiler'}
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

  published
    property Session : TffSession read FSession write FSession;
      {-overridden session object for session-based methods}
  end;


implementation


{===TOvcDbFFEngineHelper=============================================}
procedure TOvcDbFFEngineHelper.FindNearestKey(aDataSet   : TDataSet;
                                        const aKeyValues : array of const);
begin
  (aDataSet as TffTable).FindNearest(aKeyValues);
end;
{--------}
procedure TOvcDbFFEngineHelper.GetAliasNames(aList : TStrings);
begin
  if Assigned(Session) then
    Session.GetAliasNames(aList)
  else
    GetDefaultFFSession.GetAliasNames(aList);
end;
{--------}
procedure TOvcDbFFEngineHelper.GetAliasPath(const aAlias : string;
                                              var aPath  : string);
begin
  if Assigned(Session) then
    Session.GetAliasPath(aAlias, aPath)
  else
    GetDefaultFFSession.GetAliasPath(aAlias, aPath);
end;
{--------}
procedure TOvcDbFFEngineHelper.GetAliasDriverName(const aAlias  : string;
                                                    var aDriver : string);
begin
  aDriver := 'FlashFiler';
end;
{--------}
procedure TOvcDbFFEngineHelper.GetTableNames(const aAlias : string;
                                                   aList  : TStrings);
begin
  if Assigned(Session) then
    Session.GetTableNames(aAlias, '*.FFD', true, false, aList)
  else
    GetDefaultFFSession.GetTableNames(aAlias, '*.FFD', true, false, aList);
end;
{--------}
function TOvcDbFFEngineHelper.GetIndexDefs(aDataSet : TDataSet) : TIndexDefs;
begin
  Result := (aDataSet as TffTable).IndexDefs;
end;
{--------}
function TOvcDbFFEngineHelper.GetIndexField(aDataSet    : TDataSet;
                                            aFieldIndex : integer) : TField;
begin
  Result := (aDataSet as TffTable).IndexFields[aFieldIndex];
end;
{--------}
function TOvcDbFFEngineHelper.GetIndexFieldCount(aDataSet : TDataSet) : integer;
begin
  Result := (aDataSet as TffTable).IndexFieldCount;
end;
{--------}
procedure TOvcDbFFEngineHelper.GetIndexFieldNames(aDataSet         : TDataSet;
                                              var aIndexFieldNames : string);
begin
  aIndexFieldNames := (aDataSet as TffTable).IndexFieldNames;
end;
{--------}
procedure TOvcDbFFEngineHelper.GetIndexName(aDataSet   : TDataSet;
                                        var aIndexName : string);
begin
  aIndexName := (aDataSet as TffTable).IndexName;
  if (aIndexName = '') then
    aIndexName := 'Seq. Access Index';
end;
{--------}
function TOvcDbFFEngineHelper.IsChildDataSet(aDataSet : TDataSet) : boolean;
begin
  Result := (aDataSet as TffTable).MasterSource <> nil;
end;
{--------}
procedure TOvcDbFFEngineHelper.SetIndexFieldNames(aDataSet         : TDataSet;
                                            const aIndexFieldNames : string);
begin
  (aDataSet as TffTable).IndexFieldNames := aIndexFieldNames;
end;
{--------}
procedure TOvcDbFFEngineHelper.SetIndexName(aDataSet   : TDataSet;
                                      const aIndexName : string);
begin
  (aDataSet as TffTable).IndexName := aIndexName;
end;
{====================================================================}


end.
