unit CopyFromDlg;
//------------------------------------------------------------------------------
{
   Title:       Copy From Dlg

   Description: Called by the various merge routines

   Author:

   Remarks:

}
//------------------------------------------------------------------------------
   
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,   ClientLookupFme, ComCtrls,
  OsFont;
  
type
  TdlgCopyFrom = class(TForm)
    Panel1: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    chkMergeSubgroups: TCheckBox;
    chkMergeDivisions: TCheckBox;
    pnlFrameHolder: TPanel;
    ClientLookupFrame: TfmeClientLookup;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    okPressed : boolean;
    procedure SetUpHelp;
    procedure FrameDblClick(Sender: TObject);

    procedure SetUpFrame;
  public
    { Public declarations }
    function Execute :boolean;
  end;

function SelectCopyFrom(title : string; var CopyFromCode : string) : boolean;

function MergeChartSelectCopyFrom(title : string;
                                  var CopyFromCode : string;
                                  var MergeSubgroups : boolean;
                                  var MergeDivisions : boolean) : boolean;

function SubgroupsCopyFrom(title : string; var CopyFromCode : string) : boolean;

//******************************************************************************
implementation

uses
  Admin32,
  bkConst,
  bkDefs,
  bkXPThemes,
  globals,
  syDefs;

{$R *.DFM}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCopyFrom.FrameDblClick(Sender: TObject);
begin
  btnOK.Click;
end;
//------------------------------------------------------------------------------
procedure TdlgCopyFrom.btnOkClick(Sender: TObject);
begin
  //make sure that only one code is selected
  if ClientLookupFrame.FirstSelectedCode <> '' then
  begin
    okPressed := true;
    Close;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgCopyFrom.btnCancelClick(Sender: TObject);
begin
  Close;
end;
//------------------------------------------------------------------------------
function TdlgCopyFrom.Execute: boolean;
begin
  okPressed := false;
  ShowModal;
  result := okPressed;
end;
//------------------------------------------------------------------------------
procedure TdlgCopyFrom.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  ClientLookupFrame.DoCreate;

  SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCopyFrom.SetUpFrame;
begin
  if Assigned( AdminSystem) then
    Admin32.ReloadAdminAndTakeSnapshot( ClientLookupFrame.AdminSnapshot);

  with ClientLookupFrame do
  begin
    //add columns and build the grid
    ClearColumns;
    AddColumn( 'Code', 150, cluCode);
    AddColumn( 'Name', -1, cluName);
    BuildGrid( cluCode);
    FilterMode := fmAvailableFiles;
    SelectMode := smSingle;
    //set the view mode, this will reload the data
    ViewMode   := vmAllFiles;
    //set up events
    OnGridDblClick     := FrameDblClick;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCopyFrom.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectCopyFrom(Title : string; var CopyFromCode : string) : boolean;
var
  MyDlg : TdlgCopyFrom;
begin
  result := false;
  CopyFromCode := '';

  MyDlg := tDlgCopyFrom.Create(Application.MainForm);
  try
    MyDlg.SetUpFrame;

    MyDlg.caption := title;
    if MyDlg.Execute then
    begin
      CopyFromCode := MyDlg.ClientLookupFrame.FirstSelectedCode;
      result := true;
    end;
  finally
    Mydlg.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MergeChartSelectCopyFrom(title : string;
                                  var CopyFromCode : string;
                                  var MergeSubgroups : boolean;
                                  var MergeDivisions : boolean) : boolean;
begin
  result := false;
  CopyFromCode := '';

  with tDlgCopyFrom.Create(Application) do begin
     try
        chkMergeSubgroups.visible := true;
        chkMergeDivisions.visible := true;

        SetUpFrame;

        caption := title;
        if Execute then begin
          CopyFromCode   := ClientLookupFrame.FirstSelectedCode;
          MergeSubgroups := chkMergeSubgroups.checked;
          MergeDivisions := chkMergeDivisions.checked;
          result := true;
        end;
     finally
        Free;
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SubgroupsCopyFrom(title : string; var CopyFromCode : string) : boolean;
begin
  result := false;
  CopyFromCode := '';

  with tDlgCopyFrom.Create(Application) do begin
     try
        Panel1.Height := Panel1.Height - 20;

        SetUpFrame;

        caption := title;
        if Execute then begin
          CopyFromCode := ClientLookupFrame.FirstSelectedCode;
          result       := true;
        end;
     finally
        Free;
     end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCopyFrom.FormShow(Sender: TObject);
begin
  ClientLookupFrame.SetFocusToGrid;
end;

end.
