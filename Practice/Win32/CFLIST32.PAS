unit cfList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//admin system list of client file info
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  ECollect,Classes, syDefs, ioStream, sysUtils, AuditMgr, SysAudit;

Type
   tSystem_Client_File_List = class(TExtdSortedCollection)
      constructor Create;
      function    Compare( Item1, Item2 : pointer ) : integer; override;
   protected
      procedure   FreeItem( Item : Pointer ); override;
      function    FindRecordID( ARecordID : integer ):  pClient_File_Rec;
   public
      procedure   SaveToFile(var S : TIOStream );
      procedure   LoadFromFile(var S : TIOStream );
      function    Client_File_At( Index : LongInt ): pClient_File_Rec;
      function    FindCode( ACode : String ): pClient_File_Rec;
      function    FindLRN( LRN : LongInt ): pClient_File_Rec;

      procedure   DoAudit(AAuditType: TAuditType; AClientFileListCopy: tSystem_Client_File_List; var AAuditTable: TAuditTable);
      procedure   SetAuditInfo(P1, P2: pClient_File_Rec; var AAuditInfo: TAuditInfo);
      procedure   AddAuditValues(const AAuditRecord: TAudit_Trail_Rec; var Values: string);
      procedure   Insert(Item: Pointer); override;
   end;

//******************************************************************************
implementation
uses
   SYCFIO, TOKENS, LogUtil, STStrS, MALLOC, bkdbExcept,
   bk5except, SYAUDIT, bkConst;

CONST
   DebugMe : Boolean = FALSE;
   UnitName = 'CFLIST32';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// tSystem_Client_File_List

procedure tSystem_Client_File_List.AddAuditValues(
  const AAuditRecord: TAudit_Trail_Rec; var Values: string);
var
  i: integer;
  Token, Idx: byte;
  PW: string;
  ARecord: Pointer;
begin
  ARecord := AAuditRecord.atAudit_Record;
  if ARecord = nil then Exit;

  if ARecord = nil then begin
    Values := AAuditRecord.atOther_Info;
    Exit;
  end;

  Idx := 0;
  Token := AAuditRecord.atChanged_Fields[idx];
  while Token <> 0 do begin
    case Token of
      //File Code
      82: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, 81),
                                       TClient_File_Rec(ARecord^).cfFile_Code, Values);
      //File Name
      83: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, 82),
                                       TClient_File_Rec(ARecord^).cfFile_Name, Values);
      //File Type
//      84: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, 83),
//                                       TClient_File_Rec(ARecord^).cfFile_Type, Values);
      //File Status
      85: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, 84),
                                       fsNames[TClient_File_Rec(ARecord^).cfFile_Status], Values);
      //File Password
      86: begin
            for i := 1 to Length(TClient_File_Rec(ARecord^).cfFile_Password) do
              PW := PW + '*';
            SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, 85),
                                         PW, Values);
          end;
//   tkcfDate_Last_Accessed               = 87 ;
//   tkcfFile_Save_Count                  = 88 ;
//   tkcfUser_Responsible                 = 89 ;
//   tkcfCurrent_User                     = 90 ;
//   tkcfLRN                              = 91 ;
//   tkcfReport_Start_Date                = 92 ;
//   tkcfReporting_Period                 = 93 ;
//   tkcfForeign_File                     = 94 ;
//   tkcfUnused_Date_Field                = 95 ;
//   tkcfReports_Due                      = 96 ;
//   tkcfContact_Details_To_Show          = 97 ;
//   tkcfFinancial_Year_Starts            = 98 ;
//   tkcfSchd_Rep_Method                  = 99 ;
//   tkcfSpareBoolean                     = 100 ;
//   tkcfPending_ToDo_Count               = 101 ;
//   tkcfNext_ToDo_Desc                   = 102 ;
//   tkcfNext_ToDo_Rem_Date               = 103 ;
//   tkcfHas_Client_Notes                 = 104 ;
//   tkcfOverdue_ToDo_Count               = 105 ;
//   tkcfSched_Rep_Reports_To_Send        = 106 ;
//   tkcfContact_Details_Edit_Date        = 107 ;
//   tkcfContact_Details_Edit_Time        = 108 ;
//   tkcfBank_Accounts                    = 109 ;
//   tkcfDate_Of_Last_Entry_Printed       = 110 ;
//   tkcfLast_Print_Reports_Up_To         = 111 ;
//   tkcfClient_Type                      = 112 ;
//   tkcfCoded                            = 113 ;
//   tkcfFinalized                        = 114 ;
//   tkcfTransferred                      = 115 ;
//   tkcfLast_Processing_Status_Date      = 116 ;
//   tkcfSchd_Rep_Method_Filter           = 117 ;
      //Archived
      118: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, 117),
                                        TClient_File_Rec(ARecord^).cfArchived, Values);
