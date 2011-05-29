unit BKAuditUtils;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.


interface

uses
  MoneyDef;

type

  TChanged_Fields_Array = MoneyDef.TChanged_Fields_Array;
  TShort_Name_Array = Array[ 0..100 ] of String[ 10 ];
  TLong_Name_Array = Array[ 0..100 ] of String[ 30 ];
  TGST_Applies_From_Array = Array[ 1..5 ] of Integer;
  TGST_Class_Names_Array = Array[ 1..99 ] of String[ 60 ];
  TGST_Class_Types_Array = Array[ 1..99 ] of Byte;
  TGST_Account_Codes_Array = Array[ 1..99 ] of String[ 20 ];
  TGST_Rates_Array = Array[ 1..99, 1..5 ] of Money;
  TOld_Division_Names_Array = Array[ 1..9 ] of String[ 40 ];
  TCF_Headings_Array = Array[ 0..40 ] of String[ 60 ];
  TPR_Headings_Array = Array[ 0..40 ] of String[ 60 ];
  TDivision_Code_List_Array = Array[ 1..9 ] of String[ 255 ];
  TOLD_BAS_Special_Accounts_Array = Array[ 1..10 ] of String[ 20 ];
  TGST_Class_Codes_Array = Array[ 1..99 ] of String[ 5 ];
  TBAS_Field_Number_Array = Array[ 1..100 ] of Byte;
  TBAS_Field_Source_Array = Array[ 1..100 ] of Byte;
  TBAS_Field_Account_Code_Array = Array[ 1..100 ] of String[ 20 ];
  TBAS_Field_Balance_Type_Array = Array[ 1..100 ] of Byte;
  TBAS_Field_Percent_Array = Array[ 1..100 ] of Money;
  TGST_Business_Percent_Array = Array[ 1..100 ] of Money;
  TGraph_Headings_Array = Array[ 0..200 ] of String[ 60 ];
  TNotes_Array = Array[ 0..200 ] of String[ 100 ];
  TBalance_Sheet_Headings_Array = Array[ 0..30 ] of String[ 40 ];
  TCashJ_Column_Order_Array = Array[ 0..32 ] of Byte;
  TCashJ_Column_Width_Array = Array[ 0..32 ] of Integer;
  TCashJ_Column_is_Hidden_Array = Array[ 0..32 ] of Boolean;
  TCashJ_Column_is_Not_Editable_Array = Array[ 0..32 ] of Boolean;
  TAcrlJ_Column_Order_Array = Array[ 0..32 ] of Byte;
  TAcrlJ_Column_Width_Array = Array[ 0..32 ] of Integer;
  TAcrlJ_Column_is_Hidden_Array = Array[ 0..32 ] of Boolean;
  TAcrlJ_Column_is_Not_Editable_Array = Array[ 0..32 ] of Boolean;
  TStockJ_Column_Order_Array = Array[ 0..32 ] of Byte;
  TStockJ_Column_Width_Array = Array[ 0..32 ] of Integer;
  TStockJ_Column_is_Hidden_Array = Array[ 0..32 ] of Boolean;
  TStockJ_Column_is_Not_Editable_Array = Array[ 0..32 ] of Boolean;
  TYrEJ_Column_Order_Array = Array[ 0..32 ] of Byte;
  TYrEJ_Column_Width_Array = Array[ 0..32 ] of Integer;
  TYrEJ_Column_is_Hidden_Array = Array[ 0..32 ] of Boolean;
  TYrEJ_Column_is_Not_Editable_Array = Array[ 0..32 ] of Boolean;
  TgstJ_Column_Order_Array = Array[ 0..32 ] of Byte;
  TgstJ_Column_Width_Array = Array[ 0..32 ] of Integer;
  TgstJ_Column_is_Hidden_Array = Array[ 0..32 ] of Boolean;
  TgstJ_Column_is_Not_Editable_Array = Array[ 0..32 ] of Boolean;
  TAll_EditMode_Journals_Array = Array[ 0..7 ] of Boolean;
  TBudget_Column_Width_Array = Array[ 0..14 ] of Integer;
  TPrint_in_Division_Array = Array[ 1..250 ] of Boolean;
  TLast_Years_Totals_SB_Only_Array = Array[ 1..12 ] of Money;
  TAccount_Array = Array[ 1..50 ] of String[ 20 ];
  TPercentage_Array = Array[ 1..50 ] of Money;
  TGST_Class_Array = Array[ 1..50 ] of Byte;
  TGST_Has_Been_Edited_Array = Array[ 1..50 ] of Boolean;
  TGL_Narration_Array = Array[ 1..50 ] of String[ 40 ];
  TBudget_Array = Array[ 0..12 ] of Money;
  TQty_Budget_Array = Array[ 0..12 ] of Money;
  TEach_Budget_Array = Array[ 0..12 ] of Money;
  TColumn_Order_Array = Array[ 0..32 ] of Byte;
  TColumn_Width_Array = Array[ 0..32 ] of Integer;
  TColumn_is_Hidden_Array = Array[ 0..32 ] of Boolean;
  TColumn_Is_Not_Editable_Array = Array[ 0..32 ] of Boolean;
  THDE_Column_Order_Array = Array[ 0..32 ] of Byte;
  THDE_Column_Width_Array = Array[ 0..32 ] of Integer;
  THDE_Column_is_Hidden_Array = Array[ 0..32 ] of Boolean;
  THDE_Column_is_Not_Editable_Array = Array[ 0..32 ] of Boolean;
  TMDE_Column_Order_Array = Array[ 0..32 ] of Byte;
  TMDE_Column_Width_Array = Array[ 0..32 ] of Integer;
  TMDE_Column_is_Hidden_Array = Array[ 0..32 ] of Boolean;
  TMDE_Column_is_Not_Editable_Array = Array[ 0..32 ] of Boolean;
  TDIS_Column_Order_Array = Array[ 0..32 ] of Byte;
  TDIS_Column_Width_Array = Array[ 0..32 ] of Integer;
  TDIS_Column_is_Hidden_Array = Array[ 0..32 ] of Boolean;
  TDIS_Column_is_Not_Editable_Array = Array[ 0..32 ] of Boolean;
  TLine_Type_Array = Array[ 1..50 ] of Byte;
  TTAX_Applies_From_Array = Array[ 1..99, 1..5 ] of Integer;
  TTAX_Rates_Array = Array[ 1..99, 1..5 ] of Money;
  TSend_Custom_Documents_List_Array = Array[ 1..10 ] of String[ 40 ];
  TCustom_SFLedger_Titles_Array = Array[ 1..1 ] of String[ 60 ];
  TSUI_Step_Done_Array = Array[ 0..32 ] of Boolean;

 function Short_Name_Changed(const V1, V2: TShort_Name_Array; var V3: TShort_Name_Array): boolean;
 function Long_Name_Changed(const V1, V2: TLong_Name_Array; var V3: TLong_Name_Array): boolean;
 function GST_Applies_From_Changed(const V1, V2: TGST_Applies_From_Array; var V3: TGST_Applies_From_Array): boolean;
 function GST_Class_Names_Changed(const V1, V2: TGST_Class_Names_Array; var V3: TGST_Class_Names_Array): boolean;
 function GST_Class_Types_Changed(const V1, V2: TGST_Class_Types_Array; var V3: TGST_Class_Types_Array): boolean;
 function GST_Account_Codes_Changed(const V1, V2: TGST_Account_Codes_Array; var V3: TGST_Account_Codes_Array): boolean;
 function GST_Rates_Changed(const V1, V2: TGST_Rates_Array; var V3: TGST_Rates_Array): boolean;
 function Old_Division_Names_Changed(const V1, V2: TOld_Division_Names_Array; var V3: TOld_Division_Names_Array): boolean;
 function CF_Headings_Changed(const V1, V2: TCF_Headings_Array; var V3: TCF_Headings_Array): boolean;
 function PR_Headings_Changed(const V1, V2: TPR_Headings_Array; var V3: TPR_Headings_Array): boolean;
 function Division_Code_List_Changed(const V1, V2: TDivision_Code_List_Array; var V3: TDivision_Code_List_Array): boolean;
 function OLD_BAS_Special_Accounts_Changed(const V1, V2: TOLD_BAS_Special_Accounts_Array; var V3: TOLD_BAS_Special_Accounts_Array): boolean;
 function GST_Class_Codes_Changed(const V1, V2: TGST_Class_Codes_Array; var V3: TGST_Class_Codes_Array): boolean;
 function BAS_Field_Number_Changed(const V1, V2: TBAS_Field_Number_Array; var V3: TBAS_Field_Number_Array): boolean;
 function BAS_Field_Source_Changed(const V1, V2: TBAS_Field_Source_Array; var V3: TBAS_Field_Source_Array): boolean;
 function BAS_Field_Account_Code_Changed(const V1, V2: TBAS_Field_Account_Code_Array; var V3: TBAS_Field_Account_Code_Array): boolean;
 function BAS_Field_Balance_Type_Changed(const V1, V2: TBAS_Field_Balance_Type_Array; var V3: TBAS_Field_Balance_Type_Array): boolean;
 function BAS_Field_Percent_Changed(const V1, V2: TBAS_Field_Percent_Array; var V3: TBAS_Field_Percent_Array): boolean;
 function GST_Business_Percent_Changed(const V1, V2: TGST_Business_Percent_Array; var V3: TGST_Business_Percent_Array): boolean;
 function Graph_Headings_Changed(const V1, V2: TGraph_Headings_Array; var V3: TGraph_Headings_Array): boolean;
 function Notes_Changed(const V1, V2: TNotes_Array; var V3: TNotes_Array): boolean;
 function Balance_Sheet_Headings_Changed(const V1, V2: TBalance_Sheet_Headings_Array; var V3: TBalance_Sheet_Headings_Array): boolean;
 function CashJ_Column_Order_Changed(const V1, V2: TCashJ_Column_Order_Array; var V3: TCashJ_Column_Order_Array): boolean;
 function CashJ_Column_Width_Changed(const V1, V2: TCashJ_Column_Width_Array; var V3: TCashJ_Column_Width_Array): boolean;
 function CashJ_Column_is_Hidden_Changed(const V1, V2: TCashJ_Column_is_Hidden_Array; var V3: TCashJ_Column_is_Hidden_Array): boolean;
 function CashJ_Column_is_Not_Editable_Changed(const V1, V2: TCashJ_Column_is_Not_Editable_Array; var V3: TCashJ_Column_is_Not_Editable_Array): boolean;
 function AcrlJ_Column_Order_Changed(const V1, V2: TAcrlJ_Column_Order_Array; var V3: TAcrlJ_Column_Order_Array): boolean;
 function AcrlJ_Column_Width_Changed(const V1, V2: TAcrlJ_Column_Width_Array; var V3: TAcrlJ_Column_Width_Array): boolean;
 function AcrlJ_Column_is_Hidden_Changed(const V1, V2: TAcrlJ_Column_is_Hidden_Array; var V3: TAcrlJ_Column_is_Hidden_Array): boolean;
 function AcrlJ_Column_is_Not_Editable_Changed(const V1, V2: TAcrlJ_Column_is_Not_Editable_Array; var V3: TAcrlJ_Column_is_Not_Editable_Array): boolean;
 function StockJ_Column_Order_Changed(const V1, V2: TStockJ_Column_Order_Array; var V3: TStockJ_Column_Order_Array): boolean;
 function StockJ_Column_Width_Changed(const V1, V2: TStockJ_Column_Width_Array; var V3: TStockJ_Column_Width_Array): boolean;
 function StockJ_Column_is_Hidden_Changed(const V1, V2: TStockJ_Column_is_Hidden_Array; var V3: TStockJ_Column_is_Hidden_Array): boolean;
 function StockJ_Column_is_Not_Editable_Changed(const V1, V2: TStockJ_Column_is_Not_Editable_Array; var V3: TStockJ_Column_is_Not_Editable_Array): boolean;
 function YrEJ_Column_Order_Changed(const V1, V2: TYrEJ_Column_Order_Array; var V3: TYrEJ_Column_Order_Array): boolean;
 function YrEJ_Column_Width_Changed(const V1, V2: TYrEJ_Column_Width_Array; var V3: TYrEJ_Column_Width_Array): boolean;
 function YrEJ_Column_is_Hidden_Changed(const V1, V2: TYrEJ_Column_is_Hidden_Array; var V3: TYrEJ_Column_is_Hidden_Array): boolean;
 function YrEJ_Column_is_Not_Editable_Changed(const V1, V2: TYrEJ_Column_is_Not_Editable_Array; var V3: TYrEJ_Column_is_Not_Editable_Array): boolean;
 function gstJ_Column_Order_Changed(const V1, V2: TgstJ_Column_Order_Array; var V3: TgstJ_Column_Order_Array): boolean;
 function gstJ_Column_Width_Changed(const V1, V2: TgstJ_Column_Width_Array; var V3: TgstJ_Column_Width_Array): boolean;
 function gstJ_Column_is_Hidden_Changed(const V1, V2: TgstJ_Column_is_Hidden_Array; var V3: TgstJ_Column_is_Hidden_Array): boolean;
 function gstJ_Column_is_Not_Editable_Changed(const V1, V2: TgstJ_Column_is_Not_Editable_Array; var V3: TgstJ_Column_is_Not_Editable_Array): boolean;
 function All_EditMode_Journals_Changed(const V1, V2: TAll_EditMode_Journals_Array; var V3: TAll_EditMode_Journals_Array): boolean;
 function Budget_Column_Width_Changed(const V1, V2: TBudget_Column_Width_Array; var V3: TBudget_Column_Width_Array): boolean;
 function Print_in_Division_Changed(const V1, V2: TPrint_in_Division_Array; var V3: TPrint_in_Division_Array): boolean;
 function Last_Years_Totals_SB_Only_Changed(const V1, V2: TLast_Years_Totals_SB_Only_Array; var V3: TLast_Years_Totals_SB_Only_Array): boolean;
 function Account_Changed(const V1, V2: TAccount_Array; var V3: TAccount_Array): boolean;
 function Percentage_Changed(const V1, V2: TPercentage_Array; var V3: TPercentage_Array): boolean;
 function GST_Class_Changed(const V1, V2: TGST_Class_Array; var V3: TGST_Class_Array): boolean;
 function GST_Has_Been_Edited_Changed(const V1, V2: TGST_Has_Been_Edited_Array; var V3: TGST_Has_Been_Edited_Array): boolean;
 function GL_Narration_Changed(const V1, V2: TGL_Narration_Array; var V3: TGL_Narration_Array): boolean;
 function Budget_Changed(const V1, V2: TBudget_Array; var V3: TBudget_Array): boolean;
 function Qty_Budget_Changed(const V1, V2: TQty_Budget_Array; var V3: TQty_Budget_Array): boolean;
 function Each_Budget_Changed(const V1, V2: TEach_Budget_Array; var V3: TEach_Budget_Array): boolean;
 function Column_Order_Changed(const V1, V2: TColumn_Order_Array; var V3: TColumn_Order_Array): boolean;
 function Column_Width_Changed(const V1, V2: TColumn_Width_Array; var V3: TColumn_Width_Array): boolean;
 function Column_is_Hidden_Changed(const V1, V2: TColumn_is_Hidden_Array; var V3: TColumn_is_Hidden_Array): boolean;
 function Column_Is_Not_Editable_Changed(const V1, V2: TColumn_Is_Not_Editable_Array; var V3: TColumn_Is_Not_Editable_Array): boolean;
 function HDE_Column_Order_Changed(const V1, V2: THDE_Column_Order_Array; var V3: THDE_Column_Order_Array): boolean;
 function HDE_Column_Width_Changed(const V1, V2: THDE_Column_Width_Array; var V3: THDE_Column_Width_Array): boolean;
 function HDE_Column_is_Hidden_Changed(const V1, V2: THDE_Column_is_Hidden_Array; var V3: THDE_Column_is_Hidden_Array): boolean;
 function HDE_Column_is_Not_Editable_Changed(const V1, V2: THDE_Column_is_Not_Editable_Array; var V3: THDE_Column_is_Not_Editable_Array): boolean;
 function MDE_Column_Order_Changed(const V1, V2: TMDE_Column_Order_Array; var V3: TMDE_Column_Order_Array): boolean;
 function MDE_Column_Width_Changed(const V1, V2: TMDE_Column_Width_Array; var V3: TMDE_Column_Width_Array): boolean;
 function MDE_Column_is_Hidden_Changed(const V1, V2: TMDE_Column_is_Hidden_Array; var V3: TMDE_Column_is_Hidden_Array): boolean;
 function MDE_Column_is_Not_Editable_Changed(const V1, V2: TMDE_Column_is_Not_Editable_Array; var V3: TMDE_Column_is_Not_Editable_Array): boolean;
 function DIS_Column_Order_Changed(const V1, V2: TDIS_Column_Order_Array; var V3: TDIS_Column_Order_Array): boolean;
 function DIS_Column_Width_Changed(const V1, V2: TDIS_Column_Width_Array; var V3: TDIS_Column_Width_Array): boolean;
 function DIS_Column_is_Hidden_Changed(const V1, V2: TDIS_Column_is_Hidden_Array; var V3: TDIS_Column_is_Hidden_Array): boolean;
 function DIS_Column_is_Not_Editable_Changed(const V1, V2: TDIS_Column_is_Not_Editable_Array; var V3: TDIS_Column_is_Not_Editable_Array): boolean;
 function Line_Type_Changed(const V1, V2: TLine_Type_Array; var V3: TLine_Type_Array): boolean;
 function TAX_Applies_From_Changed(const V1, V2: TTAX_Applies_From_Array; var V3: TTAX_Applies_From_Array): boolean;
 function TAX_Rates_Changed(const V1, V2: TTAX_Rates_Array; var V3: TTAX_Rates_Array): boolean;
 function Send_Custom_Documents_List_Changed(const V1, V2: TSend_Custom_Documents_List_Array; var V3: TSend_Custom_Documents_List_Array): boolean;
 function Custom_SFLedger_Titles_Changed(const V1, V2: TCustom_SFLedger_Titles_Array; var V3: TCustom_SFLedger_Titles_Array): boolean;
 function SUI_Step_Done_Changed(const V1, V2: TSUI_Step_Done_Array; var V3: TSUI_Step_Done_Array): boolean;
 function Changed_Fields_Changed(const V1, V2: TChanged_Fields_Array; var V3: TChanged_Fields_Array): boolean;

