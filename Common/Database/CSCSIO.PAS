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

{  -------------------------------------------------------------------  }
Implementation uses MoneyDef, SysUtils, DebugUtils;
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
  Raise Exception.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
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
    Raise Exception.Create( SInvalidPointer );
  With PCoding_Statistics_Rec ( P )^ do Begin
    If csRecord_Type <> tkBegin_Coding_Statistics then
      Raise Exception.Create( SInvalidType );
    If csEOR <> tkEnd_Coding_Statistics then
      Raise Exception.Create( SInvalidEOR );
  end;
  Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Coding_Statistics_Rec ( Var O : TCoding_Statistics_Rec ; Var F : TIOStream );

Begin
  If IsACoding_Statistics_Rec ( @O ) then With O do
  Begin
    F.WriteToken( tkBegin_Coding_Statistics );
      F.WriteLongIntValue( tkcsClient_LRN , csClient_LRN );
      F.WriteDateValue( tkcsMonth , csMonth );
      F.WriteBooleanValue( tkcsUpdated , csUpdated );
      F.WriteLongIntValue( tkcsMemorization_Count , csMemorization_Count );
      F.WriteLongIntValue( tkcsAnalysis_Count , csAnalysis_Count );
      F.WriteLongIntValue( tkcsPayee_Count , csPayee_Count );
      F.WriteLongIntValue( tkcsManual_Count , csManual_Count );
      F.WriteLongIntValue( tkcsUncoded_Count , csUncoded_Count );
      F.WriteLongIntValue( tkcsMaster_Mem_Count , csMaster_Mem_Count );
      F.WriteLongIntValue( tkcsMan_Super_Count , csMan_Super_Count );
      F.WriteLongIntValue( tkcsNotes_Count , csNotes_Count );
      F.WriteLongIntValue( tkcsClient_Files_Sent , csClient_Files_Sent );
      F.WriteLongIntValue( tkcsClient_Files_Received , csClient_Files_Received );
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
      tkcsClient_LRN                       : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) Client_LRN', [ tkcsClient_LRN ] );
          csClient_LRN := F.ReadLongIntValue;
        end;
      tkcsMonth                            : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) Month', [ tkcsMonth ] );
          csMonth := F.ReadDateValue;
        end;
      tkcsUpdated                          : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) Updated', [ tkcsUpdated ] );
          csUpdated := F.ReadBooleanValue;
        end;
      tkcsMemorization_Count               : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) Memorization_Count', [ tkcsMemorization_Count ] );
          csMemorization_Count := F.ReadLongIntValue;
        end;
      tkcsAnalysis_Count                   : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) Analysis_Count', [ tkcsAnalysis_Count ] );
          csAnalysis_Count := F.ReadLongIntValue;
        end;
      tkcsPayee_Count                      : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) Payee_Count', [ tkcsPayee_Count ] );
          csPayee_Count := F.ReadLongIntValue;
        end;
      tkcsManual_Count                     : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) Manual_Count', [ tkcsManual_Count ] );
          csManual_Count := F.ReadLongIntValue;
        end;
      tkcsUncoded_Count                    : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) Uncoded_Count', [ tkcsUncoded_Count ] );
          csUncoded_Count := F.ReadLongIntValue;
        end;
      tkcsMaster_Mem_Count                 : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) Master_Mem_Count', [ tkcsMaster_Mem_Count ] );
          csMaster_Mem_Count := F.ReadLongIntValue;
        end;
      tkcsMan_Super_Count                  : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) Man_Super_Count', [ tkcsMan_Super_Count ] );
          csMan_Super_Count := F.ReadLongIntValue;
        end;
      tkcsNotes_Count                      : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) Notes_Count', [ tkcsNotes_Count ] );
          csNotes_Count := F.ReadLongIntValue;
        end;
      tkcsClient_Files_Sent                : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) Client_Files_Sent', [ tkcsClient_Files_Sent ] );
          csClient_Files_Sent := F.ReadLongIntValue;
        end;
      tkcsClient_Files_Received            : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) Client_Files_Received', [ tkcsClient_Files_Received ] );
          csClient_Files_Received := F.ReadLongIntValue;
        end;
      else
        Raise Exception.CreateFmt( SUnknownToken, [ Token ] );
    end; { of Case }
    Token := F.ReadToken;
  end; { of While }
end; { of Read_Coding_Statistics_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Coding_Statistics_Rec : pCoding_Statistics_Rec ;

Var
  P : pCoding_Statistics_Rec;
Begin
  New( P );
  If Assigned( P ) then With P^ do
  Begin
    FillChar( P^, Coding_Statistics_Rec_Size, 0 );
    csRecord_Type := tkBegin_Coding_Statistics;
    csEOR         := tkEnd_Coding_Statistics;
  end
  else
    Raise Exception.Create( SInsufficientMemory );
  Result := P;
end;

{  -------------------------------------------------------------------  }

{  -------------------------------------------------------------------  }

END.
