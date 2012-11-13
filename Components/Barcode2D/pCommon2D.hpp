// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pcommon2d.pas' rev: 11.00

#ifndef Pcommon2dHPP
#define Pcommon2dHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Math.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Printers.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pcommon2d
{
//-- type declarations -------------------------------------------------------
typedef DynamicArray<Byte >  TBytesArray;

typedef DynamicArray<Word >  TWordsArray;

typedef DynamicArray<unsigned >  TDWordsArray;

typedef Set<char, 0, 255>  TEscapeChars;

typedef Set<char, 0, 255>  TChars;

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TEscapeChars EMPTYSET;
extern PACKAGE double __fastcall Deg2Rad(int Degree);
extern PACKAGE Types::TPoint __fastcall Rotate2D(const Types::TPoint &P, double Alpha, double DensityRate = 1.000000E+00);
extern PACKAGE Types::TPoint __fastcall Translate2D(const Types::TPoint &A, const Types::TPoint &B);
extern PACKAGE void __fastcall RotateRect2D(int &AWidth, int &AHeight, double Alpha = 0.000000E+00, double DensityRate = 1.000000E+00);
extern PACKAGE Types::TPoint __fastcall TranslateQuad2D(double Alpha, const Types::TPoint &Orgin, const Types::TPoint &Point, double DensityRate = 1.000000E+00);
extern PACKAGE void __fastcall DrawRect(Graphics::TCanvas* Canvas, const Types::TRect &Rect, Graphics::TColor Color, const Types::TPoint &Orgin, double Alpha, double DensityRate = 1.000000E+00);
extern PACKAGE void __fastcall ClearRegion(Graphics::TCanvas* Canvas, const Types::TRect &Rect, Graphics::TColor Color);
extern PACKAGE double __fastcall GetPrinterDensityRate(int HDPI = 0x0, int VDPI = 0x0);
extern PACKAGE int __fastcall ConvertMMtoPixelsX(const double Value, int HDPI = 0x0);
extern PACKAGE int __fastcall ConvertMMtoPixelsY(const double Value, int VDPI = 0x0);
extern PACKAGE double __fastcall ConvertPixelsXtoMM(const int Value, int HDPI = 0x0);
extern PACKAGE double __fastcall ConvertPixelsYtoMM(const int Value, int VDPI = 0x0);
extern PACKAGE bool __fastcall CharInSet(char Ch, const TChars &ChSet);
extern PACKAGE int __fastcall StrToDec(AnsiString Str, int MinValue, int MaxValue, int &InvalidIndex);
extern PACKAGE AnsiString __fastcall GetParameter(AnsiString ABarcode, int ABarcodeLen, int &AIndex, const TEscapeChars &AParametersEscape = EMPTYSET, char ALeftDelimiter = '\x5b', char ARightDelimiter = '\x5d');
extern PACKAGE AnsiString __fastcall GetParameterItem(AnsiString &AParameter, bool ATrim);
extern PACKAGE Word __fastcall CRC16(AnsiString Data);

}	/* namespace Pcommon2d */
using namespace Pcommon2d;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pcommon2d
