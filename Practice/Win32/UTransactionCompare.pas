unit UTransactionCompare;

{Performs transaction and dissection compare}
{Inherit from the TTransactionCompare and TDissectionCompare}

interface

uses
  Contnrs, BKDEFS, MoneyDef;
  
type
  TDissectionCompare = class
  public
    procedure Populate(Dissection: pDissection_Rec); virtual; abstract;
    function IsEqual(Dissection: pDissection_Rec): Boolean; virtual; abstract;
  end;

  TDissectionCompareClass = class of TDissectionCompare;
  
  TTransactionCompare = class
  private
    FDissections: TObjectList;
  protected
    procedure PopulateDissectionCompare(FirstDissection: pDissection_Rec; DissectionCompareClass: TDissectionCompareClass);
    procedure Populate(Transaction: pTransaction_Rec); virtual;

    function CompareDissections(FirstDissection: pDissection_Rec): Boolean;
    function CompareSelf(Transaction: pTransaction_Rec): Boolean; virtual;
    
    function GetDissectionCompareClass: TDissectionCompareClass; virtual; abstract;
  public
    constructor Create(Transaction: pTransaction_Rec);
    destructor Destroy; override;

    function IsEqual(Transaction: pTransaction_Rec): Boolean;  virtual;
  end;

  TDataExportDissectionCompare = class(TDissectionCompare)
  private
    FReference: String;
    FAccount: String;
    FAmount: Money;
    FNarration: String;
    FPayee: Integer;
    FJob: String;
    FGSTClass: Byte;
    FGSTAmount: Money;
    FQuantity: Double;
    FTaxInvoice: Boolean;
    FRate: Double;
  public
    procedure Populate(Dissection: pDissection_Rec); override;
    function IsEqual(Dissection: pDissection_Rec): boolean; override;
  end;

  TDataExportTransactionCompare = class(TTransactionCompare)
  private
    FEffectiveDate: Integer;
    FReference: String;
    FAccount: String;
    FAmount: Money;
    FNarration: String;
    FPayee: Integer;
    FJob: String;
    FGSTClass: Byte;
    FGSTAmount: Money;
    FQuantity: Double;
    FEntryType: Byte;
    FTaxInvoice: Boolean;
    FRate: Double;
  protected       
    procedure Populate(Transaction: pTransaction_Rec); override;
    
    function CompareSelf(Transaction: pTransaction_Rec): Boolean; override;
    
    function GetDissectionCompareClass: TDissectionCompareClass; override;
  end;
  
implementation

function TDataExportTransactionCompare.CompareSelf(Transaction: pTransaction_Rec): Boolean;
begin
  Result :=
    (FEffectiveDate = Transaction.txDate_Effective) and
    (FReference = Transaction.txReference) and
    (FAccount = Transaction.txAccount) and
    (FAmount = Transaction.txAmount) and
    (FNarration = Transaction.txGL_Narration) and
    (FPayee = Transaction.txPayee_Number) and
    (FJob = Transaction.txJob_Code) and
    (FGSTClass = Transaction.txGST_Class) and
    (FGSTAmount = Transaction.txGST_Amount) and
    (FQuantity = Transaction.txQuantity) and
    (FEntryType = Transaction.txType) and
    (FTaxInvoice = Transaction.txTax_Invoice_Available) and
    (FRate = Transaction.txForex_Conversion_Rate);
end;

function TDataExportTransactionCompare.GetDissectionCompareClass: TDissectionCompareClass;
begin
  Result := TDataExportDissectionCompare;
end;

procedure TDataExportTransactionCompare.Populate(Transaction: pTransaction_Rec);
begin
  FEffectiveDate := Transaction.txDate_Effective;
  FReference := Transaction.txReference;
  FAccount := Transaction.txAccount;
  FAmount := Transaction.txAmount;
  FNarration := Transaction.txGL_Narration;
  FPayee := Transaction.txPayee_Number;
  FJob := Transaction.txJob_Code;
  FGSTClass := Transaction.txGST_Class;
  FGSTAmount := Transaction.txGST_Amount;
  FQuantity := Transaction.txQuantity;
  FEntryType := Transaction.txType;
  FTaxInvoice := Transaction.txTax_Invoice_Available;
  FRate := Transaction.txForex_Conversion_Rate;

  inherited;
