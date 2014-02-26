unit prObj32;

interface

uses
  BKDEFS,
  IOSTREAM,
  BKprIO,
  TOKENS,
  SysUtils,
  LogUtil,
  BKDbExcept;

type
  //----------------------------------------------------------------------------
  TTPR_Payee_Detail = class
  private
    prFields : tTPR_Payer_Detail_Rec;
  protected
    function GetAs_pRec: pTPR_Payer_Detail_Rec;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    property As_pRec: pTPR_Payer_Detail_Rec read GetAs_pRec;
  end;

//------------------------------------------------------------------------------
implementation

const
  UnitName = 'prObj32';
  DebugMe : boolean = false;

//------------------------------------------------------------------------------
constructor TTPR_Payee_Detail.Create;
begin
  inherited;

  FillChar(prFields, SizeOf(prFields), 0);
  With prFields do
  Begin
    prRecord_Type := tkBegin_TPR_Payer_Detail;
    prEOR         := tkEnd_TPR_Payer_Detail;
  end;
end;

//------------------------------------------------------------------------------
destructor TTPR_Payee_Detail.Destroy;
begin
  Free_TPR_Payer_Detail_Rec_Dynamic_Fields(prFields);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TTPR_Payee_Detail.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TTPR_Payee_Detail.SaveToFile';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Write_TPR_Payer_Detail_Rec(prFields, S);
  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
procedure TTPR_Payee_Detail.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TTPR_Payee_Detail.LoadFromFile';
var
  Token: byte;
  Msg: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := tkBegin_TPR_Payer_Detail;
  While (Token <> tkEndSection) do
  Begin
    if (Token <> tkBegin_TPR_Payer_Detail) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    Read_TPR_Payer_Detail_Rec(prFields, S);

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
function TTPR_Payee_Detail.GetAs_pRec: pTPR_Payer_Detail_Rec;
begin
  result := @prFields;
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UnitName);

end.
