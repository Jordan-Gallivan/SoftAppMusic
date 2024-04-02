//
//  TermsOfServiceView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 3/31/24.
//

import Foundation
import SwiftUI

struct TermsOfServiceView: View {
    
    private var viewOnly: Bool = false
    private var acceptClosure: () -> Void
    
    init(viewOnly: Bool, acceptClosure: @escaping () -> Void) {
        self.viewOnly = viewOnly
        self.acceptClosure = acceptClosure
    }
    
    init(acceptClosure: @escaping () -> Void) {
        self.acceptClosure = acceptClosure
    }
    
    var body: some View {
        ScrollView {
            if self.viewOnly {
                VStack(alignment: .trailing) {
                    Button("Close") {
                        acceptClosure()
                    }
                }
            }
            
            Text("Terms and Conditions of Use")
                .font(.title)

            Text("1. Introduction")
                .font(.title3)
                .multilineTextAlignment(.leading)

            Text("Welcome to SoftApp Music! These terms and conditions govern your use of our application and its services, which may include accessing your Spotify account (\"Service\"). By accessing or using the Service, you agree to be bound by these terms and conditions. If you do not agree to these terms and conditions, please refrain from using the Service.")

            Text("2. Use of Service")
                .font(.title3)
                .multilineTextAlignment(.leading)

            Text("2.1. Eligibility: You must be at least 18 years old to use the Service. By using the Service, you represent and warrant that you are at least 18 years old.")

            Text("2.2. Spotify Credentials: In order to use certain features of the Service, you may be required to provide your Spotify login credentials. By providing your Spotify credentials, you authorize us to access your Spotify account solely for the purpose of providing the Service.")

            Text("""
                "2.3. Prohibited Activities: You agree not to engage in any of the following prohibited activities while using the Service:

                Violating any laws or regulations.
                Breaching any third-party rights.
                Interfering with or disrupting the Service.
                Attempting to gain unauthorized access to the Service or any related systems or networks.
                Impersonating any person or entity, or falsely stating or misrepresenting your affiliation with a person or entity.
            """)

            Text("3. Privacy Policy")
                .font(.title3)
                .multilineTextAlignment(.leading)

            Text("Our Privacy Policy governs the collection, use, and disclosure of your personal information in connection with the Service. By using the Service, you consent to the collection, use, and disclosure of your personal information as described in our Privacy Policy.")

            Text("4. Intellectual Property")
                .font(.title3)
                .multilineTextAlignment(.leading)

            Text("4.1. Ownership: All intellectual property rights in the Service, including but not limited to copyrights, trademarks, and trade secrets, are owned by us or our licensors.")

            Text("4.2. License: Subject to your compliance with these terms and conditions, we grant you a limited, non-exclusive, non-transferable license to use the Service for your personal and non-commercial use.")

            Text("5. Disclaimer of Warranties")
                .font(.title3)
                .multilineTextAlignment(.leading)

            Text("THE SERVICE IS PROVIDED ON AN \"AS IS\" AND \"AS AVAILABLE\" BASIS, WITHOUT ANY WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED. WE DISCLAIM ALL WARRANTIES, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.")

            Text("6. Limitation of Liability")
                .font(.title3)
                .multilineTextAlignment(.leading)

            Text("IN NO EVENT SHALL WE BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, ARISING OUT OF OR IN CONNECTION WITH THE USE OF OR INABILITY TO USE THE SERVICE.")

            Text("7. Indemnification")
                .font(.title3)
                .multilineTextAlignment(.leading)

            Text("You agree to indemnify and hold us harmless from and against any and all claims, liabilities, damages, losses, costs, and expenses, including legal fees, arising out of or in connection with your use of the Service or any breach of these terms and conditions.")

            Text("8. Changes to Terms and Conditions")
                .font(.title3)
                .multilineTextAlignment(.leading)

            Text("We reserve the right to modify or update these terms and conditions at any time, without prior notice. Your continued use of the Service after any such changes constitutes your acceptance of the revised terms and conditions.")

            Text("9. Governing Law")
                .font(.title3)
                .multilineTextAlignment(.leading)

            Text("These terms and conditions shall be governed by and construed in accordance with the laws of the State of Florida. Any disputes arising out of or in connection with these terms and conditions shall be subject to the exclusive jurisdiction of the courts of the State of Florida.")

            Text("10. Contact Us")
                .font(.title3)
                .multilineTextAlignment(.leading)

            Text("If you have any questions or concerns about these terms and conditions, please contact the University of North Florida School of Computing.")
            
            if !viewOnly {
                Button("Accept") {
                    self.acceptClosure()
                }
                .buttonStyle(DefaultButtonStyling(buttonColor: StyleConstants.DarkBlue, borderColor: StyleConstants.DarkBlue, textColor: .white))
            }
        }
    }
}
