// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pqrcode.pas' rev: 11.00

#ifndef PqrcodeHPP
#define PqrcodeHPP

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
#include <Pbarcode2d.hpp>	// Pascal unit
#include <Pqrcodecom.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pqrcode
{
//-- type declarations -------------------------------------------------------
typedef Shortint TQRCode_Version;

#pragma option push -b-
enum TQRCode_EccLevel { elLowest, elMedium, elQuality, elHighest };
#pragma option pop

#pragma pack(push,4)
struct TQRCode_CustomArea
{
	
public:
	int BarcodeChars_Numb;
	int FunctionBits_Numb;
	int Data_Number;
	int Bits_Number;
	int TotalBits_Number;
	int EncodeVersion;
	TQRCode_Version Current_Version;
	TQRCode_EccLevel Current_EccLevel;
} ;
#pragma pack(pop)

typedef TQRCode_CustomArea *PQRCode_CustomArea;

class DELPHICLASS TBarcode2D_QRCode;
class PASCALIMPLEMENTATION TBarcode2D_QRCode : public Pbarcode2d::TBarcode2D 
{
	typedef Pbarcode2d::TBarcode2D inherited;
	
private:
	TQRCode_Version FMinVersion;
	TQRCode_Version FMaxVersion;
	TQRCode_EccLevel FEccLevel;
	bool FEccLevelUpgrade;
	bool FAllowKanjiMode;
	bool FAllowEscape;
	Pqrcodecom::TQRCode_EncodePolicy FEncodePolicy;
	void __fastcall SetMinVersion(const TQRCode_Version Value);
	void __fastcall SetMaxVersion(const TQRCode_Version Value);
	void __fastcall SetEccLevel(const TQRCode_EccLevel Value);
	void __fastcall SetEccLevelUpgrade(const bool Value);
	void __fastcall SetAllowKanjiMode(const bool Value);
	void __fastcall SetAllowEscape(const bool Value);
	void __fastcall SetEncodePolicy(const Pqrcodecom::TQRCode_EncodePolicy Value);
	TQRCode_Version __fastcall GetCurrentVersion(void);
	TQRCode_EccLevel __fastcall GetCurrentEccLevel(void);
	void __fastcall DrawTimingPattern(Pcore2d::TMapMatrix ADataMatrix);
	void __fastcall DrawAlignmentPatterns(Pcore2d::TMapMatrix ADataMatrix, TQRCode_Version AVersion);
	void __fastcall DrawFormatPattern(Pcore2d::TMapMatrix ADataMatrix, TQRCode_EccLevel AEccLevel, Byte AMaskId);
	void __fastcall DrawVersionPattern(Pcore2d::TMapMatrix ADataMatrix, TQRCode_Version AVersion);
	void __fastcall DrawCodeWords(Pcore2d::TMapMatrix &ADataMatrix, Byte * ACodeWords, const int ACodeWords_Size, TQRCode_Version AVersion, TQRCode_EccLevel AEccLevel);
	int __fastcall GetMaskScore(Pcore2d::TMapMatrix ADataMatrix, Byte AMaskId);
	Byte __fastcall GetOptimalMask(Pcore2d::TMapMatrix ADataMatrix, TQRCode_EccLevel AEccLevel);
	Byte __fastcall GetMaskValue(Byte AMaskId, Word ARow, Word ACol);
	void __fastcall ApplyMask(Pcore2d::TMapMatrix ADataMatrix, Byte AMaskId);
	
protected:
	virtual void __fastcall GetMinQuietZonesInModules(int &Left, int &Top, int &Right, int &Bottom);
	virtual void __fastcall GetSymbolZoneInModules(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	virtual void __fastcall CustomWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall ConfigWorkArea(Pcore2d::PCoreWorkArea &PWorkArea, Graphics::TCanvas* ACanvas, AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, int AModule, int ALeft, int ATop, int AAngle, bool AMirror = false, Pcore2d::TCustomPrintSizeMode APrintSizeMode = (Pcore2d::TCustomPrintSizeMode)(0x3), double APrintSizeValue = 0.000000E+00, int APrintSizeDPI = 0x0, double APrintDensityRate = 1.000000E+00, void * PCustomData = (void *)(0x0));
	virtual bool __fastcall VerifyLength(Pcore2d::PCoreWorkArea PWorkArea);
	virtual int __fastcall VerifyAllChars(Pcore2d::PCoreWorkArea PWorkArea);
	virtual bool __fastcall LevelOneEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual bool __fastcall CalculateDimension(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall LevelTwoEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall PlacementModules(Pcore2d::PCoreWorkArea &PWorkArea);
	void __fastcall FilterEscape(AnsiString ABarcode, int &Function_Bits, int &DataChar_Number);
	int __fastcall VerifyEscape(AnsiString ABarcode);
	AnsiString __fastcall Analyse(AnsiString ABarcode, int AVersion, Pqrcodecom::TQRCode_EncodePolicy AEncodePolicy, bool AAllowKanjiMode, Pqrcodecom::TEncodeStatistic &EncodeStatistic, int &HeadLength);
	void __fastcall Encode(AnsiString ABarcode, int AVersion, AnsiString AAnalysis, PDWORD PData, int HeadLength);
	
public:
	__fastcall virtual TBarcode2D_QRCode(Classes::TComponent* Owner);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property TQRCode_Version CurrentVersion = {read=GetCurrentVersion, nodefault};
	__property TQRCode_EccLevel CurrentEccLevel = {read=GetCurrentEccLevel, nodefault};
	Byte __fastcall GetParity(AnsiString ABarcode, bool AAllowEscape, int &AInvalidIndex);
	
__published:
	__property TQRCode_Version MinVersion = {read=FMinVersion, write=SetMinVersion, default=1};
	__property TQRCode_Version MaxVersion = {read=FMaxVersion, write=SetMaxVersion, default=40};
	__property TQRCode_EccLevel EccLevel = {read=FEccLevel, write=SetEccLevel, default=0};
	__property bool EccLevelUpgrade = {read=FEccLevelUpgrade, write=SetEccLevelUpgrade, default=1};
	__property bool AllowKanjiMode = {read=FAllowKanjiMode, write=SetAllowKanjiMode, default=0};
	__property bool AllowEscape = {read=FAllowEscape, write=SetAllowEscape, default=0};
	__property Pqrcodecom::TQRCode_EncodePolicy EncodePolicy = {read=FEncodePolicy, write=SetEncodePolicy, default=0};
	__property Inversed  = {default=0};
	__property Mirrored  = {default=0};
	__property LeadingQuietZone  = {default=4};
	__property TopQuietZone  = {default=4};
	__property TrailingQuietZone  = {default=4};
	__property BottomQuietZone  = {default=4};
public:
	#pragma option push -w-inl
	/* TBarcode2D.Destroy */ inline __fastcall virtual ~TBarcode2D_QRCode(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Pqrcode */
using namespace Pqrcode;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pqrcode
