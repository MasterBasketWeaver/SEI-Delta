codeunit 75011 "BA Install Codeunit"
{
    Subtype = Install;
    Permissions = tabledata "Sales Invoice Header" = rm,
                  tabledata "Service Invoice Header" = rm,
                  tabledata "Transfer Shipment Header" = rm,
                  tabledata Customer = m,
                  tabledata "Purch. Inv. Header" = m,
                  tabledata "Purch. Cr. Memo Hdr." = m,
                  tabledata "Purch. Rcpt. Header" = m,
                  tabledata "Purchase Header" = m,
                  tabledata "Tax Group" = m;

    trigger OnInstallAppPerCompany()
    begin
        // AddItemJnlApprovalCode();
        // AddCustomerSalesActivity();
        // AddNewDimValues();
        // PopulateDropDownFields();
        // AddJobQueueFailNotificationSetup();
        // PopulateCustomerPostingGroupCurrencies();
        // PopulateCountryRegionDimensions();
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
        PopulateCustomerApprovalGroups();
        PopulateProdOrderNotificationReportUsage();
        PopulatePrepyamentInvReportUsage();
    end;



    local procedure PopulatePrepyamentInvReportUsage()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        ReportSelections: Record "Report Selections";
        Subscribers: Codeunit "BA SEI Subscibers";
    begin
        if not AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Report, 50015) then
            exit;
        ReportSelections.SetRange(Usage, Subscribers.GetPrepaymentInvoiceReportUsage());
        ReportSelections.SetRange("Report ID", 50015);
        if not ReportSelections.IsEmpty() then
            exit;
        ReportSelections.Init();
        ReportSelections.Validate(Usage, Subscribers.GetPrepaymentInvoiceReportUsage());
        ReportSelections.Validate(Sequence, '1');
        ReportSelections.Validate("Report ID", 50015);
        ReportSelections.Validate("Use for Email Attachment", true);
        ReportSelections.Validate("Use for Email Body", false);
        ReportSelections.Insert(true);
    end;





    local procedure PopulateProdOrderNotificationReportUsage()
    var
        ReportSelections: Record "Report Selections";
        SalesApprovalMgt: Codeunit "BA Sales Approval Mgt.";
    begin
        ReportSelections.SetRange(Usage, SalesApprovalMgt.GetProdApprovalReportUsage());
        ReportSelections.SetRange("Report ID", Report::"BA Prod. Order Approval");
        if not ReportSelections.IsEmpty() then
            exit;
        ReportSelections.Init();
        ReportSelections.Validate(Usage, SalesApprovalMgt.GetProdApprovalReportUsage());
        ReportSelections.Validate(Sequence, '1');
        ReportSelections.Validate("Report ID", Report::"BA Prod. Order Approval");
        ReportSelections.Validate("Use for Email Attachment", false);
        ReportSelections.Validate("Use for Email Body", true);
        ReportSelections.Insert(true);
    end;


    local procedure PopulateCustomerApprovalGroups()
    var
        Customer: Record Customer;
        ApprovalGroup: Record "BA Approval Group";
        SalesApprovalMgt: Codeunit "BA Sales Approval Mgt.";
    begin
        PopulateApprovalGroups();
        Customer.SetRange("BA Approval Group", '');
        if Customer.FindSet(true) then
            repeat
                SalesApprovalMgt.UpdateCustomerApprovalGroup(Customer, false);
            until Customer.Next() = 0;
    end;

    local procedure PopulateApprovalGroups()
    var
        ApprovalGroup: Record "BA Approval Group";
    begin
        if not ApprovalGroup.Get('A') then begin
            ApprovalGroup.Init();
            ApprovalGroup.Code := 'A';
            ApprovalGroup.Description := 'Prepaid';
            ApprovalGroup."Is Prepaid" := true;
            ApprovalGroup.Insert();
        end;

        if not ApprovalGroup.Get('B') then begin
            ApprovalGroup.Init();
            ApprovalGroup.Code := 'B';
            ApprovalGroup.Description := 'Net XX';
            Evaluate(ApprovalGroup."Overdue Date Formula", '<15D>');
            ApprovalGroup.Insert();
        end;

        if not ApprovalGroup.Get('C') then begin
            ApprovalGroup.Init();
            ApprovalGroup.Code := 'C';
            ApprovalGroup.Description := 'Military/Government';
            ApprovalGroup."Is Military" := true;
            ApprovalGroup."Is Government" := true;
            ApprovalGroup.Insert();
        end;

        if not ApprovalGroup.Get('D') then begin
            ApprovalGroup.Init();
            ApprovalGroup.Code := 'D';
            ApprovalGroup.Description := 'Trusted Agent';
            ApprovalGroup."Is Trusted Agent" := true;
            Evaluate(ApprovalGroup."Overdue Date Formula", '<30D>');
            ApprovalGroup.Insert();
        end;

        if not ApprovalGroup.Get('TBD') then begin
            ApprovalGroup.Init();
            ApprovalGroup.Code := 'TBD';
            ApprovalGroup.Description := 'To be determined';
            ApprovalGroup.Insert();
        end;
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

    procedure PopulateDropDownFields()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TransferShptHeader: Record "Transfer Shipment Header";
        FreightTerm: Record "ENC Freight Term";
        ShippingAgent: Record "Shipping Agent";
        DocNos1: List of [RecordID];
        DocNos2: List of [RecordID];
        DocNos3: List of [RecordID];
        RecID: RecordId;
    begin
        SalesInvoiceHeader.SetRange("BA Order No. DrillDown", '');
        if SalesInvoiceHeader.FindSet(true) then
            repeat
                if not DocNos1.Contains(SalesInvoiceHeader.RecordId()) then
                    DocNos1.Add(SalesInvoiceHeader.RecordId());
            until SalesInvoiceHeader.Next() = 0;
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetRange("BA Ext. Doc. No. DrillDown", '');
        if SalesInvoiceHeader.FindSet(true) then
            repeat
                if not DocNos1.Contains(SalesInvoiceHeader.RecordId()) then
                    DocNos1.Add(SalesInvoiceHeader.RecordId());
            until SalesInvoiceHeader.Next() = 0;
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetRange("BA Ship-to Name DrillDown", '');
        if SalesInvoiceHeader.FindSet(true) then
            repeat
                if not DocNos1.Contains(SalesInvoiceHeader.RecordId()) then
                    DocNos1.Add(SalesInvoiceHeader.RecordId());
            until SalesInvoiceHeader.Next() = 0;
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetFilter("Shipping Agent Code", '<>%1', '');
        SalesInvoiceHeader.SetRange("BA Freight Carrier Name", '');
        if SalesInvoiceHeader.FindSet(true) then
            repeat
                if not DocNos1.Contains(SalesInvoiceHeader.RecordId()) then
                    DocNos1.Add(SalesInvoiceHeader.RecordId());
            until SalesInvoiceHeader.Next() = 0;
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetFilter("ENC Freight Term", '<>%1', '');
        SalesInvoiceHeader.SetRange("BA Freight Term Name", '');
        if SalesInvoiceHeader.FindSet(true) then
            repeat
                if not DocNos1.Contains(SalesInvoiceHeader.RecordId()) then
                    DocNos1.Add(SalesInvoiceHeader.RecordId());
            until SalesInvoiceHeader.Next() = 0;
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetRange("BA Posting Date DrillDown", 0D);
        if SalesInvoiceHeader.FindSet(true) then
            repeat
                if not DocNos1.Contains(SalesInvoiceHeader.RecordId()) then
                    DocNos1.Add(SalesInvoiceHeader.RecordId());
            until SalesInvoiceHeader.Next() = 0;
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetRange("BA Bill-to Name DrillDown", '');
        if SalesInvoiceHeader.FindSet(true) then
            repeat
                if not DocNos1.Contains(SalesInvoiceHeader.RecordId()) then
                    DocNos1.Add(SalesInvoiceHeader.RecordId());
            until SalesInvoiceHeader.Next() = 0;
        foreach RecID in DocNos1 do begin
            SalesInvoiceHeader.Get(RecID);
            SalesInvoiceHeader."BA Order No. DrillDown" := SalesInvoiceHeader."Order No.";
            SalesInvoiceHeader."BA Ext. Doc. No. DrillDown" := SalesInvoiceHeader."External Document No.";
            SalesInvoiceHeader."BA Ship-to Name DrillDown" := SalesInvoiceHeader."Ship-to Name";
            if (SalesInvoiceHeader."Shipping Agent Code" <> '') and ShippingAgent.Get(SalesInvoiceHeader."Shipping Agent Code") then
                SalesInvoiceHeader."BA Freight Carrier Name" := ShippingAgent.Name;
            if (SalesInvoiceHeader."ENC Freight Term" <> '') and FreightTerm.Get(SalesInvoiceHeader."ENC Freight Term") then
                SalesInvoiceHeader."BA Freight Term Name" := FreightTerm.Description;
            SalesInvoiceHeader."BA Posting Date DrillDown" := SalesInvoiceHeader."Posting Date";
            SalesInvoiceHeader."BA Bill-to Name DrillDown" := SalesInvoiceHeader."Bill-to Name";
            SalesInvoiceHeader.Modify(false);
        end;



        ServiceInvoiceHeader.SetRange("BA Order No. DrillDown", '');
        if ServiceInvoiceHeader.FindSet(true) then
            repeat
                if not DocNos2.Contains(ServiceInvoiceHeader.RecordId()) then
                    DocNos2.Add(ServiceInvoiceHeader.RecordId());
            until ServiceInvoiceHeader.Next() = 0;
        ServiceInvoiceHeader.Reset();
        ServiceInvoiceHeader.SetRange("BA Ship-to Name DrillDown", '');
        if ServiceInvoiceHeader.FindSet(true) then
            repeat
                if not DocNos2.Contains(ServiceInvoiceHeader.RecordId()) then
                    DocNos2.Add(ServiceInvoiceHeader.RecordId());
            until ServiceInvoiceHeader.Next() = 0;
        ServiceInvoiceHeader.Reset();
        ServiceInvoiceHeader.SetFilter("ENC Shipping Agent Code", '<>%1', '');
        ServiceInvoiceHeader.SetRange("BA Freight Carrier Name", '');
        if ServiceInvoiceHeader.FindSet(true) then
            repeat
                if not DocNos2.Contains(ServiceInvoiceHeader.RecordId()) then
                    DocNos2.Add(ServiceInvoiceHeader.RecordId());
            until ServiceInvoiceHeader.Next() = 0;
        ServiceInvoiceHeader.Reset();
        ServiceInvoiceHeader.SetFilter("ENC Freight Term", '<>%1', '');
        ServiceInvoiceHeader.SetRange("BA Freight Term Name", '');
        if ServiceInvoiceHeader.FindSet(true) then
            repeat
                if not DocNos2.Contains(ServiceInvoiceHeader.RecordId()) then
                    DocNos2.Add(ServiceInvoiceHeader.RecordId());
            until ServiceInvoiceHeader.Next() = 0;
        ServiceInvoiceHeader.Reset();
        ServiceInvoiceHeader.SetRange("BA Posting Date DrillDown", 0D);
        if ServiceInvoiceHeader.FindSet(true) then
            repeat
                if not DocNos2.Contains(ServiceInvoiceHeader.RecordId()) then
                    DocNos2.Add(ServiceInvoiceHeader.RecordId());
            until ServiceInvoiceHeader.Next() = 0;
        ServiceInvoiceHeader.Reset();
        ServiceInvoiceHeader.SetRange("BA Bill-to Name DrillDown", '');
        if ServiceInvoiceHeader.FindSet(true) then
            repeat
                if not DocNos2.Contains(ServiceInvoiceHeader.RecordId()) then
                    DocNos2.Add(ServiceInvoiceHeader.RecordId());
            until ServiceInvoiceHeader.Next() = 0;
        foreach RecID in DocNos2 do begin
            ServiceInvoiceHeader.Get(RecID);
            ServiceInvoiceHeader."BA Order No. DrillDown" := ServiceInvoiceHeader."Order No.";
            if (ServiceInvoiceHeader."ENC Shipping Agent Code" <> '') and ShippingAgent.Get(ServiceInvoiceHeader."ENC Shipping Agent Code") then
                ServiceInvoiceHeader."BA Freight Carrier Name" := ShippingAgent.Name;
            if (ServiceInvoiceHeader."ENC Freight Term" <> '') and FreightTerm.Get(ServiceInvoiceHeader."ENC Freight Term") then
                ServiceInvoiceHeader."BA Freight Term Name" := FreightTerm.Description;
            ServiceInvoiceHeader."BA Posting Date DrillDown" := ServiceInvoiceHeader."Posting Date";
            ServiceInvoiceHeader."BA Ship-to Name DrillDown" := ServiceInvoiceHeader."Ship-to Name";
            ServiceInvoiceHeader."BA Bill-to Name DrillDown" := ServiceInvoiceHeader."Bill-to Name";
            ServiceInvoiceHeader.Modify(false);
        end;


        TransferShptHeader.SetRange("BA Trans. Order No. DrillDown", '');
        if TransferShptHeader.FindSet(true) then
            repeat
                DocNos3.Add(TransferShptHeader.RecordId());
            until TransferShptHeader.Next() = 0;
        TransferShptHeader.Reset();
        TransferShptHeader.SetFilter("Shipping Agent Code", '<>%1', '');
        TransferShptHeader.SetRange("BA Freight Carrier Name", '');
        if TransferShptHeader.FindSet(true) then
            repeat
                if not DocNos2.Contains(TransferShptHeader.RecordId()) then
                    DocNos2.Add(TransferShptHeader.RecordId());
            until TransferShptHeader.Next() = 0;
        TransferShptHeader.Reset();
        TransferShptHeader.SetFilter("ENC Freight Term", '<>%1', '');
        TransferShptHeader.SetRange("BA Freight Term Name", '');
        if TransferShptHeader.FindSet(true) then
            repeat
                if not DocNos2.Contains(TransferShptHeader.RecordId()) then
                    DocNos2.Add(TransferShptHeader.RecordId());
            until TransferShptHeader.Next() = 0;
        TransferShptHeader.Reset();
        foreach RecID in DocNos3 do begin
            TransferShptHeader.Get(RecID);
            TransferShptHeader."BA Trans. Order No. DrillDown" := TransferShptHeader."Transfer Order No.";
            if (TransferShptHeader."Shipping Agent Code" <> '') and ShippingAgent.Get(TransferShptHeader."Shipping Agent Code") then
                TransferShptHeader."BA Freight Carrier Name" := ShippingAgent.Name;
            if (TransferShptHeader."ENC Freight Term" <> '') and FreightTerm.Get(TransferShptHeader."ENC Freight Term") then
                TransferShptHeader."BA Freight Term Name" := FreightTerm.Description;
            TransferShptHeader.Modify(false);
        end;

        if GuiAllowed then
            Message('%1, %2, %3', DocNos1.Count, DocNos2.Count, DocNos3.Count);
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

    local procedure AddItemJnlApprovalCode()
    var
        InventorySetup: Record "Inventory Setup";
        ApprovalCode: Record "Approval Code";
    begin
        InventorySetup.Get();
        if (InventorySetup."BA Approval Code" <> '') then
            exit;
        InventorySetup."BA Approval Code" := 'ITEM-JNL';
        InventorySetup.Modify(false);

        if ApprovalCode.Get(InventorySetup."BA Approval Code") then
            exit;
        ApprovalCode.Init();
        ApprovalCode.Validate(Code, InventorySetup."BA Approval Code");
        ApprovalCode.Validate(Description, 'Inventory Adjustment Approvals.');
        ApprovalCode.Validate("Linked To Table No.", Database::"Item Journal Batch");
        ApprovalCode.Insert(true);
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