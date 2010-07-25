//------------------------------------------------------------------------------
// MainFrm
//
// Convert Include files from 'C' header format to Delphi include format.
//
// Parameters (Optional):
//   1: Input File ('C' h file)
//   2: Output File (Delphi inc file)
//   3: Help File (HTML help .chm file)
//
// Version Date       Author    Comments
//    1.00 16/12/2003 MichaelF  Initial version.
//
unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls, Buttons, ComCtrls;

type
  TfrmMain = class(TForm)
    imgBankLinkHeader: TImage;
    imgBankLinkLogo256: TImage;
    lblUnderline: TLabel;
    lblHeading: TLabel;
    Panel1: TPanel;
    Label1: TLabel;
    edtInputFile: TEdit;
    Label2: TLabel;
    edtOutputFile: TEdit;
    btnConvert: TButton;
    btnClose: TButton;
    pnlStatus: TPanel;
    pbProgress: TProgressBar;
    stVersion: TStaticText;
    lblTransferring: TStaticText;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    btnInputFile: TBitBtn;
    btnOutputFile: TBitBtn;
    Label3: TLabel;
    edtHelpFile: TEdit;
    btnHelpFile: TBitBtn;
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnInputFileClick(Sender: TObject);
    procedure btnOutputFileClick(Sender: TObject);
    procedure btnConvertClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnHelpFileClick(Sender: TObject);
  private
    { Private declarations }
    ScreenColours : Int64;
    Automate : Boolean;
    procedure UpdateScreenColours( ColorDepth: Int64);
  public
    { Public declarations }
  end;

function GetScreenColors( CanvasHandle : hDC): Int64;

var
  frmMain: TfrmMain;

implementation

uses
  ShellAPI;

{$R *.dfm}

const
  HelpFileExtension = '.chm';

//------------------------------------------------------------------------------

function GetScreenColors( CanvasHandle : hDC): Int64;
var
  n1, n2: longint;
begin
  n1 := GetDeviceCaps( CanvasHandle, PLANES );
  n2 := GetDeviceCaps( CanvasHandle, BITSPIXEL );
  Result := Int64( 1 ) shl ( n1 * n2 );
end;

//------------------------------------------------------------------------------

procedure TfrmMain.UpdateScreenColours( ColorDepth: Int64);
begin
  if (ColorDepth <= 256) then
  begin
    //lo colour
    imgBankLinkLogo256.Visible := True;
    imgBankLinkHeader.Visible := False;
    imgBankLinkLogo256.Left := 0;
    imgBankLinkLogo256.Top := 0;
  end else
  begin
    //hi colour
    imgBankLinkLogo256.Visible := False;
    imgBankLinkHeader.Visible := True;
    imgBankLinkHeader.Left := 0;
    imgBankLinkHeader.Top := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmMain.FormActivate(Sender: TObject);
begin
  ScreenColours := GetScreenColors(Self.Canvas.Handle);
  UpdateScreenColours(ScreenColours);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  lblHeading.Caption := 'BankLink Include file converter';
  lblTransferring.Caption := ' Ready...';

  Automate := False;
  if (ParamCount > 0) then
    edtInputFile.Text := ParamStr(1);
  if (ParamCount > 1) then
  begin
    edtOutputFile.Text := ParamStr(2);
    if (ParamCount = 2) then
    begin
      Automate := True;
      btnConvert.Click;
    end;
  end;
  if (ParamCount > 2) then
  begin
    edtHelpFile.Text := ParamStr(3);
    Automate := True;
    btnConvert.Click;
  end;
end;

