unit BKOvcTable;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   BankLink OVC Table Component

  Written:
  Authors: Matthew

  Purpose: Customised BankLink Table Component

  Notes:   Used by Historical Data Entry, Smartbooks Journals and Dissections
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcBase, OvcTCmmn, OvcTable, ColFmtListObj, ColOrderFrm;

type
  TBKOvcTable = class(TOvcTable)
  private
     { Private declarations }
     BuildingCols : boolean;

     procedure SetupBankLinkDefaults;
  protected
     { Protected declarations }
     procedure DoColumnsChanged(ColNum1, ColNum2 : TColNum;
                                Action : TOvcTblActions); override;
     procedure DoActiveCellMoving(Command : word; var RowNum : TRowNum;
                                   var ColNum : TColNum); override;

  public
     { Public declarations }
     ColumnFmtList                 : TColFmtList;
     constructor Create(AOwner : TComponent); override;
     destructor Destroy; override;
     function ActiveFieldID : integer;
     procedure BuildTableColumns;
     procedure ReorderColumns;
     procedure ResetColumns;
  published
     { Published declarations }

  end;

procedure Register;

implementation
uses
   OvcTbcls,
   OvcConst,
   OvcTCHdr,
   OvcTgPns;
{ TBKOvcTable }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBKOvcTable.ActiveFieldID: integer;
begin
   result := ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TBKOvcTable.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   ColumnFmtList := TColFmtList.Create;
   SetupBankLinkDefaults;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TBKOvcTable.Destroy;
begin
   ColumnFmtList.Free;
   inherited Destroy;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKOvcTable.BuildTableColumns;
var
   i : integer;
   Col : TOvcTableColumn;
   ColDefn : pColumnDefn;
begin
   BuildingCols := true;
   //Lock table update
   AllowRedraw := false;
   //Set correct number of columns
   ColCount := ColumnFmtList.ItemCount;
   //Clear headings
   if Assigned(FLockedRowsCell) then begin
      TOvcTCColHead(FLockedRowsCell).Headings.Clear;
      //Iterate thru column format list setting correct columns attributes
      for i := 0 to Pred( ColumnFmtList.ItemCount ) do begin
         ColDefn := ColumnFmtList.ColumnDefn_At(i);
         with ColDefn^ do begin
            TOvcTCColHead(FLockedRowsCell).Headings.Add( cdHeading );
            Col := Columns[i];
            with Col do begin
               DefaultCell := cdTableCell;
               Width       := cdWidth;
               Hidden      := cdHidden;
            end;
         end;
      end;
   end;
   //Unlock table update
   AllowRedraw := true;
   BuildingCols := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKOvcTable.ReorderColumns;
var
   i : integer;
   cRec : pColumnDefn;
   CurrentFieldID : integer;
begin
   with TfrmColOrder.Create(Application.MainForm) do begin
      try
         //Assign Values to ListBox
         lbColumns.Clear;
         for i := 0 to Pred( ColumnFmtList.ItemCount ) do begin
            cRec := ColumnFmtList.ColumnDefn_At(i);
            lbColumns.Items.AddObject(cRec^.cdHeading, TObject(cRec));
         end;
         //set the selected col to the current active col
         lbColumns.ItemIndex := ActiveCol;
         //Show Form
         ShowModal;
         //Reorder the columns if OK pressed
         if ModalResult = mrOK then begin
            AllowRedraw := false;
            //store the active col field id for later use
            CurrentFieldId := ActiveFieldID;
            //Remove all cols from list and reinsert
            ColumnFmtList.DeleteAll;
            for i := 0 to Pred(lbColumns.Items.Count) do
               ColumnFmtList.Insert(lbColumns.Items.Objects[i]);
            //Rebuild the table
            BuildTableColumns;
            //Reset the active col in case the col was moved
            ActiveCol := ColumnFmtList.GetColNumOfField(CurrentFieldID);
            AllowRedraw := true;
         end;
      finally
         Free;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKOvcTable.ResetColumns;
var
   CurrentFieldID : integer;
begin
   AllowRedraw := false;
   //store the active col field id for later use
   CurrentFieldId := ActiveFieldID;
   ColumnFmtList.SetToDefault;
   //Rebuild the table
   BuildTableColumns;
   //Reset the active col in case the col was moved
   ActiveCol := ColumnFmtList.GetColNumOfField(CurrentFieldID);
   AllowRedraw := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKOvcTable.DoColumnsChanged(ColNum1, ColNum2: TColNum; Action: TOvcTblActions);
var
   pCD1,
   pCD2 : pColumnDefn;
begin
   inherited;
   //Now update column fmt list
   if BuildingCols then exit;

   case Action of
      taSingle : begin
           //update column width in ColumnFmtList
           pCD1 := ColumnFmtList.ColumnDefn_At(ColNum1);
           pCD1^.cdWidth := Columns[ColNum1].Width;
         end;

      taExchange : with ColumnFmtList do begin
           //swap cols, the table takes care of restructing itself, so all
           //we need to do is update the ColumnFmtList and ColConfigList.
           pCD1 := ColumnDefn_At(ColNum1);
           pCD2 := ColumnDefn_At(ColNum2);
           Items[ColNum1] := pCD2;
           Items[ColNum2] := pCD1;
        end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKOvcTable.DoActiveCellMoving(Command: word;
  var RowNum: TRowNum; var ColNum: TColNum);
