UNIT LAs7IO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES LADEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Windows_Report_Setting       = 80 ;
   tkEnd_Windows_Report_Setting         = 81 ;

FUNCTION  IsAWindows_Report_Setting_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Windows_Report_Setting_Rec ( Var O : TWindows_Report_Setting_Rec ; Var F : TIOStream );
PROCEDURE Read_Windows_Report_Setting_Rec ( Var O : TWindows_Report_Setting_Rec ; Var F : TIOStream );
FUNCTION  New_Windows_Report_Setting_Rec : pWindows_Report_Setting_Rec ;
PROCEDURE Free_Windows_Report_Setting_Rec_Dynamic_Fields ( Var O : TWindows_Report_Setting_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'LAS7IO';
   SBoundsError        = 'LAS7IO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'LAS7IO Error: Pointer is NIL in IsAWindows_Report_Setting_Rec';
   SInvalidType        = 'LAS7IO Error: Type is invalid in IsAWindows_Report_Setting_Rec';
   SInvalidEOR         = 'LAS7IO Error: EOR is missing in IsAWindows_Report_Setting_Rec';
   SUnknownToken       = 'LAS7IO Error: Unknown token %d in Read_Windows_Report_Setting_Rec';
   SInsufficientMemory = 'LAS7IO Error: Out of memory in New_Windows_Report_Setting_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tks7Report_Name                      = 82 ;
   tks7Printer_Name                     = 83 ;
   tks7Paper                            = 84 ;
   tks7Bin                              = 85 ;
   tks7Orientation                      = 86 ;
   tks7Base_Font_Name                   = 87 ;
   tks7Base_Font_Style                  = 88 ;
   tks7Base_Font_Size                   = 89 ;
   tks7Top_Margin                       = 90 ;
   tks7Left_Margin                      = 91 ;
   tks7Bottom_Margin                    = 92 ;
   tks7Right_Margin                     = 93 ;
   tks7Format_Style                     = 94 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAWindows_Report_Setting_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PWindows_Report_Setting_Rec ( P )^ do Begin
      If s7Record_Type <> tkBegin_Windows_Report_Setting then
         Raise ECorruptData.Create( SInvalidType );
      If s7EOR <> tkEnd_Windows_Report_Setting then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Windows_Report_Setting_Rec ( Var O : TWindows_Report_Setting_Rec ; Var F : TIOStream );

Begin
   If IsAWindows_Report_Setting_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Windows_Report_Setting );
      F.WriteStringValue( tks7Report_Name , s7Report_Name );
      F.WriteStringValue( tks7Printer_Name , s7Printer_Name );
      F.WriteIntegerValue( tks7Paper , s7Paper );
      F.WriteIntegerValue( tks7Bin , s7Bin );
      F.WriteByteValue( tks7Orientation , s7Orientation );
      F.WriteStringValue( tks7Base_Font_Name , s7Base_Font_Name );
      F.WriteIntegerValue( tks7Base_Font_Style , s7Base_Font_Style );
      F.WriteIntegerValue( tks7Base_Font_Size , s7Base_Font_Size );
      F.WriteIntegerValue( tks7Top_Margin , s7Top_Margin );
      F.WriteIntegerValue( tks7Left_Margin , s7Left_Margin );
      F.WriteIntegerValue( tks7Bottom_Margin , s7Bottom_Margin );
      F.WriteIntegerValue( tks7Right_Margin , s7Right_Margin );
      F.WriteStringValue( tks7Format_Style , s7Format_Style );
      F.WriteToken( tkEnd_Windows_Report_Setting );
   end;
end; { of Write_Windows_Report_Setting_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Windows_Report_Setting_Rec ( Var O : TWindows_Report_Setting_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Windows_Report_Setting_Rec_Size, 0 );
   O.s7Record_Type := tkBegin_Windows_Report_Setting;
   O.s7EOR := tkEnd_Windows_Report_Setting;
   Token := tkBegin_Windows_Report_Setting;

   While Token <> tkEnd_Windows_Report_Setting do With O do
   Begin
      Case Token of
         tkBegin_Windows_Report_Setting :; { Do Nothing }
         tkEnd_Windows_Report_Setting :; { Do Nothing }
         tks7Report_Name                      : s7Report_Name := F.ReadStringValue;
         tks7Printer_Name                     : s7Printer_Name := F.ReadStringValue;
         tks7Paper                            : s7Paper := F.ReadIntegerValue;
         tks7Bin                              : s7Bin := F.ReadIntegerValue;
         tks7Orientation                      : s7Orientation := F.ReadByteValue;
         tks7Base_Font_Name                   : s7Base_Font_Name := F.ReadStringValue;
         tks7Base_Font_Style                  : s7Base_Font_Style := F.ReadIntegerValue;
         tks7Base_Font_Size                   : s7Base_Font_Size := F.ReadIntegerValue;
         tks7Top_Margin                       : s7Top_Margin := F.ReadIntegerValue;
         tks7Left_Margin                      : s7Left_Margin := F.ReadIntegerValue;
         tks7Bottom_Margin                    : s7Bottom_Margin := F.ReadIntegerValue;
         tks7Right_Margin                     : s7Right_Margin := F.ReadIntegerValue;
         tks7Format_Style                     : s7Format_Style := F.ReadStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Windows_Report_Setting_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Windows_Report_Setting_Rec : pWindows_Report_Setting_Rec ;

Var
   P : pWindows_Report_Setting_Rec;
Begin
   SafeGetMem( P, Windows_Report_Setting_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Windows_Report_Setting_Rec_Size, 0 );
      s7Record_Type := tkBegin_Windows_Report_Setting;
      s7EOR         := tkEnd_Windows_Report_Setting;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Windows_Report_Setting_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Windows_Report_Setting_Rec_Dynamic_Fields ( Var O : TWindows_Report_Setting_Rec );

Begin
   If IsAWindows_Report_Setting_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
