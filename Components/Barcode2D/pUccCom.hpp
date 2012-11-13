// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pucccom.pas' rev: 11.00

#ifndef PucccomHPP
#define PucccomHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Math.hpp>	// Pascal unit
#include <Pcommon2d.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pucccom
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TUCC_EncodeMode { uemNumeric, uemAlphanumeric, uemIsoIec646, uemAlpha, uemFixed };
#pragma option pop

typedef Set<char, 0, 255>  TUCC_Charset;

typedef DynamicArray<int >  TUCC_CapacityList;

//-- var, const, procedure ---------------------------------------------------
#define UCC_Charset_Numeric (Set<char, 0, 255> () << '\x30' << '\x31' << '\x32' << '\x33' << '\x34' << '\x35' << '\x36' << '\x37' << '\x38' << '\x39' << '\x5e' )
#define UCC_Charset_Alphanumeric (Set<char, 0, 255> () << '\x2a' << '\x2c' << '\x2d' << '\x2e' << '\x2f' << '\x30' << '\x31' << '\x32' << '\x33' << '\x34' << '\x35' << '\x36' << '\x37' << '\x38' << '\x39' << '\x41' << '\x42' << '\x43' << '\x44' << '\x45' << '\x46' << '\x47' << '\x48' << '\x49' << '\x4a' << '\x4b' << '\x4c' << '\x4d' << '\x4e' << '\x4f' << '\x50' << '\x51' << '\x52' << '\x53' << '\x54' << '\x55' << '\x56' << '\x57' << '\x58' << '\x59' << '\x5a' << '\x5e' )
#define UCC_Charset_IsoIec646 (Set<char, 0, 255> () << '\x20' << '\x21' << '\x22' << '\x25' << '\x26' << '\x27' << '\x28' << '\x29' << '\x2a' << '\x2b' << '\x2c' << '\x2d' << '\x2e' << '\x2f' << '\x30' << '\x31' << '\x32' << '\x33' << '\x34' << '\x35' << '\x36' << '\x37' << '\x38' << '\x39' << '\x3a' << '\x3b' << '\x3c' << '\x3d' << '\x3e' << '\x3f' << '\x41' << '\x42' << '\x43' << '\x44' << '\x45' << '\x46' << '\x47' << '\x48' << '\x49' << '\x4a' << '\x4b' << '\x4c' << '\x4d' << '\x4e' << '\x4f' << '\x50' << '\x51' << '\x52' << '\x53' << '\x54' << '\x55' << '\x56' << '\x57' << '\x58' << '\x59' << '\x5a' << '\x5e' << '\x5f' << '\x61' << '\x62' << '\x63' << '\x64' << '\x65' << '\x66' << '\x67' << '\x68' << '\x69' << '\x6a' << '\x6b' << '\x6c' << '\x6d' << '\x6e' << '\x6f' << '\x70' << '\x71' << '\x72' << '\x73' << '\x74' << '\x75' << '\x76' << '\x77' << '\x78' << '\x79' << '\x7a' )
extern PACKAGE bool __fastcall EncodeValue(PDWORD AEncoded, int &AIndex, int &ATotalBits, unsigned AValue, Byte ABits, int AMaxBits = 0xfc);
extern PACKAGE AnsiString __fastcall Translate(AnsiString ABarcode);
extern PACKAGE bool __fastcall Verify_Is_Numeric(AnsiString AData, int AIndexOffset, int &AInvalidIndex, int ALength = 0x0);
extern PACKAGE bool __fastcall Verify_Is_Date(AnsiString AData, int AIndexOffset, int &AInvalidIndex);
extern PACKAGE int __fastcall AppropriateSizeBits(int ATotalBits, int AMinBits, TUCC_CapacityList ACapacityList);
extern PACKAGE void __fastcall EncodeGenerialPurposeField(AnsiString ABarcode, int AMinimumBits, PDWORD AEncoded, TUCC_EncodeMode &ALastMode, int &ASrcIndex, int &ADstIndex, int &ATotalBits, int &APadBits, int &AInvalidIndex, int AMaximumBits, TUCC_CapacityList ACapacityList, TUCC_EncodeMode CurMode = (TUCC_EncodeMode)(0x0));

}	/* namespace Pucccom */
using namespace Pucccom;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pucccom
