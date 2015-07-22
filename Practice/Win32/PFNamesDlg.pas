//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unit PFNamesDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcTCEdt, OvcTCmmn, OvcTCell, OvcTCStr, OvcTCHdr, OvcBase, OvcTable,
  StdCtrls, ExtCtrls, PRHead, ovcConst, OSFont;

type
  TdlgPRNames = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    OvcController1: TOvcController;
    OvcTCColHead1: TOvcTCColHead;
    btnRestore: TButton;
    tcDefault: TOvcTCString;
    tcUser: TOvcTCString;
    btnCopy: TButton;
    tbNames: TOvcTable;
    Label1: TLabel;

    procedure tbNamesGetCellData(Sender: TObject; RowNum,
      ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure FormCreate(Sender: TObject);
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
    OkPressed : Boolean;
    EditMode  : Boolean;
    LastRow  : Integer;
    procedure SetUpHelp;
  public
    { Public declarations }
    UserDef : array[phdMin..phdMax] of String[40];
    function Execute : boolean;
  end;


procedure SetupPRNames;

//******************************************************************************
implementation

uses
  bkConst,
  bkdefs,
  BKHelp,
  bkXPThemes,
  CopyFromDlg,
  clObj32,
  files,
  globals,
  progress,
  WarningMorefrm, bkBranding;

{$R *.DFM}

const
  tcDeleteCell     = ccUserFirst + 1;

const
  //this allows us to display the items in a different order to the definitions
  //note that not all of the headings are displayed
  phMin = 0;
  phMax = 18;

  phDisplayOrder : Array[ phMin..phMax ] of byte = (
                                              phdProfit_And_Loss,
                                              phdBlank, //separator
                                              phdIncome,
                                              phdTotal_Income,
                                              phdLess_Direct_Expenses,
                                              phdCOGS,
                                              phdTotal_COGS,
                                              phdOther_Direct_Expenses,
                                              phdTotal_Other_Direct_Expenses,                                              
                                              phdTotal_Direct_Expenses,
                                              phdGross_Profit_or_Loss,
                                              phdExpenses,
                                              phdTotal_Expenses,
                                              phdOperating_Profit,
                                              phdOther_Income,
                                              phdTotal_Other_Income,
                                              phdLess_Other_Expenses,
                                              phdTotal_Other_Expenses,
                                              phdNet_Trading_Profit_Or_Loss
                                              );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPRNames.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  OvcTCColHead1.Font.Style := [fsBold];
  tbNames.RowLimit := phMax + 2;
  EditMode := false;
  with tbNames.Controller.EntryCommands do begin
    {remove F2 functionallity}
    DeleteCommand('Grid',VK_F2,0,0,0);
    DeleteCommand('Grid',VK_DELETE,0,0,0);

    {add our commands}
    AddCommand('Grid',VK_F6,0,0,0,ccTableEdit);
    AddCommand('Grid',VK_DELETE,0,0,0,tcDeleteCell);
  end;

  bkBranding.StyleOvcTableGrid(tbNames);
  bkBranding.StyleTableHeading(OvcTCColHead1);

  SetUpHelp;
  LastRow := tbNames.ActiveRow;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPRNames.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   btnRestore.Hint :=
      'Restore the default Report Headings|'+
      'Restore the default Profit and Loss Report Headings';
   btnCopy.Hint    :=
      'Copy user defined Report Headings from another Client|'+
      'Copy user defined Profit and Loss Report Headings from another Client File';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPRNames.tbNamesGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
begin
  data := nil;
  if not Assigned(myClient) then exit;

  if (RowNum > 0) and (RowNum <= tbNames.RowLimit) then
  case ColNum of
    0: data := @phdNames[ phDisplayOrder[ RowNum-1]];

    1: data := @UserDef[RowNum-1];
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPRNames.btnOkClick(Sender: TObject);
begin
   tbNames.StopEditingState(true);
   okPressed := true;
   close;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPRNames.btnCancelClick(Sender: TObject);
begin
   close;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPRNames.btnRestoreClick(Sender: TObject);
var
  i : integer;
begin
  tbNames.StopEditingState(true);
  for i := phMin to phMax do
    UserDef[i] := '';

  tbNames.Refresh;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPRNames.tbNamesBeginEdit(Sender: TObject; RowNum,
  ColNum: Integer; var AllowIt: Boolean);
begin
  EditMode := true;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPRNames.tbNamesDoneEdit(Sender: TObject; RowNum,
  ColNum: Integer);
begin
   EditMode := false;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPRNames.tbNamesExit(Sender: TObject);
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
procedure TdlgPRNames.tbNamesUserCommand(Sender: TObject; Command: Word);
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
procedure TdlgPRNames.btnCopyClick(Sender: TObject);
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
     for i := phMin to phMax do
     begin
       UserDef[i] := FromClient.clFields.clPR_Headings[ phDisplayOrder[i]];
     end;

   finally
     CloseAClient(FromClient);
     FromClient := nil;
     Progress.ClearStatus;

     tbNames.Refresh;
   end;
 end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPRNames.tbNamesEnter(Sender: TObject);
begin
   btnOk.Default    := false;
   btnCancel.Cancel := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgPRNames.Execute: boolean;
begin
   okPressed := false;
   tbNames.ActiveRow := tbNames.LockedRows;
   Self.ShowModal;
   result := okPressed;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetupPRNames;
var
  MyDlg : TdlgPRNames;
  i : integer;
begin
  if not Assigned(MyClient) then exit;

  MyDlg := TdlgPRNames.Create(Application.MainForm);
  with MyDlg do begin
     try
       BKHelpSetup(MyDlg, BKH_Changing_and_hiding_report_titles_and_headings);
       tbNames.Cells.Color[0, 0] := clBtnFace;
       tbNames.Cells.Color[0, 1] := clBtnFace;
       for i := phMin to phMax do
       begin
         UserDef[i] := MyClient.clFields.clPR_Headings[ phDisplayOrder[i]];
         if (phDisplayOrder[i] = phdBlank) then
         begin
           tbNames.Cells.Access[i+tbNames.LockedRows, 0] := otxInvisible;
           tbNames.Cells.Access[i+tbNames.LockedRows, 1] := otxInvisible;
           tbNames.Cells.Color[i+tbNames.LockedRows, 0] := clBtnFace;
           tbNames.Cells.Color[i+tbNames.LockedRows, 1] := clBtnFace;
         end;
       end;

       if Execute then begin
         for i := phMin to phMax do
         begin
           if (phDisplayOrder[i] <> phdBlank) then
             MyClient.clFields.clPR_Headings[ phdisplayOrder[i]] := UserDef[i];
         end;
       end;
     finally
       Free;
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgPRNames.tbNamesLeavingRow(Sender: TObject; RowNum: Integer);
begin
  LastRow := RowNum;
end;

//------------------------------------------------------------------------------
//
// tbNamesEnteringRow
//
// Checks if the row is invisible and skips over it if it is.
//
procedure TdlgPRNames.tbNamesEnteringRow(Sender: TObject; RowNum: Integer);
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
