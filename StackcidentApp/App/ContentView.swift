import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var model = GameModel()
    @State private var scene = TowerScene(size: CGSize(width: 390, height: 550))

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    stat("SCORE", value: model.score)
                    Spacer()
                    VStack(spacing: 2) {
                        Text("STACKCIDENT")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .tracking(1)
                        Text("HOW HIGH CAN YOU GO?")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .tracking(1.5).foregroundStyle(.white.opacity(0.55))
                    }
                    Spacer()
                    stat("BEST", value: model.best)
                }
                .padding(.horizontal, 22)
                .frame(height: 67)
                .background(Color(red: 0.075, green: 0.095, blue: 0.17))

                // SpriteKit is restricted to the actual playable space. The
                // controls below are OUTSIDE this viewport: no more overlap.
                SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                VStack(spacing: 13) {
                    Text(model.status)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 30)
                    HStack(spacing: 10) {
                        rotation("rotate.left", degrees: -15)
                        rotation("rotate.right", degrees: 15)
                        Button { model.futureVision() } label: {
                            HStack(spacing: 7) {
                                Image(systemName: "eye.fill")
                                Text("VISION \(model.visionCharges)")
                            }
                            .font(.system(size: 13, weight: .heavy))
                            .frame(maxWidth: .infinity)
                            .frame(height: 53)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                        .disabled(!model.canAim)
                        .accessibilityLabel("Future Vision, \(model.visionCharges) charges")
                    }
                    Button { model.phase == .over ? model.restart() : model.drop() } label: {
                        HStack(spacing: 10) {
                            Image(systemName: model.phase == .over ? "arrow.clockwise" : "arrow.down.circle.fill")
                            Text(model.phase == .over ? "TRY AGAIN" : "DROP IT!")
                        }
                        .font(.system(size: 21, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 62)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(model.phase == .over ? .green : .orange)
                    .disabled(model.phase == .falling)
                }
                .padding(.horizontal, 18)
                .padding(.top, 13)
                .padding(.bottom, 14)
                .background(Color(red: 0.095, green: 0.115, blue: 0.20))
            }
            .background(Color(red: 0.055, green: 0.075, blue: 0.13))
            .foregroundStyle(.white)
            .onAppear {
                scene.scaleMode = .resizeFill
                scene.size = CGSize(width: geo.size.width, height: max(280, geo.size.height - 265))
                scene.model = model
                model.scene = scene
            }
            .onChange(of: geo.size) { _, newSize in
                scene.size = CGSize(width: newSize.width, height: max(280, newSize.height - 265))
            }
        }
    }

    private func stat(_ label: String, value: Int) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.system(size: 10, weight: .bold)).foregroundStyle(.white.opacity(0.5))
            Text("\(value)").font(.system(size: 25, weight: .black, design: .rounded))
        }
        .frame(minWidth: 50)
    }

    private func rotation(_ symbol: String, degrees: CGFloat) -> some View {
        Button { model.rotate(degrees) } label: {
            Image(systemName: symbol)
                .font(.system(size: 25, weight: .bold))
                .frame(width: 55, height: 53)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color(red: 0.3, green: 0.35, blue: 0.49))
        .disabled(!model.canAim)
        .accessibilityLabel(degrees < 0 ? "Rotate left" : "Rotate right")
    }
}
