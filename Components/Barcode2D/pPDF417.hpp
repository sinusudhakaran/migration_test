// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Ppdf417.pas' rev: 11.00

#ifndef Ppdf417HPP
#define Ppdf417HPP

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
#include <Ppdf417com.hpp>	// Pascal unit
#include <Ppdf417custom.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Ppdf417
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TPDF417_StretchOrder { soRowColumn, soColumnRow, soFixAspect, soFixAspectWithQuietZones };
#pragma option pop

#pragma pack(push,1)
struct TPDF417_CustomArea
{
	
public:
	Ppdf417custom::TPDF417_Rows Current_Rows;
	Ppdf417custom::TPDF417_Columns Current_Columns;
	Ppdf417custom::TPDF417_EccLevel Current_EccLevel;
	int InvalidEscapeIndex;
	int BarcodeCharsNumber;
	int EscapeWordsNumber;
} ;
#pragma pack(pop)

typedef TPDF417_CustomArea *PPDF417CustomArea;

class DELPHICLASS TBarcode2D_PDF417;
class PASCALIMPLEMENTATION TBarcode2D_PDF417 : public Ppdf417custom::TBarcode2D_PDF417Custom 
{
	typedef Ppdf417custom::TBarcode2D_PDF417Custom inherited;
	
private:
	TPDF417_StretchOrder FStretchOrder;
	bool FAllowEscape;
	Ppdf417com::TPDF417_Options FOptions;
	void __fastcall SetStretchOrder(const TPDF417_StretchOrder Value);
	void __fastcall SetAllowEscape(const bool Value);
	void __fastcall SetOptions(const Ppdf417com::TPDF417_Options Value);
	bool __fastcall GetAspectSize(int ADataWordsNum, int ALeft, int ATop, int ARight, int ABottom, Ppdf417custom::TPDF417_Rows &ARow, Ppdf417custom::TPDF417_Columns &ACol);
	
protected:
	virtual void __fastcall SetCompact(const bool Value);
	virtual void __fastcall CustomWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall ConfigWorkArea(Pcore2d::PCoreWorkArea &PWorkArea, Graphics::TCanvas* ACanvas, AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, int AModule, int ALeft, int ATop, int AAngle, bool AMirror = false, Pcore2d::TCustomPrintSizeMode APrintSizeMode = (Pcore2d::TCustomPrintSizeMode)(0x3), double APrintSizeValue = 0.000000E+00, int APrintSizeDPI = 0x0, double APrintDensityRate = 1.000000E+00, void * PCustomData = (void *)(0x0));
	virtual bool __fastcall VerifyLength(Pcore2d::PCoreWorkArea PWorkArea);
	virtual int __fastcall VerifyAllChars(Pcore2d::PCoreWorkArea PWorkArea);
	virtual bool __fastcall LevelOneEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual bool __fastcall CalculateDimension(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall LevelTwoEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	AnsiString __fastcall Encode(AnsiString ABarcode, int &AInvalidIndex);
	
public:
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	AnsiString __fastcall GetCheckSum(AnsiString ABarcode, bool AAllowEscape, int &AInvalidIndex, Ppdf417com::TPDF417_Options AOptions = Ppdf417com::TPDF417_Options() );
	
__published:
	__property TPDF417_StretchOrder StretchOrder = {read=FStretchOrder, write=SetStretchOrder, default=0};
	__property bool AllowEscape = {read=FAllowEscape, write=SetAllowEscape, default=0};
	__property Ppdf417com::TPDF417_Options Options = {read=FOptions, write=SetOptions, default=0};
	__property Mirrored  = {default=0};
public:
	#pragma option push -w-inl
	/* TBarcode2D_PDF417Custom.Create */ inline __fastcall virtual TBarcode2D_PDF417(Classes::TComponent* Owner) : Ppdf417custom::TBarcode2D_PDF417Custom(Owner) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TBarcode2D_PDF417Custom.Destroy */ inline __fastcall virtual ~TBarcode2D_PDF417(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Ppdf417 */
using namespace Ppdf417;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Ppdf417
