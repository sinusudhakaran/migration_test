unit SaveReportToDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:     Save Report to where dialog

  Written:
  Authors:

  Purpose:   Allows the user to select which format or application to generate the
             report in.

  Notes:
}
//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Buttons,
  ReportDefs,
  OSFont,
  CustomFileFormats;

type
  TdlgSaveReportTo = class(TForm)
    lblSaveTo: TLabel;
    btnToFolder: TSpeedButton;
    eTo: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    cmbFormat: TComboBox;
    svdFilename: TSaveDialog;
    lblTitle: TLabel;
    lblDesc: TLabel;
    edtTitle: TEdit;
    edtDesc: TEdit;
    lblWebSpace: TLabel;
    cmbWebSpace: TComboBox;
    lblCategory: TLabel;
    cmbCategory: TComboBox;
    procedure btnToFolderClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure eToChange(Sender: TObject);
    procedure cmbFormatChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmbWebSpaceChange(Sender: TObject);
  private
    { Private declarations }
    NameEdited : boolean;
    IgnoreChange : boolean;
    PreviousIndex: Integer; // to restore previous selection if Acclipse is not installed
    fCustomFileFormats : TCustomFileFormats;
    fDefaultFileName : string;

    function GetPositionFromIndex(aIndex : integer) : integer;
    function GetSelectedIndex : integer;
    function GetSelectedFileNameAndExt : string;
    function GetSelectedFileExt : string;
    function GetSelectedFileName : string;
  public
    property DefaultFileName : string read fDefaultFileName write fDefaultFileName;
  end;

//------------------------------------------------------------------------------
function GenerateReportTo(var FileName : string;
                          var FileFormat : integer;
                          FileFormats : TFileFormatSet;
                          var Title, Desc: string;
                          var WebID, CatID: Integer;
                          HideAcclipse: Boolean;
                          aCustomFileFormats : TCustomFileFormats = nil) : boolean;

//------------------------------------------------------------------------------
implementation

{$R *.DFM}

uses
  bkXPThemes,
  Globals,
  ImagesFrm,
  ErrorMoreFrm,
  InfoMoreFrm,
  WarningMoreFrm,
  YesNoDlg,
  GenUtils,
  bkConst,
  WinUtils,
  ComboUtils,
  WebXOffice,
  glConst,
  ReportFileFormat,
  strutils;

//------------------------------------------------------------------------------
procedure TdlgSaveReportTo.btnToFolderClick(Sender: TObject);
var
  Element: Integer;
begin
  with svdFilename do
  begin
    // Default file type - add 2 - 1 for All files, 1 because FilterIndex starts at 1 instead of 0 (#1743)
    svdFilename.FilterIndex := GetPositionFromIndex(GetSelectedIndex()) + 2;
    InitialDir := '';

    if ( eTo.Text <> '') then
    begin
      FileName := ExtractFileName(eTo.text);
      InitialDir := ExtractFilePath(eTo.text);
    end
    else
    begin
      FileName := GetSelectedFileNameAndExt();
    end;

    if InitialDir = '' then
      InitialDir := DataDir;

    if Execute then
    begin
      IgnoreChange := True;
      // If user picked file from browse then we want to change extn when a new type is chosen
      NameEdited := False;
      InitialDir := ExtractFilePath(Filename);

      if sametext(IncludeTrailingBackslash(InitialDir),DataDir)
      or (InitialDir = '') then // Dont need this
        eTo.text := ExtractFileName(Filename)
      else
        eTo.text := Filename;

      cmbFormat.ItemIndex := svdFilename.FilterIndex-2;
      Ignorechange := False;
    end;
  end;

  //make sure all relative paths are relative to data dir after browse
  SysUtils.SetCurrentDir( Globals.DataDir);
end;

//------------------------------------------------------------------------------
//
// GenerateReportTo
//
// FileFormats : specifies a set of file types can be saved. If the set is
//               empty then all file types can be saved.
//
function GenerateReportTo(var FileName : string;
                          var FileFormat : integer;
                          FileFormats : TFileFormatSet;
                          var Title, Desc: string;
                          var WebID, CatID: Integer;
                          HideAcclipse: Boolean;
                          aCustomFileFormats : TCustomFileFormats = nil) : boolean;
