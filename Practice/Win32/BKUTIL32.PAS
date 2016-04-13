Unit BKUTIL32;

{  -----------------------------------------------------------------------  }
interface uses BKDEFS,MONEYDEF, BKCONST, clObj32, PayeeObj, StDate;
{  -----------------------------------------------------------------------  }

function IsCoded( CONST T : pTransaction_Rec): Boolean; overload;
function IsCoded( aClient : TClientObj; CONST T : pTransaction_Rec): Boolean; overload;
Function IsCoded( aClient : TClientObj; CONST T : pTransaction_Rec; var HasUnCodedGST:Boolean): Boolean; overload;

function IsUncoded( CONST T : pTransaction_Rec ): Boolean; overload;
function IsUncoded( aClient : TClientObj; CONST T : pTransaction_Rec ): Boolean; overload;
function IsGSTUncoded( CONST T : pTransaction_Rec): Boolean; overload;

function DissectionMatchesPayee( bkPayee : PayeeObj.TPayee; pT : bkDefs.pTransaction_Rec) : boolean;

procedure GetPracticeContactDetails( aClient : TClientObj;
                                     var aName,
                                         aPhone,
                                         aEmail,
                                         aWebSite : string);

// The following routines operate on GLOBALS.MyClient
function GetTransCoreID( P : pTransaction_Rec ) : Int64;
function MakeSortKey( P : pTransaction_Rec ; SortMethod : Byte ): ShortString;
function GetChequeNo(T : pTransaction_Rec ): LongInt;

procedure SetOrClearTransferFlags( const SetFlags : Boolean;
                                   const FromDate, ToDate : integer;
                                   const AccountTypes : SetOfBytes;
                                   var HasEntriesInPeriod : boolean); overload;


procedure SetOrClearTransferFlags( var aClient : TClientObj;
                                   const SetFlags : Boolean;
                                   const FromDate, ToDate : integer;
                                   const AccountTypes : SetOfBytes;
                                   var HasEntriesInPeriod : boolean);overload;

procedure DeleteNotesForPeriod;

// The following routines operate on GLOBALS.MyClient

function HasAChart: Boolean;
function HasPayees: Boolean;
function HasBudgets: Boolean;
function HasAccounts: Boolean;
function HasJobs : boolean;
function CountBankAccounts : Integer;
function CountManualBankAccounts : Integer;
function CountDeliveredBankAccounts : Integer;
function ClientHasUncodedTransactions(D1, D2: Integer): Boolean;
function IsValidGSTAccountType(const AccountType: integer; const aClient: TClientObj): boolean;
procedure CountCodedGSTTrans(const aClient: TClientObj; D1, D2: TstDate; var Number,
                             Number_Uncoded: LongInt; DatePresented: boolean = True);
function HasOnlyJournalAccounts : Boolean;
function HasEntries: Boolean;
function HasJournals : Boolean;
function HasExceptions: Boolean;
function HasExceptionsSilent: Boolean;

{  -----------------------------------------------------------------------  }

Function UDMoney( U, D : Money ): String;
Function UDPercent( U, D : Money ): String;

{  -----------------------------------------------------------------------  }

implementation
{  -----------------------------------------------------------------------  }

uses
   GLOBALS,
   baObj32,
   BK5Except,
   GenUtils,
   sysutils,
   gstcalc32,
   cautils,
   infoMorefrm,
   LogUtil,
   classes,
   Math,
   StStrs, CodeDateDlg, UpdateMF, CodingFormCommands, bkhelp, ForexHelpers,
   BKDateUtils;

Const
   UnitName = 'BKUtil32';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function IsCoded( aClient : TClientObj; CONST T : pTransaction_Rec ; var HasUncodedGST:Boolean): Boolean; overload;
Const
   ThisMethodName = 'IsCoded';
Var
   OK       : Boolean;
   DS       : pDissection_Rec;
   IsActive : boolean;
Var
   Msg : String;
Begin
  HasUncodedGST := False;
   IsActive := True;
   If not Assigned( aClient) Then
   Begin
      Msg := 'aClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);

      raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName, Msg]);
   end ;

   With aClient, T^ do
   Begin
      If txFirst_Dissection<>NIL then
      Begin
         OK := TRUE;
         DS := txFirst_Dissection;
         While ( DS<>NIL ) and OK do With DS^, aClient.clFields do
         Begin
            OK := aClient.clChart.CanCodeTo( dsAccount, IsActive );

            //check CA systems GST Range
            if IsCASystems( aClient) and (not CASystemsGSTOK( aClient, dsGST_Class)) then
            begin
              ok := false;
              HasUncodedGST := True;
            end;
            DS := dsNext;
         end;
      end
      else
      with aClient.clfields do  Begin
         OK := aClient.clChart.CanCodeTo( txAccount, IsActive );

         //check CA Systems GST Range
         if IsCASystems( aClient) and (not CASystemsGSTOK( aClient, txGST_Class)) then
         begin
           ok := false;
           HasUncodedGST := True;
         end;
      end;
      Result := OK;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsUncoded( aClient : TClientObj; CONST T : pTransaction_Rec): Boolean; overload;
