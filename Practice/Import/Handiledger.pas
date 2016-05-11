unit handiledger;

//------------------------------------------------------------------------------
interface
//------------------------------------------------------------------------------

procedure RefreshChart;

//------------------------------------------------------------------------------
implementation
//------------------------------------------------------------------------------

uses
  Globals, sysutils, InfoMoreFrm, bkconst, chList32, bkchio,
  bkdefs, ovcDate, ErrorMoreFrm, classes, LogUtil, ChartUtils, 
  GenUtils, Progress, bkDateUtils, StStrS, Templates, GSTCalc32, WinUtils;

Const
   UnitName = 'Handiledger';
   DebugMe  : Boolean = False;
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function GSTCodesInChart( ChtFileName : String ): Boolean;

Var
   InFile : Text;
   InBuf  : Array[ 1..8192 ] of Byte;
   Line   : ShortString;
   Fields : Array[ 1..4 ] of ShortString;
   i      : Byte;
Begin
   Result := False;

   AssignFile( InFile, ChtFileName ); 
   SetTextBuf( InFile, InBuf );
   Reset( InFile ); 
   
   Try
      While not EOF( InFile) Do 
      Begin 
         Readln( InFile, Line ); 
         FillChar( Fields, Sizeof( Fields ), 0 );
         For i := 1 to 4 do Fields[ i ] := TrimSpacesAndQuotes( ExtractAsciiS( i, Line, ',', '"' ) );
         If Fields[ 4 ] <> '' then 
         Begin
            Result := True;
            exit;
         end;
      end;
   Finally
      Close( InFile );
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;
   
   function GetCode( const ALine : ShortString ): ShortString;
   Var
      S : ShortString;
   Begin
      S := '';
      if Length( ALine )>=38 then
      Begin
         S := TrimS( Copy( ALine, 28, 10 ) );
      end;
      Result := S; 
   end;   

   // --------------------------------------------------------------------------
   
   function HasCode( const ALine : string ): Boolean;

   Var
      S : ShortString;
      i : Byte;
   Begin
      Result := False;
      S := GetCode( ALine );
      if S='' then Exit;
      Result := True;
      For i := 1 to Length( S ) Do
      Begin
         If not ( S[ i ] in [ '0'..'9', '.' ] ) then 
         begin
            Result := False;
            Exit;
         end;
      end;
   end;

const
   ThisMethodName    = 'RefreshChart';
var
   ChartFileName     : string;
   ChartFilePath     : string;
   HCtx              : integer;
   F                 : TextFile;
   Buffer            : array[ 1..8192 ] of Byte;
   Line              : String;
   NewChart          : TChart;
   NewAccount        : pAccount_Rec;
   ACode             : Bk5CodeStr;
   ADesc             : String[80];
   APost, AGSTClass  : string[10];
   Msg               : string;
   OK                : Boolean;
   p                 : Byte;
   FileExt           : String;
   FieldCount        : Integer;
   Fields            : Array[ 1..10 ] of ShortString;
   SL                : TStringList;
   i                 : Integer;
   ThisLine          : ShortString;
   NextLine          : ShortString;
   TemplateFileName  : ShortString;
   TemplateError     : TTemplateError;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not Assigned(MyClient) then exit;

   OK := False;

   with MyClient.clFields do begin
      ChartFileName := clLoad_Client_Files_From;

      if DirectoryExists(ChartFileName) then // User only specified a directory - we need a filename
      begin
        ChartFileName := '';
        ChartFilePath := AddSlash(clLoad_Client_Files_From);
      end
      else
        ChartFilePath := RemoveSlash(clLoad_Client_Files_From);

     //check file exists, ask for a new one if not
     if not BKFileExists( ChartFileName ) then begin
        HCtx := 0;
        ChartFileName := RemoveSlash(ChartFileName);
        if not LoadChartFrom(
           clCode,
           ChartFileName,                                { Var Result }
           ExtractFilePath(ChartFilePath),  { Initial Directory }
           'BankLink Chart Files|*.CSV;*.CHT',            { Filter }
           'CSV',
           HCtx ) then
           exit;
     end;

     if not BKFileExists( ChartFileName ) then exit;

     FileExt := UpperCase( ExtractFileExt( ChartFileName ) );

     // If it is a CSV file, then do this...
     
     If FileExt = '.CSV' then
     try

        If GSTCodesInChart( ChartFileName ) and not ( MyClient.GSTHasBeenSetup ) then
        Begin
          TemplateFileName := GLOBALS.TemplateDir + 'HL.TPM';
          If BKFileExists( TemplateFileName ) then
            Template.LoadTemplate( TemplateFilename, tpl_DontCreateChart, TemplateError );
        end;
     
        AssignFile( F,ChartFileName );
        SetTextBuf( F, Buffer );
        Reset( F );
        NewChart := TChart.Create(MyClient.ClientAuditMgr);
        try
           While not EOF( F ) do 
           Begin
              Readln( F, Line );

              FillChar( Fields, Sizeof( Fields ), 0 );
              FieldCount := StStrS.AsciiCountS( Line, ',' , '"' );

              If FieldCount = 4 then
              Begin
                 For i := 1 to 4 do Fields[ i ] := TrimSpacesAndQuotes( ExtractAsciiS( i, Line, ',', '"' ) );
              
