unit CheckWebnotesData;
//------------------------------------------------------------------------------
{
   Title: CheckWebnotesData

   Description:

   Author: Andre' Joosten

   Remarks:

   The design allows for a polling strategy.
   Currently it is only impemented as a once only check when a client file is opened
   (Or at least the home page is updated)

   The update thread gets the XML response and saves it locally for all instances.
   Each instance can compare thier 'serialnumber' with the current one and update as required

   Eventhough we are not polling, it still means we controll how often we call the service.
   I.e. the instances will just use the current saved version,
   and only if that version is to 'old' will it call the service.
   If the service is called, the status is updated Asynchronusly

}
//------------------------------------------------------------------------------
interface

uses
  messages;


procedure CheckAvailableWebnotesData;
// This starts the Tread that will check if there is data available.
// It will post a WEBNOTES_MESSAGE to the registered windows if it has.

function IsWebNotesUpdateWaiting: Boolean;
function WebNotesUpdateText: string;
// Just checks against the Local file.
// Can be called at anny time
// more interestingly called in response to  WEBNOTES_MESSAGE


procedure RegisterWebNotesUpdate(Value: THandle);
procedure UnRegisterWebNotesUpdate(Value: THandle);
// Register/unRegister to recieve WEBNOTES_MESSAGE


procedure UploadedToWebnotes;
// we keep a local flag to say atleast one successfull upload has passed.
// there is no point to expect data if this nevver occured

const
  WEBNOTES_MESSAGE = WM_USER + 389;

//------------------------------------------------------------------------------
implementation

uses
  bkDateUtils,
  bkConst,
  stDate,
  Math,
  WinUtils,
  ActiveX,
  XMLDoc,
  XMLIntf,
  LogUtil,
  LockUtils,
  WebNotesClient,
  Classes,
  IniFiles,
  Windows,
  INIsettings,
  Globals,
  WebNotesSchema,
  WebUtils,
  SysUtils;

const
  IniSection = 'WebNotes';
  LastKey = 'LastCheckTime';
  NextKey = 'NextCheckTime';
  VersionKey = 'UpdateNumber';
  UploadSuccess = 'Uploaded';

  // Minimum and Maximum time to wait before calling the webservice
  MinWait = 30 / secsPerDay;  // 30 seconds
  MaxWait = 60.0 / MinsPerDay; // 60 minutes

  FailWait = 30 * 60; //In seconds... 30 min (server down, appserver down)

  UnitName = 'CheckWebnotesData';

  SecsTowaitForLock = 20;

type
  //----------------------------------------------------------------------------
  WebNotesCheckThread = class(TThread)
  private
    FClient: TWebNotesClient;
    FHaveLocks: array [ltWebNotesupdate..ltWebNotesdata] of boolean;
    FLock: Integer;
    FWaitSeconds: Integer;
    //procedure MyTerminate(Sender: TObject);
    function CheckDue: Boolean;
    procedure SetSuccessTime;
    procedure GetLock; overload;
    function GetLock(Lock: Integer):boolean; overload;
    procedure ReleaseLock; overload;
    function ReleaseLock(Lock: Integer): boolean; overload;
    procedure GetData;
    procedure NewSerialNumber;
    function GetSerialNumber: Integer;
    procedure MyTerminate(Sender: TObject);
    procedure UpdateData;
    procedure SetWaitSeconds(const Value: Integer);
    property WaitSeconds: Integer read FWaitSeconds write SetWaitSeconds;
  protected
    procedure Execute; override;
  public
    constructor Create;
    procedure Interupt;
  end;

var
  DebugMe: boolean = False;

  // This is used to check If I am already trying locally
  MyThread: WebNotesCheckThread = nil;

  // If an other instance updated the file, I would still like to know;
  MyVersionNumber: Integer = 0;

(***********************   Update List  ***************************************)

// Local Thread save list to keep track of wich window needs do know
// when webnotes when data is avialble.

  fUpdateList: TThreadlist;

