report 55089 "GMM Import Transfer Order"
{
    Caption = 'Import Transfer Order';
    ProcessingOnly = true;
    ApplicationArea = all;
    UsageCategory = ReportsAndAnalysis;
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                    field(FileName; FileName)
                    {
                        Caption = 'File Name';
                        ApplicationArea = all;
                        ToolTip = 'Specifies the value of the File Name field.';
                        trigger OnAssistEdit()
                        begin
                            UploadIntoStream('Select File', '', '', FileName, Instr);
                            if FileName <> '' then begin
                                Sheetname := gvExcelBuffer.SelectSheetsNameStream(Instr);
                            end else
                                exit;
                        end;
                    }
                    field(SheetName; SheetName)
                    {
                        Caption = 'Sheet Name';
                        ApplicationArea = all;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Sheet Name field.';
                        trigger OnAssistEdit()
                        begin
                            if FileName <> '' then
                                Sheetname := gvExcelBuffer.SelectSheetsNameStream(Instr);

                        end;
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    var
        ltTransferHeader: Record "Transfer Header";
        ltTransferLine: Record "Transfer Line";
        ltItem: Record Item;
        ltBin: Record Bin;
        LastRow, MyLoop : Integer;
        InvenSetUp: Record "Inventory Setup";
        NoseriesMgt: Codeunit NoSeriesManagement;
        CurrDateTime: DateTime;
        ltPostingDate: Date;
        ltQty: Decimal;
        InventoryComment: Record "inventory Comment Line";
    begin
        if FileName <> '' then begin
            CurrDateTime := CurrentDateTime();
            InvenSetUp.GET();
            InvenSetUp.TestField("Transfer Order Nos.");
            gvExcelBuffer.reset();
            gvExcelBuffer.DeleteAll();
            gvExcelBuffer.Reset();
            gvExcelBuffer.OpenBookStream(Instr, Sheetname);
            gvExcelBuffer.ReadSheet();
            Commit();
            CLEAR(GroupByKey);
            ExcelBufferReset.RESET;
            ExcelBufferReset.SETFILTER("Column No.", '%1', 1);
            ExcelBufferReset.SETFILTER("Cell Value as Text", '<>%1', '');
            IF ExcelBufferReset.FINDLAST THEN
                LastRow := ExcelBufferReset."Row No.";
            FOR MyLoop := 2 TO LastRow DO BEGIN
                GroupByKey[1] := GetValueExcel(MyLoop, 1);
                GroupByKey[2] := GetValueExcel(MyLoop, 2);
                GroupByKey[3] := GetValueExcel(MyLoop, 3);
                GroupByKey[4] := GetValueExcel(MyLoop, 4);
                GroupByKey[5] := GetValueExcel(MyLoop, 5);
                GroupByKey[6] := GetValueExcel(MyLoop, 13);
                GroupByKey[7] := GetValueExcel(MyLoop, 14);
                GroupByKey[8] := GetValueExcel(MyLoop, 16);
                ltPostingDate := 0D;
                if Evaluate(ltPostingDate, GroupByKey[5]) then;
                ltTransferHeader.reset();
                ltTransferHeader.SetRange("By Import", true);
                ltTransferHeader.SetRange("Imported DateTime", CurrDateTime);
                ltTransferHeader.SetRange("Order Type", GroupByKey[1]);
                ltTransferHeader.SetRange("DISTRIBUTION CHANNEL", GroupByKey[2]);
                ltTransferHeader.SetRange("Shortcut Dimension 1 Code", GroupByKey[3]);
                ltTransferHeader.SetRange("Shortcut Dimension 2 Code", GroupByKey[4]);
                ltTransferHeader.SetRange("Posting Date", ltPostingDate);
                ltTransferHeader.SetRange("Shipping Agent Code", GroupByKey[6]);
                ltTransferHeader.SetRange("Transfer-from Code", GroupByKey[7]);
                ltTransferHeader.SetRange("Transfer-to Code", GroupByKey[8]);
                if not ltTransferHeader.FindFirst() then begin
                    ltTransferHeader.init();
                    ltTransferHeader."No." := NoseriesMgt.GetNextNo(InvenSetUp."Transfer Order Nos.", WorkDate(), true);
                    ltTransferHeader."No. Series" := InvenSetUp."Transfer Order Nos.";
                    ltTransferHeader."Posting Date" := ltPostingDate;
                    ltTransferHeader."Imported DateTime" := CurrDateTime;
                    ltTransferHeader."By Import" := true;
                    ltTransferHeader.Insert(true);
                    ltTransferHeader.Validate("Transfer-from Code", GroupByKey[7]);
                    ltTransferHeader.Validate("Transfer-to Code", GroupByKey[8]);
                    ltTransferHeader.Validate("Direct Transfer", true);
                    ltTransferHeader.Validate("Shortcut Dimension 1 Code", GroupByKey[3]);
                    ltTransferHeader.Validate("Shortcut Dimension 2 Code", GroupByKey[4]);
                    ltTransferHeader.Validate("Order Type", GroupByKey[1]);
                    ltTransferHeader.Validate("DISTRIBUTION CHANNEL", GroupByKey[2]);
                    ltTransferHeader.Validate("Shipping Agent Code", GroupByKey[6]);
                    if ltBin.GET(ltTransferHeader."Transfer-from Code", GetValueExcel(MyLoop, 15)) then
                        ltTransferHeader.Validate("Transfer from Bin Code", ltBin.Code);

                    if ltBin.GET(ltTransferHeader."Transfer-to Code", GetValueExcel(MyLoop, 17)) then
                        ltTransferHeader.Validate("Transfer to Bin Code", ltBin.Code);

                    if GetValueExcel(MyLoop, 6) <> '' then
                        ltTransferHeader."Transfer-to Name" := GetValueExcel(MyLoop, 6);

                    if GetValueExcel(MyLoop, 7) <> '' then
                        ltTransferHeader."Transfer-to Name 2" := GetValueExcel(MyLoop, 7);
                    if GetValueExcel(MyLoop, 8) <> '' then
                        ltTransferHeader."Transfer-to Address" := GetValueExcel(MyLoop, 8);

                    if GetValueExcel(MyLoop, 9) <> '' then
                        ltTransferHeader."Transfer-to Address 2" := GetValueExcel(MyLoop, 9);
                    if GetValueExcel(MyLoop, 10) <> '' then
                        ltTransferHeader."Transfer-to City" := GetValueExcel(MyLoop, 10);
                    if GetValueExcel(MyLoop, 11) <> '' then
                        ltTransferHeader."Transfer-to Post Code" := GetValueExcel(MyLoop, 11);
                    if GetValueExcel(MyLoop, 12) <> '' then
                        ltTransferHeader."To Phone No." := GetValueExcel(MyLoop, 12);
                    ltTransferHeader.Modify();

                    InventoryComment.Init();
                    InventoryComment."Document Type" := InventoryComment."Document Type"::"Transfer Order";
                    InventoryComment."No." := ltTransferHeader."No.";
                    InventoryComment."Line No." := 10000;
                    InventoryComment.Date := ltPostingDate;
                    InventoryComment.Comment := GetValueExcel(MyLoop, 20);
                    InventoryComment.Insert();
                end;
                ltTransferLine.Init();
                ltTransferLine."Document No." := ltTransferHeader."No.";
                ltTransferLine."Line No." := ltTransferHeader.GetLastTransferLine(ltTransferHeader."No.");
                ltTransferLine.Validate("Item No.", GetValueExcel(MyLoop, 18));
                ltTransferLine.Insert(true);
                ltTransferLine."Transfer-from Bin Code (GMM)" := ltTransferHeader."Transfer from Bin Code";

                if ltTransferHeader."Transfer from Bin Code" <> '' then
                    ltTransferLine.Validate("Transfer-from Bin Code", ltTransferHeader."Transfer from Bin Code");

                if ltTransferHeader."Transfer to Bin Code" <> '' then
                    ltTransferLine.Validate("Transfer-To Bin Code", ltTransferHeader."Transfer to Bin Code");

                if Evaluate(ltQty, GetValueExcel(MyLoop, 19)) then;
                ltTransferLine.Validate(Quantity, ltQty);

                ltTransferLine.Modify();
            end;

            ltTransferHeader.reset();
            ltTransferHeader.SetRange("By Import", true);
            ltTransferHeader.SetRange("Imported DateTime", CurrDateTime);
            if ltTransferHeader.FindFirst() then
                ltTransferHeader.ModifyAll(Status, ltTransferHeader.Status::Released);

        end;
    end;
    /// <summary>
    /// GetValueExcel.
    /// </summary>
    /// <param name="pRowNumber">Integer.</param>
    /// <param name="pColumnNumber">integer.</param>
    /// <returns>Return value of type Text.</returns>
    procedure GetValueExcel(pRowNumber: Integer; pColumnNumber: integer): Text
    var
        ltExcelBuffer: Record "Excel Buffer";
    begin
        IF NOT ltExcelBuffer.GET(pRowNumber, pColumnNumber) THEN
            ltExcelBuffer.INIT;
        EXIT(ltExcelBuffer."Cell Value as Text");
    end;

    var
        gvExcelBuffer, ExcelBufferReset : Record "Excel Buffer";
        GroupByKey: array[8] of code[100];
        Instr: InStream;
        FileName, SheetName : text;
        gText50000: Label 'Type : %1, Posting Date %2 already exist. Do you still wish to continue ?', Locked = true;
        gText50001: Label 'The update has been interupted with respect to user request.';
        gText50002: Label 'The file %1 was imported sucessfully.', Locked = true;
        gText50003: Label 'Overide Single,Overide All';
}
