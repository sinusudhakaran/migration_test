unit SuperFieldsUtils;
//------------------------------------------------------------------------------
{
   Title:       Super Fields handler

   Description:

   Author:

   Remarks:

}
//------------------------------------------------------------------------------

interface
uses
  bkDefs,bkConst,software, WorkRecDefs, baObj32, MoneyDef, ovcnf, Globals, StdCtrls;

type
   SFRevenue = ( TaxFreeDist,TaxExemptDist,TaxDeferredDist,
                 ForeignIncome,
                 CapitalGainsIndexed, CapitalGainsDisc, CapitalGainsOther, CapitalGainsForeignDisc,
                 OtherExpenses,
                 Interest,
                 Rent,
                 SpecialIncome
                 );

 

type
   PmemSplitRec = ^TmemSplitRec;
   TmemSplitRec = record
     AcctCode      : ShortString;
     Desc          : string[60];
     GSTClassCode  : string[GST_CLASS_CODE_LENGTH];
     Amount        : double;
     GST_Has_Been_Edited : boolean;
     Narration     : string[ MaxNarrationEditLength];
     LineType      : integer;
     Payee         : integer;

     SF_PCFranked  : Money;
     SF_PCUNFranked : Money;

     SF_Member_ID  : string[20];

     SF_Fund_ID: Integer;
     SF_Fund_Code: string[20];

     SF_Trans_ID: Integer;
     SF_Trans_Code: AnsiString;

     SF_Member_Account_ID: Integer;
     SF_Member_Account_Code: string[41];
     SF_Member_Component: Byte;

     SF_Edited: Boolean;

     Quantity: Money;

     SF_GDT_Date: Integer;
     SF_Tax_Free_Dist: Money;
     SF_Tax_Exempt_Dist: Money;
     SF_Tax_Deferred_Dist: Money;
     SF_TFN_Credits: Money;
     SF_Foreign_Income: Money;
     SF_Foreign_Tax_Credits: Money;
     SF_Capital_Gains_Indexed: Money;
     SF_Capital_Gains_Disc: Money;
     SF_Capital_Gains_Other: Money;
     SF_Other_Expenses: Money;
     SF_Interest: Money;
     SF_Capital_Gains_Foreign_Disc: Money;
     SF_Rent: Money;
     SF_Special_Income: Money;
     SF_Other_Tax_Credit: Money;
     SF_Non_Resident_Tax: Money;
     SF_Foreign_Capital_Gains_Credit: Money;
     SF_Capital_Gains_Fraction_Half: Boolean;
     SF_Ledger_ID: Integer;
     SF_Ledger_Name: AnsiString;
     JobCode       : string [8];
  end;




  procedure ClearSuperfundDetails(mwr: PmemSplitRec); overload;
  procedure ClearWorkRecDetails(mwr: PmemSplitRec); overload;

  function EditSuperFields( pT : pTransaction_Rec; var Move: TFundNavigation; var T, L: Integer; BA: TBank_Account = nil) : boolean; overload;
  function EditSuperFields(  ParentTrans : pTransaction_Rec; pWD : pWorkDissect_Rec;
                             var Move: TFundNavigation; var T, L: Integer; BA: TBank_Account = nil) : boolean; overload;

  function EditSuperFields(  ParentTrans : pTransaction_Rec; pWJ : pWorkJournal_Rec;
                             var Move: TFundNavigation; var T, L: Integer; BA: TBank_Account = nil) : boolean; overload;

  function EditSuperFields(  ParentTrans : pTransaction_Rec; var Mem : TmemSplitRec;
                             var Move: TFundNavigation; var T, L: Integer;
                             aSDMode : TSuperDialogMode;
                             BA: TBank_Account = nil
                             ) : boolean; overload;

  function CompanyTax(ForDate: Integer): Money;

  procedure CalcFrankAmount(const Amount: Double; var SetFrank, GetFrank: Double); overload;
  procedure CalcFrankAmount(const Amount: Double; SetFrank, GetFrank: TOvcNumericField); overload;

  function FrankingCredit(Amount: Money; ForDate: Integer): Money;

  function CheckFrankingCredit(Amount: Double;
                         ForDate: integer; Credit: TOvcNumericField; Update: Boolean = false): Boolean;

  function GetSFMemberText(ForDate, Index: Integer; Short: Boolean): shortstring;

  procedure SetPercentLabel(aLabel: tLabel; isPercentage: Boolean);

  procedure SetNumericValue(Control: TOvcNumericField; Value :Money; isPercentage: Boolean);
  function GetNumericValue(Control: TOvcNumericField; isPercentage: Boolean): money;

  procedure SplitRevenue(Amount: Money;
     var TaxFreeDist,TaxExemptDist,TaxDeferredDist,
         ForeignIncome,
         CapitalGainsIndexed, CapitalGainsDisc, CapitalGainsOther, CapitalGainsForeignDisc,
         OtherExpenses,
         Interest,
         Rent,
         SpecialIncome : Money; Line: pMemorisation_Line_Rec); overload;

   procedure SplitRevenue(Amount: Money;
     var TaxFreeDist,TaxExemptDist,TaxDeferredDist,
         ForeignIncome,
         CapitalGainsIndexed, CapitalGainsDisc, CapitalGainsOther, CapitalGainsForeignDisc,
         OtherExpenses,
         Interest,
         Rent,
         SpecialIncome : Money; Line: pPayee_Line_Rec); overload;



implementation

uses
  EditSuperFieldsDlg, EditSupervisorFieldsDlg, Usageutils, EditDesktopFieldsDlg,
  sysUtils, forms,Math, controls, GLConst,GenUtils,TransactionUtils, graphics,
  EditSageHandisoftSuperFieldsDlg;


  procedure SplitRevenue(Amount: Money;
     var TaxFreeDist,TaxExemptDist,TaxDeferredDist,
         ForeignIncome,
         CapitalGainsIndexed, CapitalGainsDisc, CapitalGainsOther, CapitalGainsForeignDisc,
         OtherExpenses,
         Interest,
         Rent,
         SpecialIncome : Money; Line: pMemorisation_Line_Rec);

  var TotalRate, Remainder: Money;

      procedure MakeAmount(var Value: Money; Rate: Money);
      begin
         if Rate = 0 then
            Value := 0
         else begin
            TotalRate := TotalRate + Rate;
            if TotalRate = 1000000 then begin
               Value := Remainder; // 100% just copy the leftover, stop rounding errors
            end else begin
               Value := abs(Double2Money (Percent2Double(Rate) * Money2Double(Amount)/100));
            end;
         end;
         Remainder := Remainder - Value;
      end;

  begin
     {if Line.mlLine_Type = mltPercentage then begin}
        // Split as percentage..
        TotalRate := 0;
        Remainder := abs(Amount);
        MakeAmount(TaxFreeDist, Line.mlSF_Tax_Free_Dist);
        MakeAmount(TaxExemptDist, Line.mlSF_Tax_Exempt_Dist);
        MakeAmount(TaxDeferredDist, Line.mlSF_Tax_Deferred_Dist);
        MakeAmount(ForeignIncome, Line.mlSF_Foreign_Income);
        MakeAmount(CapitalGainsIndexed, Line.mlSF_Capital_Gains_Indexed);
        MakeAmount(CapitalGainsDisc, Line.mlSF_Capital_Gains_Disc);
        MakeAmount(CapitalGainsOther, Line.mlSF_Capital_Gains_Other);
        MakeAmount(CapitalGainsForeignDisc, Line.mlSF_Capital_Gains_Foreign_Disc);
        MakeAmount(OtherExpenses, Line.mlSF_Other_Expenses);
        MakeAmount(Interest, Line.mlSF_Interest);
        MakeAmount(Rent, Line.mlSF_Rent);
        MakeAmount(SpecialIncome, Line.mlSF_Special_Income);
     {end else begin
        // Just use the amounts...
        TaxFreeDist := Line.mlSF_Tax_Free_Dist;
        TaxExemptDist := Line.mlSF_Tax_Exempt_Dist;
        TaxDeferredDist := Line.mlSF_Tax_Deferred_Dist;
        ForeignIncome := Line.mlSF_Foreign_Income;
        CapitalGainsIndexed := Line.mlSF_Capital_Gains_Indexed;
        CapitalGainsDisc := Line.mlSF_Capital_Gains_Disc;
        CapitalGainsOther := Line.mlSF_Capital_Gains_Other;
        CapitalGainsForeignDisc := Line.mlSF_Capital_Gains_Foreign_Disc;
        OtherExpenses := Line.mlSF_Other_Expenses;
        Interest := Line.mlSF_Interest;
        Rent := Line.mlSF_Rent;
        SpecialIncome := Line.mlSF_Special_Income;
     end; }
  end;


  procedure SplitRevenue(Amount: Money;
     var TaxFreeDist,TaxExemptDist,TaxDeferredDist,
         ForeignIncome,
         CapitalGainsIndexed, CapitalGainsDisc, CapitalGainsOther, CapitalGainsForeignDisc,
         OtherExpenses,
         Interest,
         Rent,
         SpecialIncome : Money; Line: pPayee_Line_Rec);

  var TotalRate, Remainder: Money;

      procedure MakeAmount(var Value: Money; Rate: Money);
      begin
         if Rate = 0 then
            Value := 0
         else begin
            TotalRate := TotalRate + Rate;
            if TotalRate = 1000000 then begin
               Value := Remainder; // 100% just copy the leftover, stop rounding errors
            end else begin
               Value := abs(Double2Money (Percent2Double(Rate) * Money2Double(Amount)/100));
            end;
         end;
         Remainder := Remainder - Value;
      end;

  begin
     {if Line.mlLine_Type = mltPercentage then begin}
        // Split as percentage..
        TotalRate := 0;
        Remainder := abs(Amount);
        MakeAmount(TaxFreeDist, Line.plSF_Tax_Free_Dist);
        MakeAmount(TaxExemptDist, Line.plSF_Tax_Exempt_Dist);
        MakeAmount(TaxDeferredDist, Line.plSF_Tax_Deferred_Dist);
        MakeAmount(ForeignIncome, Line.plSF_Foreign_Income);
        MakeAmount(CapitalGainsIndexed, Line.plSF_Capital_Gains_Indexed);
        MakeAmount(CapitalGainsDisc, Line.plSF_Capital_Gains_Disc);
        MakeAmount(CapitalGainsOther, Line.plSF_Capital_Gains_Other);
        MakeAmount(CapitalGainsForeignDisc, Line.plSF_Capital_Gains_Foreign_Disc);
        MakeAmount(OtherExpenses, Line.plSF_Other_Expenses);
        MakeAmount(Interest, Line.plSF_Interest);
        MakeAmount(Rent, Line.plSF_Rent);
        MakeAmount(SpecialIncome, Line.plSF_Special_Income);
     {end else begin
        // Just use the amounts...
        TaxFreeDist := Line.mlSF_Tax_Free_Dist;
        TaxExemptDist := Line.mlSF_Tax_Exempt_Dist;
        TaxDeferredDist := Line.mlSF_Tax_Deferred_Dist;
        ForeignIncome := Line.mlSF_Foreign_Income;
        CapitalGainsIndexed := Line.mlSF_Capital_Gains_Indexed;
        CapitalGainsDisc := Line.mlSF_Capital_Gains_Disc;
        CapitalGainsOther := Line.mlSF_Capital_Gains_Other;
        CapitalGainsForeignDisc := Line.mlSF_Capital_Gains_Foreign_Disc;
        OtherExpenses := Line.mlSF_Other_Expenses;
        Interest := Line.mlSF_Interest;
        Rent := Line.mlSF_Rent;
        SpecialIncome := Line.mlSF_Special_Income;
     end; }
  end;

