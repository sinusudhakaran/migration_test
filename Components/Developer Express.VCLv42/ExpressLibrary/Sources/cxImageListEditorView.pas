
{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           Express Cross Platform Library classes                   }
{                                                                    }
{           Copyright (c) 2000-2009 Developer Express Inc.           }
{           ALL RIGHTS RESERVED                                      }
{                                                                    }
{   The entire contents of this file is protected by U.S. and        }
{   International Copyright Laws. Unauthorized reproduction,         }
{   reverse-engineering, and distribution of all or any portion of   }
{   the code contained in this file is strictly prohibited and may   }
{   result in severe civil and criminal penalties and will be        }
{   prosecuted to the maximum extent possible under the law.         }
{                                                                    }
{   RESTRICTIONS                                                     }
{                                                                    }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES            }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE     }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS    }
{   LICENSED TO DISTRIBUTE THE EXPRESSCROSSPLATFORMLIBRARY AND ALL   }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM       }
{   ONLY.                                                            }
{                                                                    }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED       }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE         }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE        }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT   }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                       }
{                                                                    }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON        }
{   ADDITIONAL RESTRICTIONS.                                         }
{                                                                    }
{********************************************************************}

unit cxImageListEditorView;

{$I cxVer.inc}

interface

uses
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, ComCtrls, CommCtrl, Menus, ImgList, ToolWin, cxGraphics,
  cxClasses, cxImageListEditor, ActnList, Dialogs, ExtDlgs;

type
  TcxImageListEditorFormInternalState = (eisSelectingTransparentColor);
  TcxImageListEditorFormInternalStates = set of TcxImageListEditorFormInternalState;

  TcxImageListEditorForm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnApply: TButton;
    gbSelectedImage: TGroupBox;
    pbPreview: TPaintBox;
    lbTransparentColor: TLabel;
    cbTransparentColor: TComboBox;
    gbImages: TGroupBox;
    lvImages: TListView;
    pnlToolBarSubstrate: TPanel;
    tbCommands: TToolBar;
    tbbAdd: TToolButton;
    tbbDelete: TToolButton;
    tbbClear: TToolButton;
    tbbExport: TToolButton;
    tbbReplace: TToolButton;
    tbbImport: TToolButton;
    pmImageLists: TPopupMenu;
    pmCommands: TPopupMenu;
    miAdd: TMenuItem;
    miReplace: TMenuItem;
    miDelete: TMenuItem;
    miClear: TMenuItem;
    miExport: TMenuItem;
    miImport: TMenuItem;
    lblManifestWarning: TLabel;
    imgWarning: TImage;
    imglSmall: TcxImageList;
    spdSave: TSavePictureDialog;
    actlCommands: TActionList;
    actAdd: TAction;
    actInsert: TAction;
    actReplace: TAction;
    actDelete: TAction;
    actClear: TAction;
    actImport: TAction;
    actApply: TAction;
    actOK: TAction;
    opdOpen: TOpenPictureDialog;
    cbImagesSize: TComboBox;
    AsBitmap1: TMenuItem;
    AsPNG1: TMenuItem;
    actExportAsBitmap: TAction;
    actExportAsPNG: TAction;
    pmExport: TPopupMenu;
    AsBitmap2: TMenuItem;
    AsPNG2: TMenuItem;
    actExport: TAction;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure cbImagesSizeChange(Sender: TObject);
    procedure cbTransparentColorChange(Sender: TObject);
    procedure cbTransparentColorExit(Sender: TObject);

    procedure lvImagesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvImagesDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lvImagesEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure lvImagesStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure lvImagesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

    procedure pbPreviewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbPreviewMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pbPreviewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbPreviewPaint(Sender: TObject);

    procedure actAddExecute(Sender: TObject);
    procedure actInsertExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actImportExecute(Sender: TObject);
    procedure actApplyExecute(Sender: TObject);
    procedure actOKExecute(Sender: TObject);
    procedure actExportAsBitmapExecute(Sender: TObject);
    procedure actExportAsPNGExecute(Sender: TObject);
    procedure actExportExecute(Sender: TObject);
  private
    FImageListEditor: TcxImageListEditor;
    FImportList: TStrings;
    FDragImageIndex: Integer;
    FPreviewImageList: TcxImageList;
    FInternalState: TcxImageListEditorFormInternalStates;

    procedure AddColor(const AColor: string);
    function ChangeImagesSize: Boolean;
    procedure DrawFocusedItem(ACanvas: TCanvas; ARect: TRect);
    function GetColorFromCursorPos(X, Y: Integer): TColor;
    function GetFocusedImageIndex: Integer;
    function IsValidImagesSize(ADisplayImagesSizeValue: string; out ASize: TSize): Boolean;
    procedure SetFocusedImageIndex(AValue: Integer);

    procedure AddImages(AAddMode: TcxImageListEditorAddMode);
    procedure ImportImageList(Sender: TObject);
    procedure PopulateImportItems;

    procedure DataChanged(Sender: TObject);

    procedure UpdateActions; reintroduce;
    procedure UpdateControls;
    procedure UpdateImagesSizeIndicator;
    procedure UpdateTransparentColor(AColor: TColor); overload;
    procedure UpdateTransparentColor(X, Y: Integer); overload;
    procedure UpdateTransparentColorIndicator(AColor: TColor);

    property FocusedImageIndex: Integer read GetFocusedImageIndex write SetFocusedImageIndex;
  public
    constructor Create(AImageListEditor: TcxImageListEditor); reintroduce;
    destructor Destroy; override;

    function GetVisualDataControl: TListView;
    procedure SetImportList(AValue: TStrings);
  end;

