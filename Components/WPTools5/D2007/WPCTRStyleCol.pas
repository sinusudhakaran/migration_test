{:: This is unit implements the TWPStyleCollection component. The TWPStyleCollection is
used to handle the paragraph styles which are used by the attached RTF-Engine }
{$IFNDEF CLRUNIT}unit WPCTRStyleCol;
{$ELSE}unit WPTools.CTR.StyleCol; {$ENDIF}
//******************************************************************************
// WPTools V5 - THE word processing component for VCL and .NET
// Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************
// WPCTRStyleCol - WPTools 5 Style Collection
// Please note that the paragraph style support in WPTools 5 is always
// active - there is no need for this collection. This collection is used
// to store the styles which are linked by several editors which are uing different
// RTFProps.
//******************************************************************************

{--$DEFINE ACCEPT_ALL_INI}// dangerous: accept all INI files as style file,
                           // not only those which start with "[WPTOOLS-STYLES]"

interface

uses Windows, SysUtils, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, WPUtil, WPCtrMemo,
  WPRTEDefs, WPIOCSS;

type
  TWPParStyles = class;
  TWPStyleCollection = class;

  EWPStyleNotFound = class(Exception);
  EWPEngineModeError = class(Exception);

  TWPParStyleValues = class(TWPValueList);

  TWPExtraStyleDisplayTypes = (wpstBlock, wpstInline, wpstList, wpstNone);

  TWXMLDefaultStyleMode = (wp_xml_any, wp_xml_body, wp_xml_P,
    wp_xml_UL, wp_xml_OL, wp_xml_LI, wp_xml_TD);

  TWPParStyle = class(TCollectionItem)
  private
    found: Boolean;
    FInherited: TList;
    FName: string;
    FOriginalName: string; // Prior to StyleDialog !
    FModified: Boolean; // By Styledialog
    FBasedOnStyle: string;
    FNextStyle: string;
    FUsed: Boolean;
    // Text Storage
    FValues: TWPValueList;
    FCSSDisplay: TWPExtraStyleDisplayTypes;
    function GetValues: TWPValueList;
    procedure SetValues(x: TWPValueList);
    procedure SetName(const x: string);
    procedure ChangeValues(Sender: TObject);
    // function  ParAttrEqualTo(ParOnly: TWPStyleElementsPar; Par: PTParagraph): Boolean;
    // function  CharAttrEqualTo(Elements: TWPStyleElementsChar; pa: PTAttr): Boolean;
  protected
    // Binary Storage - not here!
    // Parents ...
    FAllStyles: TWPParStyles;
    FController: TWPStyleCollection;
    function GetDisplayName: string; override;
    procedure AddProp(const NameAndValue: string); virtual;
    procedure SetNumberLevel(x: Integer);
    function GetNumberLevel: Integer;
    procedure SetTag(x: Integer);
    function GetTag: Integer;
    procedure SetBasedOnStyle(const x: string);
    procedure SetNextStyle(const x: string);
    procedure SetIsOutline(x: Boolean);
    function GetIsOutline: Boolean;
    procedure SetIsDefaultStyle(x: Boolean);
    function GetIsDefaultStyle: Boolean;
    // procedure SetXMLDefaultStyleMode(x: TWXMLDefaultStyleMode);
    function XMLStyleMode: TWXMLDefaultStyleMode;
    procedure SetKeepTogether(x: Boolean);
    procedure SetKeepWithNext(x: Boolean);
    function GetKeepTogether: Boolean;
    function GetKeepWithNext: Boolean;
    function GetAsCSSstring: string;
    function GetCSSName: string;
    procedure SetCSSName(x: string);
    function GetInheritedStyle(index: Integer): TWPParStyle;
    procedure Update(RTFProps: TWPRTFProps);
  public
    AbsoluteID: Integer; // ensure unique identification of style in when editing list
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    //: Add a different list of values
    procedure MergeValues(NewValues: TWPValueList);
    //: Read the values from a binary representation
    procedure ReadFromPar(txtstyle: TWPTextStyle); virtual;
    //: Delete a value
    procedure RemoveValue(const ValueName: string); virtual;
    //: Add a Value
    procedure AddValue(const ValueName, Value: string); virtual;
    //: Retrieve a value
    function GetValue(const ValName: string): string; virtual;

    //: Deletes all Values
    procedure Clear; virtual;
    //: Counts how many styles inherit from this one
    function InheritStyleCount: Integer;
    //: Inheriting styles
    property InheritStyle[index: Integer]: TWPParStyle read GetInheritedStyle;
    //: Converts Style into the CSS representation
    property AsString: string read GetAsCSSstring;
    //: Name used for this style when used as CSS style
    property CSSName: string read GetCSSName write SetCSSName;
    property Modified: Boolean read FModified write FModified;
    // Reserved
    property KeepTogether: Boolean read GetKeepTogether write SetKeepTogether default FALSE;
    property KeepWithNext: Boolean read GetKeepWithNext write SetKeepWithNext default FALSE;
    property Used: Boolean read FUsed; // Updated with UpdateUsedFlags !
  published
    {:: This is the name of the style. If you change the name the
        name for this style will be changed in all attached memo controls
        at once. This is required to keep the possibility to apply the
        values at any time using <see method="update">. }
    property Name: string read FName write SetName;
    property BasedOnStyle: string read FBasedOnStyle write SetBasedOnStyle;
    property NextStyle: string read FNextStyle write SetNextStyle;
    property Tag: Integer read GetTag write SetTag default 0;
    property Values: TWPValueList read GetValues write SetValues;
    property NumberLevel: Integer read GetNumberLevel write SetNumberLevel default 0;
    // property XMLDefaultStyleMode: TWXMLDefaultStyleMode read FXMLDefaultStyleMode write SetXMLDefaultStyleMode;
    property IsOutline: Boolean read GetIsOutline write SetIsOutline default FALSE;
    property CSSDisplay: TWPExtraStyleDisplayTypes read FCSSDisplay write FCSSDisplay;
    property IsDefaultStyle: Boolean read GetIsDefaultStyle write SetIsDefaultStyle;
    // property OnApplyEvent: TWPParStyleApplyEvent read FOnApplyEvent write FOnApplyEvent;
    // property OnNewParagraph: TWPParStyleStateEvent read FOnNewParagraph write FOnNewParagraph;
  end;
  TWPParStyleClass = class of TWPParStyle;

  TWPParStyles = class(TCollection)
  private
    FInAssign, FActivateUndo: Boolean;
    FOwner: TPersistent;
    function GetParams(index: Integer): TWPParStyle;
    procedure SetParams(index: Integer; x: TWPParStyle);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    function StyleCount: Integer;
    function AddName(const Name: string): TWPParStyle;
    property Items[index: Integer]: TWPParStyle read GetParams write SetParams; default;
    property aOwner: TPersistent write FOwner;
    procedure Assign(Source: TPersistent); override;
    property ActivateUndo: Boolean read FActivateUndo write FActivateUndo;
  end;
  TWPParStylesClass = class of TWPParStyles;


  TWPStyleCollectionSaveMode = (wpSaveWPCSSFormat, wpSaveCSSFormat, wpSaveINIFormat);

  TWPStyleCollectionChangeStyleEvent = procedure(Sender: TObject; Style: TWPParStyle) of object;
  {::   }

  TWPStyleCollection = class(TComponent)
  private
    FControlledMemos: TWPEditBoxLinkCollection;
    FAppendMode: Boolean;
    FSaveToStreamFormat: TWPStyleCollectionSaveMode;
    FOnChangeStyleList: TNotifyEvent;
    FOnChangeStyle: TWPStyleCollectionChangeStyleEvent;
    FPendingOnChangeStyleList, FPendingChangeStyle: Boolean;
    FChangedStyle: TWPParStyle;
    FStyles: TWPParStyles;
    FHTMLMode: Boolean;
    FUpdateLock: Integer;
    FNumberingControlledByStyles: Boolean;
    FDefaultParStyle: TWPParStyle;
    function GetStyles: TWPParStyles;
    procedure SetStyles(x: TWPParStyles);
    function GetAsString: string;
    procedure SetAsString(const x: string);
    procedure SetControlledMemos(x: TWPEditBoxLinkCollection);
    procedure EditBoxStateMsg(Sender: TPersistent; EditBox: TWPCustomRtfEdit; State: TWPEditBoxLinkMsg); virtual;
  protected
    constructor CreateTyped(aOwner: TComponent; ClassType: TWPParStyleClass; ColClass: TWPParStylesClass); virtual;
    procedure DoChangeStyleList;
    procedure DoChangeStyle(Sender: TWPParStyle);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure Clear;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure GetStyleList(Strings: TStrings);
    function StyleCount: Integer;
    function Add(const StyleName: string): TWPParStyle;
    function Find(const StyleName: string): TWPParStyle;
    function StyleByName(const StyleName: string): TWPParStyle;
    procedure ReadStyles(SourceRTFProps: TWPRTFProps); overload;
    procedure ReadStyles(SourceEditBox: TWPCustomRtfEdit); overload;
    procedure WriteStyles(DestEditBox: TWPCustomRtfEdit);
    procedure Update(DestRTFProps: TWPRTFProps = nil; OnlyModified: Boolean = FALSE);
    procedure SaveToINIStream(Stream: TStream);
    procedure SaveToCSSStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream); virtual;
    procedure LoadFromStream(Stream: TStream; IsINIFormat: Boolean = FALSE); virtual;
    procedure LoadFromFile(const FileName: string);
    procedure AppendFromFile(const FileName: string); // FAppendMode
    procedure AppendFromString(const Source: string);
    procedure SaveToFile(const Filename: string);
    property AsString: string read GetAsString write SetAsString;
    property NumberingControlledByStyles: Boolean read FNumberingControlledByStyles write FNumberingControlledByStyles;
  published
    property Styles: TWPParStyles read GetStyles write SetStyles;
    property SaveToStreamFormat: TWPStyleCollectionSaveMode read FSaveToStreamFormat write FSaveToStreamFormat;
    property ControlledMemos: TWPEditBoxLinkCollection read FControlledMemos write SetControlledMemos;
    property OnChangeStyleList: TNotifyEvent read FOnChangeStyleList write FOnChangeStyleList;
    property OnChangeStyle: TWPStyleCollectionChangeStyleEvent read FOnChangeStyle write FOnChangeStyle;
  end;

