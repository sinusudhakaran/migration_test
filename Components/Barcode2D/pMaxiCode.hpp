// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pmaxicode.pas' rev: 11.00

#ifndef PmaxicodeHPP
#define PmaxicodeHPP

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
#include <Types.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Math.hpp>	// Pascal unit
#include <Pcommon2d.hpp>	// Pascal unit
#include <Pcore2d.hpp>	// Pascal unit
#include <Pbarcode2d.hpp>	// Pascal unit
#include <Preedsolomon.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pmaxicode
{
//-- type declarations -------------------------------------------------------
typedef Shortint TMaxiCode_Mode;

#pragma option push -b-
enum TMaxiCode_EncodeMode { emCodeSetA, emCodeSetB, emCodeSetC, emCodeSetD, emCodeSetE };
#pragma option pop

typedef Byte TMaxiCode_Postcode[6];

class DELPHICLASS TBarcode2D_MaxiCode;
class PASCALIMPLEMENTATION TBarcode2D_MaxiCode : public Pbarcode2d::TBarcode2D 
{
	typedef Pbarcode2d::TBarcode2D inherited;
	
private:
	TMaxiCode_Mode FMode;
	bool FAutoMode;
	bool FAllowEscape;
	Preedsolomon::TReedSolomon* FReedSolomon;
	void __fastcall SetMode(const TMaxiCode_Mode Value);
	void __fastcall SetAutoMode(const bool Value);
	void __fastcall SetAllowEscape(const bool Value);
	TMaxiCode_Mode __fastcall GetCurrentMode(void);
	
protected:
	virtual void __fastcall GetDefaultSizeInPixels(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	virtual bool __fastcall VerifyLength(Pcore2d::PCoreWorkArea PWorkArea);
	virtual void __fastcall GetMinQuietZonesInModules(int &Left, int &Top, int &Right, int &Bottom);
	virtual void __fastcall GetSymbolZoneInModules(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	virtual void __fastcall CustomWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall ConfigWorkArea(Pcore2d::PCoreWorkArea &PWorkArea, Graphics::TCanvas* ACanvas, AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, int AModule, int ALeft, int ATop, int AAngle, bool AMirror = false, Pcore2d::TCustomPrintSizeMode APrintSizeMode = (Pcore2d::TCustomPrintSizeMode)(0x3), double APrintSizeValue = 0.000000E+00, int APrintSizeDPI = 0x0, double APrintDensityRate = 1.000000E+00, void * PCustomData = (void *)(0x0));
	int __fastcall ParseCarrier(AnsiString ABarcode, Byte * Postcode, Word &Country, Word &Service, AnsiString &Messages, TMaxiCode_Mode &NewMode, int &PrimaryMesgLen);
	virtual bool __fastcall LevelOneEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall LevelTwoEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall PlacementModules(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall InternalDraw(Pcore2d::PCoreWorkArea PWorkArea);
	virtual void __fastcall DrawMatrixDot(Pcore2d::PCoreWorkArea PWorkArea, int LeftInModules, int TopInModules, bool Value);
	void __fastcall DrawHexagon(Pcore2d::PCoreWorkArea PWorkArea, int ALeftInPixels, int ATopInPixels, Graphics::TColor AColor, bool IsFinder);
	AnsiString __fastcall Encode(AnsiString ABarcode, int AIndex, TMaxiCode_EncodeMode &LastMode, int &InvalidIndex, int MaxEncodeCount = 0xc8);
	
public:
	__fastcall virtual TBarcode2D_MaxiCode(Classes::TComponent* Owner);
	__fastcall virtual ~TBarcode2D_MaxiCode(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property TMaxiCode_Mode CurrentMode = {read=GetCurrentMode, nodefault};
	
__published:
	__property Module  = {default=4};
	__property TMaxiCode_Mode Mode = {read=FMode, write=SetMode, default=4};
	__property bool AutoMode = {read=FAutoMode, write=SetAutoMode, default=1};
	__property bool AllowEscape = {read=FAllowEscape, write=SetAllowEscape, default=0};
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Pmaxicode */
using namespace Pmaxicode;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pmaxicode
