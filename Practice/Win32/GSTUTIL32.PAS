unit GSTUTIL32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Calculates the gst totals from all transactions within a given date range

// Works on the MyClient global object !!!

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   MONEYDEF,
   globals,
   glConst,
   bkconst;

type
   TGSTInfo = record
      guWhichJournals   : Array[ btMin..btMax ] of Boolean;
      guHasJournals     : Boolean;
      guHasUncodes      : Boolean;
      guNumberUncoded   : Integer;
      guGross_Totals    : Array[ 0..MAX_GST_CLASS ] of Money;
      guNet_Totals      : Array[ 0..MAX_GST_CLASS ] of Money;
      guGST_Totals      : Array[ 0..MAX_GST_CLASS ] of Money;
      guHasActivity     : Array[ 0..MAX_GST_CLASS ] of Boolean;
      guAllLocked       : Boolean;
      guAllTransferred  : Boolean;
   end;

procedure Calculate12MthGSTTotals( PeriodStartDate, PeriodEndDate : array of LongInt;
                              var GSTTotals : array of Money;
                              ForClass : integer;
                              ForDivision : integer);
procedure CalculateGSTTotalsForPeriod( D1, D2 : LongInt; var Info : TGSTInfo; ForClass : integer);
procedure ApplyDefaultGST( IncludeEdited : boolean);

function HasActivity(const Value :TGSTInfo) : Boolean;
//******************************************************************************
implementation

uses
  BKDEFS,
  //BKBLIO,
  MemorisationsObj,
  GSTCalc32,
  LogUtil,
  PayeeObj, baObj32, ForexHelpers;


function HasActivity(const Value :TGSTInfo) : Boolean;
var I : Integer;
begin with value do begin
   Result := True;
   for I := Low(guHasActivity) to High(guHasActivity) do
      if Value.guHasActivity[i] then exit;
   if guHasJournals then exit;
   if guHasUncodes then exit;

   // Still here..
   Result := False;
end;end;

//------------------------------------------------------------------------------

procedure Calculate12MthGSTTotals( PeriodStartDate, PeriodEndDate : array of LongInt;
                              var GSTTotals : array of Money;
                              ForClass : integer;
                              ForDivision : integer);
var
  T, B            : LongInt;
  Dissection      : pDissection_Rec;
  AccountTypeOK   : boolean;
  PeriodID        : Integer;
  pAcct           : pAccount_Rec;
  DivisionOK      : boolean;
begin
  if not Assigned( MyClient ) then exit;

  With MyClient, clChart, clFields, clBank_Account_List do
  begin
    For B := 0 to Pred( ItemCount ) do
    begin
      with Bank_Account_At( B ), baFields do
      begin
        //check correct journal accounts are being used, exclude stock and opening journals
        AccountTypeOK := (baFields.baAccount_Type in [btBank,btCashJournals,btGSTJournals]) or
                        ((baFields.baAccount_Type = btAccrualJournals) and (not clGST_Excludes_Accruals));

        if AccountTypeOK then
        begin
          with baTransaction_List do
            for T := 0 to Pred( ItemCount ) do
              with Transaction_At( T )^ do
                for PeriodID := Low(PeriodStartDate) to High(PeriodStartDate) do
                begin
                  if ( ( clGST_on_Presentation_Date ) and ( txDate_Presented >= PeriodStartDate[PeriodID] ) and ( txDate_Presented <= PeriodEndDate[PeriodID] ) )
                   or ( ( not clGST_on_Presentation_Date ) and ( txDate_Effective >= PeriodStartDate[PeriodID] ) and ( txDate_Effective <= PeriodEndDate[PeriodID] ) ) then
                  begin
                    //transaction is in date range
                    if ( txFirst_Dissection = nil ) then
                    begin
                      //check division
                      DivisionOK := true;
                      if ForDivision <> 0 then
                      begin
                        pAcct  := MyClient.clChart.FindCode( txAccount);
                        if Assigned( pAcct) then
                          DivisionOK := ( pAcct^.chPrint_In_Division[ ForDivision ] );
                      end;

                      if DivisionOK then
                      begin
                         if ( txGST_Class = ForClass) or ( ( ForClass = -1) and ( txGST_Class in [0..MAX_GST_CLASS] )) then
                           GSTTotals[ PeriodID ] := GSTTotals [ PeriodID ] + txGST_Amount;
                      end;
                    end
                    else
                    begin
                      Dissection := txFirst_Dissection;
                      while ( Dissection<>nil ) do With Dissection^ do
                      begin
                        //check division
                        DivisionOK := true;
                        if ForDivision <> 0 then
                        begin
                          pAcct  := MyClient.clChart.FindCode( dsAccount);
                          if Assigned( pAcct) then
                            DivisionOK := ( pAcct^.chPrint_In_Division[ ForDivision ] );
                        end;

                        if DivisionOK then
                        begin
                          if ( dsGST_Class = ForClass) or ( ( ForClass = -1) and ( dsGST_Class in [0..MAX_GST_CLASS] )) then
                            GSTTotals[ PeriodID ] := GSTTotals[ PeriodID ] + dsGST_Amount;
                        end;

                        Dissection := dsNext;
                      end; { of While }
                    end;
                  end;
                end;
         end; //if account type ok
      end; //with
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure CalculateGSTTotalsForPeriod(  D1, D2 : LongInt; var Info : TGSTInfo; ForClass : integer );
//NOTE:  If called with ForClass = -1 the routine sums to gst for all classes

   procedure UpdateChart( CONST aCode : Bk5CodeStr; CONST Gross, Net, Tax : Money );
   Var
      Account         : pAccount_Rec;
   Begin
      With MyClient.clChart do
      Begin
         Account := FindCode( aCode );
         If Assigned( Account ) then With Account^ do
         Begin
            chGross := chGross + Gross;
            chNet   := chNet + Net;
            chTax   := chTax + Tax;
         end;
      end;
   end;


