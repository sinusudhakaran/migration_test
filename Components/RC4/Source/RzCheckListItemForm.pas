{===============================================================================
  RzCheckListItemForm Unit

  Raize Components - Design Editor Source Unit

  Copyright © 1995-2007 by Raize Software, Inc.  All Rights Reserved.


  Design Editors
  ------------------------------------------------------------------------------
  TRzCheckItemEditDlg
    Used by the TRzCheckListEditor dialog when adding/editing list items.


  Modification History
  ------------------------------------------------------------------------------
  3.0    (20 Dec 2002)
    * Updated form to use custom framing editing controls and HotTrack style
      buttons, radio buttons, and check boxes.
    * Added As Group check box to allow adding/editing groups.
===============================================================================}

{$I RzComps.inc}

unit RzCheckListItemForm;

interface

uses
  {$IFDEF USE_CS}
  CodeSiteLogging,
  {$ENDIF}
  Forms,
  StdCtrls,
  Controls,
  Classes,
  RzEdit,
  RzButton,
  RzLabel, RzRadChk;

type
  TRzCheckItemEditDlg = class(TForm)
    Label1: TRzLabel;
    BtnOK: TRzButton;
    BtnCancel: TRzButton;
    EdtItem: TRzMemo;
    ChkAsGroup: TRzCheckBox;
    procedure FormCreate(Sender: TObject);
  private
    procedure SetItem( const Item: string );
    function GetItem: string;
  public
    property Item: string
      read GetItem
      write SetItem;
  end;


implementation

{$R *.DFM}

procedure TRzCheckItemEditDlg.FormCreate(Sender: TObject);
begin
  {$IFDEF VCL90_OR_HIGHER}
  PopupMode := pmAuto;
  {$ENDIF}
end;


procedure TRzCheckItemEditDlg.SetItem( const Item: string );
begin
  EdtItem.Text := Item;
  EdtItem.SelectAll;
end;


function TRzCheckItemEditDlg.GetItem: string;
begin
  Result := EdtItem.Text;
end;


end.