implementation

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// TWPStyleCollection ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function TWPStyleCollection.GetStyles: TWPParStyles;
begin
  Result := FStyles;
end;

procedure TWPStyleCollection.SetStyles(x: TWPParStyles);
begin
  FStyles.Assign(x);
end;

function TWPStyleCollection.GetAsString: string;
var
  mem: TStringStream;
begin
  mem := TStringStream.Create('');
  try
    SaveToCSSStream(mem);
    Result := mem.DataString;
  finally
    mem.Free;
  end;
end;

procedure TWPStyleCollection.SetAsString(const x: string);
var
  mem: TStringStream;
begin
  mem := TStringStream.Create(x);
  try
    mem.Position := 0;
    LoadFromStream(mem);
  finally
    mem.Free;
  end;
end;

procedure TWPStyleCollection.AppendFromString(const Source: string);
begin
  FAppendMode := TRUE;
  try
    SetAsString(Source);
  finally
    FAppendMode := FALSE;
  end;
end;

constructor TWPStyleCollection.Create(aOwner: TComponent);
begin
  CreateTyped(aOwner, TWPParStyle, TWPParStyles);
{$IFDEF AUTOSTY}FAutoStyleCount := 1; {$ENDIF}
end;

constructor TWPStyleCollection.CreateTyped(aOwner: TComponent; ClassType: TWPParStyleClass; ColClass: TWPParStylesClass);
begin
  inherited Create(aOwner);
  FStyles := ColClass.Create(ClassType);
  FStyles.FOwner := Self;
  FControlledMemos := TWPEditBoxLinkCollection.Create(Self);
  FControlledMemos.OnOnUpdateState := EditBoxStateMsg;
