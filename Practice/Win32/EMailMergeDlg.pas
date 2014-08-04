unit EMailMergeDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ovcbase, ovcef, ovcpb, ovcpf, RzButton, Buttons,
  ExtCtrls, OpShared, OpModels, OpWrdXP, OpWord, Menus,
  OsFont;

type
  TfrmEMailMerge = class(TForm)
    OpenDialog1: TOpenDialog;
    opemMerge: TOpEventModel;
    popFollowup: TPopupMenu;
    N1Week: TMenuItem;
    N2Weeks: TMenuItem;
    N4Weeks: TMenuItem;
    N6Weeks: TMenuItem;
    N2Months: TMenuItem;
    N4Months: TMenuItem;
    gbDocs: TGroupBox;
    Label2: TLabel;
    btnFromFile: TSpeedButton;
    edtDocument: TEdit;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    rbAttach: TRadioButton;
    rbMessageHTML: TRadioButton;
    edtSubject: TEdit;
    rbMessageText: TRadioButton;
    gbTask: TGroupBox;
    Label1: TLabel;
    Label3: TLabel;
    btnQuik: TRzToolButton;
    edtDescription: TEdit;
    ovcFollowup: TOvcPictureField;
    chkTask: TCheckBox;
    gbPrint: TGroupBox;
    Label5: TLabel;
    InfoBmp: TImage;
    rbPreview: TRadioButton;
    rbSend: TRadioButton;
    rbManual: TRadioButton;
    gbSummary: TGroupBox;
    rbRepNone: TRadioButton;
    rbRepScreen: TRadioButton;
    rbRepPrint: TRadioButton;
    rbRepFile: TRadioButton;
    btnOk: TButton;
    btnCancel: TButton;
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
    procedure edtSubjectExit(Sender: TObject);
    procedure btnQuikClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    CodeList: TStringList;
    FowMerge: TOpWord;
    FDataSource: string;
    function EMailDoc: Boolean;
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
  frmEMailMerge: TfrmEMailMerge;

const
  UnitName = 'EMailMergeDlg';

function PerformEMailMerge(Codes: string; WordObj: TOpWord): Boolean;

implementation

uses ImagesFrm, WarningMoreFrm, ErrorMoreFrm, YesNoDlg, glConst, WinUtils,
  GlobalDirectories, bkXPThemes, Globals, SYDefs, ClientDetailCacheObj,
  progress, GenUtils, ToDoHandler, stDate, rptMailMerge, RzPopups, Admin32,
  bkDateUtils, ReportDefs, EMailMergePreview, LogUtil, ClientUtils, bkHelp,
  bkConst, bkProduct;

{$R *.dfm}

// Perform the merge
function TfrmEMailMerge.EMailDoc: Boolean;
const
  ThisMethodName = 'EMailDoc';
var
  MergeDoc: TOpWordDocument;
  Description, newfilename: string;
  i: Integer;
  idx, changes, sql, b, filename: OleVariant;
  v: Double;
  s: TStringList;
  h: HWND;
  Is2007: Boolean;
