unit PrntInfo;

interface
uses
  classes, printers, windows;

type
  TPaperInfo = class
     index : integer;
     Size  : TPoint;
  end;

  procedure GetPapernames(CurrPrinter: TPrinter; sl: TStringList);
  procedure GetBinnames(CurrPrinter : TPrinter; sl: TStringList);
  function GetPrinterName(index : integer):string;
  function GetStatusMsg(Status : integer):string;
  function GetPrinterRotation(CurrPrinter : TPrinter) : integer;

  procedure ResetPrinterDevMode(aPrinter : TPrinter);
  procedure SetAppDefaultPrinter(aPrinter: TPrinter; index :integer);

  procedure ViewSettings(fPrinter : TPrinter);

  function CheckPrinterStatus (fPrinter : TPrinter;
                            Var StatusText,
                                DriverName,
                                Location : String) : Boolean;


//******************************************************************************
implementation

uses
  winspool, sysutils, math;
const
   UnitName = 'PRNTINFO';
{var
  DebugMe : boolean = false;}

Var
   LastDevice    : Array [0..255] of Char;
   LastDriver    : Array [0..255] of Char;
   LastPort      : Array [0..255] of Char;
   LastPaperList : TStringList;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CompStruct(const S1, S2; Size : Cardinal) : Integer;
//Copied from SysTools.StBase
  {-Compare two fixed size structures}
asm
  push   edi
  push   esi
  mov    esi, eax
  mov    edi, edx
  xor    eax, eax
  or     ecx, ecx
  jz     @@CSDone

  repe   cmpsb
  je     @@CSDone

  inc    eax
  ja     @@CSDone
  or     eax, -1

@@CSDone:
  pop    esi
  pop    edi
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function IsIdentical( const S1, S2; Size : Cardinal ): Boolean;
Begin
   Result := ( CompStruct( S1, S2, Size ) = 0 );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure FreeLastPaperList;

Var i : Integer;

Begin
   If Assigned( LastPaperList ) then
   Begin
      For i := 0 to Pred( LastPaperList.Count ) do begin
         TPaperInfo( LastPaperList.Objects[ i ] ).Free;
         LastPaperList.Objects[ i] := nil;
      end;
      LastPaperList.Free;
      LastPaperList := NIL;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure CopyPaperList( SrcList, DestList : TStringList );
Var
  SrcObj : TPaperInfo;
  NewObj : TPaperInfo;
  i      : Integer;
Begin
   DestList.Clear;
   For i := 0 to Pred( SrcList.Count ) do
   Begin
      DestList.Add( SrcList[i] );
      NewObj := TPaperInfo.Create;
      SrcObj := TPaperInfo( SrcList.Objects[ i ] );
      NewObj.Index  := SrcObj.Index;
      NewObj.Size.X := SrcObj.Size.X;
      NewObj.Size.Y := SrcObj.Size.Y;
      DestList.Objects[ i ] := NewObj;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure GetPapernames(CurrPrinter : TPrinter; sl: TStringList );

Type
  TPaperName = Array [0..63] of Char;
  TPaperNameArray = Array of TPaperName;
  TPaperArray = Array of Word;
  TPaperSizeArray = Array of TPoint;
Var
  Device, Driver, Port: Array [0..255] of Char;
  hDevMode         : THandle;
  i,
  numPaperformats,
  numPapers        : Integer;
  numPaperSizes    : integer;
  Obj              : TPaperInfo;
  PaperSizes       : TPaperSizeArray;
  PaperFormats     : TPaperNameArray;
  Papers           : TPaperArray;
  MinPaperInfo     : integer;
