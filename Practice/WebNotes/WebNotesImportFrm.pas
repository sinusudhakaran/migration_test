unit WebNotesImportFrm;

interface

uses
  PayeeObj,
  XMLDoc,
  bkDefs,
  stDate,
  baObj32,
  XMLIntf,
  imagesfrm,
  xmldom,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls,
  clObj32, DateSelectorFme,
  OSFont;

type
  TWebNotesImportForm = class(TForm)
    pBtn: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    pList: TPanel;
    DateSelector: TfmeDateSelector;
    lAvailable: TLabel;
    lblClientSave: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);

  private

    NeedConfig: Boolean;
    Stop: Boolean;

    ImportedCount, NewCount, RejectedCount : Integer;
    FLastDate: tStDate;
    FFirstDate: tStDate;

    function GetAvailableData(FirstTime: Boolean = true): Boolean;
    function DownLoadData: Boolean;
    procedure TestAvailableResponse(Reply: string);
    function TestDownloadResponse(Reply: string; var DownloadId: string): boolean;
    procedure MergeBatch(FromNode: IXMLNode);
    procedure MergeAccount(FromNode: IXMLNode);
    function GetPayeeDetailsForNarration(Payee, line: integer): string;

    // The metodes below are a direct copy of the same named in BNotesInterface
    function ImportStandardTransaction( FromNode: IXMLNode;
                                        BKT: pTransaction_Rec;
                                        BankPrefix: string): Boolean;

    procedure ImportNewTransaction(FromNode: IXMLNode;
                                    bkBank: TBank_Account);

    procedure ImportDissectedTransaction(FromNode: IXMLNode;
                                         BKT: pTransaction_Rec);

    function DissectionsMatch(FromNode: IXMLNode; BKT: pTransaction_Rec): Boolean;
    function WebnotesDissectionMatchesBK5Payee(FromNode: IXMLNode; bkPayee : TPayee): boolean;

    function ExportDissectionLinesToNotes(FromNode: IXMLNode;
                                         BKT: pTransaction_Rec): string;

    procedure ImportExistingDissection(FromNode: IXMLNode;
                                       BKT: pTransaction_Rec);

    procedure ImportNewDissection_NoPayees(FromNode: IXMLNode;
                                           BKT: pTransaction_Rec);

    procedure ImportNewDissection_TransactionLevelPayee(FromNode: IXMLNode;
                                           BKT: pTransaction_Rec);

    procedure ImportNewDissection_DissectionLinePayees (FromNode: IXMLNode;
                                           BKT: pTransaction_Rec);

    procedure ImportJob(FromNode: IXMLNode; BKT: pTransaction_Rec); overload;
    procedure ImportJob(FromNode: IXMLNode; BKD: pDissection_Rec); overload;

    function ImportPayee(FromNode: IXMLNode; BKT: pTransaction_Rec; IsNew: Boolean): integer; overload;
    function ImportPayee(FromNode: IXMLNode; BKD: pDissection_Rec; IsNew: Boolean): integer; overload;

    procedure ImportSuperfund(FromNode: IXMLNode; BKT: pTransaction_Rec); overload;
    procedure ImportSuperfund(FromNode: IXMLNode; BKD: pDissection_Rec); overload;

    procedure ImportDissections(FromNode: IXMLNode; BKT: pTransaction_Rec;  bkPayee: TPayee = nil);
    procedure SetFirstDate(const Value: tStDate);
    procedure SetLastDate(const Value: tStDate);
    property FirstDate: tStDate read FFirstDate write SetFirstDate;
    property LastDate: tStDate read FLastDate write SetLastDate;
    procedure MyOnDateChange(Sender: TObject);
    function GetAvailableText(Short: Boolean): string;
    { Private declarations }
  protected
    procedure UpdateActions; override;
  public
    { Public declarations }
    Client: TClientObj;
  end;

function ImportWebNotesFile(const aClient: TClientObj): string;


implementation

uses
   bkHelp,
   admin32,
   math,
   bkdsio,
   bktxio,
   SuperFieldsUtils,
   software,
   glConst,
   GSTCALC32,
   ECodingUtils,
   MONEYDEF,
   GenUtils,
   TransactionUtils,
   ImportFromECodingDlg,
   LogUtil,
   //CompUtils,
   StStrS,
   bkDateUtils,
   STDateSt,
  
   InfoMoreFrm,
   Progress,
   Globals,
   INISettings,
   WebNotesService,
   WebNotesClient,
   bkXPThemes,
   WebNotesSchema,
   bkConst, trxList32, ForexHelpers,
   AuditMgr,
   Files;

const
   UnitName = 'WebNotesService';
   DebugMe : boolean = False;



{$R *.dfm}

function ImportWebNotesFile(const aClient: TClientObj): string;
var ldlg: TWebNotesImportForm;
begin
   ldlg := TWebNotesImportForm.Create(application.MainForm);
   try
      ldlg.Client := aClient;
      ldlg.lblClientSave.Visible := (aClient.clFields.clCountry = whUK);

      if ldlg.GetAvailableData then
         if ldlg.ShowModal = mrOK then begin

         end;

   finally
      Result := ldlg.GetAvailableText(false);
      ldlg.Free;
   end;
end;


procedure TWebNotesImportForm.ImportDissectedTransaction(FromNode: IXMLNode;
  BKT: pTransaction_Rec);
const
  dplNone = 0;
  dplAtTransaction = 1;
  dplWithinDissection = 2;

var
  ExportToNotesRequired: Boolean;
  DissectionPayeeLevel: byte;
  lPayee: Integer;
  DNode: IXMLNode;
begin
  //we first need to check if the transaction can be imported at all,
  //or if we should just export the transaction to the notes field.
  ExportToNotesRequired := false;

  //if the transaction is dissected then both dissections must match before
  //importing
  if ( BKT^.txFirst_Dissection <> nil) and ( not DissectionsMatch(FromNode, BKT)) then
    ExportToNotesRequired := true;

  //if the transaction is not dissected we need some further tests
  if (BKT.txFirst_Dissection = nil) then begin
    //if bk5 tranasction is coded then export
    if (BKT^.txAccount <> '')
    and (not Sametext(DISSECT_DESC,BKT.txAccount)) then
       ExportToNotesRequired := true;

    //if transaction amounts are different then dissection will not balance
    if (BKT.txAmount <> GetMoneyAttr(FromNode,nAmount)) then begin
       //must be a upc/upd
       if not (BKT.txUPI_State in [upUPC, upUPD, upUPW]) then
          ExportToNotesRequired := true;

       //if the bk5 amount is non zero then export to notes
       if BKT^.txAmount <> 0 then
         ExportToNotesRequired := true;
    end;
  end;

  if ExportToNotesRequired then
  begin
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 3   BNotes (D)   BK5 ( D)  - Dissections don't match
    //CASE 4   BNotes (D)   BK5 ( ND) - TrxAmount different
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -

    UpdateNotes(BKT, ExportDissectionLinesToNotes(FromNode, BKT));

    Exit;
  end;

  if BKT^.txFirst_Dissection <> nil then
  begin
    //both transactions are dissected, test for match has been done
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 5 - BNotes (D)  BK5 (D) - Dissections Match
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    ImportExistingDissection(FromNode, BKT);
  end
  else
  begin
    //bk5 tranaction is not coded, code from dissection bnotes transaction
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 6 - BNotes (D)  BK5 (NC)
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -

    //it is easier to split this into three cases because of the complexity
    //introduced by payees

    //case 6a - The BNotes dissection does not contain any payee coding
    //case 6b - The dissection has been coded via a payee at the trans level
    //case 6c - The dissection has lines with payees codes

    //look for payees in the bnotes dissection
    DissectionPayeeLevel := dplNone;
    lPayee := GetIntAttr(FromNode,nPayeeNumber);
    if LPayee <> 0 then
      DissectionPayeeLevel := dplAtTransaction
    else begin
       DNode := GetFirstDissection(fromNode);
       while (DNode <> nil) do
       begin
          if GetIntAttr(DNode,nPayeeNumber) <> 0 then begin
            DNode := nil;
            DissectionPayeeLevel := dplWithinDissection;
        end else
          DNode := DNode.NextSibling;
      end;
    end;

    //CASE 6a - no payee
    if DissectionPayeeLevel = dplNone then
    begin
      ImportNewDissection_NoPayees(FromNode, BKT);
    end;

    //case 6b - Payee specified at transaction level
    if DissectionPayeeLevel = dplAtTransaction then
    begin
      ImportNewDissection_TransactionLevelPayee(FromNode, BKT);
    end;

    //CASE 6c
    if DissectionPayeeLevel = dplWithinDissection then
    begin
      ImportNewDissection_DissectionLinePayees(FromNode, BKT);
    end;
  end;
end;

procedure TWebNotesImportForm.ImportDissections(FromNode: IXMLNode;
                                                BKT: pTransaction_Rec;
                                                 bkPayee: TPayee = nil);
