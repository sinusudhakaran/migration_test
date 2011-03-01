unit DBAUDIT;

interface

procedure GenerateAuditFiles( SysName : string );

implementation

uses
  DBMisc, ReadF, StDate, StDateSt, SysUtils, Classes, DBObj;

function MakeName (S: string): string;
var
  O: String;
  i: Integer;
begin
  O:=S;
  for i := 1 to Length(O) do
    if not (O[i] in ['a'..'z','0'..'9','_','A'..'Z'] ) then
      O[i] := '_';
  Result := O;
end;

function WS( S : String ): String;
begin
  Result := '';
  if (Length(S) < 32) then
    Result := ConstStr(' ', 32-Length(S));
end;

procedure GenerateAuditFiles( SysName : string );
var
   AuditConstFile: Text;
   TableName: string[60];
   Prefix: string[2];
   AuditConstFileName  : String;
   TokenNo, TableBeginToken     : Integer;
   LineType    : String[10];
   AuditFieldIndex: integer;
   FieldName, AuditFieldName: String[60];
   FieldCode: string[10];
   FieldType: TFieldType;
   FieldParams: string;
begin
  TokenNo := 0;
  if not OpenImportFile(SysName + '.TXT') then Halt( 1 );

  AuditConstFileName := UpperCase(SysName) + 'AUDIT.PAS';
  Assign(AuditConstFile, AuditConstFileName);
  Rewrite(AuditConstFile);

  Writeln( AuditConstFile, 'unit ',SysName,'AUDIT;' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, '// This code was generated automatically by running DBGen' );
  Writeln( AuditConstFile, '// Do not change it - any changes you make will disappear' );
  Writeln( AuditConstFile, '// when DBGen is run again.' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'interface' );
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

  while not EndOfImportFile do begin
    ReadLine;
    if NoOfFields > 0 then begin
      LineType := GetAField(1);
      if LineType='N' then begin
        //Table
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
        //Fields
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
  Writeln( AuditConstFile, 'end;' );
  Writeln( AuditConstFile );
  Writeln( AuditConstFile, 'end.' );
  Close( AuditConstFile );
  CloseImportFile;
end;

end.
