unit GraphDefs;

interface

type
   GRAPH_LIST_TYPE = (GRAPH_TRADING_SALES,
                      GRAPH_TRADING_PAYMENTS,
                      GRAPH_TRADING_RESULTS,
                      GRAPH_BANK_BALANCE,
                      GRAPH_SUMMARY,
                      Graph_Last);

const
   GRAPH_LIST_NAMES : Array[GRAPH_TRADING_SALES..GRAPH_LAST] of String =
                       ('Sales',
                        'Payments',
                        'Trading Results',
                        'Total Bank Balance',
                        'One Page Summary',
                        'ZZZ');



implementation

end.
