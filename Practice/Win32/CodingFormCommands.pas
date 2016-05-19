unit CodingFormCommands;
//------------------------------------------------------------------------------
{
   Title:       Coding Form Commands

   Description: Holds list of constants for coding form external commands

   Remarks:

   Author:      Matthew Hopkins Nov 2001

}
//------------------------------------------------------------------------------


interface

type

  TExternalCmd = ( //used to communicate external commands into this program -andy
                  ecChart,
                  ecDissect,
                  ecPayee,
                  ecMemorise,
                  ecSortDate,
                  ecSortChq,
                  ecSortRef,
                  ecSortAcct,
                  ecSortValue,
                  ecSortNarr,
                  ecSortOther,
                  ecSortParticulars,
                  ecSortStatementDetails,
                  ecSortEntryType,
                  ecSortAnalysis,
                  ecSortCodedBy,
                  ecSortPayee,
                  ecSortForexAmount,
                  ecSortForexRate,
                  ecSortAltChartCode,
                  ecGoto,
                  ecGotoNote,
                  ecRepeat,
                  ecFind,
                  ecViewAll,
                  ecViewUncoded,
                  ecViewNotes,
                  ecViewNoNotes,
                  ecViewUnReadNotes,
                  ecEditAllCol,
                  ecEditAcctCol,
                  ecAddOutChq,
                  ecAddOutDep,
                  ecAddOutWith,
                  ecMatch,
                  ecAddInitChq,
                  ecAddInitWith,
                  ecAddInitDep,
                  ecSetFlags,
                  ecClearFlags,
                  ecRecalcGST,
                  ecSortPres,

                  ecSetColWidths,
                  ecReloadTrans,
                  ecReCodeTrans,
                  ecRefreshTable,
                  ecConfigureCols,
                  ecRestoreCols,
                  ecQuit,

                  ecRecombine,
                  ecSuper,
                  ecUpdatePopups,

                  ecSortAccountDesc,
                  ecSortPayeeName,
                  ecSortGSTClass,
                  ecSortGSTAmount,
                  ecSortQuantity ,
                  ecSortDocumentTitle,
                  ecSortJobs,
                  ecSortJobName,
                  ecQueryUncoded,
                  ecLookupJobs,

                  ecNewJournal,
                  ecSortTransId,
                  ecSortSentToAndAcc,

                  ecRecommendedMems,
                  ecSuggestedMemCount,
                  ecRefreshSuggestedMem ,
                  ecRefreshMYOBLink
                  );

implementation

end.