procedure SetPercentLabel(aLabel: tLabel; isPercentage: Boolean);
begin
   if isPercentage then begin
      aLabel.Visible := True;
      if Assigned(aLabel.FocusControl) then
         if aLabel.FocusControl is TOvcNumericField then
            TOvcNumericField(aLabel.FocusControl).PictureMask := PercentMask;
   end else begin
      if assigned(aLabel.FocusControl) then
         if aLabel.FocusControl is TOvcNumericField then
            TOvcNumericField(aLabel.FocusControl).PictureMask := MoneyMask;
      aLabel.Visible := False;
   end;
end;

procedure SetNumericValue(Control: TOvcNumericField; Value :Money; isPercentage: Boolean);
begin
   if isPercentage then
      Control.AsFloat:= Percent2Double(Value)
   else
      Control.AsFloat:= Money2Double(Value);
end;


function GetNumericValue(Control: TOvcNumericField; isPercentage: Boolean): money;
begin
   if isPercentage then
      Result := Double2Percent(Control.asFloat)
   else
      Result := Double2Money(Control.asFloat);
end;

procedure ClearWorkRecDetails(mwr: PmemSplitRec); overload;
begin
   FillChar(mwr^, Sizeof(TmemSplitRec), 0);
   mwr^.LineType := mltPercentage;
   ClearSuperfundDetails(mwr);
end;

procedure ClearSuperfundDetails(mwr: PmemSplitRec); overload;
begin
   with mwr^ do begin
     SF_PCFranked := 0;
     SF_PCUnFranked := 0;

     SF_Member_ID := '';

     SF_Fund_ID := -1;
     SF_Fund_Code := '';

     SF_Trans_ID := -1;
     SF_Trans_Code := '';

     SF_Member_Account_ID := -1;
     SF_Member_Account_Code := '';
     SF_Member_Component := 0;
     SF_Edited := false;

     Quantity := 0;

     SF_GDT_Date := 0;
     SF_Tax_Free_Dist := 0;
     SF_Tax_Exempt_Dist := 0;
     SF_Tax_Deferred_Dist := 0;
     SF_TFN_Credits := 0;
     SF_Foreign_Income := 0;
     SF_Foreign_Tax_Credits := 0;
     SF_Capital_Gains_Indexed := 0;
     SF_Capital_Gains_Disc := 0;
     SF_Capital_Gains_Other := 0;
     SF_Other_Expenses := 0;
     SF_Interest := 0;
     SF_Capital_Gains_Foreign_Disc := 0;
     SF_Rent := 0;
     SF_Special_Income := 0;
     SF_Other_Tax_Credit := 0;
     SF_Non_Resident_Tax := 0;
     SF_Foreign_Capital_Gains_Credit := 0;
     SF_Capital_Gains_Fraction_Half := False;
     SF_Ledger_ID := -1;
     SF_Ledger_Name := '';
   end;
end;


function GetSFMemberText(ForDate, Index: Integer; Short: Boolean): shortstring;
begin
   if (Fordate = 0)
   or (ForDate >= mcSwitchDate) then  begin
      // Use the New List
      if (index >= mcNewMin)
      and (Index <= mcNewMax) then begin
         if Short then
            Result := mcNewCharacters[Index]
         else
            Result := mcNewNames[Index]
      end else
         Result := 'Wrong ID'
   end else begin
      // Use the Old List
      if (index >= mcOldMin)
      and (Index <= mcOldMax) then begin
         if Short then
            Result := mcOldCharacters[Index]
         else
            Result := mcOldNames[Index]
      end else
         Result := 'Wrong ID'
   end;
end;

procedure CalcFrankAmount(const Amount: Double; var SetFrank, GetFrank: Double);
begin
   if SetFrank >= Amount  then begin
      SetFrank := Amount;
      GetFrank := 0.0;
   end else if SetFrank <= Amount then begin
      GetFrank := Amount;
      SetFrank := 0.0;
   end else
      GetFrank := Amount - SetFrank;

end;

function FrankingCredit(Amount: Money; ForDate: Integer): Money;
var Tax: Double;
begin
   Tax := GSTRate2Double(CompanyTax(ForDate));

   // Workout the Imputed Credit
   if (Amount <> 0)
   and (Tax <> 0) then
      Result := Double2Money( MyRoundDouble(Money2Double(Amount) * (Tax/(100-Tax)),2))
   else
      Result := 0;
end;

function CheckFrankingCredit(Amount: Double;
                              ForDate: integer;
                              Credit: TOvcNumericField;
                              Update: Boolean = false): Boolean;
var
   Tax, lAmount: Double;
   dp: Integer;
const clOrange = $000080FF;
begin
   Tax := GSTRate2Double(CompanyTax(ForDate));
   lAmount := Abs(AMount);
   // Workout the Imputed Credit
   if (lAmount <> 0)
   and (Tax <> 0) then begin
      dp := Length(Credit.Picturemask) - Pos('.',Credit.Picturemask);
      if dp > 6 then
         dp := 2;
      lAmount := MyRoundDouble(Amount * (Tax/(100-Tax)),dp)
   end else
      LAmount := 0;

   if Update then begin
       // Update Imputed Credit ..
      Credit.AsFloat := lAmount;
      Credit.Color := clwindow;
      Credit.Modified := False;
      Result := False;

   end else begin
      //Just check Imputed Credit ..
      if lAmount <> Credit.AsFloat then begin
          Credit.Color := clOrange;
          // Make sure we set/keep this
          Credit.Modified := True;
          Result := True;
      end else begin
          Credit.Color := clwindow;
          Result := False;
      end;
   end;
end;





procedure CalcFrankAmount(const Amount: Double; SetFrank, GetFrank: TOvcNumericField); overload;
var Test: Double;
    abAmount: Double;
begin
   abAmount := Abs(Amount);
   Test := SetFrank.asFloat;

   if Test > abAmount  then begin
      SetFrank.asFloat := abAmount;
      GetFrank.asFloat := 0.0;
   end else if Test <= 0 then begin
      GetFrank.asFloat := abAmount;
      SetFrank.asFloat := 0.0;
   end else
      GetFrank.asFloat := abAmount - Test;
end;


function CompanyTax(ForDate: Integer): Money;
var D: Integer;
begin
    if Assigned(MyClient) then with MyClient.clExtra do begin
       for D  := High(ceTAX_Applies_From[tt_CompanyTax]) downto low(ceTAX_Applies_From[tt_CompanyTax]) do
          if (ceTAX_Applies_From[tt_CompanyTax][D] > 0)
          and (ForDate >= ceTAX_Applies_From[tt_CompanyTax][D]) then begin
             Result := ceTAX_Rates[tt_CompanyTax][D];
             Exit;
          end;
   end;

   if Assigned(AdminSystem) then with AdminSystem.fdFields do begin
      for D  := High(fdTAX_Applies_From[tt_CompanyTax]) downto low(fdTAX_Applies_From[tt_CompanyTax]) do
         if (fdTAX_Applies_From[tt_CompanyTax][D] > 0)
         and (ForDate >= fdTAX_Applies_From[tt_CompanyTax][D]) then begin
            Result := fdTAX_Rates[tt_CompanyTax][D];
            Exit;
         end;
   end;
   {if fordate = 0 then}
      Result := Double2percent(30.0);
end;



//*****************************************************************************************
//
//   BGL
//
//*****************************************************************************************


// BGL Transaction
function EditBGLFields( pT : pTransaction_Rec; var Move: TFundNavigation; var T, L: Integer) : boolean; overload;
var
  SuperForm : TdlgEditSuperFields;
