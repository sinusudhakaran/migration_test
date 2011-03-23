{-----------------------------------------------------------------------------
 Unit Name: DBAUDIT
 Author:    scott.wilson
 Date:      08-Mar-2011
 Purpose:   Generates xxAudit.pas with functions to return a table
            name or field name using tokens generated from xx.txt as
            parameters.
 History:
-----------------------------------------------------------------------------}

unit DBAUDIT;

interface

procedure GenerateAuditFiles(SysName: string);
procedure GenerateAuditUtils(SysName: string);
procedure GenerateAuditCompare(SysName: string);

implementation

uses
  DBMisc, ReadF, StDate, StDateSt, SysUtils, Classes, DBObj;

function MakeName(S: string): string;
var
  O: string;
  i: Integer;
begin
  O:=S;
  for i := 1 to Length(O) do
    if not (O[i] in ['a'..'z','0'..'9','_','A'..'Z'] ) then
      O[i] := '_';
  Result := O;
end;

function WS(S: string): string;
begin
  Result := '';
  if (Length(S) < 32) then
    Result := ConstStr(' ', 32-Length(S));
end;

procedure GenerateAuditFiles(SysName: string);
var
  AuditConstFile: Text;
  TableName: string[60];
  Prefix: string[2];
  AuditConstFileName: String;
  TokenNo, TableBeginToken: Integer;
  LineType: string[10];
  AuditFieldIndex: integer;
  FieldName, AuditFieldName: string[60];
  FieldCode: string[10];
  FieldType: TFieldType;
  FieldParams: string;
