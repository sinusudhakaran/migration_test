//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  }

UNIT JNLUTILS32;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  }
INTERFACE Uses ovcDate, BAOBJ32, BKDEFS, BKCONST, clObj32, MoneyDef, bkDateUtils;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  }

type
   PeriodType = (Dayly, Weekly, Monthly);

Function GetJournalFor( B : TBank_Account; EffDate : integer) : pTransaction_Rec;
Function NewJournalFor( const aClient : TClientObj; B : TBank_Account; D : integer ) : pTransaction_Rec;
function ProcessJournal(const aClient : TClientObj; B : TBank_Account; Source : pTransaction_Rec;
                        Period: PeriodType;
                        nPeriods: integer;
                        nDuration: Integer;
                        FinalDate: Integer = 0) : boolean;
function GetCorrespondingDayInNMonths( OrigDate : integer; nMths : integer) : integer;
function CheckForOpeningBalance( const aClient : TClientObj; OnDate : integer) : Boolean;
function GetPreviousStockBalance( const aClient: TClientObj; const StartDate: Integer; const Code: string): Money;

procedure RemoveJnlAccountIfEmpty( aClient : TClientObj; var JnlAccount : TBank_Account);

function HasJournalsInMonth(B: TBank_Account; EffDate: integer): Boolean;overload;
function HasJournalsInMonth(B: TBank_Account; Month: TDateRange): Boolean;overload;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  }
IMPLEMENTATION USES
  ClientHomePagefrm,
  BKDSIO,
  BKTXIO,
  glConst,  //global constants
  LogUtil,
  trxList32,
  TransactionUtils,
  stdate;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  }
Function GetJournalFor( B : TBank_Account; EffDate : integer ): pTransaction_Rec;
VAR
   i  : LongInt;
   T  : pTransaction_Rec;
Begin
   result := NIL;
   With B.baTransaction_List do For i := 0 to Pred( itemCount ) do
   Begin
      T := Transaction_At( i );
      With T^ do If ( txDate_Effective = EffDate ) then
      Begin
         result := T;
         exit;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  }
Function NewJournalFor( const aClient : TClientObj; B : TBank_Account; D : integer ) : pTransaction_Rec;
VAR
   NewJNL         : pTransaction_Rec;
Begin
   With aClient, clFields, B do
   Begin
      NewJNL :=  baTransaction_List.New_Transaction;
      With NewJNL^ do
      Begin
         Case clCountry of
            whNewZealand : txType := 50;
            whAustralia, whUK  : txType := 10;
         end;
         txSource              := orManual;
         txDate_Transferred    := 0;
         txDate_Presented      := D;
         txDate_Effective      := D;
         txAmount              := 0;
         txPayee_Number        := 0;              
         txGST_Class           := 0;
         txGST_Amount          := 0;
         //txReference           := btReferences[baFields.baAccount_Type]; Not required anymore
         //txGL_Narration        := 'Journal Entry';
         txBank_Seq            := baFields.baNumber;
      end;
      baTransaction_List.Insert_Transaction_Rec( NewJNL );
   end;
   result := NewJNL;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  }
{function GetTheCorrespondingDayInTheNextMonth( D : integer ): integer;
var
   DayNo, M, Y    : Integer;
Begin
   stDateToDMY( D, DayNo, M, Y );

   If ( DayNo=DaysInMonth( M, Y , BKDATEEPOCH) ) then
   Begin // Return the last day of the next month
      Inc( M ); If M>12 then Begin Inc( Y ); M := 1; end;
      DayNo := DaysInMonth( M, Y,BKDATEEPOCH );
      result := DMYTostDate( DayNo, M, Y, BKDATEEPOCH );
      exit;
   end
   else
   Begin // Try for the same day number in the month if possible
      Inc( M ); If M>12 then Begin Inc( Y ); M := 1; end;
      If DayNo > DaysInMonth( M, Y ,BKDATEEPOCH) then DayNo := DaysInMonth( M, Y,BKDATEEPOCH );
      result := DMYTostDate( DayNo, M, Y ,BKDATEEPOCH );
   end;
end;}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetCorrespondingDayInNMonths( OrigDate : integer; nMths : integer) : integer;
var
   DayNo, M, Y    : Integer;
   MonthsAdded    : integer;
   IsLastDay      : boolean;
