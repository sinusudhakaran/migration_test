unit DosPrn;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// List objects for loading dos printing
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses ladefs, ecollect, iostream;

type
   TDos_Printer_List = class( TExtdSortedCollection )
      constructor Create; override;
      function    Compare( Item1, Item2 : pointer ) : integer; override;

    protected
      procedure   FreeItem( Item : Pointer ); override;

    public
      function    Printer_At( Index : LongInt ): pPrinter_Rec;
      function    Find_Printer_By_LRN( ALRN : LongInt ): pPrinter_Rec;
      function    Find_Printer_By_Name( AName : String ): pPrinter_Rec;
      procedure   SaveToFile( Var S : TIOStream );
      procedure   LoadFromFile( Var S : TIOStream );
   end;

   TDos_Form_List = class( TExtdSortedCollection )
      constructor Create; override;
      function    Compare( Item1, Item2 : pointer ) : integer; override;

    protected
      procedure   FreeItem( Item : Pointer ); override;

    public
      function    Form_At( Index : LongInt ): pForm_Rec;
      function    Find_Form( No : LongInt ): pForm_Rec;
      procedure   SaveToFile( Var S : TIOStream );
      procedure   LoadFromFile( Var S : TIOStream );
   end;

   TDos_Report_Setting_List = class( TExtdSortedCollection )
      constructor Create; override;
      function    Compare( Item1, Item2 : pointer ) : integer; override;

    protected
      procedure   FreeItem( Item : Pointer ); override;

    public
      function    Report_Setting_At( Index : LongInt ): pReport_Setting_Rec;
      function    Find_Report_Setting( Report_Name : String ): pReport_Setting_Rec;
      procedure   SaveToFile( Var S : TIOStream );
      procedure   LoadFromFile( Var S : TIOStream );
   end;

//******************************************************************************
implementation
uses
   las3io, las5io, las6io, tokens, LogUtil, malloc, sysutils, StStrS,
   bkdbExcept,
   bk5Except;

const
   UnitName = 'DOSPRN';

var
   DebugMe : boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TDos_Printer_List }
function TDos_Printer_List.Compare(Item1, Item2: pointer): integer;
begin
   result := StStrS.CompStringS(pPrinter_Rec(Item2)^.s3Printer_Name,pPrinter_Rec(Item1)^.s3Printer_Name);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TDos_Printer_List.Create;
const
   ThisMethodName = 'TDos_Printer_List.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDos_Printer_List.Find_Printer_By_LRN(ALRN: Integer): pPrinter_Rec;
begin
   result := nil;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDos_Printer_List.Find_Printer_By_Name(AName: String): pPrinter_Rec;
begin
   result := nil;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDos_Printer_List.FreeItem(Item: Pointer);
const
   ThisMethodName = 'TDos_Printer_List.FreeItem';
var
   A : pPrinter_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   A := pPrinter_Rec( Item );
   LAS3IO.Free_Printer_Rec_Dynamic_Fields( A^);
   SafeFreeMem( Item, Printer_Rec_Size );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDos_Printer_List.Printer_At(Index: Integer): pPrinter_Rec;
const
   ThisMethodName = 'TDos_Printer_List.Printer_At';
Var
   P : Pointer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := nil;
   P := At( Index );
   if las3io.IsAPrinter_Rec(p) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDos_Printer_List.LoadFromFile(var S: TIOStream);
const
   ThisMethodName = 'TDos_Printer_List.LoadFromFile';
