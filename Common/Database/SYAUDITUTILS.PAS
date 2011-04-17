unit SYAuditUtils;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.


interface

uses
  MoneyDef;

type

  TChanged_Fields_Array = Array[ 0..254 ] of Byte;
  TShort_Name_Array = Array[ 0..100 ] of String[ 10 ];
  TLong_Name_Array = Array[ 0..100 ] of String[ 30 ];
  TGST_Class_Names_Array = Array[ 1..99 ] of String[ 60 ];
  TGST_Class_Types_Array = Array[ 1..99 ] of Byte;
  TGST_Account_Codes_Array = Array[ 1..99 ] of String[ 20 ];
  TGST_Rates_Array = Array[ 1..99, 1..5 ] of Money;
  TGST_Applies_From_Array = Array[ 1..5 ] of Integer;
  TOLD_BAS_Special_Accounts_Array = Array[ 1..10 ] of String[ 20 ];
  TGST_Class_Codes_Array = Array[ 1..99 ] of String[ 5 ];
  TBAS_Field_Number_Array = Array[ 1..100 ] of Byte;
  TBAS_Field_Source_Array = Array[ 1..100 ] of Byte;
  TBAS_Field_Account_Code_Array = Array[ 1..100 ] of String[ 20 ];
  TBAS_Field_Balance_Array = Array[ 1..100 ] of Byte;
  TEnhanced_Software_Options_Array = Array[ 1..20 ] of Boolean;
  TTAX_Applies_From_Array = Array[ 1..99, 1..5 ] of Integer;
  TTAX_Rates_Array = Array[ 1..99, 1..5 ] of Money;
  TAutomatic_Task_Creation_Flags_Array = Array[ 1..7 ] of Boolean;
  TAutomatic_Task_Reminder_Delay_Array = Array[ 1..7 ] of Integer;
  TAutomatic_Task_Closing_Flags_Array = Array[ 1..7 ] of Boolean;
  TCoded_Array = Array[ 1..36 ] of Byte;
  TFinalized_Array = Array[ 1..36 ] of Byte;
  TTransferred_Array = Array[ 1..36 ] of Byte;
  TDownloaded_Array = Array[ 1..36 ] of Byte;
  TWebNotesAvailable_Array = Array[ 1..36 ] of Byte;
  TISO_Codes_Array = Array[ 1..99 ] of String[ 3 ];

 function Short_Name_Changed(const V1, V2: TShort_Name_Array; var V3: TShort_Name_Array): boolean;
 function Long_Name_Changed(const V1, V2: TLong_Name_Array; var V3: TLong_Name_Array): boolean;
 function GST_Class_Names_Changed(const V1, V2: TGST_Class_Names_Array; var V3: TGST_Class_Names_Array): boolean;
 function GST_Class_Types_Changed(const V1, V2: TGST_Class_Types_Array; var V3: TGST_Class_Types_Array): boolean;
 function GST_Account_Codes_Changed(const V1, V2: TGST_Account_Codes_Array; var V3: TGST_Account_Codes_Array): boolean;
 function GST_Rates_Changed(const V1, V2: TGST_Rates_Array; var V3: TGST_Rates_Array): boolean;
 function GST_Applies_From_Changed(const V1, V2: TGST_Applies_From_Array; var V3: TGST_Applies_From_Array): boolean;
 function OLD_BAS_Special_Accounts_Changed(const V1, V2: TOLD_BAS_Special_Accounts_Array; var V3: TOLD_BAS_Special_Accounts_Array): boolean;
 function GST_Class_Codes_Changed(const V1, V2: TGST_Class_Codes_Array; var V3: TGST_Class_Codes_Array): boolean;
 function BAS_Field_Number_Changed(const V1, V2: TBAS_Field_Number_Array; var V3: TBAS_Field_Number_Array): boolean;
 function BAS_Field_Source_Changed(const V1, V2: TBAS_Field_Source_Array; var V3: TBAS_Field_Source_Array): boolean;
 function BAS_Field_Account_Code_Changed(const V1, V2: TBAS_Field_Account_Code_Array; var V3: TBAS_Field_Account_Code_Array): boolean;
 function BAS_Field_Balance_Changed(const V1, V2: TBAS_Field_Balance_Array; var V3: TBAS_Field_Balance_Array): boolean;
 function Enhanced_Software_Options_Changed(const V1, V2: TEnhanced_Software_Options_Array; var V3: TEnhanced_Software_Options_Array): boolean;
 function TAX_Applies_From_Changed(const V1, V2: TTAX_Applies_From_Array; var V3: TTAX_Applies_From_Array): boolean;
 function TAX_Rates_Changed(const V1, V2: TTAX_Rates_Array; var V3: TTAX_Rates_Array): boolean;
 function Automatic_Task_Creation_Flags_Changed(const V1, V2: TAutomatic_Task_Creation_Flags_Array; var V3: TAutomatic_Task_Creation_Flags_Array): boolean;
 function Automatic_Task_Reminder_Delay_Changed(const V1, V2: TAutomatic_Task_Reminder_Delay_Array; var V3: TAutomatic_Task_Reminder_Delay_Array): boolean;
 function Automatic_Task_Closing_Flags_Changed(const V1, V2: TAutomatic_Task_Closing_Flags_Array; var V3: TAutomatic_Task_Closing_Flags_Array): boolean;
 function Coded_Changed(const V1, V2: TCoded_Array; var V3: TCoded_Array): boolean;
 function Finalized_Changed(const V1, V2: TFinalized_Array; var V3: TFinalized_Array): boolean;
 function Transferred_Changed(const V1, V2: TTransferred_Array; var V3: TTransferred_Array): boolean;
 function Downloaded_Changed(const V1, V2: TDownloaded_Array; var V3: TDownloaded_Array): boolean;
 function WebNotesAvailable_Changed(const V1, V2: TWebNotesAvailable_Array; var V3: TWebNotesAvailable_Array): boolean;
 function ISO_Codes_Changed(const V1, V2: TISO_Codes_Array; var V3: TISO_Codes_Array): boolean;
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

