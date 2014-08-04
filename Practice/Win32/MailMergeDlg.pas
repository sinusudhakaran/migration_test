// Mail merge form - printing

unit MailMergeDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OpModels, OpShared, OpWrdXP, OpWord, ovcbase, ovcef, ovcpb,
  ovcpf, StdCtrls, CheckLst, ExtCtrls, ComCtrls, Buttons, Menus, RzButton;

type
  TfrmMailMerge = class(TForm)
    opemMerge: TOpEventModel;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    popFollowup: TPopupMenu;
    N1Week: TMenuItem;
    N2Weeks: TMenuItem;
    N4Weeks: TMenuItem;
    N6Weeks: TMenuItem;
    N2Months: TMenuItem;
    N4Months: TMenuItem;
    gbPrint: TGroupBox;
    rbNoPrint: TRadioButton;
    rbPreview: TRadioButton;
    rbPrint: TRadioButton;
    rbView: TRadioButton;
    btnOk: TButton;
    btnCancel: TButton;
    gbSummary: TGroupBox;
    rbRepNone: TRadioButton;
    rbRepScreen: TRadioButton;
    rbRepPrint: TRadioButton;
    rbRepFile: TRadioButton;
    gbTask: TGroupBox;
    Label1: TLabel;
    Label3: TLabel;
    btnQuik: TRzToolButton;
    edtDescription: TEdit;
    ovcFollowup: TOvcPictureField;
    chkTask: TCheckBox;
    gbDocs: TGroupBox;
    Label2: TLabel;
    Label4: TLabel;
    btnFromFile: TSpeedButton;
    btnToFile: TSpeedButton;
    edtSave: TEdit;
    edtDocument: TEdit;
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnToFileClick(Sender: TObject);
    procedure btnFromFileClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure opemMergeGetColCount(Sender: TObject; var ColCount: Integer);
    procedure opemMergeGetColHeaders(Sender: TObject;
      var ColHeaders: Variant);
    procedure opemMergeGetData(Sender: TObject; Index, Row: Integer;
      Mode: TOpRetrievalMode; var Size: Integer; var Data: Variant);
    procedure chkTaskClick(Sender: TObject);
    procedure N1WeekClick(Sender: TObject);
    procedure N2WeeksClick(Sender: TObject);
    procedure N4WeeksClick(Sender: TObject);
    procedure N6WeeksClick(Sender: TObject);
    procedure N2MonthsClick(Sender: TObject);
    procedure N4MonthsClick(Sender: TObject);
    procedure btnQuikClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    CodeList: TStringList;
    FowMerge: TOpWord;
    FDataSource: string;
    function MergeDoc: Boolean;
    function VerifyForm: Boolean;
    function ValidateDates: Boolean;
    procedure PopUpCalendar( aRect : TRect; var aDate : integer);        
  public
    { Public declarations }
    procedure FillCodeList(Codes: string);
    property Word: TOpWord read FowMerge write FowMerge;
    property DataSource: string read FDataSource write FDataSource;    
  end;

var
  frmMailMerge: TfrmMailMerge;

const
  UnitName = 'MailMergeDlg';

function PerformMailMerge(Codes: string; WordObj: TOpWord): Boolean;

implementation

uses ImagesFrm, WarningMoreFrm, ErrorMoreFrm, YesNoDlg, glConst, WinUtils,
  GlobalDirectories, bkXPThemes, Globals, SYDefs, ClientDetailCacheObj, bkDateUtils,
  progress, GenUtils, ToDoHandler, stDate, rptMailMerge, ReportDefs,
  LogUtil, ClientUtils, RzPopups, Admin32, bkHelp, bkConst, bkProduct;

{$R *.dfm}

// Perform the merge
function TfrmMailMerge.MergeDoc: Boolean;
const
  ThisMethodName = 'MergeDoc';
var
  MergeDoc: TOpWordDocument;
  i: Integer;
  v: Double;
  idx, filename, fileformat, changes, sql, b: OleVariant;
  Description, newfilename: string;
  FoundMergeDoc, Is2007: Boolean;
  s: TStringList;
  h: HWND;
