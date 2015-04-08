unit SuggestedMems;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  Classes;

type
  TSuggestedMems = class(TObject)
  private
  protected
  public
  end;

  //----------------------------------------------------------------------------
  function CallSuggestedMems(): TSuggestedMems;

//------------------------------------------------------------------------------
implementation

uses
  LogUtil;

const
  UnitName = 'SuggestedMems';

var
  fSuggestedMems: TSuggestedMems;
  DebugMe : boolean = false;

//------------------------------------------------------------------------------
function CallSuggestedMems(): TSuggestedMems;
begin
  if not assigned(fSuggestedMems) then
  begin
    fSuggestedMems := TSuggestedMems.Create;
  end;

  result := fSuggestedMems;
end;

//------------------------------------------------------------------------------
initialization
begin
  DebugMe := DebugUnit(UnitName);
  fSuggestedMems := nil;
end;

//------------------------------------------------------------------------------
finalization
begin
  FreeAndNil(fSuggestedMems);
end;

end.
