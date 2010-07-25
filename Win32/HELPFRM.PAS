unit HelpFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, help32,
  StdCtrls, ExtCtrls, ComCtrls, ToolWin;

type
  TfrmHelp = class(TForm)
    re1: TRichEdit;
    ToolBar1: TToolBar;
    tbtTopics: TToolButton;
    tbtPrint: TToolButton;
    Panel1: TPanel;
    Edit1: TEdit;
    tbtTest: TButton;
    Button1: TButton;
    Button2: TButton;
    procedure re1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tbtTestClick(Sender: TObject);
    procedure re1KeyPress(Sender: TObject; var Key: Char);
    procedure re1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    HelpOK   : boolean;
    Topic    : THelpTopic;
    HelpFile : THelpFile;
    point    : ppoint;

    procedure DisplayTopic(context : integer);
    procedure CheckForLink(ch : integer);
  public
    { Public declarations }
    procedure ShowHelp(HelpFileName: string; context: integer);
    procedure CreateParams(var params : TCreateParams); override;
    procedure ShowIndex;
  end;

var
  frmHelp: TfrmHelp;

implementation
{$R *.DFM}
uses
   Globals, WarningMoreFrm;

{--------------------------------------------------}
procedure TfrmHelp.CreateParams(var params : TCreateParams);
begin
   inherited CreateParams(params);
   params.Style := params.Style and not WS_POPUP;
   params.ExStyle := params.ExStyle and not WS_EX_TOOLWINDOW or WS_EX_APPWINDOW;
end;

procedure TfrmHelp.DisplayTopic(context : integer);
var
   i : integer;
begin
   re1.Clear;

   if HelpOK then
   begin
     Topic.Free;              {release a current helptopic object if allocated}
     Topic := HelpFile.GetTopic(context);

     if Assigned(Topic) then
     with re1 do
     begin
       SelAttributes := DefAttributes;
       Lines   := Topic.Lines;

       {highlight crossref}
       for i := 1 to Topic.numRefs do
       begin
         SelStart             := Topic.CrossRefOffset(i) ;
         SelLength            := Topic.CrossRefLen(i);
         SelAttributes.Style  := ([fsUnderline]);
         SelAttributes.Color  := clBlue;
       end;

       {reset attributes}
       SelStart := 0;
       SelAttributes := DefAttributes;
     end;
   end
   else
     HelpfulWarningMsg('Help File Unavailable',0);
end;

{--------------------------------------------------}
procedure TfrmHelp.ShowHelp(HelpFileName: string; context: integer);
begin
   if not Assigned(HelpFile) then
      HelpFile := THelpFile.Create(ExecDir+HelpFileName);
   HelpOK := HelpFile.HelpFileOK;

   if HelpOK then
   begin
      DisplayTopic(context);
      Show;
   end
   else
      Close;
end;

{--------------------------------------------------}
procedure TfrmHelp.re1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
{handles the hyperlink detection}
var
  Ch : integer;

begin
   {store current pos}
   point^.x := x;
   point^.y := y;
   ch := SendMessage(re1.Handle,EM_CHARFROMPOS,0,longint(point));  //works for win95 and nt4

   {see if this is a hyperlink}
   if HelpOK then
      CheckForLink(ch);
end;

{--------------------------------------------------}
procedure TfrmHelp.FormCreate(Sender: TObject);
begin
   HelpOK   := false;
   HelpFile := nil;
   Topic    := nil;
   New(Point);
end;

{--------------------------------------------------}
procedure TfrmHelp.FormClose(Sender: TObject; var Action: TCloseAction);
{dispose objects and pointers, note: must be set to nil because destroy will
 check they have been freed}
begin
   Topic.Free;
   Topic := nil;
   HelpFile.Free;
   HelpFile := nil;
end;

{--------------------------------------------------}
procedure TfrmHelp.FormDestroy(Sender: TObject);
begin
   if Assigned(Point) then Dispose(Point);

   Topic.Free;
   HelpFile.Free;
end;

{--------------------------------------------------}
procedure TfrmHelp.FormShow(Sender: TObject);
begin
   top := 0;
   left := Screen.width - width;
end;

{--------------------------------------------------}
{            key handling                          }
{--------------------------------------------------}
procedure TfrmHelp.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = 27 then close;
end;

{--------------------------------------------------}
procedure TfrmHelp.tbtTestClick(Sender: TObject);
var
   i,err : integer;
begin
     val(edit1.text,i,err);
     DisplayTopic(i);
end;

{--------------------------------------------------}
procedure TfrmHelp.re1KeyPress(Sender: TObject; var Key: Char);
begin
   if not (key in [#33..#40]) then key := #0;
end;

{--------------------------------------------------}
procedure TfrmHelp.re1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 86) or (key=88) or (key=46) or (key=8) then key := 0;
end;

{--------------------------------------------------}
procedure TfrmHelp.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
  begin
    {see if we are on a hyperlink}
    CheckForLink(re1.SelStart);
    key := #0;
  end;
end;

{--------------------------------------------------}
{--------------------------------------------------}
procedure TfrmHelp.Button1Click(Sender: TObject);
begin

end;


{--------------------------------------------------}
procedure TfrmHelp.ShowIndex;
begin
//   HelpFile.TopicList;
end;

procedure TfrmHelp.Button2Click(Sender: TObject);
begin
   HelpFile.TopicList;
   re1.clear;
   re1.lines := HelpFile.Topics;
end;

procedure TfrmHelp.CheckForLink(ch:integer);
var
  Start, Stop, i : integer;
begin
  if HelpOK then
    if ch > 0  then
      for i := 1 to Topic.numRefs do
      begin
         start := Topic.CrossRefOffset(i);
         stop  := Topic.CrossRefOffset(i)+Topic.CrossRefLen(i);
         if (ch>= start) and (ch<= stop)  then
         begin
            DisplayTopic(Topic.CrossRefContext(i));
            exit;
         end;
      end;    // for
end;

end.
