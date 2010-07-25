unit XPAUtils;
//------------------------------------------------------------------------------
{
   Title:        Professional Accounting XPA utilities

   Description:  Provides a set of utilities that do not link many other units

   Author:       Matthew Hopkins Sep 2003

   Remarks:

   Revisions:

}
//------------------------------------------------------------------------------

interface

const
  bkXPA_COM_Refresh_Supported_User_Cancelled = 0;
  bkXPA_COM_Refresh_Supported_User_Selected_Ledger = 1;
  bkXPA_COM_Refresh_NotSupported = 255;

function GetXPALedgerPath( var LedgerPath : string) : integer;

implementation
uses
  ComObj, Variants;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function GetXPALedgerPath( var LedgerPath : string) : integer;
//returns 0 if supported but not selected
//        1 if user selected ledger and clicked ok
//        255 if interface not supported
//Ledger path param will only be changed if user selected OK
var
  PALgr : OleVariant;
begin
  result := bkXPA_COM_Refresh_NotSupported;
  //test to see if PA chart dll exists
  try
    PALgr := CreateOLEObject('aPALedger.advLedger');
  except
    //invalid class string
    PALgr := UnAssigned;
  end;

  if not (VarIsEmpty(PALgr)) then
  begin
    result := bkXPA_COM_Refresh_Supported_User_Cancelled;  //COM interface was available
    try
      //if this is an XPA client then change use dll to find path
      if PALgr.Connect( '') then
      begin
        LedgerPath := PALgr.ConnectedDB;
        result := bkXPA_COM_Refresh_Supported_User_Selected_Ledger;
      end;
    finally
      PALgr := UnAssigned;
    end;
  end;
end;


end.