var
  i : Integer;
  HideInOz: Boolean;
  InitialDir: string;
begin
   result := false;
{$IFNDEF Smartlink}
   if CurrUser.HasRestrictedAccess then begin
      HelpfulInfoMsg( 'You do not have access to the print to file function.', 0);
      Exit;
   end;
{$ENDIF}

   with TdlgSaveReportTo.Create(Application.MainForm) do
   begin
     fCustomFileFormats := aCustomFileFormats;
     DefaultFileName := FileName;

      try
        //Load combo with constants - load in order defined. This means the selected
        //index will be the format identifier
        with cmbFormat do begin
           Clear;

           if (Assigned(fCustomFileFormats)) and
              (fCustomFileFormats.Count > 0) then
           begin
             for i := 0 to fCustomFileFormats.Count-1 do
             begin
               // Adds the index of the custom format to the standard formats
               Items.AddObject(TCustomFileFormat(fCustomFileFormats.Items[i]).Name, TObject(rfMax + i + 1));
               if TCustomFileFormat(fCustomFileFormats.Items[i]).Selected then
               begin
                 ItemIndex := i;
               end;
             end;
           end;

           for i := rfMin to rfMax do begin
             if (FileFormats = []) or (TFileFormats(i) in FileFormats) then
             begin
               HideInOz := Assigned(MyClient) and (MyClient.clFields.clCountry = whAustralia) and (MyClient.clFields.clWeb_Export_Format = 255);
               if (i = rfAcclipse) and
                   (HideAcclipse or HideInOz or
                   (Assigned(MyClient) and (MyClient.clFields.clWeb_Export_Format <> wfWebX) and (MyClient.clFields.clWeb_Export_Format <> 255)) ) then
                 Continue;
               Items.AddObject(RptFileFormat.Names[i], TObject(i));
             end;
           end;

           //enable/disable and set the itemindex for cmbFormat
           if (Items.Count = 0) then
             Enabled := True
           else if ItemIndex < 0 then
           begin
             i := Items.IndexOfObject(TObject(rfExcel));
             if (i <> -1) then
               ItemIndex := i
             else
               ItemIndex := 0;
           end;
        end;

        svdFilename.Filter := 'All Files (*.*)|*.*';
        if (Assigned(fCustomFileFormats)) and
           (fCustomFileFormats.Count > 0) then
        begin
          for i := 0 to fCustomFileFormats.Count-1 do
          begin
            // Adds the index of the custom format to the standard constants
            svdFilename.Filter := svdFileName.Filter + '|' +
                                  TCustomFileFormat(fCustomFileFormats.Items[i]).Description + '|*' +
                                  TCustomFileFormat(fCustomFileFormats.Items[i]).Extension;
          end;
        end;

        // Populate the browse dialog with standard constants
        for i := 0 to rfMax do
        begin
          HideInOz := Assigned(MyClient) and (MyClient.clFields.clCountry = whAustralia) and (MyClient.clFields.clWeb_Export_Format = 255);
          if (i = rfAcclipse) and
             (HideAcclipse or HideInOz or
             (Assigned(MyClient) and (MyClient.clFields.clWeb_Export_Format <> wfWebX) and (MyClient.clFields.clWeb_Export_Format <> 255)) ) then
            Continue;

          svdFilename.Filter := svdFileName.Filter + '|' + RptFileFormat.Names[i] + '|*' + RptFileFormat.Extensions[i];
        end;

        PreviousIndex := cmbFormat.ItemIndex;
        IgnoreChange := True;
        // Suppress path if in own datadata
        InitialDir := IncludeTrailingBackslash(ExtractFilePath(Filename));
        if (InitialDir = '')
        or Sametext(InitialDir, DataDir) then begin
            eto.Text := ExtractFilename(Filename);
        end else
           eTo.Text := Filename;

        edtTitle.Text := ChangeFileExt(Filename, '');
        IgnoreChange := False;
        cmbFormatChange(cmbFormat);
        ShowModal;
        if ModalResult = mrOK then
        begin
          Filename := eTo.text;
          if ExtractFilePath(Filename) = '' then // Force full path
            FileName := DataDir + FileName;

          FileFormat := GetSelectedIndex();
          // Add default filename back if the user hasnt specified a filename
          if ExtractFileExt(Filename) = '' then
            Filename := 'Report' + RptFileFormat.Extensions[FileFormat];

          Title := edtTitle.Text;
          Desc := edtDesc.Text;
          if FileFormat = rfAcclipse then
          begin
            WebID := Integer(cmbWebSpace.Items.Objects[cmbWebSpace.ItemIndex]);
            CatID := Integer(cmbCategory.Items.Objects[cmbCategory.ItemIndex]);
          end;
          result   := true;
        end;
      finally
        Free;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgSaveReportTo.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnToFolder.Glyph);
