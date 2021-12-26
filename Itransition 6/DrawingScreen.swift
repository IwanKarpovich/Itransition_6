//
//  DrawingScreen.swift
//  Itransition 6
//
//  Created by Ivan Karpovich on 25.12.21.
//

import SwiftUI
import PencilKit

struct DrawingScreen: View {
    @EnvironmentObject var model: DrawingViewModel
    var body: some View {
        ZStack{
            
            GeometryReader{ proxy -> AnyView in
                
                let size = proxy.frame(in: .global)
                
                DispatchQueue.main.async {
                    if model.rect == .zero {
                        model.rect = size //proxy.frame(in: .global)
                        
                    }
                }
                
                return AnyView(
                    ZStack{
                        Spacer()
                        CanvasView(canvas:$model.canvas, imageData: $model.imageData, toolPicker: $model.toolPicker,rect: size.size)
                        
                        ForEach(model.textBoxes){box in
                            
                            Text(model.textBoxes[model.currentIndex].id == box.id && model.addNewBox ? "":  box.text)
                                .font(.system(size: 30))
                                .fontWeight(box.isBold ? .bold : .none)
                                .foregroundColor(box.textColor)
                                .offset(box.offset)
                            
                                .gesture(DragGesture().onChanged({ (value) in
                                    let current = value.translation
                                    let lastOffset = box.lastOffset
                                    let newTranslation = CGSize(width: lastOffset.width + current.width, height: lastOffset.height + current.height)
                                    
                                    model.textBoxes[getIndex(textBox: box)].offset = newTranslation
                                    
                                }).onEnded({ (value) in
                                    model.textBoxes[getIndex(textBox: box)]
                                        .lastOffset = value.translation
                                    
                                }))
                                .onLongPressGesture{
                                    model.toolPicker.setVisible(false, forFirstResponder: model.canvas)
                                    model.canvas.restorationIdentifier
                                    model.currentIndex = getIndex(textBox: box)
                                    withAnimation{
                                        model.addNewBox = true
                                    }
                                }
                        }
                    }
                )
            }
            
        }
        
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: model.saveImage, label: {
                    Text("Save").frame(width: 50, height: 50)
                })
            }
            
            ToolbarItem(placement: .navigationBarTrailing){
                
                Button(action: {
                    
                    model.textBoxes.append(TextBox())
                    
                    model.currentIndex = model.textBoxes.count - 1
                    withAnimation{model.addNewBox.toggle()}
                    
                    model.toolPicker.setVisible(false, forFirstResponder: model.canvas)
                    model.canvas.resignFirstResponder()
                }, label: {
                    Image(systemName: "plus").frame(width: 50, height: 50)
                })
                
            }
            
        })
    }
    func getIndex(textBox: TextBox)->Int{
        let index = model.textBoxes.firstIndex { (box) -> Bool in
            return textBox.id == box.id
        } ?? 0
        return index
    }
}

struct DrawingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}


struct CanvasView: UIViewRepresentable {
    
    
    
    @Binding var canvas: PKCanvasView
    @Binding var imageData: Data
    @Binding var toolPicker: PKToolPicker
    
    var rect: CGSize
    
    
    func makeUIView(context: Context) -> PKCanvasView {
        
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        canvas.drawingPolicy = .anyInput
        
        if let image = UIImage(data: imageData){
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0 , width: rect.width , height: rect.height)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            
            let subView = canvas.subviews[0]
            subView.addSubview(imageView)
            subView.sendSubviewToBack(imageView)
            
            
            
            toolPicker.setVisible(true, forFirstResponder: canvas)
            toolPicker.addObserver(canvas)
            canvas.becomeFirstResponder()
            
        }
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        
    }
    
    
}
