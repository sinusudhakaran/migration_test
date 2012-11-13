// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pmicropdf417.pas' rev: 11.00

#ifndef Pmicropdf417HPP
#define Pmicropdf417HPP

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
#include <Ppdf417com.hpp>	// Pascal unit
#include <Pcore2d.hpp>	// Pascal unit
#include <Pbarcode2d.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pmicropdf417
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TMicroPDF417_Size { mpSize_1_11, mpSize_1_14, mpSize_1_17, mpSize_1_20, mpSize_1_24, mpSize_1_28, mpSize_2_8, mpSize_2_11, mpSize_2_14, mpSize_2_17, mpSize_2_20, mpSize_2_23, mpSize_2_26, mpSize_3_6, mpSize_3_8, mpSize_3_10, mpSize_3_12, mpSize_3_15, mpSize_3_20, mpSize_3_26, mpSize_3_32, mpSize_3_38, mpSize_3_44, mpSize_4_4, mpSize_4_6, mpSize_4_8, mpSize_4_10, mpSize_4_12, mpSize_4_15, mpSize_4_20, mpSize_4_26, mpSize_4_32, mpSize_4_38, mpSize_4_44 };
#pragma option pop

#pragma option push -b-
enum TMicroPDF417_StretchOrder { soRowColumn, soColumnRow, soRowPrior, soColumnPrior, soGlobal_1, soGlobal_2, soGlobal_3, soGlobal_4 };
#pragma option pop

typedef Shortint TMicroPDF417_RowHeight;

typedef TPDF417_Options TMicroPDF417_Options;
;

typedef Ppdf417com::TPDF417_EncodeMode TMicroPDF417_EncodeMode;

typedef Ppdf417com::TPDF417_TextEncodeMode TMicroPDF417_TextEncodeMode;

class DELPHICLASS TBarcode2D_MicroPDF417;
class PASCALIMPLEMENTATION TBarcode2D_MicroPDF417 : public Pbarcode2d::TBarcode2D 
{
	typedef Pbarcode2d::TBarcode2D inherited;
	
private:
	TMicroPDF417_RowHeight FRowHeight;
	TMicroPDF417_Size FMinSize;
	TMicroPDF417_Size FMaxSize;
	TMicroPDF417_StretchOrder FStretchOrder;
	bool FAllowEscape;
	Ppdf417com::TPDF417_EncodeMode FDefaultEncodeMode;
	Ppdf417com::TPDF417_TextEncodeMode FDefaultTextEncodeMode;
	bool FUseECIDescriptor;
	Ppdf417com::TPDF417_Options FOptions;
	Ppdf417com::TReedSolomon* FReedSolomon;
	void __fastcall SetRowHeight(const TMicroPDF417_RowHeight Value);
	void __fastcall SetMinSize(const TMicroPDF417_Size Value);
	void __fastcall SetMaxSize(const TMicroPDF417_Size Value);
	void __fastcall SetStretchOrder(const TMicroPDF417_StretchOrder Value);
	void __fastcall SetAllowEscape(const bool Value);
	void __fastcall SetDefaultEncodeMode(const Ppdf417com::TPDF417_EncodeMode Value);
	void __fastcall SetDefaultTextEncodeMode(const Ppdf417com::TPDF417_TextEncodeMode Value);
	void __fastcall SetUseECIDescriptor(const bool Value);
	void __fastcall SetOptions(const Ppdf417com::TPDF417_Options Value);
	TMicroPDF417_Size __fastcall GetCurrentSize(void);
	void __fastcall GetRAPs(Pcore2d::PCoreWorkArea PWorkArea, Byte ARow, Word &ALeft, Word &ACenter, Word &ARight);
	
protected:
	virtual void __fastcall GetMinQuietZonesInModules(int &Left, int &Top, int &Right, int &Bottom);
	virtual void __fastcall GetSymbolZoneInModules(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	virtual void __fastcall ConfigWorkArea(Pcore2d::PCoreWorkArea &PWorkArea, Graphics::TCanvas* ACanvas, AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, int AModule, int ALeft, int ATop, int AAngle, bool AMirror = false, Pcore2d::TCustomPrintSizeMode APrintSizeMode = (Pcore2d::TCustomPrintSizeMode)(0x3), double APrintSizeValue = 0.000000E+00, int APrintSizeDPI = 0x0, double APrintDensityRate = 1.000000E+00, void * PCustomData = (void *)(0x0));
	virtual bool __fastcall VerifyLength(Pcore2d::PCoreWorkArea PWorkArea);
	virtual int __fastcall VerifyAllChars(Pcore2d::PCoreWorkArea PWorkArea);
	virtual void __fastcall CustomWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual bool __fastcall LevelOneEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual bool __fastcall CalculateDimension(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall LevelTwoEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall PlacementModules(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall DrawMatrixDot(Pcore2d::PCoreWorkArea PWorkArea, int LeftInModules, int TopInModules, bool Value);
	AnsiString __fastcall Encode(AnsiString ABarcode, int &AInvalidIndex, bool IsFirstMarcoBlock);
	
public:
	__fastcall virtual TBarcode2D_MicroPDF417(Classes::TComponent* Owner);
	__fastcall virtual ~TBarcode2D_MicroPDF417(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	AnsiString __fastcall GetCheckSum(AnsiString ABarcode, bool AAllowEscape, int &AInvalidIndex, Ppdf417com::TPDF417_Options AOptions = Ppdf417com::TPDF417_Options() );
	__property TMicroPDF417_Size CurrentSize = {read=GetCurrentSize, nodefault};
	
__published:
	__property TMicroPDF417_RowHeight RowHeight = {read=FRowHeight, write=SetRowHeight, default=3};
	__property TMicroPDF417_Size MinSize = {read=FMinSize, write=SetMinSize, default=0};
	__property TMicroPDF417_Size MaxSize = {read=FMaxSize, write=SetMaxSize, default=33};
	__property TMicroPDF417_StretchOrder StretchOrder = {read=FStretchOrder, write=SetStretchOrder, default=2};
	__property bool AllowEscape = {read=FAllowEscape, write=SetAllowEscape, default=0};
	__property Ppdf417com::TPDF417_EncodeMode DefaultEncodeMode = {read=FDefaultEncodeMode, write=SetDefaultEncodeMode, default=3};
	__property Ppdf417com::TPDF417_TextEncodeMode DefaultTextEncodeMode = {read=FDefaultTextEncodeMode, write=SetDefaultTextEncodeMode, default=1};
	__property bool UseECIDescriptor = {read=FUseECIDescriptor, write=SetUseECIDescriptor, default=0};
	__property Ppdf417com::TPDF417_Options Options = {read=FOptions, write=SetOptions, default=0};
	__property Mirrored  = {default=0};
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Pmicropdf417 */
using namespace Pmicropdf417;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pmicropdf417
