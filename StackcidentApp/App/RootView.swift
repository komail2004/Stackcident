import SwiftUI

/// Native in-app animated title sequence. The actual iOS launch screen remains
/// static, as required by the platform; this begins immediately afterward.
struct RootView: View {
    private enum Destination { case splash, menu, game }
    @State private var destination: Destination = .splash
    @State private var animateLogo = false
    @State private var showHelp = false
    @AppStorage("bestScore") private var bestScore = 0

    private let navy = Color(red: 0.045, green: 0.061, blue: 0.12)
    private let gold = Color(red: 1, green: 0.67, blue: 0.30)

    var body: some View {
        ZStack {
            navy.ignoresSafeArea()
            switch destination {
            case .splash:
                titleArtwork
                    .scaleEffect(animateLogo ? 1 : 0.73)
                    .opacity(animateLogo ? 1 : 0)
                    .transition(.opacity)
            case .menu:
                menu
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            case .game:
                ContentView(onExit: { withAnimation(.easeInOut(duration: 0.2)) { destination = .menu } })
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .task {
            guard destination == .splash else { return }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.63)) { animateLogo = true }
            try? await Task.sleep(nanoseconds: 1_250_000_000)
            if destination == .splash {
                withAnimation(.easeInOut(duration: 0.35)) { destination = .menu }
            }
        }
        .sheet(isPresented: $showHelp) {
            howToPlay
                .presentationDetents([.medium, .large])
        }
    }

    private var titleArtwork: some View {
        VStack(spacing: 19) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 230, height: 230)
                    .blur(radius: 22)
                VStack(spacing: -6) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.98, green: 0.44, blue: 0.49))
                        .frame(width: 64, height: 60)
                        .rotationEffect(.degrees(21))
                        .offset(x: 24)
                    RoundedRectangle(cornerRadius: 7)
                        .fill(gold)
                        .frame(width: 110, height: 27)
                        .rotationEffect(.degrees(-8))
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.26, green: 0.86, blue: 0.79))
                        .frame(width: 86, height: 58)
                        .rotationEffect(.degrees(7))
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color(red: 0.63, green: 0.43, blue: 0.96))
                        .frame(width: 160, height: 20)
                }
                .shadow(color: .purple.opacity(0.35), radius: 16, y: 8)
            }
            Text("STACKCIDENT")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .tracking(1.1)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text("ONE MORE BLOCK. WHAT COULD GO WRONG?")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(1.1)
                .foregroundStyle(gold)
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 22)
        .accessibilityElement(children: .combine)
    }

    private var menu: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)
            titleArtwork
            Text("A game of bad decisions and excellent gravity.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.63))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            Spacer(minLength: 28)
            VStack(spacing: 14) {
                Label("BEST STACK   \(bestScore)", systemImage: "trophy.fill")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(gold)
                    .padding(.bottom, 10)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { destination = .game }
                } label: {
                    Label("START GAME", systemImage: "play.fill")
                        .font(.system(size: 21, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity).frame(height: 65)
                        .foregroundStyle(navy)
                        .background(LinearGradient(colors: [
                            gold, Color(red: 1, green: 0.43, blue: 0.37)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 22))
                }
                Button { showHelp = true } label: {
                    Label("HOW TO PLAY", systemImage: "questionmark.circle.fill")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .foregroundStyle(.white)
                        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 18))
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 28)
            Spacer(minLength: 30)
            Text("GRAVITY HAS ENTERED THE CHAT.")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(.white.opacity(0.35))
                .padding(.bottom, 22)
        }
    }

    private var howToPlay: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("HOW TO SURVIVE")
                .font(.system(size: 24, weight: .black, design: .rounded))
            Label("Drag sideways to aim the next object.", systemImage: "hand.draw.fill")
            Label("Use rotate buttons for the worst possible angle.", systemImage: "rotate.right.fill")
            Label("Tap DROP IT! and trust your engineering.", systemImage: "arrow.down.circle.fill")
            Label("If the new piece falls below the platform, it's game over.", systemImage: "exclamationmark.triangle.fill")
            Text("Future Vision is coming after physics validation. No fake predictions!")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button("GOT IT") { showHelp = false }
                .font(.headline).buttonStyle(.borderedProminent).tint(.orange)
                .frame(maxWidth: .infinity)
        }
        .padding(26)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
