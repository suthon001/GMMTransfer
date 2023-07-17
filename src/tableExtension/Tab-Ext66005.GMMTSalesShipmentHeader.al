tableextension 66005 "GMM T Sales Shipment Header" extends "Sales Shipment Header"
{
    fields
    {
        field(88898; "Have Sales Order"; Boolean)
        {
            Caption = 'Have Sales Order';
            FieldClass = FlowField;
            CalcFormula = exist("Sales Header" where("No." = field("Order No.")));
        }
    }
}