begin
   result := not ( IsCoded( aClient, T));
end;

function IsGSTUncoded( CONST T : pTransaction_Rec): Boolean; overload;
var
  HasUnCodedGST : Boolean;
begin
  HasUnCodedGST := False;
  IsCoded( MyClient, T,HasUnCodedGST);
  Result := HasUnCodedGST;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsCoded( CONST T : pTransaction_Rec): Boolean; overload;
//if no client is specified then use the myclient object
begin
  Result := IsCoded( MyClient, T);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsCoded(aClient : TClientObj; CONST T : pTransaction_Rec): Boolean; overload;
Const
   ThisMethodName = 'IsCoded';
Var
   OK       : Boolean;
   DS       : pDissection_Rec;
   IsActive : boolean;
Var
   Msg : String;
Begin
   IsActive := True;
   If not Assigned( aClient) Then
   Begin
      Msg := 'aClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);

      raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName, Msg]);
   end ;

   With aClient, T^ do
   Begin
      If txFirst_Dissection<>NIL then
      Begin
         OK := TRUE;
         DS := txFirst_Dissection;
         While ( DS<>NIL ) and OK do With DS^, aClient.clFields do
         Begin
            OK := aClient.clChart.CanCodeTo( dsAccount, IsActive );

            //check CA systems GST Range
            if IsCASystems( aClient) and (not CASystemsGSTOK( aClient, dsGST_Class)) then ok := false;
            DS := dsNext;
         end;
      end
      else
      with aClient.clfields do  Begin
         OK := aClient.clChart.CanCodeTo( txAccount, IsActive );

         //check CA Systems GST Range
         if IsCASystems( aClient) and (not CASystemsGSTOK( aClient, txGST_Class)) then ok := false;
      end;
      Result := OK;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function IsUncoded( CONST T : pTransaction_Rec): Boolean; overload;
//if no client is specified then use the myclient object
Begin
   result := Not( IsCoded( T) );
end;

function IsUncoded( CONST T : pTransaction_Rec; var HasUnCodedGST:Boolean ): Boolean; overload;
//if no client is specified then use the myclient object
Begin
   Result := Not( IsCoded(MyClient, T , HasUnCodedGST) );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DissectionMatchesPayee( bkPayee : PayeeObj.TPayee; pT : bkDefs.pTransaction_Rec) : boolean;
//matches the lines in the dissection with the lines in the payee.
//the match is done on account
var
  D : bkDefs.pDissection_Rec;
  Line : integer;
  PayeeLine : bkdefs.pPayee_Line_Rec;
begin
  result := true;

  D := pT^.txFirst_Dissection;
  Line := 0;

  while ( D <> nil) do
    begin
      Inc( Line);
      D := D.dsNext;
    end;

  if Line = bkPayee.pdLines.ItemCount then
    begin
      D := pT^.txFirst_Dissection;
      for line := bkPayee.pdLines.First to bkPayee.pdLines.Last do
        begin
          PayeeLine := bkPayee.pdLines.PayeeLine_At( Line);
          if PayeeLine.plAccount <> D.dsAccount then
            begin
              result := false;
              exit;
            end;
          D := D.dsNext;
        end;
    end
  else
    result := false;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetChequeNo(T : pTransaction_Rec ): LongInt;
{
   Could possibly be deleted but is called by FindCheques which is called
   by AddInitial and AddUnpresented.

   Have left it here so that there is no chance of duplicate cheques being added
   through Add UPC.  The routine will pickup any problems where a cheque type
   does not have a valid cheque number.

   Call if problems may be caused by txCheque_Number = 0
}
Const
   ThisMethodName = 'GetChequeNo';
Var
   S  : String[12];
   Msg : String;
Begin
   If not Assigned( MyClient) Then Begin
      Msg := 'MyClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   end ;

   Result := 0;
   With T^, MyClient.clFields do Case clCountry of
      whNewZealand :
         Begin
            If ( txType in [0,4..9] ) then begin
               if txCheque_Number <> 0 then
                  Result := txCheque_Number
               else begin
                  //is a cheque type but no number found, so try to guess from ref
                  S := Trim( txReference );
                  While Length( S ) > MaxChequeLength do System.Delete( S, 1, 1 );
                  Result := StrToIntSafe( S );
               end;
            end;
         end;
      whAustralia, whUK  :
         Begin
            If ( txType = 1 ) then begin
               if txCheque_Number <> 0 then
                  Result := txCheque_Number
               else begin
                  //is a cheque type but no number found, so try to guess from ref
                  S := Trim( txReference );
                  While Length( S ) > MaxChequeLength do System.Delete( S, 1, 1 );
                  Result := StrToIntSafe( S );
               end;
            end;
         end;
   end;
end;

{  -----------------------------------------------------------------------  }
function GetTransCoreID( P : pTransaction_Rec ) : Int64;
begin
  if assigned( P ) then
    Result := CombineInt32ToInt64( P^.txCore_Transaction_ID_High, P^.txCore_Transaction_ID )
  else
    Result := 0;
end;

