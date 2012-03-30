Unit CSDEFS;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
Interface uses MoneyDef, DateDef;
{  -------------------------------------------------------------------  }

Const
   CS_IOLIB_Version : Integer = 109;
   CS_IOLIB_Date    = '30/03/12';
   CS_FILE_VERSION  = 102;  (* Current Version counter for files
                              Changes if structure or method of storing a value would cause
                              data to be represented incorrectly, or an exception to be raised *)
   
   
   (*
       History              : 100     Introduction
       5.18.1 (2010 SMSF)   : 101     Additional Categories
       Change Request 41880 : 102     Client File counts added
   *)

{  -------------------------------------------------------------------  }

Type
   pCoding_Stat_Fields_Rec               = ^tCoding_Stat_Fields_Rec ;
   pCoding_Statistics_Rec                = ^tCoding_Statistics_Rec ;

{  -------------------------------------------------------------------  }

   tCoding_Stat_Fields_Rec = Packed Record
      sfRecord_Type                      : Byte;
      sfFile_Version                     : LongInt;       { Stored }
      sfRead_Version                     : LongInt;       { Stored }
      sfEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tCoding_Statistics_Rec = Packed Record
      csRecord_Type                      : Byte;
      csClient_LRN                       : LongInt;       { Stored }
      csMonth                            : LongInt;       { Stored }
      csUpdated                          : Boolean;       { Stored }
      csMemorization_Count               : LongInt;       { Stored }
      csAnalysis_Count                   : LongInt;       { Stored }
      csPayee_Count                      : LongInt;       { Stored }
      csManual_Count                     : LongInt;       { Stored }
      csUncoded_Count                    : LongInt;       { Stored }
      csMaster_Mem_Count                 : LongInt;       { Stored }
      csMan_Super_Count                  : LongInt;       { Stored }
      csNotes_Count                      : LongInt;       { Stored }
      csClient_Files_Sent                : LongInt;       { Stored }
      csClient_Files_Received            : LongInt;       { Stored }
      csEOR                              : Byte;
   end;

Const
   Coding_Stat_Fields_Rec_Size               = Sizeof( TCoding_Stat_Fields_Rec ); 
   Coding_Statistics_Rec_Size                = Sizeof( TCoding_Statistics_Rec ); 

{  -------------------------------------------------------------------  }
Implementation
{  -------------------------------------------------------------------  }

end.