begin
   FillChar( Device, Sizeof( Device ), 0 );
   FillChar( Driver, Sizeof( Driver ), 0 );
   FillChar( Port,   Sizeof( Port   ), 0 );
   CurrPrinter.GetPrinter( Device, Driver, Port, hDevmode );

   If IsIdentical( Device, LastDevice , Sizeof( Device   ) ) and
      IsIdentical( Driver, LastDriver , Sizeof( Driver   ) ) and
      IsIdentical( Port  , LastPort   , Sizeof( Port     ) ) then
   Begin
      CopyPaperList( LastPaperList, SL );
      exit;
   end;

   sl.Clear;
   //get printer paper information, all numbers should match, however in the case
   //that they dont then take the smallest number.
   numPaperformats := WinSpool.DeviceCapabilities( Device, Port, DC_PAPERNAMES, Nil, Nil );  //names
   numPapers       := WinSpool.DeviceCapabilities( Device, Port, DC_PAPERS, Nil, Nil );      //windows id
   numPaperSizes   := WinSpool.DeviceCapabilities( Device, Port, DC_PAPERSIZE, nil,nil);     //papersize x,y

   minPaperInfo :=  min(numPaperFormats, min(numPapers, numPaperSizes));

(*  //debug info
   if debugMe then
   begin
     If (numPapers <> numPaperFormats) or (numPapers <> numPaperSizes) and (CurrPrinter.PrinterIndex <> -1) then
       LogUtil.LogMsg(lmDebug,'PRNTINFO','CurrPrinter is '+CurrPrinter.Printers[CurrPrinter.printerIndex]);
     If numPapers <> numPaperFormats Then
       LogUtil.LogMsg(lmDebug,'PRNTINFO','DeviceCapabilities reports different number of papers and paper names!');
     If numPapers <> numPaperSizes Then
       LogUtil.LogMsg(lmDebug,'PRNTINFO','DeviceCapabilities reports different number of papers and paper sizes!');
   end;
*)

   If minPaperInfo > 0 Then
   Begin
      SetLength(PaperSizes,numPaperSizes * Sizeof(TPoint));
      SetLength(Papers,numPapers * Sizeof(Word));
      SetLength(PaperFormats, numPaperFormats * Sizeof(TPaperName));

      try
         WinSpool.DeviceCapabilities( Device, Port, DC_PAPERNAMES, Pchar( PaperFormats ), Nil);
         WinSpool.DeviceCapabilities( Device, Port, DC_PAPERS, PChar(Papers), Nil);
         WinSpool.DeviceCapabilities( Device, Port, DC_PAPERSIZE, PChar(PaperSizes),Nil);
         For i:= 0 To Pred(minPaperInfo) Do
         begin
            if sl.IndexOf( PaperFormats[i] )=-1 then
            Begin
               Obj := TPaperInfo.Create;
               Obj.index   := Papers[i];
               Obj.Size.x  := PaperSizes[i].x;
               Obj.Size.y  := PaperSizes[i].y;
               sl.addObject(Paperformats[i],Obj);
            end;
         end;
      finally
         Papers       := nil; {set size back to zero}
         PaperSizes   := nil;
         PaperFormats := nil;
      end;
   end;

   { Keep a copy so we can get it quickly next time }

   Move( Device, LastDevice, Sizeof( Device ) );
   Move( Driver, LastDriver, Sizeof( Driver ) );
   Move( Port,   LastPort,   Sizeof( Port   ) );
   FreeLastPaperList;
   LastPaperList := TStringList.Create;
   CopyPaperList( SL, LastPaperList );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure GetBinnames( CurrPrinter: TPrinter; sl: TStringList );
Type
  TBinName = Array [0..23] of Char;
  TBinNameArray = Array of TBinName;
  TBinArray = Array of Word;
Var
  Device, Driver, Port: Array [0..255] of Char;
  hDevMode: THandle;
  i, numBinNames, numBins: Integer;
  Bins : TBinArray;
  BinNames : TBinNameArray;
  MinBinInfo : integer;
begin
  CurrPrinter.GetPrinter(Device, Driver, Port, hDevmode);
  sl.Clear;

  numBinNames :=  WinSpool.DeviceCapabilities( Device, Port, DC_BINNAMES, Nil, Nil );
  numBins     :=  WinSpool.DeviceCapabilities( Device, Port, DC_BINS, Nil, Nil );

  minBinInfo := Min(numBinNames, numBins);
