unit ecReports;
//------------------------------------------------------------------------------
{
   Title:       Reports

   Description: Reports unit, produces the three standard reports

   Remarks:     Reports default to preview

   Author:      Matthew Hopkins Aug 2001

}
//------------------------------------------------------------------------------
interface
uses
   ecObj;

procedure DoChartReport( aClient : TECClient);
procedure DoTransactionsReport( aClient : TECClient; SortOrder : Integer; WithNotes : boolean; HasPayee: Boolean; HasQuantity: Boolean);
procedure DoPayeesReport( aClient : TECClient);
procedure DoJobsReport( aClient: TEcClient);

//******************************************************************************
implementation
uses
   ecReportObj,
   NewReportUtils,
   RepCols,
   ecReportDefs,
   bkconst,
   ECPayeeObj,
   ECJobObj,
   ECSortedTransListObj,
   ecBankAccountObj,
   ecDefs,
   ReportOptionsFrm,
   GenUtils,
   Sysutils,
   classes, ECollect, Controls;


type
   TECReport = class( TBKReport)
      ForClient : TECClient;
   end;

   TECTransactionReport = class( TECReport)
      WorkTranList  : tSorted_Transaction_List;
      TranSortOrder : integer;
      ShowNotes     : boolean;
      ShowPayee     : boolean;
      ShowQuantity  : boolean;
      ShowLine      : boolean;
   end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ListChartDetail(Sender : TObject);
var
   i     : integer;
begin
   with TECReport(Sender) do begin
      with ForClient.ecChart do
         for I := 0 to Pred( ItemCount ) do with Account_At( I )^ do Begin
            if not Account_At( I )^.chHide_In_Basic_Chart then
            begin
              PutString( chAccount_Code );
              PutString( chAccount_Description );
              RenderDetailLine;
            end;
         end;
     end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoChartReport( aClient : TECClient);
var
   Job          : TECReport;
   cLeft        : Double;
