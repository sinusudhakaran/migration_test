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
  Function RegExIsAlphaNumeric(aString : String; AllowUnderscore : boolean): Boolean;

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
  PerlRegEx.RegEx := '^[\w-]+(\.[\w-]+)*@([A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*?\.[A-Za-z]{2,6}|(\d{1,3}\.){3}\d{1,3})(:\d{4})?$';
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

function RegExIsAlphaNumeric(aString : String; AllowUnderscore : boolean): Boolean;
begin
  { Checks that the string is not blank and only contains alphanumeric characters.
    Underscores are a bit iffy so I've put in an option for them }
  if AllowUnderscore then
    PerlRegEx.RegEx := '^[a-zA-Z0-9_]+$'
  else
    PerlRegEx.RegEx := '^[a-zA-Z0-9]+$';
  PerlRegEx.Subject := aString;
    
  Result := PerlRegEx.Match;
end;

//------------------------------------------------------------------------------
initialization
  fPerlRegEx := nil;

//------------------------------------------------------------------------------
finalization
  FreeAndNil(fPerlRegEx);


end.