begin
  result := false;
  SuperForm := TdlgEditSuperFields.Create( Application.MainForm);
  try
    Superform.RevenuePercentage := False;
    Superform.FrankPercentage := False;

    SuperForm.SetInfo( pT^.txDate_Effective, pT^.txGL_Narration, pT^.txAmount);

    SuperForm.SetFields( pT^.txSF_Imputed_Credit,
                         pT^.txSF_Tax_Free_Dist,
                         pT^.txSF_Tax_Exempt_Dist,
                         pT^.txSF_Tax_Deferred_Dist,
                         pT^.txSF_TFN_Credits,
                         pT^.txSF_Foreign_Income,
                         pT^.txSF_Foreign_Tax_Credits,
                         pT^.txSF_Capital_Gains_Indexed,
                         pT^.txSF_Capital_Gains_Disc,
                         pT^.txSF_Other_Expenses,
                         pT^.txSF_Capital_Gains_Other,
                         pT^.txSF_Franked,
                         pT^.txSF_Unfranked,
                         pT^.txSF_CGT_Date,
                         pT^.txSF_Member_Component,
                         pT^.txQuantity,
                         pT^.txAccount
                         );
    SuperForm.ReadOnly := ( pT^.txLocked)
                       or ( pT^.txDate_Transferred <> 0);
    SuperForm.MoveDirection := Move;
    if T > -999 then
    begin
      SuperForm.FormTop := T;
      SuperForm.FormLeft := L;
    end
    else
      SuperForm.Position := poScreenCenter;
    if SuperForm.ShowModal = mrOK then
      begin
        Move := SuperForm.MoveDirection;
        pT^.txSF_Super_Fields_Edited := SuperForm.GetFields( pT^.txSF_Imputed_Credit,
                             pT^.txSF_Tax_Free_Dist,
                             pT^.txSF_Tax_Exempt_Dist,
                             pT^.txSF_Tax_Deferred_Dist,
                             pT^.txSF_TFN_Credits,
                             pT^.txSF_Foreign_Income,
                             pT^.txSF_Foreign_Tax_Credits,
                             pT^.txSF_Capital_Gains_Indexed,
                             pT^.txSF_Capital_Gains_Disc,
                             pT^.txSF_Other_Expenses,
                             pT^.txSF_Capital_Gains_Other,
                             pT^.txSF_Franked,
                             pT^.txSF_Unfranked,
                             pT^.txSF_CGT_Date,
                             pT^.txSF_Member_Component,
                             pT^.txAccount,
                             pT^.txQuantity);

        if pT^.txSF_Super_Fields_Edited then begin
           pT^.txHas_Been_Edited := true;
           pT^.txCoded_By := cbManualSuper;
        end else begin
           ClearSuperFundFields(pt);
           pT^.txCoded_By := cbManual; //Will get cleaned up
        end;

        if Move in [fnGoForward, fnGoBack] then
        begin
          T := SuperForm.Top;
          L := SuperForm.Left;
        end;
        Result := true;
      end;
  finally
    SuperForm.Release;
  end;
end;

//BGL Journal
function EditBGLFields(  ParentTrans : pTransaction_Rec; pWJ : pWorkJournal_Rec; var Move: TFundNavigation; var T, L: Integer) : boolean; overload;
var
  SuperForm : TdlgEditSuperFields;
begin
  result := false;
  SuperForm := TdlgEditSuperFields.Create( Application.MainForm);
  try
    SuperForm.SetInfo( ParentTrans.txDate_Effective, pWJ^.dtNarration, pWJ^.dtAmount);
    Superform.RevenuePercentage := False;
    Superform.FrankPercentage := False;

    SuperForm.SetFields( pWJ^.dtSF_Imputed_Credit,
                         pWJ^.dtSF_Tax_Free_Dist,
                         pWJ^.dtSF_Tax_Exempt_Dist,
                         pWJ^.dtSF_Tax_Deferred_Dist,
                         pWJ^.dtSF_TFN_Credits,
                         pWJ^.dtSF_Foreign_Income,
                         pWJ^.dtSF_Foreign_Tax_Credits,
                         pWJ^.dtSF_Capital_Gains_Indexed,
                         pWJ^.dtSF_Capital_Gains_Disc,
                         pWJ^.dtSF_Other_Expenses,
                         pWJ^.dtSF_Capital_Gains_Other,
                         pWJ^.dtSF_Franked,
                         pWJ^.dtSF_Unfranked,
                         pWJ^.dtSF_CGT_Date,
                         pWJ^.dtSF_Member_Component,
                         PWJ^.dtQuantity,
                         PWJ^.dtAccount);

    SuperForm.ReadOnly := ( ParentTrans.txLocked) or ( ParentTrans.txDate_Transferred <> 0);
    SuperForm.MoveDirection := Move;
    if T > -999 then
    begin
      SuperForm.FormTop := T;
      SuperForm.FormLeft := L;
    end
    else
      SuperForm.Position := poScreenCenter;
    if SuperForm.ShowModal = mrOK then
      begin
        Move := SuperForm.MoveDirection;
        pWJ^.dtSF_Super_Fields_Edited := SuperForm.GetFields( pWJ^.dtSF_Imputed_Credit,
                             pWJ^.dtSF_Tax_Free_Dist,
                             pWJ^.dtSF_Tax_Exempt_Dist,
                             pWJ^.dtSF_Tax_Deferred_Dist,
                             pWJ^.dtSF_TFN_Credits,
                             pWJ^.dtSF_Foreign_Income,
                             pWJ^.dtSF_Foreign_Tax_Credits,
                             pWJ^.dtSF_Capital_Gains_Indexed,
                             pWJ^.dtSF_Capital_Gains_Disc,
                             pWJ^.dtSF_Other_Expenses,
                             pWJ^.dtSF_Capital_Gains_Other,
                             pWJ^.dtSF_Franked,
                             pWJ^.dtSF_Unfranked,
                             pWJ^.dtSF_CGT_Date,
                             pWJ^.dtSF_Member_Component,
                             pWJ^.dtAccount,
                             pWJ^.dtQuantity);
        if Move in [fnGoForward, fnGoBack] then
        begin
          T := SuperForm.Top;
          L := SuperForm.Left;
        end;
        Result := true;
      end;
  finally
    SuperForm.Release;
  end;
end;

// BGL Disection
function EditBGLFields( ParentTrans : pTransaction_Rec; pWD : pWorkDissect_Rec; var Move: TFundNavigation; var T, L: Integer) : boolean; overload;
var
  SuperForm : TdlgEditSuperFields;
begin
  result := false;
  SuperForm := TdlgEditSuperFields.Create( Application.MainForm);
  try
    SuperForm.SetInfo( ParentTrans.txDate_Effective, pWD^.dtNarration, pWD^.dtAmount);
    Superform.RevenuePercentage := False;
    Superform.FrankPercentage := False;
    SuperForm.SetFields( pWD^.dtSF_Imputed_Credit,
                         pWD^.dtSF_Tax_Free_Dist,
                         pWD^.dtSF_Tax_Exempt_Dist,
                         pWD^.dtSF_Tax_Deferred_Dist,
                         pWD^.dtSF_TFN_Credits,
                         pWD^.dtSF_Foreign_Income,
                         pWD^.dtSF_Foreign_Tax_Credits,
                         pWD^.dtSF_Capital_Gains_Indexed,
                         pWD^.dtSF_Capital_Gains_Disc,
                         pWD^.dtSF_Other_Expenses,
                         pWD^.dtSF_Capital_Gains_Other,
                         pWD^.dtSF_Franked,
                         pWD^.dtSF_Unfranked,
                         pWD^.dtSF_CGT_Date,
                         pWD^.dtSF_Member_Component,
                         pWD^.dtQuantity,
                         pWD^.dtAccount);
    SuperForm.ReadOnly := ( ParentTrans.txLocked) or ( ParentTrans.txDate_Transferred <> 0);
    SuperForm.MoveDirection := Move;
    if T > -999 then
    begin
      SuperForm.FormTop := T;
      SuperForm.FormLeft := L;
    end
    else
      SuperForm.Position := poScreenCenter;
    if SuperForm.ShowModal = mrOK then
      begin
        Move := SuperForm.MoveDirection;
        pWD^.dtSuper_Fields_Edited := SuperForm.GetFields( pWD^.dtSF_Imputed_Credit,
                             pWD^.dtSF_Tax_Free_Dist,
                             pWD^.dtSF_Tax_Exempt_Dist,
                             pWD^.dtSF_Tax_Deferred_Dist,
                             pWD^.dtSF_TFN_Credits,
                             pWD^.dtSF_Foreign_Income,
                             pWD^.dtSF_Foreign_Tax_Credits,
                             pWD^.dtSF_Capital_Gains_Indexed,
                             pWD^.dtSF_Capital_Gains_Disc,
                             pWD^.dtSF_Other_Expenses,
                             pWD^.dtSF_Capital_Gains_Other,
                             pWD^.dtSF_Franked,
                             pWD^.dtSF_Unfranked,
                             pWD^.dtSF_CGT_Date,
                             pWD^.dtSF_Member_Component,
                             pWD^.dtAccount,
                             pWD^.dtQuantity);
        if Move in [fnGoForward, fnGoBack] then
        begin
          T := SuperForm.Top;
          L := SuperForm.Left;
        end;
        Result := true;
      end;
  finally
    SuperForm.Release;
  end;
end;


// BGL Memorization
function EditBGLFields(ParentTrans : pTransaction_Rec; var Mem : TmemSplitRec; var Move: TFundNavigation; var T, L: Integer) : boolean; overload;
var
  SuperForm: TdlgEditSuperFields;
  ForDate: Integer;
  Narration: string;
  Amount: Money;

begin
  Result := false;
  SuperForm := TdlgEditSuperFields.Create(Application.MainForm);
  try

    if Assigned(ParentTrans) then begin
       ForDate := max( ParentTrans.txDate_Effective, mcSwitchDate);
       Narration := ParentTrans.txGL_Narration;

       case Mem.LineType of
          mltPercentage : begin
                Amount := Double2Money(Mem.Amount * Money2Double(ParentTrans.txAmount) / 100);
                //SuperForm.RevenuePercentage := True;
             end;
          else begin
                Amount := Double2Money(Mem.Amount);
                //SuperForm.RevenuePercentage := False;
          end;
       end;

    end else begin
       ForDate := 0;
       Narration := '';
       case Mem.LineType of
          mltPercentage :  begin
                Amount := Double2Percent(Mem.Amount);
                //SuperForm.RevenuePercentage := True;
          end
          else begin
                Amount := Double2Money(Mem.Amount);
                //SuperForm.RevenuePercentage := False;
          end;
       end;
    end;
    SuperForm.RevenuePercentage := True;
    SuperForm.MemOnly := True;
    SuperForm.SetInfo(Fordate, Narration, Amount);
    Superform.FrankPercentage := True;


     {
    mImputedCredit, mTaxFreeDist,
  mTaxExemptDist, mTaxDeferredDist, mTFNCredits, mForeignIncome,
  mForeignTaxCredits, mCapitalGains, mDiscountedCapitalGains,
  mOtherExpenses, mCapitalGainsOther, mFranked, mUnfranked : Money;
  dCGTDate: integer; mComponent : byte; mUnits: Money; mAccount: string
  }
    Amount := 0; // Just a temp value
    SuperForm.SetFields (Amount,
                         Mem.SF_Tax_Free_Dist,
                         Mem.SF_Tax_Exempt_Dist,
                         Mem.SF_Tax_Deferred_Dist,
                         Mem.SF_TFN_Credits,
                         Mem.SF_Foreign_Income,

                         Mem.SF_Foreign_Tax_Credits,
                         Mem.SF_Capital_Gains_Indexed,
                         Mem.SF_Capital_Gains_Disc,
                         Mem.SF_Other_Expenses,

                         Mem.SF_Capital_Gains_Other,

                         Mem.SF_PCFranked,
                         Mem.SF_PCUnFranked,

                         mem.SF_GDT_Date,

                         Mem.SF_Member_Component,
                         Mem.Quantity,
                         Mem.AcctCode
                        );

    SuperForm.MoveDirection := Move;
    if T > -999 then begin
        SuperForm.FormTop := T;
        SuperForm.FormLeft := L;
    end else
       SuperForm.Position := poScreenCenter;

    if SuperForm.ShowModal = mrOK then begin
        Move := SuperForm.MoveDirection;

        Mem.SF_Edited := SuperForm.GetFields(Amount,
                         Mem.SF_Tax_Free_Dist,
                         Mem.SF_Tax_Exempt_Dist,
                         Mem.SF_Tax_Deferred_Dist,
                         Mem.SF_TFN_Credits,
                         Mem.SF_Foreign_Income,

                         Mem.SF_Foreign_Tax_Credits,
                         Mem.SF_Capital_Gains_Indexed,
                         Mem.SF_Capital_Gains_Disc,
                         Mem.SF_Other_Expenses,

                         Mem.SF_Capital_Gains_Other,


                         Mem.SF_PCFranked,
                         Mem.SF_PCUnFranked,

                         mem.SF_GDT_Date,

                         Mem.SF_Member_Component,

                         Mem.AcctCode,
                         Mem.Quantity);

        if Move in [fnGoForward, fnGoBack] then begin
           T := SuperForm.Top;
           L := SuperForm.Left;
        end;
        Result := True;
    end;
  finally
    SuperForm.Release;
  end;
