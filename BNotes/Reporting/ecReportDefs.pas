unit ecReportDefs;

interface

type
  TReportMargins = record
                 mtop,
                 mleft,
                 mbottom,
                 mright : longint;
  end;

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
      s7Is_Default                       : Boolean;
      s7Save_Required                    : Boolean;
      s7EOR                              : Byte;
   end;

type
   TReportDest = (rdScreen, rdPrinter, rdFile, rdAsk, rdSetup, rdNone, rdEmail);

const
   BK_PORTRAIT  = 0;
   BK_LANDSCAPE = 1;
   DEFAULT_PRINTER_ID = 'USE_DEFAULT_PRINTER';
   

implementation

end.
