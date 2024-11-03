codeunit 75010 "BA SEI Subscibers"
{
    Permissions = tabledata "Return Shipment Header" = rimd,
                  tabledata "Return Shipment Line" = rimd,
                  tabledata "Purch. Rcpt. Header" = rimd,
                  tabledata "Purch. Rcpt. Line" = rimd,
                  tabledata "Sales Shipment Line" = rimd,
                  tabledata "Sales Shipment Header" = rimd,
                  tabledata "Sales Invoice Line" = m,
                  tabledata "Sales Invoice Header" = rimd,
                  tabledata "Sales Cr.Memo Line" = m,
                  tabledata "Sales Cr.Memo Header" = m,
                  tabledata "Service Invoice Header" = rimd,
                  tabledata "Service Invoice Line" = m,
                  tabledata "Service Cr.Memo Header" = m,
                  tabledata "Transfer Shipment Header" = rimd,
                  tabledata "Item Ledger Entry" = rimd,
                  tabledata "Approval Entry" = m,
                  tabledata "Posted Deposit Header" = m,
                  tabledata "G/L Entry" = m,
                  tabledata "Cust. Ledger Entry" = m;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnBeforeOnRun', '', false, false)]
    local procedure SalesQuoteToOrderOnBeforeRun(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader."BA Copied Doc." := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Invoice", 'OnBeforeOnRun', '', false, false)]
    local procedure SalesQuoteToInvoiceOnBeforeRun(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader."BA Copied Doc." := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInitRecord', '', false, false)]
    local procedure SalesHeaderOnAfterInitRecord(var SalesHeader: Record "Sales Header")
    var
        SalesRecSetup: Record "Sales & Receivables Setup";
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Quote:
                begin
                    SalesHeader.SetHideValidationDialog(true);
                    SalesHeader.Validate("Order Date", 0D);
                    SalesHeader.Validate("BA Quote Date", Today());
                    SalesHeader.Validate("Shipment Date", 0D);
                    SalesHeader.Validate("ENC Stage", SalesHeader."ENC Stage"::Open);
                end;
            SalesHeader."Document Type"::Order:
                begin
                    SalesHeader.Validate("Shipment Date", 0D);
                    if SalesRecSetup.Get() and (SalesRecSetup."BA Default Reason Code" <> '') then
                        SalesHeader.Validate("Reason Code", SalesRecSetup."BA Default Reason Code");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnCheckItemAvailabilityInLinesOnAfterSetFilters', '', false, false)]
    local procedure SalesHeaderOnCheckItemAvailabilityInLinesOnAfterSetFilters(var SalesLine: Record "Sales Line")
    begin
        SalesLine.SetFilter("Shipment Date", '<>%1', 0D);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure SalesLineOnAfterValidateNo(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
        Item: Record Item;
    begin
        if Rec."No." <> xRec."No." then begin
            ClearShipmentDates(Rec);
            CheckServiceItem(Rec);
        end;
        if (Rec."Document Type" = Rec."Document Type"::Order) and (xRec."No." = '') then
            Rec."BA Booking Date" := WorkDate();
        if (Rec.Type <> Rec.Type::Item) or (Rec."No." = xRec."No.") or not Item.Get(Rec."No.") then
            exit;
        Item.TestField("ENC Not for Sale", false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure SalesLineOnAfterValdiateQuantity(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    begin
        if Rec.Quantity <> xRec.Quantity then
            ClearShipmentDates(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeSalesLineByChangedFieldNo', '', false, false)]
    local procedure SalesHeaderOnBeforeSalesLineByChangedFieldNo(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var IsHandled: Boolean; ChangedFieldNo: Integer)
    var
        AssembleToOrderLink: Record "Assemble-to-Order Link";
    begin
        if (SalesHeader."Shipment Date" = 0D) and AssembleToOrderLink.AsmExistsForSalesLine(SalesLine)
                and (ChangedFieldNo = SalesHeader.FieldNo("Shipment Date")) and (SalesLine."Shipment Date" <> 0D) then
            IsHandled := true;
    end;

    local procedure ClearShipmentDates(var Rec: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        AssembleToOrderLink: Record "Assemble-to-Order Link";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") or Rec.IsTemporary or (SalesHeader."Shipment Date" <> 0D)
                or not (Rec."Document Type" in [Rec."Document Type"::Quote, Rec."Document Type"::Order])
                  or AssembleToOrderLink.AsmExistsForSalesLine(Rec)
                 then
            exit;
        Rec.Validate("Shipment Date", 0D);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Shipment Date', false, false)]
    local procedure SalesLineOnBeforeValdiateShipmentDate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    begin
        Rec.Validate("BA Skip Reservation Date Check", false);
        if (xRec."Shipment Date" <> 0D) and (Rec."Shipment Date" = 0D) then
            CheckToUpdateAssemblyHeaderDates(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Shipment Date', false, false)]
    local procedure SalesLineOnAfterValdiateShipmentDate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        Rec.Validate("BA Skip Reservation Date Check", false);
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") or Rec.IsTemporary or (Rec."Shipment Date" = xRec."Shipment Date")
                or not (Rec."Document Type" in [Rec."Document Type"::Quote, Rec."Document Type"::Order]) then
            exit;
        if Rec."Shipment Date" <> 0D then
            exit;
        Rec.Validate("Planned Delivery Date", 0D);
        Rec.Validate("Planned Shipment Date", 0D);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Post", 'OnBeforeCheckLines', '', false, false)]
    local procedure WhseActivityPostOnBeforeCheckLines(var WhseActivityHeader: Record "Warehouse Activity Header")
    var
        SalesLine: Record "Sales Line";
    begin
        if (WhseActivityHeader."Source Type" <> Database::"Sales Line") or (WhseActivityHeader."Source Subtype" <> WhseActivityHeader."Source Subtype"::"1") then
            exit;
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", WhseActivityHeader."Source No.");
        SalesLine.FindSet(true);
        repeat
            SalesLine."BA Org. Qty. To Ship" := SalesLine."Qty. to Ship";
            SalesLine."BA Org. Qty. To Invoice" := SalesLine."Qty. to Invoice";
            SalesLine.Modify(false);
        until SalesLine.Next() = 0;
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Post", 'OnCodeOnAfterCreatePostedWhseActivDocument', '', false, false)]
    local procedure WhseActivityPostOnAfterWhseActivLineModify(var WhseActivityHeader: Record "Warehouse Activity Header")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        WhseActivityLine.SetRange("Activity Type", WhseActivityHeader.Type);
        WhseActivityLine.SetRange("No.", WhseActivityHeader."No.");
        WhseActivityLine.SetRange("Source Type", Database::"Sales Line");
        WhseActivityLine.SetRange("Source Subtype", WhseActivityLine."Source Subtype"::"1");
        WhseActivityLine.SetFilter("Qty. to Handle", '>%1', 0);
        WhseActivityLine.SetFilter(Quantity, '>%1', 0);
        if not WhseActivityLine.FindSet() then
            exit;

        SalesHeader.Get(SalesHeader."Document Type"::Order, WhseActivityLine."Source No.");
        if not SalesHeader.Invoice then
            repeat
                if SalesLine.Get(SalesLine."Document Type"::Order, WhseActivityLine."Source No.", WhseActivityLine."Source Line No.") then begin
                    SalesLine.Validate("Qty. to Invoice", WhseActivityLine.Quantity);
                    SalesLine.Modify(true);
                end;
            until WhseActivityLine.Next() = 0;

        SalesLine.SetRange("Document No.", WhseActivityLine."Source No.");
        if SalesLine.FindSet() then
            repeat
                WhseActivityLine.SetRange("Source Line No.", SalesLine."Line No.");
                if WhseActivityLine.IsEmpty() then begin
                    if SalesHeader.Invoice then
                        SalesLine.Validate("Qty. to Ship", SalesLine."BA Org. Qty. To Ship");
                    SalesLine.Validate("Qty. to Invoice", SalesLine."BA Org. Qty. To Invoice");
                    SalesLine.Modify(true);
                end;
            until SalesLine.Next() = 0;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly Line Management", 'OnAfterTransferBOMComponent', '', false, false)]
    local procedure AssemblyLineMgtOnAfterTransferBOMComponent(var AssemblyLine: Record "Assembly Line"; BOMComponent: Record "BOM Component")
    begin
        if not BOMComponent."BA Optional" then
            exit;
        AssemblyLine.Validate(Quantity, 0);
        AssemblyLine.Validate("Quantity per", 0);
        AssemblyLine.Validate("BA Optional", true);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterGetNoSeriesCode', '', false, false)]
    local procedure PurchaseHeaderOnAfterGetNoSeriesCode(var PurchHeader: Record "Purchase Header"; var NoSeriesCode: Code[20])
    var
        PurchPaySetup: Record "Purchases & Payables Setup";
    begin
        if not PurchHeader."BA Requisition Order" then
            exit;
        PurchPaySetup.Get();
        case PurchHeader."Document Type" of
            PurchHeader."Document Type"::Order, PurchHeader."Document Type"::Invoice:
                begin
                    PurchPaySetup.TestField("BA Requisition Nos.");
                    NoSeriesCode := PurchPaySetup."BA Requisition Nos.";
                end;
            PurchHeader."Document Type"::"Credit Memo":
                begin
                    PurchPaySetup.TestField("BA Requisition Cr.Memo Nos.");
                    NoSeriesCode := PurchPaySetup."BA Requisition Cr.Memo Nos.";
                end;
            PurchHeader."Document Type"::"Return Order":
                begin
                    PurchPaySetup.TestField("BA Requisition Return Nos.");
                    NoSeriesCode := PurchPaySetup."BA Requisition Return Nos.";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInitRecord', '', false, false)]
    local procedure PurchaseHeaderOnAfterInitRecord(var PurchHeader: Record "Purchase Header")
    var
        PurchPaySetup: Record "Purchases & Payables Setup";
    begin
        if PurchHeader."Expected Receipt Date" = 0D then
            PurchHeader.Validate("Expected Receipt Date", WorkDate());
        if not PurchHeader."BA Requisition Order" then
            exit;
        PurchPaySetup.Get();
        case PurchHeader."Document Type" of
            PurchHeader."Document Type"::Order, PurchHeader."Document Type"::Invoice:
                begin
                    PurchPaySetup.TestField("BA Requisition Receipt Nos.");
                    PurchHeader."Receiving No. Series" := PurchPaySetup."BA Requisition Receipt Nos.";
                    PurchHeader."Posting No. Series" := PurchPaySetup."BA Requisition Receipt Nos.";
                end;
            PurchHeader."Document Type"::"Credit Memo":
                begin
                    PurchPaySetup.TestField("BA Posted Req. Cr.Memo Nos.");
                    PurchHeader."Return Shipment No. Series" := PurchPaySetup."BA Posted Req. Cr.Memo Nos.";
                    PurchHeader."Posting No. Series" := PurchPaySetup."BA Posted Req. Cr.Memo Nos.";
                end;
            PurchHeader."Document Type"::"Return Order":
                begin
                    PurchPaySetup.TestField("BA Req. Return Shipment Nos.");
                    PurchHeader."Return Shipment No. Series" := PurchPaySetup."BA Req. Return Shipment Nos.";
                    PurchHeader."Posting No. Series" := PurchPaySetup."BA Req. Return Shipment Nos.";
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterInitHeaderDefaults', '', false, false)]
    local procedure PurchaseLineOnAfterInitHeaderDefaults(var PurchLine: Record "Purchase Line"; PurchHeader: Record "Purchase Header")
    begin
        if PurchHeader."BA Requisition Order" then
            PurchLine."BA Requisition Order" := true;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post (Yes/No)", 'OnBeforeConfirmPost', '', false, false)]
    local procedure PurchPostYesNoOnBeforeConfirmPost(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean)
    begin
        UpdatePostingConfirmation(PurchaseHeader, HideDialog);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post + Print", 'OnBeforeConfirmPost', '', false, false)]
    local procedure PurchPostPrintOnBeforeConfirmPost(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean)
    begin
        UpdatePostingConfirmation(PurchaseHeader, HideDialog);
    end;

    local procedure UpdatePostingConfirmation(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean)
    begin
        if not PurchaseHeader."BA Requisition Order" then
            exit;
        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Order, PurchaseHeader."Document Type"::Invoice:
                begin
                    HideDialog := true;
                    if not Confirm(StrSubstNo('Receive Requisition Order %1?', PurchaseHeader."No.")) then
                        Error('');
                    PurchaseHeader.Receive := true;
                end;
            PurchaseHeader."Document Type"::"Return Order":
                begin
                    HideDialog := true;
                    if not Confirm(StrSubstNo('Ship Requisition Return Order %1?', PurchaseHeader."No.")) then
                        Error('');
                    PurchaseHeader.Ship := true;
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post (Yes/No)", 'OnRunPreviewOnBeforePurchPostRun', '', false, false)]
    local procedure PurchPostYesNoOnRunPreviewOnBeforePurchPostRun(var PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader.Invoice := not PurchaseHeader."BA Requisition Order";
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostItemLine', '', false, false)]
    local procedure PurchPostOnAfterPostItemLine(PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
        Item: Record Item;
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        CurrencyExchageRate: Record "Currency Exchange Rate";
        ItemCostMgt: Codeunit ItemCostManagement;
        TotalAmount: Decimal;
        LastDirectCost: Decimal;
        FullyPostedReqOrder: Boolean;
    begin
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        FullyPostedReqOrder := PurchaseHeader.Receive and PurchaseHeader."BA Requisition Order";
        if FullyPostedReqOrder and (PurchaseLine."Qty. to Receive" <> 0) then begin
            Item.Get(PurchaseLine."No.");
            GLSetup.Get();
            GLSetup.TestField("Unit-Amount Rounding Precision");
            TotalAmount := PurchaseLine."Unit Cost" * PurchaseLine."Qty. to Receive";
            LastDirectCost := Round(TotalAmount / PurchaseLine."Qty. to Receive", GLSetup."Unit-Amount Rounding Precision");
            if PurchaseHeader."Currency Code" <> '' then
                LastDirectCost := CurrencyExchageRate.ExchangeAmount(LastDirectCost, PurchaseHeader."Currency Code", '', PurchaseHeader."Posting Date");
            ItemCostMgt.UpdateUnitCost(Item, PurchaseLine."Location Code", PurchaseLine."Variant Code",
                LastDirectCost, 0, true, true, false, 0);
        end;
        if Currency.Get(PurchaseLine."Currency Code") and Currency."BA Local Purchase Cost" then
            if PurchaseHeader.Invoice or FullyPostedReqOrder then begin
                Item.Get(PurchaseLine."No.");
                Item.SetLastCurrencyPurchCost(Currency.Code, PurchaseLine."Unit Cost");
                Item.Modify(true);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchRcptLineInsert', '', false, false)]
    local procedure PurchPostOnBeforePurchRcptLineInsert(var PurchLine: Record "Purchase Line"; var PurchRcptLine: Record "Purch. Rcpt. Line")
    var
        PurchLine2: Record "Purchase Line";
        DiscountedAmt: Decimal;
    begin
        PurchLine2.Get(PurchLine.RecordId());
        PurchRcptLine."BA Line Amount" := PurchLine2."Qty. to Receive" * PurchLine2."Direct Unit Cost";
        if PurchLine2."Line Discount %" <> 0 then begin
            DiscountedAmt := PurchRcptLine."BA Line Amount" * (100 - PurchLine2."Line Discount %") / 100;
            PurchRcptLine."BA Line Discount Amount" := PurchRcptLine."BA Line Amount" - DiscountedAmt;
            PurchRcptLine."BA Line Amount" := DiscountedAmt;
        end;
        PurchRcptLine."BA Product ID Code" := PurchLine."BA Product ID Code";
        PurchRcptLine."BA Project Code" := PurchLine."BA Project Code";
        PurchRcptLine."BA Shareholder Code" := PurchLine."BA Shareholder Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeReturnShptLineInsert', '', false, false)]
    local procedure PurchPostOnBeforeReturnShptLineInsert(var PurchLine: Record "Purchase Line"; var ReturnShptLine: Record "Return Shipment Line")
    var
        PurchLine2: Record "Purchase Line";
        DiscountedAmt: Decimal;
    begin
        PurchLine2.Get(PurchLine.RecordId());
        ReturnShptLine."BA Line Amount" := PurchLine2."Return Qty. to Ship" * PurchLine2."Direct Unit Cost";
        if PurchLine2."Line Discount %" <> 0 then begin
            DiscountedAmt := ReturnShptLine."BA Line Amount" * (100 - PurchLine2."Line Discount %") / 100;
            ReturnShptLine."BA Line Discount Amount" := ReturnShptLine."BA Line Amount" - DiscountedAmt;
            ReturnShptLine."BA Line Amount" := DiscountedAmt;
        end;
    end;




    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterFinalizePosting', '', false, false)]
    local procedure PurchPostOnAfterFinalizePosting(var PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        if not PurchHeader."BA Requisition Order" then
            exit;
        case PurchHeader."Document Type" of
            PurchHeader."Document Type"::Order, PurchHeader."Document Type"::Invoice:
                PurchHeader."BA Fully Rec'd. Req. Order" := PurchHeader.QtyToReceiveIsZero();
            PurchHeader."Document Type"::"Return Order":
                begin
                    PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                    PurchLine.SetRange("Document No.", PurchHeader."No.");
                    if PurchLine.FindSet() then
                        repeat
                            if PurchLine."Return Qty. Shipped" <> PurchLine.Quantity then
                                exit;
                        until PurchLine.Next() = 0;
                    PurchHeader."BA Fully Rec'd. Req. Order" := true;
                end;
            else
                exit;
        end;
        PurchHeader.Modify(false);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure PurchLineOnAfterValidateNo(var Rec: Record "Purchase Line")
    var
        Item: Record Item;
        PurchHeader: Record "Purchase Header";
        Currency: Record Currency;
        LastUnitCost: Decimal;
    begin
        if (Rec.Type <> Rec.Type::Item) or Rec.IsTemporary() or (Rec."No." = '') then
            exit;
        PurchHeader.Get(Rec."Document Type", Rec."Document No.");
        if not Currency.Get(PurchHeader."Currency Code") or not Currency."BA Local Purchase Cost" then
            exit;
        Item.Get(Rec."No.");
        LastUnitCost := Item.GetLastCurrencyPurchCost(Currency.Code);
        if LastUnitCost = 0 then
            exit;
        Rec.Validate("Direct Unit Cost", LastUnitCost);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnPrintDocumentsOnAfterSelectTempReportSelectionsToPrint', '', false, false)]
    local procedure ReportSelectionsOnPrintDocumentsOnAfterSelectTempReportSelectionsToPrint(var TempReportSelections: Record "Report Selections"; RecordVariant: Variant)
    var
        PurchHeader: Record "Purchase Header";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecordVariant);
        if RecRef.Number() <> Database::"Purchase Header" then
            exit;
        RecRef.SetTable(PurchHeader);
        if not PurchHeader."BA Requisition Order" then
            exit;
        TempReportSelections.Validate("Report ID", Report::"BA Requisition Order");
        TempReportSelections.Modify(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterValidateEvent', 'Transfer-to Code', false, false)]
    local procedure TransferHeaderOnAfterValidateTransferToCode(var Rec: Record "Transfer Header"; var xRec: Record "Transfer Header")
    var
        Location: Record Location;
    begin
        if Rec.IsTemporary or (Rec."Transfer-to Code" = xRec."Transfer-to Code") or not Location.Get(Rec."Transfer-to Code") then
            exit;
        Rec.Validate("BA Transfer-To Phone No.", Location."Phone No.");
        Rec.Validate("BA Transfer-To FID No.", Location."BA FID No.");
        Rec.Modify(false);
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnAfterCheckSalesApprovalPossible', '', false, false)]
    local procedure ApprovalsMgtOnAfterCheckSalesApprovalPossible(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        CheckIfLinesHaveValidLocationCode(SalesHeader);
        SalesHeader.TestField("Sell-to Customer No.");
        Customer.Get(SalesHeader."Sell-to Customer No.");
        if not Customer."BA Int. Customer" then
            exit;
        SalesHeader.TestField("External Document No.");
        FormatInternationalExtDocNo(SalesHeader."External Document No.", SalesHeader.FieldCaption("External Document No."));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnBeforePostWithLines', '', false, false)]
    local procedure ServicePostOnBeforePostWithLines(var PassedServHeader: Record "Service Header")
    var
        Customer: Record Customer;
    begin
        PassedServHeader.TestField("Customer No.");
        Customer.Get(PassedServHeader."Customer No.");
        if not Customer."BA Serv. Int. Customer" then
            exit;
        PassedServHeader.TestField("ENC External Document No.");
        FormatInternationalExtDocNo(PassedServHeader."ENC External Document No.", PassedServHeader.FieldCaption("External Document No."));
    end;

    local procedure FormatInternationalExtDocNo(var ExtDocNo: Code[35]; FieldCaption: Text)
    var
        Length: Integer;
        i: Integer;
        c: Char;
    begin
        Length := StrLen(ExtDocNo);
        if (ExtDocNo[1] <> 'S') or (ExtDocNo[2] <> 'O') then
            Error(ExtDocNoFormatError, FieldCaption, InvalidPrefixError);
        if Length = 2 then
            Error(ExtDocNoFormatError, FieldCaption, MissingNumeralError);
        if Length < 9 then
            Error(ExtDocNoFormatError, FieldCaption, TooShortSuffixError);
        for i := 3 to Length do begin
            c := ExtDocNo[i];
            if (c > '9') or (c < '0') then
                Error(ExtDocNoFormatError, FieldCaption, StrSubstNo(NonNumeralError, c));
        end;
        if Length > 9 then
            Error(ExtDocNoFormatError, FieldCaption, TooLongSuffixError);
    end;


    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'Customer Posting Group', false, false)]
    local procedure CustomerOnAfterValidateCustomerPostingGroup(var Rec: Record Customer)
    var
        CustPostGroup: Record "Customer Posting Group";
    begin
        if Rec."Customer Posting Group" = '' then
            exit;
        CustPostGroup.Get(Rec."Customer Posting Group");
        if CustPostGroup."BA Blocked" then
            Error(CustGroupBlockedError, CustPostGroup.TableCaption, CustPostGroup.Code);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeAutoReserve', '', false, false)]
    local procedure SalesLineOnBeforeAutoReserve(SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
        if SalesLine."Shipment Date" = 0D then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'Dimension Value Code', false, false)]
    local procedure DefaultDimOnAfterValidateDimValueCode(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension")
    var
        Item: Record Item;
        GLSetup: Record "General Ledger Setup";
    begin
        if (Rec."Dimension Value Code" = xRec."Dimension Value Code") or (Rec."Table ID" <> Database::Item)
                or (Rec."No." = '') or not Item.Get(Rec."No.") then
            exit;
        GLSetup.Get();

        case true of
            Rec."Dimension Code" = GLSetup."Shortcut Dimension 1 Code":
                Item."Global Dimension 1 Code" := Rec."Dimension Value Code";
            Rec."Dimension Code" = GLSetup."Shortcut Dimension 2 Code":
                Item."Global Dimension 2 Code" := Rec."Dimension Value Code";
            Rec."Dimension Code" = GLSetup."Shortcut Dimension 3 Code":
                Item."ENC Shortcut Dimension 3 Code" := Rec."Dimension Value Code";
            Rec."Dimension Code" = GLSetup."Shortcut Dimension 4 Code":
                Item."ENC Shortcut Dimension 4 Code" := Rec."Dimension Value Code";
            Rec."Dimension Code" = GLSetup."Shortcut Dimension 5 Code":
                Item."ENC Shortcut Dimension 5 Code" := Rec."Dimension Value Code";
            Rec."Dimension Code" = GLSetup."Shortcut Dimension 6 Code":
                Item."ENC Shortcut Dimension 6 Code" := Rec."Dimension Value Code";
            Rec."Dimension Code" = GLSetup."Shortcut Dimension 7 Code":
                Item."ENC Shortcut Dimension 7 Code" := Rec."Dimension Value Code";
            Rec."Dimension Code" = GLSetup."Shortcut Dimension 8 Code":
                Item."ENC Shortcut Dimension 8 Code" := Rec."Dimension Value Code";
            Rec."Dimension Code" = GLSetup."ENC Product ID Dim. Code":
                Item."ENC Product ID Code" := Rec."Dimension Value Code";
            else
                exit;
        end;
        Item.Modify(true);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Format Address", 'OnAfterFormatAddress', '', false, false)]
    local procedure FormatAddressOnAfterFormatAddress(var CountryCode: Code[10]; var County: Text[50]; var AddrArray: array[8] of Text)
    var
        ProvinceState: Record "BA Province/State";
        CompInfo: Record "Company Information";
        i: Integer;
    begin
        if CountryCode = '' then begin
            CompInfo.Get('');
            CompInfo.TestField("Country/Region Code");
            CountryCode := CompInfo."Country/Region Code";
        end;

        if not ProvinceState.Get(CountryCode, CopyStr(County, 1, MaxStrLen(ProvinceState.Symbol))) then begin
            ProvinceState.SetRange("Country/Region Code", CountryCode);
            ProvinceState.SetRange(Name, County);
            if not ProvinceState.FindFirst() then
                exit;
        end;
        if not ProvinceState."Print Full Name" then
            exit;

        for i := 1 to 8 do
            if AddrArray[i].Contains(County) then begin
                AddrArray[i] := AddrArray[i].Replace(County, ProvinceState.Name);
                exit;
            end;
    end;




    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Price Calc. Mgt.", 'OnAfterFindSalesPrice', '', false, false)]
    local procedure SalesLineOnAfterFindSalesPrice(var FromSalesPrice: Record "Sales Price"; var ToSalesPrice: Record "Sales Price"; ItemNo: Code[20])
    var
        NewestDate: Date;
    begin
        if (ItemNo = '') or not ToSalesPrice.FindSet() then
            exit;
        NewestDate := ToSalesPrice."Starting Date";
        repeat
            if ToSalesPrice."Starting Date" > NewestDate then
                NewestDate := ToSalesPrice."Starting Date";
        until ToSalesPrice.Next() = 0;
        ToSalesPrice.SetFilter("Starting Date", '<>%1', NewestDate);
        ToSalesPrice.DeleteAll(false);
        ToSalesPrice.SetRange("Starting Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Price Calc. Mgt.", 'OnAfterFindSalesLineItemPrice', '', false, false)]
    local procedure SalesPriceMgtOnAfterFindSalesLineItemPrice(var SalesLine: Record "Sales Line"; var TempSalesPrice: Record "Sales Price"; var FoundSalesPrice: Boolean)
    var
        SalesHeader: Record "Sales Header";
        SalesPrice: Record "Sales Price";
        GLSetup: Record "General Ledger Setup";
        ExchangeRate: Record "Currency Exchange Rate";
        GenProdPostingGroup: Record "Gen. Product Posting Group";
        CurrencyCode: Code[10];
        RateValue: Decimal;
        FoundRate: Boolean;
        InvertRate: Boolean;
    begin
        if not FoundSalesPrice and (SalesLine."Unit Price" <> 0) then begin
            TempSalesPrice."Unit Price" := SalesLine."Unit Price";
            exit;
        end;
        if not GenProdPostingGroup.Get(SalesLine."Gen. Prod. Posting Group") then
            exit;
        if GenProdPostingGroup."BA Division Currency" = '' then
            exit;
        GLSetup.Get();
        GLSetup.TestField("LCY Code");
        if GenProdPostingGroup."BA Division Currency" <> GLSetup."LCY Code" then
            CurrencyCode := GenProdPostingGroup."BA Division Currency";
        SalesPrice.SetRange("Item No.", SalesLine."No.");
        SalesPrice.SetRange("Currency Code", CurrencyCode);
        SalesPrice.SetRange("Starting Date", 0D, WorkDate());
        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
        SalesPrice.SetRange("Sales Code", SalesLine."Customer Price Group");
        SalesPrice.SetAscending("Starting Date", true);
        FoundSalesPrice := SalesPrice.FindLast();
        if not FoundSalesPrice then begin
            SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::Customer);
            SalesPrice.SetRange("Sales Code", SalesLine."Bill-to Customer No.");
            FoundSalesPrice := SalesPrice.FindLast();
            if not FoundSalesPrice then begin
                SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"All Customers");
                SalesPrice.SetRange("Sales Code");
                FoundSalesPrice := SalesPrice.FindLast();
                if not FoundSalesPrice then
                    exit;
            end;
        end;
        TempSalesPrice := SalesPrice;
        if not (SalesLine."Document Type" in [SalesLine."Document Type"::Quote, SalesLine."Document Type"::Order]) then
            exit;
        if (SalesLine."Currency Code" <> CurrencyCode) then begin
            if SalesLine."Currency Code" <> '' then begin
                FoundRate := GetExchangeRate(ExchangeRate, SalesLine."Currency Code");
                InvertRate := true;
            end else
                FoundRate := GetExchangeRate(ExchangeRate, CurrencyCode);
            if FoundRate then begin
                GLSetup.TestField("Amount Rounding Precision");
                if InvertRate then
                    RateValue := 1 / ExchangeRate."Relational Exch. Rate Amount"
                else
                    RateValue := ExchangeRate."Relational Exch. Rate Amount";
                TempSalesPrice."Unit Price" := Round(TempSalesPrice."Unit Price" * RateValue, GLSetup."Amount Rounding Precision");
                RateValue := Round(RateValue, 0.00001);
            end else
                RateValue := 1;
        end else
            RateValue := 1;
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        SalesHeader."BA Quote Exch. Rate" := RateValue;
        SalesHeader.Modify(true);
    end;





    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Price Calc. Mgt.", 'OnAfterFindServLiveItemPrice', '', false, false)]
    local procedure SalesPriceMgtOnAfterFindServLiveItemPrice(var ServiceLine: Record "Service Line"; var TempSalesPrice: Record "Sales Price"; var FoundSalesPrice: Boolean)
    var
        ServiceHeader: Record "Service Header";
        SalesPrice: Record "Sales Price";
        ServiceSetup: Record "Service Mgt. Setup";
        GLSetup: Record "General Ledger Setup";
        ExchangeRate: Record "Currency Exchange Rate";
        CurrencyCode: Code[10];
        RateValue: Decimal;
    begin
        if not ServiceSetup.Get() or not ServiceSetup."BA Use Single Currency Pricing" then
            exit;
        ServiceSetup.TestField("BA Single Price Currency");
        if not FoundSalesPrice and (ServiceLine."Unit Price" <> 0) then begin
            TempSalesPrice."Unit Price" := ServiceLine."Unit Price";
            exit;
        end;
        GLSetup.Get();
        GLSetup.TestField("LCY Code");
        if ServiceSetup."BA Single Price Currency" <> GLSetup."LCY Code" then
            CurrencyCode := ServiceSetup."BA Single Price Currency";
        SalesPrice.SetRange("Item No.", ServiceLine."No.");
        SalesPrice.SetRange("Currency Code", CurrencyCode);
        SalesPrice.SetRange("Starting Date", 0D, WorkDate());
        SalesPrice.SetAscending("Starting Date", true);
        FoundSalesPrice := SalesPrice.FindLast();
        if not FoundSalesPrice then
            exit;
        TempSalesPrice := SalesPrice;
        if not (ServiceLine."Document Type" in [ServiceLine."Document Type"::Quote, ServiceLine."Document Type"::Order]) then
            exit;
        if (ServiceLine."Currency Code" <> CurrencyCode) and GetExchangeRate(ExchangeRate, CurrencyCode) then begin
            GLSetup.TestField("Amount Rounding Precision");
            TempSalesPrice."Unit Price" := Round(TempSalesPrice."Unit Price" * ExchangeRate."Relational Exch. Rate Amount",
                GLSetup."Amount Rounding Precision");
            RateValue := Round(ExchangeRate."Relational Exch. Rate Amount", GLSetup."Amount Rounding Precision");
        end else
            RateValue := 1;
        ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");
        ServiceHeader."BA Quote Exch. Rate" := RateValue;
        ServiceHeader.Modify(true);
    end;


    procedure GetExchangeRate(var ExchangeRate: Record "Currency Exchange Rate"; CurrencyCode: Code[10]): Boolean
    begin
        ExchangeRate.SetRange("Currency Code", CurrencyCode);
        ExchangeRate.SetRange("Starting Date", 0D, WorkDate());
        ExchangeRate.SetFilter("Relational Exch. Rate Amount", '<>%1', 0);
        exit(ExchangeRate.FindLast());
    end;

    procedure UpdateSalesPrice(var SalesHeader: Record "Sales Header")
    var
        SalesRecSetup: Record "Sales & Receivables Setup";
        SalesLine: Record "Sales Line";
        ExchangeRate: Record "Currency Exchange Rate";
        SalesPriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
    begin
        SalesRecSetup.Get();
        SalesRecSetup.TestField("BA Use Single Currency Pricing", true);
        SalesRecSetup.TestField("BA Single Price Currency");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if not SalesLine.FindSet(true) then
            exit;
        repeat
            SalesPriceCalcMgt.FindSalesLinePrice(SalesHeader, SalesLine, 0);
            SalesLine.UpdateUnitPrice(0);
            SalesLine.Modify(true);
        until SalesLine.Next() = 0;
        SalesHeader.Get(SalesHeader.RecordId());
        Message(ExchageRateUpdateMsg, SalesHeader."BA Quote Exch. Rate");
    end;


    procedure UpdateServicePrice(var ServiceHeader: Record "Service Header")
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
        ServiceLine: Record "Service Line";
        ExchangeRate: Record "Currency Exchange Rate";
        SalesPriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
    begin
        ServiceMgtSetup.Get();
        ServiceMgtSetup.TestField("BA Use Single Currency Pricing", true);
        ServiceMgtSetup.TestField("BA Single Price Currency");
        ServiceLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        ServiceLine.SetRange(Type, ServiceLine.Type::Item);
        if not ServiceLine.FindSet(true) then
            exit;
        repeat
            SalesPriceCalcMgt.FindServLinePrice(ServiceHeader, ServiceLine, 0);
            ServiceLine.UpdateUnitPrice(0);
            ServiceLine.Modify(true);
        until ServiceLine.Next() = 0;
        ServiceHeader.Get(ServiceHeader.RecordId());
        Message(ExchageRateUpdateMsg, ServiceHeader."BA Quote Exch. Rate");
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesShptHeaderInsert', '', false, false)]
    local procedure SalesPostOnBeforeSalesShptHeaderInsert(var SalesShptHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header")
    begin
        SalesHeader.CalcFields("BA Ship-to County Fullname", "BA Bill-to County Fullname", "BA Sell-to County Fullname");
        SalesShptHeader."BA Bill-to County Fullname" := SalesHeader."BA Bill-to County Fullname";
        SalesShptHeader."BA Ship-to County Fullname" := SalesHeader."BA Ship-to County Fullname";
        SalesShptHeader."BA Sell-to County Fullname" := SalesHeader."BA Sell-to County Fullname";
        SalesShptHeader."BA SEI Int'l Ref. No." := SalesHeader."BA SEI Int'l Ref. No.";
        SalesShptHeader."BA SEI Barbados Order" := SalesHeader."BA SEI Barbados Order";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvHeaderInsert', '', false, false)]
    local procedure SalesPostOnBeforeSalesInveaderInsert(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header")
    var
        FreightTerm: Record "ENC Freight Term";
        ShippingAgent: Record "Shipping Agent";
    begin
        SalesHeader.CalcFields("BA Ship-to County Fullname", "BA Bill-to County Fullname", "BA Sell-to County Fullname");
        SalesInvHeader."BA Bill-to County Fullname" := SalesHeader."BA Bill-to County Fullname";
        SalesInvHeader."BA Ship-to County Fullname" := SalesHeader."BA Ship-to County Fullname";
        SalesInvHeader."BA Sell-to County Fullname" := SalesHeader."BA Sell-to County Fullname";
        SalesInvHeader."BA Order No. DrillDown" := SalesHeader."No.";
        SalesInvHeader."BA Ext. Doc. No. DrillDown" := SalesHeader."External Document No.";
        SalesInvHeader."BA Posting Date DrillDown" := SalesHeader."Posting Date";
        if (SalesInvHeader."Shipping Agent Code" <> '') and ShippingAgent.Get(SalesInvHeader."Shipping Agent Code") then
            SalesInvHeader."BA Freight Carrier Name" := ShippingAgent.Name;
        if (SalesInvHeader."ENC Freight Term" <> '') and FreightTerm.Get(SalesInvHeader."ENC Freight Term") then
            SalesInvHeader."BA Freight Term Name" := FreightTerm.Description;
        SalesInvHeader."BA SEI Int'l Ref. No." := SalesHeader."BA SEI Int'l Ref. No.";
        SalesInvHeader."BA SEI Barbados Order" := SalesHeader."BA SEI Barbados Order";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesCrMemoHeaderInsert', '', false, false)]
    local procedure SalesPostOnBeforeSalesCrMemoHeaderInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesHeader: Record "Sales Header")
    begin
        SalesHeader.CalcFields("BA Ship-to County Fullname", "BA Bill-to County Fullname", "BA Sell-to County Fullname");
        SalesCrMemoHeader."BA Bill-to County Fullname" := SalesHeader."BA Bill-to County Fullname";
        SalesCrMemoHeader."BA Ship-to County Fullname" := SalesHeader."BA Ship-to County Fullname";
        SalesCrMemoHeader."BA Sell-to County Fullname" := SalesHeader."BA Sell-to County Fullname";
        SalesCrMemoHeader."BA SEI Int'l Ref. No." := SalesHeader."BA SEI Int'l Ref. No.";
        SalesCrMemoHeader."BA SEI Barbados Order" := SalesHeader."BA SEI Barbados Order";
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterPostItemJnlLine', '', false, false)]
    local procedure ItemJnlLinePostOnAfterPostItemJnlLine(ItemLedgerEntry: Record "Item Ledger Entry"; var ItemJournalLine: Record "Item Journal Line"; var ValueEntryNo: Integer)
    begin
        ItemLedgerEntry."BA Adjust. Reason Code" := ItemJournalLine."BA Adjust. Reason Code";
        ItemLedgerEntry."BA Approved By" := ItemJournalLine."BA Approved By";
        if ItemJournalLine."BA Updated" then
            ItemLedgerEntry."BA Year-end Adjst." := true;
        ItemLedgerEntry.Modify(false);
    end;


    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'BA Credit Limit', false, false)]
    local procedure CustomerOnAfterValidateCreditLimitNonLCY(var Rec: Record Customer)
    var
        Currency: Record Currency;
        ExchRate: Record "Currency Exchange Rate";
    begin
        if not Currency.Get(Rec."Customer Posting Group") then
            exit;
        ExchRate.SetRange("Currency Code", Currency.Code);
        ExchRate.SetRange("Starting Date", 0D, WorkDate());
        if ExchRate.FindLast() and (ExchRate."Relational Exch. Rate Amount" <> 0) then
            Rec.Validate("Credit Limit (LCY)", Rec."BA Credit Limit" * ExchRate."Relational Exch. Rate Amount");
    end;

    [EventSubscriber(ObjectType::Report, Report::"Calculate Inventory", 'OnBeforeInsertItemJnlLine', '', false, false)]
    local procedure CalcInventoryOnBeforeInsertItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; YearEndInventoryAdjust: Boolean)
    begin
        if YearEndInventoryAdjust then
            ItemJournalLine."BA Updated" := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Calculate Inventory", 'OnAfterPostItemDataItem', '', false, false)]
    local procedure CalcInventoryOnAfterPostItemDataItem(var ItemJnlLine: Record "Item Journal Line")
    var
        ItemJnlLine2: Record "Item Journal Line";
    begin
        ItemJnlLine2.CopyFilters(ItemJnlLine);
        ItemJnlLine.Reset();
        ItemJnlLine.SetRange("Journal Template Name", ItemJnlLine."Journal Template Name");
        ItemJnlLine.SetRange("Journal Batch Name", ItemJnlLine."Journal Batch Name");
        if DoesItemJnlHaveMultipleItemLines(ItemJnlLine) then
            Message(ImportWarningsMsg);
        ItemJnlLine.Reset();
        ItemJnlLine.CopyFilters(ItemJnlLine2);
    end;

    procedure DoesItemJnlHaveMultipleItemLines(var ItemJnlLine: Record "Item Journal Line"): Boolean
    var
        TempItemJnlLine: Record "Item Journal Line" temporary;
        ItemNos: List of [Code[20]];
        ItemNo: Code[20];
        HasWarnings: Boolean;
    begin
        if ItemJnlLine.IsEmpty() then
            exit(false);
        ItemJnlLine.SetFilter("BA Warning Message", '<>%1', '');
        ItemJnlLine.ModifyAll("BA Warning Message", '');
        ItemJnlLine.SetRange("BA Warning Message");
        if not ItemJnlLine.FindSet() then
            exit(false);
        repeat
            if ItemNos.Contains(ItemJnlLine."Item No.") then begin
                TempItemJnlLine := ItemJnlLine;
                TempItemJnlLine.Insert(false);
            end else
                ItemNos.Add(ItemJnlLine."Item No.");
        until ItemJnlLine.Next() = 0;
        if not TempItemJnlLine.FindSet() then
            exit(false);
        repeat
            ItemJnlLine.SetRange("Item No.", TempItemJnlLine."Item No.");
            if ItemJnlLine.Count() > 1 then begin
                HasWarnings := true;
                ItemJnlLine.ModifyAll("BA Warning Message", StrSubstNo(MultiItemMsg, TempItemJnlLine."Item No."));
            end;
        until TempItemJnlLine.Next() = 0;
        exit(HasWarnings);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Phys. Inventory Journal", 'OnAfterActionEvent', 'CalculateInventory', false, false)]
    local procedure PhysInvJournalOnAfterCalculateInventory(var Rec: Record "Item Journal Line")
    var
        ItemJnlLine: Record "Item Journal Line";
    begin
        ItemJnlLine.CopyFilters(Rec);
        Rec.SetRange("Journal Template Name", Rec."Journal Template Name");
        Rec.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        Rec.SetRange("BA Created At", 0DT);
        Rec.ModifyAll("BA Created At", CurrentDateTime());
        Rec.CopyFilters(ItemJnlLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure ItemJounalLineOnAfterInsert(var Rec: Record "Item Journal Line")
    begin
        Rec."BA Created At" := CurrentDateTime();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Config. Package Management", 'OnApplyItemDimension', '', false, false)]
    local procedure ConfigPackageMgtOnApplyItemDim(ItemNo: Code[20]; DimCode: Code[20]; DimValue: Code[20])
    var
        Item: Record Item;
        ItemCard: Page "Item Card";
    begin
        if Item.Get(ItemNo) and ItemCard.CheckToUpdateDimValues(Item, DimValue) then begin
            Item.Modify(true);
            Commit();
        end;
    end;


    procedure ReuseItemNo(ItemNo: Code[20])
    var
        InventorySetup: Record "Inventory Setup";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesLine2: Record "No. Series Line";
        LineNo: Integer;
    begin
        InventorySetup.Get();
        InventorySetup.TestField("Item Nos.");
        NoSeriesLine2.SetRange("Series Code", InventorySetup."Item Nos.");
        if NoSeriesLine2.FindLast() then
            LineNo := NoSeriesLine2."Line No.";
        NoSeriesLine.Init();
        NoSeriesLine.Validate("Series Code", InventorySetup."Item Nos.");
        NoSeriesLine."Line No." := LineNo + 10000;
        NoSeriesLine."Last No. Used" := ItemNo;
        NoSeriesLine."BA Replacement" := true;
        NoSeriesLine."BA Replacement DateTime" := CurrentDateTime;
        NoSeriesLine.Open := false;
        NoSeriesLine.Insert(false);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::NoSeriesManagement, 'OnBeforeDoGetNextNo', '', false, false)]
    local procedure NoSeriesMgtOnBeforeDoGetNextNo(var ModifySeries: Boolean; var NoSeriesCode: Code[20])
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        if (InventorySetup."Item Nos." = '') or (InventorySetup."Item Nos." <> NoSeriesCode) then
            exit;
        ModifySeries := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::NoSeriesManagement, 'OnAfterGetNextNo3', '', false, false)]
    local procedure NoSeriesMgtOnAfterGetNextNo3(var NoSeriesLine: Record "No. Series Line")
    var
        Item: Record Item;
        InventorySetup: Record "Inventory Setup";
        NoSeriesLine2: Record "No. Series Line";
        TempNoSeriesLine: Record "No. Series Line" temporary;
        Reuse: Boolean;
    begin
        InventorySetup.Get();
        if (InventorySetup."Item Nos." = '') or (InventorySetup."Item Nos." <> NoSeriesLine."Series Code") then
            exit;
        SetSeriesLineFilters(NoSeriesLine2, InventorySetup."Item Nos.");
        if not NoSeriesLine2.FindSet() then
            exit;
        repeat
            if Item.Get(NoSeriesLine2."Last No. Used") then begin
                TempNoSeriesLine := NoSeriesLine2;
                TempNoSeriesLine.Insert(false);
            end else
                Reuse := true;
        until Reuse or (NoSeriesLine2.Next() = 0);
        if TempNoSeriesLine.FindSet() then
            repeat
                NoSeriesLine2.Get(TempNoSeriesLine.RecordId());
                NoSeriesLine2.Delete(true);
            until TempNoSeriesLine.Next() = 0;
        if Reuse then
            NoSeriesLine."Last No. Used" := NoSeriesLine2."Last No. Used";
    end;

    local procedure SetSeriesLineFilters(var NoSeriesLine2: Record "No. Series Line"; SeriesCode: Code[20])
    begin
        NoSeriesLine2.SetRange("Series Code", SeriesCode);
        NoSeriesLine2.SetRange("BA Replacement", true);
        NoSeriesLine2.SetCurrentKey("Series Code", "Line No.", "Last No. Used");
        NoSeriesLine2.SetAscending(NoSeriesLine2."Last No. Used", true);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterInsertEvent', '', false, false)]
    local procedure ItemOnAfterInsert(var Rec: Record Item)
    var
        InventorySetup: Record "Inventory Setup";
        NoSeriesLine: Record "No. Series Line";
    begin
        InventorySetup.Get();
        if (InventorySetup."Item Nos." = '') then
            exit;
        NoSeriesLine.SetRange("Series Code", InventorySetup."Item Nos.");
        NoSeriesLine.SetRange("Last No. Used", Rec."No.");
        NoSeriesLine.SetRange("BA Replacement", true);
        if NoSeriesLine.FindFirst() then
            NoSeriesLine.Delete(true);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Currency Exchange Rate", 'OnAfterValidateEvent', 'Relational Exch. Rate Amount', false, false)]
    local procedure CurrencyExchangeRateOnAfterValidateRelationExchRateAmount(var Rec: Record "Currency Exchange Rate"; var xRec: Record "Currency Exchange Rate")
    var
        Customer: Record Customer;
        Window: Dialog;
        RecCount: Integer;
        i: Integer;
    begin
        if (Rec."Currency Code" <> 'USD') or (Rec."Relational Exch. Rate Amount" = xRec."Relational Exch. Rate Amount") then
            exit;
        UpdateSystemIndicator(Rec);
        Customer.SetFilter("BA Credit Limit", '<>%1', 0);
        if not Customer.FindSet(true) then
            exit;
        RecCount := Customer.Count;
        if not Confirm(UpdateCreditLimitMsg) then
            exit;
        Window.Open(UpdateCreditLimitDialog);
        repeat
            i += 1;
            Window.Update(1, StrSubstNo('%1 of %2', i, RecCount));
            Customer.Validate("Credit Limit (LCY)", Customer."BA Credit Limit" * Rec."Relational Exch. Rate Amount");
            Customer.Modify(true);
        until Customer.Next() = 0;
        Window.Close();
    end;


    local procedure UpdateSystemIndicator(var CurrExchRate: Record "Currency Exchange Rate")
    var
        CompInfo: Record "Company Information";
        DateRec: Record Date;
    begin
        CompInfo.Get('');
        DateRec.SetRange("Period Type", DateRec."Period Type"::Month);
        DateRec.SetRange("Period Start", DMY2Date(1, Date2DMY(CurrExchRate."Starting Date", 2), 2000));
        DateRec.FindFirst();
        CompInfo."Custom System Indicator Text" := CopyStr(StrSubstNo(ExchangeRateText, CompanyName(), CurrExchRate."Relational Exch. Rate Amount", DateRec."Period Name"), 1, MaxStrLen(CompInfo."Custom System Indicator Text"));
        CompInfo.Modify(false);
    end;


    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'Credit Limit (LCY)', false, false)]
    local procedure CustomerNoAfterValidateCreditLimit(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec."Credit Limit (LCY)" = xRec."Credit Limit (LCY)" then
            exit;
        Rec."BA Credit Limit Last Updated" := CurrentDateTime();
        Rec."BA Credit Limit Updated By" := UserId();
        Rec.Modify(true);
    end;




    procedure LocationListLookup(): Code[20]
    begin
        exit(LocationListLookup(false));
    end;


    procedure LocationListLookup(WarehouseLookup: Boolean): Code[20]
    var
        Location: Record Location;
        LocationList: Page "Location List";
        WarehouseEmployee: Record "Warehouse Employee";
        FilterStr: Text;
    begin
        Location.FilterGroup(2);
        Location.SetRange("BA Inactive", false);
        if WarehouseLookup and (UserId() <> '') then begin
            WarehouseEmployee.SetRange("User ID", UserId());
            if WarehouseEmployee.FindSet() then
                repeat
                    if FilterStr = '' then
                        FilterStr := WarehouseEmployee."Location Code"
                    else
                        FilterStr += '|' + WarehouseEmployee."Location Code";
                until WarehouseEmployee.Next() = 0
            else
                Error(WarehouseEmployeeSetupError, UserId(), WarehouseEmployee.TableCaption());
            Location.SetFilter(Code, FilterStr);
        end;
        Location.FilterGroup(0);
        LocationList.SetTableView(Location);
        LocationList.LookupMode(true);
        if LocationList.RunModal() <> Action::LookupOK then
            exit('');
        LocationList.GetRecord(Location);
        exit(Location.Code);
    end;


    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeFindLocations', '', false, false)]
    local procedure LocationOnBeforeFindLocations(var Location: Record Location)
    begin
        Location.SetRange("BA Inactive", false);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Create Warehouse Location", 'OnLocationLookup', '', false, false)]
    local procedure CreateWarehouseLocationOnLocationLookup(var Location: Record Location; var LocCode: Code[10])
    begin
        LocCode := LocationListLookup();
    end;

    [EventSubscriber(ObjectType::Report, Report::"Refresh Production Order", 'OnAfterRefreshProdOrder', '', false, false)]
    local procedure RefreshProdOrderOnAfterRefreshProdOrder(var ProductionOrder: Record "Production Order"; ErrorOccured: Boolean)
    var
        ProdBOMHeader: Record "Production BOM Header";
    begin
        if ErrorOccured or (ProductionOrder."Source Type" <> ProductionOrder."Source Type"::Item) or not ProdBOMHeader.Get(ProductionOrder."Source No.") then
            exit;
        ProdBOMHeader.CalcFields("BA Active Version");
        ProdBOMHeader."ENC Active Version No." := ProdBOMHeader."BA Active Version";
        ProdBOMHeader.Modify(false);
        ProductionOrder."BA Source Version" := ProdBOMHeader."BA Active Version";
        ProductionOrder.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ENC SEI Functions", 'CopyCustomTemplateFieldsOnAfterSetFilters', '', false, false)]
    local procedure CopyCustomTemplateFieldsOnAfterSetFilters(var FieldRec: Record Field)
    begin
        AddFieldFilter(FieldRec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ENC SEI Functions", 'AssignCustomTemplateFieldsOnAfterSetFilters1', '', false, false)]
    local procedure AssignCustomTemplateFieldsOnAfterSetFilters1(var FieldRec: Record Field)
    begin
        AddFieldFilter(FieldRec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ENC SEI Functions", 'AssignCustomTemplateFieldsOnAfterSetFilters2', '', false, false)]
    local procedure AssignCustomTemplateFieldsOnAfterSetFilters2(var FieldRec: Record Field)
    begin
        AddFieldFilter(FieldRec);
    end;

    local procedure AddFieldFilter(var FieldRec: Record Field)
    var
        FilterText: Text;
        MinValue: Integer;
        MaxValue: Integer;
    begin
        MinValue := 80000;
        MaxValue := 80199;
        FilterText := FieldRec.GetFilter("No.");
        if FilterText <> '' then
            FieldRec.SetFilter("No.", StrSubstNo('%1|%2', FilterText, StrSubstNo('%1..%2', MinValue, MaxValue)))
        else
            FieldRec.SetRange("No.", MinValue, MaxValue);
    end;

    //test


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeRunWithCheck', '', false, false)]
    local procedure ItemJnlPostLineOnBeforeRunWithCheck(var ItemJournalLine: Record "Item Journal Line")
    begin
        if not IsInventoryApprovalEnabled() or (ItemJournalLine."Journal Template Name" <> 'ITEM') then
            exit;
        ItemJournalLine.TestField("BA Adjust. Reason Code");
        if ItemJournalLine."BA Status" = ItemJournalLine."BA Status"::Rejected then
            Error(RejectedLineError, ItemJournalLine."Line No.");
        if ItemJournalLine."BA Status" = ItemJournalLine."BA Status"::Pending then
            Error(PendingLineError, ItemJournalLine."Line No.");
        if (ItemJournalLine."BA Status" <> ItemJournalLine."BA Status"::Released) and not CheckInventoryLimit(ItemJournalLine) then
            Error(JnlLimitError);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnApproveApprovalRequest', '', false, false)]
    local procedure ApprovalsMgtOnApproveApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    begin
        ApprovalUpdateActions(ApprovalEntry, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnRejectApprovalRequest', '', false, false)]
    local procedure ApprovalsMgtOnRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    begin
        ApprovalUpdateActions(ApprovalEntry, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnAfterSetApprovalCommentLine', '', false, false)]
    local procedure ApprovalsMgtOnAfterSetApprovalCommentLine(var ApprovalCommentLine: Record "Approval Comment Line"; WorkflowStepInstanceID: Guid)
    begin
        ApprovalCommentLine.SetRange("Workflow Step Instance ID", WorkflowStepInstanceID)
    end;

    local procedure IsInventoryApprovalEnabled(): Boolean;
    var
        InventorySetup: Record "Inventory Setup";
    begin
        exit(InventorySetup.Get() and InventorySetup."BA Approval Required");
    end;

    local procedure ApprovalUpdateActions(var ApprovalEntry: Record "Approval Entry"; Rejected: Boolean)
    var
        ItemJnlBatch: Record "Item Journal Batch";
    begin
        if not IsInventoryApprovalEnabled() or (ApprovalEntry."Table ID" <> Database::"Item Journal Batch") or not ItemJnlBatch.Get(ApprovalEntry."Record ID to Approve") then
            exit;
        UpdateItemLineApprovalStatus(ItemJnlBatch, Rejected);
        UpdateOtherApprovalEntries(ApprovalEntry, Rejected);
        SendApprovalNotification(ApprovalEntry);
    end;

    local procedure UpdateOtherApprovalEntries(var ApprovalEntry: Record "Approval Entry"; Rejected: Boolean)
    var
        OtherEntry: Record "Approval Entry";
        NewStatus: Option;
    begin
        if Rejected then
            NewStatus := ApprovalEntry.Status::Rejected
        else
            NewStatus := ApprovalEntry.Status::Approved;
        OtherEntry.SetCurrentKey("Table ID", "Record ID to Approve", "Status", "Workflow Step Instance ID", "Sequence No.");
        OtherEntry.SetRange("Table ID", Database::"Item Journal Batch");
        OtherEntry.SetRange("Record ID to Approve", ApprovalEntry."Record ID to Approve");
        OtherEntry.SetRange(Status, OtherEntry.Status::Open);
        OtherEntry.SetRange("Workflow Step Instance ID", ApprovalEntry."Workflow Step Instance ID");
        OtherEntry.ModifyAll(Status, NewStatus, true);
    end;

    local procedure UpdateItemLineApprovalStatus(var ItemJnlBatch: Record "Item Journal Batch"; Rejected: Boolean)
    var
        ItemJnlLine: Record "Item Journal Line";
        RecIDList: List of [RecordId];
        RecID: RecordId;
    begin
        ItemJnlLine.SetRange("Journal Template Name", ItemJnlBatch."Journal Template Name");
        ItemJnlLine.SetRange("Journal Batch Name", ItemJnlBatch.Name);
        ItemJnlLine.SetRange("BA Locked For Approval", true);
        ItemJnlLine.SetRange("BA Status", ItemJnlLine."BA Status"::Pending);
        if not ItemJnlLine.FindSet() then
            exit;
        repeat
            RecIDList.Add(ItemJnlLine.RecordId());
        until ItemJnlLine.Next() = 0;
        foreach RecID in RecIDList do begin
            ItemJnlLine.Get(RecID);
            ItemJnlLine.Validate("BA Locked For Approval", false);
            if Rejected then
                ItemJnlLine.Validate("BA Status", ItemJnlLine."BA Status"::Rejected)
            else begin
                ItemJnlLine.Validate("BA Status", ItemJnlLine."BA Status"::Released);
                ItemJnlLine.Validate("BA Approved By", UserId());
            end;
            ItemJnlLine.Modify(false);
        end;
    end;

    procedure CheckInventoryLimit(var ItemJournalLine: Record "Item Journal Line"): Boolean
    var
        InventorySetup: Record "Inventory Setup";
        ItemJnlLine: Record "Item Journal Line";
    begin
        InventorySetup.Get();
        if not InventorySetup."BA Approval Required" or (InventorySetup."BA Approval Limit" = 0) then
            exit(true);
        ItemJnlLine.SetRange("Journal Template Name", ItemJournalLine."Journal Template Name");
        ItemJnlLine.SetRange("Journal Batch Name", ItemJournalLine."Journal Batch Name");
        ItemJnlLine.SetFilter(Amount, '>%1', InventorySetup."BA Approval Limit");
        exit(ItemJnlLine.IsEmpty());
    end;

    procedure SendItemJnlApproval(var ItemJnlLine: Record "Item Journal Line"; Cancelled: Boolean)
    var
        ItemJnlBatch: Record "Item Journal Batch";
        InventorySetup: Record "Inventory Setup";
        FilterRec: Record "Item Journal Line";
        ApprovalEntry: Record "Approval Entry";
        CheckItemJnlLine: Codeunit "Item Jnl.-Check Line";
        ApprovalAmt: Decimal;
        TempGUID: Guid;
        EntryList: List of [Integer];
        EntryNo: Integer;
    begin
        InventorySetup.Get();
        if not InventorySetup."BA Approval Required" then
            Error(InventoryAppDisabledError);
        if (InventorySetup."BA Approval Admin1" = '') and (InventorySetup."BA Approval Admin2" = '') then
            Error(NoApprovalAdminError);
        InventorySetup.TestField("BA Approval Code");
        ItemJnlBatch.Get(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");
        FilterRec.CopyFilters(ItemJnlLine);
        ItemJnlLine.Reset();
        ItemJnlLine.SetRange("Journal Template Name", ItemJnlLine."Journal Template Name");
        ItemJnlLine.SetRange("Journal Batch Name", ItemJnlLine."Journal Batch Name");
        ItemJnlLine.SetRange("BA Locked For Approval", true);
        if Cancelled then begin
            if ItemJnlLine.IsEmpty() then
                Error(NoApprovalToCancelError, ItemJnlBatch.RecordId());
            ApprovalEntry.SetCurrentKey("Table ID", "Record ID to Approve", "Status", "Workflow Step Instance ID", "Sequence No.");
            ApprovalEntry.SetRange("Table ID", Database::"Item Journal Batch");
            ApprovalEntry.SetRange("Record ID to Approve", ItemJnlBatch.RecordId());
            ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Approved);
            ApprovalEntry.SetRange("Workflow Step Instance ID", ItemJnlLine."BA Approval GUID");
            if not ApprovalEntry.IsEmpty() then
                Error(AlreadyApprovedError);
        end else
            if not Cancelled and not ItemJnlLine.IsEmpty() then
                Error(AlreadySubmittedError, ItemJnlBatch.RecordId());

        ItemJnlLine.SetRange("BA Locked For Approval");
        ItemJnlLine.FindSet(true);
        if Cancelled then begin
            repeat
                ItemJnlLine.Validate("BA Locked For Approval", false);
                ItemJnlLine.Validate("BA Status", ItemJnlLine."BA Status"::" ");
                ItemJnlLine.Modify(false);
            until ItemJnlLine.Next() = 0;
            ItemJnlLine.Reset();
            ItemJnlLine.CopyFilters(FilterRec);
            ApprovalEntry.SetCurrentKey("Table ID", "Record ID to Approve", "Status", "Workflow Step Instance ID", "Sequence No.");
            ApprovalEntry.SetRange("Table ID", Database::"Item Journal Batch");
            ApprovalEntry.SetRange("Record ID to Approve", ItemJnlBatch.RecordId());
            ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
            ApprovalEntry.SetRange("Workflow Step Instance ID", ItemJnlLine."BA Approval GUID");
            ApprovalEntry.SetRange("Sender ID", UserId());
            if ApprovalEntry.FindSet(true) then
                repeat
                    EntryList.Add(ApprovalEntry."Entry No.");
                until ApprovalEntry.Next() = 0;
            foreach EntryNo in EntryList do begin
                ApprovalEntry.Get(EntryNo);
                ApprovalEntry.Validate(Status, ApprovalEntry.Status::Canceled);
                ApprovalEntry.Modify(true);
            end;
            Message(CancelRequestMsg);
            exit;
        end;

        ItemJnlLine.SetRange("BA Adjust. Reason Code", '');
        if not ItemJnlLine.IsEmpty() then
            Error(NoAdjustReasonError, ItemJnlLine.FieldCaption("BA Adjust. Reason Code"));
        ItemJnlLine.SetRange("BA Adjust. Reason Code");
        repeat
            CheckItemJnlLine.RunCheck(ItemJnlLine);
            ApprovalAmt += ItemJnlLine.Amount;
        until ItemJnlLine.Next() = 0;

        ItemJnlLine.FindSet(true);
        if CheckInventoryLimit(ItemJnlLine) then begin
            repeat
                ItemJnlLine.Validate("BA Locked For Approval", false);
                ItemJnlLine.Validate("BA Status", ItemJnlLine."BA Status"::Released);
                ItemJnlLine.Modify(false);
            until ItemJnlLine.Next() = 0;
            Message(NoApprovalNeededMsg);
        end else begin
            TempGUID := CreateGuid();
            repeat
                ItemJnlLine.Validate("BA Locked For Approval", true);
                ItemJnlLine.Validate("BA Status", ItemJnlLine."BA Status"::Pending);
                ItemJnlLine."BA Approval GUID" := TempGUID;
                ItemJnlLine.Modify(false);
            until ItemJnlLine.Next() = 0;

            ApprovalEntry.SetCurrentKey("Table ID", "Record ID to Approve", "Status", "Workflow Step Instance ID", "Sequence No.");
            ApprovalEntry.SetRange("Table ID", Database::"Item Journal Batch");
            ApprovalEntry.SetRange("Record ID to Approve", ItemJnlBatch.RecordId());
            ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
            ApprovalEntry.SetRange("Workflow Step Instance ID", TempGUID);
            if not ApprovalEntry.IsEmpty() then
                Error(AlreadyAwaitingApprovalError, ItemJnlBatch.RecordId());
            ApprovalEntry.Reset();
            if ApprovalEntry.FindLast() then
                EntryNo := ApprovalEntry."Entry No.";
            if InventorySetup."BA Approval Admin1" <> '' then
                AddItemJnlBatchApprovalEntry(EntryNo, ItemJnlBatch, InventorySetup."BA Approval Admin1", ApprovalAmt, InventorySetup."BA Approval Code", TempGUID);
            if InventorySetup."BA Approval Admin2" <> '' then
                AddItemJnlBatchApprovalEntry(EntryNo, ItemJnlBatch, InventorySetup."BA Approval Admin2", ApprovalAmt, InventorySetup."BA Approval Code", TempGUID);
            Message(RequestSentMsg);
        end;
        ItemJnlLine.Reset();
        ItemJnlLine.CopyFilters(FilterRec);
    end;

    procedure ReopenApprovalRequest(var ItemJnlLine: Record "Item Journal Line")
    var
        ApprovalEntry: Record "Approval Entry";
        ItemJnlBatch: Record "Item Journal Batch";
    begin
        ItemJnlBatch.Get(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");
        ApprovalEntry.SetCurrentKey("Table ID", "Record ID to Approve", "Status", "Workflow Step Instance ID", "Sequence No.");
        ApprovalEntry.SetRange("Table ID", Database::"Item Journal Batch");
        ApprovalEntry.SetRange("Record ID to Approve", ItemJnlBatch.RecordId());
        ApprovalEntry.SetFilter(Status, '%1|%2', ApprovalEntry.Status::Approved, ApprovalEntry.Status::Canceled);
        ApprovalEntry.SetRange("Workflow Step Instance ID", ItemJnlLine."BA Approval GUID");
        ApprovalEntry.SetRange("Sender ID", UserId());
        ApprovalEntry.ModifyAll(Status, ApprovalEntry.Status::Canceled);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        ApprovalEntry.SetRange("Workflow Step Instance ID");
        ApprovalEntry.DeleteAll(true);
    end;

    local procedure AddItemJnlBatchApprovalEntry(var EntryNo: Integer; ItemJnlBatch: Record "Item Journal Batch"; Approver: Code[50]; ApprovalAmt: Decimal; ApprovalCode: Code[20]; WorkflowGUID: Guid)
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        EntryNo += 1;
        ApprovalEntry.Init();
        ApprovalEntry."Entry No." := EntryNo;
        ApprovalEntry.Validate("Table ID", Database::"Item Journal Batch");
        ApprovalEntry.Validate("Sender ID", UserId());
        ApprovalEntry.Validate("Record ID to Approve", ItemJnlBatch.RecordId());
        ApprovalEntry.Validate(Status, ApprovalEntry.Status::Open);
        ApprovalEntry.Validate("Date-Time Sent for Approval", CurrentDateTime());
        ApprovalEntry.Validate("Due Date", WorkDate());
        ApprovalEntry.Validate(Amount, ApprovalAmt);
        ApprovalEntry.Validate("Amount (LCY)", ApprovalAmt);
        ApprovalEntry.Validate("Approval Type", ApprovalEntry."Approval Type"::Approver);
        ApprovalEntry.Validate("Limit Type", ApprovalEntry."Limit Type"::"No Limits");
        ApprovalEntry.Validate("Approval Code", ApprovalCode);
        ApprovalEntry.Validate("Document Type", ApprovalEntry."Document Type"::" ");
        ApprovalEntry.Validate("Approver ID", Approver);
        ApprovalEntry.Insert(true);
        ApprovalEntry.Validate("BA Journal Batch Name", ItemJnlBatch.Name);
        ApprovalEntry.Validate("Workflow Step Instance ID", WorkflowGUID);
        ApprovalEntry.Modify(true);
        SendApprovalNotification(ApprovalEntry);
    end;

    procedure ClearApprovalEntries()
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        if UserId <> 'ENCORE' then
            exit;
        ApprovalEntry.SetRange("Table ID", Database::"Item Journal Batch");
        ApprovalEntry.DeleteAll(true);
    end;


    local procedure SendApprovalNotification(var ApprovalEntry: Record "Approval Entry")
    var
        NotificationEntry: Record "Notification Entry";
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlLine: Record "Item Journal Line";
        PageMgt: Codeunit "Page Management";
        RecRef: RecordRef;
    begin
        if not ItemJnlBatch.Get(ApprovalEntry."Record ID to Approve") then
            exit;
        ItemJnlLine.SetRange("Journal Template Name", ItemJnlBatch."Journal Template Name");
        ItemJnlLine.SetRange("Journal Batch Name", ItemJnlBatch.Name);
        if not ItemJnlLine.FindFirst() then
            exit;
        RecRef.GetTable(ItemJnlLine);
        NotificationEntry.CreateNewEntry(NotificationEntry.Type::Approval, ApprovalEntry."Approver ID",
            ApprovalEntry, Page::"Item Journal", PageMgt.GetRTCUrl(RecRef, Page::"Item Journal"), ApprovalEntry."Sender ID");
    end;


    [EventSubscriber(ObjectType::Report, Report::"Notification Email", 'OnAfterSetReportFieldPlaceholders', '', false, false)]
    local procedure NotificationEmailOnAfterSetReportFieldPlaceholders(var NotificationEntry: Record "Notification Entry"; var DocumentURL: Text)
    begin
        if (NotificationEntry.Type = NotificationEntry.Type::Approval) and (NotificationEntry."Link Target Page" = Page::"Item Journal")
                and (NotificationEntry."Custom Link" <> '') then
            DocumentURL := NotificationEntry."Custom Link";
    end;


    [EventSubscriber(ObjectType::Table, Database::"Production BOM Version", 'OnAfterValidateEvent', 'Starting Date', false, false)]
    local procedure ProdBOMVersionOnAfterValidateStartingDate(var Rec: Record "Production BOM Version"; var xRec: Record "Production BOM Version")
    begin
        if xRec."Starting Date" = Rec."Starting Date" then
            exit;
        UpdateBOMActive(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Production BOM Version", 'OnAfterValidateEvent', 'Status', false, false)]
    local procedure ProdBOMVersionOnAfterValidateStatus(var Rec: Record "Production BOM Version"; var xRec: Record "Production BOM Version")
    begin
        UpdateBOMActive(Rec);
    end;

    procedure UpdateBOMActive(var ProdBomVersion: Record "Production BOM Version")
    var
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMVersion2: Record "Production BOM Version";
        VersionMgt: Codeunit VersionManagement;
        ActiveVersion: Code[20];
    begin
        ProdBomVersion.Modify(false);
        ProdBomVersion.Get(ProdBomVersion.RecordId());
        ActiveVersion := VersionMgt.GetBOMVersion(ProdBomVersion."Production BOM No.", WorkDate(), true);

        ProdBomVersion."BA Active" := ProdBomVersion."Version Code" = ActiveVersion;
        ProdBOMVersion2.SetRange("Production BOM No.", ProdBomVersion."Production BOM No.");
        ProdBOMVersion2.SetFilter("Version Code", '<>%1', ActiveVersion);
        ProdBOMVersion2.ModifyAll("BA Active", false, false);
        if ProdBOMVersion2.Get(ProdBomVersion."Production BOM No.", ActiveVersion) then begin
            ProdBomVersion2."BA Active" := true;
            ProdBomVersion2.Modify(false);
        end;
        ProdBomVersion.Get(ProdBomVersion.RecordId());
        ProdBOMHeader.Get(ProdBomVersion."Production BOM No.");
        ProdBOMHeader."ENC Active Version No." := ActiveVersion;
        ProdBOMHeader.Modify(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Approval Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure ApprovalEntryOnAfterInsert(var Rec: Record "Approval Entry")
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        RecRef: RecordRef;
    begin
        if not RecRef.Get(Rec."Record ID to Approve") or (RecRef.Number <> Database::"Sales Header") then
            exit;
        RecRef.SetTable(SalesHeader);
        Rec."BA Customer Name" := SalesHeader."Bill-to Name";
        Rec."BA Customer No." := SalesHeader."Bill-to Customer No.";
        Rec."BA Payment Terms Code" := SalesHeader."Payment Terms Code";
        Rec."BA Salesperson Code" := SalesHeader."Salesperson Code";
        Customer.Get(Rec."BA Customer No.");
        if UseLCYCreditLimit(Customer) then
            Rec."BA Credit Limit" := Customer."Credit Limit (LCY)"
        else
            Rec."BA Credit Limit" := Customer."BA Credit Limit";
        Rec.CalcFields("BA Last Sales Activity");
        Rec.Modify(false);
    end;

    local procedure UseLCYCreditLimit(var Customer: Record Customer): Boolean
    var
        CustPostingGroup: Record "Customer Posting Group";
    begin
        exit((Customer."Customer Posting Group" = '') or
            (CustPostingGroup.Get(Customer."Customer Posting Group") and not CustPostingGroup."BA Show Non-Local Currency"));
    end;




    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure SalesPostOnAfterPostSalesDoc(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        if Customer.Get(SalesHeader."Bill-to Customer No.") then begin
            Customer."BA Last Sales Activity" := Today();
            Customer.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnAfterPostServiceDoc', '', false, false)]
    local procedure ServicePostOnAfterPostServiceDoc(var ServiceHeader: Record "Service Header")
    var
        Customer: Record Customer;
    begin
        if Customer.Get(ServiceHeader."Bill-to Customer No.") then begin
            Customer."BA Last Sales Activity" := Today();
            Customer.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnBeforeServiceInvHeaderInsert', '', false, false)]
    local procedure ServicePostOnBeforeServiceInvHeaderInsert(var ServiceInvoiceHeader: Record "Service Invoice Header"; ServiceHeader: Record "Service Header")
    var
        FreightTerm: Record "ENC Freight Term";
        ShippingAgent: Record "Shipping Agent";
    begin
        ServiceInvoiceHeader."BA Order No. DrillDown" := ServiceHeader."No.";
        ServiceInvoiceHeader."BA Order No. DrillDown" := ServiceHeader."No.";
        ServiceInvoiceHeader."BA Posting Date DrillDown" := ServiceHeader."Posting Date";
        if (ServiceInvoiceHeader."Shipping Agent Code" <> '') and ShippingAgent.Get(ServiceInvoiceHeader."Shipping Agent Code") then
            ServiceInvoiceHeader."BA Freight Carrier Name" := ShippingAgent.Name;
        if (ServiceInvoiceHeader."ENC Freight Term" <> '') and FreightTerm.Get(ServiceInvoiceHeader."ENC Freight Term") then
            ServiceInvoiceHeader."BA Freight Term Name" := FreightTerm.Description;
    end;


    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'ENC Product ID Code', false, false)]
    local procedure ItemOnAfterValidateProductIDCode(var Rec: Record Item; var xRec: Record Item)
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if not InventorySetup.Get() or (InventorySetup."ENC Def. Product ID Code" = '') or (Rec."ENC Product ID Code" = xRec."ENC Product ID Code") then
            exit;
        if (Rec."ENC Product ID Code" <> InventorySetup."ENC Def. Product ID Code") and (Rec.Blocked) then begin
            if confirm(UnblockItemMsg, false) then begin
                Rec.Validate("Blocked", false);
                Rec.Modify(true);
            end;
        end else
            if Rec."ENC Product ID Code" = InventorySetup."ENC Def. Product ID Code" then begin
                Rec.Validate(Blocked, true);
                Rec.Validate("Block Reason", DefaultBlockReason);
                Rec.Modify(true);
            end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchInvLineInsert', '', false, false)]
    local procedure PurchPostOnBeforePurchInvLineInsert(var PurchaseLine: Record "Purchase Line"; var PurchInvLine: Record "Purch. Inv. Line")
    begin
        PurchInvLine."BA Product ID Code" := PurchaseLine."BA Product ID Code";
        PurchInvLine."BA Project Code" := PurchaseLine."BA Project Code";
        PurchInvLine."BA Shareholder Code" := PurchaseLine."BA Shareholder Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchCrMemoLineInsert', '', false, false)]
    local procedure PurchPostOnBeforePurchCrMemoLineInsert(var PurchLine: Record "Purchase Line"; var PurchCrMemoLine: Record "Purch. Cr. Memo Line")
    begin
        PurchCrMemoLine."BA Product ID Code" := PurchLine."BA Product ID Code";
        PurchCrMemoLine."BA Project Code" := PurchLine."BA Project Code";
        PurchCrMemoLine."BA Shareholder Code" := PurchLine."BA Shareholder Code";
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::DimensionManagement, 'OnGetRecDefaultDimID', '', false, false)]
    local procedure DimMgtOnGetRecDefaultDimID(RecVariant: Variant; var InheritFromTableNo: Integer; var InheritFromDimSetID: Integer; var No: array[10] of Code[20]; CurrFieldNo: Integer)
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        ServiceItemLine: Record "Service Item Line";
        DimSetEntry: Record "Dimension Set Entry";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DefaultDim: Record "Default Dimension";
        RecRef: RecordRef;
        DimMgt: Codeunit DimensionManagement;
        NewDimSetID: Integer;
        DimValueID: Integer;
    begin
        if not RecVariant.IsRecord() or not GetRecord(RecVariant, RecRef) then
            exit;
        case RecRef.Number() of
            Database::"Sales Line":
                if (Format(RecRef.Field(SalesLine.FieldNo(Type)).Value()) <> Format(SalesLine.Type::Item)) or (CurrFieldNo <> SalesLine.FieldNo("No.")) or not Item.Get(No[1]) then
                    exit;
            Database::"Service Item Line":
                if (CurrFieldNo <> ServiceItemLine.FieldNo("Item No.")) or not Item.Get(RecRef.Field(ServiceItemLine.FieldNo("Item No.")).Value()) then
                    exit;
            else
                exit;
        end;

        DefaultDim.SetRange("Table ID", Database::Item);
        DefaultDim.SetRange("No.", Item."No.");
        if not DefaultDim.FindSet() then
            exit;
        DimMgt.GetDimensionSet(TempDimSetEntry, InheritFromDimSetID);
        DimSetEntry.SetCurrentKey("Dimension Value ID");
        DimSetEntry.SetAscending("Dimension Value ID", true);
        if DimSetEntry.FindLast() then
            DimValueID := DimSetEntry."Dimension Value ID";
        DimValueID += 1;
        repeat
            TempDimSetEntry.SetRange("Dimension Code", DefaultDim."Dimension Code");
            if TempDimSetEntry.FindFirst() then
                TempDimSetEntry.Delete(false);
            TempDimSetEntry.Init();
            TempDimSetEntry."Dimension Code" := DefaultDim."Dimension Code";
            TempDimSetEntry."Dimension Value Code" := DefaultDim."Dimension Value Code";
            TempDimSetEntry."Dimension Value ID" := DimValueID;
            TempDimSetEntry.Insert(false);
        until DefaultDim.Next() = 0;
        NewDimSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);
        if NewDimSetID = 0 then
            exit;
        InheritFromTableNo := Database::Item;
        InheritFromDimSetID := NewDimSetID;
    end;

    [TryFunction]
    local procedure GetRecord(var RecVar: Variant; var RecRef: RecordRef)
    begin
        RecRef.GetTable(RecVar);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateEvent', 'BA SEI Order Type', false, false)]
    local procedure PurchaseLineOnBeforeValidateSEIOrderType(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    begin
        if Rec."BA SEI Order Type" = xRec."BA SEI Order Type" then
            exit;
        Rec.Validate("BA SEI Order No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateEvent', 'BA SEI Order No.', false, false)]
    local procedure PurchaseLineOnBeforeValidateSEIOrderNo(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    begin
        if Rec."BA SEI Order No." = xRec."BA SEI Order No." then
            exit;
        if Rec."BA SEI Order No." = '' then begin
            Rec."BA SEI Invoice No." := '';
            exit;
        end;
        case Rec."BA SEI Order Type" of
            Rec."BA SEI Order Type"::"Delta SO":
                GetRelatedSalesFields(Rec."BA SEI Order No.", Rec."BA SEI Invoice No.", true);
            Rec."BA SEI Order Type"::"Delta SVO":
                GetRelatedServiceFields(Rec."BA SEI Order No.", Rec."BA SEI Invoice No.", true);
            Rec."BA SEI Order Type"::"Int. SO":
                GetRelatedSalesFields(Rec."BA SEI Order No.", Rec."BA SEI Invoice No.", false);
            Rec."BA SEI Order Type"::"Int. SVO":
                GetRelatedServiceFields(Rec."BA SEI Order No.", Rec."BA SEI Invoice No.", false);
            Rec."BA SEI Order Type"::Transfer:
                GetRelatedTransferFields(Rec."BA SEI Order No.", Rec."BA SEI Invoice No.");
            Rec."BA SEI Order Type"::" ":
                Error(MissingOrderTypeErr, Rec.FieldCaption("BA SEI Order Type"), Rec.FieldCaption("BA SEI Order No."));
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Line", 'OnBeforeValidateEvent', 'BA SEI Order No.', false, false)]
    local procedure PurchInvLineOnBeforeValidateSEIOrderNo(var Rec: Record "Purch. Inv. Line"; var xRec: Record "Purch. Inv. Line")
    begin
        if Rec."BA SEI Order No." = xRec."BA SEI Order No." then
            exit;
        if Rec."BA SEI Order No." = '' then begin
            Rec."BA SEI Invoice No." := '';
            exit;
        end;
        case Rec."BA SEI Order Type" of
            Rec."BA SEI Order Type"::"Delta SO":
                GetRelatedSalesFields(Rec."BA SEI Order No.", Rec."BA SEI Invoice No.", true);
            Rec."BA SEI Order Type"::"Delta SVO":
                GetRelatedServiceFields(Rec."BA SEI Order No.", Rec."BA SEI Invoice No.", true);
            Rec."BA SEI Order Type"::"Int. SO":
                GetRelatedSalesFields(Rec."BA SEI Order No.", Rec."BA SEI Invoice No.", false);
            Rec."BA SEI Order Type"::"Int. SVO":
                GetRelatedServiceFields(Rec."BA SEI Order No.", Rec."BA SEI Invoice No.", false);
            Rec."BA SEI Order Type"::Transfer:
                GetRelatedTransferFields(Rec."BA SEI Order No.", Rec."BA SEI Invoice No.");
            Rec."BA SEI Order Type"::" ":
                Error(MissingOrderTypeErr, Rec.FieldCaption("BA SEI Order Type"), Rec.FieldCaption("BA SEI Order No."));
        end;
    end;

    local procedure GetRelatedSalesFields(var DocNo: Code[20]; var PostedDocNo: Code[20]; LocalCustomer: Boolean)
    var
        SalesInvHeader: Record "Sales Invoice Header";
        FilterText: Text;
    begin
        SalesInvHeader.SetCurrentKey("Order No.");
        if LocalCustomer then
            SalesInvHeader.SetRange("Order No.", DocNo)
        else
            SalesInvHeader.SetRange("External Document No.", DocNo);

        FilterText := GetIntCustFilter(LocalCustomer);
        if FilterText <> '' then
            SalesInvHeader.SetFilter("Bill-to Customer No.", FilterText);
        if not SalesInvHeader.FindFirst() then
            if LocalCustomer then
                SalesInvHeader.SetFilter("Order No.", StrSubstNo('%1*', DocNo))
            else
                SalesInvHeader.SetFilter("External Document No.", StrSubstNo('%1*', DocNo));
        SalesInvHeader.FindFirst();
        if LocalCustomer then
            DocNo := SalesInvHeader."Order No."
        else
            DocNo := SalesInvHeader."External Document No.";
        PostedDocNo := SalesInvHeader."No.";
    end;

    local procedure GetRelatedServiceFields(var DocNo: Code[20]; var PostedDocNo: Code[20]; LocalCustomer: Boolean)
    var
        ServiceInvHeader: Record "Service Invoice Header";
        FilterText: Text;
    begin
        ServiceInvHeader.SetCurrentKey("Order No.");
        if LocalCustomer then
            ServiceInvHeader.SetRange("Order No.", DocNo)
        else
            ServiceInvHeader.SetRange("ENC External Document No.", DocNo);
        FilterText := GetIntCustFilter(LocalCustomer);
        if FilterText <> '' then
            ServiceInvHeader.SetFilter("Bill-to Customer No.", FilterText);
        if not ServiceInvHeader.FindFirst() then
            if LocalCustomer then
                ServiceInvHeader.SetFilter("Order No.", StrSubstNo('%1*', DocNo))
            else
                ServiceInvHeader.SetFilter("ENC External Document No.", StrSubstNo('%1*', DocNo));
        ServiceInvHeader.FindFirst();
        if LocalCustomer then
            DocNo := ServiceInvHeader."Order No."
        else
            DocNo := ServiceInvHeader."ENC External Document No.";
        PostedDocNo := ServiceInvHeader."No.";
    end;



    local procedure GetRelatedTransferFields(var DocNo: Code[20]; var PostedDocNo: Code[20])
    var
        TransferShptHeader: Record "Transfer Shipment Header";
    begin
        TransferShptHeader.SetCurrentKey("Transfer Order No.");
        TransferShptHeader.SetRange("Transfer Order No.", DocNo);
        if not TransferShptHeader.FindFirst() then
            TransferShptHeader.SetFilter("Transfer Order No.", StrSubstNo('%1*', DocNo));
        TransferShptHeader.FindFirst();
        DocNo := TransferShptHeader."Transfer Order No.";
        PostedDocNo := TransferShptHeader."No.";
    end;

    local procedure GetIntCustFilter(Exclude: Boolean): Text
    var
        CustomerList: List of [Code[20]];
        CustNo: Code[20];
        FilterTxt: TextBuilder;
    begin
        GetInternationalCustomers(CustomerList, true);
        if CustomerList.Count() = 0 then
            exit('');
        CustomerList.Get(1, CustNo);
        if Exclude then
            FilterTxt.Append('<>');
        FilterTxt.Append(CustNo);
        CustomerList.RemoveAt(1);
        if Exclude then
            foreach CustNo in CustomerList do
                FilterTxt.Append('&<>' + CustNo)
        else
            foreach CustNo in CustomerList do
                FilterTxt.Append('|' + CustNo);
        exit(FilterTxt.ToText());
    end;

    local procedure GetInternationalCustomers(var CustomerList: List of [Code[20]]; Sales: Boolean)
    var
        Customer: Record Customer;
    begin
        Clear(CustomerList);
        if Sales then
            Customer.SetRange("BA Int. Customer", true)
        else
            Customer.SetRange("BA Serv. Int. Customer", true);
        if Customer.FindSet() then
            repeat
                CustomerList.Add(Customer."No.");
            until Customer.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostGLAccICLine', '', false, false)]
    local procedure PurchPostOnBeforePostGLAccICLine(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    var
        GLAccount: Record "G/L Account";
    begin
        if not GLAccount.Get(PurchLine."No.") or
            (not GLAccount."BA Freight Charge" and not GLAccount."BA Transfer Charge") then
            exit;
        if GLAccount."BA Freight Charge" then begin
            if PurchLine."BA SEI Order Type" = PurchLine."BA SEI Order Type"::" " then
                Error(LineFieldTypeMissingErr, PurchLine.FieldCaption(PurchLine."BA SEI Order Type"), PurchLine."Line No.");
            if PurchLine."BA Freight Charge Type" = PurchLine."BA Freight Charge Type"::" " then
                Error(LineFieldTypeMissingErr, PurchLine.FieldCaption(PurchLine."BA Freight Charge Type"), PurchLine."Line No.");
        end;
        if PurchLine."BA SEI Order Type" <> PurchLine."BA SEI Order Type"::" " then begin
            PurchLine.TestField("BA SEI Order No.");
            PurchLine.TestField("BA Freight Charge Type");
        end;
        if PurchLine."BA Freight Charge Type" <> PurchLine."BA Freight Charge Type"::" " then begin
            PurchLine.TestField("BA SEI Order No.");
            if PurchLine."BA SEI Order Type" = PurchLine."BA SEI Order Type"::" " then
                Error(LineFieldTypeMissingErr, PurchLine.FieldCaption(PurchLine."BA SEI Order Type"), PurchLine."Line No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeInsertTransShptHeader', '', false, false)]
    local procedure TransferOrderPostShptOnBeforeInsertTransShptHeader(var TransShptHeader: Record "Transfer Shipment Header"; TransHeader: Record "Transfer Header")
    var
        FreightTerm: Record "ENC Freight Term";
        ShippingAgent: Record "Shipping Agent";
    begin
        TransShptHeader."BA Trans. Order No. DrillDown" := TransHeader."No.";
        if (TransShptHeader."Shipping Agent Code" <> '') and ShippingAgent.Get(TransShptHeader."Shipping Agent Code") then
            TransShptHeader."BA Freight Carrier Name" := ShippingAgent.Name;
        if (TransShptHeader."ENC Freight Term" <> '') and FreightTerm.Get(TransShptHeader."ENC Freight Term") then
            TransShptHeader."BA Freight Term Name" := FreightTerm.Description;
    end;




    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeMessageIfSalesLinesExist', '', false, false)]
    local procedure SalesHeaderOnBeforeMessageIfSalesLinesExist(SalesHeader: Record "Sales Header"; ChangedFieldName: Text; var IsHandled: Boolean)
    var
        SalesLine: Record "Sales Line";
        RecIDs: List of [RecordId];
        RecID: RecordId;
    begin
        if ChangedFieldName <> SalesHeader.FieldCaption("Location Code") then
            exit;
        IsHandled := true;
        if not SalesHeader.SalesLinesExist() or SalesHeader.GetHideValidationDialog() then
            exit;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("Location Code", '<>%1', SalesHeader."Location Code");
        if not SalesLine.FindSet(true) then
            exit;
        if not Confirm(UpdateSalesLinesLocationMsg) then
            exit;
        repeat
            RecIDs.Add(SalesLine.RecordId());
        until SalesLine.Next() = 0;
        foreach RecID in RecIDs do begin
            SalesLine.Get(RecID);
            SalesLine.Validate("Location Code", SalesHeader."Location Code");
            SalesLine.Modify(true);
        end;
    end;

    local procedure CheckIfLinesHaveValidLocationCode(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("Location Code", '<>%1', SalesHeader."Location Code");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if not SalesLine.IsEmpty() then
            Error(SalesLinesLocationCodeErr, SalesHeader."Location Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure SalesPostOnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        CheckIfLinesHaveValidLocationCode(SalesHeader);
        CheckCustomerCurrency(SalesHeader);
        CheckPromisedDeliveryDate(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnBeforePostWithLines', '', false, false)]
    local procedure SalesServiceOnBeforePostWithLines(var PassedServHeader: Record "Service Header")
    begin
        CheckCustomerCurrency(PassedServHeader);
        CheckPromisedDeliveryDate(PassedServHeader);
    end;

    local procedure CheckCustomerCurrency(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        CustPostingGroup: Record "Customer Posting Group";
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;
        Customer.Get(SalesHeader."Bill-to Customer No.");
        CustPostingGroup.Get(SalesHeader."Customer Posting Group");
        if SalesHeader."Currency Code" <> CustPostingGroup."BA Posting Currency" then
            CheckCustomerCurrency(CustPostingGroup);
    end;

    local procedure CheckCustomerCurrency(var ServiceHeader: Record "Service Header")
    var
        Customer: Record Customer;
        CustPostingGroup: Record "Customer Posting Group";
    begin
        if ServiceHeader."Document Type" <> ServiceHeader."Document Type"::Order then
            exit;
        Customer.Get(ServiceHeader."Bill-to Customer No.");
        CustPostingGroup.Get(ServiceHeader."Customer Posting Group");
        if ServiceHeader."Currency Code" <> CustPostingGroup."BA Posting Currency" then
            CheckCustomerCurrency(CustPostingGroup);
    end;

    local procedure CheckCustomerCurrency(var CustPostingGroup: Record "Customer Posting Group")
    var
        CurrencyText: Text;
    begin
        if CustPostingGroup."BA Posting Currency" = '' then
            CurrencyText := LocalCurrency
        else
            CurrencyText := CustPostingGroup."BA Posting Currency";
        Error(InvalidCustomerPostingGroupCurrencyErr, CurrencyText, CustPostingGroup.Code);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Dispatcher", 'OnAfterHandleRequest', '', false, false)]
    local procedure JobQueueDispatcherOnAfterHandleRequest(var JobQueueEntry: Record "Job Queue Entry"; WasSuccess: Boolean)
    var
        NotificationEntry: Record "Notification Entry";
        UserSetup: Record "User Setup";
        PageMgt: Codeunit "Page Management";
        RecRef: RecordRef;
    begin
        if WasSuccess or (JobQueueEntry."Object Type to Run" <> JobQueueEntry."Object Type to Run"::Codeunit) or (JobQueueEntry."Object ID to Run" <> 75009) then
            exit;
        UserSetup.SetRange("BA Receive Job Queue Notes.", true);
        if not UserSetup.FindSet() then
            exit;
        RecRef.GetTable(JobQueueEntry);
        repeat
            NotificationEntry.CreateNewEntry(NotificationEntry.Type::"Job Queue Fail", UserSetup."User ID",
                   JobQueueEntry, Page::"Job Queue Entries", PageMgt.GetRTCUrl(RecRef, Page::"Job Queue Entries"), JobQueueEntry."User ID");
        until UserSetup.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Notification Email", 'OnOtherNotificationTypeForTargetRecRef', '', false, false)]
    local procedure NotificationEmailReportOnOtherNotificationTypeForTargetRecRef(NotificationType: Option; SourceRecRef: RecordRef; var TargetRecRef: RecordRef)
    var
        NotificationEntry: Record "Notification Entry";
    begin
        if NotificationType <> NotificationEntry.Type::"Job Queue Fail" then
            exit;
        if SourceRecRef.Number = 0 then
            Error(NoSourceRecErr);
        TargetRecRef := SourceRecRef;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Management", 'OnGetDocumentTypeAndNumber', '', false, false)]
    local procedure NotificationMgtOnGetDocumentTypeAndNumber(var RecRef: RecordRef; var IsHandled: Boolean; var DocumentNo: Text; var DocumentType: Text)
    var
        NotificationEntry: Record "Notification Entry";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if RecRef.Number() <> Database::"Job Queue Entry" then
            exit;
        IsHandled := true;
        RecRef.SetTable(JobQueueEntry);
        JobQueueEntry.CalcFields("Object Caption to Run");
        if JobQueueEntry."Object Caption to Run" <> '' then
            DocumentNo := StrSubstNo('%1 %2 - %3', JobQueueEntry."Object Type to Run", JobQueueEntry."Object ID to Run", JobQueueEntry."Object Caption to Run")
        else
            DocumentNo := StrSubstNo('%1 %2', JobQueueEntry."Object Type to Run", JobQueueEntry."Object ID to Run");
        DocumentType := TitleMsg;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::DimensionManagement, 'OnBeforeCheckCodeMandatory', '', false, false)]
    local procedure DimMgtOnBeforeCheckCodeMandatory(SourceCode: Code[10]; DimensionCode: Code[20]; TableID: Integer; var IsHandled: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        GLSetup.Get();
        if '' in [GLSetup."BA Country Code", GLSetup."BA Region Code"] then
            exit;
        IsHandled := (SourceCode in ['', SourceCodeSetup.Sales, SourceCodeSetup."Service Management"])
            and (TableID = Database::Customer) and (DimensionCode in [GLSetup."BA Country Code", GLSetup."BA Region Code"]);
    end;


    [EventSubscriber(ObjectType::Report, Report::"Copy Item", 'OnAfterCopyItem', '', false, false)]
    local procedure CopyItemOnAfterCopyItem(SourceItem: Record Item; var TargetItem: Record Item)
    var
        RecordLink: Record "Record Link";
        RecordLink2: Record "Record Link";
        LinkID: Integer;
        TempBlob: Record TempBlob;
        IStream: InStream;
        OStream: OutStream;
        s: Text;
    begin
        if RecordLink.FindLast() then
            LinkID := RecordLink."Link ID";
        RecordLink.SetCurrentKey("Record ID");
        RecordLink.SetRange("Record ID", SourceItem.RecordId());
        if RecordLink.FindSet() then
            repeat
                RecordLink.CalcFields(Note);
                RecordLink.Note.CreateInStream(IStream);
                IStream.ReadText(s);
                LinkID += 1;
                RecordLink2.TransferFields(RecordLink);
                RecordLink2."Link ID" := LinkID;
                RecordLink2."Record ID" := TargetItem.RecordId();
                RecordLink2.Created := CurrentDateTime();
                if s <> '' then begin
                    RecordLink2.Note.CreateOutStream(OStream);
                    OStream.WriteText(s);
                end;
                RecordLink2.Insert(false);
            until RecordLink.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeValidateEvent', 'Description', false, false)]
    local procedure ItemOnBeforeValidateDescription(var Rec: Record Item; var xRec: Record Item)
    begin
        if Rec.Description <> xRec.Description then
            if StrLen(Rec.Description) > 40 then
                Error(DescripLengthErr, Rec.FieldCaption(Description), StrLen(Rec.Description));
    end;


    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeValidateEvent', 'Description 2', false, false)]
    local procedure ItemOnBeforeValidateDescription2(var Rec: Record Item; var xRec: Record Item)
    begin
        if Rec."Description 2" <> xRec."Description 2" then
            if StrLen(Rec."Description 2") > 40 then
                Error(DescripLengthErr, Rec.FieldCaption("Description 2"), StrLen(Rec."Description 2"));
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterTestSalesLine', '', false, false)]
    local procedure SalesPostOnAfterTestSalesLine(SalesLine: Record "Sales Line")
    var
        Item: Record Item;
    begin
        if (SalesLine.Type <> SalesLine.Type::Item) or not Item.Get(SalesLine."No.") then
            exit;
        Item.TestField("ENC Not for Sale", false);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnAfterPopulateApprovalEntryArgument', '', false, false)]
    local procedure ApprovalsMgtOnAfterPopulateApprovalEntryArgument(RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        OutstandingAmt: Decimal;
    begin
        if (RecRef.Number <> Database::"Sales Header") then
            exit;
        RecRef.SetTable(SalesHeader);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Quantity, '<>%1', 0);
        if SalesLine.FindSet() then
            repeat
                OutstandingAmt += SalesLine.CalcLineAmount() * SalesLine."Outstanding Quantity" / SalesLine.Quantity;
            until SalesLine.Next() = 0;
        ApprovalEntryArgument."BA Remaining Amount" := OutstandingAmt;
        if SalesHeader."Currency Factor" = 0 then
            ApprovalEntryArgument."BA Remaining Amount (LCY)" := OutstandingAmt
        else
            ApprovalEntryArgument."BA Remaining Amount (LCY)" := Round(OutstandingAmt / SalesHeader."Currency Factor", 0.01);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeApprovalEntryInsert', '', false, false)]
    local procedure ApprovalsMgtOnBeforeApprovalEntryInsert(var ApprovalEntry: Record "Approval Entry"; ApprovalEntryArgument: Record "Approval Entry")
    begin
        ApprovalEntry."BA Remaining Amount" := ApprovalEntryArgument."BA Remaining Amount";
        ApprovalEntry."BA Remaining Amount (LCY)" := ApprovalEntryArgument."BA Remaining Amount (LCY)";
    end;









    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ServLedgEntries-Post", 'OnBeforeServLedgerEntryInsert', '', false, false)]
    local procedure ServLedgEntriesPostOnBeforeServLedgerEntryInsert(var ServiceLedgerEntry: Record "Service Ledger Entry"; ServiceLine: Record "Service Line")
    begin
        ServiceLedgerEntry."BA Description 2" := ServiceLine."Description 2";
    end;



    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'Description', false, false)]
    local procedure ItemOnAfterValidateDescription(var Rec: Record Item; var xRec: Record Item)
    var
        ProdBOMLine: Record "Production BOM Line";
        AssemblyLine: Record "Assembly Line";
        BOMComponent: Record "BOM Component";
        NewDescr: Text;
    begin
        if Rec.Description = xRec.Description then
            exit;
        ProdBOMLine.SetRange("No.", Rec."No.");
        NewDescr := CopyStr(Rec.Description, 1, MaxStrLen(ProdBOMLine.Description));
        ProdBOMLine.ModifyAll(Description, NewDescr, false);

        AssemblyLine.SetRange(Type, AssemblyLine.Type::Item);
        AssemblyLine.SetRange("No.", Rec."No.");
        NewDescr := CopyStr(Rec.Description, 1, MaxStrLen(AssemblyLine.Description));
        AssemblyLine.ModifyAll(Description, NewDescr, false);

        BOMComponent.SetRange("No.", Rec."No.");
        NewDescr := CopyStr(Rec.Description, 1, MaxStrLen(BOMComponent.Description));
        BOMComponent.ModifyAll(Description, NewDescr, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'Description 2', false, false)]
    local procedure ItemOnAfterValidateDescription2(var Rec: Record Item; var xRec: Record Item)
    var
        ProdBOMLine: Record "Production BOM Line";
        AssemblyLine: Record "Assembly Line";
        BOMComponent: Record "BOM Component";
        NewDescr: Text;
    begin
        if Rec."Description 2" = xRec."Description 2" then
            exit;
        ProdBOMLine.SetRange("No.", Rec."No.");
        NewDescr := CopyStr(Rec."Description 2", 1, MaxStrLen(ProdBOMLine."ENC Description 2"));
        ProdBOMLine.ModifyAll("ENC Description 2", NewDescr, false);

        AssemblyLine.SetRange(Type, AssemblyLine.Type::Item);
        AssemblyLine.SetRange("No.", Rec."No.");
        NewDescr := CopyStr(Rec."Description 2", 1, MaxStrLen(AssemblyLine."Description 2"));
        AssemblyLine.ModifyAll("Description 2", NewDescr, false);

        BOMComponent.SetRange("No.", Rec."No.");
        NewDescr := CopyStr(Rec."Description 2", 1, MaxStrLen(BOMComponent."BA Description 2"));
        BOMComponent.ModifyAll("BA Description 2", NewDescr, false);
    end;


    [EventSubscriber(ObjectType::Table, Database::"BOM Buffer", 'OnTransferFromBOMCompCopyFields', '', false, false)]
    local procedure BOMBufferOnTransferFromBOMCompCopyFields(var BOMBuffer: Record "BOM Buffer"; BOMComponent: Record "BOM Component")
    begin
        BOMBuffer."BA Description 2" := BOMComponent."BA Description 2";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Production BOM Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure ProdBOMLineOnAfterValidateNo(var Rec: Record "Production BOM Line"; var xRec: Record "Production BOM Line")
    var
        Item: Record Item;
    begin
        if (Rec."No." <> xRec."No.") and Item.Get(Rec."No.") then
            Rec.Validate("ENC Description 2", Item."Description 2");
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Deposit-Post", 'OnBeforeDepositPost', '', false, false)]
    local procedure DepositPostOnBeforeCheckDepositPost(DepositHeader: Record "Deposit Header")
    var
        GenJnlLine: Record "Gen. Journal Line";
        Customer: Record Customer;
    begin
        GenJnlLine.SetRange("Journal Template Name", DepositHeader."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", DepositHeader."Journal Batch Name");
        GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::Customer);
        GenJnlLine.SetFilter("Account No.", '<>%1', '');
        if GenJnlLine.FindSet() then
            repeat
                Customer.Get(GenJnlLine."Account No.");
                if Customer."Currency Code" <> DepositHeader."Currency Code" then begin
                    if not Confirm(CurrencyPostingMsg) then
                        Error('');
                    exit;
                end;
            until GenJnlLine.Next() = 0;
    end;





    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", 'OnAfterValidateEvent', 'Package Tracking No.', false, false)]
    local procedure SalesInvoiceHeaderOnAfterValidatePackageTrackingNo(var Rec: Record "Sales Invoice Header"; var xRec: Record "Sales Invoice Header")
    begin
        CheckFreightCarrier(Rec."Shipping Agent Code");
        if Rec."Package Tracking No." <> xRec."Package Tracking No." then begin
            Rec.Validate("BA Package Tracking No. Date", CurrentDateTime());
            Rec."Package Tracking No." := Rec."Package Tracking No.".Replace(' ', '');
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Invoice Header", 'OnAfterValidateEvent', 'ENC Package Tracking No.', false, false)]
    local procedure ServiceInvoiceHeaderOnAfterValidatePackageTrackingNo(var Rec: Record "Service Invoice Header"; var xRec: Record "Service Invoice Header")
    begin
        CheckFreightCarrier(Rec."ENC Shipping Agent Code");
        if Rec."ENC Package Tracking No." <> xRec."ENC Package Tracking No." then begin
            Rec.Validate("BA Package Tracking No. Date", CurrentDateTime());
            Rec."ENC Package Tracking No." := Rec."ENC Package Tracking No.".Replace(' ', '');
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Header", 'OnAfterValidateEvent', 'ENC Package Tracking No.', false, false)]
    local procedure TransferShptHeaderOnAfterValidatePackageTrackingNo(var Rec: Record "Transfer Shipment Header"; var xRec: Record "Transfer Shipment Header")
    begin
        CheckFreightCarrier(Rec."Shipping Agent Code");
        if Rec."ENC Package Tracking No." <> xRec."ENC Package Tracking No." then begin
            Rec.Validate("BA Package Tracking No. Date", CurrentDateTime());
            Rec."ENC Package Tracking No." := Rec."ENC Package Tracking No.".Replace(' ', '');
            Rec.Modify(false);
        end;
    end;

    local procedure CheckFreightCarrier(ShippingAgentCode: Code[10])
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        if ShippingAgentCode = '' then
            Error(NoFreightCarrierErr);
        if ShippingAgent.Get(ShippingAgentCode) and ShippingAgent."BA Block Tracking No." then
            Error(InvalidFreightCarrierErr);
    end;




    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterShowDimensions', '', false, false)]
    local procedure SalesLineOnAfterShowDimensions(var Rec: Record "Sales Line"; IsChanged: Boolean)
    var
        UserSetup: Record "User Setup";
    begin
        If not IsChanged or not (Rec."Document Type" in [Rec."Document Type"::Quote, Rec."Document Type"::Order]) then
            exit;
        if not UserSetup.Get(UserId()) or not UserSetup."BA Can Edit Dimensions" then
            Error(DimPermissionErr);
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Deposit-Post", 'OnBeforePostedDepositHeaderInsert', '', false, false)]
    local procedure DepositPostOnBeforePostedDepositHeaderInsert(var PostedDepositHeader: Record "Posted Deposit Header")
    begin
        PostedDepositHeader."BA User ID" := UserId();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure GenJnlCheckLineOnAfterCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        GLAccount: Record "G/L Account";
    begin
        if (GenJournalLine."Account Type" <> GenJournalLine."Account Type"::"G/L Account")
                or not GLAccount.Get(GenJournalLine."Account No.") or not GLAccount."BA Require Description Change" then
            exit;
        GenJournalLine.TestField(Description);
        if GenJournalLine.Description = GLAccount.Name then
            Error(UnchangedDescrErr, GenJournalLine.FieldCaption(Description), GenJournalLine.Description, GenJournalLine."Line No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostGLAccICLine', '', false, false)]
    local procedure PostPurchOnBeforePostGLAccICLine(var PurchLine: Record "Purchase Line")
    var
        GLAccount: Record "G/L Account";
    begin
        if (PurchLine.Type <> PurchLine.Type::"G/L Account")
                or not GLAccount.Get(PurchLine."No.") or not GLAccount."BA Require Description Change" then
            exit;
        PurchLine.TestField(Description);
        if PurchLine.Description = GLAccount.Name then
            Error(UnchangedDescrErr, PurchLine.FieldCaption(Description), PurchLine.Description, PurchLine."Line No.");
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document-Print", 'OnBeforeCalcServDisc', '', false, false)]
    local procedure DocumentPrintOnBeforeCalcServDisc(var ServiceHeader: Record "Service Header"; var IsHandled: Boolean)
    var
        SalesRecSetup: Record "Sales & Receivables Setup";
        ServLine: Record "Service Line";
    begin
        if not SalesRecSetup.Get('') or not SalesRecSetup."Calc. Inv. Discount" then
            exit;
        ServLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServLine.SetRange("Document No.", ServiceHeader."No.");
        IsHandled := ServLine.IsEmpty();
    end;




    [EventSubscriber(ObjectType::Table, Database::"Production Order", 'OnAfterValidateEvent', 'Source No.', false, false)]
    local procedure ProductionOrderOnAfterValidateSourceNo(var Rec: Record "Production Order"; var xRec: Record "Production Order")
    var
        Item: Record Item;
        InventorySetup: Record "Inventory Setup";
    begin
        if (Rec."Source Type" <> Rec."Source Type"::Item) or (Rec."Source No." = xRec."Source No.") or not Item.Get(Rec."Source No.")
                or (Rec.Status <> Rec.Status::Released) then
            exit;
        InventorySetup.Get();
        if InventorySetup."BA Default Location Code" = '' then
            exit;
        Rec.Validate("Location Code", InventorySetup."BA Default Location Code");
        Rec.Modify(true);
        Rec.Get(Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Refresh Production Order", 'OnBeforeCalcProdOrder', '', false, false)]
    local procedure RefreshProductionOrderOnBeforeCalcProdOrder(var ProductionOrder: Record "Production Order")
    var
        Item: Record Item;
    begin
        ProductionOrder.TestField("Source No.");
        if (ProductionOrder."Source Type" <> ProductionOrder."Source Type"::Item) or not Item.Get(ProductionOrder."Source No.") then
            exit;
        ProductionOrder.TestField("Bin Code");
        ProductionOrder.TestField("Location Code");
    end;


    [EventSubscriber(ObjectType::Table, Database::"Bin Content", 'OnAfterInsertEvent', '', false, false)]
    local procedure BinContentOnAfterInsert(var Rec: Record "Bin Content")
    begin
        if '' in [Rec."Item No.", Rec."Bin Code", Rec."Location Code"] then
            exit;
        UpdateProductionOrderBinCodes(Rec."Item No.", Rec."Bin Code", Rec."Location Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bin Content", 'OnAfterValidateEvent', 'Bin Code', false, false)]
    local procedure BinContentOnAfterValidateBinCode(var Rec: Record "Bin Content")
    begin
        if '' in [Rec."Item No.", Rec."Location Code"] then
            exit;
        UpdateProductionOrderBinCodes(Rec."Item No.", Rec."Bin Code", Rec."Location Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bin Content", 'OnAfterValidateEvent', 'Item No.', false, false)]
    local procedure BinContentOnAfterValidateItemNo(var Rec: Record "Bin Content")
    begin
        if '' in [Rec."Item No.", Rec."Bin Code", Rec."Location Code"] then
            exit;
        UpdateProductionOrderBinCodes(Rec."Item No.", Rec."Bin Code", Rec."Location Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bin Content", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure BinContentOnAfterValidateLocationCode(var Rec: Record "Bin Content")
    begin
        if '' in [Rec."Item No.", Rec."Bin Code", Rec."Location Code"] then
            exit;
        UpdateProductionOrderBinCodes(Rec."Item No.", Rec."Bin Code", Rec."Location Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bin Content", 'OnAfterDeleteEvent', '', false, false)]
    local procedure BinContentOnAfterDelete(var Rec: Record "Bin Content")
    begin
        if Rec."Item No." <> '' then
            UpdateProductionOrderBinCodes(Rec."Item No.", '', Rec."Location Code");
    end;

    local procedure UpdateProductionOrderBinCodes(ItemNo: Code[20]; BinCode: Code[20]; LocationCode: Code[20])
    var
        ProdOrder: Record "Production Order";
    begin
        ProdOrder.SetRange(Status, ProdOrder.Status::Released);
        ProdOrder.SetCurrentKey("Source Type", "Source No.");
        ProdOrder.SetRange("Source Type", ProdOrder."Source Type"::Item);
        ProdOrder.SetRange("Source No.", ItemNo);
        ProdOrder.SetRange("Location Code", LocationCode);
        if ProdOrder.FindSet() then
            repeat
                ProdOrder.Validate("Bin Code", BinCode);
                ProdOrder.Modify(false);
            until ProdOrder.Next() = 0;
    end;

    local procedure CheckServiceItem(var SalesLine: Record "Sales Line")
    var
        Item: Record Item;
        Customer: Record Customer;
    begin
        if (SalesLine.Type = SalesLine.Type::Item)
                and (SalesLine."Document Type" in [SalesLine."Document Type"::Quote, SalesLine."Document Type"::Order, SalesLine."Document Type"::Invoice])
                and Item.Get(SalesLine."No.") and Item."BA Service Item Only"
                and Customer.Get(SalesLine."Bill-to Customer No.") and not Customer."BA SEI Service Center" then
            Error(NonServiceCustomerErr, Item."No.");
    end;




    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Standard Codes Mgt.", 'OnBeforeShowGetPurchRecurringLinesNotification', '', false, false)]
    local procedure StandardCodesMgtOnBeforeShowGetPurchRecurringLinesNotification(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    var
        StdVendorPurchCode: Record "Standard Vendor Purchase Code";
        StdCodeMgt: Codeunit "Standard Codes Mgt.";
    begin
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Invoice then
            exit;
        StdVendorPurchCode.SetRange("Vendor No.", PurchaseHeader."Buy-from Vendor No.");
        StdVendorPurchCode.SetRange("Insert Rec. Lines On Invoices", StdVendorPurchCode."Insert Rec. Lines On Invoices"::Automatic);
        if StdVendorPurchCode.IsEmpty() then
            exit;
        IsHandled := true;
        PurchaseHeader.Modify(false);
        StdCodeMgt.GetPurchRecurringLines(PurchaseHeader);
        PurchaseHeader.Get(PurchaseHeader.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Standard Vendor Purchase Code", 'OnBeforeApplyStdCodesToPurchaseLines', '', false, false)]
    local procedure StandardVendorPurchaseCodeOnBeforeApplyStdCodesToPurchaseLines(var PurchLine: Record "Purchase Line"; StdPurchLine: Record "Standard Purchase Line")
    var
        Vendor: Record Vendor;
        TaxGroup: Record "Tax Group";
    begin
        PurchLine.Description := StdPurchLine.Description;
        if not Vendor.Get(PurchLine."Buy-from Vendor No.") or not Vendor."Tax Liable" then
            exit;
        TaxGroup.SetRange("BA Non-Taxable", false);
        if TaxGroup.FindFirst() then
            PurchLine.Validate("Tax Group Code", TaxGroup.Code);
    end;



    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Line", 'OnAfterValidateEvent', 'ENC Manufacturing Dept.', false, false)]
    local procedure ProdOrderLineOnAfterValdidateManufacturingDept(var Rec: Record "Prod. Order Line"; var xRec: Record "Prod. Order Line")
    var
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        Item: Record Item;
    begin
        ProdOrderLine.SetRange(Status, Rec.Status);
        ProdOrderLine.SetRange("Prod. Order No.", Rec."Prod. Order No.");
        ProdOrderLine.SetFilter("Line No.", '<%1', Rec."Line No.");
        if ProdOrderLine.IsEmpty() and (Rec."ENC Manufacturing Dept." <> xRec."ENC Manufacturing Dept.")
                and Item.Get(Rec."Item No.") and ProdOrder.Get(Rec.Status, Rec."Prod. Order No.") then
            UpdateItemAndProdOrderManfDept(Item, ProdOrder, Rec."ENC Manufacturing Dept.");
    end;

    [EventSubscriber(ObjectType::Report, Report::"Refresh Production Order", 'OnAfterRefreshProdOrder', '', false, false)]
    local procedure RefreshProductionOrderOnAfterRefreshProdOrder(var ProductionOrder: Record "Production Order")
    var
        ProdOrderLine: Record "Prod. Order Line";
        Item: Record Item;
    begin
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        if ProdOrderLine.FindFirst() and (ProdOrderLine."ENC Manufacturing Dept." <> '')
                and Item.Get(ProdOrderLine."Item No.") then
            UpdateItemAndProdOrderManfDept(Item, ProductionOrder, ProdOrderLine."ENC Manufacturing Dept.");
    end;

    local procedure UpdateItemAndProdOrderManfDept(var Item: Record Item; var ProdOrder: Record "Production Order"; DeptCode: Text)
    begin
        if (Item."ENC Manufacturing Dept." = '') and (DeptCode <> '') then
            if Confirm(StrSubstNo(UpdateItemManfDeptConf, Item.FieldCaption("ENC Manufacturing Dept."))) then begin
                Item.Validate("ENC Manufacturing Dept.", DeptCode);
                Item.Modify(true);
            end;
        ProdOrder.Validate("BA Assigned Dept.", DeptCode);
        ProdOrder.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnAfterPostPrepayments', '', false, false)]
    local procedure SalesPostPrepaymentsOnAfterPostPrepayments(SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; DocumentType: Option)
    var
        ArchiveMgt: Codeunit ArchiveManagement;
    begin
        if (DocumentType <> 0) or (SalesInvoiceHeader."No." = '') then
            exit;
        ArchiveMgt.StoreSalesDocument(SalesHeader, false);
        SalesInvoiceHeader."Order No." := SalesHeader."No.";
        SalesInvoiceHeader."ENC Assigned User ID" := SalesHeader."Assigned User ID";
        SalesInvoiceHeader."BA Actual Posting DateTime" := CurrentDateTime();
        SalesInvoiceHeader.Modify(false);
    end;



    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeSalesHeaderInsert(var Rec: Record "Sales Header")
    begin
        if Rec."Document Type" = Rec."Document Type"::Order then begin
            Rec."Compress Prepayment" := true;
            Rec."Prepmt. Include Tax" := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Tax Calculate", 'OnBeforeAddSalesLineGetSalesHeader', '', false, false)]
    local procedure SalesTaxCalculateOnBeforeAddSalesLineGetSalesHeader(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    var
        SalesHeaderArchive: Record "Sales Header Archive";
    begin
        if not SalesLine."Prepayment Line" and (SalesLine."Prepayment Amount" = 0) then
            if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
                exit;
        IsHandled := true;
        if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            exit;
        SalesHeaderArchive.SetRange("Document Type", SalesLine."Document Type");
        SalesHeaderArchive.SetRange("No.", SalesLine."Document No.");
        SalesHeaderArchive.FindLast();
        SalesHeader.Init();
        SalesHeader.TransferFields(SalesHeaderArchive, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeRecreateSalesLinesHandler', '', false, false)]
    local procedure SalesHeaderOnBeforeRecreateSalesLinesHandler(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
        if SalesHeader."BA Skip Sales Line Recreate" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeRecreateServiceLinesHandler', '', false, false)]
    local procedure ServiceHeaderOnBeforeRecreateServiceLinesHandler(var Rec: Record "Service Header"; var IsHandled: Boolean)
    begin
        if Rec."BA Skip Sales Line Recreate" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnBeforeModifySalesOrderHeader', '', false, false)]
    local procedure SalesQuoteToOrderOnBeforeModifySalesOrderHeader(var SalesOrderHeader: Record "Sales Header"; SalesQuoteHeader: Record "Sales Header")
    var
        CustPostingGroup: Record "Customer Posting Group";
        CurrExchRate: Record "Currency Exchange Rate";
        DiffDate: Boolean;
    begin
        if (SalesOrderHeader."Order Date" = WorkDate()) and (SalesOrderHeader."Posting Date" = WorkDate()) then
            exit;
        SalesOrderHeader.SetHideValidationDialog(true);
        SalesOrderHeader."BA Skip Sales Line Recreate" := true;
        SalesOrderHeader.Validate("Posting Date", WorkDate());
        DiffDate := SalesOrderHeader."Order Date" = 0D;
        if not DiffDate then
            DiffDate := ((Date2DMY(WorkDate(), 2) <> Date2DMY(SalesOrderHeader."Order Date", 2))
                or (Date2DMY(WorkDate(), 3) <> Date2DMY(SalesOrderHeader."Order Date", 3)));
        if DiffDate and CustPostingGroup.Get(SalesOrderHeader."Customer Posting Group") and (CustPostingGroup."BA Posting Currency" <> '') then
            SalesOrderHeader.Validate("Currency Factor", CurrExchRate.GetCurrentCurrencyFactor(SalesOrderHeader."Currency Code"));
        SalesOrderHeader.SetHideValidationDialog(false);
        SalesOrderHeader."BA Skip Sales Line Recreate" := false;
        SalesOrderHeader.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Adjustment", 'OnPostItemJnlLineCopyFromValueEntry', '', false, false)]
    local procedure InventoryAdjustmentOnPostItemJnlLineCopyFromValueEntry(var ItemJournalLine: Record "Item Journal Line"; ValueEntry: Record "Value Entry")
    var
        UserSetup: Record "User Setup";
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        if UserSetup.Get(UserId()) then;
        if (ItemJournalLine."Posting Date" >= GLSetup."Allow Posting From") and (ItemJournalLine."Posting Date" >= UserSetup."Allow Posting From") then
            exit;
        if UserSetup."Allow Posting From" > ItemJournalLine."Posting Date" then
            ItemJournalLine."Posting Date" := UserSetup."Allow Posting From";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Deposit Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure PostedDepositHeaderOnAfterInsert(var Rec: Record "Posted Deposit Header")
    begin
        Rec."BA Actual Posting DateTime" := CurrentDateTime();
        Rec.Modify(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Invoice Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure ServiceInvoiceHeaderOnAfterInsert(var Rec: Record "Service Invoice Header")
    begin
        Rec."BA Actual Posting DateTime" := CurrentDateTime();
        Rec.Modify(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Cr.Memo Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure ServiceCrMemoHeaderOnAfterInsert(var Rec: Record "Service Cr.Memo Header")
    begin
        Rec."BA Actual Posting DateTime" := CurrentDateTime();
        Rec.Modify(false);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnAfterOnRun', '', false, false)]
    local procedure SalesQuoteToOrderOnAfterRun(var SalesHeader: Record "Sales Header"; var SalesOrderHeader: Record "Sales Header")
    begin
        SalesHeader."BA SEI Int'l Ref. No." := SalesOrderHeader."BA SEI Int'l Ref. No.";
    end;


    procedure ImportCustomerList()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        ExcelBuffer2: Record "Excel Buffer" temporary;
        ErrorBuffer: Record "Name/Value Buffer" temporary;
        TempBlob: Record TempBlob;
        Customer: Record Customer;
        FileMgt: Codeunit "File Management";
        IStream: InStream;
        Window: Dialog;
        FileName: Text;
        RecCount: Integer;
        i: Integer;
        i2: Integer;
        i3: Integer;
    begin
        if FileMgt.BLOBImportWithFilter(TempBlob, 'Select Customer List', '', 'Excel|*.xlsx', 'Excel|*.xlsx') = '' then
            exit;
        TempBlob.Blob.CreateInStream(IStream);
        if not ExcelBuffer.GetSheetsNameListFromStream(IStream, ErrorBuffer) then
            Error('No Sheets in file.');
        ErrorBuffer.FindFirst();
        ExcelBuffer.OpenBookStream(IStream, ErrorBuffer.Value);
        ExcelBuffer.ReadSheet();


        ExcelBuffer.SetFilter("Row No.", '>%1', 1);
        ExcelBuffer.SetFilter("Cell Value as Text", '<>%1', '');
        if not ExcelBuffer.FindSet() then
            exit;
        Window.Open('#1####/#2####');
        Window.Update(1, 'Reading Lines');
        repeat
            ExcelBuffer2 := ExcelBuffer;
            ExcelBuffer2.Insert(true);
        until ExcelBuffer.Next() = 0;
        ExcelBuffer.SetRange("Column No.", 1);
        ExcelBuffer.FindSet();
        RecCount := ExcelBuffer.Count();

        repeat
            i += 1;
            Window.Update(2, StrSubstNo('%1 of %2', i, RecCount));
            if not Customer.Get(ExcelBuffer."Cell Value as Text") then begin
                Customer.Init();
                Customer.Validate("No.", ExcelBuffer."Cell Value as Text");
                ExcelBuffer2.Get(ExcelBuffer."Row No.", 2);
                Customer."ENC Created By" := ExcelBuffer2."Cell Value as Text";
                ExcelBuffer2.Get(ExcelBuffer."Row No.", 3);
                Customer."ENC Creation Date" := ParseDate(ExcelBuffer2."Cell Value as Text");
                Customer.Insert(false);
                i2 += 1;
            end else begin
                ExcelBuffer2.Get(ExcelBuffer."Row No.", 2);
                Customer."ENC Created By" := ExcelBuffer2."Cell Value as Text";
                ExcelBuffer2.Get(ExcelBuffer."Row No.", 3);
                Customer."ENC Creation Date" := ParseDate(ExcelBuffer2."Cell Value as Text");
                Customer.Modify(false);
                i3 += 1;
            end;
        until ExcelBuffer.Next() = 0;
        Window.Close();
        Message('Inserted %1 new customers, updated %2 existing customers.', i2, i3);
    end;

    local procedure ParseDate(Input: Text): Date
    var
        Parts: list of [Text];
        s: Text;
        DD: Integer;
        MM: Integer;
        YY: Integer;
    begin
        Parts := Input.Split('/');
        Parts.Get(1, s);
        Evaluate(MM, s);
        Parts.Get(2, s);
        Evaluate(DD, s);
        Parts.Get(3, s);
        Evaluate(YY, s);
        if YY < 100 then
            YY += 2000;
        exit(DMY2Date(DD, MM, YY));
    end;



    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeRename', '', false, false)]
    local procedure SalesHeaderOnBeforeRename(var xRec: Record "Sales Header"; var Rec: Record "Sales Header"; var IsHandled: Boolean)
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        if Rec."BA Allow Rename" then begin
            ApprovalEntry.SetRange("Record ID to Approve", xRec.RecordId());
            ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
            if not ApprovalEntry.IsEmpty() then
                Error(PendingApprovalErr);
            RenameSalesHeader(Rec, xRec);
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeRename', '', false, false)]
    local procedure SalesLineOnBeforeRename(var Rec: Record "Sales Line"; var IsHandled: Boolean)
    begin
        if Rec."BA Allow Rename" then
            IsHandled := true;
    end;

    local procedure RenameSalesHeader(var SalesHeader: Record "Sales Header"; var xSalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        SalesCommentLine: Record "Sales Comment Line";
        SalesTaxAmountDiff: Record "Sales Tax Amount Difference";
        AssemblyToOrderLink: Record "Assemble-to-Order Link";
        PurchLine: Record "Purchase Line";
        TrackingSpec: Record "Tracking Specification";
        ReservationEntry: Record "Reservation Entry";
        ItemChargeAssignment: Record "Item Charge Assignment (Sales)";
        RequisitionLine: Record "Requisition Line";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesShptLine: Record "Sales Shipment Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        WhseActivityHdr: Record "Warehouse Activity Header";
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseRequest: Record "Warehouse Request";
        RecordLink: Record "Record Link";
        GLEntry: Record "G/L Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        RecIDs: List of [RecordId];
        RecIDs2: List of [RecordId];
        RecIDs3: List of [RecordId];
        RecID: RecordId;
    begin
        SalesTaxAmountDiff.SetRange("Document Type", SalesTaxAmountDiff."Document Type"::Order);
        SalesTaxAmountDiff.SetRange("Document Product Area", SalesTaxAmountDiff."Document Product Area"::Sales);
        SalesTaxAmountDiff.SetRange("Document No.", xSalesHeader."No.");
        if SalesTaxAmountDiff.FindSet() then
            repeat
                RecIDs.Add(SalesTaxAmountDiff.RecordId);
            until SalesTaxAmountDiff.Next() = 0;
        foreach RecID in RecIDs do begin
            SalesTaxAmountDiff.Get(RecID);
            with SalesTaxAmountDiff do
                Rename("Document Product Area", "Document Type", SalesHeader."No.", "Tax Area Code", "Tax Jurisdiction Code",
                        "Tax %", "Tax Group Code", "Expense/Capitalize", "Tax Type", "Use Tax");
        end;

        Clear(RecIDs);
        SalesCommentLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesCommentLine.SetRange("No.", xSalesHeader."No.");
        if SalesCommentLine.FindSet() then
            repeat
                RecIDs.Add(SalesCommentLine.RecordId);
            until SalesCommentLine.Next() = 0;
        foreach RecID in RecIDs do begin
            SalesCommentLine.Get(RecID);
            with SalesCommentLine do
                Rename("Document Type", SalesHeader."No.", "Document Line No.", "Line No.");
        end;


        Clear(RecIDs);
        AssemblyToOrderLink.SetRange(Type, AssemblyToOrderLink.Type::Sale);
        AssemblyToOrderLink.SetRange("Document Type", AssemblyToOrderLink."Document Type"::Order);
        AssemblyToOrderLink.SetRange("Document No.", xSalesHeader."No.");
        if AssemblyToOrderLink.FindSet() then
            repeat
                RecIDs.Add(AssemblyToOrderLink.RecordId());
            until AssemblyToOrderLink.Next() = 0;
        foreach RecID in RecIDs do begin
            AssemblyToOrderLink.Get(RecID);
            AssemblyToOrderLink."Document No." := SalesHeader."No.";
            AssemblyToOrderLink.Modify(false);
        end;

        Clear(RecIDs);
        ReservationEntry.SetRange("Source Type", Database::"Sales Header", Database::"Sales Line");
        ReservationEntry.SetRange("Source Subtype", SalesHeader."Document Type");
        ReservationEntry.SetRange("Source ID", xSalesHeader."No.");
        if ReservationEntry.FindSet() then
            repeat
                RecIDs.Add(ReservationEntry.RecordId());
            until ReservationEntry.Next() = 0;
        foreach RecID in RecIDs do begin
            ReservationEntry.Get(RecID);
            ReservationEntry."Source ID" := SalesHeader."No.";
            ReservationEntry.Modify(false);
        end;

        Clear(RecIDs);
        TrackingSpec.SetRange("Source Type", Database::"Sales Header", Database::"Sales Line");
        TrackingSpec.SetRange("Source Subtype", SalesHeader."Document Type");
        TrackingSpec.SetRange("Source ID", xSalesHeader."No.");
        if TrackingSpec.FindSet() then
            repeat
                RecIDs.Add(TrackingSpec.RecordId());
            until TrackingSpec.Next() = 0;
        foreach RecID in RecIDs do begin
            TrackingSpec.Get(RecID);
            TrackingSpec."Source ID" := SalesHeader."No.";
            TrackingSpec.Modify(false);
        end;

        Clear(RecIDs);
        PurchLine.SetRange("Sales Order No.", xSalesHeader."No.");
        if PurchLine.FindSet() then
            repeat
                RecIDs.Add(PurchLine.RecordId());
            until PurchLine.Next() = 0;
        foreach RecID in RecIDs do begin
            PurchLine.Get(RecID);
            PurchLine."Sales Order No." := SalesHeader."No.";
            PurchLine.Modify(false);
        end;

        Clear(RecIDs);
        RequisitionLine.SetRange("Sales Order No.", xSalesHeader."No.");
        if RequisitionLine.FindSet() then
            repeat
                RecIDs.Add(RequisitionLine.RecordId());
            until RequisitionLine.Next() = 0;
        foreach RecID in RecIDs do begin
            RequisitionLine.Get(RecID);
            RequisitionLine."Sales Order No." := SalesHeader."No.";
            RequisitionLine.Modify(false);
        end;

        Clear(RecIDs);
        ItemChargeAssignment.SetRange("Document Type", SalesHeader."Document Type");
        ItemChargeAssignment.SetRange("Document No.", xSalesHeader."No.");
        if ItemChargeAssignment.FindSet() then
            repeat
                RecIDs.Add(ItemChargeAssignment.RecordId());
            until ItemChargeAssignment.Next() = 0;
        foreach RecID in RecIDs do begin
            ItemChargeAssignment.Get(RecID);
            with ItemChargeAssignment do
                Rename("Document Type", SalesHeader."No.", "Document Line No.", "Line No.");
        end;

        Clear(RecIDs);
        SalesInvHeader.SetRange("Order No.", xSalesHeader."No.");
        if SalesInvHeader.FindSet() then begin
            GLEntry.SetRange("Document Type", GLEntry."Document Type"::Invoice);
            GLEntry.SetRange(Description, StrSubstNo('Order %1'), xSalesHeader."No.");
            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
            CustLedgerEntry.SetRange(Description, StrSubstNo('Order %1'), xSalesHeader."No.");
            repeat
                GLEntry.SetRange("Document No.", SalesInvHeader."No.");
                if GLEntry.FindSet() then
                    repeat
                        RecIDs2.Add(GLEntry.RecordId());
                    until GLEntry.Next() = 0;
                CustLedgerEntry.SetRange("Document No.", SalesInvHeader."No.");
                if CustLedgerEntry.FindSet() then
                    repeat
                        RecIDs3.Add(CustLedgerEntry.RecordId());
                    until CustLedgerEntry.Next() = 0;
                RecIDs.Add(SalesInvHeader.RecordId());
            until SalesInvHeader.Next() = 0;
            foreach RecID in RecIDs2 do begin
                GLEntry.Get(RecID);
                GLEntry.Description := StrSubstNo('Order %1', SalesHeader."No.");
                GLEntry.Modify(false);
            end;
            foreach RecID in RecIDs3 do begin
                CustLedgerEntry.Get(RecID);
                CustLedgerEntry.Description := StrSubstNo('Order %1', SalesHeader."No.");
                CustLedgerEntry.Modify(false);
            end;
        end;
        foreach RecID in RecIDs do begin
            SalesInvHeader.Get(RecID);
            SalesInvHeader."Order No." := SalesHeader."No.";
            SalesInvHeader.Modify(false);
        end;
        Clear(RecIDs);
        SalesInvLine.SetRange("Order No.", xSalesHeader."No.");
        if SalesInvLine.FindSet() then
            repeat
                RecIDs.Add(SalesInvLine.RecordId());
            until SalesInvLine.Next() = 0;
        foreach RecID in RecIDs do begin
            SalesInvLine.Get(RecID);
            SalesInvLine."Order No." := SalesHeader."No.";
            SalesInvLine.Modify(false);
        end;

        Clear(RecIDs);
        SalesShptHeader.SetRange("Order No.", xSalesHeader."No.");
        if SalesShptHeader.FindSet() then
            repeat
                RecIDs.Add(SalesShptHeader.RecordId());
            until SalesShptHeader.Next() = 0;
        foreach RecID in RecIDs do begin
            SalesShptHeader.Get(RecID);
            SalesShptHeader."Order No." := SalesHeader."No.";
            SalesShptHeader.Modify(false);
        end;
        Clear(RecIDs);
        SalesShptLine.SetRange("Order No.", xSalesHeader."No.");
        if SalesShptLine.FindSet() then
            repeat
                RecIDs.Add(SalesShptLine.RecordId());
            until SalesShptLine.Next() = 0;
        foreach RecID in RecIDs do begin
            SalesShptLine.Get(RecID);
            SalesShptLine."Order No." := SalesHeader."No.";
            SalesShptLine.Modify(false);
        end;

        Clear(RecIDs);
        SalesCrMemoHeader.SetRange("Return Order No.", xSalesHeader."No.");
        if SalesCrMemoHeader.FindSet() then
            repeat
                RecIDs.Add(SalesCrMemoHeader.RecordId());
            until SalesCrMemoHeader.Next() = 0;
        foreach RecID in RecIDs do begin
            SalesCrMemoHeader.Get(RecID);
            SalesCrMemoHeader."Return Order No." := SalesHeader."No.";
            SalesCrMemoHeader.Modify(false);
        end;
        Clear(RecIDs);
        SalesCrMemoLine.SetRange("Order No.", xSalesHeader."No.");
        if SalesCrMemoLine.FindSet() then
            repeat
                RecIDs.Add(SalesCrMemoLine.RecordId());
            until SalesCrMemoLine.Next() = 0;
        foreach RecID in RecIDs do begin
            SalesCrMemoLine.Get(RecID);
            SalesCrMemoLine."Order No." := SalesHeader."No.";
            SalesCrMemoLine.Modify(false);
        end;


        Clear(RecIDs);
        WhseActivityHdr.SetRange("Source Type", Database::"Sales Line");
        WhseActivityHdr.SetRange("Source Subtype", SalesHeader."Document Type"::Order);
        WhseActivityHdr.SetRange("Source No.", xSalesHeader."No.");
        if WhseActivityHdr.FindSet() then
            repeat
                RecIDs.Add(WhseActivityHdr.RecordId());
            until WhseActivityHdr.Next() = 0;
        foreach RecID in RecIDs do begin
            WhseActivityHdr.Get(RecID);
            WhseActivityHdr."Source No." := SalesHeader."No.";
            WhseActivityHdr.Modify(false);
        end;

        Clear(RecIDs);
        WhseActivityLine.SetRange("Source Type", Database::"Sales Line");
        WhseActivityLine.SetRange("Source Subtype", SalesHeader."Document Type"::Order);
        WhseActivityLine.SetRange("Source No.", xSalesHeader."No.");
        if WhseActivityLine.FindSet() then
            repeat
                RecIDs.Add(WhseActivityLine.RecordId());
            until WhseActivityLine.Next() = 0;
        foreach RecID in RecIDs do begin
            WhseActivityLine.Get(RecID);
            WhseActivityLine."Source No." := SalesHeader."No.";
            WhseActivityLine.Modify(false);
        end;

        Clear(RecIDs);
        RecordLink.SetRange("Record ID", xSalesHeader.RecordId());
        if RecordLink.FindSet() then
            repeat
                RecIDs.Add(RecordLink.RecordId());
            until RecordLink.Next() = 0;
        foreach RecID in RecIDs do begin
            RecordLink.Get(RecID);
            RecordLink."Record ID" := SalesHeader.RecordId();
            RecordLink.Modify(false);
        end;

        Clear(RecIDs);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", xSalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                RecIDs.Add(SalesLine.RecordId());
            until SalesLine.Next() = 0;
        foreach RecID in RecIDs do begin
            SalesLine.Get(RecID);
            SalesLine."BA Allow Rename" := true;
            SalesLine.Modify(false);
            with SalesLine do
                Rename("Document Type", SalesHeader."No.", "Line No.");
            SalesLine."BA Allow Rename" := false;
            SalesLine.Modify(false);
        end;

        SalesHeader."Posting Description" := StrSubstNo('%1 %2', SalesHeader."Document Type", SalesHeader."No.");
    end;


    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnValidateShipToCodeBeforeConfirmDialog', '', false, false)]
    local procedure ServiceHeaderOnValidateShipToCodeBeforeConfirmDialog(var Rec: Record "Service Header"; var xRec: Record "Service Header"; var IsHandled: Boolean)
    begin
        if Rec."Ship-to Code" <> xRec."Ship-to Code" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnValidateShipToCodeBeforeDeleteLines', '', false, false)]
    local procedure ServiceHeaderOnValidateShipToCodeBeforeDeleteLines(var Rec: Record "Service Header"; var IsHandled: Boolean)
    var
        ServLine: Record "Service Line";
        ServItemLine: Record "Service Item Line";
    begin
        IsHandled := true;
        Rec.Modify(true);
        ServLine.SetRange("Document Type", Rec."Document Type");
        ServLine.SetRange("Document No.", Rec."No.");
        if ServLine.FindSet(true) then
            repeat
                ServLine.Validate("Ship-to Code", Rec."Ship-to Code");
                ServLine.Modify(true);
            until ServLine.Next() = 0;

        ServItemLine.SetRange("Document Type", Rec."Document Type");
        ServItemLine.SetRange("Document No.", Rec."No.");
        if ServItemLine.FindSet(true) then
            repeat
                ServItemLine.Validate("Ship-to Code", Rec."Ship-to Code");
                ServItemLine.Modify(true);
            until ServItemLine.Next() = 0;
    end;




    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnAfterOnRun', '', false, false)]
    local procedure SalesQuoteToOrderOnAfterOnRun(var SalesOrderHeader: Record "Sales Header")
    begin
        SalesOrderHeader.SetHideValidationDialog(true);
        SalesOrderHeader.Validate("Document Date", Today());
        SalesOrderHeader.Validate("Order Date", Today());
        SalesOrderHeader.Validate("Shipment Date", 0D);
        SalesOrderHeader.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Quote to Order", 'OnBeforeServLineDeleteAll', '', false, false)]
    local procedure ServiceQuoteToOrderOnBeforeServLineDeleteAll(var NewServiceHeader: Record "Service Header"; var ServiceHeader: Record "Service Header")
    begin
        NewServiceHeader.SetHideValidationDialog(true);
        NewServiceHeader.Validate("Document Date", Today());
        NewServiceHeader.Validate("Order Date", Today());
        NewServiceHeader.Validate("BA Quote Date", ServiceHeader."BA Quote Date");
        NewServiceHeader.Modify(true);
        NewServiceHeader.Get(NewServiceHeader.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterInitRecord', '', false, false)]
    local procedure ServiceHeaderOnAfterInitRecord(var ServiceHeader: Record "Service Header")
    var
        SalesRecSetup: Record "Sales & Receivables Setup";
    begin
        case ServiceHeader."Document Type" of
            ServiceHeader."Document Type"::Quote:
                begin
                    ServiceHeader.SetHideValidationDialog(true);
                    ServiceHeader.Validate("Order Date", 0D);
                    ServiceHeader.Validate("BA Quote Date", Today());
                end;
            ServiceHeader."Document Type"::Order:
                if SalesRecSetup.Get() and (SalesRecSetup."BA Default Reason Code" <> '') then
                    ServiceHeader.Validate("Reason Code", SalesRecSetup."BA Default Reason Code");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bill-to Customer No.', false, false)]
    local procedure SalesHeaderOnAfterValidateBillToCustomerNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        if (xRec."Bill-to Customer No." <> Rec."Bill-to Customer No.") and Customer.Get(Rec."Bill-to Customer No.") then
            Rec.Validate("BA EORI No.", Customer."BA EORI No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer No.', false, false)]
    local procedure SalesHeaderOnAfterValidateSellToCustomerNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        if (xRec."Sell-to Customer No." <> Rec."Sell-to Customer No.") and Customer.Get(Rec."Sell-to Customer No.") then begin
            Rec.Validate("BA EORI No.", Customer."BA EORI No.");
            Rec.Validate("BA Ship-to Email", Customer."BA Ship-to Email");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure ServiceHeaderOnAfterValidateCustomerNo(var Rec: Record "Service Header"; var xRec: Record "Service Header")
    var
        Customer: Record Customer;
    begin
        if (xRec."Customer No." <> Rec."Customer No.") and Customer.Get(Rec."Customer No.") then begin
            Rec.Validate("BA EORI No.", Customer."BA EORI No.");
            Rec.Validate("Ship-to E-mail", Customer."BA Ship-to Email");
        end;
    end;


    local procedure CheckPromisedDeliveryDate(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        if (SalesHeader."Document Type" <> SalesHeader."Document Type"::Order) or not Customer.Get(SalesHeader."Bill-to Customer No.") then
            exit;
        if (SalesHeader."Promised Delivery Date" = 0D) and not Customer."BA Non-Mandatory Delivery Date" then
            Error(NoPromDelDateErr, SalesHeader.FieldCaption("Promised Delivery Date"));
    end;

    local procedure CheckPromisedDeliveryDate(var ServiceHeader: Record "Service Header")
    var
        Customer: Record Customer;
    begin
        if (ServiceHeader."Document Type" <> ServiceHeader."Document Type"::Order) or not Customer.Get(ServiceHeader."Bill-to Customer No.") then
            exit;
        if (ServiceHeader."BA Promised Delivery Date" = 0D) and not Customer."BA Non-Mandatory Delivery Date" then
            Error(NoPromDelDateErr, ServiceHeader.FieldCaption("BA Promised Delivery Date"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", 'OnAfterValidateEvent', 'ENC Physical Ship Date', false, false)]
    local procedure SalesInvoiceHeaderOnAfterValdiatePhysicalShipDate(var Rec: Record "Sales Invoice Header"; var xRec: Record "Sales Invoice Header")
    var
        SalesRecSetup: Record "Sales & Receivables Setup";
    begin
        if Rec."ENC Physical Ship Date" <= Rec."ENC Promised Delivery Date" then
            exit;
        SalesRecSetup.Get();
        SalesRecSetup.TestField("BA Default Reason Code");
        if Rec."Reason Code" in ['', SalesRecSetup."BA Default Reason Code"] then
            Message(UpdateReasonCodeMsg, Rec.FieldCaption("Reason Code"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Invoice Header", 'OnAfterValidateEvent', 'ENC Physical Ship Date', false, false)]
    local procedure ServiceInvoiceHeaderOnAfterValdiatePhysicalShipDate(var Rec: Record "Service Invoice Header"; var xRec: Record "Service Invoice Header")
    var
        SalesRecSetup: Record "Sales & Receivables Setup";
    begin
        if Rec."ENC Physical Ship Date" <= Rec."BA Promised Delivery Date" then
            exit;
        SalesRecSetup.Get();
        SalesRecSetup.TestField("BA Default Reason Code");
        if Rec."Reason Code" in ['', SalesRecSetup."BA Default Reason Code"] then
            Message(UpdateReasonCodeMsg, Rec.FieldCaption("Reason Code"));
    end;


    [EventSubscriber(ObjectType::Table, Database::"Document Sending Profile", 'OnBeforeTrySendToEMail', '', false, false)]
    local procedure DocumentSendingProfileOnBeforeTrySendToEMail(var ReportUsage: Integer; RecordVariant: Variant)
    var
        SalesInvHeader: Record "Sales Invoice Header";
        ReportSelection: Record "Report Selections";
        RecRef: RecordRef;
    begin
        if ReportUsage <> ReportSelection.Usage::"S.Invoice" then
            exit;
        RecRef.GetTable(RecordVariant);
        if Format(RecRef.Field(SalesInvHeader.FieldNo("Prepayment Invoice"))) = Format(true) then
            ReportUsage := 50015;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnBeforeInsertSalesOrderLine', '', false, false)]
    local procedure SalesQuoteToOrderOnBeforeInsertSalesOrderLine(var SalesOrderLine: Record "Sales Line")
    begin
        SalesOrderLine."BA Booking Date" := WorkDate();
    end;

    procedure ImportBookingDates(Sales: Boolean)
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        ExcelBuffer2: Record "Excel Buffer" temporary;
        ErrorBuffer: Record "Name/Value Buffer" temporary;
        TempBlob: Record TempBlob;
        SalesInvLine: Record "Sales Invoice Line";
        ServiceInvLine: Record "Service Invoice Line";
        FileMgt: Codeunit "File Management";
        IStream: InStream;
        Window: Dialog;
        FileName: Text;
        RecCount: Integer;

        i: Integer;
        i2: Integer;
        LineNo: Integer;
    begin
        if FileMgt.BLOBImportWithFilter(TempBlob, 'Select Sales Pricing List', '', 'Excel|*.xlsx', 'Excel|*.xlsx') = '' then
            exit;
        TempBlob.Blob.CreateInStream(IStream);
        if not ExcelBuffer.GetSheetsNameListFromStream(IStream, ErrorBuffer) then
            Error('No Sheets in file.');
        ErrorBuffer.FindFirst();
        ExcelBuffer.OpenBookStream(IStream, ErrorBuffer.Value);
        ExcelBuffer.ReadSheet();

        ExcelBuffer.SetFilter("Row No.", '>%1', 1);
        ExcelBuffer.SetFilter("Cell Value as Text", '<>%1', '');
        if not ExcelBuffer.FindSet() then
            exit;
        repeat
            ExcelBuffer2 := ExcelBuffer;
            ExcelBuffer2.Insert(false);
        until ExcelBuffer.Next() = 0;

        ExcelBuffer.SetRange("Column No.", 1);
        RecCount := ExcelBuffer.Count();
        ExcelBuffer.FindSet();
        Window.Open('#1####/#2####');

        if Sales then
            repeat
                i += 1;
                ExcelBuffer2.Get(ExcelBuffer."Row No.", 2);
                Evaluate(LineNo, ExcelBuffer2."Cell Value as Text");
                if SalesInvLine.Get(ExcelBuffer."Cell Value as Text", LineNo) then begin
                    ExcelBuffer2.Get(ExcelBuffer."Row No.", 4);
                    SalesInvLine."BA Booking Date" := GetDate(ExcelBuffer2."Cell Value as Text");
                    SalesInvLine.Modify(false);
                    i2 += 1;
                end;
                Window.Update(2, StrSubstNo('%1 of %2', i, RecCount));
            until ExcelBuffer.Next() = 0
        else
            repeat
                i += 1;
                ExcelBuffer2.Get(ExcelBuffer."Row No.", 2);
                Evaluate(LineNo, ExcelBuffer2."Cell Value as Text");
                if ServiceInvLine.Get(ExcelBuffer."Cell Value as Text", LineNo) then begin
                    ExcelBuffer2.Get(ExcelBuffer."Row No.", 3);
                    ServiceInvLine."BA Booking Date" := GetDate(ExcelBuffer2."Cell Value as Text");
                    ServiceInvLine.Modify(false);
                    i2 += 1;
                end;
                Window.Update(2, StrSubstNo('%1 of %2', i, RecCount));
            until ExcelBuffer.Next() = 0;

        Window.Close();

        Message('Updated %1 of %2.', i2, RecCount);
    end;




    procedure ImportPricingListToRemove()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        ExcelBuffer2: Record "Excel Buffer" temporary;
        ErrorBuffer: Record "Name/Value Buffer" temporary;
        TempBlob: Record TempBlob;
        SalesPrice: Record "Sales Price";
        TempSalesPrice: Record "Sales Price" temporary;
        FileMgt: Codeunit "File Management";
        IStream: InStream;
        Window: Dialog;
        FileName: Text;
        TempDec: Decimal;
        RecCount: Integer;
        ItemNoColumnNo: Integer;
        DateColumnNo: Integer;
        CurrColumnNo: Integer;
        PriceColumnNo: Integer;
        DeleteColumnNo: Integer;
        i: Integer;
        i2: Integer;
    begin
        if FileMgt.BLOBImportWithFilter(TempBlob, 'Select Sales Pricing List', '', 'Excel|*.xlsx', 'Excel|*.xlsx') = '' then
            exit;
        TempBlob.Blob.CreateInStream(IStream);
        if not ExcelBuffer.GetSheetsNameListFromStream(IStream, ErrorBuffer) then
            Error('No Sheets in file.');
        ErrorBuffer.FindFirst();
        ExcelBuffer.OpenBookStream(IStream, ErrorBuffer.Value);
        ExcelBuffer.ReadSheet();

        ExcelBuffer.SetRange("Row No.", 1);
        DateColumnNo := GetColumnNo(ExcelBuffer, 'Starting Date');
        CurrColumnNo := GetColumnNo(ExcelBuffer, 'Currency Code');
        PriceColumnNo := GetColumnNo(ExcelBuffer, 'Unit Price');
        ItemNoColumnNo := GetColumnNo(ExcelBuffer, 'Item No_');
        DeleteColumnNo := GetColumnNo(ExcelBuffer, 'Delete', true);

        ExcelBuffer.SetFilter("Row No.", '>%1', 1);
        ExcelBuffer.SetFilter("Cell Value as Text", '<>%1', '');
        if not ExcelBuffer.FindSet() then
            exit;
        repeat
            ExcelBuffer2 := ExcelBuffer;
            ExcelBuffer2.Insert(false);
        until ExcelBuffer.Next() = 0;

        if DeleteColumnNo <> 0 then
            ExcelBuffer.SetRange("Column No.", DeleteColumnNo)
        else
            ExcelBuffer.SetRange("Column No.", ItemNoColumnNo);
        RecCount := ExcelBuffer.Count();
        ExcelBuffer.FindSet();
        Window.Open('#1####/#2####');
        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"All Customers");
        SalesPrice.SetRange("Sales Code", '');
        repeat
            i += 1;
            Window.Update(2, StrSubstNo('%1 of %2', i, RecCount));
            if DeleteColumnNo <> 0 then begin
                ExcelBuffer2.Get(ExcelBuffer."Row No.", ItemNoColumnNo);
                SalesPrice.SetRange("Item No.", ExcelBuffer2."Cell Value as Text");
            end else
                SalesPrice.SetRange("Item No.", ExcelBuffer."Cell Value as Text");
            ExcelBuffer2.Get(ExcelBuffer."Row No.", DateColumnNo);
            SalesPrice.SetRange("Starting Date", GetDate(ExcelBuffer2."Cell Value as Text"));
            if ExcelBuffer2.Get(ExcelBuffer."Row No.", CurrColumnNo) then
                SalesPrice.SetRange("Currency Code", ExcelBuffer2."Cell Value as Text")
            else
                SalesPrice.SetRange("Currency Code", '');
            ExcelBuffer2.Get(ExcelBuffer."Row No.", PriceColumnNo);
            Evaluate(TempDec, ExcelBuffer2."Cell Value as Text");
            SalesPrice.SetRange("Unit Price", TempDec);
            if SalesPrice.FindSet() then
                repeat
                    if not TempSalesPrice.Get(SalesPrice.RecordId) then begin
                        TempSalesPrice := SalesPrice;
                        TempSalesPrice.Insert(false);
                    end;
                until SalesPrice.Next() = 0;

        until ExcelBuffer.Next() = 0;
        Window.Close();


        Page.RunModal(Page::"BA Temp Sales Price", TempSalesPrice);
        if Confirm(StrSubstNo('Delete %1 of %2 sales pricing?', TempSalesPrice.Count(), RecCount)) then
            if TempSalesPrice.FindSet() then
                repeat
                    SalesPrice.Get(TempSalesPrice.RecordId);
                    SalesPrice.Delete(true);
                    i2 += 1;
                until TempSalesPrice.Next() = 0;

        Message('Deleted %1 of %2, Excel Lines (%3)', i2, TempSalesPrice.Count(), RecCount);
    end;


    local procedure GetColumnNo(var ExcelBuffer: Record "Excel Buffer"; ColumnName: Text): Integer
    begin
        exit(GetColumnNo(ExcelBuffer, ColumnName, false))
    end;

    local procedure GetColumnNo(var ExcelBuffer: Record "Excel Buffer"; ColumnName: Text; Skip: Boolean): Integer
    begin
        ExcelBuffer.SetRange("Cell Value as Text", ColumnName);
        if not ExcelBuffer.FindFirst() then begin
            if Skip then
                exit(0);
            Error('Invalid formatting, %1 column found.', ColumnName);
        end;
        exit(ExcelBuffer."Column No.");
    end;

    local procedure GetDate(Input: Text): Date
    var
        Parts: List of [Text];
        s: Text;
        i: Integer;
        i2: Integer;
        i3: Integer;
    begin
        Parts := Input.Split('/');
        Parts.Get(1, s);
        Evaluate(i, s);
        Parts.Get(2, s);
        Evaluate(i2, s);
        Parts.Get(3, s);
        Evaluate(i3, s);
        if i3 < 2000 then
            i3 += 2000;
        exit(DMY2Date(i2, i, i3));
    end;


    [EventSubscriber(ObjectType::Table, Database::"Sales Price", 'OnAfterInsertEvent', '', false, false)]
    local procedure SalesPriceOnAfterInsert(var Rec: Record "Sales Price")
    begin
        if not Rec.IsTemporary() then
            CheckIfCanEditSalesPrices();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SalesPriceOnAfterDelete(var Rec: Record "Sales Price")
    begin
        if not Rec.IsTemporary() then
            CheckIfCanEditSalesPrices();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price", 'OnAfterModifyEvent', '', false, false)]
    local procedure SalesPriceOnAfterModify(var Rec: Record "Sales Price")
    begin
        if not Rec.IsTemporary() then
            CheckIfCanEditSalesPrices();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price", 'OnAfterRenameEvent', '', false, false)]
    local procedure SalesPriceOnAfterRename(var Rec: Record "Sales Price")
    begin
        if not Rec.IsTemporary() then
            CheckIfCanEditSalesPrices();
    end;

    local procedure CheckIfCanEditSalesPrices()
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) or not UserSetup."BA Can Edit Sales Prices" then
            Error(SalesPricePermissionErr);
    end;




    procedure ImportSalesQuoteListToRemove()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        ErrorBuffer: Record "Name/Value Buffer" temporary;
        TempBlob: Record TempBlob;
        SalesHeader: Record "Sales Header";
        FileMgt: Codeunit "File Management";
        IStream: InStream;
        Window: Dialog;
        FileName: Text;
        RecCount: Integer;
        i: Integer;
        i2: Integer;
    begin
        if FileMgt.BLOBImportWithFilter(TempBlob, 'Select Sales Pricing List', '', 'Excel|*.xlsx', 'Excel|*.xlsx') = '' then
            exit;
        TempBlob.Blob.CreateInStream(IStream);
        if not ExcelBuffer.GetSheetsNameListFromStream(IStream, ErrorBuffer) then
            Error('No Sheets in file.');
        ErrorBuffer.FindFirst();
        ExcelBuffer.OpenBookStream(IStream, ErrorBuffer.Value);
        ExcelBuffer.ReadSheet();

        ExcelBuffer.SetFilter("Row No.", '>%1', 1);
        ExcelBuffer.SetFilter("Cell Value as Text", '<>%1', '');
        if not ExcelBuffer.FindSet() then
            exit;

        ExcelBuffer.SetRange("Column No.", 1);
        RecCount := ExcelBuffer.Count();
        ExcelBuffer.FindSet();
        Window.Open('#1####/#2####');

        repeat
            i += 1;
            Window.Update(2, StrSubstNo('%1 of %2', i, RecCount));
            if SalesHeader.Get(SalesHeader."Document Type"::Quote, ExcelBuffer."Cell Value as Text") then begin
                SalesHeader.SetHideValidationDialog(true);
                SalesHeader.Delete(true);
                i2 += 1;
            end;
        until ExcelBuffer.Next() = 0;
        Window.Close();

        if not Confirm(StrSubstNo('Delete %1 of %2 Sales Quotes?', i2, RecCount)) then
            Error('');
    end;





    procedure ImportPricingListToUpdate()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        ExcelBuffer2: Record "Excel Buffer" temporary;
        ErrorBuffer: Record "Name/Value Buffer" temporary;
        TempBlob: Record TempBlob;
        SalesPrice: Record "Sales Price";
        TempSalesPrice: Record "Sales Price" temporary;
        FileMgt: Codeunit "File Management";
        IStream: InStream;
        Window: Dialog;
        FileName: Text;
        TempDec: Decimal;
        RecCount: Integer;
        ItemNoColumnNo: Integer;
        DateColumnNo: Integer;
        CurrColumnNo: Integer;
        PriceColumnNo: Integer;
        DeleteColumnNo: Integer;
        i: Integer;
        i2: Integer;
    begin
        if FileMgt.BLOBImportWithFilter(TempBlob, 'Select Sales Pricing List', '', 'Excel|*.xlsx', 'Excel|*.xlsx') = '' then
            exit;
        TempBlob.Blob.CreateInStream(IStream);
        if not ExcelBuffer.GetSheetsNameListFromStream(IStream, ErrorBuffer) then
            Error('No Sheets in file.');
        ErrorBuffer.FindFirst();
        ExcelBuffer.OpenBookStream(IStream, ErrorBuffer.Value);
        ExcelBuffer.ReadSheet();

        ExcelBuffer.SetRange("Row No.", 1);


        ExcelBuffer.SetFilter("Row No.", '>%1', 1);
        ExcelBuffer.SetFilter("Cell Value as Text", '<>%1', '');
        if not ExcelBuffer.FindSet() then
            exit;
        repeat
            ExcelBuffer2 := ExcelBuffer;
            ExcelBuffer2.Insert(false);
        until ExcelBuffer.Next() = 0;

        ExcelBuffer.SetRange("Column No.", 1);
        RecCount := ExcelBuffer.Count();
        ExcelBuffer.FindSet();
        Window.Open('#1####/#2####');

        repeat
            i += 1;

            SalesPrice.SetRange("Item No.", ExcelBuffer."Cell Value as Text");
            ExcelBuffer2.Get(ExcelBuffer."Row No.", 2);
            SalesPrice.SetRange("Sales Type", GetSalesType(SalesPrice, ExcelBuffer2."Cell Value as Text"));
            if ExcelBuffer2.Get(ExcelBuffer."Row No.", 3) then
                SalesPrice.SetRange("Sales Code", ExcelBuffer2."Cell Value as Text")
            else
                SalesPrice.SetRange("Sales Code", '');
            ExcelBuffer2.Get(ExcelBuffer."Row No.", 4);
            SalesPrice.SetRange("Starting Date", GetDate(ExcelBuffer2."Cell Value as Text"));
            if ExcelBuffer2.Get(ExcelBuffer."Row No.", 5) then
                SalesPrice.SetRange("Currency Code", ExcelBuffer2."Cell Value as Text")
            else
                SalesPrice.SetRange("Currency Code", '');

            if SalesPrice.FindFirst() then begin
                TempSalesPrice := SalesPrice;
                ExcelBuffer2.Get(ExcelBuffer."Row No.", 8);
                TempSalesPrice."BA Pricelist Name" := ExcelBuffer2."Cell Value as Text";
                ExcelBuffer2.Get(ExcelBuffer."Row No.", 9);
                TempSalesPrice."BA Pricelist Year" := ExcelBuffer2."Cell Value as Text";
                TempSalesPrice.Insert();
            end;

            Window.Update(2, StrSubstNo('%1 of %2', i, RecCount));
        until ExcelBuffer.Next() = 0;
        Window.Close();


        Page.RunModal(Page::"BA Temp Sales Price", TempSalesPrice);
        if Confirm(StrSubstNo('Update %1 of %2 sales pricing?', TempSalesPrice.Count(), RecCount)) then begin
            Window.Open('Updating/#1####');
            if TempSalesPrice.FindSet() then
                repeat
                    SalesPrice.Get(TempSalesPrice.RecordId);
                    SalesPrice."BA Pricelist Name" := TempSalesPrice."BA Pricelist Name";
                    SalesPrice."BA Pricelist Year" := TempSalesPrice."BA Pricelist Year";
                    SalesPrice.Modify(true);
                    i2 += 1;
                    Window.Update(1, StrSubstNo('%1 of %2', i2, RecCount));
                until TempSalesPrice.Next() = 0;
            Window.Close();
        end;

        Message('Updated %1 of %2, Excel Lines (%3)', i2, TempSalesPrice.Count(), RecCount);
    end;

    local procedure GetSalesType(var SalesPrice: Record "Sales Price"; Input: Text): Integer
    begin
        Input := Input.Trim();
        case Input of
            '1':
                exit(SalesPrice."Sales Type"::"Customer Price Group");
            '2':
                exit(SalesPrice."Sales Type"::"All Customers");
        end;
    end;



    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure ServiceLineOnAfterValidateNo(var Rec: Record "Service Line"; var xRec: Record "Service Line")
    begin
        if (Rec."Document Type" = Rec."Document Type"::Order) and (xRec."No." = '') then
            Rec."BA Booking Date" := WorkDate();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Quote to Order", 'OnBeforeServOrderLineInsert', '', false, false)]
    local procedure ServiceQuoteToOrderOnBeforeServOrderLineInsert(var ServiceOrderLine2: Record "Service Line")
    begin
        ServiceOrderLine2."BA Booking Date" := WorkDate();
    end;


    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnBeforeRenameEvent', '', false, false)]
    local procedure CustomerOnBeforeRename(var Rec: Record Customer; var xRec: Record Customer)
    begin
        CheckCustomerNo(Rec, xRec);
    end;

    procedure CheckCustomerNo(var Rec: Record Customer; var xRec: Record Customer)
    var
        i: Integer;
    begin
        if Rec."No." = xRec."No." then
            exit;
        i := StrLen(Rec."No.");
        if (i < 6) or (i > 8) then
            Error(CustNoLengthErr, Rec.FieldCaption("No."), i);
    end;

    procedure GetShipmentTrackingInfoReportUsage(): Integer
    begin
        exit(80000);
    end;

    procedure SendShipmentTrackingInfoEmail(var SalesInvHeader: Record "Sales Invoice Header")
    begin
        SalesInvHeader.TestField("BA Ship-to Email");
        SalesInvHeader.TestField("Shipping Agent Code");
        SalesInvHeader.TestField("Package Tracking No.");
        if not TryToSendSendShipmentTrackingInfoEmail(SalesInvHeader, SalesInvHeader."No.", SalesInvHeader."Bill-to Customer No.") then
            Error(ShipmentSendErr, GetLastErrorText());
        Message(ShipmentInfoSentMsg);
    end;

    procedure SendShipmentTrackingInfoEmail(var ServiceInvHeader: Record "Service Invoice Header")
    begin
        ServiceInvHeader.TestField("Ship-to E-Mail");
        ServiceInvHeader.TestField("ENC Shipping Agent Code");
        ServiceInvHeader.TestField("ENC Package Tracking No.");
        if not TryToSendSendShipmentTrackingInfoEmail(ServiceInvHeader, ServiceInvHeader."No.", ServiceInvHeader."Customer No.") then
            Error(ShipmentSendErr, GetLastErrorText());
        Message(ShipmentInfoSentMsg);
    end;

    [TryFunction]
    local procedure TryToSendSendShipmentTrackingInfoEmail(RecVar: Variant; DocNo: Code[20]; CustNo: Code[20])
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.SendEmailToVendor(GetShipmentTrackingInfoReportUsage(), RecVar, DocNo, '', true, CustNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnFindReportSelections', '', false, false)]
    local procedure ReportSelectionsOnFindReportSelections(var FilterReportSelections: Record "Report Selections"; var IsHandled: Boolean; sender: Record "Report Selections")
    begin
        if sender.Usage <> GetShipmentTrackingInfoReportUsage() then
            exit;
        IsHandled := true;
        FilterReportSelections := sender;
        FilterReportSelections.Insert(false);
        FilterReportSelections.SetRange(Usage, GetShipmentTrackingInfoReportUsage());
        FilterReportSelections.SetFilter("Report ID", '<>%1', 0);
        FilterReportSelections.SetRange("Use for Email Body", true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnBeforeGetVendorEmailAddress', '', false, false)]
    local procedure ReportSelectionsOnBeforeGetVendorEmailAddress(var IsHandled: Boolean; ReportUsage: Option; var ToAddress: Text; RecVar: Variant; BuyFromVendorNo: Code[20])
    var
        SalesInvHeader: Record "Sales Invoice Header";
        ServiceInvHeader: Record "Service Invoice Header";
        RecRef: RecordRef;
    begin
        if ReportUsage <> GetShipmentTrackingInfoReportUsage() then
            exit;
        RecRef.GetTable(RecVar);
        if RecRef.Number() = Database::"Sales Invoice Header" then begin
            RecRef.SetTable(SalesInvHeader);
            ToAddress := SalesInvHeader."BA Ship-to Email";
        end else begin
            RecRef.SetTable(ServiceInvHeader);
            ToAddress := ServiceInvHeader."Ship-to E-Mail";
        end;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnBeforeDoSaveReportAsHTML', '', false, false)]
    local procedure ReportSelectionsOnBeforeDoSaveReportAsHTML(var FilePath: Text[250]; var RecordVariant: Variant; ReportID: Integer)
    var
        SalesInvHeader: Record "Sales Invoice Header";
        ServiceInvHeader: Record "Service Invoice Header";
        RecRef: RecordRef;
    begin
        if ReportID <> Report::"BA Shipment Tracking Info" then
            exit;
        RecRef.GetTable(RecordVariant);
        RecRef.Reset();
        if RecRef.Number() = Database::"Sales Invoice Header" then begin
            RecRef.SetTable(SalesInvHeader);
            SalesInvHeader.SetRange("No.", SalesInvHeader."No.");
            RecRef.GetTable(SalesInvHeader);
        end else begin
            RecRef.SetTable(ServiceInvHeader);
            ServiceInvHeader.SetRange("No.", ServiceInvHeader."No.");
            RecRef.GetTable(ServiceInvHeader);
        end;
        RecRef.SetTable(RecordVariant);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document-Mailing", 'OnBeforeSendEmail', '', false, false)]
    local procedure DocMailingOnBeforeSendEmail(var ReportUsage: Integer; var PostedDocNo: Code[20]; var HideDialog: Boolean; var IsFromPostedDoc: Boolean; var TempEmailItem: Record "Email Item")
    var
        SalesInvHeader: Record "Sales Invoice Header";
        ServiceInvHeader: Record "Service Invoice Header";
        CompInfo: Record "Company Information";
        OrderNo: Code[20];
        Sales: Boolean;
        SalesPerson: Record "Salesperson/Purchaser";
        UserSetup: Record "User Setup";
    begin
        if ReportUsage <> GetShipmentTrackingInfoReportUsage() then
            exit;
        if not IsDebugUser() then
            HideDialog := true;
        IsFromPostedDoc := false;
        Sales := SalesInvHeader.Get(PostedDocNo);
        if Sales then
            OrderNo := SalesInvHeader."Order No."
        else
            OrderNo := ServiceInvHeader."Order No.";
        if OrderNo = '' then
            OrderNo := PostedDocNo;
        CompInfo.Get();
        TempEmailItem.Subject := StrSubstNo(ShipmentDetailsSubject, CompInfo.Name, OrderNo);
        TempEmailItem."Message Type" := GetShipmentTrackingInfoReportUsage();
        TempEmailItem."Attachment File Path" := '';
        if (SalesInvHeader."Salesperson Code" <> '') and SalesPerson.Get(SalesInvHeader."Salesperson Code") then begin
            UserSetup.SetRange("Salespers./Purch. Code", SalesPerson.Code);
            UserSetup.SetRange("BA Email SP On Tracking Emails", true);
            if UserSetup.FindFirst() then
                TempEmailItem."Send CC" := UserSetup."E-Mail";
        end;
        if TempEmailItem."Send to" = '' then
            if Sales then
                TempEmailItem."Send to" := SalesInvHeader."BA Ship-to Email"
            else
                TempEmailItem."Send to" := ServiceInvHeader."Ship-to E-Mail";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Mail Management", 'OnBeforeRunMailDialog', '', false, false)]
    local procedure MailMgtOnBeforeRunMailDialog(var TempEmailItem: Record "Email Item"; var IsHandled: Boolean)
    begin
        if not IsDebugUser() then
            IsHandled := TempEmailItem."Message Type" = GetShipmentTrackingInfoReportUsage();
    end;




    procedure IsDebugUser(): Boolean
    begin
        exit(UserId() = 'SEI-IND\BRYANBCDEV');
    end;

    procedure UpdateBookingDate(SalesInvLine: Record "Sales Invoice Line"; NewDate: Date)
    begin
        SalesInvLine.Validate("BA Booking Date", NewDate);
        SalesInvLine.Modify(true);
    end;



    local procedure CheckToUpdateAssemblyHeaderDates(var SalesLine: Record "Sales Line")
    var
        ATOLink: Record "Assemble-to-Order Link";
        AssemblyHeader: Record "Assembly Header";
    begin
        ATOLink.SetCurrentKey(Type, "Document Type", "Document No.", "Document Line No.");
        ATOLink.SetRange(Type, ATOLink.Type::Sale);
        ATOLink.SetRange("Document Type", SalesLine."Document Type");
        ATOLink.SetRange("Document No.", SalesLine."Document No.");
        ATOLink.SetRange("Document Line No.", SalesLine."Line No.");
        if not ATOLink.FindFirst() or not AssemblyHeader.Get(ATOLink."Assembly Document Type", ATOLink."Assembly Document No.") then
            exit;
        AssemblyHeader."Due Date" := SalesLine."Shipment Date";
        AssemblyHeader."Starting Date" := SalesLine."Shipment Date";
        AssemblyHeader."Ending Date" := SalesLine."Shipment Date";
        AssemblyHeader.Modify(false);
        SalesLine.Validate("BA Skip Reservation Date Check", true);
        SalesLine.Modify(true);
        SalesLine.Get(SalesLine.RecordId());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation-Check Date Confl.", 'OnSalesLineCheckOnBeforeIssueError', '', false, false)]
    local procedure ReservationCheckDateConflOnSalesLineCheckOnBeforeIssueError(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
        if SalesLine."BA Skip Reservation Date Check" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnUpdateSalesLinesByFieldNoOnAfterCalcShouldConfirmReservationDateConflict', '', false, false)]
    local procedure SalesHeaderOnUpdateSalesLinesByFieldNoOnAfterCalcShouldConfirmReservationDateConflict(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.IsEmpty() then
            exit;
        SalesLine.SetFilter("Shipment Date", '<>%1', 0D);
        if not SalesLine.FindFirst() then
            exit;
        SalesLine2.CopyFilters(SalesLine);
        SalesLine2.SetFilter("Shipment Date", '<>%1&<>%2', 0D, SalesLine."Shipment Date");
        if not SalesLine2.IsEmpty() then
            if not Confirm(StrSubstNo(MultiShipmentDateMsg, SalesHeader."No.")) then
                Error('');
    end;



    procedure ImportFreightInvoicesToFixUpdate()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        ExcelBuffer: Record "Excel Buffer" temporary;
        ErrorBuffer: Record "Name/Value Buffer" temporary;
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
        IStream: InStream;
        Window: Dialog;
        FileName: Text;
        RecCount: Integer;
        i: Integer;
        i2: Integer;
    begin
        if FileMgt.BLOBImportWithFilter(TempBlob, 'Select Freight Invoice List', '', 'Excel|*.xlsx', 'Excel|*.xlsx') = '' then
            exit;
        TempBlob.Blob.CreateInStream(IStream);
        if not ExcelBuffer.GetSheetsNameListFromStream(IStream, ErrorBuffer) then
            Error('No Sheets in file.');
        ErrorBuffer.FindFirst();
        ExcelBuffer.OpenBookStream(IStream, ErrorBuffer.Value);
        ExcelBuffer.ReadSheet();

        ExcelBuffer.SetRange("Column No.", 1);
        ExcelBuffer.SetFilter("Row No.", '>%1', 3);
        ExcelBuffer.SetFilter("Cell Value as Text", '<>%1', '');
        if not ExcelBuffer.FindSet() then
            exit;

        RecCount := ExcelBuffer.Count();
        Window.Open('#1####/#2####');
        repeat
            i += 1;
            if SalesInvHeader.Get(ExcelBuffer."Cell Value as Text") then begin
                SalesInvHeader.Validate("Shipping Agent Code", 'FDX');
                SalesInvHeader.Modify(true);
                i2 += 1;
            end;
            Window.Update(2, StrSubstNo('%1 of %2', i, RecCount));
        until ExcelBuffer.Next() = 0;
        Window.Close();

        Message('Updated %1 of %2.', i2, RecCount);
    end;



    var
        UnblockItemMsg: Label 'You have assigned a valid Product ID, do you want to unblock the Item?';
        DefaultBlockReason: Label 'Product Dimension ID must be updated, the default Product ID cannot be used!';
        UpdateCreditLimitMsg: Label 'Do you want to update all USD customer''s credit limit?\This may take a while depending on the number of customers.';
        UpdateCreditLimitDialog: Label 'Updating Customer Credit Limits\#1###';
        ExtDocNoFormatError: Label '%1 field is improperly formatted for International Orders:\%2';
        InvalidPrefixError: Label 'Missing "SO" prefix.';
        MissingNumeralError: Label 'Missing numeral suffix.';
        NonNumeralError: Label 'Non-numeric character: %1.';
        TooLongSuffixError: Label 'Numeral suffix length is greater than 7.';
        TooShortSuffixError: Label 'Numeral suffix length is less than 7.';
        ExchageRateUpdateMsg: Label 'Updated exchange rate to %1.';
        MultiItemMsg: Label 'Item %1 occurs on multiple lines.';
        ImportWarningsMsg: Label 'Inventory calculation completed with warnings.\Please review warning messages per line, where applicable.';
        JnlLimitError: Label 'This journal adjustment is outside the limit, please request approval.';
        NoApprovalAdminError: Label 'An inventory approval admin must be set before approvals can be sent.';
        NoApprovalToCancelError: Label '%1 has not been submitted for approval.';
        AlreadyApprovedError: Label 'Cannot cancel approval request as it as been approved by one or more approvers.';
        AlreadySubmittedError: Label '%1 has already been submitted for approval.';
        CancelRequestMsg: Label 'Cancelled approval request.';
        NoAdjustReasonError: Label '%1 has not been specified for one or more lines.';
        NoApprovalNeededMsg: Label 'Inventory adjustment is within the limit, no approval needed.';
        AlreadyAwaitingApprovalError: Label '%1 is already awaiting approval.';
        RequestSentMsg: Label 'An approval request has been sent.';
        RejectedLineError: Label 'Line %1 has been rejected and must be re-submitted for approval.';
        PendingLineError: Label 'Line %1 is still awaiting approval.';
        CustGroupBlockedError: Label '%1 %2 is blocked';
        ExchangeRateText: Label '%1 - USD Exch. Rate %2 (%3)';
        WarehouseEmployeeSetupError: Label '%1 must be setup as an %2';
        InventoryAppDisabledError: Label 'Inventory Approval is not enabled.';
        MissingOrderTypeErr: Label '%1 must be specified before a value can be entered in the %2 field.';
        UpdateSalesLinesLocationMsg: Label 'The Location Code on the Sales Header has been changed, do you want to update the lines?';
        SalesLinesLocationCodeErr: Label 'There is one or more lines that do not have %1 as their location code.';
        LineFieldTypeMissingErr: Label '%1 must be specified for line %2.';
        NoSourceRecErr: Label 'Source Record not set.';
        TitleMsg: Label 'Job Queue Failed:';
        InvalidCustomerPostingGroupCurrencyErr: Label 'Must use %1 currency for Customers in %2 Customer Posting Group.';
        LocalCurrency: Label 'local (LCY)';
        DescripLengthErr: Label '%1 can only have at most 40 characters, currently %2.';
        CurrencyPostingMsg: Label 'The Currency Code of the deposit being posted does not match the Currency Code of the customer.\Continue with the posting?';
        NoFreightCarrierErr: Label 'Freight Carrier must be specified.';
        InvalidFreightCarrierErr: Label 'The value for Freight Carrier must be updated with the freight company before the tracking # can be entered.\ Please update the Freight Carrier field and try again.';
        DimPermissionErr: Label 'You do not have permission to edit dimensions.';
        UnchangedDescrErr: Label '%1 "%2" on line %3 must be changed.';
        NonServiceCustomerErr: Label '%1 can only be sold to Service Center customers.';
        UpdateItemManfDeptConf: Label 'Would you like to update the %1 listed on the Item Card?';
        PendingApprovalErr: Label 'Cannot set as Barbados Order as there is one or more pending approval requests.';
        SEIFuncAppName: Label 'BryanA - SEI Functionality by BryanA BC Developments Inc.';
        ConfigPackageMgtCU: Label '"Config. Validate Management"(CodeUnit 8617).ValidateFieldRefRelationAgainstCompanyData';
        NoPromDelDateErr: Label '%1 must be assigned before invoicing.\Please have the sales staff fill in the %1.';
        UpdateReasonCodeMsg: Label 'Please update the %1 field to a new value.';
        SalesPricePermissionErr: Label 'You do not have permission to edit Sales Prices.';
        CustNoLengthErr: Label '%1 must be between 6 to 8 characters, currently %2.';
        ShipmentInfoSentMsg: Label 'Shipment Details sent successfully.';
        ShipmentSendErr: Label 'Unable to send Shipment Details due to the following error:\\%1';
        ShipmentDetailsSubject: Label '%1 - %2 - Shipment Confirmation';
        MultiShipmentDateMsg: Label 'Sales Order %1 has multiple Shipment Dates setup.\Do you want to update all Shipment Dates to have the same date?';

}

