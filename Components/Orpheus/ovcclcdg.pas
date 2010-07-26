{*********************************************************}
{*                  OVCCLCDG.PAS 4.05                    *}
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

unit ovcclcdg;
  {-Calculator dialog}

interface

uses
  Windows, Classes, Controls, ExtCtrls, Forms, Graphics, StdCtrls, SysUtils,
  OvcBase, OvcConst, OvcData, OvcExcpt, OvcDlg, OvcCalc;

type
  TOvcfrmCalculatorDlg = class(TForm)
    btnHelp: TButton;
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    OvcCalculator1: TOvcCalculator;
    procedure FormShow(Sender: TObject);                                 {!!.05}
  public
    Value: double;
  end;

type
  TOvcCalculatorDialog = class(TOvcBaseDialog)
  protected {private}
    {property variables}
    FCalculator : TOvcCalculator;
    FValue      : Double;                                                {!!.05}

  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function Execute : Boolean; override;

    property Calculator : TOvcCalculator
      read FCalculator;

  published
    {properties}
    property Caption;
    property Font;
    property Icon;
    property Options;
    property Placement;
    property Value: Double                                               {!!.05}
      read FValue write FValue;                                          {!!.05}

    {events}
    property OnHelpClick;
  end;


implementation

{$R *.DFM}


constructor TOvcCalculatorDialog.Create(AOwner : TComponent);
begin
{$IFDEF VERSION5}
  if not ((AOwner is TCustomForm) or (AOwner is TCustomFrame)) then
{$ELSE}
  if not (AOwner is TForm) then
{$ENDIF}
    raise EOvcException.Create(GetOrphStr(SCOwnerMustBeForm));

  inherited Create(AOwner);

  FPlacement.Height := 200;
  FPlacement.Width := 225;

  FCalculator := TOvcCalculator.Create(nil);
  FCalculator.Visible := False;
{$IFDEF VERSION5}
  FCalculator.Parent := (AOwner as TWinControl);
{$ELSE}
  FCalculator.Parent := AOwner as TForm;
{$ENDIF}
end;

destructor TOvcCalculatorDialog.Destroy;
begin
  inherited Destroy;
end;

function TOvcCalculatorDialog.Execute : Boolean;
var
  F : TOvcfrmCalculatorDlg;
begin
  F := TOvcfrmCalculatorDlg.Create(Application);
  try
    DoFormPlacement(F);

    F.btnHelp.Visible := doShowHelp in Options;
    F.btnHelp.OnClick := FOnHelpClick;

    {transfer Calculator properties}
    F.OvcCalculator1.Colors.Assign(FCalculator.Colors);
    F.OvcCalculator1.Font := FCalculator.Font;
    F.OvcCalculator1.TapeFont := FCalculator.TapeFont;
    F.OvcCalculator1.Decimals := FCalculator.Decimals;
    F.OvcCalculator1.Options := FCalculator.Options;
    F.OvcCalculator1.TapeHeight := FCalculator.TapeHeight;
    F.OvcCalculator1.TapeSeparatorChar := FCalculator.TapeSeparatorChar;
    F.OvcCalculator1.Hint := FCalculator.Hint;
    F.OvcCalculator1.PopupMenu := FCalculator.PopupMenu;
    F.OvcCalculator1.ShowHint := FCalculator.ShowHint;
    F.Value := FValue;

    {show the memo form}
    Result := F.ShowModal = mrOK;
    if Result then begin                                                 {!!.05}
      FCalculator.DisplayValue := F.OvcCalculator1.DisplayValue;
      FValue := FCalculator.DisplayValue;                                {!!.05}
    end;                                                                 {!!.05}

  finally
    F.Free;
  end;
end;

procedure TOvcfrmCalculatorDlg.FormShow(Sender: TObject);                {!!.05}
begin                                                                    {!!.05}
  OvcCalculator1.DisplayValue := Value;                                  {!!.05}
  OvcCalculator1.LastOperand := Value;                                   {!!.05}
end;                                                                     {!!.05}

end.
