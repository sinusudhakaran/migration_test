unit WDDX_COMLib_TLB;

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

// PASTLWTR : $Revision:   1.130.1.0.1.0.1.6  $
// File generated on 21/06/2004 3:14:46 p.m. from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\WINDOWS\wddx_com.dll (1)
// LIBID: {F99C9473-EE6A-11D1-9582-00C04FA35A24}
// LCID: 0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\System32\stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\WINDOWS\System32\stdvcl40.dll)
// Errors:
//   Error creating palette bitmap of (TWDDXStruct) : Server C:\WINDOWS\wddx_com.dll contains no icons
//   Error creating palette bitmap of (TWDDXDeserializer) : Server C:\WINDOWS\wddx_com.dll contains no icons
//   Error creating palette bitmap of (TWDDXSerializer) : Server C:\WINDOWS\wddx_com.dll contains no icons
//   Error creating palette bitmap of (TWDDXRecordset) : Server C:\WINDOWS\wddx_com.dll contains no icons
//   Error creating palette bitmap of (TWDDXJSConverter) : Server C:\WINDOWS\wddx_com.dll contains no icons
// ************************************************************************ //
// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  WDDX_COMLibMajorVersion = 1;
  WDDX_COMLibMinorVersion = 0;

  LIBID_WDDX_COMLib: TGUID = '{F99C9473-EE6A-11D1-9582-00C04FA35A24}';

  IID_IWDDXStruct: TGUID = '{F99C9482-EE6A-11D1-9582-00C04FA35A24}';
  CLASS_WDDXStruct: TGUID = '{F99C9483-EE6A-11D1-9582-00C04FA35A24}';
  IID_IWDDXDeserializer: TGUID = '{F70E2628-EEA1-11D1-9582-00C04FA35A24}';
  CLASS_WDDXDeserializer: TGUID = '{F70E2629-EEA1-11D1-9582-00C04FA35A24}';
  IID_IWDDXSerializer: TGUID = '{F70E262A-EEA1-11D1-9582-00C04FA35A24}';
  CLASS_WDDXSerializer: TGUID = '{F70E262B-EEA1-11D1-9582-00C04FA35A24}';
  IID_IWDDXRecordset: TGUID = '{11123B38-0959-11D2-9585-00C04FA35A24}';
  CLASS_WDDXRecordset: TGUID = '{11123B39-0959-11D2-9585-00C04FA35A24}';
  IID_IWDDXJSConverter: TGUID = '{6E2F7AD4-2163-11D2-958A-00C04FA35A24}';
  CLASS_WDDXJSConverter: TGUID = '{6E2F7AD5-2163-11D2-958A-00C04FA35A24}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum __MIDL___MIDL_itf_wddx_com_0209_0001
type
  __MIDL___MIDL_itf_wddx_com_0209_0001 = TOleEnum;
const
  eolUnix = $00000000;
  eolPC = $00000001;
  eolMac = $00000002;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IWDDXStruct = interface;
  IWDDXStructDisp = dispinterface;
  IWDDXDeserializer = interface;
  IWDDXDeserializerDisp = dispinterface;
  IWDDXSerializer = interface;
  IWDDXSerializerDisp = dispinterface;
  IWDDXRecordset = interface;
  IWDDXRecordsetDisp = dispinterface;
  IWDDXJSConverter = interface;
  IWDDXJSConverterDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  WDDXStruct = IWDDXStruct;
  WDDXDeserializer = IWDDXDeserializer;
  WDDXSerializer = IWDDXSerializer;
  WDDXRecordset = IWDDXRecordset;
  WDDXJSConverter = IWDDXJSConverter;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//

  EOLType = __MIDL___MIDL_itf_wddx_com_0209_0001; 

// *********************************************************************//
// Interface: IWDDXStruct
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F99C9482-EE6A-11D1-9582-00C04FA35A24}
// *********************************************************************//
  IWDDXStruct = interface(IDispatch)
    ['{F99C9482-EE6A-11D1-9582-00C04FA35A24}']
    function Get_allowNewProperties: Integer; safecall;
    procedure Set_allowNewProperties(pVal: Integer); safecall;
    function getProp(const bstrName: WideString): OleVariant; safecall;
    procedure setProp(const bstrName: WideString; Val: OleVariant); safecall;
    function clone: IWDDXStruct; safecall;
    function getPropNames: OleVariant; safecall;
    function Get_isCaseSensitive: Integer; safecall;
    procedure Set_isCaseSensitive(pVal: Integer); safecall;
    property allowNewProperties: Integer read Get_allowNewProperties write Set_allowNewProperties;
    property isCaseSensitive: Integer read Get_isCaseSensitive write Set_isCaseSensitive;
  end;

