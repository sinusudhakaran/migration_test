//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unit CFNamesDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcTCEdt, OvcTCmmn, OvcTCell, OvcTCStr, OvcTCHdr, OvcBase, OvcTable,
  StdCtrls, ExtCtrls, cfHead, ovcConst,
  OsFont;

type
  TdlgCFNames = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    tbNames: TOvcTable;
    OvcController1: TOvcController;
    OvcTCColHead1: TOvcTCColHead;
    btnRestore: TButton;
    tcDefault: TOvcTCString;
    tcUser: TOvcTCString;
    btnCopy: TButton;
    Label1: TLabel;
    ShapeBorder: TShape;

    procedure tbNamesGetCellData(Sender: TObject; RowNum,
      ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnRestoreClick(Sender: TObject);
    procedure tbNamesBeginEdit(Sender: TObject; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tbNamesDoneEdit(Sender: TObject; RowNum, ColNum: Integer);
    procedure tbNamesExit(Sender: TObject);
    procedure tbNamesUserCommand(Sender: TObject; Command: Word);
    procedure btnCopyClick(Sender: TObject);
    procedure tbNamesEnter(Sender: TObject);
    procedure tbNamesLeavingRow(Sender: TObject; RowNum: Integer);
    procedure tbNamesEnteringRow(Sender: TObject; RowNum: Integer);
  private
    { Private declarations }
    okPressed : boolean;
    EditMode : boolean;
    LastRow  : Integer;
  public
    { Public declarations }
    UserDef : array[hdMin..hdMax] of String[40];
    function Execute : boolean;
  end;


procedure SetupCFNames;

//******************************************************************************
implementation

uses
  globals,
  bkdefs,
  BKHelp,
  bkXPThemes,
  Progress,
  CopyFromDlg,
  clObj32,
  files,
  WarningMorefrm,
  bkConst, bkBranding;

{$R *.DFM}

const
    tcDeleteCell     = ccUserFirst + 1;

const
   chdMin  = hdMin;
   chdMax  = hdMax - 2;  //don't show Net GST Movement and Bank Account Summary


   //this allows us to display the items in a different order to the definitions
   hdDisplayOrder : Array[ chdMin..chdMax ] of byte =
                    (
                     hdCash_Flow,
                     hdBlank, //separator
                     hdIncome,
                     hdTotal_Income,
                     hdLess_Direct_Expenses,
                     hdTotal_Direct_Expenses,
                     hdGross_Profit_or_Loss,
                     hdLess_Expenses,
                     hdTotal_Expenses,
                     hdNet_Trading_Profit_Or_Loss,
                     hdPlus_Other_Deposits,
                     hdTotal_Other_Deposits,
                     hdLess_Other_Withdrawals,
                     hdTotal_Other_Withdrawals,
                     hdLess_Capital_Development,
                     hdTotal_Capital_Development,
                     hdLess_Equity,
                     hdTotal_Equity,
                     hdGST_Movements,
                     hdNet_GST,
                     hdUncoded_Deposits,
                     hdUncoded_Withdrawals,
                     hdNet_Cash_Movement_In_Out,

                     hdCashbook_Balances,
                     hdOpening_Balance,
                     hdPlus_Movement,
                     hdClosing_Balance,
                     hdExchangeGainLoss
                    );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCFNames.tbNamesGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
begin
  data := nil;
  if not Assigned(myClient) then exit;

  if (RowNum > 0) and (RowNum <= tbNames.RowLimit) then
  case ColNum of
    0: data := @hdNames[ hdDisplayOrder[ RowNum-1]];

    1: data := @UserDef[RowNum-1];
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCFNames.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  OvcTCColHead1.Font.Style := [fsBold];
  tbNames.RowLimit := chdMax + 2;
  EditMode := false;

  with tbNames.Controller.EntryCommands do begin
    {remove F2 functionallity}
    DeleteCommand('Grid',VK_F2,0,0,0);
    DeleteCommand('Grid',VK_DELETE,0,0,0);

    {add our commands}
    AddCommand('Grid',VK_F6,0,0,0,ccTableEdit);
    AddCommand('Grid',VK_DELETE,0,0,0,tcDeleteCell);
  end;
  SetUpHelp;

  bkBranding.StyleOvcTableGrid(tbNames);
  bkBranding.StyleTableHeading(OvcTCColHead1);

  LastRow := tbNames.ActiveRow;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCFNames.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := BKH_Changing_and_hiding_report_titles_and_headings;
   //Components
   btnRestore.Hint :=
                   'Restore default Report Headings|' +
                   'Restore the default Cash Flow Report Headings';
   btnCopy.Hint    :=
                   'Copy Report Headings from another Client File|' +
                   'Copy the user defined Cash Flow Report Headings from another Client File';
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetupCFNames;
var
  MyDlg : TdlgCFNames;
  i : integer;
begin
  if not Assigned(MyClient) then exit;

  MyDlg := TdlgCFNames.Create(Application.MainForm);
  try
    MyDlg.tbNames.Cells.Color[0, 0] := clBtnFace;
    MyDlg.tbNames.Cells.Color[0, 1] := clBtnFace;
    for i := chdMin to chdMax do
    begin
      MyDlg.UserDef[i] := MyClient.clFields.clCF_Headings[ hdDisplayOrder[i]];
      if (hdDisplayOrder[i] = hdBlank) then
      begin
        MyDlg.tbNames.Cells.Access[i+MyDlg.tbNames.LockedRows, 0] := otxInvisible;
        MyDlg.tbNames.Cells.Access[i+MyDlg.tbNames.LockedRows, 1] := otxInvisible;
        MyDlg.tbNames.Cells.Color[i+MyDlg.tbNames.LockedRows, 0] := clBtnFace;
        MyDlg.tbNames.Cells.Color[i+MyDlg.tbNames.LockedRows, 1] := clBtnFace;
      end;
    end;

     if MyDlg.execute then
     begin
       for i := chdMin to chdMax do
       begin
         if (hdDisplayOrder[i] <> hdBlank) then
         MyClient.clFields.clCF_Headings[ hdDisplayOrder[i]] := MyDlg.UserDef[i];
       end;
     end;
  finally
    MyDlg.Free;
  end;

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgCFNames.Execute: boolean;
begin
   okPressed := false;
   tbNames.ActiveRow := tbNames.LockedRows;
   Self.ShowModal;
   result := okPressed;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCFNames.btnOkClick(Sender: TObject);
begin
   tbNames.StopEditingState(true);
   okPressed := true;
   close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCFNames.btnCancelClick(Sender: TObject);
begin
   close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCFNames.btnRestoreClick(Sender: TObject);
var
  i : integer;
begin
  tbNames.StopEditingState(true);
  for i := chdMin to chdMax do
     UserDef[i] := '';

  tbNames.Refresh;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCFNames.tbNamesBeginEdit(Sender: TObject; RowNum,
  ColNum: Integer; var AllowIt: Boolean);
begin
  EditMode := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCFNames.tbNamesDoneEdit(Sender: TObject; RowNum,
  ColNum: Integer);
begin
   EditMode := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCFNames.tbNamesExit(Sender: TObject);
var
  Msg : TWMKey;
begin
  {lost focus so finalise edit if in edit mode}
   if EditMode then
   begin
      Msg.CharCode := vk_f6;
      tcUser.SendKeyToTable(Msg);
   end;

   btnOk.Default := true;
   btnCancel.Cancel := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCFNames.tbNamesUserCommand(Sender: TObject; Command: Word);
begin
  case Command of
    tcDeleteCell : begin
                    if EditMode then exit;
                    Keybd_event(VK_SPACE,0,0,0);
                    Keybd_event(VK_BACK ,0,0,0);
                    Keybd_event(VK_F6   ,0,0,0);
                  end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCFNames.btnCopyClick(Sender: TObject);
//copys the report heading from another client.  overwrites any existing headings.
var
  Code : string;
  FromClient : TClientObj;
  i : integer;
begin
  if SelectCopyFrom('Copy Headings from...',Code) then
  begin
   FromClient := nil;
   OpenAClient(Code,FromClient,false);
   try
     if not Assigned(FromClient) then
     begin
       HelpfulWarningMsg('Unable to open client '+code,0);
       exit;
     end;

     //have both clients open, begin copying..
     tbNames.StopEditingState(true);     
     for i := chdMin to chdMax do
     begin
       UserDef[i] := FromClient.clFields.clCF_Headings[ hdDisplayOrder[i]];
     end;

   finally
     CloseAClient(FromClient);
     FromClient := nil;
     ClearStatus;

     tbNames.Refresh;
   end;
 end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCFNames.tbNamesEnter(Sender: TObject);
begin
   btnOk.Default    := false;
   btnCancel.Cancel := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCFNames.tbNamesLeavingRow(Sender: TObject; RowNum: Integer);
begin
  LastRow := RowNum;
end;

//------------------------------------------------------------------------------
//
// tbNamesEnteringRow
//
// Checks if the row is invisible and skips over it if it is.
//
procedure TdlgCFNames.tbNamesEnteringRow(Sender: TObject; RowNum: Integer);
begin
  if (tbNames.Cells.Access[RowNum, 0] = otxInvisible) then
  begin
    //skip over invisible rows
    if (LastRow < tbNames.ActiveRow) then
    begin
      if (RowNum < tbNames.RowLimit) then
        tbNames.ActiveRow := RowNum + 1
    end else
    begin
      if (RowNum > tbNames.LockedRows) then
        tbNames.ActiveRow := RowNum - 1;
    end;
  end;
end;

end.
