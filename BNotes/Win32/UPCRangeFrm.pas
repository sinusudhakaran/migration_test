unit UPCRangeFrm;
//------------------------------------------------------------------------------
{
   Title:        UPC Range Form

   Description:  Form for entering a upc range.  Also validates range to see
                 if there are any cheques to add.

   Remarks:

   Author:       Matthew Hopkins  Aug 2001

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  BaseFrm, RzCommon, StdCtrls, Mask, RzEdit, ExtCtrls,
  ecBankAccountObj;

type
  TfrmUPCRange = class(TfrmBase)
    Panel1: TPanel;
    Label4: TLabel;
    lblPeriod: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    rzChqFrom: TRzNumericEdit;
    rzChqTo: TRzNumericEdit;
    RzFrameController1: TRzFrameController;
    Image1: TImage;
    lblDated: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure rzChqFromKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function GetUPCRange( BAccount : TECBank_Account;
                        const DateFrom : integer;
                        const DateTo : integer;
                        var ChqNoFrom : integer;
                        var ChqNoTo : integer) : boolean;

//******************************************************************************
implementation

{$R *.DFM}

uses
   ecColors,
   ecMessageBoxUtils,
   GenUtils,
   FormUtils,
   NotesHelp;

function GetUPCRange( BAccount : TECBank_Account;
                      const DateFrom : integer;
                      const DateTo : integer;
                      var ChqNoFrom : integer;
                      var ChqNoTo : integer) : boolean;
begin
  result := false;

  with TfrmUPCRange.Create( nil) do
  begin
    try
      lblPeriod.Caption := bkDate2Str( DateFrom) + ' to ' + bkDate2Str( DateTo);
      lblDated.Caption  := 'New cheques will be dated ' + bkDate2Str( DateTo);

      if ShowModal = mrOK then
      begin
        ChqNoFrom := rzChqFrom.IntValue;
        ChqNoTo   := rzChqTo.IntValue;

        result := true;
      end;
    finally
      Free;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmUPCRange.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
const
  MaxCheques = 250;
var
  sn1, sn2 : integer; //serial numbers
  S        : string;
  diff     : integer;
begin
  inherited;
  if ModalResult = mrOK then begin
      sn1 := rzChqFrom.IntValue;
      sn2 := rzChqTo.IntValue;
      //if nothing entered just close as if cancel pressed
      if ( sn1 = 0) then begin
        if ( sn2 = 0) then
          ModalResult := mrCancel
        else
        begin
          ErrorMessage('Cheque number 0 is invalid');
          rzChqFrom.SetFocus;
          CanClose := False;
        end;
        Exit;
      end;
      Diff := sn2-sn1 + 1; //inclusive
      if ( Diff < 0) or ( Diff > MaxCheques) or ( sn2 < sn1) then
      begin
        S := Format( 'The range %d to %d is invalid.'#13#10, [ sn1, sn2 ] );
        if ( sn2 < sn1) then
          S := S + Format( '%d is larger than %d.', [ sn1, sn2] )
        else //if (Diff > MaxCheques ) then
          S := S + 'It contains more than ' + inttostr( MaxCheques) + ' cheques.';
        ErrorMessage( S);
        CanClose := False;
        Exit;
      end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmUPCRange.FormCreate(Sender: TObject);
begin
  inherited;
  BKHelpSetUp(Self, BKH_Adding_unpresented_items);
end;

procedure TfrmUPCRange.rzChqFromKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = '-' then Key := #0;
end;

end.
