
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

unit cxImageListEditor;

{$I cxVer.inc}

interface

uses
  dxGDIPlusAPI, dxGDIPlusClasses,
  Windows, SysUtils, Classes, ImgList, ComCtrls, Controls, Graphics, Forms, Dialogs,
  cxClasses, cxGeometry, cxGraphics;

type
  TcxEditorImageInfo = class(TcxImageInfo)
  private
    FAlphaUsed: Boolean;
  protected
    procedure SetImage(Value: TBitmap); override;
  public
    property AlphaUsed: Boolean read FAlphaUsed;
  end;

  TcxImageFileFormat = record
    Name: string;
    Ext: string;
    GraphicClass: TGraphicClass;
  end;

  TcxImageFileFormatList = array of TcxImageFileFormat;

  TcxImageFileFormats = class
  private
    FList: TcxImageFileFormatList;

    function Count: Integer;
    function GetItem(Index: Integer): TcxImageFileFormat;

    property Items[Index: Integer]: TcxImageFileFormat read GetItem;
  public
    procedure Register(const AName, AExt: string; AGraphicClass: TGraphicClass);
//TODO:    procedure UnRegister(AGraphicClass: TGraphicClass);
    function GetGraphicClass(const AFileName: string): TGraphicClass;
    function GetFilter: string;
  end;

  TcxImageListEditorAddMode = (amAdd, amInsert, amReplace);
  TcxImageType = (itBitmap, itIco, itPNG);

  TcxImageListEditor = class
  private
    FChanged: Boolean;
    FImageListModified: Boolean;

    FDataControl: TListView;
    FImageList: TcxImageList;
    FOriginalImageList: TcxImageList;

    FImportList: TStrings;
    FVisibleImportList: TStrings;

    FEditorForm: TForm;
    FSplitBitmaps: TModalResult;
    FUpdateCount: Integer;

    FOnChange: TNotifyEvent;

    procedure AddDataItems(AImageList: TcxImagelist);
    procedure AddImage(AImage, AMask: TBitmap; AMaskColor: TColor; var AInsertedImageIndex: Integer);
    procedure Change;
    procedure ClearSelection;
    procedure DeleteDataItem(Sender: TObject; Item: TListItem);
    procedure DeleteImage(AIndex: Integer);
    function GetImagesCount: Integer;
    function GetDataItems: TListItems;
    function GetDefaultTransparentColor(AImage, AMask: TBitmap): TColor;
    function GetFocusedImageIndex: Integer;
    function GetImageHeight: Integer;
    function GetImagesInfo(Index: Integer): TcxEditorImageInfo;
    function GetImageWidth: Integer;
    procedure ImageListChanged;
    procedure SelectDataItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure SetFocusedImageIndex(AValue: Integer);
    procedure SetImageList(AValue: TcxImageList);
    procedure SetImagesInfo(Index: Integer; AValue: TcxEditorImageInfo);
    procedure SetImportList(AValue: TStrings);

    procedure UpdateImageList;
    procedure UpdateVisibleImportList;
  public
    constructor Create;
    destructor Destroy; override;

    function Edit(AImageList: TcxImagelist): Boolean;

    procedure AddImages(AFiles: TStrings; AAddMode: TcxImageListEditorAddMode);
    procedure ClearImages;
    procedure DeleteSelectedImages;
    procedure ExportImages(const AFileName: string; AFormat: TcxImageType = itBitmap);
    function InternalAddImage(AImage, AMask: TBitmap; AFileName: string;
      var AInsertedItemIndex: Integer; AMultiSelect: Boolean): Integer;
    procedure ImportImages(AImageList: TCustomImageList);
    procedure MoveImage(ASourceImageIndex, ADestImageIndex: Integer);

    function IsAnyImageSelected: Boolean;

    procedure BeginUpdate;
    procedure EndUpdate;
    function IsUpdateLocked: Boolean;

    procedure ApplyChanges;
    function IsChanged: Boolean;
    procedure UpdateTransparentColor(AColor: TColor);
    function ChangeImagesSize(AValue: TSize): Boolean;
    procedure SynchronizeData(AStartIndex, ACount: Integer);

    property DataControl: TListView read FDataControl;
    property DataItems: TListItems read GetDataItems;
    property FocusedImageIndex: Integer read GetFocusedImageIndex write SetFocusedImageIndex;
    property ImageHeight: Integer read GetImageHeight;
    property ImageList: TcxImageList read FImageList write SetImageList;
    property ImageListModified: Boolean read FImageListModified;
    property ImagesCount: Integer read GetImagesCount;
    property ImagesInfo[Index: Integer]: TcxEditorImageInfo read GetImagesInfo write SetImagesInfo;
    property ImageWidth: Integer read GetImageWidth;
    property ImportList: TStrings read FImportList write SetImportList;
    property OriginalImageList: TcxImageList read FOriginalImageList;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

