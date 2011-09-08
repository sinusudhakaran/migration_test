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
   function Insert(Value: TReportBase; CreatedBy: TGuid): Boolean; overload;
   function Insert(Text, Name, Description, DocType: string): Boolean; overload;
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

(******************************************************************************)

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
   Parameters[1].Value := 'RTF';

   GetRTFData;
   Parameters[3].Value := ToSQL('CustomDocument');
   Parameters[4].Value := ToSQL(Value.Name);
   Parameters[5].Value := ToSQL(Createdby);
   Parameters[6].Value := Value.Createdon;

   // Run the query
   try
      Result := ExecSQL = 1;
   except
      on e: exception do begin
         raise exception.Create(Format('Error : %s in table %s',[e.Message,TableName]));
      end;
   end;


end;

(*
procedure TCustomDocTable.SetupTable;
begin
   TableName := 'CustomDocuments';
   SetFields (['Id','Description','DocumentBlob','CustomDocumentType','CreatedBy'
      ,'CreatedOn','DataFormatStringType'],[]);
end;
 *)

function TCustomDocTable.Insert(Text, Name, Description, DocType: string): Boolean;
   procedure GetRTFData;
   var ls: TStringStream;
   begin
      ls := TStringStream.Create(Text);
      try
         ls.position := 0;
         Parameters[2].LoadFromStream(ls,ftBlob);
      finally
        ls.Free;
      end;
   end;
begin
   if Length(Text) = 0 then begin
      Result := true;
      Exit;
   end;

   Parameters[0].Value := ToSQL(Name);
   Parameters[1].Value := 'Text';
   GetRTFData;
   Parameters[3].Value := ToSQL(DocType);
   Parameters[4].Value := ToSQL(Description);
   Parameters[5].Value := ToSQL('Migrator');
   Parameters[6].Value := ToSQL(Date);

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
   TableName := 'SystemBlobs';
             //      0          1             2       3         4            5
   SetFields (['BlobName','ContentType','BlobValue','Type','Description','CreatedBy'
      ,'CreatedOn'],[]);
end;



(******************************************************************************)


{ TCustomDocSceduleTable }

function TCustomDocSceduleTable.Insert(MyId,ScheduleID: TGuid; DocId: string): Boolean;
begin
   Result := RunValues([ToSQL(MyId), ToSQL(DocID), ToSQL(ScheduleID)],[]);
end;

procedure TCustomDocSceduleTable.SetupTable;
begin
  TableName := 'CustomDocumentScheduleTasks';
  SetFields (['Id','CustomDocument','ScheduledTaskValue_Id'],[]);
end;

end.
