unit WPXMLEditor;
{ -----------------------------------------------------------------------------
  WPXMLEditor      - Copyright (C) 2005 by wpcubed GmbH -  all rigths reserved!
  Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  You may use this unit if you are a registered user of WPTools 4 or WPForm 2
  Both products use this uint for loading/saving XML data and for localization
  -----------------------------------------------------------------------------
  Distribution of the "WPXMLint" unit in object and source form is not allowed
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WPXMLint, StdCtrls, ComCtrls, ExtCtrls, Menus, Grids;

type
  TWPXMLPropertyEditor = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Load1: TMenuItem;
    Save1: TMenuItem;
    N1: TMenuItem;
    Close1: TMenuItem;
    StatusBar1: TStatusBar;
    TreeView1: TTreeView;
    Splitter1: TSplitter;
    WPXMLTree1: TWPXMLTree;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Merge1: TMenuItem;
    DeleteBranch1: TMenuItem;
    MoveBranch1: TMenuItem;
    SaveBranch1: TMenuItem;
    RenameBranch1: TMenuItem;
    CopyBranch1: TMenuItem;
    N3: TMenuItem;
    CurrentBranch: TMenuItem;
    N2: TMenuItem;
    FindTextinbranch1: TMenuItem;
    FindNext1: TMenuItem;
    ShowAsString1: TMenuItem;
    Create1: TMenuItem;
    OK: TMenuItem;
    Cancel: TMenuItem;
    CreateParaminallelements1: TMenuItem;
    CreateCopy1: TMenuItem;
    N5: TMenuItem;
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    StringGrid1: TStringGrid;
    Memo1: TMemo;
    CommentPanel: TPanel;
    CommentLabel: TLabel;
    TabSheet2: TTabSheet;
    Memo2: TMemo;
    DisplayCurrent: TPanel;
    procedure Load1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
    procedure TabSheet1Resize(Sender: TObject);
    procedure TreeView1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Close1Click(Sender: TObject);
    procedure StringGrid1KeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Merge1Click(Sender: TObject);
    procedure TreeView1Editing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure PageControl1Changing(Sender: TObject;
      var AllowChange: Boolean);
    procedure WPXMLTree1Loaded(Sender: TObject);
    procedure DeleteBranch1Click(Sender: TObject);
    procedure MoveBranch1Click(Sender: TObject);
    procedure SaveBranch1Click(Sender: TObject);
    procedure RenameBranch1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CopyBranch1Click(Sender: TObject);
    procedure FindTextinbranch1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FindNext1Click(Sender: TObject);
    procedure ShowAsString1Click(Sender: TObject);
    procedure Create1Click(Sender: TObject);
    procedure OKClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure CreateParaminallelements1Click(Sender: TObject);
    procedure CreateCopy1Click(Sender: TObject);
  private
    FLastSelected: TTreeNode;
    FModified: Boolean;
    FSaved: Boolean;
    FindList: TList;
    FindNextPos: Integer;
    FOk : Boolean;
    procedure SetLastSelected(x: TTreeNode);
  public
    Source: TWPCustomXMLInterface;
    AskSave: Boolean;
    property Saved: Boolean read FSaved;
    property LastSelected: TTreeNode read FLastSelected write SetLastSelected;
    property Apply : Boolean read FOk write FOk;
    procedure UpdateTreeview;
    procedure Execute(SourceXML : TWPCustomXMLInterface);

  end;

implementation

{$R *.DFM}

procedure TWPXMLPropertyEditor.Execute(SourceXML : TWPCustomXMLInterface);
begin
      Source := SourceXML;
      Caption := 'XML-Data in ' + SourceXML.Name;
      if SourceXML is TWPCustomXMLTree then
      WPXMLTree1.DontAllowMultTagsOnFirstLevel :=
             TWPCustomXMLTree(SourceXML).DontAllowMultTagsOnFirstLevel;
      WPXMLTree1.XMLData.Assign(SourceXML.XMLData);
      AskSave := TRUE;
      ShowModal;
end;

procedure TWPXMLPropertyEditor.Load1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    PageControl1.ActivePage := TabSheet1;
    LastSelected := nil;
    WPXMLTree1.LoadFromFile(OpenDialog1.FileName);
    SaveDialog1.FileName := OpenDialog1.FileName;
    FModified := FALSE;
  end;
end;

procedure TWPXMLPropertyEditor.Merge1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    PageControl1.ActivePage := TabSheet1;
    LastSelected := nil;
    WPXMLTree1.AppendFromFile(OpenDialog1.FileName);
    FModified := TRUE;
  end;
end;

procedure TWPXMLPropertyEditor.Save1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    WPXMLTree1.WriteIndented := TRUE;
    PageControl1.ActivePage := TabSheet1;
    LastSelected := nil;
    WPXMLTree1.SaveToFile(SaveDialog1.FileName);
    FModified := FALSE;
  end;
end;

procedure TWPXMLPropertyEditor.Close1Click(Sender: TObject);
begin
  PageControl1.ActivePage := TabSheet1;
  Close;
end;

procedure TWPXMLPropertyEditor.OKClick(Sender: TObject);
begin
  PageControl1.ActivePage := TabSheet1;
  if FModified and ( Source <> nil) then
  begin
     LastSelected := nil;
     Source.XMLData.Assign(WPXMLTree1.XMLData);
     FSaved := TRUE;
     Source := nil;
     FModified := FALSE;  AskSave := FALSE;
  end;
  FOk := TRUE;
  Close;
end;

procedure TWPXMLPropertyEditor.CancelClick(Sender: TObject);
begin
  PageControl1.ActivePage := TabSheet1;
  FModified := FALSE;
  FOk := FALSE;
  Close;
end;


procedure TWPXMLPropertyEditor.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  i: Integer;
begin
  PageControl1.ActivePage := TabSheet1;
  if Source <> nil then // Property Editor Mode
  begin
    if MessageDlg('Save XML Data', mtConfirmation, [mbYes, mbNo], 0) = IDYES then
    begin
      LastSelected := nil;
      Source.XMLData.Assign(WPXMLTree1.XMLData);
      FSaved := TRUE;
    end
    else FSaved := FALSE;
  end
  else if FModified and AskSave then // File Editor Mode
  begin
    i := MessageDlg('Save XML Data', mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if i = IDCANCEL then CanClose := FALSE
    else if i = IDYES then
    begin
      if Save1.Visible then Save1Click(nil);
      CanClose := not FModified;
      FOk := TRUE;
    end;
  end;
end;

procedure TWPXMLPropertyEditor.TreeView1Click(Sender: TObject);
begin
  LastSelected := TreeView1.Selected;
end;

procedure TWPXMLPropertyEditor.TabSheet1Resize(Sender: TObject);
begin
  StringGrid1.ColWidths[1] := StringGrid1.Width - 2 - StringGrid1.ColWidths[0];
end;

procedure TWPXMLPropertyEditor.TreeView1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  LastSelected := TreeView1.Selected;
end;

procedure TWPXMLPropertyEditor.StringGrid1KeyPress(Sender: TObject; var Key: Char);
begin
  FModified := TRUE;
end;

procedure TWPXMLPropertyEditor.TreeView1Editing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);
begin
  AllowEdit := FALSE;
end;

procedure TWPXMLPropertyEditor.WPXMLTree1Loaded(Sender: TObject);
begin
  UpdateTreeview;
  if FindList <> nil then FindList.Clear;
  FindNext1.Enabled := FALSE;
end;

{ --------------------------------------------------------------------------- }

procedure TWPXMLPropertyEditor.UpdateTreeview;
  procedure AddToTree(Node: TTreeNode; Item: TWPXMLOneLevel);
  var
    NewNode: TTreeNode;
    i: Integer;
  begin
    if Item <> nil then
    begin
      if Item.Name = '' then NewNode := Node
      else NewNode := TreeView1.Items.AddChild(Node, Item.Name);
      if NewNode <> nil then
      begin
        NewNode.Data := Item;
        Item.Obj := NewNode;
      end;
      for i := 0 to Item.Count - 1 do
        AddToTree(NewNode, Item.Elements[i]);
    end;
  end;
begin
  TreeView1.Selected := nil;
  TreeView1.Items.BeginUpdate;
  TreeView1.Items.Clear;
  try
    AddToTree(nil, WPXMLTree1.Tree);
  finally
    TreeView1.Items.EndUpdate;
    if TreeView1.Items.Count > 0 then
    begin
      TreeView1.Selected := TreeView1.Items[0];
      TreeView1Click(nil);
    end;
  end;
end;

procedure TWPXMLPropertyEditor.SetLastSelected(x: TTreeNode);
var
  i: Integer;
  vis: Boolean;
  s : string;
begin
  vis := FALSE;
  if x <> FLastSelected then
  begin
    if (FLastSelected <> nil) and (FLastSelected.Data <> nil) then
    begin
      if StringGrid1.Visible then
        for i := 0 to StringGrid1.RowCount - 1 do
          TWPXMLOneLevel(FLastSelected.Data).ParamValue[StringGrid1.Cells[0, i]] :=
            StringGrid1.Cells[1, i];
      TWPXMLOneLevel(FLastSelected.Data).Content := Memo1.Text;
    end else CommentPanel.Visible := FALSE;
    FLastSelected := x;
    if (FLastSelected = nil) or (FLastSelected.Data = nil) then
      StringGrid1.RowCount := 0
    else
    begin
      // Show Comment
      CommentPanel.Visible := TWPXMLOneLevel(FLastSelected.Data).Comment<>'';
      CommentLabel.Caption := {'<!-- ' +} TWPXMLOneLevel(FLastSelected.Data).Comment {+ ' -->'};

      StringGrid1.RowCount := TWPXMLOneLevel(FLastSelected.Data).ParamCount;
      vis := TWPXMLOneLevel(FLastSelected.Data).ParamCount > 0;
      for i := 0 to TWPXMLOneLevel(FLastSelected.Data).ParamCount - 1 do
      begin
        StringGrid1.Cells[0, i] := TWPXMLOneLevel(FLastSelected.Data).Params.Names[i];
        StringGrid1.Cells[1, i] := TWPXMLOneLevel(FLastSelected.Data).ParamValue[StringGrid1.Cells[0, i]];
      end;
      Memo1.Text := TWPXMLOneLevel(FLastSelected.Data).Content;
      Memo1.Visible := true;
    end;
    StringGrid1.Visible := vis;
  end;
  if FLastSelected = nil then CurrentBranch.Visible := FALSE
  else
  begin
    CurrentBranch.Caption := '&Branch';
    CurrentBranch.Visible := TRUE;
    DisplayCurrent.Visible := TRUE;
    s := TWPXMLOneLevel(FLastSelected.Data).Path;
    if Length(s)>30 then s := '...' + Copy(s, Length(s)-30,30) + FLastSelected.Text
    else s :=  s + FLastSelected.Text;
    DisplayCurrent.Caption := s;

  end;
end;



procedure TWPXMLPropertyEditor.PageControl1Changing(Sender: TObject;
  var AllowChange: Boolean);
begin
  try
    LastSelected := nil;
    if PageControl1.ActivePage = TabSheet1 then
    begin
      Memo2.Text := WPXMLTree1.AsString;
      TreeView1.Enabled := FALSE;
      TreeView1.Items.Clear;
    end
    else
    begin
      WPXMLTree1.AsString := Memo2.Text;
      TreeView1.Enabled := TRUE;
    end;
    AllowChange := TRUE;
  except
    AllowChange := FALSE;
    ShowMessage('A problem occured when we tried to save this text');
  end;
end;

procedure TWPXMLPropertyEditor.DeleteBranch1Click(Sender: TObject);
var
  s: string;
  n: TWPXMLOneLevel;
begin
  if (FLastSelected <> nil) and (FLastSelected.Data <> nil) then
    s := TWPXMLOneLevel(FLastSelected.Data).Path
      + TWPXMLOneLevel(FLastSelected.Data).Name
  else s := '/';
  LastSelected := nil;
  if InputQuery('Delete XML Branch', 'Path', s) then
  begin
    n := WPXMLTree1.Find(s);
    if n <> nil then
    begin
      n.Free;
      UpdateTreeview;
      FModified := TRUE;
    end else ShowMessage('Cannot find path' + s);
  end;
end;

procedure TWPXMLPropertyEditor.MoveBranch1Click(Sender: TObject);
var
  s: string;
begin
  if (FLastSelected <> nil) and (FLastSelected.Data <> nil) then
  begin
    s := TWPXMLOneLevel(FLastSelected.Data).Path + '/' +
      TWPXMLOneLevel(FLastSelected.Data).Name;
    if InputQuery('Move XML Branch "' + s + '"', 'Destination', s) then
    try
      TWPXMLOneLevel(FLastSelected.Data).Path := s;
      FModified := TRUE;
    finally
      UpdateTreeview
    end;
  end;
end;

procedure TWPXMLPropertyEditor.SaveBranch1Click(Sender: TObject);
var
  p: TWPXMLOneLevel;
  s: string;
begin
  if (FLastSelected <> nil) and (FLastSelected.Data <> nil) then
  begin
    s := TWPXMLOneLevel(FLastSelected.Data).Path +
      TWPXMLOneLevel(FLastSelected.Data).Name;
    if InputQuery('Save XML Branch', 'Path', s) then
    begin
      p := WPXMLTree1.Find(s);
      if (p <> nil) and SaveDialog1.Execute then
      begin
        p.SaveToFile(SaveDialog1.FileName, true);
      end;
    end;
  end;
end;

procedure TWPXMLPropertyEditor.RenameBranch1Click(Sender: TObject);
var
  s: string;
begin
  if (FLastSelected <> nil) and (FLastSelected.Data <> nil) then
  begin
    s := TWPXMLOneLevel(FLastSelected.Data).Name;
    if InputQuery('Rename XML Branch', 'Name', s) and (s <> '') then
    begin
      TWPXMLOneLevel(FLastSelected.Data).Name := s;
      FLastSelected.Text := s;
      FModified := TRUE;
    end;
  end;
end;

procedure TWPXMLPropertyEditor.FindTextinbranch1Click(Sender: TObject);
var
  s: string;
  f: TWPXMLOneLevel;
begin
  if (FLastSelected <> nil) and (FLastSelected.Data <> nil) then
  begin
    s := '';
    if InputQuery('Find this Text', 'Text', s) and (s <> '') then
    begin
      f := TWPXMLOneLevel(FLastSelected.Data).FindText(s, false, true, FindList);
      if f <> nil then
      begin
        TreeView1.Selected := f.Obj as TTreeNode;
        LastSelected := TreeView1.Selected;
      end;
      FindNextPos := 1;
      FindNext1.Enabled := FindList.Count > FindNextPos;
    end;
  end;
end;


procedure TWPXMLPropertyEditor.CreateParaminallelements1Click(
  Sender: TObject);
var
  s: string;
  i : Integer;
  f: TWPXMLOneLevel;
begin
  if (FLastSelected <> nil) and (FLastSelected.Data <> nil) then
  begin
    s := '';
    f := TWPXMLOneLevel(FLastSelected.Data);
    if InputQuery('Create an empty parameter in all elements under this branch', 'Name', s) and (s <> '') then
    begin
      for i:=0 to f.Count-1 do
         if f.Elements[i].ParamValue[s]='' then
         begin
             f.Elements[i].ParamValue[s] := 'X'; // Create it
             f.Elements[i].ParamValue[s] := '';  // Delete It
         end;
    end;
  end;
end;

procedure TWPXMLPropertyEditor.Create1Click(Sender: TObject);
var
  s,v,p: string;
  i : Integer;
  f : TWPXMLOneLevel;
  NewNode: TTreeNode;
begin
  if (FLastSelected <> nil) and (FLastSelected.Data <> nil) then
  begin
    s := '';
    if InputQuery('Create a new tag', 'Name(=value or #param1=value,param2=value...)', s) and (s <> '') then
    begin
      i := Pos('#',s);
      if i>0 then
      begin
         p := Copy(s,i+1,Length(s));
         v := '';
         s := Copy(s,1,i-1);
      end else p := '';
      i := Pos('=',s);
      if i>0 then
      begin
        v := Copy(s,i+1,Length(s));
        s := Copy(s,1,i-1);
      end else v := '';
      f := TWPXMLOneLevel(FLastSelected.Data).AddTagValue(s,v);
      if p<>'' then f.Params.CommaText := p;
      NewNode := TreeView1.Items.AddChild(FLastSelected, s);
      if NewNode <> nil then
      begin
        NewNode.Data := f;
        f.Obj := NewNode;
      end;
      TreeView1.Selected :=NewNode;
      LastSelected := TreeView1.Selected;
    end;
  end;
end;

// Display the current branch incl. its start and end tags but without XML header

procedure TWPXMLPropertyEditor.ShowAsString1Click(Sender: TObject);
begin
  if (FLastSelected <> nil) and (FLastSelected.Data <> nil) then
    ShowMessage(TWPXMLOneLevel(FLastSelected.Data).AsString);
end;

procedure TWPXMLPropertyEditor.FindNext1Click(Sender: TObject);
begin
  if FindNextPos < FindList.Count then
  begin
    TreeView1.Selected := TWPXMLOneLevel(FindList[FindNextPos]).Obj as TTreeNode;
    LastSelected := TreeView1.Selected;
    inc(FindNextPos);
  end;
  FindNext1.Enabled := FindList.Count > FindNextPos;
end;

procedure TWPXMLPropertyEditor.FormShow(Sender: TObject);
begin
  FSaved := FALSE;
end;

procedure TWPXMLPropertyEditor.CopyBranch1Click(Sender: TObject);
var
  s, n : string;
  ret : Integer;
  str, str2: TMemoryStream;
  current : TWPXMLOneLevel;
  b : Boolean;
begin
  if (FLastSelected <> nil) and (FLastSelected.Data <> nil) then
  begin
      s := TWPXMLOneLevel(FLastSelected.Data).Path + '/' +
           TWPXMLOneLevel(FLastSelected.Data).Name;
      n := TWPXMLOneLevel(FLastSelected.Data).Name;
      b:= InputQuery('Copy XML Branch "' + s + '"', 'New Name', n);
    if b then
    begin
      s := TWPXMLOneLevel(FLastSelected.Data).Name;
      str := TMemoryStream.Create;
      str2:= nil;
      try
        TWPXMLOneLevel(FLastSelected.Data).Name := n;
        TWPXMLOneLevel(FLastSelected.Data).SaveToStream(str, true);
        n := TWPXMLOneLevel(FLastSelected.Data).Path;
        TWPXMLOneLevel(FLastSelected.Data).Name := s;
        // AppendFromStream overwrites items which do already exist.
        // So we make a backup copy first
        current := WPXMLTree1.Find(n);
        if current<>Nil then
        begin
            ret := MessageDlg('The path does exist. Do you want to override the existing values?'+#13+#10+
                     'To override select YES, to merge in only new values select NO.',mtConfirmation, [mbYes, mbNo, mbCancel], 0);
            if ret=mrCancel then exit
            else if ret=mrNo then
            begin
               str2 := TMemoryStream.Create;
               current.SaveToStream(str2,true);
               str2.Position := 0;
            end;
        end;
        str.Position := 0;
        WPXMLTree1.AppendFromStream(str);
        if str2<>nil then
           WPXMLTree1.AppendFromStream(str2);  // reinstall the existing values
      finally
        str.Free;
        str2.Free;
      end;
      UpdateTreeview;
      FModified := TRUE;
    end;
  end;
end;

procedure TWPXMLPropertyEditor.CreateCopy1Click(Sender: TObject);
var
  s, n : string;
  str: TMemoryStream;
  b : Boolean;
begin
  if (FLastSelected <> nil) and (FLastSelected.Data <> nil) then
  begin
      s := TWPXMLOneLevel(FLastSelected.Data).Name;
      n := TWPXMLOneLevel(FLastSelected.Data).Path;
      b:= InputQuery('Copy Branch "' + s + '"', 'New path', n);
    if b then
    begin
      s := TWPXMLOneLevel(FLastSelected.Data).Name;
      str := TMemoryStream.Create;
      try
        while (Length(n)>1) and (n[Length(n)] = '/') do n := Copy(n,1,Length(n)-1);
        if n<>'' then
        begin
        n := '<' + StringReplace(n,'/','><',[rfReplaceAll]) + '>';
        str.Write(n[1],Length(n));
        end;
        TWPXMLOneLevel(FLastSelected.Data).SaveToStream(str, false);
        str.Position := 0;
        WPXMLTree1.AppendFromStream(str);   
      finally
        str.Free;
      end;
      UpdateTreeview;
      FModified := TRUE;
    end;
  end;
end;

procedure TWPXMLPropertyEditor.FormCreate(Sender: TObject);
begin
  FindList := TList.Create;
  StringGrid1.ColWidths[1] := 300;
  FOk := FALSE;
end;

procedure TWPXMLPropertyEditor.FormDestroy(Sender: TObject);
begin
  FindList.Free;
end;



end.

