unit prevform;
//------------------------------------------------------------------------------
{
   Author:  Matthew Hopkins
   Date:    Oct 97

   Purpose: Provides the preview screen for the bkPrintController object which is
            decended from the TQRPrinter.  Uses the quick report preview object.

            Allows for printing and printer setup from preview form if the
            printer object is configured
}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls, Menus, Buttons, StdCtrls, printers, ComCtrls,
  ImgList, bkqrprntr, ToolWin;

type
  TPreviewForm = class(TForm)
    imPreview: TImageList;
    imPage: TImageList;

    {preview toolbar}
    tbarPreview: TToolBar;
    tbSetup: TToolButton;
    tbPrint: TToolButton;
    tbSep3: TToolButton;
    tbPage: TToolButton;
    tbWhole: TToolButton;
    tbSep2: TToolButton;
    cmbZoom: TComboBox;
    tbSep1: TToolButton;
    tbClose: TToolButton;

    {page toolbar}
    tbarPage: TToolBar;
    tbFirst: TToolButton;
    tbPrev: TToolButton;
    tbNext: TToolButton;
    tbLast: TToolButton;

    {Menu}
    Menu: TMainMenu;
    File1: TMenuItem;
    PrinterSetup1: TMenuItem;
    Print1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    View1: TMenuItem;
    PageWidth1: TMenuItem;
    FullPage1: TMenuItem;
    StatusBar1: TStatusBar;
    N2: TMenuItem;
    FirstPage1: TMenuItem;
    LastPage1: TMenuItem;
    PreviousPage1: TMenuItem;
    NextPage1: TMenuItem;
    QRPreview1: TbkQRPreview;

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure NewPreview;
    procedure tbFirstClick(Sender: TObject);
    procedure tbPrevClick(Sender: TObject);
    procedure tbNextClick(Sender: TObject);
    procedure tbLastClick(Sender: TObject);
    procedure tbPageClick(Sender: TObject);
    procedure tbWholeClick(Sender: TObject);
    procedure tbSetupClick(Sender: TObject);
    procedure tbPrintClick(Sender: TObject);
    procedure tbCloseClick(Sender: TObject);
    procedure cmbZoomKeyPress(Sender: TObject; var Key: Char);
    procedure cmbZoomKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cmbZoomChange(Sender: TObject);
    procedure cmbZoomKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PrinterSetup1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure PageWidth1Click(Sender: TObject);
    procedure FullPage1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FirstPage1Click(Sender: TObject);
    procedure PreviousPage1Click(Sender: TObject);
    procedure NextPage1Click(Sender: TObject);
    procedure LastPage1Click(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
    FRepreview : Boolean;

    procedure UpdateZoom(newPercent : integer);
    procedure ChangeZoom( textValue: string);
    procedure DoPageWidth;
    procedure DoWholePage;

    procedure MoveFirst;
    procedure MoveLast;
    procedure MoveNext;
    procedure MovePrevious;
  public
    { Public declarations }
    procedure UpdateStatus(msg : string);
    property  Repreview : boolean read FRepreview write FRepreview default false;

    procedure DefaultDisplay;
  end;

//******************************************************************************
implementation

uses Noteshelp;

{$R *.DFM}

Const
  PRWHOLEPAGE = 'Whole Page';
  PRWIDTH     = 'Page Width';

var
  cmbTyping  : boolean = false;

//------------------------------------------------------------------------------

procedure TPreviewForm.NewPreview;
begin
   FRepreview := true;
   QRPreview1.QRPrinter.ShowingPreview := false;
   Close;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.DoWholePage;
begin
  QRPreview1.ZoomTofit;
  cmbZoom.Text := inttostr(QRPreview1.Zoom) + '%';
  cmbZoom.SelectAll;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.DoPageWidth;
begin
  QRPreview1.ZoomToWidth;
  cmbZoom.Text := inttostr(QRPreview1.Zoom) + '%';
  cmbZoom.SelectAll;
end;

//------------------------------------------------------------------------------
procedure TPreviewForm.MoveFirst;
begin
 QRPreview1.PageNumber := 1;
 UpdateStatus('Page ' + inttostr(QRPreview1.PageNumber) + ' of ' + inttostr(QRPreview1.QRPrinter.PageCount));
end;        {  }

//------------------------------------------------------------------------------
procedure TPreviewForm.MoveLast;
begin
  QRPreview1.PageNumber := QRPreview1.QRPrinter.PageCount;
  UpdateStatus('Page ' + inttostr(QRPreview1.PageNumber) + ' of ' + inttostr(QRPreview1.QRPrinter.PageCount));
end;        {  }

//------------------------------------------------------------------------------
procedure TPreviewForm.MoveNext;
begin
  QRPreview1.PageNumber := QRPreview1.PageNumber + 1;
  UpdateStatus('Page ' + inttostr(QRPreview1.PageNumber) + ' of ' + inttostr(QRPreview1.QRPrinter.PageCount));
end;        {  }

//------------------------------------------------------------------------------
procedure TPreviewForm.MovePrevious;
begin
     QRPreview1.PageNumber := QRPreview1.PageNumber - 1;
     UpdateStatus('Page ' + inttostr(QRPreview1.PageNumber) + ' of ' + inttostr(QRPreview1.QRPrinter.PageCount));
end;        {  }

//------------------------------------------------------------------------------

procedure TPreviewForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    QRPreview1.QRPrinter.ShowingPreview := false;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.FormCreate(Sender: TObject);
begin
   //Page defaults
   Left        := 0;
   Top         := 0;
   WindowState := wsMaximized;
   FRepreview  := false;
   //add the text messages
   cmbZoom.Items.Add(PRWIDTH);
   cmbZoom.Items.Add(PRWHOLEPAGE);
   BKHelpSetUp(Self, BKH_Producing_reports);   
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.tbFirstClick(Sender: TObject);
begin
     MoveFirst;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.tbPrevClick(Sender: TObject);
begin
     MovePrevious;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.tbNextClick(Sender: TObject);
begin
     MoveNext;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.tbLastClick(Sender: TObject);
begin
     MoveLast;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.tbPageClick(Sender: TObject);
begin
     DoPageWidth;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.tbWholeClick(Sender: TObject);
begin
     DoWholePage;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.tbSetupClick(Sender: TObject);
begin
    QRPreview1.QRPrinter.Print;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.tbPrintClick(Sender: TObject);
begin
    QRPreview1.QRPrinter.PrintSetup;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.tbCloseClick(Sender: TObject);
begin
    Self.Close;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.UpdateZoom(newPercent : integer);
begin
   if ( NewPercent > 0 ) and ( NewPercent < 2000) then begin
      qrPreview1.Zoom := newPercent;
      cmbZoom.Text := inttostr(QRPreview1.Zoom) + '%';
      cmbZoom.SelectAll;
   end;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.ChangeZoom( textValue: string);
{update the zoom value give a change in the combo box}
var
   valErr, percent : integer;

begin
   //check for text values
   if textValue = PRWIDTH then begin
      DoPageWidth;
      exit;
   end;
   if textValue = PRWHOLEPAGE then begin
      DoWholePage;
      exit;
   end;
   //check for blank
   if ( Trim( TextValue) = '') then begin
      TextValue := '100';
   end;
   //user has selected or typed a value
   if textValue[length(textValue)] = '%' then
      TextValue := Copy(TextValue,1,length(TextVAlue)-1);
   //check is numeric
   Val(textValue,Percent,valErr);
   if ValErr = 0 then
        UpdateZoom(percent);
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.cmbZoomKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   cmbTyping := true;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.cmbZoomChange(Sender: TObject);
//test for changes, ignore changes made while typing so that zoom only changes
//when enter is pressed.
begin
   if not cmbTyping then begin
      ChangeZoom(cmbZoom.Text);
   end;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.cmbZoomKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   cmbTyping := false;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.cmbZoomKeyPress(Sender: TObject; var Key: Char);
//ignore alpha characters
begin
   if ( Key in ['a'..'z']) or ( Key in ['A'..'Z'] ) then key := #0;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.PrinterSetup1Click(Sender: TObject);
begin
   QRPreview1.QRPrinter.PrintSetup;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.Print1Click(Sender: TObject);
begin
   QRPreview1.QRPrinter.Print;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.Exit1Click(Sender: TObject);
begin
   Self.Close;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.PageWidth1Click(Sender: TObject);
begin
   DoPageWidth;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.FullPage1Click(Sender: TObject);
begin
   DoWholePage;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.FormActivate(Sender: TObject);
begin
   Repaint;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.UpdateStatus(msg :string);
begin
   StatusBar1.SimpleText := msg;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.FirstPage1Click(Sender: TObject);
begin
   tbFirst.Click;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.PreviousPage1Click(Sender: TObject);
begin
   tbPrev.click;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.NextPage1Click(Sender: TObject);
begin
   tbNext.click;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.LastPage1Click(Sender: TObject);
begin
   tbLast.click;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.DefaultDisplay;
begin
   DoPageWidth;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
//handle special keys before any controls in the form get them
begin
   Handled := true;
   with QRPreview1 do
      case Msg.CharCode of
        VK_RIGHT:
           HorzScrollBar.Position := HorzScrollBar.Position + HorzScrollBar.Increment*2;
        VK_LEFT:
           HorzScrollBar.Position := HorzScrollBar.Position - HorzScrollBar.Increment*2;
        VK_UP:
           VertScrollBar.Position := VertScrollBar.Position - VertScrollBar.Increment*2;
        VK_DOWN:
           VertScrollBar.Position := VertScrollBar.Position + VertScrollBar.Increment*2;
        VK_ESCAPE:
           Self.Close;
        VK_PRIOR:
           MovePrevious;
        VK_NEXT:
           MoveNext;
        VK_END :
           MoveLast;
        VK_HOME :
           MoveFirst;
        VK_RETURN :
           ChangeZoom(cmbZoom.text);
        else
           Handled := false;
      end;
end;
//------------------------------------------------------------------------------

procedure TPreviewForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
// Handle mouse wheel events  
begin
   with QRPreview1 do
      if WheelDelta > 0 then begin
         if Shift = [ssShift] then begin
            MovePrevious;
         end
         else if Shift = [] then begin
            VertScrollBar.Position := VertScrollBar.Position - VertScrollBar.Increment*2;
         end;
      end
      else begin
         if Shift = [ssShift] then begin
            MoveNext;
         end
         else if Shift = [] then begin
            VertScrollBar.Position := VertScrollBar.Position + VertScrollBar.Increment*2;
         end;
      end;
   Handled := true;
end;
//------------------------------------------------------------------------------

end.
