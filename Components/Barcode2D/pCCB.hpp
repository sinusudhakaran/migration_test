// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pccb.pas' rev: 11.00

#ifndef PccbHPP
#define PccbHPP

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
#include <Typinfo.hpp>	// Pascal unit
#include <Pcommon2d.hpp>	// Pascal unit
#include <Ppdf417com.hpp>	// Pascal unit
#include <Pcore2d.hpp>	// Pascal unit
#include <Pbarcode2d.hpp>	// Pascal unit
#include <Pcccom.hpp>	// Pascal unit
#include <Pcccustom.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pccb
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TCCB_Rows { ccbRow_4, ccbRow_6, ccbRow_8, ccbRow_10, ccbRow_11, ccbRow_12, ccbRow_14, ccbRow_15, ccbRow_17, ccbRow_20, ccbRow_23, ccbRow_26, ccbRow_32, ccbRow_38, ccbRow_44 };
#pragma option pop

class DELPHICLASS TBarcode2D_CCB;
class PASCALIMPLEMENTATION TBarcode2D_CCB : public Pcccustom::TBarcode2D_CCCustom 
{
	typedef Pcccustom::TBarcode2D_CCCustom inherited;
	
private:
	void __fastcall SetMinRows(const TCCB_Rows Value);
	TCCB_Rows __fastcall GetMinRows(void);
	void __fastcall SetMaxRows(const TCCB_Rows Value);
	TCCB_Rows __fastcall GetMaxRows(void);
	TCCB_Rows __fastcall GetCurrentRows(void);
	
protected:
	virtual void __fastcall GetSymbolZoneInModules(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	virtual void __fastcall CustomWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall LevelTwoEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual int __fastcall GetMaxDataBits(Byte Size);
	virtual int __fastcall GetRowsNumber(Byte Size);
	virtual void __fastcall GetSizeRange(Byte &AMinSize, Byte &AMaxSize);
	virtual void __fastcall GetRAPs(Pcore2d::PCoreWorkArea PWorkArea, Byte ARow, Word &ALeft, Word &ACenter, Word &ARight);
	virtual void __fastcall PlacementRAPs(Pcore2d::PCoreWorkArea PWorkArea, int ARow, Word * ADataMatrix, const int ADataMatrix_Size);
	virtual Word __fastcall GetDataWordBars(Word * ADataMatrix, const int ADataMatrix_Size, Byte ARow, Byte AColumn);
	
public:
	__fastcall virtual TBarcode2D_CCB(Classes::TComponent* Owner);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property TCCB_Rows CurrentRows = {read=GetCurrentRows, nodefault};
	
__published:
	__property TCCB_Rows MinRows = {read=GetMinRows, write=SetMinRows, default=0};
	__property TCCB_Rows MaxRows = {read=GetMaxRows, write=SetMaxRows, default=14};
public:
	#pragma option push -w-inl
	/* TBarcode2D_CCCustom.Destroy */ inline __fastcall virtual ~TBarcode2D_CCB(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Pccb */
using namespace Pccb;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pccb
