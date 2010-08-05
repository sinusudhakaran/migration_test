unit ecGlobalTypes;
//------------------------------------------------------------------------------
{
   Title:       Global Types

   Description: Global Type definitions

   Remarks:     Used to hold type definitions for some global types and reduce
                coupling between units.

   Author:      Matthew Hopkins

}
//------------------------------------------------------------------------------

interface

type
   TLogEvent = procedure ( const Sender : TObject; const sLogMsg : String) of object;

implementation

end.