end;

//------------------------------------------------------------------------------
procedure TdlgSaveReportTo.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  dirPath, filenoext, wxfilename, fileext : string;
  i: Integer;
  ValRes : boolean;
  ValMsg : string;
begin
   //verify entry
   if ModalResult = mrOK then
   begin
     //Assume failure
     CanClose := false;

     if (Assigned(fCustomFileFormats)) and
       (fCustomFileFormats.Count > 0) then
     begin
       if GetSelectedIndex > rfMax then
       begin
         TCustomFileFormat(fCustomFileFormats.Items[GetSelectedIndex - 1 - rfMax]).DoCustomFormatValidation(ValRes, ValMsg);
         if not ValRes then
         begin
           HelpfulWarningMsg(ValMsg,0);
           ModalResult := mrCancel;
           CanClose := true;
           exit;
         end;
       end;
     end;

        if GetSelectedIndex() = rfAcclipse then
        begin
          // Verify acclipse
          if Trim(edtTitle.Text) = '' then
          begin
            edtTitle.SetFocus;
            HelpfulWarningMsg('You must specify a Title for the report.',0);
            exit;
          end;

          if cmbWebspace.ItemIndex = -1 then
          begin
            cmbwebSpace.SetFocus;
            HelpfulWarningMsg('You must specify a Secure Area in which to upload the report.',0);
            exit;
          end;

          if cmbCategory.ItemIndex = -1 then
          begin
            cmbCategory.SetFocus;
            HelpfulWarningMsg('You must specify a Category for the report.',0);
            exit;
          end;
          eTo.Text := WebXOffice.GetWebXDataPath(WEBX_EXPORT_FOLDER) + ExtractFilename(eTo.Text);
      end;

      //verify the file name if one is needed
      // always needed?
//      if cmbFormat.ItemIndex in [ rfCSV, rfFixedWidth ] then begin
         //Set focus back to filename box incase anything fails
         eTo.SetFocus;
         //verify the filename
         if ExtractFileName( eTo.Text ) = ''  then
         begin
            HelpfulWarningMsg('You must specify a file name for the report.',0);
            exit;
         end;
         // check that not trying to save to a file which has the same name as a directory
         DirPath := AddSlash(eTo.Text);
         if DirectoryExists( DirPath ) then  begin
            HelpfulWarningMsg('You can''t use this name because a directory called '+DirPath+' already exists.', 0);
            exit;
         end;
         //check that not writing with a bk5 extension
         if ExtractFileExt( eTo.Text ) = '.BK5' then begin
            HelpfulWarningMsg('You can''t use this name because the .BK5 extension is used by '+ShortAppName, 0 );
            exit;
         end;
         // do not allow overwrite of Authority PDFs
         if (Lowercase(ExtractFileName( eTo.Text )) = Lowercase(TPA_FILENAME)) or
            (Lowercase(ExtractFileName( eTo.Text )) = Lowercase(CAF_FILENAME)) then
         begin
            HelpfulWarningMsg('You can''t use this file name because it is reserved for use by '+ShortAppName, 0 );
            exit;
         end;
         //Verify directory exists
         DirPath := ExtractFilePath( eTo.Text );
         if (DirPath = '') then
            DirPath := DATADIR;

         if not DirectoryExists(DirPath) then
         begin
            if AskYesNo('Create Directory',
                        'The folder '+DirPath +' does not exist. Do you want to Create it?',
                         DLG_YES,0) <> DLG_YES then begin
               Exit;
            end;
            ForceDirectories(DirPath);
            if not DirectoryExists(DirPath) then begin
               HelpfulErrorMsg('Cannot Create Extract Data Directory '+DirPath,0);
               Exit;
            end;
         end;
