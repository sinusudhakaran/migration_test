unit GSTUtils;
//------------------------------------------------------------------------------
{
   Title:       GST Utils

   Description: Utilities for calculating GST

   Remarks:     Sub set of routines used by bk5

   Author:      Matthew Hopkins  Aug 2001

}
//------------------------------------------------------------------------------

interface
uses
   ecObj, Moneydef, ecDefs;

const
   MAX_GST_CLASS           = 99;
   MAX_GST_CLASS_RATES     = 5;


Procedure CalculateGST( aClient : TECClient; ADate : LongInt; Account : String; Amount : Money; Var ClassNo : Byte; Var GST : Money );
Function  CalculateGSTForClass( aClient : TECClient; ADate : LongInt; Amount : Money; ClassNo : Byte): Money;

Function  GSTDifferentToDefault( aClient : TECClient; pT : pTransaction_Rec) : boolean;

implementation
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function  WhichGSTRateApplies( aClient : TECClient; ADate : LongInt ): Byte;
Var
   i : Byte;
Begin
   WhichGSTRateApplies := 0;
   With aClient.ecFields do
   Begin
      For i := MAX_GST_CLASS_RATES downto 1 do
      If ( ecGST_Applies_From[ i ] > 0 ) and ( ADate >= ecGST_Applies_From[ i ] ) then
      Begin
         WhichGSTRateApplies := i;
         exit;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function  CalculateGSTForClass( aClient : TECClient; ADate : LongInt; Amount : Money; ClassNo : Byte): Money;
VAR
   GSTInclExt  : Extended;
   GSTInclAmt  : Money;
   GSTExclExt  : Extended;
   GSTExclAmt  : Money;
   GSTRate     : Extended;
   WhichRate   : Byte;
Begin
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
         If ( aClient.ecFields.ecGST_Rates[ ClassNo, WhichRate ] = 1000000 ) then
         Begin { Special Case - ALL GST }
            CalculateGSTForClass := Amount;
            exit;
         end;
         If ( aClient.ecFields.ecGST_Rates[ ClassNo, WhichRate ] = 0 ) then
         Begin { NO GST }
            CalculateGSTForClass := 0;
            exit;
         end;

         GSTRate     := aClient.ecFields.ecGST_Rates[ ClassNo, WhichRate ] / 1000000.0; { 1250 -> 0.1250 }
         GSTInclAmt  := Amount;
         GSTInclExt  := GSTInclAmt; { $100.00 = 10000 }
         GSTExclExt  := GSTInclExt / ( 1.0 + GSTRate );
         GSTExclAmt  := Round( GSTExclExt );
         CalculateGSTForClass := GSTInclAmt - GSTExclAmt;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure CalculateGST( aClient : TECClient; ADate : LongInt; Account : String; Amount : Money; Var ClassNo : Byte; Var GST : Money );
const
   ThisMethodName = 'CalculateGST';
Begin
   ClassNo := 0;
   GST     := 0;
   ClassNo := aClient.ecChart.GSTClass( Account );
   If ClassNo in [ 1..MAX_GST_CLASS ] then GST := CalculateGSTForClass(  aClient, ADate, Amount, ClassNo );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function  GSTDifferentToDefault( aClient : TECClient; pT : pTransaction_Rec) : boolean;
//calculate default gst amount and class and see if current values are
//different
var
   DefaultGSTClass :  byte;
   DefaultGSTAmt   : money;
begin
   with pT^ do begin
      CalculateGST( aClient, txDate_Effective, txAccount, txAmount,
                    DefaultGSTClass, DefaultGSTAmt);

      result := (txGST_Class <> DefaultGSTClass) or (txGST_Amount <> DefaultGSTAmt);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
