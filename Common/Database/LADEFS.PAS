Unit LADEFS;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
Interface uses MONEYDEF, DATEDEF;
{  -------------------------------------------------------------------  }

Const
   LA_IOLIB_Version : Integer = 116;
   LA_IOLIB_Date    = '30/12/13';

{  -------------------------------------------------------------------  }

Type
   pPrinter_Rec                          = ^tPrinter_Rec ;
   pForm_Rec                             = ^tForm_Rec ;
   pReport_Setting_Rec                   = ^tReport_Setting_Rec ;
   pWindows_Report_Setting_Rec           = ^tWindows_Report_Setting_Rec ;

{  -------------------------------------------------------------------  }

   tPrinter_Rec = Packed Record
      s3Record_Type                      : Byte;
      s3Printer_Name                     : String[ 60 ];       { Stored }
      s3Printer_Model_Name               : String[ 40 ];       { Stored }
      s3Library_File_Name                : String[ 40 ];       { Stored }
      s3Connection_Type                  : Byte;       { Stored }
      s3Queue_Name                       : String[ 80 ];       { Stored }
      s3LRN                              : Integer;       { Stored }
      s3EOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tForm_Rec = Packed Record
      s5Record_Type                      : Byte;
      s5Form_Number                      : Integer;       { Stored }
      s5Description                      : String[ 60 ];       { Stored }
      s5Page_Type                        : Byte;       { Stored }
      s5Page_Length                      : Money;       { Stored }
      s5Page_Width                       : Double;       { Stored }
      s5Left_Margin                      : Double;       { Stored }
      s5Right_Margin                     : Double;       { Stored }
      s5Top_Margin                       : Double;       { Stored }
      s5Bottom_Margin                    : Double;       { Stored }
      s5Windows_Form_Type                : Integer;       { Stored }
      s5EOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tReport_Setting_Rec = Packed Record
      s6Record_Type                      : Byte;
      s6Report_Name                      : String[ 60 ];       { Stored }
      s6Printer                          : Integer;       { Stored }
      s6Form_Number                      : Integer;       { Stored }
      s6Location                         : String[ 40 ];       { Stored }
      s6Orientation                      : String[ 40 ];       { Stored }
      s6Typeface                         : String[ 40 ];       { Stored }
      s6Font                             : String[ 40 ];       { Stored }
      s6Font_Size                        : Integer;       { Stored }
      s6Style                            : String[ 40 ];       { Stored }
      s6CPI                              : String[ 40 ];       { Stored }
      s6LPI                              : String[ 40 ];       { Stored }
      s6Number_of_Copies                 : Integer;       { Stored }
      s6EOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tWindows_Report_Setting_Rec = Packed Record
      s7Record_Type                      : Byte;
      s7Report_Name                      : String[ 60 ];       { Stored }
      s7Printer_Name                     : String[ 60 ];       { Stored }
      s7Paper                            : Integer;       { Stored }
      s7Bin                              : Integer;       { Stored }
      s7Orientation                      : Byte;       { Stored }
      s7Base_Font_Name                   : String[ 40 ];       { Stored }
      s7Base_Font_Style                  : Integer;       { Stored }
      s7Base_Font_Size                   : Integer;       { Stored }
      s7Top_Margin                       : Integer;       { Stored }
      s7Left_Margin                      : Integer;       { Stored }
      s7Bottom_Margin                    : Integer;       { Stored }
      s7Right_Margin                     : Integer;       { Stored }
      s7Format_Style                     : String[ 40 ];       { Stored }
      s7Is_Default                       : Boolean;
      s7Save_Required                    : Boolean;
      s7Temp_Font_Scale_Factor           : Double;
      s7EOR                              : Byte;
   end;

Const
   Printer_Rec_Size                          = Sizeof( TPrinter_Rec ); 
   Form_Rec_Size                             = Sizeof( TForm_Rec ); 
   Report_Setting_Rec_Size                   = Sizeof( TReport_Setting_Rec ); 
   Windows_Report_Setting_Rec_Size           = Sizeof( TWindows_Report_Setting_Rec ); 

{  -------------------------------------------------------------------  }
Implementation
{  -------------------------------------------------------------------  }

end.
