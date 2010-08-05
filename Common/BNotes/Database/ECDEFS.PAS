Unit ECDEFS;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
Interface uses MONEYDEF, DATEDEF;
{  -------------------------------------------------------------------  }

Const
   EC_IOLIB_Version : Integer = 163;
   EC_IOLIB_Date    = '30/01/09';
   EC_FILE_VERSION  = 11;  (* Current Version counter for files
                              Changes if structure or method of storing a value would cause
                              data to be represented incorrectly, or an exception to be raised *)
   
   (*
       History  :     01  Initial Version
                      02  Added export flags and branding
                          Extended Narration to 200 char
                      03  New payee list object and records added
                          Extended Dissection Narration to 200 char
                      04  Add basic chart of accounts
                      05  Add update server
                      06  Upgrade to 4 decimal places
                      07  Change UpdateServer to Practice Code
                      08  Add Superfund fields
                      09  Added GL Narration Fields
                      10  Added Tax Invoice Fields
                      11  Added Job list
   *)

{  -------------------------------------------------------------------  }

Type
   pECoding_File_Details_Rec             = ^tECoding_File_Details_Rec ;
   pAccount_Rec                          = ^tAccount_Rec ;
   pPayee_Rec                            = ^tPayee_Rec ;
   pPayee_Detail_Rec                     = ^tPayee_Detail_Rec ;
   pPayee_Line_Rec                       = ^tPayee_Line_Rec ;
   pBank_Account_Details_Rec             = ^tBank_Account_Details_Rec ;
   pTransaction_Rec                      = ^tTransaction_Rec ;
   pDissection_Rec                       = ^tDissection_Rec ;
   pJob_Heading_Rec                      = ^tJob_Heading_Rec ;

