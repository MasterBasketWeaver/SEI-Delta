pageextension 80045 "BA Customer Card" extends "Customer Card"
{
    layout
    {
        modify("No.")
        {
            trigger OnBeforeValidate()
            begin
                Subscribers.CheckCustomerNo(Rec, xRec);
            end;
        }
        addlast(General)
        {
            field("BA Last Sales Activity"; "BA Last Sales Activity")
            {
                ApplicationArea = all;
            }
        }
        addlast(Content)
        {
            group("Account & System Control")
            {
                field(Blocked2; Rec.Blocked)
                {
                    ApplicationArea = all;

                    trigger OnValidate()
                    begin
                        MandatoryBlockReason := Rec.Blocked <> Rec.Blocked::" ";
                        if MandatoryBlockReason and (Rec."BA Block Reason" = '') then
                            Message(BlockedCustMsg);
                    end;
                }
                field("BA Block Reason"; "BA Block Reason")
                {
                    ApplicationArea = all;
                    ShowMandatory = MandatoryBlockReason;
                }
                field("Privacy Blocked2"; Rec."Privacy Blocked")
                {
                    ApplicationArea = all;
                }
                field("ENC Country/Region Mandatory"; Rec."ENC Country/Region Mandatory")
                {
                    ApplicationArea = all;
                }
                field("ENC Salesperson Code Mandatory"; Rec."ENC Salesperson Code Mandatory")
                {
                    ApplicationArea = all;
                }
                field("BA Int. Customer"; Rec."BA Int. Customer")
                {
                    ApplicationArea = all;
                }
                field("BA SEI Service Center"; "BA SEI Service Center")
                {
                    ApplicationArea = all;
                }
                field("BA Serv. Int. Customer"; Rec."BA Serv. Int. Customer")
                {
                    ApplicationArea = all;
                }
                field("IC Partner Code2"; Rec."IC Partner Code")
                {
                    ApplicationArea = all;
                }
                field("Service Zone Code2"; Rec."Service Zone Code")
                {
                    ApplicationArea = all;
                }
                field("ENC CRM GUID"; Rec."ENC CRM GUID")
                {
                    ApplicationArea = all;
                }
                field("BA Non-Mandatory Delivery Date"; Rec."BA Non-Mandatory Delivery Date")
                {
                    ApplicationArea = all;
                }
                field("BA Non-Mandatory Customer"; Rec."BA Non-Mandatory Customer")
                {
                    ApplicationArea = all;

                    trigger OnValidate()
                    begin
                        ShowMandatoryFields := not Rec."BA Non-Mandatory Customer";
                    end;
                }
            }

        }
        modify(Blocked)
        {
            ApplicationArea = all;
            Visible = false;
        }
        modify("Privacy Blocked")
        {
            ApplicationArea = all;
            Visible = false;
        }
        modify("IC Partner Code")
        {
            ApplicationArea = all;
            Visible = false;
        }
        modify("Service Zone Code")
        {
            ApplicationArea = all;
            Visible = false;
        }

        addafter("Post Code")
        {
            field("BA Region"; Rec."BA Region")
            {
                ApplicationArea = all;
            }
        }
        addfirst(AddressDetails)
        {
            field("BA Country/Region Code"; "Country/Region Code")
            {
                ApplicationArea = all;
                Caption = 'Country';
            }
        }
        addafter(County)
        {
            field("BA County Fullname"; "BA County Fullname")
            {
                ApplicationArea = all;
            }
        }
        modify("Country/Region Code")
        {
            ApplicationArea = all;
            Visible = false;
            Enabled = false;
            Editable = false;
        }
        modify(County)
        {
            trigger OnAfterValidate()
            begin
                Rec.CalcFields("BA County Fullname");
            end;
        }
        modify("Customer Posting Group")
        {
            trigger OnAfterValidate()
            begin
                UpdateBalanaceDisplay();
            end;
        }
        modify("Balance (LCY)")
        {
            ApplicationArea = all;
            Visible = false;
        }
        modify("Balance Due (LCY)")
        {
            ApplicationArea = all;
            Visible = false;
        }
        modify("Credit Limit (LCY)")
        {
            ApplicationArea = all;
            Visible = false;
        }
        modify(TotalSales2)
        {
            ApplicationArea = all;
            Visible = false;

        }
        addafter(TotalSales2)
        {
            group("Total Sales")
            {
                ShowCaption = false;
                Visible = ShowLCYBalances;
                field("TotalSales"; GetTotalSales())
                {
                    ApplicationArea = all;
                    Caption = 'Total Sales';
                    Style = Strong;
                    ToolTip = 'Specifies your total sales turnover with the customer in the current fiscal year. It is calculated from amounts excluding tax on all completed and open invoices and credit memos.';
                }
            }
            group("Non-LCY Sales")
            {
                ShowCaption = false;
                Visible = not ShowLCYBalances;
                field("TotalSales Non-LCY"; NonLCYCustomerStatistics.GetSales(Rec))
                {
                    ApplicationArea = all;
                    Caption = 'Total Sales';
                    Style = Strong;
                    ToolTip = 'Specifies your total sales turnover with the customer in the current fiscal year. It is calculated from amounts excluding tax on all completed and open invoices and credit memos.';
                }
            }
        }
        addafter("Balance (LCY)")
        {
            group("BA Local Balances")
            {
                Visible = ShowLCYBalances;
                ShowCaption = false;
                field("Credit Limit (LCY)2"; "Credit Limit (LCY)")
                {
                    ApplicationArea = all;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the maximum amount you allow the customer to exceed the payment balance before warnings are issued.';
                }
                field("BA Credit Limit Last Updated2"; Rec."BA Credit Limit Last Updated")
                {
                    ApplicationArea = all;
                }
                field("BA Credit Limit Updated By2"; Rec."BA Credit Limit Updated By")
                {
                    ApplicationArea = all;
                }
                field("BA Balance (LCY)"; "Balance (LCY)")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the payment amount that the customer owes for completed sales. This value is also known as the customer''s balance.';

                    trigger OnDrillDown()
                    begin
                        Rec.OpenCustomerLedgerEntries(false);
                    end;
                }
                field("BA Balance Due (LCY)"; "Balance Due (LCY)")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies payments from the customer that are overdue per today''s date.';

                    trigger OnDrillDown()
                    begin
                        Rec.OpenCustomerLedgerEntries(true);
                    end;
                }
            }
            group("BA Non-Local Balances")
            {
                Visible = not ShowLCYBalances;
                ShowCaption = false;
                field("BA Credit Limit"; "BA Credit Limit")
                {
                    ApplicationArea = all;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the maximum amount you allow the customer to exceed the payment balance before warnings are issued.';
                }
                field("BA Credit Limit Last Updated"; Rec."BA Credit Limit Last Updated")
                {
                    ApplicationArea = all;
                }
                field("BA Credit Limit Updated By"; Rec."BA Credit Limit Updated By")
                {
                    ApplicationArea = all;
                }
                field("BA Balance"; Balance)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the payment amount that the customer owes for completed sales. This value is also known as the customer''s balance.';

                    trigger OnDrillDown()
                    begin
                        Rec.OpenCustomerLedgerEntries(false);
                    end;
                }
                field("BA Balance Due"; "Balance Due")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies payments from the customer that are overdue per today''s date.';

                    trigger OnDrillDown()
                    begin
                        Rec.OpenCustomerLedgerEntries(true);
                    end;
                }
            }
        }
        modify("Location Code")
        {
            trigger OnLookup(var Text: Text): Boolean
            begin
                Text := Subscribers.LocationListLookup();
                exit(Text <> '');
            end;
        }

        addafter("Tax Exemption No.")
        {
            field("ENC FID No."; Rec."ENC FID No.")
            {
                ApplicationArea = all;
            }
            field("BA EORI No."; Rec."BA EORI No.")
            {
                ApplicationArea = all;
            }
            field("PST Exemption No."; Rec."VAT Registration No.")
            {
                Caption = 'PST Exemption No.';
                ApplicationArea = all;
            }
        }
        addafter(Name)
        {
            field("BA SEI Int'l Cust. No."; "BA SEI Int'l Cust. No.")
            {
                ApplicationArea = all;
            }
        }
        addafter("Salesperson Code")
        {
            field("BA Segment Code"; Rec."BA Segment Code")
            {
                ApplicationArea = all;
                ShowMandatory = ShowMandatoryFields;
            }
            field("BA Sub-Segment Code"; Rec."BA Sub-Segment Code")
            {
                ApplicationArea = all;
                ShowMandatory = ShowMandatoryFields;
            }
            field("BA Dealer"; Rec."BA Dealer")
            {
                ApplicationArea = all;
            }
            field("BA Constrained"; Rec."BA Constrained")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        addlast(Creation)
        {
            action("BA Cancel Customer")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Cancel;
                Caption = 'Cancel Customer';
                ToolTip = 'Deletes a customer that has been accidently created.';

                trigger OnAction()
                begin
                    if not Confirm('Cancel customer?') then
                        exit;
                    Rec."ENC Has Been Renamed" := true;
                    Rec.Delete(true);
                end;
            }
        }
    }

    var
        [InDataSet]
        ShowLCYBalances: Boolean;
        [InDataSet]
        StyleTxt: Text;
        NonLCYCustomerStatistics: Page "BA Non-LCY Cust. Stat. Factbox";
        MandatoryBlockReason: Boolean;




    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        RecVar: Variant;
        FieldsToCheck: List of [Integer];
    begin
        if (Rec."No." = '') or Rec."BA Non-Mandatory Customer" then
            exit;
        if Rec."BA New Record" then begin
            Rec."BA New Record" := false;
            Rec.Modify(false);
        end else
            exit;
        if (Rec.Blocked <> Rec.Blocked::" ") and (Rec."BA Block Reason" = '') then
            Error(BlockedCustMsg);
        FieldsToCheck.Add(Rec.FieldNo(Rec."BA Segment Code"));
        FieldsToCheck.Add(Rec.FieldNo(Rec."BA Sub-Segment Code"));
        FieldsToCheck.Add(Rec.FieldNo(Rec."Global Dimension 1 Code"));
        FieldsToCheck.Add(Rec.FieldNo(Rec."Global Dimension 2 Code"));
        RecVar := Rec;
        CheckMandatoryFields(RecVar, FieldsToCheck);
    end;


    trigger OnAfterGetRecord()
    var
        CustomDetailsFactbox: page "Customer Details FactBox";
    begin
        ShowMandatoryFields := Rec."BA New Record" and not Rec."BA Non-Mandatory Customer";
        UpdateBalanaceDisplay();
        StyleTxt := '';
        if ShowLCYBalances then
            StyleTxt := Rec.SetStyle()
        else
            if CustomDetailsFactbox.CalcAvailableCreditNonLCY(Rec) < 0 then
                StyleTxt := UnfavorableStyle;
        GetTotalSales();
    end;

    local procedure UpdateBalanaceDisplay()
    var
        CustPostingGroup: Record "Customer Posting Group";
    begin
        if Rec."Customer Posting Group" = '' then
            ShowLCYBalances := true
        else
            ShowLCYBalances := CustPostingGroup.Get(Rec."Customer Posting Group") and not CustPostingGroup."BA Show Non-Local Currency";
    end;



    local procedure GetTotalSales(): Decimal
    var
        AmountOnPostedInvoices: Decimal;
        AmountOnPostedCrMemos: Decimal;
        AmountOnOutstandingInvoices: Decimal;
        AmountOnOutstandingCrMemos: Decimal;
        NoPostedInvoices: Integer;
        NoPostedCrMemos: Integer;
        NoOutstandingInvoices: Integer;
        NoOutstandingCrMemos: Integer;
        Totals: Decimal;
        CustomerMgt: Codeunit "Customer Mgt.";
    begin
        AmountOnPostedInvoices := CustomerMgt.CalcAmountsOnPostedInvoices("No.", NoPostedInvoices);
        AmountOnPostedCrMemos := CustomerMgt.CalcAmountsOnPostedCrMemos("No.", NoPostedCrMemos);
        AmountOnOutstandingInvoices := CustomerMgt.CalculateAmountsOnUnpostedInvoices("No.", NoOutstandingInvoices);
        AmountOnOutstandingCrMemos := CustomerMgt.CalculateAmountsOnUnpostedCrMemos("No.", NoOutstandingCrMemos);
        Totals := AmountOnPostedInvoices + AmountOnPostedCrMemos + AmountOnOutstandingInvoices + AmountOnOutstandingCrMemos;
        CustomerMgt.CalculateStatistic(Rec, AdjmtCost, AdjCustProfit, AdjProfitPct,
              CustInvDiscAmount, CustPayments, CustSales, CustProfit);
        EXIT(Totals)
    end;


    procedure CheckMandatoryFields(var RecVar: Variant; var FieldsToCheck: List of [Integer])
    var
        RecRef: RecordRef;
        EmptyFields: List of [Integer];
        FldNo: Integer;
        ErrorString: TextBuilder;
    begin
        if FieldsToCheck.Count() = 0 then
            exit;
        RecRef.GetTable(RecVar);
        foreach FldNo in FieldsToCheck do
            if Format(RecRef.Field(FldNo).Value()) = '' then
                EmptyFields.Add(FldNo);

        case EmptyFields.Count() of
            0:
                exit;
            1:
                begin
                    EmptyFields.Get(1, FldNo);
                    Error(SingleMissingValueErr, RecRef.Field(FldNo).Caption());
                end;
            else begin
                    ErrorString.AppendLine(MultiMissingValueErr);
                    foreach FldNo in EmptyFields do
                        ErrorString.AppendLine(RecRef.Field(FldNo).Caption());
                    Error(ErrorString.ToText());
                end;
        end;
    end;




    var
        Subscribers: Codeunit "BA SEI Subscibers";
        AdjmtCost: Decimal;
        AdjCustProfit: Decimal;
        AdjProfitPct: Decimal;
        CustInvDiscAmount: Decimal;
        CustPayments: Decimal;
        CustSales: Decimal;
        CustProfit: Decimal;
        [InDataSet]
        ShowMandatoryFields: Boolean;

        BlockedCustMsg: Label 'Block Reason must specified if customer is blocked.';
        UnfavorableStyle: Label 'Unfavorable';
        SingleMissingValueErr: Label '%1 must be given a value before the page can be closed.';
        MultiMissingValueErr: Label 'The following fields must be given a value before the page can be closed:';
}