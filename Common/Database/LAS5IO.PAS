UNIT LAs5IO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES LADEFS, IOSTREAM, LAAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Form                         = 60 ;
   tkEnd_Form                           = 61 ;

FUNCTION  IsAForm_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Form_Rec ( Var O : TForm_Rec ; Var F : TIOStream );
PROCEDURE Read_Form_Rec ( Var O : TForm_Rec ; Var F : TIOStream );
FUNCTION  New_Form_Rec : pForm_Rec ;
PROCEDURE Free_Form_Rec_Dynamic_Fields ( Var O : TForm_Rec );
FUNCTION Form_Rec_Delta(P1, P2, P3: pForm_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Form_Rec(P1, P2: pForm_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'LAS5IO';
   SBoundsError        = 'LAS5IO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'LAS5IO Error: Pointer is NIL in IsAForm_Rec';
   SInvalidType        = 'LAS5IO Error: Type is invalid in IsAForm_Rec';
   SInvalidEOR         = 'LAS5IO Error: EOR is missing in IsAForm_Rec';
   SUnknownToken       = 'LAS5IO Error: Unknown token %d in Read_Form_Rec';
   SInsufficientMemory = 'LAS5IO Error: Out of memory in New_Form_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tks5Form_Number                      = 62 ;
   tks5Description                      = 63 ;
   tks5Page_Type                        = 64 ;
   tks5Page_Length                      = 65 ;
   tks5Page_Width                       = 66 ;
   tks5Left_Margin                      = 67 ;
   tks5Right_Margin                     = 68 ;
   tks5Top_Margin                       = 69 ;
   tks5Bottom_Margin                    = 70 ;
   tks5Windows_Form_Type                = 71 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAForm_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PForm_Rec ( P )^ do Begin
      If s5Record_Type <> tkBegin_Form then
         Raise ECorruptData.Create( SInvalidType );
      If s5EOR <> tkEnd_Form then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Form_Rec ( Var O : TForm_Rec ; Var F : TIOStream );

Begin
   If IsAForm_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Form );
      F.WriteIntegerValue( tks5Form_Number , s5Form_Number );
      F.WriteStringValue( tks5Description , s5Description );
      F.WriteByteValue( tks5Page_Type , s5Page_Type );
      F.WriteMoneyValue( tks5Page_Length , s5Page_Length );
      F.WriteDoubleValue( tks5Page_Width, s5Page_Width );
      F.WriteDoubleValue( tks5Left_Margin, s5Left_Margin );
      F.WriteDoubleValue( tks5Right_Margin, s5Right_Margin );
      F.WriteDoubleValue( tks5Top_Margin, s5Top_Margin );
      F.WriteDoubleValue( tks5Bottom_Margin, s5Bottom_Margin );
      F.WriteIntegerValue( tks5Windows_Form_Type , s5Windows_Form_Type );
      F.WriteToken( tkEnd_Form );
   end;
end; { of Write_Form_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Form_Rec ( Var O : TForm_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Form_Rec_Size, 0 );
   O.s5Record_Type := tkBegin_Form;
   O.s5EOR := tkEnd_Form;
   Token := tkBegin_Form;

   While Token <> tkEnd_Form do With O do
   Begin
      Case Token of
         tkBegin_Form :; { Do Nothing }
         tkEnd_Form :; { Do Nothing }
         tks5Form_Number                      : s5Form_Number := F.ReadIntegerValue;
         tks5Description                      : s5Description := F.ReadStringValue;
         tks5Page_Type                        : s5Page_Type := F.ReadByteValue;
         tks5Page_Length                      : s5Page_Length := F.ReadMoneyValue;
         tks5Page_Width                       : s5Page_Width := F.ReadDoubleValue;
         tks5Left_Margin                      : s5Left_Margin := F.ReadDoubleValue;
         tks5Right_Margin                     : s5Right_Margin := F.ReadDoubleValue;
         tks5Top_Margin                       : s5Top_Margin := F.ReadDoubleValue;
         tks5Bottom_Margin                    : s5Bottom_Margin := F.ReadDoubleValue;
         tks5Windows_Form_Type                : s5Windows_Form_Type := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Form_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Form_Rec : pForm_Rec ;

Var
   P : pForm_Rec;
Begin
   SafeGetMem( P, Form_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Form_Rec_Size, 0 );
      s5Record_Type := tkBegin_Form;
      s5EOR         := tkEnd_Form;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Form_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Form_Rec_Dynamic_Fields ( Var O : TForm_Rec );

Begin
   If IsAForm_Rec ( @O ) then With O do
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
  for i := tks5Form_Number to tks5Windows_Form_Type do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Form_Rec_Delta(P1, P2, P3: pForm_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Form_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.s5Form_Number <> P2.s5Form_Number) then begin
    P3.s5Form_Number := P1.s5Form_Number;
    ChangedFields[i] := tks5Form_Number;
    Inc(i);
  end;
  if (P1.s5Description <> P2.s5Description) then begin
    P3.s5Description := P1.s5Description;
    ChangedFields[i] := tks5Description;
    Inc(i);
  end;
  if (P1.s5Page_Type <> P2.s5Page_Type) then begin
    P3.s5Page_Type := P1.s5Page_Type;
    ChangedFields[i] := tks5Page_Type;
    Inc(i);
  end;
  if (P1.s5Page_Length <> P2.s5Page_Length) then begin
    P3.s5Page_Length := P1.s5Page_Length;
    ChangedFields[i] := tks5Page_Length;
    Inc(i);
  end;
  if (P1.s5Page_Width <> P2.s5Page_Width) then begin
    P3.s5Page_Width := P1.s5Page_Width;
    ChangedFields[i] := tks5Page_Width;
    Inc(i);
  end;
  if (P1.s5Left_Margin <> P2.s5Left_Margin) then begin
    P3.s5Left_Margin := P1.s5Left_Margin;
    ChangedFields[i] := tks5Left_Margin;
    Inc(i);
  end;
  if (P1.s5Right_Margin <> P2.s5Right_Margin) then begin
    P3.s5Right_Margin := P1.s5Right_Margin;
    ChangedFields[i] := tks5Right_Margin;
    Inc(i);
  end;
  if (P1.s5Top_Margin <> P2.s5Top_Margin) then begin
    P3.s5Top_Margin := P1.s5Top_Margin;
    ChangedFields[i] := tks5Top_Margin;
    Inc(i);
  end;
  if (P1.s5Bottom_Margin <> P2.s5Bottom_Margin) then begin
    P3.s5Bottom_Margin := P1.s5Bottom_Margin;
    ChangedFields[i] := tks5Bottom_Margin;
    Inc(i);
  end;
  if (P1.s5Windows_Form_Type <> P2.s5Windows_Form_Type) then begin
    P3.s5Windows_Form_Type := P1.s5Windows_Form_Type;
    ChangedFields[i] := tks5Windows_Form_Type;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Form_Rec(P1, P2: pForm_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Form_Rec(P1^, S);
    S.Position := 0;
    Read_Form_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
