unit GSTCALC32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Returns the GST values applicable to the specified client.
//Is used by AutoCode so cannot call anything that uses the global Client object
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
INTERFACE
USES
   MONEYDEF,
   BKDEFS,
   clObj32;

Function  WhichGSTRateApplies( aClient : TClientObj; ADate : LongInt ): Byte;
Function  CalculateGSTForClass( aClient : TClientObj; ADate : LongInt; Amount : Money; ClassNo : Byte ): Money;
Procedure CalculateGST( aClient : TClientObj; ADate : LongInt; Account : String; Amount : Money; Var ClassNo : Byte; Var GST : Money );
Function  CalculateGSTFromNett( aClient : TClientObj; ADate : LongInt; Amount : Money; ClassNo : Byte; RoundToWholeValue: boolean; AmountIncludesTax: boolean = false ): double;

Function  GetGSTClassNo( aClient : TClientObj; ClassCode : String ) : Byte;
Function  GetGSTClassCode( aClient : TClientObj; No : byte ): string;
Function  GetGSTClassRate( aClient : TClientObj; aDate : integer; ClassNo : byte ): Extended;
Function  GetGSTClassPercent( aClient : TClientObj; aDate : integer; ClassNo : byte ): Money;

Function  GSTDifferentToDefault( aClient : TClientObj; pT : pTransaction_Rec) : boolean;

function  GetGSTTotalForDissection( pT : pTransaction_Rec) : Money;

//******************************************************************************
IMPLEMENTATION USES
  //GLOBALS,
  glConst,
  logutil,
  math,
  sysutils,
  stStrs,
  ForexHelpers;

const
   UnitName = 'GSTCALC32';
var
   DebugMe : boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function  WhichGSTRateApplies( aClient : TClientObj; ADate : LongInt ): Byte;
const
   ThisMethodName = 'WhichGSTRateApplies';
Var
   i : Byte;
Begin
   WhichGSTRateApplies := 0;
   With aClient.clFields do
   Begin
      For i := MAX_GST_CLASS_RATES downto 1 do
      If ( clGST_Applies_From[ i ] > 0 ) and ( ADate >= clGST_Applies_From[ i ] ) then
      Begin
         WhichGSTRateApplies := i;
         exit;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function  CalculateGSTForClass( aClient : TClientObj; ADate : LongInt; Amount : Money; ClassNo : Byte): Money;
const
   ThisMethodName = 'CalculateGSTForClass';
VAR
   GSTInclExt  : Extended;
   GSTInclAmt  : Money;
   GSTExclExt  : Extended;
   GSTExclAmt  : Money;
   GSTRate     : Extended;
   WhichRate   : Byte;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
   CalculateGSTForClass := 0;

   If ( ClassNo in [ 0.. MAX_GST_CLASS ] ) then
   Begin
      WhichRate := WhichGSTRateApplies( aClient, ADate );
      If WhichRate = 0 then
      Begin { Earlier than the first date, so no GST }
         CalculateGSTForClass := 0;
         exit;
      end;

      If ClassNo in [ 1..MAX_GST_CLASS ] then
      Begin
         If ( aClient.clFields.clGST_Rates[ ClassNo, WhichRate ] = 1000000 ) then
         Begin { Special Case - ALL GST }
            CalculateGSTForClass := Amount;
            exit;
         end;
         If ( aClient.clFields.clGST_Rates[ ClassNo, WhichRate ] = 0 ) then
         Begin { NO GST }
            CalculateGSTForClass := 0;
            exit;
         end;

         GSTRate     := aClient.clFields.clGST_Rates[ ClassNo, WhichRate ] / 1000000.0; { 1250 -> 0.1250 }
         GSTInclAmt  := Amount;
         GSTInclExt  := GSTInclAmt; { $100.00 = 10000 }
         GSTExclExt  := GSTInclExt / ( 1.0 + GSTRate );
         GSTExclAmt  := Round( GSTExclExt );
         CalculateGSTForClass := GSTInclAmt - GSTExclAmt;
      end;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure CalculateGST( aClient : TClientObj; ADate : LongInt; Account : String; Amount : Money; Var ClassNo : Byte; Var GST : Money );
const
   ThisMethodName = 'CalculateGST';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   ClassNo := 0;
   GST     := 0;
   ClassNo := aClient.clChart.GSTClass( Account );
   If ClassNo in [ 1..MAX_GST_CLASS ] then GST := CalculateGSTForClass(  aClient, ADate, Amount, ClassNo );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function  CalculateGSTFromNett( aClient : TClientObj; ADate : LongInt; Amount : Money; ClassNo : Byte; RoundToWholeValue: boolean; AmountIncludesTax: boolean): double;
const
   ThisMethodName = 'CalculateGSTFromNett';
