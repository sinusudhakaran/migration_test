// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pcccustom.pas' rev: 11.00

#ifndef PcccustomHPP
#define PcccustomHPP

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
#include <Ppdf417com.hpp>	// Pascal unit
#include <Pcore2d.hpp>	// Pascal unit
#include <Pbarcode2d.hpp>	// Pascal unit
#include <Pucccom.hpp>	// Pascal unit
#include <Pcccom.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pcccustom
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TCCX_SeparatorStyle { cssNone, cssUPC_E, cssEAN_8, cssUPC_A, cssEAN_13 };
#pragma option pop

#pragma pack(push,4)
struct TCCX_Profile
{
	
public:
	int Sizes_Count;
	int MaxBarcodeLen;
	int MaxSemiWords;
	int MinTotalBits;
	int MaxTotalBits;
	Byte PatternColsNum[3];
	Byte DataColsMap[3][4];
	Byte Sepeator_Pos[4][2];
} ;
#pragma pack(pop)

typedef TCCX_Profile *PCCX_Profile;

typedef Shortint TCCX_RowHeight;

struct TCCX_CustomArea
{
	
public:
	Byte Current_Size;
	int TotalDataBits;
	int TotalSemiWords;
	Pucccom::TUCC_EncodeMode LastMode;
	int LinearWidth;
	int LinearHeight;
	int LinearLeft;
	int LinearTop;
	int LeftSpacing;
	int RightSpacing;
	int LinearSymbolLeftZone;
	int LinearSymbolRightZone;
	int LinearOffset;
	double LinearPrintHeight;
} ;

typedef TCCX_CustomArea *PCCXCustomArea;

