unit CDTables;

interface
uses
 WPRTEDefs,
  WPRTEPaint,
  WPCTRRich,
  WPCTRMemo,
   MigrateTable,
   UBatchBase,
   CustomDocEditorFrm;

type

TSystemBlobTable = class (TMigrateTable)
private

   procedure MailMergeGetText(Sender: TObject; const inspname: string;
  Contents: TWPMMInsertTextContents);

  procedure PrepareImageforSaving(RTFData: TWPRTFDataCollection;
  Writer: TWPCustomTextWriter; TextObject: TWPTextObj; var DontSave: Boolean);

protected
   procedure SetupTable; override;
   function LoadFile(path: string): boolean;
   function LoadRTF(value: string; KeepDoc: Boolean): Boolean;
   function LoadText(value: string): Boolean;

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
  GlobalMergeFields,
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
   var ls: TStringStream;
   begin
      ls := TStringStream.Create('');
      try
         if GetNodeTextBinary(Value.Settings,'ReportRTF',ls) then begin
            ls.position := 0;
            LoadRTF(ls.DataString, true);
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

   LoadRTF(Text, false);

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
   LoadText(Text);
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
var fs: TFileStream;
    ls: String;
begin

   result := FileExists(path);
   if not result then
      Exit;
   // Get the file..
   fs := TFileStream.Create(path,fmOpenRead + fmShareDenyWrite);
   try
      fs.Position := 0;
      SetLength(ls, fs.Size);
      fs.Read(ls[1], fs.Size);
   finally
      fs.Free;
   end;
   LoadRTF(ls, false);

   // Fill in the other details
   Parameters[cBlobName].Value := 'MigratorPracticeSignature';
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

end;


procedure TSystemBlobTable.MailMergeGetText(Sender: TObject; const inspname: string;
  Contents: TWPMMInsertTextContents);

  var I: TMergeFieldType;
begin
    for I := low(MergeFieldNames) to High(MergeFieldNames) do
       if MergeFieldNames[i] = inspname then
          Contents.StringValue := format('*<%s>*',[MergeFieldNames[i]]);
             
end;


procedure TSystemBlobTable.PrepareImageforSaving(RTFData: TWPRTFDataCollection;
  Writer: TWPCustomTextWriter; TextObject: TWPTextObj; var DontSave: Boolean);
var lName: string;

   function NewImagesFilename: string;
   var I: Integer;
   begin
   {
      I := 0;
      repeat
         Inc(I);
         Result := EmailDir + Format( 'Picture%d.', [I] ) + TextObject.ObjRef.FileExtension;
      until not BKFileExists(Result);
      }
   end;


begin
  // We clear Source and StreamName to make sure the embedded data is saved to file
  TextObject.Source := '';
  if TextObject.ObjRef <> nil then begin

     TextObject.ObjRef.StreamName := '';
     lName := NewImagesFilename;
     //TextObject.ObjRef.SaveToFile('', LName, '' );

     //TextObject.ObjRef.FileName := ExtractFileName( LName);

     //ImagesList.Add(LName);
  end;
  DontSave := true;
end;



function TSystemBlobTable.LoadRTF(value: string; KeepDoc: Boolean): Boolean;
var
     RichText: TWPRichText;
begin

     RichText := TWPRichText.Create(nil);
     try
        RichText.LoadFromString(value);
        RichText.OnMailMergeGetText := MailMergeGetText;
        RichText.MergeText();
        RichText.ReformatAll(True,True);
        RichText.OnPrepareImageforSaving := PrepareImageforSaving;

        if not KeepDoc then  begin
           RichText.Header.LeftMargin := 1;
           RichText.Header.RightMargin := 1;
           RichText.Header.TopMargin := 1;
           RichText.Header.BottomMargin := 1;

           RichText.Header.defaultLeftMargin := 1;
           RichText.Header.defaultRightMargin := 1;
           RichText.Header.defaultTopMargin := 1;
           RichText.Header.defaultBottomMargin := 1;

        end;


        result := LoadText(RichText.AsString);
     finally

        freeandnil(RichText);
     end;
end;

function TSystemBlobTable.LoadText(value: string): Boolean;
var ls: TStringStream;
begin
     ls := nil;
     try
        ls := TStringStream.Create(value);
        ls.position := 0;
        Parameters[cBlobValue].LoadFromStream(ls,ftBlob);
     finally
        freeandNil(ls);
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
