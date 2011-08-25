unit chList32;
// Chart List
interface
uses
   Classes, bkdefs, iostream, ECollect, AuditMgr;

type

   TChartBase = class (TExtdSortedCollection)
   private
      function CompareCode(Code1, Code2: string): integer; virtual;
      function GetCode(Item: pointer): ShortString; virtual;
   protected
   public
      function Account_At( Index : LongInt ): pAccount_Rec;
      function Compare( Item1, Item2 : pointer ) : integer; override;
      function FindCode( ACode : String ): pAccount_Rec; virtual;
      function SearchForCode( ACode : String ): LongInt;
   end;

   TAltChart = class (TChartBase)
      function GetCode(Item: pointer): ShortString; override;
   protected
      procedure  FreeItem( Item : Pointer ); override;
   end;

   TChart = class( TChartBase )
    private
      FAccumulatorPeriods: integer;
      FAltChart: TAltChart;
      FAuditMgr: TClientAuditManager;
      FSorting: boolean;
      procedure SetAccumulatorPeriods(const Value: integer);
      procedure   CheckLinkedAccounts;
      procedure   ResortAltCodes;
      function FindRecordID( ARecordID : integer ):  pAccount_Rec;
      procedure SetSorting(const Value: boolean);
    protected
      procedure   FreeItem( Item : Pointer ); override;
    public
      constructor Create(AAuditMgr: TClientAuditManager);
      destructor  Destroy; override;
      function    SearchClosestCode( ACode : String ): pAccount_Rec;
      function    FindNextCode( ACode : String; PostingOnly: Boolean = True ): pAccount_Rec;
      function    GuessNextCode( ACode: String): pAccount_Rec;

      function    CodeIsThere( ACode : String ): Boolean;
      function    CanCodeTo ( ACode : String; WithAtlCode: Boolean = False ): Boolean;
      function    MatchAltCode(ACode: string): string;
      function    CanCodeTo_NumericSearch( ACode : String; var FoundCode: string ): Boolean;
      function    CanPressEnterNow (var ACode : ShortString; NoAtlCode: Boolean = False): Boolean;
      function    FindDesc( ACode : String ): String;
      function    GSTClass( ACode : String ): Byte;
      function    EnterQuantity( ACode : String ): Boolean;
      function    AddMaskCharToCode( Code, Mask : String; Var MaskChar : Char ): Boolean;
      function    UseMinusAsLookup : Boolean;
      function    MaxCodeLength : Integer;
      function    HasGSTClasses : Boolean;

      procedure Insert( Item : Pointer ); override;

      procedure   SaveToFile( Var S : TIOStream );
      procedure   LoadFromFile( Var S : TIOStream );

      function    GetCurrentCRC : LongWord;
      procedure   UpdateCRC(var CRC : LongWord);

      function    AllowLowerCase : boolean;
      procedure   RefreshDependencies;

      procedure DoAudit(AAuditType: TAuditType; AChartCopy: TChart;
                        AParentID: integer; var AAuditTable: TAuditTable);
      procedure SetAuditInfo(P1, P2: pAccount_Rec; AParentID: integer;
                             var AAuditInfo: TAuditInfo);

      function FindCode( ACode : String ): pAccount_Rec; override;

      property AccumulatorPeriods : integer read FAccumulatorPeriods write SetAccumulatorPeriods;
      property Sorting: boolean read FSorting write SetSorting;
   end;

   TCustomSortChart = class(TChart)
   private
      FCopiedChart: Boolean;
      function    CompareCode(Code1, Code2: string): integer; override;
   public
      destructor Destroy; override;
      procedure CopyChart(aChart: TChart);
   end;


//******************************************************************************
implementation
uses
   bkchio,
   tokens,
   LogUtil,
   malloc,
   moneydef,
   sysutils,
   StStrS,
   bkcrc,
   bkconst,
   bkdbExcept,
   GenUtils,
   BKAudit;

const
   UnitName = 'CHLIST32';
   DebugMe : Boolean = FALSE;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TChart.Create(AAuditMgr: TClientAuditManager);
const
   ThisMethodName = 'TChart.Create';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   FAuditMgr := AAuditMgr;
   Duplicates := false;
   FAltChart := TAltChart.Create;
   FAltChart.Duplicates := True;
   FSorting := False;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

