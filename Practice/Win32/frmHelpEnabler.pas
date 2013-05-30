unit frmHelpEnabler;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RzLabel;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    edtFilename: TEdit;
    btnBrowse: TButton;
    btnModify: TButton;
    btnClose: TButton;
    OpenDialog1: TOpenDialog;
    Label3: TLabel;
    urlMicrosoftKB: TRzURLLabel;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnModifyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses
  Registry,
  bkProduct;

const
  regKey_BK5Software = '\Software\Banklink';
  regStr_PathPrefix  = 'path';
  regStr_CurrentPath = 'currentpath';

{$R *.dfm}

procedure TForm1.btnBrowseClick(Sender: TObject);
begin
  if opendialog1.Execute then
  begin
    edtFilename.Text := opendialog1.FileName;
  end;
end;

procedure TForm1.btnCloseClick(Sender: TObject);
begin
  Close;
end;


function GetCurrentExePath : string;
var
  RegObj : TRegistry;
begin
  //now write in current dir
  RegObj := TRegistry.Create;
  try
    RegObj.RootKey := HKEY_CURRENT_USER;
    if RegObj.OpenKeyReadOnly( regKey_BK5Software) then
    begin
      result := RegObj.ReadString( regStr_CurrentPath);
      RegObj.CloseKey;
    end
  finally
    RegObj.Free;
  end;
end;


procedure TForm1.btnModifyClick(Sender: TObject);
const
  ItssKey = 'SOFTWARE\Microsoft\HTMLHelp\1.x\ItssRestrictions\';
var
  helpfilename : string;
  RegObj : TRegistry;
  UrlAllowList : string;
begin
  //need to add the chm file selected into the ItssRestrictions Key
  helpfilename := lowercase( edtFilename.Text);
  if not FileExists( helpfilename) then
  begin
    ShowMessage( 'The help file ' + helpfilename + ' cannot be found.');
    exit;
  end;

  RegObj := TRegistry.Create;
  try
    RegObj.RootKey := HKEY_LOCAL_MACHINE;
    if RegObj.OpenKey( ItssKey, True) then
    begin
      URLAllowList := RegObj.ReadString('UrlAllowList');
      if Pos( helpfilename, urlAllowList) = 0 then
      begin
        if URLAllowList <> '' then
          URLAllowList := URLAllowList + ';';

        URLAllowList := URLAllowList + helpfilename + ';file://' + helpfilename;
        RegObj.WriteString( 'URLAllowList', URLAllowList);
      end;
      RegObj.CloseKey;
      ShowMessage('Registry Updated');
    end;
  finally
    RegObj.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  path : string;
begin
  path := GetCurrentExePath;
  edtFilename.Text := Path + 'guide.chm';
  opendialog1.InitialDir := Path;

  Caption := TProduct.Rebrand(Caption);
end;

end.
