unit bugfixes;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title: Bug Fixes

  Written:
  Authors:

  Purpose: Holds all patch code to repair any damaged data due to bugs.
     Can be called from a standalone program or from within BankLink
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface
   procedure FixClientInvalidGSTRateAppliesDates;
   procedure FixAdminInvalidGSTRateAppliesDates;

   procedure FixStaffMemberResponsible;
   procedure FixReportStartDate;

//******************************************************************************
implementation
uses
   clObj32,
   globals,
   bkdefs,
   sydefs,
   WarningMoreFrm,
   LogUtil,
   GlConst,
   sysUtils;

const
   DATE1900 = 109573;
const
   UnitName = 'BUGFIXES';
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure FixClientInvalidGSTRateAppliesDates;
//introduced in version 0.3.1.78
const
   ThisMethodName = 'FixClientInvalidGSTRateAppliesDates';
var
   i : integer;
   FixApplied : boolean;
   s            : string;
begin
   FixApplied   := false;

   for i := 1 to MAX_GST_CLASS_RATES do
      with MyClient.clFields do
         if clGST_Applies_From[i] = DATE1900 then
         begin
            clGST_Applies_From[i] := -1;
            FixApplied := true;
         end;

   if FixApplied then begin
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Applied');
      s := 'This Client File contained invalid "Effective Dates" for your GST Rates. '+ SHORTAPPNAME+
           ' has applied a fix to this problem.'+#13+#13+

           'To confirm that all GST Rates and Amounts are correct for this Client File you should '+
           'Recalculate GST for all transactions prior to generating Reports, '+
           'or transferring transactions to your Main Accounting System.'+#13+#13+

           'Contact '+SHORTAPPNAME+' Support if you require any further assistance.';
      HelpfulWarningMsg(s,0);

   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure FixAdminInvalidGSTRateAppliesDates;
//introduced in version 0.3.1.78
const
   ThisMethodName = 'FixAdminInvalidGSTRateAppliesDates';
var
   i : integer;
   FixApplied : boolean;
begin
   FixApplied := false;

   for i := 1 to MAX_GST_CLASS_RATES do
      with AdminSystem.fdFields do
         if fdGST_Applies_From[i] = DATE1900 then
         begin
            fdGST_Applies_From[i] := -1;
            FixApplied := true;
         end;

   if FixApplied then
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Applied');
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure FixStaffMemberResponsible;
//introduced in version 5.0.0.21
{
  special fix required for a bug in earlier versions of the update program
  The staff member responsible LRN was not set in any of the client file,  however
  it was correctly updated in the admin system.

  As each client file is opened the person responsible is cleared in the admin system
  because of SyncAdminToClient which is called on a client save.

  This causes the schedule reports and the what due report to show that client are not
  attached to a staff member.  Each time a client is opened it becomes detatched from
  a staff member.

  This fix reads the staff member no in the admin system and put it back into the client
  file if the client file staff member lrn is 0.  This requires every client file to be opened
  which has a staff member responsible assigned in the admin system

}
const
   ThisMethodName = 'FixStaffMemberResp';
var
   i : integer;
   cfRec : pClient_File_Rec;
   aClient : TClientObj;
   ClientCode : string;
begin
   with AdminSystem.fdSystem_Client_File_List do begin
      for i := 0 to Pred(itemCount) do begin
          cfRec := Client_File_At(i);
          if cfRec^.cfUser_Responsible <> 0 then begin
             //load the client file and update the staff_member_lrn
             ClientCode := cfRec^.cfFile_Code;
             aClient := TClientObj.Create;
             Try
                aClient.Open( ClientCode, FILEEXTN);
                if aClient.clFields.clStaff_Member_LRN = 0 then begin
                   aClient.clFields.clStaff_Member_LRN := cfRec^.cfUser_Responsible;
                   aClient.Save;
                   LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Applied to '+aClient.clFields.clCode);
                end;
             finally
                aclient.Free;
             end;
          end;
      end;
   end; //with
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure FixReportStartDate;
//introduced in version 5.0.0.21
{
  The clReportStartDate field in the client record may contain 0 after the
  upgrade from bk4.  The means that the client will be skipped when the
  What Due report, or scheduled reporting is run.

  The problem is fixed automatically when a client file is opened.  This is
  because the reportStartDate is set to FinancialYearStartDate if it was zero.
  The admin system is also updated.  However this requires the practice to
  open and close ALL client files to fix the problem.

  This fix automatically opens all client files and fixes their ReportStartDate.
  The report start date in the admin system is also updated.
}
const
   ThisMethodName = 'FixReportStartDate';
var
   i : integer;
   cfRec : pClient_File_Rec;
   aClient : TClientObj;
   ClientCode : string;
begin
   with AdminSystem.fdSystem_Client_File_List do begin
      for i := 0 to Pred(itemCount) do begin
          cfRec := Client_File_At(i);
          ClientCode := cfRec^.cfFile_Code;
          //open the client file
          aClient := TClientObj.Create;
          Try
             //open client file
             try
                aClient.Open( ClientCode, FILEEXTN);
             except
                on e : Exception do begin
                   Logutil.LogMsg(lmError, UnitName, ThisMethodName+' Cannot open '+ ClientCode);
                   aClient.Free;
                   aClient := nil;
                end;
             end;
             //update client. no point testing if is zero because TClient.Open will
             //set clReport_Start_Date if it was zero.
             if Assigned(aClient) then with aClient do begin
                //check if aclient has changed as a result of open
                TestForChange;
                //save if needed
                if clFields.clFile_Save_Required then begin
                   aClient.Save;
                   LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Applied to '+aClient.clFields.clCode);
                end;
                //update the admin system
                cfRec^.cfReport_Start_Date := aClient.clFields.clReport_Start_Date;
             end;
          finally
             aClient.Free;
          end;
      end;
   end; //with
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
