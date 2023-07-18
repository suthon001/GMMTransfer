tableextension 66003 "GMM T Value Entry" extends "Value Entry"
{
    fields
    {
        field(66000; "Ref. Item Ledger Doc No."; Code[30])
        {
            Caption = 'Ref. Item Ledger Doc No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Item Ledger Entry"."Document No." where("Entry No." = field("Item Ledger Entry No.")));
        }
    }
}