begin
  Result := True;
  FoundMergeDoc := False;
  newfilename := '';
  opemMerge.RowCount := CodeList.Count;
  UpdateAppStatus('Merging Document', 'Please wait...', 70, True);
  try
  if (Pos('Vista', WinUtils.GetWinVer) > 0) then
    Is2007 := True
  else
  begin
    s := TStringlist.create;
    try
      FowMerge.GetAppInfo(s);
      v := StrToFloatDef(s.Values['Version'], 0);
      Is2007 := v >= 12;
    finally
      s.Free;
    end;
  end;
  FowMerge.Visible := False;
  if Is2007 then
  begin
    Application.ProcessMessages;
    if Assigned(FowMerge.Documents) then
      while FowMerge.Documents.Count > 0 do
        FowMerge.Documents.Delete(0);
    FowMerge.Visible := False;
  end;
  //try
    if Is2007 then
      FowMerge.DisplayAlerts := wdalNone
    else
      FowMerge.DisplayAlerts := wdalAll;
    MergeDoc := FowMerge.OpenDocument(edtDocument.Text);
    FowMerge.DisplayAlerts := wdalAll;
    if Is2007 then // Office 2007 behaves differently
    begin
      filename := FDataSource;
      sql := 'select * from ' + FDataSource;
      if FowMerge.OfficeVersion = ov2000 then
        MergeDoc.AsDocument.MailMerge.OpenDataSource2000(filename, emptyParam,
          emptyParam, emptyParam, emptyParam, emptyParam, emptyParam, emptyParam,
          emptyParam, emptyParam, emptyParam, filename, sql, emptyParam)
      else
        MergeDoc.AsDocument.MailMerge.OpenDataSource(filename, emptyParam, emptyParam, emptyParam,
          emptyParam, emptyParam, emptyParam, emptyParam, emptyParam, emptyParam, emptyParam,
          filename, sql, emptyParam,emptyParam,emptyParam);
      ForceDirectories(DataDir + 'Temp\');
      newfilename := DataDir + 'Temp\' + CurrUser.Code + ExtractFileName(edtDocument.Text);
      i := 1;
      while BKFileExists(newfilename) do
      begin
        newfilename := DataDir + 'Temp\' + IntToStr(i) + CurrUser.Code + ExtractFileName(edtDocument.Text);
        Inc(i);
      end;
      DeleteFile(newfilename);
      MergeDoc.SaveAs(newfilename);
      b := False;
      MergeDoc.AsDocument.Close(b, emptyParam, emptyParam);
      FowMerge.DisplayAlerts := wdalAll;
      FowMerge.Visible := True;
      h := FindWindow(nil, 'Microsoft Word');
      if h <> 0 then BringWindowToTop(h);
      MergeDoc := FowMerge.OpenDocument(newfilename);
    end;
    FowMerge.Visible := False;
    // Close everything else
    i := 1;
    changes := False;
    while FowMerge.Server.Documents.Count > 1 do
    begin
      idx := i;
      if Pos(ExtractFileName(edtDocument.Text), FowMerge.Server.Documents.Item(idx).Name) > 0 then
        Inc(i)
      else
      begin
        FowMerge.Server.Documents.Item(idx).Close(changes, emptyParam, emptyParam);
        Sleep(500); // Time for Word to close the doc
      end;
    end;
    FowMerge.DisplayAlerts := wdalNone;
    FowMerge.Visible := False;
    Sleep(500); // give word some time to sort itself out
    changes := False;
    try
      MergeDoc.MailMerge.OfficeModel := opemMerge;
      if MergeDoc.MailMerge.AsMailMerge = nil then
      begin
        MergeDoc.AsDocument.Close(changes, emptyParam, emptyParam);
        FowMerge.Connected := False;
        HelpfulWarningMsg('The selected document is not a Mail Merge document. The Mail Merge failed.'#13#13 +
          'Filename : ' + edtDocument.Text, 0);
        LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Not a Mail Merge document: ' + edtDocument.Text);          
        Result := False;
        Exit;
      end;
      MergeDoc.MailMerge.AsMailMerge.Destination := wdSendToNewDocument;

      MergeDoc.PopulateMailMerge;
      UpdateAppStatusPerc( 80, True);
      FowMerge.Visible := False; // Keeps coming visible!!
      MergeDoc.ExecuteMailMerge;
      FowMerge.Visible := False;
      UpdateAppStatusPerc( 90, True);
      {
      From OfficePartner help forum:
      The merged file is always called "Form LettersX" (X being a number). This file
      is not added to the documents collection of OfficePartner, so we have to
      iterate through the documents in the server interface to find it.
      }
      fileformat := Integer(wdFormatDocument);
      filename := edtSave.Text;
      // Close everything
      i := 1;
      changes := False;
      while FowMerge.Server.Documents.Count > 1 do
      begin
        idx := i;
        if FowMerge.Server.Documents.Item(idx).Name = 'Form Letters1' then
          Inc(i)
        else
        begin
          FowMerge.Server.Documents.Item(idx).Close(changes, emptyParam, emptyParam);
          Sleep(500); // Time for Word to close the doc
        end;
      end;
      for i := 1 to FowMerge.Server.Documents.Count do
      begin
        idx := i;
        if FowMerge.Server.Documents.Item(idx).Name = 'Form Letters1' then
        begin
          FoundMergeDoc := True;
          if FowMerge.OfficeVersion = ov2000 then
            FowMerge.Server.Documents.Item(idx).SaveAs2000(filename, fileformat,
                            emptyParam, emptyParam, emptyParam, emptyParam,
                            emptyParam, emptyParam, emptyParam, emptyParam,
                            emptyParam)
          else
            FowMerge.Server.Documents.Item(idx).SaveAs(filename, fileformat,
                            emptyParam, emptyParam, emptyParam, emptyParam,
                            emptyParam, emptyParam, emptyParam, emptyParam,
                            emptyParam, emptyParam, emptyParam, emptyParam,
                            emptyParam, emptyParam);
          // Now take the requested action
{          if not rbNoPrint.Checked then
          begin
            if rbPreview.Checked then
            begin}
          // Always preview
              FowMerge.Server.Documents.Item(idx).PrintPreview;
              FowMerge.WindowState := wdwsMaximized;
              FowMerge.Visible := True;
{            end
            else if rbView.Checked then
            begin
              FowMerge.WindowState := wdwsMaximized;
              FowMerge.Visible := True;
            end
            else
            begin
              FowMerge.Server.Documents.Item(idx).PrintOut(emptyParam, emptyParam,
              emptyParam, emptyParam, emptyParam, emptyParam, emptyParam, emptyParam,
              emptyParam, emptyParam, emptyParam, emptyParam, emptyParam, emptyParam,
              emptyParam, emptyParam, emptyParam, emptyParam);
            end;
          end
          else
            FowMerge.Connected := False;}
          // Note we only disconnect if no action required.
          // We still have control of the merged doc so if we disconnected then
          // the doc would close before the view/print/preview has been completed.
          // We do the close in that case next time we load the form or when
          // client manager gets closed.
          UpdateAppStatusPerc( 100, True);
          if not rbRepNone.Checked then
          begin
            if chkTask.Checked then
              Description := edtDescription.Text
            else
              Description := '';
            if rbRepScreen.Checked then
            begin
              AdminSystem.fdFields.fdPrint_Merge_Report_Summary := rbRepScreen.Tag;
              DoMergePrintReport(rdScreen, Description, bkdateutils.bkDate2Str(stDate.CurrentDate),
                 bkdateutils.bkDate2Str(ovcFollowup.AsStDate), edtDocument.Text, edtSave.Text, CodeList);
            end
            else if rbRepPrint.Checked then
            begin
              AdminSystem.fdFields.fdPrint_Merge_Report_Summary := rbRepPrint.Tag;
              DoMergePrintReport(rdPrinter, Description, bkdateutils.bkDate2Str(stDate.CurrentDate),
                 bkdateutils.bkDate2Str(ovcFollowup.AsStDate), edtDocument.Text, edtSave.Text, CodeList);
            end;
{            else if rbRepFile.Checked then
                DoMergePrintReport(rdFile, Description, bkdateutils.bkDate2Str(stDate.CurrentDate),
                   bkdateutils.bkDate2Str(ovcFollowup.AsStDate), CodeList);}
          end
          else
            AdminSystem.fdFields.fdPrint_Merge_Report_Summary := rbRepNone.Tag;
          if LoadAdminSystem(true, 'TfrmMailMerge.MergeDoc' ) then
            SaveAdminSystem
          else
            HelpfulErrorMsg('Unable to Update Mail Merge Settings.  Admin System cannot be loaded',0);
          Break;
        end;
      end;
      if not FoundMergeDoc then
        raise Exception.Create('could not find the merged document in the OLE server');
    finally
      if Is2007 then
        DeleteFile(newfilename);
      ClearStatus(True);
      // Log
      LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + 'Mail Merge/Print generated on ' + bkdateutils.bkDate2Str(stDate.CurrentDate));
      if chkTask.Checked then
        LogUtil.LogMsg(lmInfo, UnitName, 'Task created "' + edtDescription.Text + '", Reminder on ' + bkdateutils.bkDate2Str(ovcFollowup.AsStDate));
      LogUtil.LogMsg(lmInfo, UnitName, 'Source document: ' + edtDocument.Text + '", Destination document: ' + edtSave.Text);
      LogUtil.LogMsg(lmInfo, UnitName, 'Clients: ' + CodeList.CommaText);
    end;
  except on E: Exception do
   begin
    FowMerge.Connected := False;
    HelpFulErrorMsg('There were problems performing the Mail Merge/Print using Word.' + #13#13 +
      'Please see log for more details.', 0);
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Mail Merge/Print Failure: ' + E.Message);
    Result := False;
   end;
  end;
