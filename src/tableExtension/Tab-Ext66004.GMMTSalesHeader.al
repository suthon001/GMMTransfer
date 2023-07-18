tableextension 66004 "GMM T Sales Header" extends "Sales Header"
{
    fields
    {
        field(66000; "Qty. Not Invoiced"; Decimal)
        {
            Caption = 'Qty. Not Invoiced';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."Qty. Shipped Not Invoiced" where("Document Type" = field("Document Type"), "Document No." = field("No.")));
        }
        field(66001; "Qty. Rcd. Not Invoiced"; Decimal)
        {
            Caption = 'Qty. Not Invoiced';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."Return Rcd. Not Invd." where("Document Type" = field("Document Type"), "Document No." = field("No.")));
        }
        field(66002; "Total Qty."; Decimal)
        {
            Caption = 'Total Qty.';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line".Quantity where("Document Type" = field("Document Type"), "Document No." = field("No.")));
        }
        field(66003; "GMM Completely Shipment"; Boolean)
        {
            Caption = 'GMM Completely Shipment';
            DataClassification = CustomerContent;
        }
        field(66004; "GMM From Ship"; Boolean)
        {
            Caption = 'GMM From Ship';
            DataClassification = CustomerContent;
        }
        field(66005; "GMM Qty. Not Invoiced"; Decimal)
        {
            Caption = 'Qty. Not Invoiced';
            DataClassification = CustomerContent;

        }
        field(66006; "GMM Qty. Rcd. Not Invoiced"; Decimal)
        {
            Caption = 'Qty. Not Invoiced';
            DataClassification = CustomerContent;

        }
        field(66007; "GMM Total Qty."; Decimal)
        {
            Caption = 'Total Qty.';
            DataClassification = CustomerContent;

        }
    }
}