begin
  Result := True;
  newfilename := '';
  opemMerge.RowCount := CodeList.Count;
  UpdateAppStatus('Merging Document', 'Please wait...', 70, True);
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
  try
    FowMerge.DisplayAlerts := wdalAll;
    if Is2007 then
    begin
      FowMerge.Visible := True;
      Application.ProcessMessages;
      h := FindWindow(nil, 'Microsoft Word');
      if h <> 0 then BringWindowToTop(h);
      FowMerge.DisplayAlerts := wdalNone
    end;
    MergeDoc := FowMerge.OpenDocument(edtDocument.Text);
    FowMerge.DisplayAlerts := wdalNone;
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
      if Pos(ExtractFilename(edtDocument.Text), FowMerge.Server.Documents.Item(idx).Name) > 0 then
        Inc(i)
      else
      begin
        FowMerge.Server.Documents.Item(idx).Close(changes, emptyParam, emptyParam);
        FowMerge.Visible := False;
        Sleep(500); // Time for Word to close the doc
      end;
    end;
    FowMerge.Visible := False;
    try
      MergeDoc.MailMerge.OfficeModel := opemMerge;
      if MergeDoc.MailMerge.AsMailMerge = nil then
      begin
        MergeDoc.AsDocument.Close(changes, emptyParam, emptyParam);
        FowMerge.Connected := False;
        HelpfulWarningMsg('The selected document is not a Mail Merge document. The Mail Merge failed'#13#13 +
          'Filename : ' + edtDocument.Text, 0);
        LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Not a Mail Merge document: ' + edtDocument.Text);
        Result := False;
        Exit;
      end;
      MergeDoc.MailMerge.AsMailMerge.Destination := wdSendToEMail;
      if FowMerge.OfficeVersion <> ov2000 then // Cant set it for Office2000 - only supports plain text
      begin
        {if rbAttach.Checked then
          MergeDoc.MailMerge.AsMailMerge.MailAsAttachment := True
        else }if rbMessageHTML.Checked then
          MergeDoc.MailMerge.AsMailMerge.MailFormat := wdMailFormatHTML
        else
          MergeDoc.MailMerge.AsMailMerge.MailFormat := wdMailFormatPlainText;
      end;
      MergeDoc.MailMerge.AsMailMerge.MailSubject := edtSubject.Text;
      MergeDoc.MailMerge.AsMailMerge.MailAddressFieldName := 'Email_Address';
      UpdateAppStatusPerc( 80, True);
      MergeDoc.PopulateMailMerge;
      UpdateAppStatusPerc( 90, True);
      i := 1;
      changes := False;
      while FowMerge.Server.Documents.Count > 1 do
      begin
        idx := i;
        if Pos(ExtractFilename(edtDocument.Text), FowMerge.Server.Documents.Item(idx).Name) > 0 then
          Inc(i)
        else
        begin
          FowMerge.Server.Documents.Item(idx).Close(changes, emptyParam, emptyParam);
          FowMerge.Visible := False;
          Sleep(500); // Time for Word to close the doc
        end;
      end;
  //    if rbManual.Checked then // Do it manually to avoid the outlook security question
  //    begin
      // Always do it manually
        FowMerge.WindowState := wdwsMaximized;
        FowMerge.Visible := True;
  {    end
      else if rbSend.Checked then // Send now
      begin
        MergeDoc.ExecuteMailMerge;
        FowMerge.Connected := False;
      end
      else // Preview
      begin
        if PreviewMailMerge(CodeList, edtDocument.Text, edtSubject.Text) then
        begin
          MergeDoc.ExecuteMailMerge;
          FowMerge.Connected := False;
        end
        else
        begin
          FowMerge.Connected := False;
          exit; // skip summary report cos its been cancelled
        end;
      end;}
      UpdateAppStatusPerc(100, True);
      if not rbRepNone.Checked then
      begin
        if chkTask.Checked then
          Description := edtDescription.Text
        else
          Description := '';
        if rbRepScreen.Checked then
        begin
          AdminSystem.fdFields.fdEmail_Merge_Report_Summary := rbRepScreen.Tag;
          DoMergeEmailReport(rdScreen, Description, edtSubject.Text, bkdateutils.bkDate2Str(stDate.CurrentDate),
             bkdateutils.bkDate2Str(ovcFollowup.AsStDate), CodeList);
        end
        else if rbRepPrint.Checked then
        begin
          AdminSystem.fdFields.fdEmail_Merge_Report_Summary := rbRepPrint.Tag;
          DoMergeEmailReport(rdPrinter, Description, edtSubject.Text, bkdateutils.bkDate2Str(stDate.CurrentDate),
             bkdateutils.bkDate2Str(ovcFollowup.AsStDate), CodeList);
        end;
{        else if rbRepFile.Checked then
            DoMergeEmailReport(rdFile, Description, bkdateutils.bkDate2Str(stDate.CurrentDate),
               bkdateutils.bkDate2Str(ovcFollowup.AsStDate), CodeList);}
      end
      else
        AdminSystem.fdFields.fdEmail_Merge_Report_Summary := rbRepNone.Tag;
      if LoadAdminSystem(true, 'TfrmEMailMerge.EMailDoc' ) then
        SaveAdminSystem
      else
        HelpfulErrorMsg('Unable to Update Mail Merge Settings.  Admin System cannot be loaded',0);
    finally
      ClearStatus(True);
      if Is2007 then
        DeleteFile(newfilename);
      // Log
      LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + 'Mail Merge/EMail with Subject "' + edtSubject.Text + '" generated on ' + bkdateutils.bkDate2Str(stDate.CurrentDate));
      if chkTask.Checked then
        LogUtil.LogMsg(lmInfo, UnitName, 'Task created "' + edtDescription.Text + '", Reminder on ' + bkdateutils.bkDate2Str(ovcFollowup.AsStDate));
      LogUtil.LogMsg(lmInfo, UnitName, 'Source document: ' + edtDocument.Text);
      LogUtil.LogMsg(lmInfo, UnitName, 'Clients: ' + CodeList.CommaText);
    end;
  except on E: Exception do
   begin
    FowMerge.Connected := False;
    HelpFulErrorMsg('There were problems performing the Mail Merge/Email using Word.' + #13#13 +
      'Please see log for more details.', 0);
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Mail Merge/Email Failure: ' + E.Message);
    Result := False;
   end;
  end;
