unit TransTypeDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcTCHdr, StdCtrls, ExtCtrls, OvcTCEdt, OvcTCmmn, OvcTCell, OvcTCStr,
  OvcBase, OvcTable, globals,
  OSFont;

type
   TTransInfo = record
                   TypeNo   : string[4];
                   LongDesc : string[30];
                   ShortDesc: string[10];
                end;

   TTransInfoArray = Array[0..MAX_TRX_TYPE] of TTransInfo;

type
  TdlgTransTypes = class(TForm)
    tblTrans: TOvcTable;
    OvcController1: TOvcController;
    OvcTCColHead1: TOvcTCColHead;
    colLongDesc: TOvcTCString;
    colShortDesc: TOvcTCString;
    Bevel1: TBevel;
    btnOK: TButton;
    btnCancel: TButton;
    OvcTCString1: TOvcTCString;
    procedure tblTransGetCellData(Sender: TObject; RowNum,
      ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tblTransUserCommand(Sender: TObject; Command: Word);
    procedure tblTransBeginEdit(Sender: TObject; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tblTransEndEdit(Sender: TObject; Cell: TOvcTableCellAncestor;
      RowNum, ColNum: Integer; var AllowIt: Boolean);
    procedure tblTransExit(Sender: TObject);
    procedure tblTransEnter(Sender: TObject);
    procedure SetUpHelp;
  private
    { Private declarations }
    FData : TTransInfoArray;
    EditMode : boolean;
    okPressed : boolean;
  public
    { Public declarations }
    function Execute : boolean;
  end;

  function EditTransactionTypes : boolean;

//******************************************************************************
implementation
{$R *.DFM}

uses
  admin32, bkXPThemes,
  syDefs, ErrorMoreFrm, OvcConst, bkBranding;

const
  tcDeleteCell     = ccUserFirst + 1;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgTransTypes.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  bkBranding.StyleOvcTableGrid(tblTrans);
  bkBranding.StyleTableHeading(OvcTCColHead1);

  with tblTrans.Controller.EntryCommands do begin
    {remove F2 functionallity}
    DeleteCommand('Grid',VK_F2,0,0,0);
    DeleteCommand('Grid',VK_DELETE,0,0,0);

    {add our commands}
    AddCommand('Grid',VK_F6,0,0,0,ccTableEdit);
    AddCommand('Grid',VK_DELETE,0,0,0,tcDeleteCell);
  end;
  tblTrans.CommandOnEnter := ccRight;
  SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgTransTypes.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   tblTrans.Hint :=
      'Edit Transaction Types and Descriptions|'+
      'Edit this list of Transaction Types and Descriptions';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgTransTypes.btnOKClick(Sender: TObject);
begin
   okPressed := true;
   Close;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgTransTypes.btnCancelClick(Sender: TObject);
begin
   okPressed := false;
   Close;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgTransTypes.tblTransGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
begin
  data := nil;

  if RowNum >0 then
  case ColNum of
    0: data := @FData[RowNum-1].TypeNo;
    1: data := @FData[RowNum-1].LongDesc;
    2: data := @FData[RowNum-1].ShortDesc;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgTransTypes.tblTransUserCommand(Sender: TObject;
  Command: Word);
begin
  Case Command of
        tcDeleteCell: begin
                      if EditMode then exit;
                      Keybd_event(VK_SPACE,0,0,0);
                      Keybd_event(VK_BACK ,0,0,0);
                      Keybd_event(VK_F6   ,0,0,0);
                    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgTransTypes.tblTransBeginEdit(Sender: TObject; RowNum,
  ColNum: Integer; var AllowIt: Boolean);
begin
   EditMode := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgTransTypes.tblTransEndEdit(Sender: TObject;
  Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
  var AllowIt: Boolean);
begin
  EditMode := false;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgTransTypes.tblTransExit(Sender: TObject);
var
  Msg : TWMKey;
begin
  {lost focus so finalise edit if in edit mode}
  if EditMode then
  begin
    Msg.CharCode := vk_f6;
    ColLongDesc.SendKeyToTable(Msg);
  end;

  btnOk.Default := true;
  btnCancel.Cancel := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgTransTypes.tblTransEnter(Sender: TObject);
begin
   btnOk.Default    := false;
   btnCancel.Cancel := false;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgTransTypes.Execute: boolean;
const
   ThisMethodName = 'TDlgTransTypes.Execute';
var
  i : integer;
begin
  okPressed := false;

  {load transaction types from admin system}
  for i := 0 to MAX_TRX_TYPE do
  begin
     FData[i].TypeNo    := inttostr(i)+':';
     FData[i].LongDesc  := Adminsystem.fdFields.fdLong_Name[i];
     FData[i].ShortDesc := AdminSystem.fdFields.fdShort_Name[i];
  end;

  ShowModal;
  if OKPressed then
  begin
     if LoadAdminSystem(true, ThisMethodName ) then
     begin
       for i := 0 to MAX_TRX_TYPE do with AdminSystem.fdFields do
       begin
          fdLong_Name[i] := fData[i].LongDesc;
          fdShort_Name[i]:= fData[i].ShortDesc;
       end;

       SaveAdminsystem;
     end
     else
       HelpfulErrorMsg('Unable to update Transaction Types to the Admin System. Could not lock.',0);
  end;
  result := okPressed;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EditTransactionTypes : boolean;
begin
  result := false;
  if not RefreshAdmin then exit;

  with TDlgTransTypes.Create(Application.MainForm) do begin
    try
      tblTrans.RowLimit := MAX_TRX_TYPE+2;
      result := Execute;
    finally
      Free;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