{  -------------------------------------------------------------------  }

   tECoding_File_Details_Rec = Packed Record
      ecRecord_Type                      : Byte;
      ecCode                             : String[ 8 ];       { Stored }
      ecName                             : String[ 60 ];       { Stored }
      ecContact_Name                     : String[ 60 ];       { Stored }
      ecFile_Password                    : String[ 8 ];       { Stored }
      ecPractice_Name                    : String[ 60 ];       { Stored }
      ecContact_Person                   : String[ 60 ];       { Stored }
      ecContact_EMail_Address            : String[ 80 ];       { Stored }
      ecContact_Phone_Number             : String[ 40 ];       { Stored }
      ecCountry                          : Byte;       { Stored }
      ecFile_Save_Count                  : Integer;       { Stored }
      ecAccount_Code_Mask                : String[ 20 ];       { Stored }
      ecMagic_Number                     : Integer;       { Stored }
      ecGST_Applies_From                 : Array[ 1..5 ] of Integer;       { Stored }
      ecGST_Rates                        : Array[ 1..99, 1..5 ] of Money;       { Stored }
      ecHide_Quantity_Col                : Boolean;       { Stored }
      ecDate_Range_From                  : Integer;       { Stored }
      ecDate_Range_To                    : Integer;       { Stored }
      ecFirst_Save_Done                  : Boolean;       { Stored }
      ecFile_Number                      : Integer;       { Stored }
      ecHide_GST_Col                     : Boolean;       { Stored }
      ecHide_Tax_Invoice_Col             : Boolean;       { Stored }
      ecHide_Account_Col                 : Boolean;       { Stored }
      ecHide_Payee_Col                   : Boolean;       { Stored }
      ecRestrict_UPIs                    : Boolean;       { Stored }
      ecPractice_Logo                    : AnsiString;       { Stored }
      ecPractice_Web_Site                : AnsiString;       { Stored }
      ecNotes                            : AnsiString;       { Stored }
      ecShow_Notes_On_Open               : Boolean;       { Stored }
      ecFile_Version                     : Integer;       { Stored }
      ecPractice_Code                    : AnsiString;       { Stored }
      ecSuper_Fund_System                : Byte;       { Stored }
      ecTAX_Applies_From                 : Array[ 1..99, 1..5 ] of Integer;       { Stored }
      ecTAX_Rates                        : Array[ 1..99, 1..5 ] of Money;       { Stored }
      ecHide_Job_Col                     : Boolean;       { Stored }
      ecFilename                         : AnsiString;
      ecCurrent_CRC                      : Integer;
      ecFile_Opened_Read_Only            : Boolean;
      ecEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tAccount_Rec = Packed Record
      chRecord_Type                      : Byte;
      chAccount_Code                     : String[ 20 ];       { Stored }
      chAccount_Description              : String[ 60 ];       { Stored }
      chGST_Class                        : Byte;       { Stored }
      chPosting_Allowed                  : Boolean;       { Stored }
      chHide_In_Basic_Chart              : Boolean;       { Stored }
      chEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tPayee_Rec = Packed Record
      pyRecord_Type                      : Byte;
      pyNumber                           : Integer;       { Stored }
      pyName                             : String[ 40 ];       { Stored }
      pyAccount                          : Array[ 1..50 ] of String[ 20 ];       { Stored }
      pyPercentage                       : Array[ 1..50 ] of Money;       { Stored }
      pyGST_Class                        : Array[ 1..50 ] of Byte;       { Stored }
      pyGST_Has_Been_Edited              : Array[ 1..50 ] of Boolean;       { Stored }
      pyAdded_By_ECoding                 : Boolean;       { Stored }
      pyGL_Narration                     : Array[ 1..50 ] of String[ 40 ];       { Stored }
      pyEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tPayee_Detail_Rec = Packed Record
      pdRecord_Type                      : Byte;
      pdNumber                           : Integer;       { Stored }
      pdName                             : String[ 40 ];       { Stored }
      pdAdded_By_ECoding                 : Boolean;       { Stored }
      pdEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tPayee_Line_Rec = Packed Record
      plRecord_Type                      : Byte;
      plAccount                          : String[ 20 ];       { Stored }
      plPercentage                       : Money;       { Stored }
      plGST_Class                        : Byte;       { Stored }
      plGST_Has_Been_Edited              : Boolean;       { Stored }
      plLine_Type                        : Byte;       { Stored }
      plGL_Narration                     : AnsiString;       { Stored }
      plEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tBank_Account_Details_Rec = Packed Record
      baRecord_Type                      : Byte;
      baBank_Account_Number              : String[ 20 ];       { Stored }
      baBank_Account_Name                : String[ 60 ];       { Stored }
      baBank_Account_Password            : String[ 20 ];       { Stored }
      baCurrent_Balance                  : Money;       { Stored }
      baAccount_Type                     : Byte;       { Stored }
      baNumber                           : Integer;
      baEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tTransaction_Rec = Packed Record
      txRecord_Type                      : Byte;
      txAuto_Sequence_No                 : Integer;       { Stored }
      txType                             : Byte;       { Stored }
      txSource                           : Byte;       { Stored }
      txDate_Presented                   : Integer;       { Stored }
      txDate_Effective                   : Integer;       { Stored }
      txAmount                           : Money;       { Stored }
      txGST_Class                        : Byte;       { Stored }
      txGST_Amount                       : Money;       { Stored }
      txHas_Been_Edited                  : Boolean;       { Stored }
      txQuantity                         : Money;       { Stored }
      txCheque_Number                    : Integer;       { Stored }
      txReference                        : String[ 12 ];       { Stored }
      txParticulars                      : String[ 12 ];       { Stored }
      txAnalysis                         : String[ 12 ];       { Stored }
      txOrigBB                           : String[ 6 ];       { Stored }
      txOther_Party                      : String[ 20 ];       { Stored }
      txNarration                        : String[ 200 ];       { Stored }
      txAccount                          : String[ 20 ];       { Stored }
      txCoded_By                         : Byte;       { Stored }
      txPayee_Number                     : Integer;       { Stored }
      txLocked                           : Boolean;       { Stored }
      txGST_Has_Been_Edited              : Boolean;       { Stored }
      txNotes                            : AnsiString;       { Stored }
      txECoding_ID                       : Integer;       { Stored }
      txTax_Invoice_Available            : Boolean;       { Stored }
      txUPI_State                        : Byte;       { Stored }
      txCode_Locked                      : Boolean;       { Stored }
      txUPI_Can_Delete                   : Boolean;       { Stored }
      txSF_Edited                        : Boolean;       { Stored }
      txSF_Franked                       : Money;       { Stored }
      txSF_Unfranked                     : Money;       { Stored }
      txSF_Franking_Credit               : Money;       { Stored }
      txBank_Seq                         : Integer;
      txFirst_Dissection                 : pDissection_Rec;
      txLast_Dissection                  : pDissection_Rec;
      txOld_Narration                    : String[ 200 ];       { Stored }
      txJob_Code                         : String[ 8 ];       { Stored }
      txEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tDissection_Rec = Packed Record
      dsRecord_Type                      : Byte;
      dsAuto_Sequence_No                 : Integer;       { Stored }
      dsAccount                          : String[ 20 ];       { Stored }
      dsAmount                           : Money;       { Stored }
      dsGST_Class                        : Byte;       { Stored }
      dsGST_Amount                       : Money;       { Stored }
      dsQuantity                         : Money;       { Stored }
      dsNarration                        : String[ 200 ];       { Stored }
      dsHas_Been_Edited                  : Boolean;       { Stored }
      dsGST_Has_Been_Edited              : Boolean;       { Stored }
      dsPayee_Number                     : Integer;       { Stored }
      dsNotes                            : AnsiString;       { Stored }
      dsSF_Edited                        : Boolean;       { Stored }
      dsSF_Franked                       : Money;       { Stored }
      dsSF_Unfranked                     : Money;       { Stored }
      dsSF_Franking_Credit               : Money;       { Stored }
      dsTransaction                      : pTransaction_Rec;
      dsNext                             : pDissection_Rec;
      dsTax_Invoice                      : Boolean;       { Stored }
      dsJob_Code                         : String[ 8 ];       { Stored }
      dsEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tJob_Heading_Rec = Packed Record
      jhRecord_Type                      : Byte;
      jhHeading                          : String[ 60 ];       { Stored }
      jhLRN                              : Integer;       { Stored }
      jhCode                             : String[ 8 ];       { Stored }
      jhIsCompleted                      : Boolean;       { Stored }
      jhAdded_By_ECoding                 : Boolean;       { Stored }
      jhEOR                              : Byte;
   end;

Const
   ECoding_File_Details_Rec_Size             = Sizeof( TECoding_File_Details_Rec ); 
   Account_Rec_Size                          = Sizeof( TAccount_Rec ); 
   Payee_Rec_Size                            = Sizeof( TPayee_Rec ); 
   Payee_Detail_Rec_Size                     = Sizeof( TPayee_Detail_Rec ); 
   Payee_Line_Rec_Size                       = Sizeof( TPayee_Line_Rec ); 
   Bank_Account_Details_Rec_Size             = Sizeof( TBank_Account_Details_Rec ); 
   Transaction_Rec_Size                      = Sizeof( TTransaction_Rec ); 
   Dissection_Rec_Size                       = Sizeof( TDissection_Rec ); 
   Job_Heading_Rec_Size                      = Sizeof( TJob_Heading_Rec ); 

{  -------------------------------------------------------------------  }
Implementation
{  -------------------------------------------------------------------  }

end.
