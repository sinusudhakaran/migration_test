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
  ECollect;

type
   TPayeeLinesList = class(TExtdCollection)
   protected
     procedure FreeItem( Item : Pointer ); override;
   public
     function  PayeeLine_At( Index : LongInt ): pPayee_Line_Rec;
     procedure SaveToFile( Var S : TIOStream );
     procedure LoadFromFile( Var S : TIOStream );
     procedure UpdateCRC(var CRC : Longword);
     procedure CheckIntegrity;
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

   TPayee_List = class(TExtdSortedCollection)
      constructor Create;
      function Compare( Item1, Item2 : Pointer ) : integer; override;
   protected
      procedure FreeItem( Item : Pointer ); override;
   public
      function  Payee_At( Index : LongInt ): TPayee;
      function  Find_Payee_Number( CONST ANumber: LongInt ): TPayee;
      function  Find_Payee_Name( CONST AName: String ): TPayee;
      function  Search_Payee_Name( CONST AName : ShortString ): TPayee;
      function Guess_Next_Payee_Number(const ANumber: Integer): TPayee;      

      procedure SaveToFile( Var S : TIOStream );
      procedure LoadFromFile( Var S : TIOStream );

      procedure UpdateCRC(var CRC : Longword);
      procedure CheckIntegrity;
   end;

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
  Tokens;

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

function TPayee_List.Compare(Item1, Item2: Pointer): integer;
begin
  Result := StStrS.CompStringS(TPayee(Item1).pdName,TPayee(Item2).pdName);
end;

constructor TPayee_List.Create;
begin
  inherited;
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
              Insert( P );
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

procedure TPayeeLinesList.FreeItem(Item: Pointer);
begin
  if BKPLIO.IsAPayee_Line_Rec( Item ) then begin
    BKPLIO.Free_Payee_Line_Rec_Dynamic_Fields( pPayee_Line_Rec( Item)^ );
    SafeFreeMem( Item, Payee_Line_Rec_Size );
  end;
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

procedure TPayeeLinesList.UpdateCRC(var CRC: Longword);
var
  i : Integer;
begin
  for i := First to Last do
    BKCRC.UpdateCRC(PayeeLine_At(i)^, CRC)
end;

end.