var
  DNode: IXMLNode;
  DissectionLineNo: Integer;
  BKD: pDissection_Rec;
  bkPayeeLine: pPayee_Line_Rec;
  PayeeDetail: string;
  lTaxamount: Money;
begin
   DissectionLineNo := 1;
   DNode := GetFirstDissection(FromNode);


   while Assigned(DNode) do begin
      //create a new dissection line for the bk5 transaction
      BKD := bkdsio.New_Dissection_Rec;
      ClearSuperFundFields(BKD);
      // add the basics
      BKD.dsAmount := GetMoneyAttr(DNode, nAmount);
      BKD.dsAccount := GetStringAttr(DNode, nChartCode);
      //BKD.dsHas_Been_Edited   := ECD.dsHas_Been_Edited;
      BKD.dsPayee_Number      := 0;



      //GST and Payee
      if Assigned(bkPayee) then begin
         //this is only set if the bk5 payee exists and it matches the
         //dissection
         //bkpayee will have been set above
         //payee will have been set OUTSIDE the dissection

         bkPayeeLine := bkPayee.pdLines.PayeeLine_At(DissectionLineNo - 1);
         BKD.dsGST_Class := bkPayeeLine.plGST_Class;
//         BKD.dsGST_Amount := CalculateGSTForClass(Client, BKT.txDate_Effective, BKD.dsAmount, BKD.dsGST_Class);
         BKD.dsGST_Amount := CalculateGSTForClass(Client, BKT.txDate_Effective, BKD.Local_Amount, BKD.dsGST_Class);
         BKD.dsGST_Has_Been_Edited := bkPayeeLine.plGST_Has_Been_Edited;

         //the payee was specified at the transaction level, the dissection
         //and the payee match so use the details from the payee for the
         //payee detail
         PayeeDetail := bkPayee.pdLines.PayeeLine_At( DissectionLineNo - 1).plGL_Narration;
         // if blank then use payee name
         if Trim(PayeeDetail) = '' then
             PayeeDetail := bkPayee.pdName;
      end else begin
         // Check the disection for Payee
         ImportPayee(DNode,BKD,True);


         //set gst information based on the chart
         //payee not found or dissection too long, use default gst
         //calculate gst using information from the chart codes

//         CalculateGST(Client, BKT.txDate_Effective, BKD.dsAccount, BKD.dsAmount, BKD.dsGST_Class, BKD.dsGST_Amount);
         CalculateGST(Client, BKT.txDate_Effective, BKD.dsAccount, BKD.Local_Amount, BKD.dsGST_Class, BKD.dsGST_Amount);
         PayeeDetail := '';
         BKD.dsGST_Has_Been_Edited := False;
      end;

      //now see if the gst specified in bnotes is different
      //also add a note if gst is 0.00 in both places and trans is uncoded
      lTaxamount := GetMoneyAttr(DNode, nTaxAmount);
      if GetBoolAttr(DNode,ntaxEdited) then
         if ( lTaxamount <> BKD.dsGST_Amount)
         or (( lTaxamount = 0) and ( BKD.dsAccount = '')) then
            AddToImportNotes( BKD, Client.TaxSystemNameUC + ' Amount  ' + Money2Str( lTaxamount), glConst.ECODING_APP_NAME);

      //Quantity
      BKD.dsQuantity := ForceSignToMatchAmount(GetQtyAttr(DNode,nQuantity), BKD.dsAmount);

      //Tax Invoice
      BKD.dsTax_Invoice := GetBoolAttr(DNode,nTaxInvoice);

      // Job
      ImportJob(DNode, BKD);

      //Notes
      BKD.dsNotes := GetStringAttr(DNode,nNotes);

      //Narration
      BKD.dsGL_Narration := UpdateNarration( Client.clFields.clECoding_Import_Options,
                                           BKD.dsGL_Narration,
                                           PayeeDetail,
                                           BKD.dsNotes);


      //Add the new dissection to the transaction
      TrxList32.AppendDissection( BKT, BKD, Client.ClientAuditMgr);

      // Do this after because it need the transaction
      ImportSuperfund(DNode, BKD);

      // Next
      DNode := DNode.NextSibling;
      Inc( DissectionLineNo);
  end;
end;

procedure TWebNotesImportForm.ImportExistingDissection(FromNode: IXMLNode;
  BKT: pTransaction_Rec);
var
  bkPayee: TPayee;
  bkPayeeLine: pPayee_Line_Rec;

  BKD: pDissection_Rec;
  DNode: IXMLNode;

  bkDissectionLine: pDissection_Rec;
  DissectionLineNo: integer;

  DissectionMatchesPayee   : boolean;

  Transaction_Payee: PayeeObj.TPayee;
  trxPayeeDetail: string;
  dPayeeDetail: string;  //detail for dissection line

  UseBK5PayeeInformation: boolean;
  CurrentProcessingPayeeID: integer;

  LinesForCurrentPayee: integer;
  CurrentPayeeLine: integer;
  i,lPayee: integer;
  lMoney: Money;
begin
  //both transactions are dissected, test for match has been done
  // - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //CASE 5 - BNotes (D)  BK5 (D) - Dissections Match
  // - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //GST will have been assigned when the transaction was coded in BK5 so we
  //do not need to reassign the gst here

  trxPayeeDetail := '';
  dPayeeDetail := '';
  Transaction_Payee := nil;
  DissectionMatchesPayee := False;

  //Import Transaction level fields

  //amount
    // already tested that this matches bk5

  //account
    // n/a because transaction is dissected

  //gst
    // n/a because transaction is dissected

  //Notes
  UpdateNotes(BKT, GetStringAttr(FromNode,nNotes));

  //Payee
  //payee cannot be set in bnotes if the transaction has been coded by
  //the accountant, however we may need to recreate the narration
  lPayee := ImportPayee(FromNode,BKT, False);


  //store the payee name so that we can use it to recreate the narration if
  //needed
  if (BKT^.txPayee_Number <> 0) then begin
     //payee has been specified at transaction level
     bkPayee :=  Client.clPayee_List.Find_Payee_Number( BKT^.txPayee_Number);
     if Assigned( bkPayee) then
     begin
        trxPayeeDetail := bkPayee.pdFields.pdName;

        //now see if the dissection matches the narration
        DissectionMatchesPayee := BK5DissectionMatchesBK5Payee( bkPayee, BKT);
        Transaction_Payee := bkPayee;
     end;
  end;
  //Jobs
  ImportJob(FromNode,BKT);

  //GL Narration
  if Assigned(AdminSystem) and AdminSystem.fdFields.fdReplace_Narration_With_Payee then
    BKT^.txGL_Narration := UpdateNarration( Client.clFields.clECoding_Import_Options,
                                            BKT^.txGL_Narration,
                                            trxPayeeDetail,
                                            GetStringAttr(FromNode,nNotes))
  else
    BKT^.txGL_Narration := UpdateNarration( Client.clFields.clECoding_Import_Options,
                                            BKT^.txGL_Narration,
                                            '',
                                            GetStringAttr(FromNode,nNotes));

  BKT^.txTax_Invoice_Available := GetBoolAttr(FromNode,ntaxInvoice);

  //NOW IMPORT DISSECTION LINES
  BKD := BKT.txFirst_Dissection;
  DNode := GetFirstDissection(FromNode);
  DissectionLineNo := 1;

  CurrentProcessingPayeeID := 0;
  CurrentPayeeLine := 0;
  LinesForCurrentPayee := 0;
  //bkPayeeLine := nil;
  UseBK5PayeeInformation := false;

  while Assigned(BKD) do begin
     BKD.dsECoding_Import_Notes := '';

     //Amount
      //already tested that this matches bk5, also cannot be edited in bnotes unless upc

     //Account
      //already tested that this matched bk5, also cannot be edited in bnotes if it was dissected in bk5 on export

     //GST Amount
      //show flag if amounts are different or user has specied gst and zero for
      //and uncoded line
     lMoney := GetMoneyAttr(DNode,nTaxAmount);
     if (GetBoolAttr(DNode,nTaxEdited)) then
        if (lMoney <> BKD.dsGST_Amount)
        or ((lMoney = 0) and (BKD.dsAccount = '')) then begin
           AddToImportNotes(BKD, Client.TaxSystemNameUC + ' Amount  ' + Money2Str(LMoney), glConst.ECODING_APP_NAME);
     end;

     //Quantity
     lMoney := GetQtyAttr(DNode,nQuantity);
     lMoney := ForceSignToMatchAmount(lMoney, BKD.dsAmount);
     if (lMoney <> BKD^.dsQuantity) then begin
        if BKD.dsQuantity = 0 then begin
           BKD^.dsQuantity := lMoney;
        end else
           AddToImportNotes( BKD, 'Quantity  ' + FormatFloat('#,##0.####', LMoney/10000), glConst.ECODING_APP_NAME);
     end;

     //Tax Invoice
     BKD.dsTax_Invoice := GetBoolAttr(DNode,nTaxInvoice);

     //Notes
     BKD.dsNotes := GetStringAttr(DNode,nNotes);

     //Payee
     //show note if payee values are different
     lPayee := ImportPayee(DNode,BKD,False);


    if BKT^.txPayee_Number <> 0 then
    begin
      //if the dissection has been created by a payee at transaction level then
      //use the payee for narration
      if DissectionMatchesPayee then
        dPayeeDetail := Transaction_Payee.pdLines.PayeeLine_At( DissectionLineNo - 1).plGL_Narration
      else
        dPayeeDetail := '';  //dont know what payee detail to use

      UseBK5PayeeInformation := false;
    end
    else
    begin
      //if the dissection lines are coded by payee then we need to see if
      //the payee lines match the next n dissection lines
      //this will allow us to reset the narration
      bkPayee := Client.clPayee_List.Find_Payee_Number(BKD.dsPayee_Number);
      dPayeeDetail := '';

      if not Assigned(bkPayee) then
      begin
        dPayeeDetail := '';
        UseBK5PayeeInformation := false;
      end
      else
      begin
        //payee found
        dPayeeDetail := bkPayee.pdFields.pdName;

        //see if we are already coding using a payee
        if ( CurrentProcessingPayeeID <> BKD.dsPayee_Number) or ( CurrentPayeeLine > ( LinesForCurrentPayee - 1)) then
        begin
          //this is a new payee id, see if the following lines match
          //the structure of the payee in bk5
          CurrentProcessingPayeeID := bkPayee.pdFields.pdNumber;
          LinesForCurrentPayee := bkPayee.pdLinesCount;
          CurrentPayeeLine := 0;
          UseBK5PayeeInformation := false;
          //bkPayeeLine := nil;

          if LinesForCurrentPayee > 0 then
          begin
            bkDissectionLine := BKD;
            //see if next n lines match the bk5 payee
            i := 0;
            Repeat
              bkPayeeLine := bkPayee.pdLines.PayeeLine_At( i);
              UseBK5PayeeInformation := ( bkDissectionLine.dsAccount = bkPayeeLine.plAccount);
              bkDissectionLine := bkDissectionLine.dsNext;
              if bkDissectionLine <> nil then
                Inc( i);
            Until ( i = LinesForCurrentPayee) or ( bkDissectionLine = nil) or ( not UseBK5PayeeInformation);

            //make sure there are enough dissection lines
            if ( i < (LinesForCurrentPayee - 1)) then
              UseBK5PayeeInformation := false;

            if not UseBK5PayeeInformation then
            begin
              LinesForCurrentPayee := 0;
              //bkPayeeLine := nil;
            end;
          end;
        end;

        //get the current line and use that to set the narration
        if UseBK5PayeeInformation then
        begin
          bkPayeeLine := bkPayee.pdLines.PayeeLine_At( CurrentPayeeLine);
          dPayeeDetail := bkPayeeLine.plGL_Narration;
          Inc( CurrentPayeeLine);
        end;
      end;
    end;

    //Jobs
    ImportJob(DNode, BKD);

    //Narration
    BKD.dsGL_Narration := UpdateNarration( Client.clFields.clECoding_Import_Options,
                                           BKD.dsGL_Narration,
                                           dPayeeDetail,
                                           GetStringAttr(DNode,nNotes));

    //Superfields
    ImportSuperfund(DNode, BKD);


    //move to next dissection line
    BKD := BKD.dsNext;
    DNode := DNode.NextSibling;
    Inc( DissectionLineNo);
  end;
