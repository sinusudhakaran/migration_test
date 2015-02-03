unit msObj32;

//------------------------------------------------------------------------------
interface

uses
  BKDEFS,
  IOSTREAM,
  BKmsIO,
  TOKENS,
  SysUtils,
  LogUtil,
  BKDbExcept;

type
  TMem_Scan_Command = class
  public
    msFields: tMem_Scan_Command_Rec;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  GetAs_pRec: pMem_Scan_Command_Rec;
    property  As_pRec: pMem_Scan_Command_Rec read GetAs_pRec;
  end;

Const
  // Commands
  MEM_SCAN_COMMAND_MIN = 1;
  MEM_SCAN_COMMAND_CLEAR_COMMANDS = 1;
  MEM_SCAN_COMMAND_ADD_ACCOUNT_UNSCANNED = 2;
  MEM_SCAN_COMMAND_ADD_SELECTED_ACCOUNTS_UNSCANNED = 3;
  MEM_SCAN_COMMAND_ADD_ALL_ACCOUNTS_UNSCANNED = 4;
  MEM_SCAN_COMMAND_DEL_ACCOUNT_MEMS = 5;
  MEM_SCAN_COMMAND_DEL_SELECTED_ACCOUNTS_MEMS = 6;
  MEM_SCAN_COMMAND_DEL_ALL_ACCOUNTS_MEMS = 7;
  MEM_SCAN_COMMAND_UPDATE_CANDIDATE_MEMS = 8;
  MEM_SCAN_COMMAND_MAX = 8;

  // Sections - common
  MEM_SCAN_SECTION_START = 0;
  MEM_SCAN_SECTION_PROCESS = 1;
  MEM_SCAN_SECTION_ERROR = 2;

  // Sections Delete Account
  MEM_SCAN_SECTION_DELACC_UNSCANNED = 10;
  MEM_SCAN_SECTION_DELACC_CANDIDATE = 11;
  MEM_SCAN_SECTION_DELACC_RECOMMENDED = 12;

//------------------------------------------------------------------------------
implementation

const
   UnitName = 'utObj32';
   DebugMe: boolean = false;

//------------------------------------------------------------------------------
// TUnscanned_Transaction
//------------------------------------------------------------------------------
constructor TMem_Scan_Command.Create;
begin
  inherited;

  FillChar(msFields, SizeOf(msFields), 0);
  with msFields do
  begin
    msRecord_Type := tkBegin_Mem_Scan_Command;
    msEOR := tkEnd_Mem_Scan_Command;
  end;
end;

//------------------------------------------------------------------------------
destructor TMem_Scan_Command.Destroy;
begin
  Free_Mem_Scan_Command_Rec_Dynamic_Fields(msFields);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TMem_Scan_Command.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TUnscanned_Transaction.SaveToFile';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Write_Mem_Scan_Command_Rec(msFields, S);
  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
procedure TMem_Scan_Command.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TUnscanned_Transaction.LoadFromFile';
var
  Token: byte;
  Msg: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := tkBegin_Mem_Scan_Command;
  While (Token <> tkEndSection) do
  Begin
    if (Token <> tkBegin_Mem_Scan_Command) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    Read_Mem_Scan_Command_Rec(msFields, S);

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
function TMem_Scan_Command.GetAs_pRec: pMem_Scan_Command_Rec;
begin
  result := @msFields;
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UnitName);

end.
