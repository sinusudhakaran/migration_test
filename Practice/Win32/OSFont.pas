unit OSFont;

//------------------------------------------------------------------------------
interface

uses
  forms,
  classes,
  winutils,
  Graphics,
  Messages,
  StdCtrls,
  Controls;

type

  TForm = class (Forms.TForm)
  public
    constructor Create(AOwner: tComponent); override;

    function ShowModal: Integer; override;
  end;

  function HyperLinkColor: TColor;
  procedure SetVistaTreeView(const AHandle: THandle);
  procedure SetHyperlinkFont(const AFont: TFont);
  procedure SetPasswordFont(const AEdit: TEdit);

//------------------------------------------------------------------------------
implementation

uses
  Windows,
  uxtheme;

//------------------------------------------------------------------------------
constructor TForm.Create(AOwner: tComponent);
var
  NonClientMetrics : TNonClientMetrics;
  DPI : Integer;
  lHDC : HDC;
begin
  Inherited;

  NonClientMetrics.cbSize := SizeOf(NonClientMetrics);
  SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0);
  Font.Handle := CreateFontIndirect(NonClientMetrics.lfMessageFont);

  lHDC := Windows.GetDC(Hwnd(0));

  DPI := GetDevicecaps(lHDC,LogPixelsX);

  if DPI> 100 then  // Large size 120 DPI
     Font.size := 8
  else  // Normal size 96
     Font.size := 10;

  ReleaseDC(0,lHDC);
end;

//------------------------------------------------------------------------------
function TForm.ShowModal: Integer;
begin
  // This created too many problems with forms doing work before Showmodal and then
  // all the object being cleared
  //PopupParent := Application.MainForm;

  Result := inherited ShowModal;
end;

//------------------------------------------------------------------------------
function HyperLinkColor: TColor;
begin
  if GetSysColorBrush(COLOR_HOTLIGHT) = 0 then
     Result := clBlue
  else
     Result := GetSysColor(COLOR_HOTLIGHT);
end;

//------------------------------------------------------------------------------
procedure SetHyperlinkFont(const AFont: TFont);
begin
   AFont.Color := HyperLinkColor;
   AFont.Style := AFont.Style + [FSUnderline];
end;

//------------------------------------------------------------------------------
procedure SetPasswordFont(const AEdit: TEdit);
begin
   AEdit.Font.Name := 'Wingdings';
   AEdit.Font.Size := 12;
   AEdit.PasswordChar := #$9F;
end;

//------------------------------------------------------------------------------
procedure SetVistaTreeView(const AHandle: THandle);
begin
   if IsWindowsVista then
     SetWindowTheme(aHandle, 'explorer', nil);
end;

end.
