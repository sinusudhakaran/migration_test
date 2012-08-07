unit TransactionUtils;
//------------------------------------------------------------------------------
{
   Title:        Transaction Utilities

   Description:  Provides helper routines that work on transaction records

   Author:       Matthew Hopkins  Dec 2003

   Remarks:      The idea of this unit is to provide a set of common routines
                 that do not link in half the system
                 Should not be linked to globals

                 If transactions were objects then this routine would be part
                 of the object
}
//------------------------------------------------------------------------------

interface
  uses  bkdefs, bkAuditUtils, baObj32, clobj32;

procedure  ClearSuperFundFields( pT : pTransaction_Rec); overload;
procedure  ClearSuperFundFields( pD : pDissection_Rec); overload;

procedure  ClearGSTFields( pT : pTransaction_Rec);

function   TrimGUID( aGUID : string) : string;
procedure  CheckExternalGUID( pT : pTransaction_Rec); overload;
procedure  CheckExternalGUID( pD : pDissection_Rec); overload;

function HasNotes(T: pTransaction_Rec): Boolean;
function HasUnreadNotes(T: pTransaction_Rec): Boolean;

// Export test
function HasZeroAmount(T: pTransaction_Rec): Boolean;
function SkipZeroAmountExport(T: pTransaction_Rec): Boolean;

// Typicaly used for Re/ Imporing of Trf files
Procedure SetNotes (pT: pTransaction_Rec; NewNotes : String);Overload;
Procedure SetNotes (pD: pDissection_Rec;  NewNotes : String);Overload;

// Typicaly used for reports
function GetFullNotes (pT: pTransaction_Rec): string; overload;
function GetFullNotes (pD: pDissection_Rec): string; overload;

// Typicaly used for reports
function GetNarration (pT: pTransaction_Rec; Account_Type: Byte = 0): string; overload;
function GetNarration (pD: pDissection_Rec; Account_Type: Byte = 0): string; overload;

function getReference(pT: pTransaction_Rec; Account_Type: Byte): string;
function getDsctReference (pd: pDissection_Rec; Account_Type: Byte  ) : String; overload;
function getDsctReference (pd: pDissection_Rec;pT: pTransaction_Rec; Account_Type: Byte  ) : String; overload;

// Typicaly used in Coding screen
function GetFormattedEntryType(const T: pTransaction_Rec ): ShortString; overload;
function GetFormattedEntryType(const ClientFields: TClient_Rec; AType: Byte; HasBeenEdited: boolean): ShortString; overload;
function GetFormattedAction(const T: pTransaction_Rec): ShortString;

procedure GetPayeeInfoForDissection( const pT : pTransaction_Rec;
                                    var HasPayees : boolean;
                                    var AllPayeesTheSame : boolean;
                                    var FirstPayee : integer);

function GetChartDescription(pD: pTransaction_Rec): String;
function GetPayeeName(pD: pTransaction_Rec; Client: TClientObj): String;
function GetJobName(pD: pTransaction_Rec; Client: TClientObj): String;

//******************************************************************************
implementation
uses
  bkConst, ComObj, SysUtils, Globals, bkdateutils, PayeeObj;

function TrimGUID( aGUID : string) : string;
begin
  result := StringReplace( aGUID, '-', '', [rfReplaceAll]);
  //now remove {}
  if Pos( '{', result) = 1 then
    result := Copy( result, 2 , length( result) - 2);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure  CheckExternalGUID( pT : pTransaction_Rec); overload;
//checks to see that the external guid has been set, if not is generates one
begin
  if ( pT^.txExternal_GUID) = '' then
    pT^.txExternal_GUID := ComObj.CreateClassID;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure  CheckExternalGUID( pD : pDissection_Rec); overload;
//checks to see that the external guid has been set, if not is generates one
begin
  if ( pD^.dsExternal_GUID) = '' then
    pD^.dsExternal_GUID := ComObj.CreateClassID;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure  ClearGSTFields( pT : pTransaction_Rec);
