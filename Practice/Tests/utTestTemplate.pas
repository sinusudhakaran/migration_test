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
  published
  end;

implementation

initialization
  TestFramework.RegisterTest(TUnitTestTemplate.Suite);

end.