end;



procedure TWebNotesImportForm.ImportJob(FromNode: IXMLNode; BKD: pDissection_Rec);
var
  bkJob: pJob_Heading_Rec;
  wnJob: string;
begin
  wnJob := GetStringAttr(FromNode, nJobCode);
  if wnJob <> BKD.dsJob_Code then begin
     bkJob := Client.clJobs.FindCode(wnJob);
     if (wnJob > '') and (not Assigned(bkJob)) then
         AddToImportNotes(BKD,Format('Unknown Job %s', [wnjob]), glConst.ECODING_APP_NAME)
    else begin
      //if there was no existing job then apply new job
      if BKD.dsJob_Code = '' then begin
         BKD.dsJob_Code := wnJob;
         BKD.dsHas_Been_Edited := true;
      end else begin
         //add notes
         if wnJob = '' then
            AddToImportNotes(BKD, 'Job Removed', glConst.ECODING_APP_NAME)
        else
           //deleted job
           AddToImportNotes(BKD, 'Job ' + bkJob.jhHeading + ' (' + bkJob.jhCode + ')', glConst.ECODING_APP_NAME);
      end;
    end;
  end;
end;

procedure TWebNotesImportForm.ImportJob(FromNode: IXMLNode; BKT: pTransaction_Rec);
var
  bkJob: pJob_Heading_Rec;
  wnJob: string;
begin
  wnJob := GetStringAttr(FromNode, nJobCode);
  if wnJob <> BKT.txJob_Code then begin
     bkJob := Client.clJobs.FindCode(wnJob);
     if (wnJob > '')
     and (not Assigned(bkJob)) then
        AddToImportNotes(BKT,Format('Unknown Job %s', [wnjob]), glConst.ECODING_APP_NAME)
     else begin
        //if there was no existing job then apply new job
        if BKT.txJob_Code = '' then begin
           BKT.txJob_Code := wnJob;
           BKT.txHas_Been_Edited := true;
        end else begin
           //add notes
           if wnJob = '' then //deleted job
              AddToImportNotes(BKT, 'Job Removed', glConst.ECODING_APP_NAME)
           else
              AddToImportNotes(BKT, 'Job ' + bkJob.jhHeading + ' (' + bkJob.jhCode + ')', glConst.ECODING_APP_NAME);
      end;
    end;
  end;
end;

procedure TWebNotesImportForm.ImportNewDissection_DissectionLinePayees(
  FromNode: IXMLNode; BKT: pTransaction_Rec);

var
  bkPayee : TPayee;
  lint: Integer;
  DissectionMatchesPayee   : boolean;
  trxPayeeDetail     : string;
  dPayeeDetail       : string;  //detail for dissection line
  UseTransactionPayeeDetails  : boolean;
begin
  //Dissect the BK5 transaction
  BKT.txAccount := DISSECT_DESC;
  ClearGSTFields( BKT);
  ClearSuperFundFields( BKT);

  //Import Transaction Level Fields
  //Amount
  BKT.txTax_Invoice_Available := GetBoolAttr(FromNode,ntaxinvoice);
  BKT.txAmount := GetMoneyAttr(FromNode, nAmount);
  BKT.txPayee_Number := 0;
  ImportJob(FromNode,BKT);
  //Payee
  bkPayee := nil;
  trxPayeeDetail := '';
  dPayeeDetail := '';
  UseTransactionPayeeDetails := False;
  lInt := ImportPayee(FromNode, BKT, True);
  if lInt <> 0 then begin

      bkPayee := Client.clPayee_List.Find_Payee_Number(lInt);

      if  Assigned( bkPayee) then
      begin
        //payee found
        //set the bk5 payee number from here
        BKT.txPayee_Number         := lInt;
        BKT.txHas_Been_Edited      := True;

        if bkPayee.IsDissected then
        begin
          //use the payee name outside the narration
          if Assigned(AdminSystem) and AdminSystem.fdFields.fdReplace_Narration_With_Payee then
          begin
            trxPayeeDetail := bkPayee.pdName;
            dPayeeDetail   := trxPayeeDetail;
          end
          else
          begin
            trxPayeeDetail := '';
            dPayeeDetail   := bkPayee.pdName;
          end;

          //now we need to see if the payee lines match the dissection lines
          //this will be used later to decide what payee details to add
          //to each line
          DissectionMatchesPayee := WebnotesDissectionMatchesBK5Payee(FromNode, bkPayee);
        end
        else
        begin
          //transaction is dissected but payee is not.
          trxPayeeDetail       := bkPayee.pdName;
          dPayeeDetail         := '';
          DissectionMatchesPayee := false;
        end;

        //the payee and dissection match so we can use the bk5 payee for
        //calculating the default gst for this line
        UseTransactionPayeeDetails := DissectionMatchesPayee;
      end;

  end;

  //GL Narration
  BKT^.txGL_Narration := UpdateNarration( Client.clFields.clECoding_Import_Options,
                                          BKT^.txGL_Narration,
                                          trxPayeeDetail,
                                          GetStringAttr(FromNode,nNotes));
  //Notes
  UpdateNotes(BKT, GetStringAttr(FromNode,nNotes));

  lint := GetCodeByAttr(FromNode,nCodedBy);
  case lint of
    cbManual      : BKT^.txCoded_By := bkconst.cbECodingManual;
    cbManualPayee : BKT^.txCoded_By := bkconst.cbECodingManualPayee;
  else
    BKT^.txCoded_By := lint;
  end;


  if UseTransactionPayeeDetails then
     ImportDissections(FromNode, BKT, bkPayee)
  else
     ImportDissections(FromNode, BKT);
