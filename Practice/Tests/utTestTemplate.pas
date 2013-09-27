// Template for creating new tests

unit utTestTemplate;
{$TYPEINFO ON} //Needed for classes with published methods

interface

uses
  TestFramework; // DUnit

type
  TUnitTestTemplate = class(TTestCase)
  private
  protected
    procedure SetUp; override;
  published
  end;

implementation

{ TUnitTestTemplate }

procedure TUnitTestTemplate.SetUp;
begin
  inherited;
  //
end;

initialization
  TestFramework.RegisterTest(TUnitTestTemplate.Suite);

end.