function cxImageFileFormats: TcxImageFileFormats;
function cxEditImageList(AImageList: TcxImageList; AImportList: TStrings): Boolean;
procedure PngImageListTocxImageList(APngImages: TComponent; AImages: TcxImageList);

implementation

uses
  Types, Math, cxImageListEditorView, dxCore;

var
  FImageFileFormats: TcxImageFileFormats;

type
  TcxImageListAccess = class(TcxImageList);

  TcxIcon = class(TIcon)
  protected
    procedure SetBitmap(ABitmap: TBitmap);
  public
    procedure GetImageInfo(AImageInfo: TcxImageInfo);
    procedure HandleNeeded;
  end;

procedure TcxIcon.GetImageInfo(AImageInfo: TcxImageInfo);
var
  AImages: TcxImageListAccess;
begin
  HandleNeeded;
  AImages := TcxImageListAccess.CreateSize(Width, Height);
  try
    AImages.AddIcon(Self);
    AImages.GetImageInfo(0, AImageInfo);
  finally
    AImages.Free;
  end;
end;

procedure TcxIcon.HandleNeeded;
begin
  Handle;
end;

procedure TcxIcon.SetBitmap(ABitmap: TBitmap);
var
  AImageList: TcxImageList;
begin
  AImageList := TcxImageList.CreateSize(ABitmap.Width, ABitmap.Height);
  try
   AImageList.Add(ABitmap, nil);
   AImageList.GetIcon(0, Self, dsTransparent, itImage);
  finally
   AImageList.Free;
  end;
end;

function cxImageFileFormats: TcxImageFileFormats;
begin
  Result := FImageFileFormats;
end;

function cxEditImageList(AImageList: TcxImageList; AImportList: TStrings): Boolean;
var
  AImageListEditor: TcxImageListEditor;
begin
  Result := False;
  if AImageList = nil then
    Exit;
  AImageListEditor := TcxImageListEditor.Create;
  try
    AImageListEditor.ImportList := AImportList;
    Result := AImageListEditor.Edit(AImageList);
  finally
    AImageListEditor.Free;
  end;
end;

function IsIndexValid(AIndex, ACount: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < ACount);
end;

function IsBitmapAlphaUsed(AImage: TBitmap): Boolean;
var
  ATempBitmap: TcxBitmap;
begin
  ATempBitmap := TcxBitmap.Create;
  ATempBitmap.Assign(AImage);
  try
    Result := ATempBitmap.IsAlphaUsed;
  finally
    ATempBitmap.Free;
  end;
end;

procedure AddImageFromBinaryData(WriteData: TStreamProc; AImages: TcxImageList);
var
  AStream: TMemoryStream;
  ACount: Longint;
  B: TBitmap;
begin
  AStream := TMemoryStream.Create;
  try
    WriteData(AStream);
    ACount := AStream.Size;
    if ACount > 0 then
    begin
      AStream.Write(AStream.Memory^, ACount);
      AStream.Position := 0;
      with TdxPNGImage.Create do
      try
        LoadFromStream(AStream);
        B := GetAsBitmap;
        try
          AImages.Add(B, nil);
        finally
          B.Free;
        end;
      finally
        Free;
      end;
    end;
  finally
    AStream.Free;
  end;
end;

