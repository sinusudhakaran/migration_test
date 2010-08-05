unit ecGlobalVars;
//------------------------------------------------------------------------------
{
   Title:       ecGlobalVars

   Description: Global variables for the ecoding application

   Remarks:

   Author:      Matthew Hopkins  Jul 2001

}
//------------------------------------------------------------------------------

interface
uses
   ecObj;

var
   MyFile : TEcClient;
   ApplicationMustShutdownForUpdate: Boolean = false;

//******************************************************************************
implementation

initialization
   MyFile := nil;

finalization
   MyFile.Free;
end.