end;

procedure TWebNotesImportForm.ImportNewDissection_NoPayees(FromNode: IXMLNode;
  BKT: pTransaction_Rec);
var
  CodeBy: Integer;
begin

  BKT.txAccount := DISSECT_DESC;
  BKT.txTax_Invoice_Available := GetBoolAttr(FromNode,ntaxinvoice);

  ClearGSTFields(BKT);
  ClearSuperFundFields(BKT);

  //Import Transaction Level Fields
  BKT.txAmount := GetMoneyAttr(FromNode,nAmount);
  BKT.txPayee_Number := 0;

  //Jobs
  ImportJob(FromNode, BKT);
  ImportSuperfund(FromNode, BKT);
  BKT^.txGL_Narration := UpdateNarration(Client.clFields.clECoding_Import_Options,
                                         BKT.txGL_Narration,
                                         '',
                                         GetStringAttr(FromNode,nNotes));

  UpdateNotes(BKT, GetStringAttr(FromNode,nNotes));

  CodeBy := GetCodeByAttr(FromNode,nCodedBy);
  case CodeBy of
     cbManual,  // Curtacy only, cannot be  cbManualPayee
     cbManualPayee : BKT.txCoded_By := bkconst.cbECodingManual;
  else
     BKT.txCoded_By := CodeBy;
  end;

  ImportDissections(FromNode, BKT);

end;

procedure TWebNotesImportForm.ImportNewDissection_TransactionLevelPayee(
  FromNode: IXMLNode; BKT: pTransaction_Rec);

var
  bkPayee: TPayee;
  lInt: Integer;
  DissectionMatchesPayee: boolean;
  trxPayeeDetail: string;
  dPayeeDetail: string;  //detail for dissection line
  UseTransactionPayeeDetails: boolean;
begin
  //Dissect the BK5 transaction
  BKT.txAccount := DISSECT_DESC;
  ClearGSTFields(BKT);
  ClearSuperFundFields(BKT);

  //Import Transaction Level Fields
  //Amount
  BKT.txTax_Invoice_Available := GetBoolAttr(FromNode,nTaxInvoice);
  BKT.txAmount := GetMoneyAttr(FromNode, nAmount);
  BKT.txPayee_Number := 0;
  ImportJob(FromNode, BKT);
  ImportSuperfund(FromNode, BKT);
  //Payee
  bkPayee := nil;
  trxPayeeDetail := '';
  dPayeeDetail := '';
  UseTransactionPayeeDetails := False;

  lInt := ImportPayee(FromNode,BKT, True);
  if lInt <> 0 then begin

      bkPayee := Client.clPayee_List.Find_Payee_Number(lInt);

      if Assigned(bkPayee) then
      begin
        //payee found
        //set the bk5 payee number from here
        BKT.txPayee_Number         := lInt;
        BKT.txHas_Been_Edited      := True;

        if bkPayee.IsDissected then
        begin
          //use the payee name outside the narration
          if Assigned(AdminSystem) and AdminSystem.fdFields.fdReplace_Narration_With_Payee then
          begin
            trxPayeeDetail := bkPayee.pdName;
            dPayeeDetail   := trxPayeeDetail;
          end
          else
          begin
            trxPayeeDetail := '';
            dPayeeDetail   := bkPayee.pdName;
          end;

          //now we need to see if the payee lines match the dissection lines
          //this will be used later to decide what payee details to add
          //to each line
          DissectionMatchesPayee := WebnotesDissectionMatchesBK5Payee(FromNode, bkPayee);
        end
        else
        begin
          //transaction is dissected but payee is not.
          trxPayeeDetail       := bkPayee.pdName;
          dPayeeDetail         := '';
          DissectionMatchesPayee := false;
        end;

        //the payee and dissection match so we can use the bk5 payee for
        //calculating the default gst for this line
        UseTransactionPayeeDetails := DissectionMatchesPayee;
      end;
    end;


  //GL Narration
  BKT.txGL_Narration := UpdateNarration( Client.clFields.clECoding_Import_Options,
                                          BKT^.txGL_Narration,
                                          trxPayeeDetail,
                                          GetStringAttr(FromNode,nNotes));
  //Notes
  UpdateNotes(BKT, GetStringAttr(FromNode,nNotes));

  lInt := GetCodeByAttr(FromNode,nCodedBy);
  case lInt of
    cbManual      : BKT.txCoded_By := bkconst.cbECodingManual;
    cbManualPayee : BKT.txCoded_By := bkconst.cbECodingManualPayee;
  else
    BKT^.txCoded_By := lInt;
  end;


  if UseTransactionPayeeDetails then
     ImportDissections(FromNode, BKT, bkPayee)
  else
     ImportDissections(FromNode, BKT);

end;

procedure TWebNotesImportForm.ImportNewTransaction(FromNode: IXMLNode;
  bkBank: TBank_Account);
var
  BKT : pTransaction_Rec;
  Prefix : string;
  lState: Integer;
begin
  //no matching bk5 transaction found
  //
  // - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //CASE 7 - New Transaction, code from BNotes
  // - - - - - - - - - - - - - - - - - - - - - - - - - - -
  lState := GetUPIStateAttr(FromNode,nUPIState);
  if lState in [upUPD, upUPC, upUPW] then begin
    //set up a new blank transaction, fill cheque details
    BKT := bktxio.New_Transaction_Rec;
    ClearSuperFundFields(BKT);

    //determine if the UPC matches an existing bk5 transaction
    //the transaction may have been downloaded since, or already imported from
    //this bnotes file
    case lState of
      upUPD : BKT.txType := whDepositEntryType [Client.clFields.clCountry];
      upUPC : BKT.txType := whChequeEntryType [Client.clFields.clCountry];
      upUPW : BKT.txType := whWithdrawalEntryType [Client.clFields.clCountry];
    end;

    //set up the new transaction
    //BKT.txType                := ECT^.txType;
    BKT.txSource              := orGenerated;
    BKT.txDate_Presented      := 0;
    BKT.txDate_Effective      := GetDateAttr(FromNode,nDateEffective);
    BKT.txCheque_Number       := GetIntAttr(FromNode,nChequeNumber);
    BKT.txReference           := GetStringAttr(FromNode, nReference);
    BKT.txUPI_State           := lState;
    BKT.txBank_Seq            := bkBank.baFields.baNumber;
    bkBank.baTransaction_List.Insert_Transaction_Rec(BKT);
  end;

  //now use standard routines to import the transaction
  if Assigned(BKT) then begin
     if Assigned(GetFirstDissection(FromNode)) then begin
         ImportDissectedTransaction(FromNode, BKT );
     end else begin
        Prefix := Copy( bkBank.baFields.baBank_Account_Number, 1, 2);
        ImportStandardTransaction(FromNode, BKT, Prefix);
     end;

  end;
end;

function TWebNotesImportForm.ImportPayee(FromNode: IXMLNode;
  BKT: pTransaction_Rec; IsNew: Boolean): Integer;
var wnPayeeText: string;
    bkPayee: TPayee;
begin
  wnPayeeText := GetStringAttr(FromNode, nPayeeNumber);
  if wnPayeeText > '' then begin
     try
        Result := StrToInt(wnPayeeText);
     except
        // Its not a number.. Must be new Payee
        Result := 0;
        AddToImportNotes(BKT,Format('New Payee %s', [wnPayeeText]), glConst.ECODING_APP_NAME);
        Exit;
     end;
  end else
     Result := 0;

  if (BKT.txPayee_Number <> Result) then begin
     //payee is different, add a note
     if Result <> 0 then begin
        bkPayee := Client.clPayee_List.Find_Payee_Number(Result);
        if Assigned(bkPayee) then begin
           if not IsNew then
              AddToImportNotes( BKT, 'Payee ' + bkPayee.pdName + ' (' + inttostr( bkPayee.pdNumber) + ')', WebNotesName)
        end else
           AddToImportNotes( BKT, format('Unkown payee (%d)',[Result])  , WebNotesName);
     end else begin
        // Diffrent but zero, i.e was somthing before..
        // Cannot realy happen but he...
        bkPayee := Client.clPayee_List.Find_Payee_Number(BKT.txPayee_Number);
        if Assigned(bkPayee) then
           AddToImportNotes( BKT, 'Payee removed ' + bkPayee.pdName + ' (' + inttostr(BKT.txPayee_Number) + ')', WebNotesName)
        else
           AddToImportNotes( BKT, format('Unkown payee (%d) removed',[BKT.txPayee_Number])  , WebNotesName);
     end;
  end;

end;

function TWebNotesImportForm.ImportPayee(FromNode: IXMLNode;
  BKD: pDissection_Rec; IsNew: Boolean): integer;
var wnPayeeText: string;
    bkPayee: TPayee;