end;

// Verify the form is all ok
function TfrmMailMerge.VerifyForm: Boolean;
var
  path: string;
begin
  Result := False;
  if ExtractFilename(edtDocument.Text) = '' then
  begin
    HelpfulWarningMsg('You must specify the filename of the mail merge document.', 0);
    edtDocument.SetFocus;
  end
  else if not BKFileExists(edtDocument.Text) then
  begin
    HelpfulWarningMsg('The specified mail merge document does not exist.' + #13 +
      'Filename: ' + edtDocument.Text, 0);
    edtDocument.SetFocus;
  end
  else if ExtractFilename(edtSave.Text) = '' then
  begin
    HelpfulWarningMsg('You must specify the filename for the merged document.', 0);
    edtSave.SetFocus;
  end
  else if Lowercase(edtDocument.Text) = Lowercase(edtSave.Text) then
  begin
    HelpfulWarningMsg('The destination file must not be the same as the source file.', 0);
    edtSave.SetFocus;
  end
  else if chkTask.Checked and (Trim(edtDescription.Text) = '') then
  begin
    HelpfulWarningMsg('Please enter a description for this communication.', 0);
    edtDescription.SetFocus;
  end
  else if chkTask.Checked and (ovcFollowup.AsStDate <> -1) and (not ValidateDates) then
    ovcFollowUp.SetFocus
  else if chkTask.Checked and (ovcFollowup.AsStDate <> -1) and (ovcFollowup.AsStDate < StDate.CurrentDate) then
  begin
    HelpfulWarningMsg('The reminder date can not be in the past.', 0);
    ovcFollowUp.SetFocus;
  end
  else
    Result := True;

  if Result then // All ok up to now
  begin
    path := ExtractFilePath(edtSave.Text);
    if (path <> '') then
    begin
      if not DirectoryExists(path) then
      begin
        if AskYesNo('Create Directory',
                    'The folder ' + path + ' does not exist. Do you want to Create it?',
                     DLG_YES,0) <> DLG_YES then
           Result := False
        else
        begin
          try
             ForceDirectories(path);
          except
          end;
          if not DirectoryExists(path) then
          begin
            HelpfulErrorMsg('Cannot Create Directory ' + path, 0);
            Result := False;
          end;
        end;
      end;
    end;
  end;
  path := ExtractFileExt(edtSave.Text);
  if path = '' then
    edtSave.Text := edtSave.Text + '.doc'
  else if path = '.' then
    edtSave.Text := edtSave.Text + 'doc';
  if Result and BKFileExists(edtSave.Text) then
  begin
    if AskYesNo('Overwrite File', 'The file ' + ExtractFileName(edtSave.Text) +
                ' already exists. Overwrite?', DLG_YES, 0) <> DLG_YES then
      Result := False;
  end;