var
   T, B, I         : LongInt;
   Dissection      : pDissection_Rec;
   AccountTypeOK   : boolean;
   Gross, Net, Tax : Money;
begin
   with Info do
   begin
     FillChar( guWhichJournals, sizeof( guWhichJournals ), 0 );
     guHasUncodes         := FALSE;
     guHasJournals        := FALSE;
     guNumberUncoded      := 0;
     guAllLocked          := True;
     guAllTransferred     := True;
     FillChar( guGross_Totals  , Sizeof( guGross_Totals   ), 0 );
     FillChar( guNet_Totals    , Sizeof( guNet_Totals     ), 0 );
     FillChar( guGST_Totals    , Sizeof( guGST_Totals     ), 0 );
     FillChar( guHasActivity   , SizeOf( guHasActivity    ), 0 );

     if not Assigned( MyClient ) then exit;

     With MyClient.clChart do for I := 0 to Pred( ItemCount ) do With Account_At( I )^ do
     Begin
        chGross := 0;
        chNet   := 0;
        chTax   := 0;
     end;

     With MyClient, clChart, clFields, clBank_Account_List do For B := 0 to Pred( ItemCount ) do
        With Bank_Account_At( B ), baFields do
        begin
           //check correct journal accounts are being used, exclude stock and opening journals
           AccountTypeOK := (baFields.baAccount_Type in [btBank,btCashJournals,btGSTJournals]) or
                           ((baFields.baAccount_Type = btAccrualJournals) and (not clGST_Excludes_Accruals));

           if AccountTypeOK then
           begin
              With baTransaction_List do
                 For T := 0 to Pred( ItemCount ) do
                    With Transaction_At( T )^ do
                       if ( ( clGST_on_Presentation_Date ) and ( txDate_Presented >=D1 ) and ( txDate_Presented <=D2 ) )
                       OR ( ( not clGST_on_Presentation_Date ) and ( txDate_Effective >=D1 ) and ( txDate_Effective <=D2 ) ) then
                      begin
                         if IsAJournalAccount then guHasJournals := TRUE;
                            guWhichJournals[ baAccount_Type ] := TRUE;

                         if ( txFirst_Dissection = nil ) then
                         begin
                            if clChart.FindCode( txAccount ) = nil then begin
                               guHasUncodes := TRUE;
                               Inc(guNumberUncoded);
                            end;

                            if not TxLocked then
                               guAllLocked := False;

                            if (txDate_Transferred = 0) then
                               guAllTransferred := False;

                            if ( txGST_Class = ForClass) or ( ( ForClass = -1) and ( txGST_Class in [0..MAX_GST_CLASS] )) then
                            begin
//                               Gross := txAmount;
                               Gross := Local_Amount;
