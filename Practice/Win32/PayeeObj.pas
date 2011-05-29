unit PayeeObj;
//------------------------------------------------------------------------------
{
   Title:       PayeeObj

   Description: Payee Object

   Remarks:

   Author:      Matthew Hopkins, Michael Foot

}
//------------------------------------------------------------------------------
interface

uses
  Classes,
  BKDefs,
  IOStream,
  ECollect,
  AuditMgr;

type
   TPayeeLinesList = class(TExtdCollection)
   protected
     procedure FreeItem( Item : Pointer ); override;
   private
     function FindRecordID(ARecordID: integer): pPayee_Line_Rec;
   public
     function  PayeeLine_At( Index : LongInt ): pPayee_Line_Rec;
     procedure SaveToFile( Var S : TIOStream );
     procedure LoadFromFile( Var S : TIOStream );
     procedure UpdateCRC(var CRC : Longword);
     procedure CheckIntegrity;
     procedure DoAudit(AAuditType: TAuditType;
                       APayeeLinesListCopy: TPayeeLinesList;
                       AParentID: integer;
                       AAuditMgr : TClientAuditManager;
                       var AAuditTable: TAuditTable);
     procedure SetAuditInfo(P1, P2: pPayee_Line_Rec;
                            AParentID: integer;
                            var AAuditInfo: TAuditInfo);
     procedure Insert(Item: Pointer; AAuditMgr: TClientAuditManager); overload;
   end;

   TPayee = class
     pdFields : TPayee_Detail_Rec;
     pdLines  : TPayeeLinesList;

     constructor Create;
     destructor Destroy; override;
   private
     function GetName : ShortString;
   public
     property  pdNumber : Integer read pdFields.pdNumber;
     property  pdName : ShortString read GetName;

     function  pdLinesCount : integer;
     function  IsDissected : boolean;
     function  FirstLine : pPayee_Line_Rec;

     procedure SaveToFile( Var S : TIOStream );
     procedure LoadFromFile( Var S : TIOStream );
     procedure UpdateCRC(var CRC : Longword);
   end;


   //Compare function has been moved outside the Payee list so that it can be
   //used for sorting elsewhere.
   TPayee_List = class(TExtdSortedCollection)
   protected
      procedure FreeItem( Item : Pointer ); override;
   private
      FAuditMgr: TClientAuditManager;
   public
      constructor Create(AAuditMgr: TClientAuditManager);
      function FindRecordID( ARecordID : integer ):  TPayee;
      function  Payee_At( Index : LongInt ): TPayee;
      function  Find_Payee_Number( CONST ANumber: LongInt ): TPayee;
      function  Find_Payee_Name( CONST AName: String ): TPayee;
      function  Search_Payee_Name( CONST AName : ShortString ): TPayee;
      function Guess_Next_Payee_Number(const ANumber: Integer): TPayee;

      procedure SaveToFile( Var S : TIOStream );
      procedure LoadFromFile( Var S : TIOStream );

      procedure UpdateCRC(var CRC : Longword);
      procedure CheckIntegrity;

      procedure DoAudit(AAuditType: TAuditType; APayeeDetailCopy: TPayee_List;
                        AParentID: integer; var AAuditTable: TAuditTable);
      procedure SetAuditInfo(P1, P2: pPayee_Detail_Rec; AParentID: integer;
                             var AAuditInfo: TAuditInfo);
      procedure AddAuditValues(const AAuditRecord: TAudit_Trail_Rec; var Values: string);
      procedure Insert(Item: Pointer); override;
   end;

   function PayeeCompare(Item1, Item2: Pointer): integer;

implementation

uses
  Malloc,
  SysUtils,
  BK5Except,
  BKCRC,
  BKDBExcept,
  BKPLIO,
  BKPDIO,
  LogUtil,
  StStrS,
  Tokens,
  BKAUDIT,
  bkConst,
  GenUtils;

const
  UnitName = 'PayeeObj';

{ TPayee_List }

constructor TPayee.Create;
begin
  inherited Create;

  FillChar( pdFields, Sizeof( pdFields ), 0 );
  with pdFields do
  begin
    pdRecord_Type := tkBegin_Payee_Detail;
    pdEOR := tkEnd_Payee_Detail;
  end;

  pdLines := TPayeeLinesList.Create;
