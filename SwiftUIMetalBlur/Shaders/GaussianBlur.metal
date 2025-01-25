#include <metal_stdlib>
using namespace metal;
#include <SwiftUI/SwiftUI_Metal.h>

#define KERNEL_SIZE (51)
#define KERNEL_HALF (25)

void gaussianKernel(float sigma, thread half* weights) {
    half sum = 0.0;
    
    for (int i = -KERNEL_HALF; i <= KERNEL_HALF; i++) {
        for (int j = -KERNEL_HALF; j <= KERNEL_HALF; j++) {
            float exponent = exp(-(i*i + j*j) / (2 * sigma * sigma));
            half value = exponent / (2 * M_PI_H * sigma * sigma);
            
            int idx = (i + KERNEL_HALF) * KERNEL_SIZE + (j + KERNEL_HALF);
            weights[idx] = value;
            sum += value;
        }
    }
    
    for (int i = -KERNEL_HALF; i <= KERNEL_HALF; i++) {
        for (int j = -KERNEL_HALF; j <= KERNEL_HALF; j++) {
            int idx = (i + KERNEL_HALF) * KERNEL_SIZE + (j + KERNEL_HALF);
            weights[idx] /= sum;
        }
    }
}

[[ stitchable ]] half4 gaussianBlur(float2 position, SwiftUI::Layer layer, float2 size, float radius) {
    half3 color = half3(0);
    
    thread half weights[KERNEL_SIZE * KERNEL_SIZE];
    gaussianKernel(radius, weights); // TODO: It might be much better idea to do this in CPU
    
    for (int i = -KERNEL_HALF; i <= KERNEL_HALF; i++) {
        for (int j = -KERNEL_HALF; j <= KERNEL_HALF; j++) {
            float2 p = position + float2(i, j);
            
            
            // A LITERAL EDGE CASE? ;]
            // To handle it, we simply "clamp" to a known range.
            p.x = fmax(0, fmin(p.x, size.x - 1));
            p.y = fmax(0, fmin(p.y, size.y - 1));
            
            int idx = (i + KERNEL_HALF) * KERNEL_SIZE + (j + KERNEL_HALF);
            float kernelValue = weights[idx];
            half3 colorPoint = layer.sample(p).xyz;
            
            color += colorPoint * kernelValue;
        }
    }
        
    return half4(color, 1);
}
