unit ReportTypes;

interface
uses
   WPRTEDefs,
   WPRTEPaint,
   WPCTRRich,
   WPCTRMemo,
   classes,
   OmniXML,
   graphics;

type
  TVertColLineType = (vcUnknown, vcNone, vcFull, vcBottomHalf, vcTopHalf);
  // Basic report types
  TReportType = (rptFinancial, rptCoding, rptLedger, rptGst, rptListings, rptOther, rptGraph);

  // Items in the common footer
  TFooterItem = (fiClientCode, fiPageNumbers, fiPrinted, fiTime, fiUser);
  TFooterItems = set of TFooterItem;

  // Header / Footer  types
  THFSection = (hf_HeaderFirst, hf_HeaderAll, hf_FooterAll, hf_FooterLast);

  // Report items that can have a different style
  TStyleTypes = (siClientName,
                 siTitle,
                 siSubTitle,
                 siHeading,
                 siSectionTitle,
                 siSectionTotal,
                 siNormal,
                 siDetail,
                 siGrandTotal,
                 siFootNote,
                 siFooter);

  // Properties for Styletypes
  TStyleItem = class(TPersistent)
  private
     FBackground: TColor;
     function FontString: string;
     procedure StringFont(Value: string);
     procedure Reset;
     procedure SetBackground(const Value: TColor);
  public
     FontName: string;
     Size: Integer;
     Style: TFontStyles;
     Color: TColor;
     Alignment: TAlignment;
     constructor Create;
     destructor Destroy; override;
     procedure AssignTo(Dest: TPersistent); override;
     function SaveToNode(Node: IxmlNode): Boolean;
     function ReadFromNode(Node: IxmlNode): Boolean;
     //function MergeStyle(Value: TRenderStyle): TRenderStyle;
     property Background: TColor read FBackground write SetBackground;
  end;

  // Actual Style; Array of properties for each Style Item
  TStyleItems = class(TPersistent)
  private
     FName: string;
     FDetailBlinds: Boolean;
     procedure SetName(const Value: string);
     function Filename: string;
     function GetStyleItems(index: integer): TStyleItem;
     procedure SetDetailBlinds(const Value: Boolean);
  published
  public
     Items : array[TStyleTypes] of TStyleItem;
     constructor Create(const aName:string);
     destructor Destroy; override;
     procedure Reset;
     procedure Assign(Source: TPersistent); override;
     property Name: string read FName write SetName;
     property StyleItems [index :integer]: TStyleItem read GetStyleItems;
     property DetailBlinds: Boolean read FDetailBlinds write SetDetailBlinds;
     procedure Save;
     procedure load;
  end;

  // Report Type Properties
  TReportTypeParams = class(TPersistent)
  private
     procedure Reset;

  public
     // Header Items
     H_LogoFile: string;
     H_LogoFileAlignment: TAlignment;
     H_LogoFileWidth: Integer;
     H_LogoFileHeight: Integer;
     H_LogoFileAspect: Boolean;

     H_Title: string;
     H_TitleAlignment: TAlignment;
     H_TitleFont: TFont;
     H_TitleColor: TColor;
     H_Text: string;
     H_TextAlignment: TAlignment;
     H_TextFont: TFont;
     H_TextColor: TColor;
     HF_Sections : array [THFSection] of string;
     // Footer Items
     F_LogoFile: string;
     F_LogoFileAlignment: TAlignment;
     F_LogoFileWidth: Integer;
     F_LogoFileHeight: Integer;
     F_LogoFileAspect: Boolean;
     F_Text: string;
     F_TextAlignment: TAlignment;
     F_TextFont: TFont;
     F_TextColor: TColor;
     // General
     HF_Enabled: Boolean;
     HF_Style: string;
     FooterItems: TFooterItems;
     RoundValues: Boolean; // Financial only
     NewPageforAccounts: Boolean;

     constructor Create;
     constructor Read(value: TReportType);
     destructor Destroy; override;
     procedure CopyHeaderFooter(Source: TReportTypeParams);
     procedure Assign(Source: TPersistent); override;
     function SaveToNode(Node: IxmlNode):Boolean;
     function ReadFromNode(Node: IxmlNode; Version: string): Boolean;
     //Header Footer fill Help functions
     function HasUserHeaderFooter: Boolean;
     procedure ClearUserHeaderFooter;
     function HasFooterText: Boolean;
     function GetClientText: string;
     function GetPageText: string;
     function GetPrintedText: string;
     function HasCustomFooter: Boolean;
   end;

   // Utilities;
   function ReportTypesFilename: string;

   procedure ReadReportParams(Value:TReportTypeParams; byName: string); overload;
   procedure ReadReportParams(Value:TReportTypeParams; bytype: TReportType); overload;
   // Handle Style files...
   function FillStyleList (Value: TStrings): Boolean;
   function ClearStyles: boolean;

   // Handeling TWPRichText .. may need to move
   function GetDynamicRTF:TWPRichText;
   procedure ClearRTF(Value:TWPRichText);

   //RTF Data
   function ReadRTFData(FromNode: IxmlNode; const Name: string): string;
   procedure SaveRTFData(ToNode: IxmlNode; const Name, Value: string);


