UNIT SysDList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// System Disk Log - records downloaded disks
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
INTERFACE
USES
   eCollect, SYDEFS, IOSTREAM, AuditMgr;

Type
   tSystem_Disk_Log = class( TExtdCollection )
      CONSTRUCTOR    Create;
   protected
      PROCEDURE      FreeItem( Item : Pointer ); override;
      function       FindRecordID( ARecordID : integer ):  pSystem_Disk_Log_Rec;
   public
      FUNCTION       Disk_Log_At( Index : LongInt ): pSystem_Disk_Log_Rec;
      PROCEDURE      SaveToFile( Var S : TIOStream );
      PROCEDURE      LoadFromFile( Var S : TIOStream );

      procedure DoAudit(AAuditType: TAuditType; ASystemDiskLogCopy: tSystem_Disk_Log; var AAuditTable: TAuditTable);
      procedure SetAuditInfo(P1, P2: pSystem_Disk_Log_Rec; var AAuditInfo: TAuditInfo);
      procedure AddAuditValues(const AAuditRecord: TAudit_Trail_Rec; var Values: string);
      function Insert(Item: Pointer): integer; override;
   end;

//******************************************************************************
IMPLEMENTATION
   USES SYDLIO, TOKENS, LogUtil, MALLOC, sysutils, globals, bkdbExcept,
   bk5except, SYAUDIT, bkDateUtils;

CONST
   DebugMe : Boolean = FALSE;
   UnitName  = 'SYSDLIST32';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_Disk_Log.AddAuditValues(const AAuditRecord: TAudit_Trail_Rec;
  var Values: string);
var
  Token, Idx: byte;
  ARecord: Pointer;
begin
  ARecord := AAuditRecord.atAudit_Record;
  if ARecord = nil then Exit;

  Idx := 0;
  Token := AAuditRecord.atChanged_Fields[idx];
  while Token <> 0 do begin
    case Token of
      //Disk_ID
      42: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Disk_Log, 41),
                                       TSystem_Disk_Log_Rec(ARecord^).dlDisk_ID, Values);
      //Date_Downloaded
      43: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Disk_Log, 42),
                                       bkDate2Str(TSystem_Disk_Log_Rec(ARecord^).dlDate_Downloaded), Values);
      //No_of_Accounts
      44: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Disk_Log, 43),
                                       TSystem_Disk_Log_Rec(ARecord^).dlNo_of_Accounts, Values);
      //No_of_Entries
      45: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Disk_Log, 44),
                                       TSystem_Disk_Log_Rec(ARecord^).dlNo_of_Entries, Values);
      //Was_In_Last_Download
      46: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Disk_Log, 45),
                                       TSystem_Disk_Log_Rec(ARecord^).dlWas_In_Last_Download, Values);
    end;
    Inc(Idx);
    Token := AAuditRecord.atChanged_Fields[idx];
  end;
end;

Constructor tSystem_Disk_Log.Create;
const
  ThisMethodName = 'TSystem_Disk_Log';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function tSystem_Disk_Log.FindRecordID(
  ARecordID: integer): pSystem_Disk_Log_Rec;
const
  ThisMethodName = 'TSystem_Disk_Log.FindRecordID';
var
  i : LongInt;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, ARecordID]));
  Result := NIL;
  if (itemCount = 0 ) then Exit;

  for I := 0 to Pred( itemCount ) do
    with Disk_Log_At( I )^ do
      if dlAudit_Record_ID = ARecordID then begin
        Result := Disk_Log_At( I );
        if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
          Exit;
      end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;

PROCEDURE tSystem_Disk_Log.FreeItem( Item : Pointer );
const
  ThisMethodName = 'TSystem_Disk_Log.FreeItem';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   SYDLIO.Free_System_Disk_Log_Rec_Dynamic_Fields( pSystem_Disk_Log_Rec( Item)^);
   SafeFreeMem( Item, System_Disk_Log_Rec_Size );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function tSystem_Disk_Log.Insert(Item: Pointer): integer; 
begin
  pSystem_Disk_Log_Rec(Item).dlAudit_Record_ID := SystemAuditMgr.NextSystemRecordID;
  Result := inherited Insert(Item);
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
procedure tSystem_Disk_Log.DoAudit(AAuditType: TAuditType;
  ASystemDiskLogCopy: tSystem_Disk_Log; var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: pSystem_Disk_Log_Rec;
  AuditInfo: TAuditInfo;
begin
  AuditInfo.AuditType := atDownloadingData;
  AuditInfo.AuditUser := SystemAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_System_Disk_Log;
  //Adds, changes
  for I := 0 to Pred( itemCount ) do begin
    P1 := Items[i];
    P2 := ASystemDiskLogCopy.FindRecordID(P1.dlAudit_Record_ID);
    AuditInfo.AuditRecord := New_System_Disk_Log_Rec;
    try
      SetAuditInfo(P1, P2, AuditInfo);
      if AuditInfo.AuditAction in [aaAdd, aaChange] then
        AAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
  end;
  //Deletes
  for i := 0 to ASystemDiskLogCopy.ItemCount - 1 do begin
    P2 := ASystemDiskLogCopy.Items[i];
    P1 := FindRecordID(P2.dlAudit_Record_ID);
    AuditInfo.AuditRecord := New_System_Disk_Log_Rec;
    try
      SetAuditInfo(P1, P2, AuditInfo);
      if (AuditInfo.AuditAction = aaDelete) then
        AAuditTable.AddAuditRec(AuditInfo);
    finally
      Dispose(AuditInfo.AuditRecord);
    end;
  end;
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
procedure tSystem_Disk_Log.SetAuditInfo(P1, P2: pSystem_Disk_Log_Rec;
  var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditAction := aaNone;
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.dlAudit_Record_ID;
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.dlAudit_Record_ID;
    AAuditInfo.AuditParentID := SystemAuditMgr.GetParentRecordID(AAuditInfo.AuditRecordType,
                                                                 AAuditInfo.AuditRecordID);
    if System_Disk_Log_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.dlAudit_Record_ID;
    AAuditInfo.AuditParentID := SystemAuditMgr.GetParentRecordID(AAuditInfo.AuditRecordType,
                                                                 AAuditInfo.AuditRecordID);
    P1.dlAudit_Record_ID := AAuditInfo.AuditRecordID;
    SYDLIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_System_Disk_Log_Rec(P1, AAuditInfo.AuditRecord);
  end;
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
               inherited Insert( pD );
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
