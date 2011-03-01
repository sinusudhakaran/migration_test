UNIT BKbuIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Budget_Header                = 110 ;
   tkEnd_Budget_Header                  = 111 ;

FUNCTION  IsABudget_Header_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Budget_Header_Rec ( Var O : TBudget_Header_Rec ; Var F : TIOStream );
PROCEDURE Read_Budget_Header_Rec ( Var O : TBudget_Header_Rec ; Var F : TIOStream );
FUNCTION  New_Budget_Header_Rec : pBudget_Header_Rec ;
PROCEDURE Free_Budget_Header_Rec_Dynamic_Fields ( Var O : TBudget_Header_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKBUIO';
   SBoundsError        = 'BKBUIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKBUIO Error: Pointer is NIL in IsABudget_Header_Rec';
   SInvalidType        = 'BKBUIO Error: Type is invalid in IsABudget_Header_Rec';
   SInvalidEOR         = 'BKBUIO Error: EOR is missing in IsABudget_Header_Rec';
   SUnknownToken       = 'BKBUIO Error: Unknown token %d in Read_Budget_Header_Rec';
   SInsufficientMemory = 'BKBUIO Error: Out of memory in New_Budget_Header_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkbuStart_Date                       = 112 ;
   tkbuName                             = 113 ;
   tkbuEstimated_Opening_Bank_Balance   = 114 ;
   tkbuIs_Inclusive                     = 115 ;

{  -------------------------------------------------------------------  }

FUNCTION IsABudget_Header_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PBudget_Header_Rec ( P )^ do Begin
      If buRecord_Type <> tkBegin_Budget_Header then
         Raise ECorruptData.Create( SInvalidType );
      If buEOR <> tkEnd_Budget_Header then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Budget_Header_Rec ( Var O : TBudget_Header_Rec ; Var F : TIOStream );

Begin
   If IsABudget_Header_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Budget_Header );
      F.WriteDateValue( tkbuStart_Date , buStart_Date );
      F.WriteStringValue( tkbuName , buName );
      F.WriteMoneyValue( tkbuEstimated_Opening_Bank_Balance , buEstimated_Opening_Bank_Balance );
      F.WriteBooleanValue( tkbuIs_Inclusive , buIs_Inclusive );
      F.WriteToken( tkEnd_Budget_Header );
   end;
end; { of Write_Budget_Header_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Budget_Header_Rec ( Var O : TBudget_Header_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Budget_Header_Rec_Size, 0 );
   O.buRecord_Type := tkBegin_Budget_Header;
   O.buEOR := tkEnd_Budget_Header;
   Token := tkBegin_Budget_Header;

   While Token <> tkEnd_Budget_Header do With O do
   Begin
      Case Token of
         tkBegin_Budget_Header :; { Do Nothing }
         tkEnd_Budget_Header :; { Do Nothing }
         tkbuStart_Date                       : buStart_Date := F.ReadDateValue;
         tkbuName                             : buName := F.ReadStringValue;
         tkbuEstimated_Opening_Bank_Balance   : buEstimated_Opening_Bank_Balance := F.ReadMoneyValue;
         tkbuIs_Inclusive                     : buIs_Inclusive := F.ReadBooleanValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Budget_Header_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Budget_Header_Rec : pBudget_Header_Rec ;

Var
   P : pBudget_Header_Rec;
Begin
   SafeGetMem( P, Budget_Header_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Budget_Header_Rec_Size, 0 );
      buRecord_Type := tkBegin_Budget_Header;
      buEOR         := tkEnd_Budget_Header;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Budget_Header_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Budget_Header_Rec_Dynamic_Fields ( Var O : TBudget_Header_Rec );

Begin
   If IsABudget_Header_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