destructor TChart.Destroy;
begin
  FAltChart.Free;
  inherited;
end;

procedure TChart.DoAudit(AAuditType: TAuditType; AChartCopy: TChart;
  AParentID: integer; var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: pAccount_Rec;
  AuditInfo: TAuditInfo;
  ProvDateStr: string;
begin
  AuditInfo.AuditType := arChartOfAccounts;
  AuditInfo.AuditUser := FAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_Account;
  //Adds, changes
  for i := 0 to Pred(ItemCount) do begin
    P1 := Items[i];
    P2 := nil;
    if Assigned(AChartCopy) then
      P2 := AChartCopy.FindRecordID(P1.chAudit_Record_ID);
    AuditInfo.AuditRecord := New_Account_Rec;
    try
      SetAuditInfo(P1, P2, AParentID, AuditInfo);
      if AuditInfo.AuditAction in [aaAdd, aaChange] then
        AAuditTable.AddAuditRec(AuditInfo);
    finally
      Dispose(AuditInfo.AuditRecord);
    end;
  end;
  //Deletes
  if Assigned(AChartCopy) then begin //Sub list - may not be assigned
    for i := 0 to AChartCopy.ItemCount - 1 do begin
      P2 := AChartCopy.Items[i];
      P1 := FindRecordID(P2.chAudit_Record_ID);
      AuditInfo.AuditRecord := New_Account_Rec;
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

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChartBase.Compare( Item1, Item2 : pointer ) : integer;
begin
  result := CompareCode(GetCode(Item1), GetCode(Item2));
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChartBase.CompareCode(Code1, Code2: string): integer;
begin
  Result := STStrS.CompStringS(Code1, Code2);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChartBase.GetCode(Item: pointer): ShortString;
begin
   result := pAccount_Rec(Item).chAccount_Code;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TChart.FreeItem( Item : Pointer );
const
   ThisMethodName = 'TChart.FreeItem';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if BKCHIO.IsAAccount_Rec( Item ) then begin
      BKCHIO.Free_Account_Rec_Dynamic_Fields( pAccount_Rec( Item)^ );
      SafeFreeMem( Item, Account_Rec_Size );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChartBase.Account_At( Index : Longint ) : pAccount_Rec;
const
   ThisMethodName = 'TChart.Account_At';
Var
   P   : Pointer;
Begin
   Account_At := nil;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   P := At( Index );
   if BKCHIO.IsAAccount_Rec( P ) then
      Account_At := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TChart.SaveToFile( Var S : TIOStream );
const
   ThisMethodName = 'TChart.SaveToFile';
Var
   i   : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   S.WriteToken( tkBeginChart );
   For i := 0 to Pred( ITemCount ) do
     BKCHIO.Write_Account_Rec( Account_At( i )^, S );

   S.WriteToken( tkEndSection );
   If DebugMe then LogUtil.LogMsg(lmDebug, UnitName, Format( '%d accounts were saved.', [ ItemCount ] ) );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TChart.LoadFromFile( Var S : TIOStream );
const
   ThisMethodName = 'TChart.LoadFromFile';
Var
   Token       : Byte;
   pCH         : pAccount_Rec;
   Msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do Begin
      Case Token of
         tkBegin_Account :
            Begin
               pCh := New_Account_Rec;
               Read_Account_Rec ( pCH^, S );
               if Self.FindCode(pCh^.chAccount_Code) = nil then
                 inherited Insert( pCH )
               else begin
                 Msg := Format( 'Duplicate account code in chart: %s', [pCh^.chAccount_Code] );
                 LogUtil.LogMsg(lmError,UnitName, Msg );
               end;
            end;
         else
         begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ThisMethodName, Token] );
            LogUtil.LogMsg(lmError,UnitName, Msg );
            raise ETokenException.CreateFmt( '%s - %s', [UnitName, Msg] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   end;
   ResortAltCodes;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChartBase.FindCode( ACode : String ): pAccount_Rec;
const
   ThisMethodName = 'TChart.FindCode';
var
  L, H, I, C: Integer;
  pCh       : pAccount_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                                       Format( ' Called with %s', [ACode] ) );
  result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then begin
     {no items in list}
     if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' No Items in List' );
     Exit;
  end;
  repeat
    I := (L + H) shr 1;
    pCh := pAccount_Rec(At(i));
    C := CompareCode(ACode, getCode(pCh));
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then begin
     result := pCh;
     if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                             Format( '%s Found in List', [ ACode ] ) );
     Exit;
  end;
  if DebugMe then
     LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                          Format( '%s Not Found in List', [ ACode ] ) );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChart.CanCodeTo_NumericSearch( ACode : String; var FoundCode: string ): Boolean;