{  -----------------------------------------------------------------------  }
Function MakeSortKey( P : pTransaction_Rec ; SortMethod : Byte ): ShortString;
{ Can now return a String up to 32 characters long }
Const
   ThisMethodName = 'MakeSortKey';
Var
   Code   : BK5CodeStr;
   SortCode : BK5SortStr;
   Msg    : string;
   Payee  : PayeeObj.TPayee;
   AccountRec : pAccount_Rec;
   ds: pDissection_Rec;
   total: Comp;
   i, j, IntCode, NumericCode: integer;
Begin
   If not Assigned( MyClient) Then
   Begin
      Msg := 'MyClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   end ;

   With P^ do
   Begin
      Case SortMethod of
         csDateEffective :
            MakeSortKey := LongToKey( txBank_Seq ) +
            LongToKey( txDate_Effective ) +
            LongToKey ( txSequence_No ); { 12 }

         csChequeNumber  :
            Begin
               Case MyClient.clFields.clCountry of
                  whNewZealand :
                     Begin
                        Case txType of
                           0, 3..9 :
                             Result := //LongToKey( txBank_Seq ) +
                                       ByteToKey( 1 ) +
                                       LongToKey( txCheque_Number ) +
                                       LongToKey( txDate_Effective ) +
                                       LongToKey ( txSequence_No ); {13}
                           else
                             Result := LongToKey( txBank_Seq ) +
                                       LongToKey( txDate_Effective ) +
                                       LongToKey ( txSequence_No );
                        end; { of Case txType }
                     end;
                  whAustralia, whUK :
                     Begin
                        Case txType of
                           1 :
                             Result :=
                               //LongToKey( txBank_Seq ) +
                               ByteToKey( 1 ) +
                               LongToKey( txCheque_Number ) +
                               LongToKey( txDate_Effective ) +
                               LongToKey( txSequence_No ); {13}
                           else
                             Result := LongToKey( txBank_Seq ) +
                                       LongToKey( txDate_Effective ) +
                                       LongToKey ( txSequence_No );
                        end; { of Case txType }
                     end;
               end; { of Case fdCountry }

            end;

         csReference :
           begin
             Code := Uppercase( Copy( GetFormattedReference( p), 1, MaxBk5CodeLen ) );
             while Length( Code ) < MaxBk5CodeLen Do
               Code := Code + ' ';

             Result := LongToKey( txBank_Seq ) +
                       Code +
                       LongToKey( txDate_Effective ) +
                       LongToKey( txSequence_No );;
           end;

         csDatePresented :
           MakeSortKey :=
             LongToKey( txBank_Seq ) +
             LongToKey( txDate_Presented ) +
             LongToKey( txDate_Effective ) +
             LongToKey( txSequence_No ); {12}

         csAccountCode, csAccountCodeXLON :
            Begin
              If ( txFirst_Dissection<>NIL ) then Code := 'þ' else Code := txAccount;
              While Length( Code ) < MaxBK5CodeLen Do Code := Code + ' ';
              result := Code + { !! 42.50 }
                LongToKey( txDate_Effective ) +
                LongToKey( txBank_Seq ) +
                LongToKey( txSequence_No ); {32} { was 22}
            end;

         csByValue       :
            Begin
               result :=  LongToKey( txBank_Seq ) +