(*
  if DebugMe then
    If numBins <> numBinNames Then
    begin
      LogUtil.LogMsg(lmDebug,'PRNTINFO','CurrPrinter is '+CurrPrinter.Printers[CurrPrinter.printerIndex]);
      LogUtil.LogMsg(lmDebug,'PRNTINFO','DeviceCapabilities reports different number of bins and bin names!');
    end;
*)

  If minBinInfo > 0 Then
  Begin
    SetLength(Bins,NumBins * Sizeof(Word));
    SetLength(BinNames, numBinNames * Sizeof(TBinName));

    try
      WinSpool.DeviceCapabilities( Device, Port, DC_BINNAMES, Pchar( BinNames ), nil);
      WinSpool.DeviceCapabilities( Device, Port, DC_BINS, PChar(Bins), nil);

      sl.clear;
      For i:= 0 To Pred(minBinInfo) Do

        sl.addObject( BinNames[i], tobject(Bins[i]));
    finally
      Bins := nil;
      BinNames := nil;
    end;
  End;
End;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function GetPrinterName(index : integer):string;
{creates its own printer so as not to disturb anything}
var
  hPrinter, hDevMode: THANDLE;
  Device, Driver, Port: Array [0..255] of Char;
  Info : pPrinterInfo2;
  BytesRec,BytesRet : integer;
  TempPrinter : TPrinter;
begin
   result := '';
   TempPrinter := TPrinter.Create;
   try
     TempPrinter.PrinterIndex := index;
     TempPrinter.GetPrinter(device, driver, port, hDevMode);
     OpenPrinter(device, hPrinter, nil);
     BytesRec := 0;
     WinSpool.GetPrinter(hPrinter,2,nil,0,@bytesRec);  {get size for buffer}
     if (BytesRec <> 0 )then begin
        GetMem(info,bytesRec);
        try
          if Winspool.GetPrinter(hPrinter,2,info,bytesRec,@bytesRet) then
             result := info^.pPrinterName;
        finally
          FreeMem(info,bytesRec);
        end;
     end;
   finally
     TempPrinter.Free;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function GetStatusMsg(Status : integer):string;
begin
   case Status of
    0                                : result := 'Ready';
    PRINTER_STATUS_PAUSED            : result := 'Paused';
    PRINTER_STATUS_ERROR             : result := 'Error';
    PRINTER_STATUS_PENDING_DELETION  : result := 'Pending Deletion';
    PRINTER_STATUS_PAPER_JAM         : result := 'Paper Jammed';
    PRINTER_STATUS_PAPER_OUT         : result := 'Out of Paper';
    PRINTER_STATUS_MANUAL_FEED       : result := 'Manual Feed Required';
    PRINTER_STATUS_PAPER_PROBLEM     : result := 'Paper Problem';
    PRINTER_STATUS_OFFLINE           : result := 'OffLine';
    PRINTER_STATUS_IO_ACTIVE         : result := 'IO Active';
    PRINTER_STATUS_BUSY              : result := 'Busy';
    PRINTER_STATUS_PRINTING          : result := 'Printing';
    PRINTER_STATUS_OUTPUT_BIN_FULL   : result := 'Output Bin Full';
    PRINTER_STATUS_NOT_AVAILABLE     : result := 'Not Available';
    PRINTER_STATUS_WAITING           : result := 'Waiting';
    PRINTER_STATUS_PROCESSING        : result := 'Processing';
    PRINTER_STATUS_INITIALIZING      : result := 'Initialising';
    PRINTER_STATUS_WARMING_UP        : result := 'Warming Up';
    PRINTER_STATUS_TONER_LOW         : result := 'Toner Low';
    PRINTER_STATUS_NO_TONER          : result := 'No Toner';
    PRINTER_STATUS_PAGE_PUNT         : result := 'Page Cannot be Printed';
    PRINTER_STATUS_USER_INTERVENTION : result := 'User Intervention Required';
    PRINTER_STATUS_OUT_OF_MEMORY     : result := 'Out of Memory';
    PRINTER_STATUS_DOOR_OPEN         : result := 'Door Open';
    PRINTER_STATUS_SERVER_UNKNOWN    : result := 'Server Unknown';
    PRINTER_STATUS_POWER_SAVE        : result := 'Power Save Mode';

  else
    result := 'Unknown (' + IntToStr(Status) + ')';
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ResetPrinterDevMode(aPrinter : TPrinter);
var
   Device, Driver, Port: Array [0..255] of Char;
   hDevMode : THANDLE;
