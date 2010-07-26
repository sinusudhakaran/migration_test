{*******************************************************************}
{ TWEBPOST component                                                }
{ for Delphi & C++Builder                                           }
{ version 1.0                                                       }
{                                                                   }
{ written by                                                        }
{    TMS Software                                                   }
{     copyright © 2001 - 2005                                       }
{     Email : info@tmssoftware.com                                  }
{     Web   : http://www.tmssoftware.com                            }
{                                                                   }
{ The source code is given as is. The author is not responsible     }
{ for any possible damage done due to the use of this code.         }
{ The component can be freely used in any application. The source   }
{ code remains property of the writer and may not be distributed    }
{ freely as such.                                                   }
{*******************************************************************}

unit WebPost;

{$I TMSDEFS.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, WinInet;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 0; // Minor version nr.
  REL_VER = 1; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // v1.0.1.0 : improved handling of post through https


type

  TWebPostError = procedure(Sender:TObject;ErrorStr:string;ErrorCode:integer) of object;

  TWebPostItem = class(TCollectionItem)
  private
    fValue: string;
    fName: string;
  public
    constructor Create(Collection: TCollection); override;
  published
    property Name:string read fName write fName;
    property Value:string read fValue write fValue;
  end;

  TWebPostItems = class(TCollection)
  private
   fOwner:TComponent;
   function GetItem(Index: Integer): TWebPostItem;
   procedure SetItem(Index: Integer; Value: TWebPostItem);
  protected
   function GetOwner: tPersistent; override;
  public
   constructor Create(aOwner:TComponent);
   function Add:TWebPostItem;
   function Insert(index:integer): TWebPostItem;
   property Items[Index: Integer]: TWebPostItem read GetItem write SetItem;
  end;

  TWebPost = class(TComponent)
  private
    { Private declarations }
    FServer: string;
    FAction: string;
    FItems: TWebPostItems;
    FPostResult: string;
    FOnError: TWebPostError;
    FPort: Integer;
    FAgent: string;
    FTimeOut: integer;
    procedure SetItems(const Value: TWebPostItems);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetVersionNr: Integer;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    function Execute:boolean;
    procedure Error;
    procedure SaveToFile(fn:string);
    property PostResult:string read fPostResult;
  published
    { Published declarations }
    property Agent: string read FAgent write FAgent;
    property Port: Integer read FPort write FPort;
    property Server: string read FServer write FServer;
    property Action: string read FAction write FAction;
    property Items: TWebPostItems read fItems write SetItems;
    property TimeOut: integer read FTimeOut write FTimeOut default 0;
    property OnError: TWebPostError read fOnError write FOnError;
    property Version: string read GetVersion write SetVersion;
  end;

implementation

const
 READBUFFERSIZE = 4096;
 winetdll = 'WININET.DLL';


{ TWebPostItem }

constructor TWebPostItem.Create(Collection: TCollection);
begin
  inherited;
end;

{ TWebPostItems }

function TWebPostItems.Add: TWebPostItem;
begin
  Result := TWebPostItem(inherited Add);
end;

constructor TWebPostItems.Create(aOwner:TComponent);
begin
  inherited Create(TWebPostItem);
  FOwner := AOwner;
end;


function TWebPostItems.GetItem(Index: Integer): TWebPostItem;
begin
  Result := TWebPostItem(inherited GetItem(Index));
end;

function TWebPostItems.GetOwner: tPersistent;
begin
  Result := FOwner;
end;

function TWebPostItems.Insert(index: integer): TWebPostItem;
begin
  {$IFDEF DELPHI4_LVL}
  Result := TWebPostItem(inherited Insert(index));
  {$ELSE}
  Result := TWebPostItem(inherited Add);
  {$ENDIF}
end;

procedure TWebPostItems.SetItem(Index: Integer; Value: TWebPostItem);
begin
  inherited SetItem(Index, Value);
end;


{ TWebPost }

constructor TWebPost.Create(AOwner: TComponent);
begin
  inherited;
  FItems := TWebPostItems.Create(Self);
  FAgent := 'WebPost';
end;

destructor TWebPost.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TWebPost.Error;
var
  Errorcode:dword;
  dwIntError,dwLength:dword;
  buf:array[0..1024] of char;

begin
  ErrorCode := GetLastError;
  if (ErrorCode <> 0) then
  begin
    FormatMessage(FORMAT_MESSAGE_FROM_HMODULE,
     pointer(GetModuleHandle(winetdll)),ErrorCode,0,buf,sizeof(buf),nil);

    if (ErrorCode = ERROR_INTERNET_EXTENDED_ERROR) then
    begin
      InternetGetLastResponseInfo(dwIntError,nil,dwLength);
      if (dwLength>0) then
      begin
        InternetGetLastResponseInfo(dwIntError,buf,dwLength);

        if Assigned(fOnError) then
          FOnError(self,strpas(buf),ErrorCode)
        else
          Messagedlg(strpas(buf),mtError,[mbok],0);
      end
    end
    else
    begin
      if Assigned(fOnError) then
        FOnError(self,strpas(buf),ErrorCode)
      else
        Messagedlg(strpas(buf),mtError,[mbok],0);
     end;
   end;
end;


function TWebPost.Execute:boolean;
var
  hint,hconn,hreq:hinternet;
  hdr:string;
  buf:array[0..READBUFFERSIZE-1] of char;
  bufsize:dword;
  i,flags:integer;
  data,value:string;

begin
  Result := False;

  hdr := 'Content-Type: application/x-www-form-urlencoded';

  data := '';

  for i := 1 to fItems.Count do
  begin
    if data <> '' then
      data := data + '&';
    value := fItems.Items[i - 1].Value;
    while (pos(' ',value) > 0) do
      value[pos(' ',value)] := '+';
    data := data + FItems.Items[i - 1].Name + '=' + value;
  end;

  hint := InternetOpen(PChar(FAgent),INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);

  if FTimeout > 0 then
    InternetSetOption(hint, INTERNET_OPTION_CONNECT_TIMEOUT, @FTimeout, sizeof(FTimeout));

  if FPort = 0 then
    hconn := InternetConnect(hint,pchar(fServer),INTERNET_DEFAULT_HTTP_PORT,nil,nil,INTERNET_SERVICE_HTTP,0,1)
  else
    hconn := InternetConnect(hint,pchar(fServer),FPort,nil,nil,INTERNET_SERVICE_HTTP,0,1);

  if FPort = INTERNET_DEFAULT_HTTPS_PORT then
    flags := INTERNET_FLAG_SECURE or INTERNET_FLAG_IGNORE_CERT_CN_INVALID or INTERNET_FLAG_IGNORE_CERT_DATE_INVALID
  else
    flags := 0;

  hreq := HttpOpenRequest(hconn, 'POST', pchar(FAction), nil, nil, nil, flags, 1);

  FPostResult := '';

  if HttpSendRequest(hreq,pchar(hdr),length(hdr),pchar(Data),length(Data)) then
  begin
    bufsize := READBUFFERSIZE;
    Result := True;

    while (bufsize > 0) do
    begin
      Application.processmessages;
      if not InternetReadFile(hreq,@buf,READBUFFERSIZE,bufsize) then
      begin
        Result := False;
        break;
      end;
      if (bufsize > 0) and (bufsize <= READBUFFERSIZE) then
        for i := 0 to bufsize - 1 do
          FPostResult := FPostResult + buf[i];
    end;
  end
  else
  begin
    Error;
  end;

 InternetCloseHandle(hreq);
 InternetCloseHandle(hconn);
 InternetCloseHandle(hint);
end;

procedure TWebPost.SaveToFile(fn: string);
var
  tf:text;

begin
  Assignfile(tf,fn);
  {$i-}
  Rewrite(tf);
  {$i+}
  if IOResult = 0 then
  begin
    write(tf,fPostResult);
    closefile(tf);
  end
  else
    raise Exception.Create('Cannot create file');
end;

procedure TWebPost.SetItems(const Value: TWebPostItems);
begin
  FItems.Assign(Value);
end;

function TWebPost.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TWebPost.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TWebPost.SetVersion(const Value: string);
begin

end;

end.
