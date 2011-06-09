unit CustomHeadingsListObj;
//------------------------------------------------------------------------------
{
   Title:       Custom Headings List Object

   Description: Stores a list of custom heading objects.  The heading list is used
                to store Sub Group Headings and Division headings.

   Author:      Matthew Hopkins  Jun 2002

   Remarks:     A simple list object to hold the report headings. Each item in
                the list is a pointer pCustom_Heading_Rec that points to a
                TCustom_Heading_Rec structure:
}
//------------------------------------------------------------------------------

interface
uses
  eCollect,
  IOSTREAM,
  BKDEFS,
  AuditMgr;

type
  tNew_Custom_Headings_List = class ( TExtdCollection )
  protected
    procedure FreeItem(Item : Pointer); override;
    function  Custom_Heading_At(Index : Integer): pCustom_Heading_Rec;
    function  Find_Heading( const HeadingType, MajorID, MinorID : integer ): pCustom_Heading_Rec;
    function FindRecordID( ARecordID : integer ):  pCustom_Heading_Rec;
  private
    FAuditMgr: TClientAuditManager;
  public
    constructor Create(AAuditMgr: TClientAuditManager);
    procedure LoadFromFile(var S : TIOStream);
    procedure SaveToFile(var S : TIOStream);
    procedure UpdateCRC(var CRC : LongWord);
    procedure CheckIntegrity;
    function  Insert( Item : Pointer ) : integer; override;

    function    Get_SubGroup_Heading( const SubGroupNo : integer ) : string;
    procedure   Set_SubGroup_Heading( const SubGroupNo : integer; Heading : string );

    function    Get_Division_Heading( const DivisionNo : integer) : string;
    procedure   Set_Division_Heading( const DivisionNo : integer; Heading : string);

    procedure DoAudit(AAuditType: TAuditType; ACustomHeadingListCopy: tNew_Custom_Headings_List;
                      AParentID: integer; var AAuditTable: TAuditTable);
    procedure SetAuditInfo(P1, P2: pCustom_Heading_Rec; AParentID: integer;
                           var AAuditInfo: TAuditInfo);
  end;

//******************************************************************************
implementation
uses
  bk5Except,
  bkcrc,
  bkdbExcept,
  GenUtils,
  LogUtil,
//  bkshio,
//  bkdhio,
  bkhdio,
  malloc,
  SysUtils,
  Tokens,
  BKAudit;

const
  Unitname = 'CustomHeadingsListObj';

const
  htBase            = 0;
  htSubGroupHeading = 1;
  htDivisionHeading = 2;

  SUnknownToken = 'HDList Error: Unknown token %d';

{ tNew_Custom_Headings_List }

procedure tNew_Custom_Headings_List.CheckIntegrity;
var
  i : integer;
begin
  for i := First to Last do
    with Custom_Heading_At( i )^ do;
end;

constructor tNew_Custom_Headings_List.Create(AAuditMgr: TClientAuditManager);
begin
  inherited Create;

  FAuditMgr := AAuditMgr;
end;

function tNew_Custom_Headings_List.Custom_Heading_At(
  Index: Integer): pCustom_Heading_Rec;
var
  P: Pointer;
begin
  result := nil;
  P := At( Index );
  if BKHDIO.IsACustom_Heading_Rec( P ) then
    result := P;
end;

