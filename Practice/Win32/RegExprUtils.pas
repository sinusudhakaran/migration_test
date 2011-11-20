unit RegExprUtils;
//------------------------------------------------------------------------------
{
   Title: RegExprUtil

   Description:

        Creates an singleton of the TPerlRegEx class and has a few common
        Regular Expression functions.

   Author: Ralph Austen

   Remarks:
}
//------------------------------------------------------------------------------
interface

uses
  PerlRegEx;

  Function PerlRegEx : TPerlRegEx;
  Function RegExIsEmailValid(aEmail : String) : Boolean;
  Function RegExIsPasswordValid(aPassword : String) : Boolean;

//------------------------------------------------------------------------------
implementation

uses
  SysUtils;

var
  fPerlRegEx : TPerlRegEx;

//------------------------------------------------------------------------------
function PerlRegEx : TPerlRegEx;
begin
  if not Assigned( fPerlRegEx) then
  begin
    fPerlRegEx := TPerlRegEx.Create;
  end;

  result := fPerlRegEx;
end;

//------------------------------------------------------------------------------
function RegExIsEmailValid(aEmail : String) : Boolean;
begin
  PerlRegEx.RegEx := '^[\w-]+(\.[\w-]+)*@([a-z0-9-]+(\.[a-z0-9-]+)*?\.[a-z]{2,6}|(\d{1,3}\.){3}\d{1,3})(:\d{4})?$';
  PerlRegEx.Subject := aEmail;

  Result := PerlRegEx.Match;
end;

//------------------------------------------------------------------------------
function RegExIsPasswordValid(aPassword : String) : Boolean;
begin
  // Must be atleast 8 characters long and have one number in it.
  PerlRegEx.RegEx := '^.*(?=.{8,})(?=.*\d)(?=.*[A-Za-z]).*$';
  PerlRegEx.Subject := aPassword;

  Result := PerlRegEx.Match;
end;

//------------------------------------------------------------------------------
initialization
  fPerlRegEx := nil;

//------------------------------------------------------------------------------
finalization
  FreeAndNil(fPerlRegEx);


end.
