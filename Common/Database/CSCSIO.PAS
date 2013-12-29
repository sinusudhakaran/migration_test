UNIT CScsIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES CSDEFS, IOSTREAM, CSAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Coding_Statistics            = 10 ;
   tkEnd_Coding_Statistics              = 11 ;

FUNCTION  IsACoding_Statistics_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Coding_Statistics_Rec ( Var O : TCoding_Statistics_Rec ; Var F : TIOStream );
PROCEDURE Read_Coding_Statistics_Rec ( Var O : TCoding_Statistics_Rec ; Var F : TIOStream );
FUNCTION  New_Coding_Statistics_Rec : pCoding_Statistics_Rec ;
PROCEDURE Free_Coding_Statistics_Rec_Dynamic_Fields ( Var O : TCoding_Statistics_Rec );
FUNCTION Coding_Statistics_Rec_Delta(P1, P2, P3: pCoding_Statistics_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Coding_Statistics_Rec(P1, P2: pCoding_Statistics_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'CSCSIO';
   SBoundsError        = 'CSCSIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'CSCSIO Error: Pointer is NIL in IsACoding_Statistics_Rec';
   SInvalidType        = 'CSCSIO Error: Type is invalid in IsACoding_Statistics_Rec';
   SInvalidEOR         = 'CSCSIO Error: EOR is missing in IsACoding_Statistics_Rec';
   SUnknownToken       = 'CSCSIO Error: Unknown token %d in Read_Coding_Statistics_Rec';
   SInsufficientMemory = 'CSCSIO Error: Out of memory in New_Coding_Statistics_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkcsClient_LRN                       = 12 ;
   tkcsMonth                            = 13 ;
   tkcsUpdated                          = 14 ;
   tkcsMemorization_Count               = 15 ;
   tkcsAnalysis_Count                   = 16 ;
   tkcsPayee_Count                      = 17 ;
   tkcsManual_Count                     = 18 ;
   tkcsUncoded_Count                    = 19 ;
   tkcsMaster_Mem_Count                 = 20 ;
   tkcsMan_Super_Count                  = 21 ;
   tkcsNotes_Count                      = 22 ;
   tkcsClient_Files_Sent                = 23 ;
   tkcsClient_Files_Received            = 24 ;

{  -------------------------------------------------------------------  }

FUNCTION IsACoding_Statistics_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PCoding_Statistics_Rec ( P )^ do Begin
      If csRecord_Type <> tkBegin_Coding_Statistics then
         Raise ECorruptData.Create( SInvalidType );
      If csEOR <> tkEnd_Coding_Statistics then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Coding_Statistics_Rec ( Var O : TCoding_Statistics_Rec ; Var F : TIOStream );

Begin
   If IsACoding_Statistics_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Coding_Statistics );
      F.WriteIntegerValue( tkcsClient_LRN , csClient_LRN );
      F.WriteDateValue( tkcsMonth , csMonth );
      F.WriteBooleanValue( tkcsUpdated , csUpdated );
      F.WriteIntegerValue( tkcsMemorization_Count , csMemorization_Count );
      F.WriteIntegerValue( tkcsAnalysis_Count , csAnalysis_Count );
      F.WriteIntegerValue( tkcsPayee_Count , csPayee_Count );
      F.WriteIntegerValue( tkcsManual_Count , csManual_Count );
      F.WriteIntegerValue( tkcsUncoded_Count , csUncoded_Count );
      F.WriteIntegerValue( tkcsMaster_Mem_Count , csMaster_Mem_Count );
      F.WriteIntegerValue( tkcsMan_Super_Count , csMan_Super_Count );
      F.WriteIntegerValue( tkcsNotes_Count , csNotes_Count );
      F.WriteIntegerValue( tkcsClient_Files_Sent , csClient_Files_Sent );
      F.WriteIntegerValue( tkcsClient_Files_Received , csClient_Files_Received );
      F.WriteToken( tkEnd_Coding_Statistics );
   end;
end; { of Write_Coding_Statistics_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Coding_Statistics_Rec ( Var O : TCoding_Statistics_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Coding_Statistics_Rec_Size, 0 );
   O.csRecord_Type := tkBegin_Coding_Statistics;
   O.csEOR := tkEnd_Coding_Statistics;
   Token := tkBegin_Coding_Statistics;

   While Token <> tkEnd_Coding_Statistics do With O do
   Begin
      Case Token of
         tkBegin_Coding_Statistics :; { Do Nothing }
         tkEnd_Coding_Statistics :; { Do Nothing }
         tkcsClient_LRN                       : csClient_LRN := F.ReadIntegerValue;
         tkcsMonth                            : csMonth := F.ReadDateValue;
         tkcsUpdated                          : csUpdated := F.ReadBooleanValue;
         tkcsMemorization_Count               : csMemorization_Count := F.ReadIntegerValue;
         tkcsAnalysis_Count                   : csAnalysis_Count := F.ReadIntegerValue;
         tkcsPayee_Count                      : csPayee_Count := F.ReadIntegerValue;
         tkcsManual_Count                     : csManual_Count := F.ReadIntegerValue;
         tkcsUncoded_Count                    : csUncoded_Count := F.ReadIntegerValue;
         tkcsMaster_Mem_Count                 : csMaster_Mem_Count := F.ReadIntegerValue;
         tkcsMan_Super_Count                  : csMan_Super_Count := F.ReadIntegerValue;
         tkcsNotes_Count                      : csNotes_Count := F.ReadIntegerValue;
         tkcsClient_Files_Sent                : csClient_Files_Sent := F.ReadIntegerValue;
         tkcsClient_Files_Received            : csClient_Files_Received := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Coding_Statistics_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Coding_Statistics_Rec : pCoding_Statistics_Rec ;

Var
   P : pCoding_Statistics_Rec;
Begin
   SafeGetMem( P, Coding_Statistics_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Coding_Statistics_Rec_Size, 0 );
      csRecord_Type := tkBegin_Coding_Statistics;
      csEOR         := tkEnd_Coding_Statistics;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Coding_Statistics_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Coding_Statistics_Rec_Dynamic_Fields ( Var O : TCoding_Statistics_Rec );

Begin
   If IsACoding_Statistics_Rec ( @O ) then With O do
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
  for i := tkcsClient_LRN to tkcsClient_Files_Received do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Coding_Statistics_Rec_Delta(P1, P2, P3: pCoding_Statistics_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Coding_Statistics_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.csClient_LRN <> P2.csClient_LRN) then begin
    P3.csClient_LRN := P1.csClient_LRN;
    ChangedFields[i] := tkcsClient_LRN;
    Inc(i);
  end;
  if (P1.csMonth <> P2.csMonth) then begin
    P3.csMonth := P1.csMonth;
    ChangedFields[i] := tkcsMonth;
    Inc(i);
  end;
  if (P1.csUpdated <> P2.csUpdated) then begin
    P3.csUpdated := P1.csUpdated;
    ChangedFields[i] := tkcsUpdated;
    Inc(i);
  end;
  if (P1.csMemorization_Count <> P2.csMemorization_Count) then begin
    P3.csMemorization_Count := P1.csMemorization_Count;
    ChangedFields[i] := tkcsMemorization_Count;
    Inc(i);
  end;
  if (P1.csAnalysis_Count <> P2.csAnalysis_Count) then begin
    P3.csAnalysis_Count := P1.csAnalysis_Count;
    ChangedFields[i] := tkcsAnalysis_Count;
    Inc(i);
  end;
  if (P1.csPayee_Count <> P2.csPayee_Count) then begin
    P3.csPayee_Count := P1.csPayee_Count;
    ChangedFields[i] := tkcsPayee_Count;
    Inc(i);
  end;
  if (P1.csManual_Count <> P2.csManual_Count) then begin
    P3.csManual_Count := P1.csManual_Count;
    ChangedFields[i] := tkcsManual_Count;
    Inc(i);
  end;
  if (P1.csUncoded_Count <> P2.csUncoded_Count) then begin
    P3.csUncoded_Count := P1.csUncoded_Count;
    ChangedFields[i] := tkcsUncoded_Count;
    Inc(i);
  end;
  if (P1.csMaster_Mem_Count <> P2.csMaster_Mem_Count) then begin
    P3.csMaster_Mem_Count := P1.csMaster_Mem_Count;
    ChangedFields[i] := tkcsMaster_Mem_Count;
    Inc(i);
  end;
  if (P1.csMan_Super_Count <> P2.csMan_Super_Count) then begin
    P3.csMan_Super_Count := P1.csMan_Super_Count;
    ChangedFields[i] := tkcsMan_Super_Count;
    Inc(i);
  end;
  if (P1.csNotes_Count <> P2.csNotes_Count) then begin
    P3.csNotes_Count := P1.csNotes_Count;
    ChangedFields[i] := tkcsNotes_Count;
    Inc(i);
  end;
  if (P1.csClient_Files_Sent <> P2.csClient_Files_Sent) then begin
    P3.csClient_Files_Sent := P1.csClient_Files_Sent;
    ChangedFields[i] := tkcsClient_Files_Sent;
    Inc(i);
  end;
  if (P1.csClient_Files_Received <> P2.csClient_Files_Received) then begin
    P3.csClient_Files_Received := P1.csClient_Files_Received;
    ChangedFields[i] := tkcsClient_Files_Received;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Coding_Statistics_Rec(P1, P2: pCoding_Statistics_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Coding_Statistics_Rec(P1^, S);
    S.Position := 0;
    Read_Coding_Statistics_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
