unit mxFiles32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// utility and locking routines for the master memorised entry files
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface
uses
  bkDefs, bkConst;

type
  mxFile = file of tMemorised_Transaction_Rec;

const
   mmxPrefix     = 'mm';
   mmxExtn       = '.mxl';
   mmxBackupExtn = '.mxb';
   mmxLockExtn   = '.mx$';

//New String Routines
function  MasterFilename( const BankPrefix : BankPrefixStr) : string;
function  MasterFileBackupName( const BankPrefix : BankPrefixStr) : string;
function  GetMasterFileTimeStamp( BankPrefix : BankPrefixStr ): Int64;

function  LockMasterFile( BankPrefix : BankPrefixStr )  : Boolean;
procedure UnlockMasterFile( BankPrefix : BankPrefixStr ) ;

function  SaveNewMasterMX( BankPrefix : BankPrefixStr; MX : tMemorised_Transaction_Rec ): Boolean;
function  GetBankPrefix( Const AccountNumber : ShortString ): BankPrefixStr;

//******************************************************************************
implementation
uses
  BKmxIO,
  classes,
  forms,
  GlobalDirectories,
  GlobalCache,
  genUtils,
  LogUtil,
  MoneyDef,
  progress,
  sysutils,
  Tokens,
  windows,
  WinUtils,
  ErrorMoreFrm;

const
   UnitName = 'MXFILES32';
var
  DebugMe : boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  GetMasterFileTimeStamp( BankPrefix : BankPrefixStr ): Int64;
//reads the file time for the master file
begin
   result := WinUtils.GetFileTimeAsInt64( MasterFilename( BankPrefix));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MasterFilename( const BankPrefix : BankPrefixStr) : string;
begin
  result := GlobalDirectories.glDataDir +
            mmxPrefix +
            whShortNames[ GlobalCache.cache_Country ] +
            BankPrefix +
            mmxExtn;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  MasterFileBackupName( const BankPrefix : BankPrefixStr) : string;
begin
  result := ChangeFileExt( MasterFilename( BankPrefix), mmxBackupExtn);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  MasterFileLockFileName( BankPrefix : BankPrefixStr ): String;
begin
  result := ChangeFileExt( MasterFilename( BankPrefix), mmxLockExtn);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  LockMasterFile( BankPrefix : BankPrefixStr )  : Boolean;
const
   ThisMethodName = 'LockMasterFile';
const
   MaxTickDiff = 45000;  //milliseconds  45s
Var
   F  : TextFile;
   StartTick     : DWORD;
   TimeElapsed   : integer;
   FLockFileName : string;
Begin
   Result := FALSE;
   FLockFileName := MasterFileLockFileName(BankPrefix);

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Requesting Lock');
   try
     try
       If BKFileExists( fLockFileName ) then  //locked by someone else so wait x ms
       Begin
          UpdateAppStatus('Waiting to read Master Memorisation File '+FlockFileName,'('+inttostr(round(MaxTickDiff div 1000))+' s)',20);
          StartTick   := GetTickCount;
          TimeElapsed := 0;
          Repeat
              UpdateAppStatusPerc_NR(TimeElapsed/MaxTickDiff*100);

              Application.ProcessMessages;
              TimeElapsed := WINUTILS.GetTicksSince( StartTick );
          Until ( not BKFileExists( fLockFileName ) ) OR (TimeElapsed>MaxTickDiff);
       end;

       //waited long enough or lock no longer exists
       If not BKFileExists(fLockFileName ) then
       Begin
          AssignFile( F, fLockFileName );
          Rewrite( F );
          try
            Writeln(F,'Master Locked by [' + GlobalCache.cache_Current_Username + ']');
          finally
            CloseFile( F );
          end;
          Result := TRUE;

          if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Locked '+ fLockFileName);
       end
       else
       begin
         LogUtil.LogMsg(lmError,UnitName,ThisMethodName+' : Lock Denied '+fLockFileName);
         HelpfulErrorMsg('Unable to save the Master Memorisation - lock denied', 0);
       end;
     finally
       ClearStatus;
     end;
   except
      {log the error quietly, function will return false indicating lock cannot be obtained}
      on E: EInOutError do LogUtil.LogMsg(lmError,UnitName, ThisMethodName+' EInOutError '+e.message);
      on E: EFCreateError do LogUtil.LogMsg(lmError,UnitName, ThisMethodName+' EFCreate '+e.message);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UnlockMasterFile( BankPrefix : BankPrefixStr ) ;
begin
  DeleteFile(PChar(MasterFileLockFileName(BankPrefix)));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  SaveNewMasterMX( BankPrefix : BankPrefixStr; MX : tMemorised_Transaction_Rec ): Boolean;
//save a new master memorisation record into the file, create a new file if one does
//not currently exist.
Var
   FN : String;
   F  : MXFile;
Begin
   result := false;
   If not LockMasterFile( BankPrefix ) then exit;

   FN := MasterFileName( BankPrefix );
   If not BKFileExists( FN ) then Begin
      AssignFile( F, FN );
      Rewrite( F );
   end
   else Begin
      AssignFile( F, FN );
      Reset( F );
   end;
   //move to end of file and write new record
   try
      Seek( F, FileSize( F ) );
      Write( F, MX );
   finally
      CloseFile( F );
   end;

   UnlockMasterFile( BankPrefix );
   result := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function GetBankPrefix( Const AccountNumber : ShortString ): BankPrefixStr;
//   We need some way to link accounts with specific banks. In BK5 we used the
//   first two digits as a bank ID. This broke when we added Building Societies
//   and Credit Unions, because we used an alpha code in the account number.
//
//   In BK6, we check to see whether the account is numbers only or alphanumeric.
//   For an alphanumeric code, we use the alpha part as the bank ID. For a
//   numeric code, we use the first two digits.
//
//   For example:
//
//   SNumber = 'ABC1234567890'            BankCode = 'ABC'
//   SNumber = '1234567890123'            BankCode = '12'
Var
   i    : Byte;
Begin
   Result := '';
   If IsNumeric( AccountNumber ) then
      Result := Copy( AccountNumber, 1, 2 )
   else Begin
      //account no is alpha numeric, copy x ( 3) chars or first n alpha
      i := 1;
      while ( (i <= length( AccountNumber)) and ( i <= MaxBankPrefixLen)) do begin
         if not (AccountNumber[ i] in ['0'..'9']) then
            result := result + AccountNumber[ i];
         Inc( i);
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
end.
