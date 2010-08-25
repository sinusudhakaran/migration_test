{*********************************************************}
{*                   OVCHSCBX.PAS 4.05                  *}
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

unit ovchscbx;
  {-History combo box}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, OvcCmbx;

type
  TOvcHistoryComboBox = class(TOvcBaseComboBox)
  protected {private}
    FMaxHistory : Integer;

    {procedure UpdateHistory;} {moved to public}                       {!!.02}

  protected
    procedure DoExit;
      override;

  public
    constructor Create(AOwner : TComponent);
      override;
    procedure UpdateHistory; {moved from protected}                    {!!.02}
  published
    property MaxHistory : Integer
      read FMaxHistory
      write FMaxHistory
      default 5;                                                       {!!.05}

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
    property Items;
    property ItemHeight;
    property KeyDelay;
    property LabelInfo;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
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

{*** TOvcHistoryComboBox ***}

constructor TOvcHistoryComboBox.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);

  {defaults}
  FMaxHistory := 5;

  {disable MRU list}
  FMRUList.MaxItems := 0;
end;

procedure TOvcHistoryComboBox.DoExit;
begin
  UpdateHistory;

  inherited DoExit;
end;

procedure TOvcHistoryComboBox.UpdateHistory;
var
  I     : Integer;
  Found : Boolean;
begin
  if (Text > '') then begin
    Found := False;
    for I := 0 to Pred(Items.Count) do
      if CompareText(Text, Items[I]) = 0 then begin
        Found := True;
        Break;
      end;
    if not Found then begin
      {delete from bottom}
      while (Items.Count > 0) and (Items.Count >= FMaxHistory) do
        Items.Delete(Items.Count-1);
      {add to top}
      Items.Insert(0, Text);
      ItemIndex := Items.IndexOf(Text);
    end;
  end;
end;

end.
