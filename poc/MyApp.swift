//
//  MyApp.swift
//  poc
//
//  Created by David Frontegg on 14/11/2022.
//

import SwiftUI

struct MyApp: View {
    @EnvironmentObject var fronteggAuth: FronteggAuth

    
    var body: some View {
        
        if fronteggAuth.isAuthenticated {
            TabView {
                ProfileTab()
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                TasksTab()
                    .tabItem {
                        Image(systemName: "checklist")
                        Text("Tasks")
                    }
            }
        } else {
            FronteggLoginPage()
        }
    }
}

struct MyApp_Previews: PreviewProvider {
    static var previews: some View {
        MyApp()
    }
}
