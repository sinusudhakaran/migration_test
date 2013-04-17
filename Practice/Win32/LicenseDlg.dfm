object DlgLicense: TDlgLicense
  Left = 367
  Top = 332
  BorderStyle = bsDialog
  Caption = 'Licence Agreement'
  ClientHeight = 317
  ClientWidth = 536
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lRead: TLabel
    AlignWithMargins = True
    Left = 16
    Top = 6
    Width = 504
    Height = 42
    Margins.Left = 16
    Margins.Top = 6
    Margins.Right = 16
    Align = alTop
    AutoSize = False
    Caption = 
      'Please read the following Licence Agreement. Use the scroll bar ' +
      'or press the Page Down key to view the rest of the agreement.'
    WordWrap = True
    ExplicitTop = 8
    ExplicitWidth = 505
  end
  object lAccept: TLabel
    AlignWithMargins = True
    Left = 16
    Top = 229
    Width = 504
    Height = 41
    Margins.Left = 16
    Margins.Right = 16
    Margins.Bottom = 6
    Align = alBottom
    AutoSize = False
    Caption = 
      'Do you accept all the terms of the preceding Licence Agreement? ' +
      'If you choose No, you will not be able to login. To use BankLink' +
      ' Practice you must accept this agreement.'
    WordWrap = True
    ExplicitTop = 224
    ExplicitWidth = 509
  end
  object mmoEULA: TMemo
    AlignWithMargins = True
    Left = 16
    Top = 54
    Width = 504
    Height = 169
    Margins.Left = 16
    Margins.Right = 16
    Align = alClient
    Lines.Strings = (
      'Software End-User Licence Agreement'
      ''
      
        'IMPORTANT NOTICE PLEASE READ CAREFULLY BEFORE INSTALLING OR USIN' +
        'G THE SOFTWARE:'
      ''
      '1       Agreement'
      ''
      
        'This Software End-User Licence Agreement ('#39'Agreement'#39') is betwee' +
        'n you and'
      'Media Transfer Services Limited ('#8216'BankLink'#8217').'
      ''
      
        'This computer software, together with any supporting documentati' +
        'on and any'
      
        'modifications, amendments or updates made or authorised by BankL' +
        'ink'
      
        '('#8216'the Software'#8217'), is owned by BankLink.  Provided you are a regi' +
        'stered user'
      
        'of BankLink'#39's services and your copy of the Software has been la' +
        'wfully'
      
        'obtained, you are authorised to use the Software in accordance w' +
        'ith this'
      'Agreement.'
      ''
      
        'By proceeding to access, download, install, store, load, registe' +
        'r, execute'
      
        'and/or display (individually or collectively, '#8216'Use'#8217') the Softwar' +
        'e, you agree'
      
        'to be bound by the terms of this Agreement.  If your copy of or ' +
        'access to the'
      
        'Software has not been legally obtained or you do not agree to th' +
        'e terms of'
      
        'this Agreement, BankLink is not willing to licence the Software ' +
        'to you and'
      'you must not Use the Software.'
      ''
      ''
      '2       Grant of licence'
      ''
      
        'In consideration of you agreeing to abide by the terms of this A' +
        'greement and'
      
        'the benefit you and others derive from the Software, BankLink he' +
        'reby grants'
      
        'you a non-exclusive, non-transferable licence to Use the Softwar' +
        'e in'
      
        'accordance with this Agreement.  The licence will be perpetual u' +
        'nless'
      
        'terminated in accordance with clause 8.  You will be issued with' +
        ' a user name'
      'and password which you must keep secure.'
      ''
      
        'BankLink may sell, sub-licence, assign, transfer, charge or lend' +
        ' the Software'
      
        'to any other person or entity or otherwise dispose of the rights' +
        ' or'
      
        'obligations under this Agreement at any time without your consen' +
        't. BankLink'
      
        'may at any time restrict your access to the Software to "read on' +
        'ly" and'
      'withhold rights to edit or input information.'
      ''
      ''
      '3       Limitations on Use'
      ''
      
        'The Software licence is personal to you, you cannot sell, sub-li' +
        'cence,'
      
        'assign, transfer or lend the Software to any other person or ent' +
        'ity or'
      
        'otherwise dispose of the rights or obligations under this Agreem' +
        'ent without'
      
        'the written consent of BankLink. Except as otherwise permitted a' +
        't law you'
      
        'cannot reverse assemble or reverse compile or directly or indire' +
        'ctly allow'
      
        'or cause a third party to reverse assemble or reverse compile th' +
        'e whole or'
      'any part of the Software.'
      ''
      ''
      '4       Title'
      ''
      
        'All title and intellectual property rights in the Software remai' +
        'n with'
      
        'BankLink (or its licensors).  You acknowledge that rights in the' +
        ' Software'
      
        'are licensed (not sold) to you, and that you have no rights in, ' +
        'or to, the'
      
        'Software other than the right to Use them in accordance with the' +
        ' terms of'
      
        'this Agreement. You acknowledge that you have no right to have a' +
        'ccess to the'
      
        'Software in source code form or in unlocked coding or with comme' +
        'nts. You will'
      
        'notify BankLink as soon as you become aware of any infringement,' +
        ' suspected'
      
        'infringement or alleged infringement of BankLink'#8217's intellectual ' +
        'property'
      'rights in the Software.'
      ''
      ''
      '5       BankLink warranties'
      ''
      
        'Except as otherwise agreed, BankLink is not obliged to support t' +
        'he Software,'
      
        'whether by providing advice, training, error-correction, modific' +
        'ation,'
      'maintenance, new releases or enhancements or otherwise.'
      ''
      
        'To the extent permitted by law, BankLink excludes and disclaims ' +
        'all and any'
      
        'guarantees and/or warranties whether express, implied, statutory' +
        ' or otherwise'
      
        'in respect of the Software and in particular, to the extent that' +
        ' they are'
      
        'applicable, expressly excludes the provisions of the Sale of Goo' +
        'ds Act 1979'
      
        'and the Supply of Goods and Services Act 1982 (if you acquired t' +
        'his Software'
      
        'in the UK) or the New Zealand Consumer Guarantees Act 1993 pursu' +
        'ant to'
      
        'clause 43(2) thereof and the provisions of the New Zealand Sale ' +
        'of Goods Act'
      
        '1908 pursuant to clause 56 thereof (if you acquired this Softwar' +
        'e in'
      
        'New Zealand).  Where the Australian Consumer Law ('#8216'ACL'#8217') applies' +
        ', nothing in'
      
        'this agreement shall be taken to exclude, restrict or modify any' +
        ' mandatory'
      'condition, warranty, guarantee or remedy under the ACL.'
      ''
      
        'You acknowledge that BankLink does not warrant or promise that t' +
        'he Software'
      
        'will meet your requirements and that you have solely exercised a' +
        'nd relied'
      
        'upon your own skill and judgment in determining whether the Soft' +
        'ware meets'
      
        'your particular requirements, and have not relied on any stateme' +
        'nt or'
      
        'representation by or on behalf of BankLink (unless made fraudule' +
        'ntly).'
      
        'BankLink is providing this Software to you '#39'AS IS'#39' and you ackno' +
        'wledge that'
      
        'risk of loss or of damage to your computer system or data at all' +
        ' times'
      'remains with you.'
      ''
      
        'Other than as required pursuant to mandatory law, BankLink does ' +
        'not warrant'
      'that:'
      
        #8226'     Any of the data, whether provided by or on behalf of BankL' +
        'ink or'
      
        '      another person, and received by you for use with the Softw' +
        'are will be'
      '      accurate or virus free;'
      
        #8226'     The Software (including any embedded tax formula or releas' +
        'e notes on'
      '      updates of legislation) is free from error or defects;'
      #8226'     The Software will operate without interruption or errors;'
      
        '      Any output, reports or results produced by the Software wi' +
        'll be'
      '      accurate or error free; or'
      
        #8226'     That the Software will not affect the operation of other i' +
        'nstalled'
      '      applications.'
      ''
      ''
      '6.'#9'Your warranties and indemnity'
      ''
      'You warrant or promise to BankLink that:'
      ''
      
        #8226'     You have the relevant authority or consent to provide or o' +
        'therwise'
      
        '      upload data or information (including personal information' +
        ' as defined'
      
        '      under the New Zealand Privacy Act 1993, UK Data Protection' +
        ' Act 1998 or'
      
        '      under the Australian Privacy Act 1988, as the case may be)' +
        ' to'
      
        '      BankLink'#39's server using the Software and the provision or ' +
        'disclosure'
      
        '      of such information on BankLink'#39's server will not constitu' +
        'te a breach'
      
        '      of any agreement or arrangement that you are a party to, o' +
        'r any'
      '      applicable law; and'
      
        #8226'     You will ensure that the data or information provided to, ' +
        'or otherwise'
      
        '      uploaded onto, BankLink'#39's server is true, correct and up t' +
        'o date.'
      ''
      
        'You agree to indemnify BankLink and keep BankLink indemnified fr' +
        'om and'
      
        'against any loss or damage that BankLink may suffer as a result ' +
        'of your'
      'breach of any of the warranties in this clause 6.'
      ''
      ''
      '7       Liability'
      ''
      
        'If you acquired the Software in the UK, except in respect of lia' +
        'bility which'
      
        'cannot be limited, BankLink will not be liable to you whether ar' +
        'ising in'
      
        'contract, tort (including negligence or breach of statutory duty' +
        '),'
      
        'misrepresentation or otherwise for any loss or damage of any kin' +
        'd arising out'
      
        'of or in connection with this Agreement including, without limit' +
        'ation:'
      ''
      
        #8226'     Any indirect or consequential loss or damage of any kind; ' +
        'or'
      
        #8226'     Any loss of income, loss of profits, loss of savings, loss' +
        ' of goodwill,'
      
        '      loss of contracts, business interruption, costs of cover o' +
        'r loss of'
      
        '      data arising from your Use of or inability to Use the Soft' +
        'ware or from'
      '      errors of deficiencies in the Software.'
      ''
      
        'Except in respect of liability which cannot be limited, this lim' +
        'itation will'
      
        'apply even if BankLink has been advised of the possibility of su' +
        'ch damages.'
      ''
      
        'Except in respect of liability which cannot be limited the liabi' +
        'lity of'
      
        'BankLink for any loss arising as a result of or in relation to t' +
        'he supply by'
      
        'BankLink of the Software, including any economic or consequentia' +
        'l loss which'
      
        'may be sustained or incurred, shall be limited to (at BankLink'#39's' +
        ' option):'
      ''
      
        #8226'     The replacement of the Software or the supply of equivalen' +
        't software;'
      #8226'     The repair of the Software;'
      
        #8226'     The payment of the cost of replacing the Software or acqui' +
        'ring'
      '      equivalent Software; or'
      
        #8226'     The payment of the cost of having the Software replaced by' +
        ' a third'
      '      party.'
      ''
      
        'Nothing in this Agreement shall limit or exclude the liability o' +
        'f BankLink'
      
        'for death or personal injury resulting from BankLink'#39's negligenc' +
        'e, fraud or'
      'fraudulent misrepresentation.'
      ''
      
        'If you acquired this Software in Australia or NZ, BankLink will ' +
        'not be liable'
      
        'to you for any loss or damage (including, without limitation, co' +
        'nsequential'
      
        'loss or damage) suffered by you whether arising directly or indi' +
        'rectly from'
      
        'the Use of the Software or any data provided by or on behalf of ' +
        'BankLink'
      
        'under this agreement or from any failure or omission on the part' +
        ' of BankLink'
      'or otherwise.'
      ''
      
        'In no event will BankLink be liable for any remote, indirect, co' +
        'nsequential,'
      
        'special or incidental damages, including without limitation, dam' +
        'ages'
      
        'resulting from loss of any data, loss of profits or business int' +
        'erruption,'
      
        'or cost of cover.  This limitation will apply even if BankLink h' +
        'as been'
      'advised of the possibility of such damages.'
      ''
      
        'Where the Australian Trade Practices Act 1974 applies, then the ' +
        'liability of'
      
        'BankLink for any loss arising as a result of or in relation to t' +
        'he supply by'
      
        'BankLink of the Software, including any economic or consequentia' +
        'l loss which'
      'may be sustained or incurred, shall be limited to:'
      ''
      
        '(a) The replacement of the Software or the supply of equivalent ' +
        'Software;'
      '(b) The repair of the Software;'
      
        '(c) The payment of the cost of replacing the Software or acquiri' +
        'ng equivalent'
      '    Software; or'
      
        '(d) The payment of the cost of having the Software replaced by a' +
        ' third party.'
      ''
      ''
      '8       Termination'
      ''
      
        'Without prejudice to any other rights, BankLink may terminate th' +
        'is Agreement'
      
        'by giving not less than one month'#39's notice to you. Without preju' +
        'dice to'
      
        'BankLink'#39's other rights or remedies, if you fail to comply with ' +
        'the terms and'
      
        'conditions of this Agreement, or if you become bankrupt or insol' +
        'vent (or'
      
        'suffer any similar circumstances anywhere in the world) BankLink' +
        ' may'
      'terminate this Agreement immediately.'
      ''
      'Upon termination or expiry of this Agreement for any reason: '
      ''
      
        #8226'     All rights granted to you under this Agreement shall cease' +
        ';'
      
        #8226'     You must immediately cease all activities authorised by th' +
        'is Agreement; and'
      
        #8226'     You must immediately destroy all copies of the Software in' +
        ' your'
      '      possession and all its component parts.'
      ''
      ''
      '9       Other agreements'
      ''
      
        'This Agreement may be modified by the terms of another written a' +
        'greement'
      'entered into by you and BankLink.'
      ''
      ''
      '10      Third Parties'
      ''
      
        'No party other than you or BankLink shall have the right to enfo' +
        'rce any term'
      
        'under this Agreement whether under the Contracts (Rights of Thir' +
        'd Parties)'
      
        'Act 1999 (if you acquired this Software in the UK) or the Contra' +
        'cts (Privity)'
      
        'Act 1982 (if you acquired this Software in New Zealand) or any o' +
        'ther local'
      
        'Act or provision.  This clause does not affect any right or reme' +
        'dy of any'
      
        'person which exists, or is available, other than pursuant to the' +
        ' relevant Act.'
      ''
      ''
      '11      Governing law'
      ''
      
        'If you acquired this Software in the UK, this Agreement and any ' +
        'dispute or'
      
        'non-contractual obligation arising out of or in connection with ' +
        'it shall be'
      
        'governed by and construed in accordance with the law of England ' +
        'and Wales and'
      
        'each party hereby submits to the exclusive jurisdiction of the c' +
        'ourts of'
      
        'England and Wales over any dispute arising out of or in connecti' +
        'on with this'
      'Agreement.'
      ''
      
        'If you acquired this Software in Australia, this Agreement and a' +
        'ny dispute'
      
        'or non-contractual obligation arising out of or in connection wi' +
        'th it shall'
      
        'be governed by and construed in accordance with the laws of New ' +
        'South Wales'
      
        'and each party hereby submits to the exclusive jurisdiction of t' +
        'he courts of'
      
        'New South Wales over any dispute arising out of or in connection' +
        ' with this'
      'Agreement.'
      ''
      
        'If you acquired this Software in New Zealand, this Agreement and' +
        ' any dispute'
      
        'or non-contractual obligation arising out of or in connection wi' +
        'th it shall'
      
        'be governed by and construed in accordance with the laws of New ' +
        'Zealand and'
      
        'each party hereby submits to the exclusive jurisdiction of the c' +
        'ourts of New'
      
        'Zealand over any dispute arising out of or in connection with th' +
        'is Agreement.'
      ''
      ''
      '12      Collection of email address and personal information'
      ''
      
        'You agree that BankLink is free to collect and record personal i' +
        'nformation'
      
        'provided by you to BankLink, including, without limitation, the ' +
        'email address'
      
        'which you supply as part of the registration process for this So' +
        'ftware for'
      
        'the purpose of monitoring your Use of this Software.  You acknow' +
        'ledge that'
      
        'BankLink is a company registered and operated in New Zealand and' +
        ' as such any'
      
        'personal information collected and recorded by BankLink may be s' +
        'tored and'
      
        'used outside of the European Economic Area.  You agree that the ' +
        'collection,'
      
        'access, use or storage of your and your employees'#39' personal info' +
        'rmation, if'
      
        'any, will be governed by BankLink'#39's privacy policy which is avai' +
        'lable on, and'
      
        'can be accessed from, BankLink'#39's website. The Privacy Policy for' +
        ' New Zealand'
      'is located at http://www.banklink.co.nz/index.php/privacy'
      ',the Privacy Policy for Australia is located at'
      
        'http://www.banklink.com.au/index.php/privacy and the Privacy Pol' +
        'icy for the'
      
        'United Kingdom is located at http://www.banklink.co.uk/index.php' +
        '/privacy')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
  end
  object pBtn: TPanel
    Left = 0
    Top = 276
    Width = 536
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnNo: TButton
      Left = 448
      Top = 8
      Width = 75
      Height = 25
      Caption = '&No'
      ModalResult = 7
      TabOrder = 0
    end
    object btnYes: TButton
      Left = 360
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Yes'
      ModalResult = 6
      TabOrder = 1
    end
  end
end