// *********************************************************************//
// DispIntf:  IWDDXStructDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F99C9482-EE6A-11D1-9582-00C04FA35A24}
// *********************************************************************//
  IWDDXStructDisp = dispinterface
    ['{F99C9482-EE6A-11D1-9582-00C04FA35A24}']
    property allowNewProperties: Integer dispid 1;
    function getProp(const bstrName: WideString): OleVariant; dispid 2;
    procedure setProp(const bstrName: WideString; Val: OleVariant); dispid 3;
    function clone: IWDDXStruct; dispid 4;
    function getPropNames: OleVariant; dispid 5;
    property isCaseSensitive: Integer dispid 6;
  end;

// *********************************************************************//
// Interface: IWDDXDeserializer
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F70E2628-EEA1-11D1-9582-00C04FA35A24}
// *********************************************************************//
  IWDDXDeserializer = interface(IDispatch)
    ['{F70E2628-EEA1-11D1-9582-00C04FA35A24}']
    function deserialize(xml: OleVariant): OleVariant; safecall;
    function Get_EOLType: EOLType; safecall;
    procedure Set_EOLType(pVal: EOLType); safecall;
    property EOLType: EOLType read Get_EOLType write Set_EOLType;
  end;

// *********************************************************************//
// DispIntf:  IWDDXDeserializerDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F70E2628-EEA1-11D1-9582-00C04FA35A24}
// *********************************************************************//
  IWDDXDeserializerDisp = dispinterface
    ['{F70E2628-EEA1-11D1-9582-00C04FA35A24}']
    function deserialize(xml: OleVariant): OleVariant; dispid 1;
    property EOLType: EOLType dispid 2;
  end;

// *********************************************************************//
// Interface: IWDDXSerializer
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F70E262A-EEA1-11D1-9582-00C04FA35A24}
// *********************************************************************//
  IWDDXSerializer = interface(IDispatch)
    ['{F70E262A-EEA1-11D1-9582-00C04FA35A24}']
    function serialize(dataRoot: OleVariant): WideString; safecall;
    function Get_useTimezoneInfo: Integer; safecall;
    procedure Set_useTimezoneInfo(pVal: Integer); safecall;
    property useTimezoneInfo: Integer read Get_useTimezoneInfo write Set_useTimezoneInfo;
  end;

// *********************************************************************//
// DispIntf:  IWDDXSerializerDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F70E262A-EEA1-11D1-9582-00C04FA35A24}
// *********************************************************************//
  IWDDXSerializerDisp = dispinterface
    ['{F70E262A-EEA1-11D1-9582-00C04FA35A24}']
    function serialize(dataRoot: OleVariant): WideString; dispid 1;
    property useTimezoneInfo: Integer dispid 2;
  end;

// *********************************************************************//
// Interface: IWDDXRecordset
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {11123B38-0959-11D2-9585-00C04FA35A24}
// *********************************************************************//
  IWDDXRecordset = interface(IDispatch)
    ['{11123B38-0959-11D2-9585-00C04FA35A24}']
    function getRowCount: SYSINT; safecall;
    procedure addRows(nRowsToAdd: SYSINT); safecall;
    function getColumnCount: SYSINT; safecall;
    function addColumn(const bstrColumnName: WideString): SYSINT; safecall;
    function getIdOfColumn(const bstrColumnName: WideString): SYSINT; safecall;
    function getColumnNames: OleVariant; safecall;
    function getField(nRow: SYSINT; column: OleVariant): OleVariant; safecall;
    procedure setField(nRow: SYSINT; column: OleVariant; value: OleVariant); safecall;
  end;

