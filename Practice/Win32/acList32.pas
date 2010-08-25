unit acList32 ;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Remarks:

   Author:

}
//------------------------------------------------------------------------------

// -----------------------------------------------------------------------------
interface uses ECollect, Classes, syDefs, ioStream, sysUtils ;
// -----------------------------------------------------------------------------

type
  TSystem_File_Access_List = class( TExtdCollection )
  protected
    procedure FreeItem( Item : Pointer ) ; override ;
  public
    procedure SaveToFile( var S : TIOStream ) ;
    procedure LoadFromFile( var S : TIOStream ) ;
    function Access_At( Index : LongInt ) : pFile_Access_Mapping_Rec ;
    procedure Insert_Access_Rec( const AUserLRN, AClientLRN : Integer ) ;
    procedure Delete_User( const AUserLRN : Integer ) ;
    procedure Delete_Client_File( const AClientLRN : Integer ) ;
    function Allow_Access( const AUserLRN, AClientLRN : Integer ) : Boolean ;
    function Restrict_Access( const AUserLRN, AClientLRN : Integer ) : Boolean ;
    function Restricted_User( const AUserLRN : Integer ) : Boolean ;
    function Restricted_Client_File( const AClientLRN : Integer ) : Boolean ;
  end ;

// -----------------------------------------------------------------------------
implementation uses SYACIO, TOKENS, LogUtil, STStrS, MALLOC, bkdbExcept, bk5except ;
// -----------------------------------------------------------------------------

const
  UnitName      = 'ACLIST32' ;

// -----------------------------------------------------------------------------

function TSystem_File_Access_List.Access_At( Index : Integer ) : pFile_Access_Mapping_Rec ;
var
  p             : pointer ;
begin
  Access_At := nil ;
  P := At( Index ) ;
  if SYACIO.IsAFile_Access_Mapping_Rec( P ) then
    Access_At := P ;
end ;

// -----------------------------------------------------------------------------

procedure TSystem_File_Access_List.FreeItem( Item : Pointer ) ;
begin
  SYACIO.Free_File_Access_Mapping_Rec_Dynamic_Fields( pFile_Access_Mapping_Rec( Item )^ ) ;
  SafeFreeMem( Item, File_Access_Mapping_Rec_Size ) ;
end ;

// -----------------------------------------------------------------------------

procedure TSystem_File_Access_List.LoadFromFile( var S : TIOStream ) ;
Const
  ThisMethodName = 'TSystem_File_Access_List.LoadFromFile';
var
  Token         : Byte ;
  AR            : pFile_Access_Mapping_Rec ;
  msg           : string ;
begin
  Token := S.ReadToken ;
  while ( Token <> tkEndSection ) do
  begin
    case Token of
      tkBegin_File_Access_Mapping :
        begin
          MALLOC.SafeGetMem( AR, File_Access_Mapping_Rec_Size ) ;
          if not Assigned( AR ) then
          begin
            Msg := 'TSystem_File_Access_List.LoadFromFile : Unabled to Allocate AC' ;
            LogUtil.LogMsg( lmError, UnitName, Msg ) ;
            raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] ) ;
          end ;
          Read_File_Access_Mapping_Rec( AR^, S ) ;
          Insert( AR ) ;
        end ;
    else
      begin { Should never happen }
        Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] ) ;
        LogUtil.LogMsg( lmError, UnitName, Msg ) ;
        raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] ) ;
      end ;
    end ; { of Case }
    Token := S.ReadToken ;
  end ;
end ;

// -----------------------------------------------------------------------------

procedure TSystem_File_Access_List.SaveToFile( var S : TIOStream ) ;
var
  i             : LongInt ;
  AC            : pFile_Access_Mapping_Rec ;
begin
  S.WriteToken( tkBeginSystem_Access_List ) ;
  for i := 0 to Pred( itemCount ) do
  begin
    AC := pFile_Access_Mapping_Rec( At( i ) ) ;
    SYACIO.Write_File_Access_Mapping_Rec( AC^, S ) ;
  end ;
  S.WriteToken( tkEndSection ) ;
end ;

// -----------------------------------------------------------------------------

procedure TSystem_File_Access_List.Delete_User( const AUserLRN : Integer ) ;
var
  i             : Integer ;
  pAC           : pFile_Access_Mapping_Rec ;
begin
  for i := Pred( ItemCount ) downto 0 do
  begin
    pAC := Access_At( i ) ;
    if pAC.acUser_LRN = AUserLRN then DelFreeItem( pAC ) ;
  end ;
end ;

// -----------------------------------------------------------------------------

procedure TSystem_File_Access_List.Delete_Client_File( const AClientLRN : Integer ) ;
var
  i             : Integer ;
  pAC           : pFile_Access_Mapping_Rec ;
begin
  for i := Pred( ItemCount ) downto 0 do
  begin
    pAC := Access_At( i ) ;
    if pAC.acClient_File_LRN = AClientLRN then DelFreeItem( pAC ) ;
  end ;
end ;

// -----------------------------------------------------------------------------

function TSystem_File_Access_List.Allow_Access( const AUserLRN, AClientLRN : Integer ) : Boolean ;
var
  i             : Integer ;
  pAC           : pFile_Access_Mapping_Rec ;
begin
  If not Restricted_User( AUserLRN ) then
  Begin { There are no access restrictions for this User LRN }
    Result := True;
    exit;
  end;
  { Otherwise check the list }
  Result := False ;
  for i := 0 to Pred( ItemCount ) do
  begin
    pAC := Access_At( i ) ;
    if ( pAC^.acClient_File_LRN = AClientLRN ) and ( pAC^.acUser_LRN = AUserLRN ) then
    begin
      Result := True ;
      exit ;
    end ;
  end ;
end ;

// -----------------------------------------------------------------------------

function TSystem_File_Access_List.Restrict_Access( const AUserLRN, AClientLRN : Integer ) : Boolean ;
begin
  Result := Not Allow_Access( AUserLRN, AClientLRN );
end;

// -----------------------------------------------------------------------------

function TSystem_File_Access_List.Restricted_Client_File( const AClientLRN : Integer ): Boolean;
var
  i             : Integer ;
begin
  Result := False ;
  for i := 0 to Pred( ItemCount ) do If Access_At( i )^.acClient_File_LRN = AClientLRN then
  begin
    Result := True ;
    exit ;
  end ;
end ;

// -----------------------------------------------------------------------------

function TSystem_File_Access_List.Restricted_User( const AUserLRN : Integer ): Boolean;
var
  i             : Integer ;
begin
  Result := False ;
  for i := 0 to Pred( ItemCount ) do If Access_At( i )^.acUser_LRN = AUserLRN then
  begin
    Result := True ;
    exit ;
  end ;
end;

// -----------------------------------------------------------------------------

procedure TSystem_File_Access_List.Insert_Access_Rec(const AUserLRN,
  AClientLRN: Integer);
Var
  A : pFile_Access_Mapping_Rec;
begin
  A := SYACIO.New_File_Access_Mapping_Rec;
  A.acUser_LRN := AUserLRN;
  A.acClient_File_LRN := AClientLRN;
  Insert( A );
end;

end.

