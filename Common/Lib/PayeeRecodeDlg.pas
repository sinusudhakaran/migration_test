unit PayeeRecodeDlg;
//------------------------------------------------------------------------------
{
   Title:       Payee Recode dialog,

   Description:

   Remarks:    recode trans or only change narration

               Each "Hyperlink Button" uses a TPanel, TRzURLLabel and a TRzBmpButton.
               The TRzBmpButton is used so that we get a focus rect
               The TPanel is used so that the URLLabel can be shown in front
                  of the TRzBtnButton.

   Author:     Matthew Hopkins Feb 2001

}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  RzButton, ExtCtrls, StdCtrls, RzLabel, RzBmpBtn,
  OSFont;

const
   prCancel = 0;
   prRecode = 1;
   prNarrationOnly = 2;

type
  TdlgPayeeRecode = class(TForm)
    Label3: TLabel;
    Bevel1: TBevel;
    btnCancel: TButton;
    rbtnClear: TRzBmpButton;
    rbtnPreserve: TRzBmpButton;
    pnlPreserve: TPanel;
    ruClear: TRzURLLabel;
    ruPreserve: TRzURLLabel;
    pnlClear: TPanel;
    procedure btnCancelClick(Sender: TObject);
    procedure ruClearClick(Sender: TObject);
    procedure ruPreserveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rbtnClearClick(Sender: TObject);
    procedure rbtnPreserveClick(Sender: TObject);
  private
    { Private declarations }
    ReturnCode : integer;
  public
    { Public declarations }
  end;

function AskRecodeOnPayeeChange : integer;

//******************************************************************************
implementation

{$R *.DFM}

uses
  bkXPThemes;

//------------------------------------------------------------------------------

procedure TdlgPayeeRecode.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  ruClear.Font.Name := Font.Name;
  ruPreserve.Font.Name := Font.Name;
  ReturnCode := prCancel;
  pnlPreserve.BorderStyle := bsNone;
  pnlClear.BorderStyle    := bsNone;
end;
//------------------------------------------------------------------------------

procedure TdlgPayeeRecode.btnCancelClick(Sender: TObject);
begin
   ReturnCode := prCancel;
   Close;
end;
//------------------------------------------------------------------------------

procedure TdlgPayeeRecode.ruClearClick(Sender: TObject);
begin
   rbtnClear.Click;
end;
//------------------------------------------------------------------------------

procedure TdlgPayeeRecode.ruPreserveClick(Sender: TObject);
begin
   rbtnPreserve.Click;
end;
//------------------------------------------------------------------------------

procedure TdlgPayeeRecode.rbtnClearClick(Sender: TObject);
begin
   ReturnCode := prRecode;
   Close;
end;
//------------------------------------------------------------------------------

procedure TdlgPayeeRecode.rbtnPreserveClick(Sender: TObject);
begin
   ReturnCode := prNarrationOnly;
   Close;
end;
//------------------------------------------------------------------------------

function AskRecodeOnPayeeChange : integer;
begin
   with TDlgPayeeRecode.Create(Application.MainForm) do begin
      try
         ShowModal;
         result := ReturnCode;
      finally
         free;
      end;
   end;
end;
//------------------------------------------------------------------------------

end.
//------------------------------------------------------------------------------
