unit SelectJournalDlg;
//------------------------------------------------------------------------------
{
   Title:       Journal Date Selection Dialog

   Description:

   Remarks:    Updated Nov 2001

   Author:     Matthew Hopkins

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcBase, OvcEF, OvcPB, OvcPF, StdCtrls, bkDefs, baObj32, Menus, Buttons,
  ImgList, ComCtrls, RzListVw, RzCmboBx, RzDTP, ExtCtrls,
  OSFont;


type
  TdlgSelectJournal = class(TForm)
    pTop: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    OvcController1: TOvcController;
    PBottom: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    eDate: TOvcPictureField;
    Label2: TLabel;
    ERef: TEdit;
    ENarration: TEdit;
    Label4: TLabel;
    btnView: TButton;
    rgAction: TRadioGroup;
    BtnCal: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure eDateError(Sender: TObject; ErrorCode: Word;
      ErrorMsg: String);
    procedure menuItemClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure eDateDblClick(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
    procedure BtnCalClick(Sender: TObject);
  private
    { Private declarations }

    Bank_Account    : tBank_Account;
    JournalType     : byte;
    FHelpID         : integer;

    function  OKtoPost(DateOnly: Boolean): boolean;
    procedure SetUpHelp;
  protected
    procedure UpdateActions; override;
  public
    { Public declarations }
    //Trans : pTransaction_Rec;
    Date  : integer;

    function Execute :TModalresult;
  end;

function SelectJournal( Account_Type : integer;
                        BA : TBank_Account;
                        var effDate : integer;
                        var Transaction : pTransaction_Rec;
                        var JAction: Integer;
                        HelpCtx : integer;
                        NoView: Boolean) : TModalresult;
//******************************************************************************
implementation

{$R *.DFM}

uses
  bkConst,
  bkDateUtils,
  bkHelp,
  bkXPThemes,
  Finalise32,
  Globals,
  imagesfrm,
  JnlUtils32,
  ovcDate,
  selectDate,
  stDatest,
  stdHints,
  InfoMoreFrm,
  GenUtils,
  YesNoDlg,
  CountryUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


procedure TdlgSelectJournal.FormCreate(Sender: TObject);
var I: integer;
begin
   bkXPThemes.ThemeForm( Self);

   eDate.Epoch       := BKDATEEPOCH;
   eDate.PictureMask := BKDATEFORMAT;


   SetUpHelp;
   //load LineType combo from BKCONST values
   rgAction.Items.Clear;
   //Add lines from BKCONST definition
   for i := jtMin to jtMax do begin
      if i in EditableTypesSet then
         rgAction.Items.AddObject(jtNames[i], TObject(i));
   end;
   rgAction.ItemIndex := 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectJournal.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := BKH_Using_the_Enter_Journal_window ;
   //Components
   eDate.Hint       :=
      'Enter the Effective Date for this Journal|'+
      'Enter the Effective Date for this Journal.  This will usually be a month end date within this financial year';

end;
procedure TdlgSelectJournal.updateactions;
var EffDate: Integer;
begin
   inherited;
   EffDate := StNull2BK( eDate.AsStDate );

   BtnView.Enabled := (EffDate > MinValidDate)
                   and (EffDate < MaxValidDate)
                   and HasJournalsInMonth(Bank_Account, EffDate);

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgSelectJournal.OKtoPost(DateOnly: Boolean): boolean;
var Dr: TDateRange;
    D: Integer;
begin
   Result := false;
   D := StNull2BK( eDate.AsStDate );

   if (D <= 0) or
      (D < MinValidDate) or
      (D > MaxValidDate) then
   begin
     HelpfulInfoMsg('Please enter a valid date.',0);
     if SetFocusSafe( eDate) then
        eDate.SelectAll;
     Exit;
   end;

   if DateOnly then begin
      Date := D;
      Result := True;
      Exit;
   end;

   {if JournalType in [ btCashJournals, btAccrualJournals, btGSTJournals] then begin}
      DR := GetMonthDateRange(D);

      if ( Finalise32.IsLocked( DR.FromDate, DR.ToDate) in [ ltAll, ltSome]) then begin
         HelpfulInfoMsg( 'Finalised entries exist in the month you have selected.'#13 +
                         'You cannot add a journal to a finalised period.', 0);
         Exit;
      end;
   {end;}

   {set return values for dialog}
   Date  := D;
   Result := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectJournal.btnOKClick(Sender: TObject);
begin
   if OKtoPost(False) then
     Modalresult := mrOK;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectJournal.btnViewClick(Sender: TObject);
begin
   if OKtoPost(True) then
      Modalresult := mrRetry;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectJournal.BtnCalClick(Sender: TObject);
begin
   eDateDblClick(eDate);
end;

procedure TdlgSelectJournal.btnCancelClick(Sender: TObject);
begin
   Modalresult := mrCancel;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectJournal.eDateDblClick(Sender: TObject);
var ld: Integer;
begin
   if sender is TOVcPictureField then begin
      ld := TOVcPictureField(Sender).AsStDate;
      PopUpCalendar(TEdit(Sender),ld);
      TOVcPictureField(Sender).AsStDate := ld;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectJournal.eDateError(Sender: TObject; ErrorCode: Word;
  ErrorMsg: String);
begin
  TOvcPictureField(Sender).AsString := '';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectJournal.menuItemClick(Sender: TObject);
begin
  eDate.asStDate := BKNull2St( TMenuItem(Sender).Tag );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgSelectJournal.Execute: TModalresult;
begin
  Date      := -1;

  Result := ShowModal;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectJournal( Account_Type : integer;
                        BA : TBank_Account;
                        var effDate : integer;
                        var Transaction : pTransaction_Rec;
                        var JAction: Integer;
                        HelpCtx : integer;
                        NoView: Boolean) : TModalresult;
var
   d, m, y : integer;
begin
   Result := mrCancel;
   if ( not Assigned( MyClient))
   or ( not Assigned( BA )) then
      Exit;

   if EffDate = 0 then
      EffDate := -1;

   with tdlgSelectJournal.Create(Application.MainForm) do begin
      try
        Caption := 'Select Date for '+ Localise(MyClient.clFields.clCountry, btNames[Account_Type]);
        Bank_Account := BA;
        JournalType  := Account_Type;
        eDate.BorderStyle := bsNone;
        FHelpID := HelpCtx;
        btnView.Visible := not NoView;

        if EffDate > 0 then // use This date
           eDate.AsStDate := BKNull2St( EffDate )
        else if MyClient.clFields.clLast_Journal_Date > 0 then // Use Last used date..
           eDate.AsStDate := BKNull2St( MyClient.clFields.clLast_Journal_Date )
        else begin
           //show end of last month by
           StDateToDMY( CurrentDate, d, m, y);
           Dec(m);
           if m < 1 then begin
             m := 12;
             Dec(y);
           end;
           d := DaysInMonth( m, y, BKDATEEPOCH);
           eDate.AsStDate := DMYToStDate( d, m, y, BKDATEEPOCH);
        end;

        if Assigned(Transaction) then begin
           ERef.Text := Transaction.txReference;
           ENarration.Text :=  Transaction.txGL_Narration;
        end;

        //******************
        Result := Execute;
        //******************

        if Result in [mrOK, mrRetry] then begin
           EffDate := StNull2Bk( Date );
           if result = mrOK then begin
              MyClient.clFields.clLast_Journal_Date := effDate;
              if not assigned(Transaction) then
                 Transaction := NewJournalFor(MyClient, Bank_Account, EffDate);
              Transaction.txReference := ERef.Text;
              Transaction.txGL_Narration := ENarration.Text;
              Transaction.txAccount := DISSECT_DESC;
              if rgAction.ItemIndex >=0 then
                 JAction := Integer(rgAction.Items.Objects[rgAction.ItemIndex])
              else
                 JAction := 0;
           end;
        end else begin
           // #1661 - if user cancelled then remove the journal if empty
           if NoView then
              // Do not remove if from Coding Screen.
           else
              JnlUtils32.RemoveJnlAccountIfEmpty( MyClient, BA);
        end;
      finally
        //Free;
        Release;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectJournal.FormShow(Sender: TObject);
begin
  BKHelpSetUp( Self, FHelpID);
end;


end.