// *********************************************************************//
// DispIntf:  IWDDXRecordsetDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {11123B38-0959-11D2-9585-00C04FA35A24}
// *********************************************************************//
  IWDDXRecordsetDisp = dispinterface
    ['{11123B38-0959-11D2-9585-00C04FA35A24}']
    function getRowCount: SYSINT; dispid 1;
    procedure addRows(nRowsToAdd: SYSINT); dispid 2;
    function getColumnCount: SYSINT; dispid 3;
    function addColumn(const bstrColumnName: WideString): SYSINT; dispid 4;
    function getIdOfColumn(const bstrColumnName: WideString): SYSINT; dispid 5;
    function getColumnNames: OleVariant; dispid 6;
    function getField(nRow: SYSINT; column: OleVariant): OleVariant; dispid 7;
    procedure setField(nRow: SYSINT; column: OleVariant; value: OleVariant); dispid 8;
  end;

// *********************************************************************//
// Interface: IWDDXJSConverter
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6E2F7AD4-2163-11D2-958A-00C04FA35A24}
// *********************************************************************//
  IWDDXJSConverter = interface(IDispatch)
    ['{6E2F7AD4-2163-11D2-958A-00C04FA35A24}']
    function convertWddx(wddxXml: OleVariant; const bstrTopLevelVar: WideString): WideString; safecall;
    function convertData(dataRoot: OleVariant; const bstrTopLevelVar: WideString): WideString; safecall;
  end;

// *********************************************************************//
// DispIntf:  IWDDXJSConverterDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6E2F7AD4-2163-11D2-958A-00C04FA35A24}
// *********************************************************************//
  IWDDXJSConverterDisp = dispinterface
    ['{6E2F7AD4-2163-11D2-958A-00C04FA35A24}']
    function convertWddx(wddxXml: OleVariant; const bstrTopLevelVar: WideString): WideString; dispid 1;
    function convertData(dataRoot: OleVariant; const bstrTopLevelVar: WideString): WideString; dispid 2;
  end;

// *********************************************************************//
// The Class CoWDDXStruct provides a Create and CreateRemote method to          
// create instances of the default interface IWDDXStruct exposed by              
// the CoClass WDDXStruct. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWDDXStruct = class
    class function Create: IWDDXStruct;
    class function CreateRemote(const MachineName: string): IWDDXStruct;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWDDXStruct
// Help String      : WDDXStruct Class
// Default Interface: IWDDXStruct
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWDDXStructProperties= class;
{$ENDIF}
  TWDDXStruct = class(TOleServer)
  private
    FIntf:        IWDDXStruct;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWDDXStructProperties;
    function      GetServerProperties: TWDDXStructProperties;
{$ENDIF}
    function      GetDefaultInterface: IWDDXStruct;
  protected
    procedure InitServerData; override;
    function Get_allowNewProperties: Integer;
    procedure Set_allowNewProperties(pVal: Integer);
    function Get_isCaseSensitive: Integer;
    procedure Set_isCaseSensitive(pVal: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWDDXStruct);
    procedure Disconnect; override;
    function getProp(const bstrName: WideString): OleVariant;
    procedure setProp(const bstrName: WideString; Val: OleVariant);
    function clone: IWDDXStruct;
    function getPropNames: OleVariant;
    property DefaultInterface: IWDDXStruct read GetDefaultInterface;
    property allowNewProperties: Integer read Get_allowNewProperties write Set_allowNewProperties;
    property isCaseSensitive: Integer read Get_isCaseSensitive write Set_isCaseSensitive;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWDDXStructProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWDDXStruct
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWDDXStructProperties = class(TPersistent)
  private
    FServer:    TWDDXStruct;
    function    GetDefaultInterface: IWDDXStruct;
    constructor Create(AServer: TWDDXStruct);
  protected
    function Get_allowNewProperties: Integer;
    procedure Set_allowNewProperties(pVal: Integer);
    function Get_isCaseSensitive: Integer;
    procedure Set_isCaseSensitive(pVal: Integer);
  public
    property DefaultInterface: IWDDXStruct read GetDefaultInterface;
  published
    property allowNewProperties: Integer read Get_allowNewProperties write Set_allowNewProperties;
    property isCaseSensitive: Integer read Get_isCaseSensitive write Set_isCaseSensitive;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWDDXDeserializer provides a Create and CreateRemote method to          
// create instances of the default interface IWDDXDeserializer exposed by              
// the CoClass WDDXDeserializer. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWDDXDeserializer = class
    class function Create: IWDDXDeserializer;
    class function CreateRemote(const MachineName: string): IWDDXDeserializer;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWDDXDeserializer
