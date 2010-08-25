unit WorkRecDefs;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:

   Remarks:

}
//------------------------------------------------------------------------------

interface
uses
  bkConst, MoneyDef, glConst;


const
   MaxRefLength = 12;

type
   pWorkDissect_Rec = ^TWorkDissect_Rec;
   TWorkDissect_Rec = Record
      dtAccount             : Bk5CodeStr;
      dtAmount              : Money;
      dtDate                : Integer;
      dtGST_Class           : Byte;
      dtGST_Amount          : Money;
      dtPayee_Number        : Integer;
      dtQuantity            : Money;
      dtNarration           : String[ MaxNarrationEditLength ];
      dtHas_Been_Edited     : Boolean;
      dtGST_Has_Been_Edited : Boolean;
      dtImportNotes         : String;
      dtNotes               : string;
      dtSF_Imputed_Credit      : Money;
      dtSF_Tax_Free_Dist       : Money;
      dtSF_Tax_Exempt_Dist     : Money;
      dtSF_Tax_Deferred_Dist   : Money;
      dtSF_TFN_Credits         : Money;
      dtSF_Foreign_Income      : Money;
      dtSF_Foreign_Tax_Credits : Money;
      dtSF_Capital_Gains_Indexed : Money;
      dtSF_Capital_Gains_Disc : Money;
      dtSF_Capital_Gains_Other : Money;
      dtSF_Other_Expenses      : Money;
      dtSF_CGT_Date            : Integer;
      dtSuper_Fields_Edited : Boolean;
      dtExternal_GUID       : String;
      dtDocument_Title      : String;
      dtDocument_Status_Update_Required  : Boolean;
      dtNotes_Read : Boolean;
      dtImport_Notes_Read : Boolean;
      dtSF_Franked: Money;
      dtSF_Unfranked: Money;
      dtSF_Member_ID: string[20];
      dtSF_Interest: Money;
      dtSF_Capital_Gains_Foreign_Disc: Money;
      dtSF_Rent: Money;
      dtSF_Special_Income: Money;
      dtSF_Other_Tax_Credit: Money;
      dtSF_Non_Resident_Tax: Money;
      dtSF_Foreign_Capital_Gains_Credit: Money;
      dtSF_Member_Component: Byte;
      dtPercent_Amount: Money;
      dtAmount_Type_Is_Percent: Boolean;
      dtSF_Member_Account_ID: Integer;
      dtSF_Fund_ID: Integer;
      dtSF_Fund_Code: string[20];
      dtSF_Member_Account_Code: string[41];
      dtSF_Transaction_Type_ID: Integer;
      dtSF_Transaction_Type_Code: string;
      dtSF_Capital_Gains_Fraction_Half: Boolean;
      dtJob: string;
      dtTax_Invoice: Boolean;
      dtForex_Conversion_Rate            : Double;
      dtForeign_Currency_Amount          : Money;
   end;

procedure ClearSuperfundDetails(dwr: PWorkDissect_Rec); overload;
procedure ClearWorkRecDetails(dwr: PWorkDissect_Rec); overload;

type
   pWorkJournal_Rec = ^TWorkJournal_Rec;
   TWorkJournal_Rec = Record
      dtAccount             : Bk5CodeStr;
      dtReference           : String [MaxRefLength];
      dtAmount              : Money;
      dtDate                : Integer;
      dtGST_Class           : Byte;
      dtGST_Amount          : Money;
      dtQuantity            : Money;
      dtNarration           : String[ MaxNarrationEditLength ];
      dtPayee_Number        : integer;
      dtHas_Been_Edited     : Boolean;
      dtGST_Has_Been_Edited : Boolean;
      dtStatus              : integer;   //can hold value of -1 if status not
                                         //yet specified
      dtSF_Imputed_Credit      : Money;
      dtSF_Tax_Free_Dist       : Money;
      dtSF_Tax_Exempt_Dist     : Money;
      dtSF_Tax_Deferred_Dist   : Money;
      dtSF_TFN_Credits         : Money;
      dtSF_Foreign_Income      : Money;
      dtSF_Foreign_Tax_Credits : Money;
      dtSF_Capital_Gains_Indexed : Money;
      dtSF_Capital_Gains_Disc : Money;
      dtSF_Capital_Gains_Other : Money;
      dtSF_Other_Expenses      : Money;
      dtSF_CGT_Date            : Integer;
      dtSF_Super_Fields_Edited : Boolean;

      dtExternal_GUID       : String;
      dtDocument_Title      : String;
      dtDocument_Status_Update_Required  : Boolean;

      dtLinkedJnlDate       : integer;

      dtSF_Franked  : Money;
      dtSF_Unfranked: Money;
      dtSF_Member_ID: string[20];
      dtSF_Interest: Money;
      dtSF_Capital_Gains_Foreign_Disc: Money;
      dtSF_Rent: Money;
      dtSF_Special_Income: Money;
      dtSF_Other_Tax_Credit: Money;
      dtSF_Non_Resident_Tax: Money;
      dtSF_Foreign_Capital_Gains_Credit: Money;
      dtSF_Member_Component: Byte;
      dtSF_Member_Account_ID: Integer;
      dtSF_Fund_ID: Integer;
      dtSF_Fund_Code: string[20];
      dtSF_Member_Account_Code: string[41];
      dtSF_Transaction_Type_ID: Integer;
      dtSF_Transaction_Type_Code: string;
      dtSF_Capital_Gains_Fraction_Half: Boolean;
      dtJob: string;
   end;

