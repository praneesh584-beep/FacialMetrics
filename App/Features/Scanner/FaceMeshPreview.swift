import SceneKit
import SwiftUI
import UIKit

struct FaceMeshPreview: UIViewRepresentable {
    let sample: FaceFrameSample?

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView(frame: .zero)
        view.backgroundColor = .black
        view.allowsCameraControl = false
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X
        view.scene = context.coordinator.makeScene()
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        context.coordinator.update(sample: sample)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        private let rootNode = SCNNode()
        private let surfaceNode = SCNNode()
        private let wireNode = SCNNode()

        func makeScene() -> SCNScene {
            let scene = SCNScene()
            scene.rootNode.addChildNode(rootNode)

            let camera = SCNCamera()
            camera.fieldOfView = 44
            let cameraNode = SCNNode()
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(0, 0, 1.35)
            scene.rootNode.addChildNode(cameraNode)

            let keyLight = SCNLight()
            keyLight.type = .omni
            keyLight.intensity = 820
            let keyLightNode = SCNNode()
            keyLightNode.light = keyLight
            keyLightNode.position = SCNVector3(0.35, 0.55, 0.8)
            scene.rootNode.addChildNode(keyLightNode)

            let fillLight = SCNLight()
            fillLight.type = .ambient
            fillLight.intensity = 360
            fillLight.color = UIColor.systemIndigo
            let fillLightNode = SCNNode()
            fillLightNode.light = fillLight
            scene.rootNode.addChildNode(fillLightNode)

            rootNode.addChildNode(surfaceNode)
            rootNode.addChildNode(wireNode)
            rootNode.scale = SCNVector3(6.0, 6.0, 6.0)
            rootNode.eulerAngles = SCNVector3(-0.10, 0, 0)

            addReferenceRings(to: scene.rootNode)
            return scene
        }

        func update(sample: FaceFrameSample?) {
            guard let mesh = sample?.mesh, mesh.vertices.count >= 3, mesh.triangleIndices.count >= 3 else {
                surfaceNode.geometry = nil
                wireNode.geometry = nil
                return
            }

            surfaceNode.geometry = makeGeometry(mesh: mesh, isWireframe: false)
            wireNode.geometry = makeGeometry(mesh: mesh, isWireframe: true)
        }

        private func makeGeometry(mesh: FaceMeshSnapshot, isWireframe: Bool) -> SCNGeometry {
            let vertices = mesh.vertices.map { vertex in
                SIMD3<Float>(Float(vertex.x), Float(vertex.y), Float(vertex.z))
            }
            let vertexData = vertices.withUnsafeBufferPointer { buffer -> Data in
                guard let baseAddress = buffer.baseAddress else { return Data() }
                return Data(
                    bytes: baseAddress,
                    count: MemoryLayout<SIMD3<Float>>.stride * buffer.count
                )
            }
            let vertexSource = SCNGeometrySource(
                data: vertexData,
                semantic: .vertex,
                vectorCount: vertices.count,
                usesFloatComponents: true,
                componentsPerVector: 3,
                bytesPerComponent: MemoryLayout<Float>.size,
                dataOffset: 0,
                dataStride: MemoryLayout<SIMD3<Float>>.stride
            )

            let indices = mesh.triangleIndices.map { UInt32(max(0, $0)) }
            let indexData = indices.withUnsafeBufferPointer { buffer -> Data in
                guard let baseAddress = buffer.baseAddress else { return Data() }
                return Data(
                    bytes: baseAddress,
                    count: MemoryLayout<UInt32>.stride * buffer.count
                )
            }
            let element = SCNGeometryElement(
                data: indexData,
                primitiveType: .triangles,
                primitiveCount: indices.count / 3,
                bytesPerIndex: MemoryLayout<UInt32>.stride
            )

            let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
            geometry.firstMaterial = isWireframe ? wireMaterial() : surfaceMaterial()
            return geometry
        }

        private func surfaceMaterial() -> SCNMaterial {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemTeal.withAlphaComponent(0.72)
            material.emission.contents = UIColor.systemBlue.withAlphaComponent(0.18)
            material.specular.contents = UIColor.white.withAlphaComponent(0.55)
            material.isDoubleSided = true
            material.lightingModel = .physicallyBased
            return material
        }

        private func wireMaterial() -> SCNMaterial {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemPink.withAlphaComponent(0.78)
            material.emission.contents = UIColor.systemPurple.withAlphaComponent(0.30)
            material.fillMode = .lines
            material.isDoubleSided = true
            material.lightingModel = .constant
            return material
        }

        private func addReferenceRings(to node: SCNNode) {
            for index in 0..<3 {
                let torus = SCNTorus(ringRadius: CGFloat(0.22 + Double(index) * 0.12), pipeRadius: 0.0015)
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.white.withAlphaComponent(0.08)
                torus.materials = [material]

                let ringNode = SCNNode(geometry: torus)
                ringNode.position = SCNVector3(0, 0, -0.12)
                ringNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
                node.addChildNode(ringNode)
            }
        }
    }
}