const
  ReportTypeNames: array[TReportType] of shortstring =
   ('Financial', 'Coding', 'Ledger', 'GST', 'Listings' , 'Other', 'Graph');

  ReportStyleItemNames: array [TStyleTypes] of shortstring =
   ('ClientName', 'Title', 'SubTitle' ,'Heading', 'SectionTitle', 'SectionTotal',
     'Normal', 'Detail', 'GrandTotal', 'FootNote', 'Footer');

  NoStyle = '[None]';

implementation

uses
  WPOBJ_Image,
  BKPrintJob,
  NewReportUtils,
  Windows,
  repCols,
  math,
  ExtCtrls,
  Globals,
  WinUtils,
  logUtil,
  DirUtils,
  Sysutils,
  GenUtils,
  OmniXMLUtils;

const
  DefaultFontString = '"Arial","",8';
  RptTypesFilename = 'ReportTypes.xml';
  XMLVersion = '1';
  StyleExt   = '.brs'; //Banklink Report Style
 // SectionExt = '.bsf'; //Banklink Section RTF

  HFSectionNames : array [THFSection] of shortstring =
   ('HeaderFirst', 'HeaderAll', 'FooterAll', 'FooterLast');

  UnitName = 'ReportTypes';

//************************  Utilities *****************************************

function GetDynamicRTF: TWPRichText;
begin
   Result := TWPRichText.CreateDynamic;
   ClearRTF(Result);
end;

procedure ClearRTF(Value:TWPRichText);
begin
   Value.Clear;
   Value.Header.PageSize := wp_DINA4;
   Value.Header.TopMargin := 0;
   Value.Header.LeftMargin := 0;
   Value.Header.RightMargin := 0;
   Value.Header.BottomMargin := 0;
   Value.FormatOptions := [wpDisableAutosizeTables];
   Value.FormatOptionsEx := [];
   Value.LayoutMode := wplayLayout;
end;

procedure CreateDirIfNotFound(aDir: string);
begin
   if not DirectoryExists(aDir) then
      if not CreateDir(aDir) then
         raise EInOutError.Create('Unable to Create Directory ' + aDir);
end;

function ReportTypesFilename: string;
begin
   CreateDirIfNotFound (StyleDir);
   Result := StyleDir + RptTypesFilename;
end;


function FillStyleList (Value: TStrings): Boolean;
var ls: TSearchRec;
   procedure AddName(AName: string);
   begin
      if Sametext(NoStyle,AName) then
         Exit;
      if Value.IndexOf(AName) < 0 then begin
         Value.Add(AName);
         Result := True;
      end;
   end;
begin
   Result := False;
   Value.BeginUpdate;
   try
      Value.Clear;
      if Findfirst(Globals.StyleDir + '*' + StyleExt,faArchive,ls)=0 then try
         repeat
            AddName(Trim(ChangeFileExt(ls.Name,'')));
         until FindNext(LS) <> 0;
      finally
         FindClose(ls);
      end;
   finally
      Value.EndUpdate;
   end;
end;

function ClearStyles: boolean;
var ls: TSearchRec;
begin
   Result := True;
   while Findfirst(Globals.StyleDir + '*' + StyleExt,faArchive,ls)=0 do try
      if not deletefile (Globals.StyleDir + ls.Name) then begin
         Result := False;
         Break;
      end;
   finally
      FindClose(ls);
   end;
end;


function NewStylename: string;
var I: Integer;
begin
   I := 0;
   Result := 'New Style';
   while FileExists(Globals.StyleDir + Result + StyleExt) do begin
      Inc(I);
      Result := 'New Style(' + IntToStr(I) + ')';
   end;
end;


procedure ReadReportParams(Value:TReportTypeParams; bytype: TReportType);
begin
  ReadReportParams(Value, ReportTypeNames[bytype]);
end;

function ReadRTFData(FromNode: IxmlNode; const Name: string): string;
var ls: TStringStream;
begin
   Result := '';
   ls := TStringStream.Create('');
   try
      if GetNodeTextBinary(FromNode,Name, ls) then begin
         ls.position := 0;
         Result := ls.ReadString(ls.Size);
      end;
   finally
      ls.free;
   end;
end;

procedure SaveRTFData(ToNode: IxmlNode; const Name, Value: string);
var ls: TStringStream;
begin
   if Value > '' then begin
      ls := TStringStream.Create('');
      try
         ls.WriteString(Value);
         SetNodeTextBinary(ToNode,Name,ls);
      finally
         ls.Free;
      end;
   end;
end;

procedure ReadReportParams(Value:TReportTypeParams; ByName: string);
var Document: IXMLDocument;
    bn, vn: IXMLNode;
    Version: string;