end;

// Verify the form is all ok
function TfrmEMailMerge.VerifyForm: Boolean;
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
  else if Trim(edtSubject.Text) = '' then
  begin
    HelpfulWarningMsg('You must specify a subject for the mail message.', 0);
    edtSubject.SetFocus;
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
end;

// Do the merge if all valid
procedure TfrmEMailMerge.btnOkClick(Sender: TObject);
var
  i: Integer;
  cfRec: pClient_File_Rec;
  Saved: Boolean;
begin
  if VerifyForm then
  begin
    if EMailDoc and chkTask.Checked then // Add task for each client if required
      for i := 0 to Pred(CodeList.Count) do
      begin
        // If no email address it wont of been sent so dont add todo
        cfRec := AdminSystem.fdSystem_Client_File_List.FindCode(CodeList[i]);
        with ClientDetailsCache do
        begin
          Load(cfRec^.cfLRN);
          if Email_Address <> '' then
          begin
            AddAutomaticToDoItem(CodeList[i], ttyMailMergeEmail, edtDescription.Text, ovcFollowup.AsStDate);
          end;
        end;
      end;
    ModalResult := mrOk;
  end;
end;

// Initialise form
procedure TfrmEMailMerge.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(Self);
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnFromFile.Glyph);
  CodeList := TStringList.Create;
  CodeList.Delimiter := ClientCodeDelimiter;
  case AdminSystem.fdFields.fdEmail_Merge_Report_Summary of
    0: rbRepScreen.Checked := True;
    1: rbRepNone.Checked := True;
    2: rbRepPrint.Checked := True;
    else rbRepScreen.Checked := True;
  end;
  chkTaskClick(Sender);
end;

// Browse for merged doc
procedure TfrmEMailMerge.btnFromFileClick(Sender: TObject);
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

procedure TfrmEMailMerge.FormDestroy(Sender: TObject);
begin
  CodeList.Free;
end;

// Fill list of clients
procedure TfrmEMailMerge.FillCodeList(Codes: string);
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
procedure TfrmEMailMerge.opemMergeGetColCount(Sender: TObject;
  var ColCount: Integer);
begin
  ColCount := 12;
end;

