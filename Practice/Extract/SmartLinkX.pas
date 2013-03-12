unit SmartLinkX;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; SaveEntriesTo : String );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils, Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, YesNoDlg,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, StStrS, StDateSt, SysUtils,
     InfoMoreFrm, baUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'SmartLinkX';
   DebugMe  : Boolean = False;
   
TYPE
   c13  = Array[1..13] of Char;

   DiskIDRecType = packed Record  { 128 Bytes }
      DiskID     : Array[1..11] of Char;
      CustCode   : Array[1..20] of Char;
      CustName   : Array[1..30] of Char;
      CreateDate : Array[1.. 6] of Char;
      DataType   : Char;  { 0 at present }
      Spare      : Array[1..60] of Char;
   End;

   AcctDirRecType = packed Record  { 128 Bytes }
      AcctCode    : Array[1..20] of Char;
      AcctName    : Array[1..30] of Char;
      DateFT      : Array[1.. 6] of Char;
      DateLT      : Array[1.. 6] of Char;
      Number      : c13;
      Nett        : c13;
      Spare2      : Array[1..40] of Char;
   End;

   DiskDirRec     = packed Record
      IDInfo      : DiskIDRecType;
      DirInfo     : Array[1..15] of AcctDirRecType;
   end;

   TranRecType = packed Record
     Case Char OF
        ' ' : ( Outline : packed Record
                             RecType : Char;
                             Spare   : Array[1..83] of Char;
                          end; );
        'A' : ( Header  : packed Record
                             RecType        : Char;            {A}
                             AcctNumber     : Array[1..20] of Char;
                             AcctName       : Array[1..30] of Char;
                             Spare          : Array[1..33] of Char;
                          end; );
        'B' : ( Tran    : packed Record
                             RecType        : Char;            {B}
                             TranCode       : Byte;
                             Amount         : c13;
                             Reference      : Array[1..12] of Char;
                             Particulars    : Array[1..12] of Char;
                             Analysis       : Array[1..12] of Char;
                             PostDate       : Array[1..6] of Char;
                             OrigBB         : Array[1..6]  of Char;
                             InputSource    : Byte;
                             OtherParty     : Array[1..20] of Char;
                          end; );
        'C' : ( Tail    : packed Record
                             RecType        : Char;            {C}
                             Debit          : c13;
                             Credit         : c13;
                             Nett           : c13;
                             Grand          : c13;
                             Number         : c13;
                             Spare          : Array[1..18] of Char;
                          end; );
     end;

   PByte = ^Byte;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure Encrypt( PPlainText : PByte;  Lgth : Integer );

   Const
      Key  : String[8] = 'Banklink';
      Mask : Byte = $80;
   Var
      Cypher : Array[0..( Sizeof( Key ) -1 )] of Byte;
   Var
      i,j : Integer;
      b   : Byte;
   Begin
      Move( Key[1], Cypher, SizeOf( Cypher ) );
      j := 0;
      For i := 0 to ( Lgth - 1 ) do begin
         b := PPlainText^;
         If not ( b = Ord( ' ' ) ) then begin
            b := b xor Cypher[j];
            b := b or Mask;
         End;
         PPlainText^ := b;
         Inc( PPlainText );
         Inc( j );
         j := j mod ( Sizeof( Key ) -1 );
      End;
   End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure AmttoC13( Amount : Money; VAR Result:c13 );

Var
   S : String[13];
   i : Byte;
Begin
   Str( Abs( Amount ):13:0, S );
   For i := 1 to 13 do If S[i]=' ' then S[i] := '0';
   If Amount < 0 then S[1] := '-';
   Move( S[1], Result, 13 );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function Min( A, B : Byte ): Byte;
Begin
   If A<B then Min:=A else Min:=B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

VAR
   NoOfAccounts      : Word;
   NoOfEntries       : LongInt;
   ECount            : LongInt;
   CrValue           : Money;
   DrValue           : Money;
   DF,DL             : TStDate;
   ID                : DiskDirRec;
   DataFile          : File of TranRecType;
   DataFileName      : String[12];
   TranRec           : TranRecType;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoAccountHeader ;

const
   ThisMethodName = 'DoAccountHeader ';