end;


//*****************************************************************************************
//
//   Sage Handisoft Superfund
//
//*****************************************************************************************

// Transaction
function EditSageHandisoftFields( pT : pTransaction_Rec; var Move: TFundNavigation; var T, L: Integer) : boolean; overload;
var
  SuperForm: TdlgEditSageHandisoftSuperFields;
begin
  Result := False;
  SuperForm := TdlgEditSageHandisoftSuperFields.Create( Application.Mainform );
  try
    //Setup
    SuperForm.SetInfo( pT^.txDate_Effective, pT^.txGL_Narration, pT^.txAmount );
    SuperForm.FrankPercentage := False;
    SuperForm.SetFields( pT^.txSF_Transaction_ID,
                         pT^.txSF_Transaction_Code,
                         pT^.txQuantity,
                         pT^.txSF_Franked,
                         pT^.txSF_Unfranked,
                         pT^.txSF_Imputed_Credit );
    SuperForm.ReadOnly := ( pT^.txLocked) or ( pT^.txDate_Transferred <> 0);
    SuperForm.MoveDirection := Move;
    if T > -999 then begin
      SuperForm.FormTop := T;
      SuperForm.FormLeft := L;
    end else
      SuperForm.Position := poScreenCenter;

    //Show
    if SuperForm.ShowModal = mrOK then begin
      Move := SuperForm.MoveDirection;
      //Save changes
      pT^.txSF_Super_Fields_Edited := SuperForm.GetFields( pT^.txSF_Transaction_ID,
                                                           pT^.txSF_Transaction_Code,
                                                           pT^.txQuantity,
                                                           pT^.txSF_Franked,
                                                           pT^.txSF_Unfranked,
                                                           pT^.txSF_Imputed_Credit  );
      if pT^.txSF_Super_Fields_Edited then begin
        pT^.txHas_Been_Edited := true;
        pT^.txCoded_By := cbManualSuper;
      end else begin
        ClearSuperFundFields(pt);
        pT^.txCoded_By := cbManual; //Will get cleaned up
      end;

      if Move in [fnGoForward, fnGoBack] then begin
        T := SuperForm.Top;
        L := SuperForm.Left;
      end;
      Result := True;
    end;
  finally
    SuperForm.Release;
  end;
end;

// Dissection
function EditSageHandisoftFields( ParentTrans : pTransaction_Rec; pWD : pWorkDissect_Rec; var Move: TFundNavigation; var T, L: Integer) : boolean; overload;
var
  SuperForm: TdlgEditSageHandisoftSuperFields;
begin
  Result := False;
  SuperForm := TdlgEditSageHandisoftSuperFields.Create( Application.Mainform );
  try
    //Setup
    SuperForm.SetInfo( ParentTrans.txDate_Effective, pWD^.dtNarration, pWD^.dtAmount );
    SuperForm.FrankPercentage := False;
    SuperForm.SetFields( pWD^.dtSF_Transaction_Type_ID,
                         pWD^.dtSF_Transaction_Type_Code,
                         pWD^.dtQuantity,
                         pWD^.dtSF_Franked,
                         pWD^.dtSF_Unfranked,
                         pWD^.dtSF_Imputed_Credit );
    SuperForm.ReadOnly := ( ParentTrans^.txLocked) or ( ParentTrans^.txDate_Transferred <> 0);
    SuperForm.MoveDirection := Move;
    if T > -999 then begin
      SuperForm.FormTop := T;
      SuperForm.FormLeft := L;
    end else
      SuperForm.Position := poScreenCenter;

    //Show
    if SuperForm.ShowModal = mrOK then begin
      Move := SuperForm.MoveDirection;
      //Save changes
      pWD^.dtSuper_Fields_Edited :=
        SuperForm.GetFields( pWD^.dtSF_Transaction_Type_ID,
                             pWD^.dtSF_Transaction_Type_Code,
                             pWD^.dtQuantity,
                             pWD^.dtSF_Franked,
                             pWD^.dtSF_Unfranked,
                             pWD^.dtSF_Imputed_Credit);
      if Move in [fnGoForward, fnGoBack] then begin
        T := SuperForm.Top;
        L := SuperForm.Left;
      end;
      Result := True;
    end;
  finally
    SuperForm.Release;
  end;
end;


// Journal
function EditSageHandisoftFields( ParentTrans : pTransaction_Rec; pWJ : pWorkJournal_Rec; var Move: TFundNavigation; var T, L: Integer) : boolean; overload;
var
  SuperForm : TdlgEditSageHandisoftSuperFields;
begin
  Result := false;
  SuperForm := TdlgEditSageHandisoftSuperFields.Create( Application.Mainform);
  try
    SuperForm.SetInfo( ParentTrans.txDate_Effective, pWJ^.dtNarration, pWJ^.dtAmount);
    SuperForm.FrankPercentage := False;
    SuperForm.SetFields( pWJ^.dtSF_Transaction_Type_ID,
                         pWJ^.dtSF_Transaction_Type_Code,
                         pWJ^.dtQuantity,
                         pWJ^.dtSF_Franked,
                         pWJ^.dtSF_Unfranked,
                         pWJ^.dtSF_Imputed_Credit);

    SuperForm.ReadOnly := ( ParentTrans.txLocked) or ( ParentTrans.txDate_Transferred <> 0);
    SuperForm.MoveDirection := Move;
    if T > -999 then
    begin
      SuperForm.FormTop := T;
      SuperForm.FormLeft := L;
    end
    else
      SuperForm.Position := poScreenCenter;
    if SuperForm.ShowModal = mrOK then
      begin
        Move := SuperForm.MoveDirection;
        pWJ^.dtSF_Super_Fields_Edited := SuperForm.GetFields(pWJ^.dtSF_Transaction_Type_ID,
                                                             pWJ^.dtSF_Transaction_Type_Code,
                                                             pWJ^.dtQuantity,
                                                             pWJ^.dtSF_Franked,
                                                             pWJ^.dtSF_Unfranked,
                                                             pWJ^.dtSF_Imputed_Credit);
        if Move in [fnGoForward, fnGoBack] then
        begin
          T := SuperForm.Top;
          L := SuperForm.Left;
        end;
        Result := true;
      end;
  finally
    SuperForm.Release;
  end;
end;

//SageHandisoft Memorization
function EditSageHandisoftFields( ParentTrans : pTransaction_Rec; var Mem : TmemSplitRec; var Move: TFundNavigation; var T, L: Integer) : boolean; overload;
var
   SuperForm: TdlgEditSageHandisoftSuperFields;
   ForDate: Integer;
   Narration: string;
   Amount: Money;
begin
  Result := false;
  SuperForm := TdlgEditSageHandisoftSuperFields.Create( Application.Mainform);
  try
    if Assigned(ParentTrans) then begin
       ForDate := ParentTrans.txDate_Effective;
       Narration := ParentTrans.txGL_Narration;

       case Mem.LineType of
          mltPercentage :  begin
             Amount := Double2Money  (Mem.Amount * Money2Double(ParentTrans.txAmount) / 100);
          end;
          else begin
             Amount := Double2Money(Mem.Amount);
          end;
       end;

    end else begin
       ForDate := 0;
       Narration := '';
       case Mem.LineType of
          mltPercentage :  begin
             Amount := Double2Percent(Mem.Amount);
          end
          else begin
             Amount := Double2Money(Mem.Amount);
          end;
       end;
    end;

    SuperForm.SetInfo(Fordate, Narration, Amount );
    SuperForm.FrankPercentage := True;
    Amount := 0;
    SuperForm.SetFields( mem.SF_Trans_ID,
                         mem.SF_Trans_Code,
                         mem.Quantity,
                         mem.SF_PCFranked,
                         mem.SF_PCUNFranked,
                         Amount);

   // SuperForm.ReadOnly := ( ParentTrans.txLocked) or ( ParentTrans.txDate_Transferred <> 0);
    SuperForm.MoveDirection := Move;
    if T > -999 then
    begin
      SuperForm.FormTop := T;
      SuperForm.FormLeft := L;
    end
    else
      SuperForm.Position := poScreenCenter;
    if SuperForm.ShowModal = mrOK then
      begin
        Move := SuperForm.MoveDirection;

        mem.SF_Edited := SuperForm.GetFields(mem.SF_Trans_ID,
                         mem.SF_Trans_Code,
                         mem.Quantity,
                         mem.SF_PCFranked,
                         mem.SF_PCUNFranked,
                         Amount);

        if Move in [fnGoForward, fnGoBack] then
        begin
          T := SuperForm.Top;
          L := SuperForm.Left;
        end;
        Result := true;
      end;
  finally
    SuperForm.Release;
  end;
