require "open-uri"
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Tag.destroy_all
puts "Tags succesfully destroyed ❎"
Message.destroy_all
puts "Messages succesfully destroyed ❎"
Recipe.destroy_all
puts "Recipes succesfully destroyed ❎"
Collection.destroy_all
puts "Collections succesfully destroyed ❎"
User.destroy_all
puts "Users succesfully destroyed ❎"
Restriction.destroy_all
puts "Users restrictions succesfully destroyed ❎"
UserRestriction.destroy_all

puts "Creating models..."
file = URI.parse("https://res.cloudinary.com/dhv4phhqr/image/upload/v1750235351/IMG_6555_3_aijjsy.png").open
user1 = User.new(email: "remibst@gmail.com", password: "Remidu69")
user1.photo.attach(io: file, filename: "remi.png", content_type: "image/png")
user1.save

puts "User 1 succesfully created ✅"

pancake = Recipe.create!(
  name: "Fluffy Pancakes",
  portions: 4,
  preparation_time: 20,
  description: [
    "In a mixing bowl, combine the flour, baking powder, sugar, and salt.",
    "Add the eggs, then gradually whisk in the milk.",
    "Let the batter rest for 10 minutes.",
    "Cook small scoops of batter in a hot greased pan.",
    "Flip when bubbles form and cook until golden on both sides."
  ],
  url_image: 'https://www.allrecipes.com/thmb/FE0PiuuR0Uh06uVh1c2AsKjRGbc=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/21014-Good-old-Fashioned-Pancakes-mfs_002-0e249c95678f446291ebc9408ae64c05.jpg',
  user_id: user1.id
)
names = ["flour", "eggs", "milk", "baking powder", "sugar", "salt"]
quantities = [200, 2, 300, 1, 1, 1]
units = ["g", "", "ml", "packet", "tbsp", "pinch"]
6.times do |i|
  pancake.ingredients.create!(
    name: names[i],
    quantity: quantities[i],
    unit: units[i]
  )
end
puts "Fluffy Pancakes recipe successfully created ✅"

spaghetti = Recipe.create!(
  name: "Grilled Vegetable Spaghetti",
  portions: 2,
  preparation_time: 25,
  description: [
    "Chop the vegetables.",
    "Sauté them with olive oil.",
    "Cook the spaghetti.",
    "Mix the pasta with the grilled vegetables.",
    "Add grated parmesan before serving."
  ],
  url_image: "https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg",
  user_id: user1.id
)
names = ["spaghetti", "zucchini", "bell pepper", "eggplant", "olive oil", "parmesan"]
quantities = [200, 1, 1, 1, 2, 30]
units = ["g", "", "", "", "tbsp", "g"]
6.times do |i|
  spaghetti.ingredients.create!(name: names[i], quantity: quantities[i], unit: units[i])
end
puts "Grilled Vegetable Spaghetti recipe successfully created ✅"

salad = Recipe.create!(
  name: "Fresh Quinoa Salad",
  portions: 4,
  preparation_time: 15,
  description: [
    "Cook the quinoa and let it cool.",
    "Dice the vegetables.",
    "Mix all ingredients in a bowl.",
    "Add lemon juice and olive oil.",
    "Chill before serving."
  ],
  url_image: "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg",
  user_id: user1.id
)
names = ["quinoa", "cucumber", "tomato", "feta", "olive oil", "lemon juice"]
quantities = [150, 1, 2, 100, 2, 1]
units = ["g", "", "", "g", "tbsp", "tbsp"]
6.times do |i|
  salad.ingredients.create!(name: names[i], quantity: quantities[i], unit: units[i])
end
puts "Fresh Quinoa Salad recipe successfully created ✅"

curry = Recipe.create!(
  name: "Chickpea Curry",
  portions: 3,
  preparation_time: 30,
  description: [
    "Finely chop the onion and sauté it.",
    "Add the spices and stir.",
    "Add chickpeas, coconut milk, and tomatoes.",
    "Simmer for 20 minutes.",
    "Serve with basmati rice."
  ],
  url_image: "https://images.pexels.com/photos/1640773/pexels-photo-1640773.jpeg",
  user_id: user1.id
)
names = ["chickpeas", "coconut milk", "tomatoes", "onion", "curry powder", "oil"]
quantities = [400, 200, 2, 1, 1, 1]
units = ["g", "ml", "", "", "tbsp", "tbsp"]
6.times do |i|
  curry.ingredients.create!(name: names[i], quantity: quantities[i], unit: units[i])
end
puts "Chickpea Curry recipe successfully created ✅"

