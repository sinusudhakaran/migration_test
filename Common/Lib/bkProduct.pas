unit bkProduct;

interface

uses
  StrUtils;
  
type
  TBrandType = (btBankLink, btBankstream);

  TProduct = class
  private
    class var FProductBrand: TBrandType;
  public
    class function BrandName: String; static;

    class function Rebrand(Value: String): String; static;

    class property ProductBrand: TBrandType read FProductBrand write FProductBrand;
  end;

  
implementation

{ TProduct }

class function TProduct.BrandName: String;
begin
  if FProductBrand = btBankstream then
  begin
    Result := 'Bankstream';
  end
  else
  begin
    Result := 'MYOB BankLink';
  end;
end;

class function TProduct.Rebrand(Value: String): String;
begin
  { Note:
    This has been disabled as it was conflicting with the previous way of branding
    Result := AnsiReplaceText(Value, 'BankLink', BrandName);
  }
  result := Value;
end;

initialization
  TProduct.ProductBrand := btBankLink;

end.
