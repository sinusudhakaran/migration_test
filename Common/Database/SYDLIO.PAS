UNIT SYdlIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_System_Disk_Log              = 40 ;
   tkEnd_System_Disk_Log                = 41 ;

FUNCTION  IsASystem_Disk_Log_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_System_Disk_Log_Rec ( Var O : TSystem_Disk_Log_Rec ; Var F : TIOStream );
PROCEDURE Read_System_Disk_Log_Rec ( Var O : TSystem_Disk_Log_Rec ; Var F : TIOStream );
FUNCTION  New_System_Disk_Log_Rec : pSystem_Disk_Log_Rec ;
PROCEDURE Free_System_Disk_Log_Rec_Dynamic_Fields ( Var O : TSystem_Disk_Log_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'SYDLIO';
   SBoundsError        = 'SYDLIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'SYDLIO Error: Pointer is NIL in IsASystem_Disk_Log_Rec';
   SInvalidType        = 'SYDLIO Error: Type is invalid in IsASystem_Disk_Log_Rec';
   SInvalidEOR         = 'SYDLIO Error: EOR is missing in IsASystem_Disk_Log_Rec';
   SUnknownToken       = 'SYDLIO Error: Unknown token %d in Read_System_Disk_Log_Rec';
   SInsufficientMemory = 'SYDLIO Error: Out of memory in New_System_Disk_Log_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkdlDisk_ID                          = 42 ;
   tkdlDate_Downloaded                  = 43 ;
   tkdlNo_of_Accounts                   = 44 ;
   tkdlNo_of_Entries                    = 45 ;
   tkdlWas_In_Last_Download             = 46 ;

{  -------------------------------------------------------------------  }

FUNCTION IsASystem_Disk_Log_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PSystem_Disk_Log_Rec ( P )^ do Begin
      If dlRecord_Type <> tkBegin_System_Disk_Log then
         Raise ECorruptData.Create( SInvalidType );
      If dlEOR <> tkEnd_System_Disk_Log then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_System_Disk_Log_Rec ( Var O : TSystem_Disk_Log_Rec ; Var F : TIOStream );

Begin
   If IsASystem_Disk_Log_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_System_Disk_Log );
      F.WriteStringValue( tkdlDisk_ID , dlDisk_ID );
      F.WriteDateValue( tkdlDate_Downloaded , dlDate_Downloaded );
      F.WriteIntegerValue( tkdlNo_of_Accounts , dlNo_of_Accounts );
      F.WriteIntegerValue( tkdlNo_of_Entries , dlNo_of_Entries );
      F.WriteBooleanValue( tkdlWas_In_Last_Download , dlWas_In_Last_Download );
      F.WriteToken( tkEnd_System_Disk_Log );
   end;
end; { of Write_System_Disk_Log_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_System_Disk_Log_Rec ( Var O : TSystem_Disk_Log_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, System_Disk_Log_Rec_Size, 0 );
   O.dlRecord_Type := tkBegin_System_Disk_Log;
   O.dlEOR := tkEnd_System_Disk_Log;
   Token := tkBegin_System_Disk_Log;

   While Token <> tkEnd_System_Disk_Log do With O do
   Begin
      Case Token of
         tkBegin_System_Disk_Log :; { Do Nothing }
         tkEnd_System_Disk_Log :; { Do Nothing }
         tkdlDisk_ID                          : dlDisk_ID := F.ReadStringValue;
         tkdlDate_Downloaded                  : dlDate_Downloaded := F.ReadDateValue;
         tkdlNo_of_Accounts                   : dlNo_of_Accounts := F.ReadIntegerValue;
         tkdlNo_of_Entries                    : dlNo_of_Entries := F.ReadIntegerValue;
         tkdlWas_In_Last_Download             : dlWas_In_Last_Download := F.ReadBooleanValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_System_Disk_Log_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_System_Disk_Log_Rec : pSystem_Disk_Log_Rec ;

Var
   P : pSystem_Disk_Log_Rec;
Begin
   SafeGetMem( P, System_Disk_Log_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, System_Disk_Log_Rec_Size, 0 );
      dlRecord_Type := tkBegin_System_Disk_Log;
      dlEOR         := tkEnd_System_Disk_Log;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_System_Disk_Log_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_System_Disk_Log_Rec_Dynamic_Fields ( Var O : TSystem_Disk_Log_Rec );

Begin
   If IsASystem_Disk_Log_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