Begin
   stDateToDMY( OrigDate, DayNo, M, Y );
   IsLastDay := ( DayNo = DaysInMonth( M, Y , BKDATEEPOCH) );

   if nMths = 0 then
     nMths := 1;
   MonthsAdded := 0;

   //add n months to month and year
   repeat
     Inc( M);
     Inc( MonthsAdded);
     If M>12 then
     begin
       Inc( Y );
       M := 1;
     end;
   until (MonthsAdded = nMths);

   //set day no
   if IsLastDay then
   begin
     DayNo := DaysInMonth( M, Y,BKDATEEPOCH );
   end
   else
   begin
     //try for same date next month, check day is valid
     if DayNo > DaysInMonth( M, Y, BKDATEEPOCH) then
      DayNo := DaysInMonth( M, Y,BKDATEEPOCH );
   end;
   result := DMYTostDate( DayNo, M, Y ,BKDATEEPOCH );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  }
function ProcessJournal( const aClient : TClientObj; B : TBank_Account; Source : pTransaction_Rec;
                        Period: PeriodType;
                        nPeriods: integer;
                        nDuration: Integer;
                        FinalDate: Integer = 0) : boolean;
{
  Remarks:  Generates the automatic journals in the following month.  Reversing
            journals are marked as reverse, standing journals are marked as
            processed.

            Journal lines are only processed once they have a non zero amount.

            Returns true if a journal was created
}
Var
   AutoJnlDate, i : integer;
   Destination,
   Current: pTransaction_Rec;
   WorkToDo: Boolean;
   jThis, jNew: pDissection_Rec;
   LoopCount: Integer;

   procedure MarkAsDone(ATrans: pTransaction_Rec; Linkdate: Integer);
   begin
      //Now flag reversing lines ATrans so we know they have been reversed
      jThis := ATrans.txFirst_Dissection;
      while jThis<>nil do with jThis^ do begin

         if (dsJournal_Type = jtReversing)
         and (dsAmount <> 0) then begin
            dsJournal_Type := jtReversed;
            dsLinked_Journal_Date := LinkDate;
         end;

         if (dsJournal_Type = jtStanding)
         and (dsAmount <> 0) then begin //Mark current standing journal line as processed
            dsJournal_Type := jtProcessed;
            dsLinked_Journal_Date := LinkDate;
         end;
         jThis := dsNext;
      end;
   end;

