UNIT BKmdIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Memorisation_Detail          = 140 ;
   tkEnd_Memorisation_Detail            = 141 ;

FUNCTION  IsAMemorisation_Detail_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Memorisation_Detail_Rec ( Var O : TMemorisation_Detail_Rec ; Var F : TIOStream );
PROCEDURE Read_Memorisation_Detail_Rec ( Var O : TMemorisation_Detail_Rec ; Var F : TIOStream );
FUNCTION  New_Memorisation_Detail_Rec : pMemorisation_Detail_Rec ;
PROCEDURE Free_Memorisation_Detail_Rec_Dynamic_Fields ( Var O : TMemorisation_Detail_Rec );
FUNCTION Memorisation_Detail_Rec_Delta(P1, P2, P3: pMemorisation_Detail_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Memorisation_Detail_Rec(P1, P2: pMemorisation_Detail_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKMDIO';
   SBoundsError        = 'BKMDIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKMDIO Error: Pointer is NIL in IsAMemorisation_Detail_Rec';
   SInvalidType        = 'BKMDIO Error: Type is invalid in IsAMemorisation_Detail_Rec';
   SInvalidEOR         = 'BKMDIO Error: EOR is missing in IsAMemorisation_Detail_Rec';
   SUnknownToken       = 'BKMDIO Error: Unknown token %d in Read_Memorisation_Detail_Rec';
   SInsufficientMemory = 'BKMDIO Error: Out of memory in New_Memorisation_Detail_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkmdSequence_No                      = 142 ;
   tkmdType                             = 143 ;
   tkmdAmount                           = 144 ;
   tkmdReference                        = 145 ;
   tkmdParticulars                      = 146 ;
   tkmdAnalysis                         = 147 ;
   tkmdOther_Party                      = 148 ;
   tkmdStatement_Details                = 149 ;
   tkmdMatch_on_Amount                  = 150 ;
   tkmdMatch_on_Analysis                = 151 ;
   tkmdMatch_on_Other_Party             = 152 ;
   tkmdMatch_on_Notes                   = 153 ;
   tkmdMatch_on_Particulars             = 154 ;
   tkmdMatch_on_Refce                   = 155 ;
   tkmdMatch_On_Statement_Details       = 156 ;
   tkmdPayee_Number                     = 157 ;
   tkmdFrom_Master_List                 = 158 ;
   tkmdNotes                            = 159 ;
   tkmdDate_Last_Applied                = 160 ;
   tkmdUse_Accounting_System            = 161 ;
   tkmdAccounting_System                = 162 ;
   tkmdFrom_Date                        = 163 ;
   tkmdUntil_Date                       = 164 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAMemorisation_Detail_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PMemorisation_Detail_Rec ( P )^ do Begin
      If mdRecord_Type <> tkBegin_Memorisation_Detail then
         Raise ECorruptData.Create( SInvalidType );
      If mdEOR <> tkEnd_Memorisation_Detail then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Memorisation_Detail_Rec ( Var O : TMemorisation_Detail_Rec ; Var F : TIOStream );

Begin
   If IsAMemorisation_Detail_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Memorisation_Detail );
      F.WriteIntegerValue( tkmdSequence_No , mdSequence_No );
      F.WriteByteValue( tkmdType , mdType );
      F.WriteMoneyValue( tkmdAmount , mdAmount );
      F.WriteStringValue( tkmdReference , mdReference );
      F.WriteStringValue( tkmdParticulars , mdParticulars );
      F.WriteStringValue( tkmdAnalysis , mdAnalysis );
      F.WriteStringValue( tkmdOther_Party , mdOther_Party );
      F.WriteStringValue( tkmdStatement_Details , mdStatement_Details );
      F.WriteByteValue( tkmdMatch_on_Amount , mdMatch_on_Amount );
      F.WriteBooleanValue( tkmdMatch_on_Analysis , mdMatch_on_Analysis );
      F.WriteBooleanValue( tkmdMatch_on_Other_Party , mdMatch_on_Other_Party );
      F.WriteBooleanValue( tkmdMatch_on_Notes , mdMatch_on_Notes );
      F.WriteBooleanValue( tkmdMatch_on_Particulars , mdMatch_on_Particulars );
      F.WriteBooleanValue( tkmdMatch_on_Refce , mdMatch_on_Refce );
      F.WriteBooleanValue( tkmdMatch_On_Statement_Details , mdMatch_On_Statement_Details );
      F.WriteIntegerValue( tkmdPayee_Number , mdPayee_Number );
      F.WriteBooleanValue( tkmdFrom_Master_List , mdFrom_Master_List );
      F.WriteStringValue( tkmdNotes , mdNotes );
      F.WriteIntegerValue( tkmdDate_Last_Applied , mdDate_Last_Applied );
      F.WriteBooleanValue( tkmdUse_Accounting_System , mdUse_Accounting_System );
      F.WriteByteValue( tkmdAccounting_System , mdAccounting_System );
      F.WriteDateValue( tkmdFrom_Date , mdFrom_Date );
      F.WriteDateValue( tkmdUntil_Date , mdUntil_Date );
      F.WriteToken( tkEnd_Memorisation_Detail );
   end;
end; { of Write_Memorisation_Detail_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Memorisation_Detail_Rec ( Var O : TMemorisation_Detail_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Memorisation_Detail_Rec_Size, 0 );
   O.mdRecord_Type := tkBegin_Memorisation_Detail;
   O.mdEOR := tkEnd_Memorisation_Detail;
   Token := tkBegin_Memorisation_Detail;

   While Token <> tkEnd_Memorisation_Detail do With O do
   Begin
      Case Token of
         tkBegin_Memorisation_Detail :; { Do Nothing }
         tkEnd_Memorisation_Detail :; { Do Nothing }
         tkmdSequence_No                      : mdSequence_No := F.ReadIntegerValue;
         tkmdType                             : mdType := F.ReadByteValue;
         tkmdAmount                           : mdAmount := F.ReadMoneyValue;
         tkmdReference                        : mdReference := F.ReadStringValue;
         tkmdParticulars                      : mdParticulars := F.ReadStringValue;
         tkmdAnalysis                         : mdAnalysis := F.ReadStringValue;
         tkmdOther_Party                      : mdOther_Party := F.ReadStringValue;
         tkmdStatement_Details                : mdStatement_Details := F.ReadStringValue;
         tkmdMatch_on_Amount                  : mdMatch_on_Amount := F.ReadByteValue;
         tkmdMatch_on_Analysis                : mdMatch_on_Analysis := F.ReadBooleanValue;
         tkmdMatch_on_Other_Party             : mdMatch_on_Other_Party := F.ReadBooleanValue;
         tkmdMatch_on_Notes                   : mdMatch_on_Notes := F.ReadBooleanValue;
         tkmdMatch_on_Particulars             : mdMatch_on_Particulars := F.ReadBooleanValue;
         tkmdMatch_on_Refce                   : mdMatch_on_Refce := F.ReadBooleanValue;
         tkmdMatch_On_Statement_Details       : mdMatch_On_Statement_Details := F.ReadBooleanValue;
         tkmdPayee_Number                     : mdPayee_Number := F.ReadIntegerValue;
         tkmdFrom_Master_List                 : mdFrom_Master_List := F.ReadBooleanValue;
         tkmdNotes                            : mdNotes := F.ReadStringValue;
         tkmdDate_Last_Applied                : mdDate_Last_Applied := F.ReadIntegerValue;
         tkmdUse_Accounting_System            : mdUse_Accounting_System := F.ReadBooleanValue;
         tkmdAccounting_System                : mdAccounting_System := F.ReadByteValue;
         tkmdFrom_Date                        : mdFrom_Date := F.ReadDateValue;
         tkmdUntil_Date                       : mdUntil_Date := F.ReadDateValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Memorisation_Detail_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Memorisation_Detail_Rec : pMemorisation_Detail_Rec ;

Var
   P : pMemorisation_Detail_Rec;
Begin
   SafeGetMem( P, Memorisation_Detail_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Memorisation_Detail_Rec_Size, 0 );
      mdRecord_Type := tkBegin_Memorisation_Detail;
      mdEOR         := tkEnd_Memorisation_Detail;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Memorisation_Detail_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Memorisation_Detail_Rec_Dynamic_Fields ( Var O : TMemorisation_Detail_Rec );

Begin
   If IsAMemorisation_Detail_Rec ( @O ) then With O do
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
  for i := tkmdSequence_No to tkmdUntil_Date do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Memorisation_Detail_Rec_Delta(P1, P2, P3: pMemorisation_Detail_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Memorisation_Detail_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.mdSequence_No <> P2.mdSequence_No) then begin
    P3.mdSequence_No := P1.mdSequence_No;
    ChangedFields[i] := tkmdSequence_No;
    Inc(i);
  end;
  if (P1.mdType <> P2.mdType) then begin
    P3.mdType := P1.mdType;
    ChangedFields[i] := tkmdType;
    Inc(i);
  end;
  if (P1.mdAmount <> P2.mdAmount) then begin
    P3.mdAmount := P1.mdAmount;
    ChangedFields[i] := tkmdAmount;
    Inc(i);
  end;
  if (P1.mdReference <> P2.mdReference) then begin
    P3.mdReference := P1.mdReference;
    ChangedFields[i] := tkmdReference;
    Inc(i);
  end;
  if (P1.mdParticulars <> P2.mdParticulars) then begin
    P3.mdParticulars := P1.mdParticulars;
    ChangedFields[i] := tkmdParticulars;
    Inc(i);
  end;
  if (P1.mdAnalysis <> P2.mdAnalysis) then begin
    P3.mdAnalysis := P1.mdAnalysis;
    ChangedFields[i] := tkmdAnalysis;
    Inc(i);
  end;
  if (P1.mdOther_Party <> P2.mdOther_Party) then begin
    P3.mdOther_Party := P1.mdOther_Party;
    ChangedFields[i] := tkmdOther_Party;
    Inc(i);
  end;
  if (P1.mdStatement_Details <> P2.mdStatement_Details) then begin
    P3.mdStatement_Details := P1.mdStatement_Details;
    ChangedFields[i] := tkmdStatement_Details;
    Inc(i);
  end;
  if (P1.mdMatch_on_Amount <> P2.mdMatch_on_Amount) then begin
    P3.mdMatch_on_Amount := P1.mdMatch_on_Amount;
    ChangedFields[i] := tkmdMatch_on_Amount;
    Inc(i);
  end;
  if (P1.mdMatch_on_Analysis <> P2.mdMatch_on_Analysis) then begin
    P3.mdMatch_on_Analysis := P1.mdMatch_on_Analysis;
    ChangedFields[i] := tkmdMatch_on_Analysis;
    Inc(i);
  end;
  if (P1.mdMatch_on_Other_Party <> P2.mdMatch_on_Other_Party) then begin
    P3.mdMatch_on_Other_Party := P1.mdMatch_on_Other_Party;
    ChangedFields[i] := tkmdMatch_on_Other_Party;
    Inc(i);
  end;
  if (P1.mdMatch_on_Notes <> P2.mdMatch_on_Notes) then begin
    P3.mdMatch_on_Notes := P1.mdMatch_on_Notes;
    ChangedFields[i] := tkmdMatch_on_Notes;
    Inc(i);
  end;
  if (P1.mdMatch_on_Particulars <> P2.mdMatch_on_Particulars) then begin
    P3.mdMatch_on_Particulars := P1.mdMatch_on_Particulars;
    ChangedFields[i] := tkmdMatch_on_Particulars;
    Inc(i);
  end;
  if (P1.mdMatch_on_Refce <> P2.mdMatch_on_Refce) then begin
    P3.mdMatch_on_Refce := P1.mdMatch_on_Refce;
    ChangedFields[i] := tkmdMatch_on_Refce;
    Inc(i);
  end;
  if (P1.mdMatch_On_Statement_Details <> P2.mdMatch_On_Statement_Details) then begin
    P3.mdMatch_On_Statement_Details := P1.mdMatch_On_Statement_Details;
    ChangedFields[i] := tkmdMatch_On_Statement_Details;
    Inc(i);
  end;
  if (P1.mdPayee_Number <> P2.mdPayee_Number) then begin
    P3.mdPayee_Number := P1.mdPayee_Number;
    ChangedFields[i] := tkmdPayee_Number;
    Inc(i);
  end;
  if (P1.mdFrom_Master_List <> P2.mdFrom_Master_List) then begin
    P3.mdFrom_Master_List := P1.mdFrom_Master_List;
    ChangedFields[i] := tkmdFrom_Master_List;
    Inc(i);
  end;
  if (P1.mdNotes <> P2.mdNotes) then begin
    P3.mdNotes := P1.mdNotes;
    ChangedFields[i] := tkmdNotes;
    Inc(i);
  end;
  if (P1.mdDate_Last_Applied <> P2.mdDate_Last_Applied) then begin
    P3.mdDate_Last_Applied := P1.mdDate_Last_Applied;
    ChangedFields[i] := tkmdDate_Last_Applied;
    Inc(i);
  end;
  if (P1.mdUse_Accounting_System <> P2.mdUse_Accounting_System) then begin
    P3.mdUse_Accounting_System := P1.mdUse_Accounting_System;
    ChangedFields[i] := tkmdUse_Accounting_System;
    Inc(i);
  end;
  if (P1.mdAccounting_System <> P2.mdAccounting_System) then begin
    P3.mdAccounting_System := P1.mdAccounting_System;
    ChangedFields[i] := tkmdAccounting_System;
    Inc(i);
  end;
  if (P1.mdFrom_Date <> P2.mdFrom_Date) then begin
    P3.mdFrom_Date := P1.mdFrom_Date;
    ChangedFields[i] := tkmdFrom_Date;
    Inc(i);
  end;
  if (P1.mdUntil_Date <> P2.mdUntil_Date) then begin
    P3.mdUntil_Date := P1.mdUntil_Date;
    ChangedFields[i] := tkmdUntil_Date;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Memorisation_Detail_Rec(P1, P2: pMemorisation_Detail_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Memorisation_Detail_Rec(P1^, S);
    S.Position := 0;
    Read_Memorisation_Detail_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