end;



//*****************************************************************************************
//
//   Supervisor
//
//*****************************************************************************************

// Supervisor Transaction
function EditSupervisorFields( pT : pTransaction_Rec; var Move: TFundNavigation; var T, L: Integer) : boolean; overload;
var
  SuperForm : TdlgEditSupervisorFields;
begin
  result := false;
  SuperForm := TdlgEditSupervisorFields.Create( Application.Mainform);
  try

    SuperForm.SetInfo( pT^.txDate_Effective, pT^.txGL_Narration, pT^.txAmount);
    SuperForm.FrankPercentage := False;
    SuperForm.RevenuePercentage := False;

    SuperForm.SetFields( pT^.txSF_Imputed_Credit,
                         pT^.txSF_Tax_Free_Dist,
                         pT^.txSF_Tax_Exempt_Dist,
                         pT^.txSF_Tax_Deferred_Dist,
                         pT^.txSF_TFN_Credits,
                         pT^.txSF_Foreign_Income,
                         pT^.txSF_Foreign_Tax_Credits,
                         pT^.txSF_Capital_Gains_Indexed,
                         pT^.txSF_Capital_Gains_Disc,
                         pT^.txSF_Other_Expenses,
                         pT^.txSF_Capital_Gains_Other,
                         pT^.txSF_Franked, pT^.txSF_Unfranked,
                         pT^.txSF_Interest, pT^.txSF_Capital_Gains_Foreign_Disc, pT^.txSF_Rent,
                         pT^.txSF_Special_Income, pT^.txSF_Other_Tax_Credit, pT^.txSF_Non_Resident_Tax,
                         pT^.txSF_Foreign_Capital_Gains_Credit, pT^.txSF_Member_ID, pT^.txQuantity, pT^.txAccount);

    SuperForm.ReadOnly := ( pT^.txLocked) or ( pT^.txDate_Transferred <> 0);
    SuperForm.MoveDirection := Move;
    if T > -999 then
    begin
      SuperForm.FormTop := T;
      SuperForm.FormLeft := L;
    end
    else
      SuperForm.Position := poScreenCenter;
    if SuperForm.ShowModal = mrOK then begin
        Move := SuperForm.MoveDirection;
        pT^.txSF_Super_Fields_Edited := SuperForm.GetFields( pT^.txSF_Imputed_Credit,
                             pT^.txSF_Tax_Free_Dist,
                             pT^.txSF_Tax_Exempt_Dist,
                             pT^.txSF_Tax_Deferred_Dist,
                             pT^.txSF_TFN_Credits,
                             pT^.txSF_Foreign_Income,
                             pT^.txSF_Foreign_Tax_Credits,
                             pT^.txSF_Capital_Gains_Indexed,
                             pT^.txSF_Capital_Gains_Disc,
                             pT^.txSF_Other_Expenses,
                             pT^.txSF_Capital_Gains_Other,
                             pT^.txSF_Franked, pT^.txSF_Unfranked,
                             pT^.txSF_Interest, pT^.txSF_Capital_Gains_Foreign_Disc,
                             pT^.txSF_Rent, pT^.txSF_Special_Income, pT^.txSF_Other_Tax_Credit,
                             pT^.txSF_Non_Resident_Tax,
                             pT^.txSF_Foreign_Capital_Gains_Credit, pT^.txSF_Member_ID,
                             pT^.txAccount, pT^.txQuantity);
        if pT^.txSF_Super_Fields_Edited then begin
           pT^.txHas_Been_Edited := true;
           pT^.txCoded_By := cbManualSuper;
        end else begin
           ClearSuperFundFields(pt);
           pT^.txCoded_By := cbManual; //Will get cleaned up
        end;

        if Move in [fnGoForward, fnGoBack] then
        begin
          T := SuperForm.Top;
          L := SuperForm.Left;
        end;
        Result := true;
      end;
  finally
    SuperForm.Release;
  end;
end;

// Supervisor Journal
function EditSupervisorFields(  ParentTrans : pTransaction_Rec; pWJ : pWorkJournal_Rec; var Move: TFundNavigation; var T, L: Integer) : boolean; overload;
var
  SuperForm : TdlgEditSupervisorFields;
begin
  result := false;
  SuperForm := TdlgEditSupervisorFields.Create( Application.Mainform);
  try
    SuperForm.SetInfo( ParentTrans.txDate_Effective, pWJ^.dtNarration, pWJ^.dtAmount);
    SuperForm.FrankPercentage := False;
    SuperForm.RevenuePercentage := False;
    SuperForm.SetFields( pWJ^.dtSF_Imputed_Credit,
                         pWJ^.dtSF_Tax_Free_Dist,
                         pWJ^.dtSF_Tax_Exempt_Dist,
                         pWJ^.dtSF_Tax_Deferred_Dist,
                         pWJ^.dtSF_TFN_Credits,
                         pWJ^.dtSF_Foreign_Income,
                         pWJ^.dtSF_Foreign_Tax_Credits,
                         pWJ^.dtSF_Capital_Gains_Indexed,
                         pWJ^.dtSF_Capital_Gains_Disc,
                         pWJ^.dtSF_Other_Expenses,
                         pWJ^.dtSF_Capital_Gains_Other,
                         pWJ^.dtSF_Franked, pWJ^.dtSF_Unfranked,
                         pWJ^.dtSF_Interest, pWJ^.dtSF_Capital_Gains_Foreign_Disc, pWJ^.dtSF_Rent,
                         pWJ^.dtSF_Special_Income, pWJ^.dtSF_Other_Tax_Credit, pWJ^.dtSF_Non_Resident_Tax,
                         pWJ^.dtSF_Foreign_Capital_Gains_Credit, pWJ^.dtSF_Member_ID, pWJ^.dtQuantity, pWJ^.dtAccount);

    SuperForm.ReadOnly := ( ParentTrans.txLocked) or ( ParentTrans.txDate_Transferred <> 0);
    SuperForm.MoveDirection := Move;
    if T > -999 then
    begin
      SuperForm.FormTop := T;
      SuperForm.FormLeft := L;
    end
    else
      SuperForm.Position := poScreenCenter;
    if SuperForm.ShowModal = mrOK then
      begin
        Move := SuperForm.MoveDirection;
        pWJ^.dtSF_Super_Fields_Edited := SuperForm.GetFields( pWJ^.dtSF_Imputed_Credit,
                             pWJ^.dtSF_Tax_Free_Dist,
                             pWJ^.dtSF_Tax_Exempt_Dist,
                             pWJ^.dtSF_Tax_Deferred_Dist,
                             pWJ^.dtSF_TFN_Credits,
                             pWJ^.dtSF_Foreign_Income,
                             pWJ^.dtSF_Foreign_Tax_Credits,
                             pWJ^.dtSF_Capital_Gains_Indexed,
                             pWJ^.dtSF_Capital_Gains_Disc,
                             pWJ^.dtSF_Other_Expenses,
                             pWJ^.dtSF_Capital_Gains_Other,
                             pWJ^.dtSF_Franked, pWJ^.dtSF_Unfranked,
                             pWJ^.dtSF_Interest, pWJ^.dtSF_Capital_Gains_Foreign_Disc,
                             pWJ^.dtSF_Rent, pWJ^.dtSF_Special_Income, pWJ^.dtSF_Other_Tax_Credit,
                             pWJ^.dtSF_Non_Resident_Tax, pWJ^.dtSF_Foreign_Capital_Gains_Credit,
                             pWJ^.dtSF_Member_ID, pWJ^.dtAccount, pWJ^.dtQuantity);
        if Move in [fnGoForward, fnGoBack] then
        begin
          T := SuperForm.Top;
          L := SuperForm.Left;
        end;
        Result := true;
      end;
  finally
    SuperForm.Release;
  end;
end;


// Supervisor Dissection
function EditSupervisorFields( ParentTrans : pTransaction_Rec; pWD : pWorkDissect_Rec; var Move: TFundNavigation; var T, L: Integer) : boolean; overload;
var
  SuperForm : TdlgEditSupervisorFields;
begin
  result := false;
  SuperForm := TdlgEditSupervisorFields.Create( Application.MainForm);
  try
    SuperForm.SetInfo( ParentTrans.txDate_Effective, pWD^.dtNarration, pWD^.dtAmount);
    SuperForm.FrankPercentage := False;
    SuperForm.RevenuePercentage := False;
    SuperForm.SetFields( pWD^.dtSF_Imputed_Credit,
                         pWD^.dtSF_Tax_Free_Dist,
                         pWD^.dtSF_Tax_Exempt_Dist,
                         pWD^.dtSF_Tax_Deferred_Dist,
                         pWD^.dtSF_TFN_Credits,
                         pWD^.dtSF_Foreign_Income,
                         pWD^.dtSF_Foreign_Tax_Credits,
                         pWD^.dtSF_Capital_Gains_Indexed,
                         pWD^.dtSF_Capital_Gains_Disc,
                         pWD^.dtSF_Other_Expenses,
                         pWD^.dtSF_Capital_Gains_Other,
                         pWD^.dtSF_Franked, pWD^.dtSF_Unfranked,
                         pWD^.dtSF_Interest, pWD^.dtSF_Capital_Gains_Foreign_Disc, pWD^.dtSF_Rent,
                         pWD^.dtSF_Special_Income, pWD^.dtSF_Other_Tax_Credit, pWD^.dtSF_Non_Resident_Tax,
                         pWD^.dtSF_Foreign_Capital_Gains_Credit, pWD^.dtSF_Member_ID, pWD^.dtQuantity, pWD^.dtAccount);

    SuperForm.ReadOnly := ( ParentTrans.txLocked) or ( ParentTrans.txDate_Transferred <> 0);
    SuperForm.MoveDirection := Move;
    if T > -999 then
    begin
      SuperForm.FormTop := T;
      SuperForm.FormLeft := L;
    end
    else
      SuperForm.Position := poScreenCenter;
    if SuperForm.ShowModal = mrOK then
      begin
        Move := SuperForm.MoveDirection;
        pWD^.dtSuper_Fields_Edited := SuperForm.GetFields( pWD^.dtSF_Imputed_Credit,
                             pWD^.dtSF_Tax_Free_Dist,
                             pWD^.dtSF_Tax_Exempt_Dist,
                             pWD^.dtSF_Tax_Deferred_Dist,
                             pWD^.dtSF_TFN_Credits,
                             pWD^.dtSF_Foreign_Income,
                             pWD^.dtSF_Foreign_Tax_Credits,
                             pWD^.dtSF_Capital_Gains_Indexed,
                             pWD^.dtSF_Capital_Gains_Disc,
                             pWD^.dtSF_Other_Expenses,
                             pWD^.dtSF_Capital_Gains_Other,
                             pWD^.dtSF_Franked, pWD^.dtSF_Unfranked,
                             pWD^.dtSF_Interest, pWD^.dtSF_Capital_Gains_Foreign_Disc,
                             pWD^.dtSF_Rent, pWD^.dtSF_Special_Income, pWD^.dtSF_Other_Tax_Credit,
                             pWD^.dtSF_Non_Resident_Tax, pWD^.dtSF_Foreign_Capital_Gains_Credit,
                             pWD^.dtSF_Member_ID, pWD^.dtAccount, pWD^.dtQuantity);
        if Move in [fnGoForward, fnGoBack] then
        begin
          T := SuperForm.Top;
          L := SuperForm.Left;
        end;
        Result := true;
      end;
  finally
    SuperForm.Release;
  end;
