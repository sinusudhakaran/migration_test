unit Bk5Except;
// Declare the Exception types used in BK5Win
interface

uses
   SysUtils;

type
   {   shifted to bkdbexcept
      //EInsufficientMemory  = class(Exception);  //Raised when Create or Memory Allocation fails
      //ECorruptData         = class(Exception);  //Raised when operating on Memory Objects
      //EInvalidDataInFile   = class(Exception);  //Raised during File Read
   }

   ENoMemoryLeft        = class(Exception);  //raised when no memory available in non-db units
   EDataIntegrity       = class(Exception);  //raised when integrity of data is compromised

   EBKFileError         = class(Exception);

   EFileCRCFailure      = class(EBKFileError);
   EDeleteFailure       = class(EBKFileError);
   EFileAccess          = class(EBKFileError);
   EFileWrapper         = class(EBKFileError);
   ECompressionFailure  = class(EBKFileError);

   EInvalidCall         = class(Exception);  //Raised by any call to Illegal function
   EExtractData         = class(Exception);  //Raised by when extracting data to accounting systems
   EAdminSystem         = class(Exception);  //Raised when find objects in admin system
   EIncorrectVersion    = class(Exception);  //Raised when file cannot be loaded by this version of app

   EDownloadVerify      = class(Exception);  //Raised when there is a problem data on the download disk, before import begins
   EDownload            = class(Exception);  //Raised when downloading the data into the admin system

   ECheckIn             = class(Exception);  //Raise when errors occur checking in a file

   ERefreshFailed       = class(Exception);  //Raised if a problem occurs during the refresh chart process.
   EResyncFailed        = class(Exception);  //Raised if there is a problem resyncronising a foreign or offsite client
   EResyncVerifyFailed  = class(Exception);  //Raised if cannot verify client file prior to resync
   EResyncAbandoned     = class(Exception);  //Raise is user abandons resync

   EMailMapiError       = class(Exception);  //Raised if MAPI error occurs during email
   EMailConnectFailed   = class(Exception);  //Raised if cannot connect to mail server/mapi client
   EMailSendFailed      = class(Exception);  //Raised if send mail failed
   EMailDisconnectFailed= class(Exception);  //Raised if disconnect failed from mail server/mapi client

   EInterfaceError      = class(Exception);  //raise if chart refresh or extract failed
   ERefreshAbandoned = class( EInterfaceError); //tell the error handler that the user abandoned the refresh

implementation

end.
 