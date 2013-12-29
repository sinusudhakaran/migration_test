UNIT SYusIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM, SYAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_User                         = 60 ;
   tkEnd_User                           = 61 ;

FUNCTION  IsAUser_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_User_Rec ( Var O : TUser_Rec ; Var F : TIOStream );
PROCEDURE Read_User_Rec ( Var O : TUser_Rec ; Var F : TIOStream );
FUNCTION  New_User_Rec : pUser_Rec ;
PROCEDURE Free_User_Rec_Dynamic_Fields ( Var O : TUser_Rec );
FUNCTION User_Rec_Delta(P1, P2, P3: pUser_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_User_Rec(P1, P2: pUser_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

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
   tkusRedundant_Password               = 64 ;
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
   tkusAllow_Banklink_Online            = 85 ;
   tkusPassword                         = 86 ;
   tkusUse_Practice_Password_Online     = 87 ;
   tkusUsing_Mixed_Case_Password        = 88 ;
   tkusUsing_Secure_Authentication      = 89 ;
   tkusUser_Data_Block                  = 90 ;
   tkusSalt                             = 91 ;

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

Var
   I     : Byte;

Begin
   If IsAUser_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_User );
      F.WriteStringValue( tkusCode , usCode );
      F.WriteStringValue( tkusName , usName );
      F.WriteStringValue( tkusRedundant_Password , usRedundant_Password );
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
      F.WriteBooleanValue( tkusAllow_Banklink_Online , usAllow_Banklink_Online );
      F.WriteStringValue( tkusPassword , usPassword );
      F.WriteBooleanValue( tkusUse_Practice_Password_Online , usUse_Practice_Password_Online );
      F.WriteBooleanValue( tkusUsing_Mixed_Case_Password , usUsing_Mixed_Case_Password );
      F.WriteBooleanValue( tkusUsing_Secure_Authentication , usUsing_Secure_Authentication );
      For i := 1 to 128 do F.WriteBByteValue( tkusUser_Data_Block , i, usUser_Data_Block[ i ] );
      F.WriteStringValue( tkusSalt , usSalt );
      F.WriteToken( tkEnd_User );
   end;
end; { of Write_User_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_User_Rec ( Var O : TUser_Rec; Var F : TIOStream );

Var
   Token : Byte;
   I     : Byte;
   B     : Byte;   

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
         tkusRedundant_Password               : usRedundant_Password := F.ReadStringValue;
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
         tkusAllow_Banklink_Online            : usAllow_Banklink_Online := F.ReadBooleanValue;
         tkusPassword                         : usPassword := F.ReadStringValue;
         tkusUse_Practice_Password_Online     : usUse_Practice_Password_Online := F.ReadBooleanValue;
         tkusUsing_Mixed_Case_Password        : usUsing_Mixed_Case_Password := F.ReadBooleanValue;
         tkusUsing_Secure_Authentication      : usUsing_Secure_Authentication := F.ReadBooleanValue;
         tkusUser_Data_Block                  : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 128, 'usUser_Data_Block' );
               usUser_Data_Block[ I ] := B;
            end;
         tkusSalt                             : usSalt := F.ReadStringValue;
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

procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);
var
  i, j: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;
  j := 0;
  for i := tkusCode to tkusSalt do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION User_Rec_Delta(P1, P2, P3: pUser_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_User_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.usCode <> P2.usCode) then begin
    P3.usCode := P1.usCode;
    ChangedFields[i] := tkusCode;
    Inc(i);
  end;
  if (P1.usName <> P2.usName) then begin
    P3.usName := P1.usName;
    ChangedFields[i] := tkusName;
    Inc(i);
  end;
  if (P1.usRedundant_Password <> P2.usRedundant_Password) then begin
    P3.usRedundant_Password := P1.usRedundant_Password;
    ChangedFields[i] := tkusRedundant_Password;
    Inc(i);
  end;
  if (P1.usEMail_Address <> P2.usEMail_Address) then begin
    P3.usEMail_Address := P1.usEMail_Address;
    ChangedFields[i] := tkusEMail_Address;
    Inc(i);
  end;
  if (P1.usSystem_Access <> P2.usSystem_Access) then begin
    P3.usSystem_Access := P1.usSystem_Access;
    ChangedFields[i] := tkusSystem_Access;
    Inc(i);
  end;
  if (P1.usDialog_Colour <> P2.usDialog_Colour) then begin
    P3.usDialog_Colour := P1.usDialog_Colour;
    ChangedFields[i] := tkusDialog_Colour;
    Inc(i);
  end;
  if (P1.usLogged_In <> P2.usLogged_In) then begin
    P3.usLogged_In := P1.usLogged_In;
    ChangedFields[i] := tkusLogged_In;
    Inc(i);
  end;
  if (P1.usReverse_Mouse_Buttons <> P2.usReverse_Mouse_Buttons) then begin
    P3.usReverse_Mouse_Buttons := P1.usReverse_Mouse_Buttons;
    ChangedFields[i] := tkusReverse_Mouse_Buttons;
    Inc(i);
  end;
  if (P1.usMASTER_Access <> P2.usMASTER_Access) then begin
    P3.usMASTER_Access := P1.usMASTER_Access;
    ChangedFields[i] := tkusMASTER_Access;
    Inc(i);
  end;
  if (P1.usLRN <> P2.usLRN) then begin
    P3.usLRN := P1.usLRN;
    ChangedFields[i] := tkusLRN;
    Inc(i);
  end;
  if (P1.usSpare_String <> P2.usSpare_String) then begin
    P3.usSpare_String := P1.usSpare_String;
    ChangedFields[i] := tkusSpare_String;
    Inc(i);
  end;
  if (P1.usWorkstation_Logged_In_At <> P2.usWorkstation_Logged_In_At) then begin
    P3.usWorkstation_Logged_In_At := P1.usWorkstation_Logged_In_At;
    ChangedFields[i] := tkusWorkstation_Logged_In_At;
    Inc(i);
  end;
  if (P1.usIs_Remote_User <> P2.usIs_Remote_User) then begin
    P3.usIs_Remote_User := P1.usIs_Remote_User;
    ChangedFields[i] := tkusIs_Remote_User;
    Inc(i);
  end;
  if (P1.usDirect_Dial <> P2.usDirect_Dial) then begin
    P3.usDirect_Dial := P1.usDirect_Dial;
    ChangedFields[i] := tkusDirect_Dial;
    Inc(i);
  end;
  if (P1.usShow_CM_on_open <> P2.usShow_CM_on_open) then begin
    P3.usShow_CM_on_open := P1.usShow_CM_on_open;
    ChangedFields[i] := tkusShow_CM_on_open;
    Inc(i);
  end;
  if (P1.usShow_Printer_Choice <> P2.usShow_Printer_Choice) then begin
    P3.usShow_Printer_Choice := P1.usShow_Printer_Choice;
    ChangedFields[i] := tkusShow_Printer_Choice;
    Inc(i);
  end;
  if (P1.usEULA_Version <> P2.usEULA_Version) then begin
    P3.usEULA_Version := P1.usEULA_Version;
    ChangedFields[i] := tkusEULA_Version;
    Inc(i);
  end;
  if (P1.usSpare_Boolean <> P2.usSpare_Boolean) then begin
    P3.usSpare_Boolean := P1.usSpare_Boolean;
    ChangedFields[i] := tkusSpare_Boolean;
    Inc(i);
  end;
  if (P1.usLogin_Count <> P2.usLogin_Count) then begin
    P3.usLogin_Count := P1.usLogin_Count;
    ChangedFields[i] := tkusLogin_Count;
    Inc(i);
  end;
  if (P1.usReset_Count <> P2.usReset_Count) then begin
    P3.usReset_Count := P1.usReset_Count;
    ChangedFields[i] := tkusReset_Count;
    Inc(i);
  end;
  if (P1.usSuppress_HF <> P2.usSuppress_HF) then begin
    P3.usSuppress_HF := P1.usSuppress_HF;
    ChangedFields[i] := tkusSuppress_HF;
    Inc(i);
  end;
  if (P1.usShow_Practice_Logo <> P2.usShow_Practice_Logo) then begin
    P3.usShow_Practice_Logo := P1.usShow_Practice_Logo;
    ChangedFields[i] := tkusShow_Practice_Logo;
    Inc(i);
  end;
  if (P1.usAudit_Record_ID <> P2.usAudit_Record_ID) then begin
    P3.usAudit_Record_ID := P1.usAudit_Record_ID;
    ChangedFields[i] := tkusAudit_Record_ID;
    Inc(i);
  end;
  if (P1.usAllow_Banklink_Online <> P2.usAllow_Banklink_Online) then begin
    P3.usAllow_Banklink_Online := P1.usAllow_Banklink_Online;
    ChangedFields[i] := tkusAllow_Banklink_Online;
    Inc(i);
  end;
  if (P1.usPassword <> P2.usPassword) then begin
    P3.usPassword := P1.usPassword;
    ChangedFields[i] := tkusPassword;
    Inc(i);
  end;
  if (P1.usUse_Practice_Password_Online <> P2.usUse_Practice_Password_Online) then begin
    P3.usUse_Practice_Password_Online := P1.usUse_Practice_Password_Online;
    ChangedFields[i] := tkusUse_Practice_Password_Online;
    Inc(i);
  end;
  if (P1.usUsing_Mixed_Case_Password <> P2.usUsing_Mixed_Case_Password) then begin
    P3.usUsing_Mixed_Case_Password := P1.usUsing_Mixed_Case_Password;
    ChangedFields[i] := tkusUsing_Mixed_Case_Password;
    Inc(i);
  end;
  if (P1.usUsing_Secure_Authentication <> P2.usUsing_Secure_Authentication) then begin
    P3.usUsing_Secure_Authentication := P1.usUsing_Secure_Authentication;
    ChangedFields[i] := tkusUsing_Secure_Authentication;
    Inc(i);
  end;
  if User_Data_Block_Changed(TUser_Data_Block_Array(P1.usUser_Data_Block), 
                  TUser_Data_Block_Array(P2.usUser_Data_Block), 
                  TUser_Data_Block_Array(P3.usUser_Data_Block)) then begin
    ChangedFields[i] := tkusUser_Data_Block;
    Inc(i);
  end;
  if (P1.usSalt <> P2.usSalt) then begin
    P3.usSalt := P1.usSalt;
    ChangedFields[i] := tkusSalt;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_User_Rec(P1, P2: pUser_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_User_Rec(P1^, S);
    S.Position := 0;
    Read_User_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
