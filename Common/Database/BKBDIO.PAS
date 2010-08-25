UNIT BKbdIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Budget_Detail                = 120 ;
   tkEnd_Budget_Detail                  = 121 ;

FUNCTION  IsABudget_Detail_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Budget_Detail_Rec ( Var O : TBudget_Detail_Rec ; Var F : TIOStream );
PROCEDURE Read_Budget_Detail_Rec ( Var O : TBudget_Detail_Rec ; Var F : TIOStream );
FUNCTION  New_Budget_Detail_Rec : pBudget_Detail_Rec ;
PROCEDURE Free_Budget_Detail_Rec_Dynamic_Fields ( Var O : TBudget_Detail_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKBDIO';
   SBoundsError        = 'BKBDIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKBDIO Error: Pointer is NIL in IsABudget_Detail_Rec';
   SInvalidType        = 'BKBDIO Error: Type is invalid in IsABudget_Detail_Rec';
   SInvalidEOR         = 'BKBDIO Error: EOR is missing in IsABudget_Detail_Rec';
   SUnknownToken       = 'BKBDIO Error: Unknown token %d in Read_Budget_Detail_Rec';
   SInsufficientMemory = 'BKBDIO Error: Out of memory in New_Budget_Detail_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkbdAccount_Code                     = 122 ;
   tkbdBudget                           = 123 ;
   tkbdQty_Budget                       = 124 ;
   tkbdEach_Budget                      = 125 ;

{  -------------------------------------------------------------------  }

FUNCTION IsABudget_Detail_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PBudget_Detail_Rec ( P )^ do Begin
      If bdRecord_Type <> tkBegin_Budget_Detail then
         Raise ECorruptData.Create( SInvalidType );
      If bdEOR <> tkEnd_Budget_Detail then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Budget_Detail_Rec ( Var O : TBudget_Detail_Rec ; Var F : TIOStream );

Var
   I     : Byte;

Begin
   If IsABudget_Detail_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Budget_Detail );
      F.WriteStringValue( tkbdAccount_Code , bdAccount_Code );
      For i := 0 to 12 do F.WriteBMoneyValue( tkbdBudget , i, bdBudget[ i ] );
      For i := 0 to 12 do F.WriteBMoneyValue( tkbdQty_Budget , i, bdQty_Budget[ i ] );
      For i := 0 to 12 do F.WriteBMoneyValue( tkbdEach_Budget , i, bdEach_Budget[ i ] );
      F.WriteToken( tkEnd_Budget_Detail );
   end;
end; { of Write_Budget_Detail_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Budget_Detail_Rec ( Var O : TBudget_Detail_Rec; Var F : TIOStream );

Var
   Token : Byte;
   I     : Byte;
   M     : Money;

Begin
   FillChar( O, Budget_Detail_Rec_Size, 0 );
   O.bdRecord_Type := tkBegin_Budget_Detail;
   O.bdEOR := tkEnd_Budget_Detail;
   Token := tkBegin_Budget_Detail;

   While Token <> tkEnd_Budget_Detail do With O do
   Begin
      Case Token of
         tkBegin_Budget_Detail :; { Do Nothing }
         tkEnd_Budget_Detail :; { Do Nothing }
         tkbdAccount_Code                     : bdAccount_Code := F.ReadStringValue;
         tkbdBudget                           : 
            Begin
               M := F.ReadBMoneyValue( I );
               CheckBounds( I, 0, 12, 'bdBudget' );
               bdBudget[ I ] := M;
            end;
         tkbdQty_Budget                       : 
            Begin
               M := F.ReadBMoneyValue( I );
               CheckBounds( I, 0, 12, 'bdQty_Budget' );
               bdQty_Budget[ I ] := M;
            end;
         tkbdEach_Budget                      : 
            Begin
               M := F.ReadBMoneyValue( I );
               CheckBounds( I, 0, 12, 'bdEach_Budget' );
               bdEach_Budget[ I ] := M;
            end;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Budget_Detail_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Budget_Detail_Rec : pBudget_Detail_Rec ;

Var
   P : pBudget_Detail_Rec;
Begin
   SafeGetMem( P, Budget_Detail_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Budget_Detail_Rec_Size, 0 );
      bdRecord_Type := tkBegin_Budget_Detail;
      bdEOR         := tkEnd_Budget_Detail;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Budget_Detail_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Budget_Detail_Rec_Dynamic_Fields ( Var O : TBudget_Detail_Rec );

Begin
   If IsABudget_Detail_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
