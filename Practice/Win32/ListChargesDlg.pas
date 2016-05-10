unit ListChargesDlg;
//------------------------------------------------------------------------------
{
   Title: List Charges Dialog

   Description: Dialog for running the List Charges Report

   Author: Scott Wilson  Oct 2008

   Remarks: There is some duplication between this code and ExportChargesFrm.pas

}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OsFont, ExtCtrls;

const
  // These columns match the fields in csv file
  colListChargesPractice      = 0;
  colListChargesAcctNo        = 1;
  colListChargesAcctName      = 2;
  colListChargesFileCode      = 3;
  colListChargesCostCode      = 4;
  colListChargesCharge        = 5;
  colListChargesNoOfTxns      = 6;
  colListChargesNew           = 7;
  colListChargesLoadCharge    = 8;
  colListChargesOffsiteCharge = 9;
  // These are from the admin bank account
  colListChargesClientID      = 10;
  colListChargesMatterID      = 11;
  colListChargesAssignment    = 12;
  colListChargesDisbursement  = 13;

type
  TChargesList = class(TObject)
  private
    FCharges: TStringList;
    FPracticeMgmtSys: byte;
    function GetCount: integer;
    function GetLine(Index: Integer): TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(FileName: string);
    property Count: integer read GetCount;
    property Lines[Index: Integer]: TStringList read GetLine;
  end;

  TdlgListCharges = class(TForm)
    cmbMonths: TComboBox;
    lblShowCharges: TLabel;
    pnlControls: TPanel;
    btnPreview: TButton;
    btnFile: TButton;
    btnPrint: TButton;
    btnCancel: TButton;
    Shape1: TShape;
    procedure btnCancelClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure cmbMonthsChange(Sender: TObject);
    procedure cmbMonthsDrawItem(Control: TWinControl; Index: Integer;
                                Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FChargesList: TChargesList;
    FPracticeMgmtSys: byte;
    function CurrentMonthWorkFileExists(var Filename: string): Boolean;
    procedure LoadChargesFileList;
    procedure SetPracticeMgmtSys(const Value: byte);
  public
    { Public declarations }
    property PracticeMgmtSys: byte read FPracticeMgmtSys write SetPracticeMgmtSys;
  end;

  procedure DoListChargesReport(PracticeMgmtSys: byte);

implementation

uses
  bkConst,
  GlobalDirectories,
  imagesfrm,
  ReportDefs,
  rptAdmin,
  ReportImages,
  SYDEFS,
  ErrorMoreFrm,
  ReportFileFormat,
  Globals,
  WinUtils;

{$R *.dfm}

function ConvertToHandiNumber(s: string; maxVal, maxWidth: Integer): string;
var
  x: Integer;
begin
  x := StrToIntDef(s, -1);
  if (x <= 0) or (x > maxVal) then
    Result := ''
  else if Length(s) = maxWidth-2 then
    Result := '00' + s
  else if Length(s) = maxwidth-1 then
    Result := '0' + s
  else
    Result := Copy(s, 1, maxWidth)
end;

procedure DoListChargesReport(PracticeMgmtSys: byte);
var
  dlgListCharges: TdlgListCharges;
begin
  dlgListCharges := TdlgListCharges.Create(Application.MainForm);
  try
    dlgListCharges.PracticeMgmtSys := PracticeMgmtSys;
    // Don't display if no charges data is available
    if dlgListCharges.cmbMonths.Items.Count = 0 then
      HelpfulErrorMsg('There is no charges information available.', 0)
    else
      dlgListCharges.ShowModal;
  finally
    dlgListCharges.Release;
  end;
end;

procedure TdlgListCharges.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TdlgListCharges.btnFileClick(Sender: TObject);
var
  Dest: TReportDest;
begin
  Dest := rdFile;
  CreateReportImageList;
  try
     DoListCharges(Dest, FChargesList, FPracticeMgmtSys, cmbMonths.Text);
  finally
     DestroyReportImageList;
  end;
end;

procedure TdlgListCharges.btnPreviewClick(Sender: TObject);
var
  Dest: TReportDest;
begin
  Dest := rdScreen;
  CreateReportImageList;
  try
     DoListCharges(Dest, FChargesList, FPracticeMgmtSys, cmbMonths.Text);
  finally
     DestroyReportImageList;
  end;
end;

procedure TdlgListCharges.btnPrintClick(Sender: TObject);
var
  Dest: TReportDest;
begin
  Dest := rdPrinter;
  CreateReportImageList;
  try
     DoListCharges(Dest, FChargesList, FPracticeMgmtSys, cmbMonths.Text);
  finally
     DestroyReportImageList;
  end;
end;

procedure TdlgListCharges.cmbMonthsChange(Sender: TObject);
var
  FileName: string;
begin
  if not CurrentMonthWorkFileExists(Filename) then exit;
  FChargesList.LoadFromFile(FileName);
end;

procedure TdlgListCharges.cmbMonthsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  // This ensures the correct highlite color is used
  cmbMonths.canvas.fillrect(rect);
  // This line draws the actual bitmap
  AppImages.Misc.Draw(cmbMonths.Canvas, rect.left, rect.top + 2, 10);
  // This line writes the text after the bitmap
  cmbMonths.canvas.textout(rect.left + AppImages.Misc.Width +  2 ,
                           rect.top + 2,
                           cmbMonths.Items[Index]);
end;

function TdlgListCharges.CurrentMonthWorkFileExists(
  var Filename: string): Boolean;
var
  Month: Integer;
begin
  Month := Integer(cmbMonths.Items.Objects[cmbMonths.ItemIndex]);
  Filename := DownloadWorkDir +
    FormatDateTime('mmmyyyy', IncMonth(Date, -Month)) + RptFileFormat.Extensions[rfCSV];
  Result := BKFileExists(Filename);
end;

procedure TdlgListCharges.FormCreate(Sender: TObject);
begin
  FChargesList := TChargesList.Create;
  LoadChargesFileList;
end;

procedure TdlgListCharges.FormDestroy(Sender: TObject);
begin
  FChargesList.Free;
end;

procedure TdlgListCharges.FormShow(Sender: TObject);
begin
  if cmbMonths.Items.Count > 0 then begin
    cmbMonths.ItemIndex := 0;
    cmbMonthsChange(Sender);
  end;
end;

procedure TdlgListCharges.LoadChargesFileList;
const
  MAX_MONTHS_TO_SHOW = 15;
  MAX_MONTHS_TO_SEARCH = 36;
var
  D: TDate;
  m, s: Integer;
  Filename: string;
begin
  // List last 15 months and select this month
  cmbMonths.Items.Clear;
  D := Date;
  m := 0;
  s := 0;
  while (m < MAX_MONTHS_TO_SHOW) and (s < MAX_MONTHS_TO_SEARCH) do
  begin
    Filename := DownloadWorkDir + FormatDateTime('mmmyyyy', D) + RptFileFormat.Extensions[rfCSV];
    if BKFileExists(Filename) then
    begin
      cmbMonths.Items.AddObject(FormatDateTime('mmmm', D) + ' ' +
                                FormatDateTime('yy', D), TObject(s));
      Inc(m);
    end;
    Inc(s);
    D := IncMonth(D, -1);
  end;
  if cmbMonths.Items.Count > 0 then
    cmbMonths.ItemIndex := 0;
end;


procedure TdlgListCharges.SetPracticeMgmtSys(const Value: byte);
begin
  FPracticeMgmtSys := Value;
  FChargesList.FPracticeMgmtSys := FPracticeMgmtSys;
end;

{ TChargesList }

constructor TChargesList.Create;
begin
  FCharges := TStringList.Create;
end;

destructor TChargesList.Destroy;
var
  i: integer;
begin
  // Free objects in list
  for i := 0 to FCharges.Count - 1 do
    if Assigned(FCharges.Objects[i]) then
      TStringList(FCharges.Objects[i]).Free;
  // Free the list
  FCharges.Free;

  inherited;
end;

function TChargesList.GetCount: integer;
begin
  Result := FCharges.Count;
end;

function TChargesList.GetLine(Index: Integer): TStringList;
begin
  Result := TStringList(FCharges.Objects[Index]);
end;

procedure TChargesList.LoadFromFile(FileName: string);
var
  i, x: integer;
  Line: TStringList;
  pS: pSystem_Bank_Account_Rec;

  procedure MyCommaText(List: TStringList; Line: string);
  var P: Integer;
      Lookfor: string;
      procedure Add(Value: string);
      begin
         while (Length(Value) > 0)
         and (value[1] in ['"',',',#1..' ']) do
            Value := Copy(Value,2,Length(Value));
         while (Length(Value) > 0)
         and (Value[Length(Value)] in [',','"',#1..' ']) do
            Value := Copy(Value,1,Length(Value)-1);

         List.Add(Value);
      end;
  begin
     List.BeginUpdate;
     try
        List.Clear;
        repeat
           if (Line > '')
           and (Line[1] = '"') then
              Lookfor := '",'
           else
              Lookfor := ',';

           P := Pos(LookFor,Line);
           if P > 0 then begin
              add(Copy(Line,1,P));
              Line := Copy(Line,P + Length(LookFor),Length(Line));
           end else begin
              add(Line); // Last one
              Line := '';
           end;{end;}
        until line = '';

     finally
        List.EndUpdate;
     end;
  end;

begin
  try
    FCharges.LoadFromFile(Filename);
  except on E: Exception do
    begin
      HelpfulErrorMsg(Format('The file %s%s%s cannot be accessed.%s' +
                             'If you have this file open in another ' +
                             'application, such as Microsoft Excel, ' +
                             'please close it.',
                             [#13#13, Filename, #13#13, #13#13]), 0);
      Exit;
    end;
  end;

  // Remove headers before sorting
  FCharges.Delete(0);
  FCharges.Sort;
  for i := 1 to FCharges.Count do begin
    Line := TStringList.Create;
    try
      Line.CommaText := FCharges[i-1];
      MyCommaText(Line, FCharges[i-1]);

      //Add extra fields not in the file
      while pred(Line.Count) < colListChargesDisbursement do
         Line.Add('');

      // Now overwrite with system info
      pS := AdminSystem.fdSystem_Bank_Account_List.FindCode(Line[colListChargesAcctNo]);
      // Copy previous values
      if Assigned(pS) then begin
        if pS.sbFile_Code <> '' then
          Line[colListChargesFileCode] := pS.sbFile_Code;
        if pS.sbCost_Code <> '' then
          Line[colListChargesCostCode] := pS.sbCost_Code;



        //This code is copies from ExportChargesFrm.pas
        case FPracticeMgmtSys of
          xcAPS:
            begin
              //Client ID
              x := Pos(' ', pS.sbClient_ID);
              if x > 0 then
                Line[colListChargesClientID] :=
                  Copy(pS.sbClient_ID, x + 1, Length(pS.sbClient_ID));
              //Matter ID
              x := Pos(' ', pS.sbMatter_ID);
              if x > 0 then
                Line[colListChargesMatterID] :=
                  Copy(pS.sbMatter_ID, x + 1, Length(pS.sbMatter_ID));
            end;
          xcMYOB:
            begin
              Line[colListChargesAssignment] := pS.sbAssignment_ID;
              Line[colListChargesDisbursement] := pS.sbDisbursement_ID;
            end;
          xcMYOBAO:
            begin
              Line[colListChargesAssignment] := pS.sbJob_Code;
              // Must trim for MYOB AO
              Line[colListChargesCostCode] := Copy(Line[colListChargesCostCode], 1, 7);
            end;
          xcHandi:
            begin
              Line[colListChargesAssignment] := Line[colListChargesCostCode];
              Line[colListChargesCostCode] := pS.sbActivity_Code;
              // Must trim for HandiSoft
              Line[colListChargesFileCode] := Copy(Line[colListChargesFileCode], 1, 8);
              Line[colListChargesCostCode] := ConvertToHandiNumber(Line[colListChargesCostCode], 99, 2);
              Line[colListChargesAssignment] := ConvertToHandiNumber(Line[colListChargesAssignment], 999, 3);
            end;
        end;
      end else begin

      end;
      FCharges.Objects[i - 1] := TObject(Line);
    except
      on E: Exception do
        begin
          HelpfulErrorMsg(Format('The file %s%s%s is not a valid %s charges ' +
                                 'file.%sError: %s%s in line %d%s%s',
                                 [#13#13, Filename, #13#13,SHORTAPPNAME, #13#13,
                                  E.Message, #13, i, #13, Line.CommaText]), 0);
          Line.Free;
        end;
    end;
  end;
end;

end.

