{*********************************************************}
{*                  OVCDBDLB.PAS 4.05                    *}
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

unit ovcdbdLb;
  {-Data-aware display label component}

interface

uses
  Windows, Classes, Controls, Db, DbCtrls, Graphics, Menus, Messages, StdCtrls,
  OvcRLbl;

type
  TOvcDbDisplayLabel = class(TOvcCustomRotatedLabel)
  {.Z+}
  protected {private}
    {property variables}
    FDataLink : TFieldDataLink;

    {property methods}
    function GetDataField : string;
    function GetDataSource : TDataSource;
    function GetField : TField;
    procedure SetDataField(const Value : string);
    procedure SetDataSource(Value : TDataSource);

    {internal methods}
    procedure dlDataChange(Sender : TObject);
      {-data change notification}
    function dlGetDisplayLabel : string;
      {-return the display label}


    {vcl message methods}
    procedure CMGetDataLink(var Msg : TMessage);
      message CM_GETDATALINK;

  protected
    procedure Notification(AComponent : TComponent; Operation : TOperation);
      override;

  public
    constructor Create(AOwner : TComponent);
      override;
    destructor Destroy;
      override;
    {$IFDEF VERSION4}
    function ExecuteAction(Action: TBasicAction): Boolean;
      override;
    function UpdateAction(Action: TBasicAction): Boolean;
      override;
    {$ENDIF}
  {.Z-}

    property Field : TField
      read GetField;

  published
    {properties}
    property DataField : string
      read GetDataField
      write SetDataField;

    property DataSource : TDataSource
      read GetDataSource
      write SetDataSource;

    {inherited properties}
    {$IFDEF VERSION4}
    property Anchors;
    property Constraints;
    property DragKind;
    {$ENDIF}
    property Align;
    property Alignment;
    property AutoSize;
    property Color;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property FontAngle;
    property OriginX;
    property OriginY;
    property ParentColor;
    {property ParentFont;}
    property ParentShowHint;
    property PopupMenu;
    property ShadowColor;
    property ShadowedText;
    property ShowHint;
    property Transparent;
    property Visible;

    {events}
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
  end;


implementation


{*** TOvcDbDisplayLabel ***}

procedure TOvcDbDisplayLabel.CMGetDataLink(var Msg : TMessage);
begin
  Msg.Result := Integer(FDataLink);
end;

constructor TOvcDbDisplayLabel.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);

  {create data link}
  FDataLink := TFieldDataLink.Create;
  FDataLink.OnDataChange := dlDataChange;
end;

destructor TOvcDbDisplayLabel.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;

  inherited Destroy;
end;

procedure TOvcDbDisplayLabel.dlDataChange(Sender : TObject);
begin
  Caption := dlGetDisplayLabel;
end;

function TOvcDbDisplayLabel.dlGetDisplayLabel : string;
begin
  if FDataLink.Field <> nil then
    Result := FDataLink.Field.DisplayLabel
  else
    if csDesigning in ComponentState then
      Result := Name
    else
      Result := '';
end;

function TOvcDbDisplayLabel.GetDataField : string;
begin
  Result := FDataLink.FieldName;
end;

function TOvcDbDisplayLabel.GetDataSource : TDataSource;
begin
  Result := FDataLink.DataSource;
end;

function TOvcDbDisplayLabel.GetField : TField;
begin
  Result := FDataLink.Field;
end;

procedure TOvcDbDisplayLabel.Notification(AComponent : TComponent; Operation : TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and (AComponent = DataSource) then
    DataSource := nil;
end;

procedure TOvcDbDisplayLabel.SetDataField(const Value : string);
begin
  FDataLink.FieldName := Value;
end;

procedure TOvcDbDisplayLabel.SetDataSource(Value : TDataSource);
begin
  FDataLink.DataSource := Value;
  if Value <> nil then
    Value.FreeNotification(Self);
end;

{$IFDEF VERSION4}
function TOvcDbDisplayLabel.ExecuteAction(Action : TBasicAction) : Boolean;
begin
  Result := inherited ExecuteAction(Action) or (FDataLink <> nil) and
    FDataLink.ExecuteAction(Action);
end;

function TOvcDbDisplayLabel.UpdateAction(Action : TBasicAction) : Boolean;
begin
  Result := inherited UpdateAction(Action) or (FDataLink <> nil) and
    FDataLink.UpdateAction(Action);
end;
{$ENDIF}

end.
