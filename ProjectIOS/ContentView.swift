//
//  ContentView.swift
//  ProjectIOS
//
//  Created by MS on 15/01/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var cart = Cart()
    
    var body: some View {
        VStack{
            AppHeaderView()
            
            TabView{
                HomeView()
                    .tabItem{
                        Label("Home", systemImage: "house")
                    }
                ShopView()
                    .tabItem{
                        Label("Menu", systemImage: "list.dash")
                    }
                CartView()
                    .tabItem{
                        Label("Cart",
                        systemImage: "cart")
                    }
            }
            // items list
            
        }
        .environmentObject(cart)
    }
}


struct HomeViewLogo: View{
    @State var bowAnimation = false
    var body: some View{
        
        GeometryReader{proxy in
            let size = proxy.size
            
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Image("amazon")
                    .resizable()
                    .scaledToFit()
                    .padding(0.0)
                    .clipped()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    Spacer()
                }
                Circle()
                    .trim(from: 0, to: bowAnimation ?  0.2 : 0)
                    .stroke(
                        .linearGradient(.init(colors: [
                            Color.red,
                            Color.orange
                        ]), startPoint: .leading, endPoint: .trailing)
                        ,style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: size.width/2, height: size.width/2)
                    .rotationEffect(.init(degrees: 55))
                    .offset(y: -260)
                
            }.onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3)
                {
                    withAnimation(.linear(duration: 2)){
                        bowAnimation.toggle()
                    }
                }
                
            }
        }
        
    }
}