// Help String      : WDDXDeserializer Class
// Default Interface: IWDDXDeserializer
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWDDXDeserializerProperties= class;
{$ENDIF}
  TWDDXDeserializer = class(TOleServer)
  private
    FIntf:        IWDDXDeserializer;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWDDXDeserializerProperties;
    function      GetServerProperties: TWDDXDeserializerProperties;
{$ENDIF}
    function      GetDefaultInterface: IWDDXDeserializer;
  protected
    procedure InitServerData; override;
    function Get_EOLType: EOLType;
    procedure Set_EOLType(pVal: EOLType);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWDDXDeserializer);
    procedure Disconnect; override;
    function deserialize(xml: OleVariant): OleVariant;
    property DefaultInterface: IWDDXDeserializer read GetDefaultInterface;
    property EOLType: EOLType read Get_EOLType write Set_EOLType;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWDDXDeserializerProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWDDXDeserializer
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWDDXDeserializerProperties = class(TPersistent)
  private
    FServer:    TWDDXDeserializer;
    function    GetDefaultInterface: IWDDXDeserializer;
    constructor Create(AServer: TWDDXDeserializer);
  protected
    function Get_EOLType: EOLType;
    procedure Set_EOLType(pVal: EOLType);
  public
    property DefaultInterface: IWDDXDeserializer read GetDefaultInterface;
  published
    property EOLType: EOLType read Get_EOLType write Set_EOLType;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWDDXSerializer provides a Create and CreateRemote method to          
// create instances of the default interface IWDDXSerializer exposed by              
// the CoClass WDDXSerializer. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWDDXSerializer = class
    class function Create: IWDDXSerializer;
    class function CreateRemote(const MachineName: string): IWDDXSerializer;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWDDXSerializer
// Help String      : WDDXSerializer Class
// Default Interface: IWDDXSerializer
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWDDXSerializerProperties= class;
{$ENDIF}
  TWDDXSerializer = class(TOleServer)
  private
    FIntf:        IWDDXSerializer;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWDDXSerializerProperties;
    function      GetServerProperties: TWDDXSerializerProperties;
{$ENDIF}
    function      GetDefaultInterface: IWDDXSerializer;
  protected
    procedure InitServerData; override;
    function Get_useTimezoneInfo: Integer;
    procedure Set_useTimezoneInfo(pVal: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWDDXSerializer);
    procedure Disconnect; override;
    function serialize(dataRoot: OleVariant): WideString;
    property DefaultInterface: IWDDXSerializer read GetDefaultInterface;
    property useTimezoneInfo: Integer read Get_useTimezoneInfo write Set_useTimezoneInfo;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWDDXSerializerProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWDDXSerializer
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWDDXSerializerProperties = class(TPersistent)
  private
    FServer:    TWDDXSerializer;
    function    GetDefaultInterface: IWDDXSerializer;
    constructor Create(AServer: TWDDXSerializer);
  protected
    function Get_useTimezoneInfo: Integer;
    procedure Set_useTimezoneInfo(pVal: Integer);
  public
    property DefaultInterface: IWDDXSerializer read GetDefaultInterface;
  published
    property useTimezoneInfo: Integer read Get_useTimezoneInfo write Set_useTimezoneInfo;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWDDXRecordset provides a Create and CreateRemote method to          
// create instances of the default interface IWDDXRecordset exposed by              
// the CoClass WDDXRecordset. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWDDXRecordset = class
    class function Create: IWDDXRecordset;
    class function CreateRemote(const MachineName: string): IWDDXRecordset;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWDDXRecordset
// Help String      : WDDXRecordset Class
// Default Interface: IWDDXRecordset
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWDDXRecordsetProperties= class;
{$ENDIF}
  TWDDXRecordset = class(TOleServer)
  private
    FIntf:        IWDDXRecordset;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWDDXRecordsetProperties;
    function      GetServerProperties: TWDDXRecordsetProperties;
{$ENDIF}
    function      GetDefaultInterface: IWDDXRecordset;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWDDXRecordset);
    procedure Disconnect; override;
    function getRowCount: SYSINT;
    procedure addRows(nRowsToAdd: SYSINT);
    function getColumnCount: SYSINT;
    function addColumn(const bstrColumnName: WideString): SYSINT;
    function getIdOfColumn(const bstrColumnName: WideString): SYSINT;
    function getColumnNames: OleVariant;
    function getField(nRow: SYSINT; column: OleVariant): OleVariant;
    procedure setField(nRow: SYSINT; column: OleVariant; value: OleVariant);
    property DefaultInterface: IWDDXRecordset read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWDDXRecordsetProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWDDXRecordset
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWDDXRecordsetProperties = class(TPersistent)
  private
    FServer:    TWDDXRecordset;
    function    GetDefaultInterface: IWDDXRecordset;
    constructor Create(AServer: TWDDXRecordset);
  protected
  public
    property DefaultInterface: IWDDXRecordset read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWDDXJSConverter provides a Create and CreateRemote method to          