//   tkcfPayee_Count                      = 119 ;
//   tkcfBank_Account_Count               = 120 ;
//   tkcfManual_Account_Count             = 121 ;
//   tkcfMem_Count                        = 122 ;
//   tkcfAccounting_System                = 123 ;
//   tkcfDownloaded                       = 124 ;
//   tkcfGroup_LRN                        = 125 ;
//   tkcfClient_Type_LRN                  = 126 ;
//   tkcfJob_Count                        = 127 ;
//   tkcfDivision_Count                   = 128 ;
//   tkcfGST_Period                       = 129 ;
//   tkcfGST_Start_Month                  = 130 ;
//   tkcfBulk_Extract_Code                = 131 ;
//   tkcfWebNotesAvailable                = 132 ;
//   tkcfWebNotes_Email_Notifications     = 133 ;
//   tkcfISO_Codes                        = 134 ;
//   tkcfAudit_Record_ID                  = 135 ;
    end;
    Inc(Idx);
    Token := AAuditRecord.atChanged_Fields[idx];
  end;
end;

function tSystem_Client_File_List.Client_File_At(Index: Integer): pClient_File_Rec;
const
  ThisMethodName = 'TSystem_Client_File_List.File_At';
var
   p : pointer;
begin
   Client_File_At := NIL;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   P := At( Index );
   If SYCFIO.IsAClient_File_Rec ( P ) then 
      Client_File_At := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Client_File_List.Compare(Item1, Item2: pointer): integer;
begin
   Compare := STStrS.CompStringS(pClient_File_Rec(Item1).cfFile_Code,pClient_File_Rec(Item2).cfFile_Code);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor tSystem_Client_File_List.Create;
const
  ThisMethodName = 'TSystem_Client_File_List.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

procedure tSystem_Client_File_List.DoAudit(AAuditType: TAuditType;
  AClientFileListCopy: tSystem_Client_File_List; var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: pClient_File_Rec;
  AuditInfo: TAuditInfo;
begin
  AuditInfo.AuditType := atClientFiles;
  AuditInfo.AuditUser := SystemAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_Client_File;
  //Adds, changes
  for I := 0 to Pred( itemCount ) do begin
    P1 := Items[i];
    P2 := AClientFileListCopy.FindRecordID(P1.cfAudit_Record_ID);
    AuditInfo.AuditRecord := New_Client_File_Rec;
    try
      SetAuditInfo(P1, P2, AuditInfo);
      if AuditInfo.AuditAction in [aaAdd, aaChange] then
        AAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
  end;
  //Deletes
  for i := 0 to AClientFileListCopy.ItemCount - 1 do begin
    P2 := AClientFileListCopy.Items[i];
    P1 := FindRecordID(P2.cfAudit_Record_ID);
    AuditInfo.AuditRecord := New_Client_File_Rec;
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
function tSystem_Client_File_List.FindCode(ACode: String): pClient_File_Rec;
const
  ThisMethodName = 'TSystem_Client_File_List.FindCode';
var
  L, H, I, C: Integer;
  pcf       : pClient_File_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %s',[ThisMethodName, ACode]));
  result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then begin
    if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : No Items',[ThisMethodName]));
    exit;      {no items in list}
  end;

  repeat
    I := (L + H) shr 1;
    pcf := pClient_File_Rec(At(i));
    C := STStrS.CompStringS(ACode, pcf^.cfFile_Code);
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then begin
    result := pcf;
    if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
    exit;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Client_File_List.FindLRN(LRN: LongInt): pClient_File_Rec;
const
  ThisMethodName = 'TSystem_Client_File_List.FindLRN';
var
  I: Integer;
  pcf: pClient_File_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, LRN]));
  result := nil;
  for i := 0 to Pred(ItemCount) do
  begin
    pcf := pClient_File_Rec(At(i));
    if pcf^.cfLRN = LRN then
    begin
      result := pcf;
      Break;
    end;
  end;
