{
  Functions for detecting duplicate mems.

  Moved these from MemoriseDlg into a seperate unit so that they can be
  shared with CombineAccountsDlg.

  Steve Teare 01 Feb 2006
}
unit MemUtils;

//------------------------------------------------------------------------------
interface

uses
  SysUtils,
  bkConst,
  baObj32,
  MemorisationsObj;

type
  TMasterMemInfoRec = record
    AuditID: integer;
    SequenceNumber: integer;
  end;

  function HasDuplicateMem( MemToTest : TMemorisation;
                            FMemorisationsList : TMemorisations_List;
                            EditMem : TMemorisation = nil) : Boolean;

  function HasMatchOnCriteria(const aMemorisation: TMemorisation): boolean;

  procedure CopyMemorisation(const aMemFrom: TMemorisation;
              var aMemTo: TMemorisation);
  function  DeleteMem(MemorisedList : TMemorisations_List; BankAccount : TBank_Account; Mem : TMemorisation; Prefix: string = '') : boolean;

//------------------------------------------------------------------------------
implementation

uses
  BKMLIO,
  ComCtrls,
  SyDefs,
  globals,
  MoneyUtils,
  Admin32,
  ErrorMoreFrm,
  AuditMgr,
  LogUtil,
  bkDefs;

//------------------------------------------------------------------------------
function MemCriteriaMatches( ExistingMemorisation, MemToTest : TMemorisation) : boolean;
  //----------------------------------------------------------------------------
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

    if NoOverlap(ExistingMemorisation.mdFields.mdFrom_Date, ExistingMemorisation.mdFields.mdUntil_Date,
                 MemToTest.mdFields.mdFrom_Date, MemToTest.mdFields.mdUntil_Date) or
    (((ExistingMemorisation.mdFields.mdFrom_Date = 0) and (ExistingMemorisation.mdFields.mdUntil_Date = 0)) xor
    ((MemToTest.mdFields.mdFrom_Date = 0) and (MemToTest.mdFields.mdUntil_Date = 0))) then
      Exit;

    if (MemToTest.mdFields.mdUse_Accounting_System <> ExistingMemorisation.mdFields.mdUse_Accounting_System) then
      exit;
    if ( ExistingMemorisation.mdFields.mdAccounting_System <> MemToTest.mdFields.mdAccounting_System) then
      exit;

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

//------------------------------------------------------------------------------
function HasMatchOnCriteria(const aMemorisation: TMemorisation): boolean;
begin
  with aMemorisation.mdFields^ do
    result :=
      (mdMatch_on_Amount <> mxNo) or
      mdMatch_on_Analysis or
      mdMatch_on_Other_Party or
      mdMatch_on_Notes or
      mdMatch_on_Particulars or
      mdMatch_on_Refce or
      mdMatch_on_Statement_Details;
end;

//------------------------------------------------------------------------------
procedure CopyMemorisation(const aMemFrom: TMemorisation;
  var aMemTo: TMemorisation);
var
  iLine: integer;
  MemLineFrom: pMemorisation_Line_Rec;
  MemLineTo: pMemorisation_Line_Rec;
begin
  { Note: code taken from MainMemFrm.CopyTo.
    Could perhaps go into TMemorisation itself.
  }

  aMemTo.mdFields^ := aMemFrom.mdFields^;

  for iLine := aMemFrom.mdLines.First to aMemFrom.mdLines.Last do
  begin
    MemLineFrom := aMemFrom.mdLines.MemorisationLine_At(iLine);
    MemLineTo := BKMLIO.New_Memorisation_Line_Rec;
    MemLineTo^ := MemLineFrom^;
    aMemTo.mdLines.Insert(MemLineTo);
  end;

  // Note: the Insert will set the sequence number
end;

//------------------------------------------------------------------------------
function DeleteMem(MemorisedList : TMemorisations_List; BankAccount : TBank_Account; Mem: TMemorisation; Prefix: string = ''): boolean;
const
  ThisMethodName = 'DeleteMemorised';