//------------------------------------------------------------------------------
function UpdateList: TThreadlist;
begin
  if fUpdateList = nil then
  begin
    fUpdateList := TThreadlist.Create;
    fUpdateList.Duplicates := dupIgnore;// Won't add duplicates, but won't fail if we try...
  end;

  result := fUpdateList;
end;

//------------------------------------------------------------------------------
procedure RegisterWebNotesUpdate(Value: THandle);
begin
   // Is a Threadsave add..
   UpdateList.Add(Pointer(Value));
end;

//------------------------------------------------------------------------------
procedure UnRegisterWebNotesUpdate(Value: THandle);
begin
    // Is a Threadsave remove..
    UpdateList.Remove(Pointer(Value));
end;

(******************  CheckAvailableWebnotesData  ******************************)

// Starts Check thread if required
//------------------------------------------------------------------------------
procedure CheckAvailableWebnotesData;
var
  PracIniFile: TIniFile;
begin
  // We Just Use BK5Win.ini to see if we should
  if not Assigned (Globals.CurrUser) then
    Exit; // Not even logged in yet...

  PracIniFile := TIniFile.Create(ExecDir + PRACTICEINIFILENAME);
  try
    if not PracIniFile.ReadBool(IniSection,UploadSuccess,False) then
      Exit; // Never uploaded..
  finally
    PracIniFile.Free;
  end;


  if Assigned(MyThread) then
    Exit; //Already trying locally

  // Have a Go..
  MyThread := WebNotesCheckThread.Create;
end;

(*******************    UploadedToWebnotes      *******************************)

// Is called when tere is a succsefull upload to web notes.
// If this never occurs, there is no point in testing for available data..
//------------------------------------------------------------------------------
procedure UploadedToWebnotes;
var
  PracIniFile: TIniFile;
begin
  PracIniFile := TIniFile.Create(ExecDir + PRACTICEINIFILENAME);
  try
    PracIniFile.WriteBool(IniSection,UploadSuccess,True);
    PracIniFile.UpdateFile;
  finally
    PracIniFile.Free;
  end;
end;

{ WebNotesDataTest }
//------------------------------------------------------------------------------
function WebNotesCheckThread.CheckDue: Boolean;
var
  PracIniFile: TMemIniFile;
  RTime,
  LNow: tDateTime;
begin
  Result := true; // Should Run

  PracIniFile := TMemIniFile.Create(ExecDir + PRACTICEINIFILENAME);
  try
    lNow := Now;
    RTime := PracIniFile.ReadDateTime(IniSection,LastKey, 0);
    if RTime = 0 then begin
      if DebugMe then
        LogUtil.LogMsg(lmDebug,UnitName,'First time run' );
      Exit; // Never Run...
    end;

    if lNow > (RTime + MaxWait) then
    begin
      if DebugMe then
        LogUtil.LogMsg(lmDebug,UnitName,'Max time run' );
      Exit; // Should run
    end;

    if lNow > (RTime  + MinWait) then
    begin
      RTime := PracIniFile.ReadDateTime(IniSection,NextKey, 0);
      if LNow > RTime then
      begin
        if DebugMe then
          LogUtil.LogMsg(lmDebug,UnitName,'Ok to run on time ' );
        Exit;
      end;
    end;

    if DebugMe then
       LogUtil.LogMsg(lmDebug,UnitName,'Don''t Run' );

    Result := false;//Dont Run..
  finally
    FreeAndNil(PracIniFile);
  end;
end;