class DELPHICLASS TBarcode2D_CCCustom;
class PASCALIMPLEMENTATION TBarcode2D_CCCustom : public Pbarcode2d::TBarcode2D 
{
	typedef Pbarcode2d::TBarcode2D inherited;
	
private:
	TCCX_RowHeight FRowHeight;
	Classes::TComponent* FLinear;
	Byte FMinSize;
	Byte FMaxSize;
	void __fastcall SetRowHeight(const TCCX_RowHeight Value);
	void __fastcall SetLinear(const Classes::TComponent* Value);
	void __fastcall SetMinSize(const Byte Value);
	void __fastcall SetMaxSize(const Byte Value);
	void __fastcall LinearClear(System::TObject* Sender);
	void __fastcall LinearChanged(System::TObject* Sender);
	bool __fastcall Is_1D_Linear(Classes::TComponent* ALinear = (Classes::TComponent*)(0x0));
	
protected:
	TCCX_Profile *FProfile;
	Ppdf417com::TReedSolomon* FReedSolomon;
	virtual void __fastcall DoInvalidLength(AnsiString ABarcode, bool LinearFlag = false);
	virtual void __fastcall DoInvalidChar(AnsiString ABarcode, int Index);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual int __fastcall GetMaxDataBits(Byte Size) = 0 ;
	virtual int __fastcall GetRowsNumber(Byte Size) = 0 ;
	virtual int __fastcall GetDataColsNum(bool SpecifyLinear = false, Classes::TComponent* ALinear = (Classes::TComponent*)(0x0));
	TCCX_SeparatorStyle __fastcall ShowSeparator(bool SpecifyLinear = false, Classes::TComponent* ALinear = (Classes::TComponent*)(0x0));
	virtual void __fastcall GetSizeRange(Byte &AMinSize, Byte &AMaxSize);
	virtual void __fastcall GetRAPs(Pcore2d::PCoreWorkArea PWorkArea, Byte ARow, Word &ALeft, Word &ACenter, Word &ARight) = 0 ;
	virtual void __fastcall PlacementRAPs(Pcore2d::PCoreWorkArea PWorkArea, int ARow, Word * ADataMatrix, const int ADataMatrix_Size) = 0 ;
	virtual Word __fastcall GetDataWordBars(Word * ADataMatrix, const int ADataMatrix_Size, Byte ARow, Byte AColumn) = 0 ;
	virtual void __fastcall GetMinQuietZonesInModules(int &Left, int &Top, int &Right, int &Bottom);
	void __fastcall GetQuietZonesSpacings(int &ALeft, int &ARight);
	virtual void __fastcall GetSymbolZoneInModules(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	virtual bool __fastcall VerifyChar(Pcore2d::PCoreWorkArea PWorkArea, int AIndex);
	virtual bool __fastcall VerifyLength(Pcore2d::PCoreWorkArea PWorkArea);
	virtual void __fastcall CustomWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual bool __fastcall LevelOneEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual bool __fastcall CalculateDimension(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall PlacementModules(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall DrawMatrixDot(Pcore2d::PCoreWorkArea PWorkArea, int LeftInModules, int TopInModules, bool Value);
	virtual void __fastcall InternalDraw(Pcore2d::PCoreWorkArea PWorkArea);
	virtual void __fastcall GetQuietZonesInModules(Pcore2d::PCoreWorkArea PWorkArea, int &Left, int &Top, int &Right, int &Bottom);
	__property Byte MinSize = {read=FMinSize, write=SetMinSize, default=0};
	__property Byte MaxSize = {read=FMaxSize, write=SetMaxSize, nodefault};
	virtual void __fastcall ConfigWorkArea(Pcore2d::PCoreWorkArea &PWorkArea, Graphics::TCanvas* ACanvas, AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, int AModule, int ALeft, int ATop, int AAngle, bool AMirror = false, Pcore2d::TCustomPrintSizeMode APrintSizeMode = (Pcore2d::TCustomPrintSizeMode)(0x3), double APrintSizeValue = 0.000000E+00, int APrintSizeDPI = 0x0, double APrintDensityRate = 1.000000E+00, void * PCustomData = (void *)(0x0));
	virtual void __fastcall FillinWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	
public:
	__fastcall virtual TBarcode2D_CCCustom(Classes::TComponent* Owner);
	__fastcall virtual ~TBarcode2D_CCCustom(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	HIDESBASE int __fastcall Print(double ALeft, double ATop, double AModule, double ALinearHeight, int AAngle = 0xffffffff, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00)/* overload */;
	HIDESBASE int __fastcall Print(AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, double ALeft, double ATop, double AModule, double ALinearHeight, int AAngle = 0x0, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00)/* overload */;
	HIDESBASE int __fastcall PrintSize(double &AWidth, double &AHeight, double AModule, double ALinearHeight, int AAngle = 0xffffffff, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00, int HDPI = 0x0, int VDPI = 0x0)/* overload */;
	HIDESBASE int __fastcall PrintSize(double &AWidth, double &AHeight, AnsiString ABarcode, bool AShowQuietZone, double AModule, double ALinearHeight, int AAngle = 0x0, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00, int HDPI = 0x0, int VDPI = 0x0)/* overload */;
	
__published:
	__property TCCX_RowHeight RowHeight = {read=FRowHeight, write=SetRowHeight, default=2};
	__property Classes::TComponent* Linear = {read=FLinear, write=SetLinear};
	__property LeadingQuietZone  = {default=0};
	__property TopQuietZone  = {default=0};
	__property TrailingQuietZone  = {default=0};
	__property BottomQuietZone  = {default=0};
	
/* Hoisted overloads: */
	
public:
	inline int __fastcall  Print(double ALeft, double ATop, double AModule, int AAngle = 0xffffffff, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00){ return TBarcode2D::Print(ALeft, ATop, AModule, AAngle, ABarcodeWidth, ABarcodeHeight); }
	inline int __fastcall  Print(AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, double ALeft, double ATop, double AModule, int AAngle = 0x0, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00){ return TBarcode2D::Print(ABarcode, ABarColor, ASpaceColor, AShowQuietZone, ALeft, ATop, AModule, AAngle, ABarcodeWidth, ABarcodeHeight); }
	inline int __fastcall  PrintSize(double &AWidth, double &AHeight, double AModule, int AAngle = 0xffffffff, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00, int HDPI = 0x0, int VDPI = 0x0){ return TBarcode2D::PrintSize(AWidth, AHeight, AModule, AAngle, ABarcodeWidth, ABarcodeHeight, HDPI, VDPI); }
	inline int __fastcall  PrintSize(double &AWidth, double &AHeight, AnsiString ABarcode, bool AShowQuietZone, double AModule, int AAngle = 0x0, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00, int HDPI = 0x0, int VDPI = 0x0){ return TBarcode2D::PrintSize(AWidth, AHeight, ABarcode, AShowQuietZone, AModule, AAngle, ABarcodeWidth, ABarcodeHeight, HDPI, VDPI); }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Pcccustom */
using namespace Pcccustom;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pcccustom
