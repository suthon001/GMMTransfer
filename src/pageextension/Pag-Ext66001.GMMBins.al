pageextension 66001 "GMM Bins2" extends Bins
{
    layout
    {
        addafter(Description)
        {
            field(Name; Name)
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the value of the Name field.';
            }
        }
        addbefore(Empty)
        {
            field("Phone No."; "Phone No.")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the value of the Phone No. field.';
            }
        }
    }

}
