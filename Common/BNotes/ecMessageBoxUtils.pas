unit ecMessageBoxUtils;
//------------------------------------------------------------------------------
{
   Title:       ECMessage Box Utils

   Description: Contains InfoMessage, ErrorMsg and Warning message calls

   Remarks:

   Author:

}
//------------------------------------------------------------------------------
                    
interface

   procedure InfoMessage( aMsg : string);
   procedure WarningMessage( aMsg : string);
   procedure ErrorMessage( aMsg : string);

//******************************************************************************
implementation
uses
   Forms,
   Windows,
   ecGlobalConst;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure InfoMessage( aMsg : string);
begin
   Application.MessageBox( PChar( aMsg), APP_NAME, MB_ICONINFORMATION);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure WarningMessage( aMsg : string);
begin
   Application.MessageBox( PChar( aMsg), APP_NAME, MB_ICONWARNING);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ErrorMessage( aMsg : string);
begin
   Application.MessageBox( PChar( aMsg), APP_NAME, MB_ICONERROR);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
