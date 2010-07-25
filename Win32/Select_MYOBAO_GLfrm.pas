unit Select_MYOBAO_GLfrm;
//------------------------------------------------------------------------------
{
   Title:        MYOB Accountants Office GL selector

   Description:  Provides UI to show user a list of ledgers available in AO

   Author:       Matthew Hopkins June 2005

   Remarks:

   Revisions:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  bkXPThemes,
  OSFont;

type
  TMYOBAO_GL_Rec = record
    cl_Name : string;
    cl_yr_end : string;
    cl_dir : string;
  end;

  TGLArray = array of TMYOBAO_GL_Rec;

type
  TfrmSelect_MYOBAO_GL = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    btnSelect: TButton;
    btnCancl: TButton;
    cmbLedger: TComboBox;
    lblLedgerPath: TStaticText;
    procedure FormDestroy(Sender: TObject);
    procedure cmbLedgerChange(Sender: TObject);
    procedure cmbLedgerDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cmbLedgerDropDown(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    GLArray : TGLArray;
    procedure FillGLArray( xmlList : string);
  public
    { Public declarations }
  end;


function SelectMYOBAO_GL( var LedgerPath : string; const ListOfGLs : string) : integer;

implementation
uses
  OmniXML, OmniXMLUtils, XMLUtils;
{$R *.dfm}

function SelectMYOBAO_GL( var LedgerPath : string; const ListOfGLs : string) : integer;
//returns 1 is ledger path selected
// ledger path : string    existing ledger path in acct sys dialog
// list of gls : string    xml string containing ledgers
//
// example
// - <xml>
//   - <status>
//     <code>0</code>
//     <message>OK</message>
//    </status>
//   - <Ledgers>
//     - <Ledger>
//     - <cl_name>
//          <![CDATA[ AO Demo Company ]]>
//       </cl_name>
//       <cl_yr_end>2004/06/30</cl_yr_end>
//     - <cl_dir>
//         <![CDATA[ AODEMOCOMP]]>
//       </cl_dir>
//       </Ledger>


var
  f : TfrmSelect_MYOBAO_GL;    
  i : integer;
  currentindex : integer;
begin
  result := -1;

  f := TfrmSelect_MYOBAO_GL.Create( Application.MainForm);
  try
    //digest xml string into array
    f.FillGLArray( ListOfGLs);
    f.lblLedgerPath.Caption := '';

    currentindex := -1;
    for i := Low( f.GLArray) to High( f.GLArray) do
    begin
      f.cmbLedger.Items.Add( f.GLArray[i].cl_Name);
      //find existing code
      if f.GLArray[i].cl_dir = LedgerPath then
        currentindex := i;
    end;
    if currentindex <> -1 then
    begin
      f.cmbLedger.ItemIndex := CurrentIndex;
      f.lblLedgerPath.Caption := f.GLArray[ currentIndex].cl_dir;
    end;

    case f.ShowModal of
      mrOK : begin
        if f.cmbLedger.ItemIndex <> -1 then
        begin
          LedgerPath := f.glArray[f.cmbLedger.itemindex].cl_dir;
          result := 1;
        end;
     end;

     mrCancel : begin
       result := 0;
     end;
   end; //case
  finally
    f.Free;
  end;
end;

procedure TfrmSelect_MYOBAO_GL.FillGLArray(xmlList: string);
var
  xmlDoc : IXMLDocument;
  LedgerNode, n : IXMLNode;
  LedgerNodeList : IXMLNodeList;
  RecNo : integer;
begin
  xmlDoc := CreateXMLDoc;
  try
    xmlDoc.PreserveWhiteSpace := false;
    if XMLLoadFromString( xmlDoc, xmlList) then
    begin
      n := bkSelectChildNode( xmlDoc.FirstChild, 'Ledgers');
      LedgerNodeList := FilterNodes( n, 'Ledger');
      if LedgerNodeList.Length > 0 then
      begin
        //resize dynamic array
        SetLength( GLArray, LedgerNodeList.Length);
        RecNo := 0;

        LedgerNode := LedgerNodeList.NextNode;
        while LedgerNode <> nil do
        begin
          //now load records into the array
          GLArray[ RecNo].cl_Name := GetNodeCData( bkSelectChildNode( LedgerNode, 'cl_name'));
          GLArray[ RecNo].cl_yr_end := GetNodeTextStr( LedgerNode, 'cl_yr_end');
          GLArray[ RecNo].cl_dir := GetNodeCData( bkSelectChildNode( LedgerNode, 'cl_dir'));

          //move to next rec
          RecNo := RecNo + 1;

          LedgerNode := LedgerNodeList.NextNode;
        end;
      end;
    end
    else
      raise EBkXMLError.Create( 'XML parse error: ' + xmlDoc.ParseError.Reason);
  finally
    xmlDoc := nil;
  end;
end;

procedure TfrmSelect_MYOBAO_GL.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);
end;

procedure TfrmSelect_MYOBAO_GL.FormDestroy(Sender: TObject);
var
  i : integer;
begin
  for i := Low( GLArray) to High( GLArray) do
    with GLArray[i] do
    begin
      cl_Name := '';
      cl_yr_end := '';
      cl_dir := '';
    end;
  SetLength( GLArray, 0);
end;

procedure TfrmSelect_MYOBAO_GL.cmbLedgerChange(Sender: TObject);
begin
  if cmbLedger.ItemIndex <> - 1 then
    lblLedgerPath.Caption := GLArray[ cmbLedger.ItemIndex].cl_dir
  else
    lblLedgerPath.Caption := '';
end;

procedure TfrmSelect_MYOBAO_GL.cmbLedgerDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  //This ensures the correct highlite color is used
  cmbLedger.canvas.fillrect(rect);

  //This line writes the text after the bitmap
  cmbLedger.canvas.textout( rect.left + 2, rect.top,  GLArray[index].cl_Name);
  cmbLedger.canvas.textout( rect.left + cmbLedger.Width ,rect.top, '(' + GLArray[ index].cl_yr_end + ')');
end;

procedure TfrmSelect_MYOBAO_GL.cmbLedgerDropDown(Sender: TObject);
begin
  SendMessage(TComboBox(Sender).Handle, CB_SETDROPPEDWIDTH, cmbLedger.Width + 100, 0);
end;

end.