//                               Net   := ( txAmount - txGST_Amount );
                               Net   := ( Gross - txGST_Amount );
                               Tax   := txGST_Amount;

                               guGross_Totals [ txGST_Class ] := guGross_Totals [ txGST_Class ] + Gross;
                               guNet_Totals   [ txGST_Class ] := guNet_Totals   [ txGST_Class ] + Net;
                               guGST_Totals   [ txGST_Class ] := guGST_Totals   [ txGST_Class ] + Tax;
                               guHasActivity  [ txGST_Class ] := true;

                               UpdateChart( txAccount, Gross, Net, Tax );

                               //if we are only looking for a single class we do not need to add in the contra
                               //account entries, as these will never have a gst class associated with them
                               if ( ForClass = -1) then begin
                                  UpdateChart( baContra_Account_Code, -Gross, -Gross, 0 );
                                  //make sure not looking at the NO GST class.  This will not have an account attached so
                                  //don't try to store tax total
                                  if txGST_Class > 0 then
                                     UpdateChart( clGST_Account_Codes[ txGST_Class ], Tax, 0, Tax );
                               end;

                            end;
                         end
                         else
                         begin
                            Dissection := txFirst_Dissection;
                            While ( Dissection<>nil ) do With Dissection^ do
                            begin
                               if clChart.FindCode( dsAccount )=nil then begin
                                  guHasUncodes := TRUE;
                                  Inc(guNumberUncoded);
                               end;

                               if not txLocked then // transaction
                                  guAllLocked := False;

                               if (txDate_Transferred = 0) then
                                  guAllTransferred := False;

                               if ( dsGST_Class = ForClass) or ( ( ForClass = -1) and ( dsGST_Class in [0..MAX_GST_CLASS] )) then
                               begin
//                                  Gross := dsAmount;
                                  Gross := Local_Amount;
//                                  Net   := ( dsAmount - dsGST_Amount );
                                  Net   := ( Gross - dsGST_Amount );
                                  Tax   := dsGST_Amount;

                                  guGross_Totals [ dsGST_Class ] := guGross_Totals [ dsGST_Class ] + Gross;
                                  guNet_Totals   [ dsGST_Class ] := guNet_Totals   [ dsGST_Class ] + Net;
                                  guGST_Totals   [ dsGST_Class ] := guGST_Totals   [ dsGST_Class ] + Tax;
                                  guHasActivity  [ dsGST_Class ] := true;

                                  UpdateChart( dsAccount, Gross, Net, Tax );

                                  //if we are only looking for a single class we do not need to add in the contra
                                  //account entries, as these will never have a gst class associated with them
                                  if ( ForClass = -1) then begin
                                     UpdateChart( baContra_Account_Code, -Gross, -Gross, 0 );
                                     //make sure not looking at the NO GST class.  This will not have an account attached so
                                     //don't try to store tax total
                                     if dsGST_Class > 0 then
                                        UpdateChart( clGST_Account_Codes[ dsGST_Class ], Tax, 0, Tax );
                                  end;

                               end;
                               Dissection := dsNext;
                            end; { of While }
                         end;
                      end; //with
           end; //if account type ok
        end; //with

   end; {with info}
end;
//------------------------------------------------------------------------------

procedure ApplyDefaultGST( IncludeEdited : boolean);
{
   This method reapplies the gst to all transactions AND memorisations in
   which GST_Has_Been_Edited is set to false ( unless IncludeEdited is true).

   This should be called whenever the gst class for a chart changes.  This happens when

      1) The class for a chart is edited in Edit Account Dlg

      2) The class for a chart is edited in the Maintain Chart windows by pressing
        a SHIFT-Function Key ie SHIFT-F2

      3) A chart is merged from with Maintain Chart window.  Although in this case
         the GST class will only be updated if it was previously blank so apply need
         not be called

      4) A chart is refreshed.  This can happen from the Refresh Chart menu item
         or inside the EditAccountSystem dlg.

      5) A template is loaded

      6) The GST Rates are changed

   The GST_Has_Been_Edited flag is set/cleared by the following routines

   Coding Screen   (set/cleared if different when edited.  cleared if delete code etc)
                   (set during a recalc gst)
   Dissections
   Journals
   HDE
   AutoCode
   Memorisations   (class only)
   Templates
   EditGSTDlg
   Payees          (class only)

   Memorisations are affected by this routine, so transactions should be rememorised
   after this has been called.

}
//applies the default gst to ALL transactions and memorisations for this client
//only affects transactions that have not been transferred or locked
//The Include Edited flag tell the routine to include entries where the
//GST has been edited.
var
   pT : pTransaction_Rec;
   pD : pDissection_Rec;
   pM : TMemorisation;
   MemLine : pMemorisation_Line_Rec;
   APayee : TPayee;
   PayeeLine : pPayee_Line_Rec;
   b, t, m ,i, p : integer;
