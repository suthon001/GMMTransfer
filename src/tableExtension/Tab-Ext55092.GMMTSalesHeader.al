tableextension 66004 "GMM T Sales Header" extends "Sales Header"
{
    fields
    {
        field(55000; "Qty. Not Invoiced"; Decimal)
        {
            Caption = 'Qty. Not Invoiced';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."Qty. Shipped Not Invoiced" where("Document Type" = field("Document Type"), "Document No." = field("No.")));
        }
        field(55001; "Qty. Rcd. Not Invoiced"; Decimal)
        {
            Caption = 'Qty. Not Invoiced';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."Return Rcd. Not Invd." where("Document Type" = field("Document Type"), "Document No." = field("No.")));
        }
        field(55002; "Total Qty."; Decimal)
        {
            Caption = 'Total Qty.';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line".Quantity where("Document Type" = field("Document Type"), "Document No." = field("No.")));
        }
    }
}