end;

// Do the merge if all valid
procedure TfrmMailMerge.btnOkClick(Sender: TObject);
var
  i: Integer;
  Saved: Boolean;
begin
  if VerifyForm then
  begin
    if MergeDoc and chkTask.Checked then // Add task for each client if required
    begin
      for i := 0 to Pred(CodeList.Count) do
        AddAutomaticToDoItem(CodeList[i], ttyMailMergePrint, edtDescription.Text, ovcFollowup.AsStDate);
    end;
    ModalResult := mrOk;
  end;
end;

// Initialise form
procedure TfrmMailMerge.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(Self);
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnFromFile.Glyph);
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnToFile.Glyph);
  CodeList := TStringList.Create;
  CodeList.Delimiter := ClientCodeDelimiter;
  CodeList.StrictDelimiter := true;
  case AdminSystem.fdFields.fdPrint_Merge_Report_Summary of
    0: rbRepScreen.Checked := True;
    1: rbRepNone.Checked := True;
    2: rbRepPrint.Checked := True;
    else rbRepScreen.Checked := True;
  end;
  chkTaskClick(Sender);
end;

// Browse for saved doc
procedure TfrmMailMerge.btnToFileClick(Sender: TObject);
begin
  with SaveDialog1 do
  begin
    FileName := ExtractFileName(edtSave.Text);
    InitialDir := ExtractFilePath(edtSave.Text);
    if Execute then
      edtSave.Text := Filename;
  end;
  //make sure all relative paths are relative to data dir after browse
  SysUtils.SetCurrentDir(GlobalDirectories.glDataDir);
