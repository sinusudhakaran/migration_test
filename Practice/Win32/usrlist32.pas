unit usrlist32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// List of Users in admin system
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  ECollect, Classes, syDefs, ioStream, sysUtils, AuditMgr;

Type
   tSystem_User_List = class(TExtdSortedCollection)
      constructor Create;
      function    Compare( Item1, Item2 : pointer ) : integer; override;
   protected
      procedure   FreeItem( Item : Pointer ); override;
      function    FindRecordID( ARecordID : integer ):  pUser_Rec;
   public
      function    User_At( Index : LongInt ): pUser_Rec;
      function    FindCode( ACode : String ): pUser_Rec;
      function    FindLRN( ALRN : LongInt ):  pUser_Rec;

      procedure   SaveToFile(var S : TIOStream );
      procedure   LoadFromFile(var S : TIOStream );

      procedure   DoAudit(AAuditType: TAuditType; AUserTableCopy: tSystem_User_List; var AAuditTable: TAuditTable);
      procedure   SetAuditInfo(P1, P2: pUser_Rec; var AAuditInfo: TAuditInfo);
      procedure   AddAuditValues(const AAuditRecord: TAudit_Trail_Rec; var Values: string);
      procedure   Insert(Item: Pointer); override;
   end;

//******************************************************************************
implementation
uses
   SYUSIO, TOKENS, logutil, MALLOC, StStrS, bkdbExcept, SYAUDIT,
   bk5Except, bkConst;

CONST
   DebugMe : Boolean = FALSE;
   UnitName = 'USRLIST32';

{ tSystem_User_List }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_User_List.AddAuditValues(const AAuditRecord: TAudit_Trail_Rec; var Values: string);
var
  i: integer;
  Token, Idx: byte;
  PW, UserType: string;
  ARecord: Pointer;
begin
  ARecord := AAuditRecord.atAudit_Record;

  if ARecord = nil then begin
    Values := AAuditRecord.atOther_Info;
    Exit;
  end;

  Idx := 0;
  Token := AAuditRecord.atChanged_Fields[idx];
  while Token <> 0 do begin
    case Token of
      //Code
      62: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, 61),
                                       tUser_Rec(ARecord^).usCode, Values);
      //Name
      63: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, 62),
                                       tUser_Rec(ARecord^).usName, Values);
      //Email
      65: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, 64),
                                       tUser_Rec(ARecord^).usEMail_Address, Values);
      //Password
      64: begin
            for i := 1 to Length(tUser_Rec(ARecord^).usPassword) do
              PW := PW + '*';
            SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, 63),
                                         PW, Values);
          end;
      //Direct Dial
      75: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, 74),
                                       tUser_Rec(ARecord^).usDirect_Dial, Values);
      //Type
      66: begin
            if (tUser_Rec(ARecord^).usSystem_Access) then
              UserType := ustNames[ustSystem]
            else if (tUser_Rec(ARecord^).usIs_Remote_User) then
              UserType := ustNames[ustRestricted]
            else
              UserType := ustNames[ustNormal];
            SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, 65),
                                         UserType, Values);
          end;
      //Master mems
      70: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, 69),
                                       tUser_Rec(ARecord^).usMASTER_Access, Values);

      //Print options
      77: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, 76),
                                       tUser_Rec(ARecord^).usShow_Printer_Choice, Values);
      //Headers
      82: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, 81),
                                       tUser_Rec(ARecord^).usSuppress_HF, Values);
      //Logo
      83: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, 82),
                                       tUser_Rec(ARecord^).usShow_Practice_Logo, Values);
    end;
    Inc(Idx);
    Token := AAuditRecord.atChanged_Fields[idx];
  end;
end;

function tSystem_User_List.Compare(Item1, Item2: pointer): integer;
begin
  Compare := StStrS.CompStringS( pUser_Rec(Item1).usCode, pUser_Rec(Item2).usCode );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor tSystem_User_List.Create;
const
  ThisMethodName = 'TSystem_User_List.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