// create instances of the default interface IWDDXJSConverter exposed by              
// the CoClass WDDXJSConverter. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWDDXJSConverter = class
    class function Create: IWDDXJSConverter;
    class function CreateRemote(const MachineName: string): IWDDXJSConverter;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWDDXJSConverter
// Help String      : WDDXJSConverter Class
// Default Interface: IWDDXJSConverter
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWDDXJSConverterProperties= class;
{$ENDIF}
  TWDDXJSConverter = class(TOleServer)
  private
    FIntf:        IWDDXJSConverter;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWDDXJSConverterProperties;
    function      GetServerProperties: TWDDXJSConverterProperties;
{$ENDIF}
    function      GetDefaultInterface: IWDDXJSConverter;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWDDXJSConverter);
    procedure Disconnect; override;
    function convertWddx(wddxXml: OleVariant; const bstrTopLevelVar: WideString): WideString;
    function convertData(dataRoot: OleVariant; const bstrTopLevelVar: WideString): WideString;
    property DefaultInterface: IWDDXJSConverter read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWDDXJSConverterProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWDDXJSConverter
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWDDXJSConverterProperties = class(TPersistent)
  private
    FServer:    TWDDXJSConverter;
    function    GetDefaultInterface: IWDDXJSConverter;
    constructor Create(AServer: TWDDXJSConverter);
  protected
  public
    property DefaultInterface: IWDDXJSConverter read GetDefaultInterface;
  published
  end;
{$ENDIF}


procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

implementation

uses ComObj;

class function CoWDDXStruct.Create: IWDDXStruct;
begin
  Result := CreateComObject(CLASS_WDDXStruct) as IWDDXStruct;
end;

class function CoWDDXStruct.CreateRemote(const MachineName: string): IWDDXStruct;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WDDXStruct) as IWDDXStruct;
end;

procedure TWDDXStruct.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{F99C9483-EE6A-11D1-9582-00C04FA35A24}';
    IntfIID:   '{F99C9482-EE6A-11D1-9582-00C04FA35A24}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWDDXStruct.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWDDXStruct;
  end;
end;

procedure TWDDXStruct.ConnectTo(svrIntf: IWDDXStruct);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWDDXStruct.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWDDXStruct.GetDefaultInterface: IWDDXStruct;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWDDXStruct.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWDDXStructProperties.Create(Self);
{$ENDIF}
end;

destructor TWDDXStruct.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWDDXStruct.GetServerProperties: TWDDXStructProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TWDDXStruct.Get_allowNewProperties: Integer;
begin
    Result := DefaultInterface.allowNewProperties;
end;

procedure TWDDXStruct.Set_allowNewProperties(pVal: Integer);
begin
  Exit;
end;

function TWDDXStruct.Get_isCaseSensitive: Integer;
begin
    Result := DefaultInterface.isCaseSensitive;
end;

procedure TWDDXStruct.Set_isCaseSensitive(pVal: Integer);
begin
  Exit;
end;

function TWDDXStruct.getProp(const bstrName: WideString): OleVariant;
begin
  Result := DefaultInterface.getProp(bstrName);
end;

procedure TWDDXStruct.setProp(const bstrName: WideString; Val: OleVariant);
begin
  DefaultInterface.setProp(bstrName, Val);
end;

function TWDDXStruct.clone: IWDDXStruct;
begin
  Result := DefaultInterface.clone;
end;

function TWDDXStruct.getPropNames: OleVariant;
begin
  Result := DefaultInterface.getPropNames;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWDDXStructProperties.Create(AServer: TWDDXStruct);
begin
  inherited Create;
  FServer := AServer;
end;

function TWDDXStructProperties.GetDefaultInterface: IWDDXStruct;
begin
  Result := FServer.DefaultInterface;
end;

function TWDDXStructProperties.Get_allowNewProperties: Integer;
begin
    Result := DefaultInterface.allowNewProperties;
end;