Begin
   Result := false;

   WorkToDo := FALSE;
   jThis := Source.txFirst_Dissection;
   while (jThis <> NIL)
   and (not WorkToDo) do With jThis^ do Begin
      Case dsJournal_Type of
            jtReversing : if (dsAmount <> 0) then
               WorkToDo := true;
            jtStanding  : if (dsAmount <> 0) then
               WorkToDo := true;
      end;
      jThis := dsNext;
   end;

   if not WorkToDo then
      Exit; // nothing to do.

   // Workout the loop variables
   i := nPeriods;
   case period of
      Dayly : begin

         AutoJnlDate := IncDate(Source.txDate_Effective, i, 0, 0);
         if Finaldate = 0 then begin
            if nDuration = 0 then
               FinalDate := AutoJnlDate
            else
               FinalDate := IncDate(Source.txDate_Effective, nDuration*7, 0, 0);
         end;
      end;
      Weekly : begin
         AutoJnlDate := IncDate(Source.txDate_Effective, i*7, 0, 0);
         if Finaldate = 0 then begin
            if nDuration = 0 then
               FinalDate := AutoJnlDate
            else
               FinalDate := IncDate(Source.txDate_Effective, nDuration*7, 0, 0);
         end;
      end;
      else begin // monthly
         AutoJnlDate := GetCorrespondingDayInNMonths(Source.txDate_Effective, i );
         if Finaldate = 0 then begin
            if nDuration = 0 then
               FinalDate := AutoJnlDate
            else
               FinalDate := GetCorrespondingDayInNMonths(Source.txDate_Effective, nDuration );
      end;
      end;
   end;
   LoopCount := 0;
   Current := Source;
   //Get the first date

   // Do the loop
   while AutoJnlDate <= FinalDate do begin
         //see if a journal already exists for this date, if not create one
         //Actauly don't need to do this annymore, just make a new one..
         {Destination := GetJournalFor( B, AutoJnlDate );
         if (Destination = NIL) then}

         Destination := NewJournalFor(aClient, B, AutoJnlDate);
         Destination.txGL_Narration := Source.txGL_Narration;
         Destination.txReference := Source.txReference;

         if LoopCount < 1 then begin

            //------------ REVERSING JOURNALS ------------
            //Create line in next month that reverses the current month
            jThis := Current.txFirst_Dissection;
            while jThis<>NIL do With jThis^ do begin
               If ( dsJournal_Type = jtReversing )
               and ( dsAmount<>0 ) then begin // Copy this over
                  jNew := BKDSIO.New_Dissection_Rec;
                  With jNew^ do Begin
                     dsAccount             :=  jThis^.dsAccount;
                     dsAmount              := -jThis^.dsAmount;
                     dsPercent_Amount      := jThis^.dsPercent_Amount;
                     dsAmount_Type_Is_Percent := jThis^.dsAmount_Type_Is_Percent;
                     dsPayee_Number        :=  jThis^.dsPayee_Number;
                     dsGST_Class           :=  jThis^.dsGST_Class;
                     dsGST_Amount          := -jThis^.dsGST_Amount;
                     dsHas_Been_Edited     :=  jThis^.dsHas_Been_Edited;
                     dsGST_Has_Been_Edited :=  jThis^.dsGST_Has_Been_Edited;
                     dsQuantity            := -jThis^.dsQuantity;
                     dsGL_Narration        :=  jThis^.dsGL_Narration+' [Rev]';
                     dsReference           :=  jThis^.dsReference;
                     dsJob_Code            :=  jThis^.dsJob_Code;
                     dsJournal_Type        :=  jtReversal;
                     dsLinked_Journal_Date := Current.txDate_Effective;
                     dsSF_Member_Account_ID:= -1;
                     dsSF_Fund_ID          := -1;
                  end;
                  AppendDissection( Destination, jNew );
                  Result := true;
               end;

               jThis := dsNext;
            end;
            //Create line in next month that has template for reversing journal.  This
            //is so the user can easily setup the same journal next month
            //only if we arent using duration
            if Period <> Dayly then begin // case 3465
               jThis := Current.txFirst_Dissection;
               While jThis<>NIL do With jThis^ do Begin
                  If ( dsJournal_Type = jtReversing )
                  and ( dsAmount<>0 ) then Begin { Copy this over }
                     jNew := BKDSIO.New_Dissection_Rec;
                     With jNew^ do Begin
                        dsAccount             := jThis^.dsAccount;
                        dsAmount              := 0;
                        dsPercent_Amount      := 0;
                        dsAmount_Type_Is_Percent := False;
                        dsPayee_Number        := jThis^.dsPayee_Number;
                        dsGST_Class           := jThis^.dsGST_Class;
                        dsGST_Amount          := 0;
                        dsHas_Been_Edited     := jThis^.dsHas_Been_Edited;
                        dsGST_Has_Been_Edited := jThis^.dsGST_Has_Been_Edited;
                        dsQuantity            := 0;
                        dsGL_Narration        := jThis^.dsGL_Narration;
                        dsJob_Code            := jThis^.dsJob_Code;
                        dsJournal_Type        := jtReversing;
                        dsReference           := jThis^.dsReference;

                        dsSF_Member_Account_ID:= -1;
                        dsSF_Fund_ID          := -1;
                     end;
                     AppendDissection( Destination, jNew );
                  end;
                  jThis := dsNext;
               end;
            end; //period
         end; // Reversing only once


         //------------ STANDING JOURNALS ------------
         //Copy journal line into next months journal
         jThis := Current.txFirst_Dissection;
         while (jThis<>NIL ) do With jThis^ do begin
            if (dsJournal_Type = jtStanding)
            and (dsAmount <> 0) then begin { Copy this over }
               jNew := BKDSIO.New_Dissection_Rec;
               with jNew^ do begin
                  dsAccount             := jThis^.dsAccount;
                  dsAmount              := jThis^.dsAmount;
                  dsPercent_Amount      := jThis^.dsPercent_Amount;
                  dsAmount_Type_Is_Percent := jThis^.dsAmount_Type_Is_Percent;
                  dsPayee_Number        := jThis^.dsPayee_Number;
                  dsGST_Class           := jThis^.dsGST_Class;
                  dsGST_Amount          := jThis^.dsGST_Amount;
                  dsHas_Been_Edited     := jThis^.dsHas_Been_Edited;
                  dsGST_Has_Been_Edited := jThis^.dsGST_Has_Been_Edited;
                  dsQuantity            := jThis^.dsQuantity;
                  dsGL_Narration        := jThis^.dsGL_Narration;
                  dsReference           := jThis^.dsReference;
                  dsJob_Code            := jThis^.dsJob_Code;
                  dsJournal_Type        := jtStanding;
                  dsSF_Member_Account_ID:= -1;
                  dsSF_Fund_ID          := -1;
               end;
               AppendDissection(Destination, jNew);
               Result := true;
            end;
            jThis := dsNext;
         end;

         With Destination^ do begin // Cleanup the destination
            txQuantity     := 0;
            txAmount       := 0;
            txPayee_Number := 0;
            txGST_Amount   := 0;
            jThis := txFirst_Dissection;
            while ( jThis<>NIL ) do with jThis^ do begin
               txAmount := txAmount + dsAmount;
               jThis := dsNext;
            end;
         end;

         // Move in the loop
         MarkAsDone(Current,AutoJnlDate);
         Current := Destination;

         // Get the next date
         Inc(i, nPeriods);
         case Period of
            Dayly:   AutoJnlDate := IncDate(Source.txDate_Effective, i, 0, 0);
            Weekly:  AutoJnlDate := IncDate(Source.txDate_Effective, i*7, 0, 0);
            Monthly: AutoJnlDate := GetCorrespondingDayInNMonths(Source.txDate_Effective, i );
         end;

         inc(LoopCount);
      end; // While
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure RemoveJnlAccountIfEmpty( aClient : TClientObj; var JnlAccount : TBank_Account);
//this routine removes the journal account if it doesnt have any items
begin
  if Assigned( JnlAccount) then begin
    //remove the year end journals account if not needed
    if JnlAccount.baTransaction_List.ItemCount = 0 then begin
       aClient.clBank_Account_List.DelFreeItem( JnlAccount);
       JnlAccount := nil;
       RefreshHomepage([HPR_Coding]);
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  CheckForOpeningBalance( const aClient : TClientObj; OnDate : integer) : Boolean;
var
  i  : integer;
  Ba : TBank_Account;
  t  : integer;
  pT : pTransaction_Rec;