implementation

function Short_Name_Changed(const V1, V2: TShort_Name_Array; var V3: TShort_Name_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Long_Name_Changed(const V1, V2: TLong_Name_Array; var V3: TLong_Name_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function GST_Applies_From_Changed(const V1, V2: TGST_Applies_From_Array; var V3: TGST_Applies_From_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function GST_Class_Names_Changed(const V1, V2: TGST_Class_Names_Array; var V3: TGST_Class_Names_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function GST_Class_Types_Changed(const V1, V2: TGST_Class_Types_Array; var V3: TGST_Class_Types_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function GST_Account_Codes_Changed(const V1, V2: TGST_Account_Codes_Array; var V3: TGST_Account_Codes_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function GST_Rates_Changed(const V1, V2: TGST_Rates_Array; var V3: TGST_Rates_Array): boolean;
var
  i, j: integer;
begin
  Result := False;
  for i := Low(V1) to High(V1) do
    for j := Low(V1[i]) to High(V1[i]) do
      if V1[i, j] <> V2[i, j] then begin
        Result := True;
        Break;
      end;
  if Result then
    for i := Low(V1) to High(V1) do
      for j := Low(V1[i]) to High(V1[i]) do
        V3[i, j] := V1[i, j];
end;

function Old_Division_Names_Changed(const V1, V2: TOld_Division_Names_Array; var V3: TOld_Division_Names_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function CF_Headings_Changed(const V1, V2: TCF_Headings_Array; var V3: TCF_Headings_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function PR_Headings_Changed(const V1, V2: TPR_Headings_Array; var V3: TPR_Headings_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Division_Code_List_Changed(const V1, V2: TDivision_Code_List_Array; var V3: TDivision_Code_List_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function OLD_BAS_Special_Accounts_Changed(const V1, V2: TOLD_BAS_Special_Accounts_Array; var V3: TOLD_BAS_Special_Accounts_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function GST_Class_Codes_Changed(const V1, V2: TGST_Class_Codes_Array; var V3: TGST_Class_Codes_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function BAS_Field_Number_Changed(const V1, V2: TBAS_Field_Number_Array; var V3: TBAS_Field_Number_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function BAS_Field_Source_Changed(const V1, V2: TBAS_Field_Source_Array; var V3: TBAS_Field_Source_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function BAS_Field_Account_Code_Changed(const V1, V2: TBAS_Field_Account_Code_Array; var V3: TBAS_Field_Account_Code_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function BAS_Field_Balance_Type_Changed(const V1, V2: TBAS_Field_Balance_Type_Array; var V3: TBAS_Field_Balance_Type_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function BAS_Field_Percent_Changed(const V1, V2: TBAS_Field_Percent_Array; var V3: TBAS_Field_Percent_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function GST_Business_Percent_Changed(const V1, V2: TGST_Business_Percent_Array; var V3: TGST_Business_Percent_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Graph_Headings_Changed(const V1, V2: TGraph_Headings_Array; var V3: TGraph_Headings_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Notes_Changed(const V1, V2: TNotes_Array; var V3: TNotes_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Balance_Sheet_Headings_Changed(const V1, V2: TBalance_Sheet_Headings_Array; var V3: TBalance_Sheet_Headings_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function CashJ_Column_Order_Changed(const V1, V2: TCashJ_Column_Order_Array; var V3: TCashJ_Column_Order_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function CashJ_Column_Width_Changed(const V1, V2: TCashJ_Column_Width_Array; var V3: TCashJ_Column_Width_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function CashJ_Column_is_Hidden_Changed(const V1, V2: TCashJ_Column_is_Hidden_Array; var V3: TCashJ_Column_is_Hidden_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function CashJ_Column_is_Not_Editable_Changed(const V1, V2: TCashJ_Column_is_Not_Editable_Array; var V3: TCashJ_Column_is_Not_Editable_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function AcrlJ_Column_Order_Changed(const V1, V2: TAcrlJ_Column_Order_Array; var V3: TAcrlJ_Column_Order_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function AcrlJ_Column_Width_Changed(const V1, V2: TAcrlJ_Column_Width_Array; var V3: TAcrlJ_Column_Width_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function AcrlJ_Column_is_Hidden_Changed(const V1, V2: TAcrlJ_Column_is_Hidden_Array; var V3: TAcrlJ_Column_is_Hidden_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function AcrlJ_Column_is_Not_Editable_Changed(const V1, V2: TAcrlJ_Column_is_Not_Editable_Array; var V3: TAcrlJ_Column_is_Not_Editable_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function StockJ_Column_Order_Changed(const V1, V2: TStockJ_Column_Order_Array; var V3: TStockJ_Column_Order_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function StockJ_Column_Width_Changed(const V1, V2: TStockJ_Column_Width_Array; var V3: TStockJ_Column_Width_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function StockJ_Column_is_Hidden_Changed(const V1, V2: TStockJ_Column_is_Hidden_Array; var V3: TStockJ_Column_is_Hidden_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function StockJ_Column_is_Not_Editable_Changed(const V1, V2: TStockJ_Column_is_Not_Editable_Array; var V3: TStockJ_Column_is_Not_Editable_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function YrEJ_Column_Order_Changed(const V1, V2: TYrEJ_Column_Order_Array; var V3: TYrEJ_Column_Order_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function YrEJ_Column_Width_Changed(const V1, V2: TYrEJ_Column_Width_Array; var V3: TYrEJ_Column_Width_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function YrEJ_Column_is_Hidden_Changed(const V1, V2: TYrEJ_Column_is_Hidden_Array; var V3: TYrEJ_Column_is_Hidden_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function YrEJ_Column_is_Not_Editable_Changed(const V1, V2: TYrEJ_Column_is_Not_Editable_Array; var V3: TYrEJ_Column_is_Not_Editable_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function gstJ_Column_Order_Changed(const V1, V2: TgstJ_Column_Order_Array; var V3: TgstJ_Column_Order_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function gstJ_Column_Width_Changed(const V1, V2: TgstJ_Column_Width_Array; var V3: TgstJ_Column_Width_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function gstJ_Column_is_Hidden_Changed(const V1, V2: TgstJ_Column_is_Hidden_Array; var V3: TgstJ_Column_is_Hidden_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function gstJ_Column_is_Not_Editable_Changed(const V1, V2: TgstJ_Column_is_Not_Editable_Array; var V3: TgstJ_Column_is_Not_Editable_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function All_EditMode_Journals_Changed(const V1, V2: TAll_EditMode_Journals_Array; var V3: TAll_EditMode_Journals_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Budget_Column_Width_Changed(const V1, V2: TBudget_Column_Width_Array; var V3: TBudget_Column_Width_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Print_in_Division_Changed(const V1, V2: TPrint_in_Division_Array; var V3: TPrint_in_Division_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Last_Years_Totals_SB_Only_Changed(const V1, V2: TLast_Years_Totals_SB_Only_Array; var V3: TLast_Years_Totals_SB_Only_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Account_Changed(const V1, V2: TAccount_Array; var V3: TAccount_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Percentage_Changed(const V1, V2: TPercentage_Array; var V3: TPercentage_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function GST_Class_Changed(const V1, V2: TGST_Class_Array; var V3: TGST_Class_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function GST_Has_Been_Edited_Changed(const V1, V2: TGST_Has_Been_Edited_Array; var V3: TGST_Has_Been_Edited_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function GL_Narration_Changed(const V1, V2: TGL_Narration_Array; var V3: TGL_Narration_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Budget_Changed(const V1, V2: TBudget_Array; var V3: TBudget_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Qty_Budget_Changed(const V1, V2: TQty_Budget_Array; var V3: TQty_Budget_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Each_Budget_Changed(const V1, V2: TEach_Budget_Array; var V3: TEach_Budget_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Column_Order_Changed(const V1, V2: TColumn_Order_Array; var V3: TColumn_Order_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Column_Width_Changed(const V1, V2: TColumn_Width_Array; var V3: TColumn_Width_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Column_is_Hidden_Changed(const V1, V2: TColumn_is_Hidden_Array; var V3: TColumn_is_Hidden_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Column_Is_Not_Editable_Changed(const V1, V2: TColumn_Is_Not_Editable_Array; var V3: TColumn_Is_Not_Editable_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function HDE_Column_Order_Changed(const V1, V2: THDE_Column_Order_Array; var V3: THDE_Column_Order_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function HDE_Column_Width_Changed(const V1, V2: THDE_Column_Width_Array; var V3: THDE_Column_Width_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function HDE_Column_is_Hidden_Changed(const V1, V2: THDE_Column_is_Hidden_Array; var V3: THDE_Column_is_Hidden_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function HDE_Column_is_Not_Editable_Changed(const V1, V2: THDE_Column_is_Not_Editable_Array; var V3: THDE_Column_is_Not_Editable_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function MDE_Column_Order_Changed(const V1, V2: TMDE_Column_Order_Array; var V3: TMDE_Column_Order_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function MDE_Column_Width_Changed(const V1, V2: TMDE_Column_Width_Array; var V3: TMDE_Column_Width_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function MDE_Column_is_Hidden_Changed(const V1, V2: TMDE_Column_is_Hidden_Array; var V3: TMDE_Column_is_Hidden_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function MDE_Column_is_Not_Editable_Changed(const V1, V2: TMDE_Column_is_Not_Editable_Array; var V3: TMDE_Column_is_Not_Editable_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function DIS_Column_Order_Changed(const V1, V2: TDIS_Column_Order_Array; var V3: TDIS_Column_Order_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function DIS_Column_Width_Changed(const V1, V2: TDIS_Column_Width_Array; var V3: TDIS_Column_Width_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function DIS_Column_is_Hidden_Changed(const V1, V2: TDIS_Column_is_Hidden_Array; var V3: TDIS_Column_is_Hidden_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function DIS_Column_is_Not_Editable_Changed(const V1, V2: TDIS_Column_is_Not_Editable_Array; var V3: TDIS_Column_is_Not_Editable_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Line_Type_Changed(const V1, V2: TLine_Type_Array; var V3: TLine_Type_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function TAX_Applies_From_Changed(const V1, V2: TTAX_Applies_From_Array; var V3: TTAX_Applies_From_Array): boolean;
var
  i, j: integer;
begin
  Result := False;
  for i := Low(V1) to High(V1) do
    for j := Low(V1[i]) to High(V1[i]) do
      if V1[i, j] <> V2[i, j] then begin
        Result := True;
        Break;
      end;
  if Result then
    for i := Low(V1) to High(V1) do
      for j := Low(V1[i]) to High(V1[i]) do
        V3[i, j] := V1[i, j];
end;

function TAX_Rates_Changed(const V1, V2: TTAX_Rates_Array; var V3: TTAX_Rates_Array): boolean;
var
  i, j: integer;
begin
  Result := False;
  for i := Low(V1) to High(V1) do
    for j := Low(V1[i]) to High(V1[i]) do
      if V1[i, j] <> V2[i, j] then begin
        Result := True;
        Break;
      end;
  if Result then
    for i := Low(V1) to High(V1) do
      for j := Low(V1[i]) to High(V1[i]) do
        V3[i, j] := V1[i, j];
end;

function Send_Custom_Documents_List_Changed(const V1, V2: TSend_Custom_Documents_List_Array; var V3: TSend_Custom_Documents_List_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function Custom_SFLedger_Titles_Changed(const V1, V2: TCustom_SFLedger_Titles_Array; var V3: TCustom_SFLedger_Titles_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

function SUI_Step_Done_Changed(const V1, V2: TSUI_Step_Done_Array; var V3: TSUI_Step_Done_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;


function Changed_Fields_Changed(const V1, V2: TChanged_Fields_Array; var V3: TChanged_Fields_Array): boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(V1) to High(V2) do
    if V1[i] <> V2[i] then begin
      Result := True;
      Break;
    end;
  if Result then
    for i := Low(V1) to High(V1) do
        V3[i] := V1[i];
end;

end.