begin
  wnPayeeText := GetStringAttr(FromNode, nPayeeNumber);
  if wnPayeeText > '' then begin
     try
        Result := StrToInt(wnPayeeText);
     except
        // Its not a number.. Must be new Payee
        Result := 0;
        AddToImportNotes(BKD,Format('New Payee %s', [wnPayeeText]), glConst.ECODING_APP_NAME);
        Exit;
     end;
  end else
     Result := 0;


  if (BKD.dsPayee_Number <> Result) then begin
     //payee is different, add a note
     if Result <> 0 then begin
        bkPayee := Client.clPayee_List.Find_Payee_Number(Result);
        if Assigned(bkPayee) then begin
           if isNew then
              // Just add it now
              BKD.dsPayee_Number := bkPayee.pdFields.pdNumber
           else
              // Add as note..
              AddToImportNotes( BKD, 'Payee ' + bkPayee.pdName + ' (' + inttostr( bkPayee.pdNumber) + ')', WebNotesName)
        end else
           AddToImportNotes( BKD, format('Unkown payee (%d)',[Result])  , WebNotesName);
     end else begin
        // Cannot realy happen but he...
        bkPayee := Client.clPayee_List.Find_Payee_Number(BKD.dsPayee_Number);
        if Assigned(bkPayee) then
           AddToImportNotes( BKD, 'Payee removed ' + bkPayee.pdName + ' (' + inttostr(BKD.dsPayee_Number) + ')', WebNotesName)
        else
           AddToImportNotes( BKD, format('Unkown payee (%d) removed',[BKD.dsPayee_Number])  , WebNotesName);
     end;
  end;

end;


function TWebNotesImportForm.ImportStandardTransaction( FromNode: IXMLNode;
                                     BKT : pTransaction_Rec;
                                     BankPrefix : string): Boolean;
var
  bkPayee : PayeeObj.TPayee;
  bkPayeeLine : pPayee_Line_Rec;

  NeedToUpdatePayeeDetails : boolean;
  NeedToUpdateGST : boolean;
  trxPayeeDetails : string;
  lMoney: Money;
  lString: string;
  lInt: Integer;
  aMsg : string;
begin
  Result := False;
  //first we need to determine if the bk5 transaction is coded
  //if it is currently uncoded then code the transaction using the information
  //in the bnotes transaction
  NeedToUpdatePayeeDetails := False;
  NeedToUpdateGST          := False;
  trxPayeeDetails          := '';

  if BKT.txFirst_Dissection = nil then begin
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 1 - BNotes (ND)  BK5 (ND)
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //The BK5 transaction has not been dissected

    //Amount - override the amount if the transaction is a UPC or UPD
    lMoney := GetMoneyAttr(FromNode,nAmount);
    if ( BKT.txUPI_State in [ upUPC, upUPD, upUPW])
    and ( BKT.txAmount <> lMoney) then begin
       if BKT.txAmount = 0 then begin
          BKT.txAmount := lMoney;
          //update the GST amount if a class has been set in BK5.  This is in
          //case the transaction has been coded
          if BKT.txGST_Class = 0 then
              BKT.txGST_Amount := 0
          else
//              BKT.txGST_Amount := CalculateGSTForClass( Client, BKT.txDate_Effective, BKT.txAmount, BKT.txGST_Class);
              BKT.txGST_Amount := CalculateGSTForClass( Client, BKT.txDate_Effective, BKT.Local_Amount, BKT.txGST_Class);
      end else begin
        //bk5 transaction already has an amount, so add a note to import notes
        if lMoney <> 0 then
           AddToImportNotes( BKT, 'Amount '+ Money2Str(lMoney), WebNotesName );
      end;
    end;

    //Account
    lString := GetStringAttr(FromNode,nChartCode);
    if (BKT.txAccount <> lString)
    and (LString <> '') then begin
      Result := True;
      if BKT.txAccount = '' then begin
         //account is blank so use ecoding account to code the transaction
         BKT.txAccount := LString;
         BKT.txHas_Been_Edited := True;

         if GetCodeByAttr(FromNode,nCodedBy) in [cbManual] then
            NeedToUpdateGST := true;
      end else begin
         AddToImportNotes( BKT, 'Account Code ' + LString, WebNotesName);
      end;
    end;

    //Payee
    bkPayee := nil;
    LInt := ImportPayee(Fromnode, BKT, True);
    if LInt <> 0 then begin

       //get payees
       bkPayee := Client.clPayee_List.Find_Payee_Number (LInt);

       if ( Lint = BKT^.txPayee_Number) then
          //even though the payee has not changed we need to reconstruct the
          //payee details so that the narration can be set correctly
          NeedToUpdatePayeeDetails := True
       else begin
          // Diffrent Payee
          if Assigned(bkPayee) then begin
             if (BKT.txPayee_Number = 0) then begin
                //set the bk5 payee number from here
                BKT.txPayee_Number         := Lint;
                BKT.txHas_Been_Edited      := True;
                NeedToUpdatePayeeDetails   := True;

                if GetCodeByAttr(FromNode,nCodedBy) = cbManualPayee then
                   NeedToUpdateGST        := True;
             end;
          end;
       end;   




      //now construct the payee details string so that we can set the narration
      if NeedToUpdatePayeeDetails then
      begin
        if Assigned(bkPayee) then
        begin
          if bkPayee.IsDissected then
          begin
            if Assigned(AdminSystem) and AdminSystem.fdFields.fdReplace_Narration_With_Payee then
              trxPayeeDetails := bkPayee.pdName
            else
              trxPayeeDetails := '';
          end
          else
          begin
            bkPayeeLine := bkPayee.FirstLine;
            if Assigned( bkPayeeLine)
            and (bkPayeeLine.plAccount = BKT.txAccount) then
              trxPayeeDetails := GetPayeeDetailsForNarration(BKT.txPayee_Number,0)
            else
              trxPayeeDetails := bkPayee.pdName; //cant find details so at least use name
          end;
        end;
      end;

    end;

    //jobs
    ImportJob(FromNode, BKT);
    

    //GST
    lString := GetStringAttr(FromNode,nCodedBy);
    if NeedToUpdateGST then begin
      if Sametext(cbNames[cbManual],lString ) then begin
         //if manually coded then update gst class and amount from the account code
         //this will also update txCoded_by , txHasBeenEdited and txGST_has_been_Edited
         UpdateTransGSTFields( Client, BKT, BankPrefix, cbECodingManual);
      end;

      if Sametext(cbNames[cbManualPayee], lString) then begin
         //get payees
         bkPayee := Client.clPayee_List.Find_Payee_Number(ImportPayee(Fromnode, BKT,True));
         bkPayeeLine := bkPayee.FirstLine;

         //decide whether to use gst from chart or payee
         if (Assigned(bkPayeeLine))
         and (bkPayeeLine.plGST_Has_Been_Edited)
         and (BKT^.txAccount = GetStringAttr(FromNode,nChartCode)) then begin
            //the gst has been overriden at the payee level so use that gst info
            //to code the transaction, this means that the gst amount in bnotes
            //should match the default gst amount for bk5
            BKT^.txGST_Class  := bkPayeeLine.plGST_Class;
