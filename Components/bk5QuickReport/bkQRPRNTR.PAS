{ :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  :: QuickReport 2.0 for Delphi 1.0/2.0/3.0                  ::
  ::                                                         ::
  :: QRPRNTR - QRPrinter and other low level classes         ::
  ::                                                         ::
  :: Copyright (c) 1997 QuSoft AS                            ::
  :: All Rights Reserved                                     ::
  ::                                                         ::
  :: web: http://www.qusoft.no    mail: support@qusoft.no    ::
  ::                              fax: +47 22 41 74 91       ::
  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: }


(* **************************************************************

   BankLink Note:   Jan 2002

   This unit has been hacked for use in BankLink.  The intention is
   that this code will be replaced as soon as possible.

   This unit is compiled in as part of the "BankLink" package.

   It is refered to by the following units:

   BKPrintController.pas
   BKPrintJob.pas
   PrevForm.pas
   ReportToCanvas.pas


   It calls the following "BankLink" units

   qr2const.pas   ( and qr2const.res)
   prntInfo.pas


   The TbkQRPreview control is the only control that appears on the BankLink component tab.
   It was renamed to avoid conflict with the real TQrPreview control from Quick Report.


   NOTE:  You cannot you the banklink version of these components at the same
          time as the real Quick Report components.

   ************************************************************* *)

unit bkqrprntr;

