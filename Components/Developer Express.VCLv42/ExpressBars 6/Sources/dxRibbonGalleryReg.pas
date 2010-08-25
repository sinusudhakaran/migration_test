unit dxRibbonGalleryReg;

{$I cxVer.inc}

interface

procedure Register;

implementation

uses
{$IFDEF DELPHI6}
  DesignIntf, DesignEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  SysUtils, Classes, Graphics, ImgList, dxBar, cxLibraryReg, dxBarReg,
  dxRibbonGallery, cxPropEditors, Controls, dxRibbonGalleryFilterEd;

type
  { TdxRibboGalleryImageIndexProperty }

  TdxRibbonGalleryImageIndexProperty = class(TImageIndexProperty)
  private
    function GetGroup: TdxRibbonGalleryGroup;
  protected
    property Group: TdxRibbonGalleryGroup read GetGroup;
  public
    function GetImages: TCustomImageList; override;
  end;

  { TdxRibbonGalleryFilterGroupsProperty }

  TdxRibbonGalleryFilterGroupsProperty = class(TClassProperty)
  protected
    function GetAttributes: TPropertyAttributes; override;
    function FilterCategory: TdxRibbonGalleryFilterCategory;
  public
    procedure Edit; override;
  end;

  { TdxRibbonGalleryGroupAssignedValuesProperty }

  TdxRibbonGalleryGroupAssignedValuesProperty = class(TSetProperty)
  protected
    FProc: TGetPropProc;
    procedure GetPropProc({$IFNDEF DELPHI6}Prop: TPropertyEditor{$ELSE}const Prop: IProperty{$ENDIF});
  public
    procedure GetProperties(Proc: TGetPropProc); override;
  end;

  TdxRibbonGalleryGroupAccess = class(TdxRibbonGalleryGroup);

{ TdxRibboGalleryImageIndexProperty }

function TdxRibbonGalleryImageIndexProperty.GetImages: TCustomImageList;
begin
  Result := TdxRibbonGalleryGroupAccess(Group).Images;
end;

function TdxRibbonGalleryImageIndexProperty.GetGroup: TdxRibbonGalleryGroup;
begin
  Result := (GetComponent(0) as TdxRibbonGalleryGroupItem).Group;
end;

{ TdxRibbonGalleryFilterGroupsProperty }

procedure TdxRibbonGalleryFilterGroupsProperty.Edit;
begin
  with TfmGalleryFilterGroups.Create(nil) do
  try
    Init(FilterCategory);
    if ShowModal = mrOk then
    begin
      Apply(FilterCategory);
      dxBarDesignerModified(FilterCategory.GalleryItem.BarManager);
    end;
  finally
    Free;
  end;
end;

function TdxRibbonGalleryFilterGroupsProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly{$IFDEF DELPHI9}, paValueEditable{$ENDIF}];
end;

function TdxRibbonGalleryFilterGroupsProperty.FilterCategory: TdxRibbonGalleryFilterCategory;
begin
  Result := TdxRibbonGalleryFilterCategoryGroups(GetOrdValue).FilterCategory;
end;

{ TdxRibbonGalleryGroupAssignedValuesProperty }

procedure TdxRibbonGalleryGroupAssignedValuesProperty.GetProperties(Proc: TGetPropProc);
begin
  FProc := Proc;
  inherited GetProperties(GetPropProc);
end;

procedure TdxRibbonGalleryGroupAssignedValuesProperty.GetPropProc(
  {$IFNDEF DELPHI6}Prop: TPropertyEditor{$ELSE}const Prop: IProperty{$ENDIF});
var
  I: Integer;
begin
  for I := 0 to PropCount - 1 do
    if SameText(Prop.GetName, 'avSpaceBetweenItems') then Exit;
  FProc(Prop);
end;

procedure Register;
begin
  RegisterComponents('ExpressBars', [TdxRibbonDropDownGallery]);
  RegisterNoIcon([TdxRibbonGalleryItem]);

  RegisterPropertyEditor(TypeInfo(TBitmap), TdxRibbonGalleryGroupItem,
    'Glyph', TcxBitmapProperty);
  RegisterPropertyEditor(TypeInfo(TImageIndex), TdxRibbonGalleryGroupItem,
    'ImageIndex', TdxRibbonGalleryImageIndexProperty);
  RegisterPropertyEditor(TypeInfo(TdxBarItemLinks), TdxRibbonGalleryItem,
    'ItemLinks', TdxBarItemLinksPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TList), TdxRibbonGalleryFilterCategory,
    'Groups', TdxRibbonGalleryFilterGroupsProperty);
  RegisterPropertyEditor(TypeInfo(TdxRibbonGalleryGroupOptionsAssignedValues),
    TdxRibbonGalleryGroupOptions, 'AssignedValues',
    TdxRibbonGalleryGroupAssignedValuesProperty);

  HideClassProperties(TdxRibbonGalleryItem, ['Detachable', 'DetachingBar',
    'OnDetaching']);
  HideClassProperties(TdxRibbonDropDownGallery, ['BackgroundBitmap',
    'BarManager', 'UseRecentItems']);
  HideClassProperties(TdxRibbonGalleryOptions, ['ShowScrollBar']);
end;

end.
