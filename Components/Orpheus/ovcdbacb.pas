{*********************************************************}
{*                   OVCDBACB.PAS 4.05                   *}
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

unit ovcdbacb;

interface

uses
  Windows, Classes, OvcCmbx, OvcDbTCb, OvcDbHLL;

type
  TOvcDbAliasComboBox = class(TOvcBaseComboBox)
  {.Z+}
  protected {private}
    FDbEngineHelper    : TOvcDbEngineHelperBase;
    FTableNameComboBox : TOvcDbTableNameComboBox;
    function GetAliasName : string;
    function GetPath : string;
    function GetDriverName : string;
  protected
    procedure Loaded; override;

    procedure Notification(AComponent : TComponent;
                           Operation : TOperation);
      override;

    procedure SelectionChanged; override;
  public
    procedure Populate;
  {.Z-}
    property AliasName : string
      read GetAliasName;
    property Path : string
      read GetPath;
    property DriverName : string
      read GetDriverName;

  published
    property TableNameComboBox : TOvcDbTableNameComboBox
      read FTableNameComboBox
      write FTableNameComboBox;

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

procedure TOvcDbAliasComboBox.Loaded;
begin
  inherited Loaded;
  if not (csDesigning in ComponentState) then
    Populate;
end;

procedure TOvcDbAliasComboBox.Populate;
begin
  ClearItems;
  OvcGetAliasNames(DbEngineHelper, Items);
end;

procedure TOvcDbAliasComboBox.SelectionChanged;
begin
  if (FTableNameComboBox <> nil) then
    FTableNameComboBox.AliasName := GetAliasName;
  inherited SelectionChanged;
end;

function TOvcDbAliasComboBox.GetAliasName : string;
begin
  if (ItemIndex > -1) then
    Result := Items[ItemIndex]
  else
    Result := '';
end;

function TOvcDbAliasComboBox.GetPath : string;
begin
  Result := '';
  if (ItemIndex > -1) then
    OvcGetAliasPath(DbEngineHelper, Items[ItemIndex], Result);
end;

function TOvcDbAliasComboBox.GetDriverName : string;
begin
  Result := '';
  if (ItemIndex > -1) then
    OvcGetAliasDriverName(DbEngineHelper, Items[ItemIndex], Result);
end;

procedure TOvcDbAliasComboBox.Notification(AComponent : TComponent;
                                           Operation : TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) then begin
    if (Assigned(DBEngineHelper)) and (AComponent = FDbEngineHelper) then
      DBEngineHelper := nil;
  end;
end;

end.
