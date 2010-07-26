{
  Functions for detecting duplicate mems.

  Moved these from MemoriseDlg into a seperate unit so that they can be
  shared with CombineAccountsDlg.

  Steve Teare 01 Feb 2006
}
unit MemUtils;

interface

uses SysUtils, bkConst, MemorisationsObj;

function HasDuplicateMem( MemToTest : TMemorisation;
                          FMemorisationsList : TMemorisations_List;
                          EditMem : TMemorisation = nil) : Boolean;

implementation

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MemCriteriaMatches( ExistingMemorisation, MemToTest : TMemorisation) : boolean;
   function NoOverlap(F1,T1,F2,T2: Integer): Boolean;
   begin
      if T1 = 0 then T1 := MaxInt;
      if T2 = 0 then T2 := MaxInt;
      Result := 
      (
         ((F1 < F2) and (T1 < F2))   // 1 Before 2
         or
         ((F1 > T2) and (T1 > T2))   // 1 After 2
      )
   end;
begin
  result := false;  //assume are different

  //only compare mems of the same type
  if ( ExistingMemorisation.mdFields.mdFrom_Master_List = MemToTest.mdFields.mdFrom_Master_List) then
    begin
      if ( ExistingMemorisation.mdFields.mdType <> MemToTest.mdFields.mdType) then
        exit;

      if ( ExistingMemorisation.mdFields.mdMatch_on_Amount = MemToTest.mdFields.mdMatch_on_Amount) then
        begin
          //if match method is the same, then check the amounts are the same
          if ( ExistingMemorisation.mdFields.mdMatch_on_Amount <> mxNo) then
            if not( ExistingMemorisation.mdFields.mdAmount = MemToTest.mdFields.mdAmount) then
              exit;
        end
      else
        Exit;

      if ( ExistingMemorisation.mdFields.mdMatch_on_Refce = MemToTest.mdFields.mdMatch_on_Refce) then
        begin
          if ExistingMemorisation.mdFields.mdMatch_on_Refce then
            if not( Uppercase(ExistingMemorisation.mdFields.mdReference) = Uppercase(MemToTest.mdFields.mdReference)) then
              exit;
        end
      else
        Exit;

      if ( ExistingMemorisation.mdFields.mdMatch_on_Particulars = MemToTest.mdFields.mdMatch_on_Particulars) then
        begin
          if ( ExistingMemorisation.mdFields.mdMatch_on_Particulars) then
            if not( Uppercase(ExistingMemorisation.mdFields.mdParticulars) = Uppercase(MemToTest.mdFields.mdParticulars)) then
              exit;
        end
      else
        Exit;

      if ( ExistingMemorisation.mdFields.mdMatch_on_Analysis = MemToTest.mdFields.mdMatch_on_Analysis) then
        begin
          if ( ExistingMemorisation.mdFields.mdMatch_on_Analysis) then
            if not ( Uppercase(ExistingMemorisation.mdFields.mdAnalysis) = Uppercase(MemToTest.mdFields.mdAnalysis)) then
              exit;
        end
      else
        Exit;

      if ( ExistingMemorisation.mdFields.mdMatch_on_Other_Party = MemToTest.mdFields.mdMatch_on_Other_Party) then
        begin
          if ( ExistingMemorisation.mdFields.mdMatch_on_Other_Party) then
            if not( Uppercase(ExistingMemorisation.mdFields.mdOther_Party) = Uppercase(MemToTest.mdFields.mdOther_Party)) then
              exit;
        end
      else
        Exit;

      if ( ExistingMemorisation.mdFields.mdMatch_On_Statement_Details = MemToTest.mdFields.mdMatch_On_Statement_Details) then
        begin
          if ( ExistingMemorisation.mdFields.mdMatch_On_Statement_Details) then
            if not( Uppercase(ExistingMemorisation.mdFields.mdStatement_Details) = Uppercase(MemToTest.mdFields.mdStatement_Details)) then
              exit;
        end
      else
        Exit;

      if ( ExistingMemorisation.mdFields.mdMatch_on_Notes = MemToTest.mdFields.mdMatch_on_Notes) then
        begin
          if ( ExistingMemorisation.mdFields.mdMatch_on_Notes) then
            if not( Uppercase(ExistingMemorisation.mdFields.mdNotes) = Uppercase(MemToTest.mdFields.mdNotes)) then
              exit;
        end
      else
        Exit;

      if NoOverlap (ExistingMemorisation.mdFields.mdFrom_Date, ExistingMemorisation.mdFields.mdUntil_Date,
                      MemToTest.mdFields.mdFrom_Date, MemToTest.mdFields.mdUntil_Date) then
         Exit;




      //no criteria are different
      Result := true;
    end;
end;

//------------------------------------------------------------------------------
//
// HasDuplicateMem
//
// Checks to see if the current memorisation already exists.
//
function HasDuplicateMem( MemToTest : TMemorisation;
                          FMemorisationsList : TMemorisations_List;
                          EditMem : TMemorisation = nil) : Boolean;
// a duplicate mem is defined as one that has exactly the same matching criteria
var
  i : integer;
begin
  result := false;

  //cycle thru existing memorisation in the list provided
  for i := FMemorisationsList.First to FMemorisationsList.Last do
    begin
      if (FMemorisationsList.Memorisation_At(i) <> EditMem)
      and MemCriteriaMatches( FMemorisationsList.Memorisation_At(i), MemToTest) then begin
         Result := true;
         Exit;
      end;
    end;
end;

end.
