// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Prsscom.pas' rev: 11.00

#ifndef PrsscomHPP
#define PrsscomHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Pcommon2d.hpp>	// Pascal unit
#include <Pcore2d.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Prsscom
{
//-- type declarations -------------------------------------------------------
#pragma pack(push,4)
struct TDataSubset
{
	
public:
	int Value;
	int Modules;
	int MaxWidth;
} ;
#pragma pack(pop)

#pragma pack(push,4)
struct TCodeWord
{
	
public:
	unsigned Data;
	TDataSubset Subset_Odd;
	TDataSubset Subset_Even;
	AnsiString Widths_Odd;
	AnsiString Widths_Even;
	AnsiString Patterns;
} ;
#pragma pack(pop)

#pragma pack(push,4)
struct TCharData
{
	
public:
	unsigned MinValue;
	unsigned MaxValue;
	Byte OddModules;
	Byte EvenModules;
	Byte OddWidest;
	Byte EvenWidest;
	Word Total;
} ;
#pragma pack(pop)

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE AnsiString __fastcall Reverse(AnsiString A);
extern PACKAGE char __fastcall UCCEAN_Check(AnsiString ABarcode);
extern PACKAGE AnsiString __fastcall GetRssWidths(const TDataSubset &DataSubset, Byte Elements, bool NoNarrow);
extern PACKAGE void __fastcall GetRssSubset(TCharData * CharData_Table, const int CharData_Table_Size, unsigned Data, TDataSubset &Odd, TDataSubset &Even);
extern PACKAGE void __fastcall DrawRssLine(Pcore2d::PCoreWorkArea PWorkArea, int ATop, int AHeight, Word &ALeft, Byte AWidth, bool AValue);
extern PACKAGE void __fastcall DrawSeparator(Pcore2d::PCoreWorkArea PWorkArea, int ATop, int AHeight, int AWidth, System::PByte PRefCols, int RefLen, bool BarStart = false, int ALeft = 0x0);

}	/* namespace Prsscom */
using namespace Prsscom;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Prsscom
