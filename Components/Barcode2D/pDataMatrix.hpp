// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pdatamatrix.pas' rev: 11.00

#ifndef PdatamatrixHPP
#define PdatamatrixHPP

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

//-- user supplied -----------------------------------------------------------

namespace Pdatamatrix
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TDataMatrix_Size { dmSize_09_09, dmSize_11_11, dmSize_13_13, dmSize_15_15, dmSize_17_17, dmSize_19_19, dmSize_21_21, dmSize_23_23, dmSize_25_25, dmSize_27_27, dmSize_29_29, dmSize_31_31, dmSize_33_33, dmSize_35_35, dmSize_37_37, dmSize_39_39, dmSize_41_41, dmSize_43_43, dmSize_45_45, dmSize_47_47, dmSize_49_49 };
#pragma option pop

#pragma option push -b-
enum TDataMatrix_EccLevel { dmECC000, dmECC050, dmECC080, dmECC100, dmECC140 };
#pragma option pop

#pragma option push -b-
enum TDataMatrix_EncodeMode { emAuto, emNumeric, emAlpha, emPunctuation, emAlphanumeric, emASCII, emBinary };
#pragma option pop

#pragma pack(push,4)
struct TDataMatrix_CustomArea
{
	
public:
	int Data_Bits;
	TDataMatrix_Size Current_Size;
	TDataMatrix_EccLevel Current_EccLevel;
	TDataMatrix_EncodeMode Current_EncodeMode;
} ;
#pragma pack(pop)

typedef TDataMatrix_CustomArea *PDataMatrix_CustomArea;

class DELPHICLASS TBarcode2D_DataMatrix;
class PASCALIMPLEMENTATION TBarcode2D_DataMatrix : public Pbarcode2d::TBarcode2D 
{
	typedef Pbarcode2d::TBarcode2D inherited;
	
private:
	TDataMatrix_Size FMinSize;
	TDataMatrix_Size FMaxSize;
	TDataMatrix_EccLevel FEccLevel;
	bool FEccLevelUpgrade;
	TDataMatrix_EncodeMode FEncodeMode;
	void __fastcall SetMinSize(const TDataMatrix_Size Value);
	void __fastcall SetMaxSize(const TDataMatrix_Size Value);
	void __fastcall SetEccLevel(const TDataMatrix_EccLevel Value);
	void __fastcall SetEccLevelUpgrade(const bool Value);
	void __fastcall SetEncodeMode(const TDataMatrix_EncodeMode Value);
	TDataMatrix_Size __fastcall GetCurrentSize(void);
	TDataMatrix_EccLevel __fastcall GetCurrentEccLevel(void);
	TDataMatrix_EncodeMode __fastcall GetCurrentEncodeMode(void);
	TDataMatrix_EncodeMode __fastcall GetEncodeMode(AnsiString ABarcode, int &ABarcodeLen);
	int __fastcall GetDataBits(TDataMatrix_EncodeMode AEncodeMode, int ABarcodeLength);
	int __fastcall GetTotalBits(int ADataBits, TDataMatrix_EccLevel AEccLevel);
	Byte __fastcall GetCharValue(char Ch, TDataMatrix_EncodeMode AEncodeMode);
	void __fastcall EncodeData(AnsiString ABarcode, PDWORD PData, TDataMatrix_EncodeMode AEncodeMode);
	void __fastcall Split_nBit(PDWORD PSrcData, PDWORD PDstData, int SrcCount, int DstCount, Byte SplitBits);
	void __fastcall Split_1Bit(PDWORD PSrcData, PDWORD PDstData, int SrcCount, int DstCount);
	void __fastcall ECC_050(PDWORD PSrcData, PDWORD PDstData, int SrcCount, int DstCount);
	void __fastcall ECC_080(PDWORD PSrcData, PDWORD PDstData, int SrcCount, int DstCount);
	void __fastcall ECC_100(PDWORD PSrcData, PDWORD PDstData, int SrcCount, int DstCount);
	void __fastcall ECC_140(PDWORD PSrcData, PDWORD PDstData, int SrcCount, int DstCount);
	
protected:
	virtual void __fastcall GetMinQuietZonesInModules(int &Left, int &Top, int &Right, int &Bottom);
	virtual void __fastcall GetSymbolZoneInModules(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	virtual bool __fastcall VerifyLength(Pcore2d::PCoreWorkArea PWorkArea);
	virtual bool __fastcall VerifyChar(Pcore2d::PCoreWorkArea PWorkArea, int Index);
	virtual void __fastcall CustomWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall ConfigWorkArea(Pcore2d::PCoreWorkArea &PWorkArea, Graphics::TCanvas* ACanvas, AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, int AModule, int ALeft, int ATop, int AAngle, bool AMirror = false, Pcore2d::TCustomPrintSizeMode APrintSizeMode = (Pcore2d::TCustomPrintSizeMode)(0x3), double APrintSizeValue = 0.000000E+00, int APrintSizeDPI = 0x0, double APrintDensityRate = 1.000000E+00, void * PCustomData = (void *)(0x0));
	virtual bool __fastcall LevelOneEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual bool __fastcall CalculateDimension(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall LevelTwoEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall PlacementModules(Pcore2d::PCoreWorkArea &PWorkArea);
	
public:
	__fastcall virtual TBarcode2D_DataMatrix(Classes::TComponent* Owner);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property TDataMatrix_Size CurrentSize = {read=GetCurrentSize, nodefault};
	__property TDataMatrix_EccLevel CurrentEccLevel = {read=GetCurrentEccLevel, nodefault};
	__property TDataMatrix_EncodeMode CurrentEncodeMode = {read=GetCurrentEncodeMode, nodefault};
	
__published:
	__property TDataMatrix_Size MinSize = {read=FMinSize, write=SetMinSize, default=0};
	__property TDataMatrix_Size MaxSize = {read=FMaxSize, write=SetMaxSize, default=20};
	__property TDataMatrix_EccLevel EccLevel = {read=FEccLevel, write=SetEccLevel, default=0};
	__property bool EccLevelUpgrade = {read=FEccLevelUpgrade, write=SetEccLevelUpgrade, default=1};
	__property TDataMatrix_EncodeMode EncodeMode = {read=FEncodeMode, write=SetEncodeMode, default=0};
	__property Inversed  = {default=0};
public:
	#pragma option push -w-inl
	/* TBarcode2D.Destroy */ inline __fastcall virtual ~TBarcode2D_DataMatrix(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Pdatamatrix */
using namespace Pdatamatrix;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pdatamatrix