begin
   //set GST has been edited flag for transactions and dissections
   with MyClient.clBank_Account_List do begin
      for b := 0 to Pred( ItemCount) do with Bank_Account_At(b) do begin
         //cycle thru each bank account, including all journals
         for t := 0 to Pred( baTransaction_List.ItemCount) do begin
            pT := baTransaction_List.Transaction_At( t);
            //see if locked or transfered, if so skip this entry
            if ( pT^.txLocked) or ( pT^.txDate_Transferred > 0) then continue;
            //is it a dissection?
            if pT^.txFirst_Dissection = nil then begin
               if ( not pT^.txGST_Has_Been_Edited) or IncludeEdited then begin
//                  CalculateGST( MyClient, pT^.txDate_Effective, pT^.txAccount, pT^.txAmount, pT^.txGST_Class, pT^.txGST_Amount);
                  CalculateGST( MyClient, pT^.txDate_Effective, pT^.txAccount, pT^.Local_Amount, pT^.txGST_Class, pT^.txGST_Amount);
                  pT^.txGST_Has_Been_Edited := false;
                  if baFields.baAccount_Type in JournalsWithNoGSTSet then begin
                    if pT^.txGST_Amount <> 0 then begin
                      pT^.txGST_Amount := 0;
                      pT^.txGST_Has_Been_Edited := True;
                      pT^.txTransfered_To_Online := False;
                    end;
                  end;
               end;
            end
            else begin
              pD := pT^.txFirst_Dissection;
              while (pD <> nil) do begin
                if ( not pD^.dsGST_Has_Been_Edited) or IncludeEdited then begin
                  if not (pD^.dsJournal_Type in [ jtReversed, jtReversal, jtProcessed]) then
                  begin
                    //only recalculate GST if it is not reversed or processed
//                    CalculateGST( MyClient, pT^.txDate_Effective, pD^.dsAccount, pD^.dsAmount, pD^.dsGST_Class, pD^.dsGST_Amount);
                    CalculateGST( MyClient, pT^.txDate_Effective, pD^.dsAccount, pD^.Local_Amount, pD^.dsGST_Class, pD^.dsGST_Amount);
                    pD^.dsGST_Has_Been_Edited := false;
                    pT^.txGST_Has_Been_Edited := false;

                    if baFields.baAccount_Type in JournalsWithNoGSTSet then begin
                      if pD^.dsGST_Amount <> 0 then begin
                        pD^.dsGST_Amount := 0;
                        pD^.dsGST_Has_Been_Edited := True;
                        pT^.txGST_Has_Been_Edited := True;
                        pT^.txTransfered_To_Online := False;
                      end;
                    end;
                  end;
                end;
                pD := pD^.dsNext;
              end;
            end;
         end;

         //set GST for all client memorisations.
         for m := baMemorisations_List.First to baMemorisations_List.Last do begin
             pM := baMemorisations_List.Memorisation_At( m);
             for i := pM.mdLines.First to pM.mdLines.Last do
             begin
               MemLine := pM.mdLines.MemorisationLine_At(i);
               if ( not MemLine^.mlGST_Has_Been_Edited) or IncludeEdited then begin
                 MemLine^.mlGST_Class :=  MyClient.clChart.GSTClass( MemLine^.mlAccount);
                 MemLine^.mlGST_Has_Been_Edited := false;
               end;
             end;
         end;
      end;
   end;
   //Set GST all clients payees
   with MyClient.clPayee_List do begin
      for p := First to Last do begin
         APayee := Payee_At( p);
         for i := APayee.pdLines.First to APayee.pdLines.Last do
         begin
           PayeeLine := aPayee.pdLines.PayeeLine_At(i);
            if ( not PayeeLine.plGST_Has_Been_Edited) or IncludeEdited then begin
               PayeeLine.plGST_Class := MyClient.clChart.GSTClass(PayeeLine.plAccount);
               PayeeLine.plGST_Has_Been_Edited := false;
            end;
         end;
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
{$IFDEF SmartBooks}
   //'Need to decide what to do with GST_Has_Been_Edited and ApplyDefaultGST!!'
{$ENDIF}
END.
