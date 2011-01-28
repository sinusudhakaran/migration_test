unit CDTables;

interface
uses
   MigrateTable,
   UBatchBase,
   CustomDocEditorFrm;

type

TCustomDocTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(Value: TReportBase; CreatedBy: TGuid): Boolean;
end;

TCustomDocSceduleTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyId,ScheduleID: TGuid; DocId: string): Boolean;
end;



implementation

uses
  OmniXMLUtils,
  DB,
  classes,
  sysutils;
{ TCustomDocTable }

function TCustomDocTable.Insert(Value: TReportBase; CreatedBy: TGuid): Boolean;

   procedure GetRTFData;
   var ls: TMemoryStream;
   begin
      ls := TMemoryStream.Create;
      try
         if GetNodeTextBinary(Value.Settings,'ReportRTF',ls) then begin
            ls.position := 0;
            Parameters[2].LoadFromStream(ls,ftBlob);
         end;
      finally
        ls.Free;
      end;
   end;

begin
   Parameters[0].Value := ToSQL(Value.GetGUID);
   Parameters[1].Value := ToSQL(Value.Name);
   GetRTFData;
   Parameters[3].Value := 1;
   Parameters[4].Value := ToSQL(Createdby);
   Parameters[5].Value := Value.Createdon;
   Parameters[6].Value := 'RTF';
   // Run the query
   try
      Result := ExecSQL = 1;
   except
      on e: exception do begin
         raise exception.Create(Format('Error : %s in table %s',[e.Message,TableName]));
      end;
   end;


end;

procedure TCustomDocTable.SetupTable;
begin
   TableName := 'CustomDocuments';
   SetFields (['Id','Description','DocumentBlob','CustomDocumentType','CreatedBy'
      ,'CreatedOn','DataFormatStringType'],[]);
end;


{ TCustomDocSceduleTable }

function TCustomDocSceduleTable.Insert(MyId,ScheduleID: TGuid; DocId: string): Boolean;
begin
   Result := RunValues([ToSQL(MyId), ToSQL(DocID), ToSQL(ScheduleID)],[]);
end;

procedure TCustomDocSceduleTable.SetupTable;
begin
  TableName := 'CustomDocumentScheduleTasks';
  SetFields (['Id','CustomDocument_Id','ScheduledTaskValue_Id'],[]);
end;

end.
