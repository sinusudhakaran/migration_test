UNIT SYusIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_User                         = 60 ;
   tkEnd_User                           = 61 ;

FUNCTION  IsAUser_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_User_Rec ( Var O : TUser_Rec ; Var F : TIOStream );
PROCEDURE Read_User_Rec ( Var O : TUser_Rec ; Var F : TIOStream );
FUNCTION  New_User_Rec : pUser_Rec ;
PROCEDURE Free_User_Rec_Dynamic_Fields ( Var O : TUser_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'SYUSIO';
   SBoundsError        = 'SYUSIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'SYUSIO Error: Pointer is NIL in IsAUser_Rec';
   SInvalidType        = 'SYUSIO Error: Type is invalid in IsAUser_Rec';
   SInvalidEOR         = 'SYUSIO Error: EOR is missing in IsAUser_Rec';
   SUnknownToken       = 'SYUSIO Error: Unknown token %d in Read_User_Rec';
   SInsufficientMemory = 'SYUSIO Error: Out of memory in New_User_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkusCode                             = 62 ;
   tkusName                             = 63 ;
   tkusPassword                         = 64 ;
   tkusEMail_Address                    = 65 ;
   tkusSystem_Access                    = 66 ;
   tkusDialog_Colour                    = 67 ;
   tkusLogged_In                        = 68 ;
   tkusReverse_Mouse_Buttons            = 69 ;
   tkusMASTER_Access                    = 70 ;
   tkusLRN                              = 71 ;
   tkusSpare_String                     = 72 ;
   tkusWorkstation_Logged_In_At         = 73 ;
   tkusIs_Remote_User                   = 74 ;
   tkusDirect_Dial                      = 75 ;
   tkusShow_CM_on_open                  = 76 ;
   tkusShow_Printer_Choice              = 77 ;
   tkusEULA_Version                     = 78 ;
   tkusSpare_Boolean                    = 79 ;
   tkusLogin_Count                      = 80 ;
   tkusReset_Count                      = 81 ;
   tkusSuppress_HF                      = 82 ;
   tkusShow_Practice_Logo               = 83 ;
   tkusAudit_Record_ID                  = 84 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAUser_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PUser_Rec ( P )^ do Begin
      If usRecord_Type <> tkBegin_User then
         Raise ECorruptData.Create( SInvalidType );
      If usEOR <> tkEnd_User then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_User_Rec ( Var O : TUser_Rec ; Var F : TIOStream );

Begin
   If IsAUser_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_User );
      F.WriteStringValue( tkusCode , usCode );
      F.WriteStringValue( tkusName , usName );
      F.WriteStringValue( tkusPassword , usPassword );
      F.WriteStringValue( tkusEMail_Address , usEMail_Address );
      F.WriteBooleanValue( tkusSystem_Access , usSystem_Access );
      F.WriteByteValue( tkusDialog_Colour , usDialog_Colour );
      F.WriteBooleanValue( tkusLogged_In , usLogged_In );
      F.WriteBooleanValue( tkusReverse_Mouse_Buttons , usReverse_Mouse_Buttons );
      F.WriteBooleanValue( tkusMASTER_Access , usMASTER_Access );
      F.WriteIntegerValue( tkusLRN , usLRN );
      F.WriteStringValue( tkusSpare_String , usSpare_String );
      F.WriteStringValue( tkusWorkstation_Logged_In_At , usWorkstation_Logged_In_At );
      F.WriteBooleanValue( tkusIs_Remote_User , usIs_Remote_User );
      F.WriteStringValue( tkusDirect_Dial , usDirect_Dial );
      F.WriteBooleanValue( tkusShow_CM_on_open , usShow_CM_on_open );
      F.WriteBooleanValue( tkusShow_Printer_Choice , usShow_Printer_Choice );
      F.WriteAnsiStringValue( tkusEULA_Version , usEULA_Version );
      F.WriteBooleanValue( tkusSpare_Boolean , usSpare_Boolean );
      F.WriteIntegerValue( tkusLogin_Count , usLogin_Count );
      F.WriteIntegerValue( tkusReset_Count , usReset_Count );
      F.WriteByteValue( tkusSuppress_HF , usSuppress_HF );
      F.WriteBooleanValue( tkusShow_Practice_Logo , usShow_Practice_Logo );
      F.WriteIntegerValue( tkusAudit_Record_ID , usAudit_Record_ID );
      F.WriteToken( tkEnd_User );
   end;
end; { of Write_User_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_User_Rec ( Var O : TUser_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, User_Rec_Size, 0 );
   O.usRecord_Type := tkBegin_User;
   O.usEOR := tkEnd_User;
   Token := tkBegin_User;

   While Token <> tkEnd_User do With O do
   Begin
      Case Token of
         tkBegin_User :; { Do Nothing }
         tkEnd_User :; { Do Nothing }
         tkusCode                             : usCode := F.ReadStringValue;
         tkusName                             : usName := F.ReadStringValue;
         tkusPassword                         : usPassword := F.ReadStringValue;
         tkusEMail_Address                    : usEMail_Address := F.ReadStringValue;
         tkusSystem_Access                    : usSystem_Access := F.ReadBooleanValue;
         tkusDialog_Colour                    : usDialog_Colour := F.ReadByteValue;
         tkusLogged_In                        : usLogged_In := F.ReadBooleanValue;
         tkusReverse_Mouse_Buttons            : usReverse_Mouse_Buttons := F.ReadBooleanValue;
         tkusMASTER_Access                    : usMASTER_Access := F.ReadBooleanValue;
         tkusLRN                              : usLRN := F.ReadIntegerValue;
         tkusSpare_String                     : usSpare_String := F.ReadStringValue;
         tkusWorkstation_Logged_In_At         : usWorkstation_Logged_In_At := F.ReadStringValue;
         tkusIs_Remote_User                   : usIs_Remote_User := F.ReadBooleanValue;
         tkusDirect_Dial                      : usDirect_Dial := F.ReadStringValue;
         tkusShow_CM_on_open                  : usShow_CM_on_open := F.ReadBooleanValue;
         tkusShow_Printer_Choice              : usShow_Printer_Choice := F.ReadBooleanValue;
         tkusEULA_Version                     : usEULA_Version := F.ReadAnsiStringValue;
         tkusSpare_Boolean                    : usSpare_Boolean := F.ReadBooleanValue;
         tkusLogin_Count                      : usLogin_Count := F.ReadIntegerValue;
         tkusReset_Count                      : usReset_Count := F.ReadIntegerValue;
         tkusSuppress_HF                      : usSuppress_HF := F.ReadByteValue;
         tkusShow_Practice_Logo               : usShow_Practice_Logo := F.ReadBooleanValue;
         tkusAudit_Record_ID                  : usAudit_Record_ID := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_User_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_User_Rec : pUser_Rec ;

Var
   P : pUser_Rec;
Begin
   SafeGetMem( P, User_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, User_Rec_Size, 0 );
      usRecord_Type := tkBegin_User;
      usEOR         := tkEnd_User;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_User_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_User_Rec_Dynamic_Fields ( Var O : TUser_Rec );

Begin
   If IsAUser_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      usEULA_Version := '' ;
   end;
end;

{  -------------------------------------------------------------------  }

END.