begin
   Job := TECReport.Create;
   try
      Job.ForClient := aClient;
      {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
      AddCommonHeader(Job);
      AddJobHeader( Job, jtCenter, 1.6, 'CHART OF ACCOUNTS', true);
      AddJobHeader( Job, jtCenter, 1.2, aClient.ecFields.ecName, true);

      {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
      AddJobColumn(Job,3.0,10.0,'Account Code', jtLeft);
      cLeft := 14;
      AddColAuto(Job, cLeft, 25.0, 1.0, 'Account Description',jtLeft);
      Job.OnECPrint := ListChartDetail;
      Job.Generate( rdScreen);
   finally
      Job.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TransactionsDetail(Sender : TObject);
const
   MaxNotesLines = 3;
var
   ba : TECBank_Account;
   i  : integer;
   pT : pTransaction_Rec;
   pD : pDissection_Rec;
   t  : integer;
   ThisReport : TECTransactionReport;
   pPY : TECPayee;

   procedure PutNotes( Notes : string);
   var
      j,k        : integer;
      ColsToSkip : integer;
      NotesList  : TStringList;
   begin
      ColsToSkip := ThisReport.CurrDetail.Count;
      with ThisReport do begin
         NotesList := TStringList.Create;
         try
            NotesList.Text := Notes;
            if NotesList.Count = 0 then begin
               SkipColumn;
            end;
            if NotesList.Count = 1 then begin
               PutString( NotesList[ 0]);
            end;
            if NotesList.Count > 1 then begin
               PutString( NotesList[ 0]);
               RenderDetailLine;
               j := 1;
               while ( j < NotesList.Count) and ( j < MaxNotesLines) do begin
                  //skip all other fields
                  for k := 1 to ColsToSkip do SkipColumn;
                  PutString( NotesList[ j]);
                  //decide if need to call renderDetailLine
                  Inc( j);
                  if ( j < notesList.Count) and ( j < MaxNotesLines) then
                     RenderDetailLine;
               end;
            end;
         finally
            NotesList.Free;
         end;
      end; //with
   end;

begin
   ThisReport := TECTransactionReport( Sender);
   with ThisReport do begin
      //report for each bank account, start new bank account on new page
      for i := 0 to Pred( ForClient.ecBankAccounts.ItemCount) do begin
         ba := ForClient.ecBankAccounts.Bank_Account_At(i);

         RenderTitleLine( ForClient.GetAccountDetails(ba, ForClient.ecFields.ecCountry));

         WorkTranList := tSorted_Transaction_List.Create( ForClient.ecFields.ecCountry,
                                                          TranSortOrder);
         try
            //load transactions
            with ba.baTransaction_List do begin
               for t := 0 to Pred( ItemCount) do begin
                  pT := Transaction_At( t);
                  WorkTranList.Insert( pT);
               end;
            end;
            //print
            for t := 0 to Pred( WorkTranList.ItemCount) do begin
               pT := WorkTranList.Transaction_At( t);
               if ShowLine then               
                 ThisReport.RenderRuledLine;
               with pT^ do begin
                  //show details for this transaction
                  Case ForClient.ecFields.ecCountry of
                     whNewZealand :
                        Begin
                           PutString( bkDate2Str(txDate_Effective));
                           PutString( GetFormattedReference( pT));
                           PutString( txAccount );
                           PutMoney(  txAmount );
                           PutMoney(  txGST_Amount);
                           if ShowQuantity then                           
                             PutQuantity( txQuantity);
                           if ShowPayee then
                           begin
                             pPY := ForClient.ecPayees.Find_Payee_Number( txPayee_Number);
                             if Assigned( pPY) then
                              PutString(pPY.pdFields.pdName)
                             else
                              skipColumn;
                           end;
                           PutString( txNarration);
                           //PutString( txParticulars);
                           if ShowNotes then begin
                              PutNotes( txNotes);
                           end;
                        end;
                     whAustralia :
                        Begin
                           PutString(bkDate2Str(txDate_Effective));
                           PutString( GetFormattedReference( pT));
                           PutString( txAccount );
                           PutMoney( txAmount );
                           if txTax_Invoice_Available then
                                 PutString( 'Yes' )
                              else
                                 SkipColumn;
                           if txGST_Amount <> 0 then
                              PutMoney( txGST_Amount)
                           else
                              SkipColumn;
                           if ShowQuantity then
                           begin
                             if txQuantity <> 0 then
                               PutQuantity( txQuantity)
                             else
                               SkipColumn;
                           end;
                           if ShowPayee then
                           begin
                             pPY := ForClient.ecPayees.Find_Payee_Number( txPayee_Number);
                             if Assigned( pPY) then
                              PutString(pPY.pdFields.pdName)
                             else
                              SkipColumn;
                           end;
                           PutString(txNarration);
                           if ShowNotes then begin
                              PutNotes( txNotes);
                           end;
                        end;
                  end; { of Case fdCountry }
                  RenderDetailLine;

                  //see if transaction is dissected
                  pD := pT^.txFirst_Dissection;
                  while ( pD <> nil) do with pD^ do begin
                     //show dissection lines
                     Case ForClient.ecFields.ecCountry of
                        whNewZealand :
                           Begin
                              SkipColumn; //date
                              PutString(' /'+inttostr(dsAuto_Sequence_No));
                              PutString( dsAccount );
                              PutMoneyDontAdd( dsAmount );
                              PutMoney( dsGST_Amount);
                              if ShowQuantity then
                                PutQuantity(dsQuantity);
                              // SkipColumn; // Particulars
                              if ShowPayee then
                              begin
                                pPY := ForClient.ecPayees.Find_Payee_Number( dsPayee_Number);
                                if Assigned( pPY) then
                                 PutString(pPY.pdFields.pdName)
                                else
                                 SkipColumn;
                              end;
                              PutString(dsNarration);
                              if ShowNotes then begin
                                 PutNotes( dsNotes);
                              end;
                           end;
                        whAustralia :
                           Begin
                              SkipColumn; //date
                              PutString(' /'+inttostr(dsAuto_Sequence_No));
                              PutString( dsAccount );
                              PutMoney( dsAmount );
                              SkipColumn;
                              if dsGST_Amount <> 0 then
                                 PutMoney( dsGST_Amount)
                              else
                                 SkipColumn;
                              if ShowQuantity then
                              begin
                                if dsQuantity <> 0 then
                                  PutQuantity( dsQuantity)
                                else
                                  SkipColumn;
                              end;
                              if ShowPayee then
                              begin
                                pPY := ForClient.ecPayees.Find_Payee_Number( dsPayee_Number);
                                if Assigned( pPY) then
                                 PutString(pPY.pdFields.pdName)
                                else
                                 SkipColumn;
                              end;
                              PutString(dsNarration);
                              if ShowNotes then begin
                                 PutNotes( dsNotes);
                              end;
                           end;
                     end; { of Case clCountry }
                     RenderDetailLine;
                     pD := pD.dsNext;
                  end; //while
               end;
            end;
         finally
            WorkTranList.Free;
         end;
         RenderDetailSubTotal;
      end;  //for i:=
      RenderDetailGrandTotal;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoTransactionsReport( aClient : TECClient; SortOrder : Integer; WithNotes : boolean; HasPayee: Boolean; HasQuantity: Boolean);
var
   Job            : TECTransactionReport;
   CLeft          : double;
   CGap           : double;
   S              : string;
   Line           : Boolean;

begin
   if GetReportOptions(Line) = mrCancel then
     exit; // Cancel
   Job := TECTransactionReport.Create;
   try
      AddCommonHeader(Job);
      AddJobHeader(Job,jtCenter,1.6,'TRANSACTION LIST ', true);
      S := 'BY '+UpperCase(csNames[SortOrder]);
      if withNotes then
        S := S + ', WITH NOTES';
      AddJobHeader( Job, jtCenter, 0.8, S, true);
      AddJobHeader( Job, jtCenter, 1.2, aClient.ecFields.ecName, true);
      {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
      CLeft    := 0.01;
      CGap     := 1.5;

      if not withNotes then begin
         Case aClient.ecFields.ecCountry of
            whNewZealand :
               Begin
                  AddColAuto(Job,cleft,6.0  ,cGap,'Date', jtLeft);
                  AddColAuto(Job,cleft,13.0 ,cGap,'Reference',jtLeft);
                  AddColAuto(Job,cleft,7.0  ,cGap,'Code To',jtLeft);
                  AddFormatColAuto(Job,cleft,12,cGap,'Amount',jtRight,'#,##0.00','$#,##0.00',true);
                  AddFormatColAuto( Job, cLeft, 9, cGap, 'GST Amt', jtRight, '#,##0.00','$#,##0.00', true);
                  if HasQuantity then
                    AddColAuto(Job,cleft,5.5,cGap,'Quantity', jtLeft);
                  if HasPayee then
                  begin
                    AddColAuto(Job,cleft,16.0 ,cGap,'Payee',jtLeft);
                    AddColAuto(Job,cleft,18.0 ,cGap,'Narration',jtLeft);
                  end
                  else
                    AddColAuto(Job,cleft,50.0 ,cGap,'Narration',jtLeft);
               end;
            whAustralia :
               Begin
                  AddColAuto(Job,cleft,6.0 ,cGap,'Date', jtLeft);
                  AddColAuto(Job,cleft,13.0 ,cGap,'Reference',jtLeft);
                  AddColAuto(Job,cleft,7.0,cGap,'Code To',jtLeft);
                  AddFormatColAuto(Job,cleft,12,cGap,'Amount',jtRight,'#,##0.00','$#,##0.00',true);
                  AddColAuto(Job, cLeft, 4.5, cGap, 'Tax Inv', jtCenter);
                  AddFormatColAuto( Job, cLeft, 9, cGap, 'GST Amt', jtRight, '#,##0.00','$#,##0.00', true);
                  if HasQuantity then
                    AddColAuto(Job,cleft,5.5,cGap,'Quantity', jtLeft);
                  if HasPayee then
                  begin
                    AddColAuto(Job,cleft,15.0 ,cGap,'Payee',jtLeft);
                    AddColAuto(Job,cLeft,25,cGap, 'Narration',jtLeft);
                  end
                  else
                    AddColAuto(Job,cLeft,50,cGap, 'Narration',jtLeft);
               end;
            whUK :
               Begin
                  AddColAuto(Job,cleft,6.0 ,cGap,'Date', jtLeft);
                  AddColAuto(Job,cleft,13.0 ,cGap,'Reference',jtLeft);
                  AddColAuto(Job,cleft,7.0,cGap,'Code To',jtLeft);
                  AddFormatColAuto(Job,cleft,12,cGap,'Amount',jtRight,'#,##0.00','£#,##0.00',true);
                  AddColAuto(Job, cLeft, 4.5, cGap, 'Tax Inv', jtCenter);
                  AddFormatColAuto( Job, cLeft, 9, cGap, 'VAT Amt', jtRight, '#,##0.00','£#,##0.00', true);
                  if HasQuantity then
                    AddColAuto(Job,cleft,5.5,cGap,'Quantity', jtLeft);
                  if HasPayee then
                  begin
                    AddColAuto(Job,cleft,15.0 ,cGap,'Payee',jtLeft);
                    AddColAuto(Job,cLeft,25,cGap, 'Narration',jtLeft);
                  end
                  else
                    AddColAuto(Job,cLeft,50,cGap, 'Narration',jtLeft);
               end;
         end; { of Case clCountry }
      end
      else begin
         Job.ReportSettings.s7Orientation := BK_LANDSCAPE;
         CGap     := 0.8;
         Case aClient.ecFields.ecCountry of
            whNewZealand :
               Begin
                  AddColAuto(Job,cleft,6.0  ,cGap,'Date', jtLeft);
                  AddColAuto(Job,cleft,9.75 ,cGap,'Reference',jtLeft);
                  AddColAuto(Job,cleft,6.0  ,cGap,'Code To',jtLeft);
                  AddFormatColAuto(Job,cleft,8,cGap,'Amount',jtRight,'#,##0.00','$#,##0.00',true);
                  AddFormatColAuto( Job, cLeft, 6.75, cGap, 'GST Amt', jtRight, '#,##0.00','$#,##0.00', true);
                  if HasQuantity then
                    AddColAuto(Job,cleft,5.5,cGap,'Quantity', jtLeft);
                  if HasPayee then
                  begin
                    AddColAuto(Job,cleft,10.0 ,cGap,'Payee',jtLeft);
                    AddColAuto(Job,cleft,23 ,cGap,'Narration',jtLeft);
                    AddColAuto(Job,cLeft, 24,  cGap,'Notes', jtLeft);
                  end
                  else
                  begin
                    AddColAuto(Job,cleft,27 ,cGap,'Narration',jtLeft);
                    AddColAuto(Job,cLeft, 40,  cGap,'Notes', jtLeft);
                  end;
               end;
            whAustralia :
               Begin
                  AddColAuto(Job,cleft,6.0 ,cGap,'Date', jtLeft);
                  AddColAuto(Job,cleft,9.76 ,cGap,'Reference',jtLeft);
                  AddColAuto(Job,cleft,6.0,cGap,'Code To',jtLeft);
                  AddFormatColAuto(Job,cleft,8,cGap,'Amount',jtRight,'#,##0.00','$#,##0.00',true);
                  AddColAuto(Job, cLeft, 4.5, cGap, 'Tax Inv', jtCenter);
                  AddFormatColAuto( Job, cLeft, 6.75, cGap, 'GST Amt', jtRight, '#,##0.00','$#,##0.00', true);
                  if HasQuantity then
                    AddColAuto(Job,cleft,5.5,cGap,'Quantity', jtLeft);                  
                  if HasPayee then
                  begin
                    AddColAuto(Job,cleft,10.0 ,cGap,'Payee',jtLeft);
                    AddColAuto(Job,cLeft,20,cGap, 'Narration',jtLeft);
                    AddColAuto(Job,cLeft, 23,  cGap,'Notes', jtLeft);
                  end
                  else
                  begin
                    AddColAuto(Job,cLeft,23,cGap, 'Narration',jtLeft);
                    AddColAuto(Job,cLeft, 40,  cGap,'Notes', jtLeft);
                  end;
               end;
            whUK :
               Begin
                  AddColAuto(Job,cleft,6.0 ,cGap,'Date', jtLeft);
                  AddColAuto(Job,cleft,9.76 ,cGap,'Reference',jtLeft);
                  AddColAuto(Job,cleft,6.0,cGap,'Code To',jtLeft);
                  AddFormatColAuto(Job,cleft,8,cGap,'Amount',jtRight,'#,##0.00','£#,##0.00',true);
                  AddColAuto(Job, cLeft, 4.5, cGap, 'Tax Inv', jtCenter);
                  AddFormatColAuto( Job, cLeft, 6.75, cGap, 'VAT Amt', jtRight, '#,##0.00','£#,##0.00', true);
                  if HasQuantity then
                    AddColAuto(Job,cleft,5.5,cGap,'Quantity', jtLeft);                  
                  if HasPayee then
                  begin
                    AddColAuto(Job,cleft,10.0 ,cGap,'Payee',jtLeft);
                    AddColAuto(Job,cLeft,20,cGap, 'Narration',jtLeft);
                    AddColAuto(Job,cLeft, 23,  cGap,'Notes', jtLeft);
                  end
                  else
                  begin
                    AddColAuto(Job,cLeft,23,cGap, 'Narration',jtLeft);
                    AddColAuto(Job,cLeft, 40,  cGap,'Notes', jtLeft);
                  end;
               end;
         end; { of Case clCountry }
      end;

      Job.ForClient     := aClient;
      Job.TranSortOrder := SortOrder;
      Job.ShowNotes     := WithNotes;
      Job.ShowPayee     := HasPayee;
      Job.ShowQuantity  := HasQuantity;
      Job.ShowLine      := Line;
      Job.OnECPrint     := TransactionsDetail;
      Job.Generate( rdScreen);
   finally
    Job.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ListPayeeDetail(Sender : TObject);
var
   i       : integer;
begin
   with TECReport(Sender) do
    {render detail}
    for i := ForClient.ecPayees.First to ForClient.ecPayees.Last do
       with ForClient.ecPayees.Payee_At(i) do begin
          PutString(pdName);
          PutInteger(pdNumber);
          RenderDetailLine;
       end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoPayeesReport( aClient : TECClient);
var
   Job : TECReport;
begin
   Job := TECReport.Create;
   try
     Job.ForClient := aClient;
     {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
     AddCommonHeader(Job);
     AddJobHeader(Job,jtCenter,1.6,'PAYEE LIST',true);
     AddJobHeader( Job, jtCenter, 1.2, aClient.ecFields.ecName, true);

     {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
     AddJobColumn(Job,5,30 ,'Payee Name', jtLeft);
     AddJobColumn(Job,36,10,'Payee Number',jtLeft);

     Job.OnECPrint := ListPayeeDetail;
     Job.Generate( rdScreen);
   finally
    Job.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ListJobDetail(Sender: TObject);
var
  Report: TECReport;
  i       : integer;
  Job: TECJob;
begin
  Report := TECReport(Sender);
  for i := Report.ForClient.ecJobs.First to Report.ForClient.ecJobs.Last do
  begin
    Job := Report.ForClient.ecJobs.Job_At(i);
    if Job.jhFields.jhIsCompleted then
      Continue; //only show completed jobs
      
    Report.PutString(Job.jhFields.jhCode);
    Report.PutString(Job.jhFields.jhHeading);
    Report.RenderDetailLine;
  end;
end;

procedure DoJobsReport( aClient: TEcClient);
var
  Job: TECReport;
begin
  Job := TECReport.Create;
  try
    Job.ForClient := aClient;
    AddCommonHeader(Job);
    AddJobHeader(Job, jtCenter, 1.6, 'JOB LIST', true);
    AddJobHeader(Job, jtCenter, 1.2, aClient.ecFields.ecName, true);

    AddJobColumn(Job, 5, 30, 'JOB CODE', jtLeft);
    AddJobColumn(Job, 36, 60, 'JOB NAME', jtLeft);

    Job.OnECPrint := ListJobDetail;
    Job.Generate(rdScreen);
  finally
    Job.Free;
  end;

end;

end.
