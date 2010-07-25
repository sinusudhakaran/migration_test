unit BUDOBJ32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Budget Object
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  classes, BKDEFS, bdList32, IOSTREAM;

Type
   tBudget = class
  private
  //  FIsBasic: Boolean;
   // procedure SetIsBasic(const Value: Boolean);
  public
      buFields : tBudget_Header_Rec;
      buDetail : TBudget_Detail_List;
      CONSTRUCTOR    Create;
      DESTRUCTOR     Destroy; override;
      PROCEDURE      SaveToFile( Var S : TIOStream );
      PROCEDURE      LoadFromFile( Var S : TIOStream );
      procedure      UpdateCRC(var CRC : LongWord);
      //property IsBasic: Boolean read FIsBasic write SetIsBasic;
   end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
uses
   BKBUIO, TOKENS, LogUtil, SysUtils, bkdbExcept,
   bkcrc;

const
   UnitName = 'BUDOBJ32';
   DebugMe : Boolean = FALSE;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor tBudget.Create;
const
   ThisMethodName = 'TBudget.Create';
var
   Msg : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;

   FillChar( buFields, Sizeof( buFields ), 0 );
   With buFields do
   Begin
      buRecord_Type := tkBegin_Budget_Header;
      buEOR := tkEnd_Budget_Header;
   end;

   buDetail := NIL;

   buDetail := TBudget_Detail_List.Create;
   If not Assigned( buDetail ) then
   Begin
      Msg := Format( '%s : Unable to Allocate buDetail',[ThisMethodName]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DESTRUCTOR tBudget.Destroy;
const
   ThisMethodName = 'TBudget.Destroy';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   If buDetail<>NIL then
   Begin
      buDetail.Free;
      buDetail := NIL;
   end;

   BKBUIO.Free_Budget_Header_Rec_Dynamic_Fields( buFields);
   Inherited Destroy;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TBudget.SaveToFile( Var S : TIOStream );
const
   ThisMethodName = 'TBudget.SaveToFile';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Write_Budget_Header_Rec ( buFields, S );
   buDetail.SaveToFile( S );
   S.WriteToken( tkEndSection );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TBudget.LoadFromFile( Var S : TIOStream );
const
  ThisMethodName = 'TBudget.LoadFromFile';
Var
   Token : Byte;
   Msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Token := tkBegin_Budget_Header;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Budget_Header   : Read_Budget_Header_Rec ( buFields, S );
         tkBeginBudget           : buDetail.LoadFromFile( S );
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
procedure tBudget.UpdateCRC(var CRC: LongWord);
begin
   bkCRC.UpdateCRC( buFields, CRC);
   buDetail.UpdateCRC( CRC);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

initialization
  DebugMe := DebugUnit(UnitName);
end.
