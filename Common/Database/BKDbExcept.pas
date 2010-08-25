unit BKDbExcept;
//------------------------------------------------------------------------------
{
   Title:        BankLink Database Exceptions

   Description:  Contains exceptions used by banklink tokenised database.

   Remarks:

   Author:       Matthew Hopkins Jul 2001

}
//------------------------------------------------------------------------------
interface uses SysUtils;
// -----------------------------------------------------------------------------

type
  EBankLinkDBException = class (Exception);

   // --------------------------------------------------------------------------

  EInvalidDataInFile   = class( EBankLinkDBException);
     EBoundsException     = class( EInvalidDataInFile);
     ETokenException      = class( EInvalidDataInFile);
     EOpCodeException     = class( EInvalidDataInFile);

  ECorruptDataInFile   = class( EBankLinkDBException);
  EInsufficientMemory  = class( EBankLinkDBException);
  ECorruptData         = class( EBankLinkDBException);

//******************************************************************************
implementation

end.
