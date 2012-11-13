// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Preedsolomon.pas' rev: 11.00

#ifndef PreedsolomonHPP
#define PreedsolomonHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Preedsolomon
{
//-- type declarations -------------------------------------------------------
typedef DynamicArray<int >  pReedSolomon__2;

class DELPHICLASS TReedSolomon;
class PASCALIMPLEMENTATION TReedSolomon : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	DynamicArray<int >  FLogarithm;
	DynamicArray<int >  FAntilogarithm;
	int FGaloisField;
	int FPrimeModulus;
	int __fastcall Product(int X, int Y);
	Word __fastcall GetWords(System::PByte PWords, Byte WordLen, int Index, PWORD PTailWords = (void *)(0x0), int TotalWords = 0x0);
	void __fastcall SetWords(System::PByte PWords, Byte WordLen, int Index, Word Data, PWORD PTailWords = (void *)(0x0), int TotalWords = 0x0);
	
public:
	__fastcall virtual ~TReedSolomon(void);
	void __fastcall Encode(System::PByte DataWords, System::PByte EdccWords, Byte WordLen, int DataWordsNum, int EdccWordsNum, int GaloisField, int PrimeModulus);
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall TReedSolomon(void) : System::TObject() { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Preedsolomon */
using namespace Preedsolomon;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Preedsolomon
