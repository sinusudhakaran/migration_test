// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Prsslimited.pas' rev: 11.00

#ifndef PrsslimitedHPP
#define PrsslimitedHPP

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
#include <Prsscom.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Prsslimited
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TBarcode2D_RSSLimited;
class PASCALIMPLEMENTATION TBarcode2D_RSSLimited : public Pbarcode2d::TBarcode2D 
{
	typedef Pbarcode2d::TBarcode2D inherited;
	
__published:
	void __fastcall SetOnChangeForComposite(const Classes::TNotifyEvent AClear, const Classes::TNotifyEvent AChange);
	
private:
	int FTotalHeight;
	bool FLink2D;
	bool FShow2DSeparator;
	int FSeparatorRowHeight;
	bool FAutoCheckDigit;
	Classes::TNotifyEvent FOnClearForComposite;
	Classes::TNotifyEvent FOnChangeForComposite;
	void __fastcall SetTotalHeight(const int Value);
	void __fastcall SetLink2D(const bool Value);
	void __fastcall SetShow2DSeparator(const bool Value);
	void __fastcall SetSeparatorRowHeight(const int Value);
	void __fastcall SetAutoCheckDigit(const bool Value);
	
protected:
	virtual bool __fastcall VerifyLength(Pcore2d::PCoreWorkArea PWorkArea);
	virtual bool __fastcall VerifyChar(Pcore2d::PCoreWorkArea PWorkArea, int Index);
	virtual void __fastcall GetMinQuietZonesInModules(int &Left, int &Top, int &Right, int &Bottom);
	virtual void __fastcall GetSymbolZoneInModules(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	AnsiString __fastcall GetChekSumPatterns(AnsiString ALeftPatterns, AnsiString ARightPatterns);
	virtual void __fastcall LevelTwoEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall PlacementMapMatrix(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall PlacementModules(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall InternalDraw(Pcore2d::PCoreWorkArea PWorkArea);
	virtual void __fastcall DoChange(bool ExecuteOnChange = false);
	void __fastcall DoClearForComposite(void);
	void __fastcall DoChangeForComposite(void);
	virtual int __fastcall InternalClear(bool CheckLocked, bool UseSpaceColor, bool ForCompoSite = false);
	
public:
	__fastcall virtual TBarcode2D_RSSLimited(Classes::TComponent* Owner);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property int TotalHeight = {read=FTotalHeight, write=SetTotalHeight, default=10};
	__property bool Link2D = {read=FLink2D, write=SetLink2D, default=0};
	__property bool Show2DSeparator = {read=FShow2DSeparator, write=SetShow2DSeparator, default=0};
	__property int SeparatorRowHeight = {read=FSeparatorRowHeight, write=SetSeparatorRowHeight, default=1};
	__property bool AutoCheckDigit = {read=FAutoCheckDigit, write=SetAutoCheckDigit, default=0};
	__property LeadingQuietZone  = {default=0};
	__property TopQuietZone  = {default=0};
	__property TrailingQuietZone  = {default=0};
	__property BottomQuietZone  = {default=0};
public:
	#pragma option push -w-inl
	/* TBarcode2D.Destroy */ inline __fastcall virtual ~TBarcode2D_RSSLimited(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Prsslimited */
using namespace Prsslimited;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Prsslimited