begin
   if BKFileExists(ReportTypesFilename) then begin
      // Have a Go..
      copyFile(pChar(ReportTypesFilename),
               pChar(ChangeFileExt(  ReportTypesFilename, '.Bak')),
               False);

      Document := CreateXMLDoc;
      try
         try
            Document.Text := '';
            Document.load (ReportTypesFilename);
            Version := '';
            bn := FindNode(Document, 'ReportTypes');
            if bn <> nil then begin
               vn := FindNode(bn,'Version');
               if vn <> nil then begin
                  Version := vn.Text;
                  if Version <> '2' then begin
                      copyFile(pChar(ReportTypesFilename),
                               pChar(ChangeFileExt(  ReportTypesFilename, '.Ver' + Version)),
                               False);
                  end;
               end;

               bn := FindNode(bn,ByName);
               if bn <> nil then
                  Value.ReadFromNode(bn, Version)
               else
                  Value.Reset;
            end else
               Value.Reset;


         except
            on e: exception do begin
               LogUtil.LogError(UnitName,Format('Could not open %s : %s',[ReportTypesFilename,e.Message]));
               Value.Reset;
            end;
         end;
      finally
         Document := nil;
      end;
   end else
     Value.Reset;
end;



{ TReportType }

procedure TReportTypeParams.Assign(Source: TPersistent);
begin
   if Source is TReportTypeParams then begin
      CopyHeaderFooter(TReportTypeParams(Source));
      HF_Enabled := TReportTypeParams(Source).HF_Enabled;
      HF_Style := TReportTypeParams(Source).HF_Style;
      FooterItems := TReportTypeParams(Source).FooterItems;
      RoundValues := TReportTypeParams(Source).RoundValues;
      NewPageforAccounts := TReportTypeParams(Source).NewPageforAccounts;
   end;
end;

procedure TReportTypeParams.ClearUserHeaderFooter;
var I: Integer;
begin
   H_LogoFile := '';
   H_Text := '';
   H_Title := '';
   F_LogoFile  := '';
   F_Text := '';
   for I := Integer(Low(HF_Sections)) to Integer(High(HF_Sections)) do
     HF_Sections[THFSection(I)] := '';
end;

procedure TReportTypeParams.CopyHeaderFooter(Source:TReportTypeParams);
var I: Integer;
begin
   for I := Integer(Low(HF_Sections)) to Integer(High(HF_Sections)) do
     HF_Sections[THFSection(I)] := Source.HF_Sections[THFSection(I)];


   H_TitleFont.Assign(Source.H_TitleFont);
   H_TextFont.Assign(Source.H_TextFont);
   F_TextFont.Assign(Source.F_TextFont);
   H_TextColor := Source.H_TextColor;
   F_TextColor := Source.F_TextColor;
   H_TitleColor := Source.H_TitleColor;
   H_LogoFile := Source.H_LogoFile;
   H_LogoFileAlignment := Source.H_LogoFileAlignment;
   H_LogoFileWidth := Source.H_LogoFileWidth;
   H_LogoFileHeight := Source.H_LogoFileHeight;
   H_LogoFileAspect := Source.H_LogoFileAspect;

   H_Title := Source.H_Title;
   H_TitleAlignment := Source.H_TitleAlignment;
   H_Text := Source.H_Text;
   H_TextAlignment := Source.H_TextAlignment;
   F_LogoFile := Source.F_LogoFile;
   F_LogoFileAlignment := Source.F_LogoFileAlignment;
   F_LogoFileWidth := Source.F_LogoFileWidth;
   F_LogoFileHeight := Source.F_LogoFileHeight;
   F_LogoFileAspect := Source.F_LogoFileAspect;
   F_Text := Source.F_Text;
   F_TextAlignment := Source.F_TextAlignment;
end;

constructor TReportTypeParams.Create;
begin
   inherited Create;
   H_TitleFont := TFont.Create;
   H_TextFont := TFont.Create;
   F_TextFont := TFont.Create;
   Reset;
end;

destructor TReportTypeParams.Destroy;
begin
   H_TitleFont.Free;
   H_TextFont.Free;
   F_TextFont.Free;
   inherited;
end;




function TReportTypeParams.GetClientText: string;
begin
   Result := ' ';
   if fiClientCode in FooterItems then
      if Assigned(MyClient) then
         Result := 'CODE: '+MyClient.clFields.clCode;
end;

function TReportTypeParams.GetPageText: string;
begin
   if fiPageNumbers in FooterItems then
      Result := 'PAGE  <PAGE>'
   else
      Result := ' ';
end;

function TReportTypeParams.GetPrintedText: string;
var dt: TDateTime;
begin
  Result := '';
  dt := Now;
  if fiPrinted in FooterItems then
     Result := DateToStr(dt);
  if fiTime in FooterItems then
     Result := Result + ' ' + TimeToStr(dt);
  if fiUser in FooterItems then
     if CurrUser <> nil  then
        Result := Result + ' ' + CurrUser.Code;
  if Result > '' then
     Result := 'Printed ' + Result
  else
     Result := ' ';
