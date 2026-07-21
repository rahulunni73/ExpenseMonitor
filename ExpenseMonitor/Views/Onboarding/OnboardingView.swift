//
//  OnboardingView.swift
//  ExpenseMonitor
//
//  Created by Ospyn on 21/07/26.
//

import SwiftUI

struct OnboardingView: View {
    
    @State private var currentPage = 0

    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        
        VStack(spacing: 0) {

            HStack {
                Spacer()
                if currentPage < 3 {
                    skipButton
                }
            }
            .frame(height: 44)

            TabView(selection: $currentPage) {
                WelcomePageView()
                    .tag(0)

                TransactionsPageView()
                    .tag(1)

                EMIPageView()
                    .tag(2)

                OverviewPageView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            pageIndicator
            continueButton
            
        }.background(themeColors.background)
        

    }
    
    
    
    private var skipButton: some View {
        Button("Skip") {
            hasSeenOnboarding = true
        }
        .font(typography.subheadline)
        .foregroundStyle(.secondary)
        .padding()
    }

    private var continueButton: some View {
        Button {
            if currentPage < 3 {
                withAnimation {
                    currentPage += 1
                }
            } else {
                hasSeenOnboarding = true
            }
        } label: {
            HStack(spacing: 6) {
                Text(currentPage < 3 ? "Continue" : "Get Started")
                if currentPage == 3 {
                    Image(systemName: "arrow.right")
                }
            }
            .font(typography.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(themeColors.accent)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 16)
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<4) { index in
                Capsule()
                    .fill(index == currentPage ? themeColors.accent : Color.primary.opacity(0.15))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
            }
        }
        .padding(.vertical, 16)
        .animation(.easeInOut(duration: 0.25), value: currentPage)
    }
    
}

#Preview {
    OnboardingView()
}