procedure ProcessPngImageList(AInputSteram: TMemoryStream; AImages: TcxImageList);
var
  ASaveSeparator: Char;
  AParser: TParser;

  function ConvertOrderModifier: Integer;
  begin
    Result := -1;
    if AParser.Token = '[' then
    begin
      AParser.NextToken;
      AParser.CheckToken(toInteger);
      Result := AParser.TokenInt;
      AParser.NextToken;
      AParser.CheckToken(']');
      AParser.NextToken;
    end;
  end;

  procedure ConvertHeader(AIsInherited, AIsInline: Boolean);
  var
    AClassName, AObjectName: string;
  begin
    AParser.CheckToken(toSymbol);
    AClassName := AParser.TokenString;
    AObjectName := '';
    if AParser.NextToken = ':' then
    begin
      AParser.NextToken;
      AParser.CheckToken(toSymbol);
      AObjectName := AClassName;
      AClassName := AParser.TokenString;
      AParser.NextToken;
    end;
    ConvertOrderModifier;
  end;

  procedure ConvertProperty; forward;

  procedure ConvertValue(const APropName: string);

    procedure SkipString;
    begin
      while AParser.NextToken = '+' do
      begin
        AParser.NextToken;
        if not dxCharInSet(AParser.Token, [toString, toWString]) then
          AParser.CheckToken(toString);
      end;
    end;

    procedure SkipBinaryData;
    var
      S: TMemoryStream;
    begin
      S := TMemoryStream.Create;
      try
        AParser.HexToBinary(S);
      finally
        S.Free;
      end;
    end;

  begin
    if dxCharInSet(AParser.Token, [toString, toWString]) then
      SkipString
    else
    begin
      case AParser.Token of
        toSymbol, toInteger, toFloat:;
        '[':
          begin
            AParser.NextToken;
            if AParser.Token <> ']' then
              while True do
              begin
                if AParser.NextToken = ']' then Break;
                AParser.CheckToken(',');
                AParser.NextToken;
              end;
          end;
        '(':
          begin
            AParser.NextToken;
            while AParser.Token <> ')' do
              ConvertValue('');
          end;
        '{':
          begin
            if APropName = 'PngImage.Data' then
              AddImageFromBinaryData(AParser.HexToBinary, AImages)
            else
              SkipBinaryData;
          end;
        '<':
          begin
            AParser.NextToken;
            while AParser.Token <> '>' do
            begin
              AParser.CheckTokenSymbol('item');
              AParser.NextToken;
              ConvertOrderModifier;
              AParser.TokenString;
              while not AParser.TokenSymbolIs('end') do ConvertProperty;
              AParser.NextToken;
            end;
          end;
      else
        raise EdxException.Create('Convert error');
      end;
      AParser.NextToken;
    end;
  end;

  procedure ConvertProperty;
  var
    APropName: string;
  begin
    AParser.CheckToken(toSymbol);
    APropName := AParser.TokenString;
    AParser.NextToken;
    while AParser.Token = '.' do
    begin
      AParser.NextToken;
      AParser.CheckToken(toSymbol);
      APropName := APropName + '.' + AParser.TokenString;
      AParser.NextToken;
    end;
    AParser.CheckToken('=');
    AParser.NextToken;
    ConvertValue(APropName);
  end;

  procedure ConvertObject;
  var
    AInheritedObject: Boolean;
    AInlineObject: Boolean;
  begin
    AInheritedObject := False;
    AInlineObject := False;
    if AParser.TokenSymbolIs('INHERITED') then
      AInheritedObject := True
    else if AParser.TokenSymbolIs('INLINE') then
      AInlineObject := True
    else
      AParser.CheckTokenSymbol('OBJECT');
    AParser.NextToken;
    ConvertHeader(AInheritedObject, AInlineObject);
    while not AParser.TokenSymbolIs('END') and
      not AParser.TokenSymbolIs('OBJECT') and
      not AParser.TokenSymbolIs('INHERITED') and
      not AParser.TokenSymbolIs('INLINE') do
      ConvertProperty;
    while not AParser.TokenSymbolIs('END') do
      ConvertObject;
  end;

begin
  AParser := TParser.Create(AInputSteram);
  ASaveSeparator := DecimalSeparator;
  DecimalSeparator := '.';
  try
    ConvertObject;
  finally
    DecimalSeparator := ASaveSeparator;
    AParser.Free;
  end;
end;

procedure PngImageListTocxImageList(APngImages: TComponent; AImages: TcxImageList);
var
  S, D: TMemoryStream;
begin
  S := TMemoryStream.Create;
  try
    S.WriteComponent(APngImages);
    S.Position := 0;
    D := TMemoryStream.Create;
    try
      ObjectBinaryToText(S, D);
      S.Position := 0;
      D.Position := 0;
      ProcessPngImageList(D, AImages);
    finally
      D.Free;
    end;
  finally
    S.Free;
  end;
end;

{ TcxEditorImageInfo }

procedure TcxEditorImageInfo.SetImage(Value: TBitmap);
begin
  inherited;
  FAlphaUsed := IsBitmapAlphaUsed(Image);
end;

{ TcxImageFileFormats }

