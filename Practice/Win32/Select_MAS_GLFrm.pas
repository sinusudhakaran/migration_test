unit Select_MAS_GLFrm;
{
//------------------------------------------------------------------------------
{
   Title:        Solution6 MAS 6 ledger selector

   Description:  Provides UI to show user a list of ledgers available in MAS.
                 Will return different directories based on whether the
                 LEdger is stored in SQL or Cheetah

                 <xml>
                - <status>
                  <code>0</code>
                  <message>OK</message>
                  </status>
                - <Ledgers>
                - <Ledger>
                  <cl_code>TEST</cl_code>
                  <cl_name>Test Ledger</cl_name>
                  <cl_yr_end>2004-06-30T00:00:00</cl_yr_end>
                  <cl_dir>C:\S6CLIENT\TEST</cl_dir>
                  </Ledger>
                  </Ledgers>
                  </xml>


   Author:       Matthew Hopkins Sept 2005

   Remarks:

   Revisions:

//------------------------------------------------------------------------------
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Buttons;

type
  TfrmSelectMas_GL = class(TForm)
    lvLedgers: TListView;
    Panel1: TPanel;
    Label1: TLabel;
    edtSol64Dir: TEdit;
    btnSol6Dir: TSpeedButton;
    sbStatus: TStatusBar;
    procedure btnSol6DirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvLedgersKeyPress(Sender: TObject; var Key: Char);
    procedure edtSol64DirKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lvLedgersDblClick(Sender: TObject);
  private
    { Private declarations }
    XmlList : string;
    DefaultPath : string;
    SelectedPath : string;
    DefaultLedger : string;
    SelectedLedger : string;

    procedure RefreshList;
    procedure FillGLList(xmlList: string);
  public
    { Public declarations }
  end;

//returns a ledger path and the location of the sol6 system directory
function SelectMAS_GL_Path( var LedgerPath : string; var Sol6SystemLocation : string) : integer;

//returns a ledger code and the location of the sol6 system directory
function SelectMAS_GL_Code( var LedgerCode : string; var LedgerPath : string; var Sol6SystemLocation : string) : integer;

//******************************************************************************
implementation
uses
  OmniXML, OmniXMLUtils, XMLUtils, Sol6_Const, ComObj, LogUtil, Sol6_Utils, ShellUtils,
  ImagesFrm;
{$R *.dfm}
const
  Unitname = 'Select_MAS_GLFrm';

function SelectMAS_GL_Path( var LedgerPath : string; var Sol6SystemLocation : string) : integer;
var
  f : TfrmSelectMas_GL;
begin
  try
    f := TfrmSelectMas_GL.Create( Application);
    try
      f.DefaultPath := LedgerPath;
      f.edtSol64Dir.text := Trim( Sol6SystemLocation);
      f.XmlList := '';
      f.SelectedPath := '';

      if f.ShowModal = mrOK then
      begin
        Sol6SystemLocation := Trim( f.edtSol64Dir.text);
        //return ledger path
        LedgerPath := f.SelectedPath;
        result := bkS6_COM_Refresh_Supported_User_Selected_Ledger;
      end
      else
        result := bkS6_COM_Refresh_Supported_User_Cancelled;
    finally
      f.Free;
    end;
  except
    on e : exception do
      begin
        //exception raised getting list, save to log
        LogError( Unitname, 'SelectMAS_GL_Path failed with error ' + e.Message);
        result := bkS6_COM_Refresh_NotSupported;
      end;
  end;
end;

function SelectMAS_GL_Code( var LedgerCode : string; var LedgerPath : string; var Sol6SystemLocation : string) : integer;
//updates
//  LedgerPath
var
  f : TfrmSelectMas_GL;
begin
  try
    f := TfrmSelectMas_GL.Create( Application);
    try
      f.DefaultLedger := LedgerCode;
      f.edtSol64Dir.text := Trim( Sol6SystemLocation);
      f.XmlList := '';
      f.SelectedLedger := '';

      if f.ShowModal = mrOK then
      begin
        Sol6SystemLocation := Trim( f.edtSol64Dir.text);
        //return ledger path
        LedgerCode := f.SelectedLedger;
        LedgerPath := f.SelectedPath;
        result := bkS6_COM_Refresh_Supported_User_Selected_Ledger;
      end
      else
        result := bkS6_COM_Refresh_Supported_User_Cancelled;
    finally
      f.Free;
    end;
  except
    on e : exception do
      begin
        //exception raised getting list, save to log
        LogError( Unitname, 'SelectMAS_GL_Code failed with error ' + e.Message);
        result := bkS6_COM_Refresh_NotSupported;
      end;
  end;
end;


procedure TfrmSelectMas_GL.btnSol6DirClick(Sender: TObject);
var
  Path : string;
begin
  Path := edtSol64Dir.Text;
  if BrowseFolder( Path, 'Select the location of your Solution6 system release' ) then
  begin
     edtSol64Dir.Text := Path;
     RefreshList;
  end;
end;

procedure TfrmSelectMas_GL.FormCreate(Sender: TObject);
begin
     btnSol6Dir.Glyph := ImagesFrm.AppImages.imgFindStates.Picture.Bitmap;
end;

procedure TfrmSelectMas_GL.FillGLList( xmlList : string);
var
  xmlDoc : IXMLDocument;
  LedgerNode, n : IXMLNode;
  LedgerNodeList : IXMLNodeList;
  NewItem : TListItem;
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
        LedgerNode := LedgerNodeList.NextNode;
        while LedgerNode <> nil do
        begin
          //now load records into the array
          NewItem := lvLedgers.Items.Add;
          NewItem.Caption := GetNodeText( bkSelectChildNode( LedgerNode, 'cl_code'));
          NewItem.SubItems.Add( GetNodeText( bkSelectChildNode( LedgerNode, 'cl_name')));
          NewItem.SubItems.Add( GetNodeText( bkSelectChildNode( LedgerNode, 'cl_dir')));

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

procedure TfrmSelectMas_GL.RefreshList;
var
  s : string;
begin
  if edtSol64Dir.Text <> '' then
  begin
    lvLedgers.Clear;

    //get list of gl's
    if GetListOfMAS_GLs( edtSol64Dir.Text, S) = bkS6_COM_Refresh_List_Retrieved then
    begin
      FillGLList( s);
      sbStatus.SimpleText := 'Select a ledger';
    end
    else
    begin
      sbStatus.SimpleText := s;  //error message
    end;
  end;
end;

procedure TfrmSelectMas_GL.FormShow(Sender: TObject);
begin
  Self.RefreshList;
end;

procedure TfrmSelectMas_GL.lvLedgersKeyPress(Sender: TObject;
  var Key: Char);
begin
   if Key = #13 then begin
     Key := #0;
     ModalResult := mrOK;
   end;
   if Key = #$1B then
   begin
     Key := #0;
     ModalResult := mrCancel;
   end;
end;

procedure TfrmSelectMas_GL.edtSol64DirKeyPress(Sender: TObject;
  var Key: Char);
begin
   if Key = #13 then
   begin
     Key := #0;
     RefreshList;
   end;
   if Key = #$1B then
   begin
     Key := #0;
     ModalResult := mrCancel;
   end;
end;

procedure TfrmSelectMas_GL.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrOK then
  begin
    if lvLedgers.Selected = nil then
    begin
      CanClose := false;
      exit;
    end;

    SelectedPath := lvLedgers.Selected.SubItems[1];
    SelectedLedger := lvLedgers.Selected.Caption;
  end;
end;

procedure TfrmSelectMas_GL.lvLedgersDblClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

end.