end;

// Supervisor Memorization
function EditSupervisorFields( ParentTrans : pTransaction_Rec; var Mem : TmemSplitRec; var Move: TFundNavigation; var T, L: Integer) : boolean; overload;
var
  SuperForm: TdlgEditSupervisorFields;
  ForDate: Integer;
  Narration: string;
  Amount: Money;
begin
  Result := false;
  SuperForm := TdlgEditSupervisorFields.Create(Application.MainForm);
  try
    if Assigned(ParentTrans) then begin
       ForDate := ParentTrans.txDate_Effective;
       Narration := ParentTrans.txGL_Narration;


       case Mem.LineType of
          mltPercentage :  begin
             Amount := Double2Money  (Mem.Amount * Money2Double(ParentTrans.txAmount) / 100);
             //SuperForm.RevenuePercentage := True;
          end;
          else begin
             Amount := Double2Money(Mem.Amount);
             //SuperForm.RevenuePercentage := False;
          end;
       end;

    end else begin
       ForDate := 0;
       Narration := '';
       case Mem.LineType of
          mltPercentage :  begin
             Amount := Double2Percent(Mem.Amount);
             //SuperForm.RevenuePercentage := True;
          end
          else begin
             Amount := Double2Money(Mem.Amount);
             //SuperForm.RevenuePercentage := False;
          end;
       end;
    end;
    SuperForm.RevenuePercentage := True;
    SuperForm.MemOnly := True;

    SuperForm.SetInfo(Fordate, Narration, Amount);

    SuperForm.FrankPercentage := True;

    SuperForm.SetFields( Amount,
                         Mem.SF_Tax_Free_Dist,
                         Mem.SF_Tax_Exempt_Dist,
                         Mem.SF_Tax_Deferred_Dist,
                         Mem.SF_TFN_Credits,
                         Mem.SF_Foreign_Income,

                         Mem.SF_Foreign_Tax_Credits,
                         Mem.SF_Capital_Gains_Indexed,
                         Mem.SF_Capital_Gains_Disc,
                         Mem.SF_Other_Expenses,
                         Mem.SF_Capital_Gains_Other,

                         Mem.SF_PCFranked,
                         Mem.SF_PCUnFranked,

                         Mem.SF_Interest,
                         Mem.SF_Capital_Gains_Foreign_Disc,
                         Mem.SF_Rent,
                         Mem.SF_Special_Income,
                         Mem.SF_Other_Tax_Credit,
                         Mem.SF_Non_Resident_Tax,
                         Mem.SF_Foreign_Capital_Gains_Credit,

                         Mem.SF_Member_ID,
                         Mem.Quantity,
                         Mem.AcctCode
                        );

    SuperForm.MoveDirection := Move;
    if T > -999 then begin
       SuperForm.FormTop := T;
       SuperForm.FormLeft := L;
    end else
       SuperForm.Position := poScreenCenter;

    if SuperForm.ShowModal = mrOK then begin
        Move := SuperForm.MoveDirection;
        Mem.SF_Edited := SuperForm.GetFields(Amount,
                         Mem.SF_Tax_Free_Dist,
                         Mem.SF_Tax_Exempt_Dist,
                         Mem.SF_Tax_Deferred_Dist,
                         Mem.SF_TFN_Credits,
                         Mem.SF_Foreign_Income,

                         Mem.SF_Foreign_Tax_Credits,
                         Mem.SF_Capital_Gains_Indexed,
                         Mem.SF_Capital_Gains_Disc,
                         Mem.SF_Other_Expenses,
                         Mem.SF_Capital_Gains_Other,

                         Mem.SF_PCFranked,
                         Mem.SF_PCUnFranked,

                         Mem.SF_Interest,
                         Mem.SF_Capital_Gains_Foreign_Disc,
                         Mem.SF_Rent,
                         Mem.SF_Special_Income,
                         Mem.SF_Other_Tax_Credit,
                         Mem.SF_Non_Resident_Tax,
                         Mem.SF_Foreign_Capital_Gains_Credit,


                         Mem.SF_Member_ID,

                         Mem.AcctCode,
                         Mem.Quantity
                        );

        if Move in [fnGoForward, fnGoBack] then begin
           T := SuperForm.Top;
           L := SuperForm.Left;
        end;
        Result := true;
    end;
  finally
    SuperForm.Release;
  end;
end;

//*****************************************************************************************
//
//     DESKTOP
//
//*****************************************************************************************

//  Desktop Transaction
function EditDesktopFields( pT : pTransaction_Rec; BA: TBank_Account; var Move: TFundNavigation;
  var T, L: Integer; aSuperSystem: byte) : boolean; overload;
var
  SuperForm : TdlgEditDesktopFields;
  LLedger: ShortString;
begin
  case aSuperSystem of
  saDesktopSuper : LLedger := IntToStr(BA.baFields.baDesktop_Super_Ledger_ID);
  saClassSuperIP : LLedger :=  BA.baFields.baSuperFund_Ledger_Code ;
  end;
  result := false;
  SuperForm := TdlgEditDesktopFields.Create( Application.Mainform);
  try
    SuperForm.SetInfo( pT^.txDate_Effective, pT^.txGL_Narration, pT^.txAmount, pT^.txQuantity, LLedger, aSuperSystem, sfTrans);
    SuperForm.FrankPercentage := False;
    SuperForm.RevenuePercentage := False;

    SuperForm.SetFields( pT^.txSF_Special_Income,
                         pT^.txSF_Franked,
                         pT^.txSF_Unfranked,
                         pT^.txSF_Foreign_Income,
                         pT^.txSF_Other_Expenses,
                         pT^.txSF_Capital_Gains_Other,
                         pT^.txSF_Capital_Gains_Disc,
                         pT^.txSF_Capital_Gains_Indexed,
                         pT^.txSF_Tax_Deferred_Dist,
                         pT^.txSF_Tax_Free_Dist,
                         pT^.txSF_Tax_Exempt_Dist,
                         pT^.txSF_Imputed_Credit,
                         pT^.txSF_TFN_Credits,
                         pT^.txSF_Foreign_Capital_Gains_Credit,
                         pT^.txSF_Other_Tax_Credit,
                         pT^.txSF_CGT_Date,
                         pT^.txSF_Member_Account_ID,
                         pT^.txSF_Fund_ID,
                         pT^.txAccount,
                         pT^.txSF_Fund_Code,
                         pt^.txSF_Member_Account_Code,
                         pT^.txQuantity,
                         pT^.txSF_Transaction_ID,
                         pT^.txSF_Capital_Gains_Fraction_Half);

    SuperForm.ReadOnly := ( pT^.txLocked) or ( pT^.txDate_Transferred <> 0);
    SuperForm.MoveDirection := Move;
    if T > -999 then
    begin
      SuperForm.FormTop := T;
      SuperForm.FormLeft := L;
    end
    else
      SuperForm.Position := poScreenCenter;
    if SuperForm.ShowModal = mrOK then
      begin
        Move := SuperForm.MoveDirection;
        pT^.txSF_Super_Fields_Edited := SuperForm.GetFields(pT^.txSF_Special_Income,
                         pT^.txSF_Franked,
                         pT^.txSF_Unfranked,
                         pT^.txSF_Foreign_Income,
                         pT^.txSF_Other_Expenses,
                         pT^.txSF_Capital_Gains_Other,
                         pT^.txSF_Capital_Gains_Disc,
                         pT^.txSF_Capital_Gains_Indexed,
                         pT^.txSF_Tax_Deferred_Dist,
                         pT^.txSF_Tax_Free_Dist,
                         pT^.txSF_Tax_Exempt_Dist,
                         pT^.txSF_Imputed_Credit,
                         pT^.txSF_TFN_Credits,
                         pT^.txSF_Foreign_Capital_Gains_Credit,
                         pT^.txSF_Other_Tax_Credit,
                         pT^.txSF_CGT_Date,
                         pT^.txSF_Member_Account_ID,
                         pT^.txSF_Fund_ID,
                         pT^.txSF_Fund_Code,
                         pT^.txSF_Member_Account_Code,
                         pT^.txAccount,
                         pT^.txQuantity,
                         pT^.txSF_Transaction_ID,
                         pT^.txSF_Transaction_Code,
                         pT^.txSF_Capital_Gains_Fraction_Half);

        if pT^.txSF_Super_Fields_Edited then begin
           pT^.txHas_Been_Edited := true;
           pT^.txCoded_By := cbManualSuper;
        end else begin
           ClearSuperFundFields(pt);
           pT^.txCoded_By := cbManual; //Will get cleaned up
        end;

        if Move in [fnGoForward, fnGoBack] then
        begin
          T := SuperForm.Top;
          L := SuperForm.Left;
        end;
        Result := true;
      end;
  finally
    SuperForm.Release;
  end;
end;


//  Desktop Journal

function EditDesktopFields(  ParentTrans : pTransaction_Rec; pWJ : pWorkJournal_Rec;
  BA: TBank_Account; var Move: TFundNavigation; var T, L: Integer;  aSuperSystem: byte) : boolean; overload;