//      end;
      //Check if will be overwriting an existing file
      if GetSelectedIndex() = rfAcclipse then
      begin
        fileext := ExtractFileExt(eTo.Text);
        if fileext = '' then
          fileext := '.PDF';
        // Make a unique filename
        i := 1;
        filenoext := ChangeFileExt(ExtractFilename(ExtractFilename(eTo.Text)), '');
        wxfilename := GetWebXDatapath(WEBX_EXPORT_FOLDER) + FileNoExt + '_' +
                      IntToStr(i) + fileext;
        while BKFileExists(WxFilename) do
        begin
          Inc(i);
          wxfilename := GetWebXDataPath(WEBX_EXPORT_FOLDER) + FileNoExt + '_' +
                       IntToStr(i) + fileext;
        end;
        eTo.Text := wxfilename;
      end
      else
      begin
        fileext := ExtractFileExt(eTo.Text);

        if fileext = '' then
          eTo.Text := eTo.Text + GetSelectedFileExt();

        if BKFileExists(eTo.Text) then
        begin
          if AskYesNo('Overwrite File','The file '+ExtractFileName(eTo.Text)+' already exists. Overwrite?',dlg_yes,0) <> DLG_YES then
            exit;
        end;
      end;
      //Nothing failed so can close
      CanClose := true;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgSaveReportTo.eToChange(Sender: TObject);
begin
   if not IgnoreChange then
     NameEdited := true;
end;

//------------------------------------------------------------------------------
procedure TdlgSaveReportTo.cmbFormatChange(Sender: TObject);
//If the user hasn't edited the file name field then change the extension to
//match the format chosen
//If the user selects an "Application" (Excel, Word) to export to then disable
//the filename box because a filename is not required unless we force a save of
//the document
var
  Element : Integer;
  IsAcclipse: Boolean;
  WebXFile: string;
  S: TStrings;
  CustomFormatsCount: integer;
begin
   IsAcclipse := GetComboCurrentIntObject(cmbformat) = rfAcclipse;
   if IsAcclipse then
   begin
    // Acclipse
    S := TStringList.Create;
    try
      WebXFile := WebXOffice.GetWebXDataPath;
      WebXOffice.ReadSecureAreas(S);
      if (WebXFile = '') then
      begin
        HelpfulInfoMsg(WEBX_APP_NAME + ' Secure Client Manager does not appear to be installed on the workstation.' + #13#13 +
                'You must install the software before you can use this function.', 0);
        cmbFormat.ItemIndex := PreviousIndex;
        exit;
      end;
      if not FileExists(WebXOffice.GetWebXDataPath + glConst.WEBX_FOLDERINFO_FILE) then
      begin
        HelpfulInfoMsg('The ' + WEBX_APP_NAME + ' file listing the Secure Areas cannot be found. ' + #13 +
            'File: ' + WebXFile + #13#13 +
            'You must install the software before you can use this function.', 0);
        cmbFormat.ItemIndex := PreviousIndex;
        exit;
      end;
      if S.Count = 0 then
      begin
        HelpfulInfoMsg('There are no ' + WEBX_APP_NAME + ' Secure Areas set up. ' + #13#13 +
          'You must install the software before you can use this function.', 0);
        cmbFormat.ItemIndex := PreviousIndex;
        exit;
      end
      else
      begin
        S := TStringList.Create;
        WebXOffice.ReadSecureAreas(S);
        cmbWebSpace.Clear;
        cmbWebSpace.Items := S;
        cmbWebSpace.ItemIndex := cmbWebSpace.Items.IndexOfObject(TObject(MyClient.clFields.clECoding_WebSpace));
        cmbWebSpaceChange(nil);
      end;
    finally
      S.Free;
    end;
  end;
  if IsAcclipse then
    Height := 295
  else
    Height := 136;

  edtTitle.Visible := IsAcclipse;
  edtDesc.Visible := IsAcclipse;
  cmbWebSpace.Visible := IsAcclipse;
  cmbCategory.Visible := IsAcclipse;
  lblTitle.Visible := IsAcclipse;
  lblDesc.Visible := IsAcclipse;
  lblWebSpace.Visible := IsAcclipse;
  lblCategory.Visible := IsAcclipse;
  btnToFolder.Visible := not IsAcclipse;
  PreviousIndex := cmbFormat.ItemIndex;

  if not NameEdited then
  begin
    IgnoreChange := true;
    Element := GetPositionFromIndex(GetSelectedIndex());

    if Assigned(fCustomFileFormats) then
      CustomFormatsCount := fCustomFileFormats.Count
    else
      CustomFormatsCount := 0;
    if CustomFormatsCount > 0 then
      eTo.Text := IncludeTrailingBackslash(ExtractFilePath(eTo.text)) + GetSelectedFileNameAndExt()
    else
      eTo.Text := ChangeFileExt( eTo.Text, GetSelectedFileExt());

    eTo.Enabled       := true;
    lblSaveTo.Enabled := true;
    btnToFolder.enabled := true;
    IgnoreChange := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgSaveReportTo.FormShow(Sender: TObject);
