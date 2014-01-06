unit ReportSettingObj;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// ReportSettings list object for windows report settings
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   ecollect, iostream, ladefs;

type
   TWindows_Report_Setting_List = class( TExtdSortedCollection )
      constructor Create; override;
      function    Compare( Item1, Item2 : pointer ) : integer; override;

    protected
      procedure   FreeItem( Item : Pointer ); override;

    public
      function    Windows_Report_Setting_At( Index : LongInt ): pWindows_Report_Setting_Rec;
      function    Find_Windows_Report_Setting( Report_Name : String ): pWindows_Report_Setting_Rec;
      procedure   SaveToFile( Var S : TIOStream );
      procedure   LoadFromFile( Var S : TIOStream );
   end;
//******************************************************************************
implementation
uses
   las7io, tokens, LogUtil, malloc, sysutils, StStrS, bkdbExcept,
   bk5Except;

const
   UnitName = 'REPORTSETTINGOBJ';
var
   DebugMe : boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TWindows_Report_Setting_List }
function TWindows_Report_Setting_List.Compare(Item1, Item2: pointer): integer;
begin
   Compare := StStrS.CompStringS( pWindows_Report_Setting_Rec(Item1)^.s7Report_Name, pWindows_Report_Setting_Rec(Item2)^.s7Report_Name );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TWindows_Report_Setting_List.Create;
const
   ThisMethodName = 'TWindows_Report_Setting_List.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TWindows_Report_Setting_List.Find_Windows_Report_Setting(Report_Name: String): pWindows_Report_Setting_Rec;
const
   ThisMethodName = 'TWindows_Report_Setting_List.Find_Windows_Report_Setting';
var
   i  : LongInt;
   P  : pWindows_Report_Setting_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
   Find_Windows_Report_Setting := nil;
   If ( ItemCount = 0 ) then begin
     if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' ItemCount = 0');
     exit;
   end;

   For i := 0 to Pred( itemCount ) do Begin
      P := Windows_Report_Setting_At( i );
      With P^ do if ( s7Report_Name = Report_Name ) then Begin
         Find_Windows_Report_Setting := P;
         if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Found');
         exit;
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Not Found' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWindows_Report_Setting_List.FreeItem(Item: Pointer);
const
   ThisMethodName = 'TWindows_Report_Setting_List.FreeITem';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   LAS7IO.Free_Windows_Report_Setting_Rec_Dynamic_Fields( pWindows_Report_Setting_Rec( Item)^ );
   SafeFreeMem( Item, Windows_Report_Setting_Rec_Size );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWindows_Report_Setting_List.LoadFromFile(var S: TIOStream);
const
   ThisMethodName = 'TWindows_Report_Setting_List.LoadFromFile';
Var
   Token       : Byte;
   P           : pWindows_Report_Setting_Rec;
   Msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Windows_Report_Setting :
            Begin
               P := New_Windows_Report_Setting_Rec;
               Read_Windows_Report_Setting_Rec ( P^, S );
               Insert( P );
            end;
         else
         begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
            LogUtil.LogMsg(lmDebug, UnitName, Msg );
            raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWindows_Report_Setting_List.SaveToFile(var S: TIOStream);
const
   ThisMethodName = 'TWindows_Report_Setting_List.SaveToFile';
Var
   i : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   S.WriteToken( tkBeginWindows_Report_Setting_List );
   For i := 0 to Pred( itemCount ) do LAS7IO.Write_Windows_Report_Setting_Rec( Windows_Report_Setting_At( i )^, S );
   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TWindows_Report_Setting_List.Windows_Report_Setting_At(Index: Integer): pWindows_Report_Setting_Rec;
const
   ThisMethodName = 'TWindows_Report_Setting_List.Windows_Report_Setting_At';
Var
   P : Pointer;
Begin
   result := nil;
   P := At( Index );
   if las7io.IsAWindows_Report_Setting_Rec(p) then
      result := P;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
  DebugMe := DebugUnit(UnitName);
end.