procedure TcxImageFileFormats.Register(const AName, AExt: string; AGraphicClass: TGraphicClass);
begin
  SetLength(FList, Count + 1);
  FList[Count - 1].Name := AName;
  FList[Count - 1].Ext := AExt;
  FList[Count - 1].GraphicClass := AGraphicClass;
end;

function TcxImageFileFormats.GetGraphicClass(const AFileName: string): TGraphicClass;
var
  I: Integer;
  AExt: string;
begin
  Result := nil;
  AExt := ExtractFileExt(AFileName);
  for I := 0 to Count - 1 do
    if SameText(AExt, Items[I].Ext) then
      Result := Items[I].GraphicClass;
end;

function TcxImageFileFormats.GetFilter: string;
var
  I: Integer;
  AAllExtentions, AAllImages: string;
begin
  AAllExtentions := '';
  AAllImages := '';
  for I := 0 to Count - 1 do
  begin
    if AAllExtentions = '' then
      AAllExtentions := '*' + Items[I].Ext
    else
      AAllExtentions := AAllExtentions + ';*' + Items[I].Ext;
    if AAllImages = '' then
      AAllImages := Items[I].Name + '|*' + Items[I].Ext
    else
      AAllImages := AAllImages + '|' + Items[I].Name + '|*' + Items[I].Ext;
  end;
  Result := 'All supported image types|' + AAllExtentions + '|' + AAllImages;
end;

function TcxImageFileFormats.Count: Integer;
begin
  Result := Length(FList);
end;

function TcxImageFileFormats.GetItem(Index: Integer): TcxImageFileFormat;
begin
  Result := FList[Index];
end;

{ TcxImageListEditor }

constructor TcxImageListEditor.Create;
begin
  inherited Create;
  FImageList := TcxImageList.Create(nil);
  FEditorForm := TcxImageListEditorForm.Create(Self);
  FImportList := TStringList.Create;
  FVisibleImportList := TStringList.Create;

  FDataControl := TcxImageListEditorForm(FEditorForm).GetVisualDataControl;
  FDataControl.SmallImages := ImageList;
  FDataControl.LargeImages := ImageList;
  FDataControl.OnDeletion := DeleteDataItem;
  FDataControl.OnSelectItem := SelectDataItem;
end;

destructor TcxImageListEditor.Destroy;
begin
  ClearImages;
  FDataControl.OnSelectItem := nil;
  FDataControl.OnDeletion := nil;
  FDataControl := nil;
  FreeAndNil(FVisibleImportList);
  FreeAndNil(FImportList);
  FreeAndNil(FEditorForm);
  FreeAndNil(FImageList);
  inherited;
end;

function TcxImageListEditor.Edit(AImageList: TcxImagelist): Boolean;
var
  ACaption: string;
begin
  ImageList := AImageList;
  ACaption := AImageList.Name;
  if AImageList.Owner <> nil then
    ACaption := AImageList.Owner.Name + '.' + ACaption;
  FEditorForm.Caption := ACaption;
  FEditorForm.ShowModal;
  Result := FImageListModified;
end;

procedure TcxImageListEditor.AddImages(AFiles: TStrings; AAddMode: TcxImageListEditorAddMode);

  function GetImageInfoFromFile(const AFileName: string; AImageInfo: TcxImageInfo): Boolean;
  var
    AGraphic: TGraphic;
    AGraphicClass: TGraphicClass;
  begin
    AImageInfo.Image := nil;
    AImageInfo.Mask := nil;
    AImageInfo.MaskColor := clNone;
    AGraphicClass := cxImageFileFormats.GetGraphicClass(AFileName);
    Result := AGraphicClass <> nil;
    if Result then
    begin
      AGraphic := AGraphicClass.Create;
      try
        AGraphic.LoadFromFile(AFileName);
        if AGraphic is TdxPNGImage then // TODO:
          AImageInfo.Image := TdxPNGImage(AGraphic).GetAsBitmap
        else
          if AGraphic is TcxIcon then
          begin
            AGraphic.Width := ImageWidth;
            AGraphic.Height := ImageHeight;
            TcxIcon(AGraphic).GetImageInfo(AImageInfo)
          end
          else //TBitmap
            AImageInfo.Image := TBitmap(AGraphic);
      finally
        AGraphic.Free;
      end;
    end;
  end;

var
  AImageInfo: TcxImageInfo;
  I, AInsertedItemIndex: Integer;
