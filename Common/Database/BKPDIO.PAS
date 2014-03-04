UNIT BKpdIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Payee_Detail                 = 90 ;
   tkEnd_Payee_Detail                   = 91 ;

FUNCTION  IsAPayee_Detail_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Payee_Detail_Rec ( Var O : TPayee_Detail_Rec ; Var F : TIOStream );
PROCEDURE Read_Payee_Detail_Rec ( Var O : TPayee_Detail_Rec ; Var F : TIOStream );
FUNCTION  New_Payee_Detail_Rec : pPayee_Detail_Rec ;
PROCEDURE Free_Payee_Detail_Rec_Dynamic_Fields ( Var O : TPayee_Detail_Rec );
FUNCTION Payee_Detail_Rec_Delta(P1, P2, P3: pPayee_Detail_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Payee_Detail_Rec(P1, P2: pPayee_Detail_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKPDIO';
   SBoundsError        = 'BKPDIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKPDIO Error: Pointer is NIL in IsAPayee_Detail_Rec';
   SInvalidType        = 'BKPDIO Error: Type is invalid in IsAPayee_Detail_Rec';
   SInvalidEOR         = 'BKPDIO Error: EOR is missing in IsAPayee_Detail_Rec';
   SUnknownToken       = 'BKPDIO Error: Unknown token %d in Read_Payee_Detail_Rec';
   SInsufficientMemory = 'BKPDIO Error: Out of memory in New_Payee_Detail_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkpdNumber                           = 92 ;
   tkpdName                             = 93 ;
   tkpdAudit_Record_ID                  = 94 ;
   tkpdContractor                       = 95 ;
   tkpdSurname                          = 96 ;
   tkpdGiven_Name                       = 97 ;
   tkpdOther_Name                       = 98 ;
   tkpdAddress                          = 99 ;
   tkpdTown                             = 100 ;
   tkpdState                            = 101 ;
   tkpdPost_Code                        = 102 ;
   tkpdPhone_Number                     = 103 ;
   tkpdABN                              = 104 ;
   tkpdBusinessName                     = 105 ;
   tkpdTradingName                      = 106 ;
   tkpdCountry                          = 107 ;
   tkpdInstitutionBSB                   = 108 ;
   tkpdInstitutionAccountNumber         = 109 ;
   tkpdIsIndividual                     = 110 ;
   tkpdAddressLine2                     = 111 ;
   tkpdStateId                          = 112 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAPayee_Detail_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PPayee_Detail_Rec ( P )^ do Begin
      If pdRecord_Type <> tkBegin_Payee_Detail then
         Raise ECorruptData.Create( SInvalidType );
      If pdEOR <> tkEnd_Payee_Detail then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Payee_Detail_Rec ( Var O : TPayee_Detail_Rec ; Var F : TIOStream );

Begin
   If IsAPayee_Detail_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Payee_Detail );
      F.WriteIntegerValue( tkpdNumber , pdNumber );
      F.WriteStringValue( tkpdName , pdName );
      F.WriteIntegerValue( tkpdAudit_Record_ID , pdAudit_Record_ID );
      F.WriteBooleanValue( tkpdContractor , pdContractor );
      F.WriteStringValue( tkpdSurname , pdSurname );
      F.WriteStringValue( tkpdGiven_Name , pdGiven_Name );
      F.WriteStringValue( tkpdOther_Name , pdOther_Name );
      F.WriteStringValue( tkpdAddress , pdAddress );
      F.WriteStringValue( tkpdTown , pdTown );
      F.WriteStringValue( tkpdState , pdState );
      F.WriteStringValue( tkpdPost_Code , pdPost_Code );
      F.WriteStringValue( tkpdPhone_Number , pdPhone_Number );
      F.WriteStringValue( tkpdABN , pdABN );
      F.WriteStringValue( tkpdBusinessName , pdBusinessName );
      F.WriteStringValue( tkpdTradingName , pdTradingName );
      F.WriteStringValue( tkpdCountry , pdCountry );
      F.WriteStringValue( tkpdInstitutionBSB , pdInstitutionBSB );
      F.WriteStringValue( tkpdInstitutionAccountNumber , pdInstitutionAccountNumber );
      F.WriteBooleanValue( tkpdIsIndividual , pdIsIndividual );
      F.WriteStringValue( tkpdAddressLine2 , pdAddressLine2 );
      F.WriteIntegerValue( tkpdStateId , pdStateId );
      F.WriteToken( tkEnd_Payee_Detail );
   end;
end; { of Write_Payee_Detail_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Payee_Detail_Rec ( Var O : TPayee_Detail_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Payee_Detail_Rec_Size, 0 );
   O.pdRecord_Type := tkBegin_Payee_Detail;
   O.pdEOR := tkEnd_Payee_Detail;
   Token := tkBegin_Payee_Detail;

   While Token <> tkEnd_Payee_Detail do With O do
   Begin
      Case Token of
         tkBegin_Payee_Detail :; { Do Nothing }
         tkEnd_Payee_Detail :; { Do Nothing }
         tkpdNumber                           : pdNumber := F.ReadIntegerValue;
         tkpdName                             : pdName := F.ReadStringValue;
         tkpdAudit_Record_ID                  : pdAudit_Record_ID := F.ReadIntegerValue;
         tkpdContractor                       : pdContractor := F.ReadBooleanValue;
         tkpdSurname                          : pdSurname := F.ReadStringValue;
         tkpdGiven_Name                       : pdGiven_Name := F.ReadStringValue;
         tkpdOther_Name                       : pdOther_Name := F.ReadStringValue;
         tkpdAddress                          : pdAddress := F.ReadStringValue;
         tkpdTown                             : pdTown := F.ReadStringValue;
         tkpdState                            : pdState := F.ReadStringValue;
         tkpdPost_Code                        : pdPost_Code := F.ReadStringValue;
         tkpdPhone_Number                     : pdPhone_Number := F.ReadStringValue;
         tkpdABN                              : pdABN := F.ReadStringValue;
         tkpdBusinessName                     : pdBusinessName := F.ReadStringValue;
         tkpdTradingName                      : pdTradingName := F.ReadStringValue;
         tkpdCountry                          : pdCountry := F.ReadStringValue;
         tkpdInstitutionBSB                   : pdInstitutionBSB := F.ReadStringValue;
         tkpdInstitutionAccountNumber         : pdInstitutionAccountNumber := F.ReadStringValue;
         tkpdIsIndividual                     : pdIsIndividual := F.ReadBooleanValue;
         tkpdAddressLine2                     : pdAddressLine2 := F.ReadStringValue;
         tkpdStateId                          : pdStateId := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Payee_Detail_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Payee_Detail_Rec : pPayee_Detail_Rec ;

Var
   P : pPayee_Detail_Rec;
Begin
   SafeGetMem( P, Payee_Detail_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Payee_Detail_Rec_Size, 0 );
      pdRecord_Type := tkBegin_Payee_Detail;
      pdEOR         := tkEnd_Payee_Detail;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Payee_Detail_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Payee_Detail_Rec_Dynamic_Fields ( Var O : TPayee_Detail_Rec );

Begin
   If IsAPayee_Detail_Rec ( @O ) then With O do
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
  for i := tkpdNumber to tkpdStateId do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Payee_Detail_Rec_Delta(P1, P2, P3: pPayee_Detail_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Payee_Detail_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.pdNumber <> P2.pdNumber) then begin
    P3.pdNumber := P1.pdNumber;
    ChangedFields[i] := tkpdNumber;
    Inc(i);
  end;
  if (P1.pdName <> P2.pdName) then begin
    P3.pdName := P1.pdName;
    ChangedFields[i] := tkpdName;
    Inc(i);
  end;
  if (P1.pdAudit_Record_ID <> P2.pdAudit_Record_ID) then begin
    P3.pdAudit_Record_ID := P1.pdAudit_Record_ID;
    ChangedFields[i] := tkpdAudit_Record_ID;
    Inc(i);
  end;
  if (P1.pdContractor <> P2.pdContractor) then begin
    P3.pdContractor := P1.pdContractor;
    ChangedFields[i] := tkpdContractor;
    Inc(i);
  end;
  if (P1.pdSurname <> P2.pdSurname) then begin
    P3.pdSurname := P1.pdSurname;
    ChangedFields[i] := tkpdSurname;
    Inc(i);
  end;
  if (P1.pdGiven_Name <> P2.pdGiven_Name) then begin
    P3.pdGiven_Name := P1.pdGiven_Name;
    ChangedFields[i] := tkpdGiven_Name;
    Inc(i);
  end;
  if (P1.pdOther_Name <> P2.pdOther_Name) then begin
    P3.pdOther_Name := P1.pdOther_Name;
    ChangedFields[i] := tkpdOther_Name;
    Inc(i);
  end;
  if (P1.pdAddress <> P2.pdAddress) then begin
    P3.pdAddress := P1.pdAddress;
    ChangedFields[i] := tkpdAddress;
    Inc(i);
  end;
  if (P1.pdTown <> P2.pdTown) then begin
    P3.pdTown := P1.pdTown;
    ChangedFields[i] := tkpdTown;
    Inc(i);
  end;
  if (P1.pdState <> P2.pdState) then begin
    P3.pdState := P1.pdState;
    ChangedFields[i] := tkpdState;
    Inc(i);
  end;
  if (P1.pdPost_Code <> P2.pdPost_Code) then begin
    P3.pdPost_Code := P1.pdPost_Code;
    ChangedFields[i] := tkpdPost_Code;
    Inc(i);
  end;
  if (P1.pdPhone_Number <> P2.pdPhone_Number) then begin
    P3.pdPhone_Number := P1.pdPhone_Number;
    ChangedFields[i] := tkpdPhone_Number;
    Inc(i);
  end;
  if (P1.pdABN <> P2.pdABN) then begin
    P3.pdABN := P1.pdABN;
    ChangedFields[i] := tkpdABN;
    Inc(i);
  end;
  if (P1.pdBusinessName <> P2.pdBusinessName) then begin
    P3.pdBusinessName := P1.pdBusinessName;
    ChangedFields[i] := tkpdBusinessName;
    Inc(i);
  end;
  if (P1.pdTradingName <> P2.pdTradingName) then begin
    P3.pdTradingName := P1.pdTradingName;
    ChangedFields[i] := tkpdTradingName;
    Inc(i);
  end;
  if (P1.pdCountry <> P2.pdCountry) then begin
    P3.pdCountry := P1.pdCountry;
    ChangedFields[i] := tkpdCountry;
    Inc(i);
  end;
  if (P1.pdInstitutionBSB <> P2.pdInstitutionBSB) then begin
    P3.pdInstitutionBSB := P1.pdInstitutionBSB;
    ChangedFields[i] := tkpdInstitutionBSB;
    Inc(i);
  end;
  if (P1.pdInstitutionAccountNumber <> P2.pdInstitutionAccountNumber) then begin
    P3.pdInstitutionAccountNumber := P1.pdInstitutionAccountNumber;
    ChangedFields[i] := tkpdInstitutionAccountNumber;
    Inc(i);
  end;
  if (P1.pdIsIndividual <> P2.pdIsIndividual) then begin
    P3.pdIsIndividual := P1.pdIsIndividual;
    ChangedFields[i] := tkpdIsIndividual;
    Inc(i);
  end;
  if (P1.pdAddressLine2 <> P2.pdAddressLine2) then begin
    P3.pdAddressLine2 := P1.pdAddressLine2;
    ChangedFields[i] := tkpdAddressLine2;
    Inc(i);
  end;
  if (P1.pdStateId <> P2.pdStateId) then begin
    P3.pdStateId := P1.pdStateId;
    ChangedFields[i] := tkpdStateId;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Payee_Detail_Rec(P1, P2: pPayee_Detail_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Payee_Detail_Rec(P1^, S);
    S.Position := 0;
    Read_Payee_Detail_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
