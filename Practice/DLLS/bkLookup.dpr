library bkLookup;

//------------------------------------------------------------------------------
{
   Title:       bkLookup.DLL

   Description: A DLL to provide access to the list of BK5 client codes

   Author:      Matthew Hopkins Oct 2004

   Remarks:     Initially written to provide APS to display a picklist of
                BankLink client codes so that the Advance Practice Management
                module can associate a BK5 code with a PA ledger

                The information can be retrieve two ways

                1) Can return a tab delimited list of codes and names
                2) Can show a modal dialog and allow the user to choose a code

                Note: The Conditional compile  "LOOKUPDLL" must be included
                      otherwise most of BK5 will be linked in during compile.

                The following methods are available:


                GetBKClientList              //retrieves a list of bk5 codes

                GetBKClientListBufferLen     //retrieves the length of the codes string so can
                                             //allocate memory for the pchar

                LookupBKClientCode           //show a modal lookup dialog

                SetBKAdminLocation           //tell the locking system where the system.db
                                             //and system.lck files are


                Note:
                No logging is performs, a stub exists in errorlog.pas so that
                we didnt need to change every LogMsg call.

   Revisions:

}
//------------------------------------------------------------------------------


uses
  SysUtils,
  Classes,
  DelimitedClientList,
  ExternalClientLookupFrm,
  Admin32;

{$R *.res}

exports
  GetBKClientList,
  GetBKClientListBufferLen,
  LookupBKClientCode,
  SetBKAdminLocation;
end.