procedure ClearSuperfundDetails(jwr: PWorkJournal_Rec); overload ;
procedure ClearWorkRecDetails(jwr: PWorkJournal_Rec); overload;

implementation

procedure ClearWorkRecDetails(jwr: PWorkJournal_Rec); overload;
begin
   FillChar(jwr^,Sizeof(TWorkJournal_Rec),0);
   //Initialise dtStatus to avoid "Normal" to be displayed
   jwr^.dtStatus := -1;
   ClearSuperfundDetails(jwr);
end;

procedure ClearWorkRecDetails(dwr: PWorkDissect_Rec); overload;
begin
   FillChar(dwr^,Sizeof(TWorkDissect_Rec),0);
   ClearSuperfundDetails(dwr);
end;


procedure ClearSuperfundDetails(dwr: PWorkDissect_Rec); overload;
begin
   with dwr^ do begin
      dtSF_Imputed_Credit:= 0;
      dtSF_Tax_Free_Dist:= 0;
      dtSF_Tax_Exempt_Dist:= 0;
      dtSF_Tax_Deferred_Dist:= 0;
      dtSF_TFN_Credits:= 0;
      dtSF_Foreign_Income:= 0;
      dtSF_Foreign_Tax_Credits:= 0;
      dtSF_Capital_Gains_Indexed:= 0;
      dtSF_Capital_Gains_Disc:= 0;
      dtSF_Capital_Gains_Other:= 0;
      dtSF_Other_Expenses:= 0;
      dtSF_CGT_Date:= 0;
      dtSuper_Fields_Edited := false;
      dtSF_Franked:= 0;
      dtSF_Unfranked:= 0;
      dtSF_Member_ID:='';
      dtSF_Interest:= 0;
      dtSF_Capital_Gains_Foreign_Disc:= 0;
      dtSF_Rent:= 0;
      dtSF_Special_Income:= 0;
      dtSF_Other_Tax_Credit:= 0;
      dtSF_Non_Resident_Tax:= 0;
      dtSF_Foreign_Capital_Gains_Credit:= 0;
      dtSF_Member_Component:= 0;
      dtSF_Member_Account_ID:= -1;
      dtSF_Fund_ID:= -1;
      dtSF_Fund_Code:='';
      dtSF_Member_Account_Code:='';;
      dtSF_Transaction_Type_ID:= -1;
      dtSF_Transaction_Type_Code:='';
      dtSF_Capital_Gains_Fraction_Half:= false;
   end;
end;



procedure ClearSuperfundDetails(jwr: PWorkJournal_Rec); overload ;
begin
   with jwr^ do begin
      dtSF_Imputed_Credit := 0;
      dtSF_Tax_Free_Dist := 0;
      dtSF_Tax_Exempt_Dist := 0;
      dtSF_Tax_Deferred_Dist := 0;
      dtSF_TFN_Credits := 0;
      dtSF_Foreign_Income := 0;
      dtSF_Foreign_Tax_Credits := 0;
      dtSF_Capital_Gains_Indexed := 0;
      dtSF_Capital_Gains_Disc := 0;
      dtSF_Capital_Gains_Other := 0;
      dtSF_Other_Expenses := 0;
      dtSF_CGT_Date := 0;
      dtSF_Super_Fields_Edited := False;

      dtSF_Franked := 0;
      dtSF_Unfranked:= 0;
      dtSF_Member_ID:='';
      dtSF_Interest:= 0;
      dtSF_Capital_Gains_Foreign_Disc:= 0;
      dtSF_Rent:= 0;
      dtSF_Special_Income:= 0;
      dtSF_Other_Tax_Credit:= 0;
      dtSF_Non_Resident_Tax:= 0;
      dtSF_Foreign_Capital_Gains_Credit:= 0;
      dtSF_Member_Component:= 0;
      dtSF_Member_Account_ID:= -1;
      dtSF_Fund_ID:= -1;
      dtSF_Fund_Code:='';
      dtSF_Member_Account_Code:='';
      dtSF_Transaction_Type_ID:= -1;
      dtSF_Transaction_Type_Code :='';
      dtSF_Capital_Gains_Fraction_Half:= false;

   end;
end;


end.