//                               LongToKey( Trunc( txAmount ) ) +
                               LongToKey( Trunc( Local_Amount ) ) +
                               LongToKey( txDate_Effective ) +
                               LongToKey( txSequence_No ); {16}
            end;

         csByNarration :
            Begin
               SortCode := Uppercase( Copy( txGL_Narration, 1, Length(txGL_Narration) ) );
               While Length( SortCode ) < MaxSortLength Do SortCode := SortCode + #32;
               MakeSortKey :=    LongToKey( txBank_Seq ) +
                                 SortCode +
                                 LongToKey( txDate_Effective ) +
                                 LongToKey( txSequence_No ); {32} {was 22}
            end;

         //mjch Apr 2002 - allow different sorting in CES

         csByOtherParty : begin
               Code := Uppercase( Copy( txOther_Party, 1, MaxBk5CodeLen ) );
               While Length( Code ) < MaxBk5CodeLen Do Code := Code + ' ';
               MakeSortKey :=    LongToKey( txBank_Seq ) +
                                 Code +
                                 LongToKey( txDate_Effective ) +
                                 LongToKey( txSequence_No ); {32} {was 22}
         end;

         csByParticulars : begin
              Code := Uppercase( Copy( txParticulars, 1, MaxBk5CodeLen ) );
               While Length( Code ) < MaxBk5CodeLen Do Code := Code + ' ';
               MakeSortKey :=    LongToKey( txBank_Seq ) +
                                 Code +
                                 LongToKey( txDate_Effective ) +
                                 LongToKey( txSequence_No ); {32} {was 22}
         end;

         csByStatementDetails : begin
               SortCode := Uppercase( Copy( txStatement_Details, 1, Length(txStatement_Details) ) );
               While Length( SortCode ) < MaxSortLength Do SortCode := SortCode + ' ';
               MakeSortKey :=    LongToKey( txBank_Seq ) +
                                 SortCode +
                                 LongToKey( txDate_Effective ) +
                                 LongToKey( txSequence_No ); {32} {was 22}
         end;

         csByDocumentTitle : begin
           if txDocument_Title <> '' then
             i := 0
           else
             i := 1;

             MakeSortKey :=      LongToKey( txBank_Seq) +
                                 LongToKey( i) +
                                 LongToKey( txDate_Effective) +
                                 LongToKey( txSequence_No); 
         end;

         csByEntryType : begin
               MakeSortKey :=    LongToKey( txBank_Seq ) +
                                 ByteToKey( txType) +
                                 LongToKey( txDate_Effective ) +
                                 LongToKey( txSequence_No ); {14}
         end;

         csByAnalysis : begin
               Code := Uppercase( Copy( txAnalysis, 1, MaxBk5CodeLen ) );
               While Length( Code ) < MaxBk5CodeLen Do Code := Code + ' ';
               MakeSortKey :=    LongToKey( txBank_Seq ) +
                                 Code +
                                 LongToKey( txDate_Effective ) +
                                 LongToKey( txSequence_No ); {32} {was 22}
         end;

         csByCodedBy : begin
               Code := Copy( cbNames[ txCoded_By], 1, MaxBk5CodeLen );
               While Length( Code ) < MaxBk5CodeLen Do Code := Code + ' ';
               MakeSortKey :=    LongToKey( txBank_Seq ) +
                                 Code +
                                 LongToKey( txDate_Effective ) +
                                 LongToKey( txSequence_No ); {32} {was 22}
         end;

         csByPayee : begin
              MakeSortKey :=    LongToKey( txBank_Seq ) +
                                LongToKey( txPayee_Number) +
                                LongToKey( txDate_Effective ) +
                                LongToKey( txSequence_No ); {16}
         end;

         csByPayeeName : begin
           if txPayee_Number = 0 then
             Code := ''
           else
           begin
             Payee := MyClient.clPayee_List.Find_Payee_Number( txPayee_Number);
             if Assigned( Payee) then
               Code := Copy( Payee.pdName, 1, MaxBk5CodeLen)
             else
               Code := 'Unknown';
           end;

           while Length( Code ) < MaxBk5CodeLen Do
               Code := Code + ' ';

           MakeSortKey := LongToKey( txBank_Seq) +
                          Code +
                          LongToKey( txDate_Effective ) +
                          LongToKey( txSequence_No );
         end;

         csByAccountDesc,
         csByAltChartcode : begin
           if txAccount = '' then
             Code := ''
           else if txFirst_Dissection <> nil then
             Code := '<Dissected>'
           else
           begin
             AccountRec := MyClient.clChart.FindCode( txAccount);
             if Assigned( AccountRec) then
                if SortMethod = csByAccountDesc then
                   Code := Copy( AccountRec.chAccount_Description, 1, MaxBk5CodeLen)
                else
                   Code := Copy( AccountRec.chAlternative_Code , 1, MaxBk5CodeLen)
             else
               Code := 'Unknown';
           end;

           while Length( Code ) < MaxBk5CodeLen Do
               Code := Code + ' ';

           MakeSortKey := LongToKey( txBank_Seq) +
                          Code +
                          LongToKey( txDate_Effective ) +
                          LongToKey( txSequence_No );
         end;

         csByGSTClass: begin
           Code := Uppercase( Copy( GetGSTClassCode( MyClient, txGST_Class), 1, MaxBk5CodeLen ) );
           //test for numeric
           Val(Code, IntCode, i);
           if i = 0 then
           begin
             MakeSortKey := LongToKey( txBank_Seq) +
                            LongToKey(IntCode) +
                            LongToKey(0) +
                            LongToKey( txDate_Effective ) +
                            LongToKey( txSequence_No );
           end
           else
           begin
             // does it start with a numeric
             j := 1;
             NumericCode := -1;
             while(j <= Length(Code)) do
             begin
               Val(Copy(Code, 1, j), IntCode, i);
               if i = 0 then
                 NumericCode := IntCode;
               Inc(j);
             end;
             if NumericCode > -1 then
             begin
               MakeSortKey := LongToKey( txBank_Seq) +
                              LongToKey(NumericCode) +
                              Copy(Code, j, Length(Code)) +
                              LongToKey( txDate_Effective ) +
                              LongToKey( txSequence_No );
             end
             else
             begin
               While Length( Code ) < MaxBk5CodeLen Do Code := Code + ' ';
               MakeSortKey := LongToKey( txBank_Seq) +
                              Code +
                              LongToKey( txDate_Effective ) +
                              LongToKey( txSequence_No );                              
             end;
           end;
         end;

         csByGSTAmount: begin
           if txFirst_Dissection = nil then
             MakeSortKey := LongToKey( txBank_Seq) +
                            LongToKey( Trunc(txGST_Amount)) +
                            LongToKey( txDate_Effective ) +
                            LongToKey( txSequence_No )
           else
           begin
             ds := txFirst_Dissection;
             total := 0;
             while (ds <> nil) do
             begin
               total := total + ds.dsGST_Amount;
               ds := ds.dsNext;
             end;
             MakeSortKey := LongToKey( txBank_Seq) +
                            LongToKey( Trunc(total)) +
                            LongToKey( txDate_Effective ) +
                            LongToKey( txSequence_No )
           end;
         end;

         csByQuantity: begin
           if txFirst_Dissection = nil then
             MakeSortKey := LongToKey( txBank_Seq) +
                            LongToKey( Trunc(txQuantity)) +
                            LongToKey( txDate_Effective ) +
                            LongToKey( txSequence_No )
           else
           begin
             ds := txFirst_Dissection;
             total := 0;
             while (ds <> nil) do
             begin
               total := total + ds.dsQuantity;
               ds := ds.dsNext;
             end;
             MakeSortKey := LongToKey( txBank_Seq) +
                            LongToKey( Trunc(total)) +
                            LongToKey( txDate_Effective ) +
                            LongToKey( txSequence_No )
           end;
         end;
         csByJob: begin
            if txFirst_Dissection = nil then begin
               Code := uppercase(txJob_Code);
            end else begin
               ds := txFirst_Dissection;
               while (ds <> nil) do begin
                 Code := uppercase(ds.dsJob_Code);
                 if Code > '' then
                    Break; // First one will do...
                 ds := ds.dsNext;
               end;
            end;
            {if Code = '' then //Blanks at the bottom...
               Code := '~~~~~~~';}
            while Length( Code ) < 8 do
               Code := Code + ' '; // make them all the same length
            MakeSortKey :=    Code +
                                 LongToKey( txBank_Seq ) +
                                 LongToKey( txDate_Effective ) +
                                 LongToKey( txSequence_No ); {32} {was 22}
         end;
         csByJobName: begin
            if txFirst_Dissection = nil then begin
               Code := uppercase(Copy(MyClient.clJobs.JobName( txJob_Code),1,MaxBk5CodeLen));
            end else begin
               ds := txFirst_Dissection;
               while (ds <> nil) do begin
                 Code := uppercase(Copy(MyClient.clJobs.JobName(ds.dsJob_Code),1,MaxBk5CodeLen));
                 if Code > '' then
                    Break; // First one will do...
                 ds := ds.dsNext;
               end;
            end;
            {if Code = '' then //Blanks at the bottom...
               Code := '~~~~~~~~~~';}
            while Length( Code ) < MaxBk5CodeLen do
               Code := Code + ' '; // make them all the same length
            MakeSortKey :=    Code +
                                 LongToKey( txBank_Seq ) +
                                 LongToKey( txDate_Effective ) +
                                 LongToKey( txSequence_No ); {32} {was 22}
         end;

         csByForexAmount       :
            Begin
               Result :=   LongToKey( txBank_Seq ) +