end;

function tSystem_Client_File_List.FindRecordID(
  ARecordID: integer): pClient_File_Rec;
const
  ThisMethodName = 'tSystem_Client_File_List.FindRecordID';
var
  i : LongInt;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, ARecordID]));
  Result := NIL;
  if (itemCount = 0 ) then Exit;

  for I := 0 to Pred( itemCount ) do
    with Client_File_At( I )^ do
      if cfAudit_Record_ID = ARecordID then begin
        Result := Client_File_At( I );
        if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
          Exit;
      end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_Client_File_List.FreeItem(Item: Pointer);
const
  ThisMethodName = 'TSystem_Client_File_List.FreeItem';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  SYCFIO.Free_Client_File_Rec_Dynamic_Fields( pClient_File_Rec( Item)^ );
  SafeFreeMem( Item, Client_File_Rec_Size );

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
procedure tSystem_Client_File_List.Insert(Item: Pointer);
begin
  pClient_File_Rec(Item).cfAudit_Record_ID := SystemAuditMgr.NextSystemRecordID;
  inherited;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_Client_File_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TSystem_Client_File_List.LoadFromFile';
Var
   Token       : Byte;
   CF          : pClient_File_Rec;
   msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Client_File :
            Begin
               MALLOC.SafeGetMem( CF, Client_File_Rec_Size );
               If not Assigned( CF ) then
               Begin
                  Msg := Format( '%s : Unabled to Allocate CF',[ThisMethodName]);
                  LogUtil.LogMsg(lmError, UnitName, Msg );
                  raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
               end;
               Read_Client_File_Rec ( CF^, S );
               inherited Insert( CF );
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
procedure tSystem_Client_File_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TSystem_Client_File_List.SaveToFile';
Var
   i        : LongInt;
   CF       : pClient_File_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   S.WriteToken( tkBeginSystem_Client_File_List );

   For i := 0 to Pred( itemCount ) do
   Begin
      CF := pClient_File_Rec( At( i ) );
      SYCFIO.Write_Client_File_Rec ( CF^, S );
   end;

   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : %d records saved',[ThisMethodName,itemCount]));
end;

procedure tSystem_Client_File_List.SetAuditInfo(P1, P2: pClient_File_Rec;
  var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditAction := aaNone;
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.cfAudit_Record_ID;
    AAuditInfo.AuditOtherInfo := Format('%s=%s',
                                        [SYAuditNames.GetAuditFieldName(tkBegin_Client_File, 81),
                                         P2.cfFile_Code]);
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.cfAudit_Record_ID;
    AAuditInfo.AuditParentID := SystemAuditMgr.GetParentRecordID(AAuditInfo.AuditRecordType,
                                                                 AAuditInfo.AuditRecordID);
    if Client_File_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.cfAudit_Record_ID;
    AAuditInfo.AuditParentID := SystemAuditMgr.GetParentRecordID(AAuditInfo.AuditRecordType,
                                                                 AAuditInfo.AuditRecordID);
    P1.cfAudit_Record_ID := AAuditInfo.AuditRecordID;
    SYCFIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_Client_File_Rec(P1, AAuditInfo.AuditRecord);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
