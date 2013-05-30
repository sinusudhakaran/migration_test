unit ExtractDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Dialog for extracting data from banklink into main acc system
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, OvcBase, OvcEF, OvcPB, OvcPF, Buttons, ovcDate,
  DateSelectorFme, ExtCtrls,
  OsFont;

type
  TdlgExtract = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    chkNewFormat: TCheckBox;
    lblMessage: TLabel;
    lblFormat: TLabel;
    SaveDialog1: TSaveDialog;
    lblData: TLabel;
    DateSelector: TfmeDateSelector;
    pnlSaveTo: TPanel;
    Label6: TLabel;
    eTo: TEdit;
    btnToFolder: TSpeedButton;
    pnlMASLedgerCode: TPanel;
    Label3: TLabel;
    lblLedgerCodeToUse: TLabel;

    procedure btnToFolderClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);

  private
    okPressed : boolean;
    FDataFrom, FDataTo : TstDate;
    function  okToPost : boolean;
    { Private declarations }
  public
    procedure SetDateFromTo( DFrom, DTo : tSTDate );
    function Execute : boolean;
    { Public declarations }
  end;

function GetExtractParameters(var FromDate  : integer;
                              var ToDate    : integer;
                              var NewFormat : boolean;
                              var SaveTo    : string) : boolean;

//******************************************************************************
implementation

uses
   ShellUtils,
   BKHelp,
   bkXPThemes,
   GenUtils,
   globals,
   imagesfrm,
   bkDateUtils,
   SelectDate,
   bkconst,
   infomorefrm,
   baObj32,
   WarningMorefrm,
   YesNoDlg,
   errorMoreFrm,
   XPAUtils,
   MYOBAO_Utils,
   Software,
   ExUtil,
   ClDateUtils,
   StdHints,
   WinUtils, clObj32, BKDEFS, BusinessProductsExport, DesktopSuper_Utils,
   bkProduct;

{$R *.DFM}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgExtract.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnToFolder.Glyph);

   lblFormat.caption := '';
   with lblMessage do
     caption := format(caption,[SHORTAPPNAME]);

   SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgExtract.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   //Components
   eTo.Hint            :=
                       'Enter a directory path to extract the file to';
   btnToFolder.Hint    :=
                       STDHINTS.DirButtonHint;
   chkNewFormat.Hint   :=
                       'Check to extract data in the latest format|' +
                       'Check to extract data in the latest format for your accounting system';
end;

//------------------------------------------------------------------------------
procedure TdlgExtract.btnToFolderClick(Sender: TObject);
var
  Test : string;
  result : integer;
begin
  if ExtractDataFileNameRequired(MyClient.clFields.clCountry,MyClient.clFields.clAccounting_System_Used) then
  begin
    //special case for XPA
    if Software.IsXPA8Interface( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used) then
    begin
      Test := eTo.Text;
      result := GetXPALedgerPath( Test);
      if (result = bkXPA_COM_Refresh_Supported_User_Selected_Ledger) then
        eTo.Text := Test;
      if (result = bkXPA_COM_Refresh_NotSupported) then
        HelpfulErrorMsg( 'Could not access the list of ' + MyClient.clAccountingSystemName + ' ledgers. Please ensure the correct software is installed.', 0);
    end
    else
      with SaveDialog1 do
      begin
        FileName := ExtractFileName(eTo.text);
        InitialDir := ExtractFilePath(eTo.text);
        if (InitialDir = '') then
          InitialDir := DATADIR;

        if Execute then eTo.text := Filename;
      end;
  end
  else
  begin
    Test := ExtractFilePath(eTo.text);
    if BrowseFolder( test, 'Select the Folder to extract Entries to' ) then
      eTo.text := Test;
  end;

  //make sure all relative paths are relative to data dir after browse
  SysUtils.SetCurrentDir( Globals.DataDir);
end;
//------------------------------------------------------------------------------
procedure TdlgExtract.btnCancelClick(Sender: TObject);
begin
  okPressed := false;
  Close;
end;
//------------------------------------------------------------------------------
function TdlgExtract.Execute: boolean;
var
  NewFormat : boolean;
