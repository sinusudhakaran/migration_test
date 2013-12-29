UNIT BKmxIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Memorised_Transaction        = 220 ;
   tkEnd_Memorised_Transaction          = 221 ;

FUNCTION  IsAMemorised_Transaction_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Memorised_Transaction_Rec ( Var O : TMemorised_Transaction_Rec ; Var F : TIOStream );
PROCEDURE Read_Memorised_Transaction_Rec ( Var O : TMemorised_Transaction_Rec ; Var F : TIOStream );
FUNCTION  New_Memorised_Transaction_Rec : pMemorised_Transaction_Rec ;
PROCEDURE Free_Memorised_Transaction_Rec_Dynamic_Fields ( Var O : TMemorised_Transaction_Rec );
FUNCTION Memorised_Transaction_Rec_Delta(P1, P2, P3: pMemorised_Transaction_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Memorised_Transaction_Rec(P1, P2: pMemorised_Transaction_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKMXIO';
   SBoundsError        = 'BKMXIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKMXIO Error: Pointer is NIL in IsAMemorised_Transaction_Rec';
   SInvalidType        = 'BKMXIO Error: Type is invalid in IsAMemorised_Transaction_Rec';
   SInvalidEOR         = 'BKMXIO Error: EOR is missing in IsAMemorised_Transaction_Rec';
   SUnknownToken       = 'BKMXIO Error: Unknown token %d in Read_Memorised_Transaction_Rec';
   SInsufficientMemory = 'BKMXIO Error: Out of memory in New_Memorised_Transaction_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkmxSequence_No                      = 222 ;
   tkmxType                             = 223 ;
   tkmxAmount                           = 224 ;
   tkmxReference                        = 225 ;
   tkmxParticulars                      = 226 ;
   tkmxAnalysis                         = 227 ;
   tkmxOther_Party                      = 228 ;
   tkmxStatement_Details                = 229 ;
   tkmxMatch_on_Amount                  = 230 ;
   tkmxMatch_on_Refce                   = 231 ;
   tkmxMatch_on_Particulars             = 232 ;
   tkmxMatch_on_Analysis                = 233 ;
   tkmxMatch_on_Other_Party             = 234 ;
   tkmxMatch_On_Statement_Details       = 235 ;
   tkmxAccount                          = 236 ;
   tkmxPercentage                       = 237 ;
   tkmxGST_Class                        = 238 ;
   tkmxPayee_Number                     = 239 ;
   tkmxFrom_Master_List                 = 240 ;
   tkmxGST_Has_Been_Edited              = 241 ;
   tkmxMatch_on_Notes                   = 242 ;
   tkmxNotes                            = 243 ;
   tkmxGL_Narration                     = 244 ;
   tkmxLine_Type                        = 245 ;
   tkmxAudit_Record_ID                  = 246 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAMemorised_Transaction_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PMemorised_Transaction_Rec ( P )^ do Begin
      If mxRecord_Type <> tkBegin_Memorised_Transaction then
         Raise ECorruptData.Create( SInvalidType );
      If mxEOR <> tkEnd_Memorised_Transaction then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Memorised_Transaction_Rec ( Var O : TMemorised_Transaction_Rec ; Var F : TIOStream );

Var
   I     : Byte;

Begin
   If IsAMemorised_Transaction_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Memorised_Transaction );
      F.WriteIntegerValue( tkmxSequence_No , mxSequence_No );
      F.WriteByteValue( tkmxType , mxType );
      F.WriteMoneyValue( tkmxAmount , mxAmount );
      F.WriteStringValue( tkmxReference , mxReference );
      F.WriteStringValue( tkmxParticulars , mxParticulars );
      F.WriteStringValue( tkmxAnalysis , mxAnalysis );
      F.WriteStringValue( tkmxOther_Party , mxOther_Party );
      F.WriteStringValue( tkmxStatement_Details , mxStatement_Details );
      F.WriteByteValue( tkmxMatch_on_Amount , mxMatch_on_Amount );
      F.WriteBooleanValue( tkmxMatch_on_Refce , mxMatch_on_Refce );
      F.WriteBooleanValue( tkmxMatch_on_Particulars , mxMatch_on_Particulars );
      F.WriteBooleanValue( tkmxMatch_on_Analysis , mxMatch_on_Analysis );
      F.WriteBooleanValue( tkmxMatch_on_Other_Party , mxMatch_on_Other_Party );
      F.WriteBooleanValue( tkmxMatch_On_Statement_Details , mxMatch_On_Statement_Details );
      For i := 1 to 50 do F.WriteBStringValue( tkmxAccount , i, mxAccount[ i ] );
      For i := 1 to 50 do F.WriteBMoneyValue( tkmxPercentage , i, mxPercentage[ i ] );
      For i := 1 to 50 do F.WriteBByteValue( tkmxGST_Class , i, mxGST_Class[ i ] );
      F.WriteIntegerValue( tkmxPayee_Number , mxPayee_Number );
      F.WriteBooleanValue( tkmxFrom_Master_List , mxFrom_Master_List );
      For i := 1 to 50 do F.WriteBBooleanValue( tkmxGST_Has_Been_Edited , i, mxGST_Has_Been_Edited[ i ] );
      F.WriteBooleanValue( tkmxMatch_on_Notes , mxMatch_on_Notes );
      F.WriteStringValue( tkmxNotes , mxNotes );
      For i := 1 to 50 do F.WriteBStringValue( tkmxGL_Narration , i, mxGL_Narration[ i ] );
      For i := 1 to 50 do F.WriteBByteValue( tkmxLine_Type , i, mxLine_Type[ i ] );
      F.WriteIntegerValue( tkmxAudit_Record_ID , mxAudit_Record_ID );
      F.WriteToken( tkEnd_Memorised_Transaction );
   end;
end; { of Write_Memorised_Transaction_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Memorised_Transaction_Rec ( Var O : TMemorised_Transaction_Rec; Var F : TIOStream );

Var
   Token : Byte;
   I     : Byte;
   M     : Money;
   B     : Byte;   
   Y     : Boolean;
   S     : ShortString;

Begin
   FillChar( O, Memorised_Transaction_Rec_Size, 0 );
   O.mxRecord_Type := tkBegin_Memorised_Transaction;
   O.mxEOR := tkEnd_Memorised_Transaction;
   Token := tkBegin_Memorised_Transaction;

   While Token <> tkEnd_Memorised_Transaction do With O do
   Begin
      Case Token of
         tkBegin_Memorised_Transaction :; { Do Nothing }
         tkEnd_Memorised_Transaction :; { Do Nothing }
         tkmxSequence_No                      : mxSequence_No := F.ReadIntegerValue;
         tkmxType                             : mxType := F.ReadByteValue;
         tkmxAmount                           : mxAmount := F.ReadMoneyValue;
         tkmxReference                        : mxReference := F.ReadStringValue;
         tkmxParticulars                      : mxParticulars := F.ReadStringValue;
         tkmxAnalysis                         : mxAnalysis := F.ReadStringValue;
         tkmxOther_Party                      : mxOther_Party := F.ReadStringValue;
         tkmxStatement_Details                : mxStatement_Details := F.ReadStringValue;
         tkmxMatch_on_Amount                  : mxMatch_on_Amount := F.ReadByteValue;
         tkmxMatch_on_Refce                   : mxMatch_on_Refce := F.ReadBooleanValue;
         tkmxMatch_on_Particulars             : mxMatch_on_Particulars := F.ReadBooleanValue;
         tkmxMatch_on_Analysis                : mxMatch_on_Analysis := F.ReadBooleanValue;
         tkmxMatch_on_Other_Party             : mxMatch_on_Other_Party := F.ReadBooleanValue;
         tkmxMatch_On_Statement_Details       : mxMatch_On_Statement_Details := F.ReadBooleanValue;
         tkmxAccount                          : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 50, 'mxAccount' );
               mxAccount[ I ] := S;
            end;
         tkmxPercentage                       : 
            Begin
               M := F.ReadBMoneyValue( I );
               CheckBounds( I, 1, 50, 'mxPercentage' );
               mxPercentage[ I ] := M;
            end;
         tkmxGST_Class                        : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 50, 'mxGST_Class' );
               mxGST_Class[ I ] := B;
            end;
         tkmxPayee_Number                     : mxPayee_Number := F.ReadIntegerValue;
         tkmxFrom_Master_List                 : mxFrom_Master_List := F.ReadBooleanValue;
         tkmxGST_Has_Been_Edited              : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 1, 50, 'mxGST_Has_Been_Edited' );
               mxGST_Has_Been_Edited[ I ] := Y;
            end;
         tkmxMatch_on_Notes                   : mxMatch_on_Notes := F.ReadBooleanValue;
         tkmxNotes                            : mxNotes := F.ReadStringValue;
         tkmxGL_Narration                     : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 50, 'mxGL_Narration' );
               mxGL_Narration[ I ] := S;
            end;
         tkmxLine_Type                        : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 50, 'mxLine_Type' );
               mxLine_Type[ I ] := B;
            end;
         tkmxAudit_Record_ID                  : mxAudit_Record_ID := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Memorised_Transaction_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Memorised_Transaction_Rec : pMemorised_Transaction_Rec ;