begin
   {reset defaults}
   aPrinter.GetPrinter(device, driver, port, hDevMode);
   aPrinter.SetPrinter(device, driver, port, 0);       {forces TPrinter to load a new DEVMODE structure}
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure SetAppDefaultPrinter(aPrinter: TPrinter; index :integer);
var
   Dev,Driv,Port : Array[0..255] of char;
   DeviceM       : THandle;
begin
   aPrinter.PrinterIndex := index;
   aPrinter.GetPrinter(Dev,Driv,Port,DeviceM);
   aPrinter.SetPrinter(Dev,Driv,Port,DeviceM);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ViewSettings(fPrinter : TPrinter);
var
  hPrinter, hDevMode: THANDLE;
  Device, Driver, Port: Array [0..255] of Char;
  MyDevMode: PDevMode;


//  lCopies, WasCopies,
//  Paper, WasPaper,
//  lBin, WasBin,
//  Orient, WasOrient    : integer;
begin
   FPrinter.GetPrinter(device, driver, port, hDevMode);
   OpenPrinter(device, hPrinter, nil);
   if hDevMode <> 0 then
     begin
       MyDevMode := GlobalLock(hDevMode);
       try
         if not DocumentProperties(0, hPrinter, device, MydevMode^, MydevMode^,
           DM_IN_BUFFER or DM_IN_PROMPT) = IDOK then exit;

       finally
         GlobalUnlock(hDevMode);
       end;
     end;

   ClosePrinter(hPrinter);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function GetPrinterRotation(CurrPrinter : TPrinter) : integer;
Var
  Device, Driver, Port: Array [0..255] of Char;
  hDevMode         : THandle;
begin
  CurrPrinter.GetPrinter(Device, Driver, Port, hDevmode);
  result := WinSpool.DeviceCapabilities( Device, Port, DC_ORIENTATION , Nil, Nil );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