end;

{ TTransactionCompare }

function TTransactionCompare.CompareDissections(FirstDissection: pDissection_Rec): Boolean;
var
  Index: Integer;
  Dissection: pDissection_Rec;
  Count: Integer;
  DissectionCompare: TDissectionCompare;
begin
  Result := False;
    
  Dissection := FirstDissection;

  Index := 0;

  Count := 0;

  while Dissection <> nil do
  begin
    if Index < FDissections.Count then
    begin
      DissectionCompare := TDissectionCompare(FDissections[Index]);
        
      if not DissectionCompare.IsEqual(Dissection) then
      begin
        Result := True;

        Exit;
      end;

      Dissection := Dissection.dsNext;

      Inc(Index);

      Inc(Count);
    end
    else
    begin
      Result := True;

      Exit;
    end;
  end;

  if (not Result) and (Count <> FDissections.Count) then
  begin
    Result := True;
  end;
end;

function TTransactionCompare.CompareSelf(Transaction: pTransaction_Rec): Boolean;
begin
  Result := False;
end;

constructor TTransactionCompare.Create(Transaction: pTransaction_Rec);
begin
  FDissections := TObjectList.Create(True);

  Populate(Transaction);
end;

destructor TTransactionCompare.Destroy;
begin
  FDissections.Free;
  
  inherited;
end;

function TTransactionCompare.IsEqual(Transaction: pTransaction_Rec): Boolean;
begin
  if CompareSelf(Transaction) then
  begin
    Result := CompareDissections(Transaction.txFirst_Dissection);
  end
  else
  begin
    Result := False;
  end;
end;

procedure TTransactionCompare.Populate(Transaction: pTransaction_Rec);
begin
  PopulateDissectionCompare(Transaction.txFirst_Dissection, GetDissectionCompareClass);
end;

procedure TTransactionCompare.PopulateDissectionCompare(FirstDissection: pDissection_Rec; DissectionCompareClass: TDissectionCompareClass);
var
  DissectionCompare: TDissectionCompare;
  Dissection: pDissection_Rec;
begin
  Dissection := FirstDissection;
    
  while Dissection <> nil do
  begin
    DissectionCompare := DissectionCompareClass.Create;

    try
      DissectionCompare.Populate(Dissection);

      FDissections.Add(DissectionCompare);
    except
      DissectionCompare.Free;

      raise;
    end;

    Dissection := Dissection.dsNext;
  end;
end;

{ TDataExportDissectionCompare }

function TDataExportDissectionCompare.IsEqual(Dissection: pDissection_Rec): boolean;
begin
  Result :=
    (FReference = Dissection.dsReference) and
    (FAccount = Dissection.dsAccount) and
    (FAmount = Dissection.dsAmount) and
    (FNarration = Dissection.dsGL_Narration) and
    (FPayee = Dissection.dsPayee_Number) and
    (FJob = Dissection.dsJob_Code) and
    (FGSTClass = Dissection.dsGST_Class) and
    (FGSTAmount = Dissection.dsGST_Amount) and
    (FQuantity = Dissection.dsQuantity) and
    (FTaxInvoice = Dissection.dsTax_Invoice) and
    (FRate = Dissection.dsForex_Conversion_Rate);
end;

procedure TDataExportDissectionCompare.Populate(Dissection: pDissection_Rec);
begin
  FReference := Dissection.dsReference;
  FAccount := Dissection.dsAccount;
  FAmount := Dissection.dsAmount;
  FNarration := Dissection.dsGL_Narration;
  FPayee := Dissection.dsPayee_Number;
  FJob := Dissection.dsJob_Code;
  FGSTClass := Dissection.dsGST_Class;
  FGSTAmount := Dissection.dsGST_Amount;
  FQuantity := Dissection.dsQuantity;
  FTaxInvoice := Dissection.dsTax_Invoice;
  FRate := Dissection.dsForex_Conversion_Rate;
end;

end.
