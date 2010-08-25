unit dxsbstrs;

{$I cxVer.inc}

interface

resourcestring
  DXSB_NEWITEM               = 'New item';

  DXSB_DEFAULTGROUP          = 'Default';
  DXSB_DEFAULTITEMCAPTION    = 'New Item';
  DXSB_DEFAULTGROUPCAPTION   = 'New Group';

  //PopupMenu
  DXSB_ADDGROUP              = 'Add Group';
  DXSB_REMOVEGROUP           = 'Remove Group';
  DXSB_RENAMEGROUP           = 'Rename Group';
  DXSB_REMOVEITEM            = 'Remove ShortCut';
  DXSB_RENAMEITEM            = 'Rename ShortCut';
  DXSB_LARGEICONTYPE         = 'Large Icons';
  DXSB_SMALLICONTYPE         = 'Small Icons';
  DXSB_CUSTOMIZE             = 'Customize...';
  DXSB_CUSTOMIZECLOSEBUTTON  = 'Close';

  DXSB_CANTDELETEGROUP  = 'Can''t delete the group. It has items.';

type
  TdxSideBarGetResourceStringFunc = function(AResString: Pointer): string;

var
  dxSideBarGetResourceStringFunc: TdxSideBarGetResourceStringFunc;

function dxSideBarGetResourceString(AResString: Pointer): string;

implementation

function dxSideBarGetResourceString(AResString: Pointer): string;
begin
  if Assigned(dxSideBarGetResourceStringFunc) then
    Result := dxSideBarGetResourceStringFunc(AResString)
  else
    Result := LoadResString(AResString);
end;

end.
