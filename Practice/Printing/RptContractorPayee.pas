unit RptContractorPayee;

interface

uses
   ReportDefs, UBatchBase;

procedure DoTaxablePaymentsReport(Destination : TReportDest; RptBatch :TReportBase = nil);

implementation

uses
  ReportTypes,
  Classes,
  SysUtils,
  NewReportObj,
  RepCols,
  Globals,
  bkDefs,
  baObj32,
  GenUtils,
  NewReportUtils,
  bkDateUtils,
  PayeeLookupFrm,
  TaxablePaymentsRptDlg, MoneyDef,
  RptParams,
  PayeeObj, clObj32, balist32, trxList32, bkbaio, bktxio, bkdsio, stdate, bkconst;

type
  TTaxablePaymentsReport = class(TBKReport)
  private
    Bank_Account : TBank_Account;
    Transaction  : pTransaction_Rec;
    Payee        : TPayee;
    Dissection   : pDissection_Rec;
    Account      : pAccount_Rec;
  public
    params : TPayeeParameters;

    function ShowPayeeOnReport( aPayeeNo : integer) : boolean;
  end;

procedure GenerateDetailedTaxablePaymentsReport(Dest: TReportDest; Job: TTaxablePaymentsReport);
begin

end;

procedure GenerateSummaryTaxablePaymentsReport(Dest: TReportDest; Job: TTaxablePaymentsReport);
begin

end;

procedure DoTaxablePaymentsReport(Destination : TReportDest; RptBatch: TReportBase = nil);
var
   Job   : TTaxablePaymentsReport;
   Params : TPayeeParameters;
   ISOCodes: string;
begin
 //set defaults

  Params := TPayeeParameters.Create(ord(Report_Taxable_Payments), MyClient,Rptbatch,DYear);

  with params do
  begin
    try
      Params.FromDate := 0;
      Params.ToDate := 0;

      repeat
        if not GetPRParameters(Params) then
        begin
          Exit;
        end;

        if RunBtn = BTN_SAVE then
        begin
          SaveNodeSettings;
          Exit;
        end;

        {if (Destination = rdNone)
        or Batchsetup then}
        case RunBtn of
          BTN_PRINT   : Destination := rdPrinter;
          BTN_PREVIEW : Destination := rdScreen;
          BTN_FILE    : Destination := rdFile;
          else
            Destination := rdAsk;
        end;

        //Check Forex - this won't stop the report running if there are missing exchange rates
        MyClient.HasExchangeRates(ISOCodes, params.FromDate, params.ToDate, True, True);

        Job := TTaxablePaymentsReport.Create(rptOther);;
        try
          //set parameters
          Job.Params := Params;

          if SummaryReport then
          begin
            GenerateSummaryTaxablePaymentsReport(Destination, Job);
          end
          else
          begin
            GenerateDetailedTaxablePaymentsReport(Destination, Job);
          end;
        finally
          Job.Free;
        end;

        //Destination := rdNone;
      until Params.RunExit(Destination);
    finally
      Params.Free;
    end;
  end;
end;
{ TTaxablePaymentsReport }

function TTaxablePaymentsReport.ShowPayeeOnReport(aPayeeNo: integer): boolean;
begin

end;

end.