const
   ThisMethodName = 'TChart.FindCodeNumericSearch';
var
  L, H, I, C, j : Integer;
  pCh           : pAccount_Rec;
  TestCode      : string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                                       Format( ' Called with %s', [ACode] ) );
  result := false;
  FoundCode := '';
  L := 0;
  H := ItemCount - 1;
  if L>H then begin
     {no items in list}
     if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' No Items in List' );
     Exit;
  end;
  repeat
    I := (L + H) shr 1;
    pCh := pAccount_Rec(At(i));
    // Strip non-numeric
    TestCode := GetCode(pCh);
    j := 1;
    while (j < Length(TestCode)) do
      if not (TestCode[j] in ['0'..'9']) then
        System.Delete(TestCode, j, 1)
      else
        Inc(j);
    C := CompareCode(ACode, TestCode);
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then begin
     if pCh^.chPosting_Allowed then
     begin
       result := true;
       FoundCode := pCh^.chAccount_Code;
     end;
     if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                             Format( '%s Found in List', [ ACode ] ) );
     Exit;
  end;
  if DebugMe then
     LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                          Format( '%s Not Found in List', [ ACode ] ) );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChart.SearchClosestCode( ACode : String ): pAccount_Rec;
//Given a code, find this code or the one after it
const
   ThisMethodName = 'TChart.SearchClosestCode';
var
  L, H, I, C: Integer;
  pCh       : pAccount_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                                       Format( ' Called with %s', [ACode] ) );
  result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then begin
     {no items in list}
     if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' No Items in List' );
     Exit;
  end;
  repeat
    I := (L + H) shr 1;
    pCh := pAccount_Rec(At(i));
    C := CompareCode(ACode, GetCode(pCh));
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);

  if c=0 then begin
    result := pCh;  {found it}
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                           Format( '%s Found in List', [ ACode ] ) );
    Exit;
  end
  else begin  {not found, find closest .. this will be the one we are on, or the next one}
     if length(ACode) > 0 then begin
       c := CompareCode(ACode, Copy(GetCode(pCh),1,length(ACode)));
       if c = 0 then begin
         result := pCh;
         if DebugMe then
            LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                                 Format( '%s Found Closest in List', [ ACode ] ) );
         Exit;
       end
       else begin
         inc(i);
         if I < ItemCount then begin
           pCh := pAccount_Rec(At(i));
           result := pCh;
           if DebugMe then
             LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                                  Format( '%s Found Next Closest in List', [ ACode ] ) );
           Exit;
         end;
       end;
     end;
  end;
  if DebugMe then
     LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                          Format( '%s Closest not Found in List', [ ACode ] ) );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChart.FindNextCode( ACode : String; PostingOnly: Boolean = True ): pAccount_Rec;
//Given a code, find the one after it
const
   ThisMethodName = 'TChart.FindNextCode';
var
  L, H, I, C: Integer;
  pCh       : pAccount_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                                       Format( ' Called with %s', [ACode] ) );
  result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then begin
     {no items in list}
     if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' No Items in List' );
     Exit;
  end;
  // If blank code then get first/first non-posting
  if ACode = '' then
  begin
    i := 0;
    repeat
      pCh := pAccount_Rec(At(i));
      if not PostingOnly then // Get first
      begin                                      
        Result := pCh;
        Exit;
      end;
      if pCh^.chPosting_Allowed then // Got a posting code
      begin
        result := pCh;
        if DebugMe then
          LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + Format( '%s Found Next in List', [ ACode ] ) );
        Exit;
      end;
      Inc(i);
    until i > H;
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + Format( '%s Not Found in List', [ ACode ] ) );
    Exit;
  end;

  // If non-blank code then get next in list
  repeat
    I := (L + H) shr 1;
    pCh := pAccount_Rec(At(i));
    C := CompareCode(ACode, getCode(pCh));
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);

  if c=0 then begin
    inc(i);
    while I < ItemCount do begin
      pCh := pAccount_Rec(At(i));
      if (not PostingOnly) or pCh^.chPosting_Allowed then
      begin
        result := pCh;  {found it}
        if DebugMe then
          LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + Format( '%s Found Next in List', [ ACode ] ) );
        Exit;
      end;
      inc(i);
    end;
  end;
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + Format( '%s Not Found in List', [ ACode ] ) );
end;

