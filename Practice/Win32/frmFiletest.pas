unit frmFiletest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TFileTestForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    lbStatus: TListBox;
    TestTimer: TTimer;
    btnOnce: TButton;
    btnCont: TButton;
    Button3: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblTested: TLabel;
    lblFailed: TLabel;
    lblPassed: TLabel;
    Label4: TLabel;
    lblTesting: TLabel;
    cbFailed: TCheckBox;
    cbPassed: TCheckBox;
    btnClear: TButton;
    btnClearList: TButton;
    Label5: TLabel;
    lblMode: TLabel;
    procedure TestTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOnceClick(Sender: TObject);
    procedure btnContClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnClearListClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FCodeList: TStringList;
    FError: string;

    FCur: Integer;
    FSuccessCount: Integer;
    FFailCount: Integer;
    FContinuous: Boolean;
    FBackFile: Boolean;
    FLFailCount: Integer;
    FLSuccessCount: Integer;
    function CheckFile(Filename: string):Boolean;
    procedure AddStatus(const Value: string; LogAlso : Boolean = False);
    procedure SetFailCount(const Value: Integer);
    procedure SetSuccessCount(const Value: Integer);
    procedure SetLFailCount(const Value: Integer);
    procedure SetLSuccessCount(const Value: Integer);
    { Private declarations }
  public
    { Public declarations }
    procedure startTest;
    property SuccessCount: Integer read FSuccessCount write SetSuccessCount;
    property LSuccessCount: Integer read FLSuccessCount write SetLSuccessCount;
    property FailCount: Integer read FFailCount write SetFailCount;
    property LFailCount: Integer read FLFailCount write SetLFailCount;
  end;

  procedure ShowFileTestForm;

implementation

uses Admin32, bkConst, LogUtil, CRCFileUtils, Globals, SysObj32;

{$R *.dfm}

{ TForm2 }


const
  UnitName = 'CRCFileTest';
  MaxList = 50000;

var
  FFileTestForm: TFileTestForm;

function FileTestForm: TFileTestForm;
begin
   if not assigned (FFileTestForm) then
      FFileTestForm := TFileTestForm.Create(Application);
   Result := FFileTestForm;
end;


procedure ShowFileTestForm;
begin
   FileTestForm.Show;
end;

procedure TFileTestForm.AddStatus(const Value: string; LogAlso: Boolean);
begin
   lbstatus.Items.Insert(0,FormatDateTime('dd/mm/yy hh:mm:ss.zzz ', Now) +   Value);
   while lbstatus.Items.Count > maxList do // So we can leave it running
      lbstatus.Items.Delete( pred(lbstatus.Items.Count));

   if LogAlso then
      LogMsg(lmDebug, UnitName, Value);
end;

procedure TFileTestForm.btnClearClick(Sender: TObject);
begin
   FailCount := 0;
   SuccessCount := 0;
   LBstatus.Clear;
end;

procedure TFileTestForm.btnClearListClick(Sender: TObject);
begin
   LBstatus.Clear;
end;

procedure TFileTestForm.btnContClick(Sender: TObject);
begin
   FContinuous := True;
   StartTest;
end;

procedure TFileTestForm.btnOnceClick(Sender: TObject);
begin
   FContinuous := false;
   StartTest;
end;

procedure TFileTestForm.Button3Click(Sender: TObject);
begin
   FCur := -1;
   FContinuous := False;
end;

function TFileTestForm.CheckFile(Filename: string): Boolean;
begin
   Result := False;
   try
      if FileExists(Filename) then begin
         CRCFileUtils.CheckEmbeddedCRC(FileName);
         // still here...
         Result := True
      end else begin
         // File name will be logged, so dont repeat
         Ferror := 'File Not Found';
      end;
   except
      on E : Exception do
         Ferror := E.Message;
   end;
end;

procedure TFileTestForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := caHide;
end;

