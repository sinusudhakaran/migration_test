unit StatusFrm;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, RzPrgres,
  bkXPThemes,
  OSFont;

type
  TfrmStatus = class(TForm)
    lblLine1: TLabel;
    lblLine2: TLabel;
    btnCancel: TButton;
    pBarAppStatus: TRzProgressBar;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
    ActionOnClose : TCloseAction;
  public
    { Public declarations }
    procedure UpdateFrmStatus(Msg1: string; Msg2 :string; Perc: double; visible : boolean);
    procedure FreeClose;
  end;

var
  frmStatus: TfrmStatus;

  Status_Cancel_Visible : boolean = false;
  Status_Cancel_Pressed : boolean = false;

//******************************************************************************
implementation
//USES   ---- NEVER CALL ANY OTHER UNITS ----
//       ---- THIS UNIT IS USED BY LogUtil in BK5, calling any other units will cause them
//       ---- to be loaded before LogUtil initializes.

{$R *.DFM}

procedure TfrmStatus.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := ActionOnClose;
end;

procedure TfrmStatus.FreeClose;
begin
   ActionOnClose := caFree;
end;

procedure TfrmStatus.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);
   lblLine1.Font.Name := Font.Name;
   ActionOnClose := caHide;
end;

procedure TfrmStatus.UpdateFrmStatus(Msg1: string; Msg2: string;Perc: double; visible : boolean);
begin
{$IFDEF BK5_TESTLOCKING}
  Exit;
{$ENDIF}
   if Status_Cancel_Visible then
   begin
     btnCancel.visible := true;
     Self.Height := 145;
   end
   else
   begin
     btnCancel.visible := false;
     Self.Height := 115;
   end;

   if Visible then
   begin
     if not Self.Visible then
     begin
       Self.Show;
     end;
   end
   else
   begin
     Self.Hide;
   end;

   lblLine1.caption  := Msg1;
   lblLine2.caption  := Msg2;

   if (Perc >= 0) and (Perc <= 100) then begin
     pbarAppStatus.percent := round(Perc);
   end;
end;

procedure TfrmStatus.btnCancelClick(Sender: TObject);
begin
  if Status_Cancel_Visible then
      Status_Cancel_Pressed := true;
end;

end.
