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
    actions
    {
        addfirst(processing)
        {
            action(UpdateCompletelyStatus)
            {

                ApplicationArea = all;
                Caption = 'Update Completely Status';
                Image = UpdateShipment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    SalesReceiptLine: Record "Sales Line";
                begin
                    SalesReceiptLine.reset();
                    SalesReceiptLine.SetFilter(Quantity, '<>%1', 0);
                    SalesReceiptLine.SetRange("Outstanding Quantity", 0);
                    if SalesReceiptLine.FindSet() then
                        repeat
                            SalesReceiptLine."Completely Shipped" := true;
                            SalesReceiptLine.Modify();
                        until SalesReceiptLine.Next() = 0;
                end;
            }
        }
    }
}
