unit ExportToECodingdlg;
//------------------------------------------------------------------------------
{
   Title:       Export to Ecoding file dialog

   Description:

   Remarks:     Collects options required for exporting ecoding file.

   Author:      Matthew Hopkins  Aug 2001

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, OvcBase, Menus, OvcEF, OvcPB, OvcPF, Buttons,
  DateSelectorFme, clObj32, ECodingExportFme, WinUtils, BAobj32,
  AccountSelectorFme, ComCtrls,
  OSFont;

type
  TdlgExportToECoding = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    pcMain: TPageControl;
    tsAdvanced: TTabSheet;
    tsOptions: TTabSheet;
    SaveDialog1: TSaveDialog;
    fmeAccountSelector1: TfmeAccountSelector;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    ecDateSelector: TfmeDateSelector;
    lblData: TLabel;
    GbFilename: TGroupBox;
    Label6: TLabel;
    btnToFolder: TSpeedButton;
    eTo: TEdit;
    ecExportOptions: TfmeECodingExport;
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnToFolderClick(Sender: TObject);
    procedure eToChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
    ForClient : TClientObj;
    ExportDest : Byte;
    FExportDestination: Byte;
    procedure SetExportDestination(Value: Byte);
  public
    { Public declarations }
    property ExportDestination: Byte read FExportDestination write SetExportDestination;
  end;

  function GetECodingExportOptions( var aClient : TClientObj; Destination : byte;
                                    var DateFrom : integer; var DateTo : integer;
                                    var ToFilename : string; var AccountList: TList) : boolean;


//******************************************************************************
implementation

{$R *.DFM}

uses
   ComboUtils,
   bkXPThemes,
   stDate,
   glConst,
   GlobalDirectories,
   bkDateUtils,
   clDateUtils,
   bkConst,
   imagesfrm,
   warningMorefrm,
   errorMorefrm,
   GenUtils,
   YesNoDlg,
   Globals,
   Software,
   bkhelp,
   BKDEFS,
   CountryUtils,
   WebXOffice,
   TransactionUtils, bkProduct, bkBranding;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgExportToECoding.btnCancelClick(Sender: TObject);
begin
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgExportToECoding.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);

   ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnToFolder.Glyph);

   ExportDestination := ecDestFile;
   ecExportOptions.ShowSuperFields(Software.CanUseSuperFundFields(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used)  );
   pcMain.ActivePage := tsOptions;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetECodingExportOptions( var aClient : TClientObj; Destination : byte;
                                  var DateFrom : integer; var DateTo : integer;
                                  var ToFilename : string; var AccountList: TList) : boolean;
var
   i : integer;
   FirstExportableTrans : integer;
   LastExportableTrans  : integer;
  
   p: Pointer;
   Ldlg: TDlgExportToECoding;
begin
   result := false;
   Ldlg := TDlgExportToECoding.Create(Application.MainForm);
      try
         Ldlg.ForClient := aClient;
         ldlg.ecExportOptions.SetupDialog;
         Ldlg.ecExportOptions.ShowSuperFields(
            Software.CanUseSuperFundFields(aClient.clFields.clCountry,aClient.clFields.clAccounting_System_Used));
         Ldlg.ExportDestination := Destination;


         With Ldlg.ecExportOptions.chkShowGST do
            Caption := Localise( aClient.clFields.clCountry, Caption );

         FirstExportableTrans := ClDateUtils.BBankData( aClient);
         LastExportableTrans  := ClDateUtils.EBankData( aClient);

         with Ldlg.EcDateSelector do begin
            //set client
            ClientObj := aClient;
            //set date bounds to first and last trx date
            InitDateSelect( FirstExportableTrans,
                            LastExportableTrans,
                            Ldlg.ecExportOptions.cmbInclude);
            eDateFrom.asStDate := -1;
            eDateTo.asStDate   := -1;
            btnQuik.Visible := true;
         end;

         Ldlg.ExportDest := Destination;
         //set client specific values
         Ldlg.EcDateSelector.eDateFrom.AsStDate := BkNull2St(aClient.clFields.clPeriod_Start_Date);
         Ldlg.EcDateSelector.eDateTo.AsStDate   := BkNull2St(aClient.clFields.clPeriod_End_Date);

         Ldlg.lblData.caption := 'There are exportable transactions ' +
                            'from ' +  bkDate2Str( FirstExportableTrans) +
                            ' to '   + bkDate2Str( LastExportableTrans);

         with Ldlg.ecExportOptions do
         begin


           SetOptions(aClient);
           //set the enabled and check state of the boxes on the form

           Ldlg.EcExportOptions.UpdateControlsOnForm;
         end;

         Ldlg.eTo.Text := ToFilename;