begin
  pT^.txGST_Class   := 0;
  pT^.txGST_Amount  := 0;
  pT^.txGST_Has_Been_Edited := false;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure  ClearSuperFundFields( pT : pTransaction_Rec);
begin
   pT^.txSF_Tax_Free_Dist := 0;
   pT^.txSF_Tax_Exempt_Dist := 0;
   pT^.txSF_Tax_Deferred_Dist := 0;
   pT^.txSF_TFN_Credits := 0;
   pT^.txSF_Foreign_Income := 0;
   pT^.txSF_Other_Expenses := 0;
   pT^.txSF_Foreign_Tax_Credits := 0;
   pT^.txSF_Capital_Gains_Indexed := 0;
   pT^.txSF_Capital_Gains_Disc := 0;
   pT^.txSF_Capital_Gains_Other := 0;
   pt^.txSF_CGT_Date := 0;
   pT^.txSF_Franked := 0;
   pT^.txSF_Unfranked := 0;
   pT^.txSF_Imputed_Credit := 0;
   pT^.txSF_Interest := 0;
   pT^.txSF_Capital_Gains_Foreign_Disc := 0;
   pT^.txSF_Rent := 0;
   pT^.txSF_Special_Income := 0;
   pT^.txSF_Other_Tax_Credit := 0;
   pT^.txSF_Non_Resident_Tax := 0;
   pT^.txSF_Foreign_Capital_Gains_Credit := 0;
   pT^.txSF_Member_ID := '';
   pT^.txSF_Member_Component:= 0;
   pt^.txSF_Fund_ID := -1;
   pt^.txSF_Member_Account_ID:= -1;
   pt^.txSF_Transaction_ID := -1;
   pT^.txSF_Super_Fields_Edited := false;
end;

procedure  ClearSuperFundFields( pD : pDissection_Rec); overload;
begin
   pd.dsSF_Tax_Free_Dist := 0;
   pd.dsSF_Tax_Exempt_Dist := 0;
   pd.dsSF_Tax_Deferred_Dist := 0;
   pd.dsSF_TFN_Credits := 0;
   pd.dsSF_Foreign_Income := 0;
   pd.dsSF_Other_Expenses := 0;
   pd.dsSF_Foreign_Tax_Credits := 0;
   pd.dsSF_Capital_Gains_Indexed := 0;
   pd.dsSF_Capital_Gains_Disc := 0;
   pd.dsSF_Capital_Gains_Other := 0;
   pd.dsSF_CGT_Date := 0;
   pd.dsSF_Franked := 0;
   pd.dsSF_Unfranked := 0;
   pd.dsSF_Imputed_Credit := 0;
   pd.dsSF_Interest := 0;
   pd.dsSF_Capital_Gains_Foreign_Disc := 0;
   pd.dsSF_Rent := 0;
   pd.dsSF_Special_Income := 0;
   pd.dsSF_Other_Tax_Credit := 0;
   pd.dsSF_Non_Resident_Tax := 0;
   pd.dsSF_Foreign_Capital_Gains_Credit := 0;
   pd.dsSF_Member_ID := '';
   pd.dsSF_Member_Component:= 0;
   pd.dsSF_Fund_ID := -1;
   pd.dsSF_Member_Account_ID:= -1;
   pd.dsSF_Transaction_ID := -1;
   pd.dsSF_Super_Fields_Edited := false;
end;

// Does a tx have notes attached to it
function HasNotes(T: pTransaction_Rec): Boolean;
var
  pD: pDissection_Rec;
begin
  Result := False;

  if (T^.txECoding_Import_Notes <> '') or (T^.txNotes <> '') then
  begin
    Result := True;
    exit;
  end;

  if T^.txFirst_Dissection <> nil then
  begin
    pD := T^.txFirst_Dissection;
    while pD <> nil do
    begin
      if (pD^.dsECoding_Import_Notes <> '') or (pD^.dsNotes <> '') then
      begin
        HasNotes := True;
        exit;
      end;
      pD := pD^.dsNext;
    end;
  end;
end;

