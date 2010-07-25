unit VATConst;

interface

Const
  SBox1 = 'VAT due in this period on sales and other outputs.';
  SBox2 = 'VAT due in this period on acquisitions from other ' +
          'EC Member States.';
  SBox3 = 'Total VAT due (the sum of boxes 1 and 2).';
  SBox4 = 'VAT reclaimed in this period on purchases and ' +
          'other inputs (including acquisitions from the EC).';
  SBox5 = 'Net VAT to be paid to Customs or reclaimed ' +
          'by you. (Difference between boxes 3 and 4).';
  SBox6 = 'Total value of sales and all other outputs '+
          'excluding any VAT. This includes the Box 8 figure.';
  SBox7 = 'Total value of purchases and all other inputs '+
          'excluding any VAT. This includes the Box 9 figure.';
  SBox8 = 'Total value of all supplies of goods and related costs, excluding any VAT, to other EC member states.';
  SBox9 = 'Total value of acquisitions of goods and related costs, excluding any VAT, from other EC member states.';

  SBox5ToPay  = 'Net VAT to be paid to Customs. (Difference between boxes 3 and 4).';
  SBox5Refund = 'Net VAT to be reclaimed from Customs. (Difference between boxes 3 and 4).';

implementation

end.
