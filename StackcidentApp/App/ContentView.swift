import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var model = GameModel()
    @State private var scene = TowerScene(size: CGSize(width: 390, height: 700))

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.055, green: 0.075, blue: 0.13).ignoresSafeArea()
                SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                    .ignoresSafeArea()
                VStack(spacing: 14) {
                    HStack {
                        stat("SCORE", value: model.score)
                        Spacer()
                        Text("STACKCIDENT").font(.system(size: 17, weight: .black, design: .rounded))
                        Spacer()
                        stat("BEST", value: model.best)
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                    Text(model.status)
                        .font(.footnote.weight(.medium))
                        .multilineTextAlignment(.center)
                        .padding(10)
                        .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 12))
                    HStack(spacing: 10) {
                        control("↶", enabled: model.canAim) { model.rotate(-15) }
                        control("↷", enabled: model.canAim) { model.rotate(15) }
                        Button { model.futureVision() } label: {
                            Label("VISION \(model.visionCharges)", systemImage: "eye")
                                .font(.system(size: 13, weight: .bold))
                                .frame(maxWidth: .infinity).frame(height: 55)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                        .disabled(!model.canAim)
                    }
                    Button { model.drop() } label: {
                        Text("DROP")
                            .font(.system(size: 23, weight: .black, design: .rounded))
                            .frame(maxWidth: .infinity).frame(height: 60)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(!model.canDrop)
                    if model.phase == .over {
                        Button("RETRY") { model.restart() }
                            .font(.headline).buttonStyle(.borderedProminent).tint(.green)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 20)
            }
            .onAppear {
                scene.scaleMode = .resizeFill
                scene.size = geo.size
                scene.model = model
                model.scene = scene
            }
            .onChange(of: geo.size) { _, newSize in scene.size = newSize }
        }
    }

    private func stat(_ label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label).font(.system(size: 10, weight: .bold)).foregroundStyle(.secondary)
            Text("\(value)").font(.system(size: 24, weight: .black, design: .rounded))
        }
    }

    private func control(_ text: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text).font(.system(size: 30, weight: .bold))
                .frame(width: 57, height: 55)
        }
        .buttonStyle(.borderedProminent)
        .tint(.gray)
        .disabled(!enabled)
    }
}