procedure TFileTestForm.FormCreate(Sender: TObject);
begin
   FCodeList := TStringList.Create;
   FCur := -1;
   btnClearClick(nil);
end;

procedure TFileTestForm.FormDestroy(Sender: TObject);
begin
   TestTimer.Enabled := False;
   FCodeList.Free;
end;

procedure TFileTestForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key = VK_Escape then begin
      Key := 0;
      Hide;
   end;
end;

procedure TFileTestForm.SetFailCount(const Value: Integer);
begin
   FFailCount := Value;
   lblFailed.Caption := IntToStr(FFailCount);
   lblTested.Caption := IntToStr(FFailCount + FSuccessCount);
end;

procedure TFileTestForm.SetLFailCount(const Value: Integer);
begin
   FLFailCount := Value;
end;

procedure TFileTestForm.SetLSuccessCount(const Value: Integer);
begin
   FLSuccessCount := Value;
end;

procedure TFileTestForm.SetSuccessCount(const Value: Integer);
begin
   FSuccessCount := Value;
   lblPassed.Caption := IntToStr(FSuccessCount);
   lblTested.Caption := IntToStr(FFailCount + FSuccessCount);
end;

procedure TFileTestForm.startTest;
var I : Integer;
begin
  FCodeList.Clear;
  // Should I Lock here...
  if AdminExists then
    if RefreshAdmin then
    with AdminSystem.fdSystem_Client_File_List do
       for I := 0 to  pred(ItemCount) do
         with Client_File_At(I)^ do
           if (cfFile_Status in [fsNormal,fsOpen,fsCheckedOut])
           and (cfFile_Type = 0) then
              FCodeList.Add(cfFile_Code);

   if FCodeList.Count > 0 then begin
      btnCont.Enabled := False;
      btnOnce.Enabled := False;
      LFailCount := 0;
      LSuccessCount := 0;
      FCur := 0;
      TestTimer.Enabled := true;
      lblMode.Caption := 'Testing ' + intToStr(FCodeList.Count)
                       + ' x 2 Client files';
      if Fcontinuous then
         lblMode.Caption := lblMode.Caption + ' Continuous'
      else
         lblMode.Caption := lblMode.Caption + ' Once'
   end else begin
      lblMode.Caption := 'No Clients found';
   end;
   AddStatus(lblMode.Caption, True);
end;

procedure TFileTestForm.TestTimerTimer(Sender: TObject);
var Filename: string;
begin
   if FCur >= FCodeList.Count then begin
      // Done a complete loop
      AddStatus('Tested ' +
                         IntToStr(FCodeList.Count * 2) +
                         ' Failed: ' + IntToStr(LFailCount) +
                         ' Passed: ' + IntToStr(LSuccessCount), True);

      if FContinuous then
         StartTest
      else
         FCur := -1;
   end else if FCur >= 0 then begin
      // run test
      if FBackFile then begin
         Filename := Globals.DataDir + FcodeList[FCur] +  '.bak';
         inc(FCur);
         FBackFile := False;
      end else begin
         Filename := Globals.DataDir + FcodeList[FCur] +  '.bk5';
         FBackFile := True;
      end;
      lblTesting.Caption := Filename;

      if CheckFile(FileName ) then begin
         SuccessCount := SuccessCount + 1;
         lSuccessCount := lSuccessCount + 1;
         Addstatus(Filename + ' ok', cbPassed.Checked);
      end else begin
         FailCount := FailCount + 1;
         lFailCount := lFailCount + 1;
         Addstatus(Filename + ' ERROR:  ' + FError, cbFailed.Checked);
      end;

   end else begin
      TestTimer.Enabled := False;
      btnCont.Enabled := True;
      btnOnce.Enabled := True;
      if FCodeList.Count > 0 then
         lblMode.Caption := 'Tested ' + intToStr(SuccessCount + FailCount)
                       + ' Client files';
      lblTesting.Caption := 'Done';
                      
   end;
end;

end.