Var
   Token       : Byte;
   P           : pPrinter_Rec;
   Msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Printer :
            Begin
               P := New_Printer_Rec;
               Read_Printer_Rec ( P^, S );
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
procedure TDos_Printer_List.SaveToFile(var S: TIOStream);
Var
   i : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug,'DOSPRN','TDos_Printer_List.SaveToFile ends');

   S.WriteToken( tkBeginPrinter_List );
   For i := 0 to Pred( itemCount ) do LAS3IO.Write_Printer_Rec( Printer_At( i )^, S );
   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug,'DOSPRN','TDos_Printer_List.SaveToFile ends');
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TDos_Form_List }
function TDos_Form_List.Compare(Item1, Item2: pointer): integer;
begin
   If pForm_Rec(Item1)^.s5Form_Number < pForm_Rec(Item2)^.s5Form_Number then Compare := -1 else
   If pForm_Rec(Item1)^.s5Form_Number > pForm_Rec(Item2)^.s5Form_Number then Compare := 1 else
   Compare := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TDos_Form_List.Create;
const
   ThisMethodName = 'TDos_Form_List.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDos_Form_List.Find_Form(No: Integer): pForm_Rec;
begin
   result := nil;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDos_Form_List.Form_At(Index: Integer): pForm_Rec;
const
   ThisMethodName = 'TDos_Form_List.Form_At';
Var
   P : Pointer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := nil;
   P := At( Index );
   if las5io.IsAForm_Rec(p) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDos_Form_List.FreeItem(Item: Pointer);
const
   ThisMethodName = 'TDos_Form_List.FreeItem';
Var
   A : pForm_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   A := pForm_Rec( Item );
   LAS5IO.Free_Form_Rec_Dynamic_Fields( A^);
   SafeFreeMem( Item, Form_Rec_Size );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDos_Form_List.LoadFromFile(var S: TIOStream);
const
   ThisMethodName = 'TDos_Form_List.LoadFromFile';
Var
   Token       : Byte;
   P           : pForm_Rec;
   Msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Form :
            Begin
               P := New_Form_Rec;
               Read_Form_Rec ( P^, S );
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
procedure TDos_Form_List.SaveToFile(var S: TIOStream);
const
   ThisMethodName = 'TDos_Form_List.SaveToFile';
Var
   i : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   S.WriteToken( tkBeginForm_List );
   For i := 0 to Pred( ItemCount ) do LAS5IO.Write_Form_Rec( Form_At( i )^, S );
   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TDos_Report_Setting_List }
function TDos_Report_Setting_List.Compare(Item1, Item2: pointer): integer;
begin
   Compare := StStrS.CompStringS( pReport_Setting_Rec(Item2)^.s6Report_Name, pReport_Setting_Rec(Item1)^.s6Report_Name );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TDos_Report_Setting_List.Create;
const
   ThisMethodName = 'TDos_Report_Setting_List.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDos_Report_Setting_List.Find_Report_Setting(Report_Name: String): pReport_Setting_Rec;
begin
   result := nil;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDos_Report_Setting_List.FreeItem(Item: Pointer);
Var A : pReport_Setting_Rec;
Begin
   A := pReport_Setting_Rec( Item );
   LAS6IO.Free_Report_Setting_Rec_Dynamic_Fields( A^);
   SafeFreeMem( Item, Report_Setting_Rec_Size );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDos_Report_Setting_List.Report_Setting_At(Index: Integer): pReport_Setting_Rec;
const
   ThisMethodName = 'TDos_Report_Setting_List.Report_Setting_At';
Var
   P : Pointer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := nil;
   P := At( Index );
   if las6io.IsAReport_Setting_Rec(p) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDos_Report_Setting_List.LoadFromFile(var S: TIOStream);
const
   ThisMethodName = 'TDos_Report_Setting_List.LoadFromFile';
Var
   Token       : Byte;
   P           : pReport_Setting_Rec;
   Msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Report_Setting :
            Begin
               P := New_Report_Setting_Rec;
               Read_Report_Setting_Rec ( P^, S );
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
procedure TDos_Report_Setting_List.SaveToFile(var S: TIOStream);
const
   ThisMethodName = 'TDos_Report_Setting_List.SaveToFile';
Var
   i : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   S.WriteToken( tkBeginReport_Setting_List );
   For i := 0 to Pred( ItemCount ) do LAS6IO.Write_Report_Setting_Rec( Report_Setting_At( i )^, S );
   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
end.