//                               LongToKey( Trunc( txForeign_Currency_Amount ) ) +
                               LongToKey( Trunc( txAmount ) ) +
                               LongToKey( txDate_Effective ) +
                               LongToKey( txSequence_No ); {16}
            end;

         csByForexRate       :
            Begin
               Result :=   LongToKey( txBank_Seq ) +   //DoubletoKey, does not work...
                               LongToKey( Trunc(   txForex_Conversion_Rate * 100000) ) +
                               LongToKey( txDate_Effective ) +
                               LongToKey( txSequence_No ); {22}
            end;
         csByTransId         :
            begin
               Result :=   inttostr(GetTransCoreID(P)) +
                           LongToKey( txBank_Seq ) +
                           LongToKey( txDate_Effective ) +
                           LongToKey ( txSequence_No ) ;
            end;
         csBySentToAndAcc    :
            begin
              if txTransfered_To_Online then
                i := 1
              else
                i := 0;


               Result :=   LongToKey( i ) +
                           LongToKey( txBank_Seq ) +
                           LongToKey( txDate_Effective ) +
                           LongToKey ( txSequence_No );
            end;
         csSuggestedMemCount    :
            begin
              Result :=    LongToKey( txSuggested_Manual_Count ) +
                           LongToKey( txSuggested_Mem_Index ) +
                           LongToKey( txDate_Effective ) +
                           LongToKey( txBank_Seq ) +
                           LongToKey( txSequence_No );
            end;

      else
         begin
            MakeSortKey := LongToKey( txBank_Seq ) +
            LongToKey( txDate_Effective ) +
            LongToKey ( txSequence_No ); { 12 }
         end;
      end; { of Case }
   end;
end;

{  -----------------------------------------------------------------------  }

Function HasAChart: Boolean;

Const
   ThisMethodName = 'HasAChart';
Begin
   Result := False;

   if not Assigned( MyClient) then
     Exit;

   if MyClient.clChart.itemCount > 0 then
      result := true
   else
      HelpfulInfoMsg('There are no chart codes set up for this client.',0);
end;

{  -----------------------------------------------------------------------  }

Function HasPayees: Boolean;

Const
   ThisMethodName = 'HasPayees';
Var
   Msg : String;
Begin
   If not Assigned( MyClient) Then
   Begin
      Msg := 'MyClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   end ;
   Result := False;
   if MyClient.clPayee_List.itemCount > 0 then
      result := true
   else
     HelpfulInfoMsg('There are no payees set up for this client.',0);
