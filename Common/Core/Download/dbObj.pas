unit dbObj;

{  -------------------------------------------------------------------  }
interface uses fhdefs, Classes, FHIOStream, dtList;
{  -------------------------------------------------------------------  }

type
  TDisk_Bank_Account = class (TObject)
    dbFields: tDisk_Bank_Account_Rec;
    dbTransaction_List: tDisk_Transaction_List;
    constructor Create;
    destructor Destroy; override;
  public
    procedure LoadFromFile(var s : TFHIOStream);
    procedure SaveToFile(var s : TFHIOStream);
  end;

{  -------------------------------------------------------------------  }
implementation uses FHTokens, fhdbio, fhdtio, SysUtils, FHExceptions;
{  -------------------------------------------------------------------  }

resourcestring
  SUnknownToken = 'dbObj Error: Unknown token %d';

// -----------------------------------------------------------------------------

constructor TDisk_Bank_Account.Create;
begin
  inherited Create;
  FillChar( dbFields, Sizeof( dbFields ), 0 );
  with dbFields do
  begin
    dbRecord_Type := tkBegin_Disk_Bank_Account;
    dbFields.dbCan_Redate_Transactions := False;
    dbEOR := tkEnd_Disk_Bank_Account;
  end;
  dbTransaction_List := TDisk_Transaction_List.Create;
  if not Assigned( dbTransaction_List ) then Raise FHInsufficientMemoryException.Create( 'TDisk_Bank_Account.Create: Unable to create dbTransaction_List ');
end;

// -----------------------------------------------------------------------------

destructor TDisk_Bank_Account.Destroy;
begin
  dbTransaction_List.Free;
  inherited Destroy;
end;

// -----------------------------------------------------------------------------

procedure TDisk_Bank_Account.LoadFromFile( var s : TFHIOStream);
var
  Token: Byte;
begin
  Token := tkBegin_Disk_Bank_Account;
  while ( Token <> tkEndSection ) do
  begin
    case Token of
      tkBegin_Disk_Bank_Account : Read_Disk_Bank_Account_Rec( dbFields, S );
      tkBeginDiskTransactions   : dbTransaction_List.LoadFromFile( S );
      else
        Raise FHUnknownTokenException.CreateFmt( SUnknownToken, [ Token ] );
    end; { of Case }
    Token := S.ReadToken;
  end;
end;

// -----------------------------------------------------------------------------

procedure TDisk_Bank_Account.SaveToFile(var s : TFHIOStream);
begin
  FHDBIO.Write_Disk_Bank_Account_Rec( dbFields, S );
  dbTransaction_List.SaveToFile( S );
  S.WriteToken( tkEndSection );
end;

// -----------------------------------------------------------------------------

end.