gratin = Recipe.create!(
  name: "Potato Gratin",
  portions: 4,
  preparation_time: 20,
  description: [
    "Peel and thinly slice the potatoes.",
    "Rub a baking dish with garlic.",
    "Layer the potatoes and cover with cream.",
    "Add salt, pepper, and bake for 1h at 180°C.",
    "Let rest before serving."
  ],
  url_image: "https://res.cloudinary.com/dhv4phhqr/image/upload/v1749823157/scalloped-potatoes_tfzsen.png",
  user_id: user1.id
)
names = ["potatoes", "heavy cream", "milk", "garlic", "salt", "pepper"]
quantities = [800, 200, 100, 1, 1, 1]
units = ["g", "ml", "ml", "clove", "pinch", "pinch"]
6.times do |i|
  gratin.ingredients.create!(name: names[i], quantity: quantities[i], unit: units[i])
end
puts "Potato Gratin recipe successfully created ✅"

crepes = Recipe.create!(
  name: "Sweet Crepes",
  portions: 4,
  preparation_time: 15,
  description: [
    "Mix flour, eggs, and sugar.",
    "Gradually add the milk.",
    "Let rest for 30 minutes.",
    "Cook crepes in a hot pan.",
    "Serve with your favorite topping."
  ],
  url_image: "https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg",
  user_id: user1.id
)
names = ["flour", "eggs", "milk", "sugar", "butter", "salt"]
quantities = [250, 3, 500, 30, 20, 1]
units = ["g", "", "ml", "g", "g", "pinch"]
6.times do |i|
  crepes.ingredients.create!(name: names[i], quantity: quantities[i], unit: units[i])
end
puts "Sweet Crepes recipe successfully created ✅"

pad_thai = Recipe.create!(
  name: "Pad Thai",
  portions: 2,
  preparation_time: 25,
  description: [
    "Soak the rice noodles in warm water until softened.",
    "Heat oil in a wok and sauté garlic and shrimp.",
    "Add eggs and scramble them.",
    "Add noodles, tamarind paste, fish sauce, sugar, and chili flakes. Stir-fry everything.",
    "Add bean sprouts and green onions.",
    "Serve with crushed peanuts and lime wedges."
  ],
  url_image: "https://marcwiner.com/wp-content/uploads/2021/05/pad-thai-final-scaled.jpg",
  user_id: user1.id
)
names = ["rice noodles", "shrimp", "eggs", "tamarind paste", "fish sauce", "sugar", "chili flakes", "bean sprouts", "green onions", "peanuts", "lime"]
quantities = [200, 150, 2, 2, 2, 1, 0.5, 100, 2, 50, 1]
units = ["g", "g", "", "tbsp", "tbsp", "tbsp", "tsp", "g", "stalks", "g", ""]
11.times do |i|
  pad_thai.ingredients.create!(name: names[i], quantity: quantities[i], unit: units[i])
end
puts "Pad Thai recipe successfully created ✅"


ramen = Recipe.create!(
  name: "Japanese Ramen",
  portions: 2,
  preparation_time: 40,
  description: [
    "Prepare broth with chicken stock, soy sauce, miso paste, and ginger.",
    "Simmer for 30 minutes.",
    "Boil the ramen noodles separately.",
    "Soft-boil the eggs.",
    "Assemble bowls with noodles, broth, sliced pork, boiled egg, nori, and green onions."
  ],
  url_image: "https://japanesetaste.com/cdn/shop/articles/the-ultimate-guide-to-ramen-the-humble-japanese-noodle-soup-japanese-taste.jpg?v=1711888075&width=5760",
  user_id: user1.id
)

names = ["chicken stock", "soy sauce", "miso paste", "ginger", "ramen noodles", "pork belly", "eggs", "nori", "green onions"]
quantities = [1000, 3, 2, 1, 200, 150, 2, 2, 2]
units = ["ml", "tbsp", "tbsp", "tbsp (grated)", "g", "g", "", "sheets", "stalks"]
9.times do |i|
  ramen.ingredients.create!(name: names[i], quantity: quantities[i], unit: units[i])
end
puts "Japanese Ramen recipe successfully created ✅"

acai = Recipe.create!(
  name: "Açaï Bowl",
  portions: 1,
  preparation_time: 10,
  description: [
    "Blend the açaí pulp with banana, frozen berries, and a bit of plant-based milk until smooth.",
    "Pour into a bowl.",
    "Add toppings: granola, banana slices, fresh fruits, chia seeds, and honey."
  ],
  url_image: "https://healthfulblondie.com/wp-content/uploads/2022/06/Homemade-Healthy-Protein-Acai-Bowl.jpg",
  user_id: user1.id
)