VAR
   TaxAmtExt     : Extended;
   TaxRate       : Extended;
   WhichRate     : Byte;
   OldRoundMode  : TFPURoundingMode;
   RoundUpHalves : boolean;
   Remainder     : Extended;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   CalculateGSTFromNett := 0;
   WhichRate := WhichGSTRateApplies( aClient, ADate );
   If ( ClassNo in [ 1..MAX_GST_CLASS ] ) and ( WhichRate in [ 1..MAX_GST_CLASS_RATES ] ) then
   Begin
      If ( aClient.clFields.clGST_Rates[ ClassNo, WhichRate ] = 1000000 ) then
      Begin { Special Case - ALL GST }
         CalculateGSTFromNett := Amount;
         exit;
      end;
      If ( aClient.clFields.clGST_Rates[ ClassNo, WhichRate ] = 0 ) then exit;

      TaxRate     := aClient.clFields.clGST_Rates[ ClassNo, WhichRate ] / 1000000.0; { 1250 -> 0.1250 }
      if AmountIncludesTax then
        // In this case we have passed in the amount including tax, this gives us the tax component of that
        // amount. Eg. if you have 15% tax and you pass in $115, this should return $100, because $100 +
        // 15% tax = $115
        TaxAmtExt   := Amount - (Amount / (1 + TaxRate))
      else
        TaxAmtExt   := Amount * TaxRate;
      if RoundToWholeValue then
      begin
        // RoundUpHalves := TaxAmtExt - Trunc(TaxAmtExt) = 0.5;
        Remainder := TaxAmtExt - Trunc(TaxAmtExt);
        RoundUpHalves := abs(Remainder - 0.5) < 0.0000001;
        OldRoundMode := GetRoundMode; // would put this in the if statement below but then I get a compiler warning
        if RoundUpHalves then
          SetRoundMode(rmUp);
        Result := Round( TaxAmtExt );
        if RoundUpHalves then
          SetRoundMode(OldRoundMode);
      end else
        Result := TaxAmtExt;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function  GetGSTClassNo( aClient : TClientObj; ClassCode : String ) : Byte;
//given a class code string return the gst class no with this code
//assume that class code has been trimmed already.  Codes will be compared case insensitive
const
   ThisMethodName = 'GetGSTClassNo';
Var
   i : Byte;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
   result := 0;
   If ClassCode = '' then begin
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Returned 0');
      exit;
   end;

   with aClient.clFields do begin
      for i := 1 to MAX_GST_CLASS do begin
         if UpperCase(  clGST_Class_Codes[ i]) = UpperCase( ClassCode) then
            result := i;
      end;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Returned'+inttostr(result));
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function GetGSTClassCode( aClient : TClientObj; No : Byte ): String;
const
   ThisMethodName = 'GetGSTClassCode';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
   result := ' ';

   If No in [ 1..MAX_GST_CLASS ] then
      result := aClient.clFields.clGST_Class_Codes[ No];

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' '+result);
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//------------------------------------------------------------------------------

Function  GetGSTClassRate( aClient : TClientObj; aDate : integer; ClassNo : byte ): Extended;
const
   ThisMethodName = 'GetGSTClassRate';
var
   WhichRate   : Byte;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
   Result := GetGSTClassPercent( aClient, aDate, ClassNo) / 1000000.0; { 1250 -> 0.1250 }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

Function  GetGSTClassPercent( aClient : TClientObj; aDate : integer; ClassNo : byte ): Money;
const
   ThisMethodName = 'GetGSTClassPercent';
var
   WhichRate   : Byte;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
   result := 0;
   If ( ClassNo in [ 1.. MAX_GST_CLASS ] ) then begin
      WhichRate := WhichGSTRateApplies( aClient, ADate );
      If WhichRate = 0 then begin { Earlier than the first date, so no GST }
         exit;
      end;
      result := aClient.clFields.clGST_Rates[ ClassNo, WhichRate ];
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

Function  GSTDifferentToDefault( aClient : TClientObj; pT : pTransaction_Rec) : boolean;
//calculate default gst amount and class and see if current values are
//different
var
   DefaultGSTClass :  byte;
   DefaultGSTAmt   : money;
begin
   with pT^ do begin
      CalculateGST( aClient, txDate_Effective, txAccount, Local_Amount,
                    DefaultGSTClass, DefaultGSTAmt);

      result := (txGST_Class <> DefaultGSTClass) or (txGST_Amount <> DefaultGSTAmt);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  GetGSTTotalForDissection( pT : pTransaction_Rec) : Money;
var
   pD : pDissection_Rec;
begin
   result := 0;
   pD := pT^.txFirst_Dissection;
   while ( pD <> nil) do begin
      result := result + pD^.dsGST_Amount;
      pD := pD^.dsNext;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
END.