procedure TWDDXStructProperties.Set_allowNewProperties(pVal: Integer);
begin
  Exit;
end;

function TWDDXStructProperties.Get_isCaseSensitive: Integer;
begin
    Result := DefaultInterface.isCaseSensitive;
end;

procedure TWDDXStructProperties.Set_isCaseSensitive(pVal: Integer);
begin
  Exit;
end;

{$ENDIF}

class function CoWDDXDeserializer.Create: IWDDXDeserializer;
begin
  Result := CreateComObject(CLASS_WDDXDeserializer) as IWDDXDeserializer;
end;

class function CoWDDXDeserializer.CreateRemote(const MachineName: string): IWDDXDeserializer;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WDDXDeserializer) as IWDDXDeserializer;
end;

procedure TWDDXDeserializer.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{F70E2629-EEA1-11D1-9582-00C04FA35A24}';
    IntfIID:   '{F70E2628-EEA1-11D1-9582-00C04FA35A24}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWDDXDeserializer.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWDDXDeserializer;
  end;
end;

procedure TWDDXDeserializer.ConnectTo(svrIntf: IWDDXDeserializer);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWDDXDeserializer.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWDDXDeserializer.GetDefaultInterface: IWDDXDeserializer;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWDDXDeserializer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWDDXDeserializerProperties.Create(Self);
{$ENDIF}
end;

destructor TWDDXDeserializer.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWDDXDeserializer.GetServerProperties: TWDDXDeserializerProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TWDDXDeserializer.Get_EOLType: EOLType;
begin
    Result := DefaultInterface.EOLType;
end;

procedure TWDDXDeserializer.Set_EOLType(pVal: EOLType);
begin
  Exit;
end;

function TWDDXDeserializer.deserialize(xml: OleVariant): OleVariant;
begin
  Result := DefaultInterface.deserialize(xml);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWDDXDeserializerProperties.Create(AServer: TWDDXDeserializer);
begin
  inherited Create;
  FServer := AServer;
end;

function TWDDXDeserializerProperties.GetDefaultInterface: IWDDXDeserializer;
begin
  Result := FServer.DefaultInterface;
end;

function TWDDXDeserializerProperties.Get_EOLType: EOLType;
begin
    Result := DefaultInterface.EOLType;
end;

procedure TWDDXDeserializerProperties.Set_EOLType(pVal: EOLType);
begin
  Exit;
end;

{$ENDIF}

class function CoWDDXSerializer.Create: IWDDXSerializer;
begin
  Result := CreateComObject(CLASS_WDDXSerializer) as IWDDXSerializer;
end;

class function CoWDDXSerializer.CreateRemote(const MachineName: string): IWDDXSerializer;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WDDXSerializer) as IWDDXSerializer;
end;

procedure TWDDXSerializer.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{F70E262B-EEA1-11D1-9582-00C04FA35A24}';
    IntfIID:   '{F70E262A-EEA1-11D1-9582-00C04FA35A24}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWDDXSerializer.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWDDXSerializer;
  end;
end;

procedure TWDDXSerializer.ConnectTo(svrIntf: IWDDXSerializer);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWDDXSerializer.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWDDXSerializer.GetDefaultInterface: IWDDXSerializer;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWDDXSerializer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWDDXSerializerProperties.Create(Self);
{$ENDIF}
end;

destructor TWDDXSerializer.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWDDXSerializer.GetServerProperties: TWDDXSerializerProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TWDDXSerializer.Get_useTimezoneInfo: Integer;
begin
    Result := DefaultInterface.useTimezoneInfo;
end;

procedure TWDDXSerializer.Set_useTimezoneInfo(pVal: Integer);
begin
  Exit;
end;

function TWDDXSerializer.serialize(dataRoot: OleVariant): WideString;
begin
  Result := DefaultInterface.serialize(dataRoot);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWDDXSerializerProperties.Create(AServer: TWDDXSerializer);
begin
  inherited Create;
  FServer := AServer;
end;

function TWDDXSerializerProperties.GetDefaultInterface: IWDDXSerializer;
begin
  Result := FServer.DefaultInterface;
end;

function TWDDXSerializerProperties.Get_useTimezoneInfo: Integer;
begin
    Result := DefaultInterface.useTimezoneInfo;
end;

procedure TWDDXSerializerProperties.Set_useTimezoneInfo(pVal: Integer);
begin
  Exit;
end;

{$ENDIF}

