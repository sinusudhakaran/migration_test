Unit chartutils;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:

   Remarks:

   Revisions:

}
//------------------------------------------------------------------------------

Interface
uses
  chList32, clObj32;

Function LoadChartFrom(ClientCode: string; Var aFileName: string; aInitDir: string;
   aFilter: string; DefExtn: string; HelpCtx: Integer) : boolean;

Function SaveChartTo(ClientCode: string; Var aFileName: string; aInitDir: string;
   aFilter: string; DefExtn: string; HelpCtx: Integer) : boolean;

function MergeCharts(var NewChart : TChart; const aClient : TClientObj;
  const ReplaceChartID: Boolean = False) : boolean;

//------------------------------------------------------------------------------

Function GetChartFileName( ClientCode  : string; 
                           aInitDir    : string;
                           aFilter     : string; 
                           DefExtn     : string;
                           HelpCtx     : Integer ) : String;
   
//------------------------------------------------------------------------------
Implementation
//------------------------------------------------------------------------------

Uses
   SysUtils,
   Dialogs,
   glConst,
   GlobalDirectories,
   gstCalc32,
   bkconst,
   bkDefs,
   classes,
   controls,
   logUtil,
   YesNoWithListDlg, Globals,
   AuditMgr;

const
   UnitName = 'CHARTUTILS';
var
   DebugMe : boolean = false;

//------------------------------------------------------------------------------

Function LoadChartFrom(ClientCode: string; Var aFileName: string; aInitDir: string;
   aFilter: string; DefExtn: string; HelpCtx: Integer) : boolean;
Var
   OpenDlg : TOpenDialog;
Begin
   Result  := false;
   OpenDlg := TOpenDialog.Create(Nil);
   Try
      With OpenDlg Do
      Begin
         DefaultExt   := DefExtn;
         Filename     := aFileName;
         Filter       := aFilter + '|All Files|*.*';
         HelpContext  := HelpCtx;
         Options      := [ ofHideReadOnly, ofFileMustExist, ofEnableSizing, ofNoChangeDir ];
         Title        := 'Load ' + ClientCode + ' Chart From';
         InitialDir   := ExtractFilePath( aInitDir );
      End;

      If OpenDlg.Execute Then
      Begin
         aFileName := OpenDlg.Filename;
         Result := true;
      End;
   Finally
      OpenDlg.Free;
      //make sure all relative paths are relative to data dir after browse
      SysUtils.SetCurrentDir( GlobalDirectories.glDataDir);
   End;
End;
//------------------------------------------------------------------------------

Function SaveChartTo(ClientCode: string; Var aFileName: string; aInitDir: string;
   aFilter: string; DefExtn: string; HelpCtx: Integer) : boolean;
Var
   SaveDlg : TSaveDialog;
Begin
   Result  := false;
   SaveDlg := TSaveDialog.Create(Nil);
   Try
      With SaveDlg Do
      Begin
         DefaultExt   := DefExtn;
         Filename     := aFileName;
         Filter       := aFilter + '|All Files|*.*';
         HelpContext  := HelpCtx;
         Options      := [ ofHideReadOnly, ofFileMustExist, ofEnableSizing, ofNoChangeDir, ofOverwritePrompt ];
         Title        := 'Save ' + ClientCode + ' Chart To';
         InitialDir   := ExtractFilePath( aInitDir );
      End;

      If SaveDlg.Execute Then
      Begin
         aFileName := SaveDlg.Filename;
         Result := true;
      End;
   Finally
      SaveDlg.Free;
      //make sure all relative paths are relative to data dir after browse
      SysUtils.SetCurrentDir( GlobalDirectories.glDataDir);
   End;
End;

//------------------------------------------------------------------------------

Function GetChartFileName( ClientCode  : string;
                           aInitDir    : string;
                           aFilter     : string;
                           DefExtn     : string;
                           HelpCtx     : Integer ) : String;

Var
   OpenDlg : TOpenDialog;
Begin
   Result  := '';
   OpenDlg := TOpenDialog.Create( nil );
   Try
      With OpenDlg Do
      Begin
         DefaultExt    := DefExtn;
         Filename      := '';
         Filter        := aFilter + '|All Files|*.*';
         HelpContext   := HelpCtx;
         Options       := [ ofHideReadOnly,  ofFileMustExist, ofEnableSizing, ofNoChangeDir ];
         Title         := 'Load ' + ClientCode + ' Chart From';
         InitialDir    := ExtractFilePath( aInitDir );
      End;

      If OpenDlg.Execute then Result := OpenDlg.Filename;
   Finally
      OpenDlg.Free;
      //make sure all relative paths are relative to data dir after browse
      SysUtils.SetCurrentDir( GlobalDirectories.glDataDir);
   End;
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MergeCharts(var NewChart : TChart; const aClient : TClientObj;
  const ReplaceChartID: Boolean = False) : boolean;
// Used by each of the import chart routines to merge the new chart list into
// the existing chart list.
const
  ThisMethodName = 'MergeCharts';