function HasZeroAmount(T: pTransaction_Rec): Boolean;
begin
   Result := (T.txAmount = 0)
          and (T.txFirst_Dissection = nil);
          // At this stage Dissections cannot be zero..
end;

function SkipZeroAmountExport(T: pTransaction_Rec): Boolean;
begin
   // this should be true if i need to skip this
   Result := (not PRACINI_ExtractZeroAmounts) //Dont Skip if I expect to export
          and (HasZeroAmount(T));             //Skip if Zero 
end;


function HasUnreadNotes(T: pTransaction_Rec): Boolean;
var
  pD: pDissection_Rec;
begin
  Result := True; // Assume we find some..

  if T^.txECoding_Import_Notes <> '' then
     if (NOT T^.txImport_Notes_Read) Then Exit;

  if T^.txNotes <> '' then
     if (NOT T^.txNotes_Read) then Exit;

  pD := T^.txFirst_Dissection;
  while pD <> nil do begin
     if pD^.dsECoding_Import_Notes <> '' Then
        if (NOT pD^.dsImport_Notes_Read) then Exit;

     if (pD^.dsNotes <> '') then
        if (NOT pD^.dsNotes_Read) then Exit;

      pD := pD^.dsNext;
  end;
  // Still here
  Result := False;
end;


  // Local
  function CheckUnread ( var Old : String; New : String; Beenread : boolean ): Boolean;
  begin
     if sametext(Old, New) then begin
        result := beenread; //No Change
        // Could double check read is OFF when empty...
     end else begin
        // Text has changed
        Old := New;
        result := Length(Old) = 0; // Set to 'read' if empty
     end
  end;

procedure SetNotes (pT: pTransaction_Rec; NewNotes : String);
begin
   pT.txNotes_Read := CheckUnread(pT.txNotes,NewNotes,pT.txNotes_Read);
end;

procedure SetNotes (pD: pDissection_Rec;  NewNotes : String);
begin
  pD.dsNotes_Read := CheckUnread(pD.dsNotes,NewNotes,pD.dsNotes_Read);
end;

function getReference(pT: pTransaction_Rec; Account_Type: Byte): string;
begin
   Result := pt.txReference;
   if Result = '' then
      if Account_Type in [btCashJournals..btOpeningBalances] then
         Result := btReferences[Account_Type]
end;

function getDsctReference (pd: pDissection_Rec; Account_Type: Byte) : String;
begin
   result := getDsctReference(pd, pd.dsTransaction, Account_Type);
end;



function getDsctReference (pd: pDissection_Rec;pT: pTransaction_Rec; Account_Type: Byte ) : String; overload;
begin
   if pd.dsReference > '' then
      result := pd.dsReference
   else begin
      if pt <> nil then
         result := getReference(pt,Account_Type)
      else
         Result := '';
   end;
end;


//------------------------------------------------------------------------------

function GetFormattedEntryType(const T: pTransaction_Rec): ShortString;
begin
   Result := format('%d:%s', [T.txType, TClientObj(T.txClient).clFields.clShort_Name[T.txType] ]);

   if T.txHas_Been_Edited then
      Result := 'E-' + Result;
end;

function GetFormattedEntryType(const ClientFields: TClient_Rec; AType: Byte; HasBeenEdited: boolean): ShortString;
begin
  Result := format('%d:%s', [AType, ClientFields.clShort_Name[AType]]);
  if HasBeenEdited then
    Result := 'E-' + Result;
end;

//------------------------------------------------------------------------------

function GetFormattedAction(const T: pTransaction_Rec): ShortString;
var pd: pDissection_Rec;

   function ActionName(Value: Integer): ShortString;
   begin
      case Value of
         jtProcessed : Result := 'Standing, Processed';
         else  Result := jtNames[Value];
      end;
   end;

begin
    pd := T.txFirst_Dissection;
    Result := '';
    while Assigned(pd) do begin
       if pd.dsJournal_Type in  [jtMin..jtMax] then
          if Result = '' then  // set the first one...
             Result := ActionName(pd.dsJournal_Type)
          else if Result <> ActionName(pd.dsJournal_Type) then begin
             // Found somthing else...
             Result := 'Mixed';
             Break; // cannot get any more mixed
          end;
          pd := pd.dsNext;
    end;