function TChart.FindRecordID(ARecordID: integer): pAccount_Rec;
var
  i : integer;
begin
  Result := nil;
  if (ItemCount = 0) then Exit;

  for i := 0 to Pred(ItemCount) do
    if Account_At(i).chAudit_Record_ID = ARecordID then begin
      Result := Account_At(i);
      Exit;
    end;  
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Find this Code, or if it doesn't exist, find the closest match in the list
function TChart.GuessNextCode( ACode : String ): pAccount_Rec;
const
  ThisMethodName = 'TChart.GuessNextCode';
var
  I, J, Match, BestMatch: Integer;
  pCh       : pAccount_Rec;
  MCode: string;
  MCodeInt, CodeInt: Integer;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                                       Format( ' Called with %s', [ACode] ) );
  result := FindCode(ACode);
  if Assigned(Result) then
  begin
    if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + Format( ' %s Found in List', [ ACode ] ) );
    Exit;
  end;
  if ItemCount = 0 then begin
     {no items in list}
     if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' No Items in List' );
     Exit;
  end;
  // First do a numeric match - is there a code after this one numerically
  CodeInt := StrToIntDef(ACode, -1);
  if CodeInt > -1 then
  begin
    BestMatch := 999999;
    for I := 0 to Pred(ItemCount) do
    begin
      pCh := pAccount_Rec(At(i));
      MCodeInt := StrToIntDef(pCh^.chAccount_Code, -1);
      if MCodeInt > -1 then
      begin
        if (MCodeInt > CodeInt) and ((MCodeInt - CodeInt) < BestMatch) then
        begin
          BestMatch := MCodeInt - CodeInt;
          Result := pCh;
        end;
      end;
    end;
  end;
  // no result yet - try character matching
  if not Assigned(result) then
  begin
    Match := 0;
    BestMatch := 0;
    for I := 0 to Pred(ItemCount) do
    begin
      pCh := pAccount_Rec(At(i));
      MCode := pCh^.chAccount_Code;
      // how many characters match
      for j := 1 to Length(MCode) do
        if (Length(ACode) >= j) and (MCode[j] = ACode[j]) then
          Inc(match)
        else
          Break;
      if Match > BestMatch then
      begin
        BestMatch := Match;
        result := pCh;
      end;
      Match := 0;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChartBase.SearchForCode( ACode : String ): LongInt;
const
  ThisMethodName = 'TChart.SearchForCode';
var
  L, H, I, C: Integer;
  pCh       : pAccount_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                                       Format( ' Called with %s', [ACode] ) );
  result := -1;
  L := 0;
  H := ItemCount - 1;
  if L>H then begin
     {no items in list}
     if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' No Items in List' );
     Exit;
  end;
  repeat
    I := (L + H) shr 1;
    pCh := pAccount_Rec(At(i));
    C := CompareCode(ACode, GetCode(pCh));
    if C > 0 then
       L := I + 1
    else H := I - 1;
  until (c=0) or (L>H);
  if c<>0 then
     i := -1;
  result := i;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChart.CodeIsThere( ACode : String ): Boolean;
Begin
   CodeIsThere := FindCode( ACode )<>NIL;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function TChart.CanCodeTo(ACode : String; WithAtlCode: Boolean = False): Boolean;
const
  ThisMethodName = 'TChart.CanCodeTo';
Var
   pCh : pAccount_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                                        Format( ' Called with %s', [ACode] ) );
   (* If there is no chart, then anything goes *)
   Result := True;
   If ItemCount = 0 then begin
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' No Items' );
      exit;
   end;

   Result := False;
   pCh := FindCode( ACode );
   If Assigned( pCH ) then begin
      Result := pCh^.chPosting_Allowed;
      Exit;
   end;
   // Still here...
   if WithAtlCode then begin
       pCh := FAltChart.FindCode(ACode);
       if Assigned( pCH ) then
         Result := pCh^.chPosting_Allowed;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function TChart.CanPressEnterNow (var ACode : ShortString; NoAtlCode: Boolean = False): Boolean;
