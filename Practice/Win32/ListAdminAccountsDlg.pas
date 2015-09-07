unit ListAdminAccountsDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  OsFont, ExtCtrls;

type
  TlaReportOptions = record
     IncludeDeleted : boolean;
     NotActiveSince : Integer;
  end;

type
  TdlgAdminAccountOptions = class(TForm)
    gbOptions: TGroupBox;
    chkIncludeDeleted: TCheckBox;
    GBInactive: TGroupBox;
    CBdates: TComboBox;
    Label1: TLabel;
    Panel1: TPanel;
    btnPreview: TButton;
    btnFile: TButton;
    btnPrint: TButton;
    btnCancel: TButton;

    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
    btn : integer;
    FCheckActive: Boolean;
    procedure SetCheckActive(const Value: Boolean);
    procedure FillDateList;
  public
    { Public declarations }
    function Execute : boolean;
    property CheckActive : Boolean read FCheckActive write SetCheckActive;
  end;

function GetListAdminAccountOptions(const DialogTitle : string;
                                    CheckIfActive : Boolean;
                                    var Options : TlaReportOptions;
                                    var BtnPressed : integer) : boolean;

//******************************************************************************
implementation

uses
  stDate,
  bkdateUtils,
  BKHelp,
  Globals, bkXPThemes;

{$R *.DFM}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TdlgDownloadReportOptions }
function TdlgAdminAccountOptions.Execute: boolean;
begin
   Self.ShowModal;
   result := btn in [ BTN_PRINT, BTN_PREVIEW, BTN_FILE];
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAdminAccountOptions.btnPreviewClick(Sender: TObject);
begin
   Btn := BTN_PREVIEW;
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAdminAccountOptions.btnFileClick(Sender: TObject);
begin
   Btn := BTN_FILE;
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAdminAccountOptions.btnPrintClick(Sender: TObject);
begin
   Btn := BTN_PRINT;
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAdminAccountOptions.btnCancelClick(Sender: TObject);
begin
   Btn := BTN_NONE;
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAdminAccountOptions.SetCheckActive(const Value: Boolean);
begin
  FCheckActive := Value;
  if FCheckActive then begin
     chkIncludeDeleted.Visible := false;
     Height := Height -  chkIncludeDeleted.Height;
     FillDateList;
  end else begin
     GBInactive.Visible := false;
     Height := Height -  GBInactive.Height;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetListAdminAccountOptions(const DialogTitle : string;
                                    CheckIfActive : Boolean;
                                    var Options : TlaReportOptions;
                                    var BtnPressed : integer) : boolean;
var
  AdminAccountOptions : TdlgAdminAccountOptions;
begin
   BtnPressed := btn_none;
   AdminAccountOptions := TdlgAdminAccountOptions.Create(Application.MainForm);
   with AdminAccountOptions do begin
      try
         BKHelpSetUp(AdminAccountOptions, BKH_List_bank_accounts_System);
         Caption := DialogTitle;
         CheckActive := CheckIfActive;
         if CheckIfActive then begin
            cbdates.ItemIndex := cbDates.Items.IndexOfObject(TObject(Options.NotActiveSince));
            if cbdates.ItemIndex < 0 then
              cbdates.ItemIndex := 0;
         end else begin
            chkIncludeDeleted.Checked := Options.IncludeDeleted;
         end;

         //****************
         Result := Execute;
         //****************
         if result then begin

            if CheckIfActive then begin
               Options.IncludeDeleted := True;// ??
               if cbdates.ItemIndex <> -1 then
                 Options.NotActiveSince := integer (
                   cbdates.Items.Objects[cbdates.ItemIndex]
                                                    )
               else
                  Options.NotActiveSince := 0;
            end else begin
               Options.NotActiveSince := 0;
               Options.IncludeDeleted := chkIncludeDeleted.Checked;
            end;
            btnPressed := btn;
         end;
      finally
         Free;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


procedure TdlgAdminAccountOptions.FillDateList;
var ld : Integer;
    Month, Year,Day : Word;
begin
    CBdates.Items.BeginUpdate;
    try
       CBdates.Items.Clear;
       DecodeDate(Now,Year,Month,day);// get Yer and Month
       ld := IncDate(DMYtoStDate(1, Month, Year, BKDateEpoch),0,-1,0);
       CBdates.Items.AddObject(Date2Str(IncDate(ld,-1,0,0),'nnn yyyy'){} + ' (1+ month ago)'{},Tobject(LD));
       for month := 2 to 15 do begin
          ld := IncDate(ld,0,-1,0);
          CBdates.Items.AddObject( Date2Str(IncDate(ld,-1,0,0),'nnn yyyy') + ' (' +IntToStr(Month) + '+ months ago)'{} ,Tobject(LD));
       end
    finally
       CBdates.Items.EndUpdate;
    end;
    CBdates.ItemIndex := 0;
end;


procedure TdlgAdminAccountOptions.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);
end;

end.
