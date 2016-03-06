unit PromoWindowObj;

interface

uses LogUtil, Classes, SysUtils, contnrs, ipshttps, uHttpLib, uLKJSON, Graphics,
  ExtCtrls, Windows, WinUtils, SYDEFS;

type
  {Contenet types}
  TContentType = (ctAll, ctUpgrade, ctTechnical, ctMarketing, ctUnknown);
  {Country types}
  TCountryType = (gNZ, gAU, gUK, gANY);
  TCountryTypes = set of TCountryType;
  {user Types}
  TUserType = (utAdmin, utNormal, utRestricted, utPractice, utBooks);
  TUserTypes = set of TUserType;
  {Asset types}
  TAssetType = (atUnknown, atImage, atVideo, atPDF);

  {Display types used for displaying the contents in the form}
  TDisplayTypes = set of TContentType;

  TProcessListType = (plCountry, plUserType);

  {Content object}
  TContentfulObj = class
  private
    FContentType: TContentType;
    FTitle: string;
    FDescription: widestring;
    FURL: string;
    FPriority: Integer;
    FAvailableIn: TCountryTypes;
    FCreatedAt: TDateTime;
    FContentIndex : Integer;
    FValidInVersions: TStringList;
    FValidStartDate: TDateTime;
    FValidEndDate: TDateTime;
    FValidUsers : TUserTypes;
    FPageIndexWhereToDisplay : Integer;
    FIsImageAvilable : Boolean;

    FMainImageID : string;// This is just to go thru the json to get the original image file from the asset section
    FMainImageBitmap : Graphics.TBitmap;

    // For display purpose
    FFrameHeightRequired : Integer;
  public
    Constructor Create;
    Destructor Destroy;override;

    //Display fields
    property ContentType: TContentType read FContentType write FContentType;
    property Title: string read FTitle write FTitle;
    property Description: widestring read FDescription write FDescription;
    property URL: string read FURL write FURL;
    property AvailableIn: TCountryTypes read FAvailableIn write FAvailableIn;
    property CreatedAt : TDateTime read FCreatedAt write FCreatedAt;
    //Validation fields
    property Priority: Integer read FPriority write FPriority;
    property Geography: TCountryTypes read FAvailableIn write FAvailableIn;
    property ValidInVersions: TStringList read FValidInVersions write FValidInVersions;
    property ValidStartDate: TDateTime read FValidStartDate write FValidStartDate;
    property ValidEndDate: TDateTime read FValidEndDate write FValidEndDate;
    property ValidUsers : TUserTypes read FValidUsers write FValidUsers;

    // Display control fields - Used for display it in the promo window
    property IsImageAvilable : Boolean read FIsImageAvilable write FIsImageAvilable;
    property PageIndexWhereToDisplay : Integer read FPageIndexWhereToDisplay write FPageIndexWhereToDisplay;
    property MainImageID : string read FMainImageID write FMainImageID;
    property MainImageBitmap : Graphics.TBitmap read FMainImageBitmap write FMainImageBitmap;
    property ContentIndex : Integer read FContentIndex write FContentIndex;

    //For display Purpose
    property FrameHeightRequired : Integer read FFrameHeightRequired write FFrameHeightRequired;
  end;

  {Represents Content asset object}
  TContentfulAssetObj = class
  private
    FLinkID : string;
    FURL : string;
    FAssetType : TAssetType;
    FFileName : string;
    FTitle : string;
    FDescription : string;
  public
    property LinkID : string read FLinkID write FLinkID;
    property URL : string read FURL write FURL;
    property AssetType : TAssetType read FAssetType write FAssetType;
    property FileName : string read FFileName write FFileName;
    property Title : string read FTitle write FTitle;
    property Description : string read FDescription write FDescription;
  end;

  {List of contents}
  TContentfulDataList = class
  private
    FContentList : TObjectList;
    FipsHTTPS: TipsHTTPS;
    FContentFulResponseJSON : string;
    {If a content type is specified, we can specify order also in the query to contentful site.
    But if we go for all content types, we can not specify the order, so we need our own sorting
    method to sort the data}

    //This instance is executed within a thread, the Windows File Locking of the log file is not thread safe
    fOwnerThread : TThread;                   // Owner thread to synchronise to
    fSynchroniseLogMsgType  : TMessageType;
    fSynchroniseLogUnitName : string;
    fSynchroniseLogStat_ID  : byte;
    fSynchroniseLogLockLog  : Boolean;
    fSynchroniseLogMessage  : string;

    FProcessingData : Boolean;
    {Start of the data transfer function, clear the storage list and make it
    ready for the data receives}
    procedure StartDataTransfer(Sender: TObject;Direction: Integer);
    {End of the data transfer function- This procedure process all data received}
    procedure EndDataTransfer(Sender: TObject;Direction: Integer);
    {This procedure stores each set of data receives}
    procedure TransferData(Sender: TObject;
                            Direction: Integer;
                            BytesTransferred: LongInt;
                            Text: String);
    {Get a specific content on teh specified index}
    function GetContent(aIndex:Integer):TContentfulObj;

    {Process the valid country list for the content, can be any , nz or au}
    function ProcessCountry(aCountry : TlkJSONbase):TCountryTypes;
    {Process the valid users list for the content, can be admin, normal, restricted, practice or books}
    function ProcessUsers(aUserTypes : TlkJSONbase):TUserTypes;
    {Process valid versions for the content, it's a comma separated list}
    function ProcessVersions(aVersions :TlkJSONbase):string;
    {Process Date}
    function ProcessDate(aDate : string):TDateTime;
    {This function grabs the image from the url and returns in the bitmap object and pass it to the calling function}
    function GetImageFromURL(aURL: string; var aMainImageBitmap: Graphics.TBitmap):Boolean;
    function SetContentType(aContenetType: string): TContentType;
  public
    constructor Create; virtual; // Introduce Owner thread to synchronise, log file write, to
    destructor Destroy;override;
    {Builds the url for contentful api}
    function GetContentfulURL(aContentType: TContentType):string;
    {This function talks to contentful api and grabs all available contents}
    function GetContents(aContentType: TContentType;RetryCount : integer; var Retries : integer): Boolean;

    //This instance is executed within a thread, the Windows File Locking of the log file is not thread safe
    procedure SetAndSynchroniseLogMessage(
            aSynchroniseLogMsgType : TMessageType; aSynchroniseLogUnitName,
            aSynchroniseLogMessage : string; aSynchroniseLogStat_ID : byte = 0;
            aSynchroniseLogLockLog: Boolean = True );
    procedure SynchroniseLogMessage;
    function GetDateFromStr(ADateStr: string):TDateTime;
    procedure ProcessJSONData(aJSONData:string='');
    function Count : Integer;
    procedure ClearList;
    property Item[Index:Integer] : TContentfulObj read GetContent;
    property ProcessingData : Boolean read FProcessingData write FProcessingData;
    property OwnerThread : TThread read fOwnerThread write fOwnerThread;
  end;

  TDisplayContents = class
  private
    FDisplayTypes : TDisplayTypes;
    FSourceContents : TContentfulDataList;

    {This object list doen't own the objects inside the list. So no need
    to free them. It basically own by FSourceContents}

    FDisplayContents : TObjectList;

    FPromoMainWindowHeight : Integer;
    FNoOfPagesRequired : Integer;
    FTimerStopsContentfulRead: TTimer;
    FUpgradeVersionFrom : string;
    FUpgradeVersionTo : string;
    FDateToValidate : TDateTime;

    function GetContent(aIndex:Integer):TContentfulObj;
    function GetProcessingData:Boolean;
    procedure SetProcessingData(Value : Boolean);
    procedure TimerStopsContentfulReadTimer(Sender: TObject);
    procedure GetUpgradeVersions(VersionNoFrom:string;var PrevMajorVersion: string; var PrevMinorVersion: string);
    function GetOwnerThread : TThread;
    procedure SetOwnerThread( aValue : TThread );
  public
    constructor Create;
    destructor Destroy;override;
    function LoadAllDisplayContents():Boolean;
    function ListValidContents:Boolean;
    function ValidateContent(aContent: TContentfulObj):Boolean;
    procedure SetContentDisplayProperties;
    function Count:Integer; // this is the count of contents valid only at the moment to display
    function TotalContents:Integer; // This returns the total contents returned from contentful site
    procedure ClearList;
    procedure StartContentfulReadTimer;
    procedure SortContentfulData;

    property DisplayTypes : TDisplayTypes read FDisplayTypes write FDisplayTypes;
    property SourceContents : TContentfulDataList read FSourceContents write FSourceContents;
    property DisplayContents : TObjectList read FDisplayContents write FDisplayContents;
    property PromoMainWindowHeight : Integer read FPromoMainWindowHeight write FPromoMainWindowHeight;
    property NoOfPagesRequired : Integer read FNoOfPagesRequired write FNoOfPagesRequired;
    property Item[Index:Integer] : TContentfulObj read GetContent;
    property ProcessingData : Boolean read GetProcessingData write SetProcessingData;

    // For validation purpose
    property UpgradeVersionFrom : string read FUpgradeVersionFrom write FUpgradeVersionFrom;
    property UpgradeVersionTo : string read FUpgradeVersionTo write FUpgradeVersionTo;
    property DateToValidate : TDateTime read FDateToValidate write FDateToValidate;

    property OwnerThread : TThread read GetOwnerThread write SetOwnerThread;
  end;

  TContentfulThread = class(TThread)
  protected
  public
    procedure Execute;override;
  end;

  procedure StartPromoThread;
  
var
  DisplayPromoContents : TDisplayContents;
  CritSect : TRTLCriticalSection;
  ContentfulThread : TContentfulThread;
  ShowedPromoWindow : Boolean;

const
  PRACTICE_CONTENTSPACE_ID = 'wdv0bic4eogs';
  PRACTICE_CONTENTSPACE_ACCESSTOKEN = 'efb76108931ac5ad44d673725b637bbda58d97d3dada8a344411dd5fb41af43c';

  PRACTICE_TYPE_UPGRADE_ID = 'Ts5nC2Lm24ISAQm4aUO6E';
  PRACTICE_TYPE_MARKETING_ID = '3HWJey5vEkGwyEWA8SeOwU';
  PRACTICE_TYPE_TECHNICAL_ID = '7880fBmHpSqIKSaGgsYyug';

  CONTENT_HEIGHT_WITHOUTIMAGE = 200;
  CONTENT_HEIGHT_WITHIMAGE = 500;
  CONTENT_MAINSCREEN_HEIGHT = 840;
  CONTENT_RETRY_COUNT = 3;
  CONTENT_MAX_PAGES_TODISPLAY = 10;
  CONTENT_READ_TIMEOUT = 5000; //5 SEC

implementation

uses Dialogs, Math, Variants,IdBaseComponent, IdComponent, IdTCPConnection,
      IdTCPClient,IdHTTP, Forms, Globals, DateUtils, bkURLs;

var
  DebugMe : Boolean = False;
const
  UnitName = 'PromoWindowObj';

procedure StartPromoThread;
begin
  ContentfulThread := TContentfulThread.Create(False);
  Application.ProcessMessages;
  // Automatically free on terminate. Property is set for that
end;

{Sort Compare function used to sort the contentful list}
function CompareObjects(Item1, Item2 : Pointer):Integer;
begin
  if TContentfulObj(Item1).ContentIndex < TContentfulObj(Item2).ContentIndex then
    Result := -1
  else if TContentfulObj(Item1).ContentIndex > TContentfulObj(Item2).ContentIndex then
    Result := 1
  else
  begin
    if TContentfulObj(Item1).Priority < TContentfulObj(Item2).Priority then
      Result := -1
    else if TContentfulObj(Item1).Priority = TContentfulObj(Item2).Priority then
    begin
      if TContentfulObj(Item1).CreatedAt < TContentfulObj(Item2).CreatedAt then
        Result := 1
      else if TContentfulObj(Item1).CreatedAt = TContentfulObj(Item2).CreatedAt then
        Result := 0
      else
       Result := -1;
    end
    else
      Result := 1;
  end;
end;

{ TContentObj }

constructor TContentfulObj.Create;
begin
  inherited;

  FContentType:= ctAll;
  FContentIndex := 1;
  FTitle:= '';
  FDescription:= '';
  FURL:= '';
  FPriority:= 1;
  FAvailableIn := [gNZ];
  FValidStartDate:= 0;
  FValidEndDate:= 0;
  FValidInVersions:= TStringList.Create;
  FValidInVersions.Sorted := True;
  FIsImageAvilable := False;
  FMainImageID := '';
  FPageIndexWhereToDisplay := 1;
  FMainImageBitmap := Graphics.TBitmap.Create;
end;

destructor TContentfulObj.Destroy;
begin
  FValidInVersions.Clear;
  FreeAndNil(FValidInVersions);
  FreeAndNil(FMainImageBitmap);

  inherited;
end;

{ TContents }

procedure TContentfulDataList.ClearList;
begin
  FContentList.Clear;
end;

function TContentfulDataList.Count: Integer;
begin
  Result := FContentList.Count;
end;

constructor TContentfulDataList.Create;
begin
  inherited Create;
  fOwnerThread := nil;
  FContentList:= TObjectList.Create;
  FContentFulResponseJSON := '';

  FipsHTTPS:= TipsHTTPS.Create(Nil);
  FipsHTTPS.OnStartTransfer := StartDataTransfer;
  FipsHTTPS.OnEndTransfer := EndDataTransfer;
  FipsHTTPS.OnTransfer := TransferData;

end;

destructor TContentfulDataList.Destroy;
begin
  FContentList.Clear;// clear will free all objects in the list
  FreeAndNil(FContentList);

  FipsHTTPS.Connected := False;
  FreeAndNil(FipsHTTPS);

  inherited;
end;

function TContentfulDataList.GetDateFromStr(ADateStr: string):TDateTime;
var
  Day, Year, Month, Hour , Min, Sec : Word;
begin
  Year := StrToIntDef(Copy(ADateStr, 1,4),0);
  ADateStr := Copy(ADateStr,6,Length(ADateStr));

  Month := StrToIntDef(Copy(ADateStr, 1,2),0);
  ADateStr := Copy(ADateStr,4,Length(ADateStr));

  Day := StrToIntDef(Copy(ADateStr, 1,2),0);
  ADateStr := Copy(ADateStr,4,Length(ADateStr));

  Hour := StrToIntDef(Copy(ADateStr, 1,2),0);
  ADateStr := Copy(ADateStr,4,Length(ADateStr));

  Min := StrToIntDef(Copy(ADateStr, 1,2),0);
  ADateStr := Copy(ADateStr,4,Length(ADateStr));

  Sec := StrToIntDef(Copy(ADateStr, 1,2),0);
  Result := EncodeDateTime(Year, Month, Day, Hour, Min , Sec, 0);
  ADateStr := Copy(ADateStr,4,Length(ADateStr));
end;

procedure TContentfulDataList.EndDataTransfer(Sender: TObject; Direction: Integer);
begin
  ProcessJSONData;
end;

{This function talks to contentful api and grabs all available contents}
function TContentfulDataList.GetContent(aIndex: Integer): TContentfulObj;
begin
  Result := Nil;
  if ((aIndex >= 0) and (aIndex < FContentList.Count)) then
    Result := TContentfulObj(FContentList.Items[aIndex]);
end;

function TContentfulDataList.GetContentfulURL(aContentType: TContentType): string;
begin
  //Add base url and space id
  if Trim(Globals.PRACINI_Contentful_API_URL)= '' then
    Globals.PRACINI_Contentful_API_URL := TUrls.DefContentfulAPIUrl;

  Result := Globals.PRACINI_Contentful_API_URL + '/' + PRACTICE_CONTENTSPACE_ID + '/';
  //Add access token
  Result := Result + 'entries?access_token=' +  PRACTICE_CONTENTSPACE_ACCESSTOKEN;

  {Set the content type required is you need contents from a specific
  content type. Otherwise no need to set content type}
  if aContentType <> ctAll then
  begin
    case aContentType of
      ctUpgrade : Result := Result + '&content_type=' + PRACTICE_TYPE_UPGRADE_ID;
      ctMarketing : Result := Result + '&content_type=' + PRACTICE_TYPE_MARKETING_ID;
      ctTechnical : Result := Result + '&content_type=' + PRACTICE_TYPE_TECHNICAL_ID;
    end;
    {set the order of contents - set it to priority at the moment}
    Result := Result + '&order=fields.priority';
  end;
end;

function TContentfulDataList.GetContents(aContentType: TContentType;RetryCount : integer; var Retries : integer): Boolean;
var
  URL : string;
begin
  Result := False;
  URL := GetContentfulURL(aContentType);
  try
    FipsHTTPS.ContentType := 'application/x-www-form-urlencoded';
    FipsHTTPS.Accept := 'application/json';
    FipsHTTPS.Get(URL);
    //FContentFulResponseJSON.Text := FipsHTTPS.TransferredData;
    //ProcessJSONData;
    Result := True;
    Application.ProcessMessages;
  except
    on E: Exception do begin
      // Do Nothing, suppress the error
// Windows File Locking of the log file is not thread safe      LogUtil.LogMsg(lmError, UnitName, ' Error in connecting to Contentful site, tried ' + IntToStr(Retries)+ ' time(s)');
// Windows File Locking of the log file is not thread safe      LogUtil.LogMsg(lmError, UnitName, E.Message);
      FContentFulResponseJSON := E.Message;
      inc( Retries );
      if Retries < RetryCount then
        GetContents(aContentType, RetryCount, Retries )
      else
          SetAndSynchroniseLogMessage( lmError, UnitName, // Windows File Locking of the log file is not thread safe
            format( 'Failed to Get %s (Contentful site), tried %s time(s), %s',
              [URL, intToStr( pred( Retries ) ), E.Message ] ) );

    end;
  end;
end;

function TContentfulDataList.GetImageFromURL(aURL: string; var aMainImageBitmap: Graphics.TBitmap):Boolean;
var
  idHTTP : TIdHTTP;
  MemStream : TMemoryStream;
  sURL : string;
begin
  Result := False;
  if Trim(aURL) = '' then
    Exit;

  idHTTP := TIdHTTP.Create(Application);
  MemStream := TMemoryStream.Create;
  try
    try
      sURL := aURL;
      if Pos('http:', sURL)<= 0 then
        sURL := 'http:' + sURL;

      idHTTP.Get(sURL, MemStream);

      Application.ProcessMessages;
      MemStream.Seek(0,soFromBeginning);
      aMainImageBitmap.LoadFromStream(MemStream);

      Result := True;
    except
      // No need to send any image back
    end;
  finally
    FreeAndNil(MemStream);
    FreeAndNil(idHTTP);
  end;
end;

function TContentfulDataList.ProcessCountry(aCountry : TlkJSONbase): TCountryTypes;
var
  i : Integer;
begin
  Result := [];

  if not Assigned(aCountry) then
    Exit;

  for i := 0 to aCountry.Count - 1 do
  begin
    if Assigned(aCountry.Child[i]) then
    begin
      if UpperCase(VarToStr(aCountry.Child[i].Value)) = 'ANY' then
        Result :=  Result + [gANY]
      else if UpperCase(VarToStr(aCountry.Child[i].Value)) = 'NZ' then
        Result :=  Result + [gNZ]
      else if UpperCase(VarToStr(aCountry.Child[i].Value)) = 'AU' then
        Result :=  Result + [gAU]
      else if UpperCase(VarToStr(aCountry.Child[i].Value)) = 'UK' then
        Result :=  Result + [gUK];
    end;
  end;
end;

function TContentfulDataList.ProcessDate(aDate: string): TDateTime;
var
  Day, Month, Year : Word;
  tmpList : TStringList;
begin
  Result := 0; // No date
  tmpList := TStringList.Create;
  try
    if Trim(aDate) = '' then
      Exit;

    aDate := '"' + StringReplace(aDate,'/','","',[rfReplaceAll, rfIgnoreCase]) + '"';
    tmpList.CommaText := aDate;
    if tmpList.Count <> 3 then
      Exit; // Invalid date

    Day := StrToIntDef(tmpList.Strings[0],0);
    Month := StrToIntDef(tmpList.Strings[1],0);
    Year := StrToIntDef(tmpList.Strings[2],0);
    if (Day in [1..31]) and
        (Month in [1..12]) and
        (Year > 0) then
    begin
      try
        Result := EncodeDate(Year, Month, Day);
      except
        SetAndSynchroniseLogMessage( lmDebug, UnitName, 'Invalid date sent from Contentful: ' + aDate ); // Windows File Locking of the log file is not thread safe
      end;
    end
    else
      SetAndSynchroniseLogMessage( lmDebug, UnitName, 'Invalid date sent from Contentful: ' + aDate ); // Windows File Locking of the log file is not thread safe
  finally
    FreeAndNil(tmpList);
  end;
end;

procedure TContentfulDataList.ProcessJSONData(aJSONData:string='');
var
  BaseJSONObject : TlkJSONbase;
  Items, Assets : TlkJSONbase;
  NewContent : TContentfulObj;
  AssetList : TObjectList;
  Asset : TContentfulAssetObj;
  Bitmap : Graphics.TBitmap;

  i : Integer;
  j: Integer;
begin
  ProcessingData := True;
  if DebugMe then
  begin
    SetAndSynchroniseLogMessage( lmDebug, UnitName, FContentFulResponseJSON ); // Windows File Locking of the log file is not thread safe
    // Windows File Locking of the log file is not thread safe    LogUtil.LogMsg(lmDebug, UnitName, FContentFulResponseJSON);
  end;

  {$IFDEF BK_UNITTESTINGON}
    if Trim(aJSONData) <> '' then
      FContentFulResponseJSON := aJSONData;
  {$ENDIF}

  try
    BaseJSONObject := TlkJSON.ParseText(FContentFulResponseJSON) as TlkJSONobject;
  except
    SetAndSynchroniseLogMessage( lmDebug, UnitName, 'JSON data from Contentful website is corrupted.');
    Exit;
  end;

  if not Assigned(BaseJSONObject) then
  begin
    SetAndSynchroniseLogMessage( lmDebug, UnitName, 'Contentful data is corrupted. BaseJSONObject is nil');
    Exit;
  end;

  Items := BaseJSONObject.Field['items'];

  if not Assigned(Items) then
  begin
    SetAndSynchroniseLogMessage( lmDebug, UnitName, 'Contentful data is corrupted. Items is nil');
    Exit;
  end;

  Assets := nil;
  if Assigned(BaseJSONObject.Field['includes']) and Assigned(BaseJSONObject.Field['includes'].Field['Asset']) then
    Assets := BaseJSONObject.Field['includes'].Field['Asset'];

  AssetList := TObjectList.Create;
  try
    {Read all contents and process it}
    for i := 0 to Items.Count - 1 do
    begin
      if not(Assigned(Items.Child[i]) and
          Assigned(Items.Child[i].Field['sys']) and
          Assigned(Items.Child[i].Field['fields']) and
          Assigned(Items.Child[i].Field['fields'].Field['title'])) then
        Continue;

      if VarToStr(Items.Child[i].Field['fields'].Field['title'].Value) <> '' then
      begin
        NewContent := TContentfulObj.Create;

        NewContent.Title := VarToStr(Items.Child[i].Field['fields'].Field['title'].Value);

        if Assigned(Items.Child[i].Field['fields'].Field['description'])then
          NewContent.Description := StringReplace(VarToStr(Items.Child[i].Field['fields'].Field['description'].Value),
                                    '/n', #13,[rfReplaceAll,rfIgnoreCase]);

        if Assigned(Items.Child[i].Field['fields'].Field['url'])then
          NewContent.URL := VarToStr(Items.Child[i].Field['fields'].Field['url'].Value);

        if Assigned(Items.Child[i].Field['fields'].Field['priority'])then
          NewContent.Priority := StrToIntDef(VarToStr(Items.Child[i].Field['fields'].Field['priority'].Value),1);

        if Assigned(Items.Child[i].Field['fields'].Field['geography'])then
          NewContent.AvailableIn := ProcessCountry((Items.Child[i].Field['fields'].Field['geography']));

        if Assigned(Items.Child[i].Field['fields'].Field['userType'])then
          NewContent.ValidUsers := ProcessUsers((Items.Child[i].Field['fields'].Field['userType']));

        if Assigned(Items.Child[i].Field['fields'].Field['validVersions'])then
          NewContent.ValidInVersions.CommaText := ProcessVersions(Items.Child[i].Field['fields'].Field['validVersions']);

        if Assigned(Items.Child[i].Field['fields'].Field['validFrom'])then
          NewContent.ValidStartDate := ProcessDate(VarToStr(Items.Child[i].Field['fields'].Field['validFrom'].Value));
        if Assigned(Items.Child[i].Field['fields'].Field['validUpto'])then
          NewContent.ValidEndDate := ProcessDate(VarToStr(Items.Child[i].Field['fields'].Field['validUpto'].Value));

        if Assigned(Items.Child[i].Field['sys'].Field['contentType']) and
          Assigned(Items.Child[i].Field['sys'].Field['contentType'].Field['sys']) and
          Assigned(Items.Child[i].Field['sys'].Field['contentType'].Field['sys'].Field['id'])then
            NewContent.ContentType := SetContentType(VarToStr(Items.Child[i].Field['sys'].Field['contentType'].Field['sys'].Field['id'].Value));

        if NewContent.ContentType = ctUpgrade then
          NewContent.ContentIndex := 1
        else if NewContent.ContentType in [ctTechnical, ctMarketing] then
          NewContent.ContentIndex := 2;

        if Assigned(Items.Child[i].Field['sys'].Field['createdAt'])then
          NewContent.CreatedAt := GetDateFromStr(VarToStr(Items.Child[i].Field['sys'].Field['createdAt'].Value));

        FContentList.Add(NewContent);

        if Assigned(Items.Child[i].Field['fields'].Field['imageFile']) then
        if Assigned(Items.Child[i].Field['fields'].Field['imageFile'].Field['sys']) then
        if Assigned(Items.Child[i].Field['fields'].Field['imageFile'].Field['sys'].Field['id']) then
          NewContent.MainImageID := VarToStr(Items.Child[i].Field['fields'].Field['imageFile'].Field['sys'].Field['id'].Value);

      end;
    end;
    {Read all assets and store it in a temporary list}
    if Assigned(Assets) then
    begin
      for i := 0 to Assets.Count - 1 do
      begin
        if Assigned(Assets.Child[i]) and
          Assigned(Assets.Child[i].Field['sys']) and
          Assigned(Assets.Child[i].Field['sys'].Field['id']) and
          Assigned(Assets.Child[i].Field['fields']) and
          Assigned(Assets.Child[i].Field['fields'].Field['file']) and
          Assigned(Assets.Child[i].Field['fields'].Field['file'].Field['url']) then
        begin
          Asset := TContentfulAssetObj.Create;

          Asset.LinkID := VarToStr(Assets.Child[i].Field['sys'].Field['id'].Value);
          Asset.URL := VarToStr(Assets.Child[i].Field['fields'].Field['file'].Field['url'].Value);

          if Assigned(Assets.Child[i].Field['fields'].Field['title']) then
            Asset.Title := VarToStr(Assets.Child[i].Field['fields'].Field['title'].Value);
          if Assigned(Assets.Child[i].Field['fields'].Field['description']) then
           Asset.Description := VarToStr(Assets.Child[i].Field['fields'].Field['description'].Value);
          if Assigned(Assets.Child[i].Field['fields'].Field['file'].Field['fileName']) then
            Asset.FileName := VarToStr(Assets.Child[i].Field['fields'].Field['file'].Field['fileName'].Value);
          if Assigned(Assets.Child[i].Field['fields'].Field['file'].Field['contentType']) then
          begin
            if Pos('image/', VarToStr(Assets.Child[i].Field['fields'].Field['file'].Field['contentType'].Value)) > 0 then
              Asset.AssetType := atImage;
          end;
          AssetList.Add(Asset);
        end;
      end;
    end;
    {process asset list if required and link asset to content}

    for i := 0 to FContentList.Count - 1 do
    begin
      NewContent := TContentfulObj(FContentList.Items[i]);
      for j := 0 to AssetList.Count - 1 do
      begin
        Asset := TContentfulAssetObj(AssetList.Items[j]);
        if NewContent.MainImageID = Asset.LinkID then
        begin
          if ((ExtractFileExt(Asset.URL)) = '.bmp') then
          begin
            Bitmap := Graphics.TBitmap.Create;
            try
              try
                GetImageFromURL(Asset.URL, Bitmap);
                if Assigned(Bitmap) then
                  NewContent.MainImageBitmap.Assign(Bitmap);
                if Assigned(NewContent.MainImageBitmap) then
                begin
                  NewContent.IsImageAvilable := True;
                end;
              except
                // no need to display image , just display data
              end;
            finally
              FreeAndNil(Bitmap);
            end;
          end;
        end;
      end;
    end;
    FipsHTTPS.Connected := False;
  finally
    ProcessingData := False;
    if Assigned(AssetList) then
    begin
      AssetList.Clear;
      FreeAndNil(AssetList);
    end;
    if Assigned(BaseJSONObject) then
      FreeAndNil(BaseJSONObject);
  end;
end;

function TContentfulDataList.ProcessUsers(aUserTypes : TlkJSONbase): TUserTypes;
var
  i : Integer;
begin
  Result := [];

  if not Assigned(aUserTypes) then
    Exit;

  for i := 0 to aUserTypes.Count - 1 do
  begin
    if Assigned(aUserTypes.Child[i]) then
    begin
      if UpperCase(VarToStr(aUserTypes.Child[i].Value)) = 'PRACTICE' then
        Result :=  Result + [utPractice]
      else if UpperCase(VarToStr(aUserTypes.Child[i].Value)) = 'ADMIN' then
        Result :=  Result + [utAdmin]
      else if UpperCase(VarToStr(aUserTypes.Child[i].Value)) = 'NORMAL' then
        Result :=  Result + [utNormal]
      else if UpperCase(VarToStr(aUserTypes.Child[i].Value)) = 'BOOKS' then
        Result :=  Result + [utBooks]
      else if UpperCase(VarToStr(aUserTypes.Child[i].Value)) = 'RESTRICTED' then
        Result :=  Result + [utRestricted];
    end;
  end;
end;

function TContentfulDataList.ProcessVersions(aVersions: TlkJSONbase): string;
var
  i : Integer;
  sValue : string;
begin
  Result := '';

  if not Assigned(aVersions) then
    Exit;

  for i := 0 to aVersions.Count - 1 do
  begin
    if Assigned(aVersions.Child[i]) then
    begin
      sValue := VarToStr(aVersions.Child[i].Value);
      if UpperCase(sValue) = 'ANY' then
        sValue := UpperCase(sValue);

      if Trim(Result) = '' then
        Result :=  sValue
      else
        Result :=  Result + ',' + sValue;
    end;
  end;
end;

procedure TContentfulDataList.SetAndSynchroniseLogMessage(
            aSynchroniseLogMsgType : TMessageType; aSynchroniseLogUnitName,
            aSynchroniseLogMessage : string; aSynchroniseLogStat_ID : byte = 0;
            aSynchroniseLogLockLog: Boolean = True );
begin
  fSynchroniseLogMsgType  := aSynchroniseLogMsgType;
  fSynchroniseLogUnitName := aSynchroniseLogUnitName;
  fSynchroniseLogMessage  := aSynchroniseLogMessage;
  fSynchroniseLogStat_ID  := aSynchroniseLogStat_ID;
  fSynchroniseLogLockLog  := aSynchroniseLogLockLog;
  if assigned( fOwnerThread ) then
    fOwnerThread.Synchronize( fOwnerThread, SynchroniseLogMessage );
end;

procedure TContentfulDataList.SynchroniseLogMessage;
begin
  LogUtil.LogMsg(
    fSynchroniseLogMsgType,
    fSynchroniseLogUnitName,
    fSynchroniseLogMessage,
    fSynchroniseLogStat_ID,
    fSynchroniseLogLockLog
  );
end;

function TContentfulDataList.SetContentType(
  aContenetType: string): TContentType;
begin
  Result := ctUnknown;

  if aContenetType = PRACTICE_TYPE_UPGRADE_ID then
    Result := ctUpgrade
  else if aContenetType = PRACTICE_TYPE_MARKETING_ID then
    Result := ctMarketing
  else if aContenetType = PRACTICE_TYPE_TECHNICAL_ID then
    Result := ctTechnical;
end;

procedure TContentfulDataList.StartDataTransfer(Sender: TObject; Direction: Integer);
begin
  FContentFulResponseJSON := '';
  ProcessingData := True;
end;

procedure TContentfulDataList.TransferData(Sender: TObject; Direction,
  BytesTransferred: Integer; Text: String);
begin
  FContentFulResponseJSON := FContentFulResponseJSON + Text;
end;

{ TDisplayContents }

procedure TDisplayContents.ClearList;
begin
  FDisplayContents.Clear;
end;

function TDisplayContents.Count: Integer;
begin
  Result := FDisplayContents.Count;
end;

constructor TDisplayContents.Create;
begin
  inherited;
  FDisplayTypes := [ctAll];
  FSourceContents := TContentfulDataList.Create;
  FDisplayContents := TObjectList.Create;
  FDisplayContents.OwnsObjects := False;
  FTimerStopsContentfulRead:= TTimer.Create(Nil);
  FTimerStopsContentfulRead.Interval := CONTENT_READ_TIMEOUT;
  FTimerStopsContentfulRead.OnTimer := TimerStopsContentfulReadTimer;
  // Default value. Can be set differently
  FPromoMainWindowHeight := CONTENT_MAINSCREEN_HEIGHT;
  FDateToValidate := Today;
end;

destructor TDisplayContents.Destroy;
begin
  if Assigned(FSourceContents) then
    FreeAndNil(FSourceContents);

  FreeAndNil(FTimerStopsContentfulRead);
  if Assigned(FDisplayContents) then
  begin
    FDisplayContents.Clear;
    FreeAndNil(FDisplayContents);
  end;
  inherited;
end;

function TDisplayContents.GetContent(aIndex: Integer): TContentfulObj;
begin
  Result := Nil;
  if ((aIndex >= 0) and (aIndex < FDisplayContents.Count)) then
    Result := TContentfulObj(FDisplayContents.Items[aIndex]);
end;

function TDisplayContents.GetOwnerThread: TThread;
begin
  result := nil;
  if assigned( SourceContents ) then
    result := SourceContents.OwnerThread;
end;

procedure TDisplayContents.GetUpgradeVersions(VersionNoFrom:string;var PrevMajorVersion,
  PrevMinorVersion: string);
var
  Position : Integer;
  VersionNo, sMajor , sMinor , sRelease : string;
begin
  PrevMajorVersion := '';
  PrevMinorVersion := '';
  VersionNo := VersionNoFrom;

  // Major version
  Position := Pos('.', VersionNo);
  if Position > 0 then
  begin
    sMajor := Copy(VersionNo, 1 , Position - 1);
    VersionNo := Copy(VersionNo, Position+1, Length(VersionNo));
  end;
  // Minor version
  Position := Pos('.', VersionNo);
  if Position > 0 then
  begin
    sMinor := Copy(VersionNo, 1 , Position - 1);
    VersionNo := Copy(VersionNo, Position+1, Length(VersionNo));
  end;
  // Release version
  Position := Pos(' ', VersionNo);
  if Position > 0 then
  begin
    sRelease := Copy(VersionNo, 1 , Position - 1);
    VersionNo := Copy(VersionNo, Position+1, Length(VersionNo));
  end;

  PrevMajorVersion := sMajor + '.' + sMinor;
  PrevMinorVersion := sMajor + '.' + sMinor + '.' +  sRelease;
end;

function TDisplayContents.GetProcessingData: Boolean;
begin
  Result := FSourceContents.ProcessingData;
end;

{This function call api internally using TContentfulDataList and validate the list
and choose only the required ones based on the user/date/versions}
function TDisplayContents.ListValidContents(): Boolean;
var
  i : Integer;
  Content : TContentfulObj;
begin
  FDisplayContents.Clear;
  for i := 0 to FSourceContents.Count - 1 do
  begin
    Content := FSourceContents.Item[i];
    if Assigned(Content) and
       (Content.ContentType in DisplayTypes) and
        ValidateContent(Content) then
    begin
      FDisplayContents.Add(Content);
    end;
  end;
  Result := True;
end;

function TDisplayContents.LoadAllDisplayContents: Boolean;
var
  RetryCount : Integer;
begin
  RetryCount := CONTENT_RETRY_COUNT;
  FSourceContents.ClearList;
  ProcessingData := True;
  Result := FSourceContents.GetContents(ctAll, 0, RetryCount);
  if not Result then
    ProcessingData := False;
end;

procedure TDisplayContents.SetContentDisplayProperties;
var
  i : Integer;
  Content : TContentfulObj;
  TotalWidth : Integer;
  PageIndex : Integer;
begin
  TotalWidth := 0;

  for i := 0 to FDisplayContents.Count - 1 do
  begin
    Content := TContentfulObj(FDisplayContents.Items[i]);
    if Assigned(Content) then
    begin
      if Content.IsImageAvilable then
        TotalWidth := TotalWidth + CONTENT_HEIGHT_WITHIMAGE
      else
        TotalWidth := TotalWidth + CONTENT_HEIGHT_WITHOUTIMAGE;
    end;
    NoOfPagesRequired := 1;
    if FPromoMainWindowHeight <> 0 then
      NoOfPagesRequired := Ceil(TotalWidth/FPromoMainWindowHeight);
  end;

  PageIndex := 1;
  TotalWidth := 0;

  for i := 0 to FDisplayContents.Count - 1 do
  begin
    Content := TContentfulObj(FDisplayContents.Items[i]);
    if Assigned(Content) then
    begin
      if Content.IsImageAvilable then
        TotalWidth := TotalWidth + CONTENT_HEIGHT_WITHIMAGE
      else
        TotalWidth := TotalWidth + CONTENT_HEIGHT_WITHOUTIMAGE;

      if (TotalWidth < FPromoMainWindowHeight) then
        Content.PageIndexWhereToDisplay := PageIndex
      else
      begin
        Inc(PageIndex);
        if PageIndex > CONTENT_MAX_PAGES_TODISPLAY then
          PageIndex := 0;
          
        Content.PageIndexWhereToDisplay := PageIndex;
        TotalWidth := 0;
      end;
    end;
  end;
end;

procedure TDisplayContents.SetOwnerThread(aValue: TThread);
begin
  SourceContents.OwnerThread := aValue;
end;

procedure TDisplayContents.SetProcessingData(Value : Boolean);
begin
  FSourceContents.ProcessingData := Value;
end;

procedure TDisplayContents.SortContentfulData;
begin
  FDisplayContents.Sort(TListSortCompare(@CompareObjects));
end;

procedure TDisplayContents.StartContentfulReadTimer;
begin
  FTimerStopsContentfulRead.Enabled := True;
end;

procedure TDisplayContents.TimerStopsContentfulReadTimer(Sender: TObject);
begin
  FTimerStopsContentfulRead.Enabled := False;
  if Assigned(DisplayPromoContents) then
    DisplayPromoContents.ProcessingData := False;
end;

function TDisplayContents.TotalContents: Integer;
begin
  Result := FSourceContents.Count;
end;

function TDisplayContents.ValidateContent(aContent: TContentfulObj): Boolean;
var
  Major, Minor, Release, Build : Word;
  Index: Integer;
  CurrentMajorVersion, CurrentMinorVersion ,
  PrevMajorVersion, PrevMinorVersion: string;
begin
  Result := True;

  if Trim(UpgradeVersionTo) = '' then
  begin
    WinUtils.GetBuildInfo( Major, Minor, Release, Build);
    UpgradeVersionTo := IntToStr(Major) + '.' + IntToStr(Minor) + '.' + IntToStr(Release) + ' Build '+ IntToStr(Build);
  end;
  GetUpgradeVersions(UpgradeVersionTo,CurrentMajorVersion, CurrentMinorVersion);
  GetUpgradeVersions(UpgradeVersionFrom,PrevMajorVersion, PrevMinorVersion);

  // Validate versions
  if aContent.ContentType in [ctMarketing, ctTechnical] then
  begin
    if ((not aContent.ValidInVersions.Find('ANY', Index)) and
      (not aContent.ValidInVersions.Find(CurrentMajorVersion, Index)) and
      (not aContent.ValidInVersions.Find(CurrentMinorVersion, Index))) then
      Result := False;
  end
  else if aContent.ContentType = ctUpgrade then
  begin
    if PrevMinorVersion <> CurrentMinorVersion then
    begin
      if aContent.ValidInVersions.Find(PrevMinorVersion, Index) then
        Result := False;
    end;
    if (not aContent.ValidInVersions.Find(CurrentMinorVersion, Index)) then
      Result := False;
  end;

  if not Result then
    Exit;

  //Validate Users
  if Assigned(AdminSystem) then // practice
  begin
    //validate geography
    if (not (gANY in aContent.Geography)) then
    begin
      if (not(TCountryType(AdminSystem.fdFields.fdCountry) in aContent.Geography))  then
        Result := False;
    end;
    //validate user types
    if (( not (utPractice in aContent.ValidUsers))) then
    begin {Do the below check only if it's not Practice. Is user is Practice, all Practice users(admin, normal, restricted) can access that content}
      if (CurrUser.CanAccessAdmin and (not CurrUser.HasRestrictedAccess) and (not (utAdmin in aContent.ValidUsers))) then // Admin user
        Result := False
      else if ((not CurrUser.CanAccessAdmin) and (not CurrUser.HasRestrictedAccess) and (not (utNormal in aContent.ValidUsers))) then // Normal user
        Result := False
      else if ((not CurrUser.CanAccessAdmin) and (CurrUser.HasRestrictedAccess) and (not (utRestricted in aContent.ValidUsers))) then // Restricted user
        Result := False;
    end;
  end
  else if (not (utBooks in aContent.ValidUsers)) then // books
    Result := False;

  if not Result then
    Exit;

  if aContent.ContentType in [ctMarketing, ctTechnical] then
  begin
    if (aContent.ValidStartDate > 0) then
    begin
      if (Floor(FDateToValidate) < Floor(aContent.ValidStartDate)) then
        Result := False;
    end;
    if (aContent.ValidEndDate > 0) then
    begin
      if (Floor(FDateToValidate) > Floor(aContent.ValidEndDate)) then
        Result := False;
    end;
  end;
end;

{ TContentfulThread }


procedure TContentfulThread.Execute;
begin
  FreeOnTerminate := True;
  while not Terminated do
  begin
    //EnterCriticalSection(CritSect);
    if Assigned(DisplayPromoContents) then
    begin
      DisplayPromoContents.OwnerThread := self; // Set owning thread so that LogUtil can write to LogFile

      DisplayPromoContents.ClearList;
      DisplayPromoContents.LoadAllDisplayContents; // Load
    end;
    //LeaveCriticalSection(CritSect);
    Terminate;
  end;
end;

initialization
  //InitializeCriticalSection(CritSect);
  DisplayPromoContents := TDisplayContents.Create;
  DebugMe := DebugUnit(UnitName);

finalization
  //DeleteCriticalSection(CritSect);
  FreeAndNil(DisplayPromoContents);

end.