begin
  case AAddMode of
    amAdd:
      AInsertedItemIndex := ImagesCount;
    amInsert:
      AInsertedItemIndex := Max(0, FocusedImageIndex);
  else {amReplace}
    AInsertedItemIndex := FocusedImageIndex;
    DeleteImage(AInsertedItemIndex);
  end;

  FSplitBitmaps := mrNone;
  ClearSelection;
  Application.ProcessMessages;
  AImageInfo := TcxImageInfo.Create;
  try
    for I := 0 to AFiles.Count - 1 do
      if GetImageInfoFromFile(AFiles[I], AImageInfo) then
        InternalAddImage(AImageInfo.Image, AImageInfo.Mask, AFiles[I], AInsertedItemIndex, AFiles.Count > 1);
  finally
    AImageInfo.Free;
  end;
  FocusedImageIndex := AInsertedItemIndex - 1;
end;

procedure TcxImageListEditor.ClearImages;
begin
  DataItems.Clear;
  UpdateImageList;
end;

procedure TcxImageListEditor.DeleteSelectedImages;
var
  ASelectedIndex: Integer;
  I: Integer;
begin
  if not IsAnyImageSelected then
    Exit;
  ASelectedIndex := FocusedImageIndex;
  for I := ImagesCount - 1 downto 0 do
    if DataItems[I].Selected then
      DeleteImage(I);
  FocusedImageIndex := Min(ASelectedIndex, ImagesCount - 1);
end;

procedure TcxImageListEditor.ExportImages(const AFileName: string; AFormat: TcxImageType = itBitmap);

  function CanReplace: Boolean;
  begin
    Result := MessageDlg(Format('File %s is already exists.' + dxEndOfLine +
      'Do you want to replace it?',
      [AFileName]), mtWarning, [mbYes, mbNo], 0) = mrYes;
  end;
  
  procedure SelectAllImages;
  var
    I: Integer;
  begin
    for I := 0 to ImagesCount - 1 do
      DataItems[I].Selected := True;
  end;

  function GetSelectionCount: Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 0 to ImagesCount - 1 do
      if DataItems[I].Selected then
        Inc(Result);
  end;

  procedure ExportBitmap(ABitmap: TBitmap);
  var
    AIcon: TcxIcon;
    APNGImage: TdxPNGImage;
  begin
    case AFormat of
      itBitmap: ABitmap.SaveToFile(AFileName);
      itIco:
        begin
          AIcon := TcxIcon.Create;
          try
            AIcon.SetBitmap(ABitmap);
            AIcon.SaveToFile(AFileName);
          finally
            AIcon.Free;
          end;
        end;
      itPNG:
        begin
          APNGImage := TdxPNGImage.Create;
          try
            APNGImage.SetBitmap(ABitmap);
            APNGImage.SaveToFile(AFileName);
          finally
            APNGImage.Free;
          end;
        end;
    end;
  end;

var
  AImageIndex: Integer;
  ASelectedItem: TListItem;
  AExportImage: TcxBitmap;
  ARect: TRect;
begin
  if not FileExists(AFileName) or CanReplace then
  begin
    Application.ProcessMessages;
    ASelectedItem := FDataControl.Selected;
    if not IsAnyImageSelected then
      SelectAllImages;
    AExportImage := TcxBitmap.CreateSize(ImageList.Width * GetSelectionCount, ImageList.Height);
    try
      ARect := cxRect(0, 0, ImageList.Width, ImageList.Height);
      for AImageIndex := 0 to ImagesCount - 1 do
        if DataItems[AImageIndex].Selected then
        begin
          AExportImage.CopyBitmap(ImagesInfo[AImageIndex].Image, ARect, cxNullPoint);
          ARect := cxRectOffset(ARect, ImageList.Width, 0);
        end;
      ExportBitmap(AExportImage);
      FDataControl.Selected := ASelectedItem;
    finally
      AExportImage.Free;
    end;
  end;
end;

procedure TcxImageListEditor.ImportImages(AImageList: TCustomImageList);
begin
  if AImageList.Count <> 0 then
  begin
    if (AImageList.ClassName = 'TPngImageList') and CheckGdiPlus then
      PngImageListTocxImageList(AImageList, ImageList)
    else
      ImageList.CopyImages(AImageList);
    SynchronizeData(ImagesCount, AImageList.Count);
    FChanged := True;
    FocusedImageIndex := ImagesCount - 1;
  end;
  Change;
end;

