// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pqrcodecom.pas' rev: 11.00

#ifndef PqrcodecomHPP
#define PqrcodecomHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Pcore2d.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pqrcodecom
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TQRCode_EncodePolicy { epMixingOptimal, epMixingQuick, epSingleMode };
#pragma option pop

#pragma option push -b-
enum TQRCode_EncodeMode { emNull, emNumeric, emAlphanumeric, emByte, emKanji, emECI, emStructAppend, emFNC1A, emFNC1B };
#pragma option pop

#pragma pack(push,4)
struct TEncodeStatistic
{
	
public:
	int BitsNumber;
	int DataNumber;
} ;
#pragma pack(pop)

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Byte EncodeModeIndicator_Data[8];
extern PACKAGE Byte CharsCountIndicator_Bits[4][44];
extern PACKAGE Byte NumericRemainBits[3];
extern PACKAGE Set<char, 0, 255>  ExclusiveCharset[4];
extern PACKAGE Word BCH_10_1335[32];
extern PACKAGE void __fastcall GetEncodeHeaderParameters(int AVersion, TQRCode_EncodeMode AEncodeMode, int AEncodeNumber, Byte &EncodeModeIndicatorBits, Byte &CharsCountIndicatorBits, Word &EncodeModeIndicatorData, Word &CharsCountIndicatorData);
extern PACKAGE void __fastcall EncodeNumeric(AnsiString ABarcode, int AIndex, int ACount, PDWORD &PData);
extern PACKAGE void __fastcall EncodeAlphanumeric(AnsiString ABarcode, int AIndex, int ACount, PDWORD &PData);
extern PACKAGE void __fastcall EncodeByte(AnsiString ABarcode, int AIndex, int ACount, PDWORD &PData);
extern PACKAGE void __fastcall EncodeKanji(AnsiString ABarcode, int AIndex, int ACount, PDWORD &PData);
extern PACKAGE AnsiString __fastcall Analyse(AnsiString ABarcode, int AVersion, TQRCode_EncodePolicy AEncodePolicy, bool AAllowKanjiMode, TEncodeStatistic &Statistic);
extern PACKAGE void __fastcall DrawFinderPattern(Pcore2d::TMapMatrix ADataMatrix, int ALeftInModules = 0x0, int ATopInModules = 0x0);
extern PACKAGE void __fastcall RS_Encode(Byte EccLen, System::PByte Ecc, int DataLen, System::PByte Data);

}	/* namespace Pqrcodecom */
using namespace Pqrcodecom;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pqrcodecom
