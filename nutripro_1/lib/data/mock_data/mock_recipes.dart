class Recipe {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> ingredients;
  final String preparation;

  const Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.ingredients,
    required this.preparation,
  });
}

final Map<String, List<Recipe>> mockRecipes = {
  'Desayuno': [
    Recipe(
      id: 'd1',
      name: 'Avena con Frutas',
      imageUrl: 'assets/images/recipes/d1.jpg',
      ingredients: [
        '1 taza de avena',
        '1 plátano',
        'Fresas',
        'Leche de almendras',
      ],
      preparation:
          '1. Cocinar la avena con la leche.\n2. Cortar las frutas.\n3. Servir y decorar.',
    ),
    Recipe(
      id: 'd2',
      name: 'Tostadas de Aguacate',
      imageUrl: 'assets/images/recipes/d2.jpg',
      ingredients: [
        '2 rebanadas de pan integral',
        '1 aguacate',
        'Sal y pimienta',
        'Aceite de oliva',
      ],
      preparation:
          '1. Tostar el pan.\n2. Machacar el aguacate.\n3. Untar en el pan y sazonar.',
    ),
    Recipe(
      id: 'd3',
      name: 'Batido Verde',
      imageUrl: 'assets/images/recipes/d3.jpg',
      ingredients: ['Espinacas', 'Manzana verde', 'Pepino', 'Agua de coco'],
      preparation:
          '1. Lavar los ingredientes.\n2. Cortar en trozos.\n3. Licuar todo hasta que esté suave.',
    ),
    Recipe(
      id: 'd4',
      name: 'Tortilla Francesa',
      imageUrl: 'assets/images/recipes/d4.jpg',
      ingredients: ['2 huevos', 'Sal', 'Aceite', 'Hierbas finas'],
      preparation:
          '1. Batir los huevos.\n2. Calentar la sartén.\n3. Cocinar hasta el punto deseado.',
    ),
  ],
  'Almuerzo': [
    Recipe(
      id: 'a1',
      name: 'Yogur con Granola',
      imageUrl: 'assets/images/recipes/a1.jpg',
      ingredients: ['Yogur griego', 'Granola', 'Miel', 'Arándanos'],
      preparation:
          '1. Servir el yogur en un bol.\n2. Añadir la granola y los arándanos.\n3. Rociar con miel.',
    ),
    Recipe(
      id: 'a2',
      name: 'Manzana con Mantequilla de Cacahuates',
      imageUrl: 'assets/images/recipes/a2.jpg',
      ingredients: ['1 manzana', '2 cdas de mantequilla de cacahuates'],
      preparation:
          '1. Lavar y cortar la manzana en gajos.\n2. Servir con la mantequilla de cacahuates.',
    ),
    Recipe(
      id: 'a3',
      name: 'Barrita de Cereales',
      imageUrl: 'assets/images/recipes/a3.jpg',
      ingredients: ['Avena', 'Miel', 'Frutos secos', 'Chips de chocolate'],
      preparation:
          '1. Mezclar ingredientes.\n2. Hornear en molde.\n3. Cortar en barritas.',
    ),
    Recipe(
      id: 'a4',
      name: 'Fruta Fresca',
      imageUrl: 'assets/images/recipes/a4.jpg',
      ingredients: ['Sandía', 'Melón', 'Piña'],
      preparation:
          '1. Pelar las frutas.\n2. Cortar en cubos.\n3. Mezclar en un bol.',
    ),
  ],
  'Comida': [
    Recipe(
      id: 'c1',
      name: 'Ensalada César',
      imageUrl: 'assets/images/recipes/c1.jpg',
      ingredients: [
        'Lechuga romana',
        'Pollo a la parrilla',
        'Crutones',
        'Queso parmesano',
        'Aderezo César',
      ],
      preparation:
          '1. Lavar la lechuga.\n2. Cortar el pollo.\n3. Mezclar todo en un bol grande.',
    ),
    Recipe(
      id: 'c2',
      name: 'Salmón al Horno',
      imageUrl: 'assets/images/recipes/c2.jpg',
      ingredients: ['Filete de salmón', 'Limón', 'Eneldo', 'Espárragos'],
      preparation:
          '1. Precalentar el horno.\n2. Sazonar el salmón.\n3. Hornear por 15-20 minutos.',
    ),
    Recipe(
      id: 'c3',
      name: 'Pasta Integral con Verduras',
      imageUrl: 'assets/images/recipes/c3.jpg',
      ingredients: [
        'Pasta integral',
        'Brócoli',
        'Zanahoria',
        'Salsa de tomate',
      ],
      preparation:
          '1. Cocer la pasta.\n2. Saltear las verduras.\n3. Mezclar con la salsa.',
    ),
    Recipe(
      id: 'c4',
      name: 'Pollo al Curry',
      imageUrl: 'assets/images/recipes/c4.jpg',
      ingredients: [
        'Pechuga de pollo',
        'Leche de coco',
        'Pasta de curry',
        'Arroz basmati',
      ],
      preparation:
          '1. Sofreír el pollo.\n2. Añadir curry y leche de coco.\n3. Servir con arroz.',
    ),
  ],
  'Merienda': [
    Recipe(
      id: 'm1',
      name: 'Batido de Proteínas',
      imageUrl: 'assets/images/recipes/m1.jpg',
      ingredients: ['Proteína en polvo', 'Leche o agua', 'Hielo'],
      preparation:
          '1. Poner todo en el shaker.\n2. Agitar bien.\n3. Beber frío.',
    ),
    Recipe(
      id: 'm2',
      name: 'Tostada con Hummus',
      imageUrl: 'assets/images/recipes/m2.jpg',
      ingredients: ['Pan integral', 'Hummus', 'Pimentón'],
      preparation:
          '1. Tostar el pan.\n2. Untar el hummus.\n3. Espolvorear pimentón.',
    ),
    Recipe(
      id: 'm3',
      name: 'Puñado de Nueces',
      imageUrl: 'assets/images/recipes/m3.jpg',
      ingredients: ['Nueces', 'Almendras', 'Avellanas'],
      preparation: '1. Seleccionar una porción adecuada (30g).\n2. Disfrutar.',
    ),
    Recipe(
      id: 'm4',
      name: 'Yogur con Frutas',
      imageUrl: 'assets/images/recipes/m4.jpg',
      ingredients: ['Yogur natural', 'Fresas', 'Kiwi'],
      preparation: '1. Cortar la fruta.\n2. Mezclar con el yogur.',
    ),
  ],
  'Cena': [
    Recipe(
      id: 'ce1',
      name: 'Crema de Calabaza',
      imageUrl: 'assets/images/recipes/ce1.jpg',
      ingredients: ['Calabaza', 'Cebolla', 'Caldo de verduras', 'Nata líquida'],
      preparation:
          '1. Cocer la calabaza y cebolla.\n2. Triturar con el caldo.\n3. Añadir un toque de nata.',
    ),
    Recipe(
      id: 'ce2',
      name: 'Pescado a la Plancha',
      imageUrl: 'assets/images/recipes/ce2.jpg',
      ingredients: [
        'Filete de pescado blanco',
        'Ajo',
        'Perejil',
        'Ensalada verde',
      ],
      preparation:
          '1. Calentar la plancha.\n2. Cocinar el pescado vuelta y vuelta.\n3. Servir con ensalada.',
    ),
    Recipe(
      id: 'ce3',
      name: 'Tortilla de Espinacas',
      imageUrl: 'assets/images/recipes/ce3.jpg',
      ingredients: ['Huevos', 'Espinacas frescas', 'Ajo en polvo'],
      preparation:
          '1. Saltear las espinacas.\n2. Batir los huevos.\n3. Cuajar la tortilla.',
    ),
    Recipe(
      id: 'ce4',
      name: 'Ensalada de Quinoa',
      imageUrl: 'assets/images/recipes/ce4.jpg',
      ingredients: ['Quinoa cocida', 'Tomate cherry', 'Pepino', 'Queso feta'],
      preparation:
          '1. Mezclar la quinoa con las verduras.\n2. Añadir el queso.\n3. Aliñar al gusto.',
    ),
  ],
};
