Unit MCDEFS;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
Interface uses MONEYDEF, DATEDEF;
{  -------------------------------------------------------------------  }

Const
   MC_IOLIB_Version : Integer = 111;
   MC_IOLIB_Date    = '02/08/10';
   MC_FILE_VERSION  = 100;  (* Current Version counter for files
                              Changes if structure or method of storing a value would cause
                              data to be represented incorrectly, or an exception to be raised *)
   
   
   (*
       2010 UK          : 100     Introduction
   
   *)

{  -------------------------------------------------------------------  }

Type
   pExchange_Rates_Header_Rec            = ^tExchange_Rates_Header_Rec ;
   pExchange_Rate_Rec                    = ^tExchange_Rate_Rec ;

{  -------------------------------------------------------------------  }

   tExchange_Rates_Header_Rec = Packed Record
      ehRecord_Type                      : Byte;
      ehFile_Version                     : Integer;       { Stored }
      ehLRN                              : Integer;       { Stored }
      ehName                             : String[ 200 ];       { Stored }
      ehList_Type                        : Byte;       { Stored }
      ehISO_Codes                        : Array[ 1..99 ] of String[ 3 ];       { Stored }
      ehCur_Type                         : Array[ 1..99 ] of Byte;       { Stored }
      ehEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tExchange_Rate_Rec = Packed Record
      erRecord_Type                      : Byte;
      erApplies_Until                    : Integer;       { Stored }
      erRate                             : Array[ 1..99 ] of Double;       { Stored }
      erLocked                           : Boolean;       { Stored }
      erEOR                              : Byte;
   end;

Const
   Exchange_Rates_Header_Rec_Size            = Sizeof( TExchange_Rates_Header_Rec ); 
   Exchange_Rate_Rec_Size                    = Sizeof( TExchange_Rate_Rec ); 

{  -------------------------------------------------------------------  }
Implementation
{  -------------------------------------------------------------------  }

end.