var
  i, j, DeletedSeqNo : integer;
  CodedTo,
  MemDesc   : string;
  CodeType  : string;
  MasterMsg : string;
  MasterMsgSpace : string;
  ExtraMsg  : string;
  Country   : Byte;
  Item: TListItem;
  MemLine : pMemorisation_Line_Rec;
  SystemMemorisation: pSystem_Memorisation_List_Rec;
  SystemMem: TMemorisation;
  MasterMemInfoRec: TMasterMemInfoRec;
begin
  Result := false;
  MasterMsg := '';
  ExtraMsg := '';

  //Single delete
  CodedTo := '';
  for j := Mem.mdLines.First to Mem.mdLines.Last do
  begin
    MemLine := Mem.mdLines.MemorisationLine_At(j);
    if MemLine^.mlAccount <> '' then
      CodedTo := CodedTo + MemLine^.mlaccount+ ' ';
  end;

  if (not mem.mdFields.mdFrom_Master_List) or (not Assigned( AdminSystem)) then
  begin
    CodeType := MyClient.clFields.clShort_Name[mem.mdFields.mdType];
    if (not Assigned( AdminSystem)) and (mem.mdFields.mdFrom_Master_List) then
    begin
      MasterMsg := 'MASTER';
      ExtraMsg := #13+#13+'This will only delete the MASTER memorisation TEMPORARILY.  To delete it permanently it must be deleted at the PRACTICE.';
    end;
  end
  else
  begin
    CodeType := AdminSystem.fdFields.fdShort_Name[mem.mdFields.mdType];
    MasterMsg := 'MASTER';
    ExtraMsg := #13+#13+'NOTE: This will apply to ALL clients in your practice that have accounts with this bank and use MASTER memorisations.';
  end;

  if Assigned( MyClient ) then
    Country := MyClient.clFields.clCountry
  else
    Country := AdminSystem.fdFields.fdCountry;

  MemDesc := #13 +'Coded To '+CodedTo + #13 + 'Entry Type is '+IntToStr(mem.mdFields.mdType) + ':' + CodeType;

  // build list of things that match
  case Country of
    whNewZealand :
    begin
      if mem.mdFields.mdMatch_on_Refce then        MemDesc := MemDesc + #13 + 'Reference is ' + mem.mdFields.mdReference;
      if mem.mdFields.mdMatch_on_Analysis then     MemDesc := MemDesc + #13 + 'Analysis is ' + mem.mdFields.mdAnalysis;
      if mem.mdFields.mdMatch_On_Statement_Details then MemDesc := MemDesc + #13 + 'Stmt Details are ' + mem.mdFields.mdStatement_Details;
      if mem.mdFields.mdMatch_on_Particulars then  MemDesc := MemDesc + #13 + 'Particulars are ' + mem.mdFields.mdParticulars;
      if mem.mdFields.mdMatch_on_Other_Party then  MemDesc := MemDesc + #13 + 'Other Party is ' + mem.mdFields.mdOther_Party;
      if mem.mdFields.mdMatch_on_notes then        MemDesc := MemDesc + #13 + 'Notes is ' + mem.mdFields.mdNotes;
      if Assigned(BankAccount) then
        if (mem.mdFields.mdMatch_on_Amount > 0) then MemDesc := MemDesc + #13 + 'Value is ' + mxNames[mem.mdFields.mdMatch_on_Amount] + ' ' + MoneyStr(mem.mdFields.mdAmount, BankAccount.baFields.baCurrency_Code)
      else
        if (mem.mdFields.mdMatch_on_Amount > 0) then MemDesc := MemDesc + #13 + 'Value is ' + mxNames[mem.mdFields.mdMatch_on_Amount] + ' ' + MoneyStr(mem.mdFields.mdAmount, whCurrencyCodes[Country])
    end;
  whAustralia, whUK :
    begin
      if mem.mdFields.mdMatch_on_Refce then       MemDesc := MemDesc + #13 + 'Reference is ' + mem.mdFields.mdReference;
      if mem.mdFields.mdMatch_on_Particulars then MemDesc := MemDesc + #13 + 'Bank Type is ' + mem.mdFields.mdParticulars;
      if mem.mdFields.mdMatch_On_Statement_Details then MemDesc := MemDesc + #13 + 'Stmt Details are ' + mem.mdFields.mdStatement_Details;
      if mem.mdFields.mdMatch_on_notes then       MemDesc := MemDesc + #13 + 'Notes is ' + mem.mdFields.mdNotes;
      if Assigned(BankAccount) then
        if (mem.mdFields.mdMatch_on_Amount > 0) then MemDesc := MemDesc + #13 + 'Value is ' + mxNames[mem.mdFields.mdMatch_on_Amount] + ' ' + MoneyStr(mem.mdFields.mdAmount, BankAccount.baFields.baCurrency_Code)
      else
        if (mem.mdFields.mdMatch_on_Amount > 0) then MemDesc := MemDesc + #13 + 'Value is ' + mxNames[mem.mdFields.mdMatch_on_Amount] + ' ' + MoneyStr(mem.mdFields.mdAmount, whCurrencyCodes[Country])
    end;
  end; // Case clCountry

  if (MasterMSG = '') then
    MasterMsgSpace := ''
  else
    MasterMsgSpace := ' ';

  if Assigned(AdminSystem) and (Prefix <> '') then
  begin
    //---DELETE MASTER MEM---
    MasterMemInfoRec.AuditID := Mem.mdFields.mdAudit_Record_ID;
    MasterMemInfoRec.SequenceNumber := Mem.mdFields.mdSequence_No;
    if LoadAdminSystem(true, ThisMethodName) then
    begin
      //Get mem list
      SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(Prefix);
      if not Assigned(SystemMemorisation) then
        UnlockAdmin
      else if not Assigned(SystemMemorisation.smMemorisations) then
        UnlockAdmin
      else
      begin
        SystemMem := nil;
        //Delete memorisation
        for i := TMemorisations_List(SystemMemorisation.smMemorisations).First to TMemorisations_List(SystemMemorisation.smMemorisations).Last do
        begin
          SystemMem := TMemorisations_List(SystemMemorisation.smMemorisations).Memorisation_At(i);
          if Assigned(SystemMem) then
          begin
            //Don't care about the sequence for deletes?
            if (SystemMem.mdFields.mdAudit_Record_ID = MasterMemInfoRec.AuditID) then
            begin
              DeletedSeqNo := SystemMem.mdFields.mdSequence_No;
              TMemorisations_List(SystemMemorisation.smMemorisations).DelFreeItem(SystemMem);
              Result := True;

              // Need to subtract one from the sequence number for any memorisations after the deleted one
              for j := TMemorisations_List(SystemMemorisation.smMemorisations).First to
                       TMemorisations_List(SystemMemorisation.smMemorisations).Last do
              begin
                if (TMemorisations_List(SystemMemorisation.smMemorisations).Memorisation_At(j).mdFields.mdSequence_No > DeletedSeqNo) then
                  Dec(TMemorisations_List(SystemMemorisation.smMemorisations).Memorisation_At(j).mdFields.mdSequence_No);
              end;
              Break;
            end;
          end;
        end;
        if Assigned(SystemMem) and (not Result) then
          HelpfulErrorMsg('Could not delete master memorisation because it has been changed by another user.', 0);
        //Delete pSystem_Memorisation_List_Rec if there are no memorisations
        if TMemorisations_List(SystemMemorisation.smMemorisations).ItemCount = 0 then
          AdminSystem.SystemMemorisationList.Delete(SystemMemorisation);
        //*** Flag Audit ***
        SystemAuditMgr.FlagAudit(arMasterMemorisations);
        SaveAdminSystem;
      end;
    end
    else
      HelpfulErrorMsg('Could not delete master memorisation at this time. Admin System unavailable.', 0);
   //---END DELETE MASTER MEM---
  end
  else
    MemorisedList.DelFreeItem(Mem);

  Result := True;

  LogUtil.LogMsg(lmInfo,'MAINTAINMEMFRM','User Deleted '+MasterMSG+' Memorisation '+ MemDesc);
end;


end.
