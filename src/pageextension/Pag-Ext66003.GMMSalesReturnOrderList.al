pageextension 66003 "GMM Sales Return Order List" extends "Sales Return Order List"
{
    layout
    {
        modify("Completely Shipped")
        {
            Visible = true;
        }
        movelast(Control1; "Completely Shipped")

        addafter("Completely Shipped")
        {
            field("Qty. Rcd. Not Invoiced"; rec."Qty. Rcd. Not Invoiced")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the value of the Total Quantity field.';
            }
            field("Total Qty."; rec."Total Qty.")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the value of the Total Quantity field.';
            }
        }
    }
}
