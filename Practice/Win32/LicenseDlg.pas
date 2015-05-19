unit LicenseDlg;
//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  bkXPThemes,
  OsFont,
  ExtCtrls,
  ComCtrls,
  bkProduct;

type
  //----------------------------------------------------------------------------
  TDlgLicense = class(TForm)
    mmoEULA: TMemo;
    lRead: TLabel;
    lAccept: TLabel;
    pBtn: TPanel;
    btnNo: TButton;
    btnYes: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FAbout: Boolean;
    procedure SetAbout(Value: Boolean);
    procedure DoRebranding();
    procedure FillEula;
  public
    { Public declarations }
    property About: Boolean read FAbout write SetAbout;
  end;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  bkConst,
  Globals,
  IniFiles,
  CountryUtils;

//------------------------------------------------------------------------------
procedure TDlgLicense.DoRebranding;
begin
  lAccept.Caption := 'Do you accept all the terms of the preceding Licence Agreement? ' +
                     'If you choose No, you will not be able to login. To use ' +
                     BRAND_FULL_PRACTICE + ' you must accept this agreement.';
end;

//------------------------------------------------------------------------------
procedure TDlgLicense.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  FAbout := False;
  mmoEULA.WordWrap := True;

  DoRebranding();

  FillEula();
end;

//------------------------------------------------------------------------------
procedure TDlgLicense.FillEula;
var
  Eula: TStringList;
