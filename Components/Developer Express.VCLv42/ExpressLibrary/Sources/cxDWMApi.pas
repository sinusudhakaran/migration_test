{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           Express Cross Platform Library classes                   }
{                                                                    }
{           Copyright (c) 2000-2009 Developer Express Inc.           }
{           ALL RIGHTS RESERVED                                      }
{                                                                    }
{   The entire contents of this file is protected by U.S. and        }
{   International Copyright Laws. Unauthorized reproduction,         }
{   reverse-engineering, and distribution of all or any portion of   }
{   the code contained in this file is strictly prohibited and may   }
{   result in severe civil and criminal penalties and will be        }
{   prosecuted to the maximum extent possible under the law.         }
{                                                                    }
{   RESTRICTIONS                                                     }
{                                                                    }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES            }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE     }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS    }
{   LICENSED TO DISTRIBUTE THE EXPRESSCROSSPLATFORMLIBRARY AND ALL   }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM       }
{   ONLY.                                                            }
{                                                                    }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED       }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE         }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE        }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT   }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                       }
{                                                                    }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON        }
{   ADDITIONAL RESTRICTIONS.                                         }
{                                                                    }
{********************************************************************}

unit cxDWMApi;

{$I cxVer.inc}

interface

uses
  Windows, dxUxTheme;

const
{$IFDEF CBUILDER11}
  {$EXTERNALSYM WM_DWMCOMPOSITIONCHANGED}
{$ENDIF}
  WM_DWMCOMPOSITIONCHANGED       = $0031E;
{$IFDEF CBUILDER11}
  {$EXTERNALSYM WM_DWMNCRENDERINGCHANGED}
{$ENDIF}
  WM_DWMNCRENDERINGCHANGED       = $0031F;
{$IFDEF CBUILDER11}
  {$EXTERNALSYM WM_DWMCOLORIZATIONCOLORCHANGED}
{$ENDIF}
  WM_DWMCOLORIZATIONCOLORCHANGED = $00320;
{$IFDEF CBUILDER11}
  {$EXTERNALSYM WM_DWMWINDOWMAXIMIZEDCHANGE}
{$ENDIF}
  WM_DWMWINDOWMAXIMIZEDCHANGE    = $00321;

  DWM_EC_DISABLECOMPOSITION      = 0;
  DWM_EC_ENABLECOMPOSITION       = 1;

  // Blur behind data structures
  DWM_BB_ENABLE                  = $00000001; // fEnable has been specified
  DWM_BB_BLURREGION              = $00000002; // hRgnBlur has been specified}
  DWM_BB_TRANSITIONONMAXIMIZED   = $00000004; // fTransitionOnMaximized has been specified

  // Window attributes
  DWMWA_NCRENDERING_ENABLED         = 1; // [get] Is non-client rendering enabled/disabled
  DWMWA_NCRENDERING_POLICY          = 2; // [set] Non-client rendering policy
  DWMWA_TRANSITIONS_FORCEDISABLED   = 3; // [set] Potentially enable/forcibly disable transitions
  DWMWA_ALLOW_NCPAINT               = 4; // [set] Allow contents rendered in the non-client area to be visible on the DWM-drawn frame.
  DWMWA_CAPTION_BUTTON_BOUNDS       = 5; // [get] Bounds of the caption button area in window-relative space.
  DWMWA_NONCLIENT_RTL_LAYOUT        = 6; // [set] Is non-client content RTL mirrored
  DWMWA_FORCE_ICONIC_REPRESENTATION = 7; // [set] Force this window to display iconic thumbnails.
  DWMWA_FLIP3D_POLICY               = 8; // [set] Designates how Flip3D will treat the window.
  DWMWA_EXTENDED_FRAME_BOUNDS       = 9; // [get] Gets the extended frame bounds rectangle in screen space
  DWMWA_LAST                        = 10;

