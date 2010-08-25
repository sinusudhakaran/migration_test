unit ImportHistClass;

//------------------------------------------------------------------------------
{
   Title:        BankLink Import History Listview unit

   Description:  Overwrites the TListview, to allow Scroll synchronization between the Tob and Bottom Listview

   Remarks:

   Author:       Andre' Joosten, Feb 2009

}
//------------------------------------------------------------------------------

interface
uses Controls,comCtrls,Messages,Windows,VirtualTrees;

type
  TVirtualStringTree = class(VirtualTrees.TVirtualStringTree)
     procedure WMVScroll(var Message: TMessage); message WM_VSCROLL;
     procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
  private
    FSyncView: TVirtualStringTree;
    FInSync: Boolean;
    procedure SetSyncView(const Value: TVirtualStringTree);
  published
    property SyncView: TVirtualStringTree read FSyncView write SetSyncView;
  public
     procedure DoSync(value: Integer); virtual;

  end;

implementation

{ TVirtualStringTree }


procedure TVirtualStringTree.CMMouseWheel(var Message: TCMMouseWheel);
begin
   inherited;
   if (not FInSync)
   and Assigned(FSyncView) then begin
      FSyncView.DoSync(Self.OffsetY);// just copy the offset...
   end;
end;

procedure TVirtualStringTree.DoSync(value: Integer);
begin
  FInSync := True; // May generate Scrolls
  OffsetY := Value;
  FinSync := False;
end;

procedure TVirtualStringTree.SetSyncView(const Value: TVirtualStringTree);
begin
  FSyncView := Value;
end;

procedure TVirtualStringTree.WMVScroll(var Message: TMessage);
begin
  inherited; // do Me first..

  if (not FInSync)
  and Assigned(FSyncView) then begin
     FSyncView.DoSync(Self.OffsetY);// just copy the offset...
  end;
end;

end.
