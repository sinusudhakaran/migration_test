{*************************************************************************}
{ TAdvPreviewMenu component                                               }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright ©  2005 - 2008                                      }
{           Email : info@tmssoftware.com                                  }
{           Web : http://www.tmssoftware.com                              }
{                                                                         }
{ The source code is given as is. The author is not responsible           }
{ for any possible damage done due to the use of this code.               }
{ The component can be freely used in any application. The complete       }
{ source code remains property of the author and may not be distributed,  }
{ published, given or sold in any form as such. No parts of the source    }
{ code can be included in any other component or application without      }
{ written authorization of the author.                                    }
{*************************************************************************}

unit AdvPreviewMenuStylers;

interface

uses
  Graphics, Windows, Forms, Messages, Controls, Classes, SysUtils, AdvPreviewMenu,
  AdvStyleIF, AdvGlowButton;

type

  TPreviewMenuStyle = (psOffice2003Blue, psOffice2003Silver, psOffice2003Olive, psOffice2003Classic, psOffice2007Luna, psOffice2007Obsidian, psWindowsXP, psWhidbeyStyle, psCustom, psOfficeXP, psOffice2007Silver);

  TNotifierWindow = class(TWinControl)
  private
    FOnThemeChange: TNotifyEvent;
  protected
    procedure WndProc(var Msg: TMessage); override;
  published
    property OnThemeChange: TNotifyEvent read FOnThemeChange write FOnThemeChange;
  end;

  TAdvPreviewMenuOfficeStyler = class(TAdvCustomPreviewMenuStyler, ITMSStyle)
  private
    FNotifierWnd: TNotifierWindow;
    FStyle: TPreviewMenuStyle;
    procedure SetStyle(const Value: TPreviewMenuStyle);
  protected
    procedure ThemeChanged(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure SetComponentStyle(AStyle: TTMSStyle);
  published
    //property AutoThemeAdapt;
    property FrameAppearance;
    property LeftFrameColor;
    property RightFrameColor;
    property MenuItemAppearance;
    property ButtonAppearance;
    property Style: TPreviewMenuStyle read FStyle write SetStyle;
  end;

  TAdvPreviewMenuFantasyStyler = class(TAdvCustomPreviewMenuStyler)
  private
  protected
  public
    constructor Create(AOwner: TComponent); override;
  published
    property FrameAppearance;
    property LeftFrameColor;
    property RightFrameColor;
    property MenuItemAppearance;
    property ButtonAppearance;
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

constructor TAdvPreviewMenuOfficeStyler.Create(AOwner: TComponent);
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
end;

destructor TAdvPreviewMenuOfficeStyler.Destroy;
begin
  inherited;
end;

procedure TAdvPreviewMenuOfficeStyler.Loaded;
begin
  inherited;
  if not (csDesigning in ComponentState) then
    ThemeChanged(Self);
end;

procedure TAdvPreviewMenuOfficeStyler.ThemeChanged(Sender: TObject);
//var
  //eTheme: XPColorScheme;
begin
  //if not AutoThemeAdapt then
    //Exit;

end;


procedure TAdvPreviewMenuOfficeStyler.SetComponentStyle(AStyle: TTMSStyle);
begin
  Style := TPreviewMenuStyle(AStyle);
end;

{ TAdvPreviewMenuFantasyStyler }

constructor TAdvPreviewMenuFantasyStyler.Create(AOwner: TComponent);
begin
  inherited;
end;


procedure TAdvPreviewMenuOfficeStyler.SetStyle(
  const Value: TPreviewMenuStyle);
begin
  FStyle := Value;

  if not (FStyle in [psCustom]) then
  begin
        MenuItemAppearance.Color := clNone;
        MenuItemAppearance.ColorTo := clNone;
        MenuItemAppearance.ColorMirror := clNone;
        MenuItemAppearance.ColorMirrorTo := clNone;
        MenuItemAppearance.BorderColor := clNone;
        MenuItemAppearance.Gradient := ggVertical;
        MenuItemAppearance.GradientMirror := ggVertical;

        MenuItemAppearance.ColorDisabled := clNone;
        MenuItemAppearance.ColorDisabledTo := clNone;
        MenuItemAppearance.ColorMirrorDisabled := clNone;
        MenuItemAppearance.ColorMirrorDisabledTo := clNone;
        MenuItemAppearance.BorderColorDisabled := clNone;
        MenuItemAppearance.GradientDisabled := ggVertical;
        MenuItemAppearance.GradientMirrorDisabled := ggVertical;

        LeftFrameColor := clWhite;
        RightFrameColor := $00EEEAE9;

        FrameAppearance.Gradient := ggVertical;
        FrameAppearance.GradientMirror := ggVertical;
  end;

      if (FStyle in [psOffice2003Blue, psOffice2003Olive, psOffice2003Silver, psWhidbeyStyle]) then
    begin

      ButtonAppearance.ColorHot := $EBFDFF;
      ButtonAppearance.ColorHotTo := $ACECFF;
      ButtonAppearance.ColorMirrorHot := $59DAFF;
      ButtonAppearance.ColorMirrorHotTo := $A4E9FF;
      ButtonAppearance.BorderColorHot := $99CEDB;
      ButtonAppearance.GradientHot := ggVertical;
      ButtonAppearance.GradientMirrorHot := ggVertical;

      ButtonAppearance.ColorDown := $76AFF1;
      ButtonAppearance.ColorDownTo := $4190F3;
      ButtonAppearance.ColorMirrorDown := $0E72F1;
      ButtonAppearance.ColorMirrorDownTo := $4C9FFD;
      ButtonAppearance.BorderColorDown := $45667B;
      ButtonAppearance.GradientDown := ggVertical;
      ButtonAppearance.GradientMirrorDown := ggVertical;

      ButtonAppearance.ColorChecked := $B5DBFB;
      ButtonAppearance.ColorCheckedTo := $78C7FE;
      ButtonAppearance.ColorMirrorChecked := $9FEBFD;
      ButtonAppearance.ColorMirrorCheckedTo := $56B4FE;
      ButtonAppearance.GradientChecked := ggVertical;
      ButtonAppearance.GradientMirrorChecked := ggVertical;

      MenuItemAppearance.ColorHot := $C2EEFF;
      MenuItemAppearance.ColorHotTo := $C2EEFF;
      MenuItemAppearance.ColorMirrorHot := $C2EEFF;
      MenuItemAppearance.ColorMirrorHotTo := $C2EEFF;
      MenuItemAppearance.BorderColorHot := $385D3F;
      MenuItemAppearance.GradientHot := ggVertical;
      MenuItemAppearance.GradientMirrorHot := ggVertical;

      MenuItemAppearance.ColorDown := $3E80FE;
      MenuItemAppearance.ColorDownTo := $3E80FE;
      MenuItemAppearance.ColorMirrorDown := $3E80FE;
      MenuItemAppearance.ColorMirrorDownTo := $3E80FE;
      MenuItemAppearance.BorderColorDown := $385D3F;
      MenuItemAppearance.GradientDown := ggVertical;
      MenuItemAppearance.GradientMirrorDown := ggVertical;

      MenuItemAppearance.ColorChecked := $6FC0FF;
      MenuItemAppearance.ColorCheckedTo := $6FC0FF;
      MenuItemAppearance.ColorMirrorChecked := $6FC0FF;
      MenuItemAppearance.ColorMirrorCheckedTo := $6FC0FF;
      MenuItemAppearance.BorderColorChecked := $385D3F;
      MenuItemAppearance.GradientChecked := ggVertical;
      MenuItemAppearance.GradientMirrorChecked := ggVertical;

      MenuItemAppearance.TextColor := clBlack;
      MenuItemAppearance.TextColorHot := clBlack;
      MenuItemAppearance.TextColorDown := clBlack;

      MenuItemAppearance.SubItemTitleFont.Style := [fsBold];
    end;

     if (FStyle in [psOffice2007Luna, psOffice2007Obsidian, psOffice2007Silver]) then
    begin
        ButtonAppearance.ColorHot := $EBFDFF;
        ButtonAppearance.ColorHotTo := $ACECFF;
        ButtonAppearance.ColorMirrorHot := $59DAFF;
        ButtonAppearance.ColorMirrorHotTo := $A4E9FF;
        ButtonAppearance.BorderColorHot := $99CEDB;
        ButtonAppearance.GradientHot := ggVertical;
        ButtonAppearance.GradientMirrorHot := ggVertical;

        ButtonAppearance.ColorDown := $76AFF1;
        ButtonAppearance.ColorDownTo := $4190F3;
        ButtonAppearance.ColorMirrorDown := $0E72F1;
        ButtonAppearance.ColorMirrorDownTo := $4C9FFD;
        ButtonAppearance.BorderColorDown := $45667B;
        ButtonAppearance.GradientDown := ggVertical;
        ButtonAppearance.GradientMirrorDown := ggVertical;

        ButtonAppearance.ColorChecked := $B5DBFB;
        ButtonAppearance.ColorCheckedTo := $78C7FE;
        ButtonAppearance.ColorMirrorChecked := $9FEBFD;
        ButtonAppearance.ColorMirrorCheckedTo := $56B4FE;
        ButtonAppearance.BorderColorChecked := $45667B;
        ButtonAppearance.GradientChecked := ggVertical;
        ButtonAppearance.GradientMirrorChecked := ggVertical;

        MenuItemAppearance.ColorHot := $EBFDFF;
        MenuItemAppearance.ColorHotTo := $ACECFF;
        MenuItemAppearance.ColorMirrorHot := $59DAFF;
        MenuItemAppearance.ColorMirrorHotTo := $A4E9FF;
        MenuItemAppearance.BorderColorHot := $99CEDB;
        MenuItemAppearance.GradientHot := ggVertical;
        MenuItemAppearance.GradientMirrorHot := ggVertical;

        MenuItemAppearance.ColorDown := $76AFF1;
        MenuItemAppearance.ColorDownTo := $4190F3;
        MenuItemAppearance.ColorMirrorDown := $0E72F1;
        MenuItemAppearance.ColorMirrorDownTo := $4C9FFD;
        MenuItemAppearance.BorderColorDown := $45667B;
        MenuItemAppearance.GradientDown := ggVertical;
        MenuItemAppearance.GradientMirrorDown := ggVertical;

        MenuItemAppearance.ColorChecked := $B5DBFB;
        MenuItemAppearance.ColorCheckedTo := $78C7FE;
        MenuItemAppearance.ColorMirrorChecked := $9FEBFD;
        MenuItemAppearance.ColorMirrorCheckedTo := $56B4FE;
        MenuItemAppearance.BorderColorChecked := $45667B;
        MenuItemAppearance.GradientChecked := ggVertical;
        MenuItemAppearance.GradientMirrorChecked := ggVertical;
        MenuItemAppearance.SubItemTitleFont.Style := [fsBold];
    end;

  case FStyle of
  psOffice2003Blue:
    begin

        ButtonAppearance.Color := $EEDBC8;
        ButtonAppearance.ColorTo := $F6DDC9;
        ButtonAppearance.ColorMirror := $EDD4C0;
        ButtonAppearance.ColorMirrorTo := $F7E1D0;
        ButtonAppearance.BorderColor := $E0B99B;
        ButtonAppearance.Gradient := ggVertical;
        ButtonAppearance.GradientMirror := ggVertical;

        FrameAppearance.BorderColor := $385D3F;
        FrameAppearance.Color := $E7B38F;
        FrameAppearance.ColorMirror := $E7B38F;
        FrameAppearance.ColorMirrorTo := $F6F6F6;
        FrameAppearance.ColorTo := $E7B38F;

        RightFrameColor := $FDE9DB;

    end;
  psOffice2003Olive:
    begin

        ButtonAppearance.Color := $CFF0EA;
        ButtonAppearance.ColorTo := $CFF0EA;
        ButtonAppearance.ColorMirror := $CFF0EA;
        ButtonAppearance.ColorMirrorTo := $8CC0B1;
        ButtonAppearance.BorderColor := $8CC0B1;
        ButtonAppearance.Gradient := ggVertical;
        ButtonAppearance.GradientMirror := ggVertical;

        FrameAppearance.BorderColor := $5E8D75;
        FrameAppearance.Color := $9ACCBE;
        FrameAppearance.ColorMirror := $9ACCBE;
        FrameAppearance.ColorMirrorTo := $EDFFFF;
        FrameAppearance.ColorTo := $9ACCBE;

        RightFrameColor := $D0EDE8;

    end;

  psOffice2007Luna:
    begin
        ButtonAppearance.Color := $EEDBC8;
        ButtonAppearance.ColorTo := $F6DDC9;
        ButtonAppearance.ColorMirror := $EDD4C0;
        ButtonAppearance.ColorMirrorTo := $F7E1D0;
        ButtonAppearance.BorderColor := $E0B99B;
        ButtonAppearance.Gradient := ggVertical;
        ButtonAppearance.GradientMirror := ggVertical;

        MenuItemAppearance.TextColor := $6E1500;
        MenuItemAppearance.TextColorHot := $6E1500;
        MenuItemAppearance.TextColorDown := $6E1500;

        FrameAppearance.BorderColor := $00C9AF9C;
        FrameAppearance.Color := $00F5E1D1;
        FrameAppearance.ColorMirror := $00F5E1D1;
        FrameAppearance.ColorMirrorTo := $00E7CDB8;
        FrameAppearance.ColorTo := $00E7CDB8;

    end;

  psOffice2007Obsidian:
    begin
        ButtonAppearance.Color := HTMLToRgb($D6DEDF);
        ButtonAppearance.ColorTo := HTMLToRgb($DBE2E4);
        ButtonAppearance.ColorMirror := HTMLToRgb($CED5D7);
        ButtonAppearance.ColorMirrorTo := HTMLToRgb($E0E5E7);
        ButtonAppearance.BorderColor := HTMLToRgb($B2BCC0);
        ButtonAppearance.Gradient := ggVertical;
        ButtonAppearance.GradientMirror := ggVertical;

        MenuItemAppearance.TextColor := $464646;
        MenuItemAppearance.TextColorHot := $464646;
        MenuItemAppearance.TextColorDown := $464646;

        FrameAppearance.BorderColor := $676768;
        FrameAppearance.Color := $524643;
        FrameAppearance.ColorMirror := $3D3D3D;
        FrameAppearance.ColorMirrorTo := $2F2F2F;
        FrameAppearance.ColorTo := $4A403C;
    end;

  psOffice2007Silver:
    begin
        ButtonAppearance.Color := $F5F0EB;
        ButtonAppearance.ColorTo := $F5F0EC;
        ButtonAppearance.ColorMirror := $F9F4F0;
        ButtonAppearance.ColorMirrorTo := $DBD2CB;
        ButtonAppearance.BorderColor := $9D948D;
        ButtonAppearance.Gradient := ggVertical;
        ButtonAppearance.GradientMirror := ggVertical;

        MenuItemAppearance.TextColor := $464646;
        MenuItemAppearance.TextColorHot := $464646;
        MenuItemAppearance.TextColorDown := $464646;

        FrameAppearance.BorderColor := $B4AEA9;
        FrameAppearance.Color := $D7D0CA;
        FrameAppearance.ColorMirror := $E6E2D9;
        FrameAppearance.ColorMirrorTo := $D0C9C3;
        FrameAppearance.ColorTo := $D8D1CC;
    end;

  psOffice2003Silver:
    begin
        ButtonAppearance.Color := $EDD4C0;
        ButtonAppearance.ColorTo := $00E6D8D8;
        ButtonAppearance.ColorMirror := $EDD4C0;
        ButtonAppearance.ColorMirrorTo := $C8B2B3;
        ButtonAppearance.BorderColor := $927476;
        ButtonAppearance.Gradient := ggVertical;
        ButtonAppearance.GradientMirror := ggVertical;

        FrameAppearance.BorderColor := $947C7C;
        FrameAppearance.Color := $C2A9AB;
        FrameAppearance.ColorMirror := $C2A9AB;
        FrameAppearance.ColorMirrorTo := $FFF9F9;
        FrameAppearance.ColorTo := $C2A9AB;

        RightFrameColor := $EEE4E4;

    end;

  psOfficeXP:
    begin
        ButtonAppearance.Color := clWhite;
        ButtonAppearance.ColorTo := $C9D1D5;
        ButtonAppearance.ColorMirror := clWhite;
        ButtonAppearance.ColorMirrorTo := $C9D1D5;
        ButtonAppearance.BorderColor := clBlack;
        ButtonAppearance.Gradient := ggVertical;
        ButtonAppearance.GradientMirror := ggVertical;

        ButtonAppearance.ColorHot := $EBFDFF;
        ButtonAppearance.ColorHotTo := $ACECFF;
        ButtonAppearance.ColorMirrorHot := $59DAFF;
        ButtonAppearance.ColorMirrorHotTo := $A4E9FF;
        ButtonAppearance.BorderColorHot := $99CEDB;
        ButtonAppearance.GradientHot := ggVertical;
        ButtonAppearance.GradientMirrorHot := ggVertical;

        ButtonAppearance.ColorDown := $76AFF1;
        ButtonAppearance.ColorDownTo := $4190F3;
        ButtonAppearance.ColorMirrorDown := $0E72F1;
        ButtonAppearance.ColorMirrorDownTo := $4C9FFD;
        ButtonAppearance.BorderColorDown := $45667B;
        ButtonAppearance.GradientDown := ggVertical;
        ButtonAppearance.GradientMirrorDown := ggVertical;

        ButtonAppearance.ColorChecked := $B5DBFB;
        ButtonAppearance.ColorCheckedTo := $78C7FE;
        ButtonAppearance.ColorMirrorChecked := $9FEBFD;
        ButtonAppearance.ColorMirrorCheckedTo := $56B4FE;
        ButtonAppearance.GradientChecked := ggVertical;
        ButtonAppearance.GradientMirrorChecked := ggVertical;

        MenuItemAppearance.ColorHot := $EFD3C6;
        MenuItemAppearance.ColorHotTo := $EFD3C6;
        MenuItemAppearance.ColorMirrorHot := $EFD3C6;
        MenuItemAppearance.ColorMirrorHotTo := $EFD3C6;
        MenuItemAppearance.BorderColorHot := clHighlight;
        MenuItemAppearance.GradientHot := ggVertical;
        MenuItemAppearance.GradientMirrorHot := ggVertical;

        MenuItemAppearance.ColorDown := $EFD3C6;
        MenuItemAppearance.ColorDownTo := $EFD3C6;
        MenuItemAppearance.ColorMirrorDown := $EFD3C6;
        MenuItemAppearance.ColorMirrorDownTo := $EFD3C6;
        MenuItemAppearance.BorderColorDown := clHighlight;
        MenuItemAppearance.GradientDown := ggVertical;
        MenuItemAppearance.GradientMirrorDown := ggVertical;

        MenuItemAppearance.ColorChecked := clHighlight;
        MenuItemAppearance.ColorCheckedTo := clHighlight;
        MenuItemAppearance.ColorMirrorChecked := clHighlight;
        MenuItemAppearance.ColorMirrorCheckedTo := clHighlight;
        MenuItemAppearance.BorderColorChecked := clHighlight;
        MenuItemAppearance.GradientChecked := ggVertical;
        MenuItemAppearance.GradientMirrorChecked := ggVertical;

        FrameAppearance.BorderColor := $7A868A;
        FrameAppearance.Color := clBtnFace;
        FrameAppearance.ColorMirror := clBtnFace;
        FrameAppearance.ColorMirrorTo := clBtnFace;
        FrameAppearance.ColorTo := clBtnFace;

        RightFrameColor := clBtnFace;        

        MenuItemAppearance.TextColor := clBlack;
        MenuItemAppearance.TextColorHot := clBlack;
        MenuItemAppearance.TextColorDown := clBlack;

    end;

  psWindowsXP, psOffice2003Classic:
    begin
        ButtonAppearance.Color := clWhite;
        ButtonAppearance.ColorTo := HTMLToRgb($DCD8B9);
        ButtonAppearance.ColorMirror := HTMLToRgb($DCD8B9);
        ButtonAppearance.ColorMirrorTo := HTMLToRgb($DCD8B9);
        ButtonAppearance.BorderColor := HTMLToRgb($DCD8B9);
        ButtonAppearance.Gradient := ggVertical;
        ButtonAppearance.GradientMirror := ggVertical;

        ButtonAppearance.ColorHot := $EFD3C6;
        ButtonAppearance.ColorHotTo := $EFD3C6;
        ButtonAppearance.ColorMirrorHot := $EFD3C6;
        ButtonAppearance.ColorMirrorHotTo := $EFD3C6;
        ButtonAppearance.BorderColorHot := clHighlight;
        ButtonAppearance.GradientHot := ggVertical;
        ButtonAppearance.GradientMirrorHot := ggVertical;

        ButtonAppearance.ColorDown := $B59284;
        ButtonAppearance.ColorDownTo := $B59284;
        ButtonAppearance.ColorMirrorDown := $B59284;
        ButtonAppearance.ColorMirrorDownTo := $B59284;
        ButtonAppearance.BorderColorDown := clHighlight;
        ButtonAppearance.GradientDown := ggVertical;
        ButtonAppearance.GradientMirrorDown := ggVertical;

        ButtonAppearance.ColorChecked := HTMLToRgb($DCD8B9);
        ButtonAppearance.ColorCheckedTo := HTMLToRgb($DCD8B9);
        ButtonAppearance.ColorMirrorChecked := HTMLToRgb($DCD8B9);
        ButtonAppearance.ColorMirrorCheckedTo := HTMLToRgb($DCD8B9);
        ButtonAppearance.BorderColorChecked := clBlack;
        ButtonAppearance.GradientChecked := ggVertical;
        ButtonAppearance.GradientMirrorChecked := ggVertical;

        MenuItemAppearance.ColorHot := $C56A31;
        MenuItemAppearance.ColorHotTo := $C56A31;
        MenuItemAppearance.ColorMirrorHot := $C56A31;
        MenuItemAppearance.ColorMirrorHotTo := $C56A31;
        MenuItemAppearance.BorderColorHot := clNone;
        MenuItemAppearance.GradientHot := ggVertical;
        MenuItemAppearance.GradientMirrorHot := ggVertical;

        MenuItemAppearance.ColorDown := $C56A31;
        MenuItemAppearance.ColorDownTo := $C56A31;
        MenuItemAppearance.ColorMirrorDown := $C56A31;
        MenuItemAppearance.ColorMirrorDownTo := $C56A31;
        MenuItemAppearance.BorderColorDown := clNone;
        MenuItemAppearance.GradientDown := ggVertical;
        MenuItemAppearance.GradientMirrorDown := ggVertical;

        MenuItemAppearance.ColorChecked := clNone;
        MenuItemAppearance.ColorCheckedTo := clNone;
        MenuItemAppearance.ColorMirrorChecked := clNone;
        MenuItemAppearance.ColorMirrorCheckedTo := clNone;
        MenuItemAppearance.BorderColorChecked := clNone;
        MenuItemAppearance.GradientChecked := ggVertical;
        MenuItemAppearance.GradientMirrorChecked := ggVertical;

        FrameAppearance.BorderColor := $C55C22;
        FrameAppearance.Color := $EC9247;
        FrameAppearance.ColorMirror := $CE6616;
        FrameAppearance.ColorMirrorTo := $CE6616;
        FrameAppearance.ColorTo := $CE6616;

        RightFrameColor := $FAE5D3;

        MenuItemAppearance.TextColor := clBlack;
        MenuItemAppearance.TextColorHot := clWhite;
        MenuItemAppearance.TextColorDown := clWhite;

    end;

  psWhidbeyStyle:
    begin
        ButtonAppearance.Color := clWhite;
        ButtonAppearance.ColorTo := $DFEDF0;
        ButtonAppearance.ColorMirror := $DFEDF0;
        ButtonAppearance.ColorMirrorTo := $DFEDF0;
        ButtonAppearance.BorderColor := $99A8AC;
        ButtonAppearance.Gradient := ggVertical;
        ButtonAppearance.GradientMirror := ggVertical;

        FrameAppearance.BorderColor := $99A8AC;
        FrameAppearance.Color := $A8C0C1;
        FrameAppearance.ColorMirror := $A8C0C1;
        FrameAppearance.ColorMirrorTo := $DFEDF0;//$FBFEFE;
        FrameAppearance.ColorTo := $A8C0C1;

        RightFrameColor := $DFEDF0;

    end;



  end;
end;

end.
