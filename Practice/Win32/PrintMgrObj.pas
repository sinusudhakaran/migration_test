unit PrintMgrObj;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Handles all printer and report settings for bk5
// note: the dos settings are in the file and must be loaded but are not used
//       in windows
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   Classes, bkDefs, ioStream, sysutils, dialogs, DosPrn, ReportSettingObj;

type
   TPrintManagerObj = class
      pmPrinter_List                   : TDos_Printer_List;
      pmForm_List                      : TDos_Form_List;
      pmReport_Setting_List            : TDos_Report_Setting_List;
      pmWindows_Report_Setting_List    : TWindows_Report_Setting_List;
     private
      fcfgFileName    : string;
      procedure      SaveToFile( Var S : TIOStream );
      procedure      LoadFromFile( Var S : TIOStream );
      procedure SetFileName(const Value: string);
      function GotItems : Boolean;
      procedure Clear;
     public
      property       FileName : string read fcfgFileName write SetFileName;
      constructor    Create;
      destructor     Destroy; override;
      procedure      Save;
      procedure      Open;
   end;

//******************************************************************************
implementation
uses
   LogUtil,
   tokens,
   CRCFileUtils,
   bk5Except,
   bkdbExcept,
   WinUtils,
   globals;

const
  UnitName = 'PRINTMGROBJ';
  BUFF_SIZE = 8192;
var
   DebugMe : Boolean = FALSE;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TPrintManagerObj }
procedure TPrintManagerObj.Clear;
begin
   pmPrinter_List.FreeAll;
   pmForm_List.FreeAll;
   pmReport_Setting_List.FreeAll;
   pmWindows_Report_Setting_List.FreeAll;
end;

constructor TPrintManagerObj.Create;
const
   ThisMethodName = 'TPrintManagerObj.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;

   {rewrite this}
   fcfgFileName := DATADIR + DEFAULTUSERPRINT;

   pmPrinter_List                := TDOS_Printer_List.Create;
   pmForm_List                   := TDOS_Form_List.Create;
   pmReport_Setting_List         := TDOS_Report_Setting_List.Create;
   pmWindows_Report_Setting_List := TWindows_Report_Setting_List.Create;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TPrintManagerObj.Destroy;
const
   ThisMethodName = 'TPrintManagerObj.Destroy';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   pmPrinter_List.Free;
   pmForm_List.Free;
   pmReport_Setting_List.Free;
   pmWindows_Report_Setting_List.Free;

   inherited Destroy;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;


function TPrintManagerObj.GotItems: Boolean;
begin
   result := (pmPrinter_List.ItemCount > 0)
          or (pmForm_List.ItemCount > 0)
          or (pmReport_Setting_List.ItemCount > 0)
          or (pmWindows_Report_Setting_List.ItemCount > 0);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TPrintManagerObj.LoadFromFile(var S: TIOStream);
const
   ThisMethodName = 'TPrintManagerObj.LoadFromFile';
Var
   Token    : Byte;
   Msg      : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do Begin
      Case Token of
         tkBeginPrinter_List                  : pmPrinter_List.LoadFromFile( S );
         tkBeginForm_List                     : pmForm_List.LoadFromFile( S );
         tkBeginReport_Setting_List           : pmReport_Setting_List.LoadFromFile( S );
         tkBeginWindows_Report_Setting_List   : pmWindows_Report_Setting_List.LoadFromFile( S );
         else begin
            Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
            LogUtil.LogMsg(lmDebug, UnitName, Msg );
            raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
         end;
      end;
      Token := S.ReadToken;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TPrintManagerObj.Open;
const
   ThisMethodName = 'TPrintManagerObj.Open';
Var
   S : TIOStream;
   CRC : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' File name = '+fCfgFileName);
   Clear;
   if BKFileExists( fCfgFileName ) then
   begin
     S := TIOStream.Create;
     try
        S.LoadFromFile( fcfgFilename);
        CRCFileUtils.CheckEmbeddedCRC( S);
        S.Position := 0;
        S.Read( CRC, Sizeof( LongInt ) );
        LoadFromFile( S );
     finally
        S.Free;
     end;
   end
   else  //file doesnt exist.. is new user so uses blank prs object and save when finished
     ;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TPrintManagerObj.Save;
const
   ThisMethodName = 'TPrintManagerObj.Save';
Var
   S : TIOStream;
   L : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' File name = '+fCfgFileName);

   S := TIOStream.Create;
   try
      L := 0;
      S.Write( L, Sizeof( LongInt ) ); { Leave space for the CRC }
      SaveToFile( S );
      EmbedCRC( S);
      S.SaveToFile( fcfgFilename);
   finally
      S.Free;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TPrintManagerObj.SaveToFile(var S: TIOStream);
const
   ThisMethodName = 'TPrintManagerObj.SaveToFile';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   pmPrinter_List.SaveToFile( S );
   pmForm_List.SaveToFile( S );
   pmReport_Setting_List.SaveToFile( S );
   pmWindows_Report_Setting_List.SaveToFile( S );
   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
procedure TPrintManagerObj.SetFileName(const Value: string);
begin
  if not sametext(fcfgFileName, Value) then begin
     if (fcfgFileName <> '')
     and GotItems then
        Save;
     fcfgFileName := Value;
     open; 
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
end.
