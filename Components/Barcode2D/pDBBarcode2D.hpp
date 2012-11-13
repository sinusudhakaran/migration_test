// CodeGear C++Builder
// Copyright (c) 1995, 2007 by CodeGear
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Pdbbarcode2d.pas' rev: 11.00

#ifndef Pdbbarcode2dHPP
#define Pdbbarcode2dHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Dbctrls.hpp>	// Pascal unit
#include <Db.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Pbarcode2d.hpp>	// Pascal unit
#include <Pcore2d.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Pdbbarcode2d
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TExtBarcode2D;
class PASCALIMPLEMENTATION TExtBarcode2D : public Pbarcode2d::TBarcode2D 
{
	typedef Pbarcode2d::TBarcode2D inherited;
	
public:
	__property Barcode ;
	__property OnChangeToUpdateDatabase ;
public:
	#pragma option push -w-inl
	/* TBarcode2D.Create */ inline __fastcall virtual TExtBarcode2D(Classes::TComponent* Owner) : Pbarcode2d::TBarcode2D(Owner) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TBarcode2D.Destroy */ inline __fastcall virtual ~TExtBarcode2D(void) { }
	#pragma option pop
	
};


class DELPHICLASS TDBBarcode2D;
class PASCALIMPLEMENTATION TDBBarcode2D : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
__published:
	Pbarcode2d::TBarcode2D* FBarcode2D;
	Dbctrls::TFieldDataLink* FDataLink;
	Db::TDataSource* __fastcall GetDataSource(void);
	AnsiString __fastcall GetDataField();
	Db::TField* __fastcall GetField(void);
	bool __fastcall GetReadOnly(void);
	void __fastcall SetDataSource(Db::TDataSource* Value);
	void __fastcall SetDataField(const AnsiString Value);
	void __fastcall SetReadOnly(bool Value);
	void __fastcall SetBarcode2D(Pbarcode2d::TBarcode2D* Value);
	void __fastcall DataChange(System::TObject* Sender);
	void __fastcall UpdateData(System::TObject* Sender);
	MESSAGE void __fastcall CMGetDataLink(Messages::TMessage &Message);
	void __fastcall BarcodeChanged(System::TObject* Sender);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	
public:
	__fastcall virtual TDBBarcode2D(Classes::TComponent* AOwner);
	__fastcall virtual ~TDBBarcode2D(void);
	DYNAMIC bool __fastcall ExecuteAction(Classes::TBasicAction* Action);
	DYNAMIC bool __fastcall UpdateAction(Classes::TBasicAction* Action);
	__property Db::TField* Field = {read=GetField};
	
__published:
	__property AnsiString DataField = {read=GetDataField, write=SetDataField};
	__property Db::TDataSource* DataSource = {read=GetDataSource, write=SetDataSource};
	__property bool ReadOnly = {read=GetReadOnly, write=SetReadOnly, default=0};
	__property Pbarcode2d::TBarcode2D* Barcode2D = {read=FBarcode2D, write=SetBarcode2D};
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Pdbbarcode2d */
using namespace Pdbbarcode2d;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Pdbbarcode2d
