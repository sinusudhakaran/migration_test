unit HistChequesDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   Historical Entries Add Cheques Dialog

  Written: Nov 1999
  Authors: Matthew

  Purpose: Asks the user for a default date and cheque number range.

  Notes:  The date and cheque range is validated before allowing the user
          to accept the values.

          The maximum length of a cheque number is 6 digits.  This is because
          of the way cheques numbers are stored in a transaction.  (only the
          last 6 digits are used).
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OvcBase, OvcNF, OvcEF, OvcPB, OvcPF,
  OSFont;

type
  TdlgHistCheques = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    eDateFrom: TOvcPictureField;
    nfCheqFrom: TOvcNumericField;
    OvcController1: TOvcController;
    nfCheqTo: TOvcNumericField;
    Label4: TLabel;
    Label5: TLabel;

    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure eDateFromError(Sender: TObject; ErrorCode: Word;
      ErrorMsg: String);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    MaxDateAllowed : integer;
  public
    { Public declarations }
  end;

  function GetAddChequesRange( const MaxDate : integer; var CheqNoFrom : integer; var CheqNoTo : integer; var DefDate : integer) : boolean;

//******************************************************************************
implementation

uses
  BKHelp,
  bkXPThemes,
  ErrorMoreFrm,
  SelectDate,
  bkDateUtils,
  BKCONST,
  Globals;

{$R *.DFM}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistCheques.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  eDateFrom.Epoch       := BKDATEEPOCH;
  eDateFrom.PictureMask := BKDATEFORMAT;
  nfCheqFrom.PictureMask := ChequeNoMask;
  nfCheqTo.PictureMask   := ChequeNoMask;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistCheques.eDateFromError(Sender: TObject; ErrorCode: Word;
  ErrorMsg: String);
begin
   ShowDateError(Sender);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistCheques.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
const
   MaxNoCheqs = 50;
begin
   if ModalResult = mrOK then begin
      CanClose := false;
      //check that all values specified
      if ( nfCheqFrom.AsInteger = 0 ) or ( nfCheqTo.AsInteger = 0 ) then begin
         HelpfulErrorMsg( 'You have not specified a complete cheque range.' ,0 );
         nfCheqFrom.SetFocus;
         exit;
      end;
      //check that from <= to
      if nfCheqFrom.AsInteger > nfCheqTo.AsInteger then begin
         HelpfulErrorMsg( 'The Cheque number from value is greater than the Cheque number to value.' ,0);
         nfCheqTo.SetFocus;
         exit;
      end;
      //check that date is specified
      if eDateFrom.AsStDate <= 0 then begin
         HelpfulErrorMsg('You must specify a default date.', 0);
         eDateFrom.Setfocus;
         exit;
      end;
      //check that date is valid, ie.  valid format, is not greater than
      //max date allowed.
      if (MaxDateAllowed <> 0) and (eDateFrom.AsStDate > MaxDateAllowed) then begin
         HelpfulErrorMsg('You cannot specify a default date that is after '+ bkDate2Str( MaxDateAllowed )+'.', 0);
         eDateFrom.SetFocus;
         exit;
      end;
      //greater than minValidDate
      if eDateFrom.AsStDate < GLOBALS.MinValidDate then begin
         HelpfulErrorMsg('You cannot specify a default date that is before '+ bkDate2Str( GLOBALS.MinValidDate )+'.', 0);
         eDateFrom.SetFocus;
         exit;
      end;
      //More than max no of cheques added
      if Abs( nfCheqTo.AsInteger - nfCheqFrom.AsInteger) >= MaxNoCheqs then begin
         HelpfulErrorMsg('You can only enter '+inttostr(MaxNoCheqs)+' cheques at one time! Please adjust the cheque range entered.',0);
         nfCheqTo.SetFocus;
         exit;
      end;
      //Nothing Failed, can close ok
   end;
   CanClose := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetAddChequesRange( const MaxDate : integer;
                             var CheqNoFrom : integer;
                             var CheqNoTo : integer;
                             var DefDate : integer) : boolean;
var
  HistCheques : TdlgHistCheques;
begin
  Result := false;
  HistCheques := TdlgHistCheques.Create(Application.MainForm);
  with HistCheques do
  begin
    try
      BKHelpSetUp(HistCheques ,BKH_Adding_cheque_ranges);
      MaxDateAllowed := MaxDate;
      //Show Form
      ShowModal;
      //If okay then set values and return true;
      if ModalResult = mrOK then begin
         CheqNoFrom  := nfCheqFrom.AsInteger;
         CheqNoTo    := nfCheqTo.AsInteger;
         DefDate     := eDateFrom.AsStDate;
         result      := true;
      end;
    finally
      Free;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