function TcxImageListEditor.InternalAddImage(AImage, AMask: TBitmap; AFileName: string;
  var AInsertedItemIndex: Integer; AMultiSelect: Boolean): Integer;

  function GetUserPermissionForSplit(AFileName: string; AMultiSelect: Boolean): Boolean;
  const
    scxBitmapSplitQuery = 'The bitmap in the file %s is too large.' + dxEndOfLine +
      'Do you want to split it into smaller bitmaps?';
  var
    APossibleAnswers: TMsgDlgButtons;
  begin
    APossibleAnswers := [mbYes, mbNo];
    if AMultiSelect then
        APossibleAnswers := APossibleAnswers + [mbNoToAll, mbYesToAll];
    FSplitBitmaps := MessageDlg(Format(scxBitmapSplitQuery, [AFileName]), mtConfirmation, APossibleAnswers, 0);
    Result := FSplitBitmaps in [mrYes, mrYesToAll, mrCancel];
  end;

var
  AColCount, ARowCount, AColIndex, ARowIndex: Integer;
  ASourceImageSize: TSize;
  ASplitImages: Boolean;
  ADestBitmap, ADestMask: TcxCustomBitmap;
  ADestRect: TRect;
  ASrcPoint: TPoint;
begin
  Result := -1;

  ASplitImages := ((AImage.Width mod ImageWidth) + (AImage.Height mod ImageHeight)) = 0;

  if ((AImage.Width = ImageWidth) and (AImage.Height = ImageHeight)) or
    ASplitImages and
    (FSplitBitmaps <> mrNoToAll) and
    ((FSplitBitmaps = mrYesToAll) or GetUserPermissionForSplit(AFileName, AMultiSelect)) then
    ASourceImageSize := cxSize(ImageWidth, ImageHeight)
  else
    ASourceImageSize := cxSize(AImage.Width, AImage.Height);

  AColCount := AImage.Width div ASourceImageSize.cx;
  ARowCount := AImage.Height div ASourceImageSize.cy;

  ADestBitmap := TcxCustomBitmap.CreateSize(ImageWidth, ImageHeight, pf32bit);
  if IsGlyphAssigned(AMask) then
    ADestMask := TcxCustomBitmap.CreateSize(ImageWidth, ImageHeight, pf1bit)
  else
    ADestMask := nil;
  try
    for ARowIndex := 0 to ARowCount - 1 do
      for AColIndex := 0 to AColCount - 1 do
      begin
        ASrcPoint := Point(AColIndex * ASourceImageSize.cx, ARowIndex * ASourceImageSize.cy);

        ADestRect := cxRectCenter(ADestBitmap.ClientRect, Min(ImageWidth, ASourceImageSize.cx), Min(ImageHeight, ASourceImageSize.cy));
        ADestBitmap.Canvas.Brush.Color := GetDefaultTransparentColor(AImage, AMask);
        ADestBitmap.Canvas.FillRect(ADestBitmap.ClientRect);

        cxDrawBitmap(ADestBitmap.Canvas.Handle, AImage, ADestRect, ASrcPoint);
        if IsGlyphAssigned(AMask) then
          cxDrawBitmap(ADestMask.Canvas.Handle, AMask, ADestRect, ASrcPoint);
        AddImage(ADestBitmap, ADestMask, GetDefaultTransparentColor(ADestBitmap, ADestMask), AInsertedItemIndex);
      end;
  finally
    ADestMask.Free;
    ADestBitmap.Free;
  end;
end;

procedure TcxImageListEditor.MoveImage(ASourceImageIndex, ADestImageIndex: Integer);
var
  AList: TList;
  I: Integer;
begin
  if ADestImageIndex <> ASourceImageIndex then
  begin
    AList := TList.Create;
    try
      for I := 0 to ImagesCount - 1 do
        AList.Add(DataItems[I].Data);
      AList.Move(ASourceImageIndex, ADestImageIndex);
      for I := 0 to ImagesCount - 1 do
        DataItems[I].Data := AList[I];
    finally
      AList.Free;
    end;
    FocusedImageIndex := ADestImageIndex;
  end;
  UpdateImageList;
end;

function TcxImageListEditor.IsAnyImageSelected: Boolean;
begin
  Result := (FocusedImageIndex <> -1) and (FDataControl.SelCount > 0);
end;

procedure TcxImageListEditor.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TcxImageListEditor.EndUpdate;
begin
  if FUpdateCount > 0 then
    Dec(FUpdateCount);
end;

function TcxImageListEditor.IsUpdateLocked: Boolean;
begin
  Result := FUpdateCount > 0;
end;

