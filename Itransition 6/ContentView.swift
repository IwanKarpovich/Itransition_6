//
//  ContentView.swift
//  Itransition 6
//
//  Created by Ivan Karpovich on 25.12.21.
//

import SwiftUI
import AVFoundation


struct ContentView: View {
    
    @State private var showingDetail = false
    var body: some View {
        //        Button(action:{self.showingDetail.toggle()})
        //        {
        //            Text("Show")
        //        } .sheet(isPresented: $showingDetail){
        //                DrawingScreen()
        //            }
        
        CameraView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



struct CameraView: View {
    
    @StateObject var camera = CameraModel()
    @State private var showingDetail = false
    
    var body: some View{
        ZStack{
            CameraPreview(camera: camera )
                .ignoresSafeArea(.all, edges: .all)
            
            VStack{
                
                if camera.isTaken{
                    HStack{
                        
                        Spacer()
                        
                        Button(action:camera.reTake, label:{
                            Image(systemName: "camera.circle").foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        })
                            .padding(.trailing,10)
                    }
                }
                
                Spacer()
                
                HStack{
                    
                    if camera.isTaken{
                        
                        Button(action: {
                            self.showingDetail.toggle()
                            if !camera.isSaved{
                                camera.savePic()
                            }
                        }, label: { Image(systemName: "square.and.arrow.up").foregroundColor(.black)})
                            .padding(.vertical,10)
                            .padding(.horizontal, 200)
                            .background(Color.white)
                            .clipShape(Circle())
                            .sheet(isPresented: $showingDetail){Home()}
                        Spacer()
                        
                        //                        Button(action:{
                        //                            if !camera.isSaved{
                        //                                camera.savePic()
                        //                            }
                        //
                        //                        }, label:{
                        //                            Text(camera.isSaved ? "Saved" : "Save").foregroundColor(.black)
                        //                                .fontWeight(.semibold)
                        //                                .padding(.vertical,10)
                        //                                .padding(.horizontal, 20)
                        //                                .background(Color.white)
                        //                                .clipShape(Capsule())
                        //                        })
                        //                            .padding(.leading)
                        //                        Spacer()
                    }
                    
                    else{
                        Button(action: camera.takePic, label:{
                            ZStack{
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 70, height: 70)
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 75, height: 75)
                                
                            }
                        })
                    }
                    
                }
                .frame(height: 75)
            }
        }
        .onAppear(perform: {
            camera.Check()
        })
    }
}

class CameraModel: NSObject,ObservableObject, AVCapturePhotoCaptureDelegate {
    
    @Published var isTaken = false
    
    @Published var session = AVCaptureSession()
    
    @Published var alert = false
    
    @Published var output = AVCapturePhotoOutput()
    
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    @Published var isSaved = false
    
    @Published var picData = Data(count: 0)
    
    
    func Check(){
        
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case.authorized:
            setUp()
            return
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video){
                (status) in
                if status {
                    self.setUp()
                }
            }
            
        case .denied:
            self.alert.toggle()
            return
            
        default:
            return
            
        }
        
    }
    
    
    func setUp(){
        
        
        
        do{
            
            self.session.beginConfiguration()
            
            //            let da = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
            //            guard let captureDevice = da.devices.first else {
            //                print("Failed to get the camera device")
            //                return
            //            }
            
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            
            let input = try AVCaptureDeviceInput(device: device!)
            
            
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            
            
            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
            }
            
            
            self.session.commitConfiguration()
            
        }
        catch{
            print(error.localizedDescription)
        }
        
    }
    
    //    func takePic(){
    //
    //
    //        self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate:self)
    //        self.session.stopRunning()
    //        withAnimation{self.isTaken.toggle()}
    //
    //    }
    
    func takePic(){
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                    self.session.stopRunning()
                }
            }
            
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
            }
            print("pic taken...")
        }
    }
    
    func reTake(){
        self.session.startRunning()
        withAnimation{self.isTaken.toggle()}
        self.isSaved = false
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil{
            return
        }
       
        guard let imageData = photo.fileDataRepresentation() else {return}
        self.picData = imageData
    }
    
    func savePic() {
        let data = self.picData
        let image = UIImage(data: data)!
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        self.isSaved = true
        
        print("saved Successfully...")
    }
    
}


struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var camera :CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        camera.session.startRunning()
        
        return view
        
    }
    
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
}
