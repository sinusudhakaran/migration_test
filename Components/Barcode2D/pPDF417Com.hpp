// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Ppdf417com.pas' rev: 11.00

#ifndef Ppdf417comHPP
#define Ppdf417comHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Math.hpp>	// Pascal unit
#include <Pcommon2d.hpp>	// Pascal unit
#include <Pcore2d.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Ppdf417com
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TPDF417_EncodeMode { emText, emByte, emNumeric, emNull };
#pragma option pop

#pragma option push -b-
enum TPDF417_TextEncodeMode { tmAlpha, tmLower, tmMixed, tmPunct };
#pragma option pop

#pragma option push -b-
enum TPDF417_Option { poIgnoreShiftBeforeECI, poFirst903TextAlphaLatch, poFirst904TextMixedLatch, po906TextAlphaLatch, po907TextAlphaLatch, po908TextAlphaLatch, po910TextAlphaLatch, po912TextAlphaLatch, po914TextAlphaLatch, po915TextAlphaLatch, poFirstFNC1MatchAI01, poMicroPDF417Explicit901 };
#pragma option pop

typedef Set<TPDF417_Option, poIgnoreShiftBeforeECI, poMicroPDF417Explicit901>  TPDF417_Options;

typedef DynamicArray<Word >  TPDF417_CodeWords;

struct TCoefficients
{
	
public:
	Word K;
	Word *Coefficients;
	System::TDateTime LastUsedTime;
} ;

typedef DynamicArray<TCoefficients >  pPDF417Com__2;

class DELPHICLASS TReedSolomon;
class PASCALIMPLEMENTATION TReedSolomon : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	int FMaxCacheCount;
	DynamicArray<TCoefficients >  FCoefficientsCache;
	void __fastcall Coefficients(Word k, PWORD PCof);
	PWORD __fastcall GetCoefficient(Word k);
	
public:
	__fastcall TReedSolomon(int MaxCacheCount);
	__fastcall virtual ~TReedSolomon(void);
	void __fastcall Encode(Word EdccNum, PWORD Edcc, Word DataNum, PWORD Data);
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Word PDF417_Pattern[3][931];
extern PACKAGE Byte MicroPDF417_RAPs[52][2];
extern PACKAGE AnsiString __fastcall InternalEncode(AnsiString ABarcode, bool AAllowEscape, TPDF417_EncodeMode AMode, TPDF417_TextEncodeMode ATextMode, int &AInvalidIndex, TPDF417_Options AOptions = TPDF417_Options() , bool IsStructuredAppendField = false);
extern PACKAGE void __fastcall VerifyEscape(AnsiString ABarcode, int ABarcodeLen, TPDF417_Options AOptions, int &AInvalidIndex, int &EscapeCodeWords, int &BarcodeCodeWords, bool &AIsFirstBlock);
extern PACKAGE AnsiString __fastcall EncodeStructAppend(AnsiString AParameter, TPDF417_Options AOptions, bool &AIsFirst, bool &AIsEnd, bool &ASuccess);
extern PACKAGE AnsiString __fastcall GetCheckSum(AnsiString ABarcode, bool AAllowEscape, int &AInvalidIndex, TPDF417_Options AOptions = TPDF417_Options() );

}	/* namespace Ppdf417com */
using namespace Ppdf417com;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Ppdf417com