begin
  //Set flag that tells us if the user has changed the name field
  NameEdited := false;
  //Set flag the tells change method of edit box to ignore the change
  IgnoreChange := false;

  if (cmbFormat.Items.Count = 1) then
    eTo.SetFocus;
end;

//------------------------------------------------------------------------------
procedure TdlgSaveReportTo.cmbWebSpaceChange(Sender: TObject);
var
  S: TStrings;
begin
  if cmbWebSpace.ItemIndex = -1 then exit;
  S := TStringList.Create;
  try
    WebXOffice.ReadCategories(Integer(cmbWebSpace.Items.Objects[cmbWebSpace.ItemIndex]), S);
    cmbCategory.Clear;
    cmbCategory.Items := S;
    if cmbCategory.Items.Count = 0 then
      HelpfulWarningMsg('There are no Categories for the selected Secure Area.'#13#13 +
        'Please use the CCH Secure Area Manager to create a Category.' ,0)
    else
      cmbCategory.ItemIndex := -1;
  finally
    S.Free;
  end;
end;

//------------------------------------------------------------------------------
function TdlgSaveReportTo.GetPositionFromIndex(aIndex : integer) : integer;
var
  CustIndex : integer;
begin
  Result := -1;
  for CustIndex := 0 to cmbFormat.Items.Count - 1 do
  begin
    if Integer(cmbFormat.Items.Objects[CustIndex]) = aIndex then
    begin
      Result := CustIndex;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TdlgSaveReportTo.GetSelectedIndex: integer;
begin
  Result := Integer(cmbFormat.Items.Objects[cmbFormat.ItemIndex]);
end;

//------------------------------------------------------------------------------
function TdlgSaveReportTo.GetSelectedFileNameAndExt: string;
begin
  Result := GetSelectedFileName() + GetSelectedFileExt();
end;

//------------------------------------------------------------------------------
function TdlgSaveReportTo.GetSelectedFileExt: string;
var
  SelectedIndex : integer;
begin
  SelectedIndex := GetSelectedIndex();

  if SelectedIndex > rfMax then
    Result := TCustomFileFormat(fCustomFileFormats.Items[SelectedIndex-1-rfMax]).Extension
  else
    Result := RptFileFormat.Extensions[SelectedIndex];
end;

//------------------------------------------------------------------------------
function TdlgSaveReportTo.GetSelectedFileName: string;
var
  SelectedIndex : integer;
  FileLength : integer;
begin
  SelectedIndex := GetSelectedIndex();

  if SelectedIndex > rfMax then
    Result := TCustomFileFormat(fCustomFileFormats.Items[SelectedIndex-1-rfMax]).Filename
  else
  begin
    FileLength := length(ExtractFileName(fDefaultFileName)) - length(ExtractFileExt(fDefaultFileName));

    Result := LeftStr(ExtractFileName(fDefaultFileName), FileLength);
  end;
end;

end.


