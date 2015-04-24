UNIT BKtsIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Tran_Suggested_Link          = 170 ;
   tkEnd_Tran_Suggested_Link            = 171 ;

FUNCTION  IsATran_Suggested_Link_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Tran_Suggested_Link_Rec ( Var O : TTran_Suggested_Link_Rec ; Var F : TIOStream );
PROCEDURE Read_Tran_Suggested_Link_Rec ( Var O : TTran_Suggested_Link_Rec ; Var F : TIOStream );
FUNCTION  New_Tran_Suggested_Link_Rec : pTran_Suggested_Link_Rec ;
PROCEDURE Free_Tran_Suggested_Link_Rec_Dynamic_Fields ( Var O : TTran_Suggested_Link_Rec );
FUNCTION Tran_Suggested_Link_Rec_Delta(P1, P2, P3: pTran_Suggested_Link_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Tran_Suggested_Link_Rec(P1, P2: pTran_Suggested_Link_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKTSIO';
   SBoundsError        = 'BKTSIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKTSIO Error: Pointer is NIL in IsATran_Suggested_Link_Rec';
   SInvalidType        = 'BKTSIO Error: Type is invalid in IsATran_Suggested_Link_Rec';
   SInvalidEOR         = 'BKTSIO Error: EOR is missing in IsATran_Suggested_Link_Rec';
   SUnknownToken       = 'BKTSIO Error: Unknown token %d in Read_Tran_Suggested_Link_Rec';
   SInsufficientMemory = 'BKTSIO Error: Out of memory in New_Tran_Suggested_Link_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tktsDate_Effective                   = 172 ;
   tktsTran_Seq_No                      = 173 ;
   tktsSuggestedId                      = 174 ;

{  -------------------------------------------------------------------  }

FUNCTION IsATran_Suggested_Link_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PTran_Suggested_Link_Rec ( P )^ do Begin
      If tsRecord_Type <> tkBegin_Tran_Suggested_Link then
         Raise ECorruptData.Create( SInvalidType );
      If tsEOR <> tkEnd_Tran_Suggested_Link then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Tran_Suggested_Link_Rec ( Var O : TTran_Suggested_Link_Rec ; Var F : TIOStream );

Begin
   If IsATran_Suggested_Link_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Tran_Suggested_Link );
      F.WriteDateValue( tktsDate_Effective , tsDate_Effective );
      F.WriteIntegerValue( tktsTran_Seq_No , tsTran_Seq_No );
      F.WriteIntegerValue( tktsSuggestedId , tsSuggestedId );
      F.WriteToken( tkEnd_Tran_Suggested_Link );
   end;
end; { of Write_Tran_Suggested_Link_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Tran_Suggested_Link_Rec ( Var O : TTran_Suggested_Link_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Tran_Suggested_Link_Rec_Size, 0 );
   O.tsRecord_Type := tkBegin_Tran_Suggested_Link;
   O.tsEOR := tkEnd_Tran_Suggested_Link;
   Token := tkBegin_Tran_Suggested_Link;

   While Token <> tkEnd_Tran_Suggested_Link do With O do
   Begin
      Case Token of
         tkBegin_Tran_Suggested_Link :; { Do Nothing }
         tkEnd_Tran_Suggested_Link :; { Do Nothing }
         tktsDate_Effective                   : tsDate_Effective := F.ReadDateValue;
         tktsTran_Seq_No                      : tsTran_Seq_No := F.ReadIntegerValue;
         tktsSuggestedId                      : tsSuggestedId := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Tran_Suggested_Link_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Tran_Suggested_Link_Rec : pTran_Suggested_Link_Rec ;

Var
   P : pTran_Suggested_Link_Rec;
Begin
   SafeGetMem( P, Tran_Suggested_Link_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Tran_Suggested_Link_Rec_Size, 0 );
      tsRecord_Type := tkBegin_Tran_Suggested_Link;
      tsEOR         := tkEnd_Tran_Suggested_Link;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Tran_Suggested_Link_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Tran_Suggested_Link_Rec_Dynamic_Fields ( Var O : TTran_Suggested_Link_Rec );

Begin
   If IsATran_Suggested_Link_Rec ( @O ) then With O do
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
  for i := tktsDate_Effective to tktsSuggestedId do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Tran_Suggested_Link_Rec_Delta(P1, P2, P3: pTran_Suggested_Link_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Tran_Suggested_Link_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.tsDate_Effective <> P2.tsDate_Effective) then begin
    P3.tsDate_Effective := P1.tsDate_Effective;
    ChangedFields[i] := tktsDate_Effective;
    Inc(i);
  end;
  if (P1.tsTran_Seq_No <> P2.tsTran_Seq_No) then begin
    P3.tsTran_Seq_No := P1.tsTran_Seq_No;
    ChangedFields[i] := tktsTran_Seq_No;
    Inc(i);
  end;
  if (P1.tsSuggestedId <> P2.tsSuggestedId) then begin
    P3.tsSuggestedId := P1.tsSuggestedId;
    ChangedFields[i] := tktsSuggestedId;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Tran_Suggested_Link_Rec(P1, P2: pTran_Suggested_Link_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Tran_Suggested_Link_Rec(P1^, S);
    S.Position := 0;
    Read_Tran_Suggested_Link_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
