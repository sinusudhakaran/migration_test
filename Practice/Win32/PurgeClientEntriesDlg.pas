unit PurgeClientEntriesDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   Purge Client Entries

  Written:  Nov 1999
  Authors:  Matthew

  Purpose:  Allow entries to be deleted from a client file once they have reached
            a specifed age.

  Notes:   Any Coding Screens will have been closed prior to loading this dialog

           A minimum of 24 mths data ( 12 mths before Financial year start date ) must
           be kept.

           The process is simple.  If the transaction has an effective date prior to
           the X mths before the Financial Year Start date, it will be deleted.

           When comparing dates the Effective Date will be used!
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OvcBase, OvcEF, OvcPB, OvcNF, OvcSC, ComCtrls, ExtCtrls, ovcpf,
  CheckLst, Buttons, AccountSelectorFme, Mask, RzEdit,
  OSFont;

type
  TdlgPurgeClientEntries = class(TForm)
    chkTransOnly: TCheckBox;
    nfMths: TOvcNumericField;
    OvcController1: TOvcController;
    OvcSpinner1: TOvcSpinner;
    lblEntries: TLabel;
    lblPurgeDate: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label1: TLabel;
    rbMonths: TRadioButton;
    rbDate: TRadioButton;
    fmeAccountSelector1: TfmeAccountSelector;
    Bevel4: TBevel;
    eDateFrom: TRzDateTimeEdit;
    Label2: TLabel;
    Label3: TLabel;
    pnlControls: TPanel;
    btnPurge: TButton;
    btnCancel: TButton;
    Shape1: TShape;

    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure nfMthsChange(Sender: TObject);
    procedure nfMthsKeyPress(Sender: TObject; var Key: Char);
    procedure chkTransOnlyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rbMonthsClick(Sender: TObject);
    procedure fmeAccountSelector1btnClearAllAccountsClick(Sender: TObject);
    procedure fmeAccountSelector1btnSelectAllAccountsClick(Sender: TObject);
  private
    { Private declarations }
    procedure GetBAList(L: TStringList);
  public
    { Public declarations }
  end;

procedure DoPurgeClientEntries;

//******************************************************************************
implementation

uses
  bkDateUtils,
  bkDefs,
  BKHelp,
  bkXPThemes,
  Globals,
  stDate,
  ErrorMoreFrm,
  InfoMoreFrm,
  YesNoDlg,
  ClDateUtils,
  trxList32,
  LogUtil, ImagesFrm, ClientUtils, baObj32, bkConst, WarningMoreFrm;
{$R *.DFM}

const
   MinMthsAllowed = 12;
   MaxMthsAllowed = 120;

const
   UnitName = 'PurgeClientEntriesDlg';
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgPurgeClientEntries.fmeAccountSelector1btnClearAllAccountsClick(
  Sender: TObject);
begin
  fmeAccountSelector1.btnClearAllAccountsClick(Sender);
  nfMthsChange(Self);
end;

procedure TdlgPurgeClientEntries.fmeAccountSelector1btnSelectAllAccountsClick(
  Sender: TObject);
begin
  fmeAccountSelector1.btnSelectAllAccountsClick(Sender);
  nfMthsChange(Self);
end;

procedure TdlgPurgeClientEntries.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
   PurgeDate : integer;
   ValidEntries : integer;
   sMsg      : string;
   R: Boolean;
   I: Integer;
   L: TStringList;
