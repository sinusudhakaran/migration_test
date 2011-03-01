Unit CSDEFS;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
Interface uses MONEYDEF, DATEDEF;
{  -------------------------------------------------------------------  }

Const
   CS_IOLIB_Version : Integer = 108;
   CS_IOLIB_Date    = '15/06/10';
   CS_FILE_VERSION  = 101;  (* Current Version counter for files
                              Changes if structure or method of storing a value would cause
                              data to be represented incorrectly, or an exception to be raised *)
   
   
   (*
       History            : 100     Introduction
       5.18.1 (2010 SMSF) : 101     Additional Categories
   *)

{  -------------------------------------------------------------------  }

Type
   pCoding_Stat_Fields_Rec               = ^tCoding_Stat_Fields_Rec ;
   pCoding_Statistics_Rec                = ^tCoding_Statistics_Rec ;

{  -------------------------------------------------------------------  }

   tCoding_Stat_Fields_Rec = Packed Record
      sfRecord_Type                      : Byte;
      sfFile_Version                     : Integer;       { Stored }
      sfRead_Version                     : Integer;       { Stored }
      sfEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tCoding_Statistics_Rec = Packed Record
      csRecord_Type                      : Byte;
      csClient_LRN                       : Integer;       { Stored }
      csMonth                            : Integer;       { Stored }
      csUpdated                          : Boolean;       { Stored }
      csMemorization_Count               : Integer;       { Stored }
      csAnalysis_Count                   : Integer;       { Stored }
      csPayee_Count                      : Integer;       { Stored }
      csManual_Count                     : Integer;       { Stored }
      csUncoded_Count                    : Integer;       { Stored }
      csMaster_Mem_Count                 : Integer;       { Stored }
      csMan_Super_Count                  : Integer;       { Stored }
      csNotes_Count                      : Integer;       { Stored }
      csEOR                              : Byte;
   end;

Const
   Coding_Stat_Fields_Rec_Size               = Sizeof( TCoding_Stat_Fields_Rec ); 
   Coding_Statistics_Rec_Size                = Sizeof( TCoding_Statistics_Rec ); 

{  -------------------------------------------------------------------  }
Implementation
{  -------------------------------------------------------------------  }

end.