end;

function TReportTypeParams.HasCustomFooter: Boolean;
begin
   Result := (HF_Sections[hf_FooterAll] > '')
          or (HF_Sections[hf_FooterLast] > '');
end;

function TReportTypeParams.HasFooterText: Boolean;
begin                                 
   Result := ((FooterItems * [fiPrinted, fiTime, fiPageNumbers]) <> [])
          or ((fiUser in FooterItems) and (CurrUser <> nil))
          or ((fiClientCode in FooterItems) and (MyClient <> nil))
end;

function TReportTypeParams.HasUserHeaderFooter: Boolean;
var I: Integer;
begin
   Result := True;
   for I := Integer(Low(HF_Sections)) to Integer(High(HF_Sections)) do
     if HF_Sections[THFSection(I)] > '' then
        Exit;

   if H_LogoFile > '' then
      Exit;
   if H_Text > '' then
      Exit;
   if H_Title > '' then
      Exit;
   if F_LogoFile > '' then
      Exit;
   if F_Text > '' then
      Exit;
   // Still here.. nothing set..
   Result := False;
end;

constructor TReportTypeParams.Read(value: TReportType);
begin
   Create;
   ReadReportParams(Self, Value);
end;

function TReportTypeParams.ReadFromNode(Node: IxmlNode; Version: string): Boolean;
var CurNode: IXMLNode;
    Ws: WideString;
    I: Integer;

    procedure ReadAlignment(FromNode: IXMLNode; const Name: string; var Value: TAlignment);
    begin
       Value := taLeftJustify;
       if GetNodeText(FromNode,Name,Ws) then begin
          if sametext('Right',Ws) then
             Value := taRightJustify
          else if Sametext('Center',Ws) then
             Value := taCenter;
       end;
    end;

    procedure ReadColor(FromNode: IXMLNode; const Name: string; var Value: TColor);
    begin
      Value := clNone;
      if GetNodeText(FromNode,Name,Ws) then try
         Value := strToInt(ws);
      except
      end;
    end;

    procedure ReadVersion1;
    var LRTFLabel : TWPRichText;
        LAlgn: TAlignment;
        Par: TParagraph;
        cha: TWPStoredCharAttrInterface;
        DefaultCha: Cardinal;

        procedure GetPar;
        begin
            //Make sure we have a Paragraph
            if Assigned(par) then
               Par := Par.AppendNewPar(True)
            else begin
               // While we are here..
               LRTFLabel.CheckHasBody;
               cha := LRTFLabel.AttrHelper;
               cha.Clear;
               cha.SetFontName('Arial');
               cha.SetFontSize(7);
               DefaultCha := cha.CharAttr;
                // Just use the first one
               Par := LRTFLabel.FirstPar;
            end;

            //lRTFLabel.ActiveParagraph := par;
        end;

        function ReadLogo(Node: IXMLNode): Boolean;
        var Filename: string;
            Width, Height: Integer;
            Img: TWPObject;
            Obj: TWPTextObj;
        begin
            Result := false;
            Filename := GetNodeTextStr(Node,'LogoFile','');
            if Filename = '' then
               Exit;
            if not BKFileExists(Filename) then
               // May need to add a line, Original would add a line to the report
               Exit;

            Img := TWPOImage.Create(LRTFLabel);
            try
               Img.LoadFromFile(Filename);
            except
               Img.Free; // We cannot load this image
               Exit;
            end;

            GetPar;
            ReadAlignment(Node, 'LogoAlign', LAlgn);
            case Lalgn of
               taLeftJustify:  Par.align := paralLeft;
               taRightJustify: Par.align := paralRight;
               taCenter:       Par.align := paralCenter;
            end;

            Width := GetNodeTextInt(Node,'LogoWidth',0); // in mm
            Width := WPCentimeterToTwips(Width / 10); // want it in twips
            Height := GetNodeTextInt(Node,'LogoHeight',0);
            Height := WPCentimeterToTwips(Height / 10);
            Obj := Par.AppendNewObject(wpobjImage, false, false, 0);
            obj.ObjRef := img;
            obj.Width := Width;
            obj.Height := Height;
            Result := true;
        end;//ReadVersion1.ReadLogo

        procedure ReadParagraph(Node: IXMLNode; Name: string);
        var Text: string;
            lFont: TFont;
            LColour: TColor;

        begin //ReadVersion1.ReadParagraph
           Text := GetNodeTextStr(Node,Name,'');
           if Text > '' then begin //Got Something to do
              GetPar;
              // Get all the text atributes
              lFont := TFont.Create;
              try
                 //Get the font
                 StrToFont(GetNodeTextStr(Node,Name + 'Font',''),lFont);
                  // Apply the font
                 Cha.SetFontName(lFont.Name);
                 Cha.SetColor(LFont.Color);
                 Cha.SetFontSize(lFont.Size);
                 Cha.SetFontStyle(lFont.Style );

                 //Bacground colour
                 ReadColor(Node,Name + 'Background',LColour);
                 if lColour <> clnone then
                     par.ASetColor(WPAT_BGColor, lColour);

                 //Add some margins
                 par.ASet(WPAT_IndentLeft,  WPCentimeterToTwips(0.1));
                 par.ASet(WPAT_IndentRight, WPCentimeterToTwips(0.1));

                 //The  Line typically has some bottom margin as well
                 Par.ASet(WPAT_LineHeight,130);
                 //Par.ASet(WPAT_VertAlignment,2); // seems to brake Right align, only used in cells

                 // Add the text
                 Par.SetText(Text,Cha.CharAttr);

                 //Alignment
                 ReadAlignment(Node, Name + 'Align', LAlgn);
                 case Lalgn of
                    taLeftJustify:  Par.align := paralLeft;
                    taRightJustify: Par.align := paralRight;
                    taCenter:       Par.align := paralCenter;
                 end;

              finally
                 LFont.Free;
              end;
           end;
        end;//ReadVersion1.ReadParagraph


    begin //ReadVersion1
       LRTFLabel := GetDynamicRTF;
       try
          CurNode := FindNode(Node,'Header');
          if CurNode <> nil then begin
             ClearRTF(LRTFLabel);
             Par := nil;
             if ReadLogo(CurNode) then begin
                GetPar; // there seems to be a blank line after the image
                Par.LoadedCharAttr := DefaultCha;
             end;
             ReadParagraph(CurNode,'Title');
             ReadParagraph(CurNode,'Text');
             if Assigned(Par) then begin
                GetPar; // there seems to be a blank line after Header
                Par.LoadedCharAttr := DefaultCha;
             end;
             // Dont care much about formating / not displayed..
             HF_Sections[hf_HeaderAll] := LRTFLabel.AsString;
          end;

          CurNode := FindNode(Node,'Footer');
          if CurNode <> nil then begin
             ClearRTF(LRTFLabel);
             Par := nil;
             // add a Blank Line
             GetPar;
             Par.LoadedCharAttr := DefaultCha;
             ReadParagraph(CurNode,'Text');
             ReadLogo(CurNode);
             LRTFLabel.Refresh;
             if not LRTFLabel.IsEmpty then // may just be the blank line..
                HF_Sections[hf_FooterAll] := LRTFLabel.AsString;
          end;

       finally
          LRTFLabel.Free;
       end;
    end;//ReadVersion1


