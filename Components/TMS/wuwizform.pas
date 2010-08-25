{*******************************************************************}
{ TWebUpdate Wizard form                                            }
{ for Delphi & C++Builder                                           }
{ version 1.6                                                       }
{                                                                   }
{ written by                                                        }
{    TMS Software                                                   }
{    copyright © 1998-2006                                          }
{    Email : info@tmssoftware.com                                   }
{    Web   : http://www.tmssoftware.com                             }
{                                                                   }
{ The source code is given as is. The author is not responsible     }
{ for any possible damage done due to the use of this code.         }
{ The component can be freely used in any application. The source   }
{ code remains property of the writer and may not be distributed    }
{ freely as such.                                                   }
{*******************************************************************}

unit WuWizForm;

{$I TMSDEFS.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, WUpdate, ComCtrls, ExtCtrls, CheckLst, Math;

const

  AUTORUNDELAY = 350;

type
  TWUWIZ = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Billboard: TImage;
    WelcomeLabel: TLabel;
    StartButton: TButton;
    TabSheet3: TTabSheet;
    VersionInfoLabel: TLabel;
    ControlButton: TButton;
    WhatsNewMemo: TMemo;
    Label1: TLabel;
    TabSheet4: TTabSheet;
    Label2: TLabel;
    EULAMemo: TMemo;
    RAccept: TRadioButton;
    RNoAccept: TRadioButton;
    TabSheet5: TTabSheet;
    CheckListBox1: TCheckListBox;
    Label3: TLabel;
    NewButton: TButton;
    EULAButton: TButton;
    TabSheet6: TTabSheet;
    Label4: TLabel;
    FileProgress: TProgressBar;
    TotalProgress: TProgressBar;
    CancelButton: TButton;
    Label5: TLabel;
    Label6: TLabel;
    FilesButton: TButton;
    TabSheet7: TTabSheet;
    RestartButton: TButton;
    Label7: TLabel;
    Label8: TLabel;
    FileLabel: TLabel;
    Shape1: TShape;
    procedure StartButtonClick(Sender: TObject);
    procedure ControlButtonClick(Sender: TObject);
    procedure NewButtonClick(Sender: TObject);
    procedure EULAButtonClick(Sender: TObject);
    procedure RAcceptClick(Sender: TObject);
    procedure FilesButtonClick(Sender: TObject);
    procedure WebUpdateFileProgress(Sender: TObject; filename: String;
      pos, size: Integer);
    procedure WebUpdateCancel(Sender: TObject; var Cancel: Boolean);  
    procedure FormCreate(Sender: TObject);
    procedure RestartButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    FWebUpdate: TWebUpdate;
    FCancelled: Boolean;
    FAutoRun: Boolean;
    FAutoStart: Boolean;
    FStrNewFound: string;
    FStrNoUpdate: string;
    FStrNoNewFiles: string;
    FStrGetUpdate: string;
    FStrNewVersion: string;
    FStrNext: string;
    FStrNoNewVersion: string;
    FStrUCNewVersion: string;
    FStrCannotConnect: string;
    FStrCurVersion: string;
    FStrExit: string;
    FFailedDownload: string;
    procedure SetWebUpdate(const Value: TWebUpdate);
    procedure SetCancelled(const Value: Boolean);
    procedure ClickDelay;
    procedure SetButtonWidth(Button: TButton);
  public
    { Public declarations }
    procedure UpdateDone;
    function CheckFileCount: Boolean;
    property WebUpdate: TWebUpdate read FWebUpdate write SetWebUpdate;
    property Cancelled: Boolean read FCancelled write SetCancelled;
    property AutoRun: Boolean read FAutoRun write FAutoRun;
    property AutoStart: Boolean read FAutoStart write FAutoStart;

    property StrNewFound: string read FStrNewFound write FStrNewFound;
    property StrNewVersion: string read FStrNewVersion write FStrNewVersion;
    property StrCurVersion: string read FStrCurVersion write FStrCurVersion;
    property StrNoNewVersion: string read FStrNoNewVersion write FStrNoNewVersion;
    property StrUCNewVersion: string read FStrUCNewVersion write FStrUCNewVersion;
    property StrGetUpdate: string read FStrGetUpdate write FStrGetUpdate;
    property StrExit: string read FStrExit write FStrExit;
    property StrNoNewFiles: string read FStrNoNewFiles write FStrNoNewFiles;
    property StrCannotConnect: string read FStrCannotConnect write FStrCannotConnect;
    property StrNoUpdate: string read FStrNoUpdate write FStrNoUpdate;
    property StrNext: string read FStrNext write FStrNext;
    property StrFailedDownload:string read FFailedDownload write FFailedDownload;
  end;

var
  WUWIZ: TWUWIZ;

implementation

{$R *.dfm}

procedure TWUWIZ.SetButtonWidth(Button: TButton);
var
  MyCanvas: TCanvas;
  iButtonLeft, iButtonWidth: Integer;
begin
  iButtonLeft := Button.Left;
  iButtonWidth := Button.Width; // or 91 if it shall be able to shrink again
  MyCanvas := TCanvas.Create;
  try
    MyCanvas.Handle := GetDC(Button.Handle);
    MyCanvas.Font.Assign(Button.Font);
    Button.Width := Max(MyCanvas.TextWidth(Button.Caption)+16, iButtonWidth);
  finally
    ReleaseDC(0, Canvas.Handle);
    MyCanvas.Free;
  end;
  Button.Left := iButtonLeft - (ControlButton.Width - iButtonWidth);
end;

procedure TWUWIZ.StartButtonClick(Sender: TObject);
var
  res: Integer;
begin
  Cursor := crHourGlass;
  StartButton.Enabled := false;
  if WebUpdate.StartConnection = WU_SUCCESS then
  begin
    Cursor := crDefault;
    if WebUpdate.UpdateType = ftpUpdate then
      WebUpdate.FTPConnect;

    WebUpdate.UpdateUpdate := wuuSilent;

    if WebUpdate.GetControlFile = WU_SUCCESS then
    begin
      StartButton.Enabled := true;
      {$IFDEF DELPHI5_LVL}
      PageControl1.ActivePageIndex := 1;
      {$ELSE}
      PageControl1.ActivePage := TabSheet2;
      {$ENDIF}

      res := WebUpdate.DoVersionCheck;
      case res of
      WU_DATEBASEDNEWVERSION:
        if (Frac(WebUpdate.NewVersionDate) <> 0) then
          VersionInfoLabel.Caption := StrNewFound + ' :' + #13 +
            StrCurVersion + ' : ' + DateToStr(WebUpdate.CurVersionDate) + #13 +
            StrNewVersion + ' : ' + DateToStr(WebUpdate.NewVersionDate) + ' ' + TimeToStr(WebUpdate.NewVersionDate) + #13#13+
            WebUpdate.UpdateDescription
        else
          VersionInfoLabel.Caption := StrNewFound + ' :' + #13 +
            StrCurVersion + ' : ' + DateToStr(WebUpdate.CurVersionDate) + #13 +
            StrNewVersion + ' : ' + DateToStr(WebUpdate.NewVersionDate) + #13#13+
            WebUpdate.UpdateDescription;
      WU_UNCONDITIONALNEWVERSION,WU_CHECKSUMBASEDNEWVERSION,WU_FILESIZEBASEDNEWVERSION, WU_CUSTOMNEWVERSION:
        VersionInfoLabel.Caption := StrUcNewVersion;
      WU_VERSIONINFOBASEDNEWVERSION:
        VersionInfoLabel.Caption := StrNewFound + ' :' + #13 +
          StrCurVersion + ' : '+ WebUpdate.CurVersionInfo + #13 +
          StrNewVersion + ' : '+ WebUpdate.NewVersionInfo+ #13#13+
          WebUpdate.UpdateDescription;
      WU_NONEWVERSION:
        VersionInfoLabel.Caption := StrNoNewVersion;
      end;

      VersionInfoLabel.Width := 300;

      if res <> WU_NONEWVERSION then
        ControlButton.Caption := StrGetUpdate
      else
        ControlButton.Caption := StrExit;

      SetButtonWidth(ControlButton);

      ControlButton.Enabled := True;
      ControlButton.SetFocus;

      if AutoRun then
      begin
        ClickDelay;
        ControlButtonClick(self);
      end;
    end
    else
    begin
      {$IFDEF DELPHI5_LVL}
      PageControl1.ActivePageIndex := 1;
      {$ELSE}
      PageControl1.ActivePage := TabSheet2;
      {$ENDIF}

      VersionInfoLabel.Caption := StrCannotConnect + ' ' + StrNoUpdate;

      VersionInfoLabel.Width := 300;

      ControlButton.Caption := StrExit;

      SetButtonWidth(ControlButton);

      ControlButton.Enabled := True;
      ControlButton.SetFocus;
      
      if AutoRun then
      begin
        ClickDelay;
        ControlButtonClick(self);
      end;
    end;
  end
  else
  begin
    Cursor := crDefault;
    UpdateDone;
    StartButton.Enabled := true;
  end;
end;

procedure TWUWIZ.ControlButtonClick(Sender: TObject);
var
  sl: TStringList;
  i,j: Integer;
begin
  if ControlButton.Caption <> StrExit then
  begin
    // check for custom actions to handle
    if WebUpdate.HandleActions = WU_SUCCESS then
    begin
      // check for a What's new file
      sl := WebUpdate.GetWhatsNew;
      if Assigned(sl) then
      begin
        WhatsNewMemo.Lines.Assign(sl);
        {$IFDEF DELPHI5_LVL}
        PageControl1.ActivePageIndex := 2;
        {$ELSE}
        PageControl1.ActivePage := TabSheet3;
        {$ENDIF}
        NewButton.Enabled := true;
        NewButton.SetFocus;

        if AutoRun then
        begin
          ClickDelay;
          NewButtonClick(self);
        end;
        Exit;
      end;

      // check for a EULA file
      sl := WebUpdate.GetEULA;
      if Assigned(sl) then
      begin
        EULAMemo.Lines.Assign(sl);
        {$IFDEF DELPHI5_LVL}
        PageControl1.ActivePageIndex := 3;
        {$ELSE}
        PageControl1.ActivePage := TabSheet4;
        {$ENDIF}

        if AutoRun then
        begin
          EULAButton.Enabled := true;
          EULAButton.Caption := StrNext;

          SetButtonWidth(EULAButton);

          ClickDelay;
          EULAButtonClick(self);
        end;
        Exit;
      end;

      // Get list of file details
      WebUpdate.GetFileDetails;
      WebUpdate.ProcessFileDetails;
      
      for i := 1 to WebUpdate.FileList.Count do
      begin
        if not WebUpdate.FileList.Items[i - 1].Hidden then
          CheckListBox1.Items.Add(WebUpdate.FileList.Items[i - 1].Description);
      end;

      j := 0;
      for i := 1 to CheckListBox1.Items.Count do
      begin
        if not WebUpdate.FileList.Items[i - 1].Hidden then
        begin
          CheckListBox1.Checked[j] := True;
          CheckListBox1.Items.Objects[j] := TObject(i - 1);
	  {$IFDEF DELPHI5_LVL}
          if WebUpdate.FileList.Items[i - 1].Mandatory then
            CheckListBox1.ItemEnabled[j] := false;
          {$ENDIF} 
          inc(j);  
        end;    
      end;

      if CheckFileCount then
      begin
        {$IFDEF DELPHI5_LVL}
          PageControl1.ActivePageIndex := 4;
        {$ELSE}
          PageControl1.ActivePage := TabSheet5;
        {$ENDIF}
        FilesButton.Enabled := true;
        FilesButton.SetFocus;

        if AutoRun or (CheckListBox1.Items.Count = 0) then
        begin
          ClickDelay;
          FilesButtonClick(Self);
        end;
      end
      else
      begin
        {$IFDEF DELPHI5_LVL}
          PageControl1.ActivePageIndex := 6;
        {$ELSE}
          PageControl1.ActivePage := TabSheet7;
        {$ENDIF}
        RestartButton.Caption := StrExit;
        SetButtonWidth(RestartButton);
        Label8.Caption := '';
        RestartButton.SetFocus;
      end;
    end
    else
      UpdateDone;
  end
  else
    UpdateDone;
end;

procedure TWUWIZ.NewButtonClick(Sender: TObject);
var
  sl: TStringList;
  i,j: Integer;
begin
  sl := WebUpdate.GetEULA;
  if Assigned(sl) then
  begin
    EULAMemo.Lines.Assign(sl);
    {$IFDEF DELPHI5_LVL}
    PageControl1.ActivePageIndex := 3;
    {$ELSE}
    PageControl1.ActivePage := TabSheet4;
    {$ENDIF}

    if AutoRun then
    begin
      EULAButton.Enabled := true;
      EULAButton.Caption := StrNext;
      SetButtonWidth(EULAButton);
      ClickDelay;
      EULAButtonClick(Self);
    end;
    Exit;
  end;

  WebUpdate.GetFileDetails;
  WebUpdate.ProcessFileDetails;

  for i := 1 to WebUpdate.FileList.Count do
  begin
    if not WebUpdate.FileList.Items[i - 1].Hidden then
      CheckListBox1.Items.Add(WebUpdate.FileList.Items[i - 1].Description);
  end;

  j := 0;
  for i := 1 to WebUpdate.FileList.Count do
  begin
    if not WebUpdate.FileList.Items[i - 1].Hidden then
    begin
      CheckListBox1.Checked[j] := True;
      CheckListBox1.Items.Objects[j] := TObject(i - 1);
      {$IFDEF DELPHI5_LVL}
      if WebUpdate.FileList.Items[i - 1].Mandatory then
        CheckListBox1.ItemEnabled[j] := false;
      {$ENDIF} 
      inc(j);
    end;
  end;

  if CheckFileCount then
  begin
  {$IFDEF DELPHI5_LVL}
    PageControl1.ActivePageIndex := 4;
  {$ELSE}
    PageControl1.ActivePage := TabSheet5;
  {$ENDIF}
    FilesButton.Enabled := true;
    FilesButton.SetFocus;

    if AutoRun then
    begin
      ClickDelay;
      FilesButtonClick(self);
    end;
  end;
end;

procedure TWUWIZ.EULAButtonClick(Sender: TObject);
var
  i,j: Integer;
begin
  if RAccept.Checked then
  begin
    WebUpdate.GetFileDetails;
    WebUpdate.ProcessFileDetails;

    for i := 1 to WebUpdate.FileList.Count do
    begin
      if not WebUpdate.FileList.Items[i - 1].Hidden then
        CheckListBox1.Items.Add(WebUpdate.FileList.Items[i - 1].Description);
    end;

    j := 0;
    for i := 1 to WebUpdate.FileList.Count do
    begin
      if not WebUpdate.FileList.Items[i - 1].Hidden then
      begin
        CheckListBox1.Checked[j] := True;
        CheckListBox1.Items.Objects[j] := TObject(i - 1);
	{$IFDEF DELPHI5_LVL}
        if WebUpdate.FileList.Items[i - 1].Mandatory then
          CheckListBox1.ItemEnabled[j] := false;
        {$ENDIF}
        inc(j);
      end;
    end;

    {$IFDEF DELPHI5_LVL}
    PageControl1.ActivePageIndex := 4;
    {$ELSE}
    PageControl1.ActivePage := TabSheet5;
    {$ENDIF}

    FilesButton.Enabled := true;
    FilesButton.SetFocus;

    if AutoRun then
    begin
      ClickDelay;
      FilesButtonClick(Self);
    end;
  end;

  if RNoAccept.Checked then
    UpdateDone;
end;

procedure TWUWIZ.RAcceptClick(Sender: TObject);
begin
  if RAccept.Checked then
  begin
    EULAButton.Enabled := True;
    EULAButton.Caption := StrNext;
    SetButtonWidth(EULAButton);
  end;

  if RNoAccept.Checked then
  begin
    EULAButton.Enabled := True;
    EULAButton.Caption := StrExit;
    SetButtonWidth(EULAButton);
  end;
end;

procedure TWUWIZ.FilesButtonClick(Sender: TObject);
var
  i,j,k: Integer;
begin
  for i := 1 to WebUpdate.FileList.Count do
    WebUpdate.FileList.Items[i - 1].Selected := true;

  // indicate the selected items  
  for i := 1 to CheckListBox1.Items.Count do
  begin
    if not CheckListBox1.Checked[i - 1] then
    begin
      k := integer(CheckListBox1.Items.Objects[i - 1]);
      WebUpdate.FileList.Items[k].Selected := false;
    end;
  end;

  j := 0;

  while (j < WebUpdate.FileList.Count) do
  begin
    if not WebUpdate.FileList.Items[j].Selected then
      WebUpdate.FileList.Items[j].Free
    else
      inc(j);
  end;

  if CheckFileCount then
  begin
    FileLabel.Caption := '';
    FileProgress.Position := 0;
    TotalProgress.Position := 0;

    {$IFDEF DELPHI5_LVL}
    PageControl1.ActivePageIndex := 5;
    {$ELSE}
    PageControl1.ActivePage := TabSheet6;
    {$ENDIF}
    CancelButton.Enabled := true;
    CancelButton.SetFocus;

    if AutoRun then
      CancelButton.Enabled := false;

    Cursor := crHourGlass;

    if WebUpdate.GetFileUpdates = WU_FAILED then
    begin
      Cursor := crDefault;
      WebUpdate.Cancel;
      ShowMessage(FFailedDownload);
    end;

    WebUpdate.UpdateActions;

    Cursor := crDefault;

    if WebUpdate.Cancelled then
    begin
      UpdateDone;
    end
    else
    begin
      WebUpdate.StopConnection;

      if WebUpdate.AppNeedsRestart then
      begin
        {$IFDEF DELPHI5_LVL}
        PageControl1.ActivePageIndex := 6;
        {$ELSE}
        PageControl1.ActivePage := TabSheet7;
        {$ENDIF}
        RestartButton.Enabled := true;
        RestartButton.SetFocus;

      end
      else
      begin
        {$IFDEF DELPHI5_LVL}
        PageControl1.ActivePageIndex := 6;
        {$ELSE}
        PageControl1.ActivePage := TabSheet7;
        {$ENDIF}
        RestartButton.Caption := StrExit;
        SetButtonWidth(RestartButton);
        Label8.Caption := '';
        RestartButton.Enabled := true;
        RestartButton.SetFocus;
      end;

      if AutoRun then
      begin
        ClickDelay;
        RestartButtonClick(Self);
      end;

    end;
  end;
end;

procedure TWUWIZ.WebUpdateFileProgress(Sender: TObject; filename: String;
  pos, size: Integer);
begin
  FileLabel.Caption := ExtractFileName(Filename);
  FileProgress.Max := size;
  FileProgress.Position := pos;

  TotalProgress.Max := WebUpdate.FileList.TotalSize;
  TotalProgress.Position := WebUpdate.FileList.CompletedSize + pos;
  Application.ProcessMessages;
end;

procedure TWUWIZ.FormCreate(Sender: TObject);
begin
  {$IFDEF DELPHI5_LVL}
  PageControl1.ActivePageIndex := 0;
  {$ELSE}
  PageControl1.ActivePage := TabSheet1;
  {$ENDIF}
  WebUpdate := nil;
end;

procedure TWUWIZ.RestartButtonClick(Sender: TObject);
begin
  if WebUpdate.AppNeedsRestart then
    WebUpdate.DoRestart
  else
    Close;
end;

procedure TWUWIZ.UpdateDone;
begin
  WebUpdate.StopConnection;
  Close;
end;

function TWUWIZ.CheckFileCount: Boolean;
begin
  Result := True;
  if WebUpdate.FileList.Count = 0 then
  begin
    ShowMessage(StrNoNewFiles);
    UpdateDone;
    Result := False;
  end;
end;

procedure TWUWIZ.SetWebUpdate(const Value: TWebUpdate);
begin
  FWebUpdate := Value;
  if Assigned(FWebUpdate) Then
  begin
    FWebUpdate.OnFileProgress := WebUpdateFileProgress;
    FWebUpdate.OnProgressCancel := WebUpdateCancel;
  end;
  FCancelled := False;
end;

procedure TWUWIZ.SetCancelled(const Value: Boolean);
begin
  FCancelled := Value;
end;

procedure TWUWIZ.WebUpdateCancel(Sender: TObject; var Cancel: Boolean);
begin
  Cancel := FCancelled;
end;

procedure TWUWIZ.CancelButtonClick(Sender: TObject);
begin
  FCancelled := True;
end;

procedure TWUWIZ.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   UpdateDone;
end;

procedure TWUWIZ.FormActivate(Sender: TObject);
begin
  StartButton.SetFocus;
  if AutoStart then
  begin
  {$IFDEF DELPHI5_LVL}
    PageControl1.ActivePageIndex := 1;
  {$ELSE}
    PageControl1.ActivePage := TabSheet2;
  {$ENDIF}
    ClickDelay;
    StartButtonClick(Self);
  end;
end;

procedure TWUWIZ.ClickDelay;
var
  t: DWord;
begin
  t := GetTickCount;
  while (GetTickCount - t < AUTORUNDELAY) do
    Application.ProcessMessages;
end;

end.