function CheckPrinterStatus (fPrinter : TPrinter;
                            Var StatusText,
                                DriverName,
                                Location : String) : Boolean;


  var Info : pPrinterInfo2;
      PSize : DWord;
      Lused : DWord;
      hPrinter : THandle;
      hDevMode: THANDLE;
      Device, Driver, Port: Array [0..255] of Char;

      procedure checkjobs;
      Type
         PJobInfoList = ^TJobInfoList;
         TJobInfoList = array [0..0] of TJobInfo2A;

      var JSize,
          lRet : dWord;
          pjobs : PJobInfoList;
          i : Integer;
      begin //checkjobs
          JSize := 0; Lused := 0;
          if (not EnumJobs(hPrinter,0,Info^.cJobs,2, nil, 0,JSize,Lused)) then begin
             Lused := GetLastError; // need to keep...
             if (not (lused = ERROR_INSUFFICIENT_BUFFER)) then begin
                // most likely no access to the printer server to find out...
                // in any case, can't move on..
                StatusText := SysErrorMessage(Lused);
                Exit;
             end;
          end;
          if Info^.cJobs <= 0 then begin
             // no jobs so can't fail..
             Result := true;
          end else if JSize > 0 then begin
             // check the actual jobs...
             getmem(pjobs,jSize);
             try
                lused := 0;
                lRet := 0;
                if (not EnumJobs(hPrinter,0,Info^.cJobs,2,PJobs,JSize,LUsed,lRet)) then begin
                   StatusText := SysErrorMessage(GetLastError);
                   exit;
                end;
                if (lused = 0)
                or (lRet = 0) then begin
                   Result := true; // Must have cleared since..
                   exit;
                end;

                {$R-} // info = [0...0]
                try
                for i := 0 to pred(lRet) do begin

                   if bool(pJobs[i].Status and JOB_STATUS_PRINTING) then begin
                      StatusText := 'Printing'; // ok...
                   end;

                   if bool (pJobs[i].Status AND JOB_STATUS_OFFLINE)  then begin
                      StatusText := 'Off line';
                      Exit;
                   end;

                   if bool (pJobs[i].Status AND JOB_STATUS_PAPEROUT)  then begin
                      StatusText := 'Out of paper';
                      exit;
                   end;

                   if bool (pJobs[i].Status AND JOB_STATUS_BLOCKED_DEVQ)  then begin
                      StatusText := 'Blocked';
                      Exit;
                   end;

                   if bool (pJobs[i].Status AND JOB_STATUS_ERROR)  then begin
                      StatusText := 'Error';
                      Exit;
                   end;
                end;
                 // Still here...
                 result :=  true;
                Except
                   on E : Exception do begin
                       //Statustext := E.Message;
                       StatusText :=  'S ' + IntToStr(jSize) +
                                      ' U ' + IntToStr (LUsed) +
                                      ' R ' + IntToStr (LRet);
                   end;
                end;
             finally
                freeMem(PJobs,JSize);
             end;
          end else begin
             Result := true; // Don't  have size.. must have no jobs..
          end;
      End; //checkjobs



  begin //CheckPrinterStatus
     result := false;

     DriverName := '';
     Location   := '';

     if not assigned (fPrinter) then begin
        StatusText := 'printer not assigned';
        exit;
     end;

     fprinter.Refresh; // forces a re-load of Printers

     if (fPrinter.PrinterIndex < 0)
     or (fPrinter.PrinterIndex >= Printer.Printers.Count) then begin
        StatusText := 'printer Index out of range';
        exit;
     end;

     StatusText := 'Ready';

     fPrinter.GetPrinter(Device, Driver, Port,hDevMode);
     if OpenPrinter(Device,hPrinter,Nil) then
        Try

        pSize := 0;
        if not Winspool.GetPrinter(hPrinter,2,nil,0,@Psize) then begin
           Lused := GetLastError;
           if (not (Lused = ERROR_INSUFFICIENT_BUFFER)) then begin
              StatusText := SysErrorMessage(Lused);
              Exit; // nothing we can do
           end;
        end;
        //read info
        GetMem(info,PSize);
        try try
           if Winspool.GetPrinter(hPrinter,2,info,PSize,@LUsed) then begin

              DriverName :=  info^.pDriverName;
              Location :=  info^.pPortName;

              if info^.Status <> 0 then begin
                 StatusText := GetStatusMsg(info^.Status);
                 exit; // failed already
              end;
           end else begin
              StatusText := SysErrorMessage(GetLastError);
              exit;
           end;

           CheckJobs;
        except
          on E : Exception do begin
                       //Statustext := E.Message;
                       Statustext := 'GetPrinterInfo Failed';
                   end;
        end;
        finally
           FreeMem(info,Psize);
        end;
     Finally
        ClosePrinter(hPrinter);
     end else
        StatusText := SysErrorMessage(GetLastError);
  end; //CheckPrinterStatus








initialization
{   DebugMe := DebugUnit(UnitName);}
   LastPaperList := TStringList.Create;
   FillChar( LastDevice, Sizeof( LastDevice ), 0 );
   FillChar( LastDriver, Sizeof( LastDriver ), 0 );
   FillChar( LastPort  , Sizeof( LastPort   ), 0 );
finalization
   FreeLastPaperList;
end.
