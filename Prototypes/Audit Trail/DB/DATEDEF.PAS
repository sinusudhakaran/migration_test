Unit DATEDEF;
//------------------------------------------------------------------------------
{
   Title:       Date Definitions

   Description:

   Author:

   Remarks:

}
//------------------------------------------------------------------------------
INTERFACE
USES
   stDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

TYPE
   BK5Date = TStDate;

   tPeriod_End_Dates = Array[ 0..12 ] of BK5Date;

   TPeriod_Detail = record   //period details that will be stored in a dynamic array
      Period_Start_Date : integer;
      Period_End_Date   : integer;
      HasData           : boolean;
      HasUncodedEntries : boolean;
   end;

   TPeriod_Details_Array = Array of TPeriod_Detail;

//******************************************************************************
IMPLEMENTATION

END.