// Behaviour is as follows
//
// Moving Left:  move to next editable col left, if none found stay where we are
// Moving Right: move to next editable col right, if none move down a row and left most col
//                  if no more rows stay where we are
//
// Mouse Click Left: move to next editable col left, if none found stay where we are
//                   change row if different
// Mouse Click Right: move to next editable col right, if none found stay where we are
//                   change row if different
var
   Direction : TDirection;
   NewCol    : integer;
begin
   if ((ComponentState * [csLoading, csDestroying]) <> []) then
      Exit;

   if Assigned(FActiveCellMoving) then
      FActiveCellMoving(Self, Command, RowNum, ColNum);

   try
      with ColumnFmtList do begin
         //calculate direction of movement
         if ( ColNum < ActiveCol ) then
            Direction := diLeft
         else if ( ColNum > ActiveCol) then
            Direction := diRight
         else if ( command = ccRight ) and ( ActiveCol = Pred ( ColCount ) ) then
            Direction := diRight
         else
            exit; //col has not been changed, don't need to do anything

         //check for specific command
         case Command of
            ccPageRight, ccBotRightCell : begin //goto right most col
               ColNum  := GetRightMostEditCol;
               LeftCol := ColNum;  //make last col visible
               exit;
            end;

            ccPageLeft, ccTopLeftCell : begin  //goto left most col
               ColNum  := GetLeftMostEditCol;
               LeftCol := 0;  //make first col visible
               exit;
            end;
         end;

         //check is destination cell is editable, if so don't need to do anything
         if ( ColNum <> ActiveCol ) and ColIsEditable(ColNum) then
            exit;

         if Command in [ccLeft, ccRight] then begin
            NewCol := GetNextEditCol( ActiveCol, Direction );
            if ( NewCol = -1 ) then begin

               case Direction of
                  diLeft : begin
                     ColNum  := GetLeftMostEditCol;
                     LeftCol := 0;
                  end;
                  diRight: begin
                     if (ActiveRow < Pred(RowLimit)) then begin
                        Inc(RowNum);
                        ColNum  := GetLeftMostEditCol;
                        LeftCol := 0;
                     end
                     else begin
                        ColNum := GetRightMostEditCol;
                        LeftCol := ColNum;
                     end;
                  end;
               end;
            end
            else begin
               ColNum := NewCol;
            end;
         end
         else begin
            //can't move onto selected cell, find closest one to where we want to go
            NewCol := GetClosestEditCol( ActiveCol, ColNum);
            if (NewCol = ActiveCol ) then begin
               //could not find a column to move to in the current row
               case Direction of
                  diLeft: begin
                     ColNum  := GetLeftMostEditCol;
                     LeftCol := 0;  //make 0th col visible
                  end;
                  diRight: begin
                     if Command = ccMouse then begin
                        ColNum := ActiveCol;  //mouse move stick on current col
                     end
                     else begin
                        ColNum  := GetRightMostEditCol;
                        LeftCol := ColNum;
                     end;
                  end; //case Direction
               end;
            end
            else begin
               ColNum := NewCol;
            end;
         end;
      end;
   finally
      //Finish of Default table behaviour as defined in TOvcTable
      if InEditingState and ((RowNum <> ActiveRow) or (ColNum <> ActiveCol)) then
      if not StopEditingState(true) then
        begin
          RowNum := ActiveRow;
          ColNum := ActiveCol;
        end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKOvcTable.SetupBankLinkDefaults;
begin
    //Table Colors
    Color                                   :=clWindow;
    Colors.ActiveFocused                    :=clHighlight;
    Colors.ActiveFocusedText                :=clHighlightText;
    Colors.ActiveUnfocused                  :=clBtnFace;
    Colors.ActiveUnfocusedText              :=clHighlightText;
    Colors.Locked                           :=clBtnFace;
    Colors.LockedText                       :=clBtnText;
    Colors.Editing                          :=clWindow;
    Colors.EditingText                      :=clWindowText;
    Colors.Selected                         :=clHighlight;
    Colors.SelectedText                     :=clHighlightText;
    //Grid Styles
    GridPenSet.NormalGrid.NormalColor       :=clSilver;
    GridPenSet.NormalGrid.SecondColor       :=clBtnHighlight;
    GridPenSet.NormalGrid.Style             :=psSolid;
    GridPenSet.NormalGrid.Effect            :=geVertical;
    GridPenSet.LockedGrid.NormalColor       :=clBtnShadow;
    GridPenSet.LockedGrid.SecondColor       :=clBtnHighlight;
    GridPenSet.LockedGrid.Style             :=psSolid;
    GridPenSet.LockedGrid.Effect            :=ge3D;
    GridPenSet.CellWhenFocused.NormalColor  :=clBlack;
    GridPenSet.CellWhenFocused.SecondColor  :=clBtnHighlight;
    GridPenSet.CellWhenFocused.Style        :=psSolid;
    GridPenSet.CellWhenFocused.Effect       :=geBoth;
    GridPenSet.CellWhenUnfocused.NormalColor:=clBlack;
    GridPenSet.CellWhenUnfocused.SecondColor:=clBtnHighlight;
    GridPenSet.CellWhenUnfocused.Style      :=psClear;
    GridPenSet.CellWhenUnfocused.Effect     :=geBoth;
    //Table Options
    Options :=[otoTabToArrow, otoEnterToArrow, otoNoSelection, otoThumbTrack];
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure Register;
begin
  RegisterComponents('BankLink', [TBKOvcTable]);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
