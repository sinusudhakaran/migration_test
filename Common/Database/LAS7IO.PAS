UNIT LAs7IO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES LADEFS, IOSTREAM, LAAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Windows_Report_Setting       = 80 ;
   tkEnd_Windows_Report_Setting         = 81 ;

FUNCTION  IsAWindows_Report_Setting_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Windows_Report_Setting_Rec ( Var O : TWindows_Report_Setting_Rec ; Var F : TIOStream );
PROCEDURE Read_Windows_Report_Setting_Rec ( Var O : TWindows_Report_Setting_Rec ; Var F : TIOStream );
FUNCTION  New_Windows_Report_Setting_Rec : pWindows_Report_Setting_Rec ;
PROCEDURE Free_Windows_Report_Setting_Rec_Dynamic_Fields ( Var O : TWindows_Report_Setting_Rec );
FUNCTION Windows_Report_Setting_Rec_Delta(P1, P2, P3: pWindows_Report_Setting_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Windows_Report_Setting_Rec(P1, P2: pWindows_Report_Setting_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

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

procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);
var
  i, j: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;
  j := 0;
  for i := tks7Report_Name to tks7Format_Style do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Windows_Report_Setting_Rec_Delta(P1, P2, P3: pWindows_Report_Setting_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Windows_Report_Setting_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.s7Report_Name <> P2.s7Report_Name) then begin
    P3.s7Report_Name := P1.s7Report_Name;
    ChangedFields[i] := tks7Report_Name;
    Inc(i);
  end;
  if (P1.s7Printer_Name <> P2.s7Printer_Name) then begin
    P3.s7Printer_Name := P1.s7Printer_Name;
    ChangedFields[i] := tks7Printer_Name;
    Inc(i);
  end;
  if (P1.s7Paper <> P2.s7Paper) then begin
    P3.s7Paper := P1.s7Paper;
    ChangedFields[i] := tks7Paper;
    Inc(i);
  end;
  if (P1.s7Bin <> P2.s7Bin) then begin
    P3.s7Bin := P1.s7Bin;
    ChangedFields[i] := tks7Bin;
    Inc(i);
  end;
  if (P1.s7Orientation <> P2.s7Orientation) then begin
    P3.s7Orientation := P1.s7Orientation;
    ChangedFields[i] := tks7Orientation;
    Inc(i);
  end;
  if (P1.s7Base_Font_Name <> P2.s7Base_Font_Name) then begin
    P3.s7Base_Font_Name := P1.s7Base_Font_Name;
    ChangedFields[i] := tks7Base_Font_Name;
    Inc(i);
  end;
  if (P1.s7Base_Font_Style <> P2.s7Base_Font_Style) then begin
    P3.s7Base_Font_Style := P1.s7Base_Font_Style;
    ChangedFields[i] := tks7Base_Font_Style;
    Inc(i);
  end;
  if (P1.s7Base_Font_Size <> P2.s7Base_Font_Size) then begin
    P3.s7Base_Font_Size := P1.s7Base_Font_Size;
    ChangedFields[i] := tks7Base_Font_Size;
    Inc(i);
  end;
  if (P1.s7Top_Margin <> P2.s7Top_Margin) then begin
    P3.s7Top_Margin := P1.s7Top_Margin;
    ChangedFields[i] := tks7Top_Margin;
    Inc(i);
  end;
  if (P1.s7Left_Margin <> P2.s7Left_Margin) then begin
    P3.s7Left_Margin := P1.s7Left_Margin;
    ChangedFields[i] := tks7Left_Margin;
    Inc(i);
  end;
  if (P1.s7Bottom_Margin <> P2.s7Bottom_Margin) then begin
    P3.s7Bottom_Margin := P1.s7Bottom_Margin;
    ChangedFields[i] := tks7Bottom_Margin;
    Inc(i);
  end;
  if (P1.s7Right_Margin <> P2.s7Right_Margin) then begin
    P3.s7Right_Margin := P1.s7Right_Margin;
    ChangedFields[i] := tks7Right_Margin;
    Inc(i);
  end;
  if (P1.s7Format_Style <> P2.s7Format_Style) then begin
    P3.s7Format_Style := P1.s7Format_Style;
    ChangedFields[i] := tks7Format_Style;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Windows_Report_Setting_Rec(P1, P2: pWindows_Report_Setting_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Windows_Report_Setting_Rec(P1^, S);
    S.Position := 0;
    Read_Windows_Report_Setting_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
