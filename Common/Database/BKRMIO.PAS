UNIT BKrmIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Recommended_Mem              = 168 ;
   tkEnd_Recommended_Mem                = 169 ;

FUNCTION  IsARecommended_Mem_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Recommended_Mem_Rec ( Var O : TRecommended_Mem_Rec ; Var F : TIOStream );
PROCEDURE Read_Recommended_Mem_Rec ( Var O : TRecommended_Mem_Rec ; Var F : TIOStream );
FUNCTION  New_Recommended_Mem_Rec : pRecommended_Mem_Rec ;
PROCEDURE Free_Recommended_Mem_Rec_Dynamic_Fields ( Var O : TRecommended_Mem_Rec );
FUNCTION Recommended_Mem_Rec_Delta(P1, P2, P3: pRecommended_Mem_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Recommended_Mem_Rec(P1, P2: pRecommended_Mem_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKRMIO';
   SBoundsError        = 'BKRMIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKRMIO Error: Pointer is NIL in IsARecommended_Mem_Rec';
   SInvalidType        = 'BKRMIO Error: Type is invalid in IsARecommended_Mem_Rec';
   SInvalidEOR         = 'BKRMIO Error: EOR is missing in IsARecommended_Mem_Rec';
   SUnknownToken       = 'BKRMIO Error: Unknown token %d in Read_Recommended_Mem_Rec';
   SInsufficientMemory = 'BKRMIO Error: Out of memory in New_Recommended_Mem_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkrmType                             = 170 ;
   tkrmBank_Account_Number              = 171 ;
   tkrmAccount                          = 172 ;
   tkrmStatement_Details                = 173 ;
   tkrmManual_Count                     = 174 ;
   tkrmUncoded_Count                    = 175 ;

{  -------------------------------------------------------------------  }

FUNCTION IsARecommended_Mem_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PRecommended_Mem_Rec ( P )^ do Begin
      If rmRecord_Type <> tkBegin_Recommended_Mem then
         Raise ECorruptData.Create( SInvalidType );
      If rmEOR <> tkEnd_Recommended_Mem then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Recommended_Mem_Rec ( Var O : TRecommended_Mem_Rec ; Var F : TIOStream );

Begin
   If IsARecommended_Mem_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Recommended_Mem );
      F.WriteByteValue( tkrmType , rmType );
      F.WriteStringValue( tkrmBank_Account_Number , rmBank_Account_Number );
      F.WriteStringValue( tkrmAccount , rmAccount );
      F.WriteStringValue( tkrmStatement_Details , rmStatement_Details );
      F.WriteIntegerValue( tkrmManual_Count , rmManual_Count );
      F.WriteIntegerValue( tkrmUncoded_Count , rmUncoded_Count );
      F.WriteToken( tkEnd_Recommended_Mem );
   end;
end; { of Write_Recommended_Mem_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Recommended_Mem_Rec ( Var O : TRecommended_Mem_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Recommended_Mem_Rec_Size, 0 );
   O.rmRecord_Type := tkBegin_Recommended_Mem;
   O.rmEOR := tkEnd_Recommended_Mem;
   Token := tkBegin_Recommended_Mem;

   While Token <> tkEnd_Recommended_Mem do With O do
   Begin
      Case Token of
         tkBegin_Recommended_Mem :; { Do Nothing }
         tkEnd_Recommended_Mem :; { Do Nothing }
         tkrmType                             : rmType := F.ReadByteValue;
         tkrmBank_Account_Number              : rmBank_Account_Number := F.ReadStringValue;
         tkrmAccount                          : rmAccount := F.ReadStringValue;
         tkrmStatement_Details                : rmStatement_Details := F.ReadStringValue;
         tkrmManual_Count                     : rmManual_Count := F.ReadIntegerValue;
         tkrmUncoded_Count                    : rmUncoded_Count := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Recommended_Mem_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Recommended_Mem_Rec : pRecommended_Mem_Rec ;

Var
   P : pRecommended_Mem_Rec;
Begin
   SafeGetMem( P, Recommended_Mem_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Recommended_Mem_Rec_Size, 0 );
      rmRecord_Type := tkBegin_Recommended_Mem;
      rmEOR         := tkEnd_Recommended_Mem;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Recommended_Mem_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Recommended_Mem_Rec_Dynamic_Fields ( Var O : TRecommended_Mem_Rec );

Begin
   If IsARecommended_Mem_Rec ( @O ) then With O do
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
  for i := tkrmType to tkrmUncoded_Count do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Recommended_Mem_Rec_Delta(P1, P2, P3: pRecommended_Mem_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Recommended_Mem_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.rmType <> P2.rmType) then begin
    P3.rmType := P1.rmType;
    ChangedFields[i] := tkrmType;
    Inc(i);
  end;
  if (P1.rmBank_Account_Number <> P2.rmBank_Account_Number) then begin
    P3.rmBank_Account_Number := P1.rmBank_Account_Number;
    ChangedFields[i] := tkrmBank_Account_Number;
    Inc(i);
  end;
  if (P1.rmAccount <> P2.rmAccount) then begin
    P3.rmAccount := P1.rmAccount;
    ChangedFields[i] := tkrmAccount;
    Inc(i);
  end;
  if (P1.rmStatement_Details <> P2.rmStatement_Details) then begin
    P3.rmStatement_Details := P1.rmStatement_Details;
    ChangedFields[i] := tkrmStatement_Details;
    Inc(i);
  end;
  if (P1.rmManual_Count <> P2.rmManual_Count) then begin
    P3.rmManual_Count := P1.rmManual_Count;
    ChangedFields[i] := tkrmManual_Count;
    Inc(i);
  end;
  if (P1.rmUncoded_Count <> P2.rmUncoded_Count) then begin
    P3.rmUncoded_Count := P1.rmUncoded_Count;
    ChangedFields[i] := tkrmUncoded_Count;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Recommended_Mem_Rec(P1, P2: pRecommended_Mem_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Recommended_Mem_Rec(P1^, S);
    S.Position := 0;
    Read_Recommended_Mem_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
