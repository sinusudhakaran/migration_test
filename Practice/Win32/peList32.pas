unit peList32;

interface

uses
  ECollect, SYDEFS, IOSTREAM, AuditMgr;

type
  //Log for provisional transaction data entry at the system DB level.
  //This records who entered the transactions, the date/time, and the first and
  //last transaction LRN numbers. The username and date/time are then added to
  //the audit information when the transactions are merged into the Client file.
  TSystem_Provisional_Entries_Log = class(TExtdCollection)
  protected
    procedure FreeItem(Item: Pointer); override;
  public
    function Provisional_Entry_At(Index: integer): pProvisional_Entries_Log_Rec;
    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);    
 end;

implementation

uses
  SYPEIO, TOKENS, MALLOC, sysutils, globals, bkdbExcept,
  bk5except, SYAUDIT, bkDateUtils, LogUtil;

const
  UNIT_NAME = 'peList32';

{ TSystem_Provisional_Entries_Log }

procedure TSystem_Provisional_Entries_Log.FreeItem(Item: Pointer);
begin
  SYPEIO.Free_Provisional_Entries_Log_Rec_Dynamic_Fields(pProvisional_Entries_Log_Rec(Item)^);
  SafeFreeMem(Item, Provisional_Entries_Log_Rec_Size);
end;

procedure TSystem_Provisional_Entries_Log.LoadFromFile(var S: TIOStream);
const
  THIS_METHOD_NAME = 'TSystem_Provisional_Entries_Log.LoadFromFile';
var
  Token : Byte;
  PELR    : pProvisional_Entries_Log_Rec;
  msg   : string;
begin
  Token := S.ReadToken;
  while (Token <> tkEndSection) do begin
    case Token of
      tkBeginSystem_Provisional_Entries_Log:
        begin
          PELR := New_Provisional_Entries_Log_Rec;
          Read_Provisional_Entries_Log_Rec(PELR^, S);
          Insert(PELR);
        end;
    else
      begin { Should never happen }
        Msg := Format('%s : Unknown Token %d', [THIS_METHOD_NAME, Token]);
        LogUtil.LogMsg(lmError, UNIT_NAME, Msg );
        raise ETokenException.CreateFmt('%s - %s', [UNIT_NAME, Msg]);
      end;
    end; { of Case }
    Token := S.ReadToken;
  end;
end;

function TSystem_Provisional_Entries_Log.Provisional_Entry_At(
  Index: integer): pProvisional_Entries_Log_Rec;
begin
  Result := At(Index);
end;

procedure TSystem_Provisional_Entries_Log.SaveToFile(var S: TIOStream);
var
  i: integer;
begin
  S.WriteToken(tkBeginSystem_Provisional_Entries_Log);
  for i := 0 to Pred(ItemCount) do
    SYPEIO.Write_Provisional_Entries_Log_Rec(Provisional_Entry_At(i)^, S);
  S.WriteToken(tkEndSection);
end;

end.