begin
   Reset;
   Result := false;
   if not Assigned(Node) then
      Exit;

   try
   CurNode := FindNode(Node,'Settings');
   if CurNode <> nil then begin
      if GetNodeText(CurNode,'FooterItems',Ws) then begin
         ws := uppercase(Ws);
         FooterItems := [];
         if Pos('C',ws) <> 0 then
            FooterItems := FooterItems + [fiClientCode];
         if Pos('N',ws) <> 0 then
            FooterItems := FooterItems + [fiPageNumbers];
         if Pos('P',ws) <> 0 then
            FooterItems := FooterItems + [fiPrinted];
         if Pos('T',ws) <> 0 then
            FooterItems := FooterItems + [fiTime];
         if Pos('U',ws) <> 0 then
            FooterItems := FooterItems + [fiUser];
      end;

      if GetNodeText(CurNode,'HFEnabled',ws) then
         HF_Enabled := StrToBool(ws);
      if GetNodeText(CurNode,'RoundValues',ws) then
         RoundValues := StrToBool(ws);
      if GetNodeText(CurNode,'NewPageforAccounts',ws) then
         NewPageforAccounts := StrToBool(ws);
      if GetNodeText(CurNode,'Style',ws) then
         HF_Style := ws;

   end;

   if Version = '1' then
     ReadVersion1
   else

   for I := integer(Low(HF_Sections)) to integer(High(HF_Sections)) do
      HF_Sections[THFSection(I)] := ReadRTFData(CurNode, HFSectionNames[THFSection(I)]);

   (*
   /// Old stuff
   CurNode := FindNode(Node,'Header');
   if CurNode <> nil then begin
      H_Title := GetNodeTextStr(CurNode,'Title', H_Title);
      StrToFont(GetNodeTextStr(CurNode,'TitleFont',''),H_TitleFont);
      ReadAlignment(CurNode,'TitleAlign',H_TitleAlignment);
      ReadColor(CurNode,'TitleBackground',H_TitleColor);

      H_Text := ExpandEol(GetNodeTextStr(CurNode,'Text', H_Text));
      StrToFont(GetNodeTextStr(CurNode,'TextFont',''),H_TextFont);
      ReadAlignment(CurNode,'TextAlign',H_TextAlignment);
      ReadColor(CurNode,'TextBackground',H_TextColor);

      H_LogoFile := GetNodeTextStr(CurNode,'LogoFile', H_LogoFile);
      H_LogoFileWidth := GetNodeTextInt(CurNode,'LogoWidth',H_LogoFileWidth);
      H_LogoFileHeight := GetNodeTextInt(CurNode,'LogoHeight',H_LogoFileHeight);
      ReadAlignment(CurNode,'LogoAlign',H_LogoFileAlignment);
      if GetNodeText(CurNode,'LogoAspect',ws) then
         H_LogoFileAspect := StrToBool(ws);

   end;
   CurNode := FindNode(Node,'Footer');
   if CurNode <> nil then begin
      F_Text := ExpandEol(GetNodeTextStr(CurNode,'Text', F_Text));
      StrToFont(GetNodeTextStr(CurNode,'TextFont',''),F_TextFont);
      ReadAlignment(CurNode,'TextAlign',F_TextAlignment);
      ReadColor(CurNode,'TextBackground',F_TextColor);

      F_LogoFile := GetNodeTextStr(CurNode,'LogoFile', F_LogoFile);
      F_LogoFileWidth := GetNodeTextInt(CurNode,'LogoWidth',F_LogoFileWidth);
      F_LogoFileHeight := GetNodeTextInt(CurNode,'LogoHeight',F_LogoFileHeight);
      ReadAlignment(CurNode,'LogoAlign',F_LogoFileAlignment);
      if GetNodeText(CurNode,'LogoAspect',ws) then
         F_LogoFileAspect := StrToBool(ws);
   end;
   *)
   Result := True;
   except
   end;