procedure tSystem_User_List.DoAudit(AAuditType: TAuditType;
  AUserTableCopy: tSystem_User_List; var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: pUser_Rec;
  AuditInfo: TAuditInfo;
begin
  AuditInfo.AuditType := atUsers;
  AuditInfo.AuditUser := SystemAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_User;
  //Adds, changes
  for I := 0 to Pred( itemCount ) do begin
    P1 := Items[i];
    P2 := AUserTableCopy.FindRecordID(P1.usAudit_Record_ID);
    AuditInfo.AuditRecord := New_User_Rec;
    try
      SetAuditInfo(P1, P2, AuditInfo);
      if AuditInfo.AuditAction in [aaAdd, aaChange] then
        AAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
  end;
  //Deletes
  for i := 0 to AUserTableCopy.ItemCount - 1 do begin
    P2 := AUserTableCopy.Items[i];
    P1 := FindRecordID(P2.usAudit_Record_ID);
    AuditInfo.AuditRecord := New_User_Rec;
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
function tSystem_User_List.FindCode(ACode: String): pUser_Rec;
const
  ThisMethodName = 'TSystem_User_List.FindCode';
var
  L, H, I, C: Integer;
  pUser       : pUser_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %s',[ThisMethodName,ACode]));

  result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then exit;      {no items in list}
  repeat
    I := (L + H) shr 1;
    pUser := pUser_Rec(At(i));
    C := StStrS.CompStringS( ACode, pUser^.usCode);
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then begin
     result := pUser;
     if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
     exit;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_User_List.FindLRN(ALRN: Integer): pUser_Rec;
const
  ThisMethodName = 'TSystem_User_List';
var
   I : LongInt;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, aLRN]));
   result := NIL;
   If (itemCount = 0 ) then Exit;

   For I := 0 to Pred( itemCount ) do
      With User_At( I )^ do
         If usLRN = ALRN then
         Begin
            result := User_At( I );
            if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
            exit;
         end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;
function tSystem_User_List.FindRecordID(ARecordID: integer): pUser_Rec;
const
  ThisMethodName = 'TSystem_User_List.FindRecordID';
var
  i : LongInt;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, ARecordID]));
  Result := NIL;
  if (itemCount = 0 ) then Exit;

  for I := 0 to Pred( itemCount ) do
    with User_At( I )^ do
      if usAudit_Record_ID = ARecordID then begin
        Result := User_At( I );
        if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
          Exit;
      end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_User_List.FreeItem(Item: Pointer);
const
  ThisMethodName = 'TSystem_User_List.FreeItem';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  SYUSIO.Free_User_Rec_Dynamic_Fields( pUser_Rec( Item)^);
  SafeFreeMem( Item, User_Rec_Size );
  
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

procedure tSystem_User_List.Insert(Item: Pointer);
begin
  pUser_Rec(Item).usAudit_Record_ID := SystemAuditMgr.NextSystemRecordID;
  inherited Insert(Item);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_User_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TSystem_User_List.LoadFromFile';
Var
   Token       : Byte;
   US          : pUser_Rec;
   Msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_User :
            Begin
               SafeGetMem( US, User_Rec_Size );
               If not Assigned( US ) then
               Begin
                  Msg := Format( '%s : Unable to Allocate US',[ThisMethodName]);
                  LogUtil.LogMsg(lmError, UnitName, Msg );
                  raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
               end;
               Read_User_Rec ( US^, S );
               inherited Insert( US );
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
procedure tSystem_User_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TSystem_User_List.SaveToFile';
Var
   i        : LongInt;
   US       : pUser_Rec;
   USCount  : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   USCount := 0;

   S.WriteToken( tkBeginSystem_User_List );

   For i := 0 to Pred( itemCount ) do
   Begin
      US := pUser_Rec( At( i ) );
      SYUSIO.Write_User_Rec ( US^, S );
      Inc( USCount );
   end;

   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, Format('%s : %d user records were saved',[ThisMethodName,USCount]));
end;

procedure tSystem_User_List.SetAuditInfo(P1, P2: pUser_Rec;
  var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditAction := aaNone;
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.usAudit_Record_ID;
    AAuditInfo.AuditOtherInfo := Format('%s=%s',
                                        [SYAuditNames.GetAuditFieldName(tkBegin_User, 61),
                                         P2.usCode]);
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.usAudit_Record_ID;
    AAuditInfo.AuditParentID := SystemAuditMgr.GetParentRecordID(AAuditInfo.AuditRecordType,
                                                                 AAuditInfo.AuditRecordID);
    if User_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.usAudit_Record_ID;
    AAuditInfo.AuditParentID := SystemAuditMgr.GetParentRecordID(AAuditInfo.AuditRecordType,
                                                                 AAuditInfo.AuditRecordID);
    P1.usAudit_Record_ID := AAuditInfo.AuditRecordID;
    SYUSIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_User_Rec(P1, AAuditInfo.AuditRecord);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_User_List.User_At(Index: Integer): pUser_Rec;
const
  ThisMethodName = 'TSystem_User_List.User_At';
Var
   P : Pointer;
Begin
   result := nil;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   P := At( Index );
   If SYUSIO.IsAUser_Rec(p) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
end.
