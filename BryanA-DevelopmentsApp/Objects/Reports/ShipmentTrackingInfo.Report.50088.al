report 50088 "BA Shipment Tracking Info"
{
    Caption = 'Shipment Tracking Info';
    UseRequestPage = false;
    WordLayout = './Objects/ReportLayouts/ShipmentTrackingInfo.docx';
    DefaultLayout = Word;

    dataset
    {
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            column(SalesInvHeader_No; "No.") { }
            column(SalesInvHeader_OrderNo; "Order No.") { }
            column(SalesInvHeader_ExtDocNo; "External Document No.") { }
            column(SalesInvHeader_PackageTrackingNo; "Package Tracking No.") { }
            column(SalesInvHeader_PackageTrackingURL; TrackingURL) { }
            column(SalesInvHeader_FreightCarrier; "Shipping Agent Code") { }

            trigger OnAfterGetRecord()
            begin
                TrackingURL := GetShippingAgentTrackingURL(SalesInvoiceHeader."Shipping Agent Code");
                if TrackingURL <> '' then
                    if SalesInvoiceHeader."Package Tracking No." <> '' then
                        TrackingURL += SalesInvoiceHeader."Package Tracking No."
                    else
                        TrackingURL := '';
            end;
        }
        dataitem(SerInvHeader; "Service Invoice Header")
        {

        }
    }


    local procedure GetShippingAgentTrackingURL(AgentCode: Code[10]): Text
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        if ShippingAgent.Get(AgentCode) then
            exit(ShippingAgent."Internet Address")
    end;

    var
        TrackingURL: Text;
}