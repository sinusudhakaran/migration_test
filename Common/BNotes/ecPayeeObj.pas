unit ecPayeeObj;

interface

uses
  Classes,
  ECDefs,
  IOStream,
  ECollect;

type
   TECPayeeLinesList = class(TExtdCollection)
   protected
     procedure FreeItem( Item : Pointer ); override;
   public
     function  PayeeLine_At( Index : LongInt ): pPayee_Line_Rec;
     procedure SaveToFile( Var S : TIOStream );
     procedure LoadFromFile( Var S : TIOStream );
     procedure UpdateCRC(var CRC : Longword);
     procedure CheckIntegrity;
   end;

   TECPayee = class
     pdFields : TPayee_Detail_Rec;
     pdLines  : TECPayeeLinesList;

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

   TECPayee_List = class(TExtdSortedCollection)
      constructor Create;
      function Compare( Item1, Item2 : Pointer ) : integer; override;
   protected
      procedure FreeItem( Item : Pointer ); override;
   public
      function  Payee_At( Index : LongInt ): TECPayee;
      function  Find_Payee_Number( CONST ANumber: LongInt ): TECPayee;
      function  Find_Payee_Name( CONST AName: String ): TECPayee;
      function  Search_Payee_Name( CONST AName : ShortString ): TECPayee;
      function  Get_New_Payee_Number: LongInt;

      procedure SaveToFile( Var S : TIOStream );
      procedure LoadFromFile( Var S : TIOStream );

      procedure UpdateCRC(var CRC : Longword);
      procedure CheckIntegrity;
   end;

implementation

uses
  Malloc,
  SysUtils,
  StStrS,
  BKDbExcept,
  ECCRC,
  ECpdIO,
  ECPLIO,
  ECTokens;

const
  UnitName = 'ecPayeeObj';

{ TECPayeeLinesList }

procedure TECPayeeLinesList.CheckIntegrity;
var
  i : Integer;
begin
  for i := First to Last do
    with PayeeLine_At(i)^ do;
end;

procedure TECPayeeLinesList.FreeItem(Item: Pointer);
begin
  if ECPLIO.IsAPayee_Line_Rec( Item ) then begin
    ECPLIO.Free_Payee_Line_Rec_Dynamic_Fields( pPayee_Line_Rec( Item)^ );
    SafeFreeMem( Item, Payee_Line_Rec_Size );
  end;
end;

procedure TECPayeeLinesList.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TECPayeeLinesList.LoadFromFile';
var
  Token    : Byte;
  PL       : pPayee_Line_Rec;
  Msg      : String;
begin
   Token := S.ReadToken;
   while ( Token <> tkEndSection ) do
   begin
      case Token of
         tkBegin_Payee_Line :
           begin
              PL := New_Payee_Line_Rec;
              ECPLIO.Read_Payee_Line_Rec(PL^, S);
              Insert(PL);
           end;
      else
         begin { Should never happen }
           Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
           raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   end;
end;

function TECPayeeLinesList.PayeeLine_At(Index: Integer): pPayee_Line_Rec;
var
  P : Pointer;
begin
  Result := nil;
  P := At(Index);
  if (ECPLIO.IsAPayee_Line_Rec(P)) then
    Result := P;
end;

procedure TECPayeeLinesList.SaveToFile(var S: TIOStream);
var
  i : Integer;
begin
  S.WriteToken(tkBeginPayeeLinesList);
  for i := First To Last do
    ECPLIO.Write_Payee_Line_Rec(PayeeLine_At(i)^, S);
  S.WriteToken(tkEndSection);
end;

procedure TECPayeeLinesList.UpdateCRC(var CRC: Longword);
var
  i : Integer;
begin
  for i := First to Last do
    ECCRC.UpdateCRC(PayeeLine_At(i)^, CRC)
end;

{ TECPayee }

constructor TECPayee.Create;
begin
  inherited Create;

  FillChar( pdFields, Sizeof( pdFields ), 0 );
  with pdFields do
  begin
    pdRecord_Type := tkBegin_Payee_Detail;
    pdEOR := tkEnd_Payee_Detail;
  end;

  pdLines := TECPayeeLinesList.Create;
end;

destructor TECPayee.Destroy;
begin
  pdLines.Free;
  Free_Payee_Detail_Rec_Dynamic_Fields(pdFields);
  inherited Destroy;