//------------------------------------------------------------------------------
procedure WebNotesCheckThread.GetData;
var
  Reply: string;
  NewXMLDoc: IXMLDocument;
  ReplyNode,
  TimeNode: IXMLNode;
  lt: Integer;

  //----------------------------------------------
  function NewFile: Boolean;
  var  OldXMLDoc: IXMLDocument;
  begin
    Result := true;
    if not BkFileExists(Datadir + WEBNOTESUPDATE_Data) then
      Exit; // Must be new...

    OldXMLDoc := XMLDoc.NewXMLDocument;
    try
      OldXMLDoc.Active := true;
      try
        OldXMLDoc.LoadFromFile(Datadir + WEBNOTESUPDATE_Data);
      except
        Exit; // Not a valid file...
      end;
      // Could probleby make a faster but more elaboate test..
      Result := not SameText(NewXMLDoc.XML.Text, OldXMLDoc.XML.Text);
    finally
      OldXMLDoc := nil;
    end;
  end;

begin
  try
    if FClient.GetAvailableData ('',Reply) then
    begin

      if DebugMe then
        LogUtil.LogMsg(lmDebug,UnitName,format( 'Reply <%s>',[Reply]) );

      // test the Reply..
      NewXMLDoc := nil;

      if GetLock(ltWebNotesdata) then
        try
          CoInitialize(nil);

          NewXMlDoc := MakeXMLDoc(Reply);

          ReplyNode := NewXMLDoc.DocumentElement;
          if not SameText(ReplyNode.NodeName, nAvailableDataResponse) then
            Exit; // Wrong Reply Type..

          TimeNode := ReplyNode.ChildNodes.FindNode('WaitSeconds');
          if Assigned(TimeNode) then
          begin
            lt := TimeNode.NodeValue;
            WaitSeconds := lt;
          end;

          ReplyNode := ReplyNode.ChildNodes.FindNode(nSuccess);
          if not Assigned(ReplyNode) then
          begin
            WaitSeconds := Failwait;
            Exit; // Call Failed..
          end;

          if not (ReplyNode.NodeValue = nTrue) then
          begin
            WaitSeconds := Failwait;
            Exit; // Appserver failed?
          end;

          // The NewDoc should be OK..
          // Now check if it has changed
          if NewFile then
          begin
            NewSerialNumber; // Let other instances know
            NewXMLDoc.SaveToFile(Datadir + WEBNOTESUPDATE_Data);
          end;

        finally
          ReleaseLock(ltWebNotesdata);
          NewXMLDoc := nil;
          CoUnInitialize;
        end;

    end;
  except
     // Not a lot we can do...
  end;
end;

//------------------------------------------------------------------------------
function WebNotesCheckThread.GetLock(Lock: Integer): Boolean;
begin
  FLock := Lock;
  Synchronize(GetLock);
  Result := fHaveLocks[FLock];
end;

//------------------------------------------------------------------------------
function WebNotesCheckThread.GetSerialNumber: Integer;
var
  PracIniFile : TIniFile;
begin
  PracIniFile := TIniFile.Create(ExecDir + PRACTICEINIFILENAME);
  try
    Result := PracIniFile.ReadInteger(IniSection, VersionKey, 0);
  finally
    FreeAndNil(PracIniFile);
  end;
end;

//------------------------------------------------------------------------------
procedure WebNotesCheckThread.GetLock;
begin
  if FHaveLocks[FLock] then
    Exit;

  if LockUtils.ObtainLock(FLock, SecsTowaitForLock ) then
    FHaveLocks[FLock] := true;
end;

//------------------------------------------------------------------------------
procedure WebNotesCheckThread.Interupt;
begin
  if assigned(FClient) then
    FClient.Interupt;
end;

//------------------------------------------------------------------------------
procedure WebNotesCheckThread.MyTerminate(Sender: TObject);
begin
  FClient.Free;

  Mythread := nil;
end;

//------------------------------------------------------------------------------
procedure WebNotesCheckThread.NewSerialNumber;
var
  PracIniFile : TIniFile;
  lNumber : Integer;
begin
  PracIniFile := TIniFile.Create(ExecDir + PRACTICEINIFILENAME);
  try
    LNumber := PracIniFile.ReadInteger(IniSection, VersionKey, 0);
    if LNumber < Pred(MaxInt) then
      inc(LNumber)
    else
      LNumber := 1;
    PracIniFile.WriteInteger(IniSection,VersionKey, LNumber);
    PracIniFile.UpdateFile; // Does a flush
  finally
    FreeAndNil(PracIniFile);
  end;
