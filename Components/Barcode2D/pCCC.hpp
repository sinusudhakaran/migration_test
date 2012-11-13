// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pccc.pas' rev: 11.00

#ifndef PcccHPP
#define PcccHPP

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
#include <Printers.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit
#include <Typinfo.hpp>	// Pascal unit
#include <Pcommon2d.hpp>	// Pascal unit
#include <Pcore2d.hpp>	// Pascal unit
#include <Pbarcode2d.hpp>	// Pascal unit
#include <Pcccom.hpp>	// Pascal unit
#include <Ppdf417com.hpp>	// Pascal unit
#include <Ppdf417custom.hpp>	// Pascal unit
#include <Pucccom.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pccc
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TCCC_StretchOrder { soMaxColumnsInLinear, soMaxColumnsOutLinear, soRowColumn, soColumnRow };
#pragma option pop

#pragma pack(push,1)
struct TCCC_CustomArea
{
	
public:
	Ppdf417custom::TPDF417_Rows Current_Rows;
	Ppdf417custom::TPDF417_Columns Current_Columns;
	Ppdf417custom::TPDF417_EccLevel Current_EccLevel;
	int TotalDataBits;
	int TotalSemiWords;
	Pucccom::TUCC_EncodeMode LastMode;
	int LinearWidth;
	int LinearHeight;
	int LinearLeft;
	int LinearTop;
	int LinearSymbolLeftZone;
	int LinearSymbolRightZone;
	double LinearPrintHeight;
} ;
#pragma pack(pop)

typedef TCCC_CustomArea *PCCCCustomArea;

class DELPHICLASS TBarcode2D_CCC;
class PASCALIMPLEMENTATION TBarcode2D_CCC : public Ppdf417custom::TBarcode2D_PDF417Custom 
{
	typedef Ppdf417custom::TBarcode2D_PDF417Custom inherited;
	
private:
	TCCC_StretchOrder FStretchOrder;
	Classes::TComponent* FLinear;
	void __fastcall SetStretchOrder(const TCCC_StretchOrder Value);
	void __fastcall SetLinear(const Classes::TComponent* Value);
	void __fastcall LinearClear(System::TObject* Sender);
	void __fastcall LinearChanged(System::TObject* Sender);
	
protected:
	virtual void __fastcall DoInvalidLength(AnsiString ABarcode, bool LinearFlag = false);
	virtual void __fastcall DoInvalidChar(AnsiString ABarcode, int Index);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall SetCompact(const bool Value);
	virtual void __fastcall GetMinQuietZonesInModules(int &Left, int &Top, int &Right, int &Bottom);
	virtual void __fastcall CustomWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall ConfigWorkArea(Pcore2d::PCoreWorkArea &PWorkArea, Graphics::TCanvas* ACanvas, AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, int AModule, int ALeft, int ATop, int AAngle, bool AMirror = false, Pcore2d::TCustomPrintSizeMode APrintSizeMode = (Pcore2d::TCustomPrintSizeMode)(0x3), double APrintSizeValue = 0.000000E+00, int APrintSizeDPI = 0x0, double APrintDensityRate = 1.000000E+00, void * PCustomData = (void *)(0x0));
	virtual bool __fastcall VerifyChar(Pcore2d::PCoreWorkArea PWorkArea, int AIndex);
	virtual bool __fastcall LevelOneEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual bool __fastcall CalculateDimension(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall LevelTwoEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall GetSymbolZoneInModules(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	virtual void __fastcall GetQuietZonesInModules(Pcore2d::PCoreWorkArea PWorkArea, int &Left, int &Top, int &Right, int &Bottom);
	virtual void __fastcall FillinWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall InternalDraw(Pcore2d::PCoreWorkArea PWorkArea);
	
public:
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	HIDESBASE int __fastcall Print(double ALeft, double ATop, double AModule, double ALinearHeight, int AAngle = 0xffffffff, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00)/* overload */;
	HIDESBASE int __fastcall Print(AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, double ALeft, double ATop, double AModule, double ALinearHeight, int AAngle = 0x0, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00)/* overload */;
	HIDESBASE int __fastcall PrintSize(double &AWidth, double &AHeight, double AModule, double ALinearHeight, int AAngle = 0xffffffff, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00, int HDPI = 0x0, int VDPI = 0x0)/* overload */;
	HIDESBASE int __fastcall PrintSize(double &AWidth, double &AHeight, AnsiString ABarcode, bool AShowQuietZone, double AModule, double ALinearHeight, int AAngle = 0x0, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00, int HDPI = 0x0, int VDPI = 0x0)/* overload */;
	
__published:
	__property TCCC_StretchOrder StretchOrder = {read=FStretchOrder, write=SetStretchOrder, default=0};
	__property Classes::TComponent* Linear = {read=FLinear, write=SetLinear};
	__property TrailingQuietZone  = {default=0};
	__property TopQuietZone  = {default=0};
	__property BottomQuietZone  = {default=0};
public:
	#pragma option push -w-inl
	/* TBarcode2D_PDF417Custom.Create */ inline __fastcall virtual TBarcode2D_CCC(Classes::TComponent* Owner) : Ppdf417custom::TBarcode2D_PDF417Custom(Owner) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TBarcode2D_PDF417Custom.Destroy */ inline __fastcall virtual ~TBarcode2D_CCC(void) { }
	#pragma option pop
	
	
/* Hoisted overloads: */
	
public:
	inline int __fastcall  Print(double ALeft, double ATop, double AModule, int AAngle = 0xffffffff, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00){ return TBarcode2D::Print(ALeft, ATop, AModule, AAngle, ABarcodeWidth, ABarcodeHeight); }
	inline int __fastcall  Print(AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, double ALeft, double ATop, double AModule, int AAngle = 0x0, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00){ return TBarcode2D::Print(ABarcode, ABarColor, ASpaceColor, AShowQuietZone, ALeft, ATop, AModule, AAngle, ABarcodeWidth, ABarcodeHeight); }
	inline int __fastcall  PrintSize(double &AWidth, double &AHeight, double AModule, int AAngle = 0xffffffff, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00, int HDPI = 0x0, int VDPI = 0x0){ return TBarcode2D::PrintSize(AWidth, AHeight, AModule, AAngle, ABarcodeWidth, ABarcodeHeight, HDPI, VDPI); }
	inline int __fastcall  PrintSize(double &AWidth, double &AHeight, AnsiString ABarcode, bool AShowQuietZone, double AModule, int AAngle = 0x0, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00, int HDPI = 0x0, int VDPI = 0x0){ return TBarcode2D::PrintSize(AWidth, AHeight, ABarcode, AShowQuietZone, AModule, AAngle, ABarcodeWidth, ABarcodeHeight, HDPI, VDPI); }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Pccc */
using namespace Pccc;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pccc