end;

procedure TWPStyleCollection.EditBoxStateMsg(Sender: TPersistent;
  EditBox: TWPCustomRtfEdit; State: TWPEditBoxLinkMsg);
begin
  // assign styles
  if State = wpAfterLoad then
    ReadStyles(EditBox);
end;

destructor TWPStyleCollection.Destroy;
begin
  FStyles.Free;
  FControlledMemos.Free;
  inherited Destroy;
end;

procedure TWPStyleCollection.SetControlledMemos(x: TWPEditBoxLinkCollection);
begin
  FControlledMemos.Assign(x);
end;

procedure TWPStyleCollection.Loaded;
begin
  inherited Loaded;
  DoChangeStyleList
end;

procedure TWPStyleCollection.Clear;
begin
  FStyles.Clear;
  DoChangeStyleList;
{$IFDEF AUTOSTY}FAutoStyleLevel := 1; {$ENDIF}
end;

procedure TWPStyleCollection.LoadFromFile(const FileName: string);
var
  s: TFileStream;
begin
  s := TFileStream.Create(FileName, fmOpenRead + fmShareDenyNone);
  try
    LoadFromStream(s,
{$IFDEF ACCEPT_ALL_INI}
      (CompareText(ExtractFileExt(FileName), '.ini') = 0)
      or (CompareText(ExtractFileExt(FileName), '.sty') = 0)
{$ELSE}
      false
{$ENDIF}
      );
  finally
    s.Free;
  end;
end;

procedure TWPStyleCollection.AppendFromFile(const FileName: string); // FAppendMode
begin
  try
    FAppendMode := TRUE;
    LoadFromFile(FileName);
  finally
    FAppendMode := FALSE;
  end;
end;

procedure TWPStyleCollection.SaveToFile(const Filename: string);
var
  s: TFileStream;
  e: string;
begin
  s := TFileStream.Create(FileName, fmCreate);
  e := Uppercase(ExtractFileExt(FileName));
  try
    if e = '.CSS' then
      SaveToCSSStream(s)
    else if (e = '.STY') or (e = '.INI') then
      SaveToINIStream(s)
    else SaveToStream(s);
  finally
    s.Free;
  end;
end;

var WPT_STY_HEAD: string = '[WPTOOLS-STYLES]';

procedure TWPStyleCollection.SaveToINIStream(Stream: TStream);
var
  i, j: Integer;
  str: TStringList;
begin
  str := TStringList.Create;
  try
    str.Add(WPT_STY_HEAD); // Magic - expected as first entry!
    for i := 0 to StyleCount - 1 do
    begin
      str.Add('[' + FStyles[i].Name + ']');
      {  if FStyles[i].BasedOnStyle<>'' then
           str.Add('StyleBaseOn=' + FStyles[i].BasedOnStyle);
        if FStyles[i].NextStyle<>'' then
           str.Add('StyleNextName=' + FStyles[i].NextStyle);  }
      for j := 0 to FStyles[i].Values.Count - 1 do
        str.Add(FStyles[i].Values[j]);
    end;
  finally
    str.SaveToStream(Stream);
    str.Free;
  end;
end;

procedure TWPStyleCollection.SaveToCSSStream(Stream: TStream);
var
  i: Integer;
  s: string;
  FirstEditBox: TWPCustomRtfEdit;
  sty: TWPTextStyle;

begin
  FirstEditBox := ControlledMemos.FirstEditBox;
  if FirstEditBox = nil then
    raise Exception.Create('We need EditBox to save CSS');

  for i := 0 to StyleCount - 1 do
  begin
    if Copy(Styles[i].Name, 1, 2) = '/*' then // allow comments in value list
    begin
      s := FStyles[i].AsString + #13#10;
{$IFDEF CLR}
      Stream.Write(s, Length(s));
{$ELSE}
      Stream.Write(s[1], Length(s));
{$ENDIF}
    end
    else
    begin
      sty := FirstEditBox.Memo.RTFData.RTFProps.ParStyles.FindTextStyle(FStyles[i].Name);
      if sty <> nil then
      begin
        s := FStyles[i].CSSName + '{' + sty.AGet_CSS(true, true, false, true) + '}' + #13 + #10;
      end;
{$IFDEF CLR}
      Stream.Write(s, Length(s));
{$ELSE}
      Stream.Write(s[1], Length(s));
{$ENDIF}
    end;
  end;