//*******************************************
         if Ldlg.ShowModal = mrOK then begin
//********************************************

            AccountList.Clear;
            //add selected bank accounts to a tlist for use by export
            for i := 0 to Ldlg.fmeAccountSelector1.AccountCheckBox.Count-1 do
               if Ldlg.fmeAccountSelector1.AccountCheckBox.Checked[i] then begin
                  p := Ldlg.fmeAccountSelector1.AccountCheckBox.Items.Objects[i];
                  AccountList.Add( pointer(aClient.clBank_Account_List.Indexof(p)));
               end;

            DateFrom := Ldlg.ecDateSelector.eDateFrom.AsStDate;
            DateTo   := Ldlg.ecDateSelector.eDateTo.AsStDate;
            ToFilename := Ldlg.eTo.Text;

            Ldlg.EcExportOptions.GetOptions( aClient);

            Result := true;
         end;
   finally
      Ldlg.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgExportToECoding.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  HasEntries : boolean;
  TempBank : tBank_Account;
  i,j : integer;

  FromDate, ToDate : integer;
  DirPath : string;
  Selection : integer;
  IsSelected: Boolean;

  procedure FixFilename;
  begin
     case ExportDestination of
     ecDestWebX : if {ComboUtils.GetComboCurrentIntObject(ecExportOptions.cmbWebFormats, 0)}
                    ForClient.clFields.clWeb_Export_Format = wfWebX then begin
           // Acclipse MUST always export to the Acclipse folder
           if (Trim(eTo.Text) <> '') then
              eTo.Text := WebXOffice.GetWebXDataPath(WEBX_EXPORT_FOLDER) + ExtractFilename(eTo.Text);
        end;
         //if the destination is email than remove any path info
      ecDestEmail : eTo.Text := ExtractFilename( ETo.Text);
     end;
  end;

  function FailFilename : Boolean;
  begin
     Result := True;
     case ExportDestination of
     ecDestWebX: case {ComboUtils.GetComboCurrentIntObject(ecExportOptions.cmbWebFormats, 0)}
                  ForClient.clFields.clWeb_Export_Format of
           wfWebNotes : begin
               Result := False; // Dont Need one Cannot fail...
               Exit;
           end;

     end;
     end;

     if ( ExtractFileName( eTo.Text ) = '' ) then begin
         if ExportDestination = ecDestWebX then
          HelpfulWarningMsg('You must specify a file name for the ' + glConst.WEBX_GENERIC_APP_NAME + ' file.',0)
        else
         HelpfulWarningMsg('You must specify a file name for the ' + bkBranding.NotesProductName + ' file.',0);
        exit;
     end;
      //append default extention if one not specified
      if ExtractFileExt( eTo.Text) = '' then
      begin
        if ExportDestination = ecDestWebX then
          eTo.Text := ChangeFileExt( eTo.Text, '.' + glConst.WEBX_DEFAULT_EXTN)
        else
          eTo.Text := ChangeFileExt( eTo.Text, '.' + glConst.ECODING_DEFAULT_EXTN);
      end;

      // check that not trying to save to a file which has the same name as a directory
      DirPath := AddSlash(eTo.Text);
      if DirectoryExists( DirPath ) then begin
         HelpfulWarningMsg('You cannot use this name because a directory called '+DirPath+' already exists.', 0);
         exit;
      end;
      // check not trying to call bk5
      if Uppercase( ExtractFileExt( eTo.Text )) = '.BK5' then begin
         HelpfulWarningMsg('You cannot use this name because the .BK5 extension is used by ' + TProduct.BrandName, 0 );
         exit;
      end;

      // ----------- Verify the file name -----------------------------------------
      DirPath := ExtractFilePath( eTo.Text );
      if ( DirPath <> '') then begin
         if not DirectoryExists(DirPath) then begin
            if AskYesNo('Create Directory',
                        'The folder '+DirPath +' does not exist. Do you want to Create it?',
                         DLG_YES,0) <> DLG_YES then begin
               Exit;
            end;

            try
               ForceDirectories(DirPath);
            except
               on e : Exception do ;
            end;

            if not DirectoryExists(DirPath) then begin
               HelpfulErrorMsg('Cannot Create Extract Data Directory '+DirPath,0);
               Exit;
            end;
         end;
      end;
      // ----------- Does the file exist already? ---------------------------------
      if BKFileExists(eTo.Text) then begin
         if AskYesNo('Overwrite File','The file '+ExtractFileName(eTo.Text)+' already exists. Overwrite?',dlg_yes,0) <> DLG_YES
         then exit;
      end;

     // Still Here.. Must be OK..
     Result := False;
  end;