end;

function TECPayee.FirstLine: pPayee_Line_Rec;
begin
  if pdLines.ItemCount > 0 then
    result := pdLines.PayeeLine_At(0)
  else
    result := nil;
end;

function TECPayee.GetName: ShortString;
begin
  Result := pdFields.pdName;
end;

function TECPayee.IsDissected: boolean;
begin
  result := pdLines.ItemCount > 1;
end;

procedure TECPayee.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TECPayee.LoadFromFile';
var
  Token    : Byte;
  msg      : string;
begin
   Token := tkBegin_Payee_Detail;
   repeat
      case Token of
         tkBegin_Payee_Detail :
           ECPDIO.Read_Payee_Detail_Rec(pdFields, S);
         tkBeginPayeeLinesList :
           pdLines.LoadFromFile(S);
      else
         begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
            raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   until Token = tkEndSection;
end;

function TECPayee.pdLinesCount: integer;
begin
  result := pdLines.ItemCount;
end;

procedure TECPayee.SaveToFile(var S: TIOStream);
begin
  ECPDIO.Write_Payee_Detail_Rec(pdFields, S);
  pdLines.SaveToFile(S);
  S.WriteToken(tkEndSection);
end;

procedure TECPayee.UpdateCRC(var CRC: Longword);
begin
  ECCRC.UpdateCRC(pdFields, CRC);
  pdLines.UpdateCRC(CRC);
end;

{ TECPayee_List }

procedure TECPayee_List.CheckIntegrity;
var
  LastCode : String[40];
  i : Integer;
  APayee : TECPayee;
begin
  LastCode := '';
  for i := First to Last do
  begin
    APayee := Payee_At(i);
    if (APayee.pdName < LastCode) then
      Raise Exception.CreateFmt('Payee List Sequence : %d', [i]);
    APayee.pdLines.CheckIntegrity;
    LastCode := APayee.pdName;
  end;
end;

function TECPayee_List.Compare(Item1, Item2: Pointer): integer;
begin
  Result := StStrS.CompStringS(TECPayee(Item1).pdName,TECPayee(Item2).pdName);
end;

constructor TECPayee_List.Create;
begin
  inherited;
end;

function TECPayee_List.Find_Payee_Name(const AName: String): TECPayee;
var
  i : Integer;
  APayee : TECPayee;
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

function TECPayee_List.Find_Payee_Number(
  const ANumber: Integer): TECPayee;
var
  i : Integer;
  APayee : TECPayee;
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

procedure TECPayee_List.FreeItem(Item: Pointer);
begin
  TECPayee(Item).Free;
end;

function TECPayee_List.Get_New_Payee_Number: LongInt;
var
  i : Integer;
begin
  Result := -1;
  for i := 0 to ItemCount - 1 do
  begin
    if (Payee_At(i).pdNumber > Result) then
      Result := Payee_At(i).pdNumber;
  end;
  if (Result <> -1) then
    Result := Result + 1;
end;

procedure TECPayee_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TECPayee_List.LoadFromFile';
var
  Token    : Byte;
  P        : TECPayee;
  msg      : string;
begin
   Token := S.ReadToken;
   while ( Token <> tkEndSection ) do
   begin
      case Token of
         tkBegin_Payee_Detail :
           begin
              P := TECPayee.Create;
              if not Assigned( P ) then
              begin
                 Msg := Format( '%s : Unable to allocate P',[ThisMethodName]);
                 raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
              end;
              P.LoadFromFile( S );
              Insert( P );
           end;
      else
         begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
            raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   end;
end;

function TECPayee_List.Payee_At(Index: Integer): TECPayee;
begin
  Result := At(Index);
end;

procedure TECPayee_List.SaveToFile(var S: TIOStream);
var
  i : Integer;
begin
   S.WriteToken( tkBeginPayeesList );
   for i := First to Last do
     Payee_At(i).SaveToFile(S);
   S.WriteToken( tkEndSection );
end;

function TECPayee_List.Search_Payee_Name(
  const AName: ShortString): TECPayee;
begin
  //Not used. See pyList32.Search_Payee_Name.
  Result := nil;
end;

procedure TECPayee_List.UpdateCRC(var CRC: Longword);
var
  i : integer;
begin
  for i := First to Last do
    Payee_At(i).UpdateCRC(CRC);
end;

end.
