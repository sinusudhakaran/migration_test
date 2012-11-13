// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pdatamatrixecc200.pas' rev: 11.00

#ifndef Pdatamatrixecc200HPP
#define Pdatamatrixecc200HPP

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
#include <Preedsolomon.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pdatamatrixecc200
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TDataMatrixEcc200_Shape { dsSquare, dsRectangle };
#pragma option pop

#pragma option push -b-
enum TDataMatrixEcc200_Size { dmSize_10_10, dmSize_12_12, dmSize_14_14, dmSize_16_16, dmSize_18_18, dmSize_20_20, dmSize_22_22, dmSize_24_24, dmSize_26_26, dmSize_32_32, dmSize_36_36, dmSize_40_40, dmSize_44_44, dmSize_48_48, dmSize_52_52, dmSize_64_64, dmSize_72_72, dmSize_80_80, dmSize_88_88, dmSize_96_96, dmSize_104_104, dmSize_120_120, dmSize_132_132, dmSize_144_144, dmSize_8_18, dmSize_8_32, dmSize_12_26, dmSize_12_36, dmSize_16_36, dmSize_16_48 };
#pragma option pop

#pragma option push -b-
enum TDataMatrixEcc200_EncodeMode { emAscii, emC40, emText, emAnsiX12, emEdifact, emBase256 };
#pragma option pop

class DELPHICLASS TBarcode2D_DataMatrixEcc200;
class PASCALIMPLEMENTATION TBarcode2D_DataMatrixEcc200 : public Pbarcode2d::TBarcode2D 
{
	typedef Pbarcode2d::TBarcode2D inherited;
	
private:
	TDataMatrixEcc200_Size FMinSize;
	TDataMatrixEcc200_Size FMaxSize;
	bool FAllowEscape;
	TDataMatrixEcc200_Shape FShape;
	Preedsolomon::TReedSolomon* FReedSolomon;
	void __fastcall SetMinSize(const TDataMatrixEcc200_Size Value);
	void __fastcall SetMaxSize(const TDataMatrixEcc200_Size Value);
	void __fastcall SetAllowEscape(const bool Value);
	void __fastcall SetShape(const TDataMatrixEcc200_Shape Value);
	TDataMatrixEcc200_Size __fastcall GetCurrentSize(void);
	void __fastcall VerifyEscape(AnsiString ABarcode, int &AInvalideIndex, int &AEscapeCodeWords, int &ADataCharsNumb);
	void __fastcall Placement(Pcore2d::PCoreWorkArea PWorkArea, Pcore2d::TMapMatrix &DataMatrix, int TotalRow, int TotalCol);
	TDataMatrixEcc200_EncodeMode __fastcall LookAheadTest(AnsiString ABarcode, int AIndex, TDataMatrixEcc200_EncodeMode CurMode);
	AnsiString __fastcall EncodeBase40Char(char Ch, TDataMatrixEcc200_EncodeMode Mode);
	AnsiString __fastcall EncodeAsciiString(AnsiString ABarcode, int StartIndex, int StopIndex);
	void __fastcall LatchAscii(AnsiString ABarcode, int StopIndex, int CanSwitchWords, int CanSwitchIndex, int Base256Start, int EncodeCount, unsigned EncodeValue, TDataMatrixEcc200_EncodeMode CurMode, AnsiString &SemiCode);
	AnsiString __fastcall Encode(AnsiString ABarcode, int &InvalidIndex, TDataMatrixEcc200_EncodeMode &PreMode, int &Base256Start);
	void __fastcall AdjustEncode(Pcore2d::PCoreWorkArea &PWorkArea, int &DataWordsNum, TDataMatrixEcc200_Size Size, TDataMatrixEcc200_EncodeMode LastEncodeMode, int LastBase256Start);
	
protected:
	virtual void __fastcall GetMinQuietZonesInModules(int &Left, int &Top, int &Right, int &Bottom);
	virtual void __fastcall CustomWorkArea(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall ConfigWorkArea(Pcore2d::PCoreWorkArea &PWorkArea, Graphics::TCanvas* ACanvas, AnsiString ABarcode, Graphics::TColor ABarColor, Graphics::TColor ASpaceColor, bool AShowQuietZone, int AModule, int ALeft, int ATop, int AAngle, bool AMirror = false, Pcore2d::TCustomPrintSizeMode APrintSizeMode = (Pcore2d::TCustomPrintSizeMode)(0x3), double APrintSizeValue = 0.000000E+00, int APrintSizeDPI = 0x0, double APrintDensityRate = 1.000000E+00, void * PCustomData = (void *)(0x0));
	virtual bool __fastcall VerifyLength(Pcore2d::PCoreWorkArea PWorkArea);
	virtual int __fastcall VerifyAllChars(Pcore2d::PCoreWorkArea PWorkArea);
	virtual bool __fastcall LevelOneEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual bool __fastcall CalculateDimension(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall LevelTwoEncode(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall PlacementModules(Pcore2d::PCoreWorkArea &PWorkArea);
	virtual void __fastcall GetSymbolZoneInModules(Pcore2d::PCoreWorkArea PWorkArea, int &AWidth, int &AHeight);
	
public:
	__fastcall virtual TBarcode2D_DataMatrixEcc200(Classes::TComponent* Owner);
	__fastcall virtual ~TBarcode2D_DataMatrixEcc200(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property TDataMatrixEcc200_Size CurrentSize = {read=GetCurrentSize, nodefault};
	
__published:
	__property TDataMatrixEcc200_Size MinSize = {read=FMinSize, write=SetMinSize, default=0};
	__property TDataMatrixEcc200_Size MaxSize = {read=FMaxSize, write=SetMaxSize, default=23};
	__property bool AllowEscape = {read=FAllowEscape, write=SetAllowEscape, default=0};
	__property TDataMatrixEcc200_Shape Shape = {read=FShape, write=SetShape, default=0};
	__property Inversed  = {default=0};
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Pdatamatrixecc200 */
using namespace Pdatamatrixecc200;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pdatamatrixecc200