//            BKT^.txGST_Amount := CalculateGSTForClass(Client,BKT^.txDate_Effective, BKT^.txAmount, BKT^.txGST_Class);
            BKT^.txGST_Amount := CalculateGSTForClass(Client,BKT^.txDate_Effective, BKT^.Local_Amount, BKT^.txGST_Class);
            BKT^.txGST_Has_Been_Edited := True;
         end else begin
            //use the gst from the account code
            UpdateTransGSTFields(Client, BKT, BankPrefix, cbECodingManual);
         end;

         BKT.txCoded_By := cbECodingManualPayee;
         BKT.txHas_Been_Edited  := True;
      end;
    end;

    //gst
    if GetBoolAttr(FromNode, nTaxEdited) then begin
       aMsg := '';
       //GST will be set if account is set above
       //In all other cases the gst amount will be written to import notes
       //unless it is blank in BNotes.  Blank means don't change
       //also show note if user has specified gst and 0.00 for an uncoded trans
       lMoney := GetMoneyAttr(FromNode,nTaxAmount);
       if (BKT.txGST_Amount <> lMoney)
       or ((lMoney = 0) and (BKT.txAccount = '')) then begin
          aMsg := Client.TaxSystemNameUC + ' Amount    ' + Money2Str(LMoney);
        end;
        AddToImportNotes(BKT, aMsg, WebNotesName);
    end;

    //tax inv
    BKT.txTax_Invoice_Available := GetBoolAttr(FromNode, nTaxInvoice);

    //quantity
    //correct the sign of the quantity before comparing in case it is incorrect
    //in bnotes
    lMoney := GetQtyAttr(FromNode, nQuantity);
    lMoney := ForceSignToMatchAmount(lMoney, BKT.txAmount);
    if (BKT.txQuantity <> lMoney) then begin
      if BKT.txQuantity = 0 then begin
         BKT.txQuantity := lMoney;
      end else
         AddToImportNotes(BKT , 'Quantity   ' + FormatFloat('#,##0.####', lMoney/10000), WebNotesName);
    end;

    ImportSuperfund(FromNode, BKT);

    //gl narration
    BKT.txGL_Narration := UpdateNarration( Client.clFields.clECoding_Import_Options,
                                            BKT^.txGL_Narration,
                                            trxPayeeDetails,
                                            GetStringAttr(FromNode, nNotes));

    //Notes
    UpdateNotes(BKT, GetStringAttr(FromNode, nNotes));


  end else begin
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 2 - BNotes (ND)  BK5 (D)
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //Export the details to the notes field as the bk5 transaction is dissected
    lMoney := GetMoneyAttr(FromNode, nAmount);
    lString := GetStringAttr(FromNode, nUPIState);
    if ((lString = upNames[upUPD]) or (lString = upNames[upUPC]) or (lString = upNames[upUPW]))
    and ( lMoney <> 0) then begin
       AddToImportNotes( BKT, 'Amount ' + Money2Str(lMoney), WebNotesName);
    end;
    //account
    lString := GetStringAttr(FromNode,nChartCode);
    if (lString <> '') then
       AddToImportNotes( BKT, 'Account Code ' + lString, WebNotesName);
    //gst, tax inv
    if GetBoolAttr(FromNode, nTaxEdited) then begin
        AddToImportNotes( BKT, Client.TaxSystemNameUC + ' Amount ' + Money2Str(GetMoneyAttr(Fromnode, nTaxAmount)), WebNotesName);
    end;
    //payee
    ImportPayee(FromNode, BKT, False);

    //quantity
    lMoney := GetQtyAttr(FromNode,nQuantity);
    lMoney := ForceSignToMatchAmount(lMoney, GetMoneyAttr(FromNode,nAmount));
    if (lMoney <> 0) then begin
       AddToImportNotes( BKT, 'Quantity ' + FormatFloat('#,##0.####', lMoney/10000), WebNotesName);
    end;

    //tax invoice
    BKT.txTax_Invoice_Available := GetBoolAttr(FromNode,nTaxInvoice);

    //notes
    UpdateNotes(BKT, GetStringAttr(FromNode,nNotes));
  end;
end;


procedure  TWebNotesImportForm.ImportSuperfund(FromNode: IXMLNode; BKT: pTransaction_Rec);
var amsg: string;
begin
    if software.IsSuperFund(Client.clFields.clCountry, Client.clFields.clAccounting_System_Used) then begin
       //Have a go..

       if (BKT.txSF_Franked <> GetMoneyAttr(FromNode, nSFFranked))
       or (BKT.txSF_UnFranked <> GetMoneyAttr(FromNode, nSFUnFranked))
       or (BKT.txSF_Imputed_Credit <> GetMoneyAttr(FromNode, nSFFrankingCredit)) then begin
          // Someting Changed...
          if (BKT.txSF_Franked = 0)
          and (BKT.txSF_UnFranked = 0)
          and (BKT.txSF_Imputed_Credit = 0) then begin
             // Did not have anny, just fill it in..
             BKT^.txSF_Franked := GetMoneyAttr(FromNode, nSFFranked);
             BKT^.txSF_UnFranked := GetMoneyAttr(FromNode, nSFUnFranked);
             BKT^.txSF_Imputed_Credit := GetMoneyAttr(FromNode, nSFFrankingCredit);
             BKT^.txSF_Super_Fields_Edited := True;
             BKT^.txHas_Been_Edited  := True;
             BKT^.txCoded_By := cbECodingManual;
             if FrankingCredit(BKT^.txSF_Franked, BKT^.txDate_Effective) <> BKT^.txSF_Imputed_Credit  then begin
                aMsg := 'The franking credit amounts do not match the calculated amounts ''Franked: $' + Money2Str( BKT^.txSF_Franked) +
                ' Unfranked: $' +  Money2Str( BKT^.txSF_UnFranked) +
                ' Franking Credits: $' +  Money2Str( BKT^.txSF_Imputed_Credit) + '''';
                AddToImportNotes( BKT,aMsg , WebNotesName);
             end;

          end else begin
             aMsg := 'Superfund: ''Franked: $' + Money2Str( GetMoneyAttr(FromNode, nSFFranked)) +
                ' Unfranked: $' +  Money2Str( GetMoneyAttr(FromNode, nSFUnFranked)) +
                ' Franking Credits: $' +  Money2Str( GetMoneyAttr(FromNode, nSFFrankingCredit)) + '''';
                AddToImportNotes( BKT,aMsg , WebNotesName);
          end;
       end;
    end;
end;

procedure TWebNotesImportForm.ImportSuperfund(FromNode: IXMLNode; BKD: pDissection_Rec);
var amsg: string;
begin
    if software.IsSuperFund(Client.clFields.clCountry, Client.clFields.clAccounting_System_Used) then begin
       //Have a go..

       if (BKD.dsSF_Franked <> GetMoneyAttr(FromNode, nSFFranked))
       or (BKD.dsSF_UnFranked <> GetMoneyAttr(FromNode, nSFUnFranked))
       or (BKD.dsSF_Imputed_Credit <> GetMoneyAttr(FromNode, nSFFrankingCredit)) then begin
          // Someting Changed...
          if (BKD.dsSF_Franked = 0)
          and (BKD.dsSF_UnFranked = 0)
          and (BKD.dsSF_Imputed_Credit = 0) then begin
             // Did not have anny, just fill it in..
             BKD.dsSF_Franked := GetMoneyAttr(FromNode, nSFFranked);
             BKD.dsSF_UnFranked := GetMoneyAttr(FromNode, nSFUnFranked);
             BKD.dsSF_Imputed_Credit := GetMoneyAttr(FromNode, nSFFrankingCredit);
             BKD.dsSF_Super_Fields_Edited := True;
             BKD.dsHas_Been_Edited  := True;
             //BKD.dsCoded_By := cbECodingManual;
             if FrankingCredit(BKD.dsSF_Franked, BKD.dsTransaction.txDate_Effective) <> BKD.dsSF_Imputed_Credit  then begin
                aMsg := 'The franking credit amounts do not match the calculated amounts ''Franked: $' + Money2Str(BKD.dsSF_Franked) +
                ' Unfranked: $' +  Money2Str(BKD.dsSF_UnFranked) +
                ' Franking Credits: $' +  Money2Str(BKD.dsSF_Imputed_Credit) + '''';
                AddToImportNotes( BKD,aMsg , WebNotesName);
             end;

          end else begin
             aMsg := 'Superfund: ''Franked: $' + Money2Str( GetMoneyAttr(FromNode, nSFFranked)) +
                ' Unfranked: $' +  Money2Str( GetMoneyAttr(FromNode, nSFUnFranked)) +
                ' Franking Credits: $' +  Money2Str( GetMoneyAttr(FromNode, nSFFrankingCredit)) + '''';
                AddToImportNotes( BKD,aMsg , WebNotesName);
          end;
       end;
    end;
end;

procedure TWebNotesImportForm.MergeAccount(FromNode: IXMLNode);
var AccountNo: string;
    ba: TBank_Account;
    TransNode: IXMLNode;
    T: Integer;
    Prefix,
    msg: string;


    procedure MergeTransaction(FromNode: IXMLNode);
    var
       bkId: Integer;
       Trans : pTransaction_Rec;

       function FindTrans: pTransaction_Rec;
       var bkT: Integer;
       begin
          for bkT := 0 to Pred( ba.baTransaction_List.ItemCount) do begin
             Result := ba.baTransaction_List.Transaction_At( bkT);
             if Result.txECoding_Transaction_UID = bkId then
                Exit;
          end;
          Result := nil;
       end;

       function ValidateTransactionForImport(Trans : pTransaction_Rec; var aMsg : string): boolean;
       var LDate: Tstdate;
       begin
          result := false;
          aMsg   := '';

          //check match found
          if not Assigned(Trans) then begin
             aMsg := 'Match not found';
             Exit;
          end;

          //check the presentation dates match
          (* TFS Bug 3115, Webnotes does not set Presented date, cannot Test for it...
          lDate := GetDateAttr(FromNode, nDateEffective);
          if not (( lDate = 0 ) or ( lDate = Trans.txDate_Presented)) then begin
             //rejected transaction found, pres dates different
             aMsg := 'Pres Date Mismatch, expected ' + bkDate2Str( Trans.txDate_Presented);
             Exit;
          end;
          *)

          //check for finalised or transferred in bk5
          if ( Trans.txLocked) then begin
             aMsg := 'Finalised';
             Exit;
          end;
          if ( Trans.txDate_Transferred <> 0 ) then begin
             aMsg := 'Transferred';
             Exit;
          end;
          //everything ok
          Result := true;
       end;


    begin // MergeTransaction
       if not Sametext(FromNode.NodeName,nTransaction) then
          Exit; // Not a valid node..

       bkId := GetIntAttr(FromNode,nExternalID);
       if bkID > 0 then begin

          Trans := FindTrans;
          if ValidateTransactionForImport(Trans, msg) then begin
             if assigned(GetFirstDissection(FromNode)) then
                ImportDissectedTransaction(FromNode,Trans)
             else
                ImportStandardTransaction(FromNode,Trans,Prefix);
             inc(ImportedCount);
          end else  begin
             inc(RejectedCount);
             // ? Log the msg
          end;
       end else begin
          ImportNewTransaction(FromNode, ba);
       end;
    end; //MergeTransaction

