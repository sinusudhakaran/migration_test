{*********************************************************}
{*                   OVCDBTCB.PAS 4.05                  *}
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

unit ovcdbtcb;
  {table combobox}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, StdCtrls, OvcCmbx,
  OvcBase, Menus, Db, OvcDbHLL;

type
  TOvcDbTableNameComboBox = class(TOvcBaseComboBox)
  {.Z+}
  protected {private}
    FDbEngineHelper : TOvcDbEngineHelperBase;
    FAliasName      : string;
    function GetTableName : string;
    procedure SetAliasName(const Value : string);
  protected
    procedure Loaded; override;
    procedure Notification(AComponent : TComponent;
                           Operation : TOperation); override;
  public
    procedure Populate;
  {.Z-}
    property TableName : string
      read GetTableName;
  published
    property AliasName : string
      read FAliasName
      write SetAliasName;
    property DbEngineHelper : TOvcDbEngineHelperBase
      read FDbEngineHelper
      write FDbEngineHelper;

    {$IFDEF VERSION4}
    property Anchors;
    property Constraints;
    property DragKind;
    {$ENDIF}
    property About;
    property AutoSearch;
    property Color;
    property Ctl3D;
    property Cursor;
    property DragCursor;
    property DragMode;
    property DropDownCount;
    property Enabled;
    property Font;
    property HotTrack;
    property ImeMode;
    property ImeName;
    property ItemHeight;
    property KeyDelay;
    property LabelInfo;
    property MRUListColor;
    property MRUListCount;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Style default ocsDropDown;                               {!!.05}
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    {events}
    property AfterEnter;
    property AfterExit;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnSelectionChange;
    property OnStartDrag;
    property OnMouseWheel;
  end;

implementation

{*** TOvcAliasComboBox ***}

procedure TOvcDbTableNameComboBox.Loaded;
begin
  inherited Loaded;
  if not (csDesigning in ComponentState) then
    Populate;
end;

procedure TOvcDbTableNameComboBox.Populate;
begin
  ClearItems;                                                               
  OvcGetTableNames(DbEngineHelper, FAliasName, Items);
end;

function TOvcDbTableNameComboBox.GetTableName : string;
begin
  if (ItemIndex > -1) then
    Result := Items[ItemIndex]
  else
    Result := '';
end;

procedure TOvcDbTableNameComboBox.Notification(AComponent : TComponent;
                                               Operation : TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) then begin
    if (Assigned(DBEngineHelper)) and (AComponent = FDbEngineHelper) then
      DBEngineHelper := nil;
  end;
end;

procedure TOvcDbTableNameComboBox.SetAliasName(const Value : string);
begin
  if Value <> FAliasName then begin
    FAliasName := Value;
    Populate;
  end;
end;

end.
