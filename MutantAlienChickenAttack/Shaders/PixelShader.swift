//
//  PixelShader.swift
//  MutantAlienChickenAttack
//
//  Created by tony on 09/11/2025.
//
import SpriteKit

extension SKShader {
    static let pixelShader = SKShader(source: """
        void main() {
            vec2 uv = v_tex_coord;
            vec2 texSize = u_texture_size.xy;
            float blockSize = 16.0;
            vec2 blockUV = vec2(blockSize / texSize.x, blockSize / texSize.y);
            uv = blockUV * floor(uv / blockUV);
            gl_FragColor = texture2D(u_texture, uv);
        }
        """)
}


class PixelateFilter: CIFilter {
    var inputImage: CIImage?
    var inputBlockSize: CGFloat = 16.0

    private static let kernel: CIColorKernel = {
        let source = """
        kernel vec4 pixelate(__sample image, vec2 blockSize) {
            vec2 coord = destCoord();
            vec2 pixel = floor(coord / blockSize) * blockSize;
            return sample(image, pixel);
        }
        """
        return CIColorKernel(source: source)!
    }()

    override var outputImage: CIImage? {
        guard let inputImage = inputImage else { return nil }
        let args = [inputImage, CIVector(x: inputBlockSize, y: inputBlockSize)] as [Any]
        return PixelateFilter.kernel.apply(extent: inputImage.extent, arguments: args)
    }
}
