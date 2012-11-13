// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pcore2d.pas' rev: 11.00

#ifndef Pcore2dHPP
#define Pcore2dHPP

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
#include <Classes.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pcore2d
{
//-- type declarations -------------------------------------------------------
typedef DynamicArray<Byte >  pCore2D__1;

typedef DynamicArray<DynamicArray<Byte > >  TMapMatrix;

#pragma option push -b-
enum TCustomPrintSizeMode { cpsmNone, cpsmWidth, cpsmHeight, cpsmNoPrint };
#pragma option pop

typedef DynamicArray<Byte >  pCore2D__2;

typedef DynamicArray<Byte >  pCore2D__3;

struct TCoreWorkArea
{
	
public:
	int WSize;
	void *WCustomArea;
	int WCustomSize;
	Graphics::TCanvas* WCanvas;
	AnsiString WBarcode;
	Graphics::TColor WBarColor;
	Graphics::TColor WSpaceColor;
	int WModule;
	int WLeftInPixels;
	int WTopInPixels;
	int WAngle;
	bool WShowQuietZone;
	bool WMirror;
	bool WInvalidLength;
	int WInvalidIndex;
	int WInvalidLinear;
	bool WLengthVerified;
	bool WAllCharsVerified;
	bool WLevelOneEncoded;
	bool WDimensionCalculated;
	bool WLevelTwoEncoded;
	bool WDotsPlacemented;
	bool WContinueToDraw;
	AnsiString WAnsiBarcode;
	int WBarcodeLength;
	DynamicArray<Byte >  WSemiWords;
	int WSemiWordsCount;
	DynamicArray<Byte >  WCodeWords;
	int WCodeWordsCount;
	int WQuietZoneWidthInModules_Left;
	int WQuietZoneWidthInModules_Top;
	int WQuietZoneWidthInModules_Right;
	int WQuietZoneWidthInModules_Bottom;
	int WSymbolZoneWidthInModules;
	int WSymbolZoneHeightInModules;
	int WTotalWidthInPixels;
	int WTotalHeightInPixels;
	int WSymbolZoneOffsetInPixels_Left;
	int WSymbolZoneOffsetInPixels_Top;
	double WAlpha;
	#pragma pack(push,1)
	Types::TPoint WOrgin;
	#pragma pack(pop)
	DynamicArray<DynamicArray<Byte > >  WDotsMatrix;
	TCustomPrintSizeMode WCustomPrintSizeMode;
	double WCustomPrintSizeValue;
	int WCustomPrintSizeDPI;
	double WPrintDensityRate;
} ;

typedef TCoreWorkArea *PCoreWorkArea;

typedef void __fastcall (__closure *TOnEncode)(System::TObject* Sender, AnsiString &AnsiBarcode, AnsiString Barcode);

class DELPHICLASS TBarcodeCore2D;
class PASCALIMPLEMENTATION TBarcodeCore2D : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	TOnEncode FOnEncode;
	
protected:
	virtual PCoreWorkArea __fastcall CreateWorkArea(void);
	virtual void __fastcall CustomWorkArea(PCoreWorkArea &PWorkArea);
	virtual void __fastcall ConfigWorkArea(PCoreWorkArea &PWorkArea, Graphics::TCanvas* ACanvas, AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, int AModule, int ALeft, int ATop, int AAngle, bool AMirror = false, TCustomPrintSizeMode APrintSizeMode = (TCustomPrintSizeMode)(0x3), double APrintSizeValue = 0.000000E+00, int APrintSizeDPI = 0x0, double APrintDensityRate = 1.000000E+00, void * PCustomData = (void *)(0x0));
	virtual int __fastcall EncodeWorkArea(PCoreWorkArea &PWorkArea);
	virtual void __fastcall FillinWorkArea(PCoreWorkArea &PWorkArea);
	virtual void __fastcall DeleteWorkArea(PCoreWorkArea PWorkArea);
	virtual bool __fastcall LevelOneEncode(PCoreWorkArea &PWorkArea);
	virtual bool __fastcall CalculateDimension(PCoreWorkArea &PWorkArea);
	virtual bool __fastcall VerifyLength(PCoreWorkArea PWorkArea);
	virtual int __fastcall VerifyAllChars(PCoreWorkArea PWorkArea);
	virtual bool __fastcall VerifyChar(PCoreWorkArea PWorkArea, int AIndex);
	virtual void __fastcall LevelTwoEncode(PCoreWorkArea &PWorkArea) = 0 ;
	virtual void __fastcall PlacementMapMatrix(PCoreWorkArea &PWorkArea);
	virtual void __fastcall PlacementModules(PCoreWorkArea &PWorkArea) = 0 ;
	virtual void __fastcall GetQuietZonesInModules(PCoreWorkArea PWorkArea, int &Left, int &Top, int &Right, int &Bottom) = 0 ;
	virtual void __fastcall GetSymbolZoneInModules(PCoreWorkArea PWorkArea, int &AWidth, int &AHeight) = 0 ;
	virtual void __fastcall GetDefaultSizeInPixels(PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	virtual void __fastcall DrawMatrixDot(PCoreWorkArea PWorkArea, int LeftInModules, int TopInModules, bool Value);
	virtual void __fastcall InternalDraw(PCoreWorkArea PWorkArea);
	int __fastcall InternalDrawBarcode(PCoreWorkArea PWorkArea);
	virtual int __fastcall DrawBarcode(Graphics::TCanvas* ACanvas, AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, int AModule, int ALeft, int ATop, int AAngle = 0x0, bool AMirrored = false, TCustomPrintSizeMode APrintSizeMode = (TCustomPrintSizeMode)(0x3), double APrintSizeValue = 0.000000E+00, double APrintDensityRate = 1.000000E+00, void * PCustomData = (void *)(0x0));
	
__published:
	__property TOnEncode OnEncode = {read=FOnEncode, write=FOnEncode};
public:
	#pragma option push -w-inl
	/* TComponent.Create */ inline __fastcall virtual TBarcodeCore2D(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TComponent.Destroy */ inline __fastcall virtual ~TBarcodeCore2D(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Pcore2d */
using namespace Pcore2d;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pcore2d