class function CoWDDXRecordset.Create: IWDDXRecordset;
begin
  Result := CreateComObject(CLASS_WDDXRecordset) as IWDDXRecordset;
end;

class function CoWDDXRecordset.CreateRemote(const MachineName: string): IWDDXRecordset;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WDDXRecordset) as IWDDXRecordset;
end;

procedure TWDDXRecordset.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{11123B39-0959-11D2-9585-00C04FA35A24}';
    IntfIID:   '{11123B38-0959-11D2-9585-00C04FA35A24}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWDDXRecordset.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWDDXRecordset;
  end;
end;

procedure TWDDXRecordset.ConnectTo(svrIntf: IWDDXRecordset);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWDDXRecordset.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWDDXRecordset.GetDefaultInterface: IWDDXRecordset;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWDDXRecordset.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWDDXRecordsetProperties.Create(Self);
{$ENDIF}
end;

destructor TWDDXRecordset.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWDDXRecordset.GetServerProperties: TWDDXRecordsetProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TWDDXRecordset.getRowCount: SYSINT;
begin
  Result := DefaultInterface.getRowCount;
end;

procedure TWDDXRecordset.addRows(nRowsToAdd: SYSINT);
begin
  DefaultInterface.addRows(nRowsToAdd);
end;

function TWDDXRecordset.getColumnCount: SYSINT;
begin
  Result := DefaultInterface.getColumnCount;
end;

function TWDDXRecordset.addColumn(const bstrColumnName: WideString): SYSINT;
begin
  Result := DefaultInterface.addColumn(bstrColumnName);
end;

function TWDDXRecordset.getIdOfColumn(const bstrColumnName: WideString): SYSINT;
begin
  Result := DefaultInterface.getIdOfColumn(bstrColumnName);
end;

function TWDDXRecordset.getColumnNames: OleVariant;
begin
  Result := DefaultInterface.getColumnNames;
end;

function TWDDXRecordset.getField(nRow: SYSINT; column: OleVariant): OleVariant;
begin
  Result := DefaultInterface.getField(nRow, column);
end;

procedure TWDDXRecordset.setField(nRow: SYSINT; column: OleVariant; value: OleVariant);
begin
  DefaultInterface.setField(nRow, column, value);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWDDXRecordsetProperties.Create(AServer: TWDDXRecordset);
begin
  inherited Create;
  FServer := AServer;
end;

function TWDDXRecordsetProperties.GetDefaultInterface: IWDDXRecordset;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

class function CoWDDXJSConverter.Create: IWDDXJSConverter;
begin
  Result := CreateComObject(CLASS_WDDXJSConverter) as IWDDXJSConverter;
end;

class function CoWDDXJSConverter.CreateRemote(const MachineName: string): IWDDXJSConverter;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WDDXJSConverter) as IWDDXJSConverter;
end;

procedure TWDDXJSConverter.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{6E2F7AD5-2163-11D2-958A-00C04FA35A24}';
    IntfIID:   '{6E2F7AD4-2163-11D2-958A-00C04FA35A24}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWDDXJSConverter.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWDDXJSConverter;
  end;
end;

procedure TWDDXJSConverter.ConnectTo(svrIntf: IWDDXJSConverter);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWDDXJSConverter.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWDDXJSConverter.GetDefaultInterface: IWDDXJSConverter;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWDDXJSConverter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWDDXJSConverterProperties.Create(Self);
{$ENDIF}
end;

destructor TWDDXJSConverter.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWDDXJSConverter.GetServerProperties: TWDDXJSConverterProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TWDDXJSConverter.convertWddx(wddxXml: OleVariant; const bstrTopLevelVar: WideString): WideString;
begin
  Result := DefaultInterface.convertWddx(wddxXml, bstrTopLevelVar);
end;

function TWDDXJSConverter.convertData(dataRoot: OleVariant; const bstrTopLevelVar: WideString): WideString;
begin
  Result := DefaultInterface.convertData(dataRoot, bstrTopLevelVar);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWDDXJSConverterProperties.Create(AServer: TWDDXJSConverter);
begin
  inherited Create;
  FServer := AServer;
end;

function TWDDXJSConverterProperties.GetDefaultInterface: IWDDXJSConverter;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TWDDXStruct, TWDDXDeserializer, TWDDXSerializer, TWDDXRecordset, 
    TWDDXJSConverter]);
end;

end.
