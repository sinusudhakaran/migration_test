// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Prssexpanded.pas' rev: 11.00

#ifndef PrssexpandedHPP
#define PrssexpandedHPP

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
#include <Prsscom.hpp>	// Pascal unit
#include <Pucccom.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Prssexpanded
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TRSSExpanded_Style { rsStandard, rsStacked };
#pragma option pop

#pragma pack(push,4)
struct TRSSExpanded_CustomArea
{
	
public:
	int TotalBits;
	int PadBits;
	Pucccom::TUCC_EncodeMode LastMode;
	int SymbolsBitsIndex;
	int DataSymbols_Number;
} ;
#pragma pack(pop)

class DELPHICLASS TBarcode2D_RSSExpanded;
class PASCALIMPLEMENTATION TBarcode2D_RSSExpanded : public Pbarcode2d::TBarcode2D 
{
	typedef Pbarcode2d::TBarcode2D inherited;
	
__published:
	void __fastcall SetOnChangeForComposite(const Classes::TNotifyEvent AClear, const Classes::TNotifyEvent AChange);
	
private:
	TRSSExpanded_Style FStyle;
	Byte FRowSymbols;
	int FRowHeight;
	int FSeparatorRowHeight;
	bool FLink2D;
	bool FShow2DSeparator;
	Classes::TNotifyEvent FOnClearForComposite;
	Classes::TNotifyEvent FOnChangeForComposite;
	void __fastcall SetLink2D(const bool Value);
	void __fastcall SetShow2DSeparator(const bool Value);
	void __fastcall SetRowSymbols(const Byte Value);
	void __fastcall SetRowHeight(const int Value);
	void __fastcall SetStyle(const TRSSExpanded_Style Value);
	void __fastcall SetSeparatorRowHeight(const int Value);
	
protected:
	virtual void __fastcall GetMinQuietZonesInModules(int &Left, int &Top, int &Right, int &Bottom);
	virtual void __fastcall GetSymbolZoneInModules(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	virtual bool __fastcall VerifyLength(Pcore2d::PCoreWorkArea PWorkArea);
	virtual bool __fastcall VerifyChar(Pcore2d::PCoreWorkArea PWorkArea, int AIndex);
	virtual void __fastcall CustomWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual bool __fastcall LevelOneEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual bool __fastcall CalculateDimension(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall LevelTwoEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall PlacementModules(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall InternalDraw(Pcore2d::PCoreWorkArea PWorkArea);
	void __fastcall EncodeSymbolBits(PDWORD AEncoded, int ATotalBits, int AIndex);
	bool __fastcall EncodeData(AnsiString ABarcode, bool ALink2DFlag, PDWORD AEncoded, Pucccom::TUCC_EncodeMode &ALastMode, int &ADstIndex, int &ATotalBits, int &APadBits, int &ASymbolBitsIndex, int &AInvalidIndex);
	virtual void __fastcall DoChange(bool ExecuteOnChange = false);
	void __fastcall DoClearForComposite(void);
	void __fastcall DoChangeForComposite(void);
	virtual int __fastcall InternalClear(bool CheckLocked, bool UseSpaceColor, bool ForCompoSite = false);
	
public:
	__fastcall virtual TBarcode2D_RSSExpanded(Classes::TComponent* Owner);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property TRSSExpanded_Style Style = {read=FStyle, write=SetStyle, default=0};
	__property Byte RowSymbols = {read=FRowSymbols, write=SetRowSymbols, default=4};
	__property int RowHeight = {read=FRowHeight, write=SetRowHeight, default=33};
	__property int SeparatorRowHeight = {read=FSeparatorRowHeight, write=SetSeparatorRowHeight, default=1};
	__property bool Link2D = {read=FLink2D, write=SetLink2D, default=0};
	__property bool Show2DSeparator = {read=FShow2DSeparator, write=SetShow2DSeparator, default=0};
	__property LeadingQuietZone  = {default=0};
	__property TopQuietZone  = {default=0};
	__property TrailingQuietZone  = {default=0};
	__property BottomQuietZone  = {default=0};
public:
	#pragma option push -w-inl
	/* TBarcode2D.Destroy */ inline __fastcall virtual ~TBarcode2D_RSSExpanded(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Prssexpanded */
using namespace Prssexpanded;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Prssexpanded
