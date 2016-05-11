unit QuickBooks;
//------------------------------------------------------------------------------
{
   Title:        Quickbooks Chart Refresh

   Description:

   Remarks:     Imports chart from Quickbooks 5,6,7

   Author:      Modified Oct 2000  Matthew Hopkins

   Revisions:   Jun 2004 - expanded the list of account types that can be recognised
}
//------------------------------------------------------------------------------

interface
//------------------------------------------------------------------------------

procedure RefreshChart;

//******************************************************************************
implementation
//------------------------------------------------------------------------------

uses
   Globals,
   SysUtils,
   chList32,
   bkchio,
   BK5Except,
   BKConst,
   bkdefs,
   ovcDate,
   InfoMoreFrm,
   ErrorMoreFrm,
   Classes,
   LogUtil,
   ChartUtils,
   GenUtils,
   Windows,
   Templates,
   gstCalc32,
   WinUtils,
   bkProduct;

Const
   UnitName = 'QuickBooks';
   DebugMe  : Boolean = False;

//------------------------------------------------------------------------------
function LoadQBWChart( FileName : string ) : TChart;

const
   ThisMethodName = 'LoadQBWChart';
   Tab = #09;
(*

Version 7.4 added the TAXCODE column to the chart export

AU / NZ

   1     2       3        4         5         6       7      8       9     10     11     12    13      14       15
!ACCNT	NAME	REFNUM	TIMESTAMP	ACCNTTYPE	OBAMOUNT	DESC	ACCNUM	TAXCODE	SCD	BANKNUM	EXTRA	HIDDEN	DELCOUNT	USEID
ACCNT	Cash	3	935027837	BANK	0.00	Cash	1-7801		0			N	0	N

UK:
   1      2      3        4         5         6      7       8     9     10     11    12       13       14      15         16
!ACCNT	NAME	REFNUM	TIMESTAMP	ACCNTTYPE	OBAMOUNT	DESC	ACCNUM	SCD	BANKNUM	EXTRA	HIDDEN	DELCOUNT	USEID	WKPAPERREF	CURRENCY

*)

const
   colRowType    = 1;
   colName       = 2;
   colCode       = 8;
   colAccType    = 5;
   colTax : byte = 9;



   qbTypeMin = 1;
   qbTypeMax = 17;


   StdTypeNames : array[ qbTypeMin..qbTypeMax ] of string[10] =
      ( 'AP','AR','BANK','CCARD','COGS','EQUITY','EXEXP','EXINC','FIXASSET','INC',
        'LTLIAB','NONPOSTING','OASSET','OCASSET', 'EXP', 'OCLIAB', 'SUSPENSE' );

   StdTypeCodes : array[ qbTypeMin..qbTypeMax ] of Byte =
      ( { 'AP'         } atCreditors       ,
        { 'AR'	       } atDebtors         ,
        { 'BANK'       } atBankAccount     ,
        { 'CCARD'      } atBankAccount     ,
        { 'COGS'       } atPurchases       ,
        { 'EQUITY'     } atEquity          ,
        { 'EXEXP'      } atExpense         ,
        { 'EXINC'      } atIncome          ,
        { 'FIXASSET'   } atFixedAssets     ,
        { 'INC'        } atIncome          ,
        { 'LTLIAB'     } atLongTermLiability,
        { 'NONPOSTING' } atNone            ,
        { 'OASSET'     } atFixedAssets     ,
        { 'OCASSET'    } atCurrentAsset,
        { 'EXP'}         atExpense,
        { 'OCLIAB' }     atCurrentLiability,
        { 'SUSPENSE' }   atNone);

Var
   L          : ShortString;
   fStart     : array[ 1..50 ] of Byte;
   fLen	     : array[ 1..50 ] of Byte;
   fCount	  : Byte;

   //--------------------------------------------------------------
   procedure FindFields;
   Var
      i : Integer;
   Begin
      FillChar( fStart, SizeOf( fStart ), 0 );
      FillChar( fLen, SizeOf( fLen ), 0 );

      fCount := 1;
      for i := 1 to Length( L ) do
      Begin
         if ( L[i] = Tab ) then
            Inc( fCount )
         else
         Begin
            if fStart[ fCount ] = 0 then fStart[ fCount ] := i;
            Inc( fLen[ fCount ] );
         end;
      end;
   end;

   //--------------------------------------------------------------
   Function GetField( n : Byte ): ShortString;
   Var
      S : ShortString;
      Starts : Byte;
      Len	 : Byte;
   Begin
      Result := '';
      if n <= 0 then
         Exit;

      Starts := fStart[ n ];
      Len	 := fLen[ n ];
      If ( Starts > 0 ) and ( Len > 0 ) then
      Begin
         S[0] := Char( Len );
         Move( L[Starts], S[1], Len );
         Result := S;
      end;
   end;
   //--------------------------------------------------------------
   Function GSTCodesInChart( ChtFileName : String ): Boolean;
   var
      F          : TextFile;
      B          : array[ 1..8192 ] of Byte;
      S          : ShortString;
   Begin
      Result := False;
      try
         AssignFile( F, FileName );
         SetTextBuf( F, B );
         Reset( F );

         while not EOF( F ) do begin
            Readln( F, L );
            FindFields;
            if fCount >= 8 then begin
               S := GetField(colRowType);
               //look at acct header line to see if contains TAXCODE field
               if S = '!ACCNT' then begin
                  S := GetField(colTax);
                  if S <> 'TAXCODE' then begin
                     colTax := 0;
                     Exit;
                  end;
               end;
               //read subsequent lines to see if tax code field is used
               if S='ACCNT' then begin
                  S := GetField(colTax);
                  if S <> '' then begin
                     result := true;
                     exit;
                  end;
               end;
            end;
         end;
      finally
         CloseFile( F );
      end;
   end;
   //--------------------------------------------------------------