begin
   SysUtils.SetCurrentDir( Globals.DataDir);

   with MyClient.clFields do begin
     lblFormat.caption := 'The file will be saved in '+ MyClient.clAccountingSystemName + ' format.';
     NewFormat := Software.CanExtractInNewFormat(clCountry,clAccounting_System_Used);
     chkNewFormat.Visible := NewFormat;
     chkNewFormat.Checked := NewFormat;

     eTo.Text := ExUtil.DefaultFileName;

     gCodingDateFrom := clPeriod_Start_Date;
     gCodingDateTo   := clPeriod_End_Date;

     //set dates
     DateSelector.ClientObj := MyClient;
     fDataFrom := ClDateUtils.BAllData( MyClient );
     fDataTo   := ClDateUtils.EAllData( MyClient );
     DateSelector.InitDateSelect( fDataFrom, fDataTo, eTo);

     //SetDateFromTo( gCodingDateFrom, gCodingDateTo );


     if Software.IsXPA8Interface( clCountry, clAccounting_System_Used) then
     begin
       lblFormat.caption := 'Entries will be extracted in '+ MyClient.clAccountingSystemName + ' format.';
       lblMessage.Caption := '';
       label6.Caption := 'XPA Ledger';
     end;

     if Software.IsMYOBAO_DLL_Interface( clCountry, clAccounting_System_Used) then
     begin
       lblFormat.caption := 'Entries will be extracted in '+ Software.GetMYOBAO_Name( clCountry) + ' format.';
       lblMessage.Caption := '';
       label6.Caption := 'Ledger Path';
     end;

     if not Software.UseSaveToField( clCountry, clAccounting_System_Used) then
     begin
       pnlSaveTo.Visible := false;
       Self.Height := Self.Height - pnlSaveTo.Height;
       DateSelector.NextControl := btnOK;
     end;

     if Software.IsSol6_COM_Interface( clCountry, clAccounting_System_Used) then
     begin
       pnlMASLedgerCode.Visible := true;
       if clUse_Alterate_ID_for_extract then
          lblLedgerCodeToUse.Caption := clAlternate_Extract_ID
       else
          lblLedgerCodeToUse.Caption := clCode;
     end;
   end;

   lblData.caption := 'There are exportable transactions from: '+bkDate2Str(fDataFrom)+ ' to '+bkDate2Str(fDataTo);

   ShowModal;
   result := okPressed;
end;
//------------------------------------------------------------------------------
procedure TdlgExtract.FormShow(Sender: TObject);
begin
//
end;
//------------------------------------------------------------------------------
// Sets the value of the Date Edit Boxes to the Popup selected values
procedure TdlgExtract.SetDateFromTo( DFrom, DTo : tSTDate );
begin
  DateSelector.eDateFrom.AsStDate := BKNull2St( DFrom );
  DateSelector.eDateTo.AsStDate   := BKNull2St( DTo );
end;
//------------------------------------------------------------------------------
procedure TdlgExtract.btnOkClick(Sender: TObject);
begin
  if okToPost then
  begin
    okPressed := true;
    Close;
  end;
end;
//------------------------------------------------------------------------------
function TdlgExtract.okToPost: boolean;
var
  HasEntries, HasNonTransferedEntries : boolean;
  TempBank : tBank_Account;
  i,j : integer;

  FromDate, ToDate : integer;
  DirPath : string;
  extn : string;
