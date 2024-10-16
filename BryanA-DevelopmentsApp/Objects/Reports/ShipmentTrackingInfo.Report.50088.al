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

            trigger OnPreDataItem()
            begin
                if SalesInvoiceHeader.GetFilters() = '' then
                    CurrReport.Break();
            end;

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
        dataitem(ServiceInvoiceHeader; "Service Invoice Header")
        {
            column(ServiceInvHeader_No; "No.") { }
            column(ServiceInvHeader_OrderNo; "Order No.") { }
            column(ServiceInvHeader_ExtDocNo; "External Document No.") { }
            column(ServiceInvHeader_PackageTrackingNo; "ENC Package Tracking No.") { }
            column(ServiceInvHeader_PackageTrackingURL; TrackingURL) { }
            column(ServiceInvHeader_FreightCarrier; ServiceInvoiceHeader."ENC Shipping Agent Code") { }

            trigger OnPreDataItem()
            begin
                if ServiceInvoiceHeader.GetFilters() = '' then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            begin
                TrackingURL := GetShippingAgentTrackingURL(ServiceInvoiceHeader."ENC Shipping Agent Code");
                if TrackingURL <> '' then
                    if ServiceInvoiceHeader."ENC Package Tracking No." <> '' then
                        TrackingURL += ServiceInvoiceHeader."ENC Package Tracking No."
                    else
                        TrackingURL := '';
            end;
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