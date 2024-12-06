codeunit 75011 "BA Install Codeunit"
{
    Subtype = Install;
    Permissions = tabledata "Sales Invoice Header" = r,
                  tabledata "Service Invoice Header" = r,
                  tabledata Customer = m,
                  tabledata "Purch. Inv. Header" = m,
                  tabledata "Purch. Cr. Memo Hdr." = m,
                  tabledata "Purch. Rcpt. Header" = m,
                  tabledata "Purchase Header" = m,
                  tabledata "Tax Group" = m;

    trigger OnInstallAppPerCompany()
    begin
        // AddCustomerSalesActivity();
        // AddNewDimValues();
        // AddJobQueueFailNotificationSetup();
        // PopulateCustomerPostingGroupCurrencies();
        // PopulateCountryRegionDimensions();
        // UpdateItemDescriptions();
        // DefineNonTaxTaxGroup();
        // InitiateDeptCodesPurchaseLookup();
        // PopulateShipmentTrackingInfoReportUsage();
        // PopulateShipToContactDetails();
    end;



    local procedure PopulateShipToContactDetails()
    var
        CompInfo: Record "Company Information";
    begin
        if not CompInfo.Get('') then
            exit;
        if CompInfo.Name = 'SEI Industries' then
            if (CompInfo."BA Ship-To Email" = '') and (CompInfo."BA Ship-To Phone No." = '') then begin
                CompInfo."BA Ship-To Email" := 'shipping@sei-ind.com';
                CompInfo."BA Ship-To Phone No." := '1-866-570-3473';
                CompInfo.Modify(true);
            end;
    end;

    local procedure PopulateShipmentTrackingInfoReportUsage()
    var
        ReportSelections: Record "Report Selections";
        Subscribers: Codeunit "BA SEI Subscibers";
    begin
        ReportSelections.SetRange(Usage, Subscribers.GetShipmentTrackingInfoReportUsage());
        ReportSelections.SetRange("Report ID", Report::"BA Shipment Tracking Info");
        if not ReportSelections.IsEmpty() then
            exit;
        ReportSelections.Init();
        ReportSelections.Validate(Usage, Subscribers.GetShipmentTrackingInfoReportUsage());
        ReportSelections.Validate(Sequence, '1');
        ReportSelections.Validate("Report ID", Report::"BA Shipment Tracking Info");
        ReportSelections.Validate("Use for Email Attachment", false);
        ReportSelections.Validate("Use for Email Body", true);
        ReportSelections.Insert(true);
    end;


    local procedure InitiateDeptCodesPurchaseLookup()
    var
        DeptCode: Record "ENC Department Code";
    begin
        DeptCode.SetRange("Purchasing Lookup", false);
        DeptCode.ModifyAll("Purchasing Lookup", true);
    end;

    local procedure UpdateItemDescriptions()
    var
        Item: Record Item;
    begin
        if Item.FindSet() then
            repeat
                Item.Validate(Description);
                Item.Validate("Description 2");
            until Item.Next() = 0;
    end;


    local procedure AddJobQueueFailNotificationSetup()
    var
        NotificationSetup: Record "Notification Setup";
    begin
        NotificationSetup.SetRange("Notification Type", NotificationSetup."Notification Type"::"Job Queue Fail");
        if not NotificationSetup.IsEmpty() then
            exit;
        NotificationSetup.Init();
        NotificationSetup.Validate("Notification Type", NotificationSetup."Notification Type"::"Job Queue Fail");
        NotificationSetup.Validate("Notification Method", NotificationSetup."Notification Method"::Email);
        NotificationSetup.Validate("Display Target", NotificationSetup."Display Target"::Windows);
        NotificationSetup.Insert(true);
    end;

    local procedure AddNewDimValues()
    var
        CompInfo: Record "Company Information";
        RecRef: RecordRef;
    begin
        if not CompInfo.Get() or CompInfo."BA Populated Dimensions" then
            exit;
        RecRef.Open(Database::"Purchase Header");
        AddNewDimValues(RecRef);
        RecRef.Open(Database::"Purch. Cr. Memo Hdr.");
        AddNewDimValues(RecRef);
        RecRef.Open(Database::"Purch. Inv. Header");
        AddNewDimValues(RecRef);
        RecRef.Open(Database::"Purch. Rcpt. Header");
        AddNewDimValues(RecRef);
        CompInfo."BA Populated Dimensions" := true;
        CompInfo.Modify(false);
    end;


    procedure AddNewDimValues(var RecRef: RecordRef)
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        RecIDs: List of [RecordID];
        RecID: RecordId;
        FldRef: FieldRef;
        FldRef2: FieldRef;
        DimSetID: Integer;
        ProductIDFldNo: Integer;
        ProjectFldNo: Integer;
    begin
        ProductIDFldNo := 80100;
        ProjectFldNo := 80101;
        if not RecRef.FindFirst() or not RecRef.FieldExist(ProductIDFldNo) or not RecRef.FieldExist(ProjectFldNo) then begin
            RecRef.Close();
            exit;
        end;

        FldRef := RecRef.Field(ProductIDFldNo);
        FldRef.SetRange('');
        if RecRef.FindSet() then
            repeat
                TempDimSetEntry.Reset();
                TempDimSetEntry.DeleteAll(false);
                FldRef2 := RecRef.Field(480);
                DimSetID := FldRef2.Value();
                if DimSetID <> 0 then begin
                    DimMgt.GetDimensionSet(TempDimSetEntry, DimSetID);
                    TempDimSetEntry.SetRange("Dimension Code", 'PRODUCT ID');
                    if TempDimSetEntry.FindFirst() then
                        RecIDs.Add(RecRef.RecordId);
                end;
            until RecRef.Next() = 0;
        FldRef.SetRange();

        FldRef := RecRef.Field(ProjectFldNo);
        FldRef.SetRange('');
        if RecRef.FindSet() then
            repeat
                TempDimSetEntry.Reset();
                TempDimSetEntry.DeleteAll(false);
                FldRef2 := RecRef.Field(480);
                DimSetID := FldRef2.Value();
                if DimSetID <> 0 then begin
                    DimMgt.GetDimensionSet(TempDimSetEntry, DimSetID);
                    TempDimSetEntry.SetRange("Dimension Code", 'PROJECT');
                    if TempDimSetEntry.FindFirst() then
                        RecIDs.Add(RecRef.RecordId);
                end;
            until RecRef.Next() = 0;

        foreach RecID in RecIDs do begin
            RecRef.Get(RecID);
            TempDimSetEntry.Reset();
            TempDimSetEntry.DeleteAll(false);
            FldRef2 := RecRef.Field(480);
            DimSetID := FldRef2.Value();
            DimMgt.GetDimensionSet(TempDimSetEntry, DimSetID);
            TempDimSetEntry.SetRange("Dimension Code", 'PRODUCT ID');
            if TempDimSetEntry.FindFirst() then begin
                FldRef := RecRef.Field(ProductIDFldNo);
                FldRef.Value(TempDimSetEntry."Dimension Value Code");
            end;
            TempDimSetEntry.SetRange("Dimension Code", 'PROJECT');
            if TempDimSetEntry.FindFirst() then begin
                FldRef := RecRef.Field(ProjectFldNo);
                FldRef.Value(TempDimSetEntry."Dimension Value Code");
            end;
            RecRef.Modify(false);
        end;
        RecRef.Close();
    end;


    local procedure AddCustomerSalesActivity()
    var
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        VoidDateTime: DateTime;
        SalesDate: Date;
        ServiceDate: Date;
        VoidTime: Time;
        CustDict: Dictionary of [Code[20], Date];
        CustNo: Code[20];
    begin
        Customer.SetRange("BA Last Sales Activity", 0D);
        if not Customer.FindSet(true) then
            exit;
        SalesInvoiceHeader.SetCurrentKey("Posting Date");
        SalesInvoiceHeader.SetAscending("Posting Date", true);
        ServiceInvoiceHeader.SetCurrentKey("Posting Date");
        ServiceInvoiceHeader.SetAscending("Posting Date", true);
        repeat
            SalesInvoiceHeader.SetRange("Bill-to Customer No.", Customer."No.");
            if SalesInvoiceHeader.FindLast() then
                SalesDate := SalesInvoiceHeader."Posting Date"
            else
                SalesDate := 0D;
            ServiceInvoiceHeader.SetRange("Bill-to Customer No.", Customer."No.");
            if ServiceInvoiceHeader.FindLast() then
                ServiceDate := ServiceInvoiceHeader."Posting Date"
            else
                ServiceDate := 0D;
            if SalesDate <> 0D then
                if ServiceDate <> 0D then
                    if SalesDate >= ServiceDate then
                        CustDict.Add(Customer."No.", SalesDate)
                    else
                        CustDict.Add(Customer."No.", ServiceDate)
                else
                    CustDict.Add(Customer."No.", SalesDate)
            else
                if ServiceDate <> 0D then
                    CustDict.Add(Customer."No.", ServiceDate);
        until Customer.Next() = 0;

        foreach CustNo in CustDict.Keys() do begin
            Customer.Get(CustNo);
            CustDict.Get(CustNo, Customer."BA Last Sales Activity");
            Customer.Modify(false);
        end;
    end;

    local procedure PopulateCustomerPostingGroupCurrencies()
    var
        GLSetup: Record "General Ledger Setup";
        CustPostingGroup: Record "Customer Posting Group";
        Currency: Record Currency;
        Codes: list of [Code[10]];
        Code: Code[10];
    begin
        GLSetup.Get();
        CustPostingGroup.SetFilter(Code, '<>%1', GLSetup."LCY Code");
        CustPostingGroup.SetRange("BA Posting Currency", '');
        if CustPostingGroup.FindSet() then
            repeat
                if Currency.Get(CustPostingGroup.Code) then
                    Codes.Add(CustPostingGroup.Code);
            until CustPostingGroup.Next() = 0;
        foreach Code in Codes do begin
            CustPostingGroup.Get(Code);
            CustPostingGroup.Validate("BA Posting Currency", Code);
            CustPostingGroup.Modify(true);
        end;
    end;

    local procedure PopulateCountryRegionDimensions()
    var
        GLSetup: Record "General Ledger Setup";
        Dimension: Record Dimension;
        Update: Boolean;
    begin
        GLSetup.Get();
        if GLSetup."BA Country Code" = '' then
            if Dimension.Get('COUNTRY') and not Dimension.Blocked and not Dimension."ENC Inactive" then begin
                GLSetup.Validate("BA Country Code", Dimension.Code);
                Update := true;
            end;
        if GLSetup."BA Region Code" = '' then
            if Dimension.Get('REGION') and not Dimension.Blocked and not Dimension."ENC Inactive" then begin
                GLSetup.Validate("BA Region Code", Dimension.Code);
                Update := true;
            end;
        if Update then
            GLSetup.Modify(true);
    end;

    local procedure DefineNonTaxTaxGroup()
    var
        TaxGroup: Record "Tax Group";
    begin
        if TaxGroup.Get('NONTAX') then begin
            TaxGroup."BA Non-Taxable" := true;
            TaxGroup.Modify(false);
        end;
    end;
}