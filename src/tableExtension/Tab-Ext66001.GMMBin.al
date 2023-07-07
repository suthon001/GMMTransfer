tableextension 66001 "GMM Bin" extends Bin
{
    fields
    {
        field(66000; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(66001; "Phone No."; Text[50])
        {
            Caption = 'Phone No.';
            DataClassification = ToBeClassified;
        }
    }
}
