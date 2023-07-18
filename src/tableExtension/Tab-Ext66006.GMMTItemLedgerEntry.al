tableextension 66006 "GMM T Item Ledger Entry" extends "Item Ledger Entry"
{
    fields
    {
        field(66000; "GMM Return Order No."; Code[30])
        {
            Caption = 'GMM Return Order No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Return Receipt Header"."Return Order No." where("No." = field("Document No.")));
        }
        field(66001; "GMM CN No."; Code[30])
        {
            Caption = 'GMM CN No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Value Entry"."Document No." where("Document Type" = const("Sales Credit Memo"), "Item Ledger Entry No." = field("Entry No.")));
        }
        field(66002; "GMM Sales Order No."; Code[30])
        {
            Caption = 'GMM Sales Order No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Shipment Header"."Order No." where("No." = field("Document No.")));
        }
        field(66003; "GMM Invoice No."; Code[30])
        {
            Caption = 'GMM CN No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Value Entry"."Document No." where("Document Type" = const("Sales Invoice"), "Item Ledger Entry No." = field("Entry No.")));
        }
    }
}
