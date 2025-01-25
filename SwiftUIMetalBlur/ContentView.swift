import SwiftUI

enum BlurType: String, CaseIterable {
    case gaussian = "Gaussian Blur"
    case box = "Box Blur"
}

struct ContentView: View {
    @State var radius = 1.0;
    @State var type: BlurType = .gaussian
    
    var body: some View {
        VStack(spacing: 20) {
            Picker("Blur Type", selection: $type) {
                ForEach(BlurType.allCases, id: \.self) { blur in
                    Text(blur.rawValue).tag(blur)
                }
            }
            
            if type == .box {
                Image("1")
                    .resizable()
                    .scaledToFit()
                    .visualEffect { [radius] content, proxy in
                        content
                            .layerEffect(
                                ShaderLibrary.boxBlur(
                                    .float2(proxy.size),
                                    .float(radius)
                                ),
                                maxSampleOffset: .zero
                            )
                    }
            }
            
            if type == .gaussian {
                Image("1")
                    .resizable()
                    .scaledToFit()
                    .visualEffect { [radius] content, proxy in
                        content
                            .layerEffect(
                                ShaderLibrary.gaussianBlur(
                                    .float2(proxy.size),
                                    .float(radius)
                                ),
                                maxSampleOffset: .zero
                            )
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Radius: \(Int(radius))")
                Slider(value: $radius, in: 0...25, step: 1.0)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