implementation

{$R *.dfm}

uses
  Types, Math, cxGeometry, cxControls, dxOffice11, cxLibraryConsts;

type
  TcxImageListAccess = class(TcxImageList);

{ TcxImageListEditorForm }

constructor TcxImageListEditorForm.Create(AImageListEditor: TcxImageListEditor);
begin
  inherited Create(nil);
  FImageListEditor := AImageListEditor;
  FImageListEditor.OnChange := DataChanged;

  FPreviewImageList := TcxImageList.Create(Self);

{$IFDEF DELPHI9}
  PopupMode := pmAuto;
{$ENDIF}

  if IsXPManifestEnabled then
  begin
    imgWarning.Visible := True;
    lblManifestWarning.Caption := 'These images may be distorted if used in standard Windows UI controls with XPManifest enabled.';
    lblManifestWarning.Visible := True;
    Width := Width + MulDiv(6{Rows} * 3{Pixel}, Screen.PixelsPerInch, 96);
  end;
end;

destructor TcxImageListEditorForm.Destroy;
begin
  FreeAndNil(FPreviewImageList);
  inherited;
end;

function TcxImageListEditorForm.GetVisualDataControl: TListView;
begin
  Result := lvImages;
end;

procedure TcxImageListEditorForm.SetImportList(AValue: TStrings);
begin
  FImportList := AValue;
  PopulateImportItems;
end;

procedure TcxImageListEditorForm.FormCreate(Sender: TObject);
begin
  lvImages.OnChange := lvImagesChange;

  pbPreview.Cursor := crcxColorPicker;
  GetColorValues(AddColor);
  FDragImageIndex := -1;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
end;

procedure TcxImageListEditorForm.FormDestroy(Sender: TObject);
begin
  lvImages.OnChange := nil;
end;

procedure TcxImageListEditorForm.cbImagesSizeChange(Sender: TObject);
begin
  if not ChangeImagesSize then
    UpdateImagesSizeIndicator;
end;

procedure TcxImageListEditorForm.cbTransparentColorChange(Sender: TObject);
begin
  if cbTransparentColor.Items.IndexOf(cbTransparentColor.Text) <> -1 then
    UpdateTransparentColor(StringToColor(cbTransparentColor.Text));
end;

procedure TcxImageListEditorForm.cbTransparentColorExit(Sender: TObject);
begin
  UpdateTransparentColor(StringToColor(cbTransparentColor.Text));
end;

procedure TcxImageListEditorForm.lvImagesChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  UpdateControls;
end;

procedure TcxImageListEditorForm.lvImagesDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := lvImages.GetItemAt(X, Y) <> nil;
end;

procedure TcxImageListEditorForm.lvImagesEndDrag(Sender, Target: TObject; X,
  Y: Integer);
var
  ATargetItem: TListItem;
begin
  FImageListEditor.EndUpdate;
  ATargetItem := lvImages.GetItemAt(X, Y);
  if ATargetItem <> nil then
    FImageListEditor.MoveImage(FDragImageIndex, ATargetItem.ImageIndex)
  else
    FocusedImageIndex := FDragImageIndex;
  FDragImageIndex := -1;
end;

procedure TcxImageListEditorForm.lvImagesStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  FImageListEditor.BeginUpdate;
  FDragImageIndex := FImageListEditor.FocusedImageIndex;
end;

procedure TcxImageListEditorForm.lvImagesKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
    FImageListEditor.DeleteSelectedImages;
end;

procedure TcxImageListEditorForm.pbPreviewMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then
  begin
    Include(FInternalState, eisSelectingTransparentColor);  
    UpdateTransparentColor(X, Y);
  end;
end;

