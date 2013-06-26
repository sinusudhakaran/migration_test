unit FHIOSTREAM;

{
   Title: FHIOStream

   Description:
     The TFHIOStream object defines a structured storage system which can be
     extended as required to support additional data fields and types.

   Remarks:
     We don't bother writing empty fields.

   Author:      Steve 01/2000

   Feb 2002:

   Changed Integer Types to Integer because Integers will change to 64
   bits in later versions of Delphi.

   Eliminated all the various exception types which we weren't using.

   The Int64 Type has changed from a Comp field to an Int64.

}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Classes,
  SysUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

type
  TFHIOStream = class( TMemoryStream )
    procedure CheckType( const Expected : Byte; const SProcName : string );
    function ReadByte : Byte;
    function ReadToken : Byte;
    function ReadType : Byte;
    function ReadBooleanValue : Boolean;
    function ReadByteValue : Byte;
    function ReadIntegerValue : Integer;
    function ReadInt64Value : Int64;
    function ReadShortStringValue : ShortString;
    function ReadAnsiStringValue : AnsiString;
    procedure WriteToken( const AToken : Byte );
    procedure WriteBooleanValue( const AToken : Byte; const AValue : Boolean );
    procedure WriteByteValue( const AToken : Byte; const AValue : Byte );
    procedure WriteIntegerValue( const AToken : Byte; const AValue : Integer );
    procedure WriteInt64Value( const AToken : Byte; const AValue : Int64 );
    procedure WriteShortStringValue( const AToken : Byte; const AValue : ShortString );
    procedure WriteAnsiStringValue( const AToken : Byte; const AValue : AnsiString );
  end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation uses FHExceptions;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resourcestring
  SUnitName = 'IOStream';
  SOpCodeError = '%0:s %1:s Error: Unexpected op code %2:d';
  SShortStringLengthError = '%0:s %1:s Error: ShortString length byte is zero';
  SAnsiStringLengthError = '%0:s %1:s Error: AnsiString length is zero';

const
  { Field Types }
  ftByte : Byte = 01;
  ftBoolean : Byte = 02;
  ftInteger : Byte = 03;
  ftInt64 : Byte = 04;
  ftShortString : Byte = 05;
  ftAnsiString : Byte = 06;

const
  flByte = 1;
  flInteger = 4;
  flInt64 = 8;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TFHIOStream.CheckType( const Expected : Byte; const SProcName : string );

var
  OpCode : Byte;
begin
  Read( OpCode, flByte );
  if ( OpCode <> Expected ) then
    raise FHOpCodeException.CreateFmt( SOpCodeError, [ SUnitName, SProcName, OpCode ] );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TFHIOStream.ReadByte : Byte;
begin
  Read( Result, flByte );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TFHIOStream.ReadToken : Byte;
begin
  Read( Result, flByte );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TFHIOStream.ReadType : Byte;
begin
  Read( Result, flByte );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TFHIOStream.ReadBooleanValue : Boolean;
const
  SProcName = 'ReadBooleanValue';
begin
  CheckType( ftBoolean, SProcName );
  Result := True;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TFHIOStream.ReadIntegerValue : Integer;
const
  SProcName = 'ReadIntegerValue';
begin
  CheckType( ftInteger, SProcName );
  Read( Result, flInteger );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TFHIOStream.ReadByteValue : Byte;
const
  SProcName = 'ReadByteValue';
begin
  CheckType( ftByte, SProcName );
  Read( Result, flByte );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TFHIOStream.ReadInt64Value : Int64;
const
  SProcName = 'ReadInt64Value';
begin
  CheckType( ftInt64, SProcName );
  Read( Result, flInt64 );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TFHIOStream.ReadShortStringValue : ShortString;
const
  SProcName = 'ReadShortStringValue';
var
  RLen : Byte absolute Result;
begin
  CheckType( ftShortString, SProcName );
  Read( RLen, flByte );
  if ( RLen = 0 ) then
    raise FHStringLengthException.CreateFmt( SShortStringLengthError, [ SUnitName, SProcName ] );
  Read( Result[ 1 ], RLen );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TFHIOStream.ReadAnsiStringValue : AnsiString;
const
  SProcName = 'ReadAnsiStringValue';
var
  S : AnsiString;
  Size : Integer;
begin
  Result := '';
  S := '';
  CheckType( ftAnsiString, SProcName );
  Read( Size, flInteger );
  if ( Size = 0 ) then
    raise FHStringLengthException.CreateFmt( SAnsiStringLengthError, [ SUnitName, SProcName ] );
  System.SetLength( S, Size );
  Read( Pointer( S )^, Size );
  Result := S;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TFHIOStream.WriteToken( const AToken : Byte );
begin
  Write( AToken, flByte );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TFHIOStream.WriteBooleanValue( const AToken : Byte; const AValue : Boolean );
begin
  if AValue then
  begin
    Write( AToken, flByte );
    Write( ftBoolean, flByte );
  end
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TFHIOStream.WriteByteValue( const AToken : Byte; const AValue : Byte );
begin
  if AValue <> 0 then
  begin
    Write( AToken, flByte );
    Write( ftByte, flByte );
    Write( AValue, flByte );
  end
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TFHIOStream.WriteIntegerValue( const AToken : Byte; const AValue : Integer );
begin
  if AValue <> 0 then
  begin
    Write( AToken, flByte );
    Write( ftInteger, flByte );
    Write( AValue, flInteger );
  end
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TFHIOStream.WriteInt64Value( const AToken : Byte; const AValue : Int64 );
begin
  if AValue <> 0 then
  begin
    Write( AToken, flByte );
    Write( ftInt64, flByte );
    Write( AValue, flInt64 );
  end
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TFHIOStream.WriteShortStringValue( const AToken : Byte; const AValue : ShortString );
var
  ALen : Byte absolute AValue;
begin
  if ALen > 0 then
  begin
    Write( AToken, flByte );
    Write( ftShortString, flByte );
    Write( AValue, Integer( ALen ) + 1 );
  end
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TFHIOStream.WriteAnsiStringValue( const AToken : Byte; const AValue : AnsiString );
var
  Size : Integer;
begin
  Size := Length( AValue );
  if Size > 0 then
  begin
    Write( AToken, flByte );
    Write( ftAnsiString, flByte );
    Write( Size, flInteger );
    Write( Pointer( AValue )^, Size );
  end
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

begin
  Assert( Sizeof( Integer ) = 4 );
  Assert( Sizeof( Int64 ) = 8 );
  Assert( Sizeof( Byte ) = 1 );
  Assert( Sizeof( Boolean ) = 1 );
end.

