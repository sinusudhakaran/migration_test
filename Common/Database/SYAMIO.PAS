UNIT SYamIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Client_Account_Map           = 90 ;
   tkEnd_Client_Account_Map             = 91 ;

FUNCTION  IsAClient_Account_Map_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Client_Account_Map_Rec ( Var O : TClient_Account_Map_Rec ; Var F : TIOStream );
PROCEDURE Read_Client_Account_Map_Rec ( Var O : TClient_Account_Map_Rec ; Var F : TIOStream );
FUNCTION  New_Client_Account_Map_Rec : pClient_Account_Map_Rec ;
PROCEDURE Free_Client_Account_Map_Rec_Dynamic_Fields ( Var O : TClient_Account_Map_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'SYAMIO';
   SBoundsError        = 'SYAMIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'SYAMIO Error: Pointer is NIL in IsAClient_Account_Map_Rec';
   SInvalidType        = 'SYAMIO Error: Type is invalid in IsAClient_Account_Map_Rec';
   SInvalidEOR         = 'SYAMIO Error: EOR is missing in IsAClient_Account_Map_Rec';
   SUnknownToken       = 'SYAMIO Error: Unknown token %d in Read_Client_Account_Map_Rec';
   SInsufficientMemory = 'SYAMIO Error: Out of memory in New_Client_Account_Map_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkamClient_LRN                       = 92 ;
   tkamAccount_LRN                      = 93 ;
   tkamLast_Date_Printed                = 94 ;
   tkamTemp_Last_Date_Printed           = 95 ;
   tkamEarliest_Download_Date           = 96 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAClient_Account_Map_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PClient_Account_Map_Rec ( P )^ do Begin
      If amRecord_Type <> tkBegin_Client_Account_Map then
         Raise ECorruptData.Create( SInvalidType );
      If amEOR <> tkEnd_Client_Account_Map then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Client_Account_Map_Rec ( Var O : TClient_Account_Map_Rec ; Var F : TIOStream );

Begin
   If IsAClient_Account_Map_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Client_Account_Map );
      F.WriteIntegerValue( tkamClient_LRN , amClient_LRN );
      F.WriteIntegerValue( tkamAccount_LRN , amAccount_LRN );
      F.WriteDateValue( tkamLast_Date_Printed , amLast_Date_Printed );
      F.WriteIntegerValue( tkamTemp_Last_Date_Printed , amTemp_Last_Date_Printed );
      F.WriteDateValue( tkamEarliest_Download_Date , amEarliest_Download_Date );
      F.WriteToken( tkEnd_Client_Account_Map );
   end;
end; { of Write_Client_Account_Map_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Client_Account_Map_Rec ( Var O : TClient_Account_Map_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Client_Account_Map_Rec_Size, 0 );
   O.amRecord_Type := tkBegin_Client_Account_Map;
   O.amEOR := tkEnd_Client_Account_Map;
   Token := tkBegin_Client_Account_Map;

   While Token <> tkEnd_Client_Account_Map do With O do
   Begin
      Case Token of
         tkBegin_Client_Account_Map :; { Do Nothing }
         tkEnd_Client_Account_Map :; { Do Nothing }
         tkamClient_LRN                       : amClient_LRN := F.ReadIntegerValue;
         tkamAccount_LRN                      : amAccount_LRN := F.ReadIntegerValue;
         tkamLast_Date_Printed                : amLast_Date_Printed := F.ReadDateValue;
         tkamTemp_Last_Date_Printed           : amTemp_Last_Date_Printed := F.ReadIntegerValue;
         tkamEarliest_Download_Date           : amEarliest_Download_Date := F.ReadDateValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Client_Account_Map_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Client_Account_Map_Rec : pClient_Account_Map_Rec ;

Var
   P : pClient_Account_Map_Rec;
Begin
   SafeGetMem( P, Client_Account_Map_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Client_Account_Map_Rec_Size, 0 );
      amRecord_Type := tkBegin_Client_Account_Map;
      amEOR         := tkEnd_Client_Account_Map;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Client_Account_Map_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Client_Account_Map_Rec_Dynamic_Fields ( Var O : TClient_Account_Map_Rec );

Begin
   If IsAClient_Account_Map_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