begin
  Result := false;

  if (not DateSelector.ValidateDates) then
    Exit;

  if (DateSelector.eDateFrom.AsStDate > DateSelector.eDateTo.AsStDate) then begin
    HelpfulInfoMsg('"From" Date is later than "To" Date.  Please select valid dates.',0);
    Exit;
  end;

  {---------- check for transferable entries ----------}

  with MyClient do begin
    HasEntries := false;
    HasNonTransferedEntries := false;

    FromDate := StNull2BK( DateSelector.eDateFrom.AsStDate );
    ToDate   := StNull2BK( DateSelector.eDateTo.AsStDate );

    for i := 0 to Pred(clBank_Account_List.ItemCount) do begin
      TempBank := clBank_Account_List.Bank_Account_At(i);
      with TempBank.baTransaction_List do begin
        for j := 0 to Pred(ItemCount)do begin
          with Transaction_At(j)^ do begin
            if (txdate_effective >= FromDate) and (txDate_Effective <= ToDate) then begin
              HasEntries := true;
              if txDate_Transferred = 0 then begin
                HasNonTransferedEntries := true;
                Break;
              end;
            end;
          end;
        end;
      end;
      if HasNonTransferedEntries then break;
    end;

    // Bail out if there is nothing to do -------------------------------------

    if not HasEntries then begin
      HelpfulWarningMsg('There are no Entries for this client in the current date range, '+bkDate2Str(fromDate)+' to '+bkDate2Str(toDate)+'.',0);
      Exit;
    end;

    // Bail out if there is nothing to do -------------------------------------

    if not HasNonTransferedEntries then begin
      HelpfulWarningMsg('All the Entries for this client in the current date range, '+bkDate2Str(fromDate)+' to '+bkDate2Str(toDate)+', have been transferred.  '
                         +'There are no new entries to transfer.',0);
      Exit;
    end;
  end; {with myclient}

  if Software.UseSaveToField( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used) then
  begin
    with MyClient.clFields do
    begin
      //get rid of any spaces in extract dir field
      eTo.Text := Trim( eTo.Text);

      //add \ if expecting a path
      if not Software.ExtractDataFileNameRequired( clCountry, clAccounting_System_Used ) then
        eTo.Text := GenUtils.AddSlash( eTo.Text);

      //check extract to field is valid
      if Software.ExtractDataFileNameRequired( clCountry, clAccounting_System_Used ) then
      begin
        // Check that we have a file name
        if ( ExtractFileName( eTo.Text ) = '' ) then
        begin
          HelpfulWarningMsg('You must specify a file name for the extracted entries.',0);
          exit;
        end;

        // check that not trying to save to a file which has the same name as a directory
        DirPath := AddSlash(eTo.Text);
        if DirectoryExists( DirPath ) then
        begin
          HelpfulWarningMsg('You can''t use this name because a directory called '+DirPath+' already exists.', 0);
          exit;
        end;

        if ExtractFileExt( eTo.Text ) = '.BK5' then
        Begin
          HelpfulWarningMsg('You can''t use this name because the .BK5 extension is used by ' + TProduct.BrandName, 0 );
          exit;
        end;

        // do not allow overwrite of Authority PDFs
        if (Lowercase(ExtractFileName( eTo.Text )) = Lowercase(TPA_FILENAME)) or
           (Lowercase(ExtractFileName( eTo.Text )) = Lowercase(CAF_FILENAME)) then
        begin
           HelpfulWarningMsg('You can''t use this file name because it is reserved for use by '+ShortAppName, 0 );
           exit;
        end;

        if Software.IsPA7Interface( clCountry, clAccounting_System_Used ) then
        begin
          //special check to see if trying to use .XPA or .MDB as file extention
          //if the user is unlucky they could change from xpa8 back to xpa7 and
          //inadvertedly delete the ledger file
          extn := Uppercase( ExtractFileExt( eTo.Text ));
          if ( extn = '.XPA') or ( extn = '.MDB') then
          Begin
            HelpfulWarningMsg('You can''t use this name because the ' + extn + ' extension is used for PA ledger files', 0 );
            exit;
          end;
        end;

        //check that the path in front of the file exists
        DirPath := ExtractFilePath( eTo.Text );
      end
      else
      begin
        //only expecting a path, add a delimiter to the end of existing string
        DirPath := AddSlash( eTo.Text);
      end;
   end;

   // ----------- Verify the file name  and  Directory -------------------------
   if (DirPath = '') then
   begin
     DirPath := DATADIR;
   end;

   if not DirectoryExists(DirPath) then
   begin
      if AskYesNo('Create Directory',
                  'The folder '+DirPath +' does not exist. Do you want to Create it?',
                   DLG_YES,0) <> DLG_YES then begin
         Exit;
      end;

      if not CreateDir(DirPath) then
      begin
         HelpfulErrorMsg('Cannot Create Extract Data Directory '+DirPath,0);
         Exit;
      end;
   end;

   // ----------- Does the file exist already? ---------------------------------
   if Software.ExtractDataFileNameRequired( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then
   begin
     //special case
     //if the accounting system is XPA8 then the COM interface will be used,  the
     //ledger file name will be contained in the To path
     if Software.IsXPA8Interface(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then
     begin
       //Don't worry about checking for the existence of the file, a call to
       //an illegal file will result in the select ledger window appearing
     end
     else
     begin
       //Standard file based extract
       if ( eTo.Text <> '') and BKFileExists(eTo.Text) then
       begin
         if AskYesNo('Overwrite File','The file '+ExtractFileName(eTo.Text)+' already exists. Overwrite?',dlg_yes,0) <> DLG_YES then
           exit;
       end;
     end;
   end
    else if (MyClient.clFields.clCountry = whNewZealand) and (MyClient.clFields.clAccounting_System_Used in [snQIF]) or
            (MyClient.clFields.clCountry = whAustralia) and (MyClient.clFields.clAccounting_System_Used in [saQIF]) then
    begin // check if this folder contains QIF extracts for this client
      if QIFFilesExist(DirPath, DateSelector.eDateTo.AsStDate) then
      begin
        if AskYesNo('Overwrite File','The folder ' + DirPath + ' already contains extracted QIF files for this client and period. Overwrite?',dlg_yes,0) <> DLG_YES then
          exit;
      end;
    end;
  end;

  //at this point there are entries to transfer, a filename, and a valid directory
  Result := true;
end;
//------------------------------------------------------------------------------
function GetExtractParameters(var FromDate  : integer;
                              var ToDate    : integer;
                              var NewFormat : boolean;
                              var SaveTo    : string) : boolean;
var
  Extract : TdlgExtract;
begin
  Result := false;

  NewFormat := false;
  SaveTo    := '';

  Extract := TdlgExtract.Create(Application.MainForm);
  with Extract do begin
    try

      BKHelpSetUp(Extract, BKH_Extract_data);
      if (Fromdate <> 0) then begin
         SetDateFromTo(Fromdate,ToDate);
      end else with MyClient.clFields do begin

         gCodingDateFrom := clPeriod_Start_Date;
         gCodingDateTo   := clPeriod_End_Date;
         SetDateFromTo( gCodingDateFrom, gCodingDateTo );
      end;

      if Execute then begin
        FromDate  := StNull2BK( DateSelector.eDateFrom.AsStDate );
        ToDate    := StNull2BK( DateSelector.eDateTo.AsStDate );
        NewFormat := chkNewFormat.Checked;
        SaveTo    := eTo.text;
        Result := true;
      end;
    finally
      Free;
    end;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgExtract.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  case Msg.CharCode of
    109: begin
           DateSelector.btnPrev.Click;
           Handled := true;
         end;
    107: begin
           DateSelector.btnNext.click;
           Handled := true;
         end;
    VK_MULTIPLY : begin
           DateSelector.btnQuik.click;
           handled := true;
         end;
  end;
end;


end.