var
  ni : integer;
  NewAccount,
  ExistingAccount : pAccount_Rec;
  AllowGSTClassToBeCleared : boolean;
  ChangesList : TStringList;
  ClientChart : TChart;

  DialogResult : integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := false;

   ClientChart := aClient.clChart;

   if not Assigned(NewChart) then begin
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' NewChart not Assigned' );
      Exit;
   end;

   AllowGSTClassToBeCleared := false;

   if Assigned(ClientChart) then
   begin
     ChangesList := TStringList.Create;
     try
       //see if we need to ask the user about clear the gst class during refresh\
       //look for a gst class of "bkFORCE_GST_CLASS_TO_ZERO", if we find one
       //warn the user that the class for the chart code will be changed
       for ni := 0 to NewChart.ItemCount -1 do
       begin
         NewAccount    := Newchart.Account_At(ni);
         ExistingAccount := ClientChart.FindCode(NewAccount.chAccount_Code);

         //copy across stored fields
         if Assigned(ExistingAccount) then
         begin
           //255 is a marker that indicates the gst class should be forced to 0
           if ( NewAccount.chGST_Class = bkFORCE_GST_CLASS_TO_ZERO) and ( ExistingAccount.chGST_Class <> 0) then
           begin
             ChangesList.Add( NewAccount.chAccount_Code + ' ' + NewAccount.chAccount_Description + #9 + '('+GetGSTClassCode( aClient, ExistingAccount.chGST_Class)+')');
           end;
         end;
       end;

       //prompt user if anything will be changed
       if ChangesList.Count > 0 then
       begin
         DialogResult := AskYesNoWithList( 'Clear GST Classes',
                              'The following chart codes no longer have a GST rate associated with them in ' +
                                 aClient.clAccountingSystemName + ', however they currently have a GST class in ' + ShortAppNAme + ':',
                               ChangesList.Text,
                               'Do you want to clear the GST class in ' + ShortAppName +
                                 ' for these chart codes?');

         if DialogResult = mrYes then
           AllowGSTClassToBeCleared := True
         else
         if DialogResult = mrCancel then
           Exit;
       end;
     finally
       ChangesList.Free;
     end;

     //Merge the existing chart into the New Chart
     for ni := 0 to NewChart.ItemCount -1 do
     begin
       NewAccount    := Newchart.Account_At(ni);
       ExistingAccount := ClientChart.FindCode(NewAccount.chAccount_Code);

       //copy across stored fields
       if Assigned(ExistingAccount) then
       begin
          //Keep the same Audit ID
          NewAccount.chAudit_Record_ID := ExistingAccount.chAudit_Record_ID;

          if ( ExistingAccount.chGST_Class > 0) then
          begin
            //account has an existing GST class, use this if we are not setting
            //one
            if NewAccount.chGST_Class = 0 then
              NewAccount.chGST_Class := ExistingAccount.chGST_Class;

            if ( NewAccount.chGST_Class = bkFORCE_GST_CLASS_TO_ZERO) then
            begin
              if ( AllowGSTClassToBeCleared) then
                NewAccount.chGST_Class := 0
              else
                //don't override, just use existing class
                NewAccount.chGST_Class := ExistingAccount.chGST_Class;
            end;
          end;

          //maintain existing account type info unless a report group is defined
          If ( NewAccount.chAccount_Type = atNone ) and ( ExistingAccount.chAccount_Type <> atNone ) then begin
             NewAccount.chAccount_Type := ExistingAccount.chAccount_Type ;
             NewAccount.chSubtype      := ExistingAccount.chSubtype;
          end;
          //sub groups are not included in the chart refresh so just retain existing
          NewAccount.chSubtype                := ExistingAccount.chSubtype;

          //these fields are not filled as part of the refresh chart so retain existing
          if not ReplaceChartID then
            NewAccount.chChart_ID  := ExistingAccount.chChart_ID;
          NewAccount.chEnter_Quantity         := ExistingAccount.chEnter_Quantity;
          NewAccount.chMoney_Variance_Up      := ExistingAccount.chMoney_Variance_Up;
          NewAccount.chMoney_Variance_Down    := ExistingAccount.chMoney_Variance_Down;
          NewAccount.chPercent_Variance_Up    := ExistingAccount.chPercent_Variance_Up;
          NewAccount.chPercent_Variance_Down  := ExistingAccount.chPercent_Variance_Down;
          NewAccount.chPrint_in_Division      := ExistingAccount.chPrint_in_Division;
          NewAccount.chLinked_Account_OS      := ExistingAccount.chLinked_Account_OS;
          NewAccount.chLinked_Account_CS      := ExistingAccount.chLinked_Account_CS;
          NewAccount.chHide_In_Basic_Chart    := ExistingAccount.chHide_In_Basic_Chart;
       end;

       //make sure we don't set it to bkFORCE_GST_CLASS_TO_ZERO
       if ( NewAccount.chGST_Class = bkFORCE_GST_CLASS_TO_ZERO) then
         NewAccount.chGST_Class := 0;
     end;
   end;

   aClient.clChart.Free;  {free old chart - no longer needed}
   aClient.clChart := nil;

   aClient.clChart := NewChart;

   //*** Flag Audit ***
   aClient.ClientAuditMgr.FlagAudit(atChartOfAccounts);

   NewChart := nil;   {only kill the pointer, DON'T kill the data}
   result := true;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
End.
