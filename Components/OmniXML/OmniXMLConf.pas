{ $OmniXML: OmniXML/OmniXMLConf.pas,v 1.1.1.1 2004/04/17 11:16:33 mr Exp $ }

(*******************************************************************************
* The contents of this file are subject to the Mozilla Public License Version  *
* 1.1 (the "License"); you may not use this file except in compliance with the *
* License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ *
*                                                                              *
* Software distributed under the License is distributed on an "AS IS" basis,   *
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for *
* the specific language governing rights and limitations under the License.    *
*                                                                              *
* The Original Code is OmniXMLConf.pas                                         *
*                                                                              *
* The Initial Developer of the Original Code is Miha Vrhovnik                  *
*   http://simail.sourceforge.net/, http://divxdb.cordia.si                    *
*                                                                              *
* Last changed: 2003-11-10                                                     *
*                                                                              *
* History:                                                                     *
*     1.0.2: 2003-12-14                                                        *
*       - document can be marked as read only (no changes are saved)           *
*     1.0.1: 2003-11-01                                                        *
*       - fixed bug in  WriteIdentNode                                         *
*     1.0.0: 2003-10-25                                                        *
*       - initial version                                                      *
*                                                                              *
* Contributor(s):                                                              *
*******************************************************************************)

unit OmniXMLConf;

interface

uses SysUtils, Classes, OmniXML, OmniXMLUtils, Controls, Forms;

//you may use this class as replacement for TIniFile
type TxmlConf=class
  private
    FFileName: String;
    FxmlDoc: IXMLDocument;
    FxmlRoot: IXMLElement;
    FSaveAfterChange: Boolean;
    FReadOnly: Boolean;
    procedure SaveConfig;
    procedure WriteIdentNode(Section: String; Ident: String; Value: WideString);
  public
    constructor Create(FileName: String);
    destructor Destroy; override;

    function ReadInteger(Section: String; Ident: String; Default: Int64): Int64;
    function ReadString(Section: String; Ident: String; Default: String): String;
    function ReadBool(Section: String; Ident: String; Default: Boolean): Boolean;
    function ReadFloat(Section: String; Ident: String; Default: Extended): Extended;
    function ReadDate(Section: String; Ident: String; Default: TDateTime): TDateTime;
    function ReadTime(Section: String; Ident: String; Default: TDateTime): TDateTime;
    function ReadDateTime(Section: String; Ident: String; Default: TDateTime): TDateTime;
    procedure ReadControlSettings(Control: TControl; ctlName: String = '');

    procedure WriteInteger(Section: String; Ident: String; Value: Int64);
    procedure WriteString(Section: String; Ident: String; Value: String);
    procedure WriteBool(Section: String; Ident: String; Value: Boolean);
    procedure WriteFloat(Section: String; Ident: String; Value: Extended);
    procedure WriteDate(Section: String; Ident: String; Value: TDateTime);
    procedure WriteTime(Section: String; Ident: String; Value: TDateTime);
    procedure WriteDateTime(Section: String; Ident: String; Value: TDateTime);

    procedure WriteControlSettings(Control: TControl; ctlName: String = '');
  published
    property DocReadOnly:Boolean read FReadOnly write FReadOnly;
end;

implementation

{ TxmlConf }

constructor TxmlConf.Create(FileName: String);
begin
  FSaveAfterChange := True;
  FReadOnly := False;

  FFileName := FileName;
  FxmlDoc := CreateXMLDoc;
  FxmlDoc.PreserveWhiteSpace := False;

  //read file if exists
  if FileExists(FFileName) then begin
    FxmlDoc.Load(FFileName);
    FxmlRoot := FxmlDoc.DocumentElement;
  end
  else begin
    FxmlDoc.AppendChild(FxmlDoc.CreateProcessingInstruction('xml', 'version="1.0" encoding="utf-8"'));
    FxmlRoot := FxmlDoc.CreateElement('conf');
    FxmlDoc.DocumentElement := FxmlRoot;

    SaveConfig;
  end;
end;

destructor TxmlConf.Destroy;
begin
  SaveConfig; //Save settings before exit
  FxmlRoot := nil;
  FxmlDoc := nil;
end;

function TxmlConf.ReadBool(Section, Ident: String; Default: Boolean): Boolean;
var dataNode: IXMLNode;
begin
  //set return value to default one
  Result := Default;

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    if Length(dataNode.Text) = 1 then
      XMLStrToBool(dataNode.Text, Result)
    else //this is solely for backward compatibility purposes
      Result := (dataNode.Text[1] = 'T')
  end;

end;