(*
"0000","Suspense","Y","."
"0201","Sales - Livestock","Y",""
"0360","Freight rebate","Y",""
"0381","Interest Received","Y",""
*)
                 ACode     := Fields[1];
                 ADesc     := Fields[2];
                 APost     := Fields[3];
                 AGSTClass := Fields[4];

                 If ( ACode<>'' ) then
                 Begin
                    if ( NewChart.FindCode( ACode )<> NIL ) then Begin
                       LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+ACode+' found in '+ChartFileName );
                    end
                    else Begin
                 
                       {insert new account into chart}
                       NewAccount := New_Account_Rec;
                       with NewAccount^ do begin
                          chAccount_Code        := aCode;
                          chAccount_Description := aDesc;
                          chGST_Class           := GSTCalc32.GetGSTClassNo( MyClient, AGSTClass );
                          if Globals.PRACINI_PostingAlwaysTrue then
                             chPosting_Allowed     := True
                          else
                             chPosting_Allowed     := ( APost = 'Y' );
                       end;
                       NewChart.Insert( NewAccount );
                    end;
                 end;
              end;
           end;
              
           if NewChart.ItemCount > 0 then begin
              MergeCharts(NewChart, MyClient);
              clLoad_Client_Files_From := ChartFileName;
              clChart_Last_Updated     := CurrentDate;
              OK := True;
           end;
           ClearStatus(True);
        finally
           NewChart.Free;   {free is ok because Merge charts will have set NewChart to nil}
           CloseFile( F );
           if OK then HelpfulInfoMsg( 'The client''s chart of accounts has been refreshed.', 0 );
        end;
     except
        on E : EInOutError do begin //Normally EExtractData but File I/O only
           Msg := Format( 'Error refreshing chart %s.', [ChartFileName] );
           LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
           HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.', 0, False, E.Message, True);
           exit;
        end;
     end; {except}


     If FileExt = '.CHT' then
     try
        SL := TStringList.Create;
        NewChart := TChart.Create(MyClient.ClientAuditMgr);
        try
           SL.LoadFromFile( ChartFileName );

           for I := 0 to Pred( SL.Count ) do
           Begin
              ThisLine := SL.Strings[ I ];
              if I < Pred( SL.Count ) then
                 NextLine := SL.Strings[ I+1 ]
              else
                 NextLine := '';

              ACode := '';
              ADesc := '';                 

              if HasCode( ThisLine ) then
              Begin
                 ACode := GetCode( ThisLine );
                 ADesc := TrimS( Copy( ThisLine, 39, 28 ) );
                 if ( not HasCode( NextLine ) ) and ( Length( NextLine ) > 39 ) then
                 Begin
                    ADesc := TrimS( ADesc ) + ' ' + TrimS( Copy( NextLine, 39, 28 ) );
                 end;
              end;
                                     
              if ACode<>'' then Begin
                 if ( NewChart.FindCode( ACode )<> NIL ) then Begin
                    LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+ACode+' found in '+ChartFileName );
                 end
                 else Begin
                    {insert new account into chart}
                    NewAccount := New_Account_Rec;
                    with NewAccount^ do begin
                       chAccount_Code        := aCode;
                       chAccount_Description := aDesc;
                       chPosting_Allowed     := True;
                       chGST_Class           := 0;
                    end;
                    NewChart.Insert(NewAccount);

                    // Case #2395
                    if Globals.PRACINI_PostingAlwaysTrue then
                       Continue;

                    p := Pos( '.', aCode );
                    if ( p > 0 ) then begin { It's a sub-account } 
                       aCode := Copy( aCode, 1, p-1 );
                       NewAccount := NewChart.FindCode( aCode );
                       if Assigned( NewAccount ) then NewAccount^.chPosting_Allowed := False;
                    end;
                 end;
              end;
           end;
              
           if NewChart.ItemCount > 0 then begin
              MergeCharts(NewChart, MyClient);
              clLoad_Client_Files_From := ChartFileName;
              clChart_Last_Updated     := CurrentDate;
              OK := True;
           end;
           ClearStatus(True);
        finally
           NewChart.Free;   {free is ok because Merge charts will have set NewChart to nil}
           SL.Free;
           if OK then HelpfulInfoMsg( 'The client''s chart of accounts has been refreshed.', 0 );
        end;
     except
        on E : EInOutError do begin //Normally EExtractData but File I/O only
           Msg := Format( 'Error refreshing chart %s.', [ChartFileName] );
           LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
           HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.', 0 , False, E.Message, True);
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