begin //MergeAccount
   if not Sametext(FromNode.NodeName,nAccount) then
      Exit;
   AccountNo := FromNode.Attributes [nNumber];
   ba := Client.clBank_Account_List.FindCode(AccountNo);
   if not Assigned(ba) then
      Exit; // can't do anything


   TransNode := FromNode.ChildNodes.FindNode(nTransactions);
   if not Assigned(TransNode) then
      Exit;

   Prefix := Copy(ba.baFields.baBank_Account_Number, 1, 2);
   for T := 0 to Transnode.ChildNodes.Count - 1 do
      MergeTransaction(Transnode.ChildNodes[T]);
end; //MergeAccount

procedure TWebNotesImportForm.MergeBatch(FromNode: IXMLNode);
 var lNode: IXMLNode;
     I: Integer;
     FN: String;
begin
   // This was part of a batch loop..
   if NeedConfig then begin
      FN := GetAvailableText(True);
      if GetEcodingImportOptions(Client, FN, ecDestWebX) then
         NeedConfig := False // once is enough
      else  begin
         Stop := True;
         Exit; // Canceled..
      end;
   end;
   // Now do the actual work..
   lNode := FromNode.ChildNodes.FindNode(nAccounts);
   if Assigned(lNode) then
      for I := 0 to lNode.ChildNodes.Count - 1 do
         MergeAccount(lNode.ChildNodes[I]);

end;

procedure TWebNotesImportForm.MyOnDateChange(Sender: TObject);
begin
   DateSelector.ValidateDates(True);
end;

procedure TWebNotesImportForm.SetFirstDate(const Value: tStDate);
begin
    if value < FFirstDate then
      FFirstDate := Value
end;

procedure TWebNotesImportForm.SetLastDate(const Value: tStDate);
begin
    if value > FLastDate then
       FLastDate := Value;
end;

function TWebNotesImportForm.GetAvailableText(Short: Boolean): string;
begin
   if LastDate > 0 then
      if short then
         Result := Format('Data from %s until %s', [bkDate2Str(FirstDate),bkDate2Str(LastDate)])
      else
         Result := Format('%s data available from %s until %s', [WebNotesName, bkDate2Str(FirstDate),bkDate2Str(LastDate)])
   else
      if short then
         result := 'No data available'
      else
         result := '';
end;

procedure TWebNotesImportForm.btnOKClick(Sender: TObject);
var I: Integer;
    msg: string;
    SaveClientCode: string;