begin
  result := false;
  with aClient.clBank_Account_List do
    for i := 0 to Pred( ItemCount) do begin
      Ba := Bank_Account_At(i);
      if ( Ba.baFields.baAccount_Type = btOpeningBalances) then begin
        for t := 0 to Pred(ba.baTransaction_List.ItemCount) do begin
          pT := ba.baTransaction_List.Transaction_At(t);
          if ( pT^.txDate_Effective = OnDate) then
            Result := true;
        end;
      end;
    end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Find a stock bal record on a given date
function  GetBalanceRecord( const aClient : TClientObj; const OnDate : integer;
  const JnlType: Integer; const Code: string) : Money;
var
  i  : integer;
  Ba : TBank_Account;
  t  : integer;
  pT : pTransaction_Rec;
  pD : pDissection_Rec;
begin
  result := 0;
  with aClient.clBank_Account_List do
    for i := 0 to Pred( ItemCount) do begin
      Ba := Bank_Account_At(i);
      if ( Ba.baFields.baAccount_Type = JnlType) then begin
        for t := 0 to Pred(ba.baTransaction_List.ItemCount) do begin
          pT := ba.baTransaction_List.Transaction_At(t);
          if ( pT^.txDate_Effective = OnDate) then
          begin
            pD := pT^.txFirst_Dissection;
            while (pD <> nil) do
            begin
              if pD.dsAccount = Code then
              begin
                Result := pD.dsAmount;
                exit;
              end;
              pD := pD^.dsNext;
            end;
          end;
        end;
      end;
    end;
end;
// Search for a stock balance backwards from the given date
// Need to look in both opening balance journal (which will always be 1st day of month)
// and stock balance journal (which will always be last day of month)
function GetPreviousStockBalance( const aClient: TClientObj; const StartDate: Integer; const Code: string): Money;
var
  TestDate: Integer;
  UseOpBal: Boolean;
begin
  TestDate := StartDate;
  UseOpBal := True; // start looking at 1st of this month for op bals
  Result := 0;
  while TestDate > MinValidDate do
  begin
    if UseOpBal then // 1st day of month
    begin
      TestDate := GetFirstDayOfMonth(TestDate);
      Result := GetBalanceRecord(aClient, TestDate, btOpeningBalances, Code);
    end
    else // last day of previous month
    begin
      TestDate := GetLastDayOfMonth(IncDate(TestDate, 0, -1, 0));
      Result := GetBalanceRecord(aClient, TestDate, btStockBalances, Code);
    end;
    if Result <> 0 then
      exit;
    UseOpBal := not UseOpBal;
  end;
end;

function HasJournalsInMonth(B: TBank_Account; Month: TDateRange): Boolean;overload;
var I: Integer;
begin
   Result := False;
   if not Assigned(B) then
      Exit;
    With b.baTransaction_List do For i := First to Last do
         with Transaction_At( I )^ do
           if ( txDate_Effective <= Month.ToDate )
           and ( txDate_Effective >= Month.FromDate )then begin
              result := true;// one is enough
              Exit;
           end;
end;

function HasJournalsInMonth(B: TBank_Account; EffDate: integer): Boolean;overload;
begin
  Result := HasJournalsInMonth(B, GetMonthDateRange(EffDate));
end;

END.

