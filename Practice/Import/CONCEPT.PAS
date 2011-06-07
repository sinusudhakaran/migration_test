unit Concept;

(*
   Concept Cash Manager from

   Computer Concepts
   PO Box 692
   Masterton

   Phone 06 370 0280
   Fax   06 378 6003
   email manager@concept.co.nz

   Paul Younger

   Used by Mackay Bailey Butchard ( Steve Boscoskie )
           Owen Dunning ( Gillian Floyd }
  

*)

{$I COMPILER}

// {$I DEBUGME}


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
  GenUtils, Progress, bkDateUtils, WinUtils;

Const
   UnitName = 'Concept';
   DebugMe  : Boolean = False;
   
//------------------------------------------------------------------------------

procedure RefreshChart;

const
   ThisMethodName    = 'RefreshChart';
var
   SourceDir         : String;
   CategoryFileName  : String;
   ExtendedFileName  : String;
   ChartFilePath     : string;
   HCtx              : integer;
   i                 : integer;
   f                 : TextFile;
   Line              : ShortString;
   NewChart          : TChart;
   NewAccount        : pAccount_Rec;
   Category          : pAccount_Rec;
   p                 : integer;
   ACode             : Bk5CodeStr;
   ADesc             : String[80];
   AType             : String[10];
   MCode             : String[10];
   Msg               : string;
   OK                : Boolean;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not Assigned(MyClient) then exit;

   OK := False;

   with MyClient.clFields do begin
      CategoryFileName := clLoad_Client_Files_From;

      if DirectoryExists(CategoryFileName) then // User only specified a directory - we need a filename
      begin
        CategoryFileName := '';
        ChartFilePath := AddSlash(clLoad_Client_Files_From);
      end
      else
        ChartFilePath := RemoveSlash(clLoad_Client_Files_From);

     //check file exists, ask for a new one if not
     if not BKFileExists( CategoryFileName ) then begin
        HCtx := 0;
        CategoryFileName := RemoveSlash(CategoryFileName);
        if not LoadChartFrom( 
           clCode,
           CategoryFileName,                 { Var Result }
           ExtractFilePath(ChartFilePath),      { Initial Directory }
           'Concept Export|CATEGORY.TXT', { Filter }
           'TXT',                       { Default Extension }
           HCtx ) then
           exit;
     end;

     try
        UpdateAppStatus('Loading Chart','',0);
        try
           SourceDir        := ExtractFilePath( CategoryFileName );
           CategoryFileName := SourceDir + 'CATEGORY.TXT';
           ExtendedFileName := SourceDir + 'EXTENDED.TXT';

           Try
              NewChart := TChart.Create(MyClient.ClientAuditMgr);

              If BKFileExists( CategoryFileName ) then
              Begin
                 AssignFile( F, CategoryFileName );
                 Reset(F);
                 try
                    While not EOF( F ) do 
                    Begin
                       Readln( F, Line );
(*

"PI","Personal Income","I","P",0,0,"",0.00,"3990"
"CONI","Contra In","I","R",0,0,"",0.00,""
"SI","Suspended Inc","I","O",0,0,"",0.00,""
"$OVERPAY","Over payment","I","O",0,0,"",0.00,""

*)
                       
                 
                       p := Pos( '",', Line );
                       ACode := TrimSpacesAndQuotes( Copy( Line, 1, p-1 ) ); { 388/ }
                       Line := Copy( Line, p+3, 255 );

                       p := Pos( '",', Line );
                       ADesc := TrimSpacesAndQuotes( Copy( Line, 1, p-1 ) ); { 388/ }
                       Line := Copy( Line, p+3, 255 );

                       p := Pos( '",', Line );
                       AType := TrimSpacesAndQuotes( Copy( Line, 1, p-1 ) ); { 388/ }
                       
                       if ( NewChart.FindCode( ACode )<> NIL ) then Begin
                          LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+ACode+' found in '+CategoryFileName );
                       end
                       else Begin
                          {insert new account into chart}
                          NewAccount := New_Account_Rec;
                          with NewAccount^ do begin
                             chAccount_Code        := aCode;
                             chAccount_Description := aDesc;
                             chPosting_Allowed     := true;
                             If ( aType = 'I' ) then chAccount_Type := atIncome
                             else if ( aType = 'E' ) then chAccount_Type := atExpense;
                          end;
                          NewChart.Insert(NewAccount);
                       end;
                    end;
                 Finally
                    CloseFile( F );
                 end;
              end;

              If BKFileExists( ExtendedFileName ) then
              Begin
                 AssignFile( F, ExtendedFileName );
                 Reset(F);
                 try
                    While not EOF( F ) do 
                    Begin
                       Readln( F, Line );

(*
"ADA","Accountant",100,"4511"
"ADB","Bank Charges",0,"4501"
"ADE","Entertainment",100,""
"ADG","General",100,"4515"
*)                       
                 
                       p := Pos( '",', Line );
                       ACode := TrimSpacesAndQuotes( Copy( Line, 1, p-1 ) ); { 388/ }
                       Line := Copy( Line, p+3, 255 );

                       p := Pos( '",', Line );
                       ADesc := TrimSpacesAndQuotes( Copy( Line, 1, p-1 ) ); { 388/ }

                       if ( NewChart.FindCode( ACode )<> NIL ) then Begin
                          LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+ACode+' found in '+ExtendedFileName );
                       end
                       else Begin
                          {insert new account into chart}
                          NewAccount := New_Account_Rec;
                          with NewAccount^ do begin
                             chAccount_Code        := aCode;
                             chAccount_Description := aDesc;
                             chPosting_Allowed     := true;
                          end;
                          NewChart.Insert( NewAccount );

                          For i := Length( aCode )-1 downto 2 do
                          Begin                          
                             MCode    := Copy( ACode, 1, i );
                             Category := NewChart.FindCode( MCode );
                             If Category <> NIL then 
                             Begin
                                // Category^.chPosting_Allowed := False;
                                NewAccount^.chAccount_Type := Category^.chAccount_Type;
                                Break;
                             end;                       
                          end;
                          
                       end;
                    end;
                 Finally
                    CloseFile( F );
                 end;
              end;
           
              if NewChart.ItemCount > 0 then begin
                 MergeCharts(NewChart, MyClient);

                 clLoad_Client_Files_From := CategoryFileName;
                 clChart_Last_Updated     := CurrentDate;
                 OK := True;
              end;
              ClearStatus(True);
           finally
              NewChart.Free;   {free is ok because Merge charts will have set NewChart to nil}
              if OK then HelpfulInfoMsg( 'The client''s chart of accounts has been refreshed.', 0 );
           end;
        finally
           ClearStatus(True);
        end;
     except
        on E : EInOutError do begin //Normally EExtractData but File I/O only
           Msg := Format( 'Error Refreshing Chart %s. %s', [ CategoryFileName, E.Message ] );
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