var
  SuperForm : TdlgEditDesktopFields;
  LLedger: ShortString;
begin
  case aSuperSystem of
  saDesktopSuper : LLedger := IntToStr(BA.baFields.baDesktop_Super_Ledger_ID);
  saClassSuperIP : LLedger :=  BA.baFields.baSuperFund_Ledger_Code ;
  end;
  result := false;
  SuperForm := TdlgEditDesktopFields.Create( Application.Mainform);
  try
    SuperForm.SetInfo( ParentTrans.txDate_Effective, pWJ^.dtNarration, pWJ^.dtAmount, pWJ^.dtQuantity, LLedger, aSuperSystem, sfTrans);
    SuperForm.FrankPercentage := False;
    SuperForm.RevenuePercentage := False;

    SuperForm.SetFields( pWJ^.dtSF_Special_Income,
                         pWJ^.dtSF_Franked,
                         pWJ^.dtSF_Unfranked,
                         pWJ^.dtSF_Foreign_Income,
                         pWJ^.dtSF_Other_Expenses,
                         pWJ^.dtSF_Capital_Gains_Other,
                         pWJ^.dtSF_Capital_Gains_Disc,
                         pWJ^.dtSF_Capital_Gains_Indexed,
                         pWJ^.dtSF_Tax_Deferred_Dist,
                         pWJ^.dtSF_Tax_Free_Dist,
                         pWJ^.dtSF_Tax_Exempt_Dist,
                         pWJ^.dtSF_Imputed_Credit,
                         pWJ^.dtSF_TFN_Credits,
                         pWJ^.dtSF_Foreign_Capital_Gains_Credit,
                         pWJ^.dtSF_Other_Tax_Credit,
                         pWJ^.dtSF_CGT_Date,
                         pWJ^.dtSF_Member_Account_ID,
                         pWJ^.dtSF_Fund_ID,
                         pWJ^.dtAccount,
                         pWJ^.dtSF_Fund_Code,
                         pWJ^.dtSF_Member_Account_Code,
                         pWJ^.dtQuantity,
                         pWJ^.dtSF_Transaction_Type_ID,
                         pWJ^.dtSF_Capital_Gains_Fraction_Half);

    SuperForm.ReadOnly := ( ParentTrans.txLocked) or ( ParentTrans.txDate_Transferred <> 0);
    SuperForm.MoveDirection := Move;
    if T > -999 then
    begin
      SuperForm.FormTop := T;
      SuperForm.FormLeft := L;
    end
    else
      SuperForm.Position := poScreenCenter;
    if SuperForm.ShowModal = mrOK then
      begin
        Move := SuperForm.MoveDirection;
        pWJ^.dtSF_Super_Fields_Edited := SuperForm.GetFields(pWJ^.dtSF_Special_Income,
                         pWJ^.dtSF_Franked,
                         pWJ^.dtSF_Unfranked,
                         pWJ^.dtSF_Foreign_Income,
                         pWJ^.dtSF_Other_Expenses,
                         pWJ^.dtSF_Capital_Gains_Other,
                         pWJ^.dtSF_Capital_Gains_Disc,
                         pWJ^.dtSF_Capital_Gains_Indexed,
                         pWJ^.dtSF_Tax_Deferred_Dist,
                         pWJ^.dtSF_Tax_Free_Dist,
                         pWJ^.dtSF_Tax_Exempt_Dist,
                         pWJ^.dtSF_Imputed_Credit,
                         pWJ^.dtSF_TFN_Credits,
                         pWJ^.dtSF_Foreign_Capital_Gains_Credit,
                         pWJ^.dtSF_Other_Tax_Credit,
                         pWJ^.dtSF_CGT_Date,
                         pWJ^.dtSF_Member_Account_ID,
                         pWJ^.dtSF_Fund_ID,
                         pWJ^.dtSF_Fund_Code,
                         pWJ^.dtSF_Member_Account_Code,
                         pWJ^.dtAccount,
                         pWJ^.dtQuantity,
                         pWJ^.dtSF_Transaction_Type_ID,
                         pWJ^.dtSF_Transaction_Type_Code,
                         pWJ^.dtSF_Capital_Gains_Fraction_Half);
        Result := true;
        if Move in [fnGoForward, fnGoBack] then
        begin
          T := SuperForm.Top;
          L := SuperForm.Left;
        end;
      end;
  finally
    SuperForm.Release;
  end;
end;

//  Desktop Dissection

function EditDesktopFields( ParentTrans : pTransaction_Rec; pWD : pWorkDissect_Rec;
  BA: TBank_Account; var Move: TFundNavigation; var T, L: Integer; aSuperSystem: byte) : boolean; overload;
var
  SuperForm : TdlgEditDesktopFields;
  LLedger: ShortString;
begin
  case aSuperSystem of
  saDesktopSuper : LLedger := IntToStr(BA.baFields.baDesktop_Super_Ledger_ID);
  saClassSuperIP : LLedger :=  BA.baFields.baSuperFund_Ledger_Code ;
  end;

  result := false;
  SuperForm := TdlgEditDesktopFields.Create( Application.Mainform);
  try
    SuperForm.SetInfo(ParentTrans.txDate_Effective, pWD^.dtNarration, pWD^.dtAmount, pWD^.dtQuantity, LLedger, aSuperSystem, sfTrans);
    SuperForm.FrankPercentage := False;
    SuperForm.RevenuePercentage := False;

    SuperForm.SetFields( pWD^.dtSF_Special_Income,
                         pWD^.dtSF_Franked,
                         pWD^.dtSF_Unfranked,
                         pWD^.dtSF_Foreign_Income,
                         pWD^.dtSF_Other_Expenses,
                         pWD^.dtSF_Capital_Gains_Other,
                         pWD^.dtSF_Capital_Gains_Disc,
                         pWD^.dtSF_Capital_Gains_Indexed,
                         pWD^.dtSF_Tax_Deferred_Dist,
                         pWD^.dtSF_Tax_Free_Dist,
                         pWD^.dtSF_Tax_Exempt_Dist,
                         pWD^.dtSF_Imputed_Credit,
                         pWD^.dtSF_TFN_Credits,
                         pWD^.dtSF_Foreign_Capital_Gains_Credit,
                         pWD^.dtSF_Other_Tax_Credit,
                         pWD^.dtSF_CGT_Date,
                         pWD^.dtSF_Member_Account_ID,
                         pWD^.dtSF_Fund_ID,
                         pWD^.dtAccount,
                         pWD^.dtSF_Fund_Code,
                         pWD^.dtSF_Member_Account_Code,
                         pWD^.dtQuantity,
                         pWD^.dtSF_Transaction_Type_ID,
                         pWD^.dtSF_Capital_Gains_Fraction_Half);
    SuperForm.ReadOnly := ( ParentTrans.txLocked) or ( ParentTrans.txDate_Transferred <> 0);
    SuperForm.MoveDirection := Move;
    if T > -999 then
    begin
      SuperForm.FormTop := T;
      SuperForm.FormLeft := L;
    end
    else
      SuperForm.Position := poScreenCenter;
    if SuperForm.ShowModal = mrOK then
      begin
        Move := SuperForm.MoveDirection;
        pWD^.dtSuper_Fields_Edited := SuperForm.GetFields(pWD^.dtSF_Special_Income,
                         pWD^.dtSF_Franked,
                         pWD^.dtSF_Unfranked,
                         pWD^.dtSF_Foreign_Income,
                         pWD^.dtSF_Other_Expenses,
                         pWD^.dtSF_Capital_Gains_Other,
                         pWD^.dtSF_Capital_Gains_Disc,
                         pWD^.dtSF_Capital_Gains_Indexed,
                         pWD^.dtSF_Tax_Deferred_Dist,
                         pWD^.dtSF_Tax_Free_Dist,
                         pWD^.dtSF_Tax_Exempt_Dist,
                         pWD^.dtSF_Imputed_Credit,
                         pWD^.dtSF_TFN_Credits,
                         pWD^.dtSF_Foreign_Capital_Gains_Credit,
                         pWD^.dtSF_Other_Tax_Credit,
                         pWD^.dtSF_CGT_Date,
                         pWD^.dtSF_Member_Account_ID,
                         pWD^.dtSF_Fund_ID,
                         pWD^.dtSF_Fund_Code,
                         pWD^.dtSF_Member_Account_Code,
                         pWD^.dtAccount,
                         pWD^.dtQuantity,
                         pWD^.dtSF_Transaction_Type_ID,
                         pWD^.dtSF_Transaction_Type_Code,
                         pWD^.dtSF_Capital_Gains_Fraction_Half);
        if Move in [fnGoForward, fnGoBack] then
        begin
          T := superForm.Top;
          L := superForm.Left;
        end;
        Result := true;
      end;
  finally
    SuperForm.Release;
  end;
end;

//DeskTop Memorization
function EditDesktopFields(ParentTrans : pTransaction_Rec;
                           var Mem : TmemSplitRec;
                           BA: TBank_Account;
                           var Move: TFundNavigation;
                           var T, L: Integer;
                           aSuperSystem: byte;
                           aSDMode: TSuperDialogMode) : boolean; overload;
var
  i: integer;
  FundID, BAFundID: string;
  SameFund: boolean;
  FundBA: TBank_Account;
  SuperForm: TdlgEditDesktopFields;
  Fordate: Integer;
  Amount: Money;
  Narration: string;
  Qty: Money;
  LLedger: ShortString;