{$R-}
{$T-} { We don't need (nor want) this type checking! }
{$B-} { QuickReport source assumes boolean expression short-circuit  }

interface

uses
  Windows, winspool, Sysutils, Messages, Classes, Controls, StdCtrls, ExtCtrls,
  ComCtrls, Buttons, Printers, Graphics, Forms, qr2const, dialogs,
  PrntInfo;

const
   cQRName = 'QuickReport 2.0k'; { This string should not be resourced }
   cQRVersion = 212;
   cQRPDefaultExt = 'QRP';      { Default extesion for QRP files }
   cQRDefaultExt = 'QR';        { Default extesion for QR files }

   { Actual paper sizes for all the known paper types }
   DEFAULT_PAPER_SIZE = 0;
   CUSTOM_PAPER_SIZE  = -1;

const
   { Misc constants }
   cQRPageShadowWidth = 2;
   cQRPageFrameWidth = 1;
   cQRPageShadowColor = clBlack;

  { TQRCompress related declarations }

const
  { TQRCompress constants }
  MaxChar = 256;
  EofChar = 256;
  PredMax = 255;
  TwiceMax = 512;
  ROOT = 0;
  BitMask : array[0..7] of Byte = (1, 2, 4, 8, 16, 32, 64, 128);

  CM_QRPROGRESSUPDATE = WM_USER + 0;
  CM_QRPAGEAVAILABLE = WM_USER + 1;

type
  TQRPrinter = class;
  EQRError = class(Exception);

  CodeType = 0..MaxChar;
  UpIndex = 0..PredMax;
  DownIndex = 0..TwiceMax;
  TreeDownArray = array[UpIndex] of DownIndex;
  TreeUpArray = array[DownIndex] of UpIndex;

  TCM_QRPRogressUpdate = record
    Msg : Cardinal;
    Position : word;
    QRPrinter : TQRPrinter;
  end;

  TCM_QRPageAvailable = record
    Msg : Cardinal;
    PageCount : word;
    QRPrinter : TQRPrinter;
  end;

  { TQRStream }
  TQRStream = class(TStream)
  private
    FLock: TRTLCriticalSection;
    MemoryStream : TMemoryStream;
    FFilename : string;
    FileStream : TFileStream;
    FInMemory : boolean;
    FMemoryLimit : longint;
  public
    constructor Create(MemoryLimit : Longint);
    constructor CreateFromFile(Filename : string);
    destructor Destroy; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    procedure LockStream;
    procedure UnlockStream;
    procedure SaveToStream(AStream : TStream);
    property InMemory : boolean read FInMemory;
  end;

  { TQRCompress }
  TQRCompress = class
  private
    BitPos : Byte;
    CompressFlag : Boolean;
    InByte : CodeType;
    Left, Right : TreeDownArray;
    OutByte : CodeType;
    Stream : TStream;
    Up : TreeUpArray;
    function GetByte : Byte;
    procedure InitializeSplay;
    procedure Splay(Plain : CodeType);
  public
    constructor Create(aStream : TStream; CompressData : boolean);
    destructor Destroy; override;
    procedure Expand(var Expanded : byte);
    procedure Compress(Plain : CodeType);
  end;

  { TQRPageList }
  TQRPageList = class
  private
    FLock: TRTLCriticalSection;
    aCompressor : TQRCompress;
    FCompression : boolean;
    FPageCount : integer;
    FStream : TQRStream;
    procedure SeekToFirst;
    procedure SeekToLast;
    procedure SeekToPage(PageNumber : integer);
    procedure ReadFileHeader;
    procedure WriteFileHeader;
  public
    constructor Create;
    destructor Destroy; override;
    function GetPage(PageNumber : integer) : TMetafile;
    procedure AddPage(aMetafile : TMetafile);
    procedure Clear;
    procedure Finish;
    procedure LoadFromFile(Filename : string);
    procedure LockList;
    procedure SaveToFile(Filename : string);
    procedure UnlockList;
    property Compression : boolean read FCompression write FCompression;
    property PageCount : integer read FPageCount;
    property Stream : TQRStream read FStream write FStream;
  end;

  { TQRPreviewImage }
  TQRZoomState = (qrZoomToFit,qrZoomToWidth,qrZoomOther);

  TQRPreviewImage = class(TGraphicControl)
  private
    FQRPrinter : TQRPrinter;
    FPageNumber : integer;
    aMetaFile : TMetafile;
    FImageOK : boolean;
    procedure PaintPage;
    procedure SetPageNumber(Value : integer);
  public
    Zoom : Integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
    property ImageOK : boolean read FImageOK write FImageOK;
    property PageNumber : integer read FPageNumber write SetPageNumber;
    property QRPrinter : TQRPrinter read FQRPrinter write FQRPrinter;
  end;

  { TbkQRPreview }
  TQRProgressUpdateEvent = procedure (Sender : TObject; Progress : integer) of object;

  TQRPageAvailableEvent = procedure (Sender : TObject; PageNum : integer) of object;

  TbkQRPreview = Class(TScrollBox)
  private
    FOnPageAvailableEvent : TQRPageAvailableEvent;
    FOnProgressUpdateEvent : TQRProgressUpdateEvent;
    FPreviewImage : TQRPreviewImage;
    FPageNumber : integer;
    FQRPrinter : TQRPrinter;
    FZoom : integer;
    FZoomState : TQRZoomState;
    procedure SetPageNumber(Value : integer);
    procedure SetZoom(value : integer);
    procedure Fixvalues(Sender : TObject);
    procedure SetQRPrinter(Value : TQRPrinter);
  protected
    procedure CMPageAvailable(var Message : TCM_QRPageAvailable); Message CM_QRPAGEAVAILABLE;
    procedure CMProgressUpdate(var Message : TCM_QRProgressUpdate); Message CM_QRPROGRESSUPDATE;
  public
    constructor Create(aOwner : TComponent); override;
    destructor Destroy; override;
    procedure UpdateImage;
    procedure UpdateZoom;
    procedure ZoomToWidth;
    procedure ZoomToFit;
    property PreviewImage : TQRPreviewImage read FPreviewImage;
    property QRPrinter : TQRPrinter read FQRPrinter write SetQRPrinter;
    property ZoomState : TQRZoomState read FZoomState write FZoomState;
  published
    property OnPageAvailable : TQRPageAvailableEvent read FOnPageAvailableEvent
                                                     write FOnPageAvailableEvent;
    property OnProgressUpdate : TQRProgressUpdateEvent read FOnProgressUpdateEvent write FOnProgressUpdateEvent;
    property PageNumber : integer read FPageNumber write setPageNumber;
    property Zoom : integer read FZoom write SetZoom;
  end;

  { TPrinterSettings }
  TPrinterSettings = class
  private
    { Device stuff }
    FDevice : PChar;
    FDriver : PChar;
    FPort : PChar;
    DeviceMode : THandle;
    DevMode : PDeviceMode;
    { Storage variables }
    FCopies : integer;
    FDuplex : boolean;
    FMaxExtentX : integer;
    FMaxExtentY : integer;
    FMinExtentX : integer;
    FMinExtentY : integer;
    FOrientation : TPrinterOrientation;
    FOutputBin : integer; 
    FPapers : TStringList;

    FPaperSize2 : integer;
    FPaperQuikIndex : integer;

    FPaperWidth : integer;
    FPaperLength : integer;
    FPixelsPerX : integer;
    FPixelsPerY : integer;
    FTopOffset : integer;
    FLeftOffset : integer;
    FPrinter : TPrinter;
    FTitle : string;
    function GetCopies : integer;
    function GetDriver : string;
    function GetDuplex : boolean;
    function GetMaxExtentX : integer;
    function GetMaxExtentY : integer;
    function GetMinExtentX : integer;
    function GetMinExtentY : integer;
    function GetOrientation : TPrinterOrientation;
    function GetOutputBin : integer; //TQRBin;

    function GetPaperSize2 : integer;
    function GetPaperWidth2 : integer;
    function GetPaperLength2 : integer;

    function GetPixelsPerX : integer;
    function GetPixelsPerY : integer;
    function GetPort : string;
    function GetPrinter : TPrinter;
    function GetTitle : string;
    function GetTopOffset : integer;
    function GetLeftOffset : integer;
    function Supported(Setting : integer) : boolean;
    procedure SetField(aField : integer);
    procedure GetPrinterSettings;
    procedure SetCopies(Value : integer);
    procedure SetDuplex(Value : boolean);
    procedure SetOrientation(Value : TPrinterOrientation);
    procedure SetOutputBin(Value : integer); //TQRBin);

    procedure SetPaperSize2(Value : integer);
    procedure SetPaperLength2(Value : integer);
    procedure SetPaperWidth2(Value : integer);

    procedure SetPrinter(Value : TPrinter);
    procedure SetTitle(Value : string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure ApplySettings;
    function PaperObj(Size : integer) : TPaperInfo;
    { read only properties }
    property Device : string read GetDriver;
    property Driver : string read GetDriver;
    property LeftOffset : integer read GetLeftOffset;
    property MaxExtentX : integer read GetMaxExtentX;
    property MaxExtentY : integer read GetMaxExtentY;
    property MinExtentX : integer read GetMinExtentX;
    property MinExtentY : integer read GetMinExtentY;
    property PixelsPerX : integer read GetPixelsPerX;
    property PixelsPerY : integer read GetPixelsPerY;
    property Port : string read GetPort;
    property TopOffset : integer read GetTopOffset;
    { Read/write properties }
    property Copies : integer read GetCopies write SetCopies;
    property Duplex : boolean read GetDuplex write SetDuplex;
    property Orientation : TPrinterOrientation read GetOrientation write SetOrientation;
    property OutputBin : integer {TQRBin} read GetOutputBin write SetOutputBin;

    property PaperSize2 : integer read GetPaperSize2 write SetPaperSize2;
    property PaperLength2 : integer read GetPaperLength2 write SetPaperLength2;
    property PaperWidth2 : integer read GetPaperWidth2 write setPaperWidth2;

    property Printer : TPrinter read GetPrinter write SetPrinter;
    property Title : string read GetTitle write SetTitle;

    function PaperSizeSupported2(value : integer; Var Index : integer): boolean;
  end;

  { TQRPrinterSettings }
  TQRPrinterSettings = class(TPersistent)
  private
    FCopies : integer;
    FDuplex : boolean;
    FOrientation : TPrinterOrientation;
    FOutputBin : integer; //TQRBin;
    FPaperSize2: integer;
    FPrinterIndex : integer;
    FTitle : string;
    FFirstPage : integer;
    FLastPage : integer;
  public
    constructor Create;
    procedure ApplySettings(APrinter : TQRPrinter);
    property Copies : integer read FCopies write FCopies;
    property Duplex : boolean read FDuplex write FDuplex;
    property FirstPage : integer read FFirstPage write FFirstPage;
    property LastPage : integer read FLastPage write FLastPage;
    property Orientation : TPrinterOrientation read FOrientation write FOrientation;
    property OutputBin : integer {TQRBin} read FOutputBin write FOutputBin;
    property PaperSize2: integer read FPaperSize2 write FPaperSize2;
    property PrinterIndex : integer read FPrinterIndex write FPrinterIndex;
    property Title : string read FTitle write FTitle;
  end;

  { TQRPrinter related declarations }

  TQRPrinterDestination = (qrdMetafile, qrdPrinter);

  TQRPrinterStatus = (mpReady, mpBusy, mpFinished);

  TQRGenerateToPrinterEvent = procedure of object;
  TQRPrintSetupEvent = procedure of object;
  TQRPreviewEvent = procedure of object;
  TQRAfterPrintEvent = procedure (Sender : TObject) of object;
  TQRAfterPreviewEvent = procedure (Sender : TObject) of object;

  { TQRPrinter }
  TQRPrinter = class(TPersistent)
  private
    aPrinter : TPrinter;
    aPrinterSettings : TPrinterSettings;
    aStream : TQRStream;
    FAfterPrintEvent : TQRAfterPrintEvent;
    FAfterPreviewEvent : TQRAfterPreviewEvent;
    FAvailablePages : integer;
    FCancelled : boolean;
    FCanvas : TCanvas;
    FDestination : TQRPrinterDestination;
    FFirstPage : integer;
    FLastpage : integer;
    FLeftWaste : integer;
    FMessageReceiver : TWinControl;
    FMetafile : TMetafile;
    FOnGenerateToPrinterEvent : TQRGenerateToPrinterEvent;
    FOnPreviewEvent : TNotifyEvent;
    FOnPrintSetupEvent : TQRPrintSetupEvent;
    FPage : TMetafile;
    FPageCount : integer;
    FPageNumber : integer;
    FPrinterOK : boolean;
    FProgress : integer;
    FTitle : string;
    FTopWaste : integer;
    FShowingPreview : boolean;
    FStatus : TQRPrinterStatus;
    FXFactor : extended;
    FYFactor : extended;
    PageList : TQRPageList;
    function CurrentPageOK : boolean;
    function GetLeftWaste : integer;
    function GetBin : Integer; //TQRBin;
    function GetCanvas : TCanvas;
    function GetCompression : boolean;
    function GetCopies : integer;
    function GetDuplex : boolean;
    function GetOrientation : TPrinterOrientation;

    function GetPaperSize2 : integer;
    function GetPaperWidth2: integer;
    function GetPaperLength2 : integer;

    function GetPrinterIndex : integer;
    function GetPrinters : TStrings;
    function GetTopWaste : integer;
    procedure CreateMetafileCanvas;
    procedure CreatePrinterCanvas;
    procedure EndMetafileCanvas;
    procedure EndPrinterCanvas;
    procedure SetAvailablePages(Value : integer);
    procedure SetBin(Value : Integer);
    procedure SetCompression(Value : boolean);
    procedure SetCopies(Value : integer);
    procedure SetDestination(Value : TQRPrinterDestination);
    procedure SetDuplex(Value : boolean);
    procedure SetOrientation(Value : TPrinterOrientation);
    procedure SetPageNumber(Value : integer);

    procedure SetpaperSize2(value : integer);
    procedure SetPaperLength2(value : integer);
    procedure SetPaperWidth2(value : integer);

    procedure SetPrinterIndex(Value : integer);
    procedure SetProgress(Value : integer);
    procedure SetShowingPreview(Value : boolean);
  public
    constructor Create;
    destructor Destroy; override;
    function GetPage(Value : integer) : TMetafile;
    function XPos(Value : extended) : integer;
    function XSize(Value : extended) : integer;
    function YPos(Value : extended) : integer;
    function YSize(Value : extended) : integer;

    function PaperLengthValue2 : integer;
    function PaperWidthValue2 : integer;
{mjch}
    function  GetDevMode : THANDLE;
    procedure CopyDevMode(FromDevMode, ToDevMode: THandle);
    function GetTPrinter : TPrinter;

    procedure AbortDoc;
    procedure BeginDoc;
    procedure Cancel;
    procedure Cleanup;
    procedure EndDoc;
    procedure Load(Filename : string);
    procedure NewPage;
    procedure Preview;
    procedure Print;
    procedure PrintSetup;
    procedure Save(Filename : string);
    property AfterPreview : TQRAfterPreviewEvent read FAfterPreviewEvent write FAfterPreviewEvent;
    property AfterPrint : TQRAfterPrintEvent read FAfterPrintEvent write FAfterPrintEvent;
    property AvailablePages : integer read FAvailablePages write SetAvailablePages;
    property OutputBin : integer {TQRBin} read GetBin write SetBin;
    property Cancelled : boolean read FCancelled write FCancelled;
    property Canvas : TCanvas read GetCanvas;
    property Compression : boolean read GetCompression write SetCompression;
    property Copies : integer read GetCopies write SetCopies;
    property Destination : TQRPrinterDestination read FDestination write SetDestination;
    property Duplex : boolean read GetDuplex write SetDuplex;
    property FirstPage : integer read FFirstPage write FFirstPage;
    property LastPage : integer read FLastPage write FLastPage;
    property LeftWaste : integer read GetLeftWaste;
    property MessageReceiver : TWinControl read FMessageReceiver write FMessageReceiver;
    property Orientation : TPrinterOrientation read GetOrientation write SetOrientation;
    property OnGenerateToPrinter : TQRGenerateToPrinterEvent read FOnGenerateToPrinterEvent
                                                             write FOnGenerateToPrinterEvent;
    property OnPreview : TNotifyEvent read FOnPreviewEvent write FOnPreviewEvent;
    property OnPrintSetup : TQRPrintSetupEvent read FOnPrintSetupEvent write FOnPrintSetupEvent;
    property Page : TMetafile read FPage;
    property PageCount : integer read FPageCount write FPageCount;
    property PageNumber : Integer read FPageNumber write SetPageNumber;

    property PaperSize2 : integer read GetPaperSize2 write SetPaperSize2;
    property PaperWidth2 : integer read GetPaperWidth2 write SetPaperWidth2;
    property PaperLength2: integer read GetPaperLength2 write SetPaperLength2;

    property PrinterIndex : integer read GetPrinterIndex write SetPrinterIndex;
    property PrinterOK : boolean read FPrinterOK;
    property Printers : TStrings read GetPrinters;
    property Progress : integer read FProgress write SetProgress;
    property ShowingPreview : boolean read FShowingPreview write SetShowingPreview;
    property Status : TQRPrinterStatus read FStatus;
    property Title : string read FTitle write FTitle;
    property TopWaste : integer read GetTopWaste;
    property XFactor : extended read FXFactor write FXFactor;
    property YFactor : extended read FYFactor write FYFactor;
  end;

  procedure Register;

var
  UseDefaultPrinter : Boolean = False; 

implementation {uses StStrS;{, LogUtil;}


var
{  ArgSeparator : Char;}
  FQRPrinter : TQRPrinter;

const
  cQRPFormatVersion = 3;

type
  TQRFileHeader = record
    FormatVersion : word;                   { File format version }
    QRVersion : word;                       { QR version }
    PageSize : integer;
    PageCount : integer;
    CreateDateTime : TDateTime;
    Portrait : boolean;                     { field added in header version 2 }
    Compression : byte;                     { 0 - no compression, 1 - splay }
    EmptySpace : array[0..100] of byte;
  end;


function TempFilename : string;
var
  AName,
  ADir : array[0..255] of char;
begin
  GetTempPath(255, aDir);
  GetTempFilename(aDir, PChar('QRP'), 0, aName);
  result := StrPas(aName);
end;

{ TQRStream }

constructor TQRStream.Create(MemoryLimit : longint);
begin
  inherited Create;
  FInMemory := true;
  MemoryStream := TMemoryStream.Create;
  FMemoryLimit := MemoryLimit;
  InitializeCriticalSection(FLock);
end;

constructor TQRStream.CreateFromFile(Filename : string);
begin
  inherited Create;
  FInMemory := false;
  FileStream := TFileStream.Create(Filename, fmOpenRead);
  FMemoryLimit := 0;
  InitializeCriticalSection(FLock);
end;

destructor TQRStream.Destroy;
begin
  LockStream;
  try
    if InMemory then
      MemoryStream.Free
    else
    begin
      FileStream.Free;
      DeleteFile(FFilename);
    end;
  finally
    UnlockStream;
    DeleteCriticalSection(FLock);
  end;
  inherited Destroy;
end;

procedure TQRStream.LockStream;
begin
  EnterCriticalSection(FLock);
end;

procedure TQRStream.UnlockStream;
begin
  LeaveCriticalSection(FLock);
end;

function TQRStream.Write(const Buffer; Count: Longint): Longint;
begin
  LockStream;
  if InMemory then
  begin
    result := MemoryStream.Write(Buffer,Count);
    if MemoryStream.Size > FMemoryLimit then {...this could be optimized somewhat }
    begin
      FFilename := TempFilename;
      FileStream := TFileStream.Create(FFilename, fmCreate or fmOpenReadWrite);
      MemoryStream.SaveToStream(FileStream);
      MemoryStream.Free;
      FInMemory := false;
    end
  end else
    result := FileStream.Write(Buffer,Count);
  UnlockStream;
end;

function TQRStream.Read(var Buffer; Count: Longint): Longint;
begin
  LockStream;
  if InMemory then
    result := MemoryStream.Read(Buffer,Count)
  else
    result := FileStream.Read(Buffer,Count);
  UnlockStream;
end;

function TQRStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  LockStream;
  if InMemory then
    result := MemoryStream.Seek(Offset,Origin)
  else
    result := FileStream.Seek(Offset,Origin);
  UnlockStream;
end;

procedure TQRStream.SaveToStream(AStream : TStream);
var
  Buffer : array[0..10240] of byte;
  BytesRead : longint;
begin
  LockStream;
  Position := 0;
  repeat
    BytesRead := Read(Buffer,10240);
    AStream.Write(Buffer,BytesRead);
  until BytesRead=0;
  UnlockStream;
end;

{ TQRCompress - Based on article by Douglas W. Jonsen and SPLAY.PAS by Kim Kokkonen }

constructor TQRCompress.Create(aStream : TStream; CompressData : boolean);
begin
  Stream := aStream;
  InitializeSplay;
  if CompressData then
    BitPos := 0
  else
    BitPos := 7;
  OutByte := 0;
  CompressFlag := CompressData;
end;

destructor TQRCompress.Destroy;
begin
  if CompressFlag and (BitPos<>0) then
    Stream.Write(OutByte,1);
  inherited Destroy;
end;

procedure TQRCompress.InitializeSplay;
var
  I : DownIndex;
  J : UpIndex;
  K : DownIndex;
begin
  for I := 1 to TwiceMax do
    Up[I] := (I-1) shr 1;
  for J := 0 to PredMax do
  begin
    K := (J+1) shl 1;
    Left[J] := K-1;
    Right[J] := K;
  end;
end;

procedure TQRCompress.Splay(Plain : CodeType);
var
  A, B : DownIndex;
  C, D : UpIndex;
begin
  A := Plain+MaxChar;
  repeat
    C := Up[A];
    if C <> ROOT then
    begin
      D := Up[C];
      B := Left[D];
      if C = B then
      begin
        B := Right[D];
        Right[D] := A;
      end else
        Left[D] := A;
      if A = Left[C] then
        Left[C] := B
      else
        Right[C] := B;
      Up[A] := D;
      Up[B] := C;
      A := D;
    end else
      A := C;
  until A = ROOT;
end;

procedure TQRCompress.Compress(Plain : CodeType);
{ Compress a single byte }
var
  A : DownIndex;
  U : UpIndex;
  Sp : 0..MaxChar;
  Stack : array[UpIndex] of Boolean;
begin
  A := Plain+MaxChar;
  Sp := 0;
  repeat
    U := Up[A];
    Stack[Sp] := (Right[U] = A);
    inc(Sp);
    A := U;
  until A = ROOT;
  repeat
    dec(Sp);
    if Stack[Sp] then
      OutByte := OutByte or BitMask[BitPos];
    if BitPos = 7 then
    begin
      Stream.Write(OutByte, 1); { writebyte }
      BitPos := 0;
      OutByte := 0;
    end else
      inc(BitPos);
  until Sp = 0;
  Splay(Plain);
end;

function TQRCompress.GetByte : Byte;
begin
  Stream.Read(Result, 1);
end;

procedure TQRCompress.Expand(var Expanded : byte);
{ Expand a single byte }
var
  A : DownIndex;
begin
  A := ROOT;
  repeat
    if BitPos = 7 then
    begin
      InByte := GetByte;
      BitPos := 0;
    end else
      inc(BitPos);
    if InByte and BitMask[BitPos] = 0 then
      A := Left[A]
    else
      A := Right[A];
  until A > PredMax;
  dec(A, MaxChar);
  Splay(A);
  Expanded := A;
end;

{ TQRPageList }

constructor TQRPageList.Create;
begin
  inherited Create;
  FPageCount := 0;
  FCompression := false;
  FStream := nil;
  InitializeCriticalSection(FLock);
end;

destructor TQRPageList.Destroy;
begin
  DeleteCriticalSection(FLock);
  if assigned(FStream) then
  begin
    FStream.Free;
    FStream := nil;
  end;
  inherited Destroy;
end;

procedure TQRPageList.Clear;
begin
  FPageCount := 0;
end;

procedure TQRPageList.LockList;
begin
  EnterCriticalSection(FLock);
end;

procedure TQRPageList.UnlockList;
begin
  LeaveCriticalSection(FLock);
end;

procedure TQRPageList.Finish;
begin
  WriteFileHeader;
end;

procedure TQRPageList.LoadFromFile;
begin
  if assigned(FStream) then
    Stream.Free;
  Stream := TQRStream.CreateFromFile(Filename);
  ReadFileHeader;
end;

procedure TQRPageList.SaveToFile(Filename : string);
var
  AStream : TFileStream;
begin
  AStream := TFileStream.Create(Filename,fmCreate or fmOpenReadWrite);
  Stream.SaveToStream(AStream);
  AStream.Free;
end;

procedure TQRPageList.SeekToFirst;
begin
  Stream.Position := SizeOf(TQRFileHeader);
end;

procedure TQRPageList.SeekToLast;
var
  PrevPosition : longint;
begin
  Stream.Seek(-SizeOf(PrevPosition), soFromEnd);
  Stream.Read(PrevPosition,SizeOf(PrevPosition));
  Stream.Position := PrevPosition;
end;

procedure TQRPageList.SeekToPage(PageNumber : integer);
var
  ThisPageNum : longint;
  NextPosition : longint;
  PrevPosition : longint;
begin
  if PageNumber = 1 then
    SeekToFirst
  else
    if PageNumber=PageCount then
      SeekToLast
    else
    begin
      if Stream.Position=Stream.Size then
        SeekToLast;
      Stream.Read(ThisPageNum,SizeOf(ThisPageNum));
      Stream.Seek(-SizeOf(ThisPageNum),soFromCurrent);
      if ThisPageNum<PageNumber then
      begin
        repeat
          Stream.Read(ThisPageNum,SizeOf(ThisPageNum));
          if ThisPageNum<>PageNumber then
          begin
            Stream.Read(NextPosition,SizeOf(NextPosition));
            Stream.Position := NextPosition;
          end;
        until ThisPageNum=PageNumber;
        Stream.Seek(-SizeOf(ThisPageNum),soFromCurrent);
      end else
        if ThisPageNum>PageNumber then
        begin
          repeat
            Stream.Read(ThisPageNum,SizeOf(ThisPageNum));
            if ThisPageNum<>PageNumber then
            begin
              Stream.Position := Stream.Position-SizeOf(PrevPosition)-SizeOf(ThisPageNum);
              Stream.Read(PrevPosition,SizeOf(PrevPosition));
              Stream.Position := PrevPosition;
            end;
          until ThisPageNum=PageNumber;
          Stream.Seek(-SizeOf(ThisPageNum),soFromCurrent);
        end;
    end;
end;

function TQRPageList.GetPage(PageNumber : integer) : TMetafile;
var
  Dummy : longint;
  TempStream : TMemoryStream;
  aByte : byte;
  BytesToGet : longint;
  I : longint;
begin
  if PageNumber>PageCount then
    result := nil
  else
  try
    LockList;
    SeekToPage(PageNumber);
    Stream.Read(Dummy,SizeOf(Dummy));
    Stream.Read(Dummy,SizeOf(Dummy));
    BytesToGet := BytesToGet-Stream.Position;
    result := TMetafile.Create;
    if Compression then
    begin
      Stream.Read(BytesToGet,SizeOf(BytesToGet));
      TempStream := TMemoryStream.Create;
      aCompressor := TQRCompress.Create(Stream,false);
      for I := 1 to BytesToGet do
      begin
        aCompressor.Expand(aByte);
        TempStream.Write(aByte,1);
      end;
      aCompressor.Free;
      TempStream.Position := 0;
      result.LoadFromStream(TempStream);
      TempStream.Free;
    end else
      result.LoadFromStream(Stream);
    Stream.Read(Dummy,SizeOf(Dummy));
  finally
    UnlockList;
  end;
end;

procedure TQRPageList.ReadFileHeader;
var
  aFileHeader : TQRFileHeader;
begin
  Stream.Position := 0;
  Stream.Read(aFileHeader, SizeOf(aFileHeader));
  FPageCount := aFileHeader.PageCount;
end;

procedure TQRPageList.WriteFileHeader;
var
  aFileHeader : TQRFileHeader;
begin
  Stream.Position := 0;
  aFileHeader.FormatVersion := cQRPFormatVersion;
  aFileHeader.QRVersion := cQRVersion;
  aFileHeader.PageCount := PageCount;
  aFileHeader.CreateDateTime := Now;
  if Compression then
    aFileHeader.Compression := 1
  else
    aFileHeader.Compression := 0;
  Stream.Write(aFileHeader, SizeOf(aFileHeader));
end;

procedure TQRPageList.AddPage(aMetafile : TMetafile);
var
  I,
  SavePos1,
  SavePos2,
  SavePos3 : longint;
  TempStream : TMemoryStream;
  aByte : byte;

  procedure SavePreInfo;
  var
    aPageCount : longint;
  begin
    aPageCount := FPageCount;
    Stream.Position := Stream.Size;
    SavePos1 := Stream.Position;                    { Store start position }
    Stream.Write(aPageCount, SizeOf(aPageCount));   { Write page number }
    SavePos2 := Stream.Position;                    { Store metafile size pos }
    Stream.Write(SavePos2, SizeOf(SavePos2));       { Reserve space for size }
  end;

  procedure SavePostInfo;
  begin
    Stream.Write(SavePos1, Sizeof(SavePos1));       { Store previous start }
    SavePos3 := Stream.Position;                    { Store post of next }
    Stream.Position := SavePos2;                    { Go back to reserved pos }
    Stream.Write(SavePos3, Sizeof(SavePos3));       { Save pos of next};
    Stream.Position := SavePos3;                    { Go to end of stream }
  end;

begin
  try
    LockList;
    inc(FPageCount);
    if PageCount = 1 then
      WriteFileHeader;
    if Compression then
    begin
      TempStream := TMemoryStream.Create;
      AMetafile.SaveToStream(TempStream);
      SavePreInfo;
      aCompressor := TQRCompress.Create(Stream,true);
      TempStream.Position := 0;
      I := TempStream.Size;
      Stream.Write(I,SizeOf(I));
      for I := 0 to TempStream.Size - 1 do
      begin
        TempStream.Read(aByte,1);
        aCompressor.Compress(aByte);
      end;
      aCompressor.Free;
      TempStream.Free;
      SavePostInfo;
    end else
    begin
      SavePreInfo;
      AMetaFile.SaveToStream(Stream);               { Save the metafile }
      SavePostInfo;
    end;
  finally
    UnlockList;
  end;
end;
{ TQRPreviewImage }

constructor TQRPreviewImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Height := 50;
  Width := 100;
  Zoom := 100;
  QRPrinter := nil;
  ImageOK := false;
  FPageNumber := 1;
end;

destructor TQRPreviewImage.Destroy;
begin
  if ImageOK then
    aMetafile.Free;
  inherited Destroy;
end;

procedure TQRPReviewImage.PaintPage;
begin
  { Paint page background }
  if ImageOK or (csDesigning in ComponentState) then
    with Canvas do
    begin
      Brush.Color := clWhite;
      Pen.Color := clWhite;
      Rectangle(1, 1, Width - cQRPageFrameWidth - cQRPageShadowWidth, Height - cQRPageFrameWidth - cQRPageShadowWidth);
    end;
  if ImageOK then
  begin
    { Paint the metafile }

    Canvas.StretchDraw(rect(0, 0, Width, Height),aMetafile);
  end;
  { Paint frame around page }
  if ImageOK or (csDesigning in ComponentState) then
    with Canvas do
    begin
      Pen.Color := cQRPageShadowColor;
      Pen.Width := cQRPageFrameWidth;
      MoveTo(0,0);
      LineTo(0,Height - cQRPageFrameWidth - cQRPageShadowWidth);
      LineTo(Width - cQRPageFrameWidth - cQRPageShadowWidth, Height - cQRPageFrameWidth - cQRPageShadowWidth);
      LineTo(Width - cQRPageFrameWidth - cQRPageShadowWidth, 0);
      LineTo(0, 0);
      Brush.Color := cQRPageShadowColor;
      Rectangle(Width - cQRPageShadowWidth, cQRPageShadowWidth, Width, Height);
      Rectangle(cQRPageShadowWidth, Height - cqrPageShadowWidth, Width, Height);
    end;
end;

procedure TQRPreviewImage.Paint;
begin
  PaintPage;
end;

procedure TQRPreviewImage.SetPageNumber(Value : integer);
begin
  FPageNumber := Value;
  if assigned(aMetafile) then
    aMetafile.Free;
  aMetaFile := nil;
  if assigned(FQRPrinter) then
    aMetaFile := QRPrinter.GetPage(Value);
  ImageOK := aMetafile <> nil;
  PaintPage;
end;

{ TbkQRPreview }
constructor TbkQRPreview.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FPreviewImage := TQRPreviewImage.Create(self);
  FPreviewImage.Parent := self;
  with FPreviewImage do
  begin
    Top := 0;
    Left := 0;
  end;
  HorzScrollbar.Tracking := true;
  VertScrollBar.Tracking := true;
  FZoom := 100;
  FQRPrinter := nil;
  ZoomState := qrZoomOther{qrDefaultZoom};
  OnResize := FixValues;
  Height := 250;
  Width := 250;
  FPageNumber := 1;
  FOnPageAvailableEvent := nil;
  FOnProgressUpdateEvent := nil;
end;

destructor TbkQRPreview.Destroy;
begin
  if QRPrinter <> nil then QRPrinter := nil;
  inherited Destroy;
end;

procedure TbkQRPreview.SetQRPrinter(Value : TQRPrinter);
begin
  if assigned(FQRPrinter) and (FQRPrinter.MessageReceiver = self) then
  begin
    FQRPrinter.ShowingPreview := false;
    FQRPrinter.MessageReceiver := nil;
  end;
  FQRPrinter := Value;
  FPreviewImage.QRPrinter := Value;
  if FQRPrinter <> nil then
  begin
    FQRPrinter.MessageReceiver := self;
    FQRPrinter.ShowingPreview := true;
  end;
  PageNumber := 1;
  PreviewImage.PageNumber := 1;
  Invalidate;
  FPreviewImage.OnClick := OnClick;
  FPreviewImage.OnDblClick := OnDblClick;
  FPreviewImage.OnDragDrop := OnDragDrop;
  FPreviewImage.OnDragOver := OnDragOver;
  FPreviewImage.OnEndDrag := OnEndDrag;
  FPreviewImage.OnMouseDown := OnMouseDown;
  FPreviewImage.OnMouseMove := OnMouseMove;
  FPreviewImage.OnMouseUp := OnMouseUp;
end;

procedure TbkQRPreview.CMPageAvailable(var Message : TCM_QRPageAvailable);
begin
  if Message.PageCount = PageNumber then
    UpdateImage;
  if assigned(FOnPageAvailableEvent) then
  try
    FOnPageAvailableEvent(Self, Message.PageCount);
  finally
  end;
end;

procedure TbkQRPreview.CMProgressUpdate(var Message : TCM_QRProgressUpdate);
begin
  if assigned(FOnProgressUpdateEvent) then
  try
    FOnProgressUpdateEvent(Self, Message.Position);
  finally
  end;
end;

procedure TbkQRPreview.SetPageNumber(value : integer);
begin
  if ((Value <> FPageNumber) or (not PreviewImage.ImageOK)) and (Value > 0)
    and assigned(FQRPrinter) and (Value <= QRPrinter.PageCount) then
  begin
    FPreviewImage.PageNumber := Value;
    FPageNumber := Value;
    VertScrollBar.Position := 0;
    HorzScrollBar.Position := 0;
  end;
end;

procedure TbkQRPreview.UpdateImage;
begin
  if assigned(FPreviewImage) and not FPreviewImage.ImageOK and
    (FPreviewImage.PageNumber <= QRPrinter.AvailablePages) then
  begin
    ZoomToWidth;
    FPreviewImage.PageNumber := FPreviewImage.PageNumber;
  end;
end;

procedure TbkQRPreview.UpdateZoom;
begin
  if assigned(FQRPrinter) then
  begin
    with FPreviewImage do
    begin
      Width := round(QRPrinter.XSize(QRPrinter.PaperWidthValue2 / 100 * FZoom)) +
               cQRPageShadowWidth + cQRPageFrameWidth * 2;
      Height := round(QRPrinter.YSize(QRPrinter.PaperLengthValue2 / 100 * FZoom)) +
                cQRPageShadowWidth + cQRPageFrameWidth * 2;
    end
  end else
  begin
    with FPreviewImage do
    begin
      Width := round(2.10 * FZoom) + cQRPageShadowWidth + cQRPageFrameWidth * 2;   {A4}
      Height := round(2.97 * FZoom) + cQRPageShadowWidth + cQRPageFrameWidth * 2;  {A4}
    end;
  end;
  if FPreviewImage.Width < self.Width then
    FPreviewImage.Left := (width - FPreviewImage.width) div 2
  else
    FPreviewImage.Left := 0;
  if FPreviewImage.Height < Height then
    FPreviewImage.Top := ((Height - FPreviewImage.Height) div 2)
  else
    FPreviewImage.Top := 0;
  HorzScrollBar.Position := 0;
  VertScrollBar.Position := 0;
  FPreviewImage.Zoom := FZoom;
end;

procedure TbkQRPreview.FixValues(Sender : TObject);
begin
  if ZoomState = qrZoomToFit then
    ZoomToFit
  else
    if ZoomState = qrZoomToWidth then
      ZoomToWidth;
  UpdateZoom;
end;

procedure TbkQRPreview.SetZoom(Value:integer);
begin
  if (Value >= 2) and (Value <= 2000) then
  begin
    ZoomState := qrZoomOther;
    FZoom := Value;
    UpdateZoom;
  end;
end;

procedure TbkQRPreview.ZoomToFit;
var
  Zoom1,
  Zoom2 : Integer;
begin
  if assigned(FQRPrinter) then
  begin
    Zoom1 := round(Width / QRPrinter.XSize(QRPrinter.PaperWidthValue2) * 95);
    Zoom2 := round(Height / QRPrinter.YSize(QRPrinter.PaperLengthValue2) * 95);
  end else
  begin
    Zoom1 := round((Width / 210) * 95);   {A4}
    Zoom2 := round((Height / 297) * 95);  {A4}
  end;
  if Zoom1 < Zoom2 then
    Zoom := Zoom1
  else
    Zoom := Zoom2;
  ZoomState := qrZoomToFit;
end;

procedure TbkQRPreview.ZoomToWidth;
begin
  if assigned(FQRPrinter) then
    Zoom := round((Width / QRPrinter.XSize(QRPrinter.PaperWidthValue2)) * 90)
  else
    Zoom := round((Width / 297) * 95);   {A4}
  UpdateZoom;
  ZoomState := qrZoomToWidth;
end;

{ TPrinterSettings }

constructor TPrinterSettings.Create;
begin
  inherited Create;
  GetMem(FDevice, 128);
  GetMem(FDriver, 128);
  GetMem(FPort, 128);
  FPaperSize2 := DMPAPER_LETTER;
  FPaperQuikIndex := -1;
  FPrinter := nil;
  FPapers := TStringList.Create;
end;

destructor TPrinterSettings.Destroy;
Var                                                   // Added SPA
  i  : Integer;                                       // Added SPA
begin
  FreeMem(FDevice, 128);
  FreeMem(FDriver, 128);
  FreeMem(FPort, 128);
  
  For i := 0 to Pred( FPapers.Count ) do begin
    TPaperInfo( FPapers.Objects[ i ] ).Free;
    FPapers.Objects[ i ] := nil;
  end;

  FPapers.Free;
  inherited Destroy;
end;

function TPrinterSettings.GetCopies : integer;
begin
  Result := FCopies;
end;

function TPrinterSettings.GetDriver : string;
begin
  Result := StrPas(FDriver);
end;

function TPrinterSettings.GetDuplex : boolean;
begin
  Result := FDuplex;
end;

function TPrinterSettings.GetMaxExtentX : integer;
begin
  Result := FMaxExtentX;
end;

function TPrinterSettings.GetMaxExtentY : integer;
begin
  Result := FMaxExtentY;
end;

function TPrinterSettings.GetMinExtentX : integer;
begin
  Result := FMinExtentX;
end;

function TPrinterSettings.GetMinExtentY : integer;
begin
  Result := FMinExtentY;
end;

function TPrinterSettings.GetOrientation : TPrinterOrientation;
begin
  Result := FOrientation;
end;

function TPrinterSettings.GetOutputBin : integer; //TQRBin;
begin
  Result := FOutputBin;
end;

function TQRPrinter.GetTPrinter : TPrinter;
begin
  result := aPrinter;
end;

function TPrinterSettings.GetPixelsPerX : integer;
begin
  Result := FPixelsPerX;
end;

function TPrinterSettings.GetPixelsPerY : integer;
begin
  Result := FPixelsPerY;
end;

function TPrinterSettings.GetPort : string;
begin
  Result := StrPas(FPort);
end;

function TPrinterSettings.GetTopOffset : integer;
begin
  Result := FTopOffset;
end;

function TPrinterSettings.GetLeftOffset : integer;
begin
  Result := FLeftOffset;
end;

function TPrinterSettings.GetPrinter : TPrinter;
begin
  Result := FPrinter;
end;

function TPrinterSettings.GetTitle : string;
begin
  Result := FTitle;
end;

function TPrinterSettings.Supported(Setting : integer) : boolean;
begin
  if assigned(FPrinter) then
    Supported := Integer(DevMode^.dmFields and LongWord(Setting)) = Setting
  else
    Supported := false;
end;

procedure TPrinterSettings.SetField(aField : integer);
begin
  DevMode^.dmFields := DevMode^.dmFields or LongWord(aField);
end;

procedure TPrinterSettings.GetPrinterSettings;

  procedure GPrinter;
  //loads the following private fields for the printer
  //      FDevice
  //      FDriver
  //      FPort
  //      DeviceMode
  var
    Driver_info_2 : pDriverinfo2;
    Retrieved : dword;
    hPrinter : THandle;
  begin
    FPrinter.GetPrinter(FDevice, FDriver, FPort, DeviceMode);
    if DeviceMode = 0 then
      FPrinter.GetPrinter(FDevice, FDriver, FPort, DeviceMode);
    GetMem(Driver_info_2, 255);
    try
      OpenPrinter(FDevice, hPrinter, nil);
      try
        GetPrinterDriver(hPrinter, nil, 2, Driver_info_2, 255, Retrieved);
      finally
        ClosePrinter( hPrinter);
      end;
      StrLCopy(FDriver, PChar(ExtractFileName(StrPas(Driver_info_2^.PDriverPath)) + #0), 63);
    finally
      FreeMem(Driver_info_2, 255);
    end;
  end;

  procedure GCopies; { Number of copies }
  begin
    if Supported(dm_copies) then
      FCopies := DevMode^.dmCopies
    else
      FCopies := 1;
  end;

  procedure GBin; { Paper bin }
  begin
    if Supported(dm_defaultsource) then
       FOutputBin := DevMode^.dmDefaultSource;
  end;

  procedure GDuplex; { Duplex }
  begin
    if Supported(dm_duplex) and (DevMode^.dmDuplex <> dmdup_simplex) then
      FDuplex := true
    else
      FDuplex := false;
  end;

  procedure GPixelsPer; { Horizontal and Vertical pixels per inch }
  begin
    FPixelsPerX := GetDeviceCaps(FPrinter.Handle, LOGPIXELSX);
    FPixelsPerY := GetDeviceCaps(FPrinter.Handle, LOGPIXELSY);
  end;

  procedure GOffset; { Top left printing offset (waste) }
  var
    PrintOffset: TPoint;
    EscapeFunc: word;
  begin
    EscapeFunc := GetPrintingOffset;
    if Escape(FPrinter.Handle,QueryEscSupport,SizeOf(EscapeFunc), @EscapeFunc,nil) <> 0 then
    begin
      Escape(FPrinter.Handle,GetPrintingOffset,0,nil,@PrintOffset);
      FLeftOffset := round(PrintOffset.X/PixelsPerX*254);
      FTopOffset := round(PrintOffset.Y/PixelsPerY*254);
    end else
    begin
      FLeftOffset := 0;
      FTopOffset := 0;
    end;
  end;

  procedure GPaperSize;
  begin
    FPaperSize2 := DEFAULT_PAPER_SIZE;
    if Supported(dm_papersize) then
      FPaperSize2 := DevMode^.dmPaperSize;
  end;

  procedure GPaperDim;
  var
    PSize : TPoint;
    EscapeFunc : word;
  begin
    EscapeFunc := GetPhysPageSize;
    if Escape(FPrinter.Handle, QueryEscSupport, SizeOf(EscapeFunc), @EscapeFunc, nil) <> 0 then
    begin
      Escape(FPrinter.Handle, GetPhysPageSize, 0, nil, @PSize);
      FPaperWidth := round(PSize.X / PixelsPerX * 254);
      FPaperLength := round(PSize.Y / PixelsPerY * 254);
    end else
    begin
      FPaperWidth := 0;
      FPaperLength := 0;
    end
  end;

  procedure GPaperSizes;
  Var
     I : Integer;
  begin
     For i := 0 to Pred( FPapers.Count ) do begin
        TPaperInfo( FPapers.Objects[ i ] ).Free;         // Added SPA
        FPapers.Objects[ i] := nil;
     end;
     FPapers.Free;
     FPapers := TStringList.Create;
     GetPaperNames(FPrinter,FPapers);
  end;

begin
  if FPrinter<>nil then
  begin
    GPrinter;
    DevMode := GlobalLock(DeviceMode);
    try
      GPixelsPer;
      GCopies;
      GBin;
      GDuplex;
      GOffset;
      GPaperSize;
      GPaperDim;
      GPaperSizes;
    finally
      GlobalUnlock(DeviceMode);
    end;
  end
end;

procedure TPrinterSettings.ApplySettings;
begin
  FPrinter.GetPrinter(FDevice, FDriver, FPort, DeviceMode);
  DevMode := GlobalLock(DeviceMode);
  try
    if PaperSize2 = CUSTOM_PAPER_SIZE then
    begin
      SetField(dm_paperlength);
      DevMode^.dmPaperLength := PaperLength2;
      SetField(dm_paperwidth);
      DevMode^.dmPaperWidth := PaperWidth2;
    end;

    if Supported(dm_duplex) and FDuplex then
    begin
      SetField(dm_duplex);
      DevMode^.dmDuplex := dmdup_horizontal;
    end;

    if Supported(dm_PaperSize) and
       (PaperSize2 <> DEFAULT_PAPER_SIZE) then
    begin
      SetField(dm_papersize);
      DevMode^.dmPaperSize := PaperSize2;
    end;

    if Supported(dm_copies) then
    begin
      SetField(dm_copies);
      DevMode^.dmCopies := FCopies;
    end;

    if Supported(dm_defaultsource) then
    begin
      SetField(dm_defaultsource);
      DevMode^.dmDefaultSource := FOutputBin;
    end;

    if Supported(dm_orientation) then
    begin
      SetField(dm_orientation);
      if Orientation=poPortrait then
        DevMode^.dmOrientation := dmorient_portrait
      else
        DevMode^.dmOrientation := dmorient_landscape;
    end;
    FPrinter.SetPrinter(FDevice, FDriver, FPort, DeviceMode);
  finally
     GlobalUnlock(DeviceMode);
  end;
end;

procedure TPrinterSettings.SetCopies(Value : integer);
begin
  if Supported(dm_copies) then
    FCopies := Value;
end;

procedure TPrinterSettings.SetDuplex(Value : boolean);
begin
  if Supported(dm_duplex) then
    FDuplex := Value;
end;

procedure TPrinterSettings.SetOrientation(Value : TPrinterOrientation);
begin
  if Supported(dm_orientation) then
    FOrientation := Value;
end;

procedure TPrinterSettings.SetOutputBin(Value : integer);
begin
  if Supported(dm_defaultsource) then
    FOutputBin := Value;
end;

procedure TPrinterSettings.SetPrinter(Value : TPrinter);
begin
  FPrinter := Value;
  if (Value <> nil) and (FPrinter.Printers.Count > 0) then
    GetPrinterSettings;
end;

procedure TPrinterSettings.SetTitle(Value : string);
begin
  FTitle := Value;
end;

function TPrinterSettings.GetPaperSize2: integer;
begin
  result := FPaperSize2;
end;

procedure TPrinterSettings.SetPaperSize2(Value: integer);
var
  Index : integer;
begin
  if PaperSizeSupported2(Value,Index) then
  begin
    FPaperSize2 := Value;
    FPaperQuikIndex := Index;
  end;

  if (Value = DEFAULT_PAPER_SIZE) then
  begin
    FPaperSize2 := DEFAULT_PAPER_SIZE;
    FPaperQuikIndex := -1;
  end;
end;

function TPrinterSettings.PaperSizeSupported2(value: integer; var Index : integer): boolean;
var i : integer;
begin
   result := false;
   Index := -1;

   for i := 0 to Pred(FPapers.Count) do
     if Value = TPaperInfo(FPapers.Objects[i]).index then
     begin
        Index := i;
        result := true;
        exit;
     end;
end;

function TPrinterSettings.GetPaperLength2: integer;
var
  Obj    : TPaperInfo;
begin
  Result := FPaperLength;

   if (PaperSize2 <> CUSTOM_PAPER_SIZE) and (PaperSize2 <> DEFAULT_PAPER_SIZE) then
   begin
      Obj := PaperObj(PaperSize2);
      if Assigned(Obj) then result := Obj.Size.y;
   end;
end;

procedure TPrinterSettings.SetPaperLength2(Value: integer);
begin
  if PaperSize2 = CUSTOM_PAPER_SIZE then
    FPaperLength := Value;
end;

function TPrinterSettings.GetPaperWidth2: integer;
var
  Obj    : TPaperInfo;
begin
   Result := FPaperWidth;

   if (PaperSize2 <> CUSTOM_PAPER_SIZE) and (PaperSize2 <> DEFAULT_PAPER_SIZE) then
   begin
      Obj := PaperObj(PaperSize2);
      if Assigned(Obj) then result := Obj.Size.x;
   end;
end;

procedure TPrinterSettings.SetPaperWidth2(Value: integer);
begin
  if PaperSize2 = CUSTOM_PAPER_SIZE then
    FPaperWidth := Value;
end;

function TPrinterSettings.PaperObj(Size: integer): TPaperInfo;
var
  TempObj : TPaperInfo;
  i      : integer;
begin
  result := nil;

  if FPaperQuikIndex >= 0 then   {paperindex is set by SetPaperSize2}
  begin
     tempObj := TPaperInfo(FPapers.Objects[FPaperQuikIndex]);
     if (tempObj.Index = Size) then
     begin
        result := tempObj;
        exit;     {confirmed correct paper info}
     end;
  end;

  {find paperType}
  for i := 0 to Pred(FPapers.count) do
  begin
    tempObj := TPaperInfo(FPapers.Objects[i]);
    if tempObj.index = Size then
    begin
        result := tempObj;
        exit;
    end;
  end;
end;

{ TQRPrinterSettings }

constructor TQRPrinterSettings.Create;
begin
  PaperSize2 := DMPAPER_A4;
  Copies := 1;
  Duplex := false;
  Title := '';
  FFirstPage := 0;
  FLastPage := 0;
  FPrinterIndex := -1;
end;

procedure TQRPrinterSettings.ApplySettings(APrinter : TQRPrinter);
begin
  aPrinter.PrinterIndex := PrinterIndex;
  aPrinter.PaperSize2 := PaperSize2;
  aPrinter.Copies := Copies;
  aPrinter.Duplex := Duplex;
  aPrinter.Orientation := Orientation;
  aPrinter.OutputBin := OutputBin;
  aPrinter.Title := Title;
end;

{ TQRPrinter }
procedure ResetDriver(aPrinter : TPrinter);
var
  Device, Name, Port: array[0..255] of Char;
  DevMode: THandle;
begin
  aPrinter.GetPrinter( Device, Name, Port , DevMode );
  aPrinter.SetPrinter( Device, Name, Port , 0 );
end;

constructor TQRPrinter.Create;
begin
  FPrinterOK := Printer.Printers.Count > 0;
  aPrinter := TPrinter.Create;
  aPrinterSettings := TPrinterSettings.Create;
  if PrinterOK then
  begin
    aPrinterSettings.Printer := aPrinter;
    if Printer.PrinterIndex > aPrinter.Printers.Count then
      aPrinter.PrinterIndex := Printer.PrinterIndex;
  end;
  FTopWaste := aPrinterSettings.TopOffset;
  FLeftWaste := aPrinterSettings.LeftOffset;
  FDestination := qrdMetafile;
  FStatus := mpReady;
  FPageNumber := 0;
  PageList := TQRPageList.Create;
{  FOnProgressChangeEvent := nil;}
  FAvailablePages := 0;
  FXFactor := 1;
  FYFactor := 1;
  FMessageReceiver := nil;
  FAfterPreviewEvent := nil;
  FAfterPrintEvent := nil;
  FShowingPreview := false;
end;

destructor TQRPrinter.Destroy;
begin
  if Status <> mpReady then
    Cleanup;
  aPrinter.Free;
  aPrinterSettings.Free;
  PageList.Free;
  inherited Destroy;
end;

function TQRPrinter.GetDevMode : THANDLE;
var
   Dev,Driv,Port : Array[0..255] of char;
   DeviceM       : THandle;
begin
   aPrinter.GetPrinter(Dev,Driv,Port,DeviceM);
   if DeviceM = 0 then
      aPrinter.GetPrinter(Dev,Driv,Port,DeviceM);
    result := DeviceM;
end;

procedure TQRPrinter.Cleanup;
begin
  if Status = mpBusy then
    Cancel;
  if assigned(aStream) then
  begin
    aStream.Free;
    aStream := nil;
    PageList.Stream := nil;
  end;
  PageList.Clear;
  FStatus := mpReady;
end;

function TQRPrinter.XPos(Value : extended) : integer;
begin
  result := round((Value - FLeftWaste) * XFactor);
end;

function TQRPrinter.XSize(Value : extended) : integer;
begin
  result := round(Value * XFactor);
end;

function TQRPrinter.YPos(Value : extended) : integer;
begin
  result := round((Value - FTopWaste) * YFactor);
end;

function TQRPrinter.YSize(Value : extended) : integer;
begin
  result := round(Value * YFactor);
end;

function TQRPrinter.GetCompression : boolean;
begin
  Result := PageList.Compression;
end;

procedure TQRPrinter.SetCompression(Value : boolean);
begin
  PageList.Compression := Value;
end;

{ TQRPrinter methods related to printer driver settings }
function TQRPrinter.GetBin : integer;
begin
  Result := aPrinterSettings.OutputBin;
end;

function TQRPrinter.GetCopies;
begin
  Result := aPrinterSettings.Copies;
end;

function TQRPrinter.GetDuplex : boolean;
begin
  Result := aPrinterSettings.Duplex;
end;

function TQRPrinter.GetLeftWaste : integer;
{ Return left unprintable area in 0.1 mm }
begin
  if Destination=qrdPrinter then
    Result := aPrinterSettings.LeftOffset
  else
    Result := 0;
end;

function TQRPrinter.GetOrientation : TPrinterOrientation;
begin
  Result := aPrinterSettings.Orientation;
end;

function TQRPrinter.GetPrinterIndex : integer;
{ Return currently selected printer }
begin
  result := aPrinter.PrinterIndex;
end;

function TQRPrinter.GetPrinters : TStrings;
{ Return list of printers }
begin
  result := aPrinter.Printers;
end;

function TQRPrinter.GetTopWaste : integer;
{ Return unprintable area on top in 0.1 mm }
begin
  if Destination=qrdPrinter then
    Result := aPrinterSettings.TopOffset
  else
    Result := 0;
end;

procedure TQRPrinter.SetBin(Value : integer); //TQRBin);
begin
  aPrinterSettings.Outputbin := Value;
end;

procedure TQRPrinter.SetCopies(Value : integer);
begin
  aPrinterSettings.Copies := Value;
end;

procedure TQRPrinter.SetDestination(Value : TQRPrinterDestination);
begin
  FDestination := Value;
end;

procedure TQRPrinter.SetDuplex(Value : Boolean);
begin
  aPrinterSettings.Duplex := Value;
end;

procedure TQRPrinter.SetOrientation(Value : TPrinterOrientation);
begin
  aPrinterSettings.Orientation := Value;
end;

function TQRPrinter.GetPage(Value : integer) : TMetafile;
begin
  if (Status in [mpBusy, mpFinished]) and
     (Value > 0) and (Value <= FPageCount) then
    Result := PageList.GetPage(Value)
  else
    Result := nil;
end;

procedure TQRPrinter.SetPageNumber(Value : integer);
begin
  if (PageNumber > 0) and (PageNumber <= FPageCount) then
  begin
    FPage := GetPage(Value);
    FPageNumber := Value;
  end;
end;

procedure TQRPrinter.SetPrinterIndex(Value : integer);
var  {mjch}
  IndexChanged : boolean;
begin
  if PrinterOK then
  begin
    IndexChanged := aPrinter.PrinterIndex <> Value;
    if indexChanged then
    begin
       aPrinter.PrinterIndex := Value;
       ResetDriver(aPrinter);             {reset devmode}
    end;
    aPrinterSettings.GetPrinterSettings;  {reload devmode}
  end;
end;

{ TQRPrinter methods related to printing }

function TQRPrinter.GetCanvas;
begin
  result := FCanvas;
end;

procedure TQRPrinter.CreateMetafileCanvas;
var refDC : HdC;
begin
  FMetafile := TMetafile.Create;
  FMetaFile.Width := XSize( PaperWidthValue2);
  FMetaFile.Height := YSize( PaperLengthValue2);
  if UseDefaultPrinter then
     try
        Printer.PrinterIndex := -1; // Default printer
        refDC := Printer.Handle;
     except
        refDC := 0;
     end
  else
     refDC := 0;
  FCanvas := TMetafileCanvas.Create(FMetafile, refDC);
end;

function TQRPrinter.CurrentPageOK : boolean;
begin
  Result := true;
  if (FirstPage > 0) and (PageCount < FirstPage) then
    Result := false;
  if (LastPage > 0) and (PageCount > LastPage) then
    Result := false;
end;

procedure TQRPrinter.CreatePrinterCanvas;

  procedure ApplyThem;
  begin
    with APrinterSettings do begin
      FPrinter.GetPrinter(FDevice, FDriver, FPort, DeviceMode);
      DevMode := GlobalLock(DeviceMode);
      try
        if Supported(dm_duplex) and FDuplex then
        begin
          SetField(dm_duplex);
          DevMode^.dmDuplex := dmdup_horizontal;
        end;

        if Supported(dm_defaultsource) then
        begin
          SetField(dm_defaultsource);
          DevMode^.dmDefaultSource := FOutputBin; //cQRBinTranslate[OutputBin];
        end;

        if FPrinter.Printing then
           ResetDC(FPrinter.Canvas.Handle, DevMode^);
      finally
        GlobalUnlock(DeviceMode);
      end;
    end;
  end;

begin
  if not aPrinter.Printing then
  begin
    aPrinter.Title := Title;
    aPrinter.BeginDoc;
    ApplyThem;
    FCanvas := aPrinter.Canvas;
  end else
  begin
    StartPage(aPrinter.Handle);
    FCanvas := aPrinter.Canvas;
    Canvas.Refresh;
  end;
end;

procedure TQRPrinter.EndMetafileCanvas;
begin
  Canvas.Free;
end;

procedure TQRPrinter.EndPrinterCanvas;
begin
  if aPrinter.Printing and (PageCount <> LastPage) then
    aPrinter.NewPage;
end;

procedure TQRPrinter.NewPage;
begin
  if Status <> mpBusy then
    raise EQRError.Create(LoadStr(SqrIllegalNewPage));
  if PageNumber > 0 then
  begin
    case Destination of
      qrdMetafile: begin
                    EndMetafileCanvas;
                    PageList.AddPage(FMetafile);
                    FMetafile.Free;
                  end;
      qrdPrinter: begin
                    if CurrentPageOK then
                      EndPrinterCanvas
                    else
                    begin
                      EndMetafileCanvas;
                      FMetaFile.Free;
                    end;
                  end;
    end;
    AvailablePages := AvailablePages + 1;
  end;
  inc(FPageCount);
  inc(FPageNumber);
  case Destination of
    qrdMetafile : CreateMetafileCanvas;
    qrdPrinter : if CurrentPageOK then
                   CreatePrinterCanvas
                 else
                   CreateMetafileCanvas;
  end;
end;

procedure TQRPrinter.Cancel;
begin
  Cancelled := true;
end;

procedure TQRPrinter.BeginDoc;
begin
  FMetafile := nil;
  FAvailablePages := 0;
  FCancelled := false;
  if Destination = qrdPrinter then begin
     aPrinterSettings.ApplySettings;
  end;
  FTopWaste := TopWaste;
  FLeftWaste := LeftWaste;
  if Status <> mpReady then
    raise EQRError.Create(LoadStr(SqrQRPrinterNotReady))
  else
  begin
    FPageNumber := 0;
    FPageCount := 0;
    FStatus := mpBusy;
    case Destination of
      qrdMetafile : begin
                      aStream := TQRStream.Create(100000);
                      PageList.Stream := aStream;
                      YFactor := Screen.PixelsPerInch / 254;
                      XFactor := YFactor;
                    end;
      qrdPrinter : begin
                     XFactor := GetDeviceCaps(aPrinter.Handle, LogPixelsX) / 254;
                     YFactor := GetDeviceCaps(aPrinter.Handle, LogPixelsY) / 254;
                   end;
    end;
  end;
end;

procedure TQRPrinter.SetAvailablePages(Value : integer);
begin
  FAvailablePages := Value;
  if MessageReceiver <> nil then
    PostMessage(MessageReceiver.Handle, CM_QRPAGEAVAILABLE, Value, 0);
end;

procedure TQRPrinter.SetProgress(Value : integer);
begin
  FProgress := Value;
  if MessageReceiver <> nil then
    PostMessage(MessageReceiver.Handle, CM_QRPROGRESSUPDATE, Value, 0)
end;

procedure TQRPrinter.SetShowingPreview(Value : boolean);
begin
  if ShowingPreview and not Value then
  try
    if Status = mpBusy then Cancel;
    if assigned(FAfterPreviewEvent) then
      FAfterPreviewEvent(Self);
  finally
    FShowingPreview := Value;
  end else
    FShowingPreview := Value;
end;

procedure TQRPrinter.EndDoc;
begin
  case Destination of
    qrdPrinter : begin
                   aPrinter.EndDoc;
                   if (FPageCount > 0) then
                       if not CurrentPageOK then begin
                          EndMetafileCanvas;
                          FMetaFile.Free;
                       end;

                 end;

    qrdMetafile : begin
                    if FPageCount > 0 then
                    begin
                      EndMetafileCanvas;
                      PageList.AddPage(FMetafile);
                      FMetafile.Free;
                    end;
                  end;
  end;
  AvailablePages := AvailablePages + 1;
  FStatus := mpFinished;
  if Destination = qrdMetafile then
    PageList.Finish
  else
    if assigned(FAfterPrintEvent) then
    try
      FAfterPrintEvent(Self);
    finally
    end;
end;

procedure TQRPrinter.AbortDoc;
begin
  case Destination of
    qrdPrinter : aPrinter.Abort;
    qrdMetafile : begin
                    if FMetafile <> nil then
                    begin
                      EndMetafileCanvas;
                      PageList.AddPage(FMetafile);
                      FMetafile.Free;
                    end;
                  end;
  end;
  FStatus := mpFinished;
end;

procedure TQRPrinter.Load(Filename : string);
begin
   //mjch not written
end;

procedure TQRPrinter.Save(Filename : string);
begin
   //mjch not written
end;

procedure TQRPrinter.Preview;
begin
  if assigned(FOnPreviewEvent) then
  try
    FOnPreviewEvent(Self)
  finally
  end else
    ;
end;

procedure TQRPrinter.Print;
type
  TSmallPoint = record
    X,
    Y : integer;
  end;
var
  I : integer;
  Count : integer;
  aPoint : TSmallPoint;
  ASize : TPoint;
  EscapeFunc : word;
  LStat,
  LDriver,
  LLocation : String;
begin
    // Do some basic testing...
    if Destination = qrdPrinter then begin
      if (APrinter.PrinterIndex < 0)
      or (APrinter.PrinterIndex >= Printer.Printers.Count) then begin
          MessageDlg('Printer index out of range, re-select printer first', mtWarning
                     , [mbOk ], 0);
         exit;
      end;

      if not CheckPrinterStatus (APrinter,LStat,LDriver,LLocation) then begin
           if  MessageDlg('Printer Not ready'#13'Print job may fail', mtWarning
                     , [mbOk , mbcancel], 0) <> mrok
            then exit;
      end;
    end;
    Count := 0;
    if assigned(FOnGenerateToPrinterEvent) then
      FOnGenerateToPrinterEvent
    else
      if (Status = mpFinished) and PrinterOK then
      try
        APrinter.Title := Title;
        if APrinter.Printing then
          APrinter.Abort;
        APrinterSettings.ApplySettings;// Done in begindoc..
        APrinter.BeginDoc;
        for I := 1 to PageCount do
        begin
          Application.ProcessMessages;
          PageNumber := I;
          EscapeFunc := GetPhysPageSize;
          if Escape(APrinter.Handle, QueryEscSupport, SizeOf(EscapeFunc), @EscapeFunc, nil) <> 0 then
            Escape(APrinter.Handle, GetPhysPageSize, 0, nil, @ASize);
          EscapeFunc := GetPrintingOffset;
          if Escape(APrinter.Handle, QueryEscSupport, SizeOf(EscapeFunc), @EscapeFunc, nil) <> 0 then
            Escape(APrinter.Handle, GetPrintingOffset, Count, @aPoint, @aPoint);
//          APrinter.Canvas.StretchDraw(Rect(-aPoint.X, -aPoint.Y, aSize.X - aPoint.X, aSize.Y - aPoint.Y), GetPage(I));

          APrinter.Canvas.StretchDraw(Rect(0, 0, APrinter.PageWidth, APrinter.PageHeight), GetPage(I));
          if I < PageCount then APrinter.NewPage;
          if Cancelled then
            APrinter.Abort;
        end
      finally
        if APrinter.Printing then
          APrinter.EndDoc;
      end;
end;

procedure TQRPrinter.PrintSetup;
begin
  if assigned(FOnPrintSetupEvent) then
    FOnPrintSetupEvent;
end;

function QRPrinter : TQRPRinter;
begin
  if FQRPrinter = nil then
    FQRPrinter := TQRPrinter.Create;
  Result := FQRPrinter;
end;

function TQRPrinter.GetPaperSize2: integer;
begin
  result := aPrinterSettings.PaperSize2;
end;

procedure TQRPrinter.SetpaperSize2(value: integer);
begin
  aPrinterSettings.PaperSize2 := Value;
end;

function TQRPrinter.GetPaperLength2: integer;
{ Return physical paper length in 0.1 mm }
begin
  Result := aPrinterSettings.PaperLength2;
end;

function TQRPrinter.GetPaperWidth2: integer;
{ Return physical paper width in 0.1 mm }
begin
  Result := aPrinterSettings.PaperWidth2;
end;

function TQRPrinter.PaperLengthValue2: integer;
var
  Obj : TPaperInfo;
begin
  if Orientation = poPortrait then
     result := aPrinterSettings.GetPaperLength2
  else
  begin
    result := PaperWidth2;
    if (PaperSize2 <> CUSTOM_PAPER_SIZE) then  {dont care now about <> DEFAULT}
    begin
      Obj := aPrinterSettings.PaperObj(PaperSize2);
      if Assigned(Obj) then result := Obj.Size.x;
    end;
  end;
end;

function TQRPrinter.PaperWidthValue2: integer;
var
  Obj : TPaperInfo;
begin
  if Orientation = poPortrait then
    result := aPrinterSettings.GetPaperWidth2
  else
  begin
    result := PaperLength2;
    if (PaperSize2 <> CUSTOM_PAPER_SIZE) then   {dont care now about <> DEFAULT}
    begin
      Obj := aPrinterSettings.PaperObj(PaperSize2);
      if Assigned(Obj) then result := Obj.Size.y;
    end;
  end;
end;

procedure TQRPrinter.SetPaperLength2(value: integer);
{ Sets the paper length in 0.1 mm }
begin
  aPrinterSettings.PaperLength2 := Value;
end;

procedure TQRPrinter.SetPaperWidth2(value: integer);
{ Sets the paper width in 0.01 mm }
begin
  aPrinterSettings.PaperWidth2 := Value;
end;

procedure TQRPrinter.CopyDevMode(FromDevMode, ToDevMode: THandle);
{copies the memory from one devmode to the other}
var
   SizeFrom, SizeTo : cardinal;
   pFrom, pTo : pointer;
begin
   SizeFrom := GlobalSize(FromDevMode);
   SizeTo   := GlobalSize(ToDevMode);

   if SizeFrom = SizeTo then
   begin
      pFrom := GlobalLock(FromDevMode);
      pTo   := GlobalLock(ToDevMode);
      try
         CopyMemory(pTo,pFrom,SizeFrom);
      finally
         GlobalUnlock(FromDevMode);
         GlobalUnlock(ToDevMode);
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure Register;
begin
  RegisterComponents('BankLink QReport', [TbkQRPreview]);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
{  ArgSeparator := ',';}
  FQRPrinter := nil;

finalization
  if FQRPrinter <> nil then
    FQRPrinter.Free;
end.


