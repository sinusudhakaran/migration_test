UNIT CSsfIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES CSDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Coding_Stat_Fields           = 20 ;
   tkEnd_Coding_Stat_Fields             = 21 ;

FUNCTION  IsACoding_Stat_Fields_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Coding_Stat_Fields_Rec ( Var O : TCoding_Stat_Fields_Rec ; Var F : TIOStream );
PROCEDURE Read_Coding_Stat_Fields_Rec ( Var O : TCoding_Stat_Fields_Rec ; Var F : TIOStream );
FUNCTION  New_Coding_Stat_Fields_Rec : pCoding_Stat_Fields_Rec ;

{  -------------------------------------------------------------------  }
Implementation uses MoneyDef, SysUtils, DebugUtils;
{  -------------------------------------------------------------------  }

CONST
  SUnitName           = 'CSSFIO';
  SBoundsError        = 'CSSFIO Error: %s is out of bounds [ %d %d ], value is %d';
  SInvalidPointer     = 'CSSFIO Error: Pointer is NIL in IsACoding_Stat_Fields_Rec';
  SInvalidType        = 'CSSFIO Error: Type is invalid in IsACoding_Stat_Fields_Rec';
  SInvalidEOR         = 'CSSFIO Error: EOR is missing in IsACoding_Stat_Fields_Rec';
  SUnknownToken       = 'CSSFIO Error: Unknown token %d in Read_Coding_Stat_Fields_Rec';
  SInsufficientMemory = 'CSSFIO Error: Out of memory in New_Coding_Stat_Fields_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
  If ( Value >= Min ) and
     ( Value <= Max ) then exit;
  Raise Exception.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tksfFile_Version                     = 22 ;
   tksfRead_Version                     = 23 ;

{  -------------------------------------------------------------------  }

FUNCTION IsACoding_Stat_Fields_Rec ( P : Pointer ): Boolean;

Begin
  If P=NIL then
    Raise Exception.Create( SInvalidPointer );
  With PCoding_Stat_Fields_Rec ( P )^ do Begin
    If sfRecord_Type <> tkBegin_Coding_Stat_Fields then
      Raise Exception.Create( SInvalidType );
    If sfEOR <> tkEnd_Coding_Stat_Fields then
      Raise Exception.Create( SInvalidEOR );
  end;
  Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Coding_Stat_Fields_Rec ( Var O : TCoding_Stat_Fields_Rec ; Var F : TIOStream );

Begin
  If IsACoding_Stat_Fields_Rec ( @O ) then With O do
  Begin
    F.WriteToken( tkBegin_Coding_Stat_Fields );
      F.WriteLongIntValue( tksfFile_Version , sfFile_Version );
      F.WriteLongIntValue( tksfRead_Version , sfRead_Version );
    F.WriteToken( tkEnd_Coding_Stat_Fields );
  end;
end; { of Write_Coding_Stat_Fields_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Coding_Stat_Fields_Rec ( Var O : TCoding_Stat_Fields_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
  FillChar( O, Coding_Stat_Fields_Rec_Size, 0 );
  O.sfRecord_Type := tkBegin_Coding_Stat_Fields;
  O.sfEOR := tkEnd_Coding_Stat_Fields;
  Token := tkBegin_Coding_Stat_Fields;

  While Token <> tkEnd_Coding_Stat_Fields do With O do
  Begin
    Case Token of
      tkBegin_Coding_Stat_Fields :; { Do Nothing }
      tkEnd_Coding_Stat_Fields :; { Do Nothing }
      tksfFile_Version                     : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) File_Version', [ tksfFile_Version ] );
          sfFile_Version := F.ReadLongIntValue;
        end;
      tksfRead_Version                     : 
        Begin
          DbgWriteFmtLn( 'Reading (%d) Read_Version', [ tksfRead_Version ] );
          sfRead_Version := F.ReadLongIntValue;
        end;
      else
        Raise Exception.CreateFmt( SUnknownToken, [ Token ] );
    end; { of Case }
    Token := F.ReadToken;
  end; { of While }
end; { of Read_Coding_Stat_Fields_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Coding_Stat_Fields_Rec : pCoding_Stat_Fields_Rec ;

Var
  P : pCoding_Stat_Fields_Rec;
Begin
  New( P );
  If Assigned( P ) then With P^ do
  Begin
    FillChar( P^, Coding_Stat_Fields_Rec_Size, 0 );
    sfRecord_Type := tkBegin_Coding_Stat_Fields;
    sfEOR         := tkEnd_Coding_Stat_Fields;
  end
  else
    Raise Exception.Create( SInsufficientMemory );
  Result := P;
end;

{  -------------------------------------------------------------------  }

{  -------------------------------------------------------------------  }

END.
