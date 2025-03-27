page 50092 "BA Item Block Reason"
{
    PageType = StandardDialog;
    Caption = 'Enter Blocked Reason';

    layout
    {
        area(Content)
        {
            field(BlockReason; BlockReason)
            {
                ApplicationArea = all;
                ShowMandatory = true;
                ShowCaption = false;
            }
        }
    }

    var
        BlockReason: Text[250];

    procedure GetBlockedReason(): Text
    begin
        exit(BlockReason);
    end;
}