end;

{  -----------------------------------------------------------------------  }

Function HasExceptionsSilent: Boolean;
Var
   I : LongInt;
Const
   ThisMethodName = 'HasExceptionsSilent';
Var
   Msg : String;
Begin
   If not Assigned( MyClient) Then
   Begin
      Msg := 'MyClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   end ;

   result := FALSE;
   With MyClient.clChart do For I := 0 to Pred( itemCount ) do With Account_At( I )^ do
   Begin
      If ( chMoney_Variance_Up     <> 0 )  OR( chMoney_Variance_Down   <> 0 )  OR
         ( chPercent_Variance_Up   <> 0 )  OR( chPercent_Variance_Down <> 0 )  Then
      begin
         result := TRUE;
         exit;
      end;
   end;
end;

{  -----------------------------------------------------------------------  }

function HasExceptions : boolean;
begin
  result := HasExceptionsSilent;
  if not result then
    HelpfulInfoMsg('There are no exception criteria set up for this client.',0);
end;

{  -----------------------------------------------------------------------  }

Function HasBudgets: Boolean;

Const
   ThisMethodName = 'HasBudgets';
Var
   Msg : String;
Begin
   If not Assigned( MyClient) Then
   Begin
      Msg := 'MyClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   end ;

   result := FALSE;
   if MyClient.clBudget_List.itemCount > 0 then
     result := true
   else
     HelpfulInfoMsg('There are no budgets set up for this client.',0);
end;

{  -----------------------------------------------------------------------  }

function HasEntries: Boolean;
Var
   B : LongInt;
Const
   ThisMethodName = 'HasEntries';
Var
   Msg : String;
Begin
   If not Assigned( MyClient) Then
   Begin
      Msg := 'MyClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   end ;
   
   Result := FALSE;

   With MyClient.clBank_Account_List do
      For B := 0 to Pred( ItemCount ) do
         With Bank_Account_At( B ) do
            If baTransaction_List.itemCount > 0 then Result := TRUE;

   If not Result then
   Begin
      HelpfulInfoMsg( 'There are no transactions for this client.', 0 );
   end;
end;

{  -----------------------------------------------------------------------  }

function HasAccounts : boolean;

Const
   ThisMethodName = 'HasAccounts';
Var
   Msg : String;
Begin
   If not Assigned( MyClient) Then
   Begin
      Msg := 'MyClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   end ;
   Result := myClient.clBank_Account_List.ItemCount > 0 ;
   if not Result then
      HelpfulInfoMsg('There are no bank accounts set up for this client.', 0 );
end;


function HasJobs : boolean;
const
  ThisMethodName = 'HasJobs';
var
  Msg: string;
begin
   if not Assigned(MyClient) Then
   begin
      Msg := 'MyClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   end;
   Result := MyClient.clJobs.ItemCount > 0;
   if not Result then
    HelpfulInfoMsg('There are no jobs set up for this client.', 0);
end;

{  -----------------------------------------------------------------------  }

Function HasJournals : Boolean;
Var
   B : LongInt;
   SomeThere : Boolean;
Const
   ThisMethodName = 'HasJournals';
Var
   Msg : String;
Begin
   If not Assigned( MyClient) Then
   Begin
      Msg := 'MyClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   end ;
   SomeThere := FALSE;

   With MyClient.clBank_Account_List do
      For B := 0 to Pred( itemCount ) do
         With Bank_Account_At( B ) do
           If ( IsAJournalAccount ) and ( baTransaction_List.itemCount > 0 ) then
              SomeThere := TRUE;

   if not SomeThere then
     HelpfulInfoMsg('No journals have been entered for this client.',0);
   HasJournals := SomeThere;
end;

{ -----------------------------------------------------------------------  }
function HasOnlyJournalAccounts : Boolean;
var
  i,j : integer;
begin
  Result := False;
  j := 0;
  with MyClient.clBank_Account_List do begin
     for i := 0 to Pred( ItemCount ) do begin
        with Bank_Account_At( i ) do begin
           if IsAJournalAccount then begin
              Inc( j );
           end;
        end;
     end;
     if ( j = ItemCount ) then begin
        Result := True;
     end;
  end;
end;
{ -----------------------------------------------------------------------  }
function CountBankAccounts : Integer;
// Returns the number of Bank Accounts 
var
  i : integer;
begin
  Result := 0;
  with MyClient.clBank_Account_List do begin
     for i := 0 to Pred( ItemCount ) do begin
        with Bank_Account_At( i ) do begin
           if not IsAJournalAccount then begin
              Inc( Result );
           end;
        end;
     end;
  end;
end;
{ -----------------------------------------------------------------------  }
function CountManualBankAccounts : Integer;
// Returns the number of Manual Bank Accounts
var
  i : integer;
begin
  Result := 0;
  with MyClient.clBank_Account_List do begin
     for i := 0 to Pred( ItemCount ) do begin
        with Bank_Account_At( i ) do begin
           if IsManual then begin
              Inc( Result );
           end;
        end;
     end;
  end;