const
  ThisMethodName = 'TChart.CanPressEnterNow';
Var
   pCh : pAccount_Rec;
   i : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
   Result := FALSE;

   i := SearchForCode(ACode);
   if i >=0 then begin
      If i < pred(ItemCount) then begin
         // Check if the the next one has the same start.
         if pos(Acode, GetCode(Items[i+1])) = 1 then
            exit;
      end;
      Result := Account_At(i).chPosting_Allowed;

      Exit; // Done
   end;

   if NoAtlCode then
      Exit;

   // Try the Alt code
   i := FAltChart.SearchForCode(ACode);
   if i >=0  then begin

      If i < Pred(FAltChart.ItemCount) then begin
         // If there are duplicate alternate codes then don't return a chart code
         if (CompareCode(Acode, FAltChart.GetCode(FAltChart.Items[i+1])) = 0) then
            Exit;
      end;
      Result := FAltChart.Account_At(i).chPosting_Allowed;
      if Result then
         ACode := GetCode(FAltChart.Items[i])
   end;

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChart.FindCode(ACode: String): pAccount_Rec;
begin
  Result := inherited FindCode(ACode);
  //Check for alternative code
  if Result = nil then begin
    Result := FAltChart.FindCode(ACode);
    if Result <> nil then
      Result := inherited FindCode(Result.chAccount_Code);
  end;
end;

function tChart.FindDesc( ACode : String ): String;
const
  ThisMethodName = 'TChart.FindDesc';
Var
   pCh : pAccount_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
   FindDesc := '';
   pCh := FindCode( ACode );
   If Assigned( pCH ) then FindDesc := pCh^.chAccount_Description;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function tChart.GSTClass( ACode : String ): Byte;
const
  ThisMethodName = 'TChart.GSTClass';
Var
   pCh : pAccount_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + 
                                        Format( ' Called with %s', [ACode] ) );
   GSTClass := 0;
   pCh := FindCode( ACode );
   If Assigned( pCH ) then GSTClass := pCh^.chGST_Class;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function TChart.EnterQuantity( ACode : String ): Boolean;
const
  ThisMethodName = 'TChart.EnterQuantity';
Var
   pCh : pAccount_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
                                        Format( ' Called with %s', [ACode] ) );
   EnterQuantity := FALSE;
   pCh := FindCode( ACode );
   If Assigned( pCH ) then
      EnterQuantity := pCh^.chEnter_Quantity;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function TChart.AddMaskCharToCode( Code, Mask : String; Var MaskChar : Char ): Boolean;
const
  ThisMethodName = 'TChart.AddMaskCharToCode';
Var
   TestNextKey    : Bk5CodeStr;
   ActualNextKey  : Bk5CodeStr;
   Len            : Byte;
   NewLen         : Byte;
   pCh            : PAccount_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + 
                                        Format( ' Called with %s', [Code] ) );
   AddMaskCharToCode := FALSE;
   If ItemCount = 0 then
      exit;

   Len := Length( Code );
   If ( Len < Length( Mask ) ) and
      ( Mask[ Len+1 ] <> '#' ) then
   Begin
      NewLen   := Len + 1;
      MaskChar := Mask[ NewLen ];

      TestNextKey    := Code + MaskChar;
      ActualNextKey  := TestNextKey;

      pCh := SearchClosestCode( TestNextKey );
      If not Assigned( pCh ) then
         exit;

      ActualNextKey   := pCh^.chAccount_Code;

      If ( Copy( ActualNextKey, 1, NewLen ) = TestNextKey ) then
         AddMaskCharToCode := TRUE;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function TChart.UseMinusAsLookup : Boolean;
Var i : LongInt;
const
  ThisMethodName = 'TChart.UseMinusAsLookup';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
   UseMinusAsLookup := TRUE;
   For i := 0 to Pred( ItemCount ) do With Account_At( i )^ do
      If Pos( '-', chAccount_Code )>0 then
         UseMinusAsLookup := FALSE;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function TChart.GetCurrentCRC: LongWord;