// app header
struct AppHeaderView: View{
    var body: some View{
        HStack{
            Image("amazon")
                .resizable()
                .scaledToFit()
                .padding(0.0)
                .clipped()
                .frame(width: 100, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}



// home
struct HomeView: View{
    var body: some View{
        VStack{
            HomeViewLogo()
        }
    }
}

struct ShopView: View{
    @State private var selected_category = "All"
    @State private var selected_subcategory = "All"
    
    var body: some View{
        NavigationView{
            VStack{
                // category selection bar
                HStack{
                    Text("category")
                    Picker("Select category", selection: $selected_category){
                        ForEach(categories, id: \.self){
                            category in
                            Text(category)
                        }
                    }.pickerStyle(.menu)
                    
                    Text("subcategory")
                    Picker("Select subcategory", selection: $selected_subcategory){
                        ForEach(subcategories[selected_category]!, id: \.self){
                            Text($0)
                        }
                    }.pickerStyle(.menu)
                }
                
                List{
                    ForEach(productCategories){category in
                        if category.categoryName==selected_category || selected_category=="All"{
                            ForEach(category.subcategories){subcategory in
                                if subcategory.subcategoryName==selected_subcategory || selected_subcategory=="All"{
                                    ForEach(subcategory.products){
                                        product in
                                        NavigationLink(destination: ProductDetailView(product: product)){
                                            ProductListView(product: product)
                                        }
                                    }
                                }
                                
                            }
                        }
                        
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}




struct CartView: View{
    @EnvironmentObject var cart: Cart
    @State private var final_price = 0
    
    var body: some View{
        VStack{
            Text("Cart")

            List{
                ForEach(cart.productsDictionary.sorted(by: >), id: \.key){key, value in
                    HStack{
                        Text(key.name)
                        
                        Spacer()
                        
                        Text("\(key.price, specifier: "%.2f")")
                        Text("$")
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }){
                            Text("+")
                        }
                        .onTapGesture{
                            cart.add(p: key)
                        }
                        .padding(5)
                        .foregroundColor(.white)
                        .background(Color.orange)
                        .cornerRadius(40)
                        
                        Text(String(value))
                        
                        Button(action: {
                            
                        }){
                            Text("-")
                        }
                        .onTapGesture{
                            cart.substract(p: key)
                        }
                        .padding(5)
                        .foregroundColor(.white)
                        .background(Color.orange)
                        .cornerRadius(40)
                    }
                }
            }
            HStack{
                Text("Total price: ")
                Text("\(cart.total(), specifier: "%.2f")")
                Text("$")
            }.font(.largeTitle)
            
        }
        
    }
}




//product views
struct ProductListView: View{
    var product: Product
    
    var body: some View{
        HStack{
            Image(product.image)
                .resizable()
                .scaledToFit()
                .padding(0.0)
                .clipped()
                .frame(width: 125, height: 125)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(product.name)
        }
    }
}


struct ProductDetailView: View{
    var product: Product
    @EnvironmentObject var cart: Cart
    
    var body: some View{
        VStack{
            Image(product.image)
                .resizable()
                .scaledToFit()
                .padding(0.0)
                .clipped()
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text(product.name)
                .font(.largeTitle)
            HStack{
                Text("Price ")
                Text("\(product.price, specifier: "%.2f")")
                Text("$")
            }
            Text(product.description)
                .padding()
            Button(action: {
                cart.add(p: product)
            }){
                Text("Add to cart")
            }
            .padding(5)
            .foregroundColor(.white)
            .background(Color.orange)
            .cornerRadius(40)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}




//domain models - business logic
struct Product: Identifiable, Hashable, Comparable{
    static func < (lhs: Product, rhs: Product) -> Bool {
        lhs.name < rhs.name
    }
    
    var id = UUID()
    
    var name: String
    var image: String
    var price: Float
    var description: String
}

struct ProductCategory: Identifiable{
    var id = UUID()
    
    var categoryName: String
    var subcategories: [ProductSubCategory]
}

struct ProductSubCategory: Identifiable{
    var id = UUID()
    
    var subcategoryName: String
    var products: [Product]
}

let categories = ["All", "Books", "Movies"]
let subcategories = ["All" : ["All"],
                    "Books" : ["All", "Classics", "Crime"],
                     "Movies" : ["All", "Action", "Fantasy"]]

let lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eu imperdiet ante, vitae vehicula lectus. Nunc facilisis sed arcu nec fermentum. Ut luctus viverra quam, ac lacinia justo mollis at. Curabitur vitae nibh auctor, aliquam est non, dictum tortor. In purus ante, porttitor ut dolor at, vulputate rhoncus lorem. Sed tincidunt elementum ullamcorper. Ut hendrerit, ipsum eget faucibus bibendum, nisi orci euismod lorem, quis accumsan est lacus a ante. Nam sit amet tellus id mauris dignissim fermentum. Nunc nec convallis odio."

// dummy database
let productCategories = [
    ProductCategory(
        categoryName: "Books", subcategories: [ProductSubCategory(
            subcategoryName: "Classics", products: [
                Product(name: "Pride and Prejudice", image: "pride_and_prejudice", price: 21.20, description: lorem),
                Product(name: "To Kill a Mockingbird", image: "to_kill_a_mockinbird", price: 39.99, description: lorem),
                Product(name: "The Great Gatsby", image: "the_great_gatsby", price: 42.99, description: "Text"),
                Product(name: "One Hundred Years of Solitude", image: "one_hundred_years_of_solitude", price: 19.90, description: lorem),
                Product(name: "In Cold Blood", image: "crime_and_punishment", price: 21.50, description: lorem),
                Product(name: "Wide Sargasso Sea", image: "pride_and_prejudice", price: 21.20, description: lorem),
                Product(name: "Brave New World", image: "the_great_gatsby", price: 39.99, description: lorem),
                Product(name: "Jane Eyre", image: "to_kill_a_mockinbird", price: 19.90, description: lorem),
                Product(name: "I Capture The Castle", image: "one_hundred_years_of_solitude", price: 21.50, description: lorem),
                Product(name: "Crime and Punishment", image: "crime_and_punishment", price: 21.50, description: lorem)
                ]
        ), ProductSubCategory(
            subcategoryName: "Crime", products: [
                Product(name: "Garenthill", image: "garenthill", price: 21.20, description: lorem),
                Product(name: "The Dry", image: "the_silence_of_the_lambs", price: 39.99, description: lorem),
                Product(name: "And Then There Were None", image: "garenthill", price: 42.99, description: lorem),
                Product(name: "61 hours", image: "the_silence_of_the_lambs", price: 19.90, description: lorem),
                Product(name: "The Silence of the Lambs", image: "garenthill", price: 21.50, description: lorem)
                ]
        )]
    ), ProductCategory(
        categoryName: "Movies", subcategories: [ProductSubCategory(
            subcategoryName: "Action", products: [
                Product(name: "Jurassic World", image: "jurassic_world", price: 21.20, description: lorem),
                Product(name: "Indiana Jones", image: "indiana_jones", price: 39.99, description: lorem),
                Product(name: "Top Gun: Maverick", image: "top_gun_maverick", price: 42.99, description: lorem),
                Product(name: "No Time to Die", image: "jurassic_world", price: 19.90, description: lorem),
                Product(name: "In Cold Blood", image: "indiana_jones", price: 21.50, description: lorem)
                ]
        ), ProductSubCategory(
            subcategoryName: "Fantasy", products: [
                Product(name: "The Lord of the Rings", image: "the_lord_of_the_rings", price: 21.20, description: lorem),
                Product(name: "Coco", image: "harry_potter", price: 39.99, description: lorem),
                Product(name: "Pan’s Labyrinth", image: "the_lord_of_the_rings", price: 42.99, description: lorem),
                Product(name: "Harry Potter", image: "harry_potter", price: 19.90, description: lorem),
                Product(name: "The Chronicles of Narnia", image: "the_lord_of_the_rings", price: 21.50, description: lorem)
                ]
        )]
    )
]


class Cart: ObservableObject{
    @Published var productsDictionary: [Product: Int] = [Product:Int]()
    
    func add(p : Product){
        if productsDictionary[p] != nil{
            productsDictionary[p] = productsDictionary[p]!+1
        }
        else{
            productsDictionary[p] = 1
        }
    }
    
    func substract(p: Product){
        if productsDictionary[p] != nil{
            if productsDictionary[p] == 0{
                productsDictionary[p] = nil
            }
            else if productsDictionary[p] == 1{
                productsDictionary[p] = nil
            }
            else{
                productsDictionary[p] = productsDictionary[p]!-1
            }
            
        }
    }
    
    func total() -> Float{
        var total: Float = 0
        for (key, value) in productsDictionary{
            total += key.price*Float(value)
        }
        return total
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