end;

procedure TReportTypeParams.Reset;
var I: Integer;
begin
   for I := integer(Low(HF_Sections)) to integer(High(HF_Sections)) do
      HF_Sections[THFSection(I)] := '';

   StrToFont(DefaultFontString, H_TitleFont);
   StrToFont(DefaultFontString, H_TextFont);
   StrToFont(DefaultFontString, F_TextFont);
   HF_Enabled := False;
   FooterItems := [fiClientCode, fiPageNumbers, fiPrinted];
   H_LogoFileAlignment := taLeftJustify;
   F_LogoFileAlignment := taLeftJustify;
   H_TextAlignment := taLeftJustify;
   F_TextAlignment := taLeftJustify;
   H_TextAlignment := taLeftJustify;
   H_TitleColor := clNone;
   H_TextColor := clNone;
   F_TextColor := clNone;
   RoundValues := Globals.PRACINI_RoundCashFlowReports;
   NewPageforAccounts := Globals.PRACINI_Reports_NewPage;
   H_LogoFile := '';
   H_LogoFileWidth := 0;
   H_LogoFileHeight := 0;
   H_LogoFileAspect := True;
   H_Title := '';
   H_Text := '';
   F_LogoFile := '';
   F_LogoFileWidth := 0;
   F_LogoFileHeight := 0;
   F_LogoFileAspect := True;
   F_Text  := '';
end;


function TReportTypeParams.SaveToNode(Node: IxmlNode): Boolean;
var CurNode: IxmlNode;
    I: Integer;
    procedure SaveAlignment(Name: string; Value: TAlignment);
    begin
       case Value of
          taLeftJustify: SetNodeText(CurNode,Name,'Left');
          taRightJustify: SetNodeText(CurNode, Name, 'Right');
          taCenter: SetNodeText(CurNode, Name, 'Center');
       end;
    end;
    procedure SaveText(Name, Value: string);
    begin
       if Value > '' then
         SetNodeText(CurNode, Name, Value);
    end;
    procedure SaveInt(Name: string; Value: Integer);
    begin
       if Value <> 0 then
          SetNodeTextInt(CurNode, Name, Value);
    end;


    function FooterItemText: string;
    begin
        Result := '';
        if fiClientCode in FooterItems then
           Result := Result + 'C';
        if fiPageNumbers in FooterItems then
           Result := Result + 'N';
        if fiPrinted in FooterItems then
           Result := Result + 'P';
        if fiTime in FooterItems then
           Result := Result + 'T';
        if fiUser in FooterItems then
           Result := Result + 'U';
    end;
    procedure SaveColor(Name: string; Value: TColor);
    begin
       if Value <> clNone then
          SaveText(Name, IntTostr(Value));
    end;