names = ["açaí pulp", "banana", "frozen berries", "plant-based milk", "granola", "banana (topping)", "fresh fruits", "chia seeds", "honey"]
quantities = [100, 1, 100, 50, 30, 0.5, 50, 1, 1]
units = ["g", "", "g", "ml", "g", "", "g", "tbsp", "tbsp"]
9.times do |i|
  acai.ingredients.create!(name: names[i], quantity: quantities[i], unit: units[i])
end
puts "Açaï Bowl recipe successfully created ✅"

fried_rice = Recipe.create!(
  name: "Egg Fried Rice",
  portions: 2,
  preparation_time: 20,
  description: [
    "Cook and cool the rice beforehand.",
    "Heat oil in a wok, scramble the eggs, and set aside.",
    "Sauté chopped onions and frozen peas.",
    "Add cooked rice and soy sauce, stir-fry everything together.",
    "Mix back the scrambled eggs and serve."
  ],
  url_image: "https://www.chilipeppermadness.com/wp-content/uploads/2020/11/Nasi-Goreng-Indonesian-Fried-Rice-SQ.jpg",
  user_id: user1.id
)
names = ["rice", "eggs", "onion", "frozen peas", "soy sauce", "vegetable oil"]
quantities = [300, 2, 1, 100, 2, 2]
units = ["g (cooked)", "", "", "g", "tbsp", "tbsp"]
6.times do |i|
  fried_rice.ingredients.create!(name: names[i], quantity: quantities[i], unit: units[i])
end
puts "Egg Fried Rice recipe successfully created ✅"

brunch = Collection.create!(
  name: "brunch",
  url_image: "https://res.cloudinary.com/dhv4phhqr/image/upload/v1749654124/brunch_x10hlt.png",
  user_id: user1.id
)
puts "brunch collection successfully created ✅"
healthy = Collection.create!(
  name: "healthy",
  url_image: "https://res.cloudinary.com/dhv4phhqr/image/upload/v1749654213/healthy_ystbgg.jpg",
  user_id: user1.id
)
puts "healthy collection successfully created ✅"
favorites = Collection.create!(
  name: "Favorites",
  url_image: "https://raw.githubusercontent.com/lewagon/fullstack-images/master/uikit/dinner.jpg",
  user_id: user1.id
)
puts "Favorites collection successfully created ✅"
cheap = Collection.create!(
  name: "cheap",
  url_image: "https://res.cloudinary.com/dhv4phhqr/image/upload/v1749654154/cheap_pm6vvh.jpg",
  user_id: user1.id
)
asian = Collection.create!(
  name: "asian",
  url_image: "https://res.cloudinary.com/dhv4phhqr/image/upload/v1749654186/asian_jimmjc.jpg",
  user_id: user1.id
)
puts "Favorites collection successfully created ✅"

pancaketobrunch = Tag.create!(
  collection_id: brunch.id,
  recipe_id: pancake.id
)
crepestobrunch = Tag.create!(
  collection_id: brunch.id,
  recipe_id: crepes.id
)
tag1 = Tag.create!(
  collection_id: healthy.id,
  recipe_id: gratin.id
)
tag2 = Tag.create!(
  collection_id: healthy.id,
  recipe_id: salad.id
)
tag3 = Tag.create!(
  collection_id: healthy.id,
  recipe_id: spaghetti.id
)
tag4 = Tag.create!(
  collection_id: favorites.id,
  recipe_id: spaghetti.id
)
tag5 = Tag.create!(
  collection_id: favorites.id,
  recipe_id: curry.id
)
tag6 = Tag.create!(
  collection_id: favorites.id,
  recipe_id: ramen.id
)
tag6 = Tag.create!(
  collection_id: asian.id,
  recipe_id: ramen.id
)
tag7 = Tag.create!(
  collection_id: asian.id,
  recipe_id: pad_thai.id
)
tag8 = Tag.create!(
  collection_id: brunch.id,
  recipe_id: acai.id
)
tag9 = Tag.create!(
  collection_id: cheap.id,
  recipe_id: fried_rice.id
)
tag9 = Tag.create!(
  collection_id: asian.id,
  recipe_id: fried_rice.id
)


puts "Collections successfully fulfilled 🚀"

restrictions = [
  "Vegetarian",
  "Vegan",
  "Gluten-Free",
  "Lactose-Free",
  "Peanut-Free",
  "Shellfish-Free",
  "Egg-Free",
  "Soy-Free",
  "Nut-Free",
  "Fish-Free",
  "Pregnancy-Safe"
]

restrictions.each do |name|
  Restriction.find_or_create_by!(name: name)
end

puts "Restrictions successfully created 🚀"
