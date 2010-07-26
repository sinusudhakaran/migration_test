{*********************************************************}
{*                  OVCMODG.PAS 4.05                    *}
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

unit ovcmodg;

interface

uses
  Windows, Classes, Controls, Dialogs, ExtCtrls, Forms, Graphics, Messages,
  StdCtrls, SysUtils, OvcConst, OvcData, OvcDlg;

type
  {.Z+}
  TOvcfrmMemoDlg = class(TForm)
    btnHelp: TButton;
    Panel1: TPanel;
    Memo: TMemo;
    btnOK: TButton;
    btnCancel: TButton;
    lblReadOnly: TLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
  public
  end;
  {.Z-}

type
  TOvcMemoDialog = class(TOvcBaseDialog)
  {.Z+}
  protected {private}
    {property variables}
    FLines         : TStrings;
    FMemoFont      : TFont;
    FReadOnly      : Boolean;
    FWordWrap      : Boolean;

    {property methods}
    procedure SetLines(Value : TStrings);
    procedure SetMemoFont(Value : TFont);

  public
    constructor Create(AOwner : TComponent);
      override;
    destructor Destroy;
      override;
  {.Z-}

    function Execute : Boolean;
      override;

  published
    {properties}
    property Caption;
    property Font;
    property Icon;
    property Options;
    property Placement;

    property Lines : TStrings
      read FLines write SetLines;
    property MemoFont : TFont
      read FMemoFont write SetMemoFont;
    property ReadOnly : Boolean
      read FReadOnly write FReadOnly
      default False;                                                  {!!.05}
    property WordWrap : Boolean
      read FWordWrap write FWordWrap
      default True;                                                   {!!.05}

    {events}
    property OnHelpClick;
  end;


implementation

{$R *.DFM}


constructor TOvcMemoDialog.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);

  FLines    := TStringList.Create;
  FMemoFont := TFont.Create;
  FReadOnly := False;
  FWordWrap := True;
end;

destructor TOvcMemoDialog.Destroy;
begin
  FLines.Free;
  FLines := nil;

  FMemoFont.Free;
  FMemoFont := nil;

  inherited Destroy;
end;

function TOvcMemoDialog.Execute : Boolean;
var
  F : TOvcfrmMemoDlg;
begin
  F := TOvcfrmMemoDlg.Create(Application);
  try
    DoFormPlacement(F);

    {set memo properties}
    F.Memo.Lines.Assign(FLines);
    F.Memo.Modified := False;
    F.Memo.Font := FMemoFont;
    F.Memo.WordWrap := FWordWrap;
    F.Memo.ReadOnly := FReadOnly;
    if F.Memo.ReadOnly then begin
      F.btnOK.Visible := False;
      F.btnCancel.Caption := GetOrphStr(SCCloseCaption);
    end;
    F.lblReadOnly.Visible := F.Memo.ReadOnly;

    F.btnHelp.Visible := doShowHelp in Options;
    F.btnHelp.OnClick := FOnHelpClick;

    {show the memo form}
    Result := F.ShowModal = mrOK;

    if Result and F.Memo.Modified then
      FLines.Assign(F.Memo.Lines);
  finally
    F.Free;
  end;
end;

procedure TOvcMemoDialog.SetLines(Value : TStrings);
begin
  FLines.Assign(Lines);
end;

procedure TOvcMemoDialog.SetMemoFont(Value : TFont);
begin
  FMemoFont.Assign(Value);
end;


{*** TOvcMemoDlg ***}

procedure TOvcfrmMemoDlg.FormCloseQuery(Sender : TObject; var CanClose : Boolean);
begin
  CanClose := True;
  if Memo.Modified and (ModalResult = mrCancel) then
    if MessageDlg(GetOrphStr(SCCancelQuery), mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      CanClose := False;
end;

end.
 
