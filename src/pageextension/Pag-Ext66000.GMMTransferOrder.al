pageextension 66000 "GMM Transfer Order" extends "Transfer Order"
{
    PromotedActionCategories = 'New,Process,Report,Release,Posting,Order,Documents,Print/Send,Navigate,Ready to Scan';
    layout
    {
        addlast(General)
        {
            field("Total Quantity"; rec."Total Quantity")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the value of the Total Quantity field.';
            }
        }
        addafter(General)
        {
            group(Barcode)
            {
                Caption = 'Barcodes';

                field(gvBarcode; gvBarcode)
                {
                    Caption = 'Scan Barcode';
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Scan Barcode field.';
                    QuickEntry = true;
                    trigger OnValidate()
                    begin
                        if not gvReadyToScan then begin
                            Message('Ready to Scan must be true , current value = false');
                            exit;
                        end;
                        if gvBarcode <> '' then
                            rec.ScanBarcode(gvBarcode, gvQuantity);
                        gvBarcode := '';
                    end;
                }
                field(gvQuantity; gvQuantity)
                {
                    Caption = 'Quantity';
                    ApplicationArea = all;
                    Editable = not gvReadyToScan;
                    MinValue = 1;
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field("Item No"; rec."Item No")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Item No field.';
                    Editable = not gvReadyToScan;
                }
                field(Description; rec.Description)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Description field.';
                    Editable = not gvReadyToScan;
                }
                field("Transfer From Bin Code"; rec."Transfer From Bin Code")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Transfer from Bin Code field.';
                    Editable = not gvReadyToScan;
                }
                field("Transfer to Bin Code"; rec."Transfer to Bin Code")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Transfer to Bin Code field.';
                    Editable = not gvReadyToScan;
                }
                field("Unit of Measure"; rec."Unit of Measure")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Unit of Measure field.';
                    Editable = not gvReadyToScan;
                }
                field("Last Qty to Transfer"; rec."Last Qty to Transfer")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Last Qty to Transfer field.';
                    Editable = not gvReadyToScan;
                }
                field("Scan Barcode Status"; rec."Scan Barcode Status")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Status field.';
                    Editable = not gvReadyToScan;
                }

            }
        }
        addlast("Transfer-from")
        {
            field("From Phone No."; rec."From Phone No.")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the value of the From Phone No. field.';
                Editable = not gvReadyToScan;
            }
        }
        addlast("Transfer-To")
        {
            field("To Phone No."; rec."To Phone No.")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the value of the To Phone No. field.';
                Editable = not gvReadyToScan;
            }
        }
        modify(General)
        {
            Enabled = NOT gvReadyToScan;
        }
        modify(TransferLines)
        {
            Enabled = not gvReadyToScan;
        }
        modify(Shipment)
        {
            Enabled = not gvReadyToScan;
        }
        modify("Transfer-from")
        {
            Enabled = not gvReadyToScan;
        }
        modify("Transfer-to")
        {
            Enabled = not gvReadyToScan;
        }
        modify(Control19)
        {
            Enabled = not gvReadyToScan;
        }
        modify("Foreign Trade")
        {
            Enabled = not gvReadyToScan;
        }
    }
    actions
    {
        addfirst(processing)
        {
            action(ReadyToScan)
            {
                Caption = 'Ready to Scan';
                Image = Approval;
                Promoted = true;
                PromotedCategory = Category10;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Executes the Ready to Scan action.';
                trigger OnAction()
                begin
                    CheckFieldBeforScan();
                    gvReadyToScan := true;
                    CurrPage.Update(false);
                end;
            }
            action(NotReadyToScan)
            {
                Caption = 'Not Ready to Scan';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Category10;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Executes the Not Ready to Scan action.';
                trigger OnAction()
                begin
                    gvReadyToScan := false;
                    CurrPage.Update(false);
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        gvQuantity := 1;
        gvReadyToScan := false;
    end;

    local procedure CheckFieldBeforScan()
    begin
        rec.TestField("Unit of Measure");
    end;

    var
        gvBarcode: code[50];
        gvQuantity: Decimal;
        gvITemNo: code[20];
        gvReadyToScan: Boolean;

}