end;
{ -----------------------------------------------------------------------  }
function CountDeliveredBankAccounts : Integer;
// Returns the number of Delivered Bank Accounts
var
  i : integer;
begin
  Result := 0;
  with MyClient.clBank_Account_List do begin
     for i := 0 to Pred( ItemCount ) do begin
        with Bank_Account_At( i ) do begin
           if (not IsManual)
           and (not IsAJournalAccount) then
             Inc( Result );
        end;
     end;
  end;
end;
{ -----------------------------------------------------------------------  }
function ClientHasUncodedTransactions(D1, D2: Integer): Boolean;
var
  i, j: Integer;
  Uncoded: Boolean;
begin
  Result := False;
  with MyClient do
    for i := clBank_Account_List.First to clBank_Account_List.Last do
      with clBank_Account_List.Bank_Account_At(i) do
      begin
        if IsAJournalAccount then Continue;      
        for j := baTransaction_List.First to baTransaction_List.Last do
        begin
          if (baTransaction_List.Transaction_At(j).txDate_Effective < D1) or (baTransaction_List.Transaction_At(j).txDate_Effective > D2) then Continue;
          if clChart.itemCount > 0 then //check to see if a chart exists
            Uncoded := IsUncoded(baTransaction_List.Transaction_At(j))
          else
            Uncoded := (baTransaction_List.Transaction_At(j)^.txAccount = '');
          if Uncoded then
          begin
            Result := True;
            exit;
          end;
        end;
      end;
end;
{ -----------------------------------------------------------------------  }
Function UDMoney( U, D : Money ): String;
Var
   US, DS, RS : String[40];
   UL, DL : Double;
Begin
   UL := Round( U / 100.0 );
   DL := Round( D / 100.0 );

   US := ''; If U<>0 then US := formatFloat('#,##0;#,##0', UL);
   DS := ''; If D<>0 then DS := formatFloat('#,##0;#,##0', DL);
   RS := '';
   If US<>'' then
   Begin
      RS := '+' + US;
      If DS<>'' then RS := RS+' -'+DS;
   end
   else
   If DS<>'' then
      RS := '-'+DS;
   UDMoney := RS;
end;

{  -----------------------------------------------------------------------  }

Function UDPercent( U, D : Money ): String;
Var
   US, DS, RS : String[40];
Begin
   US := ''; If U<>0 then US := FormatFloat('#,##0.00;#.##0.00',U/100);
   DS := ''; If D<>0 then DS := FormatFloat('#,##0.00;#.##0.00',D/100);
   RS := '';
   If US<>'' then
   Begin
      RS := '+' + US+'%';
      If DS<>'' then RS := RS+' -'+DS+'%';
   end
   else
   If DS<>'' then
      RS := '-'+DS+'%';
   UDPercent := RS;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetOrClearTransferFlags( var aClient : TClientObj;
                                   const SetFlags : Boolean;
                                   const FromDate, ToDate : integer;
                                   const AccountTypes : SetOfBytes;
                                   var HasEntriesInPeriod : boolean);
//operates on aClient object
var
   pT : pTransaction_Rec;
   i  : integer;
   b  : integer;
   BA : TBank_Account;
   lTransferred: Integer;
   PeriodList: TDateList;
   PeriodIndex: Integer;
begin
   HasEntriesInPeriod := false;
   if SetFlags then // Ask only once
      lTransferred := CurrentDate //workout only once
   else
      lTransferred := 0;

   PeriodList := GetPeriodsBetween(FromDate, ToDate, True);

   with aClient do begin
      for b:= 0 to Pred( clBank_Account_List.ItemCount) do begin
         Ba := clBank_Account_List.Bank_Account_At( b);
         if Ba.baFields.baAccount_Type in AccountTypes then begin

            for i := 0 to Pred( Ba.baTransaction_List.ItemCount) do begin
               pT := BA.baTransaction_List.Transaction_At( i);

               if ( pT^.txDate_Effective >= FromDate) and ( pT^.txDate_Effective <= ToDate) then begin
                  //Clear or set the ForEx rate
                  if (not pT^.txLocked) then begin
                    if (lTransferred = 0) then
                      //Clear ForEx rate
                      pT^.txForex_Conversion_Rate := 0
                    else if (pT^.txDate_Transferred = 0)  then
                      //Set ForEx rate if txn has not already been transfered
                      pT^.txForex_Conversion_Rate := Ba.Default_Forex_Conversion_Rate(pT^.txDate_Effective);
                  end;
                  HasEntriesInPeriod := true;
                  pT^.txDate_Transferred := lTransferred;
               end;
            end;

            if SetFlags then
            begin
              for PeriodIndex := 0 to Length(PeriodList) - 1 do
              begin
                BA.baFinalized_Exchange_Rate_List.AddExchangeRate(PeriodList[PeriodIndex], Ba.Default_Forex_Conversion_Rate(PeriodList[PeriodIndex]));
              end;
            end;
         end; //if account type ok
      end;
   end;
end;

procedure SetOrClearTransferFlags( const SetFlags : Boolean;
                                   const FromDate, ToDate : integer;
                                   const AccountTypes : SetOfBytes;
                                   var HasEntriesInPeriod : boolean);
