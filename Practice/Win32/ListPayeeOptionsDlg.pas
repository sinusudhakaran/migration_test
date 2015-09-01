unit ListPayeeOptionsDlg;
//------------------------------------------------------------------------------
{
   Title:       Options for List Payees Report

   Description:

   Author:      Matthew Hopkins Aug 2002

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  RptParams,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ReportDefs, Buttons,
  OSFont, clObj32, OmniXML;

type
  TListPayeesParam = class (TRPTParameters)
  private
    FRuleLine: boolean;
    FDetailed: boolean;
    FSortBy: integer;
    procedure SetDetailed(const Value: boolean);
    procedure SetRuleLine(const Value: boolean);
    procedure SetSortBy(const Value: integer);
  protected
    procedure LoadFromClient (Value : TClientObj); override;
    procedure SaveToClient   (Value : TClientObj); override;
    procedure ReadFromNode (Value : IXMLNode); override;
    procedure SaveToNode   (Value : IXMLNode); override;
  public
    property Detailed: boolean read FDetailed write SetDetailed;
    property SortBy: integer read FSortBy write SetSortBy;
    property RuleLine: boolean read FRuleLine write SetRuleLine;
  end;

  TdlgListPayeeOptions = class(TForm)
    btnPreview: TButton;
    btnFile: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    btnSave: TBitBtn;
    ckbRuleLineBetweenPayees: TCheckBox;
    rgSortPayeesBy: TRadioGroup;
    rgReportFormat: TRadioGroup;
    btnEmail: TButton;
    BevelBorder: TBevel;

    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
  private
    { Private declarations }
    ReportDest : TReportDest;
    FRptParams: TListPayeesParam;
    procedure SetRptParams(const Value: TListPayeesParam);
  public
    property RptParams: TListPayeesParam read FRptParams write SetRptParams;
    { Public declarations }
  end;

function GetPayeeReportOptions( var Destination : TReportDest;
                                Params : TListPayeesParam ) : Boolean;

implementation

uses
  bkConst,
  OmniXMLUtils,
  bkXPThemes,
  Globals,
  BKHelp;

const
   psNames: array [0..1] of shortstring =('Name','Number');

{$R *.dfm}

function GetPayeeReportOptions( var Destination : TReportDest;
                                Params : TListPayeesParam):Boolean;
var
  ListPayeeOptions : TdlgListPayeeOptions;
begin
  ListPayeeOptions := TdlgListPayeeOptions.Create(Application.MainForm);
  with ListPayeeOptions do
  begin
    try

      if Params.Detailed then
        rgReportFormat.ItemIndex := 1;
      rgSortPayeesBy.ItemIndex := Params.SortBy;
      ckbRuleLineBetweenPayees.Checked := Params.RuleLine;

      RptParams := Params;

      //*************
      ShowModal;
      //*************

      Result := Params.DlgResult;

      if Result then begin
          RptParams.Detailed := (rgReportFormat.ItemIndex = 1);
          RptParams.SortBy := rgSortPayeesBy.ItemIndex;
          RptParams.RuleLine := ckbRuleLineBetweenPayees.Checked;
          if ReportDest = rdNone then
             Destination := rdScreen
          else begin
             Destination := ReportDest;
          end;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TdlgListPayeeOptions.btnPreviewClick(Sender: TObject);
begin
  ReportDest := rdScreen;
  FRptParams.RunBtn := BTN_PREVIEW;
  ModalResult := mrOk;
end;

procedure TdlgListPayeeOptions.BtnSaveClick(Sender: TObject);
begin
   if not RptParams.CheckForBatch then
      Exit;

   RptParams.RunBtn := BTN_SAVE;
   ModalResult := mrYes;
end;

procedure TdlgListPayeeOptions.FormCreate(Sender: TObject);
begin
  BKHelpSetUp(Self, BKH_List_payees);
  bkXPThemes.ThemeForm( Self);

   //favorite reports functionality is disabled in simpleUI
   if Active_UI_Style = UIS_Simple then
      btnSave.Hide;
end;

procedure TdlgListPayeeOptions.SetRptParams(const Value: TListPayeesParam);
begin
  FRptParams := Value;
  if Assigned(FRptParams) then begin
     FRptParams.SetDlgButtons(BtnPreview,BtnFile,BtnEmail,BtnSave,BtnOk);
     if Assigned(FRptParams.RptBatch) then
        Caption := Caption + ' [' + FRptParams.RptBatch.Name + ']';
  end else
     BtnSave.Hide;
end;

procedure TdlgListPayeeOptions.btnEmailClick(Sender: TObject);
begin
  ReportDest := rdEmail;
  FRptParams.RunBtn := BTN_EMAIL;
  ModalResult := mrOK;
end;

procedure TdlgListPayeeOptions.btnFileClick(Sender: TObject);
begin
  ReportDest := rdFile;
  FRptParams.RunBtn := BTN_FILE;
  ModalResult := mrOK;
end;

procedure TdlgListPayeeOptions.btnOKClick(Sender: TObject);
begin
  ReportDest := rdPrinter;
  FRptParams.RunBtn := BTN_PRINT;
  ModalResult := mrOK;
end;

procedure TdlgListPayeeOptions.btnCancelClick(Sender: TObject);
begin
  ReportDest := rdNone;
  ModalResult := mrCancel;
end;

{ TListPayeesParam }

procedure TListPayeesParam.LoadFromClient(Value: TClientObj);
begin
  //Load fields from client
  inherited;
  with Value.clExtra do begin
    Detailed := ceList_Payees_Detailed;
    SortBy   := ceList_Payees_SortBy; //Byte
    RuleLine := ceList_Payees_Rule_Line; //Boolean
  end;
end;

procedure TListPayeesParam.ReadFromNode(Value: IXMLNode);
var S: string;
    I: Integer;
begin
  //Read from XML nodes
  inherited;
  Detailed :=  GetBatchBool('Detailed', Detailed);

  s :=  GetNodeTextStr(Value,'Sort_by',psNames[SortBy]);
  for i := low(psNames) to High(psNames) do
     if SameText(s,psNames[i]) then begin
        SortBy := i;
        Break;
     end;


  RuleLine := GetBatchBool('RuleLine', RuleLine)
           or GetBatchBool('Rule_Line_Between_Payees', RuleLine)
end;

procedure TListPayeesParam.SaveToClient(Value: TClientObj);
begin
  //Save fields to client
  with Value.clExtra do begin
    ceList_Payees_Detailed          := Detailed; //Boolean
    ceList_Payees_SortBy            := SortBy; //Byte
    ceList_Payees_Rule_Line         := RuleLine; //Boolean
  end;
end;

procedure TListPayeesParam.SaveToNode(Value: IXMLNode);
begin
  //Save to XML nodes
  inherited;
  SetBatchBool('Detailed', Detailed);
  SetNodeTextStr(Value,'Sort_by',psNames[Sortby]);
  SetBatchBool('Rule_Line_Between_Payees', RuleLine);
end;

procedure TListPayeesParam.SetDetailed(const Value: boolean);
begin
  FDetailed := Value;
end;

procedure TListPayeesParam.SetRuleLine(const Value: boolean);
begin
  FRuleLine := Value;
end;

procedure TListPayeesParam.SetSortBy(const Value: integer);
begin
  FSortBy := Value;
end;

end.
