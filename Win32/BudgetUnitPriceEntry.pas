unit BudgetUnitPriceEntry;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ovcbase, ovcef, ovcpb, ovcnf, MoneyDef, OSFont;

type
  TfrmBudgetUnitPriceEntry = class(TForm)
    btnCancel: TButton;
    btnOk: TButton;
    lblUnitPrice: TLabel;
    lblQuantity: TLabel;
    lblTotal: TLabel;
    nUnitPrice: TOvcNumericField;
    nQuantity: TOvcNumericField;
    nTotal: TOvcNumericField;
    procedure nUnitPriceChange(Sender: TObject);
    procedure nQuantityChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    procedure UpdateTotal;
    function GetUnitPrice: Money;
    procedure SetUnitPrice(const Value: Money);
    function GetQuantity: Money;
    procedure SetQuantity(const Value: Money);
    function GetTotal: Integer;
    function IsTotalTooBig: Boolean;
    function HasNegativeValues: Boolean;
  public
    property Quantity: Money read GetQuantity write SetQuantity;
    property UnitPrice: Money read GetUnitPrice write SetUnitPrice;
    property Total: Integer read GetTotal;
    class function CalculateTotal(aUnitPrice, aQuantity: Money): Integer;
  end;

  function GetUnitPriceEntry(Owner: TCustomForm; var UnitPrice: Money; var Quantity: Money; var Total: Integer): boolean;

implementation

uses Math, bkXPThemes, ErrorMoreFrm;

{$R *.dfm}

{ TfrmBudgetUnitPriceEntry }

procedure TfrmBudgetUnitPriceEntry.btnOkClick(Sender: TObject);
begin
  if IsTotalTooBig then
    HelpfulErrorMsg('Total is too large. The Unit Price or Quantity needs to be updated', 0)
  else if HasNegativeValues then
    HelpfulErrorMsg('Quantity and Unit Price must be positive values', 0)
  else
    ModalResult := mrOk;
end;

class function TfrmBudgetUnitPriceEntry.CalculateTotal(aUnitPrice,
  aQuantity: Money): Integer;
var
  TempTotal: Money;
begin
  TempTotal := (aUnitPrice * aQuantity) / (10000 * 10000);
  TempTotal := Math.Min(1000000000, TempTotal); //max is 1 Billion
  Result := Trunc(RoundTo(TempTotal,0));
end;

procedure TfrmBudgetUnitPriceEntry.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
end;

procedure TfrmBudgetUnitPriceEntry.FormShow(Sender: TObject);
begin
  UpdateTotal;
end;

function TfrmBudgetUnitPriceEntry.GetQuantity: Money;
begin
  Result := nQuantity.AsExtended * 10000;
end;

function TfrmBudgetUnitPriceEntry.GetTotal: Integer;
begin
  Result := CalculateTotal(UnitPrice, Quantity);
end;

function TfrmBudgetUnitPriceEntry.IsTotalTooBig: Boolean;
var
  TempTotal: Money;
begin
  TempTotal := (Quantity * UnitPrice) / (10000 * 10000);
  Result := TempTotal > 1000000000;
end;

function TfrmBudgetUnitPriceEntry.GetUnitPrice: Money;
begin
  Result := nUnitPrice.AsExtended * 10000;
end;

function TfrmBudgetUnitPriceEntry.HasNegativeValues: Boolean;
begin
  Result := (Quantity < 0) or (UnitPrice < 0);
end;

procedure TfrmBudgetUnitPriceEntry.nQuantityChange(Sender: TObject);
begin
  UpdateTotal;
end;

procedure TfrmBudgetUnitPriceEntry.nUnitPriceChange(Sender: TObject);
begin
  UpdateTotal;
end;

procedure TfrmBudgetUnitPriceEntry.SetQuantity(const Value: Money);
begin
  nQuantity.AsExtended := Value / 10000;
end;

procedure TfrmBudgetUnitPriceEntry.SetUnitPrice(const Value: Money);
begin
  nUnitPrice.AsExtended := Value / 10000;
end;

procedure TfrmBudgetUnitPriceEntry.UpdateTotal;
begin
  nTotal.AsInteger := Total;  
end;

function GetUnitPriceEntry(Owner: TCustomForm; var UnitPrice: Money; var Quantity: Money; var Total: Integer): boolean;
var
  UnitPriceEntry: TfrmBudgetUnitPriceEntry;
begin
  UnitPriceEntry := TfrmBudgetUnitPriceEntry.Create(Owner);
  try
    UnitPriceEntry.PopupParent := Owner;
    UnitPriceEntry.UnitPrice := UnitPrice;
    if Quantity > 1 then    
      UnitPriceEntry.Quantity := Quantity
    else
      UnitPriceEntry.Quantity := 1;
    if UnitPriceEntry.ShowModal = mrOk then
    begin
      UnitPrice := UnitPriceEntry.UnitPrice;
      Quantity := UnitPriceEntry.Quantity;    
      Total := UnitPriceEntry.Total;
      Result := true;
    end
    else
      Result := false;
  finally
    UnitPriceEntry.Free;
  end;
end;

end.
