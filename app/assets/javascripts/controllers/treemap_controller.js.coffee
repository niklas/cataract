Cataract.TreemapController = Ember.ObjectController.extend
  numbers: [
          5000
          9000
          12000
          1200
          400
          50
          50
          50
          5
  ]

  objects:
    Ember.computed ->
      @get('numbers').map (n)-> Ember.Object.create(size: n)
    .property('numbers.@each')

