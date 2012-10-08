unit BKNumericEdit;

interface

uses
  Windows, Messages, Controls, Classes, StdCtrls, Clipbrd, SysUtils, StrUtils;

type
  TBKNumericEdit = class(TCustomEdit)
  private
    function IsNumeric(Value: String): Boolean;
  protected
    procedure KeyPress(var Key: Char); override;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
  published
    property Align;
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BevelEdges;
    property BevelInner;
    property BevelKind default bkNone;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;
  
procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('BankLink', [TBKNumericEdit]);
end;

{ TBKNumericEdit }

function TBKNumericEdit.IsNumeric(Value: String): Boolean;
var
  CharValue: Char;
begin
  Result := True;

  for CharValue in Value do
  begin
    if not (CharValue in['0'..'9']) then
    begin
      Result := False;

      Exit;
    end;
  end;
end;

procedure TBKNumericEdit.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  
  if not (Key in['0'..'9', #1, #3, #8, #22, #24, #26]) then
  begin
    Key := #0;
  end;
end;

procedure TBKNumericEdit.WMPaste(var Message: TMessage);
begin
  Clipboard.Open;

  try
    if IsNumeric(Clipboard.AsText) then
    begin
      if MaxLength > 0 then
      begin
        Text := LeftStr(Clipboard.AsText, MaxLength);
      end
      else
      begin
        Text := Clipboard.AsText;
      end;
    end
    else
    begin
      Text := '';
    end;
  finally
    Clipboard.Close;
  end;

  SetSelStart(Length(Text));
end;

end.
