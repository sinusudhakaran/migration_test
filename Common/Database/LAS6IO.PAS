UNIT LAs6IO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES LADEFS, IOSTREAM, LAAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Report_Setting               = 80 ;
   tkEnd_Report_Setting                 = 81 ;

FUNCTION  IsAReport_Setting_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Report_Setting_Rec ( Var O : TReport_Setting_Rec ; Var F : TIOStream );
PROCEDURE Read_Report_Setting_Rec ( Var O : TReport_Setting_Rec ; Var F : TIOStream );
FUNCTION  New_Report_Setting_Rec : pReport_Setting_Rec ;
PROCEDURE Free_Report_Setting_Rec_Dynamic_Fields ( Var O : TReport_Setting_Rec );
FUNCTION Report_Setting_Rec_Delta(P1, P2, P3: pReport_Setting_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Report_Setting_Rec(P1, P2: pReport_Setting_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

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

procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);
var
  i, j: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;
  j := 0;
  for i := tks6Report_Name to tks6Number_of_Copies do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Report_Setting_Rec_Delta(P1, P2, P3: pReport_Setting_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Report_Setting_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.s6Report_Name <> P2.s6Report_Name) then begin
    P3.s6Report_Name := P1.s6Report_Name;
    ChangedFields[i] := tks6Report_Name;
    Inc(i);
  end;
  if (P1.s6Printer <> P2.s6Printer) then begin
    P3.s6Printer := P1.s6Printer;
    ChangedFields[i] := tks6Printer;
    Inc(i);
  end;
  if (P1.s6Form_Number <> P2.s6Form_Number) then begin
    P3.s6Form_Number := P1.s6Form_Number;
    ChangedFields[i] := tks6Form_Number;
    Inc(i);
  end;
  if (P1.s6Location <> P2.s6Location) then begin
    P3.s6Location := P1.s6Location;
    ChangedFields[i] := tks6Location;
    Inc(i);
  end;
  if (P1.s6Orientation <> P2.s6Orientation) then begin
    P3.s6Orientation := P1.s6Orientation;
    ChangedFields[i] := tks6Orientation;
    Inc(i);
  end;
  if (P1.s6Typeface <> P2.s6Typeface) then begin
    P3.s6Typeface := P1.s6Typeface;
    ChangedFields[i] := tks6Typeface;
    Inc(i);
  end;
  if (P1.s6Font <> P2.s6Font) then begin
    P3.s6Font := P1.s6Font;
    ChangedFields[i] := tks6Font;
    Inc(i);
  end;
  if (P1.s6Font_Size <> P2.s6Font_Size) then begin
    P3.s6Font_Size := P1.s6Font_Size;
    ChangedFields[i] := tks6Font_Size;
    Inc(i);
  end;
  if (P1.s6Style <> P2.s6Style) then begin
    P3.s6Style := P1.s6Style;
    ChangedFields[i] := tks6Style;
    Inc(i);
  end;
  if (P1.s6CPI <> P2.s6CPI) then begin
    P3.s6CPI := P1.s6CPI;
    ChangedFields[i] := tks6CPI;
    Inc(i);
  end;
  if (P1.s6LPI <> P2.s6LPI) then begin
    P3.s6LPI := P1.s6LPI;
    ChangedFields[i] := tks6LPI;
    Inc(i);
  end;
  if (P1.s6Number_of_Copies <> P2.s6Number_of_Copies) then begin
    P3.s6Number_of_Copies := P1.s6Number_of_Copies;
    ChangedFields[i] := tks6Number_of_Copies;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Report_Setting_Rec(P1, P2: pReport_Setting_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Report_Setting_Rec(P1^, S);
    S.Position := 0;
    Read_Report_Setting_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
