unit BASUtils;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:   Bas Utilities

   Written: May 2000
   Authors: Steve, Matt.

   Purpose:  Provide utilities for handling the bas fields in the client file

   Notes:

   USES MyClient

   The client's data is mapped onto the various fields on the BAS form using the
   following fields:

      clBAS_Field_Number                 : Array[ 1..100 ] of Byte;

      This contains the field number of the item on the BAS form (see BKCONST.PAS ). If this
      is zero.

      clBAS_Field_Source                 : Array[ 1..100 ] of Byte;

      Set to a Tax Level [ 0 to MAX_GST_CLASS ] if the source of the data is a tax level.
      Set to 255 if the source of the data is from an account code.

      clBAS_Field_Account_Code           : Array[ 1..100 ] of String[ 20 ];

      If the clBAS_Field_Source is 255, then this field contains the account code in the chart.

      clBAS_Field_Balance_Type           : Array[ 1..100 ] of Byte;

      Are we putting in the Gross, Net or the Tax figure?

      clBAS_Field_Percent                : Array[ 1..100 ] of Money

      Do we multiple the amount by anything
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   BKConst,
   MoneyDef,
   clObj32;

CONST
   bsFrom_Chart = 255;
   MIN_SLOT     =   1;
   MAX_SLOT     = 100;

   ruAllRules   = 0;
   ruClassRules = 1;
   ruChartRules = 2;

const
   GFieldsWithRules     = [ bfG1..bfG18];
   WFieldsWithRules     = [ bfW1..bfW4];
   TotalFieldsWithRules = [ bf1C..bf6B];


Procedure ClearAll;
function  BasRuleCount( const BasFieldID : integer; RuleType : byte = ruAllRules ) : integer;
function  FindChartRule( const BasFieldID : integer; const ChartCode : string;
                         var BalanceType : Byte; var Percent : Money) : boolean;
function  AddNewRule( aFieldNo : byte; aSource : byte; aAccountCode : string;
                      aBalanceType : byte; aPercent : Money) : boolean;

function  BasIasFormType( aClient : TClientObj; IsQuarterlyStatement : boolean; PeriodEnding: Integer) : byte;

function  IsBASForm( BasFormType : byte) : boolean;
function  IsIASForm( BasFormType : byte) : boolean;

function  FieldVisible( const FieldID : integer; const FormType : byte) : boolean; overload;
function  FieldVisible( const FieldID : integer; const FormType : byte; Amount : integer) : boolean; overload;
function  FieldVisible( const FieldID : integer; const FormType : byte; Amount : Money) : boolean; overload;

function  DatesCaption( dateFrom : integer; dateTo : integer) : string;

//******************************************************************************
implementation
uses
   Globals,
   sysUtils,
   stDateSt,
   stDate,
   bkDateUtils;
//------------------------------------------------------------------------------

Procedure ClearAll;
Begin
   With MyClient.clFields do
   Begin
      FillChar( clBAS_Field_Number         , Sizeof( clBAS_Field_Number          ), 0 );
      FillChar( clBAS_Field_Source         , Sizeof( clBAS_Field_Source          ), 0 );
      FillChar( clBAS_Field_Account_Code   , Sizeof( clBAS_Field_Account_Code    ), 0 );
      FillChar( clBAS_Field_Balance_Type   , Sizeof( clBAS_Field_Balance_Type    ), 0 );
      FillChar( clBAS_Field_Percent        , Sizeof( clBAS_Field_Percent         ), 0 );
   end;
end;
//------------------------------------------------------------------------------

function  BasRuleCount( const BasFieldID : integer; RuleType : byte = ruAllRules) : integer;
var
   i       : integer;
   fNo     : integer;
   fSource : Byte;
   fCode   : String;
begin
   result := 0;
   //look thru all the slots for a rule for this field.  Can specify which type
   //of rule us checked for, or allow all rules
   for i := MIN_SLOT to MAX_SLOT do with MyClient.clFields do begin
      fNo     := clBAS_Field_Number         [ i ];
      fSource := clBAS_Field_Source         [ i ];
      fCode   := clBAS_Field_Account_Code   [ i ];
      If fNo = BasFieldID then begin
         case RuleType of
            ruAllRules   : Inc(Result);
            ruClassRules : begin
               if fSource <> bsFrom_Chart then
                  Inc( Result);
            end;
            ruChartRules : begin
               if fSource = bsFrom_Chart then
                  Inc( Result);
            end;
         end;
      end;
   end;