procedure TcxImageListEditor.ApplyChanges;
begin
  if IsChanged then
  begin
    FOriginalImageList.Width := ImageWidth;
    FOriginalImageList.Height := ImageHeight;
    AddDataItems(FOriginalImageList);
    //FOriginalImageList.Assign(ImageList);
    FImageListModified := True;
    FChanged := False;
  end;
  Change;
end;

function TcxImageListEditor.IsChanged: Boolean;
begin
  Result := FChanged;
end;

procedure TcxImageListEditor.UpdateTransparentColor(AColor: TColor);
var
  I: Integer;
begin
  for I := 0 to ImagesCount - 1 do
    if DataItems[I].Selected and (ImagesInfo[I].MaskColor <> AColor) then
    begin
      ImagesInfo[I].MaskColor := AColor;
      UpdateImageList;
    end;
end;

function TcxImageListEditor.ChangeImagesSize(AValue: TSize): Boolean;

  function CanChangeImagesSize: Boolean;
  begin
    Result := MessageDlg('This will change the image dimensions and remove all the existing images from the list. Do you want to proceed?',
      mtWarning, [mbYes, mbNo], 0) = mrYes;
  end;

begin
  Result := False;
  if ((ImageWidth <> AValue.cx) or (ImageHeight <> AValue.cy)) and
    ((ImagesCount = 0) or CanChangeImagesSize) then
    begin
      Result := True;
      ImageList.Width := AValue.cx;
      ImageList.Height := AValue.cy;
      UpdateVisibleImportList;
      ClearImages;
    end;
end;

procedure TcxImageListEditor.SynchronizeData(AStartIndex, ACount: Integer);
var
  I: Integer;
  AImageInfo: TcxEditorImageInfo;
begin
  for I := AStartIndex to AStartIndex + ACount - 1 do
  begin
    AImageInfo := TcxEditorImageInfo.Create;
    TcxImageListAccess(ImageList).GetImageInfo(I, AImageInfo);
    DataItems.Add.Data := AImageInfo;
  end;
  UpdateImageList;
end;

procedure TcxImageListEditor.AddDataItems(AImageList: TcxImagelist);
var
  I: Integer;
begin
  AImageList.BeginUpdate;
  try
    AImageList.Clear;
    for I := 0 to ImagesCount - 1 do
      TcxImageListAccess(AImageList).AddImageInfo(ImagesInfo[I]);
  finally
    AImageList.EndUpdate;
  end;
end;

procedure TcxImageListEditor.AddImage(AImage, AMask: TBitmap; AMaskColor: TColor; var AInsertedImageIndex: Integer);
var
  AImageInfo: TcxEditorImageInfo;
begin
  AImageInfo := TcxEditorImageInfo.Create;
  AImageInfo.Image := AImage;
  AImageInfo.Mask := AMask;
  AImageInfo.MaskColor := AMaskColor;
  DataItems.Add.Data := AImageInfo;
  MoveImage(ImagesCount - 1, AInsertedImageIndex);
  Inc(AInsertedImageIndex);
end;

procedure TcxImageListEditor.Change;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TcxImageListEditor.ClearSelection;
var
  I: Integer;
begin
  for I := 0 to ImagesCount - 1 do
    DataItems[I].Selected := False;
end;

procedure TcxImageListEditor.DeleteDataItem(Sender: TObject; Item: TListItem);
begin
  TObject(Item.Data).Free;
end;

procedure TcxImageListEditor.DeleteImage(AIndex: Integer);
begin
  if IsIndexValid(AIndex, ImagesCount) then
  begin
    DataItems.Delete(AIndex);
    UpdateImageList;
  end;
end;

function TcxImageListEditor.GetImagesCount: Integer;
begin
  Result := DataItems.Count;
end;

function TcxImageListEditor.GetDefaultTransparentColor(AImage, AMask: TBitmap): TColor;
begin
  if IsGlyphAssigned(AMask) or IsBitmapAlphaUsed(AImage) then
    Result := clNone
  else
    Result := AImage.Canvas.Pixels[0, AImage.Height - 1];
end;

function TcxImageListEditor.GetFocusedImageIndex: Integer;
begin
  Result := -1;
  if FDataControl.ItemFocused <> nil then
    Result := FDataControl.ItemFocused.Index;
end;

function TcxImageListEditor.GetImageHeight: Integer;
begin
  Result := ImageList.Height;
end;

