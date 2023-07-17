tableextension 66002 "GMM T Sales Line" extends "Sales Line"
{
    fields
    {
        field(55000; "GMM Order Date"; Date)
        {
            Caption = 'Order Date';
            DataClassification = CustomerContent;
        }
        field(55001; "GMM External Doc No."; text[35])
        {
            Caption = 'External Doc No.';
            DataClassification = CustomerContent;
        }

        field(55002; "GMM Bill Doc No."; code[30])
        {
            Caption = 'Bill Doc No.';
            DataClassification = CustomerContent;
        }
        field(55003; "GMM Ship to Code"; code[30])
        {
            Caption = 'Ship to Code';
            DataClassification = CustomerContent;
        }
        field(55004; "GMM Ship to Name"; text[100])
        {
            Caption = 'Ship to Name';
            DataClassification = CustomerContent;
        }
        field(55005; "GMM Trp. Plan Date"; Date)
        {
            Caption = 'Trp. Plan Date';
            DataClassification = CustomerContent;
        }
        field(55006; "GMM Status"; code[10])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(55007; "GMM GM"; code[10])
        {
            Caption = 'GM';
            DataClassification = CustomerContent;
        }
        field(55008; "GMM Sold-to-pt"; code[20])
        {
            Caption = 'Sold-to-pt';
            DataClassification = CustomerContent;
        }
        field(55009; "GMM Name Sold-to-pt"; text[100])
        {
            Caption = 'Name Sold-to-pt';
            DataClassification = CustomerContent;
        }
        field(55010; "GMM Route"; code[20])
        {
            Caption = 'Route';
            DataClassification = CustomerContent;
        }
        field(55011; "GMM Address"; text[250])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(55012; "GMM Phone No."; text[100])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(55013; "GMM Posted Bill Date"; Date)
        {
            Caption = 'Posted Bill Date';
            DataClassification = CustomerContent;
        }
    }
}
