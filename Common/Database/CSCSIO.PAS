UNIT CScsIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES CSDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Coding_Statistics            = 10 ;
   tkEnd_Coding_Statistics              = 11 ;

FUNCTION  IsACoding_Statistics_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Coding_Statistics_Rec ( Var O : TCoding_Statistics_Rec ; Var F : TIOStream );
PROCEDURE Read_Coding_Statistics_Rec ( Var O : TCoding_Statistics_Rec ; Var F : TIOStream );
FUNCTION  New_Coding_Statistics_Rec : pCoding_Statistics_Rec ;
PROCEDURE Free_Coding_Statistics_Rec_Dynamic_Fields ( Var O : TCoding_Statistics_Rec );

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

END.
