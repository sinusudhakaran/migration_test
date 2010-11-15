unit AvailableSQLServers;

interface
uses classes;

procedure ListAvailableSQLServers(Names : TStrings);
procedure DatabasesOnServer(Server, User, PW:string; Databases : TStrings);

implementation
uses
   SysUtils,
   Variants,
   ADOdb,
   DB,
   ActiveX,
   ComObj,
   AdoInt,
   OleDB;

procedure ListAvailableSQLServers(Names : TStrings);
var
  RSCon: ADORecordsetConstruction;
  Rowset: IRowset;
  SourcesRowset: ISourcesRowset;
  SourcesRecordset: _Recordset;
  SourcesName, SourcesType: TField;

    function PtCreateADOObject
             (const ClassID: TGUID): IUnknown;
    var
      Status: HResult;
      FPUControlWord: Word;
    begin
      asm
        FNSTCW FPUControlWord
      end;
      Status := CoCreateInstance(
                  CLASS_Recordset,
                  nil,
                  CLSCTX_INPROC_SERVER or
                  CLSCTX_LOCAL_SERVER,
                  IUnknown,
                  Result);
      asm
        FNCLEX
        FLDCW FPUControlWord
      end;
      OleCheck(Status);
    end;
begin
  SourcesRecordset :=
      PtCreateADOObject(CLASS_Recordset) 
      as _Recordset;
  RSCon := 
      SourcesRecordset
      as ADORecordsetConstruction;
  SourcesRowset := 
      CreateComObject(ProgIDToClassID('SQLOLEDB Enumerator')) 
      as ISourcesRowset;
  OleCheck(SourcesRowset.GetSourcesRowset(
       nil, 
       IRowset, 0, 
       nil, 
       IUnknown(Rowset)));
  RSCon.Rowset := RowSet;
  with TADODataSet.Create(nil) do
  try
    Recordset := SourcesRecordset;
    SourcesName := FieldByName('SOURCES_NAME');
    SourcesType := FieldByName('SOURCES_TYPE');
    Names.BeginUpdate;
    try
      while not EOF do
      begin
        if
           (SourcesType.AsInteger = DBSOURCETYPE_DATASOURCE) 
           and (SourcesName.AsString <> '') then
          Names.Add(SourcesName.AsString);
        Next;
      end;
    finally
      Names.EndUpdate;
    end;
  finally
    Free;
  end;
end;


procedure DatabasesOnServer(Server, User, PW:string; Databases : TStrings);
var
  rs: _RecordSet;
  ConnStr: string;
begin
  Databases.Clear;
  with TAdoConnection.Create(nil) do
  try
    //simple ConnectionString without the DB name
    ConnStr := Format(
       'Provider=SQLNCLI10.1;Integrated Security=SSPI;Persist Security Info=False;Data Source=%s;uid=%s;pwd=%s',
       [Server,User,PW]);
    ConnectionString := ConnStr;
    LoginPrompt := False;
    ConnectionTimeout := 1;
    try
      Open;
      rs := ConnectionObject.OpenSchema(
                adSchemaCatalogs, 
                EmptyParam, 
                EmptyParam);
      with rs do
      begin
        try
          Databases.BeginUpdate;
          while not Eof do
          begin
            Databases.Add(
                VarToStr(
                   Fields['CATALOG_NAME'].Value));
            MoveNext;
          end;
        finally
          Databases.EndUpdate;
        end;
      end;
      Close;
    except
      on e:exception do;

    end;
  finally
    Free;
  end;
end;
 




end.
