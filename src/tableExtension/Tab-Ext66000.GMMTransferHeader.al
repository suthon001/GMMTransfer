tableextension 66000 "GMM Transfer Header" extends "Transfer Header"
{
    fields
    {
        field(66000; "Transfer from Bin Code"; Code[10])
        {
            Caption = 'Transfer-from Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code where("Location Code" = field("Transfer-from Code"));
            trigger OnValidate()
            var
                ltBin: Record Bin;
                Location: Record Location;
                TransferLine: Record "Transfer Line";
            begin
                if ltBin.GET(rec."Transfer-from Code", "Transfer from Bin Code") then begin
                    rec."Transfer-from Name" := ltBin.Name;
                    rec."Transfer-from Name 2" := ltBin.Description;
                    rec."Transfer-from Address" := ltBin.Address;
                    rec."Transfer-from Address 2" := ltBin."Address 2";
                    rec."Transfer-from City" := ltBin.City;
                    rec."From Phone No." := ltBin."Phone No.";
                    rec."Transfer-from Post Code" := ltBin."Post Code";
                end else begin
                    if not Location.GET("Transfer-from Code") then
                        Location.Init();
                    "Transfer-from Name" := Location.Name;
                    "Transfer-from Name 2" := Location."Name 2";
                    "Transfer-from Address" := Location.Address;
                    "Transfer-from Address 2" := Location."Address 2";
                    "Transfer-from Post Code" := Location."Post Code";
                    "Transfer-from City" := Location.City;
                    "Transfer-from County" := Location.County;
                    "Trsf.-from Country/Region Code" := Location."Country/Region Code";
                    "Transfer-from Contact" := Location.Contact;
                end;

                TransferLine.reset();
                TransferLine.SetRange("Document No.", rec."No.");
                TransferLine.SetFilter("Item No.", '<>%1', '');
                if TransferLine.FindSet() then
                    repeat
                        TransferLine.Validate("Transfer-from Bin Code", "Transfer from Bin Code");
                        TransferLine.Modify();
                    until TransferLine.Next() = 0;
            end;
        }
        field(66001; "Transfer to Bin Code"; Code[10])
        {
            Caption = 'Transfer-to Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code where("Location Code" = field("Transfer-to Code"));
            trigger OnValidate()
            var
                ltBin: Record Bin;
                Location: Record Location;
                TransferLine: Record "Transfer Line";
            begin
                if ltBin.GET(rec."Transfer-to Code", "Transfer to Bin Code") then begin
                    rec."Transfer-to Name" := ltBin.Name;
                    rec."Transfer-to Name 2" := ltBin.Description;
                    rec."Transfer-to Address" := ltBin.Address;
                    rec."Transfer-to Address 2" := ltBin."Address 2";
                    rec."Transfer-to City" := ltBin.City;
                    rec."to Phone No." := ltBin."Phone No.";
                    rec."Transfer-to Post Code" := ltBin."Post Code";
                end else begin
                    if not Location.GET("Transfer-to Code") then
                        Location.Init();
                    "Transfer-to Name" := Location.Name;
                    "Transfer-to Name 2" := Location."Name 2";
                    "Transfer-to Address" := Location.Address;
                    "Transfer-to Address 2" := Location."Address 2";
                    "Transfer-to Post Code" := Location."Post Code";
                    "Transfer-to City" := Location.City;
                    "Transfer-to County" := Location.County;
                    "Trsf.-to Country/Region Code" := Location."Country/Region Code";
                    "Transfer-to Contact" := Location.Contact;
                end;

                TransferLine.reset();
                TransferLine.SetRange("Document No.", rec."No.");
                TransferLine.SetFilter("Item No.", '<>%1', '');
                if TransferLine.FindSet() then
                    repeat
                        TransferLine.Validate("Transfer-to Bin Code", "Transfer to Bin Code");
                        TransferLine.Modify();
                    until TransferLine.Next() = 0;
            end;
        }
        field(66002; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure".Code;
        }
        field(66003; "Item No"; Code[20])
        {
            Caption = 'Item No';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
            Editable = false;
            trigger OnValidate()
            var
                ltItem: Record Item;
            begin
                if not ltItem.get("Item No") then
                    ltItem.Init();
                rec.Description := ltItem.Description;
            end;
        }
        field(66004; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(66005; "Scan Barcode Status"; Option)
        {
            Caption = 'Status';
            OptionMembers = " ",Fail,Pass;
            OptionCaption = ' ,Fail,Pass';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(66006; "Last Qty to Transfer"; Decimal)
        {
            Caption = 'Last Qty to Transfer';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(66007; "Total Quantity"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Transfer Line".Quantity where("Document No." = field("No.")));
        }
        field(66008; "From Phone No."; Text[50])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(66009; "To Phone No."; Text[50])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(66010; "Imported DateTime"; DateTime)
        {
            Caption = 'Imported DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(66011; "By Import"; Boolean)
        {
            Caption = 'By Import';
            DataClassification = CustomerContent;
            Editable = false;

        }
        field(66012; "Order Type"; code[20])
        {
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('ORDER TYPE'));
            DataClassification = CustomerContent;
            Caption = 'Order Type';
            trigger OnValidate()
            var
                DimMgt: Codeunit DimensionManagement;
                DimensionSetEntry: Record "Dimension Set Entry" temporary;
            begin
                DimMgt.GetDimensionSet(DimensionSetEntry, rec."Dimension Set ID");

                DimensionSetEntry.reset();
                DimensionSetEntry.SetRange("Dimension Code", 'ORDER TYPE');
                if DimensionSetEntry.FindFirst() then
                    DimensionSetEntry.Delete();

                if "Order Type" <> '' then begin
                    DimensionSetEntry.Init();
                    DimensionSetEntry."Dimension Set ID" := rec."Dimension Set ID";
                    DimensionSetEntry.validate("Dimension Code", 'ORDER TYPE');
                    DimensionSetEntry.Insert();
                    DimensionSetEntry.Validate("Dimension Value Code", "Order Type");
                    DimensionSetEntry.Modify();
                end;
                DimensionSetEntry.reset();
                rec."Dimension Set ID" := DimMgt.GetDimensionSetID(DimensionSetEntry);
            end;
        }
        field(66013; "DISTRIBUTION CHANNEL"; Code[20])
        {
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('DISTRIBUTION CHANNEL'));
            DataClassification = CustomerContent;
            Caption = 'Distraibution Channel';
            trigger OnValidate()
            var
                DimMgt: Codeunit DimensionManagement;
                DimensionSetEntry: Record "Dimension Set Entry" temporary;
            begin
                DimMgt.GetDimensionSet(DimensionSetEntry, rec."Dimension Set ID");

                DimensionSetEntry.reset();
                DimensionSetEntry.SetRange("Dimension Code", 'DISTRIBUTION CHANNEL');
                if DimensionSetEntry.FindFirst() then
                    DimensionSetEntry.Delete();

                if "DISTRIBUTION CHANNEL" <> '' then begin
                    DimensionSetEntry.Init();
                    DimensionSetEntry."Dimension Set ID" := rec."Dimension Set ID";
                    DimensionSetEntry.validate("Dimension Code", 'DISTRIBUTION CHANNEL');
                    DimensionSetEntry.Insert();
                    DimensionSetEntry.Validate("Dimension Value Code", "DISTRIBUTION CHANNEL");
                    DimensionSetEntry.Modify();
                end;
                DimensionSetEntry.reset();
                rec."Dimension Set ID" := DimMgt.GetDimensionSetID(DimensionSetEntry);
            end;
        }
        modify("Transfer-from Code")
        {
            trigger OnAfterValidate()
            var
                ltBin: Record Bin;
                ltBinCode: code[10];
            begin
                ltBinCode := '';
                ltBin.reset();
                ltBin.SetRange("Location Code", rec."Transfer-from Code");
                ltBin.SetFilter(Code, '<>%1', '');
                if ltBin.FindFirst() then
                    ltBinCode := ltBin.Code;

                rec.Validate("Transfer from Bin Code", ltBinCode);

            end;
        }
        modify("Transfer-To Code")
        {
            trigger OnAfterValidate()
            var
                ltBin: Record Bin;
                ltBinCode: code[10];
            begin
                ltBinCode := '';
                ltBin.reset();
                ltBin.SetRange("Location Code", rec."Transfer-To Code");
                ltBin.SetFilter(Code, '<>%1', '');
                if ltBin.FindFirst() then
                    ltBinCode := ltBin.Code;

                rec.Validate("Transfer To Bin Code", ltBinCode);
            end;
        }
    }


    procedure ScanBarcode(pBarcode: code[50]; pQuantity: Decimal)
    var
        ItemRef: Record "Item Reference";
        ltTransferLine: Record "Transfer Line";
    begin
        if pBarcode = '' then
            exit;
        rec.TestField("Unit of Measure");
        ItemRef.reset();
        ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
        ItemRef.SetRange("Unit of Measure", rec."Unit of Measure");
        ItemRef.SetRange("Reference No.", pBarcode);
        if ItemRef.FindFirst() then begin
            ltTransferLine.reset();
            ltTransferLine.SetRange("Document No.", rec."No.");
            ltTransferLine.SetRange("Item No.", ItemRef."Item No.");
            ltTransferLine.SetRange("Unit of Measure Code", ItemRef."Unit of Measure");
            if ltTransferLine.FindFirst() then begin
                ltTransferLine.Validate(Quantity, ltTransferLine.Quantity + pQuantity);
                ltTransferLine.Modify();
            end else begin
                ltTransferLine.Init();
                ltTransferLine."Document No." := rec."No.";
                ltTransferLine."Line No." := GetLastTransferLine(ltTransferLine."Document No.");
                ltTransferLine.Validate("Item No.", ItemRef."Item No.");
                ltTransferLine.Insert(true);
                ltTransferLine.Validate("Unit of Measure Code", ItemRef."Unit of Measure");
                ltTransferLine.Validate(Quantity, pQuantity);
                ltTransferLine.Modify();
            end;
            rec.Validate("Item No", ItemRef."Item No.");
            rec."Unit of Measure" := ItemRef."Unit of Measure";
            rec."Scan Barcode Status" := rec."Scan Barcode Status"::Pass;
            rec."Last Qty to Transfer" := pQuantity;
            rec.Modify();
        end else begin
            rec."Scan Barcode Status" := rec."Scan Barcode Status"::Fail;
            rec.Modify();
            Message('The record in table Item Reference does not exists. Identification fields and values: No.=' + pBarcode);
        end;
    end;

    procedure GetLastTransferLine(pDOcumentNO: code[20]): Integer
    var
        ltTransferLine: Record "Transfer Line";
    begin
        ltTransferLine.reset();
        ltTransferLine.SetCurrentKey("Document No.", "Line No.");
        ltTransferLine.SetRange("Document No.", pDOcumentNO);
        if ltTransferLine.FindLast() then
            exit(ltTransferLine."Line No." + 10000);
        exit(10000);
    end;
}
