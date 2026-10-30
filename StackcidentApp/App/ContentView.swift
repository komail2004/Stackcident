import SwiftUI
import SpriteKit

struct ContentView: View {
    var onExit: () -> Void = {}
    @StateObject private var model = GameModel()
    @State private var scene = TowerScene(size: CGSize(width: 390, height: 550))

    private let background = Color(red: 0.045, green: 0.061, blue: 0.12)
    private let panel = Color(red: 0.086, green: 0.105, blue: 0.19)
    private let accent = Color(red: 1, green: 0.61, blue: 0.31)

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 10) {
                    Button(action: onExit) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 15, weight: .bold))
                            .frame(width: 28, height: 42)
                    }
                    .accessibilityLabel("Return to main menu")
                    stat("SCORE", value: model.score)
                    Spacer(minLength: 5)
                    VStack(spacing: 4) {
                        Text("STACKCIDENT")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .tracking(0.6)
                        Text(model.levelName)
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .tracking(2.2)
                            .foregroundStyle(accent)
                    }
                    .minimumScaleFactor(0.75)
                    Spacer(minLength: 5)
                    stat("BEST", value: model.best)
                }
                .padding(.horizontal, 19)
                .frame(height: 77)
                .background(panel)

                ZStack(alignment: .top) {
                    SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()

                    HStack(spacing: 7) {
                        Image(systemName: "sparkle")
                            .foregroundStyle(accent)
                        Text("STACK • BALANCE • SURVIVE")
                            .tracking(1.0)
                    }
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(.white.opacity(0.075), in: Capsule())
                    .padding(.top, 12)
                    .allowsHitTesting(false)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .layoutPriority(1)

                VStack(spacing: 12) {
                    Text(model.status)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 32)
                    HStack(spacing: 11) {
                        rotate("arrow.counterclockwise", degrees: -15)
                        rotate("arrow.clockwise", degrees: 15)
                        Button { model.futureVision() } label: {
                            HStack(spacing: 7) {
                                Image(systemName: "eye.fill")
                                Text("VISION  \(model.visionCharges)")
                            }
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                        }
                        .buttonStyle(.plain)
                        .background(LinearGradient(colors: [
                            Color(red: 0.69, green: 0.32, blue: 0.97),
                            Color(red: 0.48, green: 0.25, blue: 0.84)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 17))
                        .opacity(model.canAim ? 1 : 0.5)
                        .disabled(!model.canAim)
                        .accessibilityLabel("Future Vision, \(model.visionCharges) charges. Not yet available.")
                    }

                    Button {
                        if model.phase == .over { model.restart() }
                        else { model.drop() }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: model.phase == .over ? "arrow.clockwise" : "arrow.down.circle.fill")
                            Text(model.phase == .over ? "ONE MORE TRY" : "DROP IT!")
                        }
                        .font(.system(size: 21, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 61)
                    }
                    .buttonStyle(.plain)
                    .background(LinearGradient(colors: model.phase == .over ?
                        [.green, Color(red: 0.19, green: 0.67, blue: 0.58)] :
                        [accent, Color(red: 1, green: 0.39, blue: 0.38)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 19))
                    .shadow(color: accent.opacity(0.20), radius: 17, y: 5)
                    .disabled(model.phase == .falling)
                    .opacity(model.phase == .falling ? 0.5 : 1)
                }
                .padding(.horizontal, 19)
                .padding(.top, 13)
                .padding(.bottom, 14)
                .background(panel)
            }
            .background(background)
            .foregroundStyle(.white)
            .onAppear {
                scene.scaleMode = .resizeFill
                scene.size = CGSize(width: geometry.size.width,
                                    height: max(280, geometry.size.height - 280))
                scene.model = model
                model.scene = scene
                scene.setPaused(false)
            }
            .onChange(of: geometry.size) { _, size in
                scene.size = CGSize(width: size.width, height: max(280, size.height - 280))
            }
        }
    }

    private func stat(_ label: String, value: Int) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
            Text("\(value)")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .monospacedDigit()
        }
        .frame(minWidth: 52)
    }

    private func rotate(_ symbol: String, degrees: CGFloat) -> some View {
        Button { model.rotate(degrees) } label: {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .bold))
                .frame(width: 57, height: 54)
        }
        .buttonStyle(.plain)
        .background(Color(red: 0.22, green: 0.26, blue: 0.40),
                    in: RoundedRectangle(cornerRadius: 17))
        .disabled(!model.canAim)
        .opacity(model.canAim ? 1 : 0.5)
        .accessibilityLabel(degrees < 0 ? "Rotate left" : "Rotate right")
    }
}