function TcxImageListEditor.GetImagesInfo(Index: Integer): TcxEditorImageInfo;
begin
  Result := nil;
  if IsIndexValid(Index, ImagesCount) then
    Result := TcxEditorImageInfo(DataItems[Index].Data);
end;

procedure TcxImageListEditor.SetImageList(AValue: TcxImageList);
begin
  FOriginalImageList := AValue;
  ImageList.Assign(AValue);
  SynchronizeData(0, ImageList.Count);
  FChanged := False;
  FocusedImageIndex := 0;
  UpdateVisibleImportList;
end;

function TcxImageListEditor.GetImageWidth: Integer;
begin
  Result := ImageList.Width;
end;

procedure TcxImageListEditor.ImageListChanged;

  procedure InitializeListViewItem(AIndex: Integer);
  begin
    DataItems[AIndex].Caption := IntToStr(AIndex);
    DataItems[AIndex].ImageIndex := AIndex;
  end;

var
  I: Integer;
begin
  for I := 0 to ImagesCount - 1 do
    InitializeListViewItem(I);
  FChanged := True;
  Change;
end;

procedure TcxImageListEditor.SelectDataItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
    FDataControl.ItemFocused := Item;
end;

function TcxImageListEditor.GetDataItems: TListItems;
begin
  Result := FDataControl.Items;
end;

procedure TcxImageListEditor.SetFocusedImageIndex(AValue: Integer);
begin
  if IsIndexValid(AValue, ImagesCount) then
  begin
    ClearSelection;
    DataItems[AValue].Selected := True;
    FDataControl.Selected.MakeVisible(True);
  end;
end;

procedure TcxImageListEditor.SetImagesInfo(Index: Integer;
  AValue: TcxEditorImageInfo);
begin
  if DataItems[Index].Data <> AValue then
    DataItems[Index].Data := AValue;
end;

procedure TcxImageListEditor.SetImportList(AValue: TStrings);
begin
  if AValue <> nil then
    FImportList.Assign(AValue)
  else
    FImportList.Clear;
end;

procedure TcxImageListEditor.UpdateImageList;

  procedure MakeSystemBackground(ASource, ADestination: TBitmap);
  var
    R: TRect;
  begin
    R := Rect(0, 0, ADestination.Width, ADestination.Height);
    ADestination.Canvas.Brush.Color := clWindow;
    ADestination.Canvas.FillRect(R);
    cxAlphaBlend(ADestination, ASource, R, R);
  end;

var
  I: Integer;
  AImageInfo: TcxImageInfo;
  AEditorImageInfo: TcxEditorImageInfo;
begin
  ImageList.BeginUpdate;
  try
    ImageList.Clear;
    AImageInfo := TcxImageInfo.Create;
    try
      for I := 0 to ImagesCount - 1 do
      begin
        AEditorImageInfo := ImagesInfo[I];
        if AEditorImageInfo.AlphaUsed and not IsXPManifestEnabled then
        begin
          AImageInfo.Assign(AEditorImageInfo);
          MakeSystemBackground(AEditorImageInfo.Image, AImageInfo.Image);
          TcxImageListAccess(ImageList).AddImageInfo(AImageInfo);
        end
        else
          TcxImageListAccess(ImageList).AddImageInfo(AEditorImageInfo);
      end;
    finally
      AImageInfo.Free;
    end;
  finally
    ImageList.EndUpdate;
  end;
  ImageListChanged;
end;

procedure TcxImageListEditor.UpdateVisibleImportList;
var
  I: Integer;
  ACustomImageList: TCustomImageList;
begin
  FVisibleImportList.Clear;
  for I := 0 to FImportList.Count - 1 do
  begin
    ACustomImageList := TCustomImageList(FImportList.Objects[I]);
    if (ACustomImageList.Width = ImageWidth) and (ACustomImageList.Height = ImageHeight) then
      FVisibleImportList.AddObject(FImportList[I], FImportList.Objects[I]);
  end;
  TcxImageListEditorForm(FEditorForm).SetImportList(FVisibleImportList);
  Change;
end;

initialization
  FImageFileFormats := TcxImageFileFormats.Create;
  cxImageFileFormats.Register('Bitmaps (*.bmp)', '.bmp', TBitmap);
  cxImageFileFormats.Register('Icons (*.ico)', '.ico', TcxIcon);
  if GetClass(TdxPNGImage.ClassName) <> nil then
    cxImageFileFormats.Register('DevExpress PNG (*.png)', '.png', TdxPNGImage);

finalization
  FreeAndNil(FImageFileFormats);

end.
