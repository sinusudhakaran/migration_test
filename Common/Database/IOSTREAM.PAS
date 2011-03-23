Unit IOStream;

{
   Title: IOStream

   Description:
     The TIOStream object defines a structured storage system which can be
     extended as required to support additional data fields and types.

   Remarks:
     We don't bother writing empty fields.

   Author:      Steve 01/2000
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Interface

Uses
  Classes,
  MoneyDef,
{$IFDEF MSWINDOWS}
  Windows;
{$ENDIF}
{$IFDEF LINUX}
  !! BK5 Code is not crossplatform
  Libc;
{$ENDIF}
{$WARN SYMBOL_PLATFORM OFF}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

type
  TBigMemoryStream = class( TMemoryStream)
  protected
    function Realloc( var NewCapacity : longint) : pointer; override;
  end;

Type
  TIOStream = Class( TBigMemoryStream )
    Procedure CheckType( Const Expected : Byte; Const SProcName : String );
    Function ReadByte  : Byte;
    Function ReadToken : Byte;
    Function ReadType  : Byte;
    Function ReadBooleanValue : Boolean;
    Function ReadByteValue : Byte;
    Function ReadIntegerValue : Integer;
    Function ReadDateValue : Integer;
    Function ReadDateTimeValue : TDateTime;
    Function ReadMoneyValue : Money;
    Function ReadBMoneyValue(Var Index: Byte) : Money;
    Function ReadStringValue : ShortString;
    Function ReadAnsiStringValue : AnsiString;
    Function ReadBStringValue(Var Index: Byte) : ShortString;
    Function ReadBByteValue(Var Index: Byte) : Byte;
    Function ReadBDateValue(Var Index: Byte) : Integer;
    Function ReadBBDateValue(Var Index1, Index2: Byte) : Integer;
    Function ReadBBMoneyValue(Var Index1, Index2: Byte) : Money;
    Function ReadBBooleanValue(Var Index: Byte) : Boolean;
    Function ReadDoubleValue : Double;
    Function ReadBDoubleValue (Var Index: Byte): Double;
    Function ReadBIntegerValue(Var Index: Byte) : Integer;
    Function ReadBB_BooleanValue(Var Index1, Index2: Byte) : Boolean;
    Function ReadBBStringValue(Var Index1, Index2: Byte) : ShortString;

    Procedure WriteToken(CONST AToken: Byte);
    Procedure WriteBooleanValue(CONST AToken: Byte; CONST AValue: Boolean);
    Procedure WriteByteValue(CONST AToken: Byte; CONST AValue: Byte);
    Procedure WriteIntegerValue(CONST AToken: Byte; CONST AValue: Integer);
    Procedure WriteDateValue(CONST AToken: Byte; CONST AValue: Integer);
    Procedure WriteDateTimeValue(CONST AToken: Byte; CONST AValue: TDateTime);
    Procedure WriteMoneyValue(CONST AToken: Byte; CONST AValue: Money);
    Procedure WriteBMoneyValue(CONST AToken: Byte; CONST AIndex: Byte; CONST AValue: Money);
    Procedure WriteStringValue(CONST AToken: Byte; CONST AValue: ShortString);
    Procedure WriteAnsiStringValue(CONST AToken: Byte; CONST AValue: AnsiString);
    Procedure WriteBStringValue(CONST AToken: Byte; CONST AIndex: Byte; CONST AValue: ShortString);
    Procedure WriteBByteValue(CONST AToken: Byte; CONST AIndex, AValue: Byte);
    Procedure WriteBDateValue(CONST AToken: Byte; CONST AIndex: Byte; CONST AValue: Integer);
    Procedure WriteBBDateValue(CONST AToken: Byte; CONST AIndex1, AIndex2: Byte; CONST AValue: Integer);
    Procedure WriteBBMoneyValue(CONST AToken: Byte; CONST AIndex1, AIndex2: Byte; CONST AValue: Money);
    Procedure WriteBBooleanValue(CONST AToken: Byte; CONST AIndex: Byte; CONST AValue: Boolean);
    Procedure WriteDoubleValue(CONST AToken: Byte; CONST AValue: Double);
    Procedure WriteBDoubleValue(CONST AToken: Byte; CONST AIndex: Byte; CONST AValue: Double);
    Procedure WriteBIntegerValue(CONST AToken: Byte; CONST AIndex: Byte; CONST AValue: Integer);
    Procedure WriteBB_BooleanValue(CONST AToken: Byte; CONST AIndex1, AIndex2: Byte; CONST AValue: Boolean);
    Procedure WriteBBStringValue(CONST AToken: Byte; CONST AIndex1, AIndex2: Byte; CONST AValue: ShortString);
  End;

Const
   SUnknownToken      = 'Unknown token %d';

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Implementation
Uses
  BkDBExcept, RTLConsts;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CONST
   SUnitName = 'IOStream';

   SOpCodeError       = '%s %s Error, unexpected op code %d';
   SStringLengthError = '%s %s Error, string has a zero length byte';
   SPStringLengthError = '%s %s Error, PString has a zero length byte';

Const
  { Field Types }
  ftByte : Byte = 01;
  ftBoolean : Byte = 02;
  ftInteger : Byte = 03;
  ftDate : Byte = 04;
  ftMoney : Byte = 05;
  ftBMoney : Byte = 06;
  ftString : Byte = 07;
  ftBString : Byte = 08;
  ftBByte : Byte = 09;
  ftBDate : Byte = 10;
  ftBBMoney : Byte = 11;
  ftBBoolean : Byte = 12;
  ftDouble : Byte = 13;
  ftBInteger : Byte = 14;
  ftBB_Boolean : Byte = 15;
  ftPString : Byte = 16;
  ftBBString : Byte = 17;
  ftBBDate : Byte = 18;
  ftBDouble : byte = 19;
  ftDateTime: Byte = 20;

CONST
  flInteger     = 4;
  flDouble      = 8;
  flMoney       = 8;
  flByte        = 1;
  flBoolean     = 1;
  flDateTime    = 8;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.CheckType( Const Expected : Byte; Const SProcName : String );
Var
   OpCode : Byte;
Begin
   Read( OpCode, flByte );
   If ( OpCode<> Expected ) Then
     Raise EOpCodeException.CreateFmt( SOpCodeError, [ SUnitName, SProcName, OpCode ] );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadByte : Byte;
Begin
   Read( Result, flByte );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadToken : Byte;
Begin
  Read( Result, flByte );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadType : Byte;
Begin
  Read( Result, flByte );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadBooleanValue : Boolean;
Const
   SProcName = 'ReadBooleanValue';
Begin
   CheckType( ftBoolean, SProcName );
   Result := True;
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadIntegerValue : Integer;
Const
   SProcName = 'ReadIntegerValue';
Begin
   CheckType( ftInteger, SProcName );
   Read(Result, flInteger );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadByteValue : Byte;
Const
   SProcName = 'ReadByteValue';
Begin
   CheckType( ftByte, SProcName );
   Read(Result, flByte );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TIOStream.ReadDateTimeValue: TDateTime;
Const
   SProcName = 'ReadDateTimeValue';
Begin
   CheckType( ftDateTime, SProcName );
   Read( Result, flDateTime );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadDateValue : Integer;
Const
   SProcName = 'ReadDateValue';
Begin
   CheckType( ftDate, SProcName );
   Read( Result, flInteger );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadMoneyValue : Money;
Const
   SProcName = 'ReadMoneyValue';
Begin
   CheckType( ftMoney, SProcName );
   Read(Result, flMoney );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadBMoneyValue(Var Index: Byte) : Money;
Const
   SProcName = 'ReadBMoneyValue';
Begin
   CheckType( ftBMoney, SProcName );
   Read(Index, flByte );
   Read(Result, flMoney );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadStringValue : ShortString;
Const
   SProcName = 'ReadStringValue';
Var
   RLen   : Byte Absolute Result;
Begin
   CheckType( ftString, SProcName );
   Read( RLen, flByte );
   If ( RLen=0 ) Then
      Raise ECorruptDataInFile.CreateFmt( SStringLengthError, [ SUnitName, SProcName ] );
   Read( Result[1], RLen );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadAnsiStringValue : AnsiString;
Const
   SProcName = 'ReadPStringValue';
Var
   S    : AnsiString;
   Size : Integer;
Begin
   Result := '';
   S      := '';
   CheckType( ftPString, SProcName );
   Read( Size, flInteger );
   If ( Size=0 ) Then
      Raise ECorruptDataInFile.CreateFmt( SPStringLengthError, [ SUnitName, SProcName ] );
   System.SetLength( S, Size );
   Read( Pointer( S )^, Size );
   Result := S;
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadBStringValue(Var Index: Byte) : ShortString;
Const
   SProcName = 'ReadBStringValue';
Var
   RLen   : Byte Absolute Result;
Begin
   CheckType( ftBString, SProcName );
   Read( Index, flByte );
   Read( RLen, flByte );

   If ( RLen=0 ) Then
      Raise ECorruptDataInFile.CreateFmt( SStringLengthError, [ SUnitName, SProcName ] );

   Read( Result[1], RLen );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadBByteValue(Var Index: Byte) : Byte;
Const
   SProcName = 'ReadBByteValue';
Begin
   CheckType( ftBByte, SProcName );
   Read( Index, flByte );
   Read( Result, ftByte );
End;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadBDateValue(Var Index: Byte) : Integer;
Const
   SProcName = 'ReadBDateValue';
Begin
   CheckType( ftBDate, SProcName );
   Read( Index, flByte );
   Read( Result, flInteger );
End;

Function TIOStream.ReadBBDateValue(Var Index1, Index2: Byte) : Integer;
Const
   SProcName = 'ReadBBDateValue';
Begin
   CheckType( ftBBDate, SProcName );
   Read( Index1, flByte );
   Read( Index2, flByte );
   Read( Result, flInteger );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadBBMoneyValue(Var Index1, Index2: Byte) : Money;
Const
   SProcName = 'ReadBBMoneyValue';
Begin
   CheckType( ftBBMoney, SProcName );
   Read( Index1, flByte );
   Read( Index2, flByte );
   Read( Result, flMoney );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadBBooleanValue(Var Index: Byte) : Boolean;
Const
   SProcName = 'ReadBBooleanValue';
Begin
   CheckType( ftBBoolean, SProcName );
   Read(Index, flByte );
   Result := True;
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadDoubleValue : Double;
Const
   SProcName = 'ReadDoubleValue';
Begin
   CheckType( ftDouble, SProcName );
   Read( Result, flDouble );
End;

Function TIOStream.ReadBDoubleValue (Var Index: Byte): Double;
Const
   SProcName = 'ReadBDoubleValue';
Begin
   CheckType( ftBDouble, SProcName );
   Read(Index, flByte );
   Read(Result, flDouble );
End;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadBIntegerValue(Var Index: Byte) : Integer;
Const
   SProcName = 'ReadBIntegerValue';
Begin
   CheckType( ftBInteger, SProcName );
   Read(Index, flByte );
   Read(Result, flInteger );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadBB_BooleanValue(Var Index1, Index2: Byte) : Boolean;
Const
   SProcName = 'ReadBB_BooleanValue';
Begin
   CheckType( ftBB_Boolean, SProcName );
   Read(Index1, flByte );
   Read(Index2, flByte );
   Result := True;
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TIOStream.ReadBBStringValue(Var Index1, Index2: Byte) : ShortString;
Const
   SProcName = 'ReadBBStringValue';
Var
   RLen   : Byte Absolute Result;
Begin
   CheckType( ftBBString, SProcName );
   Read(Index1, flByte );
   Read(Index2, flByte );
   Read( RLen, flByte );
   If ( RLen=0 ) Then
      Raise ECorruptDataInFile.CreateFmt( SStringLengthError, [ SUnitName, SProcName ] );
   Read( Result[1], RLen );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteToken(CONST AToken: Byte);
Begin
   Write(AToken, flByte );
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteBooleanValue(CONST AToken: Byte; CONST AValue: Boolean);
Begin
  If AValue Then Begin
    Write(AToken, flByte );
    Write(ftBoolean, flByte );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteByteValue(CONST AToken: Byte; CONST AValue: Byte);
Begin
  If AValue <> 0 Then Begin
    Write(AToken, flByte );
    Write(ftByte, flByte );
    Write(AValue, flByte );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteIntegerValue(CONST AToken: Byte; CONST AValue: Integer);
Begin
  If AValue <> 0 Then Begin
    Write(AToken, flByte );
    Write(ftInteger, flByte );
    Write(AValue, flInteger );
  End
End;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TIOStream.WriteDateTimeValue(const AToken: Byte;
  const AValue: TDateTime);
begin
  If AValue <> 0 Then Begin
    Write(AToken, flByte );
    Write(ftDateTime, flByte );
    Write(AValue, flDateTime );
  End
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteDateValue(CONST AToken: Byte; CONST AValue: Integer);
Begin
  If AValue <> 0 Then Begin
    Write(AToken, flByte );
    Write(ftDate, flByte );
    Write(AValue, flInteger );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteMoneyValue(CONST AToken: Byte; CONST AValue: Money);
Begin
  If AValue <> 0 Then Begin
    Write(AToken, flByte );
    Write(ftMoney, flByte );
    Write(AValue, flMoney );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteBMoneyValue(CONST AToken: Byte; CONST AIndex: Byte; CONST AValue: Money);
Begin
  If AValue <> 0 Then Begin
    Write(AToken, flByte );
    Write(ftBMoney, flByte);
    Write(AIndex, flByte);
    Write(AValue, flMoney );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteStringValue(CONST AToken: Byte; CONST AValue: ShortString );
Var
  ALen : Byte Absolute AValue;
Begin
  If ALen > 0 Then Begin
    Write( AToken, flByte );
    Write( ftString, flByte );
    Write( AValue, Integer( ALen ) + 1 );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteAnsiStringValue(CONST AToken: Byte; CONST AValue: AnsiString );
Var
   Size : Integer;
Begin
   Size := Length( AValue );
   If Size > 0 Then Begin
     Write( AToken, flByte );
     Write( ftPString, flByte );
     Write( Size, flInteger );
     Write( Pointer( AValue )^, Size );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteBStringValue(CONST AToken: Byte; CONST AIndex: Byte; CONST AValue: ShortString);
Var
  ALen : Byte Absolute AValue;
Begin
  If ALen > 0 Then Begin
    Write(AToken, flByte);
    Write(ftBString, flByte );
    Write(AIndex, flByte );
    Write( AValue, Integer( ALen ) + 1 );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteBByteValue(CONST AToken: Byte; CONST AIndex, AValue: Byte);
Begin
  If AValue <> 0 Then Begin
    Write( AToken, flByte );
    Write( ftBByte, flByte );
    Write( AIndex, flByte );
    Write( AValue, flByte );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteBDateValue(CONST AToken: Byte; CONST AIndex: Byte; CONST AValue: Integer);
Begin
  If AValue <> 0 Then Begin
    Write(AToken, flByte );
    Write(ftBDate, flByte );
    Write(AIndex, flByte );
    Write(AValue, flInteger );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure TIOStream.WriteBBDateValue(CONST AToken: Byte; CONST AIndex1, AIndex2: Byte; CONST AValue: Integer);
Begin
  If AValue <> 0 Then Begin
    Write(AToken, flByte );
    Write(ftBBDate, flByte );
    Write(AIndex1, flByte );
    Write(AIndex2, flByte );
    Write(AValue, flInteger );
  End
End;
    
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteBBMoneyValue(CONST AToken: Byte; CONST AIndex1, AIndex2: Byte;
  CONST AValue: Money);
Begin
  If AValue <> 0 Then Begin
    Write(AToken, flByte );
    Write(ftBBMoney, flByte );
    Write(AIndex1, flByte );
    Write(AIndex2, flByte );
    Write(AValue, flMoney );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteBBooleanValue(CONST AToken: Byte; CONST AIndex: Byte; CONST AValue: Boolean);
Begin
  If AValue Then Begin
    Write(AToken, flByte );
    Write(ftBBoolean, flByte );
    Write(AIndex, flByte );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteDoubleValue(CONST AToken: Byte; CONST AValue: Double);
Begin
  If AValue <> 0.0 Then Begin
    Write(AToken, flByte );
    Write(ftDouble, flByte );
    Write(AValue, flDouble );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteBDoubleValue(CONST AToken: Byte; CONST AIndex: Byte; CONST AValue: Double);
Begin
  If AValue <> 0.0 Then Begin
    Write(AToken, flByte );
    Write(ftBDouble, flByte);
    Write(AIndex, flByte );
    Write(AValue, flDouble);
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteBIntegerValue(CONST AToken: Byte; CONST AIndex: Byte; CONST AValue: Integer);
Begin
  If AValue <> 0 Then Begin
    Write(AToken, flByte );
    Write(ftBInteger, flByte );
    Write(AIndex, flByte );
    Write(AValue, flInteger );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteBB_BooleanValue(CONST AToken: Byte; CONST AIndex1, AIndex2: Byte;
  CONST AValue: Boolean);
Begin
  If AValue Then Begin
    Write(AToken, flByte );
    Write(ftBB_Boolean, flByte );
    Write(AIndex1, flByte );
    Write(AIndex2, flByte );
  End
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TIOStream.WriteBBStringValue(CONST AToken: Byte; CONST AIndex1, AIndex2: Byte; CONST AValue: ShortString);
Var
  ALen : Byte Absolute AValue;
Begin
  If ALen > 0 Then Begin
    Write(AToken, flByte);
    Write(ftBBString, flByte );
    Write(AIndex1, flByte );
    Write(AIndex2, flByte );
    Write( AValue, Integer( ALen ) + 1 );
  End
End;

{ TBigMemoryStream }

function TBigMemoryStream.Realloc(var NewCapacity: Integer): pointer;
const
  MemoryDelta = $40000; //256Kb chunks
begin
  if (NewCapacity > 0) and (NewCapacity <> Size) then
    NewCapacity := (NewCapacity + (MemoryDelta - 1)) and not (MemoryDelta - 1);
  Result := Memory;
  if NewCapacity <> Capacity then
  begin
    if NewCapacity = 0 then
    begin
{$IFDEF MSWINDOWS}
      GlobalFreePtr( Memory);
{$ELSE}
      FreeMem(Memory);
{$ENDIF}
      Result := nil;
    end else
    begin
{$IFDEF MSWINDOWS}
      if Capacity = 0 then
        Result := GlobalAllocPtr(HeapAllocFlags, NewCapacity)
      else
        Result := GlobalReallocPtr(Memory, NewCapacity, HeapAllocFlags);
{$ELSE}
      if Capacity = 0 then
        GetMem( result, NewCapacity)
      else
        ReallocMem( result, NewCapacity);
{$ENDIF}
      if Result = nil then
        raise EStreamError.CreateRes(@SMemoryStreamError);
    end;
  end;
end;
                                                        
Begin
  Assert(Sizeof(Integer) = 4);
  Assert(Sizeof(Double) = 8);
  Assert(Sizeof(Money) = 8);
  Assert(Sizeof(Byte) = 1);
  Assert(Sizeof(Boolean) = 1);
End.
