report 50088 "BA Shipment Tracking Info"
{
    Caption = 'Shipment Tracking Info';
    UseRequestPage = false;
    WordLayout = './Objects/ReportLayouts/ShipmentTrackingInfo.docx';
    DefaultLayout = Word;

    dataset
    {
        dataitem(CompInfoInt; Integer)
        {
            DataItemTableView = sorting (Number) where (Number = const (1));

            column(CompName; CompInfo.Name) { }
            column(CompAddress; CompInfo.Address) { }
            column(CompAddress2; CompInfo."Address 2") { }
            column(CompCity; CompInfo.City) { }
            column(CompState; CompInfo.County) { }
            column(CompCountry; CompInfo."Name 2") { }
            column(CompPostCode; CompInfo."Post Code") { }
            column(CompWebsite; CompInfo."Home Page") { }
            column(CompEmail; CompInfo."BA Ship-To Email") { }
            column(CompPhoneNo; CompInfo."BA Ship-To Phone No.") { }


            trigger OnAfterGetRecord()
            var
                CountryRegion: Record "Country/Region";
            begin
                CompInfo.Get('');
                CountryRegion.Get(CompInfo."Country/Region Code");
                CompInfo."Name 2" := CountryRegion.Name;
            end;
        }
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            column(SalesInvHeader_No; "No.") { }
            column(SalesInvHeader_OrderNo; "Order No.") { }
            column(SalesInvHeader_ExtDocNo; "External Document No.") { }
            column(SalesInvHeader_PackageTrackingNo; "Package Tracking No.") { }
            column(SalesInvHeader_PackageTrackingURL; TrackingURL) { }
            column(SalesInvHeader_FreightCarrier; ShipAgentName) { }
            column(SalesInvHeader_CustDetails; StrSubstNo(CustTok, "Sell-to Customer No.", "Sell-to Customer Name")) { }

            trigger OnPreDataItem()
            begin
                if SalesInvoiceHeader.GetFilters() = '' then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            var
                ShippingAgent: Record "Shipping Agent";
            begin
                if ShippingAgent.Get(SalesInvoiceHeader."Shipping Agent Code") then
                    ShipAgentName := ShippingAgent.Name
                else
                    ShipAgentName := '';
                TrackingURL := GetShippingAgentTrackingURL(SalesInvoiceHeader."Shipping Agent Code");
                if TrackingURL <> '' then
                    if SalesInvoiceHeader."Package Tracking No." <> '' then
                        TrackingURL := StrSubstNo(TrackingLbl, TrackingURL, SalesInvoiceHeader."Package Tracking No.")
                    else
                        TrackingURL := '';
            end;
        }
        dataitem(ServiceInvoiceHeader; "Service Invoice Header")
        {
            column(ServiceInvHeader_No; "No.") { }
            column(ServiceInvHeader_OrderNo; "Order No.") { }
            column(ServiceInvHeader_ExtDocNo; "ENC External Document No.") { }
            column(ServiceInvHeader_PackageTrackingNo; "ENC Package Tracking No.") { }
            column(ServiceInvHeader_PackageTrackingURL; TrackingURL) { }
            column(ServiceInvHeader_FreightCarrier; ShipAgentName) { }
            column(ServiceInvHeader_CustDetails; StrSubstNo(CustTok, "Customer No.", "Name")) { }

            trigger OnPreDataItem()
            begin
                if ServiceInvoiceHeader.GetFilters() = '' then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            var
                ShippingAgent: Record "Shipping Agent";
            begin
                if ShippingAgent.Get(ServiceInvoiceHeader."ENC Shipping Agent Code") then
                    ShipAgentName := ShippingAgent.Name
                else
                    ShipAgentName := '';
                TrackingURL := GetShippingAgentTrackingURL(ServiceInvoiceHeader."ENC Shipping Agent Code");
                if TrackingURL <> '' then
                    if ServiceInvoiceHeader."ENC Package Tracking No." <> '' then
                        TrackingURL := StrSubstNo(TrackingLbl, TrackingURL, ServiceInvoiceHeader."ENC Package Tracking No.")
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
        CompInfo: Record "Company Information";
        TrackingURL: Text;
        ShipAgentName: Text;

        TrackingLbl: Label 'Tracking URL: %1%2';
        CustTok: Label '%1 - %2';
}