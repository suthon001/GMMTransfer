query 55003 "Groupping Value Entry"
{
    Caption = 'Groupping Value Entry';
    QueryType = Normal;

    elements
    {
        dataitem(ValueEntry; "Value Entry")
        {
            column(DocumentNo; "Document No.")
            {
            }
            column(ItemChargeNo; "Item Charge No.")
            {
            }
            column(RefItemLedgerDocNo; "Ref. Item Ledger Doc No.")
            {
            }
            column(DocumentType; "Document Type")
            {
            }
            column(Sales_Amount__Actual_; "Sales Amount (Actual)")
            {
                Method = Sum;
            }
            column(Sales_Amount__Expected_; "Sales Amount (Expected)")
            {
                Method = Sum;
            }
            column(Cost_Amount__Actual_; "Cost Amount (Actual)")
            {
                Method = Sum;
            }
            column(Cost_Amount__Expected_; "Cost Amount (Expected)")
            {
                Method = Sum;
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}