// Merge field names
// All are standard Word names except these additional ones:
// Mobile
// Practice
// NB: Don't use spaces in additional names because it replaces with underscore and gets confused!
procedure TfrmEMailMerge.opemMergeGetColHeaders(Sender: TObject;
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
procedure TfrmEMailMerge.opemMergeGetData(Sender: TObject; Index,
  Row: Integer; Mode: TOpRetrievalMode; var Size: Integer;
  var Data: Variant);
var
  cfRec: pClient_File_Rec;
  i: Integer;
begin
  if CodeList.Count > 1  then
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
end;

// Create and setup the mail merge form
function PerformEMailMerge(Codes: string; WordObj: TOpWord): Boolean;
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
  with TfrmEMailMerge.Create(Application.MainForm) do
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
      if FileExists(GlobalDirectories.glDataDir + MAIL_MERGE_EMAIL_TEMPLATE_FILENAME) then
        edtDocument.Text := GlobalDirectories.glDataDir + MAIL_MERGE_EMAIL_TEMPLATE_FILENAME;
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
procedure TfrmEMailMerge.chkTaskClick(Sender: TObject);
begin
  edtDescription.Visible := chkTask.Checked;
  ovcFollowup.Visible := chkTask.Checked;
  btnQuik.Visible := chkTask.Checked;
  if edtDescription.Visible and (edtDescription.Text = '') then
    edtDescription.Text := edtSubject.Text;
  if chkTask.Checked then
  begin
    gbTask.Height := 121;
    gbPrint.Top := 299;
    gbSummary.Top := 299;
    btnOk.Top := 414;
    btnCancel.Top := 414;
    Height := 480;
  end
  else
  begin
    gbTask.Height := 51;
    gbPrint.Top := 229;
    gbSummary.Top := 229;
    btnOk.Top := 344;
    btnCancel.Top := 344;
    Height := 410;
  end;
end;

// Set follow up date

procedure TfrmEMailMerge.N1WeekClick(Sender: TObject);
begin
  ovcFollowup.AsStDate := IncDate(stDate.CurrentDate, 7, 0, 0);
end;

procedure TfrmEMailMerge.N2WeeksClick(Sender: TObject);
begin
  ovcFollowup.AsStDate := IncDate(stDate.CurrentDate, 14, 0, 0);
end;

procedure TfrmEMailMerge.N4WeeksClick(Sender: TObject);
begin
  ovcFollowup.AsStDate := IncDate(stDate.CurrentDate, 0, 1, 0);
end;

procedure TfrmEMailMerge.N6WeeksClick(Sender: TObject);
begin
  ovcFollowup.AsStDate := IncDate(stDate.CurrentDate, 42, 0, 0);
end;

procedure TfrmEMailMerge.N2MonthsClick(Sender: TObject);
begin
  ovcFollowup.AsStDate := IncDate(stDate.CurrentDate, 0, 2, 0);
end;

procedure TfrmEMailMerge.N4MonthsClick(Sender: TObject);
begin
  ovcFollowup.AsStDate := IncDate(stDate.CurrentDate, 0, 4, 0);
end;

function TfrmEMailMerge.ValidateDates: Boolean;
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

procedure TfrmEMailMerge.edtSubjectExit(Sender: TObject);
begin
  if edtDescription.Visible and (edtDescription.Text = '') and
     chkTask.Checked and (edtSubject.Text <> '') then
    edtDescription.Text := edtSubject.Text;
end;

procedure TfrmEMailMerge.PopUpCalendar( aRect : TRect; var aDate : integer);
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

procedure TfrmEMailMerge.btnQuikClick(Sender: TObject);
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

procedure TfrmEMailMerge.FormShow(Sender: TObject);
begin
  BKHelpSetup(Self, BKH_Merging_and_sending_e_mails_using_Client_Manager);
  // Office 2000 only supports plain text email merging
  while FowMerge.Documents.Count > 0 do
    FowMerge.Documents.Delete(0);
  FowMerge.Connected := True;
  FowMerge.Visible := False;
  if FowMerge.OfficeVersion = ov2000 then
  begin
    rbMessageText.Checked := True;
    rbMessageHTML.Enabled := False;
  end;
  FowMerge.Connected := False;
  Application.BringToFront;
  Self.SetFocus;
end;

end.
