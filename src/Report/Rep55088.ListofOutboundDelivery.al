report 55088 "List of Outbound Delivery"
{
    Caption = 'List of Outbound Delivery (ZSDR053)';
    ApplicationArea = all;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './LayoutReport/ListofOutboundDelivery.rdl';
    PreviewMode = PrintLayout;
    dataset
    {
        dataitem(TempSalesLine; "Sales Line")
        {
            DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
            UseTemporary = true;
            column(Document_Type; "Document Type") { }
            column(Document_No_; "Document No.") { }
            column(GMM_External_Doc_No_; "GMM External Doc No.") { }
            column(GMM_Bill_Doc_No_; "GMM Bill Doc No.") { }
            column(Quantity; Quantity) { }
            column(Amount; Amount) { }
            column(Unit_Cost; "Unit Cost") { }
            column(GMM_Address; "GMM Address") { }
            column(GMM_Phone_No_; "GMM Phone No.") { }
            column(GMM_Name_Sold_to_pt; "GMM Name Sold-to-pt") { }
            column(GMM_Route; "GMM Route") { }
            column(Shipment_Date; format("Shipment Date")) { }
            column(Shipment_No_; "Shipment No.") { }
            column(GMM_Order_Date; format("GMM Order Date")) { }
            column(GMM_Posted_Bill_Date; format("GMM Posted Bill Date")) { }
            column(GMM_Sold_to_pt; "GMM Sold-to-pt") { }
            column(GMM_GM; "GMM GM") { }
            column(GMM_Ship_to_Code; "GMM Ship to Code") { }
            column(GMM_Ship_to_Name; "GMM Ship to Name") { }
            column(GMM_Trp__Plan_Date; format("GMM Trp. Plan Date")) { }
            column(GMM_Status; "GMM Status") { }

            trigger OnPreDataItem()
            var
                ltSkipt: Boolean;
                ltPostShip: Record "Sales Shipment Header";
                ltReturn: Record "Return Receipt Header";
            begin
                LineNo := 0;
                if (StartingDate = 0D) OR (EndingDate = 0D) then
                    ERROR('Staring Date and Ending Date must have a value');
                SalesHeader.reset();
                SalesHeader.SetCurrentKey("Document Type", "No.");
                SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order");
                SalesHeader.SetRange("Posting Date", StartingDate, EndingDate);
                if ExternalDocNo <> '' then
                    SalesHeader.SetFilter("External Document No.", ExternalDocNo);
                if BilltoCode <> '' then
                    SalesHeader.SetFilter("Bill-to Customer No.", BilltoCode);
                if SalesHeader.FindSet() then
                    repeat
                        ltSkipt := false;
                        SalesHeader.CalcFields("Completely Shipped", "Qty. Not Invoiced", "Qty. Rcd. Not Invoiced", "Total Qty.");

                        IF (GM = GM::"Complete Post Shipment/Receive") OR (Status = Status::POST) THEN
                            if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
                                if (not SalesHeader."Completely Shipped") then
                                    ltSkipt := true
                                else
                                    if (SalesHeader."Qty. Not Invoiced" <> SalesHeader."Total Qty.") then
                                        ltSkipt := true;
                            end else
                                if (not SalesHeader."Completely Shipped") then
                                    ltSkipt := true
                                else
                                    if (SalesHeader."Qty. Rcd. Not Invoiced" <> SalesHeader."Total Qty.") then
                                        ltSkipt := true;

                        IF (GM = GM::"Post Shipment/Receive") or (Status = Status::"Invoice Partial") THEN
                            if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
                                if (SalesHeader."Completely Shipped") then
                                    ltSkipt := true
                                else begin
                                    ltPostShip.reset();
                                    ltPostShip.SetRange("Order No.", SalesHeader."No.");
                                    if ltPostShip.IsEmpty then
                                        ltSkipt := true;

                                end;
                            end;
                        IF (GM = GM::"Post Shipment/Receive") or (Status = Status::"C/N Partial") THEN
                            if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then begin
                                if (SalesHeader."Completely Shipped") then
                                    ltSkipt := true
                                else begin
                                    ltReturn.reset();
                                    ltReturn.SetRange("Return Order No.", SalesHeader."No.");
                                    if ltReturn.IsEmpty then
                                        ltSkipt := true;
                                end;
                            end;


                        IF (GM = GM::"Complete Post Sale Invoice & Sale Credit Memo") OR (Status = Status::INVOICE) THEN
                            if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
                                if (SalesHeader."Completely Shipped") and (SalesHeader."Qty. Not Invoiced" <> 0) then
                                    ltSkipt := true;
                                if (not SalesHeader."Completely Shipped") then
                                    ltSkipt := true;

                            end;
                        IF (GM = GM::"Complete Post Sale Invoice & Sale Credit Memo") OR (Status = Status::"C/N") THEN
                            if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then begin
                                if (SalesHeader."Completely Shipped") and (SalesHeader."Qty. Rcd. Not Invoiced" <> 0) then
                                    ltSkipt := true;
                                if (not SalesHeader."Completely Shipped") then
                                    ltSkipt := true;

                            end;



                        if not ltSkipt then begin
                            if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
                                gvPostedSalesShipment.Reset();
                                gvPostedSalesShipment.SetRange("Order No.", SalesHeader."No.");
                                if gvPostedSalesShipment.FindFirst() then begin
                                    repeat
                                        CreateToSalesLineBuffShipment(gvPostedSalesShipment."No.", gvPostedSalesShipment, SalesHeader);
                                    until gvPostedSalesShipment.Next() = 0;
                                end else
                                    CreateToSalesLineBuffShipment('', gvPostedSalesShipment, SalesHeader);
                            end else begin
                                // gvPostedSalesReturnReceipt.Reset();
                                // gvPostedSalesReturnReceipt.SetRange("Return Order No.", SalesHeader."No.");
                                // if gvPostedSalesReturnReceipt.FindFirst() then begin
                                //     repeat
                                //         CreateToSalesLineBuffReceipt(gvPostedSalesReturnReceipt."No.", gvPostedSalesReturnReceipt, SalesHeader);
                                //     until gvPostedSalesReturnReceipt.Next() = 0;
                                // end else
                                //     CreateToSalesLineBuffReceipt('', gvPostedSalesReturnReceipt, SalesHeader);
                            end;
                        end;
                    until SalesHeader.Next() = 0;
                TempSalesLine.reset();
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                    Caption = 'Options';
                    field(StartingDate; StartingDate)
                    {
                        ApplicationArea = all;
                        ToolTip = 'Specifies the value of the StartingDate field.';
                        Caption = 'Starting Date';
                    }
                    field(EndingDate; EndingDate)
                    {
                        ApplicationArea = all;
                        ToolTip = 'Specifies the value of the EndingDate field.';
                        Caption = 'Ending Date';
                    }
                    field(Status; Status)
                    {
                        ApplicationArea = all;
                        ToolTip = 'Specifies the value of the Status field.';
                        Caption = 'Status';
                    }
                    field(GM; GM)
                    {
                        ApplicationArea = all;
                        ToolTip = 'Specifies the value of the GM field.';
                        Caption = 'GM';
                    }
                    field(BillToCode; BillToCode)
                    {
                        ApplicationArea = all;
                        ToolTip = 'Specifies the value of the BillToCode field.';
                        Caption = 'Bill to Code';
                    }
                    field(ExternalDocNo; ExternalDocNo)
                    {
                        ApplicationArea = all;
                        ToolTip = 'Specifies the value of the ExternalDocNo field.';
                        Caption = 'External Document No.';
                    }
                }
            }
        }
    }

    local procedure CreateToSalesLineBuffShipment(ShipReceiptNo: code[30]; PostedSalesShipment: Record "Sales Shipment Header"; pSalesHeader: Record "Sales Header")
    var
        ltSalesLine: Record "Sales Line";
        ltTotalQty, TotalAmt, UnitCost : Decimal;
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentLine: record "Sales Shipment Line";
        HaveInvoice: Boolean;
    begin
        LineNo := LineNo + 1;
        pSalesHeader.CalcFields("Completely Shipped", "Qty. Not Invoiced");

        if ShipReceiptNo <> '' then begin
            HaveInvoice := false;
            CLEAR(ValueGroupping);
            ValueGroupping.SetRange(RefItemLedgerDocNo, ShipReceiptNo);
            ValueGroupping.SetRange(ItemChargeNo, '');
            ValueGroupping.SetRange(DocumentType, ValueGroupping.DocumentType::"Sales Invoice");
            ValueGroupping.Open();
            while ValueGroupping.Read() do begin
                SalesInvoiceHeader.GET(ValueGroupping.DocumentNo);
                HaveInvoice := true;
                SalesInvoiceLine.reset();
                SalesInvoiceLine.SetRange("DOcument No.", ValueGroupping.DocumentNo);
                SalesInvoiceLine.CalcSums(Quantity, Amount, "Unit Cost");
                ltTotalQty := SalesInvoiceLine.Quantity;
                TotalAmt := SalesInvoiceLine.Amount;
                UnitCost := SalesInvoiceLine."Unit Cost";
                TempSalesLine.init();
                TempSalesLine."Document Type" := pSalesHeader."Document Type";
                TempSalesLine."Document No." := pSalesHeader."No.";
                TempSalesLine."GMM Order Date" := pSalesHeader."Order Date";
                TempSalesLine."Line No." := LineNo;
                TempSalesLine."Shipment No." := ShipReceiptNo;
                TempSalesLine."Shipment Date" := PostedSalesShipment."Posting Date";
                TempSalesLine."GMM Posted Bill Date" := SalesInvoiceHeader."Posting Date";
                TempSalesLine."GMM Bill Doc No." := ValueGroupping.DocumentNo;
                TempSalesLine."GMM External Doc No." := PostedSalesShipment."External Document No.";
                if PostedSalesShipment."Ship-to Code" <> '' then
                    TempSalesLine."GMM Ship to Code" := PostedSalesShipment."Ship-to Code"
                else
                    TempSalesLine."GMM Ship to Code" := PostedSalesShipment."Sell-to Customer No.";
                TempSalesLine."GMM Ship to Name" := PostedSalesShipment."Ship-to Name";
                TempSalesLine."GMM Trp. Plan Date" := PostedSalesShipment."Shipment Date";
                if (pSalesHeader."Completely Shipped") and (pSalesHeader."Qty. Not Invoiced" = 0) then
                    TempSalesLine."GMM GM" := 'C'
                else
                    TempSalesLine."GMM GM" := 'B';
                TempSalesLine."GMM Sold-to-pt" := pSalesHeader."Bill-to Customer No.";
                TempSalesLine."GMM Name Sold-to-pt" := pSalesHeader."Bill-to Name";
                TempSalesLine."GMM Route" := PostedSalesShipment."Shipping Agent Code";
                TempSalesLine.Quantity := ltTotalQty;
                TempSalesLine.Amount := ValueGroupping.Sales_Amount__Actual_ + ValueGroupping.Sales_Amount__Expected_;
                TempSalesLine."Unit Cost" := ValueGroupping.Cost_Amount__Actual_ + ValueGroupping.Cost_Amount__Expected_;
                if TempSalesLine."GMM GM" = 'C' then
                    TempSalesLine."GMM Status" := 'INVOICE'
                else
                    TempSalesLine."GMM Status" := 'Invoice Partial';
                TempSalesLine."GMM Address" := PostedSalesShipment."Ship-to Address" + ' ' + PostedSalesShipment."Ship-to Address 2" + ' ' + PostedSalesShipment."Ship-to City" + ' ' + PostedSalesShipment."Ship-to Post Code";
                TempSalesLine."GMM Phone No." := PostedSalesShipment."TPP Ship-to Phone No.";
                TempSalesLine.Insert();


            end;
            if not HaveInvoice then begin
                SalesShipmentLine.reset();
                SalesShipmentLine.SetRange("DOcument No.", ShipReceiptNo);
                SalesShipmentLine.CalcSums(Quantity, "Unit Cost");
                ltTotalQty := SalesInvoiceLine.Quantity;
                TotalAmt := SalesInvoiceLine.Amount;
                UnitCost := SalesInvoiceLine."Unit Cost";
                TempSalesLine.init();
                TempSalesLine."Document Type" := pSalesHeader."Document Type";
                TempSalesLine."Document No." := pSalesHeader."No.";
                TempSalesLine."GMM Order Date" := pSalesHeader."Order Date";
                TempSalesLine."Line No." := LineNo;
                TempSalesLine."Shipment No." := ShipReceiptNo;
                TempSalesLine."Shipment Date" := PostedSalesShipment."Posting Date";
                TempSalesLine."GMM Bill Doc No." := '';
                TempSalesLine."GMM External Doc No." := PostedSalesShipment."External Document No.";
                if PostedSalesShipment."Ship-to Code" <> '' then
                    TempSalesLine."GMM Ship to Code" := PostedSalesShipment."Ship-to Code"
                else
                    TempSalesLine."GMM Ship to Code" := PostedSalesShipment."Sell-to Customer No.";
                TempSalesLine."GMM Ship to Name" := PostedSalesShipment."Ship-to Name";
                TempSalesLine."GMM Trp. Plan Date" := PostedSalesShipment."Shipment Date";
                if (pSalesHeader."Completely Shipped") then
                    TempSalesLine."GMM GM" := 'A'
                else
                    TempSalesLine."GMM GM" := 'B';
                TempSalesLine."GMM Sold-to-pt" := pSalesHeader."Bill-to Customer No.";
                TempSalesLine."GMM Name Sold-to-pt" := pSalesHeader."Bill-to Name";
                TempSalesLine."GMM Route" := PostedSalesShipment."Shipping Agent Code";
                TempSalesLine.Quantity := ltTotalQty;
                TempSalesLine.Amount := ValueGroupping.Sales_Amount__Actual_ + ValueGroupping.Sales_Amount__Expected_;
                TempSalesLine."Unit Cost" := ValueGroupping.Cost_Amount__Actual_ + ValueGroupping.Cost_Amount__Expected_;
                if TempSalesLine."GMM GM" = 'A' then
                    TempSalesLine."GMM Status" := 'POST'
                else
                    TempSalesLine."GMM Status" := 'Partial';
                TempSalesLine."GMM Address" := PostedSalesShipment."Ship-to Address" + ' ' + PostedSalesShipment."Ship-to Address 2" + ' ' + PostedSalesShipment."Ship-to City" + ' ' + PostedSalesShipment."Ship-to Post Code";
                TempSalesLine."GMM Phone No." := PostedSalesShipment."TPP Ship-to Phone No.";
                TempSalesLine.Insert();
            end;
        end else begin

            ltSalesLine.reset();
            ltSalesLine.SetRange("Document Type", pSalesHeader."Document Type");
            ltSalesLine.SetRange("DOcument No.", pSalesHeader."No.");
            ltSalesLine.CalcSums(Quantity, Amount, "Unit Cost");
            ltTotalQty := ltSalesLine.Quantity;
            TotalAmt := ltSalesLine.Amount;
            UnitCost := ltsalesLine."Unit Cost";
            TempSalesLine.init();
            TempSalesLine."Document Type" := pSalesHeader."Document Type";
            TempSalesLine."Document No." := pSalesHeader."No.";
            TempSalesLine."GMM Order Date" := pSalesHeader."Order Date";
            TempSalesLine."Line No." := LineNo;
            TempSalesLine."Shipment No." := '';
            TempSalesLine."Shipment Date" := 0D;
            TempSalesLine."GMM Bill Doc No." := '';
            TempSalesLine."GMM External Doc No." := pSalesHeader."External Document No.";
            if pSalesHeader."Ship-to Code" <> '' then
                TempSalesLine."GMM Ship to Code" := pSalesHeader."Ship-to Code"
            else
                TempSalesLine."GMM Ship to Code" := pSalesHeader."Sell-to Customer No.";
            TempSalesLine."GMM Ship to Name" := pSalesHeader."Ship-to Name";
            TempSalesLine."GMM Trp. Plan Date" := pSalesHeader."Shipment Date";
            TempSalesLine."GMM GM" := '';
            TempSalesLine."GMM Sold-to-pt" := pSalesHeader."Bill-to Customer No.";
            TempSalesLine."GMM Name Sold-to-pt" := pSalesHeader."Bill-to Name";
            TempSalesLine."GMM Route" := pSalesHeader."Shipping Agent Code";
            TempSalesLine.Quantity := ltTotalQty;
            TempSalesLine.Amount := TotalAmt;
            TempSalesLine."Unit Cost" := UnitCost;
            TempSalesLine."GMM Status" := '';
            TempSalesLine."GMM Address" := pSalesHeader."Ship-to Address" + ' ' + pSalesHeader."Ship-to Address 2" + ' ' + pSalesHeader."Ship-to City" + ' ' + pSalesHeader."Ship-to Post Code";
            TempSalesLine."GMM Phone No." := pSalesHeader."TPP Ship-to Phone No.";
            TempSalesLine.Insert();
        end;
        ValueGroupping.Close();
    end;


    local procedure CreateToSalesLineBuffReceipt(ShipReceiptNo: code[30]; PostedReturnReceipt: Record "Return Receipt Header"; pSalesHeader: Record "Sales Header")
    var
        ltSalesLine: Record "Sales Line";
        ltTotalQty, TotalAmt, UnitCost : Decimal;
        SalesInvoiceLine: Record "Return Receipt Line";
        SalesCN: Record "Sales Cr.Memo Header";
        HaveInvoice: Boolean;
    begin
        LineNo := LineNo + 1;
        pSalesHeader.CalcFields("Completely Shipped", "Qty. Rcd. Not Invoiced");

        if ShipReceiptNo <> '' then begin
            HaveInvoice := false;
            CLEAR(ValueGroupping);
            ValueGroupping.SetRange(RefItemLedgerDocNo, ShipReceiptNo);
            ValueGroupping.SetRange(ItemChargeNo, '');
            ValueGroupping.SetRange(DocumentType, ValueGroupping.DocumentType::"Sales Credit Memo");
            ValueGroupping.Open();
            while ValueGroupping.Read() do begin
                SalesCN.GET(ValueGroupping.DocumentNo);
                HaveInvoice := true;
                ltSalesLine.reset();
                ltSalesLine.SetRange("Document Type", pSalesHeader."Document Type");
                ltSalesLine.SetRange("DOcument No.", pSalesHeader."No.");
                ltSalesLine.CalcSums(Quantity, Amount, "Unit Cost");
                ltTotalQty := ltSalesLine.Quantity;
                TempSalesLine.init();
                TempSalesLine."Document Type" := pSalesHeader."Document Type";
                TempSalesLine."Document No." := pSalesHeader."No.";
                TempSalesLine."GMM Order Date" := pSalesHeader."Order Date";
                TempSalesLine."Line No." := LineNo;
                TempSalesLine."Shipment No." := ShipReceiptNo;
                TempSalesLine."Shipment Date" := 0D;
                TempSalesLine."GMM Bill Doc No." := ValueGroupping.DocumentNo;
                TempSalesLine."GMM Posted Bill Date" := SalesCN."Posting Date";
                TempSalesLine."GMM External Doc No." := pSalesHeader."External Document No.";
                if PostedReturnReceipt."Ship-to Code" <> '' then
                    TempSalesLine."GMM Ship to Code" := pSalesHeader."Ship-to Code"
                else
                    TempSalesLine."GMM Ship to Code" := pSalesHeader."Sell-to Customer No.";
                TempSalesLine."GMM Ship to Name" := pSalesHeader."Ship-to Name";
                TempSalesLine."GMM Trp. Plan Date" := pSalesHeader."Shipment Date";
                if (pSalesHeader."Completely Shipped") and (pSalesHeader."Qty. Not Invoiced" = 0) then
                    TempSalesLine."GMM GM" := 'C'
                else
                    TempSalesLine."GMM GM" := 'B';
                TempSalesLine."GMM Sold-to-pt" := pSalesHeader."Bill-to Customer No.";
                TempSalesLine."GMM Name Sold-to-pt" := pSalesHeader."Bill-to Name";
                TempSalesLine."GMM Route" := pSalesHeader."Shipping Agent Code";
                TempSalesLine.Quantity := ltTotalQty;
                TempSalesLine.Amount := ValueGroupping.Sales_Amount__Actual_ + ValueGroupping.Sales_Amount__Expected_;
                TempSalesLine."Unit Cost" := ValueGroupping.Cost_Amount__Actual_ + ValueGroupping.Cost_Amount__Expected_;
                if TempSalesLine."GMM GM" = 'C' then
                    TempSalesLine."GMM Status" := 'INVOICE'
                else
                    TempSalesLine."GMM Status" := 'Invoice Partial';
                TempSalesLine."GMM Address" := pSalesHeader."Ship-to Address" + ' ' + pSalesHeader."Ship-to Address 2" + ' ' + pSalesHeader."Ship-to City" + ' ' + pSalesHeader."Ship-to Post Code";
                TempSalesLine."GMM Phone No." := pSalesHeader."TPP Ship-to Phone No.";
                TempSalesLine.Insert();

            end;
            if not HaveInvoice then begin
                ltSalesLine.reset();
                ltSalesLine.SetRange("Document Type", pSalesHeader."Document Type");
                ltSalesLine.SetRange("DOcument No.", pSalesHeader."No.");
                ltSalesLine.CalcSums(Quantity, Amount, "Unit Cost");
                ltTotalQty := ltSalesLine.Quantity;
                TempSalesLine.init();
                TempSalesLine."Document Type" := pSalesHeader."Document Type";
                TempSalesLine."Document No." := pSalesHeader."No.";
                TempSalesLine."GMM Order Date" := pSalesHeader."Order Date";
                TempSalesLine."Line No." := LineNo;
                TempSalesLine."Shipment No." := ShipReceiptNo;
                TempSalesLine."Shipment Date" := 0D;
                TempSalesLine."GMM Bill Doc No." := ValueGroupping.DocumentNo;
                TempSalesLine."GMM External Doc No." := pSalesHeader."External Document No.";
                if PostedReturnReceipt."Ship-to Code" <> '' then
                    TempSalesLine."GMM Ship to Code" := pSalesHeader."Ship-to Code"
                else
                    TempSalesLine."GMM Ship to Code" := pSalesHeader."Sell-to Customer No.";
                TempSalesLine."GMM Ship to Name" := pSalesHeader."Ship-to Name";
                TempSalesLine."GMM Trp. Plan Date" := pSalesHeader."Shipment Date";
                if (pSalesHeader."Completely Shipped") and (pSalesHeader."Qty. Rcd. Not Invoiced" = 0) then
                    TempSalesLine."GMM GM" := 'C'
                else
                    TempSalesLine."GMM GM" := 'B';

                TempSalesLine."GMM Sold-to-pt" := pSalesHeader."Bill-to Customer No.";
                TempSalesLine."GMM Name Sold-to-pt" := pSalesHeader."Bill-to Name";
                TempSalesLine."GMM Route" := pSalesHeader."Shipping Agent Code";
                TempSalesLine.Quantity := ltTotalQty;
                TempSalesLine.Amount := ValueGroupping.Sales_Amount__Actual_ + ValueGroupping.Sales_Amount__Expected_;
                TempSalesLine."Unit Cost" := ValueGroupping.Cost_Amount__Actual_ + ValueGroupping.Cost_Amount__Expected_;
                if TempSalesLine."GMM GM" = 'C' then
                    TempSalesLine."GMM Status" := 'INVOICE'
                else
                    TempSalesLine."GMM Status" := 'Invoice Partial';
                TempSalesLine."GMM Address" := pSalesHeader."Ship-to Address" + ' ' + pSalesHeader."Ship-to Address 2" + ' ' + pSalesHeader."Ship-to City" + ' ' + pSalesHeader."Ship-to Post Code";
                TempSalesLine."GMM Phone No." := pSalesHeader."TPP Ship-to Phone No.";
                TempSalesLine.Insert();
            end;
        end else begin
            ltSalesLine.reset();
            ltSalesLine.SetRange("Document Type", pSalesHeader."Document Type");
            ltSalesLine.SetRange("DOcument No.", pSalesHeader."No.");
            ltSalesLine.CalcSums(Quantity, Amount, "Unit Cost");
            ltTotalQty := ltSalesLine.Quantity;
            TotalAmt := ltSalesLine.Amount;
            UnitCost := ltsalesLine."Unit Cost";
            TempSalesLine.init();
            TempSalesLine."Document Type" := pSalesHeader."Document Type";
            TempSalesLine."Document No." := pSalesHeader."No.";
            TempSalesLine."GMM Order Date" := pSalesHeader."Order Date";
            TempSalesLine."Line No." := LineNo;
            TempSalesLine."Shipment No." := '';
            TempSalesLine."Shipment Date" := 0D;
            TempSalesLine."GMM Bill Doc No." := '';
            TempSalesLine."GMM External Doc No." := pSalesHeader."External Document No.";
            if pSalesHeader."Ship-to Code" <> '' then
                TempSalesLine."GMM Ship to Code" := pSalesHeader."Ship-to Code"
            else
                TempSalesLine."GMM Ship to Code" := pSalesHeader."Sell-to Customer No.";
            TempSalesLine."GMM Ship to Name" := pSalesHeader."Ship-to Name";
            TempSalesLine."GMM Trp. Plan Date" := pSalesHeader."Shipment Date";
            TempSalesLine."GMM GM" := '';
            TempSalesLine."GMM Sold-to-pt" := pSalesHeader."Bill-to Customer No.";
            TempSalesLine."GMM Name Sold-to-pt" := pSalesHeader."Bill-to Name";
            TempSalesLine."GMM Route" := pSalesHeader."Shipping Agent Code";
            TempSalesLine.Quantity := ltTotalQty;
            TempSalesLine.Amount := TotalAmt;
            TempSalesLine."Unit Cost" := UnitCost;
            TempSalesLine."GMM Status" := '';
            TempSalesLine."GMM Address" := pSalesHeader."Ship-to Address" + ' ' + pSalesHeader."Ship-to Address 2" + ' ' + pSalesHeader."Ship-to City" + ' ' + pSalesHeader."Ship-to Post Code";
            TempSalesLine."GMM Phone No." := pSalesHeader."TPP Ship-to Phone No.";
            TempSalesLine.Insert();
        end;
        ValueGroupping.Close();
    end;

    var
        StartingDate, EndingDate : date;
        ExternalDocNo: code[35];
        GM: Option " ","Complete Post Shipment/Receive","Post Shipment/Receive","Complete Post Sale Invoice & Sale Credit Memo";
        Status: Option " ","POST","INVOICE","C/N","Invoice Partial","C/N Partial";
        BillToCode: code[30];
        SalesHeader: Record "Sales Header";
        gvPostedSalesShipment: Record "Sales Shipment Header";
        gvPostedSalesReturnReceipt: Record "Return Receipt Header";
        PostedSalesInvoice: Record "Sales Invoice Header";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueENtry: Record "Value Entry";
        LineNo: Integer;
        ValueGroupping: query "Groupping Value Entry";



}
