pageextension 66002 "GMM Transfer GMM Sales Role" extends "GMM Sale order processor "
{
    actions
    {
        addafter(GMMShipment)
        {
            action(ImportTransferOrder)
            {
                Caption = 'Import Transfer Order';
                ApplicationArea = all;
                RunObject = report "GMM Import Transfer Order";
                ToolTip = 'Executes the Import Transfer Order action.';
            }
        }
    }
}