end;
//------------------------------------------------------------------------------

function FindChartRule( const BasFieldID : integer; const ChartCode : string;
                        var BalanceType : Byte; var Percent : Money) : boolean;
//given a bas field and chart code find the rule and return the settings
var
   i       : integer;
   fNo     : integer;
//   fSource : Byte;
   fCode   : String;
   fBalanceType : byte;
   fPercent     : Money;
begin
   result := false;
   //look thru all the slots for a rule for this field.  Can specify which type
   //of rule us checked for, or allow all rules
   for i := MIN_SLOT to MAX_SLOT do with MyClient.clFields do begin
      fNo     := clBAS_Field_Number         [ i ];
//      fSource := clBAS_Field_Source         [ i ];
      fCode   := clBAS_Field_Account_Code   [ i ];
      fBalanceType := clBAS_Field_Balance_Type[ i];
      fPercent := clBas_Field_Percent[ i];
      If ( fNo = BasFieldID) and ( fCode = ChartCode) then begin
         BalanceType := fBalanceType;
         Percent     := fPercent;
         result := true;
      end;
   end;
end;
//------------------------------------------------------------------------------

function FindEmptySlot : integer;
//returns position of empty slot, return -1 if no slots left
var
   i : integer;
begin
   result := -1;
   for i := MIN_SLOT to MAX_SLOT do
      if MyClient.clFields.clBas_Field_Number[ i] = 0 then begin
         result := i;
         exit;
      end;
end;
//------------------------------------------------------------------------------

function AddNewRule( aFieldNo : byte; aSource : byte; aAccountCode : string;
                     aBalanceType : byte; aPercent : Money) : boolean;
//find a new slot and insert the information
var
   NewSlot : integer;
begin
   result := false;
   NewSlot := FindEmptySlot;
   if NewSlot = -1 then
      Exit;

   with MyClient.clFields do begin
      clBAS_Field_Number[ NewSlot]       := aFieldNo;
      clBAS_Field_Source[ NewSlot]       := aSource;
      clBAS_Field_Account_Code[ NewSlot] := aAccountCode;
      clBAS_Field_Balance_Type[ NewSlot] := aBalanceType;
      clBAS_Field_Percent[ NewSlot]      := aPercent;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  BasIasFormType( aClient : TClientObj; IsQuarterlyStatement : boolean; PeriodEnding: Integer) : byte;
//returns the type of BAS or IAS form that should be used based on the settings
//in client
//information taken from a spreadsheet produced by ATO

  // Fuel tax only added for July 06 onwards
  function InFuelTaxPeriod: Boolean;
  begin
    Result := PeriodEnding >= bkStr2Date('01/07/06');
  end;
