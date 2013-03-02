Cataract.FileField = Bootstrap.Forms.Field.extend
  inputField: Ember.View.extend
    tagName: 'input'
    attributeBindings: ['type', 'id']
    type: 'file'

    change: (event)->
      parent = @get('parentView')
      reader = new FileReader()
      reader.onload = (upload)->
        parent.set('file', upload.target.result)
      first = event.target.files[0]
      parent.set('filename', first.name)
      reader.readAsDataURL(first)
