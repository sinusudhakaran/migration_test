UNIT LAs6IO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES LADEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Report_Setting               = 80 ;
   tkEnd_Report_Setting                 = 81 ;

FUNCTION  IsAReport_Setting_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Report_Setting_Rec ( Var O : TReport_Setting_Rec ; Var F : TIOStream );
PROCEDURE Read_Report_Setting_Rec ( Var O : TReport_Setting_Rec ; Var F : TIOStream );
FUNCTION  New_Report_Setting_Rec : pReport_Setting_Rec ;
PROCEDURE Free_Report_Setting_Rec_Dynamic_Fields ( Var O : TReport_Setting_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'LAS6IO';
   SBoundsError        = 'LAS6IO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'LAS6IO Error: Pointer is NIL in IsAReport_Setting_Rec';
   SInvalidType        = 'LAS6IO Error: Type is invalid in IsAReport_Setting_Rec';
   SInvalidEOR         = 'LAS6IO Error: EOR is missing in IsAReport_Setting_Rec';
   SUnknownToken       = 'LAS6IO Error: Unknown token %d in Read_Report_Setting_Rec';
   SInsufficientMemory = 'LAS6IO Error: Out of memory in New_Report_Setting_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tks6Report_Name                      = 82 ;
   tks6Printer                          = 83 ;
   tks6Form_Number                      = 84 ;
   tks6Location                         = 85 ;
   tks6Orientation                      = 86 ;
   tks6Typeface                         = 87 ;
   tks6Font                             = 88 ;
   tks6Font_Size                        = 89 ;
   tks6Style                            = 90 ;
   tks6CPI                              = 91 ;
   tks6LPI                              = 92 ;
   tks6Number_of_Copies                 = 93 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAReport_Setting_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PReport_Setting_Rec ( P )^ do Begin
      If s6Record_Type <> tkBegin_Report_Setting then
         Raise ECorruptData.Create( SInvalidType );
      If s6EOR <> tkEnd_Report_Setting then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Report_Setting_Rec ( Var O : TReport_Setting_Rec ; Var F : TIOStream );

Begin
   If IsAReport_Setting_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Report_Setting );
      F.WriteStringValue( tks6Report_Name , s6Report_Name );
      F.WriteIntegerValue( tks6Printer , s6Printer );
      F.WriteIntegerValue( tks6Form_Number , s6Form_Number );
      F.WriteStringValue( tks6Location , s6Location );
      F.WriteStringValue( tks6Orientation , s6Orientation );
      F.WriteStringValue( tks6Typeface , s6Typeface );
      F.WriteStringValue( tks6Font , s6Font );
      F.WriteIntegerValue( tks6Font_Size , s6Font_Size );
      F.WriteStringValue( tks6Style , s6Style );
      F.WriteStringValue( tks6CPI , s6CPI );
      F.WriteStringValue( tks6LPI , s6LPI );
      F.WriteIntegerValue( tks6Number_of_Copies , s6Number_of_Copies );
      F.WriteToken( tkEnd_Report_Setting );
   end;
end; { of Write_Report_Setting_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Report_Setting_Rec ( Var O : TReport_Setting_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Report_Setting_Rec_Size, 0 );
   O.s6Record_Type := tkBegin_Report_Setting;
   O.s6EOR := tkEnd_Report_Setting;
   Token := tkBegin_Report_Setting;

   While Token <> tkEnd_Report_Setting do With O do
   Begin
      Case Token of
         tkBegin_Report_Setting :; { Do Nothing }
         tkEnd_Report_Setting :; { Do Nothing }
         tks6Report_Name                      : s6Report_Name := F.ReadStringValue;
         tks6Printer                          : s6Printer := F.ReadIntegerValue;
         tks6Form_Number                      : s6Form_Number := F.ReadIntegerValue;
         tks6Location                         : s6Location := F.ReadStringValue;
         tks6Orientation                      : s6Orientation := F.ReadStringValue;
         tks6Typeface                         : s6Typeface := F.ReadStringValue;
         tks6Font                             : s6Font := F.ReadStringValue;
         tks6Font_Size                        : s6Font_Size := F.ReadIntegerValue;
         tks6Style                            : s6Style := F.ReadStringValue;
         tks6CPI                              : s6CPI := F.ReadStringValue;
         tks6LPI                              : s6LPI := F.ReadStringValue;
         tks6Number_of_Copies                 : s6Number_of_Copies := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Report_Setting_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Report_Setting_Rec : pReport_Setting_Rec ;

Var
   P : pReport_Setting_Rec;
Begin
   SafeGetMem( P, Report_Setting_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Report_Setting_Rec_Size, 0 );
      s6Record_Type := tkBegin_Report_Setting;
      s6EOR         := tkEnd_Report_Setting;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Report_Setting_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Report_Setting_Rec_Dynamic_Fields ( Var O : TReport_Setting_Rec );

Begin
   If IsAReport_Setting_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