begin
   if not DateSelector.ValidateDates(True) then
      Exit;

   // Reset...
   ImportedCount := 0;
   NewCount := 0;
   RejectedCount := 0;
   NeedConfig := True;
   Stop := False;

   //Save client for audit
   if Client.clFields.clCountry = whUK then
     Files.SaveAClient(Client);

   if DownLoadData then begin
     //Save client for audit
     if Client.clFields.clCountry = whUK then begin
       SaveClientCode := CurrUser.Code;
       try
         CurrUser.Code := 'Notes Online';
         Files.SaveAClient(Client);
       finally
         CurrUser.Code := SaveClientCode;
       end;
     end;
      // Build the message
      msg := 'Import Successful';
      if (ImportedCount = 0)
      and (NewCount = 0) then
         msg := msg + #13'No Transactions updated'
      else begin

         if ImportedCount > 0 then
            msg := msg + format(#13'Transaction(s) updated: %d',[ImportedCount]);
         if NewCount > 0 then
            msg := msg + format(#13'New transaction(s): %d',[NewCount]);
      end;

      if RejectedCount > 0 then
         msg := msg + format(#13'Rejected transaction(s): %d',[RejectedCount]);

      // log and Display
      HelpfulInfoMsg(msg, 0);
      LogUtil.LogMsg(lmInfo, UnitName, msg);

      //*** Flag Audit ***
      //Notes online import
      Msg := StringReplace(Msg, #13, VALUES_DELIMITER, [rfReplaceAll, rfIgnoreCase]);
      MyClient.ClientAuditMgr.FlagAudit(atBankLinkNotesOnline, 0, aaNone, Msg);
   end;

   if not GetAvailableData(False) then
      Modalresult := mrOK; // Im done..
end;

function TWebNotesImportForm.GetAvailableData(FirstTime: Boolean = true): boolean;
var WebClient: TWebNotesClient;
    Reply: string;
    kc: tCursor;
begin
   // reset some stuff...
   fFirstDate := maxint;
   fLastDate := 0;

   DateSelector.edateFrom.Enabled := False;
   DateSelector.edateFrom.AsStDate := 0;
   DateSelector.edateTo.Enabled := False;
   DateSelector.edateTo.AsStDate := 0;

   NeedConfig := true;

   // Get going...
   lAvailable.Caption := Format('Checking for %s transactions', [wfNames[wfWebNotes]]);
   UpdateAppStatus(lAvailable.Caption,'Initializing', 0);
   WebClient := TWebNotesClient.Create(GetBK5Ini);
   kc := Screen.Cursor;
   Screen.Cursor := crHourglass;
   try  try
      // Setup the basics..
      RefreshAdmin;
      WebClient.Country := CountryText(AdminSystem.fdFields.fdCountry);
      WebClient.PracticeCode := AdminSystem.fdFields.fdBankLink_Code;
      WebClient.PassWord := AdminSystem.fdFields.fdBankLink_Connect_Password;

      if WebClient.GetAvailableData (Client.clFields.clCode, Reply) then
         TestAvailableResponse(Reply);
   except
      on e: Exception do begin
         HandleWNException(e,unitname, Format('Checking for %s transactions', [wfNames[wfWebNotes]]));
         Exit;
      end;
   end;

   finally
      WebClient.Free;
      Result := fLastDate <> 0;
      Screen.Cursor := kc;
      ClearStatus;
   end;

   if Result then begin
      lAvailable.Caption := GetAvailableText(True);
      DateSelector.edateFrom.Enabled := true;
      DateSelector.edateFrom.AsStDate := FirstDate;
      DateSelector.edateTo.Enabled := true;
      DateSelector.edateTo.AsStDate := LastDate;
      DateSelector.Mindate := FirstDate;
      DateSelector.Mindate := LastDate;
   end else begin

      if FirstTime then
         Reply := ''
      else
         Reply := 'more ';

      lAvailable.Caption := Format('No %s%s transactions available', [Reply, wfNames[wfWebNotes] ]);
      HelpfulInfoMsg(Format('%s for:'#13'%s',[lAvailable.Caption, Client.clExtendedName ] ),0);
   end;

end;

procedure TWebNotesImportForm.FormCreate(Sender: TObject);
begin
    bkXPThemes.ThemeForm( Self);
    BKHelpSetUp(Self, BKH_Importing_a_BankLink_Notes_Online_file_into_BankLink_Practice);
    self.Caption := Format('Import from %s',[WebNotesName]);
    ImportedCount := 0;
    NewCount := 0;
    RejectedCount := 0;
    DateSelector.InitDateSelect(0,maxint,nil);
    //DateSelector.OnDateChange := MyOnDateChange;
end;



function TWebNotesImportForm.GetPayeeDetailsForNarration(Payee, line: Integer): string;
var
  lPayee: TPayee;
begin
  result := '';
  lPayee := Client.clPayee_List.Find_Payee_Number(Payee);
  if Assigned(lPayee) then
     result := LPayee.pdLines.PayeeLine_At(Line).plGL_Narration
  else begin
  end;
end;


function TWebNotesImportForm.TestDownloadResponse(Reply: string; var DownloadId: string): boolean;
var lNode,ReplyNode: IXMLNode;
    lXMLDoc: IXMLDocument;
    I: Integer;
begin
   Result := False;
   DownloadId := '';

   if DebugMe then
      LogUtil.LogMsg(lmDebug,UnitName,format('Download reply XML<%s>',[Reply] ));

   lXMLDoc := MakeXMLDoc(Reply);
   try
      ReplyNode := lXMLDoc.DocumentElement;

      if TestResponse(ReplyNode,'DownloadDataResponse') then begin

         LNode := ReplyNode.ChildNodes.FindNode('DownloadId');
         if Assigned(lNode) then
            DownloadId := lNode.NodeValue;

         LNode := ReplyNode.ChildNodes.FindNode(nItems);
         if not Assigned(lNode) then
            raise Exception.Create('No Data');
         // This is Realy only expected to be one...
         for I := 0 to pred(lnode.ChildNodes.Count) do begin
             MergeBatch(lnode.ChildNodes[I]);
         end;

         // Still Alive... but did I actualy do anything...
         Result := not(NeedConfig or Stop);
      end;

   finally
      lXMLDoc := nil;
   end;
end;



procedure TWebNotesImportForm.TestAvailableResponse(Reply: string);
var lNode,ReplyNode: IXMLNode;
    lXMLDoc: IXMLDocument;
    I: Integer;

    procedure CheckNode(Node: IXMLNode);
    var ldate: tstdate;
    begin
       if SameText(GetStringAttr(Node,ncompanycode),MyClient.clFields.clCode)
       and (GetIntAttr(Node,nCount) > 0) then begin
          ldate := GetDateAttr(Node,nFromDate);
          FirstDate := ldate;
          LastDate := ldate;
          ldate := GetDateAttr(Node,nToDate);
          FirstDate := ldate;
          LastDate := ldate;
       end;
    end;

begin

   if DebugMe then
         LogUtil.LogMsg(lmDebug,UnitName,format('AvailableData reply XML<%s>',[Reply] ));

   lXMLDoc := MakeXMLDoc(Reply);
   try
      ReplyNode := lXMLDoc.DocumentElement;
      if TestResponse(ReplyNode, nAvailableDataResponse) then begin

         LNode := ReplyNode.ChildNodes.FindNode(nItems);
         if not Assigned(lNode) then
            Exit;

         for I := 0 to pred(lnode.ChildNodes.Count) do begin
            CheckNode(lnode.ChildNodes[I]);
         end;

      end;

   finally
      lXMLDoc := nil;
   end;

end;

procedure TWebNotesImportForm.UpdateActions;
begin
   inherited;
   btnOK.Enabled := Dateselector.eDateFrom.AsStDate <> 0;
end;

function TWebNotesImportForm.WebnotesDissectionMatchesBK5Payee(
  FromNode: IXMLNode; bkPayee: TPayee): boolean;

var
  PayeeLine : bkdefs.pPayee_Line_Rec;
  DNode: IXMLNode;
  L: Integer;
begin
  Result := false;
  //same number of lines?
  if GetDissectionCount(FromNode) <> bkPayee.pdLines.ItemCount then
     Exit; // No show...

  L := 0;
  DNode := GetFirstDissection(FromNode);
  while Assigned(DNode) do begin
     PayeeLine := bkPayee.pdLines.PayeeLine_At(L);
     if PayeeLine.plAccount <> GetStringAttr(FromNode,nChartcode) then
        Exit;

     DNode := DNode.NextSibling;
     Inc(L);
  end;


  // Still Here...
  Result := true;
end;




function TWebNotesImportForm.DissectionsMatch(FromNode: IXMLNode; BKT: pTransaction_Rec): Boolean;
//returns true if the dissection lines match
//a match is determined by both transactions having the same no of dissect lines
//the account and amount must match for each of these lines
var
  D: pDissection_Rec;
  DNode: IXMLNode;
begin
  Result := false;
  //same number of lines, codes and amount match
  D := BKT.txFirst_Dissection;
  DNode := GetFirstDissection(FromNode);

  while ( D <> nil)
  and ( DNode <> nil) do
  begin
     if D^.dsAccount <> GetStringAttr(DNode,nChartCode) then
       exit;
     if D.dsAmount  <> GetMoneyAttr(DNode,nAmount) then
       exit;

     D := D.dsNext;
     DNode := DNode.NextSibling;
  end;

  if not ((DNode = nil) and (D = nil)) then
     exit;
  // Still Here...
  Result := true;
end;

function TWebNotesImportForm.DownLoadData: Boolean;
var
   WebClient: TWebNotesClient;
   Reply,
   DownloadId: string;
begin
    Result := false;

    UpdateAppStatus(Format('Downloading %s transactions', [wfNames[wfWebNotes]]),'Initializing', 0);
    WebClient := TWebNotesClient.Create(GetBK5Ini);


    try  try
      // Setup the basics..
      WebClient.Country := CountryText(AdminSystem.fdFields.fdCountry);
      WebClient.PracticeCode := AdminSystem.fdFields.fdBankLink_Code;
      WebClient.PassWord := AdminSystem.fdFields.fdBankLink_Connect_Password;
      // Do the action
      if CurrUser.FullName > '' then
         DownloadId := CurrUser.FullName
      else
         DownloadId := CurrUser.Code;

      WebClient.DownloadData (MyClient.clFields.clCode,
                              DownloadId,
                              DateSelector.eDateFrom.AsStDate,
                              DateSelector.eDateTo.AsStDate,  Reply);


      if TestDownLoadResponse(Reply,DownloadId) then begin// Does the complete merge as well
         Result := True; // I've got the data..

         // Now try to update the status at the webnots end..
         UpdateAppStatus(Format('Updating %s status', [wfNames[wfWebNotes]]),'Initializing', 0);
         try
             WebClient.SetDownloadStatus(DownloadId, nBatchComplete, Reply);
             // Could test the response, but not much I can do to fix a problem
         except
            // No point to do anything here...
         end;
      end;

   except
      on e: Exception do
         HandleWNException(e,UnitName,format('Downloading %s transactions', [wfNames[wfWebNotes]]));

   end;
   finally
      WebClient.Free;
      ClearStatus;
   end;
end;

function TWebNotesImportForm.ExportDissectionLinesToNotes( FromNode: IXMLNode;
                                          BKT: pTransaction_Rec): string;
//the dissection cannot be imported because of one of the following reasons:
//
//    1) The dissection lines in bnotes do not match the dissection in bk5
//    2) The bnotes transaction has been dissected, but the bk5 transaction has been coded normally

var
  ExtraNotes: TStringList;
  DNode: IXMLNode;
  NewLine: string;
  lMoney: Money;
  lPayee: Integer;
  BkPayee: TPayee;
begin
  AddToImportNotes(BKT, 'Dissection cannot be imported.  Details added to notes', WebNotesName);

  ExtraNotes := TStringList.Create;
  try
     ExtraNotes.Add( '');
     ExtraNotes.Add( 'Dissection Details');
     //add transaction level details
     lMoney := GetMoneyAttr(FromNode,nAmount);
     if (BKT.txAmount <> lMoney) then
        ExtraNotes.Add( 'Transaction Amount = ' + Money2Str(lMoney));

     lPayee := GetIntAttr(FromNode,nPayeeNumber);
     if lPayee <> 0 then begin
        BKPayee := Client.clPayee_List.Find_Payee_Number(lPayee);
        if Assigned(BKPayee) then
           ExtraNotes.Add( 'Transaction Payee = ' + BkPayee.pdName + ' (' +
                         inttostr( BkPayee.pdNumber) + ')')
        else
           ExtraNotes.Add( 'Transaction Payee =  unknown payee(' +
                         inttostr( lPayee) + ')');
     end else begin
        NewLine := GetStringAttr(FromNode,nPayeeNumber);
        if NewLine > '' then
            ExtraNotes.Add( 'Transaction Payee =  New payee(' +
                         NewLine + ')');
     end;

     //add details for each line
     DNode := GetFirstDissection(FromNode);
     while (DNode <> nil) do begin
        NewLine := '';

        NewLine := NewLine + 'Code = ' + GetStringAttr(DNode,nChartCode)
                 + '  Amt = ' + Money2Str(GetMoneyAttr(DNode,nAmount))
                 + '  GST = ' + Money2Str(GetMoneyAttr(DNode,nTaxAmount));

        lPayee := GetIntAttr(DNode,nPayeeNumber);
        if lPayee <> 0 then
        begin
           bkPayee := Client.clPayee_List.Find_Payee_Number(LPayee);
           if assigned(BkPayee) then
              NewLine := NewLine + '  Payee = ' + BkPayee.pdName + ' (' +
                                      inttostr(BkPayee.pdNumber) + ') ';
        end;
        lMoney := GetQtyAttr(DNode,nQuantity);
        if lMoney <> 0 then
           NewLine := NewLine + '  Qty = ' + FormatFloat('#,##0.####', lMoney/10000);

        Result := GetStringAttr(DNode, nNotes);
        if Trim(Result) <> '' then
           NewLine := NewLine + '  Notes = ' + GenUtils.StripReturnCharsFromString(Result, ' | ');

        Result := GetStringAttr(DNode, nJobCode);
        if Result <> '' then
          NewLine := NewLine + '  Job = ' + Result;

        ExtraNotes.Add(NewLine);
        DNode := DNode.NextSibling;
     end;

     Result := GetStringAttr(FromNode, nJobCode) + ExtraNotes.Text;
  finally
     ExtraNotes.Free;
  end;
end;


initialization
   DebugMe := DebugUnit(UnitName);
end.
