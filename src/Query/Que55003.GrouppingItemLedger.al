query 55003 "Groupping Item Ledger"
{
    Caption = 'Groupping Item Ledger';
    QueryType = Normal;

    elements
    {
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            column(DocumentNo; "Document No.")
            {
            }

            column(CostAmountExpected; "Cost Amount (Expected)")
            {
                Method = Sum;
            }
            column(CostAmountActual; "Cost Amount (Actual)")
            {
                Method = Sum;
            }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }
            column(SalesAmountExpected; "Sales Amount (Expected)")
            {
                Method = Sum;
            }
            column(SalesAmountActual; "Sales Amount (Actual)")
            {
                Method = Sum;
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}
