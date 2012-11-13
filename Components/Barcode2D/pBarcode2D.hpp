// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pbarcode2d.pas' rev: 11.00

#ifndef Pbarcode2dHPP
#define Pbarcode2dHPP

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
#include <Extctrls.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Math.hpp>	// Pascal unit
#include <Printers.hpp>	// Pascal unit
#include <Typinfo.hpp>	// Pascal unit
#include <Pcore2d.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pbarcode2d
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TBarcodeOrientation { boLeftRight, boRightLeft, boTopBottom, boBottomTop };
#pragma option pop

struct TUserWorkArea
{
	
public:
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
	AnsiString WAnsiBarcode;
	int WBarcodeLength;
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
} ;

typedef TUserWorkArea *PUserWorkArea;

typedef void __fastcall (__closure *TOnInvalidChar)(System::TObject* Sender, int Index, char AnsiBarcodeChar, int OriginalIndex, char OriginalBarcodeChar, bool LinearFlag);

typedef void __fastcall (__closure *TOnInvalidLength)(System::TObject* Sender, AnsiString Barcode, bool LinearFlag);

typedef void __fastcall (__closure *TOnDrawBarcode)(System::TObject* Sender, Graphics::TCanvas* Canvas, PUserWorkArea PWorkArea);

class DELPHICLASS TBarcode2D;
class PASCALIMPLEMENTATION TBarcode2D : public Pcore2d::TBarcodeCore2D 
{
	typedef Pcore2d::TBarcodeCore2D inherited;
	
private:
	AnsiString FBarcode;
	Graphics::TColor FBarColor;
	Graphics::TColor FSpaceColor;
	bool FInversed;
	bool FMirrored;
	TBarcodeOrientation FOrientation;
	bool FShowQuietZone;
	int FLeadingQuietZone;
	int FTopQuietZone;
	int FTrailingQuietZone;
	int FBottomQuietZone;
	bool FStretch;
	int FLeftMargin;
	int FTopMargin;
	int FBarcodeWidth;
	int FBarcodeHeight;
	bool FLocked;
	#pragma pack(push,1)
	Types::TRect FLockedRect;
	#pragma pack(pop)
	Classes::TNotifyEvent FOnChange;
	Classes::TNotifyEvent FOnChangeToUpdateDatabase;
	TOnInvalidChar FOnInvalidChar;
	TOnInvalidLength FOnInvalidLength;
	TOnDrawBarcode FOnDrawBarcode;
	Controls::TControl* FImage;
	void __fastcall SetImage(const Controls::TControl* Value);
	void __fastcall SetBarcode(const AnsiString Value);
	void __fastcall SetModule(const int Value);
	void __fastcall SetBarColor(const Graphics::TColor Value);
	void __fastcall SetSpaceColor(const Graphics::TColor Value);
	void __fastcall SetInversed(const bool Value);
	void __fastcall SetMirrored(const bool Value);
	void __fastcall SetOrientation(const TBarcodeOrientation Value);
	void __fastcall SetShowQuietZone(const bool Value);
	void __fastcall SetLeadingQuietZone(const int Value);
	void __fastcall SetTopQuietZone(const int Value);
	void __fastcall SetTrailingQuietZone(const int Value);
	void __fastcall SetBottomQuietZone(const int Value);
	void __fastcall SetStretch(const bool Value);
	void __fastcall SetLeftMargin(const int Value);
	void __fastcall SetTopMargin(const int Value);
	void __fastcall SetBarcodeWidth(const int Value);
	void __fastcall SetBarcodeHeight(const int Value);
	void __fastcall SetLocked(const bool Value);
	void __fastcall DoAfterDrawBarcode(Pcore2d::PCoreWorkArea PWorkArea);
	Graphics::TCanvas* __fastcall GetCanvas(void);
	
protected:
	int FModule;
	Pcore2d::TCoreWorkArea *FPWorkArea;
	virtual void __fastcall Loaded(void);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	int __fastcall GetAngleInDegree(void);
	virtual void __fastcall GetMinQuietZonesInModules(int &Left, int &Top, int &Right, int &Bottom) = 0 ;
	virtual void __fastcall GetQuietZonesInModules(Pcore2d::PCoreWorkArea PWorkArea, int &Left, int &Top, int &Right, int &Bottom);
	int __fastcall GetSizeInPixels(int &ADefaultWidth, int &ADefaultHeight, int &AStretchWidth, int &AStretchHeight, Graphics::TCanvas* ACanvas);
	int __fastcall InternalDrawTo(Graphics::TCanvas* Canvas, int ALeft, int ATop, int AModule = 0x0, int AAngle = 0xffffffff, Pcore2d::TCustomPrintSizeMode APrintSizeMode = (Pcore2d::TCustomPrintSizeMode)(0x3), double APrintSizeValue = 0.000000E+00, double APrintDensityRate = 1.000000E+00, void * PCustomData = (void *)(0x0))/* overload */;
	virtual void __fastcall DoInvalidLength(AnsiString ABarcode, bool LinearFlag = false);
	virtual void __fastcall DoInvalidChar(AnsiString ABarcode, int Index);
	virtual void __fastcall DoChange(bool ExecuteOnChange = false);
	virtual int __fastcall InternalClear(bool CheckLocked, bool UseSpaceColor, bool ForCompoSite = false);
	virtual void __fastcall InternalDraw(Pcore2d::PCoreWorkArea PWorkArea);
	__property Classes::TNotifyEvent OnChangeToUpdateDatabase = {read=FOnChangeToUpdateDatabase, write=FOnChangeToUpdateDatabase};
	__property bool Inversed = {read=FInversed, write=SetInversed, default=0};
	__property bool Mirrored = {read=FMirrored, write=SetMirrored, default=0};
	
public:
	__fastcall virtual TBarcode2D(Classes::TComponent* Owner);
	__fastcall virtual ~TBarcode2D(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	void __fastcall Clear(bool UseSpaceColor = false);
	void __fastcall Draw(void);
	void __fastcall Size(int &ABarcodeWidth, int &ABarcodeHeight);
	int __fastcall DrawToSize(int &AWidth, int &AHeight, int AModule = 0x0, int AAngle = 0xffffffff, Graphics::TCanvas* ACanvas = (Graphics::TCanvas*)(0x0))/* overload */;
	int __fastcall DrawToSize(int &AWidth, int &AHeight, AnsiString ABarcode, bool AShowQuietZone, int AModule, int AAngle = 0x0, Graphics::TCanvas* ACanvas = (Graphics::TCanvas*)(0x0))/* overload */;
	int __fastcall DrawTo(Graphics::TCanvas* Canvas, int ALeft, int ATop, int AModule = 0x0, int AAngle = 0xffffffff)/* overload */;
	int __fastcall DrawTo(Graphics::TCanvas* ACanvas, AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, int ALeft, int ATop, int AModule, int AAngle = 0x0)/* overload */;
	int __fastcall Print(double ALeft, double ATop, double AModule, int AAngle = 0xffffffff, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00)/* overload */;
	int __fastcall Print(AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, double ALeft, double ATop, double AModule, int AAngle = 0x0, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00)/* overload */;
	int __fastcall PrintSize(double &AWidth, double &AHeight, double AModule, int AAngle = 0xffffffff, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00, int HDPI = 0x0, int VDPI = 0x0)/* overload */;
	int __fastcall PrintSize(double &AWidth, double &AHeight, AnsiString ABarcode, bool AShowQuietZone, double AModule, int AAngle = 0x0, double ABarcodeWidth = 0.000000E+00, double ABarcodeHeight = 0.000000E+00, int HDPI = 0x0, int VDPI = 0x0)/* overload */;
	
__published:
	__property Controls::TControl* Image = {read=FImage, write=SetImage};
	__property AnsiString Barcode = {read=FBarcode, write=SetBarcode};
	__property int Module = {read=FModule, write=SetModule, default=1};
	__property Graphics::TColor BarColor = {read=FBarColor, write=SetBarColor, default=0};
	__property Graphics::TColor SpaceColor = {read=FSpaceColor, write=SetSpaceColor, default=16777215};
	__property TBarcodeOrientation Orientation = {read=FOrientation, write=SetOrientation, default=0};
	__property bool Stretch = {read=FStretch, write=SetStretch, default=0};
	__property int LeftMargin = {read=FLeftMargin, write=SetLeftMargin, default=0};
	__property int TopMargin = {read=FTopMargin, write=SetTopMargin, default=0};
	__property int BarcodeWidth = {read=FBarcodeWidth, write=SetBarcodeWidth, default=0};
	__property int BarcodeHeight = {read=FBarcodeHeight, write=SetBarcodeHeight, default=0};
	__property bool ShowQuietZone = {read=FShowQuietZone, write=SetShowQuietZone, default=0};
	__property int LeadingQuietZone = {read=FLeadingQuietZone, write=SetLeadingQuietZone, default=1};
	__property int TopQuietZone = {read=FTopQuietZone, write=SetTopQuietZone, default=1};
	__property int TrailingQuietZone = {read=FTrailingQuietZone, write=SetTrailingQuietZone, default=1};
	__property int BottomQuietZone = {read=FBottomQuietZone, write=SetBottomQuietZone, default=1};
	__property bool Locked = {read=FLocked, write=SetLocked, default=0};
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	__property TOnInvalidChar OnInvalidChar = {read=FOnInvalidChar, write=FOnInvalidChar};
	__property TOnInvalidLength OnInvalidLength = {read=FOnInvalidLength, write=FOnInvalidLength};
	__property TOnDrawBarcode OnDrawBarcode = {read=FOnDrawBarcode, write=FOnDrawBarcode};
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Pbarcode2d */
using namespace Pbarcode2d;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pbarcode2d
