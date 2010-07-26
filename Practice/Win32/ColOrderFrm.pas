unit ColOrderFrm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   Edit Column Order

  Written: Oct 1999
  Authors: Matthew

  Purpose: Allows the user to change to order of the columns provided in the string
           list.

  Notes:   The items in the listbox should be loaded before the form is shown
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, OvcBase, OvcLB, Ovcbcklb, Buttons, ExtCtrls, CheckLst,
  OSFont;

type
  TfrmColOrder = class(TForm)
    OvcController1: TOvcController;
    btnUp: TBitBtn;
    btnDown: TBitBtn;
    btnOK: TButton;
    btnCancel: TButton;
    lbColumns: TListBox;
    Label1: TLabel;
    Bevel1: TBevel;
    procedure lbColumnsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbColumnsStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure lbColumnsEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure lbColumnsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure btnDownClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    CurrentIndex : Integer;
    OverIndex    : integer;
  public
    { Public declarations }
  end;

//******************************************************************************
implementation
{$R *.DFM}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmColOrder.lbColumnsDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
//Sender = control being dropped on
//Source = object being dropped
var
  OldIndex  : Integer;
  ListRect  : TRect;
begin
  accept := Source is TListBox;
  if accept then begin
     OldIndex := OverIndex;
     OverIndex := lbColumns.ItemAtPos(Point(x,y),true);
     //See if we need to paint anything
     if OldIndex = OverIndex then exit;
     //Draw Focus Rect
     if ( OverIndex > - 1 ) then begin
       ListRect := lbColumns.ItemRect( OverIndex );
       lbColumns.Canvas.DrawFocusRect(ListRect);
     end;
     //Clear old Focus Rect
     if (OldIndex <> -1) and (OverIndex <> OldIndex) then
        with lbColumns do begin
           ListRect := ItemRect( OldIndex );
           //need to set Brush.Color to table color if using TCheckListBox,
           //not needed for normal TListBox otherwise get strange painting effects
           //Canvas.Brush.Color := Color;
           Canvas.FrameRect( ListRect);
        end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmColOrder.lbColumnsStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
   CurrentIndex := lbColumns.ItemIndex;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmColOrder.lbColumnsEndDrag(Sender, Target: TObject; X, Y: Integer);
begin
   CurrentIndex := -1;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmColOrder.lbColumnsDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
   with lbColumns do
      if ( CurrentIndex <> -1 ) and ( OverIndex <> -1 ) then begin
         //Clear old Focus Rect
         lbColumns.Canvas.FrameRect( ItemRect( OverIndex ));
         //move item
         Items.Move(CurrentIndex, OverIndex);
         ItemIndex := OverIndex;
      end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmColOrder.btnDownClick(Sender: TObject);
var
   currIndex, newIndex : integer;
begin
   with lbColumns do
      if (ItemIndex <> -1) and (ItemIndex < Pred(Items.Count)) then begin
         currIndex := ItemIndex;
         newIndex := Succ(currIndex);
         Items.Move( currIndex, newIndex);
         ItemIndex := newIndex;
      end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmColOrder.btnUpClick(Sender: TObject);
var
   currIndex, newIndex : integer;
begin
   with lbColumns do
      if (ItemIndex > 0) then begin
         currIndex := ItemIndex;
         newIndex  := Pred(currIndex);
         Items.Move( currIndex, newIndex);
         ItemIndex := newIndex;
      end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmColOrder.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
   if Ord( Msg.CharCode ) = 109 then begin
      btnUp.Click;
      handled := true;
   end
   else if Ord( Msg.CharCode ) = 107 then begin
      btnDown.Click;
      handled := true;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmColOrder.FormShow(Sender: TObject);
begin
   if lbColumns.Items.Count > 0 then
      lbColumns.ItemIndex := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.

  