procedure TcxImageListEditorForm.pbPreviewMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if eisSelectingTransparentColor in FInternalState then
    UpdateTransparentColor(X, Y);
end;

procedure TcxImageListEditorForm.pbPreviewMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Exclude(FInternalState, eisSelectingTransparentColor);
end;

procedure TcxImageListEditorForm.pbPreviewPaint(Sender: TObject);
var
  ARect: TRect;
begin
  ARect := pbPreview.ClientRect;
  FrameRectByColor(pbPreview.Canvas.Handle, ARect, clNavy);
  InflateRect(ARect, -1, -1);
  cxDrawHatch(pbPreview.Canvas.Handle, ARect, $BFBFBF, clWhite, 8);
  DrawFocusedItem(pbPreview.Canvas, ARect);
end;

procedure TcxImageListEditorForm.AddColor(const AColor: string);
begin
  cbTransparentColor.Items.Add(AColor);
end;

function TcxImageListEditorForm.ChangeImagesSize: Boolean;
var
  ASize: TSize;
begin
  Result := IsValidImagesSize(cbImagesSize.Text, ASize) and FImageListEditor.ChangeImagesSize(ASize);
end;

procedure TcxImageListEditorForm.DrawFocusedItem(ACanvas: TCanvas; ARect: TRect);
begin
  if FImageListEditor.IsAnyImageSelected then
  begin
    FPreviewImageList.Width := FImageListEditor.ImageWidth;
    FPreviewImageList.Height := FImageListEditor.ImageHeight;    
    TcxImageListAccess(FPreviewImageList).AddImageInfo(FImageListEditor.ImagesInfo[FocusedImageIndex]);
    FPreviewImageList.Draw(ACanvas, ARect, 0);
    FPreviewImageList.Clear;
  end;
end;

function TcxImageListEditorForm.GetColorFromCursorPos(X, Y: Integer): TColor;
begin
  if cxRectPtIn(Rect(0, 0, pbPreview.Width, pbPreview.Height), X, Y) then
  begin
    X := X * FImageListEditor.ImageWidth div pbPreview.Width;
    Y := Y * FImageListEditor.ImageHeight div pbPreview.Height;
    Result := FImageListEditor.ImagesInfo[FocusedImageIndex].Image.Canvas.Pixels[X, Y];
  end
  else
    Result := FImageListEditor.ImagesInfo[FocusedImageIndex].MaskColor;
end;

function TcxImageListEditorForm.GetFocusedImageIndex: Integer;
begin
  Result := FImageListEditor.FocusedImageIndex;
end;

function TcxImageListEditorForm.IsValidImagesSize(ADisplayImagesSizeValue: string; out ASize: TSize): Boolean;
var
  APosition: Integer;
begin
  APosition := Pos('x', ADisplayImagesSizeValue);
  Result := (APosition <> 0) and
    TryStrToInt(Copy(ADisplayImagesSizeValue, 1, APosition - 1), ASize.cx) and
    TryStrToInt(Copy(ADisplayImagesSizeValue, APosition + 1, Length(ADisplayImagesSizeValue) - APosition), ASize.cy);
end;

procedure TcxImageListEditorForm.SetFocusedImageIndex(AValue: Integer);
begin
  FImageListEditor.FocusedImageIndex := AValue;
end;

procedure TcxImageListEditorForm.AddImages(AAddMode: TcxImageListEditorAddMode);
begin
  opdOpen.Filter := cxImageFileFormats.GetFilter;
  if opdOpen.Execute then
    FImageListEditor.AddImages(opdOpen.Files, AAddMode);
end;

procedure TcxImageListEditorForm.ImportImageList(Sender: TObject);
begin
  FImageListEditor.ImportImages(FImportList.Objects[TMenuItem(Sender).Tag] as TCustomImageList);
end;

procedure TcxImageListEditorForm.PopulateImportItems;

  procedure PopulateItem(AParentItem: TMenuItem; const APrefix: string);
  var
    AMenuItem: TMenuItem;
    I: Integer;
  begin
    AParentItem.Clear;
    for I := 0 to FImportList.Count - 1 do
    begin
      AMenuItem := TMenuItem.Create(Self);
      AMenuItem.OnClick := ImportImageList;
      AMenuItem.Caption := APrefix + FImportList[I];
      AMenuItem.Tag := I;
      AMenuItem.ImageIndex := 5;
      AParentItem.Add(AMenuItem);
    end;
  end;

begin
  PopulateItem(pmImageLists.Items, 'Import from ');
  PopulateItem(miImport, 'from ');
end;

procedure TcxImageListEditorForm.DataChanged(Sender: TObject);
begin
  UpdateControls;
end;

