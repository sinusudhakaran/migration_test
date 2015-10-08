unit SpinnerFrm;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls;

type
  TfrmSpinner = class(TForm)
    imgSpinner: TImage;
    lblMessage: TLabel;
    imgCircle: TImage;
    imgBuffer: TImage;
    tmrSpin: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure tmrSpinTimer(Sender: TObject);
  private
    fEnableSpinner : boolean;
    fSpinValue : extended;
    fSpinnerShowing : boolean;
  protected
    procedure SetSpinMessage(aValue : string);
    function GetSpinMessage() : string;

    procedure SetEnableSpinner(aValue : boolean);
  public
    constructor Create(AOwner: TComponent); override;

    procedure ShowSpinner(aMessage : string; aTop, aLeft : integer);
    procedure UpdateSpinner(aTop, aLeft : integer);
    procedure CloseSpinner();

    property SpinMessage : string read GetSpinMessage write SetSpinMessage;
    property EnableSpinner : boolean read fEnableSpinner write SetEnableSpinner;
  end;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

//------------------------------------------------------------------------------
constructor TfrmSpinner.Create(AOwner: TComponent);
begin
  inherited;

  if AOwner is TWinControl then
  begin
    Visible := false;
    Parent := TWinControl(AOwner);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmSpinner.FormCreate(Sender: TObject);
begin
  fSpinnerShowing := false;

  tmrSpin.Enabled := false;
  SystemParametersInfo(SPI_SETDRAGFULLWINDOWS, 0, nil, 0); {Disable drag showing}
  fSpinValue := 0;
end;

//------------------------------------------------------------------------------
function TfrmSpinner.GetSpinMessage: string;
begin
  Result := lblMessage.Caption;
end;

//------------------------------------------------------------------------------
procedure TfrmSpinner.SetSpinMessage(aValue: string);
begin
  lblMessage.Caption := aValue;
end;

//------------------------------------------------------------------------------
procedure TfrmSpinner.SetEnableSpinner(aValue: boolean);
begin
  fEnableSpinner := aValue;
  tmrSpin.Enabled := aValue;
end;

//------------------------------------------------------------------------------
procedure TfrmSpinner.tmrSpinTimer(Sender: TObject);
const
  MAX_RADIANS = 6.28319;
  RADIAN_NEXT_POINT = 1.5;
  INC_VALUE   = 0.25;
var
  ImgRect : TRect;
  Centre : TPoint;
  Point1 : TPoint;
  Point2 : TPoint;
  NextSpinValue : extended;
begin
  Centre.X := 35;
  Centre.Y := 35;

  ImgRect.Top := 0;
  ImgRect.Left := 0;
  ImgRect.Right := 70;
  ImgRect.Bottom := 70;

  fSpinValue := fSpinValue + INC_VALUE;
  if fSpinValue > MAX_RADIANS then
    fSpinValue := fSpinValue - MAX_RADIANS;

  NextSpinValue := fSpinValue + RADIAN_NEXT_POINT;
  if NextSpinValue > MAX_RADIANS then
    NextSpinValue := NextSpinValue - MAX_RADIANS;

  Point1.X := Centre.X + trunc((cos(fSpinValue) * 50));
  Point1.Y := Centre.Y + trunc((sin(fSpinValue) * 50));

  Point2.X := Centre.X + trunc((cos(NextSpinValue) * 50));
  Point2.Y := Centre.Y + trunc((sin(NextSpinValue) * 50));

  imgBuffer.Canvas.CopyRect(ImgRect, imgCircle.Canvas, ImgRect);
  imgBuffer.Canvas.Pen.Color := clwhite;
  imgBuffer.Canvas.Brush.Color := clwhite;
  imgBuffer.Canvas.Brush.Style := bsSolid;
  imgBuffer.Canvas.Polygon([Centre, Point1, Point2]);

  imgSpinner.Canvas.CopyRect(ImgRect, imgBuffer.Canvas, ImgRect);
end;

//------------------------------------------------------------------------------
procedure TfrmSpinner.ShowSpinner(aMessage: string; aTop, aLeft: integer);
begin
  SpinMessage := aMessage;
  EnableSpinner := true;
  fSpinnerShowing := true;
  Show();
  UpdateSpinner(aTop, aLeft);
  Visible := true;
end;

//------------------------------------------------------------------------------
procedure TfrmSpinner.UpdateSpinner(aTop, aLeft: integer);
begin
  if not fSpinnerShowing then
    Exit;

  Top := aTop;
  Left := aLeft;
end;

//------------------------------------------------------------------------------
procedure TfrmSpinner.CloseSpinner;
begin
  if fSpinnerShowing then
  begin
    fSpinnerShowing := false;
    Close;
    Visible := false;
    EnableSpinner := false;
  end;
end;

end.
