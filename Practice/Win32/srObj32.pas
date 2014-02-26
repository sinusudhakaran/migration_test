unit srObj32;

interface

uses
  SYDEFS,
  IOSTREAM,
  SYsrIO,
  TOKENS,
  SysUtils,
  LogUtil,
  BKDbExcept;

type
  //----------------------------------------------------------------------------
  TTPR_Supplier_Detail = class
  private
    srFields : tTPR_Supplier_Detail_Rec;
  protected
    function GetAs_pRec: pTPR_Supplier_Detail_Rec;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    property As_pRec: pTPR_Supplier_Detail_Rec read GetAs_pRec;
  end;

//------------------------------------------------------------------------------
implementation

const
  UnitName = 'srObj32';
  DebugMe : boolean = false;

//------------------------------------------------------------------------------
constructor TTPR_Supplier_Detail.Create;
begin
  inherited;

  FillChar(srFields, SizeOf(srFields), 0);
  With srFields do
  Begin
    srRecord_Type := tkBegin_TPR_Supplier_Detail;
    srEOR         := tkEnd_TPR_Supplier_Detail;
  end;
end;

//------------------------------------------------------------------------------
destructor TTPR_Supplier_Detail.Destroy;
begin
  Free_TPR_Supplier_Detail_Rec_Dynamic_Fields(srFields);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TTPR_Supplier_Detail.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TTPR_Payee_Detail.SaveToFile';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Write_TPR_Supplier_Detail_Rec(srFields, S);
  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
procedure TTPR_Supplier_Detail.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TTPR_Payee_Detail.LoadFromFile';
var
  Token: byte;
  Msg: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := tkBegin_TPR_Supplier_Detail;
  While (Token <> tkEndSection) do
  Begin
    if (Token <> tkBegin_TPR_Supplier_Detail) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    Read_TPR_Supplier_Detail_Rec(srFields, S);

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
function TTPR_Supplier_Detail.GetAs_pRec: pTPR_Supplier_Detail_Rec;
begin
  result := @srFields;
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UnitName);

end.

