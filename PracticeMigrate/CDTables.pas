unit CDTables;

interface
uses
   MigrateTable,
   UBatchBase,
   CustomDocEditorFrm;

type

TSystemBlobTable = class (TMigrateTable)

protected
   procedure SetupTable; override;
   function LoadFile(path: string): boolean;
public
   function InsertCustomDoc(Value: TReportBase; CreatedBy: TGuid): Boolean;
   function InsertMessage(Text, Name, Description, DocType: string): Boolean;
   function InsertImage(Path, Name, Description, DocType: string): Boolean;
   function InsertSignature(Path: string): Boolean;
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

{ TSystemBlobTable }

function TSystemBlobTable.InsertCustomDoc(Value: TReportBase; CreatedBy: TGuid): Boolean;

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


function TSystemBlobTable.InsertImage(Path, Name, Description, DocType: string): Boolean;

   function FileType:string;
   var Ext: string;
   begin
      Ext := SysUtils.ExtractFileExt(Path);
      if SameText(Ext,'.jpg')
      or SameText(Ext,'.jpeg') then
         result := 'image/jpeg'
      else if SameText(Ext,'.bmp') then
         result := 'image/bmp'
      
   end;
begin
   result := false;
   if not LoadFile(path) then
      Exit;
   Parameters[0].Value := ToSql(name);
   Parameters[1].Value := ToSql(FileType);

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

function TSystemBlobTable.InsertMessage(Text, Name, Description, DocType: string): Boolean;
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

function TSystemBlobTable.InsertSignature(Path: string): Boolean;
begin
   result := false;
   if not LoadFile(path) then
      Exit;
   Parameters[0].Value := 'MiratorPracticeSignature';
   Parameters[1].Value := 'RTF';

   Parameters[3].Value := ToSQL('Signature');
   Parameters[4].Value := ToSQL('Practice Signature');
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

function TSystemBlobTable.LoadFile(path: string): boolean;
var fs: TFileStream;
begin
   result := FileExists(path);
   if not result then
      Exit;
   fs := TFileStream.Create(path,fmOpenRead + fmShareDenyWrite);
   try
      fs.Position := 0;
      Parameters[2].LoadFromStream(fs,ftBlob);
   finally
      fs.Free;
   end;
end;

procedure TSystemBlobTable.SetupTable;
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
