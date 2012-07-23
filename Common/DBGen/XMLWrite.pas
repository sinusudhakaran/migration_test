unit XMLWrite;

interface

(*

Assumes that there is a base class the handeles the actual implementation this just call the apropriate stubs
*)

Procedure GenerateXMLWriteFiles( SysName : String );

implementation



uses
    Contnrs,
    classes,
    SysUtils,
    DBObj,
    ReadF;


 type
   tCodeBlock = Class( TObject )
      fCode      : ShortString;
      fReadCode  : String;
      fWriteCode : string;
      fCProperty : string;
      fCArrayClass : string;
   end;


   CodeList = Class(TObjectList)
     function FindCode(code,  Name: string):tCodeBlock;
   End;

   var FieldTypes : CodeList;

Function MakeName ( S : String ): String;
Var O : String; i : Integer;
Begin
   O:=S;
   For i:=1 to Length( O ) do if not ( O[i] in ['a'..'z','0'..'9','_','A'..'Z'] ) then O[i]:='_';
   MakeName:=O;
end;

function MakeRecName( S: string): string;
begin
  result := format('T%s_Rec',[MakeName(s)]);
end;

Function MakeCleanName ( S : String ): String;
Var i : Integer;
Begin
   Result := '';
   For i:=1 to Length( S ) do if ( S[i] in ['a'..'z','0'..'9','A'..'Z'] ) then
      result := result + S[i]
end;

function MakeSaveName ( S : String ): String;
begin
   Result := MakeCleanName(S);
   if Result[1] in ['0'..'9'] then
      Result := 'N'+ Result;

end;

function MakeSingleName ( S : String ): String;
begin
   Result := MakeSaveName(S);
   if Result[ Length(Result)] in ['s', 'S'] then
      SetLength(Result,Length(Result) -1);

end;

function MakePluralName ( S : String ): String;
begin
   Result := MakeSaveName(S);
   if not (Result[ Length(Result)] in ['s', 'S']) then
      Result := result + 's';

end;


const CNameSpace = 'BankLink.Practice.BooksIO';