begin

  result := false;
  SuperForm := TdlgEditDesktopFields.Create( Application.Mainform);
  try
    LLedger := '';
    if Assigned(BA) then
        case aSuperSystem of
          saDesktopSuper : LLedger := IntToStr(BA.baFields.baDesktop_Super_Ledger_ID);
          saClassSuperIP : LLedger :=  BA.baFields.baSuperFund_Ledger_Code ;
        end
    //TFS 3557
    else if (aSDMode = sfPayee) and
            (MyClient.clBank_Account_List.ItemCount > 0) then begin
       SameFund := True;
       if (aSuperSystem = saDesktopSuper) and (Mem.SF_Ledger_ID <> -1) then
         LLedger := IntToStr(Mem.SF_Ledger_ID)
       else if (aSuperSystem = saClassSuperIP) and (Mem.SF_Ledger_Name <> '') then
         LLedger := Mem.SF_Ledger_Name
       else begin
         FundBA := MyClient.clBank_Account_List.Bank_Account_At(0);
         case aSuperSystem of
           saDesktopSuper: FundID := IntToStr(FundBA.baFields.baDesktop_Super_Ledger_ID);
           saClassSuperIP: FundID := FundBA.baFields.baSuperFund_Ledger_Code;
         end;
         SuperForm.AddFund(FundID, aSuperSystem);
         if (MyClient.clBank_Account_List.ItemCount > 1) then begin
           for i := 1 to MyClient.clBank_Account_List.ItemCount - 1 do begin
            case aSuperSystem of
              saDesktopSuper: BAFundID := IntToStr(MyClient.clBank_Account_List.Bank_Account_At(i).baFields.baDesktop_Super_Ledger_ID);
              saClassSuperIP: BAFundID := MyClient.clBank_Account_List.Bank_Account_At(i).baFields.baSuperFund_Ledger_Code;
            end;
             if (FundID <> '-1') and (FundID <> '') and
                (BAFundID <> '-1') and (BAFundID <> '') and
                (FundID <> BAFundID) then begin
               SameFund := False;
               SuperForm.AddFund(BAFundID, aSuperSystem);
             end;
             if (FundID = '-1') or (FundID = '') then
               FundID := BAFundID;
           end;
         end;

         if SameFund then
           LLedger := FundID; //must use this one

       end;
    end;

    if Assigned(ParentTrans) then begin
       ForDate := ParentTrans.txDate_Effective;
       Narration := ParentTrans.txGL_Narration;
       Qty := ParentTrans.txQuantity;

       case Mem.LineType of
          mltPercentage :  begin
             Amount := Double2Money  (Mem.Amount * Money2Double(ParentTrans.txAmount) / 100);
             //SuperForm.RevenuePercentage := True;
          end
          else begin
             Amount := Double2Money(Mem.Amount);
             //SuperForm.RevenuePercentage := False;
          end;
       end;

    end else begin
       ForDate := 0;
       Narration := '';
       Qty := Mem.Quantity;
       case Mem.LineType of
          mltPercentage :  begin
             Amount := Double2Percent(Mem.Amount);
             //SuperForm.RevenuePercentage := True;
          end
          else begin
             Amount := Double2Money(Mem.Amount);
             //SuperForm.RevenuePercentage := False;
          end;
       end;
       //TFS 3557
       if (aSuperSystem = saDesktopSuper) and (LLedger = '') and (Mem.SF_Ledger_ID <> -1) then
         LLedger := IntToStr(Mem.SF_Ledger_ID)
       else if (aSuperSystem = saClassSuperIP) and (LLedger = '') and (Mem.SF_Ledger_Name <> '') then
         LLedger := Mem.SF_Ledger_Name;

    end;
    SuperForm.RevenuePercentage := True;
    SuperForm.SetInfo(Fordate, Narration, Amount,Qty, LLedger, aSuperSystem, aSDMode);

    SuperForm.FrankPercentage := True;
    Amount := 0;

    SuperForm.SetFields( Mem.SF_Special_Income,
                         Mem.SF_PCFranked,
                         Mem.SF_PCUnFranked,
                         Mem.SF_foreign_Income,
                         Mem.SF_Other_Expenses,
                         Mem.SF_Capital_Gains_Other,
                         Mem.SF_Capital_Gains_Disc,
                         Mem.SF_Capital_Gains_Indexed,
                         Mem.SF_Tax_Deferred_Dist,
                         Mem.SF_Tax_Free_Dist,
                         Mem.SF_Tax_Exempt_Dist,
                         Amount,
                         Mem.SF_TFN_Credits,
                         Mem.SF_Foreign_Capital_Gains_Credit,
                         Mem.SF_Other_Tax_Credit,

                         Mem.SF_GDT_Date,
                         Mem.SF_Member_Account_ID,
                         Mem.SF_Fund_ID,

                         Mem.AcctCode,
                         Mem.SF_Fund_Code,
                         Mem.SF_Member_Account_Code,

                         Mem.Quantity,
                         Mem.SF_Trans_ID,
                         mem.SF_Capital_Gains_Fraction_Half
                         );



    SuperForm.MoveDirection := Move;
    if T > -999 then begin
       SuperForm.FormTop := T;
       SuperForm.FormLeft := L;
    end else
       SuperForm.Position := poScreenCenter;

    if SuperForm.ShowModal = mrOK then begin
       Move := SuperForm.MoveDirection;
       Mem.SF_Edited := SuperForm.GetFields(
                         Mem.SF_Special_Income,
                         Mem.SF_PCFranked,
                         Mem.SF_PCUnFranked,
                         Mem.SF_foreign_Income,
                         Mem.SF_Other_Expenses,
                         Mem.SF_Capital_Gains_Other,
                         Mem.SF_Capital_Gains_Disc,
                         Mem.SF_Capital_Gains_Indexed,
                         Mem.SF_Tax_Deferred_Dist,
                         Mem.SF_Tax_Free_Dist,
                         Mem.SF_Tax_Exempt_Dist,
                         Amount,
                         Mem.SF_TFN_Credits,
                         Mem.SF_Foreign_Capital_Gains_Credit,
                         Mem.SF_Other_Tax_Credit,

                         Mem.SF_GDT_Date,
                         Mem.SF_Member_Account_ID,
                         Mem.SF_Fund_ID,
                         Mem.SF_Fund_Code,
                         Mem.SF_Member_Account_Code,
                         Mem.AcctCode,
                         Mem.Quantity,
                         Mem.SF_Trans_ID,
                         Mem.SF_Trans_Code,
                         Mem.SF_Capital_Gains_Fraction_Half
                         );

       //TFS 3557
       if (not Assigned(BA)) and (aSuperSystem = saDesktopSuper) and (aSDMode = sfPayee) then
         Mem.SF_Ledger_ID := StrToIntDef(superForm.LedgerCode,-1)
       else if (not Assigned(BA)) and (aSuperSystem = saClassSuperIP) and (aSDMode = sfPayee) then
         Mem.SF_Ledger_Name := superForm.LedgerCode;

       if Move in [fnGoForward, fnGoBack] then begin
           T := superForm.Top;
           L := superForm.Left;
       end;
       Result := true;
    end;
  finally
    SuperForm.Release;
  end;
end;


//*****************************************************************************************
//
//    COMMON Switch
//
//*****************************************************************************************


function EditSuperFields( pT : pTransaction_Rec; var Move: TFundNavigation;
  var T, L: Integer; BA: TBank_Account = nil) : boolean;
begin
  result := false;
   IncUsage('Edit Superfund Transaction');
  case MyClient.clFields.clAccounting_System_Used of
   saBGLSimpleFund, saBGLSimpleLedger, saBGL360: result := EditBGLFields(pT, Move, T, L);
   saSupervisor, saSolution6SuperFund, saSuperMate: result := EditSupervisorFields(pT, Move, T, L);
   saDesktopSuper, saClassSuperIP: result := EditDesktopFields(pT, BA, Move, T, L, MyClient.clFields.clAccounting_System_Used);
   saSageHandisoftSuperfund: Result := EditSageHandisoftFields(pT, Move, T, L);
  end;
end;

function EditSuperFields(  ParentTrans : pTransaction_Rec; pWD : pWorkDissect_Rec;
  var Move: TFundNavigation; var T, L: Integer; BA: TBank_Account = nil) : boolean;
begin
  result := false;
  IncUsage('Edit Superfund Dissection');
  case MyClient.clFields.clAccounting_System_Used of
   saBGLSimpleFund, saBGLSimpleLedger, saBGL360: result := EditBGLFields(ParentTrans, pWD, Move, T, L);
   saSupervisor, saSolution6SuperFund, saSuperMate: result := EditSupervisorFields(ParentTrans, pWD, Move, T, L);
   saDesktopSuper, saClassSuperIP: result := EditDesktopFields(ParentTrans, pWD, BA, Move, T, L, MyClient.clFields.clAccounting_System_Used);
   saSageHandisoftSuperfund: Result := EditSageHandisoftFields(ParentTrans, pWD, Move, T, L);
  end;
end;

function EditSuperFields(  ParentTrans : pTransaction_Rec; pWJ : pWorkJournal_Rec;
  var Move: TFundNavigation; var T, L: Integer; BA: TBank_Account = nil) : boolean;
begin
  result := false;
  IncUsage('Edit Superfund Journal');
  case MyClient.clFields.clAccounting_System_Used of
   saBGLSimpleFund, saBGLSimpleLedger, saBGL360: result := EditBGLFields(ParentTrans, pWJ, Move, T, L);
   saSupervisor, saSolution6SuperFund, saSuperMate: result := EditSupervisorFields(ParentTrans, pWJ, Move, T, L);
   saDesktopSuper, saClassSuperIP: result := EditDesktopFields(ParentTrans, pWJ, BA, Move, T, L, MyClient.clFields.clAccounting_System_Used);
   saSageHandisoftSuperfund: Result := EditSageHandisoftFields(ParentTrans, pWJ, Move, T, L);
  end;
end;

function EditSuperFields(ParentTrans : pTransaction_Rec; var Mem : TmemSplitRec;
                         var Move: TFundNavigation; var T, L: Integer;
                         aSDMode : TSuperDialogMode;
                         BA: TBank_Account = nil
                         ) : boolean;

begin
  Result := false;
  case aSDMode of
     sfMem : IncUsage('Edit Superfund Payee');
     sfPayee : IncUsage('Edit Superfund Memorisation');
  end;
  case MyClient.clFields.clAccounting_System_Used of
     saBGLSimpleFund, saBGLSimpleLedger, saBGL360: result := EditBGLFields(ParentTrans, Mem, Move, T, L);
     saSupervisor, saSolution6SuperFund, saSuperMate: result := EditSupervisorFields(ParentTrans,Mem, Move, T, L);
     saDesktopSuper, saClassSuperIP: result := EditDesktopFields(ParentTrans, Mem, BA, Move, T, L, MyClient.clFields.clAccounting_System_Used, aSDMode);

     saSageHandisoftSuperfund:
       begin
         if (aSDMode <> sfMem) then
           Result := EditSageHandisoftFields(ParentTrans, mem, Move, T, L);
       end;
  end;
end;



end.
