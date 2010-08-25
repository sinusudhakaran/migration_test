{*********************************************************}
{*                   OVCDLG.PAS 4.05                    *}
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

unit ovcdlg;
  {non-visual dialog base classes}

interface

uses
  Classes, Forms, Graphics,
  OvcBase;

type
  TOvcDialogPosition = (mpCenter, mpCenterTop, mpCustom);
  TOvcDialogOption = (doShowHelp, doSizeable);
  TOvcDialogOptions = set of TOvcDialogOption;

  TOvcDialogPlacement = class(TPersistent)
  {.Z+}
  protected {private}
    {property variables}
    FPosition : TOvcDialogPosition;
    FHeight   : Integer;
    FLeft     : Integer;
    FTop      : Integer;
    FWidth    : Integer;
    function LeftTopUsed: Boolean;                                    {!!.05}
  {.Z-}
  published
    {properties}
    property Position : TOvcDialogPosition
      read FPosition write FPosition
      default mpCenter;
    property Top : Integer
      read FTop write FTop
      stored LeftTopUsed                                              {!!.05}
      default 10;                                                     {!!.05}
    property Left : Integer
      read FLeft write FLeft
      stored LeftTopUsed                                              {!!.05}
      default 10;                                                     {!!.05}
    property Height : Integer
      read FHeight write FHeight;
    property Width : Integer
      read FWidth write FWidth;
  end;

  TOvcBaseDialog = class(TOvcComponent)
  {.Z+}
  protected {private}
    {property variables}
    FCaption   : string;
    FFont      : TFont;
    FIcon      : TIcon;
    FOptions   : TOvcDialogOptions;
    FPlacement : TOvcDialogPlacement;

    {event variables}
    FOnHelpClick : TNotifyEvent;

    {property methods}
    procedure SetFont(Value : TFont);
    procedure SetIcon(Value : TIcon);

    {internal methods}
    procedure DoFormPlacement(Form : TForm);
  {.Z-}

    {protected properties}
    property Caption : string
      read FCaption write FCaption;
    property Font : TFont
      read FFont write SetFont;
    property Icon : TIcon
      read FIcon write SetIcon;
    property Options : TOvcDialogOptions
      read FOptions write FOptions;
    property Placement : TOvcDialogPlacement
      read FPlacement write FPlacement;

    {protected events}
    property OnHelpClick : TNotifyEvent
      read FOnHelpClick write FOnHelpClick;

  public
  {.Z+}
    constructor Create(AOwner : TComponent);
      override;
    destructor Destroy;
      override;
  {.Z-}

    function Execute : Boolean;
      virtual; abstract;
  end;


implementation


{!!.05 new}
function TOvcDialogPlacement.LeftTopUsed: Boolean;
begin
  Result := Position = mpCustom;
end;

constructor TOvcBaseDialog.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);

  FFont := TFont.Create;
  FIcon := TIcon.Create;
  FOptions := [doSizeable];
  FPlacement := TOvcDialogPlacement.Create;
  FPlacement.Left := 10;
  FPlacement.Height := 250;
  FPlacement.Top := 10;
  FPlacement.Width := 400;
end;

destructor TOvcBaseDialog.Destroy;
begin
  FFont.Free;
  FFont := nil;

  FIcon.Free;
  FIcon := nil;

  FPlacement.Free;
  FPlacement := nil;

  inherited Destroy;
end;

procedure TOvcBaseDialog.DoFormPlacement(Form : TForm);
begin
  Form.Caption := FCaption;
  Form.Font := FFont;
  Form.Icon := FIcon;

  {set proper style for displayed form}
  if doSizeable in FOptions then
    Form.BorderStyle := bsSizeable
  else
    Form.BorderStyle:= bsDialog;
  if (Screen.ActiveForm <> nil) and
     (Screen.ActiveForm.FormStyle = fsStayOnTop) then
    Form.FormStyle := fsStayOnTop;

  Form.Height := FPlacement.Height;                                           
  Form.Width  := FPlacement.Width;                                            

  {set position}
  case FPlacement.Position of
    mpCenter :
      begin
        Form.Top := (Screen.Height - Form.Height) div 2;
        Form.Left := (Screen.Width - Form.Width) div 2;
      end;
    mpCenterTop :
      begin
        Form.Top := (Screen.Height - Form.Height) div 3;
        Form.Left := (Screen.Width - Form.Width) div 2;
      end;
    mpCustom :
      begin
        Form.Top    := FPlacement.Top;
        Form.Left   := FPlacement.Left;
      end;
  end;
end;

procedure TOvcBaseDialog.SetFont(Value : TFont);
begin
  FFont.Assign(Value);
end;

procedure TOvcBaseDialog.SetIcon(Value : TIcon);
begin
  FICon.Assign(Value);
end;


end.