procedure tNew_Custom_Headings_List.DoAudit(AAuditType: TAuditType;
  ACustomHeadingListCopy: tNew_Custom_Headings_List; AParentID: integer;
  var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: pCustom_Heading_Rec;
  AuditInfo: TAuditInfo;
begin
  AuditInfo.AuditType := atCustomHeadings;
  AuditInfo.AuditUser := FAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_Custom_Heading;
  //Adds, changes
  for i := 0 to Pred(ItemCount) do begin
    P1 := Items[i];
    P2 := nil;
    if Assigned(ACustomHeadingListCopy) then
      P2 := ACustomHeadingListCopy.Find_Heading(P1.hdHeading_Type,
                                                P1.hdMajor_ID,
                                                P1.hdMinor_ID);
    AuditInfo.AuditRecord := New_Custom_Heading_Rec;
    try
      SetAuditInfo(P1, P2, AParentID, AuditInfo);
      if AuditInfo.AuditAction in [aaAdd, aaChange] then
        AAuditTable.AddAuditRec(AuditInfo);
    finally
      Dispose(AuditInfo.AuditRecord);
    end;
  end;
  //Deletes
  if Assigned(ACustomHeadingListCopy) then begin //Sub list - may not be assigned
    for i := 0 to ACustomHeadingListCopy.ItemCount - 1 do begin
      P2 := ACustomHeadingListCopy.Items[i];
      P1 := FindRecordID(P2.hdAudit_Record_ID);
      AuditInfo.AuditRecord := New_Custom_Heading_Rec;
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

function tNew_Custom_Headings_List.FindRecordID(
  ARecordID: integer): pCustom_Heading_Rec;
var
  i : integer;
begin
  Result := nil;
  if (ItemCount = 0) then Exit;

  for i := 0 to Pred(ItemCount) do
    if Custom_Heading_At(i).hdAudit_Record_ID = ARecordID then begin
      Result := Custom_Heading_At(i);
      Exit;
    end;
end;

function tNew_Custom_Headings_List.Find_Heading(const HeadingType, MajorID, MinorID: integer): pCustom_Heading_Rec;
Var
  i : Integer;
  P : pCustom_Heading_Rec;
begin
  Result := NIL;
  For i := 0 to Pred( ItemCount ) do
  Begin
    P := Custom_Heading_At( i );
    If ( P^.hdHeading_Type = HeadingType ) and
       ( P^.hdMajor_ID = MajorID ) and
       ( P^.hdMinor_ID = MinorID ) then
    Begin
      Result := P;
      exit;
    end;
  end;
end;

procedure tNew_Custom_Headings_List.FreeItem(Item: Pointer);
begin
  if BKHDIO.IsACustom_Heading_Rec( Item ) then
  begin
     BKhdIO.Free_Custom_Heading_Rec_Dynamic_Fields( pCustom_Heading_Rec( Item)^ );
     SafeFreeMem( Item, Custom_Heading_Rec_Size );
  end;
end;

function tNew_Custom_Headings_List.Get_Division_Heading(
  const DivisionNo: integer): string;
Var
  P : pCustom_Heading_Rec;
begin
  P := Find_Heading( htDivisionHeading, DivisionNo, 0 );
  If Assigned( P ) then
    Result := P^.hdHeading
  else
    Result := '';
end;

function tNew_Custom_Headings_List.Get_SubGroup_Heading(
  const SubGroupNo: integer): string;
Var
  P : pCustom_Heading_Rec;
begin
  P := Find_Heading( htSubgroupHeading, 0, SubGroupNo );
  If Assigned( P ) then
    Result := P^.hdHeading
  else
    Result := '';
end;

function tNew_Custom_Headings_List.Insert(Item: Pointer): integer;
begin
  if Assigned(FAuditMgr) then
    pCustom_Heading_Rec(Item)^.hdAudit_Record_ID := FAuditMgr.NextAuditRecordID;

  inherited Insert(Item);
end;

procedure tNew_Custom_Headings_List.LoadFromFile(var S: TIOStream);
var
  Token: Byte;
  pH: pCustom_Heading_Rec;
begin
  Token := S.ReadToken;
  while ( Token <> tkEndSection ) do
  begin
    case Token of
      tkBegin_Custom_Heading :
        begin
          pH := New_Custom_Heading_Rec;
          Read_Custom_Heading_Rec( pH^, S );
          inherited Insert( pH );
        end;
      else
        Raise Exception.CreateFmt( SUnknownToken, [ Token ] );
    end; { of Case }
    Token := S.ReadToken;
  end;
end;

procedure tNew_Custom_Headings_List.SaveToFile(var S: TIOStream);
var
  i : Integer;
begin
  S.WriteToken( tkBeginCustomHeadingsListEx );
  for i := 0 to Pred( ItemCount ) do BKHDIO.Write_Custom_Heading_Rec( Custom_Heading_At( i )^, S );
  S.WriteToken( tkEndSection );
end;

procedure tNew_Custom_Headings_List.SetAuditInfo(P1, P2: pCustom_Heading_Rec;
  AParentID: integer; var AAuditInfo: TAuditInfo);
var
  TempStr: string;
  HeadingType: byte;
begin
  AAuditInfo.AuditAction := aaNone;
  AAuditInfo.AuditParentID := AParentID;

  //Get heading type
  if Assigned(P1) then
    HeadingType := P1.hdHeading_Type
  else if Assigned(P2) then
    HeadingType := P2.hdHeading_Type
  else
    Exit;

  //other info
  case HeadingType of
    htDivisionHeading: TempStr := 'Divisional Heading';
    htSubGroupHeading: TempStr := 'Sub-group Heading';
  end;
  AAuditInfo.AuditOtherInfo := Format('%s=%s', ['RecordType', TempStr]);

  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.hdAudit_Record_ID;
    AAuditInfo.AuditOtherInfo :=
      AAuditInfo.AuditOtherInfo + VALUES_DELIMITER +
      Format('%s=%s',[BKAuditNames.GetAuditFieldName(tkBegin_Custom_Heading, 233), P2.hdHeading]);
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.hdAudit_Record_ID;
    if Custom_Heading_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.hdAudit_Record_ID;
    P1.hdAudit_Record_ID := AAuditInfo.AuditRecordID;
    bkhdio.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_Custom_Heading_Rec(P1, AAuditInfo.AuditRecord);
  end;
end;

procedure tNew_Custom_Headings_List.Set_Division_Heading(
  const DivisionNo: integer; Heading: string);
Var
  P : pCustom_Heading_Rec;
begin
  P := Find_Heading( htDivisionHeading, DivisionNo, 0 );

  If ( Trim( Heading ) = '' ) then
  begin { Deletion }
    If Assigned( P ) then
      DelFreeItem( P );
    exit;
  end;

  If Assigned( P ) then
  Begin { Change Current Heading }
    P^.hdHeading := Trim( Heading );
    exit;
  end;

  { Add a new Heading}
  P := New_Custom_Heading_Rec;
  P^.hdHeading_Type     := htDivisionHeading;
  P^.hdMajor_ID         := DivisionNo;
  P^.hdMinor_ID         := 0;
  P^.hdHeading          := Trim( Heading );
  Insert( P );
end;

procedure tNew_Custom_Headings_List.Set_SubGroup_Heading(
  const SubGroupNo: integer; Heading: string);
Var
  P : pCustom_Heading_Rec;
begin
  P := Find_Heading( htSubgroupHeading, 0, SubGroupNo );

  If ( Trim( Heading ) = '' ) then
  begin { Deletion }
    If Assigned( P ) then
      DelFreeItem( P );
    exit;
  end;

  If Assigned( P ) then
  Begin { Change Current Heading }
    P^.hdHeading := Trim( Heading );
    exit;
  end;

  { Add a new Heading}
  P := New_Custom_Heading_Rec;
  P^.hdHeading_Type     := htSubgroupHeading;
  P^.hdMajor_ID         := 0;
  P^.hdMinor_ID         := SubGroupNo;
  P^.hdHeading          := Trim( Heading );
  Insert( P );
end;

procedure tNew_Custom_Headings_List.UpdateCRC(var CRC: LongWord);
var
  i: Integer;
begin
  for i := 0 to Pred( ItemCount ) do
    BKCRC.UpdateCRC( Custom_Heading_At( i )^, CRC );
end;

end.
