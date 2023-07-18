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
            column(TotalRec; TotalRec) { }
            column(RundateTime; format(CurrentDateTime)) { }
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
                ltSalesHeader: Record "Sales Header";
                ltSalesShipmentHeader: Record "Sales Shipment Header";
            begin
                LineNo := 0;
                if (StartingDate = 0D) OR (EndingDate = 0D) then
                    ERROR('Staring Date and Ending Date must have a value');

                ltSalesHeader.reset();
                ltSalesHeader.SetCurrentKey("Document Type", "No.");
                ltSalesHeader.SetFilter("Document Type", '%1|%2', TempSalesHeader."Document Type"::Order, TempSalesHeader."Document Type"::"Return Order");
                ltSalesHeader.SetRange("Posting Date", StartingDate, EndingDate);
                if ExternalDocNo <> '' then
                    ltSalesHeader.SetFilter("External Document No.", ExternalDocNo);
                if BilltoCode <> '' then
                    ltSalesHeader.SetFilter("Bill-to Customer No.", BilltoCode);
                if ltSalesHeader.FindFirst() then
                    repeat
                        ltSalesHeader.CalcFields("Completely Shipped", "Qty. Not Invoiced", "Qty. Rcd. Not Invoiced");
                        TempSalesHeader.init();
                        TempSalesHeader.TransferFields(ltSalesHeader, false);
                        TempSalesHeader."Document Type" := ltSalesHeader."Document Type";
                        TempSalesHeader."GMM Completely Shipment" := ltSalesHeader."Completely Shipped";
                        TempSalesHeader."GMM Qty. Not Invoiced" := ltSalesHeader."Qty. Not Invoiced";
                        TempSalesHeader."GMM Qty. Rcd. Not Invoiced" := ltSalesHeader."Qty. Rcd. Not Invoiced";
                        TempSalesHeader."No." := ltSalesHeader."No.";
                        TempSalesHeader.Insert();
                    until ltSalesHeader.Next() = 0;


                ltSalesShipmentHeader.reset();
                ltSalesShipmentHeader.SetCurrentKey("No.");
                ltSalesShipmentHeader.SetRange("Have Sales Order", false);
                ltSalesShipmentHeader.SetRange("Posting Date", StartingDate, EndingDate);
                if ExternalDocNo <> '' then
                    ltSalesShipmentHeader.SetFilter("External Document No.", ExternalDocNo);
                if BilltoCode <> '' then
                    ltSalesShipmentHeader.SetFilter("Bill-to Customer No.", BilltoCode);
                ltSalesShipmentHeader.SetFilter("Order No.", '<>%1', '');

                if ltSalesShipmentHeader.FindFirst() then
                    repeat
                        TempSalesHeader.init();
                        TempSalesHeader.TransferFields(ltSalesShipmentHeader, false);
                        TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Order;
                        TempSalesHeader."No." := ltSalesShipmentHeader."Order No.";
                        TempSalesHeader."GMM Completely Shipment" := true;
                        TempSalesHeader."GMM Qty. Not Invoiced" := 0;
                        TempSalesHeader."GMM From Ship" := true;
                        if TempSalesHeader.Insert() then;
                    until ltSalesShipmentHeader.Next() = 0;

                TempSalesHeader.reset();
                TempSalesHeader.SetCurrentKey("Document Type", "No.");

                if TempSalesHeader.FindSet() then
                    repeat
                        ltSkipt := false;




                        if TempSalesHeader."Document Type" = TempSalesHeader."Document Type"::Order then begin
                            IF (GM = GM::"Post Shipment/Receive") OR (Status = Status::"Invoice Partial") THEN begin
                                if Status in [Status::" ", Status::"Invoice Partial"] then begin
                                    if (TempSalesHeader."GMM Completely Shipment") then
                                        ltSkipt := true
                                    else begin
                                        ltPostShip.reset();
                                        ltPostShip.SetRange("Order No.", TempSalesHeader."No.");
                                        if ltPostShip.IsEmpty then
                                            ltSkipt := true;
                                    end;
                                end else
                                    ltSkipt := true;
                            end else begin
                                IF (GM = GM::"Complete Post Sale Invoice & Sale Credit Memo") OR (Status = Status::INVOICE) THEN begin
                                    if Status in [Status::" ", Status::INVOICE] then begin
                                        if (TempSalesHeader."GMM Completely Shipment") and (TempSalesHeader."GMM Qty. Not Invoiced" <> 0) then
                                            ltSkipt := true;
                                        if (not TempSalesHeader."GMM Completely Shipment") then
                                            ltSkipt := true;
                                    end else
                                        ltSkipt := true;
                                end;
                                IF (GM = GM::"Complete Post Shipment/Receive") OR (Status = Status::POST) THEN begin
                                    if Status in [Status::" ", Status::"POST"] then begin
                                        if (not TempSalesHeader."GMM Completely Shipment") then
                                            ltSkipt := true
                                        else
                                            if (TempSalesHeader."GMM Qty. Not Invoiced" <> TempSalesHeader."GMM Total Qty.") then
                                                ltSkipt := true;
                                    end;
                                end;
                            end;
                            if Status in [Status::"C/N", Status::"C/N Partial"] then
                                ltSkipt := true;
                        end;


                        if TempSalesHeader."Document Type" = TempSalesHeader."Document Type"::"Return Order" then begin
                            IF (GM = GM::"Post Shipment/Receive") OR (Status = Status::"C/N Partial") THEN begin
                                if Status in [Status::" ", Status::"C/N Partial"] then begin
                                    if (TempSalesHeader."GMM Completely Shipment") then
                                        ltSkipt := true
                                    else begin
                                        ltReturn.reset();
                                        ltReturn.SetRange("Return Order No.", TempSalesHeader."No.");
                                        if ltReturn.IsEmpty then
                                            ltSkipt := true;
                                    end;
                                end else
                                    ltSkipt := true;
                            end else begin
                                IF (GM = GM::"Complete Post Sale Invoice & Sale Credit Memo") or (Status = Status::"C/N") THEN begin
                                    if Status in [Status::" ", Status::"C/N"] then begin
                                        if (TempSalesHeader."GMM Completely Shipment") and (TempSalesHeader."GMM Qty. Rcd. Not Invoiced" <> 0) then
                                            ltSkipt := true;
                                        if (not TempSalesHeader."GMM Completely Shipment") then
                                            ltSkipt := true;
                                    end else
                                        ltSkipt := true;
                                end;
                                IF (GM = GM::"Complete Post Shipment/Receive") OR (Status = Status::POST) THEN begin
                                    if Status in [Status::" ", Status::"POST"] then begin
                                        if (not TempSalesHeader."GMM Completely Shipment") then
                                            ltSkipt := true
                                        else
                                            if (TempSalesHeader."GMM Qty. Rcd. Not Invoiced" <> TempSalesHeader."GMM Total Qty.") then
                                                ltSkipt := true;
                                    end;
                                end;
                            end;
                            if Status in [Status::INVOICE, Status::"Invoice Partial"] then
                                ltSkipt := true;
                        end;




                        if not ltSkipt then begin
                            if TempSalesHeader."Document Type" = TempSalesHeader."Document Type"::Order then begin
                                gvPostedSalesShipment.Reset();
                                gvPostedSalesShipment.SetRange("Order No.", TempSalesHeader."No.");
                                if gvPostedSalesShipment.FindSet() then begin
                                    repeat
                                        CreateToSalesLineBuffShipment(gvPostedSalesShipment."No.", gvPostedSalesShipment, TempSalesHeader);
                                    until gvPostedSalesShipment.Next() = 0;
                                end else
                                    CreateToSalesLineBuffShipment('', gvPostedSalesShipment, TempSalesHeader);
                            end else begin
                                gvPostedSalesReturnReceipt.Reset();
                                gvPostedSalesReturnReceipt.SetRange("Return Order No.", TempSalesHeader."No.");
                                if gvPostedSalesReturnReceipt.FindSet() then begin
                                    repeat
                                        CreateToSalesLineBuffReceipt(gvPostedSalesReturnReceipt."No.", gvPostedSalesReturnReceipt, TempSalesHeader);
                                    until gvPostedSalesReturnReceipt.Next() = 0;
                                end else
                                    CreateToSalesLineBuffReceipt('', gvPostedSalesReturnReceipt, TempSalesHeader);
                            end;
                        end;
                    until TempSalesHeader.Next() = 0;
                TempSalesLine.reset();
                TotalRec := LineNo;
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

    local procedure CreateToSalesLineBuffShipment(ShipReceiptNo: code[30]; PostedSalesShipment: Record "Sales Shipment Header"; pTempSalesHeader: Record "Sales Header" temporary)
    var
        ltSalesLine: Record "Sales Line";
        ltTotalQty, TotalAmt, UnitCost : Decimal;
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentLine: record "Sales Shipment Line";
        HaveInvoice: Boolean;
        ItemDocType: Enum "Item Ledger Document Type";
    begin

        pTempSalesHeader.CalcFields("Completely Shipped", "Qty. Not Invoiced");

        if ShipReceiptNo <> '' then begin
            HaveInvoice := false;
            CLEAR(ValueGroupping);
            ValueGroupping.SetRange(RefItemLedgerDocNo, ShipReceiptNo);
            ValueGroupping.SetRange(ItemChargeNo, '');
            ValueGroupping.SetFilter(ItemLedgerDocumentType, '%1', ItemDocType::"Sales Invoice");
            ValueGroupping.Open();
            while ValueGroupping.Read() do begin
                LineNo := LineNo + 1;
                SalesInvoiceHeader.GET(ValueGroupping.DocumentNo);
                HaveInvoice := true;
                SalesInvoiceLine.reset();
                SalesInvoiceLine.SetRange("DOcument No.", ValueGroupping.DocumentNo);
                SalesInvoiceLine.CalcSums(Quantity, Amount, "Unit Cost");
                ltTotalQty := SalesInvoiceLine.Quantity;
                TotalAmt := SalesInvoiceLine.Amount;
                UnitCost := SalesInvoiceLine."Unit Cost";
                TempSalesLine.init();
                TempSalesLine."Document Type" := pTempSalesHeader."Document Type";
                TempSalesLine."Document No." := pTempSalesHeader."No.";
                TempSalesLine."GMM Order Date" := pTempSalesHeader."Order Date";
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
                if (pTempSalesHeader."GMM Completely Shipment") and (pTempSalesHeader."GMM Qty. Not Invoiced" = 0) then
                    TempSalesLine."GMM GM" := 'C'
                else
                    TempSalesLine."GMM GM" := 'B';
                TempSalesLine."GMM Sold-to-pt" := pTempSalesHeader."Bill-to Customer No.";
                TempSalesLine."GMM Name Sold-to-pt" := pTempSalesHeader."Bill-to Name";
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
                LineNo := LineNo + 1;
                ValueENtry.reset();
                ValueENtry.SetRange("Document No.", ShipReceiptNo);
                ValueENtry.CalcSums("Sales Amount (Actual)", "Sales Amount (Expected)", "Cost Amount (Actual)", "Cost Amount (Expected)", "Valued Quantity");
                ltTotalQty := ValueENtry."Valued Quantity";
                TotalAmt := ValueENtry."Sales Amount (Actual)" + ValueENtry."Sales Amount (Expected)";
                UnitCost := ValueENtry."Cost Amount (Actual)" + ValueENtry."Cost Amount (Expected)";
                TempSalesLine.init();
                TempSalesLine."Document Type" := pTempSalesHeader."Document Type";
                TempSalesLine."Document No." := pTempSalesHeader."No.";
                TempSalesLine."GMM Order Date" := pTempSalesHeader."Order Date";
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
                if (pTempSalesHeader."GMM Completely Shipment") then
                    TempSalesLine."GMM GM" := 'A'
                else
                    TempSalesLine."GMM GM" := 'B';
                TempSalesLine."GMM Sold-to-pt" := pTempSalesHeader."Bill-to Customer No.";
                TempSalesLine."GMM Name Sold-to-pt" := pTempSalesHeader."Bill-to Name";
                TempSalesLine."GMM Route" := PostedSalesShipment."Shipping Agent Code";
                TempSalesLine.Quantity := ltTotalQty;
                TempSalesLine.Amount := TotalAmt;
                TempSalesLine."Unit Cost" := UnitCost;
                if TempSalesLine."GMM GM" = 'A' then
                    TempSalesLine."GMM Status" := 'POST'
                else
                    TempSalesLine."GMM Status" := 'Partial';
                TempSalesLine."GMM Address" := PostedSalesShipment."Ship-to Address" + ' ' + PostedSalesShipment."Ship-to Address 2" + ' ' + PostedSalesShipment."Ship-to City" + ' ' + PostedSalesShipment."Ship-to Post Code";
                TempSalesLine."GMM Phone No." := PostedSalesShipment."TPP Ship-to Phone No.";
                TempSalesLine.Insert();
            end;
        end else begin
            LineNo := LineNo + 1;
            ltSalesLine.reset();
            ltSalesLine.SetRange("Document Type", pTempSalesHeader."Document Type");
            ltSalesLine.SetRange("DOcument No.", pTempSalesHeader."No.");
            ltSalesLine.CalcSums(Quantity, Amount, "Unit Cost");
            ltTotalQty := ltSalesLine.Quantity;
            TotalAmt := ltSalesLine.Amount;
            UnitCost := ltsalesLine."Unit Cost";
            TempSalesLine.init();
            TempSalesLine."Document Type" := pTempSalesHeader."Document Type";
            TempSalesLine."Document No." := pTempSalesHeader."No.";
            TempSalesLine."GMM Order Date" := pTempSalesHeader."Order Date";
            TempSalesLine."Line No." := LineNo;
            TempSalesLine."Shipment No." := '';
            TempSalesLine."Shipment Date" := 0D;
            TempSalesLine."GMM Bill Doc No." := '';
            TempSalesLine."GMM External Doc No." := pTempSalesHeader."External Document No.";
            if pTempSalesHeader."Ship-to Code" <> '' then
                TempSalesLine."GMM Ship to Code" := pTempSalesHeader."Ship-to Code"
            else
                TempSalesLine."GMM Ship to Code" := pTempSalesHeader."Sell-to Customer No.";
            TempSalesLine."GMM Ship to Name" := pTempSalesHeader."Ship-to Name";
            TempSalesLine."GMM Trp. Plan Date" := pTempSalesHeader."Shipment Date";
            TempSalesLine."GMM GM" := '';
            TempSalesLine."GMM Sold-to-pt" := pTempSalesHeader."Bill-to Customer No.";
            TempSalesLine."GMM Name Sold-to-pt" := pTempSalesHeader."Bill-to Name";
            TempSalesLine."GMM Route" := pTempSalesHeader."Shipping Agent Code";
            TempSalesLine.Quantity := ltTotalQty;
            TempSalesLine.Amount := TotalAmt;
            TempSalesLine."Unit Cost" := -UnitCost;
            TempSalesLine."GMM Status" := '';
            TempSalesLine."GMM Address" := pTempSalesHeader."Ship-to Address" + ' ' + pTempSalesHeader."Ship-to Address 2" + ' ' + pTempSalesHeader."Ship-to City" + ' ' + pTempSalesHeader."Ship-to Post Code";
            TempSalesLine."GMM Phone No." := pTempSalesHeader."TPP Ship-to Phone No.";
            TempSalesLine.Insert();
        end;
        ValueGroupping.Close();
    end;


    local procedure CreateToSalesLineBuffReceipt(ShipReceiptNo: code[30]; PostedReturnReceipt: Record "Return Receipt Header"; pTempSalesHeader: Record "Sales Header" temporary)
    var
        ltSalesLine: Record "Sales Line";
        ltTotalQty, TotalAmt, UnitCost : Decimal;
        SalesReceiptLine: Record "Return Receipt Line";
        SalesCN: Record "Sales Cr.Memo Header";
        HaveInvoice: Boolean;
        ItemDocType: Enum "Item Ledger Document Type";
    begin

        pTempSalesHeader.CalcFields("Completely Shipped", "Qty. Rcd. Not Invoiced");

        if ShipReceiptNo <> '' then begin

            HaveInvoice := false;
            CLEAR(ValueGroupping);
            ValueGroupping.SetRange(RefItemLedgerDocNo, ShipReceiptNo);
            ValueGroupping.SetRange(ItemChargeNo, '');
            ValueGroupping.SetFilter(ItemLedgerDocumentType, '%1', ItemDocType::"Sales Credit Memo");
            ValueGroupping.Open();
            while ValueGroupping.Read() do begin
                SalesCN.GET(ValueGroupping.DocumentNo);
                LineNo := LineNo + 1;
                HaveInvoice := true;
                ltSalesLine.reset();
                ltSalesLine.SetRange("Document Type", pTempSalesHeader."Document Type");
                ltSalesLine.SetRange("DOcument No.", pTempSalesHeader."No.");
                ltSalesLine.CalcSums(Quantity, Amount, "Unit Cost");
                ltTotalQty := ltSalesLine.Quantity;
                TempSalesLine.init();
                TempSalesLine."Document Type" := pTempSalesHeader."Document Type";
                TempSalesLine."Document No." := pTempSalesHeader."No.";
                TempSalesLine."GMM Order Date" := pTempSalesHeader."Order Date";
                TempSalesLine."Line No." := LineNo;
                TempSalesLine."Shipment No." := ShipReceiptNo;
                TempSalesLine."Shipment Date" := 0D;
                TempSalesLine."GMM Bill Doc No." := ValueGroupping.DocumentNo;
                TempSalesLine."GMM Posted Bill Date" := SalesCN."Posting Date";
                TempSalesLine."GMM External Doc No." := pTempSalesHeader."External Document No.";
                if PostedReturnReceipt."Ship-to Code" <> '' then
                    TempSalesLine."GMM Ship to Code" := pTempSalesHeader."Ship-to Code"
                else
                    TempSalesLine."GMM Ship to Code" := pTempSalesHeader."Sell-to Customer No.";
                TempSalesLine."GMM Ship to Name" := pTempSalesHeader."Ship-to Name";
                TempSalesLine."GMM Trp. Plan Date" := pTempSalesHeader."Shipment Date";
                if (pTempSalesHeader."GMM Completely Shipment") and (pTempSalesHeader."GMM Qty. Not Invoiced" = 0) then
                    TempSalesLine."GMM GM" := 'C'
                else
                    TempSalesLine."GMM GM" := 'B';
                TempSalesLine."GMM Sold-to-pt" := pTempSalesHeader."Bill-to Customer No.";
                TempSalesLine."GMM Name Sold-to-pt" := pTempSalesHeader."Bill-to Name";
                TempSalesLine."GMM Route" := pTempSalesHeader."Shipping Agent Code";
                TempSalesLine.Quantity := ltTotalQty;
                TempSalesLine.Amount := ValueGroupping.Sales_Amount__Actual_ + ValueGroupping.Sales_Amount__Expected_;
                TempSalesLine."Unit Cost" := ValueGroupping.Cost_Amount__Actual_ + ValueGroupping.Cost_Amount__Expected_;
                if TempSalesLine."GMM GM" = 'C' then
                    TempSalesLine."GMM Status" := 'INVOICE'
                else
                    TempSalesLine."GMM Status" := 'Invoice Partial';
                TempSalesLine."GMM Address" := pTempSalesHeader."Ship-to Address" + ' ' + pTempSalesHeader."Ship-to Address 2" + ' ' + pTempSalesHeader."Ship-to City" + ' ' + pTempSalesHeader."Ship-to Post Code";
                TempSalesLine."GMM Phone No." := pTempSalesHeader."TPP Ship-to Phone No.";
                TempSalesLine.Insert();

            end;
            if not HaveInvoice then begin
                LineNo := LineNo + 1;
                ValueENtry.reset();
                ValueENtry.SetRange("Document No.", ShipReceiptNo);
                ValueENtry.CalcSums("Sales Amount (Actual)", "Sales Amount (Expected)", "Cost Amount (Actual)", "Cost Amount (Expected)", "Valued Quantity");
                ltTotalQty := ValueENtry."Valued Quantity";
                TotalAmt := ValueENtry."Sales Amount (Actual)" + ValueENtry."Sales Amount (Expected)";
                UnitCost := ValueENtry."Cost Amount (Actual)" + ValueENtry."Cost Amount (Expected)";
                TempSalesLine.init();
                TempSalesLine."Document Type" := pTempSalesHeader."Document Type";
                TempSalesLine."Document No." := pTempSalesHeader."No.";
                TempSalesLine."GMM Order Date" := pTempSalesHeader."Order Date";
                TempSalesLine."Line No." := LineNo;
                TempSalesLine."Shipment No." := ShipReceiptNo;
                TempSalesLine."Shipment Date" := 0D;
                TempSalesLine."GMM Bill Doc No." := '';
                TempSalesLine."GMM External Doc No." := pTempSalesHeader."External Document No.";
                if PostedReturnReceipt."Ship-to Code" <> '' then
                    TempSalesLine."GMM Ship to Code" := pTempSalesHeader."Ship-to Code"
                else
                    TempSalesLine."GMM Ship to Code" := pTempSalesHeader."Sell-to Customer No.";
                TempSalesLine."GMM Ship to Name" := pTempSalesHeader."Ship-to Name";
                TempSalesLine."GMM Trp. Plan Date" := pTempSalesHeader."Shipment Date";
                if (pTempSalesHeader."GMM Completely Shipment") and (pTempSalesHeader."GMM Qty. Rcd. Not Invoiced" = 0) then
                    TempSalesLine."GMM GM" := 'C'
                else
                    TempSalesLine."GMM GM" := 'B';

                TempSalesLine."GMM Sold-to-pt" := pTempSalesHeader."Bill-to Customer No.";
                TempSalesLine."GMM Name Sold-to-pt" := pTempSalesHeader."Bill-to Name";
                TempSalesLine."GMM Route" := pTempSalesHeader."Shipping Agent Code";
                TempSalesLine.Quantity := ltTotalQty;
                TempSalesLine.Amount := TotalAmt;
                TempSalesLine."Unit Cost" := UnitCost;
                if TempSalesLine."GMM GM" = 'C' then
                    TempSalesLine."GMM Status" := 'CN'
                else
                    TempSalesLine."GMM Status" := 'CN Partial';
                TempSalesLine."GMM Address" := pTempSalesHeader."Ship-to Address" + ' ' + pTempSalesHeader."Ship-to Address 2" + ' ' + pTempSalesHeader."Ship-to City" + ' ' + pTempSalesHeader."Ship-to Post Code";
                TempSalesLine."GMM Phone No." := pTempSalesHeader."TPP Ship-to Phone No.";
                TempSalesLine.Insert();
            end;
        end else begin
            LineNo := LineNo + 1;
            ltSalesLine.reset();
            ltSalesLine.SetRange("Document Type", pTempSalesHeader."Document Type");
            ltSalesLine.SetRange("DOcument No.", pTempSalesHeader."No.");
            ltSalesLine.CalcSums(Quantity, Amount, "Unit Cost");
            ltTotalQty := ltSalesLine.Quantity;
            TotalAmt := ltSalesLine.Amount;
            UnitCost := ltsalesLine."Unit Cost";
            TempSalesLine.init();
            TempSalesLine."Document Type" := pTempSalesHeader."Document Type";
            TempSalesLine."Document No." := pTempSalesHeader."No.";
            TempSalesLine."GMM Order Date" := pTempSalesHeader."Order Date";
            TempSalesLine."Line No." := LineNo;
            TempSalesLine."Shipment No." := '';
            TempSalesLine."Shipment Date" := 0D;
            TempSalesLine."GMM Bill Doc No." := '';
            TempSalesLine."GMM External Doc No." := pTempSalesHeader."External Document No.";
            if pTempSalesHeader."Ship-to Code" <> '' then
                TempSalesLine."GMM Ship to Code" := pTempSalesHeader."Ship-to Code"
            else
                TempSalesLine."GMM Ship to Code" := pTempSalesHeader."Sell-to Customer No.";
            TempSalesLine."GMM Ship to Name" := pTempSalesHeader."Ship-to Name";
            TempSalesLine."GMM Trp. Plan Date" := pTempSalesHeader."Shipment Date";
            TempSalesLine."GMM GM" := '';
            TempSalesLine."GMM Sold-to-pt" := pTempSalesHeader."Bill-to Customer No.";
            TempSalesLine."GMM Name Sold-to-pt" := pTempSalesHeader."Bill-to Name";
            TempSalesLine."GMM Route" := pTempSalesHeader."Shipping Agent Code";
            TempSalesLine.Quantity := ltTotalQty;
            TempSalesLine.Amount := -TotalAmt;
            TempSalesLine."Unit Cost" := UnitCost;
            TempSalesLine."GMM Status" := '';
            TempSalesLine."GMM Address" := pTempSalesHeader."Ship-to Address" + ' ' + pTempSalesHeader."Ship-to Address 2" + ' ' + pTempSalesHeader."Ship-to City" + ' ' + pTempSalesHeader."Ship-to Post Code";
            TempSalesLine."GMM Phone No." := pTempSalesHeader."TPP Ship-to Phone No.";
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
        TempSalesHeader: Record "Sales Header" temporary;
        gvPostedSalesShipment: Record "Sales Shipment Header";
        gvPostedSalesReturnReceipt: Record "Return Receipt Header";
        PostedSalesInvoice: Record "Sales Invoice Header";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueENtry: Record "Value Entry";
        LineNo: Integer;
        ValueGroupping: query "Groupping Value Entry";
        TotalRec: Integer;



}
