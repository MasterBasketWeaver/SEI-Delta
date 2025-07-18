report 50011 "BA Sales Packing Slip"
{
    DefaultLayout = RDLC;
    RDLCLayout = '.\Objects\ReportLayouts\SalesPackingSlip.rdl';
    ApplicationArea = All;
    Caption = 'Packing Slip';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING ("Document Type", "No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Sell-to Customer No.", "Bill-to Customer No.", "Ship-to Code", "No. Printed";
            RequestFilterHeading = 'Sales Order';
            column(No_SalesHeader; "No.") { }
            column(ShowDiscount; ShowDiscount) { }
            column(ShippingText; ShippingText) { }
            column(ShipmentTime; ShipmentTime) { }
            column(TotalCaption2; TotalCaption) { }
            column(DocumentType; "Document Type") { }

            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document No." = FIELD ("No.");
                DataItemTableView = SORTING ("Document Type", "Document No.", "Line No.");
                dataitem(SalesLineComments; "Sales Comment Line")
                {
                    DataItemLink = "No." = FIELD ("Document No."),
                                   "Document Line No." = FIELD ("Line No.");
                    DataItemTableView = SORTING ("Document Type", "No.", "Document Line No.", "Line No.")
                                        WHERE ("Print On Order Confirmation" = CONST (true));

                    trigger OnAfterGetRecord()
                    begin
                        InsertTempLine(Comment, 10)
                    end;
                }

                trigger OnPreDataItem()
                begin
                    TempSalesLine.RESET;
                    TempSalesLine.DELETEALL;
                    TempSalesLineAsm.RESET;
                    TempSalesLineAsm.DELETEALL;

                    SetFilter(Type, '%1|%2', "Sales Line".Type::" ", "Sales Line".Type::Item);
                end;

                trigger OnAfterGetRecord()
                begin
                    TempSalesLine := "Sales Line";
                    TempSalesLine.INSERT;
                    TempSalesLineAsm := "Sales Line";
                    TempSalesLineAsm.INSERT;

                    HighestLineNo := "Line No.";
                    IF ("Sales Header"."Tax Area Code" <> '') AND NOT UseExternalTaxEngine THEN
                        SalesTaxCalc.AddSalesLine(TempSalesLine);
                end;
            }
            dataitem("Sales Comment Line"; "Sales Comment Line")
            {
                DataItemLink = "No." = FIELD ("No.");
                DataItemTableView = SORTING ("Document Type", "No.", "Document Line No.", "Line No.")
                                    WHERE ("Print On Order Confirmation" = CONST (True),
                                          "Document Line No." = CONST (0));

                trigger OnAfterGetRecord()
                begin
                    InsertTempLine(Comment, 1000);
                end;

                trigger OnPreDataItem()
                begin
                    WITH TempSalesLine DO BEGIN
                        INIT;
                        "Document Type" := "Sales Header"."Document Type";
                        "Document No." := "Sales Header"."No.";
                        "Line No." := HighestLineNo + 1000;
                        HighestLineNo := "Line No.";
                    END;
                    TempSalesLine.INSERT;
                end;
            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = SORTING (Number);
                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = SORTING (Number)
                                        WHERE (Number = CONST (1));
                    column(CompanyInfoPicture; CompanyInformation.Picture) { }

                    column(CompanyAddress1; CompanyAddress[1])
                    {
                    }
                    column(CompanyAddress2; CompanyAddress[2])
                    {
                    }
                    column(CompanyAddress3; CompanyAddress[3])
                    {
                    }
                    column(CompanyAddress4; CompanyAddress[4])
                    {
                    }
                    column(CompanyAddress5; CompanyAddress[5])
                    {
                    }
                    column(CompanyAddress6; CompanyAddress[6])
                    {
                    }
                    column(CopyTxt; CopyTxt)
                    {
                    }
                    column(BillToAddress1; BillToAddress[1])
                    {
                    }
                    column(BillToAddress2; BillToAddress[2])
                    {
                    }
                    column(BillToAddress3; BillToAddress[3])
                    {
                    }
                    column(BillToAddress4; BillToAddress[4])
                    {
                    }
                    column(BillToAddress5; BillToAddress[5])
                    {
                    }
                    column(BillToAddress6; BillToAddress[6])
                    {
                    }
                    column(BillToAddress7; BillToAddress[7])
                    {
                    }
                    column(ShptDate_SalesHeader; "Sales Header"."Shipment Date")
                    {
                    }
                    column(ShipToAddress1; ShipToAddress[1])
                    {
                    }
                    column(ShipToAddress2; ShipToAddress[2])
                    {
                    }
                    column(ShipToAddress3; ShipToAddress[3])
                    {
                    }
                    column(ShipToAddress4; ShipToAddress[4])
                    {
                    }
                    column(ShipToAddress5; ShipToAddress[5])
                    {
                    }
                    column(ShipToAddress6; ShipToAddress[6])
                    {
                    }
                    column(ShipToAddress7; ShipToAddress[7])
                    {
                    }
                    column(BilltoCustNo_SalesHeader; "Sales Header"."Bill-to Customer No.")
                    {
                    }
                    column(ExtDocNo_SalesHeader; "Sales Header"."External Document No.")
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPersonName)
                    {
                    }
                    column(OrderDate_SalesHeader; "Sales Header"."Order Date")
                    {
                    }
                    column(CompanyAddress7; CompanyAddress[7])
                    {
                    }
                    column(CompanyAddress8; CompanyAddress[8])
                    {
                    }
                    column(BillToAddress8; BillToAddress[8])
                    {
                    }
                    column(ShipToAddress8; ShipToAddress[8])
                    {
                    }
                    column(ShipmentMethodDesc; ShipmentMethod.Description)
                    {
                    }
                    column(PaymentTermsDesc; PaymentTerms.Description)
                    {
                    }
                    column(TaxRegLabel; TaxRegLabel)
                    {
                    }
                    column(TaxRegNo; TaxRegNo)
                    {
                    }
                    column(CopyNo; CopyNo)
                    {
                    }
                    column(CustTaxIdentificationType; FORMAT(Cust."Tax Identification Type"))
                    {
                    }
                    column(SoldCaption; SoldCaptionLbl)
                    {
                    }
                    column(ToCaption; ToCaptionLbl)
                    {
                    }
                    column(ShipDateCaption; ShipDateCaptionLbl)
                    {
                    }
                    column(CustomerIDCaption; CustomerIDCaptionLbl)
                    {
                    }
                    column(PONumberCaption; PONumberCaptionLbl)
                    {
                    }
                    column(SalesPersonCaption; SalesPersonCaptionLbl)
                    {
                    }
                    column(ShipCaption; ShipCaptionLbl)
                    {
                    }
                    column(SalesOrderCaption; HeaderText)
                    {
                    }
                    column(SalesOrderNumberCaption; SalesOrderNumberCaptionLbl)
                    {
                    }
                    column(SalesOrderDateCaption; SalesOrderDateCaptionLbl)
                    {
                    }
                    column(PageCaption; PageCaptionLbl)
                    {
                    }
                    column(ShipViaCaption; ShipViaCaptionLbl)
                    {
                    }
                    column(TermsCaption; TermsCaptionLbl)
                    {
                    }
                    column(PODateCaption; PODateCaptionLbl)
                    {
                    }
                    column(TaxIdentTypeCaption; TaxIdentTypeCaptionLbl)
                    {
                    }
                    column(SalesHeader_YourReference; "Sales Header"."Your Reference") { }
                    column(SalesHeader_AssignedUserID; "Sales Header"."Assigned User ID") { }
                    column(TerritoryCode; "Sales Header"."Salesperson Code" + ' ' + delchr("Sales Header"."Assigned User ID", '=', 'SEIIND\')) { }
                    column(CurrencyCode; CurrencyCode) { }
                    column(FreightTermDescription; FreightTermDescription) { }
                    column(ShippingAgentDescription; ShippingAgentDescription) { }
                    column(ShippingMethodDescription; ShippingMethodDescription) { }
                    column(PaymentTermDescription; PaymentTermDescription) { }
                    column(FrieghtQuoteNo; "Sales Header"."ENC Freight Quote No.") { }
                    column(FrieghtAccountNo; "Sales Header"."ENC Freight Account No.") { }
                    column(RevisionNo; "Sales Header"."No. of Archived Versions") { }
                    column(BillToAddress9; BillToAddress[9]) { }
                    column(BillToAddress10; BillToAddress[10]) { }
                    column(ShipToAddress9; ShipToAddress[9]) { }
                    column(ShipToAddress10; ShipToAddress[10]) { }
                    column(CurrSymbol; CurrSymbol) { }

                    dataitem(SalesLine; Integer)
                    {
                        DataItemTableView = SORTING (Number);

                        column(AmountExclInvDisc; AmountExclInvDisc)
                        {
                        }
                        column(TempSalesLineNo; TempSalesLine."No.")
                        {
                        }
                        column(ItemNo; ItemNo) { }

                        column(TempSalesLineUOM; TempSalesLine."Unit of Measure")
                        {
                        }
                        column(TempSalesLineQuantity; TempSalesLine.Quantity)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(UnitPriceToPrint; UnitPriceToPrint)
                        {
                            DecimalPlaces = 2 : 5;
                        }
                        column(TempSalesLineDesc; Format(TempSalesLine.Description + ' ' + TempSalesLine."Description 2".Trim()))
                        {
                        }
                        column(TempSalesLineDocumentNo; TempSalesLine."Document No.")
                        {
                        }
                        column(TempSalesLineLineNo; TempSalesLine."Line No.")
                        {
                        }
                        column(AsmInfoExistsForLine; AsmInfoExistsForLine)
                        {
                        }
                        column(TaxLiable; TaxLiable)
                        {
                        }
                        column(TempSalesLineLineAmtTaxLiable; TempSalesLine."Line Amount" - TaxLiable)
                        {
                        }
                        column(TempSalesLineInvDiscAmt; TempSalesLine."Inv. Discount Amount")
                        {
                        }
                        column(TaxAmount; TaxAmount)
                        {
                        }
                        column(TempSalesLineLineAmtTaxAmtInvDiscAmt; TotalAmountWithTax)
                        {
                        }
                        column(BreakdownTitle; BreakdownTitle)
                        {
                        }
                        column(BreakdownLabel1; BreakdownLabel[1])
                        {
                        }
                        column(BreakdownLabel2; BreakdownLabel[2])
                        {
                        }
                        column(BreakdownLabel3; BreakdownLabel[3])
                        {
                        }
                        column(BreakdownAmt1; BreakdownAmt[1])
                        {
                        }
                        column(BreakdownAmt2; BreakdownAmt[2])
                        {
                        }
                        column(BreakdownAmt3; BreakdownAmt[3])
                        {
                        }
                        column(BreakdownAmt4; BreakdownAmt[4])
                        {
                        }
                        column(BreakdownLabel4; BreakdownLabel[4])
                        {
                        }
                        column(TotalTaxLabel; TotalTaxLabel)
                        {
                        }
                        column(ItemNoCaption; ItemNoCaptionLbl)
                        {
                        }
                        column(UnitCaption; UnitCaptionLbl)
                        {
                        }
                        column(DescriptionCaption; DescriptionCaptionLbl)
                        {
                        }
                        column(QuantityCaption; QuantityCaptionLbl)
                        {
                        }
                        column(UnitPriceCaption; UnitPriceCaptionLbl)
                        {
                        }
                        column(TotalPriceCaption; TotalPriceCaptionLbl)
                        {
                        }
                        column(SubtotalCaption; SubtotalCaptionLbl)
                        {
                        }
                        column(InvoiceDiscountCaption; InvoiceDiscountCaptionLbl)
                        {
                        }
                        column(TotalCaption; TotalCaptionLbl)
                        {
                        }
                        column(AmtSubjecttoSalesTaxCptn; AmtSubjecttoSalesTaxCptnLbl)
                        {
                        }
                        column(AmtExemptfromSalesTaxCptn; AmtExemptfromSalesTaxCptnLbl)
                        {
                        }
                        column(BackOrderQty; BackOrderQty) { }
                        column(TariffNo; TariffNo) { }
                        column(DiscountPercent; TempSalesLine."Line Discount %") { }
                        column(PackageTrackingText; PackageTrackingText) { }
                        column(TempSalesLineQtyToShip; TempSalesLine."Qty. to Ship")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(TempSalesLineOutstandingsQuantity; TempSalesLine."Outstanding Quantity")
                        {
                            DecimalPlaces = 0 : 5;
                        }


                        trigger OnPreDataItem()
                        begin
                            CLEAR(TaxLiable);
                            CLEAR(TaxAmount);
                            CLEAR(AmountExclInvDisc);
                            NumberOfLines := TempSalesLine.COUNT;
                            SETRANGE(Number, 1, NumberOfLines);
                            OnLineNumber := 0;
                        end;

                        trigger OnAfterGetRecord()
                        var
                            SalesLine: Record "Sales Line";
                            Item: Record Item;
                        begin
                            OnLineNumber := OnLineNumber + 1;

                            WITH TempSalesLine DO BEGIN
                                IF OnLineNumber = 1 THEN
                                    FindSet()
                                ELSE
                                    NEXT;

                                ItemNo := '';
                                clear(TariffNo);
                                IF Type = Type::" " THEN BEGIN
                                    "No." := '';
                                    "Unit of Measure" := '';
                                    "Line Amount" := 0;
                                    "Inv. Discount Amount" := 0;
                                    Quantity := 0;
                                    ItemNo := '';
                                END ELSE
                                    if Item.Get("No.") then begin
                                        if (Item."Tariff No." <> '') then begin
                                            TariffNo := Item."Tariff No.";
                                            TariffNo := INSSTR(TariffNo, '.', 9);
                                            TariffNo := INSSTR(TariffNo, '.', 7);
                                            TariffNo := INSSTR(TariffNo, '.', 5);
                                        end;
                                        if item."ENC NSN No." <> '' then
                                            ItemNo := StrSubstNo(Text1000000002, "No.", item."ENC NSN No.")
                                        else
                                            ItemNo := "No.";
                                    end;


                                IF "Tax Area Code" <> '' THEN
                                    TaxAmount := "Amount Including VAT" - Amount
                                ELSE
                                    TaxAmount := 0;

                                IF TaxAmount <> 0 THEN
                                    TaxLiable := Amount
                                ELSE
                                    TaxLiable := 0;

                                AmountExclInvDisc := "Line Amount";

                                IF Quantity = 0 THEN
                                    UnitPriceToPrint := 0 // so it won't print
                                ELSE
                                    UnitPriceToPrint := "Unit Price"; // ROUND(AmountExclInvDisc / Quantity, 0.00001);
                                IF DisplayAssemblyInformation THEN BEGIN
                                    AsmInfoExistsForLine := FALSE;
                                    IF TempSalesLineAsm.GET("Document Type", "Document No.", "Line No.") THEN BEGIN
                                        SalesLine.GET("Document Type", "Document No.", "Line No.");
                                        AsmInfoExistsForLine := SalesLine.AsmToOrderExists(AsmHeader);
                                    END;
                                END;



                                BackOrderQty := 0;
                                if "Sales Header".Invoice then
                                    BackOrderQty := TempSalesLine."Outstanding Quantity";

                                PackageTrackingText := '';
                                IF ("Package Tracking No." <> "Sales Header"."Package Tracking No.") AND
                                   ("Package Tracking No." <> '') AND PrintPackageTrackingNos
                                THEN
                                    PackageTrackingText := Text002 + ' ' + "Package Tracking No.";
                            END;
                        end;


                    }
                }

                trigger OnAfterGetRecord()
                begin
                    // CurrReport.PAGENO := 1;

                    IF CopyNo = NoLoops THEN BEGIN
                        IF NOT CurrReport.PREVIEW THEN
                            SalesPrinted.RUN("Sales Header");
                        CurrReport.BREAK;
                    END;
                    CopyNo := CopyNo + 1;
                    IF CopyNo = 1 THEN // Original
                        CLEAR(CopyTxt)
                    ELSE
                        CopyTxt := Text000;
                end;

                trigger OnPreDataItem()
                begin
                    NoLoops := 1 + ABS(NoCopies);
                    IF NoLoops <= 0 THEN
                        NoLoops := 1;
                    CopyNo := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                FormatAddress.SalesHeaderSellTo(BillToAddress, "Sales Header");
                FormatAddress.SalesHeaderShipTo(ShipToAddress, ShipToAddress, "Sales Header");
                IF RespCenter.GET("Responsibility Center") THEN BEGIN
                    FormatAddress.RespCenter(CompanyAddress, RespCenter);
                    CompanyInformation."Phone No." := RespCenter."Phone No.";
                    CompanyInformation."Fax No." := RespCenter."Fax No.";
                end else
                    if not LoadedCompAddress then begin
                        LoadedCompAddress := true;
                        SEIFunctions.FormatCompanyAddress(CompanyAddress, CompanyInformation);
                        SEIFunctions.AddFooterToAddress(BillToAddress, "Sales Header"."Sell-to Phone No.", "Sales Header"."ENC Tax Registration No.", "Sales Header"."ENC FID No.", "Sales Header"."BA EORI No.");
                        SEIFunctions.AddFooterToAddress(ShipToAddress, "Sales Header"."ENC Ship-to Phone No.", "Sales Header"."ENC Ship-To Tax Reg. No.", "Sales Header"."ENC Ship-To FID No.", "Sales Header"."BA Ship-to EORI No.");
                    end;

                CurrReport.LANGUAGE := Language.GetLanguageID("Language Code");
                FormatDocumentFields("Sales Header");

                IF NOT Cust.GET("Sell-to Customer No.") THEN
                    CLEAR(Cust);

                IF NOT CurrReport.PREVIEW THEN
                    IF ArchiveDocument THEN
                        ArchiveManagement.StoreSalesDocument("Sales Header", LogInteraction);


                // CLEAR(BreakdownTitle);
                // CLEAR(BreakdownLabel);
                // CLEAR(BreakdownAmt);
                // TotalTaxLabel := Text008;
                // TaxRegNo := '';
                // TaxRegLabel := '';
                // IF "Tax Area Code" <> '' THEN BEGIN
                //     TaxArea.GET("Tax Area Code");
                //     CASE TaxArea."Country/Region" OF
                //         TaxArea."Country/Region"::US:
                //             TotalTaxLabel := Text005;
                //         TaxArea."Country/Region"::CA:
                //             BEGIN
                //                 TotalTaxLabel := Text007;
                //                 TaxRegNo := CompanyInformation."VAT Registration No.";
                //                 TaxRegLabel := CompanyInformation.FIELDCAPTION("VAT Registration No.");
                //             END;
                //     END;
                //     UseExternalTaxEngine := TaxArea."Use External Tax Engine";
                //     SalesTaxCalc.StartSalesTaxCalculation;
                // END;

                IF "Posting Date" <> 0D THEN
                    UseDate := "Posting Date"
                ELSE
                    UseDate := WORKDATE;

                GetHeaderDetails("Sales Header");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NoCopies; NoCopies)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Number of Copies';
                        ToolTip = 'Specifies the number of copies of each document (in addition to the original) that you want to print.';
                    }
                    field(PrintPackageTrackingNos; PrintPackageTrackingNos)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Package Tracking Nos.';
                        ToolTip = 'Specifies if you want the individual package tracking numbers to be printed on each line.';
                    }
                    field(ArchiveDocument; ArchiveDocument)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Archive Document';
                        ToolTip = 'Specifies if the document is archived after you preview or print it.';
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        ToolTip = 'Specifies if you want to record the related interactions with the involved contact person in the Interaction Log Entry table.';
                    }
                    field("Display Assembly information"; DisplayAssemblyInformation)
                    {
                        ApplicationArea = Assembly;
                        Caption = 'Show Assembly Components';
                        ToolTip = 'Specifies if you want the report to include information about components that were used in linked assembly orders that supplied the item(s) being sold.';
                    }
                }
            }
        }

        trigger OnInit()
        begin
            LogInteractionEnable := TRUE;
            ArchiveDocumentEnable := TRUE;
            SalesSetup.GET;
        end;

        trigger OnOpenPage()
        begin
            // ArchiveDocument := SalesSetup."Archive Orders";
            ArchiveDocument := true;
            LogInteraction := SegManagement.FindInteractTmplCode(3) <> '';

            ArchiveDocumentEnable := ArchiveDocument;
            LogInteractionEnable := LogInteraction;
        end;
    }

    trigger OnPreReport()
    begin
        GLSetup.Get;
        CompanyInformation.GET;
        FormatDocument.SetLogoPosition(SalesSetup."Logo Position on Documents", CompanyInformation, CompanyInformation, CompanyInformation);
        FormatAddress.Company(CompanyAddress, CompanyInformation);
    end;

    var
        TaxLiable: Decimal;
        UnitPriceToPrint: Decimal;
        AmountExclInvDisc: Decimal;
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        CompanyInformation: Record "Company Information";
        SalesSetup: Record "Sales & Receivables Setup";
        TempSalesLine: Record "Sales Line" temporary;
        TempSalesLineAsm: Record "Sales Line" temporary;
        RespCenter: Record "Responsibility Center";
        Language: Record Language;
        TempSalesTaxAmtLine: Record "Sales Tax Amount Line" temporary;
        TaxArea: Record "Tax Area";
        Cust: Record Customer;
        AsmHeader: Record "Assembly Header";
        AsmLine: Record "Assembly Line";
        SalesPrinted: Codeunit "Sales-Printed";
        FormatAddress: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        SegManagement: Codeunit SegManagement;
        ArchiveManagement: Codeunit ArchiveManagement;
        SalesTaxCalc: Codeunit "Sales Tax Calculate";
        CompanyAddress: array[8] of Text[100];
        BillToAddress: array[10] of Text[100];
        ShipToAddress: array[10] of Text[100];
        CopyTxt: Text;
        SalespersonText: Text[50];
        NoCopies: Integer;
        NoLoops: Integer;
        CopyNo: Integer;
        NumberOfLines: Integer;
        OnLineNumber: Integer;
        HighestLineNo: Integer;
        TaxAmount: Decimal;
        ArchiveDocument: Boolean;
        LogInteraction: Boolean;
        Text000: Label 'COPY';
        Text002: Label 'Specific Tracking No.';
        Text003: Label 'Sales Tax Breakdown:';
        Text004: Label 'Other Taxes';
        Text005: Label 'Total Sales Tax:';
        Text006: Label 'Tax Breakdown:';
        Text007: Label 'Total Tax:';
        Text008: Label 'Tax:';
        TaxRegNo: Text;
        TaxRegLabel: Text;
        TotalTaxLabel: Text;
        BreakdownTitle: Text;
        BreakdownLabel: array[4] of Text;
        BreakdownAmt: array[4] of Decimal;
        BrkIdx: Integer;
        PrevPrintOrder: Integer;
        PrevTaxPercent: Decimal;
        UseDate: Date;
        UseExternalTaxEngine: Boolean;
        [InDataSet]
        ArchiveDocumentEnable: Boolean;
        [InDataSet]
        LogInteractionEnable: Boolean;
        DisplayAssemblyInformation: Boolean;
        AsmInfoExistsForLine: Boolean;
        SoldCaptionLbl: Label 'Sold';
        ToCaptionLbl: Label 'To:';
        ShipDateCaptionLbl: Label 'Ship Date';
        CustomerIDCaptionLbl: Label 'Customer ID';
        PONumberCaptionLbl: Label 'P.O. Number';
        SalesPersonCaptionLbl: Label 'SalesPerson';
        ShipCaptionLbl: Label 'Ship';
        SalesOrderCaptionLbl: Label 'SALES ORDER';
        SalesOrderNumberCaptionLbl: Label 'Sales Order Number:';
        SalesOrderDateCaptionLbl: Label 'Sales Order Date:';
        PageCaptionLbl: Label 'Page:';
        ShipViaCaptionLbl: Label 'Ship Via';
        TermsCaptionLbl: Label 'Terms';
        PODateCaptionLbl: Label 'P.O. Date';
        TaxIdentTypeCaptionLbl: Label 'Tax Ident. Type';
        ItemNoCaptionLbl: Label 'Item No.';
        UnitCaptionLbl: Label 'Unit';
        DescriptionCaptionLbl: Label 'Description';
        QuantityCaptionLbl: Label 'Quantity';
        UnitPriceCaptionLbl: Label 'Unit Price';
        TotalPriceCaptionLbl: Label 'Total Price';
        SubtotalCaptionLbl: Label 'Subtotal:';
        InvoiceDiscountCaptionLbl: Label 'Invoice Discount:';
        TotalCaptionLbl: Label 'Total';
        AmtSubjecttoSalesTaxCptnLbl: Label 'Amount Subject to Sales Tax';
        AmtExemptfromSalesTaxCptnLbl: Label 'Amount Exempt from Sales Tax';
        ItemNo: Text;
        LoadedCompAddress: Boolean;
        SEIFunctions: Codeunit "ENC SEI Functions";
        FreightTermDescription: Text;
        ShippingAgentDescription: Text;
        ShippingMethodDescription: Text;
        PaymentTermDescription: Text;
        BackOrderQty: Decimal;
        TariffNo: Text;
        SalesPurchPersonName: Text;
        ShowDiscount: Boolean;
        CurrencyCode: Code[10];
        GLSetup: Record "General Ledger Setup";
        HeaderText: Text;
        ShippingText: Text;
        ShipmentTime: Text;
        CurrSymbol: Text;
        PrintPackageTrackingNos: Boolean;
        PackageTrackingText: Text;

    procedure GetUnitOfMeasureDescr(UOMCode: Code[10]): Text[10]
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        IF NOT UnitOfMeasure.GET(UOMCode) THEN
            EXIT(UOMCode);
        EXIT(UnitOfMeasure.Description);
    end;

    procedure BlanksForIndent(): Text[10]
    begin
        EXIT(PADSTR('', 2, ' '));
    end;

    local procedure FormatDocumentFields(SalesHeader: Record "Sales Header")
    begin
        WITH SalesHeader DO BEGIN
            FormatDocument.SetSalesPerson(SalesPurchPerson, "Salesperson Code", SalespersonText);
            FormatDocument.SetPaymentTerms(PaymentTerms, "Payment Terms Code", "Language Code");
            FormatDocument.SetShipmentMethod(ShipmentMethod, "Shipment Method Code", "Language Code");
        END;
    end;

    local procedure InsertTempLine(Comment: Text[80]; IncrNo: Integer)
    begin
        WITH TempSalesLine DO BEGIN
            INIT;
            "Document Type" := "Sales Header"."Document Type";
            "Document No." := "Sales Header"."No.";
            "Line No." := HighestLineNo + IncrNo;
            HighestLineNo := "Line No.";
        END;
        FormatDocument.ParseComment(Comment, TempSalesLine.Description, TempSalesLine."Description 2");
        TempSalesLine.INSERT;
    end;



    local procedure GetHeaderDetails(var SalesHeader: Record "Sales Header")
    var
        FreightTerm: Record "ENC Freight Term";
        ShippingMethod: Record "Shipment Method";
        ShippingAgent: Record "Shipping Agent";
        PaymentTerms: Record "Payment Terms";
        DiscountLine: Record "Sales Line";
        LeadTime: Record "ENC Lead Time";
        SEIFunctions: Codeunit "ENC SEI Functions";
        Currency: Record Currency;
        TaxAmounts: Record "Name/Value Buffer" temporary;
        Totals: array[2] of Decimal;
        i: Integer;
    begin
        with SalesHeader do begin
            Clear(FreightTermDescription);
            Clear(ShippingAgentDescription);
            Clear(ShippingMethodDescription);
            Clear(PaymentTermDescription);
            Clear(SalesPurchPersonName);
            clear(CurrencyCode);

            Clear(HeaderText);
            ShippingText := Text1000000005;
            ShipmentTime := Format("Shipment Date");
            case "Document Type" of
                "Document Type"::"Return Order":
                    HeaderText := Text1000000000;
                "Document Type"::Order:
                    HeaderText := Text1000000001;
                "Document Type"::Quote:
                    begin
                        HeaderText := Text1000000004;
                        ShippingText := Text1000000006;
                        if ("ENC Lead Time" <> '') and LeadTime.Get("ENC Lead Time") then
                            ShipmentTime := LeadTime.Description;
                    end;
            end;
            "Sales Header"."Order Date" := "Sales Header"."Document Date";


            if "ENC Freight Term" <> '' then begin
                FreightTerm.Get("ENC Freight Term");
                FreightTermDescription := FreightTerm.Description;
            end;
            if "Shipping Agent Code" <> '' then begin
                ShippingAgent.Get("Shipping Agent Code");
                ShippingAgentDescription := ShippingAgent.Name;
            end;
            if "Shipment Method Code" <> '' then begin
                ShippingMethod.Get("Shipment Method Code");
                ShippingMethodDescription := ShippingMethod.Description;
            end;
            if "Payment Terms Code" <> '' then begin
                PaymentTerms.Get("Payment Terms Code");
                PaymentTermDescription := PaymentTerms.Description;
            end;
            if "Currency Code" <> '' then
                CurrencyCode := "Currency Code"
            else
                CurrencyCode := GLSetup."LCY Code";
            if CurrencyCode <> '' then
                TotalCaption := StrSubstNo(Text1000000007, CurrencyCode)
            else
                TotalCaption := Text1000000007;
            if Currency.Get(CurrencyCode) and (Currency.Symbol <> '') then
                CurrSymbol := Currency.Symbol
            else
                CurrSymbol := '';

            if "Salesperson Code" <> '' then begin
                if copystr("Assigned User ID", 1, strlen('SEIIND\')) <> '' then
                    "Assigned User ID" := copystr("Assigned User ID", 9, StrLen("Assigned User ID"));
                SalesPurchPersonName := StrSubstNo(Text1000000003, "Salesperson Code", "Assigned User ID");
            end;
            // DiscountLine.SetRange("Document Type", "Document Type");
            // DiscountLine.SetRange("Document No.", "No.");
            // DiscountLine.SetFilter("Line Discount Amount", '<>%1', 0);
            // ShowDiscount := Not DiscountLine.IsEmpty;
        end;

        // SEIFunctions.GetSalesOrderTotal(SalesHeader, Totals, TaxAmounts, false);
        // TotalAmount := Totals[1];
        // TotalAmountWithTax := Totals[2];
    end;

    var
        Text1000000000: Label 'RMA';
        Text1000000001: Label 'Sales Order';
        Text1000000002: Label '%1/%2';
        Text1000000003: Label '%1/%2';
        Text1000000004: Label 'Sales Quote';
        Text1000000005: Label 'Ship Date';
        Text1000000006: Label 'Est. Lead Time';
        Text1000000007: Label 'Total (%1)';
        TotalAmount: Decimal;
        TotalAmountWithTax: Decimal;
        TotalCaption: Text;
}

