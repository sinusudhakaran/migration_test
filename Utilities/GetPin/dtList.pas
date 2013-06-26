unit dtList;

// -----------------------------------------------------------------------------
interface uses FHdefs, ECollect, FHIOStream;
// -----------------------------------------------------------------------------

type
  TDisk_Transaction_List = class ( TExtdCollection )
  protected
    procedure FreeItem(Item : Pointer); override;
  public
    function Insert(Item : Pointer): Integer; override;
    procedure LoadFromFile(var S : TFHIOStream);
    procedure SaveToFile(var S : TFHIOStream);
    function  Disk_Transaction_At(Index : longint): pDisk_Transaction_Rec;
  end;

// -----------------------------------------------------------------------------
implementation uses FHDTIO, FHTokens, SysUtils, FHExceptions;
// -----------------------------------------------------------------------------

const
  UnitName = 'DTLIST';
resourcestring
  SUnknownToken = 'dtList Error: Unknown token %d';

// -----------------------------------------------------------------------------

procedure TDisk_Transaction_List.FreeItem(Item : Pointer);

begin
  if FHDTIO.IsADisk_Transaction_Rec( Item ) then
    Dispose( pDisk_Transaction_Rec( Item ) );
end;

// -----------------------------------------------------------------------------

Function TDisk_Transaction_List.Insert( Item : Pointer ): Integer;
begin
  Result := 0;
  if FHDTIO.IsADisk_Transaction_Rec( Item ) then Result := Inherited Insert( Item );
end;

// -----------------------------------------------------------------------------

procedure TDisk_Transaction_List.LoadFromFile(var S : TFHIOStream);
var
  Token: Byte;
  pTX: pDisk_Transaction_Rec;
begin
  Token := S.ReadToken;
  while ( Token <> tkEndSection ) do
  begin
    case Token of
      tkBegin_Disk_Transaction :
        begin
          pTX := New_Disk_Transaction_Rec;
          Read_Disk_Transaction_Rec( pTX^, S );
          Insert( pTX );
        end;
      else
        Raise FHUnknownTokenException.CreateFmt( SUnknownToken, [ Token ] );
    end; { of Case }
    Token := S.ReadToken;
  end;
end;

// -----------------------------------------------------------------------------

procedure TDisk_Transaction_List.SaveToFile(var S : TFHIOStream);

const
  ThisMethodName = 'TDisk_Transaction_List.SaveToFile';
var
  i : LongInt;
  pTX : pDisk_Transaction_Rec;
begin
  S.WriteToken( tkBeginDiskTransactions );
  for i := First to Last do
  begin
    pTX := Disk_Transaction_At( i );
    FHDTIO.Write_Disk_Transaction_Rec( pTX^, S );
  end;
  S.WriteToken( tkEndSection );
end;

// -----------------------------------------------------------------------------

function TDisk_Transaction_List.Disk_Transaction_At(Index : longint): pDisk_Transaction_Rec;
var
  P: Pointer;
begin
  result := nil;
  P := At( Index );
  if FHDTIO.IsADisk_Transaction_Rec( P ) then
    result := P;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


end.