procedure TcxImageListEditorForm.UpdateActions;
begin
  actDelete.Enabled := FImageListEditor.IsAnyImageSelected;
  actClear.Enabled := FImageListEditor.ImagesCount > 0;
  actExport.Enabled := FImageListEditor.ImagesCount > 0;
  actExportAsBitmap.Enabled := actExport.Enabled;
  actExportAsPNG.Enabled := actExport.Enabled;
  actReplace.Enabled := FImageListEditor.IsAnyImageSelected;
  actInsert.Enabled := FImageListEditor.IsAnyImageSelected;
  actApply.Enabled := FImageListEditor.IsChanged;
  actImport.Enabled := (FImportList <> nil) and (FImportList.Count <> 0);
end;

procedure TcxImageListEditorForm.UpdateControls;
var
  AAllowSelectTransparentColor: Boolean;
begin
  if FImageListEditor.IsUpdateLocked then
    Exit;

  AAllowSelectTransparentColor := FImageListEditor.IsAnyImageSelected and
    not IsGlyphAssigned(FImageListEditor.ImagesInfo[FocusedImageIndex].Mask) and
    not FImageListEditor.ImagesInfo[FocusedImageIndex].AlphaUsed;

  //gbSelectedImage
  pbPreview.Enabled := AAllowSelectTransparentColor;
  cbTransparentColor.Enabled := AAllowSelectTransparentColor;
  lbTransparentColor.Enabled := AAllowSelectTransparentColor;

  pbPreview.Invalidate;

  if AAllowSelectTransparentColor then
    UpdateTransparentColorIndicator(FImageListEditor.ImagesInfo[FocusedImageIndex].MaskColor)
  else
    UpdateTransparentColorIndicator(clNone);

  UpdateImagesSizeIndicator;
  UpdateActions;
end;

procedure TcxImageListEditorForm.UpdateImagesSizeIndicator;
var
  AImagesSizeDisplayText: string;
  ASizeIndex: Integer;
begin
  AImagesSizeDisplayText := Format('%dx%d', [FImageListEditor.ImageWidth, FImageListEditor.ImageHeight]);
  ASizeIndex := cbImagesSize.Items.IndexOf(AImagesSizeDisplayText);
  if ASizeIndex <> -1 then
    cbImagesSize.ItemIndex := ASizeIndex
  else
    cbImagesSize.Items.Add(AImagesSizeDisplayText);
end;

procedure TcxImageListEditorForm.UpdateTransparentColor(AColor: TColor);
begin
  FImageListEditor.UpdateTransparentColor(AColor);
end;

procedure TcxImageListEditorForm.UpdateTransparentColor(X, Y: Integer);
begin
  UpdateTransparentColor(GetColorFromCursorPos(X, Y));
end;

procedure TcxImageListEditorForm.UpdateTransparentColorIndicator(AColor: TColor);
begin
  cbTransparentColor.Text := ColorToString(AColor);
end;

procedure TcxImageListEditorForm.actAddExecute(Sender: TObject);
begin
  AddImages(amAdd);
end;

procedure TcxImageListEditorForm.actInsertExecute(Sender: TObject);
begin
  AddImages(amInsert);
end;

procedure TcxImageListEditorForm.actReplaceExecute(Sender: TObject);
begin
  AddImages(amReplace);
end;

procedure TcxImageListEditorForm.actDeleteExecute(Sender: TObject);
begin
  FImageListEditor.DeleteSelectedImages;
end;

procedure TcxImageListEditorForm.actClearExecute(Sender: TObject);
begin
  FImageListEditor.ClearImages;
end;

procedure TcxImageListEditorForm.actImportExecute(Sender: TObject);
begin
  // (don't remove this method)
end;

procedure TcxImageListEditorForm.actApplyExecute(Sender: TObject);
begin
  FImageListEditor.ApplyChanges;
end;

procedure TcxImageListEditorForm.actOKExecute(Sender: TObject);
begin
  FImageListEditor.ApplyChanges;
end;

procedure TcxImageListEditorForm.actExportAsBitmapExecute(Sender: TObject);
begin
  spdSave.DefaultExt := '*.bmp';
  spdSave.Filter := 'Bitmaps (*.bmp)|*.bmp';
  if spdSave.Execute then
    FImageListEditor.ExportImages(spdSave.FileName, itBitmap);
end;

procedure TcxImageListEditorForm.actExportAsPNGExecute(Sender: TObject);
begin
  spdSave.DefaultExt := '*.png';
  spdSave.Filter := 'PNG (*.png)|*.png';
  if spdSave.Execute then
    FImageListEditor.ExportImages(spdSave.FileName, itPNG);
end;

procedure TcxImageListEditorForm.actExportExecute(Sender: TObject);
begin
  // (don't remove this method)
end;

end.
