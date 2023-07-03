report 60100 "BAC Create Random Sales Data"
{
    Caption = 'BAC Create Random Sales Data';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = false;

    trigger OnInitReport()
    var
        PostingDate: Date;
        OrderPostingDate: Date;
        PostingStepInt: Integer;
        PostingStep: Code[10];
        Window: Dialog;
        NextDocNo: Code[10];
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", '0000', '9999');
        if SalesHeader.FindLast() then
            NextDocNo := IncStr(SalesHeader."No.");
        Window.Open('Customer #1######### Item #2###########');
        PostingDate := 20250301D;
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        if Customer.FindSet() then
            repeat
                if Item.FindFirst() then
                    Item.Next(Random(100));
                PostingStepInt := round(Random(300), 1);
                PostingStep := Format(PostingStepInt) + 'D';
                OrderPostingDate := CalcDate(PostingStep, PostingDate);
                SalesHeader.Init();
                SalesHeader.SetHideValidationDialog(true);
                SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                SalesHeader."No." := NextDocNo;
                NextDocNo := IncStr(NextDocNo);
                SalesHeader.Insert(true);
                SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
                SalesHeader.Validate("Posting Date", OrderPostingDate);
                SalesHeader.Modify();
                SalesLine.Init();
                SalesLine.SetHideValidationDialog(true);
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := 10000;
                SalesLine.Insert(true);
                SalesLine.Type := SalesLine.Type::Item;
                SalesLine.Validate("No.", Item."No.");
                SalesLine.Validate(Quantity, Random(10));
                SalesLine.Modify();
                Window.Update(1, Customer."No.");
                Window.Update(2, item."No.");
                Commit();
            until Customer.next = 0;
    end;

    var
        Item: Record item;
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
}