function BAS_Field_Balance_Changed(const V1, V2: TBAS_Field_Balance_Array; var V3: TBAS_Field_Balance_Array): boolean;
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

function Enhanced_Software_Options_Changed(const V1, V2: TEnhanced_Software_Options_Array; var V3: TEnhanced_Software_Options_Array): boolean;
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

function Automatic_Task_Creation_Flags_Changed(const V1, V2: TAutomatic_Task_Creation_Flags_Array; var V3: TAutomatic_Task_Creation_Flags_Array): boolean;
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

function Automatic_Task_Reminder_Delay_Changed(const V1, V2: TAutomatic_Task_Reminder_Delay_Array; var V3: TAutomatic_Task_Reminder_Delay_Array): boolean;
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

function Automatic_Task_Closing_Flags_Changed(const V1, V2: TAutomatic_Task_Closing_Flags_Array; var V3: TAutomatic_Task_Closing_Flags_Array): boolean;
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

function Coded_Changed(const V1, V2: TCoded_Array; var V3: TCoded_Array): boolean;
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

function Finalized_Changed(const V1, V2: TFinalized_Array; var V3: TFinalized_Array): boolean;
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

function Transferred_Changed(const V1, V2: TTransferred_Array; var V3: TTransferred_Array): boolean;
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

function Downloaded_Changed(const V1, V2: TDownloaded_Array; var V3: TDownloaded_Array): boolean;
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

function WebNotesAvailable_Changed(const V1, V2: TWebNotesAvailable_Array; var V3: TWebNotesAvailable_Array): boolean;
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

function ISO_Codes_Changed(const V1, V2: TISO_Codes_Array; var V3: TISO_Codes_Array): boolean;
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