Var
   F          : TextFile;
   B          : array[ 1..8192 ] of Byte;
   ACode      : Bk5CodeStr;
   ADesc      : string[50];
   AGSTCode   : ShortString;
   AChart     : TChart;
   OK         : Boolean;
   Msg	     : string;
   S			  : ShortString;
   NewAccount : pAccount_Rec;
   i          : Byte;
   TemplateFileName : string;
   TemplateError : TTemplateError;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not BKFileExists( FileName ) then begin
      Msg := Format( 'The file %s does not exist', [ FileName ] );
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
      Raise ERefreshFailed.Create( Msg );
   end;

   case MyClient.clFields.clCountry of
   whAustralia : if GSTCodesInChart(FileName)
                 and not (MyClient.GSTHasBeenSetup) then begin
                    TemplateFileName := GLOBALS.TemplateDir + 'QUICKBKS.TPM';
                    If BKFileExists( TemplateFileName ) then
                       Template.LoadTemplate( TemplateFilename, tpl_DontCreateChart, TemplateError );
                 end;

   whUK: colTax := 0;
   end;

   OK     := False;
   AChart := TChart.Create(MyClient.ClientAuditMgr);
   Try
      Try
         AssignFile( F, FileName );
         SetTextBuf( F, B );
         Reset( F );

         while not EOF( F ) do Begin
            Readln( F, L );
            FindFields;
            if fCount >= colCode then
            Begin
               S := GetField(colRowType);
               if S='ACCNT' then begin
                  ACode := GetField(colCode);
                  ADesc := GetField(colName);
                  AGSTCode := GetField(colTax);

                  if (ACode<>'')
                  and (ADesc<>'') then
                  Begin
                     if (AChart.FindCode(ACode)<> nil) then Begin
                        LogUtil.LogMsg( lmError, UnitName, format('Duplicate Code %s found in %s',[ACode, FileName]));
                     end else Begin
                        NewAccount := New_Account_Rec;
                        with NewAccount^ do begin
                           chAccount_Code        := aCode;
                           chAccount_Description := aDesc;
                           chGST_Class           := GSTCalc32.GetGSTClassNo( MyClient, AGSTCode );
                           chPosting_Allowed     := true;

                           S := GetField(colAccType);
                           for i := qbTypeMin to qbTypeMax do begin
                              if SameText(S,StdTypeNames[i]) then begin
                                 chAccount_Type := stdTypeCodes[i];
                                 break; // Howmany can match...
                              end;
                           end;

                        end;
                        AChart.Insert(NewAccount);
                     end;
                  end;
               end;
            end;
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

   if Assigned(AChart)
   and (AChart.ItemCount = 0) then
   Begin
      AChart.Free;
      Msg := Format(TProduct.BrandName + ' couldn''t find any accounts in the file %s', [ FileName ] );
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
      raise ERefreshFailed.Create( Msg );
   end;      
   
   Result := AChart;
   
   if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;

const
   ThisMethodName    = 'RefreshChart';
var
   QBWFileName       : String;
   ChartFilePath     : string;
   NewChart          : TChart;
   Msg               : string;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not Assigned( MyClient ) then exit;
   
   with MyClient.clFields do begin
   
      QBWFileName := clLoad_Client_Files_From;

      if DirectoryExists(QBWFileName) then // User only specified a directory - we need a filename
      begin
        QBWFileName := '';
        ChartFilePath := AddSlash(clLoad_Client_Files_From);
      end
      else
        ChartFilePath := RemoveSlash(clLoad_Client_Files_From);

      if not BKFileExists( QBWFileName ) then
      Begin
         QBWFileName := ChartUtils.GetChartFileName(
            clCode,
            ExtractFilePath(ChartFilePath),
            'QuickBooks Files|*.IIF',
            'IIF',
             0 );
         if QBWFileName = '' then Exit;
      end;
      
      try
         NewChart := LoadQBWChart( QBWFileName );
         MergeCharts( NewChart, MyClient); { Frees NewChart }
         clLoad_Client_Files_From := QBWFileName;
         clChart_Last_Updated     := CurrentDate;
         
         HelpfulInfoMsg( 'The client''s chart of accounts has been refreshed.', 0 );
         
      except
         on E : ERefreshFailed do begin
            Msg := Format( 'Error refreshing chart %s.', [ QBWFileName] );
            LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
            HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.', 0, False, E.Message, True);
            exit;
         end;
         on E : EInOutError do begin //Normally EExtractData but File I/O only
            Msg := Format( 'Error refreshing chart %s.', [ QBWFileName] );
            LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
            HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.', 0, False, E.Message, True);
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