begin
   result := 0;

   if aClient.clFields.clGST_Period = gpMonthly then begin
      if aClient.clFields.clBAS_Include_Fuel and InFuelTaxPeriod then
        result := bsBasY
      else
        result := bsBasG;
      exit;
   end;

   if not IsQuarterlyStatement then begin
      result := bsIASI;
   end
   else begin
      case aClient.clFields.clGST_Period of
         gpQuarterly : begin
             if aClient.clFields.clBAS_Include_FBT_WET_LCT then
             begin
                if aClient.clFields.clBAS_Include_Fuel and InFuelTaxPeriod then
                  result := bsBasV
                else
                  result := bsBasC;
             end
             else begin
                if aClient.clFields.clBAS_PAYG_Instalment_Period = gpQuarterly then
                begin
                   if aClient.clFields.clBAS_Include_Fuel and InFuelTaxPeriod then
                     result := bsBasU
                   else
                     result := bsBasA;
                end
                else begin
                   if aClient.clFields.clBAS_PAYG_Withheld_Period = gpNone then
                   begin
                      if aClient.clFields.clBAS_Include_Fuel and InFuelTaxPeriod then
                        result := bsBasW
                      else
                        result := bsBasD;
                   end
                   else
                   begin
                      if aClient.clFields.clBAS_Include_Fuel and InFuelTaxPeriod then
                        result := bsBasX
                      else
                        result := bsBasF;
                   end;
                end;
             end;
         end;
         gpNone : begin
             if aClient.clFields.clBAS_Include_FBT_WET_LCT then
                result := bsIASJ
             else begin
                if aClient.clFields.clBAS_PAYG_Instalment_Period = gpQuarterly then begin
                   if aClient.clFields.clBAS_PAYG_Withheld_Period = gpNone then
                      result := bsIasB
                   else
                      result := bsIASJ;
                end
                else
                   result := bsIASI;
             end;
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  IsBASForm( BasFormType : byte) : boolean;
begin
   result := BasFormType in [ bs2000,
                              bsBasA,
                              bsBasU,
                              bsBasC,
                              bsBasV,
                              bsBasD,
                              bsBasW,
                              bsBasF,
                              bsBasX,
                              bsBasG,
                              bsBasY ];
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  IsIASForm( BasFormType : byte) : boolean;
begin
   result := BasFormType in [ bsIasB,
                              bsIASI,
                              bsIASJ,
                              bsIASN ];

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  FieldVisible( const FieldID : integer; const FormType : byte) : boolean; overload;
begin
   result := false;
   case FieldID of
      bfGSTOption1    : result := FormType in [ bsBasA, bsBasU, bsBasC, bsBasV, bsBasD, bsBasW, bsBasF, bsBasX];
      bfG1            : result := FormType in [ bsBasA, bsBasU, bsBasC, bsBasV, bsBasD, bsBasW, bsBasF, bsBasX, bsBasG, bsBasY, bsH, bsBasZ];
      bfG1IncludesGST : result := FormType in [ bsBasA, bsBasU, bsBasC, bsBasV, bsBasD, bsBasW, bsBasF, bsBasX, bsBasG, bsBasY, bsH, bsBasZ];
      bfG2IncludesGST : result := FormType in [ bsBasA, bsBasU, bsBasC, bsBasV, bsBasD, bsBasW, bsBasF, bsBasX, bsBasG, bsBasY];      
      bfG2            : result := FormType in [ bsBasA, bsBasU, bsBasC, bsBasV, bsBasD, bsBasW, bsBasF, bsBasX, bsBasG, bsBasY, bsH, bsBasZ, bsK];
      bfG3            : result := FormType in [ bsBasA, bsBasU, bsBasC, bsBasV, bsBasD, bsBasW, bsBasF, bsBasX, bsBasG, bsBasY, bsH, bsBasZ, bsK];
      bfG10           : result := FormType in [ bsBasA, bsBasU, bsBasC, bsBasV, bsBasD, bsBasW, bsBasF, bsBasX, bsBasG, bsBasY, bsH, bsBasZ, bsK];
      bfG11           : result := FormType in [ bsBasA, bsBasU, bsBasC, bsBasV, bsBasD, bsBasW, bsBasF, bsBasX, bsBasG, bsBasY, bsH, bsBasZ, bsK];
      bfGSTOption2    : result := FormType in [ bsBasA, bsBasU, bsBasC, bsBasV, bsBasD, bsBasW, bsBasF, bsBasX];
      bfGSTOption3    : result := FormType in [ bsBasA, bsBasU, bsBasC, bsBasV, bsBasD, bsBasW, bsBasF, bsBasX];

      bfW1            : result := FormType in [ bs2000, bsBASA, bsBasU, bsBasC, bsBasV, bsBasF, bsBasX, bsBasG, bsBasY, bsIasI, bsIasJ];
      bfW2            : result := FormType in [ bs2000, bsBASA, bsBasU, bsBasC, bsBasV, bsBasF, bsBasX, bsBasG, bsBasY, bsIasI, bsIasJ];
      bfW3            : result := FormType in [ bs2000, bsBASA, bsBasU, bsBasC, bsBasV, bsBasF, bsBasX, bsBasG, bsBasY, bsIasI, bsIasJ];
      bfW4            : result := FormType in [ bs2000, bsBASA, bsBasU, bsBasC, bsBasV, bsBasF, bsBasX, bsBasG, bsBasY, bsIasI, bsIasJ];

      bfF1            : result := FormType in [ bs2000, bsBasC, bsBasV, bsBasG, bsBasY, bsIASJ];
      bfF2            : result := FormType in [ bs2000, bsBasC, bsBasV, bsBasG, bsBasY, bsIASJ];
      bfF3            : result := FormType in [ bs2000, bsBasC, bsBasV, bsBasG, bsBasY, bsIASJ];
      bfF4            : result := FormType in [ bs2000, bsBasC, bsBasV, bsBasG, bsBasY, bsIASJ];

      bfT3, bfT4                : result := FormType in [ bs2000, bsBasA, bsBasU, bsBasC, bsBasV, bsBasG, bsBasY, bsIasB, bsIasJ];
      bfT1, bfT2, bfT11         : result := FormType in [ bs2000, bsBasA, bsBasU, bsBasC, bsBasV, bsBasG, bsBasY, bsIasB, bsIasJ, bsIasN];
      bfT7, bfT8, bfT9          : result := FormType in [ bsBasA, bsBasU, bsBasC, bsBasV, bsBasG, bsBasY, bsIasB, bsIasJ];
      bfT6                      : result := FormType in [ bsIasN];

      bf1a, bf1b      : result := FormType in [ bs2000, bsBasA, bsBasU, bsBasC, bsBasV, bsBasD, bsBasW, bsBasF, bsBasX, bsBasG, bsBasY, bsH, bsBasZ];
      bf1c, bf1d      : result := FormType in [ bs2000, bsBasC, bsBasV, bsBasG, bsBasY, bsH, bsBasZ];
      bf1e, bf1f      : result := FormType in [ bs2000, bsBasC, bsBasV, bsBasG, bsBasY, bsH, bsBasZ];
      bf1g            : result := FormType in [ bs2000];
      bf1h            : result := FormType in [ bsH];
      bf2a, bf2b      : result := FormType in [ bs2000, bsH];
      bf4             : result := FormType in [ bs2000, bsBasA, bsBasU, bsBasC, bsBasV, bsBasF, bsBasX, bsBasG, bsBasY, bsIasJ];
      bf5a            : result := FormType in [ bs2000, bsBasA, bsBasU, bsBasC, bsBasV, bsBasG, bsBasY, bsIasB, bsIasJ, bsIasN];
      bf5b            : result := FormType in [ bs2000, bsBasA, bsBasU, bsBasC, bsBasV, bsBasG, bsBasY, bsIasB, bsIasJ];
      bf6a, bf6b      : result := FormType in [ bs2000, bsBasC, bsBasV, bsBasG, bsBasY, bsIasJ];
      bf7             : result := FormType in [ bs2000, bsBasA, bsBasC, bsBasG, bsIasB, bsIasJ];
      bf7c            : result := FormType in [ bsBasU, bsBasV, bsBasW, bsBasX, bsBasY, bsBasZ];
      bf7d            : result := FormType in [ bsBasU, bsBasV, bsBasW, bsBasX, bsBasY, bsBasZ];
      bf8a            : result := FormType in [ bs2000, bsBasA, bsBasU, bsBasC, bsBasV, bsBasW, bsBasF, bsBasX, bsBasG, bsBasY, bsIasB, bsIasJ, bsBasZ];
      bf8b            : result := FormType in [ bs2000, bsBasA, bsBasU, bsBasC, bsBasV, bsBasW, bsBasX, bsBasG, bsBasY, bsIasJ, bsBasZ];

      bf9             : result := FormType in [ bs2000, bsBasA, bsBasU, bsBasC, bsBasV, bsBasD, bsBasW, bsBasF, bsBasX, bsBasG, bsBasY, bsIasB, bsIasI, bsIasJ, bsH, bsBasZ];
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  FieldVisible( const FieldID : integer; const FormType : byte; Amount : integer) : boolean; overload;
begin
   if Amount <> 0 then begin
      result := true;
      exit;
   end;
   result := FieldVisible( FieldID, FormType)
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  FieldVisible( const FieldID : integer; const FormType : byte; Amount : Money) : boolean; overload;
begin
   if Amount <> 0 then begin
      result := true;
      exit;
   end;
   result := FieldVisible( FieldID, FormType);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  DatesCaption( dateFrom : integer; dateTo : integer) : string;
var
   d1,d2,m1,m2,y1,y2 : integer;
begin
   // special case IAS 'N' may be yearly
   DateDiff(dateFrom, dateTo, d1, m1, y1);
   if (y1 = 0) and (m1 = 11) and (d1 >= 28) then
      result := ' for the YEAR from ' +
                StDatetoDateSTring( 'dd nnn yyyy', DateFrom, false) +
                ' to ' +
                StDateToDateString( 'dd nnn yyyy', DateTo, false)
   else
   begin
     StDateToDMY( DateFrom , d1, m1, y1);
     StDatetoDMY( DateTo , d2, m2, y2);
     if m1 = m2 then
        result := ' for the MONTH from ' + inttostr( d1) + ' to ' +
                  StDateToDateString( 'dd nnn yyyy', DateTo, false)
     else
        result := ' for the QUARTER from ' +
                  StDatetoDateSTring( 'dd nnn yyyy', DateFrom, false) +
                  ' to ' +
                  StDateToDateString( 'dd nnn yyyy', DateTo, false);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.