end;

destructor TPayee.Destroy;
begin
  pdLines.Free;
  Free_Payee_Detail_Rec_Dynamic_Fields(pdFields);
  inherited Destroy;
end;

procedure TPayee_List.AddAuditValues(const AAuditRecord: TAudit_Trail_Rec;
  var Values: string);
var
  Token, Idx: byte;
  ARecord: Pointer;
begin
  ARecord := AAuditRecord.atAudit_Record;

  if ARecord = nil then begin
    Values := AAuditRecord.atOther_Info;
    Exit;
  end;


  case AAuditRecord.atAudit_Record_Type of
    tkBegin_Payee_Detail:
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
            //Number
            92: FAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Detail, Token),
                                        tPayee_Detail_Rec(ARecord^).pdNumber, Values);
            //Name
            93: FAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Detail, Token),
                                        tPayee_Detail_Rec(ARecord^).pdName, Values);
          end;
          Inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
    tkBegin_Payee_Line:
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
            //Account
            97: FAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                        tPayee_Line_Rec(ARecord^).plAccount, Values);
            //Percentage
            98: case tPayee_Line_Rec(ARecord^).plLine_Type of
                  pltPercentage : FAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                                          Percent2Str(tPayee_Line_Rec(ARecord^).plPercentage), Values);
                  pltDollarAmt  : FAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                                          Money2Str(tPayee_Line_Rec(ARecord^).plPercentage), Values);
                end;
            //GST Class
            99: FAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                        tPayee_Line_Rec(ARecord^).plGST_Class, Values);
            //GST has been edited
            100: FAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                         tPayee_Line_Rec(ARecord^).plGST_Has_Been_Edited, Values);

            //GL_Narration
            101: FAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                         tPayee_Line_Rec(ARecord^).plGL_Narration, Values);
            //Line type
            102: FAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                        pltNames[tPayee_Line_Rec(ARecord^).plLine_Type], Values);
            //GST_Amount
            103: FAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                         Money2Str(tPayee_Line_Rec(ARecord^).plGST_Amount), Values);
            //Quantity
            115: FAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                         Quantity2Str(tPayee_Line_Rec(ARecord^).plQuantity), Values);
          end;
          Inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
  end;
end;

procedure TPayee_List.CheckIntegrity;
var
  LastCode : String[40];
  i : Integer;
  APayee : TPayee;
begin
  LastCode := '';
  for i := First to Last do
  begin
    APayee := Payee_At(i);
    if (APayee.pdName < LastCode) then
      Raise EDataIntegrity.CreateFmt('Payee List Sequence : %d', [i]);
    APayee.pdLines.CheckIntegrity;
    LastCode := APayee.pdName;
  end;
end;

//function TPayee_List.Compare(Item1, Item2: Pointer): integer;
function PayeeCompare(Item1, Item2: Pointer): integer;
var
  S1, S2: string;
begin
  S1 := '';
  S2 := '';
  if Assigned(Item1) then S1 := TPayee(Item1).pdName;
  if Assigned(Item1) then S2 := TPayee(Item2).pdName;
  Result := StStrS.CompStringS(S1, S2);
end;

constructor TPayee_List.Create(AAuditMgr: TClientAuditManager);
begin
  inherited Create;

  FAuditMgr := AAuditMgr;
  FCompare := PayeeCompare;
end;

