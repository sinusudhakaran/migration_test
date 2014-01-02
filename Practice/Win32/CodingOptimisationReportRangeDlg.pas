unit CodingOptimisationReportRangeDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ClientSelectFme, DateSelectorFme, StdCtrls, ReportDefs,
  OSFont;

type
  TCodingOptimisationOptions = class(TObject)
  private
    FClientSelectOptions: TClientSelectOptions;
    FDateTo: integer;
    FDateFrom: integer;
    FDestination: TReportDest;
    procedure SetClientSelectOptions(const Value: TClientSelectOptions);
    procedure SetDateFrom(const Value: integer);
    procedure SetDateTo(const Value: integer);
    procedure SetDestination(const Value: TReportDest);
  public
    constructor Create;
    destructor Destroy; override;
    function ClientInSelection(AClient: Pointer): Boolean;
    function TxnInSelection(ATxn: Pointer): Boolean;
    property DateFrom : integer read FDateFrom write SetDateFrom;
    property DateTo   : integer read FDateTo write SetDateTo;
    property ClientSelectOptions: TClientSelectOptions read FClientSelectOptions
                                                       write SetClientSelectOptions;
    property Destination: TReportDest read FDestination write SetDestination;
  end;

  TdlgCodingOptimisationReportRange = class(TForm)
    btnPreview: TButton;
    btnFile: TButton;
    btnPrint: TButton;
    btnCancel: TButton;
    DateSelector: TfmeDateSelector;
    ClientSelect: TFmeClientSelect;
    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure ClientSelectbtnFromLookupClick(Sender: TObject);
  private
    FBtnPressed : integer;

    function Validate: Boolean;
  public

    constructor Create; reintroduce;
  end;

  function GetCodingOptimisationReportRange(var CodingOptimisationOptions:
                                            TCodingOptimisationOptions): boolean;

implementation

uses
  bkHelp,
  bkXPThemes, SyDefs, BkDefs, BkConst, Globals;

{$R *.dfm}

{ TCodingOptimisationOptions }

function TCodingOptimisationOptions.ClientInSelection(AClient: Pointer): Boolean;
const
  FIRST_REC = '';
  LAST_REC  = 'þ';
var
  Key1, Key2: string[60];
  ClientFileRec: TClient_File_Rec;
  pUser: PUser_Rec;
  pGroup: pGroup_Rec;
  pClientType: pClient_Type_Rec;
  SortByName: string;
begin
  Result := False;
  if Assigned(AClient) then begin
    ClientFileRec := TClient_File_Rec(AClient^);

    if (ClientFileRec.cfClient_Type = ctProspect) then
       Exit;


    //Set keys
    Key1 := FIRST_REC;
    Key2 := LAST_REC;
    if ClientSelectOptions.RangeOption = roRange then begin
      if (ClientSelectOptions.FromCode <> '') then
         Key1 := ClientSelectOptions.FromCode;
      if (ClientSelectOptions.ToCode <> '') then
         Key2 := ClientSelectOptions.ToCode;
      if Key1 > Key2 then begin
         Key1 := Key2;
         Key2 := ClientSelectOptions.FromCode;
      end;
    end;

    //Check if included in selection
    case ClientSelectOptions.ReportSort of
      rsClient:
        begin
          //Client
          Result := ((ClientFileRec.cfFile_Code >= Key1) and (ClientFileRec.cfFile_Code <= Key2) and
                     (ClientSelectOptions.CodeSelectionList.Count = 0)) or
                    (ClientSelectOptions.CodeSelectionList.IndexOf(ClientFileRec.cfFile_Code) > -1)
        end;
      rsByStaffMember:
        begin
          //Staff
          pUser := AdminSystem.fdSystem_User_List.FindLRN(ClientFileRec.cfUser_Responsible);
          if Assigned(pUser) then
            Result := ((pUser^.usCode >= Key1) and (pUser^.usCode <= Key2) and
                       (ClientSelectOptions.RangeOption <> roSelection)) or
                      (ClientSelectOptions.CodeSelectionList.IndexOf(pUser^.usCode) > -1)
          else
            //no user record exists,  see if should include unallocated clients.
            //If the to code is blank then we include unallocated clients
            Result := (Key2 = LAST_REC) and
                      ((ClientSelectOptions.CodeSelectionList.Count = 0) or
                       (ClientSelectOptions.CodeSelectionList.IndexOf(' ') > -1));
        end;
      rsGroup:
        begin
          //Group
          pGroup := AdminSystem.fdSystem_Group_List.FindLRN(ClientFileRec.cfGroup_LRN);
          if Assigned (pGroup) then begin
            SortByName := UpperCase(pGroup.grName);
            Result := ((SortByName >= Key1) and (SortByName <= Key2) and
                       (ClientSelectOptions.RangeOption <> roSelection)) or
                      (ClientSelectOptions.CodeSelectionList.IndexOf(SortByName) > -1)
          end else
            Result := (Key2 = LAST_REC) and
                      ((ClientSelectOptions.CodeSelectionList.Count = 0) or
                       (ClientSelectOptions.CodeSelectionList.IndexOf(' ') > -1));
        end;
      rsClientType:
        begin
          //Client type
          pClientType := AdminSystem.fdSystem_Client_Type_List.FindLRN(ClientFileRec.cfClient_Type_LRN);
          if Assigned(pClientType) then begin
            SortByName := UpperCase(pClientType.ctName);
            Result := ((SortByName >= Key1) and (SortByName <= Key2) and
                       (ClientSelectOptions.RangeOption <> roSelection)) or
                      (ClientSelectOptions.CodeSelectionList.IndexOf(SortByName) > -1)
          end else
            Result := (Key2 = LAST_REC) and
                      ((ClientSelectOptions.CodeSelectionList.Count = 0) or
                       (ClientSelectOptions.CodeSelectionList.IndexOf(' ') > -1));
        end;
    end;
  end;