procedure TxmlConf.ReadControlSettings(Control: TControl; ctlName:String = '');
var t,l: Integer;
begin
  if ctlName = '' then
    ctlName := Control.Name;

  if Control is TForm then begin
    //damnm this thorows an exception
    //(Control as TForm).Position := poDesigned;

    //set form width & height only if form is sizeable
    if (Control as TForm).BorderStyle = bsSizeable then begin
      Control.Width := ReadInteger(ctlName, 'width', Control.Width);
      Control.Height := ReadInteger(ctlName, 'height', Control.Height);
    end;

    t := (Screen.Height div 2) - (Control.Height div 2);
    l := (Screen.Width div 2) - (Control.Width div 2);

    Control.Top := ReadInteger(ctlName, 'top', t);
    Control.Left := ReadInteger(ctlName, 'left', l);
  end
  else begin
    Control.Width := ReadInteger(ctlName, 'width', Control.Width);
    Control.Height := ReadInteger(ctlName, 'height', Control.Height);
    Control.Top := ReadInteger(ctlName, 'top', Control.Top);
    Control.Left := ReadInteger(ctlName, 'left', Control.Left);
  end;

end;

function TxmlConf.ReadDate(Section, Ident: String; Default: TDateTime): TDateTime;
var dataNode: IXMLNode;
begin
  //set return value to default one
  Result := Default;

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    XMLStrToDate(dataNode.Text, Result)
  end;
end;

function TxmlConf.ReadDateTime(Section, Ident: String; Default: TDateTime): TDateTime;
var dataNode: IXMLNode;
begin
  //set return value to default one
  Result := Default;

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    XMLStrToDateTime(dataNode.Text, Result)
  end;
end;

function TxmlConf.ReadFloat(Section, Ident: String; Default: Extended): Extended;
var dataNode: IXMLNode;
begin
  //set return value to default one
  Result := Default;

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    XMLStrToExtended(dataNode.Text, Result)
  end;
end;

function TxmlConf.ReadInteger(Section, Ident: String; Default: Int64): Int64;
var dataNode: IXMLNode;
begin
  //set return value to default one
  Result := Default;

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    XMLStrToInt64(dataNode.Text, Result)
  end;
end;

function TxmlConf.ReadString(Section, Ident, Default: String): String;
var dataNode: IXMLNode;
begin

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    Result := dataNode.Text
  end
  //return default value
  else Result := Default;

end;

function TxmlConf.ReadTime(Section, Ident: String; Default: TDateTime): TDateTime;
var dataNode: IXMLNode;
begin

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    XMLStrToTime(dataNode.Text, Result)
  end
  //return default value
  else Result := Default;

end;

procedure TxmlConf.SaveConfig;
begin
  if FFileName = '' then Exit;
  if FReadOnly then Exit;
  FxmlDoc.Save(FFileName, ofIndent);
end;

procedure TxmlConf.WriteBool(Section, Ident: String; Value: Boolean);
begin
  WriteIdentNode(Section, Ident, XMLBoolToStr(Value));
end;

procedure TxmlConf.WriteControlSettings(Control: TControl; ctlName:String = '');
begin
  if ctlName = '' then
    ctlName := Control.Name;

  WriteInteger(ctlName, 'width', Control.Width);
  WriteInteger(ctlName, 'height', Control.Height);
  WriteInteger(ctlName, 'top', Control.Top);
  WriteInteger(ctlName, 'left', Control.Left);
  if FSaveAfterChange then
    SaveConfig;

end;

procedure TxmlConf.WriteDate(Section, Ident: String; Value: TDateTime);
begin
  WriteIdentNode(Section, Ident, XMLDateToStr(Value));
end;

procedure TxmlConf.WriteDateTime(Section, Ident: String; Value: TDateTime);
begin
  WriteIdentNode(Section, Ident, XMLDateTimeToStr(Value));
end;

procedure TxmlConf.WriteFloat(Section, Ident: String; Value: Extended);
begin
  WriteIdentNode(Section, Ident, XMLExtendedToStr(Value));
end;

procedure TxmlConf.WriteIdentNode(Section, Ident: String; Value: WideString);
var sectNode, identNode: IXMLNode;
begin
  sectNode := nil;
  identNode := nil;

  //1st find section node
  sectNode := FindNode(FxmlRoot, Section, '');
  if sectNode <> nil then begin
    //section node exists
    //now find ident node
    identNode := FindNode(sectNode, Ident, '');
    //if does not exists then create it
    if identNode = nil then
      identNode := EnsureNode(sectNode, Ident);
  end
  //create both nodes
  else begin
    sectNode := EnsureNode(FxmlRoot, Section);
    identNode := EnsureNode(sectNode, Ident);
  end;

  identNode.Text := Value;

  if FSaveAfterChange then
    SaveConfig;

end;

procedure TxmlConf.WriteInteger(Section, Ident: String; Value: Int64);
begin
  WriteIdentNode(Section, Ident, XMLInt64ToStr(Value));
end;

procedure TxmlConf.WriteString(Section, Ident, Value: String);
begin
  WriteIdentNode(Section, Ident, Value);
end;

procedure TxmlConf.WriteTime(Section, Ident: String; Value: TDateTime);
begin
  WriteIdentNode(Section, Ident, XMLTimeToStr(Value));
end;

end.
