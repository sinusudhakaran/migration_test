// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pmicroqrcode.pas' rev: 11.00

#ifndef PmicroqrcodeHPP
#define PmicroqrcodeHPP

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
#include <Math.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Pcommon2d.hpp>	// Pascal unit
#include <Pcore2d.hpp>	// Pascal unit
#include <Pbarcode2d.hpp>	// Pascal unit
#include <Pqrcodecom.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pmicroqrcode
{
//-- type declarations -------------------------------------------------------
typedef Shortint TMicroQRCode_Version;

#pragma option push -b-
enum TMicroQRCode_EccLevel { elLowest, elMedium, elQuality };
#pragma option pop

#pragma pack(push,4)
struct TMicroQRCode_CustomArea
{
	
public:
	int Total_DataBits;
	TMicroQRCode_Version Current_Version;
	TMicroQRCode_EccLevel Current_EccLevel;
} ;
#pragma pack(pop)

typedef TMicroQRCode_CustomArea *PMicroQRCode_CustomArea;

class DELPHICLASS TBarcode2D_MicroQRCode;
class PASCALIMPLEMENTATION TBarcode2D_MicroQRCode : public Pbarcode2d::TBarcode2D 
{
	typedef Pbarcode2d::TBarcode2D inherited;
	
private:
	TMicroQRCode_Version FMinVersion;
	TMicroQRCode_Version FMaxVersion;
	TMicroQRCode_EccLevel FEccLevel;
	bool FEccLevelUpgrade;
	bool FAllowKanjiMode;
	Pqrcodecom::TQRCode_EncodePolicy FEncodePolicy;
	void __fastcall SetMinVersion(const TMicroQRCode_Version Value);
	void __fastcall SetMaxVersion(const TMicroQRCode_Version Value);
	void __fastcall SetEccLevel(const TMicroQRCode_EccLevel Value);
	void __fastcall SetEccLevelUpgrade(const bool Value);
	void __fastcall SetAllowKanjiMode(const bool Value);
	void __fastcall SetEncodePolicy(const Pqrcodecom::TQRCode_EncodePolicy Value);
	TMicroQRCode_Version __fastcall GetCurrentVersion(void);
	TMicroQRCode_EccLevel __fastcall GetCurrentEccLevel(void);
	void __fastcall DrawTimingPattern(Pcore2d::TMapMatrix ADataMatrix);
	void __fastcall DrawFormatPattern(Pcore2d::TMapMatrix ADataMatrix, TMicroQRCode_Version AVersion, TMicroQRCode_EccLevel AEccLevel, Byte AMaskId);
	void __fastcall DrawCodeWords(Pcore2d::TMapMatrix ADataMatrix, Byte * ACodeWords, const int ACodeWords_Size, TMicroQRCode_Version AVersion, TMicroQRCode_EccLevel AEccLevel);
	Word __fastcall GetMaskScore(Pcore2d::TMapMatrix ADataMatrix, Byte AMaskId);
	Byte __fastcall GetOptimalMask(Pcore2d::TMapMatrix ADataMatrix);
	Byte __fastcall GetMaskValue(Byte AMaskId, Word ARow, Word ACol);
	void __fastcall ApplyMask(Pcore2d::TMapMatrix ADataMatrix, Byte AMaskId);
	
protected:
	virtual void __fastcall GetMinQuietZonesInModules(int &Left, int &Top, int &Right, int &Bottom);
	virtual void __fastcall GetSymbolZoneInModules(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	virtual void __fastcall CustomWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall ConfigWorkArea(Pcore2d::PCoreWorkArea &PWorkArea, Graphics::TCanvas* ACanvas, AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, int AModule, int ALeft, int ATop, int AAngle, bool AMirror = false, Pcore2d::TCustomPrintSizeMode APrintSizeMode = (Pcore2d::TCustomPrintSizeMode)(0x3), double APrintSizeValue = 0.000000E+00, int APrintSizeDPI = 0x0, double APrintDensityRate = 1.000000E+00, void * PCustomData = (void *)(0x0));
	virtual bool __fastcall VerifyLength(Pcore2d::PCoreWorkArea PWorkArea);
	virtual bool __fastcall VerifyChar(Pcore2d::PCoreWorkArea PWorkArea, int AIndex);
	virtual bool __fastcall CalculateDimension(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall LevelTwoEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall PlacementModules(Pcore2d::PCoreWorkArea &PWorkArea);
	void __fastcall Encode(AnsiString ABarcode, int AVersion, AnsiString AAnalysis, PDWORD PData);
	
public:
	__fastcall virtual TBarcode2D_MicroQRCode(Classes::TComponent* Owner);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property TMicroQRCode_Version CurrentVersion = {read=GetCurrentVersion, nodefault};
	__property TMicroQRCode_EccLevel CurrentEccLevel = {read=GetCurrentEccLevel, nodefault};
	
__published:
	__property TMicroQRCode_Version MinVersion = {read=FMinVersion, write=SetMinVersion, default=1};
	__property TMicroQRCode_Version MaxVersion = {read=FMaxVersion, write=SetMaxVersion, default=4};
	__property TMicroQRCode_EccLevel EccLevel = {read=FEccLevel, write=SetEccLevel, default=0};
	__property bool EccLevelUpgrade = {read=FEccLevelUpgrade, write=SetEccLevelUpgrade, default=1};
	__property bool AllowKanjiMode = {read=FAllowKanjiMode, write=SetAllowKanjiMode, default=0};
	__property Pqrcodecom::TQRCode_EncodePolicy EncodePolicy = {read=FEncodePolicy, write=SetEncodePolicy, default=0};
	__property Inversed  = {default=0};
	__property Mirrored  = {default=0};
	__property LeadingQuietZone  = {default=2};
	__property TopQuietZone  = {default=2};
	__property TrailingQuietZone  = {default=2};
	__property BottomQuietZone  = {default=2};
public:
	#pragma option push -w-inl
	/* TBarcode2D.Destroy */ inline __fastcall virtual ~TBarcode2D_MicroQRCode(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Pmicroqrcode */
using namespace Pmicroqrcode;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pmicroqrcode