const
  ThisMethodName = 'TChart.GetCurrentCRC';
Var
   CRC         : LongWord;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
   CRC         := 0;
   ResortAltCodes;
   UpdateCRC( CRC);
   GetCurrentCRC := CRC;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TChart.UpdateCRC(var CRC: LongWord);
var
  I : Integer;
begin
   For I := 0 to Pred( itemCount ) do begin
      BKCRC.UpdateCRC( Account_At( i)^, CRC);
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TChart.AllowLowerCase: boolean;
const
  ThisMethodName = 'TChart.AllowLowerCase';
Var
   I  : LongInt;
   p  : Word;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
   result := false;
   For i := 0 to Pred( itemCount ) do With Account_At( I )^ do
   Begin
      For p := 1 to Length( chAccount_Code ) do
         If ( chAccount_Code[p] in [ 'a'..'z' ] ) then
         Begin
           result := true;
           exit;
         end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TChart.MatchAltCode(ACode: string): string;
var
  i, j: integer;
  Duplicate: boolean;
begin
  Result := ACode;
  Duplicate := False;
  i := FAltChart.SearchForCode(ACode);
  if i >= 0 then begin// Found one
    //Check for duplicates if not the last item
    if (i < FAltChart.ItemCount - 1) then
      if FAltChart.Compare(FAltChart.Account_At(i + 1), FAltChart.Account_At(i)) = 0 then
        Duplicate := True;

    if (FAltChart.Account_At(i).chPosting_Allowed) and (not Duplicate) then //Can use it
      Result := {Self}GetCode(FAltChart.Items[i]); // so do so
  end;    
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function  TChart.MaxCodeLength : Integer;
const
  ThisMethodName = 'TChart.MaxCodeLength';
Var
   I  : LongInt;
   MaxL, ThisL : Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   MaxL := 0;
   For i := 0 to Pred( itemCount ) do With Account_At( I )^ do
   Begin
      ThisL := Length( chAccount_Code );
      if ThisL > MaxL then MaxL := ThisL;
   end;
   Result := MaxL;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TChart.RefreshDependencies;
begin
   CheckLinkedAccounts;
   ResortAltCodes;
end;

procedure TChart.ResortAltCodes;
var I: integer;
begin
   fAltChart.FreeAll;
   for I := 0 to ItemCount - 1 do
      if Account_At(I).chAlternative_Code > '' then
         fAltChart.Insert(At( I ));

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function  TChart.HasGSTClasses : Boolean;
const
  ThisMethodName = 'TChart.HasGSTClasses';
Var
   I  : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Result := False;
   For i := 0 to Pred( itemCount ) do With Account_At( I )^ do
   Begin
      If chGST_Class > 0 then
      Begin
         Result := True;
         Break;
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ends' );
end;

procedure TChart.Insert(Item: Pointer);
begin
  if Assigned(FAuditMgr) and (not Sorting) then
    pAccount_Rec(Item).chAudit_Record_ID := FAuditMgr.NextAuditRecordID;

  inherited Insert(Item);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TChart.SetAccumulatorPeriods(const Value: integer);
var
   i : integer;
begin
   if Value <> FAccumulatorPeriods then begin
     for i := 0 to Pred( ItemCount) do begin
        DBR_SetLength( Account_At(i)^.chTemp_Amount, Value);
        DBR_SetLength( Account_At(i)^.chTemp_Base_Amount, Value);
        DBR_SetLength( Account_At(i)^.chTemp_Quantity, Value);
     end;
     FAccumulatorPeriods := Value;
   end;
end;