end;

constructor TCodingOptimisationOptions.Create;
begin
  inherited;
  FClientSelectOptions := TClientSelectOptions.Create;
end;

destructor TCodingOptimisationOptions.Destroy;
begin
  FClientSelectOptions.Free;
  inherited;
end;

procedure TCodingOptimisationOptions.SetClientSelectOptions(
  const Value: TClientSelectOptions);
begin
  FClientSelectOptions := Value;
end;

procedure TCodingOptimisationOptions.SetDateFrom(const Value: integer);
begin
  FDateFrom := Value;
end;

procedure TCodingOptimisationOptions.SetDateTo(const Value: integer);
begin
  FDateTo := Value;
end;

procedure TCodingOptimisationOptions.SetDestination(const Value: TReportDest);
begin
  FDestination := Value;
end;

function TCodingOptimisationOptions.TxnInSelection(ATxn: Pointer): Boolean;
var
  TxnRec: TTransaction_Rec;
begin
  Result := False;
  if Assigned(ATxn) then begin
    TxnRec := TTransaction_Rec(ATxn^);
    if (TxnRec.txDate_Effective >= DateFrom) and
       (TxnRec.txDate_Effective <= DateTo) then
      Result := True;
  end;
end;

function GetCodingOptimisationReportRange(var CodingOptimisationOptions: TCodingOptimisationOptions): boolean;
var
  dlgCodingOptimisationReportRange: TdlgCodingOptimisationReportRange;
begin
  dlgCodingOptimisationReportRange := TdlgCodingOptimisationReportRange.Create;
  try
    with dlgCodingOptimisationReportRange do begin
      //set the initial data
      DateSelector.eDateFrom.AsStDate := CodingOptimisationOptions.DateFrom;
      DateSelector.eDateTo.AsStDate   := CodingOptimisationOptions.DateTo;
      ClientSelect.ReportSort := CodingOptimisationOptions.ClientSelectOptions.ReportSort;
      ClientSelect.RangeOption :=  CodingOptimisationOptions.ClientSelectOptions.RangeOption;

      ClientSelect.edtFromCode.Text  := CodingOptimisationOptions.ClientSelectOptions.FromCode;
      ClientSelect.edtToCode.Text    := CodingOptimisationOptions.ClientSelectOptions.ToCode;
      ClientSelect.edtSelection.Text := CodingOptimisationOptions.ClientSelectOptions.CodeSelectionList.DelimitedText;

      ShowModal;
      if FBtnPressed in [BTN_PREVIEW, BTN_PRINT, BTN_FILE] then begin
        with CodingOptimisationOptions do begin
          DateFrom  := DateSelector.eDateFrom.AsStDate;
          DateTo    := DateSelector.eDateTo.AsStDate;
          ClientSelectOptions.ReportSort := ClientSelect.ReportSort;
          ClientSelectOptions.RangeOption := ClientSelect.RangeOption;
          ClientSelectOptions.FromCode := ClientSelect.edtFromCode.Text;
          ClientSelectOptions.ToCode := ClientSelect.edtToCode.Text;
          ClientSelectOptions.CodeSelectionList.DelimitedText := ClientSelect.edtSelection.Text;
          case FBtnPressed of
            BTN_PREVIEW :  Destination := rdScreen;
            BTN_PRINT   :  Destination := rdPrinter;
            BTN_FILE    :  Destination := rdFile;
          else
            Destination := rdNone;
          end;
        end;
      end;
      Result := True;
    end;
  finally
    dlgCodingOptimisationReportRange.Free;
  end;
end;

{ TdlgCodingOptimisationReportRange }

procedure TdlgCodingOptimisationReportRange.btnCancelClick(Sender: TObject);
begin
  FBtnPressed := BTN_NONE;
  Close;
end;

procedure TdlgCodingOptimisationReportRange.btnFileClick(Sender: TObject);
begin
  if not Validate then
     Exit;
  FBtnPressed := BTN_FILE;
  Close;
end;

procedure TdlgCodingOptimisationReportRange.btnPreviewClick(Sender: TObject);
begin
  if not Validate then
     Exit;
  FBtnPressed := BTN_PREVIEW;
  Close;
end;

procedure TdlgCodingOptimisationReportRange.btnPrintClick(Sender: TObject);
begin
  if not Validate then
     Exit;
  FBtnPressed := BTN_PRINT;
  Close;
end;

procedure TdlgCodingOptimisationReportRange.ClientSelectbtnFromLookupClick(
  Sender: TObject);
begin
  ClientSelect.btnFromLookupClick(Sender);
end;

constructor TdlgCodingOptimisationReportRange.Create;
begin
  inherited Create(Application.MainForm);
  bkXPThemes.ThemeForm(Self);
  self.HelpContext := BKH_Coding_Optimisation_Report;
  //set date bounds to first and last trx date
  DateSelector.InitDateSelect(MinValidDate, MaxValidDate, btnPreview);
  DateSelector.eDateFrom.asStDate := -1;
  DateSelector.eDateTo.asStDate   := -1;
  DateSelector.Last2Months1.Visible := False;
  DateSelector.btnQuik.Visible := true;
end;



function TdlgCodingOptimisationReportRange.Validate: Boolean;
begin
   Result := False;
   if not DateSelector.ValidateDates(true) then
      Exit;

   if not ClientSelect.Validate(True) then
      Exit;

   Result := True;   
end;

end.
