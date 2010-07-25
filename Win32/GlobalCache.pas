unit GlobalCache;
//------------------------------------------------------------------------------
{
   Title:       Global Cache

   Description: Cache for global variables that change infrequently

   Author:      Matthew Hopkins

   Remarks:     Designed to store global variables, such as country, that don't
                change frequently.

                The idea is to reduce the need to link in the admin system
                when you just need to know what country the software is set up
                for

}
//------------------------------------------------------------------------------

interface

var
  cache_Country : byte;  //updated when admin system loaded
  cache_Current_Username : string;

implementation


initialization
  cache_Country := 0;
  cache_Current_Username := '';

end.