end;

// Browse for merged doc
procedure TfrmMailMerge.btnFromFileClick(Sender: TObject);
begin
  with OpenDialog1 do
  begin
    InitialDir := ExtractFilePath( edtDocument.Text);
    Filename := ExtractFilename( edtDocument.Text);

    if Execute then
      edtDocument.Text := Filename;
  end;
  //make sure all relative paths are relative to data dir after browse
  SysUtils.SetCurrentDir(GlobalDirectories.glDataDir);
end;

procedure TfrmMailMerge.FormDestroy(Sender: TObject);
begin
  CodeList.Free;
end;

// Fill list of clients
procedure TfrmMailMerge.FillCodeList(Codes: string);
var
  i: Integer;
  cfRec: pClient_File_Rec;
begin
  CodeList.DelimitedText := Codes;
  for i := 0 to Pred(CodeList.Count) do
  begin
    cfRec := AdminSystem.fdSystem_Client_File_List.FindCode(CodeList[i]);
    CodeList.Objects[i] := TObject(cfRec);
  end;
end;

// How many merge fields do we understand
procedure TfrmMailMerge.opemMergeGetColCount(Sender: TObject;
  var ColCount: Integer);
begin
  ColCount := 12;
end;

// Merge field names
// All are standard Word names except these additional ones:
// Mobile
// Practice
// NB: Don't use spaces in additional names because it replaces with underscore and gets confused!
procedure TfrmMailMerge.opemMergeGetColHeaders(Sender: TObject;
  var ColHeaders: Variant);
begin
  ColHeaders := VarArrayOf(['Salutation', 'First Name', 'Last Name', 'Company',
    'Address 1', 'Address 2', 'Address 3', 'Business Phone', 'Business Fax',
    'Email Address', 'Mobile', 'Practice'
    ]);
end;

// Supply requested merge data
// Index is field number
// Row is client number
// Write valid to Data parameter
procedure TfrmMailMerge.opemMergeGetData(Sender: TObject; Index,
  Row: Integer; Mode: TOpRetrievalMode; var Size: Integer;
  var Data: Variant);
var
  cfRec: pClient_File_Rec;
  i: Integer;