var
  ac: string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   DF          := 0;
   DL          := 0;
   ECount      := 0;
   CrValue     := 0;
   DrValue     := 0;
   Inc( NoOfAccounts );
   With Bank_Account.baFields do
   Begin
      With ID.DirInfo[ NoOfAccounts ] do
      Begin
         ac := StripM(Bank_Account);
         Move( ac[1], AcctCode[1], Min( Length( ac ), Sizeof( AcctCode ) ) );
         Move( baBank_Account_Name[1], AcctName[1], Min( Length( baBank_Account_Name ), Sizeof( AcctName ) ) );
      end;

      With TranRec.Header do
      Begin
         FillChar( TranRec, Sizeof( TranRec ), 32 );
         RecType := 'A';
         ac := StripM(Bank_Account);
         Move( ac[1], AcctNumber[1], Min( Length( ac ), Sizeof( AcctNumber ) ) );
         Move( baBank_Account_Name[1], AcctName[1], Min( Length( baBank_Account_Name ), Sizeof( AcctName ) ) );
      end;

      Encrypt( @TranRec, Sizeof( TranRec ) );
      Write( DataFile, TranRec );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction ;
const
   ThisMethodName = 'DoTransaction';
Var
   S : String[80];
   sOther : String[20];
   sPart  : string[12];
   Narration: string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With Transaction^ do
   Begin
      txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(txDate_Effective);
      
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...
         
      If ( txFirst_Dissection=nil ) then
      Begin
         FillChar( TranRec, Sizeof( TranRec ), 32 );
         With TranRec.Tran do
         Begin
            Narration := Copy( GetNarration(TransAction,Bank_Account.baFields.baAccount_Type), 1, GetMaxNarrationLength);
            RecType := 'B';
            TranCode:= txType;
            Amttoc13( txAmount, Amount );
            S := GetReference(TransAction,Bank_Account.baFields.baAccount_Type);
            Move( S[1], Reference[1], Length( S ) );
            sPart := Copy( Narration, 21, 12);
            Move( sPart[1], Particulars[1], Length( sPart ) );
            S := Date2Str( txDate_Effective, 'ddmmyy' ); Move( S[1],PostDate,6 );
            Move( txAnalysis[1], Analysis[1], Length( txAnalysis ) );
            Move( txAccount[1], OrigBB[1], Min( Length( txAccount ), Sizeof( OrigBB ) ) );
            InputSource := txSource;
            sOther := Copy( Narration, 1, 20);
            Move( sOther[1], OtherParty[1], Length( sOther ) );
         end;
         Encrypt( @TranRec, Sizeof( TranRec ) );
         Write( DataFile, TranRec );
         Inc( ECount );
      end;
      If ( DF=0 ) or ( txDate_Effective<DF ) then DF := txDate_Effective;
      If txDate_Effective>DL then DL:= txDate_Effective;
      If txAmount<0 then
         CrValue:=CrValue + txAmount
      else
         DrValue:=DrValue + txAmount;

      Inc( NoOfEntries );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissection ;

const
   ThisMethodName = 'DoDissection';

Var
   S : String[40];

Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With Transaction^, Dissection^ do
   Begin
      FillChar( TranRec, Sizeof( TranRec ), 32 );
      With TranRec.Tran do
      Begin
         RecType := 'B';
         TranCode:= txType;
         Amttoc13( dsAmount, Amount );
         s := getDsctReference(Dissection,Transaction,Bank_Account.baFields.baAccount_Type);
         Move( s[1], Reference[1], Min (Length(s), Sizeof(Reference)) );
         S := Date2Str( txDate_Effective, 'ddmmyy' ); Move( S[1],PostDate,6 );
         Move( txAnalysis[1], Analysis[1], Length( txAnalysis ) );
         Move( dsAccount[1], OrigBB[1], Min( Length( dsAccount ), Sizeof( OrigBB ) ) );
         InputSource := txSource;
         S := Copy(dsGL_Narration, 1, GetMaxNarrationLength);
         Move( S[1], OtherParty[1], Min( Length( S ), Sizeof( OtherParty ) ) );
      end;
      Encrypt( @TranRec, Sizeof( TranRec ) );
      Write( DataFile, TranRec );
      Inc( ECount );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoAccountTrailer ;

