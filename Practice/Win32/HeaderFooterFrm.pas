unit HeaderFooterFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RzButton, RzPanel, WPRTEDefs, WPCTRMemo, WPCTRRich, WPRuler, WPTbar,
  ExtCtrls,wpManHeadFoot,WPRTEPaint, StdCtrls, Menus, ImgList;

type
  TfrmHeaderFooter = class(TForm)
    Panel1: TPanel;
    WPToolBar1: TWPToolBar;
    Topbar: TRzToolbar;
    btnAll: TRzToolButton;
    btnOdd: TRzToolButton;
    BtnEven: TRzToolButton;
    BtnFirst: TRzToolButton;
    BtnLast: TRzToolButton;
    pnlHeader: TPanel;
    RulerHeader: TWPRuler;
    VertRulerHeader: TWPVertRuler;
    RTHeader: TWPRichText;
    Splitter1: TSplitter;
    Panel2: TPanel;
    RulerFooter: TWPRuler;
    VertRulerFooter: TWPVertRuler;
    RTFooter: TWPRichText;
    RzPanel1: TRzPanel;
    Label1: TLabel;
    RzPanel2: TRzPanel;
    Label2: TLabel;
    ImageList1: TImageList;
    RzSpacer1: TRzSpacer;
    RzSpacer2: TRzSpacer;
    RzSpacer3: TRzSpacer;
    BtnInsert: TRzToolButton;
    pmInsert: TPopupMenu;
    Picture1: TMenuItem;
    N1: TMenuItem;
    PageNumber1: TMenuItem;
    PageCount1: TMenuItem;
    N2: TMenuItem;
    Date1: TMenuItem;
    Time1: TMenuItem;
    N3: TMenuItem;
    Client1: TMenuItem;
    Operator1: TMenuItem;
    ClientCode1: TMenuItem;
    OperatorCode1: TMenuItem;
    GraphicPopupMenu: TPopupMenu;
    grAutoWrap: TMenuItem;
    grBothWrap: TMenuItem;
    grNoWrap: TMenuItem;
    gr1: TMenuItem;
    grPage: TMenuItem;
    grChar: TMenuItem;
    grLeft: TMenuItem;
    grRight: TMenuItem;
    procedure DoTypeBtn(Sender: TObject);
    procedure RTFooterClick(Sender: TWPCustomRtfEdit; PageNo, X, Y: Integer;
      var Ignore: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Picture1Click(Sender: TObject);
    procedure PageNumber1Click(Sender: TObject);
    procedure PageCount1Click(Sender: TObject);
    procedure Date1Click(Sender: TObject);
    procedure Time1Click(Sender: TObject);
    procedure Client1Click(Sender: TObject);
    procedure ClientCode1Click(Sender: TObject);
    procedure Operator1Click(Sender: TObject);
    procedure OperatorCode1Click(Sender: TObject);
    procedure grPopupClick(Sender: TObject);
    procedure GraphicPopupMenuPopup(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
//    FWPManageHeaderFooter: TWPManageHeaderFooter;
    FTextRange: TWPPagePropertyRange;
    FSource: TWPRichText;
    procedure SetTextRange(const Value: TWPPagePropertyRange);
    procedure SetSource(const Value: TWPRichText);
    function TextActive: Boolean;
    function ActiveText: TWPRichText;
    { Private declarations }
  public
    property TextRange: TWPPagePropertyRange read FTextRange write SetTextRange;
    property Source: TWPRichText read FSource write SetSource;
    { Public declarations }
  end;



implementation

uses
   wpDefActions,
   StyleUtils;

{$R *.dfm}

{ TfrmHeaderFooter }

function TfrmHeaderFooter.ActiveText: TWPRichText;
begin
   Result := TWPRichText(WPToolBar1.RtfEdit);
end;

procedure TfrmHeaderFooter.grPopupClick(Sender: TObject);
var obj: TWPTextObj;
begin
  if not TextActive then
     Exit;
  if ActiveText.SelectedObject = nil then
     Exit;

  obj := ActiveText.SelectedObject;
  case (Sender as TComponent).Tag of
      //1: obj.PositionMode := wpotChar;
      1: obj.Wrap := wpwrAutomatic;
      2: obj.Wrap := wpwrLeft;
      3: obj.Wrap := wpwrRight;
      4: obj.Wrap := wpwrBoth;
      5: obj.Wrap := wpwrNone;

      6: obj.PositionMode := wpotChar;
      7: obj.PositionMode := wpotPage;
      {6: begin
          if wpobjObjectUnderText in obj.Mode then
             obj.Mode := obj.Mode - [wpobjObjectUnderText]
          else
             obj.Mode := obj.Mode + [wpobjObjectUnderText];

        end; }
    end;//case
    ActiveText.ReformatAll(false, true);
end;

procedure TfrmHeaderFooter.Client1Click(Sender: TObject);
begin
   if TextActive then begin
      ActiveText.InputMergeField(MT_Client,MT_Client);
   end;
end;

procedure TfrmHeaderFooter.ClientCode1Click(Sender: TObject);
begin
   if TextActive then begin
      ActiveText.InputMergeField(MT_ClientCode,MT_ClientCode);
   end;
end;

procedure TfrmHeaderFooter.Date1Click(Sender: TObject);
begin
   if TextActive then begin
      ActiveText.InputTextField(wpoDate);
   end;
end;

procedure TfrmHeaderFooter.DoTypeBtn(Sender: TObject);
begin
   if sender is TRzToolButton then begin
      TextRange := TWPPagePropertyRange(TRzToolButton(sender).Tag);
   end;
end;


procedure TfrmHeaderFooter.FormCreate(Sender: TObject);
begin
   RTHeader.OnMailMergeGetText := ReportStyles.OnFieldMerge;
   RTFooter.OnMailMergeGetText := ReportStyles.OnFieldMerge;
end;

procedure TfrmHeaderFooter.FormShow(Sender: TObject);
begin
   TextRange := wpraOnAllPages;
   RTHeader.SetFocus;
end;

procedure TfrmHeaderFooter.GraphicPopupMenuPopup(Sender: TObject);
var obj: TWPTextObj;
begin
   // Setup the menu...

  if not TextActive then
     Exit;
  if ActiveText.SelectedObject = nil then
     Exit;
  obj := ActiveText.SelectedObject;
  case obj.Wrap of
     wpwrAutomatic: grAutoWrap.Checked := True ;
     wpwrLeft: grLeft.Checked := True;
     wpwrRight: grRight.Checked := True;
     //wpwrNone: ;
     wpwrBoth: grBothWrap.Checked := True;
     else grNoWrap.Checked := True;
  end;
  case obj.PositionMode of
     wpotChar: grChar.Checked := True;
     //wpotPar: ;
     //wpotPage: ;
     else grPage.Checked := True;
  end;
end;

procedure TfrmHeaderFooter.Operator1Click(Sender: TObject);
begin
   if TextActive then begin
      ActiveText.InputMergeField(MT_Operator,MT_Operator);
   end;
end;

procedure TfrmHeaderFooter.OperatorCode1Click(Sender: TObject);
begin
   if TextActive then begin
      ActiveText.InputMergeField(MT_OperatorCode,MT_OperatorCode);
   end;
end;

procedure TfrmHeaderFooter.PageCount1Click(Sender: TObject);
begin
  if TextActive then begin
      ActiveText.InputTextField(wpoNumpages);
   end;
end;

procedure TfrmHeaderFooter.PageNumber1Click(Sender: TObject);
begin
   if TextActive then begin
      ActiveText.InputTextField(wpoPageNumber);
   end;
end;

procedure TfrmHeaderFooter.Picture1Click(Sender: TObject);
begin
   if TextActive then begin
     ActiveText.InsertGraphicDialog;
   end;
end;

procedure TfrmHeaderFooter.RTFooterClick(Sender: TWPCustomRtfEdit; PageNo, X,
  Y: Integer; var Ignore: Boolean);
begin
   if RTFooter.ActiveText = nil then
     RTFooter.ActiveText :=  RTFooter.HeaderFooter.Get(wpIsfooter,
        TWPPagePropertyRange( FTextRange ));

end;

procedure TfrmHeaderFooter.SetSource(const Value: TWPRichText);
begin
  FSource := Value;
end;

procedure TfrmHeaderFooter.SetTextRange(const Value: TWPPagePropertyRange);


    procedure SetText(E: TWPRichText; Kind: twppagePropertyKind );
//    var I : Integer;
//        Found : Boolean;
    begin
       {
       Found := False;
       for i := 0 to E.HeaderFooter.Count - 1 do
          if (E.HeaderFooter.Items[i].Kind = Kind)
          and (E.HeaderFooter.Items[i].Range = FTextRange)  then begin
             Found := True;
             Break;
          end;

       if Found then
       }
          E.ActiveText := E.HeaderFooter.Get(Kind,
               TWPPagePropertyRange( FTextRange ))
       {else
          E.ActiveText := nil;}
    end;
begin
   FTextRange := Value;
   try
      SetText(RTHeader,wpIsHeader);
      SetText(RTFooter,wpIsFooter);
   except

   end;
end;

function TfrmHeaderFooter.TextActive: Boolean;
begin
   Result := Assigned(WPToolBar1.RtfEdit);
end;

procedure TfrmHeaderFooter.Time1Click(Sender: TObject);
begin
   if TextActive then begin
      ActiveText.InputTextField(wpoTime);
   end;
end;

end.
