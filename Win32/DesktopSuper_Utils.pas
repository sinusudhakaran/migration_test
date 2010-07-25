unit DesktopSuper_Utils;

interface

uses Globals;

function SetLedger(Current: Integer): Integer;
function GetLedgerName(ID: Integer): string;
function ImportDesktopCSV(FileName: string; TypeTitle: string): string;
function GetChartID(Code: string): string;

implementation

uses Classes, SysUtils, Dialogs, bkConst, GenUtils, WinUtils, Select_Desktop_GLfrm,
  GlobalDirectories, InfoMoreFrm, ErrorMoreFrm, LogUtil, StStrS, bkDefs, baObj32;

Const
   UnitName = 'DesktopSuper_Utils';

function SetLedger(Current: Integer): Integer;
const
  ThisMethodName = 'SetLedger';
var
  LedgerFileName, Line, Msg: string;
  OpenDlg: TOpenDialog;
  F: TextFile;
  Buffer: array[ 1..8192 ] of Byte;
  S: TStringList;
begin
   Result := Current;
   if not Assigned(MyClient) then exit;

   with MyClient.clFields do begin
     LedgerFileName := AddSlash(clLoad_Client_Files_From) + DESKTOP_SUPER_LEDGER_FILENAME;

     //check file exists, ask for a new one if not
     if not BKFileExists( LedgerFileName ) then begin
       OpenDlg := TOpenDialog.Create(Nil);
       Try
          With OpenDlg Do
          Begin
             DefaultExt   := '*.CSV';;
             Filename     := LedgerFileName;
             Filter       := 'Exported Ledger List (*.CSV)|*.CSV|All Files|*.*';
             HelpContext  := 0;
             Options      := [ ofHideReadOnly, ofFileMustExist, ofEnableSizing, ofNoChangeDir ];
             Title        := 'Load Desktop Super Ledger List';
             InitialDir   := clLoad_Client_Files_From;
          End;
          If OpenDlg.Execute Then
             LedgerFileName := OpenDlg.Filename
          else
            exit;
       Finally
          OpenDlg.Free;
          //make sure all relative paths are relative to data dir after browse
          SysUtils.SetCurrentDir( GlobalDirectories.glDataDir);
       End;
       clLoad_Client_Files_From := SysUtils.ExtractFileDir(LedgerFileName);
     end;

     try
        //have a file to read
        AssignFile( F,LedgerFileName );
        SetTextBuf( F, Buffer );
        Reset( F );
        S := TStringList.Create;
        try
           While not EOF( F ) do Begin
              Readln( F, Line );
              S.Add(Line);
           end;
           Select_Desktop_GLfrm.SelectLedgerID(Result, S.Text);
        finally
           CloseFile(f);
           S.Free;
        end;
     except on E: Exception do
      begin
         Msg := Format( 'Error reading Ledger file %s. %s', [LedgerFileName, E.Message ] );
         LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
         HelpfulErrorMsg( Msg, 0 );
      end;
     end; {except}
  end; {with}
end;

function GetLedgerName(ID: Integer): string;
const
  ThisMethodName = 'GetLedgerName';
var
  LedgerFileName, Line, Msg: string;
  F: TextFile;
  Buffer: array[ 1..8192 ] of Byte;
begin
   if not Assigned(MyClient) then exit;
   Result := '';
   with MyClient.clFields do begin
     LedgerFileName := AddSlash(clLoad_Client_Files_From) + DESKTOP_SUPER_LEDGER_FILENAME;
     if not BKFileExists( LedgerFileName ) then exit;
     try
        AssignFile( F,LedgerFileName );
        SetTextBuf( F, Buffer );
        Reset( F );
        try
           While not EOF( F ) do Begin
              Readln( F, Line );
              if StrToIntDef(TrimSpacesAndQuotes( ExtractAsciiS( 1, Line, ',', '"' )), -99) = ID then
              begin
                Result := TrimSpacesAndQuotes( ExtractAsciiS( 2, Line, ',', '"' ));
                exit;
              end;
           end;
        finally
           CloseFile(f);
        end;
     except on E: Exception do
      begin
         Msg := Format( 'Error reading Ledger file %s. %s', [LedgerFileName, E.Message ] );
         LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
      end;
     end; {except}
  end; {with}
end;

function ImportDesktopCSV(FileName: string; TypeTitle: string): string;
const
  ThisMethodName = 'ImportDesktopCSV';
var
  LedgerFileName, Line, Msg: string;
  OpenDlg: TOpenDialog;
  F: TextFile;
  Buffer: array[ 1..8192 ] of Byte;
  S: TStringList;
begin
   if not Assigned(MyClient) then exit;
   Result := '';
   with MyClient.clFields do begin
      LedgerFileName := AddSlash(clLoad_Client_Files_From) + FileName;

     //check file exists, ask for a new one if not
     if not BKFileExists( LedgerFileName ) then begin
       OpenDlg := TOpenDialog.Create(Nil);
       Try
          With OpenDlg Do
          Begin
             DefaultExt   := '*.CSV';;
             Filename     := LedgerFileName;
             Filter       := 'Exported ' + TypeTitle + ' (*.CSV)|*.CSV|All Files|*.*';
             HelpContext  := 0;
             Options      := [ ofHideReadOnly, ofFileMustExist, ofEnableSizing, ofNoChangeDir ];
             Title        := 'Load Desktop Super ' + TypeTitle;
             InitialDir   := clLoad_Client_Files_From;
          End;
          If OpenDlg.Execute Then
             LedgerFileName := OpenDlg.Filename
          else
            exit;
       Finally
          OpenDlg.Free;
          //make sure all relative paths are relative to data dir after browse
          SysUtils.SetCurrentDir( GlobalDirectories.glDataDir);
       End;
       clLoad_Client_Files_From := SysUtils.ExtractFileDir(LedgerFileName);
     end;

     try
        //have a file to read
        AssignFile( F,LedgerFileName );
        SetTextBuf( F, Buffer );
        Reset( F );
        S := TStringList.Create;
        try
           While not EOF( F ) do Begin
              Readln( F, Line );
              S.Add(Line);
           end;
           Result := S.Text;
        finally
           CloseFile(f);
           S.Free;
        end;
     except on E: Exception do
      begin
         Msg := Format( 'Error reading ' + TypeTitle + ' file %s. %s', [LedgerFileName, E.Message ] );
         LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
         HelpfulErrorMsg( Msg, 0 );
      end;
     end; {except}
  end; {with}
end;

function GetChartID(Code: string): string;
var
  p: pAccount_Rec;
begin
  p := MyClient.clChart.FindCode(Code);
  if Assigned(p) and (p.chChart_ID <> '') then
    Result := p.chChart_ID
  else
    Result := '-1';
end;

end.