begin
  mmoEula.Clear;
  try
    Eula := TStringList.Create;
    Eula.Clear;
    Eula.Add('Last updated: February 2015');
    Eula.Add('');
    Eula.Add('Software End-User Licence Agreement');
    Eula.Add('');
    Eula.Add('‘MYOB BankLink’ means MYOB Australia Pty Ltd (if you acquire this Software in Australia) or MYOB NZ Limited (if you acquire this Software in New Zealand).');
    Eula.Add('');
    Eula.Add('');
    Eula.Add('IMPORTANT NOTICE PLEASE READ CAREFULLY BEFORE INSTALLING OR USING');
    Eula.Add('THE SOFTWARE:');
    Eula.Add('');
    Eula.Add('1	Agreement');
    Eula.Add('');
    Eula.Add('1.1	This Software End-User Licence Agreement (''Agreement'') is between you');
    Eula.Add('	and MYOB BankLink.');
    Eula.Add('');
    Eula.Add('1.2	This computer software, together with any supporting documentation');
    Eula.Add('        	and any modifications or amendments made by MYOB BankLink');
    Eula.Add('        	(‘the Software’), is owned by MYOB BankLink. Provided your copy');
    Eula.Add('        	of the Software has been lawfully obtained, and in relation to');
    Eula.Add('        	InvoicePlus and PayablesPlus, provided you are a registered user');
    Eula.Add('        	of MYOB BankLink''s services, you are authorised to use the ');
    Eula.Add('        	Software in accordance with this Agreement.');
    Eula.Add('');
    Eula.Add('1.3	By proceeding to install, store, load, execute and display');
    Eula.Add('        	(individually or collectively, ‘Use’) the Software, you agree to');
    Eula.Add('        	be bound by the terms of this Agreement. If your copy of the');
    Eula.Add('        	Software has not been legally obtained or you do not agree to the');
    Eula.Add('        	terms of this Agreement, MYOB BankLink is not willing to licence the');
    Eula.Add('        	Software to you and you must not Use the Software.');
    Eula.Add('');
    Eula.Add('');
    Eula.Add('2	Grant of licence');
    Eula.Add('');
    Eula.Add('2.1	In consideration of you agreeing to abide by the terms of this');
    Eula.Add('        	Agreement MYOB BankLink hereby grants you a non-exclusive,');
    Eula.Add('        	non-transferable licence to Use the Software in accordance with');
    Eula.Add('        	this Agreement.');
    Eula.Add('');
    Eula.Add('2.2	The licence is perpetual unless terminated in accordance with');
    Eula.Add('        	clause 7.');
    Eula.Add('');
    Eula.Add('2.3	With regard to the InvoicePlus and PayablesPlus products, you may');
    Eula.Add('        	Use one copy of the Software on a single computer.');
    Eula.Add('');
    Eula.Add('');
    Eula.Add('3	Limitations on Use');
    Eula.Add('');
    Eula.Add('3.1	The Software licence is personal to you; you cannot sell,');
    Eula.Add('        	sub-licence, assign, transfer, charge, lend the Software to any');
    Eula.Add('        	other person or entity or otherwise dispose of the rights or');
    Eula.Add('        	obligations under this Agreement without the written consent of');
    Eula.Add('        	MYOB BankLink.');
    Eula.Add('');
    Eula.Add('3.2	You cannot copy, alter, modify or reproduce the Software, but you');
    Eula.Add('        	may make one copy of the Software for backup purposes only.');
    Eula.Add('        	Except as otherwise permitted at law, you cannot reverse assemble');
    Eula.Add('        	or reverse compile or directly or indirectly allow or cause a');
    Eula.Add('        	third party to reverse assemble or reverse compile the whole or');
    Eula.Add('        	any part of the Software.');
    Eula.Add(' ');
    Eula.Add('3.3	MYOB BankLink may sell, sub-licence, assign, transfer, charge or lend');
    Eula.Add('        	the Software to any other person or entity or otherwise dispose of');
    Eula.Add('        	rights or obligations under this Agreement at any time without');
    Eula.Add('        	your consent.');
    Eula.Add('');
    Eula.Add('');
    Eula.Add('4	Title');
    Eula.Add('');
    Eula.Add('4.1	All title and intellectual property rights in the Software remain');
    Eula.Add('        	with MYOB BankLink (or it''s Licensors). You acknowledge that rights in');
    Eula.Add('        	the Software are licensed (not sold) to you, and that you have no');
    Eula.Add('        	rights in, or to, the Software other than the right to Use the');
    Eula.Add('        	Software in accordance with the terms of this Agreement. You');
    Eula.Add('        	acknowledge that you have no right to have access to the Software');
    Eula.Add('        	in source code form or in unlocked coding or with comments.');
    Eula.Add('');
    Eula.Add('4.2	You will notify MYOB BankLink as soon as you become aware of any');
    Eula.Add('        	infringement, suspected infringement or alleged infringement of');
    Eula.Add('        	MYOB BankLink’s intellectual property rights in the Software.');
    Eula.Add('');
    Eula.Add('');
    Eula.Add('5	Warranties');
    Eula.Add('');
    Eula.Add('5.1	Except as otherwise agreed, MYOB BankLink is not obliged to support');
    Eula.Add('        	the Software, whether by providing advice, training, error-correction,');
    Eula.Add('        	modification, new releases or enhancements or otherwise.');
    Eula.Add('');
    Eula.Add('5.2	If you acquired this Software in New Zealand, to the extent');
    Eula.Add('        	permitted by law, MYOB BankLink excludes and disclaims all and any');
    Eula.Add('        	guarantees and/or warranties whether express, implied, statutory');
    Eula.Add('        	or otherwise in respect of the Software and in particular, to the');
    Eula.Add('        	extent that they are applicable, expressly excludes the provisions');
    Eula.Add('        	of the New Zealand Consumer Guarantees Act 1993 pursuant to clause');
    Eula.Add('        	43(2) thereof and the provisions of the New Zealand Sale of Goods');
    Eula.Add('        	Act 1908 pursuant to clause 56 thereof. You confirm that you have');
    Eula.Add('        	the Software for business purposes.');
    Eula.Add('');
    Eula.Add('5.3	If you acquired this Software in Australia:');
    Eula.Add('(a)	This Agreement does not exclude, restrict or modify:');
    Eula.Add('	(i)	The application of any provision of the Australian Consumer Law');
    Eula.Add('		(‘ACL’) (whether applied as a law of the Commonwealth or any');
    Eula.Add('		State or Territory of Australia);');
    Eula.Add('	(ii)	The exercise of any right or remedy conferred by the ACL; or');
    Eula.Add('	(iii)	The liability of MYOB BankLink for a failure to comply with any');
    Eula.Add('		applicable consumer guarantees, where to do so would:');
    Eula.Add('		A.	contravene the ACL; or');
    Eula.Add('		B.	cause any part of this Agreement to be void.  ');
    Eula.Add('(b)	To the extent permitted by law, MYOB BankLink excludes and disclaims all');
    Eula.Add('	and any guarantees and/or warranties whether express, implied, statutory');
    Eula.Add('	or otherwise in respect of the Software, except for any condition,');
    Eula.Add('	warranty, guarantee, right or remedy under the ACL. Nothing in this clause 5');
    Eula.Add('	excludes, restricts or modifies any condition, warranty, guarantee, right or');
    Eula.Add('	remedy under the ACL.');
    Eula.Add('');
    Eula.Add('5.4	You acknowledge that MYOB BankLink does not warrant or promise that the');
    Eula.Add('        	Software will meet your requirements and that you have solely exercised');
    Eula.Add('        	and relied upon your own skill and judgment in determining whether the');
    Eula.Add('        	Software meets your particular requirements, and have not relied on any');
    Eula.Add('        	statement or representation by or on behalf of MYOB BankLink (unless');
    Eula.Add('        	made fraudulently).');
    Eula.Add('');
    Eula.Add('5.5	MYOB BankLink is providing this Software to you "AS IS" and you');
    Eula.Add('        	acknowledge that risk of loss or of damage to your computer system');
    Eula.Add('        	or data at all times remains with you.');
    Eula.Add(' ');
    Eula.Add('5.6	MYOB BankLink does not warrant that:');
    Eula.Add('');
    Eula.Add('        	5.6.1	Any of the data provided by or on behalf of MYOB BankLink');
    Eula.Add('		and received by you for use with the Software will be accurate');
    Eula.Add('		or virus free;');
    Eula.Add('');
    Eula.Add('        	5.6.2	The Software will operate without interruption or errors; or');
    Eula.Add('');
    Eula.Add('        	5.6.3	That the Software will not affect the operation of other');
    Eula.Add('		installed applications.');
    Eula.Add('');
    Eula.Add('');
    Eula.Add('6	Liability');
    Eula.Add('');
    Eula.Add('6.1	MYOB BankLink will not be liable to you for any loss or damage');
    Eula.Add('        	(including, without limitation, consequential loss or damage)');
    Eula.Add('        	suffered by you whether arising directly or indirectly from the');
    Eula.Add('        	Use of the Software or any data provided by or on behalf of');
    Eula.Add('        	MYOB BankLink under this Agreement or from any failure or omission');
    Eula.Add('        	on the part of MYOB BankLink or otherwise.');
    Eula.Add(' ');
    Eula.Add('6.2	In no event will MYOB BankLink be liable for any remote, indirect,');
    Eula.Add('        	consequential, punitive, special or incidental damages, including');
    Eula.Add('        	without limitation, damages resulting from loss of any data, loss');
    Eula.Add('        	of income or profits or business interruption, or cost of cover');
    Eula.Add('        	whether based in contract, tort (including negligence), at law, in');
    Eula.Add('        	equity, under statute or otherwise. This limitation will apply even if');
    Eula.Add('        	MYOB BankLink has been advised of the possibility of such damages.');
    Eula.Add('');
    Eula.Add('6.3	Where the ACL applies (if you acquired this Software in Australia), then');
    Eula.Add('        	the liability of MYOB BankLink for any loss arising as a result of or in ');
    Eula.Add('        	relation to the supply by MYOB BankLink of the Software, including any');
    Eula.Add('        	economic or consequential loss which may be sustained or incurred,');
    Eula.Add('        	shall be limited to:');
    Eula.Add('');
    Eula.Add('        	6.3.1	the replacement of the Software or the supply of');
    Eula.Add('                	equivalent Software;');
    Eula.Add('');
    Eula.Add('        	6.3.2	the repair of the Software;');
    Eula.Add('');
    Eula.Add('        	6.3.3	the payment of the cost of repairing or replacing the');
    Eula.Add('                	Software or acquiring equivalent Software;');
    Eula.Add('');
    Eula.Add('        	6.3.4	the payment of the cost of having the Software replaced;');
    Eula.Add('');
    Eula.Add('        	6.3.5	the payment for the reduction in value of the Software; or');
    Eula.Add('');
    Eula.Add('        	6.3.6	the cost of the refund of the Software license fee, if');
    Eula.Add('                	any, paid by you. However, nothing in this clause 6');
    Eula.Add('                	excludes, restricts or modifies any condition, warranty,');
    Eula.Add('                	guarantee, right or remedy under the ACL.');
    Eula.Add('');
    Eula.Add('');
    Eula.Add('7	Termination');
    Eula.Add('');
    Eula.Add('7.1	Without prejudice to any other rights, MYOB BankLink may terminate');
    Eula.Add('        	this Agreement by written notice to you with immediate effect if you');
    Eula.Add('        	fail to comply with the terms and conditions of this Agreement or');
    Eula.Add('        	if you become bankrupt or insolvent (or suffer any similar');
    Eula.Add('        	circumstances anywhere in the world).');
    Eula.Add('');
    Eula.Add('7.2	Upon termination for any reason:');
    Eula.Add('');
    Eula.Add('        	7.2.1	all rights granted to you under this Agreement shall cease;');
    Eula.Add('');
    Eula.Add('        	7.2.2	you must cease all Use of the Software and any other');
    Eula.Add('                	activities authorised by this Agreement; and');
    Eula.Add('');
    Eula.Add('        	7.2.3	you must immediately uninstall the Software and destroy');
    Eula.Add('                	all copies of the Software in your possession and all its');
    Eula.Add('                	component parts.');
    Eula.Add('');
    Eula.Add('');
    Eula.Add('8	Miscellaneous');
    Eula.Add('');
    Eula.Add('Entire Agreement');
    Eula.Add('');
    Eula.Add('8.1	This Agreement contains everything the parties have agreed in');
    Eula.Add('        	relation to the subject matter it deals with. No party can rely on');
    Eula.Add('        	an earlier written document or anything said or done by or on');
    Eula.Add('        	behalf of another party before this agreement was executed.');
    Eula.Add(' ');
    Eula.Add('Variation');
    Eula.Add('');
    Eula.Add('8.2	No variation of this agreement will be of any force or effect');
    Eula.Add('        	unless it is in writing and signed by each party to this agreement.');
    Eula.Add('');
    Eula.Add('Privity of contract');
    Eula.Add('');
    Eula.Add('8.3	A party who is not you or MYOB BankLink shall have no right to enforce');
    Eula.Add('        	any term under this Agreement whether under the Contracts (Privity) Act');
    Eula.Add('        	1982 (if you acquired this Software in New Zealand) or any other local');
    Eula.Add('        	Act or provision. This clause does not affect any right or remedy of');
    Eula.Add('        	any person which exists, or is available, other than pursuant to the');
    Eula.Add('        	relevant Act.');
    Eula.Add('');
    Eula.Add('Governing law');
    Eula.Add('');
    Eula.Add('8.4	If you acquired this Software in Australia, this Agreement and any');
    Eula.Add('        	dispute or non-contractual obligation arising out of or in');
    Eula.Add('        	connection with it shall be governed by and construed in');
    Eula.Add('        	accordance with the laws of Victoria, and each party hereby');
    Eula.Add('        	submits to the exclusive jurisdiction of the courts of Victoria over any');
    Eula.Add('        	dispute arising out of or in connection with this Agreement.');
    Eula.Add('');
    Eula.Add('8.5	If you acquired this Software in New Zealand, this Agreement and');
    Eula.Add('        	any dispute or non-contractual obligation arising out of or in');
    Eula.Add('        	connection with it shall be governed by and construed in');
    Eula.Add('        	accordance with the laws of New Zealand, and each party hereby');
    Eula.Add('        	submits to the exclusive jurisdiction of the courts of New Zealand');
    Eula.Add('        	over any dispute arising out of or in connection with this');
    Eula.Add('        	Agreement.');
    Eula.Add('');
    Eula.Add('');
    Eula.Add('9	Privacy and Personal Information');
    Eula.Add('');
    Eula.Add('9.1	MYOB BankLink (together with its related MYOB Group companies)');
    Eula.Add('        	collects, discloses and uses your personal information to provide');
    Eula.Add('        	you with the Software and associated support, respond to your');
    Eula.Add('        	enquiries or feedback and to promote the Software and other products');
    Eula.Add('        	and services offered by MYOB BankLink and associated third parties.');
    Eula.Add('        	MYOB BankLink may collect personal information from you, from public');
    Eula.Add('        	sources such as social media websites, or from third parties that');
    Eula.Add('        	provide MYOB BankLink with marketing leads.');
    Eula.Add('');
    Eula.Add('9.2	To do these things, MYOB BankLink may provide your personal information');
    Eula.Add('        	to its related companies and to service providers that it outsources');
    Eula.Add('        	functions to. These entities may be located in Australia, New Zealand,');
    Eula.Add('        	Singapore, India, Malaysia, the Philippines, the United States or other');
    Eula.Add('        	countries. If you do not provide your personal information, it may');
    Eula.Add('        	affect MYOB BankLink’s ability to do business with you.');
    Eula.Add('');
    Eula.Add('        	You consent to MYOB BankLink collecting, using and disclosing your ');
    Eula.Add('        	information for the purposes set out above.');
    Eula.Add('');
    Eula.Add('9.3	If you acquired this Software in Australia:');
    Eula.Add('');
    Eula.Add('        	You can ask MYOB BankLink not to use your information to promote');
    Eula.Add('        	the Software and other products and services by following the');
    Eula.Add('        	process outlined in the MYOB Group Privacy Policy');
    Eula.Add('        	(www.myob.com/privacy).');
    Eula.Add('');
    Eula.Add('        	The MYOB Group Privacy Policy contains information on how to:');
    Eula.Add('');
    Eula.Add('        	(a)	update your preferences about the marketing and promotional');
    Eula.Add('        	  	material that MYOB BankLink sends to you;');
    Eula.Add('');
    Eula.Add('        	(b)	request access to and seek correction of the personal ');
    Eula.Add('        	  	information we hold about you;');
    Eula.Add('');
    Eula.Add('        	(c)	make a privacy complaint; and');
    Eula.Add('');
    Eula.Add('        	(d)	how we will deal with your complaint.');
    Eula.Add('');
    Eula.Add('        	You can contact MYOB BankLink about your privacy by email at');
    Eula.Add('        	privacy_officer@myob.com.au, or by post at "Privacy Officer",');
    Eula.Add('        	MYOB BankLink, PO Box 371, Blackburn, Victoria 3130.');
    Eula.Add('');
    Eula.Add('9.4	If you acquired this Software in New Zealand: ');
    Eula.Add('');
    Eula.Add('        	You can ask MYOB BankLink not to use your information to promote');
    Eula.Add('        	products and services by contacting the Privacy Officer using');
    Eula.Add('        	the details outlined below. The MYOB Group Privacy Policy for');
    Eula.Add('        	New Zealand is located at www.myob.co.nz/privacy.');
    Eula.Add('');
    Eula.Add('        	You can contact MYOB BankLink about your privacy by email at');
    Eula.Add('        	privacy_officer@myob.co.nz, or by post at “Privacy Officer”');
    Eula.Add('        	MYOB BankLink, C/- Quigg Partners, Level 7, 36 Brandon Street,');
    Eula.Add('        	Wellington 6011.');
    Eula.Add('');
    Eula.Add('9.5	You warrant that you will not provide any personal information of your');
    Eula.Add('        	clients to MYOB BankLink unless you:');
    Eula.Add('');
    Eula.Add('        	(a)	have the prior consent of those clients to the disclosure; and');
    Eula.Add('');
    Eula.Add('        	(b)	have provided the clients with a copy of the relevant');
    Eula.Add('        	  	MYOB Group Privacy Policy and that they have accepted and');
    Eula.Add('        	  	consented to the collection, storage, use and disclosure of');
    Eula.Add('        	  	personal information as set out in the relevant Privacy Policy.');
    Eula.Add('');
    Eula.Add('9.6	You acknowledge, agree and further warrant that you will collect, store,');
    Eula.Add('        	use and disclose the personal information of any individual that may be');
    Eula.Add('        	provided to you by MYOB BankLink in accordance with the MYOB Group');
    Eula.Add('        	Privacy Policy that is relevant to your jurisdiction.');

    mmoEULA.Lines := Eula;
  finally
    FreeAndNil(Eula);
  end;
end;

//------------------------------------------------------------------------------
procedure TDlgLicense.SetAbout(Value: Boolean);
begin
  if Value then
  begin
    btnYes.Visible := False;
    lRead.Visible := False;
    lAccept.Visible := False;
    btnNo.Caption := '&OK';
  end;
end;

end.
