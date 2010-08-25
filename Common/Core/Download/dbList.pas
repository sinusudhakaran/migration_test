unit dbList;

// -----------------------------------------------------------------------------
interface uses ECollect, fhDefs, FHIOStream, dbObj;
// -----------------------------------------------------------------------------

type
  TDisk_Bank_Account_List = class ( TExtdCollection )
  private
  protected
    procedure FreeItem(Item : Pointer); override;
  public
    function Disk_Bank_Account_At(Index : Integer): TDisk_Bank_Account;
    procedure LoadFromFile(var S : TFHIOStream);
    procedure SaveToFile(var S : TFHIOStream);
  end;

// -----------------------------------------------------------------------------
implementation uses SysUtils, FHTokens, FHExceptions, fhdbio;
// -----------------------------------------------------------------------------

resourcestring
  SUnknownToken = 'dbList Error: Unknown token %d';
  SOutOfMemory  = 'dbList Error: Unable to create TDisk_Bank_Account';

// -----------------------------------------------------------------------------

function TDisk_Bank_Account_List.Disk_Bank_Account_At(Index : Integer): TDisk_Bank_Account;
begin
  result := TDisk_Bank_Account( At( Index ) );
end;

// -----------------------------------------------------------------------------

procedure TDisk_Bank_Account_List.FreeItem(Item : Pointer);
begin
  TDisk_Bank_Account( Item ).Free;
end;

// -----------------------------------------------------------------------------

procedure TDisk_Bank_Account_List.LoadFromFile(var S : TFHIOStream);
var
  Token: Byte;
  P: TDisk_Bank_Account;
begin
  Token := S.ReadToken;
  while ( Token <> tkEndSection ) do
  begin
    case Token of
      tkBegin_Disk_Bank_Account :
        begin
          P := TDisk_Bank_Account.Create;
          if not Assigned( P ) then Raise FHInsufficientMemoryException.Create( SOutOfMemory );
          P.LoadFromFile( S );
          Insert( P );
        end;
      else
        Raise FHUnknownTokenException.CreateFmt( SUnknownToken, [ Token ] );
    end; { of Case }
    Token := S.ReadToken;
  end;
end;

// -----------------------------------------------------------------------------

procedure TDisk_Bank_Account_List.SaveToFile(var S : TFHIOStream);
var
  i: Integer;
begin
  S.WriteToken( tkBeginDiskAccountList );
  for i := First to Last do Disk_Bank_Account_At( i ).SaveToFile( S );
  S.WriteToken( tkEndSection );
end;

// -----------------------------------------------------------------------------

end.

