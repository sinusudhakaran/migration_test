{##############################################################################}
{# NexusDB: nxllStreams.pas 2.00                                              #}
{# NexusDB Memory Manager: nxllStreams.pas 2.03                               #}
{# Copyright (c) Nexus Database Systems Pty. Ltd. 2003                        #}
{# All rights reserved.                                                       #}
{##############################################################################}
{# NexusDB: Fast memory streams                                               #}
{##############################################################################}

unit nxllStreams;

{$I nxDefine.inc}

interface

uses
  Windows,
  SysUtils,
  Classes,
  nxllFastMove,
  nxllList;

type
  TnxCustomMemoryStream = class(TStream)
  protected {private}
    cmsMemory   : Pointer;
    cmsSize     : Longint;
    cmsPosition : Longint;
  protected
    procedure SetPointer(aPointer: Pointer; aSize: Longint);
  public
    function Read(var aBuffer;
                      aCount  : Longint)
                              : Longint; override;
    function Seek(aOffset : Longint;
                  aOrigin : Word)
                          : Longint; override;

    procedure SaveToStream(aStream: TStream);
    procedure SaveToFile(const aFileName: string);

    function TheStream: TnxCustomMemoryStream;

    property Memory: Pointer
      read cmsMemory;
  end;

{ TnxMemoryStream }

  TnxMemoryStream = class(TnxCustomMemoryStream)
  protected {private}
    msReserveInitial : Longint;
    msReserved       : Longint;
    msReservedBases  : TnxList;

    msCommited       : Longint;
    procedure msSetCapacity(aNewCapacity: Longint);
  protected
    function msRealloc(var aNewCapacity: Longint): Pointer; virtual;
  public
    constructor Create(aInitial : LongInt = 0);
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromStream(aStream: TStream);
    procedure LoadFromFile(const aFileName: string);
    procedure SetSize(aNewSize: Longint); override;
    function Write(const aBuffer; aCount: Longint): Longint; override;

    property Capacity: Longint
      read msCommited
      write msSetCapacity;
  end;

  TnxStaticMemoryStream = class(TnxCustomMemoryStream)
  public
    constructor Create(aMemory: Pointer; aSize: Longint);
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

  TnxReader = class(TReader)
  public
    constructor Create(aStream: TStream);

    function TheReader: TnxReader;
  end;

  TnxWriter = class(TWriter)
  public
    constructor Create(aStream: TStream);

    procedure WriteAnsiString(const aString: string);
    function TheWriter: TnxWriter;
  end;

procedure nxAnsiStringWriter(const aString : string;
                                   aWriter : TWriter);

implementation

uses
  nxllTypes,
  nxllMemoryManager,
  nxllUtils;

const
  nxcl_1KB                        = 1024;

  nxcl_SystemPageSize             =  4 * nxcl_1KB;
  nxcl_SystemAllocationSize       = 64 * nxcl_1KB;

{===TnxCustomMemoryStream======================================================}
function TnxCustomMemoryStream.Read(var aBuffer; aCount: Longint): Longint;
begin
  if (cmsPosition >= 0) and (aCount >= 0) then begin
    Result := cmsSize - cmsPosition;
    if Result > 0 then begin
      if Result > aCount then
        Result := aCount;
      nxMove(Pointer(Longint(cmsMemory) + cmsPosition)^, aBuffer, Result);
      Inc(cmsPosition, Result);
      Exit;
    end;
  end;
  Result := 0;
end;
{------------------------------------------------------------------------------}
procedure TnxCustomMemoryStream.SaveToFile(const aFileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(aFileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;
{------------------------------------------------------------------------------}
procedure TnxCustomMemoryStream.SaveToStream(aStream: TStream);
begin
  if cmsSize <> 0 then
    aStream.WriteBuffer(cmsMemory^, cmsSize);
end;
{------------------------------------------------------------------------------}
function TnxCustomMemoryStream.Seek(aOffset: Longint; aOrigin: Word): Longint;
begin
  case aOrigin of
    soFromBeginning: cmsPosition := aOffset;
    soFromCurrent: Inc(cmsPosition, aOffset);
    soFromEnd: cmsPosition := cmsSize + aOffset;
  end;
  Result := cmsPosition;
end;
{------------------------------------------------------------------------------}
procedure TnxCustomMemoryStream.SetPointer(aPointer: Pointer; aSize: Longint);
begin
  cmsMemory := aPointer;
  cmsSize := aSize;
end;
{------------------------------------------------------------------------------}
function TnxCustomMemoryStream.TheStream: TnxCustomMemoryStream;
begin
  Result := Self;
end;
{==============================================================================}



{===TnxMemoryStream============================================================}
procedure TnxMemoryStream.Clear;
begin
  msSetCapacity(0);
  cmsSize := 0;
  cmsPosition := 0;
end;
{------------------------------------------------------------------------------}
constructor TnxMemoryStream.Create(aInitial : Integer);
begin
  if aInitial < nxcl_SystemAllocationSize then
    aInitial := 8 * nxcl_SystemAllocationSize;

  msReserveInitial := ((aInitial + Pred(nxcl_SystemAllocationSize)) div
    nxcl_SystemAllocationSize) * nxcl_SystemAllocationSize;

  inherited Create;
end;
{------------------------------------------------------------------------------}
destructor TnxMemoryStream.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{------------------------------------------------------------------------------}
procedure TnxMemoryStream.LoadFromFile(const aFileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;
{------------------------------------------------------------------------------}
procedure TnxMemoryStream.LoadFromStream(aStream: TStream);
var
  Count: Longint;
begin
  aStream.Position := 0;
  Count := aStream.Size;
  SetSize(Count);
  if Count <> 0 then aStream.ReadBuffer(cmsMemory^, Count);
end;
{------------------------------------------------------------------------------}
function TnxMemoryStream.msRealloc(var aNewCapacity: Longint): Pointer;

  procedure ReleaseAllPages;
  var
    i : Integer;
  begin
    if Assigned(Result) then begin
      if Assigned(msReservedBases) then begin
        for i := 0 to Pred(msReservedBases.Count) do
          if not VirtualFree(msReservedBases[i], 0, MEM_RELEASE) then
            nxRaiseLastOSError(ClassName);
        nxFreeAndNil(msReservedBases);
      end else
        if not VirtualFree(Result, 0, MEM_RELEASE) then
          nxRaiseLastOSError(ClassName);
      Result := nil;
      msReserved := 0;
    end;
  end;

var
  NewReserved   : Longint;
  NewBlock      : Pointer;
begin
  Result := cmsMemory;

  Assert( (Result = nil) xor (msReserved <> 0) );
  Assert( (Result <> nil) or not (msCommited <> 0) );

  if aNewCapacity = 0 then begin
    ReleaseAllPages;
    Exit;
  end;

  aNewCapacity := ((aNewCapacity +
    Pred(nxcl_SystemPageSize)) div nxcl_SystemPageSize) * nxcl_SystemPageSize;

  if aNewCapacity = msCommited then
    Exit;

  if aNewCapacity > msReserved then begin
    NewReserved := msReserved;
    if NewReserved = 0 then
      NewReserved := msReserveInitial;
    if NewReserved >= (High(LongInt) div 2) then
      // if you get this error then you tried to read a structure > 1Gig into memory !!!
      // reconsider what you're doing!
      {$IFNDEF DCC6OrLater}
      System.RunError(1 {reOutOfMemory});
      {$ELSE}
      System.Error(reOutOfMemory);
      {$ENDIF}
    while NewReserved < aNewCapacity do
      NewReserved := NewReserved * 2;

    Assert(NewReserved > msReserved);
    Assert(NewReserved >= aNewCapacity);

    if Assigned(Result) then begin
      { First. Try to just acquire more address space directly after our current
        reserved block. }
      NewBlock := VirtualAlloc(Pointer(Longint(Result) + msReserved),
        NewReserved - msReserved, MEM_RESERVE, PAGE_NOACCESS);
      { Was the address space still available? }
      if Assigned(NewBlock) then begin
        { Yes. Do we alread have a list of reserved base addresses? }
        if not Assigned(msReservedBases) then begin
          { No. Create one. }
          msReservedBases := TnxList.Create(8);
          msReservedBases.Add(Result);
        end;
        { We need this base adress later for releasing the memory... }
        msReservedBases.Add(NewBlock);

        if msReserved > msCommited then
          if not Assigned(VirtualAlloc(Pointer(Longint(Result) + msCommited),
            msReserved - msCommited, MEM_COMMIT, PAGE_READWRITE)) then
            nxRaiseLastOSError(ClassName);

        if not Assigned(VirtualAlloc(NewBlock, aNewCapacity - msReserved, MEM_COMMIT, PAGE_READWRITE)) then
          nxRaiseLastOSError(ClassName);
      end else begin
        { No. We need to acquire a complete new block and move the contents. }
        NewBlock := VirtualAlloc(nil, NewReserved, MEM_RESERVE, PAGE_NOACCESS);
        if not Assigned(NewBlock) then
          nxRaiseLastOSError(ClassName);

        if not Assigned(VirtualAlloc(NewBlock, aNewCapacity, MEM_COMMIT, PAGE_READWRITE)) then begin
          VirtualFree(NewBlock, 0, MEM_RELEASE);
          nxRaiseLastOSError(ClassName);
        end;

        if cmsSize > 0 then
          nxMove(Result^, NewBlock^, cmsSize);

        ReleaseAllPages;

        Result := NewBlock;
      end;
    end else begin
      Result := VirtualAlloc(nil, NewReserved, MEM_RESERVE, PAGE_NOACCESS);
      if not Assigned(Result) then
        nxRaiseLastOSError(ClassName);
      if not Assigned(VirtualAlloc(Result, aNewCapacity, MEM_COMMIT, PAGE_READWRITE)) then begin
        VirtualFree(Result, 0, MEM_RELEASE);
        nxRaiseLastOSError(ClassName);
      end;
    end;
    msReserved := NewReserved;
  end else if aNewCapacity > msCommited then begin
    if not Assigned(VirtualAlloc(Pointer(Longint(Result) + msCommited),
      aNewCapacity - msCommited, MEM_COMMIT, PAGE_READWRITE)) then
      nxRaiseLastOSError(ClassName);
  end else begin
    aNewCapacity := msCommited;
  end;
end;
{------------------------------------------------------------------------------}
procedure TnxMemoryStream.msSetCapacity(aNewCapacity: Longint);
begin
  SetPointer(msRealloc(aNewCapacity), cmsSize);
  msCommited := aNewCapacity;
end;
{------------------------------------------------------------------------------}
procedure TnxMemoryStream.SetSize(aNewSize: Longint);
var
  OldPosition: Longint;
begin
  OldPosition := cmsPosition;
  if aNewSize > msCommited then
    msSetCapacity(aNewSize);
  cmsSize := aNewSize;
  if OldPosition > aNewSize then Seek(0, soFromEnd);
end;
{------------------------------------------------------------------------------}
function TnxMemoryStream.Write(const aBuffer; aCount: Longint): Longint;
var
  Pos: Longint;
begin
  if (cmsPosition >= 0) and (aCount >= 0) then begin
    Pos := cmsPosition + aCount;
    if Pos > 0 then begin
      if Pos > cmsSize then begin
        if Pos > msCommited then
          msSetCapacity(Pos);
        cmsSize := Pos;
      end;
      nxMove(aBuffer, Pointer(Longint(cmsMemory) + cmsPosition)^, aCount);
      cmsPosition := Pos;
      Result := aCount;
      Exit;
    end;
  end;
  Result := 0;
end;
{==============================================================================}



{===TnxStaticMemoryStream======================================================}
constructor TnxStaticMemoryStream.Create(aMemory: Pointer; aSize: Integer);
begin
  inherited Create;
  SetPointer(aMemory, aSize);
end;
{------------------------------------------------------------------------------}
function TnxStaticMemoryStream.Write(const Buffer; Count: Integer): Longint;
begin
  Result := 0;
end;
{==============================================================================}



{===TnxReader==================================================================}
constructor TnxReader.Create(aStream: TStream);
begin
  inherited Create(aStream, 4096);
end;
{------------------------------------------------------------------------------}
function TnxReader.TheReader: TnxReader;
begin
  Result := Self;
end;
{==============================================================================}



{===TnxWriter==================================================================}
constructor TnxWriter.Create(aStream: TStream);
begin
  inherited Create(aStream, 4096);
end;
{------------------------------------------------------------------------------}
function TnxWriter.TheWriter: TnxWriter;
begin
  Result := Self;
end;
{------------------------------------------------------------------------------}
procedure TnxWriter.WriteAnsiString(const aString: string);
begin
  nxAnsiStringWriter(aString, Self);
end;
{==============================================================================}



{===nxAnsiStringWriter===========================================================}
procedure nxAnsiStringWriter(const aString : string;
                                   aWriter : TWriter);
var
  TempValue : TValueType;
  TempInt   : Integer;
begin
  with aWriter do begin
    TempInt := Length(aString);
    if TempInt <= 255 then begin
      TempValue := vaString;
      Write(TempValue, SizeOf(TempValue));
      Write(TempInt, SizeOf(Byte));
    end else begin
      TempValue := vaLString;
      Write(TempValue, SizeOf(TempValue));
      Write(TempInt, SizeOf(Integer));
    end;
    if TempInt > 0 then
      Write(Pointer(aString)^, TempInt);
  end;
end;
{==============================================================================}

initialization
end.
