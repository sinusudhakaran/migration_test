// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pcode16k.pas' rev: 11.00

#ifndef Pcode16kHPP
#define Pcode16kHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Pcommon2d.hpp>	// Pascal unit
#include <Pcore2d.hpp>	// Pascal unit
#include <Pbarcode2d.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pcode16k
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TCode16K_EncodeMode { emAuto, emModeA, emModeB, emModeC, emModeB_FNC1, emModeC_FNC1, emModeC_Shift1B, emModeC_Shift2B, emMode_Extended };
#pragma option pop

typedef Shortint TCode16K_Rows;

class DELPHICLASS TBarcode2D_Code16K;
class PASCALIMPLEMENTATION TBarcode2D_Code16K : public Pbarcode2d::TBarcode2D 
{
	typedef Pbarcode2d::TBarcode2D inherited;
	
private:
	TCode16K_Rows FMinRows;
	TCode16K_Rows FMaxRows;
	TCode16K_EncodeMode FInitialMode;
	bool FAllowEscape;
	int FRowHeight;
	int FSeparatorBarHeight;
	int FLeadingQuietZone;
	int FTrailingQuietZone;
	void __fastcall SetMinRows(const TCode16K_Rows Value);
	void __fastcall SetMaxRows(const TCode16K_Rows Value);
	void __fastcall SetInitialMode(const TCode16K_EncodeMode Value);
	void __fastcall SetAllowEscape(const bool Value);
	void __fastcall SetRowHeight(const int Value);
	void __fastcall SetSeparatorBarHeight(const int Value);
	HIDESBASE void __fastcall SetLeadingQuietZone(const int Value);
	HIDESBASE void __fastcall SetTrailingQuietZone(const int Value);
	TCode16K_Rows __fastcall GetCurrentRows(void);
	TCode16K_EncodeMode __fastcall GetCurrentMode(void);
	
protected:
	bool __fastcall ParseMultiSymbols(AnsiString AParameter, int &ASerial, int &AAmount);
	AnsiString __fastcall Encode(AnsiString ABarcode, int ABarcodeLen, bool AAllowEscape, TCode16K_EncodeMode ADefaultMode, TCode16K_EncodeMode &AMode, int &AInvalidIndex);
	virtual void __fastcall GetMinQuietZonesInModules(int &Left, int &Top, int &Right, int &Bottom);
	virtual void __fastcall GetSymbolZoneInModules(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	virtual void __fastcall CustomWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall ConfigWorkArea(Pcore2d::PCoreWorkArea &PWorkArea, Graphics::TCanvas* ACanvas, AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, int AModule, int ALeft, int ATop, int AAngle, bool AMirror, Pcore2d::TCustomPrintSizeMode APrintSizeMode = (Pcore2d::TCustomPrintSizeMode)(0x3), double APrintSizeValue = 0.000000E+00, int APrintSizeDPI = 0x0, double APrintDensityRate = 1.000000E+00, void * PCustomData = (void *)(0x0));
	void __fastcall VerifyEscape(AnsiString ABarcode, int ABarcodeLength, int &InvalidEscapeIndex, int &EscapeWordsNumber, int &BarcodeCharsNumber, bool &IsExtended);
	virtual bool __fastcall VerifyLength(Pcore2d::PCoreWorkArea PWorkArea);
	virtual int __fastcall VerifyAllChars(Pcore2d::PCoreWorkArea PWorkArea);
	virtual bool __fastcall LevelOneEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual bool __fastcall CalculateDimension(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall LevelTwoEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall PlacementModules(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall DrawMatrixDot(Pcore2d::PCoreWorkArea PWorkArea, int LeftInModules, int TopInModules, bool Value);
	
public:
	__fastcall virtual TBarcode2D_Code16K(Classes::TComponent* Owner);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property TCode16K_Rows CurrentRows = {read=GetCurrentRows, nodefault};
	__property TCode16K_EncodeMode CurrentMode = {read=GetCurrentMode, nodefault};
	
__published:
	__property TCode16K_Rows MinRows = {read=FMinRows, write=SetMinRows, default=2};
	__property TCode16K_Rows MaxRows = {read=FMaxRows, write=SetMaxRows, default=16};
	__property TCode16K_EncodeMode InitialMode = {read=FInitialMode, write=SetInitialMode, default=0};
	__property bool AllowEscape = {read=FAllowEscape, write=SetAllowEscape, default=0};
	__property int RowHeight = {read=FRowHeight, write=SetRowHeight, default=8};
	__property int SeparatorBarHeight = {read=FSeparatorBarHeight, write=SetSeparatorBarHeight, default=1};
	__property int LeadingQuietZone = {read=FLeadingQuietZone, write=SetLeadingQuietZone, default=10};
	__property int TrailingQuietZone = {read=FTrailingQuietZone, write=SetTrailingQuietZone, default=1};
	__property TopQuietZone  = {default=0};
	__property BottomQuietZone  = {default=0};
public:
	#pragma option push -w-inl
	/* TBarcode2D.Destroy */ inline __fastcall virtual ~TBarcode2D_Code16K(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Pcode16k */
using namespace Pcode16k;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pcode16k