begin

   Result := False;
   try
   CurNode := node.AppendChild(node.OwnerDocument.CreateElement('Settings'));
   SetNodeText(CurNode,'FooterItems',FooterItemText);
   SaveText('HFEnabled',BoolToStr(HF_Enabled));
   SaveText('RoundValues',BoolToStr(RoundValues));
   SaveText('NewPageforAccounts',BoolToStr(NewPageforAccounts));
   SaveText('Style',HF_Style);


    for I := integer(Low(HF_Sections)) to integer(High(HF_Sections)) do
      SaveRTFData(CurNode, HFSectionNames[THFSection(I)], HF_Sections[THFSection(I)] );


   (* Old stuff
    // Add the Header

   CurNode := node.AppendChild(node.OwnerDocument.CreateElement('Header'));

   SaveText('Title',H_Title);
   SaveText('TitleFont',FontToStr(H_TitleFont));
   SaveAlignment('TitleAlign',H_TitleAlignment);
   SaveColor('TitleBackground', H_TitleColor);
   SaveText('Text',H_Text);
   SaveText('TextFont',FontToStr(H_TextFont));
   SaveAlignment('TextAlign',H_TextAlignment);
   SaveColor('TextBackground', H_TextColor);

   SaveText('LogoFile',H_LogoFile);
   SaveInt('LogoWidth',H_LogoFileWidth);
   SaveInt('LogoHeight',H_LogoFileHeight);
   SaveAlignment('LogoAlign',H_LogoFileAlignment);
   SaveText('LogoAspect',BoolToStr(H_LogoFileAspect));

   // Add the Footer
   CurNode := node.AppendChild(node.OwnerDocument.CreateElement('Footer'));

   SaveText('Text',F_Text);
   SetNodeText(CurNode,'TextFont',FontToStr(F_TextFont));
   SaveAlignment('TextAlign',F_TextAlignment);
   SaveColor('TextBackground', F_TextColor);

   SaveText('LogoFile',F_LogoFile);
   SaveInt('LogoWidth',F_LogoFileWidth);
   SaveInt('LogoHeight',F_LogoFileHeight);
   SaveAlignment('LogoAlign',F_LogoFileAlignment);
   SaveText('LogoAspect',BoolToStr(F_LogoFileAspect));
   *)
   Result := true;
   except

   end;
end;



{ TStyle }

procedure TStyleItem.AssignTo(Dest: TPersistent);
   const
     POINT_TO_01MM = 3.514;
     LINE_SIZE_INFLATION = 1.3;
begin

  if Dest is TFont then begin
     TFont(Dest).Name := FontName;
     TFont(Dest).Size := Size;
     TFont(Dest).Style := Style;
     TFont(Dest).Color := Color;
  end else if Dest is TPanel then begin
     AssignTo(TPanel(Dest).Font);
     TPanel(Dest).Alignment := Alignment;
     if (background <> clnone) then
        TPanel(Dest).Color := backGround
     else
        TPanel(Dest).Color := clWhite;

     TPanel(Dest).Height := 10 + Round(Size * 1.5);
  end else if Dest is THeaderFooterLine then begin
     AssignTo(THeaderFooterLine(Dest).Font);
     if not THeaderFooterLine(Dest).BackFilled then
        THeaderFooterLine(Dest).Style.BackColor := background;
     THeaderFooterLine(Dest).StyleAlignment := AlignmentToJustification(Alignment);
     THeaderFooterLine(Dest).LineType := hftCustom;
     //THeaderFooterLine(Dest).Style.BorderColor := clRed;
  end else if Dest is TBKPrintJob then begin
     AssignTo(TBKPrintJob(Dest).Canvas.Font);
     if TBKPrintJob(Dest).FontScaleFactor <> 1.0 then
        TBKPrintJob(Dest).Canvas.Font.Size :=
           Trunc( TBKPrintJob(Dest).Canvas.Font.Size * TBKPrintJob(Dest).FontScaleFactor);
           
  end else if Dest is TStyleItem then  begin
     TStyleItem(Dest).FontName := FontName;
     TStyleItem(Dest).Size := Size;
     TStyleItem(Dest).Style := Style;
     TStyleItem(Dest).Color := Color;
     TStyleItem(Dest).Alignment := Alignment;
     TStyleItem(Dest).backGround := backGround;
  end;
end;

constructor TStyleItem.Create;
begin
   inherited;
   Reset;
end;

destructor TStyleItem.Destroy;
begin
  inherited;
end;


function TStyleItem.FontString: string;
begin
   Result :=
      '"' + FontName + '","' + FontStyleToStr(Style) +
      '",' + IntToStr(Size);
   if not ((Color = clBlack) or (Color = clWindowText)) then
       Result := result + ',' + IntToStr(Color);
end;



function TStyleItem.ReadFromNode(Node: IxmlNode): Boolean;
var ws: WideString;
begin
  Result := false;
  if Node <> nil then begin
     try
        StringFont(GetNodeTextStr(Node,'Font',''));
        BackGround := GetNodeTextInt(Node,'BackGround',BackGround);
        ws := GetNodeTextStr(Node,'Algnment','');
        if sametext(ws,'Left') then
           Alignment := taLeftJustify
        else if sametext(ws,'Right') then
           Alignment := taRightJustify
        else
           Alignment := taCenter;

        Result := True;
     except
     end;
  end else
     Reset;
end;

procedure TStyleItem.Reset;
begin
   Color := clWindowText;
   FBackGround := clNone;
   Size := 8;
   FontName := 'Arial';
   Alignment := taCenter;
   Style := [];
end;

function TStyleItem.SaveToNode(Node: IxmlNode): Boolean;