procedure TfrmMain.btnInputFileClick(Sender: TObject);
begin
  with OpenDialog1 do
  begin
    FileName := ExtractFileName(edtInputFile.Text);
    InitialDir := ExtractFilePath(edtInputFile.Text);
    Filter := '''C'' Include File (*.h)|*.h';
    if Execute then
    begin
      edtInputFile.Text := FileName
    end;
  end;
end;

procedure TfrmMain.btnOutputFileClick(Sender: TObject);
var
  Ext : String;
begin
  with SaveDialog1 do
  begin
    FileName := ExtractFileName(edtOutputFile.Text);
    InitialDir := ExtractFilePath(edtOutputFile.Text);
    Filter := 'Delphi Include File (*.inc)|*.inc';
    if Execute then
    begin
      Ext := ExtractFileExt(Filename);
      if (Ext = '') then
        edtOutputFile.Text := FileName + '.inc'
      else
        edtOutputFile.Text := FileName;
    end;
  end;
end;

//------------------------------------------------------------------------------
// btnConvertClick
//
// format is:
// #define <name> <value>
//
procedure TfrmMain.btnConvertClick(Sender: TObject);
var
  InputFile, OutputFile : TextFile;
  Line : String;
  StartPos, EndPos : Integer;
  DefName, DefValue : String;
begin
  if (not FileExists(edtInputFile.Text)) then
  begin
    ShowMessage('Input file does not exist.');
    Exit;
  end;
  if (edtOutputFile.Text = '') then
  begin
    ShowMessage('Output file has not been specified.');
    Exit;
  end;
  if (edtHelpFile.Text <> '') then
  begin
    Line := ExtractFileExt(edtHelpFile.Text);
    if (Line = '') then
      edtHelpFile.Text := edtHelpFile.Text + HelpFileExtension;
  end;

  lblTransferring.Caption := ' Beginning Conversion';

  AssignFile(InputFile, edtInputFile.Text);
  try
    AssignFile(OutputFile, edtOutputFile.Text);
    try
      Reset(InputFile);
      Rewrite(OutputFile);

      Writeln(OutputFile, '//------------------------------------------------------------------------------');
      Writeln(OutputFile, '//');
      Writeln(OutputFile, '// ' + ExtractFileName(edtOutputFile.Text));
      Writeln(OutputFile, '//');
      Writeln(OutputFile, '//------------------------------------------------------------------------------');
      Writeln(OutputFile, '');
      Writeln(OutputFile, 'const');
      Writeln(OutputFile, '  //Map IDs');

      while not EOF(InputFile) do
      begin
        Readln(InputFile, Line);
        if (Copy(Line, 1, 7) = '#define') then
        begin
          StartPos := 8;
          //skip spaces
          while (StartPos < Length(Line)) and (Line[StartPos] in [' ',#9]) do
            Inc(StartPos);
          EndPos := StartPos + 1;
          //extract definition name
          while (EndPos < Length(Line)) and (not (Line[EndPos] in [' ',#9])) do
          begin
            //strip out illegal characters
            if ((Integer(Line[EndPos]) and $80) = $80) then
              Delete(Line, EndPos, 1)
            else
              Inc(EndPos);
          end;
          if (EndPos >= Length(Line)) then
            Continue;
          DefName := Copy(Line, StartPos, EndPos-StartPos);
          StartPos := EndPos;
          //skip spaces
          while (StartPos < Length(Line)) and (Line[StartPos] in [' ',#9]) do
            Inc(StartPos);
          EndPos := StartPos + 1;
          //extract definition value
          while (EndPos < Length(Line)) and (not (Line[EndPos] in [' ',#9])) do
            Inc(EndPos);
          if (EndPos >= Length(Line)) then
            Inc(EndPos);
          DefValue := Copy(Line, StartPos, EndPos-StartPos);
          Writeln(OutputFile, '  BKH_' + DefName + ' = ' + DefValue + ';');
        end;
      end;

      Writeln(OutputFile, '');
      Writeln(OutputFile, 'var');
      Writeln(OutputFile, '  //filename of HTML help file');
      Line := ExtractFileName(edtHelpFile.Text);
      Writeln(OutputFile, '  HelpFileName : String = ''' + Line + ''';');
      Writeln(OutputFile, '');
    finally
      CloseFile(OutputFile);
    end;
  finally
    CloseFile(InputFile);
  end;
  lblTransferring.Caption := ' Conversion Complete';
  if (Automate) then
    Close;
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnHelpFileClick(Sender: TObject);
begin
  with OpenDialog1 do
  begin
    FileName := ExtractFileName(edtHelpFile.Text);
    InitialDir := ExtractFilePath(edtHelpFile.Text);
    Filter := 'Help File (*.chm)|*.chm';
    if Execute then
    begin
      edtHelpFile.Text := FileName
    end;
  end;
end;

end.

