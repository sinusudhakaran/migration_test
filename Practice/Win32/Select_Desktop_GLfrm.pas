unit Select_Desktop_GLfrm;
//------------------------------------------------------------------------------
{
   Title:        Desktop Super GL selector

   Description:  Provides UI to show user a list of ledgers available in DS

   Author:       Steve Teare  December 2006

   Remarks:

   Revisions:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OSFont;

type
  TDS_GL_Rec = record
    cl_ID: integer;
    cl_Code : string;
    cl_Description : string;
  end;

  TGLArray = array of TDS_GL_Rec;

type
  TfrmSelect_Desktop_GL = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    btnSelect: TButton;
    btnCancl: TButton;
    lblLedgerPath: TLabel;
    cmbLedger: TComboBox;
    procedure FormDestroy(Sender: TObject);
    procedure cmbLedgerChange(Sender: TObject);
    procedure cmbLedgerDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cmbLedgerDropDown(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    GLArray : TGLArray;
    procedure FillGLArray( List : string);
  public
    { Public declarations }
  end;

procedure SelectLedgerID( var LedgerID : Integer; const ListOfGLs : string);

procedure SelectLedgerCode( var LedgerCode : ShortString; const ListOfGLs : string);

implementation

uses
 bkXPThemes,
 StStrS, GenUtils;

{$R *.dfm}

procedure SelectLedgerID( var LedgerID : Integer; const ListOfGLs : string);
//returns 1 is ledger path selected
// ledger path : string    existing ledger path in acct sys dialog
// list of gls : string    xml string containing ledgers
var
  f : TfrmSelect_Desktop_GL;
  i : integer;
  currentindex : integer;
begin
  f := TfrmSelect_Desktop_GL.Create( Application);
  try
    //digest xml string into array
    f.FillGLArray( ListOfGLs);
    f.lblLedgerPath.Caption := '';

    currentindex := -1;
    for i := Low( f.GLArray) to High( f.GLArray) do
    begin
      if f.GLArray[i].cl_ID <> -1 then
        f.cmbLedger.Items.Add( f.GLArray[i].cl_Description);
      //find existing code
      if f.GLArray[i].cl_ID = LedgerID then
        currentindex := i;
    end;
    f.cmbLedger.ItemIndex := CurrentIndex;
    if currentindex <> -1 then
      f.lblLedgerPath.Caption := f.GLArray[ currentIndex].cl_Code
    else
      f.lblLedgerPath.Caption := '';
    case f.ShowModal of
      mrOK : begin
        if f.cmbLedger.ItemIndex <> -1 then
          LedgerID := f.glArray[f.cmbLedger.itemindex].cl_ID;
     end;
   end; //case
  finally
    f.Free;
  end;
end;

procedure SelectLedgerCode( var LedgerCode : ShortString; const ListOfGLs : string);
//returns 1 is ledger path selected
// ledger path : string    existing ledger path in acct sys dialog
// list of gls : string    xml string containing ledgers
var
  f : TfrmSelect_Desktop_GL;
  i : integer;
  currentindex : integer;
begin
  f := TfrmSelect_Desktop_GL.Create( Application);
  try
    //digest xml string into array
    f.FillGLArray( ListOfGLs);
    f.lblLedgerPath.Caption := '';

    currentindex := -1;
    for i := Low( f.GLArray) to High( f.GLArray) do
    begin
      if f.GLArray[i].cl_ID <> -1 then
        f.cmbLedger.Items.Add( f.GLArray[i].cl_Description);
      //find existing code
      if f.GLArray[i].cl_Code = LedgerCode then
        currentindex := i;
    end;
    f.cmbLedger.ItemIndex := CurrentIndex;
    if currentindex <> -1 then
      f.lblLedgerPath.Caption := f.GLArray[ currentIndex].cl_Code
    else
      f.lblLedgerPath.Caption := '';
    case f.ShowModal of
      mrOK : begin
        if f.cmbLedger.ItemIndex <> -1 then
          LedgerCode := f.glArray[f.cmbLedger.itemindex].cl_Code;
     end;
   end; //case
  finally
    f.Free;
  end;
end;



procedure TfrmSelect_Desktop_GL.FillGLArray(List: string);
var
   Fields: array[ 1..3 ] of string;
   S: TStringList;
   i, j: Integer;
begin
  S := TStringList.Create;
  try
    S.Text := List;
    // Note start at '1' to skip headers
    if S.Count < 1 then begin
       SetLength( GLArray,0);
       Exit;
    end;

    SetLength( GLArray, S.Count - 1);
    for i := 1 to Pred(S.Count) do
    begin
      For j := 1 to 3 do Fields[ j ] := TrimSpacesAndQuotes( ExtractAsciiS( j, S[i], ',', '"' ) );
      GLArray[i-1].cl_ID := StrToIntDef(Fields[1], -1);
      GLArray[i-1].cl_Code := Fields[2];
      GLArray[i-1].cl_Description := Fields[3];
    end;
  finally
    S.Free;
  end;
end;

procedure TfrmSelect_Desktop_GL.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm(Self);
end;

procedure TfrmSelect_Desktop_GL.FormDestroy(Sender: TObject);
var
  i : integer;
begin
  for i := Low( GLArray) to High( GLArray) do
    with GLArray[i] do
    begin
      cl_ID := -1;
      cl_Code := '';
      cl_Description := '';
    end;
  SetLength( GLArray, 0);
end;

procedure TfrmSelect_Desktop_GL.cmbLedgerChange(Sender: TObject);
begin
  if cmbLedger.ItemIndex <> - 1 then
    lblLedgerPath.Caption := GLArray[ cmbLedger.ItemIndex].cl_Code
  else
    lblLedgerPath.Caption := '';
end;

procedure TfrmSelect_Desktop_GL.cmbLedgerDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  //This ensures the correct highlite color is used
  cmbLedger.canvas.fillrect(rect);

  cmbLedger.canvas.textout( rect.left + 2, rect.top,  GLArray[index].cl_Description);
  cmbLedger.canvas.textout( rect.left + cmbLedger.Width ,rect.top, '(' + GLArray[ index].cl_Code + ')');
end;

procedure TfrmSelect_Desktop_GL.cmbLedgerDropDown(Sender: TObject);
begin
  SendMessage(TComboBox(Sender).Handle, CB_SETDROPPEDWIDTH, cmbLedger.Width + 100, 0);
end;

end.
