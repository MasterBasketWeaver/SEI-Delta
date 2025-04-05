enum 50001 "BA SEI Order Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Delta SO")
    {
        Caption = 'Delta Sales Order';
    }
    value(2; "Delta SVO")
    {
        Caption = 'Delta Service Order';
    }
    value(3; "Int. SO")
    {
        Caption = 'International Sales Order';
    }
    value(4; "Int. SVO")
    {
        Caption = 'International Service Order';
    }
    value(5; "Transfer")
    {
        Caption = 'Transfer Order';
    }
}