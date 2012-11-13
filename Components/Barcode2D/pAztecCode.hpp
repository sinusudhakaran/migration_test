// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pazteccode.pas' rev: 11.00

#ifndef PazteccodeHPP
#define PazteccodeHPP

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
#include <Pcommon2d.hpp>	// Pascal unit
#include <Pcore2d.hpp>	// Pascal unit
#include <Pbarcode2d.hpp>	// Pascal unit
#include <Preedsolomon.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pazteccode
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TAztecCode_Size { azSize_15Compact, azSize_19, azSize_19Compact, azSize_23, azSize_23Compact, azSize_27, azSize_27Compact, azSize_31, azSize_37, azSize_41, azSize_45, azSize_49, azSize_53, azSize_57, azSize_61, azSize_67, azSize_71, azSize_75, azSize_79, azSize_83, azSize_87, azSize_91, azSize_95, azSize_101, azSize_105, azSize_109, azSize_113, azSize_117, azSize_121, azSize_125, azSize_131, azSize_135, azSize_139, azSize_143, azSize_147, azSize_151 };
#pragma option pop

typedef Shortint TAztecCode_EccLevel;

#pragma option push -b-
enum TAztecCode_SymbolMode { smNormal, smCompact, smFullRange, smProgram, smAll };
#pragma option pop

#pragma option push -b-
enum TAztecCode_EncodeMode { emNull, emUpper, emLower, emMixed, emPunct, emDigit, emBytes };
#pragma option pop

class DELPHICLASS TBarcode2D_AztecCode;
class PASCALIMPLEMENTATION TBarcode2D_AztecCode : public Pbarcode2d::TBarcode2D 
{
	typedef Pbarcode2d::TBarcode2D inherited;
	
private:
	TAztecCode_Size FMinSize;
	TAztecCode_Size FMaxSize;
	TAztecCode_SymbolMode FSymbolMode;
	TAztecCode_EccLevel FEccLevel;
	Word FEccCount;
	bool FAllowEscape;
	Preedsolomon::TReedSolomon* FReedSolomon;
	void __fastcall SetMinSize(const TAztecCode_Size Value);
	void __fastcall SetMaxSize(const TAztecCode_Size Value);
	void __fastcall SetSymbolMode(const TAztecCode_SymbolMode Value);
	void __fastcall SetEccLevel(const TAztecCode_EccLevel Value);
	void __fastcall SetEccCount(const Word Value);
	void __fastcall SetAllowEscape(const bool Value);
	TAztecCode_Size __fastcall GetCurrentSize(void);
	void __fastcall InternalEncode(AnsiString ABarcode, AnsiString &SemiCode, int &SemiBits);
	AnsiString __fastcall InternalSplite(Byte * SemiWords, const int SemiWords_Size, Byte CodeWordBits, Word &TotalCodeWords, PWORD PCodeWords);
	AnsiString __fastcall Escape(AnsiString ABarcode, bool &AReaderPrograming, int &ABarcodeCharNumber, int &AInvalidIndex, bool IsStructuredAppend = false);
	AnsiString __fastcall Encode(AnsiString AEscpCode, int &TotalBits);
	bool __fastcall Splite(Byte * SemiWords, const int SemiWords_Size, TAztecCode_Size AMaxSize, TAztecCode_Size &ASize, Word &DataWordsNumb, PWORD PCodeWords);
	
protected:
	virtual void __fastcall CustomWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall DeleteWorkArea(Pcore2d::PCoreWorkArea PWorkArea);
	virtual void __fastcall ConfigWorkArea(Pcore2d::PCoreWorkArea &PWorkArea, Graphics::TCanvas* ACanvas, AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, int AModule, int ALeft, int ATop, int AAngle, bool AMirror = false, Pcore2d::TCustomPrintSizeMode APrintSizeMode = (Pcore2d::TCustomPrintSizeMode)(0x3), double APrintSizeValue = 0.000000E+00, int APrintSizeDPI = 0x0, double APrintDensityRate = 1.000000E+00, void * PCustomData = (void *)(0x0));
	virtual bool __fastcall VerifyLength(Pcore2d::PCoreWorkArea PWorkArea);
	virtual int __fastcall VerifyAllChars(Pcore2d::PCoreWorkArea PWorkArea);
	virtual bool __fastcall LevelOneEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual bool __fastcall CalculateDimension(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall LevelTwoEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall GetMinQuietZonesInModules(int &Left, int &Top, int &Right, int &Bottom);
	virtual void __fastcall GetSymbolZoneInModules(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	virtual void __fastcall PlacementModules(Pcore2d::PCoreWorkArea &PWorkArea);
	
public:
	__fastcall virtual TBarcode2D_AztecCode(Classes::TComponent* Owner);
	__fastcall virtual ~TBarcode2D_AztecCode(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property TAztecCode_Size CurrentSize = {read=GetCurrentSize, nodefault};
	
__published:
	__property TAztecCode_Size MinSize = {read=FMinSize, write=SetMinSize, default=0};
	__property TAztecCode_Size MaxSize = {read=FMaxSize, write=SetMaxSize, default=35};
	__property TAztecCode_SymbolMode SymbolMode = {read=FSymbolMode, write=SetSymbolMode, default=0};
	__property TAztecCode_EccLevel ECCLevel = {read=FEccLevel, write=SetEccLevel, default=23};
	__property Word ECCCount = {read=FEccCount, write=SetEccCount, default=3};
	__property bool AllowEscape = {read=FAllowEscape, write=SetAllowEscape, default=0};
	__property Inversed  = {default=0};
	__property Mirrored  = {default=0};
	__property LeadingQuietZone  = {default=0};
	__property TopQuietZone  = {default=0};
	__property TrailingQuietZone  = {default=0};
	__property BottomQuietZone  = {default=0};
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Pazteccode */
using namespace Pazteccode;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pazteccode
