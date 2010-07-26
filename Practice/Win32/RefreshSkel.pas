unit RefreshSkel;

//------------------------------------------------------------------------------
interface
//------------------------------------------------------------------------------

procedure RefreshChart;

//------------------------------------------------------------------------------
implementation
//------------------------------------------------------------------------------

uses
   Globals, SysUtils, chList32, bkchio, BK5Except,
   bkdefs, ovcDate, ErrorMoreFrm, Classes, LogUtil, ChartUtils, 
   GenUtils;

Const
   UnitName = '!!';
   DebugMe  : Boolean = False;
   
//------------------------------------------------------------------------------

function LoadChart( FileName : string ) : TChart;

const
   ThisMethodName = 'LoadChart';
   

Var
   F          : TextFile;
   B          : array[ 1..8192 ] of Byte;
   L          : ShortString;
   ACode      : string[8];
   ADesc      : string[50];
   AChart     : TChart;
   p          : Byte;
   OK         : Boolean;
Begin
   Result := nil;
   AChart := nil;
   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   
   if not BKFileExists( FileName ) then begin
      Msg := FormatStr( 'The file %s does not exist', [ FileName ] );
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
      Raise ERefreshFailed.Create( Msg );
   end;

   OK     := False;
   AChart := TChart.Create;
   
   Try
      Try
         AssignFile( F, FileName );
         SetTextBuf( F, B );
         Reset( F );
         while not EOF( F ) do Begin
            Readln( F, L );

            ACode := '';
            ADesc := '';

            p := Pos( '",', Line );
            ACode := TrimSpacesAndQuotes( Copy( Line, 1, p-1 ) ); { 388/ }
            Line := Copy( Line, p+3, 255 );

            p := Pos( '",', Line );
            ADesc := TrimSpacesAndQuotes( Copy( Line, 1, p-1 ) ); { 388/ }

               {insert new account into chart}
            NewAccount := New_Account_Rec;
            with NewAccount^ do begin
               chAccount_Code        := aCode;
               chAccount_Description := aDesc;
               chPosting_Allowed     := true;
            end;
            AChart.Insert(NewAccount);
         end;
         OK := True;
      finally
         CloseFile( F );
      end;
   Finally
      if not OK then Begin
         if Assigned( AChart ) then Begin
            AChart.Free;
            AChart := nil;
         end;
      end;
   end;
   
   if Assigned( AChart ) and AChart^.ItemCount = 0 then
   Begin
      AChart.Free;
      AChart := nil;
      Msg := FormatStr( 'BankLink couldn''t find any accounts in the file %s', [ FileName ] );
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
      Raise ERefreshFailed.Create( Msg );
   end;      
   
   Result := AChart;
   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure RefreshChart;

const
   ThisMethodName    = 'RefreshChart';
var
   FileName          : string;
   F                 : TextFile;
   Buffer            : array[ 1..8192 ] of Byte;
   NewChart          : TChart;
   Msg               : string;
   OK                : Boolean;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not Assigned( MyClient ) then exit;

   OK := False;
   
   with MyClient.clFields do begin
   
      FileName := clLoad_Client_Files_From;
      if not BKFileExists( FileName ) then
      Begin
         FileName := ChartUtils.GetChartFileName(  
            clCode, 
            ExtractFilePath( clLoad_Client_Files_From ),
            'CSV Files|*.CSV',
            'CSV',
             0 );
         if FileName = '' then Exit;
      end;

      try
         NewChart := LoadChart( FileName );
         MergeCharts( NewChart, MyClient ); { Frees NewChart }
         clLoad_Client_Files_From := FileName;
         clChart_Last_Updated     := CurrentDate;

         If clAccount_Code_Mask = '' then
            clAccount_Code_Mask := '###/###';
         HelpfulInfoMsg( 'The client''s chart of accounts has been refreshed.', 0 );
      except
         on E : ERefreshFailed do begin
            Msg := Format( 'Error Refreshing Chart: %s', [ E.Message ] );
            LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
            HelpfulErrorMsg( Msg + #13+#13+'The existing chart has not been modified.', 0 );
            exit;
         end;
         on E : EInOutError do begin //Normally EExtractData but File I/O only
            Msg := Format( 'Error Refreshing Chart %s. %s', [ FileName, E.Message ] );
            LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
            HelpfulErrorMsg( Msg + #13+#13+'The existing chart has not been modified.', 0 );
            exit;
         end;
      end; {except}
   end; {with}
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