procedure TPayee_List.DoAudit(AAuditType: TAuditType;
  APayeeDetailCopy: TPayee_List; AParentID: integer; var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: pPayee_Detail_Rec;
  AuditInfo: TAuditInfo;
  Payee: TPayee;
  M1, M2: TPayee;
begin
  AuditInfo.AuditType := atPayees;
  AuditInfo.AuditUser := FAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_Payee_Detail;
  //Adds, changes
  for i := 0 to Pred(ItemCount) do begin
    P1 := @TPayee(Items[i]).pdFields;
    P2 := nil;
    Payee := nil;
    if Assigned(APayeeDetailCopy) then //Sub list - may not be assigned
      Payee := APayeeDetailCopy.FindRecordID(P1.pdAudit_Record_ID);
    if Assigned(Payee) then
      P2 := @Payee.pdFields;
    AuditInfo.AuditRecord := New_Payee_Detail_Rec;
    try
      SetAuditInfo(P1, P2, AParentID, AuditInfo);
      if AuditInfo.AuditAction in [aaAdd, aaChange] then
        AAuditTable.AddAuditRec(AuditInfo);
    finally
      Dispose(AuditInfo.AuditRecord);
    end;
  end;
  //Deletes
  if Assigned(APayeeDetailCopy) then begin //Sub list - may not be assigned
    for i := 0 to APayeeDetailCopy.ItemCount - 1 do begin
      P2 := @TPayee(APayeeDetailCopy.Items[i]).pdFields;
      Payee := FindRecordID(P2.pdAudit_Record_ID);
      P1 := nil;
      if Assigned(Payee) then
        P1 := @Payee.pdFields;
      AuditInfo.AuditRecord := New_Payee_Detail_Rec;
      try
        SetAuditInfo(P1, P2, AParentID, AuditInfo);
        if (AuditInfo.AuditAction = aaDelete) then
          AAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
    end;
  end;

  //Audit Payee Lines
  for I := 0 to Pred(itemCount) do begin
    M1 := Items[i];
    M2 := nil;
    if Assigned(APayeeDetailCopy) then
      M2 := APayeeDetailCopy.FindRecordID(M1.pdFields.pdAudit_Record_ID);
    if Assigned(M1) then
      if Assigned(M2) then
        TPayee(M1).pdLines.DoAudit(atPayees,
                                   M2.pdLines,
                                   M1.pdFields.pdAudit_Record_ID,
                                   FAuditMgr,
                                   AAuditTable)
      else
        M1.pdLines.DoAudit(atPayees,
                           nil,
                           M1.pdFields.pdAudit_Record_ID,
                           FAuditMgr,
                           AAuditTable);
  end;
end;

function TPayee_List.FindRecordID(ARecordID: integer): TPayee;
var
  i : integer;
begin
  Result := nil;
  if (itemCount = 0 ) then Exit;

  for i := 0 to Pred( ItemCount ) do
    if Payee_At(i).pdFields.pdAudit_Record_ID = ARecordID then begin
      Result := Payee_At(i);
      Exit;
    end;
end;

function TPayee_List.Find_Payee_Name(const AName: String): TPayee;
var
  i : Integer;
  APayee : TPayee;
begin
  Result := nil;

  for i := First to Last do
  begin
    APayee := Payee_At(i);
    if (APayee.pdName = AName) then
    begin
      Result := APayee;
      exit;
    end;
  end;
end;

function TPayee_List.Find_Payee_Number(const ANumber: Integer): TPayee;
var
  i : Integer;
  APayee : TPayee;
begin
  Result := nil;

  for i := First to Last do
  begin
    APayee := Payee_At(i);
    if (APayee.pdNumber = ANumber) then
    begin
      Result := APayee;
      exit;
    end;
  end;
end;

// Get next number given a number that doesn't exist
function TPayee_List.Guess_Next_Payee_Number(const ANumber: Integer): TPayee;
var
  i : Integer;
  APayee : TPayee;
  BestMatch: Integer;
begin
  Result := Find_Payee_Number(ANumber);
  if not Assigned(Result) then
  begin
    BestMatch := 999999;
    for I := First to Last do
    begin
      APayee := Payee_At(i);
      if (APayee.pdNumber > ANumber) and ((APayee.pdNumber - ANumber) < BestMatch) then
      begin
        BestMatch := APayee.pdNumber - ANumber;
        Result := APayee;
      end;
    end;
  end;
end;

procedure TPayee_List.Insert(Item: Pointer);
begin
  TPayee(Item).pdFields.pdAudit_Record_ID := FAuditMgr.NextClientRecordID;
  inherited Insert(Item);
end;

procedure TPayee_List.FreeItem(Item: Pointer);
begin
  TPayee(Item).Free;
end;

procedure TPayee_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TPayee_List.LoadFromFile';
var
  Token    : Byte;
  P        : TPayee;
  msg      : string;
begin                                  
   Token := S.ReadToken;
   while ( Token <> tkEndSection ) do
   begin
      case Token of
         tkBegin_Payee_Detail :
           begin
              P := TPayee.Create;
              if not Assigned( P ) then
              begin
                 Msg := Format( '%s : Unable to allocate P',[ThisMethodName]);
                 LogUtil.LogMsg(lmError, UnitName, Msg );
                 raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
              end;
              P.LoadFromFile( S );
              inherited Insert( P );
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
end;

function TPayee_List.Payee_At(Index: Integer): TPayee;
begin
  Result := At(Index);
end;

procedure TPayee_List.SaveToFile(var S: TIOStream);
var
  i : Integer;
begin
   S.WriteToken( tkBeginPayeesList );
   for i := First to Last do
     Payee_At(i).SaveToFile(S);
   S.WriteToken( tkEndSection );
end;

function TPayee_List.Search_Payee_Name(const AName: ShortString): TPayee;
begin
  //Not used. See pyList32.Search_Payee_Name.
  Result := nil;
end;

procedure TPayee_List.SetAuditInfo(P1, P2: pPayee_Detail_Rec;
  AParentID: integer; var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditAction := aaNone;
  AAuditInfo.AuditParentID := AParentID;
  AAuditInfo.AuditOtherInfo := Format('%s=%s', ['RecordType','Payee']) +
                               VALUES_DELIMITER +
                               Format('%s=%d', ['ParentID', AParentID]);
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.pdAudit_Record_ID;
    AAuditInfo.AuditOtherInfo :=
      AAuditInfo.AuditOtherInfo + VALUES_DELIMITER +
      Format('%s=%d',[BKAuditNames.GetAuditFieldName(tkBegin_Payee_Detail, 91), P2.pdNumber]) +
      VALUES_DELIMITER +
      Format('%s=%s',[BKAuditNames.GetAuditFieldName(tkBegin_Payee_Detail, 92), P2.pdName]);
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.pdAudit_Record_ID;
    if Payee_Detail_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.pdAudit_Record_ID;
    P1.pdAudit_Record_ID := AAuditInfo.AuditRecordID;
    BKPDIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_Payee_Detail_Rec(P1, AAuditInfo.AuditRecord);
  end;
end;

procedure TPayee_List.UpdateCRC(var CRC: Longword);
var
  i : integer;
begin
  for i := First to Last do
    Payee_At(i).UpdateCRC(CRC);
end;

function TPayee.FirstLine: pPayee_Line_Rec;
begin
  if pdLines.ItemCount > 0 then
    result := pdLines.PayeeLine_At(0)
  else
    result := nil;
end;

function TPayee.GetName: ShortString;
begin
  Result := pdFields.pdName;
end;

function TPayee.IsDissected: boolean;
begin
  result := pdLines.ItemCount > 1;
end;

procedure TPayee.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TPayee.LoadFromFile';
var
  Token    : Byte;
  msg      : string;
begin
   Token := tkBegin_Payee_Detail;
   repeat
      case Token of
         tkBegin_Payee_Detail :
           BKPDIO.Read_Payee_Detail_Rec(pdFields, S);
         tkBeginPayeeLinesList :
           pdLines.LoadFromFile(S);
      else
         begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
            LogUtil.LogMsg(lmError, UnitName, Msg );
            raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   until Token = tkEndSection;
end;

function TPayee.pdLinesCount: integer;
begin
  result := pdLines.ItemCount;
end;

procedure TPayee.SaveToFile(var S: TIOStream);
begin
  BKPDIO.Write_Payee_Detail_Rec(pdFields, S);
  pdLines.SaveToFile(S);
  S.WriteToken(tkEndSection);
end;

procedure TPayee.UpdateCRC(var CRC: Longword);
begin
  BKCRC.UpdateCRC(pdFields, CRC);
  pdLines.UpdateCRC(CRC);
end;

{ TPayeeLinesList }

procedure TPayeeLinesList.CheckIntegrity;
var
  i : Integer;
begin
  for i := First to Last do
    with PayeeLine_At(i)^ do;
end;

procedure TPayeeLinesList.DoAudit(AAuditType: TAuditType;
  APayeeLinesListCopy: TPayeeLinesList; AParentID: integer;
  AAuditMgr : TClientAuditManager;
  var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: pPayee_Line_Rec;
  AuditInfo: TAuditInfo;
begin
  AuditInfo.AuditType := atPayees;
  AuditInfo.AuditUser := AAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_Payee_Line;
  //Adds, changes
  for i := 0 to Pred(ItemCount) do begin
    P1 := PayeeLine_At(i);
    P2 := nil;
    if Assigned(APayeeLinesListCopy) then //Sub list - may not be assigned
      P2 := APayeeLinesListCopy.FindRecordID(P1.plAudit_Record_ID);
    AuditInfo.AuditRecord := New_Payee_Line_Rec;
    try
      SetAuditInfo(P1, P2, AParentID, AuditInfo);
      if AuditInfo.AuditAction in [aaAdd, aaChange] then
        AAuditTable.AddAuditRec(AuditInfo);
    finally
      Dispose(AuditInfo.AuditRecord);
    end;
  end;
  //Deletes
  if Assigned(APayeeLinesListCopy) then begin //Sub list - may not be assigned
    for i := 0 to APayeeLinesListCopy.ItemCount - 1 do begin
      P2 := APayeeLinesListCopy.PayeeLine_At(i);
      P1 := FindRecordID(P2.plAudit_Record_ID);
      AuditInfo.AuditRecord := New_Payee_Line_Rec;
      try
        SetAuditInfo(P1, P2, AParentID, AuditInfo);
        if (AuditInfo.AuditAction = aaDelete) then
          AAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
    end;
  end;
end;

function TPayeeLinesList.FindRecordID(ARecordID: integer): pPayee_Line_Rec;
var
  i : integer;
begin
  Result := nil;
  if (ItemCount = 0) then Exit;

  for i := 0 to Pred(ItemCount) do
    if PayeeLine_At(i).plAudit_Record_ID = ARecordID then begin
      Result := PayeeLine_At(i);
      Exit;
    end;
end;

procedure TPayeeLinesList.FreeItem(Item: Pointer);
begin
  if BKPLIO.IsAPayee_Line_Rec( Item ) then begin
    BKPLIO.Free_Payee_Line_Rec_Dynamic_Fields( pPayee_Line_Rec( Item)^ );
    SafeFreeMem( Item, Payee_Line_Rec_Size );
  end;
end;

procedure TPayeeLinesList.Insert(Item: Pointer; AAuditMgr: TClientAuditManager);
begin
  pPayee_Line_Rec(Item).plAudit_Record_ID := AAuditMgr.NextClientRecordID;
  inherited Insert(Item);
end;

procedure TPayeeLinesList.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TPayeeLinesList.LoadFromFile';
var
  Token    : Byte;
  PL       : pPayee_Line_Rec;
  msg      : string;
begin
   Token := S.ReadToken;
   while ( Token <> tkEndSection ) do
   begin
      case Token of
         tkBegin_Payee_Line :
           begin
              PL := New_Payee_Line_Rec;
              BKPLIO.Read_Payee_Line_Rec(PL^, S);
              Insert(PL);
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
end;

function TPayeeLinesList.PayeeLine_At(Index: Integer): pPayee_Line_Rec;
var
  P : Pointer;
begin
  Result := nil;
  P := At(Index);
  if (BKPLIO.IsAPayee_Line_Rec(P)) then
    Result := P;
end;

procedure TPayeeLinesList.SaveToFile(var S: TIOStream);
var
  i : Integer;
begin
  S.WriteToken(tkBeginPayeeLinesList);
  for i := First To Last do
    BKPLIO.Write_Payee_Line_Rec(PayeeLine_At(i)^, S);
  S.WriteToken(tkEndSection);
end;

procedure TPayeeLinesList.SetAuditInfo(P1, P2: pPayee_Line_Rec;
  AParentID: integer; var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditAction := aaNone;
  AAuditInfo.AuditParentID := AParentID;
  AAuditInfo.AuditOtherInfo := Format('%s=%s', ['RecordType','Payee Line']) +
                               VALUES_DELIMITER +
                               Format('%s=%d', ['ParentID', AParentID]);
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.plAudit_Record_ID;
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.plAudit_Record_ID;
    if Payee_Line_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.plAudit_Record_ID;
    P1.plAudit_Record_ID := AAuditInfo.AuditRecordID;
    BKPLIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_Payee_Line_Rec(P1, AAuditInfo.AuditRecord);
  end;
end;

procedure TPayeeLinesList.UpdateCRC(var CRC: Longword);
var
  i : Integer;
begin
  for i := First to Last do
    BKCRC.UpdateCRC(PayeeLine_At(i)^, CRC)
end;

end.