begin
  Result := false;
  if Node <> nil then begin
     try
        SetNodeTextStr(Node,'Font',FontString);
        case Alignment of
           taLeftJustify: SetNodeTextStr(Node,'Algnment','Left');
           taRightJustify: SetNodeTextStr(Node,'Algnment', 'Right');
           taCenter: SetNodeTextStr(Node,'Algnment', 'Center');
        end;
        if BackGround <> clWindow then
           SetNodeTextInt(Node,'BackGround',BackGround);
        Result := True;
     except
     end;
  end else
     Reset;
end;

procedure TStyleItem.SetBackground(const Value: TColor);
begin
   FBackground := Value;
   if (FBackground = clWindow)
   or (FBackground = clWhite) then
      FBackground := clNone;
end;

procedure TStyleItem.StringFont(Value: string);
var TextLines: TStringList;
    C: integer;
begin
   TextLines := TStringList.Create;
   try
      TextLines.CommaText := Value;
      c := Textlines.Count;
      if c = 0 then exit;
      FontName := TextLines[0];
      if c = 1 then exit;
      Style := StrToFontStyle(TextLines[1]);
      if c = 2 then exit;
      Size := StrToInt(TextLines[2]);
      if c = 3 then exit;
      Color := StrToInt(TextLines[3]);
   finally
      TextLines.Free;
   end;
end;

{ TStyleItems }

procedure TStyleItems.Assign(Source: TPersistent);
var I: integer;
begin
   if not (Source is TStyleItems) then
      Exit;
   for I := ord(Low(TStyleTypes)) to ord(High(TStyleTypes)) do
      TStyleItems(Source).StyleItems[I].Assignto(StyleItems[I]);
   Name := TStyleItems(Source).Name;
   DetailBlinds := TStyleItems(Source).DetailBlinds;
end;

constructor TStyleItems.Create(const aName:string);
var I: integer;
begin
  for I := ord(Low(TStyleTypes)) to ord(High(TStyleTypes)) do
     Items[TStyleTypes(I)] := TStyleItem.Create;

  Reset;
  Name := AName;
  Load;
end;

destructor TStyleItems.Destroy;
var I: integer;
begin
  for I := ord(Low (TStyleTypes)) to ord(High (TStyleTypes)) do
     Items[TStyleTypes(I)].Free;

  inherited;
end;

function TStyleItems.Filename: string;
begin
   Result := Globals.StyleDir + Name + StyleExt;
end;

function TStyleItems.GetStyleItems(index: integer): TStyleItem;
begin
   if (index >=ord(Low (TStyleTypes)))
   and (index <= ord(High (TStyleTypes))) then
      Result := Items[TStyleTypes(index)]
   else
      Result := nil;
end;

procedure TStyleItems.load;
var Document : IXMLDocument;
    bn : IXMLNode;
    i: integer;
begin
    Reset;
    if Name = '' then
       Exit;

    Document := CreateXMLDoc;
    try try
       Document.Text := '';
       Document.load (Filename);
       bn := FindNode(Document, 'StyleItems');
       if bn <> nil then
         for I := ord(Low (TStyleTypes)) to ord(High (TStyleTypes)) do
            StyleItems[i].ReadFromNode (FindNode(bn,ReportStyleItemNames[TStyleTypes(I)]));
       DetailBlinds := GetNodeTextBool(Document,'Blinds',False);
    except

    end;
    finally
       Document := nil;
    end;
end;

procedure TStyleItems.Reset;
var I: Integer;
begin
   for I := ord(Low(TStyleTypes)) to ord(High(TStyleTypes)) do
      with Items[TStyleTypes(I)] do begin
        Reset;
        case TStyleTypes(I) of
        siClientName : Size := 10;
        siTitle      : Size := 15;
        siSubTitle   : Size := 10;
        siSectionTitle : begin
            Style := [fsUnderline];
            Alignment := taLeftJustify;
         end;
        siHeading      : Style := [fsUnderline];
        siSectionTotal : Alignment := taRightJustify;
        siGrandTotal   : Alignment := taRightJustify;
        siFootNote     : Alignment := taLeftJustify;
        siNormal       : Alignment := taLeftJustify;
        siFooter       : Size := 6;
        end;
      end;
end;

procedure TStyleItems.Save;
var Document : IXMLDocument;
    bn : IXMLNode;
    i: integer;
begin
   if Name = '' then
      Exit;
   Document := CreateXMLDoc;
   try
      Document.Text := '';
      bn := EnsureNode(Document, 'StyleItems');
      SetNodeText(bn,'Version','1');
      for I := ord(Low (TStyleTypes)) to ord(High (TStyleTypes)) do
         StyleItems[i].SavetoNode(EnsureNode(bn,ReportStyleItemNames[TStyleTypes(I)]));
      SetNodeTextBool(bn,'Blinds',DetailBlinds);
      Document.Save(Filename,ofIndent);
   finally
      Document := nil;
   end;
end;

procedure TStyleItems.SetDetailBlinds(const Value: Boolean);
begin
  FDetailBlinds := Value;
end;

procedure TStyleItems.SetName(const Value: string);
begin
  FName := Value;
end;

end.
