unit FromBrowseForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, ADODB;

type
  TFromBrowse = class(TForm)
    pBtn: TPanel;
    BtnCancel: TButton;
    Btnok: TButton;
    OpenDlg: TOpenDialog;
    pBottom: TPanel;
    EResult: TEdit;
    BtnBrowse: TButton;
    PTop: TPanel;
    LExsiting: TLabel;
    EExststing: TListBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure EExststingClick(Sender: TObject);
    procedure EExststingDblClick(Sender: TObject);
    procedure BtnokClick(Sender: TObject);
    procedure BtnBrowseClick(Sender: TObject);
  private
    FResult: string;
    procedure SetResult(const Value: string);
    { Private declarations }
  public
    property Result: string read FResult write SetResult;
    { Public declarations }
  end;



function GetFromDir: string;

implementation

uses
  Globals,
  RegistryUtils,
  WinUtils;

function GetFromDir: string;
var form: TFromBrowse;
begin
  form := TFromBrowse.Create(Application.MainForm);
  if form.ShowModal = mrOK then
    Result := form.Result;
end;


{$R *.dfm}

procedure TFromBrowse.BtnokClick(Sender: TObject);
begin
   if Result > '' then
      Modalresult := mrOK;
end;

procedure TFromBrowse.BtnBrowseClick(Sender: TObject);
begin
   OpenDlg.FileName := Result;
   if OpenDlg.Execute then
      Result := IncludeTrailingPathDelimiter(ExtractFilePath(OpenDlg.FileName));

end;

procedure TFromBrowse.EExststingClick(Sender: TObject);
begin
   Result := EExststing.Items[EExststing.ItemIndex];
end;

procedure TFromBrowse.EExststingDblClick(Sender: TObject);
begin
   BtnokClick(nil);
end;

procedure TFromBrowse.FormCreate(Sender: TObject);
var
   list: TstringList;
   I: Integer;
begin
    list := TstringList.Create;
    try
       GetExePaths(list);
       I := 0;
       while I < List.Count do begin
          if BKFileExists(List[I] + SYSFILENAME) then
             inc(I) // We can use this one..
          else
             List.Delete(I); //Remove it
       end;

       if List.Count = 0 then begin
          List.Add('<no BankLink Practice 5 database locations found>');
          EExststing.Enabled := false;
       end;
       EExststing.Items.Text := list.Text;
    finally
       List.Free;
    end;
end;

procedure TFromBrowse.SetResult(const Value: string);
begin
  FResult := Value;
  EResult.Text := Value;
end;

end.
