UNIT SYatIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Audit_Trail                  = 130 ;
   tkEnd_Audit_Trail                    = 131 ;

FUNCTION  IsAAudit_Trail_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Audit_Trail_Rec ( Var O : TAudit_Trail_Rec ; Var F : TIOStream );
PROCEDURE Read_Audit_Trail_Rec ( Var O : TAudit_Trail_Rec ; Var F : TIOStream );
FUNCTION  New_Audit_Trail_Rec : pAudit_Trail_Rec ;
PROCEDURE Free_Audit_Trail_Rec_Dynamic_Fields ( Var O : TAudit_Trail_Rec );
function Audit_Trail_Rec_Delta(P1, P2, P3: pAudit_Trail_Rec): boolean;
procedure Copy_Audit_Trail_Rec(P1, P2: pAudit_Trail_Rec);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT, SYAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'SYATIO';
   SBoundsError        = 'SYATIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'SYATIO Error: Pointer is NIL in IsAAudit_Trail_Rec';
   SInvalidType        = 'SYATIO Error: Type is invalid in IsAAudit_Trail_Rec';
   SInvalidEOR         = 'SYATIO Error: EOR is missing in IsAAudit_Trail_Rec';
   SUnknownToken       = 'SYATIO Error: Unknown token %d in Read_Audit_Trail_Rec';
   SInsufficientMemory = 'SYATIO Error: Out of memory in New_Audit_Trail_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkatAudit_ID                         = 132 ;
   tkatTransaction_Type                 = 133 ;
   tkatAudit_Action                     = 134 ;
   tkatDate_Time                        = 135 ;
   tkatUser_Code                        = 136 ;
   tkatRecord_ID                        = 137 ;
   tkatParent_ID                        = 138 ;
   tkatAudit_Record_Type                = 139 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAAudit_Trail_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PAudit_Trail_Rec ( P )^ do Begin
      If atRecord_Type <> tkBegin_Audit_Trail then
         Raise ECorruptData.Create( SInvalidType );
      If atEOR <> tkEnd_Audit_Trail then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Audit_Trail_Rec ( Var O : TAudit_Trail_Rec ; Var F : TIOStream );

Begin
   If IsAAudit_Trail_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Audit_Trail );
      F.WriteIntegerValue( tkatAudit_ID , atAudit_ID );
      F.WriteByteValue( tkatTransaction_Type , atTransaction_Type );
      F.WriteByteValue( tkatAudit_Action , atAudit_Action );
      F.WriteDateTimeValue( tkatDate_Time , atDate_Time );
      F.WriteStringValue( tkatUser_Code , atUser_Code );
      F.WriteIntegerValue( tkatRecord_ID , atRecord_ID );
      F.WriteIntegerValue( tkatParent_ID , atParent_ID );
      F.WriteByteValue( tkatAudit_Record_Type , atAudit_Record_Type );
      F.WriteToken( tkEnd_Audit_Trail );
   end;
end; { of Write_Audit_Trail_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Audit_Trail_Rec ( Var O : TAudit_Trail_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Audit_Trail_Rec_Size, 0 );
   O.atRecord_Type := tkBegin_Audit_Trail;
   O.atEOR := tkEnd_Audit_Trail;
   Token := tkBegin_Audit_Trail;

   While Token <> tkEnd_Audit_Trail do With O do
   Begin
      Case Token of
         tkBegin_Audit_Trail :; { Do Nothing }
         tkEnd_Audit_Trail :; { Do Nothing }
         tkatAudit_ID                         : atAudit_ID := F.ReadIntegerValue;
         tkatTransaction_Type                 : atTransaction_Type := F.ReadByteValue;
         tkatAudit_Action                     : atAudit_Action := F.ReadByteValue;
         tkatDate_Time                        : atDate_Time := F.ReadDateTimeValue;
         tkatUser_Code                        : atUser_Code := F.ReadStringValue;
         tkatRecord_ID                        : atRecord_ID := F.ReadIntegerValue;
         tkatParent_ID                        : atParent_ID := F.ReadIntegerValue;
         tkatAudit_Record_Type                : atAudit_Record_Type := F.ReadByteValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Audit_Trail_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Audit_Trail_Rec : pAudit_Trail_Rec ;

Var
   P : pAudit_Trail_Rec;
Begin
   SafeGetMem( P, Audit_Trail_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Audit_Trail_Rec_Size, 0 );
      atRecord_Type := tkBegin_Audit_Trail;
      atEOR         := tkEnd_Audit_Trail;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Audit_Trail_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Audit_Trail_Rec_Dynamic_Fields ( Var O : TAudit_Trail_Rec );

Begin
   If IsAAudit_Trail_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

Function Audit_Trail_Rec_Delta(P1, P2, P3: pAudit_Trail_Rec): boolean;
begin
  Result := False;

  //Add
  if not Assigned(P2) then begin
    Copy_Audit_Trail_Rec(P1, P3);
    Result := True;
    Exit;
  end;

  //Change
  if (P1.atAudit_ID <> P2.atAudit_ID) then begin
    Result := true;
    P3.atAudit_ID := P1.atAudit_ID;
  end;
  if (P1.atTransaction_Type <> P2.atTransaction_Type) then begin
    Result := true;
    P3.atTransaction_Type := P1.atTransaction_Type;
  end;
  if (P1.atAudit_Action <> P2.atAudit_Action) then begin
    Result := true;
    P3.atAudit_Action := P1.atAudit_Action;
  end;
  if (P1.atDate_Time <> P2.atDate_Time) then begin
    Result := true;
    P3.atDate_Time := P1.atDate_Time;
  end;
  if (P1.atUser_Code <> P2.atUser_Code) then begin
    Result := true;
    P3.atUser_Code := P1.atUser_Code;
  end;
  if (P1.atRecord_ID <> P2.atRecord_ID) then begin
    Result := true;
    P3.atRecord_ID := P1.atRecord_ID;
  end;
  if (P1.atParent_ID <> P2.atParent_ID) then begin
    Result := true;
    P3.atParent_ID := P1.atParent_ID;
  end;
  if (P1.atAudit_Record_Type <> P2.atAudit_Record_Type) then begin
    Result := true;
    P3.atAudit_Record_Type := P1.atAudit_Record_Type;
  end;

end;

{  -------------------------------------------------------------------  }

procedure Copy_Audit_Trail_Rec(P1, P2: pAudit_Trail_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Audit_Trail_Rec(P1^, S);
    S.Position := 0;
    Read_Audit_Trail_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