Var
   P : pMemorised_Transaction_Rec;
Begin
   SafeGetMem( P, Memorised_Transaction_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Memorised_Transaction_Rec_Size, 0 );
      mxRecord_Type := tkBegin_Memorised_Transaction;
      mxEOR         := tkEnd_Memorised_Transaction;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Memorised_Transaction_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Memorised_Transaction_Rec_Dynamic_Fields ( Var O : TMemorised_Transaction_Rec );

Begin
   If IsAMemorised_Transaction_Rec ( @O ) then With O do
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
  for i := tkmxSequence_No to tkmxAudit_Record_ID do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Memorised_Transaction_Rec_Delta(P1, P2, P3: pMemorised_Transaction_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Memorised_Transaction_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.mxSequence_No <> P2.mxSequence_No) then begin
    P3.mxSequence_No := P1.mxSequence_No;
    ChangedFields[i] := tkmxSequence_No;
    Inc(i);
  end;
  if (P1.mxType <> P2.mxType) then begin
    P3.mxType := P1.mxType;
    ChangedFields[i] := tkmxType;
    Inc(i);
  end;
  if (P1.mxAmount <> P2.mxAmount) then begin
    P3.mxAmount := P1.mxAmount;
    ChangedFields[i] := tkmxAmount;
    Inc(i);
  end;
  if (P1.mxReference <> P2.mxReference) then begin
    P3.mxReference := P1.mxReference;
    ChangedFields[i] := tkmxReference;
    Inc(i);
  end;
  if (P1.mxParticulars <> P2.mxParticulars) then begin
    P3.mxParticulars := P1.mxParticulars;
    ChangedFields[i] := tkmxParticulars;
    Inc(i);
  end;
  if (P1.mxAnalysis <> P2.mxAnalysis) then begin
    P3.mxAnalysis := P1.mxAnalysis;
    ChangedFields[i] := tkmxAnalysis;
    Inc(i);
  end;
  if (P1.mxOther_Party <> P2.mxOther_Party) then begin
    P3.mxOther_Party := P1.mxOther_Party;
    ChangedFields[i] := tkmxOther_Party;
    Inc(i);
  end;
  if (P1.mxStatement_Details <> P2.mxStatement_Details) then begin
    P3.mxStatement_Details := P1.mxStatement_Details;
    ChangedFields[i] := tkmxStatement_Details;
    Inc(i);
  end;
  if (P1.mxMatch_on_Amount <> P2.mxMatch_on_Amount) then begin
    P3.mxMatch_on_Amount := P1.mxMatch_on_Amount;
    ChangedFields[i] := tkmxMatch_on_Amount;
    Inc(i);
  end;
  if (P1.mxMatch_on_Refce <> P2.mxMatch_on_Refce) then begin
    P3.mxMatch_on_Refce := P1.mxMatch_on_Refce;
    ChangedFields[i] := tkmxMatch_on_Refce;
    Inc(i);
  end;
  if (P1.mxMatch_on_Particulars <> P2.mxMatch_on_Particulars) then begin
    P3.mxMatch_on_Particulars := P1.mxMatch_on_Particulars;
    ChangedFields[i] := tkmxMatch_on_Particulars;
    Inc(i);
  end;
  if (P1.mxMatch_on_Analysis <> P2.mxMatch_on_Analysis) then begin
    P3.mxMatch_on_Analysis := P1.mxMatch_on_Analysis;
    ChangedFields[i] := tkmxMatch_on_Analysis;
    Inc(i);
  end;
  if (P1.mxMatch_on_Other_Party <> P2.mxMatch_on_Other_Party) then begin
    P3.mxMatch_on_Other_Party := P1.mxMatch_on_Other_Party;
    ChangedFields[i] := tkmxMatch_on_Other_Party;
    Inc(i);
  end;
  if (P1.mxMatch_On_Statement_Details <> P2.mxMatch_On_Statement_Details) then begin
    P3.mxMatch_On_Statement_Details := P1.mxMatch_On_Statement_Details;
    ChangedFields[i] := tkmxMatch_On_Statement_Details;
    Inc(i);
  end;
  if Account_Changed(TAccount_Array(P1.mxAccount), 
                  TAccount_Array(P2.mxAccount), 
                  TAccount_Array(P3.mxAccount)) then begin
    ChangedFields[i] := tkmxAccount;
    Inc(i);
  end;
  if Percentage_Changed(TPercentage_Array(P1.mxPercentage), 
                  TPercentage_Array(P2.mxPercentage), 
                  TPercentage_Array(P3.mxPercentage)) then begin
    ChangedFields[i] := tkmxPercentage;
    Inc(i);
  end;
  if GST_Class_Changed(TGST_Class_Array(P1.mxGST_Class), 
                  TGST_Class_Array(P2.mxGST_Class), 
                  TGST_Class_Array(P3.mxGST_Class)) then begin
    ChangedFields[i] := tkmxGST_Class;
    Inc(i);
  end;
  if (P1.mxPayee_Number <> P2.mxPayee_Number) then begin
    P3.mxPayee_Number := P1.mxPayee_Number;
    ChangedFields[i] := tkmxPayee_Number;
    Inc(i);
  end;
  if (P1.mxFrom_Master_List <> P2.mxFrom_Master_List) then begin
    P3.mxFrom_Master_List := P1.mxFrom_Master_List;
    ChangedFields[i] := tkmxFrom_Master_List;
    Inc(i);
  end;
  if GST_Has_Been_Edited_Changed(TGST_Has_Been_Edited_Array(P1.mxGST_Has_Been_Edited), 
                  TGST_Has_Been_Edited_Array(P2.mxGST_Has_Been_Edited), 
                  TGST_Has_Been_Edited_Array(P3.mxGST_Has_Been_Edited)) then begin
    ChangedFields[i] := tkmxGST_Has_Been_Edited;
    Inc(i);
  end;
  if (P1.mxMatch_on_Notes <> P2.mxMatch_on_Notes) then begin
    P3.mxMatch_on_Notes := P1.mxMatch_on_Notes;
    ChangedFields[i] := tkmxMatch_on_Notes;
    Inc(i);
  end;
  if (P1.mxNotes <> P2.mxNotes) then begin
    P3.mxNotes := P1.mxNotes;
    ChangedFields[i] := tkmxNotes;
    Inc(i);
  end;
  if GL_Narration_Changed(TGL_Narration_Array(P1.mxGL_Narration), 
                  TGL_Narration_Array(P2.mxGL_Narration), 
                  TGL_Narration_Array(P3.mxGL_Narration)) then begin
    ChangedFields[i] := tkmxGL_Narration;
    Inc(i);
  end;
  if Line_Type_Changed(TLine_Type_Array(P1.mxLine_Type), 
                  TLine_Type_Array(P2.mxLine_Type), 
                  TLine_Type_Array(P3.mxLine_Type)) then begin
    ChangedFields[i] := tkmxLine_Type;
    Inc(i);
  end;
  if (P1.mxAudit_Record_ID <> P2.mxAudit_Record_ID) then begin
    P3.mxAudit_Record_ID := P1.mxAudit_Record_ID;
    ChangedFields[i] := tkmxAudit_Record_ID;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Memorised_Transaction_Rec(P1, P2: pMemorised_Transaction_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Memorised_Transaction_Rec(P1^, S);
    S.Position := 0;
    Read_Memorised_Transaction_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