begin
   if ModalResult = mrOK then begin
      R := False;
      //check if any accounts have been selected
      with fmeAccountSelector1 do
        for I := 0 to AccountCheckBox.Items.Count - 1 do
          if (AccountCheckBox.Checked[i]) then begin
              R := True;
              break;
          end;

      if (not R) then begin
         HelpfulWarningMsg('No accounts have been selected.',0);
         fmeAccountSelector1.chkAccounts.SetFocus;
         CanClose := false;
         exit;
      end;

      if rbMonths.Checked then
      begin
        if nfMths.AsInteger < MinMthsAllowed then begin
           HelpfulErrorMsg( 'Entries must be held for a minimum of '+inttostr(MinMthsAllowed)+ ' months prior to the '+
                            'Financial Year Start Date '+
                            'to allow '+ShortAppName+ ' to report on last years figures. Please select another value.',0);
           CanClose := false;
           nfMths.AsInteger := MinMthsAllowed;
           nfMths.SetFocus;
           exit;
        end;
        PurgeDate := IncDate( MyClient.clFields.clFinancial_Year_Starts, 0, - nfMths.AsInteger, 0);
        if (PurgeDate < MinValidDate) or (PurgeDate > MaxValidDate) then
        begin
           HelpfulErrorMsg( 'The number of months you have entered is too big. The valid months range is from 12 to ' +
             IntToStr(GetMonthsBetween(MyClient.clFields.clFinancial_Year_Starts, MinValidDate)) + '.',0);
           CanClose := false;
           nfMths.AsInteger := MinMthsAllowed;
           nfMths.SetFocus;
           exit;
        end;
      end
      else // by date
      begin
        if eDateFrom.Text = '' then
        begin
           HelpfulErrorMsg( 'Please choose a valid date prior to which entries will be purged.',0);
           CanClose := false;
           eDateFrom.Date := StDateToDateTime(IncDate( MyClient.clFields.clFinancial_Year_Starts, 0, -MinMthsAllowed, 0));
           eDateFrom.SetFocus;
           exit;
        end;
        PurgeDate := DateTimeToStDate(eDateFrom.Date);
        if (PurgeDate < MinValidDate) or (PurgeDate > MaxValidDate) then
        begin
           HelpfulErrorMsg( 'You have entered an invalid date. The valid date range is from 01/01/1980 to 31/12/2040.',0);
           CanClose := false;
           eDateFrom.Date := StDateToDateTime(IncDate( MyClient.clFields.clFinancial_Year_Starts, 0, -MinMthsAllowed, 0));
           eDateFrom.SetFocus;
           exit;
        end;
        if PurgeDate > IncDate(MyClient.clFields.clFinancial_Year_Starts, 0, -MinMthsAllowed, 0) then
        begin
           HelpfulErrorMsg( 'Entries must be held for a minimum of '+inttostr(MinMthsAllowed)+ ' months prior to the '+
                            'Financial Year Start Date '+
                            'to allow '+ShortAppName+ ' to report on last years figures. Please select another value.',0);
           CanClose := false;
           eDateFrom.Date := StDateToDateTime(IncDate( MyClient.clFields.clFinancial_Year_Starts, 0, -MinMthsAllowed, 0));
           eDateFrom.SetFocus;
           exit;
        end;
      end;
      //See if anything there to delete
      L := TStringList.Create;
      try
        GetBAList(L);
        ValidEntries := CountEntriesToPurge ( PurgeDate, chkTransOnly.Checked, L);
      finally
        L.Free;
      end;
      if ( ValidEntries = 0) then begin
         HelpfulInfoMsg('There are no entries prior to the selected purge date of '+bkDate2Str( PurgeDate )+' to be deleted.',0);
         CanClose := false;
         exit;
      end;
      //confirm action with user
      sMsg := 'All Entries prior to '+ bkDate2Str( PurgeDate ) + ' will be deleted from this Client File. '+#13+
              'Are you sure you want to do this?';

      if AskYesNo( 'Purge Entries', sMsg, dlg_No, 0) <> dlg_Yes then begin
         CanClose := false;
         if rbMonths.Checked then
           nfMths.SetFocus
         else
           eDateFrom.SetFocus;
         exit;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPurgeClientEntries.nfMthsChange(Sender: TObject);
var
   PurgeDate : integer;
   EntriesBefore : integer;
   sMsg      : string;
   L: TStringList;
begin
   if nfMths.AsInteger < 0 then
    nfMths.AsInteger := 0;
   if ((nfMths.AsInteger > 0) and (rbMonths.Checked)) or
      ((eDateFrom.Date <> 0) and (rbDate.Checked)) then begin
      sMsg := 'This will purge Entries before %s (%d entries)';
      if rbMonths.Checked then
        PurgeDate := IncDate( MyClient.clFields.clFinancial_Year_Starts, 0, - nfMths.AsInteger, 0)
      else
        PurgeDate := DateTimeToStDate(eDateFrom.Date);
      L := TStringList.Create;
      try
        GetBAList(L);
        EntriesBefore := CountEntriesToPurge ( PurgeDate, chkTransOnly.Checked, L);
      finally
        L.Free;
      end;
      lblPurgeDate.caption := Format( sMsg, [BkDate2Str(PurgeDate), EntriesBefore]);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPurgeClientEntries.nfMthsKeyPress(Sender: TObject; var Key: Char);
