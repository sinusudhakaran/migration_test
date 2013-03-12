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
   function LoadRTF(value: string): Boolean;

public
   function InsertCustomDoc(Value: TReportBase; CreatedBy: TGuid): Boolean;
   function InsertMessage(Text, Name, Description, DocType: string): Boolean;
   function InsertHeaderFooter(Text, Name: string): Boolean;
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


  const
  cBlobName = 0;
  cContentType = 1;
  cBlobValue = 2;
  cType = 3;
  cDescription = 4;
  cCreatedBy = 5;
  cCreatedOn = 6;

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
            Parameters[cBlobValue].LoadFromStream(ls,ftBlob);
         end;
      finally
        ls.Free;
      end;
   end;

begin
   Parameters[cBlobName].Value := ToSQL(Value.GetGUID);
   Parameters[cContentType].Value := 'RTF';

   GetRTFData;
   Parameters[cType].Value := ToSQL('CustomDocument');
   Parameters[cDescription].Value := ToSQL(Value.Name);
   Parameters[cCreatedBy].Value := ToSQL(Createdby);
   Parameters[cCreatedOn].Value := Value.Createdon;

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


function TSystemBlobTable.InsertHeaderFooter(Text, Name: string): Boolean;
begin

   if not (Text > '') then begin
      result := True;
      Exit;
   end;
   result := false;

   LoadRTF(Text);

   Parameters[cBlobName].Value := ToSql(name);
   Parameters[cContentType].Value := ToSql('RTF');

   Parameters[cType].Value := ToSQL('ReportHeaderFooter');
   Parameters[cDescription].Value := ToSQL('Report Header Footer');

   Parameters[cCreatedBy].Value := ToSQL('Migrator');
   Parameters[cCreatedOn].Value := DateTimeToSQL(Date);
   // Run the query
   try
      Result := ExecSQL = 1;
   except
      on e: exception do begin
         raise exception.Create(Format('Error : %s in table %s',[e.Message,TableName]));
      end;
   end;
end;

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
   Parameters[cBlobName].Value := ToSql(name);
   Parameters[cContentType].Value := ToSql(FileType);

   Parameters[cType].Value := ToSQL(DocType);
   Parameters[cDescription].Value := ToSQL(Description);

   Parameters[cCreatedBy].Value := ToSQL('Migrator');
   Parameters[cCreatedOn].Value := DateTimeToSQL(Date);
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

begin
   if Length(Text) = 0 then begin
      Result := true;
      Exit;
   end;

   Parameters[cBlobName].Value := ToSQL(Name);
   Parameters[cContentType].Value := 'Text';
   LoadRTF(Text);
   Parameters[cType].Value := ToSQL(DocType);
   Parameters[cDescription].Value := ToSQL(Description);
   Parameters[cCreatedBy].Value := ToSQL('Migrator');
   Parameters[cCreatedOn].Value := DateTimeToSQL(Date);

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
   Parameters[cBlobName].Value := 'MiratorPracticeSignature';
   Parameters[cContentType].Value := 'RTF';

   Parameters[cType].Value := ToSQL('Signature');
   Parameters[cDescription].Value := ToSQL('Practice Signature');
   Parameters[cCreatedBy].Value := ToSQL('Migrator');
   Parameters[cCreatedOn].Value := DateTimeToSQL(Date);
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

function TSystemBlobTable.LoadRTF(value: string): Boolean;
var ls: TStringStream;
begin
     ls := TStringStream.Create(value);
     try
         ls.position := 0;
         Parameters[cBlobValue].LoadFromStream(ls,ftBlob);
     finally
        ls.Free;
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
