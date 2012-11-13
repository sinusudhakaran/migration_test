// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Ppdf417custom.pas' rev: 11.00

#ifndef Ppdf417customHPP
#define Ppdf417customHPP

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

//-- user supplied -----------------------------------------------------------

namespace Ppdf417custom
{
//-- type declarations -------------------------------------------------------
typedef Shortint TPDF417_Rows;

typedef Shortint TPDF417_Columns;

typedef Shortint TPDF417_RowHeight;

#pragma option push -b-
enum TPDF417_EccLevel { elEcc_0, elEcc_1, elEcc_2, elEcc_3, elEcc_4, elEcc_5, elEcc_6, elEcc_7, elEcc_8, elEcc_Auto };
#pragma option pop

#pragma pack(push,1)
struct TPDF417_CustomAreaHead
{
	
public:
	TPDF417_Rows Current_Rows;
	TPDF417_Columns Current_Columns;
	TPDF417_EccLevel Current_EccLevel;
} ;
#pragma pack(pop)

typedef TPDF417_CustomAreaHead *PPDF417CustomAreaHead;

class DELPHICLASS TBarcode2D_PDF417Custom;
class PASCALIMPLEMENTATION TBarcode2D_PDF417Custom : public Pbarcode2d::TBarcode2D 
{
	typedef Pbarcode2d::TBarcode2D inherited;
	
private:
	TPDF417_Rows FMinRows;
	TPDF417_Rows FMaxRows;
	TPDF417_Columns FMinColumns;
	TPDF417_Columns FMaxColumns;
	TPDF417_EccLevel FEccLevel;
	bool FEccLevelUpgrade;
	TPDF417_RowHeight FRowHeight;
	void __fastcall SetMinRows(const TPDF417_Rows Value);
	void __fastcall SetMinColumns(const TPDF417_Columns Value);
	void __fastcall SetMaxRows(const TPDF417_Rows Value);
	void __fastcall SetMaxColumns(const TPDF417_Columns Value);
	void __fastcall SetEccLevel(const TPDF417_EccLevel Value);
	void __fastcall SetEccLevelUpgrade(const bool Value);
	void __fastcall SetRowHeight(const TPDF417_RowHeight Value);
	TPDF417_Rows __fastcall GetCurrentRows(void);
	TPDF417_Columns __fastcall GetCurrentColumns(void);
	TPDF417_EccLevel __fastcall GetCurrentEccLevel(void);
	
protected:
	bool FCompact;
	Ppdf417com::TReedSolomon* FReedSolomon;
	virtual void __fastcall SetCompact(const bool Value);
	virtual void __fastcall GetMinQuietZonesInModules(int &Left, int &Top, int &Right, int &Bottom);
	virtual void __fastcall GetSymbolZoneInModules(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	virtual void __fastcall CustomWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall PlacementModules(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall DrawMatrixDot(Pcore2d::PCoreWorkArea PWorkArea, int LeftInModules, int TopInModules, bool Value);
	TPDF417_EccLevel __fastcall GetAutoEccLevel(int ADataWordsNum);
	void __fastcall GetRowIndicators(Pcore2d::PCoreWorkArea PWorkArea, Byte ARow, Word &ALeft, Word &ARight);
	
public:
	__fastcall virtual TBarcode2D_PDF417Custom(Classes::TComponent* Owner);
	__fastcall virtual ~TBarcode2D_PDF417Custom(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property TPDF417_Rows CurrentRows = {read=GetCurrentRows, nodefault};
	__property TPDF417_Columns CurrentColumns = {read=GetCurrentColumns, nodefault};
	__property TPDF417_EccLevel CurrentEccLevel = {read=GetCurrentEccLevel, nodefault};
	
__published:
	__property TPDF417_Rows MinRows = {read=FMinRows, write=SetMinRows, default=3};
	__property TPDF417_Columns MinColumns = {read=FMinColumns, write=SetMinColumns, default=1};
	__property TPDF417_Rows MaxRows = {read=FMaxRows, write=SetMaxRows, default=90};
	__property TPDF417_Columns MaxColumns = {read=FMaxColumns, write=SetMaxColumns, default=30};
	__property TPDF417_EccLevel EccLevel = {read=FEccLevel, write=SetEccLevel, default=0};
	__property bool EccLevelUpgrade = {read=FEccLevelUpgrade, write=SetEccLevelUpgrade, default=1};
	__property TPDF417_RowHeight RowHeight = {read=FRowHeight, write=SetRowHeight, default=3};
	__property bool Compact = {read=FCompact, write=SetCompact, default=0};
	__property LeadingQuietZone  = {default=2};
	__property TopQuietZone  = {default=2};
	__property TrailingQuietZone  = {default=2};
	__property BottomQuietZone  = {default=2};
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Ppdf417custom */
using namespace Ppdf417custom;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Ppdf417custom
