{*********************************************************}
{*                  OVCTCSIM.PAS 4.05                    *}
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

unit ovctcsim;
  {-Orpheus Table Cell - Simple field type}

interface

uses
  Windows, SysUtils, Messages, Classes, Controls,
  OvcData, OvcEF, OvcSF, OvcTCmmn, OvcTCell, OvcTCBEF,
  Graphics; {!!.05 - for default color definition}

type
  {The editor class for TOvcTCSimpleField cell components}
  TOvcTCSimpleFieldEdit = class(TOvcSimpleField)
    protected {private}
      {.Z+}
      FCell : TOvcBaseTableCell;
      {.Z-}

    protected
      {.Z+}
      procedure efMoveFocusToNextField; override;
      procedure efMoveFocusToPrevField; override;

      procedure WMChar(var Msg : TWMKey); message WM_CHAR;
      procedure WMGetDlgCode(var Msg : TMessage); message WM_GETDLGCODE;
      procedure WMKeyDown(var Msg : TWMKey); message WM_KEYDOWN;
      procedure WMKillFocus(var Msg : TWMKillFocus); message WM_KILLFOCUS;
      procedure WMSetFocus(var Msg : TWMSetFocus); message WM_SETFOCUS;
      {.Z-}

    published
      property CellOwner : TOvcBaseTableCell
         read FCell write FCell;
  end;

  {The simple field cell component class}
  TOvcTCCustomSimpleField = class(TOvcTCBaseEntryField)
    protected
      {.Z+}
      function GetCellEditor : TControl; override;
      function GetDataType : TSimpleDataType;
      function GetPictureMask : AnsiChar;

      procedure SetDataType(DT : TSimpleDataType);
      procedure SetPictureMask(PM : AnsiChar);
      {.Z-}

      property DataType : TSimpleDataType
         read GetDataType write SetDataType;

      property PictureMask : AnsiChar
         read GetPictureMask write SetPictureMask;

    public
      function CreateEntryField(AOwner : TComponent) : TOvcBaseEntryField; override;
  end;

  TOvcTCSimpleField = class(TOvcTCCustomSimpleField)
    published
      {properties inherited from custom ancestor}
      property Access default otxDefault;                             {!!.05}
      property Adjust default otaDefault;                             {!!.05}
      property CaretIns;
      property CaretOvr;
      property Color;
      property ControlCharColor default clRed;                        {!!.05}
      property DataType default sftString;                            {!!.05}
      property DecimalPlaces default 0;                               {!!.05}
      property EFColors;
      property Font;
      property Hint;
      property Margin default 4;                                      {!!.05}
      property MaxLength default 15;                                  {!!.05}
      property Options default [efoCaretToEnd, efoTrimBlanks];        {!!.05}
      property PadChar default ' ';                                   {!!.05}
      property PasswordChar default '*';                              {!!.05}
      property PictureMask default 'X';                               {!!.05}
      property RangeHi stored False;
      property RangeLo stored False;
      property ShowHint default False;                                {!!.05}
      property Table;
      property TableColor default True;                               {!!.05}
      property TableFont default True;                                {!!.05}
      property TextHiColor default clBtnHighlight;                    {!!.05}
      property TextMargin default 2;                                  {!!.05}
      property TextStyle default tsFlat;                              {!!.05}

      {events inherited from custom ancestor}
      property OnChange;
      property OnClick;
      property OnDblClick;
      property OnDragDrop;
      property OnDragOver;
      property OnEndDrag;
      property OnEnter;
      property OnError;
      property OnExit;
      property OnKeyDown;
      property OnKeyPress;
      property OnKeyUp;
      property OnMouseDown;
      property OnMouseMove;
      property OnMouseUp;
      property OnOwnerDraw;
      property OnUserCommand;
      property OnUserValidation;
  end;


implementation