begin
  TokenNo := 0;
  TableBeginToken := 0;

  //Open files
  if not OpenImportFile(SysName + '.TXT') then Halt( 1 );
  AuditConstFileName := UpperCase(SysName) + 'AUDIT.PAS';
  Assign(AuditConstFile, AuditConstFileName);
  Rewrite(AuditConstFile);

  //Write static code
  Writeln( AuditConstFile, 'unit ',SysName,'AUDIT;' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, '// This code was generated automatically by running DBGen' );
  Writeln( AuditConstFile, '// Do not change it - any changes you make will disappear' );
  Writeln( AuditConstFile, '// when DBGen is run again.' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'interface' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'uses' );
  Writeln( AuditConstFile, '  SysUtils;' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'type' );
  Writeln( AuditConstFile, 'TAuditTableArray = array[byte] of string;' );
  Writeln( AuditConstFile, 'TAuditNamesArray = array[byte, byte] of string;' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'T' + SysName + 'AuditNames = class(TObject)' );
  Writeln( AuditConstFile, 'private' );
  Writeln( AuditConstFile, '  FAuditNamesArray: TAuditNamesArray;' );
  Writeln( AuditConstFile, '  FAuditTableArray: TAuditTableArray;' );
  Writeln( AuditConstFile, '  procedure FillArray;' );
  Writeln( AuditConstFile, 'public' );
  Writeln( AuditConstFile, '  constructor Create;' );
  Writeln( AuditConstFile, '  function GetAuditTableName(ATable: byte): string;' );
  Writeln( AuditConstFile, '  function GetAuditFieldName(ATable, AField: byte): string;' );
  Writeln( AuditConstFile, 'end;' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'function ' + SysName + 'AuditNames: T' + SysName + 'AuditNames;' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'implementation' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'var' );
  Writeln( AuditConstFile, '  _AuditNames: T' + SysName + 'AuditNames;' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'function ' + SysName + 'AuditNames: T' + SysName + 'AuditNames;' );
  Writeln( AuditConstFile, 'begin' );
  Writeln( AuditConstFile, '  if not Assigned(_AuditNames) then' );
  Writeln( AuditConstFile, '    _AuditNames := T' + SysName + 'AuditNames.Create;' );
  Writeln( AuditConstFile, '  Result := _AuditNames;' );
  Writeln( AuditConstFile, 'end;' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, '{ TAuditNames }' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'constructor T' + SysName + 'AuditNames.Create;' );
  Writeln( AuditConstFile, 'begin' );
  Writeln( AuditConstFile, '  FillArray;' );
  Writeln( AuditConstFile, 'end;' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'function T' + SysName + 'AuditNames.GetAuditFieldName(ATable, AField: byte): string;' );
  Writeln( AuditConstFile, 'begin' );
  Writeln( AuditConstFile, '  Result := FAuditNamesArray[ATable, AField];' );
  Writeln( AuditConstFile, 'end;' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'function T' + SysName + 'AuditNames.GetAuditTableName(ATable: byte): string;' );
  Writeln( AuditConstFile, 'begin' );
  Writeln( AuditConstFile, '  Result := FAuditTableArray[ATable];' );
  Writeln( AuditConstFile, 'end;' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'procedure T' + SysName + 'AuditNames.FillArray;' );
  Writeln( AuditConstFile, 'var' );
  Writeln( AuditConstFile, '  i, j: integer;' );
  Writeln( AuditConstFile, 'begin' );
  Writeln( AuditConstFile, '  //Clear arrays' );
  Writeln( AuditConstFile, '  for i := 0 to High(FAuditNamesArray) do begin' );
  Writeln( AuditConstFile, '    FAuditTableArray[i] := '''';' );
  Writeln( AuditConstFile, '    for j := 0 to High(FAuditNamesArray[i]) do' );
  Writeln( AuditConstFile, '      FAuditNamesArray[i, j] := '''';' );
  Writeln( AuditConstFile, '  end;' );

  //Generate variable code
  while not EndOfImportFile do begin
    ReadLine;
    if NoOfFields > 0 then begin
      LineType := GetAField(1);
      if LineType='N' then begin
        //Table names
        if (NoOfFields < 4) then begin
          Writeln( 'Error: Too Few Fields on line ', LineNumber );
          Halt;
        end;
        TableName := MakeName( GetAField( 2 ) );
        Prefix := GetAField( 3 );
        TableBeginToken := GetLField( 4 );
        Writeln( AuditConstFile, '   FAuditTableArray[', TableBeginToken, '] := ''', TableName, ''';');
        TokenNo := TableBeginToken;
        Inc( TokenNo );
      end else if LineType='F' then begin
        //Field names
        FieldName := MakeName( GetAField( 2 ) );
        FieldCode := GetAField( 3 );

        FieldType := DBObj.FindFieldType( FieldCode );
        FieldParams := FieldType.fReadVars;
        AuditFieldIndex := 4;
        //Add length filed
        if (FieldType.fCode <> 'AS') and (FieldType.fCode <> 'Y') and
           (FieldType.fCode <> 'L')  and (FieldType.fCode <> 'B') then
          Inc(AuditFieldIndex);
        //Add parameter fields
        while (Pos(',', FieldParams) > 0) do begin
          Inc(AuditFieldIndex);
          FieldParams := Copy(FieldParams, Pos(',', FieldParams) + 1, length(FieldParams));
        end;

        AuditFieldName := GetAField( AuditFieldIndex );

        if AuditFieldName = '' then
          Writeln( AuditConstFile, '    FAuditNamesArray[', TableBeginToken, ',', TokenNo, '] := ''', FieldName, ''';')
        else
          Writeln( AuditConstFile, '    FAuditNamesArray[', TableBeginToken, ',', TokenNo, '] := ''', AuditFieldName, '''; //', FieldName);
        Inc( TokenNo );
      end else if (LineType = 'E') then begin
        //EOF
        Writeln( AuditConstFile );
      end;
    end;
  end;

  //More static code
  Writeln( AuditConstFile, 'end;' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'initialization' );
  Writeln( AuditConstFile, '  _AuditNames := nil;' );
  Writeln( AuditConstFile, 'finalization' );
  Writeln( AuditConstFile, '  if Assigned(_AuditNames) then' );
  Writeln( AuditConstFile, '    FreeAndNil(_AuditNames);' );
  Writeln( AuditConstFile, 'end.' );

  //Close files
  Close( AuditConstFile );
  CloseImportFile;
end;

procedure GenerateAuditUtils(SysName: string);
type
  PArrayDefRec = ^TArrayDefRec;
  TArrayDefRec = record
    FieldName: string;
    ArrayType: string;
    ArrayBase: byte;
    ArrayDimensions: byte;
    ArrayD1Len: integer;
    ArrayD2Len: integer;
  end;
var
  i: integer;
  AuditUtilsFile: Text;
  Prefix: string[2];
  AuditUtilsFileName: String;
  LineType: string[10];
  FieldName: string[60];
  FieldCode: string[10];
  FieldType: TFieldType;
  FieldParams: string;
  B1,B2,B3    : Byte;
  A4          : String;
  Definition  : String;
  TypeDef: string;
  TypeList: TStringList;
  FunctionDefList: TStringList;
  FunctionList: TStringList;
  FunctionDef: string;
begin
  //Open files
  if not OpenImportFile(SysName + '.TXT') then Halt( 1 );
  AuditUtilsFileName := UpperCase(SysName) + 'AUDITUTILS.PAS';
  Assign(AuditUtilsFile, AuditUtilsFileName);
  Rewrite(AuditUtilsFile);

  //Write static code
  Writeln( AuditUtilsFile, 'unit ',SysName,'AuditUtils;' );
  Writeln( AuditUtilsFile );
  Writeln( AuditUtilsFile, '// This code was generated automatically by running DBGen' );
  Writeln( AuditUtilsFile, '// Do not change it - any changes you make will disappear' );
  Writeln( AuditUtilsFile, '// when DBGen is run again.' );
  Writeln( AuditUtilsFile );

  TypeList := TStringList.Create;

  //Add definition for fields changed array
  TypeList.Add('  TChanged_Fields_Array = Array[ 0..254 ] of Byte;');

  FunctionDefList := TStringList.Create;
  FunctionList := TStringList.Create;
  try
    while not EndOfImportFile do begin
      ReadLine;
      if NoOfFields > 0 then begin
        LineType := GetAField(1);
        if LineType='F' then begin
          //Fields
          FieldName := MakeName( GetAField( 2 ) );
          FieldCode := GetAField( 3 );
          FieldType := DBObj.FindFieldType( FieldCode );
          FieldParams := FieldType.fReadVars;
          if Pos('ARRAY', UpperCase(FieldType.fDefn)) > 0 then begin

            B1 := GetBField( 4 );
            B2 := GetBField( 5 );
            B3 := GetBField( 6 );
            A4 := MakeName( GetAField( 4 ) );

            Definition := FieldType.fDefn;
            DBObj.ReplaceCodes( Definition, '%NAME%', Prefix + FieldName );
            DBObj.ReplaceCodes( Definition, '%TOKEN%', 'tk' + Prefix + FieldName );
            DBObj.ReplaceCodes( Definition, '%B1%', IntToStr( B1 ) );
            DBObj.ReplaceCodes( Definition, '%B2%', IntToStr( B2 ) );
            DBObj.ReplaceCodes( Definition, '%B3%', IntToStr( B3 ) );
            DBObj.ReplaceCodes( Definition, '%A4%', A4 );

            TypeDef := Format('  T%s_Array = %s',[FieldName, Definition]);
            if TypeList.IndexOf(TypeDef) = -1 then begin
              TypeList.Add(TypeDef);
              FunctionDef := 'function ' + FieldName + '_Changed(const V1, V2: T' +
                             FieldName + '_Array; var V3: T' + FieldName +
                             '_Array): boolean;';
              FunctionDefList.Add(' '+ FunctionDef);
              FunctionList.Add(FunctionDef);
              if Pos(',', Definition) > 0 then begin
                //Two dimension
                FunctionList.Add('var');
                FunctionList.Add('  i, j: integer;');
                FunctionList.Add('begin');
                FunctionList.Add('  Result := False;');
                FunctionList.Add('  for i := Low(V1) to High(V1) do');
                FunctionList.Add('    for j := Low(V1[i]) to High(V1[i]) do');
                FunctionList.Add('      if V1[i, j] <> V2[i, j] then begin');
                FunctionList.Add('        Result := True;');
                FunctionList.Add('        Break;');
                FunctionList.Add('      end;');
                FunctionList.Add('  if Result then');
                FunctionList.Add('    for i := Low(V1) to High(V1) do');
                FunctionList.Add('      for j := Low(V1[i]) to High(V1[i]) do');
                FunctionList.Add('        V3[i, j] := V1[i, j];');
                FunctionList.Add('end;');
                FunctionList.Add('');
              end else begin
                //Single dimension
                FunctionList.Add('var');
                FunctionList.Add('  i: integer;');
                FunctionList.Add('begin');
                FunctionList.Add('  Result := False;');
                FunctionList.Add('  for i := Low(V1) to High(V2) do');
                FunctionList.Add('    if V1[i] <> V2[i] then begin');
                FunctionList.Add('      Result := True;');
                FunctionList.Add('      Break;');
                FunctionList.Add('    end;');
                FunctionList.Add('  if Result then');
                FunctionList.Add('    for i := Low(V1) to High(V1) do');
                FunctionList.Add('        V3[i] := V1[i];');
                FunctionList.Add('end;');
                FunctionList.Add('');
              end;
            end;
          end;
        end;
      end;
    end;
    Writeln( AuditUtilsFile );
    Writeln( AuditUtilsFile, 'interface' );
    Writeln( AuditUtilsFile );
    Writeln( AuditUtilsFile, 'uses' );
    Writeln( AuditUtilsFile, '  MoneyDef;' );
    Writeln( AuditUtilsFile );
    Writeln( AuditUtilsFile, 'type' );
    Writeln( AuditUtilsFile );
    //Array types
    for i := 0 to TypeList.Count - 1 do
      Writeln( AuditUtilsFile, TypeList[i] );
    Writeln( AuditUtilsFile );
    //Function defs
    for i := 0 to FunctionDefList.Count - 1 do
      Writeln( AuditUtilsFile, FunctionDefList[i] );
    Writeln( AuditUtilsFile );
    Writeln( AuditUtilsFile, 'implementation' );
    Writeln( AuditUtilsFile );
    //Functions
    for i := 0 to FunctionList.Count - 1 do
      Writeln( AuditUtilsFile, FunctionList[i] );
    Writeln( AuditUtilsFile );
    Writeln( AuditUtilsFile, 'end.' );
  finally
    TypeList.Free;
    FunctionDefList.Free;
    FunctionList.Free;
  end;

  //Close files
  Close( AuditUtilsFile );
  CloseImportFile;
end;

procedure GenerateAuditCompare(SysName: string);
var
  WriteFile: Text;
  LineType: string[10];
  Name: string[60];
  Prefix: string[2];
  WriteFileName: string;
  FieldCode      : String[10];
  FieldType      : TFieldType;
  FieldName      : String[60];
  TempStr: string;
begin
  if not OpenImportFile( SysName+'.TXT' ) then Halt( 1 );
  while not EndOfImportFile do begin
    ReadLine;
    if NoOfFields > 0 then begin
      LineType := GetAField( 1 );
      if LineType = 'N' then begin
        if NoOfFields < 4 then begin
          Writeln( 'Error: Too Few Fields on line ', LineNumber );
          Halt;
        end;
        Name     := MakeName( GetAField( 2 ) );
        Prefix   := GetAField( 3 );
        WriteFileName     := UpperCase( Prefix ) + '.AC';
        Assign( WriteFile, WriteFileName ); Rewrite( WriteFile );
      end else if LineType='F' then begin
        FieldName := MakeName( GetAField( 2 ) );
        FieldCode := GetAField( 3 );
        FieldType := DBObj.FindFieldType( FieldCode );
        if FieldType = nil then begin
          Writeln(WriteFile, 'Unknown Field Type ', FieldCode, ' on line ', LineNumber );
          Halt;
        end;
        if Pos('ARRAY', UpperCase(FieldType.fDefn)) > 0 then begin
          TempStr := Format('  if %1:s_Changed(T%1:s_Array(P1.%0:s%1:s), ', [Prefix, FieldName]);
          Writeln(WriteFile, TempStr);
          TempStr := Format('                  T%1:s_Array(P2.%0:s%1:s), ', [Prefix, FieldName]);
          Writeln(WriteFile, TempStr);
          TempStr := Format('                  T%1:s_Array(P3.%0:s%1:s)) then begin', [Prefix, FieldName]);
          Writeln(WriteFile, TempStr);
          Writeln(WriteFile, '    ChangedFields[i] := tk',Prefix,FieldName,';');
          Writeln(WriteFile, '    Inc(i);');
          Writeln(WriteFile, '  end;');          
        end else begin
          TempStr := Format('  if (P1.%0:s%1:s <> P2.%0:s%1:s) then begin',
                            [Prefix, FieldName]);
          Writeln(WriteFile, TempStr);
          Writeln(WriteFile, '    P3.',Prefix,FieldName,' := P1.',Prefix,FieldName,';');
          Writeln(WriteFile, '    ChangedFields[i] := tk',Prefix,FieldName,';');
          Writeln(WriteFile, '    Inc(i);');
          Writeln(WriteFile, '  end;');
        end;
      end else if LineType = 'E' then begin
        Close( WriteFile );
      end;
    end;
  end;
  CloseImportFile;
end;
end.