type
  _DWM_BLURBEHIND = packed record
    dwFlags: DWORD;
    fEnable: Bool;
    hRgnBlur: HRGN;
    fTransitionOnMaximized: Bool;
  end;
  DWM_BLURBEHIND = _DWM_BLURBEHIND;
  PDWM_BLURBEHIND = ^_DWM_BLURBEHIND;

  // Non-client rendering policy attribute values
  TDWMNCRENDERINGPOLICY = (
    DWMNCRP_USEWINDOWSTYLE, // Enable/disable non-client rendering based on window style
    DWMNCRP_DISABLED,       // Disabled non-client rendering; window style is ignored
    DWMNCRP_ENABLED,        // Enabled non-client rendering; window style is ignored
    DWMNCRP_LAST);

var
  DwmDefWindowProc: function (wnd: HWND; msg: UINT; wParam: WPARAM;
    lParam: LPARAM; plResult: LRESULT): HRESULT; stdcall;
  DwmEnableBlurBehindWindow: function (wnd: HWND;
    pBlurBehind: PDWM_BLURBEHIND): HRESULT; stdcall;
  DwmEnableComposition: function (uCompositionAction: Boolean): HRESULT; stdcall;
  DwmEnableMMCSS: function (fEnableMMCSS: Boolean): HRESULT; stdcall;
  DwmExtendFrameIntoClientArea: function (wnd: HWND;
    pMarInset: PdxMargins): HRESULT; stdcall;
  DwmGetColorizationColor: function (out pcrColorization: DWORD;
    out pfOpaqueBlend: BOOL): HRESULT; stdcall;
  DwmGetWindowAttribute: function(hwnd: HWND; dwAttribute: DWORD;
    pvAttribute: Pointer; cbAttribute: DWORD): HRESULT; stdcall;
  DwmIsCompositionEnabled: function(out pfEnabled: BOOL): HRESULT; stdcall;
  DwmSetWindowAttribute: function(hwnd: HWND; dwAttribute: DWORD;
    pvAttribute: Pointer; cbAttribute: DWORD): HRESULT; stdcall;

function IsDwmPresent: Boolean;
function IsCompositionEnabled: Boolean;

implementation

uses
  SysUtils;

var
  dwmapiDLL: THandle;
  dwmPresent: Boolean;

function IsDwmPresent: Boolean;
begin
  Result := dwmPresent;
end;

function IsCompositionEnabled: Boolean;
var
  B: BOOL;
begin
  Result := IsDwmPresent;
  if Result then
  begin
    DwmIsCompositionEnabled(B);
    Result := B;
  end;
end;

function InitDWM: Boolean;
begin
  Result := False;
  if Win32MajorVersion < 6 then Exit;
  dwmapiDLL := LoadLibrary('dwmapi.dll');
  if dwmapiDLL <> 0 then
  begin
    DwmDefWindowProc := GetProcAddress(dwmapiDLL, 'DwmDefWindowProc');
    DwmEnableBlurBehindWindow := GetProcAddress(dwmapiDLL, 'DwmEnableBlurBehindWindow');
    DwmEnableComposition := GetProcAddress(dwmapiDLL, 'DwmEnableComposition');
    DwmEnableMMCSS := GetProcAddress(dwmapiDLL, 'DwmEnableMMCSS');
    DwmExtendFrameIntoClientArea := GetProcAddress(dwmapiDLL, 'DwmExtendFrameIntoClientArea');
    DwmGetColorizationColor := GetProcAddress(dwmapiDLL, 'DwmGetColorizationColor');
    DwmGetWindowAttribute := GetProcAddress(dwmapiDLL, 'DwmGetWindowAttribute');
    DwmIsCompositionEnabled := GetProcAddress(dwmapiDLL, 'DwmIsCompositionEnabled');
    DwmSetWindowAttribute := GetProcAddress(dwmapiDLL, 'DwmSetWindowAttribute');
    Result := True;
  end;
end;

initialization
  dwmPresent := InitDWM;

finalization
  if dwmapiDLL <> 0 then
    FreeLibrary(dwmapiDLL);

end.
