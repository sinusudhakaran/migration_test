UNIT SysDList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// System Disk Log - records downloaded disks
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
INTERFACE
USES
   eCollect, SYDEFS, IOSTREAM;

Type
   tSystem_Disk_Log = class( TExtdCollection )
      CONSTRUCTOR    Create;
   protected
      PROCEDURE      FreeItem( Item : Pointer ); override;
   public
      FUNCTION       Disk_Log_At( Index : LongInt ): pSystem_Disk_Log_Rec;
      PROCEDURE      SaveToFile( Var S : TIOStream );
      PROCEDURE      LoadFromFile( Var S : TIOStream );
   end;

//******************************************************************************
IMPLEMENTATION
   USES SYDLIO, TOKENS, LogUtil, MALLOC, sysutils, globals, bkdbExcept,
   bk5except;

CONST
   DebugMe : Boolean = FALSE;
   UnitName  = 'SYSDLIST32';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Constructor tSystem_Disk_Log.Create;
const
  ThisMethodName = 'TSystem_Disk_Log';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE tSystem_Disk_Log.FreeItem( Item : Pointer );
const
  ThisMethodName = 'TSystem_Disk_Log.FreeItem';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   SYDLIO.Free_System_Disk_Log_Rec_Dynamic_Fields( pSystem_Disk_Log_Rec( Item)^);
   SafeFreeMem( Item, System_Disk_Log_Rec_Size );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION tSystem_Disk_Log.Disk_Log_At( Index : Longint ) : pSystem_Disk_Log_Rec;
const
  ThisMethodName = 'TSystem_Disk_Log.Disk_Log_At';
Var
   P : Pointer;
Begin
   result := nil;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   P := At( Index );
   If SYDLIO.IsASystem_Disk_Log_Rec( P ) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE tSystem_Disk_Log.SaveToFile( Var S : TIOStream );
const
  ThisMethodName = 'TSystem_Disk_Log.SaveToFile';
Var
   i   : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   S.WriteToken( tkBeginSystem_Disk_Log);  //tkbeginsystem...
   For i := 0 to Pred( ItemCount ) do SYDLIO.Write_System_Disk_Log_Rec( Disk_Log_At( i )^, S );
   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   If DebugMe then LogUtil.LogMsg(lmDebug,'SYSDLIST32',
                                            Format('%s : %d disk log entries were saved.',[ThisMethodName, ItemCount]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE tSystem_Disk_Log.LoadFromFile( Var S : TIOStream );
const
  ThisMethodName = 'TSystem_Disk_Log.LoadFromFile';
Var
   Token : Byte;
   pD    : pSystem_Disk_Log_Rec;
   msg   : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_System_Disk_Log:
            Begin
               pD := New_System_Disk_Log_Rec;
               Read_System_Disk_Log_Rec ( pD^, S );
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
initialization
   DebugMe := DebugUnit(UnitName);
end.
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
