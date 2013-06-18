unit bkTemplates;

interface

uses
  bkProduct;
  
type
  TTemplates = class
  private
    class function GetUKCafTemplate(Index: Integer): String; static;
  public
    class property UKCafTemplates[Index: Integer]: String read GetUKCafTemplate;
  end;

implementation

uses
  bkBranding, bkConst, Globals;

const
  istBankstreamUKTemplateFileNames : Array[ istMin..istMax ] of String =
    ( '', 'UK_CAF_Template.pdf', 'UK_HSBC_Template.pdf' );


{ TTemplates }

class function TTemplates.GetUKCafTemplate(Index: Integer): String;
begin
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := istBankstreamUKTemplateFileNames[Index];
  end
  else
  begin
    Result := istUKTemplateFileNames[Index];
  end;
end;

end.
