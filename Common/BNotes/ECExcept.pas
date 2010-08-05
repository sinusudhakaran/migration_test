unit ECExcept;
//------------------------------------------------------------------------------
{
   Title:       ECoding Exceptions

   Description: Holds all the application specific exceptions

   Remarks:

   Author:      Matthew Hopkins Jul 2001

}
//------------------------------------------------------------------------------

interface
uses
   SysUtils;

type
  EECodingException = class (Exception);

  ECompressionFailure = class( EECodingException);
  EWrapperError       = class( EECodingException);
  EIncorrectVersion   = class( EECodingException);
  EFileCRCFailure     = class( EECodingException);

  EInvalidCall        = class( EEcodingException);

  EIntegrityFailure   = class( EECodingException);

implementation

end.
 