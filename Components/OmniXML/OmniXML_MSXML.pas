{ $OmniXML: OmniXML/OmniXML_MSXML.pas,v 1.2 2005/02/01 12:12:42 mremec Exp $ }

(*******************************************************************************
* The contents of this file are subject to the Mozilla Public License Version  *
* 1.1 (the "License"); you may not use this file except in compliance with the *
* License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ *
*                                                                              *
* Software distributed under the License is distributed on an "AS IS" basis,   *
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for *
* the specific language governing rights and limitations under the License.    *
*                                                                              *
* The Original Code is OmniXML_MSXML.pas                                       *
*                                                                              *
* The Initial Developer of the Original Code is Miha Remec                     *
*   http://MihaRemec.com/                                                      *
*******************************************************************************)
unit OmniXML_MSXML;

interface

{$I OmniXML.inc}

{$IFNDEF MSWINDOWS}
  {$MESSAGE FATAL 'MSXML can only be used on Windows platform'}
{$ENDIF}

uses
  ComObj, {$IFDEF DELPHI6_UP} MSXML {$ELSE} MSXML2_TLB {$ENDIF};

type
  IXMLDocument = IXMLDOMDocument;
  IXMLText = IXMLDOMText;
  IXMLElement = IXMLDOMElement;
  IXMLProcessingInstruction = IXMLDOMProcessingInstruction;
  IXMLCDATASection = IXMLDOMCDATASection;
  IXMLComment = IXMLDOMComment;
  IXMLAttr = IXMLDOMAttribute;
  IXMLNodeList = IXMLDOMNodeList;
  IXMLNode = IXMLDOMNode;
  IXMLParseError = IXMLDOMParseError;

const
  DEFAULT_TRUE = '1';
  DEFAULT_FALSE = '0';

function CreateXMLDoc: IXMLDocument;
  
implementation

function CreateXMLDoc: IXMLDocument;
begin
  Result := CreateComObject(CLASS_DOMDocument) as IXMLDOMDocument;
end;

end.