begin
   if ModalResult = mrOK then begin
       CanClose := false; //assume failure

       FixFilename;

      //verify fields
      if (ecDateSelector.eDateFrom.AsStDate > ecDateSelector.eDateTo.AsStDate) then begin
         HelpfulWarningMsg('"From" Date is later than "To" Date.  Please select valid dates.',0);
         Exit;
      end;

      if (not ecDateSelector.ValidateDates) then
        Exit;

      if (( ecDateSelector.eDateFrom.AsStDate < glConst.MinValidDate) or
          ( ecDateSelector.eDateTo.AsStDate > glConst.MaxValidDate)) then begin
         HelpfulWarningMsg( 'You must select a valid date range.', 0);
         exit;
      end;

      //check if any accounts have been selected
      IsSelected := False;
      with fmeAccountSelector1 do
      begin
        i := 0;
        while (i < AccountCheckBox.Items.Count) and (not IsSelected) do
        begin
          if (AccountCheckBox.Checked[i]) then
            IsSelected := True;
          Inc(i);
        end;
        if (not IsSelected) then
        begin
          HelpfulWarningMsg('No accounts have been selected.',0);
          Exit;
        end;
      end;

      //see if should correct dates
      FromDate  := StNull2BK( ecDateSelector.eDateFrom.AsStDate );
      ToDate    := StNull2BK( ecDateSelector.eDateTo.AsStDate );
      Selection := ecExportOptions.cmbInclude.ItemIndex;

      (*
      //from date not 1st of mth
      if FromDate <> 0 then begin
         stDateToDMY(FromDate,d,m,y);
         if (d <> 1) then
            if AskYesNo('Please Confirm Dates','The "From" date you entered (' + bkDate2Str( FromDate)+ ') is not the'
                          +' first day of the month.  Would you like '+SHORTAPPNAME+' to correct it for you?',DLG_YES,0)
                           = DLG_YES then
            FromDate := DMYtoStDate(1,m,y,BKDATEEPOCH);
      end;

      if ToDate <> MaxInt then begin
         {to date not last of mth}
         if (not IsTheLastDayOfTheMonth(ToDate)) then
            if AskYesNo('Please Confirm Dates','The "To" date you entered (' + bkDate2Str( ToDate)+ ') is not the'
                          +' last day of the month.  Would you like '+SHORTAPPNAME+' to correct it for you?',DLG_YES,0)
                           = DLG_YES then
            begin
              stDateToDMY( ToDate,d,m,y);
              ToDate := DMYtoSTDate(DaysInMonth(m,y,BKDATEEPOCH),m,y, BKDATEEPOCH);
            end;
      end;
      *)

      //check for entries
      // in date range, not transferred, not finalised
      with ForClient do begin
        HasEntries := false;
{        HasLocked  := false;
        HasTransferred := false;}

        for i := 0 to Pred(fmeAccountSelector1.AccountCheckBox.Items.Count) do begin
           if not fmeAccountSelector1.AccountCheckBox.Checked[i] then Continue;
           TempBank := tBank_Account(fmeAccountSelector1.AccountCheckBox.Items.Objects[i]);
           if TempBank.baFields.baAccount_Type in [ btBank] then begin
              with TempBank.baTransaction_List do begin
                 for j := 0 to Pred(ItemCount)do begin
                    with Transaction_At(j)^ do begin
                       if (txdate_effective >= FromDate) and
                          (txDate_Effective <= ToDate) and
                          (txDate_Transferred = 0) and
                          (not txLocked) and
                          (( Selection = esAllEntries) or
                           (( Selection = esUncodedOnly) and not IsFullyCodedTransaction(ForClient, Transaction_At(j))))
                       then begin
                          HasEntries := true;
                          Break;
                       end;