const
   ThisMethodName = 'DoAccountTrailer';
   
Var
   S : String[20];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   FillChar( TranRec, Sizeof( TranRec ), 32 );
   With TranRec.Tail do
   Begin
      RecType := 'C';
      AmttoC13( DrValue                ,Debit );
      AmttoC13( Abs( CrValue )         ,Credit );
      AmttoC13( DRValue+CrValue        ,Nett  );
      AmttoC13( DRValue+Abs( CRValue ) ,Grand );
      AmttoC13( 100*ECount             ,Number );
   end;
   Encrypt( @TranRec, Sizeof( TranRec ) );
   Write( DataFile, TranRec );
   
   With ID.DirInfo[ NoOfAccounts ] do
   Begin
      S := Date2Str( DF, 'ddmmyy' );  Move( S[1],DateFT,6 );
      S := Date2Str( DL, 'ddmmyy' );  Move( S[1],DateLT,6 );
      AmttoC13( 100*NoOfEntries, Number );
      AmttoC13( DRValue+CRValue ,Nett );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; SaveEntriesTo : String );

const
   ThisMethodName = 'ExtractData';
var
   IDFile       : File of DiskDirRec;
   IDFileName   : String[20];
   S            : ShortString;   

   Msg          : String; 
   Selected     : TStringList;
   BA           : TBank_Account;
   No           : Integer;
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [SmartLink format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );
   
   Selected  := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
   If Selected = NIL then exit;

   Try
      with MyClient.clFields do
      begin
            
         for No := 0 to Pred( Selected.Count ) do
         Begin
            BA := TBank_Account( Selected.Objects[ No ] );
            With BA.baFields do
            Begin
               if TravUtils.NumberAvailableForExport( BA, FromDate, ToDate  )= 0 then
               Begin
                  HelpfulInfoMsg( 'There aren''t any new entries to extract from "'+baBank_Account_Number+'" in this date range!', 0 );
                  exit;
               end;
            end;
         end;

         IDFileName    := SaveEntriesTo + 'ID'; 
         DataFileName  := SaveEntriesTo + 'DATA';
         
         Assign( IDFile, IDFileName );
         Rewrite( IDFile );

         Try
           Assign( DataFile, DataFileName );
           Rewrite( DataFile );

           Try
              Inc( clLast_Batch_Number );
              FillChar( ID, Sizeof( ID ), $20 );
              With ID.IdInfo do
              Begin   {12345678901}
                 Str( clLast_Batch_Number, S );
                 While Length( S )<11 do S := '0'+S;
                 Move( S[1], DiskID[1], Length( S ) );
                 S := clCode   ; Move( S[1], CustCode  , Length( S ) );
                 S := clName   ; If Length( S )>30 then S[0]:=#30;  Move( S[1], CustName  , Length( S ) );
                 S := Date2Str( CurrentDate, 'ddmmyy' ); Move( S[1], CreateDate, Length( S ) );
                 DataType:='0';
              end;

              NoOfEntries := 0;
              NoOfAccounts     := 0;
             
              for No := 0 to Pred( Selected.Count ) do
              Begin
                 BA := TBank_Account( Selected.Objects[ No ] );
                 TRAVERSE.Clear;
                 TRAVERSE.SetSortMethod( csDateEffective );
                 TRAVERSE.SetSelectionMethod( TRAVERSE.twAllNewEntries );
                 TRAVERSE.SetOnAHProc( DoAccountHeader );
                 TRAVERSE.SetOnEHProc( DoTransaction );
                 TRAVERSE.SetOnDSProc( DoDissection );
                 TRAVERSE.SetOnATProc( DoAccountTrailer );
                 TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
              end;
              write( IDFile, ID );
              OK := True;
           finally
              System.Close( DataFile );
           end;

         finally
           System.Close( IDFile );
         end;

         if OK then
         Begin
            Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved',[ NoOfEntries ] );
            LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
            HelpfulInfoMsg( Msg, 0 );
         end;
      end; { Scope of MyClient }
   finally
      Selected.Free;            
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

