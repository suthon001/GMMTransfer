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
        field(55003; "GMM Completely Shipment"; Boolean)
        {
            Caption = 'GMM Completely Shipment';
            DataClassification = CustomerContent;
        }
        field(50004; "GMM From Ship"; Boolean)
        {
            Caption = 'GMM From Ship';
            DataClassification = CustomerContent;
        }
        field(55005; "GMM Qty. Not Invoiced"; Decimal)
        {
            Caption = 'Qty. Not Invoiced';
            DataClassification = CustomerContent;

        }
        field(55006; "GMM Qty. Rcd. Not Invoiced"; Decimal)
        {
            Caption = 'Qty. Not Invoiced';
            DataClassification = CustomerContent;

        }
        field(55007; "GMM Total Qty."; Decimal)
        {
            Caption = 'Total Qty.';
            DataClassification = CustomerContent;

        }
    }
}
