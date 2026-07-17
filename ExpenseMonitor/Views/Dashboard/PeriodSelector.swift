//
//  PeriodSelector.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 15/07/26.
//


import SwiftUI


struct PeriodSelector: View {
    
    @State private var selectedPeriod = "This Month"
    let options = ["This Month", "Custom"]
    
    var body: some View {
        
        
        HStack {
            
            ForEach(options, id: \.self) { option in
                
                Text(option)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(option == selectedPeriod ? .primary : .secondary)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(option == selectedPeriod ? Color.white : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius:8))
                    .shadow(color: .black.opacity(option == selectedPeriod ? 0.1 : 0),radius: 3,y: 1)
                    .contentShape(Rectangle())
                    .onTapGesture {selectedPeriod = option}
                
            }
            
        }.padding(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius:10))
        
        
        
        
    }
    
}

#Preview {
    PeriodSelector()
}
