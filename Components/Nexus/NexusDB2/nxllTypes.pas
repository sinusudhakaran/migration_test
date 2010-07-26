{##############################################################################}
{# NexusDB: nxllTypes.pas 2.00                                                #}
{# NexusDB Memory Manager: nxllTypes.pas 2.03                                 #}
{# Copyright (c) Nexus Database Systems Pty. Ltd. 2003                        #}
{# All rights reserved.                                                       #}
{##############################################################################}
{# NexusDB: low level types                                                   #}
{##############################################################################}

{$I nxDefine.inc}

unit nxllTypes;

interface

{$IFDEF DCC6OrLater}
uses
  Types;
{$ENDIF}

type
  {$IFNDEF DCC6OrLater}
  PPointer = ^Pointer;
  PCardinal = ^Cardinal;
  {$ENDIF}

  {$IFDEF CBuilder6}
  PPointer = ^Pointer;
  PCardinal = ^Cardinal;
  {$ENDIF}

  TnxMemSize = Integer;                     {type for size of memory to alloc/free}

  TnxBoolean = ByteBool;                    {8-bit Boolean}
  PnxBoolean = ^TnxBoolean;                 {Pointer to a 8-bit Boolean}

  TnxAnsiChar = AnsiChar;                   {8-bit AnsiChar}
  PnxAnsiChar = ^TnxAnsiChar;               {Pointer to a 8-bit AnsiChar}

  TnxWideChar = WideChar;                   {16-bit WideChar}
  PnxWideChar = ^TnxWideChar;               {Pointer to a 16-bit WideChar}

  TnxByte8 = Byte;                          {8-bit unsigned Integer}
  PnxByte8 = ^TnxByte8;                     {Pointer to a 8-bit unsigned Integer}

  TnxWord16 = Word;                         {16-bit unsigned Integer}
  PnxWord16 = ^TnxWord16;                   {Pointer to a 16-bit unsigned Integer}
  TnxDynWord16Array = array of TnxWord16;

  TnxWord32 = Cardinal;                     {32-bit unsigned Integer}
  PnxWord32 = ^TnxWord32;                   {Pointer to a 32-bit unsigned Integer}

  TnxInt8 = Shortint;                       {8-bit signed Integer}
  PnxInt8 = ^TnxInt8;                       {Pointer to a 8-bit signed Integer}

  TnxInt16 = Smallint;                      {16-bit signed Integer}
  PnxInt16 = ^TnxInt16;                     {Pointer to a 16-bit signed Integer}

  TnxInt32 = Integer;                       {32-bit signed Integer}
  PnxInt32 = ^TnxInt32;                     {Pointer to a 32-bit signed Integer}

  TnxInt64 = Int64;                         {64-bit signed Integer}
  PnxInt64 = ^TnxInt64;                     {Pointer to a 64-bit signed Integer}

  TnxInt64Rec = record
    case Integer of
      0: (Value: TnxInt64);
      1: (iLow  : TnxWord32;
          iHigh : TnxInt32);
  end;
  PnxInt64Rec = ^TnxInt64Rec;

  TnxWord64Rec = record
    case Integer of
      0: (Value : TnxInt64);
      1: (iLow  : TnxWord32;
          iHigh : TnxWord32);
  end;
  PnxWord64Rec = ^TnxWord64Rec;

  TnxSingle = Single;
  PnxSingle = ^TnxSingle;

  TnxDouble = Double;
  PnxDouble = ^TnxDouble;

  TnxExtended = Extended;
  PnxExtended = ^TnxExtended;

  TnxCurrency = Currency;
  PnxCurrency = ^TnxCurrency;

  TnxBcd = Currency;
  PnxBcd = ^TnxBcd;
               
  TnxGuid = TGuid;
  PnxGuid = ^TnxGuid;

  TnxDate = type Integer;                 {4 byte date value; One plus number of days since 1/1/0001 }
  PnxDate = ^TnxDate;                     {Pointer to a 4 byte date value}

  TnxTime = type Integer;                 {4 byte time value; Number of milliseconds since midnight }
  PnxTime = ^TnxTime;                     {Pointer to a 4 byte time value}

  TnxDateTime = {$IFNDEF BCB} type {$ENDIF} Double;              {8 byte date/time value; Number of milliseconds since midnight on one plus number of days since 1/1/0001}
  PnxDateTime = ^TnxDateTime;             {Pointer to a 8 byte date/time value}

  PnxByteArray = ^TnxByteArray;             {General array of bytes}
  PPnxByteArray = ^PnxByteArray;

  TnxByteArray = array[0..Pred(High(Integer))] of Byte;
  TnxDynByteArray = array of Byte;

  TnxAnsiCharArray = array[0..Pred(High(Integer))] of TnxAnsiChar;
  PnxAnsiCharArray = ^TnxAnsiCharArray;             {For debugging purposes. }

  TnxWideCharArray = array[0..Pred(High(Integer)  div SizeOf(TnxWideChar))] of TnxWideChar;
  PnxWideCharArray = ^TnxWideCharArray;             {For debugging purposes. }

  TnxIntegerArray = array [0..Pred(High(Integer) div SizeOf(Integer))] of Integer;
  PnxIntegerArray = ^TnxIntegerArray;       {General array of long integers}

  PnxShStr = ^TnxShStr;                     {Pointer to a length-byte string}
  TnxShStr = string[255];                   {a length-byte string}

  TnxStringZ = array [0..255] of AnsiChar;     {For converting ShortStrings to StringZs}

  TnxResult = type TnxWord32;
  PnxResult = ^TnxResult;

  TnxCharSet = set of Char;

  PComp = ^Comp;

  TnxWideString = array of TnxWideChar;

  TnxDynVariantArray = array of Variant;

  {$IFDEF DCC6OrLater}
type
  TnxValueRelationship = TValueRelationship;

const
  nxSmallerThan = LessThanValue;
  nxEqual = EqualsValue;
  nxGreaterThan= GreaterThanValue;
{$ELSE}
type
  TnxValueRelationship = -1..1;

const
  nxSmallerThan = Low(TnxValueRelationship);
  nxEqual = 0;
  nxGreaterThan = High(TnxValueRelationship);
{$ENDIF}

type
  TnxBaseID      = type TnxWord32;
  TnxSessionID   = type TnxBaseID;
  TnxMsgID       = type TnxBaseID;
  TnxRequestID   = type TnxBaseID;
  TnxTransportID = type TnxBaseID;

  PnxMsgID       = ^TnxMsgID;

type
  TnxBlockSize = (nxbs4k, nxbs8k, nxbs16k, nxbs32k, nxbs64k);
  TnxBlockSizes = set of TnxBlockSize;

  TnxNetMsgDataType = (      {Types of network message data...}
              nmdByteArray,  {..it's an array of bytes}
              nmdStream);    {..it's a stream (TStream descendant)}

  {$IFDEF DCC6OrLater}
  InxInterface = IInterface;
  {$ELSE}
  InxInterface = IUnknown;
  {$ENDIF}


  InxSessionRequests = interface(InxInterface)
  ['{46D1D328-F233-4A87-A3E1-A174196EB260}']
    function ProcessRequest(aSource          : TObject;
                            aMsgID           : TnxMsgID;
                            aTimeout         : TnxWord32;
                            aRequestData     : Pointer;
                            aRequestDataLen  : TnxWord32;
                            aReply           : PPointer;
                            aReplyLen        : PnxWord32;
                            aReplyType       : TnxNetMsgDataType)
                                             : TnxResult;

    procedure ProcessPost(aSource          : TObject;
                          aMsgID           : TnxMsgID;
                          aTimeout         : TnxWord32;
                          aRequestData     : Pointer;
                          aRequestDataLen  : TnxWord32);
  end;

implementation

end.

