// Case 6388
// msimg32.dll for Windows 95
// just dummy methods that return true!
// ******************************
// MUST COMPILE WITH DELPHI 7!!!!
// ******************************
library msimg32;
{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows;

function DllInitialize (param:DWORD):DWORD; stdcall;
begin
  // Do nothing;
  Result:=0;
end;

procedure vSetDdrawflag; stdcall;
begin
  // Do nothing;
end;

function AlphaBlend(DC: HDC; p2, p3, p4, p5: Integer; DC6: HDC; p7, p8, p9, p10: Integer; p11: TBlendFunction): BOOL; stdcall; export;
begin
  // Do nothing
  Result:=TRUE;
end;

function AlphaDIBBlend(DC: HDC; p2, p3, p4, p5: Integer; const p6: Pointer;
        const p7: PBitmapInfo; p8: UINT; p9, p10, p11, p12: Integer; p13: TBlendFunction): BOOL; stdcall; export;
begin
  // Do nothing
  Result:=TRUE;
end;

function TransparentBlt(DC: HDC; p2, p3, p4, p5: Integer; DC6: HDC; p7, p8, p9, p10: Integer; p11: UINT): BOOL; stdcall; export;
begin
  // Do nothing
  Result:=TRUE;
end;

function GradientFill(DC: HDC; Vertex: PTriVertex; NumVertex: ULONG; Mesh: Pointer; NumMesh, Mode: ULONG): BOOL; stdcall; export;
begin
  // Do nothing
  Result:=TRUE;
end;

exports
  vSetDdrawflag index 1, AlphaBlend index 2, DllInitialize index 3, GradientFill index 4, TransparentBlt index 5;

begin
end.

