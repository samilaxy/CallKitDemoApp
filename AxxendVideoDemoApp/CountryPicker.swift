//
//  CountryPicker.swift
//  AxxendVideoDemoApp
//
//  Created by Noye Samuel on 26/04/2023.
//

import Foundation
import SwiftUI
import CountryPicker

struct CountryPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = CountryPickerViewController
    
    let countryPicker = CountryPickerViewController()
    
    @Binding var country: Country?
    
    func makeUIViewController(context: Context) -> CountryPickerViewController {
        countryPicker.selectedCountry = "TR"
        countryPicker.delegate = context.coordinator
        return countryPicker
    }
    
    func updateUIViewController(_ uiViewController: CountryPickerViewController, context: Context) {
            //
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, CountryPickerDelegate {
        var parent: CountryPicker
        init(_ parent: CountryPicker) {
            self.parent = parent
        }
        func countryPicker(didSelect country: Country) {
            parent.country = country
        }
    }
}

import SwiftUI
import CountryPicker

struct ContentViewrtt: View {
    @State private var country: Country?
    @State private var showCountryPicker = false
    
    var body: some View {
        VStack {
            Button {
                showCountryPicker = true
            } label: {
                Text("Select Country")
            }.sheet(isPresented: $showCountryPicker) {
                CountryPicker(country: $country)
            }
        }
    }
}
