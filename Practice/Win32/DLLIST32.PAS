UNIT dlList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Disk log for client
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
INTERFACE
USES
   eCollect, BKDEFS, IOSTREAM;

Type
   tDisk_List = class( TExtdCollection )
      CONSTRUCTOR    Create; override;
   protected
      PROCEDURE      FreeItem( Item : Pointer ); override;
   public
      FUNCTION       Disk_Log_At( Index : LongInt ): pDisk_Log_Rec;
      PROCEDURE      SaveToFile( Var S : TIOStream );
      PROCEDURE      LoadFromFile( Var S : TIOStream );

      procedure      UpdateCRC(var CRC : Longword);
   end;

//******************************************************************************
IMPLEMENTATION
USES
  BKDLIO, TOKENS, LogUtil, MALLOC, sysutils, bkdbExcept,
   bk5Except, bkCRC;

CONST
   DebugMe : Boolean = FALSE;
   UnitName = 'DLLIST32';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Constructor TDisk_List.Create;
const
  ThisMethodName = 'TDisk_List.Create';
Begin                   { Sorted, AllowDups }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TDisk_List.FreeItem( Item : Pointer );
const
  ThisMethodName = 'TDisk_List.FreeItem';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   If BKDLIO.IsADisk_Log_Rec( Item ) then begin
      BKDLIO.Free_Disk_Log_Rec_Dynamic_Fields( pDisk_Log_Rec( Item)^ );
      SafeFreeMem( Item, Disk_Log_Rec_Size );
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION TDisk_List.Disk_Log_At( Index : Longint ) : pDisk_Log_Rec;
const
  ThisMethodName = '';
Var
   P : Pointer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := nil;
   P := At( Index );
   If BKDLIO.IsADisk_Log_Rec( P ) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TDisk_List.SaveToFile( Var S : TIOStream );
const
  ThisMethodName = 'TDisk_List.SaveToFile';
Var
   i   : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   S.WriteToken( tkBeginDiskList );
   For i := 0 to Pred( ItemCount ) do BKDLIO.Write_Disk_Log_Rec( Disk_Log_At( i )^, S );
   S.WriteToken( tkEndSection );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : %d entries saved',[ThisMethodName, itemCount]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TDisk_List.LoadFromFile( Var S : TIOStream );
const
  ThisMethodName = 'TDisk_List.LoadFromFile';
Var
   Token : Byte;
   pD    : pDisk_Log_Rec;
   msg : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Disk_Log :
            Begin
               pD := New_Disk_Log_Rec;
               Read_Disk_Log_Rec ( pD^, S );
               Insert( pD );
            end;
         else
         begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
            LogUtil.LogMsg(lmError, UnitName, Msg );
            raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tDisk_List.UpdateCRC(var CRC: Longword);
var
   i : integer;
begin
   for i := 0 to Pred( ItemCount) do
      BKCRC.UpdateCRC( Disk_Log_At( i)^, CRC);
end;

initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.