end;

//------------------------------------------------------------------------------
function WebNotesCheckThread.ReleaseLock(Lock: Integer): boolean;
begin
  flock := Lock;
  Synchronize(ReleaseLock);
  Result := FHavelocks[flock];
end;

//------------------------------------------------------------------------------
procedure WebNotesCheckThread.ReleaseLock;
begin
  if FhaveLocks[FLock] then
  begin
    LockUtils.ReleaseLock(FLock);
    FHavelocks[FLock] := False;
  end;
end;

//------------------------------------------------------------------------------
procedure WebNotesCheckThread.UpdateData;
var
  I: Integer;
begin
  with UpdateList.LockList do
    try
      for I := 0 to  pred(count) do
        if Iswindow(tHandle(items[I])) then
          PostMessage( tHandle(items[I]),WEBNOTES_MESSAGE,0,0);
    finally
      UpdateList.UnLockList;
    end;
end;

//------------------------------------------------------------------------------
procedure WebNotesCheckThread.SetSuccessTime;
var
  PracIniFile : TIniFile;
  lNow: tDateTime;
begin
  PracIniFile := TIniFile.Create(ExecDir + PRACTICEINIFILENAME);
  try
    lNow := Now;
    PracIniFile.WriteDateTime(IniSection,LastKey, lNow);
    if FWaitSeconds > 0 then begin
       lNow := lNow + FWaitseconds / SecsPerDay;
       PracIniFile.WriteDateTime(IniSection, NextKey, lNow);
    end;
    PracIniFile.UpdateFile; // Does a flush
  finally
    FreeAndNil(PracIniFile);
  end;
end;

//------------------------------------------------------------------------------
procedure WebNotesCheckThread.SetWaitSeconds(const Value: Integer);
begin
  FWaitSeconds := max(FWaitSeconds, Value);
end;

{ WebNotesCheckThread }
//------------------------------------------------------------------------------
constructor WebNotesCheckThread.Create;
begin
  inherited Create(true);
  // Do some setup first
  FreeOnTerminate := true;
  self.OnTerminate := MyTerminate;
  // Everything set up. just have a go...
  FClient := TWebNotesClient.Create(GetBK5Ini);

  FClient.Country := CountryText(AdminSystem.fdFields.fdCountry);
  FClient.PracticeCode := AdminSystem.fdFields.fdBankLink_Code;
  FClient.PassWord := AdminSystem.fdFields.fdBankLink_Connect_Password;

  FWaitSeconds := 0;
  //Have a Go
  Self.Suspended := False;
end;

//------------------------------------------------------------------------------
procedure WebNotesCheckThread.Execute;
var
  lNumber: integer;
begin
  if CheckDue then
  begin
    if GetLock(ltWebNotesupdate) then try
      Getdata;
    finally
      ReleaseLock(ltWebNotesupdate);
    end;
    SetSuccessTime;
  end;

  lNumber := GetSerialNumber;
  if LNumber <> MyVersionNumber then
  begin
    UpdateData;
    MyVersionNumber := lNumber;
  end;
end;

//------------------------------------------------------------------------------
function IsWebNotesUpdateWaiting: Boolean;
var
  lXmlDoc: IXMLDocument;
  ReplyNode,
  lNode: IXMLNode;
  I: Integer;

  //---------------------------------------------
  function TestClientNode(Node: IXMLNode): Boolean;
  begin
    Result := SameText(GetStringAttr(Node,ncompanycode),MyClient.clFields.clCode)
           and (GetIntAttr(Node,nCount) > 0); //One is enough
  end;

