{***************************************************************************}
{ TAdvOfficeStatusBar                                                       }
{ for Delphi & C++Builder                                                   }
{ version 1.0                                                               }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2006                                               }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of the author.                                      }
{***************************************************************************}

unit AdvOfficeStatusBarStylers;

interface

uses
  AdvOfficeStatusBar, Graphics, Windows, Forms, Messages, Controls, Classes,
  SysUtils, AdvStyleIF;

type
  TOfficeStatusBarFantasyStyle = (psArctic, psAquaBlue, psChocolate, psMacOS, psSilverFox,
    psSoftSand, psTerminalGreen, psTextured, psWindowsClassic, psUser);

  TOfficeStatusBarStyle = (psOffice2003Blue, psOffice2003Silver, psOffice2003Olive, psOffice2003Classic, psOffice2007Luna, psOffice2007Obsidian, psWindowsXP, psWhidbey, psCustom, psOffice2007Silver);

  TNotifierWindow = class(TWinControl)
  private
    FOnThemeChange: TNotifyEvent;
  protected
    procedure WndProc(var Msg: TMessage); override;
  published
    property OnThemeChange: TNotifyEvent read FOnThemeChange write FOnThemeChange;
  end;

  TAdvOfficeStatusBarOfficeStyler = class(TCustomAdvOfficeStatusBarStyler, ITMSStyle)
  private
    FNotifierWnd: TNotifierWindow;
    FOfficeStatusBarStyle: TOfficeStatusBarStyle;
  protected
    procedure SetOfficeStatusBarStyle(const Value: TOfficeStatusBarStyle);
    procedure ThemeChanged(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure SetComponentStyle(AStyle: TTMSStyle);
  published
    property Style: TOfficeStatusBarStyle read FOfficeStatusBarStyle write SetOfficeStatusBarStyle default psOffice2003Blue;
    property AutoThemeAdapt;
    property BorderColor;
    property PanelAppearanceLight;
    property PanelAppearanceDark;
  end;

  TAdvOfficeStatusBarFantasyStyler = class(TCustomAdvOfficeStatusBarStyler)
  private
    FOfficeStatusBarStyle: TOfficeStatusBarFantasyStyle;
  protected
    procedure SetOfficeStatusBarStyle(const Value: TOfficeStatusBarFantasyStyle);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Style: TOfficeStatusBarFantasyStyle read FOfficeStatusBarStyle write SetOfficeStatusBarStyle default psChocolate;
    property BorderColor;
    property PanelAppearanceLight;
    property PanelAppearanceDark;
  end;


implementation


const
  // theme changed notifier
  WM_THEMECHANGED = $031A;

type
  XPColorScheme = (xpNone, xpBlue, xpGreen, xpGray);

{$IFNDEF TMSDOTNET}
var
  GetCurrentThemeName: function(pszThemeFileName: PWideChar;
    cchMaxNameChars: Integer;
    pszColorBuff: PWideChar;
    cchMaxColorChars: Integer;
    pszSizeBuff: PWideChar;
    cchMaxSizeChars: Integer): THandle cdecl stdcall;

  IsThemeActive: function: BOOL cdecl stdcall;
{$ENDIF}


function IsWinXP: Boolean;
var
  VerInfo: TOSVersioninfo;
begin
{$IFNDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
{$ENDIF}
{$IFDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := Marshal.SizeOf(TypeOf(OSVersionInfo));
{$ENDIF}
  GetVersionEx(verinfo);
  Result := (verinfo.dwMajorVersion > 5) OR
    ((verinfo.dwMajorVersion = 5) AND (verinfo.dwMinorVersion >= 1));
end;

{$IFDEF TMSDOTNET}
function CurrentXPTheme: XPColorScheme;
var
  FileName, ColorScheme, SizeName: StringBuilder;
begin
  Result := xpNone;

  if IsWinXP then
  begin
    if IsThemeActive then
    begin
      FileName := StringBuilder.Create(255);
      SizeName := StringBuilder.Create(255);
      ColorScheme := StringBuilder.Create(255);
      GetCurrentThemeName(FileName, 255, ColorScheme, 255, SizeName, 255);
      if(ColorScheme.ToString = 'NormalColor') then
        Result := xpBlue
      else if (ColorScheme.ToString = 'HomeStead') then
        Result := xpGreen
      else if (ColorScheme.ToString = 'Metallic') then
        Result := xpGray
    end;
  end;
end;
{$ENDIF}

{$IFNDEF TMSDOTNET}
function CurrentXPTheme: XPColorScheme;
var
  FileName, ColorScheme, SizeName: WideString;
  hThemeLib: THandle;
begin
  hThemeLib := 0;
  Result := xpNone;

  if not IsWinXP then
    Exit;

  try
    hThemeLib := LoadLibrary('uxtheme.dll');

    if hThemeLib > 0 then
    begin
      IsThemeActive := GetProcAddress(hThemeLib,'IsThemeActive');

      if Assigned(IsThemeActive) then
        if IsThemeActive then
        begin
          GetCurrentThemeName := GetProcAddress(hThemeLib,'GetCurrentThemeName');
          if Assigned(GetCurrentThemeName) then
          begin
            SetLength(FileName, 255);
            SetLength(ColorScheme, 255);
            SetLength(SizeName, 255);
            GetCurrentThemeName(PWideChar(FileName), 255,
              PWideChar(ColorScheme), 255, PWideChar(SizeName), 255);
            if (PWideChar(ColorScheme) = 'NormalColor') then
              Result := xpBlue
            else if (PWideChar(ColorScheme) = 'HomeStead') then
              Result := xpGreen
            else if (PWideChar(ColorScheme) = 'Metallic') then
              Result := xpGray
            else
              Result := xpNone;
          end;
        end;
    end;
  finally
    if hThemeLib <> 0 then
      FreeLibrary(hThemeLib);
  end;
end;
{$ENDIF}

//------------------------------------------------------------------------------

{ TNotifierWindow }

procedure TNotifierWindow.WndProc(var Msg: TMessage);
begin
  if Msg.Msg = WM_THEMECHANGED  then
  begin
    if Assigned(FOnThemeChange) then
      FOnThemeChange(Self);
  end;
  inherited;
end;


function HTMLToRgb(color: tcolor): tcolor;
var
  r,g,b: integer;
begin
  r := (Color and $0000FF);
  g := (Color and $00FF00);
  b := (Color and $FF0000) shr 16;
  Result := b or g or (r shl 16);
end;

//------------------------------------------------------------------------------

constructor TAdvOfficeStatusBarOfficeStyler.Create(AOwner: TComponent);
var
  ctrl: TComponent;
begin
  inherited;
  FNotifierWnd := TNotifierWindow.Create(Self);

  // find first owning TWinControl owner
  ctrl := AOwner;
  while Assigned(ctrl) and not (ctrl is TWinControl) do
  begin
    ctrl := ctrl.Owner;
  end;

  if Assigned(ctrl) then
    if (ctrl is TWinControl) then
      FNotifierWnd.Parent := TWinControl(ctrl);
  
  FNotifierWnd.OnThemeChange := ThemeChanged;

  Style := psWindowsXP;
  Style := psOffice2003Blue;
end;

destructor TAdvOfficeStatusBarOfficeStyler.Destroy;
begin
  //FNotifierWnd.Free;
  inherited;
end;

procedure TAdvOfficeStatusBarOfficeStyler.Loaded;
begin
  inherited;
  if not (csDesigning in ComponentState) then
    ThemeChanged(Self);
end;

procedure TAdvOfficeStatusBarOfficeStyler.ThemeChanged(Sender: TObject);
var
  eTheme: XPColorScheme;
begin
  if not AutoThemeAdapt then
    Exit;

  eTheme := CurrentXPTheme();
  case eTheme of
    xpBlue: Style := psOffice2003Blue;
    xpGreen: Style := psOffice2003Olive;
    xpGray: Style := psOffice2003Silver;
  else
    Style := psWindowsXP;
  end;
end;

procedure TAdvOfficeStatusBarOfficeStyler.SetComponentStyle(AStyle: TTMSStyle);
begin
  Style := TOfficeStatusBarStyle(AStyle);
end;

procedure TAdvOfficeStatusBarOfficeStyler.SetOfficeStatusBarStyle(
  const Value: TOfficeStatusBarStyle);
begin
  if FOfficeStatusBarStyle <> Value then
  begin
    FOfficeStatusBarStyle := Value;
    BlendFactor := 50;
    case FOfficeStatusBarStyle of
    psWindowsXP:
      begin
        BorderColor := clSilver;
        { PanelAppearanceLight }
        PanelAppearanceLight.BorderColor := clNone;
        PanelAppearanceLight.Color := clBtnFace;
        PanelAppearanceLight.ColorTo := clBtnFace;
        PanelAppearanceLight.ColorMirror := clBtnFace;
        PanelAppearanceLight.ColorMirrorTo := clBtnFace;

        PanelAppearanceLight.TextColor := clBlack;
        PanelAppearanceLight.TextColorHot := clBlack;
        PanelAppearanceLight.TextColorDown := clBlack;

        PanelAppearanceLight.ColorHot := $00EFD3C6;
        PanelAppearanceLight.ColorHotTo := $00EFD3C6;
        PanelAppearanceLight.ColorMirrorHot := clNone;
        PanelAppearanceLight.ColorMirrorHotTo := clNone;
        PanelAppearanceLight.BorderColorHot := clGray;
        PanelAppearanceLight.ColorDown := $00B59284;
        PanelAppearanceLight.ColorDownTo := $00B59284;
        PanelAppearanceLight.ColorMirrorDown := clNone;
        PanelAppearanceLight.ColorMirrorDownTo := clNone;
        PanelAppearanceLight.BorderColorDown := clBlack;

        { PanelAppearanceDark }
        PanelAppearanceDark.BorderColor := clNone;
        PanelAppearanceDark.Color := clWhite;
        PanelAppearanceDark.ColorTo := clBtnFace;
        PanelAppearanceDark.ColorMirror := clBtnFace;
        PanelAppearanceDark.ColorMirrorTo := clBtnFace;

        PanelAppearanceDark.TextColor := clBlack;
        PanelAppearanceDark.TextColorHot := clBlack;
        PanelAppearanceDark.TextColorDown := clBlack;

        PanelAppearanceDark.ColorHot := $00EFD3C6;
        PanelAppearanceDark.ColorHotTo := $00EFD3C6;
        PanelAppearanceDark.ColorMirrorHot := clNone;
        PanelAppearanceDark.ColorMirrorHotTo := clNone;
        PanelAppearanceDark.BorderColorHot := clGray;
        PanelAppearanceDark.ColorDown := $00B59284;
        PanelAppearanceDark.ColorDownTo := $00B59284;
        PanelAppearanceDark.ColorMirrorDown := clNone;
        PanelAppearanceDark.ColorMirrorDownTo := clNone;
        PanelAppearanceDark.BorderColorDown := clBlack;

      end;
    psOffice2003Blue:
      begin
        { PanelAppearanceLight }
        BorderColor := $E4AE88;

        PanelAppearanceLight.BorderColor := $E3B28D;
        PanelAppearanceLight.Color := $FADDC6;
        PanelAppearanceLight.ColorTo := $E2A982;
        PanelAppearanceLight.ColorMirror := $E2A982;
        PanelAppearanceLight.ColorMirrorTo := $E2A982;

        PanelAppearanceLight.TextColor := clBlack;
        PanelAppearanceLight.TextColorHot := clBlack;
        PanelAppearanceLight.TextColorDown := clBlack;

        PanelAppearanceLight.ColorHot := $D4FBFF;
        PanelAppearanceLight.ColorHotTo := $63C4F7;
        PanelAppearanceLight.ColorMirrorHot := $63C4F7;
        PanelAppearanceLight.ColorMirrorHotTo := $63C4F7;
        PanelAppearanceLight.BorderColorHot := clGray;
        PanelAppearanceLight.ColorDown := $8CE1FA;
        PanelAppearanceLight.ColorDownTo := $1D9AEF;
        PanelAppearanceLight.ColorMirrorDown := $1D9AEF;
        PanelAppearanceLight.ColorMirrorDownTo := $1D9AEF;
        PanelAppearanceLight.BorderColorDown := $9C430F;

        { PanelAppearanceDark }
        PanelAppearanceDark.BorderColor := clNone;
        PanelAppearanceDark.Color := $D38355;
        PanelAppearanceDark.ColorTo := $9C430F;
        PanelAppearanceDark.ColorMirror := $9C430F;
        PanelAppearanceDark.ColorMirrorTo := $9C430F;

        PanelAppearanceDark.TextColor := clWhite;
        PanelAppearanceDark.TextColorHot := clWhite;
        PanelAppearanceDark.TextColorDown := clWhite;

        PanelAppearanceDark.ColorHot := $D4FBFF;
        PanelAppearanceDark.ColorHotTo := $63C4F7;
        PanelAppearanceDark.ColorMirrorHot := $63C4F7;
        PanelAppearanceDark.ColorMirrorHotTo := $63C4F7;
        PanelAppearanceDark.BorderColorHot := clGray;
        PanelAppearanceDark.ColorDown := $8CE1FA;
        PanelAppearanceDark.ColorDownTo := $1D9AEF;
        PanelAppearanceDark.ColorMirrorDown := $1D9AEF;
        PanelAppearanceDark.ColorMirrorDownTo := $1D9AEF;
        PanelAppearanceDark.BorderColorDown := $9C430F;
      end;
    psOffice2003Olive:
      begin
        BorderColor := $8CC0B1;
        
        { PanelAppearanceLight }
        PanelAppearanceLight.BorderColor := clNone;
        PanelAppearanceLight.Color := $CFF0EA;
        PanelAppearanceLight.ColorTo := $90C3B5;
        PanelAppearanceLight.ColorMirror := $90C3B5;
        PanelAppearanceLight.ColorMirrorTo := $90C3B5;

        PanelAppearanceLight.TextColor := clBlack;
        PanelAppearanceLight.TextColorHot := clBlack;
        PanelAppearanceLight.TextColorDown := clBlack;

        PanelAppearanceLight.ColorHot := $D4FBFF;
        PanelAppearanceLight.ColorHotTo := $63C4F7;
        PanelAppearanceLight.ColorMirrorHot := $63C4F7;
        PanelAppearanceLight.ColorMirrorHotTo := $63C4F7;
        PanelAppearanceLight.BorderColorHot := clGray;
        PanelAppearanceLight.ColorDown := $8CE1FA;
        PanelAppearanceLight.ColorDownTo := $1D9AEF;
        PanelAppearanceLight.ColorMirrorDown := $1D9AEF;
        PanelAppearanceLight.ColorMirrorDownTo := $1D9AEF;
        PanelAppearanceLight.BorderColorDown := $4D846E;

        { PanelAppearanceDark }
        PanelAppearanceDark.BorderColor := clNone;
        PanelAppearanceDark.Color := $81BFAE;
        PanelAppearanceDark.ColorTo := $4D846E;
        PanelAppearanceDark.ColorMirror := $4D846E;
        PanelAppearanceDark.ColorMirrorTo := $4D846E;

        PanelAppearanceDark.TextColor := clWhite;

        PanelAppearanceDark.ColorHot := $D4FBFF;
        PanelAppearanceDark.ColorHotTo := $63C4F7;
        PanelAppearanceDark.ColorMirrorHot := $63C4F7;
        PanelAppearanceDark.ColorMirrorHotTo := $63C4F7;
        PanelAppearanceDark.BorderColorHot := clGray;
        PanelAppearanceDark.ColorDown := $8CE1FA;
        PanelAppearanceDark.ColorDownTo := $1D9AEF;
        PanelAppearanceDark.ColorMirrorDown := $1D9AEF;
        PanelAppearanceDark.ColorMirrorDownTo := $1D9AEF;
        PanelAppearanceDark.BorderColorDown := $4D846E;
      end;
    psOffice2003Silver:
      begin
        BorderColor := $B39698;
        
        { PanelAppearanceLight }
        PanelAppearanceLight.BorderColor := clNone;
        PanelAppearanceLight.Color := $00F7F3F3;
        PanelAppearanceLight.ColorTo := $00E6D8D8;
        PanelAppearanceLight.ColorMirror := $00E6D8D8;
        PanelAppearanceLight.ColorMirrorTo := $00E6D8D8;

        PanelAppearanceLight.TextColor := clBlack;

        PanelAppearanceLight.ColorHot := $D4FBFF;
        PanelAppearanceLight.ColorHotTo := $63C4F7;
        PanelAppearanceLight.ColorMirrorHot := $63C4F7;
        PanelAppearanceLight.ColorMirrorHotTo := $63C4F7;
        PanelAppearanceLight.BorderColorHot := clGray;
        PanelAppearanceLight.ColorDown := $8CE1FA;
        PanelAppearanceLight.ColorDownTo := $1D9AEF;
        PanelAppearanceLight.ColorMirrorDown := $1D9AEF;
        PanelAppearanceLight.ColorMirrorDownTo := $1D9AEF;
        PanelAppearanceLight.BorderColorDown := $B79B9D;

        { PanelAppearanceDark }
        PanelAppearanceDark.BorderColor := clNone;
        PanelAppearanceDark.Color := $00E6D8D8;
        PanelAppearanceDark.ColorTo := $B79B9D;
        PanelAppearanceDark.ColorMirror := $B79B9D;
        PanelAppearanceDark.ColorMirrorTo := $B79B9D;

        PanelAppearanceDark.TextColor := clWhite;
        PanelAppearanceDark.TextColorHot := clWhite;
        PanelAppearanceDark.TextColorDown := clWhite;

        PanelAppearanceDark.ColorHot := $D4FBFF;
        PanelAppearanceDark.ColorHotTo := $63C4F7;
        PanelAppearanceDark.ColorMirrorHot := $63C4F7;
        PanelAppearanceDark.ColorMirrorHotTo := $63C4F7;
        PanelAppearanceDark.BorderColorHot := clGray;
        PanelAppearanceDark.ColorDown := $8CE1FA;
        PanelAppearanceDark.ColorDownTo := $1D9AEF;
        PanelAppearanceDark.ColorMirrorDown := $1D9AEF;
        PanelAppearanceDark.ColorMirrorDownTo := $1D9AEF;
        PanelAppearanceDark.BorderColorDown := $B79B9D;
      end;
    psOffice2007Luna:
      begin
        BorderColor := $B07D56;
        { PanelAppearanceLight }
        PanelAppearanceLight.BorderColor := clNone;

        PanelAppearanceLight.Color := $F9E6D7;
        PanelAppearanceLight.ColorTo := $F8DCC7;

        PanelAppearanceLight.ColorMirror := $F5D0B3;
        PanelAppearanceLight.ColorMirrorTo := $F7E0CD;

        PanelAppearanceLight.TextColor := $612009;
        PanelAppearanceLight.TextColorHot := clBlack;
        PanelAppearanceLight.TextColorDown := clBlack;

        PanelAppearanceLight.ColorHot := $FBFFFF;
        PanelAppearanceLight.ColorHotTo := $C0F0FF;
        PanelAppearanceLight.ColorMirrorHotTo := $A0E6FC;
        PanelAppearanceLight.ColorMirrorHot := $6BD8FF;
        PanelAppearanceLight.BorderColorHot := $99CEDB;

        PanelAppearanceLight.ColorDown := $77B4F7;
        PanelAppearanceLight.ColorDownTo := $459AF9;
        PanelAppearanceLight.ColorMirrorDownTo := $03AEFF;
        PanelAppearanceLight.ColorMirrorDown := $1982F8;
        PanelAppearanceLight.BorderColorDown := $45667B;

        { PanelAppearanceDark }
        PanelAppearanceDark.BorderColor := clNone;

        PanelAppearanceDark.Color := $F8DCC5;
        PanelAppearanceDark.ColorTo := $F5B687;
        PanelAppearanceDark.ColorMirror := $EAB690;
        PanelAppearanceDark.ColorMirrorTo := $C29574;

        PanelAppearanceDark.TextColor := $612009;
        PanelAppearanceDark.TextColorHot := $612009;
        PanelAppearanceDark.TextColorDown := $612009;

        PanelAppearanceDark.ColorHot := $FBFFFF;
        PanelAppearanceDark.ColorHotTo := $C0F0FF;
        PanelAppearanceDark.ColorMirrorHotTo := $A0E6FC;
        PanelAppearanceDark.ColorMirrorHot := $6BD8FF;
        PanelAppearanceDark.BorderColorHot := $99CEDB;

        PanelAppearanceDark.ColorDown := $77B4F7;
        PanelAppearanceDark.ColorDownTo := $459AF9;
        PanelAppearanceDark.ColorMirrorDownTo := $03AEFF;
        PanelAppearanceDark.ColorMirrorDown := $1982F8;
        PanelAppearanceDark.BorderColorDown := $45667B;
      end;

    psOffice2007Obsidian:
      begin
        BorderColor := $414141;
        { PanelAppearanceLight }
        PanelAppearanceLight.Color := $414141;
        PanelAppearanceLight.ColorTo := $30302F;
        PanelAppearanceLight.ColorMirror := $30302F;
        PanelAppearanceLight.ColorMirrorTo := $4C4C4C;
        PanelAppearanceLight.BorderColor := clNone;

        PanelAppearanceLight.TextColor := clWhite;
        PanelAppearanceLight.TextColorHot := clWhite;
        PanelAppearanceLight.TextColorDown := clWhite;

        PanelAppearanceLight.ColorHot := $FBFFFF;
        PanelAppearanceLight.ColorHotTo := $C0F0FF;
        PanelAppearanceLight.ColorMirrorHotTo := $A0E6FC;
        PanelAppearanceLight.ColorMirrorHot := $6BD8FF;
        PanelAppearanceLight.BorderColorHot := $99CEDB;

        PanelAppearanceLight.ColorDown := $77B4F7;
        PanelAppearanceLight.ColorDownTo := $459AF9;
        PanelAppearanceLight.ColorMirrorDownTo := $03AEFF;
        PanelAppearanceLight.ColorMirrorDown := $1982F8;
        PanelAppearanceLight.BorderColorDown := $45667B;

        { PanelAppearanceDark }
        PanelAppearanceDark.BorderColor := clNone;
        PanelAppearanceDark.Color := $A19F9E;
        PanelAppearanceDark.ColorTo := $635F5E;
        PanelAppearanceDark.ColorMirror := $635F5E;
        PanelAppearanceDark.ColorMirrorTo := $534D4B;

        PanelAppearanceDark.TextColor := clWhite;
        PanelAppearanceDark.TextColorHot := clWhite;
        PanelAppearanceDark.TextColorDown := clWhite;

        PanelAppearanceDark.ColorHot := $FBFFFF;
        PanelAppearanceDark.ColorHotTo := $C0F0FF;
        PanelAppearanceDark.ColorMirrorHotTo := $A0E6FC;
        PanelAppearanceDark.ColorMirrorHot := $6BD8FF;
        PanelAppearanceDark.BorderColorHot := $99CEDB;

        PanelAppearanceDark.ColorDown := $77B4F7;
        PanelAppearanceDark.ColorDownTo := $459AF9;
        PanelAppearanceDark.ColorMirrorDownTo := $03AEFF;
        PanelAppearanceDark.ColorMirrorDown := $1982F8;
        PanelAppearanceDark.BorderColorDown := $45667B;

      end;
    psOffice2007Silver:
      begin
        BorderColor := $766A61; 
        { PanelAppearanceLight }
        PanelAppearanceLight.BorderColor := clNone;

        PanelAppearanceLight.Color := $EBE8E7;
        PanelAppearanceLight.ColorTo := $C7BBB5;

        PanelAppearanceLight.ColorMirror := $B7B0AA;
        PanelAppearanceLight.ColorMirrorTo := $CEC9C7;

        PanelAppearanceLight.TextColor := $2A2623;
        PanelAppearanceLight.TextColorHot := clBlack;
        PanelAppearanceLight.TextColorDown := clBlack;

        PanelAppearanceLight.ColorHot := $FBFFFF;
        PanelAppearanceLight.ColorHotTo := $C0F0FF;
        PanelAppearanceLight.ColorMirrorHotTo := $A0E6FC;
        PanelAppearanceLight.ColorMirrorHot := $6BD8FF;
        PanelAppearanceLight.BorderColorHot := $99CEDB;

        PanelAppearanceLight.ColorDown := $77B4F7;
        PanelAppearanceLight.ColorDownTo := $459AF9;
        PanelAppearanceLight.ColorMirrorDownTo := $03AEFF;
        PanelAppearanceLight.ColorMirrorDown := $1982F8;
        PanelAppearanceLight.BorderColorDown := $45667B;

        { PanelAppearanceDark }
        PanelAppearanceDark.BorderColor := clNone;

        PanelAppearanceDark.Color := $EBE8E7;
        PanelAppearanceDark.ColorTo := $C7BBB6;
        PanelAppearanceDark.ColorMirror := $BAB4AE;
        PanelAppearanceDark.ColorMirrorTo := $AFABA5;

        PanelAppearanceDark.TextColor := $2A2623;
        PanelAppearanceDark.TextColorHot := $612009;
        PanelAppearanceDark.TextColorDown := $612009;

        PanelAppearanceDark.ColorHot := $FBFFFF;
        PanelAppearanceDark.ColorHotTo := $C0F0FF;
        PanelAppearanceDark.ColorMirrorHotTo := $A0E6FC;
        PanelAppearanceDark.ColorMirrorHot := $6BD8FF;
        PanelAppearanceDark.BorderColorHot := $99CEDB;

        PanelAppearanceDark.ColorDown := $77B4F7;
        PanelAppearanceDark.ColorDownTo := $459AF9;
        PanelAppearanceDark.ColorMirrorDownTo := $03AEFF;
        PanelAppearanceDark.ColorMirrorDown := $1982F8;
        PanelAppearanceDark.BorderColorDown := $45667B;
      end;
    psWhidbey:
      begin
        BorderColor := $A8C0C0;

        { PanelAppearanceLight }
        PanelAppearanceLight.BorderColor := clNone;
        PanelAppearanceLight.Color := $00F5F9FA;
        PanelAppearanceLight.ColorTo := $00A8C0C0;
        PanelAppearanceLight.ColorMirror := clNone;
        PanelAppearanceLight.ColorMirrorTo := clNone;

        PanelAppearanceLight.TextColor := clBlack;
        PanelAppearanceLight.TextColorHot := clBlack;
        PanelAppearanceLight.TextColorDown := clBlack;

        PanelAppearanceLight.ColorHot := $D4FBFF;
        PanelAppearanceLight.ColorHotTo := $63C4F7;
        PanelAppearanceLight.ColorMirrorHot := $63C4F7;
        PanelAppearanceLight.ColorMirrorHotTo := $63C4F7;
        PanelAppearanceLight.BorderColorHot := clGray;
        PanelAppearanceLight.ColorDown := $8CE1FA;
        PanelAppearanceLight.ColorDownTo := $1D9AEF;
        PanelAppearanceLight.ColorMirrorDown := $1D9AEF;
        PanelAppearanceLight.ColorMirrorDownTo := $1D9AEF;
        PanelAppearanceLight.BorderColorDown := clBlack;

        { PanelAppearanceDark }
        PanelAppearanceDark.BorderColor := clNone;
        PanelAppearanceDark.Color := $00EBEEEF;
        PanelAppearanceDark.ColorTo := $007E9898;
        PanelAppearanceDark.ColorMirror := clNone;
        PanelAppearanceDark.ColorMirrorTo := clNone;

        PanelAppearanceDark.TextColor := clBlack;

        PanelAppearanceDark.ColorHot := $D4FBFF;
        PanelAppearanceDark.ColorHotTo := $63C4F7;
        PanelAppearanceDark.ColorMirrorHot := $63C4F7;
        PanelAppearanceDark.ColorMirrorHotTo := $63C4F7;
        PanelAppearanceDark.BorderColorHot := clGray;
        PanelAppearanceDark.ColorDown := $8CE1FA;
        PanelAppearanceDark.ColorDownTo := $1D9AEF;
        PanelAppearanceDark.ColorMirrorDown := $1D9AEF;
        PanelAppearanceDark.ColorMirrorDownTo := $1D9AEF;
        PanelAppearanceDark.BorderColorDown := clBlack;
      end;

   psOffice2003Classic:
      begin
        BorderColor := $C9D1D5;
        
        { PanelAppearanceLight }
        PanelAppearanceLight.BorderColor := clNone;
        PanelAppearanceLight.Color := clWhite;
        PanelAppearanceLight.ColorTo := $C9D1D5;
        PanelAppearanceLight.ColorMirror := clNone;
        PanelAppearanceLight.ColorMirrorTo := clNone;

        PanelAppearanceLight.TextColor := clBlack;
        PanelAppearanceLight.TextColorHot := clBlack;
        PanelAppearanceLight.TextColorDown := clBlack;

        PanelAppearanceLight.ColorHot := $D2BDB6;
        PanelAppearanceLight.ColorHotTo := $D2BDB6;
        PanelAppearanceLight.ColorMirrorHot := $D2BDB6;
        PanelAppearanceLight.ColorMirrorHotTo := $D2BDB6;
        PanelAppearanceLight.BorderColorHot := clGray;
        PanelAppearanceLight.ColorDown := $00E2B598;
        PanelAppearanceLight.ColorDownTo := $00E2B598;
        PanelAppearanceLight.ColorMirrorDown := clNone;
        PanelAppearanceLight.ColorMirrorDownTo := clNone;
        PanelAppearanceLight.BorderColorDown := clBlack;

        { PanelAppearanceDark }
        PanelAppearanceDark.BorderColor := clNone;
        PanelAppearanceDark.Color := clGray;
        PanelAppearanceDark.ColorTo := clGray;
        PanelAppearanceDark.ColorMirror := clNone;
        PanelAppearanceDark.ColorMirrorTo := clNone;

        PanelAppearanceDark.TextColor := clWhite;
        PanelAppearanceDark.TextColorHot := clWhite;
        PanelAppearanceDark.TextColorDown := clWhite;

        PanelAppearanceDark.ColorHot := $D2BDB6;
        PanelAppearanceDark.ColorHotTo := $D2BDB6;
        PanelAppearanceDark.ColorMirrorHot := clNone;
        PanelAppearanceDark.ColorMirrorHotTo := clNone;
        PanelAppearanceDark.BorderColorHot := clGray;
        PanelAppearanceDark.ColorDown := $00E2B598;
        PanelAppearanceDark.ColorDownTo := $00E2B598;
        PanelAppearanceDark.ColorMirrorDown := clNone;
        PanelAppearanceDark.ColorMirrorDownTo := clNone;
        PanelAppearanceDark.BorderColorDown := clBlack;
      end;
    end;

    Change(1);
  end;
end;


{ TAdvOfficeStatusBarFantasyStyler }

constructor TAdvOfficeStatusBarFantasyStyler.Create(AOwner: TComponent);
begin
  inherited;
  Style := psChocolate;
end;

procedure TAdvOfficeStatusBarFantasyStyler.SetOfficeStatusBarStyle(
  const Value: TOfficeStatusBarFantasyStyle);
begin
  FOfficeStatusBarStyle := Value;
  BlendFactor := 50;

  case FOfficeStatusBarStyle of
  psChocolate:
    begin
    end;

  psArctic :
    begin
    end;

  psWindowsClassic :
    begin
    end;

  psTerminalGreen :
    begin
    end;

  psAquaBlue :
    begin
    end;

  psSilverFox :
    begin
    end;

  psTextured :
    begin
    end;

  psMacOS :
    begin
    end;

  psSoftSand :
    begin
    end;
  end;

end;

end.