Procedure GenerateXMLWriteFiles( SysName : String );
var
   // Output Files
   WritePFile      : Text;
   WriteCFile      : Text;
   Name           : String[60];
   Prefix         : String[2];
   WriteFileName  : String;
   LineType       : String[10];
   FieldCode      : String[10];

   FieldName      : String[60];
   CodeBlock : tCodeBlock;
   B1,B2          : Byte;
   I: integer;
   // Internal buffers
   InterfacePart: TStringList;
   ImplementationPart: TStringList;
   ReadPart: TStringList;
   WritePart: TStringList;

   CPart: TStringList;
   CArrayClasses: TStringList;

   procedure WriteLines(FieldCode: tCodeBlock; Name: string);
      function MakeCode(value:string): string ;
      begin
         result := format(value,[prefix + Makename(Name), MakeCleanName(Name), MakeSaveName(Name), B1, B2,MakePluralName(Name), MakeSingleName(Name) ])
      end;
   begin
        if not Assigned(FieldCode) then  exit;
        
         ReadPart.Add(MakeCode(FieldCode.fReadCode));
         WritePart.Add(MakeCode(FieldCode.fWriteCode));

         cPart.Add('');
         cPart.Add(#09#09'/// <summary>');
         cPart.Add(format(#09#09'/// %s property',[MakeSaveName(Name)]));
         cPart.Add(#09#09'/// </summary>');
         cPart.Add(MakeCode(FieldCode.fCProperty) );
         cPart.Add('');

         if FieldCode.fCArrayClass > '' then begin
            CArrayClasses.Add(MakeCode(FieldCode.fCArrayClass));
         end;

   end;


begin
   If not OpenImportFile( SysName+'.TXT' ) then Halt( 1 );

   ReadPart:= TStringList.Create;
   WritePart:= TStringList.Create;
   CPart:= TStringList.Create;
   InterfacePart := TStringList.Create;
   ImplementationPart := TStringList.Create;
   CArrayClasses := TStringList.Create;
   // Make the Pas File




   While not EndOfImportFile do
   Begin
      ReadLine;
      If NoOfFields > 0 then
      Begin
         LineType := GetAField( 1 );


         If LineType='N' then
         Begin
            // New Class / Type
            If NoOfFields<4 then
            Begin
               Writeln( 'Error: Too Few Fields on line ', LineNumber );
               Halt;
            end;
            Name     := GetAField(2) ;
            Prefix   := GetAField(3);

            // Clear the Class/Type Buffers
            CPart.Clear;
            ReadPart.Clear;
            WritePart.Clear;
            CArrayClasses.Clear;

            Assign( WriteCFile, SysName + MakeCleanName(Name) + '.cs');
            Rewrite( WriteCFile );
         end  else  If LineType='F' then  Begin
            // Individual  Fields
            FieldName := GetAField(2);
            
            if Sametext(Fieldname, 'Audit Record ID') then
               Continue;

            FieldCode := GetAField(3);
            CodeBlock := FieldTypes.FindCode( FieldCode, prefix + MakeName(FieldName) );
            B1 := GetBField( 4 );
            B2 := GetBField( 5 );
            WriteLines(CodeBlock, FieldName);

         end else If LineType='E' then Begin
           // End of the Type..


           InterfacePart.Add( '');
           InterfacePart.Add( Format('%0:sHelper = record helper for %0:s', [MakeRecName(Name)]));
           InterfacePart.Add( 'public');
           InterfacePart.Add( #09'function WriteRecToNode(var Node: IXMLNode): IXMLNode;');
           InterfacePart.Add( #09'function ReadRecFromNode(Node: IXMLNode): IXMLNode;');
           InterfacePart.Add( #09'class function GetXMLNodeName: string; static;');
           InterfacePart.Add( 'end;');
           InterfacePart.Add( '');


           ImplementationPart.Add('');
           ImplementationPart.Add('// ----------------------------------------------------------------------------');
           ImplementationPart.Add('');
           ImplementationPart.Add(Format('class function %sHelper.GetXMLNodeName: string;',[MakeRecName(Name)]));
           ImplementationPart.Add('begin');
           ImplementationPart.Add(format(#09'result := ''%s%s'';',[SysName,MakeCleanName(Name)]));
           ImplementationPart.Add('end;');
           ImplementationPart.Add('');
           ImplementationPart.Add('');

           ImplementationPart.Add(Format('function %sHelper.WriteRecToNode(var Node: IXMLNode): IXMLNode;',[MakeRecName(Name)]));
           ImplementationPart.Add('var PNode, CNode, CCNode: IXMLNode;');
           ImplementationPart.Add(#9'I, J, M: Integer;');
           ImplementationPart.Add('begin');
           ImplementationPart.Add(#9'Result := Node.AddChild(GetXMLNodeName);');

           for I := 0 to WritePart.Count - 1 do
               ImplementationPart.Add( #9 + WritePart[I]);

           ImplementationPart.Add('');
           ImplementationPart.Add(#9'CNode := nil;');
           ImplementationPart.Add(#9'CCNode := nil;');
           ImplementationPart.Add(#9'PNode := nil;');
           ImplementationPart.Add('end;');

           ImplementationPart.Add('');
           ImplementationPart.Add('');

           ImplementationPart.Add( Format('function %sHelper.ReadRecFromNode(Node :IXMLNode): IXMLNode;',[MakeRecName(Name)]));
           ImplementationPart.Add('var PNode, CNode, CCNode: IXMLNode;');
           ImplementationPart.Add(#9'I, J: Integer;');
           ImplementationPart.Add('begin');

           ImplementationPart.Add(#9'if Node.NodeName = GetXMLNodeName then Result := Node');
           ImplementationPart.Add(#9'else');
           ImplementationPart.Add(#9'Result := Node.ChildNodes.FindNode(GetXMLNodeName);');
           ImplementationPart.Add(#9'if not assigned(Result) then exit;');

           ImplementationPart.Add(#9'try');

           for I := 0 to WritePart.Count - 1 do
               ImplementationPart.Add(#9 + ReadPart[I]);

           ImplementationPart.Add(#9'except');
           ImplementationPart.Add(Format(#9#9'on E: Exception do ReRaise (E, ''Reading %s'');',[MakeRecName(Name)]));
           ImplementationPart.Add(#9'end;');
           ImplementationPart.Add('');


           ImplementationPart.Add(#9'CNode := nil;');
           ImplementationPart.Add(#9'CCNode := nil;');
           ImplementationPart.Add(#9'PNode := nil;');
           ImplementationPart.Add('end;');



            (***************************************************************)
            /// C File

            WriteLn(WriteCFile,'// **********************************************************');
            WriteLn(WriteCFile,'// This file is Auto generated by DBGen');
            WriteLn(WriteCFile,'// Any changes will be lost when the file is regenerated');
            WriteLn(WriteCFile,'// **********************************************************');
          

            WriteLn(WriteCFile,'using System;');
            //WriteLn(WriteCFile,'using System.Collections.Generic;');
            //WriteLn(WriteCFile,'using System.Linq;');
            //WriteLn(WriteCFile,'using System.Text;');
            WriteLn(WriteCFile,'using System.Xml.Serialization;');

            WriteLn(WriteCFile,'');
            WriteLn(WriteCFile,'');

            WriteLn(WriteCFile,Format('namespace %s',[CNameSpace]));
            WriteLn(WriteCFile,'{');

            WriteLn(WriteCFile,#09'/// <summary>');
            WriteLn(WriteCFile,Format(#09'/// %s - %s class',[SysName,MakeCleanName(Name)]));
            WriteLn(WriteCFile,#09'/// </summary>');
            WriteLn(WriteCFile,format(#09'public partial class %s%s',[SysName,MakeCleanName(Name)]));
            WriteLn(WriteCFile,#09'{');
            WriteLn(WriteCFile,'');

            for I := 0 to CPart.Count - 1 do
               WriteLn(WriteCFile, CPart[I]);


            WriteLn(WriteCFile,'');
            WriteLn(WriteCFile,#09'}'); // Class end

            WriteLn(WriteCFile,'');
            WriteLn(WriteCFile,'');

            for I := 0 to CArrayClasses.Count - 1 do begin
               WriteLn(WriteCFile, CArrayClasses[I]);
               WriteLn(WriteCFile,'');
               WriteLn(WriteCFile,'');
            end;

            WriteLn(WriteCFile,'}');  // Name space end

            WriteLn(WriteCFile,'');
            WriteLn(WriteCFile,'');



           
            Close(WriteCFile);
         end;
      end;
   end;
   // Make the pas file..
   WriteFileName   := SysName+'_XMLHelper.PAS';
   Assign( WritePFile, WriteFileName );
   Rewrite( WritePFile );

   WriteLn(WritePFile,Format('Unit %s_XMLHelper;',[SysName]));
   WriteLn(WritePFile,'// **********************************************************');
   WriteLn(WritePFile,'// This file is Auto generated by DBGen');
   WriteLn(WritePFile,'// Any changes will be lost when the file is regenerated');
   WriteLn(WritePFile,'// **********************************************************');

   WriteLn(WritePFile,'// ----------------------------------------------------------------------------');
   WriteLn(WritePFile,'interface');
   WriteLn(WritePFile,'uses');
   WriteLn(WritePFile,#09'XMLIntf,');
   WriteLn(WritePFile,Format(#09'%sdefs;',[SysName]));
   WriteLn(WritePFile,'');
   WriteLn(WritePFile,'type');

   // Add The Interfaces
   for I := 0 to InterfacePart.Count - 1 do
      WriteLn(WritePFile,InterfacePart[I]);

   WriteLn(WritePFile,'');
   WriteLn(WritePFile,'// ----------------------------------------------------------------------------');
   WriteLn(WritePFile,'implementation');
   WriteLn(WritePFile,'uses');
   WriteLn(WritePFile,#09'WebUtils,');
   WriteLn(WritePFile,#09'Variants,');
   WriteLn(WritePFile,#09'SysUtils;');
   WriteLn(WritePFile,'');
   WriteLn(WritePFile,'');

   // Add Private functions..
   WriteLn(WritePFile,'procedure ReRaise(E: Exception; Doing: string);');
   WriteLn(WritePFile,'begin');
   WriteLn(WritePFile,#9'raise exception.Create( format(''Error : %s While : %s'',[E.Message, Doing]));');
   WriteLn(WritePFile,'end;');
   WriteLn(WritePFile,'');


    // Add The Implementation
   for I := 0 to ImplementationPart.Count - 1 do
      WriteLn(WritePFile,ImplementationPart[I]);

   // End the file
   WriteLn(WritePFile,'');
   WriteLn(WritePFile,'');
   WriteLN(WritePFile,'end.');
   Close(WritePFile);

   // Cleanup
   CloseImportFile;
   FreeAndNil(ReadPart);
   FreeAndNil(WritePart);
   FreeAndNil(CPart);
   FreeAndNil(InterfacePart);
   FreeAndNil(ImplementationPart);
   FreeAndNil(CArrayClasses);
end;


{ CodeList }

function CodeList.FindCode(code,  Name: string): tCodeBlock;
var I: integer;
begin
   result := nil;
        {
   if(Code = '$') then begin
       if (name = 'txQuantity')
       or (name = 'dsQuantity')
         then Code := 'Qty';

   end;
   }
   for I := 0 to Count - 1 do
      if TCodeBlock(list[I]).fCode = code then begin
        result := TCodeBlock(list[I]);
        exit;
      end;

end;




procedure AddFieldTypes;

const
   // These are the second level Format fields, in the order they are filled in the last format
   Make = '%0:s';   Clean = '%1:s';  Save = '%2:s';    B1 = '%3:d'; B2 = '%4:d'; plural = '%5:s';  Single = '%6:s';

   baseRead =  '%s := Get%sAttr(Result, ''%s'');';
   NulbaseRead =  '%s := Get%sElement(Result, ''%s'');';

   ArrayRead =  'GetArray(Result, ''%s'', %s);';
   // since the string arrays are passed for specific string lengths... the above does not seem to work
   SArrayRead =
    #13#10#09'PNode := Result.ChildNodes.FindNode(''%s'');'#13#10 +
    #9'if Assigned(PNode) then'#13#10 +
    #9#9'CNode := PNode.ChildNodes.FindNode(''%s'')'#13#10 +
    #9'else'#13#10 +
    #9#9'CNode := Nil;'#13#10 +
    #9'for I := low(%s) to High(%s) do begin'#13#10 +
    #9#9'if Assigned(CNode) then begin'#13#10 +
    #9#9#9'if CNode.Nodevalue <> null then '#13#10 +
    #9#9#9#9'%s[I] := CNode.Nodevalue'#13#10 +
    #9#9#9'else %s[I] := '''';'#13#10 +
    #9#9#9'CNode := CNode.NextSibling;'#13#10 +
    #9#9'end else'#13#10 +
    #9#9#9'%s[I] := '''''#13#10 +
    #9'end;'#13#10;


   // Similar problem with Multy dimentional arrays..
    MArrayRead =
    #9'PNode := Result.ChildNodes.FindNode(''%s'');'#13#10 +
    #9'if Assigned(PNode) then begin'#13#10 +
    #9#9'PNode := PNode.ChildNodes.FindNode(''%s'');'#13#10 +
    #9'end;'#13#10 +
    #9'for I := low(%s) to High(%s) do begin'#13#10 +
    #9#9'if Assigned(PNode) then begin'#13#10 +
    #9#9#9'CNode := PNode.ChildNodes.FindNode(''%s'');'#13#10 +
    #9#9#9'if Assigned(CNode) then'#13#10 +
    #9#9#9#9'CCNode := CNode.ChildNodes.FindNode(''%s'')'#13#10 +
    #9#9#9'else CCNode := Nil;'#13#10 +
    #9#9'end else'#13#10 +
    #9#9#9'CNode := Nil;'#13#10 +
    #9#9'for J := Low(%s[I]) to High(%s[I]) do begin'#13#10 +
    #9#9#9'if Assigned(CCNode) then begin'#13#10 +
    #9#9#9#9'%s[I,J] := CCNode.Nodevalue;'#13#10 +
    #9#9#9#9'CCNode := CCNode.NextSibling;'#13#10 +
    #9#9#9'end else'#13#10 +
    #9#9#9#9'%s[I,J] := 0;'#13#10 +
    #9#9'end;'#13#10 +
    #9#9#9'if Assigned(PNode) then'#13#10 +
    #9#9#9#9'PNode := PNode.NextSibling;'#13#10 +
    #9'end;';

   baseWrite =  'Set%sAttr(Result, ''%s'', %s);';
   NulbaseWrite =  'Set%sElement(Result, ''%s'', %s);';

   ArrayWrite =  'SetArray(Result, ''%s'', %s);';
   // and the string version
   SArrayWrite =
   'PNode := Result.AddChild(''%s'');'#13#10 +
   #9'M :=  Low(%s);'#13#10 +
   #9'for I := Low(%s) to High(%s) do'#13#10 +
   #9#9'if  %s[I] > '''' then'#13#10 +
   #9#9#9'M := I;'#13#10 +
   #9'for I := Low(%s) to M do begin'#13#10 +
   #9#9'CNode := PNode.AddChild(''%s'');'#13#10 +
   #9#9'CNode.NodeValue := %s[I];'#13#10 +
   #9'end;';

   // And the multi array
   MArrayWrite =
   'PNode := result.AddChild(''%s'');'#13#10  +
   #9'M :=  Low(%s);'#13#10 +
   #9'for I := Low(%s) to High(%s) do'#13#10 +
   #9#9'for J := Low(%s[I]) to High(%s[I]) do'#13#10 +
   #9#9#9'if %s[I,J] > 0 then begin'#13#10 +
   #9#9#9#9'M := I;'#13#10 +
   #9#9#9#9'Break;'#13#10 +
   #9#9#9'end;'#13#10 +
   #9'for I := low(%s) to M do begin'#13#10 +
   #9#9'CNode := PNode.AddChild(''%s'');'#13#10 +
   #9#9'CNode := CNode.AddChild(''%s'');'#13#10 +
   #9#9'for J := Low(%s[I]) to High(%s[I]) do begin'#13#10 +
   #9#9#9'CCNode := CNode.AddChild(''%s'');'#13#10 +
   #9#9#9'CCNode.NodeValue := (%s[I,J]);'#13#10 +
   #9#9'end;'#13#10 +
   #9'end;';


   // C# Fields
   baseField =
   #09#09'[XmlAttribute("%s", DataType = "%s")]'#13#10 +
   #09#09'public %s %s { get; set; }'#13#10;

   NulbaseField =
   #9#9'[XmlElement("%s", DataType = "%s")]'#13#10 +
   #9#9'public %s? %s { get; set; }';

   ArrayField =
   #09#09'[XmlArray("%s"),XmlArrayItem("%s", DataType = "%s")]'#13#10 +
   #09#09'public %s[] %s { get; set; }';

   MArrayField =
   #09#09'[XmlArray("%s"),XmlArrayItem("%s")]'#13#10 +
   #09#09'public %s[] %s { get; set; }';

   ArrayClass =
   #9'/// <summary>'#13#10 +
	 #9'/// %s Array class'#13#10 +
	 #9'/// </summary>'#13#10 +
   #9'public class %s'#13#10 +
   #9'{'#13#10 +
   #9#9'/// <summary>'#13#10 +
   #9#9'/// Name property'#13#10 +
	 #9#9'/// </summary>'#13#10 +
   #9#9'[XmlArray("%s"),XmlArrayItem("%s", DataType = "%s")]'#13#10 +
   #9#9'public %s[] %s { get; set; }'#13#10 +
   #9'}'#13#10;

var F : tCodeBlock;
begin

    // 0 Field ; 1 CleanName ;
    F := tCodeBlock.Create;
    F.fCode := 'S';
    F.fReadCode  := format(baseRead,[make, 'Text', save]);
    F.fWriteCode := format(baseWrite,['Text',save, Make]);
    F.fCProperty  :=  format(baseField,[Clean,'string','String',save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'BS';
    F.fReadCode  := format(SArrayRead,[Plural,Single,Make, Make, make, Make, make, make]);
    F.fWriteCode := format(SArrayWrite,[Plural, make, make, make,make,make, Single, Make]);
    F.fCProperty  :=  format(ArrayField,[Plural,Single,'string','String',save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'BS0';
    F.fReadCode  := format(SArrayRead,[Plural,Single,Make, Make, make, Make, make, make]);
    F.fWriteCode := format(SArrayWrite,[Plural, make, make, make,make,make, Single, Make]);
    F.fCProperty  :=  format(ArrayField,[Plural,Single,'string','String',save]);
    FieldTypes.Add(F);


    F := tCodeBlock.Create;
    F.fCode := 'AS';
    F.fReadCode  := format(baseRead,[make, 'Text', save]);
    F.fWriteCode := format(baseWrite,['Text',save, Make]);
    F.fCProperty  :=  format(baseField,[Clean,'string','String',save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'D';
    F.fReadCode  := format(baseRead,[make, 'Int', save]);
    F.fWriteCode := format(baseWrite,['Int',save, Make]);
    F.fCProperty  :=  format(baseField,[save,'int','Int32',save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'L';
    F.fReadCode  := format(baseRead,[make, 'Int', save]);
    F.fWriteCode := format(baseWrite,['Int',save, Make]);
    F.fCProperty  :=  format(baseField,[save,'int','Int32',save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'BL';
    F.fReadCode  := format(ArrayRead,[Plural, Make]);
    F.fWriteCode := format(ArrayWrite,[Plural, Make]);
    F.fCProperty  :=  format(ArrayField,[Plural,Single,'int','Int32',save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'BD';
    F.fReadCode  := format(ArrayRead,[Plural, Make]);
    F.fWriteCode := format(ArrayWrite,[Plural, Make]);
    F.fCProperty  :=  format(ArrayField,[Plural,Single,'int','Int32',save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'BD0';
    F.fReadCode  := format(ArrayRead,[Plural, Make]);
    F.fWriteCode := format(ArrayWrite,[Plural, Make]);
    F.fCProperty  :=  format(ArrayField,[Plural,Single,'int','Int32',save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'BL0';
    F.fReadCode  := format(ArrayRead,[Plural, Make]);
    F.fWriteCode := format(ArrayWrite,[Plural, Make]);
    F.fCProperty  :=  format(ArrayField,[Plural,Single,'int','Int32',save]);
    FieldTypes.Add(F);


    F := tCodeBlock.Create;
    F.fCode := 'I';
    F.fReadCode  := format(baseRead,[make, 'Int', save]);
    F.fWriteCode := format(baseWrite,['Int',save, Make]);
    F.fCProperty  :=  format(baseField,[save,'int','Int32',save]);
    FieldTypes.Add(F);


    F := tCodeBlock.Create;
    F.fCode := 'BI';
    F.fReadCode  := format(ArrayRead,[Save, Make]);
    F.fWriteCode := format(ArrayWrite,[Plural, Make]);
    F.fCProperty  :=  format(ArrayField,[Plural,Single,'int','Int32',save]);
    FieldTypes.Add(F);



    F := tCodeBlock.Create;
    F.fCode := 'Y';
    F.fReadCode  := format(baseRead,[make, 'Bool', save]);
    F.fWriteCode := format(baseWrite,['Bool',save, Make]);
    F.fCProperty  :=  format(baseField,[save,'boolean','bool',save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'BY';
    F.fReadCode  := format(ArrayRead,[Plural, Make]);
    F.fWriteCode := format(ArrayWrite,[Plural, Make]);
    F.fCProperty  :=  format(ArrayField,[Plural,Single,'boolean','bool',save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'BY0';
    F.fReadCode  := format(ArrayRead,[Plural, Make]);
    F.fWriteCode := format(ArrayWrite,[Plural, Make]);
    F.fCProperty  :=  format(ArrayField,[Plural,Single,'boolean','bool',save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'B';
    F.fReadCode  := format(baseRead,[make, 'Int', save]);
    F.fWriteCode := format(baseWrite,['Int',save, Make]);
    F.fCProperty  :=  format(baseField,[save,'unsignedByte','byte',save]);
    FieldTypes.Add(F);

    
    F := tCodeBlock.Create;
    F.fCode := 'BB0';
    F.fReadCode  := format(ArrayRead,[Plural, Make]);
    F.fWriteCode := format(ArrayWrite,[Plural, Make]);
    F.fCProperty  :=  format(ArrayField,[Plural,Single,'unsignedByte','byte',save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'BB';
    F.fReadCode  := format(ArrayRead,[Plural, Make]);
    F.fWriteCode := format(ArrayWrite,[Plural, Make]);
    F.fCProperty  :=  format(ArrayField,[Plural,Single,'unsignedByte','byte',save]);
    FieldTypes.Add(F);


    F := tCodeBlock.Create;
    F.fCode := '$';
    F.fReadCode  := format(baseRead,[make, 'Int64', save]);
    F.fWriteCode := format(baseWrite,['Int64',save, Make]);
    //F.FCClass  :=  format(NulbaseField,[save,'decimal','Decimal',save]);
    F.fCProperty  :=  format(baseField,[save,'long','Int64',save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'B$';
    F.fReadCode  := format(ArrayRead,[Plural, Make]);
    F.fWriteCode := format(ArrayWrite,[Plural, Make]);
    //F.FCClass  :=  format(arrayField,[Plural,Single,'decimal','Decimal',save]);
    F.fCProperty  :=  format(arrayField,[Plural,Single,'long','Int64',save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'BB$';
    F.fReadCode  := format(MArrayRead, [Plural, Plural, Make, Make,Plural,Single, Make,Make,Make, Make]);
    F.fWriteCode := format(MArrayWrite,[Plural,Make,Make,Make,Make,Make,Make,Make,Plural,Plural,Make, Make,Single, Make]);
    //F.FCClass  :=  format(arrayField,[Plural,Single,'decimal','Decimal',save]);
    F.fCProperty  :=  format(MarrayField,[Plural,Plural,Plural,save]);
    F.fCArrayClass :=  format(ArrayClass,[Plural,Plural,Plural,Single,'long','Int64',Single,save]);
    FieldTypes.Add(F);

    F := tCodeBlock.Create;
    F.fCode := 'B$0';
    F.fReadCode  := format(ArrayRead,[Plural, Make]);
    F.fWriteCode := format(ArrayWrite,[Plural, Make]);
    //F.FCClass  :=  format(arrayField,[Plural,Single,'decimal','Decimal',save]);
    F.fCProperty  :=  format(arrayField,[Plural,Single,'long','Int64',save]);
    FieldTypes.Add(F);

    {
    F := tCodeBlock.Create;
    F.fCode := 'Qty';
    F.fReadCode  := format(NulbaseRead,[make, 'Qty', save]);
    F.fWriteCode := format(NulbaseWrite,['Qty',save, Make]);
    F.FCClass  :=  format(NulbaseField,[save,'decimal','Decimal',save]);
    FieldTypes.Add(F);
    }

end;



Initialization
   FieldTypes := CodeList.Create(True);
   AddFieldTypes;
Finalization
   FreeAndNil(FieldTypes);
end.