begin
   //operates on MyClient object
   SetOrClearTransferFlags(MyClient,SetFlags,FromDate,ToDate,AccountTypes,HasEntriesInPeriod);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure GetPracticeContactDetails( aClient : TClientObj; var aName, aPhone, aEmail, aWebSite : string);
begin
  //default is practice details
  aName  := aClient.clFields.clPractice_Name;
  aPhone := aClient.clFields.clPractice_Phone;
  aEmail := aClient.clFields.clPractice_EMail_Address;
  aWebSite := aClient.clFields.clPractice_Web_Site;

  case aClient.clFields.clContact_Details_To_Show of
    cdtStaffMember : begin
        if aClient.clFields.clStaff_Member_Name <> '' then
        begin
          //use the staff members details if specified
          aName := aClient.clFields.clStaff_Member_Name;

          if aClient.clFields.clStaff_Member_Direct_Dial <> '' then
            aPhone := aClient.clFields.clStaff_Member_Direct_Dial;

          if aClient.clFields.clStaff_Member_EMail_Address <> '' then
            aEmail := aClient.clFields.clStaff_Member_EMail_Address;
        end;
      end;

    cdtCustom : begin
        aName  := aClient.clFields.clCustom_Contact_Name;
        aPhone := aClient.clFields.clCustom_Contact_Phone;
        aEmail := aClient.clFields.clCustom_Contact_EMail_Address;
      end;
  end;

  //override web site if a client specific address is specified
  if aClient.clFields.clWeb_Site_Login_URL <> '' then
    aWebSite := aClient.clFields.clWeb_Site_Login_URL;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DeleteNotesForPeriod;
Var
   D1, D2 : LongInt;
   EntriesFound : boolean;
   pT : pTransaction_Rec;
   pD: pDissection_Rec;
   i, b  : integer;
   BA : TBank_Account;
Begin
  if not Assigned( MyClient ) then exit;
  with MyClient do
  begin
    D1 := clFields.clPeriod_Start_Date;
    D2 := clFields.clPeriod_End_Date;

    if not EnterDateRange( 'Delete all notes for a period',
            'Enter the starting and finishing date for the period you want to delete notes for.',
             D1, D2, BKH_Working_with_Notes, false, true ) then exit;

    //Clear transfer flags for all accounts and journals
    EntriesFound := false;

    with MyClient do
    begin
      for b:= 0 to Pred( clBank_Account_List.ItemCount) do
      begin
        BA := clBank_Account_List.Bank_Account_At( b);
        if BA.baFields.baAccount_Type in [btBank] then
        begin
          for i := 0 to Pred( BA.baTransaction_List.ItemCount) do
          begin
            pT := BA.baTransaction_List.Transaction_At( i);

            if ( pT^.txDate_Effective >= D1) and ( pT^.txDate_Effective <= D2) then
            begin
              if pT^.txNotes <> '' then
              begin
                pT^.txNotes := '';
                EntriesFound := true;
              end;

              if pT^.txFirst_Dissection <> nil then
              begin
                pD := pT^.txFirst_Dissection;
                while pD <> nil do
                begin
                  if pD^.dsNotes <> '' then
                  begin
                    pD^.dsNotes :=  '';
                    EntriesFound := true;
                  end;
                  pD := pD^.dsNext;
                end;
              end;
            end;
          end;
        end; //if account type ok
      end;
    end;

    if EntriesFound then
    begin
      SendCmdToAllCodingWindows( ecRefreshTable);
      HelpfulInfoMsg( 'The notes have been deleted.', 0);
    end
    else
      HelpfulInfoMsg( 'No notes that can be deleted, in this date range.', 0);
   end;
end;

function IsValidGSTAccountType(const AccountType: integer; const aClient: TClientObj): boolean;
begin
  Result := (AccountType in [btBank,btCashJournals,btGSTJournals]) or
            ((AccountType = btAccrualJournals) and (not aClient.clFields.clGST_Excludes_Accruals));
end;


procedure CountCodedGSTTrans(const aClient: TClientObj; D1, D2: TstDate; var Number,
  Number_Uncoded: LongInt; DatePresented: boolean = True);
var
  B,
  T: LongInt;
  pT: pTransaction_Rec;
  Ba: TBank_Account;
  TD: integer;
begin
  Number := 0;
  Number_Uncoded := 0;

  //count the number of transactions for in the period
  for b := aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do
  begin
    Ba := aClient.clBank_Account_List.Bank_Account_At(b);
    //see if this account should be included
    if IsValidGSTAccountType(Ba.baFields.baAccount_Type, aClient) then
    begin
      for t := ba.baTransaction_List.First to ba.baTransaction_List.Last do
      begin
        pT := ba.baTransaction_List.Transaction_At(t);
        if DatePresented then
          TD := pT^.txDate_Presented
        else
          TD := pT^.txDate_Effective;
        if ( TD >= D1 ) and ( TD <= D2 ) then
        begin
          Inc(Number);
          if IsUncoded(pT) then
            Inc( Number_Uncoded );
        end;
      end;
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
END.


