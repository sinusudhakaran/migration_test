unit HSBCDemo;

// ----------------------------------------------------------------------------
interface
// ----------------------------------------------------------------------------

procedure ImportHSBCDemoData;

// ----------------------------------------------------------------------------
implementation uses SyDefs, SysObj32, SysUtils, CSVParser, Classes,
  ErrorMoreFrm, ArchUtil32, StDateSt, bkDateUtils,
  Globals, Admin32, sysbio, BkConst, GenUtils;
// ----------------------------------------------------------------------------

procedure ImportHSBCDemoData;

const
  HSBCEntryFileName = 'HSBC_TX.TXT';
  HSBCBalFileName = 'HSBC_BAL.TXT';
var
  S: string;
  pSB: pSystem_Bank_Account_Rec;
  Parser: TCSVParser;
  F: TextFile;
  EntryFile : TextFile;
  Items: TStringList;
  D: Double;
  TxnFileName : String;
  ArchiveTxn        : tArchived_Transaction;
  ArchiveFile : File of TArchived_Transaction; { in ARCHUTIL32.pas }
  ChqNumberStr : String;
  Desc : String;
  p : Integer;
begin
  if not FileExists( HSBCEntryFileName ) or
    not FileExists( HSBCBalFileName ) then
  begin
    S := Format( 'Missing HSBC Files: %s or %s is unavailable', [
      HSBCEntryFileName, HSBCBalFileName ] ) ;
    HelpfulErrorMsg( S, 0 ) ;
    exit;
  end;

  if AdminExists then
  begin
    if LoadAdminSystem( true, 'Importing HSBC Sample Data' ) then
    begin
      AdminSystem.fdFields.fdCountry := whUK;

      Parser := TCSVParser.Create;
      Items := TStringList.Create;

      AssignFile( F, HSBCBalFileName ) ;
      {$I-} Reset( F ) ; {$I+}
      Readln( F, S ) ; // Skip Header
      while not EOF( F ) do
      begin
        Readln( F, S ) ;
        if S <> '' then
        begin
          Parser.ExtractFields( S, Items ) ;
          if Items.Count = 5 then
          begin
            pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode( Items[ 1 ] );
            if pSB = nil then
            begin
              pSB := New_System_Bank_Account_Rec;
              with pSB^ do
              begin
                sbAccount_Number := Items[ 1 ] ;
                sbAccount_Name := Items[ 0 ] ;
                sbCurrency_Code := Items[ 3 ] ;
                Inc( AdminSystem.fdFields.fdBank_Account_LRN_Counter ) ;
                sbLRN := AdminSystem.fdFields.fdBank_Account_LRN_Counter;
                if TryStrToFloat( Items[ 4 ] , D ) then
                  sbCurrent_Balance := -Double2Money( D ) ;
                sbNew_This_Month := TRUE;
                sbAttach_Required := TRUE; {very important}
                sbWas_On_Latest_Disk := true;
                sbAccount_Type := sbtData;
                AdminSystem.fdSystem_Bank_Account_List.Insert( pSB ) ;

                Assign( EntryFile, HSBCEntryFileName );
                {$I-} Reset( EntryFile ); {$I+}
                Readln( EntryFile, S ); // Skip Header
                while not EOF( EntryFile ) do
                Begin
                  Readln( EntryFile, S );
                  if ( S <> '' ) then
                  Begin
                    Parser.ExtractFields( S, Items );
                    if ( Items.Count = 7 ) and ( Items[ 0 ] = sbAccount_Number ) then
                    Begin
                      TxnFilename := ArchUtil32.ArchiveFileName( sbLRN );
                      if FileExists( TxnFilename) then
                      begin
                        AssignFile( ArchiveFile, TxnFilename);
                        Reset( ArchiveFile);
                        Seek( ArchiveFile, FileSize( ArchiveFile));
                      end
                      else
                      begin
                        AssignFile( ArchiveFile, TxnFilename);
                        Rewrite( ArchiveFile);
                      end;
                      FillChar( ArchiveTxn, SizeOf( ArchiveTxn ), 0);
                      With ArchiveTxn do
                      Begin
                        aRecord_End_Marker := ArchUtil32.ARCHIVE_REC_END_MARKER;

                        if TryStrToFloat( Items[ 3 ] , D ) then
                          aAmount := -Double2Money( D ) ;

                        if Items[ 6 ] = 'CHQ' then
                        Begin
                          aType := whChequeEntryType[ whUK ];
                          ChqNumberStr := Trim( Items[ 4 ] );
                          p := Pos( ' ', ChqNumberStr );
                          if p > 0 then ChqNumberStr := Copy( ChqNumberStr, 1, p-1 );
                          if Length( ChqNumberStr ) > MaxChequeLength then
                            ChqNumberStr := Copy( ChqNumberStr, (Length( ChqNumberStr ) - MaxChequeLength) + 1, MaxChequeLength);
                          aCheque_Number := Str2Long( ChqNumberStr );
                        End
                        Else
                          if Items[ 6 ] = 'CREDIT' then
                            aType := whDepositEntryType[ whUK ]
                          Else
                            if Items[ 6 ] = 'DEBIT' then
                              aType := whWithdrawalEntryType[ whUK ]
                            Else
                              if aAmount > 0 then
                                aType := whWithdrawalEntryType[ whUK ]
                              else
                                aType := whDepositEntryType[ whUK ];

                        aDate_Presented := Str2Date( Items[ 1 ], 'dd/mm/yyyy' );

                        Desc := Items[ 4 ];
                        p := Pos( '  ', Desc );
                        while ( p>1 ) do
                        Begin
                          System.Delete( Desc, p, 1 );
                          p := Pos( '  ', Desc );
                        End;
                        aStatement_Details := Desc;

                        Inc( AdminSystem.fdFields.fdTransaction_LRN_Counter);
                        aLRN := AdminSystem.fdFields.fdTransaction_LRN_Counter;
                        sbLast_Transaction_LRN := aLRN;

                        if ( sbFrom_Date_This_Month = 0 ) or ( aDate_Presented < sbFrom_Date_This_Month ) then
                          sbFrom_Date_This_Month := aDate_Presented;

                        if aDate_Presented > sbTo_Date_This_Month then
                          sbTo_Date_This_Month := aDate_Presented;

                        if aDate_Presented > sbLast_Entry_Date then
                          sbLast_Entry_Date := aDate_Presented;

                        Inc( sbNo_of_Entries_This_Month );
                      end;
                      Write( ArchiveFile, ArchiveTxn);
                      Close( ArchiveFile );
                    End;
                  End;
                End;
                CloseFile( EntryFile );
              end;
            end;
          end;
        end;
      end;
      CloseFile( F ) ;
      FreeAndNil( Items ) ;
      FreeAndNil( Parser ) ;
      SaveAdminSystem;
    end;
  end;
end;

end.

