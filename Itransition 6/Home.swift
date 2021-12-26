//
//  Home.swift
//  Itransition 6
//
//  Created by Ivan Karpovich on 24.12.21.
//

import SwiftUI

struct Home: View {
    
    @StateObject var model = DrawingViewModel ()
    
    var body: some View {
        
        
        ZStack{
            NavigationView {
                VStack{
                    
                    if let _ = UIImage(data: model.imageData){
                        
                        
                        DrawingScreen().environmentObject(model)
                    
                            .toolbar(content: {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: model.cancelImageEditing, label:{Text("Button")
                                        
                                    }).frame(width: 100, height: 100)
                                }
                            })
                    }
                    else{
                        Button(action:{
                            model.showImagePicker.toggle()
                            
                        }, label:{
                            Image(systemName: "plus").font(.title)
                                .foregroundColor(.black)
                                .frame(width: 50, height: 50)
                            
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color:Color.black.opacity(0.07), radius: 5, x: 5, y: 5)
                                .shadow(color:Color.black.opacity(0.07), radius: 5, x: -5, y: -5)
                        })
                        
                    }
                    
                }
                .navigationTitle("Image Editor")
            }
            if model.addNewBox{
                Color.black.opacity(0.7).ignoresSafeArea()
                
                TextField("Type Here", text: $model.textBoxes[model.currentIndex].text)
                    .font(.system(size: 35, weight: model.textBoxes[model.currentIndex].isBold ? .bold : .regular)).colorScheme(.dark).foregroundColor(model.textBoxes[model.currentIndex].textColor).padding()
                
                HStack{
                    Button(action: {
                        
                        model.textBoxes[model.currentIndex].isAdded = true
                        model.toolPicker.setVisible(true, forFirstResponder: model.canvas)
                        model.canvas.becomeFirstResponder()
                        
                        withAnimation{model.addNewBox = false}
                    }, label: {
                        Text("Add").fontWeight(.heavy).foregroundColor(.white).padding(.vertical)
                        
                    })
                    
                    Spacer()
                    Button(action: model.cancelTextView, label: {
                        Text("Cancel").fontWeight(.heavy).foregroundColor(.white).padding(.vertical)
                        
                    })
                }
                .overlay(
                    HStack(spacing: 15) {
                        ColorPicker("", selection: $model.textBoxes[model.currentIndex].textColor).labelsHidden()
                        
                        Button(action: {
                            model.textBoxes[model.currentIndex].isBold.toggle()
                        }, label: {
                            Text(model.textBoxes[model.currentIndex].isBold ? "Normal" : "Bold").fontWeight(.bold).foregroundColor(.white)
                        })
                    }
                    
                ) .frame( maxHeight: .infinity, alignment: .top)
                    
            }
               
        }
        
        .sheet(isPresented: $model.showImagePicker,  content: {ImagePicker(showPicker: $model.showImagePicker, imageData: $model.imageData)
            
        })
        .alert(isPresented: $model.showAlert, content: {
            Alert(title: Text("Message"), message: Text(model.message), dismissButton: .destructive(Text("ok")))
        })
        
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
