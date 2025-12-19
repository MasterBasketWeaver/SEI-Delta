// pageextension 80210 "BA Gener" extends "Generate EFT Files"
// {
//     layout
//     {
//         addlast(Content)
//         {
//             field("Test Payment"; TestPayment)
//             {
//                 ApplicationArea = all;

//                 trigger OnValidate()
//                 begin
//                     SingleInstance.SetEFTTestPayment(TestPayment);
//                 end;
//             }
//         }
//     }

//     trigger OnOpenPage()
//     begin
//         TestPayment := SingleInstance.GetEFTTestPayment();
//     end;

//     var
//         SingleInstance: Codeunit "BA Single Instance";
//         TestPayment: Boolean;

// }