end;

//------------------------------------------------------------------------------

procedure GetPayeeInfoForDissection( const pT : pTransaction_Rec;
                                    var HasPayees : boolean;
                                    var AllPayeesTheSame : boolean;
                                    var FirstPayee : integer);
//analyses the dissection so that can display details about payees within
var
   pD : pDissection_Rec;
begin
   HasPayees := false;
   AllPayeesTheSame := false;
   FirstPayee := 0;

   pD := pT^.txFirst_Dissection;
   while ( pd <> nil) do begin
     //see if this is a valid line
     if ( pD^.dsAmount <> 0) or ( pD^.dsAccount <> '') then
     begin
       if pD^.dsPayee_Number <> 0 then
       begin
          HasPayees := true;
          break;
       end;
     end
     else
       Break;

     pD := pD^.dsNext;
   end;

   if HasPayees then
   begin
     //see if all lines have the same payee
     pD := pT^.txFirst_Dissection;
     FirstPayee := pD^.dsPayee_Number;
     AllPayeesTheSame := true;
     while ( pd <> nil) do
     begin
       //see if this is a valid line
       if ( pD^.dsAmount <> 0) or ( pD^.dsAccount <> '') then
       begin
         //make sure payee number matches
         if ( pD^.dsPayee_Number <> FirstPayee) then
         begin
           AllPayeesTheSame := false;
           Break;
         end;

       end
       else
         Break;

       pD := pD^.dsNext;
     end;
   end;
end;


function GetFullNotes (pT: pTransaction_Rec): string;
begin
   Result := '';
   if Assigned(pt) then begin
      Result := pt.txECoding_Import_Notes;
      if pt.txNotes > '' then begin
         if Result > '' then
            Result := Result + '; ';
         Result := Result + pt.txNotes;
      end;


   end;

end;

function GetFullNotes (pD: pDissection_Rec): string;
begin
   Result := '';
   if Assigned(pd) then begin
      Result := pd.dsECoding_Import_Notes;
      if pd.dsNotes > '' then begin
         if Result > '' then
            Result := Result + '; ';
         Result := Result + pd.dsNotes;
      end;
      if Result = '' then
         Result := GetFullNotes(pd.dsTransaction);
   end;
end;

function GetNarration (pT: pTransaction_Rec; Account_Type: Byte = 0): string;
begin
   Result := PT.txGL_Narration;
   if Result = ''  then
      if Account_Type in [btCashJournals..btStockBalances] then
          Result := 'Journal Entry'
   
end;

function GetNarration (pD: pDissection_Rec; Account_Type: Byte = 0): string; overload;
begin
   Result := pD.dsGL_Narration;
   if Result = ''  then
      Result :=  GetNarration(pD.dsTransaction,Account_Type);
end;

function GetChartDescription(pD: pTransaction_Rec): String;
var
  pA: pAccount_Rec;
begin
  pA := MyClient.clChart.FindCode(pD^.txAccount);

  if Assigned(pA) then
  begin
    Result := pA^.chAccount_Description;
  end;
end;

function GetPayeeName(pD: pTransaction_Rec; Client: TClientObj): String;
var
  APayee: TPayee;
begin
  if pD^.txPayee_Number <> 0 then
  begin
    APayee := Client.clPayee_List.Find_Payee_Number(pD^.txPayee_Number);

    if Assigned( aPayee ) then
    begin
      Result := aPayee.pdName;
    end;
  end;
end;

function GetJobName(pD: pTransaction_Rec; Client: TClientObj): String;
var
  Job: pJob_Heading_Rec;
begin
  if (pD^.txJob_code > '') then
  begin
    Job := Client.clJobs.FindCode (pD^.txJob_code);

    if Assigned(Job) then
    begin
      Result := Job.jhHeading;
    end;
  end; 
end;

end.