begin
  try
  if CodeList.count > 1 then
     UpdateAppStatusPerc( Row / Pred(CodeList.Count) * 100, True);
  cfRec := pClient_File_rec(CodeList.Objects[Row]);
  with ClientDetailsCache do
  begin
    Load(cfRec^.cfLRN);
    // Note we cant use commas because it will assume that it is a delimiter!
    // We MUST quote everything otherwise we get 2 problems:
    // 1. Strips leading zeros from numbers
    // 2. Sometimes skips whole fields (seems to be random)
    // Note this also happens in Word is you use the text provider in a DSN
    case Index of
      0: Data := '"' + ReplaceCommasAndQuotes(Salutation) + '"';
      1:
        begin
          i := Pos(' ', Contact_Name);
          if i > 0 then
            Data := '"' + ReplaceCommasAndQuotes(Copy(Contact_Name, 1, i-1)) + '"'
          else
            Data := '"' + ReplaceCommasAndQuotes(Contact_Name) + '"';
        end;
      2:
        begin
          i := Pos(' ', Contact_Name);
          if i > 0 then
            Data := '"' + ReplaceCommasAndQuotes(Copy(Contact_Name, i+1, Length(Contact_Name) - i))  + '"'
          else
            Data := ''; // Assume its a first name?
        end;
      3: Data := '"' + ReplaceCommasAndQuotes(Name) + '"';
      4: Data := '"' + ReplaceCommasAndQuotes(Address_L1) + '"';
      5: Data := '"' + ReplaceCommasAndQuotes(Address_L2) + '"';
      6: Data := '"' + ReplaceCommasAndQuotes(Address_L3) + '"';
      7: Data := '"' + ReplaceCommasAndQuotes(Phone_No) + '"';
      8: Data := '"' + ReplaceCommasAndQuotes(Fax_No) + '"';
      9: Data := '"' + ReplaceCommasAndQuotes(Email_Address) + '"';
      10: Data := '"' + ReplaceCommasAndQuotes(Mobile_No) + '"';
      11: Data := '"' + ReplaceCommasAndQuotes(AdminSystem.fdFields.fdPractice_Name_for_Reports) + '"';
    end;
  end;
  except
     // Not nice to float up from here..
  end;
end;

// Create and setup the mail merge form
function PerformMailMerge(Codes: string; WordObj: TOpWord): Boolean;
var
  i: Integer;
  TempPath:String;
begin
 Result := True;
 try
  if not BKFileExists(glDataDir + MAIL_MERGE_DATASOURCE_FILENAME) then
  begin
    HelpfulErrorMsg('The ' + TProduct.BrandName + ' Mail Merge Data Source cannot be found.'#13#13 +
      'Filename:' + glDataDir + MAIL_MERGE_DATASOURCE_FILENAME, 0);
    Result := False;
    Exit;
  end;
  // copy it locally otherwise it doesnt work on Office 2003
  SetLength(TempPath,Max_Path);
  SetLength(TempPath,GetTempPath(Max_Path,Pchar(TempPath)));
  CopyFile(PChar(glDataDir + MAIL_MERGE_DATASOURCE_FILENAME), PChar(TempPath + MAIL_MERGE_DATASOURCE_FILENAME), False);
  with TfrmMailMerge.Create(nil) do
    try
      // Disconnect and hide now
      // Note one problem - if the user still has previous merged doc open
      // then it will be lost if they return to this screen!
      WordObj.Connected := False;
      WordObj.Visible := False;
      DataSource := TempPath + MAIL_MERGE_DATASOURCE_FILENAME;
      FillCodeList(Codes);
      // Check all codes still exist
      i := 0;
      while i < CodeList.Count do
        if not CheckCodeExists(CodeList[i], True) then
        begin
          HelpfulWarningMsg('The Code "' + CodeList[i] + '" no longer exists in the admin system, and will not be included in the Mail Merge.', 0);
          CodeList.Delete(i);
        end
        else
          Inc(i);
      if CodeList.Count = 0 then
      begin
        HelpFulErrorMsg('All selected codes no longer exist in the admin system.'#13#13 +
          'The Mail Merge cannot be run.', 0);
        Result := False;
        exit;
      end;
      if FileExists(GlobalDirectories.glDataDir + MAIL_MERGE_PRINT_TEMPLATE_FILENAME) then
        edtDocument.Text := GlobalDirectories.glDataDir + MAIL_MERGE_PRINT_TEMPLATE_FILENAME;
      edtSave.Text := GlobalDirectories.glDataDir + MAIL_MERGE_PRINT_RESULT_FILENAME;
      Word := WordObj;
      ShowModal;
    finally
      Free;
    end;
 except on E: Exception do
    HelpfulErrorMsg('Microsoft Word did not respond as expected.'#13#13'Please check that Microsoft Word is set up correctly on your computer.'#13#13 +
      'Error: ' + E.Message, 0);
 end;
end;

// Enable/Disable tasks
procedure TfrmMailMerge.chkTaskClick(Sender: TObject);
begin
  edtDescription.Visible := chkTask.Checked;
  ovcFollowup.Visible := chkTask.Checked;
  btnQuik.Visible := chkTask.Checked;
  if chkTask.Checked then
  begin
    gbTask.Height := 121;
    gbSummary.Top := 264;
    btnOk.Top := 371;
    btnCancel.Top := 371;
    Height := 440;
  end
  else
  begin
    gbTask.Height := 51;
    gbPrint.Top := 194;
    gbSummary.Top := 194;
    btnOk.Top := 301;
    btnCancel.Top := 301;
    Height := 370;
  end;
