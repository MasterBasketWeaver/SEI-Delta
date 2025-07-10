report 50012 "BA Service Packing Slip"
{
    DefaultLayout = RDLC;
    Caption = 'Service Order';
    RDLCLayout = '.\Objects\ReportLayouts\ServicePackngSlip.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Service Header"; "Service Header")
        {
            DataItemTableView = SORTING ("Document Type", "No.");
            RequestFilterFields = "No.", "Customer No.";
            column(Service_Header_Document_Type; "Document Type") { }
            column(No_ServHeader; "No.") { }
            column(DocType; DocType) { }
            column(NoServiceLines; NoServiceLines) { }
            column(DocumentType; "Document Type") { }

            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = SORTING (Number);
                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = SORTING (Number)
                                        WHERE (Number = CONST (1));
                    column(CompanyInfo_Picture; CompanyInfo.Picture)
                    {
                    }
                    column(CompanyInfo1_Picture; CompanyInfo.Picture)
                    {
                    }
                    column(CompanyInfo2_Picture; CompanyInfo.Picture)
                    {
                    }
                    column(Service_Header___Contract_No__; "Service Header"."Contract No.")
                    {
                    }
                    column(Service_Header___Order_Time_; "Service Header"."Order Time")
                    {
                    }
                    column(CustAddr_6_; CustAddr[6])
                    {
                    }
                    column(CustAddr_5_; CustAddr[5])
                    {
                    }
                    column(CustAddr_4_; CustAddr[4])
                    {
                    }
                    column(Service_Header___Order_Date_; FORMAT("Service Header"."Order Date"))
                    {
                    }
                    column(CustAddr_3_; CustAddr[3])
                    {
                    }
                    column(Service_Header__Status; "Service Header".Status)
                    {
                    }
                    column(CustAddr_2_; CustAddr[2])
                    {
                    }
                    column(Service_Header___No__; "Service Header"."No.")
                    {
                    }
                    column(CustAddr_1_; CustAddr[1])
                    {
                    }
                    column(CompanyAddr_6_; CompanyAddr[6])
                    {
                    }
                    column(CompanyAddr_5_; CompanyAddr[5])
                    {
                    }
                    column(Service_Header___Bill_to_Name_; "Service Header"."Bill-to Name")
                    {
                    }
                    column(CompanyAddr_4_; CompanyAddr[4])
                    {
                    }
                    column(CompanyAddr_3_; CompanyAddr[3])
                    {
                    }
                    column(CompanyAddr_2_; CompanyAddr[2])
                    {
                    }
                    column(CompanyAddr_1_; CompanyAddr[1])
                    {
                    }
                    column(STRSUBSTNO_Text001_CopyText_; STRSUBSTNO(Text001, CopyText))
                    {
                    }
                    column(STRSUBSTNO_Text002_FORMAT_CurrReport_PAGENO__; STRSUBSTNO(Text002, FORMAT(1)))
                    {
                    }
                    column(CompanyInfo__Phone_No__; CompanyInfo."Phone No.")
                    {
                    }
                    column(CompanyInfo__Fax_No__; CompanyInfo."Fax No.")
                    {
                    }
                    column(Service_Header___Phone_No__; "Service Header"."Phone No.")
                    {
                    }
                    column(Service_Header___E_Mail_; "Service Header"."E-Mail")
                    {
                    }
                    column(Service_Header__Description; "Service Header".Description)
                    {
                    }
                    column(PageCaption; STRSUBSTNO(Text002, ' '))
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(PageLoop_Number; Number)
                    {
                    }
                    column(Contract_No_Caption; Contract_No_CaptionLbl)
                    {
                    }
                    column(Service_Header___Order_Time_Caption; "Service Header".FIELDCAPTION("Order Time"))
                    {
                    }
                    column(Service_Header___Order_Date_Caption; DocType + ' Date')
                    {
                    }
                    column(Service_Header__StatusCaption; "Service Header".FIELDCAPTION(Status))
                    {
                    }
                    column(Service_Header___No__Caption; "Service Header".FIELDCAPTION("No."))
                    {
                    }
                    column(Invoice_toCaption; Invoice_toCaptionLbl)
                    {
                    }
                    column(CompanyInfo__Phone_No__Caption; CompanyInfo__Phone_No__CaptionLbl)
                    {
                    }
                    column(CompanyInfo__Fax_No__Caption; CompanyInfo__Fax_No__CaptionLbl)
                    {
                    }
                    column(Service_Header___Phone_No__Caption; Service_Header___Phone_No__CaptionLbl)
                    {
                    }
                    column(Service_Header___E_Mail_Caption; Service_Header___E_Mail_CaptionLbl)
                    {
                    }
                    column(Service_Header__DescriptionCaption; "Service Header".FIELDCAPTION(Description))
                    {
                    }
                    column(CompanyAddr7; CompanyAddr[7]) { }
                    column(CompanyAddr8; CompanyAddr[8]) { }
                    column(ShipToAddr1; ShipToAddr[1]) { }
                    column(ShipToAddr2; ShipToAddr[2]) { }
                    column(ShipToAddr3; ShipToAddr[3]) { }
                    column(ShipToAddr4; ShipToAddr[4]) { }
                    column(ShipToAddr5; ShipToAddr[5]) { }
                    column(ShipToAddr6; ShipToAddr[6]) { }
                    column(ShipToAddr7; ShipToAddr[7]) { }
                    column(ShipToAddr8; ShipToAddr[8]) { }
                    column(ShipToAddr9; ShipToAddr[9]) { }
                    column(ShipToAddr10; ShipToAddr[10]) { }
                    column(CustAddr7; CustAddr[7]) { }
                    column(CustAddr8; CustAddr[8]) { }
                    column(CustAddr9; CustAddr[9]) { }
                    column(CustAddr10; CustAddr[10]) { }
                    column(ServiceQuoteNo; "Service Header"."ENC Service Quote No.") { }
                    column(ExtDocNo; "Service Header"."ENC External Document No.") { }
                    column(DueDate; "Service Header"."Due Date") { }
                    column(SalesPerson; SalesPersonName) { }
                    column(CustomerNo; "Service Header"."Customer No.") { }
                    column(PaymentTerms; PaymentTermDescription) { }
                    column(HeaderNo; "Service Header"."No.") { }
                    column(FreightQuoteNo; "Service Header"."ENC Freight Quote No.") { }
                    column(FreightAccountNo; "Service Header"."ENC Freight Account No.") { }
                    column(ShipmentMethod; ShipmentMethodDescription) { }
                    column(ShippingAgent; ShippingAgentDescription) { }
                    column(FreightTerms; FreightTermDescription) { }
                    column(GSTNo; CompanyInfo."VAT Registration No.") { }
                    column(PSTNo; CompanyInfo."QST Registration No.") { }
                    column(CurrencyCode; CurrencyCode) { }
                    column(CurrSymbol; CurrSymbol) { }

                    dataitem(DimensionLoop1; Integer)
                    {
                        DataItemTableView = SORTING (Number)
                                            WHERE (Number = FILTER (1 ..));
                        column(DimText; DimText)
                        {
                        }
                        column(DimText_Control11; DimText)
                        {
                        }
                        column(DimensionLoop1_Number; Number)
                        {
                        }
                        column(Header_DimensionsCaption; Header_DimensionsCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            IF Number = 1 THEN BEGIN
                                IF NOT DimSetEntry1.FIND('-') THEN
                                    CurrReport.BREAK;
                            END ELSE
                                IF NOT Continue THEN
                                    CurrReport.BREAK;

                            CLEAR(DimText);
                            Continue := FALSE;
                            REPEAT
                                OldDimText := DimText;
                                IF DimText = '' THEN
                                    DimText := STRSUBSTNO(
                                        '%1 %2', DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code")
                                ELSE
                                    DimText :=
                                      STRSUBSTNO(
                                        '%1, %2 %3', DimText,
                                        DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code");
                                IF STRLEN(DimText) > MAXSTRLEN(OldDimText) THEN BEGIN
                                    DimText := OldDimText;
                                    Continue := TRUE;
                                    EXIT;
                                END;
                            UNTIL DimSetEntry1.NEXT = 0;
                        end;

                        trigger OnPreDataItem()
                        begin
                            IF NOT ShowInternalInfo THEN
                                CurrReport.BREAK;
                        end;
                    }
                    dataitem("Service Order Comment"; "Service Comment Line")
                    {
                        DataItemLink = "Table Subtype" = FIELD ("Document Type"),
                                       "No." = FIELD ("No.");
                        DataItemLinkReference = "Service Header";
                        DataItemTableView = SORTING ("Table Name", "Table Subtype", "No.", Type, "Table Line No.", "Line No.")
                                            WHERE ("Table Name" = CONST ("Service Header"),
                                                  Type = CONST (General));
                        column(Service_Order_Comment_Comment; Comment)
                        {
                        }
                        column(ServiceOrderComment_TabName; "Table Name")
                        {
                        }
                        column(Service_Order_Comment_Table_Subtype; "Table Subtype")
                        {
                        }
                        column(Service_Order_Comment_No_; "No.")
                        {
                        }
                        column(Service_Order_Comment_Type; Type)
                        {
                        }
                        column(Service_Order_Comment_Table_Line_No_; "Table Line No.")
                        {
                        }
                        column(Service_Order_Comment_Line_No_; "Line No.")
                        {
                        }
                        column(ShowOrderComment; ShowOrderComment) { }

                        trigger OnPreDataItem()
                        begin
                            ShowOrderComment := not IsEmpty;
                        end;
                    }
                    dataitem("Service Item Line"; "Service Item Line")
                    {
                        DataItemLink = "Document Type" = FIELD ("Document Type"),
                                       "Document No." = FIELD ("No.");
                        DataItemLinkReference = "Service Header";
                        DataItemTableView = SORTING ("Document Type", "Document No.", "Line No.");
                        column(ServiceItemLine_LineNo; "Service Item Line"."Line No.")
                        {
                        }
                        column(SerialNo_ServItemLine; "Serial No.")
                        {
                        }
                        column(ServiceItemLine_Description; Description)
                        {
                        }
                        column(Service_Item_Line__Service_Item_No__; "Service Item No.")
                        {
                        }
                        column(ServItemGroupCode_ServItemLine; "Service Item Group Code")
                        {
                        }
                        column(Service_Item_Line_Warranty; FORMAT(Warranty))
                        {
                        }
                        column(Service_Item_Line__Loaner_No__; "Loaner No.")
                        {
                        }
                        column(Service_Item_Line__Repair_Status_Code_; "Repair Status Code")
                        {
                        }
                        column(Service_Item_Line__Service_Shelf_No__; "Service Shelf No.")
                        {
                        }
                        column(Service_Item_Line__Response_Time_; FORMAT("Response Time"))
                        {
                        }
                        column(Service_Item_Line__Response_Date_; FORMAT("Response Date"))
                        {
                        }
                        column(Service_Item_Line_Document_Type; "Document Type")
                        {
                        }
                        column(Service_Item_Line_Document_No_; "Document No.")
                        {
                        }
                        column(Service_Item_Line__Serial_No__Caption; FIELDCAPTION("Serial No."))
                        {
                        }
                        column(Service_Item_Line_DescriptionCaption; FIELDCAPTION(Description))
                        {
                        }
                        column(Service_Item_Line__Service_Item_No__Caption; FIELDCAPTION("Service Item No."))
                        {
                        }
                        column(Service_Item_Line__Service_Item_Group_Code_Caption; FIELDCAPTION("Service Item Group Code"))
                        {
                        }
                        column(Service_Item_Line_WarrantyCaption; CAPTIONCLASSTRANSLATE(FIELDCAPTION(Warranty)))
                        {
                        }
                        column(Service_Item_LinesCaption; Service_Item_LinesCaptionLbl)
                        {
                        }
                        column(Service_Item_Line__Loaner_No__Caption; FIELDCAPTION("Loaner No."))
                        {
                        }
                        column(Service_Item_Line__Repair_Status_Code_Caption; FIELDCAPTION("Repair Status Code"))
                        {
                        }
                        column(Service_Item_Line__Service_Shelf_No__Caption; FIELDCAPTION("Service Shelf No."))
                        {
                        }
                        column(Service_Item_Line__Response_Date_Caption; Service_Item_Line__Response_Date_CaptionLbl)
                        {
                        }
                        column(Service_Item_Line__Response_Time_Caption; Service_Item_Line__Response_Time_CaptionLbl)
                        {
                        }
                        column(ServiceItemLine_Description2; "Service Item Line"."Description 2") { }
                        column(ServiceItemLine_ItemNo; "Service Item Line"."Item No.") { }
                        column(ServiceItemLine_UoM; ServiceItemLine_UoM) { }
                        column(TariffNo; TariffNo) { }

                        dataitem("Fault Comment"; "Service Comment Line")
                        {
                            DataItemLink = "Table Subtype" = FIELD ("Document Type"),
                                           "No." = FIELD ("Document No."),
                                           "Table Line No." = FIELD ("Line No.");
                            DataItemTableView = SORTING ("Table Name", "Table Subtype", "No.", Type, "Table Line No.", "Line No.")
                                                WHERE ("Table Name" = CONST ("Service Header"),
                                                      Type = CONST (Fault));
                            column(Comment_FaultComment; Comment)
                            {
                            }
                            column(Fault_Comment_Table_Name; "Table Name")
                            {
                            }
                            column(Fault_Comment_Table_Subtype; "Table Subtype")
                            {
                            }
                            column(Fault_Comment_No_; "No.")
                            {
                            }
                            column(Fault_Comment_Type; Type)
                            {
                            }
                            column(Fault_Comment_Table_Line_No_; "Table Line No.")
                            {
                            }
                            column(Fault_Comment_Line_No_; "Line No.")
                            {
                            }
                            column(Fault_CommentsCaption; Fault_CommentsCaptionLbl)
                            {
                            }
                        }

                        dataitem("Resolution Comment"; "Service Comment Line")
                        {
                            DataItemLink = "Table Subtype" = FIELD ("Document Type"),
                                           "No." = FIELD ("Document No."),
                                           "Table Line No." = FIELD ("Line No.");
                            DataItemTableView = SORTING ("Table Name", "Table Subtype", "No.", Type, "Table Line No.", "Line No.")
                                                WHERE ("Table Name" = CONST ("Service Header"),
                                                      Type = CONST (Resolution));
                            column(Comment_ResolutionComment; Comment)
                            {
                            }
                            column(Resolution_Comment_Table_Name; "Table Name")
                            {
                            }
                            column(Resolution_Comment_Table_Subtype; "Table Subtype")
                            {
                            }
                            column(Resolution_Comment_No_; "No.")
                            {
                            }
                            column(Resolution_Comment_Type; Type)
                            {
                            }
                            column(Resolution_Comment_Table_Line_No_; "Table Line No.")
                            {
                            }
                            column(Resolution_Comment_Line_No_; "Line No.")
                            {
                            }
                            column(Resolution_CommentsCaption; Resolution_CommentsCaptionLbl)
                            {
                            }
                        }

                        trigger OnAfterGetRecord()
                        var
                            Item: Record Item;
                        begin
                            if Item.Get("Service Item Line"."Item No.") then begin
                                ServiceItemLine_UoM := Item."Base Unit of Measure";
                                if (Item."Tariff No." <> '') then begin
                                    TariffNo := Item."Tariff No.";
                                    TariffNo := INSSTR(TariffNo, '.', 9);
                                    TariffNo := INSSTR(TariffNo, '.', 7);
                                    TariffNo := INSSTR(TariffNo, '.', 5);
                                end;
                            end else begin
                                ServiceItemLine_UoM := '';
                                TariffNo := '';
                            end;
                        end;
                    }
                    dataitem("Service Line"; "Service Line")
                    {
                        DataItemLink = "Document Type" = FIELD ("Document Type"),
                                       "Document No." = FIELD ("No.");
                        DataItemLinkReference = "Service Header";
                        DataItemTableView = SORTING ("Document Type", "Document No.", "Line No.");
                        column(Service_Line___Line_No__; "Service Line"."Line No.")
                        {
                        }
                        column(Service_Line__Service_Item_Serial_No__; "Service Item Serial No.")
                        {
                        }
                        column(Type_ServLine; Type)
                        {
                        }
                        column(Service_Line__No__; "No.")
                        {
                        }
                        column(Service_Line__Variant_Code_; "Variant Code")
                        {
                        }
                        column(Service_Line_Description; Description)
                        {
                        }
                        column(Qty; Qty)
                        {
                        }
                        column(UnitPrice_ServLine; "Unit Price")
                        {
                        }
                        column(Service_Line__Line_Discount___; "Line Discount %")
                        {
                        }
                        column(Amt; Amt)
                        {
                        }
                        column(GrossAmt; GrossAmt)
                        {
                        }
                        column(Service_Line__Quantity_Consumed_; "Quantity Consumed")
                        {
                        }
                        column(Service_Line__Qty__to_Consume_; "Qty. to Consume")
                        {
                        }
                        column(Amt_Control63; Amt)
                        {
                        }
                        column(GrossAmt_Control65; GrossAmt)
                        {
                        }
                        column(Service_Line_Document_Type; "Document Type")
                        {
                        }
                        column(DocumentNo_ServLine; "Document No.")
                        {
                        }
                        column(Service_Line__Service_Item_Serial_No__Caption; FIELDCAPTION("Service Item Serial No."))
                        {
                        }
                        column(Service_Line__No__Caption; FIELDCAPTION("No."))
                        {
                        }
                        column(Service_Line_TypeCaption; FIELDCAPTION(Type))
                        {
                        }
                        column(Service_Line__Variant_Code_Caption; FIELDCAPTION("Variant Code"))
                        {
                        }
                        column(Service_Line_DescriptionCaption; FIELDCAPTION(Description))
                        {
                        }
                        column(QtyCaption; QtyCaptionLbl)
                        {
                        }
                        column(Service_LinesCaption; Service_LinesCaptionLbl)
                        {
                        }
                        column(Service_Line__Unit_Price_Caption; FIELDCAPTION("Unit Price"))
                        {
                        }
                        column(Service_Line__Line_Discount___Caption; FIELDCAPTION("Line Discount %"))
                        {
                        }
                        column(AmountCaption; AmountCaptionLbl)
                        {
                        }
                        column(Gross_AmountCaption; Gross_AmountCaptionLbl)
                        {
                        }
                        column(Service_Line__Quantity_Consumed_Caption; FIELDCAPTION("Quantity Consumed"))
                        {
                        }
                        column(Service_Line__Qty__to_Consume_Caption; FIELDCAPTION("Qty. to Consume"))
                        {
                        }
                        column(TotalCaption; TotalCaptionLbl)
                        {
                        }

                        column(HideDiscount; HideDiscount) { }
                        column(SL_UoM; "Unit of Measure Code") { }
                        column(ServiceLine_QtyToShip; "Service Line"."Qty. to Ship") { }
                        column(ServiceLine_OutstandingQty; "Service Line"."Outstanding Quantity") { }
                        column(ServiceLine_UOM; "Service Line"."Unit of Measure Code") { }




                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = SORTING (Number)
                                                WHERE (Number = FILTER (1 ..));
                            column(DimText_Control13; DimText)
                            {
                            }
                            column(DimensionLoop2_Number; Number)
                            {
                            }
                            column(Line_DimensionsCaption; Line_DimensionsCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                IF Number = 1 THEN BEGIN
                                    IF NOT DimSetEntry2.FIND('-') THEN
                                        CurrReport.BREAK;
                                END ELSE
                                    IF NOT Continue THEN
                                        CurrReport.BREAK;

                                CLEAR(DimText);
                                Continue := FALSE;
                                REPEAT
                                    OldDimText := DimText;
                                    IF DimText = '' THEN
                                        DimText := STRSUBSTNO(
                                            '%1 %2', DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code")
                                    ELSE
                                        DimText :=
                                          STRSUBSTNO(
                                            '%1, %2 %3', DimText,
                                            DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code");
                                    IF STRLEN(DimText) > MAXSTRLEN(OldDimText) THEN BEGIN
                                        DimText := OldDimText;
                                        Continue := TRUE;
                                        EXIT;
                                    END;
                                UNTIL DimSetEntry2.NEXT = 0;
                            end;

                            trigger OnPreDataItem()
                            begin
                                IF NOT ShowInternalInfo THEN
                                    CurrReport.BREAK;

                                DimSetEntry2.SETRANGE("Dimension Set ID", "Service Line"."Dimension Set ID");
                            end;
                        }

                        trigger OnPreDataItem()
                        begin
                            HideDiscount := True;
                            "Service Line".SetFilter(Type, '%1|%2', "Service Line".Type::" ", "Service Line".Type::Item);
                            NoServiceLines := "Service Line".IsEmpty();
                        end;

                        trigger OnAfterGetRecord()
                        var
                            Item: Record Item;
                            ExchangeFactor: Decimal;
                            SalesTaxCalculate: Codeunit "Sales Tax Calculate";
                            TempSalesTaxAmountLine: Record "Sales Tax Amount Line" temporary;
                            TaxJurisdiction: Record "Tax Jurisdiction";
                            BrkIdx: Integer;
                            PrevPrintOrder: Integer;
                            PrevTaxPercent: Decimal;
                        begin
                            ShowOrderComment := False;

                            Qty := Quantity;
                            Amt := "Line Amount";
                            IF "Service Header"."Currency Factor" = 0 THEN
                                ExchangeFactor := 1
                            ELSE
                                ExchangeFactor := "Service Header"."Currency Factor";
                            SalesTaxCalculate.StartSalesTaxCalculation;
                            SalesTaxCalculate.AddServiceLine("Service Line");
                            SalesTaxCalculate.EndSalesTaxCalculation("Posting Date");
                            SalesTaxCalculate.GetSalesTaxAmountLineTable(TempSalesTaxAmountLine);
                            OnAfterCalculateSalesTax("Service Header", "Service Line", TempSalesTaxAmountLine);
                            GrossAmt := Amt + TempSalesTaxAmountLine.GetTotalTaxAmountFCY;
                            // with TempSalesTaxAmountLine do
                            //     if FindSet then
                            //         repeat
                            //             if ("Print Order" = 0) or ("Print Order" <> PrevPrintOrder) or ("Tax %" <> PrevTaxPercent) then begin
                            //                 BrkIdx += 1;
                            //                 if BrkIdx > ArrayLen(TaxLabels) then begin
                            //                     BrkIdx -= 1;
                            //                     TaxLabels[BrkIdx] := 'Additional Taxes:';
                            //                 end else begin
                            //                     if TaxJurisdiction.Get("Tax Jurisdiction Code") then
                            //                         "Print Description" := TaxJurisdiction."Print Description";
                            //                     if "Print Description" <> '' then
                            //                         TaxLabels[BrkIdx] := "Print Description"
                            //                     else
                            //                         if Description <> '' then
                            //                             TaxLabels[BrkIdx] := Description
                            //                         else
                            //                             TaxLabels[BrkIdx] := "Tax Jurisdiction Code";
                            //                 end;
                            //             end;
                            //             TaxAmounts[BrkIdx] := TaxAmounts[BrkIdx] + "Tax Amount";
                            //         until Next = 0;


                            TotalAmt += Amt;
                            TotalGrossAmt += GrossAmt;

                            if "Line Discount Amount" <> 0 then
                                HideDiscount := False;



                        end;
                    }
                    dataitem(Totals; Integer)
                    {
                        DataItemTableView = sorting (Number) where (number = const (1));
                        column(TotalAmt; TotalAmt) { }
                        column(TotalGrossAmt; TotalGrossAmt) { }
                        column(TaxLabel1; TaxLabels[1]) { }
                        column(TaxLabel2; TaxLabels[2]) { }
                        column(TaxLabel3; TaxLabels[3]) { }
                        column(TaxLabel4; TaxLabels[4]) { }
                        column(TaxAmount1; TaxAmounts[1]) { }
                        column(TaxAmount2; TaxAmounts[2]) { }
                        column(TaxAmount3; TaxAmounts[3]) { }
                        column(TaxAmount4; TaxAmounts[4]) { }
                    }
                    dataitem(Shipto; Integer)
                    {
                        DataItemTableView = SORTING (Number)
                                            WHERE (Number = CONST (1));
                        column(ShipToAddr_6_; ShipToAddr[6])
                        {
                        }
                        column(ShipToAddr_5_; ShipToAddr[5])
                        {
                        }
                        column(ShipToAddr_4_; ShipToAddr[4])
                        {
                        }
                        column(ShipToAddr_3_; ShipToAddr[3])
                        {
                        }
                        column(ShipToAddr_2_; ShipToAddr[2])
                        {
                        }
                        column(ShipToAddr_1_; ShipToAddr[1])
                        {
                        }
                        column(Shipto_Number; Number)
                        {
                        }
                        column(Ship_to_AddressCaption; Ship_to_AddressCaptionLbl)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            IF NOT ShowShippingAddr THEN
                                CurrReport.BREAK;
                        end;
                    }
                }
                // dataitem(Totals; Integer)
                // {
                //     DataItemTableView = sorting (Number) where (number = const (1));

                //     column(TotalAmt; TotalAmt) { }
                //     column(TotalGrossAmt; TotalGrossAmt) { }
                // }

                trigger OnPreDataItem()
                begin
                    NoOfLoops := ABS(NoOfCopies) + 1;
                    IF NoOfLoops <= 0 THEN
                        NoOfLoops := 1;
                    CopyText := '';
                    SETRANGE(Number, 1, NoOfLoops);
                    OutputNo := 1;
                end;

                trigger OnAfterGetRecord()
                begin
                    IF Number > 1 THEN BEGIN
                        CopyText := FormatDocument.GetCOPYText;
                        OutputNo += 1;
                    END;
                end;


            }


            //Header
            trigger OnPreDataItem()
            begin
                TotalAmt := 0;
                TotalGrossAmt := 0;
            end;

            trigger OnAfterGetRecord()
            begin
                CurrReport.LANGUAGE := Language.GetLanguageID("Language Code");
                FormatAddressFields("Service Header");
                DimSetEntry1.SETRANGE("Dimension Set ID", "Dimension Set ID");
                Clear(TaxLabels);
                Clear(TaxAmounts);
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
                    field(NoOfCopies; NoOfCopies)
                    {
                        ApplicationArea = Service;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies how many copies of the document to print.';
                    }
                    field(ShowInternalInfo; ShowInternalInfo)
                    {
                        ApplicationArea = Service;
                        Caption = 'Show Internal Information';
                        ToolTip = 'Specifies if you want the printed report to show information that is only for internal use.';
                    }
                    field(ShowQty; ShowQty)
                    {
                        ApplicationArea = Service;
                        Caption = 'Amounts Based on';
                        OptionCaption = 'Quantity,Quantity Invoiced';
                        ToolTip = 'Specifies the amounts that the service order is based on.';
                    }
                }
            }
        }
    }


    trigger OnInitReport()
    begin
        ServiceSetup.GET;
        CompanyInfo.GET;
        CompanyInfo.CALCFIELDS(Picture);
    end;

    var
        Text001: Label 'Service Order %1';
        Text002: Label 'Page %1';
        CompanyInfo: Record "Company Information";
        ServiceSetup: Record "Service Mgt. Setup";
        RespCenter: Record "Responsibility Center";
        Language: Record Language;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        FormatAddr: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        OutputNo: Integer;
        ShowInternalInfo: Boolean;
        Continue: Boolean;
        ShowShippingAddr: Boolean;
        CustAddr: array[10] of Text[100];
        ShipToAddr: array[10] of Text[100];
        CompanyAddr: array[8] of Text[100];
        CopyText: Text[30];
        DimText: Text;
        OldDimText: Text[120];
        Qty: Decimal;
        Amt: Decimal;
        ShowQty: Option Quantity,"Quantity Invoiced";
        GrossAmt: Decimal;
        TotalAmt: Decimal;
        TotalGrossAmt: Decimal;
        Contract_No_CaptionLbl: Label 'Contract No.';
        Service_Header___Order_Date_CaptionLbl: Label 'Order Date';
        Invoice_toCaptionLbl: Label 'Invoice to';
        CompanyInfo__Phone_No__CaptionLbl: Label 'Phone No.';
        CompanyInfo__Fax_No__CaptionLbl: Label 'Fax No.';
        Service_Header___Phone_No__CaptionLbl: Label 'Phone No.';
        Service_Header___E_Mail_CaptionLbl: Label 'Email';
        Header_DimensionsCaptionLbl: Label 'Header Dimensions';
        Service_Item_LinesCaptionLbl: Label 'Service Item Lines';
        Service_Item_Line__Response_Date_CaptionLbl: Label 'Response Date';
        Service_Item_Line__Response_Time_CaptionLbl: Label 'Response Time';
        Fault_CommentsCaptionLbl: Label 'Fault Comments';
        Resolution_CommentsCaptionLbl: Label 'Resolution Comments';
        QtyCaptionLbl: Label 'Quantity';
        Service_LinesCaptionLbl: Label 'Service Lines';
        AmountCaptionLbl: Label 'Amount';
        Gross_AmountCaptionLbl: Label 'Gross Amount';
        TotalCaptionLbl: Label 'Total';
        Line_DimensionsCaptionLbl: Label 'Line Dimensions';
        Ship_to_AddressCaptionLbl: Label 'Ship-to Address';
        FormattedAddress: Boolean;
        SalesPersonName: text;
        PaymentTermDescription: Text;
        Text1000000000: Label '%1 %2';
        FreightTermDescription: Text;
        ShipmentMethodDescription: Text;
        ShippingAgentDescription: Text;
        TaxLabels: Array[4] of Text;
        TaxAmounts: Array[4] of Decimal;
        ShowOrderComment: Boolean;
        CurrencyCode: Text;
        HideDiscount: Boolean;
        SEIFunctions: Codeunit "ENC SEI Functions";
        DocType: Text;
        ServiceItemLine_UoM: Code[10];
        NoServiceLines: Boolean;
        CurrSymbol: Text;
        TariffNo: Text;

    procedure InitializeRequest(ShowInternalInfoFrom: Boolean; ShowQtyFrom: Option)
    begin
        ShowInternalInfo := ShowInternalInfoFrom;
        ShowQty := ShowQtyFrom;
    end;

    local procedure FormatAddressFields(var ServiceHeader: Record "Service Header")
    var
        PaymentTerms: Record "Payment Terms";
        ShipmentMethod: Record "Shipment Method";
        ShippingAgent: Record "Shipping Agent";
        FreightTerm: Record "ENC Freight Term";
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        i: Integer;
    begin
        FormatAddr.GetCompanyAddr(ServiceHeader."Responsibility Center", RespCenter, CompanyInfo, CompanyAddr);
        FormatAddr.ServiceOrderSellto(CustAddr, ServiceHeader);
        FormatAddr.ServiceOrderShipto(ShipToAddr, ServiceHeader);
        if not FormattedAddress then begin
            FormattedAddress := True;
            SEIFunctions.FormatCompanyAddress(CompanyAddr, CompanyInfo);
            SEIFunctions.AddFooterToAddress(CustAddr, "Service Header"."Phone No.", "Service Header"."ENC Tax Registration No.", ServiceHeader."ENC FID No.", ServiceHeader."BA EORI No.");
            SEIFunctions.AddFooterToAddress(ShipToAddr, "Service Header"."Ship-to Phone", "Service Header"."ENC Ship-To Tax Reg. No.", ServiceHeader."ENC Ship-To FID No.", ServiceHeader."BA Ship-to EORI No.");
        end;

        with ServiceHeader do begin
            //SalesPersonName := DelChr(StrSubstNo(Text1000000000, "Salesperson Code", "Assigned User ID"), '<>', ' ');
            SalesPersonName := "Salesperson Code";
            if ("Payment Terms Code" <> '') and PaymentTerms.Get("Payment Terms Code") then
                PaymentTermDescription := PaymentTerms.Description
            else
                clear(PaymentTermDescription);

            if ("Shipment Method Code" <> '') and ShipmentMethod.Get("Shipment Method Code") then
                ShipmentMethodDescription := ShipmentMethod.Description
            else
                Clear(ShipmentMethodDescription);

            if ("Shipping Agent Code" <> '') and ShippingAgent.Get("Shipping Agent Code") then
                ShippingAgentDescription := ShippingAgent.Name
            else
                clear(ShippingAgentDescription);

            if ("ENC Freight Term" <> '') and FreightTerm.Get("ENC Freight Term") then
                FreightTermDescription := FreightTerm.Description
            else
                Clear(FreightTermDescription);

            Clear(DocType);
            GLSetup.Get;
            if "Currency Code" <> '' then
                CurrencyCode := "Currency Code"
            else
                CurrencyCode := GLSetup."LCY Code";

            if Currency.Get(CurrencyCode) and (Currency.Symbol <> '') then
                CurrSymbol := Currency.Symbol
            else
                CurrSymbol := '';

            case "Document Type" of
                "Document Type"::Order:
                    DocType := 'Order';
                "Document Type"::Quote:
                    DocType := 'Quote';
            end;
            "Order Date" := "Document Date";
        end;
    end;


    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateSalesTax(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; var SalesTaxAmountLine: Record "Sales Tax Amount Line")
    begin
    end;
}

