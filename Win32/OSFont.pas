unit OSFont;

interface

uses
forms, classes, winutils, Graphics, Messages,StdCtrls;

type

  TForm = class (Forms.TForm)
  public
    constructor Create(AOwner: tComponent); override;
  protected
    //procedure WMSyscommand(var Message: TWmSysCommand); message WM_SYSCOMMAND;

  end;

  function HyperLinkColor: TColor;

  procedure SetVistaTreeView(const AHandle: THandle);

  procedure SetHyperlinkFont(const AFont: TFont);

  procedure SetPasswordFont(const AEdit: TEdit);

implementation

uses windows, uxtheme;
{ TForm }

function HyperLinkColor: TColor;
begin
  if GetSysColorBrush(COLOR_HOTLIGHT) = 0 then
     Result := clBlue
  else
     Result := GetSysColor(COLOR_HOTLIGHT);
end;

procedure SetHyperlinkFont(const AFont: TFont);
begin
   AFont.Color := HyperLinkColor;
   AFont.Style := AFont.Style + [FSUnderline];
end;

procedure SetPasswordFont(const AEdit: TEdit);
begin
   AEdit.Font.Name := 'Wingdings';
   AEdit.Font.Size := 12;
   AEdit.PasswordChar := #$9F;
end;

procedure SetVistaTreeView(const AHandle: THandle);
begin
   if IsWindowsVista then
     SetWindowTheme(aHandle, 'explorer', nil);
end;


constructor TForm.Create(AOwner: tComponent);
  {
  begin

  inherited;
  if IsVista then begin
    Font.name := 'Segoe UI';
    Font.size := 9;
  end else begin
    Font.name := 'Tahoma';
    Font.size := 8;
  end;
  }
var NonClientMetrics :TNonClientMetrics;
    DPI: Integer;
    lHDC: HDC;
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


  {if Scaled then
  begin
    Font.Height := NonClientMetrics.lfMessageFont.lfHeight;
  end; }

end;

(*
procedure TForm.WMSyscommand(var Message: TWmSysCommand);
begin
   case (Message.CmdType and $FFF0) of
    SC_MINIMIZE: begin
          ShowWindow(Handle, SW_MINIMIZE);
          Message.Result := 0;
       end;
    SC_RESTORE: begin
          ShowWindow(Handle, SW_RESTORE);
          Message.Result := 0;
       end;
    else inherited;
   end;
end;
*)
end.