end;

// Set follow up date

procedure TfrmMailMerge.N1WeekClick(Sender: TObject);
begin
  ovcFollowup.AsStDate := IncDate(stDate.CurrentDate, 7, 0, 0);
end;

procedure TfrmMailMerge.N2WeeksClick(Sender: TObject);
begin
  ovcFollowup.AsStDate := IncDate(stDate.CurrentDate, 14, 0, 0);
end;

procedure TfrmMailMerge.N4WeeksClick(Sender: TObject);
begin
  ovcFollowup.AsStDate := IncDate(stDate.CurrentDate, 0, 1, 0);
end;

procedure TfrmMailMerge.N6WeeksClick(Sender: TObject);
begin
  ovcFollowup.AsStDate := IncDate(stDate.CurrentDate, 42, 0, 0);
end;

procedure TfrmMailMerge.N2MonthsClick(Sender: TObject);
begin
  ovcFollowup.AsStDate := IncDate(stDate.CurrentDate, 0, 2, 0);
end;

procedure TfrmMailMerge.N4MonthsClick(Sender: TObject);
begin
  ovcFollowup.AsStDate := IncDate(stDate.CurrentDate, 0, 4, 0);
end;

function TfrmMailMerge.ValidateDates: Boolean;
var
  D : integer;
begin
  D := stNull2Bk(ovcFollowup.AsStDate);

  if (D < MinValidDate) or (D > MaxValidDate) then
  begin
    HelpfulWarningMsg( 'You must select a valid reminder date.', 0);
    Result := False;
  end
  else
    Result := True;
end;

procedure TfrmMailMerge.PopUpCalendar( aRect : TRect; var aDate : integer);
var
  PopupPanel: TRzPopupPanel;
  Calendar: TRzCalendar;
  HiddenEdit : TEdit;
begin
  PopupPanel := TRzPopupPanel.Create( Self );
  try
    Calendar := TRzCalendar.Create( PopupPanel );
    Calendar.Parent := PopupPanel;
    PopupPanel.Parent := Self;
    PopupPanel.Font.Name := ovcFollowup.Font.Name;
    PopupPanel.Font.Color := ovcFollowup.Font.Color;

    Calendar.IsPopup := True;
    Calendar.Color := ovcFollowup.Color;
    Calendar.Elements := [ceYear,ceMonth,ceArrows,ceDaysOfWeek,ceFillDays,ceTodayButton,ceClearButton];
    Calendar.FirstDayOfWeek := fdowLocale;
    Calendar.Handle;

    if aDate <> 0 then
      Calendar.Date := StDate.StDateToDateTime( aDate);

    //Calendar.BorderOuter := fsFlat;
    Calendar.Visible := True;
    Calendar.OnClick := PopupPanel.Close;

    //create a hidden edit box to position the popup under, need to
    //move into position of the rect provided
    HiddenEdit := TEdit.Create( Self);
    HiddenEdit.Parent  := Self;
    HiddenEdit.Visible := False;
    aRect.Right := aRect.Left +  Calendar.Width;    
    HiddenEdit.BoundsRect := aRect;

    if PopupPanel.Popup( HiddenEdit) then
      if ( Calendar.Date <> 0 ) then
        aDate := StDate.DateTimeToStDate( Calendar.Date)
      else
        aDate := 0;
  finally
    PopupPanel.Free;
  end;
end;

procedure TfrmMailMerge.btnQuikClick(Sender: TObject);
var
  aDate: Integer;
  R: TRect;
  P: TPoint;
begin
  //get current value
  aDate := ovcFollowup.AsStDate;
  R := btnQuik.ClientRect;
  P := btnQuik.ClientToParent(R.TopLeft, Self);
  OffsetRect( R, P.X + R.Left, (  P.Y - R.Top));
  PopUpCalendar( R, aDate);
  //set current value
  if aDate > 0 then
    ovcFollowup.AsStDate := aDate
  else if aDate = 0 then
    ovcFollowup.asStDate := -1;
end;

procedure TfrmMailMerge.FormShow(Sender: TObject);
begin
  BKHelpSetup(Self, BKH_Merging_and_printing_documents_using_Client_Manager);
end;

end.
