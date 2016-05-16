unit CAUtils;
//------------------------------------------------------------------------------
{
   Title:

   Description: Utility Functions specific to CA-Systems

   Remarks:
                Operates on GLOBALS.MyClient


                Feb 2001 - Added overload so that can for generic client, no just
                          MyClient

   Author:      SPA, 20-05-99

}
//------------------------------------------------------------------------------
interface
uses
   clObj32, SysUtils;

function IsCASystems( aClient : TClientObj) : boolean; overload;
function CASystemsGSTOK( aClient : TClientObj; const Rate : Byte) : boolean; overload;

function IsCASystems : Boolean; overload;
function CASystemsGSTOK( const Rate : Byte ) : boolean; overload;

function StripAlphaFromAccount( OriginalAccountNo : ShortString) : ShortString;

//******************************************************************************
implementation
uses
   BKConst,
   glConst,
   Globals,
   LogUtil;

Const
   UnitName = 'CAUtils';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function StripAlphaFromAccount( OriginalAccountNo : ShortString) : ShortString;
//Strip alpha characters from the account number.  MYOB AO does not allow
//accounts to be imported if have alpha when bank rec module is turned on
var
  S : ShortString;
  i : integer;
  HasNumbers : boolean;
  NewNo      : ShortString;
begin
  S := OriginalAccountNo;
  //first see if all characters are alpha
  i := 0;
  HasNumbers := false;
  while i < length( s) do
  begin
    inc( i);
    HasNumbers := (Ord( S[i]) > 47) and ( Ord( S[i]) < 58);
  end;

  //if there are no numbers then leave the account number the same
  if not Hasnumbers then
    Exit;

  //remove alpha characters from account number
  i := 0;
  NewNo := '';
  S := OriginalAccountNo;
  while i < length( s) do
  begin
    inc( i);
    if (Ord( S[i]) > 47) and ( Ord( S[i]) < 58) then
    begin
      NewNo := NewNo + S[i];
    end;
  end;
  result := NewNo;
end;


//------------------------------------------------------------------------------

function IsCASystems( aClient : TClientObj) : boolean; overload;
Const
   ThisMethodName = 'IsCASystems';
   AU_Systems = [ saGLMAN, saMYOBAccountantsOffice, saMYOB_AO_COM , saMYOBOnlineLedger];
   NZ_Systems = [ snGLMAN, snMYOB_AO_COM, snMYOBOnlineLedger];
   UK_Systems = [  ];

Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  Result := False;
  with aClient.clFields do
  Begin
    case clCountry of
      whNewZealand : Result := ( clAccounting_System_Used in NZ_Systems );
      whAustralia  : Result := ( clAccounting_System_Used in AU_Systems );
      whUK         : Result := ( clAccounting_System_Used in UK_Systems );
    end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//------------------------------------------------------------------------------

function IsCASystems : Boolean;
begin
   result := IsCASystems( MyClient);
end;
//------------------------------------------------------------------------------

function CASystemsGSTOK( aClient : TClientObj; const Rate : Byte) : boolean; overload;
Const
   ThisMethodName = 'CASystemsGSTOK';
   vMin = 1;
   vMax = 8;
   ValidCodes : Array[ vMin..vMax ] of String[1] = ( 'I','O','E','Z','1','2','3','4' );

   ValidPLNZCodes : Array [1..7] of String[4] = ('GST', 'E', 'NTR', 'Z', 'I', 'GSTI', 'GSTO');
   ValidPLAUCodes : Array [1..10] of String[4] = ('CAP', 'EXP', 'FRE', 'GNR', 'GST', 'INP', 'ITS', 'NTR', 'GSTI', 'GSTO');
Var
   GSTCode : String[GST_CLASS_CODE_LENGTH];
   i       : Byte;
Begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  { Rate 0 is OK }
  Result := True;
  if Rate = 0 then Exit;

  with aClient.clFields do
  begin
    GSTCode := '';
    if Rate in [ 1..MAX_GST_CLASS ] then
    Begin
      //only need to compare the first character
      if ((clCountry = whNewZealand) and (clAccounting_System_Used =  snMYOBOnlineLedger)) then
      begin
        GSTCode := Copy( clGST_Class_Codes[ Rate ],1,4);
        if Trim(GSTCode) <> ''  then
          for i := 1 to 7 do If Trim(GSTCode) = ValidPLNZCodes[ i ] then Exit;
      end
      else if ((clCountry = whAustralia) and (clAccounting_System_Used =  saMYOBOnlineLedger)) then
      begin
        GSTCode := Copy( clGST_Class_Codes[ Rate ],1,4);
        if Trim(GSTCode) <> ''  then
          for i := 1 to High(ValidPLAUCodes) do If Trim(GSTCode) = ValidPLAUCodes[ i ] then Exit;
      end
      else
      begin
        GSTCode := Copy( clGST_Class_Codes[ Rate ],1,1);
        for i := vMin to vMax do If GSTCode = ValidCodes[ i ] then Exit;
      end;
    end;
    Result := False;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//------------------------------------------------------------------------------

function CASystemsGSTOK( const Rate : Byte ) : boolean;
begin
   result := CASystemsGSTOK( MyClient, Rate);
end;
//------------------------------------------------------------------------------

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
