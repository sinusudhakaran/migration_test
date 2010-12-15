unit DownloadConverter_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 8291 $
// File generated on 16/12/2010 9:52:53 a.m. from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\DelphiTFS\Practice\Dev\DownLoadConverter\DownloadConverter.tlb (1)
// LIBID: {B1E1FB50-5934-4AA9-916C-41BDC87872B1}
// LCID: 0
// Helpfile: 
// HelpString: DownloadConverter Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\system32\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  DownloadConverterMajorVersion = 1;
  DownloadConverterMinorVersion = 0;

  LIBID_DownloadConverter: TGUID = '{B1E1FB50-5934-4AA9-916C-41BDC87872B1}';

  IID_IFileConverter: TGUID = '{EC01893B-4FE7-4F90-9DB0-A3CE0377A83D}';
  DIID_IFileConverterEvents: TGUID = '{30CC3027-DF6A-4499-B277-4E6E62EEA528}';
  CLASS_FileConverter: TGUID = '{AA0DDB0B-CC5F-4AF2-B19D-5B47D4BE62B0}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum FileType
type
  FileType = TOleEnum;
const
  DataFile = $00000000;
  htmFile = $00000001;
  rptFile = $00000002;
  binFile = $00000003;
  ChargesFile = $00000004;

// Constants for enum ErrorCodes
type
  ErrorCodes = TOleEnum;
const
  FileCorrupt = $00000001;
  DiskInvalid = $00000002;
  PINIncorrect = $00000003;
  NoData = $00000004;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IFileConverter = interface;
  IFileConverterDisp = dispinterface;
  IFileConverterEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  FileConverter = IFileConverter;


// *********************************************************************//
// Interface: IFileConverter
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EC01893B-4FE7-4F90-9DB0-A3CE0377A83D}
// *********************************************************************//
  IFileConverter = interface(IDispatch)
    ['{EC01893B-4FE7-4F90-9DB0-A3CE0377A83D}']
    procedure ImportFile(const FileName: WideString; const Country: WideString; 
                         const FileStream: WideString; PIN: Integer); safecall;
  end;

// *********************************************************************//
// DispIntf:  IFileConverterDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EC01893B-4FE7-4F90-9DB0-A3CE0377A83D}
// *********************************************************************//
  IFileConverterDisp = dispinterface
    ['{EC01893B-4FE7-4F90-9DB0-A3CE0377A83D}']
    procedure ImportFile(const FileName: WideString; const Country: WideString; 
                         const FileStream: WideString; PIN: Integer); dispid 201;
  end;

// *********************************************************************//
// DispIntf:  IFileConverterEvents
// Flags:     (4096) Dispatchable
// GUID:      {30CC3027-DF6A-4499-B277-4E6E62EEA528}
// *********************************************************************//
  IFileConverterEvents = dispinterface
    ['{30CC3027-DF6A-4499-B277-4E6E62EEA528}']
    procedure OnNewFile(const FileName: WideString; FileType: FileType; const FileStream: WideString); dispid 201;
    procedure OnError(Code: ErrorCodes; const Description: WideString); dispid 202;
  end;

// *********************************************************************//
// The Class CoFileConverter provides a Create and CreateRemote method to          
// create instances of the default interface IFileConverter exposed by              
// the CoClass FileConverter. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFileConverter = class
    class function Create: IFileConverter;
    class function CreateRemote(const MachineName: string): IFileConverter;
  end;

implementation

uses ComObj;

class function CoFileConverter.Create: IFileConverter;
begin
  Result := CreateComObject(CLASS_FileConverter) as IFileConverter;
end;

class function CoFileConverter.CreateRemote(const MachineName: string): IFileConverter;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FileConverter) as IFileConverter;
end;

end.
