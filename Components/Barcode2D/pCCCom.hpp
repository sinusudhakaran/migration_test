// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pcccom.pas' rev: 11.00

#ifndef PcccomHPP
#define PcccomHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Math.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Pucccom.hpp>	// Pascal unit
#include <Pcommon2d.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pcccom
{
//-- type declarations -------------------------------------------------------
#pragma pack(push,1)
struct TLinearPrintParameters
{
	
public:
	double Height;
} ;
#pragma pack(pop)

typedef TLinearPrintParameters *PLinearPrintParameters;

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall SplitData(PDWORD PSrcData, PWORD PDstData, int SrcCount, int BitLen, int &DstCount);
extern PACKAGE bool __fastcall EncodeData(AnsiString ABarcode, PDWORD AEncoded, Pucccom::TUCC_EncodeMode &ALastMode, int &ADstIndex, int &ATotalBits, int &AInvalidIndex, int AMinBits, int AMaxBits, Pucccom::TUCC_CapacityList ACapacityList);
extern PACKAGE void __fastcall EncodeByte(PWORD Source, PWORD Target, int Count);
extern PACKAGE int __fastcall PixelsToModules(int APixels, int AModule);
extern PACKAGE void __fastcall SetLinearOnChange(Classes::TComponent* ALinear, const Classes::TNotifyEvent AClear, const Classes::TNotifyEvent AChange);
extern PACKAGE int __fastcall GetLinearSymbolWidth(Classes::TComponent* ALinear, Graphics::TCanvas* ACanvas, int AModule, int &AWidth, int &ASymbolLeftZone, int &ASymbolRightZone);
extern PACKAGE int __fastcall DrawLinear(Classes::TComponent* ALinear, int ATotalWidth, int ATotalHeight, int ATotalLeft, int ATotalTop, int ALinearLeft, int ALinearTop, int AModule, int AAngle, Graphics::TCanvas* ACanvas, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AIsPrint, double APrintDensityRate, int AHeight);

}	/* namespace Pcccom */
using namespace Pcccom;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pcccom
