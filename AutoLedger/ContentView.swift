import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.on.rectangle")
                .font(.system(size: 56))
            Text("自动记账")
                .font(.title)
                .bold()
            Text("脚手架已就绪")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}