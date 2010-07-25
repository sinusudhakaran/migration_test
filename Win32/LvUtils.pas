Unit LvUtils;

Interface

Uses
   Windows, ComCtrls;

Procedure SetListViewColWidth(lv: TListView; AutoCol: Integer; MinimumWidth: Integer = -1);

Procedure SelectListViewItem(lv: TListView; Item: TListItem);

procedure ReselectAndScroll(ListView: TListView; SelectedIndex, TopIndex: Integer);
procedure Reselect(ListView: TListView; SelectedIndex: Integer);
procedure ScrollToItem(ListView: TListView; TopIndex: Integer);

Implementation

Uses Math;

{sc-----------------------------------------------------------------------
-----------------------------------------------------------------------sc}
Procedure SetListViewColWidth(lv: TListView; AutoCol: Integer; MinimumWidth: Integer = -1);
Const
   EXTRA_MARGIN = 5;
Var
   ws,
   i       : Integer;
   Total   : Integer;
   NewSize : Integer;
Begin { SetListViewColWidth } 
   Total := 0; 
   
   ws := GetSystemMetrics(SM_CXVSCROLL); //Get Width Vertical Scroll Bar 
   For i := 0 to lv.columns.Count - 1 Do 
   Begin 
      Total := Total + lv.columns[i].width 
   End; 
   
   If lv.columns.Count > 0 Then 
   Begin 
      Total := Total - lv.columns[AutoCol].width; 
      NewSize := lv.width - (ws + EXTRA_MARGIN) - Total; 
      
      If NewSize < lv.columns[AutoCol].MinWidth Then
      Begin
         NewSize := lv.columns[AutoCol].MinWidth
      End;
      If (MinimumWidth > -1) and (NewSize < MinimumWidth) Then
      Begin
         NewSize := MinimumWidth
      End;
      lv.columns[AutoCol].width := NewSize
   End { lv.columns.Count > 0 }; 
End; { SetListViewColWidth } 


{sc-----------------------------------------------------------------------
-----------------------------------------------------------------------sc} 
Procedure SelectListViewItem(lv: TListView; Item: TListItem); 
//clears any previously selected item 
Begin { SelectListViewItem } 
   lv.Selected := Nil; 
   lv.Selected := Item; 
   lv.Selected.Focused := true; 
   lv.Selected.MakeVisible(false); 
End; { SelectListViewItem } 

//Selects the item in a list view (and scrolls to when it was before)
//Requires called to get the selection and TopItem.Index before changing list
procedure ReselectAndScroll(ListView: TListView; SelectedIndex, TopIndex: Integer);
begin
  if ListView.Items.Count = 0 then
    Exit;
  Reselect(ListView, SelectedIndex);
  ScrollToItem(ListView, TopIndex);
end;

procedure Reselect(ListView: TListView; SelectedIndex: Integer);
begin
  if ListView.Selected <> nil then
    ListView.Selected.Selected := false;
  if ( SelectedIndex >= ListView.Items.Count ) then
    Dec( SelectedIndex );
  ListView.Selected := ListView.Items[SelectedIndex];
  if Assigned( ListView.Selected ) then
    ListView.Selected.Focused := true;
end;

procedure ScrollToItem(ListView: TListView; TopIndex: Integer);
var
  LastItemIndex: Integer;
begin
  //Move scroll to be the same as before (but make sure we don't try to scroll to an item that
  //doesn't exist)
  if ListView.Items.Count > TopIndex then
  begin
    ListView.Items[TopIndex].MakeVisible(false);
    LastItemIndex := Math.Min(ListView.Items.Count - 1, TopIndex + ListView.VisibleRowCount - 1);
    ListView.Items[LastItemIndex].MakeVisible(false);
  end;
end;

End.  
