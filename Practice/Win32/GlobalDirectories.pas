unit GlobalDirectories;
//------------------------------------------------------------------------------
{
   Title:       Global Directories

   Description:

   Remarks:     This will take over from the directories stored in globals.
                I have introduced this now so that the ECodingInterface doesn't
                need to access globals

   Author:      Matthew Hopkins  Aug 2001

}
//------------------------------------------------------------------------------

interface
var
   glDataDir  : string;
   glExecDir  : string;

implementation

initialization
   glDataDir := '';
   glExecDir := '';
end.
