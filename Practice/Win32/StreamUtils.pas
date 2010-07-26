unit StreamUtils;

// ----------------------------------------------------------------------------
interface uses Classes, LBClass, LBCipher, IOStream;
// ----------------------------------------------------------------------------

Function ReadStreamFromEncryptedFile( Const FileName : String; Const Key : TKey128 ): TIOStream;
Procedure WriteStreamToEncryptedFile( Var S : TIOStream; Const FileName : String; Const Key : TKey128 );

// ----------------------------------------------------------------------------
implementation uses SysUtils, Tokens;
// ----------------------------------------------------------------------------

Procedure WriteStreamToEncryptedFile( Var S : TIOStream; Const FileName : String; Const Key : TKey128 );
Var
  Context   : TBFContext;
  BFBlock   : TBFBlock;
  BytesRead : Integer;
  Seed      : Integer;
  OutStream : TIOStream;
  Id: array[0..0] of Integer;
Begin
  Assert( Assigned( S ) );
  
  OutStream := TIOStream.Create;
  Try
    OutStream.Position := 0;
  
    S.Position := 0;
    InitEncryptBF( Key, Context );
    Id[0] := tkBeginEncryptedData;
    OutStream.Write(Id, SizeOf(Id));
    BFBlock[ 1 ] := S.Size;
    Seed := $12345678;
    BFBlock[ 0 ] := Ran03( Seed );
    EncryptBF( Context, BFBlock, True );
    OutStream.Write( BFBlock, Sizeof( BFBlock ) );

    BytesRead := S.Read( BFBlock, Sizeof( BFBlock ) );
    While ( BytesRead <> 0 ) do
    Begin
      EncryptBF( Context, BFBlock, True );
      OutStream.Write( BFBlock, Sizeof( BFBlock ) );
      BytesRead := S.Read( BFBlock, Sizeof( BFBlock ) );
    end;
    OutStream.SaveToFile( FileName );
  Finally
    OutStream.Free;
  end;
end;

// ----------------------------------------------------------------------------

Function ReadStreamFromEncryptedFile( Const FileName : String; Const Key : TKey128 ): TIOStream;
Var
  Context   : TBFContext;
  BFBlock   : TBFBlock;
  BytesToDecrypt : Integer;
  BytesToWrite   : Integer;
  S : TMemoryStream;
  Id: array[0..0] of Integer;
Begin
  Assert( FileExists( FileName ) );
  S := TMemoryStream.Create;
  try
    S.LoadFromFile( FileName );
    S.Position := 0;

    Result := TIOStream.Create;
    Result.Position := 0;

    InitEncryptBF( Key, Context );
    S.ReadBuffer( Id, Sizeof(Id));
    if Id[0] <> tkBeginEncryptedData then
    begin
      FreeAndNil(Result);
      exit;
    end;
    S.ReadBuffer( BFBlock, Sizeof( BFBlock ) );
    EncryptBF( Context, BFBlock, False );
    BytesToDecrypt := BFBlock[ 1 ];

    While ( BytesToDecrypt <> 0 ) do
    Begin
      S.ReadBuffer( BFBlock, Sizeof( BFBlock ) );
      EncryptBF( Context, BFBlock, False );
      If ( BytesToDecrypt > Sizeof( BFBlock ) ) then
        BytesToWrite := Sizeof( BFBlock )
      else
        BytesToWrite := BytesToDecrypt;
      Dec( BytesToDecrypt, BytesToWrite );
      Result.WriteBuffer( BFBlock, BytesToWrite );
    end;
    Result.Position := 0;
  finally
    S.Free;
  end;
end;

// ----------------------------------------------------------------------------

end.
