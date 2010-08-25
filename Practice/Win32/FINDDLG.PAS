unit FindDlg;

//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcNF, OvcBase, OvcEF, OvcPB, OvcPF, StdCtrls, Buttons, OvcABtn,
  osFont;

type
   Str12 = String[12];

type
  TdlgFind = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    tReference: TEdit;
    EntryDate: TOvcPictureField;
    OvcController1: TOvcController;
    nAmount: TOvcNumericField;
    btnOK: TButton;
    btnCancel: TButton;
    BtnCal: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure EntryDateError(Sender: TObject; ErrorCode: Word;
      ErrorMsg: String);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure EntryDateKeyPress(Sender: TObject; var Key: Char);
    procedure BtnCalClick(Sender: TObject);
    procedure EntryDateDblClick(Sender: TObject);
  private
    { Private declarations }
    okPressed : boolean;
  public
    { Public declarations }
    function Execute(var DateValue : integer; var Ref:str12; var Amt : double) : boolean;
  end;

  function FindParameters(var DateValue : integer; var Ref:str12; var Amt : double) : boolean;
//******************************************************************************
implementation
{$R *.DFM}

uses
  Genutils,
  ovcDate,
  bkDateUtils,
  quikdate,
  bkhelp,
  globals,
  WarningMoreFrm,
  bkXPThemes;

//------------------------------------------------------------------------------
procedure TdlgFind.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);

   EntryDate.AsString := '';
   tReference.text    := '';
   nAmount.asFloat    := 0.0;

   EntryDate.Epoch    := BKDATEEPOCH;
   SetUpHelp;
end;
//------------------------------------------------------------------------------
procedure TdlgFind.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   EntryDate.Hint   :=
                    'Enter the Effective Date of the transaction|' +
                    'Enter the Effective Date of the transaction or leave blank for any';
   tReference.Hint  :=
                    'Enter the Reference of the transaction|' +
                    'Enter the Reference of the transaction, wild card characters can be used in search string';
   nAmount.Hint     :=
                    'Enter the Amount of the transaction|' +
                    'Enter the Amount of the transaction or leave blank if unsure';

   BKHelpSetUp( Self, BKH_Finding_a_transaction);
end;
//------------------------------------------------------------------------------
procedure SpaceDate(EditBox : TOvcPictureField; def : TStDate);
var
   ClientP, ScreenP : TPoint;
   Return : String;
   temp   : TDateTime;
begin
   ClientP.x := 0;
   ClientP.y := EditBox.Height;
   ScreenP   := EditBox.ClientToScreen(ClientP);
   temp      := StrToDate(bkDate2Str(def));

   return := PopupDateStr(Screenp.x, Screenp.y, temp);
   if Return <> '' then
     EditBox.AsString := Return;
end;
//------------------------------------------------------------------------------
procedure TdlgFind.BtnCalClick(Sender: TObject);
begin
    EntryDateDblClick(EntryDate);
end;

procedure TdlgFind.btnCancelClick(Sender: TObject);
begin
   Close;
end;
//------------------------------------------------------------------------------
procedure TdlgFind.btnOKClick(Sender: TObject);
begin
   okPressed := true;
   Close;
end;
//------------------------------------------------------------------------------
procedure TdlgFind.EntryDateDblClick(Sender: TObject);
var ld: Integer;
begin
   if sender is TOVcPictureField then begin
      ld := TOVcPictureField(Sender).AsStDate;
      PopUpCalendar(TEdit(Sender),ld);
      TOVcPictureField(Sender).AsStDate := ld;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgFind.EntryDateError(Sender: TObject; ErrorCode: Word;
  ErrorMsg: String);
begin
  HelpfulWarningMsg('Invalid Date Entered. Please Reenter.',0);
  EntryDate.AsString := '';
end;
//------------------------------------------------------------------------------
procedure TdlgFind.EntryDateKeyPress(Sender: TObject; var Key: Char);
begin
{  if key = #32 then
   begin
    btn1.SetFocus;
    btn1.Click;
    key := #0;
   end;}
end;
//------------------------------------------------------------------------------
function TdlgFind.Execute(var DateValue : integer; var Ref:str12; var Amt : double) : boolean;
begin
  Result := false;
  ShowModal;
  if okpressed then begin
    DateValue := StNull2BK( EntryDate.AsStDate );
    Ref       := tReference.Text;
    Amt       := nAmount.AsFloat;
    // Result = True if user has set a value in any field
    Result := not ( (DateValue = 0 ) and (Ref = '') and (Amt = 0) );
  end;
end;
//------------------------------------------------------------------------------
function FindParameters(var DateValue : integer; var Ref:str12; var Amt : double) : boolean;
var
  MyDlg : tDlgFind;
  tempDate : integer;
  tempRef  : string[12];
  tempAmt  : double;
begin
  tempDate := 0;
  tempRef  := '';
  tempAmt  := 0;
  result   := false;

  MyDlg := tDlgFind.Create(Application.MainForm);
  try
    if MyDlg.Execute(tempDate,tempRef,tempAmt) then
    begin
       DateValue := tempDate;
       Ref       := tempRef;
       Amt       := tempAmt;
       result := true;
    end;
  finally
    MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
end.