begin
   if (Key = '+') then begin
      nfMths.AsInteger := nfMths.AsInteger +1;
      Key := #0;
   end;

   if (Key = '-') and (nfMths.AsInteger > 0) then begin
      nfMths.AsInteger := nfMths.AsInteger -1;
      Key := #0;
   end;
end;
procedure TdlgPurgeClientEntries.rbMonthsClick(Sender: TObject);
begin
  nfMths.Enabled := rbMonths.Checked;
  OvcSpinner1.Enabled := rbMonths.Checked;
  eDateFrom.Enabled := rbDate.Checked;
  nfMthsChange(Self);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoPurgeClientEntries;
var
  PurgeClientEntries: TdlgPurgeClientEntries;
  PurgeDate: integer;
  TotalDeleted: integer;
  TotalUnpresented: integer;
  sMsg: string;
  L: TStringList;
begin
  PurgeClientEntries := TdlgPurgeClientEntries.Create(Application.MainForm);
  with PurgeClientEntries do
  begin
    try
      BKHelpSetUp(PurgeClientEntries, BKH_Purging_entries);
      //Set defaults
      nfMths.AsInteger := MinMthsAllowed;
      rbMonthsClick(nil);
      eDateFrom.Date := StDateToDateTime(IncDate( MyClient.clFields.clFinancial_Year_Starts, 0, -MinMthsAllowed, 0));
      //Force lblPurgeDate caption to be updated
      lblEntries.caption := Format ( lblEntries.caption , [bkDate2Str( BAllData(MyClient))]);
      // Fill account box and select them all
      fmeAccountSelector1.LoadAccounts( MyClient, BKCONST.TransferringJournalsSet + NonTransferringJournalsSet);
      fmeAccountSelector1.btnSelectAllAccounts.Click;
      nfMthsChange( nil );
      //Show dialog modally
      ShowModal;
      //Delete Entries if ok pressed and validated
      if ModalResult = mrOK then
      begin
        if rbMonths.Checked then
          PurgeDate := IncDate( MyClient.clFields.clFinancial_Year_Starts, 0, - nfMths.AsInteger, 0)
        else
          PurgeDate := DateTimeToStDate(eDateFrom.Date);
        L := TStringList.Create;
        try
          GetBAList(L);
          PurgeEntriesFromMyClient( PurgeDate, chkTransOnly.checked, TotalDeleted, TotalUnpresented, L );
        finally
          L.Free;
        end;
        //Report back to user what happened, log details
        if (TotalDeleted > 0) then begin
          sMsg := Format('%s purged %d entries with a presentation date prior to %s',
                         [ShortAppName, TotalDeleted, BkDate2Str(PurgeDate)]);
          if (TotalUnpresented > 0) then
            if (TotalUnpresented = 1) then
              sMsg := Format('%s%s%d unpresented item remains',[sMsg, #13#13, TotalUnpresented])
            else
              sMsg := Format('%s%s%d unpresented items remain',[sMsg, #13#13, TotalUnpresented]);
          HelpfulInfoMsg(sMsg,0);
        end
        else begin
          HelpfulInfoMsg(ShortAppName + ' did not find any valid Entries to Purge.',0);
        end;
      end;
    finally
      Free;
    end;
 end;
end;

procedure TdlgPurgeClientEntries.chkTransOnlyClick(Sender: TObject);
begin
   nfMthsChange( Sender);
end;

procedure TdlgPurgeClientEntries.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
end;

procedure TdlgPurgeClientEntries.GetBAList(L: TStringList);
var
  i: Integer;
begin
  with fmeAccountSelector1 do
    for I := 0 to AccountCheckBox.Items.Count - 1 do
      if (AccountCheckBox.Checked[i]) then
          L.Add(TBank_Account(fmeAccountSelector1.AccountCheckBox.Items.Objects[i]).baFields.baBank_Account_Number);
end;

end.