{                       if txLocked then HasLocked := true;
                       if txDate_Transferred <> 0 then HasTransferred := true;}
                   end;
                 end;
              end;  //with trans list
           end; //is a bank account
           if HasEntries then break;
        end;

        // Bail out if there is nothing to do -------------------------------------
        if not HasEntries then begin
          HelpfulWarningMsg('There are no entries that can be exported in the current date range, '+bkDate2Str(fromDate)+' to '+bkDate2Str(toDate)+'.',0);
          Exit;
        end;
      end; {with aclient}

      if FailFileName then
         Exit;



      CanClose := true;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgExportToECoding.btnOkClick(Sender: TObject);
begin
  if (FExportDestination <> ecDestWebX)
  and (not (ecExportOptions.edtPassword.Text = ecExportOptions.edtConfirm.Text)) then
  begin
    HelpfulWarningMsg('The passwords you have entered do not match. Please re-enter them.', 0);
    ecExportOptions.edtPassword.SetFocus;
  end
  else
    ModalResult := mrOk;
end;

procedure TdlgExportToECoding.btnToFolderClick(Sender: TObject);
begin
    with SaveDialog1 do begin
      FileName := ExtractFileName(eTo.text);
      InitialDir := ExtractFilePath(eTo.text);
      if Execute then
        eTo.text := Filename;
    end;
    //make sure all relative paths are relative to data dir after browse
    SysUtils.SetCurrentDir( GlobalDirectories.glDataDir);
end;



procedure TdlgExportToECoding.eToChange(Sender: TObject);
begin
   eTo.Hint := eTo.Text;
end;

procedure TdlgExportToECoding.FormShow(Sender: TObject);
begin
  if FExportDestination = ecDestWebX then
     case ForClient.clFields.clWeb_Export_Format of
        wfWebX:  BKHelpSetUp( Self, BKH_Exporting_transactions_from_BankLink_to_CCH_WebPractice);
        wfWebNotes:  BKHelpSetUp( Self, BKH_Creating_a_BankLink_Notes_Online_file_for_a_client_to_access);
     end
  else
     BKHelpSetUp( Self, BKH_Creating_a_transaction_file_to_send_to_a_client);

  //load lists - dont do this in create as per other dialogs, because ForClient isnt set til later on
  fmeAccountSelector1.LoadAccounts( ForClient, BKCONST.SchedRepSet);
  fmeAccountSelector1.btnSelectAllAccounts.Click;
end;

// Set up UI as required
procedure TdlgExportToECoding.SetExportDestination(Value: Byte);

begin
  if Value = ecDestWebX then
  begin
    if ForClient.clFields.clWeb_Export_Format = 255 then
       ForClient.clFields.clWeb_Export_Format := wfDefault;

    case ForClient.clFields.clWeb_Export_Format  of
      wfWebX : Self.Caption := 'Export ' + wfNames[wfWebX] + ' File';
      wfWebNotes : Self.Caption := 'Export to ' + wfNames[wfWebNotes];
    end;
    

    if ForClient.clFields.clWeb_Export_Format = wfWebNotes then begin
       GBFilename.Visible := False;
       pcMain.Height := pcMain.Height  - GBFilename.Height;
       self.Height := self.Height -  GBFilename.Height;
    end;

    SaveDialog1.Filter := glConst.WEBX_GENERIC_APP_NAME + ' file (*.' +
                          glConst.WEBX_DEFAULT_EXTN + ')|*.' +
                          glConst.WEBX_DEFAULT_EXTN + '|' +
                          'All files (*.*)|*.*';
    SaveDialog1.DefaultExt := glConst.WEBX_DEFAULT_EXTN;

  end
  else
  begin
    Self.Caption := 'Export ' + bkBranding.NotesProductName + ' Entries ';
    case Value of
      ecDestFile:
        Caption := Caption + 'to file';
      ecDestEmail:
        Caption := Caption + 'via email';
    end;

    SaveDialog1.Filter := bkBranding.NotesProductName + ' file (*.' +
                          glConst.ECODING_DEFAULT_EXTN + ')|*.' +
                          glConst.ECODING_DEFAULT_EXTN + '|' +
                          'All files (*.*)|*.*';
    SaveDialog1.DefaultExt := glConst.ECODING_DEFAULT_EXTN;
  end;
  FExportDestination := Value;
  ecExportOptions.ExportDestination := FExportDestination;

end;

procedure TdlgExportToECoding.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  case Msg.CharCode of
    109: begin
           ecDateSelector.btnPrev.Click;
           Handled := true;
         end;
    107: begin
           ecDateSelector.btnNext.click;
           Handled := true;
         end;
    VK_MULTIPLY : begin
           ecDateSelector.btnQuik.click;
           handled := true;
         end;
  end;
end;

end.