{===TOvcTCCustomSimpleField=========================================}
function TOvcTCCustomSimpleField.CreateEntryField(AOwner : TComponent) : TOvcBaseEntryField;
  begin
    Result := TOvcTCSimpleFieldEdit.Create(AOwner);
    TOvcTCSimpleFieldEdit(Result).CellOwner := Self;
  end;
{--------}
function TOvcTCCustomSimpleField.GetCellEditor : TControl;
  begin
    Result := FEdit;
  end;
{--------}
function TOvcTCCustomSimpleField.GetDataType : TSimpleDataType;
  begin
    if Assigned(FEdit) then Result := TOvcTCSimpleFieldEdit(FEdit).DataType
      else Result := sftString;
  end;
{--------}
function TOvcTCCustomSimpleField.GetPictureMask : AnsiChar;
  begin
    if Assigned(FEdit) then Result := TOvcTCSimpleFieldEdit(FEdit).PictureMask
      else Result := pmAnyChar;
  end;
{--------}
procedure TOvcTCCustomSimpleField.SetDataType(DT : TSimpleDataType);
  begin
    if Assigned(FEdit) then
      begin
        TOvcTCSimpleFieldEdit(FEdit).DataType := DT;
        TOvcTCSimpleFieldEdit(FEditDisplay).DataType := DT;
      end;
  end;
{--------}
procedure TOvcTCCustomSimpleField.SetPictureMask(PM : AnsiChar);
  begin
    if Assigned(FEdit) then
      begin
        TOvcTCSimpleFieldEdit(FEdit).PictureMask := PM;
        TOvcTCSimpleFieldEdit(FEditDisplay).PictureMask := PM;
      end;
  end;
{====================================================================}


{===TOvcTCSimpleFieldEdit==============================================}
procedure TOvcTCSimpleFieldEdit.efMoveFocusToNextField;
  var
    Msg : TWMKey;
  begin
    FillChar(Msg, sizeof(Msg), 0);
    with Msg do
      begin
        Msg := WM_KEYDOWN;
        CharCode := VK_RIGHT;
      end;
    CellOwner.SendKeyToTable(Msg);
  end;
{--------}
procedure TOvcTCSimpleFieldEdit.efMoveFocusToPrevField;
  var
    Msg : TWMKey;
  begin
    FillChar(Msg, sizeof(Msg), 0);
    with Msg do
      begin
        Msg := WM_KEYDOWN;
        CharCode := VK_LEFT;
      end;
    CellOwner.SendKeyToTable(Msg);
  end;
{--------}
procedure TOvcTCSimpleFieldEdit.WMChar(var Msg : TWMKey);
  begin
    if (Msg.CharCode <> 9) then {filter tab characters}
      inherited;
  end;
{--------}
procedure TOvcTCSimpleFieldEdit.WMGetDlgCode(var Msg : TMessage);
  begin
    inherited;
    if CellOwner.TableWantsTab then
      Msg.Result := Msg.Result or DLGC_WANTTAB;
    if CellOwner.TableWantsEnter then
      Msg.Result := Msg.Result or DLGC_WANTALLKEYS;
  end;
{--------}
procedure TOvcTCSimpleFieldEdit.WMKeyDown(var Msg : TWMKey);
  var
    GridReply : TOvcTblKeyNeeds;
    GridUsedIt : boolean;
  begin
    GridUsedIt := false;
    GridReply := otkDontCare;
    if (CellOwner <> nil) then
      GridReply := CellOwner.FilterTableKey(Msg);
    case GridReply of
      otkMustHave :
        begin
          {the entry field must also process this key - to restore its contents}
          if (Msg.CharCode = VK_ESCAPE) then
            Restore;

          CellOwner.SendKeyToTable(Msg);
          GridUsedIt := true;
        end;
      otkWouldLike :
        case Msg.CharCode of
          VK_PRIOR, VK_NEXT, VK_UP, VK_DOWN :
            begin
              if ValidateSelf then
                begin
                  CellOwner.SendKeyToTable(Msg);
                  GridUsedIt := true;
                end;
            end;
          {Note: VK_LEFT, VK_RIGHT are processed by efMoveFocusToNext(Next)Field}
        end;
    end;{case}

    if not GridUsedIt then
      inherited;
  end;
{--------}
procedure TOvcTCSimpleFieldEdit.WMKillFocus(var Msg : TWMKillFocus);
  begin
    inherited;
    CellOwner.PostMessageToTable(ctim_KillFocus, Msg.FocusedWnd, LastError);
  end;
{--------}
procedure TOvcTCSimpleFieldEdit.WMSetFocus(var Msg : TWMSetFocus);
  begin
    inherited;
    CellOwner.PostMessageToTable(ctim_SetFocus, Msg.FocusedWnd, 0);
  end;
{====================================================================}

end.