end;

procedure TWPStyleCollection.SaveToStream(Stream: TStream);
begin
  if FSaveToStreamFormat = wpSaveINIFormat then
    SaveToINIStream(Stream)
  else SaveToCSSStream(Stream);
end;

procedure TWPStyleCollection.LoadFromStream(Stream: TStream; IsINIFormat: Boolean = FALSE);
var
  mem: TStringStream;
  data, s, n: string;
  cssparser: TWPCSSParser;
  parsty: TWPParStyle;
  lst, list2: TStringList;
  p, j, a, i: Integer;
begin
  if not FAppendMode then FStyles.Clear;
  mem := TStringStream.Create('');
  lst := TStringList.Create;
  try
    mem.CopyFrom(Stream, Stream.Size);
    data := mem.DataString;

    if Length(data) > 0 then
    begin
      p := 1;
      while (data[p] <> #0) and (data[p] <= #32) do inc(p);
      if IsINIFormat or (CompareText(Copy(data, p, Length(WPT_STY_HEAD)), WPT_STY_HEAD) = 0) then
      begin
        lst.Text := data;
        parsty := nil;
        for j := 0 to lst.Count - 1 do
        begin
          s := lst[j];
          if s <> '' then
          begin
            if s[1] = '[' then
            begin
              a := Pos(']', s);
              if a > 0 then s := Copy(s, 2, a - 2)
              else Delete(s, 1, 1);

              if CompareText('[' + s + ']', WPT_STY_HEAD) <> 0 then
                parsty := FStyles.AddName(s);
            end else
              if parsty <> nil then
              begin
                a := Pos('=', s);
                n := Copy(s, 1, a - 1);
                if CompareText(n, 'IsDefaultStyle') = 0 then
                begin
                  parsty.FValues.Add('IsDefault=' + Copy(s, a + 1, Length(s)));
                end else
                  if CompareText(n, 'Values') = 0 then
                  begin
                    list2 := TStringList.Create;
                    try
                      list2.CommaText := Copy(s, a + 1, Length(s));
                      for a := 0 to list2.Count - 1 do
                        parsty.FValues.Add(list2[a]);
                    finally
                      list2.Free;
                    end;
                  end else
                    parsty.FValues.Add(s);
              end;
          end;
        end;
      end else // CSS Format
      begin
        cssparser := TWPCSSParser.Create(TWPCSSParserStyleWP, nil);
        try
          cssparser.AsString := data;
          for i := 0 to cssparser.StyleCount - 1 do
            if cssparser.Style[i].Name <> '' then
            begin
              parsty := Add(cssparser.Style[i].Name);
              TWPCSSParserStyleWP(cssparser.Style[i]).GetWPValues(parsty.Values);
            end;
        finally
          cssparser.Free;
        end;
      end;
    end;
  finally
    mem.Free;
    lst.Free;
  end;
end;

function TWPStyleCollection.StyleCount: Integer;
begin
  Result := FStyles.Count;
end;

{ Apply the style properties to a certain or all TWPCustomRichText }

procedure TWPStyleCollection.Update(DestRTFProps: TWPRTFProps = nil; OnlyModified: Boolean = FALSE);
var
  j: Integer;
  procedure Process(DEST: TWPRTFProps);
  var
    i: Integer;
    ele, sty: TWPRTFStyleElement;
  begin
    for i := 0 to StyleCount - 1 do
    begin
      if not OnlyModified
        or FStyles[i].FModified
        then
      begin
        FStyles[i].Update(DEST);
      end;
    end;

    for i := 0 to DEST.ParStyles.Count - 1 do
    begin
      ele := DEST.ParStyles[i];
      if ele.TextStyle.AGet(WPAT_STYLE_BASE_NAME, j) then
      begin
        sty := DEST.ParStyles.FindStyle(ele.TextStyle.ANumberToString(j));
        if sty <> nil then
        begin
          ele.TextStyle.ASetBaseStyle(sty.ID);
          ele.TextStyle.ADel(WPAT_STYLE_BASE_NAME);
        end;
      end;
    end;
  end;
begin
  if DestRTFProps <> nil then
    Process(DestRTFProps)
  else
    for j := 0 to FControlledMemos.Count - 1 do
      if FControlledMemos[j].EditBox <> nil then
        Process(FControlledMemos[j].EditBox.Memo.RTFData.RTFProps);
  if OnlyModified then
    for j := 0 to StyleCount - 1 do
      FStyles[j].FModified := FALSE;
end;

procedure TWPStyleCollection.ReadStyles(SourceEditBox: TWPCustomRtfEdit);
begin
  ReadStyles(SourceEditBox.Memo.RTFData.RTFProps);
end;

procedure TWPStyleCollection.WriteStyles(DestEditBox: TWPCustomRtfEdit);
begin
  Update(DestEditBox.Memo.RTFData.RTFProps);
end;

procedure TWPStyleCollection.ReadStyles(SourceRTFProps: TWPRTFProps);
var
  j: Integer;
  procedure Process(Source: TWPRTFProps);
  var
    i: Integer;
    sty: TWPRTFStyleElement;
    thisstyle: TWPParStyle;
    opt: TWPStyleAsIniOptions;
  begin
    for i := 0 to Source.ParStyles.Count - 1 do
    begin
      sty := Source.ParStyles[i];
      thisstyle := Find(sty.Name);
      if thisstyle = nil then
      begin
        opt := [wpINI_Names, // Based, Next !
          wpINI_CharAttr, // read/modify character attributes (font ...)
          wpINI_ParAttr, // read/modify paragraph attributes (indent ...)
          wpINI_Borders, // WPAT_BorderTypeL .. WPAT_BorderRes1
          wpINI_ParSpecial, // read/modify paragraph special flags, WPAT_ParProtected ..WPAT_ParOutlineBreak
          wpINI_Tabstops];
        if sty.IsDefault then
          include(opt, wpINI_IsDefaultStyle);
        thisstyle := Add(sty.Name);
        sty.TextStyle.AGetAsINI(thisstyle.Values, opt);
      end;
    end;
  end;
begin
  if SourceRTFProps <> nil then
    Process(SourceRTFProps)
  else
    for j := 0 to FControlledMemos.Count - 1 do
      if FControlledMemos[j].EditBox <> nil then
        Process(FControlledMemos[j].EditBox.Memo.RTFData.RTFProps);
end;

function TWPStyleCollection.Add(const StyleName: string): TWPParStyle;
begin
  Result := Find(StyleName);
  if Result = nil then
  begin
    FStyles.BeginUpdate;
    Result := TWPParStyle(FStyles.Add);
    Result.Name := StyleName;
    FStyles.EndUpdate;
  end;
end;

function TWPStyleCollection.Find(const StyleName: string): TWPParStyle;
var i: Integer;
begin
  for i := 0 to StyleCount - 1 do
    if CompareText(Styles[i].Name, StyleName) = 0 then
    begin
      Result := Styles[i];
      exit;
    end;
  Result := nil;
end;

procedure TWPStyleCollection.DoChangeStyleList;
begin
  if FUpdateLock > 0 then
    FPendingOnChangeStyleList := TRUE
  else
  begin
    if assigned(FOnChangeStyleList) then FOnChangeStyleList(Self);
    FPendingOnChangeStyleList := FALSE;
  end;
end;

procedure TWPStyleCollection.DoChangeStyle(Sender: TWPParStyle);
begin
  if FUpdateLock > 0 then
  begin
    FPendingChangeStyle := TRUE;
    FChangedStyle := Sender;
  end
  else
  begin
    if assigned(FOnChangeStyle) then FOnChangeStyle(Self, Sender);
    FPendingChangeStyle := FALSE;
    FChangedStyle := nil;
  end;
end;

procedure TWPStyleCollection.BeginUpdate;
begin
  inc(FUpdateLock);
end;

procedure TWPStyleCollection.EndUpdate;
begin
  dec(FUpdateLock);
  if FUpdateLock = 0 then
  begin
    if assigned(FOnChangeStyleList) and FPendingOnChangeStyleList then FOnChangeStyleList(Self);
    if assigned(FOnChangeStyle) and FPendingChangeStyle then FOnChangeStyle(Self, FChangedStyle);
    FPendingChangeStyle := FALSE;
    FChangedStyle := nil;
    FPendingOnChangeStyleList := FALSE;
  end;
end;

procedure TWPStyleCollection.GetStyleList(Strings: TStrings);
var
  i: Integer;
begin
  Strings.Clear;
  for i := 0 to Styles.Count - 1 do
    if Copy(Styles[i].Name, 1, 2) <> '/*' then // Added March 2, 2003 - BAL
      Strings.Add(Styles[i].Name);
end;

function TWPStyleCollection.StyleByName(const StyleName: string): TWPParStyle;
begin
  Result := TWPParStyle(Find(StyleName));
  if Result = nil then raise EWPStyleNotFound.Create('Style "' + StyleName + '" not found!');
end;


// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// TWPParStyles - TCollection
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function TWPParStyles.GetParams(index: Integer): TWPParStyle;
begin
  Result := TWPParStyle(inherited items[index]);
end;

procedure TWPParStyles.SetParams(index: Integer; x: TWPParStyle);
begin
  TWPParStyle(inherited items[index]).Assign(x);
end;

function TWPParStyles.AddName(const Name: string): TWPParStyle;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if CompareText(Items[i].Name, Name) = 0 then
    begin
      Result := Items[i]; exit;
    end;
  Result := TWPParStyle(Add);
  Result.Name := Name;
end;


procedure TWPParStyles.Assign(Source: TPersistent);
begin
  FInAssign := TRUE;
  try
    inherited Assign(Source);
  finally
    FInAssign := FALSE;
  end;
end;

procedure TWPParStyles.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  (FOwner as TWPStyleCollection).DoChangeStyleList;
end;

function TWPParStyles.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TWPParStyles.StyleCount: Integer;
begin
  Result := Count;
end;


// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// TWPParStyle - TCollectionItem
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


function TWPParStyle.GetDisplayName: string;
begin
  Result := CSSNAME + '=[' + FValues.CommaText + ']';
end;

function TWPParStyle.GetValues: TWPValueList;
begin
  Result := TWPValueList(FValues);
end;

procedure TWPParStyle.SetValues(x: TWPValueList);
begin
  Clear;
  FValues.Assign(x);
end;

procedure TWPParStyle.ChangeValues(Sender: TObject);
begin
  FBasedOnStyle := GetValue('StyleBaseOn');
  FNextStyle := GetValue('StyleNextName');
  Modified := TRUE;
  FController.DoChangeStyle(Self);
end;

var
  FGlobalAbsoluteID: Integer;

constructor TWPParStyle.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FAllStyles := TWPParStyles(Collection);
  FController := TWPStyleCollection(FAllStyles.FOwner);
  FInherited := TList.Create;
  FName := 'Style ' + IntToStr(FAllStyles.Count + 1);
  FValues := TWPValueList.Create;
  FValues.OnChange := ChangeValues;
  inc(FGlobalAbsoluteID);
  AbsoluteID := FGlobalAbsoluteID;
end;

destructor TWPParStyle.Destroy;
begin
  if FController.FDefaultParStyle = Self then
    FController.FDefaultParStyle := nil;
  FValues.Free;
  FInherited.Free;
  if FController.FChangedStyle = Self then FController.FChangedStyle := nil;
  inherited Destroy;
end;

procedure TWPParStyle.SetName(const x: string);
var
  j: Integer;
  sty: TWPRTFStyleElement;
begin
  if FName <> x then
  begin
    for j := 0 to FController.FControlledMemos.Count - 1 do
      if FController.FControlledMemos[j].EditBox <> nil then
      begin
        sty := FController.FControlledMemos[j].EditBox.Memo.RTFData.RTFProps.ParStyles.FindStyle(FName);
        if sty <> nil then sty.Name := x;
      end;
    FName := x;
  end;
end;

procedure TWPParStyle.Assign(Source: TPersistent);
var
  b: Boolean;
begin
  if Source = nil then
  begin
    Clear;
    Name := '';
    Values.Clear;
    BasedOnStyle := '';
    NextStyle := '';
    b := TRUE;
  end
  else if Source is TWPParStyle then
  begin
    b := Name <> TWPParStyle(Source).FName;
    Tag := TWPParStyle(Source).Tag;
    Name := TWPParStyle(Source).FName;
    BasedOnStyle := TWPParStyle(Source).FBasedOnStyle;
    NextStyle := TWPParStyle(Source).FNextStyle;
    IsDefaultStyle := TWPParStyle(Source).IsDefaultStyle;
    AbsoluteID := TWPParStyle(Source).AbsoluteID;
    KeepTogether := TWPParStyle(Source).KeepTogether;
    KeepWithNext := TWPParStyle(Source).KeepWithNext;
    Clear;
    Values.Assign(TWPParStyle(Source).FValues);
    // We need this in UpdateStyleList
    if TWPParStyle(Source).FOriginalName <> '' then
      FOriginalName := TWPParStyle(Source).FOriginalName
    else if FAllStyles.FInAssign then
      FOriginalName := TWPParStyle(Source).FName;
    if FAllStyles.FInAssign then
      FModified := FALSE
    else
      FModified := TWPParStyle(Source).FModified;
  end
  else
    b := FALSE;
  if b then FController.DoChangeStyleList;
  FController.DoChangeStyle(Self);
end;

procedure TWPParStyle.SetNumberLevel(x: Integer);
begin
  if x > 9 then x := 9;
  if x = 0 then RemoveValue(WPAT_CodeNames[WPAT_NumberLevel].Name)
  else AddValue(WPAT_CodeNames[WPAT_NumberLevel].Name, IntToStr(x));
end;

function TWPParStyle.GetNumberLevel: Integer;
var s: string;
begin
  s := GetValue(WPAT_CodeNames[WPAT_NumberLevel].Name);
  if s <> '' then Result := StrToIntDef(s, 0) else Result := 0;
end;

procedure TWPParStyle.SetTag(x: Integer);
begin
  if x = 0 then RemoveValue('StyleTag') else
    AddValue('StyleTag', IntToStr(x));
end;

function TWPParStyle.GetTag: Integer;
var s: string;
begin
  s := GetValue('StyleTag');
  if s <> '' then Result := StrToIntDef(s, 0) else Result := 0;
end;

procedure TWPParStyle.SetBasedOnStyle(const x: string);
begin
  if x = '' then RemoveValue('StyleBaseOn')
  else AddValue('StyleBaseOn', x);
  FBasedOnStyle := x; // for quicker access
end;

procedure TWPParStyle.SetNextStyle(const x: string);
begin
  if x = '' then RemoveValue('StyleNextName')
  else AddValue('StyleNextName', x);
  FNextStyle := x; // for quicker access
end;

procedure TWPParStyle.SetIsOutline(x: Boolean);
begin
  if x then
    AddValue(WPAT_CodeNames[WPAT_ParIsOutline].Name, '1')
  else RemoveValue(WPAT_CodeNames[WPAT_ParIsOutline].Name);
end;

function TWPParStyle.GetIsOutline: Boolean;
begin
  Result := GetValue(WPAT_CodeNames[WPAT_ParIsOutline].Name) = '1';
end;

procedure TWPParStyle.SetIsDefaultStyle(x: Boolean);
var
  i: Integer;
begin
  if IsDefaultStyle <> x then
  begin
    for i := 0 to FController.FStyles.Count - 1 do
      FController.FStyles[i].RemoveValue('IsDefault');
    if x then
    begin
      FController.FDefaultParStyle := Self;
      AddValue('IsDefault', '1');
    end
    else FController.FDefaultParStyle := nil;
  end;
end;

function TWPParStyle.GetIsDefaultStyle: Boolean;
begin
  Result := GetValue('IsDefault') = '1';
end;


function TWPParStyle.XMLStyleMode: TWXMLDefaultStyleMode;
begin
  if CompareText(Name, 'body') = 0 then
    Result := wp_xml_body
  else if CompareText(Name, 'p') = 0 then
    Result := wp_xml_P
  else if CompareText(Name, 'ul') = 0 then
    Result := wp_xml_UL
  else if CompareText(Name, 'ol') = 0 then
    Result := wp_xml_OL
  else if CompareText(Name, 'li') = 0 then
    Result := wp_xml_LI
  else if CompareText(Name, 'td') = 0 then
    Result := wp_xml_TD
  else Result := wp_xml_any;
end;

procedure TWPParStyle.SetKeepTogether(x: Boolean);
begin
  if x then
    AddValue(WPAT_CodeNames[WPAT_ParKeep].Name, '1')
  else
    RemoveValue(WPAT_CodeNames[WPAT_ParKeep].Name);
end;

procedure TWPParStyle.SetKeepWithNext(x: Boolean);
begin
  if x then
    AddValue(WPAT_CodeNames[WPAT_ParKeepN].Name, '1')
  else
    RemoveValue(WPAT_CodeNames[WPAT_ParKeepN].Name);
end;

function TWPParStyle.GetKeepTogether: Boolean;
begin
  Result := GetValue(WPAT_CodeNames[WPAT_ParKeep].Name) = '1';
end;

function TWPParStyle.GetKeepWithNext: Boolean;
begin
  Result := GetValue(WPAT_CodeNames[WPAT_ParKeepN].Name) = '1';
end;

//TODO: assign to default TextStyle and retrieve CSS from it!

function TWPParStyle.GetAsCSSstring: string;
begin
  if Copy(Name, 1, 2) <> '/*' then // Added March 2, 2003 - BAL
  begin
(*	Result := '';

  // Initialize Extra
  Extra.IsDefault := IsDefaultStyle;
  Extra.Display := FCSSDisplay;

   if FController.FHTMLMode then
   begin
    // AllValues := TWPValueList.Create;
    // MergeValues(AllValues);
    if FXMLDefaultStyleMode in
      [wp_xml_ExportStyle,wp_xmlhtml_ExportStyle,wp_html_ExportStyle,wp_xml_body] then
       Result := WPGetStyleString({All}Values, nil)
    else  Result := WPGetStyleString({All}Values, @Extra);
    // AllValues.Free;
   end
   else
    Result := WPGetStyleString(FValues, @Extra);

  if assigned(FController.FOnStyleSaveCSS) then
   FController.FOnStyleSaveCSS( FController, Self, Result );   *)
  end else // Added March 2, 2003 - BAL
    Result := Values.Text;
end;

procedure TWPParStyle.MergeValues(NewValues: TWPValueList);
  procedure DoIt(sty: TWPParStyle);
  var
    s: TWPParStyle;
  begin
    if sty.FBasedOnStyle <> '' then
      s := FController.Find(sty.FBasedOnStyle)
    else
      s := nil;
    if s <> nil then DoIt(s);
    NewValues.Merge(sty.Values);
  end;
begin
  DoIt(Self);
end;

//: Read the values from a binary representation

procedure TWPParStyle.ReadFromPar(txtstyle: TWPTextStyle);
begin
  FValues.CSSText := txtstyle.StyleString;
end;


// here we calculate a style name which is used in HTML and XML export
// the style name which is calculated represents also the inheritance
// In XML 3 levels are possible, in HTML only 2 unless the first name is
// the default style which is named as DIV

function TWPParStyle.GetCSSName: string;
var
  c, i: Integer;
  function GetName(sty: TWPParStyle): string;
  begin
   { case sty.FXMLDefaultStyleMode of
        wp_xml_P : Result := 'p';
        wp_xml_TD: Result := 'td';
        else }Result := sty.Name;
    // end;
  end;
begin
  if (Pos('.', FName) > 0) or (Pos('#', FName) > 0) then
    Result := FName
  else
  begin
    Result := '';
    c := InheritStyleCount;
    if FController.FHTMLMode then
    begin
      if XMLStyleMode = wp_xml_Any then
        Result := GetName(Self) // NO '.' !
      else
        if c = 1 then
        begin
          if (Length(FName) = 2) and // HTML Headlines
            ((FName[1] = 'h') or (FName[1] = 'H')) and
            ((FName[2] >= '1') and (FName[2] <= '9'))
            then
            Result := GetName(Self)
          else
            Result := '.' + GetName(Self);
        end
        else if (c = 2) or not InheritStyle[2].IsDefaultStyle then
          Result := GetName(InheritStyle[1]) + '.' + Name
        else if c = 3 then
          Result := GetName(InheritStyle[2]) + '.' +
            InheritStyle[1].Name + '#' + Name;
    end
    else
    begin
      for i := c - 1 downto 1 do
        Result := Result + InheritStyle[i].Name + '.';
      Result := Result + Name;
    end;
  end;
end;

// interpret the CSS name as
// either   nnnnnn  (name)
// or       bbbbbb.nnnnnn  (baseon.name)
// anything before that is ignored.

procedure TWPParStyle.SetCSSName(x: string);
var
  I: Integer;
begin
  I := LastDelimiter('.#', x);
  if i = 0 then
  begin
    FName := x;
    FBasedOnStyle := '';
  end
  else
  begin
    FName := Copy(x, I + 1, Length(x));
    x := Copy(X, 1, I - 1);
    I := LastDelimiter('.#', x);
    if I = 0 then
      FBasedOnStyle := x
    else
      FBasedOnStyle := Copy(x, I + 1, Length(x));
  end;
end;

// Get the inhereited styles. index=0 = the style itself!

function TWPParStyle.GetInheritedStyle(index: Integer): TWPParStyle;
begin
  if (index < 0) or (index > FInherited.Count) then
    Result := nil
  else
    Result := TWPParStyle(FInherited[index]);
end;

function TWPParStyle.InheritStyleCount: Integer;
  function DoIt(sty: TWPParStyle): Boolean;
  begin
    if sty = nil then
      Result := FALSE
    else if FInherited.IndexOf(sty) >= 0 then
      Result := true
    else if sty <> nil then
    begin
      FInherited.Add(sty);
      Result := DoIt(FController.Find(sty.FBasedOnStyle));
    end else Result := TRUE;
  end;
begin
  FInherited.Clear;
  if DoIt(Self) then // LOOP - don't allow 'based on'
  begin
    FBasedOnStyle := '';
    FInherited.Clear;
    FInherited.Add(Self);
  end;
  Result := FInherited.Count;
end;

procedure TWPParStyle.AddProp(const NameAndValue: string);
var
  s, strval: string;
  i: Integer;
begin
  if Trim(NameAndValue) = '' then exit;
  i := Pos('=', NameAndValue);
  if (i <= 0) or (i = Length(NameAndValue)) then raise EWPEngineModeError.Create('Stylesyntax: Name=Value');
  s := Copy(NameAndValue, 1, i - 1);
  strval := Copy(NameAndValue, i + 1, Length(NameAndValue));
  FValues.AddValue(s, strval);
  // Some extra properties which are stored in the TWPParStyle
  if CompareText(s, 'StyleNextName') = 0 then
    FNextStyle := strval
  else if CompareText(s, 'StyleBaseOn') = 0 then
    FBasedOnStyle := strval
{$IFNDEF DONT_SHOW_PROPERTY_NOT_FOUND} // ignore unknown properties
  else if (CompareText(s, 'StyleTag') = 0) or
    (CompareText(s, 'IsDefault') = 0) then
  begin
    // always loades from the Values list
  end
  else
    if not found and (CompareText(s, 'CSS') <> 0) then
      raise Exception.Create('Property not found:' + s)
{$ENDIF};
  Modified := TRUE;
end;


procedure TWPParStyle.RemoveValue(const ValueName: string);
var
  i, j: Integer;
  s: string;
begin
  for i := FValues.Count - 1 downto 0 do
  begin
    s := FValues[i];
    j := Pos('=', s);
    if j > 0 then s := Copy(s, 1, j - 1);
    if CompareText(ValueName, s) = 0 then
    begin
      FValues.Delete(i);
      Modified := TRUE;
    end;
  end;
end;

procedure TWPParStyle.AddValue(const ValueName, Value: string);
var
  i, j: Integer;
  s: string;
begin
  for i := 0 to FValues.Count - 1 do
  begin
    s := FValues[i];
    j := Pos('=', s);
    if j > 0 then s := Copy(s, 1, j - 1);
    if CompareText(ValueName, s) = 0 then
    begin
      if Value <> '' then
        FValues[i] := ValueName + '=' + Value
      else
        FValues.Delete(i);
      Modified := TRUE;
      exit;
    end;
  end;
  if Value <> '' then FValues.Add(ValueName + '=' + Value);
end;

function TWPParStyle.GetValue(const ValName: string): string;
var
  i, j: Integer;
  s: string;
begin
  Result := '';
  for i := 0 to FValues.Count - 1 do
  begin
    s := FValues[i];
    j := Pos('=', s);
    if (j > 0) and (CompareText(ValName, Copy(s, 1, j - 1)) = 0) then
    begin
      Result := Copy(s, j + 1, Length(s));
      exit;
    end;
  end;
end;

procedure TWPParStyle.Update(RTFProps: TWPRTFProps);
var
  aStyle: TWPRTFStyleElement;
begin
  aStyle := RTFProps.ParStyles.FindStyle(Name);
  if aStyle = nil then
    aStyle := RTFProps.ParStyles.Add(Name);
  aStyle.TextStyle.ASetAsINI(FValues, [
    wpINI_Names, // read/modify names, "Name" and "StyleBasedOn"
      wpINI_CharAttr, // read/modify character attributes (font ...)
      wpINI_ParAttr, // read/modify paragraph attributes (indent ...)
      wpINI_Borders, // WPAT_BorderTypeL .. WPAT_BorderRes1
      wpINI_ParSpecial, // read/modify paragraph special flags, WPAT_ParProtected ..WPAT_ParOutlineBreak
      wpINI_Tabstops // read and modify tabstops
      ], aStyle);
  aStyle.Name := Name;
  aStyle.NextStyleName := GetValue('StyleNextName');
end;

procedure TWPParStyle.Clear;
begin
  Modified := TRUE;
  FValues.Clear;
end;



end.