procedure TChart.SetAuditInfo(P1, P2: pAccount_Rec; AParentID: integer;
  var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditAction := aaNone;
  AAuditInfo.AuditParentID := AParentID;
  AAuditInfo.AuditOtherInfo := Format('%s=%s', ['RecordType','Chart of Accounts']) +
                               VALUES_DELIMITER +
                               Format('%s=%d', ['ParentID', AParentID]);
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.chAudit_Record_ID;
    AAuditInfo.AuditOtherInfo :=
      AAuditInfo.AuditOtherInfo + VALUES_DELIMITER +
      Format('%s=%s',[BKAuditNames.GetAuditFieldName(tkBegin_Account, 82), P2.chAccount_Code]);
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.chAudit_Record_ID;
    if Account_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.chAudit_Record_ID;
    P1.chAudit_Record_ID := AAuditInfo.AuditRecordID;
    BKCHIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_Account_Rec(P1, AAuditInfo.AuditRecord);
  end;
end;

procedure TChart.SetSorting(const Value: boolean);
begin
  FSorting := Value;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TChart.CheckLinkedAccounts;
//this procedure checks the linked accounts for each account in the chart
//invalid links are deleted
var
  i : integer;
  pAcct : pAccount_Rec;
  pLink : pAccount_Rec;
  pLink2 : pAccount_Rec;
begin
  //clear temp link
  for i := First to Last do
    Account_at(i)^.chTemp_Linked_To_From_SOH := '';

  //verify links, remove invalid ones
  for i := 0 to Pred( ItemCount) do begin
    pAcct := Account_At(i);

    case pAcct^.chAccount_Type of

      atOpeningStock : begin
        //make sure is linked to a closing stock account
        pLink := FindCode( pAcct^.chLinked_Account_CS);
        if not Assigned( pLink) then
          pAcct^.chLinked_Account_CS  := ''
        else
          if not (pLink.chAccount_Type = atClosingStock) then
            pAcct^.chLinked_Account_CS := '';
        //should never be linked to self
        pAcct^.chLinked_Account_OS := '';
      end;

      atClosingStock : begin
        //make sure is linked to a opening stock account
        pLink := FindCode( pAcct^.chLinked_Account_OS);
        if not Assigned( pLink) then
          pAcct^.chLinked_Account_OS  := ''
        else
          if not (pLink.chAccount_Type = atOpeningStock) then
            pAcct^.chLinked_Account_OS := '';
        //should never be linked to self
        pAcct^.chLinked_Account_CS := '';
      end;

      atStockOnHand : begin
        //check is linked to a closing stock account AND an opening stock
        pLink  := FindCode( pAcct^.chLinked_Account_CS);
        pLink2 := FindCode( pAcct^.chLinked_Account_OS);

        if Assigned( pLink) and Assigned( pLink2)
          and ( pLink.chAccount_Type  = atClosingStock)
          and ( pLink2.chAccount_Type = atOpeningStock) then
        begin
          //both accounts are linked correctly, just store temp link
          pLink^.chTemp_Linked_To_From_SOH  := pAcct^.chAccount_Code;
          pLink2^.chTemp_Linked_To_From_SOH := pAcct^.chAccount_Code;
        end
        else begin
          pAcct^.chLinked_Account_CS := '';
          pAcct^.chLinked_Account_OS := '';
        end;
      end;

      else begin
        //this account type should not have linked accounts, clear them
        pAcct^.chLinked_Account_OS  := '';
        pAcct^.chLinked_Account_CS  := '';
      end;
    end;

  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{ TCustomSortChart }

function TCustomSortChart.CompareCode(Code1, Code2: string): integer;
begin
  if UseXlonSort then
    //allow for comparing Xlon chart codes for reports only - should never
    //be used on the client file chart.
    Result := inherited CompareCode(FormatCodeForXlonSort(Code1), FormatCodeForXlonSort(Code2))
  else
    Result := inherited CompareCode(Code1, Code2);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TCustomSortChart.CopyChart(aChart: TChart);
var
  I: Integer;
begin
  FreeAll;
  //create copy by simply copying the points to the items so that the accounts
  //will be the same copy of the data

  //Set limit first, so array is only resized once
  Limit := aChart.ItemCount;
  for I := 0 to aChart.Last do
  begin
    inherited Insert(aChart.At(I));
  end;
  self.FAccumulatorPeriods := aChart.AccumulatorPeriods;
  FCopiedChart := true;
end;

destructor TCustomSortChart.Destroy;
begin
  if FCopiedChart then
    DeleteAll;
  inherited;
end;

{ TAltChart }

procedure TAltChart.FreeItem(Item: Pointer);
begin
   // Don't own any..
end;

function TAltChart.GetCode(Item: pointer): ShortString;
begin
    result := pAccount_Rec(Item).chAlternative_Code;
end;

initialization
   DebugMe := DebugUnit(UnitName);
end.

