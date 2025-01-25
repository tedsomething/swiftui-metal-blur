#include <metal_stdlib>
using namespace metal;
#include <SwiftUI/SwiftUI_Metal.h>

[[ stitchable ]] half4 boxBlur(float2 position, SwiftUI::Layer layer, float2 size, float radius) {
    half3 color = half3(0);
    
    float radiusValues = pow(2 * radius + 1, 2);
    for (float i = -radius; i <= radius; i++) {
        for (float j = -radius; j <= radius; j++) {
            float2 p = position + float2(i, j);
            
            // A LITERAL EDGE CASE? ;]
            // To handle it, we simply "skip" it and the average stays the same.
            if (p.x < 0 || p.y < 0 || p.x > (size.x - 1) || p.y > (size.y - 1)) {
                radiusValues -= 1;
                continue;
            }
            
            half3 colorPoint = layer.sample(p).xyz;
            color += colorPoint;
        }
    }
    
    color /= radiusValues;
    
    return half4(color, 1);
}
