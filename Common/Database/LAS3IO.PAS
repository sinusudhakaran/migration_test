UNIT LAs3IO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES LADEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Printer                      = 40 ;
   tkEnd_Printer                        = 41 ;

FUNCTION  IsAPrinter_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Printer_Rec ( Var O : TPrinter_Rec ; Var F : TIOStream );
PROCEDURE Read_Printer_Rec ( Var O : TPrinter_Rec ; Var F : TIOStream );
FUNCTION  New_Printer_Rec : pPrinter_Rec ;
PROCEDURE Free_Printer_Rec_Dynamic_Fields ( Var O : TPrinter_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'LAS3IO';
   SBoundsError        = 'LAS3IO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'LAS3IO Error: Pointer is NIL in IsAPrinter_Rec';
   SInvalidType        = 'LAS3IO Error: Type is invalid in IsAPrinter_Rec';
   SInvalidEOR         = 'LAS3IO Error: EOR is missing in IsAPrinter_Rec';
   SUnknownToken       = 'LAS3IO Error: Unknown token %d in Read_Printer_Rec';
   SInsufficientMemory = 'LAS3IO Error: Out of memory in New_Printer_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tks3Printer_Name                     = 42 ;
   tks3Printer_Model_Name               = 43 ;
   tks3Library_File_Name                = 44 ;
   tks3Connection_Type                  = 45 ;
   tks3Queue_Name                       = 46 ;
   tks3LRN                              = 47 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAPrinter_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PPrinter_Rec ( P )^ do Begin
      If s3Record_Type <> tkBegin_Printer then
         Raise ECorruptData.Create( SInvalidType );
      If s3EOR <> tkEnd_Printer then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Printer_Rec ( Var O : TPrinter_Rec ; Var F : TIOStream );

Begin
   If IsAPrinter_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Printer );
      F.WriteStringValue( tks3Printer_Name , s3Printer_Name );
      F.WriteStringValue( tks3Printer_Model_Name , s3Printer_Model_Name );
      F.WriteStringValue( tks3Library_File_Name , s3Library_File_Name );
      F.WriteByteValue( tks3Connection_Type , s3Connection_Type );
      F.WriteStringValue( tks3Queue_Name , s3Queue_Name );
      F.WriteIntegerValue( tks3LRN , s3LRN );
      F.WriteToken( tkEnd_Printer );
   end;
end; { of Write_Printer_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Printer_Rec ( Var O : TPrinter_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Printer_Rec_Size, 0 );
   O.s3Record_Type := tkBegin_Printer;
   O.s3EOR := tkEnd_Printer;
   Token := tkBegin_Printer;

   While Token <> tkEnd_Printer do With O do
   Begin
      Case Token of
         tkBegin_Printer :; { Do Nothing }
         tkEnd_Printer :; { Do Nothing }
         tks3Printer_Name                     : s3Printer_Name := F.ReadStringValue;
         tks3Printer_Model_Name               : s3Printer_Model_Name := F.ReadStringValue;
         tks3Library_File_Name                : s3Library_File_Name := F.ReadStringValue;
         tks3Connection_Type                  : s3Connection_Type := F.ReadByteValue;
         tks3Queue_Name                       : s3Queue_Name := F.ReadStringValue;
         tks3LRN                              : s3LRN := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Printer_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Printer_Rec : pPrinter_Rec ;

Var
   P : pPrinter_Rec;
Begin
   SafeGetMem( P, Printer_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Printer_Rec_Size, 0 );
      s3Record_Type := tkBegin_Printer;
      s3EOR         := tkEnd_Printer;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Printer_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Printer_Rec_Dynamic_Fields ( Var O : TPrinter_Rec );

Begin
   If IsAPrinter_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