begin
  Result := false;

  if not Assigned (MyClient) then
    Exit; // savety net...

  if not BkFileExists(Datadir + WEBNOTESUPDATE_Data) then
    Exit; // No show..

  lXMLDoc := XMLDoc.NewXMLDocument;
  try
    try
      lXmlDoc.Active := true;
      if LockUtils.ObtainLock(ltWebNotesdata, SecsTowaitForLock ) then
        try
          lXMLDoc.LoadFromFile(Datadir + WEBNOTESUPDATE_Data);
        finally
          LockUtils.ReleaseLock(ltWebNotesdata);
        end
      else
         Exit;

      // The folowing test should not have to happen here,
      // because it should have been checked before saving
      // Just in case someone played...

      ReplyNode := lXMLDoc.DocumentElement;
      if not TestResponse(ReplyNode, nAvailableDataResponse) then
        Exit;

      lNode := ReplyNode.ChildNodes.FindNode(nItems);
      if not Assigned(lNode) then
        Exit; // Nothing available

      // Now go through the list...
      for I := 0 to lNode.ChildNodes.Count - 1 do
        if TestClientNode(lNode.ChildNodes[I]) then
        begin
          Result := True;
          Exit;
        end;

    except
      // What ...
    end;
  finally
    lXMLDoc := nil;
    ReplyNode := nil;
    lNode := nil;
  end;
end;

//------------------------------------------------------------------------------
function WebNotesUpdateText: string;
var
  lXmlDoc: IXMLDocument;
  ReplyNode,
  lNode: IXMLNode;
  I: Integer;
  FirstDate,
  LastDate: tstDate;
  Count: integer;

  //-------------------------------------------------
  procedure TestClientNode(Node: IXMLNode);
  begin
    if SameText(GetStringAttr(Node,ncompanycode),MyClient.clFields.clCode) and
      (GetIntAttr(Node,nCount) > 0) then
    begin
      FirstDate := min(FirstDate, GetDateAttr(Node,nFromdate));
      LastDate := max(LastDate, GetDateAttr(Node,nToDate));
      inc(Count,GetIntAttr(Node,nCount));
    end;
  end;

begin
  Result := '';

  if not Assigned (MyClient) then
    Exit; // savety net...

  if not BkFileExists(Datadir + WEBNOTESUPDATE_Data) then
    Exit; // No show..

  lXMLDoc := XMLDoc.NewXMLDocument;
  try
    try
      lXmlDoc.Active := true;
      if LockUtils.ObtainLock(ltWebNotesdata, SecsTowaitForLock ) then
        try
          lXMLDoc.LoadFromFile(Datadir + WEBNOTESUPDATE_Data);
        finally
          LockUtils.ReleaseLock(ltWebNotesdata);
        end
      else
        Exit;

      // The folowing test should not have to happen here,
      // because it should have been checked before saving
      // Just in case someone played...

      ReplyNode := lXMLDoc.DocumentElement;
      if not TestResponse(ReplyNode, nAvailableDataResponse) then
        Exit;

      lNode := ReplyNode.ChildNodes.FindNode(nItems);
      if not Assigned(lNode) then
        Exit; // Nothing available

      // Now go through the list...
      FirstDate := MaxInt;
      LastDate := 0;
      Count := 0;
      for I := 0 to lNode.ChildNodes.Count - 1 do
        TestClientNode(lNode.ChildNodes[I]);

      if Count > 0 then
      begin
        Result := format('%s transactions available from %s until %s',
                         [WebnotesName,
                         bkdate2str(FirstDate),
                         bkdate2str(LastDate)]);
      end;
    except
      // What ...
    end;
  finally
    lXMLDoc := nil;
    ReplyNode := nil;
    lNode := nil;
  end;
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UnitName);
  MyThread := nil;
  fUpdateList := nil;

//------------------------------------------------------------------------------
finalization
  if Assigned(MyThread) then
    try
      MyThread.Interupt;
      Mythread.WaitFor;
    except
      // can fail when connected but does not get a reply
    end;

  if Assigned(fUpdateList) then
    FreeAndNil(fUpdateList);

end.
