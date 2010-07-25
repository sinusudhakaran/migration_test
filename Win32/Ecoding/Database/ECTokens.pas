UNIT ECTOKENS;
//------------------------------------------------------------------------------
{
   Title:       ECTokens

   Description: Additional tokens required by ecoding for tokenised file system

   Remarks:     The basic Start/End tokens should really be part of a seperate
                unit which is not application specific.

                Application specific tokens should really be written as part of
                DBGEN.

   Author:      Matthew Hopkins Jul 2001
}
//------------------------------------------------------------------------------


INTERFACE

CONST
   //generic tokenised file system tokens
   tkStartOfFile              = 0;
   tkStartRecord              = 1;

   tkEndRecord                = 253;
   tkEndSection               = 254;
   tkEndOfFile                = 255;

   //application specific tokens
   tkBeginEntries             = 2;
   tkBeginDissections         = 3;
   tkBeginChart               = 4;
   tkBeginPayees              = 5;
   tkBeginBankAccountList     = 6;
   tkBeginPayeesList          = 7;
   tkBeginPayeeLinesList      = 8;
   tkBeginJobsList            = 9;

//******************************************************************************
IMPLEMENTATION
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.

